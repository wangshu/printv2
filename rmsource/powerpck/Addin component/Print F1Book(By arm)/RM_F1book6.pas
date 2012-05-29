{*****************************************}
{                                         }
{          Report Machine v2.4            }
{          F1Book6 Report v1.10           }
{          Arm Tech Group                 }
{          425007@sina.com                }
{*****************************************}
unit RM_F1book6;

interface

{$I RM.INC}

{2002-3-1 修正了合并单元的对齐问题}
{2002-3-5 修正了显示问题}
{2002-7-22重写了部分代码，修正了单元格的高和宽计算误差问题}
{2002-7-22修正了负数的位置问题}
{2002-7-23修正了显示数字的小数点问题}
{2002-7-31增加了随f1book61.viewscale变化大小的功能}

{todo 2002-8-15 FitPageWidth FitPageHeight 功能}

uses
  SysUtils, Windows, Dialogs, Classes, Graphics, Controls, TTF160_TLB, RM_DataSet, RM_Class,
  RM_FormReport;

const
  Ver = 1.09;
type
  TRMPrintF1Book = class(TComponent)
  end;
  { TRMPrintF1book6 }
  TRMPrintF1book6 = class(TRMFormReportObject)
  private
    FFormReport: TRMFormReport;
    FGrid: TF1Book6;
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
    procedure OnGenerate_Object(aFormReport: TRMFormReport; Page: TRMReportPage;
      Control: TControl; var t: TRMView); override;
  end;
function IsNumber(S: string): boolean;
function RMConvertToPixels1(Avalue: extended): extended;
procedure Register;
implementation


uses RM_Utils;


type
  THackBook = class(TF1book6)
  end;

  THackFormReport = class(TRMFormReport)
  end;
{ TRMPrintF1book6 }

constructor TRMPrintF1book6.Create;
begin
  inherited Create;
  AutoFree := False;
end;

destructor TRMPrintF1book6.Destroy;
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

procedure TRMPrintF1book6.OnGenerate_Object(aFormReport: TRMFormReport;
  Page: TRMReportPage; Control: TControl; var t: TRMView);
