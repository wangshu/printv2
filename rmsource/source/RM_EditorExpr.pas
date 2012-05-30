
{*****************************************}
{                                         }
{          Report Machine v1.0            }
{             Expr Dialog                 }
{                                         }
{*****************************************}

unit RM_EditorExpr;

{$I RM.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, RM_Common, RM_Class, RM_DataSet
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF};

type
  TRMFormExpressionBuilder = class(TForm)
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheetExpr: TTabSheet;
    TabSheetDatabase: TTabSheet;
    TabSheetVal: TTabSheet;
    TabSheetFunc: TTabSheet;
    lblHeading: TLabel;
    InsertGroupBox: TGroupBox;
    AddPlus: TButton;
    AddMinus: TButton;
    AddMul: TButton;
    AddDiv: TButton;
    AddEqual: TButton;
    AddSmaller: TButton;
    AddLarger: TButton;
    AddNotEqual: TButton;
    AddLessEqual: TButton;
    AddGreaterEqual: TButton;
    AddNot: TButton;
    AddAnd: TButton;
    AddOr: TButton;
    Button3: TButton;
    btnClearExpr: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    SelectVariableGroupBox: TGroupBox;
    btnVariableOK: TButton;
    btnVariableCancel: TButton;
    btnFunctionOK: TButton;
    btnFunctionCancel: TButton;
    FunctionGroupBox: TGroupBox;
    FuncName: TLabel;
    FuncDescription: TLabel;
    lstFunc: TListBox;
    btnDataFieldOK: TButton;
    DataFieldCancelBtn: TButton;
    DatafieldGB: TGroupBox;
    DatasetLabel: TLabel;
    DatafieldLabel: TLabel;
    lstFields: TListBox;
    lstDatasets: TListBox;
    TabSheetFuncParam: TTabSheet;
    GroupBox6: TGroupBox;
    CopyFuncName: TLabel;
    CopyFuncDescription: TLabel;
    FuncParamSB: TScrollBox;
    btnFuncParamOk: TButton;
    btnFuncArgCancel: TButton;
    lstVariableFolder: TListBox;
    lstVariables: TListBox;
    btnInsertDataField: TSpeedButton;
    btnInsertVariable: TSpeedButton;
    btnInsertFunction: TSpeedButton;
    TreeViewFunctions: TTreeView;
    ImageList1: TImageList;
    chkUseTableName: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnClearExprClick(Sender: TObject);
    procedure btnInsertDataFieldClick(Sender: TObject);
    procedure btnDataFieldOKClick(Sender: TObject);
    procedure DataFieldCancelBtnClick(Sender: TObject);
    procedure btnInsertFunctionClick(Sender: TObject);
    procedure btnFunctionOKClick(Sender: TObject);
    procedure btnInsertVariableClick(Sender: TObject);
    procedure btnFunctionCancelClick(Sender: TObject);
    procedure lstDatasetsClick(Sender: TObject);
    procedure AddOrClick(Sender: TObject);
    procedure lstFieldsDblClick(Sender: TObject);
    procedure btnVariableOKClick(Sender: TObject);
    procedure btnVariableCancelClick(Sender: TObject);
    procedure lstFuncDblClick(Sender: TObject);
    procedure btnFuncParamOkClick(Sender: TObject);
    procedure btnFuncArgCancelClick(Sender: TObject);
    procedure lstFuncClick(Sender: TObject);
    procedure lstVariableFolderDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstVariableFolderClick(Sender: TObject);
    procedure lstVariablesDblClick(Sender: TObject);
    procedure TreeViewFunctionsChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    edtExpression: TEdit;
    FExprResult: integer;
    FDatafieldResult: integer;
    FFuncParamsResult: integer;
    FFuncResult: integer;
    FVariableResult: integer;
    FVal: string;
    FFunctionBMP: TBitmap;
    FDataSetBMP, FFieldBMP: TBitmap;
    FVariableFolderBMP, FVariableBMP: TBitmap;
    FReport: TRMReport;
    FDataSet: TRMDataSet;

    function CurDataSet: string;
    procedure GetVariables;
    procedure GetSpecValues;
    function GetParams(ParamList: string; var ParamResult: string): boolean;
    procedure GetParamExprClick(Sender: TObject);
    procedure SelectFunc(Index: integer);

    procedure InsertText(AText: string);
    function GetDatafield(var Field: string): boolean;
    function GetFunc(var Func: string): boolean;
    function GetVariable(var Variable: string): boolean;
    procedure Localize;
  public
    IsScript: Boolean;

    property Report: TRMReport read FReport write FReport;
    property DataSet: TRMDataSet read FDataSet write FDataSet;
  end;

