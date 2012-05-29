
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{             Report Pars                 }
{                                         }
{*****************************************}

unit RM_Parser;

{$I RM.INC}

interface

uses
  Windows, SysUtils, Classes, Forms, RM_Common
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMGetPValueEvent = procedure(aVariableName: WideString; var aValue: Variant) of object;
  TRMFunctionEvent = procedure(aFunctionName: string; aParams: array of Variant;
    var aValue: Variant; var aFound: Boolean) of object;

   { TRMParser }
  TRMParser = class(TRMCustomParser)
  private
    FInScript: Boolean;
    FOnGetValue: TRMGetPValueEvent;
    FOnFunction: TRMFunctionEvent;

    function GetString(const aStr: WideString; var i: Integer): WideString;
  public
    function Str2OPZ(aStr: WideString): WideString; override;
    function CalcOPZ(const aStr: WideString): Variant;
    function Calc(aStr: Variant): Variant; override;

    function GetIdentify(const aStr: WideString; var i: Integer): WideString; override;
    procedure GetParameters(const aStr: WideString; var aIndex: Integer; var aParams: array of Variant); override;

    property OnGetValue: TRMGetPValueEvent read FOnGetValue write FOnGetValue;
    property OnFunction: TRMFunctionEvent read FOnFunction write FOnFunction;
    property InScript: Boolean read FInScript write FInScript;
  end;

implementation

uses
  RM_Utils;

const
  ttGe = #1;
  ttLe = #2;
  ttNe = #3;
  ttOr = #4;
  ttAnd = #5;
  ttInt = #6;
  ttFrac = #7;
  ttUnMinus = #9;
  ttUnPlus = #10;
  ttStr = #11;
  ttNot = #12;
  ttMod = #13;
  ttRound = #14;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMParser}

function TRMParser.CalcOPZ(const aStr: WideString): Variant;
var
  i, j, k, i1, st: Integer;
  s1, s2: WideString;
  lParams: array[0..10] of Variant;
  nm: array[1..11] of Variant;
  v: Double;
  lFound: Boolean;

  procedure _RMSetNullValue;

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
    if (FParentReport = nil) or TRMCustomReport(FParentReport).ConvertNulls then Exit;
//    if not RMUseNull then Exit;

    if (nm[st - 2] = Null) or (nm[st - 1] = Null) then
    begin
      if nm[st - 2] = Null then
      begin
        _SetValue(nm[st - 2], nm[st - 1]);
      end
      else if nm[st - 1] = Null then
      begin
        _SetValue(nm[st - 1], nm[st - 2]);
      end;
    end;
  end;

