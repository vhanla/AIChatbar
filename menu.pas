{
  KNOWN BUGS: Sometimes closing a site the CardPanel activecard property fails
              and might occur that switching to another site doesn't work well
              until you create (open) a new site
}
unit menu;

interface

{$I ProjectDefines.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, Menus, StdCtrls, registry,
  frmChatWebView, System.ImageList, Vcl.ImgList,
  AnyiQuack, AQPSystemTypesAnimations, uWVCoreWebView2Args,
  Vcl.Imaging.pngimage, Skia, Skia.Vcl, Generics.Collections, Winapi.ShellAPI,
  settingsHelper, JvComponentBase, JvAppHotKey, JvAppEvent, madExceptVcl {$IFDEF EXPERIMENTAL} {$I experimental.uses.inc} {$IFEND};

const
  APP_VERSION = '1.0.0';

type

  TfrmMenu = class(TForm)
    tmrMenu: TTimer;
    pm1: TPopupMenu;
    About1: TMenuItem;
    Exit1: TMenuItem;
    tmrHideMenu: TTimer;
    tmrShowMenu: TTimer;
    N2: TMenuItem;
    ImageList1: TImageList;
    imgMenu: TSkSvg;
    pmCard: TPopupMenu;
    pmCardCloseSite: TMenuItem;
    Settings1: TMenuItem;
    TrayIcon1: TTrayIcon;
    JvApplicationHotKey1: TJvApplicationHotKey;
    JvAppEvents1: TJvAppEvents;
    AlternatURL1: TMenuItem;
    MadExceptionHandler1: TMadExceptionHandler;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure tmrMenuTimer(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure tmrHideMenuTimer(Sender: TObject);
    procedure tmrShowMenuTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pmCardPopup(Sender: TObject);
    procedure pmCardCloseSiteClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure pm1Popup(Sender: TObject);
    procedure pm1Close(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvApplicationHotKey1HotKey(Sender: TObject);
    procedure JvApplicationHotKey1HotKeyRegisterFailed(Sender: TObject;
      var HotKey: TShortCut);
    procedure JvAppEvents1Activate(Sender: TObject);
    procedure pmCardClose(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AlternatURL1Click(Sender: TObject);
//    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FOnMenuArea: Boolean;
    FCurrentPopupCardId: Integer;
    FPopupMenuVisible: Boolean;
    {$IFDEF EXPERIMENTAL}
      {$I experimental.object.inc}
    {$IFEND}
    FHookWndHandle: THandle;
    FHookMsg: Integer;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure HideMenu(Sender: TObject);
    procedure RestoreRequest(var message: TMessage); message WM_USER + $1000;
    // restore after resolution change
    procedure WMDisplayChange(var message: TMessage); message WM_DISPLAYCHANGE;
  protected
    procedure WMShellHook(var Msg: TMessage);
    procedure WndMethod(var Msg: TMessage);
    function IsStarteMenuVisible: Boolean;
  public
    { Public declarations }
    FFirstTimeBrowser: Boolean;
    Settings: TSettings;
    Icons: TObjectList<TSkSvg>;
    PopupWindowRect: TRect;
    //constructor Create(AOwner: TComponent); override;
    procedure buttonClick(btnID: Cardinal);
    procedure ShowMenuAnimation(aLocation: Integer; aShow: Boolean = True);
    procedure CreateNewCard(const aArgs : TCoreWebView2NewWindowRequestedEventArgs);
    procedure CreateNewSite(Sender: TObject);
    procedure SiteContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FocusCurrentBrowser;
    procedure SetDarkMode(Enable: Boolean = True);
    procedure LoadSites;
    property OnMenuArea: Boolean read FOnMenuArea write FOnMenuArea;
  end;

var
  frmMenu: TfrmMenu;

  OriginalWorkArea: TRect;
  frmMenuON: Boolean = False;
  NewLeft, NewWidth: Integer;
  NewAlphaBlend: Byte;

implementation

{$R *.dfm}

uses
  functions,
  Splash,
  settings,
  utils,
  uBrowserCard,
  ActiveX,
  Vcl.Themes,
  GDIPAPI, gdipobj, gdiputil;

const
//https://stackoverflow.com/a/22105803/537347 Windows 8 or newer only
  IID_AppVisibility: TGUID = '{2246EA2D-CAEA-4444-A3C4-6DE827E44313}';
  CLSID_AppVisibility: TGUID = '{7E5FE3D9-985F-4908-91F9-EE19F9FD1514}';

type
  MONITOR_APP_VISIBILITY = (
    MAV_UNKNOWN = 0,
    MAV_NO_APP_VISIBLE = 1,
    MAV_APP_VISIBLE = 2
  );

// *********************************************************************//
// Interface: IAppVisibilityEvents
// Flags:     (0)
// GUID:      {6584CE6B-7D82-49C2-89C9-C6BC02BA8C38}
// *********************************************************************//
  IAppVisibilityEvents = interface(IUnknown)
    ['{6584CE6B-7D82-49C2-89C9-C6BC02BA8C38}']
    function AppVisibilityOnMonitorChanged(hMonitor: HMONITOR;
              previousMode: MONITOR_APP_VISIBILITY;
              currentMode: MONITOR_APP_VISIBILITY):HRESULT; stdcall;
    function LauncherVisibilityChange(currentVisibleState: BOOL): HRESULT; stdcall;
  end;


// *********************************************************************//
// Interface: IAppVisibility
// Flags:     (0)
// GUID:      {2246EA2D-CAEA-4444-A3C4-6DE827E44313}
// *********************************************************************//
  IAppVisibility = interface(IUnknown)
    ['{2246EA2D-CAEA-4444-A3C4-6DE827E44313}']
    function GetAppVisibilityOnMonitor(monitor: HMONITOR; out pMode: MONITOR_APP_VISIBILITY): HRESULT; stdcall;
    function IsLauncherVisible(out pfVisible: BOOL): HRESULT; stdcall;
    function Advise(pCallBack: IAppVisibilityEvents; out pdwCookie: DWORD): HRESULT; stdcall;
    function Unadvise(dwCookie: DWORD): HRESULT; stdcall;
  end;
var
  StartMenuVis: IAppVisibility;

function AccessibleChildren(paccContainer: Pointer; iChildStart: LONGINT;
                             cChildren: LONGINT; out rgvarChildren: OleVariant;
                             out pcObtained: LONGINT): HRESULT; stdcall;
                             external 'OLEACC.DLL' name 'AccessibleChildren';

function  RegisterShellHookWindow( hWnd : HWND ) : BOOL;    stdcall;
  external user32 name 'RegisterShellHookWindow';
function  DeregisterShellHookWindow( hWnd : HWND) : BOOL;  stdcall;
  external user32 name 'DeregisterShellHookWindow';



procedure TfrmMenu.RestoreRequest(var message: TMessage);
begin
  // mostramos si está oculto
  frmMenu.Show;
end;

procedure TfrmMenu.SetDarkMode(Enable: Boolean);
begin
{  if Enable then
  begin
    if TStyleManager.IsValidStyle('Windows11_Polar_Dark.vsf') then
      TStyleManager.TrySetStyle('Windows11 Polar Dark')
  end
  else
    TStyleManager.TrySetStyle('Windows');}
end;

procedure TfrmMenu.Settings1Click(Sender: TObject);
begin
  frmSetting.Show;
end;

procedure TfrmMenu.ShowMenuAnimation(aLocation: Integer; aShow: Boolean = True);
var
  TypesAniPlugin: TAQPSystemTypesAnimations;
begin
{//  frmMenuX.Width := MulDiv(64, Self.PixelsPerInch, 96);
  var wtf := MulDiv(264, Self.PixelsPerInch, 96);
  frmMenuX.Left := Screen.Width - wtf;
  frmMenuX.SetBounds(0, 0, 64, Screen.WorkAreaRect.Height);
//  frmMenuX.Top := 0;
//  frmMenuX.Height := Screen.WorkAreaRect.Height;

  if not aShow and frmMenuX.Visible then
    frmMenuX.Hide
  else
    frmMenuX.Show;

  if frmMenuX.Icons.Count = 0 then
    frmMenuX.LoadIcons(Settings);
  frmMenuX.AnimateMenu(aLocation, aShow);
  Exit;}

  TypesAniPlugin := Take(Self)
    .FinishAnimations
    .Plugin<TAQPSystemTypesAnimations>;

  // Animate the BoundsRect (position and size) of the form
  TypesAniPlugin
    .RectAnimation(Rect(NewLeft, 0, NewLeft + NewWidth, Screen.WorkAreaHeight),
      function(RefObject: TObject): TRect
      begin
        Result := TForm(RefObject).BoundsRect;
      end,
      procedure(RefObject: TObject; const NewRect: TRect)

  var
    I: Integer;
  begin
        TForm(RefObject).BoundsRect := NewRect;
        // update icons position
        for I := 0 to Icons.Count - 1 do
        begin
          if Settings.BarPosition = ABE_LEFT then
            Icons[I].Left := 54 - Self.Width + 4
          else
            Icons[I].Left := 4;
        end;

      end,
      250, 0, TAQ.Ease(etBack, emInSnake),
      procedure(Sender: TObject)
      begin
        if NewWidth < 54 then
          ShowWindow(Handle, SW_HIDE);
        // if timer for icons animations is not enabled
        {if not tmrShowMenu.Enabled then
        begin
          tmrShowMenu.Enabled := True;
          tmrHideMenu.Enabled := False;
        end
        else
        begin
          tmrShowMenu.Enabled := False;
          tmrHideMenu.Enabled := True;
          ShowWindow(Handle, SW_HIDE);
        end;}
      end
      );

  // Animate the AlphaBlendValue
  TypesAniPlugin.IntegerAnimation(NewAlphaBlend,
    function(RefObject: TObject): Integer
    begin
      Result := TForm(RefObject).AlphaBlendValue;
    end,
    procedure(RefObject: TObject; const NewValue: Integer)
    begin
      TForm(RefObject).AlphaBlendValue := Byte(NewValue);
    end,
    2000, 0, TAQ.Ease(etCircle, emInInverted));
end;

procedure TfrmMenu.SiteContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  AlternatURL1.Visible := False;
  if Sender is TSkSvg then
  begin
    //TODO needs better way for it to enable close site option
    if not TSkSvg(Sender).Svg.GrayScale then
    begin
      FCurrentPopupCardId := Settings.Sites[TSkSvg(Sender).Tag].Id;
      // show alternate URL once the broser is loaded
      if Trim(Settings.Sites[TSkSvg(Sender).Tag].AltUrl) <> '' then
        AlternatURL1.Visible := True;

    end
    else
      FCurrentPopupCardId := 0; // hard coded way to say, site not started
  end;
end;

procedure TfrmMenu.WMDisplayChange(var message: TMessage);
begin
  // Resolution changed
  Height := Screen.Height;
  // TODO: realign icons
//  imgMenu.Top := Height div 2 - 24;
//  imgShare.Top := imgMenu.Top - 64;
//  imgChatGPT.Top := imgMenu.Top - 64 * 2;
//  imgConnect.Top := imgMenu.Top + 64;
//  imgSettings.Top := imgMenu.Top + 64 * 2;
//  imgClaude.Top := imgMenu.Top + 64 * 3;
  inherited;
end;

procedure TfrmMenu.WMShellHook(var Msg: TMessage);
begin
  case Msg.WParam of
    HSHELL_WINDOWCREATED, HSHELL_WINDOWDESTROYED:
    begin
//      if IsStarteMenuVisible then
//      begin
//        ShowWindow(Handle, SW_SHOWNOACTIVATE);
//        if not OnMenuArea then
//          begin
//            OnMenuArea := True;
//            NewWidth := 54;
//            NewLeft := Screen.WorkAreaWidth - NewWidth +1;
//            NewAlphaBlend := MAXBYTE;
//            ShowMenuAnimation;
//          end;
//      end;
    end;

    HSHELL_WINDOWACTIVATED:
    begin

    end;

  end;
end;

procedure TfrmMenu.WndMethod(var Msg: TMessage);
begin
  if Msg.Msg = FHookMsg then
    WMShellHook(Msg);
end;

procedure TfrmMenu.HideMenu(Sender: TObject);
begin
  tmrHideMenu.Enabled := true;
end;

procedure TfrmMenu.AlternatURL1Click(Sender: TObject);
var
  I, J: Integer;
begin
  for I := 0 to mainBrowser.CardPanel1.CardCount - 1 do
  begin
    if mainBrowser.CardPanel1.Cards[I].Tag = FCurrentPopupCardId then
    begin
      for J := 0 to Icons.Count - 1 do
      begin
        if Settings.Sites[Icons[J].Tag].Id = FCurrentPopupCardId then
        begin
          TBrowserCard(mainBrowser.CardPanel1.Cards[I]).Navigate(Settings.Sites[Icons[J].Tag].AltUrl);
          Break;
        end;
      end;

      Break;
    end;
  end;
end;

procedure TfrmMenu.buttonClick(btnID: Cardinal);
begin

end;

//constructor TfrmMenu.Create(AOwner: TComponent);
//var
//  MyTaskbar: TAppBarData;
//begin
//  inherited;
//
//  FillChar(MyTaskbar, SizeOf(TAppBarData), 0);
//  MyTaskbar.cbSize := SizeOf(TAppBarData);
//  MyTaskbar.hWnd := Handle;
//  MyTaskbar.uCallbackMessage := WM_USER + 888;
//  MyTaskbar.uEdge := ABE_RIGHT;
//  MyTaskbar.rc := ClientRect;
//  SHAppBarMessage(ABM_NEW, MyTaskbar);
//  SHAppBarMessage(ABM_ACTIVATE, MyTaskbar);
//  SHAppBarMessage(ABM_SETPOS, MyTaskbar);
//
//  Application.ProcessMessages;
//end;

procedure TfrmMenu.CreateNewCard(
  const aArgs: TCoreWebView2NewWindowRequestedEventArgs);
begin
  if Assigned(mainBrowser) then
    mainBrowser.CreateNewCard(aArgs);
end;


procedure TfrmMenu.CreateNewSite(Sender: TObject);
var
  SiteID: Integer;
  SiteURL: string;
  SiteUA: string;
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  SiteID := Settings.Sites[TSkSvg(Sender).Tag].Id;
  SiteURL := Settings.Sites[TSkSvg(Sender).Tag].Url;
  SiteUA := Settings.Sites[TSkSvg(Sender).Tag].UA;
  // check if there isn't already a card/tab with that site opened
  for I := 0 to mainBrowser.CardPanel1.CardCount - 1 do
  begin
    if mainBrowser.CardPanel1.Cards[I].Tag = SiteID then
    begin
      Found := True;
      Break;
    end;
  end;

  if (Sender is TSkSvg) then
  begin
    if Found then
    begin
      if Assigned(mainBrowser.CardPanel1.ActiveCard) and
      (mainBrowser.CardPanel1.ActiveCard.Tag <> SiteID)
      then
      begin
        mainBrowser.CardPanel1.ActiveCardIndex := I;
        mainBrowser.Visible := True;
        SetForegroundWindow(mainBrowser.Handle);
        FocusCurrentBrowser;
      end
      else
      begin
        if mainBrowser.Visible then
          mainBrowser.Visible := False
        else
        begin
          mainBrowser.Visible := True;
          SetForegroundWindow(mainBrowser.Handle);
          FocusCurrentBrowser;
        end;
      end;
    end
    else
    begin
      if FFirstTimeBrowser then
      begin // use the predefined hard coded position mimicking the Windows Copilot location
        FFirstTimeBrowser := False; // to avoid resetting the position on new calls so user keeps change position in this session
        mainBrowser.Height := Screen.WorkAreaRect.Height;
        if Settings.BarPosition = ABE_LEFT then
          mainBrowser.Left := Screen.WorkAreaRect.Left
        else
          mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
        mainBrowser.Top := Screen.WorkAreaRect.Top;
      end;
      mainBrowser.Visible := True;
      mainBrowser.CreateNewSite(SiteID, SiteURL, SiteUA);
      TSkSvg(Sender).Svg.GrayScale := False;
    end;
  end;
end;

procedure TfrmMenu.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName := 'AIChatbarWnd';
  Params.WndParent := Application.Handle;
  Params.ExStyle := Params.ExStyle and not WS_EX_APPWINDOW;
end;

Function GetUserFromWindows: string;
Var
  UserName: string;
  UserNameLen: Dword;
Begin
  UserNameLen := 255;
  SetLength(UserName, UserNameLen);
  If GetUserName(PChar(UserName), UserNameLen) Then
    Result := Copy(UserName, 1, UserNameLen - 1)
  Else
    Result := 'Unknown';

End;

procedure TfrmMenu.FocusCurrentBrowser;
begin
  if Assigned(mainBrowser) then
  begin
    if GetForegroundWindow = mainBrowser.Handle then
    begin
      if mainBrowser.CardPanel1.CardCount > 0 then
      begin
        if Assigned(mainBrowser.CardPanel1.ActiveCard) then
          TBrowserCard(mainBrowser.CardPanel1.ActiveCard).FocusBrowser;
      end;
    end;
  end;
end;

procedure TfrmMenu.FormClick(Sender: TObject);
begin
  if Assigned(mainBrowser) then
  begin
    if mainBrowser.Visible then
      SetForegroundWindow(mainBrowser.Handle);
  end;
end;

procedure TfrmMenu.FormClose(Sender: TObject; var Action: TCloseAction);
//var
//  MyTaskbar: TAppBarData;
begin
//  FillChar(MyTaskbar, SizeOf(TAppBarData), 0);
//  MyTaskbar.cbSize := SizeOf(TAppBarData);
//  MyTaskbar.hWnd := Handle;
//  SHAppBarMessage(ABM_REMOVE, MyTaskbar);
end;

procedure TfrmMenu.FormCreate(Sender: TObject);
const
  SPI_SETDISPLAYDPI = $009F;
var
  ReservedScreenArea: TRect;
begin
  FFirstTimeBrowser := True; // to use the preset browser position for the first call
  PopupWindowRect.Width := 0;
//  SystemParametersInfo(SPI_SETDISPLAYDPI, 1, nil, 1);
  OnMenuArea := False;
  // SetPriorityClass(GetCurrentProcess, $4000);

//  Application.OnDeactivate := HideMenu;

  Color := clBlack; // $151515;//clBlack;
  Width := 1;
  Height := Screen.Height - 164;
  Top := 64;
  Left := GetRightMost - 1;// + 10; // Screen.Width+10;//-48;
  BorderStyle := bsNone;

  Icons := TObjectList<TSKSvg>.Create;
  // menu
  imgMenu.Left := 40;
  imgMenu.Top := Height div 2 - 24;
  imgMenu.Cursor := crHandPoint;



  {$IFDEF EXPERIMENTAL}
    {$I experimental.create.menubar.inc}
  {$ELSE}
    EnableBlur(Handle, True);
  {$IFEND}

  SetWindowLong(frmMenu.Handle, GWL_EXSTYLE, GetWindowLong(frmMenu.Handle,
    GWL_EXSTYLE) Or WS_EX_LAYERED or WS_EX_TOOLWINDOW);
  SetLayeredWindowAttributes(frmMenu.Handle, 0, 0, LWA_ALPHA);

  SetWindowPos(frmMenu.Handle, HWND_TOPMOST, Left, Top, Width, Height,
    SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);

  // save current workarea to restore later
  SystemParametersInfo(SPI_GETWORKAREA, 0, @OriginalWorkArea, 0);
  // now reserver screen area to work with
  ReservedScreenArea := Rect(0, 0, 60, Screen.Height);
//  SystemParametersInfo(SPI_SETWORKAREA, 0,@ReservedScreenArea, SPIF_SENDCHANGE);

  Settings := TSettings.Create(ExtractFilePath(ParamStr(0))+'settings.db');

  Settings.ReadSites;
  Settings.LoadSettings;

  LoadSites;

  // Register ourselves as shell message instance receiver
  FHookWndHandle := AllocateHWnd(WndMethod);
  FHookMsg := RegisterWindowMessage('SHELLHOOK'#0);
  RegisterShellHookWindow(FHookWndHandle);

  JvApplicationHotKey1.HotKey := TextToShortCut(Settings.GlobalHotkey);
  JvApplicationHotKey1.WindowsKey := Settings.RequireWinKey;
  JvApplicationHotKey1.Active := True;
end;

procedure TfrmMenu.FormDestroy(Sender: TObject);
begin
  DeregisterShellHookWindow(FHookWndHandle);
  DeallocateHWnd(FHookWndHandle);

  {$IFDEF EXPERIMENTAL}
    {$I experimental.destroy.inc}
  {$IFEND}

  Icons.Free;

  Settings.Free;
  // restore reserved screenarea
  SystemParametersInfo(SPI_SETWORKAREA, 0, @OriginalWorkArea, 0);

end;

procedure TfrmMenu.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // TODO: as of now we assume right click is the context menu, needs fix for left hand users mouse settings
  if Button = TMouseButton.mbRight  then
  begin
    PopupMenu.Popup(Left + X, Top + Y);
  end;
end;

//procedure TfrmMenu.FormPaint(Sender: TObject);
//begin
//  if TaskbarAccented then
//  begin
//    Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BlendColors(GetAccentColor, clBlack,50), 200);
//  end
//  else
//  begin
//    if SystemUsesLightTheme then
//      Canvas.Brush.Handle := CreateSolidBrushWithAlpha($dddddd, 200)    else
//      Canvas.Brush.Handle := CreateSolidBrushWithAlpha($222222, 200);
//  end;
//  Canvas.FillRect(Rect(0,0,Width,Height));
//end;

procedure TfrmMenu.tmrMenuTimer(Sender: TObject);
var
  pos: TPoint;
  TypesAniPlugin: TAQPSystemTypesAnimations;
begin
  if Settings.DisableOnFullScreenDirectX and DetectFullScreen3D then Exit;
  if Settings.DisableOnFullScreen and DetectFullScreenApp(GetForegroundWindow) then Exit;
  if FPopupMenuVisible then Exit;

  try
    pos := Mouse.CursorPos;
  except
  end;

  // verificamos el borde
  if (GetAsyncKeyState(VK_LBUTTON) = 0) and (GetAsyncKeyState(VK_RBUTTON) = 0) then
  begin
    case Settings.BarPosition of
      ABE_LEFT:
      begin
        if (pos.X <= GetLeftMost + 1) then
        begin
          ShowWindow(Handle, SW_SHOWNOACTIVATE);
          if not OnMenuArea then
          begin
            OnMenuArea := True;
            NewWidth := 54;
            NewLeft := GetLeftMost - 1;
            NewAlphaBlend := MAXBYTE;
            ShowMenuAnimation(ABE_LEFT);
          end;
        end
        else if (pos.X > frmMenu.Left + frmMenu.Width) and (tmrHideMenu.Enabled = False) then
        begin
          if OnMenuArea then
          begin
            OnMenuArea := False;
            NewWidth := 1;
            NewLeft := GetLeftMost;
            NewAlphaBlend := 0;
            ShowMenuAnimation(ABE_LEFT, False);
          end;
        end;

      end;
      ABE_TOP:
      begin

      end;
      ABE_RIGHT:
      begin
        if (pos.X >= GetRightMost - 1) then
        begin
          ShowWindow(Handle, SW_SHOWNOACTIVATE);
          if not OnMenuArea then
          begin
            OnMenuArea := True;
            NewWidth := 54;
            NewLeft := Screen.WorkAreaWidth - NewWidth +1;
            NewAlphaBlend := MAXBYTE;
            ShowMenuAnimation(ABE_RIGHT);
          end;
        end
        else if (pos.X < Left) and (tmrHideMenu.Enabled = False) then
//        else if (pos.X < GetRightMost - frmMenuX.Width) then //and (tmrHideMenu.Enabled = False) then
        begin
          if OnMenuArea then
          begin
            OnMenuArea := False;
            NewWidth := 1;
            NewLeft := Screen.WorkAreaWidth - NewWidth;
            NewAlphaBlend := 0;
            ShowMenuAnimation(ABE_RIGHT, False);
          end;
        end;

      end;
      ABE_BOTTOM:
      begin

      end;
    end;
  end;

end;

procedure TfrmMenu.imgMenuClick(Sender: TObject);
var
  winrect: TRect;
begin
  if not IsStarteMenuVisible then
    SendMessage(Handle, WM_SYSCOMMAND, SC_TASKLIST, 0);
end;

procedure TfrmMenu.Exit1Click(Sender: TObject);
begin
  close
end;

procedure TfrmMenu.About1Click(Sender: TObject);
begin
  // MessageDlg('Win8Menu v 1.3'#13'Written by vhanla'#13'http://apps.codigobit.info',mtInformation,[mbOK],0);
  with TFormSplash.Create(Application) do
    execute;

end;

procedure TfrmMenu.tmrHideMenuTimer(Sender: TObject);
begin
  if not tmrShowMenu.Enabled then
  begin
    if Left < GetRightMost - 2 then
      Left := Left + 10 // Screen.Width-2 then Left:=Left+10
    else
    begin
      tmrHideMenu.Enabled := False;
      // modificamos las posiciones de los iconos
      imgMenu.Left := 40;
//      imgShare.Left := 50;
//      imgChatGPT.Left := 60;
//      imgConnect.Left := 50;
//      imgSettings.Left := 60;
//      imgClaude.Left := 60;
      Left := GetRightMost - 2; // Screen.Width-2;
      frmMenuON := False;
    end;
  end;
end;

procedure TfrmMenu.tmrShowMenuTimer(Sender: TObject);
begin
  // anima los iconos
  if imgMenu.Left > 0 then
    imgMenu.Left := imgMenu.Left - 10
  else
    imgMenu.Left := 0;

//  if imgShare.Left > 0 then
//    imgShare.Left := imgShare.Left - 10
//  else
//    imgShare.Left := 0;
//
//  if imgChatGPT.Left > 0 then
//    imgChatGPT.Left := imgChatGPT.Left - 10
//  else
//    imgChatGPT.Left := 0;
//
//  if imgConnect.Left > 0 then
//    imgConnect.Left := imgConnect.Left - 10
//  else
//    imgConnect.Left := 0;
//
//  if imgSettings.Left > 0 then
//    imgSettings.Left := imgSettings.Left - 10
//  else
//    imgSettings.Left := 0;
//
//  if imgClaude.Left > 0 then
//    imgClaude.Left := imgClaude.Left - 10
//  else
//    imgClaude.Left := 0;
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

function TfrmMenu.IsStarteMenuVisible: Boolean;
var
  startMenuOn: BOOL;
begin
  startMenuOn := False;

  var res := CoCreateInstance(CLSID_AppVisibility, nil, CLSCTX_ALL, IID_AppVisibility, StartMenuVis);

  if Succeeded(res) then
  begin
    if Succeeded(StartMenuVis.IsLauncherVisible(startMenuOn)) then
    begin

    end;
  end;

  Result := startMenuOn;
end;



procedure TfrmMenu.JvAppEvents1Activate(Sender: TObject);
begin
  FocusCurrentBrowser;
end;

procedure TfrmMenu.JvApplicationHotKey1HotKey(Sender: TObject);
begin
  if Assigned(mainBrowser) then
  begin
    if mainBrowser.Visible then
    begin
      if GetForegroundWindow <> mainBrowser.Handle then
      begin
        SetForegroundWindow(mainBrowser.Handle);
        FocusCurrentBrowser;
      end
      else
        mainBrowser.Hide;
    end
    else
    begin
      mainBrowser.Show;
      FocusCurrentBrowser;
    end;
  end;
end;

procedure TfrmMenu.JvApplicationHotKey1HotKeyRegisterFailed(Sender: TObject;
  var HotKey: TShortCut);
var
  win: string;
begin
  win := '';
  if Settings.RequireWinKey then win := 'Win+';

  ShowMessage(Format('There was an error assigning this hotkey: %s%s '#13#10'It might be in use by other program or reserved by the OS.', [win, ShortCutToText(HotKey)]));
end;

procedure TfrmMenu.LoadSites;
begin
// create each icon
  var sitesCount := frmMenu.Settings.Sites.Count;
  var sPos := Height div 2 - sitesCount div 2 * 64;

  Icons.Clear;
  for var I := 0 to sitesCount - 1 do
  begin

    var vicon := TSkSvg.Create(Self);
    vicon.Parent := Self;
    vicon.Svg.Source := Settings.Sites[I].Icon;
    vicon.Svg.GrayScale := True;
    vicon.Tag := I;
    vicon.Left := 4;
    vicon.Top := sPos + 64*I;
    vicon.Width := 48;
    vicon.Height := 48;
    vicon.Cursor := crHandPoint;
    vicon.Hint := Settings.Sites[I].Name;
    vicon.ShowHint := True;
    vicon.OnClick := CreateNewSite;
    vicon.OnContextPopup := SiteContextPopup;
    vicon.PopupMenu := pmCard;
    Icons.Add(vicon);
  end;
end;

procedure TfrmMenu.pm1Close(Sender: TObject);
begin
  FPopupMenuVisible := False;
end;

procedure TfrmMenu.pm1Popup(Sender: TObject);
begin
  FPopupMenuVisible := True;
end;

procedure TfrmMenu.pmCardClose(Sender: TObject);
begin
  FPopupMenuVisible := False;
end;

procedure TfrmMenu.pmCardCloseSiteClick(Sender: TObject);
var
  TempCard: tbrowsercard;
  I, J: Integer;
begin
  for I := 0 to mainBrowser.CardPanel1.CardCount - 1 do
  begin
    if mainBrowser.CardPanel1.Cards[I].Tag = FCurrentPopupCardId then
    begin
      for J := 0 to Icons.Count - 1 do
      begin
        if Settings.Sites[Icons[J].Tag].Id = FCurrentPopupCardId then
        begin
          Icons[J].Svg.GrayScale := True;
        end;
      end;
      TempCard := TBrowserCard(mainBrowser.CardPanel1.Cards[I]);
      TempCard.Free;
      if mainBrowser.CardPanel1.CardCount = 0 then
        mainBrowser.Visible := False;
      Break;
    end;
  end;

{  if FCurrentPopupCardId = mainBrowser.ChatGPTID then
  begin
     TempCard := TBrowserCard(mainBrowser.CardPanel1.Cards[pred(mainBrowser.ChatGPTID)]);
     TempCard.Free;
     mainBrowser.ChatGPTID := 0;
  end
  else if FCurrentPopupCardId = mainBrowser.BingID then
  begin
     TempCard := TBrowserCard(mainBrowser.CardPanel1.Cards[pred(mainBrowser.BingID)]);
     TempCard.Free;
     mainBrowser.BingID := 0;
  end
  else if FCurrentPopupCardId = mainBrowser.BardID then
  begin
     TempCard := TBrowserCard(mainBrowser.CardPanel1.Cards[pred(mainBrowser.BardID)]);
     TempCard.Free;
     mainBrowser.BardID := 0;
  end
  else if FCurrentPopupCardId = mainBrowser.YouID then
  begin
     TempCard := TBrowserCard(mainBrowser.CardPanel1.Cards[pred(mainBrowser.YouID)]);
     TempCard.Free;
     mainBrowser.YouID := 0;
  end}
end;

procedure TfrmMenu.pmCardPopup(Sender: TObject);
begin
  FPopupMenuVisible := True;
  if FCurrentPopupCardId > 0 then
    pmCardCloseSite.Enabled := True
  else
    pmCardCloseSite.Enabled := False;
end;

end.
