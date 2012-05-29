
{*******************************************}
{                                           }
{          Report Machine v2.0              }
{         Barcode Add-in object             }
{                                           }
{*******************************************}

unit RM_AsBarView;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, RM_Common, RM_Class, RM_Ctrls,
  RM_AsBarCode
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMAsBarCodeObject = class(TComponent) // fake component
  end;

  TRMAsBarCodeAngleType = (rmatNone, rmat90, rmat180, rmat270);

  { TRMBarCodeInfo }
  TRMAsBarCodeInfo = class(TPersistent)
  private
    FBarCode: TAsBarcode;
    FShowText: Boolean;
    FAngle: TRMAsBarCodeAngleType;
    FFont: TFont;

    function GetText: string;
    procedure SetText(Value: string);
    function GetModul: Integer;
    procedure SetModul(Value: Integer);
    function GetRatio: Double;
    procedure SetRatio(Value: Double);
    function GetBarType: TBarcodeType;
    procedure SetBarType(Value: TBarcodeType);
    function GetChecksum: Boolean;
    procedure SetChecksum(Value: Boolean);
    function GetCheckSumMethod: TCheckSumMethod;
    procedure SetCheckSumMethod(Value: TCheckSumMethod);
    procedure SetAngle(Value: TRMAsBarCodeAngleType);
    function GetColor: TColor;
    procedure SetColor(Value: TColor);
    function GetColorBar: TColor;
    procedure SetColorBar(Value: TColor);
    function GetBarcodeHeight: Integer;
    function GetBarcodeWidth: Integer;
    procedure SetBarcodeHeight(const Value: Integer);
    procedure SetBarcodeWidth(const Value: Integer);
    procedure SetTextFont(Value: TFont);
  protected
  public
    constructor Create;
    destructor Destroy; override;

    property BarCode: TAsBarcode read FBarCode write FBarCode;
    property Text: string read GetText write SetText;
    property BarcodeHeight: Integer read GetBarcodeHeight write SetBarcodeHeight;
    property BarcodeWidth: Integer read GetBarcodeWidth write SetBarcodeWidth;
  published
    property ShowText: Boolean read FShowText write FShowText;
    property BarType: TBarcodeType read GetBarType write SetBarType;
    property Checksum: boolean read GetCheckSum write SetCheckSum;
    property CheckSumMethod: TCheckSumMethod read GetCheckSumMethod write SetCheckSumMethod;
    property Angle: TRMAsBarCodeAngleType read FAngle write SetAngle;
    property Color: TColor read GetColor write SetColor;
    property ColorBar: TColor read GetColorBar write SetColorBar;
    property TextFont: TFont read FFont write SetTextFont;
    property Zoom: integer read GetModul write SetModul;
    property Ratio: Double read GetRatio write SetRatio;
  end;

  { TRMAsBarCodeView }
  TRMAsBarCodeView = class(TRMReportView)
  private
    FBarInfo: TRMAsBarCodeInfo;

    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
    function GetAutoSize: Boolean;
    procedure SetAutoSize(Value: Boolean);
  protected
    function GetViewCommon: string; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure DefinePopupMenu(aPopup: TRMCustomMenuItem); override;
    procedure ShowEditor; override;

    property DirectDraw: Boolean read GetDirectDraw write SetDirectDraw;
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
  published
    property BarInfo: TRMAsBarCodeInfo read FBarInfo write FBarInfo;
    property LeftFrame;
    property TopFrame;
    property RightFrame;
    property BottomFrame;
    property FillColor;
    property DataField;
    property PrintFrame;
    property Printable;
    property GapLeft;
    property GapTop;
    property OnPreviewClick;
    property OnPreviewClickUrl;
  end;

implementation

uses RM_Const, RM_Const1, RM_Utils;

const
  flBarcodeDirectDraw = $2;
  flBarCodeAutoSize = $4;
  cbDefaultText = '12345678';

function CreateRotatedFont(Font: TFont; Angle: Integer): HFont;
var
  F: TLogFont;
begin
  GetObject(Font.Handle, SizeOf(TLogFont), @F);
  F.lfEscapement := Angle * 10;
  F.lfOrientation := Angle * 10;
  Result := CreateFontIndirect(F);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBarCodeInfo }

