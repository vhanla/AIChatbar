unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, ComCtrls, ImgList, registry, Spin,
  System.ImageList, Vcl.ControlList, Vcl.VirtualImage, Vcl.BaseImageCollection,
  SVGIconImageCollection, Vcl.ToolWin, IconFontsImageListBase,
  IconFontsImageList, Skia, Skia.Vcl, Vcl.Mask, frameEditSite, JvExComCtrls,
  JvHotKey, settingsHelper;

type
  TfrmSetting = class(TForm)
    imgLogo: TImage;
    lblTitle: TLabel;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    ImageList1: TImageList;
    TabSheet2: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    chkAutoHide: TCheckBox;
    chkAutoStart: TCheckBox;
    chkClipText: TCheckBox;
    chkFSOff: TCheckBox;
    chkFSOff3D: TCheckBox;
    GroupBox1: TGroupBox;
    chkClipImg: TCheckBox;
    Image1: TImage;
    lblProgName: TLabel;
    lblAboutStrings: TLabel;
    chkUseEmbeddedBrowser: TRadioButton;
    rbUseExternalBrowser: TRadioButton;
    cbbPosition: TComboBox;
    edtProxy: TEdit;
    chkProxy: TCheckBox;
    chkDarkMode: TCheckBox;
    rbUseLeftWin11Taskbar: TRadioButton;
    grpUpToDate: TGroupBox;
    lblAppWebSite: TLabel;
    lblCheckNewVersion: TLabel;
    lblTwitterAccount: TLabel;
    lblAuthorsTwitter: TLabel;
    lblSoftwareTwitter: TLabel;
    grpMargins: TGroupBox;
    ControlList1: TControlList;
    lblSiteUrl: TLabel;
    VirtualImage1: TVirtualImage;
    lblSiteName: TLabel;
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    SVGIconImageCollection1: TSVGIconImageCollection;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    IconFontsImageList1: TIconFontsImageList;
    pnlEditSite: TPanel;
    Frame11: TFrame1;
    Button1: TButton;
    btnSaveSettings: TButton;
    JvGlobalHotKey: TJvHotKey;
    chkWinKey: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure lblCheckNewVersionClick(Sender: TObject);
    procedure lblAppWebSiteClick(Sender: TObject);
    procedure lblTwitterAccountClick(Sender: TObject);
    procedure lblAuthorsTwitterClick(Sender: TObject);
    procedure lblSoftwareTwitterClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure Frame11btnCancelClick(Sender: TObject);
    procedure Frame11btnOKClick(Sender: TObject);
    procedure btnSaveSettingsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ControlList1BeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure chkAutoHideClick(Sender: TObject);
    procedure chkAutoStartClick(Sender: TObject);
    procedure cbbPositionChange(Sender: TObject);
    procedure chkProxyClick(Sender: TObject);
    procedure chkDarkModeClick(Sender: TObject);
    procedure chkFSOff3DClick(Sender: TObject);
    procedure chkFSOffClick(Sender: TObject);
    procedure chkClipImgClick(Sender: TObject);
    procedure chkClipTextClick(Sender: TObject);
    procedure JvGlobalHotKeyChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkWinKeyClick(Sender: TObject);
    procedure ControlList1ItemDblClick(Sender: TObject);
  private
    { Private declarations }
    fTempHotkey: TShortcut;
    fEditedSiteId: Integer;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    procedure FillSettings(settings: TSettings);
    procedure UpdateControlList;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  frmSetting: TfrmSetting;

  webbrowserlst, webbrowserpath: TStringList;

implementation

{$R *.dfm}

uses menu,
  msxml, ShellAPI, functions, Vcl.Menus, Net.HttpClient, System.JSON;

const
  RELESASESCOUNT = 2;
  // SEGUNDA COMPILACIÓN , debe haber igual de posts en win8menu.tumblr.com

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
//        frmSetting.cbbBrowsers.Items.BeginUpdate;
//        frmSetting.cbbBrowsers.Items.Clear;
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
//              frmSetting.cbbBrowsers.Items.Add(reg1.ReadString(''));
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
//        frmSetting.cbbBrowsers.Items.EndUpdate;
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

