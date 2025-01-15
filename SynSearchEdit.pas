unit SynSearchEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,   Vcl.ImageCollection,
  Vcl.VirtualImageList,
  SynEdit, Clipbrd;

type
  TSearchBoxIndicator = (sbiText, sbiAudio);

  TSearchTrigger = (stNone, stEnter, stCtrlEnter);
  TNewLineTrigger = (nlEnter, nlShiftEnter);

  TSearchSynEdit = class(TSynEdit)
  strict private
    class var FButtonImageCollection: TImageCollection;
    class constructor Create;
    class procedure InitButtonImageCollection; static;
    class destructor Destroy;
  private
    FSearchIndicator: TSearchBoxIndicator;
    FButtonImages: TVirtualImageList;
    FButtonWidth: Integer;
    FButtonRect: TRect;
    FMouseOverButton: Boolean;
    FButtonDown: Boolean;
    FOnInvokeSearch: TNotifyEvent;
    FExpandedHeight: Integer;
    FCollapsedHeight: Integer;
    FIsExpanded: Boolean;
    FSearchTrigger: TSearchTrigger;
    FNewLineTrigger: TNewLineTrigger;
    FCanvas: TCanvas;

    procedure SetButtonWidth(Value: Integer);
    procedure SetExpandedHeight(Value: Integer);
    procedure SetNewLineTrigger(Value: TNewLineTrigger);
    procedure UpdateButtonPosition;
    procedure SetSearchTrigger(Value: TSearchTrigger);
    procedure ValidateSearchTrigger(Value: TSearchTrigger);

    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMKillFocus(var Msg: TMessage); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Msg: TMessage); message WM_LBUTTONDBLCLK;
    procedure WMRButtonDown(var Msg: TMessage); message WM_RBUTTONDOWN;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;

    procedure DoTextChanged(Sender: TObject); // New
    procedure UpdateEditorState; // New

  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure LoadImages;
    procedure RepaintButton;
    procedure DrawButton(Canvas: TCanvas); virtual;
    procedure MouseCancel;
    procedure InvokeSearch; dynamic;
    procedure Resize; override;
    procedure ExpandEditor;
    procedure CollapseEditor;
    function IsNewLineAllowed(Shift: TShiftState): Boolean;
    property Canvas: TCanvas read FCanvas;

//    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
//    procedure WndProc(var Message: TMessage); override;
  public
    class function GetClipboardHTMLContent: string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 24;
    property ExpandedHeight: Integer read FExpandedHeight write SetExpandedHeight default 100;
    property SearchTrigger: TSearchTrigger read FSearchTrigger write SetSearchTrigger default stEnter;
    property NewLineTrigger: TNewLineTrigger read FNewLineTrigger write SetNewLineTrigger default nlEnter;
    property OnInvokeSearch: TNotifyEvent read FOnInvokeSearch write FOnInvokeSearch;

    // inherited properties
    property AccessibleName;
    property Align;
    property Anchors;
    property DoubleBuffered;
    property CaseSensitive default False;
    property Constraints;
    property Color;
    property ActiveLineColor;
    property Ctl3D;
    property Cursor;
    property ParentCtl3D;
    property Enabled;
    property Font;
    property Height;
    property Name;
    property ParentDoubleBuffered;
    property ParentColor default False;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property TextHint;
    property Visible;
    property Width;
    // inherited events
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnStartDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    // TCustomSynEdit properties
//++ CodeFolding
    property CodeFolding;
    property UseCodeFolding;
