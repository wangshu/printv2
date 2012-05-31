unit fm_main_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsDefaultPainters, dxSkinsdxStatusBarPainter,
  dxSkinscxPCPainter, cxContainer, cxEdit, Menus, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridBandedTableView,
  cxTextEdit, cxMaskEdit, cxSpinEdit, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, NativeXml,
  cxGridDBTableView, cxGrid, StdCtrls, cxButtons, cxPC, cxGroupBox,
  dxStatusBar, RM_Class, RM_Designer, RM_System, RM_Common, ComCtrls,
  cxPropertiesStore, cxListView, dxmdaset, RM_Dataset, Grids, DBGrids;

type
  Tfrm_main = class(TForm)
    RMReport1: TRMReport;
    RMDesigner1: TRMDesigner;
    dxStatusBar1: TdxStatusBar;
    cxPageControl1: TcxPageControl;
    cxGroupBox1: TcxGroupBox;
    cxGroupBox2: TcxGroupBox;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxGroupBox3: TcxGroupBox;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    sedt_rowcount: TcxSpinEdit;
    cxGroupBox4: TcxGroupBox;
    cxButton3: TcxButton;
    cxButton4: TcxButton;
    cxButton5: TcxButton;
    cxButton7: TcxButton;
    cxGroupBox5: TcxGroupBox;
    lv_reportlist: TcxListView;
    cxStyleRepository1: TcxStyleRepository;
    cxPropertiesStore1: TcxPropertiesStore;
    cxButton6: TcxButton;
    cxButton8: TcxButton;
    Label1: TLabel;
    lv_attrib: TcxListView;
    RMDBDataSet1: TRMDBDataSet;
    dxMemData: TdxMemData;
    DataSource1: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure cxButton7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lv_reportlistSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cxButton8Click(Sender: TObject);
    procedure cxButton6Click(Sender: TObject);
    procedure cxButton4Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure cxButton5Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure lv_reportlistDblClick(Sender: TObject);
    procedure RMDesigner1SaveReport(Report: TRMReport;
      var ReportName: String; SaveAs: Boolean; var Saved: Boolean);
  private
    { Private declarations }
    xmlfile: string;
    selectnode: TXmlNode;
    xml: TNativeXml;
    procedure RefreshReportList;
    procedure RefreshAttribList;
    procedure initDataset;
    function getvalue(node: TXmlNode): Variant;
  public
    { Public declarations }
  end;

var
  frm_main: Tfrm_main;

implementation

uses frm_Authorization_Unit, frm_about_Unit, Symbol_Unit,
  frm_printInfo_Unit, frm_attribInfoUnit, Comm_Unit, Math;

{$R *.dfm}

procedure Tfrm_main.FormShow(Sender: TObject);
begin

  frm_Authorization := Tfrm_Authorization.Create(self);
  if frm_Authorization.ShowModal = mrOk then
  begin
    cxGroupBox5.Enabled := true;
    cxGroupBox4.Enabled := true;
  end
  else
  begin
    cxGroupBox5.Enabled := False   ;
    cxGroupBox4.Enabled := False   ;
    dxStatusBar1.Font.Color:=clRed;
        dxStatusBar1.Panels[0].Text:='未注册版本';
  end;
  frm_Authorization.Timer1.Enabled:=false;
  frm_Authorization.Free;
  RefreshReportList;
  lv_reportlist.Column[0].Width := lv_reportlist.Width - 5;

end;

procedure Tfrm_main.cxButton7Click(Sender: TObject);
begin
  AboutBox := TAboutBox.Create(self);
  AboutBox.ShowModal;
end;

procedure Tfrm_main.FormCreate(Sender: TObject);
begin
  try
    xml := TNativeXml.Create;
    xmlfile := ExtractFilePath(Application.ExeName) + CONFIG_FILE;
    xml.LoadFromFile(xmlfile);
  except
    Application.MessageBox('配置文件读取失败，程序即将退出！', '系统提示', MB_OK);
    Application.Terminate;
  end;
end;

procedure Tfrm_main.lv_reportlistSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (lv_reportlist.Selected <> nil) then
  begin
    selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index];
    RefreshAttribList;
  end;
  cxPageControl1.ActivePageIndex := 0;
end;

procedure Tfrm_main.cxButton8Click(Sender: TObject);
begin
  xml.Root.NodeDelete(lv_reportlist.Selected.Index);

  RefreshReportList;
end;

procedure Tfrm_main.RefreshReportList;
var
  i: Integer;
  item: TListItem;
