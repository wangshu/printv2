
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{            Registration unit            }
{                                         }
{*****************************************}


unit RM_reg;

interface

{$I RM.inc}

procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  DB, Dialogs,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  RM_Class, RM_Printer, RM_DataSet, RM_Designer, RM_PreView, RM_Utils, RM_Const,
  RM_Const1, RM_PageSetup, RM_Common,
  RM_AngLbl, RM_ChineseMoneyMemo, RM_RichEdit, RM_CheckBox, RM_Diagonal, RM_Ole,
  RM_DialogCtls, RM_BarCode, RM_AsBarView, RM_Cross,
  RMD_ReportExplorer, RM_DsgGridReport, RM_GridReport,
  RM_e_txt, RM_e_bmp, RM_e_emf, RM_e_wmf, RM_e_Tiff, RM_e_xls, RM_e_htm, RM_e_csv,
  RM_EditorFieldAlias
{$IFDEF llPDFlib}, RM_E_llPDF{$ENDIF}
{$IFDEF RXGIF}, RM_e_gif{$ENDIF}
{$IFDEF JPEG}, RM_e_jpeg{$ENDIF}
  , RM_FormReport, RM_PDBGrid
{$IFDEF EHLib}, RM_PEHGrid{$ENDIF}
{$IFDEF TeeChart}, RM_Chart, RM_ChartUI, RM_PChart, RM_DBChart, RM_DBChartUI{$ENDIF}
{$IFDEF JVCLCTLS}, RM_PRxCtls{$ENDIF}
{$IFDEF InfoPower}, RM_wwRichEdit, RM_PwwGrid{$ENDIF}
{$IFDEF DM_BDE}, RMD_BDE{$ENDIF}
{$IFDEF DM_ADO}, RMD_ADO{$ENDIF}
{$IFDEF DM_IBX}, RMD_IBX{$ENDIF}
{$IFDEF DM_DBX}, RMD_DBX{$ENDIF}
{$IFDEF DM_MIDAS}, RMD_MIDAS{$ENDIF}
  ;

{-----------------------------------------------------------------------}
type
  TRMReportEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TRMDictionaryFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TRMDesigner_DefaultPageClass_Editor = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(aProc: TGetStrProc); override;
  end;

  TRMIniFileNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

{ TRMFieldProperty }

  TRMFieldProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings);
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  { TRMRichEditStrings }
  TRMRichEditStrings = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TRMPageLayoutProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TRMFormReportEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure DoShow;
  end;

  TRMGridReportEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure DoShow;
  end;

  { TRMDataSet_Editor }
  TRMDataSet_Editor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  { TRMDataSet_FieldAlias_Editor }
  TRMDataSet_FieldAlias_Editor = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
{ TRMReportEditor }

function TRMReportEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

function TRMReportEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := RMLoadStr(SDesignReport);
  end;
end;

procedure TRMReportEditor.ExecuteVerb(Index: Integer);

  procedure _DoDesign;
  begin
    TRMReport(Component).DesignReport;
    if TRMReport(Component).StoreInDFM then
    begin
      if TRMReport(Component).ComponentModified then
        Designer.Modified;
    end;
  end;

begin
  case Index of
    0: _DoDesign;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDictionaryFileNameProperty }

procedure TRMDictionaryFileNameProperty.Edit;
var
  liOpenDlg: TOpenDialog;
begin
  liOpenDlg := TOpenDialog.Create(nil);
  liOpenDlg.FileName := GetValue;
  liOpenDlg.Filter := 'ReportMachine Dictionary Files (*.rmd)|*.rmd';
  liOpenDlg.Options := liOpenDlg.Options + [ofPathMustExist, ofFileMustExist];
  try
    if liOpenDlg.Execute then SetValue(liOpenDlg.FileName);
  finally
    liOpenDlg.Free;
  end;
end;

function TRMDictionaryFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDesigner_DefaultPageClass_Editor }

