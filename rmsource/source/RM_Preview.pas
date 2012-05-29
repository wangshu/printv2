

{*****************************************}
{                                         }
{             Report Machine v2.0         }
{             Report preview Dlg          }
{                                         }
{*****************************************}

unit RM_Preview;

interface

{$I RM.inc}
{$R RMACHINE.RES}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, Buttons, ComCtrls, Math,
  RM_Common, RM_Ctrls, ImgList
{$IFDEF COMPILER6_UP}, Variants{$ENDIF}
{$IFDEF USE_TB2K}
  , TB2Item, TB2Dock, TB2Toolbar
{$ENDIF};

type
  TRMPreview = class;
  TRMVirtualPreview = class;
  TRMPreviewForm = class;
  TRMBeforeShowReport = procedure(aReport: TObject) of object;

  { TRMDrawPanel }
  TRMDrawPanel = class(TPanel)
  private
    FSaveEndPage: TObject;
    FSaveFoundView: TObject;
    FSavePageNo: Integer;
    FRepaintPageNo: Integer;

    FPreview: TRMVirtualPreview;
    FDown, FDoubleClickFlag: Boolean;
    FLastX, FLastY: Integer;
    FHRulerOffset, FVRulerOffset: Integer;
    FVisiblePages: array of Integer;
    FBusy: Boolean;

    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DblClick; override;
  end;

  PRMPreviewNodeDataInfo = ^TRMPreviewNodeDataInfo;
  TRMPreviewNodeDataInfo = record
    PageNo: Integer;
    Position: Integer;
  end;

  { TRMVirtualPreview }
  TRMVirtualPreview = class(TRMCustomPreview)
  private
    FReport: TRMCustomReport;
    FCurPage: Integer;
    FOffsetLeft, FOffsetTop, FOldVPos, FOldHPos: Integer;
    FScale: Double;
    FZoomMode: TRMScaleMode;
    FPaintAllowed: Boolean;
    FLastScale: Double;
    FSaveReportInfo: TRMReportInfo;
    FPrepareReportFlag: Boolean;
    FColumns: Integer;

    FScrollBox: TRMScrollBox;
    FStatusBar: TStatusBar;
    FTopPanel1: TPanel;
    FLeftTopPanel: TPanel;
    FLeftPanel: TPanel;
    FTopPanel: TPanel;
    FHRuler, FVRuler: TRMDesignerRuler;
    FDrawPanel: TRMDrawPanel;
    FSplitter: TSplitter;
    FOutlineTreeView: TTreeView;

    FKWheel: Integer;
    FParentForm: TForm;
    FInitialDir: string;

    FOnStatusChange: TNotifyEvent;
    FOnPageChanged: TNotifyEvent;
    FOnAfterPageSetup: TNotifyEvent;
    FOnBeforeShowReport: TRMBeforeShowReport;

    FStrFound: Boolean;
    FStrBounds: TRect;
    FFindStr: string;
    FCaseSensitive: Boolean;
    FWholewords: Boolean;
    FLastFoundPage, FLastFoundObject: Integer;
    FTotalPages: Integer;

    procedure SetKWheel(Value: Integer);

    procedure DoStatusChange;
    procedure SetPage(Value: Integer);
    function GetZoom: Double;
    procedure SetZoom(Value: Double);
    function GetHScrollBar: TRMScrollBar;
    function GetVScrollBar: TRMScrollBar;

    procedure ClearOutLine;
    procedure SetOutLineInfo;
    procedure OnOutlineClickEvent(Sender: TObject);
    procedure GotoPosition(aPageNo, aPosition: Integer);

    procedure FindInEMF(lEmf: TMetafile);
    procedure ShowPageNum;
    procedure SetToCurPage;
    procedure OnResizeEvent(Sender: TObject);
    procedure OnSplitterMovedEvent(Sender: TObject);
    procedure OnScrollBoxScroll(Sender: TObject; Kind: TRMScrollBarKind);
    procedure SetPageRect;

    procedure OnMouseWheelUpEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure OnMouseWheelDownEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  protected
    procedure Connect_1(aReport: TRMCustomReport);
    procedure Disconnect;
    function GetEndPages: TObject;
    property OnAfterPageSetup: TNotifyEvent read FOnAfterPageSetup write FOnAfterPageSetup;

    procedure InternalOnProgress(aReport: TRMCustomReport; aPercent: Integer); override;
    procedure BeginPrepareReport(aReport: TRMCustomReport); override;
    procedure EndPrepareReport(aReport: TRMCustomReport); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanModify: Boolean;
    procedure ShowReport(aReport: TRMCustomReport); override;
    procedure Connect(aReport: TRMCustomReport); override;

    procedure RedrawAll(aResetPage: Boolean);
    procedure OnePage;
    procedure TwoPages;
    procedure PageWidth;
    procedure PrinterZoom;
    procedure First;
    procedure Next;
    procedure Prev;
    procedure Last;
    procedure LoadFromFile(aFileName: string);
    procedure LoadFromFiles(aFileNames: TStrings);
    procedure SaveToFile(aFileName: string; aIndex: Integer);
    procedure ExportToFile(aExport: TComponent; aFileName: string);
    procedure ExportToXlsFile;
    procedure Print; override;
    procedure PrintCurrentPage;
    procedure DlgPageSetup;
    procedure InsertPageBefore;
    procedure InsertPageAfter;
    procedure AddPage;
    procedure DeletePage(PageNo: Integer);
    function EditPage(PageNo: Integer): Boolean;
    procedure DesignReport;
    procedure Find;
    procedure FindNext;
    procedure ShowOutline(aVisible: Boolean);

    property ParentForm: TForm read FParentForm write FParentForm;
    property KWheel: Integer read FKWheel write SetKWheel;
    property Report: TRMCustomReport read FReport;
    property TotalPages: Integer read FTotalPages;
    property Zoom: Double read GetZoom write SetZoom;
    property ZoomMode: TRMScaleMode read FZoomMode write FZoomMode;
    property LastScale: Double read FLastScale write FLastScale;
    property ScrollBox: TRMScrollBox read FScrollBox;
    property HScrollBar: TRMScrollBar read GetHScrollBar;
    property VScrollBar: TRMScrollBar read GetVScrollBar;
    property CurPage: Integer read FCurPage write SetPage;
    property OutlineTreeView: TTreeView read FOutlineTreeView;

    property FindStr: string read FFindStr write FFindstr;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    property Wholewords: Boolean read FWholewords write FWholewords;
    property LastFoundPage: Integer read FLastFoundPage write FLastFoundPage;
    property LastFoundObject: Integer read FLastFoundObject write FLastFoundObject;
    property StrFound: Boolean read FStrFound write FStrFound;
    property StrBounds: TRect read FStrBounds write FStrBounds;
    property PrepareReportFlag: Boolean read FPrepareReportFlag;
  published
    property InitialDir: string read FInitialDir write FInitialDir;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
    property OnBeforeShowReport: TRMBeforeShowReport read FOnBeforeShowReport write FOnBeforeShowReport;
  end;

  { TRMPreview }
  TRMPreview = class(TRMVirtualPreview)
  private
    FShowToolbar: Boolean;
    FOnBtnExitClickEvent: TNotifyEvent;
    FOnSaveReportEvent: TRMPreviewSaveReportEvent;

    Dock971: TRMDock;
    ToolbarStand: TRMToolbar;
    BtnExit: TRMToolbarButton;
    btn100: TRMToolbarButton;
    btnOnePage: TRMToolbarButton;
    btnPageSetup: TRMToolbarButton;
    btnPageWidth: TRMToolbarButton;
    btnShowOutline: TRMToolbarButton;
    ToolbarSep972: TRMToolbarSep;
//{$IFDEF USE_TB2K}
//    btnPrint: TRMSubmenuItem;
//{$ELSE}
    btnPrint: TRMToolbarButton;
//{$ENDIF}
    ToolbarSep973: TRMToolbarSep;
    btnTop: TRMToolbarButton;
{$IFDEF USE_TB2K}
    btnSave: TRMSubmenuItem;
{$ELSE}
    btnSave: TRMToolbarButton;
{$ENDIF}
    btnPrev: TRMToolbarButton;
    btnOpen: TRMToolbarButton;
    btnNext: TRMToolbarButton;
    btnLast: TRMToolbarButton;
    btnFind: TRMToolbarButton;
    btnSaveToXLS: TRMToolbarButton;
    btnDesign: TRMToolbarButton;
    ToolbarSep974: TRMToolbarSep;
    ToolbarSep975: TRMToolbarSep;
    tbLine: TRMToolbarSep;
    ToolbarSep971: TRMToolbarSep;
    cmbZoom: TRMComboBox97;
    edtPageNo: TRMEdit;

    FBtnShowBorder: TRMToolbarButton;
//    FBtnBackColor: TRMColorPickerButton;
    tbSep1: TRMToolbarSep;

    ProcMenu: TPopupMenu;
    itmScale200: TMenuItem;
    itmScale150: TMenuItem;
    itmScale100: TMenuItem;
    itmScale75: TMenuItem;
    itmScale50: TMenuItem;
    itmScale25: TMenuItem;
    itmScale10: TMenuItem;
    itmPageWidth: TMenuItem;
    itmOnePage: TMenuItem;
    itmDoublePage: TMenuItem;
    N1: TMenuItem;
    itmNewPage: TMenuItem;
    itmDeletePage: TMenuItem;
    itmEditPage: TMenuItem;
    N4: TMenuItem;
    itmPrint: TMenuItem;
    itmPrintCurrentPage: TMenuItem;
    InsertBefore1: TMenuItem;
    InsertAfter1: TMenuItem;
    N2: TMenuItem;
    Append1: TMenuItem;

    procedure btnPrintClick(Sender: TObject);
    procedure btnTopClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btn100Click(Sender: TObject);
    procedure btnOnePageClick(Sender: TObject);
    procedure btnPageWidthClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure OnmnuExportClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure btnPageSetupClick(Sender: TObject);
    procedure btnShowOutlineClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure btnDesignClick(Sender: TObject);
    procedure CmbZoomKeyPress(Sender: TObject; var Key: Char);
    procedure CmbZoomClick(Sender: TObject);
    procedure edtPageNoKeyPress(Sender: TObject; var Key: Char);
    procedure btnSaveToXLSClick(Sender: TObject);
    procedure btnShowBorderClick(Sender: TObject);
//    procedure btnBackColorClick(Sender: TObject);

    procedure itmScale10Click(Sender: TObject);
    procedure itmDeletePageClick(Sender: TObject);
    procedure itmEditPageClick(Sender: TObject);
    procedure itmPrintCurrentPageClick(Sender: TObject);
    procedure Append1Click(Sender: TObject);
    procedure InsertBefore1Click(Sender: TObject);
    procedure InsertAfter1Click(Sender: TObject);

    procedure OnPageChangedEvent(Sender: TObject);
    procedure OnStatusChangeEvent(Sender: TObject);

    procedure SetShowToolbar(Value: Boolean);
    procedure CreateButtons;
    procedure SetButtonsVisible;
    procedure Localize;
  protected
    IsStanderPreview: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure LoadIni(aDefault: Boolean);
    procedure SaveIni(aDefault: Boolean);
    property OnBtnExitClickEvent: TNotifyEvent read FOnBtnExitClickEvent write FOnBtnExitClickEvent;
    property OnSaveReportEvent: TRMPreviewSaveReportEvent read FOnSaveReportEvent write FOnSaveReportEvent;
  published
    property ShowToolbar: Boolean read FShowToolbar write SetShowToolbar default False;
  end;

  { TRMPreviewForm }
  TRMPreviewForm = class(TForm)
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FDoc: Pointer;
    FViewer: TRMPreview;
    FPopupMenu: TRMPopupMenu;
    FPopupMenuPrint: TRMPopupMenu;

    procedure Localize;
    procedure SaveIni;
    procedure LoadIni;
    procedure PopupMenuPrintOnPopup(Sender: TObject);
//    procedure ItmPopupPrintClick(Sender: TObject);
  public
    { Public declarations }
    procedure Execute(aDoc: Pointer);
    property Viewer: TRMPreview read FViewer;
    property Report: Pointer read FDoc;
  end;

implementation

{$R *.DFM}

uses
  ShellAPI, Registry, RM_Const, RM_Const1, RM_Class, RM_Printer, RM_PrintDlg,
  RM_Utils, RM_PageSetup, RM_DlgFind;

type
  THackReport = class(TRMReport)
  end;

  THackEndPages = class(TRMEndPages)
  end;

  THackEndPage = class(TRMEndPage)
  end;

  THackReportView = class(TRMReportView)
  end;

var
  //  FcrMagnifier: Integer = 0;
  FCurPreview: TRMVirtualPreview;
  FRecordNum: Integer;
  FLastExportIndex: Integer = 1;
  FSaveLastScale: Double = 1;
  FSaveLastScaleMode: TRMScaleMode = mdNone;
  FSaveOpenDialogDir: string;
  FSaveSaveDialogDir: string;
  FWindow: TRMPreviewForm = nil;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TRMDrawPanel }

constructor TRMDrawPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSaveFoundView := nil;
  FBusy := False;
  FHRulerOffset := 0;
  FVRulerOffset := 0;
  SetLength(FVisiblePages, 0);
end;

procedure TRMDrawPanel.WMEraseBackground(var Message: TMessage);
begin
//
end;

