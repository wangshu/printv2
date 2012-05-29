
unit RM_Ctrls;

interface

{$I RM.inc}
{$R RM_common.res}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Commctrl, Menus, Mask, Buttons, RM_Common
{$IFDEF USE_TB2K}
  , TB2Item, TB2ExtItems, TB2Dock, TB2Toolbar, TB2ToolWindow, TB2Common
{$IFDEF USE_TB2K_TBX}
  , TBX, TBXExtItems
{$ENDIF}
{$ELSE}
{$IFDEF USE_INTERNALTB97}
  , RM_TB97Ctls, RM_TB97Tlbr, RM_TB97, RM_TB97Tlwn
{$ELSE}
  , TB97Ctls, TB97Tlbr, TB97, TB97Tlwn
{$ENDIF}
{$ENDIF}
{$IFNDEF USE_INTERNAL_JVCL}
  ,JvOfficeColorButton
{$ENDIF}
{$IFDEF COMPILER5_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  MaxColorButtonNumber = 40;

type
  { TRMDockableToolbar }
  TRMDockableToolbar = class(TToolBar)
  private
    function GetRightMostControlPos: Integer;
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    function DoUnDock(NewTarget: TWinControl; Client: TControl): Boolean; override;
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddControl(aControl: TControl);

    procedure BeginUpdate;
    procedure EndUpdate;
  published
  end;

  TRMToolbarSeparator = class(TToolButton)
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TRMSubMenuItem = class;

  {TRMDock}
{$IFDEF USE_TB2k}
{$IFDEF USE_TB2K_TBX}
  TRMDock = TTBDock;
{$ELSE}
  TRMDock = TTBDock;
{$ENDIF}
{$ELSE}
  TRMDock = class(TDock97);
{$ENDIF}

  {TRMToolbar}
{$IFDEF USE_TB2k}
{$IFDEF USE_TB2K_TBX}
  TRMToolbar = class(TTBXToolbar)
{$ELSE}
  TRMToolbar = class(TTBToolbar)
{$ENDIF}
  private
    function GetDockedto: TRMDock;
    procedure SetDockedto(Value: TRMDock);
  public
    ParentForm: TForm;
    property Dockedto: TRMDock read GetDockedto write SetDockedto;
  end;
{$ELSE}
  TRMToolbar = class(TToolbar97)
  public
    ParentForm: TForm;
  end;
{$ENDIF}

  {TRMToolbarSep}
{$IFDEF USE_TB2k}
{$IFDEF USE_TB2K_TBX}
  TRMToolbarSep = class(TTBXSeparatorItem)
{$ELSE}
  TRMToolbarSep = class(TTBSeparatorItem)
{$ENDIF}
{$ELSE}
  TRMToolbarSep = class(TToolbarSep97)
{$ENDIF}
  private
    procedure SetAddTo(Value: TRMToolbar);
  public
    property AddTo: TRMToolbar write SetAddTo;
  end;

  {TRMEdit}
{$IFDEF USE_TB2K}
{$IFDEF USE_TB2K_TBX}
  TRMEdit = class(TTBXEditItem)
{$ELSE}
  TRMEdit = class(TTBEditItem)
{$ENDIF}
{$ELSE}
  TRMEdit = class(TEdit97)
{$ENDIF}
  private
    procedure SetAddTo(Value: TRMToolbar);
  public
    property AddTo: TRMToolbar write SetAddTo;
  end;

  {TRMMenuBar}
{$IFDEF USE_TB2K}
  TRMMenuBar = TRMToolbar;
{$ELSE}
  TRMMenuBar = class(TMainMenu)
  public
    Dockedto: TRMDock;
    MenuBar: Boolean;

    procedure BeginUpdate;
    procedure EndUpdate;
  end;
{$ENDIF}

  {TRMPopupMenu}
{$IFDEF USE_TB2k}
{$IFDEF USE_TB2K_TBX}
  TRMPopupMenu = TTBXPopupMenu;
{$ELSE}
  TRMPopupMenu = TTBPopupMenu;
{$ENDIF}
{$ELSE}
  TRMPopupMenu = TPopupMenu;
{$ENDIF}

  {TRMCustomMenuItem}
{$IFDEF USE_TB2K}
{$IFDEF USE_TB2K_TBX}
  TRMCustomMenuItem = class(TTBXItem)
{$ELSE}
  TRMCustomMenuItem = class(TTBItem)
{$ENDIF}
  private
    function GetRadioItem: boolean;
    procedure SetRadioItem(Value: boolean);
    procedure SetAddTo(Value: TRMToolbar);
  public
    property RadioItem: boolean read GetRadioItem write SetRadioItem;
    property AddTo: TRMToolbar write SetAddTo;
{$ELSE}
  TRMCustomMenuItem = class(TMenuItem)
  private
    function GetImages: TCustomImageList;
    procedure SetImages(Value: TCustomImageList);
  public
    property Images: TCustomImageList read GetImages write SetImages;
{$ENDIF}
  public
    procedure AddToMenu(Value: TRMMenuBar); overload;
    procedure AddToMenu(Value: TRMCustomMenuItem); overload;
    procedure AddToMenu(Value: TRMSubMenuItem); overload;
    procedure AddToMenu(Value: TRMPopupMenu); overload;
  end;

  TRMMenuItem = class(TRMCustomMenuItem);

  {TRMSubMenuItem}
{$IFDEF USE_TB2K}
{$IFDEF USE_TB2K_TBX}
  TRMSubMenuItem = class(TTBXSubmenuItem)
{$ELSE}
  TRMSubMenuItem = class(TTBSubmenuItem)
{$ENDIF}
  private
    procedure SetAddTo(Value: TRMToolbar);
  public
    procedure AddToMenu(Value: TRMMenuBar); overload;
    procedure AddToMenu(Value: TRMCustomMenuItem); overload;
    procedure AddToMenu(Value: TRMSubMenuItem); overload;
    procedure AddToMenu(Value: TRMPopupMenu); overload;
    property AddTo: TRMToolbar write SetAddTo;
  end;
{$ELSE}
  TRMSubMenuItem = class(TRMMenuItem);
{$ENDIF}

  {TRMSeparatorMenuItem}
{$IFDEF USE_TB2K}
{$IFDEF USE_TB2K_TBX}
  TRMSeparatorMenuItem = class(TTBXSeparatorItem)
{$ELSE}
  TRMSeparatorMenuItem = class(TTBSeparatorItem)
{$ENDIF}
  public
    procedure AddToMenu(Value: TRMMenuBar); overload;
    procedure AddToMenu(Value: TRMCustomMenuItem); overload;
    procedure AddToMenu(Value: TRMSubMenuItem); overload;
    procedure AddToMenu(Value: TRMPopupMenu); overload;
  end;
{$ELSE}
  TRMSeparatorMenuItem = class(TRMMenuItem)
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;
{$ENDIF}

{$IFDEF USE_TB2k}
{$IFDEF USE_TB2K_TBX}
  TRMToolbarButton = class(TTBXItem)
{$ELSE}
  TRMToolbarButton = class(TTBItem)
{$ENDIF}
  private
    function GetDown: Boolean;
    procedure SetDown(Value: Boolean);
    function GetAllowAllUp: Boolean;
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetAddTo(Value: TRMToolBar);
  public
    property AddTo: TRMToolBar write SetAddTo;
    property AllowAllUp: Boolean read GetAllowAllup write SetAllowAllup;
    property Down: Boolean read GetDown write SetDown;
  end;
{$ELSE}
  TRMToolbarButton = class(TToolbarButton97)
  private
    procedure SetAddTo(Value: TRMToolBar);
  public
    property AddTo: TRMToolBar write SetAddTo;
  end;
{$ENDIF}

  TComboState97 = set of (csButtonPressed, csMouseCaptured);

  { TRMCustomComboBox97 }
  TRMCustomComboBox97 = class(TCustomComboBox)
  private
    FFlat: Boolean;
    FOldColor: TColor;
    FOldParentColor: Boolean;
    FButtonWidth: Integer;
    FEditState: TComboState97;
    FMouseInControl: Boolean;
    procedure SetFlat(const Value: Boolean);
    procedure DrawButtonBorder(DC: HDC);
    procedure DrawControlBorder(DC: HDC);
    procedure DrawBorders;
    function NeedDraw3DBorder: Boolean;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    procedure TrackButtonPressed(X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;

    property Flat: Boolean read FFlat write SetFlat default True;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TRMComboBox97 }
  TRMComboBox97 = class(TRMCustomComboBox97)
  published
    property Style; // Debe ser siempre la primera
    property Flat;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDrag;
  end;

  TRMSpinButtonState = (rmsbNotDown, rmsbTopDown, rmsbBottomDown);

  { TRMSpinButton }
  TRMSpinButton = class(TGraphicControl)
  private
    FDown: TRMSpinButtonState;
    FUpBitmap: TBitmap;
    FDownBitmap: TBitmap;
    FDragging: Boolean;
    FInvalidate: Boolean;
    FTopDownBtn: TBitmap;
    FBottomDownBtn: TBitmap;
    FRepeatTimer: TTimer;
    FNotDownBtn: TBitmap;
    FLastDown: TRMSpinButtonState;
    FFocusControl: TWinControl;
    FOnTopClick: TNotifyEvent;
    FOnBottomClick: TNotifyEvent;
    procedure TopClick;
    procedure BottomClick;
    procedure GlyphChanged(Sender: TObject);
    procedure SetDown(Value: TRMSpinButtonState);
    procedure DrawAllBitmap;
    procedure DrawBitmap(ABitmap: TBitmap; ADownState: TRMSpinButtonState);
    procedure TimerExpired(Sender: TObject);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Down: TRMSpinButtonState read FDown write SetDown default rmsbNotDown;
  published
  end;

  {TRMSpinEdit}

  TRMValueType = (rmvtInteger, rmvtFloat);

  TRMSpinEdit = class(TCustomEdit)
  private
    FAlignment: TAlignment;
    FMinValue: Extended;
    FMaxValue: Extended;
    FIncrement: Extended;
    FDecimal: Byte;
    FChanging: Boolean;
    FEditorEnabled: Boolean;
    FValueType: TRMValueType;
    FButton: TRMSpinButton;
    FBtnWindow: TWinControl;
    FArrowKeys: Boolean;
    FOnTopClick: TNotifyEvent;
    FOnBottomClick: TNotifyEvent;
    FUpDown: TCustomUpDown;
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    function GetMinHeight: Integer;
    procedure GetTextHeight(var SysHeight, Height: Integer);
    function GetValue: Extended;
    function CheckValue(NewValue: Extended): Extended;
    function GetAsInteger: Longint;
    function IsIncrementStored: Boolean;
    function IsValueStored: Boolean;
    procedure SetArrowKeys(Value: Boolean);
    procedure SetAsInteger(NewValue: Longint);
    procedure SetValue(NewValue: Extended);
    procedure SetValueType(NewType: TRMValueType);
    procedure SetDecimal(NewValue: Byte);
    function GetButtonWidth: Integer;
    procedure RecreateButton;
    procedure ResizeButton;
    procedure SetEditRect;
    procedure SetAlignment(Value: TAlignment);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TMessage); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
{$IFDEF COMPILER4_UP}
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
{$ENDIF}
  protected
    procedure Change; override;
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure UpClick(Sender: TObject); virtual;
    procedure DownClick(Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AsInteger: Longint read GetAsInteger write SetAsInteger default 0;
    property Text;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ArrowKeys: Boolean read FArrowKeys write SetArrowKeys default True;
    property Decimal: Byte read FDecimal write SetDecimal default 2;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property Increment: Extended read FIncrement write FIncrement stored IsIncrementStored;
    property MaxValue: Extended read FMaxValue write FMaxValue;
    property MinValue: Extended read FMinValue write FMinValue;
    property ValueType: TRMValueType read FValueType write SetValueType;
    property Value: Extended read GetValue write SetValue stored IsValueStored;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnBottomClick: TNotifyEvent read FOnBottomClick write FOnBottomClick;
    property OnTopClick: TNotifyEvent read FOnTopClick write FOnTopClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  { TRMPopupWindow }
  TRMPopupWindow = class(TForm)
  private
    FSave: HWND;
    FForm: TCustomForm;
    FCaller: TControl;
    FWidth: Integer;
    FOnClose: TNotifyEvent;
    FOnPopup: TNotifyEvent;

    procedure DoClosePopupWindow;
    procedure WMKILLFOCUS(var message: TWMKILLFOCUS); message WM_KILLFOCUS;
    procedure PopupWindow(ACaller: TControl);
  protected
    procedure DestroyWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    procedure Close(Sender: TObject = nil);
    procedure Popup(ACaller: TControl);

    property Caller: TControl read FCaller;
  published
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
  end;

{$IFDEF USE_TB2K}
  TRMArrowButton = class(TGraphicControl)
  private
    FGlyph: Pointer;
    FGroupIndex: Integer;
    FDown: Boolean;
    FArrowClick: Boolean;
    FPressBoth: Boolean;
    FArrowWidth: Integer;
    FAllowAllUp: Boolean;
    FFlat: Boolean;
    FMouseInControl: Boolean;
    FDropDownMenu: TPopupMenu;
    FOnDrop: TNotifyEvent;

    function GetGlyph: TBitmap;
    procedure SetGlyph(Value: TBitmap);
    function GetNumGlyphs: TNumGlyphs;
    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetArrowWidth(Value: Integer);
    procedure UpdateTracking;
    procedure MouseEnter(AControl: TControl);
    procedure MouseLeave(AControl: TControl);
    procedure GlyphChanged(Sender: TObject);

    procedure WMLButtonDblClk(var Msg: TWMLButtonDown); message WM_LBUTTONDBLCLK;
  protected
    FState: TButtonState;

    procedure WndProc(var Msg: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs default 1;
    property Align;
    property Action;
    property Anchors;
    property Constraints;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property ArrowWidth: Integer read FArrowWidth write SetArrowWidth default 13;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property DropDown: TPopupMenu read FDropDownMenu write FDropDownMenu;
    property Caption;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
    property ParentFont default True;
    property ParentShowHint;
    property PressBoth: Boolean read FPressBoth write FPressBoth default True;
    property ShowHint;
    property Visible;
    property OnDrop: TNotifyEvent read FOnDrop write FOnDrop;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;
{$ENDIF}

  { TRMPopupWindowButton }
  TRMPopupWindowButton = {$IFDEF USE_TB2K}class(TRMArrowButton){$ELSE}class(TRMToolbarButton){$ENDIF}
  private
    FActive: Boolean;
    FDropDownPanel: TRMPopupWindow;

    procedure SetActive(aValue: Boolean);
    procedure DropdownPanel_OnClose(Sender: TObject);
    procedure ShowDropDownPanel;
  protected
    function GetDropDownPanel: TRMPopupWindow; virtual;
    procedure SetDropdownPanel(Value: TRMPopupWindow);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;

    property Active: Boolean read FActive write SetActive;
  published
    property DropDownPanel: TRMPopupWindow read GetDropDownPanel write SetDropdownPanel;
  end;

  { TRMColorPickerButton }

  TRMColorType = (rmptFont, rmptLine, rmptFill, rmptHighlight, rmptCustom);

{$IFDEF USE_INTERNAL_JVCL}

{$IFDEF USE_TB2K}
  TRMColorSpeedButton = class(TSpeedButton)
{$ELSE}
  TRMColorSpeedButton = class(TRMToolbarButton)
{$ENDIF}
  private
    FCurColor: TColor;
  protected
    procedure Paint; override;
  published
    property CurColor: TColor read FCurColor write FCurColor;
  end;

  { TRMColorPickerButton }
  TRMColorPickerButton = class(TRMPopupWindowButton)
  private
    FPopup: TRMPopupWindow;

    FColorButtons: array[0..MaxColorButtonNumber - 1] of TRMColorSpeedButton;
    FAutoButton: TRMColorSpeedButton;
    FOtherButton: {$IFDEF USE_TB2K}TSpeedButton{$ELSE}TRMToolbarButton{$ENDIF};
    FColorDialog: TColorDialog;
    FColorType: TRMColorType;
    FCurrentColor: TColor;
    FAutoColor: TColor;
    FAutoCaption: string;

    FHoriMargin: integer;
    FTopMargin: integer;
    FBottomMargin: integer;
    FDragBarHeight: integer;
    FDragBarSpace: integer;
    FButtonHeight: integer;
    FColorSpace: integer;
    FColorSize: integer;
    FColorSpaceTop: integer;
    FColorSpaceBottom: integer;

    FOnColorChange: TNotifyEvent;

    procedure ColorButtonClick(Sender: TObject);
    procedure DrawButtonGlyph(aColor: TColor);

    procedure SetSelectedColor(const Value: TColor);
    procedure SetColorType(const Value: TRMColorType);
    function GetCustomColors: TStrings;
    procedure SetCustomColors(const Value: TStrings);
  protected
    function GetDropDownPanel: TRMPopupWindow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property TopMargin: integer read FTopMargin write FTopMargin;
    property BottomMargin: integer read FBottomMargin write FBottomMargin;
    property HoriMargin: integer read FHoriMargin write FHoriMargin;
    property DragBarHeight: integer read FDragBarHeight write FDragBarHeight;
    property DragBarSpace: integer read FDragBarSpace write FDragBarSpace;
    property ColorSpace: integer read FColorSpace write FColorSpace;
    property ColorSpaceTop: integer read FColorSpaceTop write FColorSpaceTop;
    property ColorSpaceBottom: integer read FColorSpaceBottom write FColorSpaceBottom;
    property ColorSize: integer read FColorSize write FColorSize;
    property ButtonHeight: integer read FButtonHeight write FButtonHeight;

    property AutoCaption: string read FAutoCaption write FAutoCaption;
    property CurrentColor: TColor read FCurrentColor write SetSelectedColor;
    property ColorType: TRMColorType read FColorType write SetColorType;
    property CustomColors: TStrings read GetCustomColors write SetCustomColors;

    property OnColorChange: TNotifyEvent read FOnColorChange write FOnColorChange;
  end;
{$ELSE}

  TRMColorPickerButton = class(TJvOfficeColorButton)
  private
    FColorType: TRMColorType;
    procedure SetColorType(const Value: TRMColorType);
    function GetCurrentColor: TColor;
    procedure SetCurrentColor(const Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    property ColorType: TRMColorType read FColorType write SetColorType;
    property CurrentColor :TColor read GetCurrentColor write SetCurrentColor;
  end;
{$ENDIF USE_INTERNAL_JVCL}

  TRMRulerOrientationType = (roHorizontal, roVertical);

  {@TRMDesignerRuler }
  TRMDesignerRuler = class(TPaintBox) //TGraphicControl)
  private
    FDrawRect: TRect;
    FGuide1X: Integer;
    FGuide1Y: Integer;
    FGuide2X: Integer;
    FGuide2Y: Integer;
    FGuideHeight: Integer;
    FGuideWidth: Integer;
    FHalfTicks: Boolean;
    FMargin: Integer;
    FOrientation: TRMRulerOrientationType;
    FPixelIncrement: Double;
    FScrollOffset: Integer;
    FThickness: Integer;
    FTicksPerUnit: Integer;
    FTickFactor: Single;
    FUnits: TRMUnitType;
    FScale: Double;

    procedure DrawGuide(aGuideX, aGuideY: Integer);
    procedure InitGuides;
    procedure PaintRuler;
    procedure SetOrientation(aOrientation: TRMRulerOrientationType);
    procedure SetUnits(aUnit: TRMUnitType);
    procedure SetScrollOffset(Value: Integer);
    function UpdateGuidePosition(aNewPosition: Integer; var aGuideX, aGuideY: Integer): Boolean;
    procedure ChangeUnits(aUnit: TRMUnitType);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Scroll(Value: Integer);
    procedure SetGuides(aPosition1, aPosition2: Integer);
    property Orientation: TRMRulerOrientationType read FOrientation write SetOrientation;
    property Units: TRMUnitType read FUnits write SetUnits;
    property ScrollOffset: Integer read FScrollOffset write SetScrollOffset;
    property PixelIncrement: Double read FPixelIncrement;
    property Scale: Double read FScale write FScale;
  end;

  TRMScrollBarKind = (rmsbHorizontal, rmsbVertical);
  TRMScrollEvent = procedure(Sender: TObject; Kind: TRMScrollBarKind) of object;
  TRMScrollBox = class;

  { TRMScrollBar }
  TRMScrollBar = class(TPersistent)
  private
    FScrollBox: TRMScrollBox;
    FKind: TRMScrollBarKind;
    FScrollInfo: TScrollInfo;
    FWidth: Integer;

    FSmallChange: Integer;
    FLargeChange: Integer;
    FRange: Integer;
    FPosition: Integer;
    FPageSize: Integer;
    FThumbValue: Integer;

    constructor Create(aScrollBox: TRMScrollBox; aKind: TRMScrollBarKind);
    procedure UpdateScrollBar;
    function GetBarFlag: Integer;
    procedure ScrollMessage(var aMessage: TWMScroll);

    function GetTrackPos: Integer;
    procedure SetPageSize(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure SetRange(Value: Integer);
  protected
  public
    property TrackPos: Integer read GetTrackPos;
  published
    property SmallChange: Integer read FSmallChange write FSmallChange;
    property LargeChange: Integer read FLargeChange write FLargeChange;
    property Position: Integer read FPosition write SetPosition;
    property Range: Integer read FRange write SetRange;
    property PageSize: Integer read FPageSize write SetPageSize;
    property ThumbValue: Integer read FThumbValue write FThumbValue;
    property Width: Integer read FWidth;
  end;

  { TRMScrollBox }
  TRMScrollBox = class(TCustomControl)
  private
    FHorzScrollBar: TRMScrollBar;
    FVertScrollBar: TRMScrollBar;
    FOnChange: TRMScrollEvent;

    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;

    property OnKeyDown;
    property HorzScrollBar: TRMScrollBar read FHorzScrollBar;
    property VertScrollBar: TRMScrollBar read FVertScrollBar;
  published
    property OnChange: TRMScrollEvent read FOnChange write FOnChange;
  end;

function RMNewLine: TRMSeparatorMenuItem;
function RMNewItem(const ACaption: string; AShortCut: TShortCut;
  AChecked, AEnabled: Boolean; AOnClick: TNotifyEvent; hCtx: THelpContext;
  const AName: string; ATag: integer = 0): TRMMenuItem;

implementation

uses RM_Utils, RM_Const, RM_Const1, RM_Class;

const
  sSpinUpBtn = 'RM_MYSPINUP';
  sSpinDownBtn = 'RM_MYSPINDOWN';
  cDropdownComboWidth = 11;

const
  InitRepeatPause = 400; { pause before repeat timer (ms) }
  RepeatPause = 100;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDockableToolbar }

constructor TRMDockableToolbar.Create(AOwner: TComponent);
begin
  inherited;
  EdgeBorders := [];
  Flat := True;
  AutoSize := True;
  DragKind := dkDock;
  DragMode := dmAutomatic;
end;

destructor TRMDockableToolbar.Destroy;
begin
  inherited;
end;

procedure TRMDockableToolbar.BeginUpdate;
begin
  DisableAlign;
end;

procedure TRMDockableToolbar.EndUpdate;
begin
  EnableAlign;
end;

procedure TRMDockableToolbar.DoDock(NewDockSite: TWinControl; var ARect: TRect);
begin
  inherited;
end;

function TRMDockableToolbar.DoUnDock(NewTarget: TWinControl;
  Client: TControl): Boolean;
begin
  Result := inherited DoUnDock(NewTarget, Client);
end;

procedure TRMDockableToolbar.AddControl(aControl: TControl);
begin
  aControl.Left := GetRightMostControlPos + 1;
  aControl.Parent := Self;
end;

function TRMDockableToolbar.GetRightMostControlPos: Integer;

  function _GetRightMostControl: TControl;
  var
    liIndex: Integer;
    lControl: TControl;
  begin

    Result := nil;

    for liIndex := 0 to ControlCount - 1 do
    begin
      lControl := Controls[liIndex];

      if (Result = nil) or ((lControl.Visible) and (lControl.Left > Result.Left)) then
        Result := lControl;

    end;
  end;

var
  lControl: TControl;
begin
  lControl := _GetRightMostControl;
  if (lControl <> nil) then
    Result := lControl.Left + lControl.Width
  else
    Result := 0;
end;

procedure TRMDockableToolbar.AlignControls(AControl: TControl; var ARect: TRect);
begin
  inherited;

  Width := GetRightMostControlPos;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarSeparator }

constructor TRMToolbarSeparator.Create(AOwner: TComponent);
begin
  inherited;

  Style := tbsSeparator;
  Grouped := False;
  Width := 8;
end;

function RMNewLine: TRMSeparatorMenuItem;
begin
  Result := TRMSeparatorMenuItem.Create(Application);
end;

function RMNewItem(const ACaption: string; AShortCut: TShortCut;
  AChecked, AEnabled: Boolean; AOnClick: TNotifyEvent; hCtx: THelpContext;
  const AName: string; ATag: integer = 0): TRMMenuItem;
begin
  Result := TRMMenuItem.Create(Application);
  with Result do
  begin
    Caption := ACaption;
    ShortCut := AShortCut;
    OnClick := AOnClick;
    HelpContext := hCtx;
    Checked := AChecked;
    Enabled := AEnabled;
    //    Name := AName;
    Tag := ATag;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMEdit}

procedure TRMEdit.SetAddTo(Value: TRMToolBar);
begin
{$IFDEF USE_TB2k}
  Value.Items.Add(self);
{$ELSE}
  if Parent <> Value then
    Parent := Value;
{$ENDIF}
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMMenuBar }

