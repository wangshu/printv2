
{*****************************************}
{                                         }
{           Report Machine 2.0           }
{       Wrapper for Diamond Access        }
{                                         }
{*****************************************}

unit RMD_Diamond;

interface

{$I RM.INC}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, DAODatabase, DAODataset, DAOMDTable,
  DAOQuery, DAOTable, DAOTlb, Dialogs, Controls, StdCtrls, RM_Class, RMD_DBWrap,
  JvInterpreter
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMDDiamondComponents = class(TComponent) // fake component
  end;

  TRMDDiamondDatabase = class(TRMDialogComponent)
  private
    FDatabase: TDAODatabase;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetDAOVersion: TDAOVersion;
    procedure SetDAOVersion(Value: TDAOVersion);
    function GetWorkspace: TWorkspace;
    procedure SetWorkspace(Value: TWorkspace);
    function GetDatabaseName: string;
    procedure SetDatabaseName(Value: string);
  protected
    procedure AfterChangeName; override;
    procedure PropEditor(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
  published
    property Database: TDAODatabase read FDatabase;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
    property Connected: Boolean read GetConnected write SetConnected;
    property DAOVersion: TDAOVersion read GetDAOVersion write SetDAOVersion;
    property Workspace: TWorkspace read GetWorkspace write SetWorkspace;
  end;

 { TRMDDiamondTable }
  TRMDDiamondTable = class(TRMDTable)
  private
    FTable: TDAOMasterDetailTable;
  protected
    function GetTableName: string; override;
    procedure SetTableName(Value: string); override;
    function GetFilter: string; override;
    procedure SetFilter(Value: string); override;
    function GetIndexName: string; override;
    procedure SetIndexName(Value: string); override;
    function GetMasterFields: string; override;
    procedure SetMasterFields(Value: string); override;
    function GetMasterSource: string; override;
    procedure SetMasterSource(Value: string); override;
    function GetDatabaseName: string; override;
    procedure SetDatabaseName(const Value: string); override;
    procedure GetIndexNames(sl: TStrings); override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  end;

  { TRMDDiamondQuery }
  TRMDDiamondQuery = class(TRMDQuery)
  private
    FQuery: TDAOQuery;
  protected
    function GetParamCount: Integer; override;
    function GetSQL: string; override;
    procedure SetSQL(Value: string); override;
    function GetFilter: string; override;
    procedure SetFilter(Value: string); override;
    function GetDatabaseName: string; override;
    procedure SetDatabaseName(const Value: string); override;
    function GetDataSource: string; override;
    procedure SetDataSource(Value: string); override;

    function GetParamName(Index: Integer): string; override;
    function GetParamType(Index: Integer): TFieldType; override;
    procedure SetParamType(Index: Integer; Value: TFieldType); override;
    function GetParamKind(Index: Integer): TRMParamKind; override;
    procedure SetParamKind(Index: Integer; Value: TRMParamKind); override;
    function GetParamText(Index: Integer): string; override;
    procedure SetParamText(Index: Integer; Value: string); override;
    function GetParamValue(Index: Integer): Variant; override;
    procedure SetParamValue(Index: Integer; Value: Variant); override;

    procedure GetDatabases(sl: TStrings); override;
    procedure GetTableNames(DB: string; Strings: TStrings); override;
    procedure GetTableFieldNames(const DB, TName: string; sl: TStrings); override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
  end;

implementation

uses RM_Const, RM_Common, RM_utils, RM_PropInsp, RM_Insp;

{$R RMD_Diamond.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDiamondDatabase}

constructor TRMDDiamondDatabase.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'DAODatabase';
  FBmpRes := 'RMD_DiamondDB';

  DontUndo := True;
  FDatabase := TDAODatabase.Create(RMDialogForm);
end;

destructor TRMDDiamondDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FDatabase.Free;
    FDatabase := nil;
  end;
  inherited Destroy;
end;

procedure TRMDDiamondDatabase.AfterChangeName;
begin
  FDatabase.Name := Name;
end;

procedure TRMDDiamondDatabase.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDatabase.DatabaseName := RMReadString(aStream);
  FDatabase.DAOVersion := TDAOVersion(RMReadByte(aStream));
  FDatabase.Workspace.UserName := RMReadString(aStream);
  FDatabase.Workspace.Password := RMReadString(aStream);
  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDDiamondDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FDatabase.DatabaseName);
  RMWriteByte(aStream, Byte(FDatabase.DAOVersion));
  RMWriteString(aStream, FDatabase.Workspace.UserName);
  RMWriteString(aStream, FDatabase.Workspace.Password);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