//-- CodeFolding
    property BookMarkOptions;
    property BorderStyle;
    property ExtraLineSpacing;
    property DisplayFlowControl;
    property FontQuality default fqClearTypeNatural;
    property Gutter;
    property HideSelection;
    property Highlighter;
    property IndentGuides;
    property ImeMode;
    property ImeName;
    property InsertCaret;
    property InsertMode;
    property Keystrokes;
    property Lines;
    property MaxUndo;
    property Options;
    property OverwriteCaret;
    property ReadOnly;
    property RightEdge;
    property RightEdgeColor;
    property ScrollHintColor;
    property ScrollHintFormat;
    property ScrollBars;
    property ScrollbarAnnotations;
    property SearchEngine;
    property SelectedColor;
    property TabWidth;
    property VisibleSpecialChars;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property WordWrapGlyph;
    // TCustomSynEdit events
    property OnChange;
    property OnClearBookmark;
    property OnCommandProcessed;
    property OnContextHelp;
    property OnContextPopup;
    property OnDropFiles;
    property OnGutterClick;
    property OnGutterGetText;
    property OnMouseCursor;
    property OnPaint;
    property OnPlaceBookmark;
    property OnProcessCommand;
    property OnProcessUserCommand;
    property OnReplaceText;
    property OnShowHint;
    property OnScroll;
    property OnSpecialLineColors;
    property OnStatusChange;
    property OnPaintTransient;
    property OnTripleClick;
    property OnQuadrupleClick;
    property OnSearchNotFound;
    property OnZoom;
//++ CodeFolding
    property OnScanForFoldRanges;
//-- CodeFolding
  end;

  TSearchSynEditStyleHook = class(TEditStyleHook)
  strict private
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
  strict protected
    procedure PaintNC(Canvas: TCanvas); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;
implementation

uses
  System.Types,
  System.Math,
  Vcl.ActnList,
  Vcl.Themes,
  Vcl.Consts,
  Vcl.ImgList,
  Vcl.GraphUtil,
  Winapi.CommCtrl,
  System.Generics.Collections;


const
  DefaultButtonWidth = 24;
  DefaultExpandedHeight = 100;
  DefaultCollapsedHeight = 30;
  DefaultButtonImageSize = 16;

{ TSearchSynEdit }

class constructor TSearchSynEdit.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TSearchSynEdit, TSearchSynEditStyleHook);
end;

class procedure TSearchSynEdit.InitButtonImageCollection;
 procedure LoadItem(const AName: String);
  begin
    FButtonImageCollection.Add(AName, HInstance, AName, ['', '_20X']);
  end;
begin
  if FButtonImageCollection <> nil then
    Exit;
//  FButtonImageCollection := TImageCollection.Create(nil);
//  // Add search icon image here
//   FButtonImageCollection.Add('SEARCH_ICON', HInstance, 'SEARCH_ICON');
  FButtonImageCollection := TImageCollection.Create(nil);
  LoadItem('WINXCTRLS_SEARCHINDICATORS_TEXT');
  LoadItem('WINXCTRLS_SEARCHINDICATORS_AUDIO');
end;

class destructor TSearchSynEdit.Destroy;
begin
  FreeAndNil(FButtonImageCollection);
end;

constructor TSearchSynEdit.Create(AOwner: TComponent);
begin
  InitButtonImageCollection;
  inherited Create(AOwner);

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  FButtonImages := TVirtualImageList.Create(Self);
  LoadImages;

  FButtonWidth := DefaultButtonWidth;
  FExpandedHeight := DefaultExpandedHeight;
  FCollapsedHeight := DefaultCollapsedHeight;
  FIsExpanded := False;
  FSearchTrigger := stNone;
  FNewLineTrigger := nlEnter;

  // Configure SynEdit defaults
  WantReturns := False;
  ScrollBars := ssNone;
  Height := FCollapsedHeight;
  BorderStyle := bsSingle;
  Gutter.Visible := False;

  Font.Name := 'Segoe UI';
  Font.Size := 13;
  // Hook into text changes
  OnChange := DoTextChanged;
end;

destructor TSearchSynEdit.Destroy;
begin
  FCanvas.Free;
  FButtonImages.Free;
  inherited;
end;

procedure TSearchSynEdit.DoTextChanged(Sender: TObject);
begin
  UpdateEditorState;
//  if Assigned(OnChange) then
//    OnChange(Self);
  Inherited;
end;

procedure TSearchSynEdit.DrawButton(Canvas: TCanvas); { TODO : original }
var
  ElementDetails: TThemedElementDetails;
  ImageIndex: Integer;
  LColor: TColor;
  LStyle: TCustomStyleServices;
  IX, IY: Integer;
