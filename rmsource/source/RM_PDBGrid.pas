unit RM_PDBGrid;

{$I RM.INC}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Printers, Controls, DB,
  Forms, StdCtrls, Grids, DBCtrls, DBGrids, RM_const,
  RM_DataSet, RM_Class, RM_FormReport, RM_GridReport, RM_Grid;

type
  { TRMPrintDBGrid }
  TRMPrintDBGrid = class(TRMCustomGridReport)
  private
    FDBGrid: TCustomDBGrid;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function CreateReportFromGrid: Boolean; override;
  public
  published
    property DBGrid: TCustomDBGrid read FDBGrid write FDBGrid;
  end;

  { TRMFormPrintDBGrid }
  TRMFormPrintDBGrid = class(TRMFormReportObject)
  private
    FDBGrid: TCustomDBGrid;
    FParentReport: TRMReport;

    procedure OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMFormPrintStringGrid }
  TRMFormPrintStringGrid = class(TRMFormReportObject)
  private
    FFormReport: TRMFormReport;
    FGrid: TCustomGrid;
    FUserDataset: TRMUserDataset;
    FList: TStringList;
    FCurrentRow: Integer;
    procedure OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
    procedure OnUserDatasetFirst(Sender: TObject);
    procedure OnUserDatasetNext(Sender: TObject);
    procedure OnUserDatasetPrior(Sender: TObject);
    procedure OnReportBeginBand(Band: TRMBand);
    procedure SetMemos;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

implementation

uses RM_Utils;

type
  THackFormReport = class(TRMFormReport)
  end;

  THackDBGrid = class(TCustomDBGrid)
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TRMPrintDBGrid }

procedure TRMPrintDBGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDBGrid then
      FDBGrid := nil;
  end;
end;

function TRMPrintDBGrid.CreateReportFromGrid: Boolean;
var
  i, lColIndex, lRowOffset, lColCount: Integer;
  lRowHeight: Integer;
  lPage: TRMGridReportPage;
  lDBGrid: THackDBGrid;
  lGridEx: TRMGridEx;
  lBandColumnHeader: TRMBandColumnHeader;
  lBandMasterData: TRMBandMasterData;

  procedure _MakeOneColumn(lGridExCol, lDBGridCol: Integer);
  var
    t: TRMView;
  begin
    lGridEx.ColWidths[lGridExCol] := lDBGrid.Columns[lDBGridCol].Width + 1;
    if TDBGridOption(dgTitles) in lDBGrid.Options then //表头
    begin
      lGridEx.Cells[lGridExCol, 1].Text := lDBGrid.Columns[lDBGridCol].Title.Caption;
    end;

    // 表体
    lGridEx.Cells[lGridExCol, lRowOffset].Text := Format('[%s."%s"]', [AddRMDataSet(lDBGrid.DataSource.DataSet).Name, lDBGrid.Columns[lDBGridCol].FieldName]);
    t := lGridEx.Cells[lGridExCol, lRowOffset].View;
    if (lDBGrid.Columns[lDBGridCol].Field <> nil) and (lDBGrid.Columns[lDBGridCol].Field.DataType in [ftGraphic]) then //图像字段
    begin
    end
    else
    begin
      TRMMemoView(t).VAlign := rmvCenter;
      TRMMemoView(t).Stretched := rmgoStretch in ReportOptions;
      TRMMemoView(t).WordWrap := rmgoWordWrap in ReportOptions;
      case lDBGrid.Columns[lDBGridCol].Alignment of
        taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(t).HAlign := rmhRight;
        taCenter: TRMMemoView(t).HAlign := rmhCenter;
      end;
      TRMMemoView(t).Font.Assign(lDBGrid.Columns[lDBGridCol].Font);
      if GridFontOptions.UseCustomFontSize then
        TRMMemoView(t).Font.Size := GridFontOptions.Font.Size;
      SetMemoViewFormat(TRMMemoView(t), lDBGrid.DataSource.DataSet.FieldByName(lDBGrid.Columns[lDBGridCol].FieldName));
    end;

    if rmgoUseColor in ReportOptions then
      t.FillColor := lDBGrid.Columns[lDBGridCol].Color;
  end;

