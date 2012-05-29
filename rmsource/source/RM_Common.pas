unit RM_Common;

interface

{$I RM.INC}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, ExtCtrls, TypInfo
  ,RM_System
{$IFDEF TntUnicode}, TntClasses{$ENDIF}
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvInterpreter, rm_JvInterpreterParser, rm_JclWideStrings
{$ELSE}
  , JvInterpreter, JvInterpreterParser,JclWideStrings
{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  RMPenStyles: array[psSolid..psInsideFrame] of DWORD =
  (PS_SOLID, PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT, PS_NULL, PS_INSIDEFRAME);

type
{    <Table>
    Value               Meaning
    ---------------------------
    rmutInches            Display in inches.
    rmutMillimeters       Display in millimeters.
    rmutScreenPixels      Display in screen pixels.
    rmutPrinterPixels     Display in printer pixels.
    rmutMMThousandths     Display in thousandths of millimeters.
    </Table>}
  TRMResolutionType = (rmrtHorizontal, rmrtVertical);
  TRMUnitType = (rmutScreenPixels, rmutInches, rmutMillimeters, rmutMMThousandths);
  TRMPrinterOrientation = (rmpoPortrait, rmpoLandscape);
  TRMPreviewZoom = (pzDefault, pzPageWidth, pzOnePage, pzTwoPages);
  TRMPreviewButton = (pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbPageSetup, pbExit, pbDesign,
    pbSaveToXLS, pbExport, pbNavigator);
  TRMPreviewButtons = set of TRMPreviewButton;
  TRMScaleMode = (mdNone, mdPageWidth, mdOnePage, mdTwoPages, mdPrinterZoom);
  TRMExportMode = (rmemText, rmemRtf, rmemPicture);

  TRMValueType = (rmvaList, rmvaInt8, rmvaInt16, rmvaInt32, rmvaExtended,
    rmvaString, rmvaIdent, rmvaFalse, rmvaTrue, rmvaBinary, rmvaSet, rmvaLString,
    rmvaNil, rmvaSingle, rmvaCurrency, rmvaDate, rmvaWideString,
    rmvaInt64, rmvaUTF8String);
  TRMDataType = (rmdtBoolean, rmdtDate, rmdtTime, rmdtDateTime, rmdtInteger, rmdtSingle,
    rmdtDouble, rmdtExtended, rmdtCurrency, rmdtChar, rmdtString, rmdtVariant,
    rmdtLongint, rmdtBLOB, rmdtMemo, rmdtGraphic, rmdtNotKnown, rmdtLargeInt);
  TRMSearchOperatorType = (rmsoEqual, rmsoNotEqual,
    rmsoLessThan, rmsoLessThanOrEqualTo,
    rmsoGreaterThan, rmsoGreaterThanOrEqualTo,
    rmsoLike, rmsoNotLike,
    rmsoBetween, soNotBetween,
    rmsoInList, rmsoNotInList,
    rmsoBlank, rmsoNotBlank);

  TRMPageInfo = record // print info about page size, margins e.t.c
    PrinterPageWidth, PrinterPageHeight: Integer; // page width/height (printer)
    ScreenPageWidth, ScreenPageHeight: Integer; // page width/height (screen)
    PrinterOffsetX, PrinterOffsetY: Integer; // offset x/y
  end;

  TRMReportInfo = packed record
    Title: string;
    Author: string;
    Company: string;
    CopyRight: string;
    Comment: string;
  end;

  TRMClass = class of TRMCustomView;
  TRMCustomReport = class;

  TRMPreviewSaveReportEvent = procedure(aReport: TObject) of object;


  TRMVariableItem =RM_System.TRMVariableItem;
  TRMVariables  =RM_System.TRMVariables;

  TRMEventPropVars  =RM_System.TRMEventPropVars;
  TRMPersistentCompAdapter = RM_System.TRMPersistentCompAdapter;
  TRMPersistent = RM_System.TRMPersistent;
  TRMComponent = RM_System.TRMComponent;

  TRMPersistentCompAdapterClass = class of TRMPersistentCompAdapter;

 { TRMVariables }

 { TRMCustomView }
  TRMCustomView = class(TRMPersistent)
  public
    class function CanPlaceOnGridView: Boolean; virtual;
    class procedure DefaultSize(var aKx, aKy: Integer); virtual;
  end;

  { TRMPreviewOptions }
  TRMPreviewOptions = class(TPersistent)
  private
    FRulerUnit: TRMUnitType;
    FRulerVisible: Boolean;
    FDrawBorder: Boolean;
    FBorderPen: TPen;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property RulerUnit: TRMUnitType read FRulerUnit write FRulerUnit;
    property RulerVisible: Boolean read FRulerVisible write FRulerVisible;
    property DrawBorder: Boolean read FDrawBorder write FDrawBorder;
    property BorderPen: TPen read FBorderPen write FBorderPen;
  end;

  { TRMCustomPreview}
  TRMCustomPreview = class(TPanel)
  private
    FOptions: TRMPreviewOptions;

    procedure SetOptions(Value: TRMPreviewOptions);
  protected
    NeedRepaint: Boolean;
    procedure InternalOnProgress(aReport: TRMCustomReport; aPercent: Integer); virtual; abstract;
    procedure BeginPrepareReport(aReport: TRMCustomReport); virtual; abstract;
    procedure EndPrepareReport(aReport: TRMCustomReport); virtual; abstract;
    procedure CloseForm; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowReport(aReport: TRMCustomReport); virtual; abstract;
    procedure Connect(aReport: TRMCustomReport); virtual; abstract;
    procedure Print; virtual; abstract;
  published
    property Options: TRMPreviewOptions read FOptions write SetOptions;
  end;

  { TRMBandMsg }
  TRMBandMsg = class(TPersistent)
  private
    FFont: TFont;
    FLeftMemo, FCenterMemo, FRightMemo: TStringList;
    procedure SetFont(Value: TFont);
    procedure SetLeftMemo(Value: TStringList);
    procedure SetCenterMemo(Value: TStringList);
    procedure SetRightMemo(Value: TStringList);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Font: TFont read FFont write SetFont;
    property LeftMemo: TStringList read FLeftMemo write SetLeftMemo;
    property CenterMemo: TStringList read FCenterMemo write SetCenterMemo;
    property RightMemo: TStringList read FRightMemo write SetRightMemo;
  end;

  { TRMPageCaptionMsg }
  TRMPageCaptionMsg = class(TPersistent)
  private
    FTitleFont: TFont;
    FCaptionMsg: TRMBandMsg;
    FTitleMemo: TStringList;

    procedure SetTitleFont(Value: TFont);
    procedure SetTitleMemo(Value: TStringList);
    procedure SetCaptionMsg(Value: TRMBandMsg);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CaptionMsg: TRMBandMsg read FCaptionMsg write SetCaptionMsg;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property TitleMemo: TStringList read FTitleMemo write SetTitleMemo;
  end;

 { TRMCustomReport }
  TRMCustomReport = class(TRMComponent)
  private
    FTerminated: Boolean;
    FConvertNulls: Boolean;
  protected
  public
    property Terminated: Boolean read FTerminated write FTerminated;
    property ConvertNulls: Boolean read FConvertNulls write FConvertNulls;
  end;

  TRMCustomExportFilter = class(TComponent)
  end;

  PRMFunctionDesc = ^TRMFunctionDesc;
  TRMFunctionDesc = packed record
    FuncName: string;
    Category: string;
    Description: string;
    FuncPara: string;
  end;

  { TRMCustomParser }
  TRMCustomParser = class(TRMPersistent)
  private
  protected
    FParentReport: TComponent;
  public
    function Str2OPZ(aStr: WideString): WideString; virtual; abstract;
    function Calc(aStr: Variant): Variant; virtual; abstract;
    function GetIdentify(const aStr: WideString; var i: Integer): WideString; virtual; abstract;
    procedure GetParameters(const aStr: WideString; var aIndex: Integer; var aParams: array of Variant); virtual; abstract;

    property ParentReport: TComponent read FParentReport write FParentReport;
  end;

  { TRMFunctionLibrary }
  TRMCustomFunctionLibrary = class(TObject)
  private
    FFunctionList: TList;
    FList: TStringList;
    procedure Clear;
  protected
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function OnFunction(aParser: TRMCustomParser; const aFunctionName: string;
      aParams: array of Variant; var aValue: Variant): Boolean; virtual;
    procedure DoFunction(aParser: TRMCustomParser; aFuncNo: Integer; aParams: array of Variant;
      var aValue: Variant); virtual;
    procedure AddFunctionDesc(const aFuncName, aCategory, aDescription, aFuncPara: string);

    property FunctionList: TList read FFunctionList;
    property List: TStringList read FList;
  end;

 { TRMAddInObjectInfo }
  TRMAddInObjectInfo = class(TObject)
  private
    FIsPage: Boolean;
    FPage: string;
    FClassRef: TRMClass;
    FEditorFormClass: TFormClass;
    FButtonBmpRes: string;
    FButtonHint: string;
    FIsControl: Boolean;
  public
    constructor Create(AClassRef: TClass; AEditorFormClass: TFormClass;
      const AButtonBmpRes: string; const AButtonHint: string; AIsControl: Boolean);
    property ClassRef: TRMClass read FClassRef write FClassRef;
    property EditorFormClass: TFormClass read FEditorFormClass write FEditorFormClass;
    property ButtonBmpRes: string read FButtonBmpRes write FButtonBmpRes;
    property ButtonHint: string read FButtonHint write FButtonHint;
    property IsControl: Boolean read FIsControl write FIsControl;
    property Page: string read FPage write FPage;
    property IsPage: Boolean read FIsPage write FIsPage;
  end;

  { TRMExportFilterInfo }
  TRMExportFilterInfo = class(TObject)
  private
    FFilter: TRMCustomExportFilter;
    FFilterDesc: string;
    FFilterExt: string;
  public
    constructor Create(AClassRef: TRMCustomExportFilter; const AFilterDesc: string; const AFilterExt: string);
    property Filter: TRMCustomExportFilter read FFilter write FFilter;
    property FilterDesc: string read FFilterDesc write FFilterDesc;
    property FilterExt: string read FFilterExt write FFilterExt;
  end;

  { TRMPageEditorInfo }
  TRMPageEditorInfo = class(TObject)
  private
    FPageClass: TClass;
    FPageEditorClass: TClass;
  public
    constructor Create(aPageClass: TClass; aPageEditorClass: TClass);
    property PageClass: TClass read FPageClass;
    property PageEditorClass: TClass read FPageEditorClass;
  end;

  { TRMToolsInfo }
  TRMToolsInfo = class(TObject)
  private
    FCaption: string;
    FButtonBmpRes: string;
    FOnClick: TNotifyEvent;
    FIsReportPage: Boolean;
    FPageClassName: string;
  public
    constructor Create(const ACaption: string; const AButtonBmpRes: string; AOnClick: TNotifyEvent);
    property Caption: string read FCaption write FCaption;
    property ButtonBmpRes: string read FButtonBmpRes write FButtonBmpRes;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property IsReportPage: Boolean read FIsReportPage;
    property PageClassName: string read FPageClassName;
  end;

  { TRMTempFileStream }
  TRMTempFileStream = class(TFileStream)
  private
    FFileName: string;
  public
    constructor Create;
    destructor Destroy; override;
    property FileName: string read FFileName;
  end;

function RMHavePropertyName(aObject: TObject; const aPropName: string): Boolean;
function RMGetPropValue_1(aObject: TObject; aPropName: string; var aValue: Variant): Boolean;
function RMSetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean;

procedure RMResigerReportPageClass(ClassRef: TClass);
procedure RMRegisterObjectByRes(ClassRef: TClass; const ButtonBmpRes: string;
  const ButtonHint: string; EditorFormClass: TFormClass);
procedure RMRegisterControl(ClassRef: TClass; const ButtonBmpRes, ButtonHint: string); overload;
procedure RMRegisterControl(const aPage, aPageButtonBmpRes: string; aIsControl: Boolean;
  aClassRef: TClass; aButtonBmpRes, aButtonHint: string); overload;
procedure RMRegisterControls(const aPage, aPageButtonBmpRes: string; aIsControl: Boolean;
  AryClassRef: array of TClass; AryButtonBmpRes: array of string; AryButtonHint: array of string);

procedure RMRegisterComAdapter(aClassRef: TClass; aComAdapterClass: TRMPersistentCompAdapterClass);

procedure RMRegisterPageEditor(aClassRef, aPageEditorClass: TClass);
procedure RMRegisterExportFilter(Filter: TRMCustomExportFilter; const FilterDesc, FilterExt: string);
procedure RMUnRegisterExportFilter(Filter: TRMCustomExportFilter);
procedure RMRegisterTool(const MenuCaption: string; const ButtonBmpRes: string; OnClick: TNotifyEvent);
procedure RMUnRegisterTool(const MenuCaption: string);
procedure RMRegisterFunctionLibrary(ClassRef: TClass);
procedure RMUnRegisterFunctionLibrary(ClassRef: TClass);
procedure RMRegisterPageButton(const Hint: string; const ButtonBmpRes: string;
  aIsReportPage: Boolean; aPageClass: string);

function RMPageEditor(Index: Integer): TRMPageEditorInfo;
function RMPageEditorCount: Integer;
function RMAddIns(index: Integer): TRMAddInObjectInfo;
function RMAddInsCount: Integer;
function RMAddInReportPage(Index: Integer): TRMAddInObjectInfo;
function RMAddInReportPageCount: Integer;
function RMFilters(index: Integer): TRMExportFilterInfo;
function RMFiltersCount: Integer;
function RMDsgPageButton(Index: Integer): TRMToolsInfo;
function RMDsgPageButtonCount: Integer;
function RMTools(index: Integer): TRMToolsInfo;
function RMToolsCount: Integer;
function RMAddInFunctions(Index: Integer): TRMCustomFunctionLibrary;
function RMAddInFunctionCount: Integer;
function RMDataSetList: TList;
function RMComAdapterList: TList;

function RMGetBrackedVariable(const aStr: WideString; var aBeginPos, aEndPos: Integer): WideString;
function RMAnsiGetBrackedVariable(const aStr: string; var aBeginPos, aEndPos: Integer): string;
function RMCmp(const S1, S2: string): Boolean;
function RMCreateAdapter(aClassType: TClass; aParent: TObject): TRMPersistentCompAdapter;

var
  RMRegRootKey: string;

{$IFDEF TntUnicode}
type
  TWideStringList = TTntStringList;
  TWideStrings = TTntStrings;
{$ELSE}
type
  TWideStrings = TWStrings;
  TWideStringList = TWStringList;
{$ENDIF}

type
 { TRMFunctionSplitter }
  TRMFunctionSplitter = class(TObject)
  protected
    FMatchFuncs, FSplitTo: TWideStringList;
    FParser: TRMCustomParser;
    FVariables: TRMVariables;
  public
    constructor Create(aMatchFuncs, aSplitTo: TWideStringList; aVariables: TRMVariables);
    destructor Destroy; override;
    procedure Split(aStr: WideString);
  end;

implementation

uses
  Consts, Math, RM_Const, RM_Const1, RM_Utils, RM_Parser
{$IFDEF COMPILER6_UP}
  , RtlConsts
{$ENDIF};

var
  FDataSetList: TList = nil;

function RMCreateAdapter(aClassType: TClass; aParent: TObject): TRMPersistentCompAdapter;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to RMComAdapterList.Count - 1 do
  begin
    if TRMPageEditorInfo(RMComAdapterList[i]).PageClass = aClassType then
    begin
      Result := TRMPersistentCompAdapterClass(TRMPageEditorInfo(RMComAdapterList[i]).PageEditorClass).CreateComp(aParent);
      Break;
    end;
  end;
end;

function RMAnsiGetBrackedVariable(const aStr: string;
  var aBeginPos, aEndPos: Integer): string;
var
  c: Integer;
  lFlag1, lFlag2: Boolean;
  lStrLen: Integer;
begin
  Result := '';
  aEndPos := aBeginPos; lFlag1 := True; lFlag2 := True; c := 0;
  lStrLen := Length(aStr);
  if (aStr = '') or (aBeginPos >= lStrLen) then Exit;

  Dec(aEndPos);
  repeat
    Inc(aEndPos);
    if lFlag1 and lFlag2 then
    begin
      if aStr[aEndPos] = '[' then
      begin
        if c = 0 then
          aBeginPos := aEndPos;

        Inc(c);
      end
      else if aStr[aEndPos] = ']' then
        Dec(c);
    end;

    if lFlag1 then
    begin
      if aStr[aEndPos] = '"' then
        lFlag2 := not lFlag2;
    end;

    if lFlag2 then
    begin
      if aStr[aEndPos] = '''' then
        lFlag1 := not lFlag1;
    end;
  until (c = 0) or (aEndPos >= lStrLen);

  Result := Copy(aStr, aBeginPos + 1, aEndPos - aBeginPos - 1);
end;

function RMGetBrackedVariable(const aStr: WideString;
  var aBeginPos, aEndPos: Integer): WideString;
var
  c: Integer;
  lFlag1, lFlag2: Boolean;
  lStrLen: Integer;
begin
  Result := '';
  aEndPos := aBeginPos; lFlag1 := True; lFlag2 := True; c := 0;
  lStrLen := Length(aStr);
  if (aStr = '') or (aBeginPos >= lStrLen) then Exit;

  Dec(aEndPos);
  repeat
    Inc(aEndPos);
    if lFlag1 and lFlag2 then
    begin
      if aStr[aEndPos] = '[' then
      begin
        if c = 0 then
          aBeginPos := aEndPos;

        Inc(c);
      end
      else if aStr[aEndPos] = ']' then
        Dec(c);
    end;

    if lFlag1 then
    begin
      if aStr[aEndPos] = '"' then
        lFlag2 := not lFlag2;
    end;

    if lFlag2 then
    begin
      if aStr[aEndPos] = '''' then
        lFlag1 := not lFlag1;
    end;
  until (c = 0) or (aEndPos >= lStrLen);

  if c = 0 then
    Result := Copy(aStr, aBeginPos + 1, aEndPos - aBeginPos - 1)
  else
    Result := '';
end;

function RMCmp(const S1, S2: string): Boolean;
begin
  Result := (Length(S1) = Length(S2)) and
    (CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    -1, PChar(S2), -1) = 2);
