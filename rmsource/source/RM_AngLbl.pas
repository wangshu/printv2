
{*****************************************}
{                                         }
{             Report Machine v2.0         }
{         Checkbox Add-In Object          }
{                                         }
{*****************************************}

unit RM_AngLbl;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus,
  RM_Common, RM_Class, RM_Ctrls
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMAngledLabelObject = class(TComponent) // fake component
  end;

  TRMAnchorStyle = (rmasNone, rmasTextLeft, rmasTextCenter, rmasTextRight);
  TRMAngledValues = record
    fntWidth, fntHeight, txtWidth, txtHeight, gapTxtWidth, gapTxtHeight: Integer;
    totWidth, totHeight, posLeft, posTop, posX, posY: Integer
  end;

  { TRMAngledLabelView }
  TRMAngledLabelView = class(TRMCustomMemoView)
  private
    FAnchorStyle: TRMAnchorStyle;
    FAngle: Integer;
    procedure CalculateAngledValues(var aValues: TRMAngledValues; const aStr: WideString);
    procedure DrawAngledLabel(const aStr: WideString);
  protected
    function GetViewCommon: string; override;
  public
    constructor Create; override;
    function GetExportMode: TRMExportMode; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure DefinePopupMenu(aPopup: TRMCustomMenuItem); override;
  published
    property AnchorStyle: TRMAnchorStyle read FAnchorStyle write FAnchorStyle;
    property Angle: Integer read FAngle write FAngle;
    property LeftFrame;
    property RightFrame;
    property TopFrame;
    property BottomFrame;
    property FillColor;
    property ReprintOnOverFlow;
    property ShiftWith;
    property BandAlign;
    property DataField;
  end;

implementation

uses RM_Parser, RM_Utils, RM_Const;

function DegToRad(aDegrees: Real): Real;
begin
  Result := (aDegrees * PI / 180);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMAngledLabelView}

constructor TRMAngledLabelView.Create;
begin
  inherited Create;
  Typ := rmgtAddin;
  BaseName := 'AngledLabel';

  Stretched := False;
  WordWrap := False;
  Angle := 45;
  AnchorStyle := rmasNone;
end;

function TRMAngledLabelView.GetExportMode: TRMExportMode;
begin
	Result := rmemPicture;
end;

procedure TRMAngledLabelView.CalculateAngledValues(var aValues: TRMAngledValues;
  const aStr: WideString);
var
  angB: Real;
  nCenterX, nCenterY: Integer;
  x, y, dx, dy: Integer;
