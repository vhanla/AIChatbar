unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uWVBrowserBase, uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypeLibrary, uWVTypes,
  uChildForm, uWVCoreWebView2Args, uWVCoreWebView2Deferral, Skia, Skia.Vcl,
  Vcl.ExtCtrls, Winapi.TlHelp32, Winapi.PsAPI, Net.HttpClient;

type
  TBrowserTitleEvent = procedure(Sender: TObject; const aTitle : string) of object;

  TBrowserFrame = class(TFrame)
    WVBrowser1: TWVBrowser;
    WVWindowParent1: TWVWindowParent;
    SkAnimatedImage1: TSkAnimatedImage;
    Timer1: TTimer;
    procedure WVBrowser1AfterCreated(Sender: TObject);
    procedure WVBrowser1DocumentTitleChanged(Sender: TObject);
    procedure WVBrowser1NavigationStarting(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2NavigationStartingEventArgs);
    procedure WVBrowser1NavigationCompleted(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2NavigationCompletedEventArgs);
    procedure WVBrowser1SourceChanged(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2SourceChangedEventArgs);
    procedure WVBrowser1InitializationError(Sender: TObject;
      aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure WVBrowser1NewWindowRequested(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
    procedure WVBrowser1DOMContentLoaded(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2DOMContentLoadedEventArgs);
    procedure WVBrowser1WebMessageReceived(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
    procedure WVBrowser1WebResourceResponseReceived(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2WebResourceResponseReceivedEventArgs);
    procedure Timer1Timer(Sender: TObject);
    procedure WVBrowser1GetCookiesCompleted(Sender: TObject; aResult: HRESULT;
      const aCookieList: ICoreWebView2CookieList);
  private
    { Private declarations }
    FChildHandle: THandle;
    FTimeout: Integer;
    FMemoryUsage: Int64;
    FCtrlPEvent: TNotifyEvent;
    FCookies: TCookieManager;
    function GetMemoryUsage: Int64;
  protected
    FGetHeaders        : boolean;
    FHeaders           : TStringList;
    FHomepage             : wvstring;
    FUA                   : wvstring;
    FDisableCSP           : Boolean;
    FOnBrowserTitleChange : TBrowserTitleEvent;
    FArgs                 : TCoreWebView2NewWindowRequestedEventArgs;
    FDeferral             : TCoreWebView2Deferral;

    function  GetInitialized : boolean;

    procedure SetArgs(const aValue : TCoreWebView2NewWindowRequestedEventArgs);

  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;
    procedure   NotifyParentWindowPositionChanged;
    procedure   CreateBrowser;
    procedure   CreateAllHandles;

    property  Initialized          : boolean                                   read GetInitialized;
    property  Homepage             : wvstring                                  read FHomepage              write FHomepage;
    property  UA                   : wvstring                                  read FUA                    write FUA;
    property  OnBrowserTitleChange : TBrowserTitleEvent                        read FOnBrowserTitleChange  write FOnBrowserTitleChange;
    property  Args                 : TCoreWebView2NewWindowRequestedEventArgs  read FArgs                  write SetArgs;
    property  ChildHandle          : THandle                                   read FChildHandle;
    property  Headers              : TStringList                               read FHeaders;
    property  DisableCSP           : Boolean                                   read FDisableCSP            write FDisableCSP;
    property  MemoryUsage          : Int64                                     read GetMemoryUsage;
    property  CtrlPEvent           : TNotifyEvent read FCtrlPEvent write FCtrlPEvent;
    property  Cookies              : TCookieManager read FCookies write FCookies;
  end;

implementation

{$R *.dfm}

uses
  uWVCoreWebView2WindowFeatures, frmChatWebView, menu,
  uWVCoreWebView2WebResourceResponseView, uWVCoreWebView2HttpResponseHeaders,
  uWVCoreWebView2HttpHeadersCollectionIterator,
  uWVCoreWebView2ProcessInfoCollection, uWVCoreWebView2ProcessInfo,
  uWVCoreWebView2Delegates,
  uWVCoreWebView2CookieList, uWVCoreWebView2Cookie;

constructor TBrowserFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AOwner.GetParentComponent;
  FHomepage              := '';
  FOnBrowserTitleChange  := nil;
  FHeaders := TStringList.Create;
  FTimeOut := 3; // 3 seconds
  FCookies := TCookieManager.Create;
end;

procedure TBrowserFrame.CreateAllHandles;
begin
  CreateHandle;

  WVWindowParent1.CreateHandle;
end;

procedure TBrowserFrame.CreateBrowser;
begin
  WVBrowser1.DefaultURL := FHomepage;
//  WVBrowser1.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.0.0';
  WVBrowser1.CreateBrowser(WVWindowParent1.Handle);
  FChildHandle := WVWindowParent1.ChildWindowHandle;
end;

destructor TBrowserFrame.Destroy;
begin
  FCookies.Free;

  if assigned(FDeferral) then
    FreeAndNil(FDeferral);

  if assigned(FArgs) then
    FreeAndNil(FArgs);

  FHeaders.Free;

  inherited Destroy;
end;

function TBrowserFrame.GetInitialized: boolean;
begin
  Result := WVBrowser1.Initialized;
end;

procedure TBrowserFrame.NotifyParentWindowPositionChanged;
begin
  WVBrowser1.NotifyParentWindowPositionChanged;
end;

procedure TBrowserFrame.SetArgs(
  const aValue: TCoreWebView2NewWindowRequestedEventArgs);
begin
  FArgs     := aValue;
  FDeferral := TCoreWebView2Deferral.Create(FArgs.Deferral);
end;

function TBrowserFrame.GetMemoryUsage: Int64;
var
  TempCollection: TCoreWebView2ProcessInfoCollection;
  TempInfo: TCoreWebView2ProcessInfo;
  I: Cardinal;
  TempHandle: THandle;
  TempMemCtrs: TProcessMemoryCounters;
begin
  Result := 0;
  TempCollection := nil;
  TempInfo := nil;

  try
    TempCollection := TCoreWebView2ProcessInfoCollection.Create(WVBrowser1.ProcessInfos);

    I := 0;
    while (I < TempCollection.Count) do
    begin
      if Assigned(TempInfo) then
        TempInfo.BaseIntf := TempCollection.Items[I]
      else
        TempInfo := TCoreWebView2ProcessInfo.Create(TempCollection.Items[I]);

      {case TempInfo.Kind of
        COREWEBVIEW2_PROCESS_KIND_BROWSER         :

      end;}

      TempHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, TempInfo.ProcessId);
      if TempHandle <> 0 then
      try
        ZeroMemory(@TempMemCtrs, SizeOf(TProcessMemoryCounters));
        TempMemCtrs.cb := SizeOf(TProcessMemoryCounters);

        if GetProcessMemoryInfo(TempHandle, @TempMemCtrs, TempMemCtrs.cb) then
          Result := Result + TempMemCtrs.WorkingSetSize;

      finally
        CloseHandle(TempHandle);
      end;


      Inc(I);
    end;

  finally
    if Assigned(TempCollection) then
      FreeAndNil(TempCollection);

    if Assigned(TempInfo) then
      FreeAndNil(TempInfo);

  end;

end;

procedure TBrowserFrame.Timer1Timer(Sender: TObject);
begin
  if FTimeout > 0 then
    Dec(FTimeOut)
  else
  begin
    Timer1.Enabled := False;
    WVWindowParent1.Visible := True;
  end;

end;

procedure TBrowserFrame.WVBrowser1AfterCreated(Sender: TObject);
begin
  if FUA = '' then
    WVBrowser1.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.0.0'
  else
    WVBrowser1.UserAgent := FUA;
  if assigned(FArgs) and assigned(FDeferral) then
    try
      FArgs.NewWindow := WVBrowser1.CoreWebView2.BaseIntf;
      FArgs.Handled   := True;

      FDeferral.Complete;
    finally
      FreeAndNil(FDeferral);
      FreeAndNil(FArgs);
    end;

  WVWindowParent1.UpdateSize;
//  NavControlPnl.Enabled := True;
  Timer1.Enabled := True;
end;

procedure TBrowserFrame.WVBrowser1DocumentTitleChanged(Sender: TObject);
begin
  if assigned(FOnBrowserTitleChange) then
    FOnBrowserTitleChange(self, WVBrowser1.DocumentTitle);
end;

procedure TBrowserFrame.WVBrowser1DOMContentLoaded(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2DOMContentLoadedEventArgs);
begin
  WVWindowParent1.Visible := True;
  WVBrowser1.GetCookies();
end;

procedure TBrowserFrame.WVBrowser1GetCookiesCompleted(Sender: TObject;
  aResult: HRESULT; const aCookieList: ICoreWebView2CookieList);
var
  TempCookieList: TCoreWebView2CookieList;
  TempCookie: TCoreWebView2Cookie;
  I: Integer;
  a, b, c: Boolean;
begin
  TempCookieList := nil;
  TempCookie := nil;

  if Assigned(aCookieList) then
  try
    TempCookieList := TCoreWebView2CookieList.Create(aCookieList);
    TempCookie := TCoreWebView2Cookie.Create(nil);

    FCookies.Clear;
    for I := 0 to TempCookieList.Count - 1 do
    begin
      TempCookie.BaseIntf := TempCookieList.Items[I];
      Cookies.AddServerCookie(TempCookie.Name + '=' + TempCookie.Value, PChar('https://'+TempCookie.Domain));
    end;

  finally
    if Assigned(TempCookieList) then
      FreeAndNil(TempCookieList);
    if Assigned(TempCookie) then
      FreeAndNil(TempCookie);
  end;
end;

procedure TBrowserFrame.WVBrowser1InitializationError(Sender: TObject;
  aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  showmessage(aErrorMessage);
end;

procedure TBrowserFrame.WVBrowser1NavigationCompleted(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NavigationCompletedEventArgs);
begin
//  UpdateNavButtons(False);
  SkAnimatedImage1.Enabled := False;
  SkAnimatedImage1.Visible := False;
  Winapi.Windows.SetFocus(WVWindowParent1.ChildWindowHandle);
  WVBrowser1.ExecuteScript('window.addEventListener("keydown", function (e) { if (e.ctrlKey && e.key ==="p") { e.preventDefault(); window.chrome.webview.postMessage("ctrlp"); } });');
end;

procedure TBrowserFrame.WVBrowser1NavigationStarting(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NavigationStartingEventArgs);
begin
  FGetHeaders := True;
//  UpdateNavButtons(True);
  WVWindowParent1.Visible := False;
end;

procedure TBrowserFrame.WVBrowser1NewWindowRequested(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NewWindowRequestedEventArgs);
var
  TempChildForm : TChildForm;
begin
  TempChildForm := TChildForm.Create(Self, aArgs);
  TempChildForm.Show;
end;

procedure TBrowserFrame.WVBrowser1SourceChanged(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2SourceChangedEventArgs);
begin
//  URLCbx.Text := WVBrowser1.Source;
end;

procedure TBrowserFrame.WVBrowser1WebMessageReceived(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
var
  Msgs: TCoreWebView2WebMessageReceivedEventArgs;
begin
  Msgs := TCoreWebView2WebMessageReceivedEventArgs.Create(aArgs);
  try
    // create here the rules to interact with the webapps

    // handle Ctrl+P to switch among the other AI chats
    if Msgs.WebMessageAsString = 'ctrlp' then
    begin
    //  PostMessage(Application.Handle, WM_USER + 99, 0, 0);
      if Assigned(FCtrlPEvent) then
        FCtrlPEvent(Self);
    end;

//    Msgs.WebMessageAsJson;
  finally
    Msgs.Free;
  end;
  WVBrowser1.ExecuteScript('document.currentScript.setAttribute(''sanbox'', ''allow-forms'')');
end;

procedure TBrowserFrame.WVBrowser1WebResourceResponseReceived(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2WebResourceResponseReceivedEventArgs);
var
  TempArgs     : TCoreWebView2WebResourceResponseReceivedEventArgs;
  TempResponse : TCoreWebView2WebResourceResponseView;
  TempHeaders  : TCoreWebView2HttpResponseHeaders;
  TempIterator : TCoreWebView2HttpHeadersCollectionIterator;
  TempName     : wvstring;
  TempValue    : wvstring;
  TempHandler  : ICoreWebView2WebResourceResponseViewGetContentCompletedHandler;
begin
  if FGetHeaders then
  try
    FHeaders.Clear;
    FGetHeaders := False;
    TempArgs := TCoreWebView2WebResourceResponseReceivedEventArgs.Create(aArgs);
    TempResponse := TCoreWebView2WebResourceResponseView.Create(TempArgs.Response);
    TempHandler := TCoreWebView2WebResourceResponseViewGetContentCompletedHandler.Create(WVBrowser1);
    TempHeaders := TCoreWebView2HttpResponseHeaders.Create(TempResponse.Headers);
    TempIterator := TCoreWebView2HttpHeadersCollectionIterator.Create(TempHeaders.Iterator);

//    TempHeaders.AppendHeader('Content-Security-Policy', 'script-src ''self'' https://');

    TempResponse.GetContent(TempHandler);
    while TempIterator.HasCurrentHeader do
    begin
      if TempIterator.GetCurrentHeader(TempName, TempValue) then
      begin
        FHeaders.Add(TempName + ':' + TempValue);
      end;
      TempIterator.MoveNext;
    end;

    if FDisableCSP then
      TempHeaders.AppendHeader('Content-Security-Policy', '');

  finally
    FreeAndNil(TempIterator);
    FreeAndNil(TempHeaders);
    FreeAndNil(TempResponse);
    FreeAndNil(TempArgs);
    TempHandler := nil;
  end;
end;

end.
