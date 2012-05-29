unit RM_PTopGrid;

interface

{$I RM.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Stdctrls,
  Printers, DB, RM_Class, RM_FormReport, RM_DataSet, TSGrid, TSDBGrid, TSCommon
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMPrintTopGridObject = class(TComponent) // fake component
  end;

  { TRMPrintTopGrid }
  TRMPrintTopGrid = class(TRMFormReportObject)
  private
    FFormReport: TRMFormReport;
    FGrid: TtsCustomGrid;
    FUserDataset: TRMUserDataset;
    FList: TStringList;
    FCurrentRow: Integer;
    procedure OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
    procedure OnUserDatasetFirst(Sender: TObject);
    procedure OnUserDatasetNext(Sender: TObject);
    procedure OnUserDatasetPrior(Sender: TObject);
    procedure SetMemos;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
    procedure OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
  public
  end;

  { TRMPrintTopDBGrid }
  TRMPrintTopDBGrid = class(TRMFormReportObject)
  private
    FList: TStringList;
    FDBGrid: TtsCustomDBGrid;
//    procedure _OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
    procedure _OnBeforePrint(Memo: TStrings; View: TRMReportView);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

implementation

uses RM_Utils;

type
  THackReport = class(TRMReport)
  end;

  THackFormReport = class(TRMFormReport)
  end;

  THackGrid = class(TtsCustomGrid)
  end;

  THackDBGrid = class(TtsCustomDBGrid)
  end;

  THackView = class(TRMView)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintTopDBGrid}

constructor TRMPrintTopGrid.Create;
begin
  inherited Create;
  AutoFree := False;
end;

destructor TRMPrintTopGrid.Destroy;
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

procedure TRMPrintTopGrid.SetMemos;
var
  i: Integer;
  liView: TRMView;
  s: string;
  liValue: Variant;
begin
  for i := 0 to FList.Count - 1 do
  begin
    liView := FFormReport.Report.FindObject(FList[i]);
    if liView <> nil then
    begin
      if liView is TRMMemoView then
      begin
        s := THackGrid(FGrid).Cell[i + 1, FCurrentRow];
        if s = '[Error]' then s := '';
        liView.Memo.Text := s;
      end
      else if liView is TRMPictureView then
      begin
        liValue := THackGrid(FGrid).Cell[i + 1, FCurrentRow];
        if VarType(liValue) = varString then
          TRMPictureView(liView).Picture.LoadFromFile(liValue)
        else if VariantToBitmap(liValue) <> nil then
          TRMPictureView(liView).Picture.Assign(VariantToBitmap(liValue));
      end;
    end;

    if FCurrentRow < 0 then //Fixed Row
    begin
    end
    else
    begin
    end;
  end;
end;

procedure TRMPrintTopGrid.OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
begin
  Eof := FCurrentRow > (THackGrid(FGrid).RowCount - 1);
end;

procedure TRMPrintTopGrid.OnUserDatasetFirst(Sender: TObject);
begin
  FCurrentRow := THackGrid(FGrid).FixedRows;
  SetMemos;
end;

