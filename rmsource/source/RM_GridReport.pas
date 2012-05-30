unit RM_GridReport;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, RM_Common, RM_Class, RM_Printer, RM_Grid, RM_Preview
  {$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type

  { TRMGridReportPage }
  TRMGridReportPage = class(TRMReportPage)
  private
    FAutoCreateName: Boolean;
    FAutoDeleteNoUseBand: Boolean;
    FGrid: TRMGridEx;
    FRowBands: TList;
    FInLoadSaveMode: Boolean;
    FFixed: TStringList;
    FObjectsList: TList;
    FUseHeaderFooter: Boolean;
    FPageHeaderMsg: TRMBandMsg;
    FPageFooterMsg: TRMBandMsg;
    FPageCaptionMsg: TRMPageCaptionMsg;
    FOnBeforeCreateObjects: TNotifyEvent;
    FOnAfterCreateObjects: TNotifyEvent;

	  procedure DeleteBand(aAryBandType: array of TRMBandType);
    function GetRowBandView(aIndex: Integer): TRMView;
    procedure SetRowBandView(aIndex: Integer; Value: TRMView);
    procedure SetUseHeaderFooter(Value: Boolean);

    procedure OnAfterInsertRow(aGrid: TRMGridEx; aRow: Integer);
    procedure OnAfterDeleteRow(aGrid: TRMGridEx; aRow: Integer);
    procedure OnAfterChangeRowCount(aGrid: TRMGridEx; aOldCount, aNewCount: Integer);
  protected
    procedure AddChildView(aStringList: TStringList; aDontAddBlankNameObject: Boolean); override;
    procedure BuildTmpObjects; override;
    procedure PreparePage; override;
    procedure UnPreparePage; override;
    procedure AfterLoaded; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  public
    constructor CreatePage(aParentReport: TRMReport; aSize, aWidth, aHeight, aBin: Integer; aOr: TRMPrinterOrientation); override;
    destructor Destroy; override;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant; Args: array of Variant): Boolean; override;
    function SetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean; override;
    function FindObject(aObjectName: string): TRMView; override;
    function PageObjects: TList; override;

    property RowBandViews[Index: Integer]: TRMView read GetRowBandView write SetRowBandView;
    property PageHeaderMsg: TRMBandMsg read FPageHeaderMsg write FPageHeaderMsg;
    property PageFooterMsg: TRMBandMsg read FPageFooterMsg write FPageFooterMsg;
    property PageCaptionMsg: TRMPageCaptionMsg read FPageCaptionMsg write FPageCaptionMsg;
    property Grid: TRMGridEx read FGrid;
  published
    property UseHeaderFooter: Boolean read FUseHeaderFooter write SetUseHeaderFooter;
    property AutoCreateName: Boolean read FAutoCreateName write FAutoCreateName;
    property AutoDeleteNoUseBand: Boolean read FAutoDeleteNoUseBand write FAutoDeleteNoUseBand;
    property OnBeforeCreateObjects: TNotifyEvent read FOnBeforeCreateObjects write FOnBeforeCreateObjects;
    property OnAfterCreateObjects: TNotifyEvent read FOnAfterCreateObjects write FOnAfterCreateObjects;
  end;

  { TRMGridReport }
  TRMGridReport = class(TRMReport)
  private
  protected
  public
    class function DefaultPageClassName: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ReportClassType: Byte; override;
    function ReportCommon: string; override;
    function CreatePage(const aClassName: string): TRMCustomPage; override;
    function AddGridReportPage: TRMGridReportPage;
    function AddReportPage: TRMGridReportPage;
  end;

implementation

uses
  Math, RM_Const, RM_Const1, RM_Utils
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvInterpreter_Types
{$ELSE}
  , JvInterpreter_Types
{$ENDIF};

type
  THackReport = class(TRMReport)
  end;

  THackReportView = class(TRMReportView)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMGridReportPage }

constructor TRMGridReportPage.CreatePage(aParentReport: TRMReport;
  aSize, aWidth, aHeight, aBin: Integer; aOr: TRMPrinterOrientation);
