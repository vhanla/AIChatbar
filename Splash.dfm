object FormSplash: TFormSplash
  Left = 192
  Top = 124
  BorderStyle = bsNone
  Caption = 'FormSplash'
  ClientHeight = 442
  ClientWidth = 912
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnClick = FormClick
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  TextHeight = 13
  object TimerSplash: TTimer
    Interval = 4096
    OnTimer = TimerSplashTimer
    Left = 208
    Top = 112
  end
end