begin
  if IsCustomStyleActive then
  begin
    LStyle := StyleServices(Self);
    Canvas.Brush.Color := LStyle.GetStyleColor(scEdit);
    Canvas.FillRect(FButtonRect);

    case FSearchIndicator of
      sbiText:
        begin
          if not Enabled then
            ElementDetails := LStyle.GetElementDetails(tsiTextDisabled)
          else if FButtonDown then
            ElementDetails := LStyle.GetElementDetails(tsiTextPressed)
          else if FMouseOverButton then
            ElementDetails := LStyle.GetElementDetails(tsiTextHot)
          else
            ElementDetails := LStyle.GetElementDetails(tsiTextNormal);

          LStyle.DrawElement(Canvas.Handle, ElementDetails, FButtonRect, nil, CurrentPPI);
        end;

      sbiAudio:
        begin
          if not Enabled then
            ElementDetails := LStyle.GetElementDetails(tsiAudioDisabled)
          else if FButtonDown then
            ElementDetails := LStyle.GetElementDetails(tsiAudioPressed)
          else if FMouseOverButton then
            ElementDetails := LStyle.GetElementDetails(tsiAudioHot)
          else
            ElementDetails := LStyle.GetElementDetails(tsiAudioNormal);

          LStyle.DrawElement(Canvas.Handle, ElementDetails, FButtonRect, nil, CurrentPPI);
        end;
    end;
  end
  else // No Styles
  begin
    if FButtonDown then
      LColor := clBtnShadow
    else if FMouseOverButton then
      LColor := clBtnFace
    else
     LColor := Self.Color;
    Canvas.Brush.Color := LColor;
    Canvas.FillRect(FButtonRect);

    if FSearchIndicator = sbiText then
      ImageIndex := 0
    else
      ImageIndex := 1;
    IX := FButtonRect.Left + (FButtonRect.Width - FButtonImages.Width) div 2;
    IY := FButtonRect.Top + (FButtonRect.Height - FButtonImages.Height) div 2;
    FButtonImages.Draw(Canvas, IX, IY, ImageIndex, Enabled);
  end;
end;

procedure TSearchSynEdit.LoadImages;
begin
  FButtonImages.SetSize(DefaultButtonImageSize, DefaultButtonImageSize);
  FButtonImages.AutoFill := True;
  FButtonImages.ImageCollection := FButtonImageCollection;
end;

procedure TSearchSynEdit.MouseCancel;{ TODO : original }
begin
  if GetCapture = Handle then
    ReleaseCapture;

  FButtonDown := False;
  RepaintButton;
end;

procedure TSearchSynEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        // Handle new line triggers
        if IsNewLineAllowed(Shift) then
        begin
          if not FIsExpanded then
            ExpandEditor;
          inherited KeyDown(Key, Shift);
          Key := 0;
        end
        // Handle search triggers
        else if ((FSearchTrigger = stEnter) and (Shift = [])) or
                ((FSearchTrigger = stCtrlEnter) and (ssCtrl in Shift)) then
        begin
          InvokeSearch;
          Key := 0;
        end;
      end;
  end;

  if Key <> 0 then
    inherited KeyDown(Key, Shift);
end;

procedure TSearchSynEdit.ExpandEditor;
begin
  if not FIsExpanded then
  begin
    FIsExpanded := True;
    WantReturns := True;
    ScrollBars := ssBoth;
    Height := FExpandedHeight;
    UpdateButtonPosition;
  end;
end;

class function TSearchSynEdit.GetClipboardHTMLContent: string;
var
  CF_HTML, CF_TEXT_HTML: Word;
  Data: THandle;
  Ptr: Pointer;
  Size: NativeUInt;
  HtmlData: string;
  Utf8: UTF8String;
  StartFragment, EndFragment: Integer;
  StartFragmentTag, EndFragmentTag: string;