begin
  inherited;

  FRowBands := TList.Create;
  FFixed := nil;
  FObjectsList := nil;

  FInLoadSaveMode := True;
  FGrid := TRMGridEx.Create(nil);
  FGrid.ParentReport := aParentReport;
  FGrid.ParentPage := Self;
  FGrid.OnAfterInsertRow := OnAfterInsertRow;
  FGrid.OnAfterDeleteRow := OnAfterDeleteRow;
  FGrid.OnAfterChangeRowCount := OnAfterCHangeRowCount;
  FGrid.DefaultRowHeight := 24;
  FGrid.ColWidths[0] := 13;
  FGrid.RowHeights[0] := 14;
  FInLoadSaveMode := False;

  OnAfterChangeRowCount(FGrid, FGrid.RowCount, FGrid.RowCount);

  FAutoCreateName := True;
  FAutoDeleteNoUseBand := True;
  FUseHeaderFooter := False;
  FPageHeaderMsg := TRMBandMsg.Create;
  FPageFooterMsg := TRMBandMsg.Create;
  FPageCaptionMsg := TRMPageCaptionMsg.Create;
end;

destructor TRMGridReportPage.Destroy;
begin
  FreeAndNil(FFixed);
  FreeAndNil(FObjectsList);
  FreeAndNil(FGrid);
  FreeAndNil(FRowBands);

  FreeAndNil(FPageHeaderMsg);
  FreeAndNil(FPageFooterMsg);
  FreeAndNil(FPageCaptionMsg);
  inherited Destroy;
end;