procedure TRMDrawPanel.Paint;
var
  i, j: Integer;
  lRect, lRect1: TRect;
  lPages: TRMEndPages;
  lPage: TRMEndPage;
  lhRgn: HRGN;
  lScale: Double;
  ltb, lbr: tagLOGBRUSH;
  lNewH, lOldH: HGDIOBJ;
  lnbr, lobr: HBRUSH;
  //  lSavePages: array of Integer;
  lFlag: Boolean;

  procedure _SetPS;
  begin
    ltb.lbStyle := BS_SOLID;
    ltb.lbColor := Canvas.Pen.Color;
    lNewH := ExtCreatePen(PS_GEOMETRIC + PS_ENDCAP_SQUARE + RMPenStyles[Canvas.Pen.Style], Canvas.Pen.Width, ltb, 0, nil);
    lOldH := SelectObject(Canvas.Handle, lNewH);
  end;

  procedure _SetRuler(aPageNo: Integer);
  var
    lRect: TRect;
  begin
    if not FPreview.Options.RulerVisible then Exit;
    if lPages[aPageNo - 1] = nil then Exit;

    lRect := lPages[aPageNo - 1].PageRect;
    OffsetRect(lRect, FPreview.FOffsetLeft, FPreview.FOffsetTop);

    FPreview.FHRuler.Scale := lScale;
    FPreview.FVRuler.Scale := lScale;
    FPreview.FHRuler.Left := lRect.Left;
    FPreview.FVRuler.Top := lRect.Top;
    FPreview.FHRuler.Width := lRect.Right - lRect.Left;
    FPreview.FVRuler.Height := lRect.Bottom - lRect.Top;

    FPreview.FHRuler.ScrollOffset := 0;
    FPreview.FVRuler.ScrollOffset := 0;
    FHRulerOffset := 10 - lRect.Left;
    FVRulerOffset := 10 - lRect.Top;
  end;

  procedure _DrawMargins;
  begin
    with lPage, lPage.PrinterInfo do
    begin
      lRect1.Left := RMToScreenPixels(mmMarginLeft * lScale, rmutMMThousandths);
      lRect1.Top := RMToScreenPixels(mmMarginTop * lScale, rmutMMThousandths);
      lRect1.Right := Round((ScreenPageWidth - RMToScreenPixels(mmMarginRight, rmutMMThousandths)) * lScale);
      lRect1.Bottom := Round((ScreenPageHeight - RMToScreenPixels(mmMarginBottom, rmutMMThousandths)) * lScale);

      OffsetRect(lRect1, lRect.Left, lRect.Top);
    end;

    with Canvas do
    begin
      Pen.Width := 1;
      Pen.Color := clGray;
      Pen.Style := psSolid;
      MoveTo(lRect1.Left, lRect1.Top);
      LineTo(lRect1.Left, lRect1.Top - Round(20 * lScale)); //左上
      MoveTo(lRect1.Left, lRect1.Top);
      LineTo(lRect1.Left - Round(20 * lScale), lRect1.Top);
      MoveTo(lRect1.Right, lRect1.Top);
      LineTo(lRect1.Right, lRect1.Top - Round(20 * lScale)); //右上
      MoveTo(lRect1.Right, lRect1.Top);
      LineTo(lRect1.Right + Round(20 * lScale), lRect1.Top);
      MoveTo(lRect1.Left, lRect1.Bottom);
      LineTo(lRect1.Left, lRect1.Bottom + Round(20 * lScale)); //左下
      MoveTo(lRect1.Left, lRect1.Bottom);
      LineTo(lRect1.Left - Round(20 * lScale), lRect1.Bottom);
      MoveTo(lRect1.Right, lRect1.Bottom);
      LineTo(lRect1.Right, lRect1.Bottom + Round(20 * lScale)); //右下
      MoveTo(lRect1.Right, lRect1.Bottom);
      LineTo(lRect1.Right + Round(20 * lScale), lRect1.Bottom);
    end;

    if FPreview.Options.DrawBorder then
    begin
      Canvas.Pen.Width := FPreview.Options.BorderPen.Width;
      Canvas.Pen.Color := FPreview.Options.BorderPen.Color;
      Canvas.Pen.Style := FPreview.Options.BorderPen.Style;
      if Canvas.Pen.Width = 1 then
        Canvas.Rectangle(lRect1.Left, lRect1.Top, lRect1.Right + 1, lRect1.Bottom + 1)
      else
      begin
        lRect1.Left := lRect1.Left - Canvas.Pen.Width div 2;
        lRect1.Right := lRect1.Right + Canvas.Pen.Width div 2;
        lRect1.Top := lRect1.Top - Canvas.Pen.Width div 2;
        lRect1.Bottom := lRect1.Bottom + Canvas.Pen.Width div 2;

        _SetPS;
        lbr.lbStyle := BS_NULL;
        lnbr := CreateBrushIndirect(lbr);
        lobr := SelectObject(Canvas.Handle, lnbr);

        Windows.MoveToEx(Canvas.Handle, lRect1.Left, lRect1.Top, nil); // Left
        Windows.LineTo(Canvas.Handle, lRect1.Left, lRect1.Bottom);

        Windows.MoveToEx(Canvas.Handle, lRect1.Left, lRect1.Top, nil); // Top
        Windows.LineTo(Canvas.Handle, lRect1.Right, lRect1.Top);

        Windows.MoveToEx(Canvas.Handle, lRect1.Right, lRect1.Top, nil); // Right
        Windows.LineTo(Canvas.Handle, lRect1.Right, lRect1.Bottom);

        Windows.MoveToEx(Canvas.Handle, lRect1.Left, lRect1.Bottom, nil); // Bottom
        Windows.LineTo(Canvas.Handle, lRect1.Right, lRect1.Bottom);

        SelectObject(Canvas.Handle, lobr);
        DeleteObject(lnbr);
        SelectObject(Canvas.Handle, lOldH);
        DeleteObject(lNewH);
      end;
    end;
  end;

  procedure _DrawbkPicture;
  var
    lbkPic: TRMbkPicture;
    lPic: TPicture;
    lPicWidth, lPicHeight: Integer;
  begin
    lbkPic := lPages.bkPictures[lPage.bkPictureIndex];
    if lbkPic = nil then Exit;

    lPic := lbkPic.Picture;
    if lPic.Graphic <> nil then
    begin
      lPicWidth := lbkPic.Width;
      lPicHeight := lbkPic.Height;

      lRect1 := Rect(0, 0, Round(lPicWidth * lScale), Round(lPicHeight * lScale));
      OffsetRect(lRect1, Round(lbkPic.Left * lScale), Round(lbkPic.Top * lScale));
      OffsetRect(lRect1, lRect.Left, lRect.Top);
      try
        IntersectClipRect(Canvas.Handle, lRect.Left + 1, lRect.Top + 1,
          lRect.Right - 1, lRect.Bottom - 1);
        RMPrintGraphic(Canvas, lRect1, lPic.Graphic, False, False, False);
      finally
        SelectClipRgn(Canvas.Handle, lhRgn);
      end;
    end;
  end;

