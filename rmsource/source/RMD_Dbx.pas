
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{             Wrapper for Dbx             }
{                                         }
{*****************************************}

unit RMD_Dbx;

interface

{$I RM.INC}

{$IFDEF DM_DBX}
uses
  Windows, Classes, SysUtils, Forms, Dialogs, ExtCtrls, StdCtrls, Controls, DB,
  SqlExpr, RM_Class, RMD_DBWrap
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants, ValEdit, Menus{$ENDIF}
{$IFDEF COMPILER7_UP}, SimpleDS{$ELSE}, DBLocalS{$ENDIF};

type
  TRMDDBXComponents = class(TComponent) // fake component
  end;

 { TRMDDBXDatabase }
  TRMDDBXDatabase = class(TRMDialogComponent)
  private
    FDatabase: TSQLConnection;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetConnectionName: string;
    procedure SetConnectionName(Value: string);
    function GetDriverName: string;
    procedure SetDriverName(Value: string);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetParams: string;
    procedure SetParams(Value: string);
  protected
    procedure AfterChangeName; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
  published
    property Database: TSQLConnection read FDatabase;
    property Connected: Boolean read GetConnected write SetConnected;
    property ConnectionName: string read GetConnectionName write SetConnectionName;
    property DriverName: string read GetDriverName write SetDriverName;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property Params: string read GetParams write SetParams;
  end;

 { TRMDDBXTable }
  TRMDDBXTable = class(TRMDTable)
  private
    FTable: TSQLTable;
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
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(Value: string); override;

    function GetIndexDefs: TIndexDefs; override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
	published
    property IndexName;
  end;

  { TRMDDBXQuery}
  TRMDDBXQuery = class(TRMDQuery)
  private
{$IFDEF COMPILER7_UP}
    FQuery: TSimpleDataSet;
{$ELSE}
    FQuery: TSQLClientDataSet;
{$ENDIF}

    procedure OnSQLTextChangedEvent(Sender: TObject);
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
  TRMDFormDbxDBProp = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    StringEditorMenu: TPopupMenu;
    LoadItem: TMenuItem;
    SaveItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadItemClick(Sender: TObject);
    procedure SaveItemClick(Sender: TObject);
  private
    FValueListEditor: TValueListEditor;

    procedure Localize;
  end;
{$ENDIF}

implementation

{$IFDEF DM_DBX}
{$R *.DFM}
{$R RMD_DBX.RES}

uses RM_Utils, RM_Common, RM_Const, RM_PropInsp, RM_Insp;

type
  THackSQLConnection = class(TSQLConnection)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDBXDatabase}

constructor TRMDDBXDatabase.Create;
begin
  inherited Create;
  BaseName := 'DBXDatabase';
  FBmpRes := 'RMD_DBXDB';

  FDatabase := TSQLConnection.Create(RMDialogForm);
  THackSQLConnection(FDataBase).SetDesigning(True, False);
  DontUndo := True;
  FComponent := FDatabase;
end;

destructor TRMDDBXDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FDatabase.Free;
    FDatabase := nil;
  end;
  inherited Destroy;
end;

procedure TRMDDBXDatabase.AfterChangeName;
begin
  FDatabase.Name := Name;
end;

procedure TRMDDBXDatabase.LoadFromStream(aStream: TStream);
var
  lVersion: Integer;
  lStr: string;
{$IFDEF COMPILER10_UP}
  lStrList: TStringList;
{$ENDIF}
begin
  inherited LoadFromStream(aStream);
  lVersion := RMReadWord(aStream);
  FDatabase.ConnectionName := RMReadString(aStream);
  lStr := RMReadString(aStream);
  if lStr <> '' then
    FDatabase.DriverName := lStr;
  FDatabase.LoginPrompt := RMReadBoolean(aStream);

  if lVersion >= 1 then
  begin
    FDatabase.Params.Text := RMReadWideString(aStream);
  end
  else
  begin
  {$IFDEF COMPILER10_UP}
    lStrList := TStringList.Create;
    RMReadMemo(aStream, lStrList);
    FDatabase.Params.Assign(lStrList);
    lStrList.Free;
  {$ELSE}
    RMReadMemo(aStream, FDatabase.Params);
  {$ENDIF}
  end;

  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDDBXDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 1);
  RMWriteString(aStream, FDatabase.ConnectionName);
  RMWriteString(aStream, FDatabase.DriverName);
  RMWriteBoolean(aStream, FDatabase.LoginPrompt);
  RMWriteWideString(aStream, FDatabase.Params.Text);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

