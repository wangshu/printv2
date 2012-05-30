unit RMD_KaDao;

interface

{$I RM.INC}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, Dialogs, Controls, StdCtrls,
  KDaoDataBase, KDaoTable, RM_Common, RM_Class, RMD_DBWrap
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMDDiamondComponents = class(TComponent) // fake component
  end;

  TRMDKaDaoDatabase = class(TRMDialogComponent)
  private
    FDatabase: TKADaoDatabase;

    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetDatabaseName: string;
    procedure SetDatabaseName(Value: string);
    function GetUsername: string;
    procedure SetUsername(Value: string);
    function GetPassword: string;
    procedure SetPassword(Value: string);
    function GetVersion: string;
    procedure SetVersion(Value: string);
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;
  published
    property Database: TKADaoDatabase read FDatabase;

    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
    property Username: string read GetUsername write SetUsername;
    property Password: string read GetPassword write SetPassword;
    property Version: string read GetVersion write SetVersion;
  end;

  { TRMDKaDaoQuery }
  TRMDKaDaoQuery = class(TRMDQuery)
  private
    FQuery: TKADaoTable;
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
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
  end;

implementation

uses RM_Const, RM_utils;

{$R RMD_KaDao.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDKaDaoDatabase}

constructor TRMDKaDaoDatabase.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'KADaoDatabase';
  FBmpRes := 'RMD_KaDaoDB';

  FDatabase := TKADaoDatabase.Create(RMDialogForm);
  DontUndo := True;
  FComponent := FDatabase;
end;

destructor TRMDKaDaoDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
  begin
    FreeAndNil(FDatabase);
  end;
  inherited Destroy;
end;

function TRMDKaDaoDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

procedure TRMDKaDaoDatabase.SetConnected(Value: Boolean);
begin
  FDatabase.Connected := Value;
end;

function TRMDKaDaoDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TRMDKaDaoDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

function TRMDKaDaoDatabase.GetDatabaseName: string;
begin
  Result := FDatabase.Database;
end;

procedure TRMDKaDaoDatabase.SetDatabaseName(Value: string);
begin
  FDatabase.Database := Value;
end;

function TRMDKaDaoDatabase.GetUsername: string;
begin
  Result := FDatabase.Username;
end;

procedure TRMDKaDaoDatabase.SetUsername(Value: string);
begin
  FDatabase.Username := Value;
end;

function TRMDKaDaoDatabase.GetPassword: string;
begin
  Result := FDatabase.Password;
end;

procedure TRMDKaDaoDatabase.SetPassword(Value: string);
begin
  FDatabase.Password := Value;
end;

function TRMDKaDaoDatabase.GetVersion: string;
begin
  Result := FDatabase.Version;
end;

procedure TRMDKaDaoDatabase.SetVersion(Value: string);
begin
  FDatabase.Version := Value;
end;

procedure TRMDKaDaoDatabase.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDatabase.Database := RMReadString(aStream);
  FDatabase.Version := RMReadString(aStream);
  FDatabase.UserName := RMReadString(aStream);
  FDatabase.Password := RMReadString(aStream);
  FDatabase.LoginPrompt := RMReadBoolean(aStream);
  FDatabase.Connected := RMReadBoolean(aStream);
end;

procedure TRMDKaDaoDatabase.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FDatabase.Database);
  RMWriteString(aStream, FDatabase.Version);
  RMWriteString(aStream, FDatabase.UserName);
  RMWriteString(aStream, FDatabase.Password);
  RMWriteBoolean(aStream, FDatabase.LoginPrompt);
  RMWriteBoolean(aStream, FDatabase.Connected);
end;

procedure TRMDKaDaoDatabase.ShowEditor;
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  OpenDialog.Filter := '*.MDB|*.MDB';
  try
    if OpenDialog.Execute then
    begin
      FDatabase.Database := OpenDialog.FileName;
    end;
  finally
    OpenDialog.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDKaDaoQuery}

constructor TRMDKaDaoQuery.Create;
begin
  inherited Create;
  BaseName := 'KADaoTable';
  FBmpRes := 'RMD_KadaoTable';

  FQuery := TKADaoTable.Create(RMDialogForm);
  FQuery.DatabaseAutoActivate := True;
  DataSet := FQuery;
  FComponent := FQuery;
end;

procedure TRMDKaDaoQuery.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
end;

procedure TRMDKaDaoQuery.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
end;

procedure TRMDKaDaoQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TKADaoDatabase, liStringList, nil);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

function TRMDKaDaoQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDKaDaoQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDKaDaoQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDKaDaoQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDKaDaoQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
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

function TRMDKaDaoQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDKaDaoQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDKaDaoQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDKaDaoQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;

function TRMDKaDaoQuery.GetParamCount: Integer;
begin
  Result := FQuery.ParamCount;
end;

function TRMDKaDaoQuery.GetSQL: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TRMDKaDaoQuery.SetSQL(Value: string);
begin
  FQuery.SQL.Text := Value;
end;

function TRMDKaDaoQuery.GetFilter: string;
begin
  Result := FQuery.Filter;
end;

procedure TRMDKaDaoQuery.SetFilter(Value: string);
begin
  FQuery.Active := False;
  FQuery.Filter := Value;
  FQuery.Filtered := Value <> '';
end;

function TRMDKaDaoQuery.GetDatabaseName: string;
begin
//  Result := FQuery.DatabaseName;
end;

procedure TRMDKaDaoQuery.SetDatabaseName(const Value: string);
begin
  FQuery.Active := False;
//  FQuery.DatabaseName := Value;
end;

function TRMDKaDaoQuery.GetDataSource: string;
begin
//  Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
  Result := '';
end;

procedure TRMDKaDaoQuery.SetDataSource(Value: string);
begin
end;


initialization
  RMRegisterControl(TRMDKaDaoDatabase, 'RMD_KaDaoDBControl', RMLoadStr(SInsertDB) + '(KADao)');
  RMRegisterControl(TRMDKaDaoQuery, 'RMD_KaDaoQUERYControl', RMLoadStr(SInsertQuery) + '(KADao)');

end.