begin
  if (not FPreview.FPaintAllowed) or (FPreview.FReport = nil) then
  begin
    inherited;
    Exit;
  end;

  {  SetLength(lSavePages, Length(FVisiblePages));
    for i := 0 to Length(FVisiblePages) - 1 do
      lSavePages[i] := FVisiblePages[i];}

  SetLength(FVisiblePages, 0);
  if FPreview.GetEndPages = nil then
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(ClientRect);
    Exit;
  end;

  lScale := FPreview.FScale;
  lPages := TRMEndPages(FPreview.GetEndPages);
  lhRgn := CreateRectRgn(0, 0, Width, Height); // 创建一个区域
  try
    GetClipRgn(Canvas.Handle, lhRgn);
    for i := 0 to FPreview.FTotalPages - 1 do
    begin
      lPage := lPages[i];
      lRect := lPage.PageRect;
      OffsetRect(lRect, FPreview.FOffsetLeft, FPreview.FOffsetTop);
      if (lRect.Top > 2000) or (lRect.Bottom < 0) then
        lPage.Visible := False
      else
        lPage.Visible := RectVisible(Canvas.Handle, lRect);

      if lPage.Visible then // 去掉一个矩形区
      begin
        ExcludeClipRect(Canvas.Handle, lRect.Left + 1, lRect.Top + 1,
          lRect.Right - 1, lRect.Bottom - 1);
      end;

      if ((lRect.Bottom >= 0) and (lRect.Bottom <= Self.Height)) or
        ((lRect.Top >= 0) and (lRect.Top <= Self.Height)) then
      begin
        SetLength(FVisiblePages, Length(FVisiblePages) + 1);
        FVisiblePages[Length(FVisiblePages) - 1] := i;
      end;
    end;

    if (Length(FVisiblePages) = 0) and
      ((FPreview.CurPage - 1) >= 0) and ((FPreview.CurPage - 1) < FPreview.FTotalPages) then
    begin
      SetLength(FVisiblePages, 1);
      FVisiblePages[0] := FPreview.CurPage - 1;
    end;

    with Canvas do
    begin
      Brush.Color := clGray;
      FillRect(Rect(0, 0, Width, Height));
    end;

    SelectClipRgn(Canvas.Handle, lhRgn);
    //for i := 0 to Length(FVisiblePages) - 1 do
    for i := 0 to lPages.Count - 1 do // drawing page background
    begin
      //lPage := lPages[FVisiblePages[i]];
      lPage := lPages[i];
      if lPage.Visible then
      begin
        Canvas.Pen.Color := clBlack;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Mode := pmCopy;
        Canvas.Pen.Style := psSolid;
        Canvas.Brush.Color := clWhite;

        lRect := lPage.PageRect;
        OffsetRect(lRect, FPreview.FOffsetLeft, FPreview.FOffsetTop);
        Canvas.Rectangle(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
        Canvas.Polyline([Point(lRect.Left + 1, lRect.Bottom), Point(lRect.Right, lRect.Bottom),
          Point(lRect.Right, lRect.Top + 1)]);

        _DrawMargins;
        _DrawbkPicture;
      end;
    end;

    //    for i := 0 to Length(FVisiblePages) - 1 do
    for i := 0 to FPreview.FTotalPages - 1 do
    begin
      lPage := lPages[i];
      //lPage := lPages[FVisiblePages[i]];
      if lPage.Visible then
      begin
        if i = FRepaintPageNo then
          lPage.RemoveCachePage;

        lRect := lPage.PageRect;
        OffsetRect(lRect, FPreview.FOffsetLeft, FPreview.FOffsetTop);
        lPage.Draw(TRMReport(FPreview.FReport), Canvas, lRect);
      end
      else
      begin
        lFlag := True;
        for j := 0 to Length(FVisiblePages) - 1 do
        begin
          if i = FVisiblePages[j] then
          begin
            lFlag := False;
            Break;
          end;
        end;

        if lFlag then
          lPage.RemoveCachePage;
      end;
    end;

    {    for i := 0 to Length(lSavePages) - 1 do
        begin
          lPage := lPages[lSavePages[i]];
          if not lPage.Visible then
            lPage.RemoveCachePage;
        end;}

    _SetRuler(FPreview.CurPage);
  finally
    DeleteObject(lhRgn);
    FRepaintPageNo := -1;
  end;
end;

procedure TRMDrawPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPageNo: Integer;
  lNeedChangePage: Boolean;

  procedure _SetToAnchor(aAnchor: string);
  var
    lValue: Variant;
    lTmpPos: Integer;
    lVal1, lVal2: Integer;
  begin
    if THackReport(FPreview.FReport).AnchorList = nil then Exit;

    lValue := THackReport(FPreview.FReport).AnchorList[aAnchor];
    if lValue <> Null then
    begin
      lTmpPos := 1;
      lVal1 := StrToInt(RMStrGetToken(string(lValue), #1, lTmpPos));
      lVal2 := StrToInt(RMStrGetToken(string(lValue), #1, lTmpPos));
      FPreview.GotoPosition(lVal1 - 1, lVal2);

      lPageNo := FPreview.CurPage;
      lNeedChangePage := True;
    end;
  end;

  function _GenOnePage: Boolean;
  var
    t: TRMView;
    lReport: TRMReport;
    lModified: Boolean;
    lUrl: string;
  begin
    Result := False;

    lReport := TRMReport(FPreview.Report);
    lModified := False;
    t := TRMView(FSaveFoundView);
    lUrl := THackReportView(t).Url;
    if Length(lUrl) > 0 then
    begin
      if lUrl[1] = '#' then // 书签
      begin
        _SetToAnchor(Copy(lUrl, 2, 9999))
      end
      else if lUrl[1] = '@' then // 页码
      begin
        lUrl := RMDeleteNoNumberChar(System.Copy(lUrl, 2, 9999));
        if RMIsNumeric(lUrl) then
        begin
          try
            lPageNo := StrToInt(lUrl);
            lNeedChangePage := True;
          except
          end;
        end;
      end
      else // 超级连接
      begin
        if Assigned(THackReportView(t).OnPreviewClickUrl) then
        begin
          Result := True;
          THackReportView(t).OnPreviewClickUrl(TRMReportView(t));
        end
        else
          ShellExecute(0, nil, PChar(lUrl), nil, nil, SW_RESTORE);
      end;
    end;

    if Assigned(THackReportView(t).OnPreviewClick) then
    begin
      Result := True;
      THackReportView(t).OnPreviewClick(TRMReportView(t), Button, Shift, lModified);
    end;

    if Assigned(lReport.OnObjectClick) then
    begin
      Result := True;
      lReport.OnObjectClick(TRMReportView(t), Button, Shift, lModified);
    end;

    if lModified then // 修改内容了，需要保存
    begin
      TRMEndPage(FSaveEndPage).ObjectsToStream(lReport);
      TRMEndPage(FSaveEndPage).StreamToObjects(lReport, True);
      if FPreview.CurPage = lPageNo then
        FPreview.ReDrawAll(False);
    end;
  end;

begin
  if FBusy or (FPreview.GetEndPages = nil) or (not FPreview.FPaintAllowed) then Exit;

  if FDoubleClickFlag then
  begin
    FDoubleClickFlag := False;
    Exit;
  end;

  FBusy := True; lNeedChangePage := False;
  try
    FPreview.ScrollBox.SetFocus;
    if Button = mbLeft then
    begin
      FDown := True;
      lPageNo := FPreview.CurPage;
      if FSaveFoundView <> nil then
      begin
        //lPageNo := FSavePageNo;
        if _GenOnePage then
          FDown := False;
      end;

      FLastX := X; FLastY := Y;
      if lNeedChangePage then
      begin
        FPreview.CurPage := lPageNo;
        FPreview.ShowPageNum;
      end;
    end
    else if Button = mbRight then
    begin
    end;
  finally
    FBusy := False;
  end;
end;

procedure TRMDrawPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  lPoint: TPoint;
  lRect: TRect;
  lEndPages: TRMEndPages;
  lEndPage: TRMEndPage;
  lCursor: TCursor;
  lUrlStr: string;

  function _GenOnePage: Boolean;
  var
    i: Integer;
    t: TRMView;
    lScaleX, lScaleY, lOffsetX, lOffsetY: Double;
  begin
    Result := False;
    if THackEndPage(lEndPage).FPage = nil then Exit;

    lScaleX := 1; lScaleY := 1;
    lOffsetX := RMToScreenPixels(lEndPage.mmMarginLeft, rmutMMThousandths);
    lOffsetY := RMToScreenPixels(lEndPage.mmMarginTop, rmutMMThousandths);
    for i := lEndPage.Page.Objects.Count - 1 downto 0 do
    begin
      t := lEndPage.Page.Objects[i];
      if PtInRect(Rect(Round(t.spLeft * lScaleX + lOffsetX), Round(t.spTop * lScaleY + lOffsetY),
        Round(t.spRight * lScaleX + lOffsetX), Round(t.spBottom * lScaleX + lOffsetY)), lPoint) then
      begin
        Result := True;
        FSaveFoundView := t;
        if Length(THackReportView(t).Url) >= 1 then
        begin
          lUrlStr := THackReportView(t).Url;
          lCursor := crHandPoint;
        end
        else
          lCursor := THackReportView(t).Cursor;

        Break;
      end;
    end;
  end;

begin
  if FBusy or (not FPreview.FPaintAllowed) or (FPreview.FReport = nil) then Exit;

  FBusy := True;
  FSaveFoundView := nil;
  try
    if FDown then
    begin
      FPreview.HScrollBar.Position := FPreview.HScrollBar.Position - (X - FLastX);
      FPreview.VScrollBar.Position := FPreview.VScrollBar.Position - (Y - FLastY);
      FLastX := X;
      FLastY := Y;
    end
    else
    begin
      lCursor := crDefault;
      lUrlStr := '';
      FPreview.FHRuler.SetGuides(x - 10 + FHRulerOffset, 0);
      FPreview.FVRuler.SetGuides(y - 10 + FVRulerOffset, 0);

      lPoint := Point(x { - FPreview.FOffsetLeft}, y { - FPreview.FOffsetTop});
      lEndPages := TRMEndPages(FPreview.GetEndPages);
      for i := 0 to Length(FVisiblePages) - 1 do
      begin
        lEndPage := lEndPages[FVisiblePages[i]];
        //此处应增加如下行
        if lEndPage <> nil then //ADD BY PGT
        begin
          lRect := lEndPage.PageRect;
          OffsetRect(lRect, FPreview.FOffsetLeft, FPreview.FOffsetTop);
          if PtInRect(lRect, lPoint) then
          begin
            lPoint := Point(Round((lPoint.X - lRect.Left) / FPReview.FScale),
              Round((lPoint.Y - lRect.Top) / FPReview.FScale));
            if _GenOnePage then
            begin
              FSavePageNo := FVisiblePages[i] + 1;
              FSaveEndPage := lEndPage;
              Break;
            end;
          end;
        end; {if }
      end;

      Cursor := lCursor;
      FPreview.FStatusBar.Panels[1].Text := lUrlStr;
    end;
  finally
    FBusy := False;
  end;
end;

procedure TRMDrawPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (not FPreview.FPaintAllowed) then Exit;

  FDown := False;
end;

procedure TRMDrawPanel.DblClick;
begin
  FDown := False;
  FDoubleClickFlag := True;
  FPreview.EditPage(FPreview.CurPage - 1);
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{ TRMVirtualPreview }

constructor TRMVirtualPreview.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FKWheel := 20;
  BevelInner := bvNone;
  BevelOuter := bvLowered;
  Caption := '';
  OnResize := OnResizeEvent;
  FParentForm := nil;
  FOnPageChanged := nil;
  FOnStatusChange := nil;

  FOutlineTreeView := TTreeView.Create(Self);
  with FOutlineTreeView do
  begin
    Parent := Self;
    Align := alLeft;
    Width := 180;
    Visible := False;
    ReadOnly := True;
    OnClick := OnOutlineClickEvent;
  end;

  FSplitter := TSplitter.Create(Self);
  with FSplitter do
  begin
    Parent := Self;
    Align := alLeft;
    Left := 10;
    Visible := False;
    OnMoved := OnSplitterMovedEvent;
  end;

  FScrollBox := TRMScrollBox.Create(Self);
  with FScrollBox do
  begin
    Parent := Self;
    //BorderStyle := bsNone;
    Caption := '';
    Align := alClient;
    HorzScrollBar.SmallChange := Self.FKWheel;
    HorzScrollBar.LargeChange := 300;

    VertScrollBar.SmallChange := Self.FKWheel;
    VertScrollBar.LargeChange := 300;

    OnMouseWheelUp := OnMouseWheelUpEvent;
    OnMouseWheelDown := OnMouseWheelDownEvent;
    OnChange := Self.OnScrollBoxScroll;
  end;

  FTopPanel := TPanel.Create(Self);
  with FTopPanel do
  begin
    Parent := FScrollBox;
    Caption := '';
    Height := 29;
    Align := alTop;
    BevelOuter := bvNone;
    Visible := False;
  end;
  FLeftTopPanel := TPanel.Create(Self);
  with FLeftTopPanel do
  begin
    Parent := FTopPanel;
    Caption := '';
    Width := 29;
    Align := alLeft;
    BevelOuter := bvNone;
  end;
  FTopPanel1 := TPanel.Create(Self);
  with FTopPanel1 do
  begin
    Parent := FTopPanel;
    Caption := '';
    Height := 29;
    Align := alClient;
    BevelOuter := bvNone;
  end;
  FLeftPanel := TPanel.Create(Self);
  with FLeftPanel do
  begin
    Parent := FScrollBox;
    Caption := '';
    Width := 29;
    Align := alLeft;
    BevelOuter := bvNone;
    Visible := False;
  end;

  FHRuler := TRMDesignerRuler.Create(Self);
  FHRuler.Parent := FTopPanel1;
  FHRuler.Units := RMUnits;
  FHRuler.Orientation := roHorizontal;
  FHRuler.SetBounds(FLeftPanel.Width, 0, FTopPanel1.Width, FTopPanel1.Height);

  FVRuler := TRMDesignerRuler.Create(Self);
  FVRuler.Parent := FLeftPanel;
  FVRuler.Units := RMUnits;
  FVRuler.Orientation := roVertical;
  FVRuler.SetBounds(0, 0, FLeftPanel.Width, FLeftPanel.Height);

  FStatusBar := TStatusBar.Create(Self);
  with FStatusBar do
  begin
    Parent := Self;
    Align := alBottom;
    with Panels.Add do
    begin
      Width := 140;
    end;
    with Panels.Add do
    begin
      Width := 260;
    end;
    with Panels.Add do
    begin
      Width := 100;
    end;
  end;

  FDrawPanel := TRMDrawPanel.Create(FScrollBox);
  with FDrawPanel do
  begin
    Parent := FScrollBox;
    Caption := '';
    Align := alClient;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Color := clGray;
    FPreview := Self;
  end;

  FLastScale := 1;
  FZoomMode := mdNone;
end;

destructor TRMVirtualPreview.Destroy;
begin
  if FReport <> nil then
  begin
    TRMReport(FReport).ReportInfo := FSaveReportInfo;
  end;

  ClearOutLine;

  inherited Destroy;
end;

function TRMVirtualPreview.CanModify: Boolean;
begin
  Result := (RMDesignerClass <> nil) and Assigned(FReport) and TRMReport(Report).ModifyPrepared;
end;

procedure TRMVirtualPreview.Connect_1(aReport: TRMCustomReport);
begin
  FReport := aReport;
  if FReport <> nil then
    FTotalPages := TRMEndPages(GetEndPages).Count;
end;

{$HINTS OFF}

procedure TRMVirtualPreview.ShowReport(aReport: TRMCustomReport);
begin
  FPrepareReportFlag := False;
  if Assigned(FOnBeforeShowReport) then FOnBeforeShowReport(aReport);

  Connect(aReport);
end;

procedure TRMVirtualPreview.Disconnect;
begin
  if FReport <> nil then
    TRMReport(FReport).ReportInfo := FSaveReportInfo;

  FReport := nil;
end;

procedure TRMVirtualPreview.ClearOutLine;
var
  i: Integer;
  lNode: TTreeNode;
begin
  for i := 0 to FOutLineTreeView.Items.Count - 1 do
  begin
    lNode := FOutLineTreeView.Items[i];
    if lNode.Data <> nil then
    begin
      Dispose(lNode.Data);
      lNode.Data := nil;
    end;
  end;
  FOutLineTreeView.Items.Clear;
end;

procedure TRMVirtualPreview.GotoPosition(aPageNo, aPosition: Integer);
var
  lPages: TRMEndPages;
  lPageRectHeight: Integer;
  lPageHeight: Integer;
begin
  lPages := TRMEndPages(GetEndPages);
  if (aPageNo < 0) or (aPageNo >= lPages.Count) then Exit;

  aPosition := Round(aPosition * FScale) +
    RMToScreenPixels(lPages[aPageNo].mmMarginTop * FScale, rmutMMThousandths);

  if aPageNo > 0 then
    lPageRectHeight := lPages[aPageNo].PageRect.Bottom - lPages[aPageNo - 1].PageRect.Bottom
  else
    lPageRectHeight := lPages[aPageNo].PageRect.Bottom;

  lPageRectHeight := lPageRectHeight - 10;
  lPageHeight := Round(lPages[aPageNo].PrinterInfo.ScreenPageHeight * FScale);

  FCurPage := -1;
  CurPage := aPageNo + 1;
  VScrollBar.Position := VScrollBar.Position +
    Round(aPosition * lPageRectHeight / lPageHeight) + 10 - 5;
end;

procedure TRMVirtualPreview.OnOutlineClickEvent(Sender: TObject);
var
  lNode: TTreeNode;
  lPages: TRMEndPages;
begin
  lNode := FOutLineTreeView.Selected;
  if (lNode = nil) or (lNode.Data = nil) then Exit;

  GotoPosition(PRMPreviewNodeDataInfo(lNode.Data).PageNo,
    PRMPreviewNodeDataInfo(lNode.Data).Position);
end;

procedure TRMVirtualPreview.SetOutLineInfo; // 设置outline
var
  i, j: Integer;
  lStr: string;
  lInfo: PRMPreviewNodeDataInfo;
  lParentNode, lNode: TTreeNode;
  lCaption: string;
  lPageNo, lPosition, lNodeLevel: Integer;
  lTmpPos, lOldNodeLevel: Integer;
  lEndPages: TRMEndPages;
begin
  FOutLineTreeView.Items.BeginUpdate;
  try
    lEndPages := TRMEndPages(GetEndPages);
    ClearOutLine;
      //      lNode := FOutLine.Items.AddChild(nil, '目录');
      //      lNode.Data := nil;
    lNode := nil;
    lParentNode := lNode;
    lOldNodeLevel := 0;

      {      lEndPages.OutLines.Add('1' + #1 + '0' + #1 + '100' + #1 + '0');
            lEndPages.OutLines.Add('2' + #1 + '1' + #1 + '100' + #1 + '1');
            lEndPages.OutLines.Add('3' + #1 + '1' + #1 + '100' + #1 + '1');
            lEndPages.OutLines.Add('4' + #1 + '1' + #1 + '100' + #1 + '2');
            lEndPages.OutLines.Add('5' + #1 + '1' + #1 + '100' + #1 + '2');
            lEndPages.OutLines.Add('6' + #1 + '1' + #1 + '100' + #1 + '1');
            lEndPages.OutLines.Add('7' + #1 + '1' + #1 + '100' + #1 + '0');
           }for i := 0 to lEndPages.OutLines.Count - 1 do
    begin
      lStr := lEndPages.OutLines[i];
      lTmpPos := 1;
      lCaption := RMStrGetToken(lStr, #1, lTmpPos);
      lPageNo := StrToInt(RMStrGetToken(lStr, #1, lTmpPos));
      lPosition := StrToInt(RMStrGetToken(lStr, #1, lTmpPos));
      lNodeLevel := StrToInt(RMStrGetToken(lStr, #1, lTmpPos));

      if lNodeLevel > lOldNodeLevel then
      begin
        lParentNode := lNode;
      end
      else if lNodeLevel < lOldNodeLevel then
      begin
        lParentNode := lNode;
        for j := lNodeLevel to lOldNodeLevel do
        begin
          if lParentNode = nil then Break;
          lParentNode := lParentNode.Parent;
        end;
      end;

      lNode := FOutLineTreeView.Items.AddChild(lParentNode, lCaption);

      New(lInfo);
      lInfo.PageNo := lPageNo;
      lInfo.Position := lPosition;
      lNode.Data := lInfo;

      lOldNodeLevel := lNodeLevel;
    end;
  finally
    FOutLineTreeView.FullExpand;
    FOutLineTreeView.Items.EndUpdate;
    ShowOutline(FOutLineTreeView.Items.Count > 0);
  end;
end;

procedure TRMVirtualPreview.Connect(aReport: TRMCustomReport);
var
  lParentForm: TForm;
begin
  Connect_1(aReport);
  FTotalPages := 0;
  FLeftPanel.Visible := Options.RulerVisible;
  FTopPanel.Visible := Options.RulerVisible;
  FHRuler.Units := Options.RulerUnit;
  FVRuler.Units := Options.RulerUnit;
  TRMPreview(Self).SetButtonsVisible;
  if aReport = nil then
  begin
    FPaintAllowed := False;
    HScrollBar.Range := 2;
    HScrollBar.PageSize := 1;
    VScrollBar.Range := 2;
    VScrollBar.PageSize := 1;
    FStatusBar.Panels[0].Text := '';
    FStatusBar.Panels[1].Text := '';
    ShowOutline(False);
    ClearOutLine;
    Exit;
  end;

  FTotalPages := TRMEndPages(GetEndPages).Count;
  FSaveReportInfo := TRMReport(FReport).ReportInfo;
  case TRMReport(FReport).InitialZoom of
    pzDefault:
      begin
        FScale := 1;
        FZoomMode := mdNone;
      end;
    pzPageWidth: FZoomMode := mdPageWidth;
    pzOnePage: FZoomMode := mdOnePage;
    pzTwoPages: FZoomMode := mdTwoPages;
  end;

  SetOutLineInfo;
  CurPage := 1;
  RedrawAll(True);

  lParentForm := FParentForm;
  if (lParentForm = nil) and (Parent <> nil) and (Parent is TForm) then
    lParentForm := TForm(Parent);
  if lParentForm <> nil then
  begin
    lParentForm.OnMouseWheelUp := OnMouseWheelUpEvent;
    lParentForm.OnMouseWheelDown := OnMouseWheelDownEvent;
  end;
end;
{$HINTS ON}

procedure TRMVirtualPreview.DoStatusChange;
begin
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self);
end;

procedure TRMVirtualPreview.SetToCurPage;
begin
  if (GetEndPages = nil) or (FCurPage < 1) then Exit;

  TRMEndPages(GetEndPages).CurPageNo := FCurPage; //by waw
  if FOffsetTop <> TRMEndPages(GetEndPages)[FCurPage - 1].PageRect.Top - 10 then
    VScrollBar.Position := TRMEndPages(GetEndPages)[FCurPage - 1].PageRect.Top - 10;
end;

procedure TRMVirtualPreview.ShowPageNum;
begin
  if GetEndPages = nil then
    FStatusBar.Panels[0].Text := ''
      //    FLabel.Caption := ''
  else
  begin
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);

    FStatusBar.Panels[0].Text {FLabel.Caption} := RMLoadStr(SPg) + ' ' + IntToStr(FCurPage) + '/' +
      IntToStr(FTotalPages);
    TRMEndPages(GetEndPages).CurPageNo := FCurPage;
  end;
end;

procedure TRMVirtualPreview.LoadFromFile(aFileName: string);
var
  lSaveReport: TRMCustomReport;
begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;

  FPaintAllowed := False;
  lSaveReport := FReport;
  try
    TRMReport(FReport).LoadPreparedReport(aFileName);
    //    SetLength(FVisiblePages, 0);
  finally
    Connect(lSaveReport);
  end;
end;

procedure TRMVirtualPreview.LoadFromFiles(aFileNames: TStrings);
var
  i: Integer;
  lSaveReport: TRMCustomReport;

  procedure _AppendReport(const aFileName: string; aEndPages: TRMEndPages);
  var
    lStream: TFileStream;
  begin
    if not FileExists(aFileName) then Exit;
    lStream := TFileStream.Create(aFileName, fmOpenRead);
    try
      aEndPages.AppendFromStream(lStream);
    finally
      lStream.Free;
    end;
  end;

begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;

  FPaintAllowed := False;
  lSaveReport := FReport;
  try
    for i := 0 to aFileNames.Count - 1 do
    begin
      if i = 0 then
        TRMReport(FReport).LoadPreparedReport(aFileNames[i])
      else
        _AppendReport(aFileNames[i], TRMReport(FReport).EndPages);
    end;
  finally
    Connect(lSaveReport);
  end;
end;

procedure TRMVirtualPreview.SaveToFile(aFileName: string; aIndex: Integer);
begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;

  FPaintAllowed := False;
  try
    if aIndex < 2 then
    begin
      aFileName := ChangeFileExt(aFileName, '.rmp');
      TRMReport(FReport).SavePreparedReport(aFileName);
    end
    else if (FReport <> nil) and TRMReport(FReport).CanExport then //export输出
    begin
      TRMReport(Report).ExportTo(TRMExportFilter(RMFilters(aIndex - 2).Filter),
        ChangeFileExt(aFileName, Copy(RMFilters(aIndex - 2).FilterExt, 2, 255)));
    end;
  finally
    Connect_1(FReport);
    RedrawAll(False);
  end;
end;

procedure TRMVirtualPreview.ExportToFile(aExport: TComponent; aFileName: string);
begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;

  FPaintAllowed := False;
  try
    TRMReport(Report).ExportTo(TRMExportFilter(aExport), aFileName);
  finally
    RedrawAll(False);
  end;
end;

type
  THackExport = class(TRMExportFilter)
  end;

procedure TRMVirtualPreview.ExportToXlsFile;
var
  i: Integer;
  lXLSExport: TRMExportFilter;
  lSaveShowDialog: Boolean;
  lFound: Boolean;
begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;
  if not TRMReport(FReport).CanExport then Exit;

  lXLSExport := nil;
  lFound := False;
  for i := 0 to RMFiltersCount - 1 do
  begin
    lXLSExport := TRMExportFilter(RMFilters(i).Filter);
    if lXLSExport.IsXLSExport then
    begin
      lFound := True;
      Break;
    end;
  end;

  if lFound then
  begin
    lSaveShowDialog := lXLSExport.ShowDialog;
    try
      if lXLSExport.ShowModal = mrOK then
      begin
        lXLSExport.ShowDialog := False;
        FPaintAllowed := False;
        ExportToFile(lXLSExport, THackExport(lXLSExport).FileName);
      end;
    finally
      lXLSExport.ShowDialog := lSaveShowDialog;
      RedrawAll(False);
    end;
  end;
end;

procedure TRMVirtualPreview.SetPageRect;
var
  i, j, y, d, maxx, maxy, lMaxHeight, lCurXOff: Integer;
  lTmpInt: Integer;
  lPageWidth, lPageHeight: Integer;
  lPages: TRMEndPages;
  lEndPage: TRMEndPage;
  lDrawPanelWidth: Integer;
begin
  if (GetEndPages = nil) or (FTotalPages < 1) or (FCurPage < 1) then Exit;

  FPaintAllowed := False;
  lPages := TRMEndPages(GetEndPages);
  lPageWidth := lPages[FCurPage - 1].PrinterInfo.ScreenPageWidth;
  lPageHeight := lPages[FCurPage - 1].PrinterInfo.ScreenPageHeight;
  case FZoomMode of
    mdPageWidth: FScale := (FDrawPanel.Width - 20) / lPageWidth;
    mdOnePage: FScale := (FDrawPanel.Height - 20) / lPageHeight;
    mdTwoPages: FScale := (FDrawPanel.Width - 30) / (2 * lPageWidth);
    mdPrinterZoom: FScale := RMPrinter.FactorY;
  end;

  FColumns := 0;
  maxx := 10;
  j := 0;
  for i := 0 to lPages.Count - 1 do
  begin
    d := maxx + 10 + Round(lPages[i].PrinterInfo.ScreenPageWidth * FScale);
    if d > FDrawPanel.Width then
    begin
      if FColumns < j then
        FColumns := j;
      j := 0;
      maxx := 10;
    end
    else
    begin
      maxx := d;
      Inc(j);
      if i = lPages.Count - 1 then
      begin
        if FColumns < j then
          FColumns := j;
      end;
    end;
  end;

  if FColumns = 0 then
    FColumns := 1;
  if FZoomMode = mdOnePage then
    FColumns := 1;
  if FZoomMode = mdTwoPages then
    FColumns := 2;

  y := 10;
  i := 0;
  maxx := 0; maxy := 0;
  lDrawPanelWidth := FDrawPanel.Width;
  if VScrollBar.PageSize > VScrollBar.Range then
    lDrawPanelWidth := lDrawPanelWidth - VScrollBar.Width;

  while i < lPages.Count do
  begin
    lMaxHeight := 0; lCurXOff := 10;
    for j := 0 to FColumns - 1 do
    begin
      lEndPage := lPages[i];
      lPageWidth := Round(lEndPage.PrinterInfo.ScreenPageWidth * FScale);
      lPageHeight := Round(lEndPage.PrinterInfo.ScreenPageHeight * FScale);
      if (FColumns = 1) and (lPageWidth < lDrawPanelWidth) then
      begin
        lTmpInt := (lDrawPanelWidth - lPageWidth) div 2;
        lEndPage.PageRect := Rect(lTmpInt, y, lTmpInt + lPageWidth, y + lPageHeight);
      end
      else
        lEndPage.PageRect := Rect(lCurXOff, y, lCurXOff + lPageWidth, y + lPageHeight);

      maxx := Max(maxx, lEndPage.PageRect.Right);
      maxy := Max(maxy, lEndPage.PageRect.Bottom);
      lMaxHeight := Max(lMaxHeight, lPageHeight);
      Inc(lCurXOff, lPageWidth + 10);
      Inc(i);
      if i >= lPages.Count then Break;
    end;

    Inc(y, lMaxHeight + 10);
  end;

  HScrollBar.Range {Max} := maxx + 10;
  HScrollBar.PageSize := FScrollBox.ClientWidth;
  if HScrollBar.Position > HScrollBar.Range {Max} - HScrollBar.LargeChange then
    HScrollBar.Position := HScrollBar.Range {Max} - HScrollBar.LargeChange;
  if (HScrollBar.Position > 0) and (HScrollBar.PageSize > HScrollBar.Range) then
    HScrollBar.Position := 0;

  VScrollBar.Range {Max} := maxy + 10;
  VScrollBar.PageSize := FScrollBox.ClientHeight;
  if VScrollBar.Position > VScrollBar.Range {Max} - VScrollBar.LargeChange then
    VScrollBar.Position := VScrollBar.Range {Max} - VScrollBar.LargeChange;

//  if lDrawPanelWidth <> FDrawPanel.Width then
//  begin
//  end;

  FPaintAllowed := True;
end;

procedure TRMVirtualPreview.BeginPrepareReport(aReport: TRMCustomReport);
begin
  NeedRepaint := False;
  FPrepareReportFlag := True;
  TRMPreview(Self).SetButtonsVisible;
end;

procedure TRMVirtualPreview.InternalOnProgress(aReport: TRMCustomReport;
  aPercent: Integer);
begin
  if TRMReport(aReport).DoublePass and (not TRMReport(aReport).FinalPass) then
    FTotalPages := 0
  else
    FTotalPages := TRMEndPages(GetEndPages).Count;

  SetPageRect;
  if FTotalPages = 1 then
    FDrawPanel.Repaint;

  if TRMReport(aReport).DoublePass and (not TRMReport(aReport).FinalPass) then
  begin
    FStatusBar.Panels[0].Text := Format('%s %d', [RMLoadStr(SFirstPass), TRMEndPages(GetEndPages).Count]);
  end
  else
  begin
    FStatusBar.Panels[0].Text := Format('%s %d/%d', [RMLoadStr(SPg), FCurPage, FTotalPages]);
  end;
end;

procedure TRMVirtualPreview.EndPrepareReport(aReport: TRMCustomReport);
begin
  FPrepareReportFlag := False;
  if GetEndPages = nil then Exit;

  FTotalPages := TRMEndPages(GetEndPages).Count;
  TRMPreview(Self).SetButtonsVisible;
  SetOutLineInfo;
  SetPageRect;
  if (FColumns > 1) or TRMReport(aReport).AutoSetPageLength or NeedRepaint then
  begin
    FDrawPanel.FRepaintPageNo := CurPage - 1;
    FDrawPanel.Repaint;
  end;
end;

procedure TRMVirtualPreview.OnResizeEvent(Sender: TObject);
begin
  if (GetEndPages = nil) or (FTotalPages < 1) then
  begin
    HScrollBar.Range := 2;
    HScrollBar.PageSize := 1;
    VScrollBar.Range := 2;
    HScrollBar.PageSize := 1;
    Exit;
  end;

  if FCurPage < 1 then Exit;

  SetPageRect;
  SetToCurPage;
  DoStatusChange;
end;

procedure TRMVirtualPreview.OnSplitterMovedEvent(Sender: TObject);
begin
  OnResizeEvent(nil);
end;

procedure TRMVirtualPreview.RedrawAll(aResetPage: Boolean);
var
  i: Integer;
begin
  FPaintAllowed := True;
  FScale := FLastScale;
  if aResetPage then
  begin
    FCurPage := 1;
    FOffsetLeft := 0;
    FOffsetTop := 0;
    FOldHPos := 0;
    FOldVPos := 0;
    HScrollBar.Position := 0;
    VScrollBar.Position := 0;
  end;
  ShowPageNum;
  OnResizeEvent(nil);

  if GetEndPages <> nil then
  begin
    for i := 0 to FTotalPages - 1 do
    begin
      TRMEndPages(GetEndPages).Pages[i].RemoveCachePage;
    end;
  end;

  FDrawPanel.Repaint;
end;

procedure TRMVirtualPreview.OnScrollBoxScroll(Sender: TObject; Kind: TRMScrollBarKind);
var
  i, p, pp: Integer;
  lRect: TRect;
  lPages: TRMEndPages;
begin
  if GetEndPages = nil then Exit;

  if Kind = rmsbHorizontal then
  begin
    p := HScrollBar.Position;
    pp := FOldHPos - p;
    FOldHPos := p;
    FOffsetLeft := -p;
    lRect := Rect(0, 0, FDrawPanel.Width, FDrawPanel.Height);
    ScrollWindow(FDrawPanel.Handle, pp, 0, @lRect, @lRect);
  end
  else
  begin
    lPages := TRMEndPages(GetEndPages);
    p := VScrollBar.Position;
    pp := FOldVPos - p;
    FOldVPos := p;
    FOffsetTop := -p;
    lRect := Rect(0, 0, FDrawPanel.Width, FDrawPanel.Height);
    ScrollWindow(FDrawPanel.Handle, 0, pp, @lRect, @lRect);
    for i := 0 to lPages.Count - 1 do
    begin
      if (lPages[i].PageRect.Top < -FOffsetTop + 11) and (lPages[i].PageRect.Bottom > -FOffsetTop + 11) then
      begin
        FCurPage := i + 1;
        ShowPageNum;
        Break;
      end;
    end;
  end;
end;

procedure TRMVirtualPreview.SetPage(Value: Integer);
begin
  if FCurPage <> Value then
  begin
    if Value < 1 then
      Value := 1;
    if Value > TotalPages then
      Value := TotalPages;
    FCurPage := Value;
    SetToCurPage;
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);
  end;
end;

function TRMVirtualPreview.GetZoom: Double;
begin
  Result := FScale * 100;
end;

procedure TRMVirtualPreview.SetZoom(Value: Double);
begin
  FScale := Value / 100;
  FZoomMode := mdNone;
  LastScale := FScale;
  OnResizeEvent(nil);
  FDrawPanel.Paint;
  DoStatusChange;
end;

procedure TRMVirtualPreview.OnePage;
begin
  FZoomMode := mdOnePage;
  OnResizeEvent(nil);
  FDrawPanel.Paint;
  DoStatusChange;
end;

procedure TRMVirtualPreview.TwoPages;
begin
  FZoomMode := mdTwoPages;
  OnResizeEvent(nil);
  FDrawPanel.Paint;
  DoStatusChange;
end;

procedure TRMVirtualPreview.PageWidth;
begin
  FZoomMode := mdPageWidth;
  OnResizeEvent(nil);
  FDrawPanel.Paint;
  DoStatusChange;
end;

procedure TRMVirtualPreview.PrinterZoom;
begin
  if RMPrinter.PrinterInfo.IsValid then
    FZoomMode := mdPrinterZoom
  else
    FZoomMode := mdPageWidth;

  OnResizeEvent(nil);
  FDrawPanel.Paint;
  DoStatusChange;
end;

procedure TRMVirtualPreview.First;
begin
  CurPage := 1;
end;

procedure TRMVirtualPreview.Next;
begin
  CurPage := CurPage + 1;
end;

procedure TRMVirtualPreview.Prev;
begin
  CurPage := CurPage - 1;
end;

procedure TRMVirtualPreview.Last;
begin
  CurPage := TotalPages;
end;

procedure TRMVirtualPreview.Print;
var
  lSavePrinterIndex: Integer;
  lNeedSave: Boolean;
  lPages: string;
  lForm: TRMPrintDialogForm;
begin
  if FPrepareReportFlag then Exit;
  if (GetEndPages = nil) or (RMPrinters.Count = 2) then Exit;

  lForm := TRMPrintDialogForm.Create(nil);
  try
    with lForm do
    begin
      CurrentPrinter := TRMReport(FReport).ReportPrinter;
      Copies := TRMReport(FReport).DefaultCopies;
      chkCollate.Checked := TRMReport(FReport).DefaultCollate;
      chkTaoda.Checked := TRMReport(FReport).PrintBackGroundPicture;
      chkColorPrint.Checked := TRMReport(FReport).ColorPrint;
      THackReport(FReport).ScalePageSize := -1;
      THackReport(FReport).ScaleFactor := 100;
      PrintOffsetTop := TRMReport(FReport).PrintOffsetTop;
      PrintOffsetLeft := TRMReport(FReport).PrintOffsetLeft;
      if TRMReport(Report).ShowPrintDialog then
        lSavePrinterIndex := TRMReport(FReport).ReportPrinter.PrinterIndex
      else
        lSavePrinterIndex := -1;

      if (not TRMReport(Report).ShowPrintDialog) or (ShowModal = mrOK) then
      begin
        if TRMReport(FReport).CanRebuild and (lForm.NeedRebuild or
          (TRMReport(FReport).ReportPrinter.PrinterIndex <> lSavePrinterIndex)) then // 改变了打印机设置
        begin
          {          if TRMReport(FReport).ChangePrinter(liSavePrinterIndex, TRMReport(FReport).ReportPrinter.PrinterIndex) then
                    begin
                      TRMEndPages(FEndPages).Free;
                      FEndPages := nil;
                      TRMReport(FReport).PrepareReport;
                      Connect(FReport);
                    end
                    else
                    begin
                      Free;
                      Exit;
                    end;
                  }
        end;

        TRMReport(FReport).ColorPrint := chkColorPrint.Checked;
        THackReport(FReport).Flag_PrintBackGroundPicture := not chkTaoda.Checked;
        GetPageInfo(THackReport(FReport).ScalePageWidth, THackReport(FReport).ScalePageHeight, THackReport(FReport).ScalePageSize);
        THackReport(FReport).ScaleFactor := lForm.ScaleFactor;
        lNeedSave := (TRMReport(FReport).PrintOffsetTop <> PrintOffsetTop) or
          (TRMReport(FReport).PrintOffsetLeft <> PrintOffsetLeft);
        TRMReport(FReport).PrintOffsetTop := PrintOffsetTop;
        TRMReport(FReport).PrintOffsetLeft := PrintOffsetLeft;
        if rdbPrintAll.Checked then
          lPages := ''
        else if rbdPrintCurPage.Checked then
          lPages := IntToStr(FCurPage)
        else
          lPages := edtPages.Text;

        if lNeedSave then
          TRMReport(FReport).SaveReportOptions.SaveReportSetting(TRMReport(FReport), '', False);

        FPaintAllowed := False;
        try
          TRMReport(FReport).PrintPreparedReport(lPages, Copies, chkCollate.Checked,
            TRMPrintPages(cmbPrintAll.ItemIndex));
        finally
          Connect_1(FReport);
          RedrawAll(False);
        end;
      end;
    end;
  finally
    lForm.Free;
  end;
end;

procedure TRMVirtualPreview.PrintCurrentPage; //打印当前页
begin
  if FPrepareReportFlag then Exit;
  if (GetEndPages = nil) or (RMPrinters.Count = 2) then Exit;

  FPaintAllowed := False;
  try
    THackReport(FReport).Flag_PrintBackGroundPicture := TRMReport(FReport).PrintbackgroundPicture;
    THackReport(FReport).ScalePageSize := -1;
    THackReport(FReport).ScaleFactor := 100;

    TRMReport(FReport).PrintPreparedReport(IntToStr(CurPage), 1, TRMReport(FReport).DefaultCollate,
      rmppAll);
  finally
    RedrawAll(False);
  end;
end;

procedure TRMVirtualPreview.DlgPageSetup;
var
  lSaveReport: TRMCustomReport;
  tmpForm: TRMPageSetupForm;
  liEndPage: TRMEndPage;
  lPage: TRMCustomPage;
  i: Integer;
  lPageWidth, lhRgn, lPageSize: Integer;
  lOldIndex: Integer;
begin
  if FPrepareReportFlag or (GetEndPages = nil) then Exit;

  liEndPage := TRMEndPages(GetEndPages)[Self.CurPage - 1];
  if liEndPage = nil then Exit;

  lOldIndex := RMPrinter.PrinterIndex;
  tmpForm := TRMPageSetupForm.Create(nil);
  try
    tmpForm.CurReport := TRMReport(Report);
    tmpForm.CurPrinter := TRMReport(Report).ReportPrinter;
    with liEndPage do
    begin
      tmpForm.PageSetting.PrinterName := RMPrinters.Printers[RMPrinter.PrinterIndex];
      tmpForm.PageSetting.Title := TRMReport(Report).ReportInfo.Title;
      tmpForm.PageSetting.DoublePass := TRMReport(Report).DoublePass;
      tmpForm.PageSetting.PrintBackGroundPicture := TRMReport(Report).PrintbackgroundPicture;
      tmpForm.PageSetting.ColorPrint := TRMReport(Report).ColorPrint;
      tmpForm.PageSetting.MarginLeft := RMFromMMThousandths(mmMarginLeft, rmutMillimeters);
      tmpForm.PageSetting.MarginTop := RMFromMMThousandths(mmMarginTop, rmutMillimeters);
      tmpForm.PageSetting.MarginRight := RMFromMMThousandths(mmMarginRight, rmutMillimeters);
      tmpForm.PageSetting.MarginBottom := RMFromMMThousandths(mmMarginBottom, rmutMillimeters);
      tmpForm.PageSetting.PageOr := PageOrientation;
      tmpForm.PageSetting.PageBin := PageBin;
      tmpForm.PageSetting.PageSize := PageSize;
      tmpForm.PageSetting.PageWidth := PageWidth;
      tmpForm.PageSetting.PageHeight := PageHeight;
      tmpForm.PageSetting.UnlimitedHeight := True;
      if tmpForm.PreviewPageSetup then
      begin
        if lOldIndex <> tmpForm.cmbPrinterNames.ItemIndex then
          TRMReport(Report).ChangePrinter(RMPrinter.PrinterIndex, tmpForm.cmbPrinterNames.ItemIndex);

        TRMReport(Report).ReportInfo.Title := tmpForm.PageSetting.Title;
        TRMReport(Report).DoublePass := tmpForm.PageSetting.DoublePass;
        TRMReport(Report).PrintbackgroundPicture := tmpForm.PageSetting.PrintbackgroundPicture;
        TRMReport(Report).ColorPrint := tmpForm.PageSetting.ColorPrint;

        mmMarginLeft := RMToMMThousandths(tmpForm.PageSetting.MarginLeft, rmutMillimeters);
        mmMarginTop := RMToMMThousandths(tmpForm.PageSetting.MarginTop, rmutMillimeters);
        mmMarginRight := RMToMMThousandths(tmpForm.PageSetting.MarginRight, rmutMillimeters);
        mmMarginBottom := RMToMMThousandths(tmpForm.PageSetting.MarginBottom, rmutMillimeters);

        PageOrientation := tmpForm.PageSetting.PageOr;
        PageBin := tmpForm.PageSetting.PageBin;
        lPageSize := tmpForm.PageSetting.PageSize;
        lPageWidth := tmpForm.PageSetting.PageWidth;
        lhRgn := tmpForm.PageSetting.PageHeight;
        if tmpForm.chkUnlimitedHeight.Checked then
        begin
          for i := 0 to TRMReport(Report).Pages.Count - 1 do
          begin
            lPage := TRMReport(Report).Pages[i];
            if lPage is TRMReportPage then
            begin
              TRMReportPage(lPage).mmMarginLeft := mmMarginLeft;
              TRMReportPage(lPage).mmMarginTop := mmMarginTop;
              TRMReportPage(lPage).mmMarginRight := mmMarginRight;
              TRMReportPage(lPage).mmMarginBottom := mmMarginBottom;
              TRMReportPage(lPage).ChangePaper(lPageSize, lPageWidth, lhRgn, liEndPage.PageBin, liEndPage.PageOrientation);
            end;
          end;
        end;

        TRMReport(Report).SaveReportOptions.SaveReportSetting(TRMReport(Report), '', False);
        if Assigned(OnAfterPageSetup) then
          OnAfterPageSetup(tmpForm.PageSetting);

        if TRMReport(Report).CanRebuild then
        begin
          FPaintAllowed := False;
          //SetLength(FVisiblePages, 0);
          lSaveReport := FReport;
          TRMReport(Report).PrepareReport;
          Connect_1(lSaveReport);
        end;

        RedrawAll(True);
      end;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMVirtualPreview.AddPage;
begin
  if FPrepareReportFlag then Exit;
  if FReport = nil then Exit;

  TRMEndPages(GetEndPages).InsertFromEndPage(FTotalPages,
    TRMEndPages(GetEndPages).Pages[FTotalPages - 1]);
  FTotalPages := TRMEndPages(GetEndPages).Count;
  RedrawAll(False);
end;

procedure TRMVirtualPreview.InsertPageBefore;
var
  liEndPage: TRMEndPage;
  liPageNo: Integer;
begin
  if FPrepareReportFlag then Exit;
  if FReport = nil then Exit;

  if FCurPage > FTotalPages then
  begin
    liEndPage := TRMEndPages(GetEndPages).Pages[FTotalPages - 1];
    liPageNo := FTotalPages - 1;
  end
  else
  begin
    liEndPage := TRMEndPages(GetEndPages).Pages[FCurPage - 1];
    liPageNo := FCurPage - 1;
  end;

  TRMEndPages(GetEndPages).InsertFromEndPage(liPageNo, liEndPage);
  TRMReport(FReport).Modified := True;
  FTotalPages := TRMEndPages(GetEndPages).Count;
  RedrawAll(False);
end;

procedure TRMVirtualPreview.InsertPageAfter;
begin
  if FPrepareReportFlag then Exit;
  if FReport = nil then Exit;

  if FCurPage > FTotalPages then
    AddPage
  else
  begin
    TRMEndPages(GetEndPages).InsertFromEndPage(FCurPage, TRMEndPages(GetEndPages).Pages[FCurPage - 1]);
    RedrawAll(False);
  end;

  FTotalPages := TRMEndPages(GetEndPages).Count;
  TRMReport(FReport).Modified := True;
end;

procedure TRMVirtualPreview.DeletePage(PageNo: Integer);
begin
  if FPrepareReportFlag then Exit;
  if (FReport = nil) or (GetEndPages = nil) then Exit;

  if (PageNo >= 0) and (FTotalPages > 1) then
  begin
    if MessageBox(0, PChar(RMLoadStr(SRemovePg)), PChar(RMLoadStr(SConfirm)),
      mb_YesNo + mb_IconQuestion) = mrYes then
    begin
      TRMEndPages(GetEndPages).Delete(PageNo);
      FTotalPages := TRMEndPages(GetEndPages).Count;
      RedrawAll(True);
      TRMReport(FReport).Modified := True;
    end;
  end;
end;

function TRMVirtualPreview.EditPage(PageNo: Integer): Boolean;
begin
  Result := False;

  if FPrepareReportFlag then Exit;
  if not CanModify then Exit;
  if (PageNo >= 0) and (PageNo < FTotalPages) then
  begin
    FPaintAllowed := False;
    try
      Result := TRMReport(FReport).EditPreparedReport(PageNo);
    finally
      Connect_1(FReport);
      RedrawAll(False);
    end;
  end;
end;

procedure TRMVirtualPreview.DesignReport;
begin
  if FPrepareReportFlag then Exit;
  if not ((RMDesignerClass <> nil) and Assigned(FReport)) then Exit;
  if (not TRMReport(FReport).CanRebuild) or (TRMReport(FReport) is TRMCompositeReport) then
    Exit;

  FPaintAllowed := False;
  try
    TRMReport(FReport).DesignPreviewedReport;
  finally
    Connect_1(FReport);
    RedrawAll(False);
  end;
end;

procedure TRMVirtualPreview.OnMouseWheelUpEvent(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  VScrollBar.Position := VScrollBar.Position - VScrollBar.SmallChange;
end;

procedure TRMVirtualPreview.OnMouseWheelDownEvent(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  VScrollBar.Position := VScrollBar.Position + VScrollBar.SmallChange;
end;

function EnumEMFRecordsProc(DC: HDC; HandleTable: PHandleTable;
  EMFRecord: PEnhMetaRecord; nObj: Integer; OptData: Pointer): Bool; stdcall;
var
  Typ: Byte;
  s: string;
  t: TEMRExtTextOut;
  s1: PChar;

  function _FindText(const aStr: string): Boolean;
  var
    liPos, liLen: Integer;
  begin
    Result := False;
    liPos := Pos(aStr, s);
    liLen := Length(aStr);
    while (liPos > 0) and (not Result) do
    begin
      if liPos < Length(s) then
      begin
        if (s[liPos + liLen] in RMBreakChars) or (s[liPos + liLen] in LeadBytes) then
          Result := True;
      end
      else
        Result := True;

      if not Result then
      begin
        System.Delete(s, 1, liPos - 1 + liLen);
        liPos := Pos(aStr, s);
      end;
    end;
  end;

begin
  Result := True;
  Typ := EMFRecord^.iType;
  if Typ in [83, 84] then
  begin
    t := PEMRExtTextOut(EMFRecord)^;
    if RMGetWindowsVersion <> 'NT' then
    begin
      s1 := StrAlloc(t.EMRText.nChars + 1);
      StrLCopy(s1, PChar(PChar(EMFRecord) + t.EMRText.offString), t.EMRText.nChars);
      s := StrPas(s1);
      StrDispose(s1);
    end
    else
      s := WideCharLenToString(PWideChar(PChar(EMFRecord) + t.EMRText.offString),
        t.EMRText.nChars);

    if not FCurPreview.CaseSensitive then
      s := AnsiUpperCase(s);

    if FCurPreview.Wholewords then
    begin
      FCurPreview.StrFound := _FindText(FCurPreview.FindStr);
    end
    else
      FCurPreview.StrFound := Pos(FCurPreview.FindStr, s) <> 0;

    if FCurPreview.StrFound and (FRecordNum >= FCurPreview.LastFoundObject) then
    begin
      FCurPreview.StrBounds := t.rclBounds;
      Result := False;
    end;
  end;
  Inc(FRecordNum);
end;

procedure TRMVirtualPreview.FindInEMF(lEmf: TMetafile);
begin
  FCurPreview := Self;
  FRecordNum := 0;
  EnumEnhMetafile(0, lEmf.Handle, @EnumEMFRecordsProc, nil, Rect(0, 0, 0, 0));
end;

procedure TRMVirtualPreview.FindNext;
var
  lEmf: TMetafile;
  lEmfCanvas: TMetafileCanvas;
  lEndPage: TRMEndPage;
  i, nx, ny, ndx, ndy: Integer;
begin
  if FPrepareReportFlag then Exit;

  FStrFound := False;
  while FLastFoundPage < FTotalPages do
  begin
    lEndPage := TRMEndPages(GetEndPages).Pages[FLastFoundPage];
    lEmf := TMetafile.Create;
    lEmf.Width := lEndPage.PrinterInfo.ScreenPageWidth;
    lEmf.Height := lEndPage.PrinterInfo.ScreenPageHeight;
    lEmfCanvas := TMetafileCanvas.Create(lEmf, 0);
    lEndPage.Visible := True;
    lEndPage.Draw(TRMReport(FReport), lEmfCanvas,
      Rect(0, 0, lEndPage.PrinterInfo.ScreenPageWidth, lEndPage.PrinterInfo.ScreenPageHeight));
    lEmfCanvas.Free;

    FindInEMF(lEmf);
    lEmf.Free;
    if FStrFound then
    begin
      FCurPage := FLastFoundPage + 1;
      ShowPageNum;
      nx := lEndPage.PageRect.Left + Round(StrBounds.Left * FScale);
      ny := Round(StrBounds.Top * FScale) + 10;
      ndx := Round((StrBounds.Right - StrBounds.Left) * FScale);
      ndy := Round((StrBounds.Bottom - StrBounds.Top) * FScale);

      if ny > FDrawPanel.Height - ndy then
      begin
        VScrollBar.Position := lEndPage.PageRect.Top + ny - FDrawPanel.Height - 10 + ndy;
        ny := FDrawPanel.Height - ndy;
      end
      else
        VScrollBar.Position := lEndPage.PageRect.Top - 10;

      if nx > FDrawPanel.Width - ndx then
      begin
        HScrollBar.Position := lEndPage.PageRect.Left + nx - FDrawPanel.Width - 10 + ndx;
        nx := FDrawPanel.Width - ndx;
      end
      else
        HScrollBar.Position := lEndPage.PageRect.Left - 10;

      LastFoundObject := FRecordNum;
      Application.ProcessMessages;

      FPaintAllowed := True;
      FDrawPanel.Paint;
      with FDrawPanel.Canvas do
      begin
        Pen.Width := 1;
        Pen.Mode := pmXor;
        Pen.Color := clWhite;
        for i := 0 to ndy do
        begin
          MoveTo(nx, ny + i);
          LineTo(nx + ndx, ny + i);
        end;
        Pen.Mode := pmCopy;
      end;

      Break;
    end
    else
    begin
      lEndPage.RemoveCachePage;
    end;

    FLastFoundObject := 0;
    Inc(FLastFoundPage);
  end;
end;

procedure TRMVirtualPreview.Find;
var
  tmp: TRMPreviewSearchForm;
begin
  if FPrepareReportFlag then Exit;
  if FReport = nil then Exit;

  tmp := TRMPreviewSearchForm.Create(Application);
  try
    tmp.chkCaseSensitive.Checked := FCaseSensitive;
    tmp.chkWholewords.Checked := FWholewords;
    tmp.edtSearchTxt.Text := FFindStr;
    if tmp.ShowModal = mrOk then
    begin
      FFindStr := tmp.edtSearchTxt.Text;
      FCaseSensitive := tmp.chkCaseSensitive.Checked;
      FWholewords := tmp.chkWholewords.Checked;
      if not FCaseSensitive then
        FFindStr := AnsiUpperCase(FFindStr);
      if tmp.rdbFromFirst.Checked then
      begin
        FLastFoundPage := 0;
        FLastFoundObject := 0;
      end
      else if FLastFoundPage <> FCurPage - 1 then
      begin
        FLastFoundPage := FCurPage - 1;
        FLastFoundObject := 0;
      end;

      FreeAndNil(tmp);
      FindNext;
    end;
  finally
    FreeAndNil(tmp);
  end;
end;

procedure TRMVirtualPreview.ShowOutline(aVisible: Boolean);
begin
  FOutlineTreeView.Visible := aVisible;
  FSplitter.Visible := FOutlineTreeView.Visible;
  FSplitter.Left := FOutLineTreeView.Left + 10;
end;

function TRMVirtualPreview.GetHScrollBar: TRMScrollBar;
begin
  Result := FScrollBox.HorzScrollBar;
end;

function TRMVirtualPreview.GetVScrollBar: TRMScrollBar;
begin
  Result := FScrollBox.VertScrollBar;
end;

function TRMVirtualPreview.GetEndPages: TObject;
begin
  if FReport <> nil then
    Result := TRMReport(FReport).EndPages
  else
    Result := nil;
end;

procedure TRMVirtualPreview.SetKWheel(Value: Integer);
begin
  if FKWheel = Value then Exit;

  FKWheel := Value;
  HScrollBar.SmallChange := FKWheel;
  VScrollBar.SmallChange := FKWheel;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMPreview.Create(AOwner: TComponent);
begin
  inherited;

  ProcMenu := nil;
  IsStanderPreview := False;
  Dock971 := nil;

  //  OnKeyDown := OnKeyDownEvent;
end;

destructor TRMPreview.Destroy;
begin
  inherited Destroy;
end;

procedure TRMPreview.CreateButtons;

  procedure _CreateDock;
  begin
    Dock971 := TRMDock.Create(Self);
    with Dock971 do
    begin
      Parent := Self;
      FixAlign := True;
      Name := 'Dock971';
    end;
  end;

  procedure _CreateToolbar;
  begin
    ToolbarStand := TRMToolbar.Create(Self);
    ToolbarStand.BeginUpdate;
    with ToolbarStand do
    begin
      DockedTo := Dock971;
      CloseButton := False;
      DockRow := 0;
      DockPos := 0;
      Name := 'ToolbarPreviewStand';
    end;

    cmbZoom := TRMComboBox97.Create(ToolbarStand);
    with cmbZoom do
    begin
      TabStop := False;
      Parent := ToolbarStand;
      Width := 80; //90;
      DropDownCount := 12;
      Items.Add('200%');
      Items.Add('150%');
      Items.Add('100%');
      Items.Add('75%');
      Items.Add('50%');
      Items.Add('25%');
      Items.Add('10%');
      Items.Add(RMLoadStr(rmRes + 1857));
      Items.Add(RMLoadStr(rmRes + 1858));
      Items.Add(RMLoadStr(rmRes + 1859));
      //    Items.Add(RMLoadStr(rmRes + 1870));
      OnClick := CmbZoomClick;
      OnKeyPress := CmbZoomKeyPress;
    end;
    tbLine := TRMToolbarSep.Create(ToolbarStand);
    with tbLine do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(tbLine);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnOnePage := TRMToolbarButton.Create(ToolbarStand);
    with btnOnePage do
    begin
      AllowAllUp := True;
      GroupIndex := 2;
      ImageIndex := 1;
      Images := FWindow.ImageList1;
      OnClick := btnOnePageClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnOnePage);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    btn100 := TRMToolbarButton.Create(ToolbarStand);
    with btn100 do
    begin
      Hint := '100%';
      AllowAllUp := True;
      GroupIndex := 2;
      ImageIndex := 2;
      Images := FWindow.ImageList1;
      OnClick := btn100Click;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btn100);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    btnPageWidth := TRMToolbarButton.Create(ToolbarStand);
    with btnPageWidth do
    begin
      AllowAllUp := True;
      GroupIndex := 2;
      ImageIndex := 3;
      Images := FWindow.ImageList1;
      OnClick := btnPageWidthClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnPageWidth);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    ToolbarSep974 := TRMToolbarSep.Create(ToolbarStand);
    with ToolbarSep974 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(ToolbarSep974);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnTop := TRMToolbarButton.Create(ToolbarStand);
    with btnTop do
    begin
      ImageIndex := 4;
      Images := FWindow.ImageList1;
      OnClick := btnTopClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnTop);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    btnPrev := TRMToolbarButton.Create(ToolbarStand);
    with btnPrev do
    begin
      ImageIndex := 5;
      Images := FWindow.ImageList1;
      OnClick := btnPrevClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnPrev);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    edtPageNo := TRMEdit.Create(ToolbarStand);
    with edtPageNo do
    begin
      OnKeyPress := edtPageNoKeyPress;
{$IFDEF USE_TB2k}
      EditWidth := 34;
      ToolbarStand.Items.Add(edtPageNo);
{$ELSE}
      Width := 34;
      Parent := ToolbarStand;
{$ENDIF}
      TabOrder := 0;
      TabStop := False;
    end;
    btnNext := TRMToolbarButton.Create(ToolbarStand);
    with btnNext do
    begin
      ImageIndex := 6;
      Images := FWindow.ImageList1;
      OnClick := btnNextClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnNext);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    btnLast := TRMToolbarButton.Create(ToolbarStand);
    with btnLast do
    begin
      ImageIndex := 7;
      Images := FWindow.ImageList1;
      OnClick := btnLastClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnLast);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    ToolbarSep972 := TRMToolbarSep.Create(ToolbarStand);
    with ToolbarSep972 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(ToolbarSep972);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnFind := TRMToolbarButton.Create(ToolbarStand);
    with btnFind do
    begin
      ImageIndex := 8;
      Images := FWindow.ImageList1;
      OnClick := btnFindClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnFind);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    ToolbarSep975 := TRMToolbarSep.Create(ToolbarStand);
    with ToolbarSep975 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(ToolbarSep975);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnOpen := TRMToolbarButton.Create(ToolbarStand);
    with btnOpen do
    begin
      ImageIndex := 9;
      Images := FWindow.ImageList1;
      OnClick := btnOpenClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnOpen);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
{$IFDEF USE_TB2K}
    btnSave := TRMSubmenuItem.Create(Self);
{$ELSE}
    btnSave := TRMToolbarButton.Create(Self);
{$ENDIF}
    with btnSave do
    begin
      DropdownCombo := True;
      ImageIndex := 10;
      Images := FWindow.ImageList1;
      OnClick := btnSaveClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnSave);
{$ELSE}
      AddTo := ToolbarStand;
      DropdownMenu := FWindow.FPopupMenu;
{$ENDIF}
    end;

    btnSaveToXLS := TRMToolbarButton.Create(Self);
    with btnSaveToXLS do
    begin
      ImageIndex := 15;
      Images := FWindow.ImageList1;
      OnClick := btnSaveToXLSClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnSaveToXLS);
{$ELSE}
//      Parent := ToolbarStand;
      AddTo := ToolbarStand;
{$ENDIF}
    end;
//{$IFDEF USE_TB2K}
//    btnPrint := TRMSubmenuItem.Create(Self);
//{$ELSE}
    btnPrint := TRMToolbarButton.Create(Self);
//{$ENDIF}
    with btnPrint do
    begin
      //DropdownCombo := True;
      ImageIndex := 11;
      Images := FWindow.ImageList1;
      OnClick := btnPrintClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnPrint);
{$ELSE}
      Parent := ToolbarStand;
      //DropdownMenu := FWindow.FPopupMenuPrint;
{$ENDIF}
    end;
    btnPageSetup := TRMToolbarButton.Create(ToolbarStand);
    with btnPageSetup do
    begin
      ImageIndex := 12;
      Images := FWindow.ImageList1;
      OnClick := btnPageSetupClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnPageSetup);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    ToolbarSep973 := TRMToolbarSep.Create(ToolbarStand);
    with ToolbarSep973 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(ToolbarSep973);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnDesign := TRMToolbarButton.Create(ToolbarStand);
    with btnDesign do
    begin
      ImageIndex := 13;
      Images := FWindow.ImageList1;
      OnClick := btnDesignClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnDesign);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    ToolbarSep971 := TRMToolbarSep.Create(ToolbarStand);
    with ToolbarSep971 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(ToolbarSep971);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnShowOutline := TRMToolbarButton.Create(ToolbarStand);
    with btnShowOutline do
    begin
      AllowAllUp := True;
      GroupIndex := 10;
      ImageIndex := 18;
      Images := FWindow.ImageList1;
      OnClick := btnShowOutlineClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnShowOutline);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
    FBtnShowBorder := TRMToolbarButton.Create(ToolbarStand);
    with FBtnShowBorder do
    begin
      AllowAllUp := True;
      GroupIndex := 3;
      Images := FWindow.ImageList1;
      ImageIndex := 16;
      OnClick := btnShowBorderClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(FBtnShowBorder);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;
(*    FBtnBackColor := TRMColorPickerButton.Create(ToolbarStand);
    with FBtnBackColor do
    begin
      Parent := ToolbarStand;
      ParentShowHint := True;
      ColorType := rmptLine;
      OnColorChange := btnBackColorClick;
    end; *)
    tbSep1 := TRMToolbarSep.Create(ToolbarStand);
    with tbSep1 do
    begin
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(tbSep1);
{$ELSE}
      Parent := ToolbarStand;
{$ENDIF}
    end;

    btnExit := TRMToolbarButton.Create(ToolbarStand);
    with btnExit do
    begin
      ImageIndex := 14;
      Images := FWindow.ImageList1;
      OnClick := BtnExitClick;
{$IFDEF USE_TB2k}
      ToolbarStand.Items.Add(btnExit);
{$ELSE}
      Parent := ToolbarStand;
      Width := 50;
{$ENDIF}
    end;
    ToolbarStand.EndUpdate;
  end;

  procedure _CreateMenu;
  var
    i: Integer;
  {$IFDEF USE_TB2k}
    lMenuItem: TTBItem;
  {$ELSE}
    lMenuItem: TMenuItem;
  {$ENDIF}
    //lAryPrint: array[0..6] of string;
  begin
    if ProcMenu <> nil then Exit;

    ProcMenu := TPopupMenu.Create(Self);

    itmScale200 := TMenuItem.Create(Self);
    with itmScale200 do
    begin
      Tag := 200;
      Caption := '200%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale200);
    end;
    itmScale150 := TMenuItem.Create(Self);
    with itmScale150 do
    begin
      Tag := 150;
      Caption := '150%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale150);
    end;
    itmScale100 := TMenuItem.Create(Self);
    with itmScale100 do
    begin
      Tag := 100;
      Caption := '100%';
      Checked := True;
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale100);
    end;
    itmScale75 := TMenuItem.Create(Self);
    with itmScale75 do
    begin
      Tag := 75;
      Caption := '75%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale75);
    end;
    itmScale50 := TMenuItem.Create(Self);
    with itmScale50 do
    begin
      Tag := 50;
      Caption := '50%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale50);
    end;
    itmScale25 := TMenuItem.Create(Self);
    with itmScale25 do
    begin
      Tag := 25;
      Caption := '25%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale25);
    end;
    itmScale10 := TMenuItem.Create(Self);
    with itmScale10 do
    begin
      Tag := 10;
      Caption := '10%';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmScale10);
    end;
    itmPageWidth := TMenuItem.Create(Self);
    with itmPageWidth do
    begin
      Tag := 1;
      Caption := 'Page width';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmPageWidth);
    end;
    itmOnePage := TMenuItem.Create(Self);
    with itmOnePage do
    begin
      Tag := 2;
      Caption := 'Whole Page';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmOnePage);
    end;
    itmDoublePage := TMenuItem.Create(Self);
    with itmDoublePage do
    begin
      Tag := 3;
      Caption := 'Double Page';
      GroupIndex := 1;
      RadioItem := True;
      OnClick := itmScale10Click;
      ProcMenu.Items.Add(itmDoublePage);
    end;
    N1 := TMenuItem.Create(Self);
    with N1 do
    begin
      Caption := '-';
      ProcMenu.Items.Add(N1);
    end;
    itmPrint := TMenuItem.Create(Self);
    with itmPrint do
    begin
      Caption := 'Print...';
      OnClick := btnPrintClick;
      ProcMenu.Items.Add(itmPrint);
    end;
    itmPrintCurrentPage := TMenuItem.Create(Self);
    with itmPrintCurrentPage do
    begin
      Caption := 'Print Current Page';
      OnClick := itmPrintCurrentPageClick;
      ProcMenu.Items.Add(itmPrintCurrentPage);
    end;
    N4 := TMenuItem.Create(Self);
    with N4 do
    begin
      Caption := '-';
      ProcMenu.Items.Add(N4);
    end;
    itmNewPage := TMenuItem.Create(Self);
    with itmNewPage do
    begin
      Caption := 'Add Page';
      ProcMenu.Items.Add(itmNewPage);
    end;
    itmDeletePage := TMenuItem.Create(Self);
    with itmDeletePage do
    begin
      Caption := 'Remove Page...';
      OnClick := itmDeletePageClick;
      ProcMenu.Items.Add(itmDeletePage);
    end;
    itmEditPage := TMenuItem.Create(Self);
    with itmEditPage do
    begin
      Caption := 'Edit Page...';
      OnClick := itmEditPageClick;
      ProcMenu.Items.Add(itmEditPage);
    end;

    InsertBefore1 := TMenuItem.Create(Self);
    with InsertBefore1 do
    begin
      Caption := 'Insert Before';
      OnClick := InsertBefore1Click;
      itmNewPage.Add(InsertBefore1);
    end;
    InsertAfter1 := TMenuItem.Create(Self);
    begin
      Caption := 'Insert After';
      OnClick := InsertAfter1Click;
      itmNewPage.Add(InsertAfter1);
    end;
    N2 := TMenuItem.Create(Self);
    with N2 do
    begin
      Caption := '-';
      itmNewPage.Add(N2);
    end;
    Append1 := TMenuItem.Create(Self);
    with Append1 do
    begin
      Caption := 'Append';
      OnClick := Append1Click;
      itmNewPage.Add(Append1);
    end;

    FWindow.FPopupMenu.Items.Clear;
    for i := 0 to RMFiltersCount - 1 do
    begin
{$IFDEF USE_TB2k}
      lMenuItem := TTBItem.Create(btnSave);
      lMenuItem.Tag := i;
      lMenuItem.Caption := RMFilters(i).FilterDesc;
      lMenuItem.OnClick := OnmnuExportClick;
      btnSave.Add(lMenuItem);
{$ELSE}
      lMenuItem := TMenuItem.Create(FWindow.FPopupMenu);
      lMenuItem.Caption := RMFilters(i).FilterDesc;
      lMenuItem.Tag := i;
      lMenuItem.OnClick := OnmnuExportClick;
      FWindow.FPopupMenu.Items.Add(lMenuItem);
{$ENDIF}
    end;

