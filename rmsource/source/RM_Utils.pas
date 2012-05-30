
{*****************************************}
{                                         }
{           Report Machine v2.0           }
{            Various routines             }
{                                         }
{*****************************************}

unit RM_utils;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, TypInfo, Classes, Graphics, Controls, Forms, StdCtrls,
  Menus, RM_Common, RM_Class, RM_Dataset
{$IFDEF COMPILER4_UP}, SysConst{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF}
{$IFDEF COMPILER7_UP}, StrUtils{$ENDIF}
{$IFDEF TntUnicode}, TntSysUtils{$ENDIF};

const
  RMBreakChars: set of Char = [' ', #13, '-'];
  RMChineseBreakChars: array[0..35] of string = (
    '。', '.', '，', ',', '、', '；', ';', '：', ':', '？', '?', '！', '!', '…', '—', '·', 'ˉ', '’',
    '”', '～', '∶', '＂', '＇', '｀', '｜', '〕', '〉', '》', '」', '』', '．', '〗', '】', '）', '］', '｝');
  RMChinereEndChars: array[0..11] of string = (
    '‘', '“', '〔', '〈', '《', '「', '『', '〖', '【', '（', '［', '｝');

{$IFNDEF COMPILER4_UP}
type
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
function Min(A, B: Single): Single;
function Max(A, B: Double): Double;
{$ENDIF}

{$IFNDEF COMPILER6_UP}
type
  UTF8String = type string;
  PUTF8String = ^UTF8String;

function UnicodeToUtf8(Dest: PChar; Source: PWideChar; MaxBytes: Integer): Integer; overload;
function Utf8ToUnicode(Dest: PWideChar; Source: PChar; MaxChars: Integer): Integer; overload;

function UnicodeToUtf8(Dest: PChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal; overload;
function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PChar; SourceBytes: Cardinal): Cardinal; overload;

function UTF8Encode(const WS: WideString): UTF8String;
function UTF8Decode(const S: UTF8String): WideString;
{$ENDIF}

type

  { TRMDeviceCompatibleCanvas }
  TRMDeviceCompatibleCanvas = class(TCanvas)
  private
    FReferenceDC: HDC;
    FCompatibleDC: HDC;
    FCompatibleBitmap: HBitmap;
    FOldBitmap: HBitmap;
    FWidth: Integer;
    FHeight: Integer;
    FSavePalette: HPalette;
    FRestorePalette: Boolean;
  protected
    procedure CreateHandle; override;
    procedure Changing; override;
    procedure UpdateFont;
  public
    constructor Create(aReferenceDC: HDC; aWidth, aHeight: Integer; aPalette: HPalette);
    destructor Destroy; override;

    procedure RenderToDevice(aDestRect: TRect; aPalette: HPalette; aCopyMode: TCopyMode);
    property Height: Integer read FHeight;
    property Width: Integer read FWidth;
  end;

  { TRMHtmlFontStack }
  TRMHtmlFontStack = class(TObject) //字体栈
  private
    FFontList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(aFont: TFont);
    function Pop: TFont;
  end;

  PRMHtmlElement = ^TRMtmlElement;
  TRMtmlElement = record
    H_tag: WideString; //标记名称
    H_str: WideString; //字符内容
    H_paras: array of WideString; //参数名称列表
    H_values: array of WideString; //参数值列表
    H_TagStr: WideString;
  end;

  PRMHtmlParaValue = ^TRMHtmlParaValue;
  TRMHtmlParaValue = record
    ParaName: WideString; //参数名称
    ParaValue: WideString; //参数的值
  end;

  { TRMHtmlList }
  TRMHtmlList = class(TList)
  private
  protected
  public
    procedure Clear; override;
  end;

function RMReadAnsiMemo(aStream: TStream): string;
procedure RMReadMemo(aStream: TStream; aStrings: TStrings);
procedure RMWriteMemo(aStream: TStream; aStrings: TStrings);
function RMReadString(aStream: TStream): string;
procedure RMWriteString(aStream: TStream; const s: string);
function RMReadWideString(aStream: TStream): WideString;
procedure RMReadWideMemo(aStream: TStream; aStrings: TWideStrings);
procedure RMWriteWideMemo(aStream: TStream; aStrings: TWideStrings);
procedure RMWriteWideString(aStream: TStream; const s: WideString);
function RMReadBoolean(aStream: TStream): Boolean;
procedure RMWriteBoolean(aStream: TStream; Value: Boolean);
function RMReadByte(aStream: TStream): Byte;
procedure RMWriteByte(aStream: TStream; Value: Byte);
function RMReadWord(aStream: TStream): Word;
procedure RMWriteWord(aStream: TStream; Value: Word);
function RMReadInt32(aStream: TStream): Integer;
procedure RMWriteInt32(aStream: TStream; Value: Integer);
function RMReadLongWord(aStream: TStream): LongWord;
procedure RMWriteLongWord(aStream: TStream; Value: LongWord);
function RMReadFloat(aStream: TStream): Single;
procedure RMWriteFloat(aStream: TStream; Value: Single);
procedure RMReadFont(aStream: TStream; Font: TFont);
procedure RMWriteFont(aStream: TStream; Font: TFont);
function RMReadRect(aStream: TStream): TRect;
procedure RMWriteRect(aStream: TStream; aRect: TRect);

{Added by dejoy begin}
procedure RMReadObjFromStream(aStream: TStream; aObj : TPersistent);
procedure RMWriteObjToStream(aStream: TStream; aObj : TPersistent);

procedure RMReadObjFromFile(aObj:TPersistent;const aFileName:String);
procedure RMWriteObjToFile(aObj:TPersistent;const aFilename:String);
{Added by dejoy end}

function RMWideCharIn(aChar: WideChar; aSysCharSet: TSysCharSet): Boolean;
function RMFindComponent(aOwner: TComponent; const aComponentName: string): TComponent;
procedure RMGetComponents(aOwner: TComponent; aClassRef: TClass; aList: TStrings; aSkip: TComponent);
procedure RMEnableControls(c: array of TControl; e: Boolean);
function RMGetFontStyle(Style: TFontStyles): Integer;
function RMSetFontStyle(Style: Integer): TFontStyles;
function RMRemoveQuotes(const aStr: WideString): WideString;
procedure RMSetCommaText(Text: string; sl: TStringList);

function RMWideCanvasTextExtent(aCanvas: TCanvas; const aText: WideString): TSize;
function RMWideCanvasTextWidth(aCanvas: TCanvas; const aText: WideString): Integer;
function RMWideCanvasTextHeight(aCanvas: TCanvas; const aText: WideString): Integer;
function RMCanvasWidth(const aStr: string; aFont: TFont): Integer;
function RMCanvasHeight(const aStr: string; aFont: TFont): Integer;
function RMWrapStrings(const aSrcLines: TWideStringList; aDstLines: TWideStringList;
  aCanvas: TCanvas; aWidth: Integer; const aLineSpacing: Integer;
  aWordBreak, aCharWrap, aAllowHtmlTag, aWidthFlag, aAddChar: Boolean): integer;

function RMLoadStr(aResID: Integer): string;
function RMNumToBig(Value: Integer): string;
function RMCurrToBIGNum(Value: Currency): string;
function RMChineseNumber(const jnum: string): string;
function RMSmallToBig(curs: string): string;
procedure RMSetFontSize(aComboBox: TComboBox; aFontHeight, aFontSize: integer);
procedure RMSetFontSize1(aListBox: TListBox; aFontSize: integer);
function RMGetFontSize(aComboBox: TComboBox): integer;
function RMGetFontSize1(aIndex: Integer; aText: string): integer;
function RMCreateBitmap(const ResName: string): TBitmap;
procedure RMSetStrProp(aObject: TObject; const aPropName: string; ID: Integer);
function RMGetPropValue(aReport: TRMReport; const aObjectName, aPropName: string): Variant;
function RMRound(x: Extended; dicNum: Integer): Extended; //四舍五入

function RMMakeFileName(AFileName, AFileExtension: string; ANumber: Integer): string;
function RMAppendTrailingBackslash(const S: string): string;
function RMColorBGRToRGB(AColor: TColor): string;
function RMMakeImgFileName(AFileName, AFileExtension: string; ANumber: Integer): string;
procedure RMSetControlsEnable(AControl: TWinControl; AState: Boolean);
procedure RMSaveFormPosition(aParentKey: string; aForm: TForm);
procedure RMRestoreFormPosition(aParentKey: string; aForm: TForm);
procedure RMGetBitmapPixels(aGraphic: TGraphic; var x, y: Integer);
function RMGetWindowsVersion: string;
function RMGetTmpFileName: string; overload;
function RMGetTmpFileName(aExt: string): string; overload;

function RMMonth_EnglishShort(aMonth: Integer): string;
function RMMonth_EnglishLong(aMonth: Integer): string;
function RMSinglNumToBig(Value: Extended; Digit: Integer): string;

function RMStream2TXT(aStream: TStream): AnsiString;
function RMTXT2Stream(inStr: AnsiString; OutStream: TStream): Boolean;

function RMStrToFloat(aStr: string): Double;
function RMisNumeric(aStr: string): Boolean;
function RMIsValidFloat(aStr: string): Boolean;
function RMStrGetToken(s: string; delimeter: string; var APos: integer): string;
function RMExtractField(const aStr: string; aFieldNo: Integer): string;
procedure RMSetNullValue(var aValue1, aValue2: Variant);
procedure RMSetControlsEnabled(aControl: TWinControl; aEnabled: Boolean);

procedure RMPrintGraphic(const aCanvas: TCanvas; aDestRect: TRect; const aGraphic: TGraphic;
  aIsPrinting: Boolean; aDirectDraw: Boolean; aTransparent: Boolean);
function RMDeleteNoNumberChar(s: string): string;
function RMO2V(O: TObject): Variant;
{$IFNDEF COMPILER6_UP}
function TryStrToFloat(const S: string; out Value: Extended): Boolean;
{$ENDIF}
function RMNumToLetters(Number: Real): string;
function RMTrim(aStr: string): string;

procedure RMHtmlAnalyseElement(aSourceStr: WideString; var aHtmlElements: TRMHtmlList);
procedure RMHtmlSetFont(aFont: TFont; aHtmlElement: PRMHtmlElement;
  aFontStack: TRMHtmlFontStack; aDocMode: TRMDocMode; aFactorY: Double; aList: TWideStringList);

function RMPosEx(const SubStr, S: WideString; Offset: Cardinal = 1): Integer;

//added by dejoy
procedure GetMethodDefinition(ATypeInfo: PTypeInfo; AStrings: TStrings);overload;
function GetMethodDefinition(ATypeInfo: PTypeInfo):string;overload;
function GetFullMethodDefinition(Instance: TComponent; const PropName: string):string;

implementation

uses
  Math, Registry, RM_Const, RM_Const1;

type
  THackReport = class(TRMReport)
  end;

function RMWideCharIn(aChar: WideChar; aSysCharSet: TSysCharSet): Boolean;
begin
  Result := (aChar <= High(AnsiChar)) and (AnsiChar(aChar) in aSysCharSet);
end;

function RMO2V(O: TObject): Variant;
begin
  TVarData(Result).VType := $0010;
  TVarData(Result).vPointer := O;
end;

{$IFNDEF COMPILER4_UP}

function Min(A, B: Single): Single;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(A, B: Double): Double;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;
{$ENDIF}

{$IFNDEF COMPILER6_UP}

function UnicodeToUtf8(Dest: PChar; Source: PWideChar; MaxBytes: Integer): Integer;
var
  len: Cardinal;
begin
  len := 0;
  if Source <> nil then
    while Source[len] <> #0 do
      Inc(len);
  Result := UnicodeToUtf8(Dest, MaxBytes, Source, len);
end;

// UnicodeToUtf8(4):
// MaxDestBytes includes the null terminator (last char in the buffer will be set to null)
// Function result includes the null terminator.
// Nulls in the source data are not considered terminators - SourceChars must be accurate

function UnicodeToUtf8(Dest: PChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Cardinal;
begin
  Result := 0;
  if Source = nil then Exit;
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceChars) and (count < MaxDestBytes) do
    begin
      c := Cardinal(Source[i]);
      Inc(i);
      if c <= $7F then
      begin
        Dest[count] := Char(c);
        Inc(count);
      end
      else if c > $7FF then
      begin
        if count + 3 > MaxDestBytes then
          break;
        Dest[count] := Char($E0 or (c shr 12));
        Dest[count + 1] := Char($80 or ((c shr 6) and $3F));
        Dest[count + 2] := Char($80 or (c and $3F));
        Inc(count, 3);
      end
      else //  $7F < Source[i] <= $7FF
      begin
        if count + 2 > MaxDestBytes then
          break;
        Dest[count] := Char($C0 or (c shr 6));
        Dest[count + 1] := Char($80 or (c and $3F));
        Inc(count, 2);
      end;
    end;
    if count >= MaxDestBytes then count := MaxDestBytes - 1;
    Dest[count] := #0;
  end
  else
  begin
    while i < SourceChars do
    begin
      c := Integer(Source[i]);
      Inc(i);
      if c > $7F then
      begin
        if c > $7FF then
          Inc(count);
        Inc(count);
      end;
      Inc(count);
    end;
  end;
  Result := count + 1; // convert zero based index to byte count
end;

function Utf8ToUnicode(Dest: PWideChar; Source: PChar; MaxChars: Integer): Integer;
var
  len: Cardinal;
begin
  len := 0;
  if Source <> nil then
    while Source[len] <> #0 do
      Inc(len);
  Result := Utf8ToUnicode(Dest, MaxChars, Source, len);
end;

function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PChar; SourceBytes: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := Cardinal(-1);
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceBytes) and (count < MaxDestChars) do
    begin
      wc := Cardinal(Source[i]);
      Inc(i);
      if (wc and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit; // incomplete multibyte char
        wc := wc and $3F;
        if (wc and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit; // malformed trail byte or out of range char
          if i >= SourceBytes then Exit; // incomplete multibyte char
          wc := (wc shl 6) or (c and $3F);
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit; // malformed trail byte

        Dest[count] := WideChar((wc shl 6) or (c and $3F));
      end
      else
        Dest[count] := WideChar(wc);
      Inc(count);
    end;
    if count >= MaxDestChars then count := MaxDestChars - 1;
    Dest[count] := #0;
  end
  else
  begin
    while (i < SourceBytes) do
    begin
      c := Byte(Source[i]);
      Inc(i);
      if (c and $80) <> 0 then
      begin
        if i >= SourceBytes then Exit; // incomplete multibyte char
        c := c and $3F;
        if (c and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit; // malformed trail byte or out of range char
          if i >= SourceBytes then Exit; // incomplete multibyte char
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit; // malformed trail byte
      end;
      Inc(count);
    end;
  end;
  Result := count + 1;
end;

function UTF8Encode(const WS: WideString): UTF8String;
var
  L: Integer;
  Temp: UTF8String;
begin
  Result := '';
  if WS = '' then Exit;
  SetLength(Temp, Length(WS) * 3); // SetLength includes space for null terminator

  L := UnicodeToUtf8(PChar(Temp), Length(Temp) + 1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;

function UTF8Decode(const S: UTF8String): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result := '';
  if S = '' then Exit;
  SetLength(Temp, Length(S));

  L := Utf8ToUnicode(PWideChar(Temp), Length(Temp) + 1, PChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L - 1)
  else
    Temp := '';
  Result := Temp;
end;
{$ENDIF}

function RMSetFontStyle(Style: Integer): TFontStyles;
begin
  Result := [];
  if (Style and $1) <> 0 then
    Result := Result + [fsItalic];
  if (Style and $2) <> 0 then
    Result := Result + [fsBold];
  if (Style and $4) <> 0 then
    Result := Result + [fsUnderLine];
  if (Style and $8) <> 0 then
    Result := Result + [fsStrikeOut];
end;

function RMGetFontStyle(Style: TFontStyles): Integer;
begin
  Result := 0;
  if fsItalic in Style then
    Result := Result or $1;
  if fsBold in Style then
    Result := Result or $2;
  if fsUnderline in Style then
    Result := Result or $4;
  if fsStrikeOut in Style then
    Result := Result or $8;
end;

function RMReadAnsiMemo(aStream: TStream): string;
var
  lStrLen: Integer;
begin
  Result := '';
  lStrLen := RMReadInt32(aStream);
  if lStrLen > 0 then
  begin
    SetLength(Result, lStrLen);
    aStream.Read(Pointer(Result)^, lStrLen);
  end;
end;

procedure RMReadMemo(aStream: TStream; aStrings: TStrings);
var
  lStr: string;
  lStrLen: Integer;
begin
  aStrings.Clear;
  lStrLen := RMReadInt32(aStream);
  if lStrLen > 0 then
  begin
    SetString(lStr, PChar(nil), lStrLen);
    aStream.Read(Pointer(lStr)^, lStrLen);
    aStrings.Text := lStr;
  end;
end;

procedure RMWriteMemo(aStream: TStream; aStrings: TStrings);
var
  lStr: string;
  lStrLen: Integer;
begin
  lStr := aStrings.Text;
  lStrLen := Length(lStr);
  RMWriteInt32(aStream, lStrLen);
  if lStrLen > 0 then
    aStream.WriteBuffer(Pointer(lStr)^, lStrLen);
end;

function RMReadString(aStream: TStream): string;
var
  n: Word;
begin
  aStream.Read(n, 2);
  SetLength(Result, n);
  aStream.Read(Pointer(Result)^, n);
end;

procedure RMWriteString(aStream: TStream; const s: string);
var
  n: Word;
begin
  n := Length(s);
  aStream.Write(n, 2);
  aStream.Write(Pointer(s)^, n);
end;

function RMReadWideString(aStream: TStream): WideString;
var
  lCount: Integer;
  lUtf8Str: string;
  lType: TRMValueType;
begin
  aStream.Read(lType, 1);
  if lType = rmvaUTF8String then
  begin
    aStream.Read(lCount, 4);
    SetLength(lUtf8Str, lCount);
    aStream.Read(Pointer(lUtf8Str)^, lCount);
    Result := UTF8Decode(lUtf8Str);
  end
  else
  begin
    aStream.Read(lCount, 4);
    SetLength(Result, lCount);
    aStream.Read(Pointer(Result)^, lCount * 2);
  end;
end;

procedure RMWriteWideString(aStream: TStream; const s: WideString);
var
  lCount, lCountUtf8: Integer;
  lUtf8Str: string;
  lType: TRMValueType;
begin
  lUtf8Str := Utf8Encode(s);
  lCount := Length(s);
  lCountUtf8 := Length(lUtf8Str);
  if lCountUtf8 < (lCount * SizeOf(WideChar)) then
  begin
    lType := rmvaUTF8String;
    aStream.Write(lType, 1);

    aStream.Write(lCountUtf8, 4);
    aStream.Write(Pointer(lUtf8Str)^, lCountUtf8);
  end
  else
  begin
    lType := rmvaWideString;
    aStream.Write(lType, 1);

    aStream.Write(lCount, 4);
    aStream.Write(Pointer(s)^, lCount * 2);
  end;
end;

procedure RMReadWideMemo(aStream: TStream; aStrings: TWideStrings);
var
  lLen: Integer;
  lStr: WideString;
  lUtf8Str: string;
  lType: TRMValueType;
begin
  aStrings.Clear;
  aStream.Read(lType, 1);
  if lType = rmvaUTF8String then
  begin
    aStream.Read(lLen, 4);
    SetLength(lUtf8Str, lLen);
    aStream.Read(Pointer(lUtf8Str)^, lLen);
    aStrings.Text := Utf8Decode(lUtf8Str);
  end
  else
  begin
    aStream.Read(lLen, 4);
    SetLength(lStr, lLen);
    aStream.Read(Pointer(lStr)^, lLen * 2);
    aStrings.Text := lStr;
  end;
end;

procedure RMWriteWideMemo(aStream: TStream; aStrings: TWideStrings);
var
  lLen, lLenUtf8: Integer;
  lStr: WideString;
  lUtf8Str: string;
  lType: TRMValueType;
begin
  lStr := aStrings.Text;
  lUtf8Str := Utf8Encode(lStr);
  lLen := Length(lStr);
  lLenUtf8 := Length(lUtf8Str);
  if lLenUtf8 < (lLen * 2) then
  begin
    lType := rmvaUTF8String;
    aStream.Write(lType, 1);

    aStream.Write(lLenUtf8, 4);
    aStream.Write(Pointer(lUtf8Str)^, lLenUtf8);
  end
  else
  begin
    lType := rmvaWideString;
    aStream.Write(lType, 1);

    aStream.Write(lLen, 4);
    aStream.Write(Pointer(lStr)^, lLen * 2);
  end;
end;

function RMReadBoolean(aStream: TStream): Boolean;
begin
  aStream.Read(Result, 1);
end;

procedure RMWriteBoolean(aStream: TStream; Value: Boolean);
begin
  aStream.Write(Value, 1);
end;

function RMReadByte(aStream: TStream): Byte;
begin
  aStream.Read(Result, 1);
end;

procedure RMWriteByte(aStream: TStream; Value: Byte);
begin
  aStream.Write(Value, 1);
end;

function RMReadWord(aStream: TStream): Word;
begin
  aStream.Read(Result, 2);
end;

procedure RMWriteWord(aStream: TStream; Value: Word);
begin
  aStream.Write(Value, 2);
end;

function RMReadInt32(aStream: TStream): Integer;
begin
  aStream.Read(Result, 4);
end;

procedure RMWriteInt32(aStream: TStream; Value: Integer);
begin
  aStream.Write(Value, 4);
end;

function RMReadLongWord(aStream: TStream): LongWord;
begin
  aStream.Read(Result, 4);
end;

procedure RMWriteLongWord(aStream: TStream; Value: LongWord);
begin
  aStream.Write(Value, 4);
end;

function RMReadFloat(aStream: TStream): Single;
begin
  aStream.Read(Result, SizeOf(Result));
end;

procedure RMWriteFloat(aStream: TStream; Value: Single);
begin
  aStream.Write(Value, SizeOf(Value));
end;

{$HINTS OFF}

procedure RMReadFont(aStream: TStream; Font: TFont);
var
  lSize: Integer;

  function _SetFontStyle(Style: Integer): TFontStyles;
  begin
    Result := [];
    if (Style and $1) <> 0 then
      Result := Result + [fsItalic];
    if (Style and $2) <> 0 then
      Result := Result + [fsBold];
    if (Style and $4) <> 0 then
      Result := Result + [fsUnderLine];
    if (Style and $8) <> 0 then
      Result := Result + [fsStrikeOut];
  end;

begin
  Font.Name := RMReadString(aStream);
  lSize := RMReadInt32(aStream);
  if lSize >= 0 then
    Font.Size := lSize
  else
    Font.Height := lSize;

  Font.Style := _SetFontStyle(RMReadWord(aStream));
  Font.Color := RMReadInt32(aStream);
  Font.Charset := RMReadWord(aStream);
end;

procedure RMWriteFont(aStream: TStream; Font: TFont);

  function _GetFontStyle(Style: TFontStyles): Integer;
  begin
    Result := 0;
    if fsItalic in Style then
      Result := Result or $1;
    if fsBold in Style then
      Result := Result or $2;
    if fsUnderline in Style then
      Result := Result or $4;
    if fsStrikeOut in Style then
      Result := Result or $8;
  end;

begin
  RMWriteString(aStream, Font.Name);
  RMWriteInt32(aStream, Font.Height {Size});
  RMWriteWord(aStream, _GetFontStyle(Font.Style));
  RMWriteInt32(aStream, Font.Color);
  RMWriteWord(aStream, Font.Charset);
end;
{$HINTS ON}

function RMReadRect(aStream: TStream): TRect;
begin
  Result.Left := RMReadInt32(aStream);
  Result.Top := RMReadInt32(aStream);
  Result.Right := RMReadInt32(aStream);
  Result.Bottom := RMReadInt32(aStream);
end;

procedure RMWriteRect(aStream: TStream; aRect: TRect);
begin
  RMWriteInt32(aStream, aRect.Left);
  RMWriteInt32(aStream, aRect.Top);
  RMWriteInt32(aStream, aRect.Right);
  RMWriteInt32(aStream, aRect.Bottom);
end;

type
  TWrapperComponent = class(TComponent)
  private
    fP : TPersistent;
  published
    property P : TPersistent read fP write fP;
  end;

const
  DefaultOpenMode : integer = fmOpenRead or fmShareDenyWrite;

procedure RMWriteObjToStream(aStream: TStream; aObj : TPersistent);
var
  m : TWrapperComponent;
begin
  if aObj is TComponent then
  begin
    aStream.WriteComponent(TComponent(aObj))
  end
  else
    begin
      m := TWrapperComponent.Create(nil);
      try
        m.P := aObj;
        aStream.WriteComponent(m);
      finally
        m.Free;
      end;
    end;
end;

procedure RMReadObjFromStream(aStream: TStream; aObj : TPersistent);
var
  m : TWrapperComponent;
begin
  BeginGlobalLoading;
  try
    if aObj is TComponent then
      begin
        aStream.ReadComponent(TComponent(aObj));
        NotifyGlobalLoading;
      end
    else
      begin
        m := TWrapperComponent.Create(nil);
        try
          m.P := aObj;
          aStream.ReadComponent(m);
        finally
          m.Free;
        end;
      end;
  finally
    EndGlobalLoading;
  end;
end;

procedure RMReadObjFromFile(aObj:TPersistent;const aFileName:String);
Var
  F:TFileStream;
begin
  F:=TFileStream.Create(aFileName, DefaultOpenMode);
  try
    RMReadObjFromStream(F,aObj);
  finally
    F.Free;
  end;
end;

procedure RMWriteObjToFile(aObj:TPersistent;const aFilename:String);
Var
  F:TFileStream;
begin
  F:=TFileStream.Create(aFileName,fmcreate);
  try
    RMWriteObjToStream(F,aObj);
  finally
    F.Free;
  end;
end;

type
  THackWinControl = class(TWinControl)
  end;

procedure RMEnableControls(c: array of TControl; e: Boolean);
const
  Clr1: array[Boolean] of TColor = (clGrayText, clWindowText);
  Clr2: array[Boolean] of TColor = (clBtnFace, clWindow);
var
  i: Integer;
begin
  for i := Low(c) to High(c) do
  begin
    if c[i] is TLabel then
    begin
      with TLabel(c[i]) do
      begin
        Font.Color := Clr1[e];
        Enabled := e;
      end;
    end
    else if c[i] is TWinControl then
    begin
      with THackWinControl(c[i]) do
      begin
        Color := Clr2[e];
        Enabled := e;
      end;
    end
    else
      c[i].Enabled := e;
  end;
end;

function RMFindComponent(aOwner: TComponent; const aComponentName: string): TComponent;
var
  n: Integer;
  s1, s2: string;
begin
  Result := nil;
  if aComponentName = '' then Exit;

  n := Pos('.', aComponentName);
  try
    if n = 0 then
    begin
      if aOwner <> nil then
        Result := aOwner.FindComponent(aComponentName);
    end
    else
    begin
      s1 := Copy(aComponentName, 1, n - 1); // module name
      s2 := Copy(aComponentName, n + 1, 99999); // component name
      Result := RMFindComponent(FindGlobalComponent(s1), s2);
    end;
  except
    on Exception do
      raise EClassNotFound.Create('Missing ' + aComponentName);
  end;
end;

// --> Leon, 2004-10-10, 增加

function RMClassIsOk(aComponent: TComponent; aClassRef: TClass): boolean;
var
  lClass: TClass;
begin
  Result := aComponent is aClassRef;
  if not Result then
  begin
    lClass := aComponent.ClassType;
    while lClass <> nil do
    begin
      if lClass.ClassName = aClassRef.ClassName then
      begin
        Result := True;
        Break;
      end;

      lClass := lClass.ClassParent;
    end;
  end;
end;

{$HINTS OFF}

procedure RMGetComponents(aOwner: TComponent; aClassRef: TClass; aList: TStrings;
  aSkip: TComponent);
var
  i: Integer;
{$IFDEF COMPILER6_UP}
  j: Integer;
{$ENDIF}

  procedure _EnumComponents(aComponent: TComponent);
  var
    i: Integer;
    lComponent: TComponent;
    //(2004-12-9 0:08 PYZFL)
    lComponentName: string;
    lIsDataSet: Boolean;
  begin
{$IFDEF COMPILER5_UP}
    if aComponent is TForm then
    begin
      for i := 0 to TForm(aComponent).ControlCount - 1 do
      begin
        lComponent := TForm(aComponent).Controls[i];
        if lComponent is TFrame then
          _EnumComponents(lComponent);
      end;
    end;
{$ENDIF}

    for i := 0 to aComponent.ComponentCount - 1 do
    begin
      lComponent := aComponent.Components[i];
      //(2004-12-8 23:28 PYZFL)
      // 如果Visible=false，则在设计器中不显示。
      lIsDataSet := RMClassIsOk(lComponent, TRMDataset);
      if lIsDataSet and (not TRMDataset(lComponent).Visible) then Continue;
      if RMClassIsOk(lComponent, TRMDBDataSet) and (TRMDBDataSet(lComponent).DataSet = nil) then Continue;

      if (lComponent <> aSkip) and RMClassIsOk(lComponent, aClassRef) and
        ((lComponent.Name <> '') or (lIsDataSet and (TRMDataSet(lComponent).AliasName <> ''))) then
      begin
        if aComponent = aOwner then
          lComponentName := lComponent.Name
        else if ((aComponent is TForm) or (aComponent is TDataModule)) then
          lComponentName := aComponent.Name + '.' + lComponent.Name
        else
          lComponentName := TControl(aComponent).Parent.Name + '.' + aComponent.Name + '.' + lComponent.Name;

        if (lComponent is TRMDataset) and (TRMDataset(lComponent).AliasName <> '') then
          lComponentName := TRMDataset(lComponent).AliasName;
//          lComponentName := lComponentName + '-(' + TRMDataset(lComponent).AliasName + ')';

        aList.AddObject(lComponentName,lComponent);
      end;
    end;
  end;

begin
  aList.Clear;
  for i := 0 to Screen.CustomFormCount - 1 do
  begin
    if (Screen.CustomForms[i].Name <> 'RMDesignerForm') and
      (Screen.CustomForms[i].Name <> 'RMGridReportDesignerForm') then
      _EnumComponents(Screen.CustomForms[i]);
  end;
  for i := 0 to Screen.DataModuleCount - 1 do
    _EnumComponents(Screen.DataModules[i]);

{$IFDEF COMPILER6_UP}
  with Screen do
  begin
    for i := 0 to CustomFormCount - 1 do
    begin
      with CustomForms[i] do
      begin
        if (ClassName = 'TDataModuleForm') then
        begin
          for j := 0 to ComponentCount - 1 do
          begin
            if (Components[j] is TDataModule) then
              _EnumComponents(Components[j]);
          end;
        end;
      end;
    end;
  end;
{$ENDIF}
end;
{$HINTS ON}

function RMRemoveQuotes(const aStr: WideString): WideString;
begin
  if (Length(aStr) > 2) and (aStr[1] = '"') and (aStr[Length(aStr)] = '"') then
    Result := Copy(aStr, 2, Length(aStr) - 2)
  else
    Result := aStr;
end;

procedure RMSetCommaText(Text: string; sl: TStringList);
var
  i: Integer;

  function _ExtractCommaName(s: string; var Pos: Integer): string;
  var
    i: Integer;
  begin
    i := Pos;
    while (i <= Length(s)) and (s[i] <> ';') do
      Inc(i);
    Result := Copy(s, Pos, i - Pos);
    if (i <= Length(s)) and (s[i] = ';') then
      Inc(i);
    Pos := i;
  end;

begin
  i := 1;
  sl.Clear;
  while i <= Length(Text) do
    sl.Add(_ExtractCommaName(Text, i));
end;

type
  THackCanvas = class(TCanvas);

function RMWideCanvasTextExtent(aCanvas: TCanvas; const aText: WideString): TSize;
begin
  with THackCanvas(aCanvas) do
  begin
    RequiredState([csHandleValid, csFontValid]);

    Result.cx := 0;
    Result.cy := 0;
    Windows.GetTextExtentPoint32W(Handle, PWideChar(aText), Length(aText), Result);
  end;
end;

function RMWideCanvasTextWidth(aCanvas: TCanvas; const aText: WideString): Integer;
begin
  Result := RMWideCanvasTextExtent(aCanvas, aText).cx;
end;

function RMWideCanvasTextHeight(aCanvas: TCanvas; const aText: WideString): Integer;
begin
  Result := RMWideCanvasTextExtent(aCanvas, aText).cy;
end;

function RMCanvasWidth(const aStr: string; aFont: TFont): integer;
begin
  with TCanvas.Create do
  begin
    Handle := GetDC(0);
    Font.Assign(aFont);
    Result := TextWidth(aStr);
    ReleaseDC(0, Handle);
    Free;
  end;
end;

function RMCanvasHeight(const aStr: string; aFont: TFont): integer;
begin
  with TCanvas.Create do
  begin
    Handle := GetDC(0);
    Font.Assign(aFont);
    Result := TextHeight(aStr);
    ReleaseDC(0, Handle);
    Free;
  end;
end;

function RMWrapStrings(const aSrcLines: TWideStringList; aDstLines: TWideStringList;
  aCanvas: TCanvas; aWidth: Integer; const aLineSpacing: Integer;
  aWordBreak, aCharWrap, aAllowHtmlTag, aWidthFlag, aAddChar: Boolean): integer;
var
  i: Integer;
  lNewLine: WideString;
  lNewLineWidth: Integer;
  lNowHeight: Integer;
  lLineFinished: Boolean;
  lHtmlList: TRMHtmlList;
  lFontStack: TRMHtmlFontStack;
  lLineHeight: Integer;
  lAddFirstCharFlag: Boolean;

  function _TW(const aStr: WideString): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to Length(aStr) do
    begin
      Result := Result + RMWideCanvasTextHeight(aCanvas, aStr[i]);
    end;
  end;

  function _LineWidth(const aLine: WideString; aIsBreakWord: Boolean): integer;
  begin
    if aWidthFlag then
    begin
      Result := RMWideCanvasTextWidth(aCanvas, aLine);
      if aIsBreakWord then
        Result := Result div 2;
    end
    else
      Result := _TW(aLine);
  end;

  procedure _FlushLine;
  begin
    if lAddFirstCharFlag then
      lNewLine := #1 + lNewLine;

    aDstLines.Add(lNewLine);
    Inc(lNowHeight, lLineHeight {aOneLineHeight});
    lNewLine := '';
    lLineFinished := True;
    lNewLineWidth := 0;
    lAddFirstCharFlag := False;
  end;

  procedure _AddWord(aWord: WideString);
  var
//    i: Integer;
    lStr, lStr1: WideString;
    lPos: Integer;
    lCurWidth: Integer;
    lFlag: Boolean;
  begin
    if aWord = #1 then Exit;

    lFlag := False;
{    if aWordBreak and (lNewLine <> '') then
    begin
      for i := Low(RMChineseBreakChars) to High(RMChineseBreakChars) do
      begin
        if aWord = RMChineseBreakChars[i] then
        begin
          lFlag := True;
          Break;
        end;
      end;
    end;}

    lCurWidth := _LineWidth(aWord, lFlag);
    if lNewLineWidth + lCurWidth > aWidth then // 太长了，该换行了
    begin
      if lNewLine = '' then
      begin
        while True do
        begin
          lStr := Copy(aWord, 1, 1);
          lCurWidth := _LineWidth(lStr, False);
          if lNewLineWidth + lCurWidth < aWidth then
          begin
            lNewLine := lNewLine + lStr;
            Inc(lNewLineWidth, lCurWidth);
            Delete(aWord, 1, Length(lStr));
          end
          else
          begin
            if lNewLine = '' then
            begin
              lNewLine := lNewLine + lStr;
              Inc(lNewLineWidth, lCurWidth);
              Delete(aWord, 1, Length(lStr));
            end;
            Break;
          end;
        end; {while}
      end
      else if aCharWrap then
      begin
        lPos := 1;
        lStr := '';
        while lPos < Length(aWord) do
        begin
          lStr1 := Copy(aWord, lPos, 1);
          lPos := lPos + 1;
          lCurWidth := _LineWidth(lStr + lStr1, False);
          if lNewLineWidth + lCurWidth > aWidth then
            Break
          else
          begin
            lStr := lStr + lStr1;
          end;
        end;

        lNewLine := lNewLine + lStr;
        Inc(lNewLineWidth, _LineWidth(lStr, False));
        Delete(aWord, 1, Length(lStr));
      end
      else
      begin
        if aAddChar and (lNewLine <> '') and (lNewLine[1] <> #1) then
        begin
          lAddFirstCharFlag := True; // 实现自动调整间距功能
        end;
      end;

      _FlushLine;
      if Length(aWord) > 0 then
        _AddWord(aWord);
    end
    else
    begin
      lNewLine := lNewLine + aWord;
      Inc(lNewLineWidth, lCurWidth);
      if Length(aWord) > 0 then
        lLineFinished := False;
    end;
  end;

  procedure _AddOneLine(aStr: WideString);
  var
    i, lPos: Integer;
    lNextWord: WideString;
    lHtmlElement: PRMHtmlElement;
    lHtmlTagStr: WideString;

    procedure _AddOneStr;
    var
      i, lPos: Integer;
      //lAnsiStr: string;
    begin
      lPos := 0; {lAnsiStr := '';}
      while (lPos < Length(aStr)) and (Length(aStr) > 0) do
      begin
        repeat
          Inc(lPos);
          //lAnsiStr := aStr[lPos];
        until (Cardinal(aStr[lPos]) > $7F {Length(lAnsiStr) > 1}) or (AnsiChar(aStr[lPos]) in RMBreakChars) or (lPos >= Length(aStr));

        if aWordBreak and (lPos + 1 <= Length(aStr)) and (Cardinal(aStr[lPos]) > $7F {Length(lAnsiStr) > 1}) then
        begin
          lNextWord := Copy(aStr, lPos + 1, 1);
          if (lNewLineWidth > 0) and (lNewLineWidth + _LineWidth(Copy(aStr, 1, lPos) + lNextWord, False) > aWidth) then
          begin
            for i := Low(RMChineseBreakChars) to High(RMChineseBreakChars) do
            begin
              if lNextWord = RMChineseBreakChars[i] then
              begin
                if lNewLineWidth + _LineWidth(Copy(aStr, 1, lPos), False) + _LineWidth(lNextWord, False{True}) > aWidth then
                begin
                  if not aCharWrap then
                  begin
                    if aAddChar and (lNewLine <> '') and (lNewLine[1] <> #1) then
                      lAddFirstCharFlag := True; // 实现自动调整间距功能
                  end;

                  _FlushLine;
                end;

                Break;
              end; { liNextWord = RMChineseBreakChars[i] }
            end;
          end;
        end;

        _AddWord(Copy(aStr, 1, lPos));
        Delete(aStr, 1, lPos);
        lPos := 0;
      end;
    end;

  begin
    while Pos(#10, aStr) > 0 do
      Delete(aStr, Pos(#10, aStr), 1);

    lPos := Pos(#13, aStr);
    if lPos > 0 then
    begin
      repeat
        _AddOneLine(Copy(aStr, 1, lPos - 1));
        Delete(aStr, 1, lPos);
        lPos := Pos(#13, aStr);
      until lPos = 0;

      _AddOneLine(aStr);
      Exit;
    end;

    lHtmlTagStr := '';
    lNewLine := '';
    lLineFinished := False;
    lAddFirstCharFlag := (aStr <> '') and (aStr[1] = #1);
    if aAllowHtmlTag then
    begin
      RMHtmlAnalyseElement(aStr, lHtmlList);
      for i := 0 to lHtmlList.Count - 1 do
      begin
        lHtmlElement := lHtmlList[i];
        if lHtmlElement^.H_tag <> '' then
        begin
          RMHtmlSetFont(aCanvas.Font, lHtmlElement, lFontStack, rmdmDesigning, 1, nil);
          lHtmlTagStr := lHtmlTagStr + '<' + lHtmlElement.H_TagStr + '>';
        end
        else
        begin
          if lHtmlTagStr <> '' then
            lNewLine := lNewLine + lHtmlTagStr;

          lLineHeight := Max(lLineHeight, -aCanvas.Font.Height + aLineSpacing);
          aStr := lHtmlElement.H_str;
          _AddOneStr;
          lHtmlTagStr := '';
        end;
      end;

      if lHtmlTagStr <> '' then
      begin
        lNewLine := lNewLine + lHtmlTagStr;
        aStr := '';
        _AddWord('');
        lHtmlTagStr := '';
      end;
    end
    else
      _AddOneStr;

    if not lLineFinished then
      _FlushLine;
  end;

begin
  lNewLineWidth := 0;
  lNowHeight := 0;
  aDstLines.BeginUpdate;
  lLineFinished := False;
  lAddFirstCharFlag := False;

  lHtmlList := nil;
  lFontStack := nil;
  if aAllowHtmlTag then
  begin
    lHtmlList := TRMHtmlList.Create;
    lFontStack := TRMHtmlFontStack.Create;
  end;

  try
    for i := 0 to aSrcLines.Count - 1 do
    begin
      lLineHeight := -aCanvas.Font.Height + aLineSpacing;
      _AddOneLine(aSrcLines[i]);
    end;
  finally
    if lHtmlList <> nil then
      lHtmlList.Clear;

    lHtmlList.Free;
    lFontStack.Free;
    aDstLines.EndUpdate;
    Result := lNowHeight;
  end;
end;


(* -------------------------------------------------- *)
(* RMCurrToBIGNum  将阿拉伯数字转成中文数字字串
(* 使用示例:
(*   RMCurrToBIGNum(10002.34) ==> 一万零二圆三角四分
(* -------------------------------------------------- *)
const
  _ChineseNumeric: array[0..22] of string = (
    '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖', '拾', '佰', '仟',
    '万', '亿', '兆', '元', '角', '分', '厘', '点', '负', '整');

function RMCurrToBIGNum(Value: Currency): string;
var
  sArabic, sIntArabic: string;
  sSectionArabic, sSection: string;
  i, iDigit, iSection, iPosOfDecimalPoint: integer;
  bInZero, bMinus: boolean;
  lNeedAddZero: Boolean;

  function ConvertStr(const str: string): string; //将字串反向, 例如: 传入 '1234', 传回 '4321'
  var
    i: integer;
  begin
    Result := '';
    for i := Length(str) downto 1 do
      Result := Result + str[i];
  end;

begin
  Result := '';
  bInZero := True;
  sArabic := FloatToStr(Value); //将数字转成阿拉伯数字字串
  if sArabic[1] = '-' then
  begin
    bMinus := True;
    sArabic := Copy(sArabic, 2, 9999);
  end
  else
    bMinus := False;

  lNeedAddZero := False;
  iPosOfDecimalPoint := Pos('.', sArabic); //取得小数点的位置
  //先处理整数的部分
  if iPosOfDecimalPoint = 0 then
    sIntArabic := ConvertStr(sArabic)
  else
    sIntArabic := ConvertStr(Copy(sArabic, 1, iPosOfDecimalPoint - 1));

  //从个位数起以每四位数为一小节
  for iSection := 0 to ((Length(sIntArabic) - 1) div 4) do
  begin
    sSectionArabic := Copy(sIntArabic, iSection * 4 + 1, 4);
    sSection := '';
    for i := 1 to Length(sSectionArabic) do //以下的 i 控制: 个十百千位四个位数
    begin
      iDigit := Ord(sSectionArabic[i]) - 48;
      if iDigit = 0 then
      begin
        if (iSection = 0) and (i = 1) then
          lNeedAddZero := True;

        if (not bInZero) and (i <> 1) then
          sSection := _ChineseNumeric[0] + sSection;
        bInZero := True;
      end
      else
      begin
        case i of
          2: sSection := _ChineseNumeric[10] + sSection;
          3: sSection := _ChineseNumeric[11] + sSection;
          4: sSection := _ChineseNumeric[12] + sSection;
        end;
        sSection := _ChineseNumeric[iDigit] + sSection;
        bInZero := False;
      end;
    end;

    //加上该小节的位数
    if Length(sSection) = 0 then
    begin
      if (Length(Result) > 0) and (Copy(Result, 1, 2) <> _ChineseNumeric[0]) then
        Result := _ChineseNumeric[0] + Result;
    end
    else
    begin
      case iSection of
        0: Result := sSection + Result;
        1: Result := sSection + _ChineseNumeric[13] + Result;
        2: Result := sSection + _ChineseNumeric[14] + Result;
        3: Result := sSection + _ChineseNumeric[15] + Result;
      end;
    end;
  end;

  if Length(Result) > 0 then
    Result := Result + _ChineseNumeric[16];
  if iPosOfDecimalPoint > 0 then //处理小数部分
  begin
    if lNeedAddZero then // 需要加"零", 107000.53:壹拾万柒仟元零伍角叁分
      Result := Result + _ChineseNumeric[0];

    for i := iPosOfDecimalPoint + 1 to Length(sArabic) do
    begin
      iDigit := Ord(sArabic[i]) - 48;
      if not ((iDigit = 0) and lNeedAddZero) then
        Result := Result + _ChineseNumeric[iDigit];
        
      case i - (iPosOfDecimalPoint + 1) of
        0:
          begin
            if iDigit > 0 then
              Result := Result + _ChineseNumeric[17];
          end;
        1: Result := Result + _ChineseNumeric[18];
        2: Result := Result + _ChineseNumeric[19];
      end;
    end;
  end;

  //其他例外状况的处理
  if Length(Result) = 0 then
    Result := _ChineseNumeric[0];
  //  if Copy(Result, 1, 4) = _ChineseNumeric[1] + _ChineseNumeric[10] then
  //    Result := Copy(Result, 3, 254);
  if Copy(Result, 1, 2) = _ChineseNumeric[20] then
    Result := _ChineseNumeric[0] + Result;

  if bMinus then
    Result := _ChineseNumeric[21] + Result;
  if ((Round(Value * 100)) div 1) mod 10 = 0 then
    Result := Result + _ChineseNumeric[22];
end;

function RMChineseNumber(const jnum: string): string;
var
  hjnum: real;
  Vstr, zzz, cc, cc1, Presult: string;
  xxbb: array[1..12] of string;
  uppna: array[0..9] of string;
  iCount, iZero {,vpoint}: integer;
begin
  hjnum := strtofloat(jnum);
  Result := '';
  presult := '';
  if hjnum < 0 then
  begin
    hjnum := -hjnum;
    Result := '负';
  end;

  xxbb[1] := '亿';
  xxbb[2] := '千';
  xxbb[3] := '百';
  xxbb[4] := '十';
  xxbb[5] := '万';
  xxbb[6] := '千';
  xxbb[7] := '百';
  xxbb[8] := '十';
  xxbb[9] := '一';
  xxbb[10] := '.';
  xxbb[11] := '';
  xxbb[12] := '';

  uppna[0] := '零';
  uppna[1] := '一';
  uppna[2] := '二';
  uppna[3] := '三';
  uppna[4] := '四';
  uppna[5] := '五';
  uppna[6] := '六';
  uppna[7] := '七';
  uppna[8] := '八';
  uppna[9] := '九';

  Str(hjnum: 12: 2, Vstr);
  cc := '';
  cc1 := '';
  zzz := '';

  iZero := 0;
  //  vPoint:=0;
  for iCount := 1 to 10 do
  begin
    cc := Vstr[iCount];
    if cc <> ' ' then
    begin
      zzz := xxbb[iCount];
      if cc = '0' then
      begin
        if iZero < 1 then //*对“零”进行判断*//
          cc := '零'
        else
          cc := '';
        if iCount = 5 then //*对万位“零”的处理*//
          if copy(Result, length(Result) - 1, 2) = '零' then
            Result := copy(Result, 1, length(Result) - 2) + xxbb[iCount] + '零'
          else
            Result := Result + xxbb[iCount];
        cc1 := cc;
        zzz := '';
        iZero := iZero + 1;
      end
      else
      begin
        if cc = '.' then
        begin
          cc := '';
          if (cc1 = '') or (cc1 = '零') then
          begin
            Presult := copy(Result, 1, Length(Result) - 2);
            Result := Presult;
            iZero := 15;
          end;
          zzz := '';
        end
        else
        begin
          iZero := 0;
          cc := uppna[StrToInt(cc)];
        end
      end;
      Result := Result + (cc + zzz)
    end;
  end;

  if Vstr[11] = '0' then //*对小数点后两位进行处理*//
  begin
    if Vstr[12] <> '0' then
    begin
      cc := '点';
      Result := Result + cc;
      cc := uppna[StrToInt(Vstr[12])];
      Result := Result + (uppna[0] + cc + xxbb[12]);
    end
  end
  else
  begin
    if iZero = 15 then
    begin
      cc := '点';
      Result := Result + cc;
    end;
    cc := uppna[StrToInt(Vstr[11])];
    Result := Result + (cc + xxbb[11]);
    if Vstr[12] <> '0' then
    begin
      cc := uppna[StrToInt(Vstr[12])];
      Result := Result + (cc + xxbb[12]);
    end;
  end;

  if Copy(Result, 1, 4) = '一十' then
    Delete(Result, 1, 2);
end;

function RMSmallToBig(curs: string): string;
var
  Small, Big: string;
  wei: string[2];
  i: integer;
begin
  small := trim(curs);
  Big := '';
  for i := 1 to length(Small) do
  begin
    case strtoint(small[i]) of {位置上的数转换成大写}
      1: wei := '壹';
      2: wei := '贰';
      3: wei := '叁';
      4: wei := '肆';
      5: wei := '伍';
      6: wei := '陆';
      7: wei := '柒';
      8: wei := '捌';
      9: wei := '玖';
      0: wei := '零';
    end;

    Big := Big + wei; {组合成大写}
  end;

  Result := Big;
end;

procedure RMSetFontSize(aComboBox: TComboBox; aFontHeight, aFontSize: integer);
var
  i: integer;
begin
  for i := Low(RMDefaultFontSize) to High(RMDefaultFontSize) do
  begin
    if RMDefaultFontSize[i] = aFontHeight then
    begin
      if RMIsChineseGB then
        aComboBox.Text := RMDefaultFontSizeStr[i]
      else
        aComboBox.Text := RMDefaultFontSizeStr[i + 13];

      Exit;
    end;
  end;

  aComboBox.Text := IntToStr(aFontSize);
end;

procedure RMSetFontSize1(aListBox: TListBox; aFontSize: integer);
var
  i: integer;
begin
  for i := Low(RMDefaultFontSize) to High(RMDefaultFontSize) do
  begin
    if RMDefaultFontSize[i] = aFontSize then
    begin
      if RMIsChineseGB then
        aListBox.ItemIndex := i
      else
        aListBox.ItemIndex := i + 13;

      Break;
    end;
  end;
end;

function RMGetFontSize(aComboBox: TComboBox): integer;
begin
  if aComboBox.ItemIndex >= 0 then
  begin
    if aComboBox.ItemIndex <= High(RMDefaultFontSize) then
      Result := RMDefaultFontSize[aComboBox.ItemIndex]
    else
      Result := StrToInt(aComboBox.Text);
  end
  else
  begin
    try
      Result := StrToInt(aComboBox.Text);
    except
      Result := 0;
    end;
  end;
end;

function RMGetFontSize1(aIndex: Integer; aText: string): integer;
begin
  if aIndex >= 0 then
  begin
    if aIndex <= High(RMDefaultFontSize) then
      Result := RMDefaultFontSize[aIndex]
    else
      Result := StrToInt(aText);
  end
  else
  begin
    try
      Result := StrToInt(aText);
    except
      Result := 0;
    end;
  end;
end;

function RMCreateBitmap(const ResName: string): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Handle := LoadBitmap(HInstance, PChar(ResName));
end;

procedure RMSetStrProp(aObject: TObject; const aPropName: string; ID: Integer);
var
  lStr: string;
  lPropInfo: PPropInfo;
begin
  lStr := RMLoadStr(ID);
  if lStr <> '' then
  begin
    lPropInfo := GetPropInfo(aObject.ClassInfo, aPropName);
    if lPropInfo <> nil then
      SetStrProp(aObject, lPropInfo, lStr);
  end;
end;

function RMGetPropValue(aReport: TRMReport; const aObjectName, aPropName: string): Variant;
var
  pi: PPropInfo;
  lObject: TObject;
begin
  Result := varEmpty;
  if aReport <> nil then
    lObject := RMFindComponent(aReport.Owner, aObjectName)
  else
    lObject := RMFindComponent(nil, aObjectName);

  if lObject <> nil then
  begin
    pi := GetPropInfo(lObject.ClassInfo, aPropName);
    if pi <> nil then
    begin
      case pi.PropType^.Kind of
        tkString, tkLString, tkWString:
          Result := GetStrProp(lObject, pi);
        tkInteger, tkEnumeration:
          Result := GetOrdProp(lObject, pi);
        tkFloat:
          Result := GetFloatProp(lObject, pi);
      end;
    end;
  end;
end;

function RMRound(x: Extended; dicNum: Integer): Extended; //四舍五入
var
  tmp: string;
  i: Integer;
begin
  if dicNum = 0 then
  begin
    Result := Round(x);
    Exit;
  end;

  tmp := '#.';
  for i := 1 to dicNum do
    tmp := tmp + '0';
  Result := StrToFloat(FormatFloat(tmp, x));
end;

function RMMakeFileName(AFileName, AFileExtension: string; ANumber: Integer): string;
var
  FileName: string;
begin
  FileName := ChangeFileExt(ExtractFileName(AFileName), '');
  Result := Format('%s%.4d.%s', [FileName, ANumber, AFileExtension]);
end;

function RMAppendTrailingBackslash(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + '\';
end;

function RMColorBGRToRGB(AColor: TColor): string;
begin
  Result := IntToHex(ColorToRGB(AColor), 6);
  Result := Copy(Result, 5, 2) + Copy(Result, 3, 2) + Copy(Result, 1, 2);
end;

function RMMakeImgFileName(AFileName, AFileExtension: string; ANumber: Integer): string;
var
  FileName: string;
begin
  FileName := ChangeFileExt(ExtractFileName(AFileName), '');
  Result := Format('%s_I%.4d.%s', [FileName, ANumber, AFileExtension]);
end;

procedure RMSetControlsEnable(AControl: TWinControl; AState: Boolean);
const
  StateColor: array[Boolean] of TColor = (clInactiveBorder, clWindow);
var
  I: Integer;
begin
  with AControl do
    for I := 0 to ControlCount - 1 do
    begin
      if ((Controls[I] is TWinControl) and
        (TWinControl(Controls[I]).ControlCount > 0)) then
        RMSetControlsEnable(TWinControl(Controls[I]), AState);
      if (Controls[I] is TCustomEdit) then
        THackWinControl(Controls[I]).Color := StateColor[AState]
      else if (Controls[I] is TCustomComboBox) then
        THackWinControl(Controls[I]).Color := StateColor[AState];
      Controls[I].Enabled := AState;
    end;
end;

procedure RMSaveFormPosition(aParentKey: string; aForm: TForm);
var
  Ini: TRegIniFile;
  Name: string;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + aParentKey);
  Name := rsForm + aForm.ClassName;
  Ini.WriteInteger(Name, rsX, aForm.Left);
  Ini.WriteInteger(Name, rsY, aForm.Top);
  Ini.WriteInteger(Name, rsWidth, aForm.Width);
  Ini.WriteInteger(Name, rsHeight, aForm.Height);
  Ini.WriteBool(Name, rsMaximized, aForm.WindowState = wsMaximized);
  Ini.Free;
end;

procedure RMRestoreFormPosition(aParentKey: string; aForm: TForm);
var
  lIni: TRegIniFile;
  lName: string;
  lMaximized: Boolean;
begin
  lIni := TRegIniFile.Create(RMRegRootKey + aParentKey);
  try
    lName := rsForm + aForm.ClassName;
    lMaximized := lIni.ReadBool(lName, rsMaximized, True);
    if not lMaximized then
      aForm.WindowState := wsNormal;

    aForm.SetBounds(lIni.ReadInteger(lName, rsX, aForm.Left),
      lIni.ReadInteger(lName, rsY, aForm.Top),
      lIni.ReadInteger(lName, rsWidth, aForm.Width),
      lIni.ReadInteger(lName, rsHeight, aForm.Height));
  finally
    lIni.Free;
  end;
end;

procedure RMGetBitmapPixels(aGraphic: TGraphic; var x, y: Integer);
var
  mem: TMemoryStream;
  FileBMPHeader: TBitMapFileHeader;

  procedure _GetBitmapHeader;
  var
    bmHeadInfo: PBITMAPINFOHEADER;
  begin
    try
      GetMem(bmHeadInfo, Sizeof(TBITMAPINFOHEADER));
      mem.ReadBuffer(bmHeadInfo^, Sizeof(TBITMAPINFOHEADER));
      x := Round(bmHeadInfo.biXPelsPerMeter / 39);
      y := Round(bmHeadInfo.biYPelsPerMeter / 39);
      FreeMem(bmHeadInfo, Sizeof(TBITMAPINFOHEADER));
    finally
      if x < 1 then
        x := 96;
      if y < 1 then
        y := 96;
    end;
  end;

begin
  x := 96;
  y := 96;
  mem := TMemoryStream.Create;
  try
    aGraphic.SaveToStream(mem);
    mem.Position := 0;

    if (mem.Read(FileBMPHeader, Sizeof(TBITMAPFILEHEADER)) = Sizeof(TBITMAPFILEHEADER)) and
      (FileBMPHeader.bfType = $4D42) then
    begin
      _GetBitmapHeader;
    end;
  finally
    mem.Free;
  end;
end;

function RMGetWindowsVersion: string;
var
  Ver: TOsVersionInfo;
begin
  Ver.dwOSVersionInfoSize := SizeOf(Ver);
  GetVersionEx(Ver);
  with Ver do
  begin
    case dwPlatformId of
      VER_PLATFORM_WIN32s: Result := '32s';
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          dwBuildNumber := dwBuildNumber and $0000FFFF;
          if (dwMajorVersion > 4) or ((dwMajorVersion = 4) and
            (dwMinorVersion >= 10)) then
            Result := '98'
          else
            Result := '95';
        end;
      VER_PLATFORM_WIN32_NT: Result := 'NT';
    end;
  end;
end;

{$IFNDEF COMPILER6_UP}

function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;
{$ENDIF}

function RMGetTmpFileName: string;
var
  lTempDir: array[0..1024] of char;
  lTempFile: array[0..1024] of char;
begin
  Result := '';
  if GetTempPath(sizeof(lTempDir), lTempDir) = 0 then Exit;

  StrPCopy(lTempDir, StrPas(lTempDir) + 'ReportMachine\');
  if not DirectoryExists(StrPas(lTempDir)) then
    SysUtils.CreateDir(StrPas(lTempDir));

  if GetTempFileName(lTempDir, '_rm_', 0, lTempFile) = 0 then Exit;

  Result := StrPas(lTempFile);
end;

function RMGetTmpFileName(aExt: string): string;
var
  lTempDir: array[0..1024] of char;
  lStr: string;
begin
  Result := '';
  if GetTempPath(sizeof(lTempDir), lTempDir) = 0 then Exit;

  StrPCopy(lTempDir, StrPas(lTempDir) + 'ReportMachine\');
  if not DirectoryExists(StrPas(lTempDir)) then
    SysUtils.CreateDir(StrPas(lTempDir));

  while True do
  begin
    lStr := StrPas(lTempDir) + '_rm_' + IntToStr(GetTickCount) + aExt;
    if not SysUtils.FileExists(lStr) then
    begin
      Result := lStr;
      Break;
    end;
  end;
end;

function RMMonth_EnglishShort(aMonth: Integer): string;
begin
  Result := '';
  if (aMonth < 1) or (aMonth > 12) then
    Exit;
  case aMonth of
    1: Result := SShortMonthNameJan;
    2: Result := SShortMonthNameFeb;
    3: Result := SShortMonthNameMar;
    4: Result := SShortMonthNameApr;
    5: Result := SShortMonthNameMay;
    6: Result := SShortMonthNameJun;
    7: Result := SShortMonthNameJul;
    8: Result := SShortMonthNameAug;
    9: Result := SShortMonthNameSep;
    10: Result := SShortMonthNameOct;
    11: Result := SShortMonthNameNov;
    12: Result := SShortMonthNameDec;
  end;
end;

function RMMonth_EnglishLong(aMonth: Integer): string;
begin
  Result := '';
  if (aMonth < 1) or (aMonth > 12) then
    Exit;
  case aMonth of
    1: Result := SLongMonthNameJan;
    2: Result := SLongMonthNameFeb;
    3: Result := SLongMonthNameMar;
    4: Result := SLongMonthNameApr;
    5: Result := SLongMonthNameMay;
    6: Result := SLongMonthNameJun;
    7: Result := SLongMonthNameJul;
    8: Result := SLongMonthNameAug;
    9: Result := SLongMonthNameSep;
    10: Result := SLongMonthNameOct;
    11: Result := SLongMonthNameNov;
    12: Result := SLongMonthNameDec;
  end;
end;

function RMNumToBig(Value: Integer): string;
var
  i: Integer;
  lBigNums, lstr: string;
begin
  Result := '';
  if Value = 0 then
  begin
    Result := '○'; //'０';
    Exit
  end;

  lBigNums := '○一二三四五六七八九十'; //'０一二三四五六七八九十';
  lstr := IntTostr(Value);
  for i := 1 to Length(lStr) do
    Result := Result + Copy(lBigNums, StrToInt(lstr[i]) * 2 + 1, 2);
end;

function RMSinglNumToBig(Value: Extended; Digit: Integer): string;
var
  lBigNums, lstr: string;
  lPos: Integer;
begin
  Result := '';
  if Digit = 0 then
    Exit;
  lBigNums := '零壹贰叁肆伍陆柒捌玖';
  lstr := FloatTostr(Value);
  lPos := Pos('.', lstr) - Digit;

  if (lPos > 0) and (lPos < Length(lstr)) then
    Result := copy(lBigNums, StrToInt(lstr[lPos]) * 2 + 1, 2);
end;

{***************************函数头部说明******************************
// 单元名称 : Unit1
// 函数名称 :HexByte
// 函数实现目标：
// 参    数 :b: Byte
// 返回值   :string
// 作    者 :  ＳＩＮＭＡＸ           　　　　　  　　　　　
// 　　　　 "._`-.　　　　 (\-.　          Http://SinMax.yeah.net
// 　　　　　　'-.`;.--.___/ _`>　      　 Email:SinMax@163.net
// 　　　　　　　 `"( )　　, ) 　      　　　　
// 　　　　　　　　　\\----\-\　       　　　==== 郎  正 ====  　
// 　　　 ~~ ~~~~~~ "" ~~ """ ~~~~~~~~~　　
// 创建日期 :  2002-07-26
// 工作路径 :  C:\Documents and Settings\Administrator\桌面\File2Str\
// 修改记录 :
// 备   注 :
********************************************************************}

function HexByte(b: Byte): string;
const
  HexDigs: array[0..15] of char = '0123456789ABCDEF';
var
  bz: Byte;
begin
  bz := b and $F;
  b := b shr 4;
  HexByte := HexDigs[b] + HexDigs[bz];
end;

{***************************函数头部说明******************************
// 单元名称 : Unit1
// 函数名称 :File2TXT
// 函数实现目标：文件转为流
// 参    数 :Filename:String
// 返回值   :AnsiString
// 作    者 :  ＳＩＮＭＡＸ           　　　　　  　　　　　
// 　　　　 "._`-.　　　　 (\-.　          Http://SinMax.yeah.net ;
// 　　　　　　'-.`;.--.___/ _`>　      　 Email:SinMax@163.net
// 　　　　　　　 `"( )　　, ) 　      　　　　
// 　　　　　　　　　\\----\-\　       　　　==== 郎  正 ====  　
// 　　　 ~~ ~~~~~~ "" ~~ """ ~~~~~~~~~　　
// 创建日期 :  2002-07-26
// 工作路径 :  D:\报表客户端\计算\
// 修改记录 :
// 备   注 :
********************************************************************}
//load

function RMStream2TXT(aStream: TStream): AnsiString;
var
  lStr: AnsiString;
  Arec: char;
  i: integer;
begin
  lStr := '';
  aStream.Position := 0;
  for i := 0 to aStream.Size - 1 do
  begin
    aStream.Read(arec, 1);
    lStr := lStr + HexByte(Ord(Arec));
  end;
  lStr := lStr + '#';
  Result := lStr;
end;

{***************************函数头部说明******************************
// 单元名称 : Unit1
// 函数名称 :TForm1.TXT2File
// 函数实现目标：流转为文件
// 参    数 :inStr:AnsiString;Filename:String
// 返回值   :Boolean
// 作    者 :  ＳＩＮＭＡＸ           　　　　　  　　　　　
// 　　　　 "._`-.　　　　 (\-.　          Http://SinMax.yeah.net ;
// 　　　　　　'-.`;.--.___/ _`>　      　 Email:SinMax@163.net
// 　　　　　　　 `"( )　　, ) 　      　　　　
// 　　　　　　　　　\\----\-\　       　　　==== 郎  正 ====  　
// 　　　 ~~ ~~~~~~ "" ~~ """ ~~~~~~~~~　　
// 创建日期 :  2002-07-26
// 工作路径 :  D:\报表客户端\计算\
// 修改记录 :
// 备   注 :
********************************************************************}

function RMTXT2Stream(inStr: AnsiString; OutStream: TStream): Boolean;
var
  i, DEC: integer;
  lChar: Char;
begin
  Result := False;
  if inStr = '' then
  begin
    Result := True;
    Exit;
  end;

  i := 1;
  try
    while not (inStr[i] = '#') do
    begin
      DEC := StrtoInt(('$' + inStr[i])) * 16 + StrtoInt('$' + inStr[i + 1]);
      lChar := Chr(dec);
      OutStream.Write(lChar, 1);
      i := i + 2;
    end;
    Result := True;
  except
  end
end;

function RMLoadStr(aResID: Integer): string;
begin
  Result := RMResourceManager.LoadStr(aResID);
end;

function RMStrToFloat(aStr: string): Double;
begin
  aStr := RMDeleteNoNumberChar(aStr);
  Result := 0;
  try
    Result := StrToFloat(aStr);
  except
  end;
end;

{$HINTS OFF}

function RMIsValidFloat(aStr: string): Boolean;
begin
  Result := True;
  try
    RMStrToFloat(aStr);
  except
    Result := False;
  end;
end;

function RMisNumeric(aStr: string): Boolean;
var
  R: Double;
  E: Integer;
begin
  Val(aStr, R, E);
  Result := (E = 0);
end;
{$HINTS ON}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDeviceCompatibleCanvas }

constructor TRMDeviceCompatibleCanvas.Create(aReferenceDC: HDC; aWidth, aHeight: Integer; aPalette: HPalette);
begin
  inherited Create;

  FReferenceDC := aReferenceDC;
  FWidth := aWidth;
  FHeight := aHeight;

  FSavePalette := 0;
  FRestorePalette := False;

  FCompatibleDC := CreateCompatibleDC(FReferenceDC);

  FCompatibleBitmap := CreateCompatibleBitmap(FReferenceDC, aWidth, aHeight);
  FOldBitMap := SelectObject(FCompatibleDC, FCompatibleBitmap);

  if aPalette <> 0 then
  begin
    FSavePalette := SelectPalette(FCompatibleDC, aPalette, False);
    RealizePalette(FCompatibleDC);
    FRestorePalette := True;
  end
  else
  begin
    FSavePalette := SelectPalette(FCompatibleDC, SystemPalette16, False);
    RealizePalette(FCompatibleDC);
    FRestorePalette := True;
  end;

  PatBlt(FCompatibleDC, 0, 0, aWidth, aHeight, WHITENESS);
  SetMapMode(FCompatibleDC, MM_TEXT);
end;

destructor TRMDeviceCompatibleCanvas.Destroy;
begin
  if FRestorePalette then
    SelectPalette(FReferenceDC, FSavePalette, False);

  FReferenceDC := 0;
  Handle := 0;
  if FCompatibleDC <> 0 then
  begin
    SelectObject(FCompatibleDC, FOldBitMap);
    DeleteObject(FCompatibleBitmap);
    DeleteDC(FCompatibleDC);
  end;

  inherited Destroy;
end;

procedure TRMDeviceCompatibleCanvas.CreateHandle;
begin
  UpdateFont;
  Handle := FCompatibleDC;
end;

procedure TRMDeviceCompatibleCanvas.Changing;
begin
  inherited Changing;
  UpdateFont;
end;

procedure TRMDeviceCompatibleCanvas.UpdateFont;
var
  lFontSize: Integer;
  liDevicePixelsPerInch: Integer;
begin
  liDevicePixelsPerInch := GetDeviceCaps(FReferenceDC, LOGPIXELSY);
  if (liDevicePixelsPerInch <> Font.PixelsPerInch) then
  begin
    lFontSize := Font.Size;
    Font.PixelsPerInch := liDevicePixelsPerInch;
    Font.Size := lFontSize;
  end;
end;

procedure TRMDeviceCompatibleCanvas.RenderToDevice(aDestRect: TRect; aPalette: HPalette; aCopyMode: TCopyMode);
var
  lSavePalette: HPalette;
  lbRestorePalette: Boolean;
begin
  lSavePalette := 0;
  lbRestorePalette := False;
  if aPalette <> 0 then
  begin
    lSavePalette := SelectPalette(FReferenceDC, aPalette, False);
    RealizePalette(FReferenceDC);
    lbRestorePalette := True;
  end;

  BitBlt(FReferenceDC,
    aDestRect.Left, aDestRect.Top, aDestRect.Right - aDestRect.Left, aDestRect.Bottom - aDestRect.Top,
    FCompatibleDC, 0, 0, aCopyMode);

  if lbRestorePalette then
    SelectPalette(FReferenceDC, lSavePalette, False);
end;

// Draw Bitmap

procedure _DrawDIBitmap(aCanvas: TCanvas; const aDestRect: TRect; aBitmap: TBitmap;
  aCopyMode: TCopyMode);
var
  lBitmapHeader: pBitmapInfo;
  HBitmapHeader: HGLOBAL;
  lBitmapImage: Pointer;
  HBitmapImage: HGLOBAL;
  lHeaderSize: DWORD;
  lImageSize: DWORD;
begin
  GetDIBSizes(aBitmap.Handle, lHeaderSize, lImageSize);

//  GetMem(lBitmapHeader, lHeaderSize);
//  GetMem(lBitmapImage, lImageSize);
  HBitmapHeader := GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE, lHeaderSize);
  lBitmapHeader := PBitmapInfo(GlobalLock(HBitmapHeader));
  try
    HBitmapImage := GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE, lImageSize);
    lBitmapImage := Pointer(GlobalLock(HBitmapImage));
    try
      GetDIB(aBitmap.Handle, aBitmap.Palette, lBitmapHeader^, lBitmapImage^);
      SetStretchBltMode(aCanvas.Handle, STRETCH_DELETESCANS);
      StretchDIBits(aCanvas.Handle, aDestRect.Left, aDestRect.Top,
        aDestRect.Right - aDestRect.Left, aDestRect.Bottom - aDestRect.Top,
        0, 0, aBitmap.Width, aBitmap.Height, lBitmapImage, TBitmapInfo(lBitmapHeader^),
        DIB_RGB_COLORS, aCopyMode);
    finally
      GlobalUnlock(HBitmapImage);
      GlobalFree(HBitmapImage);
    end;
  finally
    GlobalUnlock(HBitmapHeader);
    GlobalFree(HBitmapHeader);
    //FreeMem(lBitmapImage);
    //FreeMem(lBitmapHeader);
  end;
end;

procedure _DrawTransparentDIBitmap(aCanvas: TCanvas; const aDestRect: TRect; aBitmap: TBitmap;
  aCopyMode: TCopyMode);
var
  lRasterCaps: Integer;
  lStretchBlt: Boolean;

  function _TransparentStretchBlt(aDstDC: HDC; aDstX, aDstY, aDstW, aDstH: Integer;
    aSrcDC: HDC; aSrcX, aSrcY, aSrcW, aSrcH: Integer; aMaskDC: HDC; aMaskX, aMaskY: Integer): Boolean;
  var
    lMemDC: HDC;
    lMemBmp: HBITMAP;
    lSaveBmp: HBITMAP;
    lSavePal: HPALETTE;
    lSaveTextColor, lSaveBkColor: TColorRef;
  begin
    Result := True;
    lSavePal := 0;
    lMemDC := CreateCompatibleDC(aSrcDC);
    try
      lMemBmp := CreateCompatibleBitmap(aSrcDC, aSrcW, aSrcH);
      lSaveBmp := SelectObject(lMemDC, lMemBmp);

      lSavePal := SelectPalette(aSrcDC, SystemPalette16, False);
      SelectPalette(aSrcDC, lSavePal, False);
      if lSavePal <> 0 then
        lSavePal := SelectPalette(lMemDC, lSavePal, True)
      else
        lSavePal := SelectPalette(lMemDC, SystemPalette16, True);

      RealizePalette(lMemDC);
      StretchBlt(lMemDC, 0, 0, aSrcW, aSrcH, aMaskDC, aMaskX, aMaskY, aSrcW, aSrcH, SrcCopy);
      StretchBlt(lMemDC, 0, 0, aSrcW, aSrcH, aSrcDC, aSrcX, aSrcY, aSrcW, aSrcH, SrcErase);

      lSaveTextColor := SetTextColor(aDstDC, $0);
      lSaveBkColor := SetBkColor(aDstDC, $FFFFFF);

      StretchBlt(aDstDC, aDstX, aDstY, aDstW, aDstH, aMaskDC, aMaskX, aMaskY, aSrcW, aSrcH, SrcAnd);
      StretchBlt(aDstDC, aDstX, aDstY, aDstW, aDstH, lMemDC, 0, 0, aSrcW, aSrcH, SrcInvert);

      SetTextColor(aDstDC, lSaveTextColor);
      SetBkColor(aDstDC, lSaveBkColor);
      if lSaveBmp <> 0 then
        SelectObject(lMemDC, lSaveBmp);

      DeleteObject(lMemBmp);
    finally
      if lSavePal <> 0 then
        SelectPalette(lMemDC, lSavePal, False);

      DeleteDC(lMemDC);
    end;
  end;

  procedure _DrawTransparentDIBitmapUsingStretchBlt(aCanvas: TCanvas; const aRect: TRect; aBitmap: TBitmap; aCopyMode: TCopyMode);
  var
    lDrawWidth: Integer;
    lDrawHeight: Integer;
    lBitmapWidth: Integer;
    lBitmapHeight: Integer;
    lMaskBmp: TBitmap;
    lMaskCanvas: TRMDeviceCompatibleCanvas;
    lMemCanvas: TRMDeviceCompatibleCanvas;
    lDeviceBPP: Integer;
  begin
    lDrawWidth := aRect.Right - aRect.Left;
    lDrawHeight := aRect.Bottom - aRect.Top;

    lDeviceBPP := GetDeviceCaps(aCanvas.Handle, BITSPIXEL) * GetDeviceCaps(aCanvas.Handle, PLANES);
    if lDeviceBPP = 1 then
    begin
      lBitmapWidth := aRect.Right - aRect.Left;
      lBitmapHeight := aRect.Bottom - aRect.Top;
    end
    else
    begin
      lBitmapWidth := aBitmap.Width;
      lBitmapHeight := aBitmap.Height;
    end;

    lMaskBmp := nil;
    lMaskCanvas := nil;
    lMemCanvas := nil;
    try
      lMemCanvas := TRMDeviceCompatibleCanvas.Create(aCanvas.Handle, lBitmapWidth, lBitmapHeight,
        aBitmap.Palette);
      _DrawDIBitmap(lMemCanvas, Rect(0, 0, lBitmapWidth, lBitmapHeight), aBitmap, cmSrcCopy);

      lMaskBmp := TBitmap.Create;
      lMaskBmp.Assign(aBitmap);
      lMaskBmp.Mask(clWhite);
      lMaskCanvas := TRMDeviceCompatibleCanvas.Create(aCanvas.Handle, lBitmapWidth,
        lBitmapHeight, aBitmap.Palette);

      _DrawDIBitmap(lMaskCanvas, Rect(0, 0, lBitmapWidth, lBitmapHeight), lMaskBmp, cmSrcCopy);
      aCanvas.Brush.Style := bsClear;
      _TransparentStretchBlt(aCanvas.Handle, aRect.Left, aRect.Top,
        lDrawWidth, lDrawHeight,
        lMemCanvas.Handle, 0, 0, lBitmapWidth, lBitmapHeight,
        lMaskCanvas.Handle, 0, 0);
    finally
      lMaskBmp.Free;
      lMaskCanvas.Free;
      lMemCanvas.Free;
    end;
  end;

begin
  lRasterCaps := GetDeviceCaps(aCanvas.Handle, RASTERCAPS);
  lStretchBlt := (lRasterCaps and RC_STRETCHBLT) > 0;
  if lStretchBlt then
    _DrawTransparentDIBitmapUsingStretchBlt(aCanvas, aDestRect, aBitmap, aCopyMode)
  else
    _DrawDIBitmap(aCanvas, aDestRect, aBitmap, aCopyMode);
end;

procedure RMPrintGraphic(const aCanvas: TCanvas; aDestRect: TRect; const aGraphic: TGraphic;
  aIsPrinting: Boolean; aDirectDraw: Boolean; aTransparent: Boolean);
var
  lBmp: TBitmap;
  lFreeBitmap: Boolean;

  procedure _GetAsBitmap;
  begin
    lBmp := TBitmap.Create;
    try
      lBmp.Width := aGraphic.Width;
      lBmp.Height := aGraphic.Height;
      lBmp.Palette := aGraphic.Palette;
      lBmp.HandleType := bmDIB;
      lBmp.Canvas.Draw(0, 0, aGraphic);
      lFreeBitmap := True;
    except
      try
        lBmp.Width := Trunc(aGraphic.Width * 0.25);
        lBmp.Height := Trunc(aGraphic.Height * 0.25);
        lBmp.Palette := aGraphic.Palette;
        lBmp.HandleType := bmDIB;
        lBmp.Canvas.StretchDraw(Rect(0, 0, lBmp.Width, lBmp.Height), aGraphic);
      except
        FreeAndNil(lBmp);
        lFreeBitmap := False;
      end;
    end;
  end;

  procedure _DirectDrawImage(aGraphic: TGraphic);
  begin
    if aTransparent then
      aCanvas.CopyMode := cmSrcAnd
    else
      aCanvas.CopyMode := cmSrcCopy;

    aCanvas.StretchDraw(aDestRect, aGraphic);
  end;

  procedure _DrawGraphic(aGraphic: TGraphic);
  var
    lMemCanvas: TRMDeviceCompatibleCanvas;
    lCopyMode: TCopyMode;
  begin
    lMemCanvas := TRMDeviceCompatibleCanvas.Create(aCanvas.Handle,
      aDestRect.Right - aDestRect.Left, aDestRect.Bottom - aDestRect.Top,
      aGraphic.Palette);
    try
      if aGraphic is TBitmap then
        _DrawDIBitmap(lMemCanvas, aDestRect, TBitmap(aGraphic), cmSrcCopy)
      else
        lMemCanvas.StretchDraw(aDestRect, aGraphic);

      if aTransparent then
        lCopyMode := cmSrcAnd
      else
        lCopyMode := cmSrcCopy;

      lMemCanvas.RenderToDevice(aDestRect, aGraphic.Palette, lCopyMode);
    finally
      lMemCanvas.Free;
    end;
  end;

  procedure _DrawBmp(const aBitmap: TBitmap);
  begin
    if aTransparent then
    begin
      aCanvas.CopyMode := cmSrcAnd;
      _DrawTransparentDIBitmap(aCanvas, aDestRect, aBitmap, cmSrcCopy);
    end
    else
    begin
      aCanvas.CopyMode := cmSrcCopy;
      _DrawDIBitmap(aCanvas, aDestRect, aBitmap, cmSrcCopy);
    end;
  end;

begin
  if (not aIsPrinting) or (aGraphic is TMetaFile) or (aGraphic is TIcon) then
  begin
    aCanvas.StretchDraw(aDestRect, aGraphic);
    Exit;
  end;

  lBmp := nil;
  lFreeBitmap := False;
  try
    if aGraphic is TBitmap then
    begin
      if TBitmap(aGraphic).Monochrome and aDirectDraw then
        _DirectDrawImage(aGraphic)
      else
        _DrawBMP(TBitmap(aGraphic));
    end
    else if aDirectDraw then
      _DirectDrawImage(aGraphic)
    else
    begin
      _GetAsBitmap;
      if lBmp <> nil then
        _DrawBMP(lBmp)
      else
        _DrawGraphic(aGraphic);
    end;
  finally
    if lFreeBitmap then
    begin
      FreeAndNil(lBmp);
    end;
  end;
end;

function RMStrGetToken(s: string; delimeter: string; var APos: integer): string;
var
  tempStr: string;
  endStringPos: integer;
begin
  Result := '';
  if APos <= 0 then exit;
  if APos > length(s) then
  begin
    APos := -1;
    exit;
  end;

  tempStr := copy(s, APos, length(s) + 1 - APos);
  if (length(delimeter) = 1) then
{$IFNDEF COMPILER3_UP}
    endStringPos := pos(delimeter, tempStr)
{$ELSE}
    endStringPos := AnsiPos(delimeter, tempStr)
{$ENDIF}
  else
  begin
    delimeter := ' ' + delimeter + ' ';
{$IFNDEF COMPILER3_UP}
    endStringPos := pos(UpperCase(delimeter), UpperCase(tempStr));
{$ELSE}
    endStringPos := AnsiPos(UpperCase(delimeter), UpperCase(tempStr));
{$ENDIF}
  end;

  if endStringPos <= 0 then
  begin
    Result := tempStr;
    APos := -1;
  end
  else
  begin
    Result := copy(tempStr, 1, endStringPos - 1);
    APos := APos + endStringPos + length(delimeter) - 1;
  end
end;

function RMExtractField(const aStr: string; aFieldNo: Integer): string;
var
  i, j, k: Integer;
begin
  Result := '';
  j := 1;
  k := 0;
  for i := 1 to Length(aStr) do
  begin
    if aStr[i] = #1 then
    begin
      Inc(k);
      if k = aFieldNo then
      begin
        Result := Copy(aStr, j, i - j);
        Break;
      end
      else
        j := i + 1;
    end;
  end;
end;

procedure RMSetNullValue(var aValue1, aValue2: Variant);

  procedure _SetValue(var aValue1: Variant; const aValue2: Variant);
  begin
    if (TVarData(aValue2).VType = varString) or (TVarData(aValue2).VType = varOleStr) then
      aValue1 := ''
    else if TVarData(aValue2).VType = varBoolean then
      aValue1 := False
    else
      aValue1 := 0;
  end;

begin
  if (aValue1 = Null) or (aValue2 = Null) then
  begin
    if aValue1 = Null then
    begin
      _SetValue(aValue1, aValue2);
    end
    else if aValue2 = Null then
    begin
      _SetValue(aValue2, aValue1);
    end;
  end;
end;

function RMDeleteNoNumberChar(s: string): string;
begin
  s := Trim(s);
  while (Length(s) > 0) and not (s[1] in ['-', '0'..'9']) do
    s := Copy(s, 2, 255); // trim all non-digit chars at the begin
  while (Length(s) > 0) and not (s[Length(s)] in ['0'..'9']) do
    s := Copy(s, 1, Length(s) - 1); // trim all non-digit chars at the end
  while Pos(ThousandSeparator, s) <> 0 do
    Delete(s, Pos(ThousandSeparator, s), 1);

  Result := s;
end;

{$IFNDEF COMPILER6_UP}

function TryStrToFloat(const S: string; out Value: Extended): Boolean;
begin
  Result := False;
end;
{$ENDIF}

const
  Numbers: array[1..19] of string = ('one', 'two', 'three', 'four',
    'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
    'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen',
    'nineteen');

  Tenths: array[1..9] of string = ('ten', 'twenty', 'thirty', 'forty',
    'fifty', 'sixty', 'seventy', 'eighty', 'ninety');

function RMNumToLetters(Number: Real): string;

  function _RecurseNumber(N: LongWord): string;
  begin
    case N of
      1..19:
        Result := Numbers[N];
      20..99:
        if N mod 10 <> 0 then //处理如果整数时的-问题
          Result := Tenths[N div 10] + '-' + _RecurseNumber(N mod 10)
        else
          Result := Tenths[N div 10] + '' + _RecurseNumber(N mod 10);
      100..999:
        Result := Numbers[N div 100] + ' hundred ' + _RecurseNumber(N mod 100);
      1000..999999:
        Result := _RecurseNumber(N div 1000) + ' thousand and ' +
          _RecurseNumber(N mod 1000);
      1000000..999999999: Result := _RecurseNumber(N div 1000000) + ' million and '
        + _RecurseNumber(N mod 1000000);
      1000000000..4294967295: Result := _RecurseNumber(N div 1000000000) +
        ' billion and ' + _RecurseNumber(N mod 1000000000);
    end; {Case N of}
  end; {RecurseNumber}

begin
  if (Number >= 0.00) and (Number <= 4294967295.99) then
  begin
    Result := _RecurseNumber(Round(Int(Number)));
    if not (Frac(Number) = 0.00) then
    begin
      if Result <> '' then
        Result := Result + ' and Cents ' + _RecurseNumber(Round(Frac(Number) * 100)) + ''
      else
        Result := IntToStr(Round(Frac(Number) * 100)) + '/100';
    end;
  end
  else
  begin
    Result := '';
  end;
end;

function RMTrim(aStr: string): string;
var
  lPos: Integer;
begin
  lPos := Length(aStr);
  while lPos > 0 do
  begin
    if aStr[lPos] <> ' ' then
      Break;

    Dec(lPos);
  end;

  Result := Copy(aStr, 1, lPos);
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ Html }

function _Htmldeletequotation(aStr: WideString): WideString;
begin
{$IFDEF TntUnicode}
  aStr := Tnt_WideStringReplace(aStr, '"', '', [rfReplaceAll]);
  aStr := Tnt_WideStringReplace(aStr, '''', '', [rfReplaceAll]);
{$ELSE}
  aStr := stringreplace(aStr, '"', '', [rfReplaceAll]);
  aStr := stringreplace(aStr, '''', '', [rfReplaceAll]);
{$ENDIF}
  Result := aStr;
end;


function RMHtmlGetFontColor(aStr: WideString): TColor;
var
  lCode: integer;
begin
  Result := clBlack;
  if Copy(aStr, 1, 1) <> '#' then
  begin
    if Pos('cl', aStr) <> 1 then
      aStr := 'cl' + aStr;

    IdentToColor(aStr, Longint(Result));
  end
  else
  begin
    aStr := '$' + Copy(aStr, 6, 2) + Copy(aStr, 4, 2) + Copy(aStr, 2, 2);
    Val(aStr, Result, lCode);
  end
end;

procedure RMHtmlGetFontSize(aFont: TFont; aStr: WideString;
  aDocMode: TRMDocMode; aFactorY: Double);
var
  lCode: integer;
  lFontSize: Integer;
begin
  aStr := _Htmldeletequotation(aStr);
  Val(aStr, lFontSize, lCode);

  aFont.Size := lFontSize;
  if aDocMode <> rmdmPrinting then
  begin
    if aFactorY = 1 then
    begin
      aFont.Height := -Round(aFont.Size * 96 / 72);
    end
    else
      aFont.Height := -Trunc(aFont.Size * 96 / 72 * aFactorY);
  end;
end;

function RMHtmlGetFontFace(aStr: WideString): WideString;
begin
  Result := aStr;
end;

function HtmlGetFontCharset(aStr: WideString): TFontCharSet;
var
  lCode: Integer;
  lCharSet: Integer;
begin
  Val(aStr, lCharSet, lCode);
  Result := lCharSet;
end;

procedure RMHtmlAnalyseElement(aSourceStr: WideString; var aHtmlElements: TRMHtmlList);
var
  i: Integer;
  lList: TList;
  lHtmlElement: PRMHtmlElement;
  ltagName, ltagParas, lHtmlStr: WideString;
  ltagStr: WideString;

  procedure _ClearMem;
  var
    i: Integer;
  begin
    for i := 0 to lList.Count - 1 do
    begin
      Dispose(PRMHtmlParaValue(lList[i]));
    end;

    lList.Clear;
  end;

  function _GetTagNameStr(aSourceStr: WideString;
    var atagName, atagParas, atagStr, aOutStr: WideString): WideString;
  var
    lBeginTagPos, lEndTagPos: Integer;
    ltagPos: Integer;
  begin
    //aSourceStr := Trim(aSourceStr);
    lBeginTagPos := Pos('<', aSourceStr);
    lEndTagPos := Pos('>', aSourceStr); //find the tag's position.
    if lBeginTagPos <= 0 then
    begin
      atagName := '';
      atagParas := '';
      atagStr := '';
      aOutStr := aSourceStr;
      Result := '';
      Exit;
    end;

    if lBeginTagpos > 1 then
    begin
      atagName := '';
      atagParas := '';
      atagStr := '';
      aOutStr := Copy(aSourceStr, 1, lBeginTagpos - 1);
      Result := Copy(aSourceStr, lBeginTagpos, Length(aSourceStr));
      Exit;
    end;

    if (lBeginTagPos > 0) and (lEndTagPos <= 0) then
    begin
      atagName := '';
      atagParas := '';
      atagStr := '';
      aOutStr := '';
      Result := '';
      Exit;
    end;

    atagStr := Copy(aSourceStr, lBeginTagPos + 1, lEndTagPos - lBeginTagPos - 1);
    Result := Copy(aSourceStr, lEndTagPos + Length('>'), Length(aSourceStr));
    aOutStr := '';
    aSourceStr := Copy(aSourceStr, lBeginTagpos + Length('<'), lendtagpos - lbegintagpos - 1);

    aSourceStr := Trim(aSourceStr);
    ltagPos := Pos(' ', aSourceStr);
    if ltagPos <= 0 then
    begin
      atagName := aSourceStr;
      atagParas := '';
      Exit;
    end;

    atagName := Copy(aSourceStr, 1, ltagPos - 1);
    Delete(aSourceStr, 1, ltagPos);
    atagParas := Trim(aSourceStr);
  end;

  procedure _GetParaValue(aStr: WideString; var aList: TList);
  var
    lTagPos, lTagPos1: Integer;
    ltmpTpv: PRMHtmlParaValue; //内部用的TTommParaValue类型变量
    lParamName, lParamValue: WideString;
  begin
    aStr := Trim(aStr);
    lTagPos := pos('="', aStr);
    while lTagPos > 0 do
    begin
      lParamName := LowerCase(Trim(Copy(aStr, 1, lTagPos - 1)));
      Delete(aStr, 1, lTagPos + 1);
      lTagPos1 := Pos('"', aStr);
      if lTagPos1 > 0 then
      begin
        lParamValue := Copy(aStr, 1, lTagPos1 - 1);
        Delete(aStr, 1, lTagPos1);
        New(ltmpTpv);
        ltmpTpv.ParaName := lParamName;
        ltmpTpv.ParaValue := lParamValue;
        aList.Add(ltmpTpv);
      end;

      lTagPos := pos('="', aStr);
    end;
  end;

begin
  aHtmlElements.Clear;
  lList := TList.Create;
  try
    repeat
      aSourceStr := _GetTagNameStr(aSourceStr, ltagName, ltagParas, ltagStr, lHtmlStr); //得到tag的名字和参数
      New(lHtmlElement);
      lHtmlElement^.H_tag := LowerCase(ltagName);
      lHtmlElement^.H_str := lHtmlStr;
      lHtmlElement^.H_TagStr := ltagStr;

      _ClearMem;
      _GetParaValue(ltagParas, lList); //得到tag的参数列表和值列表
      SetLength(lHtmlElement^.H_paras, lList.Count);
      SetLength(lHtmlElement^.H_values, lList.Count);
      for i := 0 to lList.Count - 1 do
      begin
        lHtmlElement^.H_paras[i] := LowerCase(PRMHtmlParaValue(lList.Items[i])^.ParaName);
        lHtmlElement^.H_values[i] := PRMHtmlParaValue(lList.Items[i])^.ParaValue;
      end;

      aHtmlElements.Add(lHtmlElement);
    until (aSourceStr = '');
  finally
    _ClearMem;
    lList.Free;
  end;
end;

procedure RMHtmlSetFont(aFont: TFont; aHtmlElement: PRMHtmlElement;
  aFontStack: TRMHtmlFontStack; aDocMode: TRMDocMode; aFactorY: Double; aList: TWideStringList);
var
  j: Integer;
  lFont: TFont;

  procedure _Push(aTag: WideString);
  var
    lColor: WideString;
  begin
    if aList = nil then Exit;

    if aTag = '<font>' then
    begin
      lColor := ColorToString(aFont.Color);
      if Copy(lColor, 1, 2) = 'cl' then
        lColor := Copy(lColor, 3, Length(lColor) - 2);

      aTag := '<font face="' + aFont.Name +
        '" size="' + IntToStr(aFont.size) +
        '" charset="' + IntToStr(aFont.Charset) +
        '" color="' + lColor + '">';
    end;

    aList.Add(aTag);
  end;

  procedure _Pop(aTag: WideString);
  var
    lStr: WideString;
    lFlag: Boolean;
  begin
    if aList = nil then Exit;

    lFlag := False;
    if aList.Count > 0 then
    begin
      lStr := aTag;
      Delete(lStr, 2, 1);
      if Pos(lStr, aList[aList.Count - 1]) = 1 then
      begin
        lFlag := True;
        aList.Delete(aList.Count - 1);
      end;
    end;

    if not lFlag then
      aList.Add(aTag);
  end;

begin
  if aHtmlElement^.H_tag = 'font' then
  begin
    aFontStack.Push(afont);
    for j := 0 to High(aHtmlElement^.H_paras) do
    begin
      if aHtmlElement^.H_paras[j] = 'face' then
        aFont.Name := RMHtmlGetFontFace(aHtmlElement^.H_values[j])
      else if aHtmlElement^.H_paras[j] = 'size' then
        RMHtmlGetFontSize(aFont, aHtmlElement^.H_values[j], aDocMode, aFactorY)
      else if aHtmlElement^.H_paras[j] = 'color' then
        aFont.Color := RMHtmlGetFontColor(aHtmlElement^.H_values[j])
      else if aHtmlElement^.H_paras[j] = 'charset' then
        aFont.Charset := HtmlGetFontCharset(aHtmlElement^.H_values[j]);
    end;

    _Push('<font>');
  end
  else if aHtmlElement^.H_tag = 'b' then
  begin
    aFont.Style := aFont.Style + [fsbold];
    _Push('<b>');
  end
  else if aHtmlElement^.H_tag = '/b' then
  begin
    aFont.Style := aFont.Style - [fsbold];
    _Pop('</b>');
  end
  else if aHtmlElement^.H_tag = 'u' then
  begin
    aFont.Style := aFont.Style + [fsUnderline];
    _Push('<u>');
  end
  else if aHtmlElement^.H_tag = '/u' then
  begin
    aFont.Style := aFont.Style - [fsUnderline];
    _Pop('</u>');
  end
  else if aHtmlElement^.H_tag = 'i' then
  begin
    aFont.Style := aFont.Style + [fsitalic];
    _Push('<i>');
  end
  else if aHtmlElement^.H_tag = '/i' then
  begin
    aFont.Style := aFont.Style - [fsitalic];
    _Pop('</i>');
  end
  else if aHtmlElement^.H_tag = 'strike' then
  begin
    aFont.Style := aFont.Style + [fsStrikeOut];
    _Push('<strike>');
  end
  else if aHtmlElement^.H_tag = '/strike' then
  begin
    aFont.Style := aFont.Style - [fsStrikeOut];
    _Pop('</strike>');
  end
  else if (aHtmlElement^.H_tag = 'sup') or (aHtmlElement^.H_tag = 'sub') then
  begin
    aFontStack.Push(aFont);
    aFont.Size := aFont.Size * 2 div 3;
    _Push('<sup>');
  end
  else if (aHtmlElement^.H_tag = '/font') or (aHtmlElement^.H_tag = '/sup') or
    (aHtmlElement^.H_tag = '/sub') then
  begin
    lFont := aFontStack.Pop;
    if lFont <> nil then
      aFont.Assign(lFont);
    lFont.Free;

    _Pop('<' + aHtmlElement^.H_tag + '>');
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMHtmlFontStack }

constructor TRMHtmlFontStack.Create;
begin
  inherited;

  FFontList := TList.Create;
end;

destructor TRMHtmlFontStack.Destroy;
var
  i: Integer;
begin
  for i := 0 to FFontList.Count - 1 do
  begin
    TFont(FFontList.Items[i]).Free;
  end;

  FFontList.Free;

  inherited;
end;

function TRMHtmlFontStack.Pop: TFont; //出栈
var
  lFont: TFont;
begin
  if FFontList.Count <= 0 then
  begin
    Result := nil;
    Exit;
  end;

  Result := TFont.Create;
  lFont := FFontList.Items[FFontList.Count - 1];
  Result.Assign(lFont);

  lFont.Free;
  FFontlist.Delete(FFontList.Count - 1);
end;

procedure TRMHtmlFontStack.Push(aFont: TFont); //进栈
var
  lFont: TFont;
begin
  lFont := TFont.Create;
  lFont.Assign(aFont);
  FFontList.Add(lFont);
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMHtmlList }

procedure TRMHtmlList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Dispose(PRMHtmlElement(Items[i]));
  end;

  inherited Clear;
end;

procedure RMSetControlsEnabled(aControl: TWinControl; aEnabled: Boolean);
var
  i: Integer;
begin
  aControl.Enabled := aEnabled;
  for i := 0 to aControl.ControlCount - 1 do
  begin
    aControl.Controls[i].Enabled := aEnabled;
  end;
end;

function RMPosEx(const SubStr, S: WideString; Offset: Cardinal = 1): Integer;
var
  I, X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;


procedure GetMethodDefinition(ATypeInfo: PTypeInfo; AStrings: TStrings);
begin
  // finally, add the string to the listbox.
  with AStrings do
  begin
    Add(GetMethodDefinition(ATypeInfo));
  end;
end;

type

  PParamRecord = ^TParamRecord;
  TParamRecord = record
    Flags:     TParamFlags;
    ParamName: ShortString;
    TypeName:  ShortString;
  end;


function GetMethodDefinition(ATypeInfo: PTypeInfo):string;
{ This method retrieves the property info on a method pointer. We use this
  information to recunstruct the method definition. }
var
  MethodTypeData: PTypeData;
  MethodDefine:   String;
  ParamRecord:    PParamRecord;
  TypeStr:        ^ShortString;
  ReturnStr:      ^ShortString;
  i: integer;
begin
  Result:='';

  if ATypeInfo=nil then Exit;

  MethodTypeData := GetTypeData(ATypeInfo);

  // Determine the type of method
  case MethodTypeData.MethodKind of
    mkProcedure:      MethodDefine := 'procedure ';
    mkFunction:       MethodDefine := 'function ';
    mkConstructor:    MethodDefine := 'constructor ';
    mkDestructor:     MethodDefine := 'destructor ';
    mkClassProcedure: MethodDefine := 'class procedure ';
    mkClassFunction:  MethodDefine := 'class function ';
  end;

  // point to the first parameter
  ParamRecord    := @MethodTypeData.ParamList;
  i := 1; // first parameter

  // loop through the method's parameters and add them to the string list as
  // they would be normally defined.
  while i <= MethodTypeData.ParamCount do
  begin
    if i = 1 then
      MethodDefine := MethodDefine+'(';

    if pfVar in ParamRecord.Flags then
      MethodDefine := MethodDefine+('var ');
    if pfconst in ParamRecord.Flags then
      MethodDefine := MethodDefine+('const ');
    if pfArray in ParamRecord.Flags then
      MethodDefine := MethodDefine+('array of ');
//  we won't do anything for the pfAddress but know that the Self parameter
//  gets passed with this flag set.
{
    if pfAddress in ParamRecord.Flags then
      MethodDefine := MethodDefine+('*address* ');
}
    if pfout in ParamRecord.Flags then
      MethodDefine := MethodDefine+('out ');


    // Use pointer arithmetic to get the type string for the parameter.
    TypeStr := Pointer(Integer(@ParamRecord^.ParamName) +
      Length(ParamRecord^.ParamName)+1);

    MethodDefine := Format('%s%s: %s', [MethodDefine, ParamRecord^.ParamName,
      TypeStr^]);

    inc(i); // Increment the counter.

    // Go the next parameter. Notice that use of pointer arithmetic to
    // get to the appropriate location of the next parameter.
    ParamRecord := PParamRecord(Integer(ParamRecord) + SizeOf(TParamFlags) +
      (Length(ParamRecord^.ParamName) + 1) + (Length(TypeStr^)+1));

    // if there are still parameters then setup
    if i <= MethodTypeData.ParamCount then
    begin
      MethodDefine := MethodDefine + '; ';
    end
    else
      MethodDefine := MethodDefine + ')';
  end;

  // If the method type is a function, it has a return value. This is also
  // placed in the method definition string. The return value will be at the
  // location following the last parameter.
  if MethodTypeData.MethodKind = mkFunction then
  begin
    ReturnStr := Pointer(ParamRecord);
    MethodDefine := Format('%s: %s;', [MethodDefine, ReturnStr^])
  end
  else
    MethodDefine := MethodDefine+';';
  Result:=MethodDefine;
end;

function GetFullMethodDefinition(Instance: TComponent; const PropName: string):string;
var
  s:string;
begin
  if (Instance=nil) or (PropName='') then Exit;

  s:='%s_%s';

  s:=Format(s,[Instance.Name,PropName]);

  Result:=GetMethodDefinition(GetPropInfo(Instance,PropName,[tkMethod])^.PropType^);
  if Result<>'' then
   Result:=StringReplace(Result,'(',s+'(',[rfIgnoreCase	]);

end;


end.

