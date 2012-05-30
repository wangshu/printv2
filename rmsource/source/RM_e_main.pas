
{******************************************************}
{                                                      }
{          Report Machine v3.0                         }
{           main export filter                         }
{                                                      }
{         write by whf and jim_waw(jim_waw@163.com)    }
{******************************************************}

unit RM_e_main;

interface

{$I RM.INC}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, Dialogs, StdCtrls,
  Controls, Comctrls, Math, RM_Common, RM_Class
{$IFDEF RXGIF}, JvGif{$ENDIF}
{$IFDEF JPEG}, JPEG{$ENDIF};

type
  TRMEFImageFormat = (ifGIF, ifJPG, ifBMP);
//  TRMObjType = (rmotMemo, rmotPicture);

  PRMEFTextRec = ^TRMEFTextRec;
  TRMEFTextRec = packed record
    Left, Top: Integer;
    Text: string;
    TextWidth: Integer;
    TextHeight: Integer;
  end;

  { TRMIEMCellStyle }
  TRMIEMCellStyle = class(TObject)
  private
    FFont: TFont;
    FHAlign: TRMHAlign;
    FVAlign: TRMVAlign;
    FFillColor: TColor;
    FLeftFrame: TRMFrameLine;
    FTopFrame: TRMFrameLine;
    FRightFrame: TRMFrameLine;
    FBottomFrame: TRMFrameLine;
    FDisplayFormat: TRMFormat;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function IsEqual(aSource: TRMIEMCellStyle): Boolean;

    property Font: TFont read FFont write FFont;
    property HAlign: TRMHAlign read FHAlign write FHAlign;
    property VAlign: TRMVAlign read FVAlign write FVAlign;
    property FillColor: TColor read FFillColor write FFillColor;
    property LeftFrame: TRMFrameLine read FLeftFrame write FLeftFrame;
    property TopFrame: TRMFrameLine read FTopFrame write FTopFrame;
    property RightFrame: TRMFrameLine read FRightFrame write FRightFrame;
    property BottomFrame: TRMFrameLine read FBottomFrame write FBottomFrame;
    property DisplayFormat: TRMFormat read FDisplayFormat write FDisplayFormat;
  end;

  { TRMIEMData }
  TRMIEMData = class(TObject)
  private
    FTextList: TList;
    FStartCol, FStartRow, FEndCol, FEndRow: Integer;
    FMemo: TWideStringList;
    FStyleIndex: Integer;
    FCounter: Integer;
    FExportAsNum: Boolean;

    function GetTextList: TList;
    procedure ClearTextList;
    function GetTextListCount: Integer;
    function GetMemo: TWideStringList;
    function GetGraphic: TGraphic;
  protected
    FGraphic: TGraphic;
  public
    Left, Top, Width, Height: Integer;
    Obj: TRMReportView;
    ObjType: TRMExportMode;
    BmpWidth: Integer;
    BmpHeight: Integer;
    TextWidth: Integer;
    ViewIndex: Integer;

    constructor Create;
    destructor Destroy; override;

    property TextList: TList read GetTextList;
    property TextListCount: Integer read GetTextListCount;
    property StartCol: Integer read FStartCol write FStartCol;
    property StartRow: Integer read FStartRow write FStartRow;
    property EndCol: Integer read FEndCol write FEndCol;
    property EndRow: Integer read FEndRow write FEndRow;
    property Memo: TWideStringList read GetMemo;
    property StyleIndex: Integer read FStyleIndex;
    property Graphic: TGraphic read GetGraphic;
    property Counter: Integer read FCounter write FCounter;
    property ExportAsNum: Boolean read FExportAsNum write FExportAsNum;
  end;

  { TRMIEMList }
  TRMIEMList = class(TObject)
  private
    FExportComp: TRMExportFilter;
    FTopOffset: Integer;
    FMaxHeight: Integer;
    FCols, FRows: TList;
    FCells: array of array of Integer;
    FObjList: TList;
    FStyleList: TList;
    FAryPageBreak: array of Integer;

    FExportPrecision: Integer;
    FDrawFrame: Boolean;
    FExportImage: Boolean;
    FExportRtf: Boolean;
    FExportHighQualityPicture: Boolean;

    procedure AddValue(aList: TList; aValue: Integer);

    function GetRowCount: Integer;
    function GetColCount: Integer;
    function GetRowHeight(aIndex: Integer): Integer;
    function GetColWidth(aIndex: Integer): Integer;
    function GetCell(aCol, aRow: Integer): TRMIEMData;
    function GetCellStyle(aCell: TRMIEMData): TRMIEMCellStyle;
    function GetPageBreak(Index: Integer): Integer;
  protected
  public
    constructor Create(aExportComponent: TRMExportFilter);
    destructor Destroy; override;

    procedure Clear(aClearStyle: Boolean);
    procedure AddObject(aReportView: TRMReportView);
    procedure EndPage;
    procedure Prepare;
    function GetCellRowPos(aIndex: Integer): Integer;
    function GetCellColPos(aIndex: Integer): Integer;

    property StyleList: TList read FStyleList;
    property RowCount: Integer read GetRowCount;
    property ColCount: Integer read GetColCount;
    property RowHeight[Index: Integer]: Integer read GetRowHeight;
    property ColWidth[Index: Integer]: Integer read GetColWidth;
    property Cells[Col, Row: Integer]: TRMIEMData read GetCell;
    property CellStyle[aCell: TRMIEMData]: TRMIEMCellStyle read GetCellStyle;
    property ExportPrecision: Integer read FExportPrecision write FExportPrecision;
    property PageBreak[Index: Integer]: Integer read GetPageBreak;

    property DrawFrame: Boolean read FDrawFrame write FDrawFrame;
    property ExportImage: Boolean read FExportImage write FExportImage;
    property ExportRtf: Boolean read FExportRtf write FExportRtf;
    property ExportHighQualityPicture: Boolean read FExportHighQualityPicture write FExportHighQualityPicture;
  end;

  TRMMainExportFilter = class;

  TBeforeSaveGraphicEvent = procedure(Sender: TRMMainExportFilter;
    AViewName: string; var UniqueImage: Boolean; var ReuseImageIndex: Integer;
    AAltText: string) of object;

  TAfterSaveGraphicEvent = procedure(Sender: TRMMainExportFilter;
    AViewName: string; ObjectImageIndex: Integer) of object;

 { TRMMainExportFilter }
  TRMMainExportFilter = class(TRMExportFilter)
  private
    FScaleX, FScaleY: Double;
    FExportFrames, FExportImages: Boolean;
{$IFDEF JPEG}
    FJPEGQuality: TJPEGQualityRange;
{$ENDIF}
    FViewNames: TStringList;
    FPixelFormat: TPixelFormat;
    FNowDataRec: TRMIEMData;
  protected
    CanMangeRotationText: Boolean;
    FDataList: TList;
    FPageNo: Integer;
    FPageWidth: Integer;
    FPageHeight: Integer;
    FExportImageFormat: TRMEFImageFormat;

    procedure SaveBitmapToPicture(aBmp: TBitmap; aImgFormat: TRMEFImageFormat
{$IFDEF JPEG}; aJPEGQuality: TJPEGQualityRange{$ENDIF}; var aPicture: TPicture);

    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnBeginPage; override;
    procedure OnEndPage; override;
    procedure OnExportPage(const aPage: TRMEndPage); override;
    procedure InternalOnePage(aPage: TRMEndPage); virtual;
    procedure OnText(aDrawRect: TRect; x, y: Integer; const aText: string; View: TRMView); override;
    procedure ClearDataList;
    property PixelFormat: TPixelFormat read FPixelFormat write FPixelFormat default pf24bit;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
    property ExportImages: Boolean read FExportImages write FExportImages default True;
    property ExportFrames: Boolean read FExportFrames write FExportFrames default True;
    property ExportImageFormat: TRMEFImageFormat read FExportImageFormat write FExportImageFormat;
{$IFDEF JPEG}
    property JPEGQuality: TJPEGQualityRange read FJPEGQuality write FJPEGQuality default High(TJPEGQualityRange);
{$ENDIF}
  end;