constructor TRMAsBarCodeInfo.Create;
begin
  inherited Create;

  FBarCode := TAsBarcode.Create(nil);
  FShowText := True;
  FBarCode.Height := 50;
  FBarCode.CheckSum := True;
  FBarCode.Modul := 1;
  FBarCode.Ratio := 2;
  FBarCode.Angle := 0;

  FFont := TFont.Create;
  FFont.Color := clBlack;
  FFont.Name := 'Arial';
  FFont.Size := 9;
  FFont.Style := [];
end;

destructor TRMAsBarCodeInfo.Destroy;
begin
  FreeAndNil(FBarCode);
  FFont.Free;
  inherited Destroy;
end;

function TRMAsBarCodeInfo.GetText: string;
begin
  Result := FBarCode.Text;
end;

procedure TRMAsBarCodeInfo.SetText(Value: string);
begin
  FBarCode.Text := Value;
end;

function TRMAsBarCodeInfo.GetModul: Integer;
begin
  Result := FBarCode.Modul{FModul};
end;

procedure TRMAsBarCodeInfo.SetModul(Value: Integer);
begin
  FBarCode.Modul{FModul} := Value;
end;

function TRMAsBarCodeInfo.GetRatio: Double;
begin
  Result := FBarCode.Ratio{ FRatio};
end;

procedure TRMAsBarCodeInfo.SetRatio(Value: Double);
begin
  FBarCode.Ratio{FRatio} := Value;
end;

function TRMAsBarCodeInfo.GetBarType: TBarcodeType;
begin
  Result := FBarCode.Typ;
end;

procedure TRMAsBarCodeInfo.SetBarType(Value: TBarcodeType);
begin
  FBarCode.Typ := Value;
end;

function TRMAsBarCodeInfo.GetChecksum: Boolean;
begin
  Result := FBarCode.Checksum;
end;

procedure TRMAsBarCodeInfo.SetChecksum(Value: Boolean);
begin
  FBarCode.Checksum := Value;
end;

function TRMAsBarCodeInfo.GetCheckSumMethod: TCheckSumMethod;
begin
  Result := FBarCode.CheckSumMethod;
end;

procedure TRMAsBarCodeInfo.SetCheckSumMethod(Value: TCheckSumMethod);
begin
  FBarCode.CheckSumMethod := Value;
end;

procedure TRMAsBarCodeInfo.SetAngle(Value: TRMAsBarCodeAngleType);
begin
  FAngle := Value;
  case Value of
    rmatNone: FBarCode.Angle := 0;
    rmat90: FBarCode.Angle := 90;
    rmat180: FBarCode.Angle := 180;
    rmat270: FBarCode.Angle := 270;
  end;
end;

function TRMAsBarCodeInfo.GetColor: TColor;
begin
  Result := FBarCode.Color;
end;

procedure TRMAsBarCodeInfo.SetColor(Value: TColor);
begin
  FBarCode.Color := Value;
end;

function TRMAsBarCodeInfo.GetColorBar: TColor;
begin
  Result := FBarCode.ColorBar;
end;

procedure TRMAsBarCodeInfo.SetColorBar(Value: TColor);
begin
  FBarCode.ColorBar := Value;
end;

function TRMAsBarCodeInfo.GetBarcodeHeight: Integer;
begin
  Result := FBarcode.Height;
end;

procedure TRMAsBarCodeInfo.SetBarcodeHeight(const Value: Integer);
begin
  FBarcode.Height := Value;
end;

function TRMAsBarCodeInfo.GetBarcodeWidth: Integer;
begin
  Result := FBarcode.Width;
end;

procedure TRMAsBarCodeInfo.SetBarcodeWidth(const Value: Integer);
begin
  FBarcode.Width := Value;
end;

procedure TRMAsBarCodeInfo.SetTextFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMAsBarCodeView}

constructor TRMAsBarCodeView.Create;
begin
  inherited Create;
  BaseName := 'Bar';
  Memo.Add(cbDefaultText);

  FBarInfo := TRMAsBarCodeInfo.Create;
end;

destructor TRMAsBarCodeView.Destroy;
begin
  FreeAndNil(FBarInfo);
  inherited Destroy;
end;

procedure TRMAsBarCodeView.LoadFromStream(aStream: TStream);
var
  lVersion: Word;