function TRMGridReportPage.GetPropValue(aObject: TObject; aPropName: string;
	var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if (aPropName = 'GRID') or (aPropName = 'GRIDEX') then
    aValue := O2V(FGrid)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

function TRMGridReportPage.SetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean;
begin
  //  Result := True;
  Result := inherited SetPropValue(aObject, aPropName, aValue);
end;

function TRMGridReportPage.PageObjects: TList;
var
  i, j: Integer;
  lCell: TRMCellInfo;
begin
  if FObjectsList = nil then
    FObjectsList := TList.Create;

  FObjectsList.Clear;
  for i := 0 to Objects.Count - 1 do
    FObjectsList.Add(Objects[i]);

  for i := 1 to FGrid.RowCount - 1 do
  begin
    j := 1;
    while j < FGrid.ColCount do
    begin
      lCell := FGrid.Cells[j, i];
      if lCell.StartRow = i then
        FObjectsList.Add(lCell.View);
      j := lCell.EndCol + 1;
    end;
  end;

  Result := FObjectsList;
end;

function TRMGridReportPage.FindObject(aObjectName: string): TRMView;
var
  i, j: Integer;
  liCell: TRMCellInfo;
begin
  Result := inherited FindObject(aObjectName);
  if Result = nil then
  begin
    for i := 1 to FGrid.RowCount - 1 do
    begin
      j := 1;
      while j < FGrid.ColCount do
      begin
        liCell := FGrid.Cells[j, i];
        if liCell.StartRow = i then
        begin
          if AnsiCompareText(liCell.View.Name, aObjectName) = 0 then
          begin
            Result := liCell.View;
            Exit;
          end;
        end;
        j := liCell.EndCol + 1;
      end;
    end;
  end;
end;

  procedure TRMGridReportPage.DeleteBand(aAryBandType: array of TRMBandType);
  var
    i, j: Integer;
  begin
    for i := 0 to FRowBands.Count - 1 do
    begin
      if FRowBands[i] <> nil then
      begin
				for j := Low(aAryBandType) to High(aAryBandType) do
        begin
        	if TRMBand(FRowBands[i]).BandType = aAryBandType[j] then
          begin
		        Self.Delete(Self.IndexOf(TRMBand(FRowBands[i]).Name));
    		    RowBandViews[i] := nil;
            Break;
          end;
        end;
      end;
    end;
  end;

procedure TRMGridReportPage.SetUseHeaderFooter(Value: Boolean);
begin
  if FUseHeaderFooter = Value then Exit;

  FUseHeaderFooter := Value;
  if FUseHeaderFooter then
  begin
    DeleteBand([rmbtPageHeader, rmbtPageFooter]);
  end;
end;

function TRMGridReportPage.GetRowBandView(aIndex: Integer): TRMView;
begin
  Result := FRowBands[aIndex];
end;

procedure TRMGridReportPage.SetRowBandView(aIndex: Integer; Value: TRMView);
begin
  FRowBands[aIndex] := Value;
end;

procedure TRMGridReportPage.OnAfterInsertRow(aGrid: TRMGridEx; aRow: Integer);
begin
  if FInLoadSaveMode then Exit;

  FRowBands.Insert(aRow, FRowBands[aRow]);
end;

procedure TRMGridReportPage.OnAfterDeleteRow(aGrid: TRMGridEx; aRow: Integer);
begin
  if FInLoadSaveMode then Exit;

  FRowBands.Delete(aRow);
end;

procedure TRMGridReportPage.OnAfterChangeRowCount(aGrid: TRMGridEx; aOldCount, aNewCount: Integer);
var
  liOldCount: Integer;
begin
  if FInLoadSaveMode or (FRowBands.Count = aNewCount) then Exit;

  liOldCount := FRowBands.Count;
  if liOldCount > aNewCount then
  begin
    while FRowBands.Count > aNewCount do
      FRowBands.Delete(FRowBands.Count - 1);
  end
  else
  begin
    while FRowBands.Count < aNewCount do
      FRowBands.Add(nil);
  end;
end;

procedure TRMGridReportPage.BuildTmpObjects;
var
  i, j: Integer;
  lCell: TRMCellInfo;
  lTopOffset: Integer;

  procedure _DeleteNoUseBand(aDeleteFlag: Boolean);
	var
  	i: Integer;
    t: TRMView;
  begin
    if not FAutoDeleteNoUseBand then Exit;
    
  	for i := Objects.Count - 1 downto 0 do
    begin
    	t := Objects[i];
      if t.IsBand then
      begin
      	if aDeleteFlag then
        begin
        	if t.spTop < 0 then
          begin
          	t.Free;
            Objects.Delete(i);
          end;
        end
        else
        	t.spTop := - 1;
      end;
    end;
  end;

  function _TextWidth(aMemo: TStringList; aFont: TFont): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to aMemo.Count - 1 do
    begin
      Result := Max(Result, RMCanvasWidth(aMemo[i], aFont) + 4);
    end;
  end;

  function _TextHeight(aMemo: TStringList; aFont: TFont): Integer;
  begin
    Result := aMemo.Count * (RMCanvasHeight('1234', aFont) + 2);
    if Result > 0 then
      Result := Result + 4 + 6;
  end;

  procedure _CreateHeaderFooterBand;
  var
    t: TRMMemoView;
    lBand: TRMView;
    lPageWidth, lHeight, lSaveTopOffset: Integer;

    procedure _CreateOneBand(aBandMsg: TRMBandMsg; aBandType: TRMBandType);
    var
      t: TRMMemoView;
      lLeftWidth, lRightWidth, lHeight: Integer;
    begin
      if (aBandMsg.LeftMemo.Count > 0) or (aBandMsg.CenterMemo.Count > 0) or
        (aBandMsg.RightMemo.Count > 0) then
      begin
        lLeftWidth := _TextWidth(aBandMsg.LeftMemo, aBandMsg.Font);
        lRightWidth := _TextWidth(aBandMsg.RightMemo, aBandMsg.Font);
        lLeftWidth := Max(lLeftWidth, lRightWidth);
        lHeight := _TextHeight(aBandMsg.LeftMemo, aBandMsg.Font);
        lHeight := Max(lHeight, _TextHeight(aBandMsg.CenterMemo, aBandMsg.Font));
        lHeight := Max(lHeight, _TextHeight(aBandMsg.RightMemo, aBandMsg.Font));

        if lBand = nil then
        begin
          lBand := RMCreateBand(aBandType);
          lBand.ParentPage := Self;
          lBand.spTop := lTopOffset;
          lBand.spHeight := lHeight;
        end
        else
          lBand.spHeight := lBand.spHeight + lHeight;

        t := TRMMemoView.Create; // 左
        t.ParentPage := Self;
        t.SetspBounds(0, lTopOffset, lLeftWidth, lHeight);
        t.Font.Assign(aBandMsg.Font);
        t.Memo.Assign(aBandMsg.LeftMemo);
        t.LeftFrame.Visible := False;
        t.RightFrame.Visible := False;
        t.TopFrame.Visible := False;
        t.BottomFrame.Visible := False;
        t.HAlign := rmHLeft;
        t.VAlign := rmVCenter;

        t := TRMMemoView.Create; // 中
        t.ParentPage := Self;
        t.SetspBounds(lLeftWidth, lTopOffset, lPageWidth - lLeftWidth * 2, lHeight);
        t.Font.Assign(aBandMsg.Font);
        t.Memo.Assign(aBandMsg.CenterMemo);
        t.LeftFrame.Visible := False;
        t.RightFrame.Visible := False;
        t.TopFrame.Visible := False;
        t.BottomFrame.Visible := False;
        t.HAlign := rmHCenter;
        t.VAlign := rmVCenter;

        t := TRMMemoView.Create; // 右
        t.ParentPage := Self;
        t.SetspBounds(lPageWidth - lLeftWidth, lTopOffset, lLeftWidth, lHeight);
        t.Font.Assign(aBandMsg.Font);
        t.Memo.Assign(aBandMsg.RightMemo);
        t.LeftFrame.Visible := False;
        t.RightFrame.Visible := False;
        t.TopFrame.Visible := False;
        t.BottomFrame.Visible := False;
        t.HAlign := rmHRight;
        t.VAlign := rmVCenter;
      end;
    end;

  begin
    lPageWidth := Self.PrinterInfo.ScreenPageWidth - Self.spMarginLeft - Self.spMarginRight;
    lBand := nil;
    lSaveTopOffset := lTopOffset;
    _CreateOneBand(FPageHeaderMsg, rmbtPageHeader);
    if lBand <> nil then
      lTopOffset := lBand.spTop + lBand.spHeight;

    if FPageCaptionMsg.TitleMemo.Count > 0 then
    begin
      lHeight := _TextHeight(FPageCaptionMsg.TitleMemo, FPageCaptionMsg.TitleFont);
      if lBand = nil then
      begin
        lBand := RMCreateBand(rmbtPageHeader);
        lBand.ParentPage := Self;
        lBand.spTop := lTopOffset;
        lBand.spHeight := lHeight;
      end
      else
        lBand.spHeight := lBand.spHeight + lHeight;

      t := TRMMemoView.Create;
      t.ParentPage := Self;
      t.SetspBounds(0, lTopOffset, lPageWidth, lHeight);
      t.Font.Assign(FPageCaptionMsg.TitleFont);
      t.Memo.Assign(FPageCaptionMsg.TitleMemo);
      t.LeftFrame.Visible := False;
      t.RightFrame.Visible := False;
      t.TopFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.HAlign := rmHCenter;
      t.VAlign := rmVCenter;

      lTopOffset := lTopOffset + lHeight;
    end;

    _CreateOneBand(FPageCaptionMsg.CaptionMsg, rmbtPageHeader);
    lTopOffset := lSaveTopOffset;
    if lBand <> nil then
      lTopOffset := lBand.spTop + lBand.spHeight;

    lBand := nil;
    _CreateOneBand(FPageFooterMsg, rmbtPageFooter);
    if lBand <> nil then
      lTopOffset := lBand.spTop + lBand.spHeight;
  end;

  procedure _SetBands; // 设置各个Band的位置信息
  var
    i, j: Integer;
    t: TRMReportView;
  begin
    t := TRMReportView(RowBandViews[1]);
    if t <> nil then
    begin
      t.spTop := 0 + lTopOffset;
      t.spHeight := FGrid.RowHeights[1] + 1;
    end;

    for i := 2 to FGrid.RowCount - 1 do
    begin
      if RowBandViews[i] = t then
      begin
        if t <> nil then
          t.spHeight := t.spHeight + FGrid.RowHeights[i] + 1;
      end
      else
      begin
        t := TRMReportView(RowBandViews[i]);
        if t <> nil then
        begin
          t.spTop := 0 + lTopOffset;
          for j := 1 to i - 1 do
            t.spTop := t.spTop + FGrid.RowHeights[j] + 1;
          t.spHeight := FGrid.RowHeights[i] + 1;
        end;
      end;
    end;
  end;

  procedure _SetCellInfo;
  var
    t, t1: TRMReportView;
    i: Integer;
    lSize: Integer;
  begin
    t := TRMReportView(RMCreateObject(lCell.View.ObjectType, lCell.View.ClassName));
    t.NeedCreateName := False;
    t.ParentPage := Self;
    t.Assign(lCell.View);

    lSize := 0;
    for i := 1 to lCell.StartCol - 1 do
      lSize := lSize + FGrid.ColWidths[i] + 1;
    t.spLeft := lSize;

    lSize := 0;
    for i := lCell.StartCol to lCell.EndCol do
      lSize := lSize + FGrid.ColWidths[i] + 1;
    t.spWidth := lSize;

    lSize := 0;
    for i := 1 to lCell.StartRow - 1 do
      lSize := lSize + FGrid.RowHeights[i] + 1;
    t.spTop := lSize + lTopOffset;

    lSize := 0;
    for i := lCell.StartRow to lCell.EndRow do
      lSize := lSize + FGrid.RowHeights[i] + 1;

    t.spHeight := lSize;
    if lCell.FillColor = FGrid.Color then
      t.FillColor := clNone
    else
      t.FillColor := lCell.FillColor;

    if t is TRMMemoView then
    begin
      TRMMemoView(t).Font.Assign(lCell.Font);
      TRMMemoView(t).HAlign := lCell.HAlign;
      TRMMemoView(t).VAlign := lCell.VAlign;
    end;

    THackReportView(t).BandAlign := rmbaNone;
    if (t is TRMSubReportView) and
    	(t.LeftFrame.Visible or t.RightFrame.Visible or t.TopFrame.Visible or
      	t.BottomFrame.Visible) then
		begin
	    t1 := TRMReportView(RMCreateObject(rmgtMemo, ''));
  	  t1.NeedCreateName := False;
    	t1.ParentPage := Self;
			t1.mmLeft := t.mmLeft;
      t1.mmTop := t.mmTop;
      t1.mmWidth := t.mmWidth;
      t1.mmHeight := t.mmHeight;
      t1.LeftFrame.Assign(t.LeftFrame);
      t1.RightFrame.Assign(t.RightFrame);
      t1.TopFrame.Assign(t.TopFrame);
      t1.BottomFrame.Assign(t.BottomFrame);
    end;
  end;

begin
  SetObjectEvent(EventList, THackReport(ParentReport.MasterReport).FScriptEngine);

  FGrid.AutoCreateName := AutoCreateName;
	if Assigned(FOnBeforeCreateObjects) then
  	FOnBeforeCreateObjects(Self);

  lTopOffset := 0;
  _DeleteNoUseBand(False);
  if FUseHeaderFooter then
  begin
    DeleteBand([rmbtPageHeader, rmbtPageFooter]);
    _CreateHeaderFooterBand;
  end;

  //lTopOffset := RMToMMThousandths(lTopOffset, rmutScreenPixels);
  _SetBands;
  for i := 1 to FGrid.RowCount - 1 do
  begin
    j := 1;
    while j < FGrid.ColCount do
    begin
      lCell := FGrid.Cells[j, i];
      if lCell.StartRow = i then
      begin
        _SetCellInfo;
      end;
      j := lCell.EndCol + 1;
    end;
  end;

  _DeleteNoUseBand(True);
  SetObjectsEvent;
	if Assigned(FOnAfterCreateObjects) then
  	FOnAfterCreateObjects(Self);
end;

procedure TRMGridReportPage.PreparePage;
begin
  inherited PreparePage;
end;

procedure TRMGridReportPage.UnPreparePage;
begin
  inherited UnPreparePage;
end;

procedure TRMGridReportPage.AddChildView(aStringList: TStringList; aDontAddBlankNameObject: Boolean);
var
  i, j: Integer;
  lCell: TRMCellInfo;
begin
  inherited AddChildView(aStringList, aDontAddBlankNameObject);
  for i := 1 to FGrid.RowCount - 1 do
  begin
    j := 1;
    while j < FGrid.ColCount do
    begin
      lCell := FGrid.Cells[j, i];
      if lCell.StartRow = i then
      begin
        if not (aDontAddBlankNameObject and (lCell.View.Name = '')) then
          aStringList.Add(UpperCase(lCell.View.Name));
      end;
      j := lCell.EndCol + 1;
    end;
  end;
end;

procedure TRMGridReportPage.AfterLoaded;
var
  i: Integer;
  t: TRMView;
begin
  for i := 0 to FGrid.RowCount - 1 do
    RowBandViews[i] := nil;

  if FFixed = nil then Exit;

  for i := 0 to FFixed.Count - 1 do
  begin
    if FFixed[i] <> '' then
    begin
      t := FindObject(FFixed[i]);
      RowBandViews[i + 1] := t;
    end;
  end;
  FreeAndNil(FFixed);
end;

procedure TRMGridReportPage.LoadFromStream(aStream: TStream);
var
  i: Integer;
  lVersion: Word;

  procedure _ReadBandMsg(aBandMsg: TRMBandMsg);
  begin
    RMReadFont(aStream, aBandMsg.Font);
    RMReadMemo(aStream, aBandMsg.LeftMemo);
    RMReadMemo(aStream, aBandMsg.CenterMemo);
    RMReadMemo(aStream, aBandMsg.RightMemo);
  end;

begin
  FAutoDeleteNoUseBand := False;
  FGrid.AutoCreateName := AutoCreateName;
  FInLoadSaveMode := True;
  inherited LoadFromStream(aStream);
  lVersion := RMReadWord(aStream);
  FGrid.LoadFromStream(aStream);

  if FFixed = nil then
    FFixed := TStringList.Create;
  FFixed.Clear;
  for i := 1 to FGrid.RowCount - 1 do
  begin
    FFixed.Add(RMReadString(aStream));
  end;

  FUseHeaderFooter := False;
  if lVersion >= 1 then
  begin
    FUseHeaderFooter := RMReadBoolean(aStream);
    _ReadBandMsg(FPageHeaderMsg);
    _ReadBandMsg(FPageFooterMsg);
    RMReadFont(aStream, FPageCaptionMsg.TitleFont);
    RMReadMemo(aStream, FPageCaptionMsg.TitleMemo);
    _ReadBandMsg(FPageCaptionMsg.CaptionMsg);
  end;
  if lVersion >= 2 then
  begin
    FAutoCreateName := RMReadBoolean(aStream);
  end;
  if lVersion >= 3 then
  begin
    FAutoDeleteNoUseBand := RMReadBoolean(aStream);
  end;

  FInLoadSaveMode := False;
  OnAfterChangeRowCount(FGrid, FGrid.RowCount, FGrid.RowCount);
end;

procedure TRMGridReportPage.SaveToStream(aStream: TStream);
var
  i: Integer;
  t: TRMView;

  procedure _WriteBandMsg(aBandMsg: TRMBandMsg);
  begin
    RMWriteFont(aStream, aBandMsg.Font);
    RMWriteMemo(aStream, aBandMsg.LeftMemo);
    RMWriteMemo(aStream, aBandMsg.CenterMemo);
    RMWriteMemo(aStream, aBandMsg.RightMemo);
  end;

begin
  FInLoadSaveMode := True;
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 3);
  FGrid.SaveToStream(aStream);
  for i := 1 to FGrid.RowCount - 1 do
  begin
    t := RowBandViews[i];
    if t <> nil then
      RMWriteString(aStream, t.Name)
    else
      RMWriteString(aStream, '');
  end;

  RMWriteBoolean(aStream, FUseHeaderFooter);
  _WriteBandMsg(FPageHeaderMsg);
  _WriteBandMsg(FPageFooterMsg);
  RMWriteFont(aStream, FPageCaptionMsg.TitleFont);
  RMWriteMemo(aStream, FPageCaptionMsg.TitleMemo);
  _WriteBandMsg(FPageCaptionMsg.CaptionMsg);
  RMWriteBoolean(aStream, FAutoCreateName);
  RMWriteBoolean(aStream, FAutoDeleteNoUseBand);

  FInLoadSaveMode := False;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMGridReport }

class function TRMGridReport.DefaultPageClassName: string;
begin
  Result := 'TRMGridReportPage';
end;

constructor TRMGridReport.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
//  CanPreviewDesign := False;
end;

destructor TRMGridReport.Destroy;
begin
  inherited Destroy;
end;

function TRMGridReport.ReportClassType: Byte;
begin
  Result := 2;
end;

function TRMGridReport.ReportCommon: string;
begin
  Result := 'GridReport';
end;

function TRMGridReport.CreatePage(const aClassName: string): TRMCustomPage;
begin
  if AnsiCompareText(aClassName, 'TRMGridReportPage') = 0 then
  begin
    with ReportPrinter do
      Result := TRMGridReportPage.CreatePage(Self, DefaultPaper, DefaultPaperWidth, DefaultPaperHeight, $FFFF, rmpoPortrait);
  end
  else
    Result := inherited CreatePage(aClassName);
end;

function TRMGridReport.AddGridReportPage: TRMGridReportPage;
begin
  with ReportPrinter do
    Result := TRMGridReportPage.CreatePage(Self, DefaultPaper, DefaultPaperWidth,
    	DefaultPaperHeight, $FFFF, rmpoPortrait);
      
  Pages.PagesList.Add(Result);
end;

function TRMGridReport.AddReportPage: TRMGridReportPage;
begin
	Result := AddGridReportPage;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMGridEx_Read_Cells(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridEx(Args.Obj).Cells[Args.Values[0], Args.Values[1]]);