function TRMDDiamondDatabase.GetDatabaseName: string;
begin
  Result := FDatabase.DatabaseName;
end;

procedure TRMDDiamondDatabase.SetDatabaseName(Value: string);
begin
  FDatabase.DatabaseName := Value;
end;

function TRMDDiamondDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDDiamondDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDDiamondDatabase.GetDAOVersion: TDAOVersion;
begin
  Result := FDatabase.DAOVersion;
end;

procedure TRMDDiamondDatabase.SetDAOVersion(Value: TDAOVersion);
begin
  FDatabase.DAOVersion := Value;
end;

function TRMDDiamondDatabase.GetWorkspace: TWorkspace;
begin
  Result := FDatabase.Workspace;
end;

procedure TRMDDiamondDatabase.SetWorkspace(Value: TWorkspace);
begin
  FDatabase.Workspace := Value;
end;

procedure TRMDDiamondDatabase.ShowEditor;
begin
  PropEditor(nil);
end;

procedure TRMDDiamondDatabase.PropEditor(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  OpenDialog.Filter := '*.mdb|*.mdb';
  try
    if OpenDialog.Execute then
    begin
      FDatabase.DatabaseName := OpenDialog.FileName;
    end;
  finally
    OpenDialog.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDiamondTable}

constructor TRMDDiamondTable.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'DAOMasterDetailTable';
  FBmpRes := 'RMD_DiamondTABLE';

  FTable := TDAOMasterDetailTable.Create(RMDialogForm);
  DataSet := FTable;
end;

procedure TRMDDiamondTable.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDDiamondTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

function TRMDDiamondTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDDiamondTable.SetTableName(Value: string);
begin
  FTable.Close;
  FTable.TableName := Value;
end;

function TRMDDiamondTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDDiamondTable.SetFilter(Value: string);
begin
  FTable.Filter := Value;
end;

function TRMDDiamondTable.GetIndexName: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDDiamondTable.SetIndexName(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDDiamondTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDDiamondTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDDiamondTable.GetMasterSource: string;
begin
  Result := '';
  if FTable.MasterSource <> nil then
  begin
    Result := FTable.MasterSource.Name;
    if FTable.MasterSource.Owner <> FTable.Owner then
      Result := FTable.MasterSource.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDDiamondTable.SetMasterSource(Value: string);
var
  lComponent: TComponent;
begin
  lComponent := RMFindComponent(FTable.Owner, Value);
  FTable.MasterSource := RMGetDataSource(FTable.Owner, TDataSet(lComponent));
end;

function TRMDDiamondTable.GetDatabaseName: string;
begin
  Result := '';
  if FTable.Database <> nil then
  begin
    Result := FTable.Database.Name;
    if FTable.Database.Owner <> FTable.Owner then
      Result := FTable.Database.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDDiamondTable.SetDatabaseName(const Value: string);
var
  lComponent: TComponent;
begin
  FTable.Close;
  lComponent := RMFindComponent(FTable.Owner, Value);
  FTable.Database := TDAODatabase(lComponent);
end;

procedure TRMDDiamondTable.GetIndexNames(sl: TStrings);
begin
  sl.Clear;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDiamondQuery}

constructor TRMDDiamondQuery.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'DAOQuery';
  FBmpRes := 'RMD_DiamondQUERY';

  FQuery := TDAOQuery.Create(RMDialogForm);
  DataSet := FQuery;
end;

procedure TRMDDiamondQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDDiamondQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream);
end;

function TRMDDiamondQuery.GetParamCount: Integer;
begin
  Result := FQuery.Params.Count;
end;

function TRMDDiamondQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDDiamondQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDDiamondQuery.GetDatabaseName: string;
begin
  Result := '';
  if FQuery.Database <> nil then
  begin
    Result := FQuery.Database.Name;
    if (FQuery.Database.Owner <> nil) and (FQuery.Database.Owner <> FQuery.Owner) then
      Result := FQuery.Database.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDDiamondQuery.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FQuery.Close;
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDAODatabase) then
    FQuery.Database := TDAODatabase(liComponent)
  else
    FQuery.Database := nil;
end;

function TRMDDiamondQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDDiamondQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDDiamondQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDDiamondQuery.SetDataSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(liComponent))
  else
    FQuery.DataSource := nil;
end;