begin
  inherited LoadFromStream(aStream);

  lVersion := RMReadWord(aStream);
  FBarInfo.ShowText := RMReadBoolean(aStream);
  FBarInfo.Zoom := RMReadInt32(aStream);
  FBarInfo.Ratio := RMReadFloat(aStream);
  FBarInfo.BarType := TBarcodeType(RMReadByte(aStream));
  FBarInfo.Checksum := RMReadBoolean(aStream);
  FBarInfo.CheckSumMethod := TCheckSumMethod(RMReadByte(aStream));
  FBarInfo.Angle := TRMAsBarCodeAngleType(RMReadByte(aStream));
  FBarInfo.ColorBar := RMReadInt32(aStream);
  if lVersion >= 1 then
    RMReadFont(aStream, FBarInfo.TextFont);
end;

procedure TRMAsBarCodeView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 1); // °æ±¾ºÅ
  RMWriteBoolean(aStream, FBarInfo.ShowText);
  RMWriteInt32(aStream, FBarInfo.Zoom);
  RMWriteFloat(aStream, FBarInfo.Ratio);
  RMWriteByte(aStream, Byte(FBarInfo.BarType));
  RMWriteBoolean(aStream, FBarInfo.Checksum);
  RMWriteByte(aStream, Byte(FBarInfo.CheckSumMethod));
  RMWriteByte(aStream, Byte(FBarInfo.Angle));
  RMWriteInt32(aStream, FBarInfo.ColorBar);
  RMWriteFont(aStream, FBarInfo.TextFont);
end;