begin
  Result := '';

  // Register Clipboard Formats
  CF_HTML := RegisterClipboardFormat('HTML Format');
  CF_TEXT_HTML := RegisterClipboardFormat('text/html');

  Clipboard.Open;
  try
    // Check for 'text/html' first (preferred, e.g., from Firefox)
    Data := Clipboard.GetAsHandle(CF_TEXT_HTML);
    if Data = 0 then
    begin
      // Fallback to 'HTML Format' (for Chromium browsers)
      Data := Clipboard.GetAsHandle(CF_HTML);
      if Data = 0 then
        Exit; // Neither format is available
    end;

    // Lock and extract data
    Ptr := GlobalLock(Data);
    try
      if Assigned(Ptr) then
      begin
        Size := GlobalSize(Data);
        if Size > 0 then
        begin
          // If we are using 'HTML Format' (Chromium-like), extract UTF-8 content
          if Data = Clipboard.GetAsHandle(CF_HTML) then
          begin
            SetString(Utf8, PAnsiChar(Ptr), Size - 1); // Extract UTF-8 content
            HtmlData := String(Utf8); // Convert to Delphi string
            StartFragmentTag := 'StartFragment:';
            EndFragmentTag := 'EndFragment:';

            // Look for StartFragment and EndFragment in the HTML data
            StartFragment := StrToIntDef(Copy(HtmlData, Pos(StartFragmentTag, HtmlData) + Length(StartFragmentTag), 10), -1);
            EndFragment := StrToIntDef(Copy(HtmlData, Pos(EndFragmentTag, HtmlData) + Length(EndFragmentTag), 10), -1);

            // Ensure valid fragment range and extract it
            if (StartFragment >= 0) and (EndFragment > StartFragment) then
              Result := Copy(HtmlData, StartFragment + 1, EndFragment - StartFragment)
            else
              Result := ''; // Return empty string if invalid markers
          end
          else
          begin
            // For 'text/html' format (e.g., Firefox), use it directly
            HtmlData := PChar(Ptr); // Directly assign for Firefox data (which is already a valid Delphi string)
            Result := HtmlData; // No need for extra processing
          end;
        end;
      end;
    finally
      GlobalUnlock(Data);
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure TSearchSynEdit.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  RepaintButton;
end;

procedure TSearchSynEdit.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FMouseOverButton := False;
end;

procedure TSearchSynEdit.CollapseEditor;
begin
  if FIsExpanded then
  begin
    FIsExpanded := False;
    WantReturns := False;
    ScrollBars := ssNone;
    Height := FCollapsedHeight;
    // Ensure text is visible in single line mode
    TopLine := 0;
    LeftChar := 1;
//    Self.Perform(EM_SCROLLCARET, 0, 0);
    UpdateButtonPosition;
  end;
end;

procedure TSearchSynEdit.UpdateButtonPosition;
begin
  if FIsExpanded then
    FButtonRect := Rect(Width - FButtonWidth - 4, Height - FButtonWidth - 4,
                       Width - 4, Height - 4)
  else
    FButtonRect := Rect(Width - FButtonWidth - 4, 2,
                       Width - 4, Height - 2);

  RepaintButton;
end;

procedure TSearchSynEdit.UpdateEditorState;
begin
  if Lines.Count = 1 then
  begin
    if FIsExpanded then
      CollapseEditor;
  end
  else
  begin
    if not FIsExpanded then
      ExpandEditor;
  end;
end;

procedure TSearchSynEdit.ValidateSearchTrigger(Value: TSearchTrigger);
begin
  // If Enter is set for new lines, we can't use Enter for search
  if (FNewLineTrigger = nlEnter) and (Value = stEnter) then
    FSearchTrigger := stNone
  else
    FSearchTrigger := Value;
end;

procedure TSearchSynEdit.RepaintButton;{ TODO : original }
begin
  if HandleAllocated then
    SendMessage(Handle, WM_NCPAINT, 0, 0);
end;

procedure TSearchSynEdit.WMKillFocus(var Msg: TMessage);  { TODO : original }
begin
  inherited;
  MouseCancel;
end;

procedure TSearchSynEdit.WMLButtonDblClk(var Msg: TMessage);{ TODO : original }
begin
  if FMouseOverButton then
    WMLButtonDown(Msg)
  else
    inherited;
end;

