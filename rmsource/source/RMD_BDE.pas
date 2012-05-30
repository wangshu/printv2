
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{             Wrapper for BDE             }
{                                         }
{*****************************************}

unit RMD_BDE;

interface

{$I RM.INC}

{$IFDEF DM_BDE}
uses
  Windows, Classes, SysUtils, Forms, Dialogs, ExtCtrls, StdCtrls, Controls, DB,
  DBTables, RM_Class, RMD_DBWrap
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvInterpreter, rm_JvInterpreter_DbTables
{$ELSE}
  , JvInterpreter, JvInterpreter_DbTables
{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDBDEComponents = class(TComponent) // fake component
  end;

 { TRMDBDEDatabase }
  TRMDBDEDatabase = class(TRMDialogComponent)
  private
    FDatabase: TDatabase;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetAliasName: string;
    procedure SetAliasName(Value: string);
    function GetDriverName: string;
    procedure SetDriverName(Value: string);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetParams: TStrings;
    procedure SetParams(Value: TStrings);
    function GetDatabaseName: string;
    procedure SetDatabaseName(Value: string);
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
    property Database: TDatabase read FDatabase;
  published
    property Connected: Boolean read GetConnected write SetConnected;
    property AliasName: string read GetAliasName write SetAliasName;
    property DriverName: string read GetDriverName write SetDriverName;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property Params: TStrings read GetParams write SetParams;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
  end;

  { TRMDBDETable }
  TRMDBDETable = class(TRMDTable)
  private
    FTable: TTable;
  protected
    function GetTableName: string; override;
    procedure SetTableName(Value: string); override;
    function GetFilter: string; override;
    procedure SetFilter(Value: string); override;
    function GetIndexName: string; override;
    procedure SetIndexName(Value: string); override;
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(Value: string); override;
    function GetMasterFields: string; override;
    procedure SetMasterFields(Value: string); override;
    function GetMasterSource: string; override;
    procedure SetMasterSource(Value: string); override;
    function GetDatabaseName: string; override;
    procedure SetDatabaseName(const Value: string); override;
    procedure GetIndexNames(sl: TStrings); override;
    function GetIndexDefs: TIndexDefs; override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
	published
    property IndexName;
  end;

  { TRMDBDEQuery}
  TRMDBDEQuery = class(TRMDQuery)
  private
    FQuery: TQuery;
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
  	property DataSource;
  end;

  { TDBEditForm }
  TRMDFormBDEDBProp = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    cmbAliasName: TComboBox;
    Label2: TLabel;
    cmbDriverName: TComboBox;
    Label3: TLabel;
    memDatabaseParams: TMemo;
    btnDefaultsParam: TButton;
    btnClearParam: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    Label4: TLabel;
    edtDBName: TEdit;
    btnPath: TButton;
    procedure cmbAliasNameChange(Sender: TObject);
    procedure cmbAliasNameDropDown(Sender: TObject);
    procedure cmbDriverNameChange(Sender: TObject);
    procedure cmbDriverNameDropDown(Sender: TObject);
    procedure btnDefaultsParamClick(Sender: TObject);
    procedure btnClearParamClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FDatabase: TDatabase;
    function Edit: Boolean;
    procedure Localize;
  end;
{$ENDIF}

implementation

{$IFDEF DM_BDE}
{$R *.DFM}
{$R RMD_BDE.RES}

uses BdeConst, BDE, RM_Utils, RM_Const, RM_DsgCtrls, RM_Common, RM_PropInsp, RM_Insp;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDBDEDatabase}

constructor TRMDBDEDatabase.Create;
begin
  inherited Create;
  BaseName := 'Database';
  FBmpRes := 'RMD_BDEDB';

  FDatabase := TDataBase.Create(RMDialogForm);
  DontUndo := True;
  FComponent := FDatabase;
end;

destructor TRMDBDEDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FreeAndNil(FDatabase);
  end;

  inherited Destroy;
end;

