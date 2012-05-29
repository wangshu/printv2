unit RM_DsgCtrls;

interface

{$I RM.inc}
{$R RM_Designer.res}
{$R rm_lng2.res}
{$R rm_lng3.res}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, CommCtrl, Menus, RM_Ctrls, RM_Common
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF USE_TB2K}
  , TB2Item, TB2ExtItems, TB2Dock, TB2Toolbar, TB2ToolWindow, TB2Common
{$ELSE}
{$IFDEF USE_INTERNALTB97}
  , RM_TB97Ctls, RM_TB97Tlbr, RM_TB97, RM_TB97Tlwn
{$ELSE}
  , TB97Ctls, TB97Tlbr, TB97, TB97Tlwn
{$ENDIF}
{$ENDIF}
{$IFDEF USE_SYNEDIT}
  , SynEdit, SynEditHighlighter,SynHighlighterPas, SynHighlighterSQL
{$ELSE}
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvEditor, rm_JvHLEditor , rm_JvEditorCommon
{$ELSE}
  , JvEditor, JvHLEditor, JvEditorCommon
{$ENDIF}
{$ENDIF}

{$IFDEF Raize}
  , RzCommon, RzTabs, RzPanel
{$ENDIF}
{$IFDEF FlatStyle}
  , TFlatPanelUnit, TFlatTabControlUnit
{$ENDIF}
  ;
const
  AlignmentBorderSize = 2; // TRY = 0
  DockedBorderSize = 2; // FROM TB2Dock.pas
  ResizeBorderSize = AlignmentBorderSize + DockedBorderSize;

type

  tbResizeKind = (rkNone, rkTop, rkLeft, rkBottom, rkRight);

  TRMDockPosition = {$IFDEF USE_TB2K}TTBDockPosition{$ELSE}TDockPosition{$ENDIF};
  TRMToolWindowSizeHandle = {$IFDEF USE_TB2K}TTBSizeHandle{$ELSE}TToolWindowSizeHandle{$ENDIF};

  TRMHighLighter = (rmhlNone, rmhlPascal, rmhlCBuilder, rmhlSql, rmhlPython, rmhlJava,
    rmhlJScript, rmhlVB,
    rmhlHtml, rmhlPerl, rmhlIni, rmhlCocoR, rmhlPhp, rmhlNQC, rmhlCSharp,
    rmhlSyntaxHighlighter);
  //dejoy added end