{$IFNDEF USE_TB2K}

procedure TRMMenuBar.BeginUpdate;
begin
 //
end;

procedure TRMMenuBar.EndUpdate;
begin
 //
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMToolbarSep}

procedure TRMToolbarSep.SetAddTo(Value: TRMToolBar);
begin
{$IFDEF USE_TB2k}
  Value.Items.Add(self);
{$ELSE}
  if Parent <> Value then
    Parent := Value;
{$ENDIF}
end;

{------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{$IFDEF USE_TB2k}

function TRMToolbar.GetDockedto: TRMDock;
begin
  Result := CurrentDock;
end;

procedure TRMToolbar.SetDockedto(Value: TRMDock);
begin
  CurrentDock := Value;
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMToolbarButton}

procedure TRMToolbarButton.SetAddTo(Value: TRMToolBar);
begin
{$IFDEF USE_TB2k}
  Value.Items.Add(self);
{$ELSE}
  if Parent <> Value then
    Parent := Value;
{$ENDIF}
end;

{$IFDEF USE_TB2k}

function TRMToolbarButton.GetDown: Boolean;
begin
  Result := Checked;
end;

procedure TRMToolbarButton.SetDown(Value: Boolean);
begin
  Checked := Value;
end;

function TRMToolbarButton.GetAllowAllUp: Boolean;
begin
  Result := AutoCheck;
end;

procedure TRMToolbarButton.SetAllowAllUp(Value: Boolean);
begin
  AutoCheck := Value;
end;
{$ENDIF}

//dejoy added begin

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMCustomMenuItem}
{$IFDEF USE_TB2k}

function TRMCustomMenuItem.GetRadioItem: boolean;
begin
  Result := AutoCheck;
end;

procedure TRMCustomMenuItem.SetRadioItem(Value: boolean);
begin
  AutoCheck := Value;
end;

procedure TRMCustomMenuItem.SetAddTo(Value: TRMToolBar);
begin
  Value.Items.Add(self);
end;
{$ELSE}

function TRMCustomMenuItem.GetImages: TCustomImageList;
var
  M: TMenu;
begin
  m := GetParentMenu;
  if m <> nil then
    Result := m.Images
  else
    Result := nil;
end;

procedure TRMCustomMenuItem.SetImages(Value: TCustomImageList);
var
  M: TMenu;
begin
  m := GetParentMenu;
  if m <> nil then
    with m do
    begin
      if Images <> Value then
        Images := Value;
    end;
end;
{$ENDIF}

procedure TRMCustomMenuItem.AddToMenu(Value: TRMMenuBar);
begin
  Value.Items.Add(self);
end;

procedure TRMCustomMenuItem.AddToMenu(Value: TRMCustomMenuItem);
begin
  Value.Add(self);
end;

procedure TRMCustomMenuItem.AddToMenu(Value: TRMSubMenuItem);
begin
  Value.Add(self);
end;

procedure TRMCustomMenuItem.AddToMenu(Value: TRMPopupMenu);
begin
  Value.Items.Add(self);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMSubMenuItem}
{$IFDEF USE_TB2K}

procedure TRMSubMenuItem.SetAddTo(Value: TRMToolBar);
begin
  Value.Items.Add(self);
end;

procedure TRMSubMenuItem.AddToMenu(Value: TRMMenuBar);
begin
  Value.Items.Add(self);
end;

procedure TRMSubMenuItem.AddToMenu(Value: TRMCustomMenuItem);
begin
  Value.Add(self);
end;

