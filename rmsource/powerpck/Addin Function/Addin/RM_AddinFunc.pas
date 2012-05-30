unit RM_AddinFunc;

interface

{$I rm.inc}

uses
  SysUtils, Classes, RM_class, RM_Common, RM_Parser
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMCharSet = set of Char;

  TRMAddinFunctionLibrary = class(TRMFunctionLibrary)
  public
    constructor Create; override;
    procedure DoFunction(aParser: TRMParser; FNo: Integer; p: array of Variant; var val: Variant); override;
  end;

var
  RMFFormatDate: string;

implementation

const
  SRMWordPosition = 'WordPosition(<Value>,<String>,<Char>)|Returns position of word number <WordNo> in the string <String>. <Delimiters> is the list of word delimiters.';
  SRMExtractWord = 'ExtractWord(<Value>,<String>,<Char>)|Returns word number <WordNo> from the string <String>.<Delimiters> is the list of word delimiters.';
  SRMWordCount = 'WordCount(<String>,<Char>)|Returns number of words in the string <String>.<Delimiters> is the list of word delimiters.';
  SRMIsWordPresent = 'IsWordPresent(<String>,<String>,<Char>)|Determines is word <Word> present in the string <String>.<Delimiters> is the list of word delimiters.';
  SRMNPos = 'NPos(<String>,<String>,<Char>)|Returns position of <SubStrNo>-th substring <SubStr> inclusion in the string <String>.';
  SRMReplaceStr = 'ReplaceStr(<String>,<String>,<String>)|Replaces all inclusions of <SubStr1> string to the <SubStr2> string in the string <String> and returns the result.';
  SRMReplicate = 'Replicate(<String>,<Value>)|Returns the string with length <Length> that consists of symbols <Symbol>.';
  SRMPadRight = 'PadRight(<String>,<Value>,<String>)|Adds symbols <Symbol> to end of the string <String> to make it as long as stated in the <Length> parameter and returns result string.';
  SRMPadLeft = 'PadLeft(<String>,<Value>,<String>)|Adds symbols <Symbol> to begin of the string <String> to make it as long as stated in the <Length> parameter and returns result string.';
  SRMPadCenter = 'PadCenter(<String>,<Value>,<String>)|Adds symbols <Symbol> to begin and end of the string <String> to make it as long as stated in the <Length> parameter and returns result string.';
  SRMEndPos = 'EndPos(<String>,<String>)|Returns position of substring <SubStr> in the string <String> starting at the end of the string.';
  SRMCompareStr = 'CompareStr(<String>,<String>)|Compares two strings. Returns the position where begins the difference between the strings or 0 if strings are equivalent.';
  SRMLeftCopy = 'LeftCopy(<String>,<Value>)|Copies number of symbols <Count> from the string <String> starting at the begin of the string.';
  SRMRightCopy = 'RightCopy(<String>,<Value>)|Copies number of symbols <Count> from the string <String> starting at the end of the string.';
  SRMDelete = 'Delete(<String>,<Value>,<Value>)|Deletes <DelCount> symbols starting at position <DelFrom> in the given string <String> and returns the result.';
  SRMInsert = 'Insert(<String>,<String>,<Value>)|Inserts <SubStr> substring into <String> string starting at position <InsertFrom> and returns the result.';
  SRMTrimRight = 'TrimRight(<String>)|Trims all right spaces from the string <String> and returns the result.';
  SRMTrimLeft = 'TrimLeft(<String>)|Trims all left spaces from the string <String> and returns the result.';
  SRMDateToStr = 'DATETOSTR(<Date>)|Converts date <Date> to string and returns the result.';
  SRMTimeToStr = 'TIMETOSTR(<Time>)|Converts time <Time> to string and returns the result.';
  SRMChr = 'CHR(<Code>)|Returns symbol of ASCII code <Code>.';
  SRMOrd = 'Ord(<Code>)|GetASCII code Of <Chr>.';

  SRMValidInt = 'ValidInt(<String>)|Returns True if <String> is valid integer value.';
  SRMValidFloat = 'ValidFloat(<String>)|Returns True if <String> is valid float value.';
  SRMIsRangeNum = 'IsRangeNum(<Number1>,<Number2>,<Number3>)|Returns True if <Number3> is between <Number1> and <Number2>.';
  SRMStrToFloatDef = 'StrToFloatDef(<String>,<DefValue>)|Converts <String> string to float value. If conversion fails, returns default value <DefValue>.';
  SRMStrToIntDef = 'StrToIntDef(<String>,<DefValue>)|Converts <String> string to integer value. If conversion fails, returns default value <DefValue>.';
  SRMStrToInt = 'StrToInt(<String>)|Converts <String> string to the integer value.';
  SRMStrToFloat = 'StrToFloat(<String>)|Converts <String> string to the float value.';

  SRMCreateDate = 'CreateDate(<String>)|Converts <String> string to string that contains date to use it in SQL ' +
    'clause. To use this function put the string with desired date format ' +
    'to TfrAddFunctionLibrary.FormatDate property.';
  SRMCreateStr = 'CreateStr(<String>)|Adds quotes to the <String> string to use it in SQL clause.';
  SRMCreateNum = 'CreateNum(<String>)|Converts <String> string to string that contains numeric value to use it in SQL clause.';

  SRMDateDiff = 'DateDiff(<Date1>,<Date2>,<var String>)|Returns the difference between two dates <Date1> and <Date2>. Result is in the string <String> in format days;months;years.';
  SRMIncDate = 'IncDate(<Date>,<String>)|Increments the date <Date> by given number of days, months and years ' +
    'passed in the <String> parameter in format days; months; years. ' +
    'Returns the result date.';
  SRMIncTime = 'IncTime(<Time>,<String>)|Increments the time <Time> by given number of hours, minutes, seconds ' +
    'and milliseconds passed in the <String> parameter in format h; min; sec; msec . ' +
    'Returns the result time.';
  SRMDaysPerMonth = 'DaysPerMonth(<Year>,<Month>)|Returns days in the given month <Month> of the year <Year>.';
  SRMFirstdayOfNextMonth = 'FirstdayOfNextMonth(<Date>)|Returns the date of first day of the next month of date <Date>.';
  SRMFirstdayOfPrevMonth = 'FirstdayOfPrevMonth(<Date>)|Returns the date of first day of the previous month of date <Date>.';
  SRMLastDayOfPrevMonth = 'LastDayOfPrevMonth(<Date>)|Returns the date of last day of the previous month of date <Date>.';
  SRMIncDay = 'IncDay(<Date>,<Number>)|Increments the date <Date> by given number of days <Number> and returns.';
  SRMIncYear = 'IncYear(<Date>,<Number>)|Increments the date <Date> by given number of years <Number> and returns the result date.';
  SRMIsRangeDate = 'IsRangeDate(<Date1>,<Date2>,<Date3>)|Returns True if date <Date3> is between <Date1> and <Date2>.';
  SRMStrToDateDef = 'StrToDateDef(<String>,<DefDate>)|Converts <String> string to date. If conversion fails, returns default value <DefDate>.';
  SRMValidDate = 'ValidDate(<String>)|Returns True if <String> string is valid date.';
  SRMIncMonth = 'IncMonth(<Date>,<Number>)|Increments the date <Date> by given number of months <Number> and returns the result date.';
  SRMIsLeapYear = 'IsLeapYear(<Year>)|Returns True if <Year> year is leap year.';
  SRMSwap = 'Swap(<var var1>,<var var2>)|Swaps the variables var1 and var2.';