begin
  st := 1;
  i := 1;
  nm[1] := 0;
  while i <= Length(aStr) do
  begin
    j := i;
    case aStr[i] of
      '+', ttOr:
        begin
          _RMSetNullValue;
          nm[st - 2] := nm[st - 2] + VarAsType(nm[st - 1], TVarData(nm[st - 2]).VType);
        end;
      '-':
        begin
          _RMSetNullValue;
          nm[st - 2] := nm[st - 2] - nm[st - 1];
        end;
      '*', ttAnd:
        begin
          _RMSetNullValue;
          nm[st - 2] := nm[st - 2] * nm[st - 1];
        end;
      '/':
        begin
          _RMSetNullValue;
          if nm[st - 1] <> 0 then
            nm[st - 2] := nm[st - 2] / nm[st - 1]
          else
            nm[st - 2] := 0;
        end;
      '>':
        begin
          _RMSetNullValue;
          if nm[st - 2] > nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      '<':
        begin
          _RMSetNullValue;
          if nm[st - 2] < nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      '=':
        begin
          _RMSetNullValue;
          if nm[st - 2] = nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      ttNe:
        begin
          _RMSetNullValue;
          if nm[st - 2] <> nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      ttGe:
        begin
          _RMSetNullValue;
          if nm[st - 2] >= nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      ttLe:
        begin
          _RMSetNullValue;
          if nm[st - 2] <= nm[st - 1] then
            nm[st - 2] := 1
          else
            nm[st - 2] := 0;
        end;
      ttInt:
        begin
          _RMSetNullValue;
          v := nm[st - 1];
          if Abs(Round(v) - v) < 1E-10 then
            v := Round(v)
          else
            v := Int(v);
          nm[st - 1] := v;
        end;
      ttFrac:
        begin
          _RMSetNullValue;
          v := nm[st - 1];
          if Abs(Round(v) - v) < 1E-10 then
            v := Round(v);
          nm[st - 1] := Frac(v);
        end;
      ttRound:
        begin
          if nm[st - 1] = Null then
            nm[st - 1] := 0;

          nm[st - 1] := Integer(Round(nm[st - 1]));
        end;
      ttUnMinus:
        begin
          if nm[st - 1] = Null then
            nm[st - 1] := 0;

          nm[st - 1] := -nm[st - 1];
        end;
      ttUnPlus: ;
      ttStr:
        begin
          if nm[st - 1] <> Null then
            s1 := nm[st - 1]
          else
            s1 := '';

          nm[st - 1] := s1;
        end;
      ttNot:
        begin
          if nm[st - 1] = Null then
            nm[st - 1] := False;

          if nm[st - 1] = 0 then
            nm[st - 1] := 1
          else
            nm[st - 1] := 0;
        end;
      ttMod:
        begin
          _RMSetNullValue;
          nm[st - 2] := nm[st - 2] mod nm[st - 1];
        end;
      ' ': ;
      '[':
        begin
          k := i;
          s1 := RMGetBrackedVariable(aStr, k, i);
          if Assigned(FOnGetValue) then
            FOnGetValue(s1, nm[st]);
          Inc(st);
        end
    else //case else
      if aStr[i] = '''' then
      begin
        s1 := GetString(aStr, i);
        s1 := Copy(s1, 2, Length(s1) - 2);
        while Pos('''' + '''', s1) <> 0 do
          Delete(s1, Pos('''' + '''', s1), 1);
        nm[st] := s1;
        k := i;
      end
      else
      begin
        k := i;
        s1 := GetIdentify(aStr, k);
        if (s1 <> '') and RMWideCharIn(s1[1], ['0'..'9', '.', ',']) then
        begin
          for i1 := 1 to Length(s1) do
          begin
            if RMWideCharIn(s1[i1], ['.', ',']) then
              s1[i1] := WideChar(DecimalSeparator);
          end;
          nm[st] := StrToFloat(s1);
        end
        else if RMCmp(s1, 'TRUE') then
          nm[st] := 1
        else if RMCmp(s1, 'FALSE') then
          nm[st] := 0
        else if aStr[k] = '[' then
        begin
          //s1 := 'GETARRAY(' + s1 + ', ' + RMGetBrackedVariable(aStr, k, i) + ')';
          //nm[st] := Calc(s1);
          s2 := RMGetBrackedVariable(aStr, k, i);
          nm[st] := s1 + WideString(Calc(s2));
          k := i;
        end
        else if aStr[k] = '(' then
        begin
          s1 := AnsiUpperCase(s1);
          GetParameters(aStr, k, lParams);
          if Assigned(FOnFunction) then
            FOnFunction(s1, lParams, nm[st], lFound);
          Dec(k);
        end
        else if Assigned(FOnGetValue) then
        begin
          if not VarIsEmpty(nm[st]) then
            VarClear(nm[st]);
          FOnGetValue(AnsiUpperCase(s1), nm[st]);
        end;
      end;

      i := k;
      Inc(st);
    end; //case

    if RMWideCharIn(aStr[j], ['+', '-', '*', '/', '>', '<', '=', ttGe, ttLe, ttNe, ttOr, ttAnd, ttMod]) then
      Dec(st);
    Inc(i);
  end; // do

  Result := nm[1];
end;

function TRMParser.GetIdentify(const aStr: WideString; var i: Integer): WideString;
var
  k, n: Integer;
begin
  n := 0;
  while (i <= Length(aStr)) and (aStr[i] <= ' ') do
    Inc(i);
  k := i;
  Dec(i);
  repeat
    Inc(i);
    while (i <= Length(aStr)) and
      not RMWideCharIn(aStr[i], [' ', #13, '+', '-', '*', '/', '>', '<', '=', '(', ')', '[']) do
    begin
      if aStr[i] = '"' then
        Inc(n);
      Inc(i);
    end;
  until (n mod 2 = 0) or (i >= Length(aStr));
  Result := Copy(aStr, k, i - k);
end;

function TRMParser.GetString(const aStr: WideString; var i: Integer): WideString;
var
  k: Integer;
  f: Boolean;
begin
  k := i;
  Inc(i);
  repeat
    while (i <= Length(aStr)) and (aStr[i] <> '''') do
      Inc(i);
    f := True;
    if (i < Length(aStr)) and (aStr[i + 1] = '''') then
    begin
      f := False;
      Inc(i, 2);
    end;
  until f;
  Result := Copy(aStr, k, i - k + 1);
  Inc(i);
end;

procedure TRMParser.GetParameters(const aStr: WideString; var aIndex: Integer;
  var aParams: array of Variant);
var
  c, d, oi, ci: Integer;
  i: Integer;
begin
  c := 1;
  d := 1;
  oi := aIndex + 1;
  ci := 1;
  repeat
    Inc(aIndex);
    if aStr[aIndex] = '''' then
    begin
      if d = 1 then
        Inc(d)
      else
        d := 1;
    end;
    if d = 1 then
    begin
      if aStr[aIndex] = '(' then
        Inc(c)
      else if aStr[aIndex] = ')' then
        Dec(c);
      if (aStr[aIndex] = ',') and (c = 1) then
      begin
        aParams[ci - 1] := Copy(aStr, oi, aIndex - oi);
        oi := aIndex + 1;
        Inc(ci);
      end;
    end;
  until (c = 0) or (aIndex >= Length(aStr));

  if aIndex - oi > 0 then  // dejoy 2006-07-13 09:28  修正以适应形如myfunc()这样的调用方式
    aParams[ci - 1] := Copy(aStr, oi, aIndex - oi)
  else
    aParams[ci - 1] := Null;

  if c <> 0 then
    raise Exception.Create('');

  Inc(aIndex);
  for i := ci to High(aParams) do
    aParams[i] := Null{''};
end;

function TRMParser.Str2OPZ(aStr: WideString): WideString;
label
  1;
var
  i, i1, j, p: Integer;
  lStack: WideString;
  lResultStr, s1, s2: WideString;
  lParams: array[0..10] of Variant;
  lFlag: Boolean;
  lChar: Char;

  function _Priority(aChar: Char): Integer;
  begin
    case aChar of
      '(': Result := 5;
      ')': Result := 4;
      '=', '>', '<', ttGe, ttLe, ttNe: Result := 3;
      '+', '-', ttUnMinus, ttUnPlus: Result := 2;
      '*', '/', ttOr, ttAnd, ttNot, ttMod: Result := 1;
      ttInt, ttFrac, ttRound, ttStr: Result := 0;
    else
      Result := 0;
    end;
  end;

begin
  lResultStr := '';  lStack := '';  i := 1;  lFlag := False;
  while i <= Length(aStr) do
  begin
    case aStr[i] of
      '(':
        begin
          lStack := '(' + lStack;
          lFlag := False;
        end;
      ')':
        begin
          p := Pos('(', lStack);
          lResultStr := lResultStr + Copy(lStack, 1, p - 1);
          lStack := Copy(lStack, p + 1, Length(lStack) - p);
        end;
      '+', '-', '*', '/', '>', '<', '=':
        begin
          if (aStr[i] = '<') and (aStr[i + 1] = '>') then
          begin
            Inc(i);
            aStr[i] := ttNe;
          end
          else if (aStr[i] = '>') and (aStr[i + 1] = '=') then
          begin
            Inc(i);
            aStr[i] := ttGe;
          end
          else if (aStr[i] = '<') and (aStr[i + 1] = '=') then
          begin
            Inc(i);
            aStr[i] := ttLe;
          end;

          1: if not lFlag then
          begin
            if aStr[i] = '-' then
              aStr[i] := ttUnMinus;
            if aStr[i] = '+' then
              aStr[i] := ttUnPlus;
          end;

          lFlag := False;
          if lStack = '' then
            lStack := aStr[i] + lStack
          else if _Priority(Char(aStr[i])) < _Priority(Char(lStack[1])) then
            lStack := aStr[i] + lStack
          else
          begin
            repeat
              lResultStr := lResultStr + lStack[1];
              lStack := Copy(lStack, 2, Length(lStack) - 1);
            until (lStack = '') or (_Priority(Char(lStack[1])) > _Priority(Char(aStr[i])));
            lStack := aStr[i] + lStack;
          end;
        end;
      ';': break;
      ' ', #13: ;
    else
      lFlag := True; s2 := ''; i1 := i;
      if aStr[i] = '%' then
      begin
        s2 := '%' + Char(aStr[i + 1]);
        Inc(i, 2);
      end;
      if aStr[i] = '''' then
        s2 := s2 + GetString(aStr, i)
      else if aStr[i] = '[' then
      begin
        s2 := s2 + '[' + RMGetBrackedVariable(aStr, i, j) + ']';
        i := j + 1;
      end
      else
      begin
        s2 := s2 + GetIdentify(aStr, i);
        if aStr[i] = '[' then
        begin
          s2 := s2 + '[' + RMGetBrackedVariable(aStr, i, j) + ']';
          i := j + 1;
        end;
      end;
      lChar := Char(aStr[i]);
      if (Length(s2) > 0) and RMWideCharIn(s2[1], ['0'..'9', '.', ',']) then
        lResultStr := lResultStr + s2 + ' '
      else
      begin
        s1 := AnsiUpperCase(s2);
        if s1 = 'INT' then
        begin
          aStr[i - 1] := ttInt;
          Dec(i);
          goto 1;
        end
        else if s1 = 'FRAC' then
        begin
          aStr[i - 1] := ttFrac;
          Dec(i);
          goto 1;
        end
        else if s1 = 'ROUND' then
        begin
          aStr[i - 1] := ttRound;
          Dec(i);
          goto 1;
        end
        else if s1 = 'OR' then
        begin
          aStr[i - 1] := ttOr;
          Dec(i);
          goto 1;
        end
        else if s1 = 'AND' then
        begin
          aStr[i - 1] := ttAnd;
          Dec(i);
          goto 1;
        end
        else if s1 = 'NOT' then
        begin
          aStr[i - 1] := ttNot;
          Dec(i);
          goto 1;
        end
        else if s1 = 'STR' then
        begin
          aStr[i - 1] := ttStr;
          Dec(i);
          goto 1;
        end
        else if s1 = 'MOD' then
        begin
          aStr[i - 1] := ttMod;
          Dec(i);
          goto 1;
        end
        else if lChar = '(' then
        begin
          GetParameters(aStr, i, lParams);
          lResultStr := lResultStr + Copy(aStr, i1, i - i1);
        end
        else
          lResultStr := lResultStr + s2 + ' ';
      end;
      Dec(i);
    end;
    Inc(i);
  end;

  if lStack <> '' then
    lResultStr := lResultStr + lStack;
    
  Result := lResultStr;
end;

function TRMParser.Calc(aStr: Variant): Variant;
begin
  if FInScript then
    Result := aStr
  else
    Result := CalcOPZ(Str2OPZ(aStr));
end;

end.

