
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{        Wrapper for Table & Query        }
{                                         }
{*****************************************}

unit RMD_DBWrap;

interface

{$I RM.inc}

uses
  Windows, Classes, SysUtils, Controls, Forms, Menus, DB, RM_Class, RM_DataSet,
  RM_Parser, RM_Common, RM_Ctrls
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  RMFieldClasses: array[0..9] of TFieldClass = (
    TStringField, TSmallintField, TIntegerField, TWordField,
    TBooleanField, TFloatField, TCurrencyField, TDateField,
    TTimeField, TBlobField);

  RMParamTypes: array[0..10] of TFieldType = (
    ftBCD, ftBoolean, ftCurrency, ftDate, ftDateTime, ftInteger,
    ftFloat, ftSmallint, ftString, ftTime, ftWord);

type
  TRMParamKind = (rmpkValue, rmpkAssignFromMaster);

  { TRMDDataSet }
  TRMDDataSet = class(TRMDialogComponent)
  private
    procedure P1Click(Sender: TObject);

    procedure SetDataSet(Value: TDataSet);
  protected
    FIndexBased: Boolean;
    FCanBrowse: Boolean;
    FHaveFilter: Boolean;
    FDataSet: TDataSet;
    FDataSource: TDataSource;
    FRMDataSet: TRMDBDataset;
    FFixupList: TRMVariables;

  	procedure DBInternalLoaded; virtual;
    procedure AfterChangeName; override;

    function GetIndexDefs: TIndexDefs; virtual;
    function GetActive: Boolean; virtual;
    procedure SetActive(Value: Boolean); virtual;
    function GetTableName: string; virtual; abstract;
    function GetDatabaseName: string; virtual; abstract;
    procedure SetDatabaseName(const Value: string); virtual; abstract;

    procedure LoadFields(aStream: TStream);
    procedure SaveFields(aStream: TStream);

    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    function SetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AfterLoaded; override;
    procedure ShowEditor; override;
    procedure DefinePopupMenu(aPopup: TRMCustomMenuItem); override;

    property DataSet: TDataSet read FDataSet write SetDataSet;
    property IndexBased: Boolean read FIndexBased;
    property IndexDefs: TIndexDefs read GetIndexDefs;
  published
    property Active: Boolean read GetActive write SetActive;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
  end;

  { TRMDTable }
  TRMDTable = class(TRMDDataSet)
  private
  protected
    procedure SetTableName(Value: string); virtual; abstract;
    function GetFilter: string; virtual; abstract;
    procedure SetFilter(Value: string); virtual; abstract;
    function GetIndexName: string; virtual; abstract;
    procedure SetIndexName(Value: string); virtual; abstract;
    function GetIndexFieldNames: string; virtual; abstract;
    procedure SetIndexFieldNames(Value: string); virtual; abstract;
    function GetMasterFields: string; virtual; abstract;
    procedure SetMasterFields(Value: string); virtual; abstract;
    function GetMasterSource: string; virtual; abstract;
    procedure SetMasterSource(Value: string); virtual; abstract;

    procedure GetIndexNames(sl: TStrings); virtual; abstract; //获取索引列表
  public
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure AfterLoaded; override;
    property IndexName: string read GetIndexName write SetIndexName;
  published
    property TableName: string read GetTableName write SetTableName;
    property Filter: string read GetFilter write SetFilter;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property MasterSource: string read GetMasterSource write SetMasterSource;
  end;

  { TRMDQuery }
  TRMDQuery = class(TRMDDataSet)
  private
    FUseSqlBuilder: Boolean;
    FVisualSQL: TStringList;
    FOnSQLTextChanged: TNotifyEvent;
    FParameters: string;
  protected
    FParams: TRMVariables;
    FParamCount: Integer;

    procedure Prepare; override;
    procedure OnBeforeOpenQueryEvent(DataSet: TDataSet); virtual;

    function GetFilter: string; virtual; abstract;
    procedure SetFilter(Value: string); virtual; abstract;
    function GetDataSource: string; virtual; abstract;
    procedure SetDataSource(Value: string); virtual; abstract;
    procedure GetDatabases(sl: TStrings); virtual; abstract; //获取数据库列表

    function GetParamCount: Integer; virtual; abstract;
    function GetSQL: string; virtual; abstract;
    procedure SetSQL(aSql: string); virtual; abstract;
    function GetParamName(Index: Integer): string; virtual; abstract;
    function GetParamType(Index: Integer): TFieldType; virtual; abstract;
    procedure SetParamType(Index: Integer; Value: TFieldType); virtual; abstract;
    function GetParamKind(Index: Integer): TRMParamKind; virtual; abstract;
    procedure SetParamKind(Index: Integer; Value: TRMParamKind); virtual; abstract;
    function GetParamText(Index: Integer): string; virtual; abstract;
    procedure SetParamText(Index: Integer; Value: string); virtual; abstract;
    function GetParamValue(Index: Integer): Variant; virtual; abstract;
    procedure SetParamValue(Index: Integer; Value: Variant); virtual; abstract;
    procedure GetTableNames(DB: string; Strings: TStrings); virtual; abstract;

    procedure GetTableFieldNames(const DB, TName: string; sl: TStrings); virtual; abstract; //获取表的字段名称列表
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure AfterLoaded; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    function ParamIndex(const ParName: string): Integer;

    property VisualSQL: TStringList read FVisualSQL write FVisualSQL;

    property ParamCount: Integer read GetParamCount;
    property ParamName[Index: Integer]: string read GetParamName; //取得参数的名称
    property ParamType[Index: Integer]: TFieldType read GetParamType write SetParamType; //取得(设置)参数类型
    property ParamKind[Index: Integer]: TRMParamKind read GetParamKind write SetParamKind; //取得(设置)参数初始化类型
    property ParamText[Index: Integer]: string read GetParamText write SetParamText; //取得(设置)参数初始化值
    property ParamValue[Index: Integer]: Variant read GetParamValue write SetParamValue; //取得(设置)参数值

    property OnSQLTextChanged: TNotifyEvent read FOnSQLTextChanged write FOnSQLTextChanged;
    property DataSource: string read GetDataSource write SetDataSource;
  published
    property UseSqlBuilder: Boolean read FUseSqlBuilder write FUseSqlBuilder;
    property Filter: string read GetFilter write SetFilter;
    property SQL: string read GetSQL write SetSQL;
    property Parameters: string read FParameters write FParameters;
  end;

