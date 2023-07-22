unit menu;

interface

{$I ProjectDefines.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, Menus, StdCtrls, registry,
  frmChatWebView, System.ImageList, Vcl.ImgList,
  AnyiQuack, AQPSystemTypesAnimations, uWVCoreWebView2Args,
  Vcl.Imaging.pngimage, Skia, Skia.Vcl, Generics.Collections,
  settingsHelper {$IFDEF EXPERIMENTAL} {$I experimental.uses.inc} {$IFEND};

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
    imgShare: TSkSvg;
    imgMenu: TSkSvg;
    imgConnect: TSkSvg;
    imgChatGPT: TSkSvg;
    imgSettings: TSkSvg;
    pmCard: TPopupMenu;
    pmCardClose: TMenuItem;
    Settings1: TMenuItem;
    imgClaude: TSkSvg;
    TrayIcon1: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure tmrMenuTimer(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure imgChatGPTClick(Sender: TObject);
    procedure tmrHideMenuTimer(Sender: TObject);
    procedure tmrShowMenuTimer(Sender: TObject);
    procedure imgConnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSettingsClick(Sender: TObject);
    procedure imgShareClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pmCardPopup(Sender: TObject);
    procedure pmCardCloseClick(Sender: TObject);
    procedure imgChatGPTContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure imgShareContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure imgConnectContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure imgSettingsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Settings1Click(Sender: TObject);
    procedure imgClaudeClick(Sender: TObject);
    procedure imgClaudeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    procedure pm1Popup(Sender: TObject);
    procedure pm1Close(Sender: TObject);
//    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FOnMenuArea: Boolean;
    FCurrentPopupCardId: Integer;
    FPopupMenuVisible: Boolean;
    {$IFDEF EXPERIMENTAL}
      {$I experimental.object.inc}
    {$IFEND}
    procedure CreateParams(var Params: TCreateParams); override;
    procedure HideMenu(Sender: TObject);
    procedure RestoreRequest(var message: TMessage); message WM_USER + $1000;
    // restore after resolution change
    procedure WMDisplayChange(var message: TMessage); message WM_DISPLAYCHANGE;
  public
    { Public declarations }
    Settings: TSettings;
    procedure buttonClick(btnID: Cardinal);
    procedure ShowMenuAnimation;
    procedure CreateNewCard(const aArgs : TCoreWebView2NewWindowRequestedEventArgs);
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
  GDIPAPI, gdipobj, gdiputil;


procedure TfrmMenu.RestoreRequest(var message: TMessage);
begin
  // mostramos si está oculto
  frmMenu.Show;
end;

procedure TfrmMenu.Settings1Click(Sender: TObject);
begin
  frmSetting.Show;
end;

procedure TfrmMenu.ShowMenuAnimation;
var
  TypesAniPlugin: TAQPSystemTypesAnimations;
begin
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
      begin
        TForm(RefObject).BoundsRect := NewRect;
      end,
      250, 0, TAQ.Ease(etBack, emInSnake),
      procedure(Sender: TObject)
      begin
        // if timer for icons animations is not enabled
        if not tmrShowMenu.Enabled then
        begin
          tmrShowMenu.Enabled := True;
          tmrHideMenu.Enabled := False;
        end
        else
        begin
          tmrShowMenu.Enabled := False;
          tmrHideMenu.Enabled := True;
          ShowWindow(Handle, SW_HIDE);
        end;
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

procedure TfrmMenu.WMDisplayChange(var message: TMessage);
begin
  // Resolution changed
  Height := Screen.Height;
  imgMenu.Top := Height div 2 - 24;
  imgShare.Top := imgMenu.Top - 64;
  imgChatGPT.Top := imgMenu.Top - 64 * 2;
  imgConnect.Top := imgMenu.Top + 64;
  imgSettings.Top := imgMenu.Top + 64 * 2;
  imgClaude.Top := imgMenu.Top + 64 * 3;
  inherited;
end;

procedure TfrmMenu.HideMenu(Sender: TObject);
begin
  tmrHideMenu.Enabled := true;
end;

procedure TfrmMenu.buttonClick(btnID: Cardinal);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.ChatGPTID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(btnID)
    then
      mainBrowser.CardPanel1.ActiveCardIndex := pred(btnID)
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateGPTChat;
  end;
end;

procedure TfrmMenu.CreateNewCard(
  const aArgs: TCoreWebView2NewWindowRequestedEventArgs);
begin
  if Assigned(mainBrowser) then
    mainBrowser.CreateNewCard(aArgs);
end;

procedure TfrmMenu.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName := 'Win8MenuCLS';
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

procedure TfrmMenu.FormClick(Sender: TObject);
begin
  if frmChatWebView.mainBrowser.Visible then
    SetForegroundWindow(mainBrowser.Handle);
end;

procedure TfrmMenu.FormCreate(Sender: TObject);
const
  SPI_SETDISPLAYDPI = $009F;
var
  ReservedScreenArea: TRect;
begin
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

  // menu
  imgMenu.Left := 40;
  imgMenu.Top := Height div 2 - 24;
  imgMenu.Cursor := crHandPoint;

  imgShare.Left := 50;
  imgShare.Top := imgMenu.Top - 64;
  imgShare.Cursor := crHandPoint;

  imgChatGPT.Left := 60;
  imgChatGPT.Top := imgMenu.Top - 64 * 2;
  imgChatGPT.Cursor := crHandPoint;

  imgConnect.Left := 50;
  imgConnect.Top := imgMenu.Top + 64;
  imgConnect.Cursor := crHandPoint;

  imgSettings.Left := 60;
  imgSettings.Top := imgMenu.Top + 64 * 2;
  imgSettings.Cursor := crHandPoint;

  imgClaude.Left := 60;
  imgClaude.Top := imgMenu.Top + 64 * 3;
  imgClaude.Cursor := crHandPoint;

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
  ReservedScreenArea := Rect(10, 0, Screen.Width - 10, Screen.Height);
  // SystemParametersInfo(SPI_SETWORKAREA,0,@ReservedScreenArea,0);

  Settings := TSettings.Create(ExtractFilePath(ParamStr(0))+'settings.db');
end;

procedure TfrmMenu.FormDestroy(Sender: TObject);
begin
  {$IFDEF EXPERIMENTAL}
    {$I experimental.destroy.inc}
  {$IFEND}
  Settings.Free;
  // restore reserved screenarea
  SystemParametersInfo(SPI_SETWORKAREA, 0, @OriginalWorkArea, 0);
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
  if DetectFullScreen3D then Exit;
  if DetectFullScreenApp(GetForegroundWindow) then Exit;
  if FPopupMenuVisible then Exit;

  try
    pos := Mouse.CursorPos;
  except
  end;

  // verificamos el borde
  if (pos.X >= GetRightMost - 1 - frmSetting.seMenuHotArea.Value)
  then
  begin
    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    // si no se está presionando el botón izquierdo del mouse
    if (GetAsyncKeyState(VK_LBUTTON) = 0) then
    begin
      if not OnMenuArea then
      begin
        OnMenuArea := True;
        NewWidth := 54;
        NewLeft := Screen.WorkAreaWidth - NewWidth +1;
        NewAlphaBlend := MAXBYTE;
        ShowMenuAnimation;
      end;
    end;
  end
  else if (pos.X < Left) and (tmrHideMenu.Enabled = False) then
  begin
    if OnMenuArea then
    begin
      OnMenuArea := False;
      NewWidth := 1;
      NewLeft := Screen.WorkAreaWidth - NewWidth;
      NewAlphaBlend := 0;
      ShowMenuAnimation;
    end;
  end;

end;

procedure TfrmMenu.imgMenuClick(Sender: TObject);
var
  winrect: TRect;
begin
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

procedure TfrmMenu.imgChatGPTClick(Sender: TObject);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.ChatGPTID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(mainBrowser.ChatGPTID)
    then
    begin
      mainBrowser.CardPanel1.ActiveCardIndex := pred(mainBrowser.ChatGPTID);
      mainBrowser.Visible := True;
    end
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateGPTChat;
  end;
end;

procedure TfrmMenu.imgChatGPTContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  FCurrentPopupCardId := mainBrowser.ChatGPTID;
end;

procedure TfrmMenu.imgClaudeClick(Sender: TObject);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.ClaudeID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(mainBrowser.ClaudeID)
    then
    begin
      mainBrowser.CardPanel1.ActiveCardIndex := pred(mainBrowser.ClaudeID);
      mainBrowser.Visible := True;
    end
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateClaudeChat;
  end;
end;

procedure TfrmMenu.imgClaudeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  FCurrentPopupCardId := mainBrowser.ClaudeID;
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
      imgShare.Left := 50;
      imgChatGPT.Left := 60;
      imgConnect.Left := 50;
      imgSettings.Left := 60;
      imgClaude.Left := 60;
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

  if imgShare.Left > 0 then
    imgShare.Left := imgShare.Left - 10
  else
    imgShare.Left := 0;

  if imgChatGPT.Left > 0 then
    imgChatGPT.Left := imgChatGPT.Left - 10
  else
    imgChatGPT.Left := 0;

  if imgConnect.Left > 0 then
    imgConnect.Left := imgConnect.Left - 10
  else
    imgConnect.Left := 0;

  if imgSettings.Left > 0 then
    imgSettings.Left := imgSettings.Left - 10
  else
    imgSettings.Left := 0;

  if imgClaude.Left > 0 then
    imgClaude.Left := imgClaude.Left - 10
  else
    imgClaude.Left := 0;
end;

procedure TfrmMenu.imgConnectClick(Sender: TObject);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.BardID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(mainBrowser.BardID)
    then
    begin
      mainBrowser.CardPanel1.ActiveCardIndex := pred(mainBrowser.BardID);
      mainBrowser.Visible := True;
    end
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateBardChat;
  end;
end;

procedure TfrmMenu.imgConnectContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  FCurrentPopupCardId := mainBrowser.BardID;
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TfrmMenu.imgSettingsClick(Sender: TObject);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.YouID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(mainBrowser.YouID)
    then
    begin
      mainBrowser.CardPanel1.ActiveCardIndex := pred(mainBrowser.YouID);
      mainBrowser.Visible := True;
    end
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateYouChat;
  end;
end;

procedure TfrmMenu.imgSettingsContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  FCurrentPopupCardId := mainBrowser.YouID;
end;

procedure TfrmMenu.imgShareClick(Sender: TObject);
begin
  mainBrowser.Height := Screen.WorkAreaRect.Height;
  mainBrowser.Left := Screen.WorkAreaRect.Width - mainBrowser.Width;
  mainBrowser.Top := Screen.WorkAreaRect.Top;
  if mainBrowser.BingID > 0 then
  begin
    if mainBrowser.CardPanel1.ActiveCardIndex <> pred(mainBrowser.BingID)
    then
    begin
      mainBrowser.CardPanel1.ActiveCardIndex := pred(mainBrowser.BingID);
      mainBrowser.Visible := True;
    end
    else
      mainBrowser.Visible := not mainBrowser.Visible;
  end
  else
  begin
    mainBrowser.Visible := True;
    mainBrowser.CreateBingChat;
  end;
end;

procedure TfrmMenu.imgShareContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  FCurrentPopupCardId := mainBrowser.BingID;
end;

procedure TfrmMenu.pm1Close(Sender: TObject);
begin
  FPopupMenuVisible := False;
end;

procedure TfrmMenu.pm1Popup(Sender: TObject);
begin
  FPopupMenuVisible := True;
end;

procedure TfrmMenu.pmCardCloseClick(Sender: TObject);
var
  TempCard: tbrowsercard;
  I: Integer;
begin
  for I := 0 to mainBrowser.CardPanel1.CardCount - 1 do
  begin
    if mainBrowser.CardPanel1.Cards[I].Tag = FCurrentPopupCardId then
    begin

    end;
  end;

  if FCurrentPopupCardId = mainBrowser.ChatGPTID then
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
  end
end;

procedure TfrmMenu.pmCardPopup(Sender: TObject);
begin
  if FCurrentPopupCardId > 0 then
    pmCardClose.Enabled := True
  else
    pmCardClose.Enabled := False;
end;

end.