const
  ImageFormats: array[TRMEFImageFormat] of string = ('GIF', 'JPG', 'BMP');

function RMColorToHtmlColor(aColor: TColor): string;

implementation

uses RM_Utils;

type
  THackRMView = class(TRMReportView)
  end;

  THackMemoView = class(TRMCustomMemoView)
  end;

function RMColorToHtmlColor(aColor: TColor): string;
begin
  Result := IntToHex(ColorToRGB(AColor), 6);
  Result := '#' + Copy(Result, 5, 2) + Copy(Result, 3, 2) + Copy(Result, 1, 2);
end;

function RMGetTextSize(aFont: TFont; const aText: string): TSize;
var
  lDC: HDC;
  lSaveFont: HFont;
begin
  lDC := GetDC(0);
  lSaveFont := SelectObject(lDC, aFont.Handle);
  Result.cX := 0;
  Result.cY := 0;
  GetTextExtentPoint32(lDC, PChar(aText), Length(aText), Result);
  SelectObject(lDC, lSaveFont);
  ReleaseDC(0, lDC);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMIEMCellStyle }

constructor TRMIEMCellStyle.Create;
begin
  inherited;

  FFont := TFont.Create;
  FLeftFrame := TRMFrameLine.CreateComp(nil);
  FTopFrame := TRMFrameLine.CreateComp(nil);
  FRightFrame := TRMFrameLine.CreateComp(nil);
  FBottomFrame := TRMFrameLine.CreateComp(nil);
