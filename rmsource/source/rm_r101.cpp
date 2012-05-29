//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USEFORMNS("RM_about.pas", Rm_about, RMFormAbout);
USEFORMNS("RM_BarCode.pas", Rm_barcode, RM2DBarCodeForm);
USEFORMNS("RM_Chart.pas", Rm_chart, RMChartForm);
USEFORMNS("RM_Designer.pas", Rm_designer, RMDesignerForm);
USEFORMNS("RM_DesignerOptions.pas", Rm_designeroptions, RMDesOptionsForm);
USEFORMNS("RM_e_bmp.pas", Rm_e_bmp, RMBMPExportForm);
USEFORMNS("RM_e_emf.pas", Rm_e_emf, RMEMFExportForm);
USEFORMNS("RM_e_gif.pas", Rm_e_gif, RMGIFExportForm);
USEFORMNS("RM_e_Jpeg.pas", Rm_e_jpeg, RMJPEGExportForm);
USEFORMNS("RM_E_WMF.pas", Rm_e_wmf, RMWMFExportForm);
USEFORMNS("RM_EditorBand.pas", Rm_editorband, RMBandEditorForm);
USEFORMNS("RM_EditorBarCode.pas", Rm_editorbarcode, RMBarCodeForm);
USEFORMNS("RM_EditorCalc.pas", Rm_editorcalc, RMCalcMemoEditorForm);
USEFORMNS("RM_EditorDictionary.pas", Rm_editordictionary, RMDictionaryForm);
USEFORMNS("RM_EditorExpr.pas", Rm_editorexpr, RMFormExpressionBuilder);
USEFORMNS("RM_EditorField.pas", Rm_editorfield, RMFieldsForm);
USEFORMNS("RM_EditorFindReplace.pas", Rm_editorfindreplace, RMFindReplaceForm);
USEFORMNS("RM_EditorFormat.pas", Rm_editorformat, RMFmtForm);
USEFORMNS("RM_EditorFrame.pas", Rm_editorframe, RMFormFrameProp);
USEFORMNS("RM_EditorGroup.pas", Rm_editorgroup, RMGroupEditorForm);
USEFORMNS("RM_EditorHilit.pas", Rm_editorhilit, RMHilightForm);
USEFORMNS("RM_EditorMemo.pas", Rm_editormemo, RMEditorForm);
USEFORMNS("RM_EditorPicture.pas", Rm_editorpicture, RMPictureEditorForm);
USEFORMNS("RM_EditorReportProp.pas", Rm_editorreportprop, RMReportProperty);
USEFORMNS("RM_EditorStrings.pas", Rm_editorstrings, ELStringsEditorDlg);
USEFORMNS("RM_EditorTemplate.pas", Rm_editortemplate, RMTemplNewForm);
USEFORMNS("RM_Ole.pas", Rm_ole, RMOleForm);
USEFORMNS("RM_PageSetup.pas", Rm_pagesetup, RMPageSetupForm);
USEFORMNS("RM_Progr.pas", Rm_progr, RMProgressForm);
USEFORMNS("RM_RichEdit.pas", Rm_richedit, RMRichForm);
USEFORMNS("RM_RxParaFmt.pas", Rm_rxparafmt, RMParaFormatDlg);
USEFORMNS("RM_WizardNewReport.pas", Rm_wizardnewreport, RMTemplForm);
USEFORMNS("RM_wwRichEdit.pas", Rm_wwrichedit, RMwwRichForm);
USEFORMNS("RMD_ADO.pas", Rmd_ado, RMDFormADOConnEdit);
USEFORMNS("RMD_BDE.pas", Rmd_bde, RMDFormBDEDBProp);
USEFORMNS("RMD_DataPrv.pas", Rmd_dataprv, RMDFormPreviewData);
USEFORMNS("RMD_Dbx.pas", Rmd_dbx, RMDFormDbxDBProp);
USEFORMNS("RMD_DlgListField.pas", Rmd_dlglistfield, RMDFieldsListForm);
USEFORMNS("RMD_DlgNewLookupField.pas", Rmd_dlgnewlookupfield, RMDLookupFieldForm);
USEFORMNS("RMD_EditorField.pas", Rmd_editorfield, RMDFieldsEditorForm);
USEFORMNS("RMD_Editorldlinks.pas", Rmd_editorldlinks, RMDFieldsLinkForm);
USEFORMNS("RMD_ExpFrm.pas", Rmd_expfrm, RMDFormReportExplorer);
USEFORMNS("RMD_IBX.pas", Rmd_ibx, RMDFormIBXPropEdit);
USEFORMNS("RMD_Qblnk.pas", Rmd_qblnk, RMDFormQBLink);
USEFORMNS("RMD_QryDesigner.pas", Rmd_qrydesigner, RMDQueryDesignerForm);
USEFORMNS("RMD_QueryParm.pas", Rmd_queryparm, RMDParamsForm);
USEFORMNS("RM_Preview.pas", Rm_preview, RMPreviewForm);
USEFORMNS("RM_DsgGridReport.pas", Rm_dsggridreport, RMGridReportDesignerForm);
USEFORMNS("RM_EditorCellProp.pas", Rm_editorcellprop, RMCellPropForm);
USEFORMNS("RM_EditorCellWidth.pas", Rm_editorcellwidth, RMEditCellWidthForm);
USEFORMNS("RM_EditorGridCols.pas", Rm_editorgridcols, RMGetGridColumnsForm);
USEFORMNS("RM_e_htm.pas", Rm_e_htm, RMHTMLExportForm);
USEFORMNS("RM_EditorBandType.pas", Rm_editorbandtype, RMBandTypesForm);
USEFORMNS("RM_e_Tiff.pas", Rm_e_tiff, RMTiffExportForm);
USEFORMNS("RM_DBChart.pas", Rm_dbchart, RMDBChartForm);
USEFORMNS("RM_e_txt.pas", Rm_e_txt, RMTXTExportForm);
USEFORMNS("RM_Cross.pas", Rm_cross, RMCrossForm);
USEFORMNS("RM_e_csv.pas", Rm_e_csv, RMCSVExportForm);
USEFORMNS("RM_DlgFind.pas", Rm_dlgfind, RMPreviewSearchForm);
USEFORMNS("RM_e_Xls.pas", Rm_e_xls, RMXLSExportForm);
USEFORMNS("RM_EditorConfirmReplace.pas", Rm_editorconfirmreplace, RMConfirmReplaceDialog);
USEFORMNS("RM_EditorFieldAlias.pas", Rm_editorfieldalias, RMEditorFieldAlias);
USEFORMNS("RM_EditorHF.pas", Rm_editorhf, RMFormEditorHF);
USEFORMNS("RM_EditorReplaceText.pas", Rm_editorreplacetext, RMTextReplaceDialog);
USEFORMNS("RM_EditorReportMaster.pas", Rm_editorreportmaster, RMFormReportMaster);
USEFORMNS("RM_EditorSearchText.pas", Rm_editorsearchtext, RMTextSearchDialog);
USEFORMNS("RM_HtmlMemo.pas", Rm_htmlmemo, RMHtmlForm);
USEFORMNS("RM_PrintDlg.pas", Rm_printdlg, RMPrintDialogForm);
USEFORMNS("RM_TntRichEdit.pas", Rm_tntrichedit, RMTntRichForm);
USEFORMNS("RMD_DlgSelectReportType.pas", Rmd_dlgselectreporttype, RMDSelectReportTypeForm);
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
	return 1;
}
//---------------------------------------------------------------------------