{$IFDEF Raize}
  TRMPanel = class(TRzPanel)
  private
    function GetBevelInner: TPanelBevel;
    function GetBevelOuter: TPanelBevel;
    procedure SetBevelInner(const Value: TPanelBevel);
    procedure SetBevelOuter(const Value: TPanelBevel);
  public
    property BevelInner: TPanelBevel read GetBevelInner write SetBevelInner;
    property BevelOuter: TPanelBevel read GetBevelOuter write SetBevelOuter;
  end;

  TRMPageControl = TRzPageControl;
  TRMTabControl = class(TRzTabControl)
{$ELSE}
{$IFDEF FlatStyle}
  TRMPanel = TFlatPanel;
  TRMPageControl = TPageControl;
  TRMTabControl = class(TFlatTabControl)
  private
    FMultiLine: boolean;
    procedure SetMultiLine(Value: Boolean);
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetTabIndex: Integer;
    procedure SetTabIndex(const Value: Integer); virtual;
  public
    HotTrack: Boolean;
    property MultiLine: Boolean read FMultiLine write SetMultiLine default False;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property TabIndex: Integer read GetTabIndex write SetTabIndex default -1;
{$ELSE}
{$IFDEF JVCLCTLS}
  TRMPanel = TPanel;
  TRMPageControl = TPageControl;
  TRMTabControl = class(TTabControl)
{$ELSE}
  TRMPanel = TPanel;
  TRMPageControl = TPageControl;
  TRMTabControl = class(TTabControl)
{$ENDIF}
{$ENDIF}
{$ENDIF}
  private
    function GetTabsCaption(Index: Integer): string;
    procedure SetTabsCaption(Index: Integer; Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    function AddTab(const S: string): Integer;
    property TabsCaption[Index: Integer]: string read GetTabsCaption write SetTabsCaption;
  end;

{$IFDEF USE_TB2K}
  TTBCustomDockableWindowAccess = class(TTBCustomDockableWindow);
{$ELSE}
  TTBCustomDockableWindowAccess = class(TCustomToolWindow97);
{$ENDIF}

{$IFDEF USE_TB2K}
  TRMResizeableToolWindow = class(TTBToolWindow)
{$ELSE}
  TRMResizeableToolWindow = class(TToolWindow97)
{$ENDIF}
  private
{$IFNDEF USE_TB2K}
    function GetCurrentDock: TDock97;
{$ENDIF}
    function DockedSizingLoop(X, Y: Integer): Boolean;
    function GetResizeKind(X, Y: Integer): tbResizeKind;
    procedure DrawDraggingOutline(const DC: HDC; const NewRect,
      OldRect: PRect; const NewDocking, OldDocking: Boolean);
  protected
{$IFDEF COMPILER4_UP}
    procedure AdjustClientRect(var Rect: TRect); override;
{$ENDIF}
    procedure WM__LButtonDown(var Msg: TWMMouse); message WM_LBUTTONDOWN;
    procedure WM__NCLButtonDown(var Msg: TWMMouse); message WM_NCLBUTTONDOWN;
    procedure WM__SetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
{$IFNDEF USE_TB2K}
    procedure GetMinMaxSize(var AMinClientWidth, AMinClientHeight,
      AMaxClientWidth, AMaxClientHeight: Integer);
    property CurrentDock: TDock97 read GetCurrentDock;
{$ENDIF}
  end;

  TRMToolWin = TRMResizeableToolWindow; //{$IFDEF USE_TB2k}TRMResizeableToolWindow{$ELSE}TToolWindow97{$ENDIF};
  TRMCustomDockableWindow = {$IFDEF USE_TB2K}TTBCustomDockableWindow{$ELSE}TCustomToolWindow97{$ENDIF};

  TFontDevice = (rmfdScreen, rmfdPrinter, rmfdBoth);
  TFontListOption = (rmfoAnsiOnly, rmfoTrueTypeOnly, rmfoFixedPitchOnly,
    rmfoNoOEMFonts, rmfoOEMFontsOnly, rmfoScalableOnly, rmfoNoSymbolFonts);
  TFontListOptions = set of TFontListOption;

  { TRMFontComboBox }
  TRMFontComboBox = class(TRMComboBox97 {TComboBox})
  private
    FFontHeight: Integer;
    FTrueTypeBMP: TBitmap;
    FDeviceBMP: TBitmap;
    FOnChange: TNotifyEvent;
    FDevice: TFontDevice;
    FUpdate: Boolean;
    FOptions: TFontListOptions;
    procedure SetFontName(const NewFontName: TFontName);
    function GetFontName: TFontName;
    function GetTrueTypeOnly: Boolean;
    procedure SetDevice(Value: TFontDevice);
    procedure SetOptions(Value: TFontListOptions);
    procedure SetTrueTypeOnly(Value: Boolean);
    procedure Reset;
    procedure WMFontChange(var Message: TMessage); message WM_FONTCHANGE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMFontChange(var Message: TMessage); message CM_FONTCHANGE;
  protected
    procedure Init;
    procedure PopulateList; virtual;
    procedure Change; override;
    procedure Click; override;
    procedure DoChange; dynamic;
    procedure CreateWnd; override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Text;
  published
    property Device: TFontDevice read FDevice write SetDevice default rmfdScreen;
    property FontName: TFontName read GetFontName write SetFontName;
    property Options: TFontListOptions read FOptions write SetOptions default [];
    property TrueTypeOnly: Boolean read GetTrueTypeOnly write SetTrueTypeOnly stored False;
    property OnChange;
  end;

  { TRMTrackIcon }
  TRMTrackIcon = class(TGraphicControl)
  private
    TrackBmp: TBitmap;
    FBitmapName: string;
    procedure SetBitmapName(const Value: string);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BitmapName: string read FBitmapName write SetBitmapName;
  end;

  { TRMRuler }
  TRMRuler = class(TPanel)
  private
    FRichEdit: TCustomRichEdit;
    ScreenPixelsPerInch: integer;
    FDragOfs: Integer;
    FLineDC: HDC;
    FLinePen: HPen;
    FDragging: Boolean;
    FLineVisible: Boolean;
    FLineOfs: Integer;

    FirstInd: TRMTrackIcon;
    LeftInd: TRMTrackIcon;
    RightInd: TRMTrackIcon;
    FOnIndChanged: TNotifyEvent;
    procedure DrawLine;
    procedure CalcLineOffset(Control: TControl);
    function IndentToRuler(Indent: Integer; IsRight: Boolean): Integer;
    function RulerToIndent(RulerPos: Integer; IsRight: Boolean): Integer;
    procedure OnRulerItemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnRulerItemMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure OnFirstIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnLeftIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnRightIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateInd;
    property RichEdit: TCustomRichEdit read FRichEdit write FRichEdit;
    property OnIndChanged: TNotifyEvent read FOnIndChanged write FOnIndChanged;
  end;

  { TRMFrameStyleButton }
  TRMFrameStyleButton = class(TRMPopupWindowButton)
  private
    FPopup: TRMPopupWindow;
    FCurrentStyle: Integer;
    FOnStyleChange: TNotifyEvent;

    procedure SetCurrentStyle(Value: Integer);
    procedure Item_OnClick(Sender: TObject);
  protected
    function GetDropDownPanel: TRMPopupWindow; override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    property CurrentStyle: Integer read FCurrentStyle write SetCurrentStyle;
    property OnStyleChange: TNotifyEvent read FOnStyleChange write FOnStyleChange;
  published
  end;

  { TRMNewScrollBox }
  TRMNewScrollBox = class(TScrollBox)
  private
    FOnkeyDown: TKeyEvent;
    procedure CNKeydown(var Message: TMessage); message CN_KEYDOWN;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnkeyDown: TKeyEvent read FOnkeyDown write FOnkeyDown;
  end;

{$IFDEF USE_SYNEDIT}
  TRMSynEditor = class(TSynEdit)
  private
    FSynHighlighter:TSynCustomHighlighter;
{$ELSE}
  TRMSynEditor = class(TJvHLEditor)
  private
     procedure OnCodeMemoPaintGutterEvent(Sender: TObject; aCanvas: TCanvas);
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CreateStringList: TStrings;
    procedure SetHighLighter(aHighLighter: TRMHighLighter);
    procedure SetGutterWidth(aWidth: Integer);
    procedure SetGroupUndo(aValue: Boolean);
    procedure SetUndoAfterSave(aValue: Boolean);
    procedure SetReservedForeColor(aValue: TColor);
    procedure SetCommentForeColor(aValue: TColor);
    procedure SetShowLineNumbers(aValue: Boolean);

    function RMCanCut: Boolean;
    function RMCanCopy: Boolean;
    function RMCanPaste: Boolean;
    function RMCanUndo: Boolean;
    function RMCanRedo: Boolean;

    procedure RMClearUndoBuffer;
    procedure RMClipBoardCut;
    procedure RMClipBoardCopy;
    procedure RMClipBoardPaste;
    procedure RMDeleteSelected;
    procedure RMUndo;
    procedure RMRedo;
  end;


procedure RMSaveToolbars(aParentKey: string; t: array of TRMToolbar);
procedure RMRestoreToolbars(aParentKey: string; t: array of TRMToolbar);
procedure RMSaveToolWinPosition(aParentKey: string; f: TRMToolWin);
procedure RMRestoreToolWinPosition(aParentKey: string; f: TRMToolWin);
function RMMinimizeName(const Filename: TFileName; Canvas: TCanvas; MaxLen: Integer): string;

function RMForceDirectories(Dir: string): Boolean;
function RMDirectoryExists(const aName: string): Boolean;
function RMSelectDirectory(const Caption: string; const Root: WideString; var Directory: string): Boolean;

implementation

uses
  Registry, RM_Class, RM_Utils, RM_Const, RM_Const1, Math, ShlObj, ActiveX;

{------------------------------------------------------------------------------}

function RMMinimizeName(const Filename: TFileName; Canvas: TCanvas; MaxLen: Integer): string;
var
  Drive: TFileName;
  Dir: TFileName;
  lName: TFileName;

  procedure CutFirstDirectory(var S: TFileName);
  var
    Root: Boolean;
    P: Integer;
  begin
    if S = '\' then
      S := ''
    else
    begin
      if S[1] = '\' then
      begin
        Root := True;
        Delete(S, 1, 1);
      end
      else
        Root := False;
      if S[1] = '.' then
        Delete(S, 1, 4);
      P := AnsiPos('\', S);
      if P <> 0 then
      begin
        Delete(S, 1, P);
        S := '...\' + S;
      end
      else
        S := '';
      if Root then
        S := '\' + S;
    end;
  end;

begin
  Result := FileName;
  Dir := ExtractFilePath(Result);
  lName := ExtractFileName(Result);

  if (Length(Dir) >= 2) and (Dir[2] = ':') then
  begin
    Drive := Copy(Dir, 1, 2);
    Delete(Dir, 1, 2);
  end
  else
    Drive := '';
  while ((Dir <> '') or (Drive <> '')) and (Canvas.TextWidth(Result) > MaxLen) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then
      Drive := ''
    else
      CutFirstDirectory(Dir);
    Result := Drive + Dir + lName;
  end;
end;

procedure DrawDragRect(const DC: HDC; const NewRect, OldRect: PRect;
  const NewSize, OldSize: TSize; const Brush: HBRUSH; BrushLast: HBRUSH);
{ Draws a dragging outline, hiding the old one if neccessary. This is
  completely flicker free, unlike the old DrawFocusRect method. In case
  you're wondering, I got a lot of ideas from the MFC sources.

  Either NewRect or OldRect can be nil or empty. }
  function CreateNullRegion: HRGN;
  var
    R: TRect;
  begin
    SetRectEmpty(R);
    Result := CreateRectRgnIndirect(R);
  end;
var
  SaveIndex: Integer;
  rgnNew, rgnOutside, rgnInside, rgnLast, rgnUpdate: HRGN;
  R: TRect;
begin
  rgnLast := 0;
  rgnUpdate := 0;

  { First, determine the update region and select it }
  if NewRect = nil then begin
    SetRectEmpty(R);
    rgnOutside := CreateRectRgnIndirect(R);
  end
  else begin
    R := NewRect^;
    rgnOutside := CreateRectRgnIndirect(R);
    InflateRect(R, -NewSize.cx, -NewSize.cy);
    IntersectRect(R, R, NewRect^);
  end;
  rgnInside := CreateRectRgnIndirect(R);
  rgnNew := CreateNullRegion;
  CombineRgn(rgnNew, rgnOutside, rgnInside, RGN_XOR);

  if BrushLast = 0 then
    BrushLast := Brush;

  if OldRect <> nil then begin
    { Find difference between new region and old region }
    rgnLast := CreateNullRegion;
    with OldRect^ do
      SetRectRgn(rgnOutside, Left, Top, Right, Bottom);
    R := OldRect^;
    InflateRect(R, -OldSize.cx, -OldSize.cy);
    IntersectRect(R, R, OldRect^);
    SetRectRgn(rgnInside, R.Left, R.Top, R.Right, R.Bottom);
    CombineRgn(rgnLast, rgnOutside, rgnInside, RGN_XOR);

    { Only diff them if brushes are the same }
    if Brush = BrushLast then begin
      rgnUpdate := CreateNullRegion;
      CombineRgn(rgnUpdate, rgnLast, rgnNew, RGN_XOR);
    end;
  end;

  { Save the DC state so that the clipping region can be restored }
  SaveIndex := SaveDC(DC);
  try
    if (Brush <> BrushLast) and (OldRect <> nil) then begin
      { Brushes are different -- erase old region first }
      SelectClipRgn(DC, rgnLast);
      GetClipBox(DC, R);
      SelectObject(DC, BrushLast);
      PatBlt(DC, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, PATINVERT);
    end;

    { Draw into the update/new region }
    if rgnUpdate <> 0 then
      SelectClipRgn(DC, rgnUpdate)
    else
      SelectClipRgn(DC, rgnNew);
    GetClipBox(DC, R);
    SelectObject(DC, Brush);
    PatBlt(DC, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, PATINVERT);
  finally
    { Clean up DC }
    RestoreDC(DC, SaveIndex);
  end;

  { Free regions }
  if rgnNew <> 0 then DeleteObject(rgnNew);
  if rgnOutside <> 0 then DeleteObject(rgnOutside);
  if rgnInside <> 0 then DeleteObject(rgnInside);
  if rgnLast <> 0 then DeleteObject(rgnLast);
  if rgnUpdate <> 0 then DeleteObject(rgnUpdate);
end;

procedure TRMResizeableToolWindow.DrawDraggingOutline(const DC: HDC;
  const NewRect, OldRect: PRect; const NewDocking, OldDocking: Boolean);

  function CreateHalftoneBrush: HBRUSH;
  const
    GrayPattern: array[0..7] of Word =
    ($5555, $AAAA, $5555, $AAAA, $5555, $AAAA, $5555, $AAAA);
  var
    GrayBitmap: HBITMAP;
  begin
    GrayBitmap := CreateBitmap(8, 8, 1, 1, @GrayPattern);
    Result := CreatePatternBrush(GrayBitmap);
    DeleteObject(GrayBitmap);
  end;
var
  NewSize, OldSize: TSize;
  Brush: HBRUSH;
begin
  Brush := CreateHalftoneBrush;
  try
    with GetFloatingBorderSize do begin
      if NewDocking then NewSize.cx := 1 else NewSize.cx := X;
      NewSize.cy := NewSize.cx;
      if OldDocking then OldSize.cx := 1 else OldSize.cx := X;
      OldSize.cy := OldSize.cx;
    end;
    DrawDragRect(DC, NewRect, OldRect, NewSize, OldSize, Brush, Brush);
  finally
    DeleteObject(Brush);
  end;
end;

{$IFNDEF USE_TB2K}

procedure ProcessPaintMessages;
{ Dispatches all pending WM_PAINT messages. In effect, this is like an
  'UpdateWindow' on all visible windows }
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE) do begin
    case Integer(GetMessage(Msg, 0, WM_PAINT, WM_PAINT)) of
      -1: Break; { if GetMessage failed }
      0: begin
          { Repost WM_QUIT messages }
          PostQuitMessage(Msg.WParam);
          Break;
        end;
    end;
    DispatchMessage(Msg);
  end;
end;

procedure TRMResizeableToolWindow.GetMinMaxSize(var AMinClientWidth, AMinClientHeight,
  AMaxClientWidth, AMaxClientHeight: Integer);
begin
  AMinClientWidth := MinClientWidth;
  AMinClientHeight := MinClientHeight;
  AMaxClientWidth := 0;
  AMaxClientHeight := 0;
end;

function TRMResizeableToolWindow.GetCurrentDock: TDock97;
begin
  Result := DockedTo;
end;
{$ENDIF}

function TRMResizeableToolWindow.DockedSizingLoop(X, Y: Integer): Boolean;
var
  MultiResize, UseSmoothDrag, ResizeVertical, ResizeReverese: Boolean;
  OrigPos, Pos: Integer;
  APoint, LastPos: TPoint;
  SizeDiff, OrigSize, NewSize, MinSize, MaxSize: Integer;
  FToolbar: TRMCustomDockableWindow;
  DragRect, OldDragRect: TRect;
  ScreenDC: HDC;

  function ResizeKind2SizeHandle(Vertical, Reverse: Boolean): TRMToolWindowSizeHandle;
  begin
    if Vertical then
      if Reverse then Result := twshTop else Result := twshBottom
    else
      if Reverse then Result := twshLeft else Result := twshRight;
  end;

  procedure ComputeToolbarNewSize(var Rect: TRect);
  begin
    with Rect do
    begin
      if ResizeVertical then
      begin
        if ResizeReverese then Top := Bottom - NewSize;
        Bottom := Top + NewSize;
      end
      else
      begin
        if ResizeReverese then Left := Right - NewSize;
        Right := Left + NewSize;
      end;
    end;
  end;

  procedure DoResize;
  var
    I: Integer;
    ARect: TRect;
  begin
    CurrentDock.BeginUpdate;
    try
      if MultiResize then
        for I := 0 to CurrentDock.ToolbarCount - 1 do
        begin
          FToolbar := CurrentDock.Toolbars[I];
          if FToolbar.DockRow = DockRow then
          begin
            ARect := FToolbar.BoundsRect;
            ComputeToolbarNewSize(ARect);
            FToolbar.BoundsRect := ARect;
          end;
        end
      else
      begin
        ARect := Self.BoundsRect;
        ComputeToolbarNewSize(ARect);
        BoundsRect := ARect;
      end;
    finally
      CurrentDock.EndUpdate;
    end;
  end;

  procedure MouseMoved;
  begin
    NewSize := OrigSize;
    SizeDiff := Pos - OrigPos;
    if ResizeReverese then Dec(NewSize, SizeDiff)
    else Inc(NewSize, SizeDiff);

    // adjust min/max resizing
    if NewSize < MinSize then NewSize := MinSize;
    if (NewSize > MaxSize) and (MaxSize > 0) then NewSize := MaxSize;

    OldDragRect := DragRect;
    ComputeToolbarNewSize(DragRect);

    if not UseSmoothDrag then
      DrawDraggingOutline(ScreenDC, @DragRect, @OldDragRect, True, True)
    else
      DoResize;
  end;

var
  Msg: TMsg;
  Accept, VerticalDock: Boolean;
  I: Integer;
  FResizeKind: tbResizeKind;
  AMinSize, AMaxSize, DUMMY: Integer;
begin
  FResizeKind := GetResizeKind(X, Y);
  Result := FResizeKind <> rkNone;

  if not Result then Exit;

  // Initialization
  Accept := False;
  ResizeVertical := FResizeKind in [rkTop, rkBottom];
  ResizeReverese := FResizeKind in [rkLeft, rkTop];
  VerticalDock := CurrentDock.Position in [dpLeft, dpRight];
  MultiResize := VerticalDock xor ResizeVertical;
{$IFDEF USE_TB2K}
  UseSmoothDrag := SmoothDrag;
{$ENDIF}

  // compute maximal/minimal sizes
  MinSize := 0;
  MaxSize := 0;
  if not MultiResize then
  begin // MINIMAL-MAXIMAL sizes of me only or to stay inside of my dock.
    if ResizeVertical then
    begin
      GetMinMaxSize(MinSize, DUMMY, MaxSize, DUMMY);
      if (MaxSize <= 0) or (MaxSize + Top > CurrentDock.Height) then MaxSize := CurrentDock.Height - Top;
    end
    else
    begin
      GetMinMaxSize(DUMMY, MinSize, DUMMY, MaxSize);
      if (MaxSize <= 0) or (MaxSize + Left > CurrentDock.Width) then MaxSize := CurrentDock.Width - Left;
    end;
  end
  else // MINIMAL-MAXIMAL sizes in my row.
    for I := 0 to CurrentDock.ToolbarCount - 1 do
    begin
      FToolbar := CurrentDock.Toolbars[I];
      if FToolbar.DockRow = DockRow then
      begin
        AMinSize := 0;
        AMaxSize := 0;
{$IFDEF USE_TB2K}
        if ResizeVertical then
          TTBCustomDockableWindowAccess(FToolbar).GetMinMaxSize(AMinSize, DUMMY, AMaxSize, DUMMY)
        else
          TTBCustomDockableWindowAccess(FToolbar).GetMinMaxSize(DUMMY, AMinSize, DUMMY, AMaxSize);
{$ELSE}
        if ResizeVertical then
          GetMinMaxSize(AMinSize, DUMMY, AMaxSize, DUMMY)
        else
          GetMinMaxSize(DUMMY, AMinSize, DUMMY, AMaxSize);
{$ENDIF}

        if MinSize < AMinSize then MinSize := AMinSize;
        if ((MaxSize > AMaxSize) or (MaxSize = 0))
          and (AMaxSize > 0) then MaxSize := AMaxSize;
      end;
    end;

  ResizeBegin(ResizeKind2SizeHandle(ResizeVertical, ResizeReverese));
  try
    { Before locking, make sure all pending paint messages are processed }
    ProcessPaintMessages;

    if not UseSmoothDrag then
    begin
{$IFNDEF TB2Dock_DisableLock}
      LockWindowUpdate(GetDesktopWindow);
{$ENDIF}
      ScreenDC := GetDCEx(GetDesktopWindow, 0, DCX_LOCKWINDOWUPDATE or DCX_CACHE or DCX_WINDOW);
    end
    else
      ScreenDC := 0;
    try
      SetCapture(Handle);

      {Initialization}
      GetWindowRect(Handle, DragRect);
      if not UseSmoothDrag then
        DrawDraggingOutline(ScreenDC, @DragRect, nil, True, True);
      GetCursorPos(APoint);
      if ResizeVertical then OrigPos := APoint.y
      else OrigPos := APoint.x;
      LastPos := APoint;
      if ResizeVertical then
        OrigSize := Height
      else
        OrigSize := Width;
      NewSize := OrigSize;

      { Stay in message loop until capture is lost. Capture is removed either
        by this procedure manually doing it, or by an outside influence (like
        a message box or menu popping up) }
      while GetCapture = Handle do begin
        case Integer(GetMessage(Msg, 0, 0, 0)) of
          -1: Break; { if GetMessage failed }
          0: begin
              { Repost WM_QUIT messages }
              PostQuitMessage(Msg.WParam);
              Break;
            end;
        end;

        case Msg.Message of
          WM_KEYDOWN, WM_KEYUP:
            { Ignore all keystrokes while in a resize loop except ESCAPE}
            if Msg.wParam = VK_ESCAPE then Break;
          WM_MOUSEMOVE: begin
              APoint := SmallPointToPoint(TSmallPoint(DWORD(GetMessagePos)));
              if (LastPos.X <> APoint.X) or (LastPos.Y <> APoint.Y) then begin
                if ResizeVertical then Pos := APoint.y
                else Pos := APoint.x;
                MouseMoved;
                LastPos := APoint;
              end;
            end;
          WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
            { Make sure it doesn't begin another loop }
            Break;
          WM_LBUTTONUP: begin
              Accept := True;
              Break;
            end;
          WM_RBUTTONDOWN..WM_MBUTTONDBLCLK:
            { Ignore all other mouse up/down messages }
            ;
        else
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
      end;
    finally
      { Since it sometimes breaks out of the loop without capture being
        released }
      if GetCapture = Handle then
        ReleaseCapture;
      ClipCursor(nil);

      if not UseSmoothDrag then begin
        { Hide dragging outline. Since NT will release a window update lock if
          another thread comes to the foreground, it has to release the DC
          and get a new one for erasing the dragging outline. Otherwise,
          the DrawDraggingOutline appears to have no effect when this happens. }
        ReleaseDC(GetDesktopWindow, ScreenDC);
        ScreenDC := GetDCEx(GetDesktopWindow, 0,
          DCX_LOCKWINDOWUPDATE or DCX_CACHE or DCX_WINDOW);
        DrawDraggingOutline(ScreenDC, nil, @DragRect, True, True);
        ReleaseDC(GetDesktopWindow, ScreenDC);

        { Release window update lock }
{$IFNDEF TB2Dock_DisableLock}
        LockWindowUpdate(0);
{$ENDIF}
      end;
    end;
    if not UseSmoothDrag and Accept then
      DoResize;
  finally
{$IFDEF USE_TB2K}
    ResizeEnd;
{$ELSE}
    ResizeEnd(True);
{$ENDIF}
  end;
end;

function TRMResizeableToolWindow.GetResizeKind(X, Y: Integer): tbResizeKind;
begin
  Result := rkNone;

  if not Assigned(CurrentDock) then Exit;

  if (Y + DockedBorderSize in [0..ResizeBorderSize])
    and (CurrentDock.Position = dpBottom) then Result := rkTop;

  if (ClientAreaHeight - Y in [0..ResizeBorderSize])
    and (CurrentDock.Position <> dpBottom) then Result := rkBottom;

  if (X + DockedBorderSize in [0..ResizeBorderSize])
    and (CurrentDock.Position = dpRight) then Result := rkLeft;

  if (ClientAreaWidth - X in [0..ResizeBorderSize])
    and (CurrentDock.Position <> dpRight) then Result := rkRight;

  // NO resizing because of FULLSIZE
  if FullSize
    and ((Result in [rkLeft, rkRight]) xor (CurrentDock.Position in [dpLeft, dpRight])) then Result := rkNone;
end;

{$IFDEF COMPILER4_UP}

procedure TRMResizeableToolWindow.AdjustClientRect(var Rect: TRect);
var
  DockPos: TRMDockPosition;
begin
  inherited;
  if Assigned(CurrentDock) then
  begin
    DockPos := CurrentDock.Position;
    Dec(Rect.Right, AlignmentBorderSize);
    Dec(Rect.Bottom, AlignmentBorderSize);
    if DockPos = dpBottom then OffsetRect(Rect, 0, AlignmentBorderSize);
    if DockPos = dpRight then OffsetRect(Rect, AlignmentBorderSize, 0);
  end;
end;
{$ENDIF}

procedure TRMResizeableToolWindow.WM__LButtonDown(var Msg: TWMMouse);
begin
  if DockedSizingLoop(Msg.XPos, Msg.YPos) then
    Msg.Result := 0
  else
    inherited;
end;

procedure TRMResizeableToolWindow.WM__NCLButtonDown(var Msg: TWMMouse);
var
  P: TPoint;
begin
  P := ScreenToClient(SmallPointToPoint(Msg.Pos));

  if DockedSizingLoop(P.X, P.Y) then
    Msg.Result := 0
  else
    inherited;
end;

procedure TRMResizeableToolWindow.WM__SetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);

  case GetResizeKind(P.X, P.Y) of
    rkTop, rkBottom: Windows.SetCursor(Screen.Cursors[crVSplit]); // LoadCursor(0, IDC_HSPLIT));
    rkLeft, rkRight: Windows.SetCursor(Screen.Cursors[crHSplit]); // LoadCursor(0, IDC_VSPLIT));
  else inherited;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure RMSaveToolbars(aParentKey: string; t: array of TRMToolbar);
var
  i: Integer;

  procedure SaveToolbarPosition(t: TRMToolbar);
  var
    Ini: TRegIniFile;
    X, Y, lWidth, lHeight: integer;
    lName: string;
  begin
    Ini := TRegIniFile.Create(RMRegRootKey + aParentKey);
    try
      lName := rsToolbar + t.Name;
      Ini.WriteBool(lName, rsVisible, t.Visible);
{$IFDEF USE_TB2K}
      if t.CurrentDock <> nil then
      begin
        X := t.DockPos;
        Y := t.DockRow;
        lWidth := t.Width;
        lHeight := t.Height;
      end
{$ELSE}
      if t.DockedTo <> nil then
      begin
        X := t.DockPos;
        Y := t.DockRow;
        lWidth := t.Width;
        lHeight := t.Height;
      end
{$ENDIF}
      else
      begin
{$IFDEF USE_TB2K}
        X := t.FloatingPosition.x;
        Y := t.FloatingPosition.Y;
{$ELSE}
        X := t.Left;
        Y := t.Top;
{$ENDIF}
        lWidth := t.Width;
        lHeight := t.Height;
      end;
      Ini.WriteInteger(lName, rsX, X);
      Ini.WriteInteger(lName, rsY, Y);
      Ini.WriteInteger(lName, rsWidth, lWidth);
      Ini.WriteInteger(lName, rsHeight, lHeight);
{$IFDEF USE_TB2K}
      if t.CurrentDock <> nil then
      begin
        Ini.WriteString(lName, rsDockName, t.CurrentDock.Name);
        Ini.WriteBool(lName, rsDocked, TRUE);
      end
{$ELSE}
      if t.DockedTo <> nil then
      begin
        Ini.WriteString(lName, rsDockName, t.DockedTo.Name);
        Ini.WriteBool(lName, rsDocked, TRUE);
      end
{$ENDIF}
      else
      begin
        Ini.WriteString(lName, rsDockName, '');
        Ini.WriteBool(lName, rsDocked, FALSE);
      end;
    finally
      Ini.Free;
    end;
  end;

begin
  for i := Low(t) to High(t) do
  begin
    SaveToolbarPosition(t[i]);
    //    t[i].Visible := False;
  end;
end;

procedure RMRestoreToolbars(aParentKey: string; t: array of TRMToolbar);
var
  i: Integer;

  procedure _RestoreToolbarPosition(t: TRMToolbar);
  var
    Ini: TRegIniFile;
    X, Y: Integer;
    DN: string;
    lNewDock: TRMDock;
    lName: string;
    lDNDocked: Boolean;
  begin
    Ini := TRegIniFile.Create(RMRegRootKey + aParentKey);
    try
      lName := rsToolbar + t.Name;
      t.Visible := False;
      X := Ini.ReadInteger(lName, rsX, t.Left);
      Y := Ini.ReadInteger(lName, rsY, t.Top);
      //t.Width := Ini.ReadInteger(lName, rsWidth, t.Width);
      t.Height := Ini.ReadInteger(lName, rsHeight, t.Height);

      lDNDocked := Ini.ReadBool(lName, rsDocked, TRUE);
      if lDNDocked then
      begin
        DN := Ini.ReadString(lName, rsDockName, '');
        if t.Owner <> nil then
        begin
          if t.ParentForm <> nil then
            lNewDock := t.ParentForm.FindComponent(DN) as TRMDock
          else
            lNewDock := t.Parent.FindComponent(DN) as TRMDock;

          if lNewDock <> nil then
          begin
{$IFDEF USE_TB2K}
            t.CurrentDock := lNewDock;
{$ELSE}
            t.DockedTo := lNewDock;
{$ENDIF}
            t.DockPos := X;
            t.DockRow := Y;
          end;
        end;
      end
      else
      begin
{$IFDEF USE_TB2K}
        t.CurrentDock := nil;
{$ELSE}
        t.DockedTo := nil;
{$ENDIF}
{$IFDEF USE_TB2K}
        t.FloatingPosition := Point(X, Y);
        t.Floating := True;
        t.MoveOnScreen(True);
{$ELSE}
        t.Left := X;
        t.Top := Y;
{$ENDIF}
      end;

      t.Visible := Ini.ReadBool(lName, rsVisible, True);
    finally
      Ini.Free;
    end;
  end;

begin
  for i := Low(t) to High(t) do
    _RestoreToolbarPosition(t[i]);
end;

procedure RMSaveToolWinPosition(aParentKey: string; f: TRMToolWin);
var
  Ini: TRegIniFile;
  lName: string;
  X, Y, lWidth, lHeight: integer;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + aParentKey);
  lName := rsForm + f.ClassName;

  Ini.WriteBool(lName, rsVisible, f.Visible);
{$IFDEF USE_TB2K}
  if f.CurrentDock <> nil then
  begin
    X := f.DockPos;
    Y := f.DockRow;
    lWidth := f.ClientAreaWidth;
    lHeight := f.ClientAreaHeight;
  end
{$ELSE}
  if f.DockedTo <> nil then
  begin
    X := f.DockPos;
    Y := f.DockRow;
    lWidth := f.Width;
    lHeight := f.Height;
  end
{$ENDIF}
  else
  begin
{$IFDEF USE_TB2K}
    X := f.FloatingPosition.x;
    Y := f.FloatingPosition.Y;
{$ELSE}
    X := f.Left;
    Y := f.Top;
{$ENDIF}
    lWidth := f.Width;
    lHeight := f.Height;
  end;
  Ini.WriteInteger(lName, rsX, X);
  Ini.WriteInteger(lName, rsY, Y);
  Ini.WriteInteger(lName, rsWidth, lWidth);
  Ini.WriteInteger(lName, rsHeight, lHeight);
{$IFDEF USE_TB2K}
  if f.CurrentDock <> nil then
  begin
    Ini.WriteString(lName, rsDockName, f.CurrentDock.Name);
    Ini.WriteBool(lName, rsDocked, TRUE);
  end
{$ELSE}
  if f.DockedTo <> nil then
  begin
    Ini.WriteString(lName, rsDockName, f.DockedTo.Name);
    Ini.WriteBool(lName, rsDocked, TRUE);
  end
{$ENDIF}
  else
  begin
    Ini.WriteString(lName, rsDockName, '');
    Ini.WriteBool(lName, rsDocked, FALSE);
  end;
  Ini.Free;
