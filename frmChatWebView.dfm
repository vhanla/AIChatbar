object mainBrowser: TmainBrowser
  Left = 0
  Top = 0
  AlphaBlendValue = 248
  BorderStyle = bsNone
  Caption = 'Chat'
  ClientHeight = 728
  ClientWidth = 509
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
    509
    728)
  TextHeight = 15
  object CardPanel1: TCardPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 509
    Height = 728
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Caption = 'CardPanel1'
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 509
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    OnMouseDown = Panel1MouseDown
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
