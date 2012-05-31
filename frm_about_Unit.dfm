object AboutBox: TAboutBox
  Left = 412
  Top = 349
  BorderStyle = bsDialog
  ClientHeight = 251
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 18
  object Panel1: TPanel
    Left = 10
    Top = 10
    Width = 320
    Height = 196
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 0
    object ProgramIcon: TImage
      Left = 10
      Top = 10
      Width = 74
      Height = 64
      Picture.Data = {
        07544269746D617076020000424D760200000000000076000000280000002000
        0000200000000100040000000000000200000000000000000000100000000000
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00000000000000000000000000000000000EE8787878EEEEEEE03F30878EEE
        EEE00EE8787878EEEEEEE03F30878EEEEEE00EE8787878EEEEEEE03F30878EEE
        EEE00EE8787878EEEEEEE03F30878EEEEEE00887787877788888803F3088787E
        EEE00788787878878887803F3088887EEEE00788887888878887803F3088887E
        EEE00877888887788888703F308887EEEEE00888777778888888037883088888
        8EE007777777777777703787883087777EE00888888888888803787FF8830888
        888008888888888880378777778830888880077777777788037873F3F3F87808
        88E00888888888803787FFFFFFFF8830EEE00887777778800001111111111100
        EEE00888888888888899B999B99999EEEEE00888888888888899B9B99BB9B9EE
        EEE0088888888888899BB9BB99BB99EEEEE0078888888888899B999B999999EE
        EEE0087788888778899B9B9BB9BB99EEEEE00888778778888E9B9B9BB9999EEE
        EEE0088888788888EE9B99B9BB9BEEEEEEE00EE8888888EEEEE999B9999EEEEE
        EEE00EEEE888EEEEEEEE99BB999EEEEEEEE00EEEEE8EEEEEEEEEE999B9EEEEEE
        EEE00EEEEE8EEEEEEEEEEEE999EEEEEEEEE00EEEEE8EEEEEEEEEEEEE99EEEEEE
        EEE00EEEEE8EEEEEEEEEEEEE9EEEEEEEEEE00EEEEE8EEEEEEEEEEEEEEEEEEEEE
        EEE00EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE00000000000000000000000000000
        0000}
      Stretch = True
      IsControl = True
    end
    object ProductName: TLabel
      Left = 100
      Top = 19
      Width = 172
      Height = 18
      AutoSize = False
      Caption = #19987#19994#31080#25454#25171#21360#31995#32479
      IsControl = True
    end
    object Version: TLabel
      Left = 100
      Top = 46
      Width = 54
      Height = 18
      Caption = 'V0.0.2'
      IsControl = True
    end
    object Copyright: TLabel
      Left = 10
      Top = 92
      Width = 252
      Height = 18
      AutoSize = False
      Caption = #26412#31243#24207#19968#20999#26435#21033#24402#24320#21457#32773#25152#26377#65281
      IsControl = True
    end
    object Comments: TLabel
      Left = 10
      Top = 119
      Width = 72
      Height = 18
      Caption = 'KILL_NET'
      WordWrap = True
      IsControl = True
    end
    object Label1: TLabel
      Left = 11
      Top = 160
      Width = 19
      Height = 17
      AutoSize = False
      Caption = 'SN'
    end
    object edt_sn: TEdit
      Left = 54
      Top = 158
      Width = 260
      Height = 21
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = 'edt_sn'
    end
  end
  object OKButton: TButton
    Left = 127
    Top = 216
    Width = 85
    Height = 28
    Caption = #30830
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