end;

procedure RMRestoreToolWinPosition(aParentKey: string; f: TRMToolWin);
var
  Ini: TRegIniFile;
  lName: string;
  X, Y: integer;
  DN: string;
  NewDock: TRMDock;
  DNDocked: Boolean;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + aParentKey);
  lName := rsForm + f.ClassName;

  f.Visible := False;
  X := Ini.ReadInteger(lName, rsX, f.Left);
  Y := Ini.ReadInteger(lName, rsY, f.Top);
  f.Width := Ini.ReadInteger(lName, rsWidth, f.Width);
  if f.Width < 40 then f.Width := 40;
  f.Height := Ini.ReadInteger(lName, rsHeight, f.Height);
  if f.Height < 40 then f.Height := 40;

  DNDocked := Ini.ReadBool(lName, rsDocked, TRUE);
  if DNDocked then
  begin
    DN := Ini.ReadString(lName, rsDockName, '');
    if f.Owner <> nil then
    begin
      NewDock := (f.Owner).FindComponent(DN) as TRMDock;
      if NewDock <> nil then
      begin
{$IFDEF USE_TB2K}
        f.CurrentDock := NewDock;
{$ELSE}
        f.DockedTo := NewDock;
{$ENDIF}
        f.DockPos := X;
        f.DockRow := Y;
      end;
    end;
  end
  else
  begin
{$IFDEF USE_TB2K}
    f.CurrentDock := nil;
{$ELSE}
    f.DockedTo := nil;
{$ENDIF}
{$IFDEF USE_TB2K}
    f.FloatingPosition := Point(X, Y);
    f.Floating := True;
    f.MoveOnScreen(True);
{$ELSE}
    f.Left := X;
    f.Top := Y;
{$ENDIF}
  end;
  f.Visible := Ini.ReadBool(lName, rsVisible, True);

  Ini.Free;
