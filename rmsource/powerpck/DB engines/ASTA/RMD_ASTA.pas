
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{             Wrapper for ADO             }
{                                         }
{*****************************************}

unit RMD_ASTA;

interface

{$I RM.INC}
uses
  Windows, Classes, SysUtils, Graphics, Forms, ExtCtrls, DB,
  AstaCustomSocket, AstaClientSocket, AstaDrv2, AstaClientDataset,AstaStringLine,AstaDBTypes,
  StdCtrls, Controls, RM_Class, RMD_DBWrap ,ScktComp
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TRMDASTAComponents = class(TComponent) // fake component
  end;

  TRMDASTADatabase = class(TRMNonVisualControl)
  private
    FAstaClientSocket: TAstaClientSocket;
  protected
    procedure SetPropValue(Index: string; Value: Variant); override;
    function GetPropValue(Index: string): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefineProperties; override;
  end;

  { TRMDAstaClientDataSet }
  TRMDAstaClientDataSet = class(TRMDQuery)
  private
    FQuery: TAstaClientDataSet;
  protected
    procedure SetPropValue(Index: string; Value: Variant); override;
    function GetPropValue(Index: string): Variant; override;
    function DoMethod(const MethodName: string; Pars: array of Variant): Variant; override;

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
    procedure DefineProperties; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  published
  end;

implementation

uses RM_Const, RM_CmpReg, RM_utils;

{$R RMD_ASTA.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDAstaDatabase}

constructor TRMDASTADatabase.Create;
begin
  inherited Create;
  FAstaClientSocket := TAstaClientSocket.Create(RMDialogForm);
  FAstaClientSocket.ConnectAction := caNone;
  Component := FAstaClientSocket;
  BaseName := 'AstaDatabase';
  BmpRes := 'RMD_ASTASOCKET';
  Flags := Flags or flDontUndo;
  //  asta compress config
  RMConsts['acAstaCompress'] := acAstaCompress;
  RMConsts['acAstaZLib'] := acAstaZLib;
  RMConsts['acNoCompression'] := acNoCompression;
  RMConsts['acUserDefined'] := acUserDefined;
  //  asta encryption config
  RMConsts['etNoEncryption'] := etNoEncryption;
  RMConsts['etAstaEncrypt'] := etAstaEncrypt;
  RMConsts['etUserDefined'] := etUserDefined;
  RMConsts['etAESEncrypt'] := etAESEncrypt;
  //  asta ClientType config
  RMConsts['ctNonBlocking'] := ctNonBlocking;
  RMConsts['ctBlocking'] := ctBlocking;

end;

destructor TRMDASTADatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
    FAstaClientSocket.Free;
  inherited Destroy;
end;

procedure TRMDASTADatabase.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Connected', [rmdtBoolean], nil);
  AddProperty('Address',[rmdtString],nil);
  AddProperty('DateMaskForSQL',[rmdtString],nil);
  AddProperty('DateTimeMaskForSQL',[rmdtString],nil);
  AddProperty('ApplicationName',[rmdtString],nil);

  AddProperty('Port',[rmdtInteger],nil);
  AddEnumProperty('Compression',
    'acNoCompression;acAstaCompress;acUserDefined;acAstaZLib',
    [acNoCompression,acAstaCompress,acUserDefined,acAstaZLib], nil);

  AddEnumProperty('Encryption',
    'etNoEncryption;etAstaEncrypt;etUserDefined;etAESEncrypt',
    [etNoEncryption,etAstaEncrypt,etUserDefined,etAESEncrypt], nil);

  AddEnumProperty('ClientType',
    'ctNonBlocking; ctBlocking',
    [ctNonBlocking, ctBlocking], nil);

end;

