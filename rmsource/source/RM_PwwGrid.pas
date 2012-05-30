
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{             wwdbgrid report             }
{                                         }
{*****************************************}

unit RM_PwwGrid;

interface

{$I RM.inc}
{$IFDEF InfoPower}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Stdctrls,
  Printers, DB, Wwdbigrd, Wwdbgrid, wwDataInspector, RM_Class, RM_DataSet,
  RM_Parser, RM_wwRichEdit, RM_FormReport;

type
  TRMwwGridReport = class(TComponent) // fake component
  end;

 { TRMPrintwwSpinEdit }
  TRMPrintwwSpinEdit = class(TRMPrintEdit)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

 { TRMPrintwwDBCheckBox }
  TRMPrintwwDBCheckBox = class(TRMPrintCheckBox)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

 { TRMPrintwwRichEdit }
  TRMPrintwwRichEdit = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintwwDBGrid }
  TRMPrintwwDBGrid = class(TRMFormReportObject)
  private
    FDBGrid: TwwCustomDBGrid;
    FParentReport: TRMReport;
    procedure OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

{$ENDIF}
implementation

{$IFDEF InfoPower}
uses Wwcommon, wwriched, wwdbedit, wwdblook, wwcheckbox, wwdbdatetimepicker,
  RM_Utils;

type
  THackwwDBGrid = class(TwwDBGrid)
  end;

  THackFormReport = class(TRMFormReport)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintwwSpinEdit}

procedure TRMPrintwwSpinEdit.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
  dataset: TDataSet;
begin
  inherited;
  if aControl is TwwDBCustomEdit then
  begin
    try
      ds := TwwDBCustomEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(ds.DataSet).Name, TwwDBCustomEdit(aControl).DataField]);
    except
    end;
  end
  else if aControl is TwwDBCustomLookupCombo then
  begin
    try
      ds := TwwDBCustomLookupCombo(aControl).DataSource;
      if ds <> nil then
        t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(ds.DataSet).Name, TwwDBCustomLookupCombo(aControl).DataField])
      else
      begin
        dataset := TwwDBCustomLookupCombo(aControl).LookupTable;
        t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(dataset).Name,
          RMGetOneField(TwwDBCustomLookupCombo(aControl).LookupField)]);
      end;
    except
    end;
  end
  else if aControl is TwwDBCustomDateTimePicker then
  begin
    try
      ds := TwwDBCustomDateTimePicker(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(ds.DataSet).Name,
        TwwDBCustomDateTimePicker(aControl).DataField]);
    except
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMPrintwwDBCheckBox.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  inherited;
  try
    ds := TwwDBCustomCheckBox(aControl).DataSource;
    t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(ds.DataSet).Name, TwwDBCustomCheckBox(aControl).DataField]);
  except
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintwwRichEdit}

procedure TRMPrintwwRichEdit.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtAddin, 'TRMwwRichView');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + THackFormReport(aFormReport).OffsX;
  t.spTop := aControl.Top + THackFormReport(aFormReport).OffsY;
  t.spWidth := aControl.Width + 2;
  t.spHeight := aControl.Height + 2;
  if (aControl is TwwDBRichEdit) and (TwwDBRichEdit(aControl).DataSource <> nil) and
    (TwwDBRichEdit(aControl).DataField <> '') then
  begin
    try
      ds := TwwDBRichEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(ds.DataSet).Name, TwwDBRichEdit(aControl).DataField]);
    except
    end;
  end
  else
    TRMwwRichView(t).LoadFromRichEdit(TwwDBRichEdit(aControl));

  if rmgoDrawBorder in aFormReport.ReportOptions then
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

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintwwDBGrid}

procedure TRMPrintwwDBGrid.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
var
  i: Integer;
  lBookmark: TBookmark;
