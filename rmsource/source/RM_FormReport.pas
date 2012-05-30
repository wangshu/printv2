unit RM_FormReport;

{$I RM.INC}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, DB,
  Forms, StdCtrls, Dialogs, Menus, Buttons, Comctrls, ExtCtrls, DBCtrls, RM_const,
  RM_DataSet, RM_Class, RM_Preview, RM_Printer, RM_Common, RM_GridReport
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF}
  {$IFDEF TntUnicode}, TntClasses{$ENDIF};

type
  TRMGridReportOption = (rmgoUseColor, rmgoStretch, rmgoWordWrap, rmgoGridLines,
    rmgoSelectedRecordsOnly, rmgoAppendBlank, rmgoGridNumber, rmgoDrawBorder,
    rmgoDoubleFrame, rmgoRebuildAfterPageChanged, rmgoDisableControls);
  TRMGridReportOptions = set of TRMGridReportOption;
  TRMFRScaleMode = (rmsmAdjust, rmsmFit);
  TRMCustomFormReport = class;
  TRMFormReport = class;

  TRMOnPrintObjectEvent = procedure(aFormReport: TRMFormReport; aPage: TRMReportPage;
    aControl: TControl; var aPrintObjectClass: TClass; var OwnerDraw: Boolean) of object;
  TRMOnAfterCreateObjectEvent = procedure(aControl: TControl; aView: TRMView) of object;
  TRMOnAfterCreateGridObjectEvent = procedure(aControl: TControl; aFieldName: string; aView: TRMView) of object;

  { TRMPageLayout }
  TRMPageLayout = class(TPersistent)
  private
    FColumnCount: Integer;
    FColumnGap: Integer;
    FPageSize: Word;
    FLeftMargin: integer;
    FTopMargin: integer;
    FBottomMargin: integer;
    FRightMargin: integer;
    FPageHeight: integer;
    FPageWidth: integer;
    FPageOr: TRMPrinterOrientation;
    FPageBin: integer;
    FPrinterName: string;
    FDoublePass: Boolean;
    FPrintBackColor: Boolean;
    FTitle: string;
  protected
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property ColumnCount: Integer read FColumnCount write FColumnCount default 1;
    property ColumnGap: Integer read FColumnGap write FColumnGap default 0;
    property PageSize: Word read FPageSize write FPageSize default 9;
    property LeftMargin: integer read FLeftMargin write FLeftMargin default 36;
    property TopMargin: integer read FTopMargin write FTopMargin default 36;
    property RightMargin: integer read FRightMargin write FRightMargin default 36;
    property BottomMargin: integer read FBottomMargin write FBottomMargin default 36;
    property Height: integer read FPageHeight write FPageHeight default 2100;
    property Width: integer read FPageWidth write FPageWidth default 2970;
    property PageOrientation: TRMPrinterOrientation read FPageOr write FPageOr default rmpoPortrait;
    property PageBin: integer read FPageBin write FPageBin;
    property PrinterName: string read FPrinterName write FPrinterName;
    property DoublePass: Boolean read FDoublePass write FDoublePass default False;
    property ColorPrint: Boolean read FPrintBackColor write FPrintBackColor;
    property Title: string read FTitle write FTitle;
  end;

  { TRMPageHeaderFooter }
  TRMPageHeaderFooter = class(TPersistent)
  private
    FCaption: TStrings;
    FHeight: Integer;
    procedure SetCaption(Value: TStrings);
    procedure SetHeight(Value: Integer);
  protected
    ParentFormReport: TRMCustomFormReport;
    procedure GetStrings(aStrings: {$IFDEF TntUnicode}TTntStrings{$ELSE}TStrings{$ENDIF});
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    procedure Add(const AStr: string; AFont: TFont; Align: TAlignment);
    procedure LoadFromRichEdit(ARichEdit: TRichEdit);
  published
    property Caption: TStrings read FCaption write SetCaption;
    property Height: Integer read FHeight write SetHeight default 20;
  end;

  { TRMGridNumOptions }
  TRMGridNumOptions = class(TPersistent)
  private
    FText: string;
    FNumber: integer;
    procedure SetNumber(Value: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Text: string read FText write FText;
    property Number: integer read FNumber write SetNumber default 7;
  end;

  { TRMScaleOptions }
  TRMScaleOptions = class(TPersistent)
  private
    FCenterOnPageH: Boolean;
    FCenterOnPageV: Boolean;
    FFitPageWidth: Boolean;
    FFitPageHeight: Boolean;
    FScaleMode: TRMFRScaleMode;
    FScaleFactor: Integer;
  protected
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property CenterOnPageH: Boolean read FCenterOnPageH write FCenterOnPageH default False;
    property CenterOnPageV: Boolean read FCenterOnPageV write FCenterOnPageV default False;
    property FitPageWidth: Boolean read FFitPageWidth write FFitPageWidth default False;
    property FitPageHeight: Boolean read FFitPageHeight write FFitPageHeight default False;
    property ScaleMode: TRMFRScaleMode read FScaleMode write FScaleMode default rmsmAdjust;
    property ScaleFactor: Integer read FScaleFactor write FScaleFactor default 100;
  end;

  { TRMGroupItem }
  TRMGroupItem = class(TCollectionItem)
  private
    FGroupFieldName: string;
    FFormNewPage: Boolean;
    function GetReport: TComponent;
  protected
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Report: TComponent read GetReport;
  published
    property GroupFieldName: string read FGroupFieldName write FGroupFieldName;
    property FormNewPage: Boolean read FFormNewPage write FFormNewPage default False;
  end;

  { TRMGroupItems }
  TRMGroupItems = class(TCollection)
  private
    FReport: TComponent;
    function GetItem(Index: Integer): TRMGroupItem;
    procedure SetItem(Index: Integer; Value: TRMGroupItem);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(aReport: TComponent);
    function Add: TRMGroupItem;
    property Report: TComponent read FReport;
    property Items[Index: Integer]: TRMGroupItem read GetItem write SetItem; default;
  end;

  { TRMMasterDataBandOptions }
  TRMMasterDataBandOptions = class(TPersistent)
  private
    FLinesPerPage: Integer;
    FColumns: Integer;
    FColumnWidth: integer;
    FColumnGap: integer;
    FNewPageAfter: Boolean;
    FHeight: Integer;
    FReprintColumnHeaderOnNewColumn: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property LinesPerPage: Integer read FLinesPerPage write FLinesPerPage default 0;
    property Columns: Integer read FColumns write FColumns default 1;
    property ColumnWidth: Integer read FColumnWidth write FColumnWidth default 200;
    property ColumnGap: Integer read FColumnGap write FColumnGap default 20;
    property NewPageAfter: Boolean read FNewPageAfter write FNewPageAfter default False;
    property Height: Integer read FHeight write FHeight default -1;
    property ReprintColumnHeaderOnNewColumn: Boolean read FReprintColumnHeaderOnNewColumn write FReprintColumnHeaderOnNewColumn default False;
  end;

  { TRMGridFontOptions }
  TRMGridFontOptions = class(TPersistent)
  private
    FUseCustomFontSize: Boolean;
    FFont: TFont;
    procedure SetFont(Value: TFont);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property UseCustomFontSize: Boolean read FUseCustomFontSize write FUseCustomFontSize default False;
    property Font: TFont read FFont write SetFont;
  end;

  TRMPageAggr = class(TPersistent)
  private
    FAutoTotal: Boolean;
    FTotalFields: string;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property AutoTotal: Boolean read FAutoTotal write FAutoTotal;
    property TotalFields: string read FTotalFields write FTotalFields;
  end;

  TRMGridPageAggrOptions = class(TPersistent)
  private
    FPageSum: TRMPageAggr;
    FPageSumTotal: TRMPageAggr;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property PageSum: TRMPageAggr read FPageSum write FPageSum;
    property PageSumTotal: TRMPageAggr read FPageSumTotal write FPageSumTotal;
  end;

  TRMReportSettings = class(TPersistent)
  private
    FShowPrintDialog: Boolean;
    FModifyPrepared: Boolean;
    FInitialZoom: TRMPreviewZoom;
    FPreviewButtons: TRMPreviewButtons;
    FPreview: TRMPreview;
    FReportTitle: string;
    FShowProgress: Boolean;
  public
    constructor Create;
  published
    property InitialZoom: TRMPreviewZoom read FInitialZoom write FInitialZoom;
    property PreviewButtons: TRMPreviewButtons read FPreviewButtons write FPreviewButtons;
    property Preview: TRMPreview read FPreview write FPreview;
    property ShowProgress: Boolean read FShowProgress write FShowProgress default True;
    property ReportTitle: string read FReportTitle write FReportTitle;
    property ShowPrintDialog: Boolean read FShowPrintDialog write FShowPrintDialog default True;
    property ModifyPrepared: Boolean read FModifyPrepared write FModifyPrepared default False;
  end;

  { TRMCustomGridReport }
  TRMCustomGridReport = class(TComponent)
  private
    FAutoBooleanString: string;
    FReport: TRMGridReport;
    FRMDataSets: TList;

    FGroups: TRMGroupItems;
    FReportOptions: TRMGridReportOptions;
    FGridFontOptions: TRMGridFontOptions;

    FPageLayout: TRMPageLayout;
    FPageHeaderMsg: TRMBandMsg;
    FPageFooterMsg: TRMBandMsg;
    FPageCaptionMsg: TRMPageCaptionMsg;

    FGridNumOptions: TRMGridNumOptions;
    FMasterDataBandOptions: TRMMasterDataBandOptions;
    FReportSettings: TRMReportSettings;
    FGridFixedCols: Integer;
    FOnAfterCreateGridFieldObject: TRMOnAfterCreateGridObjectEvent;

    procedure SetGroups(Value: TRMGroupItems);
    function GetReport: TRMGridReport;

    procedure SetMasterDataBandOptions(Value: TRMMasterDataBandOptions);
    procedure SetGridNumOptions(Value: TRMGridNumOptions);
    procedure SetPageLayout(Value: TRMPageLayout);
    procedure SetGridFontOptions(Value: TRMGridFontOptions);

    procedure SetPageHeaderMsg(Value: TRMBandMsg);
    procedure SetPageFooterMsg(Value: TRMBandMsg);
    procedure SetPageCaptionMsg(Value: TRMPageCaptionMsg);

    procedure ClearRMDataSets;
    procedure OnAfterPreviewPageSetup(Sender: TObject);
  protected
    OffsX, OffsY: Integer;
    FormHeight: Integer;
    PageWidth, PageHeight: Integer;
    HaveDetailBand: Boolean;

    function CreateReportFromGrid: Boolean; virtual;
    procedure _InternalShowReport(aFlag: Integer);
    procedure SetMemoViewFormat(aView: TRMMemoView; aField: TField);
    function AddRMDataSet(const aDataSet: TDataSet): TRMDBDataSet;
    procedure AssignFont(aView: TRMMemoView; aFont: TFont);

    property Groups: TRMGroupItems read FGroups write SetGroups;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrintReport;
    procedure ShowReport;
    procedure DesignReport;
    procedure BuildReport;
    function PageSetup: Boolean;
    function PageHeaderFooterSetup: Boolean;
    procedure ChangePageLayout(aPageSetting: TRMPageSetting);

    property Report: TRMGridReport read GetReport;
  published
    property ReportOptions: TRMGridReportOptions read FReportOptions write FReportOptions;

    property PageLayout: TRMPageLayout read FPageLayout write SetPageLayout;
    property PageHeaderMsg: TRMBandMsg read FPageHeaderMsg write SetPageHeaderMsg;
    property PageFooterMsg: TRMBandMsg read FPageFooterMsg write SetPageFooterMsg;
    property PageCaptionMsg: TRMPageCaptionMsg read FPageCaptionMsg write SetPageCaptionMsg;

    property MasterDataBandOptions: TRMMasterDataBandOptions read FMasterDataBandOptions write SetMasterDataBandOptions;
    property GridNumOptions: TRMGridNumOptions read FGridNumOptions write SetGridNumOptions;
    property GridFontOptions: TRMGridFontOptions read FGridFontOptions write SetGridFontOptions;
    property ReportSettings: TRMReportSettings read FReportSettings write FReportSettings;
    property AutoBooleanString: string read FAutoBooleanString write FAutoBooleanString;
    property GridFixedCols: Integer read FGridFixedCols write FGridFixedCols default 0;

    property OnAfterCreateGridObjectEvent: TRMOnAfterCreateGridObjectEvent read FOnAfterCreateGridFieldObject write FOnAfterCreateGridFieldObject;
  end;

  { TRMCustomFormReport }
  TRMCustomFormReport = class(TComponent)
  private
    FAutoBooleanString: string;
    FReport: TRMReport;
    //    FReportDataSet: TRMDBDataSet;
    FPageHeader: TRMPageHeaderFooter;
    FPageFooter: TRMPageHeaderFooter;
    FColumnFooter: TRMPageHeaderFooter;
    FDataSet: TDataSet;
    FDetailDataSet: TDataSet;
    FRMDataSets: TList;

    FGroups: TRMGroupItems;
    FReportOptions: TRMGridReportOptions;
    FGridFontOptions: TRMGridFontOptions;
    FPageLayout: TRMPageLayout;
    FScaleMode: TRMScaleOptions;
    FGridNumOptions: TRMGridNumOptions;
    FMasterDataBandOptions: TRMMasterDataBandOptions;
    FReportSettings: TRMReportSettings;

    procedure SetGroups(Value: TRMGroupItems);
    function GetReport: TRMReport;
    //    function GetReportDataSet: TRMDBDataSet;

    procedure SetPageHeader(Value: TRMPageHeaderFooter);
    procedure SetPageFooter(Value: TRMPageHeaderFooter);
    procedure SetColumnFooter(Value: TRMPageHeaderFooter);
    procedure SetMasterDataBandOptions(Value: TRMMasterDataBandOptions);
    procedure SetGridNumOptions(Value: TRMGridNumOptions);
    procedure SetScaleMode(Value: TRMScaleOptions);
    procedure SetPageLayout(Value: TRMPageLayout);
    procedure SetGridFontOptions(Value: TRMGridFontOptions);

    procedure ClearRMDataSets;
    procedure OnAfterPreviewPageSetup(Sender: TObject);
  protected
    FormWidth: TStringList;
    OffsX, OffsY: Integer;
    FormHeight: Integer;
    PageWidth, PageHeight: Integer;
    HaveDetailBand: Boolean;
    
    function CalcWidth(aWidth: Integer): Integer;
    procedure AddPage;
    procedure CalcRect(t: TRMView; ParentBand: TRMCustomBandView; aFormWidth: Integer);
    procedure _InternalShowReport(aFlag: Integer);
    procedure SetMemoViewFormat(aView: TRMMemoView; aField: TField);
    function AddRMDataSet(const aDataSet: TDataSet): TRMDBDataSet;
    function CreateReportFromGrid: Boolean; virtual;

    property Groups: TRMGroupItems read FGroups write SetGroups;
    property DetailDataSet: TDataSet read FDetailDataSet write FDetailDataSet;
  public
    MainDataSet: TRMDBDataSet;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure AssignFont(aView: TRMMemoView; aFont: TFont);
    procedure PrintReport;
    procedure ShowReport;
    procedure DesignReport;
    procedure BuildReport;
    function PageSetup: Boolean;
    procedure ChangePageLayout(aPageSetting: TRMPageSetting);
    property Report: TRMReport read GetReport;
    //    property ReportDataSet: TRMDBDataSet read GetReportDataSet;
  published
    property DataSet: TDataSet read FDataSet write FDataSet;
    property ReportOptions: TRMGridReportOptions read FReportOptions write FReportOptions;

    property PageLayout: TRMPageLayout read FPageLayout write SetPageLayout;
    property PageHeader: TRMPageHeaderFooter read FPageHeader write SetPageHeader;
    property PageFooter: TRMPageHeaderFooter read FPageFooter write SetPageFooter;
    property ColumnFooter: TRMPageHeaderFooter read FColumnFooter write SetColumnFooter;
    property ScaleMode: TRMScaleOptions read FScaleMode write SetScaleMode;
    property MasterDataBandOptions: TRMMasterDataBandOptions read FMasterDataBandOptions write SetMasterDataBandOptions;
    property GridNumOptions: TRMGridNumOptions read FGridNumOptions write SetGridNumOptions;
    property GridFontOptions: TRMGridFontOptions read FGridFontOptions write SetGridFontOptions;
    property ReportSettings: TRMReportSettings read FReportSettings write FReportSettings;
    property AutoBooleanString: string read FAutoBooleanString write FAutoBooleanString;
  end;

  { TRMFormReportObjects }
  TRMFormReportObject = class(TObject)
  private
    FAutoFree: Boolean;
  protected
  public
    constructor Create; virtual;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); virtual; abstract;
    property AutoFree: Boolean read FAutoFree write FAutoFree;
  end;

  { TRMAddInFormReportObjectInfo }
  TRMAddInFormReportObjectInfo = class
  private
    FClassRef: TClass;
    FObjectClass: TClass;
  public
    constructor Create(AClassRef: TClass; AObjectClass: TClass);
    property ClassRef: TClass read FClassRef;
    property ObjectClass: TClass read FObjectClass;
  end;

  { TRMFormReport }
  TRMFormReport = class(TRMCustomFormReport)
  private
    FGridFixedCols: Integer;
    FDrawOnPageFooter: Boolean;
    FColumnHeaderViews, FPageDetailViews, FPageFooterViews: TList;
    FColumnFooterViews: TList;
    FGroupFooterViews: TList;
    FGridTop, FGridHeight: Integer;
    FPrintControl: TWinControl;
    FDetailPrintControl: TWinControl;
    FReportObjects: TList;
    FOnPrintObject: TRMOnPrintObjectEvent;
    FOnAfterCreateObject: TRMOnAfterCreateObjectEvent;
    FOnAfterCreateGridFieldObject: TRMOnAfterCreateGridObjectEvent;
    procedure Clear;
  protected
    CanSetDataSet: Boolean;

    function CreateReportFromGrid: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    property ColumnHeaderViews: TList read FColumnHeaderViews;
    property PageDetailViews: TList read FPageDetailViews;
    property PageFooterViews: TList read FPageFooterViews;
    property ColumnFooterViews: TList read FColumnFooterViews;
    property GroupFooterViews: TList read FGroupFooterViews;
    property GridTop: Integer read FGridTop write FGridTop;
    property GridHeight: Integer read FGridHeight write FGridHeight;
    property DrawOnPageFooter: Boolean read FDrawOnPageFooter write FDrawOnPageFooter;

    property DetailPrintControl: TWinControl read FDetailPrintControl write FDetailPrintControl;
    property DetailDataSet;
  published
    property Groups;
    property PrintControl: TWinControl read FPrintControl write FPrintControl;
    property GridFixedCols: Integer read FGridFixedCols write FGridFixedCols default 0;
    property OnPrintObject: TRMOnPrintObjectEvent read FOnPrintObject write FOnPrintObject;
    property OnAfterCreateObject: TRMOnAfterCreateObjectEvent read FOnAfterCreateObject write FOnAfterCreateObject;
    property OnAfterCreateGridObjectEvent: TRMOnAfterCreateGridObjectEvent read FOnAfterCreateGridFieldObject write FOnAfterCreateGridFieldObject;
  end;

  { TRMPrintControl }
  TRMPrintControl = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintEdit }
  TRMPrintEdit = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintImage }
  TRMPrintImage = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintRichEdit }
  TRMPrintRichEdit = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintShape }
  TRMPrintShape = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintCheckBox }
  TRMPrintCheckBox = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintDateTimePicker }
  TRMPrintDateTimePicker = class(TRMFormReportObject)
  public
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
  end;

  { TRMPrintListView }
  TRMPrintListView = class(TRMFormReportObject)
  private
    FFormReport: TRMFormReport;
    FListView: TCustomListView;
    FUserDataset: TRMUserDataset;
    FList: TStringList;
    procedure OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
    procedure OnUserDatasetFirst(Sender: TObject);
    procedure OnUserDatasetNext(Sender: TObject);
    procedure OnUserDatasetPrior(Sender: TObject);
    procedure SetMemos;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
      aControl: TControl; var t: TRMView); override;
    procedure OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
  public
  end;