(*    lAryPrint[0] := '打印';
    lAryPrint[1] := '打印设置';
    lAryPrint[2] := '显示打印对话框';
    lAryPrint[3] := '自动加载默认打印参数';
    lAryPrint[4] := '-';
    lAryPrint[5] := '保存打印参数到文件';
    lAryPrint[6] := '从文件加载打印参数';
    FWindow.FPopupMenuPrint.Items.Clear;
    for i := Low(lAryPrint) to High(lAryPrint) do
    begin
{$IFDEF USE_TB2k}
      lMenuItem := TTBItem.Create(btnSave);
      lMenuItem.Tag := i;
      lMenuItem.Caption := lAryPrint[i];
      lMenuItem.OnClick := FWindow.ItmPopupPrintClick;
      btnPrint.Add(lMenuItem);
{$ELSE}
      lMenuItem := TMenuItem.Create(FWindow.FPopupMenu);
      lMenuItem.Caption := lAryPrint[i];
      lMenuItem.Tag := i;
      lMenuItem.OnClick := FWindow.ItmPopupPrintClick;
      FWindow.FPopupMenuPrint.Items.Add(lMenuItem);
{$ENDIF}
    end; *)
  end;

begin
  if Dock971 <> nil then Exit;

  if FWindow = nil then
  begin
    FWindow := TRMPreviewForm.Create(nil);
  end;

  _CreateDock;
{$IFNDEF USE_TB2K}
  Dock971.BeginUpdate;
{$ENDIF}
  _CreateToolbar;
{$IFNDEF USE_TB2K}
  Dock971.EndUpdate;
{$ENDIF}
  _CreateMenu;

  Localize;
  //  if IsStanderPreview and (FParentForm <> nil) then
  //  begin
  //    Dock971.Parent := FParentForm;
  //  end;