procedure TfrmSetting.ControlList1BeforeDrawItem(AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
begin
  lblSiteName.Caption := frmMenu.Settings.Sites[AIndex].Name;
  lblSiteUrl.Caption := frmMenu.Settings.Sites[AIndex].Url;
  VirtualImage1.ImageIndex := AIndex;
end;

procedure TfrmSetting.ControlList1ItemDblClick(Sender: TObject);
begin
  fEditedSiteId := frmMenu.Settings.Sites[ControlList1.HotItemIndex].Id;
  Frame11.lblName.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].Name;
  Frame11.lblURL.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].Url;
  Frame11.lblAltURL.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].AltUrl;
  Frame11.svgIcon.Svg.Source := frmMenu.Settings.Sites[ControlList1.HotItemIndex].Icon;
  Frame11.ckUserScript.Checked := frmMenu.Settings.Sites[ControlList1.HotItemIndex].UserScriptEnabled;
  Frame11.ckUserStyle.Checked := frmMenu.Settings.Sites[ControlList1.HotItemIndex].UserStyleEnabled;
  Frame11.txtUserScript.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].UserScript;
  Frame11.txtUserStyle.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].UserStyle;
  Frame11.ckEnabled.Checked := frmMenu.Settings.Sites[ControlList1.HotItemIndex].Enabled;
  Frame11.lblUA.Text := frmMenu.Settings.Sites[ControlList1.HotItemIndex].UA;
  Frame11.btnOK.Caption := 'Update';
  pnlEditSite.Visible := True;
end;

procedure TfrmSetting.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Params.Style:=Params.Style or WS_THICKFRAME;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure TfrmSetting.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmSetting.btnSaveSettingsClick(Sender: TObject);
begin
  fTempHotkey := JvGlobalHotKey.HotKey;
  frmMenu.JvApplicationHotKey1.WindowsKey := chkWinKey.Checked;
  frmMenu.JvApplicationHotKey1.HotKey := JvGlobalHotKey.HotKey;
  frmMenu.JvApplicationHotKey1.Active := True;
  frmMenu.Settings.SaveSettings;
  Close;
end;