end;

const
  RulerAdj = 4 / 3;

function RMDirectoryExists(const aName: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(aName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

{$IFDEF COMPILER6_UP}
{$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}

function RMExcludeTrailingBackslash(const S: string): string;
begin
  Result := S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result) - 1);
end;

function RMForceDirectories(Dir: string): Boolean;
begin
  Result := True;
  if Length(Dir) = 0 then
  begin
    Result := False;
    Exit;
  end;
  Dir := RMExcludeTrailingBackslash(Dir);
  if (Length(Dir) < 3) or RMDirectoryExists(Dir)
    or (ExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
  Result := RMForceDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;

function RMSelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
  result := 0;
end;

function RMSelectDirectory(const Caption: string; const Root: WideString;
  var Directory: string): Boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  OldErrorMode: Cardinal;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: ULONG {LongWord};
begin
  Result := False;
  if not RMDirectoryExists(Directory) then
    Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if Root <> '' then
      begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(Application.Handle, nil,
          POleStr(Root), Eaten, RootItemIDList, Flags);
      end;
      with BrowseInfo do
      begin
        hwndOwner := Application.Handle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS;
        if Directory <> '' then
        begin
          lpfn := RMSelectDirCB;
          lParam := Integer(PChar(Directory));
        end;
      end;
      WindowList := DisableTaskWindows(0);
      OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        SetErrorMode(OldErrorMode);
        EnableTaskWindows(WindowList);
      end;
      Result := ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFontComboBox}