begin
  if (Band.BandType = rmbtMasterData) and (not FParentReport.Flag_TableEmpty) then
  begin
    PrintBand := False;
    lBookmark := THackwwDBGrid(FDBGrid).DataSource.DataSet.GetBookmark;
    try
      for i := 0 to THackwwDBGrid(FDBGrid).SelectedList.Count - 1 do
      begin
        if THackwwDBGrid(FDBGrid).DataSource.DataSet.CompareBookmarks(TBookmark(THackwwDBGrid(FDBGrid).SelectedList[i]), lBookmark) = 0 then
        begin
          PrintBand := True;
          Break;
        end;
      end;
    finally
      THackwwDBGrid(FDBGrid).DataSource.DataSet.FreeBookmark(lBookmark);
    end;
  end;
end;

procedure TRMPrintwwDBGrid.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, tmpx, tmpx0, NextTop: Integer;
  liDBGrid: THackwwDBGrid;
  DSet: TDataSet;
  str: string;
  liPage: TRMReportPage;
  liPageNo, liNum, liGridTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liLastGroupName: string;
  liRowHeight: Integer;

  function _GetColumnWidth(aIndex: Integer; aColumn: TwwColumn): Integer;
  begin
    if dgIndicator in liDBGrid.Options then
      Inc(aIndex);
    Result := liDBGrid.ColWidths[aIndex];