procedure TRMSubMenuItem.AddToMenu(Value: TRMSubMenuItem);
begin
  Value.Add(self);
end;

procedure TRMSubMenuItem.AddToMenu(Value: TRMPopupMenu);
begin
  Value.Items.Add(self);
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMSeparatorMenuItem }
{$IFDEF USE_TB2K}

procedure TRMSeparatorMenuItem.AddToMenu(Value: TRMMenuBar);
begin
  Value.Items.Add(self);
end;

procedure TRMSeparatorMenuItem.AddToMenu(Value: TRMCustomMenuItem);
begin
  Value.Add(self);
end;

procedure TRMSeparatorMenuItem.AddToMenu(Value: TRMSubMenuItem);
begin
  Value.Add(self);
end;

procedure TRMSeparatorMenuItem.AddToMenu(Value: TRMPopupMenu);
begin
  Value.Items.Add(self);
end;

{$ELSE}

constructor TRMSeparatorMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '-';
end;
{$ENDIF}

{ TRMCustomComboBox97 }

constructor TRMCustomComboBox97.Create(AOwner: TComponent);
begin
  inherited;

  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL) + 2;
  FOldColor := inherited Color;
  FOldParentColor := inherited ParentColor;
  FFlat := True;
end;

procedure TRMCustomComboBox97.SetFlat(const Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    Ctl3D := not Value;
    Invalidate;
  end;
end;

// Verifica si el botón todavía deba estar presionado

procedure TRMCustomComboBox97.CMEnter(var Message: TCMEnter);
begin
  inherited;

  if not (csDesigning in ComponentState) then
    DrawBorders;
end;

procedure TRMCustomComboBox97.CMExit(var Message: TCMExit);
begin
  inherited;

  if not (csDesigning in ComponentState) then
    DrawBorders;
end;

procedure TRMCustomComboBox97.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  if not FMouseInControl and Enabled then
  begin
    FMouseInControl := True;
    DrawBorders;
  end;
end;

procedure TRMCustomComboBox97.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if FMouseInControl and Enabled then
  begin
    FMouseInControl := False;
    DrawBorders
  end;
end;

procedure TRMCustomComboBox97.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;

  // Si se desea plano
  if FFlat then
    // Si se habilita se recupera su color anterior ?
    // si se inhabilita se guarda su color actual y se utiliza el del contenedor,
    // as?se d?la apariencia del ComboBox inhabilitado de Office97.
    if Enabled then
    begin
      inherited Color := FOldColor;
      inherited ParentColor := FOldParentColor;
    end
    else
    begin
      FOldParentColor := inherited Parentcolor;
      FOldColor := inherited Color;
      inherited ParentColor := True;
    end;
end;

procedure TRMCustomComboBox97.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
  procedure DrawButton;
  var
    ARect: TRect;
  begin
    // Obtiene las coordenadas de los límites del botón
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    Inc(ARect.Left, ClientWidth - FButtonWidth);
    InflateRect(ARect, -1, -1);
    // Dibuja el botón
    DrawFrameControl(DC, ARect, DFC_SCROLL, DFCS_SCROLLCOMBOBOX or DFCS_FLAT);
    // Notifica a Windows que ya no tiene que dibujar el botón
    ExcludeClipRect(DC, ClientWidth - FButtonWidth - 4, 0, ClientWidth, ClientHeight);
  end;
begin
  // Si no es plano sólo se hacer lo de omisión
  if not FFlat then
  begin
    inherited;
    Exit;
  end;

  // Utiliza o crea el dispositivo de contexto
  if Message.DC = 0 then
    DC := BeginPaint(Handle, PS)
  else
    DC := Message.DC;
  try
    // Si el estilo as?lo requiere dibuja el botón y una base
    if Style <> csSimple then
    begin
      FillRect(DC, ClientRect, Brush.Handle);
      DrawButton; //(DC);
    end;
    // Dibuja el ComboBox
    PaintWindow(DC);
  finally
    // Elimina el dispositivo de contexto si fu?creado aqu?
    if Message.DC = 0 then
      EndPaint(Handle, PS);
  end;
  // Dibuja los bordes del ComboBox y del botón incluido
  DrawBorders;
end;

function TRMCustomComboBox97.NeedDraw3DBorder: Boolean;
begin
  // Se requiere dibujar el borde cuando el ratón esta encima
  // o cuando es el control activo.
  if csDesigning in ComponentState then
    Result := Enabled
  else
    Result := FMouseInControl or (Screen.ActiveControl = Self);
end;

// Dibuja el borde del botón incluido

procedure TRMCustomComboBox97.DrawButtonBorder(DC: HDC);
const
  Flags: array[Boolean] of Integer = (0, BF_FLAT);
var
  ARect: TRect;
  BtnFaceBrush: HBRUSH;
begin
  // Notifica a Windows que no tiene que dibujar sobre botón
  ExcludeClipRect(DC, ClientWidth - FButtonWidth + 4, 4,
    ClientWidth - 4, ClientHeight - 4);
  // Obtiene las coordenadas de los límites del botón
  GetWindowRect(Handle, ARect);
  OffsetRect(ARect, -ARect.Left, -ARect.Top);
  Inc(ARect.Left, ClientWidth - FButtonWidth - 2);
  InflateRect(ARect, -2, -2);

  // Dibuja un borde 3D o plano según se requiera
  if NeedDraw3DBorder then
    DrawEdge(DC, ARect, EDGE_RAISED, BF_RECT or Flags[csButtonPressed in FEditState])
  else
  begin
    BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
    try
      InflateRect(ARect, -1, -1);
      FillRect(DC, ARect, BtnFaceBrush);
    finally
      DeleteObject(BtnFaceBrush);
    end;
  end;

  // Notifica a Windows que ya no tiene que dibujar el botón
  ExcludeClipRect(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

// Dibuja el borde del ComboBox

procedure TRMCustomComboBox97.DrawControlBorder(DC: HDC);
var
  ARect: TRect;
  BtnFaceBrush, WindowBrush: HBRUSH; // Brochas necesarias para el efecto 3D
begin
  // Crea las brochas necesarias para el efecto 3D
  BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  WindowBrush := CreateSolidBrush(GetSysColor(COLOR_WINDOW));
  try
    // Obtiene las coordenadas de los límites del ComboBox
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    // Dibuja un borde 3D o plano según se requiera
    if NeedDraw3DBorder then
    begin
      DrawEdge(DC, ARect, BDR_SUNKENOUTER, BF_RECT or BF_ADJUST);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, WindowBrush);
    end
    else
    begin
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, WindowBrush);
    end;
  finally
    // Elimina las brochas
    DeleteObject(WindowBrush);
    DeleteObject(BtnFaceBrush);
  end;
end;

// Dibuja los bordes del ComboBox y del botón incluido

procedure TRMCustomComboBox97.DrawBorders;
var
  lDC: HDC;
begin
  if not FFlat then Exit;

  lDC := GetDC(Handle); //GetWindowDC(Handle);
  try
    DrawControlBorder(lDC);
    if Style <> csSimple then
      DrawButtonBorder(lDC);
  finally
    ReleaseDC(Handle, lDC);
  end;
end;

procedure TRMCustomComboBox97.TrackButtonPressed(X, Y: Integer);
var
  ARect: TRect;
begin
  SetRect(ARect, ClientWidth - FButtonWidth, 0, ClientWidth, ClientHeight);
  if (csButtonPressed in FEditState) and not PtInRect(ARect, Point(X, Y)) then
  begin
    Exclude(FEditState, csButtonPressed);
    DrawBorders;
  end;
end;

procedure TRMCustomComboBox97.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if DroppedDown then
  begin
    Include(FEditState, csButtonPressed);
    Include(FEditState, csMouseCaptured);
    Invalidate;
  end;

  inherited;
end;

procedure TRMCustomComboBox97.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if csMouseCaptured in FEditState then
    TrackButtonPressed(X, Y);

  inherited;
end;

procedure TRMCustomComboBox97.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  TrackButtonPressed(-1, -1);

  inherited;
end;

procedure TRMCustomComboBox97.CMMouseWheel(var Message: TCMMouseWheel);
begin
  Abort;
end;

{ TRMSpinButton }
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUpBitmap := TBitmap.Create;
  FDownBitmap := TBitmap.Create;
  FUpBitmap.Handle := LoadBitmap(HInstance, sSpinUpBtn);
  FDownBitmap.Handle := LoadBitmap(HInstance, sSpinDownBtn);
  FUpBitmap.OnChange := GlyphChanged;
  FDownBitmap.OnChange := GlyphChanged;
  Height := 20;
  Width := 20;
  FTopDownBtn := TBitmap.Create;
  FBottomDownBtn := TBitmap.Create;
  FNotDownBtn := TBitmap.Create;
  DrawAllBitmap;
  FLastDown := rmsbNotDown;
end;

destructor TRMSpinButton.Destroy;
begin
  FTopDownBtn.Free;
  FBottomDownBtn.Free;
  FNotDownBtn.Free;
  FUpBitmap.Free;
  FDownBitmap.Free;
  FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TRMSpinButton.GlyphChanged(Sender: TObject);
begin
  FInvalidate := True;
  Invalidate;
end;

procedure TRMSpinButton.SetDown(Value: TRMSpinButtonState);
var
  OldState: TRMSpinButtonState;
begin
  OldState := FDown;
  FDown := Value;
  if OldState <> FDown then
    Repaint;
end;

procedure TRMSpinButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TRMSpinButton.Paint;
begin
  if not Enabled and not (csDesigning in ComponentState) then
    FDragging := False;
  if (FNotDownBtn.Height <> Height) or (FNotDownBtn.Width <> Width) or FInvalidate then
    DrawAllBitmap;
  FInvalidate := False;
  with Canvas do
    case FDown of
      rmsbNotDown: Draw(0, 0, FNotDownBtn);
      rmsbTopDown: Draw(0, 0, FTopDownBtn);
      rmsbBottomDown: Draw(0, 0, FBottomDownBtn);
    end;
end;

procedure TRMSpinButton.DrawAllBitmap;
begin
  DrawBitmap(FTopDownBtn, rmsbTopDown);
  DrawBitmap(FBottomDownBtn, rmsbBottomDown);
  DrawBitmap(FNotDownBtn, rmsbNotDown);
end;

procedure TRMSpinButton.DrawBitmap(ABitmap: TBitmap; ADownState: TRMSpinButtonState);
var
  R, RSrc: TRect;
  dRect: Integer;
begin
  ABitmap.Height := Height;
  ABitmap.Width := Width;
  with ABitmap.Canvas do
  begin
    R := Bounds(0, 0, Width, Height);
    Pen.Width := 1;
    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    FillRect(R);
    { buttons frame }
    Pen.Color := clWindowFrame;
    Rectangle(0, 0, Width, Height);
    MoveTo(-1, Height);
    LineTo(Width, -1);
    { top button }
    if ADownState = rmsbTopDown then
      Pen.Color := clBtnShadow
    else
      Pen.Color := clBtnHighlight;
    MoveTo(1, Height - 4);
    LineTo(1, 1);
    LineTo(Width - 3, 1);
    if ADownState = rmsbTopDown then
      Pen.Color := clBtnHighlight
    else
      Pen.Color := clBtnShadow;
    if ADownState <> rmsbTopDown then
    begin
      MoveTo(1, Height - 3);
      LineTo(Width - 2, 0);
    end;
    { bottom button }
    if ADownState = rmsbBottomDown then
      Pen.Color := clBtnHighlight
    else
      Pen.Color := clBtnShadow;
    MoveTo(2, Height - 2);
    LineTo(Width - 2, Height - 2);
    LineTo(Width - 2, 1);
    if ADownState = rmsbBottomDown then
      Pen.Color := clBtnShadow
    else
      Pen.Color := clBtnHighlight;
    MoveTo(2, Height - 2);
    LineTo(Width - 1, 1);
    { top glyph }
    dRect := 1;
    if ADownState = rmsbTopDown then
      Inc(dRect);
    R := Bounds(Round((Width / 4) - (FUpBitmap.Width / 2)) + dRect,
      Round((Height / 4) - (FUpBitmap.Height / 2)) + dRect, FUpBitmap.Width,
      FUpBitmap.Height);
    RSrc := Bounds(0, 0, FUpBitmap.Width, FUpBitmap.Height);
    BrushCopy(R, FUpBitmap, RSrc, FUpBitmap.TransparentColor);
    { bottom glyph }
    R := Bounds(Round((3 * Width / 4) - (FDownBitmap.Width / 2)) - 1,
      Round((3 * Height / 4) - (FDownBitmap.Height / 2)) - 1,
      FDownBitmap.Width, FDownBitmap.Height);
    RSrc := Bounds(0, 0, FDownBitmap.Width, FDownBitmap.Height);
    BrushCopy(R, FDownBitmap, RSrc, FDownBitmap.TransparentColor);
    if ADownState = rmsbBottomDown then
    begin
      Pen.Color := clBtnShadow;
      MoveTo(3, Height - 2);
      LineTo(Width - 1, 2);
    end;
  end;
end;

procedure TRMSpinButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FInvalidate := True;
  Invalidate;
end;

procedure TRMSpinButton.TopClick;
begin
  if Assigned(FOnTopClick) then
  begin
    FOnTopClick(Self);
    if not (csLButtonDown in ControlState) then
      FDown := rmsbNotDown;
  end;
end;

procedure TRMSpinButton.BottomClick;
begin
  if Assigned(FOnBottomClick) then
  begin
    FOnBottomClick(Self);
    if not (csLButtonDown in ControlState) then
      FDown := rmsbNotDown;
  end;
end;

procedure TRMSpinButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if (FFocusControl <> nil) and FFocusControl.TabStop and
      FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
      FFocusControl.SetFocus;

    if FDown = rmsbNotDown then
    begin
      FLastDown := FDown;
      if Y > (-(Height / Width) * X + Height) then
      begin
        FDown := rmsbBottomDown;
        BottomClick;
      end
      else
      begin
        FDown := rmsbTopDown;
        TopClick;
      end;
      if FLastDown <> FDown then
      begin
        FLastDown := FDown;
        Repaint;
      end;
      if FRepeatTimer = nil then
        FRepeatTimer := TTimer.Create(Self);
      FRepeatTimer.OnTimer := TimerExpired;
      FRepeatTimer.Interval := InitRepeatPause;
      FRepeatTimer.Enabled := True;
    end;
    FDragging := True;
  end;
end;