function GetFontMetrics(Font: TFont): TTextMetric;
var
  DC: HDC;
  SaveFont: HFont;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Result);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
end;

function GetFontHeight(Font: TFont): Integer;
begin
  Result := GetFontMetrics(Font).tmHeight;
end;

{function GetItemHeight(Font: TFont): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;
  Result := Metrics.tmHeight + 2;
end;
}
const
  WRITABLE_FONTTYPE = 256;

function IsValidFont(Box: TRMFontComboBox; LogFont: TLogFont; FontType: Integer): Boolean;
begin
  Result := True;
  if (rmfoAnsiOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = ANSI_CHARSET);
  if (rmfoTrueTypeOnly in Box.Options) then
    Result := Result and (FontType and TRUETYPE_FONTTYPE = TRUETYPE_FONTTYPE);
  if (rmfoFixedPitchOnly in Box.Options) then
    Result := Result and (LogFont.lfPitchAndFamily and FIXED_PITCH = FIXED_PITCH);
  if (rmfoOEMFontsOnly in Box.Options) then
    Result := Result and (LogFont.lfCharSet = OEM_CHARSET);
  if (rmfoNoOEMFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> OEM_CHARSET);
  if (rmfoNoSymbolFonts in Box.Options) then
    Result := Result and (LogFont.lfCharSet <> SYMBOL_CHARSET);
  if (rmfoScalableOnly in Box.Options) then
    Result := Result and (FontType and RASTER_FONTTYPE = 0);
end;

function EnumFontsProc(var EnumLogFont: TEnumLogFont; var TextMetric: TNewTextMetric;
  FontType: Integer; Data: LPARAM): Integer; export; stdcall;
var
  FaceName: string;
begin
  FaceName := StrPas(EnumLogFont.elfLogFont.lfFaceName);
  with TRMFontComboBox(Data) do
  begin
    if (Items.IndexOf(FaceName) < 0) and
      IsValidFont(TRMFontComboBox(Data), EnumLogFont.elfLogFont, FontType) then
    begin
      if EnumLogFont.elfLogFont.lfCharSet <> SYMBOL_CHARSET then
        FontType := FontType or WRITABLE_FONTTYPE;
      Items.AddObject(FaceName, TObject(FontType));
    end;
  end;
  Result := 1;
end;

constructor TRMFontComboBox.Create(AOwner: TComponent);
var
  liFont: TFont;
begin
  inherited Create(AOwner);
  FTrueTypeBMP := RMCreateBitmap('RM_TRUETYPE_FNT');
  FDeviceBMP := RMCreateBitmap('RM_DEVICE_FNT');
  FDevice := rmfdScreen;
  Style := csOwnerDrawVariable; //DropDownList;
  Sorted := True;
  DropDownCount := 18;
  Init;

  liFont := TFont.Create;
  try
    liFont.Name := 'Arial';
    liFont.Size := 16;
    FFontHeight := RMCanvasHeight('a', liFont);
  finally
    liFont.Free;
  end;
end;

destructor TRMFontComboBox.Destroy;
begin
  FTrueTypeBMP.Free;
  FDeviceBMP.Free;
  inherited Destroy;
end;

procedure TRMFontComboBox.CreateWnd;
var
  OldFont: TFontName;
begin
  OldFont := FontName;
  inherited CreateWnd;
  FUpdate := True;
  try
    PopulateList;
    inherited Text := '';
    SetFontName(OldFont);
    Perform(CB_SETDROPPEDWIDTH, 240, 0);
  finally
    FUpdate := False;
  end;
  if AnsiCompareText(FontName, OldFont) <> 0 then
    DoChange;
end;

procedure TRMFontComboBox.PopulateList;
var
  DC: HDC;
