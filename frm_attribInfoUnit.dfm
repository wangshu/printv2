object frm_attribInfo: Tfrm_attribInfo
  Left = 377
  Top = 233
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #23646#24615
  ClientHeight = 487
  ClientWidth = 692
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 18
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 408
    Align = alBottom
    TabOrder = 1
    Height = 79
    Width = 692
    object cxButton2: TcxButton
      Left = 490
      Top = 28
      Width = 90
      Height = 31
      Caption = #30830#23450
      TabOrder = 0
      OnClick = cxButton2Click
    end
    object cxButton1: TcxButton
      Left = 580
      Top = 28
      Width = 89
      Height = 31
      Caption = #21462#28040
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
    Height = 408
    Width = 692
    object Label6: TLabel
      Left = 28
      Top = 41
      Width = 72
      Height = 18
      Caption = #21464#37327#21517#31216
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 28
      Top = 100
      Width = 72
      Height = 18
      Caption = #21464#37327#31867#22411
    end
    object cxPageControl1: TcxPageControl
      Left = 2
      Top = 145
      Width = 688
      Height = 261
      ActivePage = cxTabSheet1
      Align = alBottom
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      ClientRectBottom = 261
      ClientRectRight = 688
      ClientRectTop = 28
      object cxTabSheet1: TcxTabSheet
        Caption = #25968#23383
        ImageIndex = 0
        object Label2: TLabel
          Left = 356
          Top = 128
          Width = 68
          Height = 24
          AutoSize = False
          Caption = #26368#22823
        end
        object Label3: TLabel
          Left = 58
          Top = 128
          Width = 68
          Height = 24
          AutoSize = False
          Caption = #26368#23567
        end
        object rg_num: TcxRadioGroup
          Left = 51
          Top = 21
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
          Height = 67
          Width = 536
        end
        object sedt_num_max: TcxSpinEdit
          Left = 442
          Top = 124
          TabOrder = 1
          Width = 145
        end
        object sedt_num_min: TcxSpinEdit
          Left = 144
          Top = 124
          TabOrder = 2
          Width = 145
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = #26085#26399
        ImageIndex = 1
        object Label4: TLabel
          Left = 346
          Top = 128
          Width = 68
          Height = 24
          AutoSize = False
          Caption = #26368#22823
        end
        object Label5: TLabel
          Left = 58
          Top = 128
          Width = 68
          Height = 24
          AutoSize = False
          Caption = #26368#23567
        end
        object Label8: TLabel
          Left = 76
          Top = 172
          Width = 223
          Height = 24
          AutoSize = False
          Caption = #26085#26399#26684#24335#65306'2012-01-01'
          Font.Charset = GB2312_CHARSET
          Font.Color = clRed
          Font.Height = -22
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object rg_datetime: TcxRadioGroup
          Left = 51
          Top = 21
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
          Height = 67
          Width = 536
        end
        object medt_date_max: TcxMaskEdit
          Left = 432
          Top = 124
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]-(0?[1-9] | 1[012])- ([012]?[1-9] | [123' +
            ']0 |31)'
          Properties.MaxLength = 0
          TabOrder = 1
          Width = 145
        end
        object medt_date_min: TcxMaskEdit
          Left = 144
          Top = 124
          Properties.MaskKind = emkRegExpr
          Properties.EditMask = 
            '([123][0-9])? [0-9][0-9]-(0?[1-9] | 1[012])- ([012]?[1-9] | [123' +
            ']0 |31)'
          Properties.MaxLength = 0
          TabOrder = 2
          Width = 145
        end
      end
      object cxTabSheet3: TcxTabSheet
        Caption = #26522#20030
        ImageIndex = 2
        object Label1: TLabel
          Left = 10
          Top = 10
          Width = 594
          Height = 58
          AutoSize = False
          Caption = #22312#19979#38754#30340#36755#20837#26694#20013#36755#20837#38656#35201#38543#26426#25171#21360#30340#25991#23383#65292#20351#29992'","'#20316#20026#25991#23383#30340#38388#38548#12290
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -22
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object memo_enmu: TcxMemo
          Left = 0
          Top = 76
          Align = alBottom
          TabOrder = 0
          Height = 157
          Width = 688
        end
      end
    end
    object edt_item_name: TcxTextEdit
      Left = 147
      Top = 38
      TabOrder = 0
      Text = 'edt_item_name'
      Width = 365
    end
    object rg_master: TcxRadioGroup
      Left = 137
      Top = 89
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
      Height = 47
      Width = 373
    end
  end
end
