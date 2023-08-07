unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uWVBrowserBase, uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypeLibrary, uWVTypes,
  uChildForm, uWVCoreWebView2Args, uWVCoreWebView2Deferral, Skia, Skia.Vcl;

type
  TBrowserTitleEvent = procedure(Sender: TObject; const aTitle : string) of object;

  TBrowserFrame = class(TFrame)
    WVBrowser1: TWVBrowser;
    WVWindowParent1: TWVWindowParent;
    SkAnimatedImage1: TSkAnimatedImage;
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
  private
    { Private declarations }
    FChildHandle: THandle;
  protected
    FHomepage             : wvstring;
    FUA                   : wvstring;
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
  end;

implementation

{$R *.dfm}

uses
  uWVCoreWebView2WindowFeatures, frmChatWebView, menu;

constructor TBrowserFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FHomepage              := '';
  FOnBrowserTitleChange  := nil;
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
  if assigned(FDeferral) then
    FreeAndNil(FDeferral);

  if assigned(FArgs) then
    FreeAndNil(FArgs);

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
end;

procedure TBrowserFrame.WVBrowser1NavigationStarting(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NavigationStartingEventArgs);
begin
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
begin
  WVBrowser1.ExecuteScript('document.currentScript.setAttribute(''sanbox'', ''allow-forms'')');
end;

end.
