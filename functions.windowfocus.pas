unit functions.windowfocus;

interface

uses
  Windows, Messages, Forms, MultiMon, SysUtils, ShellApi;

type
  TWindowFocusHelper = class
  private
    class procedure ForceForegroundWindow(hwnd: HWND);
    class function IsWindowFullscreen(hwnd: HWND): Boolean;
  public
    class procedure FocusWindow(FormHandle: HWND);
  end;

implementation

procedure SwitchToThisWindow(hWnd: HWND; fUnknown: BOOL); external 'user32.dll';

class procedure TWindowFocusHelper.ForceForegroundWindow(hwnd: HWND);
var
  HForegroundThread, HAppThread: DWORD;
  HActiveWindow: THandle;
  FClientId: DWORD;
begin
  TForm(hwnd).Show;
  HActiveWindow := GetForegroundWindow();
  if HActiveWindow <> hwnd then
  begin
    HForegroundThread := GetWindowThreadProcessId(HActiveWindow, @FClientId);
    AllowSetForegroundWindow(FClientId);
    HAppThread := GetCurrentThreadId;

    if not SetForegroundWindow(hwnd) then
      SwitchToThisWindow(GetDesktopWindow, True);

    // magic part to switch correctly to our window
    if HForegroundThread <> HAppThread then
    begin
      AttachThreadInput(HForegroundThread, HAppThread, True);
      BringWindowToTop(hwnd);
      Windows.SetFocus(hwnd);
      AttachThreadInput(HForegroundThread, HAppThread, False);
    end;

    var rct: TRect;
    Windows.GetWindowRect(HActiveWindow, rct);
    SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, {SWP_ASYNCWINDOWPOS or }SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);

    var helperPath := ExtractFilePath(ParamStr(0))+'focusHelper.exe';
    if FileExists(helperPath) then
      ShellExecute(0, 'OPEN', PChar(ExtractFilePath(ParamStr(0))+'focusHelper.exe'), nil, nil, SW_SHOW);
  end;

end;

class function TWindowFocusHelper.IsWindowFullscreen(hwnd: HWND): Boolean;
var
  WinRect: TRect;
  Monitor: HMonitor;
  MonInfo: TMonitorInfo;
begin
  GetWindowRect(hwnd, WinRect);
  Monitor := MonitorFromWindow(hwnd, MONITOR_DEFAULTTOPRIMARY);
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(Monitor, @MonInfo);

  Result := (WinRect.Left = MonInfo.rcMonitor.Left) and
            (WinRect.Top = MonInfo.rcMonitor.Top) and
            (WinRect.Right = MonInfo.rcMonitor.Right) and
            (WinRect.Bottom = MonInfo.rcMonitor.Bottom);
end;

class procedure TWindowFocusHelper.FocusWindow(FormHandle: HWND);
begin
  // Handle minimized state
  if IsIconic(FormHandle) then
    ShowWindow(FormHandle, SW_RESTORE);

  // Don't steal focus from fullscreen applications
  if not IsWindowFullscreen(GetForegroundWindow) then
  begin
    // Try standard approach first
    if not SetForegroundWindow(FormHandle) then
      // If that fails, use the forced approach
      ForceForegroundWindow(FormHandle);
  end;

  // Ensure window is visible and on top
  ShowWindow(FormHandle, SW_SHOW);
  BringWindowToTop(FormHandle);

  // Send activation message
  SendMessage(FormHandle, WM_ACTIVATE, WA_ACTIVE, 0);
end;

end.