end;


function RMDataSetList: TList;
begin
  if FDataSetList = nil then
    FDataSetList := TList.Create;

  Result := FDataSetList;
end;

function RMGetPropValue_1(aObject: TObject; aPropName: string; var aValue: Variant): Boolean;
var
  lPropInfo: PPropInfo;
begin
  lPropInfo := TypInfo.GetPropInfo(aObject.ClassInfo, aPropName);
  if lPropInfo = nil then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  case lPropInfo.PropType^^.Kind of
    tkInteger, tkChar, tkWChar, tkClass:
      aValue := TypInfo.GetOrdProp(aObject, lPropInfo);
    tkEnumeration:
      aValue := TypInfo.GetOrdProp(aObject, lPropInfo);
    tkSet:
      aValue := TypInfo.GetOrdProp(aObject, lPropInfo);
    tkFloat:
      aValue := TypInfo.GetFloatProp(aObject, lPropInfo);
    tkMethod:
      aValue := lPropInfo^.PropType^.Name;
    tkString, tkLString:
      aValue := TypInfo.GetStrProp(aObject, lPropInfo);
    tkWString:
{$IFDEF COMPILER6_UP}
      aValue := TypInfo.GetWideStrProp(aObject, lPropInfo);
{$ELSE}
      aValue := TypInfo.GetStrProp(aObject, lPropInfo);
{$ENDIF}
    tkVariant:
      aValue := TypInfo.GetVariantProp(aObject, lPropInfo);
    tkInt64:
{$IFDEF COMPILER6_UP}
      aValue := TypInfo.GetInt64Prop(aObject, lPropInfo);
{$ELSE}
      aValue := TypInfo.GetInt64Prop(aObject, lPropInfo) + 0.0;
{$ENDIF}
    tkDynArray:
      DynArrayToVariant(aValue, Pointer(GetOrdProp(aObject, lPropInfo)), lPropInfo^.PropType^);
  else
    Result := False;
  end;