end;

procedure TRMPreview.SetButtonsVisible;
var
  i: Integer;
  lFound: Boolean;
begin
  if (Dock971 = nil) or (Report = nil) then Exit;

  if FPrepareReportFlag then
  begin
    btnExit.Caption := RMLoadStr(SCancel);
    btnExit.Images := nil;
    btnExit.ImageIndex := -1;
  end
  else
  begin
    btnExit.Caption := '';
    btnExit.ImageIndex := 14;
    btnExit.Images := FWindow.ImageList1;
  end;

  ToolbarStand.Visible := True;
  FBtnShowBorder.Down := Options.DrawBorder;
//  FBtnBackColor.CurrentColor := Options.BorderPen.Color;
  N4.Visible := RMDesignerClass <> nil;
  itmNewPage.Visible := N4.Visible;
  itmDeletePage.Visible := N4.Visible;
  itmEditPage.Visible := N4.Visible;

  btnOpen.Enabled := not FPrepareReportFlag;
  btnSave.Enabled := not FPrepareReportFlag;
  btnSaveToXls.Enabled := not FPrepareReportFlag;
  btnPrint.Enabled := (not FPrepareReportFlag) and (RMPrinters.Count > 2);
  btnPageSetup.Enabled := not FPrepareReportFlag;
  btnDesign.Enabled := not FPrepareReportFlag;
  btnFind.Enabled := not FPrepareReportFlag;
  itmPrint.Enabled := btnPrint.Enabled;
  itmPrintCurrentPage.Enabled := btnPrint.Enabled;
  itmNewPage.Enabled := not FPrepareReportFlag;
  itmDeletePage.Enabled := not FPrepareReportFlag;
  InsertBefore1.Enabled := not FPrepareReportFlag;
  InsertAfter1.Enabled := not FPrepareReportFlag;
  Append1.Enabled := not FPrepareReportFlag;
  itmEditPage.Enabled := not FPrepareReportFlag;

  if not (csDesigning in TRMReport(Report).ComponentState) then
  begin
    cmbZoom.Visible := pbZoom in TRMReport(Report).PreviewButtons;
    if not cmbZoom.Visible then
    begin
      tbLine.Visible := False;
      //tbLine.Free;
    end;

    btnShowOutline.Down := FOutlineTreeView.Visible;
    btnShowOutline.Visible := (FOutLineTreeView.Items.Count > 0);
    btnFind.Visible := pbFind in TRMReport(Report).PreviewButtons;
    ToolbarSep975.Visible := btnFind.Visible;

    btnOpen.Visible := pbLoad in TRMReport(Report).PreviewButtons;
    btnSave.Visible := pbSave in TRMReport(Report).PreviewButtons;
    btnSaveToXLS.Visible := pbSavetoXLS in TRMReport(Report).PreviewButtons;
    btnPrint.Visible := pbPrint in TRMReport(Report).PreviewButtons;
    btnPageSetup.Visible := pbPageSetup in TRMReport(Report).PreviewButtons;
    ToolbarSep973.Visible := btnOpen.Visible or btnSave.Visible or btnPrint.Visible or
      btnPageSetup.Visible or btnSaveToXLS.Visible;

    btnDesign.Visible := pbDesign in TRMReport(Report).PreviewButtons;
    ToolbarSep971.Visible := btnDesign.Visible;

    btnExit.Visible := pbExit in TRMReport(Report).PreviewButtons;
    tbSep1.Visible := btnExit.Visible;

    itmPrint.Visible := btnPrint.Visible;
    itmPrintCurrentPage.Visible := btnPrint.Visible;
    if btnSaveToXLS.Visible then
    begin
      lFound := False;
      for i := 0 to RMFiltersCount - 1 do
      begin
        if TRMExportFilter(RMFilters(i).Filter).IsXLSExport then
        begin
          lFound := True;
          Break;
        end;
      end;

      if not lFound then
        btnSaveToXLS.Visible := False;
    end;

    if not (pbNavigator in TRMReport(Report).PreviewButtons) then
    begin
      Self.btnTop.Visible := False;
      Self.btnPrev.Visible := False;
      Self.edtPageNo.Visible := False;
      Self.btnNext.Visible := False;
      Self.btnLast.Visible := False;
      ToolbarSep972.Visible := False;
    end;
  end;

  case TRMReport(Report).InitialZoom of
    pzPageWidth: btnPageWidth.Down := True;
    pzOnePage: btnOnePage.Down := True;
    pzTwoPages: FZoomMode := mdTwoPages;
  else
    LastScale := FSaveLastScale;
    ZoomMode := FSaveLastScaleMode;
    //    btn100.Down := TRUE;
  end;

  if btnPageWidth.Down then
    cmbZoom.ItemIndex := 7
  else if btnOnePage.Down then
    cmbZoom.ItemIndex := 8
  else if btn100.Down then
    cmbZoom.ItemIndex := 2
  else if FZoomMode = mdTwoPages then
    cmbZoom.ItemIndex := 9
  else
  begin
    cmbZoom.ItemIndex := -1;
    cmbZoom.Text := IntToStr(Round(Zoom)) + '%';
  end;