procedure TRMDDiamondQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TDAODatabase, liStringList, nil);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDDiamondQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
  lDatabase: TDAODatabase;
begin
  Strings.Clear;
  sl := TStringList.Create;
  try
    try
      lDatabase := RMFindComponent(FQuery.Owner, DB) as TDAODatabase;
      if lDatabase = nil then exit;
      if not lDatabase.Connected then
        lDatabase.Connected := True;
      if lDatabase.Connected then
        lDatabase.GetTableNames(sl);
      sl.Sort;
      Strings.Assign(sl);
    except
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDDiamondQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TDAOTable;
begin
  lStrings := TStringList.Create;
  t := TDAOTable.Create(RMDialogForm);
  try
    t.Database := RMFindComponent(FQuery.Owner, DB) as TDAODatabase;
    t.TableName := tName;
    try
      t.FieldDefs.UpDate;
      for i := 0 to t.FieldDefs.Count - 1 do
        lStrings.Add(t.FieldDefs.Items[i].Name);
      lStrings.Sort;
      sl.Assign(lStrings);
    except;
    end;
  finally
    lStrings.Free;
    t.Free;
  end;
end;

function TRMDDiamondQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDDiamondQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDDiamondQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDDiamondQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDDiamondQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
begin
  if Value = rmpkAssignFromMaster then
  begin
    FQuery.Params[Index].Bound := False;
    FParams.Delete(FParams.IndexOf(FQuery.Params[Index].Name));
  end
  else
  begin
    FQuery.Params[Index].Clear;
    FQuery.Params[Index].Bound := True;
    FParams[FQuery.Params[Index].Name] := '';
  end;
end;

function TRMDDiamondQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDDiamondQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDDiamondQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDDiamondQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TDatabaseEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TGetDatabaseEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TIndexNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TTableNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDatabaseEditor }

function TDatabaseEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TDatabaseEditor.Edit;
var
  lDatabase: TRMDDiamondDatabase;
begin
  lDatabase := TRMDDiamondDatabase(GetInstance(0));
  lDatabase.PropEditor(lDatabase);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TGetDatabaseEditor }

function TGetDatabaseEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TGetDatabaseEditor.GetValues(AValues: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TDAODatabase, liStringList, nil);
    liStringList.Sort;
    aValues.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TIndexNameEditor }

function TIndexNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TIndexNameEditor.GetValues(AValues: TStrings);
var
  lTable: TRMDDiamondTable;
begin
  lTable := TRMDDiamondTable(GetInstance(0));
  lTable.GetIndexNames(aValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TTableNameEditor }

function TTableNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TTableNameEditor.GetValues(AValues: TStrings);
var
  lTable: TDAOMasterDetailTable;
  liStringList: TStringList;
begin
  lTable := TRMDDiamondTable(GetInstance(0)).FTable;
  if lTable.Database <> nil then
  begin
    liStringList := TStringList.Create;
    try
      lTable.Database.GetTableNames(liStringList);
      liStringList.Sort;
      aValues.Assign(liStringList);
    finally
      liStringList.Free;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
procedure TRMDDiamondQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDiamondQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDDiamondQuery(Args.Obj).FQuery);
  TRMDDiamondQuery(Args.Obj).FQuery.Execute(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMDDiamondDatabase, 'TRMDDiamondDatabase');
    AddClass('ReportMachine', TRMDDiamondTable, 'TRMDDiamondTable');
    AddClass('ReportMachine', TRMDDiamondQuery, 'TRMDDiamondQuery');

    AddGet(TRMDDataset, 'ExecSql', TRMDDiamondQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
  RMRegisterControl(TRMDDiamondDatabase, 'RMD_DiamondDBControl', RMLoadStr(SInsertDB) + '(DiamondDao)');
  RMRegisterControl(TRMDDiamondTable, 'RMD_DiamondTABLEControl', RMLoadStr(SInsertTable) + '(DiamondDao)');
  RMRegisterControl(TRMDDiamondQuery, 'RMD_DiamondQUERYControl', RMLoadStr(SInsertQuery) + '(DiamondDao)');

  RMRegisterPropEditor(TypeInfo(string), TRMDDiamondDatabase, 'DatabaseName', TDatabaseEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDDiamondTable, 'DatabaseName', TGetDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDiamondTable, 'IndexName', TIndexNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDiamondTable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDDiamondQuery, 'DatabaseName', TGetDatabaseEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