procedure TRMAsBarCodeView.Draw(aCanvas: TCanvas);
var
  lStr: string;
  lEmptyStrFlag: Boolean;
  lPicWidth, lPicHeight: Integer;
  lTxtHeight: Integer;

  procedure _DrawOneLine(aCanvas: TMetafileCanvas; x, x1, x2: Integer; s: string);
  begin
    if FBarInfo.BarCode.Angle = 90 then
    begin
      aCanvas.FillRect(Rect(lPicWidth - lTxtHeight, lPicHeight - x1, lPicWidth, lPicHeight - x2 - 1));
      aCanvas.TextOut(lPicWidth - lTxtHeight, lPicHeight - x, s);
    end
    else if FBarInfo.BarCode.Angle = 180 then
    begin
      aCanvas.FillRect(Rect(lPicWidth - x1, 0, lPicWidth - x2 - 1, lTxtHeight + 2));
      aCanvas.TextOut(lPicWidth - x, lTxtHeight, s);
    end
    else if FBarInfo.BarCode.Angle = 270 then
    begin
      aCanvas.FillRect(Rect(0, x1, lTxtHeight, x2 + 1));
      aCanvas.TextOut(lTxtHeight, x, s);
    end
    else
    begin
      aCanvas.FillRect(Rect(x1, lPicHeight - lTxtHeight - 2, x2 + 1, lPicHeight));
      aCanvas.TextOut(x, lPicHeight - lTxtHeight, s);
    end;
  end;

  procedure _DrawText(aCanvas: TMetafileCanvas);
  var
    lOldFont, lNewFont: HFont;
    lBarWidth: Integer;
  begin
    if not FBarInfo.ShowText then Exit;

    lBarWidth := FBarInfo.BarCode.Width;
    lStr := FBarInfo.Text;
    with aCanvas do
    begin
      Font.Assign(FBarInfo.TextFont);
      lNewFont := CreateRotatedFont(Font, Round(FBarInfo.BarCode.Angle));
      lOldFont := SelectObject(Handle, lNewFont);
      Brush.Color := FBarInfo.BarCode.Color;
      case FBarInfo.BarCode.Typ of
        bcCodeEAN8:
          begin
            _DrawOneLine(aCanvas, 3, 3, 30, Copy(lStr, 1, 4));
            _DrawOneLine(aCanvas, 35, 35, lBarWidth - 4, Copy(lStr, 5, 4));
          end;
        bcCodeEAN13:
          begin
            if lStr[1] <> '0' then
              _DrawOneLine(aCanvas, -8, -8, -2, Copy(lStr, 1, 1));

            _DrawOneLine(aCanvas, 3, 3, 44, Copy(lStr, 2, 6));
            _DrawOneLine(aCanvas, 49, 49, lBarWidth - 4, Copy(lStr, 8, 6));
          end;
        bcCodeUPC_A:
          begin
            _DrawOneLine(aCanvas, -8, -8, -2, Copy(lStr, 1, 1));
            _DrawOneLine(aCanvas, 10, 10, 44, Copy(lStr, 2, 5));
            _DrawOneLine(aCanvas, 49, 49, 83, Copy(lStr, 7, 5));
            _DrawOneLine(aCanvas, lBarWidth + 1, lBarWidth + 1, lBarWidth + 8, Copy(lStr, 12, 1));
          end;
        bcCodeUPC_E0, bcCodeUPC_E1:
          begin
            _DrawOneLine(aCanvas, 3, 3, 44, Copy(lStr, 1, 6));
            _DrawOneLine(aCanvas, lBarWidth + 1, lBarWidth + 1, lBarWidth + 8, Copy(lStr, 7, 1));
          end;
      else
        _DrawOneLine(aCanvas, (lBarWidth - TextWidth(lStr)) div 2, 0, lBarWidth, lStr);
      end;

      SelectObject(Handle, lOldFont);
      DeleteObject(lNewFont);
    end;
  end;

  procedure _DrawBarCode(aCanvas: TCanvas; aRect: TRect);
  var
    lEMF: TMetafile;
    lEMFCanvas: TMetafileCanvas;
    lBarWidth: Integer;
    lZoom: Extended;
  begin
    try
      FBarInfo.BarCode.MakeData;
    except
      FBarInfo.Text := cbDefaultText;
      FBarInfo.BarCode.MakeData;
    end;

    lBarWidth := FBarInfo.BarCode.Width;
    if (FBarInfo.BarCode.Angle = 0) or (FBarInfo.BarCode.Angle = 180) then
    begin
      lZoom := (aRect.Right - aRect.Left) / lBarWidth;
      lPicWidth := lBarWidth;
      lPicHeight := Round((aRect.Bottom - aRect.Top) / lZoom);
      FBarInfo.BarCode.Height := lPicHeight;
      if FBarInfo.ShowText then
      begin
        if FBarInfo.BarCode.Typ in [bcCodeEAN8, bcCodeEAN13, bcCodeUPC_A, bcCodeUPC_E0, bcCodeUPC_E1] then
        begin
          FBarInfo.BarCode.Height := lPicHeight - lTxtHeight div 2;
          if FBarInfo.BarCode.Angle = 180 then
            FBarInfo.BarCode.Top := (lTxtHeight + 2) div 2;
        end
        else
        begin
          FBarInfo.BarCode.Height := lPicHeight - lTxtHeight - 2;
          if FBarInfo.BarCode.Angle = 180 then
            FBarInfo.BarCode.Top := lTxtHeight + 2;
        end;
      end;
    end
    else
    begin
      lZoom := (aRect.Bottom - aRect.Top) / lBarWidth;
      lPicWidth := Round((aRect.Right - aRect.Left) / lZoom);
      lPicHeight := lBarWidth;
      FBarInfo.BarCode.Height := lPicWidth;
      if FBarInfo.ShowText then
      begin
        if FBarInfo.BarCode.Typ in [bcCodeEAN8, bcCodeEAN13, bcCodeUPC_A, bcCodeUPC_E0, bcCodeUPC_E1] then
        begin
          FBarInfo.BarCode.Height := lPicWidth - lTxtHeight div 2;
          if FBarInfo.BarCode.Angle = 270 then
            FBarInfo.BarCode.Left := (lTxtHeight + 2) div 2;
        end
        else
        begin
          FBarInfo.BarCode.Height := lPicWidth - lTxtHeight - 2;
          if FBarInfo.BarCode.Angle = 270 then
            FBarInfo.BarCode.Left := lTxtHeight + 2;
        end;
      end;
    end;

    if (lPicWidth > 0) and (lPicHeight > 0) then
    begin
      lEMF := TMetafile.Create;
      lEMF.Width := lPicWidth;
      lEMF.Height := lPicHeight;
      lEMFCanvas := TMetafileCanvas.Create(lEMF, 0);
      try
        FBarInfo.BarCode.DrawBarcode(lEMFCanvas);
        _DrawText(lEMFCanvas);
        FreeAndNil(lEMFCanvas);
        aCanvas.StretchDraw(aRect, lEMF);
      finally
        lEMF.Free;
        lEMFCanvas.Free;
      end;
    end;
  end;

