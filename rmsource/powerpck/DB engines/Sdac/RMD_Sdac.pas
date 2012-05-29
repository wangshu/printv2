
{*****************************************}
{                                         }
{           Report Machine v1.0           }
{   Wrapper for Interbase Express(SDAC)    }
{                                         }
{*****************************************}

unit RMD_Sdac;

interface

{$I RM.INC}
{$R RMD_SDAC.RES}
uses
  Classes, SysUtils, Graphics, Forms, ExtCtrls, DB,
  MSAccess, DBAccess, OLEDBAccess,
  StdCtrls, Controls, Dialogs, RMD_DBWrap, RM_Class
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF Delphi6}, Variants, Mask, ComCtrls{$ENDIF};

type
  TRMDSDacComponents = class(TComponent)
  end;

  { TRMSDacConnection }
  TRMDMSConnection = class(TRMDialogComponent)
  private
    FDatabase: TMSConnection;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetConnectionString: string;
    procedure SetConnectionString(Value: string);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetDatabase: string;
    procedure SetDatabase(Value: string);
    function GetServer: string;
    procedure SetServer(Value: string);
    function GetUsername: string;
    procedure SetUsername(Value: string);
    function GetPassword: string;
    procedure SetPassword(Value: string);
  protected
    procedure AfterChangeName; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
  published
    property Database: string read GetDatabase write SetDatabase;
    property Server: string read GetServer write SetServer;
    property Username: string read GetUsername write SetUsername;
    property Password: string read GetPassword write SetPassword;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property Connected: Boolean read GetConnected write SetConnected;
    property ConnectString: string read GetConnectionString write SetConnectionString;
  end;

  { TRMDMSTable }
  TRMDMSTable = class(TRMDTable)
  private
    FTable: TMSTable;

    function GetDetailFields: string;
    procedure SetDetailFields(Value: string);
  protected
  	procedure InternalLoaded; override;

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
    property DetailFields: string read GetDetailFields write SetDetailFields;
  end;

  { TRMDMSQuery}
  TRMDMSQuery = class(TRMDQuery)
  private
    FQuery: TMSQuery;

    function GetMasterFields: string;
    procedure SetMasterFields(Value: string);
    function GetDetailFields: string;
    procedure SetDetailFields(Value: string);
  protected
  	procedure InternalLoaded; override;

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
    property MasterSource: string read GetDataSource write SetDataSource;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property DetailFields: string read GetDetailFields write SetDetailFields;
  end;

  { TRMDSdacDBEdit }
  TRMDSdacDBEdit = class(TForm)
    PageControl: TPageControl;
    shConnect: TTabSheet;
    Panel: TPanel;
    lbUsername: TLabel;
    lbPassword: TLabel;
    lbServer: TLabel;
    edUsername: TEdit;
    edPassword: TMaskEdit;
    edServer: TComboBox;
    btConnect: TButton;
    btDisconnect: TButton;
    btClose: TButton;
    cbLoginPrompt: TCheckBox;
    shRed: TShape;
    shYellow: TShape;
    shGreen: TShape;
    lbDatabase: TLabel;
    edDatabase: TComboBox;
    rgAuth: TRadioGroup;
    procedure edServerDropDown(Sender: TObject);
    procedure edServerExit(Sender: TObject);
    procedure edDatabaseDropDown(Sender: TObject);
    procedure edDatabaseExit(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure rgAuthClick(Sender: TObject);
    procedure edUsernameExit(Sender: TObject);
    procedure edPasswordExit(Sender: TObject);
    procedure cbLoginPromptClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FConnection: TRMDMSConnection;

    procedure ShowState(Yellow: boolean = False);
    procedure DoInit;
  protected
  public
  end;

implementation

uses RM_Common, RM_utils, RM_Const, RM_PropInsp, RM_Insp, RMD_Editorldlinks;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDMSConnection }

constructor TRMDMSConnection.Create;
begin
  inherited Create;
  BaseName := 'MSConnection';
  FBmpRes := 'RMD_SDACCONNECTION';

  DontUndo := True;
  FDatabase := TMSConnection.Create(RMDialogForm);
  FComponent := FDatabase;
end;

destructor TRMDMSConnection.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FDatabase.Free;
    FDatabase := nil;
  end;
  inherited Destroy;
end;

