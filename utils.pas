unit utils;

interface

uses
  Windows, Forms, Classes, TLHelp32, PsAPI, SysUtils, Registry, Graphics, DWMAPI,
  OleAcc, Variants, DirectDraw, ActiveX, ShellAPI;

function IsDirectXAppRunningFullScreen: Boolean;
function DetectFullScreen3D: Boolean;
function DetectFullScreenApp(AHandle: HWND = 0): Boolean;
function IsDesktopWindow(AHandle: HWND): Boolean;

implementation

function GetShellWindow:HWND;stdcall;
    external user32 Name 'GetShellWindow';

function IsDirectXAppRunningFullScreen: Boolean;
var
  LSPI: Boolean;
begin
  Result := False;
  if SystemParametersInfo(SPI_GETCURSORSHADOW, 0, @LSPI, 0) and not LSPI then
  begin
    if SystemParametersInfo(SPI_GETHOTTRACKING, 0, @LSPI, 0) and not LSPI then
    begin
      Result := DetectFullScreen3D;
    end;
  end;
end;

function DetectFullScreen3D: Boolean;
var
  DW: IDirectDraw7;
  HR: HRESULT;
begin
  Result := False;

  HR := coinitialize(nil);
  if Succeeded(HR) then
  begin
    HR := DirectDrawCreateEx(PGUID(DDCREATE_EMULATIONONLY), DW, IDirectDraw7, nil);
    if HR = DD_OK then
    begin
      HR := DW.TestCooperativeLevel;
      if HR = DDERR_EXCLUSIVEMODEALREADYSET then
        Result := True;
    end;
  end;

  CoUninitialize;
end;

function DetectFullScreenApp(AHandle: HWND = 0): Boolean;
var
  curwnd: HWND;
  wndPlm: WINDOWPLACEMENT;
  R: TRect;
  Mon: TMonitor;
begin
  Result := False;
  if AHandle = 0 then
    curwnd := GetForegroundWindow
  else
    curwnd := AHandle;
  if curwnd <= 0 then Exit;

  // ignore maximized windows with caption bar
  if GetWindowLong(curwnd, GWL_STYLE) and WS_CAPTION = WS_CAPTION then
    Exit;

  if not IsWindow(curwnd) then Exit;
  if IsDesktopWindow(curwnd) then Exit;

  Mon := Screen.MonitorFromWindow(curwnd);
{ TODO : This workaround kind of fixes, but it blocks on fast fullscreen apps detection leaving them as if it were full app, }
//  if Assigned(Mon) then //o fix Mon.BoundsRect EAccessViolation ... added Assigned(Mon) to following 2 comparisons
  begin
    GetWindowRect(curwnd, R);
    GetWindowPlacement(curwnd, wndPlm);
    if (wndPlm.showCmd and SW_SHOWMAXIMIZED) = SW_SHOWMAXIMIZED then
    begin
      if Assigned(Mon) and (Mon.BoundsRect.Width = R.Width) and (Mon.BoundsRect.Height = R.Height) then
        Result := True;
    end
    else
    begin
      // some applications do not set SW_SHOWMAXIMIZED flag e.g. MPC-HC media player
      // ignore maximized when workarearect is similar (i.e. taskbar is on top, might not be the same on secondary monitor)
  //    if IsTaskbarAlwaysOnTop then
  //    begin
  //      if (Screen.MonitorCount > 1) and (Mon.Handle =
  //    if ((Screen.MonitorCount > 1) and (FindWindow('Shell_SecondaryTrayWnd', nil)<>0) and (Mon.WorkareaRect <> Mon.BoundsRect))
  //    // if there is another monitor without taskbar then
  //    or ((Screen.MonitorCount > 1) and (FindWindow('Shell_SecondaryTrayWnd', nil)=0) and (Mon.WorkareaRect = Mon.BoundsRect))
  //    then
      begin
        if Assigned(Mon) and (Mon.BoundsRect.Width = R.Width) and (Mon.BoundsRect.Height = R.Height) then
          Result := True;
     // end;
      end;
    end;
  end;
end;

// detect desktop is present
// those are different on specific conditions, like slideshow, win10 special features, and maybe third party tools installed for desktop handling
function IsDesktopWindow(AHandle: HWND): Boolean;
var
  AppClassName: array[0..255] of char;
  ChildHwnd: HWND;
begin
  Result := False;
  if AHandle = GetDesktopWindow then Result := True
  else if AHandle = GetShellWindow then Result := True
  else
  begin
    GetClassName(AHandle, AppClassName, 255);
    if AppClassName = 'WorkerW' then
    begin
      // it should have a children with 'SHELLDLL_DefView' present
      ChildHwnd := FindWindowEx(AHandle, 0, 'SHELLDLL_DefView', nil);
      if ChildHwnd <> 0 then
      begin
        //if DetectFullScreenApp(AHandle) then
        Result := True;
      end;
    end;
  end;
end;

end.
