
{*****************************************}
{                                         }
{           Report Machine 2.0           }
{       Wrapper for Diamond Access        }
{                                         }
{*****************************************}

unit RMD_midas;

interface

{$I RM.INC}
{$IFDEF DM_MIDAS}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, Controls, StdCtrls, DBClient, MConnect,
  SConnect, RM_Class, RM_Dataset, RMD_DBWrap, RM_Parser, RM_Common
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDMidasComponents = class(TComponent) // fake component
  end;

  { TRMDDCOMConnection }
  TRMDDCOMConnection = class(TRMDialogComponent)
  private
    FFixupList: TRMVariables;
    FDCOMConnection: TDCOMConnection;
    function GetComputerName: string;
    procedure SetComputerName(Value: string);
    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetObjectBroker: string;
    procedure SetObjectBroker(Value: string);
    function GetServerGUID: string;
    procedure SetServerGUID(Value: string);
    function GetServerName: string;
    procedure SetServerName(Value: string);
  protected
    procedure AfterChangeName; override;
    procedure AfterLoaded; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property ComputerName: string read GetComputerName write SetComputerName;
    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property ObjectBroker: string read GetObjectBroker write SetObjectBroker;
    property ServerGUID: string read GetServerGUID write SetServerGUID;
    property ServerName: string read GetServerName write SetServerName;
    property DCOMConnection: TDCOMConnection read FDCOMConnection;
  end;

  { TRMDSocketConnection }
  TRMDSocketConnection = class(TRMDialogComponent)
  private
    FFixupList: TRMVariables;
    FSocketConnection: TSocketConnection;

    function GetAddress: string;
    procedure SetAddress(Value: string);
    function GetConnected: Boolean;
    procedure SetConnected(Value: Boolean);
    function GetLoginPrompt: Boolean;
    procedure SetLoginPrompt(Value: Boolean);
    function GetObjectBroker: string;
    procedure SetObjectBroker(Value: string);
    function GetServerGUID: string;
    procedure SetServerGUID(Value: string);
    function GetServerName: string;
    procedure SetServerName(Value: string);
    function GetHost: string;
    procedure SetHost(Value: string);
    function GetInterceptGUID: string;
    procedure SetInterceptGUID(Value: string);
    function GetPort: Integer;
    procedure SetPort(Value: Integer);
  protected
    procedure AfterChangeName; override;
    procedure AfterLoaded; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Address: string read GetAddress write SetAddress;
    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt;
    property ObjectBroker: string read GetObjectBroker write SetObjectBroker;
    property ServerGUID: string read GetServerGUID write SetServerGUID;
    property ServerName: string read GetServerName write SetServerName;
    property Host: string read GetHost write SetHost;
    property InterceptGUID: string read GetInterceptGUID write SetInterceptGUID;
    property Port: Integer read GetPort write SetPort;
    property SocketConnection: TSocketConnection read FSocketConnection;
  end;

  { TRMDClientDataSet }
  TRMDClientDataSet = class(TRMDTable)
  private
    FTable: TClientDataSet;

    function GetRemoteServer: string;
    procedure SetRemoteServer(Value: string);
    function GetProviderName: string;
    procedure SetProviderName(Value: string);
    function GetCommandText: string;
    procedure SetCommandText(Value: string);
    function GetPacketRecords: Integer;
    procedure SetPacketRecords(Value: Integer);
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;

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
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure AfterLoaded; override;

    property ClientDataSet: TClientDataSet read FTable;
  published
    property RemoteServer: string read GetRemoteServer write SetRemoteServer;
    property ProviderName: string read GetProviderName write SetProviderName;
    property CommandText: string read GetCommandText write SetCommandText;
    property PacketRecords: Integer read GetPacketRecords write SetPacketRecords;
    property IndexName;
  end;
{$ENDIF}

implementation

{$IFDEF DM_MIDAS}
{$R RMD_MIDAS.RES}

uses RM_Const, RM_utils, RM_PropInsp, RM_Insp;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDDCOMConnection }

constructor TRMDDCOMConnection.Create;
begin
  inherited Create;
  BaseName := 'DCOMConnection';
  FBmpRes := 'RMD_DCOMConnection';

  DontUndo := True;
  FDCOMConnection := TDCOMConnection.Create(RMDialogForm);
  FFixupList := TRMVariables.Create;
  FComponent := FDCOMConnection;
