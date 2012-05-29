unit RM_wawWriters;

{$I rm.inc}

interface

uses
  Windows, Classes, SysUtils, Graphics, AxCtrls, ActiveX,
{$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  RM_wawConsts, RM_wawExcelFmt, RM_wawExcel, RM_wawFormula, RM_wawBIFF8;

type
  TwawHtmlCell = record
    Image: TwawImage;
    Range: TwawXLSRange;
    StyleId: Word;
    Hide: Word;
    ImageNum: Integer;
    BordersStyleId: Word;
  end;

  THtmlCells = array[$0..$0] of TwawHtmlCell;

  PHtmlCells = ^THtmlCells;

  TwawHTMLWriter = class(TwawCustomWriter)
  private
    FileStream: TFileStream;
    FFileName: string;
    FilesDir: string;
    FName: string;
    FileExt: string;
    DirName: string;
    FWorkBook: TwawXLSWorkbook;
    HtmlCells: PHtmlCells;
    MinPos: Integer;
    RowCount: Integer;
    ColCount: Integer;
    Styles: TStrings;
    SpansPresent: Boolean;
    function GetBackgroundColor(Range: TwawXLSRange): string;
    function GetBorders(Range: TwawXLSRange): string;
    procedure CheckBounds(Images: TwawImages);
    procedure AddImage(Sheet: TwawXLSWorksheet; Image: TwawImage; FileName: string;
      ImageNum: Integer);
    procedure AddRange(Range: TwawXLSRange);
    procedure SaveBmpToFile(Picture: TPicture; FileName: string);
    function GenStyle(Range: TwawXLSRange): string;
    function GenCellStyle(Range: TwawXLSRange): string;
    procedure SaveHeadFiles;
    procedure SaveMainFile;
    procedure SaveHeadFile;
    procedure WriteStyles;
    procedure WriteRowTag(Sheet: TwawXLSWorksheet; RowIndex: Integer; Level: Integer);
    procedure WriteCellTag(Sheet: TwawXLSWorksheet; RowIndex: Integer;
      ColumnIndex: Integer; Level: Integer);
    function GetSheetFileName(SheetNumber: Integer): string;
    function GetCellTagString(Range: TwawXLSRange): string;
    function GetCellTagStringImg(Image: TwawImage): string;
    procedure InitStrings;
    function CalcTableWidth(Sheet: TwawXLSWorksheet): Integer;
    function CalcTableHeight(Sheet: TwawXLSWorksheet): Integer;
    function GetTableTag(Sheet: TwawXLSWorksheet): string;
    function GetImgStyle(Image: TwawImage): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveSheet(Sheet: TwawXLSWorksheet; FileName: string);
    procedure Save(WorkBook: TwawXLSWorkbook; FileName: string); override;
  end;

  rXLSRangeRec = record
    iXF: Integer;
    iSST: Integer;
    iFont: Integer;
    iFormat: Integer;
    Ptgs: PChar;
    PtgsSize: Integer;
  end;

  pXLSRangeRec = ^rXLSRangeRec;

  rXLSRangesRec = array[$0..$0] of rXLSRangeRec;

  pXLSRangesRec = ^rXLSRangesRec;

  rXLSSheetRec = record
    StreamBOFOffset: Integer;
    StreamBOFOffsetPosition: Integer;
  end;

  rXLSSheetsRecs = array[$0..$0] of rXLSSheetRec;

  pXLSSheetsRecs = ^rXLSSheetsRecs;

  rXLSImageRec = record
    BorderLineColorIndex: Integer;
    ForegroundFillPatternColorIndex: Integer;
    BackgroundFillPatternColorIndex: Integer;
  end;

  pXLSImageRec = ^rXLSImageRec;

  rXLSImagesRecs = array[$0..$0] of rXLSImageRec;

  pXLSImagesRecs = ^rXLSImagesRecs;

  TwawExcelWriter = class(TwawCustomWriter)
  private
    FBOFOffs: Integer;
    FWorkBook: TwawXLSWorkbook;
    FUsedColors: TList;
    FRangesRecs: pXLSRangesRec;
    FColorPalette: array[$0..XLSMaxColorsInPalette - 1] of TColor;
    FPaletteModified: Boolean;
    FSheetsRecs: pXLSSheetsRecs;
    FImagesRecs: pXLSImagesRecs;
    FCompiler: TwawExcelFormulaCompiler;
    function GetColorPaletteIndex(Color: TColor): Integer;
    procedure BuildFontList(l: TList);
    procedure BuildFormatList(sl: TStringList);
    procedure BuildXFRecord(Range: TwawXLSRange; var XF: rb8XF; prr: pXLSRangeRec);
    procedure BuildXFList(l: TList);
    procedure BuildFormulas;
    procedure BuildImagesColorsIndexes;
    procedure WriteRangeToStream(Stream: TStream; Range: TwawXLSRange;
      CurrentRow: Integer; var IndexInCellsOffsArray: Integer;
      var CellsOffs: Tb8DBCELLCellsOffsArray);
    procedure WriteSheetToStream(Stream: TStream; Sheet: TwawXLSWorksheet);
    procedure WriteSheetImagesToStream(Stream: TStream; Sheet: TwawXLSWorksheet);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveAsBIFFToStream(WorkBook: TwawXLSWorkbook; Stream: TStream);
    procedure Save(WorkBook: TwawXLSWorkbook; FileName: string); override;
  end;

const
  aDefaultColorPalette: array[$0..XLSMaxColorsInPalette - 1] of TColor =
  ($00000000, $00FFFFFF, $000000FF, $0000FF00,
    $00FF0000, $0000FFFF, $00FF00FF, $00FFFF00,
    $00000080, $00008000, $00800000, $00008080,
    $00800080, $00808000, $00C0C0C0, $00808080,
    $00FF9999, $00663399, $00CCFFFF, $00FFFFCC,
    $00660066, $008080FF, $00CC6600, $00FFCCCC,
    $00800000, $00FF00FF, $0000FFFF, $00FFFF00,
    $00800080, $00000080, $00808000, $00FF0000,
    $00FFCC00, $00FFFFCC, $00CCFFCC, $0099FFFF,
    $00FFCC99, $00CC99FF, $00FF99CC, $0099CCFF,
    $00FF6633, $00CCCC33, $0000CC99, $0000CCFF,
    $000099FF, $000066FF, $00996666, $00969696,
    $00663300, $00669933, $00003300, $00003333,
    $00003399, $00663399, $00993333, $00333333);

  aDefaultColors: array[$0..$F] of Integer =
  (clWhite, clBlack, clSilver, clGray,
    clRed, clMaroon, clYellow, clOlive,
    clLime, clGreen, clAqua, clTeal,
    clBlue, clNavy, clFuchsia, clPurple);

  aHtmlCellBorders: array[$2..$5] of string =
  ('bottom', 'left', 'right', 'top');

  aBorderLineStyles: array[$0..$D] of string =
  ('none',
    '.5pt solid',
    '1.0pt solid',
    '.5pt dashed',
    '.5pt dotted',
    '1.5pt solid',
    '2.0pt double',
    '.5pt hairline',
    '1.0pt dashed',
    '.5pt dot-dash',
    '1.0pt dot-dash',
    '.5pt dot-dot-dash',
    '1.0pt dot-dot-dash',
    '1.0pt dot-dash-slanted');

  aBorderImageLineStyles: array[$0..$8] of string =
  ('.5pt solid',
    '.5pt dashed',
    '.5pt dotted',
    '.5pt dot-dash',
    '.5pt dot-dot-dash',
    'none',
    '.5pt solid DarkGray',
    '.5pt solid MediumGray',
    '.5 pt solid LightGray');

implementation

uses
  Math, ComObj;

function MakeHTMLString(Value: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Value) do
    case Value[i] of
      Char(34): Result := Result + wawHtml_quot;
      Char(38): Result := Result + wawHtml_amp;
      Char(60): Result := Result + wawHtml_lt;
      Char(62): Result := Result + wawHtml_gt;
      Char(13): Result := Result + wawHtml_crlf;
      Char(10): if ((i = 1) or (Value[i - 1] <> Char(13))) then
          Result := Result + wawHtml_crlf;
      Char(32): if ((i = 1) or (Value[i - 1] = Char(32))) then
          Result := Result + wawHtml_space
        else
          Result := Result + Value[i];
    else
      Result := Result + Value[i];
    end;
end;

procedure WriteBlockSeparator(AStream: TStream);
var
  P: PChar;
begin
  P := @(wawBLOCKSEPARATOR[1]);
//  UniqueString(wawBLOCKSEPARATOR);
  AStream.Write(P^, Length(wawBLOCKSEPARATOR));
end;

procedure WriteStringToStream(AStream: TStream; Value: string);
var
  P: PChar;
begin
  P := @Value[1];
//  UniqueString(Value);
  AStream.Write(P^, Length(Value));
end;

procedure WriteLevelMargin(AStream: TStream; Level: Integer);
begin
  AStream.Write(wawMAXMARGINSTRING, Min(Length(wawMAXMARGINSTRING), Level));
end;

procedure WriteStringWithFormatToStream(AStream: TStream;
  Value: string; Level: Integer);
begin
  WriteLevelMargin(AStream, Level);
  WriteStringToStream(AStream, Value);
  WriteBlockSeparator(AStream);
end;

procedure WriteOpenTagFormat(AStream: TStream; Tag: string;
  Level: Integer);
begin
  WriteStringWithFormatToStream(AStream, Format('%s%s%s', [wawOPENTAGPREFIX, tag, wawTAGPOSTFIX]), Level);
end;

procedure WriteOpenTagClassFormat(AStream: TStream; Tag: string;
  Level: Integer; ClassId: Integer);
var
  ClName: string;
begin
  ClName := Format(wawSTYLEFORMAT, [ClassId]);
  WriteStringWithFormatToStream(AStream, Format('%s%s class=%s %s', [wawOPENTAGPREFIX, tag, ClName, wawTAGPOSTFIX]), Level);
end;

procedure WriteCloseTagFormat(AStream: TStream; Tag: string;
  Level: Integer);
begin
  WriteStringWithFormatToStream(AStream, Format('%s%s%s', [wawCLOSETAGPREFIX, tag, wawTAGPOSTFIX]), Level);
end;

constructor TwawHTMLWriter.Create;
begin
  Styles := TStringList.Create;
  Styles.Add(wawTABLESTYLE);
end;

destructor TwawHTMLWriter.Destroy;
begin
  Styles.Free;
end;

procedure TwawHTMLWriter.SaveHeadFiles;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FilesDir));
  if (Code = -1) or (Code = $10) then
    CreateDir(FilesDir);
  SaveMainFile;
  SaveHeadFile;
end;

procedure TwawHTMLWriter.SaveMainFile;
begin
  WriteStringWithFormatToStream(FileStream, wawHTML_VERSION, 0);
  WriteOpenTagFormat(FileStream, wawHTMLTAG, 0);
  WriteOpenTagFormat(FileStream, wawHEADTAG, 0);
  WriteOpenTagFormat(FileStream, wawTITLETAG, 1);
  WriteStringWithFormatToStream(FileStream, MakeHTMLString(FName), 2);
  WriteCloseTagFormat(FileStream, wawTITLETAG, 1);
  WriteCloseTagFormat(FileStream, wawHEADTAG, 0);
  WriteStringWithFormatToStream(FileStream, '<FRAMESET rows="39,*" border=0 width=0 frameborder=no framespacing=0>', 1);
  WriteStringWithFormatToStream(FileStream, Format('<FRAME name="header" src="%s/header.htm" marginwidth=0 marginheight=0>', [DirName]), 2);
  WriteStringWithFormatToStream(FileStream, Format('<FRAME name="sheet" src="%s/Sheet0.htm">', [DirName]), 2);
  WriteStringWithFormatToStream(FileStream, '</FRAMESET>', 1);
  WriteCloseTagFormat(FileStream, wawHTMLTAG, 0);
end;

procedure TwawHTMLWriter.SaveHeadFile;
var
  fs: TFileStream;
  i: Integer;
