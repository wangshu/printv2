unit RM_ChartUI;

interface

{$I RM.inc}
{$IFDEF TeeChart}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, Buttons, RM_Class, RM_DsgCtrls,
  TeeProcs, TeEngine, Chart, Series, EditChar, RM_Chart
{$IFDEF COMPILER6_UP}
  , Variants
{$ENDIF};

type
  TRMTeeChartUI = class(TRMCustomTeeChartUI)
  public
    class procedure Edit(aTeeChart: TCustomChart); override;
  end;
{$ENDIF}

implementation

{$IFDEF TeeChart}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

class procedure TRMTeeChartUI.Edit(aTeeChart: TCustomChart);
//{$IFDEF Tee40}
//var
//  lChartPart: TChartClickedPart;
//{$ENDIF}
begin
//{$IFDEF Tee40}
//  aCustomTeeChart.Chart.CalcClickedPart(aCustomTeeChart.Chart.GetCursorPos, lChartPart);
//  EditChartPart(nil, aCustomTeeChart.Chart, lChartPart);
//{$ELSE}
  EditChart(nil, aTeeChart);
//{$ENDIF}
end;

initialization
  TRMTeeChartUIPlugIn.Register(TRMTeeChartUI);

finalization
  TRMTeeChartUIPlugIn.UnRegister(TRMTeeChartUI);
{$ENDIF}
end.