function RMGetExpression(ACaption: string; var Value: string; AParentControl: TWinControl;
  aIsScript: Boolean): boolean;
function RMGetExpression1(ACaption: string; var Value: string; AParentControl: TWinControl;
  aIsScript: Boolean; aReport: TRMReport; aDataSet: TRMDataSet): boolean;


implementation

uses
  RM_Parser, RM_Const, RM_Const1, RM_Utils, RM_Designer;

{$R *.DFM}

var
  FLastVariableFolder: string;

type
  THackReport = class(TRMReport);

function TrimExpr(AExpr: string): string;
begin
  while pos(#13, AExpr) > 0 do
    Delete(AExpr, Pos(#13, AExpr), 2);
  Result := AExpr;
end;

function RMGetExpression(ACaption: string; var Value: string; AParentControl: TWinControl;
  aIsScript: Boolean): boolean;
begin
  with TRMFormExpressionBuilder.Create(Application) do
  try
    DataSet := nil;
    Report := nil;
    isScript := aIsScript;
    chkUseTableName.Checked := RMDesigner.UseTableName;
    if AParentControl <> nil then
    begin
      Parent := AParentControl;
      Top := 0;
      Left := 0;
      BorderStyle := bsNone;
      Position := poDesigned;
    end;
    if ACaption <> '' then
      lblHeading.Caption := ACaption;
    edtExpression.Text := Value;
    edtExpression.SelStart := 0;
    edtExpression.SelLength := Length(Value);
    FExprResult := 0;
    if Parent = nil then
      ShowModal
    else
    begin
      Show;
      repeat
        Application.HandleMessage
      until FExprResult <> 0;
    end;
    Result := FExprResult = 1;
    if Result then
      Value := TrimExpr(edtExpression.Text)
    else
      Value := '';
  finally
    RMDesigner.UseTableName := chkUseTableName.Checked;
    Free;
  end;
end;

function RMGetExpression1(ACaption: string; var Value: string; AParentControl: TWinControl;
  aIsScript: Boolean; aReport: TRMReport; aDataSet: TRMDataSet): boolean;
begin
  with TRMFormExpressionBuilder.Create(Application) do
  try
    isScript := aIsScript;
    DataSet := aDataSet;
    Report := aReport;
    chkUseTableName.Checked := False;
    if AParentControl <> nil then
    begin
      Parent := AParentControl;
      Top := 0;
      Left := 0;
      BorderStyle := bsNone;
      Position := poDesigned;
    end;
    if ACaption <> '' then
      lblHeading.Caption := ACaption;
    edtExpression.Text := Value;
    edtExpression.SelStart := 0;
    edtExpression.SelLength := Length(Value);
    FExprResult := 0;
    if Parent = nil then
      ShowModal
    else
    begin
      Show;
      repeat
        Application.HandleMessage
      until FExprResult <> 0;
    end;
    Result := FExprResult = 1;
    if Result then
      Value := TrimExpr(edtExpression.Text)
    else
      Value := '';
  finally
    Free;
  end;
end;

function AddBrackets(s: string): string;
var
  i: Integer;
begin
  Result := s;
  s := AnsiUpperCase(s);
  for i := 1 to Length(s) do
  begin
    if not (s[i] in ['0'..'9', '_', '.', 'A'..'Z']) then
    begin
      Result := '[' + Result + ']';
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ 函数处理程序 }

procedure GetFunctionFolder(aList: TStrings); // 函数分类
var
  i, j, k: Integer;
  pfunc: PRMFunctionDesc;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Sorted := True;
    for i := 0 to RMAddInFunctionCount - 1 do
    begin
      with RMAddInFunctions(i) do
      begin
        for j := 0 to FunctionList.Count - 1 do
        begin
          pfunc := PRMFunctionDesc(FunctionList[j]);
          if not sl.Find(pfunc.Category, k) then
            sl.Add(pfunc^.Category);
        end;
      end;
    end;

    with THackReport(RMDesigner.Report).InterFunction do
    begin
      for j := 0 to FunctionList.Count - 1 do
      begin
        pfunc := PRMFunctionDesc(FunctionList[j]);
        if not sl.Find(pfunc.Category, k) then
          sl.Add(pfunc^.Category);
      end;
    end;

    sl.Sort;
    aList.Assign(sl);
  finally
    sl.Free;
  end;
end;

procedure GetFunctionList(aCategory: string; aList: TStrings); // 每类函数列表
var
  i, j: Integer;
  pfunc: PRMFunctionDesc;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    if aCategory = RMLoadStr(SAllCategories) then
      aCategory := '';

    for i := 0 to RMAddInFunctionCount - 1 do
    begin
      with RMAddInFunctions(i) do
      begin
        for j := 0 to FunctionList.Count - 1 do
        begin
          pfunc := PRMFunctionDesc(FunctionList[j]);
          if (aCategory = '') or (AnsiCompareText(pfunc^.Category, aCategory) = 0) then
            sl.Add(pfunc^.FuncName);
        end;
      end;
    end;

    with THackReport(RMDesigner.Report).InterFunction do
    begin
      for j := 0 to FunctionList.Count - 1 do
      begin
        pfunc := PRMFunctionDesc(FunctionList[j]);
        if (aCategory = '') or (AnsiCompareText(pfunc^.Category, aCategory) = 0) then
          sl.Add(pfunc^.FuncName);
      end;
    end;

    sl.Sort;
    aList.Assign(sl);
  finally
    sl.Free;
  end;
end;

function GetFunctionDescription(const FuncName: string): string; // 函数功能描述
var
  i, j: integer;
  pfunc: PRMFunctionDesc;
begin
  Result := '';
  for i := 0 to RMAddInFunctionCount - 1 do
  begin
    with RMAddInFunctions(i) do
    begin
      for j := 0 to FunctionList.Count - 1 do
      begin
        pfunc := PRMFunctionDesc(FunctionList[j]);
        if AnsiCompareText(pfunc^.FuncName, FuncName) = 0 then
        begin
          Result := pfunc^.Description;
          Exit;
        end;
      end;
    end;
  end;

  with THackReport(RMDesigner.Report).InterFunction do
  begin
    for j := 0 to FunctionList.Count - 1 do
    begin
      pfunc := PRMFunctionDesc(FunctionList[j]);
      if AnsiCompareText(pfunc^.FuncName, FuncName) = 0 then
      begin
        Result := pfunc^.Description;
        Exit;
      end;
    end;
  end;
end;

function GetArguments(const FuncName: string): string; // 函数参数
var
  i, j: integer;
  pfunc: PRMFunctionDesc;
begin
  Result := '';
  for i := 0 to RMAddInFunctionCount - 1 do
  begin
    with RMAddInFunctions(i) do
    begin
      for j := 0 to FunctionList.Count - 1 do
      begin
        pfunc := PRMFunctionDesc(FunctionList[j]);
        if AnsiCompareText(pfunc^.FuncName, FuncName) = 0 then
        begin
          Result := pfunc^.FuncPara;
          Exit;
        end;
      end;
    end;
  end;

  with THackReport(RMDesigner.Report).InterFunction do
  begin
    for j := 0 to FunctionList.Count - 1 do
    begin
      pfunc := PRMFunctionDesc(FunctionList[j]);
      if AnsiCompareText(pfunc^.FuncName, FuncName) = 0 then
      begin
        Result := pfunc^.FuncPara;
        Exit;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TWordWrapEdit }
type
  TWordWrapEdit = class(TEdit)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

procedure TWordWrapEdit.CreateParams(var Params: TCreateParams);
const
  WordWraps: array[Boolean] of LongInt = (0, ES_AUTOHSCROLL);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WordWraps[True] or ES_MULTILINE
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFormExpressionBuilder}

