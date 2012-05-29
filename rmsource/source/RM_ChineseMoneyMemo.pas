{***********************************************************
// 函数名称 :
// 参    数 :  None
//
// 作    者 :  ＳＩＮＭＡＸ            　　　　　　　　　　
// 　　　　 "._`-.　　　　 (\-.　              　
// 　　　　　　'-.`;.--.___/ _`>　     　　　　　　
// 　　　　　　　 `"( )　　, ) 　      　　　　　
// 　　　　　　　　　\\----\-\　       　　　　　
// 　　　 ~~ ~~~~~~ "" ~~ """ ~~~~~~~~~　　　　
// 创建日期 :  2003-01-06      　
// 实现目标 :  中国样式财务单元格                        　 　　　　
// 修改记录 :   作者：David (xac@163.com)
//              修改: 廖伯志 1.你的MonyView--小数位变化时，显示有误，我的已修正}
//         最后修该人　郎　正　  Email : Sinmax@163.net
// 工作路径 :              　　　　
// 备    注 : RM3.0  Puls单元                               　　　　　
//***********************************************************}

unit RM_ChineseMoneyMemo;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, RM_Class, RM_Common
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMChineseMoneyObject = class(TComponent) // fake component
  end;

  { TRMMoneyView }
  TRMMoneyView = class(TRMCustomMemoView)
  private
    FWorkCellWidth: integer;
    FWorkCellOffset: integer;
    FDigitalSymbols: tstringlist;
    FDecimalSymbols: tstringlist;
    FIsTitle: Boolean;
    FHaveTitle: Boolean;
    FGridLineWidth: integer;
    FDigitalNumber: integer;
    FDecimalNumber: integer;
    FDecimalSeparatorColor: TColor;
    FKilobitSeparatorColor: TColor;
    FGridLineColor: TColor;
    FCurrencySymbol: string;
  protected
    procedure DrawGrid(Canvas: TCanvas);
    procedure DrawText(Canvas: TCanvas; Text: string);
    procedure DrawTitle(Canvas: TCanvas);
    function GetViewCommon: string; override;
    function GetPrintGridLine: Boolean;
    procedure SetPrintGridLine(Value: Boolean);
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetExportMode: TRMExportMode; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property GridLineWidth: integer read FGridLineWidth write FGridLineWidth;
    property GridLineColor: TColor read FGridLineColor write FGridLineColor;
    property DigitalNumber: integer read FDigitalNumber write FDigitalNumber;
    property DecimalNumber: integer read FDecimalNumber write FDecimalNumber;
    property DecimalSeparatorColor: TColor read FDecimalSeparatorColor write FDecimalSeparatorColor;
    property KilobitSeparatorColor: TColor read FKilobitSeparatorColor write FKilobitSeparatorColor;
    property IsTitle: Boolean read FIsTitle write FIsTitle;
    property HaveTitle: Boolean read FHaveTitle write FHaveTitle;
    property CurrencySymbol: string read FCurrencySymbol write FCurrencySymbol;
    property PrintGridLine: Boolean read GetPrintGridLine write SetPrintGridLine;
    property ExportAsNumber;
    property DataField;
  end;

implementation

uses RM_Utils, RM_Const, RM_Const1;

{ TRMMoneyView }

const
  flMemoIsHeader = $2000;
  flMemoPrintGridLine = $400;

constructor TRMMoneyView.Create;
begin
  inherited Create;
  Typ := rmgtAddin;
  BaseName := 'MoneyMemo';

  CurrencySymbol := '￥';
  IsTitle := False;
  DigitalNumber := 12; //数字的位数
  DecimalNumber := 2; //小数的位数
  GridLineWidth := 1; //分割线的宽度
  DecimalSeparatorColor := clRed; //小数点分割线的颜色
  KilobitSeparatorColor := clBlack; //千位分割线的颜色
  GridLineColor := clSilver; //分割线的颜色

  FDecimalSymbols := TStringlist.Create;
  FDigitalSymbols := TStringlist.Create;
  FHaveTitle := True;

  FDigitalSymbols.Add('元');
  FDigitalSymbols.Add('十');
  FDigitalSymbols.Add('百');
  FDigitalSymbols.Add('千');
  FDigitalSymbols.Add('万');
  FDigitalSymbols.Add('十');
  FDigitalSymbols.Add('百');
  FDigitalSymbols.Add('千');
  FDigitalSymbols.Add('亿');
  FDigitalSymbols.Add('十');
  FDigitalSymbols.Add('百');
  FDigitalSymbols.Add('千');
  FDigitalSymbols.Add('万');
  FDigitalSymbols.Add('兆');
  FDigitalSymbols.Add('十');
  FDecimalSymbols.Add('角');
  FDecimalSymbols.Add('分');
  FDecimalSymbols.Add('厘');
  FDecimalSymbols.Add('毫');
  FDecimalSymbols.Add('微');
end;

destructor TRMMoneyView.Destroy;
begin
  FDigitalSymbols.free;
  FDecimalSymbols.free;
  inherited Destroy;
end;

function TRMMoneyView.GetExportMode: TRMExportMode;
begin
  Result := rmemPicture;
end;

procedure TRMMoneyView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  CalcGaps;
  ShowBackground;
  ShowFrame;
  DrawGrid(aCanvas);
  if Istitle then
    DrawTitle(aCanvas)
  else
  begin
    if HaveTitle then
      DrawTitle(aCanvas);
    if trim(Memo1.Text) <> '' then
      DrawText(aCanvas, trim(Memo1.Text));
  end;

//  DrawGrid(aCanvas);
  RestoreCoord;
end;

type
  THackReport = class(TRMReport)
  end;

procedure TRMMoneyView.DrawGrid(Canvas: TCanvas);
var
  I: Integer;
  OldPenColor: TColor;
  OldPenWidth: Integer;
  OldPenPos: TPoint;
  x, y, dx, dy: Integer;
begin
  if (ParentReport.DocMode <> rmdmDesigning) and (not THackReport(ParentReport).Flag_PrintBackGroundPicture)
    and (not PrintGridLine) then
    Exit;

  x := spLeft;
  y := spTop;
  dx := spWidth;
  dy := spHeight;
  OldPenColor := Canvas.Pen.Color;
  OldPenWidth := Canvas.Pen.Width;
  OldPenPos := Canvas.PenPos;
  Canvas.Pen.Width := GridLineWidth;
  for I := 1 to DigitalNumber - 1 do
  begin
    if ((DigitalNumber - DecimalNumber - I) = 0) then
    begin //liliang edit 颜色设为无色时,其风格应为psClear
      Canvas.Pen.Color := DecimalSeparatorColor;
      if DecimalSeparatorColor = clNone then
        Canvas.Pen.Style := psClear;
    end
    else if ((DigitalNumber - DecimalNumber - I) mod 3 = 0) then
    begin
      Canvas.Pen.Color := KilobitSeparatorColor;
      if KilobitSeparatorColor = clNone then
        Canvas.Pen.Style := psClear;
    end
    else
    begin
      Canvas.Pen.Color := GridLineColor;
      if GridLineColor = clNone then
        Canvas.Pen.Style := psClear;
    end;

    FWorkCellWidth := (dx - GridLineWidth * (DigitalNumber - 1)) div DigitalNumber;
    FWorkCellOffset := round(Dx) - GridLineWidth * (DigitalNumber - 1) - FWorkCellWidth * DigitalNumber;

    Canvas.MoveTo(x + (FWorkCellWidth + GridLineWidth) * I - GridLineWidth + FWorkCellOffset, y + 0);
    Canvas.LineTo(x + (FWorkCellWidth + GridLineWidth) * I - GridLineWidth + FWorkCellOffset, y + DY);
  end;

  if (not IsTitle) and HaveTitle then
  begin
    y := spTop + spHeight div 2;
    Canvas.Pen.Color := KilobitSeparatorColor;
    if KilobitSeparatorColor = clNone then
      Canvas.Pen.Style := psClear;
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x + dx, y);
  end;

  Canvas.Pen.Color := OldPenColor;
  Canvas.Pen.Width := OldPenWidth;
  Canvas.PenPos := OldPenPos;