end;

destructor TRMIEMCellStyle.Destroy;
begin
  FFont.Free;
  FLeftFrame.Free;
  FTopFrame.Free;
  FRightFrame.Free;
  FBottomFrame.Free;

  inherited;
end;

function TRMIEMCellStyle.IsEqual(aSource: TRMIEMCellStyle): Boolean;
begin
  Result := (HAlign = aSource.HAlign) and (VAlign = aSource.VAlign) and
    (FillColor = aSource.FillColor) and
    (Font.Name = aSource.Font.Name) and (Font.Size = aSource.Font.Size) and
    (Font.Color = aSource.Font.Color) and (Font.Charset = aSource.Font.Charset) and
    (Font.Style = aSource.Font.Style) and
    LeftFrame.IsEqual(aSource.LeftFrame) and
    TopFrame.IsEqual(aSource.TopFrame) and
    RightFrame.IsEqual(aSource.RightFrame) and
    BottomFrame.IsEqual(aSource.BottomFrame) and
    (aSource.DisplayFormat.FormatIndex1 = DisplayFormat.FormatIndex1) and
    (aSource.DisplayFormat.FormatIndex2 = DisplayFormat.FormatIndex2) and
    (aSource.DisplayFormat.FormatPercent = DisplayFormat.FormatPercent) and
    (aSource.DisplayFormat.FormatdelimiterChar = DisplayFormat.FormatdelimiterChar);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMIEMData }

constructor TRMIEMData.Create;
begin
  inherited;

  FTextList := nil;
  FMemo := nil;
  FGraphic := nil;
  FCounter := 0;
end;

destructor TRMIEMData.Destroy;
begin
  ClearTextList;
  FreeAndNil(FTextList);
  FreeAndNil(FMemo);
  FreeAndNil(FGraphic);

  inherited;
end;

function TRMIEMData.GetGraphic: TGraphic;
begin
  if FGraphic = nil then
  begin
{$IFDEF JPEG}
    FGraphic := TJPEGImage.Create;
{$ELSE}
    FGraphic := TBitmap.Create;
{$ENDIF}
  end;

  Result := FGraphic;
end;

function TRMIEMData.GetMemo: TWideStringList;
begin
  if FMemo = nil then
    FMemo := TWideStringList.Create;

  Result := FMemo;
end;

function TRMIEMData.GetTextList: TList;
begin
  if FTextList = nil then
    FTextList := TList.Create;

  Result := FTextList;
end;

function TRMIEMData.GetTextListCount: Integer;
begin
  if FTextList = nil then
    Result := 0
  else
    Result := FTextList.Count;
end;

procedure TRMIEMData.ClearTextList;
var
  i: Integer;
begin
  if FTextList = nil then Exit;

  for i := 0 to FTextList.Count - 1 do
  begin
    Dispose(pRMEFTextRec(FTextList[i]));
  end;

  FTextList.Clear;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMIEMList }

type
  TRMIEMValue = class(TObject)
  public
    Value: Integer;
  end;


constructor TRMIEMList.Create(aExportComponent: TRMExportFilter);
begin
  inherited Create;

  FExportComp := aExportComponent;
  FTopOffset := 0;
  FMaxHeight := 0;
  FExportPrecision := 1;
  FDrawFrame := True;
  FCols := TList.Create;
  FRows := TList.Create;
  FObjList := TList.Create;
  FStyleList := TList.Create;

  FExportImage := True;
  FExportRtf := False;
  FExportHighQualityPicture := False;
end;

destructor TRMIEMList.Destroy;
begin
  Clear(True);
  FCols.Free;
  FRows.Free;
  FObjList.Free;
  FStyleList.Free;

  inherited;
end;

procedure TRMIEMList.Clear(aClearStyle: Boolean);
var
  i: Integer;