function RMGetOneField(const str: string): string;
procedure RMRegisterFormReportControl(ClassRef, ObjectClass: TClass);

implementation

uses
  Math, RM_RichEdit, RM_Utils, RM_Const1, RM_PageSetup, RM_CheckBox, RM_EditorHF;

type
  THackListView = class(TCustomListView)
  end;

  THackView = class(TRMReportView)
  end;

  THackReport = class(TRMReport)
  end;

var
  FFormReportList: TList;

  {$IFNDEF COMPILER4_UP}

function Max(Value1, Value2: Integer): Integer;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function Min(Value1, Value2: Integer): Integer;
begin
  if Value1 > Value2 then
    Result := Value2
  else
    Result := Value1;
end;
{$ENDIF}

function RMGetOneField(const str: string): string;
var
  i: integer;
begin
  i := pos(';', str);
  if i > 0 then
    Result := Copy(str, 1, i - 1)
  else
    Result := str;
end;

function ListSortCompare(Item1, Item2: Pointer): Integer;
begin
  Result := TControl(Item1).Top - TControl(Item2).Top;
  if Result = 0 then
    Result := TControl(Item1).Left - TControl(Item2).Left;
end;

function RMFormReportList: TList;
begin
  if FFormReportList = nil then
    FFormReportList := TList.Create;
  Result := FFormReportList;
end;

procedure RMRegisterFormReportControl(ClassRef, ObjectClass: TClass); // 注册一个打印控件
var
  tmp: TRMAddInFormReportObjectInfo;
begin
  tmp := TRMAddInFormReportObjectInfo.Create(ClassRef, ObjectClass);
  RMFormReportList.Add(tmp);
end;

procedure FreeFormReportList; // 释放资源
begin
  if FFormReportList = nil then Exit;
  while FFormReportList.Count > 0 do
  begin
    TRMAddInFormReportObjectInfo(FFormReportList[0]).Free;
    FFormReportList.Delete(0);
  end;

  FFormReportList.Free;
  FFormReportList := nil;
end;

{--------------------------------------------------------------------------------}
{--------------------------------------------------------------------------------}
{ TRMPageLayout }

constructor TRMPageLayout.Create;
begin
  inherited Create;
  FPageSize := 9; // A4
  FPageWidth := 2100;
  FPageHeight := 2970;
  FPageOr := rmpoPortrait;
  FPrinterName := RMLoadStr(SDefaultPrinter);
  FDoublePass := False;
  FColumnCount := 1;
  FColumnGap := 0;

  FLeftMargin := Round(RMFromMMThousandths(10 * 1000, rmutScreenPixels));
  FTopMargin := Round(RMFromMMThousandths(10 * 1000, rmutScreenPixels));
  FRightMargin := Round(RMFromMMThousandths(10 * 1000, rmutScreenPixels));
  FBottomMargin := Round(RMFromMMThousandths(10 * 1000, rmutScreenPixels));
end;

procedure TRMPageLayout.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  PageSize := TRMPageLayout(Source).PageSize;
  LeftMargin := TRMPageLayout(Source).LeftMargin;
  TopMargin := TRMPageLayout(Source).TopMargin;
  RightMargin := TRMPageLayout(Source).RightMargin;
  BottomMargin := TRMPageLayout(Source).BottomMargin;
  Height := TRMPageLayout(Source).Height;
  Width := TRMPageLayout(Source).Width;
  PageOrientation := TRMPageLayout(Source).PageOrientation;
  PageBin := TRMPageLayout(Source).PageBin;
  PrinterName := TRMPageLayout(Source).PrinterName;
  DoublePass := TRMPageLayout(Source).DoublePass;
  Title := TRMPageLayout(Source).Title;
  ColumnCount := TRMPageLayout(Source).ColumnCount;
  ColumnGap := TRMPageLayout(Source).ColumnGap;
end;

{--------------------------------------------------------------------------------}
{--------------------------------------------------------------------------------}
{ TRMPageHeaderFooter }

constructor TRMPageHeaderFooter.Create;
begin
  inherited Create;
  FCaption := TStringList.Create;
  FHeight := 0;
end;

destructor TRMPageHeaderFooter.Destroy;
begin
  FCaption.Free;
  inherited Destroy;
end;

procedure TRMPageHeaderFooter.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  Caption := TRMPageHeaderFooter(Source).Caption;
  Height := TRMPageHeaderFooter(Source).Height;
end;

procedure TRMPageHeaderFooter.Clear;
begin
  FCaption.Clear;
end;

procedure TRMPageHeaderFooter.Add(const AStr: string; AFont: TFont; Align: TAlignment);
var
  RichEdit: TRichEdit;
  Stream: TMemoryStream;
  StringList: TStringList;

  function link2(s1, s2: string): string;
  var
    p: integer;
  begin
    if s1 = '' then
    begin
      Result := s2;
      Exit;
    end;

    p := LastDelimiter('}', s1);
    if p > 0 then
      s1 := copy(s1, 1, p - 1)
    else
      s1 := '{' + s1;
    p := Pos('{', s2);
    if p > 0 then
      Delete(s2, 1, p)
    else
      s2 := s2 + '}';
    Result := s1 + s2;
  end;

begin
  RichEdit := TRichEdit.Create(nil);
  Stream := TMemoryStream.Create;
  StringList := TStringList.Create;
  try
    RichEdit.Parent := RMDialogForm;
    RichEdit.SelStart := 1;
    RichEdit.SelText := AStr;
    RichEdit.SelectAll;

    RichEdit.SelAttributes.Style := AFont.Style;
    RichEdit.SelAttributes.Name := AFont.Name;
    RichEdit.SelAttributes.Size := AFont.Size;
    RichEdit.Paragraph.Alignment := Align;

    RichEdit.Lines.SaveToStream(Stream);
    Stream.Position := 0;
    StringList.LoadFromStream(Stream);

    FCaption.Text := Link2(FCaption.Text, StringList.Text);
  finally
    RichEdit.Free;
    Stream.Free;
    StringList.Free;
  end;
end;

procedure TRMPageHeaderFooter.LoadFromRichEdit(ARichEdit: TRichEdit);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    ARichEdit.Lines.SaveToStream(Stream);
    Stream.Position := 0;
    TStrings(FCaption).LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRMPageHeaderFooter.GetStrings(aStrings: {$IFDEF TntUnicode}TTntStrings{$ELSE}TStrings{$ENDIF});
var
  Stream: TStringStream;
begin
  Stream := TStringStream.Create('');
  try
    FCaption.SaveToStream(Stream);
    Stream.Position := 0;
    aStrings.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRMPageHeaderFooter.SetHeight(Value: Integer);
begin
  if Value >= 0 then
    FHeight := Value;
end;

procedure TRMPageHeaderFooter.SetCaption(Value: TStrings);
begin
  FCaption.Assign(Value);
end;

{--------------------------------------------------------------------------------}
{--------------------------------------------------------------------------------}
{TRMScaleOptions}

constructor TRMGridNumOptions.Create;
begin
  inherited Create;
  FText := 'No';
  FNumber := 7;
end;

