object frm_attribInfo: Tfrm_attribInfo
  Left = 377
  Top = 233
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #23646#24615#31649#29702
  ClientHeight = 406
  ClientWidth = 576
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 340
    Align = alBottom
    TabOrder = 1
    Height = 66
    Width = 576
    object cxButton2: TcxButton
      Left = 408
      Top = 24
      Width = 75
      Height = 25
      Caption = #30830#23450
      TabOrder = 0
      OnClick = cxButton2Click
    end
    object cxButton1: TcxButton
      Left = 483
      Top = 24
      Width = 75
      Height = 25
      Caption = #21462#28040
      TabOrder = 1
      OnClick = cxButton1Click
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    Caption = #23646#24615#20449#24687
    TabOrder = 0
    Height = 340
    Width = 576
    object Label6: TLabel
      Left = 24
      Top = 34
      Width = 64
      Height = 20
      Caption = #21464#37327#21517#31216
    end
    object Label7: TLabel
      Left = 24
      Top = 83
      Width = 64
      Height = 20
      Caption = #21464#37327#31867#22411
    end
    object cxPageControl1: TcxPageControl
      Left = 2
      Top = 120
      Width = 572
      Height = 218
      ActivePage = cxTabSheet1
      Align = alBottom
      TabOrder = 2
      ClientRectBottom = 218
      ClientRectRight = 572
      ClientRectTop = 31
      object cxTabSheet1: TcxTabSheet
        Caption = #25968#20540#22411
        ImageIndex = 0
        object Label2: TLabel
          Left = 296
          Top = 107
          Width = 57
          Height = 20
          AutoSize = False
          Caption = #26368#22823
        end
        object Label3: TLabel
          Left = 48
          Top = 107
          Width = 57
          Height = 20
          AutoSize = False
          Caption = #26368#23567
        end
        object rg_num: TcxRadioGroup
          Left = 42
          Top = 18
          Alignment = alLeftCenter
          Properties.Columns = 3
          Properties.Items = <
            item
              Caption = #25972#25968
            end
            item
              Caption = #28014#28857#25968
            end>
          ItemIndex = 0
          TabOrder = 0
          Height = 55
          Width = 447
        end
        object sedt_num_max: TcxSpinEdit
          Left = 368
          Top = 104
          TabOrder = 1
          Width = 121
        end
        object sedt_num_min: TcxSpinEdit
          Left = 120
          Top = 104
          TabOrder = 2
          Width = 121
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = #26085#26399#26102#38388#22411
        ImageIndex = 1
        object Label4: TLabel
          Left = 288
          Top = 107
          Width = 57
          Height = 20
          AutoSize = False
          Caption = #26368#22823
        end
        object Label5: TLabel
          Left = 48
          Top = 107
          Width = 57
          Height = 20
          AutoSize = False
          Caption = #26368#23567
        end
        object Label8: TLabel
          Left = 64
          Top = 144
          Width = 185
          Height = 20
          AutoSize = False
          Caption = #26085#26399#26684#24335#65306'2012-01-01'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -17
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object rg_datetime: TcxRadioGroup
          Left = 42
          Top = 18
          Alignment = alLeftCenter
          Properties.Columns = 3
          Properties.Items = <
            item
              Caption = #26085#26399#26102#38388
            end
            item
              Caption = #26085#26399
            end
            item
              Caption = #26102#38388
            end>
          TabOrder = 0
          Height = 55
          Width = 447
        end
        object medt_date_max: TcxMaskEdit
          Left = 360
          Top = 104
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]- ([012]?[1-9] | [123]0 |31)-(0?[1-9] | ' +
            '1[012])'
          Properties.MaxLength = 0
          TabOrder = 1
          Width = 121
        end
        object medt_date_min: TcxMaskEdit
          Left = 120
          Top = 104
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]- ([012]?[1-9] | [123]0 |31)-(0?[1-9] | ' +
            '1[012])'
          Properties.MaxLength = 0
          TabOrder = 2
          Width = 121
        end
      end
      object cxTabSheet3: TcxTabSheet
        Caption = #26522#20030#22411
        ImageIndex = 2
        object Label1: TLabel
          Left = 8
          Top = 8
          Width = 496
          Height = 49
          AutoSize = False
          Caption = #22312#19979#38754#30340#36755#20837#26694#20013#36755#20837#38656#35201#38543#26426#25171#21360#30340#25991#23383#65292#20351#29992'","'#20316#20026#25991#23383#30340#38388#38548#12290
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -17
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object memo_enmu: TcxMemo
          Left = 0
          Top = 56
          Align = alBottom
          TabOrder = 0
          Height = 131
          Width = 572
        end
      end
    end
    object edt_item_name: TcxTextEdit
      Left = 122
      Top = 32
      TabOrder = 0
      Text = 'edt_item_name'
      Width = 305
    end
    object rg_master: TcxRadioGroup
      Left = 114
      Top = 74
      Alignment = alLeftCenter
      Properties.Columns = 3
      Properties.Items = <
        item
          Caption = #25968#23383
        end
        item
          Caption = #26085#26399#26102#38388
        end
        item
          Caption = #26522#20030
        end>
      Properties.OnEditValueChanged = cxRadioGroup3PropertiesEditValueChanged
      ItemIndex = 0
      TabOrder = 1
      Height = 39
      Width = 311
    end
  end
end