end;

procedure TRMMoneyView.DrawText(Canvas: TCanvas; Text: string);
var
  e, I, J, Len, LenStart: Integer;
  XOffset, YOffset: Integer;
  TheRect: TRect;
  r: real;
  FDotLength: integer;
  x, y, dx, dy: Integer;
  lCurrencySymbol: string;
  // FCurrencySymbolAligned:boolean;
begin
  // FCurrencySymbol:='$';//货币符号
  x := spLeft;
  dx := spWidth;
  if (not IsTitle) and HaveTitle then
  begin
    dy := spHeight div 2;
    y := spTop + dy;
  end
  else
  begin
    y := spTop;
    dy := spHeight;
  end;

  //  format('%6.1f',
  FDotLength := 1;
  //  FCurrencySymbolAligned:=false;
  Canvas.Font.Assign(Font);
  //*************************************************2002.1.17 LBZ

  val(text, r, e);
  if DecimalNumber = 0 then
    text := floattostr(int(r));

  text := trim(text);
  j := Pos('.', Text);
  if j > 0 then
    text := copy(text, 1, j + DecimalNumber);
  //*************************************************
  Len := Length(Text);
  j := Pos('.', Text);
  if j = 0 then
  begin
    for i := 1 to DecimalNumber do
    begin
      if i = 1 then
        Text := Text + '.0'
      else
        Text := Text + '0';
    end;
  end
  else
  begin
    for i := 1 to DecimalNumber - (Len - J) do
      Text := Text + '0';
  end;

  Len := Length(Text);
  FWorkCellWidth := (dx - GridLineWidth * (DigitalNumber - 1)) div DigitalNumber;
  FWorkCellOffset := dx - GridLineWidth * (DigitalNumber - 1) - FWorkCellWidth * DigitalNumber;
  lCurrencySymbol := CurrencySymbol;
  if DigitalNumber - (Len - FDotLength) < 1 then
    lCurrencySymbol := '';

  if (lCurrencySymbol <> '') then
  begin
    if (DigitalNumber - (Len - FDotLength) < 1) then
    begin
      Text := StringOfChar('*', DigitalNumber - DecimalNumber - 1) + StringOfChar('.', FDotLength) +
        StringOfChar('*', DecimalNumber);
    end;
  end
  else
  begin
    if (DigitalNumber - (Len - FDotLength) < 0) then
    begin
      Text := StringOfChar('*', DigitalNumber - DecimalNumber) + StringOfChar('.', FDotLength) + StringOfChar('*',
        DecimalNumber);
    end;
  end;

  XOffset := (FWorkCellWidth - Canvas.TextWidth(lCurrencySymbol)) div 2;
  YOffset := (DY - Canvas.TextHeight(lCurrencySymbol)) div 2 + 1;
  Len := length(Text);
  if DecimalNumber = 0 then
    inc(len);
  delete(Text, Len - DecimalNumber, 1);
  LenStart := DigitalNumber - Len;

      //画出货币符号
  if lCurrencySymbol <> '' then
  begin
    TheRect := Rect(X + XOffset - GridLineWidth + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * LenStart, Y
      + YOffset, FWorkCellWidth + X + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * LenStart, Y + DY -
      YOffset);
    Canvas.TextRect(TheRect, X + xoffset + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * LenStart, Y +
      YOffset, lCurrencySymbol);
  end;
  
  XOffset := (FWorkCellWidth - Canvas.TextWidth('0')) div 2;
  YOffset := (DY - Canvas.TextHeight('0')) div 2 + 1;
  for I := 1 to Len - 1 do
    Canvas.TextOut(x + XOffset + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * (I + LenStart), Y + YOffset,
      TEXT[i]);