procedure TRMSpinButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TRMSpinButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) then
    begin
      NewState := FDown;
      if Y > (-(Width / Height) * X + Height) then
      begin
        if (FDown <> rmsbBottomDown) then
        begin
          if FLastDown = rmsbBottomDown then
            FDown := rmsbBottomDown
          else
            FDown := rmsbNotDown;
          if NewState <> FDown then
            Repaint;
        end;
      end
      else
      begin
        if (FDown <> rmsbTopDown) then
        begin
          if (FLastDown = rmsbTopDown) then
            FDown := rmsbTopDown
          else
            FDown := rmsbNotDown;
          if NewState <> FDown then
            Repaint;
        end;
      end;
    end
    else if FDown <> rmsbNotDown then
    begin
      FDown := rmsbNotDown;
      Repaint;
    end;
  end;
end;

procedure TRMSpinButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then
  begin
    FDragging := False;
    if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) then
    begin
      FDown := rmsbNotDown;
      FLastDown := rmsbNotDown;
      Repaint;
    end;
  end;
end;

procedure TRMSpinButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FDown <> rmsbNotDown) and MouseCapture then
  begin
    try
      if FDown = rmsbBottomDown then
        BottomClick
      else
        TopClick;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

function DefBtnWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXVSCROLL);
  if Result > 15 then
    Result := 15;
end;

type
  TRxUpDown = class(TCustomUpDown)
  private
    FChanging: Boolean;
    procedure ScrollMessage(var Message: TWMVScroll);
    procedure WMHScroll(var Message: TWMHScroll); message CN_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnClick;
  end;

constructor TRxUpDown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Orientation := udVertical;
  Min := -1;
  Max := 1;
  Position := 0;
end;

destructor TRxUpDown.Destroy;
begin
  OnClick := nil;
  inherited Destroy;
end;

procedure TRxUpDown.ScrollMessage(var Message: TWMVScroll);
begin
  if Message.ScrollCode = SB_THUMBPOSITION then
  begin
    if not FChanging then
    begin
      FChanging := True;
      try
        if Message.Pos > 0 then
          Click(btNext)
        else if Message.Pos < 0 then
          Click(btPrev);
        if HandleAllocated then
          SendMessage(Handle, UDM_SETPOS, 0, 0);
      finally
        FChanging := False;
      end;
    end;
  end;
end;

procedure TRxUpDown.WMHScroll(var Message: TWMHScroll);
begin
  ScrollMessage(TWMVScroll(Message));
end;

procedure TRxUpDown.WMVScroll(var Message: TWMVScroll);
begin
  ScrollMessage(Message);
end;

procedure TRxUpDown.WMSize(var Message: TWMSize);
begin
  inherited;
  if Width <> DefBtnWidth then
    Width := DefBtnWidth;
end;

{ TRMSpinEdit }

constructor TRMSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1.0;
  FDecimal := 2;
  FMinValue := 0;
  FMaxValue := MaxInt;
  FEditorEnabled := True;
  FArrowKeys := True;
  RecreateButton;
end;

destructor TRMSpinEdit.Destroy;
begin
  Destroying;
  FChanging := True;
  if FButton <> nil then
  begin
    FButton.Free;
    FButton := nil;
    FBtnWindow.Free;
    FBtnWindow := nil;
  end;
  if FUpDown <> nil then
  begin
    FUpDown.Free;
    FUpDown := nil;
  end;
  inherited Destroy;
end;

procedure TRMSpinEdit.RecreateButton;
begin
  if (csDestroying in ComponentState) then
    Exit;
  FButton.Free;
  FButton := nil;
  FBtnWindow.Free;
  FBtnWindow := nil;
  FUpDown.Free;
  FUpDown := nil;
  FUpDown := TRxUpDown.Create(Self);
  with TRxUpDown(FUpDown) do
  begin
    Visible := True;
    SetBounds(0, 0, DefBtnWidth, Self.Height);
{$IFDEF COMPILER4_UP}
    if (BiDiMode = bdRightToLeft) then
      Align := alLeft
    else
{$ENDIF}
      Align := alRight;
    Parent := Self;
    OnClick := UpDownClick;
  end;
end;

procedure TRMSpinEdit.SetArrowKeys(Value: Boolean);
begin
  FArrowKeys := Value;
  ResizeButton;
end;

procedure TRMSpinEdit.UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  if TabStop and CanFocus then
    SetFocus;
  case Button of
    btNext: UpClick(Sender);
    btPrev: DownClick(Sender);
  end;
end;

function TRMSpinEdit.GetButtonWidth: Integer;
begin
  if FUpDown <> nil then
    Result := FUpDown.Width
  else if FButton <> nil then
    Result := FButton.Width
  else
    Result := DefBtnWidth;
end;

procedure TRMSpinEdit.ResizeButton;
var
  R: TRect;
begin
  if FUpDown <> nil then
  begin
    FUpDown.Width := DefBtnWidth;
{$IFDEF COMPILER4_UP}
    if (BiDiMode = bdRightToLeft) then
      FUpDown.Align := alLeft
    else
{$ENDIF}
      FUpDown.Align := alRight;
  end
  else if FButton <> nil then
  begin { bkDiagonal }
    if NewStyleControls and Ctl3D and (BorderStyle = bsSingle) then
      R := Bounds(Width - Height - 1, -1, Height - 3, Height - 3)
    else
      R := Bounds(Width - Height, 0, Height, Height);
{$IFDEF COMPILER4_UP}
    if (BiDiMode = bdRightToLeft) then
    begin
      if NewStyleControls and Ctl3D and (BorderStyle = bsSingle) then
      begin
        R.Left := -1;
        R.Right := Height - 4;
      end
      else
      begin
        R.Left := 0;
        R.Right := Height;
      end;
    end;
{$ENDIF}
    with R do
      FBtnWindow.SetBounds(Left, Top, Right - Left, Bottom - Top);
    FButton.SetBounds(0, 0, FBtnWindow.Width, FBtnWindow.Height);
  end;
end;

procedure TRMSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if ArrowKeys and (Key in [VK_UP, VK_DOWN]) then
  begin
    if Key = VK_UP then
      UpClick(Self)
    else if Key = VK_DOWN then
      DownClick(Self);
    Key := 0;
  end;
end;

procedure TRMSpinEdit.Change;
begin
  if not FChanging then
    inherited Change;
end;

procedure TRMSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then
  begin
    inherited KeyPress(Key);
    if (Key = Char(VK_RETURN)) or (Key = Char(VK_ESCAPE)) then
    begin
      { must catch and remove this, since is actually multi-line }
      GetParentForm(Self).Perform(CM_DIALOGKEY, Byte(Key), 0);
      if Key = Char(VK_RETURN) then
        Key := #0;
    end;
  end;
end;

function TRMSpinEdit.IsValidChar(Key: Char): Boolean;
var
  ValidChars: set of Char;