//    if liDBGrid.UseTFields and (DSet.FindField(aColumn.FieldName) <> nil) then
//      Result := DSet.FindField(aColumn.FieldName).DisplayWidth * liDBGrid.Canvas.TextWidth('0') + 4
//    else
//      Result := aColumn.DisplayWidth * liDBGrid.Canvas.TextWidth('0') + 4;
  end;

  function _GetCustomEditControl(aParamters: string): TComponent;
  begin
    Result := nil;
    if Pos(';', aParamters) > 0 then
    begin
      aParamters := Copy(aParamters, 1, Pos(';', aParamters) - 1);
      Result := liDBGrid.Parent.FindComponent(aParamters);
    end;
  end;

  procedure _MakeDataInspectorObject(liDataInspector: TwwDataInspector; aWidth: Integer);
  var
    i: Integer;
    liDSet: TDataSet;
    liView, liView1: TRMView;
    liDefaultRowHeight: Integer;
  begin
    if liDataInspector.DefaultRowHeight <= 0 then
      liDefaultRowHeight := liDataInspector.Canvas.TextHeight('0') + 4
    else
      liDefaultRowHeight := liDataInspector.DefaultRowHeight + 1;

    for i := 0 to liDataInspector.Items.Count - 1 do
    begin
     // Caption
      liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      liView.ParentPage := liPage;
      liView.Memo.Text := liDataInspector.Items[i].Caption;
      TRMMemoView(liView).HAlign := rmhCenter;
      TRMMemoView(liView).VAlign := rmvCenter;
      aFormReport.AssignFont(TRMMemoView(liView), liDataInspector.CaptionFont);
      if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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
      liView.spTop := liDefaultRowHeight * i;
      liView.spWidth := liDataInspector.CaptionIndent + liDataInspector.CaptionWidth + 1;
      liView.spHeight := liDefaultRowHeight;
      if rmgoUseColor in aFormReport.ReportOptions then
        liView.FillColor := liDataInspector.CaptionColor;
      aFormReport.PageDetailViews.Add(liView);

      // DataField
      liDSet := liDataInspector.Items[i].DataSource.DataSet;
      liView1 := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      liView1.ParentPage := liPage;
      liView1.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(liDSet).Name, liDataInspector.Items[i].DataField]);
      case liDataInspector.Items[i].Alignment of
        taLeftJustify: TRMMemoView(liView1).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView1).HAlign := rmhRight;
        taCenter: TRMMemoView(liView1).HAlign := rmhCenter;
      end;
      TRMMemoView(liView1).VAlign := rmvCenter;
      aFormReport.AssignFont(TRMMemoView(liView1), liDataInspector.Font);
      if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
      begin
        liView1.LeftFrame.Visible := True;
        liView1.TopFrame.Visible := True;
        liView1.RightFrame.Visible := True;
        liView1.BottomFrame.Visible := True;
      end
      else
      begin
        liView1.LeftFrame.Visible := False;
        liView1.TopFrame.Visible := False;
        liView1.RightFrame.Visible := False;
        liView1.BottomFrame.Visible := False;
      end;

      liView1.spLeft := tmpx + liView.spWidth;
      liView1.spTop := liView.spTop;
      liView1.spWidth := liDataInspector.Width - liView.spWidth + 1;
      liView1.spHeight := liView.spHeight;
      if rmgoUseColor in aFormReport.ReportOptions then
        liView1.FillColor := liDataInspector.Color;
      aFormReport.PageDetailViews.Add(liView1);
    end;
    tmpx := tmpx + aWidth;
    liFlagFirstColumn := False;
  end;

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
      t.GapLeft := 0; t.GapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      TRMMemoView(t).Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure MakeOneHeader(aIndex: Integer);
  var
    liColumn, liColumn1: TwwColumn;
    i: Integer;
  begin
    liColumn := liDBGrid.Columns[aIndex];
    if (liColumn.GroupName <> '') and (liLastGroupName <> liColumn.GroupName) then
    begin
      liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      liView.ParentPage := liPage;
      str := liColumn.GroupName;
      while Pos('~', str) <> 0 do
        str[Pos('~', str)] := #13;
      liView.Memo.Text := str;
      liView.spLeft := tmpx;
      liView.spTop := NextTop;
      liView.spWidth := 0;
      for i := aIndex to liDBGrid.Selected.Count - 1 do
      begin
        liColumn1 := liDBGrid.Columns[i];
        if liColumn1.GroupName <> liColumn.GroupName then
          Break;
        if THackFormReport(aFormReport).CalcWidth(liView.spLeft + liView.spWidth + _GetColumnWidth(i, liColumn1) + 1) > THackFormReport(aFormReport).PageWidth then // 超宽
          Break;
        liView.spWidth := liView.spWidth + _GetColumnWidth(i, liColumn1) + 1;
      end;
      liView.spHeight := liGridTitleHeight div 2;

      if rmgoUseColor in aFormReport.ReportOptions then
        liView.FillColor := liDBGrid.TitleColor;
      if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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

      TRMMemoView(liView).HAlign := rmhCenter;
      TRMMemoView(liView).VAlign := rmvCenter;
      aFormReport.ColumnHeaderViews.Add(liView);
    end;

    liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    liView.ParentPage := liPage;
    str := liColumn.DisplayLabel;
    while Pos('~', str) <> 0 do
      str[Pos('~', str)] := #13;
    liView.Memo.Text := str;
    liView.spLeft := tmpx;
    liView.spWidth := _GetColumnWidth(aIndex, liColumn) + 1;
    if liColumn.GroupName <> '' then
    begin
      liView.spTop := NextTop + liGridTitleHeight div 2;
      liView.spHeight := liGridTitleHeight - liGridTitleHeight div 2;
    end
    else
    begin
      liView.spHeight := liGridTitleHeight;
      liView.spTop := NextTop;
    end;
    aFormReport.AssignFont(TRMMemoView(liView), liDBGrid.TitleFont);
    TRMMemoView(liView).VAlign := rmvCenter;
    case liDBGrid.TitleAlignment of
      taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
      taCenter: TRMMemoView(liView).HAlign := rmhCenter;
    end;
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liDBGrid.TitleColor;
    if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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
    liLastGroupName := liColumn.GroupName;
  end;

  procedure MakeOneDetail(aIndex: Integer);
  var
    liColumn: TwwColumn;
    liControlType, liParameters: string;
    liComponent: TComponent;
  begin
    liColumn := liDBGrid.Columns[aIndex];
    liDBGrid.GetControlInfo(liColumn.FieldName, liControlType, liParameters);
    liControlType := Uppercase(liControlType);
    liView := nil;
    if liControlType = 'CUSTOMEDIT' then
    begin
      liComponent := _GetCustomEditControl(liParameters);
      if liComponent <> nil then
      begin
        if liComponent is TwwCustomRichEdit then
          liControlType := 'RICHEDIT'
        else if AnsiCompareText(liComponent.ClassName, 'TDBImage') = 0 then
          liControlType := 'BITMAP'
        else if AnsiCompareText(liComponent.ClassName, 'TwwDataInspector') = 0 then
        begin
          _MakeDataInspectorObject(TwwDataInspector(liComponent), _GetColumnWidth(aIndex, liColumn) + 1);
          Exit;
        end;
      end;
    end;

    if liControlType = 'BITMAP' then
    begin
      liView := TRMPictureView(RMCreateObject(rmgtPicture, ''));
      liView.ParentPage := liPage;
      liView.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(DSet).Name, liColumn.FieldName]);
      TRMPictureView(liView).PictureCenter := True;
      TRMPictureView(liView).PictureRatio := True;
      TRMPictureView(liView).PictureStretched := True;
