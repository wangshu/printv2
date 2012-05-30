unit RM_Grid;

{$I RM.INC}

interface

uses Messages, Windows, SysUtils, Classes, Graphics, Menus, Controls, Forms,
  StdCtrls, Mask, Clipbrd, RM_Common, RM_Class;

const
  MaxCustomExtents = MaxListSize;
  MaxShortInt = High(ShortInt);

type
  ERMInvalidGridOperation = class(Exception);

  { Internal grid types }
  TRMGridEx = class;
  TRMCellInfo = class;
  TRMGetExtentsFunc = function(Index: Longint): Integer of object;
  TRMAfterInsertRowEvent = procedure(aGrid: TRMGridEx; aRow: Integer) of object;
  TRMAfterDeleteRowEvent = procedure(aGrid: TRMGridEx; aRow: Integer) of object;
  TRMAfterChangeRowCountEvent = procedure(aGrid: TRMGridEx; aOldCount, aNewCount: Integer) of object;
  TRMBeforeChangeCellEvent = procedure(aGrid: TRMGridEx; aCell: TRMCellInfo) of object;
  TRMFRowHeaderClickEvent = procedure(Sender: TObject; X, Y: Integer) of object;
  TRMDropDownFieldEvent = procedure(aCol, aRow: Integer) of object;
  TRMDropDownFieldClickEvent = procedure(aDropDown: Boolean; X, Y: Integer) of object;

  TRMGridAxisDrawInfo = record
    EffectiveLineWidth: Integer;
    TitleBoundary: Integer; // (行列)标题栏边界(像素单位)
    FixedBoundary: Integer;
    GridBoundary: Integer;
    GridExtent: Integer;
    LastFullVisibleCell: Longint;
    FullVisBoundary: Integer;
    FixedCellCount: Integer;
    FirstGridCell: Integer;
    GridCellCount: Integer;
    GetExtent: TRMGetExtentsFunc;
  end;

  TRMGridDrawInfo = record
    Horz, Vert: TRMGridAxisDrawInfo;
  end;

  TRMGridState = (rmgsNormal, rmgsSelecting, rmgsRowSizing, rmgsColSizing,
    rmgsRowMoving, rmgsColMoving, rmgsRowHeaderDblClick);
  TRMGridMovement = rmgsRowMoving..rmgsColMoving;

  TRMGridOption = (rmgoFixedVertLine, rmgoFixedHorzLine, rmgoVertLine, rmgoHorzLine,
    rmgoRangeSelect, rmgoDrawFocusSelected, rmgoRowSizing, rmgoColSizing, rmgoRowMoving,
    rmgoColMoving, rmgoEditing, rmgoTabs, rmgoRowSelect,
    rmgoAlwaysShowEditor, rmgoThumbTracking);
  TRMGridOptions = set of TRMGridOption;
  TRMGridDrawState = set of (rmgdSelected, rmgdFocused, rmgdFixed, rmgdTitled);
  TRMGridScrollDirection = set of (rmsdLeft, rmsdRight, rmsdUp, rmsdDown);

  TRMSelectCellEvent = procedure(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean) of object;
  TRMDrawCellEvent = procedure(Sender: TObject; ACol, ARow: Longint;
    Rect: TRect; State: TRMGridDrawState) of object;

  { TRMCellInfo }
  TRMCellInfo = class(TRMPersistent)
  private
    FMutilCell: Boolean;
    FFont: TFont;
    FAutoWordBreak: Boolean;
    FHorizAlign: TRMHAlign;
    FVertAlign: TRMVAlign;
    FView: TRMView;
    FParentReport: TRMReport;

    function GetText: WideString;
    procedure SetText(const Value: WideString);
    function GetFillColor: TColor;
    procedure SetFillColor(Value: TColor);
    function GetFont: TFont;
    procedure SetFont(Value: TFont);
    function GetAutoWordBreak: Boolean;
    procedure SetAutowordBreak(Value: Boolean);
    function GetHorizAlign: TRMHAlign;
    procedure SetHorizAlign(Value: TRMHAlign);
    function GetVertAlign: TRMVAlign;
    procedure SetVertAlign(Value: TRMVAlign);
    procedure SetParentReport(Value: TRMReport);
  protected
    FStartCol: Integer;
    FStartRow: Integer;
    FEndCol: Integer;
    FEndRow: Integer;

    function CanEdit: Boolean;
    property ParentReport: TRMReport read FParentReport write SetParentReport;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignFromCell(Source: TRMCellInfo);
    procedure ReCreateView(aObjectType: Byte; const aClassName: string);
  published
    property StartCol: Integer read FStartCol;
    property StartRow: Integer read FStartRow;
    property EndCol: Integer read FEndCol;
    property EndRow: Integer read FendRow;
    property MutilCell: Boolean read FMutilCell write FMutilCell;
    property FillColor: TColor read GetFillColor write SetFillColor;
    property Text: WideString read GetText write SetText;
    property Font: TFont read GetFont write SetFont;
    property AutoWordBreak: Boolean read GetAutoWordBreak write SetAutoWordBreak;
    property HAlign: TRMHAlign read GetHorizAlign write SetHorizAlign;
    property VAlign: TRMVAlign read GetVertAlign write SetVertAlign;
    property View: TRMView read FView;
  end;

  TRMRowCell = class
  private
    FList: TList;
    function GetItem(Index: Integer): TRMCellInfo;
  public
    constructor Create(ARow, AColCount: Integer; AGrid: TRMGridEx);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(ARow, ACol: Integer; AGrid: TRMGridEx);
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TRMCellInfo read GetItem;
  end;

  { TRMCells }
  TRMCells = class
  private
    FList: TList;
    FGrid: TRMGridEx;
    function GetItem(Index: Integer): TRMRowCell;
  protected
  public
    constructor Create(AColCount, ARowCount: Integer; AGrid: TRMGridEx);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(AIndex: Integer);
    procedure Insert(AIndex: Integer);
    procedure Delete(AIndex: Integer);

    property Items[Index: Integer]: TRMRowCell read GetItem;
  end;

  TRMInplaceEdit = class(TCustomMaskEdit)
  private
    FTempText: string;
    FGrid: TRMGridEx;
    FCell: TRMCellInfo;
    FClickTime: Longint;
    procedure InternalMove(const Loc: TRect; Redraw: Boolean);
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMPaste(var Message); message WM_PASTE;
    procedure WMCut(var Message); message WM_CUT;
    procedure WMClear(var Message); message WM_CLEAR;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure ValidateError; override;
    procedure BoundsChanged; virtual;
    procedure UpdateContents; virtual;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Deselect;
    procedure Hide;
    procedure Invalidate; reintroduce;
    procedure Move(const Loc: TRect);
    function PosEqual(const Rect: TRect): Boolean;
    procedure SetFocus; reintroduce;
    procedure UpdateLoc(const Loc: TRect);
    function Visible: Boolean;
    property Grid: TRMGridEx read FGrid write FGrid;
    property Cell: TRMCellInfo read FCell write FCell;
  end;

  { TRMGridEx }
  TRMGridEx = class(TCustomControl)
  private
    FEditorMode: Boolean;
    FSaveLastNameIndex: Integer;
    FAutoDraw: Boolean;
    FAnchor: TPoint;
    FBorderStyle: TBorderStyle;
    FCanEditModify: Boolean;
    FColCount: Longint;
    FColWidths: Pointer;
    FCurrent: TPoint;
    FmmDefaultColWidth: Integer;
    FmmDefaultRowHeight: Integer;
    FFixedCols: Integer;
    FFixedRows: Integer;
    FFixedColor: TColor;
    FGridLineWidth: Integer;
    FOptions: TRMGridOptions;
    FRowCount: Longint;
    FRowHeights: Pointer;
    FScrollBars: TScrollStyle;
    FTopLeft: TPoint;
    FSizingIndex: Longint;
    FSizingPos, FSizingOfs: Integer;
    FMoveIndex, FMovePos: Longint;
    FHitTest: TPoint;
    FColOffset: Integer;
    FDefaultDrawing: Boolean;
    FPressed: Boolean;
    FPressedCell: TPoint;
    FCells: TRMCells;

    FTitleColor: TColor;
    FHighLightColor: TColor;
    FHighLightTextColor: TColor;
    FFocusedTitleColor: TColor;
    FFixedLineColor: TColor;
    FClientLineColor: TColor;
    FInLoadSaveMode: Boolean;
    FAutoCreateName: Boolean;
    FFocusedFillColor: TColor;
    FDrawPicture: Boolean;

    FInplaceEdit: TRMInplaceEdit;
    FInplaceCol, FInplaceRow: Longint;
    FEditUpdate: Integer;

    FGridCanCopyMove: Boolean;
    FGridCanFill: Boolean;
    FAutoUpdate: Boolean;
    FParentReport: TRMReport;
    FParentPage: TRMReportPage;
    FHeaderClick: Boolean;
    //    FAlwaysDrawFocus: Boolean;

    FNewRgn, FOldRgn: HRGN;
    FHaveClip: Integer;
    FOnAfterInsertRow: TRMAfterInsertRowEvent;
    FOnAfterDeleteRow: TRMAfterDeleteRowEvent;
    FOnAfterChangeRowCount: TRMAfterChangeRowCountEvent;

    FOnSelectCell: TRMSelectCellEvent;
    FOnChange: TNotifyEvent;
    FOnRowHeaderClick: TRMFRowHeaderClickEvent;
    FOnRowHeaderDblClick: TNotifyEvent;
    FOnBeginSizingCell: TNotifyEvent;
    FOnBeforeChangeCell: TRMBeforeChangeCellEvent;
    FOnDropDownField: TRMDropDownFieldEvent;
    FOnDropDownFieldClick: TRMDropDownFieldClickEvent;

    procedure ClearGrid;
    procedure ShowFrame(t: TRMView; aCanvas: TCanvas; x, y, x1, y1: Integer; aDrawSubReport: Boolean);
    function CalcCoordFromPoint(X, Y: Integer; const DrawInfo: TRMGridDrawInfo): TPoint;
    procedure CalcDrawInfoXY(var DrawInfo: TRMGridDrawInfo; UseWidth, UseHeight: Integer);
    function CalcMaxTopLeft(const Coord: TPoint; const DrawInfo: TRMGridDrawInfo): TPoint;
    procedure CancelMode;
    procedure ChangeSize(NewColCount, NewRowCount: Longint);
    procedure ClampInView(const Coord: TPoint);
    procedure DrawSizingLine(const DrawInfo: TRMGridDrawInfo);
    procedure DrawMove;
    procedure FocusCell(ACol, ARow: Longint; MoveAnchor: Boolean);
    procedure GridRectToScreenRect(GridRect: TRect; var ScreenRect: TRect; IncludeLine: Boolean);
    procedure Initialize;
    procedure ModifyScrollBar(ScrollBar, ScrollCode, Pos: Cardinal; UseRightToLeft: Boolean);
    procedure MoveAdjust(var CellPos: Longint; FromIndex, ToIndex: Longint);
    procedure MoveAnchor(const NewAnchor: TPoint);
    procedure MoveCurrent(ACol, ARow: Longint; MoveAnchor, Show: Boolean);
    procedure MoveTopLeft(ALeft, ATop: Longint);
    procedure ResizeCol(Index: Longint; OldSize, NewSize: Integer);
    procedure ResizeRow(Index: Longint; OldSize, NewSize: Integer);
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    procedure SelectionMoved(const OldSel: TRect);
    procedure ScrollDataInfo(DX, DY: Integer; var DrawInfo: TRMGridDrawInfo);
    procedure TopLeftMoved(const OldTopLeft: TPoint);
    procedure UpdateScrollPos;
    procedure UpdateScrollRange;
    function GetRowHeights(Index: Longint): Integer;
    procedure SetRowHeights(Index: Longint; Value: Integer);
    function GetmmRowHeights(Index: Longint): Integer;
    procedure SetmmRowHeights(Index: Longint; Value: Integer);
    function GetSelection: TRect;
    function GetVisibleColCount: Integer;
    function GetVisibleRowCount: Integer;
    function IsActiveControl: Boolean;
    procedure SetBorderStyle(Value: TBorderStyle);
    function GetCol: Longint;
    procedure SetCol(Value: Longint);
    procedure SetColCount(Value: Longint);
    function GetColWidths(Index: Longint): Integer;
    procedure SetColWidths(Index: Longint; Value: Integer);
    function GetmmColWidths(Index: Longint): Integer;
    procedure SetmmColWidths(Index: Longint; Value: Integer);
    procedure SetFixedColor(Value: TColor);
    function GetLeftCol: LongInt;
    procedure SetLeftCol(Value: Longint);
    function GetRow: Longint;
    procedure SetRow(Value: Longint);
    procedure SetRowCount(Value: Longint);
    procedure SetSelection(Value: TRect);
    function GetTopRow: Longint;
    procedure SetTopRow(Value: Longint);
    function GetComAdapter: IUnknown;

    procedure CMCancelMode(var Msg: TMessage); message CM_CANCELMODE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMCancelMode(var Msg: TWMCancelMode); message WM_CANCELMODE;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMEraseBkGnd(var Message: TWMCommand); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;

    procedure TrackButton(X, Y: Integer);
    function GetDefaultColWidth: Integer;
    procedure SetDefaultColWidth(Value: Integer);
    function GetDefaultRowHeight: Integer;
    procedure SetDefaultRowHeight(Value: Integer);

    procedure ColCountChange(Value: Integer);
    procedure RowCountChange(Value: Integer);
    procedure SetClipRect(ACanvas: TCanvas; ClipR: TRect);
    procedure RestoreClipRect(ACanvas: TCanvas);
    function CellInMerge(ACol, ARow: Integer): Boolean;
    function GetCell(ACol, ARow: Integer): TRMCellInfo;
    function GetMerges(ACol, ARow: Integer): TRect;
    procedure InitCell(AGrid: TRMGridEx; ACell: TRMCellInfo; ACol, ARow: Integer);
    procedure SetParentReport(Value: TRMReport);

    procedure RestoreCells(aDestRestoreRect: TRect);
    procedure ReadCellFromBuffer(aCell: TRMCellInfo; aStream: TStream; aXOffset, aYOffset: Integer);
    procedure WriteCellToBuffer(aCell: TRMCellInfo; aStream: TStream);
  protected
    FGridState: TRMGridState;
    FSaveCellExtents: Boolean;
    VirtualView: Boolean;
    RightClickRowHeader: Boolean;
    RightClickColHeader: Boolean;
    FComAdapter: IUnknown;

    FCurrentCol, FCurrentRow: Integer;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function CellRect(ACol, ARow: Longint): TRect;
{$IFDEF COMPILER4_UP}
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
{$ENDIF}

    procedure CalcDrawInfo(var DrawInfo: TRMGridDrawInfo);
    procedure CalcFixedInfo(var DrawInfo: TRMGridDrawInfo);
    procedure CalcSizingState(X, Y: Integer; var State: TRMGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer; var FixedInfo: TRMGridDrawInfo); virtual;
    function GetGridWidth: Integer;
    function GetGridHeight: Integer;
    procedure DrawCell(ACol, ARow: Longint; ARect, AClipRect: TRect; AState: TRMGridDrawState);
    procedure MoveColRow(ACol, ARow: Longint; MoveAnchor, Show: Boolean);
    function SelectCell(ACol, ARow: Longint): Boolean; virtual;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); dynamic;
    function Sizing(X, Y: Integer): Boolean;
    procedure ScrollData(DX, DY: Integer);
    procedure InvalidateCol(ACol: Longint);
    procedure InvalidateRow(ARow: Longint);
    procedure TopLeftChanged; dynamic;
    procedure TimedScroll(Direction: TRMGridScrollDirection); dynamic;
    procedure Paint; override;
    procedure ColWidthsChanged; dynamic;
    procedure RowHeightsChanged; dynamic;

    procedure DisableEditUpdate;
    procedure EnableEditUpdate;
    procedure SetEditText(ACol, ARow: Longint; Value: string);
    function CreateEditor: TRMInplaceEdit;
    procedure InvalidateEditor;
    procedure HideEdit;
    procedure HideEditor;
    procedure ShowEditor;
    procedure UpdateText;
    procedure UpdateEdit;
    procedure ShowEditorChar(Ch: Char);
    procedure AdjustSize(Index, Amount: Longint; Rows: Boolean); reintroduce; dynamic;
    function BoxRect(ALeft, ATop, ARight, ABottom: Longint): TRect;
    procedure DoExit; override;
    function CanEditAcceptKey(Key: Char): Boolean; dynamic;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; dynamic;
    function CanEditModify: Boolean; dynamic;
    function CanEditShow: Boolean; virtual;

    procedure CopyCellsToBuffer(aRect: TRect; aStream: TStream); // 从缓冲区中粘贴 Cells 内容
    procedure PasteCellsFromBuffer(aRect: TRect; aStream: TStream);
    procedure GetClipBoardInfo(aStream: TStream; var aStartCell, aSize: TPoint);
    function CanPasteToRect(aDestRect: TRect): Boolean;
    function MergeRectIntersects(aDestRect: TRect): Boolean;
    function CalcMaxRange(aDestRect: TRect): TRect; // 计算新的选择范围

    property GridHeight: Integer read GetGridHeight;
    property GridWidth: Integer read GetGridWidth;
    property HitTest: TPoint read FHitTest;
    property LeftCol: Longint read GetLeftCol write SetLeftCol;
    property TopRow: Longint read GetTopRow write SetTopRow;
    property ParentColor default False;
    property VisibleColCount: Integer read GetVisibleColCount;
    property VisibleRowCount: Integer read GetVisibleRowCount;
    property InLoadSaveMode: Boolean read FInLoadSaveMode write FInLoadSaveMode;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure CreateViewsName;
    function GetCellInfo(ACol, Arow: Integer): TRMCellinfo;
    procedure InvalidateGrid;
    procedure InvalidateRect(ARect: TRect);
    procedure InvalidateCell(ACol, ARow: Longint);
    function MouseCoord(X, Y: Integer): TPoint;
    procedure MergeCell(aFirstCol, aFirstRow, aEndCol, aEndRow: Integer);
    procedure MergeSelection;
    procedure SplitCell(aFirstCol, aFirstRow, aEndCol, aEndRow: Integer);
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
    function GetCellRect(ACell: TRMCellInfo): TRect;
    procedure FreeEditor;

    procedure InsertColumn(aCol: Integer; aCreateName: Boolean);
    procedure InsertRow(aRow: Integer; aCreateName: Boolean);
    procedure DeleteColumn(aCol: Integer; aRefresh: Boolean); virtual;
    procedure DeleteRow(ARow: Integer; aRefresh: Boolean); virtual;
    procedure InsertCellRight(aInsertRect: TRect); // 向右插入一个网格
    procedure InsertCellDown(aInsertRect: TRect); // 向下插入一个网格
    procedure DeleteCellRight(aDeleteRect: TRect); // 向右删除一个网格
    procedure DeleteCellDown(aDeleteRect: TRect); // 向下删除一个网格
    procedure CopyCells(aDestCopyRect: TRect); // 拷贝一个范围内的 Cells 内容到剪贴板中
    procedure CutCells(aDestCutRect: TRect); // 拷贝一个范围内的 Cells 内容到剪贴板中并清除 Cells 内容
    procedure PasteCells(aDestPasteCoord: TPoint); // 从剪贴板中粘贴 Cells 内容到一个范围内

    function CanCut: Boolean;
    function CanCopy: Boolean;
    function CanPaste: Boolean;

    procedure LoadFromFile(aFileName: string);
    procedure SaveToFile(aFileName: string);
    procedure LoadFromStream(aStream: TStream);
    procedure SaveToStream(aStream: TStream);

    property InplaceEditor: TRMInplaceEdit read FInplaceEdit;
    property AutoCreateName: Boolean read FAutoCreateName write FAutoCreateName;
    property HeaderClick: Boolean read FHeaderClick write FHeaderClick;
    property Selection: TRect read GetSelection write SetSelection;
    property Cells[ACol, ARow: Integer]: TRMCellInfo read GetCell;
    property Merges[ACol, ARow: Integer]: TRect read GetMerges;
    property ColWidths[Index: Longint]: Integer read GetColWidths write SetColWidths;
    property mmColWidths[Index: Longint]: Integer read GetmmColWidths write SetmmColWidths;
    property RowHeights[Index: Longint]: Integer read GetRowHeights write SetRowHeights;
    property mmRowHeights[Index: Longint]: Integer read GetmmRowHeights write SetmmRowHeights;
    property Col: Longint read GetCol write SetCol;
    property Row: Longint read GetRow write SetRow;
    property AutoDraw: Boolean read FAutoDraw write FAutoDraw;
    property DrawPicture: Boolean read FDrawPicture write FDrawPicture;
    property ParentReport: TRMReport read FParentReport write SetParentReport;
    property ParentPage: TRMReportPage read FParentPage write FParentPage;
    property ScrollBars: TScrollStyle read FScrollBars write FScrollBars;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;

    property OnAfterInsertRow: TRMAfterInsertRowEvent read FOnAfterInsertRow write FOnAfterInsertRow;
    property OnAfterDeleteRow: TRMAfterDeleteRowEvent read FOnAfterDeleteRow write FOnAfterDeleteRow;
    property OnAfterChangeRowCount: TRMAfterChangeRowCountEvent read FOnAfterChangeRowCount write FOnAfterChangeRowCount;
    property OnBeginSizingCell: TNotifyEvent read FOnBeginSizingCell write FOnBeginSizingCell;
    property OnBeforeChangeCell: TRMBeforeChangeCellEvent read FOnBeforeChangeCell write FOnBeforeChangeCell;

    property OnDropDownField: TRMDropDownFieldEvent read FOnDropDownField write FOnDropDownField;
    property OnDropDownFieldClick: TRMDropDownFieldClickEvent read FOnDropDownFieldClick write FOnDropDownFieldClick;
    property CurrentCol: Integer read FCurrentCol write FCurrentCol;
    property CurrentRow: Integer read FCurrentRow write FCurrentRow;
    property ComAdapter: IUnknown read GetComAdapter write FComAdapter;
  published
    property FixedCols: Integer read FFixedCols write FFixedCols;
    property FixedRows: Integer read FFixedRows write FFixedRows;
    property ColCount: Longint read FColCount write SetColCount;
    property RowCount: Longint read FRowCount write SetRowCount;
    property DefaultDrawing: Boolean read FDefaultDrawing;
    property Options: TRMGridOptions read FOptions;
    property DefaultColWidth: Integer read GetDefaultColWidth write SetDefaultColWidth;
    property DefaultRowHeight: Integer read GetDefaultRowHeight write SetDefaultRowHeight;
    property FixedColor: TColor read FFixedColor write SetFixedColor;
    property Color default clWindow;
    property TabStop default True;
    property PopupMenu;
    property Font;

    property OnSelectCell: TRMSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnRowHeaderClick: TRMFRowHeaderClickEvent read FOnRowHeaderClick write FOnRowHeaderClick;
    property OnRowHeaderDblClick: TNotifyEvent read FOnRowHeaderDblClick write FOnRowHeaderDblClick;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnEnter;
  end;

var
  CF_RMGridCopyFormat: Word;

implementation

uses Math, Consts, RM_Utils, RM_Const, RM_Const1;

type
  THackView = class(TRMView);

  THackMemoView = class(TRMCustomMemoView);

  THackPage = class(TRMCustomPage);

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TRMCellInfo }

constructor TRMCellInfo.Create;
begin
  inherited Create;

  FFont := TFont.Create;
  FView := RMCreateObject(rmgtMemo, '');
  //  FView.TopFrame.Visible := True;
  //  FView.LeftFrame.Visible := True;
  //  FView.BottomFrame.Visible := True;
  //  FView.RightFrame.Visible := True;
end;

destructor TRMCellInfo.Destroy;
begin
  FFont.Free;
  FView.Free;
  inherited Destroy;
end;

function TRMCellInfo.CanEdit: Boolean;
begin
  Result := FView is TRMCustomMemoView;
end;

procedure TRMCellInfo.Assign(Source: TPersistent);
begin
  if Source is TRMCellInfo then
  begin
    FStartCol := TRMCellInfo(Source).StartCol;
    FStartRow := TRMCellInfo(Source).StartRow;
    FEndCol := TRMCellInfo(Source).EndCol;
    FEndRow := TRMCellInfo(Source).EndRow;
    FMutilCell := TRMCellInfo(Source).MutilCell;
    FFont.Assign(TRMCellInfo(Source).Font);
    FAutoWordBreak := TRMCellInfo(Source).FAutoWordBreak;
    FHorizAlign := TRMCellInfo(Source).FHorizAlign;
    FVertAlign := TRMCellInfo(Source).FVertAlign;
    ReCreateView(TRMCellInfo(Source).FView.ObjectType, TRMCellInfo(Source).FView.ClassName);
    FView.Assign(TRMCellInfo(Source).FView);
    ParentReport := TRMCellInfo(Source).ParentReport;
  end;
end;

procedure TRMCellInfo.AssignFromCell(Source: TRMCellInfo);
begin
  FStartCol := Source.StartCol;
  FStartRow := Source.StartRow;
  FEndCol := Source.EndCol;
  FEndRow := Source.EndRow;
  FMutilCell := Source.MutilCell;
end;

procedure TRMCellInfo.ReCreateView(aObjectType: Byte; const aClassName: string);
var
  t: TRMView;
begin
  if (FView.ObjectType <> rmgtAddIn) and (FView.ObjectType = aObjectType) then Exit;
  if (FView.ObjectType = rmgtAddIn) and (AnsiCompareText(FView.ClassName, aClassName) = 0) then Exit;

  t := RMCreateObject(aObjectType, aClassName);
  t.LeftFrame.Assign(FView.LeftFrame);
  t.RightFrame.Assign(FView.RightFrame);
  t.TopFrame.Assign(FView.TopFrame);
  t.BottomFrame.Assign(View.BottomFrame);
  t.FillColor := FView.FillColor;
  t.Restrictions := FView.Restrictions;

  if (t is TRMCustomMemoView) and (FView is TRMCustomMemoView) then
  begin
    TRMCustomMemoView(t).Font.Assign(TRMCustomMemoView(FView).Font);
    TRMCustomMemoView(t).GapLeft := TRMCustomMemoView(FView).GapLeft;
    TRMCustomMemoView(t).GapTop := TRMCustomMemoView(FView).GapTop;
    TRMCustomMemoView(t).LineSpacing := TRMCustomMemoView(FView).LineSpacing;
    TRMCustomMemoView(t).CharacterSpacing := TRMCustomMemoView(FView).CharacterSpacing;
    THackView(t).FFlags := THackView(FView).FFlags;
    TRMCustomMemoView(t).HAlign := TRMCustomMemoView(FView).HAlign;
    TRMCustomMemoView(t).VAlign := TRMCustomMemoView(FView).VAlign;
    THackMemoView(t).FDisplayFormat := TRMCustomMemoView(FView).DisplayFormat;
    THackMemoView(t).FormatFlag := THackMemoView(FView).FormatFlag;
    t.Memo.Assign(FView.Memo);
  end;

  FView.Free;
  FView := t;
  ParentReport := ParentReport;