begin
  FMaxHeight := 0;
  FTopOffset := 0;
  SetLength(FCells, 0);
  SetLength(FAryPageBreak, 0);

  for i := 0 to FCols.Count - 1 do
    TRMIEMValue(FCols[i]).Free;
  FCols.Clear;

  for i := 0 to FRows.Count - 1 do
    TRMIEMValue(FRows[i]).Free;
  FRows.Clear;

  for i := 0 to FObjList.Count - 1 do
    TRMIEMData(FObjList[i]).Free;
  FObjList.Clear;

  if aClearStyle then
  begin
    for i := 0 to FStyleList.Count - 1 do
      TRMIEMCellStyle(FStyleList[i]).Free;
    FStyleList.Clear;
  end;
end;

procedure TRMIEMList.AddValue(aList: TList; aValue: Integer);
var
  i: Integer;
  tmp: TRMIEMValue;
begin
  for i := 0 to aList.Count - 1 do
  begin
    if TRMIEMValue(aList[i]).Value = aValue then
      Exit;
  end;

  tmp := TRMIEMValue.Create;
  tmp.Value := aValue;
  aList.Add(tmp);
end;

procedure TRMIEMList.AddObject(aReportView: TRMReportView);
var
  lObj: TRMIEMData;

  procedure _AddStyle;
  var
    i: Integer;
    tmp, tmp1: TRMIEMCellStyle;
    lAddFlag: Boolean;
  begin
    lObj.FStyleIndex := -1;

    lAddFlag := True;
    tmp := TRMIEMCellStyle.Create;
    tmp.LeftFrame.Assign(aReportView.LeftFrame);
    tmp.TopFrame.Assign(aReportView.TopFrame);
    tmp.RightFrame.Assign(aReportView.RightFrame);
    tmp.BottomFrame.Assign(aReportView.BottomFrame);
    tmp.FillColor := aReportView.FillColor;
    if THackRMView(aReportView).GetExportMode = rmemText then
    begin
      tmp.HAlign := TRMCustomMemoView(aReportView).HAlign;
      tmp.VAlign := TRMCustomMemoView(aReportView).VAlign;
      tmp.Font.Assign(TRMCustomMemoView(aReportView).Font);
      tmp.DisplayFormat := THackMemoView(aReportView).FormatFlag;
    end;

    for i := 0 to FStyleList.Count - 1 do
    begin
      tmp1 := TRMIEMCellStyle(FStyleList[i]);
      if tmp1.IsEqual(tmp) then
      begin
        FreeAndNil(tmp);
        lObj.FStyleIndex := i;
        lAddFlag := False;
        Break;
      end;
    end;

    if lAddFlag then
    begin
      lObj.FStyleIndex := FStyleList.Add(tmp);
    end;
  end;

  procedure _GetExportPicture1;
  var
    lSaveOffsetLeft, lSaveOffsetTop: Integer;
    lSave1, lSave2, lSave3, lSave4: Boolean;
    lBitmap: TBitmap;
  begin
    lSaveOffsetLeft := THackRMView(aReportView).OffsetLeft;
    lSaveOffsetTop := THackRMView(aReportView).OffsetTop;
    lSave1 := THackRMView(aReportView).LeftFrame.Visible;
    lSave2 := THackRMView(aReportView).TopFrame.Visible;
    lSave3 := THackRMView(aReportView).RightFrame.Visible;
    lSave4 := THackRMView(aReportView).BottomFrame.Visible;
    lBitmap := TBitmap.Create;
    try
      lBitmap.Width := lObj.Width + 1;
      lBitmap.Height := lObj.Height + 1;
      if not DrawFrame then
      begin
        THackRMView(aReportView).LeftFrame.Visible := False;
        THackRMView(aReportView).TopFrame.Visible := False;
        THackRMView(aReportView).RightFrame.Visible := False;
        THackRMView(aReportView).BottomFrame.Visible := False;
      end;

      THackRMView(aReportView).OffsetLeft := 0;
      THackRMView(aReportView).OffsetTop := 0;
      aReportView.SetspBounds(0, 0, lObj.Width, lObj.Height);
      aReportView.Draw(lBitmap.Canvas);
      lObj.Graphic.Assign(lBitmap);
      lObj.ObjType := rmemPicture;
    finally
      THackRMView(aReportView).OffsetLeft := lSaveOffsetLeft;
      THackRMView(aReportView).OffsetTop := lSaveOffsetTop;
      THackRMView(aReportView).LeftFrame.Visible := lSave1;
      THackRMView(aReportView).TopFrame.Visible := lSave2;
      THackRMView(aReportView).RightFrame.Visible := lSave3;
      THackRMView(aReportView).BottomFrame.Visible := lSave4;
      lBitmap.Free;
    end;
  end;

  procedure _GetExportPicture;
  begin
    if ExportHighQualityPicture and (aReportView is TRMPictureView) then
    begin
      lObj.ObjType := rmemPicture;
      if (TRMPictureView(aReportView).Picture.Graphic <> nil) and
        (not TRMPictureView(aReportView).Picture.Graphic.Empty) then
      begin
        lObj.Graphic.Assign(TRMPictureView(aReportView).Picture.Graphic);
      end;
    end;

    if lObj.Graphic.Empty then
      _GetExportPicture1;
  end;

  procedure _GetExportRtf;
  begin
    lObj.ObjType := rmemRtf;
    lObj.Memo.Text := THackRMView(aReportView).GetExportData;
  end;

  procedure _GetExportText;
  var
    i: Integer;
    lStr: string;
  begin
    lObj.ObjType := rmemText;
    lObj.Memo.Assign(aReportView.Memo);
    lObj.ExportAsNum := THackMemoView(aReportView).ExportAsNumber;
    _AddStyle;

    if THackMemoView(aReportView).WordWrap then
    begin
      for i := 0 to lObj.Memo.Count - 1 do
      begin
        lStr := lObj.Memo[i];
        if (Length(lStr) > 0) and (lStr[1] = #1) then
        begin
          Delete(lStr, 1, 1);
          lObj.Memo[i] := lStr;
        end;
      end;

      if (lObj.Memo.Count > 1) and (lObj.Memo[lObj.Memo.Count - 1] = #1) then
        lObj.Memo.Delete(lObj.Memo.Count - 1);
    end;
  end;

begin
  lObj := TRMIEMData.Create;
  lObj.Left := aReportView.spLeft;
  lObj.Top := aReportView.spTop + FTopOffset;
  lObj.Width := aReportView.spWidth;
  lObj.Height := aReportView.spHeight;
  lObj.Obj := aReportView;
  case THackRMView(aReportView).GetExportMode of
    rmemText:
      begin
        _GetExportText;
      end;
    rmemRtf:
      begin
        _AddStyle;
        if FExportRtf then
          _GetExportRtf
        else
          _GetExportPicture;
      end;
    rmemPicture:
      begin
        _AddStyle;
        if ExportImage then
          _GetExportPicture;
      end;
  end;

  FMaxHeight := Max(FMaxHeight, lObj.Top + lObj.Height);
  AddValue(FCols, lObj.Left);
  AddValue(FCols, lObj.Left + lObj.Width);
  AddValue(FRows, lObj.Top);
  AddValue(FRows, lObj.Top + lObj.Height);
  FObjList.Add(lObj);
end;

procedure TRMIEMList.EndPage;
begin
  SetLength(FAryPageBreak, Length(FAryPageBreak) + 1);
  FTopOffset := FMaxHeight;
  FAryPageBreak[Length(FAryPageBreak) - 1] := FTopOffset;
  FMaxHeight := 0;
end;

function _ListSortProc(aItem1, aItem2: Pointer): Integer;
begin
  Result := TRMIEMValue(aItem1).Value - TRMIEMValue(aItem2).Value;
end;

procedure TRMIEMList.Prepare;

  procedure _SortList(aList: TList);
  var
    i, lCount: integer;
    lValue1, lValue2: Integer;
  begin
    lValue2 := 0;
    aList.Sort(_ListSortProc);
    for i := 0 to aList.Count - 1 do
    begin
      lValue1 := TRMIEMValue(aList[i]).Value;
      if lValue1 >= 0 then
        Break
      else
        lValue2 := Min(lValue2, lValue1);
    end;

    if lValue2 < 0 then
    begin
      for i := 0 to aList.Count - 1 do
      begin
        TRMIEMValue(aList[i]).Value := TRMIEMValue(aList[i]).Value + (-lValue2);
      end;
    end;

    if (aList.Count > 0) and (TRMIEMValue(aList[0]).Value = 0) then
    begin
      TRMIEMValue(aList[0]).Free;
      aList.Delete(0);
    end;

    lCount := aList.Count - 1;
    for i := lCount - 1 downto 0 do
    begin
      lValue1 := TRMIEMValue(aList[i + 1]).Value;
      lValue2 := TRMIEMValue(aList[i]).Value;
      if lValue1 - lValue2 <= FExportPrecision then
      begin
        TRMIEMValue(aList[i]).Free;
        aList.Delete(i);
      end;
    end;
  end;

  function _FindIndex(aList: TList; aPosition: Integer): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to aList.Count - 1 do
    begin
      if TRMIEMValue(aList[i]).Value > aPosition then
      begin
        Result := i;
        Exit;
      end;
    end;
  end;

  procedure _SortCells;
  var
    i, j, lIndex: Integer;
    lObj: TRMIEMData;
  begin
    _SortList(FCols);
    _SortList(FRows);
    for i := 0 to FObjList.Count - 1 do
    begin
      lObj := TRMIEMData(FObjList[i]);
      lObj.StartCol := -1;
      lObj.StartRow := -1;
      lObj.EndCol := -1;
      lObj.EndRow := -1;
      lIndex := _FindIndex(FCols, lObj.Left);
      if lIndex >= 0 then
      begin
        lObj.StartCol := lIndex + 1;
        lObj.EndCol := lObj.StartCol;
        for j := lIndex to FCols.Count - 1 do
        begin
          if TRMIEMValue(FCols[j]).Value >= lObj.Left + lObj.Width then
          begin
            lObj.EndCol := j + 1;
            Break;
          end;
        end;
      end;

      lIndex := _FindIndex(FRows, lObj.Top);
      if lIndex >= 0 then
      begin
        lObj.StartRow := lIndex + 1;
        lObj.EndRow := lObj.StartRow;
        for j := lIndex to FRows.Count - 1 do
        begin
          if TRMIEMValue(FRows[j]).Value >= lObj.Top + lObj.Height then
          begin
            lObj.EndRow := j + 1;
            Break;
          end;
        end;
      end;
    end;
  end;

  procedure _FillCells;
  var
    i, lCol, lRow: Integer;
    lObj: TRMIEMData;
    lRowCount, lColCount: Integer;
  begin
    lRowCount := RowCount;
    lColCount := ColCount;
    for i := 0 to FObjList.Count - 1 do
    begin
      lObj := TRMIEMData(FObjList[i]);
      if (lObj.StartCol < 1) or (lObj.StartRow < 1) or
        (lObj.EndCol > lColCount) or (lObj.EndRow > lRowCount) then
        Continue;

      for lCol := lObj.StartCol to lObj.EndCol do
      begin
        for lRow := lObj.StartRow to lObj.EndRow do
        begin
          FCells[lRow - 1, lCol - 1] := i;
        end;
      end;
    end;
  end;

  procedure _SetNewXY(aCol, aRow: Integer; var aCell: TRMIEMData);
  var
    lRow, lCol, i: Integer;
    lCell: TRMIEMData;
  begin
    for lCol := aCol + 1 to aCell.EndCol - 1 do
    begin
      lCell := Cells[lCol, aRow];
      if (lCell <> nil) and (lCell <> aCell) then
      begin
        aCell.EndCol := lCol;
        aCell.Width := 0;
        for i := aCell.StartCol to aCell.EndCol do
          aCell.Width := aCell.Width + ColWidth[i - 1];

        Break;
      end;
    end;

    for lRow := aRow + 1 to aCell.EndRow - 1 do
    begin
      lCell := Cells[aCol, lRow];
      if (lCell <> nil) and (lCell <> aCell) then
      begin
        aCell.EndRow := lRow;
        aCell.Height := 0;
        for i := aCell.StartRow to aCell.EndRow do
          aCell.Height := aCell.Height + RowHeight[i - 1];

        Break;
      end;
    end;
  end;

  procedure _SplitCells;
  var
    lRow, lCol: Integer;
    lCell: TRMIEMData;
  begin
    for lRow := 0 to RowCount - 1 do
    begin
      for lCol := 0 to ColCount - 1 do
      begin
        lCell := Cells[lCol, lRow];
        if (lCell = nil) or (lCell.FCounter > 0) then Continue;

        _SetNewXY(lCol, lRow, lCell);
        lCell.FCounter := 1;
      end;
    end;

    for lRow := 0 to RowCount - 1 do
    begin
      for lCol := 0 to ColCount - 1 do
      begin
        lCell := Cells[lCol, lRow];
        if lCell <> nil then
          lCell.FCounter := 0;
      end;
    end;
  end;

var
  lRow, lCol, lRowCount, lColCount: Integer;
begin
  _SortCells;
  lRowCount := RowCount;
  lColCount := ColCount;
  SetLength(FCells, lRowCount);
  for lRow := 0 to lRowCount - 1 do
  begin
    SetLength(FCells[lRow], lColCount);
    for lCol := 0 to lColCount - 1 do
      FCells[lRow, lCol] := -1;
  end;

  _FillCells;
  _SplitCells;
end;

function TRMIEMList.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function TRMIEMList.GetColCount: Integer;
begin
  Result := FCols.Count;
end;

function TRMIEMList.GetCellRowPos(aIndex: Integer): Integer;
begin
  Result := TRMIEMValue(FRows[aIndex]).Value;
end;

function TRMIEMList.GetCellColPos(aIndex: Integer): Integer;
begin
  Result := TRMIEMValue(FCols[aIndex]).Value;
end;

function TRMIEMList.GetRowHeight(aIndex: Integer): Integer;
begin
  if aIndex = 0 then
    Result := TRMIEMValue(FRows[aIndex]).Value
  else
    Result := TRMIEMValue(FRows[aIndex]).Value - TRMIEMValue(FRows[aIndex - 1]).Value;
end;

function TRMIEMList.GetColWidth(aIndex: Integer): Integer;
begin
  if aIndex = 0 then
    Result := TRMIEMValue(FCols[aIndex]).Value
  else
    Result := TRMIEMValue(FCols[aIndex]).Value - TRMIEMValue(FCols[aIndex - 1]).Value;
end;

function TRMIEMList.GetCell(aCol, aRow: Integer): TRMIEMData;
begin
  if FCells[aRow, aCol] >= 0 then
    Result := TRMIEMData(FObjList[FCells[aRow, aCol]])
  else
    Result := nil;
end;

function TRMIEMList.GetCellStyle(aCell: TRMIEMData): TRMIEMCellStyle;
begin
  if aCell.FStyleIndex >= 0 then
    Result := TRMIEMCellStyle(FStyleList[aCell.FStyleIndex])
  else
    Result := nil;
end;

function TRMIEMList.GetPageBreak(Index: Integer): Integer;
begin
  if Index < Length(FAryPageBreak) then
    Result := FAryPageBreak[Index]
  else
    Result := $FFFFFF;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMMainExportFilter}

constructor TRMMainExportFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScaleX := 1;
  FScaleY := 1;
  ShowDialog := True;
{$IFDEF JPEG}
  FJPEGQuality := High(TJPEGQualityRange);
  FExportImageFormat := ifJPG;
{$ELSE}
  FExportImageFormat := ifBMP;
{$ENDIF}

  FExportImages := True;
  FExportFrames := True;
  FPixelFormat := pf24bit;
end;

destructor TRMMainExportFilter.Destroy;
begin
  RMUnRegisterExportFilter(Self);
  inherited Destroy;
end;

procedure TRMMainExportFilter.OnBeginDoc;
begin
  FDataList := TList.Create;
  FViewNames := TStringList.Create;

  FPageNo := 0;
  FPageWidth := ParentReport.EndPages[0].PageWidth;
  FPageHeight := ParentReport.EndPages[0].PageHeight;
end;

procedure TRMMainExportFilter.OnEndDoc;
begin
  ClearDataList;
  FDataList.Free;
  FViewNames.Free;
end;

procedure TRMMainExportFilter.OnBeginPage;
begin
  ClearDataList;
end;

procedure TRMMainExportFilter.OnEndPage;
begin
  Inc(FPageNo);
end;

procedure TRMMainExportFilter.OnText(aDrawRect: TRect; x, y: Integer; const aText: string; View: TRMView);
var
  lTextRec: pRMEFTextRec;
begin
  New(lTextRec);
  lTextRec.Left := x;
  lTextRec.Top := y;
  lTextRec.Text := aText;
  lTextRec.TextWidth := RMGetTextSize(TRMCustomMemoView(FNowDataRec.Obj).Font, aText).cx;
  lTextRec.TextHeight := RMGetTextSize(TRMCustomMemoView(FNowDataRec.Obj).Font, aText).cy;
  FNowDataRec.TextList.Add(lTextRec);
end;

procedure TRMMainExportFilter.InternalOnePage(aPage: TRMEndPage);
begin
end;

procedure TRMMainExportFilter.OnExportPage(const aPage: TRMEndPage);
var
  i, lIndex: Integer;
  t: TRMReportView;
  lDataRec: TRMIEMData;
  lSaveOffsetLeft, lSaveOffsetTop: Integer;
  lIsMemoView: Boolean;
begin
  FPageWidth := Round(aPage.PrinterInfo.ScreenPageWidth * ScaleX);
  FPageHeight := Round(aPage.PrinterInfo.ScreenPageHeight * ScaleY);

  for i := 0 to aPage.Page.Objects.Count - 1 do
  begin
    t := aPage.Page.Objects[i];
    if t.IsBand or (t is TRMSubReportView) then Continue;

    lDataRec := TRMIEMData.Create;
    lDataRec.Obj := t;
    lDataRec.FGraphic := nil;
    lDataRec.ObjType := rmemText;

    lIndex := FViewNames.IndexOf(t.Name);
    if lIndex < 0 then
      lIndex := FViewNames.Add(t.Name);
    lDataRec.ViewIndex := lIndex;

    lDataRec.Left := Round(t.spLeft * ScaleX);
    lDataRec.Top := Round(t.spTop * ScaleY);
    lDataRec.Width := Round(t.spWidth * ScaleX);
    lDataRec.Height := Round(t.spHeight * ScaleY);

    lIsMemoView := (t.ClassName = TRMMemoView.ClassName) or (t.ClassName = TRMCalcMemoView.ClassName);
    lIsMemoView := lIsMemoView and (CanMangeRotationText or (THackMemoView(lDataRec.Obj).RotationType = rmrtNone));
    if lIsMemoView then
    begin
      lDataRec.Width := lDataRec.Width + 1;
      lDataRec.TextWidth := RMGetTextSize(TRMCustomMemoView(t).Font, t.Memo.Text).cx;

      lSaveOffsetLeft := THackRMView(t).OffsetLeft;
      lSaveOffsetTop := THackRMView(t).OffsetTop;
      THackRMView(t).OffsetLeft := 0;
      THackRMView(t).OffsetTop := 0;
      FNowDataRec := lDataRec;
      THackRMView(t).ExportData;
      THackRMView(t).OffsetLeft := lSaveOffsetLeft;
      THackRMView(t).OffsetTop := lSaveOffsetTop;
    end
    else
    begin
      lDataRec.ObjType := rmemPicture;
      if ExportImages then
      begin
        lDataRec.FGraphic := TBitmap.Create;
        TBitmap(lDataRec.FGraphic).PixelFormat := FPixelFormat;
        lDataRec.FGraphic.Width := Round(t.spWidth * ScaleX + 1);
        lDataRec.FGraphic.Height := Round(t.spHeight * ScaleY + 1);

        lSaveOffsetLeft := THackRMView(t).OffsetLeft;
        lSaveOffsetTop := THackRMView(t).OffsetTop;
        THackRMView(t).OffsetLeft := 0;
        THackRMView(t).OffsetTop := 0;
        t.SetspBounds(0, 0, lDataRec.FGraphic.Width - 1, lDataRec.FGraphic.Height - 1);
        t.Draw(TBitmap(lDataRec.FGraphic).Canvas);
        t.SetspBounds(t.spLeft, t.spTop, t.spWidth, t.spHeight);
        THackRMView(t).OffsetLeft := lSaveOffsetLeft;
        THackRMView(t).OffsetTop := lSaveOffsetTop;
      end;
    end;

    FDataList.Add(lDataRec);
  end;

  InternalOnePage(aPage);
end;

procedure TRMMainExportFilter.ClearDataList;
var
  i: Integer;
  p: TRMIEMData;
begin
  if FDataList = nil then Exit;

  for i := 0 to FDataList.Count - 1 do
  begin
    p := FdataList[i];
    if p.FGraphic <> nil then
      FreeAndNil(p.FGraphic); //by waw
    p.Free;
  end;
  FDataList.Clear;
end;

procedure TRMMainExportFilter.SaveBitmapToPicture(aBmp: TBitmap; aImgFormat: TRMEFImageFormat
{$IFDEF JPEG}; aJPEGQuality: TJPEGQualityRange{$ENDIF}; var aPicture: TPicture);
var
  lGraphic: TGraphic;

  procedure SaveJpgGif;
  begin
    try
      lGraphic.Assign(aBmp);
      aPicture.Assign(lGraphic);
    finally
      lGraphic.Free;
    end;
  end;

begin
  aBmp.PixelFormat := FPixelFormat;
  case aImgFormat of
    ifBMP:
      begin
        aPicture.Assign(aBmp);
      end;
    ifGIF:
      begin
{$IFDEF RXGIF}
        lGraphic := TJvGIFImage.Create;
        SaveJpgGif;
{$ELSE}
{$IFDEF JPEG}
        lGraphic := TJPEGImage.Create;
        SaveJpgGif;
{$ELSE}
        aPicture.Assign(aBmp);
{$ENDIF}
{$ENDIF}
      end;
    ifJPG:
      begin
{$IFDEF JPEG}
        lGraphic := TJPEGImage.Create;
        TJPEGImage(lGraphic).CompressionQuality := JPEGQuality;
        SaveJpgGif;
{$ELSE}
        aPicture.Assign(aBmp);
{$ENDIF}
      end;
  end;
end;

end.