begin
  Result := False;
  lDBGrid := THackDBGrid(FDBGrid);
  if (lDBGrid.Datasource = nil) or (lDBGrid.Datasource.Dataset = nil) then Exit;
  if not lDBGrid.Datasource.Dataset.Active then Exit;

  lPage := Report.AddGridReportPage;
  lGridEx := lPage.Grid;

  lRowHeight := lDBGrid.DefaultRowHeight + 4;
  if MasterDataBandOptions.Height > 0 then
    lRowHeight := MasterDataBandOptions.Height;

  lColCount := 0;
  for i := 0 to lDBGrid.Columns.Count - 1 do
  begin
    {$IFDEF COMPILER4_UP}
    if not lDBGrid.Columns[i].Visible then Continue;
    {$ENDIF}
    lColCount := lColCount + 1;
  end;

  if (TDBGridOption(dgTitles) in lDBGrid.Options) and (rmgoGridNumber in ReportOptions) then
  begin
    lColCount := lColCount + 1;
  end;

  lGridEx.ColCount := lColCount + 1;
  if TDBGridOption(dgTitles) in lDBGrid.Options then //表头
  begin
    lGridEx.RowCount := 3;
    lRowOffset := 2;
    lGridEx.RowHeights[1] := lRowHeight;
    lGridEx.RowHeights[2] := lRowHeight;

    lBandColumnHeader := TRMBandColumnHeader.Create;
    lBandColumnHeader.ParentPage := lPage;
    lPage.RowBandViews[1] := lBandColumnHeader;
  end
  else
  begin
    lGridEx.RowCount := 2;
    lRowOffset := 1;
    lGridEx.RowHeights[1] := lRowHeight;
  end;

  lBandMasterData := TRMBandMasterData.Create;
  lBandMasterData.ParentPage := lPage;
  lPage.RowBandViews[lRowOffset] := lBandMasterData;
  lBandMasterData.DataSetName := AddRMDataSet(lDBGrid.DataSource.DataSet).Name;

  if (TDBGridOption(dgTitles) in lDBGrid.Options) and (rmgoGridNumber in ReportOptions) then
  begin
    lColIndex := 2;
    lGridEx.ColWidths[1] := RMCanvasHeight('a', lDBGrid.Font) * GridNumOptions.Number;
    if TDBGridOption(dgTitles) in lDBGrid.Options then //表头
    begin
      lGridEx.Cells[1, 1].Text := GridNumOptions.Text;
    end;

    lGridEx.Cells[1, lRowOffset].Text := '[_RM_Line]';
    TRMMemoView(lGridEx.Cells[1, lRowOffset].View).Stretched := rmgoStretch in ReportOptions;
  end
  else
    lColIndex := 1;
  for i := 0 to lDBGrid.Columns.Count - 1 do
  begin
    {$IFDEF COMPILER4_UP}
    if not lDBGrid.Columns[i].Visible then Continue;
    {$ENDIF}

    _MakeOneColumn(lColIndex, i);
    Inc(lColIndex);
  end;

  Result := True;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFormPrintDBGrid}

procedure TRMFormPrintDBGrid.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
begin
  if (Band.BandType = rmbtMasterData) and (not FParentReport.Flag_TableEmpty) and
    (not THackDBGrid(FDBGrid).SelectedRows.CurrentRowSelected) then
    PrintBand := False;
end;

