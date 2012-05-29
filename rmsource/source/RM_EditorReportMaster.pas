unit RM_EditorReportMaster;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, RM_Common, RM_Class, RM_ReportMaster, Buttons,
  RM_DataSet, RM_GridReport, RM_Ctrls;

type

  TRMFormReportMaster = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    memTitle: TMemo;
    GroupBox2: TGroupBox;
    memCaptionLeft: TMemo;
    memCaptionCenter: TMemo;
    memCaptionRight: TMemo;
    FontDialog1: TFontDialog;
    Panel2: TPanel;
    GroupBox4: TGroupBox;
    memFooterLeft: TMemo;
    memFooterCenter: TMemo;
    memFooterRight: TMemo;
    GroupBox3: TGroupBox;
    memHeaderLeft: TMemo;
    memHeaderCenter: TMemo;
    memHeaderRight: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    tabReportDefine: TTabSheet;
    Panel3: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    edtTitleCaption: TEdit;
    cmbFields: TComboBox;
    Panel4: TPanel;
    btnLoad: TButton;
    btnSave: TButton;
    SpeedButton1: TSpeedButton;
    ColorDialog1: TColorDialog;
    btnDisplayFormat: TSpeedButton;
    Label7: TLabel;
    SpeedButton2: TSpeedButton;
    trvReportData: TTreeView;
    btnNewColumn: TSpeedButton;
    btnNewSubColumn: TSpeedButton;
    btnUpMove: TSpeedButton;
    btnDownMove: TSpeedButton;
    btnUpLevel: TSpeedButton;
    btnDownLevel: TSpeedButton;
    btnDeleteColumn: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Bevel1: TBevel;
    Label16: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Panel7: TPanel;
    Label12: TLabel;
    Bevel2: TBevel;
    Label17: TLabel;
    Label11: TLabel;
    Label8: TLabel;
    Panel5: TPanel;
    edtWidth: TEdit;
    Label23: TLabel;
    Label13: TLabel;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox1: TCheckBox;
    Label10: TLabel;
    Label9: TLabel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Bevel3: TBevel;
    Label18: TLabel;
    cmbDataHAlign: TComboBox;
    cmbDataVAlign: TComboBox;
    cmbTitleHAlign: TComboBox;
    cmbTitleVAlign: TComboBox;
    tabDataSet: TTabSheet;
    Panel8: TPanel;
    lstDataSets: TListBox;
    GroupBox5: TGroupBox;
    pnlDefaultFont: TPanel;
    Label19: TLabel;
    chkAutoAppendBlank: TCheckBox;
    chkAutoHCenter: TCheckBox;
    procedure Label1Click(Sender: TObject);
    procedure memTitleDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNewColumnClick(Sender: TObject);
    procedure btnNewSubColumnClick(Sender: TObject);
    procedure btnDeleteColumnClick(Sender: TObject);
    procedure trvReportDataChange(Sender: TObject; Node: TTreeNode);
    procedure btnUpMoveClick(Sender: TObject);
    procedure btnDownMoveClick(Sender: TObject);
    procedure btnUpLevelClick(Sender: TObject);
    procedure btnDownLevelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure trvReportDataChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Panel5Click(Sender: TObject);
    procedure trvReportDataExit(Sender: TObject);
    procedure btnDisplayFormatClick(Sender: TObject);
    procedure edtTitleCaptionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnOKClick(Sender: TObject);
    procedure cmbFieldsClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure lstDataSetsClick(Sender: TObject);
  private
    { Private declarations }
    FCurNode: TTreeNode;
    FCanRefresh: Boolean;
    FReportMaster: TRMCustomReportMaster;

    FbtnDataColor: TRMColorPickerButton;
    FbtnTitleColor: TRMColorPickerButton;

    procedure DeleteOneNode(aParentNode: TTreeNode);
    procedure ClearTreeInfo;
    procedure Localize;
    procedure GetNodeData;
    procedure SetNodeData;
    procedure LoadFromTreeView;
    procedure SaveToTreeView;
  public
    { Public declarations }
    function Execute(aReportMaster: TRMCustomReportMaster): Boolean;
  end;