function RMFindFieldDef(DataSet: TDataSet; FieldName: string): TFieldDef;
function RMGetDataSetName(Owner: TComponent; d: TDataSource): string;
function RMGetDataSource(Owner: TComponent; d: TDataSet): TDataSource;
procedure RMGetFieldNames(aDataSet: TDataSet; aList: TStrings);

implementation

uses RM_Const, RM_Utils, RMD_EditorField, RMD_Editorldlinks, RMD_DataPrv,
  RMD_QryDesigner, RMD_QueryParm, RM_Insp, RM_PropInsp, RM_DialogCtls;

{$R RMD_DBWrap.RES}

function RMFindFieldDef(DataSet: TDataSet; FieldName: string): TFieldDef;
var
  i: Integer;
begin
  Result := nil;
  with DataSet do
  begin
    for i := 0 to FieldDefs.Count - 1 do
    begin
      if AnsiCompareText(FieldDefs.Items[i].Name, FieldName) = 0 then
      begin
        Result := FieldDefs.Items[i];
        break;
      end;
    end;
  end;
end;

function RMGetDataSetName(Owner: TComponent; d: TDataSource): string;
begin
  Result := '';
  if (d <> nil) and (d.DataSet <> nil) then
  begin
    Result := d.Dataset.Name;
    if d.Dataset.Owner <> Owner then
      Result := d.Dataset.Owner.Name + '.' + Result;
  end;
end;

function RMGetDataSource(Owner: TComponent; d: TDataSet): TDataSource;
var
  i: Integer;
  sl: TStringList;
  ds: TDataSource;
begin
  Result := nil;
  sl := TStringList.Create;
  try
    RMGetComponents(Owner, TDataSource, sl, nil);
    for i := 0 to sl.Count - 1 do
    begin
      ds := RMFindComponent(Owner, sl[i]) as TDataSource;
      if (ds <> nil) and (ds.DataSet = d) then
      begin
        Result := ds;
        break;
      end;
    end;
  finally
    sl.Free;
  end;
end;

{$HINTS OFF}

procedure RMGetFieldNames(aDataSet: TDataSet; aList: TStrings);
var
  i: Integer;
