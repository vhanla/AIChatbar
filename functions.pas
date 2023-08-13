unit functions;

interface

uses ComObj, TlHelp32, SysUtils, Windows, Registry, Forms, Winapi.DwmApi, Vcl.Graphics, PsAPI;

procedure ShowDesktop;
procedure DisableTaskMgr(bTF: Boolean);
procedure HideWindows7MenuBar;
function KillTask(FileName: String): integer;

procedure DisableKeys;
procedure EnableKeys;
function IdleTime: DWord;
function LastWork: DWord;
function IsFullScreenAppRunning: Boolean;

procedure PerformAltTab;
procedure PerformCtrlAltTab;
procedure PerformF11;
procedure TaskBarSwitcher;
procedure AutomaticSize;
procedure DefaultSize;

function AppIsResponding(const app: HWND): Boolean;

// multimonito functions
function GetLeftMost: integer;
function GetRightMost: integer;
function GetBottomMost: integer;

function isAcrylicSupported:boolean;
function isWindows11: boolean;
procedure EnableBlur(Wnd: HWND; Enable: Boolean = True);
procedure EnableNCShadow(Wnd: HWND);
function TaskbarAccented:Boolean;
function GetAccentColor:TColor;
function SystemUsesLightTheme:boolean;
function BlendColors(Col1, Col2: TColor; A: Byte): TColor;
function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;
function GetRAMUsage: Int64;

function IsAutostartEnabled(const AppName: string): Boolean;
procedure SetAutostartEnabled(const AppName: string; Enable: Boolean);

implementation

const
  RegKey_Run = 'Software\Microsoft\Windows\CurrentVersion\Run';


type
  AccentPolicy = packed record
    AccentState: Integer;
    AccentFlags: Integer;
    GradientColor: Integer;
    AnimationId: Integer;
  end;

  TWinCompAttrData = packed record
    attribute: THandle;
    pData: Pointer;
    dataSize: ULONG;
  end;

var
  KeyBoardHook: HHOOK;
  AltTabItems: integer;

function SetWindowCompositionAttribute(Wnd: HWND; const AttrData: TWinCompAttrData): BOOL; stdcall;
  external user32 Name 'SetWindowCompositionAttribute';
function RtlGetVersion(var RTL_OSVERSIONINFOEXW): LONG; stdcall;
  external 'ntdll.dll' Name 'RtlGetVersion';

procedure ShowDesktop;
var
  shelll: OleVariant;
begin
  shelll := CreateOleObject('Shell.Application');

  shelll.MinimizeAll;

end;

procedure PerformAltTab;
var
  shelll: OleVariant;
begin
  // shelll:=CreateOleObject('Shell.Application');
  shelll := CreateOleObject('WScript.Shell');
  shelll.SendKeys('%+{TAB}');
  // shelll.MinimizeAll;
  // shelll.WindowSwitcher;
end;

procedure PerformCtrlAltTab;
var
  shelll: OleVariant;
begin
  // shelll:=CreateOleObject('Shell.Application');
  shelll := CreateOleObject('WScript.Shell');
  shelll.SendKeys('^(%{TAB})');
  // shelll.MinimizeAll;
  // shelll.WindowSwitcher;
end;

procedure PerformF11;
var
  shelll: OleVariant;
begin
  shelll := CreateOleObject('WScript.Shell');
  shelll.SendKeys('{F11}');
end;

procedure HideWindows7MenuBar;
begin

end;

// works with registry use with care
// http://www.delphifaq.com/faq/delphi_windows_API/f346.shtml
// usage: true to disable and false to enable
procedure DisableTaskMgr(bTF: Boolean);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey
      ('Software\Microsoft\Windows\CurrentVersion\Policies\System', True);
    if bTF = True then
    begin
      reg.WriteString('DisableTaskMgr', '1');
    end
    else if bTF = False then
    begin
      // reg.DeleteValue('DisableTaskMgr');
      reg.WriteString('DisableTaskMgr', '0');
    end;
  finally
    reg.CloseKey;
    reg.Free;
  end;