implementation

uses
  RM_Utils, RM_Const, RM_Const1, RM_EditorMemo, RM_EditorExpr, RM_EditorFormat;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMFormReportMaster }

type
  THackTRMTreeItem = class(TRMColumnInfo)
  end;

function TRMFormReportMaster.Execute(aReportMaster: TRMCustomReportMaster): Boolean;
var
	lSaveDataSet: TRMDataSet;
begin
  FReportMaster := aReportMaster;
	lSaveDataSet := FReportMaster.DataSet;
  FCanRefresh := False;

  pnlDefaultFont.Font.Assign(FReportMaster.DefaultFont);
  chkAutoAppendBlank.Checked := FReportMaster.AutoAppendBlank;
  chkAutoHCenter.Checked := FReportMaster.AutoHCenter;
  SaveToTreeView;

  Result := (ShowModal = mrOK);
  if Result then
  begin
  	FReportMaster.DefaultFont := pnlDefaultFont.Font;
	  FReportMaster.AutoAppendBlank := chkAutoAppendBlank.Checked;
  	FReportMaster.AutoHCenter := chkAutoHCenter.Checked;
    LoadFromTreeView;
  end
  else
  	FReportMaster.DataSet := lSaveDataSet;
end;

procedure TRMFormReportMaster.LoadFromTreeView; // 读入TTreeView中的信息

  procedure _LoadFromTreeNode(aNode: TTreeNode; aParentNode: TRMTreeNode);
  var
    lNode: TRMTreeNode;
  begin
    while aNode <> nil do
    begin
      lNode := FReportMaster.ReportDataTree.AddChild(aParentNode, '');
      lNode.ColumnInfo.Assign(aNode.Data);
      if aNode.Count > 0 then
        _LoadFromTreeNode(aNode[0], lNode);

      aNode := aNode.getNextSibling;
    end;
  end;

begin
  FReportMaster.ReportDataTree.Clear;
  if trvReportData.Items.Count > 0 then
    _LoadFromTreeNode(trvReportData.Items[0], nil);
end;

procedure TRMFormReportMaster.SaveToTreeView; // 将信息保存倒TTreeView中

  procedure _SaveToTreeNode(aNode: TRMTreeNode; aParentTreeNode: TTreeNode);
  var
    lTreeNode: TTreeNode;
    lNodeInfo: TRMColumnInfo;
  begin
    while aNode <> nil do
    begin
      lNodeInfo := TRMColumnInfo.Create;
      lNodeInfo.Assign(aNode.ColumnInfo);
      lTreeNode := trvReportData.Items.AddChildObject(aParentTreeNode, lNodeInfo.TitleCaption, lNodeInfo);
      if aNode.Count > 0 then
        _SaveToTreeNode(aNode[0], lTreeNode);

      aNode := aNode.GetNextSibling;
    end;
  end;

begin
  FCanRefresh := False;
  try
    ClearTreeInfo;
    if FReportMaster.ReportDataTree.Count > 0 then
      _SaveToTreeNode(FReportMaster.ReportDataTree.Items[0], nil);
  finally
    FCanRefresh := True;
  end;
end;

procedure TRMFormReportMaster.GetNodeData;
var
  lNodeData: TRMColumnInfo;
begin
  lNodeData := TRMColumnInfo(FCurNode.Data);

  cmbFields.Text := lNodeData.DataFieldName;
  cmbDataHAlign.ItemIndex := Byte(lNodeData.DataHAlign);
  cmbDataVAlign.ItemIndex := BYte(lNodeData.DataVAlign);
  Panel7.Font.Assign(lNodeData.DataFont);
  FBtnDataColor.CurrentColor := lNodeData.DataFillColor;

  edtTitleCaption.Text := lNodeData.TitleCaption;
  cmbTitleHAlign.ItemIndex := Byte(lNodeData.TitleHAlign);
  cmbTitleVAlign.ItemIndex := BYte(lNodeData.TitleVAlign);
  Panel5.Font.Assign(lNodeData.TitleFont);
  FBtnTitleColor.CurrentColor := lNodeData.TitleFillColor;

  edtWidth.Text := IntToStr(lNodeData.Width);
