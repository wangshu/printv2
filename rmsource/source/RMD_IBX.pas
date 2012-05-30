
{*****************************************}
{                                         }
{           Report Machine v1.0           }
{   Wrapper for Interbase Express(IBX)    }
{                                         }
{*****************************************}

unit RMD_IBX;

interface

{$I RM.INC}
{$IFDEF DM_IBX}
uses
  Classes, SysUtils, Graphics, Forms, ExtCtrls, DB, IBTable, IBQuery, IBDatabase,
  StdCtrls, Controls, Dialogs, RMD_DBWrap, RM_Class
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDIBXComponents = class(TComponent) // fake component
  end;

  TRMDIBDatabase = class(TRMDialogComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetDatabaseName: string;
    procedure SetDatabaseName(Value: string);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetSQLDialect: Integer;
    procedure SetSQLDialect(Value: Integer);
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
    property Database: TIBDatabase read FDatabase;
    property Connected: Boolean read GetConnected write SetConnected;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property SQLDialect: Integer read GetSQLDialect write SetSQLDialect;
    property Params: string read GetParams write SetParams;
  end;

 { TRMDIBTable }
  TRMDIBTable = class(TRMDTable)
  private
    FTable: TIBTable;
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
  published
    property IndexName;
  end;

  { TRMDIBQuery}
  TRMDIBQuery = class(TRMDQuery)
  private
    FQuery: TIBQuery;
  protected
    function GetParamCount: Integer; override;
    function GetSQL: string; override;
    procedure SetSQL(aSql: string); override;
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
  published
  	property DataSource;
  end;

 { TRMDFormIBXPropEdit }
  TRMDFormIBXPropEdit = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    rdbLocal: TRadioButton;
    rdbRemote: TRadioButton;
    edtServer: TEdit;
    cmbProtocol: TComboBox;
    Label3: TLabel;
    edtDatabase: TEdit;
    Label4: TLabel;
    edtUser: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    memParam: TMemo;
    edtPassword: TEdit;
    Label7: TLabel;
    edtSQLRole: TEdit;
    btnBrowse: TButton;
    OpenDialog1: TOpenDialog;
    lblServer: TStaticText;
    lblProtocol: TStaticText;
    procedure btnBrowseClick(Sender: TObject);
    procedure rdbLocalClick(Sender: TObject);
    procedure edtUserExit(Sender: TObject);
    procedure edtPasswordExit(Sender: TObject);
    procedure edtSQLRoleExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDatabase: TIBDatabase;
    procedure Localize;
  public
    { Public declarations }
  end;

{$ENDIF}
implementation

{$IFDEF DM_IBX}
uses RM_Common, RM_utils, RM_Const, RM_PropInsp, RM_Insp;

{$R *.DFM}
{$R RMD_IBX.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDIBDatabase}

constructor TRMDIBDatabase.Create;
begin
  inherited Create;
  BaseName := 'IBDatabase';
  FBmpRes := 'RMD_IBXDB';

  FDatabase := TIBDataBase.Create(RMDialogForm);
  FTransaction := TIBTransaction.Create(RMDialogForm);
  FDatabase.DefaultTransaction := FTransaction;
  DontUndo := True;
  FComponent := FDatabase;
end;

destructor TRMDIBDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FTransaction.Free;
    FTransaction := nil;
    FDatabase.Free;
    FDatabase := nil;
  end;
  inherited Destroy;
end;

procedure TRMDIBDatabase.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDatabase.DatabaseName := RMReadString(aStream);
  FDatabase.LoginPrompt := RMReadBoolean(aStream);
  FDatabase.SQLDialect := RMReadInt32(aStream);
  RMReadMemo(aStream, FDatabase.Params);
  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDIBDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FDatabase.DatabaseName);
  RMWriteBoolean(aStream, FDatabase.LoginPrompt);
  RMWriteInt32(aStream, FDatabase.SQLDialect);
  RMWriteMemo(aStream, FDatabase.Params);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