begin
  fs := TFileStream.Create(FilesDir + '\header.htm', fmCreate or fmShareDenyWrite);
  try
    WriteStringWithFormatToStream(fs, wawHTML_VERSION, 0);
    WriteOpenTagFormat(fs, wawHTMLTAG, 0);
    WriteOpenTagFormat(fs, wawHEADTAG, 0);
    WriteOpenTagFormat(fs, wawTITLETAG, 1);
    WriteStringWithFormatToStream(fs, MakeHTMLString(FName), 2);
    WriteCloseTagFormat(fs, wawTITLETAG, 1);
    WriteOpenTagFormat(fs, wawSTYLETAG, 0);
    WriteStringWithFormatToStream(fs, '<!--'#13#10'A { text-decoration:none; color:#000000; font-size:9pt; } A:Active { color : #0000E0}'#13#10'-->', 1);
    WriteCloseTagFormat(fs, wawSTYLETAG, 0);
    WriteCloseTagFormat(fs, wawHEADTAG, 0);
    WriteStringWithFormatToStream(fs, '<BODY topmargin=0 leftmargin=0 bgcolor="#808080">', 0);
    WriteStringWithFormatToStream(fs, '<TABLE border=0 cellspacing=1 height=100%>', 0);
    WriteStringWithFormatToStream(fs, '<TR height=10><TD>', 1);
    WriteStringWithFormatToStream(fs, '<TR>', 1);
    for i := 0 to FWorkBook.SheetsCount - 1 do
    begin
      WriteStringToStream(fs, Format('<td bgcolor="#FFFFFF" nowrap><b><small><small>&nbsp;<A href="Sheet%d.htm" target=sheet><font face="Arial">%s</FONT></A>&nbsp;</small></small></b></td>'#13#10,
        [i, TwawXLSWorksheet(FWorkBook.Sheets[i]).Title]));
    end;
    WriteCloseTagFormat(fs, wawROWTAG, 0);
    WriteCloseTagFormat(fs, wawTABLETAG, 0);
    WriteCloseTagFormat(fs, wawBODYTAG, 0);
    WriteCloseTagFormat(fs, wawHTMLTAG, 0);
  finally
    fs.Free;
  end;
end;

procedure TwawHTMLWriter.WriteStyles;
var
  i: Integer;
begin
  WriteOpenTagFormat(FileStream, wawSTYLETAG, 2);
  for i := 0 to Styles.Count - 1 do
    WriteStringToStream(FileStream, Format('.' + wawSTYLEFORMAT + ' { %s } '#13#10, [i, Styles[i]]));
  WriteCloseTagFormat(FileStream, wawSTYLETAG, 2);
end;

procedure TwawHTMLWriter.WriteRowTag(Sheet: TwawXLSWorksheet;
  RowIndex: Integer; Level: Integer);
var
  Row: TwawXLSRow;
  RowHeight: Integer;
begin
  if RowIndex >= 0 then
  begin
    Row := Sheet.FindRow(RowIndex);
    if Row = nil then
      RowHeight := Sheet.GetDefaultRowPixelHeight
    else
      RowHeight := Row.PixelHeight;
  end
  else
    RowHeight := 0;
  WriteStringWithFormatToStream(FileStream, Format('%s%s style="%s:%dpx" %s', [wawOPENTAGPREFIX, wawROWTAG, wawHEIGHTATTRIBUTE, RowHeight, wawTAGPOSTFIX]), Level);
end;

procedure TwawHTMLWriter.WriteCellTag(Sheet: TwawXLSWorksheet;
  RowIndex: Integer; ColumnIndex: Integer; Level: Integer);
var
  S: string;
  Col: TwawXLSCol;
  ColWidth: Integer;
begin
  S := wawOPENTAGPREFIX + wawCELLTAG;
  if (RowIndex = MinPos) then
  begin
    if (ColumnIndex >= 0) then
    begin
      Col := Sheet.FindCol(ColumnIndex);
      if Col <> nil then
        ColWidth := Col.PixelWidth
      else
        ColWidth := Sheet.GetDefaultColumnPixelWidth;
    end
    else
      ColWidth := 0;
    S := S + Format(' style="%s:%dpx"', [wawWIDTHATTRIBUTE, ColWidth]);
  end;
  if (RowIndex >= 0) and (ColumnIndex >= 0) and (HtmlCells^[RowIndex * ColCount + ColumnIndex].Image <> nil) then
  begin
    S := S + GetCellTagStringImg(HtmlCells^[RowIndex * ColCount + ColumnIndex].Image);
    S := S + ' CLASS=' + Format(wawSTYLEFORMAT, [HtmlCells^[RowIndex * ColCount + ColumnIndex].BordersStyleId]);
  end;
  if (RowIndex >= 0) and (ColumnIndex >= 0) and (HtmlCells^[RowIndex * ColCount + ColumnIndex].Range <> nil) then
  begin
    S := S + GetCellTagString(HtmlCells^[RowIndex * ColCount + ColumnIndex].Range);
    S := S + ' CLASS=' + Format(wawSTYLEFORMAT, [HtmlCells^[RowIndex * ColCount + ColumnIndex].BordersStyleId]);
  end;
  S := S + wawTAGPOSTFIX;
  WriteStringWithFormatToStream(FileStream, S, Level);
end;

procedure TwawHTMLWriter.AddImage(Sheet: TwawXLSWorksheet; Image: TwawImage; FileName: string;
  ImageNum: Integer);
var
  i: Integer;
  j: Integer;
  ABottom: Integer;
  ARight: Integer;
begin
  if Image.ScalePercentX > 0 then
    ARight := Image.Left + 1
  else
    ARight := Image.Right;

  if Image.ScalePercentY > 0 then
    ABottom := Image.Top + 1
  else
    ABottom := Image.Bottom;

  for i := Image.Top to ABottom - 1 do
    for j := Image.Left to ARight - 1 do
      if (i = Image.Top) and (j = Image.Left) then
      begin
        HtmlCells^[i * ColCount + j].Image := Image;
        HtmlCells^[i * ColCount + j].ImageNum := ImageNum;
      end
      else
      begin
        SpansPresent := True;
        HtmlCells^[i * ColCount + j].Hide := 1;
      end;
  SaveBmpToFile(Image.Picture, FileName);
end;

procedure TwawHTMLWriter.AddRange(Range: TwawXLSRange);
var
  i: Integer;
  j: Integer;
  StStr: string;
  BstIndex: Integer;
  StIndex: Integer;
begin
  with Range do
  begin
    StStr := GenStyle(Range);
    StIndex := Styles.IndexOf(StStr);
    if StIndex < 0 then
    begin
      Styles.Add(StStr);
      StIndex := Styles.Count - 1;
    end;

    StStr := GenCellStyle(Range);
    BstIndex := Styles.IndexOf(StStr);
    if BstIndex < 0 then
    begin
      Styles.Add(StStr);
      BstIndex := Styles.Count - 1;
    end;

    for i := Place.Top to Place.Bottom do
      for j := Place.Left to Place.Right do
      begin
        if (i = Place.Top) and (j = Place.Left) then
        begin
          HtmlCells^[i * ColCount + j].Range := Range;
          HtmlCells^[i * ColCount + j].StyleId := StIndex;
          HtmlCells^[i * ColCount + j].BordersStyleId := BstIndex;
        end
        else
        begin
          SpansPresent := True;
          HtmlCells^[i * ColCount + j].Hide := 1;
        end;
      end;
  end;
end;

procedure TwawHTMLWriter.SaveBmpToFile(Picture: TPicture;
  FileName: string);
var
  bm: TPicture;
begin
  if Picture.ClassName() = 'TBitmap' then
    Picture.SaveToFile(FileName)
  else
  begin
    bm := TPicture.Create;
    try
      bm.Bitmap.Width := Picture.Bitmap.Width;
      bm.Bitmap.Height := Picture.Bitmap.Height;
      bm.Bitmap.Canvas.Draw(0, 0, Picture.Bitmap);
      bm.SaveToFile(FileName);
    finally
      bm.Free;
    end;
  end;
end;

function Getfont_family(Font: TFont): string;
begin
  Result := Font.Name
end;

function Getfont_size(Font: TFont): Word;
begin
  Result := Font.Size
end;

function Getfont_weight(Font: TFont): string;
begin
  if fsBold in Font.Style then
    Result := wawFONT_BOLD
  else
    Result := wawFONT_NORMAL;
end;

function Getfont_style(Font: TFont): string;
begin
  if fsItalic in Font.Style then
    Result := wawFONT_ITALIC
  else
    Result := wawFONT_NORMAL;
end;

function GetText_decoration(Font: TFont): string;
begin
  Result := '';
  if fsUnderline in Font.Style then
    Result := wawFONT_UNDERLINE;
  if fsStrikeout in Font.Style then
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + wawFONT_STRIKE;
  end;
  if Result = '' then
    Result := wawFONT_NONE;
end;

function GetColor(Color: TColor): string;
var
  r: PByte;
  g: PByte;
  b: PByte;
begin
  r := @Color;
  g := @Color;
  b := @Color;
  Inc(g, 1);
  Inc(b, 2);
  Result := Format('#%.2x%.2x%.2x', [r^, g^, b^]);
end;

function GetVAlign(Align: TwawXLSVerticalAlignmentType): string;
var
  Val: string;
begin
  if Align = wawxlVAlignJustify then
    Result := ''
  else
  begin
    Result := wawVALIGN + ':';
    case Align of
      wawxlVAlignTop: Val := wawTEXTTOP;
      wawxlVAlignCenter: Val := wawMiddle;
      wawxlVAlignBottom: Val := wawTEXTBOTTOM;
    end;
    Result := Result + Val + ';';
  end;
end;

function GetTextAlign(Align: TwawXLSHorizontalAlignmentType): string;
var
  Val: string;
begin
  if not (Align in [wawxlHAlignLeft, wawxlHAlignCenter, wawxlHAlignRight, wawxlHAlignJustify]) then
    Result := ''
  else
  begin
    Result := wawTEXTALIGN + ':';
    case Align of
      wawxlHAlignLeft: Val := wawLEFT;
      wawxlHAlignCenter: Val := wawCENTER;
      wawxlHAlignRight: Val := wawRIGHT;
      wawxlHAlignJustify: Val := wawJustify;
    end;
    Result := Result + Val + ';';
  end;
end;

function TwawHTMLWriter.GetBackgroundColor(Range: TwawXLSRange):
  string;
begin
  if Range.FillPattern = wawfpNone then
    Result := ''
  else
    Result := wawBackgroundColor + ':' + GetColor(Range.ForegroundFillPatternColor) + ';';
end;

function GetBorderId(Border: TwawXLSBorderType): string;
begin
  if (Border >= wawxlEdgeBottom) and (Border <= wawxlEdgeTop) then
    Result := aHtmlCellBorders[Integer(Border)]
  else
    Result := '';
end;

function GetLineStyle(BorderLineStyle: TwawXLSLineStyleType): string;
begin
  Result := aBorderLineStyles[Integer(BorderLineStyle)];
end;

function TwawHTMLWriter.GetBorders(Range: TwawXLSRange): string;
var
  i: Integer;
  Eq: Boolean;
  lt: TwawXLSLineStyleType;
  lc: TColor;
begin
  Result := '';
  Eq := True;
  for i := ord(wawxlEdgeBottom) to ord(wawxlEdgeTop) do
  begin
    if (i > ord(wawxlEdgeBottom)) and
      ((Range.Borders[TwawXLSBorderType(i - 1)].LineStyle <> Range.Borders[TwawXLSBorderType(i)].LineStyle) or
      (Range.Borders[TwawXLSBorderType(i - 1)].Color <> Range.Borders[TwawXLSBorderType(i)].Color)) then Eq := false;
    lt := Range.Borders[TwawXLSBorderType(i)].LineStyle;
    lc := Range.Borders[TwawXLSBorderType(i)].Color;
    if (lt <> wawlsNone) then
      Result := Result + 'border-' + GetBorderId(TwawXLSBorderType(i)) + ': ' + GetLineStyle(lt) + ' ' + GetColor(lc) + ';';
  end;
  if Eq and (lt <> wawlsNone) then
    Result := 'border:' + GetLineStyle(lt) + ' ' + GetColor(lc) + ';';
end;

function TwawHTMLWriter.GenStyle(Range: TwawXLSRange): string;
begin
  Result := Format('font-family : ''%s''; font-size : %dpt; font-weight : %s; font-style : %s;  text-decoration : %s ; color : %s',
    [Getfont_family(Range.Font),
    Getfont_size(Range.Font),
      Getfont_weight(Range.Font),
      Getfont_style(Range.Font),
      Gettext_decoration(Range.Font),
      GetColor(Range.Font.Color)]);
end;

function TwawHTMLWriter.GenCellStyle(Range: TwawXLSRange): string;
begin
  Result := Format('%s %s %s %s', [GetBorders(Range), GetBackgroundColor(Range), GetVAlign(Range.VerticalAlignment), GetTextAlign(Range.HorizontalAlignment)]);
end;

function TwawHTMLWriter.GetSheetFileName(SheetNumber: Integer):
  string;
begin
  Result := Format('%s\Sheet%d%s', [FilesDir, SheetNumber, '.htm']);
end;

procedure TwawHTMLWriter.InitStrings;
begin
  FileExt := ExtractFileExt(FFileName);
  FName := Copy(FFileName, 1, Length(FFileName) - Length(FileExt));
  FilesDir := FName + '_files';
  DirName := ExtractFileName(FilesDir);
end;

function TwawHTMLWriter.CalcTableWidth(Sheet: TwawXLSWorksheet): Integer;
var
  Col: TwawXLSCol;
  i: Integer;
  ColWidth: Integer;
begin
  Result := 0;
  for i := 0 to ColCount - 1 do
  begin
    Col := Sheet.FindCol(i);
    if Col <> nil then ColWidth := Col.PixelWidth
    else ColWidth := Sheet.GetDefaultColumnPixelWidth;
    Result := Result + ColWidth;
  end;
end;

function TwawHTMLWriter.CalcTableHeight(Sheet: TwawXLSWorksheet): Integer;
var
  Row: TwawXLSRow;
  i: Integer;
  RowHeight: Integer;
begin
  Result := 0;
  for i := 0 to RowCount - 1 do
  begin
    Row := Sheet.FindRow(i);
    if Row <> nil then RowHeight := Row.PixelHeight
    else RowHeight := Sheet.GetDefaultRowPixelHeight;
    Result := Result + RowHeight;
  end;
end;

function TwawHTMLWriter.GetTableTag(Sheet: TwawXLSWorksheet): string;
begin
  Result := Format('TABLE style="width:%dpx;height:%dpx"', [CalcTableWidth(Sheet), CalcTableHeight(Sheet)]);
end;

function TwawHTMLWriter.GetImgStyle(Image: TwawImage): string;
var
  Wstr: string;
  Hstr: string;
begin
  if Image.ScalePercentX = 0 then
    Wstr := '100%'
  else
    Wstr := Format('%dpx', [Muldiv(Image.Picture.Width, Image.ScalePercentX, 100)]);
  if Image.ScalePercentY = 0 then
    Hstr := '100%'
  else
    Hstr := Format('%dpx', [Muldiv(Image.Picture.Height, Image.ScalePercentY, 100)]);

  Result := Format('width:%s;heigth:%s;border: %s %s',
    [Wstr, Hstr, GetColor(Image.BorderLineColor), aBorderImageLineStyles[Integer(Image.BorderLineStyle)]]);
end;

procedure TwawHTMLWriter.Save(WorkBook: TwawXLSWorkbook;
  FileName: string);
var
  i: Integer;
  Writer: TwawHTMLWriter;
begin
  FFileName := FileName;
  InitStrings;
  FileStream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    FWorkBook := WorkBook;
    SaveHeadFiles;
  finally
    FileStream.Free;
  end;
  for i := 0 to WorkBook.SheetsCount - 1 do
  begin
    Writer := TwawHTMLWriter.Create;
    try
      Writer.SaveSheet(TwawXLSWorksheet(WorkBook.Sheets[i]), GetSheetFileName(i));
    finally
      Writer.Free;
    end;
  end;
end;

procedure TwawHTMLWriter.CheckBounds(Images: TwawImages);
var
  i: Integer;
begin
  for i := 0 to Images.Count - 1 do
  begin
    RowCount := Max(RowCount, Images[i].Bottom);
    ColCount := Max(ColCount, Images[i].Right);
  end;
end;

procedure TwawHTMLWriter.SaveSheet(Sheet: TwawXLSWorksheet;
  FileName: string);
var
  i: Integer;
  j: Integer;
  ImgFileName: string;
begin
  FileStream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    with Sheet do
    begin
      SpansPresent := false;
      RowCount := Dimensions.Bottom + 1;
      ColCount := Dimensions.Right + 1;
      CheckBounds(Images);
      HtmlCells := AllocMem(RowCount * ColCount * (SizeOf(TwawHtmlCell)));
      ZeroMemory(HtmlCells, RowCount * ColCount * (SizeOf(TwawHtmlCell)));
      try
        for i := 0 to Images.Count - 1 do
        begin
          ImgFileName := Format('%s_p%d.bmp', [ChangeFileExt(FileName, ''), i]);
          self.AddImage(Sheet, Images[i], ImgFileName, i);
        end;
        for i := 0 to RangesCount - 1 do
          self.AddRange(RangeByIndex[i]);

        if SpansPresent then
          MinPos := -1
        else
          MinPos := 0;
        WriteStringWithFormatToStream(FileStream, wawHTML_VERSION, 0);
        WriteOpenTagFormat(FileStream, wawHTMLTAG, 0);
        WriteOpenTagFormat(FileStream, wawHEADTAG, 0);
        WriteOpenTagFormat(FileStream, wawTITLETAG, 1);
        WriteStringWithFormatToStream(FileStream, MakeHTMLString(Sheet.Title), 2);
        WriteCloseTagFormat(FileStream, wawTITLETAG, 1);
        WriteStyles;
        WriteCloseTagFormat(FileStream, wawHEADTAG, 0);
        WriteOpenTagFormat(FileStream, wawBODYTAG, 0);
        WriteOpenTagFormat(FileStream, wawFORMTAG, 0);
        WriteOpenTagClassFormat(FileStream, GetTableTag(Sheet), 0, 0);
        for i := MinPos to RowCount - 1 do
        begin
          WriteRowTag(Sheet, i, 1);
          for j := MinPos to ColCount - 1 do
          begin
            if (i >= 0) and (j >= 0) and (HtmlCells^[i * ColCount + j].Hide = 0) then
            begin
              WriteCellTag(Sheet, i, j, 2);
              if (HtmlCells^[i * ColCount + j].Image <> nil) then
                WriteStringWithFormatToStream(FileStream, '<IMG src="' +
                  Format('%s_p%d.bmp', [ChangeFileExt(ExtractFileName(FileName), ''), HtmlCells^[i * ColCount + j].ImageNum]) +
                  Format('" style="%S"', [GetImgStyle(HtmlCells^[i * ColCount + j].Image)]) + wawTAGPOSTFIX, 2);
              if (HtmlCells^[i * ColCount + j].Range <> nil) then
                WriteStringWithFormatToStream(FileStream, '<SPAN CLASS=' +
                  Format(wawSTYLEFORMAT, [HtmlCells^[i * ColCount + j].StyleId]) + wawTAGPOSTFIX +
                  MakeHTMLString(HtmlCells^[i * ColCount + j].Range.Value) + '</SPAN>', 2);
              WriteCloseTagFormat(FileStream, wawCELLTAG, 2);
            end
            else
              if (i = MinPos) and (j >= 0) then
              begin
                WriteCellTag(Sheet, i, j, 2);
                WriteCloseTagFormat(FileStream, wawCELLTAG, 2);
              end;
          end;
          WriteCloseTagFormat(FileStream, wawROWTAG, 1);
        end;
        WriteCloseTagFormat(FileStream, wawTABLETAG, 1);
        WriteCloseTagFormat(FileStream, wawFORMTAG, 0);
        WriteCloseTagFormat(FileStream, wawBODYTAG, 0);
        WriteCloseTagFormat(FileStream, wawHTMLTAG, 0);
      finally
        FreeMem(HtmlCells);
      end;
    end;
  finally
    FileStream.Free;
  end;
end;

function TwawHTMLWriter.GetCellTagString(Range: TwawXLSRange): string;
var
  ColSpan: Integer;
  RowSpan: Integer;
begin
  Result := '';
  with Range do
  begin
    RowSpan := Place.Bottom - Place.Top + 1;
    ColSpan := Place.Right - Place.Left + 1;
  end;
  if RowSpan > 1 then
    Result := Result + Format(' %s=%d', [wawROWSPANATTRIBUTE, rowspan]);
  if ColSpan > 1 then
    Result := Result + Format(' %s=%d', [wawCOLSPANATTRIBUTE, colspan]);
end;

function TwawHTMLWriter.GetCellTagStringImg(Image: TwawImage): string;
var
  ColSpan: Integer;
  RowSpan: Integer;
begin
  Result := '';
  RowSpan := Image.Bottom - Image.Top;
  ColSpan := Image.Right - Image.Left;
  if RowSpan > 1 then
    Result := Result + Format(' %s=%d', [wawROWSPANATTRIBUTE, rowspan]);
  if ColSpan > 1 then
    Result := Result + Format(' %s=%d', [wawCOLSPANATTRIBUTE, colspan]);
end;

procedure wbiff(Stream: TStream; code: Word; buf: Pointer; size: Integer);
var
  sz: Word;
begin
  repeat
    Stream.Write(code, 2);
    sz := Min(size, MaxBiffRecordSize - 4);
    Stream.Write(sz, 2);
    if sz > 0 then
    begin
      Stream.Write(buf^, sz);
      buf := PChar(buf) + sz;
      size := size - sz;
      code := b8_CONTINUE;
    end;
  until size <= 0;
end;

procedure wbiffFont(Stream: TStream; f: TFont; ColorPaletteIndex: Word);
var
  font: pb8FONT;
  lf: TLogFont;
  lfont: Integer;
begin
  lfont := Length(f.Name) * sizeof(WideChar);
  font := AllocMem(sizeof(rb8FONT) + lfont);
  try
    GetObject(f.Handle, SizeOf(TLogFont), @lf);
    font.dyHeight := f.Size * 20;
    if fsItalic in f.Style then
      font.grbit := font.grbit or b8_FONT_grbit_fItalic;
    if fsStrikeout in f.Style then
      font.grbit := font.grbit or b8_FONT_grbit_fStrikeout;
    font.icv := ColorPaletteIndex;
    if fsBold in f.Style then
      font.bls := $3E8 // from MSDN
    else
      font.bls := $64; // from MSDN
    if fsUnderline in f.Style then
      font.uls := 1; // from MSDN
    font.bFamily := lf.lfPitchAndFamily;
    font.bCharSet := lf.lfCharSet;
    font.cch := FormatStrToWideChar(f.Name, PWideChar(PChar(font) + sizeof(rb8FONT)));
    font.cchgrbit := $01;

    wbiff(Stream, b8_FONT, font, sizeof(rb8FONT) + (font.cch shl 1));
  finally
    FreeMem(font);
  end;
end;

procedure wbiffFormat(Stream: TStream; FormatString: string;
  FormatCode: Word);
var
  lformat: Integer;
  format: pb8FORMAT;
begin
  lformat := Length(FormatString) * sizeof(WideChar);
  format := AllocMem(sizeof(rb8FORMAT) + lformat);
  try
    format.ifmt := FormatCode;
    format.cch := FormatStrToWideChar(FormatString, PWideChar(PChar(format) + sizeof(rb8FORMAT)));
    format.cchgrbit := 1;
    wbiff(Stream, b8_FORMAT, format, sizeof(rb8FORMAT) + (format.cch shl 1));
  finally
    FreeMem(format);
  end;
end;

function HexStringToString(s: string): string;
var
  b1: string;
  i: Integer;
  ls: Integer;
begin
  Result := '';
  ls := length(s);
  i := 1;
  while i <= ls do
  begin
    while (i <= ls) and not (s[i] in ['0'..'9', 'a'..'f', 'A'..'F']) do Inc(i);
    if i > ls then break;
    b1 := '';
    while (i <= ls) and (s[i] in ['0'..'9', 'a'..'f', 'A'..'F']) do
    begin
      b1 := b1 + s[i];
      Inc(i);
    end;
    if b1 <> '' then
      Result := Result + char(StrToInt('$' + b1));
    if (b1 = '') or (i > ls) then break;
  end;
end;

procedure wbiffHexString(Stream: TStream; HexString: string);
var
  s: string;
begin
  s := HexStringToString(HexString);
  UniqueString(s);
  Stream.Write(s[1], Length(s));
end;

constructor TwawExcelWriter.Create;
begin
  FCompiler := TwawExcelFormulaCompiler.Create;
  FUsedColors := TList.Create;
end;

destructor TwawExcelWriter.Destroy;
begin
  FCompiler.Free;
  FUsedColors.Free;
end;

procedure TwawExcelWriter.BuildFontList(l: TList);
var
  f: TFont;
  sh: TwawXLSWorksheet;
  ran: TwawXLSRange;
  i: Integer;
  j: Integer;
  k: Integer;
  n: Integer;
begin
  n := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    sh := FWorkBook.Sheets[i];
    for j := 0 to sh.RangesCount - 1 do
    begin
      ran := sh.RangeByIndex[j];
      ran.ExportData := Addr(FRangesRecs^[n]);
      f := ran.Font;
      k := 0;
      while (k < L.Count) and
        ((TFont(L[k]).Charset <> f.Charset) or
        (TFont(L[k]).Color <> f.Color) or
        (TFont(L[k]).Height <> f.Height) or
        (TFont(L[k]).Name <> f.Name) or
        (TFont(L[k]).Pitch <> f.Pitch) or
        (TFont(L[k]).Size <> f.Size) or
        (TFont(L[k]).Style <> f.Style)) do Inc(k);
      if k >= L.Count then
      begin
        k := L.Add(TFont.Create);
        TFont(L[k]).Assign(f);
      end;
      FRangesRecs[n].iFont := k + 1;
      Inc(n);
    end;
  end;
end;

procedure TwawExcelWriter.BuildFormatList(sl: TStringList);
var
  sh: TwawXLSWorksheet;
  ran: TwawXLSRange;
  i: Integer;
  j: Integer;
  k: Integer;
  n: Integer;
  m: Integer;
begin
  n := sl.Count;
  m := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    sh := FWorkBook.Sheets[i];
    for j := 0 to sh.RangesCount - 1 do
    begin
      ran := sh.RangeByIndex[j];
      if ran.Format = '' then
        FRangesRecs^[m].iFormat := 0
      else
      begin
        k := sl.IndexOf(ran.Format);
        if k = -1 then
          k := sl.AddObject(ran.Format, TObject(sl.Count - n + $32));
        FRangesRecs^[m].iFormat := integer(sl.Objects[k]);
      end;
      Inc(m);
    end;
  end;
end;

procedure TwawExcelWriter.BuildXFRecord(Range: TwawXLSRange;
  var XF: rb8XF; prr: pXLSRangeRec);
var
  DiagBorderLineStyle: TwawXLSLineStyleType;
  DiagBorderColorIndex: Integer;
const
  aFillPattern: array[TwawXLSFillPattern] of Integer =
  (0, -4105, 9, 16, -4121, 18, 17, -4124, -4125, -4126, 15, -4128, 13, 11, 14, 12, 10, 1, -4162, -4166);
  aHorizontalAlignment: array[TwawXLSHorizontalAlignmentType] of Integer =
  (b8_XF_Opt2_alcGeneral,
    b8_XF_Opt2_alcLeft,
    b8_XF_Opt2_alcCenter,
    b8_XF_Opt2_alcRight,
    b8_XF_Opt2_alcFill,
    b8_XF_Opt2_alcJustify,
    b8_XF_Opt2_alcCenterAcrossSelection);
  aVerticalAlignment: array[TwawXLSVerticalAlignmentType] of Integer =
  (b8_XF_Opt2_alcVTop,
    b8_XF_Opt2_alcVCenter,
    b8_XF_Opt2_alcVBottom,
    b8_XF_Opt2_alcVJustify);
  aWrapText: array[Boolean] of Integer = (0, b8_XF_Opt2_fWrap);
  aBorderLineStyle: array[TwawXLSLineStyleType] of Word =
  (b8_XF_Border_None,
    b8_XF_Border_Thin,
    b8_XF_Border_Medium,
    b8_XF_Border_Dashed,
    b8_XF_Border_Dotted,
    b8_XF_Border_Thick,
    b8_XF_Border_Double,
    b8_XF_Border_Hair,
    b8_XF_Border_MediumDashed,
    b8_XF_Border_DashDot,
    b8_XF_Border_MediumDashDot,
    b8_XF_Border_DashDotDot,
    b8_XF_Border_MediumDashDotDot,
    b8_XF_Border_SlantedDashDot);
  function GetBorderColorIndex(b: TwawXLSBorderType): Integer;
  begin
    if Range.Borders[b].LineStyle = wawlsNone then
      Result := 0
    else
      Result := GetColorPaletteIndex(Range.Borders[b].Color);
  end;
begin
  ZeroMemory(@XF, sizeof(XF));
  XF.ifnt := prr.iFont;
  XF.ifmt := pXLSRangeRec(Range.ExportData).iFormat;
  XF.Opt1 := $0001; //b8_XF_Opt1_fLocked or b8_XF_Opt1_fHidden;
  XF.Opt2 := aHorizontalAlignment[Range.HorizontalAlignment] or
    aWrapText[Range.WrapText] or
    aVerticalAlignment[Range.VerticalAlignment];
  XF.trot := Range.Rotation;
  XF.Opt3 := b8_XF_Opt3_fAtrNum or
    b8_XF_Opt3_fAtrFnt or
    b8_XF_Opt3_fAtrAlc or
    b8_XF_Opt3_fAtrBdr or
    b8_XF_Opt3_fAtrPat; // $7C00
  if (Range.Place.Left <> Range.Place.Right) or (Range.Place.Top <> Range.Place.Bottom) then
    XF.Opt3 := XF.Opt3 or b8_XF_Opt3_fMergeCell;

// borders
  XF.Borders1 := (aBorderLineStyle[Range.Borders[wawxlEdgeLeft].LineStyle]) or
    (aBorderLineStyle[Range.Borders[wawxlEdgeRight].LineStyle] shl 4) or
    (aBorderLineStyle[Range.Borders[wawxlEdgeTop].LineStyle] shl 8) or
    (aBorderLineStyle[Range.Borders[wawxlEdgeBottom].LineStyle] shl 12);
  DiagBorderLineStyle := wawlsNone;
  DiagBorderColorIndex := 0;
  XF.Borders2 := 0;
  if Range.Borders[wawxlDiagonalDown].LineStyle <> wawlsNone then
  begin
    XF.Borders2 := XF.Borders2 or $4000;
    DiagBorderLineStyle := Range.Borders[wawxlDiagonalDown].LineStyle;
    DiagBorderColorIndex := GetColorPaletteIndex(Range.Borders[wawxlDiagonalDown].Color) + 8;
  end;
  if Range.Borders[wawxlDiagonalUp].LineStyle <> wawlsNone then
  begin
    XF.Borders2 := XF.Borders2 or $8000;
    DiagBorderLineStyle := Range.Borders[wawxlDiagonalUp].LineStyle;
    DiagBorderColorIndex := GetColorPaletteIndex(Range.Borders[wawxlDiagonalUp].Color) + 8;
  end;
  XF.Borders2 := XF.Borders2 or
    (GetBorderColorIndex(wawxlEdgeLeft)) or
    (GetBorderColorIndex(wawxlEdgeRight) shl 7);
  XF.Borders3 := (GetBorderColorIndex(wawxlEdgeTop)) or
    (GetBorderColorIndex(wawxlEdgeBottom) shl 7) or
    (DiagBorderColorIndex shl 14) or
    (aBorderLineStyle[DiagBorderLineStyle] shl 21) or
    (aFillPattern[Range.FillPattern] shl 26);
  XF.Colors := GetColorPaletteIndex(Range.ForegroundFillPatternColor) or
    (GetColorPaletteIndex(Range.BackgroundFillPatternColor) shl 7); // colors for fill pattern
end;

procedure TwawExcelWriter.BuildXFList(l: TList);
var
  p: Pointer;
  XF: rb8XF;
  sh: TwawXLSWorksheet;
  ran: TwawXLSRange;
  i: Integer;
  j: Integer;
  k: Integer;
  n: Integer;
begin
  n := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    sh := FWorkBook.Sheets[i];
    for j := 0 to sh.RangesCount - 1 do
    begin
      ran := sh.RangeByIndex[j];
      BuildXFRecord(ran, XF, @FRangesRecs^[n]);
      k := 0;
      while (k < l.Count) and not CompareMem(l[k], @XF, sizeof(rb8XF)) do Inc(k);
      if k >= l.Count then
      begin
        GetMem(p, sizeof(rb8XF));
        CopyMemory(p, @XF, sizeof(rb8XF));
        k := l.Add(p);
      end;
      FRangesRecs^[n].iXF := k + 15; // 15 - count of STYLE XF records
      Inc(n);
    end;
  end;
end;

procedure TwawExcelWriter.BuildFormulas;
var
  sh: TwawXLSWorksheet;
  ran: TwawXLSRange;
  i: Integer;
  j: Integer;
  n: Integer;
begin
  n := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    sh := FWorkBook.Sheets[i];
    for j := 0 to sh.RangesCount - 1 do
    begin
      ran := sh.RangeByIndex[j];
      FRangesRecs^[n].Ptgs := nil;
      FRangesRecs^[n].PtgsSize := 0;
      if ran.CellDataType = wawcdtFormula then
        FCompiler.CompileFormula(ran.Formula,
          FRangesRecs^[n].Ptgs,
          FRangesRecs^[n].PtgsSize);
      Inc(n);
    end;
  end;
end;

function TwawExcelWriter.GetColorPaletteIndex(Color: TColor): Integer;
  function DefaultColorIndex(c: TColor): Integer;
  begin
    Result := 0;
    while (Result < MaxDefaultColors) and (aDefaultColors[Result] <> c) do Inc(Result);
    if Result >= MaxDefaultColors then
      Result := Result or -1;
  end;
begin
  if (Color and $80000000) <> 0 then
    Color := GetSysColor(Color and $00FFFFFF);
  if FUsedColors.IndexOf(Pointer(Color)) = -1 then
    FUsedColors.Add(Pointer(Color));
  Result := 0;
  while (Result < XLSMaxColorsInPalette) and (FColorPalette[Result] <> Color) do Inc(Result);
  if Result < XLSMaxColorsInPalette then
  begin
    Result := Result + 8;
    exit; // color exist in current palette
  end;
  Result := 0;
  while Result < XLSMaxColorsInPalette do
  begin
    if (DefaultColorIndex(FColorPalette[Result]) = -1) and
      (FUsedColors.IndexOf(Pointer(FColorPalette[Result])) = -1) then
    begin
        // replace color in palette with new color
      FColorPalette[Result] := Color;
      FPaletteModified := true;
      Result := Result + 8;
      exit;
    end;
    Inc(Result);
  end;
  Result := 8; // return index to BLACK color
end;

function sort(Item1: Pointer; Item2: Pointer): Integer;
begin
  Result := TwawXLSRange(Item1).Place.Left - TwawXLSRange(Item2).Place.Left;
end;

procedure TwawExcelWriter.WriteRangeToStream(Stream: TStream;
  Range: TwawXLSRange; CurrentRow: Integer;
  var IndexInCellsOffsArray: Integer;
  var CellsOffs: Tb8DBCELLCellsOffsArray);
var
  blank: rb8BLANK;
  i: Integer;
  Left: Integer;
  number: rb8NUMBER;
  mulblank: pb8MULBLANK;
  labelsst: rb8LABELSST;
  formula: pb8FORMULA;
  procedure AddToCellsOffsArray;
  begin
    if IndexInCellsOffsArray = 0 then
      CellsOffs[IndexInCellsOffsArray] := Stream.Position
    else
      CellsOffs[IndexInCellsOffsArray] := Stream.Position - CellsOffs[IndexInCellsOffsArray - 1];
    Inc(IndexInCellsOffsArray);
  end;
begin
  Left := Range.Place.Left;
  if CurrentRow = Range.Place.Top then
  begin
    // write data cell, check cell type
    case Range.CellDataType of
      wawcdtNumber:
        begin
          AddToCellsOffsArray;
          number.rw := CurrentRow;
          number.col := Left;
          number.ixfe := pXLSRangeRec(Range.ExportData).iXF;
          number.num := Range.Value;
          wbiff(Stream, b8_NUMBER, @number, sizeof(rb8NUMBER));
          Inc(Left);
        end;
      wawcdtString:
        begin
          if pXLSRangeRec(Range.ExportData).iSST <> -1 then
          begin
            AddToCellsOffsArray;
            labelsst.rw := CurrentRow;
            labelsst.col := Left;
            labelsst.ixfe := pXLSRangeRec(Range.ExportData).iXF;
            labelsst.isst := pXLSRangeRec(Range.ExportData).iSST;
            wbiff(Stream, b8_LABELSST, @labelsst, sizeof(labelsst));
            Inc(Left);
          end;
        end;
      wawcdtFormula:
        begin
          AddToCellsOffsArray;
          formula := AllocMem(pXLSRangeRec(Range.ExportData).PtgsSize + sizeof(rb8FORMULA));
          try
            formula.rw := CurrentRow;
            formula.col := Left;
            formula.ixfe := pXLSRangeRec(Range.ExportData).iXF;
            formula.value := 0;
            formula.grbit := 1;
            formula.chn := 0;
            formula.cce := pXLSRangeRec(Range.ExportData).PtgsSize;
            MoveMemory(PChar(PChar(formula) + sizeof(rb8FORMULA)),
              pXLSRangeRec(Range.ExportData).Ptgs,
              pXLSRangeRec(Range.ExportData).PtgsSize);
            wbiff(Stream, b8_FORMULA, formula, pXLSRangeRec(Range.ExportData).PtgsSize + sizeof(rb8FORMULA));
            Inc(Left);
          finally
            FreeMem(formula);
          end;
        end;
    end;
  end;
  if Left < Range.Place.Right then
  begin
    AddToCellsOffsArray;
    mulblank := AllocMem(sizeof(rb8MULBLANK) + (Range.Place.Right - Left + 1) * 2 + 2);
    try
      mulblank.rw := CurrentRow;
      mulblank.colFirst := Left;
      for i := 0 to Range.Place.Right - Left do
        PWordArray(PChar(mulblank) + sizeof(rb8MULBLANK))^[i] := pXLSRangeRec(Range.ExportData).iXF;
      PWord(PChar(mulblank) + sizeof(rb8MULBLANK) + (Range.Place.Right - Left + 1) * 2)^ := Range.Place.Right;
      wbiff(Stream, b8_MULBLANK, mulblank, sizeof(rb8MULBLANK) + (Range.Place.Right - Left + 1) * 2 + 2);
    finally
      FreeMem(mulblank);
    end;
  end
  else
    if Left = Range.Place.Right then
    begin
      AddToCellsOffsArray;
      blank.rw := CurrentRow;
      blank.col := Left;
      blank.ixfe := pXLSRangeRec(Range.ExportData).iXF;
      wbiff(Stream, b8_BLANK, @blank, sizeof(blank));
    end;
end;

procedure TwawExcelWriter.WriteSheetToStream(Stream: TStream; Sheet: TwawXLSWorksheet);
var
  s: string;
  bof: rb8BOF;
  guts: rb8GUTS;
  wsbool: rb8WSBOOL;
  header: pb8HEADER;
  footer: pb8FOOTER;
  hcenter: rb8HCENTER;
  vcenter: rb8VCENTER;
  refmode: rb8REFMODE;
  gridset: rb8GRIDSET;
  window2: rb8WINDOW2;
  calcmode: rb8CALCMODE;
  calccount: rb8CALCCOUNT;
  iteration: rb8ITERATION;
  selection: pb8SELECTION;
  saverecalc: rb8SAVERECALC;
  dimensions: rb8DIMENSIONS;
  defcolwidth: rb8DEFCOLWIDTH;
  printheaders: rb8PRINTHEADERS;
  printgridlines: rb8PRINTGRIDLINES;
  defaultrowheight: rb8DEFAULTROWHEIGHT;
  l: TList;
  rw: TwawXLSRow;
  ran: TwawXLSRange;
  row: rb8ROW;
  bc: Integer;
  i: Integer;
  j: Integer;
  index: pb8INDEX;
  INDEXOffs: Integer;
  BlocksInSheet: Integer;
  IndexInDBCELLsOffs: Integer;
  dbcell: rb8DBCELLfull;
  IndexInCellsOffsArray: Integer;
  ms: TMemoryStream;
  merge: PChar;
  colinfo: rb8COLINFO;
  FirstRowOffs: Integer;
  SecondRowOffs: Integer;
  setup: rb8SETUP;
  topmargin: rb8TOPMARGIN;
  leftmargin: rb8LEFTMARGIN;
  rightmargin: rb8RIGHTMARGIN;
  bottommargin: rb8BOTTOMMARGIN;
  horizontalpagebreaks: pb8HORIZONTALPAGEBREAKS;
begin
  ZeroMemory(@bof, sizeof(bof));
  bof.vers := b8_BOF_vers;
  bof.dt := b8_BOF_dt_Worksheet;
  bof.rupBuild := b8_BOF_rupBuild_Excel97;
  bof.rupYear := b8_BOF_rupYear_Excel07;
  wbiff(Stream, b8_BOF, @bof, sizeof(bof));

  if (Sheet.Dimensions.Bottom <> -1) and (Sheet.Dimensions.Top <> -1) then
  begin
    BlocksInSheet := (Sheet.Dimensions.Bottom - Sheet.Dimensions.Top + 1) div XLSMaxRowsInBlock;
    if (Sheet.Dimensions.Bottom = Sheet.Dimensions.Top) or (((Sheet.Dimensions.Bottom - Sheet.Dimensions.Top + 1) mod XLSMaxRowsInBlock) <> 0) then
      Inc(BlocksInSheet);
  end
  else
    BlocksInSheet := 0;

  index := AllocMem(sizeof(rb8INDEX) + BlocksInSheet * 4);
  try
    if (Sheet.Dimensions.Bottom <> -1) and (Sheet.Dimensions.Top <> -1) then
    begin
      index.rwMic := Sheet.Dimensions.Top;
      index.rwMac := Sheet.Dimensions.Bottom + 1;
    end;
    INDEXOffs := Stream.Position;
    IndexInDBCELLsOffs := 0;
    wbiff(Stream, b8_INDEX, index, sizeof(rb8INDEX) + BlocksInSheet * 4); // corrected later

    calcmode.fAutoRecalc := 1; // automatic recalc
    wbiff(Stream, b8_CALCMODE, @calcmode, sizeof(calcmode));

    calccount.cIter := $0064; // see in biffview
    wbiff(Stream, b8_CALCCOUNT, @calccount, sizeof(calccount));

    refmode.fRefA1 := $0001; // 1 for A1 mode
    wbiff(Stream, b8_REFMODE, @refmode, sizeof(refmode));

    iteration.fIter := $0000; // 1 see in biffview
    wbiff(Stream, b8_ITERATION, @iteration, sizeof(iteration));
  // DELTA
    s := HexStringToString('10 00 08 00 fc a9 f1 d2 4d 62 50 3f');
    UniqueString(s);
    Stream.Write(s[1], length(s));

    saverecalc.fSaveRecalc := $0001; // see in biffview
    wbiff(Stream, b8_SAVERECALC, @saverecalc, sizeof(saverecalc));

    if Sheet.PageSetup.PrintHeaders then
      printheaders.fPrintRwCol := 1
    else
      printheaders.fPrintRwCol := 0;
    wbiff(Stream, b8_PRINTHEADERS, @printheaders, sizeof(printheaders));

    if Sheet.PageSetup.PrintGridLines then
      printgridlines.fPrintGrid := 1
    else
      printgridlines.fPrintGrid := 0;
    wbiff(Stream, b8_PRINTGRIDLINES, @printgridlines, sizeof(printgridlines));

    gridset.fGridSet := $0001; // see in biffview
    wbiff(Stream, b8_GRIDSET, @gridset, sizeof(gridset));

    ZeroMemory(@guts, sizeof(guts)); // all to zero see in biffview
    wbiff(Stream, b8_GUTS, @guts, sizeof(guts));

    defaultrowheight.grbit := $0000; // see in biffview
    defaultrowheight.miyRw := xlsDefaultRowHeight; // see in biffview
    wbiff(Stream, b8_DEFAULTROWHEIGHT, @defaultrowheight, sizeof(defaultrowheight));

    if Sheet.PageBreaksCount > 0 then
    begin
      horizontalpagebreaks := AllocMem(Sheet.PageBreaksCount * sizeof(rb8HORIZONTALPAGEBREAK) + 2);
      try
        horizontalpagebreaks.cbrk := Sheet.PageBreaksCount;
        for i := 0 to Sheet.PageBreaksCount - 1 do
        begin
          pb8HORIZONTALPAGEBREAK(PCHAR(horizontalpagebreaks) + sizeof(rb8HORIZONTALPAGEBREAKS) +
            sizeof(rb8HORIZONTALPAGEBREAK) * i)^.row := Sheet.PageBreaks[i];
          pb8HORIZONTALPAGEBREAK(PCHAR(horizontalpagebreaks) + sizeof(rb8HORIZONTALPAGEBREAKS) +
            sizeof(rb8HORIZONTALPAGEBREAK) * i)^.startcol := $0000;
          pb8HORIZONTALPAGEBREAK(PCHAR(horizontalpagebreaks) + sizeof(rb8HORIZONTALPAGEBREAKS) +
            sizeof(rb8HORIZONTALPAGEBREAK) * i)^.endcol := $00FF;
        end;
        wbiff(Stream, b8_HORIZONTALPAGEBREAKS, horizontalpagebreaks,
          Sheet.PageBreaksCount * sizeof(rb8HORIZONTALPAGEBREAK) + sizeof(rb8HORIZONTALPAGEBREAKS));
      finally
        FreeMem(horizontalpagebreaks);
      end;
    end;

    wsbool.grbit := $04C1; // see in biffview
    wbiff(Stream, b8_WSBOOL, @wsbool, sizeof(wsbool));

    s := '';
    if Sheet.PageSetup.LeftHeader <> '' then
      s := s + '&L' + Sheet.PageSetup.LeftHeader;
    if Sheet.PageSetup.CenterHeader <> '' then
      s := s + '&C' + Sheet.PageSetup.CenterHeader;
    if Sheet.PageSetup.RightHeader <> '' then
      s := s + '&R' + Sheet.PageSetup.RightHeader;
    if s <> '' then
    begin
      GetMem(header, sizeof(rb8HEADER) + Length(s) * sizeof(WideChar));
      try
        i := FormatStrToWideChar(s, PWideChar(PChar(header) + sizeof(rb8HEADER)));
        header.cch := i;
        header.cchgrbit := 1;
        wbiff(Stream, b8_HEADER, header, sizeof(rb8HEADER) + (i shl 1));
      finally
        FreeMem(header);
      end;
    end
    else
      wbiff(Stream, b8_HEADER, nil, 0);

    s := '';
    if Sheet.PageSetup.LeftFooter <> '' then
      s := s + '&L' + Sheet.PageSetup.LeftFooter;
    if Sheet.PageSetup.CenterFooter <> '' then
      s := s + '&C' + Sheet.PageSetup.CenterFooter;
    if Sheet.PageSetup.RightFooter <> '' then
      s := s + '&R' + Sheet.PageSetup.RightFooter;
    if s <> '' then
    begin
      GetMem(footer, sizeof(rb8FOOTER) + Length(s) * sizeof(WideChar));
      try
        i := FormatStrToWideChar(s, PWideChar(PChar(footer) + sizeof(rb8HEADER)));
        footer.cch := i;
        footer.cchgrbit := 1;
        wbiff(Stream, b8_FOOTER, footer, sizeof(rb8FOOTER) + (i shl 1));
      finally
        FreeMem(footer);
      end;
    end
    else
      wbiff(Stream, b8_FOOTER, nil, 0);

    if Sheet.PageSetup.CenterHorizontally then
      hcenter.fHCenter := 1
    else
      hcenter.fHCenter := 0;
    wbiff(Stream, b8_HCENTER, @hcenter, sizeof(hcenter));

    if Sheet.PageSetup.CenterVertically then
      vcenter.fVCenter := 1
    else
      vcenter.fVCenter := 0;
    wbiff(Stream, b8_VCENTER, @vcenter, sizeof(vcenter));

    leftmargin.num := Sheet.PageSetup.LeftMargin;
    wbiff(Stream, b8_LEFTMARGIN, @leftmargin, sizeof(rb8LEFTMARGIN));
    rightmargin.num := Sheet.PageSetup.RightMargin;
    wbiff(Stream, b8_RIGHTMARGIN, @rightmargin, sizeof(rb8RIGHTMARGIN));
    topmargin.num := Sheet.PageSetup.TopMargin;
    wbiff(Stream, b8_TOPMARGIN, @topmargin, sizeof(rb8TOPMARGIN));
    bottommargin.num := Sheet.PageSetup.BottomMargin;
    wbiff(Stream, b8_BOTTOMMARGIN, @bottommargin, sizeof(rb8BOTTOMMARGIN));

    ZeroMemory(@setup, sizeof(rb8SETUP));
    setup.iPaperSize := word(Sheet.PageSetup.PaperSize);
    setup.iPageStart := Sheet.PageSetup.FirstPageNumber;
    setup.iFitWidth := Sheet.PageSetup.FitToPagesWide;
    setup.iFitHeight := Sheet.PageSetup.FitToPagesTall;
    setup.numHdr := Sheet.PageSetup.HeaderMargin;
    setup.numFtr := Sheet.PageSetup.FooterMargin;
    setup.iCopies := Sheet.PageSetup.Copies;
    setup.iScale := Sheet.PageSetup.Zoom;
//  setup.grbit := b8_SETUP_fNoPls;
    if Sheet.PageSetup.Order = wawxlOverThenDown then
      setup.grbit := setup.grbit or b8_SETUP_fLeftToRight;
    if Sheet.PageSetup.Orientation = wawxlPortrait then
      setup.grbit := setup.grbit or b8_SETUP_fLandscape;
    if Sheet.PageSetup.BlackAndWhite then
      setup.grbit := setup.grbit or b8_SETUP_fNoColor;
    if Sheet.PageSetup.Draft then
      setup.grbit := setup.grbit or b8_SETUP_fDraft;
    if Sheet.PageSetup.PrintNotes then
      setup.grbit := setup.grbit or b8_SETUP_fNotes;
    if Sheet.PageSetup.FirstPageNumber <> 1 then
      setup.grbit := setup.grbit or b8_SETUP_fUsePage;
    wbiff(Stream, b8_SETUP, @setup, sizeof(rb8SETUP));

    defcolwidth.cchdefColWidth := XLSDefaultColumnWidthInChars; // see in biffview
    wbiff(Stream, b8_DEFCOLWIDTH, @defcolwidth, sizeof(defcolwidth));

    for i := 0 to Sheet.ColsCount - 1 do
      with Sheet.ColByIndex[i] do
      begin
        ZeroMemory(@colinfo, sizeof(colinfo));
        colinfo.colFirst := Ind;
        colinfo.colLast := Ind;
        colinfo.coldx := Width;
        colinfo.ixfe := $0F; //waw see from *.xls
        colinfo.grbit := $02; //waw
        if Width = 0 then
          colinfo.grbit := colinfo.grbit or $01; //waw
        colinfo.res1 := $02; //waw
        wbiff(Stream, b8_COLINFO, @colinfo, sizeof(colinfo));
      end;

    ZeroMemory(@dimensions, sizeof(dimensions));
    if (Sheet.Dimensions.Left <> -1) and
      (Sheet.Dimensions.Right <> -1) and
      (Sheet.Dimensions.Top <> -1) and
      (Sheet.Dimensions.Bottom <> -1) then
    begin
      dimensions.rwMic := Sheet.Dimensions.Top;
      dimensions.rwMac := Sheet.Dimensions.Bottom + 1;
      dimensions.colMic := Sheet.Dimensions.Left;
      dimensions.colMac := Sheet.Dimensions.Right + 1;
    end;
    wbiff(Stream, b8_DIMENSIONS, @dimensions, sizeof(dimensions));

    if (Sheet.Dimensions.Top <> -1) and (Sheet.Dimensions.Bottom <> -1) then
    begin
      l := TList.Create;
      ms := TMemoryStream.Create;
      try
        bc := 0;
        FirstRowOffs := 0;
        SecondRowOffs := 0;
        for i := Sheet.Dimensions.Top to Sheet.Dimensions.Bottom do
        begin
            // finding all regions what placed over row [i]
          l.Clear;
          for j := 0 to Sheet.RangesCount - 1 do
          begin
            ran := Sheet.RangeByIndex[j];
            if (ran.Place.Top <= i) and (i <= ran.Place.Bottom) then
              l.Add(ran);
          end;
          l.Sort(sort);
            // write row i to file
          if bc = 0 then
            FirstRowOffs := Stream.Position;
          row.rw := i;
          if l.Count > 0 then
          begin
            row.colMic := TwawXLSRange(l[0]).Place.Left;
            row.colMac := TwawXLSRange(l[l.Count - 1]).Place.Right + 1;
          end
          else
          begin
            row.colMic := 0;
            row.colMac := 0;
          end;
            // to determine row height find TwawXLSRow, if not found
            // simple set default height
          rw := Sheet.FindRow(i);
          if rw = nil then
          begin
            row.miyRw := XLSDefaultRowHeight;
            row.grbit := 0;
          end
          else
          begin
            row.miyRw := rw.Height;
            row.irwMac := 0; //waw
            row.res1 := 0; //waw
            row.grbit := b8_ROW_grbit_fDefault or b8_ROW_grbit_fUnsynced; //waw
            if row.miyRw = 0 then //waw
              row.grbit := row.grbit or b8_ROW_grbit_fDyZero;
            row.ixfe := $0F; //waw
          end;
          wbiff(Stream, b8_ROW, @row, sizeof(row));
          if bc = 0 then
            SecondRowOffs := Stream.Position;

            // write row cells to temporary memorystream,
            // also save cell offset from SecondRowOffs to CellsOffs
          IndexInCellsOffsArray := 0;
          for j := 0 to l.Count - 1 do
            WriteRangeToStream(ms, TwawXLSRange(l[j]), i, IndexInCellsOffsArray, dbcell.CellsOffs);

          Inc(bc);
          if (bc = XLSMaxRowsInBlock) or (i = Sheet.Dimensions.Bottom) then
          begin
            dbcell.CellsOffs[0] := Stream.Position - SecondRowOffs;
              // write from temporary memorystream to Stream
            ms.SaveToStream(Stream);
              // rows block ended - write DBCELL
              // save DBCell offset
            PCardinalArray(PChar(index) + sizeof(rb8INDEX))^[IndexInDBCELLsOffs] := Stream.Position - FBOFOffs;
            Inc(IndexInDBCELLsOffs);

            dbcell.dbRtrw := Stream.Position - FirstRowOffs;
            wbiff(Stream, b8_DBCELL, @dbcell, sizeof(rb8DBCELL) + IndexInCellsOffsArray * 2);
              // reinit vars
            ms.Clear;
            bc := 0;
          end;
        end;
      finally
        l.Free;
        ms.Free;
      end;

      // correct index record
      Stream.Position := INDEXOffs;
      wbiff(Stream, b8_INDEX, index, sizeof(rb8INDEX) + BlocksInSheet * 4);
      Stream.Seek(0, soFromEnd);
    end;
  finally
    FreeMem(index);
  end;
  WriteSheetImagesToStream(Stream, Sheet);

  ZeroMemory(@window2, sizeof(window2));
  window2.grbit := b8_WINDOW2_grbit_fPaged or // $06B6 - this value see in biffview
    b8_WINDOW2_grbit_fDspGuts or
    b8_WINDOW2_grbit_fDspZeros or
    b8_WINDOW2_grbit_fDefaultHdr or
    b8_WINDOW2_grbit_fDspGrid or
    b8_WINDOW2_grbit_fDspRwCol;
  if Sheet.IndexInWorkBook = 0 then
    window2.grbit := window2.grbit + b8_WINDOW2_grbit_fSelected;
  window2.rwTop := 0;
  window2.colLeft := 0;
  window2.icvHdr := $00000040;
  window2.wScaleSLV := 0;
  window2.wScaleNormal := 0;
  wbiff(Stream, b8_WINDOW2, @window2, sizeof(window2));

  selection := AllocMem(sizeof(rb8SELECTION) + 6);
  try
    selection.pnn := 3; // see in biffview
    selection.cref := 1;
    wbiff(Stream, b8_SELECTION, selection, sizeof(rb8SELECTION) + 6);
  finally
    FreeMem(selection);
  end;

// write data about merge ranges
  if Sheet.RangesCount > 0 then
  begin
    j := 0;
    for i := 0 to Sheet.RangesCount - 1 do
    begin
      ran := Sheet.RangeByIndex[i];
      if (ran.Place.Left <> ran.Place.Right) or
        (ran.Place.Top <> ran.Place.Bottom) then
        Inc(j);
    end;
{    if j>0 then
      begin
        merge := AllocMem(sizeof(rb8MERGE)+j*8);
        try
          pb8MERGE(merge)^.cnt := j;
          j := 0;
          for i:=0 to Sheet.RangesCount-1 do
            begin
              ran := Sheet.RangeByIndex[i];
              if(ran.Place.Left<>ran.Place.Right) or(ran.Place.Top<>ran.Place.Bottom) then
                begin
                  with pb8MERGErec(PChar(merge)+sizeof(rb8MERGE)+j*8)^ do
                    begin
                      top := ran.Place.Top;
                      bottom := ran.Place.Bottom;
                      left := ran.Place.Left;
                      right := ran.Place.Right;
                    end;
                  Inc(j);
                end;
            end;
          wbiff(Stream,b8_MERGE,merge,sizeof(rb8MERGE)+j*8);
        finally
          FreeMem(merge);
        end;
      end;}

     // shaoyy modifed
    if j > 0 then
    begin
      merge := AllocMem(sizeof(rb8MERGE) + 8);
      pb8MERGE(merge)^.cnt := 1;
       // j :=0;
      for i := 0 to Sheet.RangesCount - 1 do
      begin
        ran := Sheet.RangeByIndex[i];
        if (ran.Place.Left <> ran.Place.Right) or (ran.Place.Top <> ran.Place.Bottom) then
        begin
          with pb8MERGErec(PChar(merge) + sizeof(rb8MERGE))^ do
          begin
            top := ran.Place.Top;
            bottom := ran.Place.Bottom;
            left := ran.Place.Left;
            right := ran.Place.Right;
          end;
                //  Inc(j);
          wbiff(Stream, b8_MERGE, merge, sizeof(rb8MERGE) + 8);
        end;
      end;
      FreeMem(merge);
    end;
     //end shaoyy
  end;

  wbiff(Stream, b8_EOF, nil, 0);
end;

procedure TwawExcelWriter.BuildImagesColorsIndexes;
var
  i: Integer;
  j: Integer;
  n: Integer;
begin
  n := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    for j := 0 to FWorkBook.Sheets[i].Images.Count - 1 do
    begin
      FImagesRecs^[n].BorderLineColorIndex :=
        GetColorPaletteIndex(FWorkBook.Sheets[i].Images[j].BorderLineColor);
      FImagesRecs^[n].ForegroundFillPatternColorIndex := GetColorPaletteIndex($FFFFFF);
      FImagesRecs^[n].BackgroundFillPatternColorIndex := GetColorPaletteIndex($FFFFFF);
      inc(n);
    end;
  end;
end;

procedure TwawExcelWriter.WriteSheetImagesToStream(Stream: TStream;
  Sheet: TwawXLSWorksheet);
var
  ms: TMemoryStream;
  mf: TMetafile;
  mfc: TMetafileCanvas;
  obj: pb8OBJ;
  img: TwawImage;
  pir: pXLSImageRec;
  imdata: rb8IMDATA;
  i: Integer;
  n: Integer;
  k: Integer;
  w: Integer;
  objpicture: pb8OBJPICTURE;
const
  aBorderLineStyles: array[TwawXLSImageBorderLineStyle] of Byte =
  ($00, $01, $02, $03, $04, $05, $06, $07, $08);
  aBorderLineWeight: array[TwawXLSImageBorderLineWeight] of Byte =
  ($00, $01, $02, $03);
  function GetColWidth(ColIndex: Integer): Integer;
  var
    c: TwawXLSCol;
  begin
    c := Sheet.FindCol(ColIndex);
    if c = nil then
      Result := Sheet.GetDefaultColumnPixelWidth
    else
      Result := c.PixelWidth;
  end;
  function GetRowHeight(RowIndex: Integer): Integer;
  var
    r: TwawXLSRow;
  begin
    r := Sheet.FindRow(RowIndex);
    if r = nil then
      Result := Sheet.GetDefaultRowPixelHeight
    else
      Result := r.PixelHeight;
  end;
begin
  obj := AllocMem(sizeof(rb8OBJ) + sizeof(rb8OBJPICTURE));
  objpicture := pb8OBJPICTURE(PChar(obj) + sizeof(rb8OBJ));
  ms := TMemoryStream.Create;
  try
    n := 0;
    w := 0;
    for i := 0 to Sheet.IndexInWorkBook - 1 do
      n := n + Sheet.WorkBook.Sheets[i].Images.Count;
    for i := 0 to Sheet.Images.Count - 1 do
    begin
      img := Sheet.Images[i];
      pir := Addr(FImagesRecs^[n]);
      ZeroMemory(obj, sizeof(rb8OBJ) + sizeof(rb8OBJPICTURE));
      pb8OBJ(obj)^.cObj := Sheet.Images.Count;
      pb8OBJ(obj)^.OT := b8_OBJ_OT_PictureObject;
      pb8OBJ(obj)^.id := i + 1;
      pb8OBJ(obj)^.grbit := $0614;
      pb8OBJ(obj)^.colL := img.Left;
      pb8OBJ(obj)^.dxL := img.LeftCO;
      pb8OBJ(obj)^.rwT := img.Top;
      pb8OBJ(obj)^.dyT := img.TopCO;
      if img.ScalePercentX > 0 then
      begin
        pb8OBJ(obj)^.colR := img.Left;
        k := MulDiv(img.Picture.Width, img.ScalePercentX, 100) +
          MulDiv(GetColWidth(pb8OBJ(obj)^.colR), img.LeftCO, $400);
        while k > 0 do
        begin
          w := GetColWidth(pb8OBJ(obj)^.colR);
          if w = 0 then break;
          k := k - w;
          Inc(pb8OBJ(obj)^.colR);
        end;
        if k < 0 then
        begin
          Dec(pb8OBJ(obj)^.colR);
          pb8OBJ(obj)^.dxR := MulDiv(k + w, $400, w);
        end
        else
          pb8OBJ(obj)^.dxR := 0;
      end
      else
      begin
        pb8OBJ(obj)^.colR := img.Right;
        pb8OBJ(obj)^.dxR := img.RightCO;
      end;
      if img.ScalePercentY > 0 then
      begin
        pb8OBJ(obj)^.rwB := img.Top;
        k := MulDiv(img.Picture.Height, img.ScalePercentY, 100) +
          MulDiv(GetRowHeight(pb8OBJ(obj)^.rwB), img.TopCO, $100);
        while k > 0 do
        begin
          w := GetRowHeight(pb8OBJ(obj)^.rwB);
          if w = 0 then break;
          k := k - w;
          Inc(pb8OBJ(obj)^.rwB);
        end;
        if k < 0 then
        begin
          Dec(pb8OBJ(obj)^.rwB);
          pb8OBJ(obj)^.dyB := MulDiv(k + w, $100, w);
        end
        else
          pb8OBJ(obj)^.dyB := 0;
      end
      else
      begin
        pb8OBJ(obj)^.rwB := img.Bottom;
        pb8OBJ(obj)^.dyB := img.BottomCO;
      end;
      pb8OBJ(obj)^.cbMacro := 0;
      pb8OBJPICTURE(objpicture)^.icvBack := pir.BackgroundFillPatternColorIndex;
      pb8OBJPICTURE(objpicture)^.icvFore := pir.ForegroundFillPatternColorIndex;
      pb8OBJPICTURE(objpicture)^.fls := 1;
      pb8OBJPICTURE(objpicture)^.fAutoFill := 0;
      pb8OBJPICTURE(objpicture)^.icv := pir.BorderLineColorIndex;
      pb8OBJPICTURE(objpicture)^.lns := aBorderLineStyles[img.BorderLineStyle];
      pb8OBJPICTURE(objpicture)^.lnw := aBorderLineWeight[img.BorderLineWeight];
      pb8OBJPICTURE(objpicture)^.fAutoBorder := b8_XF_Border_None;
      pb8OBJPICTURE(objpicture)^.frs := 0;
      pb8OBJPICTURE(objpicture)^.cf := 2;
      pb8OBJPICTURE(objpicture)^.Reserved1 := 0;
      pb8OBJPICTURE(objpicture)^.cbPictFmla := 0;
      pb8OBJPICTURE(objpicture)^.Reserved2 := 0;
      pb8OBJPICTURE(objpicture)^.grbit := 0;
      pb8OBJPICTURE(objpicture)^.Reserved3 := 0;
      wbiff(Stream, b8_OBJ, obj, sizeof(rb8OBJ) + sizeof(rb8OBJPICTURE));

      ms.Clear;
      imdata.cf := 2;
      imdata.env := 1;
      imdata.lcb := 0;
      ms.Write(imdata, sizeof(rb8IMDATA));
      mf := TMetafile.Create;
      try
        mf.Height := img.Picture.Height;
        mf.Width := img.Picture.Width;
        mfc := TMetafileCanvas.Create(mf, 0);
        mfc.CopyMode := cmSrcCopy;
        mfc.Draw(0, 0, img.Picture.Graphic);
        mfc.Free;
        mf.SaveToStream(ms);
      finally
        mf.Free;
      end;
      imdata.lcb := ms.Size - sizeof(rb8IMDATA);
      ms.Position := 4;
      ms.Write(PChar(imdata.lcb), sizeof(Cardinal));
      wbiff(Stream, b8_IMDATA, ms.Memory, ms.Size);
      Inc(n);
    end;
  finally
    ms.Free;
    FreeMem(obj);
  end;
end;

procedure TwawExcelWriter.SaveAsBIFFToStream(WorkBook: TwawXLSWorkbook;
  Stream: TStream);
var
  sstsizeoffset: Integer;
  ltitleoffset: Integer;
  sstblockoffset: Integer;
  lsstbuf: Integer;
  sstsize: Integer;
  extsstsize: Integer;
  i: Integer;
  j: Integer;
  k: Integer;
  m: Integer;
  ltitle: Integer;
  RangesCount: Integer;
  s: string;
  l: TList;
  sl: TStringList;
  sh: TwawXLSWorksheet;
  bof: rb8BOF;
  mms: rb8MMS;
  codepage: rb8CODEPAGE;
  interfachdr: rb8INTERFACHDR;
  fngroupcount: rb8FNGROUPCOUNT;
  windowprotect: rb8WINDOWPROTECT;
  protect: rb8PROTECT;
  password: rb8PASSWORD;
  backup: rb8BACKUP;
  hideobj: rb8HIDEOBJ;
  s1904: rb81904;
  precision: rb8PRECISION;
  bookbool: rb8BOOKBOOL;
  writeaccess: rb8WRITEACCESS;
  doublestreamfile: rb8DOUBLESTREAMFILE;
  prot4rev: rb8PROT4REV;
  prot4revpass: rb8PROT4REVPASS;
  window1: rb8WINDOW1;
  refreshall: rb8REFRESHALL;
  useselfs: rb8USESELFS;
  boundsheet: pb8BOUNDSHEET;
  country: rb8COUNTRY;
  palette: rb8PALETTE;
  sst: PChar;
  sstbuf: PChar;
  extsst: pb8EXTSST;
  supbook: pb8SUPBOOK;
  externsheet: pb8EXTERNSHEET;
  xti: pb8XTI;
  sz: Word;
  buf: Pointer;
  P: Pointer;
  procedure AddDefXF(HexString: string);
  var
    s: string;
    buf: Pointer;
  begin
    s := HexStringToString(HexString);
    UniqueString(s);
    GetMem(buf, Length(s));
    CopyMemory(buf, @s[1], Length(s));
    l.Add(buf);
  end;
begin
  FWorkBook := WorkBook;
  RangesCount := 0;
  k := 0;
  for i := 0 to FWorkBook.SheetsCount - 1 do
  begin
    RangesCount := RangesCount + FWorkBook.Sheets[i].RangesCount;
    k := k + FWorkBook.Sheets[i].Images.Count;
  end;
  GetMem(FRangesRecs, RangesCount * sizeof(rXLSRangeRec));
  GetMem(FSheetsRecs, FWorkBook.SheetsCount * sizeof(rXLSSheetRec));
  GetMem(FImagesRecs, k * sizeof(rXLSImageRec));

  try
  // set palette to default values
    CopyMemory(@FColorPalette[0], @aDefaultColorPalette[0], XLSMaxColorsInPalette * sizeof(TColor));
    FPaletteModified := false;
    FUsedColors.Clear;

    FBOFOffs := Stream.Position;
    ZeroMemory(@bof, sizeof(bof));
    bof.vers := b8_BOF_vers; //$0600
    bof.dt := b8_BOF_dt_WorkbookGlobals; //$0005
    bof.rupBuild := b8_BOF_rupBuild_Excel97; //$0DBB
    bof.rupYear := b8_BOF_rupYear_Excel07; //$07CC
    bof.sfo := b8_BOF_vers; //$00000600
    wbiff(Stream, b8_BOF, @bof, sizeof(bof));

    interfachdr.cv := b8_INTERFACHDR_cv_ANSI; //$04E4;
    wbiff(Stream, b8_INTERFACHDR, @interfachdr, sizeof(interfachdr));

    ZeroMemory(@mms, sizeof(mms));
    wbiff(Stream, b8_MMS, @mms, sizeof(mms));

    wbiff(Stream, b8_INTERFACEND, nil, 0);

    FillMemory(PChar(@writeaccess), sizeof(writeaccess), 32);
    FormatStrToWideChar(Workbook.UserNameOfExcel, PWideChar(@writeaccess.stName[0]));
    wbiff(Stream, b8_WRITEACCESS, @writeaccess.stName[0], sizeof(writeaccess));

    codepage.cv := b8_CODEPAGE_cv_ANSI;
    wbiff(Stream, b8_CODEPAGE, @codepage, sizeof(codepage));

    doublestreamfile.fDSF := 0;
    wbiff(Stream, b8_DOUBLESTREAMFILE, @doublestreamfile, sizeof(doublestreamfile));

  // see in biffview, not found in MSDN
    wbiff(Stream, $01C0, nil, 0);

    GetMem(buf, WorkBook.SheetsCount * Sizeof(Word));
    try
      for i := 0 to WorkBook.SheetsCount - 1 do
        PWordArray(buf)^[i] := i + 1;
      wbiff(Stream, b8_TABID, buf, WorkBook.SheetsCount * Sizeof(Word));
    finally
      FreeMem(buf);
    end;

    fngroupcount.cFnGroup := $000E; // viewed in biffview
    wbiff(Stream, b8_FNGROUPCOUNT, @fngroupcount, sizeof(fngroupcount));

    windowprotect.fLockWn := 0; // viewed in biffview
    wbiff(Stream, b8_WINDOWPROTECT, @windowprotect, sizeof(windowprotect));

    protect.fLock := 0; // viewed in biffview
    wbiff(Stream, b8_PROTECT, @protect, sizeof(protect));

    password.wPassword := 0; // viewed in biffview
    wbiff(Stream, b8_PASSWORD, @password, sizeof(password));

    prot4rev.fRevLock := 0; // see in biffview
    wbiff(Stream, b8_PROT4REV, @prot4rev, sizeof(prot4rev));

    prot4revpass.wrevPass := 0; // see in biffview
    wbiff(Stream, b8_PROT4REVPASS, @prot4revpass, sizeof(prot4revpass));

    ZeroMemory(@window1, sizeof(window1));
    window1.xWn := $0168;
    window1.yWn := $001E;
    window1.dxWn := $1D1F; //$1D1E;
    window1.dyWn := $1860;
    window1.grbit := $0038;
    window1.itabCur := $0000;
    window1.itabFirst := $0000;
    window1.ctabSel := $0001;
    window1.wTabRatio := $0258;
    wbiff(Stream, b8_WINDOW1, @window1, sizeof(window1));

    backup.fBackupFile := 0; // set to 1 to enable backup
    wbiff(Stream, b8_BACKUP, @backup, sizeof(backup));

    hideobj.fHideObj := 0; // viewed in biffview
    wbiff(Stream, b8_HIDEOBJ, @hideobj, sizeof(hideobj));

    s1904.f1904 := 0; // = 1 if the 1904 date system is used
    wbiff(Stream, b8_1904, @s1904, sizeof(s1904));

    precision.fFullPrec := 1; // viewed in biffview
    wbiff(Stream, b8_PRECISION, @precision, sizeof(precision));

    refreshall.fRefreshAll := 0;
    wbiff(Stream, b8_REFRESHALL, @refreshall, sizeof(refreshall));

    bookbool.fNoSaveSupp := 0; // viewed in biffview
    wbiff(Stream, b8_BOOKBOOL, @bookbool, sizeof(bookbool));

  // FONTS
    l := TList.Create;
    try
    // 1. Add One default font records
      for i := 0 to 3 do
        with TFont(L[L.Add(TFont.Create)]) do
        begin
          Name := sDefaultFontName;
          Size := 10;
        end;
    // 2. Build list of unique FONT records and write them
    // and init ExportData
      BuildFontList(l);

    // 3. write fonts
      for i := 0 to l.Count - 1 do
        wbiffFont(Stream, TFont(l[i]), GetColorPaletteIndex(TFont(l[i]).Color));
    finally
      for i := 0 to l.Count - 1 do
        TFont(l[i]).Free;
      l.Free;
    end;

  // FORMATS
    sl := TStringList.Create;
    try
    // 1. Add default format records
      sl.AddObject('#,##0"ð.";\-#,##0"ð."', TObject($0005));
      sl.AddObject('#,##0"ð.";[Red]\-#,##0"ð."', TObject($0006));
      sl.AddObject('#,##0.00"ð.";\-#,##0.00"ð."', TObject($0007));
      sl.AddObject('#,##0.00"ð.";[Red]\-#,##0.00"ð."', TObject($0008));
      sl.AddObject('_-* #,##0"ð."_-;\-* #,##0"ð."_-;_-* "-""ð."_-;_-@_-', TObject($002A));
      sl.AddObject('_-* #,##0_ð_._-;\-* #,##0_ð_._-;_-* "-"_ð_._-;_-@_-', TObject($0029));
      sl.AddObject('_-* #,##0.00"ð."_-;\-* #,##0.00"ð."_-;_-* "-"??"ð."_-;_-@_-', TObject($002C));
      sl.AddObject('_-* #,##0.00_ð_._-;\-* #,##0.00_ð_._-;_-* "-"??_ð_._-;_-@_-', TObject($002B));
    // 2. build format records list
      BuildFormatList(sl);
    // 3. write formats
      for i := 0 to sl.Count - 1 do
        wbiffFormat(Stream, sl[i], word(sl.Objects[i]));
    finally
      sl.Free;
    end;

  // Style XF
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 00 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 01 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 01 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 02 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 02 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');
    wbiffHexString(Stream, 'e0 00 14 00 00 00 00 00 f5 ff 20 00 00 f4 00 00 00 00 00 00 00 00 c0 20');

  // XF
    l := TList.Create;
    try
    // 1. Add default XF record
      AddDefXF('00 00 00 00 01 00 20 00 00 00 00 00 00 00 00 00 00 00 C0 20'); //ox15ec
      AddDefXF('01 00 2C 00 F5 FF 20 00 00 F8 00 00 00 00 00 00 00 00 C0 20'); //ox1630
      AddDefXF('01 00 2A 00 F5 FF 20 00 00 F8 00 00 00 00 00 00 00 00 C0 20'); //ox1630
      AddDefXF('01 00 09 00 F5 FF 20 00 00 F8 00 00 00 00 00 00 00 00 C0 20'); //ox1630
      AddDefXF('01 00 2B 00 F5 FF 20 00 00 F8 00 00 00 00 00 00 00 00 C0 20'); //ox1630
      AddDefXF('01 00 29 00 F5 FF 20 00 00 F8 00 00 00 00 00 00 00 00 C0 20'); //ox1630
    // 2. Build list of unique XF records and write them
      BuildXFList(l);
    // 3. write XF
      for i := 0 to l.Count - 1 do
        wbiff(Stream, b8_XF, l[i], sizeof(rb8XF));
    finally
      for i := 0 to l.Count - 1 do
        FreeMem(l[i]);
      l.Free;
    end;

  // STYLE see in biffview, i dont use this ability simple write bytes
    wbiffHexString(Stream, '93 02 04 00 10 80 04 FF');
    wbiffHexString(Stream, '93 02 04 00 11 80 07 FF');
    wbiffHexString(Stream, '93 02 04 00 00 80 00 FF');
    wbiffHexString(Stream, '93 02 04 00 12 80 05 FF');
    wbiffHexString(Stream, '93 02 04 00 13 80 03 FF');
    wbiffHexString(Stream, '93 02 04 00 14 80 06 FF');

    BuildImagesColorsIndexes;

  // PALETTE
    if FPaletteModified then
    begin
      palette.ccv := XLSMaxColorsInPalette;
      for i := 0 to XLSMaxColorsInPalette - 1 do
        palette.colors[i] := FColorPalette[i];
      wbiff(Stream, b8_PALETTE, @palette, sizeof(palette));
    end;

    useselfs.fUsesElfs := 0;
    wbiff(Stream, b8_USESELFS, @useselfs, sizeof(useselfs));

  // Sheets information
    for i := 0 to FWorkBook.SheetsCount - 1 do
    begin
      sh := FWorkBook.Sheets[i];
      FSheetsRecs^[i].StreamBOFOffsetPosition := Stream.Position + 4;
      ltitle := Length(sh.Title) * sizeof(WideChar);
      boundsheet := AllocMem(sizeof(rb8BOUNDSHEET) + ltitle);
      try
        P := PChar(PChar(boundsheet) + sizeof(rb8BOUNDSHEET));
        boundsheet.cch := FormatStrToWideChar(sh.Title, P);
        boundsheet.grbit := 0;
        boundsheet.cchgrbit := 1;
        wbiff(Stream, b8_BOUNDSHEET, boundsheet, sizeof(rb8BOUNDSHEET) + (boundsheet.cch shl 1));
      finally
        FreeMem(boundsheet);
      end;
    end;


    country.iCountryDef := $56;
    country.iCountryWinIni := $56;
    wbiff(Stream, b8_COUNTRY, @country, sizeof(country));

    BuildFormulas;

    if FCompiler.ExtRefs.SheetsCount > 0 then
    begin
      externsheet := AllocMem(sizeof(rb8EXTERNSHEET) + 2);
      try
        externsheet.cXTI := FCompiler.ExtRefs.SheetsCount;
        PWord(PChar(externsheet) + sizeof(rb8EXTERNSHEET))^ := $0401;
        wbiff(Stream, b8_SUPBOOK, externsheet, sizeof(rb8EXTERNSHEET) + 2);
      finally
        FreeMem(externsheet);
      end;
      for i := 0 to FCompiler.ExtRefs.BooksCount - 1 do
      begin
        s := FCompiler.ExtRefs.Books[i].Name;
        if s <> '' then
        begin
          k := Length(s) * sizeof(Widechar) + sizeof(rb8SUPBOOK);
          supbook := AllocMem(k);
          try
            P := PChar(PChar(supbook) + sizeof(rb8SUPBOOK));
            k := FormatStrToWideChar(s, P);
            supbook.Ctab := FCompiler.ExtRefs.Books[i].SheetsCount;
            supbook.cch := k + 1;
            supbook.grbit := 1;
            supbook.code := 1;
            k := sizeof(rb8SUPBOOK) + (k shl 1);
            P := PWideChar(PChar(supbook) + k + 3);
            for j := 0 to FCompiler.ExtRefs.Books[i].SheetsCount - 1 do
            begin
              s := FCompiler.ExtRefs.Books[i].Sheets[j].Name;
              ReallocMem(supbook, Length(s) * sizeof(Widechar) + k + 3);
              m := FormatStrToWideChar(s, P);
              PWord(PChar(supbook) + k)^ := m shl 1;
              k := k + 2;
              PChar(PChar(supbook) + k)^ := Char(1);
              k := k + 1;
              P := PChar(PChar(supbook) + k);
              k := k + (m shl 1);
            end;
            wbiff(Stream, b8_SUPBOOK, supbook, k);
          finally
            FreeMem(supbook);
          end;
        end;
      end;
      xti := AllocMem((FCompiler.ExtRefs.SheetsCount) * sizeof(rb8XTI) + 2);
      buf := xti;
      try
        PWord(buf)^ := FCompiler.ExtRefs.SheetsCount;
        buf := PChar(buf) + 2;
        for i := 0 to FCompiler.ExtRefs.SheetsCount - 1 do
        begin
          buf := PChar(buf) + i * sizeof(rb8XTI);
          pb8XTI(buf)^.iSUPBOOK := FCompiler.ExtRefs.Sheets[i].iSUPBOOK;
          if FCompiler.ExtRefs.Books[FCompiler.ExtRefs.Sheets[i].iSUPBOOK].Name = '' then
            pb8XTI(buf)^.itabFirst := WorkBook.GetSheetIndex(FCompiler.ExtRefs.Sheets[i].Name)
          else
            pb8XTI(buf)^.itabFirst := FCompiler.ExtRefs.Sheets[i].itab;
          pb8XTI(buf)^.itabLast := pb8XTI(buf)^.itabFirst;
        end;
        wbiff(Stream, b8_EXTERNSHET, xti, (FCompiler.ExtRefs.SheetsCount) * sizeof(rb8XTI) + 2);
      finally
        FreeMem(xti);
      end;
    end;
  // SST build sst table
    extsstsize := sizeof(rb8EXTSST);
    extsst := AllocMem(extsstsize);
    extsst.Dsst := 8;

    sstsize := sizeof(rb8SST) + 4;
    sst := AllocMem(sstsize);
    PWord(sst)^ := b8_SST;
    sstsizeoffset := 2;
    PWord(sst + sstsizeoffset)^ := sizeof(rb8SST);
    sstblockoffset := sstsize;
    lsstbuf := 0;
    sstbuf := nil;

    k := 0;
    m := 0;
    try
      for i := 0 to FWorkBook.SheetsCount - 1 do
      begin
        sh := FWorkBook.Sheets[i];
        for j := 0 to sh.RangesCount - 1 do
        begin
          if sh.RangeByIndex[j].CellDataType = wawcdtString then
          begin
            s := VarToStr(sh.RangeByIndex[j].Value);
            if s <> '' then
            begin
              FRangesRecs^[m].iSST := k;
              Inc(k);

                    // convert string to UNICODE
              ltitle :=Length(s) * sizeof(WideChar);
              if lsstbuf < ltitle then
              begin
                lsstbuf := ltitle;
                ReallocMem(sstbuf, lsstbuf);
              end;
              P := PChar(sstbuf);
              ltitle := FormatStrToWideChar(s, p);

              if MaxBiffRecordSize - sstblockoffset <= 4 then
              begin
                        // start new CONTINUE record
                ReallocMem(sst, sstsize + 4);
                PWord(sst + sstsize)^ := b8_CONTINUE;
                sstsize := sstsize + 2;
                sstsizeoffset := sstsize;
                PWord(sst + sstsize)^ := 0;
                sstsize := sstsize + 2;
                sstblockoffset := 4;
              end;

              if (k mod 8) = 1 then
              begin
                ReallocMem(extsst, extsstsize + sizeof(rb8ISSTINF));
                pb8ISSTINF(PChar(extsst) + extsstsize).cb := sstblockoffset;
                pb8ISSTINF(PChar(extsst) + extsstsize).ib := Stream.Position + sstsize;
                pb8ISSTINF(PChar(extsst) + extsstsize).res1 := 0;
                extsstsize := extsstsize + sizeof(rb8ISSTINF);
              end;

              ReallocMem(sst, sstsize + 3);
              PWord(sst + sstsize)^ := ltitle;
              sstsize := sstsize + 2;
              PByte(sst + sstsize)^ := 1;
              sstsize := sstsize + 1;
              PWord(sst + sstsizeoffset)^ := PWord(sst + sstsizeoffset)^ + 3;
              sstblockoffset := sstblockoffset + 3;

              ltitle := ltitle * sizeof(Widechar);
              ltitleoffset := 0;
              repeat
                sz := (Min(ltitle - ltitleoffset, MaxBiffRecordSize - sstblockoffset)) and (not 1);
                ReallocMem(sst, sstsize + sz);
                CopyMemory(sst + sstsize, sstbuf + ltitleoffset, sz);
                sstsize := sstsize + sz;
                sstblockoffset := sstblockoffset + sz;
                ltitleoffset := ltitleoffset + sz;
                PWord(sst + sstsizeoffset)^ := PWord(sst + sstsizeoffset)^ + sz;
                if (ltitle > ltitleoffset) and ((MaxBiffRecordSize - sstblockoffset) <= 4) then
                begin
                          // begin CONTINUE record
                  ReallocMem(sst, sstsize + 5);
                  PWord(sst + sstsize)^ := b8_CONTINUE;
                  sstsize := sstsize + 2;
                  sstsizeoffset := sstsize;
                  PWord(sst + sstsize)^ := 1;
                  sstsize := sstsize + 2;
                  PByte(sst + sstsize)^ := 1;
                  sstsize := sstsize + 1;
                  sstblockoffset := 5;
                end;
              until ltitle <= ltitleoffset;
            end;
          end;
          Inc(m);
        end;
      end;
      if k <> 0 then
      begin
        pb8SST(sst + 4).cstTotal := k;
        pb8SST(sst + 4).cstUnique := k;
        Stream.Write(sst^, sstsize);
        wbiff(Stream, b8_EXTSST, extsst, extsstsize);
      end;
    finally
      FreeMem(sst);
      FreeMem(sstbuf);
      FreeMem(extsst);
    end;

    wbiff(Stream, b8_EOF, nil, 0);

  //
    for i := 0 to FWorkBook.SheetsCount - 1 do
    begin
      sh := FWorkBook.Sheets[i];
      FSheetsRecs^[i].StreamBOFOffset := Stream.Position;
      WriteSheetToStream(Stream, sh);
    end;

  // updating sheets information
    for i := 0 to FWorkBook.SheetsCount - 1 do
    begin
      Stream.Position := FSheetsRecs^[i].StreamBOFOffsetPosition;
      Stream.Write(FSheetsRecs^[i].StreamBOFOffset, 4);
    end;

  finally
    FUsedColors.Clear;
    FCompiler.Clear;
    for i := 0 to RangesCount - 1 do
      if FRangesRecs^[i].Ptgs <> nil then FreeMem(FRangesRecs^[i].Ptgs);
    FreeMem(FRangesRecs);
    FRangesRecs := nil;
    FreeMem(FSheetsRecs);
    FSheetsRecs := nil;
    FreeMem(FImagesRecs);
    FImagesRecs := nil;
  end;
end;

procedure TwawExcelWriter.Save(WorkBook: TwawXLSWorkbook; FileName: string);
var
  hr: HRESULT;
  buf: PWideChar;
  Stream: IStream;
  OleStream: TOleStream;
  RootStorage: IStorage;
begin
  buf := StringToOleStr(FileName);
  try
    hr := StgCreateDocFile(buf,
      STGM_CREATE or STGM_READWRITE or STGM_DIRECT or STGM_SHARE_EXCLUSIVE,
      0, RootStorage)
  finally
    SysFreeString(buf);
  end;
  if hr <> S_OK then
  begin
    OleCheck(hr);
    Exit;
  end;
  hr := RootStorage.CreateStream('Workbook',
    STGM_CREATE or STGM_READWRITE or STGM_DIRECT or STGM_SHARE_EXCLUSIVE,
    0, 0, Stream);
  if hr <> S_OK then
  begin
    OleCheck(hr);
    Exit;
  end;
// Create the OleStream.
  OleStream := TOleStream.Create(Stream);
  try
  // Save the memo's text to the OleStream.
    SaveAsBIFFToStream(WorkBook, OleStream);
  finally
  // Release the OleStream stream.
    OleStream.Free;
  end;
end;

end.