procedure TRMDDBXDatabase.ShowEditor;
var
  tmp: TRMDFormDbxDBProp;
  SaveConnected: Boolean;
begin
  tmp := TRMDFormDbxDBProp.Create(nil);
  try
    tmp.FValueListEditor.Strings.Assign(FDatabase.Params);
    if tmp.ShowModal = mrOk then
    begin
      RMDesigner.BeforeChange;
      SaveConnected := FDatabase.Connected;
      FDatabase.Connected := False;
      FDatabase.Params.Assign(tmp.FValueListEditor.Strings);
      FDatabase.Connected := SaveConnected;
      RMDesigner.AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

function TRMDDBXDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDDBXDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDDBXDatabase.GetConnectionName: string;
begin
  Result := FDatabase.ConnectionName;
end;

procedure TRMDDBXDatabase.SetConnectionName(Value: string);
begin
  FDatabase.ConnectionName := Value;
end;

function TRMDDBXDatabase.GetDriverName: string;
begin
  Result := FDatabase.DriverName;
end;

procedure TRMDDBXDatabase.SetDriverName(Value: string);
begin
  FDatabase.DriverName := Value;
end;

function TRMDDBXDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDDBXDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDDBXDatabase.GetParams: string;
begin
  Result := FDatabase.Params.Text;
end;

procedure TRMDDBXDatabase.SetParams(Value: string);
begin
  FDatabase.Params.Text := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDBXTable}

constructor TRMDDBXTable.Create;
begin
  inherited Create;
  BaseName := 'DBXTable';
  FBmpRes := 'RMD_DBXTABLE';

  FCanBrowse := False;
  FHaveFilter := False;
  FTable := TSQLTable.Create(RMDialogForm);
  DataSet := FTable;
  FComponent := FTable;
end;

procedure TRMDDBXTable.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDDBXTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

procedure TRMDDBXTable.GetIndexNames(sl: TStrings);
var
  i: integer;
begin
  try
    if (Length(FTable.TableName) > 0) and (FTable.IndexDefs <> nil) then
    begin
      FTable.IndexDefs.Update;
      for i := 0 to FTable.IndexDefs.Count - 1 do
      begin
        if FTable.IndexDefs[i].Name <> '' then
          sl.Add(FTable.IndexDefs[i].Name);
      end;
    end;
  except
  end;
end;

function TRMDDBXTable.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDDBXTable.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDDBXTable.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TRMDDBXTable.GetDatabaseName: string;
begin
  Result := '';
  if FTable.SQLConnection <> nil then
  begin
    Result := FTable.SQLConnection.Name;
    if FTable.SQLConnection.Owner <> FTable.Owner then
      Result := FTable.SQLConnection.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDDBXTable.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FTable.Close;
  liComponent := RMFindComponent(FTable.Owner, Value);

  if (liComponent <> nil) and (liComponent is TSQLConnection) then
    FTable.SQLConnection := TSQLConnection(liComponent)
  else
    FTable.SQLConnection := nil;
end;

function TRMDDBXTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDDBXTable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDDBXTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDDBXTable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDDBXTable.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDDBXTable.SetIndexName(Value: string);
begin
  FTable.IndexName := Value;
end;

function TRMDDBXTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDDBXTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDDBXTable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDDBXTable.SetMasterSource(Value: string);
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
{TRMDDBXQuery}

type
{$IFDEF COMPILER7_UP}
  THackClientDataSet = class(TSimpleDataSet)
{$ELSE}
  THackClientDataSet = class(TSQLClientDataSet)
{$ENDIF}
  end;