end;

function RMSetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean;

  function _RangedValue(const AMin, AMax: Int64): Int64;
  begin
    Result := Trunc(aValue);
    if (Result < AMin) or (Result > AMax) then
    begin
      //raise ERangeError.CreateRes(@SRangeError);
    end;
  end;

var
  lPropInfo: PPropInfo;
  lTypeData: PTypeData;
  lDynArray: Pointer;
begin
  Result := False;
  lPropInfo := GetPropInfo(aObject, aPropName);
  if lPropInfo = nil then Exit;

  Result := True;
  lTypeData := GetTypeData(lPropInfo^.PropType^);
  case lPropInfo.PropType^^.Kind of
    tkInteger, tkChar, tkWChar:
      if lTypeData^.MinValue < lTypeData^.MaxValue then
        TypInfo.SetOrdProp(aObject, lPropInfo, _RangedValue(lTypeData^.MinValue,
          lTypeData^.MaxValue))
      else
        TypInfo.SetOrdProp(aObject, lPropInfo,
          _RangedValue(LongWord(lTypeData^.MinValue),
          LongWord(lTypeData^.MaxValue)));
    tkEnumeration:
      if VarType(aValue) = varString then
        TypInfo.SetEnumProp(aObject, lPropInfo, VarToStr(aValue))
      else if VarType(aValue) = varBoolean then
        TypInfo.SetOrdProp(aObject, lPropInfo, Abs(Trunc(aValue)))
      else
        TypInfo.SetOrdProp(aObject, lPropInfo, _RangedValue(lTypeData^.MinValue,
          lTypeData^.MaxValue));
    tkSet:
      if VarType(aValue) = varInteger then
        TypInfo.SetOrdProp(aObject, lPropInfo, aValue)
      else
        TypInfo.SetSetProp(aObject, lPropInfo, VarToStr(aValue));
    tkFloat:
      TypInfo.SetFloatProp(aObject, lPropInfo, aValue);
    tkString, tkLString:
      TypInfo.SetStrProp(aObject, lPropInfo, VarToStr(aValue));
    tkWString:
{$IFDEF COMPILER6_UP}
      TypInfo.SetWideStrProp(aObject, lPropInfo, VarToWideStr(aValue));
{$ELSE}
      TypInfo.SetStrProp(aObject, lPropInfo, VarToStr(aValue));
{$ENDIF}
    tkVariant:
      TypInfo.SetVariantProp(aObject, lPropInfo, aValue);
    tkInt64:
      TypInfo.SetInt64Prop(aObject, lPropInfo, _RangedValue(lTypeData^.MinInt64Value,
        lTypeData^.MaxInt64Value));
    tkDynArray:
      begin
        DynArrayFromVariant(lDynArray, aValue, lPropInfo^.PropType^);
        TypInfo.SetOrdProp(aObject, lPropInfo, Integer(lDynArray));
      end;
  else
    Result := False;
  end;
