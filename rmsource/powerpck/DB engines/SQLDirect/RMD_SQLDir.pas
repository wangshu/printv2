
{*****************************************}
{                                         }
{           Report Machine 2.0           }
{       Wrapper for Diamond Access        }
{                                         }
{*****************************************}

unit RMD_SQLDir;

interface

{$I RM.INC}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, Controls, StdCtrls,
  RM_Common, RM_Class, RM_DataSet, RM_Parser, RMD_DBWrap, SDEngine
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMDSQLDirComponents = class(TComponent) // fake component
  end;

  { TRMDSDDatabase }
  TRMDSDDatabase = class(TRMDialogComponent)
  private
    FDatabase: TSDDatabase;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetDatabaseName: string;
    procedure SetDatabaseName(Value: string);
    function GetKeepConnection: Boolean;
    procedure SetKeepConnection(Value: Boolean);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetRemoteDatabase: string;
    procedure SetRemoteDatabase(Value: string);
    function GetServerType: TSDServerType;
    procedure SetServerType(Value: TSDServerType);
    function GetTransIsolation: TSDTransIsolation;
    procedure SetTransIsolation(Value: TSDTransIsolation);
    function GetSessionName: string;
    procedure SetSessionName(Value: string);
    function GetParams: TStrings;
    procedure SetParams(Value: TStrings);
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Connected: Boolean read GetConnected write SetConnected;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
    property KeepConnection: Boolean read GetKeepConnection write SetKeepConnection;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property RemoteDatabase: string read GetRemoteDatabase write SetRemoteDatabase;
    property ServerType: TSDServerType read GetServerType write SetServerType;
    property TransIsolation: TSDTransIsolation read GetTransIsolation write SetTransIsolation;
    property SessionName: string read GetSessionName write SetSessionName;
    property Params: TStrings read GetParams write SetParams;
  end;

  { TRMDSDQuery }
  TRMDSDQuery = class(TRMDQuery)
  private
    FQuery: TSDQuery;
//		procedure _GetSessionName(Sender: TObject);

    function GetDetachOnFetchAll: Boolean;
    procedure SetDetachOnFetchAll(Value: Boolean);
    function GetParamCheck: Boolean;
    procedure SetParamCheck(Value: Boolean);
    function GetSessionName: string;
    procedure SetSessionName(Value: string);
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
    property DetachOnFetchAll: Boolean read GetDetachOnFetchAll write SetDetachOnFetchAll;
    property ParamCheck: Boolean read GetParamCheck write SetParamCheck;
    property SessionName: string read GetSessionName write SetSessionName;
  end;

implementation

uses RM_Const, RM_utils, RM_PropInsp, RM_Insp, RM_EditorStrings;

{$R RMD_SqlDir.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDSDDatabase }

constructor TRMDSDDatabase.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'SDDatabase';
  FBmpRes := 'RMD_SDDATABASE';

  FDatabase := TSDDatabase.Create(RMDialogForm);
  FComponent := FDatabase;
  DontUndo := True;
end;

destructor TRMDSDDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
    FreeAndNil(FDatabase);

  inherited Destroy;
end;

function TRMDSDDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDSDDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDSDDatabase.GetDatabaseName: string;
begin
  Result := FDatabase.DatabaseName;
end;

procedure TRMDSDDatabase.SetDatabaseName(Value: string);
begin
  FDatabase.DatabaseName := Value;
end;

function TRMDSDDatabase.GetKeepConnection: Boolean;
begin
  Result := FDatabase.KeepConnection;
end;

procedure TRMDSDDatabase.SetKeepConnection(Value: Boolean);
begin
  FDatabase.KeepConnection := Value;
end;

function TRMDSDDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDSDDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDSDDatabase.GetRemoteDatabase: string;
begin
  Result := FDatabase.RemoteDatabase;
end;

procedure TRMDSDDatabase.SetRemoteDatabase(Value: string);
begin
  FDatabase.RemoteDatabase := Value;
end;

function TRMDSDDatabase.GetServerType: TSDServerType;
begin
  Result := FDatabase.ServerType;
end;

procedure TRMDSDDatabase.SetServerType(Value: TSDServerType);
begin
  FDatabase.ServerType := Value;
