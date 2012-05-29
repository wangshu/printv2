unit RMInterpreter_Chart;

interface

{$I RM.inc}
{$IFDEF TeeChart}

uses
  Windows, Messages, SysUtils, Classes, TeeProcs, TeEngine, Chart, Series
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

procedure RegisterJvInterpreterAdapter(JvInterpreterAdapter: TJvInterpreterAdapter);

{$ENDIF}
implementation

{$IFDEF TeeChart}
uses
  TeeShape, ArrowCha, GanttCh, BubbleCh
{$IFDEF TeeChartPro}, teestore{$ENDIF};

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TCustomSeries

procedure TCustomSeries_ParentChart(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TCustomSeries(Args.Obj).ParentChart);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TChartSeries

procedure TChartSeries_Clear(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChartSeries(Args.Obj).Clear;
end;

procedure TChartSeries_Count(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).Count;
end;

procedure TChartSeries_Add(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).Add(Args.Values[0], Args.Values[1], Args.Values[2]);
end;

procedure TChartSeries_Delete(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChartSeries(Args.Obj).Delete(Args.Values[0]);
end;

procedure TChartSeries_MaxXValue(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).MaxXValue;
end;

procedure TChartSeries_MaxYValue(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).MaxYValue;
end;

procedure TChartSeries_MinXValue(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).MinXValue;
end;

procedure TChartSeries_MinYValue(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).MinYValue;
end;

procedure TChartSeries_AddNull(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).AddNull(Args.Values[0]);
end;

procedure TChartSeries_AddXY(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).AddXY(Args.Values[0], Args.Values[1], Args.Values[2],
    Args.Values[3]);
end;

procedure TChartSeries_FillSampleValues(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChartSeries(Args.Obj).FillSampleValues(Args.Values[0]);
end;

procedure TChartSeries_AddY(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).AddY(Args.Values[0], Args.Values[1], Args.Values[2]);
end;

procedure TChartSeries_NumSampleValues(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).NumSampleValues;
end;

procedure TChartSeries_AssignValues(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChartSeries(Args.Obj).AssignValues(TChartSeries(V2O(Args.Values[0])));
end;

procedure TChartSeries_XValueToText(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).XValueToText(Args.Values[0]);
end;

procedure TChartSeries_YValueToText(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).YValueToText(Args.Values[0]);
end;

procedure TChartSeries_MarkPercent(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChartSeries(Args.Obj).MarkPercent(Args.Values[0], Args.Values[1]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TLineSeries

procedure TLineSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TLineSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TAreaSeries

procedure TAreaSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TAreaSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TAreaSeries_GetOriginPos(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TAreaSeries(Args.Obj).GetOriginPos(Args.Values[0]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TPointSeries

procedure TPointSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TPointSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TBarSeries

procedure TBarSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TBarSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TBarSeries_GetOriginPos(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TBarSeries(Args.Obj).GetOriginPos(Args.Values[0]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// THorizBarSeries

procedure THorizBarSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(THorizBarSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure THorizBarSeries_AddBar(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := THorizBarSeries(Args.Obj).AddBar(Args.Values[0], Args.Values[1], Args.Values[2]);
end;

procedure THorizBarSeries_GetOriginPos(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := THorizBarSeries(Args.Obj).GetOriginPos(Args.Values[0]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TPieSeries

procedure TPieSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TPieSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TPieSeries_AngleToPos(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TPieSeries(Args.Obj).AngleToPos(Args.Values[0], Args.Values[1], Args.Values[2],
    TVarData(Args.Values[3]).vInteger, TVarData(Args.Values[4]).vInteger);
end;

procedure TPieSeries_PointToAngle(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TPieSeries(Args.Obj).PointToAngle(Args.Values[0], Args.Values[1]);
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TChartShape

procedure TChartShape_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TChartShape.Create(V2O(Args.Values[0]) as TComponent));
end;

{procedure TChartShape_GetShapeRect(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChartShape.GetI
  Value := TChartShape(Args.Obj).GetShapeRect;
end;
}


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TFastLineSeries

procedure TFastLineSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TFastLineSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TArrowSerie

procedure TArrowSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TArrowSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TArrowSeries_AddArrow(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TArrowSeries(Args.Obj).AddArrow(Args.Values[0], Args.Values[1], Args.Values[2],
    Args.Values[3], Args.Values[4], Args.Values[5]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TGanttSeries

procedure TGanttSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TGanttSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TGanttSeries_AddGantt(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TGanttSeries(Args.Obj).AddGantt(Args.Values[0], Args.Values[1], Args.Values[2],
    Args.Values[3]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TBubbleSeries

procedure TBubbleSeries_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TBubbleSeries.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TBubbleSeries_AddBubble(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TBubbleSeries(Args.Obj).AddBubble(Args.Values[0], Args.Values[1], Args.Values[2],
    Args.Values[3], Args.Values[4]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
// TChart

procedure TChart_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TChart.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TChart_SeriesCount(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TChart(Args.Obj).SeriesCount;
end;

procedure TChart_ActiveSeriesLegend(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TChart(Args.Obj).ActiveSeriesLegend(Args.Values[0]));
end;

procedure TChart_AddSeries(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChart(Args.Obj).AddSeries(TChartSeries(V2O(Args.Values[0])));
end;

procedure TChart_FreeAllSeries(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TChart(Args.Obj).FreeAllSeries;
end;

procedure TChart_LoadFromFile(var Value: Variant; Args: TJvInterpreterArgs);
begin
{$IFDEF TeeChartPro}
  LoadChartFromFile(TCustomChart(Args.Obj), Args.Values[0]);
{$ENDIF}
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
const
  cChart = 'TeeChart';

procedure RegisterJvInterpreterAdapter(JvInterpreterAdapter: TJvInterpreterAdapter);
begin
  with JvInterpreterAdapter do
  begin
    // TCustomSeries
    AddClass(cChart, TCustomSeries, 'TCustomSeries');
    AddGet(TCustomSeries, 'ParentChart', TCustomSeries_ParentChart, 0, [varEmpty], varEmpty);

    // TChartSeries
    AddClass(cChart, TChartSeries, 'TChartSeries');
    AddGet(TChartSeries, 'Clear', TChartSeries_Clear, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'Count', TChartSeries_Count, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'Add', TChartSeries_Add, 3, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'Delete', TChartSeries_Delete, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'MaxXValue', TChartSeries_MaxXValue, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'MaxYValue', TChartSeries_MaxYValue, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'MinXValue', TChartSeries_MinXValue, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'MinYValue', TChartSeries_MinYValue, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'AddNull', TChartSeries_AddNull, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'AddXY', TChartSeries_AddXY, 4, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'FillSampleValues', TChartSeries_FillSampleValues, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'AddY', TChartSeries_AddY, 3, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'NumSampleValues', TChartSeries_NumSampleValues, 0, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'AssignValues', TChartSeries_AssignValues, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'XValueToText', TChartSeries_XValueToText, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'YValueToText', TChartSeries_YValueToText, 1, [varEmpty], varEmpty);
    AddGet(TChartSeries, 'MarkPercent', TChartSeries_MarkPercent, 2, [varEmpty], varEmpty);

    // TLineSeries
    AddClass(cChart, TLineSeries, 'TLineSeries');
    AddGet(TLineSeries, 'Create', TLineSeries_Create, 1, [varEmpty], varEmpty);

    // TAreaSeries
    AddClass(cChart, TAreaSeries, 'TAreaSeries');
    AddGet(TAreaSeries, 'Create', TAreaSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TAreaSeries, 'GetOriginPos', TAreaSeries_GetOriginPos, 1, [varEmpty], varEmpty);

    // TPointSeries
    AddClass(cChart, TPointSeries, 'TPointSeries');
    AddGet(TPointSeries, 'Create', TPointSeries_Create, 1, [varEmpty], varEmpty);

    // TBarSeries
    AddClass(cChart, TBarSeries, 'TBarSeries');
    AddGet(TBarSeries, 'Create', TBarSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TBarSeries, 'GetOriginPos', TBarSeries_GetOriginPos, 1, [varEmpty], varEmpty);

    // THorizBarSeries
    AddClass(cChart, THorizBarSeries, 'THorizBarSeries');
    AddGet(THorizBarSeries, 'Create', THorizBarSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(THorizBarSeries, 'AddBar', THorizBarSeries_AddBar, 3, [varEmpty], varEmpty);
    AddGet(THorizBarSeries, 'GetOriginPos', THorizBarSeries_GetOriginPos, 1, [varEmpty], varEmpty);

    // TPieSeries
    AddClass(cChart, TPieSeries, 'TPieSeries');
    AddGet(TPieSeries, 'Create', TPieSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TPieSeries, 'AngleToPos', TPieSeries_AngleToPos, 5, [varEmpty], varEmpty);
    AddGet(TPieSeries, 'PointToAngle', TPieSeries_PointToAngle, 2, [varEmpty], varEmpty);

    // TChartShape
    AddClass(cChart, TChartShape, 'TChartShape');
    AddGet(TChartShape, 'Create', TChartShape_Create, 1, [varEmpty], varEmpty);
//    AddGet(TChartShape, 'GetShapeRect', TChartShape_GetShapeRect, 0, [varEmpty], varEmpty);

    // TFastLineSeries
    AddClass(cChart, TFastLineSeries, 'TFastLineSeries');
    AddGet(TFastLineSeries, 'Create', TFastLineSeries_Create, 1, [varEmpty], varEmpty);

    // TArrowSeries
    AddClass(cChart, TArrowSeries, 'TArrowSeries');
    AddGet(TArrowSeries, 'Create', TArrowSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TArrowSeries, 'AddArrow', TArrowSeries_AddArrow, 6, [varEmpty], varEmpty);

    // TGanttSeries
    AddClass(cChart, TGanttSeries, 'TGanttSeries');
    AddGet(TGanttSeries, 'Create', TGanttSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TGanttSeries, 'AddGantt', TGanttSeries_AddGantt, 4, [varEmpty], varEmpty);

    // TBubbleSeries
    AddClass(cChart, TBubbleSeries, 'TBubbleSeries');
    AddGet(TBubbleSeries, 'Create', TBubbleSeries_Create, 1, [varEmpty], varEmpty);
    AddGet(TBubbleSeries, 'AddBubble', TBubbleSeries_AddBubble, 5, [varEmpty], varEmpty);

    // TChart
    AddClass(cChart, TChart, 'TChart');
    AddGet(TChart, 'Create', TChart_Create, 1, [varEmpty], varEmpty);
    AddGet(TChart, 'SeriesCount', TChart_SeriesCount, 0, [varEmpty], varEmpty);
    AddGet(TChart, 'ActiveSeriesLegend', TChart_ActiveSeriesLegend, 1, [varEmpty], varEmpty);
    AddGet(TChart, 'AddSeries', TChart_AddSeries, 1, [varEmpty], varEmpty);
    AddGet(TChart, 'FreeAllSeries', TChart_FreeAllSeries, 0, [varEmpty], varEmpty);
    AddGet(TChart, 'LoadFromFile', TChart_LoadFromFile, 1, [varEmpty], varEmpty);

    // THorizAxis
    AddConst(cChart, 'aTopAxis', aTopAxis);
    AddConst(cChart, 'aBottomAxis', aBottomAxis);

    // TVertAxis
    AddConst(cChart, 'aLeftAxis', aLeftAxis);
    AddConst(cChart, 'aRightAxis', aRightAxis);

    // TSeriesMarksStyle
    AddConst(cChart, 'smsValue', smsValue);
    AddConst(cChart, 'smsPercent', smsPercent);
    AddConst(cChart, 'smsLabel', smsLabel);
    AddConst(cChart, 'smsLabelPercent', smsLabelPercent);
    AddConst(cChart, 'smsLabelValue', smsLabelValue);
    AddConst(cChart, 'smsLegend', smsLegend);
    AddConst(cChart, 'smsPercentTotal', smsPercentTotal);
    AddConst(cChart, 'smsLabelPercentTotal', smsLabelPercentTotal);
    AddConst(cChart, 'smsXValue', smsXValue);

    // TSeriesRecalcOptions
    AddConst(cChart, 'rOnDelete', rOnDelete);
    AddConst(cChart, 'rOnModify', rOnModify);
    AddConst(cChart, 'rOnInsert', rOnInsert);
    AddConst(cChart, 'rOnClear', rOnClear);

    // TLegendStyle
    AddConst(cChart, 'lsAuto', lsAuto);
    AddConst(cChart, 'lsSeries', lsSeries);
    AddConst(cChart, 'lsValues', lsValues);
    AddConst(cChart, 'lsLastValues', lsLastValues);

    // TLegendTextStyle
    AddConst(cChart, 'ltsPlain', ltsPlain);
    AddConst(cChart, 'ltsLeftValue', ltsLeftValue);
    AddConst(cChart, 'ltsRightValue', ltsRightValue);
    AddConst(cChart, 'ltsLeftPercent', ltsLeftPercent);
    AddConst(cChart, 'ltsRightPercent', ltsRightPercent);
    AddConst(cChart, 'ltsXValue', ltsXValue);

    // TAxisLabelStyle
    AddConst(cChart, 'talAuto', talAuto);
    AddConst(cChart, 'talNone', talNone);
    AddConst(cChart, 'talValue', talValue);
    AddConst(cChart, 'talMark', talMark);
    AddConst(cChart, 'talText', talText);

    // TBarStyle
    AddConst(cChart, 'bsRectangle', bsRectangle);
    AddConst(cChart, 'bsRectGradient', bsRectGradient);
    AddConst(cChart, 'bsPyramid', bsPyramid);
    AddConst(cChart, 'bsInvPyramid', bsInvPyramid);
    AddConst(cChart, 'bsCilinder', bsCilinder);
    AddConst(cChart, 'bsEllipse', bsEllipse);
    AddConst(cChart, 'bsArrow', bsArrow);

    // TMultiBar
    AddConst(cChart, 'mbNone', mbNone);
    AddConst(cChart, 'mbSide', mbSide);
    AddConst(cChart, 'mbStacked', mbStacked);
    AddConst(cChart, 'mbStacked100', mbStacked100);

    // TMultiArea
    AddConst(cChart, 'maNone', maNone);
    AddConst(cChart, 'maStacked', maStacked);
    AddConst(cChart, 'maStacked100', maStacked100);

    // TPieOtherStyle
    AddConst(cChart, 'poNone', poNone);
    AddConst(cChart, 'poBelowPercent', poBelowPercent);
    AddConst(cChart, 'poBelowValue', poBelowValue);

    // TChartShapeStyle
    AddConst(cChart, 'chasRectangle', chasRectangle);
    AddConst(cChart, 'chasCircle', chasCircle);
    AddConst(cChart, 'chasVertLine', chasVertLine);
    AddConst(cChart, 'chasHorizLine', chasHorizLine);
    AddConst(cChart, 'chasTriangle', chasTriangle);
    AddConst(cChart, 'chasInvertTriangle', chasInvertTriangle);
    AddConst(cChart, 'chasLine', chasLine);
    AddConst(cChart, 'chasDiamond', chasDiamond);

    // TChartShapeXYStyle
    AddConst(cChart, 'xysAxis', xysAxis);
    AddConst(cChart, 'xysPixels', xysPixels);
    AddConst(cChart, 'xysAxisOrigin', xysAxisOrigin);
  end;
end;
{$ENDIF}
end.