end;

function TRMCellInfo.GetText: WideString;
var
  i: Integer;
begin
  if View is TRMCustomMemoView then
  begin
    Result := '';
    for i := 0 to FView.Memo.Count - 1 do
    begin
      if i > 0 then
        Result := Result + #13#10;
      Result := Result + FView.Memo[i];
    end;
  end
  else
    Result := THackView(View).GetViewCommon;
end;

procedure TRMCellInfo.SetText(const Value: WideString);
begin
  if View is TRMCustomMemoView then
    TRMCustomMemoView(View).Memo.Text := Value;
end;

function TRMCellInfo.GetFillColor: TColor;
begin
  Result := FView.FillColor;
end;

procedure TRMCellInfo.SetFillColor(Value: TColor);
begin
  FView.FillColor := Value;
end;

function TRMCellInfo.GetFont: TFont;
begin
  if View is TRMCustomMemoView then
    Result := TRMCustomMemoView(View).Font
  else
    Result := FFont;
end;

procedure TRMCellInfo.SetFont(Value: TFont);
begin
  if View is TRMCustomMemoView then
    TRMCustomMemoView(View).Font.Assign(Value);
  FFont.Assign(Value);
end;

function TRMCellInfo.GetAutoWordBreak: Boolean;
begin
  if View is TRMCustomMemoView then
    Result := THackMemoView(View).Wordwrap
  else
    Result := FAutowordBreak;
end;

procedure TRMCellInfo.SetAutowordBreak(Value: Boolean);
begin
  FAutowordBreak := Value;
  if View is TRMCustomMemoView then
    THackMemoView(View).Wordwrap := Value;
end;

function TRMCellInfo.GetHorizAlign: TRMHAlign;
begin
  if View is TRMCustomMemoView then
    Result := TRMCustomMemoView(View).HAlign
  else
    Result := FHorizAlign;
end;

procedure TRMCellInfo.SetHorizAlign(Value: TRMHAlign);
begin
  FHorizAlign := Value;
  if View is TRMCustomMemoView then
    TRMCustomMemoView(View).HAlign := Value;
end;

function TRMCellInfo.GetVertAlign: TRMVAlign;
begin
  if View is TRMCustomMemoView then
    Result := TRMCustomMemoView(View).VAlign
  else
    Result := FVertAlign;
end;

procedure TRMCellInfo.SetVertAlign(Value: TRMVAlign);
begin
  FVertAlign := Value;
  if View is TRMCustomMemoView then
    TRMCustomMemoView(View).VAlign := Value;
end;

procedure TRMCellInfo.SetParentReport(Value: TRMReport);
begin
  FParentReport := Value;
  if FView <> nil then
    THackView(FView).ParentReport := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMRowCell.Create(ARow, AColCount: Integer; AGrid: TRMGridEx);
var
  i: Integer;
  liCellInfo: TRMCellInfo;
begin
  inherited Create;

  FList := TList.Create;
  for i := 0 to AColCount - 1 do
  begin
    liCellInfo := TRMCellInfo.Create;
    AGrid.InitCell(AGrid, liCellInfo, i, ARow);
    FList.Add(liCellInfo);
    liCellInfo.ParentReport := aGrid.ParentReport;
  end;
end;

destructor TRMRowCell.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TRMRowCell.Clear;
begin
  while FList.Count > 0 do
  begin
    TRMCellInfo(FList[0]).Free;
    FList.Delete(0);
  end;
end;

procedure TRMRowCell.Add(ARow, ACol: Integer; AGrid: TRMGridEx);
var
  liCellInfo: TRMCellInfo;
begin
  liCellInfo := TRMCellInfo.Create;
  AGrid.InitCell(AGrid, liCellInfo, ACol, ARow);
  FList.Add(liCellInfo);
  liCellInfo.ParentReport := aGrid.ParentReport;
end;

procedure TRMRowCell.Delete(Index: Integer);
begin
  TRMCellInfo(FList[Index]).Free;
  FList.Delete(Index);
end;

function TRMRowCell.GetItem(Index: Integer): TRMCellInfo;
begin
  Result := TRMCellInfo(FList[Index]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMCells.Create(AColCount, ARowCount: Integer; AGrid: TRMGridEx);
var
  i: Integer;
  liRowCell: TRMRowCell;
begin
  inherited Create;
  FList := TList.Create;
  FGrid := AGrid;
  for i := 0 to ARowCount - 1 do
  begin
    liRowCell := TRMRowCell.Create(i, AColCount, AGrid);
    FList.Add(liRowCell);
  end;
end;

destructor TRMCells.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TRMCells.Clear;
begin
  while FList.Count > 0 do
  begin
    TRMRowCell(FList[0]).Free;
    FList.Delete(0);
  end;
end;

function TRMCells.GetItem(Index: Integer): TRMRowCell;
begin
  Result := TRMRowCell(FList[Index]);
end;

procedure TRMCells.Insert(AIndex: Integer);
var
  liRowCell: TRMRowCell;
begin
  liRowCell := TRMRowCell.Create(AIndex, FGrid.ColCount, FGrid);
  FList.Insert(AIndex, liRowCell);
end;

procedure TRMCells.Add(AIndex: Integer);
var
  liRowCell: TRMRowCell;
begin
  liRowCell := TRMRowCell.Create(AIndex, FGrid.ColCount, FGrid);
  FList.Add(liRowCell);
end;

procedure TRMCells.Delete(AIndex: Integer);
begin
  TRMRowCell(FList[AIndex]).Free;
  FList.Delete(AIndex);
end;

type
  TSelection = record
    StartPos, EndPos: Integer;
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TRMInplaceEdit }

constructor TRMInplaceEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentCtl3D := False;
  Ctl3D := False;
  TabStop := False;
  BorderStyle := bsNone;
  DoubleBuffered := False;
end;

destructor TRMInplaceEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TRMInplaceEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style and not ES_AUTOHSCROLL or ES_MULTILINE;
end;

procedure TRMInplaceEdit.CMShowingChanged(var Message: TMessage);
begin
end;

procedure TRMInplaceEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if rmgoTabs in Grid.Options then
    Message.Result := Message.Result or DLGC_WANTTAB;
end;

procedure TRMInplaceEdit.WMClear(var Message);
begin
  if not EditCanModify then Exit;
  inherited;
end;

procedure TRMInplaceEdit.WMCut(var Message);
begin
  if not EditCanModify then Exit;
  inherited;
end;

procedure TRMInplaceEdit.DblClick;
begin
  Grid.DblClick;
end;

function TRMInplaceEdit.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result := Grid.DoMouseWheel(Shift, WheelDelta, MousePos);
end;

function TRMInplaceEdit.EditCanModify: Boolean;
begin
  Result := Grid.CanEditModify;
end;

procedure TRMInplaceEdit.ValidateError;
begin
end;

procedure TRMInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);

  procedure SendToParent;
  begin
    Grid.KeyDown(Key, Shift);
    Key := 0;
  end;

  procedure ParentEvent;
  var
    GridKeyDown: TKeyEvent;
  begin
    GridKeyDown := Grid.OnKeyDown;
    if Assigned(GridKeyDown) then GridKeyDown(Grid, Key, Shift);
  end;

  function Ctrl: Boolean;
  begin
    Result := ssCtrl in Shift;
  end;

  function Selection: TSelection;
  begin
    SendMessage(Handle, EM_GETSEL, Longint(@Result.StartPos), Longint(@Result.EndPos));
  end;

  function RightSide: Boolean;
  begin
    with Selection do
      Result := ((StartPos = 0) or (EndPos = StartPos)) and
        (EndPos = GetTextLen);
  end;

  function LeftSide: Boolean;
  begin
    with Selection do
      Result := (StartPos = 0) and ((EndPos = 0) or (EndPos = GetTextLen));
  end;

begin
  case Key of
    VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT:
      SendToParent;
    VK_ESCAPE:
      begin
        Text := FTempText;
        SendToParent;
      end;
    VK_INSERT:
      if Shift = [] then SendToParent
      else if (Shift = [ssShift]) and not Grid.CanEditModify then Key := 0;
    VK_LEFT: if not Ctrl and LeftSide then SendToParent;
    VK_RIGHT: if not Ctrl and RightSide then SendToParent;
    VK_HOME: if not Ctrl and LeftSide then
      begin
        Key := VK_LEFT;
        SendToParent;
      end;
    VK_END: if not Ctrl and RightSide then
      begin
        Key := VK_RIGHT;
        SendToParent;
      end;
    VK_F2:
      begin
        ParentEvent;
        if Key = VK_F2 then
        begin
          Deselect;
          Exit;
        end;
      end;
    VK_TAB: if not (ssAlt in Shift) then SendToParent;
  end;
  if (Key = VK_DELETE) and not Grid.CanEditModify then Key := 0;
  if Key <> 0 then
  begin
    ParentEvent;
    inherited KeyDown(Key, Shift);
  end;
end;

procedure TRMInplaceEdit.KeyPress(var Key: Char);
var
  Selection: TSelection;
begin
  Grid.KeyPress(Key);
  if (Key in [#32..#255]) and not Grid.CanEditAcceptKey(Key) then
  begin
    Key := #0;
    MessageBeep(0);
  end;

  case Key of
    #9, #27: Key := #0;
    #13:
      begin
        SendMessage(Handle, EM_GETSEL, Longint(@Selection.StartPos), Longint(@Selection.EndPos));
        if (Selection.StartPos = 0) and (Selection.EndPos = GetTextLen) then
          Deselect else
          SelectAll;
        Key := #0;
      end;
    ^H, ^V, ^X, #32..#255:
      if not Grid.CanEditModify then Key := #0;
  end;

  if not FCell.CanEdit then
  begin
    inherited;
    Exit;
  end;
end;

procedure TRMInplaceEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  Grid.KeyUp(Key, Shift);
end;

procedure TRMInplaceEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      begin
        if (GetParentForm(Self) = nil) or GetParentForm(Self).SetFocusedControl(Grid) then
          Dispatch(Message);

        Exit;
      end;
    WM_LBUTTONDOWN:
      begin
        if UINT(GetMessageTime - FClickTime) < GetDoubleClickTime then
          Message.Msg := WM_LBUTTONDBLCLK;
        FClickTime := 0;
      end;
  end;

  inherited WndProc(Message);
end;

procedure TRMInplaceEdit.WMPaste(var Message);
begin
  if not EditCanModify then Exit;

  if not FCell.CanEdit then
  begin
    inherited;
    Exit;
  end;

  inherited;
end;

procedure TRMInplaceEdit.Deselect;
begin
  SendMessage(Handle, EM_SETSEL, $7FFFFFFF, Longint($FFFFFFFF));
end;

procedure TRMInplaceEdit.Invalidate;
var
  Cur: TRect;
begin
  ValidateRect(Handle, nil);
  InvalidateRect(Handle, nil, True);
  Windows.GetClientRect(Handle, Cur);
  MapWindowPoints(Handle, Grid.Handle, Cur, 2);
  ValidateRect(Grid.Handle, @Cur);
  InvalidateRect(Grid.Handle, @Cur, False);
end;

procedure TRMInplaceEdit.Hide;
begin
  if HandleAllocated and IsWindowVisible(Handle) then
  begin
    Invalidate;
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or SWP_NOZORDER or
      SWP_NOREDRAW);
    if Focused then Windows.SetFocus(Grid.Handle);
  end;
end;

function TRMInplaceEdit.PosEqual(const Rect: TRect): Boolean;
var
  Cur: TRect;
begin
  GetWindowRect(Handle, Cur);
  MapWindowPoints(HWND_DESKTOP, Grid.Handle, Cur, 2);
  Result := EqualRect(Rect, Cur);
end;

procedure TRMInplaceEdit.InternalMove(const Loc: TRect; Redraw: Boolean);
begin
  if IsRectEmpty(Loc) then Hide
  else
  begin
    CreateHandle;
    Redraw := Redraw or not IsWindowVisible(Handle);
    Invalidate;
    with Loc do
      SetWindowPos(Handle, HWND_TOP, Left, Top, Right - Left, Bottom - Top,
        SWP_SHOWWINDOW or SWP_NOREDRAW);
    BoundsChanged;
    if Redraw then Invalidate;
    if Grid.Focused then
      Windows.SetFocus(Handle);
  end;
end;

procedure TRMInplaceEdit.BoundsChanged;
var
  R: TRect;
begin
  R := Rect(2, 2, Width - 2, Height);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@R));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TRMInplaceEdit.UpdateLoc(const Loc: TRect);
begin
  InternalMove(Loc, False);
end;

function TRMInplaceEdit.Visible: Boolean;
begin
  Result := IsWindowVisible(Handle);
end;

procedure TRMInplaceEdit.Move(const Loc: TRect);
begin
  InternalMove(Loc, True);
end;

procedure TRMInplaceEdit.SetFocus;
begin
  if IsWindowVisible(Handle) then
    Windows.SetFocus(Handle);
end;

procedure TRMInplaceEdit.UpdateContents;
begin
  Text := '';
  FCell := Grid.Cells[Grid.FInplaceCol, Grid.FInplaceRow];
  //  EditMask := Grid.GetEditMask(Grid.Col, Grid.Row);
  Text := FCell.Text;
  MaxLength := 0;

  FTempText := Text;
  //Color := FCell.FillColor;
  Font.Assign(FCell.Font);
end;

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxCustomExtents] of Integer;

function ColTitle(Index: Integer): string;
var
  Hi, Lo: Integer;
begin
  Result := '';
  if (Index < 0) or (Index > 255) then
    Exit;
  Hi := Index div 26;
  Lo := Index mod 26;
  if Index <= 25 then
    Result := Chr(Ord('A') + Lo)
  else
    Result := Chr(Ord('A') + Hi - 1) + Chr(Ord('A') + Lo);
end;

procedure InvalidOp(const id: string);
begin
  raise ERMInvalidGridOperation.Create(id);
end;

function GridRect(Coord1, Coord2: TPoint): TRect;
begin
  with Result do
  begin
    Left := Coord2.X;
    if Coord1.X < Coord2.X then
      Left := Coord1.X;
    Right := Coord1.X;
    if Coord1.X < Coord2.X then
      Right := Coord2.X;
    Top := Coord2.Y;
    if Coord1.Y < Coord2.Y then
      Top := Coord1.Y;
    Bottom := Coord1.Y;
    if Coord1.Y < Coord2.Y then
      Bottom := Coord2.Y;
  end;
end;

procedure Restrict(var Coord: TPoint; MinX, MinY, MaxX, MaxY: Longint);
begin
  with Coord do
  begin
    if X > MaxX then
      X := MaxX
    else if X < MinX then
      X := MinX;
    if Y > MaxY then
      Y := MaxY
    else if Y < MinY then
      Y := MinY;
  end;
end;

function PointInGridRect(Col, Row: Longint; const Rect: TRect): Boolean;
begin
  Result := (Col >= Rect.Left) and (Col <= Rect.Right) and (Row >= Rect.Top)
    and (Row <= Rect.Bottom);
end;

function GridRectInterSects(GridRect1, GridRect2: TRect): Boolean; // GridRect2 in GridRect1
var
  i, j: Integer;
begin
  Result := True;
  for i := GridRect1.Left to GridRect1.Right do
  begin
    for j := GridRect1.Top to GridRect1.Bottom do
    begin
      if PointInGridRect(i, j, GridRect2) then
        Exit;
    end;
  end;
  Result := False;
end;

type
  TXorRects = array[0..3] of TRect;

procedure XorRects(const R1, R2: TRect; var XorRects: TXorRects);
var
  Intersect, Union: TRect;

  function PtInRect(X, Y: Integer; const Rect: TRect): Boolean;
  begin
    with Rect do
      Result := (X >= Left) and (X <= Right) and (Y >= Top) and
        (Y <= Bottom);
  end;

  function Includes(const P1: TPoint; var P2: TPoint): Boolean;
  begin
    with P1 do
    begin
      Result := PtInRect(X, Y, R1) or PtInRect(X, Y, R2);
      if Result then
        P2 := P1;
    end;
  end;

  function Build(var R: TRect; const P1, P2, P3: TPoint): Boolean;
  begin
    Build := True;
    with R do
      if Includes(P1, TopLeft) then
      begin
        if not Includes(P3, BottomRight) then
          BottomRight := P2;
      end
      else if Includes(P2, TopLeft) then
        BottomRight := P3
      else
        Build := False;
  end;