end;

procedure TRMFormReportMaster.SetNodeData;
var
  lNodeData: TRMColumnInfo;
begin
  lNodeData := TRMColumnInfo(FCurNode.Data);
  if edtTitleCaption.Text = '' then
    FCurNode.Text := '???'
  else
  begin
    FCurNode.Text := edtTitleCaption.Text;
  end;

  lNodeData.TitleCaption := FCurNode.Text;
  lNodeData.TitleHAlign := TRMHAlign(cmbTitleHAlign.ItemIndex);
  lNodeData.TitleVAlign := TRMVAlign(cmbTitleVAlign.ItemIndex);
  lNodeData.TitleFont.Assign(Panel5.Font);
  lNodeData.TitleFillColor := FBtnTitleColor.CurrentColor;

  lNodeData.DataFieldName := cmbFields.Text;
  lNodeData.DataHAlign := TRMHAlign(cmbDataHAlign.ItemIndex);
  lNodeData.DataVAlign := TRMVAlign(cmbDataVAlign.ItemIndex);
  lNodeData.DataFont.Assign(Panel7.Font);
  lNodeData.DataFillColor := FBtnDataColor.CurrentColor;

  lNodeData.Width := StrToInt(edtWidth.Text);
end;

procedure TRMFormReportMaster.DeleteOneNode(aParentNode: TTreeNode);
var
  lNode, lNode1: TTreeNode;
begin
  lNode := aParentNode.getFirstChild;
  while lNode <> nil do
  begin
    lNode1 := aParentNode.GetNextChild(lNode);
    DeleteOneNode(lNode);
    lNode := lNode1;
  end;

  if aParentNode.Data <> nil then
  begin
    TRMColumnInfo(aParentNode.Data).Free;
    aParentNode.Data := nil;
  end;
  aParentNode.Delete;
end;

procedure TRMFormReportMaster.ClearTreeInfo;
var
  i, lCount: Integer;
  lNode: TTreeNode;
begin
  lCount := trvReportData.Items.Count;
  trvReportData.Items.BeginUpdate;
  try
    for i := 0 to lCount - 1 do
    begin
      lNode := trvReportData.Items[i];
      if lNode.Data <> nil then
      begin
        TRMColumnInfo(lNode.Data).Free;
        lNode.Data := nil;
      end;
    end;
  finally
    trvReportData.Items.Clear;
    trvReportData.Items.EndUpdate;
  end;
end;