procedure TRMGridNumOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  Text := TRMGridNumOptions(Source).Text;
  Number := TRMGridNumOptions(Source).Number;
end;

procedure TRMGridNumOptions.SetNumber(Value: Integer);
begin
  if Value >= 0 then
    FNumber := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMScaleOptions}

constructor TRMScaleOptions.Create;
begin
  inherited Create;
  FCenterOnPageH := False;
  FCenterOnPageV := False;
  FFitPageWidth := False;
  FFitPageHeight := False;
  FScaleMode := rmsmAdjust;
  FScaleFactor := 100;
end;

procedure TRMScaleOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  CenterOnPageH := TRMScaleOptions(Source).CenterOnPageH;
  CenterOnPageV := TRMScaleOptions(Source).CenterOnPageV;
  FitPageWidth := TRMScaleOptions(Source).FitPageWidth;
  FitPageHeight := TRMScaleOptions(Source).FitPageHeight;
  ScaleMode := TRMScaleOptions(Source).ScaleMode;
  ScaleFactor := TRMScaleOptions(Source).ScaleFactor
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMGroupItem}

constructor TRMGroupItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FFormNewPage := False;
end;

procedure TRMGroupItem.Assign(Source: TPersistent);
begin
  if Source is TRMGroupItem then
  begin
  end
  else
    inherited Assign(Source);
end;

function TRMGroupItem.GetReport: TComponent;
begin
  if Assigned(Collection) and (Collection is TRMGroupItems) then
    Result := TRMGroupItems(Collection).Report
  else
    Result := nil;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMGroupItems}

constructor TRMGroupItems.Create(aReport: TComponent);
begin
  inherited Create(TRMGroupItem);
  FReport := aReport;
end;

function TRMGroupItems.Add: TRMGroupItem;
begin
  Result := TRMGroupItem(inherited Add);
end;

function TRMGroupItems.GetItem(Index: Integer): TRMGroupItem;
begin
  Result := TRMGroupItem(inherited GetItem(Index));
end;

procedure TRMGroupItems.SetItem(Index: Integer; Value: TRMGroupItem);
begin
  inherited SetItem(Index, Value);
end;

function TRMGroupItems.GetOwner: TPersistent;
begin
  Result := FReport;
end;

procedure TRMGroupItems.Update(Item: TCollectionItem);
begin
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMMasterDatalBandOptions}

constructor TRMMasterDataBandOptions.Create;
begin
  inherited Create;
  FLinesPerPage := 0;
  FColumns := 1;
  FColumnWidth := 200;
  FColumnGap := 20;
  FNewPageAfter := False;
  FHeight := -1;
end;

procedure TRMMasterDataBandOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  LinesPerPage := TRMMasterDataBandOptions(Source).LinesPerPage;
  Columns := TRMMasterDataBandOptions(Source).Columns;
  ColumnWidth := TRMMasterDataBandOptions(Source).ColumnWidth;
  ColumnGap := TRMMasterDataBandOptions(Source).ColumnGap;
  FNewPageAfter := TRMMasterDataBandOptions(Source).NewPageAfter;
  FHeight := TRMMasterDataBandOptions(Source).Height;
  FReprintColumnHeaderOnNewColumn := TRMMasterDataBandOptions(Source).ReprintColumnHeaderOnNewColumn;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMGridFontOptions}

constructor TRMGridFontOptions.Create;
begin
  inherited Create;
  FUseCustomFontSize := False;
  FFont := TFont.Create;
end;

destructor TRMGridFontOptions.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TRMGridFontOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  FUseCustomFontSize := TRMGridFontOptions(Source).FUseCustomFontSize;
  Font.Assign(TRMGridFontOptions(Source).Font);
end;

procedure TRMGridFontOptions.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPageAggr }

procedure TRMPageAggr.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TRMPageAggr then
  begin
    FAutoTotal := TRMPageAggr(Source).AutoTotal;
    FTotalFields := TRMPageAggr(Source).TotalFields;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMGridPageAggrOptions.Create;
begin
  inherited Create;
  FPageSum := TRMPageAggr.Create;
  FPageSumTotal := TRMPageAggr.Create;
end;

destructor TRMGridPageAggrOptions.Destroy;
begin
  FPageSum.Free;
  FPageSumTotal.Free;
  inherited Destroy;
end;

procedure TRMGridPageAggrOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TRMPageAggr then
  begin
    FPageSum.Assign(TRMGridPageAggrOptions(Source).PageSum);
    FPageSumTotal.Assign(TRMGridPageAggrOptions(Source).PageSumTotal);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMReportSettings }

constructor TRMReportSettings.Create;
begin
  inherited;
  FShowProgress := True;
  FInitialZoom := pzDefault;
  FPreviewButtons := [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbPageSetup, pbExit];
  FShowPrintDialog := True;
  FModifyPrepared := False;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomGridReport }

constructor TRMCustomGridReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FReport := nil;
  FAutoBooleanString := '';
  FGridFixedCols := 0;
  FReportOptions := [rmgoStretch, rmgoWordWrap, rmgoGridLines];

  FReportSettings := TRMReportSettings.Create;
  FGroups := TRMGroupItems.Create(Self);
  FPageLayout := TRMPageLayout.Create;
  FPageHeaderMsg := TRMBandMsg.Create;
  FPageFooterMsg := TRMBandMsg.Create;
  FPageCaptionMsg := TRMPageCaptionMsg.Create;

  FGridNumOptions := TRMGridNumOptions.Create;
  FMasterDataBandOptions := TRMMasterDataBandOptions.Create;
  FGridFontOptions := TRMGridFontOptions.Create;

  FRMDataSets := TList.Create;
end;

destructor TRMCustomGridReport.Destroy;
begin
  if RMDialogForm <> nil then
    FreeAndNil(FReport);

  ClearRMDataSets;
  FreeAndNil(FRMDataSets);

  FreeAndNil(FReportSettings);
  FreeAndNil(FGroups);
  FreeAndNil(FPageLayout);
  FreeAndNil(FPageHeaderMsg);
  FreeAndNil(FPageFooterMsg);
  FreeAndNil(FPageCaptionMsg);

  FreeAndNil(FGridNumOptions);
  FreeAndNil(FMasterDataBandOptions);
  FreeAndNil(FGridFontOptions);

  inherited Destroy;
end;

procedure TRMCustomGridReport.SetMemoViewFormat(aView: TRMMemoView; aField: TField);
begin
  if aField = nil then Exit;

  if aField.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
    ftBCD, ftBytes, ftVarBytes, ftAutoInc{$IFDEF COMPILER4_UP}, ftLargeint{$ENDIF}] then
  begin
  	if TNumericField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'N' + TNumericField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftDate, ftDateTime] then
  begin
  	if TDateTimeField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'D' + TDateTimeField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftTime] then
  begin
  	if TDateTimeField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'T' + TDateTimeField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftBoolean] then
  begin
  	if TBooleanField(aField).DisplayValues <> '' then
	    aView.DisplayFormat := 'B' + TBooleanField(aField).DisplayValues;
  end;
end;

function TRMCustomGridReport.AddRMDataSet(const aDataSet: TDataSet): TRMDBDataSet;
var
  i: Integer;
  liComponent: TComponent;

  function _CreateDataSet: TRMDBDataSet;
  var
    liDataSet: TRMDBDataSet;
    i: Integer;
    str: string;
  begin
    liDataSet := TRMDBDataSet.Create(RMDialogForm);
    liDataSet.DataSet := aDataSet;
    FRMDataSets.Add(liDataSet);
    i := 1;
    while True do
    begin
      str := 'RMGridDataSet' + IntToStr(i);
      if RMDialogForm.FindComponent(str) = nil then
      begin
        liDataSet.Name := str;
        Break;
      end;
      Inc(i);
    end;
    Result := liDataSet;
  end;

begin
  for i := 0 to FRMDataSets.Count - 1 do
  begin
    if TRMDBDataSet(FRMDataSets[i]).DataSet = aDataSet then
    begin
      Result := TRMDBDataSet(FRMDataSets[i]);
      Exit;
    end;
  end;

  for i := 0 to RMDialogForm.ComponentCount - 1 do
  begin
    liComponent := RMDialogForm.Components[i];
    if (liComponent is TRMDBDataSet) and (TRMDBDataSet(liComponent).DataSet = aDataSet) then
    begin
      Result := TRMDBDataSet(liComponent);
      Exit;
    end;
  end;

  Result := _CreateDataSet;
end;

procedure TRMCustomGridReport.ClearRMDataSets;
var
  i: Integer;
begin
  for i := 0 to FRMDataSets.Count - 1 do
    TRMDBDataSet(FRMDataSets[i]).Free;
  FRMDataSets.Clear;
end;

procedure TRMCustomGridReport._InternalShowReport(aFlag: Integer);
var
	lPage: TRMGridReportPage;
begin
  ClearRMDataSets;
  Report.ModalPreview := True;
  Report.OnBeforePrintBand := nil;
  FReport.ModalPreview := TRUE;
  try
    FReport.ReportInfo.Title := PageLayout.Title;
    FReport.InitialZoom := FReportSettings.FInitialZoom;
    FReport.PreviewButtons := FReportSettings.FPreviewButtons;
    FReport.Preview := FReportSettings.FPreview;
    FReport.ShowProgress := FReportSettings.FShowProgress;
    FReport.ModifyPrepared := FReportSettings.FModifyPrepared;
    FReport.ShowPrintDialog := FReportSettings.FShowPrintDialog;
    FReport.ReportInfo.Title := FReportSettings.FReportTitle;
    if rmgoRebuildAfterPageChanged in ReportOptions then
      THackReport(FReport).OnAfterPreviewPageSetup := OnAfterPreviewPageSetup
    else
      THackReport(FReport).OnAfterPreviewPageSetup := nil;

    FReport.Clear;
    with PageLayout do
    begin
      FReport.DoublePass := DoublePass;
      THackReport(FReport).PrinterName := PrinterName;
    end;

    if CreateReportFromGrid then
    begin
    	lPage := TRMGridReportPage(FReport.Pages[0]);
      lPage.UseHeaderFooter := True;
      lPage.PageHeaderMsg.Assign(PageHeaderMsg);
      lPage.PageFooterMsg.Assign(PageFooterMsg);
      lPage.PageCaptionMsg.Assign(PageCaptionMsg);

      try
        //        if (rmgoDisableControls in ReportOptions) and (MainDataSet <> nil) and (MainDataSet.DataSet <> nil) then
        //          MainDataSet.DataSet.DisableControls;
        case aFlag of
          1: FReport.ShowReport;
          2: FReport.PrintReport;
          3: FReport.DesignReport;
        end;
      finally
        //        if (rmgoDisableControls in ReportOptions) and (MainDataSet <> nil) and (MainDataSet.DataSet <> nil) then
        //          MainDataSet.DataSet.EnableControls;
      end;
    end;
  finally
  end;
end;

procedure TRMCustomGridReport.ShowReport;
begin
  _InternalShowReport(1);
end;

procedure TRMCustomGridReport.PrintReport;
begin
  _InternalShowReport(2);
end;

procedure TRMCustomGridReport.DesignReport;
begin
  _InternalShowReport(3);
end;

procedure TRMCustomGridReport.BuildReport;
begin
  _InternalShowReport(0);
end;

procedure TRMCustomGridReport.OnAfterPreviewPageSetup(Sender: TObject);
begin
  ChangePageLayout(TRMPageSetting(Sender));
  BuildReport;
end;

function TRMCustomGridReport.PageHeaderFooterSetup: Boolean;
var
  tmpForm: TRMFormEditorHF;
begin
	Result := False;
  tmpForm := TRMFormEditorHF.Create(nil);
  try
    tmpForm.memHeaderLeft.Lines.Assign(PageHeaderMsg.LeftMemo);
    tmpForm.memHeaderCenter.Lines.Assign(PageHeaderMsg.CenterMemo);
    tmpForm.memHeaderRight.Lines.Assign(PageHeaderMsg.RightMemo);
    tmpForm.memHeaderLeft.Font.Assign(PageHeaderMsg.Font);
    tmpForm.memHeaderCenter.Font.Assign(PageHeaderMsg.Font);
    tmpForm.memHeaderRight.Font.Assign(PageHeaderMsg.Font);

    tmpForm.memFooterLeft.Lines.Assign(PageFooterMsg.LeftMemo);
    tmpForm.memFooterCenter.Lines.Assign(PageFooterMsg.CenterMemo);
    tmpForm.memFooterRight.Lines.Assign(PageFooterMsg.RightMemo);
    tmpForm.memFooterLeft.Font.Assign(PageFooterMsg.Font);
    tmpForm.memFooterCenter.Font.Assign(PageFooterMsg.Font);
    tmpForm.memFooterRight.Font.Assign(PageFooterMsg.Font);

    tmpForm.memTitle.Lines.Assign(PageCaptionMsg.TitleMemo);
    tmpForm.memTitle.Font.Assign(PageCaptionMsg.TitleFont);

    tmpForm.memCaptionLeft.Lines.Assign(PageCaptionMsg.CaptionMsg.LeftMemo);
    tmpForm.memCaptionCenter.Lines.Assign(PageCaptionMsg.CaptionMsg.CenterMemo);
    tmpForm.memCaptionRight.Lines.Assign(PageCaptionMsg.CaptionMsg.RightMemo);
    tmpForm.memCaptionLeft.Font.Assign(PageCaptionMsg.CaptionMsg.Font);
    tmpForm.memCaptionCenter.Font.Assign(PageCaptionMsg.CaptionMsg.Font);
    tmpForm.memCaptionRight.Font.Assign(PageCaptionMsg.CaptionMsg.Font);

    if tmpForm.ShowModal = mrOK then
    begin
    	Result := True;
      PageHeaderMsg.LeftMemo.Assign(tmpForm.memHeaderLeft.Lines);
      PageHeaderMsg.CenterMemo.Assign(tmpForm.memHeaderCenter.Lines);
      PageHeaderMsg.RightMemo.Assign(tmpForm.memHeaderRight.Lines);
      PageHeaderMsg.Font.Assign(tmpForm.memHeaderLeft.Font);

      PageFooterMsg.LeftMemo.Assign(tmpForm.memFooterLeft.Lines);
      PageFooterMsg.CenterMemo.Assign(tmpForm.memFooterCenter.Lines);
      PageFooterMsg.RightMemo.Assign(tmpForm.memFooterRight.Lines);
      PageFooterMsg.Font.Assign(tmpForm.memFooterLeft.Font);

      PageCaptionMsg.TitleMemo.Assign(tmpForm.memTitle.Lines);
      PageCaptionMsg.TitleFont.Assign(tmpForm.memTitle.Font);

      PageCaptionMsg.CaptionMsg.LeftMemo.Assign(tmpForm.memCaptionLeft.Lines);
      PageCaptionMsg.CaptionMsg.CenterMemo.Assign(tmpForm.memCaptionCenter.Lines);
      PageCaptionMsg.CaptionMsg.RightMemo.Assign(tmpForm.memCaptionRight.Lines);
      PageCaptionMsg.CaptionMsg.Font.Assign(tmpForm.memCaptionLeft.Font);
    end;
  finally
    tmpForm.Free;
  end;