begin
  x := spLeft; y := spTop; dx := spWidth; dy := spHeight;

  aValues.fntWidth := RMWideCanvasTextWidth(Canvas, aStr);
  aValues.fntHeight := RMWideCanvasTextHeight(Canvas, aStr);
  case Angle of
    0..89: angB := DegToRad(90 - Angle);
    90..179: angB := DegToRad(Angle - 90);
    180..269: angB := DegToRad(270 - Angle);
  else { 270..359 }
    angB := DegToRad(Angle - 270)
  end;
  aValues.txtWidth := Round(sin(angB) * aValues.fntWidth);
  aValues.gapTxtWidth := Round(cos(angB) * aValues.fntHeight);
  aValues.txtHeight := Round(cos(angB) * aValues.fntWidth);
  aValues.gapTxtHeight := Round(sin(angB) * aValues.fntHeight);

  aValues.totWidth := (aValues.txtWidth + aValues.gapTxtWidth);
  aValues.totHeight := (aValues.txtHeight + aValues.gapTxtHeight);

  if AnchorStyle in [rmasNone] then
  begin
    aValues.posLeft := x;
    aValues.posTop := y;
  end
  else if AnchorStyle in [rmasTextLeft] then
  begin
    case Angle of 0..89, 270..359:
        aValues.posLeft := x
    else { 90..179, 180..269 }
      aValues.posLeft := (x + dx - aValues.totWidth)
    end;
    case Angle of 180..269, 270..359:
        aValues.posTop := y
    else { 0..89, 90..179 }
      aValues.posTop := (y + dy - aValues.totHeight)
    end;
  end
  else if AnchorStyle in [rmasTextRight] then
  begin
    case Angle of 90..179, 180..269:
        aValues.posLeft := x
    else { 0..89, 270..359 }
      aValues.posLeft := (x + dx - aValues.totWidth)
    end;
    case Angle of 0..89, 90..179:
        aValues.posTop := y
    else { 180..269, 270..359 }
      aValues.posTop := (y + dy - aValues.totHeight)
    end;
  end
  else { asTextCenter }
  begin
    aValues.posLeft := (x + Round((dx - aValues.totWidth) / 2));
    aValues.posTop := (y + Round((dy - aValues.totHeight) / 2));
  end;

  case Angle of
    0..89:
      begin
        aValues.posX := 0;
        aValues.posY := aValues.txtHeight
      end;
    90..179:
      begin
        aValues.posX := aValues.txtWidth;
        aValues.posY := aValues.totHeight
      end;
    180..269:
      begin
        aValues.posX := aValues.totWidth;
        aValues.posY := aValues.gapTxtHeight
      end;
  else { 270..359 }
    aValues.posX := aValues.gapTxtWidth;
    aValues.posY := 0
  end;

  if (AnchorStyle in [rmasTextLeft, rmasTextRight, rmasTextCenter]) then
  begin
    if AnchorStyle in [rmasTextLeft] then
    begin
      case Angle of
        0..89:
          begin
            aValues.posX := 0;
            aValues.posY := (dy - aValues.gapTxtHeight);
          end;
        90..179:
          begin
            aValues.posX := (dx - aValues.gapTxtWidth);
            aValues.posY := dy;
          end;
        180..279:
          begin
            aValues.posX := dx;
            aValues.posY := aValues.gapTxtHeight;
          end;
      else { 280..359 }
        aValues.posX := aValues.gapTxtWidth;
        aValues.posY := 0;
      end;
    end
    else if AnchorStyle in [rmasTextRight] then
    begin
      case Angle of
        0..89:
          begin
            aValues.posX := (dx - aValues.txtWidth - aValues.gapTxtWidth);
            aValues.posY := aValues.txtHeight;
          end;
        90..179:
          begin
            aValues.posX := aValues.txtWidth;
            aValues.posY := (aValues.txtHeight + aValues.gapTxtHeight);
          end;
        180..279:
          begin
            aValues.posX := (aValues.txtWidth + aValues.gapTxtWidth);
            aValues.posY := (dy - aValues.txtHeight);
          end;
      else { 280..359 }
        aValues.posX := (dx - aValues.txtWidth);
        aValues.posY := (dy - aValues.txtHeight - aValues.gapTxtHeight);
      end;
    end
    else { asTextCenter }
    begin
      nCenterX := Round((dx - aValues.txtWidth - aValues.gapTxtHeight) / 2);
      nCenterY := Round((dy - aValues.txtHeight - aValues.gapTxtHeight) / 2);
      case Angle of
        0..89:
          begin
            aValues.posX := nCenterX;
            aValues.posY := (nCenterY + aValues.txtHeight);
          end;
        90..179:
          begin
            aValues.posX := (nCenterX + aValues.txtWidth);
            aValues.posY := (nCenterY + aValues.txtHeight + aValues.gapTxtHeight);
          end;
        180..279:
          begin
            aValues.posX := (nCenterX + aValues.txtWidth + aValues.gapTxtWidth);
            aValues.posY := (nCenterY + aValues.gapTxtHeight);
          end;
      else // 280..359
        aValues.posX := (nCenterX + aValues.gapTxtWidth);
        aValues.posY := nCenterY;
      end;
    end;
  end;
  aValues.posX := aValues.posX + x;
  aValues.posY := aValues.posY + y;
end;

procedure TRMAngledLabelView.DrawAngledLabel(const aStr: WideString);
var
	lValues: TRMAngledValues;
  lNewFont, lOldFont: HFONT;
begin
  AssignFont(Canvas);
  lNewFont := RMCreateAPIFont(Canvas.Font, Angle, 0);
  lOldFont := SelectObject(Canvas.Handle, lNewFont);
  try
    SetTextCharacterExtra(Canvas.Handle, Round(CharacterSpacing * FactorX));
    CalculateAngledValues(lValues, aStr);
    ExtTextOutW(Canvas.Handle, lValues.posX, lValues.posY, ETO_CLIPPED, @RealRect,
      PWideChar(aStr), Length(aStr), nil);
  finally
    SelectObject(Canvas.Handle, lOldFont);
    DeleteObject(lNewFont);
  end;
end;

procedure TRMAngledLabelView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  CalcGaps;
  ShowBackground;
  ShowFrame;
  if Memo1.Count > 0 then
    DrawAngledLabel(Memo1[0]);

  SetTextCharacterExtra(aCanvas.Handle, 0);
  RestoreCoord;
end;

procedure TRMAngledLabelView.DefinePopupMenu(aPopup: TRMCustomMenuItem);
begin
//
end;

procedure TRMAngledLabelView.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Angle := RMReadInt32(aStream);
  AnchorStyle := TRMAnchorStyle(RMReadByte(aStream));
end;

procedure TRMAngledLabelView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteInt32(aStream, Angle);
  RMWriteByte(aStream, Byte(AnchorStyle));
end;

function TRMAngledLabelView.GetViewCommon: string;
begin
  Result := '[Angled Memo]';
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMAngledLabelView, 'TRMAngledLabelView');

    AddConst('ReportMachine', 'rmasNone', rmasNone);
    AddConst('ReportMachine', 'rmasTextLeft', rmasTextLeft);
    AddConst('ReportMachine', 'rmasTextCenter', rmasTextCenter);
    AddConst('ReportMachine', 'rmasTextRight', rmasTextRight);
  end;
end;

initialization
//  RMRegisterObjectByRes(TRMAngledLabelView, 'RM_ANGLEDLABLE', RMLoadStr(SInsAngledLabel), nil);
  RMRegisterControls('ReportPage Additional', 'RM_OtherComponent', False,
    [TRMAngledLabelView],
    ['RM_ANGLEDLABLE'],
    [RMLoadStr(SInsAngledLabel)]);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