procedure TRMFormPrintDBGrid.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, tmpx, tmpx0, lNextTop: Integer;
  liDBGrid: THackDBGrid;
  liPageNo: Integer;
  liNum: Integer;
  liGridTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liRowHeight: Integer;
  liPage: TRMReportPage;

  procedure _DrawDoubleFrameBottom(aView: TRMView; aList: TList);
  var
    t: TRMMemoView;
  begin
    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      t := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      t.ParentPage := liPage;
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.TopFrame.Width := 2;
      t.GapLeft := 0;
      t.GapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      t.Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure _MakeOneHeader(aIndex: Integer);
  begin
    liView := RMCreateObject(rmgtMemo, '');
    liView.ParentPage := liPage;
    liView.spLeft := tmpx;
    liView.spTop := lNextTop;
    liView.spWidth := liDBGrid.Columns[aIndex].Width + 1;
    liView.spHeight := liGridTitleHeight;
    TRMMemoView(liView).Font.Assign(liDBGrid.Columns[aIndex].Title.Font);
    liView.Memo.Text := liDBGrid.Columns[aIndex].Title.Caption;
    TRMMemoView(liView).VAlign := rmvCenter;
    case liDBGrid.Columns[aIndex].Title.Alignment of
      taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(liView).HALign := rmhRight;
      taCenter: TRMMemoView(liView).HAlign := rmhCenter;
    end;
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liDBGrid.Columns[aIndex].Title.Color;
    if (rmgoGridLines in aFormReport.ReportOptions) and
      (TDBGridOption(dgColLines) in liDBGrid.Options) then
    begin
      liView.LeftFrame.Visible := True;
      liView.TopFrame.Visible := True;
      liView.RightFrame.Visible := True;
      liView.BottomFrame.Visible := True;
    end
    else
    begin
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
    end;

    aFormReport.ColumnHeaderViews.Add(liView);
    tmpx := tmpx + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
      liView.TopFrame.Width := 2;
    end;
    liFlagFirstColumn := False;
  end;

  procedure _MakeOneDetail(aIndex: Integer);
  begin
    if (liDBGrid.Columns[aIndex].Field <> nil) and (liDBGrid.Columns[aIndex].Field.DataType in [ftGraphic]) then //图像字段
    begin
      liView := RMCreateObject(rmgtPicture, '');
      liView.ParentPage := liPage;
      //      TRMPictureView(liView).BandAlign := rmbaHeight;
      TRMPictureView(liView).PictureRatio := True;
    end
    else
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := liPage;
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
      TRMMemoView(liView).WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
      TRMMemoView(liView).DBFieldOnly := True;
      case liDBGrid.Columns[aIndex].Alignment of
        taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
        taCenter: TRMMemoView(liView).HAlign := rmhCenter;
      end;
      TRMMemoView(liView).Font.Assign(liDBGrid.Columns[aIndex].Font);
      if aFormReport.GridFontOptions.UseCustomFontSize then
        TRMMemoView(liView).Font.Size := aFormReport.GridFontOptions.Font.Size;
      THackFormReport(aFormReport).SetMemoViewFormat(TRMMemoView(liView), liDBGrid.DataSource.DataSet.FieldByName(liDBGrid.Columns[aIndex].FieldName));
    end;
    if (rmgoGridLines in aFormReport.ReportOptions) and
      (TDBGridOption(dgColLines) in liDBGrid.Options) then
    begin
      liView.LeftFrame.Visible := True;
      liView.TopFrame.Visible := True;
      liView.RightFrame.Visible := True;
      liView.BottomFrame.Visible := True;
    end
    else
    begin
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
    end;

    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := liDBGrid.Columns[aIndex].Width + 1;
    liView.spHeight := liRowHeight;
    liView.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(liDBGrid.DataSource.DataSet).Name, liDBGrid.Columns[aIndex].FieldName]);
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liDBGrid.Columns[aIndex].Color;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, liDBGrid.Columns[aIndex].FieldName, liView);

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
    end;
    _DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  procedure _DrawFixedColHeader;
  var
    i: Integer;
  begin
    for i := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if i < liDBGrid.Columns.Count then
        _MakeOneHeader(i);
    end;
  end;

  procedure _DrawFixedColDetail;
  var
    i: Integer;
  begin
    for i := 0 to aFormReport.GridFixedCols - 1 do //表体
    begin
      {$IFDEF COMPILER4_UP}
      if not liDBGrid.Columns[i].Visible then
        Continue;
      {$ENDIF}
      if i < liDBGrid.Columns.Count then
        _MakeOneDetail(i);
    end;
  end;

