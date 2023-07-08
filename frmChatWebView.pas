unit frmChatWebView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXPanels,
  uWVLoader, uWVCoreWebView2Args, scStyledForm;

const
  WV_INITIALIZED = WM_APP + $100;
  HOMEPAGE_URL        = 'https://www.bing.com';
  DEFAULT_TAB_CAPTION = 'New tab';

type
  TmainBrowser = class(TForm)
    CardPanel1: TCardPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    FBingID: Cardinal;
    FBardID: Cardinal;
    FChatGPTID: Cardinal;
    FYouID: Cardinal;

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
    procedure CreateBingChat;
    procedure CreateBardChat;
    procedure CreateGPTChat;
    procedure CreateYouChat;

    property BingID: Cardinal read FBingID default 0;
    property BardID: Cardinal read FBardID default 0;
    property ChatGPTID: Cardinal read FChatGPTID default 0;
    property YouID: Cardinal read FYouID default 0;
  end;

var
  mainBrowser: TmainBrowser;

implementation

{$R *.dfm}

uses
  uBrowserCard, functions;

{ TForm1 }

procedure TmainBrowser.CreateBardChat;
var
  TempNewCard : TBrowserCard;
  CardID: Cardinal;
begin
  if FBardID > 0 then Exit;

  CardID := NextCardID;
  TempNewCard := TBrowserCard.Create(self, CardID, DEFAULT_TAB_CAPTION);
  TempNewCard.Parent := CardPanel1;
  TempNewCard.Tag := CardID;
  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);
  FBardID := CardPanel1.CardCount;
  TempNewCard.CreateBrowser('https://bard.google.com/');
end;

procedure TmainBrowser.CreateBingChat;
var
  TempNewCard : TBrowserCard;
  CardID: Cardinal;
begin
  if FBingID > 0 then Exit;

  CardID := NextCardID;
  TempNewCard := TBrowserCard.Create(self, CardID, DEFAULT_TAB_CAPTION);
//  TempNewCard.CardPanel := CardPanel1;
  TempNewCard.Parent := CardPanel1;
  TempNewCard.Tag := CardID;
  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);
  FBingID := CardPanel1.CardCount;
  TempNewCard.CreateBrowser('https://edgeservices.bing.com/edgediscover/query?&darkschemeovr=1&FORM=SHORUN&udscs=1&udsnav=1&setlang=en-GB&features=udssydinternal&clientscopes=windowheader,coauthor,chat,&udsframed=1');
//  TempNewCard.CreateBrowser('https://www.microsoft.com/es-mx/edge/launch/newBinginEdge');
//  TempNewCard.CreateBrowser('https://bard.google.com')
end;

procedure TmainBrowser.CreateGPTChat;
var
  TempNewCard : TBrowserCard;
  CardID: Cardinal;
begin
  if FChatGPTID > 0 then Exit;

  CardID := NextCardID;
  TempNewCard := TBrowserCard.Create(self, CardID, DEFAULT_TAB_CAPTION);
  TempNewCard.Parent := CardPanel1;
  TempNewCard.Tag := CardID;
  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);
  FChatGPTID := CardPanel1.CardCount;
  TempNewCard.CreateBrowser('https://chat.openai.com/');
end;

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

procedure TmainBrowser.CreateYouChat;
var
  TempNewCard : TBrowserCard;
  CardID: Cardinal;
begin
  if FYouID > 0 then Exit;

  CardID := NextCardID;
  TempNewCard := TBrowserCard.Create(self, CardID, DEFAULT_TAB_CAPTION);
  TempNewCard.Parent := CardPanel1;
  TempNewCard.Tag := CardID;
  CardPanel1.ActiveCardIndex := pred(CardPanel1.CardCount);
  FYouID := CardPanel1.CardCount;
  TempNewCard.CreateBrowser('https://you.com/search?q=who+are+you&tbm=youchat');
end;

procedure TmainBrowser.FormCreate(Sender: TObject);
begin
  EnableBlur(Handle);
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
  GlobalWebView2Loader.UserDataFolder       := ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.OnEnvironmentCreated := GlobalWebView2Loader_OnEnvironmentCreated;
  GlobalWebView2Loader.StartWebView2;

end.
