object mainBrowser: TmainBrowser
  Left = 0
  Top = 0
  AlphaBlendValue = 248
  Caption = 'Chat'
  ClientHeight = 689
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  StyleElements = [seFont]
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    493
    689)
  TextHeight = 15
  object CardPanel1: TCardPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 493
    Height = 689
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Caption = 'CardPanel1'
    TabOrder = 0
    ExplicitWidth = 509
    ExplicitHeight = 728
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 493
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    OnMouseDown = Panel1MouseDown
    ExplicitWidth = 509
    DesignSize = (
      493
      20)
    object lblPin: TLabel
      Left = 408
      Top = 8
      Width = 12
      Height = 15
      Cursor = crHandPoint
      Anchors = [akTop, akRight]
      Caption = #55357#56524
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = lblPinClick
      ExplicitLeft = 424
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 96
    Top = 296
  end
  object tmrRamUsage: TTimer
    OnTimer = tmrRamUsageTimer
    Left = 240
    Top = 352
  end
end