procedure TRMFormExpressionBuilder.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 700);
  RMSetStrProp(lblHeading, 'Caption', rmRes + 701);
  RMSetStrProp(InsertGroupBox, 'Caption', rmRes + 702);
  RMSetStrProp(btnInsertDataField, 'Caption', rmRes + 703);
  RMSetStrProp(btnInsertVariable, 'Caption', rmRes + 704);
  RMSetStrProp(btnInsertFunction, 'Caption', rmRes + 705);
  RMSetStrProp(btnClearExpr, 'Caption', rmRes + 721);
  RMSetStrProp(Button3, 'Caption', rmRes + 712);

  RMSetStrProp(DatasetLabel, 'Caption', rmRes + 706);
  RMSetStrProp(DatafieldLabel, 'Caption', rmRes + 707);
  RMSetStrProp(DatafieldGB, 'Caption', rmRes + 713);
  btnDataFieldOK.Caption := RMLoadStr(SOK);
  DataFieldCancelBtn.Caption := RMLoadStr(SCancel);

  btnVariableOK.Caption := RMLoadStr(SOK);
  btnVariableCancel.Caption := RMLoadStr(SCancel);
  RMSetStrProp(SelectVariableGroupBox, 'Caption', rmRes + 708);

  RMSetStrProp(btnFunctionOK, 'Caption', rmRes + 709);
  btnFunctionCancel.Caption := RMLoadStr(SCancel);
  RMSetStrProp(FunctionGroupBox, 'Caption', rmRes + 710);

  RMSetStrProp(GroupBox6, 'Caption', rmRes + 711);
  btnFuncParamOk.Caption := RMLoadStr(SOK);
  btnFuncArgCancel.Caption := RMLoadStr(SCancel);
  RMSetStrProp(chkUseTableName, 'Caption', rmRes + 722);

  btnOK.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMFormExpressionBuilder.InsertText(AText: string);