procedure TRMFormReportMaster.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(TabSheet1, 'Caption', rmRes + 867);
  RMSetStrProp(Label3, 'Caption', rmRes + 868);
  RMSetStrProp(Label4, 'Caption', rmRes + 869);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 870);
  RMSetStrProp(Label1, 'Caption', rmRes + 871);
  RMSetStrProp(Label2, 'Caption', rmRes + 872);

  RMSetStrProp(tabDataSet, 'Caption', rmRes + 886);
  RMSetStrProp(GroupBox5, 'Caption', rmRes + 887);
  RMSetStrProp(Label19, 'Caption', rmRes + 888);
  RMSetStrProp(chkAutoAppendBlank, 'Caption', rmRes + 889);
  RMSetStrProp(chkAutoHCenter, 'Caption', rmRes + 890);

  RMSetStrProp(tabReportDefine, 'Caption', rmRes + 891);
  RMSetStrProp(Label7, 'Caption', rmRes + 891);
  RMSetStrProp(btnNewColumn, 'Caption', rmRes + 892);
  RMSetStrProp(btnDeleteColumn, 'Caption', rmRes + 893);
  RMSetStrProp(btnNewSubColumn, 'Caption', rmRes + 894);
  RMSetStrProp(btnUpMove, 'Hint', rmRes + 909);
  RMSetStrProp(btnDownMove, 'Hint', rmRes + 910);
  RMSetStrProp(btnUpLevel, 'Hint', rmRes + 911);
  RMSetStrProp(btnDownLevel, 'Hint', rmRes + 912);
  RMSetStrProp(Label5, 'Caption', rmRes + 895);
  RMSetStrProp(Label6, 'Caption', rmRes + 896);
  RMSetStrProp(Label16, 'Caption', rmRes + 897);
  RMSetStrProp(Label11, 'Caption', rmRes + 898);
  RMSetStrProp(Label14, 'Caption', rmRes + 900);
  RMSetStrProp(Label15, 'Caption', rmRes + 888);
  RMSetStrProp(Label12, 'Caption', rmRes + 901);
  RMSetStrProp(Label17, 'Caption', rmRes + 897);
  RMSetStrProp(Label23, 'Caption', rmRes + 900);
  RMSetStrProp(Label8, 'Caption', rmRes + 888);
  RMSetStrProp(Label13, 'Caption', rmRes + 901);
  RMSetStrProp(Label18, 'Caption', rmRes + 902);
  RMSetStrProp(Label9, 'Caption', rmRes + 903);
  RMSetStrProp(Label10, 'Caption', rmRes + 904);
  RMSetStrProp(CheckBox1, 'Caption', rmRes + 905);
  RMSetStrProp(CheckBox2, 'Caption', rmRes + 906);
  RMSetStrProp(CheckBox3, 'Caption', rmRes + 907);
  RMSetStrProp(CheckBox4, 'Caption', rmRes + 908);

  RMSetStrProp(Self, 'Caption', rmRes + 873);
  RMSetStrProp(btnOK, 'Caption', SOK);
  RMSetStrProp(btnCancel, 'Caption', SCancel);
end;

procedure TRMFormReportMaster.Label1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    if Sender = Label1 then
      memTitle.Font.Assign(FontDialog1.Font)
    else if Sender = Label2 then
    begin
      memCaptionLeft.Font.Assign(FontDialog1.Font);
      memCaptionCenter.Font.Assign(FontDialog1.Font);
      memCaptionRight.Font.Assign(FontDialog1.Font);
    end
    else if Sender = Label3 then
    begin
      memHeaderLeft.Font.Assign(FontDialog1.Font);
      memHeaderCenter.Font.Assign(FontDialog1.Font);
      memHeaderRight.Font.Assign(FontDialog1.Font);
    end
    else if Sender = Label4 then
    begin
      memFooterLeft.Font.Assign(FontDialog1.Font);
      memFooterCenter.Font.Assign(FontDialog1.Font);
      memFooterRight.Font.Assign(FontDialog1.Font);
    end;
  end;
end;

procedure TRMFormReportMaster.memTitleDblClick(Sender: TObject);
var
  tmp: TRMEditorForm;
begin
  tmp := TRMEditorForm(RMDesigner.EditorForm);
  tmp.Memo.Lines.Assign(TMemo(Sender).Lines);
  if tmp.Execute then
    TMemo(Sender).Lines.Assign(tmp.Memo.Lines);
end;

procedure TRMFormReportMaster.FormCreate(Sender: TObject);
begin
  FCanRefresh := False;
  FCurNode := nil;
  PageControl1.ActivePage := tabDataSet;

  FBtnDataColor := TRMColorPickerButton.Create(Self);
  with FBtnDataColor do
  begin
		Parent := Panel3;
    SetBounds(223, 100, 60, 22);
    ColorType := rmptFill;
//    Flat := False;
  end;
  FBtnTitleColor := TRMColorPickerButton.Create(Self);
  with FBtnTitleColor do
  begin
		Parent := Panel3;
    SetBounds(223, 165, 60, 22);
    ColorType := rmptFill;
//    Flat := False;
  end;

  Localize;
end;

