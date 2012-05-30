
{*****************************************}
{                                         }
{            Report Machine               }
{             Report dataset              }
{
{ 2004/12  PYZFL修改
{  对RMDataSet控件添加了两个属性
{    Visible，如果属性为false，则在设计器中不显示。
{    AliasName，别名，如果设计时写入，则在设计器中将会显示出来                                         }
{*****************************************}

unit RM_Dataset;

interface

{$I RM.INC}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Stdctrls, DB, RM_Common
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDataset = class;

  TRMRangeBegin = (rmrbFirst, rmrbCurrent, rmrbDefault);
  TRMRangeEnd = (rmreLast, rmreCurrent, rmreCount, rmreDefault);
  TRMCheckEOFEvent = procedure(Sender: TObject; var aEOF: Boolean) of object;
  TRMGetIsBlobFieldEvent = procedure(const aFieldName: string; var IsBlobField: Boolean) of object;
  TRMGetFieldIsNullEvent = procedure(const aFieldName: string; var IsBlobField: Boolean) of object;
  TRMUserDatasetOnGetFieldValue = procedure(Dataset: TRMDataset; const FieldName: string; var FieldValue: Variant) of object;
  TRMUserDatasetOnGetFieldDisplayText = procedure(Dataset: TRMDataset; const FieldName: string;
    var FieldValue: WideString) of object;
  TRMUserDatasetOnGetFieldsList = procedure(Dataset: TRMDataset; FieldNames: TStrings) of object;

  { TRMDataset }
  TRMDataset = class(TRMComponent)
  private
    FVisible: Boolean; //(2004-12-8 23:28 PYZFL)
    FAliasName: string; //(2004-12-9 0:00 PYZFL)
    FFieldAlias: TStringList;
    FOnGetFieldValue: TRMUserDatasetOnGetFieldValue;
    FOnGetFieldDisplayText: TRMUserDatasetOnGetFieldDisplayText;
    FOnGetFieldsList: TRMUserDatasetOnGetFieldsList;
    FConvertNulls: Boolean;

    procedure SetFieldAlias(Value: TStringList);
  protected
    FDictionaryKey: string;
    FRangeBegin: TRMRangeBegin;
    FRangeEnd: TRMRangeEnd;
    FRangeEndCount: Integer;
    FOnInit, FOnFirst, FOnNext, FOnLast, FOnPrior: TNotifyEvent;
    FOnCheckEOF: TRMCheckEOFEvent;
    FRecordNo: Integer;
    FOnAfterFirst: TNotifyEvent;
    FOnGetIsBlobField: TRMGetIsBlobFieldEvent;
    FOnGetFieldIsNull: TRMGetFieldIsNullEvent;

    property OnGetFieldDisplayText: TRMUserDatasetOnGetFieldDisplayText read FOnGetFieldDisplayText write FOnGetFieldDisplayText;
    property OnGetFieldValue: TRMUserDatasetOnGetFieldValue read FOnGetFieldValue write FOnGetFieldValue;
    property OnGetFieldsList: TRMUserDatasetOnGetFieldsList read FOnGetFieldsList write FOnGetFieldsList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open; virtual;
    procedure Close; virtual;
    procedure Init; virtual;
    procedure Exit; virtual;
    procedure First; virtual;
    procedure Last; virtual;
    procedure Next; virtual;
    procedure Prior; virtual;
    function Eof: Boolean; virtual;
    function Active: boolean; virtual; abstract;
    // dejoy 2006-07-13 08:49
    function FindField(AFieldName: string): string; virtual;
    function GetRealFieldName(aFieldName: string): string; virtual;

    function GetFieldValue(aFieldName: string): Variant; virtual; abstract;
    function GetFieldDisplayText(aFieldName: string): WideString; virtual; abstract;
    function GetFieldDisplayLabel(aFieldName: string): string; virtual;
    function FieldIsNull(aFieldName: string): Boolean; virtual;
    function FieldWidth(aFieldName: string): Integer; virtual;
    procedure GetFieldsList(aFieldList: TStringList); virtual; abstract;
    function IsBlobField(aFieldName: string): Boolean; virtual;
    procedure AssignBlobFieldTo(aFieldName: string; aDest: TObject); virtual;

    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    function SetPropValue(aObject: TObject; aPropName: string;
      aValue: Variant): Boolean; override;

    property ConvertNulls: Boolean read FConvertNulls write FConvertNulls default true;
    property RecordNo: Integer read FRecordNo;
    property OnCheckEOF: TRMCheckEOFEvent read FOnCheckEOF write FOnCheckEOF;
    property OnInit: TNotifyEvent read FOnInit write FOnInit;
    property OnFirst: TNotifyEvent read FOnFirst write FOnFirst;
    property OnNext: TNotifyEvent read FOnNext write FOnNext;
    property OnPrior: TNotifyEvent read FOnPrior write FOnPrior;
    property OnGetIsBlobField: TRMGetIsBlobFieldEvent read FOnGetIsBlobField write FOnGetIsBlobField;
    property OnGetFieldIsNull: TRMGetFieldIsNullEvent read FOnGetFieldIsNull write FOnGetFieldIsNull;

    // dejoy 2006-07-12 21:57
    property FieldValue[aFieldName: string]: Variant read GetFieldValue {write SetFieldValue}; default;
    property FieldDisplayText[aFieldName: string]: WideString read GetFieldDisplayText ;
    property FieldDisplayLabel[aFieldName: string]: string read GetFieldDisplayLabel ;
  published
    property DictionaryKey: string read FDictionaryKey write FDictionaryKey;
    property RangeBegin: TRMRangeBegin read FRangeBegin write FRangeBegin default rmrbFirst;
    property RangeEnd: TRMRangeEnd read FRangeEnd write FRangeEnd default rmreLast;
    property RangeEndCount: Integer read FRangeEndCount write FRangeEndCount default 0;
    //(2004-12-8 23:28 PYZFL)
    property Visible: Boolean read FVisible write FVisible;
    property AliasName: string read FAliasName write FAliasName;
    property FieldAlias: TStringList read FFieldAlias write SetFieldAlias;
  end;

  { TRMUserDataset }
  TRMUserDataset = class(TRMDataset)
  private
  public
    function GetFieldValue(aFieldName: string): Variant; override;
    function GetFieldDisplayText(aFieldName: string): WideString; override;
    procedure GetFieldsList(aFieldList: TStringList); override;
    function Active: boolean; override;
    procedure AssignBlobFieldTo(aFieldName: string; aDest: TObject); override;
  published
    property OnCheckEOF;
    property OnInit;
    property OnFirst;
    property OnNext;
    property OnPrior;
    property OnGetFieldDisplayText;
    property OnGetFieldValue;
    property OnGetFieldsList;
  end;

  { TRMStringsDataset}
  TRMStringSourceType = (rmssNone, rmssListBox, rmssComboBox, rmssMemo);

  TRMStringsDataset = class(TRMUserDataset)
  private
    FCurIndex: integer;
    FStrings: TStrings;
    FStringsSource: TComponent;
    FStringsSourceType: TRMStringSourceType;

    procedure SetStringsSource(Value: TComponent);
    function GetStrings: TStrings;
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;

    function Active: boolean; override;
    function Eof: boolean; override;
    function GetFieldValue(aFieldName: string): Variant; override;
    function GetFieldDisplayText(aFieldName: string): WideString; override;

    procedure Init; override;
    procedure First; override;
    procedure Last; override;
    procedure Next; override;
    procedure Prior; override;
    procedure GetFieldsList(aFieldList: TStringList); override;

    property Strings: TStrings read GetStrings write FStrings;
  published
    property StringsSource: TComponent read FStringsSource write SetStringsSource;
  end;

  { TRMDBDataSet }
  TRMDBDataSet = class(TRMDataset)
  private
    FDataSet: TDataSet;
    FOpenDataSet, FCloseDataSet: Boolean;
    FOnOpen, FOnClose: TNotifyEvent;
    FBookmark: TBookmark;
    FEof: Boolean;
    procedure SetDataSet(Value: TDataSet);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Active: boolean; override;
    procedure Init; override;
    procedure Exit; override;
    procedure First; override;
    procedure Last; override;
    procedure Next; override;
    procedure Prior; override;
    procedure MoveBy(Distance: Integer);
    procedure Open; override;
    procedure Close; override;
    function Eof: Boolean; override;
    function GetDataSet: TDataSet;
    function FieldWidth( aFieldName: string): Integer; override;
    function FieldIsNull( aFieldName: string): Boolean; override;
    function GetFieldDisplayLabel( aFieldName: string): string; override;
    function GetFieldValue( aFieldName: string): Variant; override;
    function GetFieldDisplayText( aFieldName: string): WideString; override;
    procedure GetFieldsList(aFieldList: TStringList); override;
    function IsBlobField( aFieldName: string): Boolean; override;
    procedure AssignBlobFieldTo( aFieldName: string; aDest: TObject); override;
  published
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property CloseDataSet: Boolean read FCloseDataSet write FCloseDataSet default False;
    property OpenDataSet: Boolean read FOpenDataSet write FOpenDataSet default True;
    property ConvertNulls;

    property OnCheckEOF;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnFirst;
    property OnNext;
    property OnPrior;
    property OnInit;
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
    property OnGetFieldValue;
  end;

function RMIsBlob(aField: TField): Boolean;
procedure RMAssignBlobTo(aBlobField: TField; aObj: TObject);
procedure RMDisableDBControls(aDataSet: TDataSet);
procedure RMEnableDBControls(aDataSet: TDataSet);

function RMStreamToVariant(aStream: TStream): OleVariant;
procedure RMVariantToStream(const aData: OleVariant; aOutStream: TStream);

implementation

type
  EDSError = class(Exception);

  TRMGraphicHeader = record
    Count: Word; // Fixed at 1
    HType: Word; // Fixed at $0100
    Size: Longint; // Size not including header
  end;

function RMStreamToVariant(aStream: TStream): OleVariant;
var
  p: Pointer;
begin
  Result := VarArrayCreate([0, aStream.Size - 1], varByte);
  p := VarArrayLock(Result);
  try
    aStream.Position := 0;
    aStream.Read(p^, aStream.Size);
  finally
    VarArrayUnlock(Result);
  end;
end;

procedure RMVariantToStream(const aData: OleVariant; aOutStream: TStream);
var
  P: Pointer;
begin
  P := VarArrayLock(aData);
  try
    aOutStream.write(P^, VarArrayHighBound(aData, 1) + 1);
    aOutStream.Position := 0;
  finally
    VarArrayUnlock(aData);
  end;
end;

{$IFDEF COMPILER6_UP}

procedure _AssignBlobToPicture(aBlobField: TBlobField; aObj: TPersistent);

  function _SupportsStreamPersist(const aPersistent: TPersistent;
    var aStreamPersist: IStreamPersist): Boolean;
  begin
    Result := (aPersistent is TInterfacedPersistent) and
      (TInterfacedPersistent(aPersistent).QueryInterface(IStreamPersist, aStreamPersist) = S_OK);
  end;

  procedure _SaveToStreamPersist(aStreamPersist: IStreamPersist);
  var
    lBlobStream: TStream;
    lSize: Longint;
    lHeader: TRMGraphicHeader;
  begin
    lBlobStream := aBlobField.DataSet.CreateBlobStream(aBlobField, bmRead);
    try
      lSize := lBlobStream.Size;
      if lSize >= SizeOf(TRMGraphicHeader) then
      begin
        lBlobStream.Read(lHeader, SizeOf(lHeader));
        if (lHeader.Count <> 1) or (lHeader.HType <> $0100) or
          (lHeader.Size <> lSize - SizeOf(lHeader)) then
          lBlobStream.Position := 0;
      end;

      aStreamPersist.LoadFromStream(lBlobStream);
    finally
      lBlobStream.Free;
    end;
  end;

var
  lStreamPersist: IStreamPersist;
begin
  if _SupportsStreamPersist(aObj, lStreamPersist) then
    _SaveToStreamPersist(lStreamPersist);
end;
{$ENDIF}

function RMIsBlob(aField: TField): Boolean;
begin
  Result := (aField <> nil) and (aField.DataType in [ftBlob..ftTypedBinary,
    ftOraBlob, ftOraClob]);
end;

procedure RMAssignBlobTo(aBlobField: TField; aObj: TObject);
begin
  if aObj is TPersistent then
  begin
    try
{$IFDEF COMPILER6_UP}
      if System.IsLibrary then
      begin
        _AssignBlobToPicture(TBlobField(aBlobField), TPersistent(aObj));
      end
      else
{$ENDIF}
        TPersistent(aObj).Assign(aBlobField);
    except
      on e: EConvertError do
      begin
{$IFDEF COMPILER6_UP}
      	if not System.IsLibrary then
        	_AssignBlobToPicture(TBlobField(aBlobField), TPersistent(aObj));
{$ENDIF}
      end;
    end;
  end
  else if aObj is TStream then
  begin
    TBlobField(aBlobField).SaveToStream(TStream(aObj));
    TStream(aObj).Position := 0;
  end;
end;

procedure RMDisableDBControls(aDataSet: TDataSet);
begin
  if aDataSet <> nil then
    aDataSet.DisableControls;
end;

procedure RMEnableDBControls(aDataSet: TDataSet);
begin
  if aDataSet <> nil then
    aDataSet.EnableControls;
end;

type
  IWideStringField = interface
    ['{679C5F1A-4356-4696-A8F3-9C7C6970A9F6}']
    function GetAsWideString: WideString;
    procedure SetAsWideString(const Value: WideString);
    function GetWideDisplayText: WideString;
    function GetWideEditText: WideString;
    procedure SetWideEditText(const Value: WideString);
    //--
    property AsWideString: WideString read GetAsWideString write SetAsWideString {inherited};
    property WideDisplayText: WideString read GetWideDisplayText;
    property WideText: WideString read GetWideEditText write SetWideEditText;
  end;

function _GetAsWideString(aField: TField): WideString;
var
  lWideField: IWideStringField;
begin
  if aField.GetInterface(IWideStringField, lWideField) then
    Result := lWideField.AsWideString
  else if (aField is TWideStringField) then
  begin
    if aField.IsNull then
      Result := ''
    else
      Result := TWideStringField(aField).Value
  end
  else
    Result := aField.AsString;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDataSet }

constructor TRMDataset.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOnAfterFirst := nil;
  RangeBegin := rmrbFirst;
  RangeEnd := rmreLast;
  //(2004-12-8 23:59 PYZFL)
  Visible := True;
  AliasName := '';
  FFieldAlias := TStringList.Create;

  //{2006-07-12 20:58:28  dejoy }
  FConvertNulls := True;
  RMDataSetList.Add(Self);
end;

destructor TRMDataset.Destroy;
begin
  RMDataSetList.Remove(Self);
  FFieldAlias.Free;

  inherited Destroy;
end;

function TRMDataset.IsBlobField(aFieldName: string): Boolean;
var
  lIsBlob: Boolean;
begin
  Result := False;
  aFieldName := GetRealFieldName(aFieldName);
  if Assigned(FOnGetIsBlobField) then
  begin
    lIsBlob := Result;
    FOnGetIsBlobField(aFieldName, lIsBlob);
    Result := lIsBlob;
  end;
end;

function TRMDataSet.FieldIsNull(aFieldName: string): Boolean;
begin
  Result := False;
  aFieldName := GetRealFieldName(aFieldName);
  if Assigned(FOnGetFieldIsNull) then
    FOnGetFieldIsNull(aFieldName, Result);
end;

function TRMDataSet.GetFieldDisplayLabel(aFieldName: string): string;
begin
  Result := '';
end;

function TRMDataSet.FieldWidth(aFieldName: string): Integer;
begin
  Result := 0;
end;

procedure TRMDataSet.AssignBlobFieldTo(aFieldName: string; aDest: TObject);
begin
//
end;

procedure TRMDataset.Open;
begin
 //
end;

procedure TRMDataset.Close;
begin
  //
end;

procedure TRMDataset.Init;
begin
  if Assigned(FOnInit) then FOnInit(Self);
end;

procedure TRMDataset.Exit;
begin
  //
end;

procedure TRMDataset.First;
begin
  FRecordNo := 0;
  if Assigned(FOnFirst) then FOnFirst(Self);
end;

procedure TRMDataset.Last;
begin
  //
end;

procedure TRMDataset.Next;
begin
  Inc(FRecordNo);
  if not ((FRangeEnd = rmreCount) and (FRecordNo >= FRangeEndCount)) then
  begin
    if Assigned(FOnNext) then FOnNext(Self);
  end;
end;

procedure TRMDataSet.Prior;
begin
  Dec(FRecordNo);
  if Assigned(FOnPrior) then FOnPrior(Self);
end;

function TRMDataset.Eof: Boolean;
begin
  Result := False;
  if (FRangeEnd = rmreCount) and (FRecordNo >= FRangeEndCount) then Result := True;
  if Assigned(FOnCheckEOF) then FOnCheckEOF(Self, Result);
end;

function TRMDataSet.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

function TRMDataSet.SetPropValue(aObject: TObject; aPropName: string;
  aValue: Variant): Boolean;
begin
  Result := inherited SetPropValue(aObject, aPropName, aValue);
end;

procedure TRMDataSet.SetFieldAlias(Value: TStringList);
begin
  if (Value <> nil) and (Value <> FFieldAlias) then
    FFieldAlias.Assign(Value);
end;

function TRMDataset.FindField(AFieldName: string): string;
var
  sl : TStringList;
  i: integer;
begin
  Result :='';
  if AFieldName = '' then
    Exit;
    
  for i := 0 to FieldAlias.Count - 1 do
  begin
{$IFDEF COMPILER7_UP}
    if RMCmp(aFieldName, Trim(FieldAlias.ValueFromIndex[i])) then
{$ELSE}
    if RMCmp(aFieldName, Trim(FieldAlias.Values[FieldAlias.Names[i]])) then
{$ENDIF}
    begin
      Result := FieldAlias.Names[i];
      Exit;
    end;
  end;

  sl := TStringList.Create;
  try
    GetFieldsList(sl);
    if sl.IndexOf(aFieldName) >= 0 then
      Result := aFieldName;
  finally
    sl.Free;
  end;

end;

function TRMDataset.GetRealFieldName(aFieldName: string): string;
begin
  Result := FindField(aFieldName);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMUserDataSet }

function TRMUserDataSet.GetFieldValue(aFieldName: string): Variant;
begin
  Result := UnAssigned;
  aFieldName := GetRealFieldName(aFieldName);
  if Assigned(FOnGetFieldValue) then
    FOnGetFieldValue(Self, aFieldName, Result);
end;

function TRMUserDataSet.GetFieldDisplayText(aFieldName: string): WideString;
begin
  Result := '';
  aFieldName := GetRealFieldName(aFieldName);
  if Assigned(FOnGetFieldDisplayText) then
    FOnGetFieldDisplayText(Self, aFieldName, Result);
end;

procedure TRMUserDataSet.GetFieldsList(aFieldList: TStringList);
begin
  if Assigned(FOnGetFieldsList) then
    FOnGetFieldsList(Self, aFieldList);
end;

function TRMUserDataSet.Active: boolean;
begin
  Result := True;
end;

const
  BUFFER_SIZE = 65534;

procedure TRMUserDataSet.AssignBlobFieldTo(aFieldName: string; aDest: TObject);
var
  lValue: Variant;
  lStream: TMemoryStream;
  lHeader: TRMGraphicHeader;
  lCount: Integer;
  lbuffer: array[0..BUFFER_SIZE + 1] of byte;
begin
  if not Assigned(FOnGetFieldValue) then Exit;

  aFieldName := GetRealFieldName(aFieldName);
  FOnGetFieldValue(Self, aFieldName, lValue);
  lStream := TMemoryStream.Create;
  try
    RMVariantToStream(lValue, lStream);

    lCount := lStream.Size;
    if lCount >= SizeOf(TRMGraphicHeader) then
    begin
      lStream.Read(lHeader, SizeOf(lHeader));
      if (lHeader.Count <> 1) or (lHeader.HType <> $0100) or
        (lHeader.Size <> lCount - SizeOf(lHeader)) then
        lStream.Position := 0;
    end
    else
    begin
    end;

    if lStream.Size > 0 then
    begin
      if aDest is TPicture then
      begin
        TPicture(aDest).Graphic.LoadFromStream(lStream);
      end
      else if aDest is TStream then
      begin
        if lStream.Position = 0 then
        begin
          lStream.SaveToStream(TStream(aDest));
        end
        else
        begin
          while true do
          begin
            lCount := lStream.Read(lbuffer, BUFFER_SIZE);
            TStream(aDest).WriteBuffer(lbuffer, lCount);

            if lCount < BUFFER_SIZE then Break;
          end;
        end;

        TStream(aDest).Position := 0;
      end;
    end;
  finally
    lStream.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMStringsDataset }

constructor TRMStringsDataset.Create;
begin
  inherited;
  FStringsSourceType := rmssNone;
end;

procedure TRMStringsDataset.Notification;
begin
  inherited;
  if (AOperation = opRemove) and (AComponent = FStringsSource) then
    FStringsSource := nil;
end;

procedure TRMStringsDataset.SetStringsSource;
begin
  if (Value = nil) or (Value is TComboBox) or (Value is TListBox) or (Value is TMemo) then
  begin
    FStringsSource := Value;
    if FStringsSource is TComboBox then
      FStringsSourceType := rmssComboBox
    else if FStringsSource is TListBox then
      FStringsSourceType := rmssListBox
    else if FStringsSource is TMemo then
      FStringsSourceType := rmssMemo
    else
      FStringsSourceType := rmssNone;
  end;
end;

function TRMStringsDataset.GetStrings;
begin
  Result := nil;
  if FStringsSourceType <> rmssNone then
  begin
    case FStringsSourceType of
      rmssComboBox: Result := TComboBox(FStringsSource).Items;
      rmssListBox: Result := TListBox(FStringsSource).Items;
      rmssMemo: Result := TMemo(FStringsSource).Lines;
    end;
  end
  else
  begin
    if Strings <> nil then
      Result := Strings;
  end;
end;

function TRMStringsDataset.Active;
begin
  Result := True;
end;

function TRMStringsDataset.Eof;
begin
  Result := FCurIndex >= Strings.Count;
end;

function TRMStringsDataset.GetFieldValue(aFieldName: string): Variant;
begin
  aFieldName := GetRealFieldName(aFieldName);
  if AnsiCompareText('NAME', aFieldName) = 0 then
    Result := Strings[FCurIndex]
  else if AnsiCompareText('ID', aFieldName) = 0 then
    Result := integer(Strings.Objects[FCurIndex]);
end;

function TRMStringsDataset.GetFieldDisplayText(aFieldName: string): WideString;
begin
  Result := GetFieldValue(aFieldName);
end;

procedure TRMStringsDataset.Init;
begin
  FRecordNo := 0;
  inherited Init;
end;

procedure TRMStringsDataset.First;
begin
  FRecordNo := 0;
  inherited First;
end;

procedure TRMStringsDataset.Last;
begin
  //
end;

procedure TRMStringsDataset.Next;
begin
  if FRecordNo <= Strings.Count then
    Inc(FRecordNo);
  inherited Next;
end;

procedure TRMStringsDataset.Prior;
begin
  if FRecordNo > 0 then
    Dec(FRecordNo);
  inherited Prior;
end;

procedure TRMStringsDataset.GetFieldsList(aFieldList: TStringList);
begin
  aFieldList.Add('NAME');
  aFieldList.Add('ID');
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDBDataSet }

