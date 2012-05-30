{***************************************************************}
{                                         　　　　　　　　　　　}
{              Report Machine            　　　　　　　　　　　 }
{                                       　　　　　　　　　　　  }
{             system unit              　　　　　　　　　　　   }
{             系统单元，由dejoy友情提供　　      　　　　　　　 }
{                                         　　　　　　　　　　　}
{           作者: dejoy(qq:23487189)                            }
{***************************************************************}

unit RM_System;

{$I RM.inc}
interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvInterpreter, rm_JvInterpreterFm
{$ELSE}
  , JvInterpreter, JvInterpreterFm
{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
{$IFNDEF COMPILER6_UP}
  EOSError = class(EWin32Error);
  IInterface = IUnknown;
{$M+}
  IInvokable = interface(IInterface)
  end;
{$M-}
  IStreamPersist = interface
    ['{B8CD12A3-267A-11D4-83DA-00C04F60B2DD}']
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  end;

  TInterfacedPersistent = class(TPersistent, IInterface)
  private
    FOwnerInterface: IInterface;
  protected
    { IInterface }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    procedure AfterConstruction; override;
  end;
{$ENDIF COMPILER6_UP}

  TRMPersistent = class;
  TRMPersistentCompAdapter = class;

  {created by dejoy}
  TRMNamedItem = class(TCollectionItem)
  private
  protected
    FName: string;
    procedure OnChange(Sender: TObject); virtual;
    procedure SetDisplayName(const Value: string); override;
    function GetDisplayName: string; override;
    property Name: string read FName write FName;
  public
    procedure Assign(Source: TPersistent); override;
  published
  end;

  TRMNamedItemClass = class of TRMNamedItem;
  TUpdateCollectionEvent = procedure(Sender: TObject; Item: TCollectionItem) of object;

  {created by dejoy}
  TRMCustomNamedItems = class(TCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
    FOnUpdate: TUpdateCollectionEvent;

    function GetItem(Index: integer): TRMNamedItem;

    function GetName(Index: Integer): string;
    procedure SetName(Index: Integer; Value: string);
  protected
    procedure FreeNotificationProc(Instance: TObject);
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; ItemClass: TRMNamedItemClass); virtual;
    destructor Destroy; override;
    function GetOwner: TPersistent; override;

    function IndexOfName(const Name: string): Integer;
    function IndexOf(Item: TRMNamedItem): Integer; overload;
    function IndexOf(const Name: string): Integer; overload;

    property Items[index: integer]: TRMNamedItem read GetItem;
    property Name[Index: Integer]: string read GetName write SetName;
{$IFNDEF COMPILER6_UP}
    property Owner: TPersistent read FOwner;
{$ENDIF}
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnUpdate: TUpdateCollectionEvent read FOnUpdate write FOnUpdate;
  end;

  TRMNamedItems = class(TRMCustomNamedItems)
  public
    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure SaveToFile(const FileName: string); virtual;
  end;

 {TRMVariableItem   ReCreated by dejoy}
  TRMVariableItem = class(TRMNamedItem)
  private
    FValue: Variant;
    FIsExpression: Boolean;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Name;
    property Value: Variant read FValue write FValue;
    property IsExpression: Boolean read FIsExpression write FIsExpression;
  end;

 { TRMVariables   ReCreated by dejoy}
  TRMVariables = class(TRMNamedItems)
  private
    function GetItem(Index: integer): TRMVariableItem;
    function GetVariable(const Name: string): Variant;
    function GetValue(Index: Integer): Variant;

    procedure SetVariable(const Name: string; Value: Variant);
    procedure SetStringVariable(const aName: string; aValue: Variant);
    procedure SetValue(Index: Integer; Value: Variant);
  public
    constructor Create(AOwner: TPersistent = nil);reintroduce; overload; virtual;

    function Add(const aName: string; aValue: Variant): Integer; overload;
    procedure AddCategory(const Name: string);
    procedure Delete(Index: Integer);
    procedure DeleteByName(const AName: string);
    procedure Insert(Index: Integer; const aName: string; aValue: Variant); overload;

    property Variable[const Name: string]: Variant read GetVariable write SetVariable; default;
    property Value[Index: Integer]: Variant read GetValue write SetValue;
    property AsString[const Name: string]: Variant read GetVariable write SetStringVariable;
    property Items[index: integer]: TRMVariableItem read GetItem;
  published
  end;

  { TRMPersistentCompAdapter }
  TRMPersistentCompAdapter = class(TComponent
{$IFNDEF COMPILER6_UP}
      , IInterface
{$ENDIF}
      )
  private
  protected
    FComp: TObject;
  public
    constructor CreateComp(aComp: TObject); virtual;
    destructor Destroy; override;
  end;


  { TRMPersistent }
  TRMPersistent = class(TInterfacedPersistent)
  private
    function GetEventPropVars: TRMVariables;
  protected
    FEventPropVars: TRMVariables;
    FName: string;
    FComAdapter: IInterface;

    procedure LoadEventInfo(aStream: TStream);
    procedure SaveEventInfo(aStream: TStream);

    procedure SetObjectEvent(aEventList: TList; aEngine: TJvInterpreterProgram);
    procedure SetName(const Value: string); virtual;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; virtual;
    function SetPropValue(aObject: TObject; aPropName: string;
      aValue: Variant): Boolean; virtual;

    function GetComAdapter: IInterface;
    procedure SetComAdapter(const Value: IInterface);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property EventPropVars: TRMVariables read GetEventPropVars;
    property Name: string read FName write SetName;
    property ComAdapter: IInterface read GetComAdapter write SetComAdapter;
  published
  end;

 { TRMComponent }
  TRMComponent = class(TComponent)
  private
    function GetComAdapter: IInterface;
    procedure SetComAdapter(const Value: IInterface);
    function GetEventPropVars: TRMVariables;
  protected
    FEventPropVars: TRMVariables;
    FComAdapter: IInterface;

    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; virtual;
    function SetPropValue(aObject: TObject; aPropName: string;
      aValue: Variant): Boolean; virtual;
  public
    destructor Destroy; override;
    property EventPropVars: TRMVariables read GetEventPropVars;
    property ComAdapter: IInterface read GetComAdapter write SetComAdapter;
  end;

{TRMEventItem}
  TRMEventItem = class(TRMNamedItem)
  private
    FObjectName: string;
    FEventValueName: string;
    FEventPropName: string;
    FInstance: TPersistent;
  protected
  public
  published
    property Instance: TPersistent read FInstance write FInstance;
    property ObjectName: string read FObjectName write FObjectName;
    property EventPropName: string read FEventPropName write FEventPropName;
    property EventValueName: string read FEventValueName write FEventValueName;
  end;

{TRMCustomEventItems}
  TRMCustomEventItems = class(TRMNamedItems)
  private
    function GetItem(index: integer): TRMEventItem;
  public
    constructor Create(AOwner: TComponent);reintroduce; overload; virtual;

    property Items[index: integer]: TRMEventItem read GetItem;
  end;


{TRMEventPropVars}
  {保存报表中的对象的script事件列表}

  TRMEventPropVars = class(TRMCustomEventItems)
  private
    FParentReport: TComponent;
  protected
    procedure CheckParentReport;
  public
    constructor Create(aReport: TComponent); override;

    function IndexOfEvent(aObjectName: string; aEventPropName: string): integer; overload;
    function IndexOfEvent(AInstance: TPersistent; aEventPropName: string): integer; overload;

    {SetEventPropVar  添加对象事件过程,示例:
     SetEventPropVar('Memo1','OnBeforePrint','Memo1_OnBeforePrint');
    }

    function GetEventPropVar(AInstance: TPersistent; APropName: string): string;
    function SetEventPropVar(AInstance: TPersistent; APropName, AProcName: string): integer;

    function DeleteEventProp(AInstance: TPersistent; APropName: string): boolean;
    procedure RenameEventProc(aOldProcName, aNewProcName: string);

    function DeleteAllEventByObjName(aComponentName: string): boolean; overload;

  end;

implementation

uses
  RM_Const, RM_Common, RM_Utils, TypInfo
{$IFDEF COMPILER6_UP}
  , RtlConsts
{$ENDIF}
  ;

procedure E_GetComponent(var aObject: TObject; var aPropName: string);
var
  lPropInfo: PPropInfo;
  lPos: integer;
begin
  while Pos('.', aPropName) > 0 do
  begin
    lPos := Pos('.', aPropName);
    lPropInfo := GetPropInfo(aObject.ClassInfo, Copy(aPropName, 1, lPos - 1));
    aObject := TObject(GetOrdProp(aObject, lPropInfo));
    Delete(aPropName, 1, lPos);
  end;
end;

{ TInterfacedPersistent }

{$IFNDEF COMPILER6_UP}

procedure TInterfacedPersistent.AfterConstruction;
begin
  inherited;
  if GetOwner <> nil then
    GetOwner.GetInterface(IInterface, FOwnerInterface);
end;

function TInterfacedPersistent._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef else
    Result := -1;
end;

function TInterfacedPersistent._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release else
    Result := -1;
end;

function TInterfacedPersistent.QueryInterface(const IID: TGUID;
  out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := E_NOINTERFACE;
end;
{$ENDIF}

{TRMNamedItem}
{--------------------------------------------}

procedure TRMNamedItem.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TRMNamedItem) then
    Self.Name := TRMNamedItem(Source).Name
  else
    inherited;
end;

{--------------------------------------------}


procedure TRMNamedItem.SetDisplayName(const Value: string);
begin
  Name := Value;
end;

{--------------------------------------------}

function TRMNamedItem.GetDisplayName: string;
begin
  Result := Name;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

{--------------------------------------------}

procedure TRMNamedItem.OnChange(Sender: TObject);
begin
  Changed(False);
end;

{------------------------------------------------------------------}

{TRMCustomNamedItems}
{------------------------------------------------------------------}

procedure TRMCustomNamedItems.FreeNotificationProc(Instance: TObject);
begin
  FOwner := nil;
end;

{--------------------------------------------}

function TRMCustomNamedItems.IndexOfName(const Name: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if CompareText(Name, TRMNamedItem(Items[i]).Name) = 0 then
    begin
      Result := i;
      exit;
    end;
  Result := -1;
end;

{--------------------------------------------}

function TRMCustomNamedItems.IndexOf(Item: TRMNamedItem): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i] = Item then
    begin
      Result := i;
      exit;
    end;
  Result := -1;
end;

function TRMCustomNamedItems.IndexOf(const Name: string): Integer;
begin
  Result := IndexOfName(Name);
end;

function TRMCustomNamedItems.GetItem(Index: integer): TRMNamedItem;
begin
  Result := TRMNamedItem(inherited Items[Index]);
end;

function TRMCustomNamedItems.GetName(Index: Integer): string;
begin
  Result := '';
  if (Index < 0) or (Index >= Count) then Exit;
  Result := Items[Index].Name;
end;

procedure TRMCustomNamedItems.SetName(Index: Integer; Value: string);
begin
  if (Index < 0) or (Index >= Count) or (Value = '') then Exit;
  Items[Index].Name := Value;
end;

{--------------------------------------------}

procedure TRMCustomNamedItems.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
  if Assigned(FOnUpdate) then
    FonUpdate(Self, Item);
end;

{--------------------------------------------}

constructor TRMCustomNamedItems.Create(AOwner: TPersistent; ItemClass: TRMNamedItemClass);
begin
  inherited Create(ItemClass);
  FOwner := AOwner;
end;

{--------------------------------------------}

destructor TRMCustomNamedItems.Destroy;
begin
  inherited;
end;

{--------------------------------------------}

function TRMCustomNamedItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{--------------------------------------------}
{--------------------------------------------}

{ TRMNamedItems }

procedure TRMNamedItems.LoadFromFile(const FileName: string);
begin
  RMReadObjFromFile(Self, FileName);
end;

procedure TRMNamedItems.LoadFromStream(Stream: TStream);
begin
  RMReadObjFromStream(Stream, Self);
end;

procedure TRMNamedItems.SaveToFile(const FileName: string);
begin
  RMWriteObjToFile(Self, FileName);
end;

procedure TRMNamedItems.SaveToStream(Stream: TStream);
begin
  RMWriteObjToStream(Stream, Self);
end;

{ TRMVariableItem }

procedure TRMVariableItem.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TRMVariableItem) then
  begin
    inherited;
    Self.Value := TRMVariableItem(Source).Value;
    Self.IsExpression := TRMVariableItem(Source).IsExpression;
  end
  else
    inherited;