begin
  if not HandleAllocated then
    Exit;

  Items.BeginUpdate;
  try
    Clear;
    DC := GetDC(0);
    try
      if (FDevice = rmfdScreen) or (FDevice = rmfdBoth) then
        EnumFontFamilies(DC, nil, @EnumFontsProc, Longint(Self));
      if (FDevice = rmfdPrinter) or (FDevice = rmfdBoth) then
      begin
        try
          EnumFontFamilies(RMDesigner.Report.ReportPrinter.DC, nil, @EnumFontsProc, Longint(Self));
        except
        end;
      end;
    finally
      ReleaseDC(0, DC);
    end;
  finally
    Items.EndUpdate;
  end;
end;

procedure TRMFontComboBox.SetFontName(const NewFontName: TFontName);
var
  Item: Integer;
begin
  if FontName <> NewFontName then
  begin
    if not (csLoading in ComponentState) then
    begin
      HandleNeeded;
      for Item := 0 to Items.Count - 1 do
      begin
        if AnsiCompareText(Items[Item], NewFontName) = 0 then
        begin
          ItemIndex := Item;
          DoChange;
          Exit;
        end;
      end;
      if Style = csDropDownList then
        ItemIndex := -1
      else
        inherited Text := NewFontName;
    end
    else
      inherited Text := NewFontName;
    DoChange;
  end;
end;

function TRMFontComboBox.GetFontName: TFontName;
begin
  Result := inherited Text;
end;

function TRMFontComboBox.GetTrueTypeOnly: Boolean;
begin
  Result := rmfoTrueTypeOnly in FOptions;
end;

procedure TRMFontComboBox.SetOptions(Value: TFontListOptions);
begin
  if Value <> Options then
  begin
    FOptions := Value;
    Reset;
  end;
end;

procedure TRMFontComboBox.SetTrueTypeOnly(Value: Boolean);
begin
  if Value <> TrueTypeOnly then
  begin
    if Value then
      FOptions := FOptions + [rmfoTrueTypeOnly]
    else
      FOptions := FOptions - [rmfoTrueTypeOnly];
    Reset;
  end;
end;

procedure TRMFontComboBox.SetDevice(Value: TFontDevice);
begin
  if Value <> FDevice then
  begin
    FDevice := Value;
    Reset;
  end;
end;

procedure TRMFontComboBox.MeasureItem(Index: Integer; var Height: Integer);
begin
  if Index = -1 then
    Height := 15
  else
  begin
    Height := FFontHeight;
    //    Canvas.Font.Name := Items[index];
    //    Canvas.Font.Size := 16;
    //    Height := GetItemHeight(Canvas.Font);
  end;
end;

procedure TRMFontComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TBitmap;
  BmpWidth: Integer;
  s: string;
  h: Integer;
begin
  with Canvas do
  begin
    FillRect(Rect);
    BmpWidth := 15;
    if (Integer(Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0 then
      Bitmap := FTrueTypeBMP
    else if (Integer(Items.Objects[Index]) and DEVICE_FONTTYPE) <> 0 then
      Bitmap := FDeviceBMP
    else
      Bitmap := nil;
    if Bitmap <> nil then
    begin
      BmpWidth := Bitmap.Width;
      BrushCopy(Bounds(Rect.Left + 2, (Rect.Top + Rect.Bottom - Bitmap.Height)
        div 2, Bitmap.Width, Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
        Bitmap.Height), Bitmap.TransparentColor);
    end;

    if (not DroppedDown){$IFDEF COMPILER5_UP} or (odComboBoxEdit in State){$ENDIF} then
    begin
      Font.Assign(Font);
    end
    else
    begin
      Font.Name := Items[index];
      Font.Size := 16;
      if RMIsChineseGB then
      begin
        if ByteType(Font.Name, 1) = mbSingleByte then
          Font.CharSet := ANSI_CHARSET
        else
          Font.CharSet := GB2312_CHARSET;
      end;
    end;

    Rect.Left := Rect.Left + BmpWidth + 6;
    s := Items[index];
    h := TextHeight(s);
    TextOut(Rect.Left, Rect.Top + (Rect.Bottom - Rect.Top - h) div 2, s);
  end;
end;

procedure TRMFontComboBox.WMFontChange(var Message: TMessage);
begin
  inherited;
  Reset;
end;

procedure TRMFontComboBox.Change;
var
  I: Integer;
begin
  inherited Change;
  if Style <> csDropDownList then
  begin
    I := Items.IndexOf(inherited Text);
    if (I >= 0) and (I <> ItemIndex) then
    begin
      ItemIndex := I;
      DoChange;
    end;
  end;
end;

procedure TRMFontComboBox.Click;
begin
  inherited Click;
  DoChange;
end;

procedure TRMFontComboBox.DoChange;
begin
  if not (csReading in ComponentState) then
  begin
    if not FUpdate and Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TRMFontComboBox.Reset;
var
  SaveName: TFontName;
begin
  if HandleAllocated then
  begin
    FUpdate := True;
    try
      SaveName := FontName;
      PopulateList;
      FontName := SaveName;
    finally
      FUpdate := False;
      if FontName <> SaveName then
        DoChange;
    end;
  end;
end;

procedure TRMFontComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Init;
end;

procedure TRMFontComboBox.CMFontChange(var Message: TMessage);
begin
  inherited;
  Reset;
end;

procedure TRMFontComboBox.Init;
begin
  if GetFontHeight(Font) > FTrueTypeBMP.Height then
    ItemHeight := GetFontHeight(Font)
  else
    ItemHeight := FTrueTypeBMP.Height + 1;
  RecreateWnd;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMTrackIcon}

constructor TRMTrackIcon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TrackBmp := TBitmap.create;
end;

destructor TRMTrackIcon.Destroy;
begin
  TrackBmp.Free;
  TrackBmp := nil;
  inherited Destroy;
end;

procedure TRMTrackIcon.Paint;
var
  TempRect: TRect;
begin
  Canvas.Lock;
  TempRect := Rect(0, 0, TrackBmp.Width, TrackBmp.Height);
  try
    Canvas.Brush.Style := bsClear;
    Canvas.BrushCopy(TempRect, TrackBmp, TempRect,
      TrackBmp.Canvas.Pixels[0, Height - 1]);
  finally
    Canvas.Unlock;
  end;
end;

procedure TRMTrackIcon.SetBitmapName(const Value: string);
begin
  if FBitmapName <> Value then
  begin
    FBitmapName := Value;
    if Value <> '' then
    begin
      TrackBmp.Handle := LoadBitmap(HInstance, PChar(BitmapName));
      Width := TrackBmp.Width;
      Height := TrackBmp.Height;
    end;
    invalidate;
  end
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMRuler}
const
  rmTwipsPerInch = 1440;

constructor TRMRuler.Create(AOwner: TComponent);
var
  DC: HDC;
begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  BevelInner := bvNone; //bvLowered;
  BevelOuter := bvNone;
  Caption := '';
  DC := GetDC(0);
  ScreenPixelsPerInch := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);

  FirstInd := TRMTrackIcon.Create(Self);
  with FirstInd do
  begin
    BitmapName := 'RM_RULERDOWN';
    Parent := Self;
    Left := 3;
    Top := 2;
    //    SetBounds(3, 2, 16, 12);
    DragCursor := crArrow;
    OnMouseDown := OnRulerItemMouseDown;
    OnMouseMove := OnRulerItemMouseMove;
    OnMouseUp := OnFirstIndMouseUp;
  end;
  LeftInd := TRMTrackIcon.Create(Self);
  with LeftInd do
  begin
    BitmapName := 'RM_RULERUP';
    Parent := Self;
    Left := 3;
    Top := 12;
    //    SetBounds(3, 12, 16, 12);
    DragCursor := crArrow;
    OnMouseDown := OnRulerItemMouseDown;
    OnMouseMove := OnRulerItemMouseMove;
    OnMouseUp := OnLeftIndMouseUp;
  end;
  RightInd := TRMTrackIcon.Create(Self);
  with RightInd do
  begin
    BitmapName := 'RM_RULERUP';
    Parent := Self;
    Left := 475;
    Top := 13;
    //    SetBounds(475, 13, 15, 12);
    DragCursor := crArrow;
    OnMouseDown := OnRulerItemMouseDown;
    OnMouseMove := OnRulerItemMouseMove;
    OnMouseUp := OnRightIndMouseUp;
  end;
end;

procedure TRMRuler.Paint;
var
  i, j: integer;
  PageWidth: double;
  ScreenPixelsPerUnit: Double;
  liRect: TRect;
