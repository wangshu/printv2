
{******************************************}
{                                          }
{          Report Machine v2.0             }
{             Data dictionary              }
{                                          }
{******************************************}

unit RM_EditorDictionary;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, RM_Common, RM_Class, RM_Ctrls, RM_Parser, ExtCtrls, Buttons
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF};

type
  TRMDictionaryForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    ImageList1: TImageList;
    treeVariables: TTreeView;
    cmbDataSets: TComboBox;
    lstFields: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    edtExpression: TEdit;
    btnNewCategory: TSpeedButton;
    btnNewVar: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDel: TSpeedButton;
    btnExpression: TSpeedButton;
    PopupMenu1: TPopupMenu;
    NewCategory1: TMenuItem;
    NewVariable1: TMenuItem;
    N1: TMenuItem;
    Delete1: TMenuItem;
    TabSheet2: TTabSheet;
    lstAllDataSets: TListBox;
    btnFieldAddOne: TSpeedButton;
    btnFieldAddAll: TSpeedButton;
    btnFieldDeleteOne: TSpeedButton;
    btnFieldDeleteAll: TSpeedButton;
    Label8: TLabel;
    treeFieldAliases: TTreeView;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    chkFieldNoSelect: TCheckBox;
    edtFieldAlias: TEdit;
    btnPackDictionary: TButton;
    TabSheet3: TTabSheet;
    trvStyles: TTreeView;
    Panel1: TPanel;
    btnAddStyle: TSpeedButton;
    btnEditStyle: TSpeedButton;
    btnDeleteStyle: TSpeedButton;
    GroupBox2: TGroupBox;
    LabelHAlign: TLabel;
    cmbHAlign: TComboBox;
    LabelVAlign: TLabel;
    cmbVAlign: TComboBox;
    GroupBox3: TGroupBox;
    Button1: TButton;
    PaintBox1: TPaintBox;
    FontDialog1: TFontDialog;
    Button2: TButton;
    btnClearDictionary: TButton;
    procedure btnNewCategoryClick(Sender: TObject);
    procedure btnNewVarClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure treeVariablesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure treeVariablesEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtExpressionKeyPress(Sender: TObject; var Key: Char);
    procedure btnExpressionClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstFieldsClick(Sender: TObject);
    procedure treeVariablesChange(Sender: TObject; Node: TTreeNode);
    procedure lstAllDataSetsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnFieldAddOneClick(Sender: TObject);
    procedure btnFieldDeleteOneClick(Sender: TObject);
    procedure treeFieldAliasesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure edtFieldAliasKeyPress(Sender: TObject; var Key: Char);
    procedure edtFieldAliasExit(Sender: TObject);
    procedure btnFieldAddAllClick(Sender: TObject);
    procedure btnFieldDeleteAllClick(Sender: TObject);
    procedure cmbDataSetsClick(Sender: TObject);
    procedure edtExpressionEnter(Sender: TObject);
    procedure edtExpressionExit(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure chkFieldNoSelectClick(Sender: TObject);
    procedure treeFieldAliasesChange(Sender: TObject; Node: TTreeNode);
    procedure btnPackDictionaryClick(Sender: TObject);
    procedure btnAddStyleClick(Sender: TObject);
    procedure btnDeleteStyleClick(Sender: TObject);
    procedure btnEditStyleClick(Sender: TObject);
    procedure trvStylesEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure trvStylesChange(Sender: TObject; Node: TTreeNode);
    procedure Button1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure cmbHAlignChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnClearDictionaryClick(Sender: TObject);
  private
    { Private declarations }
    FBusyFlag: Boolean;
    FVariables: TRMVariables;
    FFieldAliases: TRMVariables;
    FActiveNode: TTreeNode;

    FStyles: TRMTextStyles;
    FBtnFillColor: TRMColorPickerButton;

    procedure OnColorChangeEvent(Sender: TObject);
    procedure Localize;

    procedure ShowValue(aValue: string);
    procedure AddFieldAlias(const aDataSet: string);
    procedure FillValiableDataSets;
  public
    { Public declarations }
    CurReport: TRMReport;
  end;

implementation

{$R *.DFM}

uses
	RM_DataSet, RM_Const, RM_Const1, RM_Utils, RM_EditorExpr, RM_EditorFormat;

const
  Dataset_INDEX = 1;
  Field_CanSelect = 2;
  Field_CannotSelect = 4;
  Variable_Category = 5;
  Variable_Variable = 6;
  Field_INDEX = 13;

type
  THackDictionary = class(TRMDictionary)
  end;

procedure TRMDictionaryForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 340);
  RMSetStrProp(TabSheet1, 'Caption', rmRes + 341);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 342);
  RMSetStrProp(Label3, 'Caption', rmRes + 344);
  RMSetStrProp(Label4, 'Caption', rmRes + 345);
  RMSetStrProp(btnNewCategory, 'Hint', rmRes + 347);
  RMSetStrProp(btnNewVar, 'Hint', rmRes + 348);
  RMSetStrProp(btnEdit, 'Hint', rmRes + 349);
  RMSetStrProp(btnDel, 'Hint', rmRes + 350);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 354);
  RMSetStrProp(Label2, 'Caption', rmRes + 355);
  RMSetStrProp(chkFieldNoSelect, 'Caption', rmRes + 356);
  RMSetStrProp(Label8, 'Caption', rmRes + 358);
  RMSetStrProp(btnPackDictionary, 'Caption', rmRes + 360);

  RMSetStrProp(NewCategory1, 'Caption', rmRes + 347);
  RMSetStrProp(NewVariable1, 'Caption', rmRes + 348);
  RMSetStrProp(Delete1, 'Caption', rmRes + 350);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);

  cmbHAlign.Items.Clear;
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 107));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 109));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 108));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 114));
  cmbVAlign.Items.Clear;
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 112));
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 111));
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 113));
  RMSetStrProp(LabelHAlign, 'Caption', rmRes + 678);
  RMSetStrProp(LabelVAlign, 'Caption', rmRes + 679);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 680);
  RMSetStrProp(TabSheet3, 'Caption', rmRes + 938);
  RMSetStrProp(btnAddStyle, 'Hint', rmRes + 271);
  RMSetStrProp(btnDeleteStyle, 'Hint', rmRes + 272);
  RMSetStrProp(btnEditStyle, 'Hint', rmRes + 273);
  RMSetStrProp(GroupBox3, 'Caption', rmRes + 274);
  RMSetStrProp(Button1, 'Caption', rmRes + 275);
  RMSetStrProp(Button2, 'Caption', rmRes + 276);
  RMSetStrProp(FBtnFillColor, 'Caption', rmRes + 277);