procedure TRMPrintTopGrid.OnUserDatasetNext(Sender: TObject);
begin
  Inc(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintTopGrid.OnUserDatasetPrior(Sender: TObject);
begin
  Dec(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintTopGrid.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
begin
  PrintBand := True;
end;

procedure TRMPrintTopGrid.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, tmpx, tmpx0, NextTop: Integer;
  liGrid: THackGrid;
  DSet: TDataSet;
  liPage: TRMReportPage;
  liPageNo, liNum, liGridTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liCol: TtsCol;

  procedure DrawDoubleFrameBottom(aView: TRMView; aList: TList);
  var
    t: TRMMemoView;
  begin
    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      t := TRMMemoView(RMCreateObject(gtMemo, ''));
      t.ParentPage := liPage;
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.TopFrame.spWidth := 2;
      t.spGapLeft := 0; t.spGapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      t.Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure MakeOneHeader(aIndex: Integer);
  var
    liCol: TtsCol;
  begin
    liCol := liGrid.Col[aIndex];
    liView := TRMMemoView(RMCreateObject(gtMemo, ''));
    liView.ParentPage := liPage;
    liView.Memo.Text := liCol.Heading;
    liView.spLeft := tmpx;
    liView.spTop := NextTop;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liGridTitleHeight;
    TRMMemoView(liView).WordWrap := (liCol.HeadingWordWrap = wwOn) or ((liCol.HeadingWordWrap = wwDefault) and (liGrid.HeadingWordWrap = wwOn));
    if liCol.HeadingFont <> nil then
      aFormReport.AssignFont(TRMMemoView(liView), liCol.HeadingFont)
    else
      aFormReport.AssignFont(TRMMemoView(liView), liGrid.HeadingFont);

    case liCol.HeadingHorzAlignment of
      htaLeft: TRMMemoView(liView).HAlign := rmhLeft;
      htaRight: TRMMemoView(liView).HAlign := rmhRight;
    else
      TRMMemoView(liView).HAlign := rmhCenter;
    end;
    case liCol.HeadingVertAlignment of
      vtaCenter: TRMMemoView(liView).VAlign := rmvCenter;
      vtaBottom: TRMMemoView(liView).VAlign := rmvBottom;
    else
      TRMMemoView(liView).VAlign := rmvTop;
    end;

    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liCol.Color;
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
    tmpx := tmpx + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.spWidth := 2;
      liView.TopFrame.spWidth := 2;
    end;
    liFlagFirstColumn := False;
  end;

  procedure MakeOneDetail(aIndex: Integer);
  var
    liCol: TtsCol;
  begin
    liCol := liGrid.Col[aIndex];
    if liCol.ControlType = ctPicture then
    begin
      liView := TRMPictureView(RMCreateObject(gtPicture, ''));
      liView.ParentPage := liPage;
      liView.Memo.Text := '';
      TRMPictureView(liView).PictureRatio := TRUE;
      TRMPictureView(liView).PictureStretched := (liCol.StretchPicture = dopOn) or ((liCol.StretchPicture = dopDefault) and liGrid.StretchPicture);
      TRMPictureView(liView).PictureCenter := liGrid.CenterPicture;
    end
    else
    begin
      liView := TRMMemoView(RMCreateObject(gtMemo, ''));
      liView.ParentPage := liPage;
      TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
      if liCol.Font <> nil then
        aFormReport.AssignFont(TRMMemoView(liView), liCol.Font)
      else
        aFormReport.AssignFont(TRMMemoView(liView), liGrid.Font);
      liView.Memo.Text := '';
      TRMMemoView(liView).WordWrap := (liCol.WordWrap = wwOn) or ((liCol.WordWrap = wwDefault) and (liGrid.WordWrap = wwOn));

      case liCol.HorzAlignment of
        htaLeft: TRMMemoView(liView).HAlign := rmhLeft;
        htaRight: TRMMemoView(liView).HAlign := rmhRight;
      else
        TRMMemoView(liView).HAlign := rmhCenter;
      end;
      case liCol.VertAlignment of
        vtaCenter: TRMMemoView(liView).VAlign := rmvCenter;
        vtaBottom: TRMMemoView(liView).VAlign := rmvBottom;
      else
        TRMMemoView(liView).VAlign := rmvTop;
      end;
    end;
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

    FList.Add(liView.Name);
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liGrid.DefaultRowHeight + 4;
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liGrid.Color;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, DSet.Fields[aIndex].FieldName, liView);

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.spWidth := 2;
    end;
    DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  procedure DrawFixedColHeader;
  var
    i: Integer;
    liCol: TtsCol;
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if i < liGrid.Cols then
        MakeOneHeader(i);
    end;
  end;

  procedure DrawFixedColDetail;
  var
    i: Integer;
    liCol: TtsCol;
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if i < liGrid.Cols then
        MakeOneDetail(i);
    end;
  end;

begin
  if aFormReport.DrawOnPageFooter then exit;
  liGrid := THackGrid(aControl);
  FFormReport := aFormReport;

  FGrid := liGrid;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (liGrid.SelectedRows.Count > 0) then
  begin
//    AutoFree := False;
//    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  liGridTitleHeight := 0;
  NextTop := aControl.Top + THackFormReport(aFormReport).OffsY;

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

  tmpx := 0;
  for i := 1 to liGrid.Cols do
  begin
    liCol := liGrid.Col[i];
    if liCol.Visible then
      tmpx := tmpx + liCol.Width + 1;
  end;

  if liGrid.HeadingOn and (rmgoGridNumber in aFormReport.ReportOptions) then
    tmpx := tmpx + RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;

  if (aFormReport.PrintControl = aControl) or (tmpx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(tmpx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

  if liGrid.HeadingOn then //表头
  begin
    liFlagFirstColumn := True;
    liGridTitleHeight := liGrid.RowHeights[0] + 4;
    tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
    if rmgoGridNumber in aFormReport.ReportOptions then
    begin
      liView := RMCreateObject(gtMemo, '');
      liView.ParentPage := aPage;
      liView.spLeft := tmpx;
      liView.spTop := NextTop;
      liView.spWidth := RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;
      liView.spHeight := liGridTitleHeight;
      liView.Memo.Add(aFormReport.GridNumOptions.Text);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).HAlign := rmhCenter;
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
      tmpx := tmpx + liView.spWidth;

      if rmgoDoubleFrame in aFormReport.ReportOptions then
      begin
        if liFlagFirstColumn then
          liView.LeftFrame.spWidth := 2;
        liView.TopFrame.spWidth := 2;
      end;
      liFlagFirstColumn := False;
    end;

    liPage := aPage; liNum := 0;
    tmpx0 := tmpx;
    for i := 1 to liGrid.Cols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liCol.Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
        begin
          liNum := 0;
          liFlagFirstColumn := True;
          if rmgoDoubleFrame in aFormReport.ReportOptions then
            liView.RightFrame.spWidth := 2;

          THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
          liPage := TRMReportPage(aFormReport.Report.Pages[aFormReport.Report.Pages.Count - 1]);
          tmpx := tmpx0;
          liFlagFirstColumn := True;
          DrawFixedColHeader;
        end;
      end;

      MakeOneHeader(i);
      Inc(liNum);
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.spWidth := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);

  liPage := aPage; //表体
  tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
  liFlagFirstColumn := True;
  if rmgoGridNumber in aFormReport.ReportOptions then
  begin
    liView := RMCreateObject(gtMemo, '');
    liView.ParentPage := aPage;
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;
    liView.spHeight := liGrid.DefaultRowHeight + 4;
    liView.Memo.Add('[Line#]');
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HAlign := rmhCenter;
    if (rmgoGridLines in aFormReport.ReportOptions) then
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
        liView.LeftFrame.spWidth := 2;
    end;
    DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  tmpx0 := tmpx;
  liNum := 0; liPageNo := 0;
  for i := 1 to liGrid.Cols do
  begin
    liCol := liGrid.Col[i];
    if not liCol.Visible then Continue;
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liCol.Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.spWidth := 2;

        liFlagFirstColumn := True;
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
        DrawFixedColDetail;
      end;
    end;

    MakeOneDetail(i);
    Inc(liNum);
  end;

  if liNum > 0 then
  begin
    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.spWidth := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintTopDBGrid}