end;

function TRMCustomGridReport.PageSetup: Boolean;
var
  tmpForm: TRMPageSetupForm;
begin
  Result := False;
  tmpForm := TRMPageSetupForm.Create(Application);
  try
    tmpForm.PageSetting.Title := PageLayout.Title;
    tmpForm.PageSetting.DoublePass := PageLayout.DoublePass;
    tmpForm.PageSetting.PageOr := PageLayout.PageOrientation;
    tmpForm.PageSetting.MarginLeft := RMRound(RMToMMThousandths(PageLayout.LeftMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginTop := RMRound(RMToMMThousandths(PageLayout.TopMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginRight := RMRound(RMToMMThousandths(PageLayout.RightMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginBottom := RMRound(RMToMMThousandths(PageLayout.BottomMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.PageWidth := PageLayout.Width;
    tmpForm.PageSetting.PageHeight := PageLayout.Height;
    tmpForm.PageSetting.PageSize := PageLayout.PageSize;
    tmpForm.PageSetting.PageBin := PageLayout.PageBin;
    tmpForm.PageSetting.PrinterName := PageLayout.PrinterName;
    tmpForm.PageSetting.ColorPrint := PageLayout.ColorPrint;
    tmpForm.PageSetting.ColCount := PageLayout.ColumnCount;
    tmpForm.PageSetting.ColGap := RMFromScreenPixels(PageLayout.ColumnGap, rmutMillimeters);
    if tmpForm.ShowModal = mrOk then
    begin
      ChangePageLayout(tmpForm.PageSetting);
      Result := True;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMCustomGridReport.ChangePageLayout(aPageSetting: TRMPageSetting);
begin
  PageLayout.Title := aPageSetting.Title;
  PageLayout.PrinterName := aPageSetting.PrinterName;
  PageLayout.DoublePass := aPageSetting.DoublePass;
  PageLayout.PageOrientation := aPageSetting.PageOr;
  PageLayout.ColorPrint := aPageSetting.ColorPrint;

  PageLayout.LeftMargin := Round(RMToScreenPixels(aPageSetting.MarginLeft * 1000, rmutMMThousandths));
  PageLayout.TopMargin := Round(RMToScreenPixels(aPageSetting.MarginTop * 1000, rmutMMThousandths));
  PageLayout.RightMargin := Round(RMToScreenPixels(aPageSetting.MarginRight * 1000, rmutMMThousandths));
  PageLayout.BottomMargin := Round(RMToScreenPixels(aPageSetting.MarginBottom * 1000, rmutMMThousandths));

  PageLayout.Width := aPageSetting.PageWidth;
  PageLayout.Height := aPageSetting.PageHeight;
  PageLayout.PageBin := aPageSetting.PageBin;
  PageLayout.PageSize := aPageSetting.PageSize;
  PageLayout.ColumnCount := aPageSetting.ColCount;
  PageLayout.ColumnGap := RMToScreenPixels(aPageSetting.ColGap, rmutMillimeters);
end;

function TRMCustomGridReport.CreateReportFromGrid: Boolean;
begin
  Result := False;
end;

procedure TRMCustomGridReport.SetGroups(Value: TRMGroupItems);
begin
  FGroups.Assign(Value);
end;

function TRMCustomGridReport.GetReport: TRMGridReport;
begin
  if FReport = nil then
  begin
    FReport := TRMGridReport.Create(RMDialogForm);
  end;
  Result := FReport;
end;

procedure TRMCustomGridReport.SetMasterDataBandOptions(Value: TRMMasterDataBandOptions);
begin
  FMasterDataBandOptions.Assign(Value);
end;

procedure TRMCustomGridReport.SetGridNumOptions(Value: TRMGridNumOptions);
begin
  FGridNumOptions.Assign(Value);
end;

procedure TRMCustomGridReport.SetPageLayout(Value: TRMPageLayout);
begin
  FPageLayout.Assign(Value);
end;

procedure TRMCustomGridReport.SetGridFontOptions(Value: TRMGridFontOptions);
begin
  FGridFontOptions.Assign(Value);
end;

procedure TRMCustomGridReport.AssignFont(aView: TRMMemoView; aFont: TFont);
var
  liSaveColor: TColor;
begin
  liSaveColor := aView.Font.Color;
  aView.Font.Assign(aFont);
  if rmgoUseColor in ReportOptions then
    aView.Font.Color := liSaveColor;
end;

procedure TRMCustomGridReport.SetPageHeaderMsg(Value: TRMBandMsg);
begin
  PageHeaderMsg.Assign(Value);
end;

procedure TRMCustomGridReport.SetPageFooterMsg(Value: TRMBandMsg);
begin
  PageFooterMsg.Assign(Value);
end;

procedure TRMCustomGridReport.SetPageCaptionMsg(Value: TRMPageCaptionMsg);
begin
  PageCaptionMsg.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomFormReport }

constructor TRMCustomFormReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReport := nil;
  //  FReportDataSet := nil;
  FormWidth := TStringList.Create;

  FReportOptions := [rmgoStretch, rmgoWordWrap, rmgoGridLines];
  FReportSettings := TRMReportSettings.Create;

  FGroups := TRMGroupItems.Create(Self);
  FPageLayout := TRMPageLayout.Create;

  FPageHeader := TRMPageHeaderFooter.Create;
  FPageHeader.ParentFormReport := Self;
  FPageFooter := TRMPageHeaderFooter.Create;
  FPageFooter.ParentFormReport := Self;
  FColumnFooter := TRMPageHeaderFooter.Create;
  FColumnFooter.ParentFormReport := Self;

  FScaleMode := TRMScaleOptions.Create;
  FGridNumOptions := TRMGridNumOptions.Create;
  FMasterDataBandOptions := TRMMasterDataBandOptions.Create;
  FGridFontOptions := TRMGridFontOptions.Create;
  FAutoBooleanString := '';

  FRMDataSets := TList.Create;
end;

destructor TRMCustomFormReport.Destroy;
begin
  ClearRMDataSets;
  FReportSettings.Free;
  FRMDataSets.Free;
  FGroups.Free;
  FPageLayout.Free;
  FPageHeader.Free;
  FPageFooter.Free;
  FColumnFooter.Free;
  FScaleMode.Free;
  FGridNumOptions.Free;
  if RMDialogForm <> nil then
    FReport.Free;
  //  FReportDataSet.Free;
  FormWidth.Free;
  FMasterDataBandOptions.Free;
  FGridFontOptions.Free;

  inherited Destroy;
end;

procedure TRMCustomFormReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDataSet then
      FDataSet := nil
    else if AComponent = FDetailDataSet then
    	FDetailDataSet := nil;
  end;
end;

procedure TRMCustomFormReport.AssignFont(aView: TRMMemoView; aFont: TFont);
var
  liSaveColor: TColor;
begin
  liSaveColor := aView.Font.Color;
  aView.Font.Assign(aFont);
  if rmgoUseColor in ReportOptions then
    aView.Font.Color := liSaveColor;
end;

procedure TRMCustomFormReport.SetMemoViewFormat(aView: TRMMemoView; aField: TField);
begin
  if aField = nil then Exit;

  if aField.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
    ftBCD, ftBytes, ftVarBytes, ftAutoInc{$IFDEF COMPILER4_UP}, ftLargeint{$ENDIF}] then
  begin
		if TNumericField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'N' + TNumericField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftDate, ftDateTime] then
  begin
  	if TDateTimeField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'D' + TDateTimeField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftTime] then
  begin
  	if TDateTimeField(aField).DisplayFormat <> '' then
	    aView.DisplayFormat := 'T' + TDateTimeField(aField).DisplayFormat;
  end
  else if aField.DataType in [ftBoolean] then
  begin
  	if TBooleanField(aField).DisplayValues <> '' then
	    aView.DisplayFormat := 'B' + TBooleanField(aField).DisplayValues;
  end;
end;

function TRMCustomFormReport.AddRMDataSet(const aDataSet: TDataSet): TRMDBDataSet;
var
  i: Integer;
  liComponent: TComponent;

  function _CreateDataSet: TRMDBDataSet;
  var
    liDataSet: TRMDBDataSet;
    i: Integer;
    str: string;
  begin
    liDataSet := TRMDBDataSet.Create(RMDialogForm);
    liDataSet.DataSet := aDataSet;
    FRMDataSets.Add(liDataSet);
    i := 1;
    while True do
    begin
      str := 'RMGridDataSet' + IntToStr(i);
      if RMDialogForm.FindComponent(str) = nil then
      begin
        liDataSet.Name := str;
        Break;
      end;
      Inc(i);
    end;
    Result := liDataSet;
  end;

begin
  for i := 0 to FRMDataSets.Count - 1 do
  begin
    if TRMDBDataSet(FRMDataSets[i]).DataSet = aDataSet then
    begin
      Result := TRMDBDataSet(FRMDataSets[i]);
      Exit;
    end;
  end;

  for i := 0 to RMDialogForm.ComponentCount - 1 do
  begin
    liComponent := RMDialogForm.Components[i];
    if (liComponent is TRMDBDataSet) and (TRMDBDataSet(liComponent).DataSet = aDataSet) then
    begin
      Result := TRMDBDataSet(liComponent);
      Exit;
    end;
  end;

  Result := _CreateDataSet;
end;

procedure TRMCustomFormReport.ClearRMDataSets;
var
  i: Integer;
begin
  for i := 0 to FRMDataSets.Count - 1 do
    TRMDBDataSet(FRMDataSets[i]).Free;
  FRMDataSets.Clear;
end;

function TRMCustomFormReport.CalcWidth(aWidth: Integer): Integer;
begin
  Result := aWidth;
  if FScaleMode.ScaleMode = rmsmAdjust then
  begin
    if FScaleMode.ScaleFactor <> 100 then
      Result := Round(aWidth * FScaleMode.ScaleFactor / 100);
  end
end;

procedure TRMCustomFormReport.CalcRect(t: TRMView; ParentBand: TRMCustomBandView; aFormWidth: Integer);
var
  liScale: Double;

  procedure _ScaleView;
  begin
    t.spWidth := Round((t.spLeft + t.spWidth) * liScale) - Round(t.spLeft * liScale);
    t.spHeight := Round((t.spTop + t.spHeight) * liScale) - Round(t.spTop * liScale);
    t.spLeft := Round(t.spLeft * liScale);
    t.spTop := ParentBand.spTop + Round(t.spTop * liScale) - Round(ParentBand.spTop * liScale);
    if t is TRMCustomMemoView then
      TRMMemoView(t).Font.Height := -Trunc(TRMMemoView(t).Font.Size * 96 / 72 * liScale);
  end;

begin
  t.spLeft := t.spLeft + OffsX;
  t.spTop := t.spTop + OffsY;
  liScale := FScaleMode.ScaleFactor / 100;
  if FScaleMode.ScaleMode = rmsmAdjust then
  begin
    if FScaleMode.ScaleFactor <> 100 then
      _ScaleView;
  end
  else
  begin
    if FScaleMode.FitPageWidth then //水平缩放
    begin
      liScale := PageWidth / aFormWidth;
      _ScaleView;
    end
    else if (not HaveDetailBand) and FScaleMode.FitPageHeight then
    begin
      liScale := PageHeight / FormHeight;
      _ScaleView;
    end;
  end;

  if FScaleMode.CenterOnPageH then //水平居中
  begin
    t.spLeft := t.spLeft + (PageWidth - Round(aFormWidth * liScale)) div 2;
  end;
  if FScaleMode.CenterOnPageV and (not HaveDetailBand) then //垂直居中
  begin
    t.spTop := t.spTop + (PageHeight - Round(FormHeight * liScale)) div 2;
  end;
end;

procedure TRMCustomFormReport.AddPage;
var
  liPage: TRMReportPage;
begin
  liPage := FReport.Pages.AddReportPage;
  with PageLayout do
  begin
    liPage.PageMargins := Rect(LeftMargin, TopMargin, RightMargin, BottomMargin);
    liPage.ColumnCount := ColumnCount;
    liPage.spColumnGap := ColumnGap;
    liPage.ChangePaper(PageSize, Width, Height, PageBin, PageOrientation);
  end;
end;

procedure TRMCustomFormReport._InternalShowReport(aFlag: Integer);
begin
  ClearRMDataSets;
  Report.ModalPreview := True;
  Report.OnBeforePrintBand := nil;
  MainDataSet := nil;
  FReport.ModalPreview := TRUE;
  try
    FReport.ReportInfo.Title := PageLayout.Title;
    FReport.InitialZoom := FReportSettings.FInitialZoom;
    FReport.PreviewButtons := FReportSettings.FPreviewButtons;
    FReport.Preview := FReportSettings.FPreview;
    FReport.ShowProgress := FReportSettings.FShowProgress;
    FReport.ModifyPrepared := FReportSettings.FModifyPrepared;
    FReport.ShowPrintDialog := FReportSettings.FShowPrintDialog;
    FReport.ReportInfo.Title := FReportSettings.FReportTitle;
    if rmgoRebuildAfterPageChanged in ReportOptions then
      THackReport(FReport).OnAfterPreviewPageSetup := OnAfterPreviewPageSetup
    else
      THackReport(FReport).OnAfterPreviewPageSetup := nil;

    FReport.Pages.Clear;
    with PageLayout do
    begin
      FReport.DoublePass := DoublePass;
      THackReport(FReport).PrinterName := PrinterName;
    end;
    AddPage;

    if CreateReportFromGrid then
    begin
      try
        if (rmgoDisableControls in ReportOptions) and (MainDataSet <> nil) and (MainDataSet.DataSet <> nil) then
          MainDataSet.DataSet.DisableControls;
        case aFlag of
          1: FReport.ShowReport;
          2: FReport.PrintReport;
          3: FReport.DesignReport;
        end;
      finally
        if (rmgoDisableControls in ReportOptions) and (MainDataSet <> nil) and (MainDataSet.DataSet <> nil) then
          MainDataSet.DataSet.EnableControls;
      end;
    end;
  finally
  end;
end;

procedure TRMCustomFormReport.ShowReport;
begin
  _InternalShowReport(1);
end;

procedure TRMCustomFormReport.PrintReport;
begin
  _InternalShowReport(2);
end;

procedure TRMCustomFormReport.DesignReport;
begin
  _InternalShowReport(3);
end;

procedure TRMCustomFormReport.BuildReport;
begin
  _InternalShowReport(0);
end;

procedure TRMCustomFormReport.OnAfterPreviewPageSetup(Sender: TObject);
begin
  ChangePageLayout(TRMPageSetting(Sender));
  BuildReport;
end;

function TRMCustomFormReport.PageSetup: Boolean;
var
  tmpForm: TRMPageSetupForm;
begin
  Result := False;
  tmpForm := TRMPageSetupForm.Create(Application);
  try
    tmpForm.PageSetting.Title := PageLayout.Title;
    tmpForm.PageSetting.DoublePass := PageLayout.DoublePass;
    tmpForm.PageSetting.PageOr := PageLayout.PageOrientation;
    tmpForm.PageSetting.MarginLeft := RMRound(RMToMMThousandths(PageLayout.LeftMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginTop := RMRound(RMToMMThousandths(PageLayout.TopMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginRight := RMRound(RMToMMThousandths(PageLayout.RightMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.MarginBottom := RMRound(RMToMMThousandths(PageLayout.BottomMargin, rmutScreenPixels) / 1000, 1);
    tmpForm.PageSetting.PageWidth := PageLayout.Width;
    tmpForm.PageSetting.PageHeight := PageLayout.Height;
    tmpForm.PageSetting.PageSize := PageLayout.PageSize;
    tmpForm.PageSetting.PageBin := PageLayout.PageBin;
    tmpForm.PageSetting.PrinterName := PageLayout.PrinterName;
    tmpForm.PageSetting.ColorPrint := PageLayout.ColorPrint;
    tmpForm.PageSetting.ColCount := PageLayout.ColumnCount;
    tmpForm.PageSetting.ColGap := RMFromScreenPixels(PageLayout.ColumnGap, rmutMillimeters);
    if tmpForm.ShowModal = mrOk then
    begin
      ChangePageLayout(tmpForm.PageSetting);
      Result := True;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMCustomFormReport.ChangePageLayout(aPageSetting: TRMPageSetting);
begin
  PageLayout.Title := aPageSetting.Title;
  PageLayout.PrinterName := aPageSetting.PrinterName;
  PageLayout.DoublePass := aPageSetting.DoublePass;
  PageLayout.PageOrientation := aPageSetting.PageOr;
  PageLayout.ColorPrint := aPageSetting.ColorPrint;

  PageLayout.LeftMargin := Round(RMToScreenPixels(aPageSetting.MarginLeft * 1000, rmutMMThousandths));
  PageLayout.TopMargin := Round(RMToScreenPixels(aPageSetting.MarginTop * 1000, rmutMMThousandths));
  PageLayout.RightMargin := Round(RMToScreenPixels(aPageSetting.MarginRight * 1000, rmutMMThousandths));
  PageLayout.BottomMargin := Round(RMToScreenPixels(aPageSetting.MarginBottom * 1000, rmutMMThousandths));

  PageLayout.Width := aPageSetting.PageWidth;
  PageLayout.Height := aPageSetting.PageHeight;
  PageLayout.PageBin := aPageSetting.PageBin;
  PageLayout.PageSize := aPageSetting.PageSize;
  PageLayout.ColumnCount := aPageSetting.ColCount;
  PageLayout.ColumnGap := RMToScreenPixels(aPageSetting.ColGap, rmutMillimeters);
end;

function TRMCustomFormReport.CreateReportFromGrid: Boolean;
begin
  Result := False;
end;

procedure TRMCustomFormReport.SetGroups(Value: TRMGroupItems);
begin
  FGroups.Assign(Value);
end;

function TRMCustomFormReport.GetReport: TRMReport;
begin
  if FReport = nil then
  begin
    FReport := TRMReport.Create(RMDialogForm);
  end;
  Result := FReport;
end;

{function TRMCustomFormReport.GetReportDataSet: TRMDBDataSet;
var
  i: Integer;
  str: string;
begin
  if FReportDataSet = nil then
  begin
    FReportDataSet := TRMDBDataSet.Create(RMDialogForm);
    i := 1;
    while True do
    begin
      str := 'RMGridDataSet' + IntToStr(i);
      if RMDialogForm.FindComponent(str) = nil then
      begin
        FReportDataSet.Name := str;
        Break;
      end;
      Inc(i);
    end;
  end;
  Result := FReportDataSet;
end;
}

procedure TRMCustomFormReport.SetPageHeader(Value: TRMPageHeaderFooter);
begin
  FPageHeader.Assign(Value);
end;

procedure TRMCustomFormReport.SetPageFooter(Value: TRMPageHeaderFooter);
begin
  FPageFooter.Assign(Value);
end;

procedure TRMCustomFormReport.SetColumnFooter(Value: TRMPageHeaderFooter);
begin
  FColumnFooter.Assign(Value);
end;

procedure TRMCustomFormReport.SetMasterDataBandOptions(Value: TRMMasterDataBandOptions);
begin
  FMasterDataBandOptions.Assign(Value);
end;

procedure TRMCustomFormReport.SetGridNumOptions(Value: TRMGridNumOptions);
begin
  FGridNumOptions.Assign(Value);
end;

procedure TRMCustomFormReport.SetScaleMode(Value: TRMScaleOptions);
begin
  FScaleMode.Assign(Value);
end;

procedure TRMCustomFormReport.SetPageLayout(Value: TRMPageLayout);
begin
  FPageLayout.Assign(Value);
end;

procedure TRMCustomFormReport.SetGridFontOptions(Value: TRMGridFontOptions);
begin
  FGridFontOptions.Assign(Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFormReportObject}

constructor TRMFormReportObject.Create;
begin
  inherited Create;
  AutoFree := True;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMAddinFormReportObjectInfo}

constructor TRMAddInFormReportObjectInfo.Create(AClassRef: TClass; AObjectClass: TClass);
begin
  inherited Create;
  FClassRef := AClassRef;
  FObjectClass := AObjectClass;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFormReport}

constructor TRMFormReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReportObjects := TList.Create;
  FPrintControl := nil;
  FDetailPrintControl := nil;
  FDataSet := nil;
  FDetailDataSet := nil;
  CanSetDataSet := True;
  FGridFixedCols := 0;
end;

destructor TRMFormReport.Destroy;
begin
  Clear;
  FReportObjects.Free;
  inherited Destroy;
end;

procedure TRMFormReport.Clear;
begin
  while FReportObjects.Count > 0 do
  begin
    TRMFormReportObject(FReportObjects[0]).Free;
    FReportObjects.Delete(0);
  end;
end;

procedure TRMFormReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FPrintControl then
      PrintControl := nil
    else if AComponent = FDetailPrintControl then
    	FDetailPrintControl := nil;
  end;
end;

type
  THackStretcheable = class(TRMStretcheableView)
  end;

function TRMFormReport.CreateReportFromGrid: Boolean;
var
  i, j: Integer;
  liPage: TRMReportPage;
  liBandPageHeader: TRMBandPageHeader;
  liBandColumnHeader: TRMBandColumnHeader;
  liBandMasterData: TRMBandMasterData;
  liBandColumnFooter: TRMBandColumnFooter;
  liBandPageFooter: TRMBandPageFooter;
  liBandReportSummary: TRMBandReportSummary;
  liDetailBandList: TStringList;
  liGroupFooterBands: TList;
  Nexty: Integer;

  procedure _GetFormRect;
  var
    i: Integer;
    liLeft, liTop: Integer;
  begin
    if PrintControl is TScrollingWinControl then
    begin
      with TScrollingWinControl(PrintControl) do
      begin
        HorzScrollBar.Position := 0;
        VertScrollBar.Position := 0;
      end;
    end;

    if PrintControl.ControlCount > 0 then
    begin
      FormHeight := 0;
      liLeft := 99999;
      liTop := 99999;
      for i := 0 to PrintControl.ControlCount - 1 do
      begin
        liLeft := Min(liLeft, PrintControl.Controls[i].Left);
        liTop := Min(liTop, PrintControl.Controls[i].Top);
        FormWidth[0] := IntToStr(Max(StrToInt(FormWidth[0]), PrintControl.Controls[i].Left + PrintControl.Controls[i].Width));
        FormHeight := Max(FormHeight, PrintControl.Controls[i].Top + PrintControl.Controls[i].Height);
      end;
      FormWidth[0] := IntToStr(StrToInt(FormWidth[0]) - liLeft);
      FormHeight := FormHeight - liTop;
    end
    else
    begin
      FormWidth[0] := IntToStr(PrintControl.ClientWidth);
      FormHeight := PrintControl.ClientHeight;
    end;
  end;

  procedure _PrintOneObject(Sender: TControl; aOffsetX, aOffsetY: Integer);
  var
    i: Integer;
    OldOffsX, OldOffsY: Integer;
    liList: TList;
    tmp: TRMFormReportObject;
    liPrintObjectClass: TClass;
    liOwnerDraw: Boolean;
    liFound: Boolean;
    liView: TRMView;
  begin
    OldOffsX := OffsX;
    OldOffsY := OffsY;
    OffsX := aOffsetX;
    OffsY := aOffsetY;
    if Sender is TScrollingWinControl then
    begin
      with TScrollingWinControl(Sender) do
      begin
        HorzScrollBar.Position := 0;
        VertScrollBar.Position := 0;
      end;
    end;

    liPrintObjectClass := nil;
    liOwnerDraw := False;
    liFound := False;
    if Assigned(FOnPrintObject) then
      FOnPrintObject(Self, liPage, Sender, liPrintObjectClass, liOwnerDraw);
      
    if (not liOwnerDraw) and (liPrintObjectClass = nil) then
    begin
      for i := FFormReportList.Count - 1 downto 0 do
      begin
        if Sender is TRMAddInFormReportObjectInfo(FFormReportList[i]).ClassRef then
        begin
          liFound := True;
          liPrintObjectClass := TRMAddInFormReportObjectInfo(FFormReportList[i]).ObjectClass;
          Break;
        end;
      end;
    end;

    if (not liOwnerDraw) and (liPrintObjectClass <> nil) then
    begin
      tmp := TRMFormReportObject(liPrintObjectClass.NewInstance);
      tmp.Create;
      try
        liView := nil;
        tmp.OnGenerate_Object(Self, liPage, Sender, liView);
        if (liView <> nil) and Assigned(FOnAfterCreateObject) then
          FOnAfterCreateObject(Sender, liView);
          
        if not tmp.AutoFree then
          FReportObjects.Add(tmp);
      finally
        if tmp.AutoFree then
          tmp.Free;
      end;
    end;

    liFound := liFound or liOwnerDraw;
    if (not liFound) and (Sender is TWinControl) and (TWinControl(Sender).ControlCount > 0) then
    begin
      liList := TList.Create;
      try
        for i := 0 to TWinControl(Sender).ControlCount - 1 do
          liList.Add(TWinControl(Sender).Controls[I]);

        liList.Sort(ListSortCompare); //按上到下、左到右排序
        for i := 0 to liList.Count - 1 do
          _PrintOneObject(TControl(liList[i]), aOffsetX + TWinControl(Sender).Left, aOffsetY + TWinControl(Sender).Top);
      finally
        liList.Free;
      end;
    end;

    OffsX := OldOffsX;
    OffsY := OldOffsY;
  end;

  procedure _MakeGroups;
  var
    i, j, liNextY: Integer;
    liBandGroupHeader: TRMBandGroupHeader;
    liBandGroupFooter: TRMBandGroupFooter;
    liDataSet: TDataSet;
  begin
    if (MainDataSet <> nil) and (MainDataSet.DataSet <> nil) then
      liDataSet := MainDataSet.DataSet
    else
      Exit;

    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(Report.Pages[i]);
      for j := 0 to FGroups.Count - 1 do
      begin
        if (Length(FGroups[j].GroupFieldName) > 0) then
        begin
          liBandGroupHeader := TRMBandGroupHeader.Create;
          liBandGroupHeader.ParentPage := liPage;
          liBandGroupHeader.NewPageAfter := FGroups[j].FormNewPage;
          if liDataSet.FindField(FGroups[j].GroupFieldName) <> nil then
            liBandGroupHeader.GroupCondition := Format('[%s."%s"]', [AddRMDataSet(liDataSet).Name, FGroups[j].GroupFieldName])
          else
            liBandGroupHeader.GroupCondition := FGroups[j].GroupFieldName;
          liBandGroupHeader.SetspBounds(0, NextY + 1, 0, 0);
          Inc(NextY, 1);
        end;
      end;

      liNextY := NextY;
      for j := FGroups.Count - 1 downto 0 do
      begin
        if Length(FGroups[j].GroupFieldName) > 0 then
        begin
          liBandGroupFooter := TRMBandGroupFooter.Create;
          liBandGroupFooter.ParentPage := liPage;
          liBandGroupFooter.SetspBounds(0, liNextY + 1, 0, 0);
          Inc(liNextY, 1);
          liGroupFooterBands.Add(liBandGroupFooter);
        end;
      end;
    end;
  end;

  procedure _MakeGroupFooter;
  var
    i, j, k, SaveNextY: Integer;
    liGroupFooter: TRMBandGroupFooter;
    liPage: TRMReportPage;
  begin
    if liGroupFooterBands.Count > 0 then
    begin
      k := 0;
      SaveNextY := NextY;
      for i := 0 to Report.Pages.Count - 1 do
      begin
        NextY := SaveNextY;
        liPage := TRMReportPage(Report.Pages[i]);
        liGroupFooter := TRMBandGroupFooter(liGroupFooterBands[k]);
        liGroupFooter.spTop := NextY;
        for j := 0 to FGroupFooterViews.Count - 1 do
        begin
          if liPage.FindObject(TRMView(FGroupFooterViews[j]).Name) <> nil then
          begin
            TRMView(FGroupFooterViews[j]).spTop := TRMView(FGroupFooterViews[j]).spTop + NextY;
            CalcRect(TRMView(FGroupFooterViews[j]), liGroupFooterBands[0], StrToInt(FormWidth[i]));
            TRMView(liGroupFooterBands[k]).spHeight := Max(TRMView(liGroupFooterBands[k]).spHeight, TRMView(FGroupFooterViews[j]).spTop + TRMView(FGroupFooterViews[j]).spHeight - TRMView(liGroupFooterBands[k]).spTop);
          end;
        end;

        Inc(k);
        NextY := liGroupFooter.spTop + liGroupFooter.spHeight + 1;
        for j := k to liGroupFooterBands.Count - 1 do
        begin
          if liPage.FindObject(TRMView(liGroupFooterBands[j]).Name) <> nil then
          begin
            TRMView(liGroupFooterBands[j]).spTop := NextY;
            NextY := NextY + TRMView(liGroupFooterBands[j]).spHeight + 1;
            Inc(k);
          end;
        end;
      end;
    end;
  end;

  procedure _MakePageHeader;
  var
    i: Integer;
    liPage: TRMReportPage;
    t: TRMRichView;
    liFormWidth: Integer;

    procedure _MakeColumnHeader;
    var
      i: Integer;
      t: TRMView;
    begin
      if FColumnHeaderViews.Count = 0 then Exit;

      liBandColumnHeader := TRMBandColumnHeader.Create;
      liBandColumnHeader.ParentPage := liPage;
      liBandColumnHeader.spLeft := 0;
      liBandColumnHeader.spTop := NextY;
      liBandColumnHeader.spWidth := 0;
      liBandColumnHeader.spHeight := 0;
      liBandColumnHeader.ReprintOnNewColumn := MasterDataBandOptions.ReprintColumnHeaderOnNewColumn;
      for i := 0 to FColumnHeaderViews.Count - 1 do
      begin
        t := TRMView(FColumnHeaderViews[i]);
        if liPage.FindObject(t.Name) <> nil then
        begin
          CalcRect(t, liBandColumnHeader, liFormWidth);
          t.spTop := t.spTop + liBandColumnHeader.spTop;
          if liBandColumnHeader.spHeight < t.spTop + t.spHeight - liBandColumnHeader.spTop then
            liBandColumnHeader.spHeight := t.spTop + t.spHeight - liBandColumnHeader.spTop;
        end;
      end;
    end;

  begin
    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(Report.Pages[i]);
      liFormWidth := StrToInt(FormWidth[i]);

      liBandPageHeader := TRMBandPageHeader.Create;
      liBandPageHeader.ParentPage := liPage;
      liBandPageHeader.spLeft := 0;
      liBandPageHeader.spTop := 0;
      liBandPageHeader.spWidth := 0;
      liBandPageHeader.spHeight := 0;
      NextY := 0;
      if Length(PageHeader.Caption.Text) > 0 then //标题
      begin
        t := TRMRichView(RMCreateObject(rmgtAddin, 'TRMRichView'));
        PageHeader.GetStrings(t.RichEdit.Lines);
        if t.RichEdit.Lines.Count = 0 then
        begin
          t.Free;
        end
        else
        begin
          t.ParentPage := liPage;
          t.TextOnly := True;
          t.LeftFrame.Visible := False;
          t.TopFrame.Visible := False;
          t.RightFrame.Visible := False;
          t.BottomFrame.Visible := False;
          t.spLeft := 0;
          t.spWidth := liPage.PrinterInfo.ScreenPageWidth - PageLayout.LeftMargin - PageLayout.RightMargin;
          t.spTop := liBandPageHeader.spTop;
          if PageHeader.Height <= 0 then
          begin
            THackView(t).CalcGaps;
            t.spHeight := RMToScreenPixels(THackStretcheable(t).CalcHeight, rmutMMThousandths) + 2;
          end
          else
            t.spHeight := PageHeader.Height;
          t.TextOnly := False;
          NextY := t.spHeight + 2;
          liBandPageHeader.spHeight := NextY;
        end;
      end;

      _MakeColumnHeader;
    end;
  end;

  procedure _MakeColumnFooter;
  var
    i, j: Integer;
    liPage: TRMReportPage;
    t: TRMRichView;
  begin
    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(Report.Pages[i]);

      liBandColumnFooter := TRMBandColumnFooter.Create;
      liBandColumnFooter.ParentPage := liPage;
      liBandColumnFooter.spLeft := 0;
      liBandColumnFooter.spTop := NextY;
      liBandColumnFooter.spHeight := 0;
      for j := 0 to FColumnFooterViews.Count - 1 do
      begin
        if liPage.FindObject(TRMView(FColumnFooterViews[j]).Name) <> nil then
        begin
          TRMView(FColumnFooterViews[j]).spTop := TRMView(FColumnFooterViews[j]).spTop - (FGridTop + FGridHeight);
          TRMView(FColumnFooterViews[j]).spTop := TRMView(FColumnFooterViews[j]).spTop + liBandColumnFooter.spTop;
          CalcRect(TRMView(FColumnFooterViews[j]), liBandColumnFooter, StrToInt(FormWidth[i]));
          if liBandColumnFooter.spHeight < TRMView(FColumnFooterViews[j]).spTop + TRMView(FColumnFooterViews[j]).spHeight - liBandColumnFooter.spTop then
            liBandColumnFooter.spHeight := TRMView(FColumnFooterViews[j]).spTop + TRMView(FColumnFooterViews[j]).spHeight - liBandColumnFooter.spTop;
        end;
      end;

      if Length(ColumnFooter.Caption.Text) > 0 then
      begin
        t := TRMRichView(RMCreateObject(rmgtAddin, 'TRMRichView'));
        ColumnFooter.GetStrings(t.RichEdit.Lines);
        if t.RichEdit.Lines.Count = 0 then
          t.Free
        else
        begin
          t.ParentPage := liPage;
          t.TextOnly := True;
          t.LeftFrame.Visible := False;
          t.TopFrame.Visible := False;
          t.RightFrame.Visible := False;
          t.BottomFrame.Visible := False;
          t.spLeft := 0;
          t.spWidth := liPage.PrinterInfo.ScreenPageWidth - PageLayout.LeftMargin - PageLayout.RightMargin;
          t.spTop := liBandColumnFooter.spTop + liBandColumnFooter.spHeight;
          if ColumnFooter.Height <= 0 then
          begin
            THackView(t).CalcGaps;
            t.spHeight := RMToScreenPixels(THackStretcheable(t).CalcHeight, rmutMMThousandths) + 2;
          end
          else
            t.spHeight := ColumnFooter.Height;
          t.TextOnly := False;
          liBandColumnFooter.spHeight := liBandColumnFooter.spHeight + t.spHeight + 2;
        end;
      end;
    end;
  end;

  procedure _MakePageFooter;
  var
    i, j: Integer;
    liPage: TRMReportPage;
    t: TRMRichView;
  begin
    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(Report.Pages[i]);

      liBandPageFooter := TRMBandPageFooter.Create;
      liBandPageFooter.ParentPage := liPage;
      liBandPageFooter.spLeft := 0;
      liBandPageFooter.spTop := liBandColumnFooter.spTop + liBandColumnFooter.spHeight + 1;
      liBandPageFooter.spHeight := 3;
      for j := 0 to FPageFooterViews.Count - 1 do
      begin
        if liPage.FindObject(TRMView(FPageFooterViews[j]).Name) <> nil then
        begin
          TRMView(FPageFooterViews[j]).spTop := TRMView(FPageFooterViews[j]).spTop - (liBandColumnFooter.spTop + 1 {FGridTop + FGridHeight});
          TRMView(FPageFooterViews[j]).spTop := TRMView(FPageFooterViews[j]).spTop + liBandPageFooter.spTop;
          CalcRect(TRMView(FPageFooterViews[j]), liBandPageFooter, StrToInt(FormWidth[i]));
          if liBandPageFooter.spHeight < TRMView(FPageFooterViews[j]).spTop + TRMView(FPageFooterViews[j]).spHeight - liBandPageFooter.spTop then
            liBandPageFooter.spHeight := TRMView(FPageFooterViews[j]).spTop + TRMView(FPageFooterViews[j]).spHeight - liBandPageFooter.spTop;
        end;
      end;

      if Length(PageFooter.Caption.Text) > 0 then
      begin
        t := TRMRichView(RMCreateObject(rmgtAddin, 'TRMRichView'));
        PageFooter.GetStrings(t.RichEdit.Lines);
        if t.RichEdit.Lines.Count = 0 then
          t.Free
        else
        begin
          t.ParentPage := liPage;
          t.TextOnly := True;
          t.LeftFrame.Visible := False;
          t.TopFrame.Visible := False;
          t.RightFrame.Visible := False;
          t.BottomFrame.Visible := False;
          t.spLeft := 0;
          t.spWidth := liPage.PrinterInfo.ScreenPageWidth - PageLayout.LeftMargin - PageLayout.RightMargin;
          t.spTop := liBandPageFooter.spTop + liBandPageFooter.spHeight + 2;
          if PageFooter.Height <= 0 then
          begin
            THackView(t).CalcGaps;
            t.spHeight := RMToScreenPixels(THackStretcheable(t).CalcHeight, rmutMMThousandths) + 2;
          end
          else
            t.spHeight := PageFooter.Height;
          t.TextOnly := False;
          liBandPageFooter.spHeight := liBandPageFooter.spHeight + t.spHeight + 2;
        end;
      end;
    end;
  end;

  procedure _MakePageDetail;
  var
    i, j: Integer;
  begin
    liBandMasterData := nil;
    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(Report.Pages[i]);

      if FPageDetailViews.Count > 0 then
      begin
        liBandMasterData := TRMBandMasterData.Create;
        liBandMasterData.ParentPage := liPage;
        liBandMasterData.Name := 'MasterData';
        if CanSetDataSet and (MainDataSet <> nil) then
          liBandMasterData.DataSetName := MainDataSet.Name
        else
          liBandMasterData.DataSetName := '';
        liBandMasterData.spLeft := 0;
        liBandMasterData.spTop := NextY + 1;
        liBandMasterData.spHeight := 0;
        liBandMasterData.AutoAppendBlank := rmgoAppendBlank in ReportOptions;
        liBandMasterData.Stretched := rmgoStretch in ReportOptions;

        liBandMasterData.LinesPerPage := MasterDataBandOptions.LinesPerPage;
        liBandMasterData.Columns := MasterDataBandOptions.Columns;
        liBandMasterData.ColumnWidth := MasterDataBandOptions.ColumnWidth;
        liBandMasterData.ColumnGap := MasterDataBandOptions.ColumnGap;
        liBandMasterData.NewPageAfter := MasterDataBandOptions.NewPageAfter;

        liDetailBandList.Add(liBandMasterData.Name);

        for j := 0 to FPageDetailViews.Count - 1 do
        begin
          if liPage.FindObject(TRMView(FPageDetailViews[j]).Name) <> nil then
          begin
            TRMView(FPageDetailViews[j]).spTop := TRMView(FPageDetailViews[j]).spTop + liBandMasterData.spTop;
            CalcRect(TRMView(FPageDetailViews[j]), liBandMasterData, StrToInt(FormWidth[i]));
            liBandMasterData.spHeight := Max(liBandMasterData.spHeight, TRMView(FPageDetailViews[j]).spTop + TRMView(FPageDetailViews[j]).spHeight - liBandMasterData.spTop);
          end;
        end;
      end;
    end;
  end;

  procedure _MakeReportSummary;
  var
    i, j: Integer;
    liPage: TRMReportPage;
  begin
    if (FGroupFooterViews.Count > 0) and (liGroupFooterBands.Count = 0) then
    begin
      NextY := liBandPageFooter.spTop + liBandPageFooter.spHeight + 1;
      for i := 0 to Report.Pages.Count - 1 do
      begin
        liPage := TRMReportPage(Report.Pages[i]);

        liBandReportSummary := TRMBandReportSummary.Create;
        liBandReportSummary.ParentPage := liPage;
        liBandReportSummary.SetspBounds(0, NextY, 0, 0);
        for j := 0 to FGroupFooterViews.Count - 1 do
        begin
          if liPage.FindObject(TRMView(FGroupFooterViews[j]).Name) <> nil then
          begin
            TRMView(FGroupFooterViews[j]).spTop := TRMView(FGroupFooterViews[j]).spTop + NextY;
            CalcRect(TRMView(FGroupFooterViews[j]), liBandReportSummary, StrToInt(FormWidth[i]));
            liBandReportSummary.spHeight := Max(liBandReportSummary.spHeight, TRMView(FGroupFooterViews[j]).spTop + TRMView(FGroupFooterViews[j]).spHeight - liBandReportSummary.spTop);
          end;
        end;
      end;
    end;
  end;

begin
  Clear;
  FormWidth.Clear;
  FormWidth.Add('0');
  Result := FALSE;
  if PrintControl = nil then Exit;

  liPage := TRMReportPage(Report.Pages[0]);
  FColumnHeaderViews := TList.Create;
  FPageDetailViews := TList.Create;
  FPageFooterViews := TList.Create;
  FColumnFooterViews := TList.Create;
  FGroupFooterViews := TList.Create;
  liGroupFooterBands := TList.Create;
  liDetailBandList := TStringList.Create;
  liBandColumnHeader := nil;
  try
    PageWidth := liPage.PrinterInfo.ScreenPageWidth - PageLayout.LeftMargin - PageLayout.RightMargin;
    PageHeight := liPage.PrinterInfo.ScreenPageHeight - PageLayout.TopMargin - PageLayout.BottomMargin;
    _GetFormRect;
    DrawOnPageFooter := False;
    FGridTop := 0;
    FGridHeight := 0;

    _PrintOneObject(PrintControl, -PrintControl.Left, -PrintControl.Top);

    if not (rmgoSelectedRecordsOnly in ReportOptions) and
      (FPageDetailViews.Count <= 0) and (Assigned(FDataSet)) then
    begin
      MainDataSet := AddRMDataSet(FDataSet);
      for i := 0 to FColumnHeaderViews.Count - 1 do
      begin
        FPageDetailViews.Add(FColumnHeaderViews[i]);
      end;
      FColumnHeaderViews.Clear;
    end;

    HaveDetailBand := FPageDetailViews.Count > 0;
    _MakePageHeader; // PageHeader;

    if liBandColumnHeader <> nil then
      NextY := liBandColumnHeader.spTop + liBandColumnHeader.spHeight
    else
      NextY := liBandPageHeader.spTop + liBandPageHeader.spHeight;

    if HaveDetailBand then _MakeGroups;

    _MakePageDetail; // PageDetail;
    if FPageDetailViews.Count > 0 then
      NextY := liBandMasterData.spTop + liBandMasterData.spHeight + 1
    else
      NextY := liBandPageHeader.spTop + liBandPageHeader.spHeight + 1;

    _MakeGroupFooter; // Group Footer;

    _MakeColumnFooter;
    _MakePageFooter; // 页脚
    _MakeReportSummary;
    for i := 0 to FReport.Pages.Count - 1 do
    begin
      liPage := TRMReportPage(FReport.Pages[i]);
      for j := 0 to FGroupFooterViews.Count - 1 do
      begin
        if TRMView(FGroupFooterViews[j]).ObjectType = rmgtCalcMemo then
        begin
          if liPage.FindObject(TRMView(FGroupFooterViews[j]).Name) <> nil then
            TRMCalcMemoView(FGroupFooterViews[j]).CalcOptions.AggrBandName := liDetailBandList[i];
        end;
      end;
    end;

    if liBandMasterData = nil then
    begin
      liBandMasterData := TRMBandMasterData.Create;
      liBandMasterData.ParentPage := liPage;
      liBandMasterData.Name := 'MasterData';
      liBandMasterData.DataSetName := '1';
      liBandMasterData.SetspBounds(liBandPageHeader.spLeft, liBandPageHeader.spTop,
        liBandPageHeader.spRight, liBandPageHeader.spBottom);
      liPage.Objects.Delete(liPage.Objects.IndexOf(liBandPageHeader));
    end;

    Result := True;
  finally
    FColumnHeaderViews.Free;
    FPageDetailViews.Free;
    FPageFooterViews.Free;
    FColumnFooterViews.Free;
    FGroupFooterViews.Free;
    liGroupFooterBands.Free;
    liDetailBandList.Free;
  end;
end;

type
  THackControl = class(TControl)
  end;

  THackLabel = class(TCustomLabel)
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  {TRMPrintControl}

procedure TRMPrintControl.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtMemo, '');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  //lxj
  t.spWidth := aControl.Width + 8;
  //  t.spWidth := Control.Width + 4;
  t.spHeight := aControl.Height + 4;
  TRMMemoView(t).Font.Assign(THackControl(aControl).Font);
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

  if aControl is TCustomMemo then
  begin
    if aControl is TDBMemo then
    begin
      try
        ds := TDBMemo(aControl).DataSource;
        t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBMemo(aControl).DataField]);
      except
      end;
    end
    else
      t.Memo.Assign(TCustomMemo(aControl).Lines);
  end
  else if aControl is TCustomListBox then
  begin
    if aControl is TDBListBox then
    begin
      try
        ds := TDBListBox(aControl).DataSource;
        t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBListBox(aControl).DataField]);
      except
      end;
    end
    else
      t.Memo.Assign(TCustomListBox(aControl).Items);
    TRMMemoView(t).VAlign := rmvCenter;
  end
  else if aControl is TCustomLabel then
  begin
    if aControl is TDBText then
    begin
      try
        ds := TDBText(aControl).DataSource;
        t.Memo.Text := Format('[%s.s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBText(aControl).DataField]);
        aFormReport.SetMemoViewFormat(TRMMemoView(t), ds.DataSet.FieldByName(TDBText(aControl).DataField));
        case ds.DataSet.FieldByName(TDBText(aControl).DataField).Alignment of
          taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
          taRightJustify: TRMMemoView(t).HAlign := rmhRight;
          taCenter: TRMMemoView(t).HAlign := rmhCenter;
        end;
      except
      end;
    end
    else
      t.Memo.Add(THackLabel(aControl).Caption);

    t.spTop := t.spTop - 2;
    TRMMemoView(t).WordWrap := THackLabel(aControl).WordWrap;
    case THackLabel(aControl).Layout of
      tlBottom: TRMMemoView(t).VAlign := rmvBottom;
      tlCenter: TRMMemoView(t).VAlign := rmvCenter;
      tlTop: TRMMemoView(t).VAlign := rmvTop;
    end;
    case THackLabel(aControl).Alignment of
      taCenter: TRMMemoView(t).HAlign := rmhCenter;
      taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(t).HAlign := rmhRight;
    end;
  end
  else
  begin
    t.Memo.Add(THackControl(aControl).Caption);
  end;

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintEdit}

procedure TRMPrintEdit.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtMemo, '');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + (aControl.Width - aControl.ClientWidth) div 2 + aFormReport.OffsX;
  t.spTop := aControl.Top + (aControl.Height - aControl.ClientHeight) div 2 + aFormReport.OffsY;
  t.spWidth := aControl.ClientWidth;
  t.spHeight := aControl.ClientHeight;
  TRMMemoView(t).VAlign := rmvCenter;

  if aControl is TDBEdit then
  begin
    try
      ds := TDBEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBEdit(aControl).DataField]);
      case ds.DataSet.FieldByName(TDBEdit(aControl).DataField).Alignment of
        taLeftJustify: TRMMemoView(t).HAlign := rmhLeft;
        taRightJustify: TRMMemoView(t).HAlign := rmhRight;
        taCenter: TRMMemoView(t).HAlign := rmhCenter;
      end;
      aFormReport.SetMemoViewFormat(TRMMemoView(t), ds.DataSet.FieldByName(TDBEdit(aControl).DataField));
    except
    end;
  end
  else if aControl is TDBComboBox then
  begin
    try
      ds := TDBComboBox(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name,
        TDBComboBox(aControl).DataField]);
    except
    end;
  end
  else if aControl is TDBLookupComboBox then
  begin
    try
      ds := TDBLookupComboBox(aControl).ListSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name,
        RMGetOneField(TDBLookupComboBox(aControl).ListField)]);
      aFormReport.SetMemoViewFormat(TRMMemoView(t), ds.DataSet.FieldByName(RMGetOneField(TDBLookupComboBox(aControl).ListField)));
    except
    end;
  end
  else
    t.Memo.Add(THackControl(aControl).Text);
  TRMMemoView(t).Font.Assign(THackControl(aControl).Font);
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
{TRMPrintImage}