begin
  edtExpression.SelText := AText;
  edtExpression.SelStart := edtExpression.SelStart + edtExpression.SelLength;
  edtExpression.SelLength := 0;
end;

procedure TRMFormExpressionBuilder.SelectFunc(Index: Integer);
var
  str: string;
begin
  if (Index >= 0) and (Index < lstFunc.Items.Count) then
  begin
    str := GetFunctionDescription(lstFunc.Items[lstFunc.ItemIndex]);
    FuncName.Caption := Copy(str, 1, Pos('|', str) - 1);
    FuncDescription.Caption := Copy(str, Pos('|', str) + 1, 1000);
  end
  else
  begin
    FuncDescription.Caption := '';
    FuncName.Caption := '';
  end;
end;

procedure TRMFormExpressionBuilder.GetParamExprClick(Sender: TObject);
var
  I: integer;
  ParamExpr: string;
begin
  for I := 0 to FuncParamSB.ControlCount - 1 do
  begin
    if (FuncParamSB.Controls[I] is TEdit) and (TEdit(FuncParamSB.Controls[I]).Tag = TSpeedButton(Sender).Tag) then
    begin
      with TEdit(FuncParamSB.Controls[I]) do
      begin
        ParamExpr := Text;
        if RMGetExpression(Format(RMLoadStr(rmRes + 728), [Tag + 1, FuncName.Caption]),
          ParamExpr, Self, Self.IsScript) then
          Text := ParamExpr;

        PageControl1.ActivePage := TabSheetFuncParam;
        SetFocus;
        SelStart := 0;
        SelLength := Length(Text);
        Exit;
      end;
    end;
  end;
end;

type
  THackPage = TRMCustomPage;

function TRMFormExpressionBuilder.GetParams(ParamList: string; var ParamResult: string): boolean;
var
  i, j: integer;
  t: TRMView;
  lStr: string;
