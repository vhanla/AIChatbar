unit frmChatWebView;

interface

{$I ProjectDefines.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  uWVLoader, uWVCoreWebView2Args, JvComponentBase, JvAppEvent {$IFDEF EXPERIMENTAL} {$I experimental.uses.inc} {$IFEND};

const
  WV_INITIALIZED = WM_APP + $100;
  DEFAULT_TAB_CAPTION = 'New tab';

type
  TmainBrowser = class(TForm)
    CardPanel1: TCardPanel;
    Panel1: TPanel;
    Timer1: TTimer;
    tmrRamUsage: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure tmrRamUsageTimer(Sender: TObject);
  private
    { Private declarations }
    FBingID: Cardinal;
    FBardID: Cardinal;
    FChatGPTID: Cardinal;
    FYouID: Cardinal;
    FClaudeID: Cardinal;
    {$IFDEF EXPERIMENTAL}
      {$I experimental.object.inc}
    {$IFEND}
  protected
    FLastCardID       : cardinal;

    function  GetNextCardID : cardinal;
//    procedure EnableButtonPnl;

    property  NextCardID       : cardinal   read GetNextCardID;

  public
    { Public declarations }
    procedure WVInitializedMsg(var aMessage : TMessage); message WV_INITIALIZED;
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;

    procedure CreateNewCard(const aArgs : TCoreWebView2NewWindowRequestedEventArgs);
    function CreateNewSite(const Id: Integer; const url, ua: string): Integer;

  end;

var
  mainBrowser: TmainBrowser;

implementation

{$R *.dfm}

uses
  uBrowserCard, functions, menu;

{ TForm1 }



procedure TmainBrowser.CreateNewCard(
  const aArgs: TCoreWebView2NewWindowRequestedEventArgs);
var
  TempNewCard : TBrowserCard;
begin
  TempNewCard := TBrowserCard.Create(self, NextCardID, DEFAULT_TAB_CAPTION);
//  TempNewCard.CardPanel := CardPanel1;

  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);

  TempNewCard.CreateBrowser(aArgs);
end;

function TmainBrowser.CreateNewSite(const Id: Integer; const url, ua: string): Integer;
var
  TempNewCard : TBrowserCard;
  CardID: Cardinal;
begin
  Result := -1;

  CardID := Id;
  TempNewCard := TBrowserCard.Create(self, CardID, DEFAULT_TAB_CAPTION);
  TempNewCard.Parent := CardPanel1;
  TempNewCard.Tag := CardID;
//  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);
//  FClaudeID := CardPanel1.CardCount;
  Result := CardID;
  TempNewCard.CreateBrowser(url, ua);
end;



procedure TmainBrowser.FormCreate(Sender: TObject);
begin
  {$IFDEF EXPERIMENTAL}
    {$I experimental.create.inc}
  {$ELSE}
    EnableBlur(Handle);
  {$IFEND}
end;

procedure TmainBrowser.FormDestroy(Sender: TObject);
begin
  {$IFDEF EXPERIMENTAL}
    {$I experimental.destroy.inc}
  {$IFEND}
end;

procedure TmainBrowser.FormPaint(Sender: TObject);
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

procedure TmainBrowser.FormShow(Sender: TObject);
begin
  if GlobalWebView2Loader.InitializationError then
    showmessage(GlobalWebView2Loader.ErrorMessage)
  else
    if GlobalWebView2Loader.Initialized then
    begin
//      EnableButtonPnl;
    end;
end;

function TmainBrowser.GetNextCardID: cardinal;
begin
  if FLastCardID < 0 then
    FLastCardID := 0;

  Inc(FLastCardID);
  Result := FLastCardID;
end;

procedure TmainBrowser.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TmainBrowser.Timer1Timer(Sender: TObject);
var
  pos: TPoint;
begin
  try
    pos := Mouse.CursorPos;
  except
  end;

  if (pos.X > Left) and (pos.X < Left+Width)
  and (pos.Y > Top) and (pos.Y < Top+Panel1.Height)
  then
  begin
    Panel1.Visible := True;
//    CardPanel1.Margins.Top := 0;
  end
  else
  begin
    Panel1.Visible := False;
//    CardPanel1.Margins.Top := Panel1.Height;
  end;

end;

procedure TmainBrowser.tmrRamUsageTimer(Sender: TObject);
const
  B = 1;
  KB = 1024 * B;
  MB = 1024 * KB;
  GB = 1024 * MB;
var
  Bytes: Int64;
begin
  Bytes := GetRAMUsage;

  if Bytes > GB then
    Panel1.Caption := FormatFloat('Memory Used: #.## GB', Bytes / GB)
  else if Bytes > MB then
    Panel1.Caption := FormatFloat('Memory Used: #.## MB', Bytes / MB)
  else if Bytes > KB then
    Panel1.Caption := FormatFloat('Memory Used: #.## KB', Bytes / KB)
  else
    Panel1.Caption := FormatFloat('Memory Used: #.## bytes', Bytes);
end;

procedure TmainBrowser.WMMove(var aMessage: TWMMove);
var
  i : integer;
begin
  inherited;

  i := 0;
  while (i < CardPanel1.CardCount) do
    begin
      TBrowserCard(CardPanel1.Cards[i]).NotifyParentWindowPositionChanged;
//      TBrowserTab(BrowserPageCtrl.Pages[i]).NotifyParentWindowPositionChanged;
      inc(i);
    end;
end;

procedure TmainBrowser.WMMoving(var aMessage: TMessage);
var
  i : integer;
begin
  inherited;

  i := 0;
  while (i < CardPanel1.CardCount) do
    begin
      TBrowserCard(CardPanel1.Cards[i]).NotifyParentWindowPositionChanged;
      inc(i);
    end;
end;

procedure TmainBrowser.WVInitializedMsg(var aMessage: TMessage);
begin
//  EnableButtonPnl;
end;

procedure GlobalWebView2Loader_OnEnvironmentCreated(Sender: TObject);
begin
  if (mainBrowser <> nil) and mainBrowser.HandleAllocated then
    PostMessage(mainBrowser.Handle, WV_INITIALIZED, 0, 0);
end;

initialization
  GlobalWebView2Loader                      := TWVLoader.Create(nil);
//  GlobalWebView2Loader.ProxySettings.Server := '127.0.0.1:8888';
  GlobalWebView2Loader.EnableGPU := True;
  GlobalWebView2Loader.EnableTrackingPrevention := False;
  GlobalWebView2Loader.UserDataFolder       := ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.OnEnvironmentCreated := GlobalWebView2Loader_OnEnvironmentCreated;
  GlobalWebView2Loader.StartWebView2;

end.