begin
  try
    aDataSet.GetFieldNames(aList);
  except;
  end;
end;
{$HINTS ON}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDataset}

constructor TRMDDataset.Create;
begin
  inherited Create;

  FFixupList := TRMVariables.Create;
  FRMDataSet := TRMDBDataSet.Create(RMDialogForm);
  FDataSource := TDataSource.Create(RMDialogForm);
  FDataSource.DataSet := nil;

  FCanBrowse := True;
  FHaveFilter := True;
  DontUndo := True;
end;

destructor TRMDDataset.Destroy;
begin
  FFixupList.Free;
  if Assigned(RMDialogForm) then
  begin
    FRMDataSet.Free;
    FRMDataSet := nil;
    FDataSet.Free;
    FDataSet := nil;
    FDataSource.Free;
    FDataSource := nil;
  end;
  inherited Destroy;
end;

function TRMDDataset.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'DATASET' then
  begin
    aValue := O2V(DataSet);
  end
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

function TRMDDataset.SetPropValue(aObject: TObject; aPropName: string;
  aValue: Variant): Boolean;
begin
//  Result := True;
{  if aPropName = 'MEMO' then
    FMemo.Text := aValue
  else}
  Result := inherited SetPropValue(aObject, aPropName, aValue);
end;

procedure TRMDDataset.DBInternalLoaded;
begin
//
end;

procedure TRMDDataset.AfterChangeName;
begin
  FDataSource.Name := '_DS' + Name;
  FDataSet.Name := Name;
  FRMDataSet.Name := '_' + Name;
end;

function TRMDDataset.GetIndexDefs: TIndexDefs;
begin
  Result := nil;
end;

function TRMDDataset.GetActive: Boolean;
begin
  Result := FDataSet.Active;
end;

procedure TRMDDataset.SetActive(Value: Boolean);
begin
  FDataSet.Active := Value;
end;

procedure TRMDDataset.SetDataSet(Value: TDataSet);
begin
  if FDataSet <> Value then
  begin
    FDataSet := Value;
    FDataSource.DataSet := FDataSet;
    FRMDataSet.DataSet := FDataSet;
    if Self is TRMDQuery then
      FDataSet.BeforeOpen := TRMDQuery(Self).OnBeforeOpenQueryEvent;
  end;
end;

procedure TRMDDataset.AfterLoaded;
var
  i: Integer;
  s: string;
  liComponent: TComponent;
  liField: TField;
begin
  try
    for i := 0 to FFixupList.Count - 1 do
    begin
      s := FFixupList.Name[i];
      if Pos('LookupField.', s) = 1 then
      begin
        System.Delete(s, 1, 12);
        liField := FDataSet.FindField(s);
        liComponent := RMFindComponent(FDataSet.Owner, FFixupList.Value[i]);
        if (liComponent <> nil) and (liComponent is TDataSet) then
          liField.LookupDataset := TDataSet(liComponent);
      end
    end;
  except;
  end;

  FFixupList.Clear;
  inherited AfterLoaded;
end;

procedure TRMDDataset.ShowEditor;
var
  SaveActive: Boolean;
  tmpForm: TRMDFieldsEditorForm;
begin
  SaveActive := FDataSet.Active;
  FDataSet.Close;
  tmpForm := TRMDFieldsEditorForm.Create(nil);
  try
    tmpForm.DataSet := FDataSet;
    if tmpForm.ShowModal = mrOK then
      RMDesigner.BeforeChange;
  finally
    tmpForm.Free;
    FDataSet.Active := SaveActive;
  end;
end;

procedure TRMDDataset.LoadFields(aStream: TStream);
var
  i: Integer;
  liCount: Word;
  s: string;
  liField: TField;
  liFieldName: string;
  liFieldType: TFieldType;
  liLookup: Boolean;
  liFieldSize: Word;
  liFieldDefs: TFieldDefs;