end;

procedure TRMMoneyView.DrawTitle(Canvas: TCanvas);
var
  I, len: Integer;
  XOffset, YOffset: Integer;
  // TheRect: TRect;
  x, y, dx, dy: Integer;
begin
  x := spLeft;
  y := spTop;
  dx := spWidth;
  if (not IsTitle) and HaveTitle then
    dy := spHeight div 2
  else
    dy := spHeight;

  Canvas.Font.Assign(Font);
  if DigitalNumber > 19 then
    Exit;
  if decimalNumber > 5 then
    Exit;
  len := DigitalNumber - DecimalNumber;

  FWorkCellWidth := round((dx - GridLineWidth * (DigitalNumber - 1))) div DigitalNumber;
  FWorkCellOffset := round((dx - GridLineWidth * (DigitalNumber - 1))) - FWorkCellWidth * DigitalNumber;

  XOffset := (FWorkCellWidth - Canvas.TextWidth(FDigitalSymbols.Strings[0])) div 2;
  YOffset := round((DY - Canvas.TextHeight(FDigitalSymbols.Strings[0]))) div 2 + 1;

  for i := 0 to len - 1 do
    Canvas.TextOut(round(x) + XOffset + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * I, round(Y) + YOffset,
      FDigitalSymbols.Strings[Len - 1 - i]);
  for i := Len to DigitalNumber - 1 do
    Canvas.TextOut(round(x) + XOffset + FWorkCellOffset + (FWorkCellWidth + GridLineWidth) * I, round(Y) + YOffset,
      FDecimalSymbols.Strings[i - len]);