procedure TRMDASTADatabase.SetPropValue(Index: string; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ADDRESS' then
    FAstaClientSocket.Address := Value
  else if Index = 'PORT' then
    FAstaClientSocket.Port := Value
  else if Index = 'DATEMASKFORSQL' then
    FAstaClientSocket.DateMaskForSQL := Value
  else if Index = 'DATETIMEMASKFORSQL' then
    FAstaClientSocket.DateTimeMaskForSQL := Value
  else if Index = 'APPLICATIONNAME' then
    FAstaClientSocket.ApplicationName := Value
  else if Index = 'COMPRESSION' then
    FAstaClientSocket.Compression := Value
  else if Index = 'ENCRYPTION' then
    FAstaClientSocket.Encryption := Value
  else if Index = 'CLIENTTYPE' then
    FAstaClientSocket.ClientType := Value
  else if Index = 'CONNECTED' then
    FAstaClientSocket.Active := Value
end;

function TRMDASTADatabase.GetPropValue(Index: string): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ADDRESS' then
    Result := FAstaClientSocket.Address
  else if Index = 'PORT' then
    Result := FAstaClientSocket.Port
  else if Index = 'DATEMASKFORSQL' then
    Result := FAstaClientSocket.DateMaskForSQL
  else if Index = 'DATETIMEMASKFORSQL' then
    Result := FAstaClientSocket.DateTimeMaskForSQL
  else if Index = 'APPLICATIONNAME' then
    Result := FAstaClientSocket.ApplicationName
  else if Index = 'COMPRESSION' then
    Result := FAstaClientSocket.Compression
  else if Index = 'ENCRYPTION' then
    Result := FAstaClientSocket.Encryption
  else if Index = 'CLIENTTYPE' then
    Result := FAstaClientSocket.ClientType
  else if Index = 'CONNECTED' then
    Result := FAstaClientSocket.Active
end;

procedure TRMDASTADatabase.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FAstaClientSocket.Address := RMReadString(Stream);
  FAstaClientSocket.Port := RMReadInteger(Stream);
  FAstaClientSocket.DateMaskForSQL := RMReadString(Stream);
  FAstaClientSocket.DateTimeMaskForSQL := RMReadString(Stream);
  FAstaClientSocket.ApplicationName := RMReadString(Stream);
  FAstaClientSocket.Compression := TAstaCompression(RMReadByte(Stream));
  FAstaClientSocket.Encryption := TAstaEncryption(RMReadByte(Stream));
  FAstaClientSocket.ClientType := TClientType(RMReadByte(Stream));
  FAstaClientSocket.Active := RMReadBoolean(Stream);
end;

procedure TRMDASTADatabase.SaveToStream(Stream: TStream);
begin
  LVersion := 0;
  inherited SaveToStream(Stream);
  RMWriteString(Stream, FAstaClientSocket.Address);
  RMWriteInteger(Stream, FAstaClientSocket.Port);
  RMWriteString(Stream, FAstaClientSocket.DateMaskForSQL);
  RMWriteString(Stream, FAstaClientSocket.DateTimeMaskForSQL);
  RMWriteString(Stream, FAstaClientSocket.ApplicationName);
  RMWriteByte(Stream, Byte(FAstaClientSocket.Compression));
  RMWriteByte(Stream, Byte(FAstaClientSocket.Encryption));
  RMWriteByte(Stream, Byte(FAstaClientSocket.ClientType));
  RMWriteBoolean(Stream, FAstaClientSocket.Active);
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDAstaClientDataSet}

constructor TRMDAstaClientDataSet.Create;
begin
  inherited Create;
  FQuery := TAstaClientDataSet.Create(RMDialogForm);
  DataSet := FQuery;

  Component := FQuery;
  BaseName := 'AstaClientDataSet';
  BmpRes := 'RMD_ASTACLIENTDATASET';
end;

procedure TRMDAstaClientDataSet.DefineProperties;
begin
  inherited DefineProperties;
end;

procedure TRMDAstaClientDataSet.SetPropValue(Index: string; Value: Variant);
var
  d: TComponent;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if index = 'DATABASE' then
  begin
    FQuery.Close;
    d := RMFindComponent(FQuery.Owner, Value);
    FQuery.AstaClientSocket := TAstaClientSocket(d);
  end
  else if Index = 'DATASOURCE' then
  begin
  end
  else if index = 'PARAMS.COUNT' then
  begin
  end
  else if Index = 'SQL' then
  begin
    FQuery.Close;
    FQuery.SQL.Text := Value;
  end