var
  liView: TRMMemoView;
  i, j, liPageNo, Leftx, NextLeft, NextTop: Integer;
  liNum: Integer;
  liGrid: THackBook;
  s: string;
  liPage: TRMReportPage;
  liGridTitleHeight: Integer;
  procedure MakeOneHeader(aRow, aIndex: Integer);
    procedure FormatOneHeader(RowNo, ColNo: integer);
    var
      j: integer;
      liHeight, temp, pRow1, pCol1, pRow2, pCol2: integer;
      Cellformat: F1CellFormat;
    begin
      liHeight := Round(RMConvertToPixels1(FGrid.RowHeight[RowNo] / 1440 * FGrid.ViewScale / 100)) + 4;

      if (ColNo div 26) = 0 then
        FGrid.Selection := Chr(64 + ColNo) + inttostr(RowNo)
      else
        FGrid.Selection := Chr(64 + (ColNo div 26)) + Chr(64 + (ColNo mod 26)) + inttostr(FCurrentRow);
      begin
        FGrid.GetSelection(0, pRow1, pCol1, pRow2, pCol2);
        if (pRow1 < pRow2) and (pRow1 = RowNo) then
        begin
          Temp := 0;
          for J := pRow1 to pRow2 do
            Temp := Temp + Round(RMConvertToPixels1(FGrid.RowHeight[J] / 1440 * FGrid.ViewScale / 100)) + 4;
          liView.spHeight := temp;
        end
        else
          liView.spHeight := liHeight;
        if (pCol1 < pCol2) and (pCol1 = ColNo) then
        begin
          Temp := 0;
          for J := pCol1 to pCol2 do
            Temp := Temp + Round(RMConvertToPixels1(FGrid.ColWidthtwips[J] / 1440 * FGrid.ViewScale / 100)) + 1;
          liView.spWidth := Temp;
        end
        else
          liView.spWidth := Round(RMConvertToPixels1(FGrid.ColWidthtwips[ColNo] / 1440 * FGrid.ViewScale / 100)) + 1;
      end;
        //对齐方式
      FGrid.SetActiveCell(RowNo, ColNo);
      s := FGrid.TextRC[RowNo, ColNo];
      Cellformat := FGrid.GetCellFormat;
        //水平排列
      if CellFormat.AlignHorizontal = F1HAlignCenter then
        LiView.HAlign := rmhCenter;
      if CellFormat.AlignHorizontal = F1HalignRight then
        LiView.HAlign := rmhRight;
      if CellFormat.AlignHorizontal = F1HAlignLeft then
        LiView.HAlign := rmhLeft;
        {//垂直排列}
      if CellFormat.AlignVertical = F1VAlignTop then
        LiView.VAlign := rmvTop;
      if CellFormat.AlignVertical = F1VAlignCenter then
        LiView.VAlign := rmvCenter;
      if CellFormat.AlignVertical = F1VAlignBottom then
        LiView.VAlign := rmvBottom;
        //
      if CellFormat.AlignHorizontal = F1HAlignGeneral then
        if IsNumber(s) then
          LiView.HAlign := rmhRight
        else
          LiView.HAlign := rmhLeft;
       //字体
      LiView.Font.Name := CellFormat.FontName;
      LiView.Font.Size := CellFormat.FontSize;
      LiView.Font.Color := CellFormat.FontColor;
      Liview.Font.Style := [];
      if CellFormat.FontBold then
        Liview.Font.Style := LiView.Font.style + [fsBold];
      if CellFormat.FontItalic then
        Liview.Font.Style := LiView.Font.style + [fsItalic];
      if CellFormat.FontUnderline then
        Liview.Font.Style := LiView.Font.style + [fsUnderline];
      if CellFormat.FontStrikeout then
        Liview.Font.Style := LiView.Font.style + [fsStrikeOut];

     //画表格线
      FGrid.GetSelection(0, pRow1, pCol1, pRow2, pCol2);
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
      if RowNo = PRow1 then
        if cellformat.BorderStyle[F1TopBorder] > 0 then
          liView.TopFrame.Visible := True;
      if ColNo = PCol1 then
        if cellformat.BorderStyle[F1LeftBorder] > 0 then
          liView.LeftFrame.Visible := True;
      if RowNo = PRow2 then
        if cellformat.BorderStyle[F1BottomBorder] > 0 then
          liView.BottomFrame.Visible := True;
      if ColNo = PCol2 then
        if cellformat.BorderStyle[F1RightBorder] > 0 then
          liView.RightFrame.Visible := True;
    end;

  begin
    liView := TRMMemoView(RMCreateObject(gtMemo, ''));
    liView.ParentPage := liPage;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    liView.WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
    liView.spLeft := NextLeft;
    liView.spTop := NextTop;
    FormatOneHeader(aRow, aIndex);
    liView.Memo.Text := liGrid.TextRC[aRow, aIndex];
    aFormReport.ColumnHeaderViews.Add(liView);
    NextLeft := NextLeft + Round(RMConvertToPixels1(liGrid.ColWidthTwips[aIndex] / 1440 * FGrid.ViewScale / 100)) + 1;
  end;


  procedure MakeOneDetail(aIndex: Integer);
  var
    i: integer;
  begin
    if NextLeft = 0 then
    begin
      for i := 1 to aFormReport.GridFixedCols do
      begin
        liView := TRMMemoView(RMCreateObject(gtMemo, ''));
        liView.ParentPage := liPage;
        TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
        liView.WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
        liView.spLeft := NextLeft;
        liView.spWidth := Round(RMConvertToPixels1(liGrid.ColWidthTwips[i] / 1440 * FGrid.ViewScale / 100)) + 1;
        liView.spTop := 0;
        liView.spHeight := 20;
        liView.Font.Assign(liGrid.Font);
        aFormReport.PageDetailViews.Add(liView);
        FList.Add(liView.Name + '$' + IntToStr(I));
        NextLeft := NextLeft + liView.spWidth;
      end;
    end;
    if aIndex <= aFormReport.GridFixedCols then //
      exit;
    liView := TRMMemoView(RMCreateObject(gtMemo, ''));
    liView.ParentPage := liPage;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    liView.WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
    liView.spLeft := NextLeft;
    liView.spWidth := Round(RMConvertToPixels1(liGrid.ColWidthTwips[aIndex] / 1440 * FGrid.ViewScale / 100)) + 1;
    liView.spTop := 0;
    liView.spHeight := 20;
    aFormReport.PageDetailViews.Add(liView);
    FList.Add(liView.Name);
    NextLeft := NextLeft + liView.spWidth;
  end;
  procedure DrawFixedHeader(aRow: Integer);
  var
    j: Integer;
  begin
    for j := 1 to aFormReport.GridFixedCols do
    begin
      if j < liGrid.LastCol then
        MakeOneHeader(aRow, j);
    end;
  end;
begin
  if aFormReport.DrawOnPageFooter then exit;
  liGrid := THackBook(Control);
  FGrid := THackBook(Control);
  FFormReport := aFormReport;
  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + Control.Top;
  aFormReport.GridHeight := Control.Height;
  liGridTitleHeight := 0;
  NextTop := Control.Top + THackFormReport(aFormReport).OffsY;

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
  for i := 1 to liGrid.LastCol do
    Leftx := Leftx + Round(RMConvertToPixels1(liGrid.ColWidthTwips[i] / 1440 * FGrid.ViewScale / 100)) + 1;

  if (aFormReport.PrintControl = Control) or (Leftx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(Leftx + (THackFormReport(aFormReport).OffsX + Control.Left) * 2);

  Leftx := Control.Left + THackFormReport(aFormReport).OffsX;
  NextLeft := 0;
  if liGrid.FixedRows > 0 then //表头
  begin
    for i := 1 to liGrid.FixedRows do
    begin
      liGridTitleHeight := liGridTitleHeight + Round(RMConvertToPixels1(liGrid.RowHeight[i] / 1440 * FGrid.ViewScale / 100)) + 4;
      NextLeft := Leftx;
      liPageNo := 0; liNum := 0;
      liPage := TRMReportPage(aFormReport.Report.Pages[0]);
      for j := 1 to liGrid.LastCol do
      begin
        if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
        begin
          if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(NextLeft + (Round(RMConvertToPixels1(liGrid.ColWidthTwips[j] / 1440 * FGrid.ViewScale / 100)) + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
          begin
            liNum := 0;
            THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(NextLeft);
            Inc(liPageNo);
            if liPageNo >= aFormReport.Report.Pages.Count then
            begin
              THackFormReport(aFormReport).AddPage;
              THackFormReport(aFormReport).FormWidth.Add('0');
            end;
            liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
            NextLeft := Leftx;
            DrawFixedHeader(i);
          end;
        end;
        MakeOneHeader(i, j);
        Inc(liNum);
      end;
      NextTop := NextTop + Round(RMConvertToPixels1(liGrid.RowHeight[i] / 1440 * FGrid.ViewScale / 100)) + 4;
    end;
  end;


  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(NextLeft);

  liPage := Page;
  liPageNo := 0; liNum := 0;
  NextLeft := Control.Left + THackFormReport(aFormReport).OffsX;
  for i := 1 to liGrid.LastCol do //表体
  begin

    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(NextLeft + (Round(RMConvertToPixels1(liGrid.ColWidthTwips[i] / 1440 * FGrid.ViewScale / 100)) + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        {DONE -oArm:超过页宽时越界}
        THackFormReport(aFormReport).FormWidth[liPageNo] := IntToStr(NextLeft);
        Inc(liPageNo);
        if liPageNo >= aFormReport.Report.Pages.Count then
        begin
          THackFormReport(aFormReport).AddPage;
          THackFormReport(aFormReport).FormWidth.Add('0');
        end;
        liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
        NextLeft := Control.Left + THackFormReport(aFormReport).OffsX;
        {DONE -oArm:表前n列问题}
      end;
    end;
    MakeOneDetail(i);
    Inc(liNum);
  end;
  if THackFormReport(aFormReport).FormWidth.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(NextLeft);
end;

procedure TRMPrintF1book6.OnReportBeginBand(Band: TRMBand);
begin
  if Band.BandType = rmbtMasterData then
    Band.spHeight := Round(RMConvertToPixels1(FGrid.RowHeight[FCurrentRow] / 1440 * FGrid.ViewScale / 100));
end;

procedure TRMPrintF1book6.OnUserDatasetCheckEOF(Sender: TObject;
  var Eof: Boolean);
begin
  Eof := FCurrentRow > (THackbook(FGrid).LastRow);
end;

procedure TRMPrintF1book6.OnUserDatasetFirst(Sender: TObject);
begin
  FCurrentRow := 1 + THackbook(FGrid).FixedRows;
  SetMemos;
end;

procedure TRMPrintF1book6.OnUserDatasetNext(Sender: TObject);
begin
  Inc(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintF1book6.OnUserDatasetPrior(Sender: TObject);
begin
  Dec(FCurrentRow);
  SetMemos;
end;

procedure TRMPrintF1book6.SetMemos;
var
  i, FixCount: Integer;
  liView: TRMMemoView;
  s, S1: string;
  liHeight, Temp: Integer;
  cellformat: F1CellFormat;
  pRow1, pCol1, pRow2, pCol2: integer;
  procedure FindandSetMemo(RowNo, ColNo: integer; MemoName: string);
  var
    j: integer;
  begin
    liHeight := Round(RMConvertToPixels1(FGrid.RowHeight[RowNo] / 1440 * FGrid.ViewScale / 100));
    liView := TRMMemoView(FFormReport.Report.FindObject(MemoName));
    if liView <> nil then
    begin
      S := FGrid.FormattedTextRC[RowNo, ColNo + 1];
      if Abs(FGrid.TypeRC[RowNo, ColNo + 1]) = 1 then //number
      begin
        if FGrid.NumberRC[RowNo, ColNo + 1] = 0 then
          liView.Memo.Text := ''
        else
          liView.Memo.Text := s;
      end
      else
        liView.Memo.Text := s;
      //合并单元格的对齐方式
      if (ColNo div 26) = 0 then
        FGrid.Selection := Chr(65 + ColNo) + inttostr(RowNo)
      else
        FGrid.Selection := Chr(65 + (ColNo div 26)) + Chr(65 + (ColNo mod 26)) + inttostr(FCurrentRow);

      FGrid.GetSelection(0, pRow1, pCol1, pRow2, pCol2);
      if (pRow1 < pRow2) and (pRow1 = RowNo) then
      begin
        Temp := 0;
        for J := pRow1 to pRow2 do
          Temp := Temp + Round(RMConvertToPixels1(FGrid.RowHeight[J] / 1440 * FGrid.ViewScale / 100));
        liView.spHeight := temp;
      end
      else
        liView.spHeight := liHeight;
      if (pCol1 < pCol2) and (pCol1 = ColNo + 1) then
      begin
        Temp := 0;
        for J := pCol1 to pCol2 do
          Temp := Temp + Round(RMConvertToPixels1(FGrid.ColWidthtwips[J] / 1440 * FGrid.ViewScale / 100)) + 1;
        liView.spWidth := Temp;
      end
      else
        liView.spWidth := Round(RMConvertToPixels1(FGrid.ColWidthtwips[ColNo + 1] / 1440 * FGrid.ViewScale / 100)) + 1;

      //对齐方式
      FGrid.SetActiveCell(RowNo, ColNo + 1);
      Cellformat := FGrid.GetCellFormat;
      if CellFormat.AlignHorizontal = F1HAlignCenter then
        LiView.HAlign := rmhCenter;
      if CellFormat.AlignHorizontal = F1HalignRight then
        LiView.HAlign := rmhRight;
      if CellFormat.AlignHorizontal = F1HAlignLeft then
        LiView.HAlign := rmhLeft;
      {//垂直排列}
      if CellFormat.AlignVertical = F1VAlignTop then
        LiView.VAlign := rmvTop;
      if CellFormat.AlignVertical = F1VAlignCenter then
        LiView.VAlign := rmvCenter;
      if CellFormat.AlignVertical = F1VAlignBottom then
        LiView.VAlign := rmvBottom;
      //
      if CellFormat.AlignHorizontal = F1HAlignGeneral then
        if IsNumber(s) then
          LiView.HAlign := rmhRight
        else
          LiView.HAlign := rmhLeft;

     //字体
      LiView.Font.Name := CellFormat.FontName;
      LiView.Font.Size := CellFormat.FontSize;
      LiView.Font.Color := CellFormat.FontColor;
      Liview.Font.Style := [];
      if CellFormat.FontBold then
        Liview.Font.Style := LiView.Font.style + [fsBold];
      if CellFormat.FontItalic then
        Liview.Font.Style := LiView.Font.style + [fsItalic];
      if CellFormat.FontUnderline then
        Liview.Font.Style := LiView.Font.style + [fsUnderline];
      if CellFormat.FontStrikeout then
        Liview.Font.Style := LiView.Font.style + [fsStrikeOut];

 //画表格线
      FGrid.GetSelection(0, pRow1, pCol1, pRow2, pCol2);
      liView.LeftFrame.Visible := False;
      liView.TopFrame.Visible := False;
      liView.RightFrame.Visible := False;
      liView.BottomFrame.Visible := False;
      if RowNo = PRow1 then
        if cellformat.BorderStyle[F1TopBorder] > 0 then
          liView.TopFrame.Visible := True;
      if ColNo + 1 = PCol1 then
        if cellformat.BorderStyle[F1LeftBorder] > 0 then
          liView.LeftFrame.Visible := True;
      if RowNo = PRow2 then
        if cellformat.BorderStyle[F1BottomBorder] > 0 then
          liView.BottomFrame.Visible := True;
      if ColNo + 1 = PCol2 then
        if cellformat.BorderStyle[F1RightBorder] > 0 then
          liView.RightFrame.Visible := True;
    end;
  end;
begin
  FixCount := 0;
  for i := 0 to FList.Count - 1 do
  begin
    //处理固定列
    S1 := Copy(FList[i], Pos('$', Flist[i]), Length(Flist[i]) - Pos('$', Flist[i]) + 1);
    if S1[1] = '$' then
    begin
      Inc(FixCount);
      FindandSetMemo(FCurrentRow, StrToInt(Copy(S1, 2, Length(S1) - 1)) - 1, Copy(FList[i], 1, Length(Flist[i]) - 2));
    end
    else
    begin
      if FixCount <= FFormReport.GridFixedCols then
        FindandSetMemo(FCurrentRow, I, FList[i])
      else
        FindandSetMemo(FCurrentRow, I - FixCount + FFormReport.GridFixedCols, FList[i]);
    end;
  end;
end;

function IsNumber(S: string): boolean;
const
  Number = ['0'..'9', '.'];
var
  I, j: integer;
begin
  Result := True;
  if s = '' then
    Result := False;
  if Pos('-', s) = 1 then
  begin
    Result := True;
    system.Delete(s, 1, 1);
  end;
  j := 0;
  for i := 1 to Length(S) do
  begin
    if not (S[i] in Number) then
    begin
      Result := False;
      break;
    end
    else
    begin
      if S[i] = '.' then
        j := j + 1;
      if j > 1 then
      begin
        Result := False;
        break;
      end;
    end;
  end;
end;

function RMConvertToPixels1(Avalue: extended): extended;
begin
  Result := Avalue * RMPixPerInchX;
end;

procedure Register;
begin
  RegisterComponents('Report Machine', [TRMPrintF1Book]);
end;
initialization
  RMRegisterFormReportControl(TF1book6, TRMPrintF1book6);
end.