end;

function KillTask(FileName: String): integer;
var
  ContinueLoop: Boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
const
  PROCESS_TERMINATE = $0001;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile))
      = UpperCase(FileName)) or (UpperCase(FProcessEntry32.szExeFile)
      = UpperCase(FileName))) then

      Result := integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),

        FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function LowLevelKeyboardProc(nCode: integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

  TKBDLLHOOKSTRUCT = record
    vkCode: cardinal;
    scanCode: cardinal;
    flags: cardinal;
    time: cardinal;
    dwExtraInfo: cardinal;
  end;

  PKeyboardLowLevelHookStruct = ^TKeyboardLowLevelHookStruct;
  TKeyboardLowLevelHookStruct = TKBDLLHOOKSTRUCT;
const
  LLKHF_ALTDOWN = $20;
var
  hs: PKeyboardLowLevelHookStruct;
  ctrlDown: Boolean;
begin

  if nCode = HC_ACTION then
  begin

    hs := PKeyboardLowLevelHookStruct(lParam);
    ctrlDown := GetAsyncKeyState(VK_CONTROL) and $8000 <> 0;
    if (hs^.vkCode = VK_ESCAPE) and ctrlDown then
      Exit(1);
    if (hs^.vkCode = VK_TAB) and ((hs^.flags and LLKHF_ALTDOWN) <> 0) then
      Exit(1);
    if (hs^.vkCode = VK_TAB) and ((hs^.flags and LLKHF_ALTDOWN) <> 0) and ctrlDown
    then
      Exit(1);
    if (hs^.vkCode = VK_ESCAPE) and ((hs^.flags and LLKHF_ALTDOWN) <> 0) then
      Exit(1);
    if (hs^.vkCode = VK_LWIN) or (hs^.vkCode = VK_RWIN) then
      Exit(1);

  end;

  Result := CallNextHookEx(0, nCode, wParam, lParam);

end;

procedure DisableKeys;
const
  WH_KEYBOARD_LL = 13;
begin
  KeyBoardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc, 0, 0);
end;

procedure EnableKeys;
const
  WH_KEYBOARD_LL = 13;
begin
  UnhookWindowsHookEx(KeyBoardHook);
end;

// http://www.delphitips.net/2007/11/11/how-to-detect-system-idle-time/
function IdleTime: DWord;
var
  LastInput: TLastInputInfo;
begin
  LastInput.cbSize := Sizeof(TLastInputInfo);
  GetLastInputInfo(LastInput);
  Result := (GetTickCount - LastInput.dwTime) DIV 1000;
end;

function LastWork: DWord;
var
  LInput: TLastInputInfo;
  iTicksNow, iResult: DWord;
begin
  LInput.cbSize := Sizeof(TLastInputInfo);
  GetLastInputInfo(LInput);
  iTicksNow := GetTickCount;

  // The result of GetTickCount will wrap around to zero if
  // Windows is run continuously for 49.7 days.

  if LInput.dwTime <= iTicksNow then
    iResult := iTicksNow - LInput.dwTime
  else
    iResult := (high(DWord) - LInput.dwTime) + iTicksNow;

  Result := iResult;
end;

function IsFullScreenAppRunning: Boolean;
var
  rc: trect;
  hw: HWND;
begin
  hw := GetForegroundWindow;
  GetWindowRect(hw, rc);
  if (rc.Right - rc.Left = GetSystemMetrics(SM_CXFULLSCREEN)) and
    (rc.Bottom - rc.Top = GetSystemMetrics(SM_CYFULLSCREEN)) then
    Result := True
  else
    Result := False;
end;

function AltTabCount(gHandle: HWND; lowparam: pointer): Boolean stdcall;
var
  caption: array [0 .. 256] of char;
  dwStyle, dwexStyle: longint;