end;

procedure TRMPreview.CmbZoomKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    try
      Zoom := StrToIntDef(cmbZoom.Text, 100);
      FScrollBox.SetFocus;
    except
      FScrollBox.SetFocus;
    end;
  end;
end;

procedure TRMPreview.CmbZoomClick(Sender: TObject);
begin
  case cmbZoom.ItemIndex of
    0: Zoom := 200;
    1: Zoom := 150;
    2: Zoom := 100;
    3: Zoom := 75;
    4: Zoom := 50;
    5: Zoom := 25;
    6: Zoom := 10;
    7: PageWidth;
    8: OnePage;
    9: TwoPages;
    //    10: FViewer.PrinterZoom;
  end;

  FScrollBox.SetFocus;
end;

procedure TRMPreview.btnTopClick(Sender: TObject);
begin
  First;
end;

procedure TRMPreview.btnPrevClick(Sender: TObject);
begin
  Prev;
end;

procedure TRMPreview.btnNextClick(Sender: TObject);
begin
  Next;
end;

procedure TRMPreview.btnLastClick(Sender: TObject);
begin
  Last;
end;

procedure TRMPreview.btn100Click(Sender: TObject);
begin
  Zoom := 100;
  FSaveLastScale := LastScale;
  FSaveLastScaleMode := ZoomMode;
