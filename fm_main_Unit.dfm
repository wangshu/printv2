object frm_main: Tfrm_main
  Left = 234
  Top = 231
  Width = 952
  Height = 656
  Caption = 'frm_main'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object dxStatusBar1: TdxStatusBar
    Left = 0
    Top = 591
    Width = 934
    Height = 20
    Panels = <>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object cxPageControl1: TcxPageControl
    Left = 281
    Top = 65
    Width = 653
    Height = 526
    ActivePage = cxTabSheet2
    Align = alClient
    TabOrder = 2
    ClientRectBottom = 526
    ClientRectRight = 653
    ClientRectTop = 31
    object cxTabSheet1: TcxTabSheet
      Caption = #21464#37327#32534#36753
      ImageIndex = 0
      object cxGroupBox4: TcxGroupBox
        Left = 0
        Top = 0
        Align = alTop
        TabOrder = 0
        Height = 57
        Width = 653
        object cxButton3: TcxButton
          Left = 483
          Top = 16
          Width = 75
          Height = 25
          Caption = #21024#38500
          TabOrder = 1
          OnClick = cxButton3Click
        end
        object cxButton4: TcxButton
          Left = 408
          Top = 16
          Width = 75
          Height = 25
          Caption = #28155#21152
          TabOrder = 0
          OnClick = cxButton4Click
        end
        object cxButton5: TcxButton
          Left = 558
          Top = 16
          Width = 75
          Height = 25
          Caption = #35774#35745
          TabOrder = 2
          OnClick = cxButton5Click
        end
      end
      object lv_attrib: TcxListView
        Left = 0
        Top = 57
        Width = 653
        Height = 438
        Align = alClient
        Columns = <
          item
            Caption = #21464#37327#21517#31216
            Width = 120
          end
          item
            Caption = #21464#37327#31867#22411
            Width = 120
          end
          item
            Caption = #26368#22823#20540
            Width = 120
          end
          item
            Caption = #26368#23567#20540
            Width = 120
          end>
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = #29983#25104#25968#25454
      ImageIndex = 1
      object cxGroupBox3: TcxGroupBox
        Left = 0
        Top = 0
        Align = alTop
        TabOrder = 0
        Height = 57
        Width = 653
        object Label1: TLabel
          Left = 32
          Top = 24
          Width = 97
          Height = 20
          AutoSize = False
          Caption = #25171#21360#20221#25968
        end
        object cxButton1: TcxButton
          Left = 568
          Top = 21
          Width = 75
          Height = 25
          Caption = #25171#21360
          TabOrder = 2
        end
        object cxButton2: TcxButton
          Left = 488
          Top = 21
          Width = 75
          Height = 25
          Caption = #29983#25104
          TabOrder = 1
        end
        object cxSpinEdit1: TcxSpinEdit
          Left = 144
          Top = 20
          TabOrder = 0
          Width = 121
        end
      end
      object cxGrid1: TcxGrid
        Left = 0
        Top = 57
        Width = 653
        Height = 438
        Align = alClient
        TabOrder = 1
        object cxGrid1DBTableView1: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGrid1DBTableView1
        end
      end
    end
  end
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 0
    Align = alTop
    TabOrder = 0
    Height = 65
    Width = 934
    object cxButton7: TcxButton
      Left = 840
      Top = 24
      Width = 75
      Height = 25
      Caption = #20851#20110
      TabOrder = 0
      OnClick = cxButton7Click
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 65
    Align = alLeft
    Caption = #25253#34920#21015#34920
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -17
    Style.Font.Name = 'MS Sans Serif'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 1
    Height = 526
    Width = 281
    object cxGroupBox5: TcxGroupBox
      Left = 2
      Top = 25
      Align = alTop
      TabOrder = 0
      Height = 52
      Width = 277
      object cxButton6: TcxButton
        Left = 111
        Top = 16
        Width = 75
        Height = 25
        Caption = #28155#21152
        TabOrder = 0
        OnClick = cxButton6Click
      end
      object cxButton8: TcxButton
        Left = 186
        Top = 16
        Width = 75
        Height = 25
        Caption = #21024#38500
        TabOrder = 1
        OnClick = cxButton8Click
      end
    end
    object lv_reportlist: TcxListView
      Left = 2
      Top = 77
      Width = 277
      Height = 447
      Align = alClient
      Columns = <
        item
        end>
      TabOrder = 1
      ViewStyle = vsReport
      OnSelectItem = lv_reportlistSelectItem
    end
  end
  object RMReport1: TRMReport
    ThreadPrepareReport = True
    InitialZoom = pzDefault
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbPageSetup, pbExit, pbExport, pbNavigator]
    DefaultCollate = False
    SaveReportOptions.RegistryPath = 'Software\ReportMachine\ReportSettings\'
    PreviewOptions.RulerUnit = rmutScreenPixels
    PreviewOptions.RulerVisible = False
    PreviewOptions.DrawBorder = False
    PreviewOptions.BorderPen.Color = clGray
    PreviewOptions.BorderPen.Style = psDash
    Dataset = RMDBDataSet1
    CompressLevel = rmzcFastest
    CompressThread = False
    LaterBuildEvents = True
    OnlyOwnerDataSet = False
    Left = 144
    Top = 16
    ReportData = {}
  end
  object RMDesigner1: TRMDesigner
    DesignerRestrictions = []
    Left = 16
    Top = 16
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 48
    Top = 16
    PixelsPerInch = 120
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    Left = 16
    Top = 16
  end
  object RMDBDataSet1: TRMDBDataSet
    Visible = True
    DataSet = dxMemData
    Left = 112
    Top = 16
  end
  object dxMemData: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 80
    Top = 16
  end
end