procedure TRMDIBDatabase.ShowEditor;
var
  tmp: TRMDFormIBXPropEdit;
begin
  tmp := TRMDFormIBXPropEdit.Create(nil);
  try
    tmp.FDatabase := Self.FDatabase;
    if tmp.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
    end;
  finally
    tmp.Free;
  end;
end;

function TRMDIBDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDIBDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
  if Assigned(FDataBase.DefaultTransaction) then
    FDataBase.DefaultTransaction.Active := Value;
end;

function TRMDIBDatabase.GetDatabaseName: string;
begin
  Result := FDatabase.DatabaseName;
end;

procedure TRMDIBDatabase.SetDatabaseName(Value: string);
begin
  FDatabase.DatabaseName := Value;
end;

function TRMDIBDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDIBDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDIBDatabase.GetSQLDialect: Integer;
begin
  Result := FDatabase.SQLDialect;
end;

procedure TRMDIBDatabase.SetSQLDialect(Value: Integer);
begin
  FDatabase.SQLDialect := Value;
end;

function TRMDIBDatabase.GetParams: string;
begin
  Result := FDatabase.Params.Text;
end;

procedure TRMDIBDatabase.SetParams(Value: string);
begin
  FDatabase.Params.Text := Value;
end;

procedure TRMDIBDatabase.AfterChangeName;
begin
  FDatabase.Name := Name;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDIBTable}

constructor TRMDIBTable.Create;
begin
  inherited Create;
  BaseName := 'IBTable';
  FBmpRes := 'RMD_IBXTABLE';

  FTable := TIBTable.Create(RMDialogForm);
  DataSet := FTable;
  FComponent := FTable;
end;

procedure TRMDIBTable.GetIndexNames(sl: TStrings);
var
  i: Integer;
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

function TRMDIBTable.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDIBTable.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDIBTable.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TRMDIBTable.GetDatabaseName: string;
begin
  Result := '';
  if FTable.Database <> nil then
  begin
    Result := FTable.Database.Name;
    if FTable.Database.Owner <> FTable.Owner then
      Result := FTable.Database.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDIBTable.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FTable.Close;
  liComponent := RMFindComponent(FTable.Owner, Value);
  if (liComponent <> nil) and (liComponent is TIBDatabase) then
    FTable.Database := TIBDatabase(liComponent)
  else
    FTable.Database := nil;
end;

function TRMDIBTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDIBTable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDIBTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDIBTable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDIBTable.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDIBTable.SetIndexName(Value: string);
begin
  FTable.Active := False;
  FTable.IndexName := Value;
end;

function TRMDIBTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDIBTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDIBTable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDIBTable.SetMasterSource(Value: string);
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
{TRMDIBQuery}

constructor TRMDIBQuery.Create;
begin
  inherited Create;
  BaseName := 'IBQuery';
  FBmpRes := 'RMD_IBXQUERY';

  FQuery := TIBQuery.Create(RMDialogForm);
  DataSet := FQuery;
  FComponent := FQuery;
end;

procedure TRMDIBQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TIBDatabase, liStringList, nil);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDIBQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
  lDatabase: TIBDatabase;
begin
  sl := TStringList.Create;
  try
    try
      lDatabase := RMFindComponent(FQuery.Owner, DB) as TIBDatabase;
      if lDatabase = nil then exit;
      if not lDatabase.Connected then
        lDatabase.Connected := True;
      if lDatabase.Connected then
        lDatabase.GetTableNames(sl);
      sl.Sort;
      Strings.Assign(sl);
    except;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDIBQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TIBTable;
begin
  lStrings := TStringList.Create;
  t := TIBTable.Create(RMDialogForm);
  try
    t.Database := RMFindComponent(FQuery.Owner, DB) as TIBDataBase;
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

function TRMDIBQuery.GetParamCount: Integer;
begin
  Result := FQuery.ParamCount;
end;

function TRMDIBQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDIBQuery.SetSQL(aSql: string);
begin
  FQuery.Close;
  FQuery.SQL.Text := aSQL;
end;

function TRMDIBQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDIBQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDIBQuery.GetDatabaseName: string;
begin
  Result := '';
  if FQuery.Database <> nil then
  begin
    Result := FQuery.Database.Name;
    if FQuery.Database.Owner <> FQuery.Owner then
      Result := FQuery.Database.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDIBQuery.SetDatabaseName(const Value: string);
var
  liComponent: TComponent;
begin
  FQuery.Close;
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TIBDatabase) then
    FQuery.Database := TIBDatabase(liComponent)
  else
    FQuery.Database := nil;
end;

function TRMDIBQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
end;

procedure TRMDIBQuery.SetDataSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FQuery.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(liComponent))
  else
    FQuery.DataSource := nil;
end;

function TRMDIBQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDIBQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDIBQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDIBQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDIBQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

function TRMDIBQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDIBQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDIBQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDIBQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDFormIBXPropEdit}

procedure TRMDFormIBXPropEdit.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 3230);
  RMSetStrProp(rdbLocal, 'Caption', rmRes + 3241);
  RMSetStrProp(rdbRemote, 'Caption', rmRes + 3242);
  RMSetStrProp(Label3, 'Caption', rmRes + 3233);
  RMSetStrProp(btnBrowse, 'Caption', rmRes + 3249);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 3237);
  RMSetStrProp(Label4, 'Caption', rmRes + 3246);
  RMSetStrProp(Label5, 'Caption', rmRes + 3247);
  RMSetStrProp(Label7, 'Caption', rmRes + 3248);
  RMSetStrProp(Label6, 'Caption', rmRes + 3237);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDFormIBXPropEdit.btnBrowseClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edtDatabase.Text := OpenDialog1.FileName;
end;

procedure TRMDFormIBXPropEdit.rdbLocalClick(Sender: TObject);
begin
  edtServer.Enabled := rdbRemote.Checked;
  cmbProtocol.Enabled := rdbRemote.Checked;
  lblServer.Enabled := rdbRemote.Checked;
  lblProtocol.Enabled := rdbRemote.Checked;
  btnBrowse.Enabled := rdbLocal.Checked;
end;

procedure TRMDFormIBXPropEdit.edtUserExit(Sender: TObject);
begin
  memParam.Lines.Values['user_name'] := edtUser.Text;
end;

procedure TRMDFormIBXPropEdit.edtPasswordExit(Sender: TObject);
begin
  memParam.Lines.Values['password'] := edtPassword.Text;
end;

procedure TRMDFormIBXPropEdit.edtSQLRoleExit(Sender: TObject);
begin
  memParam.Lines.Values['sql_role'] := edtSQLRole.Text;
end;

procedure TRMDFormIBXPropEdit.FormShow(Sender: TObject);
var
  aPos: integer;
  str: string;