procedure TRMDMSConnection.AfterChangeName;
begin
  FDatabase.Name := Name;
end;

procedure TRMDMSConnection.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  ConnectString := RMReadString(aStream);
  Database := RMReadString(aStream);
  Server := RMReadString(aStream);
  Username := RMReadString(aStream);
  Password := RMReadString(aStream);
  LoginPrompt := RMReadBoolean(aStream);
  Connected := RMReadBoolean(aStream);
end;

procedure TRMDMSConnection.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, ConnectString);
  RMWriteString(aStream, Database);
  RMWriteString(aStream, Server);
  RMWriteString(aStream, Username);
  RMWriteString(aStream, Password);
  RMWriteBoolean(aStream, LoginPrompt);
  RMWriteBoolean(aStream, Connected);
end;

procedure TRMDMSConnection.ShowEditor;
var
	tmp: TRMDSdacDBEdit;
begin
  tmp := TRMDSdacDBEdit.Create(nil);
  try
  	tmp.FConnection := Self;
  	tmp.ShowModal;
  finally
  	tmp.Free;
  end;
end;

function TRMDMSConnection.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDMSConnection.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDMSConnection.GetConnectionString: string;
begin
  Result := FDatabase.ConnectString;
end;

procedure TRMDMSConnection.SetConnectionString(Value: string);
begin
  FDatabase.Connected := False;
  FDatabase.ConnectString := Value;
end;

function TRMDMSConnection.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDMSConnection.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDMSConnection.GetDatabase: string;
begin
  Result := FDatabase.Database;
end;

procedure TRMDMSConnection.SetDatabase(Value: string);
begin
  FDatabase.Database := Value;
end;

function TRMDMSConnection.GetServer: string;
begin
  Result := FDatabase.Server;
end;

procedure TRMDMSConnection.SetServer(Value: string);
begin
  FDatabase.Server := Value;
end;

function TRMDMSConnection.GetUsername: string;
begin
  Result := FDatabase.Username;
end;

procedure TRMDMSConnection.SetUsername(Value: string);
begin
  FDatabase.Username := Value;
end;

function TRMDMSConnection.GetPassword: string;
begin
  Result := FDatabase.Password;
end;

procedure TRMDMSConnection.SetPassword(Value: string);
begin
  FDatabase.Password := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDMSTable}

procedure TRMDMSQuery_ExecSql(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDMSQuery(Args.Obj).OnBeforeOpenQueryEvent(TRMDMSQuery(Args.Obj).FQuery);
  TRMDMSQuery(Args.Obj).FQuery.Execute;
end;

constructor TRMDMSTable.Create;
begin
  inherited Create;
  BaseName := 'MSTable';
  FBmpRes := 'RMD_SDACTABLE';

  FTable := TMSTable.Create(RMDialogForm);
  DataSet := FTable;
  FComponent := FTable;
  FIndexBased := False;
end;

procedure TRMDMSTable.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FFixupList['DetailFields'] := RMReadString(aStream);
end;

procedure TRMDMSTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, DetailFields);
end;

procedure TRMDMSTable.InternalLoaded;
begin
	MasterFields := FFixupList['MasterFields'];
end;

function TRMDMSTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

function TRMDMSTable.GetDetailFields: string;
begin
  Result := FTable.DetailFields;
end;

procedure TRMDMSTable.SetDetailFields(Value: string);
begin
  FTable.DetailFields := Value;
end;

function TRMDMSTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDMSTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDMSTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

function TRMDMSTable.GetDatabaseName: string;
begin
  Result := '';
  if FTable.Connection <> nil then
  begin
    Result := FTable.Connection.Name;
    if (FTable.Connection.Owner <> nil) and (FTable.Connection.Owner <> FTable.Owner) then
      Result := FTable.Connection.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDMSTable.SetDatabaseName(const Value: string);
var
  lComponent: TComponent;
begin
  FTable.Active := False;
  lComponent := RMFindComponent(FTable.Owner, Value);
  if (lComponent <> nil) and (lComponent is TMSConnection) then
    FTable.Connection := TMSConnection(lComponent)
  else
    FTable.Connection := nil;
end;

procedure TRMDMSTable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDMSTable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDMSTable.SetMasterSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FTable.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FTable.MasterSource := RMGetDataSource(FTable.Owner, TDataSet(liComponent))
  else
    FTable.MasterSource := nil;