procedure TRMDBDEDatabase.LoadFromStream(aStream: TStream);
var
  s: string;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDatabase.DatabaseName := RMReadString(aStream);
  s := RMReadString(aStream);
  if s <> '' then
    FDatabase.AliasName := s;
  s := RMReadString(aStream);
  if s <> '' then
    FDatabase.DriverName := s;
  FDatabase.LoginPrompt := RMReadBoolean(aStream);
  RMReadMemo(aStream, FDatabase.Params);
  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDBDEDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FDatabase.DatabaseName);
  RMWriteString(aStream, FDatabase.AliasName);
  RMWriteString(aStream, FDatabase.DriverName);
  RMWriteBoolean(aStream, FDatabase.LoginPrompt);
  RMWriteMemo(aStream, FDatabase.Params);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

function TRMDBDEDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDBDEDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDBDEDatabase.GetAliasName: string;
begin
  Result := FDatabase.AliasName;
end;

procedure TRMDBDEDatabase.SetAliasName(Value: string);
begin
  FDatabase.AliasName := Value;
end;

function TRMDBDEDatabase.GetDriverName: string;
begin
  Result := FDatabase.DriverName;
end;

procedure TRMDBDEDatabase.SetDriverName(Value: string);
begin
  FDatabase.DriverName := Value;
end;

function TRMDBDEDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDBDEDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDBDEDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Params;
end;

procedure TRMDBDEDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Params.Assign(Value);
end;

function TRMDBDEDatabase.GetDatabaseName: string;
begin
  Result := FDatabase.DatabaseName;
end;

procedure TRMDBDEDatabase.SetDatabaseName(Value: string);
begin
  FDatabase.DatabaseName := Value;
end;

procedure TRMDBDEDatabase.ShowEditor;
var
  tmp: TRMDFormBDEDBProp;
begin
  tmp := TRMDFormBDEDBProp.Create(nil);
  try
    tmp.FDatabase := Self.FDatabase;
    if tmp.Edit then
    begin
      RMDesigner.BeforeChange;
      RMDesigner.AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDBDETable}

constructor TRMDBDETable.Create;
begin
  inherited Create;
  BaseName := 'Table';
  FBmpRes := 'RMD_BDETABLE';

  FTable := TTable.Create(RMDialogForm);
  DataSet := FTable;
  FComponent := FTable;
  FIndexBased := True;
end;

procedure TRMDBDETable.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDBDETable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

procedure TRMDBDETable.GetIndexNames(sl: TStrings);
begin
  try
    if Length(FTable.TableName) > 0 then
    begin
      FTable.GetIndexNames(sl);
    end;
  except
  end;
end;

function TRMDBDETable.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TRMDBDETable.GetDatabaseName: string;
begin
  Result := FTable.DatabaseName;
end;

procedure TRMDBDETable.SetDatabaseName(const Value: string);
begin
  FTable.Active := False;
  FTable.DatabaseName := Value;
end;

function TRMDBDETable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDBDETable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDBDETable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDBDETable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDBDETable.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDBDETable.SetIndexName(Value: string);
begin
  FTable.Active := False;
  FTable.IndexName := Value;
end;

function TRMDBDETable.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDBDETable.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDBDETable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDBDETable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDBDETable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDBDETable.SetMasterSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FTable.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FTable.MasterSource := RMGetDataSource(FTable.Owner, TDataSet(liComponent))
  else
    FTable.MasterSource := nil;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDBDEQuery}

constructor TRMDBDEQuery.Create;
begin
  inherited Create;
  BaseName := 'Query';
  FBmpRes := 'RMD_BDEQUERY';

  FQuery := TQuery.Create(RMDialogForm);
  DataSet := FQuery;
  FComponent := FQuery;
end;

procedure TRMDBDEQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDBDEQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

function TRMDBDEQuery.GetParamCount: Integer;
begin
  Result := FQuery.ParamCount;
end;

function TRMDBDEQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDBDEQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDBDEQuery.GetDatabaseName: string;
begin
  Result := FQuery.DatabaseName;
end;

procedure TRMDBDEQuery.SetDatabaseName(const Value: string);
begin
  FQuery.Active := False;
  FQuery.DatabaseName := Value;
end;

function TRMDBDEQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDBDEQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDBDEQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDBDEQuery.SetDataSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(liComponent))
  else
    FQuery.DataSource := nil;
end;