//      TRMPictureView(liView).BandAlign := rmbaHeight;
    end
    else if liControlType = 'RICHEDIT' then
    begin
      liView := TRMwwRichView(RMCreateObject(rmgtAddin, 'TRMwwRichView'));
      liView.ParentPage := liPage;
      TRMwwRichView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
      TRMwwRichView(liView).RichEdit.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(DSet).Name, liColumn.FieldName]);
    end;

    if liView = nil then
    begin
      liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
      liView.ParentPage := liPage;
      TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
      aFormReport.AssignFont(TRMMemoView(liView), liDBGrid.Font);
      if aFormReport.GridFontOptions.UseCustomFontSize then
        TRMMemoView(liView).Font.Size := aFormReport.GridFontOptions.Font.Size;
      liView.Memo.Text := Format('[%s."%s"]', [THackFormReport(aFormReport).AddRMDataSet(DSet).Name, liColumn.FieldName]);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).WordWrap := rmgoWordWrap in aFormReport.ReportOptions;
      case DSet.Fields[aIndex].Alignment of
        taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
        taCenter: TRMMemoView(liView).HAlign := rmhCenter;
      end;
      THackFormReport(aFormReport).SetMemoViewFormat(TRMMemoView(liView), DSet.Fields[aIndex]);
    end;
    if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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
    liView.spWidth := _GetColumnWidth(aIndex, liColumn) + 1;
    liView.spHeight := liRowHeight;
    if rmgoUseColor in aFormReport.ReportOptions then
      liView.FillColor := liDBGrid.Color;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, DSet.Fields[aIndex].FieldName, liView);

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
    SaveGroupName: string;
  begin
    SaveGroupName := liLastGroupName; liLastGroupName := '';
    for i := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if i < liDBGrid.Selected.Count - 1 then
        MakeOneHeader(i);
    end;
    liLastGroupName := SaveGroupName;
  end;

  procedure DrawFixedColDetail;
  var
    i: Integer;
  begin
    for i := 0 to aFormReport.GridFixedCols - 1 do
    begin
      if i < liDBGrid.Selected.Count - 1 then
        MakeOneDetail(i);
    end;
  end;

begin
  if aFormReport.DrawOnPageFooter then Exit;

  FParentReport := aFormReport.Report;
  liDBGrid := THackwwDBGrid(aControl);
  if (liDBGrid.Datasource = nil) or (liDBGrid.Datasource.Dataset = nil) then Exit;
  if not liDBGrid.Datasource.Dataset.Active then Exit;

  FDBGrid := liDBGrid;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (liDBGrid.SelectedList.Count > 0) then //只打印选择的记录
  begin
    AutoFree := False;
    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := THackFormReport(aFormReport).OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  liGridTitleHeight := 0;
  NextTop := aControl.Top + THackFormReport(aFormReport).OffsY;
  aFormReport.MainDataSet := THackFormReport(aFormReport).AddRMDataSet(liDBGrid.DataSource.DataSet);