end;

procedure TRMMoneyView.LoadFromStream(aStream: TStream);
var
  lVersion: Integer;
begin
  inherited LoadFromStream(aStream);

  FHaveTitle := False;
  lVersion := RMReadWord(aStream);
  DecimalSeparatorColor := RMReadInt32(aStream);
  KilobitSeparatorColor := RMReadInt32(aStream);
  GridLineColor := RMReadInt32(aStream);

  ISTitle := RMReadBoolean(aStream);
  GridLineWidth := RMReadInt32(aStream);
  DigitalNumber := RMReadInt32(aStream);
  DecimalNumber := RMReadInt32(aStream);
  CurrencySymbol := RMReadString(aStream);
  if lVersion >= 1 then
    FHaveTitle := RMReadBoolean(aStream);
end;

procedure TRMMoneyView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 1); // 版本号
  RMWriteInt32(aStream, DecimalSeparatorColor);
  RMWriteInt32(aStream, KilobitSeparatorColor);
  RMWriteInt32(aStream, GridLineColor);
  RMWriteBoolean(aStream, IsTitle);
  RMWriteInt32(aStream, GridLineWidth);
  RMWriteInt32(aStream, DigitalNumber);
  RMWriteInt32(aStream, DecimalNumber);
  RMWriteString(aStream, CurrencySymbol);
  RMWriteBoolean(aStream, FHaveTitle);
end;

function TRMMoneyView.GetPrintGridLine: Boolean;
begin
  Result := (FFlags and flMemoPrintGridLine) = flMemoPrintGridLine;
end;

procedure TRMMoneyView.SetPrintGridLine(Value: Boolean);
begin
  FFlags := (FFlags and not flMemoPrintGridLine);
  if Value then
    FFlags := FFlags + flMemoPrintGridLine;
end;

function TRMMoneyView.GetViewCommon: string;
begin
  Result := '[MoneyView]';
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMMoneyView, 'TRMMoneyView');
  end;
end;

initialization
//  RMRegisterObjectByRes(TRMMoneyView, 'RM_ChineseMoneyMemo', '中国样式财务单元格', nil);
  RMRegisterControls('ReportPage Additional', 'RM_OtherComponent', False,
    [TRMMoneyView],
    ['RM_ChineseMoneyMemo'],
    ['中国样式财务单元格']);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