procedure TRMDBDEQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    Session.GetAliasNames(liStringList);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDBDEQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    try
      Session.GetTableNames(DB, '', True, False, sl);
      sl.Sort;
      Strings.Assign(sl);
    except;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDBDEQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TTable;
begin
  lStrings := TStringList.Create;
  t := TTable.Create(RMDialogForm);
  try
    t.DatabaseName := DB;
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

function TRMDBDEQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDBDEQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDBDEQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDBDEQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDBDEQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

function TRMDBDEQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDBDEQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDBDEQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDBDEQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TDBEditForm}

procedure TRMDFormBDEDBProp.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 3233);
  RMSetStrProp(Label4, 'Caption', rmRes + 3234);
  RMSetStrProp(Label1, 'Caption', rmRes + 3235);
  RMSetStrProp(Label2, 'Caption', rmRes + 3236);
  RMSetStrProp(Label3, 'Caption', rmres + 3237);
  RMSetStrProp(btnDefaultsParam, 'Caption', rmRes + 3238);
  RMSetStrProp(btnClearParam, 'Caption', rmRes + 3239);
  RMSetStrProp(btnPath, 'Caption', rmRes + 3240);

  btnOK.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMDFormBDEDBProp.Edit: Boolean;
begin
  edtDBName.Text := FDatabase.DatabaseName;
  cmbAliasName.Text := FDatabase.AliasName;
  cmbDriverName.Text := FDatabase.DriverName;
  memDatabaseParams.Lines := FDatabase.Params;
  Result := False;
  if ShowModal = mrOk then
  begin
    FDatabase.DatabaseName := edtDBName.Text;
    if cmbDriverName.Text <> '' then
      FDatabase.DriverName := cmbDriverName.Text
    else
      FDatabase.AliasName := cmbAliasName.Text;
    FDatabase.Params := memDatabaseParams.Lines;
    Result := True;
  end;
end;

procedure TRMDFormBDEDBProp.cmbAliasNameChange(Sender: TObject);
begin
  cmbDriverName.Text := '';
end;

procedure TRMDFormBDEDBProp.cmbAliasNameDropDown(Sender: TObject);
begin
  cmbAliasName.Items.Clear;
  FDatabase.Session.GetAliasNames(cmbAliasName.Items);
end;

procedure TRMDFormBDEDBProp.cmbDriverNameChange(Sender: TObject);
begin
  cmbAliasName.Text := '';
end;

procedure TRMDFormBDEDBProp.cmbDriverNameDropDown(Sender: TObject);
begin
  cmbDriverName.Items.Clear;
  FDatabase.Session.GetDriverNames(cmbDriverName.Items);
end;

procedure TRMDFormBDEDBProp.btnDefaultsParamClick(Sender: TObject);
var
  AddPassword: Boolean;
begin
  memDatabaseParams.Clear;
  AddPassword := False;
  if cmbDriverName.Text <> '' then
  begin
    FDatabase.Session.GetDriverParams(cmbDriverName.Text, memDatabaseParams.Lines);
    AddPassword := cmbDriverName.Text <> szCFGDBSTANDARD;
  end
  else if cmbAliasName.Text <> '' then
  begin
    FDatabase.Session.GetAliasParams(cmbAliasName.Text, memDatabaseParams.Lines);
    AddPassword := FDatabase.Session.GetAliasDriverName(cmbAliasName.Text) <> szCFGDBSTANDARD;
  end;

  if AddPassword then memDatabaseParams.Lines.Add('PASSWORD=');
end;

procedure TRMDFormBDEDBProp.btnClearParamClick(Sender: TObject);
begin
  memDatabaseParams.Clear;
end;

procedure TRMDFormBDEDBProp.btnPathClick(Sender: TObject);
var
  str: string;
begin
  if RMSelectDirectory(RMLoadStr(rmRes + 3252), '', str) then
    memDatabaseParams.Lines.Values['PATH'] := str;
//  if SelectDirectory(str, [], 0) then
//    memDatabaseParams.Lines.Values['PATH'] := str;
end;