end;

procedure TRMPreview.btnOnePageClick(Sender: TObject);
begin
  OnePage;
  FSaveLastScale := LastScale;
  FSaveLastScaleMode := ZoomMode;
end;

procedure TRMPreview.btnPageWidthClick(Sender: TObject);
begin
  PageWidth;
  FSaveLastScale := LastScale;
  FSaveLastScaleMode := ZoomMode;
end;

procedure TRMPreview.btnOpenClick(Sender: TObject);
var
  lStr: string;
  lOpenDialog: TOpenDialog;
begin
  if (Report = nil) or (not btnOpen.Visible) then Exit;

  lOpenDialog := TOpenDialog.Create(nil);
  try
    lOpenDialog.InitialDir := FSaveOpenDialogDir;
    lOpenDialog.Filter := RMLoadStr(SRepFile) + ' (*.rmp)|*.rmp';
    if lOpenDialog.Execute then
    begin
      FSaveOpenDialogDir := ExtractFileDir(lOpenDialog.FileName);
      LoadFromFiles(lOpenDialog.Files {FileName});

      lStr := RMLoadStr(SPreview);
      if TRMReport(Report).ReportInfo.Title <> '' then
        lStr := lStr + ' - ' + TRMReport(Report).ReportInfo.Title
      else if lOpenDialog.FileName <> '' then
        lStr := lStr + ' - ' + ExtractFileName(lOpenDialog.FileName)
      else
        lStr := lStr + ' - ' + RMLoadStr(SUntitled);

      Caption := lStr; //ExtractFileName(FileName);
    end;

    btnShowOutline.Down := FOutlineTreeView.Visible;
    btnShowOutline.Visible := (FOutLineTreeView.Items.Count > 0);
  finally
    lOpenDialog.Free;
  end;
end;

procedure TRMPreview.btnSaveClick(Sender: TObject);
var
  i: Integer;
  s: string;
  lSaveDialog: TSaveDialog;
begin
  if (Report = nil) or (not btnSave.Visible) then Exit;

  if Assigned(FOnSaveReportEvent) then
  begin
    FOnSaveReportEvent(Report);
    Exit;
  end;

  lSaveDialog := TSaveDialog.Create(nil);
  try
    s := RMLoadStr(SRepFile) + ' (*.rmp)|*.rmp';
    if TRMReport(Report).CanExport and (pbExport in TRMReport(Report).PreviewButtons) then
    begin
      for i := 0 to RMFiltersCount - 1 do
        s := s + '|' + RMFilters(i).FilterDesc + '|' + RMFilters(i).FilterExt;
    end;

    lSaveDialog.InitialDir := FSaveSaveDialogDir;
    lSaveDialog.Filter := s;
//    lSaveDialog.FilterIndex := FLastExportIndex;
    if lSaveDialog.Execute then
    begin
      FSaveSaveDialogDir := ExtractFileDir(lSaveDialog.FileName);
      FLastExportIndex := lSaveDialog.FilterIndex;
      Update;
      SaveToFile(lSaveDialog.Files[0]{.FileName}, lSaveDialog.FilterIndex);
    end;
  finally
    lSaveDialog.Free;
  end;
end;

procedure TRMPreview.OnmnuExportClick(Sender: TObject);
var
  lSaveDialog: TSaveDialog;
begin
  if (Report = nil) or (not btnSave.Visible) or (not TRMReport(Report).CanExport) then Exit;
  if (Report <> nil) and (not (pbExport in TRMReport(Report).PreviewButtons)) then Exit;

  lSaveDialog := TSaveDialog.Create(nil);
  try
    lSaveDialog.InitialDir := FSaveSaveDialogDir;
    lSaveDialog.Filter := RMFilters(TMenuItem(Sender).Tag).FilterDesc + '|' + RMFilters(TMenuItem(Sender).Tag).FilterExt; ;
    if lSaveDialog.Execute then
    begin
      FSaveSaveDialogDir := ExtractFileDir(lSaveDialog.FileName);
      FLastExportIndex := TMenuItem(Sender).Tag + 2;
      Update;
      SaveToFile(lSaveDialog.FileName, FLastExportIndex);
    end;
  finally
    lSaveDialog.Free;
  end;
end;

procedure TRMPreview.btnPrintClick(Sender: TObject);
begin
  if (Report = nil) or (not btnPrint.Visible) then Exit;

  Print;
end;

procedure TRMPreview.btnFindClick(Sender: TObject);
begin
  if (Report = nil) or (not btnFind.Visible) then Exit;

  Find;
end;

procedure TRMPreview.btnPageSetupClick(Sender: TObject);
begin
  DlgPageSetup;
end;

procedure TRMPreview.btnShowOutlineClick(Sender: TObject);
begin
  ShowOutline(btnShowOutline.Down);
end;

procedure TRMPreview.BtnExitClick(Sender: TObject);
var
  lParentForm: TForm;
begin
  if (FReport <> nil) and FPrepareReportFlag then
  begin
    TRMReport(FReport).Terminated := True;
    Exit;
  end;

  if Assigned(FOnBtnExitClickEvent) then
  begin
    FOnBtnExitClickEvent(Sender);
    Exit;
  end;

  lParentForm := ParentForm;
  if (lParentForm = nil) and (Parent <> nil) and (Parent is TForm) then
    lParentForm := TForm(Parent);

  if lParentForm = nil then Exit;

  if FReport = nil then
  begin
    lParentForm.Close;
  end
  else
  begin
    if TRMReport(FReport).ModalPreview and (not TRMReport(FReport).MDIPreview) then
      lParentForm.ModalResult := mrOk
    else
      lParentForm.Close;
  end;
end;

procedure TRMPreview.btnDesignClick(Sender: TObject);
begin
  if (Report = nil) or (not btnDesign.Visible) then Exit;

  EditPage(CurPage - 1);
//  DesignReport;
end;

procedure TRMPreview.edtPageNoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    try
      CurPage := StrToInt(edtPageNo.Text);
    except;
      edtPageNo.Text := IntToStr(CurPage);
    end;
  end;
end;

procedure TRMPreview.btnSaveToXLSClick(Sender: TObject); // 保存到xls文件
begin
  if (Report = nil) or (not btnSaveToXLS.Visible) then Exit;

  ExportToXlsFile;
end;

procedure TRMPreview.btnShowBorderClick(Sender: TObject);
begin
  Options.DrawBorder := not Options.DrawBorder;
  ReDrawAll(False);
  if Report <> nil then
    TRMReport(Report).PreviewOptions.DrawBorder := Options.DrawBorder;
end;

(* procedure TRMPreview.btnBackColorClick(Sender: TObject);
begin
  Options.BorderPen.Color := FBtnBackColor.CurrentColor;
  ReDrawAll(False);
end; *)

procedure TRMPreview.OnPageChangedEvent(Sender: TObject);
begin
  edtPageNo.Text := IntToStr(CurPage);
end;