constructor TRMDBDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOpenDataSet := True;
  FBookMark := nil;
end;

destructor TRMDBDataSet.Destroy;
begin
  inherited Destroy;
end;

function TRMDBDataset.IsBlobField( aFieldName: string): Boolean;
begin
  Result := False;
  aFieldName := GetRealFieldName(aFieldName);
  if FDataSet <> nil then
    Result := RMIsBlob(FDataset.FindField(aFieldName));
end;

procedure TRMDBDataSet.AssignBlobFieldTo( aFieldName: string; aDest: TObject);
begin
  aFieldName := GetRealFieldName(aFieldName);
  RMAssignBlobTo(FDataSet.FindField(aFieldName), aDest);
end;

procedure TRMDBDataSet.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDataSet then
      FDataSet := nil;
  end;
end;

procedure TRMDBDataSet.SetDataSet(Value: TDataSet);
begin
  if FDataSet <> Value then
  begin
    FDataSet := Value;
//    FFieldAlias.Clear;
  end;
end;

function TRMDBDataSet.GetDataSet: TDataSet;
begin
  if FDataSet <> nil then
    Result := FDataSet
  else
  begin
    raise EDSError.Create('Unable to open dataset ' + Name);
    Result := nil;
  end;
end;

function TRMDBDataSet.Active: boolean;
begin
  Result := False;
  if FDataSet <> nil then
    Result := FDataSet.Active;