function RMConvCS(cStr: string): TrmCharSet;
var
  i: Integer;
begin
  Result := [];
  for i := 1 to Length(cStr) do Include(Result, cStr[i]);
end;

function RMWordPosition(const N: Integer; const S: string; const WordDelims: TrmCharSet): Integer;
var
  Count, I: Integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do
  begin
    while (I <= Length(S)) and (S[I] in WordDelims) do Inc(I);
    if I <= Length(S) then Inc(Count);
    if Count <> N then
    begin
      while (I <= Length(S)) and not (S[I] in WordDelims) do Inc(I);
    end
    else
      Result := I;
  end;
end;

function RMExtractWord(N: Integer; const S: string; const WordDelims: TrmCharSet): string;
var
  I: Integer;
  Len: Integer;
begin
  Len := 0;
  I := RMWordPosition(N, S, WordDelims);
  if I <> 0 then
  begin
    while (I <= Length(S)) and not (S[I] in WordDelims) do
    begin
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  end;
  SetLength(Result, Len);
end;

function RMWordCount(const S: string; const WordDelims: TrmCharSet): Integer;
var
  SLen, I: Cardinal;
begin
  Result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen do
  begin
    while (I <= SLen) and (S[I] in WordDelims) do Inc(I);
    if I <= SLen then Inc(Result);
    while (I <= SLen) and not (S[I] in WordDelims) do Inc(I);
  end;