begin
  ValidChars := ['+', '-', '0'..'9'];
  if ValueType = rmvtFloat then
  begin
    if Pos(DecimalSeparator, Text) = 0 then
      ValidChars := ValidChars + [DecimalSeparator];
    if Pos('E', AnsiUpperCase(Text)) = 0 then
      ValidChars := ValidChars + ['e', 'E'];
  end;
  Result := (Key in ValidChars) or (Key < #32);
  if not FEditorEnabled and Result and ((Key >= #32) or
    (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then
    Result := False;
end;

procedure TRMSpinEdit.CreateParams(var Params: TCreateParams);
const
{$IFDEF COMPILER4_UP}
  Alignments: array[Boolean, TAlignment] of DWORD =
  ((ES_LEFT, ES_RIGHT, ES_CENTER), (ES_RIGHT, ES_LEFT, ES_CENTER));
{$ELSE}
  Alignments: array[TAlignment] of Longint = (ES_LEFT, ES_RIGHT, ES_CENTER);
{$ENDIF}
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN or
{$IFDEF COMPILER4_UP}
  Alignments[UseRightToLeftAlignment, FAlignment];
{$ELSE}
  Alignments[FAlignment];
{$ENDIF}
end;

procedure TRMSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TRMSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
{$IFDEF COMPILER4_UP}
  if (BiDiMode = bdRightToLeft) then
    SetRect(Loc, GetButtonWidth + 1, 0, ClientWidth - 1,
      ClientHeight + 1)
  else
{$ENDIF}
    SetRect(Loc, 0, 0, ClientWidth - GetButtonWidth - 2, ClientHeight + 1);
  SendMessage(Handle, EM_SETRECTNP, 0, Longint(@Loc));
end;

procedure TRMSpinEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TRMSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  { text edit bug: if size to less than minheight, then edit ctrl does
    not display the text }
  if Height < MinHeight then
    Height := MinHeight
  else
  begin
    ResizeButton;
    SetEditRect;
  end;
end;

procedure TRMSpinEdit.GetTextHeight(var SysHeight, Height: Integer);
var
  DC: HDC;
  SaveFont: HFont;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(Handle);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(Handle, DC);
  SysHeight := SysMetrics.tmHeight;
  Height := Metrics.tmHeight;
end;

function TRMSpinEdit.GetMinHeight: Integer;
var
  I, H: Integer;
begin
  GetTextHeight(I, H);
  if I > H then
    I := H;
  Result := H + (GetSystemMetrics(SM_CYBORDER) * 4) + 1;
end;

procedure TRMSpinEdit.UpClick(Sender: TObject);
var
  OldText: string;
begin
  if ReadOnly then
    MessageBeep(0)
  else
  begin
    FChanging := True;
    try
      OldText := inherited Text;
      Value := Value + FIncrement;
    finally
      FChanging := False;
    end;
    if CompareText(inherited Text, OldText) <> 0 then
    begin
      Modified := True;
      Change;
    end;
    if Assigned(FOnTopClick) then
      FOnTopClick(Self);
  end;
end;

procedure TRMSpinEdit.DownClick(Sender: TObject);
var
  OldText: string;
begin
  if ReadOnly then
    MessageBeep(0)
  else
  begin
    FChanging := True;
    try
      OldText := inherited Text;
      Value := Value - FIncrement;
    finally
      FChanging := False;
    end;
    if CompareText(inherited Text, OldText) <> 0 then
    begin
      Modified := True;
      Change;
    end;
    if Assigned(FOnBottomClick) then
      FOnBottomClick(Self);
  end;
end;

{$IFDEF COMPILER4_UP}

procedure TRMSpinEdit.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;
{$ENDIF}

procedure TRMSpinEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;

procedure TRMSpinEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  ResizeButton;
  SetEditRect;
end;

procedure TRMSpinEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if FUpDown <> nil then
  begin
    FUpDown.Enabled := Enabled;
    ResizeButton;
  end;
  if FButton <> nil then
    FButton.Enabled := Enabled;
end;

procedure TRMSpinEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then
    Exit;
  inherited;
end;

procedure TRMSpinEdit.WMCut(var Message: TWMCut);
begin
  if not FEditorEnabled or ReadOnly then
    Exit;
  inherited;
end;

procedure TRMSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> Value then
    SetValue(Value);
end;

procedure TRMSpinEdit.CMEnter(var Message: TMessage);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;

function TRMSpinEdit.GetValue: Extended;
begin
  try
    if (Text <> '') and (Text <> '-') then
    begin
      if ValueType = rmvtFloat then
        Result := StrToFloat(Text)
      else
        Result := StrToInt(Text);
    end
    else
      Result := 0;
  except
    if ValueType = rmvtFloat then
      Result := FMinValue
    else
      Result := Trunc(FMinValue);
  end;
end;

procedure TRMSpinEdit.SetValue(NewValue: Extended);
begin
  if ValueType = rmvtFloat then
    Text := FloatToStrF(CheckValue(NewValue), ffFixed, 15, FDecimal)
  else
    Text := IntToStr(Round(CheckValue(NewValue)));
end;

function TRMSpinEdit.GetAsInteger: Longint;
begin
  Result := Trunc(GetValue);
end;

procedure TRMSpinEdit.SetAsInteger(NewValue: Longint);
begin
  SetValue(NewValue);
end;

procedure TRMSpinEdit.SetValueType(NewType: TRMValueType);
begin
  if FValueType <> NewType then
  begin
    FValueType := NewType;
    Value := GetValue;
    if FValueType in [rmvtInteger] then
    begin
      FIncrement := Round(FIncrement);
      if FIncrement = 0 then
        FIncrement := 1;
    end;
  end;
end;

function TRMSpinEdit.IsIncrementStored: Boolean;
begin
  Result := FIncrement <> 1.0;
end;

function TRMSpinEdit.IsValueStored: Boolean;
begin
  Result := (GetValue <> 0.0);
end;

procedure TRMSpinEdit.SetDecimal(NewValue: Byte);
begin
  if FDecimal <> NewValue then
  begin
    FDecimal := NewValue;
    Value := GetValue;
  end;
end;

function TRMSpinEdit.CheckValue(NewValue: Extended): Extended;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then
  begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMColorPickerButton}

{$IFDEF USE_INTERNAL_JVCL}
const
  LineColorButtonCount = 8;
  SubColorButtonColors: array[0..MaxColorButtonNumber - 1] of TColor = (
    $000000, $003399, $003333, $003300, $663300, $800000, $993333, $333333,
    $000080, $0066FF, $008080, $008000, $808000, $FF0000, $996666, $808080,
    $0000FF, $0099FF, $00CC99, $669933, $CCCC33, $FF6633, $800080, $999999,
    $FF00FF, $00CCFF, $00FFFF, $00FF00, $FFFF00, $FFCC00, $663399, $C0C0C0,
    $CC99FF, $99CCFF, $99FFFF, $CCFFCC, $FFFFCC, $FFCC99, $FF99CC, $FFFFFF);

procedure TRMColorSpeedButton.Paint;
var
  C, S, X, Y: integer;
  R: TRect;
begin
  inherited Paint;

  R := Rect(0, 0, Width - 1, Height - 1);
  with Canvas do
  begin
    if Glyph.Handle <> 0 then
    begin
{$IFDEF USE_TB2K}
      X := ((Width + 1) div 2) - 8 + Integer(FState in [TButtonState(bsDown)]);
      Y := ((Height + 1) div 2) + 4 + Integer(FState in [TButtonState(bsDown)]);
{$ELSE}
      X := ((Width + 1) div 2) - 8 + Integer(FState in [bsDown]);
      Y := ((Height + 1) div 2) + 4 + Integer(FState in [bsDown]);
{$ENDIF}
      if Enabled then
      begin
        Pen.Color := CurColor;
        Brush.Color := CurColor;
      end
      else
      begin
        Pen.Color := clInactiveCaption;
        Brush.Color := clInactiveCaption;
      end;
      Rectangle(X, Y, X + 16, Y + 4);
    end
    else if Caption = '' then
    begin
      C := (R.Bottom - R.Top) div 6 + 1;
      if Enabled then
      begin
        Pen.Color := clGray;
        Brush.Color := CurColor;
      end
      else
      begin
        Pen.Color := clInactiveCaption;
        Brush.Color := clBtnFace;
      end;
      Brush.Style := bsSolid;
      Rectangle(R.Left + C, R.Top + C, R.Right - C + 1, R.Bottom - C + 1);
    end
    else
    begin
      C := (R.Bottom - R.Top) div 6 + 3;
      S := (R.Bottom - R.Top) div 7;
      if Enabled then
        Pen.Color := clGray
      else
        Pen.Color := clInactiveCaption;
      Brush.Style := bsClear;
      Polygon([Point(R.Left + S, R.Top + S), Point(R.Right - S, R.Top + S), Point(R.Right - S, R.Bottom - S), Point(R.Left + S, R.Bottom - S)]);
      if Enabled then
      begin
        Pen.Color := clGray;
        Brush.Color := CurColor;
      end
      else
      begin
        Pen.Color := clInactiveCaption;
        Brush.Color := clBtnFace;
      end;
      Brush.Style := bsSolid;

      Rectangle(R.Left + C + 1, R.Top + C, R.Bottom - C + 2 + 1, R.Bottom - C + 2);
    end;
  end;
end;

constructor TRMColorPickerButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FPopup := nil;
{$IFNDEF USE_TB2K}
  DropdownCombo := True;
  DropdownAlways := True;
{$ENDIF}
  FCurrentColor := clDefault;
  FColorType := rmptFill;
  FAutoColor := clDefault;
  FAutoCaption := RMLoadStr(STransparent);

  FColorDialog := TColorDialog.Create(Self);
  FColorDialog.Options := [cdFullOpen, cdSolidColor, cdAnyColor];

  FButtonHeight := 22;
  FColorSize := 18;
  FColorSpace := 0;
  FColorSpaceTop := 4;
  FColorSpaceBottom := 4;
  FTopMargin := 2;
  FBottomMargin := 4;
  FHoriMargin := 7;
end;

destructor TRMColorPickerButton.Destroy;
begin
  FreeAndNil(FPopup);
  inherited Destroy;
end;

procedure TRMColorPickerButton.DrawButtonGlyph(aColor: TColor);
begin
  Glyph.Canvas.Brush.Color := aColor;
  Glyph.Canvas.Brush.Style := bsSolid;
  Glyph.Canvas.FillRect(Rect(0, 12, 15, 15));

  Invalidate;
end;

procedure TRMColorPickerButton.ColorButtonClick(Sender: TObject);
begin
  if TRMToolbarButton(Sender).Tag = FOtherButton.Tag then // Other Button
  begin
    FColorDialog.Color := FCurrentColor;
    if FColorDialog.Execute then
    begin
      SetSelectedColor(FColorDialog.Color);
      if Assigned(FOnColorChange) then FOnColorChange(Self);
    end;
  end
  else
  begin
    SetSelectedColor(TRMColorSpeedButton(Sender).CurColor);
    if Assigned(FOnColorChange) then FOnColorChange(Self);
  end;

  FPopup.Close(nil);
end;

function TRMColorPickerButton.GetDropDownPanel: TRMPopupWindow;
var
  i: Integer;

  procedure _SetButtonDown;
  var
    i: Integer;
  begin
    FAutoButton.Down := (FAutoButton.Color = FCurrentColor);
    if not FAutoButton.Down then
    begin
      for i := 0 to MaxColorButtonNumber - 1 do
      begin
        FColorButtons[i].Down := (FColorButtons[i].CurColor = FCurrentColor);
      end;
    end;
  end;

begin
  if FPopup <> nil then
  begin
    Result := FPopup;
    _SetButtonDown;
    Exit;
  end;

  FPopup := TRMPopupWindow.CreateNew(nil);
  FPopup.Font.Assign(Font);
  FPopup.ClientWidth := FHoriMargin * 2 + LineColorButtonCount * (FColorSpace + FColorSize);
  FPopup.ClientHeight := FTopMargin + FBottomMargin + FColorSpaceTop * 2 + FColorSpaceBottom +
    (FButtonHeight + FColorSpaceTop) * (MaxColorButtonNumber div LineColorButtonCount);

  FAutoButton := TRMColorSpeedButton.Create(FPopup);
  with FAutoButton do
  begin
    Parent := FPopup;
    Flat := True;
    GroupIndex := 1;
    Tag := MaxColorButtonNumber + 1;
    Down := true;
    AllowAllUp := true;
    CurColor := Self.FAutoColor;
    Caption := 'Automatic';
    OnClick := ColorButtonClick;

    SetBounds(FHoriMargin, FTopMargin + FDragBarHeight + FDragBarSpace + FDragBarHeight,
      FPopup.ClientWidth - FHoriMargin * 2, FButtonHeight);
    Caption := FAutoCaption;
  end;

  for i := 0 to MaxColorButtonNumber - 1 do
  begin
    FColorButtons[i] := TRMColorSpeedButton.Create(FPopup);
    with FColorButtons[i] do
    begin
      Parent := FPopup;
      Flat := True;
      GroupIndex := 1;
      AllowAllUp := true;
      CurColor := SubColorButtonColors[I];
      Tag := I;
      OnClick := ColorButtonClick;

      SetBounds(FAutoButton.Left + (I mod LineColorButtonCount) * (FColorSpace + FColorSize),
        FAutoButton.Top + FAutoButton.Height + FColorSpaceTop + (I div LineColorButtonCount) * (FColorSpace + FColorSize),
        FColorSize, FColorSize);
    end;
  end;

  FOtherButton := {$IFDEF USE_TB2K}TSpeedButton{$ELSE}TRMToolbarButton{$ENDIF}.Create(FPopup);
  with FOtherButton do
  begin
    Parent := FPopup;
    Flat := True;
    Tag := MaxColorButtonNumber + 2;
    Caption := RMLoadStr(SOther);
    SetBounds(FAutoButton.Left,
      FColorButtons[MaxColorButtonNumber - 1].Top + FColorSize + FColorSpaceBottom,
      FAutoButton.Width, FButtonHeight);

    OnClick := ColorButtonClick;
  end;

  DropdownPanel := FPopup;
  Result := FPopup;
  _SetButtonDown;
end;

function TRMColorPickerButton.GetCustomColors: TStrings;
begin
  Result := FColorDialog.CustomColors;
end;

procedure TRMColorPickerButton.SetCustomColors(const Value: TStrings);
begin
  FColorDialog.CustomColors.Assign(Value);
end;

procedure TRMColorPickerButton.SetColorType(const Value: TRMColorType);
begin
  case Value of
    rmptFill:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_BACKGROUDCOLOR');
        FAutoColor := clNone;
        FAutoCaption := RMLoadStr(STransparent);
      end;
    rmptLine:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_LINECOLOR');
        FAutoColor := clBlack; //clWindow;
        FAutoCaption := RMLoadStr(rmRes + 878);
      end;
    rmptFont:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_FONTCOLOR');
        FAutoColor := clWindowText;
        FAutoCaption := RMLoadStr(rmRes + 878);
      end;
    rmptHighlight:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_HIGHLIGHTCOLOR');
        FAutoColor := clWindow;
        FAutoCaption := RMLoadStr(rmRes + 878);
      end;
  end;

  DrawButtonGlyph(FCurrentColor);
end;

procedure TRMColorPickerButton.SetSelectedColor(const Value: TColor);
begin
  if FCurrentColor <> Value then
  begin
    FCurrentColor := Value;
  end;

  DrawButtonGlyph(FCurrentColor);
end;
{$ELSE USE_INTERNAL_JVCL}

constructor TRMColorPickerButton.Create(AOwner: TComponent);
begin
  inherited;
  Properties.DefaultColorCaption := RMLoadStr(STransparent);
  Properties.CustomColorCaption := RMLoadStr(SOther);
end;

function TRMColorPickerButton.GetCurrentColor: TColor;
begin
  Result := SelectedColor;
end;

procedure TRMColorPickerButton.SetColorType(const Value: TRMColorType);
begin
  FColorType := Value;
  case Value of
    rmptFill:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_BACKGROUDCOLOR');
        Properties.DefaultColorColor := clNone;
        Properties.DefaultColorCaption := RMLoadStr(STransparent);
      end;
    rmptLine:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_LINECOLOR');
        Properties.DefaultColorColor := clBlack;
        Properties.DefaultColorCaption := RMLoadStr(rmRes + 878);
      end;
    rmptFont:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_FONTCOLOR');
        Properties.DefaultColorColor := clWindowText;
        Properties.DefaultColorCaption := RMLoadStr(rmRes + 878);
      end;
    rmptHighlight:
      begin
        Glyph.Handle := LoadBitmap(hInstance, 'RM_HIGHLIGHTCOLOR');
        Properties.DefaultColorColor := clWindow;
        Properties.DefaultColorCaption := RMLoadStr(rmRes + 878);
      end;
  end;
end;


procedure TRMColorPickerButton.SetCurrentColor(const Value: TColor);
begin
  SelectedColor :=Value;
end;
{$ENDIF USE_INTERNAL_JVCL}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

function PixelsPerCentimeter: Double;
begin
  Result := Screen.PixelsPerInch / 2.54;
end;

{ TRMDesignerRuler.Create }

constructor TRMDesignerRuler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FScale := 1;
  Color := clBtnFace;
  Font.Color := clBtnText;
  FGuide1X := -1;
  FGuide1Y := -1;
  FGuide2X := -1;
  FGuide2Y := -1;
  FGuideHeight := 0;
  FGuideWidth := 0;
  FHalfTicks := True;
  FMargin := 0;
  FPixelIncrement := Round(Screen.PixelsPerInch / 8);
  FOrientation := roHorizontal;
  FScrollOffset := 0;
  FThickness := 1;
  FTicksPerUnit := 8;
  FTickFactor := 0.125;
  FUnits := rmutMillimeters;
  ChangeUnits(rmutScreenPixels);
end;

destructor TRMDesignerRuler.Destroy;
begin
  inherited Destroy;
end;

procedure TRMDesignerRuler.Paint;
begin
  if Visible and Enabled then
  begin
    PaintRuler;
  end;
end;

procedure TRMDesignerRuler.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FOrientation = roHorizontal then
    SetGuides(X, 0)
  else
    SetGuides(Y, 0);

  inherited MouseMove(Shift, X, Y);
end;

procedure TRMDesignerRuler.SetUnits(aUnit: TRMUnitType);
begin
  if FUnits = aUnit then Exit;

  ChangeUnits(aUnit);
end;

procedure TRMDesignerRuler.SetOrientation(aOrientation: TRMRulerOrientationType);
begin
  if FOrientation = aOrientation then
    Exit;
  FOrientation := aOrientation;
  Invalidate;
end;

procedure TRMDesignerRuler.PaintRuler;
var
  liTickLength: Integer;
  liFullTickLength: Integer;
  liTick: Integer;
  liPosition: Integer;
  liMaxLength: Integer;
  liTextHeight: Integer;
  liTextWidth: Integer;
  liDrawPosition: Integer;
  ldPosition: Double;

  procedure DrawTick;
  begin
    if FOrientation = roHorizontal then
    begin
      Canvas.MoveTo(liDrawPosition, FMargin);
      Canvas.LineTo(liDrawPosition, FMargin + liTickLength);
    end
    else
    begin
      Canvas.MoveTo(FMargin, liDrawPosition);
      Canvas.LineTo(FMargin + liTickLength, liDrawPosition);
    end;
  end;

  procedure DrawLabel;
  var
    liSpacing: Integer;
    liChar: Integer;
    liLeft: Integer;
    liTop: Integer;
    lRect: TRect;
    lsText: string[10];
  begin
    if (liTick * FTickFactor) >= 10000 then
      lsText := IntToStr(Round((liTick * FTickFactor) / 1000)) + 'k'
    else
      lsText := IntToStr(Round(liTick * FTickFactor));

    if FOrientation = roHorizontal then
    begin
      liTop := FMargin + (FDrawRect.Bottom - FDrawRect.Top) - liTextHeight;
      Canvas.TextOut(liDrawPosition + 2, liTop, lsText);
    end
    else
    begin
      liSpacing := liDrawPosition + 2;
      for liChar := 1 to Length(lsText) do
      begin
        liLeft := FMargin + (FDrawRect.Right - FDrawRect.Left) - liTextWidth - 2;
        lRect.Left := liLeft;
        lRect.Top := liSpacing;
        lRect.Right := liLeft + liTextWidth;
        lRect.Bottom := liSpacing + liTextHeight;
        Canvas.TextRect(lRect, liLeft, liSpacing, lsText[liChar]);
        liSpacing := liSpacing + liTextHeight - 2;
      end;
    end;
  end;

begin
  liPosition := 0;
  liMaxLength := 0;

  InitGuides;
  FDrawRect.Top := 0;
  FDrawRect.Left := 0;
  FDrawRect.Bottom := Self.Height;
  FDrawRect.Right := Self.Width;

  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(FDrawRect);
  if FOrientation = roHorizontal then
  begin
    FDrawRect.Top := 0;
    FDrawRect.Left := 0;
    FDrawRect.Bottom := Self.Height;
    FDrawRect.Right := Self.Width;
    FDrawRect.Top := FMargin;
    FDrawRect.Bottom := Self.Height - FMargin;
    liMaxLength := FDrawRect.Right;
    liPosition := FDrawRect.Left;
  end
  else if FOrientation = roVertical then
  begin
    FDrawRect.Top := 0;
    FDrawRect.Left := 0;
    FDrawRect.Bottom := Self.Height;
    FDrawRect.Right := Self.Width;
    FDrawRect.Left := FMargin;
    FDrawRect.Right := Self.Width - FMargin;
    liMaxLength := FDrawRect.Bottom;
    liPosition := FDrawRect.Top;
  end;

  Canvas.Brush.Color := clWindow;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(FDrawRect);
  Canvas.Font.Name := 'Small Fonts';
  Canvas.Font.Style := [];
  Canvas.Font.Size := 6;
  Canvas.Font.Color := Self.Font.Color;
  liTextHeight := Canvas.TextHeight('0');
  liTextWidth := Canvas.TextWidth('0');

  if FOrientation = roHorizontal then
    liFullTickLength := FDrawRect.Bottom - FDrawRect.Top
  else
    liFullTickLength := FDrawRect.Right - FDrawRect.Left;

  Canvas.Pen.Color := Font.Color;
  Canvas.Pen.Width := 1;
  liTick := 0;
  ldPosition := 0;
  while liPosition < liMaxLength + FScrollOffset do
  begin
    if ((liTick mod FTicksPerUnit) = 0) or (liTick = 0) then
      liTickLength := liFullTickLength
    else if ((liTick mod (FTicksPerUnit div 2)) = 0) and FHalfTicks then
      liTickLength := liFullTickLength div 2
    else
      liTickLength := liFullTickLength div 4;

    liDrawPosition := liPosition - FScrollOffset;
    if liTickLength = liFullTickLength then
      DrawLabel;

    if (liDrawPosition >= 0) and (liTick > 0) then
      DrawTick;

    ldPosition := ldPosition + FPixelIncrement * FScale;
    liPosition := Round(ldPosition);
    Inc(liTick);
  end;
end;

procedure TRMDesignerRuler.SetGuides(aPosition1, aPosition2: Integer);
begin
  if not (Visible and Enabled) then
    Exit;

  DrawGuide(FGuide1X, FGuide1Y);
  UpdateGuidePosition(aPosition1, FGuide1X, FGuide1Y);
  DrawGuide(FGuide1X, FGuide1Y);
end;

procedure TRMDesignerRuler.InitGuides;
begin
  if FOrientation = roHorizontal then
  begin
    FMargin := (Height - Round(0.1354 * Screen.PixelsPerInch)) div 2;
    FGuideWidth := 1;
    FGuideHeight := Round(0.1354 * Screen.PixelsPerInch);
  end
  else
  begin
    FMargin := (Width - Round(0.1354 * Screen.PixelsPerInch)) div 2;
    FGuideWidth := Round(0.1458 * Screen.PixelsPerInch);
    FGuideHeight := 1;
  end;

  FGuide1X := -1;
  FGuide1Y := -1;
  FGuide2X := -1;
  FGuide2Y := -1;
end;

function TRMDesignerRuler.UpdateGuidePosition(aNewPosition: Integer; var aGuideX, aGuideY: Integer): Boolean;
var
  liNewPosition: Integer;
begin
  Result := False;

  if ((FOrientation = roHorizontal) and (aNewPosition = aGuideX)) or
    ((FOrientation = roVertical) and (aNewPosition = aGuideY)) then
    Exit;

  if (FOrientation = roHorizontal) and (aNewPosition < FDrawRect.Left) then
    liNewPosition := FDrawRect.Left
  else if (FOrientation = roVertical) and (aNewPosition > FDrawRect.Bottom) then
    liNewPosition := FDrawRect.Bottom
  else
    liNewPosition := aNewPosition;

  if FOrientation = roHorizontal then
    aGuideX := liNewPosition
  else
    aGuideY := liNewPosition;

  Result := True;
end;

procedure TRMDesignerRuler.DrawGuide(aGuideX, aGuideY: Integer);
begin
  if FOrientation = roHorizontal then
  begin
    if aGuideX = -1 then Exit;
    Canvas.Pen.Mode := pmNot;
    Canvas.MoveTo(aGuideX, FMargin);
    Canvas.LineTo(aGuideX, FGuideHeight + FMargin);
  end
  else
  begin
    if aGuideY = -1 then Exit;
    Canvas.Pen.Mode := pmNot;
    Canvas.MoveTo(FMargin, aGuideY);
    Canvas.LineTo(FGuideWidth + FMargin, aGuideY);
  end;
end;

procedure TRMDesignerRuler.ChangeUnits(aUnit: TRMUnitType);
var
  liUnitLabel: Integer;
  ldScreenPixelsPerUnit: Double;
begin
  if FUnits <> aUnit then
  begin
    FUnits := aUnit;
    case FUnits of
      rmutScreenPixels:
        begin
          liUnitLabel := Screen.PixelsPerInch;
          ldScreenPixelsPerUnit := Screen.PixelsPerInch;
          FTicksPerUnit := Round(Screen.PixelsPerInch / 10);
          FPixelIncrement := ldScreenPixelsPerUnit / FTicksPerUnit;
          FTickFactor := liUnitLabel / FTicksPerUnit;
          FHalfTicks := True;
        end;
      rmutInches:
        begin
          liUnitLabel := 1;
          ldScreenPixelsPerUnit := Screen.PixelsPerInch;
          FTicksPerUnit := 8;
          FPixelIncrement := ldScreenPixelsPerUnit / FTicksPerUnit;
          FTickFactor := liUnitLabel / FTicksPerUnit;
          FHalfTicks := True;
        end;
      rmutMillimeters:
        begin
          liUnitLabel := 10;
          ldScreenPixelsPerUnit := PixelsPerCentimeter;
          FTicksPerUnit := 5;
          FPixelIncrement := ldScreenPixelsPerUnit / FTicksPerUnit;
          FTickFactor := liUnitLabel / FTicksPerUnit;
          FHalfTicks := False;
        end;
      rmutMMThousandths:
        begin
          liUnitLabel := 10000;
          ldScreenPixelsPerUnit := PixelsPerCentimeter;
          FTicksPerUnit := 5;
          FPixelIncrement := ldScreenPixelsPerUnit / FTicksPerUnit;
          FTickFactor := liUnitLabel / FTicksPerUnit;
          FHalfTicks := False;
        end;
    end;

    Invalidate;
  end;
end;

procedure TRMDesignerRuler.Scroll(Value: Integer);
var
  liOldOffset: Integer;
begin
  liOldOffset := FScrollOffset;
  FScrollOffset := FScrollOffset + Value;
  if FScrollOffset < 0 then
    FScrollOffset := 0;
  if FScrollOffset <> liOldOffset then
    Invalidate;
end;

procedure TRMDesignerRuler.SetScrollOffset(Value: Integer);
begin
  if FScrollOffset <> Value then
  begin
    if Value < 0 then
      FScrollOffset := 0
    else
      FScrollOffset := Value;
    Invalidate;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPopupWindow }

constructor TRMPopupWindow.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited;

  BorderIcons := [];
  BorderStyle := bsNone;
  Visible := False;
end;

procedure TRMPopupWindow.DestroyWnd;
begin
  Close(Self);
  inherited;
end;

procedure TRMPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := WS_POPUP + WS_DLGFRAME;
end;

procedure TRMPopupWindow.WMKILLFOCUS(var message: TWMKILLFOCUS);
begin
  inherited;
  DoClosePopupWindow;
end;

procedure TRMPopupWindow.AdjustClientRect(var Rect: TRect);
begin
  inherited;
  InflateRect(Rect, -FWidth, -FWidth);
end;

procedure TRMPopupWindow.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  AdjustClientRect(Rect);
  inherited;
end;

procedure TRMPopupWindow.DoClosePopupWindow;
begin
  Visible := False;
  try
    if Visible then
    begin
      //    if FForm <> nil then FForm.EnableAutoRange;
      //    if Application.Active and (FSave > 0) then Windows.SetFocus(FSave);

      SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_HIDEWINDOW or SWP_NOACTIVATE or SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE);
      Parent := nil;
    end;
  finally
    Visible := False;
    FCaller := nil;
  end;
end;

procedure TRMPopupWindow.PopupWindow(ACaller: TControl);
var
  CallerBounds: TRect;
  X, Y, W, H: Integer;
begin
  inherited;
  FCaller := ACaller;
  if Caller is TWinControl then
    GetWindowRect(TWinControl(Caller).Handle, CallerBounds)
  else
  begin
    with Caller.Parent do
    begin
      CallerBounds := Caller.BoundsRect;
      CallerBounds.TopLeft := ClientToScreen(CallerBounds.TopLeft);
      CallerBounds.BottomRight := ClientToScreen(CallerBounds.BottomRight);
    end;
  end;

  W := Self.Width;
  H := Self.Height;
  Windows.SetFocus(Self.Handle);
  Y := CallerBounds.Bottom;
  X := CallerBounds.Left;
  if X + W > Screen.Width then X := CallerBounds.Right - W;
  if Y + H > Screen.Height then Y := CallerBounds.Top - H;
  if X < 0 then X := 0;
  if Y < 0 then Y := 0;

  Self.Left := W;
  Self.Top := H;
  SetWindowPos(Handle, HWND_TOP, X, Y, W, H, SWP_NOACTIVATE or SWP_SHOWWINDOW);
  Visible := True;
end;

procedure TRMPopupWindow.Close(Sender: TObject);
begin
  DoClosePopupWindow;
end;

procedure TRMPopupWindow.Popup(ACaller: TControl);
begin
  FForm := nil;
  FSave := 0;
  if not Active then
  begin
    FCaller := ACaller;
    FForm := GetParentForm(Self);
    FSave := GetFocus;
    if FForm <> nil then FForm.DisableAutoRange;
    if Assigned(FOnPopup) then FOnPopup(Self);

    PopupWindow(ACaller);
  end;
end;

{$IFDEF USE_TB2K}

type
  TGlyphList = class(TImageList)
  private
    FUsed: TBits;
    FCount: Integer;
    function AllocateIndex: Integer;
  public
    constructor CreateSize(AWidth, AHeight: Integer);
    destructor Destroy; override;
    function AddMasked(Image: TBitmap; MaskColor: TColor): Integer;
{$IFDEF VisualCLX} override; {$ENDIF}
    procedure Delete(Index: Integer);
    property Count: Integer read FCount;
  end;

  TGlyphCache = class(TObject)
  private
    FGlyphLists: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetList(AWidth, AHeight: Integer): TGlyphList;
    procedure ReturnList(var List: TGlyphList);
    function Empty: Boolean;
  end;

  TButtonGlyph = class(TObject)
  private
    FOriginal: TBitmap;
    FGlyphList: TGlyphList;
    FIndexs: array[TButtonState] of Integer;
    FTransparentColor: TColor;
    FNumGlyphs: TNumGlyphs;
    FOnChange: TNotifyEvent;
    procedure GlyphChanged(Sender: TObject);
    procedure SetGlyph(Value: TBitmap);
    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure Invalidate;
    function CreateButtonGlyph(State: TButtonState): Integer;
    procedure DrawButtonGlyph(Canvas: TCanvas; const GlyphPos: TPoint;
      State: TButtonState; Transparent: Boolean);
    procedure DrawButtonText(Canvas: TCanvas; const Caption: string;
      TextBounds: TRect; State: TButtonState);
    procedure CalcButtonLayout(Canvas: TCanvas; const Client: TRect;
      const Offset: TPoint; const Caption: string; Layout: TButtonLayout;
      Margin, Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect);
  public
    constructor Create;
    destructor Destroy; override;
    { return the text rectangle }
    function Draw(Canvas: TCanvas; const Client: TRect; const Offset: TPoint;
      const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer;
      State: TButtonState; Transparent: Boolean): TRect;
    property Glyph: TBitmap read FOriginal write SetGlyph;
    property NumGlyphs: TNumGlyphs read FNumGlyphs write SetNumGlyphs;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure DrawLine(Canvas: TCanvas; X, Y, X2, Y2: Integer);
begin
  Canvas.MoveTo(X, Y);
  Canvas.LineTo(X2, Y2);
end;

// (rom) best move to JCL

procedure GrayBitmap(Bmp: TBitmap);
var
  I, J, W, H: Integer;
  ColT: TColor;
  Col: TColor;
begin
  if Bmp.Empty then
    Exit;

  W := Bmp.Width;
  H := Bmp.Height;
  ColT := Bmp.Canvas.Pixels[0, 0];

  // (rom) speed up by using Scanline
  for I := 0 to W do
    for J := 0 to H do
    begin
      Col := Bmp.Canvas.Pixels[I, J];
      if (Col <> clWhite) and (Col <> ColT) then
        Col := clBlack
      else
        Col := ColT;
      Bmp.Canvas.Pixels[I, J] := Col;
    end;
end;

//=== { TGlyphList } =========================================================

constructor TGlyphList.CreateSize(AWidth, AHeight: Integer);
begin
  inherited CreateSize(AWidth, AHeight);
  FUsed := TBits.Create;
end;

destructor TGlyphList.Destroy;
begin
  FUsed.Free;
  inherited Destroy;
end;

function TGlyphList.AllocateIndex: Integer;
begin
  Result := FUsed.OpenBit;
  if Result >= FUsed.Size then
  begin
    Result := inherited Add(nil, nil);
    FUsed.Size := Result + 1;
  end;
  FUsed[Result] := True;
end;

function TGlyphList.AddMasked(Image: TBitmap; MaskColor: TColor): Integer;
begin
  Result := AllocateIndex;
  ReplaceMasked(Result, Image, MaskColor);
  Inc(FCount);
end;

procedure TGlyphList.Delete(Index: Integer);
begin
  if FUsed[Index] then
  begin
    Dec(FCount);
    FUsed[Index] := False;
  end;
end;

//=== { TGlyphCache } ========================================================

constructor TGlyphCache.Create;
begin
  inherited Create;
  FGlyphLists := TList.Create;
end;

destructor TGlyphCache.Destroy;
begin
  FGlyphLists.Free;
  inherited Destroy;
end;

function TGlyphCache.GetList(AWidth, AHeight: Integer): TGlyphList;
var
  I: Integer;
begin
  for I := FGlyphLists.Count - 1 downto 0 do
  begin
    Result := FGlyphLists[I];
    if (AWidth = Result.Width) and (AHeight = Result.Height) then
      Exit;
  end;
  Result := TGlyphList.CreateSize(AWidth, AHeight);
  FGlyphLists.Add(Result);
end;

procedure TGlyphCache.ReturnList(var List: TGlyphList);
begin
  if (List <> nil) and (List.Count = 0) then
  begin
    FGlyphLists.Remove(List);
    FreeAndNil(List);
  end;
end;

function TGlyphCache.Empty: Boolean;
begin
  Result := FGlyphLists.Count = 0;
end;

var
  GlyphCache: TGlyphCache = nil;
  Pattern: TBitmap = nil;
  ButtonCount: Integer = 0;

//=== { TButtonGlyph } =======================================================

procedure CreateBrushPattern;
var
  X, Y: Integer;
begin
  Pattern.Free; // (rom) just to be sure
  Pattern := TBitmap.Create;
  Pattern.Width := 8;
  Pattern.Height := 8;
  with Pattern.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, Pattern.Width, Pattern.Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then { toggles between even/odd pixles }
          Pixels[X, Y] := clBtnHighlight; { on even/odd rows }
  end;
end;

constructor TButtonGlyph.Create;
var
  I: TButtonState;
begin
  inherited Create;
  FOriginal := TBitmap.Create;
  FOriginal.OnChange := GlyphChanged;
  FTransparentColor := clOlive;
  FNumGlyphs := 1;
  for I := Low(I) to High(I) do
    FIndexs[I] := -1;
  if GlyphCache = nil then
    GlyphCache := TGlyphCache.Create;
end;

destructor TButtonGlyph.Destroy;
begin
  FOriginal.Free;
  Invalidate;
  if Assigned(GlyphCache) and GlyphCache.Empty then
    FreeAndNil(GlyphCache);
  inherited Destroy;
end;

procedure TButtonGlyph.Invalidate;
var
  I: TButtonState;
begin
  for I := Low(TButtonState) to High(TButtonState) do
  begin
    if FIndexs[I] <> -1 then
      FGlyphList.Delete(FIndexs[I]);
    FIndexs[I] := -1;
  end;
  GlyphCache.ReturnList(FGlyphList);
end;

procedure TButtonGlyph.GlyphChanged(Sender: TObject);
begin
  if Sender = FOriginal then
  begin
    FTransparentColor := FOriginal.TransparentColor;
    Invalidate;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TButtonGlyph.SetGlyph(Value: TBitmap);
var
  Glyphs: Integer;
begin
  Invalidate;
  FOriginal.Assign(Value);
  if (Value <> nil) and (Value.Height > 0) then
  begin
    FTransparentColor := Value.TransparentColor;
    if Value.Width mod Value.Height = 0 then
    begin
      Glyphs := Value.Width div Value.Height;
      if Glyphs > 4 then
        Glyphs := 1;
      SetNumGlyphs(Glyphs);
    end;
  end;
end;

procedure TButtonGlyph.SetNumGlyphs(Value: TNumGlyphs);
begin
  if (Value <> FNumGlyphs) and (Value > 0) then
  begin
    Invalidate;
    FNumGlyphs := Value;
    GlyphChanged(Glyph);
  end;
end;

function TButtonGlyph.CreateButtonGlyph(State: TButtonState): Integer;
const
  ROP_DSPDxax = $00E20746;
var
  TmpImage, DDB, MonoBmp: TBitmap;
  IWidth, IHeight: Integer;
  IRect, ORect: TRect;
  I: TButtonState;
  DestDC: HDC;
begin
  if (State = bsDown) and (NumGlyphs < 3) then
    State := bsUp;
  Result := FIndexs[State];
  if Result <> -1 then
    Exit;
  if (FOriginal.Width = 0) or (FOriginal.Height = 0) then
    Exit;
  IWidth := FOriginal.Width div FNumGlyphs;
  IHeight := FOriginal.Height;
  if FGlyphList = nil then
  begin
    if GlyphCache = nil then
      GlyphCache := TGlyphCache.Create;
    FGlyphList := GlyphCache.GetList(IWidth, IHeight);
  end;
  TmpImage := TBitmap.Create;
  try
    TmpImage.Width := IWidth;
    TmpImage.Height := IHeight;
    IRect := Rect(0, 0, IWidth, IHeight);
    TmpImage.Canvas.Brush.Color := clBtnFace;
{$IFDEF VCL}
    TmpImage.Palette := CopyPalette(FOriginal.Palette);
{$ENDIF VCL}
    I := State;
    if Ord(I) >= NumGlyphs then
      I := bsUp;
    ORect := Rect(Ord(I) * IWidth, 0, (Ord(I) + 1) * IWidth, IHeight);
    case State of
      bsUp, bsDown, bsExclusive:
        begin
          TmpImage.Canvas.CopyRect(IRect, FOriginal.Canvas, ORect);
          if FOriginal.TransparentMode = tmFixed then
            FIndexs[State] := FGlyphList.AddMasked(TmpImage, FTransparentColor)
          else
            FIndexs[State] := FGlyphList.AddMasked(TmpImage, clDefault);
        end;
      bsDisabled:
        begin
          MonoBmp := nil;
          DDB := nil;
          try
            MonoBmp := TBitmap.Create;
            DDB := TBitmap.Create;
            DDB.Assign(FOriginal);
{$IFDEF VCL}
            DDB.HandleType := bmDDB;
{$ENDIF VCL}
            if NumGlyphs > 1 then
              with TmpImage.Canvas do
              begin { Change white & gray to clBtnHighlight and clBtnShadow }
                CopyRect(IRect, DDB.Canvas, ORect);
                MonoBmp.Monochrome := True;
                MonoBmp.Width := IWidth;
                MonoBmp.Height := IHeight;

                { Convert white to clBtnHighlight }
                DDB.Canvas.Brush.Color := clWhite;
                MonoBmp.Canvas.CopyRect(IRect, DDB.Canvas, ORect);
                Brush.Color := clBtnHighlight;
                DestDC := Handle;
                SetTextColor(DestDC, clBlack);
                SetBkColor(DestDC, clWhite);
                BitBlt(DestDC, 0, 0, IWidth, IHeight,
                  MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);

                { Convert gray to clBtnShadow }
                DDB.Canvas.Brush.Color := clGray;
                MonoBmp.Canvas.CopyRect(IRect, DDB.Canvas, ORect);
                Brush.Color := clBtnShadow;
                DestDC := Handle;
                SetTextColor(DestDC, clBlack);
                SetBkColor(DestDC, clWhite);
                BitBlt(DestDC, 0, 0, IWidth, IHeight,
                  MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);

                { Convert transparent color to clBtnFace }
                DDB.Canvas.Brush.Color := ColorToRGB(FTransparentColor);
                MonoBmp.Canvas.CopyRect(IRect, DDB.Canvas, ORect);
                Brush.Color := clBtnFace;
                DestDC := Handle;
                SetTextColor(DestDC, clBlack);
                SetBkColor(DestDC, clWhite);
                BitBlt(DestDC, 0, 0, IWidth, IHeight,
                  MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
              end
            else
            begin
              { Create a disabled version }
              with MonoBmp do
              begin
                Assign(FOriginal);
                GrayBitmap(MonoBmp);
{$IFDEF VCL}
                HandleType := bmDDB;
{$ENDIF VCL}
                Canvas.Brush.Color := clBlack;
                Width := IWidth;
                if Monochrome then
                begin
                  Canvas.Font.Color := clWhite;
                  Monochrome := False;
                  Canvas.Brush.Color := clWhite;
                end;
                Monochrome := True;
              end;
              with TmpImage.Canvas do
              begin
                Brush.Color := clBtnFace;
                FillRect(IRect);
                Brush.Color := clBtnHighlight;
                SetTextColor(Handle, clBlack);
                SetBkColor(Handle, clWhite);
                BitBlt(Handle, 1, 1, IWidth, IHeight,
                  MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
                Brush.Color := clBtnShadow;
                SetTextColor(Handle, clBlack);
                SetBkColor(Handle, clWhite);
                BitBlt(Handle, 0, 0, IWidth, IHeight,
                  MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
              end;
            end;
          finally
            DDB.Free;
            MonoBmp.Free;
          end;

          FIndexs[State] := FGlyphList.AddMasked(TmpImage, clDefault);
        end;
    end;
  finally
    TmpImage.Free;
  end;
  Result := FIndexs[State];
  FOriginal.Dormant;
end;

procedure TButtonGlyph.DrawButtonGlyph(Canvas: TCanvas; const GlyphPos: TPoint;
  State: TButtonState; Transparent: Boolean);
var
  Index: Integer;
begin
  if (FOriginal = nil) or (FOriginal.Width = 0) or (FOriginal.Height = 0) then
    Exit;
  Index := CreateButtonGlyph(State);
  with GlyphPos do
  begin
    if Transparent or (State = bsExclusive) then
      ImageList_DrawEx(FGlyphList.Handle, Index, Canvas.Handle, X, Y, 0, 0,
        clNone, clNone, ILD_Transparent)
    else
      ImageList_DrawEx(FGlyphList.Handle, Index, Canvas.Handle, X, Y, 0, 0,
        ColorToRGB(clBtnFace), clNone, ILD_Normal);
  end;
end;

procedure TButtonGlyph.DrawButtonText(Canvas: TCanvas; const Caption: string;
  TextBounds: TRect; State: TButtonState);
begin
//
end;

procedure TButtonGlyph.CalcButtonLayout(Canvas: TCanvas; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout; Margin,
  Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect);
var
  TextPos: TPoint;
  ClientSize, GlyphSize, TextSize: TPoint;
  TotalSize: TPoint;
  S: string;
begin
  { calculate the item sizes }
  ClientSize := Point(Client.Right - Client.Left, Client.Bottom -
    Client.Top);

  if FOriginal <> nil then
    GlyphSize := Point(FOriginal.Width div FNumGlyphs, FOriginal.Height)
  else
    GlyphSize := Point(0, 0);

  if Length(Caption) > 0 then
  begin
    TextBounds := Rect(0, 0, Client.Right - Client.Left, 0);
    S := Caption;
    //DrawText(Canvas, S, -1, TextBounds, DT_CALCRECT);
    TextSize := Point(TextBounds.Right - TextBounds.Left, TextBounds.Bottom -
      TextBounds.Top);
  end
  else
  begin
    TextBounds := Rect(0, 0, 0, 0);
    TextSize := Point(0, 0);
  end;

  { If the layout has the glyph on the right or the left, then both the
    text and the glyph are centered vertically.  If the glyph is on the top
    or the bottom, then both the text and the glyph are centered horizontally.}
  if Layout in [blGlyphLeft, blGlyphRight] then
  begin
    GlyphPos.Y := (ClientSize.Y - GlyphSize.Y + 1) div 2;
    TextPos.Y := (ClientSize.Y - TextSize.Y + 1) div 2;
  end
  else
  begin
    GlyphPos.X := (ClientSize.X - GlyphSize.X + 1) div 2;
    TextPos.X := (ClientSize.X - TextSize.X + 1) div 2;
  end;

  { if there is no text or no bitmap, then Spacing is irrelevant }
  if (TextSize.X = 0) or (GlyphSize.X = 0) then
    Spacing := 0;

  { adjust Margin and Spacing }
  if Margin = -1 then
  begin
    if Spacing = -1 then
    begin
      TotalSize := Point(GlyphSize.X + TextSize.X, GlyphSize.Y + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X) div 3
      else
        Margin := (ClientSize.Y - TotalSize.Y) div 3;
      Spacing := Margin;
    end
    else
    begin
      TotalSize := Point(GlyphSize.X + Spacing + TextSize.X, GlyphSize.Y +
        Spacing + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X + 1) div 2
      else
        Margin := (ClientSize.Y - TotalSize.Y + 1) div 2;
    end;
  end
  else
  begin
    if Spacing = -1 then
    begin
      TotalSize := Point(ClientSize.X - (Margin + GlyphSize.X), ClientSize.Y -
        (Margin + GlyphSize.Y));
      if Layout in [blGlyphLeft, blGlyphRight] then
        Spacing := (TotalSize.X - TextSize.X) div 2
      else
        Spacing := (TotalSize.Y - TextSize.Y) div 2;
    end;
  end;

  case Layout of
    blGlyphLeft:
      begin
        GlyphPos.X := Margin;
        TextPos.X := GlyphPos.X + GlyphSize.X + Spacing;
      end;
    blGlyphRight:
      begin
        GlyphPos.X := ClientSize.X - Margin - GlyphSize.X;
        TextPos.X := GlyphPos.X - Spacing - TextSize.X;
      end;
    blGlyphTop:
      begin
        GlyphPos.Y := Margin;
        TextPos.Y := GlyphPos.Y + GlyphSize.Y + Spacing;
      end;
    blGlyphBottom:
      begin
        GlyphPos.Y := ClientSize.Y - Margin - GlyphSize.Y;
        TextPos.Y := GlyphPos.Y - Spacing - TextSize.Y;
      end;
  end;

  { fixup the result variables }
  with GlyphPos do
  begin
    Inc(X, Client.Left + Offset.X);
    Inc(Y, Client.Top + Offset.Y);
  end;
  OffsetRect(TextBounds, TextPos.X + Client.Left + Offset.X,
    TextPos.Y + Client.Top + Offset.X);
end;

function TButtonGlyph.Draw(Canvas: TCanvas; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout;
  Margin, Spacing: Integer; State: TButtonState; Transparent: Boolean): TRect;
var
  GlyphPos: TPoint;
begin
  CalcButtonLayout(Canvas, Client, Offset, Caption, Layout, Margin, Spacing,
    GlyphPos, Result);
  DrawButtonGlyph(Canvas, GlyphPos, State, Transparent);
  DrawButtonText(Canvas, Caption, Result, State);
end;

function _IsMouseOver(Control: TControl): Boolean;
var
  Pt: TPoint;
begin
  Pt := Control.ScreenToClient(Mouse.CursorPos);
  Result := PtInRect(Control.ClientRect, Pt);
end;

procedure _DrawLine(Canvas: TCanvas; X, Y, X2, Y2: Integer);
begin
  Canvas.MoveTo(X, Y);
  Canvas.LineTo(X2, Y2);
end;

//=== { TRMArrowButton } =====================================================

constructor TRMArrowButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FArrowWidth := 9;
  SetBounds(0, 0, 23 + FArrowWidth + 2, 22);
  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks];
  FAllowAllUp := False;
  FGroupIndex := 0;
  ParentFont := True;
  FDown := False;
  FFlat := False;
  FPressBoth := True;

  FGlyph := TButtonGlyph.Create;
  TButtonGlyph(FGlyph).OnChange := GlyphChanged;
end;

destructor TRMArrowButton.Destroy;
begin
  TButtonGlyph(FGlyph).Free;
  inherited Destroy;
end;

procedure TRMArrowButton.Paint;
const
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);
var
  PaintRect: TRect;
  DrawFlags: Integer;
  Offset: TPoint;
  DivX, DivY: Integer;
  Push: Boolean;
begin
  if not Enabled then
    FState := bsDisabled
  else if FState = bsDisabled then
  begin
    if Down and (GroupIndex <> 0) then
      FState := bsExclusive
    else
      FState := bsUp;
  end;

  PaintRect := Rect(0, 0, Width - ArrowWidth, Height);
  if FArrowClick and not Down then
    FState := bsUp;

  if not Flat then
  begin
    DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
    if (FState in [bsDown, bsExclusive]) then
      DrawFlags := DrawFlags or DFCS_PUSHED;
    if _IsMouseOver(Self) then
      DrawFlags := DrawFlags or DFCS_HOT;
    //DrawThemedFrameControl(Self, Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
    DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
  end
  else
  begin
    if (FState in [bsDown, bsExclusive]) or
      (FMouseInControl and (FState <> bsDisabled)) or
      (csDesigning in ComponentState) then
      DrawEdge(Canvas.Handle, PaintRect, DownStyles[FState in [bsDown, bsExclusive]],
        FillStyles[Flat] or BF_RECT);
    InflateRect(PaintRect, -1, -1);
  end;

  if FState in [bsDown, bsExclusive] then
  begin
    if (FState = bsExclusive) and (not Flat or not FMouseInControl) then
    begin
      Canvas.FillRect(PaintRect);
    end;
    Offset.X := 1;
    Offset.Y := 1;
  end
  else
  begin
    Offset.X := 0;
    Offset.Y := 0;
  end;

  { draw image: }
  TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, blGlyphLeft, -1,
    4, FState, Flat);

  { calculate were to put arrow part }
  PaintRect := Rect(Width - ArrowWidth, 0, Width, Height);
  Push := FArrowClick or (PressBoth and (FState in [bsDown, bsExclusive]));
  if Push then
  begin
    Offset.X := 1;
    Offset.Y := 1;
  end
  else
  begin
    Offset.X := 0;
    Offset.Y := 0;
  end;

  if not Flat then
  begin
    DrawFlags := DFCS_BUTTONPUSH; // or DFCS_ADJUSTRECT;
    if Push then
      DrawFlags := DrawFlags or DFCS_PUSHED;
    if _IsMouseOver(Self) then
      DrawFlags := DrawFlags or DFCS_HOT;
    //DrawThemedFrameControl(Self, Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
    DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
  end
  else if FMouseInControl and Enabled or (csDesigning in ComponentState) then
  begin
    Push := FArrowClick;
    DrawEdge(Canvas.Handle, PaintRect, DownStyles[Push], FillStyles[Flat] or BF_RECT);
  end;

  { find middle pixel }
  with PaintRect do
  begin
    DivX := Right - Left;
    DivX := DivX div 2;
    DivY := Bottom - Top;
    DivY := DivY div 2;
    Bottom := Bottom - (DivY + DivX div 2) + 1;
    Top := Top + (DivY + DivX div 2) + 1;
    Left := Left + (DivX div 2);
    Right := (Right - DivX div 2);
  end;

  if not Flat then
    Dec(Offset.X);

  OffsetRect(PaintRect, Offset.X, Offset.Y);
  if Enabled then
    Canvas.Pen.Color := clBlack
  else
    Canvas.Pen.Color := clBtnShadow;

  { Draw arrow }
  while PaintRect.Left < PaintRect.Right + 1 do
  begin
    _DrawLine(Canvas, PaintRect.Left, PaintRect.Bottom, PaintRect.Right, PaintRect.Bottom);
    InflateRect(PaintRect, -1, 1);
  end;
end;

procedure TRMArrowButton.UpdateTracking;
var
  P: TPoint;
begin
  if Flat then
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not (FindDragTarget(P, True) = Self);
      if FMouseInControl then
        Perform(CM_MOUSELEAVE, 0, 0)
      else
        Perform(CM_MOUSEENTER, 0, 0);
    end;
end;

procedure TRMArrowButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Pnt: TPoint;
  Msg: TMsg;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Enabled then Exit;

  FArrowClick := False;
  if Assigned(FDropDownMenu) then
    FArrowClick := (X >= Width - ArrowWidth) and (X <= Width) and (Y >= 0) and (Y <= Height);

  if Button = mbLeft then
  begin
    if not Down then
      FState := bsDown
    else
      FState := bsExclusive;

    Repaint; // Invalidate;
  end;

  if Assigned(FDropDownMenu) and FArrowClick then
  begin
    Pnt := ClientToScreen(Point(0, Height));
    DropDown.Popup(Pnt.X, Pnt.Y);
    while PeekMessage(Msg, HWND_DESKTOP, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE) do
    begin
      {nothing};
    end;

    if GetCapture <> 0 then
      SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  end;

  if FArrowClick then
  begin
    if Assigned(FOnDrop) then
      FOnDrop(Self);
  end;

  FArrowClick := False;
  Repaint;
end;

procedure TRMArrowButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);

  if not Enabled then
  begin
    FState := bsUp;
    Repaint;
  end;

  DoClick := True;
  if Assigned(FDropDownMenu) then
    DoClick := (X >= 0) and (X <= Width - ArrowWidth) and (Y >= 0) and (Y <= Height);

  if GroupIndex = 0 then
  begin
    //FState := bsUp;
    FMouseInControl := False;
    if DoClick and not (FState in [bsExclusive, bsDown]) then
      Invalidate;
  end
  else
  begin
    if DoClick then
    begin
      SetDown(not Down);
      if Down then
        Repaint;
    end
    else
    begin
      if Down then
        FState := bsExclusive;
      Repaint;
    end;
  end;

  if DoClick then
    Click;

  UpdateTracking;
  Repaint;