end;

constructor TRMVariableItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FIsExpression := False;
  FValue := null;
end;

{------------------------------------------------------------------------------}
{TRMVariables}

constructor TRMVariables.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TRMVariableItem);
end;

procedure TRMVariables.SetVariable(const Name: string; Value: Variant);
begin
  Add(Name, Value);
end;

procedure TRMVariables.SetStringVariable(const aName: string; aValue: Variant);
var
  i: Integer;
  s: string;
begin
  i := IndexOfName(aName);
  s := VarToStr(aValue);
  s := QuotedStr(s);
  if i >= 0 then
  begin
    Items[i].Value := s;
  end
  else
  begin
    SetVariable(aName, s);
  end;
end;

function TRMVariables.GetItem(Index: integer): TRMVariableItem;
begin
  Result := TRMVariableItem(inherited Items[Index]);
end;

function TRMVariables.GetVariable(const Name: string): Variant;
var
  i: Integer;
begin
  i := IndexOfName(Name);
  if i >= 0 then
    Result := Items[i].Value
  else
    Result := Null;
end;

procedure TRMVariables.SetValue(Index: Integer; Value: Variant);
begin
  if (Index < 0) or (Index >= Count)
    or (Items[Index].Name = '') then Exit;

  Items[Index].Value := Value;