constructor TRMDDBXQuery.Create;
begin
  inherited Create;
  BaseName := 'DBXQuery';
  FBmpRes := 'RMD_DBXQUERY';

{$IFDEF COMPILER7_UP}
  FQuery := TSimpleDataSet.Create(RMDialogForm);
  FQuery.DataSet.CommandType := ctQuery;
{$ELSE}
  FQuery := TSQLClientDataSet.Create(RMDialogForm);
  FQuery.CommandType := ctQuery;
{$ENDIF}
  OnSQLTextChanged := OnSQLTextChangedEvent;
  THackClientDataSet(FQuery).SetDesigning(True, False);
  DataSet := FQuery;
end;

procedure TRMDDBXQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMDDBXQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

function TRMDDBXQuery.GetParamCount: Integer;
begin
  Result := FQuery.Params.Count;
end;

function TRMDDBXQuery.GetSQL: string;
begin
{$IFDEF COMPILER7_UP}
  Result := FQuery.DataSet.CommandText
{$ELSE}
  Result := FQuery.CommandText
{$ENDIF}
end;

procedure TRMDDBXQuery.SetSQL(Value: string);
begin
  FQuery.Close;
{$IFDEF COMPILER7_UP}
  FQuery.DataSet.CommandText := Value;
{$ELSE}
  FQuery.CommandText := Value;
{$ENDIF}
end;

function TRMDDBXQuery.GetDatabaseName: string;

  function _GetDataBase(Owner: TComponent; d: TSQLConnection): string;
  begin
    Result := '';
    if d <> nil then
    begin
      Result := d.Name;
      if d.Owner <> Owner then
        Result := d.Owner.Name + '.' + Result;
    end;
  end;

begin
{$IFDEF COMPILER7_UP}
  Result := _GetDataBase(FQuery.Owner, FQuery.Connection)
{$ELSE}
  Result := _GetDataBase(FQuery.Owner, FQuery.DBConnection)
{$ENDIF}
end;

procedure TRMDDBXQuery.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FQuery.Close;
  liComponent := RMFindComponent(FQuery.Owner, Value);
{$IFDEF COMPILER7_UP}
  if (liComponent <> nil) and (liComponent is TSQLConnection) then
    FQuery.Connection := TSQLConnection(liComponent)
  else
    FQuery.Connection := nil;
{$ELSE}
  if (liComponent <> nil) and (liComponent is TSQLConnection) then
    FQuery.DBConnection := TSQLConnection(liComponent)
  else
    FQuery.DBConnection := nil;
{$ENDIF}
end;

function TRMDDBXQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDDBXQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDDBXQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDDBXQuery.SetDataSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FQuery.MasterSource := RMGetDataSource(FQuery.Owner, TDataSet(liComponent))
  else
    FQuery.MasterSource := nil;
end;

procedure TRMDDBXQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TSQLConnection, liStringList, nil);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDDBXQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
begin
{$IFDEF COMPILER7_UP}
  if FQuery.Connection <> nil then
{$ELSE}
  if FQuery.DBConnection <> nil then
{$ENDIF}
  begin
    sl := TStringList.Create;
    try
      try
{$IFDEF COMPILER7_UP}
        FQuery.Connection.GetTableNames(sl);
{$ELSE}
        FQuery.DBConnection.GetTableNames(sl);
{$ENDIF}
        sl.Sort;
        Strings.Assign(sl);
      except
      end;
    finally
      sl.Free;
    end;
  end;
end;

procedure TRMDDBXQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TSQLTable;
begin
  lStrings := TStringList.Create;
  t := TSQLTable.Create(RMDialogForm);
  try
{$IFDEF COMPILER7_UP}
    t.SQLConnection := FQuery.Connection;
{$ELSE}
    t.SQLConnection := FQuery.DBConnection;
{$ENDIF}
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

function TRMDDBXQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDDBXQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDDBXQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDDBXQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDDBXQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

function TRMDDBXQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDDBXQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDDBXQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDDBXQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;

procedure TRMDDBXQuery.OnSQLTextChangedEvent(Sender: TObject);
begin
  try
    FQuery.Open;
    FQuery.Close;
  except
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TDBEditForm}