begin
  inherited Paint;
  ScreenPixelsPerUnit := ScreenPixelsPerInch;
  liRect := Rect(6, 4, Width - 6, Height - 4);
  with Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(liRect);

    Pen.Color := clBtnShadow;
    MoveTo(liRect.Left - 1, liRect.Bottom);
    LineTo(liRect.Left - 1, liRect.Top);
    LineTo(liRect.Right + 1, liRect.Top);

    Pen.Color := clBlack;
    MoveTo(liRect.Left, liRect.Bottom);
    LineTo(liRect.Left, liRect.Top + 1);
    LineTo(liRect.Right + 1, liRect.Top + 1);

    Pen.Color := clBtnFace;
    MoveTo(liRect.Left - 1, liRect.Bottom);
    LineTo(liRect.Right + 1, liRect.Bottom);
    LineTo(liRect.Right + 1, liRect.Top);

    Pen.Color := clBtnHighlight;
    MoveTo(liRect.Left - 1, liRect.Bottom + 1);
    LineTo(liRect.Right + 2, liRect.Bottom + 1);
    LineTo(liRect.Right + 2, liRect.Top);

    PageWidth := (RichEdit.Width - 12) / ScreenPixelsPerUnit;
    for i := 0 to trunc(pageWidth) + 1 do
    begin
      if (i >= PageWidth) then
        continue;
      if i > 0 then
        TextOut(Trunc(liRect.Left + i * ScreenPixelsPerUnit - TextWidth(inttostr(i)) div 2),
          liRect.Top + 3, inttostr(i));
      for j := 1 to 3 do
      begin
        Pen.color := clBlack;
        if (i + j / 4 >= PageWidth) then
          Continue;

        if (j = 4 div 2) then
        begin
          MoveTo(liRect.Left + Trunc((i + (j / 4)) * ScreenPixelsPerUnit), liRect.Top + 7);
          LineTo(liRect.Left + Trunc((i + (j / 4)) * ScreenPixelsPerUnit), liRect.Bottom - 5);
        end
        else
        begin
          MoveTo(liRect.Left + Trunc((i + (j / 4)) * ScreenPixelsPerUnit), liRect.Top + 8);
          LineTo(liRect.Left + Trunc((i + (j / 4)) * ScreenPixelsPerUnit), liRect.Bottom - 7);
        end
      end
    end;
  end;
end;

procedure TRMRuler.DrawLine;
var
  P: TPoint;
begin
  FLineVisible := not FLineVisible;
  P := Point(0, 0);
  Inc(P.X, FLineOfs);
  with P, RichEdit do
  begin
    MoveToEx(FLineDC, X, Y, nil);
    LineTo(FLineDC, X, Y + ClientHeight);
  end;
end;

procedure TRMRuler.CalcLineOffset(Control: TControl);
var
  P: TPoint;
begin
  with Control do
    P := ClientToScreen(Point(0, 0));
  P := RichEdit.ScreenToClient(P);
  FLineOfs := P.X + FDragOfs;
end;

function TRMRuler.IndentToRuler(Indent: Integer; IsRight: Boolean): Integer;
var
  R: TRect;
  P: TPoint;
begin
  Indent := Trunc(Indent * RulerAdj);
  with RichEdit do
  begin
    SendMessage(Handle, EM_GETRECT, 0, Longint(@R));
    if IsRight then
    begin
      P := R.BottomRight;
      P.X := P.X - Indent;
    end
    else
    begin
      P := R.TopLeft;
      P.X := P.X + Indent;
    end;
    P := ClientToScreen(P);
  end;

  P := ScreenToClient(P);
  Result := P.X;
end;

function TRMRuler.RulerToIndent(RulerPos: Integer; IsRight: Boolean): Integer;
var
  R: TRect;
  P: TPoint;
begin
  P.Y := 0;
  P.X := RulerPos;
  P := ClientToScreen(P);
  with RichEdit do
  begin
    P := ScreenToClient(P);
    SendMessage(Handle, EM_GETRECT, 0, Longint(@R));
    if IsRight then
      Result := R.BottomRight.X - P.X
    else
      Result := P.X - R.TopLeft.X;
  end;
  Result := Trunc(Result / RulerAdj);
end;

procedure TRMRuler.UpdateInd;
begin
  if RichEdit.Paragraph = nil then Exit;
  with RichEdit.Paragraph do
  begin
    FirstInd.Left := IndentToRuler(FirstIndent, False) - (FirstInd.Width div 2);
    LeftInd.Left := IndentToRuler(LeftIndent + FirstIndent, False) - (LeftInd.Width div 2);
    RightInd.Left := IndentToRuler(RightIndent, True) - (RightInd.Width div 2);
  end;
end;

procedure TRMRuler.OnRulerItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragOfs := (TControl(Sender).Width div 2);
  TControl(Sender).Left := Max(0, TControl(Sender).Left + X - FDragOfs);
  FLineDC := GetDCEx(RichEdit.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS
    or DCX_LOCKWINDOWUPDATE);
  FLinePen := SelectObject(FLineDC, CreatePen(PS_DOT, 1, ColorToRGB(clWindowText)));
  SetROP2(FLineDC, R2_XORPEN);
  CalcLineOffset(TControl(Sender));
  DrawLine;
  FDragging := True;
end;

procedure TRMRuler.OnRulerItemMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging then
  begin
    DrawLine;
    TControl(Sender).Left := Min(Max(0, TControl(Sender).Left + X - FDragOfs),
      ClientWidth - FDragOfs * 2);
    CalcLineOffset(TControl(Sender));
    DrawLine;
  end;
end;

procedure TRMRuler.OnFirstIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit.Paragraph.FirstIndent := Max(0, RulerToIndent(FirstInd.Left + FDragOfs,
    False));
  OnLeftIndMouseUp(Sender, Button, Shift, X, Y);
end;

procedure TRMRuler.OnLeftIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  if FLineVisible then
    DrawLine;
  DeleteObject(SelectObject(FLineDC, FLinePen));
  ReleaseDC(RichEdit.Handle, FLineDC);
  RichEdit.Paragraph.LeftIndent := Max(-RichEdit.Paragraph.FirstIndent,
    RulerToIndent(LeftInd.Left + FDragOfs, False) -
    RichEdit.Paragraph.FirstIndent);
  if Assigned(FOnIndChanged) then
    FOnIndChanged(RichEdit);
end;

procedure TRMRuler.OnRightIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  if FLineVisible then
    DrawLine;
  DeleteObject(SelectObject(FLineDC, FLinePen));
  ReleaseDC(RichEdit.Handle, FLineDC);
  RichEdit.Paragraph.RightIndent := Max(0, RulerToIndent(RightInd.Left + FDragOfs,
    True));
  if Assigned(FOnIndChanged) then
    FOnIndChanged(RichEdit);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMTabControl }

function TRMTabControl.GetTabsCaption(Index: Integer): string;
begin
{$IFDEF Raize}
  Result := Tabs[Index].Caption;
{$ELSE}
  Result := Tabs[Index];
{$ENDIF}
end;

procedure TRMTabControl.SetTabsCaption(Index: Integer; Value: string);
begin
{$IFDEF Raize}
  Tabs[Index].Caption := Value;
{$ELSE}
  Tabs[Index] := Value;
{$ENDIF}
end;

constructor TRMTabControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF JVCLCTLS}
  //Style := tsFlatButtons;
{$ENDIF}
end;

function TRMTabControl.AddTab(const S: string): Integer;
begin
{$IFDEF Raize}
  Tabs.Add.Caption := S;
  Result := Tabs.Count;
{$ELSE}
  Result := Tabs.Add(S);
{$ENDIF}
end;

{$IFDEF Raize}

function TRMPanel.GetBevelInner: TPanelBevel;
begin
  Result := bvNone;
end;

function TRMPanel.GetBevelOuter: TPanelBevel;
begin
  Result := bvNone;
end;

procedure TRMPanel.SetBevelInner(const Value: TPanelBevel);
begin
  case Value of
    bvNone: BorderInner := fsNone;
    bvLowered: BorderInner := fsLowered;
    bvRaised: BorderInner := fsRaised;
    bvSpace: BorderInner := fsFlat;
  end;
end;

procedure TRMPanel.SetBevelOuter(const Value: TPanelBevel);
begin
  case Value of
    bvNone: BorderOuter := fsNone;
    bvLowered: BorderOuter := fsLowered;
    bvRaised: BorderOuter := fsRaised;
    bvSpace: BorderOuter := fsFlat;
  end;
end;
{$ENDIF}

{$IFDEF FlatStyle}

function TRMTabControl.GetOnChange: TNotifyEvent;
begin
  Result := OnTabChanged;
end;

procedure TRMTabControl.SetOnChange(const Value: TNotifyEvent);
begin
  OnTabChanged := Value;
end;

function TRMTabControl.GetTabIndex: Integer;
begin
  Result := SendMessage(Handle, TCM_GETCURSEL, 0, 0);
end;

procedure TRMTabControl.SetTabIndex(const Value: Integer);
begin
  SendMessage(Handle, TCM_SETCURSEL, Value, 0);
