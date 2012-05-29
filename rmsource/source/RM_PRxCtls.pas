
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{          RxRich Add-In Object           }
{                                         }
{*****************************************}

unit RM_PRxCtls;

interface

{$I RM.inc}

{$IFDEF JVCLCTLS}
uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Menus, Db,
  Forms, Dialogs, StdCtrls, RM_DataSet, RM_Class, RM_FormReport;

type
  TRMPrintRxControls = class(TComponent) // fake component
  end;

 { TRMPrintRxRichEdit }
  TRMPrintRxRichEdit = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

	{ TRMPrintRxCustomComboEdit }
  TRMPrintRxCustomComboEdit = class(TRMPrintEdit)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

{$ENDIF}

implementation

{$IFDEF JVCLCTLS}
uses
  RM_RichEdit, JvToolEdit,JvRichEdit, JvDBRichEdit, JvDBLookup,
  JvDBLookupComboEdit, JvDBCombobox, JvDBControls;

type
  THackFormReport = class(TRMFormReport)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintRxRichEdit}

procedure TRMPrintRxRichEdit.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtAddin, 'TRMRxRichView');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + THackFormReport(aFormReport).OffsX;
  t.spTop := aControl.Top + THackFormReport(aFormReport).OffsY;
  t.spWidth := aControl.Width + 2;
  t.spHeight := aControl.Height + 2;
  if aControl is TJvDBRichEdit then
  begin
    try
      ds := TJvDBRichEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name, TJvDBRichEdit(aControl).DataField]);
    except
    end;
  end
  else
    TRMRxRichView(t).LoadFromRichEdit(TJvRichEdit(aControl));
    
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

type
	THackDBComboBox = class(TJvLookupControl)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintRxCustomComboEdit}

procedure TRMPrintRxCustomComboEdit.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  inherited;
	if aControl is TJvDBLookupCombo then
  begin
  try
    ds := TJvDBLookupCombo(aControl).LookupSource;
    t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name,
      RMGetOneField(TJvDBLookupCombo(aControl).LookupDisplay)]);
  except
  end;
  end
  else if aControl is TJvDBDateEdit then
  begin
    try
      ds := TJvDBDateEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name,
        TJvDBDateEdit(aControl).DataField]);
    except
    end;
  end
  else if aControl is TJvDBCalcEdit then
  begin
    try
      ds := TJvDBCalcEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name,
        TJvDBCalcEdit(aControl).DataField]);
    except
    end;
  end
  else if aControl is TJvDBComboEdit then
  begin
    try
      ds := TJvDBComboEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name,
        TJvDBComboEdit(aControl).DataField]);
    except
    end;
  end
  else if aControl is TJvCustomDBComboBox then
  begin
    try
      ds := THackDBComboBox(aControl).DataSource;
      t.Memo.Text := Format('[%s.%s."%s"]', [ds.DataSet.Owner.Name, ds.DataSet.Name,
        THackDBComboBox(aControl).DataField]);
    except
    end;
  end
end;

initialization
  RMRegisterFormReportControl(TJvCustomRichEdit, TRMPrintRxRichEdit);
  RMRegisterFormReportControl(TJvDBLookupCombo, TRMPrintRxCustomComboEdit);
  RMRegisterFormReportControl(TJvCustomComboEdit, TRMPrintRxCustomComboEdit);
  RMRegisterFormReportControl(TJvCustomDBComboBox, TRMPrintRxCustomComboEdit);

finalization

{$ENDIF}
end.