procedure TRMDFormBDEDBProp.btnOKClick(Sender: TObject);
begin
  ModalResult := mrNone;
  try
    FDatabase.ValidateName(edtDBName.Text);
  except
    edtDBName.SetFocus;
    raise;
  end;
  if FDatabase.Connected then
  begin
    if MessageDlg(SDisconnectDatabase, mtConfirmation,
      mbOkCancel, 0) <> mrOk then Exit;
    FDatabase.Close;
  end;
  ModalResult := mrOk;
end;

procedure TRMDFormBDEDBProp.FormCreate(Sender: TObject);
begin
  Localize;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TAliasNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TDriverNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TDatabaseNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TDatabaseEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TIndexNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TIndexFieldNamesEditor = class(TELStringPropEditor)
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
{ TAliasNameEditor }

function TAliasNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TAliasNameEditor.GetValues(AValues: TStrings);
begin
  Session.GetAliasNames(aValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDriverNameEditor }

function TDriverNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TDriverNameEditor.GetValues(AValues: TStrings);
begin
  Session.GetDriverNames(aValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDatabaseNameEditor }

function TDatabaseNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TDatabaseNameEditor.Edit;
begin
  TRMDBDEDatabase(GetInstance(0)).ShowEditor;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDatabaseEditor }

function TDatabaseEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TDatabaseEditor.GetValues(AValues: TStrings);
begin
  Session.GetAliasNames(aValues);
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
  liTable: TRMDBDETable;
begin
  liTable := TRMDBDETable(GetInstance(0));
  liTable.GetIndexNames(aValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TIndexFieldNamesEditor }

function TIndexFieldNamesEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TIndexFieldNamesEditor.GetValues(AValues: TStrings);
var
  lTable: TRMDBDETable;
  i: Integer;
begin
  lTable := TRMDBDETable(GetInstance(0));
  lTable.IndexDefs.Update;
  for i := 0 to lTable.IndexDefs.Count - 1 do
  begin
    aValues.Add(lTable.IndexDefs[i].Fields);
  end;
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
  liTable: TTable;
begin
  liTable := TRMDBDETable(GetInstance(0)).FTable;
  if liTable.DatabaseName <> '' then
  begin
    Session.GetTableNames(liTable.DatabaseName, '', True, False, aValues);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMDBDEQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDBDEQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDBDEQuery(Args.Obj).FQuery);
  TRMDBDEQuery(Args.Obj).FQuery.ExecSQL;
end;

const
	cReportMachine = 'RMD_BDE';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDBDEDatabase, 'TRMDBDEDataSet');
    AddClass(cReportMachine, TRMDBDETable, 'TRMDBDETable');
    AddClass(cReportMachine, TRMDBDEQuery, 'TRMDBDEQuery');

    { TRMDBDEQuery }
    AddGet(TRMDDataset, 'ExecSql', TRMDBDEQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
//  RMRegisterControl(TRMDBDEDatabase, 'RMD_BDEDB', RMLoadStr(SInsertDB) + '(BDE)');
//  RMRegisterControl(TRMDBDETable, 'RMD_BDETABLE', RMLoadStr(SInsertTable) + '(BDE)');
//  RMRegisterControl(TRMDBDEQuery, 'RMD_BDEQUERY', RMLoadStr(SInsertQuery) + '(BDE)');
  RMRegisterControls('BDE', 'RMD_BDEPATH', True,
    [TRMDBDEDatabase, TRMDBDETable, TRMDBDEQuery],
    ['RMD_BDEDB', 'RMD_BDETABLE', 'RMD_BDEQUERY'],
    [RMLoadStr(SInsertDB), RMLoadStr(SInsertTable), RMLoadStr(SInsertQuery)]);

  RMRegisterPropEditor(TypeInfo(string), TRMDBDEDatabase, 'AliasName', TAliasNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDBDEDatabase, 'DriverName', TDriverNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDBDEDatabase, 'DatabaseName', TDatabaseNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDBDETable, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDBDETable, 'IndexName', TIndexNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDBDETable, 'IndexFieldNames', TIndexFieldNamesEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDBDETable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDBDEQuery, 'DatabaseName', TDatabaseEditor);

{$IFDEF USE_INTERNAL_JVCL}
  rm_JvInterpreter_DbTables.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
{$ELSE}
  JvInterpreter_DbTables.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
{$ENDIF}
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

{$ENDIF}
end.

