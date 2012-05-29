
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{          PGT Addin Function             }
{                                         }
{    感谢 网友PGT提供  amirery@163.net    }
{*****************************************}

unit RM_PGTFunction;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Classes, Controls, Forms, Dialogs, RM_Class, RM_Common, RM_Parser
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMAddInFunctionLib = class(TComponent);

 { TPGTAddinFunction }
  TRMPGTAddinFunction = class(TRMFunctionLibrary)
  public
    constructor Create; override;
    procedure DoFunction(aParser: TRMParser; FNo: Integer; p: array of Variant; var val: Variant); override;
  end;

function RMPGTGetINI(const KeyName: string; const SubName: string; IniFile: string): string;
{function CutInt(v: Variant): Variant; //提取小数点左边数值
function LeftUpper(S: Variant): Variant; //首字大写
function NumToEn(V: Variant): string; //数字转换为英文大写
function NumToMoney(V: Variant; Dollar: string; Cent: string): string; //数字转换为美元大写
function NumToCn(V: Variant): string; //数字转换为中文大写
function SmallNum(V: Integer): string; //小数字转换为英文大写
function LeftStr(SouStr: string; LeftLen: Word): string; //取左边n位字符
function RightStr(SouStr: string; RightLen: Word): string; //取右边n位字符
function DateToShortStr(V: Variant; StrLx: Integer): string; //英文短日期格式
function DateToLongStr(V: Variant): string; //英文长日期格式
function MyFormatDate(Format: string; DateTime: TDateTime): string; //自定义日期转换为字符串
function Ascii(const Keychr: string): Byte;
function PicExists(var v: string): Boolean; //检查图片文件是否存在
function DayofShortWeek(D: TdateTime): string; //返回短星期格式
function DayofLongWeek(D: TdateTime): string; //返回长星期格式
function myfunction(Name: string; p1, p[1], p[2]: Variant): variant;
function CutRootDir(var v: string): Boolean; //把文件名转换为相对路径
}

{$IFDEF DM_ADO}
(* 注意：此单元请在搜索路径中指定 Sv_Data的路径  *)
function RMPGTInitConnectstring: string; //初始化数据连接字符串 ;
function RMPGTGetFieldValue(TableName: string; WhereCode: string; ReturnFld: string): Variant;
  {例：GetFieldValue('CKHT','合同号=SAMPLE','总金额')  }
{$ENDIF}

var
  ExePath: string; //可执行程序路径
  ReportDir: string; //存放报表文件的目录
  RmRegistOK: Boolean; //程序是否已经注册
  CurOpenFile: string; //当前打开的报表文件
  PrintBase: Boolean = True; //报表打印是否打印背景图
  PrintFrame: Boolean = True; //文本框打印边条
  AllowSetFrame: Boolean = False; //允许设置边条是否打印
  HasBasePic: Boolean; //报表是否带有背景图
  ReportTitle: string = '报表标题'; //报表标题
  ReportSubTitle1: string = '报表子标题一'; //报表子标题1
  ReportSubTitle2: string = '报表子标题二'; //报表子标题2
{$IFDEF DM_ADO}
  SvSetFile: string = 'SerVerConfig.Dll';
{$ENDIF}

implementation

uses Inifiles{$IFDEF DM_ADO}, DB, Clipbrd, Adodb{$ENDIF};

const
  ShortMon: array[0..11] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
  LongMon: array[0..11] of string = ('January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
  CnNum: array[0..11] of string = ('一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二');
  ShortWeek: array[0..6] of string = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  LongWeek: array[0..6] of string = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

{$IFDEF DM_ADO}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ADO Function}

function RMPGTGetFieldValue(TableName: string; WhereCode: string; ReturnFld: string): Variant;
var
  Adoc: TAdoConnection;
  tbl: TadoDataSet;
  SqlStr: string;
  i: integer;
  s: string;