end;

function TRMArrowButton.GetGlyph: TBitmap;
begin
  Result := TButtonGlyph(FGlyph).Glyph;
end;

procedure TRMArrowButton.SetGlyph(Value: TBitmap);
begin
  TButtonGlyph(FGlyph).Glyph := Value;
  Invalidate;
end;

function TRMArrowButton.GetNumGlyphs: TNumGlyphs;
begin
  Result := TButtonGlyph(FGlyph).NumGlyphs;
end;

procedure TRMArrowButton.SetNumGlyphs(Value: TNumGlyphs);
begin
  if Value < 0 then
    Value := 1
  else
    if Value > 4 then
      Value := 4;
  if Value <> TButtonGlyph(FGlyph).NumGlyphs then
  begin
    TButtonGlyph(FGlyph).NumGlyphs := Value;
    Invalidate;
  end;
end;

procedure TRMArrowButton.SetDown(Value: Boolean);
begin
  if GroupIndex = 0 then
    Value := False;
  if Value <> FDown then
  begin
    if FDown and (not AllowAllUp) then
      Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then
        Invalidate;
      FState := bsExclusive
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
  end;
end;

procedure TRMArrowButton.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure TRMArrowButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
  end;
end;

procedure TRMArrowButton.SetArrowWidth(Value: Integer);
begin
  if FArrowWidth <> Value then
  begin
    FArrowWidth := Value;
    Repaint;
  end;
