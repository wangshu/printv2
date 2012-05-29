object frm_printInfo: Tfrm_printInfo
  Left = 427
  Top = 316
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #25253#34920#20449#24687
  ClientHeight = 351
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 288
    Align = alBottom
    TabOrder = 1
    Height = 63
    Width = 564
    object cxButton1: TcxButton
      Left = 483
      Top = 24
      Width = 75
      Height = 25
      Caption = #21462#28040
      TabOrder = 1
      OnClick = cxButton1Click
    end
    object cxButton2: TcxButton
      Left = 408
      Top = 24
      Width = 75
      Height = 25
      Caption = #30830#23450
      TabOrder = 0
      OnClick = cxButton2Click
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    Caption = #25253#34920#20449#24687
    TabOrder = 0
    Height = 288
    Width = 564
    object Label1: TLabel
      Left = 24
      Top = 40
      Width = 89
      Height = 20
      AutoSize = False
      Caption = #25253#34920#21517#31216
    end
    object Label2: TLabel
      Left = 24
      Top = 88
      Width = 89
      Height = 20
      AutoSize = False
      Caption = #32440#23485
    end
    object Label3: TLabel
      Left = 256
      Top = 88
      Width = 57
      Height = 20
      AutoSize = False
      Caption = #32440#39640
    end
    object Label4: TLabel
      Left = 24
      Top = 136
      Width = 89
      Height = 20
      AutoSize = False
      Caption = #20351#29992#23383#20307
    end
    object Label5: TLabel
      Left = 24
      Top = 184
      Width = 89
      Height = 20
      AutoSize = False
      Caption = #25253#34920#31867#22411
    end
    object edt_title: TcxTextEdit
      Left = 120
      Top = 40
      TabOrder = 0
      Width = 369
    end
    object sedt_width: TcxSpinEdit
      Left = 120
      Top = 84
      TabOrder = 1
      Width = 121
    end
    object sedt_height: TcxSpinEdit
      Left = 336
      Top = 84
      TabOrder = 2
      Width = 121
    end
    object cb_font: TcxComboBox
      Left = 120
      Top = 132
      Properties.Items.Strings = (
        #26410#23450#20041
        #23383#20307#19968
        #23383#20307#20108
        #23383#20307#19977)
      TabOrder = 3
      Text = #26410#23450#20041
      Width = 121
    end
    object cb_reporttype: TcxComboBox
      Left = 120
      Top = 180
      Properties.Items.Strings = (
        'RM')
      TabOrder = 4
      Text = 'RM'
      Width = 121
    end
    object cxRadioGroup1: TcxRadioGroup
      Left = 72
      Top = 216
      Alignment = alLeftTop
      BiDiMode = bdRightToLeft
      Enabled = False
      ParentBiDiMode = False
      Properties.Items = <
        item
          Caption = 'STAR'
        end
        item
          Caption = 'EPSON'
        end
        item
          Caption = 'ESCPOS'
        end>
      TabOrder = 5
      Height = 57
      Width = 433
    end
  end
end