end;

function RMHavePropertyName(aObject: TObject; const aPropName: string): Boolean;
var
  lPropInfo: PPropInfo;
begin
  lPropInfo := TypInfo.GetPropInfo(aObject.ClassInfo, aPropName);
  Result := lPropInfo <> nil;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
  {TRMVariables}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomView }

class function TRMCustomView.CanPlaceOnGridView: Boolean;
begin
  Result := True;
end;

class procedure TRMCustomView.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 96;
  aKy := 18;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPreviewOptions }

constructor TRMPreviewOptions.Create;
begin
  inherited;

  FRulerUnit := rmutScreenPixels;
  FRulerVisible := False;

  FDrawBorder := False;
  FBorderPen := TPen.Create;
  FBorderPen.Color := clGray;
  FBorderPen.Style := psDash;
  FBorderPen.Width := 1;
end;

destructor TRMPreviewOptions.Destroy;
begin
  FreeAndNil(FBorderPen);

  inherited;
end;

procedure TRMPreviewOptions.Assign(Source: TPersistent);
begin
  FRulerUnit := TRMPreviewOptions(Source).RulerUnit;
  FRulerVisible := TRMPreviewOptions(Source).RulerVisible;

  FDrawBorder := TRMPreviewOptions(Source).DrawBorder;
  FBorderPen.Assign(TRMPreviewOptions(Source).BorderPen);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomPreview }

constructor TRMCustomPreview.Create(AOwner: TComponent);
begin
  inherited;

  FOptions := TRMPreviewOptions.Create;
end;

destructor TRMCustomPreview.Destroy;
begin
  FreeAndNil(FOptions);

  inherited Destroy;
end;

procedure TRMCustomPreview.SetOptions(Value: TRMPreviewOptions);
begin
  FOptions.Assign(Value);
end;

procedure TRMCustomPreview.CloseForm;
begin
//
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBandMsg }

constructor TRMBandMsg.Create;
begin
  inherited;

  FFont := TFont.Create;
  if RMIsChineseGB then
    FFont.Name := '宋体'
  else
    FFont.Name := 'Arial';
  FFont.Size := 10;
  FFont.Charset := StrToInt(RMLoadStr(SCharset)); //RMCharset;

  FLeftMemo := TStringList.Create;
  FCenterMemo := TStringList.Create;
  FRightMemo := TStringList.Create;
end;

destructor TRMBandMsg.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(FLeftMemo);
  FreeAndNil(FCenterMemo);
  FreeAndNil(FRightMemo);

  inherited;
end;

procedure TRMBandMsg.Assign(Source: TPersistent);
begin
  if Source is TRMBandMsg then
  begin
    FFont.Assign(TRMBandMsg(Source).Font);
    FLeftMemo.Assign(TRMBandMSg(Source).LeftMemo);
    FCenterMemo.Assign(TRMBandMSg(Source).CenterMemo);
    FRightMemo.Assign(TRMBandMSg(Source).RightMemo);
  end;
end;

procedure TRMBandMsg.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TRMBandMsg.SetLeftMemo(Value: TStringList);
begin
  FLeftMemo.Assign(Value);
end;

procedure TRMBandMsg.SetCenterMemo(Value: TStringList);
begin
  FCenterMemo.Assign(Value);
end;

procedure TRMBandMsg.SetRightMemo(Value: TStringList);
begin
  FRightMemo.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPageCaptionMsg }

constructor TRMPageCaptionMsg.Create;
begin
  inherited;

  FTitleFont := TFont.Create;
  FTitleMemo := TStringList.Create;
  FCaptionMsg := TRMBandMsg.Create;

  if RMIsChineseGB then
    FTitleFont.Name := '宋体'
  else
    FTitleFont.Name := 'Arial';
  FTitleFont.Size := 10;
  FTitleFont.Charset := StrToInt(RMLoadStr(SCharset)); //RMCharset;
end;

destructor TRMPageCaptionMsg.Destroy;
begin
  FreeAndNil(FTitleFont);
  FreeAndNil(FTitleMemo);
  FreeAndNil(FCaptionMsg);

  inherited;
end;

procedure TRMPageCaptionMsg.Assign(Source: TPersistent);
begin
  if Source is TRMPageCaptionMsg then
  begin
    TitleFont := TRMPageCaptionMsg(Source).TitleFont;
    TitleMemo := TRMPageCaptionMsg(Source).TitleMemo;
    CaptionMsg := TRMPageCaptionMsg(Source).CaptionMsg;
  end;