begin
  dwStyle := GetWindowLongPtr(gHandle, GWL_STYLE);
  dwexStyle := GetWindowLongPtr(gHandle, GWL_EXSTYLE);
  if (dwStyle and WS_VISIBLE = WS_VISIBLE) and
    (GetWindowText(gHandle, caption, Sizeof(caption) - 1) <> 0) and
    (GetParent(gHandle) = 0) and (gHandle <> application.Handle) { exclude me }
  then
  begin
    if ((dwexStyle and WS_EX_APPWINDOW = WS_EX_APPWINDOW) and
      (GetWindow(gHandle, GW_OWNER) = gHandle)) or
      ((dwexStyle and WS_EX_TOOLWINDOW = 0) and
      (GetWindow(gHandle, GW_OWNER) = 0))
    // * Escondido cuando se quiere mostrar todos las ventanas
    then
      Inc(AltTabItems);
  end;
  Result := True;
end;

// ** Set the Alt Tab Switcher Thumbnail Size **//
procedure AutomaticSize;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.CreateKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AltTab');
    if reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AltTab',
      True) then
    begin
      AltTabItems := 0;
      EnumWindows(@AltTabCount, 0);
      // Screen.Width div AltTabItems - 24
      if AltTabItems > 6 then
        AltTabItems := 6;

      reg.WriteInteger('MinThumbSizePcent', 100);
      reg.WriteInteger('MaxThumbSizePx',
        Screen.Width div (AltTabItems + 1) - 24);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;

end;

// ** Set the Alt Tab Switcher Thumbnail Size to default **//
procedure DefaultSize;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.CreateKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AltTab');
    if reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AltTab',
      False) then
    begin
      reg.DeleteValue('MinThumbSizePcent');
      reg.DeleteValue('MaxThumbSizePx');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;

end;

procedure TaskBarSwitcher;
begin
  keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), 0, 0);
  Sleep(10);
  keybd_event(VK_MENU, MapVirtualKey(VK_MENU, 0), 0, 0);
  Sleep(10);
  keybd_event(VK_TAB, MapVirtualKey(VK_TAB, 0), 0, 0);
  Sleep(10);
  keybd_event(VK_TAB, MapVirtualKey(VK_TAB, 0), KEYEVENTF_KEYUP, 0);
  Sleep(100);
  keybd_event(VK_MENU, MapVirtualKey(VK_MENU, 0), KEYEVENTF_KEYUP, 0);
  Sleep(100);
  keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), KEYEVENTF_KEYUP, 0);
  // PerformCtrlAltTab;
  Sleep(100);
end;

// http://delphiptt.blogspot.com/2009/05/how-detect-if-application-has-stopped.html
function AppIsResponding(const app: HWND): Boolean;
const
  WM_NULL = $0000;
var
  lngReturnValue: longint;
  DWResult: DWord;
begin
  lngReturnValue := SendMessageTimeout(app, WM_NULL, 0, 0, SMTO_ABORTIFHUNG and
    SMTO_BLOCK, 1000, DWResult);
  if lngReturnValue > 0 then
    Result := True
  else
    Result := False;
end;

// leftmost if multimonitor
function GetLeftMost: integer;
var
  leftmost: integer;
  I: integer;
begin
  for I := 0 to Screen.MonitorCount - 1 do
  begin
    if I = 0 then
      leftmost := Screen.Monitors[I].Left
    else if Screen.Monitors[I].Left < leftmost then
      leftmost := Screen.Monitors[I].Left;
  end;
  Result := leftmost;
end;

function GetRightMost: integer;
var
  rightmost: integer;
  I: integer;
begin
  for I := 0 to Screen.MonitorCount - 1 do
  begin
    if I = 0 then
      rightmost := Screen.Monitors[I].Left + Screen.Monitors[I].Width
    else if Screen.Monitors[I].Left + Screen.Monitors[I].Width > rightmost then
      rightmost := Screen.Monitors[I].Left + Screen.Monitors[I].Width;
  end;
  Result := rightmost;
end;

function GetBottomMost: integer;
var
  bottommost: integer;
  I: integer;
begin
  for I := 0 to Screen.MonitorCount - 1 do
  begin
    if I = 0 then
      bottommost := Screen.Monitors[I].Height
    else if Screen.Monitors[I].Height > bottommost then
      bottommost := Screen.Monitors[I].Height;
  end;
  Result := bottommost;