end;

destructor TRMDDCOMConnection.Destroy;
begin
  FFixupList.Free;
  if Assigned(RMDialogForm) then
  begin
    FDCOMConnection.Free;
    FDCOMConnection := nil;
  end;

  inherited Destroy;
end;

procedure TRMDDCOMConnection.AfterChangeName;
begin
  FDCOMConnection.Name := Name;
end;

procedure TRMDDCOMConnection.AfterLoaded;
begin
  try
    ObjectBroker := FFixupList['ObjectBroker'];
  except;
  end;

  inherited AfterLoaded;
end;

procedure TRMDDCOMConnection.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FDCOMConnection.ComputerName := RMReadString(aStream);
  FDCOMConnection.LoginPrompt := RMReadBoolean(aStream);
  FDCOMConnection.ServerGUID := RMReadString(aStream);
  FDCOMConnection.ServerName := RMReadString(aStream);
  FFixupList['ObjectBroker'] := RMReadString(aStream);
end;

procedure TRMDDCOMConnection.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FDCOMConnection.ComputerName);
  RMWriteBoolean(aStream, FDCOMConnection.LoginPrompt);
  RMWriteString(aStream, FDCOMConnection.ServerGUID);
  RMWriteString(aStream, FDCOMConnection.ServerName);
  RMWriteString(aStream, ObjectBroker);
end;

function TRMDDCOMConnection.GetComputerName: string;
begin
  Result := FDCOMConnection.ComputerName;
end;

procedure TRMDDCOMConnection.SetComputerName(Value: string);
begin
  FDCOMConnection.ComputerName := Value;
end;

function TRMDDCOMConnection.GetConnected: Boolean;
begin
  Result := FDCOMConnection.Connected;
end;

procedure TRMDDCOMConnection.SetConnected(Value: Boolean);
begin
  FDCOMConnection.Connected := Value;
end;

function TRMDDCOMConnection.GetLoginPrompt: Boolean;
begin
  Result := FDCOMConnection.LoginPrompt;
end;

procedure TRMDDCOMConnection.SetLoginPrompt(Value: Boolean);
begin
  FDCOMConnection.LoginPrompt := Value;
end;

function TRMDDCOMConnection.GetObjectBroker: string;
begin
  Result := '';
  if FDCOMConnection.ObjectBroker <> nil then
  begin
    Result := FDCOMConnection.ObjectBroker.Name;
    if FDCOMConnection.ObjectBroker.Owner <> FDCOMConnection.Owner then
      Result := FDCOMConnection.ObjectBroker.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDDCOMConnection.SetObjectBroker(Value: string);
var
  d: TComponent;
begin
  d := RMFindComponent(FDCOMConnection.Owner, Value);
  if d is TCustomObjectBroker then
    FDCOMConnection.ObjectBroker := TCustomObjectBroker(d);
end;

function TRMDDCOMConnection.GetServerGUID: string;
begin
  Result := FDCOMConnection.ServerGUID;
end;

procedure TRMDDCOMConnection.SetServerGUID(Value: string);
begin
  FDCOMConnection.ServerGUID := Value;
end;

function TRMDDCOMConnection.GetServerName: string;
begin
  Result := FDCOMConnection.ServerName;
end;

procedure TRMDDCOMConnection.SetServerName(Value: string);
begin
  FDCOMConnection.ServerName := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDSocketConnection }

constructor TRMDSocketConnection.Create;
begin
  inherited Create;
  BaseName := 'SocketConnection';
  FBmpRes := 'RMD_SocketConnection';

  DontUndo := True;
  FSocketConnection := TSocketConnection.Create(RMDialogForm);
  FComponent := FSocketConnection;
  FFixupList := TRMVariables.Create;
end;

destructor TRMDSocketConnection.Destroy;
begin
  FFixupList.Free;
  if Assigned(RMDialogForm) then
  begin
    FreeAndNil(FSocketConnection);
  end;

  inherited Destroy;
end;

procedure TRMDSocketConnection.AfterChangeName;
begin
  FSocketConnection.Name := Name;
end;