begin
//  if aFormReport.DrawOnPageFooter then Exit;

  FParentReport := aFormReport.Report;
  liDBGrid := THackDBGrid(aControl);
  if (liDBGrid.Datasource = nil) or (liDBGrid.Datasource.Dataset = nil) then Exit;
  if not liDBGrid.Datasource.Dataset.Active then Exit;

  FDBGrid := liDBGrid;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (liDBGrid.SelectedRows.Count > 0) then //只打印选择的记录
  begin
    AutoFree := False;
    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  liRowHeight := liDBGrid.DefaultRowHeight + 4;
  if aFormReport.MasterDataBandOptions.Height > 0 then
    liRowHeight := aFormReport.MasterDataBandOptions.Height;

  aFormReport.DrawOnPageFooter := True;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  lNextTop := aControl.Top + THackFormReport(aFormReport).OffsY;
  aFormReport.MainDataSet := THackFormReport(aFormReport).AddRMDataSet(liDBGrid.DataSource.DataSet);
  liGridTitleHeight := 0;
  tmpx := 0;
  for i := 0 to liDBGrid.Columns.Count - 1 do
  begin
    {$IFDEF COMPILER4_UP}
    if liDBGrid.Columns[i].Visible then
      {$ENDIF}
      tmpx := tmpx + liDBGrid.Columns[i].Width + 1;
  end;

  if (TDBGridOption(dgTitles) in liDBGrid.Options) and (rmgoGridNumber in aFormReport.ReportOptions) then
    tmpx := tmpx + RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;

  if (aFormReport.PrintControl = aControl) or (tmpx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(tmpx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

  // 表头
  liPage := TRMReportPage(aFormReport.Report.Pages[0]);
  if TDBGridOption(dgTitles) in liDBGrid.Options then //表头
  begin
    liFlagFirstColumn := True;
    liGridTitleHeight := liDBGrid.RowHeights[0] + 4;
    tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
    if rmgoGridNumber in aFormReport.ReportOptions then
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := liPage;
      liView.spLeft := tmpx;
      liView.spTop := lNextTop;
      liView.spWidth := RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;
      liView.spHeight := liGridTitleHeight;
      liView.Memo.Add(aFormReport.GridNumOptions.Text);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).HAlign := rmhCenter;
      if (rmgoGridLines in aFormReport.ReportOptions) and (TDBGridOption(dgColLines) in liDBGrid.Options) then
      begin
        liView.LeftFrame.Visible := True;
        liView.TopFrame.Visible := True;
        liView.RightFrame.Visible := True;
        liView.BottomFrame.Visible := True;
      end
      else
      begin
        liView.LeftFrame.Visible := False;
        liView.TopFrame.Visible := False;
        liView.RightFrame.Visible := False;
        liView.BottomFrame.Visible := False;
      end;

      aFormReport.ColumnHeaderViews.Add(liView);
      tmpx := tmpx + liView.spWidth;

      if rmgoDoubleFrame in aFormReport.ReportOptions then
      begin
        if liFlagFirstColumn then
          liView.LeftFrame.Width := 2;
        liView.TopFrame.Width := 2;
      end;
      liFlagFirstColumn := False;
    end;

    tmpx0 := tmpx;
    liNum := 0;
    for i := 0 to liDBGrid.Columns.Count - 1 do
    begin
      {$IFDEF COMPILER4_UP}
      if not liDBGrid.Columns[i].Visible then
        Continue;
      {$ENDIF}
      if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liDBGrid.Columns[i].Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
        begin
          liNum := 0;
          liFlagFirstColumn := True;
          if rmgoDoubleFrame in aFormReport.ReportOptions then
            liView.RightFrame.Width := 2;

          THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
          liPage := TRMReportPage(aFormReport.Report.Pages[aFormReport.Report.Pages.Count - 1]);
          tmpx := tmpx0;
          liFlagFirstColumn := True;
          _DrawFixedColHeader;
        end;
      end;

      _MakeOneHeader(i);
      Inc(liNum);
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);

  // 表体
  liPageNo := 0;
  liPage := TRMReportPage(aFormReport.Report.Pages[0]);
  tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
  liFlagFirstColumn := True;
  if (dgTitles in liDBGrid.Options) and (rmgoGridNumber in aFormReport.ReportOptions) then
  begin
    liView := RMCreateObject(rmgtMemo, '');
    liView.ParentPage := liPage;
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;
    liView.spHeight := liRowHeight;
    liView.Memo.Add('[_RM_Line]');
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HAlign := rmhCenter;
    if (rmgoGridLines in aFormReport.ReportOptions) and (TDBGridOption(dgColLines) in liDBGrid.Options) then
    begin
      liView.LeftFrame.Visible := True;
      liView.TopFrame.Visible := True;
      liView.RightFrame.Visible := True;
      liView.BottomFrame.Visible := True;
    end
    else
    begin
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
    end;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
    end;
    _DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  tmpx0 := tmpx;
  liPage := aPage;
  liNum := 0;
  for i := 0 to liDBGrid.Columns.Count - 1 do //表体
  begin
    {$IFDEF COMPILER4_UP}
    if not liDBGrid.Columns[i].Visible then
      Continue;
    {$ENDIF}
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liDBGrid.Columns[i].Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.Width := 2;

        THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(tmpx);
        Inc(liPageNo);
        if liPageNo >= aFormReport.Report.Pages.Count then
        begin
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
        end;
        liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
        tmpx := tmpx0;
        liFlagFirstColumn := True;
        _DrawFixedColDetail;
      end;
    end;

    _MakeOneDetail(i);
    Inc(liNum);
  end;

  if liNum > 0 then
  begin
    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFormPrintStringGrid}
