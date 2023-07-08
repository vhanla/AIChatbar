unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, ComCtrls, ImgList, registry, Spin,
  System.ImageList, Vcl.ControlList, Vcl.VirtualImage, Vcl.BaseImageCollection,
  SVGIconImageCollection, Vcl.ToolWin, IconFontsImageListBase,
  IconFontsImageList, Skia, Skia.Vcl, Vcl.Mask;

type
  TfrmSetting = class(TForm)
    imgLogo: TImage;
    lblTitle: TLabel;
    lblOk: TLabel;
    lblCancel: TLabel;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ImageList1: TImageList;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    chkLogonStretch: TCheckBox;
    chkAutoStart: TCheckBox;
    chkEnableLogon: TCheckBox;
    chkEnableSwitcher: TCheckBox;
    chkSwitcherApps: TCheckBox;
    GroupBox1: TGroupBox;
    chkEnableClock: TCheckBox;
    rbShowWin8Menu: TRadioButton;
    rbShowDesktop: TRadioButton;
    rbShowNormalMenu: TRadioButton;
    Image1: TImage;
    lblProgName: TLabel;
    lblAboutStrings: TLabel;
    chkUseEmbeddedBrowser: TRadioButton;
    rbUseExternalBrowser: TRadioButton;
    cbbBrowsers: TComboBox;
    edtBrowserPath: TEdit;
    chkLaunchAsWebApp: TCheckBox;
    chkUseKioskMode: TCheckBox;
    rbUseDefaultBrowser: TRadioButton;
    rbsbLaunchURL: TRadioButton;
    grpsbLaunch: TGroupBox;
    rbsbAsExecutable: TRadioButton;
    rbsbAsURLInEmbeddedBrowser: TRadioButton;
    rbsbAsURLInExternalBrowser: TRadioButton;
    edtsbCommandLine: TEdit;
    grpStartCustom: TGroupBox;
    imgStart: TImage;
    edtStartImg: TEdit;
    btnStartAddImg: TButton;
    edtStartCustomText: TEdit;
    cbbStartActions: TComboBox;
    grpUpToDate: TGroupBox;
    lblAppWebSite: TLabel;
    lblCheckNewVersion: TLabel;
    lblTwitterAccount: TLabel;
    lblAuthorsTwitter: TLabel;
    lblSoftwareTwitter: TLabel;
    grpMargins: TGroupBox;
    seMenuHotArea: TSpinEdit;
    lblMenuHotArea: TLabel;
    lblSwitcherHotArea: TLabel;
    seSwitcherHotArea: TSpinEdit;
    seThumbsHotArea: TSpinEdit;
    lblThumbsHotArea: TLabel;
    ControlList1: TControlList;
    Label1: TLabel;
    VirtualImage1: TVirtualImage;
    Label2: TLabel;
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    SVGIconImageCollection1: TSVGIconImageCollection;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    IconFontsImageList1: TIconFontsImageList;
    procedure FormCreate(Sender: TObject);
    procedure lblOkClick(Sender: TObject);
    procedure lblCancelClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure cbbBrowsersChange(Sender: TObject);
    procedure lblCheckNewVersionClick(Sender: TObject);
    procedure lblAppWebSiteClick(Sender: TObject);
    procedure lblTwitterAccountClick(Sender: TObject);
    procedure lblAuthorsTwitterClick(Sender: TObject);
    procedure lblSoftwareTwitterClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  frmSetting: TfrmSetting;

  webbrowserlst, webbrowserpath: TStringList;

implementation

{$R *.dfm}

uses menu,
  msxml, ShellAPI;

const
  RELESASESCOUNT = 2;
  // SEGUNDA COMPILACI�N , debe haber igual de posts en win8menu.tumblr.com