end;

procedure TRMDMSTable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDMSTable.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDMSTable.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDMSTable.GetIndexName: string;
begin
  //Result := FTable.IndexName;
end;

procedure TRMDMSTable.SetIndexName(Value: string);
begin
  //FTable.IndexName := Value;
end;

procedure TRMDMSTable.GetIndexNames(sl: TStrings);
var
  i: integer;
  lDataSetUtils: TDADataSetUtils;
begin
  lDataSetUtils := TDADataSetUtils.Create;
  try
    lDataSetUtils.QuickOpen(FTable);

    for i := 0 to DataSet.FieldDefs.Count - 1 do
      sl.Add(FTable.FieldDefs[i].Name);
  finally
    lDataSetUtils.Restore(True);
    lDataSetUtils.Free;
  end;
end;

function TRMDMSTable.GetIndexDefs: TIndexDefs;
begin
  Result := nil;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDMSQuery}

constructor TRMDMSQuery.Create;
begin
  inherited Create;
  BaseName := 'MSQuery';
  FBmpRes := 'RMD_SDACQUERY';

  FQuery := TMSQuery.Create(RMDialogForm);
  DataSet := FQuery;
  FComponent := FQuery;
  FIndexBased := False;
end;

procedure TRMDMSQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FFixupList['MasterFields'] := RMReadString(aStream);
  FFixupList['DetailFields'] := RMReadString(aStream);
end;

procedure TRMDMSQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, MasterFields);
  RMWriteString(aStream, DetailFields);
end;

procedure TRMDMSQuery.InternalLoaded;
begin
	MasterFields := FFixupList['MasterFields'];
end;

function TRMDMSQuery.GetDatabaseName: string;
begin
  Result := '';
  if FQuery.Connection <> nil then
  begin
    Result := FQuery.Connection.Name;
    if (FQuery.Connection.Owner <> nil) and (FQuery.Connection.Owner <> FQuery.Owner) then
      Result := FQuery.Connection.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDMSQuery.SetDatabaseName(const Value: string);
var
  lComponent: TComponent;
begin
  FQuery.Active := False;
  lComponent := RMFindComponent(FQuery.Owner, Value);
  if (lComponent <> nil) and (lComponent is TMSConnection) then
    FQuery.Connection := TMSConnection(lComponent)
  else
    FQuery.Connection := nil;
end;

function TRMDMSQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

function TRMDMSQuery.GetParamCount: Integer;
begin
  Result := FQuery.ParamCount;
end;

function TRMDMSQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

function TRMDMSQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDMSQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

function TRMDMSQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

function TRMDMSQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

function TRMDMSQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDMSQuery.GetTableFieldNames(const DB, TName: string; sl:
  TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TMSTable;
begin
  lStrings := TStringList.Create;
  t := TMSTable.Create(RMDialogForm);
  try
    t.Connection := RMFindComponent(FQuery.Owner, DB) as TMSConnection;
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

procedure TRMDMSQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
  lConnection: TMSConnection;
begin
  sl := TStringList.Create;
  try
    try
      lConnection := RMFindComponent(FQuery.Owner, DB) as TMSConnection;
      if lConnection = nil then exit;
      if not lConnection.Connected then
        lConnection.Connected := True;
      if lConnection.Connected then
        lConnection.GetTableNames(sl);
      sl.Sort;
      Strings.Assign(sl);
    except;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDMSQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

procedure TRMDMSQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

procedure TRMDMSQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

procedure TRMDMSQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

procedure TRMDMSQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;

procedure TRMDMSQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDMSQuery.GetDataSource: string;
begin
  Result := RMGetDataSetName(FQuery.Owner, FQuery.MasterSource)
end;

procedure TRMDMSQuery.SetDataSource(Value: string);
var
  lComponent: TComponent;
begin
  lComponent := RMFindComponent(FQuery.Owner, Value);
  if (lComponent <> nil) and (lComponent is TDataSet) then
    FQuery.MasterSource := RMGetDataSource(FQuery.Owner, TDataSet(lComponent))
  else
    FQuery.MasterSource := nil;
end;

procedure TRMDMSQuery.GetDatabases(sl: TStrings);
var
  lStringList: TStringList;
begin
  lStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TMSConnection, lStringList, nil);
    lStringList.Sort;
    sl.Assign(lStringList);
  finally
    lStringList.Free;
  end;
