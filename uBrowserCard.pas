unit uBrowserCard;

interface

uses
  Winapi.Windows, System.Classes, Winapi.Messages, Vcl.ComCtrls, Vcl.Controls,
  Vcl.Forms, System.SysUtils, uBrowserFrame, uWVCoreWebView2Args, Vcl.WinXPanels;

type
  TBrowserCard = class(TCard)
  protected
    FBrowserFrame: TBrowserFrame;
    FCardID: Cardinal;

    function GetInitialized: Boolean;

    procedure CreateFrame(const aHomepage, aUA : string); overload;
    procedure CreateFrame(const aArgs : TCoreWebView2NewWindowRequestedEventArgs); overload;

    procedure BrowserFrame_OnBrowserTitleChange(Sender: TObject; const aTitle : string);
  public
    constructor Create(AOwner: TComponent; aCardID : cardinal; const aCaption : string); reintroduce;
    procedure NotifyParentWindowPositionChanged;
    procedure CreateBrowser(const aHomepage, aUA: string); overload;
    procedure CreateBrowser(const aArgs : TCoreWebView2NewWindowRequestedEventArgs); overload;
    procedure Navigate(const url: string);

    procedure FocusBrowser;

    property CardID            : cardinal   read FCardID;
    property Initialized       : boolean    read GetInitialized;
  end;

implementation

uses
  frmChatWebView, menu;

{ TBrowserCard }

procedure TBrowserCard.BrowserFrame_OnBrowserTitleChange(Sender: TObject;
  const aTitle: string);
begin
  Caption := aTitle;
end;

constructor TBrowserCard.Create(AOwner: TComponent; aCardID: cardinal;
  const aCaption: string);
begin
  inherited Create(AOwner);

  FCardID       := aCardID;
  Caption       := aCaption;
  FBrowserFrame := nil;
end;

procedure TBrowserCard.CreateBrowser(
  const aArgs: TCoreWebView2NewWindowRequestedEventArgs);
begin
  CreateFrame(aArgs);

  if (FBrowserFrame <> nil) then FBrowserFrame.CreateBrowser;
end;

procedure TBrowserCard.CreateBrowser(const aHomepage, aUA: string);
begin
  CreateFrame(aHomepage, aUA);

  if (FBrowserFrame <> nil) then FBrowserFrame.CreateBrowser;
end;

procedure TBrowserCard.CreateFrame(
  const aArgs: TCoreWebView2NewWindowRequestedEventArgs);
begin
  CreateFrame('', '');

  FBrowserFrame.Args := aArgs;
end;

procedure TBrowserCard.FocusBrowser;
begin
  if (FBrowserFrame <> nil) then
  begin
    Winapi.Windows.SetFocus(FBrowserFrame.ChildHandle);
  end;
end;

procedure TBrowserCard.CreateFrame(const aHomepage, aUA: string);
begin
  if (FBrowserFrame = nil) then
    begin
      FBrowserFrame                      := TBrowserFrame.Create(self);
      FBrowserFrame.Name                 := 'BrowserFrame' + IntToStr(CardID);
      FBrowserFrame.Parent               := self;
      FBrowserFrame.Align                := alClient;
      FBrowserFrame.Visible              := True;
      FBrowserFrame.OnBrowserTitleChange := BrowserFrame_OnBrowserTitleChange;
      FBrowserFrame.CreateAllHandles;
    end;

  FBrowserFrame.UA := aUA;
  FBrowserFrame.Homepage := aHomepage;
end;

function TBrowserCard.GetInitialized: Boolean;
begin
  Result := (FBrowserFrame <> nil) and
            FBrowserFrame.Initialized;
end;

procedure TBrowserCard.Navigate(const url: string);
begin
  FBrowserFrame.WVBrowser1.Navigate(url);
end;

procedure TBrowserCard.NotifyParentWindowPositionChanged;
begin
  FBrowserFrame.NotifyParentWindowPositionChanged;
end;

end.
