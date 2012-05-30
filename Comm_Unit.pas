unit Comm_Unit;

interface
uses
      Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, StdCtrls, nb30,ActiveX;

function NBGetAdapterAddress(a: Integer): string;
function RandomDate(date1: string; date2: string; formatstr: string): string;
function randomDatetime(begindate: string; enddate: string): string;
 function RandomInt(int1: integer; int2: integer; formatstr: string): string;

function RandomTime(formatstr: string): string;
function getMD5(value: string): string;
function getGUID:string;
implementation

uses
      md5;

function NBGetAdapterAddress(a: Integer): string;
var
      NCB: TNCB;
      ADAPTER: TADAPTERSTATUS;
      LANAENUM: TLANAENUM;
      intIdx: Integer;
      cRC: Char;
      strTemp: string;
begin
      Result := '';
      try
            ZeroMemory(@NCB, SizeOf(NCB));
            NCB.ncb_command := Chr(NCBENUM);
            cRC := NetBios(@NCB);
            NCB.ncb_buffer := @LANAENUM;
            NCB.ncb_length := SizeOf(LANAENUM);
            cRC := NetBios(@NCB);
            if Ord(cRC) <> 0 then
                  exit;
            ZeroMemory(@NCB, SizeOf(NCB));
            NCB.ncb_command := Chr(NCBRESET);
            NCB.ncb_lana_num := LANAENUM.lana[a];
            cRC := NetBios(@NCB);
            if Ord(cRC) <> 0 then
                  exit;

            ZeroMemory(@NCB, SizeOf(NCB));
            NCB.ncb_command := Chr(NCBASTAT);
            NCB.ncb_lana_num := LANAENUM.lana[a];
            StrPCopy(NCB.ncb_callname, '*');
            NCB.ncb_buffer := @ADAPTER;
            NCB.ncb_length := SizeOf(ADAPTER);
            cRC := NetBios(@NCB);
            strTemp := '';
            for intIdx := 0 to 5 do
                  strTemp := strTemp + InttoHex(Integer(ADAPTER.adapter_address[intIdx]), 2);
            Result := strTemp;
      finally
      end;
end;

function getAllMacAddress(): string;
var
      index: integer;
      mac: string;
      R_Str: string;
begin
      index := 0;
      repeat
            mac := NBGetAdapterAddress(index);
            if R_Str = '' then
            begin
                  if mac <> '' then
                  begin
                        R_Str := mac;
                  end;

            end
            else
            begin
                  if mac <> '' then
                  begin
                        R_Str := R_Str + ',' + mac;
                  end;
            end;
            index := index + 1;
      until mac = '';
end;






function RandomDate(date1: string; date2: string; formatstr: string): string;
var
      bDate, eDate: TDate;
      format: TFormatSettings;
      i: Integer;
begin
      format.ShortDateFormat := 'yyyy-MM-dd';
      format.DateSeparator := '-';
      bDate := StrToDate(date1, format);
      eDate := StrToDate(date2, format); ;
      i := round(eDate - bDate);
      i := Random(i);
      if formatstr = '' then
            Result := FormatDateTime('yyyy-MM-dd', bDate + i)
      else
            Result := FormatDateTime(formatstr, bDate + i);
    //ShowMessage(Result);
end;


function RandomTime(formatstr: string): string;
var
      vStartTime, vEndTime: TTime;
      T: Real;
      R: Real;
begin
      Randomize;
      vStartTime := StrToTime('00:00:00 ');
      vEndTime := StrToTime('23:59:57 ');
      T := vEndTime - vStartTime;
      R := Random;
      while R > T do R := R - T;
      Result := FormatDateTime(formatstr, vStartTime + R);

end;

function randomDatetime(begindate: string; enddate: string): string;
begin
    Result:=RandomDate(begindate,enddate,'')+' '+RandomTime('hh:mm:ss');
end;

function RandomInt(int1: integer; int2: integer; formatstr: string): string;
begin
      Result := FormatFloat(formatstr, int1 + random(round(int2 - int1))+random);
end;

function getMD5(value: string): string;
begin
      Result := MD5Print(MD5String(value));
end;
function getGUID:string;
var
  guid:TGUID;
begin
  CoCreateGuid(Guid);
  Result:=GUIDToString(guid) ;
end;

end.

