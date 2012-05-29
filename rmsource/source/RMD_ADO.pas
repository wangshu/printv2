
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{             Wrapper for ADO             }
{                                         }
{*****************************************}

unit RMD_ADO;

interface

{$I RM.INC}
{$IFDEF DM_ADO}
uses
  Windows, Classes, SysUtils, Graphics, Forms, ExtCtrls, DB, ADODB, ADOInt,
  StdCtrls, Controls, RM_Class, RMD_DBWrap
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDADOComponents = class(TComponent) // fake component
  end;

  TRMDADODatabase = class(TRMDialogComponent)
  private
    FDatabase: TADOConnection;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetConnectionString: WideString;
    procedure SetConnectionString(Value: WideString);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetCursorLocation: TCursorLocation;
    procedure SetCursorLocation(Value: TCursorLocation);
  protected
    procedure AfterChangeName; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
  published
    property Database: TADOConnection read FDatabase;
    property Connected: Boolean read GetConnected write SetConnected;
    property ConnectionString: WideString read GetConnectionString write SetConnectionString;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property CursorLocation: TCursorLocation read GetCursorLocation write SetCursorLocation;
  end;

 { TRMDADOTable }
  TRMDADOTable = class(TRMDTable)
  private
    FTable: TADOTable;
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
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(Value: string); override;

    procedure GetIndexNames(sl: TStrings); override;
    function GetIndexDefs: TIndexDefs; override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property IndexName;
  end;

  { TRMDADOQuery }
  TRMDADOQuery = class(TRMDQuery)
  private
    FQuery: TADOQuery;
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

 { TConnEditForm }
  TRMDFormADOConnEdit = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    SourceofConnection: TGroupBox;
    UseDataLinkFile: TRadioButton;
    UseConnectionString: TRadioButton;
    DataLinkFile: TComboBox;
    Browse: TButton;
    ConnectionString: TEdit;
    Build: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BuildClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure SourceButtonClick(Sender: TObject);
  private
    procedure Localize;
  public
    function Edit(var ConnStr: WideString): boolean;
  end;

  //lxj
var
  theThirdConnection: TAdoConnection;
{$ENDIF}
implementation

{$IFDEF DM_ADO}
uses RM_Const, RM_Common, RM_utils, RM_PropInsp, RM_Insp;

{$R *.DFM}
{$R RMD_ADO.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDADODatabase}

constructor TRMDADODatabase.Create;
begin
  inherited Create;
  BaseName := 'ADODatabase';
  FBmpRes := 'RMD_ADODB';

  DontUndo := True;
  FDatabase := TADOConnection.Create(RMDialogForm);
  FComponent := FDatabase;
end;

destructor TRMDADODatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FDatabase.Free;
    FDatabase := nil;
  end;
  inherited Destroy;
end;

procedure TRMDADODatabase.AfterChangeName;
begin
  FDatabase.Name := Name;
end;

procedure TRMDADODatabase.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  ConnectionString := RMReadString(aStream);
  LoginPrompt := RMReadBoolean(aStream);
  CursorLocation := TCursorLocation(RMReadByte(aStream));
  Connected := RMReadBoolean(aStream);
end;

procedure TRMDADODatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, ConnectionString);
  RMWriteBoolean(aStream, LoginPrompt);
  RMWriteByte(aStream, Byte(CursorLocation));
  RMWriteBoolean(aStream, Connected);
end;

procedure TRMDADODatabase.ShowEditor;
var
  InitialConnStr: WideString;
  tmp: TRMDFormADOConnEdit;
begin
  tmp := TRMDFormADOConnEdit.Create(nil);
  try
    InitialConnStr := FDatabase.ConnectionString;
    if tmp.Edit(InitialConnStr) then
    begin
      RMDesigner.BeforeChange;
      FDatabase.Connected := FALSE;
      FDatabase.ConnectionString := InitialConnStr;
      RMDesigner.AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

function TRMDADODatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDADODatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDADODatabase.GetConnectionString: WideString;
begin
  Result := FDatabase.ConnectionString;
end;

procedure TRMDADODatabase.SetConnectionString(Value: WideString);
begin
  FDatabase.Connected := False;
  FDatabase.ConnectionString := Value;
end;

function TRMDADODatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDADODatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDADODatabase.GetCursorLocation: TCursorLocation;
begin
  Result := FDatabase.CursorLocation;
end;

procedure TRMDADODatabase.SetCursorLocation(Value: TCursorLocation);
begin
  FDatabase.CursorLocation := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDADOTable}

constructor TRMDADOTable.Create;
begin
  inherited Create;
  BaseName := 'ADOTable';
  FBmpRes := 'RMD_ADOTABLE';

  FTable := TADOTable.Create(RMDialogForm);
  DataSet := FTable;
  FComponent := FTable;
  FIndexBased := False;
end;

procedure TRMDADOTable.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FTable.CursorLocation := TCursorLocation(RMReadByte(aStream));
end;

procedure TRMDADOTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(FTable.CursorLocation));
end;

procedure TRMDADOTable.GetIndexNames(sl: TStrings);
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