begin
  memParam.Lines.Assign(FDatabase.Params);
  edtUser.Text := memParam.Lines.Values['user_name'];
  edtPassword.Text := memParam.Lines.Values['password'];
  edtSQLRole.Text := memParam.Lines.Values['sql_role'];

  if (Pos(':', FDatabase.DatabaseName) > 0) and (Pos(':\', FDatabase.DatabaseName) = 0) then // TCP
  begin
    rdbRemote.Checked := TRUE;
    cmbProtocol.ItemIndex := 0;
    aPos := Pos(':', FDatabase.DatabaseName);
    edtServer.Text := Copy(FDatabase.DatabaseName, 1, aPos - 1);
    edtDatabase.Text := Copy(FDatabase.DatabaseName, aPos + 1, 99999);
  end
  else if Pos('\\', FDatabase.DatabaseName) > 0 then // NetBEUI
  begin
    rdbRemote.Checked := TRUE;
    cmbProtocol.ItemIndex := 1;
    str := FDatabase.DatabaseName;
    Delete(str, 1, 2);
    aPos := Pos('\', str);
    edtServer.Text := Copy(str, 1, aPos - 1);
    edtDatabase.Text := Copy(str, aPos + 1, 99999);
  end
  else if Pos('@', FDatabase.DatabaseName) > 0 then // SPX
  begin
    rdbRemote.Checked := TRUE;
    cmbProtocol.ItemIndex := 2;
    aPos := Pos('@', FDatabase.DatabaseName);
    edtServer.Text := Copy(FDatabase.DatabaseName, 1, aPos - 1);
    edtDatabase.Text := Copy(FDatabase.DatabaseName, aPos + 1, 99999);
  end
  else
  begin
    rdbLocal.Checked := TRUE;
    cmbProtocol.ItemIndex := 0;
    edtDatabase.Text := FDatabase.DatabaseName;
  end;

  rdbLocalClick(nil);
end;

procedure TRMDFormIBXPropEdit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    FDatabase.Params.Assign(memParam.Lines);

    if rdbLocal.Checked then
      FDatabase.DatabaseName := edtDatabase.Text
    else
    begin
      case cmbProtocol.ItemIndex of
        0: // TCP
          FDatabase.DatabaseName := Format('%s:%s', [edtServer.Text, edtDatabase.Text]);
        1: // NetBEUI
          FDatabase.DatabaseName := Format('\\%s\%s', [edtServer.Text, edtDatabase.Text]);
        2: // SPX
          FDatabase.DatabaseName := Format('%s@%s', [edtServer.Text, edtDatabase.Text]);
      end;
    end;
  end;
end;

procedure TRMDFormIBXPropEdit.FormCreate(Sender: TObject);
begin
  Localize;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
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

  TTableNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
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
  TRMDIBDatabase(GetInstance(0)).ShowEditor;
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
    RMGetComponents(RMDialogForm, TIBDatabase, AValues, nil);
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
  liTable: TRMDIBTable;
begin
  liTable := TRMDIBTable(GetInstance(0));
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
  liTable: TIBTable;
begin
  liTable := TRMDIBTable(GetInstance(0)).FTable;
  if liTable.Database <> nil then
  begin
    liTable.DataBase.GetTableNames(AValues, False);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMDIBXQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDIBQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDIBQuery(Args.Obj).FQuery);
  TRMDIBQuery(Args.Obj).FQuery.ExecSQL;
end;

const
	cReportMachine = 'RMD_IBX';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDIBDatabase, 'TRMDIBDataset');
    AddClass(cReportMachine, TRMDIBTable, 'TRMDIBTable');
    AddClass(cReportMachine, TRMDIBQuery, 'TRMDIBQuery');

    AddGet(TRMDDataset, 'ExecSql', TRMDIBXQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
//  RMRegisterControl(TRMDIBDatabase, 'RMD_IBXDB', RMLoadStr(SInsertDB) + '(IBX)');
//  RMRegisterControl(TRMDIBTable, 'RMD_IBXTABLE', RMLoadStr(SInsertTable) + '(IBX)');
//  RMRegisterControl(TRMDIBQuery, 'RMD_IBXQUERY', RMLoadStr(SInsertQuery) + '(IBX)');
  RMRegisterControls('IBX', 'RMD_IBXPATH', True,
    [TRMDIBDatabase, TRMDIBTable, TRMDIBQuery],
    ['RMD_IBXDB', 'RMD_IBXTABLE', 'RMD_IBXQUERY'],
    [RMLoadStr(SInsertDB), RMLoadStr(SInsertTable), RMLoadStr(SInsertQuery)]);

  RMRegisterPropEditor(TypeInfo(string), TRMDIBDatabase, 'DatabaseName', TDatabaseNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDIBDatabase, 'Params', TDatabaseNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDIBTable, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDIBTable, 'IndexName', TIndexNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDIBTable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDIBQuery, 'DatabaseName', TDatabaseEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization
{$ENDIF}

end.