begin
  Screen.Cursor := crHourGlass;
  Adoc := TAdoConnection.Create(Application);
  Adoc.LoginPrompt := False;
  Adoc.Provider := 'MSDASQL';
  if Trim(Adoc.ConnectionString) = '' then
  begin
    Adoc.ConnectionString := RMPGTInitConnectstring;
    Adoc.Open;
  end;
  TableName := Trim(TableName);
  WhereCode := Trim(WhereCode);
  ReturnFld := Trim(ReturnFld);
  if (TableName = '') or (ReturnFld = '') then
  begin
    Result := 'GetFieldValue 函数参数缺少';
    Adoc.Close;
    Adoc.Free;
    Screen.Cursor := CrDefault;
    Exit;
  end;
  s := '';
  for i := 1 to Length(WhereCode) do
  begin
    if WhereCode[i] <> '"' then
      s := s + WhereCode[i]
    else
      s := s + '''';
  end;
  WhereCode := S;
  if WhereCode <> '' then
  begin
    if Pos('WHERE', UpperCase(WhereCode)) = 0 then
      WhereCode := 'Where ' + WhereCode;
  end;
  WhereCode := ' ' + WhereCode + ' ';
  tbl := TadoDataSet.Create(nil);
  tbl.Connection := AdoC;
  SQLStr := 'Select * From ' + TableName + WhereCode;
  Tbl.CommandText := SQLStr;
  Tbl.CommandType := cmdText;
  try
    Tbl.Open;
  except
    Clipboard.AsText := SQLstr;
    Result := '表' + TableName + '不能打开!';
    Adoc.Close;
    Adoc.Free;
    Screen.Cursor := CrDefault;
    Exit;
  end;
  if Tbl.FindField(ReturnFld) = nil then
  begin
    Result := '没有发现字段[' + ReturnFld + ']';
    Screen.Cursor := CrDefault;
    Exit;
  end;
  case Tbl.FieldByName(ReturnFld).DataType of
    FtString, FtMemo, ftFixedChar, ftWideString:
      Result := Trim(Tbl.FieldByName(ReturnFld).AsString);
    ftDate, ftTime, ftDateTime:
      Result := Tbl.FieldByName(ReturnFld).AsDateTime;
    ftBoolean:
      Result := Tbl.FieldByName(ReturnFld).AsBoolean;
    ftSmallint, ftInteger, ftWord, ftLargeint,
      ftFloat, ftCurrency, ftBCD, ftBytes, ftVarBytes:
      Result := Tbl.FieldByName(ReturnFld).AsFloat;
  else
    Result := Tbl.FieldValues[ReturnFld];
  end;
  Tbl.Close;
  Tbl.free;
  Adoc.Close;
  Adoc.Free;
  Screen.Cursor := CrDefault;
end;

function RMPGTInitConnectstring: string; //初始化数据连接字符串 ;
var
  SaveFile: string;
  Tstr: TStringList;
  SaveStr: string;
  SysPath: PChar;
begin
  GetMem(SysPath, 255);
  GetSystemDirectory(SysPath, 255); //获取WINDOWS 系统SYSTEM 目录
  SaveFile := SysPath + '\' + SvSetFile;
  SaveStr := '';
  if FileExists(SaveFile) then
  begin
    TStr := TStringList.Create;
    TStr.LoadFromFile(SaveFile);
    SaveStr := Tstr.Text;
    TStr.Free;
  end;
  SaveStr := Trim(SaveStr);
  Result := SaveStr;
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{Other Function}

function RMPGTGetINI(const KeyName: string; const SubName: string; IniFile: string): string; // 从INI文件中提取数据
var
  MyIni: TiniFile;
begin
  if IniFile = '' then
    IniFile := 'System.Ini';
  if Pos(UpperCase('.'), UpperCase(IniFile)) = 0 then
    IniFile := IniFile + '.ini';
  if Pos('\', IniFile) = 0 then
    IniFile := ExtractFilePath(Application.ExeName) + IniFile;
  if FileExists(IniFile) then
  begin
    MyIni := TiniFile.Create(IniFile);
    if MyIni.ValueExists(KeyName, SubName) then
      Result := MyIni.ReadString(KeyName, SubName, '')
    else
      Result := '不存在关键字[' + KeyName + '][' + SubName + ']';
    MyIni.Free;
  end
  else
  begin
    Result := Inifile + '不存在!';
  end;
end;

function LeftStr(SouStr: string; LeftLen: Word): string; //取左边n位字符
begin
  Result := Copy(SouStr, 1, LeftLen);
end;

function RightStr(SouStr: string; RightLen: Word): string; //取右边n位字符
begin
  Result := Copy(SouStr, Length(SouStr) - RightLen + 1, RightLen);
end;

function LeftUpper(S: Variant): Variant; //首字大写
var
  i: Integer;
  BeginUpper: Boolean;
  TmpStr, Restr: string;
begin
  try
    TmpStr := VarAsType(s, VarString);
  except
    Result := S;
    Exit;
  end;
  BeginUpper := True; ReStr := '';
  for I := 1 to Length(TmpStr) do
  begin
    if BeginUpper = True then
      ReStr := ReStr + UpperCase(TmpStr[i])
    else
      ReStr := ReStr + LowerCase(TmpStr[i]);
    if Pos(TmpStr[i], ' \/`~!@#$%^&*()_+-=|{}[]: ; "" '' <> ?') <> 0 then
      BeginUpper := True
    else
      BeginUpper := False;
  end;
  Result := ReStr;
end;

function SmallNum(V: Integer): string; //小数字转换为英文大写
var
  I_Str: string;
  R_Str: string;
  H_str: string;
begin
  if V > 999 then
  begin
    Result := '数据太大' + FormatFloat('##0', V);
    Exit;
  end;
  R_Str := '';
  I_str := Trim(FormatFloat('##0', V));
  I_str := RightStr('000' + I_str, 3);
  case StrToInt(RightStr(I_str, 2)) of
    0: R_str := '';
    1: R_str := 'ONE';
    2: R_str := 'TWO';
    3: R_str := 'THREE';
    4: R_str := 'FOUR';
    5: R_str := 'FIVE';
    6: R_str := 'SIX';
    7: R_str := 'SEVEN';
    8: R_str := 'EIGHT';
    9: R_str := 'NINE';
    10: R_str := 'TEN';
    11: R_str := 'ELEVEN';
    12: R_str := 'TWELVE';
    13: R_str := 'THIRTEEN';
    14: R_str := 'FOURTEEN';
    15: R_str := 'FIFTEEN';
    16: R_str := 'SIXTEEN';
    17: R_str := 'SEVENTEEN';
    18: R_str := 'EIGHTEEN';
    19: R_str := 'NINETEEN';
    20: R_str := 'TWENTY';
    30: R_str := 'THIRTY';
    40: R_str := 'FORTY';
    50: R_str := 'FIFTY';
    60: R_str := 'SIXTY';
    70: R_str := 'SEVENTY';
    80: R_str := 'EIGHTY';
    90: R_str := 'NINETY';
  else
    case StrToInt(Copy(I_str, 2, 1)) of
      0: R_str := '';
      1: R_str := '';
      2: R_str := 'TWENTY-';
      3: R_str := 'THIRTY-';
      4: R_str := 'FORTY-';
      5: R_str := 'FIFTY-';
      6: R_str := 'SIXTY-';
      7: R_str := 'SEVENTY-';
      8: R_str := 'EIGHTY-';
      9: R_str := 'NINETY-';
    end;
    case StrToInt(Copy(I_str, 3, 1)) of
      0: R_str := R_str + '';
      1: R_str := R_str + 'ONE';
      2: R_str := R_str + 'TWO';
      3: R_str := R_str + 'THREE';
      4: R_str := R_str + 'FOUR';
      5: R_str := R_str + 'FIVE';
      6: R_str := R_str + 'SIX';
      7: R_str := R_str + 'SEVEN';
      8: R_str := R_str + 'EIGHT';
      9: R_str := R_str + 'NINE';
    end;
  end;
  H_Str := '';
  case StrToInt(Copy(I_str, 1, 1)) of
    0: H_str := '';
    1: H_str := 'ONE';
    2: H_str := 'TWO';
    3: H_str := 'THREE';
    4: H_str := 'FOUR';
    5: H_str := 'FIVE';
    6: H_str := 'SIX';
    7: H_str := 'SEVEN';
    8: H_str := 'EIGHT';
    9: H_str := 'NINE';
  else
    ShowMessage('不可预料的情况');
  end;
  if (H_Str <> '') and (R_Str <> '') then
    I_str := H_Str + ' HUNDRED AND ' + R_Str
  else if (H_Str <> '') and (R_Str = '') then
    I_str := H_Str + ' HUNDRED ' + R_Str
  else if (H_Str = '') and (R_Str <> '') then
    I_str := R_Str
  else if (H_Str = '') and (R_Str = '') then
    I_str := '';
  Result := I_Str;
end;

function DayofShortWeek(D: TdateTime): string; //返回短星期格式
begin
  Result := ShortWeek[DayOfWeek(d) - 1];
end;

function DayofLongWeek(D: TdateTime): string; //返回长星期格式
begin
  Result := LongWeek[DayOfWeek(d) - 1];
end;

function CutRootDir(var v: string): Boolean; //把文件名转换为相对路径
var
  sv, RootDir: string;
begin
  sv := v;
  RootDir := ExtractFileDir(Application.ExeName) + '\';
  if CompareText(RootDir, LeftStr(sv, Length(RootDir))) = 0 then
  begin
    v := Copy(sv, Length(RootDir) + 1, 255);
    Result := True;
  end
  else
    Result := False;
end;

function PicExists(var V: string): Boolean; //检查图片文件是否存在
var
  S, Sdir, Sname, PicDir: string;
begin
  s := V;
  Result := True;
  if FileExists(s) then
    Exit;
  if Trim(CurOpenFile) <> '' then
  begin //首先在报表所在目录中查找
    SName := ExtractFileName(s);
    Sdir := ExtractFileDir(CurOpenFile);
    if FileExists(Sdir + '\' + sName) then
    begin
      v := Sdir + '\' + sName;
      Exit;
    end;
    Sdir := ExtractFileDir(Sdir); //再一次减去子目录+\BitMaps
    if FileExists(Sdir + '\BitMaps\' + sName) then
    begin
      v := Sdir + '\BitMaps\' + sName;
      Exit;
    end;
    if FileExists(Sdir + '\BitBmps\' + sName) then
    begin
      v := Sdir + '\BitBmps\' + sName;
      Exit;
    end;
  end;
  if not FileExists(s) then
  begin //其次在程序运行的目录中查找
    Sdir := Trim(ExtractFileDir(S));
    SName := ExtractFileName(S);
    if (Pos('\', Sdir) = 0) and (Sdir <> '') then
      PicDir := ExtractFileDir(Application.ExeName) + '\' + Sdir + '\'
    else
      PicDir := ExtractFileDir(Application.ExeName) + '\BitMaps\';
    if FileExists(Picdir + sName) then
      V := PicDir + sName
    else
    begin
      PicDir := ExtractFileDir(Application.ExeName) + '\BitBmps\';
      if FileExists(Picdir + s) then
        V := PicDir + s
      else
        Result := False;
    end;
  end;
end;

function Ascii(const Keychr: string): Byte;
var
  I, ReturnAscii: Byte;
begin
  ReturnAscii := 0;
  for I := 0 to 255 do
  begin
    if Chr(I) = KeyChr then
    begin
      ReturnAscii := I;
      Break;
    end;
  end;
  Ascii := ReturnAscii;
end;

function PGTFormatDate(Format: string; DateTime: TDateTime): string; //自定义日期转换为字符串
var
  TmpStr, TmpForMat: string;
  MonType, i, at: Integer;
  FindStr: string;
  Bstr, eStr, EnMon: string;
  UType: Integer; //大小写类型
  c: string;
begin
  TmpForMat := '';
  for i := 1 to Length(Format) do
  begin
    if UpperCase(ForMat[i]) = 'M' then
      c := LowerCase(Format[i])
    else
      c := Format[i];
    TmpForMat := TmpForMat + C;
  end;
  TmpFormat := Trim(TmpForMat);
  TmpStr := FormatDateTime(tmpFormat, DateTime);
  if Pos('MMMM', UpperCase(ForMat)) <> 0 then
    MonType := 2 //月份是完整的
  else
    Montype := 1; //否则为短格式月份
  if Pos('MMM', ForMat) <> 0 then
    UType := 1 //全部大写
  else if Pos('Mmm', ForMat) <> 0 then
    UType := 2 //首字母大写
  else if Pos('mmm', ForMat) <> 0 then
    UType := 3 //全部小写
  else
    Utype := 0; //默认  首字母大写

  FindStr := '';
  for i := 11 downto 0 do
  begin
    FindStr := CnNum[i] + '月';
    at := Pos(FindStr, TmpStr); //检查中文月份是否在值中
    if at <> 0 then
    begin
      Bstr := LeftStr(TmpStr, At - 1);
      estr := RightStr(TmpStr, Length(TmpStr) - at - Length(FindStr) + 1);
      if Montype = 2 then
        EnMon := LongMon[i]
      else
        EnMon := ShortMon[i];
      case uType of
        1: enMon := UpperCase(enMon);
        2: enMon := LeftUpper(enMon);
        3: enMon := LowerCase(enMon);
      end;
      TmpStr := bStr + enMon + estr;
      Break;
    end;
  end;
  Result := TmpStr;
end;


function CutInt(v: Variant): Variant; //提取小数点左边数值
var
  V_str, V_Bgn: string;
begin
  try
    V_str := Trim(ForMatFloat('####.00', V));
    V_Bgn := V_Str;
    if Pos('.', V_Str) <> 0 then
    begin
      V_Bgn := Trim(Leftstr(V_Str, Pos('.', V_Str) - 1));
    end;
    Result := StrToInt(V_Bgn);
  except
    Result := v;
  end;
end;


function NumToEn(V: Variant): string; //数字转换为英文大写
var
  V_Str, V_Bgn, V_End: string;
  Split, I: Integer;
  TmpNum: string;
  Re_str, Dec_str: string;
begin
  Re_str := '';
  TmpNum := '';
  Split := 0;
  V_str := Trim(ForMatFloat('#,##0.00', v));
  V_Bgn := V_Str;
  V_End := '';
  if Pos('.', V_Str) <> 0 then
  begin
    V_Bgn := Leftstr(V_Str, Pos('.', V_Str) - 1);
    V_End := RightStr(V_Str, Length(V_str) - Pos('.', V_Str));
  end;
  if Length(Trim(V_Bgn)) = 0 then
    V_Bgn := '0';
  if Length(Trim(V_End)) = 0 then
    V_End := '0';
  for I := Length(V_Bgn) downto 1 do
  begin
    if V_Bgn[I] <> ',' then
    begin
      TmpNum := V_Bgn[i] + TmpNum;
    end
    else
    begin
      Split := Split + 1;
      case Split of
        1: Re_str := SmallNum(StrToInt(TmpNum)) + Re_str;
        2: Re_str := SmallNum(StrToInt(TmpNum)) + ' THOUSAND ' + Re_Str;
        3: Re_str := SmallNum(StrToInt(TmpNum)) + ' MILLION ' + Re_Str;
      else
        begin
          Re_str := '超出设计范围';
          Break;
        end;
      end;
      TmpNum := '';
    end;
  end;
  if TmpNum <> '' then
  begin
    Split := Split + 1;
    case Split of
      1: Re_str := SmallNum(StrToInt(TmpNum)) + Re_str;
      2: Re_str := SmallNum(StrToInt(TmpNum)) + ' THOUSAND ' + Re_Str;
      3: Re_str := SmallNum(StrToInt(TmpNum)) + ' MILLION ' + Re_Str;
    else
      begin
        Result := '超出设计范围';
        Exit;
      end;
    end;
  end;
  if StrToInt(V_End) <> 0 then
  begin
    Dec_Str := SmallNum(StrToIntDef(V_END, 0));
    Re_str := Re_str + ' AND ' + DEC_STR + ' CENT';
  end;
  Result := Re_Str;
end;

function NumToMoney(V: Variant; SDollar: Variant; SCent: Variant): string; //数字转换为美元大写
var
  V_Str, V_Bgn, V_End: string;
  Split, I: Integer;
  TmpNum: string;
  Re_str, Dec_str: string;
  CanD: Boolean;
  Dollar, Cent: string;
begin
  Re_str := '';
  TmpNum := '';
  try Dollar := VartoStr(SDollar); except Dollar := 'DOLLAR'; end;
  try Cent := VartoStr(SCent); except Cent := 'CENT'; end;

  Split := 0;
  V_str := Trim(ForMatFloat('#,##0.00', V));
  V_Bgn := V_Str;
  V_End := '';
  if Pos('.', V_Str) <> 0 then
  begin
    V_Bgn := Leftstr(V_Str, Pos('.', V_Str) - 1);
    V_End := RightStr(V_Str, Length(V_str) - Pos('.', V_Str));
  end;
  if Length(Trim(V_Bgn)) = 0 then
    V_Bgn := '0';
  if Length(Trim(V_End)) = 0 then
    V_End := '0';
  for I := Length(V_Bgn) downto 1 do
  begin
    if V_Bgn[I] <> ',' then
    begin
      TmpNum := V_Bgn[i] + TmpNum;
    end
    else
    begin
      Split := Split + 1;
      case Split of
        1: Re_str := SmallNum(StrToInt(TmpNum)) + Re_str;
        2: Re_str := SmallNum(StrToInt(TmpNum)) + ' THOUSAND ' + Re_Str;
        3: Re_str := SmallNum(StrToInt(TmpNum)) + ' MILLION ' + Re_Str;
      else
        begin
          Re_str := '超出设计范围';
          Break;
        end;
      end;
      TmpNum := '';
    end;
  end;
  if TmpNum <> '' then
  begin
    Split := Split + 1;
    case Split of
      1: Re_str := SmallNum(StrToInt(TmpNum)) + Re_str;
      2: Re_str := SmallNum(StrToInt(TmpNum)) + ' THOUSAND ' + Re_Str;
      3: Re_str := SmallNum(StrToInt(TmpNum)) + ' MILLION ' + Re_Str;
    else
      begin
        Result := '超出设计范围';
        Exit;
      end;
    end;
  end;
  Dollar := UpperCase(Dollar);
  if (Trunc(V) > 1) and (Ascii(Dollar[1]) < 128) then
  begin
    if Rightstr(Dollar, 1) = 'Y' then
      Dollar := LeftStr(Dollar, Length(Dollar) - 1) + 'IES'
    else
      Dollar := Dollar + 'S';
  end;
  Re_str := Re_str + ' ' + Dollar;
  if StrToInt(V_End) <> 0 then
  begin
    Dec_Str := SmallNum(StrToInt(V_END));
    TmpNum := Cent;

    if StrToInt(V_End) > 1 then
    begin
      CanD := True; // 可以变复数
      for i := 1 to Length(cent) do
      begin
        if Ascii(Cent[i]) >= 128 then
        begin
          Cand := False;
          Break;
        end;
      end;
      Cent := UpperCase(Cent);
      if Cand then
      begin
        if RightStr(Cent, 1) = 'Y' then
          Cent := LeftStr(Cent, Length(Cent) - 1) + 'IES'
        else
          Cent := Cent + 'S';
      end;
    end;

    if Pos('>', Cent) > 0 then
    begin // 去除>符号 如果有>符号,则美分置右
      Cent := '';
      for i := 1 to Length(TmpNum) do
      begin
        if Tmpnum[i] <> '>' then
          Cent := Cent + TmpNum[i];
      end;
    end;
    if Pos('>', TmpNum) = 0 then
      Re_str := Re_str + ' AND ' + Trim(CENT) + ' ' + DEC_STR
    else
      Re_str := Re_str + ' AND ' + DEC_STR + ' ' + Trim(CENT);
  end;
  Result := UpperCase(Re_Str);
end;

function DateToShortStr(V: Variant; StrLx: Integer): string; //日期转换为英文短日期格式
var
  MonthStr: string;
  Month: string;
begin
  Month := Trim(FormatDateTime('m', V));
  if Length(Month) = 0 then
  begin
    Result := FormatDateTime('dd mmm yyyy', V);
    Exit;
  end;
  MOnthStr := '';
  case StrToInt(Month) of
    1: MonthStr := 'Jan';
    2: MonthStr := 'Feb';
    3: MonthStr := 'Mar';
    4: MonthStr := 'Apr';
    5: MonthStr := 'May';
    6: MonthStr := 'Jun';
    7: MonthStr := 'Jul';
    8: MonthStr := 'Aug';
    9: MonthStr := 'Sep';
    10: MonthStr := 'Oct';
    11: MonthStr := 'Nov';
    12: MonthStr := 'Dec';
  else
    MonthStr := '***';
  end;
  case StrLx of
    7: Result := UpperCase(MonthStr) + FormatDateTime(' dd', V) + FormatDateTime(' yyyy', V);
    8: Result := UpperCase(MonthStr) + '.' + FormatDateTime(' dd,', V) + FormatDateTime(' yyyy', V);
  else
    Result := UpperCase(MonthStr) + FormatDateTime(' dd', V) + FormatDateTime(' yyyy', V);
  end;
end;

function DateToLongStr(V: Variant): string; //日期转换为英文长日期格式
var
  MonthStr: string;
  Month: string;
begin
  Month := Trim(FormatDateTime('m', V));
  if Length(Month) = 0 then
  begin
    Result := FormatDateTime('dd mmm yyyy', V);
    Exit;
  end;
  MOnthStr := '';
  case StrToInt(Month) of
    1: MonthStr := 'January';
    2: MonthStr := 'February';
    3: MonthStr := 'March';
    4: MonthStr := 'April';
    5: MonthStr := 'May';
    6: MonthStr := 'June';
    7: MonthStr := 'July';
    8: MonthStr := 'August';
    9: MonthStr := 'September';
    10: MonthStr := 'October';
    11: MonthStr := 'November';
    12: MonthStr := 'December';
  else
    MonthStr := '***';
  end;
  Result := UpperCase(MonthStr) + FormatDateTime(' dd,', V) + FormatDateTime(' yyyy', V);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPGTAddinFunction}

constructor TRMPGTAddinFunction.Create;
begin
  inherited Create;
  with List do
  begin
    Add('CutInt');
    Add('DayofLongWeek');
    Add('DayofShortWeek');
    Add('LeftUpper');
    Add('NumToEn');
    Add('NumToMoney');
    Add('SmallNum');
    Add('LeftStr');
    Add('RightStr');
    Add('DateToShortStr');
    Add('DateToLongStr');
    Add('PGTFormatDate');
    Add('Ascii');
    Add('PicExists');
{$IFDEF DM_ADO}
    Add('InitConnectstring');
    Add('GetFieldValue');
{$ENDIF}
  end;

  AddFunctionDesc('CutInt', RMftstring, 'CutInt|(Value)提取小数点左边数值', 'N');
  AddFunctionDesc('DayofLongWeek', rmftDateTime, 'DayofLongWeek(Date)|返回长星期格式', 'D');
  AddFunctionDesc('DayofShortWeek', rmftDateTime, 'DayofShortWeek(Date)|返回短星期格式', 'D');
  AddFunctionDesc('LeftUpper', rmftString, 'LeftUpper(String)|首字大写', 'S');
  AddFunctionDesc('NumToEn', rmftMath, 'NumToEn(Value)|数字转换为英文大写', 'N');
  AddFunctionDesc('NumToMoney', rmftMath, 'NumToMoney(Value, Dollar, Cent)|数字转换为美元大写,如果Cent带">"符号,则CENT置右 ', 'NSS');
  AddFunctionDesc('LeftStr', rmftString, 'LeftStr(String, n)|取左边n位字符', 'SN');
  AddFunctionDesc('RightStr', rmftString, 'RightStr(String, n)|取右边n位字符', 'SN');
  AddFunctionDesc('DateToShortStr', rmftDateTime, 'DateToShortStr(Date, StrLx)|英文短日期格式', 'DN');
  AddFunctionDesc('DateToLongStr', rmftDateTime, 'DateToLongStr(Date)|英文长日期格式', 'D');
  AddFunctionDesc('PGTFormatDate', rmftDateTime, 'PGTFormatDate(Foramt, Date)|自定义日期转换为字符串', 'SD');
  AddFunctionDesc('Ascii', rmftString, 'Ascii(Char)|取字符的Ascii码', 'S');
  AddFunctionDesc('PicExists', rmftBoolean, 'PicExists(FileName)|检查图片文件是否存在', 'S');
{$IFDEF DM_ADO}
  AddFunctionDesc('InitConnectstring', RMftInterpreter, 'InitConnectstring()|初始化数据连接字符串', '');
  AddFunctionDesc('GetFieldValue', rmftMath, 'GetFieldValue(TableName, Where, FieldName)|取得表<Table>中符合<Where>条件的记录的字段<FieldName>的值', 'SSS');
{$ENDIF}
end;

procedure TRMPGTAddinFunction.DoFunction(aParser: TRMParser; FNo: Integer; p: array of Variant;
  var val: Variant);
var
  s: string;
begin
  val := '0';
  case FNo of
    0: Val := CutInt(aParser.Calc(p[0]));
    1: Val := DayofLongWeek(aParser.Calc(p[0]));
    2: Val := DayofShortWeek(aParser.Calc(p[0]));
    3: Val := LeftUpper(aParser.Calc(p[0]));
    4: Val := NumToEn(aParser.Calc(p[0]));
    5: Val := NumToMoney(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
    6: Val := SmallNum(aParser.Calc(p[0]));
    7: Val := LeftStr(aParser.Calc(p[0]), aParser.Calc(p[1]));
    8: Val := RightStr(aParser.Calc(p[0]), aParser.Calc(p[1]));
    9: Val := DateToShortStr(aParser.Calc(p[0]), aParser.Calc(p[1]));
    10: Val := DateToLongStr(aParser.Calc(p[0]));
    11: Val := PGTFormatDate(aParser.Calc(p[0]), aParser.Calc(p[1]));
    12: Val := Ascii(aParser.Calc(p[0]));
    13:
      begin
        s := aParser.Calc(p[0]);
        Val := PicExists(s);
      end;
{$IFDEF DM_ADO}
    14: Val := RMPGTInitConnectstring;
    15: Val := RMPGTGetFieldValue(aParser.Calc(p[0]), aParser.Calc(p[1]), aParser.Calc(p[2]));
{$ENDIF}
  end;
end;

initialization
  RMRegisterFunctionLibrary(TRMPGTAddinFunction);

finalization
  RMUnRegisterFunctionLibrary(TRMPGTAddinFunction);

end.

