
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{             dbgrid report               }
{                                         }
{*****************************************}

unit RM_PdcsGrid;

interface

{$I RM.INC}
{$IFDEF DecisionGrid}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Stdctrls,
  Printers, Grids, RM_Class, RM_View, RM_Pars, RM_dset, RM_FormReport, mxgrid;

type
  TRMPrintDecision = class(TComponent) // fake component
  end;

  {TRMPrintDecisionGrid}
  TRMPrintDecisionGrid = class(TRMFormReportObject)
  private
    FFormReport: TRMFormReport;
    FGrid: TCustomDecisionGrid;
    FUserDataset: TRMUserDataset;
    FList: TStringList;
    FCurrentRow: Integer;
    procedure OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
    procedure OnUserDatasetFirst(Sender: TObject);
    procedure OnUserDatasetNext(Sender: TObject);
    procedure OnUserDatasetPrior(Sender: TObject);
		procedure OnReportBeginBand(Band: TRMBand);
    procedure SetMemos;
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; Page: TRMPage;
      Control: TControl; var t: TRMView); override;
  published
  end;

{$ENDIF}

implementation

{$IFDEF DecisionGrid}

uses RM_Utils;

{--------------------------------------------------------------------------------}
{--------------------------------------------------------------------------------}
{ TRMPrintDecisionGrid }

constructor TRMPrintDecisionGrid.Create;
begin
  inherited Create;
  AutoFree := False;
end;

destructor TRMPrintDecisionGrid.Destroy;
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

type
  THackGrid = class(TCustomGrid)
  end;

  THackDecisionGrid = class(TCustomDecisionGrid)
  end;

const
  MarginAfterTitle = 30;

procedure TRMPrintDecisionGrid.SetMemos;
var
  i: Integer;
  t: TRMMemoView;
  s: string;
  sTemp: string;
  liHeight: Integer;
  DQState: TDecisionDrawState;

  procedure AssignFont(aFont: TFont);
  var
    liSaveColor: TColor;
  begin
    liSaveColor := t.Font.Color;
    t.Font.Assign(aFont);
    if not (rmgoUseColor in FFormReport.ReportOptions) then
      t.Font.Color := liSaveColor;
  end;

begin
	liHeight := THackGrid(FGrid).RowHeights[FCurrentRow + THackGrid(FGrid).FixedRows + 1];
  for i := 0 to FList.Count - 1 do
  begin
    t := TRMMemoView(FFormReport.Report.FindObject(FList[i]));
    s := FGrid.Cells[i - THackGrid(FGrid).FixedCols, FCurrentRow];
    if s = '[Error]' then s := '';
    t.Memo.Text := s;
  	t.dy := liHeight;

    FGrid.CellDrawState(i - THackGrid(FGrid).FixedCols + 1, FCurrentRow, sTemp, DQState);
    if FCurrentRow < 0 then //Fixed Row
    begin
      if (dsRowCaption in DQState) or (dsColCaption in DQState) then
      begin
        if rmgoUseColor in FFormReport.ReportOptions then
          t.FillColor := THackDecisionGrid(FGrid).CaptionColor;
        AssignFont(THackDecisionGrid(FGrid).CaptionFont);
      end
      else if (dsRowValue in DQState) or (dsColValue in DQState) then
      begin
        if dsSum in DQState then
        begin
          if rmgoUseColor in FFormReport.ReportOptions then
            t.FillColor := THackDecisionGrid(FGrid).LabelSumColor;
          AssignFont(THackDecisionGrid(FGrid).LabelFont);
        end
        else
        begin
          if rmgoUseColor in FFormReport.ReportOptions then
            t.FillColor := THackDecisionGrid(FGrid).LabelColor;
          AssignFont(THackDecisionGrid(FGrid).LabelFont);
        end;
      end
      else if dsSum in DQState then
      begin
        if rmgoUseColor in FFormReport.ReportOptions then
          t.FillColor := THackDecisionGrid(FGrid).LabelSumColor;
        AssignFont(THackDecisionGrid(FGrid).LabelFont);
      end
      else
      begin
        if rmgoUseColor in FFormReport.ReportOptions then
          t.FillColor := THackDecisionGrid(FGrid).Color;
        AssignFont(THackDecisionGrid(FGrid).LabelFont);
      end;
    end
    else
    begin
      if (i - THackGrid(FGrid).FixedCols + 1) < 0 then
      begin
        if (dsRowValue in DQState) or (dsColValue in DQState) then
        begin
          if (dsSum in DQState) then
          begin
            if rmgoUseColor in FFormReport.ReportOptions then
              t.FillColor := THackDecisionGrid(FGrid).LabelSumColor;
            AssignFont(THackDecisionGrid(FGrid).LabelFont);
          end
          else
          begin
            if rmgoUseColor in FFormReport.ReportOptions then
              t.FillColor := THackDecisionGrid(FGrid).LabelColor;
            AssignFont(THackDecisionGrid(FGrid).LabelFont);
          end;
        end
        else
          if dsSum in DQState then
          begin
            if rmgoUseColor in FFormReport.ReportOptions then
              t.FillColor := THackDecisionGrid(FGrid).LabelSumColor;
            AssignFont(THackDecisionGrid(FGrid).LabelFont);
          end
          else
          begin
            if rmgoUseColor in FFormReport.ReportOptions then
              t.FillColor := THackDecisionGrid(FGrid).LabelColor;
            AssignFont(THackDecisionGrid(FGrid).LabelFont);
          end;
      end
      else
      begin
        if dsSum in DQState then
        begin
          if rmgoUseColor in FFormReport.ReportOptions then
            t.FillColor := THackDecisionGrid(FGrid).DataSumColor;
          AssignFont(THackDecisionGrid(FGrid).DataFont);
        end
        else
        begin
          if rmgoUseColor in FFormReport.ReportOptions then
            t.FillColor := THackDecisionGrid(FGrid).DataColor;
          AssignFont(THackDecisionGrid(FGrid).DataFont);
        end;
      end;
    end;
  end;