end;

function TRMVariables.GetValue(Index: Integer): Variant;
begin
  Result := 0;
  if (Index < 0) or (Index >= Count)
    or (Items[Index].Name = '') then Exit;

  Result := Items[Index].Value;
end;

procedure TRMVariables.Insert(Index: Integer; const aName: string; aValue: Variant);
var
  i: integer;
begin
  i := Add(aName, aValue);

  if i <> -1 then
    Items[i].Index := Index;
end;

function TRMVariables.Add(const aName: string; aValue: Variant): Integer;
var
  lItem: TRMVariableItem;
begin
  Result := -1;
  if Trim(aName) = '' then Exit;

  Result := IndexOfName(aName);
  if Result <> -1 then
    Items[Result].Value := aValue
  else
  begin
    lItem := TRMVariableItem(inherited Add());
    lItem.Name := aName;
    lItem.Value := aValue;
    lItem.IsExpression := True;
    Result := Count - 1;
  end;
end;

procedure TRMVariables.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= Count) then Exit;
  inherited Delete(Index);
end;

procedure TRMVariables.AddCategory(const Name: string);
begin
  SetVariable(' ' + Name, '');
end;

procedure TRMVariables.DeleteByName(const AName: string);
begin
  Delete(IndexOfName(AName));
end;

