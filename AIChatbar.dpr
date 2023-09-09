program AIChatbar;



{$R *.dres}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Windows,
  menu in 'menu.pas' {frmMenu},
  Splash in 'Splash.pas',
  settings in 'settings.pas' {frmSetting},
  functions in 'functions.pas',
  Vcl.Themes,
  Vcl.Styles,
  frmChatWebView in 'frmChatWebView.pas' {mainBrowser},
  uBrowserCard in 'uBrowserCard.pas',
  uBrowserFrame in 'uBrowserFrame.pas' {BrowserFrame: TFrame},
  uChildForm in 'uChildForm.pas',
  settingsHelper in 'settingsHelper.pas',
  frameEditSite in 'frameEditSite.pas' {Frame1: TFrame},
  frmTaskGPT in 'frmTaskGPT.pas' {taskForm};

{$R *.res}

begin
  if FindWindow('AIChatbarWnd', nil) > 0 then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskBar := False;
  TStyleManager.TrySetStyle('Windows11 Modern Dark');
  Application.Title := 'AIChat';
  Application.CreateForm(TfrmMenu, frmMenu);
  Application.CreateForm(TfrmSetting, frmSetting);
  Application.CreateForm(TmainBrowser, mainBrowser);
  Application.CreateForm(TtaskForm, taskForm);
  Application.Run;

end.
