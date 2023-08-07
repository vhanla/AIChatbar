object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 574
  Height = 440
  TabOrder = 0
  DesignSize = (
    574
    440)
  object svgIcon: TSkSvg
    Left = 493
    Top = 16
    Width = 64
    Height = 64
    Anchors = [akTop, akRight]
    ExplicitLeft = 424
  end
  object lblName: TLabeledEdit
    Left = 16
    Top = 32
    Width = 185
    Height = 23
    EditLabel.Width = 35
    EditLabel.Height = 15
    EditLabel.Caption = 'Name:'
    TabOrder = 0
    Text = ''
  end
  object lblURL: TLabeledEdit
    Left = 16
    Top = 80
    Width = 297
    Height = 23
    EditLabel.Width = 24
    EditLabel.Height = 15
    EditLabel.Caption = 'URL:'
    TabOrder = 1
    Text = ''
  end
  object lblAltURL: TLabeledEdit
    Left = 16
    Top = 128
    Width = 297
    Height = 23
    EditLabel.Width = 161
    EditLabel.Height = 15
    EditLabel.Caption = 'Alternate URL: (if primary fails)'
    TabOrder = 2
    Text = ''
  end
  object btnSearchSVG: TButton
    Left = 493
    Top = 86
    Width = 64
    Height = 27
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = btnSearchSVGClick
    ExplicitLeft = 424
  end
  object ckUserScript: TCheckBox
    Left = 16
    Top = 205
    Width = 137
    Height = 17
    Caption = 'Enable UserScripts'
    TabOrder = 4
  end
  object ckUserStyle: TCheckBox
    Left = 324
    Top = 205
    Width = 137
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Enable UserStyles'
    TabOrder = 5
    ExplicitLeft = 326
  end
  object ckEnabled: TCheckBox
    Left = 16
    Top = 388
    Width = 137
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Enabled'
    TabOrder = 6
    ExplicitTop = 473
  end
  object txtUserScript: TMemo
    Left = 16
    Top = 228
    Width = 233
    Height = 136
    Lines.Strings = (
      'Memo1')
    TabOrder = 7
  end
  object txtUserStyle: TMemo
    Left = 324
    Top = 220
    Width = 233
    Height = 136
    Anchors = [akTop, akRight]
    Lines.Strings = (
      'Memo1')
    TabOrder = 8
    ExplicitLeft = 326
  end
  object btnCancel: TButton
    Left = 401
    Top = 412
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    TabOrder = 9
    ExplicitLeft = 403
    ExplicitTop = 466
  end
  object btnOK: TButton
    Left = 482
    Top = 412
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 10
    ExplicitLeft = 413
    ExplicitTop = 349
  end
  object lblUA: TLabeledEdit
    Left = 16
    Top = 176
    Width = 297
    Height = 23
    EditLabel.Width = 103
    EditLabel.Height = 15
    EditLabel.Caption = 'Custom User Agent'
    TabOrder = 11
    Text = ''
  end
  object openSVG: TOpenDialog
    Left = 328
    Top = 48
  end
end