procedure TRMPrintImage.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtPicture, '');
  t.ParentPage := aPage;
  t.LeftFrame.spWidth := 0;
  t.TopFrame.spWidth := 0;
  t.RightFrame.spWidth := 0;
  t.BottomFrame.spWidth := 0;
  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := aControl.Width;
  t.spHeight := aControl.Height;
  if aControl is TImage then
  begin
    if TImage(aControl).Picture.Graphic <> nil then
      TRMPictureView(t).Picture.Assign(TImage(aControl).Picture);
    TRMPictureView(t).PictureCenter := TImage(aControl).Center;
    TRMPictureView(t).PictureStretched := TImage(aControl).Stretch;
    TRMPictureView(t).PictureRatio := False;
  end
  else if aControl is TDBImage then
  begin
    try
      ds := TDBImage(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBImage(aControl).DataField]);
    except
    end;
    TRMPictureView(t).PictureCenter := TImage(aControl).Center;
    TRMPictureView(t).PictureStretched := TImage(aControl).Stretch;
    TRMPictureView(t).PictureRatio := False;
  end;
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
{TRMPrintRichEdit}

procedure TRMPrintRichEdit.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtAddin, 'TRMRichView');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := aControl.Width + 2;
  t.spHeight := aControl.Height + 2;
  if aControl is TDBRichEdit then
  begin
    try
      ds := TDBEdit(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBEdit(aControl).DataField]);
    except
    end;
  end
  else
    TRMRichView(t).RichEdit.Lines.Assign(TCustomRichEdit(aControl).Lines);
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
{TRMPrintShape}