function TRMDesigner_DefaultPageClass_Editor.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList];
end;

procedure TRMDesigner_DefaultPageClass_Editor.GetValues(aProc: TGetStrProc);
var
  i: Integer;
begin
  aProc('TRMReportPage');
  for i := 0 to RMAddInReportPageCount - 1 do
    aProc(RMAddInReportPage(i).ClassRef.ClassName);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMIniFileNameProperty }

procedure TRMIniFileNameProperty.Edit;
var
  liOpenDlg: TOpenDialog;
begin
  liOpenDlg := TOpenDialog.Create(nil);
  liOpenDlg.FileName := GetValue;
  liOpenDlg.Filter := 'Ini File (*.ini)|*.ini';
  liOpenDlg.Options := liOpenDlg.Options + [ofPathMustExist, ofFileMustExist];
  try
    if liOpenDlg.Execute then SetValue(liOpenDlg.FileName);
  finally
    liOpenDlg.Free;
  end;
end;

function TRMIniFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFieldProperty}

function TRMFieldProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TRMFieldProperty.GetValueList(List: TStrings);
var
  lReport: TComponent;
begin
  if (GetComponent(0) = nil) then Exit;

  lReport := nil;
  if (GetComponent(0) is TRMGroupItem) then
    lReport := (GetComponent(0) as TRMGroupItem).Report;

  if lReport <> nil then
  begin
    if lReport is TRMCustomFormReport then
    begin
      if TRMCustomFormReport(lReport).DataSet <> nil then
        TRMCustomFormReport(lReport).DataSet.GetFieldNames(List);
    end;
  end;
end;

procedure TRMFieldProperty.GetValues(Proc: TGetStrProc);
var
  i: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for i := 0 to Values.Count - 1 do Proc(Values[i]);
  finally
    Values.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMRichEditStrings}
type
  THackDesigner = class(TRMReportDesigner)
  end;

  THackRMPageHeaderFooter = class(TRMPageHeaderFooter)
  end;

function TRMRichEditStrings.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog] - [paSubProperties];
end;

procedure TRMRichEditStrings.Edit;
var
  Stream: TStringStream;
begin
  if RMDesignerClass <> nil then
  begin
    RMDesigner := TRMReportDesigner(RMDesignerClass.NewInstance);
    RMDesigner.Create(nil);
    THackDesigner(RMDesigner).FReport := THackRMPageHeaderFooter(GetComponent(0)).ParentFormReport.Report;
  end;

  with TRMRichForm.Create(Application) do
  begin
    try
      Stream := TStringStream.Create('');
      TStrings(GetOrdValue).SaveToStream(Stream);
      Stream.Position := 0;
      Editor.Lines.LoadFromStream(Stream);
      case ShowModal of
        mrOk:
          begin
            Stream.Position := 0;
            Editor.Lines.SaveToStream(Stream);
            Stream.Position := 0;
            TStrings(GetOrdValue).LoadFromStream(Stream);
            Modified;
          end;
      end;
      Stream.Free;
    finally
      if RMDesignerClass <> nil then
      begin
        RMDesigner.Free;
        RMDesigner := nil;
      end;
      Free;
    end;
  end;
end;