end;

function TRMDSDDatabase.GetTransIsolation: TSDTransIsolation;
begin
  Result := FDatabase.TransIsolation;
end;

procedure TRMDSDDatabase.SetTransIsolation(Value: TSDTransIsolation);
begin
  FDatabase.TransIsolation := Value;
end;

function TRMDSDDatabase.GetSessionName: string;
begin
  Result := FDatabase.SessionName;
end;

procedure TRMDSDDatabase.SetSessionName(Value: string);
begin
  FDatabase.SessionName := Value;
end;

function TRMDSDDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Params;
end;

procedure TRMDSDDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Params.Assign(Value);
end;

procedure TRMDSDDatabase.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDatabase.ServerType := TSDServerType(RMReadByte(aStream));
  FDatabase.DatabaseName := RMReadString(aStream);
  FDatabase.RemoteDatabase := RMReadString(aStream);
  FDatabase.Transisolation := TSDTransisolation(RMReadByte(aStream));
  FDatabase.SessionName := RMReadString(aStream);
  RMReadMemo(aStream, FDatabase.Params);
  FDatabase.LoginPrompt := RMReadBoolean(aStream);
  FDatabase.KeepConnection := RMReadBoolean(aStream);
  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDSDDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(FDatabase.ServerType));
  RMWriteString(aStream, FDatabase.DatabaseName);
  RMWriteString(aStream, FDatabase.RemoteDatabase);
  RMWriteByte(aStream, Byte(FDatabase.Transisolation));
  RMWriteString(aStream, FDatabase.SessionName);
  RMWriteMemo(aStream, FDatabase.Params);
  RMWriteBoolean(aStream, FDatabase.LoginPrompt);
  RMWriteBoolean(aStream, FDatabase.KeepConnection);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDSDQuery}

constructor TRMDSDQuery.Create;
begin
  inherited Create;
  FComponent := FQuery;
  BaseName := 'SDQuery';
  FBmpRes := 'RMD_SDQUERY';

  FQuery := TSDQuery.Create(RMDialogForm);
  DataSet := FQuery;
end;

function TRMDSDQuery.GetDetachOnFetchAll: Boolean;
begin
  Result := FQuery.DetachOnFetchAll;
end;

procedure TRMDSDQuery.SetDetachOnFetchAll(Value: Boolean);
begin
  FQuery.DetachOnFetchAll := Value;
end;

function TRMDSDQuery.GetParamCheck: Boolean;
begin
  Result := FQuery.ParamCheck;
end;

procedure TRMDSDQuery.SetParamCheck(Value: Boolean);
begin
  FQuery.ParamCheck := Value;
end;

function TRMDSDQuery.GetSessionName: string;
begin
  Result := FQuery.SessionName;
end;

procedure TRMDSDQuery.SetSessionName(Value: string);
begin
  FQuery.SessionName := Value;
end;

procedure TRMDSDQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FQuery.DetachOnFetchAll := RMReadBoolean(aStream);
  FQuery.ParamCheck := RMReadBoolean(aStream);
  FQuery.Preservation := RMReadBoolean(aStream);
  FQUery.SessionName := RMReadString(aStream);
end;

procedure TRMDSDQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteBoolean(aStream, FQuery.DetachOnFetchAll);
  RMWriteBoolean(aStream, FQuery.ParamCheck);
  RMWriteBoolean(aStream, FQuery.Preservation);
  RMWriteString(aStream, FQUery.SessionName);
end;

procedure TRMDSDQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    FQuery.DBSession.GetDatabaseNames(liStringList);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDSDQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    try
      FQuery.DBSession.GetTableNames(FQuery.DatabaseName, '', False, sl);
      sl.Sort;
      Strings.Assign(sl);
    except;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDSDQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  lStrings: TStringList;
begin
  lStrings := TStringList.Create;
  try
    FQuery.DBSession.GetTableFieldNames(FQuery.DatabaseName, TName, lStrings);
    lStrings.Sort;
    sl.Assign(lStrings);
  finally
    lStrings.Free;
  end;
end;

function TRMDSDQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDSDQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDSDQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDSDQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDSDQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