end;

procedure TRMDBDataSet.Init;
begin
  Open;
  if FBookMark <> nil then
    GetDataSet.FreeBookMark(FBookMark);

  FBookmark := DataSet.GetBookmark;
  //	if CurPage.CanDisableControls then
  //	  RMDisableDBControls(TDataSet(GetDataSet));
  FEof := False;
end;

procedure TRMDBDataSet.Exit;
begin
  try
    if FBookMark <> nil then
    begin
      if (FRangeBegin = rmrbCurrent) or (FRangeEnd = rmreCurrent) then
        GetDataSet.GotoBookmark(FBookMark);
      GetDataSet.FreeBookMark(FBookmark);
    end;
  finally
    FBookMark := nil;
    Close;
  end;
end;

procedure TRMDBDataSet.First;
begin
  if FRangeBegin = rmrbFirst then
  begin
    GetDataSet.First;
  end
  else if FRangeBegin = rmrbCurrent then
    GetDataSet.GotoBookMark(FBookMark);

  FEof := False;
  inherited First;
end;

procedure TRMDBDataSet.Last;
begin
  if FRangeEnd = rmreLast then
    GetDataSet.Last
  else if FRangeEnd = rmreCurrent then
    GetDataSet.GotoBookMark(FBookMark);

  FEof := True;
  inherited Last;