end;

function TRMDMSQuery.GetMasterFields: string;
begin
  Result := FQuery.MasterFields;
end;

procedure TRMDMSQuery.SetMasterFields(Value: string);
begin
  FQuery.MasterFields := Value;
end;

function TRMDMSQuery.GetDetailFields: string;
begin
  Result := FQuery.DetailFields;
end;

procedure TRMDMSQuery.SetDetailFields(Value: string);
begin
  FQuery.DetailFields := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDSDacDBEdit }
procedure TRMDSdacDBEdit.ShowState(Yellow: boolean);
begin
  btDisconnect.Enabled := FConnection.FDatabase.Connected;

  shRed.Brush.Color := clBtnFace;
  shYellow.Brush.Color := clBtnFace;
  shGreen.Brush.Color := clBtnFace;

  if Yellow then
  begin
    shYellow.Brush.Color := clYellow;
    shYellow.Update;
  end
  else if FConnection.FDatabase.Connected then
  begin
  	shGreen.Brush.Color := clGreen;
    shYellow.Update;
  end
  else
  	shRed.Brush.Color := clRed;
end;

procedure TRMDSdacDBEdit.edServerDropDown(Sender: TObject);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crSQLWait;
  try
    GetServerList(edServer.Items);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TRMDSdacDBEdit.edServerExit(Sender: TObject);
begin
  ShowState(False);
  FConnection.FDatabase.Server := edServer.Text;
  ShowState(False);
end;

procedure TRMDSdacDBEdit.edDatabaseDropDown(Sender: TObject);
var
  List: TStringList;
  OldLoginPrompt: Boolean;
begin
  inherited;

  OldLoginPrompt := FConnection.FDatabase.LoginPrompt;
  List := TStringList.Create;
  try
    FConnection.FDatabase.LoginPrompt := False;
    GetDatabasesList(FConnection.FDatabase, List);
    List.Sort;
    edDatabase.Items.Assign(List);
  finally
    edDatabase.Text := FConnection.FDatabase.Database;
    List.Free;
    FConnection.FDatabase.LoginPrompt := OldLoginPrompt;
    ShowState;
  end;
end;

procedure TRMDSdacDBEdit.edDatabaseExit(Sender: TObject);
begin
  FConnection.FDatabase.Database := edDatabase.Text;
  ShowState(False);
end;

procedure TRMDSdacDBEdit.btConnectClick(Sender: TObject);
begin
  ShowState(True);
  SetCursor(crSQLWait);
  try
    FConnection.FDatabase.PerformConnect;
  finally
    SetCursor(crDefault);
    ShowState;
  end;

  Close;
end;

procedure TRMDSdacDBEdit.btDisconnectClick(Sender: TObject);
begin
  try
    FConnection.FDatabase.Disconnect;
  finally
    ShowState;
  end;
end;

procedure TRMDSdacDBEdit.rgAuthClick(Sender: TObject);
begin
  FConnection.FDatabase.Authentication := TMSAuthentication(rgAuth.ItemIndex);
  case FConnection.FDatabase.Authentication of
    auWindows:
    begin
      edUsername.Enabled := False;
      edPassword.Enabled := False;
      lbUsername.Enabled := False;
      lbPassword.Enabled := False;
      cbLoginPrompt.Enabled := False;
    end;
    auServer:
    begin
      edUsername.Enabled := True;
      edPassword.Enabled := True;
      lbUsername.Enabled := True;
      lbPassword.Enabled := True;
      cbLoginPrompt.Enabled := True;
    end;
  end;

  ShowState(False);
end;

procedure TRMDSdacDBEdit.edUsernameExit(Sender: TObject);
begin
  FConnection.FDatabase.Username := edUsername.Text;
  ShowState(False);
end;

procedure TRMDSdacDBEdit.edPasswordExit(Sender: TObject);
begin
  FConnection.FDatabase.Password := edPassword.Text;
  ShowState(False);
end;

procedure TRMDSdacDBEdit.cbLoginPromptClick(Sender: TObject);
begin
  FConnection.FDatabase.LoginPrompt := cbLoginPrompt.Checked;
  ShowState(False);