end;

// Check Windows 10 RS4 version which onwards supports Acrylic Glass
function isAcrylicSupported:boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows NT\CurrentVersion') then
    begin
      if Reg.ValueExists('CurrentVersion') then
        if (Reg.ReadString('CurrentVersion') = '6.3')
        and (StrToInt(Reg.ReadString('CurrentBuildNumber')) >= 17134) then
          Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

function isWindows11:Boolean;
var
  winver: RTL_OSVERSIONINFOEXW;
begin
  Result := False;
  if ((RtlGetVersion(winver) = 0) and (winver.dwMajorVersion>=10) and (winver.dwBuildNumber > 22000))  then
    Result := True;
end;

procedure EnableBlur(Wnd: HWND; Enable: Boolean = True);
const
  WCA_ACCENT_POLICY = 19;
  ACCENT_NORMAL = 0;
  ACCENT_ENABLE_GRADIENT = 1;
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2;
  ACCENT_ENABLE_BLURBEHIND = 3;
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4;
  DRAW_LEFT_BORDER = $20;
  DRAW_TOP_BORDER = $40;
  DRAW_RIGHT_BORDER = $80;
  DRAW_BOTTOM_BORDER = $100;
  DWMWCP_DEFAULT    = 0; // Let the system decide whether or not to round window corners
  DWMWCP_DONOTROUND = 1; // Never round window corners
  DWMWCP_ROUND      = 2; // Round the corners if appropriate
  DWMWCP_ROUNDSMALL = 3; // Round the corners if appropriate, with a small radius
  DWMWA_WINDOW_CORNER_PREFERENCE = 33; // [set] WINDOW_CORNER_PREFERENCE, Controls the policy that rounds top-level window corners
var
  data: TWinCompAttrData;
  accent: AccentPolicy;
begin
  if Enable then
  begin
    if isAcrylicSupported then
      accent.AccentState := ACCENT_ENABLE_ACRYLICBLURBEHIND
    else
      accent.AccentState := ACCENT_ENABLE_BLURBEHIND
  end
  else
  accent.AccentState := ACCENT_NORMAL;
  accent.AccentFlags := DRAW_LEFT_BORDER or DRAW_TOP_BORDER or DRAW_RIGHT_BORDER or DRAW_BOTTOM_BORDER;

  data.attribute := WCA_ACCENT_POLICY;
  data.dataSize := SizeOf(accent);
  data.pData := @accent;
  SetWindowCompositionAttribute(Wnd, data);

  if isWindows11  then
  begin
    var DWM_WINDOW_CORNER_PREFERENCE: Cardinal;
    DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_ROUNDSMALL;
     DwmSetWindowAttribute(Wnd, DWMWA_WINDOW_CORNER_PREFERENCE, @DWM_WINDOW_CORNER_PREFERENCE, sizeof(DWM_WINDOW_CORNER_PREFERENCE));

  end;
end;

procedure EnableNCShadow(Wnd: HWND);
const
  DWMWCP_DEFAULT    = 0; // Let the system decide whether or not to round window corners
  DWMWCP_DONOTROUND = 1; // Never round window corners
  DWMWCP_ROUND      = 2; // Round the corners if appropriate
  DWMWCP_ROUNDSMALL = 3; // Round the corners if appropriate, with a small radius
  DWMWA_WINDOW_CORNER_PREFERENCE = 33; // [set] WINDOW_CORNER_PREFERENCE, Controls the policy that rounds top-level window corners
begin

  if isWindows11  then
  begin
    var DWM_WINDOW_CORNER_PREFERENCE: Cardinal;
    DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_ROUNDSMALL;
     DwmSetWindowAttribute(Wnd, DWMWA_WINDOW_CORNER_PREFERENCE, @DWM_WINDOW_CORNER_PREFERENCE, sizeof(DWM_WINDOW_CORNER_PREFERENCE));
  end;
end;