begin
  liFieldDefs := FDataSet.FieldDefs;
  liCount := RMReadWord(aStream);
  for i := 0 to liCount - 1 do
  begin
    liFieldType := TFieldType(RMReadByte(aStream));
    liFieldName := RMReadString(aStream);
    liLookup := RMReadBoolean(aStream);
    liFieldSize := RMReadWord(aStream);
    liFieldDefs.Add(liFieldName, liFieldType, liFieldSize, False);
    liField := liFieldDefs[liFieldDefs.Count - 1].CreateField(FDataSet);
    if liLookup then
    begin
      liField.Lookup := True;
      liField.KeyFields := RMReadString(aStream);
      s := RMReadString(aStream);
      FFixupList['LookupField.' + liFieldName] := s;
      liField.LookupDataset := TDataSet(RMFindComponent(FDataSet.Owner, s));
      liField.LookupKeyFields := RMReadString(aStream);
      liField.LookupResultField := RMReadString(aStream);
    end;
  end;
end;

procedure TRMDDataset.SaveFields(aStream: TStream);
var
  i: Integer;
  s: string;
  SaveActive: Boolean;
begin
  SaveActive := FDataSet.Active;
  FDataSet.Close;
  RMWriteWord(aStream, FDataSet.FieldCount);
  for i := 0 to FDataSet.FieldCount - 1 do
  begin
    with FDataSet.Fields[i] do
    begin
      RMWriteByte(aStream, Byte(DataType));
      RMWriteString(aStream, FieldName);
      RMWriteBoolean(aStream, Lookup);
      RMWriteWord(aStream, Size);
      if Lookup then
      begin
        RMWriteString(aStream, KeyFields);
        if LookupDataset <> nil then
        begin
          s := LookupDataset.Name;
          if LookupDataset.Owner <> FDataSet.Owner then
            s := LookupDataset.Owner.Name + '.' + s;
        end
        else
          s := '';
        RMWriteString(aStream, s);
        RMWriteString(aStream, LookupKeyFields);
        RMWriteString(aStream, LookupResultField);
      end;
    end;
  end;
  FDataSet.Active := SaveActive;
end;

procedure TRMDDataset.DefinePopupMenu(aPopup: TRMCustomMenuItem);
var
  m: TRMMenuItem;
begin
  inherited DefinePopupMenu(aPopup);
  m := TRMMenuItem.Create(aPopup);
  m.Caption := RMLoadStr(rmRes + 3007);
  m.OnClick := P1Click;
  m.Enabled := FCanBrowse;
  aPopup.Add(m);
end;

procedure TRMDDataset.P1Click(Sender: TObject);
var
  tmp: TRMDFormPreviewData;
begin
  tmp := TRMDFormPreviewData.Create(nil);
  try
    FDataSet.Open;
    tmp.DataSource := FDataSource;
    if FDataSet.Active then
      tmp.ShowModal;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDTable}

procedure TRMDTable.LoadFromStream(aStream: TStream);
var
  lVersion: Integer;
begin
  inherited LoadFromStream(aStream);
  lVersion := RMReadWord(aStream);
  FFixupList['DatabaseName'] := RMReadString(aStream);
  FFixupList['TableName'] := RMReadString(aStream);
  FFixupList['IndexName'] := RMReadString(aStream);
  FFixupList['MasterSource'] := RMReadString(aStream);
  FFixupList['MasterFields'] := RMReadString(aStream);
  if FHaveFilter then
    FFixupList['Filter'] := RMReadString(aStream);
  FFixupList['Active'] := RMReadBoolean(aStream);
  if lVersion >= 1 then
    FFixupList['IndexFieldNames'] := RMReadString(aStream)
  else
    FFixupList['IndexFieldNames'] := '';
  DontUndo := True;
end;

procedure TRMDTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 1);
  RMWriteString(aStream, DatabaseName);
  RMWriteString(aStream, TableName);
  RMWriteString(aStream, IndexName);
  RMWriteString(aStream, MasterSource);
  RMWriteString(aStream, MasterFields);
  if FHaveFilter then
    RMWriteString(aStream, Filter);
  RMWriteBoolean(aStream, Active);
  RMWriteString(aStream, IndexFieldNames);
end;

procedure TRMDTable.AfterLoaded;
var
  lValue: Variant;
begin
  try
    DatabaseName := FFixupList['DatabaseName'];
    TableName := FFixupList['TableName'];
    MasterSource := FFixupList['MasterSource'];
    MasterFields := FFixupList['MasterFields'];
    if FHaveFilter then
      Filter := FFixupList['Filter'];

    IndexName := FFixupList['IndexName'];
    lValue := FFixupList['IndexFieldNames'];
    if (lValue <> Null) and (string(lValue) <> '') then
      IndexFieldNames := lValue;

    DBInternalLoaded;
    Active := FFixupList['Active'];
  except;
  end;
  inherited AfterLoaded;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDQuery}