{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
{ TRMPageLayoutProperty }

function TRMPageLayoutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TRMPageLayoutProperty.Edit;
var
  tmpForm: TRMPageSetupForm;
  tmp: TRMPageLayout;
begin
  tmp := TRMPageLayout(GetOrdValue);
  tmpForm := TRMPageSetupForm.Create(nil);
  try
    tmpForm.CurPrinter := RMPrinter;

    tmpForm.PageSetting.Title := tmp.Title;
    tmpForm.PageSetting.DoublePass := tmp.DoublePass;
    tmpForm.PageSetting.PageOr := tmp.PageOrientation;
    tmpForm.PageSetting.MarginLeft := RMRound(RMToMMThousandths(tmp.LeftMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginTop := RMRound(RMToMMThousandths(tmp.TopMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginRight := RMRound(RMToMMThousandths(tmp.RightMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginBottom := RMRound(RMToMMThousandths(tmp.BottomMargin, rmutScreenPixels) / 1000, 1);

    tmpForm.PageSetting.PageWidth := tmp.Width;
    tmpForm.PageSetting.PageHeight := tmp.Height;
    tmpForm.PageSetting.PageSize := tmp.PageSize;
    tmpForm.PageSetting.PageBin := tmp.PageBin;
    tmpForm.PageSetting.PrinterName := tmp.PrinterName;
    tmpForm.PageSetting.ColorPrint := tmp.ColorPrint;
    tmpForm.PageSetting.ColCount := tmp.ColumnCount;
    tmpForm.PageSetting.ColGap := RMFromScreenPixels(tmp.ColumnGap, rmutMillimeters);
    if tmpForm.ShowModal = mrOk then
    begin
      tmp.Title := tmpForm.PageSetting.Title;
      tmp.PrinterName := tmpForm.PageSetting.PrinterName;
      tmp.DoublePass := tmpForm.PageSetting.DoublePass;
      tmp.PageOrientation := tmpForm.PageSetting.PageOr;
      tmp.ColorPrint := tmpForm.PageSetting.ColorPrint;

      tmp.ColumnCount := tmpForm.PageSetting.ColCount;
      tmp.ColumnGap := RMToScreenPixels(tmpForm.PageSetting.ColGap, rmutMillimeters);
      tmp.LeftMargin := Round(RMToScreenPixels(tmpForm.PageSetting.MarginLeft * 1000, rmutMMThousandths));
      tmp.TopMargin := Round(RMToScreenPixels(tmpForm.PageSetting.MarginTop * 1000, rmutMMThousandths));
      tmp.RightMargin := Round(RMToScreenPixels(tmpForm.PageSetting.MarginRight * 1000, rmutMMThousandths));
      tmp.BottomMargin := Round(RMToScreenPixels(tmpForm.PageSetting.MarginBottom * 1000, rmutMMThousandths));

      tmp.Width := tmpForm.PageSetting.PageWidth;
      tmp.Height := tmpForm.PageSetting.PageHeight;
      tmp.PageBin := tmpForm.PageSetting.PageBin;
      tmp.PageSize := tmpForm.PageSetting.PageSize;
      Modified;
//        SetOrdValue(Longint(tmp));
    end;
  finally
    tmpForm.Free;
  end;
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{ TRMFormReportEditor }

procedure TRMFormReportEditor.ExecuteVerb(Index: Integer);
begin
  DoShow;
end;

function TRMFormReportEditor.GetVerb(Index: Integer): string;
begin
  Result := RMLoadStr(SPreview);
end;

function TRMFormReportEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TRMFormReportEditor.DoShow;
begin
  TRMCustomFormReport(Component).ShowReport;
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{ TRMGridReportEditor }

procedure TRMGridReportEditor.ExecuteVerb(Index: Integer);
begin
  DoShow;
end;

function TRMGridReportEditor.GetVerb(Index: Integer): string;
begin
  Result := RMLoadStr(SPreview);
end;

function TRMGridReportEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TRMGridReportEditor.DoShow;
begin
  TRMCustomGridReport(Component).ShowReport;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMDataSet_Editor.ExecuteVerb(Index: Integer);
var
  tmp: TRMEditorFieldAlias;
begin
  tmp := TRMEditorFieldAlias.Create(nil);
  try
    if tmp.Edit(TRMDataSet(Component)) then
      Designer.Modified;
  finally
    tmp.Free;
  end;
end;

function TRMDataSet_Editor.GetVerb(Index: Integer): string;
begin
  Result := 'Edit Field Alias';
end;

function TRMDataSet_Editor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

function TRMDataSet_FieldAlias_Editor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TRMDataSet_FieldAlias_Editor.Edit;
var
  tmp: TRMEditorFieldAlias;
begin
  tmp := TRMEditorFieldAlias.Create(nil);
  try
    if tmp.Edit(TRMDataSet(GetComponent(0))) then
      Designer.Modified;
  finally
    tmp.Free;
  end;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('Report Machine',
    [TRMGridReport, TRMReport, TRMCompositeReport, TRMDBDataSet, TRMUserDataset,
    TRMAngledLabelObject, TRMRichObject, TRMCheckBoxObject, TRMOLEObject,
      TRMChineseMoneyObject, TRMDiagonalObject, TRMAsBarCodeObject, TRMCrossObject
{$IFDEF TurboPower}, TRMBarCodeObject{$ENDIF}
{$IFDEF TeeChart}, TRMChartObject, TRMDBChartObject{$ENDIF}
{$IFDEF JVCLCTLS}{$ENDIF}
{$IFDEF InfoPower}, TRMwwRichObject{$ENDIF}
    , TRMDialogControls, TRMPreview,
      TRMTextExport, TRMCSVExport, TRMBMPExport, TRMEMFExport, TRMWMFExport,
      TRMTiffExport, TRMXLSExport, TRMHTMExport
{$IFDEF llPDFlib}, TRMllPDFExport{$ENDIF}
{$IFDEF RXGIF}, TRMGIFExport{$ENDIF}
{$IFDEF JPEG}, TRMJPEGExport{$ENDIF}
    ]);

  RegisterComponents('RM Designer', [TRMGridReportDesigner, TRMDesigner, TRMDataDictionary, TRMReportExplorer
{$IFDEF DM_BDE}, TRMDBDEComponents{$ENDIF}
{$IFDEF DM_ADO}, TRMDADOComponents{$ENDIF}
{$IFDEF DM_IBX}, TRMDIBXComponents{$ENDIF}
{$IFDEF DM_DBX}, TRMDDBXComponents{$ENDIF}
{$IFDEF DM_MIDAS}, TRMDMidasComponents{$ENDIF}
    , TRMFormReport, TRMPrintDBGrid
{$IFDEF DecisionGrid}, TRMPrintDecision{$ENDIF}
{$IFDEF InfoPower}, TRMwwGridReport{$ENDIF}
{$IFDEF JVCLCTLS}, TRMPrintRxControls{$ENDIF}
{$IFDEF EHLib}, TRMPrintEHLib{$ENDIF}
//{$IFDEF DecisionGrid}, TRMPrintDecision{$ENDIF}
{$IFDEF TeeChart}, TRMPrintChart{$ENDIF}
    ]);

  RegisterComponentEditor(TRMReport, TRMReportEditor);
  RegisterPropertyEditor(TypeInfo(string), TRMSaveReportOptions, 'IniFileName', TRMIniFileNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TRMDesigner, 'DefaultDictionaryFile', TRMDictionaryFileNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TRMDesigner, 'DefaultPageClassName', TRMDesigner_DefaultPageClass_Editor);
  RegisterPropertyEditor(TypeInfo(TRMPageLayout), TRMCustomFormReport, 'PageLayout', TRMPageLayoutProperty);
  RegisterPropertyEditor(TypeInfo(TRMPageLayout), TRMCustomGridReport, 'PageLayout', TRMPageLayoutProperty);
  RegisterPropertyEditor(TypeInfo(string), TRMGroupItem, 'GroupFieldName', TRMFieldProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TRMPageHeaderFooter, 'Caption', TRMRichEditStrings);
  RegisterPropertyEditor(TypeInfo(TStringList), TRMDataSet, 'FieldAlias', TRMDataSet_FieldAlias_Editor);

  RegisterComponentEditor(TRMCustomFormReport, TRMFormReportEditor);
  RegisterComponentEditor(TRMCustomGridReport, TRMGridReportEditor);
  RegisterComponentEditor(TRMDataSet, TRMDataSet_Editor);
end;

end.