end;

procedure TRMDictionaryForm.FillValiableDataSets;
var
  lList: TStringList;
begin
  lList := TStringList.Create;
  try
    CurReport.Dictionary.GetDataSets(lList, FFieldAliases);
    lList.Sort;
    cmbDataSets.Items.Assign(lList);
  finally
    lList.Free;
    cmbDataSets.ItemIndex := 0;
    cmbDataSetsClick(nil);
  end;
end;

procedure TRMDictionaryForm.FormCreate(Sender: TObject);
begin
  FVariables := TRMVariables.Create;
  FFieldAliases := TRMVariables.Create;
  FStyles := TRMTextStyles.Create(CurReport);

  FBtnFillColor := TRMColorPickerButton.Create(Self);
  with FBtnFillColor do
  begin
    Parent := GroupBox3;
    Flat := False;
    SetBounds(16, 56, 100, 25);
//    Caption := RMLoadStr(rmRes + 528);
    ColorType := rmptFill;
    Caption := 'FillColor';
    OnColorChange := OnColorChangeEvent;
  end;

  PageControl1.ActivePage := TabSheet1;
  Localize;
end;

procedure TRMDictionaryForm.FormDestroy(Sender: TObject);
begin
  FVariables.Free;
  FFieldAliases.Free;
  FStyles.Free;
end;