procedure TfrmSetting.cbbPositionChange(Sender: TObject);
begin
  if (cbbPosition.ItemIndex = 1) or (cbbPosition.ItemIndex = 3)  then
  begin
    MessageDlg('Top and Bottom are not available, yet.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    cbbPosition.ItemIndex := ABE_RIGHT;
    frmMenu.Settings.BarPosition := ABE_RIGHT;
  end
  else
    frmMenu.Settings.BarPosition := cbbPosition.ItemIndex;
end;

procedure TfrmSetting.chkAutoHideClick(Sender: TObject);
begin
  frmMenu.Settings.AutoHide := chkAutoHide.Checked;
end;

procedure TfrmSetting.chkAutoStartClick(Sender: TObject);
begin
  frmMenu.Settings.AutoStart := chkAutoStart.Checked;
  SetAutostartEnabled('AIChatbar', chkAutoStart.Checked);
end;

procedure TfrmSetting.chkClipImgClick(Sender: TObject);
begin
  frmMenu.Settings.DetectClipboardImage := chkClipImg.Checked;
end;

procedure TfrmSetting.chkClipTextClick(Sender: TObject);
begin
  frmMenu.Settings.DetectClipboardText := chkClipText.Checked;
end;

procedure TfrmSetting.chkDarkModeClick(Sender: TObject);
begin
  frmMenu.Settings.DarkMode := chkDarkMode.Checked;
  frmMenu.SetDarkMode(chkDarkMode.Checked);
end;

procedure TfrmSetting.chkFSOff3DClick(Sender: TObject);
begin
  frmMenu.Settings.DisableOnFullScreenDirectX := chkFSOff3D.Checked;
end;

procedure TfrmSetting.chkFSOffClick(Sender: TObject);
begin
  frmMenu.Settings.DisableOnFullScreen := chkFSOff.Checked;
end;

procedure TfrmSetting.chkProxyClick(Sender: TObject);
begin
  if chkProxy.Checked then
    frmMenu.Settings.Proxy := edtProxy.Text
  else
    frmMenu.Settings.Proxy := '';
end;

procedure TfrmSetting.chkWinKeyClick(Sender: TObject);
begin
  frmMenu.Settings.RequireWinKey := chkWinKey.Checked;
end;

procedure TfrmSetting.FillSettings(settings: TSettings);
begin
  chkAutoHide.Checked := settings.AutoHide;
  chkAutoStart.Checked := settings.AutoStart;
  chkClipText.Checked := settings.DetectClipboardText;
  chkClipImg.Checked := settings.DetectClipboardImage;
  chkFSOff.Checked := settings.DisableOnFullScreen;
  chkFSOff3D.Checked := settings.DisableOnFullScreenDirectX;
  JvGlobalHotKey.HotKey := TextToShortCut(settings.GlobalHotkey);
  chkWinKey.Checked := settings.RequireWinKey;
  cbbPosition.ItemIndex := settings.BarPosition;
  if settings.Proxy = '' then
  begin
    chkProxy.Checked := False;
    edtProxy.Text := '';
  end
  else
  begin
    chkProxy.Checked := True;
    edtProxy.Text := settings.Proxy;
  end;
  chkDarkMode.Checked := settings.DarkMode;
end;

procedure TfrmSetting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  JvGlobalHotKey.HotKey := fTempHotkey;

  frmMenu.JvApplicationHotKey1.Active := True;
end;

procedure TfrmSetting.FormCreate(Sender: TObject);
var
  I: Integer;
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

//  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) Or
//    WS_EX_LAYERED { or WS_EX_TRANSPARENT } or
//    WS_EX_TOOLWINDOW { and not WS_EX_APPWINDOW } );
//  SetLayeredWindowAttributes(Handle, 0, 225, LWA_ALPHA);

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

//  ListWebBrowsers;

  pnlEditSite.Align := alClient;

  if Assigned(frmMenu.Settings) then
  begin
    UpdateControlList;
  end;

  EnableNCShadow(Handle);

  FillSettings(frmMenu.Settings);
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

procedure TfrmSetting.ToolButton1Click(Sender: TObject);
begin
  Frame11.btnOK.Caption := 'Add';
  pnlEditSite.Visible := True;
end;

procedure TfrmSetting.UpdateControlList;
var
  I: Integer;
begin
  ControlList1.ItemCount := frmMenu.Settings.Sites.Count;
  SVGIconImageCollection1.ClearIcons;
  for I := 0 to frmMenu.Settings.Sites.Count - 1 do
  begin
    SVGIconImageCollection1.LoadFromString(frmMenu.Settings.Sites[I].Icon, frmMenu.Settings.Sites[I].Name);
  end;
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

procedure TfrmSetting.FormShow(Sender: TObject);
begin
  fTempHotkey := JvGlobalHotKey.HotKey;
  frmMenu.JvApplicationHotKey1.Active := False;
end;

procedure TfrmSetting.Frame11btnCancelClick(Sender: TObject);
begin
  pnlEditSite.Visible := False;
end;

procedure TfrmSetting.Frame11btnOKClick(Sender: TObject);
begin
  // Accept and close
  if Frame11.btnOK.Caption = 'Update' then
  begin
    frmMenu.Settings.UpdateSite(
      fEditedSiteId,
      Frame11.lblName.Text,
      Frame11.lblURL.Text,
      Frame11.lblAltURL.Text,
      Frame11.svgIcon.SVG.Source,
      Frame11.txtUserScript.Text,
      Frame11.txtUserStyle.Text,
      Frame11.ckUserScript.Checked,
      Frame11.ckUserStyle.Checked,
      Frame11.ckEnabled.Checked,
      0,
      Frame11.lblUA.Text
    );
  end
  else
  begin
    frmMenu.Settings.AddSites(
      Frame11.lblName.Text,
      Frame11.lblURL.Text,
      Frame11.lblAltURL.Text,
      Frame11.svgIcon.SVG.Source,
      Frame11.txtUserScript.Text,
      Frame11.txtUserStyle.Text,
      Frame11.ckUserScript.Checked,
      Frame11.ckUserStyle.Checked,
      Frame11.ckEnabled.Checked,
      0,
      Frame11.lblUA.Text
    );
  end;
  // refresh the icons
  frmMenu.LoadSites;
  UpdateControlList;
  frmMenu.Invalidate;

  pnlEditSite.Visible := False;
end;

procedure TfrmSetting.JvGlobalHotKeyChange(Sender: TObject);
begin
  frmMenu.Settings.GlobalHotkey := ShortCutToText(JvGlobalHotKey.HotKey);
end;

procedure TfrmSetting.lblAppWebSiteClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'https://codigobit.net/AIChatbar',
    '', '', SW_SHOWNORMAL);
end;

procedure TfrmSetting.lblAuthorsTwitterClick(Sender: TObject);
begin
  shellexecute(GetDesktopWindow, 'OPEN', 'https://twitter.com/vhanla', '', '',
    SW_SHOWNORMAL);
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
      // MessageDlg(_('Actualmente está ejecutando la última versión.'), mtInformation, [mbOK], 0);
      lblCheckNewVersion.Caption := 'You''re up to date.';
end;

end.