procedure TRMDSocketConnection.AfterLoaded;
begin
  try
    ObjectBroker := FFixupList['ObjectBroker'];
  except;
  end;

  inherited AfterLoaded;
end;

procedure TRMDSocketConnection.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FSocketConnection.Address := RMReadString(aStream);
  FSocketConnection.LoginPrompt := RMReadBoolean(aStream);
  FSocketConnection.ServerGUID := RMReadString(aStream);
  FSocketConnection.ServerName := RMReadString(aStream);
  FFixupList['ObjectBroker'] := RMReadString(aStream);
  FSocketConnection.Host := RMReadString(aStream);
  FSocketConnection.InterceptGUID := RMReadString(aStream);
  FSocketConnection.Port := RMReadInt32(aStream);
end;

procedure TRMDSocketConnection.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FSocketConnection.Address);
  RMWriteBoolean(aStream, FSocketConnection.LoginPrompt);
  RMWriteString(aStream, FSocketConnection.ServerGUID);
  RMWriteString(aStream, ServerName);
  RMWriteString(aStream, ObjectBroker);
  RMWriteString(aStream, FSocketConnection.Host);
  RMWriteString(aStream, FSocketConnection.InterceptGUID);
  RMWriteInt32(aStream, FSocketConnection.Port);
end;

type
  THackSocketConnection = class(TSocketConnection)
  end;

function TRMDSocketConnection.GetAddress: string;
begin
  Result := FSocketConnection.Address;
end;

procedure TRMDSocketConnection.SetAddress(Value: string);
begin
  FSocketConnection.Address := Value;
end;

function TRMDSocketConnection.GetConnected: Boolean;
begin
  Result := FSocketConnection.Connected;
end;

procedure TRMDSocketConnection.SetConnected(Value: Boolean);
begin
  FSocketConnection.Connected := Value;
end;

function TRMDSocketConnection.GetLoginPrompt: Boolean;
begin
  Result := FSocketConnection.LoginPrompt;
end;

procedure TRMDSocketConnection.SetLoginPrompt(Value: Boolean);
begin
  FSocketConnection.LoginPrompt := Value;
end;

function TRMDSocketConnection.GetObjectBroker: string;
begin
  Result := '';
  if FSocketConnection.ObjectBroker <> nil then
  begin
    Result := FSocketConnection.ObjectBroker.Name;
    if FSocketConnection.ObjectBroker.Owner <> FSocketConnection.Owner then
      Result := FSocketConnection.ObjectBroker.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDSocketConnection.SetObjectBroker(Value: string);
var
  d: TComponent;
begin
  d := RMFindComponent(FSocketConnection.Owner, Value);
  if d is TCustomObjectBroker then
    FSocketConnection.ObjectBroker := TCustomObjectBroker(d);
end;

function TRMDSocketConnection.GetServerGUID: string;
begin
  Result := FSocketConnection.ServerGUID;
end;

procedure TRMDSocketConnection.SetServerGUID(Value: string);
begin
  FSocketConnection.ServerGUID := Value;
end;

function TRMDSocketConnection.GetServerName: string;
begin
  Result := FSocketConnection.ServerName;
end;

procedure TRMDSocketConnection.SetServerName(Value: string);
begin
  FSocketConnection.ServerName := Value;
end;

function TRMDSocketConnection.GetHost: string;
begin
  Result := FSocketConnection.Host;
end;

procedure TRMDSocketConnection.SetHost(Value: string);
begin
  FSocketConnection.Host := Value;
end;

function TRMDSocketConnection.GetInterceptGUID: string;
begin
  Result := FSocketConnection.InterceptGUID;
end;

procedure TRMDSocketConnection.SetInterceptGUID(Value: string);
begin
  FSocketConnection.InterceptGUID := Value;
end;

function TRMDSocketConnection.GetPort: Integer;
begin
  Result := FSocketConnection.Port;
end;

procedure TRMDSocketConnection.SetPort(Value: Integer);
begin
  FSocketConnection.Port := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDClientDataSet }

constructor TRMDClientDataSet.Create;
begin
  inherited Create;
  BaseName := 'ClientDataSet';
  FBmpRes := 'RMD_CLIENTDATASET';

  FTable := TClientDataSet.Create(RMDialogForm);
  DataSet := FTable;