end;

procedure TRMPageCaptionMsg.SetTitleFont(Value: TFont);
begin
  FTitleFont.Assign(Value);
end;

procedure TRMPageCaptionMsg.SetTitleMemo(Value: TStringList);
begin
  FTitleMemo.Assign(Value);
end;

procedure TRMPageCaptionMsg.SetCaptionMsg(Value: TRMBandMsg);
begin
  FCaptionMsg.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMTempFileStream }

const
  sDefPrefix = 'dfs';

function GetTempFile(const prefix: string): string;
var
  path, pref3: string;
  ppref: PChar;
begin
  SetLength(path, 1024);
  SetLength(path, GetTempPath(1024, @path[1]));
  SetLength(Result, 1024);
  Result[1] := #0;
  case length(prefix) of
    0: ppref := PChar(sDefPrefix);
    1, 2:
      begin
        pref3 := prefix;
        while length(pref3) < 3 do
          pref3 := pref3 + '_';

        ppref := PChar(pref3);
      end;
    3: ppref := PChar(prefix);
  else
    pref3 := Copy(prefix, 1, 3);
    ppref := PChar(pref3);
  end;

  GetTempFileName(PChar(path), ppref, 0, PChar(Result));
  SetLength(Result, StrLen(PChar(Result)));
end;

constructor TRMTempFileStream.Create;
begin
  FFileName := GetTempFile(''); // Windows.GetTempFileName creates the file...
  inherited Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
end;

destructor TRMTempFileStream.Destroy;
begin
  DeleteFile(PChar(FFileName));
  inherited;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
var
  FRMAddInObjectList: TList = nil;
  FRMExportFilterList: TList = nil;
  FRMToolsList: TList = nil;
  FRMFunctionList: TList = nil;
  FRMPageEditorList: TList = nil;
  FRMDsgPageButtonList: TList = nil;
  FRMAddInReportPageList: TList = nil;
  FComAdapterList: TList = nil;

function RMComAdapterList: TList;
begin
  if FComAdapterList = nil then
    FComAdapterList := TList.Create;

  Result := FComAdapterList;
end;

function RMPageEditorList: TList;
begin
  if FRMPageEditorList = nil then
    FRMPageEditorList := TList.Create;

  Result := FRMPageEditorList;
end;

function RMAddInObjectList: TList;
begin
  if FRMAddInObjectList = nil then
    FRMAddInObjectList := TList.Create;
  Result := FRMAddInObjectList;
end;

function RMExportFilterList: TList;
begin
  if FRMExportFilterList = nil then
    FRMExportFilterList := TList.Create;
  Result := FRMExportFilterList;
end;

function RMToolsList: TList;
begin
  if FRMToolsList = nil then
    FRMToolsList := TList.Create;
  Result := FRMToolsList;
end;

function RMAddIns(index: Integer): TRMAddInObjectInfo;
begin
  Result := TRMAddInObjectInfo(FRMAddInObjectList[index]);
end;

function RMAddInsCount: Integer;
begin
  if FRMAddInObjectList = nil then
    Result := -1
  else
    Result := FRMAddinObjectList.Count;
end;

function RMAddInReportPage(Index: Integer): TRMAddInObjectInfo;
begin
  Result := TRMAddInObjectInfo(FRMAddInReportPageList[index]);
end;

function RMAddInReportPageCount: Integer;
begin
  if FRMAddInReportPageList = nil then
    Result := -1
  else
    Result := FRMAddInReportPageList.Count;
end;

function RMPageEditor(Index: Integer): TRMPageEditorInfo;
begin
  Result := TRMPageEditorInfo(FRMPageEditorList[Index]);
end;

function RMPageEditorCount: Integer;
begin
  if FRMPageEditorList = nil then
    Result := 0
  else
    Result := FRMPageEditorList.Count;
end;

function RMDsgPageButton(Index: Integer): TRMToolsInfo;
begin
  Result := TRMToolsInfo(FRMDsgPageButtonList[Index]);
end;

function RMDsgPageButtonCount: Integer;
begin
  if FRMDsgPageButtonList = nil then
    Result := 0
  else
    Result := FRMDsgPageButtonList.Count;
end;

function RMFilters(index: Integer): TRMExportFilterInfo;
begin
  Result := TRMExportFilterInfo(FRMExportFilterList[index]);
end;

function RMFiltersCount: Integer;
begin
  if FRMExportFilterList = nil then
    Result := -1
  else
    Result := FRMExportFilterList.Count;
end;

function RMTools(index: Integer): TRMToolsInfo;
begin
  Result := TRMToolsInfo(FRMToolsList[index]);
end;

function RMToolsCount: Integer;
begin
  if FRMToolsList = nil then
    Result := -1
  else
    Result := FRMToolsList.Count;
end;

function RMFunctionList: TList;
begin
  if FRMFunctionList = nil then
    FRMFunctionList := TList.Create;
  Result := FRMFunctionList;
end;

function RMAddInFunctionCount: Integer;
begin
  if FRMFunctionList <> nil then
    Result := FRMFunctionList.Count
  else
    Result := 0;
end;

function RMAddInFunctions(Index: Integer): TRMCustomFunctionLibrary;
begin
  if (Index >= 0) and (Index < RMFunctionList.Count) then
    Result := TRMCustomFunctionLibrary(FRMFunctionList[Index])
  else
    Result := nil;
end;

procedure RMRegisterComAdapter(aClassRef: TClass; aComAdapterClass: TRMPersistentCompAdapterClass);
var
  tmp: TRMPageEditorInfo;
begin
  tmp := TRMPageEditorInfo.Create(aClassRef, aComAdapterClass);
  RMComAdapterList.Add(tmp);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMPageEditorInfo.Create(aPageClass: TClass; aPageEditorClass: TClass);
begin
  inherited Create;

  FPageClass := aPageClass;
  FPageEditorClass := aPageEditorClass;
end;

procedure RMRegisterPageEditor(aClassRef, aPageEditorClass: TClass);
var
  tmp: TRMPageEditorInfo;
begin
  tmp := TRMPageEditorInfo.Create(aClassRef, aPageEditorClass);
  RMPageEditorList.Add(tmp);
end;

procedure RMRegisterPageButton(const Hint: string; const ButtonBmpRes: string;
  aIsReportPage: Boolean; aPageClass: string);
var
  tmp: TRMToolsInfo;
begin
  tmp := TRMToolsInfo.Create(Hint, ButtonBmpRes, nil);
  tmp.FIsReportPage := aIsReportPage;
  tmp.FPageClassName := aPageClass;

  if FRMDsgPageButtonList = nil then
    FRMDsgPageButtonList := TList.Create;

  FRMDsgPageButtonList.Add(tmp);
end;

procedure RMResigerReportPageClass(ClassRef: TClass);
var
  tmp: TRMAddinObjectInfo;