function TRMDADOTable.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TRMDADOTable.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDADOTable.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDADOTable.GetDatabaseName: string;
begin
  Result := '';
  if FTable.Connection <> nil then
  begin
    Result := FTable.Connection.Name;
      //lxj
    if (FTable.Connection.Owner <> nil) and (FTable.Connection.Owner <> FTable.Owner) then
      Result := FTable.Connection.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDADOTable.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FTable.Close;
  liComponent := RMFindComponent(FTable.Owner, Value);
    //lxj
  if (liComponent = nil) and (theThirdConnection <> nil) and (theThirdConnection.Name = Value) then
    liComponent := theThirdConnection;

  if (liComponent <> nil) and (liComponent is TADOConnection) then
    FTable.Connection := TADOConnection(liComponent)
  else
    FTable.Connection := nil;  
end;

function TRMDADOTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDADOTable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDADOTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDADOTable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDADOTable.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDADOTable.SetIndexName(Value: string);
begin
  FTable.IndexName := Value;
end;

function TRMDADOTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDADOTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDADOTable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDADOTable.SetMasterSource(Value: string);
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
{TRMDADOQuery}

constructor TRMDADOQuery.Create;
begin
  inherited Create;
  BaseName := 'ADOQuery';
  FBmpRes := 'RMD_ADOQUERY';

  FQuery := TADOQuery.Create(RMDialogForm);
  DataSet := FQuery;
  FComponent := FQuery;
end;

procedure TRMDADOQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FQuery.CursorLocation := TCursorLocation(RMReadByte(aStream));
end;

procedure TRMDADOQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(FQuery.CursorLocation));
end;

function TRMDADOQuery.GetParamCount: Integer;
begin
  Result := FQuery.Parameters.Count;
end;

function TRMDADOQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDADOQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDADOQuery.GetDatabaseName: string;
begin
  Result := '';
  if FQuery.Connection <> nil then
  begin
    Result := FQuery.Connection.Name;
      //lxj
    if (FQuery.Connection.Owner <> nil) and (FQuery.Connection.Owner <> FQuery.Owner) then
      Result := FQuery.Connection.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDADOQuery.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FQuery.Close;
  liComponent := RMFindComponent(FQuery.Owner, Value);
    //lxj
  if (liComponent = nil) and (theThirdConnection <> nil) and (theThirdConnection.Name = Value) then
    liComponent := theThirdConnection;

  if (liComponent <> nil) and (liComponent is TADOConnection) then
    FQuery.Connection := TADOConnection(liComponent)
  else
    FQuery.Connection := nil;  
end;

function TRMDADOQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDADOQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDADOQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDADOQuery.SetDataSource(Value: string);
var
  lComponent: TComponent;
begin
  lComponent := RMFindComponent(FQuery.Owner, Value);
  if (lComponent <> nil) and (lComponent is TDataSet) then
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(lComponent))
  else
    FQuery.DataSource := nil;
end;

procedure TRMDADOQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TADOConnection, liStringList, nil);
    //lxj
    if theThirdConnection <> nil then
      liStringList.Add(theThirdConnection.Name);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDADOQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
  lConnection: TADOConnection;
begin
  sl := TStringList.Create;
  try
    try
      lConnection := RMFindComponent(FQuery.Owner, DB) as TADOConnection;
      if lConnection = nil then exit;
      if not lConnection.Connected then
        lConnection.Connected := True;
      if lConnection.Connected then
        lConnection.GetTableNames(sl, False);
      sl.Sort;
      Strings.Assign(sl);
    except;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDADOQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TADOTable;
begin
  lStrings := TStringList.Create;
  t := TADOTable.Create(RMDialogForm);
  try
    t.Connection := RMFindComponent(FQuery.Owner, DB) as TADOConnection;
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

function TRMDADOQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Parameters[Index].Name;
end;

function TRMDADOQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Parameters[Index].DataType;
end;

procedure TRMDADOQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Parameters[Index].DataType := Value;
end;

function TRMDADOQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not (paNullable in FQuery.Parameters[Index].Attributes) then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDADOQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
begin
  if Value = rmpkAssignFromMaster then
  begin
    FQuery.Parameters[Index].Attributes := [];
    FParams.Delete(FParams.IndexOf(FQuery.Parameters[Index].Name));
  end
  else
  begin
    FQuery.Parameters[Index].Attributes := [paNullable];
    FParams[FQuery.Parameters[Index].Name] := '';
  end;
end;

function TRMDADOQuery.GetParamText(Index: Integer): string;
var
  v: Variant;
begin
  v := '';
  if ParamKind[Index] = rmpkValue then
    v := FParams[FQuery.Parameters[Index].Name];
  if v = Null then
    v := '';
  Result := v;
end;

procedure TRMDADOQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Parameters[Index].Name] := Value;
end;

function TRMDADOQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Parameters[Index].Value;
end;

procedure TRMDADOQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Parameters[Index].Value := Value;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRNDFormADOConnEdit}