begin
  PageControl1.ActivePage := TabSheetFuncParam;
  CopyFuncName.Caption := FuncName.Caption;
  CopyFuncDescription.Caption := FuncDescription.Caption;
  for i := 0 to length(ParamList) - 1 do
  begin
    with TLabel.Create(Self) do
    begin
      Parent := FuncParamSB;
      Left := 10;
      Top := i * 40;
      case ParamList[i + 1] of
        'N': Caption := RMLoadStr(rmRes + 719);
        'B': Caption := RMLoadStr(rmRes + 718);
        'S', 'C': Caption := RMLoadStr(rmRes + 717);
        'V': Caption := RMLoadStr(rmRes + 720);
        'D': Caption := RMLoadStr(rmRes + 716);
        'T': Caption := RMLoadStr(rmRes + 715);
        'E': Caption := RMLoadStr(rmRes + 714);
      end;
      Caption := Format(Caption, [I + 1]);
    end;

    if ParamList[i + 1] = 'C' then
    begin
      with TComboBox.Create(Self) do
      begin
        Parent := FuncParamSB;
        Left := 10;
        Top := I * 40 + 15;
        Width := Parent.Width - 60;
        Tag := I;
        Items.Add(RMLoadStr(SNotAssigned));
        for j := 0 to RMDesigner.Page.Objects.Count - 1 do
        begin
          t := RMDesigner.Page.Objects[j];
          if t.IsBand and (TRMCustomBandView(t).BandType in [rmbtMasterData, rmbtDetailData]) then
          begin
            lStr := t.Name;
            case TRMCustomBandView(t).BandType of
              rmbtMasterData: lStr := lStr + ' (Master Data)';
              rmbtDetailData: lStr := lStr + ' (Detail Data)';
            end;
            Items.Add(lStr);
          end;
        end;
      end;
    end
    else
    begin
      with TEdit.Create(Self) do
      begin
        Parent := FuncParamSB;
        Left := 10;
        Top := I * 40 + 15;
        Width := Parent.Width - 60;
        Tag := I;
      end;
      with TSpeedButton.Create(Self) do
      begin
        Parent := FuncParamSB;
        Left := Parent.Width - 40;
        Width := 20;
        Height := 20;
        Top := I * 40 + 15;
        Caption := '...';
        Tag := I;
        OnClick := GetParamExprClick;
      end;
    end;

    FuncParamSB.VertScrollBar.Range := Length(ParamList) * 40;
    FuncParamSB.VertScrollBar.Increment := 40;
  end;

  FFuncParamsResult := 0;
  repeat
    Application.HandleMessage;
  until FFuncParamsResult <> 0;
  Result := FFuncParamsResult = 1;
  if Result then
  begin
    ParamResult := '';
    for i := 0 to FuncParamSB.ControlCount - 1 do
    begin
      if FuncParamSB.Controls[i] is TComboBox then
      begin
        if ParamResult <> '' then
          ParamResult := ParamResult + ',';

        if TComboBox(FuncParamSB.Controls[i]).ItemIndex = 0 then
          ParamResult := ParamResult + ''
        else
        begin
          lStr := TComboBox(FuncParamSB.Controls[i]).Text;
          ParamResult := ParamResult + Copy(lStr, 1, Pos(' (', lStr) - 1);
        end;
      end
      else if FuncParamSB.Controls[i] is TEdit then
      begin
//        if TEdit(FuncParamSB.Controls[I]).Text <> '' then
        begin
          if ParamResult <> '' then
            ParamResult := ParamResult + ',';
          ParamResult := ParamResult + TEdit(FuncParamSB.Controls[i]).Text;
        end;
      end;
    end;
  end;
  while FuncParamSB.ControlCount > 0 do
    FuncParamSB.Controls[0].Free;
end;