type
  THackGrid = class(TCustomGrid)
  end;

constructor TRMFormPrintStringGrid.Create;
begin
  inherited Create;
  AutoFree := False;
end;

destructor TRMFormPrintStringGrid.Destroy;
begin
  if FUserDataset <> nil then
  begin
    FUserDataset.Free;
    FUserDataset := nil;
  end;
  if FList <> nil then
  begin
    FList.Free;
    FList := nil;
  end;
  inherited Destroy;
end;

procedure TRMFormPrintStringGrid.SetMemos;
var
  i: Integer;
  liView: TRMMemoView;
  s: string;
  liHeight: Integer;

  procedure AssignFont(aFont: TFont);
  var
    liSaveColor: TColor;
  begin
    liSaveColor := liView.Font.Color;
    liView.Font.Assign(aFont);
    if not (rmgoUseColor in FFormReport.ReportOptions) then
      liView.Font.Color := liSaveColor;
  end;

begin
  liHeight := THackGrid(FGrid).RowHeights[FCurrentRow];
  //	RMReport.Pages[0].FindObject(FDetailBandName).spHeight := liHeight;
  for i := 0 to FList.Count - 1 do
  begin
    liView := TRMMemoView(FFormReport.Report.FindObject(FList[i]));
    if liView <> nil then
    begin
      liView.spHeight := liHeight;
      s := THackGrid(FGrid).GetEditText(i, FCurrentRow);
      if s = '[Error]' then
        s := '';
      liView.Memo.Text := s;
    end;

    if FCurrentRow < 0 then //Fixed Row
    begin
    end
    else
    begin
    end;
  end;
