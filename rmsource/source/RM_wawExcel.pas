unit RM_wawExcel;

{$I rm.inc}

interface

uses
  Windows, Classes, SysUtils, Graphics, Math,
{$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  RM_wawConsts, RM_wawExcelFmt, RM_wawBIFF8;

const
  sDefaultFontName = 'Arial';
  sXLSWorksheetTitlePrefix = 'Sheet';

//  XLSDefaultRowHeight = $FF;   //waw
  XLSDefaultRowHeight = $11D; //waw
  XLSDefaultColumnWidthInChars = 8;

  MaxDefaultColors = $10;
  MaxBiffRecordSize = $2024;

  mergeBlockItemsCount = $0400;

  sErrorInvalidPictureFormat = 'Invalid picture format';

type
  TCardinalArray = array[$0..$0] of Cardinal;

  PCardinalArray = ^TCardinalArray;

  TwawXLSBorder = class(TObject)
  private
    FColor: TColor;
    FLineStyle: TwawXLSLineStyleType;
    FWeight: TwawXLSWeightType;
  public
    property Color: TColor read FColor write FColor;
    property LineStyle: TwawXLSLineStyleType read FLineStyle write FLineStyle;
    property Weight: TwawXLSWeightType read FWeight write FWeight;
    constructor Create;
    destructor Destroy; override;
  end;

  TwawXLSBorders = class(TObject)
  private
    FBorders: array[TwawXLSBorderType] of TwawXLSBorder;
    function GetItem(i: TwawXLSBorderType): TwawXLSBorder;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetAttributes(ABorders: TwawXLSBorderTypes; AColor: TColor;
      ALineStyle: TwawXLSLineStyleType; AWeight: TwawXLSWeightType);
    property Borders[i: TwawXLSBorderType]: TwawXLSBorder read GetItem; default;
  end;

  TDynWordArray = array of Word;

  TwawXLSWorksheet = class;
  TwawXLSWorkbook = class;

  TwawXLSRange = class(TObject)
  private
    FWorksheet: TwawXLSWorksheet;
    FPlace: TRect;
    FBorders: TwawXLSBorders;
    FFont: TFont;
    FHorizontalAlignment: TwawXLSHorizontalAlignmentType;
    FVerticalAlignment: TwawXLSVerticalAlignmentType;
    FWrapText: Boolean;
    FRotation: Byte;
    FFormat: string;
    FValue: Variant;
    FFillPattern: TwawXLSFillPattern;
    FForegroundFillPatternColor: TColor;
    FBackgroundFillPatternColor: TColor;
    FFormula: string;
    FExportData: Pointer;
    function GetWorkbook: TwawXLSWorkbook;
    function GetCellDataType: TwawCellDataType;
    procedure SetValue(Value: Variant);
  public
    property Worksheet: TwawXLSWorksheet read FWorksheet;
    property Workbook: TwawXLSWorkbook read GetWorkbook;
    property Place: TRect read FPlace;
    property Borders: TwawXLSBorders read FBorders;
    property Font: TFont read FFont;
    property HorizontalAlignment: TwawXLSHorizontalAlignmentType
      read FHorizontalAlignment write FHorizontalAlignment;
    property VerticalAlignment: TwawXLSVerticalAlignmentType
      read FVerticalAlignment write FVerticalAlignment;
    property Value: Variant read FValue write SetValue;
    property WrapText: Boolean read FWrapText write FWrapText;
    property Rotation: Byte read FRotation write FRotation;
    property Format: string read FFormat write FFormat;
    property FillPattern: TwawXLSFillPattern read FFillPattern write FFillPattern;
    property ForegroundFillPatternColor: TColor
      read FForegroundFillPatternColor
      write FForegroundFillPatternColor;
    property BackgroundFillPatternColor: TColor
      read FBackgroundFillPatternColor
      write FBackgroundFillPatternColor;
    property ExportData: Pointer read FExportData write FExportData;
    property CellDataType: TwawCellDataType read GetCellDataType;
    property Formula: string read FFormula write FFormula;
    constructor Create(AWorksheet: TwawXLSWorksheet);
    destructor Destroy; override;
  end;

  TwawXLSRow = class(TObject)
  private
    FInd: Integer;
    FHeight: Integer;
    function GetPixelHeight: Integer;
    procedure SetPixelHeight(value: Integer);
    function GetInchHeight: Double;
    procedure SetInchHeight(value: Double);
    function GetCentimeterHeight: Double;
    procedure SetCentimeterHeight(value: Double);
    function GetExcelHeight: Double;
    procedure SetExcelHeight(value: Double);
  public
    property Ind: Integer read FInd;
    property Height: Integer read FHeight write FHeight;
    property PixelHeight: Integer read GetPixelHeight write SetPixelHeight;
    property InchHeight: Double read GetInchHeight write SetInchHeight;
    property CentimeterHeight: Double read GetCentimeterHeight write SetCentimeterHeight;
    property ExcelHeight: Double read GetExcelHeight write SetExcelHeight;
    constructor Create;
  end;

  TwawXLSCol = class(TObject)
  private
    FInd: Integer;
    FWidth: Integer;
    procedure SetWidth(Value: Integer);
    function GetPixelWidth: Integer;
    procedure SetPixelWidth(value: Integer);
    function GetInchWidth: Double;
    procedure SetInchWidth(value: Double);
    function GetCentimeterWidth: Double;
    procedure SetCentimeterWidth(value: Double);
    function GetExcelWidth: Double;
    procedure SetExcelWidth(value: Double);
  public
    property Ind: Integer read FInd write FInd;
    property Width: Integer read FWidth write SetWidth;
    property PixelWidth: Integer read GetPixelWidth write SetPixelWidth;
    property InchWidth: Double read GetInchWidth write SetInchWidth;
    property CentimeterWidht: Double read GetCentimeterWidth write SetCentimeterWidth;
    property ExcelWidth: Double read GetExcelWidth write SetExcelWidth;
    constructor Create;
  end;

  TwawXLSPageSetup = class(TObject)
  private
    FBlackAndWhite: Boolean;
    FCenterFooter: string;
    FCenterHeader: string;
    FCenterHorizontally: Boolean;
    FCenterVertically: Boolean;
    FDraft: Boolean;
    FFirstPageNumber: Integer;
    FFitToPagesTall: Integer;
    FFitToPagesWide: Integer;
    FLeftFooter: string;
    FLeftHeader: string;
    FOrder: TwawXLSOrderType;
    FOrientation: TwawXLSOrientationType;
    FPaperSize: TwawXLSPaperSizeType;
    FPrintGridLines: Boolean;
    FPrintHeaders: Boolean;
    FPrintNotes: Boolean;
    FRightFooter: string;
    FRightHeader: string;
    FLeftMargin: Double;
    FRightMargin: Double;
    FTopMargin: Double;
    FBottomMargin: Double;
    FFooterMargin: Double;
    FHeaderMargin: Double;
    FZoom: Integer;
    FCopies: Integer;
  public
    property LeftFooter: string read FLeftFooter write FLeftFooter;
    property LeftHeader: string read FLeftHeader write FLeftHeader;
    property CenterFooter: string read FCenterFooter write FCenterFooter;
    property CenterHeader: string read FCenterHeader write FCenterHeader;
    property RightFooter: string read FRightFooter write FRightFooter;
    property RightHeader: string read FRightHeader write FRightHeader;
    property CenterHorizontally: Boolean read FCenterHorizontally write FCenterHorizontally;
    property CenterVertically: Boolean read FCenterVertically write FCenterVertically;
    property LeftMargin: Double read FLeftMargin write FLeftMargin;
    property RightMargin: Double read FRightMargin write FRightMargin;
    property TopMargin: Double read FTopMargin write FTopMargin;
    property BottomMargin: Double read FBottomMargin write FBottomMargin;
    property HeaderMargin: Double read FHeaderMargin write FHeaderMargin;
    property FooterMargin: Double read FFooterMargin write FFooterMargin;
    property PaperSize: TwawXLSPaperSizeType read FPaperSize write FPaperSize;
    property Orientation: TwawXLSOrientationType read FOrientation write FOrientation;
    property Order: TwawXLSOrderType read FOrder write FOrder;
    property FirstPageNumber: Integer read FFirstPageNumber write FFirstPageNumber;
    property FitToPagesTall: Integer read FFitToPagesTall write FFitToPagesTall;
    property FitToPagesWide: Integer read FFitToPagesWide write FFitToPagesWide;
    property Copies: Integer read FCopies write FCopies;
    property Zoom: Integer read FZoom write FZoom;
    property BlackAndWhite: Boolean read FBlackAndWhite write FBlackAndWhite;
    property Draft: Boolean read FDraft write FDraft;
    property PrintNotes: Boolean read FPrintNotes write FPrintNotes;
    property PrintGridLines: Boolean read FPrintGridLines write FPrintGridLines;
    property PrintHeaders: Boolean read FPrintHeaders write FPrintHeaders;
    constructor Create;
  end;

  TwawImage = class(TObject)
  private
    FLeft: Integer;
    FLeftCO: Integer;
    FTop: Integer;
    FTopCO: Integer;
    FRight: Integer;
    FRightCO: Integer;
    FBottom: Integer;
    FBottomCO: Integer;
    FPicture: TPicture;
    FOwnsImage: Boolean;
    FBorderLineColor: TColor;
    FBorderLineStyle: TwawXLSImageBorderLineStyle;
    FBorderLineWeight: TwawXLSImageBorderLineWeight;
    FScalePercentX: Integer;
    FScalePercentY: Integer;
  public
    property Left: Integer read FLeft write FLeft;
    property LeftCO: Integer read FLeftCO write FLeftCO;
    property Top: Integer read FTop write FTop;
    property TopCO: Integer read FTopCO write FTopCO;
    property Right: Integer read FRight write FRight;
    property RightCO: Integer read FRightCO write FRightCO;
    property Bottom: Integer read FBottom write FBottom;
    property BottomCO: Integer read FBottomCO write FBottomCO;
    property Picture: TPicture read FPicture;
    property BorderLineColor: TColor read FBorderLineColor write FBorderLineColor;
    property BorderLineStyle: TwawXLSImageBorderLineStyle
      read FBorderLineStyle write FBorderLineStyle;
    property BorderLineWeight: TwawXLSImageBorderLineWeight
      read FBorderLineWeight write FBorderLineWeight;
    property ScalePercentX: Integer read FScalePercentX write FScalePercentX;
    property ScalePercentY: Integer read FScalePercentY write FScalePercentY;
    constructor Create(_Left: Integer; _Top: Integer; _Right: Integer;
      _Bottom: Integer; _Picture: TPicture; _OwnsImage: Boolean);
    constructor CreateScaled(_Left: Integer; _LeftCO: Integer;
      _Top: Integer; _TopCO: Integer; _ScalePercentX: Integer;
      _ScalePercentY: Integer; _Picture: TPicture; _OwnsImage: Boolean);
    constructor CreateWithOffsets(_Left: Integer; _LeftCO: Integer;
      _Top: Integer; _TopCO: Integer; _Right: Integer; _RightCO: Integer;
      _Bottom: Integer; _BottomCO: Integer; _Picture: TPicture;
      _OwnsImage: Boolean);
    destructor Destroy; override;
  end;

  TwawImages = class(TList)
  private
    function GetItm(i: Integer): TwawImage;
  public
    property Items[i: Integer]: TwawImage read GetItm; default;
    procedure Clear; override;
    destructor Destroy; override;
  end;

  TwawXLSWorksheet = class(TObject)
  private
    FWorkbook: TwawXLSWorkbook;
    FTitle: string;
    FPageSetup: TwawXLSPageSetup;
    FImages: TwawImages;
    FRanges: TList;
    FCols: TList;
    FRows: TList;
    FPageBreaks: TList;
    FDimensions: TRect;
    FMaxRangeLength: Integer;
    procedure SetTitle(Value: string);
    function GetCol(ColIndex: Integer): TwawXLSCol;
    function GetRow(RowIndex: Integer): TwawXLSRow;
    function GetRangesCount: Integer;
    function GetXLSRange(RangeIndex: Integer): TwawXLSRange;
    function GetColsCount: Integer;
    function GetRowsCount: Integer;
    function GetIndexInWorkBook: Integer;
    function GetColByIndex(i: Integer): TwawXLSCol;
    function GetRowByIndex(i: Integer): TwawXLSRow;
    function GetPageBreak(i: Integer): Integer;
    function GetPageBreaksCount: Integer;
    function AddRow(RowIndex: Integer): TwawXLSRow;
    function AddCol(ColIndex: Integer): TwawXLSCol;
    procedure SetMaxRangeLength(Value: Integer);
    procedure ResetMaxRangeLength;
    function GetRangeSp(xl: Integer; yt: Integer; xr: Integer; yb: Integer): TwawXLSRange;
    function SeekTop(Value: Integer): Integer;
    function ScanGet(Index: Integer; R: TRect; var RemoveFlag: Boolean): TwawXLSRange;
  public
    property Title: string read FTitle write SetTitle;
    property PageSetup: TwawXLSPageSetup read FPageSetup;
    property Ranges[xl: Integer; yt: Integer; xr: Integer; yb: Integer]: TwawXLSRange read GetRangeSp; default;
    property Cols[ColIndex: Integer]: TwawXLSCol read GetCol;
    property Rows[RowIndex: Integer]: TwawXLSRow read GetRow;
    property RangeByIndex[RangeIndex: Integer]: TwawXLSRange read GetXLSRange;
    property RangesCount: Integer read GetRangesCount;
    property ColByIndex[ColIndex: Integer]: TwawXLSCol read GetColByIndex;
    property ColsCount: Integer read GetColsCount;
    property RowByIndex[RowIndex: Integer]: TwawXLSRow read GetRowByIndex;
    property RowsCount: Integer read GetRowsCount;
    property IndexInWorkBook: Integer read GetIndexInWorkBook;
    property Images: TwawImages read FImages;
    property PageBreaks[i: Integer]: Integer read GetPageBreak;
    property PageBreaksCount: Integer read GetPageBreaksCount;
    property Workbook: TwawXLSWorkbook read FWorkbook;
    property Dimensions: TRect read FDimensions;
    function GetDefaultColumnPixelWidth: Integer;
    function GetDefaultRowPixelHeight: Integer;
    function FindRow(RowIndex: Integer): TwawXLSRow;
    function FindCol(ColIndex: Integer): TwawXLSCol;
    function FindPageBreak(RowNumber: Integer): Integer;
    function AddImage(Left: Integer; Top: Integer; Right: Integer;
      Bottom: Integer; Picture: TPicture; OwnsImage: Boolean): TwawImage;
    function AddImageWithOffsets(Left: Integer; LeftCO: Integer;
      Top: Integer; TopCO: Integer; Right: Integer; RightCO: Integer;
      Bottom: Integer; BottomCO: Integer; Picture: TPicture;
      OwnsImage: Boolean): TwawImage;
    function AddImageScaled(Left: Integer; LeftCO: Integer; Top: Integer;
      TopCO: Integer; ScalePercentX: Integer; ScalePercentY: Integer;
      Picture: TPicture; OwnsImage: Boolean): TwawImage;
    procedure AddPageBreakAfterRow(RowNumber: Integer);
    procedure DeletePageBreakAfterRow(RowNumber: Integer);
    constructor Create(AWorkbook: TwawXLSWorkbook);
    destructor Destroy; override;
  end;

  TwawXLSWorkbook = class(TObject)
  private
    FUserNameOfExcel: string;
    FSheets: TList;
    procedure SetUserNameOfExcel(Value: string);
    procedure ClearSheets;
    function GetSheetsCount: Integer;
    function GetXLSWorkSheet(i: Integer): TwawXLSWorksheet;
  public
    property UserNameOfExcel: string read FUserNameOfExcel write SetUserNameOfExcel;
    property SheetsCount: Integer read GetSheetsCount;
    property Sheets[i: Integer]: TwawXLSWorksheet read GetXLSWorkSheet;
    procedure SaveAsXLSToFile(FileName: string);
    procedure SaveAsHTMLToFile(FileName: string);
    function AddSheet: TwawXLSWorksheet;
    function GetSheetIndex(SheetTitle: string): Integer;
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

  TwawCustomWriter = class(TObject)
  public
    procedure Save(WorkBook: TwawXLSWorkbook; FileName: string);
      virtual;
  end;

function PointInRect(X: Integer; Y: Integer; var R: TRect): Boolean;

function RectOverRect(var r1: TRect; var r2: TRect): Boolean;

implementation

uses
  RM_wawWriters;

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

function PointInRect(X: Integer; Y: Integer; var R: TRect): Boolean;
begin
  Result := ((X >= R.Left) and (X <= R.Right)) and ((Y >= R.Top) and (Y <= R.Bottom))
end;

function RectOverRect(var r1: TRect; var r2: TRect): Boolean;
begin
  Result := ((((r2.Left >= r1.Left) and (r2.Left <= r1.Right)) or ((r2.Right >= r1.Left) and (r2.Right <= r1.Right))) and
    (((r2.Top >= r1.Top) and (r2.Top <= r1.Bottom)) or ((r2.Bottom <= r1.Bottom) and (r2.Bottom >= r1.Top)))) or
    ((((r1.Left >= r2.Left) and (r1.Left <= r2.Right)) or ((r1.Right >= r2.Left) and (r1.Right <= r2.Right))) and
    (((r1.Top >= r2.Top) and (r1.Top <= r2.Bottom)) or ((r1.Bottom <= r2.Bottom) and (r1.Bottom >= r2.Top))));
end;

function RectEqualRect(var r1: TRect; var r2: TRect): Boolean;
begin
  Result := (r1.Top = r2.Top) and (r1.Left = r2.Left) and (r1.Bottom = r2.Bottom) and (r1.Right = r2.Right);
end;

constructor TwawXLSRow.Create;
begin
  inherited Create;
  FHeight := XLSDefaultRowHeight;
end;

function TwawXLSRow.GetPixelHeight: Integer;
begin
  Result := MulDiv(GetPixelPerInch, FHeight, wawPointPerInch14);
end;

procedure TwawXLSRow.SetPixelHeight(value: Integer);
begin
  FHeight := MulDiv(value, wawPointPerInch14, GetPixelPerInch);
end;

function TwawXLSRow.GetInchHeight: Double;
begin
  Result := FHeight / wawPointPerInch14;
end;

procedure TwawXLSRow.SetInchHeight(value: Double);
begin
  FHeight := Round(value * wawPointPerInch14);
end;

function TwawXLSRow.GetCentimeterHeight: Double;
begin
  Result := GetInchHeight * wawSmRepInch;
end;

procedure TwawXLSRow.SetCentimeterHeight(value: Double);
begin
  SetInchHeight(value / wawSmRepInch);
end;

function TwawXLSRow.GetExcelHeight: Double;
begin
  Result := FHeight / wawExcelHeightC;
end;

procedure TwawXLSRow.SetExcelHeight(value: Double);
begin
  FHeight := Round(value * wawExcelHeightC);
end;

constructor TwawXLSCol.Create;
begin
  inherited Create;
  FWidth := (XLSDefaultColumnWidthInChars + 1) * wawPointPerInch10;
end;

procedure TwawXLSCol.SetWidth(Value: Integer);
begin
  FWidth := Min(Value, $FF00);
end;

function TwawXLSCol.GetPixelWidth: Integer;
begin
  Result := MulDiv(GetCharacterWidth, FWidth, wawPointPerInch10);
end;

procedure TwawXLSCol.SetPixelWidth(value: Integer);
begin
  FWidth := MulDiv(value, wawPointPerInch10, GetCharacterWidth);
end;

function TwawXLSCol.GetInchWidth: Double;
begin
  Result := GetCharacterWidth * FWidth / (GetPixelPerInch * wawPointPerInch10);
end;

procedure TwawXLSCol.SetInchWidth(value: Double);
begin
  FWidth := Round(GetPixelPerInch * wawPointPerInch10 * value / GetCharacterWidth);
end;

function TwawXLSCol.GetCentimeterWidth: Double;
begin
  Result := GetInchWidth * wawSmRepInch;
end;

procedure TwawXLSCol.SetCentimeterWidth(value: Double);
begin
  SetInchWidth(value / wawSmRepInch);
end;

function TwawXLSCol.GetExcelWidth: Double;
begin
  if FWidth > wawExcelWidthC1 then
    Result := (FWidth - wawExcelWidthC2) / wawPointPerInch10
  else
    Result := FWidth / wawExcelWidthC1;
end;

procedure TwawXLSCol.SetExcelWidth(value: Double);
begin
  if value > 1 then
    FWidth := Round(value * wawPointPerInch10) + wawExcelWidthC2
  else
    FWidth := Round(value * wawExcelWidthC1);
end;

constructor TwawXLSBorder.Create;
begin
  inherited Create;
// Init to default values
  FLineStyle := wawlsNone;
  FWeight := wawxlHairline;
  FColor := clBlack;
end;

destructor TwawXLSBorder.Destroy;
begin
  inherited Destroy;
end;

constructor TwawXLSBorders.Create;
var
  i: TwawXLSBorderType;
begin
  inherited Create;
  for i := Low(TwawXLSBorderType) to High(TwawXLSBorderType) do
    FBorders[i] := TwawXLSBorder.Create;
end;

destructor TwawXLSBorders.Destroy;
var
  i: TwawXLSBorderType;
begin
  for i := Low(TwawXLSBorderType) to High(TwawXLSBorderType) do
    FBorders[i].Free;
  inherited Destroy;
end;

function TwawXLSBorders.GetItem(i: TwawXLSBorderType): TwawXLSBorder;
begin
  Result := FBorders[i];
end;

procedure TwawXLSBorders.SetAttributes(ABorders: TwawXLSBorderTypes;
  AColor: TColor; ALineStyle: TwawXLSLineStyleType;
  AWeight: TwawXLSWeightType);
var
  i: Integer;
begin
  for i := Ord(Low(TwawXLSBorderType)) to Ord(High(TwawXLSBorderType)) do
  begin
    if TwawXLSBorderType(i) in TwawXLSBorderTypes(ABorders) then
    begin
      Borders[TwawXLSBorderType(i)].FColor := AColor;
      Borders[TwawXLSBorderType(i)].FLineStyle := ALineStyle;
      Borders[TwawXLSBorderType(i)].FWeight := AWeight;
    end;
  end;
end;

constructor TwawXLSRange.Create(AWorksheet: TwawXLSWorksheet);
begin
// inherited Create;
  FVerticalAlignment := wawxlVAlignBottom;
  FHorizontalAlignment := wawxlHAlignGeneral;
  FWorksheet := AWorksheet;
  FBorders := TwawXLSBorders.Create;
  FFont := TFont.Create;
  FFont.Name := sDefaultFontName;
  FFont.Size := 10;
  FFont.Color := clBlack;
end;

destructor TwawXLSRange.Destroy;
begin
// inherited Destroy;
  FBorders.Free;
  FFont.Free;
end;

function TwawXLSRange.GetWorkbook: TwawXLSWorkbook;
begin
  Result := nil;
  if FWorksheet <> nil then
    Result := FWorksheet.Workbook;
end;

procedure TwawXLSRange.SetValue(Value: Variant);
begin
  if (VarType(Value) = varOleStr) or (VarType(Value) = varString) then
    FValue := StringReplace(VarToStr(Value), #13#10, #10, [rfReplaceAll])
  else
    FValue := Value;
end;

function TwawXLSRange.GetCellDataType: TwawCellDataType;
var
  vt: Integer;
begin
  if FFormula = '' then
  begin
    vt := VarType(FValue);
    if (vt = varSmallint) or
      (vt = varInteger) or
      (vt = varSingle) or
      (vt = varDouble) or
      (vt = varCurrency) or
      (vt = varByte) then
      Result := wawcdtNumber
    else
      Result := wawcdtString;
  end
  else
    Result := wawcdtFormula;
end;

constructor TwawXLSPageSetup.Create;
begin
  inherited Create;
  FLeftMargin := 2;
  FRightMargin := 2;
  FTopMargin := 2.5;
  FBottomMargin := 2.5;
  FPaperSize := wawxlPaperA4;
  FZoom := 100;
  FitToPagesTall := 1;
  FitToPagesWide := 1;
  FirstPageNumber := 1;
end;

constructor TwawImage.Create(_Left: Integer; _Top: Integer;
  _Right: Integer; _Bottom: Integer; _Picture: TPicture;
  _OwnsImage: Boolean);
begin
  inherited Create;
  FLeft := _Left;
  FTop := _Top;
  FRight := _Right;
  FBottom := _Bottom;
  FOwnsImage := _OwnsImage;
  FBorderLineColor := $00FFFFFF;
  FBorderLineStyle := wawblsSolid;
  FBorderLineWeight := wawblwHairline;
  FScalePercentX := 0;
  FScalePercentY := 0;

  if FOwnsImage = True then
  begin
    FPicture := TPicture.Create;
    FPicture.Assign(_Picture);
  end
  else
    FPicture := _Picture;
end;

constructor TwawImage.CreateWithOffsets(_Left: Integer; _LeftCO: Integer;
  _Top: Integer; _TopCO: Integer; _Right: Integer; _RightCO: Integer;
  _Bottom: Integer; _BottomCO: Integer; _Picture: TPicture;
  _OwnsImage: Boolean);
begin
  Create(_Left, _Top, _Right, _Bottom, _Picture, _OwnsImage);
  FLeftCO := _LeftCO;
  FTopCO := _TopCO;
  FRightCO := _RightCO;
  FBottomCO := _BottomCO;
end;

constructor TwawImage.CreateScaled(_Left: Integer; _LeftCO: Integer;
  _Top: Integer; _TopCO: Integer; _ScalePercentX: Integer;
  _ScalePercentY: Integer; _Picture: TPicture; _OwnsImage: Boolean);
begin
  CreateWithOffsets(_Left, _LeftCO, _Top, _TopCO, $FF, $FF, $FF, $FF, _Picture, _OwnsImage);
  FScalePercentX := _ScalePercentX;
  FScalePercentY := _ScalePercentY;
end;

destructor TwawImage.Destroy;
begin
  if FOwnsImage then
    FPicture.Free;
  inherited Destroy;
end;

destructor TwawImages.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TwawImages.GetItm(i: Integer): TwawImage;
begin
  Result := inherited Items[i];
end;

procedure TwawImages.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  inherited Clear;
end;

constructor TwawXLSWorksheet.Create(AWorkbook: TwawXLSWorkbook);
var
  i: Integer;
  j: Integer;
begin
  inherited Create;
  FDimensions := Rect(-1, -1, -1, -1);
  FWorkbook := AWorkbook;
  FRanges := TList.Create;
  FCols := TList.Create;
  FRows := TList.Create;
  FPageSetup := TwawXLSPageSetup.Create;
  FImages := TwawImages.Create;
  FPageBreaks := TList.Create;

  i := Workbook.FSheets.Count + 1;
  while true do
  begin
    j := 0;
    while (j < FWorkbook.FSheets.Count) and
      (AnsiCompareText(TwawXLSWorksheet(FWorkbook.FSheets[j]).Title,
      sXLSWorksheetTitlePrefix + IntToStr(i)) = 0) do Inc(j);
    if (j >= FWorkbook.FSheets.Count) or
      (AnsiCompareText(TwawXLSWorksheet(FWorkbook.FSheets[j]).Title,
      sXLSWorksheetTitlePrefix + IntToStr(i)) <> 0) then
      break;
    Inc(i);
  end;
  Title := sXLSWorksheetTitlePrefix + IntToStr(i);
end;

destructor TwawXLSWorksheet.Destroy;
var
  i: Integer;
begin
  for i := 0 to FRanges.Count - 1 do
    TwawXLSRange(FRanges.List[i]).Free;
  for i := 0 to FCols.Count - 1 do
    TwawXLSCol(FCols[i]).Free;
  for i := 0 to FRows.Count - 1 do
    TwawXLSRow(FRows[i]).Free;
  FPageBreaks.Free;
  FRanges.Free;
  FCols.Free;
  FRows.Free;
  FPageSetup.Free;
  FImages.Free;
  inherited Destroy;
end;

function TwawXLSWorksheet.GetIndexInWorkBook: Integer;
begin
  if WorkBook = nil then
    Result := -1
  else
    Result := WorkBook.FSheets.IndexOf(Self);
end;

procedure TwawXLSWorksheet.SetTitle(Value: string);
begin
  FTitle := Trim(Copy(Value, 1, 31));
end;

function TwawXLSWorksheet.GetColByIndex(i: Integer): TwawXLSCol;
begin
  Result := TwawXLSCol(FCols.Items[i]);
end;

function TwawXLSWorksheet.GetRowByIndex(i: Integer): TwawXLSRow;
begin
  Result := TwawXLSRow(FRows.Items[i]);
end;

function TwawXLSWorksheet.GetColsCount: Integer;
begin
  Result := FCols.Count;
end;

function TwawXLSWorksheet.GetRowsCount: Integer;
begin
  Result := FRows.Count;
end;

function TwawXLSWorksheet.GetRangesCount: Integer;
begin
  Result := FRanges.Count;
end;

function TwawXLSWorksheet.GetXLSRange(RangeIndex: Integer): TwawXLSRange;
begin
  Result := TwawXLSRange(FRanges.List[RangeIndex]);
end;

function TwawXLSWorksheet.GetCol(ColIndex: Integer): TwawXLSCol;
begin
  Result := FindCol(ColIndex);
  if Result = nil then
    Result := AddCol(ColIndex);
end;

function TwawXLSWorksheet.GetRow(RowIndex: Integer): TwawXLSRow;
begin
  Result := FindRow(RowIndex);
  if Result = nil then
    Result := AddRow(RowIndex);
end;

function TwawXLSWorksheet.FindRow(RowIndex: Integer): TwawXLSRow;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FRows.Count - 1 do
    if TwawXLSRow(FRows.Items[i]).Ind = RowIndex then
    begin
      Result := TwawXLSRow(FRows.Items[i]);
      break;
    end;
end;

function TwawXLSWorksheet.AddRow(RowIndex: Integer): TwawXLSRow;
begin
  Result := TwawXLSRow.Create;
  Result.FInd := RowIndex;
  FRows.Add(Result);
// change FDimensions
  if (FDimensions.Top = -1) or (RowIndex < FDimensions.Top) then
    FDimensions.Top := RowIndex;
  if (FDimensions.Bottom = -1) or (RowIndex > FDimensions.Bottom) then
    FDimensions.Bottom := RowIndex;
end;

function TwawXLSWorksheet.FindCol(ColIndex: Integer): TwawXLSCol;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FCols.Count - 1 do
    if TwawXLSCol(FCols.Items[i]).Ind = ColIndex then
    begin
      Result := TwawXLSCol(FCols.Items[i]);
      break;
    end;
end;

function TwawXLSWorksheet.GetDefaultColumnPixelWidth: Integer;
begin
  Result := GetCharacterWidth * (XLSDefaultColumnWidthInChars + 1); //waw
end;

function TwawXLSWorksheet.GetDefaultRowPixelHeight: Integer;
begin
  Result := MulDiv(GetPixelPerInch, XLSDefaultRowHeight, wawPointPerInch14);
end;

function TwawXLSWorksheet.AddCol(ColIndex: Integer): TwawXLSCol;
begin
  Result := TwawXLSCol.Create;
  Result.FInd := ColIndex;
  FCols.Add(Result);
// change FDimensions
  if (FDimensions.Left = -1) or (ColIndex < FDimensions.Left) then
    FDimensions.Left := ColIndex;
  if (FDimensions.Right = -1) or (ColIndex > FDimensions.Right) then
    FDimensions.Right := ColIndex;
end;

procedure TwawXLSWorksheet.SetMaxRangeLength(Value: Integer);
begin
  if Value > FMaxRangeLength then
    FMaxRangeLength := Value;
end;

procedure TwawXLSWorksheet.ResetMaxRangeLength;
var
  i: Integer;
begin
  FMaxRangeLength := 1;
  for i := 0 to FRanges.Count - 1 do
    SetMaxRangeLength(RangeByIndex[i].FPlace.Bottom - RangeByIndex[i].FPlace.Top + 1);
end;

function TwawXLSWorksheet.SeekTop(Value: Integer): Integer;
var
  h_rule: Integer;
  l_rule: Integer;
  m_rule: Integer;
begin
  case FRanges.Count of
    0: Result := 0;
    1:
      begin
        if RangeByIndex[0].FPlace.Top < Value then
          Result := FRanges.Count
        else
          Result := 0;
      end;
  else
    begin
      if RangeByIndex[FRanges.Count - 1].FPlace.Top < Value then
        Result := FRanges.Count
      else
      begin
        l_rule := 0;
        h_rule := FRanges.Count - 1;
        repeat
          begin
            m_rule := h_rule + l_rule;
            if (m_rule and 1) = 1 then
              m_rule := (m_rule shr 1) + 1
            else
              m_rule := (m_rule shr 1);
            if RangeByIndex[m_rule].FPlace.Top < Value then
              l_rule := m_rule + 1
            else
              h_rule := l_rule;
          end
        until h_rule = l_rule;
        Result := l_rule;
      end;
    end;
  end;
end;

function TwawXLSWorksheet.ScanGet(Index: Integer; R: TRect; var RemoveFlag: Boolean): TwawXLSRange;
var
  pos: Integer;
  i: Integer;
  fl_delete: Boolean;
  fl_seek: Boolean;
begin
  Result := TwawXLSRange(nil);
  fl_seek := false;
  if FRanges.Count = Index then
  begin
    Result := TwawXLSRange.Create(Self);
    Result.FPlace := R;
    FRanges.Add(Result);
  end
  else
  begin
    i := Index;
    pos := Index;
    repeat
      begin
        fl_delete := false;
        if RectEqualRect(R, RangeByIndex[i].FPlace) then
        begin
          Result := RangeByIndex[i];
          fl_seek := true;
          Break;
        end
        else
          if RectOverRect(R, RangeByIndex[i].FPlace) then
          begin
            RangeByIndex[i].Free;
            FRanges.Delete(i);
            RemoveFlag := true;
            fl_delete := true;
          end;
        if not fl_delete and (RangeByIndex[pos].FPlace.Top <= R.Top) then Inc(pos);
        if not fl_delete and (RangeByIndex[i].FPlace.Top <= R.Bottom) then Inc(i);
        if FRanges.Count = i then Break;
      end;
    until RangeByIndex[i].FPlace.Top > R.Bottom;
    if Result = nil then
    begin
      Result := TwawXLSRange.Create(Self);
      Result.FPlace := R;
    end;
    if not fl_seek then
    begin
      if FRanges.Count > pos then
        FRanges.Insert(pos, Result)
      else
        FRanges.Add(Result);
    end;
  end;
end;

function TwawXLSWorksheet.GetRangeSp(xl: Integer; yt: Integer;
  xr: Integer; yb: Integer): TwawXLSRange;
var
  Index: Integer;
  RemoveFlag: Boolean;
  R: TRect;
begin
  RemoveFlag := False;
  R := Rect(xl, yt, xr, yb);
  Index := SeekTop(yt - FMaxRangeLength + 1);
  if Index = FRanges.Count then
  begin
    Result := TwawXLSRange.Create(Self);
    Result.FPlace := R;
    FRanges.Add(Result);
  end
  else
    Result := ScanGet(Index, R, RemoveFlag);
  if RemoveFlag then ResetMaxRangeLength
  else
    SetMaxRangeLength(yb - yt + 1);
  if (FDimensions.Left = -1) or (FDimensions.Left > R.Left) then
    FDimensions.Left := R.Left;
  if (FDimensions.Top = -1) or (FDimensions.Top > R.Top) then
    FDimensions.Top := R.Top;
  if (FDimensions.Right = -1) or (FDimensions.Right < R.Right) then
    FDimensions.Right := R.Right;
  if (FDimensions.Bottom = -1) or (FDimensions.Bottom < R.Bottom) then
    FDimensions.Bottom := R.Bottom;
end;

function TwawXLSWorksheet.AddImage(Left: Integer; Top: Integer;
  Right: Integer; Bottom: Integer; Picture: TPicture; OwnsImage: Boolean):
  TwawImage;
begin
  Result := FImages[FImages.Add(TwawImage.Create(Left, Top, Right, Bottom, Picture, OwnsImage))];
end;

function TwawXLSWorksheet.AddImageWithOffsets(Left: Integer;
  LeftCO: Integer; Top: Integer; TopCO: Integer; Right: Integer;
  RightCO: Integer; Bottom: Integer; BottomCO: Integer; Picture: TPicture;
  OwnsImage: Boolean): TwawImage;
begin
  Result := FImages[FImages.Add(TwawImage.CreateWithOffsets(Left, LeftCO, Top, TopCO, Right, RightCO, Bottom, BottomCO, Picture, OwnsImage))];
end;

function TwawXLSWorksheet.AddImageScaled(Left: Integer; LeftCO: Integer;
  Top: Integer; TopCO: Integer; ScalePercentX: Integer;
  ScalePercentY: Integer; Picture: TPicture; OwnsImage: Boolean):
  TwawImage;
begin
  Result := FImages[FImages.Add(TwawImage.CreateScaled(Left, LeftCO, Top, TopCO, ScalePercentX, ScalePercentY, Picture, OwnsImage))];
end;

function TwawXLSWorksheet.GetPageBreak(i: Integer): Integer;
begin
  Result := Integer(FPageBreaks[i]); //????
end;

function TwawXLSWorksheet.GetPageBreaksCount: Integer;
begin
  Result := FPageBreaks.Count;
end;

procedure TwawXLSWorksheet.AddPageBreakAfterRow(RowNumber: Integer);
begin
  if FPageBreaks.IndexOf(Pointer(RowNumber)) = -1 then
    FPageBreaks.Add(Pointer(RowNumber));
end;

procedure TwawXLSWorksheet.DeletePageBreakAfterRow(RowNumber: Integer);
begin
  FPageBreaks.Remove(Pointer(RowNumber));
end;

function TwawXLSWorksheet.FindPageBreak(RowNumber: Integer): Integer;
begin
  Result := FPageBreaks.IndexOf(Pointer(RowNumber));
end;

constructor TwawXLSWorkbook.Create;
begin
  UserNameOfExcel := 'wawReport';
  FSheets := TList.Create;
end;

destructor TwawXLSWorkbook.Destroy;
begin
  ClearSheets;
  FSheets.Free;
end;

procedure TwawXLSWorkbook.ClearSheets;
var
  i: Integer;
begin
  for i := 0 to FSheets.Count - 1 do
    TwawXLSWorkSheet(FSheets[i]).Free;
  FSheets.Clear;
end;

procedure TwawXLSWorkbook.SetUserNameOfExcel(Value: string);
begin
  FUserNameOfExcel := Trim(Copy(Value, 1, 66));
end;

function TwawXLSWorkbook.GetSheetsCount: Integer;
begin
  Result := FSheets.Count;
end;

function TwawXLSWorkbook.GetXLSWorkSheet(i: Integer): TwawXLSWorksheet;
begin
  Result := TwawXLSWorkSheet(FSheets[i]);
end;

procedure TwawXLSWorkbook.SaveAsXLSToFile(FileName: string);
var
  Writer: TwawExcelWriter;
begin
  Writer := TwawExcelWriter.Create;
  try
    Writer.Save(Self, FileName);
  finally
    Writer.Free;
  end;
end;

procedure TwawXLSWorkbook.SaveAsHTMLToFile(FileName: string);
var
  Writer: TwawHTMLWriter;
begin
  Writer := TwawHTMLWriter.Create;
  try
    Writer.Save(Self, FileName);
  finally
    Writer.Free;
  end;
end;

function TwawXLSWorkbook.AddSheet: TwawXLSWorksheet;
begin
  Result := TwawXLSWorkSheet.Create(Self);
  FSheets.Add(Result);
end;

function TwawXLSWorkbook.GetSheetIndex(SheetTitle: string): Integer;
begin
  for Result := 0 to SheetsCount - 1 do
    if Sheets[Result].Title = SheetTitle then break;
  if Result >= SheetsCount then Result := -1;
end;

procedure TwawXLSWorkbook.Clear;
begin
  ClearSheets;
end;

procedure TwawCustomWriter.Save(WorkBook: TwawXLSWorkbook; FileName: string);
begin
end;

end.