begin
  tmp := TRMAddinObjectInfo.Create(ClassRef, nil, '', '', False);

  if FRMAddinReportPageList = nil then
    FRMAddinReportPageList := TList.Create;

  FRMAddinReportPageList.Add(tmp);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMAddInObjectInfo}

constructor TRMAddInObjectInfo.Create(AClassRef: TClass;
  AEditorFormClass: TFormClass; const AButtonBmpRes: string;
  const AButtonHint: string; AIsControl: Boolean);
begin
  inherited Create;
  FClassRef := TRMClass(AClassRef);
  FEditorFormClass := AEditorFormClass;
  FButtonBmpRes := AButtonBmpRes;
  FButtonHint := AButtonHint;
  FIsControl := AIsControl;
  FPage := '';
  FIsPage := True;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMExportFilterInfo}

constructor TRMExportFilterInfo.Create(AClassRef: TRMCustomExportFilter;
  const AFilterDesc: string; const AFilterExt: string);
begin
  inherited Create;
  FFilter := AClassRef;
  FFilterDesc := AFilterDesc;
  FFilterExt := AFilterExt;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMToolsInfo}

constructor TRMToolsInfo.Create(const ACaption: string;
  const AButtonBmpRes: string; AOnClick: TNotifyEvent);
begin
  inherited Create;
  FCaption := ACaption;
  FButtonBmpRes := AButtonBmpRes;
  FOnClick := AOnClick;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFunctionSplitter}

constructor TRMFunctionSplitter.Create(aMatchFuncs, aSplitTo: TWideStringList;
  aVariables: TRMVariables);
begin
  inherited Create;
  FParser := TRMParser.Create;
  FMatchFuncs := aMatchFuncs;
  FSplitTo := aSplitTo;
  FVariables := aVariables;
end;

destructor TRMFunctionSplitter.Destroy;
begin
  FParser.Free;
  inherited Destroy;
end;

procedure TRMFunctionSplitter.Split(aStr: WideString);
var
  i, k: Integer;
  s1: WideString;
  lParams: array[0..10] of Variant;