end;

procedure TRMGridEx_Write_Cells(const Value: Variant; Args: TJvInterpreterArgs);
begin
end;

procedure TRMGridEx_Read_ColWidths(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMGridEx(Args.Obj).ColWidths[Args.Values[0]];
end;

procedure TRMGridEx_Write_ColWidths(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).ColWidths[Args.Values[0]] := Value;
end;

procedure TRMGridEx_Read_RowHeights(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMGridEx(Args.Obj).RowHeights[Args.Values[0]];
end;

procedure TRMGridEx_Write_RowHeights(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).RowHeights[Args.Values[0]] := Value;
end;

procedure TRMGridEx_CreateViewsName(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).CreateViewsName;
end;

procedure TRMGridEx_GetCellInfo(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridEx(Args.Obj).GetCellInfo(Args.Values[0], Args.Values[1]));
end;

procedure TRMGridEx_MergeCell(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).MergeCell(Args.Values[0], Args.Values[1], Args.Values[2], Args.Values[3]);
end;

procedure TRMGridEx_SplitCell(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).SplitCell(Args.Values[0], Args.Values[1], Args.Values[2], Args.Values[3]);
end;

procedure TRMGridEx_GetCellRect(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := Rect2Var(TRMGridEx(Args.Obj).GetCellRect(TRMCellInfo(V2O(Args.Values[0]))));
end;

procedure TRMGridEx_InsertColumn(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).InsertColumn(Args.Values[0], Args.Values[1]);
end;

procedure TRMGridEx_InsertRow(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).InsertRow(Args.Values[0], Args.Values[1]);
end;

procedure TRMGridEx_DeleteColumn(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).DeleteColumn(Args.Values[0], Args.Values[1]);
end;

procedure TRMGridEx_DeleteRow(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridEx(Args.Obj).DeleteRow(Args.Values[0], Args.Values[1]);
end;

procedure TRMGridReportPage_Read_RowBandViews(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridReportPage(Args.Obj).RowBandViews[Args.Values[0]]);
end;

procedure TRMGridReportPage_Write_RowBandViews(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMGridReportPage(Args.Obj).RowBandViews[Args.Values[0]] := TRMView(V2O(Value));
end;

procedure TRMGridReportPage_PageHeaderMsg(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridReportPage(Args.Obj).PageHeaderMsg);
end;

procedure TRMGridReportPage_PageFooterMsg(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridReportPage(Args.Obj).PageFooterMsg);
end;

procedure TRMGridReportPage_PageCaptionMsg(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMGridReportPage(Args.Obj).PageCaptionMsg);
end;

const
  cReportMachine = 'RM_GridReport';
  cRM_Grid = 'RM_Grid';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cRM_Grid, TRMGridEx, 'TRMGridEx');
    AddClass(cRM_Grid, TRMBandMsg, 'TRMBandMsg');
    AddClass(cRM_Grid, TRMPageCaptionMsg, 'TRMPageCaptionMsg');

    { TRMGridEx }
    AddIGet(TRMGridEx, 'Cells', TRMGridEx_Read_Cells, 2, [0], varEmpty);
    AddIDGet(TRMGridEx, TRMGridEx_Read_Cells, 2, [0], varEmpty);
    AddISet(TRMGridEx, 'Cells', TRMGridEx_Write_Cells, 2, [1]);
    AddIDSet(TRMGridEx, TRMGridEx_Write_Cells, 2, [1]);
    AddIGet(TRMGridEx, 'ColWidths', TRMGridEx_Read_ColWidths, 1, [0], varEmpty);
    AddISet(TRMGridEx, 'ColWidths', TRMGridEx_Write_ColWidths, 1, [1]);
    AddIGet(TRMGridEx, 'RowHeights', TRMGridEx_Read_RowHeights, 1, [0], varEmpty);
    AddISet(TRMGridEx, 'RowHeights', TRMGridEx_Write_RowHeights, 1, [1]);

    AddGet(TRMGridEx, 'CreateViewsName', TRMGridEx_CreateViewsName, 0, [0], varEmpty);
    AddGet(TRMGridEx, 'GetCellInfo', TRMGridEx_GetCellInfo, 2, [0], varEmpty);
    AddGet(TRMGridEx, 'MergeCell', TRMGridEx_MergeCell, 4, [0], varEmpty);
    AddGet(TRMGridEx, 'SplitCell', TRMGridEx_SplitCell, 4, [0], varEmpty);
    AddGet(TRMGridEx, 'GetCellRect', TRMGridEx_GetCellRect, 1, [0], varEmpty);
    AddGet(TRMGridEx, 'InsertColumn', TRMGridEx_InsertColumn, 2, [0], varEmpty);
    AddGet(TRMGridEx, 'InsertRow', TRMGridEx_InsertRow, 2, [0], varEmpty);
    AddGet(TRMGridEx, 'DeleteColumn', TRMGridEx_DeleteColumn, 2, [0], varEmpty);
    AddGet(TRMGridEx, 'DeleteRow', TRMGridEx_DeleteRow, 2, [0], varEmpty);

    { TRMGridReportPage }
    AddClass(cReportMachine, TRMGridReportPage, 'TRMGridReportPage');
    AddIGet(TRMGridReportPage, 'RowBandViews', TRMGridReportPage_Read_RowBandViews, 1, [0], varEmpty);
    AddISet(TRMGridReportPage, 'RowBandViews', TRMGridReportPage_Write_RowBandViews, 1, [1]);
    AddGet(TRMGridReportPage, 'PageHeaderMsg', TRMGridReportPage_PageHeaderMsg, 0, [0], varEmpty);
    AddGet(TRMGridReportPage, 'PageFooterMsg', TRMGridReportPage_PageFooterMsg, 0, [0], varEmpty);
    AddGet(TRMGridReportPage, 'DeleteRow', TRMGridReportPage_PageCaptionMsg, 0, [0], varEmpty);

    { TRMGridReport }
    AddClass(cReportMachine, TRMGridReport, 'TRMGridReport');
  end;
end;

initialization
  RMResigerReportPageClass(TRMGridReportPage);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