procedure TSearchSynEdit.WMLButtonDown(var Msg: TMessage);{ TODO : original }
begin
  if FMouseOverButton then
  begin
    if not Focused then
      SetFocus;
    FButtonDown := True;
    RepaintButton;
    SetCapture(Handle);
    Msg.Result := 0;
  end
  else
  begin
    inherited;
    if not Focused then
      MouseCancel;
  end;
end;

procedure TSearchSynEdit.WMLButtonUp(var Msg: TWMLButtonUp);{ TODO : original }
var
  P: TPoint;
  R: TRect;
begin
  MouseCancel;
  inherited;

  P := Msg.Pos;
  R := FButtonRect;
  if UseRightToLeftAlignment then
  begin
    R.Left := 0;
    P.X := R.Right + P.X;
  end;
  if PtInRect(R, P) then
    InvokeSearch;
end;

procedure TSearchSynEdit.WMNCCalcSize(var Msg: TWMNCCalcSize);{ TODO : original }
begin
  if not UseRightToLeftAlignment then
    Dec(Msg.CalcSize_Params^.rgrc[0].Right, FButtonWidth)
  else
    Inc(Msg.CalcSize_Params^.rgrc[0].Left, FButtonWidth);
  inherited;
end;

procedure TSearchSynEdit.WMNCHitTest(var Msg: TMessage);{ TODO : original }
begin
  inherited;

  if Msg.Result = Winapi.Windows.HTNOWHERE then
  begin
    FMouseOverButton := True;
    Msg.Result := HTCLIENT;
  end
  else
    FMouseOverButton := False;
end;

procedure TSearchSynEdit.WMNCPaint(var Msg: TWMNCPaint);{ TODO : original }
var
  DC: HDC;
begin
  inherited;

  DC := GetWindowDC(Handle);
  FCanvas.Handle := DC;
  try
    GetWindowRect(Handle, FButtonRect);
    OffsetRect(FButtonRect, -FButtonRect.Left, -FButtonRect.Top);

    InflateRect(FButtonRect, -2, -2);
    if not UseRightToLeftAlignment then
      FButtonRect.Left := FButtonRect.Right - FButtonWidth
    else
      FButtonRect.Right := FButtonRect.Left + FButtonWidth;
    IntersectClipRect(FCanvas.Handle, FButtonRect.Left, FButtonRect.Top, FButtonRect.Right, FButtonRect.Bottom);

    DrawButton(FCanvas);
    Msg.Result := 0;
  finally
    FCanvas.Handle := 0;
    ReleaseDC(Handle, DC);
  end;
end;

//procedure TSearchSynEdit.WMPaste(var Message: TWMPaste);
//var
//  HtmlContent: string;
//begin
//  HtmlContent := GetClipboardHTMLContent;
//
//  if HtmlContent <> '' then
//  begin
//    Self.Text := HtmlContent;
//  end
//  else
//    inherited;
//end;

procedure TSearchSynEdit.WMRButtonDown(var Msg: TMessage);{ TODO : original }
begin
  if FMouseOverButton then
    Msg.Result := 0
  else
    inherited;
end;

procedure TSearchSynEdit.WMSetCursor(var Msg: TWMSetCursor);{ TODO : original }
begin
  if FMouseOverButton then
    Msg.HitTest := Winapi.Windows.HTNOWHERE;

  inherited;
end;

//procedure TSearchSynEdit.WndProc(var Message: TMessage);
//var
//  HtmlContent: string;
//begin
//  if Message.Msg = WM_PASTE then
//  begin
//    HtmlContent := GetClipboardHTMLContent;
//
//    if HtmlContent <> '' then
//    begin
//      Self.Text := HtmlContent;
//    end
//    else
//      inherited;
//  end;
//
//  inherited WndProc(Message);
//end;

procedure TSearchSynEdit.Resize;
begin
  inherited;
  UpdateButtonPosition;
end;

procedure TSearchSynEdit.SetButtonWidth(Value: Integer);
begin
  if FButtonWidth <> Value then
  begin
    FButtonWidth := Value;
    UpdateButtonPosition;
  end;
end;