procedure TRMDictionaryForm.FormShow(Sender: TObject);

  procedure _FillVariables; // 自定义变量
  var
    i: Integer;
    liParentNode, liNode: TTreeNode;
    s: string;
  begin
    FVariables.Assign(CurReport.Dictionary.Variables);
    treeVariables.Items.Clear;
    liParentNode := nil;
    for i := 0 to FVariables.Count - 1 do
    begin
      s := FVariables.Name[i];
      if (s <> '') and (s[1] = ' ') then // 目录
      begin
        liParentNode := treeVariables.Items.Add(nil, Copy(s, 2, 999));
        liParentNode.ImageIndex := 5;
        liParentNode.SelectedIndex := 5;
      end
      else // 变量
      begin
        if liParentNode = nil then
        begin
          FVariables.Insert(0, ' Category1','');
          liParentNode := treeVariables.Items.Add(nil, 'Category1');
          liParentNode.ImageIndex := 5;
          liParentNode.SelectedIndex := 5;
        end;

        liNode := treeVariables.Items.AddChild(liParentNode, s);
        liNode.ImageIndex := 6;
        liNode.SelectedIndex := 6;
      end;
    end;

    treeVariables.FullExpand;
    if treeVariables.Items.Count > 0 then
      treeVariables.Items[0].Selected := True;
  end;

  procedure _FillDataSets;
  var
    i, liIndex: Integer;
    sl: TStringList;
    liDataSetName: string;
  begin
    FFieldAliases.Assign(CurReport.Dictionary.FieldAliases);
    treeFieldAliases.Items.Add(nil, RMLoadStr(rmRes + 352));
    sl := TStringList.Create;
    try
      RMGetComponents(CurReport.Owner, TRMDataset, sl, nil);
      sl.Sort;
      for i := 0 to sl.Count - 1 do
      begin
        liDataSetName := sl[i];
        liIndex := FFieldAliases.IndexOf(liDataSetName);
        if liIndex >= 0 then
        begin
          if FFieldAliases.Value[liIndex] <> '' then
            liDataSetName := liDataSetName + ' {' + FFieldAliases.Value[liIndex] + '}';
          AddFieldAlias(liDataSetName)
        end
        else
          lstAllDataSets.Items.Add(liDataSetName);
      end;

      lstAllDataSets.ItemIndex := 0;
      treeFieldAliases.Items[0].Expand(False);
      treeFieldAliases.Selected := treeFieldAliases.Items[0];
    finally
      sl.Free;
    end;
  end;

  procedure _FillStyles;
  var
    i: Integer;
    lNode: TTreeNode;
    lStyle: TRMTextStyle;
  begin
    trvStyles.Items.BeginUpdate;
    try
	    trvStyles.Items.Clear;
  	  for i := 0 to FStyles.Count - 1 do
    	begin
      	lStyle := FStyles[i];
	      lNode := trvStyles.Items.AddChild(nil, lStyle.StyleName);
  	    lNode.Data := lStyle;
			  lNode.ImageIndex := 6;
        lNode.SelectedIndex := 6;
    	end;
    finally
	    trvStyles.Items.EndUpdate;
    end;
  end;

begin
  treeFieldAliases.Items.Clear;

  FStyles.Assign(CurReport.TextStyles);
  _FillStyles;

  _FillVariables;
  FillValiableDataSets;
  _FillDataSets;

  treeVariables.SetFocus;
end;

procedure TRMDictionaryForm.btnOKClick(Sender: TObject);
begin
  CurReport.Dictionary.Variables.Assign(FVariables);
  CurReport.Dictionary.FieldAliases.Assign(FFieldAliases);
  CurReport.TextStyles.Assign(FStyles);
  CurReport.TextStyles.Apply;
end;

procedure TRMDictionaryForm.btnNewCategoryClick(Sender: TObject);
var
  ANode, TreeNode: TTreeNode;
  s: string;

  function CreateNewCategory: string;
  var
    i: Integer;

    function FindCategory(s: string): Boolean;
    var
      i: Integer;
    begin
      Result := False;
      for i := 0 to FVariables.Count - 1 do
      begin
        if AnsiCompareText(FVariables.Name[i], s) = 0 then
        begin
          Result := True;
          break;
        end;
      end;
    end;

  begin
    for i := 1 to 10000 do
    begin
      Result := 'Category' + IntToStr(i);
      if not FindCategory(' ' + Result) then
        break;
    end;
  end;

begin
  TreeNode := treeVariables.Selected;
  if treeVariables.ShowRoot = False then
  begin
    TreeNode.Delete;
    TreeNode := nil;
    treeVariables.ShowRoot := True;
  end;
  if TreeNode <> nil then
    TreeNode := treeVariables.Items[0];

  s := CreateNewCategory;
  FVariables[' ' + s] := '';
  ANode := treeVariables.Items.Add(TreeNode, s);
  ANode.ImageIndex := 5;
  ANode.SelectedIndex := 5;
  treeVariables.Selected := ANode;
  ANode.EditText;
end;

procedure TRMDictionaryForm.btnNewVarClick(Sender: TObject);
var
  ANode, TreeNode: TTreeNode;
  s: string;

  function CreateNewVariable: string;
  var
    i: Integer;

    function FindVariable(s: string): Boolean;
    var
      i: Integer;
    begin
      Result := False;
      for i := 0 to FVariables.Count - 1 do
      begin
        if AnsiCompareText(FVariables.Name[i], s) = 0 then
        begin
          Result := True;
          break;
        end;
      end;
    end;

  begin
    for i := 1 to 10000 do
    begin
      Result := 'Variable' + IntToStr(i);
      if not FindVariable(Result) then
        break;
    end;
  end;