function TaskbarAccented:Boolean;
var
  reg: TRegistry;
begin
  Result := False;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize');
    try
      if reg.ValueExists('ColorPrevalence') then
        if reg.ReadInteger('ColorPrevalence') = 1 then
        Result := True;
    except
      Result := False;
    end;
    reg.CloseKey;

  finally
    reg.Free;
  end;
end;

function GetAccentColor:TColor;
var
  col: Cardinal;
  opaque: LongBool;
  newColor: TColor;
  a,r,g,b: byte;
begin
  DwmGetColorizationColor(col, opaque);
  a := Byte(col shr 24);
  r := Byte(col shr 16);
  g := Byte(col shr 8);
  b := Byte(col);


  newcolor := RGB(
      round(r*(a/255)+255-a),
      round(g*(a/255)+255-a),
      round(b*(a/255)+255-a)
  );

  Result := newcolor;
end;


// Checks whether registry value which registers system's light mode is on
function SystemUsesLightTheme:boolean;
var
  Reg: TRegistry;
begin
  Result := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') then
    begin
      if Reg.ValueExists('SystemUsesLightTheme') then
        if (Reg.ReadInteger('SystemUsesLightTheme') = 1) then
          Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

{Credits to Roy M Klever http://rmklever.com/?p=116}
function BlendColors(Col1, Col2: TColor; A: Byte): TColor;
var
  c1,c2: LongInt;
  r,g,b,v1,v2: byte;
begin
  A := Round(2.55 * A);
  c1 := ColorToRGB(Col1);
  c2 := ColorToRGB(Col2);
  v1 := Byte(c1);
  v2 := Byte(c2);
  r := A * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 8);
  v2 := Byte(c2 shr 8);
  g := A * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 16);
  v2 := Byte(c2 shr 16);
  b := A * (v1 - v2) shr 8 + v2;
  Result := (b shl 16) + (g shl 8) + r;
end;

// Functions to create alpha channel aware brushes to paint on canvas
// from Delphi Haven https://delphihaven.wordpress.com/2010/09/06/custom-drawing-on-glass-2/
function CreatePreMultipliedRGBQuad(Color: TColor; Alpha: Byte = $FF): TRGBQuad;
  begin
    Color := ColorToRGB(Color);
    Result.rgbBlue := MulDiv(GetBValue(Color), Alpha, $FF);
    Result.rgbGreen := MulDiv(GetGValue(Color), Alpha, $FF);
    Result.rgbRed := MulDiv(GetRValue(Color), Alpha, $FF);
    Result.rgbReserved := Alpha;
  end;
function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;
  var
    Info: TBitmapInfo;
  begin
    FillChar(Info, SizeOf(Info), 0);
    with Info.bmiHeader do
    begin
      biSize := SizeOf(Info.bmiHeader);
      biWidth := 1;
      biHeight := 1;
      biPlanes := 1;
      biBitCount := 32;
      biCompression := BI_RGB;
    end;
    Info.bmiColors[0] := CreatePreMultipliedRGBQuad(Color, Alpha);
    Result := CreateDIBPatternBrushPt(@Info, 0);
  end;


  function GetRAMUsage: Int64;
  var
    pmc: PROCESS_MEMORY_COUNTERS;
  begin
    Result := 0;
    if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
      Result := pmc.WorkingSetSize;
  end;


  function IsAutostartEnabled(const AppName: string): Boolean;
  var
    Reg: TRegistry;
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Result := Reg.OpenKeyReadOnly(RegKey_Run) and Reg.ValueExists(AppName);
    finally
      Reg.Free;
    end;
  end;

  procedure SetAutostartEnabled(const AppName: string; Enable: Boolean);
  var
    Reg: TRegistry;
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Enable then
      begin
        if Reg.OpenKey(RegKey_Run, True) then
          Reg.WriteString(AppName, ParamStr(0));
      end
      else
      begin
        if Reg.OpenKey(RegKey_Run, False) then
          Reg.DeleteValue(AppName);
      end;
    finally
      Reg.Free;
    end;
  end;

end.