end;

procedure TRMFormPrintStringGrid.OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
begin
  Eof := FCurrentRow > (THackGrid(FGrid).RowCount - 1);
end;

procedure TRMFormPrintStringGrid.OnUserDatasetFirst(Sender: TObject);
begin
  FCurrentRow := THackGrid(FGrid).FixedRows;
  SetMemos;
end;

procedure TRMFormPrintStringGrid.OnUserDatasetNext(Sender: TObject);
begin
  Inc(FCurrentRow);
  SetMemos;
end;

procedure TRMFormPrintStringGrid.OnUserDatasetPrior(Sender: TObject);
begin
  Dec(FCurrentRow);
  SetMemos;
end;

procedure TRMFormPrintStringGrid.OnReportBeginBand(Band: TRMBand);
begin
  if Band.BandType = rmbtMasterData then // .Name = FFormReport.DetailBandName then
    Band.spHeight := THackGrid(FGrid).RowHeights[FCurrentRow];
end;

procedure TRMFormPrintStringGrid.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  liView: TRMMemoView;
  i, j, liPageNo, Leftx, NextLeft, lNextTop: Integer;
  liNum: Integer;
  liGrid: THackGrid;
  s: string;
  liGridTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liPage: TRMReportPage;

  procedure _DrawDoubleFrameBottom(aView: TRMView; aList: TList);
  var
    t: TRMMemoView;
  begin
    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      t := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      t.ParentPage := liPage;
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.TopFrame.Width := 2;
      t.GapLeft := 0;
      t.GapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      TRMMemoView(t).Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure _MakeOneHeader(aRow, aIndex: Integer);
  begin
    liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    liView.ParentPage := liPage;
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HALign := rmhCenter;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    TRMMemoView(liView).WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
    liView.spLeft := NextLeft;
    liView.spTop := lNextTop;
    liView.spWidth := liGrid.ColWidths[aIndex] + 1;
    liView.spHeight := liGrid.RowHeights[aRow] + 4;
    liView.Font.Assign(liGrid.Font);
    s := liGrid.GetEditText(aIndex, aRow);
    if s = '[Error]' then
      s := '';
    liView.Memo.Text := s;
    if rmgoGridLines in aFormReport.ReportOptions then
    begin
      liView.LeftFrame.Visible := True;
      liView.TopFrame.Visible := True;
      liView.RightFrame.Visible := True;
      liView.BottomFrame.Visible := True;
    end
    else
    begin
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
    end;

    aFormReport.ColumnHeaderViews.Add(liView);
    NextLeft := NextLeft + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
      liView.TopFrame.Width := 2;
    end;
    liFlagFirstColumn := False;
  end;

  procedure _MakeOneDetail(aIndex: Integer);
  begin
    liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    liView.ParentPage := liPage;
    liView.VAlign := rmvCenter;
    liView.HAlign := rmhCenter;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    TRMMemoView(liView).WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
    liView.Font.Assign(liGrid.Font);
    if rmgoGridLines in aFormReport.ReportOptions then
    begin
      liView.LeftFrame.Visible := True;
      liView.TopFrame.Visible := True;
      liView.RightFrame.Visible := True;
      liView.BottomFrame.Visible := True;
    end
    else
    begin
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
    end;

    liView.spLeft := NextLeft;
    liView.spWidth := liGrid.ColWidths[aIndex] + 1;
    liView.spTop := 0;
    liView.spHeight := 4;

    aFormReport.PageDetailViews.Add(liView);
    FList.Add(liView.Name);
    NextLeft := NextLeft + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
    end;
    _DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  procedure _DrawFixedHeader(aRow: Integer);
  var
    j: Integer;
  begin
    for j := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if j < liGrid.ColCount then
        _MakeOneHeader(aRow, j);
    end;
  end;

  procedure _DrawFixedDetail;
  var
    i: Integer;
  begin
    for i := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if i < liGrid.ColCount then
        _MakeOneDetail(i);
    end;
  end;