end;

procedure TRMDBDataSet.Next;
var
  liBookMark: TBookmark;
begin
  FEof := False;
  if FRangeEnd = rmreCurrent then
  begin
    liBookMark := GetDataSet.GetBookMark;
    if GetDataSet.CompareBookMarks(liBookMark, FBookMark) = 0 then
      FEof := True;
    GetDataSet.FreeBookMark(liBookMark);
    if not FEof then
    begin
      GetDataSet.Next;
      inherited Next;
    end;
    System.Exit;
  end;
  GetDataSet.Next;
  inherited Next;
end;

procedure TRMDBDataSet.MoveBy(Distance: Integer);
begin
  GetDataSet.MoveBy(Distance);
end;

procedure TRMDBDataSet.Prior;
begin
  GetDataSet.Prior;
  inherited Prior;
end;

function TRMDBDataSet.Eof: Boolean;
begin
  Result := inherited Eof or FEof or GetDataSet.Eof;
end;

procedure TRMDBDataSet.Open;
begin
  if FOpenDataSet then GetDataSet.Open;
  if Assigned(FOnOpen) then FOnOpen(Self);
end;

procedure TRMDBDataSet.Close;
begin
  if Assigned(FOnClose) then FOnClose(Self);
  if FCloseDataSet then GetDataSet.Close;