procedure TRMPrintShape.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
begin
  if ((TShape(aControl).Shape = stRectangle) or (TShape(aControl).Shape = stRoundRect)) and
    ((aControl.Width <= 2) or (aControl.Height <= 2)) then
  begin
    t := RMCreateObject(rmgtMemo, '');
    t.ParentPage := aPage;
    if aControl.Width <= 2 then
    begin
      t.LeftFrame.spWidth := aControl.Width;
      t.TopFrame.spWidth := aControl.Width;
      t.RightFrame.spWidth := aControl.Width;
      t.BottomFrame.spWidth := aControl.Width;
    end
    else if aControl.Height <= 2 then
    begin
      t.LeftFrame.spWidth := aControl.Height;
      t.TopFrame.spWidth := aControl.Height;
      t.RightFrame.spWidth := aControl.Height;
      t.BottomFrame.spWidth := aControl.Height;
    end
    else
    begin
      t.LeftFrame.spWidth := 1;
      t.TopFrame.spWidth := 1;
      t.RightFrame.spWidth := 1;
      t.BottomFrame.spWidth := 1;
    end;
    t.RightFrame.Visible := False;
    t.BottomFrame.Visible := False;
    if aControl.Width > aControl.Height then
    begin
      t.LeftFrame.Visible := False;
      t.TopFrame.Visible := True;
    end
    else
    begin
      t.LeftFrame.Visible := True;
      t.TopFrame.Visible := False;
    end;
  end
  else
  begin
    t := TRMShapeView(RMCreateObject(rmgtShape, ''));
    t.ParentPage := aPage;
    case TShape(aControl).Shape of
      stRectangle: TRMShapeView(t).Shape := rmskRectangle;
      stRoundRect: TRMShapeView(t).Shape := rmskRoundRectangle;
      stSquare: TRMShapeView(t).Shape := rmskSquare;
      stRoundSquare: TRMShapeView(t).Shape := rmskRoundSquare;
      stEllipse: TRMShapeView(t).Shape := rmskEllipse;
      stCircle: TRMShapeView(t).Shape := rmskCircle;
    end;
    TRMShapeView(t).Pen.Assign(TShape(aControl).Pen);
    t.LeftFrame.spWidth := TShape(aControl).Pen.Width;
    t.TopFrame.spWidth := TShape(aControl).Pen.Width;
    t.RightFrame.spWidth := TShape(aControl).Pen.Width;
    t.BottomFrame.spWidth := TShape(aControl).Pen.Width;
    t.LeftFrame.Visible := False;
    t.TopFrame.Visible := False;
    t.RightFrame.Visible := False;
    t.BottomFrame.Visible := False;
  end;

  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := aControl.Width;
  t.spHeight := aControl.Height;

  t.FillColor := TShape(aControl).Brush.Color;

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintCheckBox}
type
  THackCheckBox = class(TCustomCheckBox)
  end;