begin
  i := 1;
  aStr := Trim(aStr);
  if (Length(aStr) > 0) and (aStr[1] = '''') then Exit;

  while i <= Length(aStr) do
  begin
    k := i;
    if aStr[1] = '[' then
    begin
      s1 := RMGetBrackedVariable(aStr, k, i);
      if FVariables.IndexOf(s1) <> -1 then
        s1 := FVariables[s1];
      Split(s1);
      k := i + 1;
    end
    else
    begin
      s1 := FParser.GetIdentify(aStr, k);
      if aStr[k] = '(' then
      begin
        FParser.GetParameters(aStr, k, lParams);
        if lParams[0] <> Null then
          Split(lParams[0]);
        if lParams[1] <> Null then
          Split(lParams[1]);
        if lParams[2] <> Null then
          Split(lParams[2]);
        if FMatchFuncs.IndexOf(s1) <> -1 then
          FSplitTo.Add(Copy(aStr, i, k - i));
      end
      else if FVariables.IndexOf(s1) <> -1 then
      begin
        s1 := FVariables[s1];
        Split(s1);
      end
      else if RMWideCharIn(aStr[k], [' ', #13, '+', '-', '*', '/', '>', '<', '=']) then
        Inc(k)
      else if s1 = '' then
        Break;
    end;
    i := k;
  end;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{登记注册一个Add-in Object}

procedure RMRegisterObjectByRes(ClassRef: TClass; const ButtonBmpRes: string;
  const ButtonHint: string; EditorFormClass: TFormClass);
var
  tmp: TRMAddinObjectInfo;
begin
  tmp := TRMAddinObjectInfo.Create(ClassRef, EditorFormClass, ButtonBmpRes, ButtonHint,
    False);
  RMAddinObjectList.Add(tmp);
end;

procedure RMRegisterControl(ClassRef: TClass; const ButtonBmpRes, ButtonHint: string);
var
  tmp: TRMAddinObjectInfo;
begin
  tmp := TRMAddinObjectInfo.Create(ClassRef, nil, ButtonBmpRes, ButtonHint, TRUE);
  RMAddinObjectList.Add(tmp);
end;

function _FindRegisteredControl(aPage: string): Boolean;
var
  i: Integer;
  lInfo: TRMAddInObjectInfo;
begin
  Result := False;
  for i := 0 to RMAddinsCount - 1 do
  begin
    lInfo := RMAddins(i);
    if lInfo.IsPage and RMCmp(lInfo.Page, aPage) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure RMRegisterControl(const aPage, aPageButtonBmpRes: string; aIsControl: Boolean;
  aClassRef: TClass; aButtonBmpRes, aButtonHint: string);
var
  tmp: TRMAddinObjectInfo;
begin
  if not _FindRegisteredControl(aPage) then
  begin
    tmp := TRMAddinObjectInfo.Create(nil, nil, aPageButtonBmpRes,
      '', aIsControl);
    tmp.Page := aPage;
    tmp.IsPage := True;
    RMAddinObjectList.Add(tmp);
  end;

  tmp := TRMAddinObjectInfo.Create(aClassRef, nil, aButtonBmpRes,
    aButtonHint, aIsControl);
  tmp.Page := aPage;
  tmp.IsPage := False;
  RMAddinObjectList.Add(tmp);
end;

procedure RMRegisterControls(const aPage, aPageButtonBmpRes: string;
  aIsControl: Boolean;
  AryClassRef: array of TClass;
  AryButtonBmpRes: array of string;
  AryButtonHint: array of string);
var
  tmp: TRMAddinObjectInfo;
  i: Integer;
begin
  if not _FindRegisteredControl(aPage) then
  begin
    tmp := TRMAddinObjectInfo.Create(nil, nil, aPageButtonBmpRes,
      '', aIsControl);
    tmp.Page := aPage;
    tmp.IsPage := True;
    RMAddinObjectList.Add(tmp);
  end;

  for i := Low(AryClassRef) to High(AryClassRef) do
  begin
    tmp := TRMAddinObjectInfo.Create(AryClassRef[i], nil, AryButtonBmpRes[i],
      AryButtonHint[i], aIsControl);
    tmp.Page := aPage;
    tmp.IsPage := False;
    RMAddinObjectList.Add(tmp);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{登记注册一个Export}

procedure RMRegisterExportFilter(Filter: TRMCustomExportFilter; const FilterDesc, FilterExt: string);
var
  i: Integer;
  tmp: TRMExportFilterInfo;
begin
  for i := 0 to RMFiltersCount - 1 do
  begin
    if RMFilters(i).Filter.ClassName = Filter.ClassName then Exit;
  end;
  tmp := TRMExportFilterInfo.Create(Filter, FilterDesc, FilterExt);
  RMExportFilterList.Add(tmp);
end;

procedure RMUnRegisterExportFilter(Filter: TRMCustomExportFilter);
var
  i: Integer;
begin
  if FRMExportFilterList = nil then Exit;

  for i := 0 to RMFiltersCount - 1 do
  begin
    if RMFilters(i).Filter.ClassName = Filter.ClassName then
    begin
      TRMExportFilterInfo(RMExportFilterList[i]).Free;
      RMExportFilterList.Delete(i);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{登记注册一个Design Tools}

procedure RMRegisterTool(const MenuCaption: string; const ButtonBmpRes: string; OnClick: TNotifyEvent);
var
  tmp: TRMToolsInfo;
begin
  tmp := TRMToolsInfo.Create(MenuCaption, ButtonBmpRes, OnClick);
  RMToolsList.Add(tmp);
end;

procedure RMUnRegisterTool(const MenuCaption: string);
var
  i: Integer;
begin
  if FRMToolsList = nil then Exit;

  for i := 0 to RMToolsList.Count - 1 do
  begin
    if TRMToolsInfo(RMToolsList[i]).Caption = MenuCaption then
    begin
      TRMToolsInfo(RMToolsList[i]).Free;
      RMToolsList.Delete(i);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure RMRegisterFunctionLibrary(ClassRef: TClass);
var
  i: Integer;
  tmp: TRMCustomFunctionLibrary;
begin
  for i := 0 to RMFunctionList.Count - 1 do
  begin
    if TRMCustomFunctionLibrary(RMFunctionList[i]).ClassName = ClassRef.ClassName then
      Exit;
  end;

  tmp := TRMCustomFunctionLibrary(ClassRef.NewInstance);
  tmp.Create;
  RMFunctionList.Add(tmp);
end;

procedure RMUnRegisterFunctionLibrary(ClassRef: TClass);
var
  i: Integer;
begin
  if FRMFunctionList = nil then Exit;

  for i := 0 to RMFunctionList.Count - 1 do
  begin
    if TRMCustomFunctionLibrary(RMFunctionList[i]).ClassName = ClassRef.ClassName then
    begin
      TRMCustomFunctionLibrary(RMFunctionList[i]).Free;
      RMFunctionList.Delete(i);
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMCustomFunctionLibrary}

constructor TRMCustomFunctionLibrary.Create;
begin
  inherited Create;

  FList := TStringList.Create;
  FFunctionList := TList.Create;
end;

destructor TRMCustomFunctionLibrary.Destroy;
begin
  Clear;
  FFunctionList.Free;
  FList.Free;

  inherited Destroy;
end;

procedure TRMCustomFunctionLibrary.Clear;
begin
  while FFunctionList.Count > 0 do
  begin
    Dispose(PRMFunctionDesc(FFunctionList[0]));
    FFunctionList.Delete(0);
  end;
end;

procedure TRMCustomFunctionLibrary.DoFunction(aParser: TRMCustomParser; aFuncNo: Integer; aParams: array of Variant;
  var aValue: Variant);
begin
//
end;

function TRMCustomFunctionLibrary.OnFunction(aParser: TRMCustomParser; const aFunctionName: string;
  aParams: array of Variant; var aValue: Variant): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := FList.IndexOf(aFunctionName);
  if i >= 0 then
  begin
    DoFunction(aParser, i, aParams, aValue);
    Result := True;
  end;
end;

procedure TRMCustomFunctionLibrary.AddFunctionDesc(const aFuncName, aCategory,
  aDescription, aFuncPara: string);
var
  pfunc: PRMFunctionDesc;
begin
  New(pfunc);
  pfunc^.FuncName := aFuncName;
  pfunc^.Category := aCategory;
  pfunc^.Description := aDescription;
  pfunc^.FuncPara := aFuncPara;

  FFunctionList.Add(pfunc);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure FreeAddInReportPageList;
var
  i: Integer;
begin
  if FRMAddInReportPageList = nil then Exit;

  for i := 0 to FRMAddInReportPageList.Count - 1 do
    TRMAddInObjectInfo(FRMAddInReportPageList[i]).Free;

  FreeAndNil(FRMAddInReportPageList);
end;

procedure FreeAddInObjectList;
var
  i: Integer;
begin
  if FRMAddInObjectList = nil then Exit;
  for i := 0 to FRMAddInObjectList.Count - 1 do
    TRMAddinObjectInfo(FRMAddInObjectList[i]).Free;

  FreeAndNil(FRMAddInObjectList);
end;

procedure FreeExportFilterList;
var
  i: Integer;
begin
  if FRMExportFilterList = nil then Exit;
  for i := 0 to FRMExportFilterList.Count - 1 do
    TRMExportFilterInfo(FRMExportFilterList[i]).Free;

  FreeAndNil(FRMExportFilterList);
end;

procedure FreeToolsList;
var
  i: Integer;
begin
  if FRMToolsList = nil then Exit;
  for i := 0 to FRMToolsList.Count - 1 do
    TRMToolsInfo(FRMToolsList[i]).Free;

  FreeAndNil(FRMToolsList);
end;

procedure FreeComAdapterList;
var
  i: Integer;
begin
  if FComAdapterList = nil then Exit;

  for i := 0 to FComAdapterList.Count - 1 do
    TRMPageEditorInfo(FComAdapterList[i]).Free;

  FreeAndNil(FComAdapterList);
end;

procedure FreePageEditorList;
var
  i: Integer;
begin
  if FRMPageEditorList = nil then Exit;

  for i := 0 to FRMPageEditorList.Count - 1 do
    TRMPageEditorInfo(FRMPageEditorList[i]).Free;

  FreeAndNil(FRMPageEditorList);
end;

procedure FreeDsgPageButton;
var
  i: Integer;
begin
  if FRMDsgPageButtonList = nil then Exit;

  for i := 0 to FRMDsgPageButtonList.Count - 1 do
    TRMToolsInfo(FRMDsgPageButtonList[i]).Free;

  FreeAndNil(FRMDsgPageButtonList);
end;

procedure FreeFunctionList;
var
  i: Integer;
begin
  if FRMFunctionList = nil then Exit;
  for i := 0 to FRMFunctionList.Count - 1 do
    TRMCustomFunctionLibrary(FRMFunctionList[i]).Free;

  FreeAndNil(FRMFunctionList);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TWideStringList_Read_Text(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Text;
end;

procedure TWideStringList_Write_Text(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Text := Value;
end;

procedure TWideStringList_Add(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Add(Args.Values[0]);
end;

procedure TWideStringList_Clear(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Clear;
end;

procedure TWideStringList_Delete(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Delete(Args.Values[0]);
end;

procedure TWideStringList_Exchange(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Exchange(Args.Values[0], Args.Values[1]);
end;

procedure TWideStringList_Find(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Find(Args.Values[0], TVarData(Args.Values[1]).vInteger);
end;

procedure TWideStringList_IndexOf(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).IndexOf(Args.Values[0]);
end;

procedure TWideStringList_Insert(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Insert(Args.Values[0], Args.Values[1]);
end;

procedure TWideStringList_Sort(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Sort;
end;

//procedure TWideStringList_AddObject(var Value: Variant; Args: TJvInterpreterArgs);
//begin
//  Value := TWideStringList(Args.Obj).AddObject(Args.Values[0], V2O(Args.Values[1]));
//end;

procedure TWideStringList_Append(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Append(Args.Values[0]);
end;

procedure TWideStringList_AddStrings(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).AddStrings(V2O(Args.Values[0]) as TWideStringList);
end;

procedure TWideStringList_Assign(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Assign(V2O(Args.Values[0]) as TPersistent);
end;

procedure TWideStringList_BeginUpdate(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).BeginUpdate;
end;

procedure TWideStringList_EndUpdate(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).EndUpdate;
end;

procedure TWideStringList_Equals(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Equals(V2O(Args.Values[0]) as TWideStringList);
end;

procedure TWideStringList_IndexOfName(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).IndexOfName(Args.Values[0]);
end;

procedure TWideStringList_IndexOfObject(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).IndexOfObject(V2O(Args.Values[0]));
end;

procedure TWideStringList_InsertObject(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).InsertObject(Args.Values[0], Args.Values[1], V2O(Args.Values[2]));
end;

procedure TWideStringList_LoadFromFile(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).LoadFromFile(Args.Values[0]);
end;

procedure TWideStringList_LoadFromStream(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).LoadFromStream(V2O(Args.Values[0]) as TStream);
end;

procedure TWideStringList_Move(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Move(Args.Values[0], Args.Values[1]);
end;

procedure TWideStringList_SaveToFile(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).SaveToFile(Args.Values[0]);
end;

procedure TWideStringList_SaveToStream(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).SaveToStream(V2O(Args.Values[0]) as TStream);
end;

procedure TWideStringList_Read_Capacity(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Capacity;
end;

procedure TWideStringList_Write_Capacity(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Capacity := Value;
end;

procedure TWideStringList_Read_CommaText(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).CommaText;
end;

procedure TWideStringList_Write_CommaText(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).CommaText := Value;
end;

procedure TWideStringList_Read_Count(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Count;
end;

procedure TWideStringList_Read_Names(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Names[Args.Values[0]];
end;

procedure TWideStringList_Read_Values(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Values[Args.Values[0]];
end;

procedure TWideStringList_Write_Values(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Values[Args.Values[0]] := Value;
end;

procedure TWideStringList_Read_Objects(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TWideStringList(Args.Obj).Objects[Args.Values[0]]);
end;

procedure TWideStringList_Write_Objects(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Objects[Args.Values[0]] := V2O(Value);
end;

procedure TWideStringList_Read_Strings(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TWideStringList(Args.Obj).Strings[Args.Values[0]];
end;

procedure TWideStringList_Write_Strings(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TWideStringList(Args.Obj).Strings[Args.Values[0]] := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

const
  cReportMachine = 'RM_Class';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    { TWideStringList }
    AddClass('cReportMachine', TWideStringList, 'TWideStringList');
    AddGet(TWideStringList, 'Append', TWideStringList_Append, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'AddStrings', TWideStringList_AddStrings, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'Assign', TWideStringList_Assign, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'IndexOfName', TWideStringList_IndexOfName, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'LoadFromFile', TWideStringList_LoadFromFile, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'Move', TWideStringList_Move, 2, [varEmpty, varEmpty], varEmpty);
    AddGet(TWideStringList, 'SaveToFile', TWideStringList_SaveToFile, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'CommaText', TWideStringList_Read_CommaText, 0, [0], varEmpty);
    AddSet(TWideStringList, 'CommaText', TWideStringList_Write_CommaText, 0, [0]);
    AddGet(TWideStringList, 'Count', TWideStringList_Read_Count, 0, [0], varEmpty);
    AddIGet(TWideStringList, 'Names', TWideStringList_Read_Names, 1, [0], varEmpty);
    AddIGet(TWideStringList, 'Values', TWideStringList_Read_Values, 1, [0], varEmpty);
    AddISet(TWideStringList, 'Values', TWideStringList_Write_Values, 1, [1]); // ivan_ra
    AddIGet(TWideStringList, 'Objects', TWideStringList_Read_Objects, 1, [0], varEmpty);
    AddISet(TWideStringList, 'Objects', TWideStringList_Write_Objects, 1, [1]);
    AddIGet(TWideStringList, 'Strings', TWideStringList_Read_Strings, 1, [0], varEmpty);
    AddISet(TWideStringList, 'Strings', TWideStringList_Write_Strings, 1, [1]);
    AddIDGet(TWideStringList, TWideStringList_Read_Strings, 1, [0], varEmpty);
    AddIDSet(TWideStringList, TWideStringList_Write_Strings, 1, [1]);
    AddGet(TWideStringList, 'Text', TWideStringList_Read_Text, 0, [0], varEmpty);
    AddSet(TWideStringList, 'Text', TWideStringList_Write_Text, 0, [0]);
    AddGet(TWideStringList, 'Add', TWideStringList_Add, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'Clear', TWideStringList_Clear, 0, [0], varEmpty);
    AddGet(TWideStringList, 'Delete', TWideStringList_Delete, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'Exchange', TWideStringList_Exchange, 2, [varEmpty, varEmpty], varEmpty);
    AddGet(TWideStringList, 'Find', TWideStringList_Find, 2, [varEmpty, varByRef], varEmpty);
    AddGet(TWideStringList, 'IndexOf', TWideStringList_IndexOf, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'Insert', TWideStringList_Insert, 2, [varEmpty, varEmpty], varEmpty);
    AddGet(TWideStringList, 'Sort', TWideStringList_Sort, 0, [0], varEmpty);
    AddGet(TWideStringList, 'BeginUpdate', TWideStringList_BeginUpdate, 0, [0], varEmpty);
    AddGet(TWideStringList, 'EndUpdate', TWideStringList_EndUpdate, 0, [0], varEmpty);
    AddGet(TWideStringList, 'Capacity', TWideStringList_Read_Capacity, 0, [varEmpty], varEmpty);
    AddSet(TWideStringList, 'Capacity', TWideStringList_Write_Capacity, 0, [varEmpty]);
    AddGet(TWideStringList, 'SaveToStream', TWideStringList_SaveToStream, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'LoadFromStream', TWideStringList_LoadFromStream, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'IndexOfObject', TWideStringList_IndexOfObject, 1, [varEmpty], varEmpty);
    AddGet(TWideStringList, 'InsertObject', TWideStringList_InsertObject, 3, [varEmpty, varEmpty, varEmpty], varEmpty);
    AddGet(TWideStringList, 'Equals', TWideStringList_Equals, 1, [varEmpty], varEmpty);
  end;
end;

initialization
  RMRegRootKey := 'Software\WHF SoftWare\Report Machine';
  FDataSetList := nil;
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization
  FreeAndNil(FDataSetList);
  FreeAddInObjectList;
  FreeAddInReportPageList;
  FreeExportFilterList;
  FreeToolsList;
  FreeFunctionList;
  FreePageEditorList;
  FreeDsgPageButton;
  FreeComAdapterList;

end.

