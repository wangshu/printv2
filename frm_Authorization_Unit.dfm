object frm_Authorization: Tfrm_Authorization
  Left = 518
  Top = 484
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = #31995
  ClientHeight = 50
  ClientWidth = 226
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 13
    Top = 16
    Width = 84
    Height = 12
    Caption = #26381#21153#22120#36830#25509#20013'..'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 136
    Top = 8
  end
end