begin
  if (spWidth < 0) or (spHeight < 0) then Exit;

  lTxtHeight := RM_Utils.RMCanvasHeight('aa', FBarInfo.TextFont);
  lEmptyStrFlag := False;
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  if (Memo1.Count > 0) and (Length(Memo1[0]) > 0) and (Memo1[0][1] <> '[') then
    lStr := Trim(Memo1.Strings[0])
  else
  begin
    lEmptyStrFlag := True;
    lStr := cbDefaultText;
  end;

  if bcData[FBarInfo.BarType].Num = False then
    FBarInfo.Text := lStr
  else if RMIsNumeric(lStr) then
    FBarInfo.Text := lStr
  else
  begin
    lEmptyStrFlag := True;
    FBarInfo.Text := cbDefaultText;
  end;

//  FBarInfo.BarCode.Modul := FBarInfo.Modul;
//  FBarInfo.BarCode.Ratio := FBarInfo.Ratio;

//  if AutoSize then
  begin
    try
      if (FBarInfo.BarCode.Angle = 0) or (FBarInfo.BarCode.Angle = 180) then
      begin
      	FBarInfo.BarCode.Width := spWidth;
        spWidth := FBarInfo.BarCode.Width + spGapLeft * 2 + _CalcHFrameWidth(LeftFrame.Width, RightFrame.Width);;
      end
      else
      begin
      	FBarInfo.BarCode.Width := spHeight;
        spHeight := FBarInfo.BarCode.Width + spGapTop * 2 + _CalcVFrameWidth(TopFrame.Width, BottomFrame.Width);
      end;
    except
      on e: Exception do
      begin
      end;
    end;
  end;
//  else
//  begin
//		FBarInfo.Zoom := 1;
//    FBarInfo.Ratio := 2;
//  end;

  CalcGaps;
  ShowBackground;
  if not lEmptyStrFlag then
  begin
    InflateRect(RealRect, -_CalcHFrameWidth(LeftFrame.spWidth, RightFrame.spWidth) - spGapLeft,
      -_CalcVFrameWidth(TopFrame.spWidth, BottomFrame.spWidth) - spGapTop);
    _DrawBarCode(aCanvas, RealRect);
  end;
  ShowFrame;
  RestoreCoord;
end;

procedure TRMAsBarCodeView.PlaceOnEndPage(aStream: TStream);
begin
  inherited;
{  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  InternalOnBeforePrint(Memo1, Self);
  if not Visible then Exit;
//  if IsPrinting and (not PPrintFrame) then Exit;

  if Memo1.Count > 0 then
  begin
    if (Length(Memo1[0]) > 0) and (Memo1[0][1] = '[') then
    begin
      try
        Memo1[0] := ParentReport.Parser.Calc(Memo1[0]);
      except
        Memo1[0] := '0';
      end;
    end;
  end;

  aStream.Write(Typ, 1);
  RMWriteString(aStream, ClassName);
  SaveToStream(aStream);
}end;

procedure TRMAsBarCodeView.DefinePopupMenu(aPopup: TRMCustomMenuItem);
begin
  inherited;
end;

procedure TRMAsBarCodeView.ShowEditor;
begin
end;

function TRMAsBarCodeView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flBarCodeDirectDraw) = flBarCodeDirectDraw;
end;

procedure TRMAsBarCodeView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flBarCodeDirectDraw);
  if Value then
    FFlags := FFlags + flBarCodeDirectDraw;
end;

function TRMAsBarCodeView.GetAutoSize: Boolean;
begin
  Result := (FFlags and flBarCodeAutoSize) = flBarCodeAutoSize;
end;

procedure TRMAsBarCodeView.SetAutoSize(Value: Boolean);
begin
  FFlags := (FFlags and not flBarCodeAutoSize);
  if Value then
    FFlags := FFlags + flBarCodeAutoSize;
end;

function TRMAsBarCodeView.GetViewCommon: string;
begin
  Result := '[BarCode]';
end;

const
  cRM = 'RM_AsBarView';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cRM, TRMAsBarCodeView, 'TRMAsBarCodeView');
  end;
end;

initialization
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);
//  RMRegisterObjectByRes(TRMAsBarCodeView, 'RM_BARCODEOBJECT', RMLoadStr(SInsBarcode), nil);
  RMRegisterControl('ReportPage Additional', 'RM_OtherComponent', False,
    TRMAsBarCodeView, 'RM_BARCODEOBJECT', RMLoadStr(SInsBarcode));

finalization

end.