{------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
{ TRMPersistentCompAdapter }

constructor TRMPersistentCompAdapter.CreateComp(aComp: TObject);
begin
  inherited Create(nil);

  FComp := aComp;
end;

destructor TRMPersistentCompAdapter.Destroy;
begin
  inherited Destroy;
end;

{------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
{ TRMPersistent }

constructor TRMPersistent.Create;
begin
  inherited Create;

  FEventPropVars := nil;
end;

destructor TRMPersistent.Destroy;
begin
  FComAdapter := nil;
  FreeAndNil(FEventPropVars);
  inherited Destroy;
end;

function TRMPersistent.GetEventPropVars: TRMVariables;
begin
  if FEventPropVars = nil then
  begin
    FEventPropVars := TRMVariables.Create;
  end;

  Result := FEventPropVars;
end;

procedure TRMPersistent.LoadEventInfo(aStream: TStream);
var
  i, lCount: Integer;
  lStr: string;
begin
  lCount := RMReadWord(aStream);
  for i := 0 to lCount - 1 do
  begin
    lStr := RMReadString(aStream);
    EventPropVars[lStr] := RMReadString(aStream);
  end;
end;

procedure TRMPersistent.SaveEventInfo(aStream: TStream);
var
  i: Integer;
begin
  if FEventPropVars = nil then
    RMWriteWord(aStream, 0)
  else
  begin
    RMWriteWord(aStream, FEventPropVars.Count);
    for i := 0 to FEventPropVars.Count - 1 do
    begin
      RMWriteString(aStream, FEventPropVars.Name[i]);
      RMWriteString(aStream, FEventPropVars.Value[i]);
    end;
  end;
end;

function TRMPersistent.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  E_GetComponent(aObject, aPropName);
  Result := RMGetPropValue_1(aObject, aPropName, aValue);
end;

function TRMPersistent.SetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean;
begin
  E_GetComponent(aObject, aPropName);
  Result := RMSetPropValue(aObject, aPropName, aValue);
end;

procedure TRMPersistent.SetName(const Value: string);
begin
  FName := Value;
end;

type
  THackEngine = class(TJvInterpreterProgram {TJvInterpreterFm});
  THackRMCustomComponent = class(TRMPersistent);

procedure TRMPersistent.SetObjectEvent(aEventList: TList; aEngine: TJvInterpreterProgram);
var
  i: Integer;
  lMethod: TMethod;
  lPropInfo: PPropInfo;
  lPropName: string;
  lPropValue: string;
begin
  if FEventPropVars = nil then Exit;

  for i := 0 to EventPropVars.Count - 1 do
  begin
    lPropName := EventPropVars.Name[i];
    lPropValue := EventPropVars.Value[i];
    if (lPropValue <> '') and
      aEngine.FunctionExists('Report', lPropValue) then
    begin
      lPropInfo := TypInfo.GetPropInfo(Self, lPropName);
      try
        lMethod := TMethod(THackEngine(aEngine).NewEvent(
          'Report',
          lPropValue,
          lPropInfo^.PropType^.Name,
          Self, lPropName));
        TypInfo.SetMethodProp(Self, lPropInfo, lMethod);
        aEventList.Add(lMethod.Data);
      except
      end;
    end;
  end;
end;

function TRMPersistent.GetComAdapter: IInterface;
var
  i: Integer;
begin
  if FComAdapter = nil then
  begin
    for i := 0 to RMComAdapterList.Count - 1 do
    begin
      if TRMPageEditorInfo(RMComAdapterList[i]).PageClass = ClassType then
      begin
        FComAdapter := TRMPersistentCompAdapterClass(TRMPageEditorInfo(RMComAdapterList[i]).PageEditorClass).CreateComp(Self);
        Break;
      end;
    end;
  end;

  Result := FComAdapter;
end;

procedure TRMPersistent.SetComAdapter(const Value: IInterface);
begin
  FComAdapter := Value;
end;

{------------------------------------------------------------------------------}
{ TRMComponent }

destructor TRMComponent.Destroy;
begin
  FComAdapter := nil;
  inherited Destroy;
end;

function TRMComponent.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := False;
end;

function TRMComponent.SetPropValue(aObject: TObject; aPropName: string;
  aValue: Variant): Boolean;
begin
  Result := False;
end;

function TRMComponent.GetComAdapter: IInterface;
begin
  Result := FComAdapter;
end;

procedure TRMComponent.SetComAdapter(const Value: IInterface);
begin
  FComAdapter := Value;
end;

function TRMComponent.GetEventPropVars: TRMVariables;
begin
  if FEventPropVars = nil then
  begin
    FEventPropVars := TRMVariables.Create;
  end;

  Result := FEventPropVars;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

{ TRMCustomEventItems }

constructor TRMCustomEventItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner, TRMEventItem);
end;

function TRMCustomEventItems.GetItem(index: integer): TRMEventItem;
begin
  Result := TRMEventItem(inherited Items[Index]);
end;

{ TRMEventPropVars }

procedure TRMEventPropVars.CheckParentReport;
begin
  if FParentReport = nil then
    raise Exception.Create('ParentReport Can''t be nil!');
end;

constructor TRMEventPropVars.Create(aReport: TComponent);
begin
  inherited Create(aReport);
  FParentReport := aReport;
end;

function TRMEventPropVars.DeleteAllEventByObjName(aComponentName: string): boolean;
var
  i, iCount: Integer;
begin
  Result := false;
  iCount := self.Count;
  if (aComponentName = '') or (iCount <= 0) then
    Exit;
  for i := iCount - 1 downto 0 do
  begin
    if Sametext(TRMEventItem(Items[i]).objectName, aComponentName) then
    begin
      Delete(i);
    end;
  end;
  Result := true;
end;

function TRMEventPropVars.IndexOfEvent(aObjectName,
  aEventPropName: string): integer;
var
  i: integer;
  m: TRMEventItem;
begin
  Result := -1;
  if (Count <= 0) or (aObjectName = '') or (aEventPropName = '') then
    Exit;
  for i := 0 to Count - 1 do
  begin
    m := TRMEventItem(Items[i]);
    if SameText(m.ObjectName, aObjectName) and SameText(m.EventPropName, aEventPropName) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;


function TRMEventPropVars.IndexOfEvent(AInstance: TPersistent;
  aEventPropName: string): integer;
var
  i: integer;
  m: TRMEventItem;
begin
  Result := -1;
  if (Count <= 0) or (AInstance = nil) or (aEventPropName = '') then
    Exit;
  for i := 0 to Count - 1 do
  begin
    m := TRMEventItem(Items[i]);
    if (m.Instance = AInstance) and SameText(m.EventPropName, aEventPropName) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TRMEventPropVars.GetEventPropVar(AInstance: TPersistent;
  APropName: string): string;
var
  lVars: TRMVariables;
  lValue: Variant;
begin
  Result := '';
  if (AInstance = nil) or (APropName = '') then
    Exit;
  if AInstance is TRMPersistent then
    lVars := TRMPersistent(AInstance).EventPropVars
  else
    lVars := nil;

  if lVars <> nil then
  begin
    lValue := lVars[APropName];
    if lValue <> Null then
      Result := lValue
    else
      Result := '';
  end;
end;

function TRMEventPropVars.SetEventPropVar(AInstance: TPersistent;
  APropName, AProcName: string): Integer;
var
  lVars: TRMVariables;
  m: TRMEventItem;
  sObjName: string;
begin
  Result := -1;
  if (AInstance = nil) or (APropName = '') then
    Exit;

  lVars := nil;
  if AInstance is TRMPersistent then
  begin
    lVars := TRMPersistent(AInstance).EventPropVars;
    sObjName := TRMPersistent(AInstance).Name;
  end
  else if AInstance is TComponent then
  begin
    sObjName := TComponent(AInstance).Name;
  end;

  if lVars = nil then Exit;

  Result := IndexOfEvent(AInstance, APropName);

  if AProcName = '' then
  begin
    lVars.DeleteByName(APropName);
    if (Result <> -1) then
      Delete(Result);

    Exit;
  end
  else
  begin
    lVars[APropName] := AProcName;
    if (Result = -1) then
    begin
      m := TRMEventItem(Add());
      m.Instance := AInstance;
      m.ObjectName := sObjName;
      m.EventPropName := APropName;
      m.EventValueName := AProcName;
      Result := Count;
    end
    else
    begin
      m := TRMEventItem(Items[Result]);
      m.EventValueName := AProcName;
    end;
  end;
end;

function TRMEventPropVars.DeleteEventProp(AInstance: TPersistent;
  APropName: string): boolean;
var
  i: Integer;
  lVars: TRMVariables;
begin
  Result := False;
  i := IndexOfEvent(AInstance, APropName);
  if (i = -1) then
    Exit;

  if Items[i].Instance is TRMPersistent then
  begin
    lVars := TRMPersistent(Items[i].Instance).EventPropVars;
  end
  else
    lVars := nil;

  if lVars <> nil then
    lVars.DeleteByName(APropName);

  Delete(i);
  Result := true;
end;

procedure TRMEventPropVars.RenameEventProc(aOldProcName,
  aNewProcName: string);
var
  i: integer;
  lVars: TRMVariables;
begin
  if SameText(aOldProcName, aNewProcName) or (Count < 1) then Exit;
  for i := 0 to Count - 1 do
  begin
    if SameText(aOldProcName, Items[i].EventValueName) then
    begin
      Items[i].EventValueName := aNewProcName;
      if Items[i].Instance is TRMPersistent then
      begin
        lVars := TRMPersistent(Items[i].Instance).EventPropVars;
      end
      else
        lVars := nil;
      if lVars <> nil then
        lVars[Items[i].EventPropName] := aNewProcName;
    end;
  end;
end;

end.