end;

procedure TRMTabControl.SetMultiLine(Value: Boolean);
begin
  FMultiLine := value;
end;
{$ENDIF}
//dejoy added end

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMFrameStyleButton.Create(aOwner: TComponent);
begin
  inherited;

  FPopup := nil;
end;

destructor TRMFrameStyleButton.Destroy;
begin
  FreeAndNil(FPopup);
  inherited;
end;

function TRMFrameStyleButton.GetDropDownPanel: TRMPopupWindow;
var
  tmp: TSpeedButton;
  i: Integer;
begin
  if FPopup <> nil then
  begin
    Result := FPopup;
    Exit;
  end;

  FPopup := TRMPopupWindow.CreateNew(nil);
  FPopup.Font.Assign(Font);
  FPopup.ClientWidth := 90 + 4 + 4;
  FPopup.ClientHeight := 18 * 6 + 2 + 2;
  for i := 1 to 6 do
  begin
    tmp := TSpeedButton.Create(FPopup);
    tmp.Flat := True;
    tmp.Parent := FPopup;
    tmp.Tag := 24 + i;
    tmp.GroupIndex := 1;
    tmp.Glyph.LoadFromResourceName(hInstance, 'RM_BORDERSTYLE' + IntToStr(i));
    tmp.SetBounds(4, 2 + 18 * (i - 1), 90, 18);
    tmp.OnClick := Item_OnClick;
  end;

  DropdownPanel := FPopup;
  Result := FPopup;
end;

procedure TRMFrameStyleButton.Item_OnClick(Sender: TObject);
begin
  FCurrentStyle := TRMToolbarButton(Sender).Tag;
  FPopup.Close(nil);

  if Assigned(FOnStyleChange) then FOnStyleChange(Sender);
end;

procedure TRMFrameStyleButton.SetCurrentStyle(Value: Integer);
begin
  FCurrentStyle := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMNewScrollBox }

constructor TRMNewScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := True; //使之能获得焦点
end;

procedure TRMNewScrollBox.CNKeydown(var Message: TMessage);
begin
  case TWMKey(Message).CharCode of
    VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_TAB:
      begin
        Exit; //如果让他自己处理的话就会失去焦点，必须中断才能把消息传到WM_KeyDown
      end;
  else
    inherited;
  end;
end;

procedure TRMNewScrollBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnkeyDown) then
  begin
    FOnkeyDown(Self, key, Shift);
  end;
  inherited;
end;

{------------------------------------------------------------------------------}
{ TRMSynEdit }

constructor TRMSynEditor.Create(aOwner: TComponent);
begin
  inherited;
{$IFDEF USE_SYNEDIT}
  FSynHighlighter := nil;
{$ELSE}  
{$ENDIF}
end;

destructor TRMSynEditor.Destroy;
begin

  inherited;
end;

{$IFNDEF USE_SYNEDIT}
procedure TRMSynEditor.OnCodeMemoPaintGutterEvent(Sender: TObject; aCanvas: TCanvas);
var
  i, Y: integer;
  str: string;
begin
  Y := 0;
  for i := TopRow to TopRow + LastVisibleRow do
  begin
    str := IntToStr(i + 1);
    aCanvas.TextOut(GutterWidth - aCanvas.TextWidth(str) - 4, Y, str);
    Inc(Y, CellRect.Height);
  end;
end;
{$ENDIF}

function TRMSynEditor.CreateStringList: TStrings;
begin
  Result := Self.Lines;
end;

procedure TRMSynEditor.SetHighLighter(aHighLighter: TRMHighLighter);
begin
{$IFDEF USE_SYNEDIT}
   case aHighLighter of
     rmhlPascal:
     begin
       if FSynHighlighter <> nil then
         FSynHighlighter.Free;
       FSynHighlighter := TSynPasSyn.Create(Self);
       Self.Highlighter := FSynHighlighter;
     end;
     rmhlSql:
     begin
       if FSynHighlighter <> nil then
         FSynHighlighter.Free;
       FSynHighlighter := TSynSQLSyn.Create(Self);
       Self.Highlighter := FSynHighlighter;
     end;
   end;
{$ELSE}
  HighLighter := TJvHighlighter(aHighLighter);
{$ENDIF}
end;

procedure TRMSynEditor.SetGutterWidth(aWidth: Integer);
begin
{$IFDEF USE_SYNEDIT}
  Gutter.Width := aWidth;
{$ELSE}
  GutterWidth := aWidth;
{$ENDIF}
end;

procedure TRMSynEditor.SetGroupUndo(aValue: Boolean);
begin
{$IFDEF USE_SYNEDIT}
  if aValue then
    Options := Options + [eoGroupUndo]
  else
    Options := Options - [eoGroupUndo];
{$ELSE}
  GroupUndo := aValue;
{$ENDIF}

end;

procedure TRMSynEditor.SetUndoAfterSave(aValue: Boolean);
begin
{$IFDEF USE_SYNEDIT}
{$ELSE}
  UndoAfterSave := aValue;
{$ENDIF}
end;

procedure TRMSynEditor.SetShowLineNumbers(aValue: Boolean);
begin
{$IFDEF USE_SYNEDIT}
  Gutter.ShowLineNumbers := aValue;
{$ELSE}
  if aValue then
    OnPaintGutter := OnCodeMemoPaintGutterEvent
  else
    OnPaintGutter := nil;
{$ENDIF}
end;

procedure TRMSynEditor.SetReservedForeColor(aValue: TColor);
begin
{$IFDEF USE_SYNEDIT}
  if Self.Highlighter <> nil then
    Self.Highlighter.KeywordAttribute.Foreground := aValue;
{$ELSE}
  Colors.Reserved.ForeColor := aValue;
{$ENDIF}
end;

procedure TRMSynEditor.SetCommentForeColor(aValue: TColor);
begin
{$IFDEF USE_SYNEDIT}
  if Self.Highlighter <> nil then
    Self.Highlighter.CommentAttribute.Foreground := aValue;
{$ELSE}
  Colors.Comment.ForeColor := aValue;
{$ENDIF}
end;

procedure TRMSynEditor.RMClearUndoBuffer;
begin
{$IFDEF USE_SYNEDIT}
  Self.ClearUndo;
{$ELSE}
  UndoBuffer.Clear;
{$ENDIF}
end;

function TRMSynEditor.RMCanCut: Boolean;
begin
{$IFDEF USE_SYNEDIT}
  Result := Self.SelAvail;
{$ELSE}
  Result := CanCut;
{$ENDIF}
end;

function TRMSynEditor.RMCanCopy: Boolean;
begin
{$IFDEF USE_SYNEDIT}
  Result := Self.SelAvail;
{$ELSE}
  Result := CanCopy;
{$ENDIF}
end;

function TRMSynEditor.RMCanPaste: Boolean;
begin
{$IFDEF USE_SYNEDIT}
  Result := Self.CanPaste;
{$ELSE}
  Result := CanPaste;
{$ENDIF}
end;

function TRMSynEditor.RMCanUndo: Boolean;
begin
{$IFDEF USE_SYNEDIT}
  Result := Self.CanUndo;
{$ELSE}
  Result := UndoBuffer.CanUndo;
{$ENDIF}
end;

function TRMSynEditor.RMCanRedo: Boolean;
begin
{$IFDEF USE_SYNEDIT}
  Result := Self.CanRedo;
{$ELSE}
  Result := False;
  //Result := UndoBuffer.CanUndo;
{$ENDIF}
end;

procedure TRMSynEditor.RMClipBoardCut;
begin
{$IFDEF USE_SYNEDIT}
  Self.CutToClipboard;
{$ELSE}
  ClipBoardCut;
{$ENDIF}
end;

procedure TRMSynEditor.RMClipBoardCopy;
begin
{$IFDEF USE_SYNEDIT}
  Self.CopyToClipboard;
{$ELSE}
  ClipBoardCopy;
{$ENDIF}
end;

procedure TRMSynEditor.RMClipBoardPaste;
begin
{$IFDEF USE_SYNEDIT}
  Self.PasteFromClipboard;
{$ELSE}
  ClipBoardPaste;
{$ENDIF}
end;

procedure TRMSynEditor.RMDeleteSelected;
begin
{$IFDEF USE_SYNEDIT}
{$ELSE}
  DeleteSelected;
{$ENDIF}
end;

procedure TRMSynEditor.RMUndo;
begin
{$IFDEF USE_SYNEDIT}
  Self.Undo;
{$ELSE}
  UndoBuffer.Undo;
{$ENDIF}
end;

procedure TRMSynEditor.RMRedo;
begin
{$IFDEF USE_SYNEDIT}
  Self.Redo;
{$ELSE}
  UndoBuffer.Redo;
{$ENDIF}
end;

{------------------------------------------------------------------------------}

end.