//  aFormReport.ReportDataSet.DataSet := liDBGrid.DataSource.DataSet;

  liRowHeight := liDBGrid.DefaultRowHeight + 4;
  if aFormReport.MasterDataBandOptions.Height > 0 then
    liRowHeight := aFormReport.MasterDataBandOptions.Height;

  DSet := liDBGrid.Datasource.Dataset;
  tmpx := 0;
  for i := 0 to liDBGrid.Selected.Count - 1 do
  begin
    tmpx := tmpx + _GetColumnWidth(i, liDBGrid.Columns[i]) + 1;
  end;

  if (dgTitles in liDBGrid.Options) and (rmgoGridNumber in aFormReport.ReportOptions) then
    tmpx := tmpx + RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;

  if (aFormReport.PrintControl = aControl) or (tmpx > StrToInt(THackFormReport(aFormReport).FormWidth[0])) then
    THackFormReport(aFormReport).FormWidth[0] := IntToStr(tmpx + (THackFormReport(aFormReport).OffsX + aControl.Left) * 2);

  liLastGroupName := '';
  if dgTitles in liDBGrid.Options then //表头
  begin
    liFlagFirstColumn := True;
    liGridTitleHeight := liDBGrid.RowHeights[0] + 4;
    tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
    if rmgoGridNumber in aFormReport.ReportOptions then
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := aPage;
      liView.spLeft := tmpx;
      liView.spTop := NextTop;
      liView.spWidth := RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;
      liView.spHeight := liGridTitleHeight;
      liView.Memo.Add(aFormReport.GridNumOptions.Text);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).HAlign := rmhCenter;
      if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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

    liPage := aPage; liNum := 0;
    tmpx0 := tmpx;
    for i := 0 to liDBGrid.GetColCount - 2 do
    begin
      if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (_GetColumnWidth(i, liDBGrid.Columns[i]) + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
        begin
          liLastGroupName := '';
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

      MakeOneHeader(i);
      Inc(liNum);
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);

  liLastGroupName := '';
  liPage := aPage; //表体
  tmpx := aControl.Left + THackFormReport(aFormReport).OffsX;
  liFlagFirstColumn := True;
  if rmgoGridNumber in aFormReport.ReportOptions then
  begin
    liView := RMCreateObject(rmgtMemo, '');
    liView.ParentPage := aPage;
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := RMCanvasHeight('a', liDBGrid.Font) * aFormReport.GridNumOptions.Number;
    liView.spHeight := liRowHeight;
    liView.Memo.Add('[_RM_Line]');
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HAlign := rmhCenter;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    if (rmgoGridLines in aFormReport.ReportOptions) and (dgColLines in liDBGrid.Options) then
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
  liNum := 0; liPageNo := 0;
  for i := 0 to liDBGrid.GetColCount - 2 do
  begin
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (THackFormReport(aFormReport).CalcWidth(tmpx + (_GetColumnWidth(i, liDBGrid.Columns[i]) + 1)) > THackFormReport(aFormReport).PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.Width := 2;

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
      liView.RightFrame.Width := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    THackFormReport(aFormReport).FormWidth[THackFormReport(aFormReport).FormWidth.Count - 1] := IntToStr(tmpx);
end;

initialization
  RMRegisterFormReportControl(TwwCustomRichEdit, TRMPrintwwRichEdit);
  RMRegisterFormReportControl(TwwCustomDBGrid, TRMPrintwwDBGrid);
  RMRegisterFormReportControl(TwwDBCustomEdit, TRMPrintwwSpinEdit);
  RMRegisterFormReportControl(TwwDBCustomCheckBox, TRMPrintwwDBCheckBox);

{$ENDIF}
end.