begin
  cxPageControl1.ActivePageIndex := 0;
  xml.SaveToFile(xmlfile);
  xml.LoadFromFile(xmlfile);
  lv_reportlist.Items.Clear;
  if xml.Root.NodeCount > 0 then
  begin
    for i := 0 to xml.Root.NodeCount - 1 do
    begin
      item := lv_reportlist.Items.Add;

      item.Caption := xml.Root.Nodes[i].AttributeByName[REPORT_TITLE];
    end;
  end;
  ;
end;

procedure Tfrm_main.RefreshAttribList;
var
  i: Integer;
  item: TListItem;
  node: TXmlNode;
begin
  if (lv_reportlist.Selected <> nil) then
  begin
    cxPageControl1.ActivePageIndex := 0;
    xml.SaveToFile(xmlfile);
    xml.LoadFromFile(xmlfile);
    lv_attrib.Items.Clear;

    if xml.Root.Nodes[lv_reportlist.Selected.Index].NodeCount > 0 then
    begin
      for i := 0 to xml.Root.Nodes[lv_reportlist.Selected.Index].NodeCount - 1 do
      begin
        node := xml.Root.Nodes[lv_reportlist.Selected.Index].Nodes[i];
        item := lv_attrib.Items.Add;

        item.Caption := node.AttributeByName[ITEM_TITLE];
        item.SubItems.Add(node.AttributeByName[ITEM_TYPE]);
        if node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_INTEGER then
        begin
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MAX]);
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MIN]);


        end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DOUBLE then
        begin
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MAX]);
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MIN]);

        end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DATE then
        begin
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MAX]);
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MIN]);

        end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DATETIME then
        begin
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MAX]);
          item.SubItems.Add(node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MIN]);

        end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_TIME then
        begin

        end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_ENMU then
        begin

        end

      end;
    end;
    ;
  end;
end;


procedure Tfrm_main.cxButton6Click(Sender: TObject);
var
  node: TXmlNode;
begin
  node := TXmlNode.Create(xml);
  frm_printInfo := Tfrm_printInfo.Create(self);
  frm_printInfo.node := node;
  if frm_printInfo.ShowModal = mrok then
  begin
    node.Name := REPORT_NODE_NAME;
    xml.Root.NodeInsert(0, node);
    RefreshReportList;

  end
  else
  begin
    node.Free;
  end;
end;

procedure Tfrm_main.cxButton4Click(Sender: TObject);
var
  node: TXmlNode;
begin
  if lv_reportlist.Selected <> nil then
  begin
    frm_attribInfo := Tfrm_attribInfo.Create(self);
    node := xml.Root.Nodes[lv_reportlist.Selected.Index].NodeNew(ITEM_NODE_NAME);

    frm_attribInfo.node := node;

    if frm_attribInfo.ShowModal = mrok then
    begin



      RefreshAttribList;
    end else
    begin
      node.Free;
    end;
  end;

end;

procedure Tfrm_main.cxButton3Click(Sender: TObject);
begin
  if lv_reportlist.Selected <> nil then
  begin
    xml.Root.Nodes[lv_reportlist.Selected.Index].Nodes[lv_attrib.ItemIndex].Delete;
    RefreshAttribList;
  end;

end;

procedure Tfrm_main.initDataset;
var
  str_field: TStringField;
  float_field: TFloatField;
  int_field: TIntegerField;
  i: integer;
begin
  DataSource1.DataSet := nil;
  self.dxMemData.Close;
  with dxMemData do begin
    Close;
    for I := FieldCount - 1 downto 1 do // do not delete RecId
      Fields[I].Free;
    Open;
    Close;
    FieldDefs.Clear;
    FieldDefs.BeginUpdate;
    selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index];
    for i := 0 to selectnode.NodeCount - 1 do
    begin
      if (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_ENMU) or
        (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_DATETIME) or
        (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_DATE) or
        (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_TIME)
        then
      begin
        str_field := TStringField.Create(dxMemData);
        str_field.FieldName := selectnode.Nodes[i].AttributeByName[ITEM_TITLE];
        str_field.size := 50;
        str_field.DataSet := dxMemData
      end
      else
        if (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_INTEGER) then
        begin
          int_field := TIntegerField.Create(dxMemData);
          int_field.FieldName := selectnode.Nodes[i].AttributeByName[ITEM_TITLE];
          int_field.DataSet := dxMemData
        end else if (selectnode.Nodes[i].AttributeByName[ITEM_TYPE] = ITEM_TYPE_DOUBLE) then
        begin
          float_field := TFloatField.Create(dxMemData);
          float_field.FieldName := selectnode.Nodes[i].AttributeByName[ITEM_TITLE];

          float_field.DataSet := dxMemData
        end;

    end;
    FieldDefs.EndUpdate;
  end;
end;

procedure Tfrm_main.cxButton5Click(Sender: TObject);
var
  i: integer;