end;

function RMReplicate(cStr: string; nLen: Integer): string;
var
  nCou: Integer;
begin
  Result := '';
  for nCou := 1 to nLen do
    Result := Result + cStr;
end;

function RMPadLeft(cStr: string; nLen: Integer; cChar: string): string;
var
  S: string;
begin
  S := Trim(cStr);
  Result := RMReplicate(cChar, nLen - Length(S)) + S;
end;

function RMPadRight(cStr: string; nLen: Integer; cChar: string): string;
var
  S: string;
begin
  S := Trim(cStr);
  Result := S + RMReplicate(cChar, nLen - Length(S));
end;

function RMReplaceStr(const S, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then
    begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until I <= 0;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMAddinFunctionLibrary }

constructor TRMAddinFunctionLibrary.Create;
begin
  inherited Create;
  with List do
  begin
    Add('WORDPOSITION');
    Add('EXTRACTWORD');
    Add('WORDCOUNT');
    Add('ISWORDPRESENT');
    Add('NPOS');

    Add('REPLACESTR');
    Add('REPLICATE');
    Add('PADLEFT');
    Add('PADRIGHT');
    Add('PADCENTER');
    Add('ENDPOS');
    Add('LEFTCOPY');
    Add('RIGHTCOPY');
    Add('DELETE');
    Add('INSERT');
    Add('COMPARESTR');
    Add('TRIMRIGHT');
    Add('TRIMLEFT');
    Add('DATETOSTR');
    Add('TIMETOSTR');
    Add('CHR');

    Add('VALIDINT');
    Add('VALIDFLOAT');
    Add('ISRANGENUM');
    Add('STRTOFLOATDEF');
    Add('STRTOINTDEF');
    Add('STRTOINT');
    Add('STRTOFLOAT');
    Add('CREATEDATE');
    Add('CREATESTR');
    Add('CREATENUM');

    Add('DATEDIFF');
    Add('INCDATE');
    Add('INCTIME');
    Add('DAYSPERMONTH');
    Add('FIRSTDAYOFNEXTMONTH');
    Add('FIRSTDAYOFPREVMONTH');
    Add('LASTDAYOFPREVMONTH');
    Add('INCDAY');
    Add('INCYEAY');
    Add('ISRANGEDATE');
    Add('STRTODATEDEF');
    Add('VALIDDATE');
    Add('INCMONTH');
    Add('ISLEAPYEAR');