procedure TRMFormReportMaster.btnNewColumnClick(Sender: TObject);
var
  lNode: TTreeNode;
  lNodeInfo: TRMColumnInfo;
begin
  lNodeInfo := TRMColumnInfo.Create;
  lNodeInfo.DataFont.Assign(pnlDefaultFont.Font);
  lNodeInfo.TitleFont.Assign(pnlDefaultFont.Font);

  if FCurNode = nil then
    lNode := trvReportData.Items.AddChildObject(nil, '???', lNodeInfo)
  else
    lNode := trvReportData.Items.AddChildObject(FCurNode.Parent, '???', lNodeInfo);

  lNode.Selected := True;
end;

procedure TRMFormReportMaster.btnNewSubColumnClick(Sender: TObject);
var
  lNode: TTreeNode;
  lNodeP: TRMColumnInfo;
begin
  if FCurNode = nil then Exit; //Add 2002.12.15

  lNodeP := TRMColumnInfo.Create;
  lNode := trvReportData.Items.AddChildObject(FCurNode, '???', lNodeP);
  lNode.Selected := True;
end;

procedure TRMFormReportMaster.btnDeleteColumnClick(Sender: TObject);
begin
  if FCurNode = nil then Exit;

  FCanRefresh := False;
  try
	  DeleteOneNode(FCurNode);
    FCurNode := nil;
  finally
  	FCanRefresh := True;
  end;

  if trvReportData.Items.Count = 0 then
  begin
    FCurNode := nil;
    edtTitleCaption.Clear;
    cmbFields.ItemIndex := -1;
  end
  else
  begin
  	trvReportDataChange(nil, trvReportData.Selected);
  end;
end;

procedure TRMFormReportMaster.trvReportDataChange(Sender: TObject; Node: TTreeNode);
begin
  if not FCanRefresh then Exit;
  FCurNode := Node;

  GetNodeData;
end;

procedure TRMFormReportMaster.btnUpMoveClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  if FCurNode = nil then Exit;

  lNode := FCurNode.getPrevSibling;
  if lNode <> nil then
    FCurNode.MoveTo(lNode, naInsert);
end;

procedure TRMFormReportMaster.btnDownMoveClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  if FCurNode = nil then Exit;

  lNode := FCurNode.getNextSibling;
  if lNode <> nil then
    lNode.MoveTo(FCurNode, naInsert);
end;

procedure TRMFormReportMaster.btnUpLevelClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  if FCurNode = nil then Exit;

  lNode := FCurNode.Parent;
  if lNode <> nil then
  begin
    FCurNode.MoveTo(lNode, naInsert);
    lNode := FCurNode.getNextSibling;
    if lNode <> nil then
    begin
      trvReportData.Items.BeginUpdate;
      try
        lNode.MoveTo(FCurNode, naInsert);
      finally
        trvReportData.Items.EndUpdate;
        trvReportData.FullExpand;
      end;
    end;
  end;
end;

procedure TRMFormReportMaster.btnDownLevelClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  if FCurNode = nil then Exit;

  if FCurNode.HasChildren then Exit;

  lNode := FCurNode.getPrevSibling;
  if (lNode <> nil) {and (lNode.Parent = nil)} then
  begin
    trvReportData.Items.BeginUpdate;
    try
      FCurNode.MoveTo(lNode, naAddChild);
    finally
      trvReportData.Items.EndUpdate;
      trvReportData.FullExpand;
    end;
  end;
end;

procedure TRMFormReportMaster.FormDestroy(Sender: TObject);
begin
  FCanRefresh := False;
  ClearTreeInfo;
end;

procedure TRMFormReportMaster.FormShow(Sender: TObject);

  procedure _GetDataSets;
  begin
    lstDatasets.Items.Clear;

    if FReportMaster.DataSet <> nil then
    begin
      lstDataSets.Items.Add(FReportMaster.DataSet.Name);
    end
    else
    begin
      FReportMaster.Report.Dictionary.GetDataSets(lstDatasets.Items);
    end;

    lstDataSets.ItemIndex := 0;
  end;