procedure TRMDFormADOConnEdit.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(SourceofConnection, 'Caption', rmRes + 3230);
  RMSetStrProp(UseDataLinkFile, 'Caption', rmRes + 3231);
  RMSetStrProp(UseConnectionString, 'Caption', rmRes + 3232);
  RMSetStrProp(Browse, 'Caption', rmRes + 3249);
  RMSetStrProp(Build, 'Caption', rmRes + 3251);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMDFormADOConnEdit.Edit(var ConnStr: WideString): boolean;
var
  FileName: string;
begin
  UseDataLinkFile.Checked := True;
  if Pos(CT_FILENAME, ConnStr) = 1 then
  begin
    FileName := Copy(ConnStr, Length(CT_FILENAME) + 1, MAX_PATH);
    if ExtractFilePath(FileName) = (DataLinkDir + '\') then
      DataLinkFile.Text := ExtractFileName(FileName)
    else
      DataLinkFile.Text := FileName;
  end
  else
  begin
    ConnectionString.Text := ConnStr;
    UseConnectionString.Checked := True;
  end;

  SourceButtonClick(nil);
  Result := FALSE;
  if ShowModal = mrOk then
  begin
    if UseConnectionString.Checked then
      ConnStr := ConnectionString.Text
    else if DataLinkFile.Text <> '' then
    begin
      if ExtractFilePath(DataLinkFile.Text) = '' then
        ConnStr := CT_FILENAME + DataLinkDir + '\' + DataLinkFile.Text
      else
        ConnStr := CT_FILENAME + DataLinkFile.Text
    end;
    Result := TRUE;
  end;
end;

procedure TRMDFormADOConnEdit.FormCreate(Sender: TObject);
begin
  Localize;
  GetDataLinkFiles(DataLinkFile.Items);
end;

procedure TRMDFormADOConnEdit.BrowseClick(Sender: TObject);
begin
  DataLinkFile.Text := PromptDataLinkFile(Handle, DataLinkFile.Text);
end;

procedure TRMDFormADOConnEdit.BuildClick(Sender: TObject);
begin
  ConnectionString.Text := PromptDataSource(Handle, ConnectionString.Text);
end;

const
  EnabledColor: array[Boolean] of TColor = (clBtnFace, clWindow);

procedure TRMDFormADOConnEdit.SourceButtonClick(Sender: TObject);
begin
  DataLinkFile.Enabled := UseDataLinkFile.Checked;
  DataLinkFile.Color := EnabledColor[DataLinkFile.Enabled];
  Browse.Enabled := DataLinkFile.Enabled;
  ConnectionString.Enabled := UseConnectionString.Checked;
  ConnectionString.Color := EnabledColor[ConnectionString.Enabled];
  Build.Enabled := ConnectionString.Enabled;
  if DataLinkFile.Enabled then
    ActiveControl := DataLinkFile
  else
    ActiveControl := ConnectionString;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TConnectionStringEditor = class(TELStringPropEditor)
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

  TTableNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TConnectionStringEditor }

function TConnectionStringEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TConnectionStringEditor.Edit;
begin
  TRMDADODatabase(GetInstance(0)).ShowEditor;
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
    RMGetComponents(RMDialogForm, TADOConnection, AValues, nil);
    //lxj
    if theThirdConnection <> nil then
      AValues.Add(theThirdConnection.Name);
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
  liTable: TRMDADOTable;
begin
  liTable := TRMDADOTable(GetInstance(0));
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
  liTable: TADOTable;
begin
  liTable := TRMDADOTable(GetInstance(0)).FTable;
  if liTable.Connection <> nil then
  begin
    liTable.Connection.GetTableNames(AValues);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
procedure TRMDADOQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDADOQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDADOQuery(Args.Obj).FQuery);
  TRMDADOQuery(Args.Obj).FQuery.ExecSQL;
end;

const
	cReportMachine = 'RMD_ADO';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDADODatabase, 'TRMDADODataset');
    AddClass(cReportMachine, TRMDADOTable, 'TRMDADOTable');
    AddClass(cReportMachine, TRMDADOQuery, 'TRMDADOQuery');

    AddGet(TRMDDataset, 'ExecSql', TRMDADOQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
//  RMRegisterControl(TRMDADODatabase, 'RMD_ADODB', RMLoadStr(SInsertDB) + '(ADO)');
//  RMRegisterControl(TRMDADOTable, 'RMD_ADOTABLE', RMLoadStr(SInsertTable) + '(ADO)');
//  RMRegisterControl(TRMDADOQuery, 'RMD_ADOQUERY', RMLoadStr(SInsertQuery) + '(ADO)');
  RMRegisterControls('ADO', 'RMD_ADOPATH', True,
    [TRMDADODatabase, TRMDADOTable, TRMDADOQuery],
    ['RMD_ADODB', 'RMD_ADOTABLE', 'RMD_ADOQUERY'],
    [RMLoadStr(SInsertDB), RMLoadStr(SInsertTable), RMLoadStr(SInsertQuery)]);

  RMRegisterPropEditor(TypeInfo(WideString), TRMDADODatabase, 'ConnectionString', TConnectionStringEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDADOTable, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDADOTable, 'IndexName', TIndexNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDADOTable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDADOQuery, 'DatabaseName', TDatabaseEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization
{$ENDIF}

end.