begin
  FillChar(XorRects, SizeOf(XorRects), 0);
  if not Bool(IntersectRect(Intersect, R1, R2)) then
  begin
    { Don't intersect so its simple }
    XorRects[0] := R1;
    XorRects[1] := R2;
  end
  else
  begin
    UnionRect(Union, R1, R2);
    if Build(XorRects[0],
      Point(Union.Left, Union.Top),
      Point(Union.Left, Intersect.Top),
      Point(Union.Left, Intersect.Bottom)) then
      XorRects[0].Right := Intersect.Left;
    if Build(XorRects[1],
      Point(Intersect.Left, Union.Top),
      Point(Intersect.Right, Union.Top),
      Point(Union.Right, Union.Top)) then
      XorRects[1].Bottom := Intersect.Top;
    if Build(XorRects[2],
      Point(Union.Right, Intersect.Top),
      Point(Union.Right, Intersect.Bottom),
      Point(Union.Right, Union.Bottom)) then
      XorRects[2].Left := Intersect.Right;
    if Build(XorRects[3],
      Point(Union.Left, Union.Bottom),
      Point(Intersect.Left, Union.Bottom),
      Point(Intersect.Right, Union.Bottom)) then
      XorRects[3].Top := Intersect.Bottom;
  end;
end;

procedure ModifyExtents(var Extents: Pointer; Index, Amount: Longint;
  Default: Integer);
var
  LongSize, OldSize: LongInt;
  NewSize: Integer;
  I: Integer;
begin
  if Amount <> 0 then
  begin
    if not Assigned(Extents) then
      OldSize := 0
    else
      OldSize := PIntArray(Extents)^[0];
    if (Index < 0) or (OldSize < Index) then
      InvalidOp(SIndexOutOfRange);
    LongSize := OldSize + Amount;
    if LongSize < 0 then
      InvalidOp(STooManyDeleted)
    else if LongSize >= MaxListSize - 1 then
      InvalidOp(SGridTooLarge);
    NewSize := Cardinal(LongSize);
    if NewSize > 0 then
      Inc(NewSize);
    ReallocMem(Extents, NewSize * SizeOf(Integer));
    if Assigned(Extents) then
    begin
      I := Index + 1;
      while I < NewSize do
      begin
        PIntArray(Extents)^[I] := Default;
        Inc(I);
      end;
      PIntArray(Extents)^[0] := NewSize - 1;
    end;
  end;
end;

procedure UpdateExtents(var Extents: Pointer; NewSize: Longint; Default: Integer);
var
  OldSize: Integer;
begin
  OldSize := 0;
  if Assigned(Extents) then
    OldSize := PIntArray(Extents)^[0];
  ModifyExtents(Extents, OldSize, NewSize - OldSize, Default);
end;

procedure MoveExtent(var Extents: Pointer; FromIndex, ToIndex: Longint);
var
  Extent: Integer;
begin
  if Assigned(Extents) then
  begin
    Extent := PIntArray(Extents)^[FromIndex];
    if FromIndex < ToIndex then
      Move(PIntArray(Extents)^[FromIndex + 1], PIntArray(Extents)^[FromIndex],
        (ToIndex - FromIndex) * SizeOf(Integer))
    else if FromIndex > ToIndex then
      Move(PIntArray(Extents)^[ToIndex], PIntArray(Extents)^[ToIndex + 1],
        (FromIndex - ToIndex) * SizeOf(Integer));
    PIntArray(Extents)^[ToIndex] := Extent;
  end;
end;

{ Private. LongMulDiv multiplys the first two arguments and then
  divides by the third.  This is used so that real number
  (floating point) arithmetic is not necessary.  This routine saves
  the possible 64-bit value in a temp before doing the divide.  Does
  not do error checking like divide by zero.  Also assumes that the
  result is in the 32-bit range (Actually 31-bit, since this algorithm
  is for unsigned). }

function LongMulDiv(Mult1, Mult2, Div1: Longint): Longint; stdcall;
  external 'kernel32.dll' name 'MulDiv';

{ TRMGridEx }

constructor TRMGridEx.Create(AOwner: TComponent);
const
  GridStyle = [csCaptureMouse, csOpaque, csDoubleClicks];
begin
  inherited Create(AOwner);
  if NewStyleControls then
    ControlStyle := GridStyle
  else
    ControlStyle := GridStyle + [csFramed];

  FCurrentCol := -1;
  FCurrentRow := -1;
  FDrawPicture := False;
  FEditorMode := False;
  FInplaceEdit := nil;
  FAutoCreateName := True;
  FSaveLastNameIndex := 1;
  FInLoadSaveMode := False;
  FCanEditModify := True;
  FColCount := 10;
  FRowCount := 6;
  FFixedCols := 1;
  FFixedRows := 1;
  FGridLineWidth := 1;
  FmmDefaultColWidth := RMToMMThousandths(64, rmutScreenPixels);
  FmmDefaultRowHeight := RMToMMThousandths(24, rmutScreenPixels);
  FOptions := [rmgoFixedVertLine, rmgoFixedHorzLine, rmgoVertLine, rmgoHorzLine,
    rmgoRangeSelect, rmgoRowSizing, rmgoColSizing, rmgoDrawFocusSelected,
    rmgoEditing];
  FScrollBars := ssBoth;
  FBorderStyle := bsSingle;
  FSaveCellExtents := True;
  ParentColor := False;
  TabStop := True;
  FDefaultDrawing := True;
  FAutoDraw := True;

  Color := clWindow;
  FFixedColor := clBtnFace;
  FTitleColor := clBtnFace;
  FHighLightColor := clBlack;
  FHighLightTextColor := clWhite;
  FFocusedTitleColor := clBlack;
  FFixedLineColor := clBlack;
  FClientLineColor := clSilver;
  FFocusedFillColor := $00E7D7CE; //clSkyBlue;

  FAutoUpdate := True;
  FGridCanCopyMove := False;
  FGridCanFill := False;

  if RMIsChineseGB then
    Font.Name := '宋体'
  else
    Font.Name := 'Arial';
  Font.Charset := StrToInt(RMLoadStr(SCharset));
  Font.Size := 10;

  FCells := TRMCells.Create(FColCount, FRowCount, Self);
  SetBounds(Left, Top, FColCount * DefaultColWidth, FRowCount * DefaultRowHeight);
  Initialize;
end;

destructor TRMGridEx.Destroy;
begin
  FreeAndNil(FInplaceEdit);
  FAutoDraw := False;
  FCells.Free;
  inherited Destroy;
  FreeMem(FColWidths);
  FreeMem(FRowHeights);
end;

procedure TRMGridEx.FreeEditor;
begin
  FEditorMode := False;
  FreeAndNil(FInplaceEdit);
end;

procedure TRMGridEx.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_TABSTOP;
    if FScrollBars in [ssVertical, ssBoth] then
      Style := Style or WS_VSCROLL;
    if FScrollBars in [ssHorizontal, ssBoth] then
      Style := Style or WS_HSCROLL;
    WindowClass.style := CS_DBLCLKS;
    if FBorderStyle = bsSingle then
    begin
      if NewStyleControls and Ctl3D then
      begin
        Style := Style and not WS_BORDER;
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
      end
      else
        Style := Style or WS_BORDER;
    end;
  end;
end;

procedure TRMGridEx.ClearGrid;
begin
  FInLoadSaveMode := True;
  try
    Initialize;
    FCells.Free;
    FreeMem(FColWidths);
    FreeMem(FRowHeights);
    FColWidths := nil;
    FRowHeights := nil;

    FColCount := 2;
    FRowCount := 2;
    FCells := TRMCells.Create(FColCount, FRowCount, Self);
    SetBounds(Left, Top, FColCount * DefaultColWidth, FRowCount * DefaultRowHeight);
    ColWidths[0] := 100;
    Initialize;
  finally
    FInLoadSaveMode := False;
  end;
end;

procedure TRMGridEx.Assign(Source: TPersistent);
var
  i, liCol, liRow: Integer;
begin
  if not (Source is TRMGridEx) then Exit;

  ColCount := TRMGridEx(Source).ColCount;
  RowCount := TRMGridEx(Source).RowCount;
  FixedColor := TRMGridEx(Source).FixedColor;
  Font.Assign(TRMGridEx(Source).Font);
  DefaultRowHeight := TRMGridEx(Source).DefaultRowHeight;
  DefaultColWidth := TRMGridEx(Source).DefaultColWidth;
  for i := 1 to TRMGridEx(Source).ColCount - 1 do
    ColWidths[i] := TRMGridEx(Source).ColWidths[i];

  for i := 1 to TRMGridEx(Source).RowCount - 1 do
    RowHeights[i] := TRMGridEx(Source).RowHeights[i];

  for liCol := 1 to TRMGridEx(Source).ColCount - 1 do
  begin
    for liRow := 1 to TRMGridEx(Source).RowCount - 1 do
    begin
      Cells[liCol, liRow].Assign(TRMGridEx(Source).Cells[liCol, liRow]);
    end;
  end;
end;

procedure TRMGridEx.CreateViewsName;
var
  i, j: Integer;
  sl: TStringList;
  lPage: TRMCustomPage;
  lCell: TRMCellInfo;
  str, str1: string;
  lPageObjects: TList;

  procedure _GetObjects;
  var
    i, j: Integer;
  begin
    if sl <> nil then Exit;

    sl := TStringList.Create;
    sl.BeginUpdate;
    for i := 0 to ParentReport.Pages.Count - 1 do
    begin
      lPage := ParentReport.Pages[i];
      lPageObjects := lPage.PageObjects;
      for j := 0 to lPageObjects.Count - 1 do
      begin
        if TRMView(lPageObjects[j]).Name <> '' then
          sl.Add(UpperCase(TRMView(lPageObjects[j]).Name));
        THackPage(lPage).AddChildView(sl, True);
      end;
    end;

    sl.Sort;
    sl.Sorted := True;
    sl.EndUpdate;
  end;

  procedure _CreateName;
  var
    lIndex: Integer;
  begin
    _GetObjects;
    str1 := THackView(lCell.View).BaseName;
    while True do
    begin
      str := str1 + IntToStr(FSaveLastNameIndex);
      if not sl.Find(UpperCase(str), lIndex) then
      begin
        lCell.View.Name := str;

        Inc(FSaveLastNameIndex);
        sl.Add(UpperCase(str));
        Break;
      end;
      Inc(FSaveLastNameIndex);
    end;
  end;

begin
  if not AutoCreateName then Exit;

  sl := nil;
  try
    for i := 1 to RowCount - 1 do
    begin
      j := 1;
      while j < ColCount do
      begin
        lCell := Cells[j, i];
        if (lCell.StartRow = i) and (lCell.View.Name = '') then
        begin
          _CreateName;
        end;
        j := lCell.EndCol + 1;
      end;
    end;
  finally
    sl.Free;
  end;
end;

function TRMGridEx.GetCellInfo(ACol, Arow: Integer): TRMCellinfo;
var
  liCell: TRMCellInfo;
begin
  liCell := Cells[ACol, ARow];
  Result := Cells[liCell.StartCol, liCell.StartRow];
end;

function TRMGridEx.BoxRect(ALeft, ATop, ARight, ABottom: Longint): TRect;
var
  GridRect: TRect;
begin
  GridRect.Left := ALeft;
  GridRect.Right := ARight;
  GridRect.Top := ATop;
  GridRect.Bottom := ABottom;
  GridRectToScreenRect(GridRect, Result, False);
end;

function TRMGridEx.CellRect(ACol, ARow: Longint): TRect;
begin
  Result := BoxRect(ACol, ARow, ACol, ARow);
end;

function TRMGridEx.IsActiveControl: Boolean;
var
  H: Hwnd;
  ParentForm: TCustomForm;
begin
  Result := False;
  ParentForm := GetParentForm(Self);
  if Assigned(ParentForm) then
  begin
    if (ParentForm.ActiveControl = Self) then
      Result := True
  end
  else
  begin
    H := GetFocus;
    while IsWindow(H) and (Result = False) do
    begin
      if H = WindowHandle then
        Result := True
      else
        H := GetParent(H);
    end;
  end;
end;

function TRMGridEx.MouseCoord(X, Y: Integer): TPoint;
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  Result := CalcCoordFromPoint(X, Y, DrawInfo);
  if Result.X < 0 then
    Result.Y := -1
  else if Result.Y < 0 then
    Result.X := -1;
end;

procedure TRMGridEx.MoveColRow(ACol, ARow: Longint; MoveAnchor,
  Show: Boolean);
begin
  MoveCurrent(ACol, ARow, MoveAnchor, Show);
end;

function TRMGridEx.SelectCell(ACol, ARow: Longint): Boolean;
begin
  Result := True;
  if Assigned(FOnSelectCell) then
    FOnSelectCell(Self, ACol, ARow, Result);
end;

procedure TRMGridEx.SizeChanged(OldColCount, OldRowCount: Longint);
begin
end;

function TRMGridEx.Sizing(X, Y: Integer): Boolean;
var
  DrawInfo: TRMGridDrawInfo;
  State: TRMGridState;
  Index: Longint;
  Pos, Ofs: Integer;
begin
  State := FGridState;
  if State = rmgsNormal then
  begin
    CalcDrawInfo(DrawInfo);
    CalcSizingState(X, Y, State, Index, Pos, Ofs, DrawInfo);
  end;
  Result := State <> rmgsNormal;
end;

procedure TRMGridEx.TopLeftChanged;
begin
  if FEditorMode and (FInplaceEdit <> nil) then
    FInplaceEdit.UpdateLoc(CellRect(Col, Row));
end;

procedure FillDWord(var Dest; Count, Value: Integer); register;
asm
  XCHG  EDX, ECX
  PUSH  EDI
  MOV   EDI, EAX
  MOV   EAX, EDX
  REP   STOSD
  POP   EDI
end;

{ StackAlloc allocates a 'small' block of memory from the stack by
  decrementing SP.  This provides the allocation speed of a local variable,
  but the runtime size flexibility of heap allocated memory.  }

function StackAlloc(Size: Integer): Pointer; register;
asm
  POP   ECX          { return address }
  MOV   EDX, ESP
  ADD   EAX, 3
  AND   EAX, not 3   // round up to keep ESP dword aligned
  CMP   EAX, 4092
  JLE   @@2
@@1:
  SUB   ESP, 4092
  PUSH  EAX          { make sure we touch guard page, to grow stack }
  SUB   EAX, 4096
  JNS   @@1
  ADD   EAX, 4096
@@2:
  SUB   ESP, EAX
  MOV   EAX, ESP     { function result = low memory address of block }
  PUSH  EDX          { save original SP, for cleanup }
  MOV   EDX, ESP
  SUB   EDX, 4
  PUSH  EDX          { save current SP, for sanity check  (sp = [sp]) }
  PUSH  ECX          { return to caller }
end;

procedure StackFree(P: Pointer); register;
asm
  POP   ECX                     { return address }
  MOV   EDX, DWORD PTR [ESP]
  SUB   EAX, 8
  CMP   EDX, ESP                { sanity check #1 (SP = [SP]) }
  JNE   @@1
  CMP   EDX, EAX                { sanity check #2 (P = this stack block) }
  JNE   @@1
  MOV   ESP, DWORD PTR [ESP+4]  { restore previous SP  }
@@1:
  PUSH  ECX                     { return to caller }
end;

procedure TRMGridEx.SetClipRect(ACanvas: TCanvas; ClipR: TRect);
begin
  FOldRgn := 0;
  FOldRgn := CreateRectRgn(0, 0, 0, 0);
  FHaveClip := GetClipRgn(ACanvas.Handle, FOldRgn);

  FNewRgn := CreateRectRgnIndirect(ClipR);
  SelectClipRgn(ACanvas.Handle, FNewRgn);
  DeleteObject(FNewRgn);
end;

procedure TRMGridEx.RestoreClipRect(ACanvas: TCanvas);
begin
  if FHaveClip > 0 then
    SelectClipRgn(ACanvas.Handle, FOldRgn)
  else
    SelectClipRgn(ACanvas.Handle, 0);
  DeleteObject(FOldRgn);
end;

procedure TRMGridEx.ShowFrame(t: TRMView; aCanvas: TCanvas; x, y, x1, y1: Integer;
  aDrawSubReport: Boolean);

  procedure _Line1(x, y, x1, y1: Integer);
  begin
    aCanvas.MoveTo(x, y);
    aCanvas.LineTo(x1, y1);
  end;

  procedure _DrawFrame(const x, y, x1, y1: Integer; b: TRMFrameLine; aFlag: Byte);
  begin
    aCanvas.Pen.Width := Round(b.Width);
    aCanvas.Pen.Style := b.Style;
    aCanvas.Pen.Color := b.Color;
    aCanvas.MoveTo(x, y);
    aCanvas.LineTo(x1, y1);
  end;

begin
  if t.LeftFrame.Visible then
    Inc(x, Round(t.LeftFrame.Width) div 2 - 1);
  if t.TopFrame.Visible then
    Inc(y, Round(t.TopFrame.Width) div 2 - 1);
  if t.RightFrame.Visible then
    Dec(x1, Round(t.RightFrame.Width) div 2);
  if t.BottomFrame.Visible then
    Dec(y1, Round(t.BottomFrame.Width) div 2);

  if t.LeftFrame.Visible then
    _DrawFrame(x, y, x, y1, t.LeftFrame, 1);
  if t.TopFrame.Visible then
    _DrawFrame(x, y, x1, y, t.TopFrame, 2);
  if t.RightFrame.Visible then
    _DrawFrame(x1, y, x1, y1, t.RightFrame, 3);
  if t.BottomFrame.Visible then
    _DrawFrame(x, y1, x1, y1, t.BottomFrame, 4);

  if t.LeftRightFrame > 0 then
  begin
    aCanvas.Brush.Style := bsSolid;
    aCanvas.Pen.Style := psSolid;
    aCanvas.Pen.Width := 1;
    aCanvas.Pen.Color := t.LeftFrame.Color;
    case t.LeftRightFrame of
      1: _Line1(x, y, x1, y1);
      2:
        begin
          _Line1(x, y, x1 div 2, y1);
          _Line1(x, y, x1, y1 div 2);
        end;
      3:
        begin
          _Line1(x, y, x1, y1);
          _Line1(x, y, x1 div 2, y1);
          _Line1(x, y, x1, y1 div 2);
        end;
      4: _Line1(x, y1, x1, y);
      5:
        begin
          _Line1(x, y1 div 2, x1, y);
          _Line1(x1 div 2, y1, x1, y);
        end;
      6:
        begin
          _Line1(x, y1, x1, y);
          _Line1(x, y1 div 2, x1, y);
          _Line1(x1 div 2, y1, x1, y);
        end;
    end;
  end;

  if (t is TRMSubReportView) and aDrawSubReport then
  begin
    aCanvas.Pen.Width := 1;
    aCanvas.Pen.Color := clBlack;
    aCanvas.Pen.Style := psSolid;
    aCanvas.Brush.Color := clSilver; //clWhite;
    aCanvas.Rectangle(x, y, x1 + 1, y1 + 1);
    aCanvas.Brush.Style := bsClear;
  end;

end;

procedure TRMGridEx.DrawCell(ACol, ARow: Longint; ARect, AClipRect: TRect; AState: TRMGridDrawState);
var
  lSaveRect: TRect;
  lTextAlignMode: UINT;
  lTextToDraw: PWideChar;
  lTestRect: TRect; // 边框范围与文本试输出范围
  lTestWidth, lTestHeight: Integer; // 实际宽高
  lDrawWidth, lDrawHeight: Integer; // 绘画区宽高
  lView: TRMView;
  lBmp1, lBmp2: TBitmap;

  procedure _DrawAsPicture;
  var
    lSaveOffsetLeft, lSaveOffsetTop: Integer;
    lSave1, lSave2, lSave3, lSave4: Boolean;
    lSaveFillColor: TColor;
    lBitmap: TBitmap;
  begin
    lBitmap := TBitmap.Create;
    lSaveOffsetLeft := THackView(lView).OffsetLeft;
    lSaveOffsetTop := THackView(lView).OffsetTop;
    lSave1 := THackView(lView).LeftFrame.Visible;
    lSave2 := THackView(lView).TopFrame.Visible;
    lSave3 := THackView(lView).RightFrame.Visible;
    lSave4 := THackView(lView).BottomFrame.Visible;
    lSaveFillColor := THackView(lView).FillColor;
    try
      lBitmap.Width := aRect.Right - aRect.Left + 1;
      lBitmap.Height := aRect.Bottom - aRect.Top + 1;
      if rmgdSelected in AState then
        THackView(lView).FillColor := FFocusedFillColor;

      THackView(lView).DrawFocusedFrame := False;
      THackView(lView).LeftFrame.Visible := False;
      THackView(lView).TopFrame.Visible := False;
      THackView(lView).RightFrame.Visible := False;
      THackView(lView).BottomFrame.Visible := False;
      THackView(lView).OffsetLeft := 0;
      THackView(lView).OffsetTop := 0;
      lView.SetspBounds(0, 0, lBitmap.Width - 1, lBitmap.Height - 1);
      lView.Draw(lBitmap.Canvas);
      lView.SetspBounds(lView.spLeft, lView.spTop, lView.spWidth, lView.spHeight);

      Canvas.Draw(aRect.Left, aRect.Top, lBitmap);
      if THackView(lView).HaveEventProp then
        Canvas.Draw(aRect.Left + 1, aRect.Top + 1, lBmp1);

      if (lView is TRMCustomMemoView) and (TRMCustomMemoView(lView).Highlight.Condition <> '') then
        Canvas.Draw(aRect.Left + 1 + 8, aRect.Top + 1, lBmp2);
    finally
      THackView(lView).OffsetLeft := lSaveOffsetLeft;
      THackView(lView).OffsetTop := lSaveOffsetTop;
      THackView(lView).LeftFrame.Visible := lSave1;
      THackView(lView).TopFrame.Visible := lSave2;
      THackView(lView).RightFrame.Visible := lSave3;
      THackView(lView).BottomFrame.Visible := lSave4;
      THackView(lView).FillColor := lSaveFillColor;
      THackView(lView).DrawFocusedFrame := True;
      lBitmap.Free;
    end;
  end;

  procedure _CalcTestRect;
  var
    CalcMode: Cardinal;
  begin
    lTestRect := ARect;
    with lTestRect do
    begin
      Dec(Right, Left);
      Dec(Bottom, Top);
      Left := 0;
      Top := 0;
    end;
    CalcMode := DT_CALCRECT;
    if Cells[ACol, ARow].AutoWordBreak then
      CalcMode := CalcMode or DT_WORDBREAK;

    DrawTextW(Canvas.Handle, lTextToDraw, -1, lTestRect, CalcMode);
    lTestWidth := lTestRect.Right - lTestRect.Left;
    lTestHeight := lTestRect.Bottom - lTestRect.Top;
    lDrawWidth := ARect.Right - ARect.Left;
    lDrawHeight := ARect.Bottom - ARect.Top;
    lTestRect.Left := (lDrawWidth - lTestWidth) div 2;
    lTestRect.Right := lTestRect.Left + lTestWidth;
    lTestRect.Top := (lDrawHeight - lTestHeight) div 2;
    lTestRect.Bottom := lTestRect.Top + lTestHeight;
  end;

  procedure _DrawDropDownField;
  var
    lBmp: TBitmap;
  begin
    lBmp := TBitmap.Create;
    try
      lBmp.LoadFromResourceName(hInstance, 'RM_DropDownField');
      Canvas.Draw(lSaveRect.Right - 16, lSaveRect.Top, lBmp);
    finally
      lBmp.Free;
    end;
  end;

begin
  if (aCol > 0) and (aRow > 0) then
  begin
    ShowFrame(Cells[ACol, ARow].View, Canvas, aRect.Left, aRect.Top,
      aRect.Right, aRect.Bottom, (not (rmgdSelected in AState)));
  end;

  lBmp1 := TBitmap.Create;
  lBmp2 := TBitmap.Create;
  try
    lBmp1.LoadFromResourceName(hInstance, 'RM_SCRIPT');
    lBmp2.LoadFromResourceName(hInstance, 'RM_HIGHLIGHT');

    if (ARow = 0) and (ACol <> 0) then
    begin
      Canvas.Brush.Style := bsClear;
    //    Canvas.Font.Name := 'MS Sans Serif';
    //    Canvas.Font.Size := 8;
    //    Canvas.Font.Style := [];
      Canvas.Font.Color := clWindowText;
      DrawText(Canvas.Handle, PChar(ColTitle(ACol - 1)), -1, ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE)
    end
    else if (ACol = 0) and (ARow <> 0) then
    begin
      Canvas.Brush.Style := bsClear;
    //    Canvas.Font.Name := 'MS Sans Serif';
    //    Canvas.Font.Size := 8;
    //    Canvas.Font.Style := [];
      Canvas.Font.Color := clWindowText;
      aRect.Right := aRect.Right - 2;
      lTestRect := Rect(ARect.Left + 2, ARect.Top + 2, ARect.Right, ARect.Bottom);

      DrawText(Canvas.Handle, PChar(IntToStr(aRow)), -1, lTestRect, DT_LEFT or DT_TOP or DT_SINGLELINE);
      DrawTextW(Canvas.Handle, PWideChar(Cells[0, aRow].Text), -1, aRect, DT_RIGHT {DT_CENTER} or DT_VCENTER or DT_SINGLELINE)
      //    DrawText(Canvas.Handle, PChar(IntToStr(ARow)), -1, ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE)
    end
    else if (ARow <> 0) and (ACol <> 0) then
    begin
      InflateRect(ARect, -1, -1);
      IntersectClipRect(Canvas.Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      lView := Cells[aCol, aRow].FView;
      lSaveRect := ARect;
      if (lView <> nil) {and THackView(lView).DrawAsPicture} and FDrawPicture then
      begin
        _DrawAsPicture;
        if (FCurrentCol = aCol) and (FCurrentRow = aRow) then
          _DrawDropDownField;
      end
      else
      begin
        if (lView <> nil) and THackView(lView).HaveEventProp then
          Canvas.Draw(aRect.Left + 1, aRect.Top + 1, lBmp1);

        with Cells[ACol, ARow] do
        begin
          if Text <> '' then
          begin
            lTextToDraw := PWideChar(Text);
            Canvas.Font.Assign(Font);
            if rmgdSelected in AState then //and ((ACol <> FCurrent.X) or (ARow <> FCurrent.Y)) then
              Canvas.Font.Color := FHighLightTextColor;

            _CalcTestRect;
            case HAlign of
              rmHLeft: lTextAlignMode := DT_TOP or DT_LEFT;
              rmHRight: lTextAlignMode := DT_TOP or DT_RIGHT;
            else
              lTextAlignMode := DT_CENTER;
            end;

            case VAlign of
              rmVBottom: ARect.Top := ARect.Bottom - lTestHeight;
              rmVCenter: Inc(ARect.Top, lTestRect.Top);
            end;

            if AutoWordBreak then
              lTextAlignMode := lTextAlignMode or DT_WORDBREAK;

            Windows.DrawTextW(Canvas.Handle, lTextToDraw, -1, ARect, lTextAlignMode);
          end;
        end;

        if (FCurrentCol = aCol) and (FCurrentRow = aRow) then
          _DrawDropDownField;
      end;

      RestoreClipRect(Canvas);
      SetClipRect(Canvas, AClipRect);
    end;

  //  if Assigned(FOnDrawCell) then
  //  begin
  //    FOnDrawCell(Self, ACol, ARow, ARect, AState);
  //  end;
  finally
    lBmp1.Free;
    lBmp2.Free;
  end;
end;

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

procedure TRMGridEx.Paint;
var
  DrawInfo: TRMGridDrawInfo;
  Sel: TRect;
  UpdateRect: TRect;
  DrawRect, ClipRect, IRect: TRect;
  PointsList: PIntArray;
  StrokeList: PIntArray;
  MaxStroke: Integer;
  FrameFlags1, FrameFlags2: DWORD;
  MaxHorzExtent, MaxVertExtent: Integer;
  MaxHorzCell, MaxVertCell: Integer;
  MinHorzCell, MinVertCell: Integer;

  procedure _DrawLines(DoHorz, DoVert: Boolean; StartCol, StartRow, EndCol, EndRow: Longint;
    const CellBounds: array of Integer; OnColor, OffColor: TColor);
  const
    FlatPenStyle = PS_Geometric or PS_Solid or PS_EndCap_Flat or PS_Join_Miter;

    procedure DrawAxisLines(const AxisInfo: TRMGridAxisDrawInfo;
      MajorIndex: Integer; UseOnColor: Boolean);
    var
      LogBrush: TLOGBRUSH;
      Cell, Index: Integer;
      Points: PIntArray;
      StartMajor, StopMajor, StartMinor, StopMinor: Integer;
      MayHaveMerge: Boolean;
      TopIndex: Integer;
      MergePoint: TPoint;

      function FindHorzMerge(ARow, StartIndex: Integer): TPoint;
      var
        I: Integer;
        liCell: TRMCellInfo;
      begin
        Result.x := -1;
        Result.y := -1;
        for i := StartIndex to EndCol do
        begin
          liCell := Cells[i, ARow];
          if CellInMerge(i, ARow) and (ARow <> liCell.EndRow) then
          begin
            Result.x := liCell.StartCol;
            Result.y := liCell.EndCol;
            Exit;
          end;
        end;
      end;

      function FindVertMerge(ACol, StartIndex: Integer): TPoint;
      var
        i: Integer;
        liCell: TRMCellInfo;
      begin
        Result.x := -1;
        Result.y := -1;
        for i := StartIndex to EndRow do
        begin
          liCell := Cells[ACol, i];
          if CellInMerge(ACol, i) and (ACol <> liCell.EndCol) then
          begin
            Result.x := liCell.StartRow;
            Result.y := liCell.EndRow;
            Exit;
          end;
        end;
      end;

    begin
      with Canvas, AxisInfo do
      begin
        Pen.Style := psSolid;
        Pen.Mode := pmCopy;
        if EffectiveLineWidth <> 0 then
        begin
          Pen.Width := FGridLineWidth;
          if UseOnColor then
            Pen.Color := OnColor
          else
            Pen.Color := OffColor;
          if Pen.Width > 1 then
          begin
            LogBrush.lbStyle := BS_Solid;
            LogBrush.lbColor := Pen.Color;
            LogBrush.lbHatch := 0;
            Pen.Handle := ExtCreatePen(FlatPenStyle, Pen.Width, LogBrush, 0, nil);
          end;
          if MajorIndex = 0 then
            Cell := StartCol // 画竖线
          else
            Cell := StartRow; // 画横线
          // 第一根线的位置
          StartMajor := CellBounds[MajorIndex] + EffectiveLineWidth shr 1 +
            GetExtent(Cell);
          // 最后一根线的位置
          StopMajor := CellBounds[2 + MajorIndex] + EffectiveLineWidth;
          // 画线起点
          StartMinor := CellBounds[MajorIndex xor 1];
          // 画线终点
          StopMinor := CellBounds[2 + (MajorIndex xor 1)];
          MayHaveMerge := False;
          // 计算是否可能存在合并区域
          if ((StartMinor > 0) and (StartMajor > 0) or
            (StartMinor > 0) and (StartMajor > 0)) then
            MayHaveMerge := True;
          Points := PointsList;
          Index := 0;
          repeat
            if ((MajorIndex = 0) and (ColWidths[Cell] >= 0)) or
              ((MajorIndex = 1) and (RowHeights[Cell] >= 0)) then
            begin
              // 画线起点
              Points^[Index + MajorIndex] := StartMajor; // MoveTo
              Points^[Index + (MajorIndex xor 1)] := StartMinor;
              Inc(Index, 2);
              // 如果可能存在合并区域
              if MayHaveMerge then
              begin
                if MajorIndex = 0 then // 画竖线
                begin
                  TopIndex := StartRow;
                  while TopIndex <= EndRow do
                  begin
                    MergePoint := FindVertMerge(Cell, TopIndex);
                    if MergePoint.x > 0 then //Have Merge
                    begin
                      Points^[Index + MajorIndex] := StartMajor; // LineTo
                      Points^[Index + (MajorIndex xor 1)] := CellRect(Cell, MergePoint.x).Top;
                      Inc(Index, 2);
                      Points^[Index + MajorIndex] := StartMajor; // MoveTo
                      Points^[Index + (MajorIndex xor 1)] := CellRect(Cell, MergePoint.y).Bottom;
                      Inc(Index, 2);
                      TopIndex := MergePoint.y + 1;
                    end
                    else
                      Inc(TopIndex);
                  end;
                end
                else // 画横线
                begin
                  TopIndex := StartCol;
                  while TopIndex <= EndCol do
                  begin
                    MergePoint := FindHorzMerge(Cell, TopIndex);
                    if MergePoint.x > 0 then
                    begin
                      Points^[Index + MajorIndex] := StartMajor; // LineTo
                      Points^[Index + (MajorIndex xor 1)] := CellRect(MergePoint.x, Cell).Left;
                      Inc(Index, 2);
                      Points^[Index + MajorIndex] := StartMajor; // MoveTo
                      Points^[Index + (MajorIndex xor 1)] := CellRect(MergePoint.y, Cell).Right;
                      Inc(Index, 2);
                      TopIndex := MergePoint.y + 1;
                    end
                    else
                      Inc(TopIndex);
                  end;
                end;
              end;
              // 画线终点
              Points^[Index + MajorIndex] := StartMajor;
              Points^[Index + (MajorIndex xor 1)] := StopMinor;
              Inc(Index, 2);
            end;
            Inc(Cell);
            Inc(StartMajor, GetExtent(Cell) + EffectiveLineWidth);
          until StartMajor > StopMajor;

          PolyPolyLine(Canvas.Handle, Points^, StrokeList^, Index shr 2);
        end;
      end;
    end;
  begin
    if (CellBounds[0] = CellBounds[2]) or (CellBounds[1] = CellBounds[3]) then
      Exit;

    if not DoHorz then
    begin
      DrawAxisLines(DrawInfo.Vert, 1, DoHorz); // 画水平线
      DrawAxisLines(DrawInfo.Horz, 0, DoVert); // 画竖直线
    end
    else
    begin
      DrawAxisLines(DrawInfo.Horz, 0, DoVert); // 画竖直线
      DrawAxisLines(DrawInfo.Vert, 1, DoHorz); // 画水平线
    end;
  end;

  procedure DrawCells(DrawRegion: Integer; StartCol, StartRow, EndCol, EndRow: Integer;
    Color: TColor; IncludeDrawState: TRMGridDrawState);
  var
    CurCol, CurRow: Longint;
    Where, TempRect: TRect;
    DrawState: TRMGridDrawState;
    Focused: Boolean;
    bDown: Boolean;
    liCell: TRMCellInfo;

    procedure CalcRegion;
    var
      i: Integer;
    begin
      with DrawInfo do
      begin
        case DrawRegion of
          6: // 固定区交叉区
            begin
              ClipRect := Rect(0, 0, Horz.FixedBoundary, Vert.FixedBoundary);
              DrawRect := ClipRect;
            end;
          7: // 顶部固定区
            begin
              ClipRect := Rect(Horz.FixedBoundary, 0, MaxHorzExtent, Vert.FixedBoundary);
              DrawRect := ClipRect;
              Dec(DrawRect.Left, FColOffset);
              for i := StartCol to LeftCol - 1 do
                Dec(DrawRect.Left, Horz.GetExtent(i) + Horz.EffectiveLineWidth);
            end;
          8: // 左部固定区
            begin
              ClipRect := Rect(0, Vert.FixedBoundary, Horz.FixedBoundary, MaxVertExtent);
              DrawRect := ClipRect;
              for i := StartRow to TopRow - 1 do
                Dec(DrawRect.Top, Vert.GetExtent(i) + Vert.EffectiveLineWidth);
            end;
          9: // 活动区域
            begin
              ClipRect := Rect(Horz.FixedBoundary, Vert.FixedBoundary, MaxHorzExtent, MaxVertExtent);
              DrawRect := ClipRect;
              Dec(DrawRect.Left, FColOffset);
              for i := StartCol to LeftCol - 1 do
                Dec(DrawRect.Left, Horz.GetExtent(i) + Horz.EffectiveLineWidth);
              for i := StartRow to TopRow - 1 do
                Dec(DrawRect.Top, Vert.GetExtent(i) + Vert.EffectiveLineWidth);
            end;
        end;
      end;
    end;

    function MergedExtent(AAxisDrawInfo: TRMGridAxisDrawInfo; StartIndex, EndIndex: Integer): Integer;
    var
      i: Integer;
    begin
      Result := 0;
      with AAxisDrawInfo do
      begin
        for i := StartIndex to EndIndex do
          Inc(Result, GetExtent(i) + EffectiveLineWidth);
      end;
      Dec(Result, AAxisDrawInfo.EffectiveLineWidth);
    end;

  begin
    CalcRegion; // 计算剪裁范围和绘画范围
    SetClipRect(Canvas, ClipRect);
    CurRow := StartRow;
    Where.Top := DrawRect.Top;
    while (Where.Top < DrawRect.Bottom) and (CurRow < RowCount) do
    begin
      CurCol := StartCol;
      Where.Left := DrawRect.Left;
      while (Where.Left < DrawRect.Right) and (CurCol <= EndCol) do
      begin
        liCell := Cells[CurCol, CurRow];
        Where.Right := Where.Left + MergedExtent(DrawInfo.Horz, CurCol, liCell.EndCol); //ColWidths[CurCol];
        Where.Bottom := Where.Top + MergedExtent(DrawInfo.Vert, CurRow, liCell.EndRow); //RowHeights[CurRow];
        if (Where.Right > Where.Left) and (Where.Bottom > Where.Top) and
          (CurCol = liCell.StartCol) and (CurRow = liCell.StartRow) and
          InterSectRect(IRect, Where, ClipRect) then
        begin
          DrawState := IncludeDrawState;
          Focused := IsActiveControl;
          if Focused and (CurRow = Row) and (CurCol = Col) then
            Include(DrawState, rmgdFocused);
          if GridRectInterSects(Rect(liCell.StartCol, liCell.StartRow, liCell.EndCol, liCell.EndRow), Sel) then
            Include(DrawState, rmgdSelected);

          if True then
            //if (not (rmgdFocused in DrawState)) or
            //  (not (rmgoEditing in Options)) or
            //  (not FEditorMode) or
            //  (csDesigning in ComponentState) then
          begin
            if DefaultDrawing or (csDesigning in ComponentState) then
            begin
              with Canvas do
              begin
                Font := Self.Font;
                if (rmgdSelected in DrawState) and (not (rmgdFocused in DrawState) or
                  ([rmgoDrawFocusSelected] * Options <> [])) then
                begin
                  Brush.Color := FFocusedFillColor;
                  Font.Color := clHighlightText;
                end
                else
                begin
                  if Cells[CurCol, CurRow].FillColor = clNone then
                    Brush.Color := Color
                  else
                    Brush.Color := Cells[CurCol, CurRow].FillColor;
                end;
                FillRect(Where);
              end;
            end;
            TempRect := Where;

            DrawCell(CurCol, CurRow, TempRect, ClipRect, DrawState);

            if DefaultDrawing and Ctl3D then
            begin
              if (rmgdFixed in DrawState) and ((FrameFlags1 or FrameFlags2) <> 0) then //draw 3D frame
              begin
                bDown := FPressed and (FPressedCell.X = CurCol) and (FPressedCell.Y = CurRow);
                begin
                  if bDown then
                  begin
                    with tempRect do
                      BitBlt(Canvas.Handle, Left, Top, Right - Left, Bottom - Top, 0, 0, 0, DSTINVERT);
                  end
                  else
                  begin
                    tempRect.Right := tempRect.Right + 1;
                    tempRect.Bottom := tempRect.Bottom + 1;
                    DrawEdge(Canvas.Handle, TempRect, BDR_RAISEDINNER, BF_RECT);
                  end;
                end;
              end;
            end;
          end // 焦点
          else if DefaultDrawing and not (csDesigning in ComponentState) and
            (rmgdFocused in DrawState) then
          begin
            //            DrawFocusRect(Canvas.Handle, Where)
          end;
        end;

        Where.Left := Where.Left + ColWidths[CurCol] + DrawInfo.Horz.EffectiveLineWidth;
        Inc(CurCol);
      end;
      Where.Top := Where.Top + RowHeights[CurRow] + DrawInfo.Vert.EffectiveLineWidth;
      Inc(CurRow);
    end;
    RestoreClipRect(Canvas);
  end;

  function CalcMaxStroke: Integer;
  var
    i, j, HorzStroke, VertStroke: Integer;
  begin
    Result := Max(DrawInfo.Horz.LastFullVisibleCell - 1,
      DrawInfo.Vert.LastFullVisibleCell - 1) + 4;
    i := MinHorzCell;
    VertStroke := 0;
    while i <= MaxHorzCell do
    begin
      j := MinVertCell;
      while j <= MaxVertCell do
      begin
        if i <> Cells[i, j].EndCol then
        begin
          Inc(VertStroke);
          j := Cells[i, j].EndRow + 1;
        end
        else
          Inc(j);
      end;
      Inc(i);
    end;

    j := MinVertCell;
    HorzStroke := 0;
    while j <= MaxVertCell do
    begin
      i := MinHorzCell;
      while i <= MaxHorzCell do
      begin
        if j <> Cells[i, j].EndRow then
        begin
          Inc(HorzStroke);
          i := Cells[i, j].EndCol + 1;
        end
        else
          Inc(i);
      end;
      Inc(j);
    end;
    Result := Result + Max(HorzStroke, VertStroke);
  end;

  function CalcMinHorzCell: Integer;
  var
    i: Integer;
  begin
    Result := Cells[LeftCol, TopRow].StartCol;
    for i := 1 to MaxVertCell do
      Result := Min(Result, Cells[LeftCol, i].StartCol);
  end;

  function CalcMinVertCell: Integer;
  var
    i: Integer;
  begin
    Result := Cells[LeftCol, TopRow].StartRow;
    for i := 1 to MaxHorzCell do
      Result := Min(Result, Cells[i, TopRow].StartRow);
  end;

begin
  UpdateRect := Canvas.ClipRect;
  CalcDrawInfo(DrawInfo);
  with DrawInfo do
  begin
    if (Horz.EffectiveLineWidth > 0) or (Vert.EffectiveLineWidth > 0) then
    begin
      MaxHorzExtent := Min(Width, Horz.GridBoundary);
      MaxVertExtent := Min(Height, Vert.GridBoundary);
      MaxHorzCell := Min(Horz.GridCellCount - 1, Horz.LastFullVisibleCell + 1);
      MaxVertCell := Min(Vert.GridCellCount - 1, Vert.LastFullVisibleCell + 1);
      MinHorzCell := CalcMinHorzCell;
      MinVertCell := CalcMinVertCell;
      MaxStroke := CalcMaxStroke;
      PointsList := StackAlloc(MaxStroke * sizeof(TPoint) * 2);
      StrokeList := StackAlloc(MaxStroke * sizeof(Integer));
      FillDWord(StrokeList^, MaxStroke, 2);

      _DrawLines(rmgoFixedHorzLine in Options, rmgoFixedVertLine in Options, // 固定区交叉区
        1, 1, Horz.FixedCellCount, Vert.FixedCellCount,
        [0, 0, Horz.FixedBoundary, Vert.FixedBoundary], FFixedLineColor, Color);
      _DrawLines(rmgoFixedHorzLine in Options, rmgoFixedVertLine in Options, // 顶部固定区
        LeftCol, 1, MaxHorzCell, Vert.FixedCellCount,
        [Horz.FixedBoundary, 0, MaxHorzExtent,
        Vert.FixedBoundary], FFixedLineColor, Color);
      _DrawLines(rmgoFixedHorzLine in Options, rmgoFixedVertLine in Options, // 左部固定区
        1, TopRow, Horz.FixedCellCount, MaxVertCell,
        [0, Vert.FixedBoundary, Horz.FixedBoundary,
        MaxVertExtent], FFixedLineColor, Color);
      _DrawLines(rmgoHorzLine in Options, rmgoVertLine in Options, // 活动区域
        LeftCol, TopRow, MaxHorzCell, MaxVertCell,
        [Horz.FixedBoundary, Vert.FixedBoundary, MaxHorzExtent,
        MaxVertExtent], FClientLineColor, Color);

      StackFree(StrokeList);
      StackFree(PointsList);
    end;

    Sel := Selection;
    FrameFlags1 := 0;
    FrameFlags2 := 0;
    if rmgoFixedVertLine in Options then
    begin
      FrameFlags1 := BF_RIGHT;
      FrameFlags2 := BF_LEFT;
    end;
    if rmgoFixedHorzLine in Options then
    begin
      FrameFlags1 := FrameFlags1 or BF_BOTTOM;
      FrameFlags2 := FrameFlags2 or BF_TOP;
    end;
    DrawCells(6, 0, 0, FFixedCols, FFixedRows, FixedColor, [rmgdFixed]); // 固定区交叉区
    DrawCells(7, MinHorzCell, 0, MaxHorzCell, FFixedRows, FixedColor, [rmgdFixed]); // 顶部固定区
    DrawCells(8, 0, MinVertCell, FFixedCols, MaxVertCell, FixedColor, [rmgdFixed]);
    DrawCells(9, MinHorzCell, MinVertCell, MaxHorzCell, MaxVertCell, Color, []);

    if Horz.GridBoundary < Horz.GridExtent then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(Horz.GridBoundary, 0, Horz.GridExtent, Vert.GridBoundary));
    end;
    if Vert.GridBoundary < Vert.GridExtent then
    begin
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(0, Vert.GridBoundary, Horz.GridExtent, Vert.GridExtent));
    end;
  end;
end;

function TRMGridEx.CalcCoordFromPoint(X, Y: Integer; const DrawInfo: TRMGridDrawInfo): TPoint;

  function DoCalc(const AxisInfo: TRMGridAxisDrawInfo; N: Integer): Integer;
  var
    I, Start, Stop: Longint;
    Line: Integer;
  begin
    with AxisInfo do
    begin
      if N < FixedBoundary then
      begin
        Start := 0;
        Stop := FixedCellCount - 1;
        Line := 0;
      end
      else
      begin
        Start := FirstGridCell;
        Stop := GridCellCount - 1;
        Line := FixedBoundary;
      end;
      Result := -1;
      for I := Start to Stop do
      begin
        Inc(Line, GetExtent(I) + EffectiveLineWidth);
        if N < Line then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;

  function DoCalcRightToLeft(const AxisInfo: TRMGridAxisDrawInfo; N: Integer): Integer;
  var
    I, Start, Stop: Longint;
    Line: Integer;
  begin
    N := ClientWidth - N;
    with AxisInfo do
    begin
      if N < FixedBoundary then
      begin
        Start := 0;
        Stop := FixedCellCount - 1;
        Line := ClientWidth;
      end
      else
      begin
        Start := FirstGridCell;
        Stop := GridCellCount - 1;
        Line := FixedBoundary;
      end;
      Result := -1;
      for I := Start to Stop do
      begin
        Inc(Line, GetExtent(I) + EffectiveLineWidth);
        if N < Line then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;

begin
  Result.X := DoCalc(DrawInfo.Horz, X);
  Result.Y := DoCalc(DrawInfo.Vert, Y);
end;

procedure TRMGridEx.CalcDrawInfo(var DrawInfo: TRMGridDrawInfo);
begin
  CalcDrawInfoXY(DrawInfo, ClientWidth, ClientHeight);
end;

procedure TRMGridEx.CalcDrawInfoXY(var DrawInfo: TRMGridDrawInfo;
  UseWidth, UseHeight: Integer);

  procedure CalcAxis(var AxisInfo: TRMGridAxisDrawInfo; UseExtent: Integer);
  var
    I: Integer;
  begin
    with AxisInfo do
    begin
      GridExtent := UseExtent;
      GridBoundary := FixedBoundary;
      FullVisBoundary := FixedBoundary;
      LastFullVisibleCell := FirstGridCell;
      for I := FirstGridCell to GridCellCount - 1 do
      begin
        Inc(GridBoundary, GetExtent(I) + EffectiveLineWidth);
        if GridBoundary > GridExtent + EffectiveLineWidth then
        begin
          GridBoundary := GridExtent;
          Break;
        end;
        LastFullVisibleCell := I;
        FullVisBoundary := GridBoundary;
      end;
    end;
  end;

begin
  CalcFixedInfo(DrawInfo);
  CalcAxis(DrawInfo.Horz, UseWidth);
  CalcAxis(DrawInfo.Vert, UseHeight);
end;

procedure TRMGridEx.CalcFixedInfo(var DrawInfo: TRMGridDrawInfo);

  procedure CalcFixedAxis(var Axis: TRMGridAxisDrawInfo; LineOptions: TRMGridOptions;
    FixedCount, FirstCell, CellCount: Integer; GetExtentFunc: TRMGetExtentsFunc);
  var
    I: Integer;
  begin
    with Axis do
    begin
      if LineOptions * Options = [] then
        EffectiveLineWidth := 0
      else
        EffectiveLineWidth := 1;

      FixedBoundary := 0;
      for I := 0 to FixedCount - 1 do
        Inc(FixedBoundary, GetExtentFunc(I) + EffectiveLineWidth);

      FixedCellCount := FixedCount;
      FirstGridCell := FirstCell;
      GridCellCount := CellCount;
      GetExtent := GetExtentFunc;
    end;
  end;

begin
  CalcFixedAxis(DrawInfo.Horz, [rmgoFixedVertLine, rmgoVertLine], FFixedCols,
    LeftCol, ColCount, GetColWidths);
  CalcFixedAxis(DrawInfo.Vert, [rmgoFixedHorzLine, rmgoHorzLine], FFixedRows,
    TopRow, RowCount, GetRowHeights);
end;

{ Calculates the TopLeft that will put the given Coord in view }

function TRMGridEx.CalcMaxTopLeft(const Coord: TPoint;
  const DrawInfo: TRMGridDrawInfo): TPoint;

  function CalcMaxCell(const Axis: TRMGridAxisDrawInfo; Start: Integer): Integer;
  var
    Line: Integer;
    I, Extent: Longint;
  begin
    Result := Start;
    with Axis do
    begin
      Line := GridExtent + EffectiveLineWidth;
      for I := Start downto FixedCellCount do
      begin
        Extent := GetExtent(I);
        if Extent > 0 then
        begin
          Dec(Line, Extent);
          Dec(Line, EffectiveLineWidth);
          if Line < FixedBoundary then
          begin
            if (Result = Start) and (GetExtent(Start) <= 0) then
              Result := I;
            Break;
          end;
          Result := I;
        end;
      end;
    end;
  end;

begin
  Result.X := CalcMaxCell(DrawInfo.Horz, Coord.X);
  Result.Y := CalcMaxCell(DrawInfo.Vert, Coord.Y);
end;

procedure TRMGridEx.CalcSizingState(X, Y: Integer; var State: TRMGridState;
  var Index: Longint; var SizingPos, SizingOfs: Integer;
  var FixedInfo: TRMGridDrawInfo);

  procedure CalcAxisState(const AxisInfo: TRMGridAxisDrawInfo; Pos: Integer;
    NewState: TRMGridState);
  var
    I, Line, Back, Range: Integer;
  begin
    with AxisInfo do
    begin
      Line := FixedBoundary;
      Range := EffectiveLineWidth;
      Back := 0;
      if Range < 7 then
      begin
        Range := 7;
        Back := (Range - EffectiveLineWidth) shr 1;
      end;
      for I := FirstGridCell to GridCellCount - 1 do
      begin
        Inc(Line, GetExtent(I));
        if Line > GridBoundary then Break;
        if (Pos >= Line - Back) and (Pos <= Line - Back + Range) then
        begin
          State := NewState;
          SizingPos := Line;
          SizingOfs := Line - Pos;
          Index := I;
          Exit;
        end;
        Inc(Line, EffectiveLineWidth);
      end;

      if (GridBoundary = GridExtent) and (Pos >= GridExtent - Back)
        and (Pos <= GridExtent) then
      begin
        State := NewState;
        SizingPos := GridExtent;
        SizingOfs := GridExtent - Pos;
        //        Index := LastFullVisibleCell + 1;
        if FixedBoundary = FullVisBoundary then // whf
          Index := LastFullVisibleCell
        else
          Index := LastFullVisibleCell + 1;
      end;
    end;
  end;

  function XOutsideHorzFixedBoundary: Boolean;
  begin
    with FixedInfo do
      Result := X > Horz.FixedBoundary
  end;

  function XOutsideOrEqualHorzFixedBoundary: Boolean;
  begin
    with FixedInfo do
      Result := X >= Horz.FixedBoundary
  end;

var
  lEffectiveOptions: TRMGridOptions;

begin
  State := rmgsNormal;
  Index := -1;
  lEffectiveOptions := FOptions;
  if [rmgoColSizing, rmgoRowSizing] * lEffectiveOptions <> [] then
  begin
    with FixedInfo do
    begin
      Vert.GridExtent := ClientHeight;
      Horz.GridExtent := ClientWidth;
      if (XOutsideHorzFixedBoundary) and (rmgoColSizing in lEffectiveOptions) then
      begin
        if Y >= Vert.FixedBoundary then Exit;

        CalcAxisState(Horz, X, rmgsColSizing);
      end
      else if (Y > Vert.FixedBoundary) and (rmgoRowSizing in lEffectiveOptions) then
      begin
        if XOutsideOrEqualHorzFixedBoundary then Exit;

        CalcAxisState(Vert, Y, rmgsRowSizing);
      end;
    end;
  end;
end;

procedure TRMGridEx.ChangeSize(NewColCount, NewRowCount: Longint);
var
  OldColCount, OldRowCount: Longint;
  OldDrawInfo: TRMGridDrawInfo;

  procedure MinRedraw(const OldInfo, NewInfo: TRMGridAxisDrawInfo; Axis: Integer);
  var
    R: TRect;
    First: Integer;
  begin
    if not FAutoDraw then
      Exit;
    First := Min(OldInfo.LastFullVisibleCell, NewInfo.LastFullVisibleCell);
    R := CellRect(First and not Axis, First and Axis);
    R.Bottom := Height;
    R.Right := Width;
    Windows.InvalidateRect(Handle, @R, False);
  end;

  procedure DoChange;
  var
    Coord: TPoint;
    NewDrawInfo: TRMGridDrawInfo;
  begin
    if FColWidths <> nil then
      UpdateExtents(FColWidths, ColCount, FmmDefaultColWidth);
    if FRowHeights <> nil then
      UpdateExtents(FRowHeights, RowCount, FmmDefaultRowHeight);
    Coord := FCurrent;
    if Row >= RowCount then
      Coord.Y := RowCount - 1;
    if Col >= ColCount then
      Coord.X := ColCount - 1;
    if (FCurrent.X <> Coord.X) or (FCurrent.Y <> Coord.Y) then
      MoveCurrent(Coord.X, Coord.Y, True, True);
    if (FAnchor.X <> Coord.X) or (FAnchor.Y <> Coord.Y) then
      MoveAnchor(Coord);
    if VirtualView or (LeftCol <> OldDrawInfo.Horz.FirstGridCell) or
      (TopRow <> OldDrawInfo.Vert.FirstGridCell) then
    begin
      if FAutoDraw then
        InvalidateGrid;
    end
    else if HandleAllocated then
    begin
      CalcDrawInfo(NewDrawInfo);
      MinRedraw(OldDrawInfo.Horz, NewDrawInfo.Horz, 0);
      MinRedraw(OldDrawInfo.Vert, NewDrawInfo.Vert, -1);
    end;
    UpdateScrollRange;
    SizeChanged(OldColCount, OldRowCount);
  end;

begin
  if HandleAllocated then
    CalcDrawInfo(OldDrawInfo);
  OldColCount := FColCount;
  OldRowCount := FRowCount;
  FColCount := NewColCount;
  FRowCount := NewRowCount;
  if FFixedCols > NewColCount then FFixedCols := NewColCount - 1;
  if FFixedRows > NewRowCount then FFixedRows := NewRowCount - 1;
  try
    DoChange;
  except
    { Could not change size so try to clean up by setting the size back }
    FColCount := OldColCount;
    FRowCount := OldRowCount;
    DoChange;
    if FAutoDraw then
      InvalidateGrid;
    raise;
  end;
end;

{ Will move TopLeft so that Coord is in view }

procedure TRMGridEx.ClampInView(const Coord: TPoint);
var
  DrawInfo: TRMGridDrawInfo;
  MaxTopLeft: TPoint;
  OldTopLeft: TPoint;
begin
  if not HandleAllocated then
    Exit;
  CalcDrawInfo(DrawInfo);
  with DrawInfo, Coord do
  begin
    if (X > Horz.LastFullVisibleCell) or
      (Y > Vert.LastFullVisibleCell) or (X < LeftCol) or (Y < TopRow) then
    begin
      OldTopLeft := FTopLeft;
      MaxTopLeft := CalcMaxTopLeft(Coord, DrawInfo);
      Update;
      if X < LeftCol then
        FTopLeft.X := X
      else if X > Horz.LastFullVisibleCell then
        FTopLeft.X := MaxTopLeft.X;
      if Y < TopRow then
        FTopLeft.Y := Y
      else if Y > Vert.LastFullVisibleCell then
        FTopLeft.Y := MaxTopLeft.Y;
      TopLeftMoved(OldTopLeft);
    end;
  end;
end;

procedure TRMGridEx.DrawSizingLine(const DrawInfo: TRMGridDrawInfo);
var
  OldPen: TPen;
begin
  OldPen := TPen.Create;
  try
    with Canvas, DrawInfo do
    begin
      OldPen.Assign(Pen);
      Pen.Style := psDot;
      Pen.Mode := pmXor;
      Pen.Width := 1;
      try
        if FGridState = rmgsRowSizing then
        begin
          MoveTo(0, FSizingPos);
          LineTo(Horz.GridBoundary, FSizingPos);
        end
        else
        begin
          MoveTo(FSizingPos, 0);
          LineTo(FSizingPos, Vert.GridBoundary);
        end;
      finally
        Pen := OldPen;
      end;
    end;
  finally
    OldPen.Free;
  end;
end;

procedure TRMGridEx.DrawMove;
var
  OldPen: TPen;
  Pos: Integer;
  R: TRect;
begin
  OldPen := TPen.Create;
  try
    with Canvas do
    begin
      OldPen.Assign(Pen);
      try
        Pen.Style := psDot;
        Pen.Mode := pmXor;
        Pen.Width := 5;
        if FGridState = rmgsRowMoving then
        begin
          R := CellRect(0, FMovePos);
          if FMovePos > FMoveIndex then
            Pos := R.Bottom
          else
            Pos := R.Top;
          MoveTo(0, Pos);
          LineTo(ClientWidth, Pos);
        end
        else
        begin
          R := CellRect(FMovePos, 0);
          if FMovePos > FMoveIndex then
            Pos := R.Right
          else
            Pos := R.Left;
          MoveTo(Pos, 0);
          LineTo(Pos, ClientHeight);
        end;
      finally
        Canvas.Pen := OldPen;
      end;
    end;
  finally
    OldPen.Free;
  end;
end;

procedure TRMGridEx.FocusCell(ACol, ARow: Longint; MoveAnchor: Boolean);
begin
  MoveCurrent(ACol, ARow, MoveAnchor, True);
  UpdateEdit;
  Click;
end;

procedure TRMGridEx.GridRectToScreenRect(GridRect: TRect;
  var ScreenRect: TRect; IncludeLine: Boolean);

  function LinePos(const AxisInfo: TRMGridAxisDrawInfo; Line: Integer): Integer;
  var
    Start, I: Longint;
  begin
    with AxisInfo do
    begin
      Result := 0;
      if Line < FixedCellCount then
        Start := 0
      else
      begin
        if Line >= FirstGridCell then
          Result := FixedBoundary;
        Start := FirstGridCell;
      end;
      for I := Start to Line - 1 do
      begin
        Inc(Result, GetExtent(I) + EffectiveLineWidth);
        if Result > GridExtent then
        begin
          Result := 0;
          Exit;
        end;
      end;
    end;
  end;

  function CalcAxis(const AxisInfo: TRMGridAxisDrawInfo;
    GridRectMin, GridRectMax: Integer;
    var ScreenRectMin, ScreenRectMax: Integer): Boolean;
  begin
    Result := False;
    with AxisInfo do
    begin
      if (GridRectMin >= FixedCellCount) and (GridRectMin < FirstGridCell) then
        if GridRectMax < FirstGridCell then
        begin
          FillChar(ScreenRect, SizeOf(ScreenRect), 0); { erase partial results }
          Exit;
        end
        else
          GridRectMin := FirstGridCell;
      if GridRectMax > LastFullVisibleCell then
      begin
        GridRectMax := LastFullVisibleCell;
        if GridRectMax < GridCellCount - 1 then
          Inc(GridRectMax);
        if LinePos(AxisInfo, GridRectMax) = 0 then
          Dec(GridRectMax);
      end;

      ScreenRectMin := LinePos(AxisInfo, GridRectMin);
      ScreenRectMax := LinePos(AxisInfo, GridRectMax);
      if ScreenRectMax = 0 then
        ScreenRectMax := ScreenRectMin + GetExtent(GridRectMin)
      else
        Inc(ScreenRectMax, GetExtent(GridRectMax));
      if ScreenRectMax > GridExtent then
        ScreenRectMax := GridExtent;
      if IncludeLine then
        Inc(ScreenRectMax, EffectiveLineWidth);
    end;
    Result := True;
  end;

var
  DrawInfo: TRMGridDrawInfo;
{$IFDEF COMPILER4_UP}
  Hold: Integer;
{$ENDIF}
begin
  FillChar(ScreenRect, SizeOf(ScreenRect), 0);
  if (GridRect.Left > GridRect.Right) or (GridRect.Top > GridRect.Bottom) then
    Exit;
  CalcDrawInfo(DrawInfo);
  with DrawInfo do
  begin
    if GridRect.Left > Horz.LastFullVisibleCell + 1 then
      Exit;
    if GridRect.Top > Vert.LastFullVisibleCell + 1 then
      Exit;

    if CalcAxis(Horz, GridRect.Left, GridRect.Right, ScreenRect.Left,
      ScreenRect.Right) then
    begin
      CalcAxis(Vert, GridRect.Top, GridRect.Bottom, ScreenRect.Top,
        ScreenRect.Bottom);
    end;
  end;

{$IFDEF COMPILER4_UP}
  if UseRightToLeftAlignment and (Canvas.CanvasOrientation = coLeftToRight) then
  begin
    Hold := ScreenRect.Left;
    ScreenRect.Left := ClientWidth - ScreenRect.Right;
    ScreenRect.Right := ClientWidth - Hold;
  end;
{$ENDIF}
end;

procedure TRMGridEx.Initialize;
begin
  FTopLeft.X := FFixedCols;
  FTopLeft.Y := FFixedRows;
  FCurrent := FTopLeft;
  FAnchor := FCurrent;
end;

procedure TRMGridEx.InvalidateCell(ACol, ARow: Longint);
var
  Rect: TRect;
begin
  Rect.Top := ARow;
  Rect.Left := ACol;
  Rect.Bottom := ARow;
  Rect.Right := ACol;
  InvalidateRect(Rect);
end;

procedure TRMGridEx.InvalidateCol(ACol: Longint);
var
  lRect: TRect;
begin
  if not HandleAllocated then Exit;

  lRect.Top := 0;
  lRect.Left := ACol;
  lRect.Bottom := VisibleRowCount + 1;
  lRect.Right := ACol;
  InvalidateRect(lRect);
end;

procedure TRMGridEx.InvalidateRow(ARow: Longint);
var
  lRect: TRect;
begin
  if not HandleAllocated then Exit;

  lRect.Top := ARow;
  lRect.Left := 0;
  lRect.Bottom := ARow;
  lRect.Right := VisibleColCount + 1;
  InvalidateRect(lRect);
end;

procedure TRMGridEx.InvalidateGrid;
begin
  FCurrentCol := -1;
  FCurrentRow := -1;
  Invalidate;
end;

function TRMGridEx.GetCellRect(ACell: TRMCellInfo): TRect;
var
  R, tempRc: Trect;
  bCalcRc, bFix: Boolean;
  iFirstCol, iFirstRow, iEndCol, iEndRow: Integer;

  function GetRC(ACol, ARow: Integer): Trect;
  var
    tempRc: Trect;
    i, iLeft, iTop, iFix: Integer;
  begin
    if ACol < leftCol then
    begin
      tempRc := CellRect(leftcol, TopRow);
      for i := ACol to (leftCol - 1) do
        tempRc.Left := tempRc.left - colwidths[i] - 1;
      iFix := 0;
      for i := 0 to FFixedCols - 1 do
        iFix := iFix + ColWidths[i] + 1;
    end
    else if ACol > (leftcol + VisibleColCount - 1) then
    begin
      tempRc := CellRect(leftcol + VisibleColCount - 1, TopRow);
      for i := (leftcol + VisibleColCount) to ACol do
        tempRc.Left := tempRc.left + colwidths[i - 1] + 1;
    end
    else
    begin
      tempRc := CellRect(ACol, TopRow);
    end;
    iLeft := tempRc.Left;
    if ARow < TopRow then
    begin
      tempRc := CellRect(leftcol, TopRow);
      for i := ARow to TopRow - 1 do
        tempRc.top := tempRc.top - Rowheights[i] - 1;
      iFix := 0;
      for i := 0 to FFixedrows - 1 do
        iFix := iFix + Rowheights[i] + 1;
    end
    else if ARow > (TopRow + VisibleRowCount - 1) then
    begin
      tempRc := CellRect(leftcol, TopRow + VisibleRowCount - 1);
      for i := TopRow + VisibleRowCount to ARow do
        tempRc.top := tempRc.top + Rowheights[i] + 1;
    end
    else
    begin
      tempRc := CellRect(leftcol, ARow);
    end;
    iTop := tempRc.top;
    result.Left := iLeft;
    result.Top := iTop;
    result.Right := ColWidths[ACol] + result.Left;
    result.Bottom := RowHeights[ARow] + result.Top;
  end;

begin
  iFirstCol := aCell.StartCol;
  iFirstRow := aCell.StartRow;
  iEndCol := aCell.EndCol;
  iendrow := aCell.EndRow;
  bCalcRc := false;
  R := CellRect(iFirstCol, iFirstRow);
  //开始行、列不可见区域置为负数
  if Cells[iFirstCol, iFirstRow].Mutilcell then
  begin
    if ((R.Right - r.Left) <> ColWidths[iFirstCol]) or ((R.Bottom - R.Top) <> RowHeights[iFirstRow]) then
    begin
      if ((R.Right - r.Left) <> colwidths[iFirstCol]) then //确定左边界
        R.Left := GetRc(ifirstCol, ifirstRow).Left;
      if ((R.Bottom - R.Top) <> RowHeights[iFirstRow]) then //确定上边界
        R.Top := GetRc(ifirstCol, ifirstRow).top;
      bCalcRc := true;
    end;
  end;

  Result := R;
  R := CellRect(iEndCol, iEndRow);
  //结束行、列不可见区域置为>边界
  if Cells[iFirstCol, iFirstRow].Mutilcell then
  begin
    if ((R.Right - r.Left) <> colwidths[iEndCol]) or ((R.Bottom - R.Top) <> RowHeights[iEndrow]) then
    begin
      if ((R.Right - r.Left) <> colwidths[iEndCol]) then
      begin //确定右边界
        R.Right := getRc(iEndcol, iEndRow).right;
      end;
      if ((R.Bottom - R.Top) <> RowHeights[iEndrow]) then
      begin //确定下边界
        R.Bottom := getRc(iEndcol, iEndRow).Bottom;
      end;
      bCalcRc := true
    end;
  end;

  Result.Bottom := R.Bottom;
  Result.Right := R.Right;
  bFix := (iEndcol < FFixedCols) or (iendRow < FFixedRows);
  if bCalcRc then
  begin
    tempRc := Cellrect(LeftCol, TopRow);
    if bFix then
    begin
      if iendrow < FFixedRows then
      begin
        Result.Left := Max(tempRC.Left, Result.Left);
        Result.Right := Min(result.right, GridWidth);
      end
    end
    else
    begin
      Result.left := Max(tempRC.Left, Result.Left);
      Result.Top := max(tempRC.top, result.top);
      Result.Bottom := min(result.bottom, GridHeight);
      Result.Right := Min(result.right, GridWidth);
    end;
  end;
end;

procedure TRMGridEx.InvalidateRect(ARect: TRect);
var
  InvalidRect: TRect;

  procedure _CustomUpdateRect(var ARect: Trect);
  var
    ACol, ARow: Integer;
  begin
    MouseToCell(Arect.left + 1, ARect.Top + 1, ACol, ARow);
    if (ACol < ColCount) and (ACol >= 0) and (aRow < RowCount) and (ARow >= 0) then
    begin
      ARect := GetCellRect(Cells[ACol, ARow]);
    end;
  end;

begin
  if (not FAutoDraw) or (not HandleAllocated) then Exit;

  GridRectToScreenRect(ARect, InvalidRect, True);
  //_CustomUpdateRect(InvalidRect);
  Windows.InvalidateRect(Handle, @InvalidRect, False);
  //UpdateWindow(Handle);
end;

procedure TRMGridEx.ModifyScrollBar(ScrollBar, ScrollCode, Pos: Cardinal;
  UseRightToLeft: Boolean);
var
  NewTopLeft, MaxTopLeft: TPoint;
  DrawInfo: TRMGridDrawInfo;
  RTLFactor: Integer;

  function _Min: Longint;
  begin
    if ScrollBar = SB_HORZ then
      Result := FFixedCols
    else
      Result := FFixedRows;
  end;

  function _Max: Longint;
  begin
    if ScrollBar = SB_HORZ then
      Result := MaxTopLeft.X
    else
      Result := MaxTopLeft.Y;
  end;

  function PageUp: Longint;
  var
    MaxTopLeft: TPoint;
  begin
    MaxTopLeft := CalcMaxTopLeft(FTopLeft, DrawInfo);
    if ScrollBar = SB_HORZ then
      Result := FTopLeft.X - MaxTopLeft.X
    else
      Result := FTopLeft.Y - MaxTopLeft.Y;
    if Result < 1 then
      Result := 1;
  end;

  function PageDown: Longint;
  var
    DrawInfo: TRMGridDrawInfo;
  begin
    CalcDrawInfo(DrawInfo);
    with DrawInfo do
      if ScrollBar = SB_HORZ then
        Result := Horz.LastFullVisibleCell - FTopLeft.X
      else
        Result := Vert.LastFullVisibleCell - FTopLeft.Y;
    if Result < 1 then
      Result := 1;
  end;

  function CalcScrollBar(Value, ARTLFactor: Longint): Longint;
  begin
    Result := Value;
    case ScrollCode of
      SB_LINEUP:
        Dec(Result, ARTLFactor);
      SB_LINEDOWN:
        Inc(Result, ARTLFactor);
      SB_PAGEUP:
        Dec(Result, PageUp * ARTLFactor);
      SB_PAGEDOWN:
        Inc(Result, PageDown * ARTLFactor);
      SB_THUMBPOSITION, SB_THUMBTRACK:
        if (rmgoThumbTracking in FOptions) or (ScrollCode = SB_THUMBPOSITION) then
        begin
          Result := _Min + LongMulDiv(Pos, _Max - _Min, MaxShortInt);
        end;
      SB_BOTTOM:
        Result := _Max;
      SB_TOP:
        Result := _Min;
    end;
  end;

  procedure ModifyPixelScrollBar(Code, Pos: Cardinal);
  var
    NewOffset: Integer;
    OldOffset: Integer;
    R: TRect;
    GridSpace, ColWidth: Integer;
  begin
    NewOffset := FColOffset;
    ColWidth := ColWidths[DrawInfo.Horz.FirstGridCell];
    GridSpace := ClientWidth - DrawInfo.Horz.FixedBoundary;
    case Code of
      SB_LINEUP: Dec(NewOffset, Canvas.TextWidth('0') * RTLFactor);
      SB_LINEDOWN: Inc(NewOffset, Canvas.TextWidth('0') * RTLFactor);
      SB_PAGEUP: Dec(NewOffset, GridSpace * RTLFactor);
      SB_PAGEDOWN: Inc(NewOffset, GridSpace * RTLFactor);
      SB_THUMBPOSITION,
        SB_THUMBTRACK:
        if (rmgoThumbTracking in FOptions) or (Code = SB_THUMBPOSITION) then
        begin
          NewOffset := Pos;
        end;
      SB_BOTTOM: NewOffset := 0;
      SB_TOP: NewOffset := ColWidth - GridSpace;
    end;
    if NewOffset < 0 then
      NewOffset := 0
    else if NewOffset >= ColWidth - GridSpace then
      NewOffset := ColWidth - GridSpace;
    if NewOffset <> FColOffset then
    begin
      OldOffset := FColOffset;
      FColOffset := NewOffset;
      ScrollData(OldOffset - NewOffset, 0);
      FillChar(R, SizeOf(R), 0);
      R.Bottom := FFixedRows;
      InvalidateRect(R);
      Update;
      UpdateScrollPos;
    end;
  end;

var
  Temp: Longint;
begin
  HideEditor;
  RTLFactor := 1;
  if Visible and CanFocus and TabStop and not (csDesigning in ComponentState) then
    SetFocus;
  CalcDrawInfo(DrawInfo);
  if (ScrollBar = SB_HORZ) and (ColCount = 1) then
  begin
    ModifyPixelScrollBar(ScrollCode, Pos);
    Exit;
  end;
  MaxTopLeft.X := ColCount - 1;
  MaxTopLeft.Y := RowCount - 1;
  MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  NewTopLeft := FTopLeft;
  if ScrollBar = SB_HORZ then
    repeat
      Temp := NewTopLeft.X;
      NewTopLeft.X := CalcScrollBar(NewTopLeft.X, RTLFactor);
    until (NewTopLeft.X <= FFixedCols) or (NewTopLeft.X >= MaxTopLeft.X)
      or (ColWidths[NewTopLeft.X] > 0) or (Temp = NewTopLeft.X)
  else
    repeat
      Temp := NewTopLeft.Y;
      NewTopLeft.Y := CalcScrollBar(NewTopLeft.Y, 1);
    until (NewTopLeft.Y <= FFixedRows) or (NewTopLeft.Y >= MaxTopLeft.Y)
      or (RowHeights[NewTopLeft.Y] > 0) or (Temp = NewTopLeft.Y);
  NewTopLeft.X := Max(FFixedCols, Min(MaxTopLeft.X, NewTopLeft.X));
  NewTopLeft.Y := Max(FFixedRows, Min(MaxTopLeft.Y, NewTopLeft.Y));
  if (NewTopLeft.X <> FTopLeft.X) or (NewTopLeft.Y <> FTopLeft.Y) then
    MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
end;

procedure TRMGridEx.MoveAdjust(var CellPos: Longint; FromIndex, ToIndex: Longint);
var
  Min, Max: Longint;
begin
  if CellPos = FromIndex then
    CellPos := ToIndex
  else
  begin
    Min := FromIndex;
    Max := ToIndex;
    if FromIndex > ToIndex then
    begin
      Min := ToIndex;
      Max := FromIndex;
    end;
    if (CellPos >= Min) and (CellPos <= Max) then
      if FromIndex > ToIndex then
        Inc(CellPos)
      else
        Dec(CellPos);
  end;
end;

procedure TRMGridEx.MoveAnchor(const NewAnchor: TPoint);
var
  OldSel: TRect;
begin
  if [rmgoRangeSelect {, rmgoEditing}] * FOptions = [rmgoRangeSelect] then
  begin
    OldSel := Selection;
    FAnchor := NewAnchor;
    ClampInView(NewAnchor);
    SelectionMoved(OldSel);
  end
  else
    MoveCurrent(NewAnchor.X, NewAnchor.Y, True, True);
end;

procedure TRMGridEx.MoveCurrent(ACol, ARow: Longint; MoveAnchor, Show: Boolean);
var
  OldSel: TRect;
  OldCurrent: TPoint;
begin
  if (ACol < 0) or (ARow < 0) or (ACol >= ColCount) or (ARow >= RowCount) then
    InvalidOp(SIndexOutOfRange);
  if SelectCell(ACol, ARow) then
  begin
    OldSel := Selection;
    OldCurrent := FCurrent;
    FCurrent.X := ACol;
    FCurrent.Y := ARow;
    if not (rmgoAlwaysShowEditor in Options) then HideEditor;
    if MoveAnchor or not (rmgoRangeSelect in FOptions) then
    begin
      FAnchor.X := Cells[FCurrent.X, FCurrent.Y].EndCol;
      FAnchor.Y := Cells[FCurrent.X, FCurrent.Y].EndRow;
      //      FAnchor := FCurrent;
    end;
    if Show then ClampInView(FCurrent);
    SelectionMoved(OldSel);
    with OldCurrent do InvalidateCell(OldCurrent.X, OldCurrent.Y);
    with FCurrent do InvalidateCell(ACol, ARow);
  end;
end;

procedure TRMGridEx.MoveTopLeft(ALeft, ATop: Longint);
var
  OldTopLeft: TPoint;
begin
  if (ALeft = FTopLeft.X) and (ATop = FTopLeft.Y) then
    Exit;
  Update;
  OldTopLeft := FTopLeft;
  FTopLeft.X := ALeft;
  FTopLeft.Y := ATop;
  TopLeftMoved(OldTopLeft);
end;

procedure TRMGridEx.ResizeCol(Index: Longint; OldSize, NewSize: Integer);
begin
  InvalidateGrid;
end;

procedure TRMGridEx.ResizeRow(Index: Longint; OldSize, NewSize: Integer);
begin
  InvalidateGrid;
end;

procedure TRMGridEx.SelectionMoved(const OldSel: TRect);
var
  OldRect, NewRect: TRect;
  AXorRects: TXorRects;
  I: Integer;
begin
  if not HandleAllocated then Exit;
  GridRectToScreenRect(OldSel, OldRect, True);
  GridRectToScreenRect(Selection, NewRect, True);
  XorRects(OldRect, NewRect, AXorRects);
  for I := Low(AXorRects) to High(AXorRects) do
    Windows.InvalidateRect(Handle, @AXorRects[I], False);
end;

procedure TRMGridEx.ScrollDataInfo(DX, DY: Integer;
  var DrawInfo: TRMGridDrawInfo);
var
  ScrollArea: TRect;
  ScrollFlags: Integer;
begin
  with DrawInfo do
  begin
    ScrollFlags := SW_INVALIDATE;
    { Scroll the area }
    if DY = 0 then
    begin
      { Scroll both the column titles and data area at the same time }
      ScrollArea := Rect(Horz.FixedBoundary, 0, Horz.GridExtent, Vert.GridExtent);
      ScrollWindowEx(Handle, DX, 0, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    end
    else if DX = 0 then
    begin
      { Scroll both the row titles and data area at the same time }
      ScrollArea := Rect(0, Vert.FixedBoundary, Horz.GridExtent, Vert.GridExtent);
      ScrollWindowEx(Handle, 0, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    end
    else
    begin
      { Scroll titles and data area separately }
      { Column titles }
      ScrollArea := Rect(Horz.FixedBoundary, 0, Horz.GridExtent, Vert.FixedBoundary);
      ScrollWindowEx(Handle, DX, 0, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
      { Row titles }
      ScrollArea := Rect(0, Vert.FixedBoundary, Horz.FixedBoundary, Vert.GridExtent);
      ScrollWindowEx(Handle, 0, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
      { Data area }
      ScrollArea := Rect(Horz.FixedBoundary, Vert.FixedBoundary, Horz.GridExtent,
        Vert.GridExtent);
      ScrollWindowEx(Handle, DX, DY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
    end;
  end;
end;

procedure TRMGridEx.ScrollData(DX, DY: Integer);
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  ScrollDataInfo(DX, DY, DrawInfo);
end;

procedure TRMGridEx.TopLeftMoved(const OldTopLeft: TPoint);

  function CalcScroll(const AxisInfo: TRMGridAxisDrawInfo;
    OldPos, CurrentPos: Integer; var Amount: Longint): Boolean;
  var
    Start, Stop: Longint;
    I: Longint;
  begin
    Result := False;
    with AxisInfo do
    begin
      if OldPos < CurrentPos then
      begin
        Start := OldPos;
        Stop := CurrentPos;
      end
      else
      begin
        Start := CurrentPos;
        Stop := OldPos;
      end;
      Amount := 0;
      for I := Start to Stop - 1 do
      begin
        Inc(Amount, GetExtent(I) + EffectiveLineWidth);
        if Amount > (GridBoundary - FixedBoundary) then
        begin
          { Scroll amount too big, redraw the whole thing }
          InvalidateGrid;
          Exit;
        end;
      end;
      if OldPos < CurrentPos then
        Amount := -Amount;
    end;
    Result := True;
  end;

var
  DrawInfo: TRMGridDrawInfo;
  Delta: TPoint;
begin
  UpdateScrollPos;
  CalcDrawInfo(DrawInfo);
  if CalcScroll(DrawInfo.Horz, OldTopLeft.X, FTopLeft.X, Delta.X) and
    CalcScroll(DrawInfo.Vert, OldTopLeft.Y, FTopLeft.Y, Delta.Y) then
    ScrollDataInfo(Delta.X, Delta.Y, DrawInfo);
  TopLeftChanged;
end;

procedure TRMGridEx.UpdateScrollPos;
var
  DrawInfo: TRMGridDrawInfo;
  MaxTopLeft: TPoint;
  GridSpace, ColWidth: Integer;

  procedure SetScroll(Code: Word; Value: Integer);
  begin
    if GetScrollPos(Handle, Code) <> Value then
      SetScrollPos(Handle, Code, Value, True);
  end;

begin
  if (not HandleAllocated) or (FScrollBars = ssNone) then
    Exit;
  CalcDrawInfo(DrawInfo);
  MaxTopLeft.X := ColCount - 1;
  MaxTopLeft.Y := RowCount - 1;
  MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  if FScrollBars in [ssHorizontal, ssBoth] then
    if ColCount = 1 then
    begin
      ColWidth := ColWidths[DrawInfo.Horz.FirstGridCell];
      GridSpace := ClientWidth - DrawInfo.Horz.FixedBoundary;
      if (FColOffset > 0) and (GridSpace > (ColWidth - FColOffset)) then
        ModifyScrollbar(SB_HORZ, SB_THUMBPOSITION, ColWidth - GridSpace, True)
      else
        SetScroll(SB_HORZ, FColOffset)
    end
    else
      SetScroll(SB_HORZ, LongMulDiv(FTopLeft.X - FFixedCols, MaxShortInt,
        MaxTopLeft.X - FFixedCols));
  if FScrollBars in [ssVertical, ssBoth] then
    SetScroll(SB_VERT, LongMulDiv(FTopLeft.Y - FFixedRows, MaxShortInt,
      MaxTopLeft.Y - FFixedRows));
end;

procedure TRMGridEx.UpdateScrollRange;
var
  MaxTopLeft, OldTopLeft: TPoint;
  DrawInfo: TRMGridDrawInfo;
  OldScrollBars: TScrollStyle;
  Updated: Boolean;

  procedure DoUpdate;
  begin
    if not Updated then
    begin
      Update;
      Updated := True;
    end;
  end;

  function ScrollBarVisible(Code: Word): Boolean;
  var
    Min, Max: Integer;
  begin
    Result := False;
    if (FScrollBars = ssBoth) or
      ((Code = SB_HORZ) and (FScrollBars = ssHorizontal)) or
      ((Code = SB_VERT) and (FScrollBars = ssVertical)) then
    begin
      GetScrollRange(Handle, Code, Min, Max);
      Result := Min <> Max;
    end;
  end;

  procedure CalcSizeInfo;
  begin
    CalcDrawInfoXY(DrawInfo, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
    MaxTopLeft.X := ColCount - 1;
    MaxTopLeft.Y := RowCount - 1;
    MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  end;

  procedure SetAxisRange(var Max, Old, Current: Longint; Code: Word;
    Fixeds: Integer);
  begin
    CalcSizeInfo;
    if Fixeds < Max then
      SetScrollRange(Handle, Code, 0, MaxShortInt, True)
    else
      SetScrollRange(Handle, Code, 0, 0, True);
    if Old > Max then
    begin
      DoUpdate;
      Current := Max;
    end;
  end;

  procedure SetHorzRange;
  var
    Range: Integer;
  begin
    if OldScrollBars in [ssHorizontal, ssBoth] then
      if ColCount = 1 then
      begin
        Range := ColWidths[0] - ClientWidth;
        if Range < 0 then
          Range := 0;
        SetScrollRange(Handle, SB_HORZ, 0, Range, True);
      end
      else
        SetAxisRange(MaxTopLeft.X, OldTopLeft.X, FTopLeft.X, SB_HORZ, FFixedCols);
  end;

  procedure SetVertRange;
  begin
    if OldScrollBars in [ssVertical, ssBoth] then
      SetAxisRange(MaxTopLeft.Y, OldTopLeft.Y, FTopLeft.Y, SB_VERT, FFixedRows);
  end;

begin
  if (FScrollBars = ssNone) or not HandleAllocated or not Showing then
    Exit;
  with DrawInfo do
  begin
    Horz.GridExtent := ClientWidth;
    Vert.GridExtent := ClientHeight;
    { Ignore scroll bars for initial calculation }
    if ScrollBarVisible(SB_HORZ) then
      Inc(Vert.GridExtent, GetSystemMetrics(SM_CYHSCROLL));
    if ScrollBarVisible(SB_VERT) then
      Inc(Horz.GridExtent, GetSystemMetrics(SM_CXVSCROLL));
  end;
  OldTopLeft := FTopLeft;
  { Temporarily mark us as not having scroll bars to avoid recursion }
  OldScrollBars := FScrollBars;
  FScrollBars := ssNone;
  Updated := False;
  try
    { Update scrollbars }
    SetHorzRange;
    DrawInfo.Vert.GridExtent := ClientHeight;
    SetVertRange;
    if DrawInfo.Horz.GridExtent <> ClientWidth then
    begin
      DrawInfo.Horz.GridExtent := ClientWidth;
      SetHorzRange;
    end;
  finally
    FScrollBars := OldScrollBars;
  end;
  UpdateScrollPos;
  if (FTopLeft.X <> OldTopLeft.X) or (FTopLeft.Y <> OldTopLeft.Y) then
    TopLeftMoved(OldTopLeft);
end;

procedure TRMGridEx.TrackButton(X, Y: Integer);
var
  Cell: TPoint;
  NewPressed: Boolean;
begin
  Cell := MouseCoord(X, Y);
  FPressedCell := Cell;
  NewPressed := PtInRect(Rect(0, 0, ClientWidth, ClientHeight), Point(X, Y)) and (Cell.X >= 0);
  if (FPressed <> NewPressed) then
  begin
    FPressed := NewPressed;
    if Cell.X >= 0 then
      InvalidateCell(Cell.X, cell.Y);
  end;
end;

procedure TRMGridEx.KeyDown(var Key: Word; Shift: TShiftState);
var
  NewTopLeft, NewCurrent, MaxTopLeft: TPoint;
  DrawInfo: TRMGridDrawInfo;
  PageWidth, PageHeight: Integer;
  RTLFactor: Integer;
  NeedsInvalidating: Boolean;

  procedure CalcPageExtents;
  begin
    CalcDrawInfo(DrawInfo);
    PageWidth := DrawInfo.Horz.LastFullVisibleCell - LeftCol;
    if PageWidth < 1 then
      PageWidth := 1;
    PageHeight := DrawInfo.Vert.LastFullVisibleCell - TopRow;
    if PageHeight < 1 then
      PageHeight := 1;
  end;

begin
  inherited KeyDown(Key, Shift);
  NeedsInvalidating := False;
  RTLFactor := 1;
  NewCurrent := FCurrent;
  NewTopLeft := FTopLeft;
  CalcPageExtents;
  if Shift = [ssCtrl] then
  begin
    case Key of
      VK_UP:
        begin
          Dec(NewTopLeft.Y);
        end;
      VK_DOWN:
        begin
          Inc(NewTopLeft.Y);
        end;
      VK_LEFT:
        begin
          Dec(NewCurrent.X, PageWidth * RTLFactor);
          Dec(NewTopLeft.X, PageWidth * RTLFactor);
        end;
      VK_RIGHT:
        begin
          Inc(NewCurrent.X, PageWidth * RTLFactor);
          Inc(NewTopLeft.X, PageWidth * RTLFactor);
        end;
      VK_PRIOR: NewCurrent.Y := TopRow;
      VK_NEXT: NewCurrent.Y := DrawInfo.Vert.LastFullVisibleCell;
      VK_HOME:
        begin
          NewCurrent.X := FFixedCols;
          NewCurrent.Y := FFixedRows;
        end;
      VK_END:
        begin
          NewCurrent.X := ColCount - 1;
          NewCurrent.Y := RowCount - 1;
        end;
    end;
  end
  else
  begin
    case Key of
      VK_UP:
        begin
          if not (ssAlt in Shift) then
          begin
            if Shift = [ssShift] then
              FGridState := rmgsSelecting;

            NewCurrent.Y := Cells[NewCurrent.X, NewCurrent.Y].FStartRow - 1;
            //Dec(NewCurrent.Y);
          end;
        end;
      VK_DOWN:
        begin
          if not (ssAlt in Shift) then
          begin
            if Shift = [ssShift] then
              FGridState := rmgsSelecting;

            NewCurrent.Y := Cells[NewCurrent.X, NewCurrent.Y].FEndRow + 1;
            //Inc(NewCurrent.Y);
          end;
        end;
      VK_LEFT:
        begin
          if not (ssAlt in Shift) then
          begin
            if Shift = [ssShift] then
              FGridState := rmgsSelecting;

            NewCurrent.X := Cells[NewCurrent.X, NewCurrent.Y].FStartCol - 1;
            //Dec(NewCurrent.X, RTLFactor);
          end;
        end;
      VK_RIGHT:
        begin
          if not (ssAlt in Shift) then
          begin
            if Shift = [ssShift] then
              FGridState := rmgsSelecting;

            NewCurrent.X := Cells[NewCurrent.X, NewCurrent.Y].FEndCol + 1;
            //Inc(NewCurrent.X, RTLFactor);
          end;
        end;
      VK_NEXT:
        begin
          if Shift = [ssShift] then
            FGridState := rmgsSelecting;

          Inc(NewCurrent.Y, PageHeight);
          Inc(NewTopLeft.Y, PageHeight);
        end;
      VK_PRIOR:
        begin
          if Shift = [ssShift] then
            FGridState := rmgsSelecting;

          Dec(NewCurrent.Y, PageHeight);
          Dec(NewTopLeft.Y, PageHeight);
        end;
      VK_HOME:
        begin
          if Shift = [ssShift] then
            FGridState := rmgsSelecting;

          NewCurrent.X := FFixedCols;
        end;
      VK_END:
        begin
          if Shift = [ssShift] then
            FGridState := rmgsSelecting;

          NewCurrent.X := ColCount - 1;
        end;
      //VK_F2: EditorMode := True;
      VK_ESCAPE: HideEditor;
      VK_DELETE:
        begin
        end;
    end;
  end;

  MaxTopLeft.X := ColCount - 1;
  MaxTopLeft.Y := RowCount - 1;
  MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  Restrict(NewTopLeft, FFixedCols, FFixedRows, MaxTopLeft.X, MaxTopLeft.Y);
  if (NewTopLeft.X <> LeftCol) or (NewTopLeft.Y <> TopRow) then
    MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
  Restrict(NewCurrent, FFixedCols, FFixedRows, ColCount - 1, RowCount - 1);
  if (NewCurrent.X <> Col) or (NewCurrent.Y <> Row) then
    FocusCell(NewCurrent.X, NewCurrent.Y, not (ssShift in Shift));
  if NeedsInvalidating then
    Invalidate;
end;

procedure TRMGridEx.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FGridState := rmgsNormal;
  inherited KeyUp(Key, Shift);
end;

procedure TRMGridEx.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if not (rmgoAlwaysShowEditor in Options) and (Key = #13) then
  begin
    if FEditorMode then
      HideEditor
    else
      ShowEditor;

    Key := #0;
  end;
end;

procedure TRMGridEx.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  CellHit: TPoint;
  DrawInfo: TRMGridDrawInfo;
  MoveDrawn: Boolean;

  procedure _SelectCells;
  begin
    FGridState := rmgsSelecting;
    //    SetTimer(Handle, 1, 60, nil);
    if ssShift in Shift then
      MoveAnchor(CellHit)
    else
    begin
      with Cells[CellHit.X, CellHit.Y] do
        MoveCurrent(StartCol, StartRow, True, True);
    end;
  end;

begin
  if Assigned(FOnDropDownFieldClick) then
    FOnDropDownFieldClick(False, X, Y);

  HideEditor;
  RightClickRowHeader := False;
  RightClickColHeader := False;
  FHeaderClick := False;
  MoveDrawn := False;
  TrackButton(X, Y);
  if not (csDesigning in ComponentState) and (CanFocus or (GetParentForm(Self) = nil)) then
  begin
    SetFocus;
    if not IsActiveControl then
    begin
      MouseCapture := False;
      Exit;
    end;
  end;

  if (Button = mbLeft) and (ssDouble in Shift) then
  begin
    CalcDrawInfo(DrawInfo);
    CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
    if (CellHit.X >= FFixedCols) and (CellHit.Y >= FFixedRows) then
      DblClick
    else // 点中标题栏
    begin
      if (CellHit.X = 0) and (CellHit.Y = 0) then // 点击左上角的标题栏网格,则选中所有网格
      begin
      end
      else if CellHit.X >= FFixedCols then // 点击活动列标题,则选中整个列
      begin
      end
      else if CellHit.Y >= FFixedRows then // 点击活动行标题,则选中整个行
      begin
        FGridState := rmgsRowHeaderDblClick;
      end;
    end;
  end
  else if Button = mbLeft then
  begin
    CalcDrawInfo(DrawInfo);
    { Check grid sizing }
    CalcSizingState(X, Y, FGridState, FSizingIndex, FSizingPos, FSizingOfs, DrawInfo);
    if FGridState <> rmgsNormal then
    begin
      DrawSizingLine(DrawInfo);
      if Assigned(FOnBeginSizingCell) then FOnBeginSizingCell(Self);
      Exit;
    end;
    CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
    if (CellHit.X >= FFixedCols) and (CellHit.Y >= FFixedRows) then
    begin
      _SelectCells;
      if (FCurrentCol > 0) and (FCurrentRow > 0) and Assigned(FOnDropDownFieldClick) then
        FOnDropDownFieldClick(True, X, Y);
    end
    else // 点中标题栏
    begin
      FHeaderClick := True;
      if (CellHit.X < 0) or (CellHit.Y < 0) then
      begin
      end
      else if (CellHit.X = 0) and (CellHit.Y = 0) then // 点击左上角的标题栏网格,则选中所有网格
      begin
      end
      else if (CellHit.X < FFixedCols) and (CellHit.Y >= FFixedRows) then // 点击活动行标题,则选中整个行
      begin
        CellHit.X := FFixedCols;
        _SelectCells;
        Selection := Rect(CellHit.X, CellHit.Y, ColCount - 1, CellHit.Y);
      end
      else if (CellHit.X >= FFixedCols) and (CellHit.Y < FFixedRows) then // 点击活动列标题,则选中整个列
      begin
        CellHit.Y := FFixedRows;
        _SelectCells;
        Selection := Rect(CellHit.X, CellHit.Y, CellHit.X, RowCount - 1);
      end
      else if CellHit.X >= FFixedCols then
      begin
        CellHit.Y := CellHit.Y + 1;
        _SelectCells;
      end
      else if CellHit.Y >= FFixedRows then
      begin
        CellHit.X := CellHit.X + 1;
        _SelectCells;
        if Assigned(FOnRowHeaderClick) then FOnRowHeaderClick(Self, X, Y);
      end;
    end;
  end
  else if Button = mbRight then
  begin
    CalcDrawInfo(DrawInfo);
    CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
    if (CellHit.X >= FFixedCols) and (CellHit.Y >= FFixedRows) then
    begin
    end
    else // 点中标题栏
    begin
      if (CellHit.X = 0) and (CellHit.Y = 0) then // 点击左上角的标题栏网格,则选中所有网格
      begin
      end
      else if CellHit.X >= FFixedCols then // 点击活动列标题,则选中整个列
      begin
        RightClickColHeader := True;
      end
      else if CellHit.Y >= FFixedRows then // 点击活动行标题,则选中整个行
      begin
        RightClickRowHeader := True;
        CellHit.X := FFixedCols;
        _SelectCells;
        Selection := Rect(CellHit.X, CellHit.Y, ColCount - 1, CellHit.Y);
      end;
    end;
  end;

  try
    inherited MouseDown(Button, Shift, X, Y);
  except
    if MoveDrawn then
      DrawMove;
  end;
end;

procedure TRMGridEx.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  lDrawInfo: TRMGridDrawInfo;
  lCellHit: TPoint;
  lSaveX, lSaveY: Integer;

  procedure _ScrollGrid;
  var
    Point: TPoint;
    DrawInfo: TRMGridDrawInfo;
    ScrollDirection: TRMGridScrollDirection;
    CellHit: TPoint;
  begin
    if not (FGridState in [rmgsSelecting, rmgsRowMoving, rmgsColMoving]) then
      Exit;

    GetCursorPos(Point);
    Point := ScreenToClient(Point);
    CalcDrawInfo(DrawInfo);
    ScrollDirection := [];
    with DrawInfo do
    begin
      CellHit := CalcCoordFromPoint(Point.X, Point.Y, DrawInfo);
      case FGridState of
        rmgsSelecting:
          begin
            if Point.X < Horz.FixedBoundary then
              Include(ScrollDirection, rmsdLeft)
            else if Point.X > Horz.FullVisBoundary then
              Include(ScrollDirection, rmsdRight);
            if Point.Y < Vert.FixedBoundary then
              Include(ScrollDirection, rmsdUp)
            else if Point.Y > Vert.FullVisBoundary then
              Include(ScrollDirection, rmsdDown);
            if ScrollDirection <> [] then
              TimedScroll(ScrollDirection);
          end;
      end;
    end;
  end;

begin
  lSaveX := FCurrentCol; lSaveY := FCurrentRow;
  FCurrentCol := -1; FCurrentRow := -1;
  CalcDrawInfo(lDrawInfo);
  case FGridState of
    rmgsSelecting, rmgsColMoving, rmgsRowMoving:
      begin
        lCellHit := CalcCoordFromPoint(X, Y, lDrawInfo);

        // 向左上方拖动选择并超出显示范围
        if (lCellHit.X < LeftCol) and (LeftCol > FixedCols) then
          _ScrollGrid;
        if (lCellHit.Y < TopRow) and (TopRow > FixedRows) then
          _ScrollGrid;

        if (lCellHit.X >= FFixedCols) and (lCellHit.Y >= FFixedRows) and
          (lCellHit.X <= lDrawInfo.Horz.LastFullVisibleCell + 1) and
          (lCellHit.Y <= lDrawInfo.Vert.LastFullVisibleCell + 1) then
        begin
          case FGridState of
            rmgsSelecting:
              if ((lCellHit.X <> FAnchor.X) or (lCellHit.Y <> FAnchor.Y)) then
                MoveAnchor(lCellHit);
          end;
        end;
      end;
    rmgsRowSizing, rmgsColSizing:
      begin
        DrawSizingLine(lDrawInfo); { XOR it out }
        if FGridState = rmgsRowSizing then
          FSizingPos := Y + FSizingOfs
        else
          FSizingPos := X + FSizingOfs;
        DrawSizingLine(lDrawInfo); { XOR it back in }
      end;
    rmgsNormal:
      begin
        lCellHit := CalcCoordFromPoint(X, Y, lDrawInfo);
        if (lCellHit.X >= FFixedCols) and (lCellHit.Y >= FFixedRows) and
          (lCellHit.X <= lDrawInfo.Horz.LastFullVisibleCell + 1) and
          (lCellHit.Y <= lDrawInfo.Vert.LastFullVisibleCell + 1) then
        begin
          if Assigned(FOnDropDownField) then
            FOnDropDownField(lCellHit.X, lCellHit.Y);
        end;
      end;
  end;

//        	FCurrentCol := lCellHit.X;
//          FCurrentRow := lCellHit.Y;
  if (FCurrentCol <> lSaveX) or (FCurrentRow <> lSaveY) then
  begin
    InvalidateCell(lSaveX, lSaveY);
    InvalidateCell(FCurrentCol, FCurrentRow);
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TRMGridEx.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DrawInfo: TRMGridDrawInfo;
  NewSize: Integer;

  function ResizeLine(const AxisInfo: TRMGridAxisDrawInfo): Integer;
  var
    I: Integer;
  begin
    with AxisInfo do
    begin
      Result := FixedBoundary;
      for I := FirstGridCell to FSizingIndex - 1 do
        Inc(Result, GetExtent(I) + EffectiveLineWidth);
      Result := FSizingPos - Result;
    end;
  end;

begin
  if FPressed then
  begin
    InvalidateCell(FPressedCell.X, FPressedCell.Y);
    FPressed := false;
  end;
  FPressed := false;

  try
    case FGridState of
      rmgsSelecting:
        begin
          MouseMove(Shift, X, Y);
          KillTimer(Handle, 1);
          Click;
        end;
      rmgsRowSizing, rmgsColSizing:
        begin
          CalcDrawInfo(DrawInfo);
          DrawSizingLine(DrawInfo);
          if FGridState = rmgsColSizing then
          begin
            NewSize := ResizeLine(DrawInfo.Horz);
            if NewSize > 1 then
            begin
              ColWidths[FSizingIndex] := NewSize;
              if Assigned(FOnChange) then FOnChange(Self);
            end;
          end
          else
          begin
            NewSize := ResizeLine(DrawInfo.Vert);
            if NewSize > 1 then
            begin
              RowHeights[FSizingIndex] := NewSize;
              if Assigned(FOnChange) then FOnChange(Self);
            end;
          end;
        end;
      rmgsRowHeaderDblClick:
        begin
          if Assigned(FOnRowHeaderDblClick) then FOnRowHeaderDblClick(Self);
        end;
    end;
    inherited MouseUp(Button, Shift, X, Y);
  finally
    FGridState := rmgsNormal;
  end;
end;

function TRMGridEx.GetGridWidth: Integer;
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  Result := DrawInfo.Horz.GridBoundary;
end;

function TRMGridEx.GetGridHeight: Integer;
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  Result := DrawInfo.Vert.GridBoundary;
end;

function TRMGridEx.GetSelection: TRect;
var
  liOldRect, liGridRect: TRect;

  procedure GetNewRC(iLeft, iRight, iTop, iBottom: Integer);
  var
    liCol, liRow: Integer;
    liCell: TRMCellInfo;
  begin
    iRight := Min(iRight, ColCount - 1);
    iBottom := Min(iBottom, RowCount - 1);
    for liCol := iLeft to iRight do
    begin
      for liRow := iTop to iBottom do
      begin
        liCell := Cells[liCol, liRow];
        liGridRect.Left := Min(liCell.StartCol, liGridRect.Left);
        liGridRect.Top := Min(liCell.StartRow, liGridRect.Top);
        liGridRect.right := Max(liCell.EndCol, liGridRect.Right);
        liGridRect.Bottom := Max(liCell.EndRow, liGridRect.Bottom);
      end;
    end;
  end;

  procedure _CustomSetSelection;
  begin
    repeat
      liOldRect := liGridRect;
      GetNewRC(liGridRect.Left, liGridRect.Right, liGridRect.Top, liGridRect.Top);
      GetNewRC(liGridRect.Left, liGridRect.Right, liGridRect.Bottom, liGridRect.Bottom);
      GetNewRC(liGridRect.Left, liGridRect.Left, liGridRect.Top, liGridRect.Bottom);
      GetNewRC(liGridRect.Right, liGridRect.Right, liGridRect.Top, liGridRect.Bottom);
    until (liOldRect.Top = liGridRect.Top) and (liOldRect.Bottom = liGridRect.bottom) and
      (liOldRect.left = liGridRect.Left) and (liOldRect.Right = liGridRect.Right);
  end;

begin
  liGridRect := GridRect(FCurrent, FAnchor);
  _CustomSetSelection;
  Result := liGridRect;
  if (FCurrent.X > Result.Left) and (FCurrent.X < Result.Right) then
    FCurrent.X := Result.Left;
  if (FCurrent.Y > Result.Top) and (FCurrent.Y < Result.Bottom) then
    FCurrent.Y := Result.top;

  if Result.Left = FCurrent.X then
    FAnchor.X := Result.Right
  else
    FAnchor.X := Result.Left;
  if FCurrent.Y = Result.Top then
    FAnchor.Y := Result.Bottom
  else
    FAnchor.Y := Result.top;
end;

procedure TRMGridEx.SetSelection(Value: TRect);
var
  OldSel: TRect;
begin
  OldSel := Selection;
  FAnchor := Value.TopLeft;
  FCurrent := Value.BottomRight;
  SelectionMoved(OldSel);
end;

function TRMGridEx.GetVisibleColCount: Integer;
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  Result := DrawInfo.Horz.LastFullVisibleCell - LeftCol + 1;
end;

function TRMGridEx.GetVisibleRowCount: Integer;
var
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  Result := DrawInfo.Vert.LastFullVisibleCell - TopRow + 1;
end;

procedure TRMGridEx.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

function TRMGridEx.GetCol: Longint;
begin
  Result := FCurrent.X;
end;

procedure TRMGridEx.SetCol(Value: Longint);
begin
  if Col <> Value then
    FocusCell(Value, Row, True);
end;

procedure TRMGridEx.SetColCount(Value: Longint);
var
  i, j: Integer;
  liFlag: Boolean;
begin
  if FColCount = Value then
    Exit;
  if Value < ColCount then
  begin
    for i := Value to ColCount - 1 do
    begin
      for j := 1 to RowCount - 1 do
      begin
        if CellInMerge(i, j) then
          Exit;
      end;
    end;
  end;

  if FColCount <> Value then
  begin
    liFlag := FColCount < Value;
    if Value < 1 then
      Value := 1;
    if Value <= FFixedCols then
      FFixedCols := Value - 1;
    ColCountChange(Value);
    ChangeSize(Value, RowCount);
    if (not FInLoadSaveMode) and liFlag then
      CreateViewsName;
  end;
end;

function TRMGridEx.GetColWidths(Index: Longint): Integer;
begin
  if (FColWidths = nil) or (Index >= ColCount) then
    Result := DefaultColWidth
  else
    Result := Round(RMFromMMThousandths(PIntArray(FColWidths)^[Index + 1], rmutScreenPixels));
end;

procedure TRMGridEx.SetColWidths(Index: Longint; Value: Integer);
var
  lmmValue: Integer;
begin
  if Value < 0 then Exit;
  if FColWidths = nil then
    UpdateExtents(FColWidths, ColCount, FmmDefaultColWidth);
  if Index >= ColCount then
    InvalidOp(SIndexOutOfRange);

  lmmValue := RMToMMThousandths(Value, rmutScreenPixels);
  if lmmValue <> PIntArray(FColWidths)^[Index + 1] then
  begin
    ResizeCol(Index, PIntArray(FColWidths)^[Index + 1], lmmValue);
    PIntArray(FColWidths)^[Index + 1] := lmmValue;
    ColWidthsChanged;
  end;
end;

function TRMGridEx.GetmmColWidths(Index: Longint): Integer;
begin
  if (FColWidths = nil) or (Index >= ColCount) then
    Result := FmmDefaultColWidth
  else
    Result := PIntArray(FColWidths)^[Index + 1];
end;

procedure TRMGridEx.SetmmColWidths(Index: Longint; Value: Integer);
begin
  if Value < 0 then Exit;
  if FColWidths = nil then
    UpdateExtents(FColWidths, ColCount, FmmDefaultColWidth);
  if Index >= ColCount then
    InvalidOp(SIndexOutOfRange);
  if Value <> PIntArray(FColWidths)^[Index + 1] then
  begin
    ResizeCol(Index, PIntArray(FColWidths)^[Index + 1], Value);
    PIntArray(FColWidths)^[Index + 1] := Value;
    ColWidthsChanged;
  end;
end;

procedure TRMGridEx.SetFixedColor(Value: TColor);
begin
  if FFixedColor <> Value then
  begin
    FFixedColor := Value;
    InvalidateGrid;
  end;
end;

function TRMGridEx.GetLeftCol: Longint;
begin
  Result := FTopLeft.X;
end;

procedure TRMGridEx.SetLeftCol(Value: Longint);
begin
  if FTopLeft.X <> Value then
    MoveTopLeft(Value, TopRow);
end;

function TRMGridEx.GetRow: Longint;
begin
  Result := FCurrent.Y;
end;

procedure TRMGridEx.SetRow(Value: Longint);
begin
  if Row <> Value then
    FocusCell(Col, Value, True);
end;

procedure TRMGridEx.ColCountChange(Value: Integer);
var
  i, j: Integer;
begin
  if (FCells = nil) or (Value < 1) then
    Exit;
  if Value > ColCount then
  begin
    for i := 0 to RowCount - 1 do
    begin
      for j := ColCount to Value - 1 do
        FCells.Items[i].Add(i, j, Self);
    end;
  end
  else
  begin
    for i := 0 to RowCount - 1 do
    begin
      for j := ColCount - 1 downto Value do
        FCells.Items[i].Delete(j);
    end;
  end;
end;

procedure TRMGridEx.RowCountChange(Value: Integer);
var
  i: Integer;
begin
  if FCells = nil then
    Exit;
  if Value > RowCount then
  begin
    for i := RowCount to Value - 1 do
      FCells.Add(i);
  end
  else
  begin
    for i := RowCount - 1 downto Value do
    begin
      FCells.Delete(i);
    end;
  end;
end;

procedure TRMGridEx.SetRowCount(Value: Longint);
var
  i, j: Integer;
  liFlag: Boolean;
begin
  if FRowCount = Value then Exit;

  if Value < RowCount then
  begin
    for i := 1 to ColCount - 1 do
    begin
      for j := Value to RowCount - 1 do
      begin
        if CellInMerge(i, j) then
          Exit;
      end;
    end;
  end;

  if FRowCount <> Value then
  begin
    liFlag := FRowCount < Value;
    if Value < 1 then
      Value := 1;
    if Value <= FFixedRows then
      FFixedRows := Value - 1;

    if Assigned(FOnAfterChangeRowCount) then
      FOnAfterChangeRowCount(Self, FRowCount, Value);

    RowCountChange(Value);
    ChangeSize(ColCount, Value);
    if (not FInLoadSaveMode) and liFlag then
      CreateViewsName;
  end;
end;

function TRMGridEx.GetRowHeights(Index: Longint): Integer;
begin
  if (FRowHeights = nil) or (Index >= RowCount) then
    Result := DefaultRowHeight
  else
    Result := Round(RMFromMMThousandths(PIntArray(FRowHeights)^[Index + 1], rmutScreenPixels));
end;

procedure TRMGridEx.SetRowHeights(Index: Longint; Value: Integer);
var
  lmmValue: Integer;
begin
  if Value < 0 then Exit;
  if FRowHeights = nil then
    UpdateExtents(FRowHeights, RowCount, FmmDefaultRowHeight);
  if Index >= RowCount then
    InvalidOp(SIndexOutOfRange);

  lmmValue := RMToMMThousandths(Value, rmutScreenPixels);
  if lmmValue <> PIntArray(FRowHeights)^[Index + 1] then
  begin
    ResizeRow(Index, PIntArray(FRowHeights)^[Index + 1], lmmValue);
    PIntArray(FRowHeights)^[Index + 1] := lmmValue;
    RowHeightsChanged;
  end;
end;

function TRMGridEx.GetmmRowHeights(Index: Longint): Integer;
begin
  if (FRowHeights = nil) or (Index >= RowCount) then
    Result := FmmDefaultRowHeight
  else
    Result := PIntArray(FRowHeights)^[Index + 1];
end;

procedure TRMGridEx.SetmmRowHeights(Index: Longint; Value: Integer);
begin
  if Value < 0 then Exit;
  if FRowHeights = nil then
    UpdateExtents(FRowHeights, RowCount, FmmDefaultRowHeight);
  if Index >= RowCount then
    InvalidOp(SIndexOutOfRange);
  if Value <> PIntArray(FRowHeights)^[Index + 1] then
  begin
    ResizeRow(Index, PIntArray(FRowHeights)^[Index + 1], Value);
    PIntArray(FRowHeights)^[Index + 1] := Value;
    RowHeightsChanged;
  end;
end;

function TRMGridEx.GetTopRow: Longint;
begin
  ;
  Result := FTopLeft.Y;
end;

procedure TRMGridEx.SetTopRow(Value: Longint);
begin
  if FTopLeft.Y <> Value then
    MoveTopLeft(LeftCol, Value);
end;

function TRMGridEx.GetDefaultColWidth: Integer;
begin
  Result := Round(RMFromMMThousandths(FmmDefaultColWidth, rmutScreenPixels));
end;

procedure TRMGridEx.SetDefaultColWidth(Value: Integer);
begin
  if FColWidths <> nil then
    UpdateExtents(FColWidths, 0, 0);
  FmmDefaultColWidth := RMToMMThousandths(Value, rmutScreenPixels);
  ColWidthsChanged;
  InvalidateGrid;
end;

function TRMGridEx.GetDefaultRowHeight: Integer;
begin
  Result := Round(RMFromMMThousandths(FmmDefaultRowHeight, rmutScreenPixels));
end;

procedure TRMGridEx.SetDefaultRowHeight(Value: Integer);
begin
  if FRowHeights <> nil then
    UpdateExtents(FRowHeights, 0, 0);
  FmmDefaultRowHeight := RMToMMThousandths(Value, rmutScreenPixels);
  RowHeightsChanged;
  InvalidateGrid;
end;

procedure TRMGridEx.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  if FAutoDraw then
    InvalidateRect(Selection);

  if (FInplaceEdit <> nil) and (Msg.FocusedWnd <> FInplaceEdit.Handle) then
    HideEditor;
end;

procedure TRMGridEx.WMLButtonDown(var Message: TMessage);
begin
  inherited;
  if FInplaceEdit <> nil then
    FInplaceEdit.FClickTime := GetMessageTime;
end;

procedure TRMGridEx.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  DefaultHandler(Msg);
  FHitTest := ScreenToClient(SmallPointToPoint(Msg.Pos));
end;

procedure TRMGridEx.WMSetCursor(var Msg: TWMSetCursor);
var
  lDrawInfo: TRMGridDrawInfo;
  lState: TRMGridState;
  lIndex: Longint;
  lPos, lOfs: Integer;
  lCur: HCURSOR;
begin
  lCur := 0;
  with Msg do
  begin
    if HitTest = HTCLIENT then
    begin
      if FGridState = rmgsNormal then
      begin
        CalcDrawInfo(lDrawInfo);
        CalcSizingState(FHitTest.X, FHitTest.Y, lState, lIndex, lPos, lOfs,
          lDrawInfo);
      end
      else
        lState := FGridState;

      if lState = rmgsRowSizing then
        lCur := Screen.Cursors[crVSplit]
      else if lState = rmgsColSizing then
        lCur := Screen.Cursors[crHSplit]
    end;
  end;

  if lCur <> 0 then
    SetCursor(lCur)
  else
    inherited;
end;

procedure TRMGridEx.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  if (FInplaceEdit = nil) or (Msg.FocusedWnd <> FInplaceEdit.Handle) then
  begin
    InvalidateRect(Selection);
    UpdateEdit;
  end;
end;

procedure TRMGridEx.WMSize(var Msg: TWMSize);
begin
  inherited;
  UpdateScrollRange;
end;

procedure TRMGridEx.WMVScroll(var Msg: TWMVScroll);
begin
  ModifyScrollBar(SB_VERT, Msg.ScrollCode, Msg.Pos, True);
end;

procedure TRMGridEx.WMHScroll(var Msg: TWMHScroll);
begin
  ModifyScrollBar(SB_HORZ, Msg.ScrollCode, Msg.Pos, True);
end;

procedure TRMGridEx.CancelMode;
var
  DrawInfo: TRMGridDrawInfo;
begin
  try
    case FGridState of
      rmgsSelecting:
        KillTimer(Handle, 1);
      rmgsRowSizing, rmgsColSizing:
        begin
          CalcDrawInfo(DrawInfo);
          DrawSizingLine(DrawInfo);
        end;
      rmgsColMoving, rmgsRowMoving:
        begin
          DrawMove;
          KillTimer(Handle, 1);
        end;
    end;
  finally
    FGridState := rmgsNormal;
  end;
end;

procedure TRMGridEx.WMCancelMode(var Msg: TWMCancelMode);
begin
  inherited;
  CancelMode;
end;

procedure TRMGridEx.CMCancelMode(var Msg: TMessage);
begin
  if Assigned(FInplaceEdit) then
    FInplaceEdit.WndProc(Msg);

  inherited;
  CancelMode;
end;

procedure TRMGridEx.CMFontChanged(var Message: TMessage);
begin
  if FInplaceEdit <> nil then
    FInplaceEdit.Font := Font;

  inherited;
end;

procedure TRMGridEx.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  RecreateWnd;
end;

procedure TRMGridEx.CMDesignHitTest(var Msg: TCMDesignHitTest);
begin
  Msg.Result := Longint(BOOL(Sizing(Msg.Pos.X, Msg.Pos.Y)));
end;

procedure TRMGridEx.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  if (rmgoEditing in Options) and (Char(Msg.CharCode) = #13) then
    Msg.Result := 1;
end;

procedure TRMGridEx.WMChar(var Msg: TWMChar);
begin
  if (rmgoEditing in Options) and (Char(Msg.CharCode) in [^H, #32..#255]) then
    ShowEditorChar(Char(Msg.CharCode))
  else
    inherited;
end;

procedure TRMGridEx.WMCommand(var Message: TWMCommand);
begin
  {  with Message do
    begin
      if (FInplaceEdit <> nil) and (Ctl = FInplaceEdit.Handle) then
        case NotifyCode of
          EN_CHANGE: UpdateText;
        end;
    end;}
end;

procedure TRMGridEx.WMEraseBkGnd(var Message: TWMCommand);
begin
  Message.Result := 1;
end;

procedure TRMGridEx.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
  if rmgoRowSelect in Options then Exit;
  if rmgoTabs in Options then Msg.Result := Msg.Result or DLGC_WANTTAB;
  if rmgoEditing in Options then Msg.Result := Msg.Result or DLGC_WANTCHARS;
end;

procedure TRMGridEx.TimedScroll(Direction: TRMGridScrollDirection);
var
  MaxAnchor, NewAnchor: TPoint;
begin
  NewAnchor := FAnchor;
  MaxAnchor.X := ColCount - 1;
  MaxAnchor.Y := RowCount - 1;
  if (rmsdLeft in Direction) and (FAnchor.X > FFixedCols) then
    Dec(NewAnchor.X);
  if (rmsdRight in Direction) and (FAnchor.X < MaxAnchor.X) then
    Inc(NewAnchor.X);
  if (rmsdUp in Direction) and (FAnchor.Y > FFixedRows) then
    Dec(NewAnchor.Y);
  if (rmsdDown in Direction) and (FAnchor.Y < MaxAnchor.Y) then
    Inc(NewAnchor.Y);
  if (FAnchor.X <> NewAnchor.X) or (FAnchor.Y <> NewAnchor.Y) then
    MoveAnchor(NewAnchor);
end;

procedure TRMGridEx.WMTimer(var Msg: TWMTimer);
var
  Point: TPoint;
  DrawInfo: TRMGridDrawInfo;
  ScrollDirection: TRMGridScrollDirection;
  CellHit: TPoint;
begin
  if not (FGridState in [rmgsSelecting, rmgsRowMoving, rmgsColMoving]) then
    Exit;
  GetCursorPos(Point);
  Point := ScreenToClient(Point);
  CalcDrawInfo(DrawInfo);
  ScrollDirection := [];
  with DrawInfo do
  begin
    CellHit := CalcCoordFromPoint(Point.X, Point.Y, DrawInfo);
    case FGridState of
      rmgsSelecting:
        begin
          if Point.X < Horz.FixedBoundary then
            Include(ScrollDirection, rmsdLeft)
          else if Point.X > Horz.FullVisBoundary then
            Include(ScrollDirection, rmsdRight);
          if Point.Y < Vert.FixedBoundary then
            Include(ScrollDirection, rmsdUp)
          else if Point.Y > Vert.FullVisBoundary then
            Include(ScrollDirection, rmsdDown);
          if ScrollDirection <> [] then
            TimedScroll(ScrollDirection);
        end;
    end;
  end;
end;

procedure TRMGridEx.ColWidthsChanged;
begin
  UpdateScrollRange;
end;

procedure TRMGridEx.RowHeightsChanged;
begin
  UpdateScrollRange;
end;

{$IFDEF COMPILER4_UP}

function TRMGridEx.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  if not Result then
  begin
    if Row < RowCount - 1 then
      Row := Row + 1;
    Result := True;
  end;
end;

function TRMGridEx.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
  if not Result then
  begin
    if Row > FFixedRows then
      Row := Row - 1;
    Result := True;
  end;
end;
{$ENDIF}

procedure TRMGridEx.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
    UpdateScrollRange;
end;

procedure TRMGridEx.MoveColumn(FromIndex, ToIndex: Longint);
var
  Rect: TRect;
begin
  if FromIndex = ToIndex then Exit;
  if Assigned(FColWidths) then
  begin
    MoveExtent(FColWidths, FromIndex + 1, ToIndex + 1);
  end;
  MoveAdjust(FCurrent.X, FromIndex, ToIndex);
  MoveAdjust(FAnchor.X, FromIndex, ToIndex);
  MoveAdjust(FInplaceCol, FromIndex, ToIndex);
  Rect.Top := 0;
  Rect.Bottom := VisibleRowCount;
  if FromIndex < ToIndex then
  begin
    Rect.Left := FromIndex;
    Rect.Right := ToIndex;
  end
  else
  begin
    Rect.Left := ToIndex;
    Rect.Right := FromIndex;
  end;
  if Assigned(FColWidths) then
    ColWidthsChanged;
end;

procedure TRMGridEx.MoveRow(FromIndex, ToIndex: Longint);
begin
  if FromIndex = ToIndex then Exit;
  if Assigned(FRowHeights) then
    MoveExtent(FRowHeights, FromIndex + 1, ToIndex + 1);
  MoveAdjust(FCurrent.Y, FromIndex, ToIndex);
  MoveAdjust(FAnchor.Y, FromIndex, ToIndex);
  MoveAdjust(FInplaceRow, FromIndex, ToIndex);
  if Assigned(FRowHeights) then
    RowHeightsChanged;
end;

procedure TRMGridEx.RestoreCells(aDestRestoreRect: TRect);
var
  i, j: Integer;
begin
  Restrict(TPoint(aDestRestoreRect.TopLeft), 1, 1, ColCount - 1, RowCount - 1);
  Restrict(TPoint(aDestRestoreRect.BottomRight), 1, 1, ColCount - 1, RowCount - 1);
  for i := aDestRestoreRect.Left to aDestRestoreRect.Right do
  begin
    for j := aDestRestoreRect.Top to aDestRestoreRect.Bottom do
      InitCell(Self, Cells[i, j], i, j);
  end;
  InvalidateRect(TRect(aDestRestoreRect));
end;

procedure TRMGridEx.InitCell(AGrid: TRMGridEx; ACell: TRMCellInfo; ACol, ARow: Integer);
begin
  with ACell do
  begin
    Text := '';
    View.LeftFrame.Visible := True;
    View.TopFrame.Visible := True;
    View.RightFrame.Visible := True;
    View.BottomFrame.Visible := True;
    AutoWordBreak := False;
    HAlign := rmHCenter;
    VAlign := rmVCenter;
    if (ACol = 0) or (ARow = 0) then
      FillColor := AGrid.FTitleColor
    else
      FillColor := clNone;
    FStartCol := ACol;
    FEndCol := ACol;
    FStartRow := ARow;
    FEndRow := ARow;
    FFont.Assign(Self.Font);
    Font.Assign(Self.Font);
  end;
end;

function TRMGridEx.CellInMerge(ACol, ARow: Integer): Boolean;
begin
  Result := False;
  if ((Cells[ACol, ARow].StartCol <> Cells[ACol, ARow].EndCol) or
    (Cells[ACol, ARow].StartRow <> Cells[ACol, ARow].EndRow)) then
    Result := True;
end;

function TRMGridEx.GetCell(ACol, ARow: Integer): TRMCellInfo;
begin
  if (ACol < FColCount) and (ARow < FRowCount) then
    Result := FCells.Items[ARow].Items[ACol]
  else
    Result := nil;
end;

function TRMGridEx.GetMerges(ACol, ARow: Integer): TRect;
var
  lCell: TRMCellInfo;
begin
  lCell := Cells[aCol, aRow];
  Result := Rect(lCell.FStartCol, lCell.FStartRow, lCell.FEndCol, lCell.FEndRow);
end;

procedure TRMGridEx.MergeCell(aFirstCol, aFirstRow, aEndCol, aEndRow: Integer);
var
  lMergedCell, lFirstCell, lEndCell: TRMCellInfo;
  lCol, lRow: Integer;
begin
  lFirstCell := Cells[aFirstCol, aFirstRow];
  lEndCell := Cells[aEndCol, aEndRow];
  lMergedCell := TRMCellInfo.Create;
  try
    lMergedCell.ParentReport := ParentReport;
    lMergedCell.Assign(lFirstCell);
    lMergedCell.FStartCol := Min(lFirstCell.StartCol, lEndCell.StartCol);
    lMergedCell.FEndCol := Max(lFirstCell.EndCol, lEndCell.EndCol);
    lMergedCell.FStartRow := Min(lFirstCell.StartRow, lEndCell.Startrow);
    lMergedCell.FendRow := Max(lFirstCell.EndRow, lEndCell.Endrow);

    lMergedCell.MutilCell := not ((lMergedCell.StartCol = lMergedCell.endCol) and
      (lMergedCell.StartRow = lMergedCell.EndRow));
    for lCol := lMergedCell.StartCol to lMergedCell.EndCol do
    begin
      for lRow := lMergedCell.StartRow to lMergedCell.EndRow do
      begin
        Cells[lCol, lRow].Assign(lMergedCell);
      end;
    end;
  finally
    lMergedCell.Free;
  end;

  InvalidateGrid;
end;

procedure TRMGridEx.MergeSelection;
var
  liRect: TRect;
begin
  liRect := Selection;
  MergeCell(liRect.left, liRect.Top, liRect.right, liRect.Bottom)
end;

procedure TRMGridEx.SplitCell(aFirstCol, aFirstRow, aEndCol, aEndRow: Integer);
var
  lCol, lrow: integer;
  lCell: TRMCellInfo;
  lFlag: Boolean;
begin
  lFlag := False;
  for lCol := aFirstCol to aEndCol do
  begin
    for lRow := aFirstRow to aEndRow do
    begin
      lCell := Cells[lCol, lRow];
      if (lCell.FStartCol <> lCell.FEndCol) or (lCell.FStartRow <> lCell.FEndRow) then
      begin
        lCell.FStartCol := lCol;
        lCell.FEndCol := lCol;
        lCell.FStartRow := lRow;
        lCell.FEndRow := lRow;
        lCell.MutilCell := False;
        lCell.View.Name := '';
        if (lCell.FStartCol <> aFirstCol) or (lCell.FStartRow <> aFirstRow) then
          lCell.ReCreateView(rmgtMemo, '');
        lFlag := True;
      end;
    end;
  end;

  if lFlag then
  begin
    CreateViewsName;
    InvalidateGrid;
  end;
end;

procedure TRMGridEx.MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
var
  Coord: TPoint;
begin
  Coord := MouseCoord(X, Y);
  ACol := Coord.X;
  ARow := Coord.Y;
end;

procedure TRMGridEx.CopyCellsToBuffer(aRect: TRect; aStream: TStream); // 从缓冲区中粘贴 Cells 内容
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
begin
  Restrict(aRect.TopLeft, 1, 1, ColCount - 1, RowCount - 1);
  Restrict(aRect.BottomRight, 1, 1, ColCount - 1, RowCount - 1);

  RMWriteInt32(aStream, aRect.Left);
  RMWriteInt32(aStream, aRect.Top);
  RMWriteInt32(aStream, aRect.Right - aRect.Left);
  RMWriteInt32(aStream, aRect.Bottom - aRect.Top);
  for lCol := aRect.Left to aRect.Right do
    RMWriteInt32(aStream, mmColWidths[lCol]);
  for lRow := aRect.Top to aRect.Bottom do
    RMWriteInt32(aStream, mmRowHeights[lRow]);

  for lCol := aRect.Left to aRect.Right do
  begin
    for lRow := aRect.Top to aRect.Bottom do
    begin
      lCell := Cells[lCol, lRow];
      if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
        WriteCellToBuffer(lCell, aStream);
    end;
  end;
end;

procedure TRMGridEx.PasteCellsFromBuffer(aRect: TRect; aStream: TStream);
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
  lColCount, lRowCount: Integer;
  lXOffset, lYOffset: Integer;
  lStartPoint: TPoint;
begin
  Restrict(aRect.TopLeft, 1, 1, ColCount - 1, RowCount - 1);
  Restrict(aRect.BottomRight, 1, 1, ColCount - 1, RowCount - 1);

  lStartPoint.X := RMReadInt32(aStream);
  lStartPoint.Y := RMReadInt32(aStream);
  lXOffset := aRect.Left - lStartPoint.X;
  lYOffset := aRect.Top - lStartPoint.Y;
  lColCount := RMReadInt32(aStream);
  lRowCount := RMReadInt32(aStream);
  for lCol := aRect.Left to aRect.Left + lColCount do
    mmColWidths[lCol] := RMReadInt32(aStream);
  for lRow := aRect.Top to aRect.Top + lRowCount do
    mmRowHeights[lRow] := RMReadInt32(aStream);

  for lCol := aRect.Left to aRect.Left + lColCount do
  begin
    for lRow := aRect.Top to aRect.Top + lRowCount do
    begin
      InitCell(Self, Cells[lCol, lRow], lCol, lRow);
    end;
  end;

  for lCol := aRect.Left to aRect.Left + lColCount do
  begin
    for lRow := aRect.Top to aRect.Top + lRowCount do
    begin
      lCell := Cells[lCol, lRow];
      if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
      begin
        ReadCellFromBuffer(lCell, aStream, lXOffset, lYOffset);
      end;
    end;
  end;
end;

procedure TRMGridEx.InsertRow(aRow: Integer; aCreateName: Boolean);

  procedure _MoveRows(aStartRow, aEndRow: Integer);
  var
    lCol, lRow: Integer;
    lSaveCell: TRMCellInfo;

    procedure _MoveOneCell(ACell: TRMCellInfo; aDestCol, aDestRow: Integer;
      aAdjustMerge: Boolean);
    begin
      FCells.Items[aDestRow].FList[aDestCol] := ACell;
      if aAdjustMerge then
      begin
        Inc(ACell.FStartRow, 1);
        Inc(ACell.FEndRow, 1);
      end;
    end;

  begin
    for lCol := 1 to ColCount - 1 do
    begin
      lSaveCell := Cells[lCol, aEndRow];
      lSaveCell.Assign(Cells[lCol, aStartRow]);
      for lRow := aEndRow - 1 downto aStartRow do
        _MoveOneCell(Cells[lCol, lRow], lCol, lRow + 1, True);

      lSaveCell.View.Name := '';
      _MoveOneCell(lSaveCell, lCol, aStartRow, False);
    end;
  end;

  procedure _ExpandMerges;
  var
    liCol, i, j: Integer;
    liCellRect: TRect;
    liCell: TRMCellInfo;
    liEndRow: Integer;
  begin
    liCol := 1;
    while liCol < ColCount do
    begin
      liCell := Cells[liCol, ARow];
      liCellRect := GridRect(Point(liCol, ARow), Point(liCol, ARow));
      if (liCell.StartRow <> liCell.EndRow) and (liCell.StartRow < ARow) then
      begin
        liEndRow := liCell.EndRow + 1;
        for i := liCell.StartCol to liCell.EndCol do
        begin
          for j := liCell.StartRow to liEndRow do
          begin
            Cells[i, j].FStartCol := liCell.StartCol;
            Cells[i, j].FEndCol := liCell.EndCol;
            Cells[i, j].FStartRow := liCell.StartRow;
            Cells[i, j].FEndRow := liEndRow;
          end;
        end;
        liCol := liCell.EndCol;
      end
      else
        RestoreCells(TRect(liCellRect));
      Inc(liCol);
    end;
  end;

begin
  if (ARow >= RowCount) or (ARow < 0) then
    Exit;

  if Assigned(FOnAfterInsertRow) then
    FOnAfterInsertRow(Self, aRow);

  FAutoDraw := False;
  RowCount := RowCount + 1;
  MoveRow(RowCount - 1, ARow);
  _MoveRows(ARow, RowCount - 1);
  _ExpandMerges;
  if aCreateName then
    CreateViewsName;

  FAutoDraw := True;
  if aCreateName then
    InvalidateGrid;
end;

procedure TRMGridEx.InsertColumn(aCol: Integer; aCreateName: Boolean);

  procedure _MoveCols(aStartCol, aEndCol: Integer);
  var
    lCol, lRow: Integer;
    lSaveCell: TRMCellInfo;

    procedure _MoveOneCell(ACell: TRMCellInfo; aDestCol, aDestRow: Integer;
      aAdjustMerge: Boolean);
    begin
      FCells.Items[aDestRow].FList[aDestCol] := ACell;
      if aAdjustMerge then
      begin
        Inc(ACell.FStartCol, 1);
        Inc(ACell.FEndCol, 1);
      end;
    end;

  begin
    for lRow := 1 to RowCount - 1 do
    begin
      lSaveCell := Cells[aEndCol, lRow];
      lSaveCell.Assign(Cells[aStartCol, lRow]);
      for lCol := aEndCol - 1 downto aStartCol do
        _MoveOneCell(Cells[lCol, lRow], lCol + 1, lRow, True);

      lSaveCell.View.Name := '';
      _MoveOneCell(lSaveCell, aStartCol, lRow, False);
    end;
  end;

  procedure _ExpandMerges;
  var
    liRow, i, j: Integer;
    liCellRect: TRect;
    liCell: TRMCellInfo;
    liEndCol: Integer;
  begin
    liRow := 1;
    while liRow < RowCount do
    begin
      liCell := Cells[ACol, liRow];
      liCellRect := GridRect(Point(ACol, liRow), Point(ACol, liRow));
      if (liCell.StartCol <> liCell.EndCol) and (liCell.StartCol < ACol) then
      begin
        liEndCol := liCell.EndCol + 1;
        for i := liCell.StartCol to liEndCol do
        begin
          for j := liCell.StartRow to liCell.EndRow do
          begin
            Cells[i, j].FStartCol := liCell.StartCol;
            Cells[i, j].FEndCol := liEndCol;
            Cells[i, j].FStartRow := liCell.StartRow;
            Cells[i, j].FEndRow := liCell.EndRow;
          end;
        end;
        liRow := liCell.EndRow;
      end
      else
        RestoreCells(TRect(liCellRect));
      Inc(liRow);
    end;
  end;

begin
  if (ACol >= ColCount) or (ACol < FFixedCols) then
    Exit;

  FAutoDraw := False;
  ColCount := ColCount + 1;
  MoveColumn(ColCount - 1, ACol);
  _MoveCols(ACol, ColCount - 1);
  _ExpandMerges;
  if aCreateName then
    CreateViewsName;

  FAutoDraw := True;
  if aCreateName then
    InvalidateGrid;
end;

procedure TRMGridEx.DeleteColumn(ACol: Integer; aRefresh: Boolean);

  procedure _MoveCols(StartCol, EndCol: Integer);
  var
    liCol, liRow: Integer;
    liSaveCell: TRMCellInfo;

    procedure _MoveOneCell(ACell: TRMCellInfo; DestCol, DestRow: Integer; AdjustMerge: Boolean);
    begin
      FCells.Items[DestRow].FList[DestCol] := ACell;
      if AdjustMerge then
      begin
        Dec(ACell.FStartCol, 1);
        Dec(ACell.FEndCol, 1);
      end;
    end;

  begin
    for liRow := 1 to RowCount - 1 do
    begin
      liSaveCell := Cells[StartCol, liRow];
      for liCol := StartCol + 1 to EndCol do
        _MoveOneCell(Cells[liCol, liRow], liCol - 1, liRow, True);
      _MoveOneCell(liSaveCell, EndCol, liRow, False);
    end;
  end;

  procedure _ReduceMerges;
  var
    liRow, i: Integer;
    liCell: TRMCellInfo;
    liStartCol, liEndCol: INteger;
  begin
    liRow := 1;
    while liRow < RowCount do
    begin
      liCell := Cells[ACol, liRow];
      if liCell.StartCol < ACol then
      begin
        liStartCol := liCell.StartCol;
        liEndCol := liCell.EndCol;
        for i := liStartCol to ACol - 1 do
        begin
          if liEndCol <= ACol then
            Cells[i, liRow].FEndCol := ACol - 1
          else
            Dec(Cells[i, liRow].FEndCol, 1);
        end;
      end;

      liCell := Cells[ACol, liRow];
      if liCell.EndCol > ACol then
      begin
        liStartCol := liCell.StartCol;
        liEndCol := liCell.EndCol;
        for i := ACol + 1 to liEndCol do
        begin
          if liStartCol >= ACol then
            Cells[i, liRow].FStartCol := ACol + 1
          else
            Inc(Cells[i, liRow].FStartCol, 1);
        end;
      end;
      Inc(liRow);
    end;
  end;

begin
  if (ACol < 1) or (ACol >= ColCount) or (ColCount < 3) then
    Exit;

  FAutoDraw := False;
  _ReduceMerges;
  RestoreCells(Rect(ACol, 1, ACol, RowCount - 1));
  _MoveCols(ACol, ColCount - 1);

  MoveColumn(ACol, ColCount - 1);
  Col := Min(ACol, ColCount - 2);
  ColCount := ColCount - 1;

  FAutoDraw := True;
  if aRefresh then
    InvalidateGrid;
end;

procedure TRMGridEx.DeleteRow(ARow: Integer; aRefresh: Boolean);

  procedure _MoveRows(StartRow, EndRow: Integer);
  var
    liCol, liRow: Integer;
    liSaveCell: TRMCellInfo;

    procedure _MoveOneCell(ACell: TRMCellInfo; DestCol, DestRow: Integer; AdjustMerge: Boolean);
    begin
      FCells.Items[DestRow].FList[DestCol] := ACell;
      if AdjustMerge then
      begin
        Dec(ACell.FStartRow, 1);
        Dec(ACell.FEndRow, 1);
      end;
    end;

  begin
    for liCol := 1 to ColCount - 1 do
    begin
      liSaveCell := Cells[liCol, StartRow];
      for liRow := StartRow + 1 to EndRow do
        _MoveOneCell(Cells[liCol, liRow], liCol, liRow - 1, True);
      _MoveOneCell(liSaveCell, liCol, EndRow, False);
    end;
  end;

  procedure _ReduceMerges;
  var
    liCol, i: Integer;
    liCell: TRMCellInfo;
    liStartRow, liEndRow: Integer;
  begin
    liCol := 1;
    while liCol < ColCount do
    begin
      liCell := Cells[liCol, ARow];
      if liCell.StartRow < ARow then
      begin
        liStartRow := liCell.StartRow;
        liEndRow := liCell.EndRow;
        for i := liStartRow to ARow - 1 do
        begin
          if liEndRow <= ARow then
            Cells[liCol, i].FEndRow := ARow - 1
          else
            Dec(Cells[liCol, i].FEndRow, 1);
        end;
      end;

      liCell := Cells[liCol, ARow];
      if liCell.EndRow > ARow then
      begin
        liStartRow := liCell.StartRow;
        liEndRow := liCell.EndRow;
        for i := ARow + 1 to liEndRow do
        begin
          if liStartRow >= ARow then
            Cells[liCol, i].FStartRow := ARow + 1
          else
            Inc(Cells[liCol, i].FStartRow, 1);
        end;
      end;
      Inc(liCol);
    end;
  end;

begin
  if (ARow < 1) or (ARow >= RowCount) or (RowCount < 3) then
    Exit;

  if Assigned(FOnAfterDeleteRow) then
    FOnAfterDeleteRow(Self, aRow);

  FAutoDraw := False;
  _ReduceMerges;
  RestoreCells(Rect(1, ARow, ColCount - 1, ARow));
  _MoveRows(ARow, RowCount - 1);

  MoveRow(ARow, RowCount - 1);
  Row := Min(ARow, RowCount - 2);
  RowCount := RowCount - 1;

  FAutoDraw := True;
  if aRefresh then
    InvalidateGrid;
end;

procedure TRMGridEx.InsertCellRight(aInsertRect: TRect); // 向右插入一个网格
var
  lInsertWidth: Integer;
  lRect: TRect;
  lStream: TMemoryStream;

  function _CanInsert: Boolean; // 如果将要丢弃的网格内容不为空,或者存在合并区域,则不能插入
  var
    i, j: Integer;
  begin
    Result := False;
    for i := ColCount - lInsertWidth to ColCount - 1 do
    begin
      for j := aInsertRect.Top to aInsertRect.Bottom do
      begin
        if (Cells[i, j].Text <> '') or
          (CellInMerge(i, j)) then
          Exit;
      end;
    end;

    Result := True;
  end;

  function _FindMerge: Boolean; // 向右查找超出范围的合并区域
  var
    i: Integer;
  begin
    Result := False;
    for i := aInsertRect.Right + 1 to ColCount - 1 do
      if (Cells[i, aInsertRect.Top].StartRow < aInsertRect.Top) or
        (Cells[i, aInsertRect.Bottom].EndRow > aInsertRect.Bottom) then
      begin
        Result := True;
        Exit;
      end;
  end;

  procedure _DeleteAnyMerges; // 如果发现任何超出范围的合并区域,则将其拆散
  var
    i: Integer;
    lCell: TRMCellInfo;
  begin
    // 拆散顶部超出范围的合并区域
    i := aInsertRect.Right + 1;
    while i < ColCount do
    begin
      lCell := Cells[i, aInsertRect.Top];
      if (lCell.StartRow < aInsertRect.Top) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndCol;
      end;
      Inc(i);
    end;

    // 拆散底部超出范围的合并区域
    i := aInsertRect.Right + 1;
    while i < ColCount do
    begin
      lCell := Cells[i, aInsertRect.Bottom];
      if (lCell.EndRow > aInsertRect.Bottom) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndCol;
      end;
      Inc(i);
    end;
  end;

  //const
    //CannotRemoveRightMostCells = '为了防止数据丢失,表格中最右侧的非空白单元格不能被移去。' + #13 + #10 + #13 + #10 +
    //  '请清除该非空白单元格的内容,或将数据移到新的位置后再尝试。';
    //DoYouWantDeleteMergedCells = '此操作将会导致一些合并单元格被拆散,是否继续?';

begin
  lInsertWidth := aInsertRect.Right - aInsertRect.Left + 1;
  if not _CanInsert then
  begin
    //Application.MessageBox(CannotRemoveRightMostCells, PChar(RMLoadStr(SError)),
    //  mb_Ok + mb_IconError);
    //Exit;
  end;

  if _FindMerge then
  begin
    //if Application.MessageBox(CannotRemoveRightMostCells, PChar(RMLoadStr(SError)),
    //  mb_IconQuestion + mb_YesNo) = mrYes then
    _DeleteAnyMerges
      //else
//  Exit;
  end;

  lStream := TMemoryStream.Create;
  try
    lRect := aInsertRect;
    lRect.Right := ColCount - lInsertWidth - 1;
    CopyCellsToBuffer(lRect, lStream);
    Inc(lRect.Left, lInsertWidth);
    Inc(lRect.Right, lInsertWidth);

    lStream.Position := 0;
    PasteCellsFromBuffer(lRect, lStream);
    RestoreCells(aInsertRect);

    lRect := aInsertRect;
    lRect.Right := ColCount - 1;
    InvalidateRect(lRect);
  finally
    lStream.Free;
  end;
end;

procedure TRMGridEx.InsertCellDown(aInsertRect: TRect); // 向下插入一个网格
var
  lInsertHeight: Integer;
  lRect: TRect;
  lStream: TMemoryStream;

  function _CanInsert: Boolean; // 如果将要丢弃的网格内容不为空,或者存在合并区域,则不能插入
  var
    i, j: Integer;
  begin
    Result := False;
    for i := aInsertRect.Left to aInsertRect.Right do
    begin
      for j := RowCount - lInsertHeight to RowCount - 1 do
      begin
        if (Cells[i, j].Text <> '') or
          (CellInMerge(i, j)) then
          Exit;
      end;
    end;
    Result := True;
  end;

  function _FindMerge: Boolean; // 向下查找超出范围的合并区域
  var
    i: Integer;
  begin
    Result := False;
    for i := aInsertRect.Bottom + 1 to RowCount - 1 do
      if (Cells[aInsertRect.Left, i].StartCol < aInsertRect.Left) or
        (Cells[aInsertRect.Right, i].EndCol > aInsertRect.Right) then
      begin
        Result := True;
        Exit;
      end;
  end;

  procedure _DeleteAnyMerges; // 如果发现任何超出范围的合并区域,则将其拆散
  var
    i: Integer;
    lCell: TRMCellInfo;
  begin
    i := aInsertRect.Bottom + 1;
    while i < RowCount do
    begin
      lCell := Cells[aInsertRect.Left, i];
      if (lCell.StartCol < aInsertRect.Left) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndRow;
      end;
      Inc(i);
    end;

    i := aInsertRect.Bottom + 1;
    while i < RowCount do
    begin
      lCell := Cells[aInsertRect.Right, i];
      if (lCell.EndCol > aInsertRect.Right) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndRow;
      end;
      Inc(i);
    end;
  end;

begin
  lInsertHeight := aInsertRect.Bottom - aInsertRect.Top + 1;
  if not _CanInsert then
  begin
    //SayStop(CannotRemoveBottomMostCells);
    //Exit;
  end;

  if _FindMerge then
  begin
    //if Ask(DoYouWantDeleteMergedCells,2) then
    _DeleteAnyMerges;
    //else
  //  Exit;
  end;

  lStream := TMemoryStream.Create;
  try
    lRect := aInsertRect;
    lRect.Bottom := RowCount - lInsertHeight - 1;
    CopyCellsToBuffer(lRect, lStream);

    lStream.Position := 0;
    Inc(lRect.Top, lInsertHeight);
    Inc(lRect.Bottom, lInsertHeight);
    PasteCellsFromBuffer(lRect, lStream);
    RestoreCells(aInsertRect);

    lRect := aInsertRect;
    lRect.Bottom := RowCount - 1;
    InvalidateRect(lRect);
  finally
    lStream.Free;
  end;
end;

procedure TRMGridEx.DeleteCellRight(aDeleteRect: TRect); // 向右删除一个网格
var
  lDeleteWidth: Integer;
  lRect: TRect;
  lStream: TMemoryStream;

  function _FindMerge: Boolean; // 向右查找超出范围的合并区域
  var
    i: Integer;
  begin
    Result := False;
    for i := aDeleteRect.Right + 1 to ColCount - 1 do
    begin
      if (Cells[i, aDeleteRect.Top].StartRow < aDeleteRect.Top) or
        (Cells[i, aDeleteRect.Bottom].EndRow > aDeleteRect.Bottom) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  procedure _DeleteAnyMerges; // 如果发现任何超出范围的合并区域,则将其拆散
  var
    i: Integer;
    lCell: TRMCellInfo;
  begin
    i := aDeleteRect.Right + 1;
    while i < ColCount do
    begin
      lCell := Cells[i, aDeleteRect.Top];
      if (lCell.StartRow < aDeleteRect.Top) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndCol;
      end;
      Inc(i);
    end;

    i := aDeleteRect.Right + 1;
    while i < ColCount do
    begin
      lCell := Cells[i, aDeleteRect.Bottom];
      if (lCell.EndRow > aDeleteRect.Bottom) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndCol;
      end;
      Inc(i);
    end;
  end;

begin
  lDeleteWidth := aDeleteRect.Right - aDeleteRect.Left + 1;

  if _FindMerge then
  begin
    //if Ask(DoYouWantDeleteMergedCells, 2) then
    _DeleteAnyMerges;
    //else
    //  Exit;
  end;

  lStream := TMemoryStream.Create;
  try
    lRect := TRect(aDeleteRect);
    lRect.Left := lRect.Right + 1;
    lRect.Right := ColCount - 1;
    CopyCellsToBuffer(lRect, lStream);

    lStream.Position := 0;
    Dec(lRect.Left, lDeleteWidth);
    Dec(lRect.Right, lDeleteWidth);
    PasteCellsFromBuffer(lRect, lStream);
    lRect.Left := ColCount - lDeleteWidth + 1;
    lRect.Right := ColCount - 1;
    RestoreCells(TRect(lRect));

    lRect := TRect(aDeleteRect);
    lRect.Right := ColCount - 1;
    InvalidateRect(lRect);
  finally
    lStream.Free;
  end;
end;

procedure TRMGridEx.DeleteCellDown(aDeleteRect: TRect); // 向下删除一个网格
var
  lDeleteHeight: Integer;
  lRect: TRect;
  lStream: TMemoryStream;

  function _FindMerge: Boolean; // 向下查找超出范围的合并区域
  var
    i: Integer;
  begin
    Result := False;
    for i := aDeleteRect.Bottom + 1 to RowCount - 1 do
    begin
      if (Cells[aDeleteRect.Left, i].StartCol < aDeleteRect.Left) or
        (Cells[aDeleteRect.Right, i].EndCol > aDeleteRect.Right) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  procedure _DeleteAnyMerges; // 如果发现任何超出范围的合并区域,则将其拆散
  var
    i: Integer;
    lCell: TRMCellInfo;
  begin
    i := aDeleteRect.Bottom + 1;
    while i < RowCount do
    begin
      lCell := Cells[aDeleteRect.Left, i];
      if (lCell.StartCol < aDeleteRect.Left) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndRow;
      end;
      Inc(i);
    end;

    i := aDeleteRect.Bottom + 1;
    while i < RowCount do
    begin
      lCell := Cells[aDeleteRect.Right, i];
      if (lCell.EndCol > aDeleteRect.Right) then
      begin
        SplitCell(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        i := lCell.EndRow;
      end;
      Inc(i);
    end;
  end;

begin
  AutoCreateName := False;
  lStream := nil;
  lDeleteHeight := aDeleteRect.Bottom - aDeleteRect.Top + 1;
  try
    if _FindMerge then
    begin
      //if Ask(DoYouWantDeleteMergedCells, 2) then
      _DeleteAnyMerges;
      //else
      //  Exit;
    end;

    lStream := TMemoryStream.Create;
    lRect := TRect(aDeleteRect);
    lRect.Top := aDeleteRect.Bottom + 1;
    lRect.Bottom := RowCount - 1;
    CopyCellsToBuffer(lRect, lStream);

    lStream.Position := 0;
    Dec(lRect.Top, lDeleteHeight);
    Dec(lRect.Bottom, lDeleteHeight);
    PasteCellsFromBuffer(lRect, lStream);
    lRect.Top := RowCount - lDeleteHeight + 1;
    lRect.Bottom := RowCount - 1;
    RestoreCells(TRect(lRect));

    lRect := TRect(aDeleteRect);
    lRect.Bottom := RowCount - 1;
    InvalidateRect(lRect);
  finally
    lStream.Free;
    AutoCreateName := True;
  end;
end;

function TRMGridEx.CanCut: Boolean;
begin
  Result := True;
end;

function TRMGridEx.CanCopy: Boolean;
begin
  Result := True;
end;

function TRMGridEx.CanPaste: Boolean;
var
  hMem: THandle;
begin
  Result := False;
  ClipBoard.Open;
  try
    hMem := Clipboard.GetAsHandle(CF_RMGridCopyFormat);
    if hMem > 0 then
      Result := True;
  finally
    ClipBoard.Close;
  end;
end;

procedure TRMGridEx.GetClipBoardInfo(aStream: TStream; var aStartCell, aSize: TPoint);
begin
  aStream.Position := 0;
  aStartCell.X := RMReadInt32(aStream);
  aStartCell.Y := RMReadInt32(aStream);
  aSize.X := RMReadInt32(aStream);
  aSize.Y := RMReadInt32(aStream);
  aStream.Position := 0;
end;

function TRMGridEx.CalcMaxRange(aDestRect: TRect): TRect; // 计算新的选择范围
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
  lRowCount, lColCount: Integer;
begin
  Result := aDestRect;
  lRowCount := Min(aDestRect.Bottom, RowCount - 1);
  lColCount := Min(aDestRect.Right, ColCount - 1);
  for lRow := aDestRect.Top to lRowCount do
  begin
    lCol := aDestRect.Left;
    while lCol <= lColCount do
    begin
      lCell := Cells[lCol, lRow];
      if lCell.StartRow = lRow then
      begin
        Result.Left := Min(Result.Left, lCell.StartCol);
        Result.Right := Max(Result.Right, lCell.EndCol);
        Result.Top := Min(Result.Top, lCell.StartRow);
        Result.Bottom := Max(Result.Bottom, lCell.EndRow);
      end;

      lCol := lCell.EndCol + 1;
    end;
  end;
end;

function TRMGridEx.MergeRectIntersects(aDestRect: TRect): Boolean;
var
  lMaxRange: TRect;
begin
  Result := False;
  lMaxRange := CalcMaxRange(aDestRect);
  if (lMaxRange.Left < aDestRect.Left) or
    (lMaxRange.Top < aDestRect.Top) or
    (lMaxRange.Right > aDestRect.Right) or
    (lMaxRange.Bottom > aDestRect.Bottom) then
    Result := True;
end;

function TRMGridEx.CanPasteToRect(aDestRect: TRect): Boolean;
begin
  Result := True;
  if MergeRectIntersects(aDestRect) then
    Result := False;
end;

procedure TRMGridEx.CopyCells(aDestCopyRect: TRect);
var
  lStream: TMemoryStream;
  hMem: THandle;
  pMem: pointer;
begin
  lStream := TMemoryStream.Create;
  try
    CopyCellsToBuffer(aDestCopyRect, lStream);
    ClipBoard.Open;
    try
      lStream.Position := 0;
      hMem := GlobalAlloc(GMEM_MOVEABLE + GMEM_SHARE + GMEM_ZEROINIT, lStream.Size);
      if hMem <> 0 then
      begin
        pMem := GlobalLock(hMem);
        if pMem <> nil then
        begin
          CopyMemory(pMem, lStream.Memory, lStream.Size);
          GlobalUnLock(hMem);
          ClipBoard.SetAsHandle(CF_RMGridCopyFormat, hMem);
        end;
      end;
    finally
      //      GlobalFree(hMem);
      ClipBoard.Close;
    end;
  finally
    lStream.Free;
  end;
end;

procedure TRMGridEx.CutCells(aDestCutRect: TRect);
begin
  CopyCells(aDestCutRect);
  RestoreCells(aDestCutRect);
end;

procedure TRMGridEx.PasteCells(aDestPasteCoord: TPoint);
var
  lPasteRect: TRect;
  lStartCell, lSize: TPoint;
  lStream: TMemoryStream;
  hMem: THandle;
  pMem: pointer;
  hSize: DWORD;
  lRow, lCol: Integer;
  lCell: TRMCellInfo;
begin
  lStream := nil;
  ClipBoard.Open;
  try
    hMem := Clipboard.GetAsHandle(CF_RMGridCopyFormat);
    pMem := GlobalLock(hMem);
    if pMem <> nil then
    begin
      hSize := GlobalSize(hMem);
      try
        lStream := TMemoryStream.Create;
        lStream.Write(pMem^, hSize);
        lStream.Position := 0;
      finally
        GlobalUnlock(hMem);
      end;
    end;
  finally
    ClipBoard.Close;
  end;

  if lStream = nil then Exit;

  try
    GetClipBoardInfo(lStream, lStartCell, lSize);
    lPasteRect.Left := aDestPasteCoord.X;
    lPasteRect.Top := aDestPasteCoord.Y;
    lPasteRect.Right := lPasteRect.Left + lSize.X;
    lPasteRect.Bottom := lPasteRect.Top + lSize.Y;
    if CanPasteToRect(lPasteRect) then
    begin
      if Col + lSize.X + 1 > ColCount then
        ColCount := Col + lSize.X + 1;
      if Row + lSize.Y + 1 > RowCount then
        RowCount := Row + lSize.Y + 1;

      PasteCellsFromBuffer(lPasteRect, lStream);
      for lRow := lPasteRect.Top to lPasteRect.Bottom do
      begin
        lCol := lPasteRect.Left;
        while lCol <= lPasteRect.Right do
        begin
          lCell := Cells[lCol, lRow];
          lCell.View.Name := '';

          lCol := lCell.EndCol + 1;
        end;
      end;

      CreateViewsName;
      Selection := lPasteRect;
      InvalidateRect(Selection);
    end;
  finally
    lStream.Free;
  end;
end;

procedure TRMGridEx.LoadFromFile(aFileName: string);
var
  Stream: TFileStream;
begin
  if not FileExists(AFileName) and (ExtractFileExt(AFileName) = '') then
    aFileName := aFileName + '.rxl';
  Stream := TFileStream.Create(AFileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRMGridEx.SaveToFile(aFileName: string);
var
  Stream: TFileStream;
begin
  if ExtractFileExt(AFileName) = '' then
    AFileName := AFileName + '.rxl';
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRMGridEx.LoadFromStream(aStream: TStream);
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
  lSaveWidth: Integer;
  lVersion: Integer;
begin
  FInLoadSaveMode := True;
  try
    FCurrentCol := -1;
    FCurrentRow := -1;

    lSaveWidth := mmColWidths[0];
    ClearGrid;
    FInLoadSaveMode := True;
    mmColWidths[0] := lSaveWidth;

    lVersion := RMReadWord(aStream);
    ColCount := RMReadInt32(aStream);
    RowCount := RMReadInt32(aStream);
    for lCol := 1 to ColCount - 1 do
    begin
      if lVersion >= 2 then
        mmColWidths[lCol] := RMReadInt32(aStream)
      else
        ColWidths[lCol] := RMReadInt32(aStream);
    end;
    for lRow := 1 to RowCount - 1 do
    begin
      if lVersion >= 2 then
        mmRowHeights[lRow] := RMReadInt32(aStream)
      else
        RowHeights[lRow] := RMReadInt32(aStream);
    end;

    for lCol := 1 to ColCount - 1 do
    begin
      for lRow := 1 to RowCount - 1 do
      begin
        lCell := Cells[lCol, lRow];
        if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
        begin
          ReadCellFromBuffer(lCell, aStream, 0, 0);
        end;
      end;
    end;
  finally
    FInLoadSaveMode := False;
  end;
end;

procedure TRMGridEx.ReadCellFromBuffer(aCell: TRMCellInfo; aStream: TStream;
  aXOffset, aYOffset: Integer);
var
  i, j: Integer;
  lPos: Integer;
  b: Byte;
  s: string;
begin
  lPos := RMReadInt32(aStream);
  aCell.FStartCol := RMReadWord(aStream) + aXOffset;
  aCell.FStartRow := RMReadWord(aStream) + aYOffset;
  aCell.FEndCol := RMReadWord(aStream) + aXOffset;
  aCell.FEndRow := RMReadWord(aStream) + aYOffset;
  aCell.VAlign := TRMVAlign(RMReadByte(aStream));
  aCell.HAlign := TRMHAlign(RMReadByte(aStream));
  aCell.MutilCell := RMReadBoolean(aStream);
  RMReadFont(aStream, aCell.Font);
  b := RMReadByte(aStream);
  if b = rmgtAddIn then
    s := RMReadString(aStream);

  aCell.ReCreateView(b, s);
  aCell.View.LoadFromStream(aStream);
  for i := aCell.StartCol to aCell.EndCol do
  begin
    for j := aCell.StartRow to aCell.EndRow do
    begin
      if (i <> aCell.StartCol) or (j <> aCell.StartRow) then
        Cells[i, j].Assign(aCell);
    end;
  end;

  aStream.Seek(lPos, soFromBeginning);
end;

procedure TRMGridEx.WriteCellToBuffer(aCell: TRMCellInfo; aStream: TStream);
var
  liSavePos, liPos: Integer;
begin
  liSavePos := aStream.Position;
  RMWriteInt32(aStream, liSavePos);
  RMWriteWord(aStream, aCell.StartCol);
  RMWriteWord(aStream, aCell.StartRow);
  RMWriteWord(aStream, aCell.EndCol);
  RMWriteWord(aStream, aCell.EndRow);
  RMWriteByte(aStream, Byte(aCell.VAlign));
  RMWriteByte(aStream, Byte(aCell.HAlign));
  RMWriteBoolean(aStream, aCell.MutilCell);
  RMWriteFont(aStream, aCell.Font);
  RMWriteByte(aStream, aCell.View.ObjectType);
  if aCell.View.ObjectType = rmgtAddIn then
    RMWriteString(aStream, aCell.View.ClassName);
  aCell.View.SaveToStream(aStream);

  liPos := aStream.Position;
  aStream.Position := liSavePos;
  RMWriteInt32(aStream, liPos);
  aStream.Seek(0, soFromEnd);
end;

procedure TRMGridEx.SaveToStream(aStream: TStream);
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
begin
  RMWriteWord(aStream, 2);
  RMWriteInt32(aStream, ColCount);
  RMWriteInt32(aStream, RowCount);
  for lCol := 1 to ColCount - 1 do
    RMWriteInt32(aStream, mmColWidths[lCol]);
  for lRow := 1 to RowCount - 1 do
    RMWriteInt32(aStream, mmRowHeights[lRow]);

  for lCol := 1 to ColCount - 1 do
  begin
    for lRow := 1 to RowCount - 1 do
    begin
      lCell := Cells[lCol, lRow];
      if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
      begin
        WriteCellToBuffer(lCell, aStream);
      end;
    end;
  end;
end;

procedure TRMGridEx.SetParentReport(Value: TRMReport);
var
  i, j: Integer;
  lCell: TRMCellInfo;
begin
  FParentReport := Value;
  for i := 1 to RowCount - 1 do
  begin
    j := 1;
    while j < ColCount do
    begin
      lCell := Cells[j, i];
      if lCell.StartRow = i then
      begin
        lCell.ParentReport := ParentReport;
      end;
      j := lCell.EndCol + 1;
    end;
  end;
end;

procedure TRMGridEx.AdjustSize(Index, Amount: Longint; Rows: Boolean);
var
  NewCur: TPoint;
  OldRows, OldCols: Longint;
  MovementX, MovementY: Longint;
  MoveRect: TRect;
  ScrollArea: TRect;
  AbsAmount: Longint;

  function DoSizeAdjust(var Count: Longint; var Extents: Pointer;
    DefaultExtent: Integer; var Current: Longint): Longint;
  var
    I: Integer;
    NewCount: Longint;
  begin
    NewCount := Count + Amount;
    if NewCount < Index then InvalidOp(STooManyDeleted);
    if (Amount < 0) and Assigned(Extents) then
    begin
      Result := 0;
      for I := Index to Index - Amount - 1 do
        Inc(Result, PIntArray(Extents)^[I]);
    end
    else
      Result := Amount * DefaultExtent;
    if Extents <> nil then
      ModifyExtents(Extents, Index, Amount, DefaultExtent);
    Count := NewCount;
    if Current >= Index then
      if (Amount < 0) and (Current < Index - Amount) then Current := Index
      else Inc(Current, Amount);
  end;

begin
  if Amount = 0 then Exit;
  NewCur := FCurrent;
  OldCols := ColCount;
  OldRows := RowCount;
  MoveRect.Left := FixedCols;
  MoveRect.Right := ColCount - 1;
  MoveRect.Top := FixedRows;
  MoveRect.Bottom := RowCount - 1;
  MovementX := 0;
  MovementY := 0;
  AbsAmount := Amount;
  if AbsAmount < 0 then AbsAmount := -AbsAmount;
  if Rows then
  begin
    MovementY := DoSizeAdjust(FRowCount, FRowHeights, DefaultRowHeight, NewCur.Y);
    MoveRect.Top := Index;
    if Index + AbsAmount <= TopRow then MoveRect.Bottom := TopRow - 1;
  end
  else
  begin
    MovementX := DoSizeAdjust(FColCount, FColWidths, DefaultColWidth, NewCur.X);
    MoveRect.Left := Index;
    if Index + AbsAmount <= LeftCol then MoveRect.Right := LeftCol - 1;
  end;
  GridRectToScreenRect(MoveRect, ScrollArea, True);
  if not IsRectEmpty(ScrollArea) then
  begin
    ScrollWindow(Handle, MovementX, MovementY, @ScrollArea, @ScrollArea);
    UpdateWindow(Handle);
  end;
  SizeChanged(OldCols, OldRows);
  if (NewCur.X <> FCurrent.X) or (NewCur.Y <> FCurrent.Y) then
    MoveCurrent(NewCur.X, NewCur.Y, True, True);
end;

procedure TRMGridEx.DoExit;
begin
  inherited DoExit;
  if not (rmgoAlwaysShowEditor in Options) then HideEditor;
end;

function TRMGridEx.CanEditAcceptKey(Key: Char): Boolean;
begin
  Result := True;
end;

function TRMGridEx.CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := True;
end;

function TRMGridEx.CanEditModify: Boolean;
begin
  Result := FCanEditModify;
end;

function TRMGridEx.CanEditShow: Boolean;
begin
  Result := ([rmgoRowSelect, rmgoEditing] * Options = [rmgoEditing]) and
    FEditorMode and not (csDesigning in ComponentState) and HandleAllocated and
    ((rmgoAlwaysShowEditor in Options) or IsActiveControl);
  Result := Result and Cells[Col, Row].CanEdit;
end;

procedure TRMGridEx.HideEditor;
begin
  FEditorMode := False;
  HideEdit;
end;

procedure TRMGridEx.ShowEditor;
var
  NewTopLeft, MaxTopLeft: TPoint;
  DrawInfo: TRMGridDrawInfo;
begin
  CalcDrawInfo(DrawInfo);
  MaxTopLeft.X := ColCount - 1;
  MaxTopLeft.Y := RowCount - 1;
  MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  NewTopLeft.X := Min(FCurrent.X, MaxTopLeft.X);
  NewTopLeft.Y := Min(FCurrent.Y, MaxTopLeft.Y);
  if ((FCurrent.X < LeftCol) or (FCurrent.Y < TopRow) or
    (FCurrent.X < LeftCol) or (FCurrent.Y < TopRow)) and
    ((NewTopLeft.X <> FTopLeft.X) or (NewTopLeft.Y <> FTopLeft.Y)) then
    MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
  FEditorMode := True;
  UpdateEdit;
end;

procedure TRMGridEx.ShowEditorChar(Ch: Char);
begin
  ShowEditor;
  if FInplaceEdit <> nil then
    PostMessage(FInplaceEdit.Handle, WM_CHAR, Word(Ch), 0);
end;

procedure TRMGridEx.UpdateEdit;
var
  MoveRect: TRect;

  procedure _UpdateEditor;
  begin
    FInplaceCol := Cells[Col, Row].FStartCol;
    FInplaceRow := Cells[Col, Row].FStartRow;
    FInplaceEdit.UpdateContents;
    if FInplaceEdit.MaxLength = -1 then
      FCanEditModify := False
    else
      FCanEditModify := True;

    if FInplaceEdit.Text <> '' then
      SendMessage(FInplaceEdit.Handle, EM_SETSEL, Length(FInplaceEdit.Text), Length(FInplaceEdit.Text));
  end;

begin
  if not CanEditShow then Exit;

  if FInplaceEdit = nil then
  begin
    FInplaceEdit := CreateEditor;
    FInplaceEdit.Grid := Self;
    FInplaceEdit.Parent := Self;
    _UpdateEditor;
  end
  else
  begin
    if (Col <> FInplaceCol) or (Row <> FInplaceRow) then
    begin
      HideEdit;
      _UpdateEditor;
    end;
  end;

  if CanEditShow then
  begin
    MoveRect := GetCellRect(Cells[Col, Row]);
    InflateRect(MoveRect, -2, -2);
    FInplaceEdit.Move(MoveRect);
  end;
end;

procedure TRMGridEx.UpdateText;
begin
  if (FInplaceCol <> -1) and (FInplaceRow <> -1) then
    SetEditText(FInplaceCol, FInplaceRow, FInplaceEdit.Text);
end;

procedure TRMGridEx.InvalidateEditor;
begin
  FInplaceCol := -1;
  FInplaceRow := -1;
  UpdateEdit;
end;

procedure TRMGridEx.HideEdit;
begin
  if FInplaceEdit <> nil then
  try
    UpdateText;
  finally
    FInplaceCol := -1;
    FInplaceRow := -1;
    FInplaceEdit.Hide;
  end;
end;

function TRMGridEx.CreateEditor: TRMInplaceEdit;
begin
  Result := TRMInplaceEdit.Create(Self);
end;

procedure TRMGridEx.SetEditText(ACol, ARow: Longint; Value: string);
begin
  DisableEditUpdate;
  try
    if Value <> Cells[ACol, ARow].Text then
    begin
      if Assigned(FOnBeforeChangeCell) then FOnBeforeChangeCell(Self, Cells[aCol, aRow]);
      Cells[ACol, ARow].Text := Value;
    end;
  finally
    EnableEditUpdate;
  end;
end;

procedure TRMGridEx.DisableEditUpdate;
begin
  Inc(FEditUpdate);
end;

procedure TRMGridEx.EnableEditUpdate;
begin
  Dec(FEditUpdate);
end;

function TRMGridEx.GetComAdapter: IUnknown;
var
  i: Integer;
begin
  if FComAdapter = nil then
  begin
    for i := 0 to RMComAdapterList.Count - 1 do
    begin
      if TRMPageEditorInfo(RMComAdapterList[i]).PageClass = ClassType then
      begin
        FComAdapter := TRMPersistentCompAdapterClass(TRMPageEditorInfo(RMComAdapterList[i]).PageEditorClass).CreateComp(Self);
        Break;
      end;
    end;
  end;

  Result := FComAdapter;
end;

end.