constructor TRMDQuery.Create;
begin
  inherited Create;
  FUseSQLBuilder := True;
  FVisualSQL := TStringList.Create;
  FParams := TRMVariables.Create;
end;

destructor TRMDQuery.Destroy;
begin
  FVisualSQL.Free;
  FParams.Free;
  inherited Destroy;
end;

procedure TRMDQuery.AfterLoaded;
var
  i: Integer;
begin
  try
    DatabaseName := FFixupList['DatabaseName'];
    DataSource := FFixupList['DataSource'];
    SQL := FFixupList['SQL'];
    for i := 0 to FParamCount - 1 do
    begin
      ParamType[i] := FFixupList['ParamType' + IntToStr(i)];
      ParamKind[i] := FFixupList['ParamKind' + IntToStr(i)];
      ParamText[i] := FFixupList['ParamText' + IntToStr(i)];
    end;
    Active := FFixupList['Active'];
  except
  end;

  DontUndo := True;
  inherited AfterLoaded;
end;

function TRMDQuery.ParamIndex(const ParName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to ParamCount - 1 do
  begin
    if AnsiCompareText(ParamName[i], ParName) = 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TRMDQuery.LoadFromStream(aStream: TStream);

  procedure _ReadParams;
  var
    i: Integer;
  begin
    FParamCount := RMReadWord(aStream);
    for i := 0 to FParamCount - 1 do
    begin
      FFixupList['ParamType' + IntToStr(i)] := RMParamTypes[RMReadByte(aStream)];
      FFixupList['ParamKind' + IntToStr(i)] := TRMParamKind(RMReadByte(aStream));
      FFixupList['ParamText' + IntToStr(i)] := RMReadString(aStream);
    end;
  end;

begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FFixupList['DatabaseName'] := RMReadString(aStream);
  FFixupList['DataSource'] := RMReadString(aStream);
  FUseSQLBuilder := RMReadBoolean(aStream);
  FFixupList['SQL'] := RMReadString(aStream);
  RMReadMemo(aStream, FVisualSQL);
  if FHaveFilter then
    Filter := RMReadString(aStream);
  _ReadParams;
  FFixupList['Active'] := RMReadBoolean(aStream);
end;

procedure TRMDQuery.SaveToStream(aStream: TStream);

  procedure _WriteParams;
  var
    i, j, liCount: Integer;
  begin
    liCount := ParamCount;
    RMWriteWord(aStream, liCount);
    for i := 0 to liCount - 1 do
    begin
      j := Low(RMParamTypes);
      while j < High(RMParamTypes) do
      begin
        if ParamType[i] = RMParamTypes[j] then
          Break;
        Inc(j);
      end;
      RMWriteByte(aStream, j);
      RMWriteByte(aStream, Byte(ParamKind[i]));
      RMWriteString(aStream, ParamText[i]);
    end;
  end;

begin
  inherited SavetoStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, DatabaseName);
  RMWriteString(aStream, DataSource);
  RMWriteBoolean(aStream, FUseSQLBuilder);
  RMWriteString(aStream, SQL);
  RMWriteMemo(aStream, FVisualSQL);
  if FHaveFilter then
    RMWriteString(aStream, FDataSet.Filter);
  _WriteParams;
  RMWriteBoolean(aStream, FDataSet.Active);
end;

procedure TRMDQuery.Prepare;
begin
  Active := False;
  //  OnBeforeOpenQueryEvent(FDataSet);
end;

procedure TRMDQuery.OnBeforeOpenQueryEvent(DataSet: TDataSet);
var
  i: Integer;
  lParamText: string;

  function DefParamValue(index: Integer): string;
  begin
    if ParamType[index] in [ftDate, ftDateTime] then
      Result := '01.01.00'
    else if ParamType[index] = ftTime then
      Result := '00:00'
    else
      Result := '0';
  end;