procedure TRMPrintCheckBox.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
var
  ds: TDataSource;
begin
  t := RMCreateObject(rmgtAddin, 'TRMCheckBoxView');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := 18;
  t.spHeight := aControl.Height + 2;
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

  if aControl is TDBCheckBox then
  begin
    try
      ds := TDBCheckBox(aControl).DataSource;
      t.Memo.Text := Format('[%s."%s"]', [aFormReport.AddRMDataSet(ds.DataSet).Name, TDBCheckBox(aControl).DataField]);
    except
    end;
  end
  else
  begin
    if THackCheckBox(aControl).Checked then
      t.Memo.Add('1')
    else
      t.Memo.Add('0');
  end;

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);

  t := RMCreateObject(rmgtMemo, '');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + aFormReport.OffsX + 18;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := aControl.Width + 2 - 18;
  t.spHeight := aControl.Height + 2;
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

  TRMMemoView(t).VAlign := rmvCenter;
  t.Memo.Text := THackCheckBox(aControl).Caption;

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrintDateTimePicker}

procedure TRMPrintDateTimePicker.OnGenerate_Object(aFormReport: TRMFormReport;
  aPage: TRMReportPage; aControl: TControl; var t: TRMView);
begin
  t := RMCreateObject(rmgtMemo, '');
  t.ParentPage := aPage;
  t.spLeft := aControl.Left + aFormReport.OffsX;
  t.spTop := aControl.Top + aFormReport.OffsY;
  t.spWidth := aControl.Width + 2;
  t.spHeight := aControl.Height + 2;
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

  if TDateTimePicker(aControl).Kind = dtkDate then
    t.Memo.Text := DateToStr(TDateTimePicker(aControl).Date)
  else
    t.Memo.Text := TimeToStr(TDateTimePicker(aControl).Date);

  if aFormReport.DrawOnPageFooter then
    aFormReport.ColumnFooterViews.Add(t)
  else
    aFormReport.ColumnHeaderViews.Add(t);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPrintListView }

constructor TRMPrintListView.Create;
begin
  inherited Create;
  AutoFree := False;
end;

destructor TRMPrintListView.Destroy;
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

procedure TRMPrintListView.SetMemos;
var
  i: Integer;
  liView: TRMView;
  s: string;
  liListItem: TListItem;
begin
  liListItem := THackListView(FListView).Items[FUserDataset.RecordNo];
  if liListItem = nil then Exit;
  for i := 0 to FList.Count - 1 do
  begin
    liView := FFormReport.Report.FindObject(FList[i]);
    if liView <> nil then
    begin
      if i = 0 then
        s := liListItem.Caption
      else
      begin
        s := '';
        if i - 1 < liListItem.SubItems.Count then
          s := liListItem.SubItems[i - 1];
      end;
      liView.Memo.Text := s;
    end;
  end;
end;

procedure TRMPrintListView.OnUserDatasetCheckEOF(Sender: TObject; var Eof: Boolean);
begin
  Eof := FUserDataset.RecordNo >= THackListView(FListView).Items.Count;
end;

procedure TRMPrintListView.OnUserDatasetFirst(Sender: TObject);
begin
  SetMemos;
end;

procedure TRMPrintListView.OnUserDatasetNext(Sender: TObject);
begin
  SetMemos;
end;

procedure TRMPrintListView.OnUserDatasetPrior(Sender: TObject);
begin
  SetMemos;
end;

procedure TRMPrintListView.OnBeforePrintBandEvent(Band: TRMBand; var PrintBand: Boolean);
begin
  PrintBand := True;
end;

procedure TRMPrintListView.OnGenerate_Object(aFormReport: TRMFormReport; aPage: TRMReportPage;
  aControl: TControl; var t: TRMView);
var
  liView: TRMView;
  i, tmpx, tmpx0, NextTop: Integer;
  liListView: THackListView;
  liPageNo, liNum, liListViewTitleHeight: Integer;
  liFlagFirstColumn: Boolean;
  liCol: TListColumn;
  liRowHeight: Integer;
  liPage: TRMReportPage;

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
      t.GapLeft := 0;
      t.GapTop := 0;
      t.SetspBounds(aView.spLeft, aFormReport.GridTop + aFormReport.GridHeight, aView.spWidth, 2);
      t.Stretched := rmgoStretch in aFormReport.ReportOptions;
      aList.Add(t);
    end;
  end;

  procedure _MakeOneHeader(aIndex: Integer);
  var
    liCol: TListColumn;
  begin
    liCol := liListView.Columns[aIndex];
    liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    liView.ParentPage := liPage;
    liView.Memo.Text := liCol.Caption;
    liView.spLeft := tmpx;
    liView.spTop := NextTop;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liListViewTitleHeight;
    TRMMemoView(liView).WordWrap := True;
    aFormReport.AssignFont(TRMMemoView(liView), liListView.Font);

    case liCol.Alignment of
      taLeftJustify: TRMMemoView(liView).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(liView).HAlign := rmhRight;
    else
      TRMMemoView(liView).HAlign := rmhCenter;
    end;

    if rmgoGridLines in aFormReport.ReportOptions then
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

  procedure _MakeOneDetail(aIndex: Integer);
  var
    liCol: TListColumn;
  begin
    liCol := liListView.Columns[aIndex];
    liView := TRMMemoView(RMCreateObject(rmgtMemo, ''));
    liView.ParentPage := liPage;
    TRMMemoView(liView).Stretched := rmgoStretch in aFormReport.ReportOptions;
    aFormReport.AssignFont(TRMMemoView(liView), liListView.Font);
    liView.Memo.Text := '';
    TRMMemoView(liView).WordWrap := True;

    if rmgoGridLines in aFormReport.ReportOptions then
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

    FList.Add(liView.Name);
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := liCol.Width + 1;
    liView.spHeight := liRowHeight + 4;

    aFormReport.PageDetailViews.Add(liView);
    tmpx := tmpx + liView.spWidth;
    if Assigned(aFormReport.OnAfterCreateGridObjectEvent) then
      aFormReport.OnAfterCreateGridObjectEvent(aControl, IntToStr(aIndex), liView);

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
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      if i < liListView.Columns.Count then
      begin
        _MakeOneHeader(i);
      end;
    end;
  end;

  procedure _DrawFixedColDetail;
  var
    i: Integer;
  begin
    for i := 1 to aFormReport.GridFixedCols do
    begin
      if i < liListView.Columns.Count then
      begin
        _MakeOneDetail(i);
      end;
    end;
  end;

begin
  if aFormReport.DrawOnPageFooter then Exit;

  liListView := THackListView(aControl);
  FFormReport := aFormReport;

  FListView := liListView;
  if (rmgoSelectedRecordsOnly in aFormReport.ReportOptions) and
    (liListView.SelCount > 0) then
  begin
    //    AutoFree := False;
    //    aFormReport.Report.OnBeforePrintBand := OnBeforePrintBandEvent;
  end;

  aFormReport.DrawOnPageFooter := TRUE;
  aFormReport.GridTop := aFormReport.OffsY + aControl.Top;
  aFormReport.GridHeight := aControl.Height;
  liListViewTitleHeight := 0;
  NextTop := aControl.Top + aFormReport.OffsY;

  if FUserDataset = nil then
    FUserDataset := TRMUserDataset.Create(nil);

  if FList = nil then
    FList := TStringList.Create;

  aFormReport.CanSetDataSet := False;
  FList.Clear;
  FUserDataset.OnCheckEOF := OnUserDatasetCheckEOF;
  FUserDataset.OnFirst := OnUserDatasetFirst;
  FUserDataset.OnNext := OnUserDatasetNext;
  FUserDataset.OnPrior := OnUserDatasetPrior;
  aFormReport.Report.DataSet := FUserDataset;

  tmpx := 0;
  for i := 0 to liListView.Columns.Count - 1 do
  begin
    liCol := liListView.Columns[i];
    tmpx := tmpx + liCol.Width + 1;
  end;

  liRowHeight := RMCanvasHeight('a', liListView.Font);
  if rmgoGridNumber in aFormReport.ReportOptions then
    tmpx := tmpx + RMCanvasHeight('a', liListView.Font) * aFormReport.GridNumOptions.Number;

  if (aFormReport.PrintControl = aControl) or (tmpx > StrToInt(aFormReport.FormWidth[0])) then
    aFormReport.FormWidth[0] := IntToStr(tmpx + (aFormReport.OffsX + aControl.Left) * 2);

  liPage := aPage;
  if True then //表头
  begin
    liFlagFirstColumn := True;
    liListViewTitleHeight := liRowHeight + 4;
    tmpx := aControl.Left + aFormReport.OffsX;
    if rmgoGridNumber in aFormReport.ReportOptions then
    begin
      liView := RMCreateObject(rmgtMemo, '');
      liView.ParentPage := liPage;
      liView.spLeft := tmpx;
      liView.spTop := NextTop;
      liView.spWidth := RMCanvasHeight('a', liListView.Font) * aFormReport.GridNumOptions.Number;
      liView.spHeight := liListViewTitleHeight;
      liView.Memo.Add(aFormReport.GridNumOptions.Text);
      TRMMemoView(liView).VAlign := rmvCenter;
      TRMMemoView(liView).HAlign := rmhCenter;
      if rmgoGridLines in aFormReport.ReportOptions then
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

    liNum := 0;
    tmpx0 := tmpx;
    for i := 0 to liListView.Columns.Count - 1 do
    begin
      liCol := liListView.Columns[i];
      if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
      begin
        if (liNum > 0) and (aFormReport.CalcWidth(tmpx + (liCol.Width + 1)) > aFormReport.PageWidth) then // 超宽
        begin
          liNum := 0;
          liFlagFirstColumn := True;
          if rmgoDoubleFrame in aFormReport.ReportOptions then
            liView.RightFrame.Width := 2;

          aFormReport.FormWidth[aFormReport.FormWidth.Count - 1] := IntToStr(tmpx);
          aFormReport.AddPage;
          aFormReport.FormWidth.Add('0');
          liPage := TRMReportPage(aFormReport.Report.Pages[aFormReport.Report.Pages.Count - 1]);
          tmpx := tmpx0;
          liFlagFirstColumn := True;
          _DrawFixedColHeader;
        end;
      end;

      _MakeOneHeader(i);
      Inc(liNum);
    end;

    liFlagFirstColumn := True;
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    aFormReport.FormWidth[aFormReport.FormWidth.Count - 1] := IntToStr(tmpx);

  liPage := aPage; //表体
  tmpx := aControl.Left + aFormReport.OffsX;
  liFlagFirstColumn := True;
  if rmgoGridNumber in aFormReport.ReportOptions then
  begin
    liView := RMCreateObject(rmgtMemo, '');
    liView.ParentPage := liPage;
    liView.spLeft := tmpx;
    liView.spTop := 0;
    liView.spWidth := RMCanvasHeight('a', liListView.Font) * aFormReport.GridNumOptions.Number;
    liView.spHeight := liRowHeight + 4;
    liView.Memo.Add('[Line#]');
    TRMMemoView(liView).VAlign := rmvCenter;
    TRMMemoView(liView).HAlign := rmhCenter;
    if (rmgoGridLines in aFormReport.ReportOptions) then
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
  liNum := 0;
  liPageNo := 0;
  for i := 0 to liListView.Columns.Count - 1 do
  begin
    liCol := liListView.Columns[i];
    if (aFormReport.ScaleMode.ScaleMode <> rmsmFit) or (not aFormReport.ScaleMode.FitPageWidth) then
    begin
      if (liNum > 0) and (aFormReport.CalcWidth(tmpx + (liCol.Width + 1)) > aFormReport.PageWidth) then // 超宽
      begin
        liNum := 0;
        liFlagFirstColumn := True;
        if rmgoDoubleFrame in aFormReport.ReportOptions then
          liView.RightFrame.Width := 2;

        liFlagFirstColumn := True;
        aFormReport.FormWidth[liPageNo] := IntToStr(tmpx);
        Inc(liPageNo);
        if liPageNo >= aFormReport.Report.Pages.Count then
        begin
          aFormReport.AddPage;
          aFormReport.FormWidth.Add('0');
        end;
        liPage := TRMReportPage(aFormReport.Report.Pages[liPageNo]);
        tmpx := tmpx0;
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
    if rmgoDoubleFrame in aFormReport.ReportOptions then
      liView.RightFrame.Width := 2;
  end;

  if aFormReport.Report.Pages.Count > 1 then
    aFormReport.FormWidth[aFormReport.FormWidth.Count - 1] := IntToStr(tmpx);
end;

initialization
  RMRegisterFormReportControl(TCustomCheckBox, TRMPrintCheckBox);
  RMRegisterFormReportControl(TShape, TRMPrintShape);
  RMRegisterFormReportControl(TDBImage, TRMPrintImage);
  RMRegisterFormReportControl(TImage, TRMPrintImage);
  RMRegisterFormReportControl(TCustomListBox, TRMPrintControl);
  RMRegisterFormReportControl(TDBLookupComboBox, TRMPrintEdit);
  RMRegisterFormReportControl(TCustomComboBox, TRMPrintEdit);
  RMRegisterFormReportControl(TCustomEdit, TRMPrintEdit);
  RMRegisterFormReportControl(TCustomMemo, TRMPrintControl);
  RMRegisterFormReportControl(TCustomRichEdit, TRMPrintRichEdit);
  RMRegisterFormReportControl(TCustomLabel, TRMPrintControl);
  RMRegisterFormReportControl(TDateTimePicker, TRMPrintDateTimePicker);
  RMRegisterFormReportControl(TCustomListView, TRMPrintListView);

finalization
  FreeFormReportList;

end.