end;

destructor TRMDClientDataSet.Destroy;
begin
  inherited Destroy;
end;

function TRMDClientDataSet.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'CLIENTDATASET' then
    aValue := O2V(FTable)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMDClientDataSet.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FFixupList['RemoteServer'] := RMReadString(aStream);
  FFixupList['ProviderName'] := RMReadString(aStream);
  FTable.CommandText := RMReadString(aStream);
  FTable.PacketRecords := RMReadInt32(aStream);
end;

procedure TRMDClientDataSet.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, RemoteServer);
  RMWriteString(aStream, FTable.ProviderName);
  RMWriteString(aStream, FTable.CommandText);
  RMWriteInt32(aStream, FTable.PacketRecords);
end;

function TRMDClientDataSet.GetRemoteServer: string;
begin
  Result := '';
  if FTable.RemoteServer <> nil then
  begin
    Result := FTable.RemoteServer.Name;
    if FTable.RemoteServer.Owner <> FTable.Owner then
      Result := FTable.RemoteServer.Owner.Name + '.' + Result;
  end;
end;

procedure TRMDClientDataSet.SetRemoteServer(Value: string);
var
  d: TComponent;
begin
  FTable.Active := False;
  d := RMFindComponent(FTable.Owner, Value);
  if d is TCustomRemoteServer then
  begin
    FTable.Active := False;
    FTable.RemoteServer := TCustomRemoteServer(d);
  end;
end;

function TRMDClientDataSet.GetProviderName: string;
begin
  Result := FTable.ProviderName;
end;

procedure TRMDClientDataSet.SetProviderName(Value: string);
begin
  FTable.Active := False;
  FTable.ProviderName := Value;
end;

function TRMDClientDataSet.GetCommandText: string;
begin
  Result := FTable.CommandText;
end;

procedure TRMDClientDataSet.SetCommandText(Value: string);
begin
  FTable.CommandText := Value;
end;

function TRMDClientDataSet.GetPacketRecords: Integer;
begin
  Result := FTable.PacketRecords;
end;

procedure TRMDClientDataSet.SetPacketRecords(Value: Integer);
begin
  FTable.PacketRecords := Value;
end;

procedure TRMDClientDataSet.GetIndexNames(sl: TStrings);
begin
  try
    if FTable.ProviderName <> '' then
    begin
      FTable.GetIndexNames(sl);
    end;
  except
  end;
end;

function TRMDClientDataSet.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

type
  THackRemoveServer = class(TCustomRemoteServer)
  end;

procedure TRMDClientDataSet.AfterLoaded;
begin
  try
    RemoteServer := FFixupList['RemoteServer'];
    ProviderName := FFixupList['ProviderName'];
  except;
  end;

  inherited AfterLoaded;
end;

function TRMDClientDataSet.GetDatabaseName: string;
begin
  Result := '';
end;

procedure TRMDClientDataSet.SetDatabaseName(const Value: string);
begin
end;

function TRMDClientDataSet.GetTableName: string;
begin
  Result := '';
end;

procedure TRMDClientDataSet.SetTableName(Value: string);
begin
end;

function TRMDClientDataSet.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDClientDataSet.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDClientDataSet.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDClientDataSet.SetIndexName(Value: string);
begin
  FTable.Active := False;
  FTable.IndexName := Value;
end;

function TRMDClientDataSet.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

procedure TRMDClientDataSet.SetIndexFieldNames(Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

function TRMDClientDataSet.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDClientDataSet.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDClientDataSet.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDClientDataSet.SetMasterSource(Value: string);
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
type
  TRMDDComConnection_ServerNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TRMDDComConnection_ObjectBrokerEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TRMDSocketConnection_ServerNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TRMDClientDataSet_RemoteServerEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TRMDClientDataSet_ProviderNameEditor = class(TELStringPropEditor)
  private
    FProviderNames: TStringList;
    procedure GetOneProviderName(const s: string);
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDDComConnection_ServerNameEditor }

function TRMDDComConnection_ServerNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDDComConnection_ServerNameEditor.GetValues(AValues: TStrings);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    GetMIDASAppServerList(sl, '');
    sl.Sort;
    aValues.Assign(sl);
  finally
    sl.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDDComConnection_ObjectBrokerEditor }