procedure TSearchSynEdit.SetExpandedHeight(Value: Integer);
begin
  if Value < DefaultCollapsedHeight then
    Value := DefaultCollapsedHeight;

  if FExpandedHeight <> Value then
  begin
    FExpandedHeight := Value;
    if FIsExpanded then
    begin
      Height := Value;
      UpdateButtonPosition;
    end;
  end;
end;

procedure TSearchSynEdit.SetNewLineTrigger(Value: TNewLineTrigger);
begin
  if FNewLineTrigger <> Value then
  begin
    FNewLineTrigger := Value;
    // Automatically adjust SearchTrigger if it conflicts with NewLineTrigger
    ValidateSearchTrigger(FSearchTrigger);
  end;
end;

procedure TSearchSynEdit.SetSearchTrigger(Value: TSearchTrigger);
begin
  if FSearchTrigger <> Value then
    ValidateSearchTrigger(Value);
end;

procedure TSearchSynEdit.InvokeSearch;
begin
  if Assigned(FOnInvokeSearch) then
    FOnInvokeSearch(Self);
end;

function TSearchSynEdit.IsNewLineAllowed(Shift: TShiftState): Boolean;
begin
  case FNewLineTrigger of
    nlEnter: Result := (Shift = []);
    nlShiftEnter: Result := (ssShift in Shift);
  end;
end;

{ TSearchBoxStyleHook }

constructor TSearchSynEditStyleHook.Create(AControl: TWinControl);
begin
  inherited;

end;

procedure TSearchSynEditStyleHook.PaintNC(Canvas: TCanvas);
var
  Details: TThemedElementDetails;
  ControlRect, EditRect, BtnRect: TRect;
  BtnWidth: Integer;
  LStyle: TCustomStyleServices;

begin
  LStyle := StyleServices;
  if LStyle.Available then
  begin
    // Draw border of control
    if Control.Focused then
      Details := LStyle.GetElementDetails(teEditBorderNoScrollFocused)
    else if MouseInControl then
      Details := LStyle.GetElementDetails(teEditBorderNoScrollHot)
    else if Control.Enabled then
      Details := LStyle.GetElementDetails(teEditBorderNoScrollNormal)
    else
      Details := LStyle.GetElementDetails(teEditBorderNoScrollDisabled);

    ControlRect := Rect(0, 0, Control.Width, Control.Height);

    EditRect := ControlRect;
    InflateRect(EditRect, -2, -2);
    BtnWidth := TSearchSynEdit(Control).ButtonWidth;
    if not Control.UseRightToLeftAlignment then
      Dec(EditRect.Right, BtnWidth)
    else
      Inc(EditRect.Left, BtnWidth);

    // Exclude the editing area
    ExcludeClipRect(Canvas.Handle, EditRect.Left, EditRect.Top, EditRect.Right, EditRect.Bottom);

    LStyle.DrawElement(Canvas.Handle, Details, ControlRect);

    // Draw the button
    BtnRect := ControlRect;
    InflateRect(BtnRect, -2, -2);

    if not Control.UseRightToLeftAlignment then
      BtnRect.Left := BtnRect.Right - BtnWidth
    else
      BtnRect.Right := BtnRect.Left + BtnWidth;
    IntersectClipRect(Canvas.Handle, BtnRect.Left, BtnRect.Top, BtnRect.Right, BtnRect.Bottom);

    TSearchSynEdit(Control).FButtonRect := BtnRect;
    TSearchSynEdit(Control).DrawButton(Canvas);
  end;
end;

procedure TSearchSynEditStyleHook.WMNCCalcSize(var Msg: TWMNCCalcSize);
var
  W: Integer;
begin
  if (Control is TSearchSynEdit) then
  begin
    W := TSearchSynEdit(Control).ButtonWidth;

    if not Control.UseRightToLeftAlignment then
      Dec(Msg.CalcSize_Params^.rgrc[0].Right, W)
    else
      Inc(Msg.CalcSize_Params^.rgrc[0].Left, W);

    InflateRect(Msg.CalcSize_Params^.rgrc[0], -2, -2);
    Handled := True;
  end;
end;

end.