begin
//  if aFormReport.DrawOnPageFooter then Exit;

  liGrid := THackGrid(aControl);
  FGrid := TCustomGrid(aControl);
  FFormReport := aFormReport;

  aFormReport.DrawOnPageFooter := True;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  liGridTitleHeight := 0;
  lNextTop := aControl.Top + THackFormReport(aFormReport).OffsY;

  if FUserDataset = nil then
    FUserDataset := TRMUserDataset.Create(nil);
  if FList = nil then
    FList := TStringList.Create;

  THackFormReport(aFormReport).CanSetDataSet := False;
  FList.Clear;
  FUserDataset.OnCheckEOF := OnUserDatasetCheckEOF;
  FUserDataset.OnFirst := OnUserDatasetFirst;
  FUserDataset.OnNext := OnUserDatasetNext;
  FUserDataset.OnPrior := OnUserDatasetPrior;
  aFormReport.Report.DataSet := FUserDataset;
  aFormReport.Report.OnBeginBand := OnReportBeginBand;

  Leftx := 0;
  for i := 0 to liGrid.ColCount - 1 do
    Leftx := Leftx + liGrid.ColWidths[i] + 1;

  if (aFormReport.PrintControl = aControl) or (Leftx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(Leftx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

  Leftx := aControl.Left + THackFormReport(aFormReport).OffsX;
  NextLeft := 0;
  if liGrid.FixedRows > 0 then //表头
  begin
    liFlagFirstColumn := True;
    for i := 0 to liGrid.FixedRows - 1 do
    begin
      liGridTitleHeight := liGridTitleHeight + liGrid.RowHeights[i] + 4;
      NextLeft := Leftx;
      liPageNo := 0;
      liNum := 0;
      liPage := TRMReportPage(aFormReport.Report.Pages[0]);
      for j := 0 to liGrid.ColCount - 1 do
      begin
        if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
        begin
          if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(NextLeft + (liGrid.ColWidths[j] + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
          begin
            liFlagFirstColumn := True;
            if rmgoDoubleFrame in aFormReport.ReportOptions then
              liView.RightFrame.Width := 2;

            THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(NextLeft);
            liNum := 0;
            Inc(liPageNo);
            if liPageNo >= aFormReport.Report.Pages.Count then
            begin
              THackFormReport(aFormReport).AddPage;
              THackFormReport(aFormReport).FormWidth.Add('0');
            end;
            liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
            NextLeft := Leftx;
            liFlagFirstColumn := True;
            _DrawFixedHeader(i);
          end;
        end;

        _MakeOneHeader(i, j);
        Inc(liNum);
      end;

      lNextTop := lNextTop + liGrid.RowHeights[i] + 4;
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(NextLeft);

  liPage := aPage;
  liPageNo := 0;
  liNum := 0;
  NextLeft := aControl.Left + THackFormReport(aFormReport).OffsX;
  liFlagFirstColumn := True;
  for i := 0 to liGrid.ColCount - 1 do //表体
  begin
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(NextLeft + (liGrid.ColWidths[i] + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.Width := 2;

        THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(NextLeft);
        Inc(liPageNo);
        liNum := 0;
        if liPageNo >= aFormReport.Report.Pages.Count then
        begin
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
        end;
        liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
        NextLeft := aControl.Left + THackFormReport(aFormReport).OffsX;
        liFlagFirstColumn := True;
        _DrawFixedDetail;
      end;
    end;

    _MakeOneDetail(i);
    Inc(liNum);
  end;

  if liNum > 0 then
  begin
    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(NextLeft);
end;

initialization
  RMRegisterFormReportControl(TStringGrid, TRMFormPrintStringGrid);
  RMRegisterFormReportControl(TCustomDBGrid, TRMFormPrintDBGrid);

end.