procedure TRMPreview.OnStatusChangeEvent(Sender: TObject);
begin
  if Dock971 = nil then Exit;

  case ZoomMode of
    mdPageWidth: btnPageWidth.Down := TRUE;
    mdOnePage: btnOnePage.Down := TRUE;
  else
    if Round(Zoom) = 100 then
      btn100.Down := TRUE
    else
    begin
      btn100.Down := FALSE;
      btnPageWidth.Down := FALSE;
      btnOnePage.Down := FALSE;
    end;
  end;

  if btnPageWidth.Down then
    cmbZoom.ItemIndex := 7
  else if btnOnePage.Down then
    cmbZoom.ItemIndex := 8
  else if btn100.Down then
    cmbZoom.ItemIndex := 2
  else if ZoomMode = mdPrinterZoom then
    cmbZoom.ItemIndex := 10
  else if ZoomMode = mdTwoPages then
    cmbZoom.ItemIndex := 9
  else
    cmbZoom.ItemIndex := cmbZoom.Items.IndexOf(IntToStr(Round(Zoom)) + '%');

  if cmbZoom.ItemIndex >= 0 then
    ProcMenu.Items[cmbZoom.ItemIndex].Checked := True
  else
    ProcMenu.Items[2].Checked := True;

  N4.Visible := CanModify;
  itmNewPage.Visible := N4.Visible;
  itmDeletePage.Visible := N4.Visible;
  itmEditPage.Visible := N4.Visible;

  itmPrint.Enabled := btnPrint.Enabled;
  itmPrintCurrentPage.Enabled := btnPrint.Enabled;
end;

procedure TRMPreview.DoKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Report = nil then Exit;

  if Key = vk_Up then
    VScrollBar.Position := VScrollBar.Position - VScrollBar.SmallChange
  else if Key = vk_Down then
    VScrollBar.Position := VScrollBar.Position + VScrollBar.SmallChange
  else if Key = vk_Left then
    HScrollBar.Position := HScrollBar.Position - HScrollBar.SmallChange
  else if Key = vk_Right then
    HScrollBar.Position := HScrollBar.Position + HScrollBar.SmallChange
  else if Key = vk_Prior then
  begin
    if ssCtrl in Shift then
      btnPrev.Click
    else
      VScrollBar.Position := VScrollBar.Position - VScrollBar.LargeChange;
  end
  else if Key = vk_Next then
  begin
    if ssCtrl in Shift then
      btnNext.Click
    else
      VScrollBar.Position := VScrollBar.Position + VScrollBar.LargeChange;
  end
  else if Key = vk_Escape then
    btnExit.Click
  else if Key = vk_Home then
  begin
    if ssCtrl in Shift then
      VScrollBar.Position := 0
    else
      Exit;
  end
  else if Key = vk_End then
  begin
    if ssCtrl in Shift then
      btnLast.Click
    else
      Exit;
  end
  else if ssCtrl in Shift then
  begin
    if (ssAlt in Shift) and (Chr(Key) = 'P') and btnPrint.Enabled then
      PrintCurrentPage
    else if Chr(Key) = 'O' then btnOpen.Click
    else if Chr(Key) = 'S' then btnSave.Click
    else if (Chr(Key) = 'P') and btnPrint.Enabled then btnPrint.Click
    else if Chr(Key) = 'F' then btnFind.Click;
    //    else if (Chr(Key) = 'E') and itmEditPage.Visible then itmEditPage.Click;
  end
  else if Key = vk_F3 then
  begin
    if FindStr <> '' then
    begin
      if LastFoundPage <> CurPage - 1 then
      begin
        LastFoundPage := CurPage - 1;
        LastFoundObject := 0;
      end;

      FindNext;
    end;
  end
  else
    Exit;

  Key := 0;
end;

procedure TRMPreview.itmScale10Click(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    case Tag of
      1: PageWidth;
      2: OnePage;
      3: TwoPages;
    else
      Zoom := Tag;
    end;
    Checked := True;
  end;

  if btnPageWidth.Down then
    cmbZoom.ItemIndex := 7
  else if btnOnePage.Down then
    cmbZoom.ItemIndex := 8
  else if btn100.Down then
    cmbZoom.ItemIndex := 2
  else if FZoomMode = mdTwoPages then
    cmbZoom.ItemIndex := 9
  else
  begin
    cmbZoom.ItemIndex := -1;
    cmbZoom.Text := IntToStr(Round(Zoom)) + '%';
  end;

  FSaveLastScale := LastScale;
  FSaveLastScaleMode := ZoomMode;
end;

procedure TRMPreview.itmDeletePageClick(Sender: TObject);
begin
  DeletePage(CurPage - 1);
end;

procedure TRMPreview.itmEditPageClick(Sender: TObject);
begin
  EditPage(CurPage - 1);
end;

procedure TRMPreview.itmPrintCurrentPageClick(Sender: TObject);
begin
  PrintCurrentPage;
end;

procedure TRMPreview.Append1Click(Sender: TObject);
begin
  AddPage;
  Last;
end;

procedure TRMPreview.InsertBefore1Click(Sender: TObject);
begin
  InsertPageBefore;
end;

procedure TRMPreview.InsertAfter1Click(Sender: TObject);
begin
  InsertPageAfter;
  CurPage := CurPage + 1;
end;

procedure TRMPreview.SetShowToolbar(Value: Boolean);
begin
  if FShowToolbar = Value then Exit;

  FShowToolbar := Value;
  if FShowToolbar then
  begin
    CreateButtons;
    OnPageChanged := OnPageChangedEvent;
    OnStatusChange := OnStatusChangeEvent;
    PopupMenu := ProcMenu;
    FScrollBox.OnKeyDown := DoKeyDownEvent;
  end
  else
  begin
    if Dock971 <> nil then
    begin
      OnPageChanged := nil;
      OnStatusChange := nil;
      FScrollBox.OnKeyDown := nil;
      PopupMenu := nil;

      FreeAndNil(Dock971);
      FreeAndNil(FWindow);
    end;
  end;
end;

procedure TRMPreview.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(btnOpen, 'Hint', rmRes + 025);
  RMSetStrProp(btnSave, 'Hint', rmRes + 026);
  RMSetStrProp(btnPrint, 'Hint', rmRes + 027);
  RMSetStrProp(btnFind, 'Hint', rmRes + 028);
  RMSetStrProp(btnOnePage, 'Hint', rmRes + 1858);
  RMSetStrProp(btnPageWidth, 'Hint', rmRes + 1857);
  RMSetStrProp(btnTop, 'Hint', rmRes + 32);
  RMSetStrProp(btnPrev, 'Hint', rmRes + 33);
  RMSetStrProp(btnNext, 'Hint', rmRes + 34);
  RMSetStrProp(btnLast, 'Hint', rmRes + 35);
  RMSetStrProp(btnPageSetup, 'Hint', rmRes + 24);
  RMSetStrProp(btnShowOutline, 'Hint', rmRes + 1871);
  RMSetStrProp(btnExit, 'Hint', rmRes + 23);
  RMSetStrProp(cmbZoom, 'Hint', rmRes + 7);
  //  RMSetStrProp(btnAutoScale, 'Hint', rmRes + 8);
  RMSetStrProp(btnSaveToXLS, 'Hint', rmRes + 9);
  RMSetStrProp(btnDesign, 'Hint', rmRes + 10);
  RMSetStrProp(ToolbarStand, 'Caption', rmRes + 11);

  RMSetStrProp(itmPageWidth, 'Caption', rmRes + 020);
  RMSetStrProp(itmOnePage, 'Caption', rmRes + 021);
  RMSetStrProp(itmDoublePage, 'Caption', rmRes + 022);
  RMSetStrProp(itmNewPage, 'Caption', rmRes + 030);
  RMSetStrProp(itmDeletePage, 'Caption', rmRes + 031);
  RMSetStrProp(itmEditPage, 'Caption', rmRes + 029);
  RMSetStrProp(itmPrint, 'Caption', rmRes + 1866);
  RMSetStrProp(itmPrintCurrentPage, 'Caption', rmRes + 376);
  RMSetStrProp(InsertBefore1, 'Caption', rmRes + 1867);
  RMSetStrProp(InsertAfter1, 'Caption', rmRes + 1868);
  RMSetStrProp(Append1, 'Caption', rmRes + 1869);
end;

procedure TRMPreview.LoadIni(aDefault: Boolean);
var
  lOpenDialog: TOpenDialog;
  lFlag1, lFlag2: Boolean;
  lFileName: string;
begin
  if aDefault then
  begin
    TRMReport(FReport).SaveReportOptions.LoadReportSetting(TRMReport(FReport), '', True);
    Exit;
  end;

  lOpenDialog := TOpenDialog.Create(nil);
  lFlag1 := TRMReport(FReport).SaveReportOptions.UseRegistry;
  lFlag2 := TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting;
  lFileName := TRMReport(FReport).SaveReportOptions.IniFileName;
  try
    lOpenDialog.InitialDir := FSaveOpenDialogDir;
    lOpenDialog.Filter := 'Ini Files(*.ini)|*.ini';
    if lOpenDialog.Execute then
    begin
      TRMReport(FReport).SaveReportOptions.UseRegistry := False;
      TRMReport(FReport).SaveReportOptions.IniFileName := lOpenDialog.FileName;
      TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting := True;
      TRMReport(FReport).SaveReportOptions.LoadReportSetting(TRMReport(FReport), '', False);
    end;
  finally
    lOpenDialog.Free;
    TRMReport(FReport).SaveReportOptions.UseRegistry := lFlag1;
    TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting := lFlag2;
    TRMReport(FReport).SaveReportOptions.IniFileName := lFileName;
  end;
end;

procedure TRMPreview.SaveIni(aDefault: Boolean);
var
  lSaveDialog: TSaveDialog;
  lFlag1, lFlag2: Boolean;
  lFileName: string;
begin
  if aDefault then
  begin
    TRMReport(FReport).SaveReportOptions.SaveReportSetting(TRMReport(FReport), '', True);
    Exit;
  end;

  lSaveDialog := TSaveDialog.Create(nil);
  lFlag1 := TRMReport(FReport).SaveReportOptions.UseRegistry;
  lFlag2 := TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting;
  lFileName := TRMReport(FReport).SaveReportOptions.IniFileName;
  try
    lSaveDialog.Options := lSaveDialog.Options + [ofOverwritePrompt];
    lSaveDialog.InitialDir := FSaveOpenDialogDir;
    lSaveDialog.Filter := 'Ini Files(*.ini)|*.ini';
    lSaveDialog.DefaultExt := '.ini';
    if lSaveDialog.Execute then
    begin
      TRMReport(FReport).SaveReportOptions.UseRegistry := False;
      TRMReport(FReport).SaveReportOptions.IniFileName := lSaveDialog.FileName;
      TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting := True;
      TRMReport(FReport).SaveReportOptions.SaveReportSetting(TRMReport(FReport), '', False);
    end;
  finally
    lSaveDialog.Free;
    TRMReport(FReport).SaveReportOptions.UseRegistry := lFlag1;
    TRMReport(FReport).SaveReportOptions.AutoLoadSaveSetting := lFlag2;
    TRMReport(FReport).SaveReportOptions.IniFileName := lFileName;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPreviewForm }

procedure TRMPreviewForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));
end;

procedure TRMPreviewForm.Execute(aDoc: Pointer);
begin
  FDoc := aDoc;
  FViewer.FPrepareReportFlag := False;
  FViewer.ShowToolbar := True;
  FViewer.Connect(aDoc);

  if (FViewer.Dock971 <> nil) and (FViewer.FReport <> nil) then
    FViewer.Dock971.ShowHint := THackReport(FViewer.FReport).ShowPreviewHint;

  FSaveOpenDialogDir := FViewer.InitialDir;
  FSaveSaveDialogDir := FViewer.InitialDir;
  if TRMReport(ADoc).ModalPreview and (not TRMReport(ADoc).MDIPreview) then
    ShowModal
  else
    Show;
end;

procedure TRMPreviewForm.FormCreate(Sender: TObject);
begin
  if FWindow = nil then FWindow := Self;

  FViewer := TRMPreview.Create(Self);
  with FViewer do
  begin
    Parent := Self;
    Align := alClient;
    PopupMenu := ProcMenu;
    ParentForm := Self;
    BorderStyle := bsNone;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;

  FViewer.IsStanderPreview := True;

  FPopupMenu := TRMPopupMenu.Create(Self);
  FPopupMenu.AutoHotkeys := maManual;

  FPopupMenuPrint := TRMPopupMenu.Create(Self);
  FPopupMenuPrint.AutoHotkeys := maManual;
  FPopupMenuPrint.OnPopup := PopupMenuPrintOnPopup;

  Localize;
end;

procedure TRMPreviewForm.FormDestroy(Sender: TObject);
begin
  if FWindow = Self then FWindow := nil;

  FreeAndNil(FViewer);
end;

procedure TRMPreviewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveIni;
  if FormStyle <> fsMDIChild then
  begin
    RMSaveFormPosition('', Self);
  end;
  Action := caFree;
end;

procedure TRMPreviewForm.FormShow(Sender: TObject);
begin
//	FViewer.FScrollBox.SetFocus;
  LoadIni;
  if FormStyle <> fsMDIChild then
  begin
    RMRestoreFormPosition('', Self);
  end;
end;

procedure TRMPreviewForm.SaveIni;
//var
//  lIni: TRegIniFile;
//  Nm: string;
begin
{  lIni := TRegIniFile.Create(RMRegRootKey);
  try
    Nm := 'DefaultPreviewForm';
    lIni.WriteBool(Nm, 'DrawBorder', Viewer.Options.DrawBorder);
    lIni.WriteInteger(Nm, 'DrawPenColor', Viewer.Options.BorderPen.Color);
    lIni.WriteInteger(Nm, 'OutlineWidth', Viewer.FOutLineTreeView.Width);
  finally
    lIni.Free;
  end;
}end;

procedure TRMPreviewForm.LoadIni;
//var
//  lIni: TRegIniFile;
//  Nm: string;
begin
{  lIni := TRegIniFile.Create(RMRegRootKey);
  try
    Nm := 'DefaultPreviewForm';
    Viewer.Options.DrawBorder := lIni.ReadBool(Nm, 'DrawBorder', Viewer.Options.DrawBorder);
    Viewer.Options.BorderPen.Color := lIni.ReadInteger(Nm, 'DrawPenColor', Viewer.Options.BorderPen.Color);
    FViewer.FOutLineTreeView.Width := lIni.ReadInteger(Nm, 'OutlineWidth', 200);
  finally
    lIni.Free;
  end;
}end;

procedure TRMPreviewForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FViewer.DoKeyDownEvent(Sender, Key, Shift);

  Key := 0;
end;

procedure TRMPreviewForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FViewer.FPrepareReportFlag;
end;

procedure TRMPreviewForm.PopupMenuPrintOnPopup(Sender: TObject);
begin
  FPopupMenuPrint.Items[0].Checked := True;
  FPopupMenuPrint.Items[2].Checked := TRMReport(FViewer.FReport).ShowPrintDialog;
  FPopupMenuPrint.Items[3].Checked := TRMReport(FViewer.FReport).SaveReportOptions.AutoLoadSaveSetting;
end;

(* procedure TRMPreviewForm.ItmPopupPrintClick(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    0: FViewer.btnPrint.Click;
    1: FViewer.btnPageSetup.Click;
    2: TRMReport(FViewer.FReport).ShowPrintDialog := not TRMReport(FViewer.FReport).ShowPrintDialog;
    3: TRMReport(FViewer.FReport).SaveReportOptions.AutoLoadSaveSetting := not TRMReport(FViewer.FReport).SaveReportOptions.AutoLoadSaveSetting;
    5: FViewer.SaveIni(False);
    6: FViewer.LoadIni(False);
  end;
end; *)

initialization

finalization
  FreeAndNil(FWindow);

end.

