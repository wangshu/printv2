unit RM_GridReportMaster;

{$I RM.INC}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls,
  ComCtrls, Dialogs, Menus, RM_Common, RM_Class, RM_DataSet, RM_GridReport,
  RM_Grid, RM_ReportMaster
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  { TRMGridReportMaster }
  TRMGridReportMaster = class(TRMCustomReportMaster)
  private
  protected
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function CreateReport: Boolean; override;
  published
  end;

implementation

uses
  RM_Utils, RM_Const, RM_Const1;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMGridReportMaster }

constructor TRMGridReportMaster.Create(aOwner: TComponent);
begin
  inherited;

  FReport := TRMGridReport.Create(nil);
end;

destructor TRMGridReportMaster.Destroy;
begin
  inherited;
end;

function TRMGridReportMaster.CreateReport: Boolean;
var
  i: Integer;
  lPage: TRMGridReportPage;
  lGrid: TRMGridEx;
  lMaxLevel: Integer;
  lNowCol: Integer;
  lBandColumnHeader: TRMBandColumnHeader;
  lBandMasterData: TRMBandMasterData;
  lDataSetName: string;

  function _GetColumnCount(aNode: TRMTreeNode): Integer;
  begin
    Result := 0;
    while aNode <> nil do
    begin
      if aNode.Count = 0 then
        Inc(Result)
      else
      begin
        Result := Result + _GetColumnCount(aNode.Item[0]);
      end;

      aNode := aNode.GetNextSibling; // 处理下一个兄弟Node
    end;
  end;

  function _GetNodeLevel(aNode: TRMTreeNode): Integer;
  var
    lLevel: Integer;
  begin
    Result := 1;
    lLevel := 1;
    while aNode <> nil do
    begin
      if aNode.Count > 0 then
      begin
        lLevel := _GetNodeLevel(aNode.Item[0]) + 1;
      end;

      if lLevel > Result then
        Result := lLevel;

      lLevel := 1;
      aNode := aNode.GetNextSibling; // 处理下一个兄弟Node
    end;
  end;

  procedure _GenOneNode(aNode: TRMTreeNode; var aNowCol: Integer; aNowRow: Integer);
  var
    lCurCol, lCurRow: Integer;
    lSaveMaxLevel: Integer;

    procedure _SetOneCell(aCol1, aRow1, aCol2, aRow2: Integer; aCreateField: Boolean);
    var
      lCell: TRMCellInfo;
      lColWidth: Integer;
    begin
      lGrid.MergeCell(aCol1, aRow1, aCol2, aRow2);
      lCell := lGrid.Cells[aCol1, aRow1];
      if aCreateField then // 设置列宽
      begin
        lColWidth := 0;
        if aNode.ColumnInfo.Width > 0 then
          lColWidth := aNode.ColumnInfo.Width
        else
        begin
          if FDataSet <> nil then
          begin
            lColWidth := FDataSet.FieldWidth(FReport.Dictionary.RealFieldName[nil, aNode.ColumnInfo.DataFieldName]);
            lColWidth := RMCanvasWidth(StringOfChar('a', lColWidth), aNode.ColumnInfo.DataFont);
          end;
        end;

        if lColWidth > 0 then
          lGrid.ColWidths[aCol1] := lColWidth
      end;

      if aCreateField then
      begin
        lCell.Font.Assign(aNode.ColumnInfo.DataFont);
        lCell.HAlign := aNode.ColumnInfo.DataHAlign;
        lCell.VAlign := aNode.ColumnInfo.DataVAlign;
        lCell.FillColor := aNode.ColumnInfo.DataFillColor;
        if aNode.ColumnInfo.DataFieldName <> '' then
          lCell.Text := Format('[%s."%s"]', [lDataSetName, aNode.ColumnInfo.DataFieldName]);
      end
      else
      begin
        lCell.Font.Assign(aNode.ColumnInfo.TitleFont);
        lCell.HAlign := aNode.ColumnInfo.TitleHAlign;
        lCell.VAlign := aNode.ColumnInfo.TitleVAlign;
        lCell.FillColor := aNode.ColumnInfo.TitleFillColor;
        lCell.Text := aNode.ColumnInfo.TitleCaption;
      end;
    end;

  begin
    lCurRow := aNowRow;
    while aNode <> nil do
    begin
      if aNode.Count > 0 then // 还有下级Node
      begin
        lCurCol := aNowCol;
        lSaveMaxLevel := lMaxLevel;
        Dec(lMaxLevel);
        _GenOneNode(aNode.Item[0], aNowCol, lCurRow + 1);
        lMaxLevel := lSaveMaxLevel;

        _SetOneCell(lCurCol, lCurRow, aNowCol - 1, lCurRow, False);
      end
      else
      begin
        _SetOneCell(aNowCol, lCurRow, aNowCol, lCurRow + lMaxLevel - 1, False);
        _SetOneCell(aNowCol, lCurRow + lMaxLevel, aNowCol, lCurRow + lMaxLevel, True);
        aNowCol := aNowCol + 1;
      end;

      lCurRow := aNowRow;
      aNode := aNode.GetNextSibling; // 处理下一个兄弟Node
    end;
  end;

begin
  Result := True;
  FReport.Clear;

  lPage := TRMGridReport(FReport).AddGridReportPage;
  lPage.AutoHCenter := Self.AutoHCenter;

  lGrid := lPage.Grid;
  if ReportDataTree.Count > 0 then
  begin
    lDataSetName := '';
    if FDataSet <> nil then
    begin
      if (FDataSet.Owner <> nil) and (FDataSet.Owner <> FReport.Owner) then
        lDataSetName := FDataSet.Owner.Name + '.' + FDataSet.Name
      else
        lDataSetName := FDataSet.Name;
    end;

    lMaxLevel := _GetNodeLevel(ReportDataTree.Items[0]);
    lGrid.RowCount := lMaxLevel + 2;
    lGrid.ColCount := _GetColumnCount(ReportDataTree.Items[0]) + 1;

    lNowCol := 1;
    _GenOneNode(ReportDataTree.Items[0], lNowCol, 1);

    lBandColumnHeader := TRMBandColumnHeader.Create;
    lBandColumnHeader.ParentPage := lPage;
    for i := 1 to lMaxLevel do
      lPage.RowBandViews[i] := lBandColumnHeader;

    lBandMasterData := TRMBandMasterData.Create;
    lBandMasterData.ParentPage := lPage;
    lBandMasterData.DataSetName := lDataSetName;
    lBandMasterData.AutoAppendBlank := Self.AutoAppendBlank;
    lPage.RowBandViews[lMaxLevel + 1] := lBandMasterData;
  end;
end;

end.