end;

procedure TRMArrowButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
  end;
end;

procedure TRMArrowButton.WMLButtonDblClk(var Msg: TWMLButtonDown);
begin
  inherited;
  if Down then
    DblClick;
end;

function _DispatchIsDesignMsg(Control: TControl; var Msg: TMessage): Boolean;
var
  Form: TCustomForm;
begin
  Result := False;
  case Msg.Msg of
    WM_SETFOCUS, WM_KILLFOCUS, WM_NCHITTEST,
      WM_MOUSEFIRST..WM_MOUSELAST,
      WM_KEYFIRST..WM_KEYLAST,
      WM_CANCELMODE:
      Exit; // These messages are handled in TWinControl.WndProc before IsDesignMsg() is called
  end;
  if (Control <> nil) and (csDesigning in Control.ComponentState) then
  begin
    Form := GetParentForm(Control);
    if (Form <> nil) and (Form.Designer <> nil) and
      Form.Designer.IsDesignMsg(Control, Msg) then
      Result := True;
  end;
end;

procedure TRMArrowButton.WndProc(var Msg: TMessage);
begin
  if not _DispatchIsDesignMsg(Self, Msg) then
  begin
    case Msg.Msg of
      CM_MOUSEENTER:
        MouseEnter(TControl(Msg.LParam));
      CM_MOUSELEAVE:
        begin
          MouseLeave(TControl(Msg.LParam));
          if GroupIndex = 0 then
          begin
            FState := bsUp;
          end;
        end;
    else
      inherited WndProc(Msg);
    end;
  end;
