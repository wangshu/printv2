unit RM_DBChartUI;

interface

{$I RM.inc}
{$IFDEF TeeChart}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, Buttons, RM_Class, RM_DsgCtrls,
  TeeProcs, TeEngine, Chart, Series, DBChart, EditChar, DBEditCh, RM_DBChart
{$IFDEF COMPILER6_UP}
  , Variants
{$ENDIF};

type
  TRMDBTeeChartUI = class(TRMCustomDBTeeChartUI)
  public
    class procedure Edit(aTeeChart: TCustomChart); override;
  end;
{$ENDIF}

implementation

{$IFDEF TeeChart}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

class procedure TRMDBTeeChartUI.Edit(aTeeChart: TCustomChart);
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
  TRMTeeChartUIPlugIn.Register(TRMDBTeeChartUI);

finalization
  TRMTeeChartUIPlugIn.UnRegister(TRMDBTeeChartUI);
{$ENDIF}
end.