begin
  i := 0;
  try
    while i < ParamCount do
    begin
      //李献军 old: if ParamKind[i] = rmpkValue then
      //目的：如果已经设置了参数则继续执行出现错误，所以进行判断付值后不再重新付值
      if (ParamKind[i] = rmpkValue) { and (VarType(ParamValue[i]) = varEmpty) } then
      begin
        if FDataSet <> nil then
          FDataSet.Close;

        if DocMode = rmdmDesigning then
          ParamValue[i] := DefParamValue(i)
        else
        begin
          lParamText := ParamText[i];
          if (lParamText <> '') or (VarType(ParamValue[i]) = varEmpty) then
            ParamValue[i] := ParentReport.Parser.Calc(lParamText);
        end;
      end;
      Inc(i);
    end;
  except
    Memo.Clear;
    Memo.Add(ParamText[i]);
    //    raise;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TSQLBuilderEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TQueryParamsEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TDataSourceEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TMasterFieldsEditor = class(TRMDFieldLinkProperty)
  protected
    function GetMasterFields: string; override;
    procedure SetMasterFields(const Value: string); override;
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(const Value: string); override;

    procedure Edit; override;
  end;

  TRMDQuery_DataSourceEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TSQLBuilderEditor }

function TSQLBuilderEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praReadOnly];
end;

procedure TSQLBuilderEditor.Edit;
var
  tmp: TRMDQueryDesignerForm;
begin
  tmp := TRMDQueryDesignerForm.Create(nil);
  try
    tmp.Query := TRMDQuery(GetInstance(0));
    if tmp.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      //      RMDesigner.AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TQueryParamsEditor }

function TQueryParamsEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praReadOnly];
end;

procedure TQueryParamsEditor.Edit;
var
  liQuery: TRMDQuery;
  tmp: TRMDParamsForm;
begin
  liQuery := TRMDQuery(GetInstance(0));
  if liQuery.ParamCount > 0 then
  begin
    tmp := TRMDParamsForm.Create(nil);
    try
      tmp.Query := liQuery;
      tmp.Caption := liQuery.Name + ' ' + RMLoadStr(SParams);
      if tmp.ShowModal = mrOk then
      begin
        RMDesigner.BeforeChange;
      end;
    finally
      tmp.Free;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDataSourceEditor }

function TDataSourceEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TDataSourceEditor.GetValues(AValues: TStrings);
var
  liDataSet: TDataSet;
begin
  liDataSet := TRMDDataSet(GetInstance(0)).FDataSet;
  RMGetComponents(liDataSet.Owner, TDataSet, AValues, liDataSet);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TMasterFieldsEditor }

procedure TMasterFieldsEditor.Edit;
begin
  inherited Edit;
  if Changed then
  begin
    if FullIndexName <> '' then
    begin
      TRMDTable(DataSet).IndexName := IndexName;
    end
    else
    begin
      TRMDTable(DataSet).IndexFieldNames := IndexFieldNames;
    end;  
  end;
end;

function TMasterFieldsEditor.GetMasterFields: string;
begin
  Result := TRMDTable(DataSet).MasterFields;
end;

procedure TMasterFieldsEditor.SetMasterFields(const Value: string);
begin
  TRMDTable(DataSet).MasterFields := Value;
end;

function TMasterFieldsEditor.GetIndexFieldNames: string;
begin
  Result := TRMDTable(DataSet).IndexFieldNames;
end;

procedure TMasterFieldsEditor.SetIndexFieldNames(const Value: string);
begin
  TRMDTable(DataSet).IndexFieldNames := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDQuery_DataSourceEditor }

function TRMDQuery_DataSourceEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDQuery_DataSourceEditor.GetValues(AValues: TStrings);
var
  liDataSet: TDataSet;
begin
  liDataSet := TRMDDataSet(GetInstance(0)).FDataSet;
  RMGetComponents(liDataSet.Owner, TDataSet, AValues, liDataSet);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMDDataset_FieldByName(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMDDataSet(Args.Obj).DataSet.FieldByName(Args.Values[0]));
end;