end;

procedure TRMDSdacDBEdit.DoInit;
begin
  inherited;

  edUsername.Text := FConnection.FDatabase.Username;
  edPassword.Text := FConnection.FDatabase.Password;
  edServer.Text := FConnection.FDatabase.Server;

  cbLoginPrompt.Checked := FConnection.FDatabase.LoginPrompt;
  rgAuth.ItemIndex := Ord(FConnection.FDatabase.Authentication);

  ShowState;
  edDatabase.Text := FConnection.FDatabase.Database;
end;

procedure TRMDSdacDBEdit.FormShow(Sender: TObject);
begin
	DoInit;
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

  TTableMasterFieldsEditor = class(TRMDFieldLinkProperty)
  protected
    function GetMasterFields: string; override;
    procedure SetMasterFields(const Value: string); override;
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(const Value: string); override;
  end;

  TQueryMasterFieldsEditor = class(TRMDFieldLinkProperty)
  protected
    function GetMasterFields: string; override;
    procedure SetMasterFields(const Value: string); override;
    function GetIndexFieldNames: string; override;
    procedure SetIndexFieldNames(const Value: string); override;
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
  TRMDMSConnection(GetInstance(0)).ShowEditor;
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
    RMGetComponents(RMDialogForm, TMSConnection, AValues, nil);
  finally
  end;
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
  lTable: TRMDMSTable;
begin
  lTable := TRMDMSTable(GetInstance(0));
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
  liTable: TMSTable;
begin
  liTable := TRMDMSTable(GetInstance(0)).FTable;
  if liTable.Connection <> nil then
  begin
    liTable.Connection.GetTableNames(AValues);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TTableMasterFieldsEditor }

function TTableMasterFieldsEditor.GetMasterFields: string;
begin
  Result := TRMDMSTable(DataSet).MasterFields;
end;

procedure TTableMasterFieldsEditor.SetMasterFields(const Value: string);
begin
  TRMDMSTable(DataSet).MasterFields := Value;
end;

function TTableMasterFieldsEditor.GetIndexFieldNames: string;
begin
  Result := TRMDMSTable(DataSet).DetailFields;
end;

procedure TTableMasterFieldsEditor.SetIndexFieldNames(const Value: string);
begin
  TRMDMSTable(DataSet).DetailFields := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TQueryMasterFieldsEditor }

function TQueryMasterFieldsEditor.GetMasterFields: string;
begin
  Result := TRMDMSQuery(DataSet).MasterFields;
end;

procedure TQueryMasterFieldsEditor.SetMasterFields(const Value: string);
begin
  TRMDMSQuery(DataSet).MasterFields := Value;
end;

function TQueryMasterFieldsEditor.GetIndexFieldNames: string;
begin
  Result := TRMDMSQuery(DataSet).DetailFields;
end;

procedure TQueryMasterFieldsEditor.SetIndexFieldNames(const Value: string);
begin
  TRMDMSQuery(DataSet).DetailFields := Value;
end;

const
  cReportMachine = 'RMD_SDAC';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDMSConnection, 'TRMDMSConnection');
    AddClass(cReportMachine, TRMDMSTable, 'TRMDMSTable');
    AddClass(cReportMachine, TRMDMSQuery, 'TRMDMSQuery');

    AddGet(TRMDDataset, 'ExecSql', TRMDMSQuery_ExecSql, 0, [0], varEmpty);
  end;
end;

initialization
  RMRegisterControls('SDAC', 'RMD_SDACPATH', True,
    [TRMDMSConnection, TRMDMSTable, TRMDMSQuery],
    ['RMD_SDACCONNECTION', 'RMD_SDACTABLE', 'RMD_SDACQUERY'],
    [RMLoadStr(SInsertDB), RMLoadStr(SInsertTable), RMLoadStr(SInsertQuery)]);

  RMRegisterPropEditor(TypeInfo(string), TRMDMSConnection, 'ConnectString', TConnectionStringEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDMSTable, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDMSTable, 'IndexFieldNames', TIndexFieldNamesEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDMSTable, 'TableName', TTableNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDMSQuery, 'DatabaseName', TDatabaseEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDMSTable, 'MasterFields', TTableMasterFieldsEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDMSQuery, 'MasterFields', TQueryMasterFieldsEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

end.