//procedure TRMPrintTopDBGrid.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
//begin
//  PrintBand := THackDBGrid(FDBGrid).SelectedRows.Selected[THackDBGrid(FDBGrid).CurrentDataRow];
//end;

constructor TRMPrintTopDBGrid.Create;
begin
  inherited Create;
  FList := TStringList.Create;
end;

destructor TRMPrintTopDBGrid.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TRMPrintTopDBGrid._OnBeforePrint(Memo: TStrings; View: TRMReportView);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if AnsiCompareText(View.Name, FList[i]) = 0 then
    begin
      if View is TRMMemoView then
      begin
        Memo.Text := THackDBGrid(FDBGrid).Cell[StrToInt(Memo[0]), THackDBGrid(FDBGrid).CurrentDataRow];
      end;
    end;
  end;
end;

procedure TRMPrintTopDBGrid.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, tmpx, tmpx0, NextTop: Integer;
  liGrid: THackDBGrid;
  DSet: TDataSet;
  liPage: TRMReportPage;
  liPageNo, liNum, liGridTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liCol: TtsDBCol;
  liNeedBeforePrint: Boolean;

  procedure DrawDoubleFrameBottom(aView: TRMView; aList: TList);
  var
    t: TRMMemoView;
  begin
    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      t := TRMMemoView(RMCreateObject(gtMemo, ''));
      t.ParentPage := liPage;
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.TopFrame.spWidth := 2;
      t.spGapLeft := 0; t.spGapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      t.Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure MakeOneHeader(aIndex: Integer);
  var
    liCol: TtsDBCol;
  begin
    liCol := liGrid.Col[aIndex];
    liView := TRMMemoView(RMCreateObject(gtMemo, ''));
    liView.ParentPage := liPage;
    liView.Memo.Text := liCol.Heading;
    liView.spLeft := tmpx;
    liView.spTop := NextTop;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liGridTitleHeight;
    TRMMemoView(liView).WordWrap := (liCol.HeadingWordWrap = wwOn) or ((liCol.HeadingWordWrap = wwDefault) and (liGrid.HeadingWordWrap = wwOn));
    if liCol.HeadingFont <> nil then
      aFormReport.AssignFont(TRMMemoView(liView), liCol.HeadingFont)
    else
      aFormReport.AssignFont(TRMMemoView(liView), liGrid.HeadingFont);

    case liCol.HeadingHorzAlignment of
      htaLeft: TRMMemoView(liView).HAlign := rmhLeft;
      htaRight: TRMMemoView(liView).HAlign := rmhRight;
    else
      TRMMemoView(liView).HAlign := rmhCenter;
    end;
    case liCol.HeadingVertAlignment of
      vtaCenter: TRMMemoView(liView).VAlign := rmvCenter;
      vtaBottom: TRMMemoView(liView).VAlign := rmvBottom;
    else
      TRMMemoView(liView).VAlign := rmvTop;
    end;

    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liCol.Color;
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
    tmpx := tmpx + liView.spWidth;

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.spWidth := 2;
      liView.TopFrame.spWidth := 2;
    end;
    liFlagFirstColumn := False;
  end;

  procedure MakeOneDetail(aIndex: Integer);
  var
    liCol: TtsDBCol;
  begin
    liCol := liGrid.Col[aIndex];
    if liCol.ControlType = ctPicture then
    begin
      liView := TRMPictureView(RMCreateObject(gtPicture, ''));
      liView.ParentPage := liPage;
      liView.Memo.Text := Format('[%s.%s."%s"]', [DSet.Owner.Name, DSet.Name, liCol.DatasetField.FieldName]);
      TRMPictureView(liView).PictureRatio := TRUE;
      TRMPictureView(liView).PictureStretched := (liCol.StretchPicture = dopOn) or ((liCol.StretchPicture = dopDefault) and liGrid.StretchPicture);
      TRMPictureView(liView).PictureCenter := liGrid.CenterPicture;
    end
    else
    begin
      liView := TRMMemoView(RMCreateObject(gtMemo, ''));
      liView.ParentPage := liPage;
      TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
      if liCol.Font <> nil then
        aFormReport.AssignFont(TRMMemoView(liView), liCol.Font)
      else
        aFormReport.AssignFont(TRMMemoView(liView), liGrid.Font);
      liView.Memo.Text := Format('[%s.%s."%s"]', [DSet.Owner.Name, DSet.Name, liCol.FieldName]);
      TRMMemoView(liView).WordWrap := (liCol.WordWrap = wwOn) or ((liCol.WordWrap = wwDefault) and (liGrid.WordWrap = wwOn));

      case liCol.HorzAlignment of
        htaLeft: TRMMemoView(liView).HAlign := rmhLeft;
        htaRight: TRMMemoView(liView).HAlign := rmhRight;
      else
        TRMMemoView(liView).HAlign := rmhCenter;
      end;
      case liCol.VertAlignment of
        vtaCenter: TRMMemoView(liView).VAlign := rmvCenter;
        vtaBottom: TRMMemoView(liView).VAlign := rmvBottom;
      else
        TRMMemoView(liView).VAlign := rmvTop;
      end;

      THackFormReport(aFormReport).SetMemoViewFormat(TRMMemoView(liView), liCol.DatasetField);
    end;
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

    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liGrid.DefaultRowHeight + 4;
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liGrid.Color;

    if liCol.DatasetField = nil then
    begin
      liNeedBeforePrint := True;
      FList.Add(liView.Name);
      liView.Memo.Text := IntToStr(aIndex);
    end;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, DSet.Fields[aIndex].FieldName, liView);

    if rmgoDoubleFrame in aFormReport.ReportOptions then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.spWidth := 2;
    end;
    DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  procedure DrawFixedColHeader;
  var
    i: Integer;
    liCol: TtsDBCol;
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if i < liGrid.Cols then
        MakeOneHeader(i);
    end;
  end;

  procedure DrawFixedColDetail;
  var
    i: Integer;
    liCol: TtsDBCol;
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if i < liGrid.Cols then
        MakeOneDetail(i);
    end;
  end;

