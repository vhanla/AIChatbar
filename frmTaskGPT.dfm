object taskForm: TtaskForm
  Left = 0
  Top = 0
  Caption = 'TaskGPT - A ChatGPT System Assistant'
  ClientHeight = 311
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 8
  Padding.Top = 8
  Padding.Right = 8
  Padding.Bottom = 8
  Position = poScreenCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 553
    Height = 15
    Align = alTop
    Caption = 
      'TaskGPT is a ChatGPT based AI assitant that will launch applicat' +
      'ions and do some scripting for you.'
    ExplicitWidth = 519
  end
  object SearchBox1: TSearchBox
    Left = 8
    Top = 280
    Width = 553
    Height = 23
    Align = alBottom
    TabOrder = 0
    TextHint = 'Write your desired action on your PC'
    ExplicitTop = 272
    ExplicitWidth = 529
  end
  object grpTaskAnswer: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 31
    Width = 553
    Height = 241
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 8
    Align = alClient
    Caption = 'ChatGPT Answer'
    TabOrder = 1
    ExplicitTop = 48
    ExplicitWidth = 529
    ExplicitHeight = 218
    DesignSize = (
      553
      241)
    object Label2: TLabel
      Left = 16
      Top = 32
      Width = 63
      Height = 15
      Caption = 'Description:'
    end
    object Label3: TLabel
      Left = 16
      Top = 72
      Width = 38
      Height = 15
      Caption = 'Action:'
    end
    object Label4: TLabel
      Left = 16
      Top = 112
      Width = 65
      Height = 15
      Caption = 'Safety Level:'
    end
    object Button1: TButton
      Left = 460
      Top = 200
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Execute'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
