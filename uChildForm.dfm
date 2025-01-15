object ChildForm: TChildForm
  Left = 0
  Top = 0
  Caption = 'ChildForm'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object WVWindowParent1: TWVWindowParent
    Left = 0
    Top = 0
    Width = 624
    Height = 422
    Align = alClient
    Color = clNone
    TabOrder = 0
    Browser = WVBrowser1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Cursor = crHandPoint
    Panels = <
      item
        Width = 50
      end>
    OnDblClick = StatusBar1DblClick
  end
  object WVBrowser1: TWVBrowser
    TargetCompatibleBrowserVersion = '95.0.1020.44'
    AllowSingleSignOnUsingOSPrimaryAccount = False
    OnAfterCreated = WVBrowser1AfterCreated
    OnDocumentTitleChanged = WVBrowser1DocumentTitleChanged
    OnNewWindowRequested = WVBrowser1NewWindowRequested
    OnWindowCloseRequested = WVBrowser1WindowCloseRequested
    Left = 144
    Top = 168
  end
end