begin
  _GetDataSets;

  FCanRefresh := True;
  trvReportData.FullExpand;
end;

procedure TRMFormReportMaster.trvReportDataChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  if (not FCanRefresh) or (FCurNode = nil) then Exit;

  SetNodeData;
end;

procedure TRMFormReportMaster.SpeedButton1Click(Sender: TObject);
var
  lStr: string;
begin
  if FCurNode = nil then Exit;

  lStr := '';
  if RM_EditorExpr.RMGetExpression1('', lStr, nil, False, FReportMaster.Report, FReportMaster.DataSet) then
  begin
    if lStr <> '' then
    begin
      if not ((lStr[1] = '[') and (lStr[Length(lStr)] = ']') and
        (Pos('[', Copy(lStr, 2, 999999)) = 0)) then
        lStr := '[' + lStr + ']';

      cmbFields.Text := lStr;
    end;
  end;
end;

procedure TRMFormReportMaster.Panel5Click(Sender: TObject);
begin
  FontDialog1.Font.Assign(TPanel(Sender).Font);
  if FontDialog1.Execute then
  begin
    TPanel(Sender).Font.Assign(FontDialog1.Font);
  end;
end;

procedure TRMFormReportMaster.trvReportDataExit(Sender: TObject);
var
  lFlag: Boolean;
begin
  trvReportDataChanging(nil, nil, lFlag);
end;

procedure TRMFormReportMaster.btnDisplayFormatClick(Sender: TObject);
var
  tmp: TRMDisplayFormatForm;
  lNodeData: TRMColumnInfo;
begin
  if FCurNode = nil then Exit;

  lNodeData := TRMColumnInfo(FCurNode.Data);
  tmp := TRMDisplayFormatForm.Create(nil);
  try
    tmp.DisplayFormat := THackTRMTreeItem(lNodeData).FormatFlag;
    tmp.DisplayFormatStr := lNodeData.DisplayFormat;
    if tmp.ShowModal = mrOK then
    begin
      THackTRMTreeItem(lNodeData).FormatFlag := tmp.DisplayFormat;
      THackTRMTreeItem(lNodeData).FDisplayFormat := tmp.DisplayFormatStr;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMFormReportMaster.edtTitleCaptionKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SetNodeData;
end;

procedure TRMFormReportMaster.btnOKClick(Sender: TObject);
begin
  if FCurNode <> nil then
    SetNodeData;
end;

procedure TRMFormReportMaster.cmbFieldsClick(Sender: TObject);
begin
  if (edtTitleCaption.Text = '???') or (edtTitleCaption.Text = '') then
  begin
    edtTitleCaption.Text := cmbFields.Text;
  end;
end;

procedure TRMFormReportMaster.btnLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FReportMaster.LoadFromFile(OpenDialog1.FileName);
    SaveToTreeView;
    trvReportData.FullExpand;
  end;
end;

procedure TRMFormReportMaster.btnSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    LoadFromTreeView;
    FReportMaster.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TRMFormReportMaster.lstDataSetsClick(Sender: TObject);
var
  lDataSet: TRMDataSet;
  lStr: string;
begin
  lDataSet := FReportMaster.Report.Dictionary.FindDataSet(lstDataSets.Items[lstDataSets.ItemIndex],
    FReportMaster.Report.Owner, lStr);
//  lComponent := RMFindComponent(FReportMaster.Report.Owner,
//  	FReportMaster.Report.Dictionary.RealDataSetName[lstDataSets.Items[lstDataSets.ItemIndex]]);
  if (lDataSet <> nil) then
    FReportMaster.DataSet := lDataSet;

  if FReportMaster.DataSet <> nil then
    FReportMaster.Report.Dictionary.GetDataSetFields(FReportMaster.DataSet.Owner.Name + '.' + FReportMaster.DataSet.Name,
      cmbFields.Items);
end;

end.

