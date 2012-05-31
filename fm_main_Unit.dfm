object frm_main: Tfrm_main
  Left = 217
  Top = 198
  Width = 952
  Height = 656
  Caption = #32508#21512
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object dxStatusBar1: TdxStatusBar
    Left = 0
    Top = 605
    Width = 944
    Height = 17
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Width = 120
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
  end
  object cxPageControl1: TcxPageControl
    Left = 239
    Top = 55
    Width = 705
    Height = 550
    ActivePage = cxTabSheet1
    Align = alClient
    TabOrder = 2
    ClientRectBottom = 550
    ClientRectRight = 705
    ClientRectTop = 28
    object cxTabSheet1: TcxTabSheet
      Caption = #21464#37327
      ImageIndex = 0
      object cxGroupBox4: TcxGroupBox
        Left = 0
        Top = 0
        Align = alTop
        TabOrder = 0
        Height = 48
        Width = 705
        object cxButton3: TcxButton
          Left = 411
          Top = 14
          Width = 63
          Height = 21
          Caption = #21024
          TabOrder = 1
          OnClick = cxButton3Click
        end
        object cxButton4: TcxButton
          Left = 347
          Top = 14
          Width = 64
          Height = 21
          Caption = #28155
          TabOrder = 0
          OnClick = cxButton4Click
        end
        object cxButton5: TcxButton
          Left = 474
          Top = 14
          Width = 64
          Height = 21
          Caption = #35774
          TabOrder = 2
          OnClick = cxButton5Click
        end
      end
      object lv_attrib: TcxListView
        Left = 0
        Top = 48
        Width = 705
        Height = 474
        Align = alClient
        Columns = <
          item
            Caption = #21464#37327#21517#31216
            Width = 102
          end
          item
            Caption = #21464#37327#31867#22411
            Width = 102
          end
          item
            Caption = #26368#22823#20540
            Width = 102
          end
          item
            Caption = #26368#23567#20540
            Width = 102
          end>
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = #29983#25104
      ImageIndex = 1
      object cxGroupBox3: TcxGroupBox
        Left = 0
        Top = 0
        Align = alTop
        TabOrder = 0
        Height = 48
        Width = 705
        object Label1: TLabel
          Left = 27
          Top = 20
          Width = 83
          Height = 17
          AutoSize = False
          Caption = #25171#21360#20221#25968
        end
        object cxButton1: TcxButton
          Left = 483
          Top = 18
          Width = 64
          Height = 21
          Caption = #25171#21360
          TabOrder = 2
          OnClick = cxButton1Click
        end
        object cxButton2: TcxButton
          Left = 415
          Top = 18
          Width = 64
          Height = 21
          Caption = #29983#25104
          TabOrder = 1
          OnClick = cxButton2Click
        end
        object sedt_rowcount: TcxSpinEdit
          Left = 122
          Top = 17
          TabOrder = 0
          Value = 1
          Width = 103
        end
      end
      object cxGrid1: TcxGrid
        Left = 0
        Top = 48
        Width = 705
        Height = 474
        Align = alClient
        TabOrder = 1
        object cxGrid1DBTableView1: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          DataController.DataSource = DataSource1
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.ColumnAutoWidth = True
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
    Height = 55
    Width = 944
    object cxButton7: TcxButton
      Left = 714
      Top = 20
      Width = 64
      Height = 22
      Caption = #20851
      TabOrder = 0
      OnClick = cxButton7Click
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 0
    Top = 55
    Align = alLeft
    Caption = #25253#34920
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -15
    Style.Font.Name = 'MS Sans Serif'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 1
    Height = 550
    Width = 239
    object cxGroupBox5: TcxGroupBox
      Left = 2
      Top = 23
      Align = alTop
      TabOrder = 0
      Height = 44
      Width = 235
      object cxButton6: TcxButton
        Left = 94
        Top = 14
        Width = 64
        Height = 21
        Caption = #28155
        TabOrder = 0
        OnClick = cxButton6Click
      end
      object cxButton8: TcxButton
        Left = 158
        Top = 14
        Width = 64
        Height = 21
        Caption = #21024
        TabOrder = 1
        OnClick = cxButton8Click
      end
    end
    object lv_reportlist: TcxListView
      Left = 2
      Top = 67
      Width = 235
      Height = 481
      Align = alClient
      Columns = <
        item
          Width = 43
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = lv_reportlistDblClick
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
    PixelsPerInch = 96
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
  object DataSource1: TDataSource
    Left = 184
    Top = 24
  end
end