procedure TRMDDataset_FieldByVariant(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.FieldByName(Args.Values[0]).AsVariant;
end;

procedure TRMDDataset_FieldByString(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Fields[Args.Values[0]].AsString;
end;

procedure TRMDDataset_FieldByNumber(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Fields[Args.Values[0]].AsVariant;
end;

procedure TRMDDataset_FieldByBoolean(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Fields[Args.Values[0]].AsBoolean;
end;

procedure TRMDDataset_FieldByDateTime(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Fields[Args.Values[0]].AsDateTime;
end;

procedure TRMDDataset_Open(var Value: Variant; Args: TJvInterpreterArgs);
var
  liDataSet: TRMDDataSet;
  liComponent: TComponent;
  liDataSource: TDataSource;
begin
  liDataSet := TRMDDataSet(Args.Obj);
  if liDataSet is TRMDQuery then
  begin
    liComponent := RMFindComponent(liDataSet.DataSet.Owner, TRMDQuery(liDataSet).DataSource);
    if liComponent <> nil then
    begin
      liDataSource := RMGetDataSource(liDataSet.DataSet.Owner, TDataSet(liComponent));
      if (liDataSource <> nil) and (liDataSource.DataSet <> nil) then
        liDataSource.DataSet.Open;
    end;
  end;
  liDataSet.DataSet.Open;
end;

procedure TRMDDataset_Close(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.Close;
end;

procedure TRMDDataset_Next(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.Next;
end;

procedure TRMDDataset_Prior(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.Prior;
end;

procedure TRMDDataset_First(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.First;
end;

procedure TRMDDataset_Last(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.Last;
end;

procedure TRMDDataset_MoveBy(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDataSet(Args.Obj).DataSet.MoveBy(Args.Values[0]);
end;

procedure TRMDDataset_Locate(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Locate(Args.Values[0], Args.Values[1], TLocateOptions(Byte(V2S(Args.Values[2]))));
end;

procedure TRMDDataset_Bof(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Bof;
end;

procedure TRMDDataset_Eof(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMDDataSet(Args.Obj).DataSet.Eof;
end;

procedure TRMDQuery_SetParamValue(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDQuery(Args.Obj).ParamValue[Args.Values[0]] := Args.Values[1];
end;

procedure TRMDQuery_SetParamValueByName(var Value: Variant; Args: TJvInterpreterArgs);
var
  i: Integer;
begin
  for i := 0 to TRMDQuery(Args.Obj).ParamCount - 1 do
  begin
    if AnsiCompareText(Args.Values[0], TRMDQuery(Args.Obj).ParamName[i]) = 0 then
    begin
      TRMDQuery(Args.Obj).ParamValue[i] := Args.Values[1];
      Break;
    end;
  end;
end;

const
  cReportMachine = 'RMD_DBWrap';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDDataset, 'TRMDDataset');
    AddClass(cReportMachine, TRMDQuery, 'TRMDQuery');

    // TRMParamKind
    AddConst(cReportMachine, 'rmpkValue', rmpkValue);
    AddConst(cReportMachine, 'rmpkAssignFromMaster', rmpkAssignFromMaster);

    AddGet(TRMDDataset, 'FieldByName', TRMDDataset_FieldByName, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'FieldByVariant', TRMDDataset_FieldByVariant, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'FieldByString', TRMDDataset_FieldByString, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'FieldByNumber', TRMDDataset_FieldByNumber, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'FieldByBoolean', TRMDDataset_FieldByBoolean, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'FieldByDateTime', TRMDDataset_FieldByDateTime, 1, [0], varEmpty);

    AddGet(TRMDDataset, 'Fields', TRMDDataset_FieldByName, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'Open', TRMDDataset_Open, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Close', TRMDDataset_Close, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Next', TRMDDataset_Next, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Prior', TRMDDataset_Prior, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'First', TRMDDataset_First, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Last', TRMDDataset_Last, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Last', TRMDDataset_MoveBy, 1, [0], varEmpty);
    AddGet(TRMDDataset, 'Locate', TRMDDataset_Locate, 3, [0], varEmpty);
    AddGet(TRMDDataset, 'Bof', TRMDDataset_Bof, 0, [0], varEmpty);
    AddGet(TRMDDataset, 'Eof', TRMDDataset_Eof, 0, [0], varEmpty);

    AddGet(TRMDQuery, 'SetParamValue', TRMDQuery_SetParamValue, 2, [0], varEmpty);
    AddGet(TRMDQuery, 'SetParamValueByName', TRMDQuery_SetParamValueByName, 2, [0], varEmpty);
  end;
end;

initialization
  RMRegisterPropEditor(TypeInfo(string), TRMDDataSet, 'MasterSource', TDataSourceEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDTable, 'MasterFields', TMasterFieldsEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDQuery, 'Datasource', TRMDQuery_DataSourceEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDQuery, 'SQL', TSQLBuilderEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDQuery, 'Parameters', TQueryParamsEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