function TRMFormExpressionBuilder.GetDatafield(var Field: string): boolean;
begin
  FDatafieldResult := 0;
  PageControl1.ActivePage := TabSheetDatabase;
  repeat
    Application.HandleMessage;
  until FDatafieldResult <> 0;

  Result := FDatafieldResult = 1;
  if Result and (lstDatasets.ItemIndex > -1) and (lstFields.ItemIndex > -1) then
  begin
    if chkUseTableName.Checked then
      Field := lstDatasets.Items[lstDatasets.ItemIndex] + '."'
    else
      Field := '"';
    Field := Field + lstFields.Items[lstFields.ItemIndex] + '"';
  end
  else
    Field := '';

  if isScript and (Field <> '') then
    Field := 'GetValue(''' + Field + ''')';
end;

function TRMFormExpressionBuilder.GetFunc(var Func: string): boolean;
var
  AllArguments: string;
  Arguments: string;
begin
  PageControl1.ActivePage := TabSheetFunc;
  FFuncResult := 0;
  repeat
    Application.HandleMessage;
  until FFuncResult <> 0;

  if FFuncResult = 1 then
  begin
    Result := true;
    if (lstFunc.ItemIndex >= 0) and (lstFunc.ItemIndex <= lstFunc.Items.Count - 1) then
    begin
      Func := lstFunc.Items[lstFunc.ItemIndex];
      Arguments := GetArguments(Func);
    end;

    if Length(Arguments) > 0 then
    begin
      if GetParams(Arguments, AllArguments) then
        Func := Func + '(' + AllArguments + ')'
      else
        Result := false;
    end;
    PageControl1.ActivePage := TabSheetFunc;
  end
  else
    Result := false;

  if not Result then
    Func := '';
end;

function TRMFormExpressionBuilder.GetVariable(var Variable: string): boolean;
begin
  FVariableResult := 0;
  PageControl1.ActivePage := TabSheetVal;
  repeat
    Application.HandleMessage
  until FVariableResult <> 0;

  Result := FVariableResult = 1;
  if Result then
    Variable := FVal;
end;

procedure TRMFormExpressionBuilder.FormCreate(Sender: TObject);
begin
  FFunctionBMP := TBitmap.Create;
  FFunctionBMP.LoadFromResourceName(hInstance, 'RM_BMPFUNCTION');

  FDataSetBMP := TBitmap.Create;
  FDataSetBMP.LoadFromResourceName(hInstance, 'RM_FLD1');

  FFieldBMP := TBitmap.Create;
  FFieldBMP.LoadFromResourceName(hInstance, 'RM_FLD2');

  FVariableFolderBMP := TBitmap.Create;
  FVariableFolderBMP.LoadFromResourceName(hInstance, 'RM_FLD3');

  FVariableBMP := TBitmap.Create;
  FVariableBMP.LoadFromResourceName(hInstance, 'RM_FLD4');

  btnInsertDataField.Glyph.Assign(FDataSetBMP);
  btnInsertVariable.Glyph.Assign(FVariableBMP);

  Localize;
  PageControl1.ActivePage := TabSheetExpr;
  edtExpression := TWordWrapEdit.Create(Self);
  with edtExpression do
  begin
    Parent := TabSheetExpr;
    AutoSize := false;
    Top := lblHeading.BoundsRect.Bottom + 4;
    Left := InsertGroupBox.Left;
    Width := InsertGroupBox.Width;
    Height := InsertGroupBox.Top - Top - 4;
  end;
end;

procedure TRMFormExpressionBuilder.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FExprResult <> 1 then
    FExprResult := 2;
end;

procedure TRMFormExpressionBuilder.btnOKClick(Sender: TObject);
begin
  FExprResult := 1;
end;

procedure TRMFormExpressionBuilder.btnCancelClick(Sender: TObject);
begin
  FExprResult := 2;
end;

procedure TRMFormExpressionBuilder.btnClearExprClick(Sender: TObject);
begin
  edtExpression.Text := '';
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.btnInsertDataFieldClick(Sender: TObject);
var
  AField: string;
begin
  if GetDatafield(AField) then
  begin
    if IsScript then
      InsertText(AField)
    else
      InsertText(AddBrackets(AField));
  end;
  PageControl1.ActivePage := TabSheetExpr;
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.btnDataFieldOKClick(Sender: TObject);
begin
  if lstDatasets.ItemIndex >= 0 then
  begin
    RM_Dsg_LastDataSet := lstDatasets.Items[lstDatasets.ItemIndex];
    FDatafieldResult := 1;
  end;
end;

procedure TRMFormExpressionBuilder.DataFieldCancelBtnClick(
  Sender: TObject);
begin
  FDatafieldResult := 2;
end;

procedure TRMFormExpressionBuilder.btnInsertFunctionClick(Sender: TObject);
var
  AFunction: string;
begin
  if GetFunc(AFunction) then
  begin
    if isScript or (Pos('(', AFunction) <> 0) then
      InsertText(AFunction)
    else
      InsertText(AddBrackets(AFunction));
  end;
  PageControl1.ActivePage := TabSheetExpr;
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.btnFunctionOKClick(Sender: TObject);
begin
  if lstFunc.ItemIndex >= 0 then
    FFuncResult := 1;
end;

procedure TRMFormExpressionBuilder.btnInsertVariableClick(Sender: TObject);
var
  AVariable: string;
begin
  if GetVariable(AVariable) then
  begin
    if isScript then
      InsertText(AVariable)
    else
      InsertText(AddBrackets(AVariable));
  end;
  PageControl1.ActivePage := TabSheetExpr;
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.btnFunctionCancelClick(Sender: TObject);
begin
  FFuncResult := 2;
end;

procedure TRMFormExpressionBuilder.lstDatasetsClick(Sender: TObject);
begin
  lstFields.Items.Clear;
  if lstDataSets.ItemIndex >= 0 then
  begin
    if FReport <> nil then
      FReport.Dictionary.GetDataSetFields(lstDataSets.Items[lstDataSets.ItemIndex],
        lstFields.Items)
    else
      RMDesigner.Report.Dictionary.GetDataSetFields(lstDataSets.Items[lstDataSets.ItemIndex],
        lstFields.Items);
  end
  else
    lstFields.Items.Clear;
end;

procedure TRMFormExpressionBuilder.AddOrClick(Sender: TObject);
begin
  InsertText(' ' + TSpeedButton(Sender).Caption + ' ');
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.lstFieldsDblClick(Sender: TObject);
begin
  if lstFields.ItemIndex >= 0 then
    btnDataFieldOK.Click;
end;

function TRMFormExpressionBuilder.CurDataSet: string;
begin
  Result := '';
  if lstVariableFolder.ItemIndex <> -1 then
    Result := lstVariableFolder.Items[lstVariableFolder.ItemIndex];
end;

procedure TRMFormExpressionBuilder.GetVariables;
begin
  if FReport <> nil then
    FReport.Dictionary.GetVariablesList(lstVariableFolder.Items[lstVariableFolder.ItemIndex],
      lstVariables.Items)
  else
    RMDesigner.Report.Dictionary.GetVariablesList(lstVariableFolder.Items[lstVariableFolder.ItemIndex],
      lstVariables.Items);
end;

procedure TRMFormExpressionBuilder.GetSpecValues;
var
  i: Integer;
begin
  with lstVariables.Items do
  begin
    Clear;
    for i := 0 to RMSpecCount - 1 do
    begin
      Add(RMLoadStr(SVar1 + i));
    end;

    for i := 0 to RMVariables.Count - 1 do
      Add(RMVariables.Name[i]);
  end;
end;

procedure TRMFormExpressionBuilder.btnVariableOKClick(Sender: TObject);
begin
  if lstVariables.ItemIndex >= 0 then
  begin
    if CurDataSet <> RMLoadStr(SSystemVariables) then
    begin
      if lstVariables.ItemIndex <> -1 then
        FVal := lstVariables.Items[lstVariables.ItemIndex];
    end
    else
    begin
      if lstVariables.ItemIndex < RMSpecCount then
        FVal := RMSpecFuncs[lstVariables.ItemIndex]
      else
        FVal := lstVariables.Items[lstVariables.ItemIndex];
    end;

    FLastVariableFolder := lstVariableFolder.Items[lstVariableFolder.ItemIndex];
    FVariableResult := 1;
  end;
end;

procedure TRMFormExpressionBuilder.btnVariableCancelClick(Sender: TObject);
begin
  FVariableResult := 2;
end;

procedure TRMFormExpressionBuilder.lstFuncDblClick(Sender: TObject);
begin
  if lstFunc.ItemIndex >= 0 then
    btnFunctionOK.Click;
end;

procedure TRMFormExpressionBuilder.btnFuncParamOkClick(Sender: TObject);
begin
  FFuncParamsResult := 1;
end;

procedure TRMFormExpressionBuilder.btnFuncArgCancelClick(Sender: TObject);
begin
  FFuncParamsResult := 2;
end;

procedure TRMFormExpressionBuilder.lstFuncClick(Sender: TObject);
begin
  SelectFunc(lstFunc.ItemIndex);
end;

procedure TRMFormExpressionBuilder.lstVariableFolderDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  liBmp: TBitmap;
begin
  with TListBox(Control) do
  begin
    s := Items[Index];
    if Control = lstDatasets then
      liBmp := FDataSetBMP
    else
      liBmp := FFieldBMP;

    if Control = lstVariableFolder then
      liBmp := FVariableFolderBMP
    else if Control = lstVariables then
      liBmp := FVariableBMP
    else if Control = lstFunc then
      liBmp := FFunctionBMP
    else if Control = lstDatasets then
      liBmp := FDataSetBMP
    else if Control = lstFields then
      liBmp := FFieldBMP;

    Canvas.FillRect(Rect);
    Canvas.BrushCopy(Bounds(Rect.Left + 2, Rect.Top, liBmp.Width, liBmp.Height),
      liBmp, Bounds(0, 0, liBmp.Width, liBmp.Height), liBmp.TransparentColor);
    Canvas.TextOut(Rect.Left + 4 + liBmp.Width, Rect.Top, s);
  end;
end;

procedure TRMFormExpressionBuilder.lstVariableFolderClick(Sender: TObject);
begin
  if CurDataSet = RMLoadStr(SSystemVariables) then
    GetSpecValues
  else
    GetVariables;
end;

procedure TRMFormExpressionBuilder.lstVariablesDblClick(Sender: TObject);
begin
  if lstVariables.ItemIndex >= 0 then
    btnVariableOK.Click;
end;

procedure TRMFormExpressionBuilder.TreeViewFunctionsChange(Sender: TObject;
  Node: TTreeNode);
begin
  GetFunctionList(Node.Text, lstFunc.Items);
  lstFunc.ItemIndex := 0;
  lstFuncClick(nil);
end;

procedure TRMFormExpressionBuilder.FormShow(Sender: TObject);

  procedure _FillFunctions;
  var
    i: integer;
    s: TStringList;
    TreeNode, ANode: TTreeNode;
  begin
    s := TStringList.Create;
    try
      GetFunctionFolder(s);

      TreeNode := TreeViewFunctions.Items.Add(nil, RMLoadStr(SAllCategories));
      TreeNode.ImageIndex := 0;
      TreeNode.SelectedIndex := 0;
      for i := 0 to s.Count - 1 do
      begin
        ANode := TreeViewFunctions.Items.AddChild(TreeNode, s[i]);
        ANode.ImageIndex := 1;
        ANode.SelectedIndex := 1;
      end;

      TreeViewFunctions.FullExpand;
      TreeViewFunctions.Selected := TreeViewFunctions.Items[0];
    finally
      s.Free;
    end;
  end;

  procedure _FillCategoryLB;
  var
    s: TStringList;
  begin
    s := TStringList.Create;
    if FReport <> nil then
      FReport.Dictionary.GetCategoryList(s)
    else
      RMDesigner.Report.Dictionary.GetCategoryList(s);
    s.Add(RMLoadStr(SSystemVariables));
    lstVariableFolder.Items.Assign(s);
    s.Free;
  end;

begin
  if FDataSet <> nil then
    lstDataSets.Items.Add(FDataSet.Owner.Name + '.' + FDataSet.Name)
  else
    RMDesigner.Report.Dictionary.GetDataSets(lstDatasets.Items);

  if lstDatasets.Items.IndexOf(RM_Dsg_LastDataSet) <> -1 then
    lstDatasets.ItemIndex := lstDatasets.Items.IndexOf(RM_Dsg_LastDataSet)
  else
    lstDatasets.ItemIndex := 0;
  lstDatasetsClick(nil);

  _FillCategoryLB;
  with lstVariableFolder do
  begin
    if Items.IndexOf(FLastVariableFolder) <> -1 then
      ItemIndex := Items.IndexOf(FLastVariableFolder)
    else
      ItemIndex := 0;
  end;

  lstVariableFolderClick(nil);
  _FillFunctions;
  edtExpression.SetFocus;
end;

procedure TRMFormExpressionBuilder.FormDestroy(Sender: TObject);
begin
  FFunctionBMP.Free;
  FDataSetBMP.Free;
  FFieldBMP.Free;
  FVariableFolderBMP.Free;
  FVariableBMP.Free;
end;

end.