function TRMDSDQuery.GetParamText(Index: Integer): string;
var
  v: Variant;
begin
  v := '';
  if ParamKind[Index] = rmpkValue then
    v := FParams[FQuery.Params[Index].Name];
  if v = Null then
    v := '';
  Result := v;
end;

procedure TRMDSDQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDSDQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDSDQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;

function TRMDSDQuery.GetParamCount: Integer;
begin
  Result := FQuery.ParamCount;
end;

function TRMDSDQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDSDQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDSDQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDSDQuery.SetFilter(Value: string);
begin
  FQuery.Filter := Value;
end;

function TRMDSDQuery.GetDatabaseName: string;
begin
  Result := FQuery.DatabaseName;
end;

procedure TRMDSDQuery.SetDatabaseName(const Value: string);
begin
  FQuery.DatabaseName := Value;
end;

function TRMDSDQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDSDQuery.SetDataSource(Value: string);
var
  lComponent: TComponent;
begin
  lComponent := RMFindComponent(FQuery.Owner, Value);
  if (lComponent <> nil) and (lComponent is TDataSet) then
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(lComponent))
  else
    FQuery.DataSource := nil;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

type
  TSessionNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TDatabaseParamsEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TQueryDatabaseNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TSessionNameEditor }

function TSessionNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TSessionNameEditor.GetValues(AValues: TStrings);
begin
  SDEngine.Sessions.GetSessionNames(AValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{}

function TDatabaseParamsEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TDatabaseParamsEditor.Edit;
var
  tmp: TELStringsEditorDlg;
begin
  tmp := TELStringsEditorDlg.Create(nil);
  try
    tmp.Lines.Assign(TRMDSDDatabase(GetInstance(0)).Params);
    if tmp.ShowModal = mrOK then
    begin
      TRMDSDDatabase(GetInstance(0)).Params.Assign(tmp.Lines);
    end;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TQueryDatabaseNameEditor }

function TQueryDatabaseNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TQueryDatabaseNameEditor.GetValues(AValues: TStrings);
begin
  try
    RMGetComponents(RMDialogForm, TSDDatabase, AValues, nil);
  finally
  end;
end;

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMDSDDatabase, 'TRMDSDDatabase');
    AddClass('ReportMachine', TRMDSDQuery, 'TRMDSDQuery');

    AddConst('ReportMachine', 'stDB2', stDB2);
    AddConst('ReportMachine', 'stInformix', stInformix);
    AddConst('ReportMachine', 'stInterbase', stInterbase);
    AddConst('ReportMachine', 'stMySQL', stMySQL);
    AddConst('ReportMachine', 'stODBC', stODBC);
    AddConst('ReportMachine', 'stOracle', stOracle);
    AddConst('ReportMachine', 'stSQLBase', stSQLBase);
    AddConst('ReportMachine', 'stSQLServer', stSQLServer);
    AddConst('ReportMachine', 'stSybase', stSybase);
    AddConst('ReportMachine', 'tiDirtyRead', tiDirtyRead);
    AddConst('ReportMachine', 'tiReadCommitted', tiReadCommitted);
    AddConst('ReportMachine', 'tiRepeatableRead2', tiRepeatableRead);
    AddConst('ReportMachine', 'stDB2', stDB2);
    AddConst('ReportMachine', 'stDB2', stDB2);

    RMRegisterPropEditor(TypeInfo(string), TRMDSDDatabase, 'Params', TDatabaseParamsEditor);
    RMRegisterPropEditor(TypeInfo(string), TRMDSDDatabase, 'SessionName', TSessionNameEditor);

    RMRegisterPropEditor(TypeInfo(string), TRMDSDQuery, 'SessionName', TSessionNameEditor);
    RMRegisterPropEditor(TypeInfo(string), TRMDSDQuery, 'DatabaseName', TQueryDatabaseNameEditor);
  end;
end;

initialization
  RMRegisterControl(TRMDSDDatabase, 'RMD_SDDATABASEcontrol', 'SDDatabase');
  RMRegisterControl(TRMDSDQuery, 'RMD_SDQUERYCONTROL', 'SDQuery');

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

