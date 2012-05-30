unit RM_e_Graphic;

{$I RM.INC}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls, RM_Class;

type
 { TRMGraphicExport }
  TRMGraphicExport = class(TRMExportFilter)
  private
    FScaleX, FScaleY: Double;
  protected
    FFileExtension: string;
    FPageNo: Integer;
    FPageWidth, FPageHeight: Integer;
    procedure DrawbkPicture(aCanvas: TCanvas);
    procedure InternalOnePage(aPage: TRMEndPage); virtual; abstract;

    procedure OnBeginDoc; override;
    procedure OnExportPage(const aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
  end;

implementation

uses RM_Common, RM_Utils;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMGraphicExport }

constructor TRMGraphicExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateFile := False;
  FScaleX := 1;
  FScaleY := 1;
  ShowDialog := True;
end;

destructor TRMGraphicExport.Destroy;
begin
  RMUnRegisterExportFilter(Self);
  inherited Destroy;
end;

procedure TRMGraphicExport.OnBeginDoc;
begin
  FPageNo := 0;
end;

procedure TRMGraphicExport.OnExportPage(const aPage: TRMEndPage);
var
  lFileName: string;
begin
  FPageWidth := Round(aPage.PrinterInfo.ScreenPageWidth * ScaleX);
  FPageHeight := Round(aPage.PrinterInfo.ScreenPageHeight * ScaleY);
  lFileName := ExtractFilePath(FileName) + RMMakeFileName(FileName, FFileExtension, FPageNo + 1);
  ExportStream := TFileStream.Create(lFileName, fmCreate);

  InternalOnePage(aPage);

  FreeAndNil(ExportStream);
  Inc(FPageNo);
end;

procedure TRMGraphicExport.DrawbkPicture(aCanvas: TCanvas);
var
  lbkPic: TRMbkPicture;
  lPic: TPicture;
  r1: TRect;
begin
  lbkPic := ParentReport.EndPages.bkPictures[ParentReport.EndPages[FPageNo].bkPictureIndex];
  if lbkPic = nil then Exit;
  lPic := lbkPic.Picture;
  if lPic.Graphic <> nil then
  begin
    r1 := Rect(0, 0, Round(lPic.Width * FScaleX), Round(lPic.Height * FScaleY));
    OffsetRect(r1, Round(lbkPic.Left * FScaleX), Round(lbkPic.Top * FScaleY));
    RMPrintGraphic(aCanvas, r1, lPic.Graphic, False, True, False);
  end;
end;

end.