end;

function TRMDAstaClientDataSet.GetPropValue(Index: string): Variant;

  function GetDataBase(Owner: TComponent; d: TAstaClientSocket): string;
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
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASE' then
    Result := GetDataBase(FQuery.Owner, FQuery.AstaClientSocket)
  else if Index = 'DATASOURCE' then
    Result := ''
  else if Index = 'PARAMS.COUNT' then
    Result := FQuery.Params.Count
  else if Index = 'SQL' then
    Result := FQuery.SQL.Text
  else if Index = 'SQL.COUNT' then
    Result := FQuery.SQL.Count
end;

function TRMDAstaClientDataSet.DoMethod(const MethodName: string; Pars: array of Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Pars);
  if Result = Null then
    Result := LinesMethod(FQuery.SQL, MethodName, 'SQL', Pars[0], Pars[1], Pars[2]);
  if MethodName = 'EXECSQL' then
  begin
    OnBeforeOpenQueryEvent(FQuery);
    FQuery.ExecSQL;
  end;
end;

procedure TRMDAstaClientDataSet.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
end;

procedure TRMDAstaClientDataSet.SaveToStream(Stream: TStream);
begin
  LVersion := 0;
  inherited SaveToStream(Stream);
end;

procedure TRMDAstaClientDataSet.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TAstaClientSocket, liStringList, nil);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure TRMDAstaClientDataSet.GetTableNames(DB: string; Strings: TStrings);
var
  sl : TStringList;
begin
  if FQuery.Active then FQuery.Active := False;
  FQuery.MetaDataRequest := mdTables;
  FQuery.SQL.Clear;
  FQuery.TableName := '';
  sl := TStringList.Create;
  FQuery.Open;
  FQuery.DisableControls;
  try
    FQuery.First;
    while not FQuery.Eof do
    begin
      sl.Add(FQuery.Fields[0].AsString);
      FQuery.Next;
    end;
    sl.Sort;
    Strings.Assign(sl);
  finally
    FQuery.EnableControls;
    FQuery.Close;
    FQuery.MetaDataRequest := mdNormalQuery;
    sl.Free;
  end;
end;

procedure TRMDAstaClientDataSet.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  sl1 : TStringList;
begin
  if FQuery.Active then FQuery.Active := False;
  FQuery.MetaDataRequest := mdFields;
  FQuery.SQL.Clear;
  FQuery.TableName := TName;
  FQuery.Open;
  FQuery.DisableControls;
  sl1 := TStringList.Create;
  try
    FQuery.First;
    while not FQuery.Eof do
    begin
      sl1.Add(FQuery.Fields[0].AsString);
      FQuery.Next;
    end;
    sl1.Sort;
    sl.Assign(sl1);
  finally
    FQuery.EnableControls;
    FQuery.Close;
    FQuery.MetaDataRequest := mdNormalQuery;
    sl1.Free;
  end;
end;

function TRMDAstaClientDataSet.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDAstaClientDataSet.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDAstaClientDataSet.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDAstaClientDataSet.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if FQuery.Params[index].IsNull then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDAstaClientDataSet.SetParamKind(Index: Integer; Value: TRMParamKind);
begin
  if Value = rmpkAssignFromMaster then
  begin
    FQuery.Params[index].Clear;
    FParams.Delete(FParams.IndexOf(FQuery.Params[Index].Name));
  end
  else
  begin
    FQuery.Params[index].Clear;
    FParams[FQuery.Params[Index].Name] := '';
  end;
end;

function TRMDAstaClientDataSet.GetParamText(Index: Integer): string;
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

procedure TRMDAstaClientDataSet.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDAstaClientDataSet.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDAstaClientDataSet.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;


initialization
  RMRegisterControl(TRMDASTADatabase, 'RMD_ASTASOCKETCONTROL', 'ASTAClientSocket(ASTA)');
  RMRegisterControl(TRMDAstaClientDataSet, 'RMD_ASTACLIENTDATASETCONTROL', 'ASTAClientDataSet(ASTA)');

finalization

end.

