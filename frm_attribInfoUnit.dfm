object frm_attribInfo: Tfrm_attribInfo
  Left = 377
  Top = 233
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #23646#24615
  ClientHeight = 345
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 289
    Align = alBottom
    TabOrder = 1
    Height = 56
    Width = 490
    object cxButton2: TcxButton
      Left = 347
      Top = 20
      Width = 64
      Height = 22
      Caption = #30830
      TabOrder = 0
      OnClick = cxButton2Click
    end
    object cxButton1: TcxButton
      Left = 411
      Top = 20
      Width = 63
      Height = 22
      Caption = #21462
      TabOrder = 1
      OnClick = cxButton1Click
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    Caption = #23646#24615
    TabOrder = 0
    Height = 289
    Width = 490
    object Label6: TLabel
      Left = 20
      Top = 29
      Width = 56
      Height = 17
      Caption = #21464#37327#21517#31216
    end
    object Label7: TLabel
      Left = 20
      Top = 71
      Width = 56
      Height = 17
      Caption = #21464#37327#31867#22411
    end
    object cxPageControl1: TcxPageControl
      Left = 2
      Top = 102
      Width = 486
      Height = 185
      ActivePage = cxTabSheet2
      Align = alBottom
      TabOrder = 2
      ClientRectBottom = 185
      ClientRectRight = 486
      ClientRectTop = 28
      object cxTabSheet1: TcxTabSheet
        Caption = #25968#0
        ImageIndex = 0
        object Label2: TLabel
          Left = 252
          Top = 91
          Width = 48
          Height = 17
          AutoSize = False
          Caption = #26368#22823
        end
        object Label3: TLabel
          Left = 41
          Top = 91
          Width = 48
          Height = 17
          AutoSize = False
          Caption = #26368#23567
        end
        object rg_num: TcxRadioGroup
          Left = 36
          Top = 15
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
          Height = 47
          Width = 380
        end
        object sedt_num_max: TcxSpinEdit
          Left = 313
          Top = 88
          TabOrder = 1
          Width = 103
        end
        object sedt_num_min: TcxSpinEdit
          Left = 102
          Top = 88
          TabOrder = 2
          Width = 103
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = #26085#26399#0
        ImageIndex = 1
        object Label4: TLabel
          Left = 245
          Top = 91
          Width = 48
          Height = 17
          AutoSize = False
          Caption = #26368#22823
        end
        object Label5: TLabel
          Left = 41
          Top = 91
          Width = 48
          Height = 17
          AutoSize = False
          Caption = #26368#23567
        end
        object Label8: TLabel
          Left = 54
          Top = 122
          Width = 158
          Height = 17
          AutoSize = False
          Caption = #26085#26399#26684#24335#65306'2012-01-01'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object rg_datetime: TcxRadioGroup
          Left = 36
          Top = 15
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
          Height = 47
          Width = 380
        end
        object medt_date_max: TcxMaskEdit
          Left = 306
          Top = 88
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]-(0?[1-9] | 1[012])- ([012]?[1-9] | [123' +
            ']0 |31)'
          Properties.MaxLength = 0
          TabOrder = 1
          Width = 103
        end
        object medt_date_min: TcxMaskEdit
          Left = 102
          Top = 88
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]-(0?[1-9] | 1[012])- ([012]?[1-9] | [123' +
            ']0 |31)'
          Properties.MaxLength = 0
          TabOrder = 2
          Width = 103
        end
      end
      object cxTabSheet3: TcxTabSheet
        Caption = #26522#0
        ImageIndex = 2
        object Label1: TLabel
          Left = 7
          Top = 7
          Width = 421
          Height = 41
          AutoSize = False
          Caption = #22312#19979#38754#30340#36755#20837#26694#20013#36755#20837#38656#35201#38543#26426#25171#21360#30340#25991#23383#65292#20351#29992'","'#20316#20026#25991#23383#30340#38388#38548#12290
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object memo_enmu: TcxMemo
          Left = 0
          Top = 46
          Align = alBottom
          TabOrder = 0
          Height = 111
          Width = 486
        end
      end
    end
    object edt_item_name: TcxTextEdit
      Left = 104
      Top = 27
      TabOrder = 0
      Text = 'edt_item_name'
      Width = 259
    end
    object rg_master: TcxRadioGroup
      Left = 97
      Top = 63
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
      Height = 33
      Width = 264
    end
  end
end