end;

procedure TRMPrintDecisionGrid.OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
begin
  Eof := FCurrentRow > (THackGrid(FGrid).RowCount - THackGrid(FGrid).FixedRows - 1);
end;

procedure TRMPrintDecisionGrid.OnUserDatasetFirst(Sender: TObject);
begin
  FCurrentRow := -THackGrid(FGrid).FixedRows;
  SetMemos;
end;

procedure TRMPrintDecisionGrid.OnUserDatasetNext(Sender: TObject);
begin
  Inc(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintDecisionGrid.OnUserDatasetPrior(Sender: TObject);
begin
  Dec(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintDecisionGrid.OnReportBeginBand(Band: TRMBand);
begin
  if Band.Typ = btMasterData then // .Name = FFormReport.DetailBandName then
    Band.dy := THackGrid(FGrid).RowHeights[FCurrentRow + THackGrid(FGrid).FixedRows + 1];
end;

type
  THackFormReport = class(TRMFormReport)
  end;

procedure TRMPrintDecisionGrid.OnGenerate_Object(aFormReport: TRMFormReport; Page: TRMPage;
  Control: TControl; var t: TRMView);
var
  liView: TRMMemoView;
  i, liPageNo, Leftx, NextLeft: Integer;
  liNum: Integer;
  liGrid: THackGrid;
  liPage: TRMPage;

  procedure MakeOneDetail(aIndex: Integer);
  begin
    liView := TRMMemoView(RMCreateObject(gtMemo, ''));
    liView.CreateUniqueName;
    liView.PLayout := rmtlCenter;
    liView.PAlignment := rmtaCenterJustify;
    liView.PStretched := rmgoStretch in aFormReport.ReportOptions;
    liView.PWordWrap := rmgoWordWrap in aFormReport.ReportOptions;
    liView.Font.Assign(liGrid.Font);
    if rmgoGridLines in aFormReport.ReportOptions then
      liView.Prop['FrameTyp'] := $F
    else
      liView.Prop['FrameTyp'] := 0;
    liView.x := NextLeft;
    liView.dx := liGrid.ColWidths[aIndex] + 1;
    liView.y := 0;
		liView.dy := 4;

    liPage.Objects.Add(liView);
    aFormReport.PageDetailViews.Add(liView);
    FList.Add(liView.Name);
    NextLeft := NextLeft + liView.dx;
  end;

  procedure DrawFixedDetail;
  var
    i: Integer;
  begin
    for i := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if i < liGrid.ColCount then
        MakeOneDetail(i);
    end;
  end;

begin
  if aFormReport.DrawOnPageFooter then exit;
  liGrid := THackGrid(Control);
  FGrid := TCustomDecisionGrid(Control);
  FFormReport := aFormReport;

  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + Control.Top;
  aFormReport.GridHeight := Control.Height;

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
//  aFormReport.ReportDataSet := FUserDataset;
  aFormReport.Report.OnBeginBand := OnReportBeginBand;

  Leftx := 0;
  for i := 0 to liGrid.ColCount - 1 do
    Leftx := Leftx + liGrid.ColWidths[i] + 1;

  if (aFormReport.PrintControl = Control) or (Leftx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(Leftx + (THackFormReport(aFormReport).OffsX + Control.Left) * 2);

  NextLeft := 0;

  liPage := Page;
  liPageNo := 0; liNum := 0;
  NextLeft := Control.Left + THackFormReport(aFormReport).OffsX;
  for i := 0 to liGrid.ColCount - 1 do //±íÌå
  begin
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(NextLeft + (liGrid.ColWidths[i] + 1)) > THackFormReport(aFormReport).PageWidth) then // ³¬¿í
      begin
        THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(NextLeft);
        Inc(liPageNo); liNum := 0;
        if liPageNo >= aFormReport.Report.Pages.Count then
        begin
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
        end;
        liPage := aFormReport.Report.Pages[liPageNo];
        NextLeft := Control.Left + THackFormReport(aFormReport).OffsX;
        DrawFixedDetail;
      end;
    end;

    MakeOneDetail(i);
    Inc(liNum);
  end;

  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(NextLeft);
end;

initialization
  RMRegisterFormReportControl(TCustomDecisionGrid, TRMPrintDecisionGrid);
  RMRegisterFormReportControl(TDecisionGrid, TRMPrintDecisionGrid);

{$ENDIF}
end.

