unit RM_E_llPDF;

interface

{$I RM.INC}
{$IFDEF llPDFlib}
uses Classes, Windows, Sysutils, Graphics, PDF, RM_Common, RM_Class;

type

  { TRMllPDFExport }
  TRMllPDFExport = class(TRMExportFilter)
  private
    FPdf: TPDFDocument;
    FPageNo: Integer;
    FAlpha: Extended;
    FShowAfterExport: Boolean;
    FScaleX: Double;
    FScaleY: Double;
    FShowBackPicture: Boolean;
  protected
    procedure DrawbkPicture(aCanvas: TCanvas);
    procedure OnExportPage(const aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
//    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property ShowAfterExport: Boolean read FShowAfterExport write FShowAfterExport;
    property ShowBackPicture: Boolean read FShowBackPicture write FShowBackPicture;
  end;

{$ENDIF}
implementation

{$IFDEF llPDFlib}
uses
  ShellAPI, RM_Const, RM_Const1, RM_Utils;

{ TRMllPDFExport }

constructor TRMllPDFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  RMRegisterExportFilter(Self, 'Adobe Acrobat Documents (*.pdf)', '*.pdf');

  FShowBackPicture := True;
  FScaleX := 1;
  FScaleY := 1;
  FShowAfterExport := True;
  FPdf := TPDFDocument.Create(Self);
  CreateFile := False;
end;

destructor TRMllPDFExport.Destroy;
begin
  RMUnRegisterExportFilter(Self);
  FreeAndNil(FPdf);
  inherited;
end;

procedure TRMllPDFExport.OnBeginDoc;
var
  lDC: HDC;
begin
  inherited;
  if FPdf.Printing then FPdf.Abort;

  FPdf.FileName := FileName;
  FPdf.OutputStream := ExportStream;
  FPdf.Compression := ctFlate;
  FPdf.NonEmbeddedFont.Add('WingDings');
  FPdf.OnePass := True;
  lDC := GetDC(0);
  FPdf.Resolution := GetDeviceCaps(lDc, LOGPIXELSX);
  FAlpha := 1; //FPdf.Resolution / 91.4;
  ReleaseDC(0, lDC);

  FPdf.BeginDoc;
  FPageNo := -1;
end;

procedure TRMllPDFExport.OnEndDoc;
begin
  try
    FPdf.EndDoc;
    if FShowAfterExport then
      ShellExecute(0, nil, PChar(FPdf.FileName), nil, nil, SW_RESTORE);
  except
    on Exception do
    begin
      FPdf.Abort;
      raise;
    end;
  end;
end;

type
  THackView = class(TRMView);

procedure TRMllPDFExport.OnExportPage(const aPage: TRMEndPage);
var
  i: Integer;
  t: TRMReportView;
  lOffsetTop, lOffsetLeft: Integer;
begin
  Inc(FPageNo);
  if FPageNo <> 0 then
    FPdf.NewPage;

  FPdf.CurrentPage.Width := Round(aPage.PrinterInfo.ScreenPageWidth * FAlpha);
  FPdf.CurrentPage.Height := Round(aPage.PrinterInfo.ScreenPageHeight * FAlpha);

  if FShowBackPicture then
    DrawbkPicture(Fpdf.Canvas);

  lOffsetLeft := aPage.spMarginLeft;
  lOffsetTop := aPage.spMarginTop;
  for i := 0 to aPage.Page.Objects.Count - 1 do
  begin
    t := aPage.Page.Objects[i];
    if t.IsBand or (t is TRMSubReportView) then Continue;

  // ÷–Œƒœ‘ æ
    if t is TRMCustomMemoView then
    begin
      FPdf.CurrentPage.SetActiveFont(TRMCustomMemoView(t).Font.Name,
        TRMCustomMemoView(t).Font.Style, TRMCustomMemoView(t).Font.Size,
        TRMCustomMemoView(t).Font.Charset);
    end;
    
    THackView(t).IsPrinting := False;
    try
      THackView(t).FactorX := 1;
      THackView(t).FactorY := 1;
      THackView(t).OffsetLeft := lOffsetLeft;
      THackView(t).OffsetTop := lOffsetTop;
      t.Draw(FPdf.Canvas);
    finally
      THackView(t).IsPrinting := False;
    end;
  end;
end;

procedure TRMllPDFExport.DrawbkPicture(aCanvas: TCanvas);
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

{$ENDIF}
end.

