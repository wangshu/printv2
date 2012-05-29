
{******************************************************}
{                                                      }
{          Report Machine v3.0                         }
{            XLS export filter                         }
{                                                      }
{         write by whf and jim_waw(jim_waw@163.com)    }
{******************************************************}

unit RM_e_Xls;

interface

{$I RM.inc}
{$IFDEF COMPILER4_UP}
//{$DEFINE XLSReadWriteII}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls, Controls,
  Dialogs, ExtCtrls, Buttons, ComCtrls, ShellApi, ComObj,
  RM_Common, RM_Class, RM_e_main
{$IFDEF XLSReadWriteII}
	, XLSReadWriteII, BIFFRecsII, Picture
{$ELSE}
  , RM_wawExcel
{$ENDIF}
{$IFDEF RXGIF}, JvGIF{$ENDIF}
{$IFDEF JPEG}, JPeg{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  { TRMXLSExport }
  TRMXLSExport = class(TRMExportFilter)
  private
    FScaleX, FScaleY: Double;
    FExportPrecision: Integer;
    FShowAfterExport: Boolean;
    FExportImages: Boolean;
    FExportFrames: Boolean;
    FPixelFormat: TPixelFormat;
    FExportImageFormat: TRMEFImageFormat;
{$IFDEF JPEG}
    FJPEGQuality: TJPEGQualityRange;
{$ENDIF}

    FSheetCount: Integer;
    FPagesOfSheet: Integer; //waw
    FTotalPage: Integer;
{$IFDEF XLSReadWriteII}
    FXlsReadWrite: TXLSReadWriteII;
		FXlsPageNo: Integer;
{$ELSE}
    FWorkBook: TwawXLSWorkbook; //waw
{$ENDIF}
    FMatrixList: TRMIEMList;
    FLeftMargin, FTopMargin, FRightMargin, FBottomMargin: Integer;
    FPageOr: TRMPrinterOrientation;
    FPageSize: Integer;
    FCompressFile: Boolean;

    procedure DoAfterExport(const aFileName: string);
    procedure ExportPages;
  protected
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnBeginPage; override;
    procedure OnEndPage; override;
    procedure OnExportPage(const aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
  published
    property ShowAfterExport: Boolean read FShowAfterExport write FShowAfterExport;
    property ExportPrecision: Integer read FExportPrecision write FExportPrecision;
    property PagesOfSheet: Integer read FPagesOfSheet write FPagesOfSheet;
    property ExportImages: Boolean read FExportImages write FExportImages;
    property ExportFrames: Boolean read FExportFrames write FExportFrames;
    property ExportImageFormat: TRMEFImageFormat read FExportImageFormat write FExportImageFormat;
{$IFDEF JPEG}
    property JPEGQuality: TJPEGQualityRange read FJPEGQuality write FJPEGQuality default High(TJPEGQualityRange);
{$ENDIF}
    property PixelFormat: TPixelFormat read FPixelFormat write FPixelFormat default pf24bit;
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
    property CompressFile: Boolean read FCompressFile write FCompressFile;
  end;

  { TRMCSVExportForm }
  TRMXLSExportForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edtExportFileName: TEdit;
    btnFileName: TSpeedButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    SaveDialog: TSaveDialog;
    rdbPrintAll: TRadioButton;
    rbdPrintCurPage: TRadioButton;
    rbdPrintPages: TRadioButton;
    edtPages: TEdit;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    chkShowAfterGenerate: TCheckBox;
    chkExportFrames: TCheckBox;
    gbExportImages: TGroupBox;
    lblExportImageFormat: TLabel;
    lblJPEGQuality: TLabel;
    Label4: TLabel;
    cmbImageFormat: TComboBox;
    edJPEGQuality: TEdit;
    UpDown1: TUpDown;
    cmbPixelFormat: TComboBox;
    chkExportImages: TCheckBox;
    edPages: TEdit;
    UpDown2: TUpDown;
    Label3: TLabel;
    chkWYB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnFileNameClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure rbdPrintPagesClick(Sender: TObject);
    procedure edtPagesEnter(Sender: TObject);
    procedure chkExportFramesClick(Sender: TObject);
    procedure edJPEGQualityKeyPress(Sender: TObject; var Key: Char);
    procedure cmbImageFormatChange(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

{$ENDIF}
implementation

{$IFDEF COMPILER4_UP}
uses Math, RM_wawWriters, RM_wawExcelFmt, RM_Const, RM_Const1, RM_Utils;

{$R *.DFM}

const
  xlEdgeBottom = $00000009;
  xlEdgeLeft = $00000007;
  xlEdgeRight = $0000000A;
  xlEdgeTop = $00000008;

type
  THackRMIEMData = class(TRMIEMData);

{------------------------------------------------------------------------------}
{TRMXLSExport}

constructor TRMXLSExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RMRegisterExportFilter(Self, RMLoadStr(SCSVFile) + ' (*.xls)', '*.xls');

  ShowDialog := True;
  CreateFile := False;
  FIsXLSExport := True;

  FScaleX := 1;
  FScaleY := 1;
  FExportPrecision := 1;
  FPagesOfSheet := 1; //waw
  FExportImages := True;
  FExportFrames := True;
  FShowAfterExport := True;
  FExportImageFormat := ifBMP;
  FPixelFormat := pf24bit;
  FCompressFile := False;

  FMatrixList := nil;
end;

destructor TRMXLSExport.Destroy;
begin
  FreeAndNil(FMatrixList);
  RMUnRegisterExportFilter(Self);

  inherited Destroy;
end;

function TRMXLSExport.ShowModal: Word;
var
  tmp: TRMXLSExportForm;
begin
  ExportPageList.Clear;
  if not ShowDialog then
  begin
    Result := mrOk;
    Exit;
  end;

  tmp := TRMXLSExportForm.Create(nil);
  try
    tmp.edtExportFileName.Text := FileName;
    tmp.btnFileName.Enabled := tmp.edtExportFileName.Enabled;

    tmp.chkExportFrames.Checked := ExportFrames;
    tmp.chkShowAfterGenerate.Checked := ShowAfterExport;
    tmp.UpDown2.Position := FPagesOfSheet; //waw

    tmp.cmbPixelFormat.ItemIndex := Integer(PixelFormat);
    tmp.chkExportImages.Checked := ExportImages;
    tmp.cmbImageFormat.ItemIndex := tmp.cmbImageFormat.Items.IndexOfObject(TObject(Ord(ExportImageFormat)));
{$IFDEF JPEG}
    tmp.UpDown1.Position := JPEGQuality;
{$ENDIF}
    tmp.chkExportFramesClick(Self);
    tmp.chkWYB.Checked := ExportPrecision <= 1;

    Result := tmp.ShowModal;
    if Result = mrOK then
    begin
      if tmp.rdbPrintAll.Checked then
        ParsePageNumbers(1, '')
      else if tmp.rbdPrintCurPage.Checked then
        ParsePageNumbers(2, '')
      else
        ParsePageNumbers(3, tmp.edtPages.Text);

      FileName := tmp.edtExportFileName.Text;
      ExportFrames := tmp.chkExportFrames.Checked;
      ShowAfterExport := tmp.chkShowAfterGenerate.Checked;
      FPagesOfSheet := tmp.UpDown2.Position;
      ExportImages := tmp.chkExportImages.Checked;
      if tmp.chkWYB.Checked then
        ExportPrecision := 1
      else
        ExportPrecision := 10;
      if ExportImages then
      begin
        PixelFormat := TPixelFormat(tmp.cmbPixelFormat.ItemIndex);
        ExportImageFormat := TRMEFImageFormat
          (tmp.cmbImageFormat.Items.Objects[tmp.cmbImageFormat.ItemIndex]);
{$IFDEF JPEG}
        JPEGQuality := StrToInt(tmp.edJPEGQuality.Text);
{$ENDIF}
      end;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMXLSExport.DoAfterExport(const aFileName: string);

{$IFDEF XLSReadWriteII}
  procedure _SaveToFile(const aFileName: string);
  begin
  	try
	  	FXlsReadWrite.Filename := aFileName;
  		FXlsReadWrite.Write;
    finally
    	FreeAndNil(FXlsReadWrite);
    end;
  end;
{$ELSE}
  procedure _SaveToFile(const aFileName: string);
  var
    lWriter: TwawCustomWriter; //By waw
    lExcel: Variant;
    lWorkBook: Variant;
  begin
    if FWorkBook = nil then Exit;

    if RMCmp(ExtractFileExt(aFileName), '.xls') then
      lWriter := TwawExcelWriter.Create //By waw
    else
      lWriter := TwawHTMLWriter.Create; //By waw

    try
      lWriter.Save(FWorkBook, aFileName); //By waw
    finally
      lWriter.Free; //By waw
    end;

    FreeAndNil(FWorkBook);
    if FCompressFile and RMCmp(ExtractFileExt(aFileName), '.xls') and FileExists(aFileName) then
    begin
      lExcel := CreateOLEObject('Excel.Application');
      lExcel.Application.EnableEvents := False;
      lExcel.Application.EnableAutoComplete := False;
      lExcel.Application.EnableAnimations := False;
      lExcel.Application.ScreenUpdating := False;
      lExcel.Application.Interactive := False;
      lExcel.Application.DisplayAlerts := False;

      lWorkBook := lExcel.WorkBooks.Open(aFileName);
      lWorkBook.SaveAs(aFileName, $FFFFEFD1 {xlNormal});

      lExcel.Quit;
      lExcel := null;
      lExcel := Unassigned;
    end;
  end;
{$ENDIF}

begin //by waw
  try
    if FTotalPage > 0 then
    begin
      FTotalPage := 0;
      ExportPages;
    end;

    _SaveToFile(aFileName);
    if FShowAfterExport then //by waw
      ShellExecute(0, 'open', PChar(aFileName), '', '', SW_SHOWNORMAL);
  finally
    FreeAndNil(FMatrixList);
  end;
end;

{$IFDEF XLSReadWriteII}
const
  sDefaultFontName = 'Arial';
  wawDefFontSize = 10;
  wawPointPerInch14 = 1440;

function GetCharacterWidth: Integer;
var
  F: TFont;
  SaveFont: HFont;
  DC: HDC;
  TM: TEXTMETRIC;
begin
  SaveFont := HFont(nil);
  DC := GetDC(0);
  F := TFont.Create;
  try
    F.Name := sDefaultFontName;
    F.Size := wawDefFontSize;
    SaveFont := SelectObject(DC, F.Handle);
    GetTextMetrics(DC, TM);
    result := TM.tmAveCharWidth + TM.tmOverhang + 1;
  finally
    if SaveFont <> HFont(nil) then
      SelectObject(DC, SaveFont);
    F.Free;
  end;
  ReleaseDC(0, DC);
end;

function GetPixelPerInch: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  Result := GetDeviceCaps(DC, LOGPIXELSX); // LOGPIXELSX = $58
  ReleaseDC(0, DC);
end;

procedure TRMXLSExport.ExportPages;
var
  lRow, lCol: Integer;
  lCell: TRMIEMData;
  lCellStyle: TRMIEMCellStyle;
  lSheetIndex: Integer;

  procedure _ExportAsText;
  begin
  end;

  procedure _ExportAsGraphic;
	var
		lTmpFileName: string;
    lXlsPicture: TXLSPicture;
  begin
		lTmpFileName := RM_Utils.RMGetTmpFileName('.jpg');
    try
    	lCell.Graphic.SaveToFile(lTmpFileName);
      lXlsPicture := FXlsReadWrite.Pictures.Add;
      with lXlsPicture do
      begin
      	IsTempFile := True;
				FileName := lTmpFileName;
        Width := 0;
        Height := 0;
        //for i := lCell.StartCol to lCell.EndCol do
        //	Width := Width + FMatrixList.ColWidth[i - 1];

      end;

      with FXlsReadWrite.Sheets[lSheetIndex].SheetPictures.Add do
      begin
        Col := lCell.StartCol;
        Row := lCell.StartRow;
        PictureName := lTmpFileName;
      end;
    finally
    end;
  end;

begin
  FMatrixList.Prepare;

	if FXlsPageNo > 1 then
	  FXlsReadWrite.Sheets.Add;

  lSheetIndex := FXlsReadWrite.Sheets.Count - 1;
  FXlsReadWrite.Sheets[lSheetIndex].Name := 'Sheet' + IntToStr(lSheetIndex + 1);

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Row Height');
  lCol := 0;
  for lRow := 0 to FMatrixList.RowCount - 1 do
  begin
    AddProgress;
    if ParentReport.Terminated then Break;

    FXlsReadWrite.Sheets[lSheetIndex].RowHeights[lRow + 1] := MulDiv(FMatrixList.RowHeight[lRow], wawPointPerInch14, GetPixelPerInch);
    if FMatrixList.GetCellRowPos(lRow) >= FMatrixList.PageBreak[lCol] then
    begin
      //lSheet.AddPageBreakAfterRow(lRow + 1);
      Inc(lCol);
    end;
  end;

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Column Width');
  for lCol := 0 to FMatrixList.ColCount - 1 do
  begin
    AddProgress;
    if ParentReport.Terminated then Break;

//    FXlsReadWrite.Sheets[lSheetIndex]  MulDiv(value, wawPointPerInch10, GetCharacterWidth)
    //lSheet.Cols[lCol].InchWidth := Round(RMFromScreenPixels(FMatrixList.ColWidth[lCol], rmutInches) * 0.937 * 100) / 100;
  end;

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Cells');
  for lRow := 0 to FMatrixList.RowCount - 1 do
  begin
    if ParentReport.Terminated then Break;
    for lCol := 0 to FMatrixList.ColCount - 1 do
    begin
      AddProgress;
      if ParentReport.Terminated then Break;

      lCell := FMatrixList.Cells[lCol, lRow];
      if (lCell = nil) or (lCell.Counter > 0) then Continue;

      lCellStyle := FMatrixList.CellStyle[lCell];
      lCell.Counter := 1;
      if lCell.ObjType = rmemText then
        _ExportAsText
      else if FExportImages then
        _ExportAsGraphic;
    end;
  end;

  FMatrixList.Clear(False);
end;
{$ELSE}
procedure TRMXLSExport.ExportPages;
var
  lRow, lCol: Integer;
  lRange: TwawXLSRange; //by waw
  lSheet: TwawXLSWorkSheet; //waw
  lCell: TRMIEMData;
  lCellStyle: TRMIEMCellStyle;

  procedure _SetXLSBorders;

    procedure _SetXLSBorder(bi: cardinal; b: TRMFrameLine);
    var
      bt: TwawXLSBorderType;
    begin
      bt := TwawXLSBorderType(nil);
      if not b.Visible then exit;
      case bi of
        xlEdgeLeft: bt := wawxlEdgeLeft;
        xlEdgeTop: bt := wawxlEdgeTop;
        xlEdgeRight: bt := wawxlEdgeRight;
        xlEdgeBottom: bt := wawxlEdgeBottom;
      end;
      case TPenStyle(b.Style) of
        psSolid: lRange.Borders[bt].LineStyle := wawlsThin;
        psDash: lRange.Borders[bt].LineStyle := wawlsDashed;
        psDot: lRange.Borders[bt].LineStyle := wawlsDotted;
        psDashDot: lRange.Borders[bt].LineStyle := wawlsDashDot;
        psDashDotDot: lRange.Borders[bt].LineStyle := wawlsDashDotDot;
        psClear: lRange.Borders[bt].LineStyle := wawlsNone;
        psInsideFrame: lRange.Borders[bt].LineStyle := wawlsNone;
      end;
      lRange.Borders[bt].Color := b.Color;
      lRange.Borders[bt].Weight := wawxlThin;
    end;

  begin
    if ExportFrames then
    begin
      _SetXLSBorder(xlEdgeLeft, lCellStyle.LeftFrame);
      _SetXLSBorder(xlEdgeTop, lCellStyle.TopFrame);
      _SetXLSBorder(xlEdgeRight, lCellStyle.RightFrame);
      _SetXLSBorder(xlEdgeBottom, lCellStyle.BottomFrame);
    end;
  end;

  procedure _ExportAsGraphic;
  var
    lPicture: TPicture;
  begin
    lPicture := TPicture.Create;
    try
      lPicture.Assign(lCell.Graphic);
//      SaveBitmapToPicture(TBitmap(lDataRec.Graphic), ExportImageFormat{$IFDEF JPEG}, JPEGQuality{$ENDIF}, lPicture);
      lSheet.AddImage(lCell.StartCol - 1, lCell.StartRow - 1,
        lCell.EndCol, lCell.EndRow, lPicture, True);
    finally
      lPicture.Free;
    end;
  end;

  procedure _ExportAsText;
  var
    i, lCount: Integer;
    lText: WideString;
    lValue: Extended;
  begin
    lRange := lSheet.Ranges[lCell.StartCol - 1, lCell.StartRow - 1, lCell.EndCol - 1, lCell.EndRow - 1];
    lCount := lCell.Memo.Count;
    lText := '';
    for i := 0 to lCount - 1 do
    begin
      if i > 0 then
        lText := lText + #13#10;

      lText := lText + lCell.Memo[i];
    end;

    lText := StringReplace(lText, #1, '', [rfReplaceAll]);
    if (lText = '') or (lText = #13#10) then
    begin
      lRange.Value := ' ';
      lRange.WrapText := False;
    end
    else
    begin
      if (Copy(lText, Length(lText) - 1, 2) = #13#10) then
        lText := Copy(lText, 1, Length(lText) - 2);

      if (lCell.ExportAsNum or (lCellStyle.DisplayFormat.FormatIndex1 = 1)) and
      	TryStrToFloat(lText, lValue) then
        lRange.Value := lValue
      else
      begin
        lRange.Value := lText;
        if ((Pos(#13#10, lText) > 0) or (Pos(#10, lText) > 0)) then
          lRange.WrapText := True
        else
          lRange.WrapText := False;
      end;
    end;

    lRange.Font.Assign(lCellStyle.Font);
    _SetXLSBorders;
    if (lCellStyle.FillColor <> clNone) and (lCellStyle.FillColor <> clWhite) then
    begin
      lRange.ForegroundFillPatternColor := lCellStyle.FillColor;
      lRange.BackgroundFillPatternColor := clWhite;
      lRange.FillPattern := wawfpSolid;
    end;

    case lCellStyle.VAlign of
      rmvBottom: lRange.VerticalAlignment := wawxlVAlignBottom;
      rmvCenter: lRange.VerticalAlignment := wawxlVAlignCenter;
      rmvTop: lRange.VerticalAlignment := wawxlVAlignTop;
    else
      lRange.VerticalAlignment := wawxlVAlignJustify;
    end;

    case lCellStyle.HAlign of
      rmhLeft: lRange.HorizontalAlignment := wawxlHAlignLeft;
      rmhCenter: lRange.HorizontalAlignment := wawxlHAlignCenter;
      rmhRight: lRange.HorizontalAlignment := wawxlHAlignRight;
    else
      lRange.HorizontalAlignment := wawxlHAlignJustify;
    end;
  end;

begin
  FMatrixList.Prepare;

  lSheet := FWorkBook.AddSheet; //by waw
  if (FPageSize < 256) and (FPageSize < Integer(wawxlPaperA3ExtraTransverse)) then
  begin
    lSheet.PageSetup.PaperSize := TwawXLSPaperSizeType(FPageSize);
    lSheet.PageSetup.FitToPagesWide := 1;
    lSheet.PageSetup.FitToPagesTall := 1;
  end;
  if FPageOr = rmpoPortrait then
    lSheet.PageSetup.Orientation := wawxlPortrait
  else
    lSheet.PageSetup.Orientation := wawxlLandscape;

  lSheet.PageSetup.LeftMargin := (Round(RMFromScreenPixels(FLeftMargin, rmutInches) * 100) / 100) - 0.18;
  lSheet.PageSetup.TopMargin := Round(RMFromScreenPixels(FTopMargin, rmutInches) * 100) / 100;
  lSheet.PageSetup.RightMargin := (Round(RMFromScreenPixels(FRightMargin, rmutInches) * 100) / 100) - 0.18;
  lSheet.PageSetup.BottomMargin := Round(RMFromScreenPixels(FBottomMargin, rmutInches) * 100) / 100;
  lSheet.PageSetup.HeaderMargin := 0.0;
  lSheet.PageSetup.FooterMargin := 0.0;
  lSheet.Title := 'Sheet' + IntToStr(FSheetCount);
  Inc(FSheetCount);

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Row Height');
  lCol := 0;
  for lRow := 0 to FMatrixList.RowCount - 1 do
  begin
    AddProgress;
    if ParentReport.Terminated then Break;

    lSheet.Rows[lRow].InchHeight := Round(RMFromScreenPixels(FMatrixList.RowHeight[lRow], rmutInches) * 100) / 100; //waw
    if FMatrixList.GetCellRowPos(lRow) >= FMatrixList.PageBreak[lCol] then
    begin
      lSheet.AddPageBreakAfterRow(lRow + 1);
      Inc(lCol);
    end;
  end;

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Column Width');
  for lCol := 0 to FMatrixList.ColCount - 1 do
  begin
    AddProgress;
    if ParentReport.Terminated then Break;

    lSheet.Cols[lCol].InchWidth := Round(RMFromScreenPixels(FMatrixList.ColWidth[lCol], rmutInches) * 0.937 * 100) / 100;
  end;

  SetProgress(FMatrixList.RowCount * FMatrixList.ColCount, 'Exporting Cells');
  for lRow := 0 to FMatrixList.RowCount - 1 do
  begin
    if ParentReport.Terminated then Break;
    for lCol := 0 to FMatrixList.ColCount - 1 do
    begin
      AddProgress;
      if ParentReport.Terminated then Break;

      lCell := FMatrixList.Cells[lCol, lRow];
      if (lCell = nil) or (lCell.Counter > 0) then Continue;

      lCellStyle := FMatrixList.CellStyle[lCell];
      lCell.Counter := 1;
      if lCell.ObjType = rmemText then
        _ExportAsText
      else if FExportImages then
        _ExportAsGraphic;
    end;
  end;

  FMatrixList.Clear(False);
end;
{$ENDIF}

procedure TRMXLSExport.OnBeginDoc;
begin
  inherited OnBeginDoc;

  if FMatrixList = nil then
  begin
    FMatrixList := TRMIEMList.Create(Self);
  end;
  FMatrixList.Clear(True);
  FMatrixList.ExportPrecision := ExportPrecision;
  FMatrixList.ExportImage := ExportImages;
  FMatrixList.ExportHighQualityPicture := False;

  ParentReport.Terminated := False;
  FTotalPage := 0;
  FSheetCount := 1;
  OnAfterExport := DoAfterExport;
  try
{$IFDEF XLSReadWriteII}
    FXlsReadWrite := TXLSReadWriteII.Create(nil);
    FXlsReadWrite.Clear;

    FXlsPageNo := 1;
    FXlsReadWrite.PictureOptions := FXlsReadWrite.PictureOptions + [poDeleteTempFiles];
{$ELSE}
    FWorkBook := TwawXLSWorkbook.Create; //By waw
    FWorkBook.Clear;
{$ENDIF}
  except
  end;
end;

procedure TRMXLSExport.OnEndDoc;
begin
  inherited OnEndDoc;
end;

procedure TRMXLSExport.OnBeginPage;
begin
  inherited;

  Inc(FTotalPage);
end;

procedure TRMXLSExport.OnEndPage;
begin
  inherited;
end;

procedure TRMXLSExport.OnExportPage(const aPage: TRMEndPage);
var
  i: Integer;
  t: TRMReportView;
begin
  FLeftMargin := aPage.spMarginLeft;
  FTopMargin := aPage.spMarginTop;
  FRightMargin := aPage.spMarginRight;
  FBottomMargin := aPage.spMarginBottom;
  FPageOr := aPage.PageOrientation;
  FPageSize := aPage.PageSize;
  for i := 0 to aPage.Page.Objects.Count - 1 do
  begin
    t := aPage.Page.Objects[i];
    if t.IsBand or (t is TRMSubReportView) then Continue;

    FMatrixList.AddObject(t);
  end;

  if FTotalPage >= FPagesOfSheet then
  begin
    FTotalPage := 0;
    ExportPages;
{$IFDEF XLSReadWriteII}
    Inc(FXlsPageNo);
{$ENDIF}    
  end
  else
  begin
    FMatrixList.EndPage;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMXLSExportForm }

procedure TRMXLSExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(chkExportImages, 'Caption', rmRes + 1821);
  RMSetStrProp(lblExportImageFormat, 'Caption', rmRes + 1816);
  RMSetStrProp(lblJPEGQuality, 'Caption', rmRes + 1814);
  RMSetStrProp(Label4, 'Caption', rmRes + 1788);

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 044);
  RMSetStrProp(rdbPrintAll, 'Caption', rmRes + 045);
  RMSetStrProp(rbdPrintCurPage, 'Caption', rmRes + 046);
  RMSetStrProp(rbdPrintPages, 'Caption', rmRes + 047);
  RMSetStrProp(Label2, 'Caption', rmRes + 048);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 379);
  RMSetStrProp(Label1, 'Caption', rmRes + 378);
  RMSetStrProp(chkShowAfterGenerate, 'Caption', rmRes + 380);
  RMSetStrProp(chkExportFrames, 'Caption', rmRes + 1778);
  RMSetStrProp(Label3, 'Caption', rmRes + 382); //waw
  RMSetStrProp(chkWYB, 'Caption', rmRes + 1775);

  RMSetStrProp(Self, 'Caption', rmRes + 1779);
  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMXLSExportForm.FormCreate(Sender: TObject);
begin
  Localize;
  cmbImageFormat.Items.Clear;
{$IFDEF RXGIF}
  cmbImageFormat.Items.AddObject(ImageFormats[ifGIF], TObject(ifGIF));
{$ENDIF}
{$IFDEF JPEG}
  cmbImageFormat.Items.AddObject(ImageFormats[ifJPG], TObject(ifJPG));
{$ENDIF}
  cmbImageFormat.Items.AddObject(ImageFormats[ifBMP], TObject(ifBMP));
  cmbImageFormat.ItemIndex := 0;
end;

procedure TRMXLSExportForm.btnFileNameClick(Sender: TObject);
begin
  SaveDialog.FileName := edtExportFileName.Text;
  if SaveDialog.Execute then
    edtExportFileName.Text := SaveDialog.FileName;
end;

procedure TRMXLSExportForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = mrOK) and (edtExportFileName.Text = '') then
    CanClose := False;
end;

procedure TRMXLSExportForm.rbdPrintPagesClick(Sender: TObject);
begin
  edtPages.SetFocus;
end;

procedure TRMXLSExportForm.edtPagesEnter(Sender: TObject);
begin
  rbdPrintPages.Checked := True;
end;

procedure TRMXLSExportForm.chkExportFramesClick(Sender: TObject);
begin
  RMSetControlsEnable(gbExportImages, chkExportImages.Checked);
  cmbImageFormatChange(Sender);
end;

procedure TRMXLSExportForm.edJPEGQualityKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TRMXLSExportForm.cmbImageFormatChange(Sender: TObject);
begin
  if chkExportImages.Checked and (cmbImageFormat.Text = ImageFormats[ifJPG]) then
  begin
    lblJPEGQuality.Enabled := True;
    edJPEGQuality.Enabled := True;
    edJPEGQuality.Color := clWindow;
  end
  else
  begin
    lblJPEGQuality.Enabled := False;
    edJPEGQuality.Enabled := False;
    edJPEGQuality.Color := clInactiveBorder;
  end;
end;

initialization

finalization

{$ENDIF}
end.