end;

function TRMDBDataSet.FieldIsNull( aFieldName: string): Boolean;
var
  lField: TField;
begin
  aFieldName := GetRealFieldName(aFieldName);
  lField := FDataSet.FindField(aFieldName);
  Result := (lField <> nil) and lField.IsNull;
end;

function TRMDBDataSet.GetFieldDisplayLabel( aFieldName: string): string;
var
  lField: TField;
begin
  aFieldName := GetRealFieldName(aFieldName);
  Result := '';
  lField := FDataSet.FindField(aFieldName);
  if lField <> nil then
    Result := lField.DisplayLabel;
end;

function TRMDBDataSet.FieldWidth( aFieldName: string): Integer;
var
  lField: TField;
begin
  aFieldName := GetRealFieldName(aFieldName);
  Result := 0;
  lField := FDataSet.FindField(aFieldName);
  if lField <> nil then
    Result := lField.DisplayWidth;
end;

function TRMDBDataSet.GetFieldValue( aFieldName: string): Variant;
var
  lField: TField;
  lWideField: IWideStringField;
begin
//	if not FDataSet.Active then FDataSet.Open;

  aFieldName := GetRealFieldName(aFieldName);
  lField := FDataSet.FindField(aFieldName);
  if lField = nil then Exit;

  if Assigned(lField.OnGetText) then
    Result := lField.DisplayText
  else
  begin
    if lField.DataType in [ftLargeint] then
      Result := lField.DisplayText
    else
    begin
      if lField.GetInterface(IWideStringField, lWideField) then
        Result := lWideField.AsWideString
      else if lField is TWideStringField then
      begin
        if not lField.IsNull then
          Result := TWideStringField(lField).Value;
      end
      else
        Result := lField.AsVariant;
    end;
  end;

  if (Result = Null) and ConvertNulls {(not RMUseNull)} then
  begin
    if lField.DataType in [ftString, ftWideString] then
      Result := ''
    else if lField.DataType = ftBoolean then
      Result := False
    else
      Result := 0;
  end;
