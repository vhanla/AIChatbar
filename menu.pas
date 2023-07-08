unit menu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, Menus, StdCtrls, registry, scStyledForm,
  frmChatWebView, System.ImageList, Vcl.ImgList,
  AnyiQuack, AQPSystemTypesAnimations,
  Vcl.Imaging.pngimage, Skia, Skia.Vcl, Generics.Collections;

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
    imgSearch: TSkSvg;
    imgSettings: TSkSvg;
    procedure FormCreate(Sender: TObject);
    procedure tmrMenuTimer(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure imgSearchClick(Sender: TObject);
    procedure tmrHideMenuTimer(Sender: TObject);
    procedure tmrShowMenuTimer(Sender: TObject);
    procedure imgConnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSettingsClick(Sender: TObject);
    procedure imgShareClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FOnMenuArea: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure HideMenu(Sender: TObject);
    procedure RestoreRequest(var message: TMessage); message WM_USER + $1000;
    // restore after resolution change
    procedure WMDisplayChange(var message: TMessage); message WM_DISPLAYCHANGE;
  public
    { Public declarations }
    procedure buttonClick(btnID: Cardinal);
    procedure ShowMenuAnimation;
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
  CursorFix,
  Splash,
  settings,
  utils,
  GDIPAPI, gdipobj, gdiputil;


procedure TfrmMenu.RestoreRequest(var message: TMessage);
begin
  // mostramos si está oculto
  frmMenu.Show;
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
  imgSearch.Top := imgMenu.Top - 64 * 2;
  imgConnect.Top := imgMenu.Top + 64;
  imgSettings.Top := imgMenu.Top + 64 * 2;
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

  imgSearch.Left := 60;
  imgSearch.Top := imgMenu.Top - 64 * 2;
  imgSearch.Cursor := crHandPoint;

  imgConnect.Left := 50;
  imgConnect.Top := imgMenu.Top + 64;
  imgConnect.Cursor := crHandPoint;

  imgSettings.Left := 60;
  imgSettings.Top := imgMenu.Top + 64 * 2;
  imgSettings.Cursor := crHandPoint;

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

  EnableBlur(Handle, True);
end;

procedure TfrmMenu.FormDestroy(Sender: TObject);
begin
  // restore reserved screenarea
  SystemParametersInfo(SPI_SETWORKAREA, 0, @OriginalWorkArea, 0);
end;

procedure TfrmMenu.FormPaint(Sender: TObject);
begin
  if TaskbarAccented then
  begin
    Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BlendColors(GetAccentColor, clBlack,50), 200);
  end
  else
  begin
    if SystemUsesLightTheme then
      Canvas.Brush.Handle := CreateSolidBrushWithAlpha($dddddd, 200)    else
      Canvas.Brush.Handle := CreateSolidBrushWithAlpha($222222, 200);
  end;
  Canvas.FillRect(Rect(0,0,Width,Height));
end;

procedure TfrmMenu.tmrMenuTimer(Sender: TObject);
var
  pos: TPoint;
  TypesAniPlugin: TAQPSystemTypesAnimations;
begin
  if DetectFullScreen3D then Exit;
  if DetectFullScreenApp(GetForegroundWindow) then Exit;
  

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

procedure TfrmMenu.imgSearchClick(Sender: TObject);
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
      imgSearch.Left := 60;
      imgConnect.Left := 50;
      imgSettings.Left := 60;
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

  if imgSearch.Left > 0 then
    imgSearch.Left := imgSearch.Left - 10
  else
    imgSearch.Left := 0;

  if imgConnect.Left > 0 then
    imgConnect.Left := imgConnect.Left - 10
  else
    imgConnect.Left := 0;

  if imgSettings.Left > 0 then
    imgSettings.Left := imgSettings.Left - 10
  else
    imgSettings.Left := 0;
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

end.
