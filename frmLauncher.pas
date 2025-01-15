unit frmLauncher;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ACL.UI.Controls.Base,
  ACL.UI.Controls.BaseEditors, ACL.UI.Controls.TextEdit,
  ACL.UI.Controls.SearchBox, Vcl.StdCtrls, Vcl.WinXCtrls, System.Actions,
  Vcl.ActnList, HTMLUn2, HtmlView, DragDropContext, DropHandler,
  DropComboTarget, DragDropText, DragDrop, DropTarget, DragDropFile, Vcl.Menus, Vcl.Clipbrd, UWP.DarkMode, UWP.Form, SynSearchEdit,
  SynEdit, SynMarkdownViewer, SynEditHighlighter, SynHighlighterMulti,
  SynEditTypes, Vcl.AppEvnts, SynHighlighterHtml, SynHighlighterCpp,
  SynHighlighterPas, SynHighlighterJSON, SynHighlighterPython,
  SynHighlighterBat, SynHighlighterJScript,
  SynEditCodeFolding, SynHighlighterCS, Vcl.ComCtrls;

type
  TSearchBox = class(Vcl.WinXCtrls.TSearchBox)
  private
    function GetClipboardHTMLContent: string;
  protected
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  end;

type
  TformLauncher = class(TUWPForm)
    SearchBox1: TSearchBox;
    ActionList1: TActionList;
    actHideLauncher: TAction;
    HtmlViewer1: THtmlViewer;
    DataFormatAdapter1: TDataFormatAdapter;
    DropFileTarget1: TDropFileTarget;
    DropTextTarget1: TDropTextTarget;
    DropComboTarget1: TDropComboTarget;
    DropHandler1: TDropHandler;
    DropContextMenu1: TDropContextMenu;
    PopupMenu1: TPopupMenu;
    DummyMenu1: TMenuItem;
    SynJScriptSyn1: TSynJScriptSyn;
    SynBatSyn1: TSynBatSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynJSONSyn1: TSynJSONSyn;
    SynPasSyn1: TSynPasSyn;
    SynCppSyn1: TSynCppSyn;
    SynMultiSyn1: TSynMultiSyn;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure actHideLauncherExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    SearchEdit1: TSearchSynEdit;
    procedure PasteProcessed(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Launch(Sender: TObject);
  public
    { Public declarations }
  end;

var
  formLauncher: TformLauncher;
//  CF_HTML: WORD;

implementation

uses
  functions, pngimage, functions.windowfocus, ShellApi, uChildForm;

{$R *.dfm}

procedure HandleClipboardImage;
var
  CF_PNG, CF_DIBV5: UINT;
  Data: THandle;
  Ptr: Pointer;
  Size: NativeUInt;
  Png: TPngImage;
  Bitmap: TBitmap;
begin
  CF_PNG := RegisterClipboardFormat('PNG');
  CF_DIBV5 := RegisterClipboardFormat('CF_DIBV5'); // Ensure compatibility

  Clipboard.Open;
  try
    // Check for PNG format
    if Clipboard.HasFormat(CF_PNG) then
    begin
      Data := Clipboard.GetAsHandle(CF_PNG);
      if Data <> 0 then
      begin
        Ptr := GlobalLock(Data);
        try
          Size := GlobalSize(Data);
          if Size > 0 then
          begin
            Png := TPngImage.Create;
            try
//              Png.LoadFromStream(TMemoryStream.CreateFromBuffer(Ptr, Size));
              // Do something with the PNG (e.g., save or display)
              Png.SaveToFile('clipboard_image.png');
              ShowMessage('PNG image saved with transparency.');
            finally
              Png.Free;
            end;
          end;
        finally
          GlobalUnlock(Data);
        end;
      end;
    end
    // Fallback to CF_DIBV5
    else if Clipboard.HasFormat(CF_DIBV5) then
    begin
      Data := Clipboard.GetAsHandle(CF_DIBV5);
      if Data <> 0 then
      begin
        Ptr := GlobalLock(Data);
        try
          // Convert DIBV5 to a Delphi TBitmap with transparency
          Bitmap := TBitmap.Create;
          try
            Bitmap.PixelFormat := pf32bit;
            Bitmap.Handle := CreateDIBitmap(GetDC(0), PBitmapInfoHeader(Ptr)^, CBM_INIT, Ptr,
              PBitmapInfo(Ptr)^, DIB_RGB_COLORS);
            Bitmap.SaveToFile('clipboard_image.bmp');
            ShowMessage('Bitmap with alpha saved.');
          finally
            Bitmap.Free;
          end;
        finally
          GlobalUnlock(Data);
        end;
      end;
    end
    else
      ShowMessage('No supported image format found on clipboard.');
  finally
    Clipboard.Close;
  end;
end;

procedure TformLauncher.actHideLauncherExecute(Sender: TObject);
begin

  Hide;
end;

procedure TformLauncher.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WinClassName := 'AIChatbarWndL';
end;

procedure TformLauncher.FormCreate(Sender: TObject);
begin
  EnableNCShadow(Handle);
  SetDarkMode(Handle, True);

//  CF_HTML := RegisterClipboardFormat('HTML Format');

  SearchEdit1 := TSearchSynEdit.Create(Self);
  SearchEdit1.Parent := formLauncher;
  SearchEdit1.Align := alTop;
  SearchEdit1.Color := $2c2c2c;
  SearchEdit1.Font.Color := $dcdcdc;
  SearchEdit1.AlignWithMargins := True;
  SearchEdit1.OnKeyDown := PasteProcessed;
  SearchEdit1.OnInvokeSearch := Launch;
  SearchEdit1.SearchTrigger := stCtrlEnter;
  SearchEdit1.ExpandedHeight := ClientHeight - SearchEdit1.Height;
  SearchEdit1.RightEdge := 0;
  SearchEdit1.Highlighter := SynMultiSyn1;
end;

procedure TformLauncher.FormDestroy(Sender: TObject);
begin
  SearchEdit1.Free;
end;

procedure TformLauncher.FormResize(Sender: TObject);
begin
  if ClientHeight > SearchEdit1.Height then
    SearchEdit1.ExpandedHeight := ClientHeight - SearchEdit1.Height;
end;

procedure TformLauncher.FormShow(Sender: TObject);
begin
//  AnimateWindow(Handle, 150, AW_ACTIVATE or AW_CENTER or AW_SLIDE);
//  SetForegroundWindow(Handle);
  TWindowFocusHelper.FocusWindow(Handle);
end;

procedure TformLauncher.Launch(Sender: TObject);
var
  TempChildForm : TChildForm;
begin
  TempChildForm := TChildForm.Create(Self, 'https://chatgpt.com/?q='+SearchEdit1.Text+'&ref=ext&model=auto&temporary-chat=true');
  TempChildForm.Show;
end;

procedure TformLauncher.PasteProcessed(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 86) and (Shift = [ssCtrl, ssShift]) then
  begin
    SearchEdit1.SelText := TSearchSynedit.GetClipboardHTMLContent;
    Key := 0;
  end;
end;

function TSearchBox.GetClipboardHTMLContent: string;
var
  CF_HTML: Word;
  Data: THandle;
  Ptr: Pointer;
  Size: NativeUInt;
  utf8: UTF8String;
begin
  Result := '';
  CF_HTML := RegisterClipboardFormat('HTML Format');

  Clipboard.Open;
  try
    Data := Clipboard.GetAsHandle(CF_HTML);
    if Data = 0 then
      Exit; // No HTML data on the clipboard

    Ptr := GlobalLock(Data);
    try
      if Assigned(Ptr) then
      begin
        Size := GlobalSize(Data);
        if Size > 0 then
        begin
          SetString(utf8, PAnsiChar(Ptr), Size - 1); // Extract UTF-8 content
          Result := string(utf8); // Convert to a Delphi string
        end;
      end;
    finally
      GlobalUnlock(Data);
    end;
  finally
    Clipboard.Close;
  end;
end;

{ TSearchBox2 }

procedure TSearchBox.WMPaste(var Message: TWMPaste);
var
  HtmlContent: string;
begin
  HtmlContent := GetClipboardHTMLContent;

  if HtmlContent <> '' then
  begin
    formLauncher.HtmlViewer1.LoadFromString(HtmlContent);
  end
  else
    inherited;
end;

end.