procedure ListWebBrowsers;
var
  reg, reg1: TRegistry;
  i: Integer;
  r, s: TStringList;
  def: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE; // need to be administrator
    if reg.OpenKeyReadOnly('Software\Clients\StartMenuInternet') then
    begin
      s := TStringList.Create;
      try
        // Reg.GetValueNames(S);
        reg.GetKeyNames(s);
        webbrowserlst.BeginUpdate;
        webbrowserlst.Clear;
        frmSetting.cbbBrowsers.Items.BeginUpdate;
        frmSetting.cbbBrowsers.Items.Clear;
        webbrowserpath.BeginUpdate;
        webbrowserpath.Clear;
        for i := 0 to s.Count - 1 do
        begin
          // ComboBox1.Items.Add(Reg.ReadString(S.Strings[i]));
          webbrowserlst.Add(s[i]);
          // agregamos los nombres dentro de ellos
          reg1 := TRegistry.Create;
          try
            reg1.RootKey := HKEY_LOCAL_MACHINE;
            if reg1.OpenKeyReadOnly('Software\Clients\StartMenuInternet\' + s[i])
            then
            begin
              frmSetting.cbbBrowsers.Items.Add(reg1.ReadString(''));
              reg1.CloseKey;
            end;
          finally
            reg1.Free;
          end;
          // agregamos las ubicaciones de cada ejecutable del navegador
          reg1 := TRegistry.Create;
          try
            reg1.RootKey := HKEY_LOCAL_MACHINE;
            if reg1.OpenKeyReadOnly('Software\Clients\StartMenuInternet\' + s[i]
              + '\shell\open\command') then
            begin
              webbrowserpath.Add(reg1.ReadString(''));
              reg1.CloseKey;
            end;
          finally
            reg1.Free;
          end;
        end;
        webbrowserpath.EndUpdate;
        frmSetting.cbbBrowsers.Items.EndUpdate;
        webbrowserlst.EndUpdate;
      finally
        s.Free;
      end;

      r := TStringList.Create;
      try
        reg.GetValueNames(r);
        def := reg.ReadString(r.Strings[0]);
        // (Predeterminado) REG_SZ El navegador predeterminado
        webbrowserlst.IndexOf(def);
        // retorna la posicion del navegador en la lista creada

      finally
        r.Free;
      end;
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;

end;

procedure TfrmSetting.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  // don't resize
  if (message.Result = htbottom) or (message.Result = htbottomleft) or
    (message.Result = htbottomright) or (message.Result = htleft) or
    (message.Result = htright) or (message.Result = httop) or
    (message.Result = httopleft) or (message.Result = httopright) then
    message.Result := HTBORDER;

end;

procedure TfrmSetting.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Params.Style:=Params.Style or WS_THICKFRAME;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure TfrmSetting.cbbBrowsersChange(Sender: TObject);
begin
  if cbbBrowsers.ItemIndex <> -1 then
  begin
    edtBrowserPath.Text := StringReplace(webbrowserpath[cbbBrowsers.ItemIndex],
      '"', '', [rfReplaceAll]);
    if pos('chrome.exe', edtBrowserPath.Text) > 0 then
      chkLaunchAsWebApp.Enabled := true
    else
    begin
      chkLaunchAsWebApp.Enabled := False;
      chkLaunchAsWebApp.Checked := False;
    end;
  end;

end;

procedure TfrmSetting.FormCreate(Sender: TObject);
begin
  // TranslateComponent(Self);

  // Color:=clBlack;
  /// BorderStyle:=bsNone;
  { GlassFrame.Enabled:=True;
    GlassFrame.Left:=24;
    GlassFrame.Right:=24;
    GlassFrame.Top:=110;
    GlassFrame.Bottom:=40; }
  BorderIcons := [];
  // GlassFrame.SheetOfGlass:=True;

  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or
    WS_EX_LAYERED { or WS_EX_TRANSPARENT } or
    WS_EX_TOOLWINDOW { and not WS_EX_APPWINDOW } );
  SetLayeredWindowAttributes(Handle, 0, 225, LWA_ALPHA);

  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height,
    SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE);

  // ImageList1.Clear;
  // ImageList1.Add(frmMenu.imgMenu.Picture.Bitmap,frmMenu.imgMenu.Picture.Bitmap);
  // ImageList1.Add(frmMenu.imgConnect.Picture.Bitmap,frmMenu.imgConnect.Picture.Bitmap);
  // ImageList1.Add(frmMenu.imgSearch.Picture.Bitmap,frmMenu.imgSearch.Picture.Bitmap);
  // ImageList1.Add(frmMenu.imgShare.Picture.Bitmap,frmMenu.imgShare.Picture.Bitmap);
  // ImageList1.Add(frmMenu.imgSettings.Picture.Bitmap,frmMenu.imgSettings.Picture.Bitmap);

  webbrowserlst := TStringList.Create;
  webbrowserpath := TStringList.Create;

  ListWebBrowsers;
end;

function GetComputerNetName: string;
var
  buffer: array [0 .. 255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

procedure TfrmSetting.lblOkClick(Sender: TObject);
begin

  close;
end;

procedure TfrmSetting.lblSoftwareTwitterClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'https://twitter.com/Codigobit', '',
    '', SW_SHOWNORMAL);
end;

procedure TfrmSetting.lblTwitterAccountClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'https://twitter.com/Win8Menu', '', '',
    SW_SHOWNORMAL);
end;

procedure TfrmSetting.FormDestroy(Sender: TObject);
begin
  webbrowserlst.Clear;
  webbrowserlst.Free;
  webbrowserpath.Clear;
  webbrowserpath.Free;
end;

procedure TfrmSetting.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TfrmSetting.lblAppWebSiteClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'http://apps.codigobit.info/Win8Menu',
    '', '', SW_SHOWNORMAL);
end;

procedure TfrmSetting.lblAuthorsTwitterClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'https://twitter.com/vhanla', '', '',
    SW_SHOWNORMAL);
end;

procedure TfrmSetting.lblCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmSetting.lblCheckNewVersionClick(Sender: TObject);
var
  doc: IXMLDOMDocument;
begin
  doc := CoDOMDocument.Create;
  doc.async := False;

  if doc.load('http://win8menu.tumblr.com/rss') then
    if doc.documentElement.selectNodes('channel/item').length > RELESASESCOUNT
    then
    begin
      if MessageDlg('A new version is available,'#13'Go to site?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        // acWebSite.Execute;
        shellexecute(GetDesktopWindow, 'OPEN',
          'http://apps.codigobit.info/Win8Menu', '', '', SW_SHOWNORMAL);
    end
    else
      // MessageDlg(_('Actualmente est� ejecutando la �ltima versi�n.'), mtInformation, [mbOK], 0);
      lblCheckNewVersion.Caption := 'You''re up to date.';
end;

end.