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
  OnPaint = FormPaint
  OnShow = FormShow
  TextHeight = 15
  object CardPanel1: TCardPanel
    Left = 0
    Top = 0
    Width = 509
    Height = 728
    Margins.Left = 0
    Margins.Top = 2
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Caption = 'CardPanel1'
    TabOrder = 0
  end
end
