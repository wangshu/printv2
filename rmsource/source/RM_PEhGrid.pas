
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{             EHLib report                }
{                                         }
{*****************************************}

unit RM_PEHGrid;

interface

{$I RM.INC}
{$IFDEF EHLib}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Stdctrls,
  Grids, DBGrids, DBGridEh, Printers, Db,
  RM_Common, RM_Class, RM_DataSet, RM_FormReport, RM_Parser;

type
  TRMPrintEHLib = class(TComponent) // fake component
  end;

 { TRMPrintEHGrid }
  TRMPrintEHGrid = class(TRMFormReportObject)
  private
    FPrintDoubleFrame: Boolean;
    FFormReport: TRMFormReport;
    FPage: TRMReportPage;
    FDBGridEh: TCustomDBGridEh;
    FParentReport: TRMReport;
    procedure PrintMultiTitle;
    procedure OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
    procedure PrintSimpleTitle;
  protected
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

{$ENDIF}
implementation

{$IFDEF EHLib}
uses RM_CheckBox, RM_Utils;

type
  THackGrid = class(TCustomDBGridEh)
  end;

  THackFormReport = class(TRMFormReport)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintEHGrid}

procedure TRMPrintEHGrid.PrintMultiTitle;
var
  liLeft0, liTop0: Integer;
  liNextX, liLastX, liNextY, liLeftX, liRightX: Integer;
  liPage: TRMReportPage;
  liNum: Integer;
  liSaveNode: THeadTreeNode;
  liFlagFirstColumn: Boolean;
  liLevel: Integer;
  liMinx: Integer;
  t, t1: TRMMemoView;
  i: Integer;
  SaveLeftList: TStringList;

  procedure _MakeOneHeader(aNode: THeadTreeNode);
  begin
    liSaveNode := aNode;
    t := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    t.ParentPage := liPage;
    if (rmgoGridLines in FFormReport.ReportOptions) and (dgColLines in THackGrid(FDBGridEh).Options) then
    begin
      t.LeftFrame.Visible := True;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := True;
      t.BottomFrame.Visible := True;
    end
    else
    begin
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := False;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
    end;

    TRMMemoView(t).WordWrap := True;
    TRMMemoView(t).LineSpacing := 0;
    TRMMemoView(t).VAlign := rmvCenter;
    if Assigned(aNode.Column) then
    begin
{$IFDEF EHLib20}
      if aNode.Column.Title.Orientation = tohVertical then
        TRMMemoView(t).RotationType := rmrt90;
{$ENDIF}
      case aNode.Column.Title.Alignment of
        taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(t).HAlign := rmhRight;
        taCenter: TRMMemoView(t).HAlign := rmhCenter;
      end;
    end
    else
      TRMMemoView(t).HAlign := rmhCenter;

    if liNextX < liLeftX then
      t.SetspBounds(liLeftX, liNextY, aNode.Width + 1 + (liNextX - liLeftX), aNode.Height)
    else
    begin
      if liNextX + aNode.Width + 1 > liRightX then
        t.SetspBounds(liNextX, liNextY, (liRightX - liNextX), aNode.Height)
      else
        t.SetspBounds(liNextX, liNextY, aNode.Width + 1, aNode.Height);
    end;

    t.Memo.Add(aNode.Text);
    if Assigned(aNode.Column) then
      FFormReport.AssignFont(t, aNode.Column.Title.Font)
    else
      FFormReport.AssignFont(t, THackGrid(FDBGridEh).TitleFont);

    FFormReport.ColumnHeaderViews.Add(t);

    if (liLevel <= 0) and FPrintDoubleFrame then
      t.TopFrame.Width := 2;
    if FPrintDoubleFrame then
    begin
      if liFlagFirstColumn then liMinx := liNextX;
      if liFlagFirstColumn or (liMinx >= liNextX) then
        t.LeftFrame.Width := 2;
    end;
    liFlagFirstColumn := False;

    liLastX := liNextX;
    liNextX := liNextX + aNode.Width + 1;
  end;

  procedure _ShowParentNode(aNode: THeadTreeNode);
  var
    SaveY: Integer;
    i: Integer;
  begin
    SaveY := liNextY;
    i := SaveLeftList.Count - 1;
    while (aNode <> nil) and (aNode.Text <> 'Root') do
    begin
      Dec(liLevel);
      liNextY := liNextY - aNode.Height;
      if i >= 0 then
        liNextX := StrToInt(SaveLeftList[i])
      else
        liNextX := liLastX;
      if aNode.Width > 0 then _MakeOneHeader(aNode);
      if FPrintDoubleFrame then
        t.RightFrame.Width := 2;
      aNode := aNode.Host;
      Dec(i);
    end;
    liNextY := SaveY;
  end;


  procedure _DrawHeader(aNode: THeadTreeNode; aCount: Integer);
  var
    htLast: THeadTreeNode;
    liCount: Integer;
    liFlag: Boolean;

    procedure _ShowOneColumn(aNode: THeadTreeNode);
    var
      SaveY: Integer;
      SaveLevel: Integer;
      i: Integer;
    begin
      if (FFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not FFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (THackFormReport(FFormReport).CalcWidth(liNextX + aNode.Width + 1) > THackFormReport(FFormReport).PageWidth) then // 超宽
        begin
          SaveLevel := liLevel;
          liNum := 0;
          liRightX := liNextX;
          if FPrintDoubleFrame then
            t.RightFrame.Width := 2;

          if aNode.Host = liSaveNode.Host then
            _ShowParentNode(liSaveNode.Host);
          liRightX := 9999999;
          THackFormReport(FFormReport).FormWidth[FFormReport.Report.Pages.Count - 1] := IntToStr(liNextX);
          THackFormReport(FFormReport).AddPage;
          THackFormReport(FFormReport).FormWidth.Add('0');
          liPage := TRMReportPage(FFormReport.Report.Pages[FFormReport.Report.Pages.Count - 1]);
          liNextX := liLeft0; liLeftX := liLeft0;
          for i := 0 to SaveLeftList.Count - 1 do
            SaveLeftList[i] := IntToStr(liLeft0);

          liFlagFirstColumn := True;
          if FFormReport.GridFixedCols > 0 then
          begin
            SaveY := liNextY; liNextY := liTop0;
            liLevel := 0;
            _DrawHeader(FDBGridEh.HeadTree, FFormReport.GridFixedCols);
            liNextY := SaveY;
            liLeftX := liNextX;
          end;

          liLevel := SaveLevel;
        end;
      end;

      _MakeOneHeader(aNode);
      Inc(liNum);
    end;

  begin
    liCount := 0;
    htLast := aNode.Child;
    liFlag := True;
    while liFlag do
    begin
      if htLast.Child <> nil then
      begin
        liNextY := liNextY + htLast.Height;
        Inc(liLevel);
        SaveLeftList.Add(IntToStr(liNextX));
        _DrawHeader(htLast, aCount);
        Dec(liLevel);
      end;

      if htLast <> nil then
      begin
        Inc(liCount);
        if htLast.Width > 0 then _ShowOneColumn(htLast);
        if (aCount > 0) and (liCount >= aCount) then
          liFlag := False;
      end;

      if aNode.Child = htLast.Next then
      begin
        liNextY := liNextY - aNode.Height;
        liNextX := liNextX - aNode.Width - 1;
        Break;
      end;
      htLast := htLast.Next;
    end;
    if SaveLeftList.Count > 0 then
      SaveLeftList.Delete(SaveLeftList.Count - 1);
  end;

begin
  liSaveNode := nil;
  liLeft0 := FDBGridEh.Left + THackFormReport(FFormReport).OffsX;
  liTop0 := FDBGridEh.Top + THackFormReport(FFormReport).OffsY;
  liNextX := liLeft0; liNextY := liTop0; liLastX := liNextX;
  liLeftX := liLeft0;
  liRightX := 9999999; liNum := 0;
  liPage := FPage;
  liFlagFirstColumn := True;
  liLevel := 0;
  SaveLeftList := TStringList.Create;
  _DrawHeader(FDBGridEh.HeadTree, -1);

  if FPrintDoubleFrame then
  begin
    t.RightFrame.Width := 2;
    for i := liPage.Objects.Count - 1 downto 0 do
    begin
      t1 := liPage.Objects[i];
      if t1.spLeft + t1.spWidth = t.spLeft + t.spWidth then
        t1.RightFrame.Width := 2
      else
        Break;
    end;
  end;
  SaveLeftList.Free;
end;

procedure TRMPrintEHGrid.PrintSimpleTitle;
var
  i, liTitleHeight: Integer;
  liNextX, liNextY: Integer;
  liPage: TRMReportPage;
  liNum: Integer;
  t: TRMMemoView;
  tmpx0: Integer;
  liFlagFirstColumn: Boolean;

  procedure _MakeOneHeader(aIndex: Integer);
  begin
    t := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    t.ParentPage := liPage;
    if (rmgoGridLines in FFormReport.ReportOptions) and (dgColLines in THackGrid(FDBGridEh).Options) then
    begin
      t.LeftFrame.Visible := True;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := True;
      t.BottomFrame.Visible := True;
    end
    else
    begin
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := False;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
    end;

    TRMMemoView(t).WordWrap := True;
    TRMMemoView(t).LineSpacing := 0;
{$IFDEF EHLib20}
    if FDBGridEh.Columns[aIndex].Title.Orientation = tohVertical then
      t.RotationType := rmrt90;
{$ENDIF}
    t.VAlign := rmvCenter;
    case THackGrid(FDBGridEh).Columns[aIndex].Title.Alignment of
      taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(t).HAlign := rmhRight;
      taCenter: TRMMemoView(t).HAlign := rmhCenter;
    end;
    t.SetspBounds(liNextX, liNextY, THackGrid(FDBGridEh).Columns[aIndex].Width + 1, liTitleHeight);
    t.Memo.Add(THackGrid(FDBGridEh).Columns[aIndex].Title.Caption);
    FFormReport.AssignFont(t, THackGrid(FDBGridEh).Columns[aIndex].Title.Font);

    FFormReport.ColumnHeaderViews.Add(t);
    liNextX := liNextX + t.spWidth;

    if FPrintDoubleFrame then
    begin
      if liFlagFirstColumn then
        t.LeftFrame.Width := 2;
      t.TopFrame.Width := 2;
    end;
    liFlagFirstColumn := False;
  end;

  procedure _DrawFixedColHeader;
  var
    i: Integer;
  begin
    for i := 0 to FFormReport.GridFixedCols - 1 do
    begin
      if not THackGrid(FDBGridEh).Columns[i].Visible then Continue;
      if i < THackGrid(FDBGridEh).Columns.Count then _MakeOneHeader(i);
    end;
  end;

begin
  liNextX := FDBGridEh.Left + THackFormReport(FFormReport).OffsX;
  liNextY := FDBGridEh.Top + THackFormReport(FFormReport).OffsY;
  liTitleHeight := THackGrid(FDBGridEh).RowHeights[0] + 4;
  liPage := FPage;
  liNum := 0; tmpx0 := liNextX;
  liFlagFirstColumn := True;
  for i := 0 to THackGrid(FDBGridEh).Columns.Count - 1 do
  begin
    if not THackGrid(FDBGridEh).Columns[i].Visible then Continue;

    if (FFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not FFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(FFormReport).CalcWidth(liNextX + (THackGrid(FDBGridEh).Columns[i].Width + 1)) > THackFormReport(FFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if FPrintDoubleFrame then
          t.RightFrame.Width := 2;

        THackFormReport(FFormReport).FormWidth[FFormReport.Report.Pages.Count - 1] := IntToStr(liNextX);
        THackFormReport(FFormReport).AddPage;
        THackFormReport(FFormReport).FormWidth.Add('0');
        liPage := TRMReportPage(FFormReport.Report.Pages[FFormReport.Report.Pages.Count - 1]);
        liNextX := tmpx0;
        liFlagFirstColumn := True;
        _DrawFixedColHeader;
      end;
    end;

    _MakeOneHeader(i);
    Inc(liNum);
  end;

  liFlagFirstColumn := True;
  if FPrintDoubleFrame then
    t.RightFrame.Width := 2;

  if FFormReport.Report.Pages.Count > 1 then
    THackFormReport(FFormReport).FormWidth[THackFormReport(FFormReport).FormWidth.Count - 1] := IntToStr(liNextX);
end;

procedure TRMPrintEHGrid.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
begin
  if (Band.BandType = rmbtMasterData) and (not FParentReport.Flag_TableEmpty) and
    (not THackGrid(FDBGridEh).SelectedRows.CurrentRowSelected) then
    PrintBand := False;
end;

procedure TRMPrintEHGrid.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, j, liLeftx: Integer;
  liNextX, liNextY: Integer;
  liDataSet: TDataSet;
  liFooter: TColumnFooterEh;
  liNum, liPageNo, tmpx0: Integer;
  liPage: TRMReportPage;
  liFlagFirstColumn: Boolean;
  liRowHeight: Integer;

  procedure _DrawDoubleFrameBottom(aView: TRMView; aList: TList);
  var
    t: TRMMemoView;
  begin
    if FPrintDoubleFrame then
    begin
      t := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      t.ParentPage := liPage;
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
      t.RightFrame.Visible := False;
      t.BottomFrame.Visible := False;
      t.TopFrame.Width := 2;
      t.GapLeft := 0; t.GapTop := 0;
      TRMMemoView(t).SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      TRMMemoView(t).Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure _MakeOneDetail(aIndex: Integer);
  begin
    if THackGrid(FDBGridEh).Columns[aIndex].Checkboxes then
    begin
      liView := RMCreateObject(rmgtAddin, 'TRMCheckBoxView');
      liView.ParentPage := liPage;
      TRMCheckBoxView(liView).CheckStyle := rmcsCheck;
    end
    else
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := liPage;
      TRMMemoView(liView).Stretched := rmgoStretch in FFormReport.ReportOptions;
      TRMMemoView(liView).WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
      TRMMemoView(liView).VAlign := rmvCenter;
      aFormReport.AssignFont(TRMMemoView(liView), THackGrid(FDBGridEh).Columns[aIndex].Font);
      if aFormReport.GridFontOptions.UseCustomFontSize then
        TRMMemoView(liView).Font.Size := aFormReport.GridFontOptions.Font.Size;
      case THackGrid(FDBGridEh).Columns[aIndex].Alignment of
        taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
      else
        TRMMemoView(liView).HAlign := rmhCenter;
      end;
      THackFormReport(aFormReport).SetMemoViewFormat(TRMMemoView(liView), liDataSet.FieldByName(THackGrid(FDBGridEh).Columns[aIndex].FieldName));
    end;

    liView.spLeft := liNextX;
    liView.spTop := 0;
    liView.spWidth := THackGrid(FDBGridEh).Columns[aIndex].Width + 1;
    liView.spHeight := liRowHeight;
    if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in THackGrid(FDBGridEh).Options) then
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
    if THackGrid(FDBGridEh).Columns[aIndex].FieldName <> '' then
      liView.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(liDataSet).Name, THackGrid(FDBGridEh).Columns[aIndex].FieldName]);

    aFormReport.PageDetailViews.Add(liView);
    liNextX := liNextX + THackGrid(FDBGridEh).Columns[aIndex].Width + 1;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, THackGrid(FDBGridEh).Columns[aIndex].FieldName, liView);

    if FPrintDoubleFrame then
    begin
      if liFlagFirstColumn then
        liView.LeftFrame.Width := 2;
    end;
    _DrawDoubleFrameBottom(liView, aFormReport.ColumnFooterViews);
    liFlagFirstColumn := False;
  end;

  procedure MakeOneFooter(aRow, aIndex: Integer);
  var
    lField: string;
  begin
    liFooter := nil;
    if THackGrid(FDBGridEh).Columns[aIndex].Footers.Count > aRow then
      liFooter := THackGrid(FDBGridEh).Columns[aIndex].Footers[aRow]
    else if THackGrid(FDBGridEh).Columns[aIndex].Footers.Count = aRow then
      liFooter := THackGrid(FDBGridEh).Columns[aIndex].Footer;
    if liFooter <> nil then
    begin
      case liFooter.ValueType of
        fvtSum:
          begin
            liView := RMCreateObject(rmgtCalcMemo, '');
            liView.ParentPage := liPage;
            TRMCalcMemoView(liView).CalcOptions.ResetAfterPrint := True;
            TRMCalcMemoView(liView).CalcOptions.CalcType := rmdcSum;
            if liFooter.FieldName <> '' then
              lField := liFooter.FieldName
            else
              lField := liFooter.Column.FieldName;

            liView.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(liDataSet).Name, lField]);
            THackFormReport(aFormReport).SetMemoViewFormat(TRMMemoView(liView), liDataSet.FieldByName(lField));
          end;
        fvtCount:
          begin
            liView := RMCreateObject(rmgtCalcMemo, '');
            liView.ParentPage := liPage;
            TRMCalcMemoView(liView).CalcOptions.ResetAfterPrint := True;
            TRMCalcMemoView(liView).CalcOptions.CalcType := rmdcCount;
          end;
      else
        liView := RMCreateObject(rmgtMemo, '');
        liView.ParentPage := liPage;
        liView.Memo.Text := liFooter.Value;
      end;
    end
    else
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := liPage;
    end;

    liView.spLeft := liNextX;
    liView.spTop := liNexty;
    liView.spWidth := THackGrid(FDBGridEh).Columns[aIndex].Width + 1;
    liView.spHeight := liRowHeight;
    TRMMemoView(liView).VAlign := rmvCenter;
    if liFooter <> nil then
    begin
      aFormReport.AssignFont(TRMMemoView(liView), liFooter.Font);
      case liFooter.Alignment of
        taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
        taCenter: TRMMemoView(liView).HAlign := rmhCenter;
      end;
    end
    else
    begin
      aFormReport.AssignFont(TRMMemoView(liView), THackGrid(FDBGridEh).Columns[aIndex].Font);
      case THackGrid(FDBGridEh).Columns[aIndex].Alignment of
        taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
        taCenter: TRMMemoView(liView).HAlign := rmhCenter;
      end;
    end;

    if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in THackGrid(FDBGridEh).Options) then
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

    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, THackGrid(FDBGridEh).Columns[aIndex].FieldName, liView);
    aFormReport.GroupFooterViews.Add(liView);
    liNextX := liNextX + THackGrid(FDBGridEh).Columns[aIndex].Width + 1;
  end;

  procedure _DrawFixedColDetail;
  var
    i: Integer;
  begin
    for i := 0 to FFormReport.GridFixedCols - 1 do
    begin
      if not THackGrid(FDBGridEh).Columns[i].Visible then Continue;
      if i < THackGrid(FDBGridEh).Columns.Count then _MakeOneDetail(i);
    end;
  end;

  procedure _DrawFixedColFooter(aRow: Integer);
  var
    j: Integer;
  begin
    for j := 0 to FFormReport.GridFixedCols - 1 do
    begin
      if not THackGrid(FDBGridEh).Columns[j].Visible then Continue;

      if j < THackGrid(FDBGridEh).Columns.Count then
        MakeOneFooter(aRow, j);
    end;
  end;