//    Add('SWAP');
    Add('ORD');
  end;

  AddFunctionDesc('WordPosition', RMftString, SRMWordPosition, 'NSS');
  AddFunctionDesc('ExtractWord', RMftString, SRMExtractWord, 'NSS');
  AddFunctionDesc('WordCount', RMftString, SRMWordCount, 'SS');
  AddFunctionDesc('IsWordPresent', RMftString, SRMIsWordPresent, 'SSS');
  AddFunctionDesc('NPos', RMftString, SRMNPos, 'SSN');

  AddFunctionDesc('ReplaceStr', RMftString, SRMReplaceStr, 'SSS');
  AddFunctionDesc('Replicate', RMftString, SRMReplicate, 'SN');
  AddFunctionDesc('PadLeft', rmftString, SRMPadLeft, 'SNS');
  AddFunctionDesc('PadRight', RMftString, SRMPadRight, 'SNS');
  AddFunctionDesc('PadCenter', RMftString, SRMPadCenter, 'SNS');
  AddFunctionDesc('EndPos', RMftString, SRMEndPos, 'SS');
  AddFunctionDesc('LeftCopy', RMftString, SRMLeftCopy, 'SN');
  AddFunctionDesc('RightCopy', RMftString, SRMRightCopy, 'SN');
  AddFunctionDesc('Delete', RMftString, SRMDelete, 'SNN');
  AddFunctionDesc('Insert', RMftString, SRMInsert, 'SSN');
  AddFunctionDesc('CompareStr', RMftString, SRMCompareStr, 'SS');
  AddFunctionDesc('TrimRight', RMftString, SRMTrimRight, 'S');
  AddFunctionDesc('TrimLeft', RMftString, SRMTrimLeft, 'S');
  AddFunctionDesc('DateToStr', RMftString, SRMDateToStr, 'D');
  AddFunctionDesc('TimeToStr', RMftString, SRMTimeToStr, 'T');
  AddFunctionDesc('Chr', RMftString, SRMChr, 'N');
  AddFunctionDesc('Ord', RMftMath, SRMOrd, 'S');

  AddFunctionDesc('ValidInt', RMftMath, SRMValidInt, 'S');
  AddFunctionDesc('ValidFloat', RMftMath, SRMValidFloat, 'S');
  AddFunctionDesc('IsRangeNum', RMftMath, SRMIsRangeNum, 'NNN');
  AddFunctionDesc('StrToFloatDef', RMftMath, SRMStrToFloatDef, 'SN');
  AddFunctionDesc('StrToIntDef', RMftMath, SRMStrToIntDef, 'SN');
  AddFunctionDesc('StrToInt', RMftMath, SRMStrToInt, 'S');
  AddFunctionDesc('StrToFloat', RMftMath, SRMStrToFloat, 'SN');
  AddFunctionDesc('CreateDate', RMftString, SRMCreateDate, 'S');
  AddFunctionDesc('CreateStr', RMftString, SRMCreateStr, 'S');
  AddFunctionDesc('CreateNum', RMftString, SRMCreateNum, 'S');

  AddFunctionDesc('DateDiff', RMftDateTime, SRMDateDiff, 'DDS');
  AddFunctionDesc('IncDate', RMftDateTime, SRMIncDate, 'DS');
  AddFunctionDesc('IncTime', RMftDateTime, SRMIncTime, 'DS');
  AddFunctionDesc('DaysPerMonth', RMftDateTime, SRMDaysPerMonth, 'DD');
  AddFunctionDesc('FirstdayOfNextMonth', RMftDateTime, SRMFirstdayOfNextMonth, 'D');
  AddFunctionDesc('FirstdayOfPrevMonth', RMftDateTime, SRMFirstdayOfPrevMonth, 'D');
  AddFunctionDesc('LastDayOfPrevMonth', RMftDateTime, SRMLastDayOfPrevMonth, 'D');
  AddFunctionDesc('IncDay', RMftDateTime, SRMIncDay, 'DN');
  AddFunctionDesc('IncYear', RMftDateTime, SRMIncYear, 'DN');
  AddFunctionDesc('IsRangeDate', RMftDateTime, SRMIsRangeDate, 'DDD');
  AddFunctionDesc('StrToDateDef', RMftDateTime, SRMStrToDateDef, 'SD');
  AddFunctionDesc('ValidDate', RMftDateTime, SRMValidDate, 'S');
  AddFunctionDesc('IncMonth', RMftDateTime, SRMIncMonth, 'DN');
  AddFunctionDesc('IsLeapYear', RMftDateTime, SRMIsLeapYear, 'D');

//  AddFunctionDesc('Swap', rmftOther, SRMSwap, 'SS');
end;

function RMValidDate(cDate: string): Boolean;
begin
  Result := True;
  try
    StrToDate(cDate)
  except
    Result := False;
  end;
end;

function RMIsLeapYear(AYear: Integer): Boolean;
begin
  Result := (AYear mod 4 = 0) and ((AYear mod 100 <> 0) or (AYear mod 400 = 0));
end;

