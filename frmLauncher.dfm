object formLauncher: TformLauncher
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'AI Launcher'
  ClientHeight = 166
  ClientWidth = 547
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  StyleElements = [seFont, seClient]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object SearchBox1: TSearchBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 541
    Height = 31
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    TextHint = 'How can I help you?'
    Visible = False
    ExplicitLeft = -2
    ExplicitTop = 8
  end
  object HtmlViewer1: THtmlViewer
    Left = 32
    Top = 45
    Width = 489
    Height = 118
    BorderStyle = htFocused
    HistoryMaxCount = 0
    NoSelect = False
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    PrintScale = 1.000000000000000000
    Text = ''
    TabOrder = 1
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 147
    Width = 547
    Height = 19
    Panels = <>
    ExplicitLeft = 280
    ExplicitTop = 96
    ExplicitWidth = 0
  end
  object ActionList1: TActionList
    Left = 264
    Top = 80
    object actHideLauncher: TAction
      Caption = 'actHideLauncher'
      ShortCut = 27
      OnExecute = actHideLauncherExecute
    end
  end
  object DataFormatAdapter1: TDataFormatAdapter
    DragDropComponent = DropHandler1
    DataFormatName = 'THTMLDataFormat'
    Left = 16
    Top = 56
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = [dtCopy, dtLink]
    OptimizedMove = True
    Left = 8
    Top = 16
  end
  object DropTextTarget1: TDropTextTarget
    DragTypes = [dtCopy, dtLink]
    Left = 440
    Top = 16
  end
  object DropComboTarget1: TDropComboTarget
    DragTypes = [dtCopy, dtLink]
    Left = 184
    Top = 16
  end
  object DropHandler1: TDropHandler
    DragTypes = [dtCopy, dtLink]
    Target = HtmlViewer1
    OptimizedMove = True
    Left = 354
    Top = 103
  end
  object DropContextMenu1: TDropContextMenu
    ContextMenu = PopupMenu1
    Left = 146
    Top = 103
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 8
    object DummyMenu1: TMenuItem
      Caption = 'Dummy Menu'
    end
  end
  object SynJScriptSyn1: TSynJScriptSyn
    Left = 312
    Top = 24
  end
  object SynBatSyn1: TSynBatSyn
    Left = 160
    Top = 72
  end
  object SynPythonSyn1: TSynPythonSyn
    Left = 440
    Top = 56
  end
  object SynJSONSyn1: TSynJSONSyn
    Left = 240
    Top = 56
  end
  object SynPasSyn1: TSynPasSyn
    Left = 224
    Top = 72
  end
  object SynCppSyn1: TSynCppSyn
    Left = 256
    Top = 32
  end
  object SynMultiSyn1: TSynMultiSyn
    Schemes = <
      item
        StartExpr = '```python'
        EndExpr = '```'
        Highlighter = SynPythonSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'Python'
      end
      item
        StartExpr = '```pascal'
        EndExpr = '```'
        Highlighter = SynPasSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'Pascal'
      end
      item
        StartExpr = '```delphi'#39
        EndExpr = '```'
        Highlighter = SynPasSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'Delphi'
      end
      item
        StartExpr = '```bat'
        EndExpr = '```'
        Highlighter = SynBatSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'Bat'
      end
      item
        StartExpr = '```json'
        EndExpr = '```'
        Highlighter = SynJSONSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'JSON'
      end
      item
        StartExpr = '```cpp'
        EndExpr = '```'
        Highlighter = SynCppSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'CPP'
      end
      item
        StartExpr = '```js'
        EndExpr = '```'
        Highlighter = SynJScriptSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'JS'
      end
      item
        StartExpr = '```javascript'
        EndExpr = '```'
        Highlighter = SynJScriptSyn1
        MarkerAttri.Background = clNone
        SchemeName = 'JavaScript'
      end>
    Left = 464
    Top = 88
  end
end