procedure TRMDFormDbxDBProp.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  btnOK.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDFormDbxDBProp.btnOKClick(Sender: TObject);
begin
  ModalResult := mrNone;
  try
  except
    raise;
  end;
  ModalResult := mrOk;
end;

procedure TRMDFormDbxDBProp.FormCreate(Sender: TObject);
begin
  FValueListEditor := TValueListEditor.Create(Self);
  with FValueListEditor do
  begin
    Parent := Self;
    Left := 8;
    Top := 7;
    Width := 412;
    Height := 233;
    KeyOptions := [keyEdit, keyAdd, keyDelete];
    PopupMenu := StringEditorMenu;
  end;

  Localize;
end;

procedure TRMDFormDbxDBProp.LoadItemClick(Sender: TObject);
begin
  with OpenDialog do
  begin
    if Execute then
      FValueListEditor.Strings.LoadFromFile(FileName);
  end;
end;

procedure TRMDFormDbxDBProp.SaveItemClick(Sender: TObject);
begin
  SaveDialog.FileName := OpenDialog.FileName;
  with SaveDialog do
  begin
    if Execute then
      FValueListEditor.Strings.SaveToFile(FileName);
  end;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TParamsEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TConnectionNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TDriverNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
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

  TTableNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TParamsEditor }

function TParamsEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TParamsEditor.Edit;
begin
  TRMDDBXDatabase(GetInstance(0)).ShowEditor;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TConnectionNameEditor }

function TConnectionNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TConnectionNameEditor.GetValues(AValues: TStrings);
begin
  GetConnectionNames(AValues);
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
  GetDriverNames(AValues);
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
  try
    RMGetComponents(RMDialogForm, TSQLConnection, AValues, nil);
  finally
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
  liTable: TRMDDBXTable;
begin
  liTable := TRMDDBXTable(GetInstance(0));
  liTable.GetIndexNames(aValues);
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
  liTable: TSQLTable;
begin
  liTable := TRMDDBXTable(GetInstance(0)).FTable;
  if liTable.SQLConnection <> nil then
  begin
    liTable.SQLConnection.GetTableNames(AValues);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMDDBXQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDDBXQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDDBXQuery(Args.Obj).FQuery);
  TRMDDBXQuery(Args.Obj).FQuery.Execute;
end;

const
	cReportMachine = 'RMD_Dbx';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDDBXDatabase, 'TRMDDBXDataset');
    AddClass(cReportMachine, TRMDDBXTable, 'TRMDDBXTable');
    AddClass(cReportMachine, TRMDDBXQuery, 'TRMDDBXQuery');

    AddGet(TRMDDataset, 'ExecSql', TRMDDBXQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
//  RMRegisterControl(TRMDDBXDatabase, 'RMD_DBXDB', RMLoadStr(SInsertDB) + '(DBX)');
//  RMRegisterControl(TRMDDBXTable, 'RMD_DBXTable', RMLoadStr(SInsertTable) + '(DBX)');
//  RMRegisterControl(TRMDDBXQuery, 'RMD_DBXQUERY', RMLoadStr(SInsertQuery) + '(DBX)');
  RMRegisterControls('DBX', 'RMD_DBXPATH', True,
    [TRMDDBXDatabase, TRMDDBXTable, TRMDDBXQuery],
    ['RMD_DBXDB', 'RMD_DBXTable', 'RMD_DBXQUERY'],
    [RMLoadStr(SInsertDB), RMLoadStr(SInsertTable), RMLoadStr(SInsertQuery)]);

  RMRegisterPropEditor(TypeInfo(string), TRMDDBXDatabase, 'Params', TParamsEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDBXDatabase, 'ConnectionName', TConnectionNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDBXDatabase, 'DriverName', TDriverNameEditor);


  RMRegisterPropEditor(TypeInfo(string), TRMDDBXTable, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDBXTable, 'IndexName', TIndexNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDBXTable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDDBXQuery, 'DatabaseName', TDatabaseEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

{$ENDIF}
end.