function RMDaysPerMonth(nYear, nMonth: Integer): Integer;
const
  DaysInMonth: array[1..12] of Integer =
  (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

begin
  Result := DaysInMonth[nMonth];
  if (nMonth = 2) and RMIsLeapYear(nYear) then Inc(Result);
end;

function RMIncDate(dDate: TDateTime; nDays, nMonths, nYears: Integer): TDateTime;
var
  D, M, Y: Word;
  Day, Month, Year: LongInt;
begin
  DecodeDate(dDate, Y, M, D);
  Year := Y; Month := M; Day := D;
  Inc(Year, nYears);
  Inc(Year, nMonths div 12);
  Inc(Month, nMonths mod 12);

  if Month < 1 then
  begin
    Inc(Month, 12);
    Dec(Year);
  end
  else
    if Month > 12 then
    begin
      Dec(Month, 12);
      Inc(Year);
    end;

  if Day > RMDaysPerMonth(Year, Month) then Day := RMDaysPerMonth(Year, Month);
  Result := EncodeDate(Year, Month, Day) + nDays + Frac(dDate);
end;

function RMFirstDayOfPrevMonth(dDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(dDate, Year, Month, Day);
  Day := 1;
  if Month > 1 then
    Dec(Month)
  else begin
    Dec(Year);
    Month := 12;
  end;
  Result := EncodeDate(Year, Month, Day);
end;

procedure TRMAddinFunctionLibrary.DoFunction(aParser: TRMParser; FNo: Integer; p: array of Variant;
  var val: Variant);
var
  liCount: Integer;
  Str: string;
  liChar: Char;

  function _IsWordPresent(const W, S: string; const WordDelims: TrmCharSet): Boolean;
  var
    Count, I: Integer;
  begin
    Result := False;
    Count := RMWordCount(S, WordDelims);
    for I := 1 to Count do
    begin
      if RMExtractWord(I, S, WordDelims) = W then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  function _NPos(const C: string; S: string; N: Integer): Integer;
  var
    I, P, K: Integer;
  begin
    Result := 0;
    K := 0;
    for I := 1 to N do
    begin
      P := Pos(C, S);
      Inc(K, P);
      if (I = N) and (P > 0) then
      begin
        Result := K;
        Exit;
      end;
      if P > 0 then
        Delete(S, 1, P)
      else
        Exit;
    end;
  end;

  function _PadCenter(cStr: string; nWidth: Integer; cChar: string): string;
  var
    nPerSide: Integer;
    cResult: string;
  begin
    nPerSide := (nWidth - Length(cStr)) div 2;
    cResult := RMPadLeft(cStr, (Length(cStr) + nPerSide), cChar);
    Result := RMPadRight(cResult, nWidth, cChar);
  end;

  function _EndPos(cStr, cSubStr: string): Integer;
  var
    nCou: Integer;
    nLenSS: Integer;
    nLenS: Integer;
  begin
    nLenSS := Length(cSubStr);
    nLenS := Length(cStr);
    Result := 0;

    if nLenSS > nLenS then Exit;

    for nCou := nLenS downto 1 do
    begin
      if Copy(cStr, nCou, nLenSS) = cSubStr then
      begin
        Result := nCou;
        Exit;
      end;
    end;
  end;

  function _Delete(s: string; aIndex, aCount: Integer): string;
  begin
    Delete(s, aIndex, aCount);
    Result := s;
  end;

  function _Insert(str, str1: string; lIndex: Integer): string;
  begin
    Insert(str, str1, lIndex);
    Result := str1;
  end;

  function _CompareStr(cStr1, cStr2: string): Integer;
  var
    nLenMax: Integer;
    nCou: Integer;
  begin
    Result := 0;
    if Length(cStr1) > Length(cStr2) then
      nLenMax := Length(cStr1)
    else
      nLenMax := Length(cStr2);

    for nCou := 1 to nLenMax do
    begin
      if Copy(cStr1, nCou, 1) <> Copy(cStr2, nCou, 1) then
      begin
        Result := nCou;
        Exit;
      end;
    end;
  end;

  function _IsRangeNum(nBeg, nEnd, nValue: Extended): Boolean;
  begin
    Result := (nValue >= nBeg) and (nValue <= nEnd);
  end;

  function _CreateDate(cDate: string): string;
  begin
    if not RMValidDate(cDate) then
      val := 'null'
    else
      val := CHR(39) + FormatDateTime(RMFFormatDate, StrToDateTime(cDate)) + CHR(39);
  end;

  function _CreateStr(cStr: string): string;
  begin
    if Trim(cStr) = '' then
      val := 'null'
    else
      val := CHR(39) + cStr + CHR(39);
  end;

  function _CreateNum(cNum: string): string;
  begin
    if Trim(cNum) = '' then
      val := 'null'
    else
      val := RMReplaceStr(cNum, DecimalSeparator, '.');
  end;

  procedure _DateDiffEx(dDate1, dDate2: TDateTime; var cDelta: string);
  var
    DtSwap: TDateTime;
    Day1, Day2, Month1, Month2, Year1, Year2: Word;
    Days, Months, Years: Word;
  begin
    if dDate1 > dDate2 then begin
      DtSwap := dDate1;
      dDate1 := dDate2;
      dDate2 := DtSwap;
    end;
    DecodeDate(dDate1, Year1, Month1, Day1);
    DecodeDate(dDate2, Year2, Month2, Day2);
    Years := Year2 - Year1;
    Months := 0;
    Days := 0;
    if Month2 < Month1 then begin
      Inc(Months, 12);
      Dec(Years);
    end;
    Inc(Months, Month2 - Month1);
    if Day2 < Day1 then
    begin
      Inc(Days, RMDaysPerMonth(Year1, Month1));
      if Months = 0 then
      begin
        Dec(Years);
        Months := 11;
      end
      else Dec(Months);
    end;
    Inc(Days, Day2 - Day1);
    cDelta := IntToStr(Days) + ';' + IntToStr(Months) + ';' + IntToStr(Years);
  end;

  function _IncDate(dDate: TDateTime; cDelta: string): TDateTime;
  var
    nDay, nMonth, nYear: LongInt;
  begin
    nDay := StrToInt(RMExtractWord(1, cDelta, [';']));
    nMonth := StrToInt(RMExtractWord(2, cDelta, [';']));
    nYear := StrToInt(RMExtractWord(3, cDelta, [';']));
    Result := RMIncDate(dDate, nDay, nMonth, nYear);
  end;

  function _IncTimeEx(dTime: TDateTime; cDelta: string): TDateTime;
  var
    nHours, nMinutes, nSeconds, nMSecs: Integer;
  begin
    nHours := StrToInt(RMExtractWord(1, cDelta, [';']));
    nMinutes := StrToInt(RMExtractWord(2, cDelta, [';']));
    nSeconds := StrToInt(RMExtractWord(3, cDelta, [';']));
    nMSecs := StrToInt(RMExtractWord(4, cDelta, [';']));

    Result := dTime + (nHours div 24) + (((nHours mod 24) * 3600000 +
      nMinutes * 60000 + nSeconds * 1000 + nMSecs) / MSecsPerDay);

    if Result < 0 then Result := Result + 1;
  end;

  function _FirstDayOfNextMonth(dDate: TDateTime): TDateTime;
  var
    Year, Month, Day: Word;
  begin
    DecodeDate(dDate, Year, Month, Day);
    Day := 1;
    if Month < 12 then
      Inc(Month)
    else begin
      Inc(Year);
      Month := 1;
    end;
    Result := EncodeDate(Year, Month, Day);
  end;

  function _LastDayOfPrevMonth(dDate: TDateTime): TDateTime;
  var
    D: TDateTime;
    Year, Month, Day: Word;
  begin
    D := RMFirstDayOfPrevMonth(dDate);
    DecodeDate(D, Year, Month, Day);
    Day := RMDaysPerMonth(Year, Month);
    Result := EncodeDate(Year, Month, Day);
  end;

  function _IsRangeDate(dBegDate, dEndDate, dDate: TDateTime): Boolean;
  begin
    if (dDate >= dBegDate) and (dDate <= dEndDate) then
      Result := True
    else
      Result := False
  end;

begin
  val := '0';
  case FNo of
    0: // WordPosition
      val := RMWordPosition(aParser.Calc(p[0]), aParser.Calc(p[1]), RMConvCS(aParser.Calc(p[2])));
    1: // ExtractWord
      val := RMExtractWord(aParser.Calc(p[0]), aParser.Calc(p[1]), RMConvCS(aParser.Calc(p[2])));
    2: // WordCount
      val := RMWordCount(aParser.Calc(p[0]), RMConvCS(aParser.Calc(p[1])));
    3: // IsWordPresent
      val := _IsWordPresent(aParser.Calc(p[0]), aParser.Calc(p[1]), RMConvCS(aParser.Calc(p[1])));
    4: // NPos
      val := _NPos(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    5: // ReplaceStr
      val := RMReplaceStr(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    6: // Replicate
      val := RMReplicate(aParser.Calc(p[0]), aParser.Calc(p[1]));
    7: // PadLeft
      val := RMPadLeft(aParser.Calc(p[2]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    8: // PadRight
      val := RMPadRight(aParser.Calc(p[2]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    9: // PadCenter
      val := _PadCenter(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    10: // EndPos
      val := _EndPos(aParser.Calc(p[0]), aParser.Calc(p[1]));
    11: // LeftCopy
      begin
        liCount := aParser.Calc(p[1]);
        val := Copy(aParser.Calc(p[0]), 1, liCount);
      end;
    12: // RightCopy
      begin
        val := '';
        str := aParser.Calc(p[0]);
        liCount := aParser.Calc(p[1]);
        if liCount > Length(Str) then Exit;
        val := Copy(Str, (Length(Str) - liCount + 1), Length(Str));
      end;
    13: // Delete
      val := _Delete(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    14: // Insert
      val := _Insert(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    15: // CompareStr
      val := _CompareStr(aParser.Calc(p[0]), aParser.Calc(p[1]));
    16: // TrimRight
      val := TrimRight(aParser.Calc(p[0]));
    17: // TrimLeft
      val := TrimLeft(aParser.Calc(p[0]));
    18: // DatetoStr
      val := DateToStr(aParser.Calc(p[0]));
    19: // TimeToStr
      val := TimeToStr(aParser.Calc(p[0]));
    20: // Chr
      val := Chr(Byte(aParser.Calc(p[0])));
    21: // ValidInt
      begin
        val := True;
        try
          StrToInt(aParser.Calc(p[0]));
        except
          val := False;
        end;
      end;
    22: // ValidFloat
      begin
        val := True;
        try
          StrToFloat(aParser.Calc(p[0]));
        except
          val := False;
        end;
      end;
    23: // IsRangeNum
      val := _IsRangeNum(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    24: // StrToFloatDef
      begin
        try
          val := StrToFloat(aParser.Calc(p[0]));
        except
          val := aParser.Calc(p[1]);
        end;
      end;
    25: // StrToIntDef
      val := StrToIntDef(aParser.Calc(p[0]), aParser.Calc(p[1]));
    26: // StrToInt
      val := StrToInt(aParser.Calc(p[0]));
    27: // StrToFloat
      val := StrToFloat(aParser.Calc(p[0]));
    28: // CreateDate
      val := _CreateDate(aParser.Calc(p[0]));
    29: // CreateStr
      val := _CreateStr(aParser.Calc(p[0]));
    30: // CreateNum
      val := _CreateNum(aParser.Calc(p[0]));
    31: // DateDiff
      begin
        Str := aParser.Calc(p[2]);
        _DateDiffEx(aParser.Calc(p[0]), aParser.Calc(p[1]), Str);
      end;
    32: // IncDate
      val := _IncDate(aParser.Calc(p[0]), aParser.Calc(p[1]));
    33: // IncTime
      val := _IncTimeEx(aParser.Calc(p[0]), aParser.Calc(p[1]));
    34: // DaysPerMonth
      val := RMDaysPerMonth(aParser.Calc(p[0]), aParser.Calc(p[1]));
    35: // FirstdayOfNextMonth
      val := _FirstDayOfNextMonth(aParser.Calc(p[0]));
    36: // FirstdayOfPrevMonth
      val := RMFirstDayOfPrevMonth(aParser.Calc(p[0]));
    37: // LastDayOfPrevMonth
      val := _LastDayOfPrevMonth(aParser.Calc(p[0]));
    38: // IncDay
      val := aParser.Calc(p[0]) + aParser.Calc(p[1]);
    39: // IncYear
      val := RMIncDate(aParser.Calc(p[0]), 0, 0, aParser.Calc(p[1]));
    40: // IsRangeDate
      val := _IsRangeDate(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    41: // StrToDateDef
      begin
        try
          val := StrToDate(aParser.Calc(p[0]))
        except
          val := aParser.Calc(p[1]);
        end;
      end;
    42: // ValidDate
      begin
        val := True;
        try
          StrToDate(aParser.Calc(p[0]))
        except
          val := False;
        end;
      end;
    43: // IncMonth
      val := RMIncDate(aParser.Calc(p[0]), 0, aParser.Calc(p[1]), 0);
    44: // IsLeapYear
      val := RMIsLeapYear(aParser.Calc(p[0]));
    45: // swap
      begin
      end;
    46: // Ord
      begin
        str := aParser.Calc(p[0]);
        if str <> '' then
        begin
          liChar := str[1];
          val := Ord(liChar);
        end;  
      end;
  end;
end;

initialization
  RMFFormatDate := '';
  RMRegisterFunctionLibrary(TRMAddInFunctionLibrary);

finalization
end.