begin
  selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index];
  initDataset;
  self.dxMemData.Open;
  self.dxMemData.Append;

  self.dxMemData.Post;
  self.RMReport1.LoadFromFile(ExtractFilePath(Application.ExeName) + selectnode.AttributeByName[REPORT_FILE_NAME]);
  self.RMReport1.DesignReport;
 // (self.RMReport1.Pages[0] as TRMReportPage).PageWidth := StrToInt(selectnode.AttributeByName[REPORT_WIDTH]);
  //(self.RMReport1.Pages[0] as TRMReportPage).PageHeight := StrToInt(selectnode.AttributeByName[REPORT_HEIGHT]);
  self.RMReport1.SaveToFile(self.RMReport1.FileName);


end;

procedure Tfrm_main.cxButton2Click(Sender: TObject);
var
  i, j: integer;
begin
  selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index];
  initDataset;
  
   dxMemData.Open;
  for i := 0 to sedt_rowcount.Value - 1 do
  begin
    dxMemData.Append;
    for j := 0 to selectnode.NodeCount - 1 do
    begin
      dxMemData.FieldByName(selectnode.Nodes[j].AttributeByName[ITEM_TITLE]).Value := getvalue(selectnode.Nodes[j]);

    end;
    dxMemData.Post;
  end;
  DataSource1.DataSet := dxMemData;
      (cxGrid1DBTableView1.DataController as IcxCustomGridDataController).DeleteAllItems;
    (cxGrid1DBTableView1.DataController as IcxCustomGridDataController).CreateAllItems(False);
end;

function Tfrm_main.getvalue(node: TXmlNode): Variant;
var
   Strs:TStrings;
begin
  if (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_ENMU) then
  begin
    Strs:=TStringList.Create;
    Strs.Text:=StringReplace(node.AttributeByName[ITEM_TYPE_ENMU_ITEMS],',',#13,[rfReplaceAll]);
     Result:=Strs.Strings[random(Strs.Count)];
    Strs.Free;

  end else if
    (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_DATETIME) then
  begin
    Result := randomDatetime(node.AttributeByName[ITEM_TYPE_DATETIME_MIN], node.AttributeByName[ITEM_TYPE_DATETIME_MAX])
  end else if
    (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_DATE) then
  begin
    Result := RandomDate(node.AttributeByName[ITEM_TYPE_DATE_MIN], node.AttributeByName[ITEM_TYPE_DATE_MAX],'')
  end else if
    (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_TIME) then
  begin
    Result := RandomTime('hh:mm:ss')
  end else if (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_INTEGER) then
  begin
    Result := RandomInt(StrToInt(node.AttributeByName[ITEM_TYPE_INTEGER_MIN])  , StrToInt(node.AttributeByName[ITEM_TYPE_INTEGER_MAX]), '0');
  end else if (node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_DOUBLE) then
  begin
    Result := RandomInt(StrToInt(node.AttributeByName[ITEM_TYPE_DOUBLE_MIN])  , StrToInt(node.AttributeByName[ITEM_TYPE_DOUBLE_MAX]), '0.00');
  end;

end;
procedure Tfrm_main.cxButton1Click(Sender: TObject);
begin
  if(cxGrid1DBTableView1.ViewData.RowCount>0 ) then
  begin
  selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index];
    self.RMReport1.LoadFromFile(ExtractFilePath(Application.ExeName) + selectnode.AttributeByName[REPORT_FILE_NAME]);
  self.RMReport1.ShowReport;;
  end
  else
  begin
    application.MessageBox('请先生成数据后再进行打印操作！','系统提示',MB_OK)
  end;
end;

procedure Tfrm_main.lv_reportlistDblClick(Sender: TObject);
begin
 if (lv_reportlist.Selected <> nil) then
  begin
 frm_printInfo := Tfrm_printInfo.Create(self);
  frm_printInfo.node := xml.Root.Nodes[lv_reportlist.Selected.Index];;
  if frm_printInfo.ShowModal = mrok then
  begin
            RefreshReportList;

  end
  else
  begin
  xml.LoadFromFile(self.xmlfile);
  end;
     frm_printInfo.Free;
 end;
  cxPageControl1.ActivePageIndex := 0;
end;

procedure Tfrm_main.RMDesigner1SaveReport(Report: TRMReport;
  var ReportName: String; SaveAs: Boolean; var Saved: Boolean);
begin
     selectnode := xml.Root.Nodes[lv_reportlist.Selected.Index]; 
  (Report.Pages[0] as TRMReportPage).PageWidth := StrToInt(selectnode.AttributeByName[REPORT_WIDTH]);
  (Report.Pages[0] as TRMReportPage).PageHeight := StrToInt(selectnode.AttributeByName[REPORT_HEIGHT]);
end;

end.