begin
  TreeNode := treeVariables.Selected;
  if (TreeNode = nil) or not treeVariables.ShowRoot then Exit;
  if TreeNode.Parent <> nil then
    TreeNode := TreeNode.Parent;

  s := CreateNewVariable;

  if TreeNode.GetNextSibling <> nil then
    FVariables.Insert(FVariables.IndexOf(' ' + TreeNode.GetNextSibling.Text), s,'')
  else
    FVariables[s] := '';

  ANode := treeVariables.Items.AddChild(TreeNode, s);
  ANode.ImageIndex := 6;
  ANode.SelectedIndex := 6;
  TreeNode.Expand(True);
  treeVariables.Selected := ANode;
  ANode.EditText;
end;

procedure TRMDictionaryForm.btnEditClick(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  TreeNode := treeVariables.Selected;
  if (TreeNode <> nil) and treeVariables.ShowRoot then
    TreeNode.EditText;
end;

procedure TRMDictionaryForm.btnDelClick(Sender: TObject);
var
  TreeNode: TTreeNode;
  i: integer;
begin
  TreeNode := treeVariables.Selected;
  if (TreeNode <> nil) and treeVariables.ShowRoot then
  begin
    if TreeNode.ImageIndex = 5 then
    begin
      i := FVariables.IndexOf(' ' + TreeNode.Text);
      FVariables.Delete(i);
      while (i < FVariables.Count) and (FVariables.Name[i][1] <> ' ') do
        FVariables.Delete(i);
    end
    else
      FVariables.Delete(FVariables.IndexOf(TreeNode.Text));

    TreeNode.Delete;
    if treeVariables.Items.Count = 0 then
    begin
      TreeNode := treeVariables.Items.Add(treeVariables.Selected, RMLoadStr(SNotAssigned));
      TreeNode.ImageIndex := -1;
      TreeNode.SelectedIndex := -1;
      treeVariables.ShowRoot := False;
      treeVariables.Selected := treeVariables.Items[0];
    end;
  end;
end;

procedure TRMDictionaryForm.treeVariablesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Insert then
  begin
    if ssCtrl in Shift then
      btnNewCategoryClick(nil)
    else if (treeVariables.Selected = nil) or (treeVariables.ShowRoot = False) then
      btnNewCategory.Click
    else
      btnNewVar.Click;
  end
  else if (Key = vk_Delete) and not treeVariables.IsEditing then
    btnDel.Click
  else if Key = vk_Return then
    btnEdit.Click
  else if (Key = vk_Escape) and not treeVariables.IsEditing then
    btnCancel.Click;
end;

procedure TRMDictionaryForm.treeVariablesEdited(Sender: TObject; Node: TTreeNode; var S: string);
var
  s1: string;
begin
  if Node.ImageIndex = 6 then
    s1 := s
  else
    s1 := ' ' + s;
  if (AnsiCompareText(s, Node.Text) <> 0) and (FVariables.IndexOf(s1) <> -1) then
    s := Node.Text
  else
  begin
    if Node.ImageIndex = 6 then
      FVariables.Name[FVariables.IndexOf(Node.Text)] := s1
    else
      FVariables.Name[FVariables.IndexOf(' ' + Node.Text)] := s1;
  end;
end;

procedure TRMDictionaryForm.edtExpressionKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    treeVariables.SetFocus;
end;

procedure TRMDictionaryForm.btnExpressionClick(Sender: TObject);
var
  expr: string;
begin
  expr := edtExpression.Text;
  if RMGetExpression('', expr, nil, False) then
  begin
    edtExpression.Text := expr;
    edtExpression.SetFocus;
    edtExpression.Modified := True;
  end;
end;

procedure TRMDictionaryForm.lstFieldsClick(Sender: TObject);
var
  liNode: TTreeNode;
  liValue: string;
begin
  if edtExpression.Modified then
    edtExpressionExit(nil);

  liNode := treeVariables.Selected;
  if (liNode = nil) or (liNode.ImageIndex <> 6) then Exit;

  if lstFields.ItemIndex <= 0 then
    liValue := ''
  else
    liValue := cmbDataSets.Text + '."' + lstFields.Items[lstFields.ItemIndex] + '"';

  FVariables[liNode.Text] := liValue;
end;

procedure TRMDictionaryForm.ShowValue(aValue: string);
var
  i, n: Integer;
  s1, s2: string;
  Found: Boolean;

  function FindStr(aList: TStrings; aStr: string; aIsField: Boolean): Integer;
  var
    i: Integer;
    lStr: string;
  begin
    Result := -1;
    for i := 0 to aList.Count - 1 do
    begin
      if aIsField then
        lStr := CurReport.Dictionary.RealFieldName[nil, aList[i]]
      else
        lStr := CurReport.Dictionary.RealDataSetName[aList[i]];

      if AnsiCompareText(lStr, aStr) = 0 then
      begin
        Result := i;
        Break;
      end;
    end;
  end;

begin
  s1 := '';
  s2 := '';
  Found := False;

  if Pos('.', aValue) <> 0 then
  begin
    for i := Length(aValue) downto 1 do
    begin
      if aValue[i] = '.' then
      begin
        s1 := Copy(aValue, 1, i - 1);
        s2 := Copy(aValue, i + 1, 255);
        break;
      end;
    end;

    n := FindStr(cmbDataSets.Items, s1, FALSE);
    if n <> -1 then
    begin
      if cmbDataSets.ItemIndex <> n then
      begin
        cmbDataSets.ItemIndex := n;
        cmbDataSetsClick(nil);
      end;
      if (s2 <> '') and (s2[1] = '"') then
        s2 := Copy(s2, 2, Length(s2) - 2);
      n := FindStr(lstFields.Items, s2, TRUE);
      if n <> -1 then
      begin
        lstFields.ItemIndex := n;
        Found := True;
      end;
    end;
  end;

  if not Found then
  begin
    if Trim(aValue) = '' then
    begin
      lstFields.ItemIndex := 0;
      edtExpression.Text := '';
    end;

    edtExpression.Text := aValue;
    lstFields.ItemIndex := 0;
  end
  else
  begin
    edtExpression.Text := '';
  end;
end;

procedure TRMDictionaryForm.treeVariablesChange(Sender: TObject; Node: TTreeNode);
var
  lVariableName: string;
begin
  if edtExpression.Modified then
    edtExpressionExit(nil);

  RMEnableControls([edtExpression, btnExpression], (Node <> nil) and (Node.ImageIndex = Variable_Variable));

  lVariableName := '';
  if (Node <> nil) and (Node.ImageIndex = Variable_Category) then
    lVariableName := ' ' + Node.Text
  else if (Node <> nil) and (Node.ImageIndex = Variable_Variable) then
    lVariableName := Node.Text;

  if lVariableName <> '' then
    ShowValue(FVariables[lVariableName]);
end;

procedure TRMDictionaryForm.lstAllDataSetsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  liBmp: TBitmap;
  liCanvas: TCanvas;
begin
  liBmp := TBitmap.Create;
  liCanvas := nil;
  try
    if Control = lstAllDataSets then
    begin
      liCanvas := lstAllDataSets.Canvas;
      s := lstAllDataSets.Items[Index];
      ImageList1.GetBitmap(Dataset_INDEX, liBmp);
    end
    else if Control = cmbDataSets then
    begin
      liCanvas := cmbDataSets.Canvas;
      s := cmbDataSets.Items[Index];
      ImageList1.GetBitmap(Dataset_INDEX, liBmp);
    end
    else if Control = lstFields then
    begin
      liCanvas := lstFields.Canvas;
      s := lstFields.Items[Index];
      ImageList1.GetBitmap(Field_INDEX, liBmp);
    end;

    if liCanvas <> nil then
    begin
      liCanvas.FillRect(Rect);
      liCanvas.BrushCopy(Bounds(Rect.Left + 2, Rect.Top, liBmp.Width, liBmp.Height),
        liBmp, Bounds(0, 0, liBmp.Width, liBmp.Height), liBmp.TransparentColor);
      liCanvas.TextOut(Rect.Left + 4 + liBmp.Width, Rect.Top, s);
    end;
  finally
    liBmp.Free;
  end;
end;

function GetItemName(const s: string): string;
var
  liPos: Integer;
begin
  liPos := Pos('{', s);
  if liPos > 0 then
    Result := Trim(Copy(s, 1, liPos - 1))
  else
    Result := s;
end;

procedure TRMDictionaryForm.AddFieldAlias(const aDataSet: string);
var
  liNode: TTreeNode;
begin
  if aDataSet <> '' then
  begin
    treeFieldAliases.Items.AddChild(treeFieldAliases.Items[0], aDataSet);
    liNode := treeFieldAliases.Items[0].GetLastChild;
    liNode.ImageIndex := Dataset_INDEX;
    liNode.SelectedIndex := Dataset_INDEX;
    treeFieldAliases.Items.AddChild(liNode, RMLoadStr(SNotAssigned));
    FFieldAliases[aDataSet] := '';
  end;
  btnFieldDeleteAll.Enabled := treeFieldAliases.Items.Count > 1;
end;

procedure TRMDictionaryForm.btnFieldAddOneClick(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < lstAllDataSets.Items.Count do
  begin
    if lstAllDataSets.Selected[i] then
    begin
      AddFieldAlias(lstAllDataSets.Items[i]);
      lstAllDataSets.Items.Delete(i);
    end
    else
      Inc(i);
  end;

  treeFieldAliases.Items[0].Expand(False);
  treeFieldAliases.Selected := treeFieldAliases.Items[0];
end;

procedure TRMDictionaryForm.btnFieldDeleteOneClick(Sender: TObject);
var
  lNode: TTreeNode;
  lFlag: Boolean;
  s: string;

  procedure _DeleteFieldAlias(aNode: TTreeNode);
  var
    i, n: Integer;
    s, lItemName: string;
  begin
    lItemName := GetItemName(aNode.Text);
    for i := 0 to aNode.Count - 1 do
    begin
      s := aNode.Item[i].Text;
      n := FFieldAliases.IndexOf(lItemName + '."' + GetItemName(s) + '"');
      if n <> -1 then
        FFieldAliases.Delete(n);
    end;
    btnFieldDeleteAll.Enabled := treeFieldAliases.Items.Count > 1;
  end;

begin
  lNode := treeFieldAliases.Selected;
  if (lNode = nil) or (lNode.ImageIndex <> Dataset_INDEX) then Exit;

  treeFieldAliasesExpanding(nil, lNode, lFlag);
  s := GetItemName(lNode.Text);
  _DeleteFieldAlias(lNode);
  lstAllDataSets.Items.Add(s);
  lNode.Delete;
  FFieldAliases.Delete(FFieldAliases.IndexOf(s));
  treeFieldAliasesChange(nil, nil);
end;

procedure TRMDictionaryForm.treeFieldAliasesExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  i, lIndex, lImageIndex: Integer;
  lFieldList: TStringList;
  lItemName, lStr: string;
  lNode: TTreeNode;
  lDataSet: TRMDataSet;
begin
  if Node.ImageIndex = 3 then
    AllowExpansion := False
  else if (Node.ImageIndex = Dataset_INDEX) and (Node.GetLastChild.ImageIndex = 0) then
  begin
    Node.DeleteChildren;
    lFieldList := TStringList.Create;
    lItemName := GetItemName(Node.Text);
    lDataSet := THackDictionary(CurReport.Dictionary).FindDataSet(lItemName, CurReport.Owner, lStr);
    if lDataSet <> nil then
    begin
      try
        lDataSet.GetFieldsList(lFieldList);
        //      CurReport.Dictionary.GetDataSetFields(ItemName, sl);
      except;
      end;

      for i := 0 to lFieldList.Count - 1 do
      begin
        lImageIndex := Field_CanSelect;
        lStr := lFieldList[i];
        lIndex := FFieldAliases.IndexOf(lItemName + '."' + lStr + '"');
        if lIndex >= 0 then
        begin
          if FFieldAliases.Value[lIndex] <> '' then
            lStr := lStr + ' {' + FFieldAliases.Value[lIndex] + '}'
          else
            lImageIndex := Field_CannotSelect;
        end
        else
        begin
//					lDisplayLabel := lDataSet.GetFieldDisplayLabel(lStr);
//          if lDisplayLabel <> lStr then
//          begin
//			      FFieldAliases[Node.Text + '."' + lStr + '"'] := lDisplayLabel;
//          	lStr := lStr + ' {' + lDisplayLabel + '}'
//          end;
        end;

        treeFieldAliases.Items.AddChild(Node, lStr);
        lNode := Node.GetLastChild;
        lNode.ImageIndex := lImageIndex;
        lNode.SelectedIndex := lImageIndex;
      end;
    end;

    lFieldList.Free;
  end;
end;

procedure TRMDictionaryForm.edtFieldAliasKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
    treeFieldAliases.SetFocus;
end;

procedure TRMDictionaryForm.edtFieldAliasExit(Sender: TObject);
var
  s: string;
begin
  if edtFieldAlias.Modified then
  begin
    if (FActiveNode <> nil) and (FActiveNode <> treeFieldAliases.Items[0]) then
    begin
      s := GetItemName(FActiveNode.Text);
      FActiveNode.Text := s + ' {' + edtFieldAlias.Text + '}';
      if FActiveNode.ImageIndex = Field_CanSelect then
        s := GetItemName(FActiveNode.Parent.Text) + '."' + s + '"';

      if (not chkFieldNoSelect.Checked) and (edtFieldAlias.Text = '') then
      begin
        FFieldAliases.Delete(FFieldAliases.IndexOf(s));
      end
      else
        FFieldAliases[s] := edtFieldAlias.Text;
    end;
  end;
  edtFieldAlias.Modified := False;
end;

procedure TRMDictionaryForm.btnFieldAddAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstAllDataSets.Items.Count - 1 do
    AddFieldAlias(lstAllDataSets.Items[i]);

  lstAllDataSets.Items.Clear;
  treeFieldAliases.Items[0].Expand(False);
  treeFieldAliases.Selected := treeFieldAliases.Items[0];
end;

procedure TRMDictionaryForm.btnFieldDeleteAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FFieldAliases.Count - 1 do
  begin
    if Pos('"', FFieldAliases.Name[i]) = 0 then
      lstAllDataSets.Items.Add(FFieldAliases.Name[i]);
  end;

  FFieldAliases.Clear;
  treeFieldAliases.Items[0].DeleteChildren;
  btnFieldDeleteAll.Enabled := treeFieldAliases.Items.Count > 1;
  treeFieldAliasesChange(nil, nil);
end;

procedure TRMDictionaryForm.cmbDataSetsClick(Sender: TObject);
begin
  if cmbDataSets.ItemIndex >= 0 then
  begin
    RMDesigner.Report.Dictionary.GetDataSetFields(cmbDataSets.Items[cmbDataSets.ItemIndex],
      lstFields.Items, FFieldAliases);
  end
  else
    lstFields.Items.Clear;

  lstFields.Items.Insert(0, RMLoadStr(SNotAssigned));
end;

procedure TRMDictionaryForm.edtExpressionEnter(Sender: TObject);
begin
  FActiveNode := treeVariables.Selected;
end;

procedure TRMDictionaryForm.edtExpressionExit(Sender: TObject);
begin
  if (FActiveNode = nil) or (FActiveNode.ImageIndex <> 6) then Exit;
  if edtExpression.Modified then
  begin
    FVariables[FActiveNode.Text] := edtExpression.Text;
  end;

  edtExpression.Modified := False;
  FActiveNode := nil;
end;

procedure TRMDictionaryForm.PageControl1Change(Sender: TObject);
begin
  FActiveNode := nil;
  if PageControl1.ActivePage = TabSheet1 then
  begin
    FillValiableDataSets;
    treeVariablesChange(nil, treeVariables.Selected);
  end;
end;

procedure TRMDictionaryForm.chkFieldNoSelectClick(Sender: TObject);
var
  liNode: TTreeNode;
  ItemName, FullName: string;
begin
  if FBusyFlag then Exit;
  liNode := treeFieldAliases.Selected;
  if (liNode = nil) or (liNode = treeFieldAliases.Items[0]) then Exit;

  if liNode.ImageIndex in [Field_CanSelect, Field_CannotSelect] then
  begin
    ItemName := GetItemName(liNode.Text);
    FullName := GetItemName(liNode.Parent.Text) + '."' + ItemName + '"';
    if liNode.ImageIndex = Field_CanSelect then
      liNode.ImageIndex := Field_CannotSelect
    else
      liNode.ImageIndex := Field_CanSelect;
    liNode.SelectedIndex := liNode.ImageIndex;

    if liNode.ImageIndex = Field_CanSelect then
      FFieldAliases.Delete(FFieldAliases.IndexOf(FullName))
    else
      FFieldAliases[FullName] := '';
    liNode.Text := ItemName;
  end;
end;

procedure TRMDictionaryForm.treeFieldAliasesChange(Sender: TObject; Node: TTreeNode);
var
  s: string;
begin
  if edtFieldAlias.Modified then edtFieldAliasExit(nil);

  FActiveNode := treeFieldAliases.Selected;
  btnFieldDeleteOne.Enabled := (FActiveNode.ImageIndex = Dataset_INDEX);
  btnFieldDeleteAll.Enabled := treeFieldAliases.Items.Count > 1;
  if FActiveNode <> treeFieldAliases.Items[0] then
  begin
    s := FActiveNode.Text;
    if Pos('{', s) <> 0 then
      s := Copy(s, Pos('{', s) + 1, Pos('}', s) - Pos('{', s) - 1);
    edtFieldAlias.Text := s;
  end
  else
    edtFieldAlias.Text := '';

  FBusyFlag := True;
  RMEnableControls([Label2, edtFieldAlias], FActiveNode.ImageIndex <> 0);
  chkFieldNoSelect.Enabled := FActiveNode.ImageIndex in [Field_CanSelect, Field_CannotSelect];
  chkFieldNoSelect.Checked := (FActiveNode <> treeFieldAliases.Items[0]) and
    (FActiveNode.ImageIndex = Field_CannotSelect);
  FBusyFlag := False;
end;

procedure TRMDictionaryForm.btnPackDictionaryClick(Sender: TObject);
begin
  THackDictionary(CurReport.Dictionary).Pack1(FFieldAliases);
end;

procedure TRMDictionaryForm.btnClearDictionaryClick(Sender: TObject);
begin
  THackDictionary(CurReport.Dictionary).Clear;

  PageControl1.ActivePage := TabSheet1;
  FormShow(nil);
end;

procedure TRMDictionaryForm.btnAddStyleClick(Sender: TObject);
var
	lNode: TTreeNode;
  lStyle: TRMTextStyle;
begin
  lStyle := FStyles.Add;
  lStyle.CreateUniqueName;

	lNode := trvStyles.Items.Add(nil, lStyle.StyleName);
  lNode.Data := lStyle;
  lNode.ImageIndex := 6;
  lNode.SelectedIndex := 6;

  trvStyles.Selected := lNode;
  trvStyles.Selected.EditText;
end;

procedure TRMDictionaryForm.btnDeleteStyleClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  lNode := trvStyles.Selected;
  if lNode <> nil then
  begin
    TRMTextStyle(lNode.Data).Free;
    trvStyles.Items.Delete(lNode);
  end;
end;

procedure TRMDictionaryForm.btnEditStyleClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  lNode := trvStyles.Selected;
  if lNode <> nil then
  begin
    lNode.EditText;
  end;
end;

procedure TRMDictionaryForm.trvStylesEdited(Sender: TObject;
  Node: TTreeNode; var S: String);
begin
	TRMTextStyle(Node.Data).StyleName := s;
end;

procedure TRMDictionaryForm.trvStylesChange(Sender: TObject;
  Node: TTreeNode);
var
	lNode: TTreeNode;
begin
	lNode := trvStyles.Selected;
  if lNode <> nil then
  begin
		cmbHAlign.ItemIndex := Integer(TRMTextStyle(lNode.Data).HAlign);
		cmbVAlign.ItemIndex := Integer(TRMTextStyle(lNode.Data).VAlign);
  end;

  PaintBox1.Repaint;
end;

procedure TRMDictionaryForm.Button1Click(Sender: TObject);
var
	lFontDialog: TFontDialog;
begin
  if trvStyles.Selected = nil then Exit;

	lFontDialog := TFontDialog.Create(Application);
  try
  	lFontDialog.Options := lFontDialog.Options + [fdTrueTypeOnly];
  	lFontDialog.Font := TRMTextStyle(trvStyles.Selected.Data).Font;
		if lFontDialog.Execute then
    begin
    	TRMTextStyle(trvStyles.Selected.Data).Font := lFontDialog.Font;
    end;
  finally
  	lFontDialog.Free;
	  PaintBox1.Repaint;
  end;
end;

type
	THackView = class(TRMMemoView);

procedure TRMDictionaryForm.PaintBox1Paint(Sender: TObject);
var
  t: TRMMemoView;
begin
  with PaintBox1.Canvas do
  begin
    Brush.Color := clWindow;
    Pen.Color := clGray;
    Pen.Width := 1;
    Pen.Style := psSolid;
    Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);
  end;
  if trvStyles.Selected = nil then Exit;

  t := TRMMemoView.Create;
  try
	  THackView(t).SetParentReport(CurReport);
  	THackView(t).DrawFocusedFrame := False;

    THackView(t).ApplyStyle(TRMTextStyle(trvStyles.Selected.Data));
  	t.Memo.Text := RMLoadStr(rmRes + 278);
	  t.SetspBounds(1, 1, PaintBox1.Width - 2, PaintBox1.Height - 2);
  	t.Draw(PaintBox1.Canvas);
  finally
	  t.Free;
  end;
end;

procedure TRMDictionaryForm.cmbHAlignChange(Sender: TObject);
begin
  if trvStyles.Selected = nil then Exit;

  TRMTextStyle(trvStyles.Selected.Data).HAlign := TRMHAlign(cmbHAlign.ItemIndex);
  TRMTextStyle(trvStyles.Selected.Data).VAlign := TRMVAlign(cmbVAlign.ItemIndex);
  PaintBox1.Repaint;
end;

procedure TRMDictionaryForm.OnColorChangeEvent(Sender: TObject);
begin
  if trvStyles.Selected = nil then Exit;

  TRMTextStyle(trvStyles.Selected.Data).FillColor := FBtnFillColor.CurrentColor;
  PaintBox1.Repaint;
end;

procedure TRMDictionaryForm.Button2Click(Sender: TObject);
var
	lTmp: TRMDisplayFormatForm;
begin
  if trvStyles.Selected = nil then Exit;

	lTmp := TRMDisplayFormatForm.Create(nil);
  try
		lTmp.DisplayFormat := TRMTextStyle(trvStyles.Selected.Data).DisplayFormat;
    if lTmp.ShowModal = mrOK then
    begin
    	TRMTextStyle(trvStyles.Selected.Data).DisplayFormat := lTmp.DisplayFormat;
    end;
  finally
  	lTmp.Free;
  end;
end;

end.