end;

procedure TRMArrowButton.MouseEnter(AControl: TControl);
begin
  if Flat and not FMouseInControl and Enabled then
  begin
    FMouseInControl := True;
    Repaint;
  end;
  //BaseWndProc(CM_MOUSEENTER, 0, AControl);
end;

procedure TRMArrowButton.MouseLeave(AControl: TControl);
begin
//BaseWndProc(CM_MOUSELEAVE, 0, AControl);
  if Flat and FMouseInControl and Enabled then
  begin
    FMouseInControl := False;
    Invalidate;
  end;
end;

procedure TRMArrowButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;


{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPopupWindowButton }

constructor TRMPopupWindowButton.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  Flat := True;
  FActive := False;
  FDropDownPanel := nil;
end;

{$IFDEF USE_TB2K}

procedure TRMPopupWindowButton.SetActive(aValue: Boolean);
begin
  if GetDropDownPanel = nil then Exit;

  FActive := aValue;
  if FActive then
  begin
    ShowDropDownPanel;
  end
  else
  begin
    if FDropDownPanel <> nil then
      FDropDownPanel.Visible := False;
  end;
end;

{$ELSE}

procedure TRMPopupWindowButton.SetActive(aValue: Boolean);
begin
  if GetDropDownPanel = nil then Exit;

  FActive := aValue;
  if FActive then
  begin
    if DropDownCombo then
    begin
      Down := False;
      FState := bsDown;
      ShowDropDownPanel;
      Invalidate;
    end
    else
    begin
      Down := True;
      ShowDropDownPanel;
    end;
  end
  else
  begin
    if FDropDownPanel <> nil then
      FDropDownPanel.Visible := False;

    Down := False;
    FState := bsUp;
    Invalidate;
  end;
end;

{$ENDIF}

function TRMPopupWindowButton.GetDropDownPanel: TRMPopupWindow;
begin
  Result := FDropDownPanel;
end;

procedure TRMPopupWindowButton.SetDropdownPanel(Value: TRMPopupWindow);
begin
  if (FDropdownPanel = Value) then Exit;

  FDropdownPanel := Value;
  if (FDropdownPanel <> nil) then
  begin
    FDropdownPanel.OnClose := DropdownPanel_OnClose;
  end;
end;

procedure TRMPopupWindowButton.DropdownPanel_OnClose(Sender: TObject);
begin
  Active := False;
end;

procedure TRMPopupWindowButton.ShowDropDownPanel;
begin
  if csDesigning in ComponentState then Exit;

  FDropDownPanel.Popup(Self);
end;

procedure TRMPopupWindowButton.Click;
var
  lbTogglePanel: Boolean;
begin
  if Active then
    lbTogglePanel := True
  else
    lbTogglePanel := (GetDropDownPanel <> nil);

  if lbTogglePanel then
    Active := True
  else
    inherited Click;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMScrollBar }

constructor TRMScrollBar.Create(aScrollBox: TRMScrollBox; aKind: TRMScrollBarKind);
begin
  inherited Create;

  FScrollBox := aScrollBox;
  FKind := aKind;

  FSmallChange := 1;
  FLargeChange := 10;

  FSmallChange := 1;
  FLargeChange := 10;

  FRange := 2;
  FPageSize := 1;
  FPosition := 0;
  FThumbValue := 1;

  FScrollInfo.cbSize := Sizeof(TScrollInfo);
  FScrollInfo.nMin := 0;
  FScrollInfo.nMax := FRange;
  FScrollInfo.nPage := FPageSize;
  FScrollInfo.nPos := FPosition;
  FScrollInfo.nTrackPos := FPosition;

  FWidth := GetSystemMetrics(SM_CXVSCROLL);
end;

function TRMScrollBar.GetBarFlag: Integer;
begin
  if FKind = rmsbVertical then
    Result := SB_VERT
  else
    Result := SB_HORZ;
end;

procedure TRMScrollBar.ScrollMessage(var aMessage: TWMScroll);
begin
  case aMessage.ScrollCode of
    SB_LINEUP: Position := Position - SmallChange;
    SB_LINEDOWN: Position := Position + SmallChange;
    SB_PAGEUP: Position := Position - LargeChange;
    SB_PAGEDOWN: Position := Position + LargeChange;
    SB_THUMBPOSITION, SB_THUMBTRACK:
      Position := TrackPos - TrackPos mod ThumbValue;
    SB_TOP: Position := 0;
    SB_BOTTOM: Position := Range;
    SB_ENDSCROLL:
      begin
        Exit;
      end;
  end;
end;

procedure TRMScrollBar.UpdateScrollBar;
var
  lMax: Integer;
begin
  lMax := FRange;
  if lMax < FPageSize then lMax := 0;

  FScrollInfo.fMask := SIF_ALL;
  FScrollInfo.nMin := 0;
  FScrollInfo.nMax := lMax;
  FScrollInfo.nPage := FPageSize;
  FScrollInfo.nPos := FPosition;
  FScrollInfo.nTrackPos := FPosition;
  FlatSB_SetScrollInfo(FScrollBox.Handle, GetBarFlag, FScrollInfo, True);
end;

procedure TRMScrollBar.SetPageSize(Value: Integer);
begin
  if FPageSize <> Value then
  begin
    FPageSize := Value;
    Range := Range;
  end;
end;

procedure TRMScrollBar.SetPosition(Value: Integer);
begin
  if Value > FRange - FPageSize then
    Value := FRange - FPageSize;

  if Value < 0 then
    Value := 0;

  if Value <> FPosition then
  begin
    FPosition := Value;
    FlatSB_SetScrollPos(FScrollBox.Handle, GetBarFlag, Value, True);
    if Assigned(FScrollBox.FOnChange) then
      FScrollBox.FOnChange(Self, FKind);
  end;
end;

procedure TRMScrollBar.SetRange(Value: Integer);
begin
  FRange := Value;
  UpdateScrollBar;
end;

function TRMScrollBar.GetTrackPos: Integer;
begin
  FScrollInfo.fMask := SIF_ALL;
  FlatSB_GetScrollInfo(FScrollBox.Handle, GetBarFlag, FScrollInfo);
  Result := FScrollInfo.nTrackPos;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMScrollBox }

constructor TRMScrollBox.Create(AOwner: TComponent);
begin
  inherited;

  FHorzScrollBar := TRMScrollBar.Create(Self, rmsbHorizontal);
  FVertScrollBar := TRMScrollBar.Create(Self, rmsbVertical);
end;

destructor TRMScrollBox.Destroy;
begin
  FHorzScrollBar.Free;
  FVertScrollBar.Free;

  inherited;
end;

procedure TRMScrollBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_CLIENTEDGE;
  Params.Style := Params.Style or WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL;
end;

procedure TRMScrollBox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTTAB or DLGC_WANTALLKEYS;
end;

procedure TRMScrollBox.Paint;
begin
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect(0, 0, ClientWidth, ClientHeight));
  end;
end;

procedure TRMScrollBox.WMEraseBackground(var Message: TMessage);
begin
//
end;

procedure TRMScrollBox.WMHScroll(var Message: TWMHScroll);
begin
  FHorzScrollBar.ScrollMessage(Message);
end;

procedure TRMScrollBox.WMVScroll(var Message: TWMVScroll);
begin
  //Self.SetFocus;
  FVertScrollBar.ScrollMessage(Message);
end;

end.