begin
  FFormReport := aFormReport;
  FDBGridEh := TCustomDBGridEh(aControl);
  FParentReport := aFormReport.Report;
  if not Assigned(FDBGridEh) or not Assigned(THackGrid(FDBGridEh).DataSource) or
    not Assigned(THackGrid(FDBGridEh).DataSource.DataSet) then Exit;
//    or not FDBGridEh.DataSource.DataSet.Active then Exit;

  liDataSet := THackGrid(FDBGridEh).DataSource.DataSet;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (THackGrid(FDBGridEh).SelectedRows.Count > 0) then //只打印选择的记录
  begin
    AutoFree := False;
    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  FPage := TRMReportPage(aFormReport.Report.Pages[0]);
  aFormReport.DrawOnPageFooter := True;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
//  liNextY := aControl.Top + THackFormReport(aFormReport).OffsY;
  aFormReport.MainDataSet := THackFormReport(aFormReport).AddRMDataSet(THackGrid(FDBGridEh).DataSource.DataSet);
//  aFormReport.ReportDataSet.DataSet := THackGrid(FDBGridEh).DataSource.DataSet;
  FPrintDoubleFrame := (rmgoDoubleFrame in aFormReport.ReportOptions) and
    (THackGrid(FDBGridEh).FooterRowCount = 0);

  liRowHeight := THackGrid(FDBGridEh).DefaultRowHeight + 4;
  if aFormReport.MasterDataBandOptions.Height > 0 then
    liRowHeight := aFormReport.MasterDataBandOptions.Height;

  liLeftx := 0;
  for i := 0 to THackGrid(FDBGridEh).Columns.Count - 1 do
  begin
    if THackGrid(FDBGridEh).Columns[i].Visible then
      liLeftx := liLeftX + THackGrid(FDBGridEh).Columns[i].Width + 1;
  end;

  if (aFormReport.PrintControl = aControl) or (liLeftx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(liLeftx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

//表头
  liPage := aPage;
  liNextX := aControl.Left + THackFormReport(aFormReport).OffsX;
  if dgTitles in THackGrid(FDBGridEh).Options then
  begin
    if FDBGridEh.UseMultiTitle then
      PrintMultiTitle
    else
      PrintSimpleTitle;
  end;

// 表体
  liNum := 0; liPageNo := 0;
  liPage := aPage; tmpx0 := lINextX;
  liFlagFirstColumn := True;
  for i := 0 to THackGrid(FDBGridEh).Columns.Count - 1 do
  begin
    if not THackGrid(FDBGridEh).Columns[i].Visible then Continue;
    if (FFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not FFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(FFormReport).CalcWidth(liNextX + (THackGrid(FDBGridEh).Columns[i].Width + 1)) > THackFormReport(FFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if FPrintDoubleFrame then
          liView.RightFrame.Width := 2;

        THackFormReport(FFormReport).FormWidth[liPageNo] := IntToStr(liNextX);
        Inc(liPageNo);
        if liPageNo >= FFormReport.Report.Pages.Count then
        begin
          THackFormReport(FFormReport).AddPage;
          THackFormReport(FFormReport).FormWidth.Add('0');
        end;
        liPage := TRMReportPage(FFormReport.Report.Pages[liPageNo]);
        liNextX := tmpx0;
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
    if FPrintDoubleFrame then
      liView.RightFrame.Width := 2;
  end;

  if FFormReport.Report.Pages.Count > 1 then
    THackFormReport(FFormReport).FormWidth[liPageNo] := IntToStr(liNextX);

  // 统计
  if THackGrid(FDBGridEh).FooterRowCount > 0 then // Footer Row
  begin
    liNextY := 0;
    for i := 0 to THackGrid(FDBGridEh).FooterRowCount - 1 do
    begin
      liPage := aPage; liNum := 0; liPageNo := 0;
      liNextX := aControl.Left + THackFormReport(aFormReport).OffsX;
      for j := 0 to THackGrid(FDBGridEh).Columns.Count - 1 do // 表体
      begin
        if not THackGrid(FDBGridEh).Columns[j].Visible then Continue;
        if (FFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not FFormReport.ScaleMode.FitPageWidth) then
        begin
          if (liNum > 0) and (THackFormReport(FFormReport).CalcWidth(liNextX + (THackGrid(FDBGridEh).Columns[j].Width + 1)) > THackFormReport(FFormReport).PageWidth) then // 超宽
          begin
            liNum := 0;
            Inc(liPageNo);
            liPage := TRMReportPage(FFormReport.Report.Pages[liPageNo]);
            liNextX := tmpx0;
            _DrawFixedColFooter(i);
          end;
        end;

        MakeOneFooter(i, j);
        Inc(liNum);
      end; // end for
      liNextY := liNextY + THackGrid(FDBGridEh).DefaultRowHeight + 4;
    end;
  end;
end;

type
  TRMAddinFunctionLibrary = class(TRMFunctionLibrary)
  public
    constructor Create; override;
    procedure DoFunction(aParser: TRMCustomParser; FNo: Integer; p: array of Variant; var val: Variant); override;
  end;

constructor TRMAddinFunctionLibrary.Create;
begin
  inherited Create;
  with List do
  begin
    Add('GETEHLIBFIELDVALUE');
  end;
end;

procedure TRMAddinFunctionLibrary.DoFunction(aParser: TRMCustomParser; FNo: Integer; p: array of Variant;
  var val: Variant);
var
  lStr1, lStr2, lStr3: string;
begin
  val := '0';
  case FNo of
    0:
      begin
        lStr1 := p[0];
        lStr2 := p[1];
        lStr3 := p[2];
      end;
  end;
end;

initialization
  RMRegisterFormReportControl(TCustomDBGridEh, TRMPrintEHGrid);
  RMRegisterFormReportControl(TDBGridEh, TRMPrintEHGrid);
{$ENDIF}
end.