function TRMDDComConnection_ObjectBrokerEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDDComConnection_ObjectBrokerEditor.GetValues(AValues: TStrings);
begin
  try
    RMGetComponents(RMDialogForm, TCustomObjectBroker, AValues, nil);
  finally
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDSocketConnection_ServerNameEditor }

function TRMDSocketConnection_ServerNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDSocketConnection_ServerNameEditor.GetValues(AValues: TStrings);
var
  lSocketConnection: TSocketConnection;
  sl: TStringList;
  tmp: OleVariant;
  i, liCount: Integer;
begin
  lSocketConnection := TRMDSocketConnection(GetInstance(0)).FSocketConnection;
  sl := TStringList.Create;
  try
    tmp := THackSocketConnection(lSocketConnection).GetServerList;
    if tmp <> Null then
    begin
      liCount := VarArrayDimCount(tmp);
      for i := 0 to liCount do
      begin
        aValues.Add(tmp[i]);
      end;
    end;
  finally
    sl.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDClientDataSet_RemoteServerEditor }

function TRMDClientDataSet_RemoteServerEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDClientDataSet_RemoteServerEditor.GetValues(AValues: TStrings);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    RMGetComponents(RMDialogForm, TCustomRemoteServer, sl, nil);
    sl.Sort;
    aValues.Assign(sl);
  finally
    sl.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDClientDataSet_ProviderNameEditor }

function TRMDClientDataSet_ProviderNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TRMDClientDataSet_ProviderNameEditor.GetOneProviderName(const s: string);
begin
  FProviderNames.Add(s);
end;

procedure TRMDClientDataSet_ProviderNameEditor.GetValues(AValues: TStrings);
var
  lClientDataSet: TClientDataSet;
begin
  lClientDataSet := TRMDClientDataSet(GetInstance(0)).FTable;
  if lClientDataSet.RemoteServer <> nil then
  begin
    FProviderNames := TStringList.Create;
    try
      THackRemoveServer(lClientDataSet.RemoteServer).GetProviderNames(GetOneProviderName);
      aValues.Assign(FProviderNames);
    finally
      FProviderNames.Free;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

const
	cReportMachine = 'RMD_midas';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cReportMachine, TRMDDCOMConnection, 'TRMDDCOMConnection');
    AddClass(cReportMachine, TRMDSocketConnection, 'TRMDSocketConnection');
    AddClass(cReportMachine, TRMDClientDataSet, 'TRMDClientDataSet');
  end;
end;

initialization
//  RMRegisterControl(TRMDDComConnection, 'RMD_DCOMCONNECTIONCONTROL', RMLoadStr(rmRes + 2497));
//  RMRegisterControl(TRMDSocketConnection, 'RMD_SOCKETCONNECTIONCONTROL', RMLoadStr(rmRes + 2498));
//  RMRegisterControl(TRMDClientDataSet, 'RMD_CLIENTDATASETCONTROL', RMLoadStr(rmRes + 2496));
  RMRegisterControls('MIDAS', 'RMD_MIDASPATH', True,
    [TRMDDComConnection, TRMDSocketConnection, TRMDClientDataSet],
    ['RMD_DCOMCONNECTIONCONTROL', 'RMD_SOCKETCONNECTIONCONTROL', 'RMD_CLIENTDATASETCONTROL'],
    [RMLoadStr(rmRes + 2497), RMLoadStr(rmRes + 2498), RMLoadStr(rmRes + 2496)]);

  RMRegisterPropEditor(TypeInfo(string), TRMDDComConnection, 'ServerName', TRMDDComConnection_ServerNameEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDDComConnection, 'ObjectBroker', TRMDDComConnection_ObjectBrokerEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDSocketConnection, 'ObjectBroker', TRMDDComConnection_ObjectBrokerEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDSocketConnection, 'ServerName', TRMDSocketConnection_ServerNameEditor);

  RMRegisterPropEditor(TypeInfo(string), TRMDClientDataSet, 'RemoteServer', TRMDClientDataSet_RemoteServerEditor);
  RMRegisterPropEditor(TypeInfo(string), TRMDClientDataSet, 'ProviderName', TRMDClientDataSet_ProviderNameEditor);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);
finalization
{$ENDIF}
end.