begin
  if aFormReport.DrawOnPageFooter then exit;
  liGrid := THackDBGrid(aControl);
  if (liGrid.Datasource = nil) or (liGrid.Datasource.Dataset = nil) then Exit;
  if not liGrid.Datasource.Dataset.Active then Exit;

  FDBGrid := liGrid;
  FList.Clear;
  liNeedBeforePrint := False;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (liGrid.SelectedRows.Count > 0) then
  begin
//    AutoFree := False;
//    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  liGridTitleHeight := 0;
  NextTop := aControl.Top + THackFormReport(aFormReport).OffsY;
  aFormReport.MainDataSet := THackFormReport(aFormReport).AddRMDataSet(THackDBGrid(FDBGrid).DataSource.DataSet);

  DSet := liGrid.Datasource.Dataset;
  tmpx := 0;
  for i := 1 to liGrid.Cols do
  begin
    liCol := liGrid.Col[i];
    if liCol.Visible then
      tmpx := tmpx + liCol.Width + 1;
  end;

  if liGrid.HeadingOn and (rmgoGridNumber in aFormReport.ReportOptions) then
    tmpx := tmpx + RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;

  if (aFormReport.PrintControl = aControl) or (tmpx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(tmpx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

  if liGrid.HeadingOn then //表头
  begin
    liFlagFirstColumn := True;
    liGridTitleHeight := liGrid.RowHeights[0] + 4;
    tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
    if rmgoGridNumber in aFormReport.ReportOptions then
    begin
      liView := RMCreateObject(gtMemo, '');
      liView.ParentPage := aPage;
      liView.spLeft := tmpx;
      liView.spTop := NextTop;
      liView.spWidth := RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;
      liView.spHeight := liGridTitleHeight;
      liView.Memo.Add(aFormReport.GridNumOptions.Text);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).HAlign := rmhCenter;
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
      tmpx := tmpx + liView.spWidth;

      if rmgoDoubleFrame in aFormReport.ReportOptions then
      begin
        if liFlagFirstColumn then
          liView.LeftFrame.spWidth := 2;
        liView.TopFrame.spWidth := 2;
      end;
      liFlagFirstColumn := False;
    end;

    liPage := aPage; liNum := 0;
    tmpx0 := tmpx;
    for i := 1 to liGrid.Cols do
    begin
      liCol := liGrid.Col[i];
      if not liCol.Visible then Continue;
      if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liCol.Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
        begin
          liNum := 0;
          liFlagFirstColumn := True;
          if rmgoDoubleFrame in aFormReport.ReportOptions then
            liView.RightFrame.spWidth := 2;

          THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
          liPage := TRMReportPage(aFormReport.Report.Pages[aFormReport.Report.Pages.Count - 1]);
          tmpx := tmpx0;
          liFlagFirstColumn := True;
          DrawFixedColHeader;
        end;
      end;

      MakeOneHeader(i);
      Inc(liNum);
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.spWidth := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);

  liPage := aPage; //表体
  tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
  liFlagFirstColumn := True;
  if rmgoGridNumber in aFormReport.ReportOptions then
  begin
    liView := RMCreateObject(gtMemo, '');
    liView.ParentPage := aPage;
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := RMCanvasHeight('a', liGrid.Font) * aFormReport.GridNumOptions.Number;
    liView.spHeight := liGrid.DefaultRowHeight + 4;
    liView.Memo.Add('[Line#]');
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HAlign := rmhCenter;
    if (rmgoGridLines in aFormReport.ReportOptions) then
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
        liView.LeftFrame.spWidth := 2;
    end;
    DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  tmpx0 := tmpx;
  liNum := 0; liPageNo := 0;
  for i := 1 to liGrid.Cols do
  begin
    liCol := liGrid.Col[i];
    if not liCol.Visible then Continue;
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (liCol.Width + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.spWidth := 2;

        liFlagFirstColumn := True;
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
        DrawFixedColDetail;
      end;
    end;

    MakeOneDetail(i);
    Inc(liNum);
  end;

  if liNum > 0 then
  begin
    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.spWidth := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);

  if liNeedBeforePrint then
  begin
    AutoFree := False;
    aFormReport.Report.OnBeforePrint := _OnBeforePrint;
  end;
end;

initialization
  RMRegisterFormReportControl(TtsCustomDBGrid, TRMPrintTopDBGrid);
  RMRegisterFormReportControl(TtsCustomGrid, TRMPrintTopGrid);

end.