end;

function TRMDBDataSet.GetFieldDisplayText( aFieldName: string): WideString;
var
  lField: TField;
  lWideField: IWideStringField;
begin
	if not FDataSet.Active then FDataSet.Open;

  aFieldName := GetRealFieldName(aFieldName);
  lField := FDataSet.FindField(aFieldName);
  if lField <> nil then
  begin
	  if lField.GetInterface(IWideStringField, lWideField) then
  	  Result := lWideField.WideDisplayText
	  else if (lField is TWideStringField) and (not Assigned(lField.OnGetText)) then
  	  Result := _GetAsWideString(lField)
	  else
  	  Result := lField.DisplayText;
  end;
end;
{$HINTS OFF}

procedure TRMDBDataSet.GetFieldsList(aFieldList: TStringList);
var
  i: Integer;
  lField: TField;

  procedure _GetFields;
  var
  	i: Integer;
  begin
    aFieldList.Clear;
    if FDataSet.FieldList.Count > 0 then
    begin
      for i := 0 to FDataSet.FieldList.Count - 1 do
        aFieldList.Add(FDataSet.FieldList[i].FieldName);
    end
    else
    begin
      FDataSet.FieldDefs.Update;
      for i := 0 to FDataSet.FieldDefList.Count - 1 do
        aFieldList.Add(FDataSet.FieldDefList[i].Name);
    end;
  end;

begin
  aFieldList.Clear;
  if FDataSet <> nil then
  begin
    try
      if System.IsLibrary then
      	_GetFields
	    else
      FDataSet.GetFieldNames(aFieldList);
    except
      on e: EConvertError do
      begin
      	if not System.IsLibrary then
	        _GetFields;
      end;
    end; {Try}
  end;
end;
{$HINTS ON}

end.

