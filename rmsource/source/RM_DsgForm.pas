unit RM_DsgForm;

interface

{$I RM.INC}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Printers, Menus, ComCtrls, ExtCtrls, Clipbrd,
  RM_Class, RM_Common, RM_DsgCtrls, RM_Ctrls, RM_Designer
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type

  TRMDesignerDrawMode = (dmAll, dmSelection, dmShape);
  TRMCursorType = (ctNone, ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8);
  TRMDesignerEditMode = (mdInsert, mdSelect);

  TRMWorkSpace = class;
  TRMReportPageEditor = class;

  TRMMouseMode = (mmNone, mmSelect, mmRegionDrag, mmRegionResize,
    mmSelectedResize, mmInsertObj);
  TRMShapeMode = (smFrame, smAll);
  TRMSplitInfo = record
    SplRect: TRect;
    SplX: Integer;
    View1, View2: TRMView;
  end;

  { TRMDialogForm }
  TRMDialogForm = class(TForm)
  private
    FDesignerForm: TRMDesignerForm;
    procedure WMMove(var Message: TMessage); message WM_MOVE;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetPageFormProp;

    procedure OnFormResizeEvent(Sender: TObject);
    procedure OnFormKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnFormCloseQueryEvent(Sender: TObject; var CanClose: Boolean);
  end;

  { TRMWorkSpace }
  TRMWorkSpace = class(TPanel)
  private
    FDesignerForm: TRMDesignerForm;
    FPageEditor: TRMReportPageEditor;

    FBandMoved: Boolean;
    FDisableDraw: Boolean;
    FMode: TRMDesignerEditMode; // current mode
    FMouseButtonDown: Boolean; // mouse button was pressed
    FDragFlag: Boolean;
    FCursorType: TRMCursorType; // current mouse cursor (sizing arrows)
    FDoubleClickFlag: Boolean; // was double click
    FObjectsSelecting: Boolean; // selecting objects by framing
    FLeftTop: TPoint;
    FMoved: Boolean; // mouse was FMoved (with pressed btn)
    FLastX, FLastY: Integer; // here stored last mouse coords
    FSplitInfo: TRMSplitInfo;
    FBmp_Event, FBmp_HighLight: TBitmap;

    FCurrentBand: TRMBandMasterData;
    FCurrentView: TRMReportView;
    FFieldListBox: TListBox;

    procedure OnFieldListBoxClick(Sender: TObject);
    procedure OnFieldListBoxDrawItem(aControl: TWinControl; aIndex: Integer; aRect: TRect; aState: TOwnerDrawState);

    procedure NormalizeCoord(t: TRMView);
    procedure NormalizeRect(var r: TRect);

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure OnDoubleClickEvent(Sender: TObject);

    procedure DrawFocusRect(aRect: TRect);
    procedure DrawHSplitter(aRect: TRect);
    procedure DrawSelection(t: TRMView);
    procedure DrawShape(t: TRMView);
    procedure DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DoDragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
    procedure Paint; override;
    procedure DrawRect(aView: TRMView);
  public
    PageForm: TRMDialogForm;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    procedure SetPage;
    procedure GetMultipleSelected;
    procedure DrawPage(aDrawMode: TRMDesignerDrawMode);
    procedure DrawObject(t: TRMView);
    procedure Draw(N: Integer; aClipRgn: HRGN);
    procedure RedrawPage;

    procedure OnMouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure OnMouseDownEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUpEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure CopyToClipboard;
    procedure DeleteObjects(aAddUndoAction: Boolean);
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure RoundCoord(var x, y: Integer);

    property DesignerForm: TRMDesignerForm read FDesignerForm write FDesignerForm;
    property DisableDraw: Boolean read FDisableDraw write FDisableDraw;
    property EditMode: TRMDesignerEditMode read FMode write FMode; // current mode
    property MouseButtonDown: Boolean read FMouseButtonDown write FMouseButtonDown; // mouse button was pressed
    property CurrentView: TRMReportView read FCurrentView write FCurrentView;
  end;

  { TRMToolbarComponent }
  TRMToolbarComponent = class(TPanel)
  private
    FDesignerForm: TRMDesignerForm;
    FPageEditor: TRMReportPageEditor;
    FWorkSpace: TRMWorkSpace;

    FControlIndex: Integer;
    FBandsMenu, FPopupMenuComponent: TPopupMenu;
    FBtnNoSelect, FBtnMemoView: TSpeedButton;
    FBtnUp, FBtnDown: {$IFDEF USE_TB2K}TSpeedButton{$ELSE}TRMToolbarButton{$ENDIF};
    FOldPageType: Integer;
    FBusy: Boolean;
    FObjectBand: TSpeedButton;
    FSelectedObjIndex: Integer;
    FImageList: TImageList;

    procedure OnBandMenuPopup(Sender: TObject);
    procedure OnAddBandEvent(Sender: TObject);
    procedure OnOB1ClickEvent(Sender: TObject);
    procedure OnButtonBandClickEvent(Sender: TObject);
    procedure OnOB2MouseDownEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnOB2ClickEvent(Sender: TObject);
    procedure OnOB2ClickEvent_1(Sender: TObject);
    procedure OnAddInObectMenuItemClick(Sender: TObject);

    procedure RefreshControls;
    procedure OnResizeEvent(Sender: TObject);
    procedure OnBtnUpClickEvent(Sender: TObject);
    procedure OnBtnDownClickEvent(Sender: TObject);
  public
    constructor CreateComp(aOwner: TComponent);
    destructor Destroy; override;

    procedure CreateObjects;

    property btnNoSelect: TSpeedButton read FBtnNoSelect;
    property ObjectBand: TSpeedButton read FObjectBand;
    property SelectedObjIndex: Integer read FSelectedObjIndex;
  end;

  { TRMToolbarEdit }
  TRMToolbarEdit = class(TRMToolbar)
  private
    FDesignerForm: TRMDesignerForm;
    FPageEditor: TRMReportPageEditor;

    FcmbFont: TRMFontComboBox;
    FcmbFontSize: TRMComboBox97;
    ToolbarSep971: TRMToolbarSep;

    btnFontBold: TRMToolbarButton;
    btnFontItalic: TRMToolbarButton;
    btnFontUnderline: TRMToolbarButton;
    ToolbarSep972: TRMToolbarSep;

    FBtnFontColor: TRMColorPickerButton;
    ToolbarSep973: TRMToolbarSep;
    FBtnHighlight: TRMToolbarButton;
    ToolbarSep9730: TRMToolbarSep;

    btnHLeft: TRMToolbarButton;
    btnHCenter: TRMToolbarButton;
    btnHRight: TRMToolbarButton;
    btnHSpaceEqual: TRMToolbarButton;
    ToolbarSep974: TRMToolbarSep;

    btnVTop: TRMToolbarButton;
    btnVCenter: TRMToolbarButton;
    btnVBottom: TRMToolbarButton;
    ToolbarSep975: TRMToolbarSep;

    procedure Localize;
    procedure BtnHighlightClick(Sender: TObject);
  public
    constructor CreateAndDock(aOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarAddinTools }
  TRMToolbarAddinTools = class(TRMToolbar)
  private
    FDesignerForm: TRMDesignerForm;
    FPageEditor: TRMReportPageEditor;

    BtnDBField: TRMToolbarButton;
    btnExpression: TRMToolbarButton;
    btnInsertFields: TRMToolbarButton;

    procedure Localize;
    procedure btnDBFieldClick(Sender: TObject);
    procedure btnExpressionClick(Sender: TObject);
    procedure BtnInsertFieldsClick(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarBorder }
  TRMToolbarBorder = class(TRMToolbar)
  private
    FDesignerForm: TRMDesignerForm;
    FPageEditor: TRMReportPageEditor;

    btnFrameTop: TRMToolbarButton;
    btnFrameLeft: TRMToolbarButton;
    btnFrameBottom: TRMToolbarButton;
    btnFrameRight: TRMToolbarButton;
    btnNoFrame: TRMToolbarButton;
    btnSetFrame: TRMToolbarButton;
    ToolbarSep9717: TRMToolbarSep;
    ToolbarSep9722: TRMToolbarSep;
    FBtnBackColor: TRMColorPickerButton;
    FBtnFrameColor: TRMColorPickerButton;
    ToolbarSep9719: TRMToolbarSep;
    btnSetFrameStyle: TRMFrameStyleButton {TRMToolbarButton};
    FCmbFrameWidth: TRMComboBox97;

    procedure Localize;
    procedure SetStatus;
    procedure btnSetFrameStyle_OnChange(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarAlign }
  TRMToolbarAlign = class(TRMToolbar)
  private
    FPageEditor: TRMReportPageEditor;
    FDesignerForm: TRMDesignerForm;

    btnAlignLeftRight: TRMToolbarButton;
    btnAlignTopBottom: TRMToolbarButton;
    btnAlignVWCenter: TRMToolbarButton;
    btnAlignLeft: TRMToolbarButton;
    btnAlignHWCenter: TRMToolbarButton;
    btnAlignHCenter: TRMToolbarButton;
    btnAlignVSE: TRMToolbarButton;
    btnAlignHSE: TRMToolbarButton;
    btnAlignRight: TRMToolbarButton;
    btnAlignBottom: TRMToolbarButton;
    btnAlignTop: TRMToolbarButton;
    btnAlignVCenter: TRMToolbarButton;
    ToolbarSep9720: TRMToolbarSep;
    ToolbarSep9721: TRMToolbarSep;
    ToolbarSep9710: TRMToolbarSep;

    procedure Localize;
    function GetLeftObject: Integer;
    function GetTopObject: Integer;
    function GetRightObject: Integer;
    function GetBottomObject: Integer;

    procedure btnAlignLeftClick(Sender: TObject);
    procedure btnAlignHCenterClick(Sender: TObject);
    procedure btnAlignRightClick(Sender: TObject);
    procedure btnAlignTopClick(Sender: TObject);
    procedure btnAlignBottomClick(Sender: TObject);
    procedure btnAlignHSEClick(Sender: TObject);
    procedure btnAlignVSEClick(Sender: TObject);
    procedure btnAlignHWCenterClick(Sender: TObject);
    procedure btnAlignVWCenterClick(Sender: TObject);
    procedure btnAlignVCenterClick(Sender: TObject);
    procedure btnAlignLeftRightClick(Sender: TObject);
    procedure btnAlignTopBottomClick(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarSize }
  TRMToolbarSize = class(TRMToolbar)
  private
    FPageEditor: TRMReportPageEditor;
    FDesignerForm: TRMDesignerForm;

    btnSetWidthToMin: TRMToolbarButton;
    btnSetWidthToMax: TRMToolbarButton;
    btnSetHeightToMin: TRMToolbarButton;
    btnSetHeightToMax: TRMToolbarButton;
    ToolbarSep979: TRMToolbarSep;

    procedure Localize;
    procedure btnSetWidthToMinClick(Sender: TObject);
    procedure btnSetWidthToMaxClick(Sender: TObject);
    procedure btnSetHeightToMinClick(Sender: TObject);
    procedure btnSetHeightToMaxClick(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMReportPageEditor }
  TRMReportPageEditor = class(TRMCustomPageEditor)
  private
    FDesignerForm: TRMDesignerForm;
    FToolbarComponent: TRMToolbarComponent;
    FToolbarEdit: TRMToolbarEdit;
    FToolbarAlign: TRMToolbarAlign;
    FToolbarBorder: TRMToolbarBorder;
    FToolbarSize: TRMToolbarSize;
    FToolbarAddinTools: TRMToolbarAddinTools;
    FWorkSpace: TRMWorkSpace;
    FOldFactor: Integer;
    FGridBitmap: TBitmap;
    FObjRepeat: Boolean; // was pressed Shift + Insert Object
    FShowSizes: Boolean;
    FShapeMode: TRMShapeMode; // show selection: frame or bar
    FFindReplaceForm: TForm;
    FUndoBusy: Boolean;

    Panel2: TRMPanel;
    FScrollBox: TRMNewScrollBox;
    pnlHorizontalRuler: TRMPanel;
    pnlVerticalRuler: TRMPanel;
    pnlWorkSpace: TRMPanel;
    FHRuler, FVRuler: TRMDesignerRuler;
    Panel7: TPanel;
    PBox1: TPaintBox;

   // 右键菜单
    FPopupMenu: TRMPopupMenu;
    padpopCut: TRMMenuItem;
    padpopCopy: TRMMenuItem;
    padpopPaste: TRMMenuItem;
    padpopDelete: TRMMenuItem;
    N8: TRMSeparatorMenuItem;
    padpopFrame: TRMMenuItem;
    padpopEdit: TRMMenuItem;
    padpopClearContents: TRMMenuItem;

    // 主菜单
    FMainMenu: TRMMenuBar;
    barEdit: TRMSubmenuItem;
    padUndo: TRMmenuItem;
    padRedo: TRMmenuItem;
    N47: TRMSeparatorMenuItem;
    padCut: TRMmenuItem;
    padCopy: TRMmenuItem;
    padPaste: TRMmenuItem;
    padDelete: TRMmenuItem;
    padSelectAll: TRMmenuItem;
    padEdit: TRMmenuItem;
    N3: TRMSeparatorMenuItem;
    padEditReplace: TRMmenuItem;
    N26: TRMSeparatorMenuItem;
    padBringtoFront: TRMmenuItem;
    padSendtoBack: TRMmenuItem;
    N4: TRMSeparatorMenuItem;
    itmEditLockControls: TRMmenuItem;

    barTools: TRMSubmenuItem;
    padSetToolbar: TRMSubmenuItem;
    Pan1: TRMmenuItem;
    Pan2: TRMmenuItem;
    Pan3: TRMmenuItem;
    Pan5: TRMmenuItem;
    Pan4: TRMmenuItem;
    Pan6: TRMmenuItem;
    Pan8: TRMmenuItem;
    Pan7: TRMmenuItem;
    Pan9: TRMmenuItem;
    padAddTools: TRMmenuItem;
    padOptions: TRMmenuItem;

    function GetSelectionStatus: TRMSelectionStatus;
    procedure Localize;
    procedure ShowObjMsg;
    procedure SetRulerOffset;
    procedure PBox1Paint(Sender: TObject);
    procedure OnScrollBox1ResizeEvent(Sender: TObject);
    procedure LoadIni;
    procedure SaveIni;
    procedure Popup1Popup(Sender: TObject);
    procedure padDeleteClick(Sender: TObject);
    procedure padpopFrameClick(Sender: TObject);
    procedure padpopEditClick(Sender: TObject);
    procedure padpopClearContentsClick(Sender: TObject);
    procedure OnpadAutoArrangeClick(Sender: TObject);
    function RectTypEnabled: Boolean;
    function ZEnabled: Boolean;
    function CutEnabled: Boolean;
    function CopyEnabled: Boolean;
    function PasteEnabled: Boolean;
    function DelEnabled: Boolean;
    function EditEnabled: Boolean;
    function RedoEnabled: Boolean;
    function UndoEnabled: Boolean;
    procedure MoveObjects(dx, dy: Integer; Resize: Boolean);
    procedure ShowEditor;
    procedure barFileClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure padEditClick(Sender: TObject);
    procedure padEditReplaceClick(Sender: TObject);
    procedure btnBringtoFrontClick(Sender: TObject);
    procedure btnSendtoBackClick(Sender: TObject);
    procedure itmEditLockControlsClick(Sender: TObject);
    procedure padSetToolbarClick(Sender: TObject);
    procedure Pan2Click(Sender: TObject);
    procedure Pan5Click(Sender: TObject);
    procedure padOptionsClick(Sender: TObject);
    procedure OnFindReplaceView(Sender: TObject);
    procedure ShowFieldsDialog(aVisible: Boolean);
  protected
  public
    constructor CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm); override;
    destructor Destroy; override;

    procedure GetDefaultSize(var aWidth, aHeight: Integer);
    procedure SendBandsToDown;
    function IsBandsSelect(var Band: TRMView): Boolean;
    procedure GetRegion;
    function GetFirstSelected: TRMView;

    procedure Undo(aBuffer: PRMUndoBuffer);
    procedure AddAction(aBuffer: PRMUndoBuffer; aAction: TRMUndoAction; aList: TList);
    procedure Editor_BtnUndoClick(Sender: TObject); override;
    procedure Editor_BtnRedoClick(Sender: TObject); override;
    procedure Editor_AddUndoAction(aAction: TRMUndoAction); override;

    procedure Editor_Localize; override;
    procedure Editor_OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string); override;
    procedure Editor_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure Editor_OnFormMouseWheelUp(aUp: Boolean); override;
    procedure Editor_Tab1Changed; override;
    procedure Editor_InitToolbarComponent; override;
    procedure Editor_DisableDraw; override;
    procedure Editor_EnableDraw; override;
    procedure Editor_RedrawPage; override;
    procedure Editor_Resize; override;
    procedure Editor_Init; override;
    procedure Editor_SetCurPage; override;
    procedure Editor_SelectionChanged(aRefreshInspProp: Boolean); override;
    procedure Editor_ShowPosition; override;
    procedure Editor_ShowContent; override;
    function Editor_PageObjects: TList; override;
    procedure Editor_OnInspGetObjects(aList: TStrings); override;
    procedure Editor_FillInspFields; override;
    procedure Editor_DoClick(Sender: TObject); override;
    procedure Editor_SelectObject(aObjName: string); override;
    procedure Editor_AfterChange; override;
    procedure Editor_SetObjectsID; override;
    procedure Editor_BtnCutClick(Sender: TObject); override;
    procedure Editor_BtnCopyClick(Sender: TObject); override;
    procedure Editor_BtnPasteClick(Sender: TObject); override;
    procedure Editor_EnableControls; override;
    procedure Editor_BtnDeletePageClick(Sender: TObject); override;
    procedure Editor_BeforeFormDestroy; override;

    property WorkSpace: TRMWorkSpace read FWorkSpace;
    property ToolbarComponent: TRMToolbarComponent read FToolbarComponent;
    property ObjRepeat: Boolean read FObjRepeat write FObjRepeat;
    property SelStatus: TRMSelectionStatus read GetSelectionStatus;
  published
  end;

var
  RM_ClipRgn: HRGN;
  RM_OldRect, RM_OldRect1: TRect; // object rect after mouse was clicked
  RM_SelectedManyObject: Boolean; // several objects was selected
  RM_FirstChange, RM_FirstBandMove: Boolean;
  CF_REPORTMACHINE: Word;

implementation

uses
  Math, Registry, RM_Const, RM_Const1, RM_Utils, RM_EditorMemo, RM_EditorBand, RM_EditorGroup,
  RM_EditorPicture, RM_EditorHilit, RM_EditorFrame, RM_EditorField,
  RM_EditorExpr, RM_PageSetup, RM_EditorReportProp, RM_DesignerOptions, RM_Printer,
  RM_EditorFormat, RM_EditorDictionary, RM_EditorFindReplace, RM_EditorTemplate,
  RM_EditorCalc, RM_EditorBandType;


type
  THackView = class(TRMView)
  end;

  THackDialogControl = class(TRMDialogControl)
  end;

  THackReport = class(TRMReport)
  end;

  THackPage = class(TRMCustomPage)
  end;

  THackReportPage = class(TRMReportPage)
  end;

  THackDesigner = class(TRMDesignerForm)
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMWorkSpace }

constructor TRMWorkSpace.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := AOwner as TWinControl;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Color := clWhite;
  BorderStyle := bsNone;

  PageForm := nil;

  OnMouseDown := OnMouseDownEvent;
  OnMouseUp := OnMouseUpEvent;
  OnMouseMove := OnMouseMoveEvent;
  OnDblClick := OnDoubleClickEvent;
  OnDragOver := DoDragOver;
  OnDragDrop := DoDragDrop;

  FFieldListBox := TListBox.Create(Self);
  with FFieldListBox do
  begin
    Visible := False;
    Parent := Self;
    Ctl3D := False;
    Style := lbOwnerDrawFixed;
    ItemHeight := 16;
    OnClick := OnFieldListBoxClick;
    OnDrawItem := OnFieldListBoxDrawItem;
  end;

  FBmp_Event := TBitmap.Create;
  FBmp_HighLight := TBitmap.Create;
  FBmp_Event.LoadFromResourceName(hInstance, 'RM_SCRIPT');
  FBmp_HighLight.LoadFromResourceName(hInstance, 'RM_HIGHLIGHT');
end;

destructor TRMWorkSpace.Destroy;
begin
  FreeAndNil(PageForm);
  FreeAndNil(FBmp_Event);
  FreeAndNil(FBmp_HighLight);

  inherited;
end;

procedure TRMWorkSpace.Init;
begin
  DisableDraw := False;
  FDragFlag := False;
  FMouseButtonDown := False;
  FDoubleClickFlag := False;
  FObjectsSelecting := False;
  Cursor := crDefault;
  FCursorType := ctNone;
end;

procedure TRMWorkSpace.SetPage;
var
  lWidth, lHeight: Integer;
  x1, y1, x2, y2: Integer;
begin
  if (FDesignerForm = nil) or (FDesignerForm.Page = nil) then Exit;

  if FDesignerForm.Page is TRMDialogPage then
  begin
    Align := alClient;
  end
  else
  begin
    lWidth := Round(TRMReportPage(FDesignerForm.Page).PrinterInfo.ScreenPageWidth * FDesignerForm.Factor / 100);
    lHeight := Round(TRMReportPage(FDesignerForm.Page).PrinterInfo.ScreenPageHeight * FDesignerForm.Factor / 100);
    if FDesignerForm.UnlimitedHeight then
      lHeight := lHeight * 3;

    Align := alNone;

    x1 := Round(TRMReportPage(FDesignerForm.Page).spMarginLeft * FDesignerForm.Factor / 100);
    y1 := Round(TRMReportPage(FDesignerForm.Page).spMarginTop * FDesignerForm.Factor / 100);
    x2 := lWidth - x1 - Round(TRMReportPage(FDesignerForm.Page).spMarginRight * FDesignerForm.Factor / 100);
    y2 := lHeight - y1 - Round(TRMReportPage(FDesignerForm.Page).spMarginBottom * FDesignerForm.Factor / 100);
    //Color := FDesignerForm.WorkSpaceColor;
    SetBounds(x1, y1, x2, y2);
  end;
end;

procedure TRMWorkSpace.Paint;
begin
  FPageEditor.SetRulerOffset;
  RedrawPage;
end;

procedure TRMWorkSpace.RoundCoord(var x, y: Integer);
begin
  with FDesignerForm do
  begin
    if GridAlign then
    begin
      x := x div GridSize * GridSize;
      y := y div GridSize * GridSize;
    end;
  end;
end;

procedure TRMWorkSpace.NormalizeRect(var r: TRect);
var
  i: Integer;
begin
  with r do
  begin
    if Left > Right then
    begin
      i := Left;
      Left := Right;
      Right := i
    end;

    if Top > Bottom then
    begin
      i := Top;
      Top := Bottom;
      Bottom := i
    end;
  end;
end;

procedure TRMWorkSpace.NormalizeCoord(t: TRMView);
begin
  if t.spWidth_Designer < 0 then
  begin
    t.spWidth_Designer := -t.spWidth_Designer;
    t.spLeft_Designer := t.spLeft_Designer - t.spWidth_Designer;
  end;
  if t.spHeight_Designer < 0 then
  begin
    t.spHeight_Designer := -t.spHeight_Designer;
    t.spTop_Designer := t.spTop_Designer - t.spHeight_Designer;
  end;
end;

procedure TRMWorkSpace.GetMultipleSelected;
var
  i, j, k: Integer;
  t: TRMView;
begin
  j := 0; k := 0;
  FLeftTop := Point(10000, 10000);
  RM_SelectedManyObject := False;
  if FDesignerForm.SelNum > 1 then {find right-bottom element}
  begin
    for i := 0 to FDesignerForm.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.PageObjects[i];
      if t.Selected then
      begin
        THackView(t).OriginalTop := t.spLeft_Designer;
        THackView(t).OriginalTop1 := t.spLeft_Designer;
        THackView(t).OriginalHeight := t.spTop_Designer;
        THackView(t).OriginalHeight := t.spTop_Designer;
        if (t.spLeft_Designer + t.spWidth_Designer > j) or ((t.spLeft_Designer + t.spWidth_Designer = j) and (t.spTop_Designer + t.spHeight_Designer > k)) then
        begin
          j := t.spLeft_Designer + t.spWidth_Designer;
          k := t.spTop_Designer + t.spHeight_Designer;
        end;
        if t.spLeft_Designer < FLeftTop.x then FLeftTop.x := t.spLeft_Designer;
        if t.spTop_Designer < FLeftTop.y then FLeftTop.y := t.spTop_Designer;
      end;
    end;

    RM_SelectedManyObject := True;
  end;
end;

procedure TRMWorkSpace.OnMouseDownEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  f, DontChange, v: Boolean;
  t: TRMView;
  Rgn: HRGN;
  p: TPoint;
  lRect: TRect;

  function _IsDropDownField(aView: TRMView): Boolean;
  begin
    Result := (aView is TRMReportView) and (X >= aView.spRight_Designer - 16) and
      (X <= aView.spRight_Designer) and
      (Y >= aView.spTop_Designer) and
      (Y <= aView.spTop_Designer + 16);
  end;

begin
  if FFieldListBox.Visible then
    FFieldListBox.Hide;

  FBandMoved := False;
  if FDoubleClickFlag then
  begin
    FDoubleClickFlag := False;
    Exit;
  end;

  DrawPage(dmSelection);
  FMouseButtonDown := True;
  DontChange := False;
  if Button = mbLeft then
  begin
    if (ssCtrl in Shift) or (Cursor = crCross) then
    begin
      FObjectsSelecting := True;
      if Cursor = crCross then
      begin
        DrawFocusRect(RM_OldRect);
        RoundCoord(x, y);
        RM_OldRect1 := RM_OldRect;
      end;
      RM_OldRect := Rect(x, y, x, y);
      FDesignerForm.UnSelectAll;
      FDesignerForm.SelNum := 0;
      RM_SelectedManyObject := False;
      FDesignerForm.FirstSelected := nil;
      Exit;
    end;
  end;

  if Cursor = crDefault then
  begin
    f := False;
    for i := FDesignerForm.PageObjects.Count - 1 downto 0 do
    begin
      t := FDesignerForm.PageObjects[i];
      Rgn := t.GetClipRgn(rmrtNormal);
      v := PtInRegion(Rgn, X, Y);
      DeleteObject(Rgn);
      if v then
      begin
        if ssShift in Shift then
        begin
          t.Selected := not t.Selected;
          if t.Selected then Inc(FDesignerForm.SelNum) else Dec(FDesignerForm.SelNum);
        end
        else
        begin
          if not t.Selected then
          begin
            if RM_Class.RMShowDropDownField and _IsDropDownField(t) and (t = FCurrentView) then
            begin
            end
            else
            begin
              FDesignerForm.UnSelectAll;
              FDesignerForm.SelNum := 1;
              t.Selected := True;
            end;
          end
          else
            DontChange := True;
        end;

        if FDesignerForm.SelNum = 0 then
          FDesignerForm.FirstSelected := nil
        else if FDesignerForm.SelNum = 1 then
          FDesignerForm.FirstSelected := t
        else if FDesignerForm.FirstSelected <> nil then
        begin
          if not FDesignerForm.FirstSelected.Selected then
            FDesignerForm.FirstSelected := nil;
        end;

        f := True;
        Break;
      end;
    end;

    if not f then
    begin
      FDesignerForm.UnSelectAll;
      FDesignerForm.SelNum := 0;
      FDesignerForm.FirstSelected := nil;
      if Button = mbLeft then
      begin
        FObjectsSelecting := True;
        RM_OldRect := Rect(x, y, x, y);
        Exit;
      end;
    end
    else if RM_Class.RMShowDropDownField and (not (ssShift in Shift)) and (FCurrentView <> nil)
      and _IsDropDownField(FCurrentView) then // 下拉字段选择列表
    begin
      FDesignerForm.Report.Dictionary.GetDataSetFields(FCurrentBand.DataSetName, FFieldListBox.Items);
      if FCurrentView.Memo.Count > 0 then
        FFieldListBox.ItemIndex := FFieldListBox.Items.IndexOf(RMGetFieldName(FCurrentView.Memo[0]));

      lRect.Left := FCurrentView.spLeft_Designer;
      lRect.Top := FCurrentView.spTop_Designer + 18;
      lRect.Right := lRect.Left + Max(140, FCurrentView.spWidth_Designer);
      lRect.Bottom := lRect.Top + 200;
      if lRect.Left < 0 then
      begin
        lRect.Right := lRect.Right - lRect.Left;
        lRect.Left := 0;
      end;
      if lRect.Bottom > ClientHeight then
      begin
        lRect.Top := lRect.Top - (lRect.Bottom - ClientHeight);
        lRect.Bottom := ClientHeight;
      end;

      FFieldListBox.BoundsRect := lRect;
      FFieldListBox.Show;
    end;

    GetMultipleSelected;
    if not DontChange then FPageEditor.Editor_SelectionChanged(True);
  end;

  if FDesignerForm.SelNum = 0 then
  begin // reset multiple selection
    RM_SelectedManyObject := False;
  end;
  FLastX := x;
  FLastY := y;
  FMoved := False;
  RM_FirstChange := True;
  RM_FirstBandMove := True;
  if Button = mbRight then
  begin
    DrawPage(dmSelection);
    FMouseButtonDown := False;
    GetCursorPos(p);
    FPageEditor.Editor_SelectionChanged(True);
    FPageEditor.FPopupMenu.Popup(p.X, p.Y);
  end
  else
    DrawPage(dmShape);
end;

procedure TRMWorkSpace.OnMouseUpEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, dx: Integer;
  t: TRMView;
  liNeedReDraw: Boolean;
  lObjectInserted: Boolean;

  function _GetUnusedBand: TRMBandType;
  var
    b: TRMBandType;
  begin
    Result := rmbtNone;
    for b := rmbtReportTitle to rmbtNone do
    begin
      if not FDesignerForm.RMCheckBand(b) then
      begin
        Result := b;
        Break;
      end;
    end;
    if Result = rmbtNone then
      Result := rmbtMasterData;
  end;

  procedure _AddObject(aType: Byte; aClassName: string);
  begin
    t := RMCreateObject(aType, aClassName);
    t.ParentPage := FDesignerForm.Page;
  end;

  procedure _SetControlParent;
  var
    i: Integer;
    lView: TRMView;
  begin
    if t is TRMDialogControl then
    begin
      for i := FDesignerForm.Page.Objects.Count - 2 downto 0 do
      begin
        lView := FDesignerForm.Page.Objects[i];
        if THackView(lView).IsContainer and
          (t.spLeft >= lView.spLeft) and (t.spTop >= lView.spTop) and
          (t.spLeft <= lView.spBottom) and (t.spTop <= lView.spBottom) then
        begin
          THackDialogControl(t).ParentControl := lView.Name;
          THackView(t).IsChildView := True;
          Break;
        end;
      end;
    end;
  end;

  procedure _CreateSection;
  var
    tmp: TRMBandTypesForm;
    lSubReportView: TRMView;
  begin
    tmp := TRMBandTypesForm.Create(nil);
    try
      lSubReportView := FDesignerForm.IsSubreport(FDesignerForm.CurPage);
      if (lSubReportView <> nil) and (TRMSubReportView(lSubReportView).SubReportType = rmstChild) then
        tmp.IsSubreport := True
      else
        tmp.IsSubreport := False;

      lObjectInserted := tmp.ShowModal = mrOk;
      if lObjectInserted then
      begin
        t := RMCreateBand(tmp.SelectedTyp);
        t.ParentPage := FDesignerForm.Page;
        FPageEditor.SendBandsToDown;
      end;
    finally
      tmp.Free;
    end;
  end;

  procedure _CreateSubReport;
  var
    lPage: TRMReportPage;
  begin
    t := RMCreateObject(rmgtSubReport, '');
    t.ParentPage := FDesignerForm.Page;
    TRMSubReportView(t).SubPage := FDesignerForm.Report.Pages.Count;
    with FDesignerForm, TRMReportPage(FDesignerForm.Page) do
    begin
      lPage := TRMReportPage(Report.Pages.AddReportPage);
      lPage.ChangePaper(PageSize, PrinterInfo.ScreenPageWidth, PrinterInfo.ScreenPageHeight, PageBin, PageOrientation);
      lPage.mmMarginLeft := mmMarginLeft;
      lPage.mmMarginTop := mmMarginTop;
      lPage.mmMarginRight := mmMarginRight;
      lPage.mmMarginBottom := mmMarginBottom;
      lPage.CreateName(True);
    end;
    FDesignerForm.SetPageTabs;
    FDesignerForm.CurPage := FDesignerForm.CurPage;
  end;

  procedure _SetDefaultProp;
  var
    lWidth, lHeight: Integer;
    lSaveDesignerRestrictions: TRMDesignerRestrictions;
  begin
    FDesignerForm.Modified := True;
    lSaveDesignerRestrictions := FDesignerForm.DesignerRestrictions;
    FDesignerForm.DesignerRestrictions := [];
    try
      with RM_OldRect do
      begin
        if (Left = Right) or (Top = Bottom) then
        begin
          lWidth := 36;
          lHeight := 36;
          if t is TRMCustomMemoView then
            FPageEditor.GetDefaultSize(lWidth, lHeight)
          else if FDesignerForm.Page is TRMDialogPage then
            t.DefaultSize(lWidth, lHeight);

          RM_OldRect := Rect(Left, Top, Left + lWidth, Top + lHeight);
        end;
      end;

      FDesignerForm.UnSelectAll;
      t.Selected := True;
      t.spLeft_Designer := RM_OldRect.Left;
      t.spTop_Designer := RM_OldRect.Top;
      if (t.spWidth_Designer = 0) and (t.spHeight_Designer = 0) then
      begin
        t.spWidth_Designer := RM_OldRect.Right - RM_OldRect.Left;
        t.spHeight_Designer := RM_OldRect.Bottom - RM_OldRect.Top;
      end;
      if t.IsBand and t.IsCrossBand then
      begin
        t.spWidth_Designer := 40;
      end;

      lWidth := t.spWidth_Designer;
      lHeight := t.spHeight_Designer;
      RoundCoord(lWidth, lHeight);
      t.spWidth_Designer := lWidth;
      t.spHeight_Designer := lHeight;
      if t is TRMCustomMemoView then
      begin
        t.LeftFrame.Visible := RM_LastLeftFrameVisible;
        t.TopFrame.Visible := RM_LastTopFrameVisible;
        t.RightFrame.Visible := RM_LastRightFrameVisible;
        t.BottomFrame.Visible := RM_LastBottomFrameVisible;
        t.LeftFrame.mmWidth := RM_LastFrameWidth;
        t.TopFrame.mmWidth := RM_LastFrameWidth;
        t.RightFrame.mmWidth := RM_LastFrameWidth;
        t.BottomFrame.mmWidth := RM_LastFrameWidth;
        t.LeftFrame.Color := RM_LastFrameColor;
        t.TopFrame.Color := RM_LastFrameColor;
        t.RightFrame.Color := RM_LastFrameColor;
        t.BottomFrame.Color := RM_LastFrameColor;
        t.FillColor := RM_LastFillColor;
        with TRMCustomMemoView(t) do
        begin
          Font.Name := RM_LastFontName;
          Font.Size := RM_LastFontSize;
          Font.Style := RMSetFontStyle(RM_LastFontStyle);
          Font.Color := RM_LastFontColor;
          Font.Charset := RM_LastFontCharset;
          HAlign := RM_LastHAlign;
          VAlign := RM_LastVAlign;
        end;
      end;

      if t is TRMDialogControl then
      begin
        THackDialogControl(t).Font := t.ParentPage.Font;
      end;

      FDesignerForm.SelNum := 1;
      if t.IsBand then
        Draw(10000, t.GetClipRgn(rmrtExtended))
      else
      begin
        t.Draw(Canvas);
        DrawSelection(t);
      end;

      FPageEditor.Editor_SelectionChanged(True);
    finally
      FDesignerForm.DesignerRestrictions := lSaveDesignerRestrictions;
    end;
  end;

  procedure _InsertControl;
  begin
    t := nil;
    if FDesignerForm.DesignerRestrictions * [rmdrDontCreateObj] = [] then
    begin
      if FPageEditor.ToolbarComponent.SelectedObjIndex >= 0 then
      begin
        case FPageEditor.ToolbarComponent.SelectedObjIndex of
          rmgtBand:
            begin
              if _GetUnusedBand <> rmbtNone then
                _CreateSection;
            end;
          rmgtSubReport:
            _CreateSubReport;
        else
          if FPageEditor.ToolbarComponent.SelectedObjIndex >= rmgtAddIn then
            _AddObject(rmgtAddIn, RMAddIns(FPageEditor.ToolbarComponent.SelectedObjIndex - rmgtAddIn).ClassRef.ClassName)
          else
            _AddObject(FPageEditor.ToolbarComponent.SelectedObjIndex, '');
        end;
      end;
    end;

    if t <> nil then
    begin
      _SetDefaultProp;
      FDesignerForm.SetObjectID(t);
      FDesignerForm.AddUndoAction(rmacInsert);
      _SetControlParent;
    end
    else
    begin
      FMoved := False;
      FCursorType := ctNone;
      FPageEditor.ToolbarComponent.btnNoSelect.Down := TRUE;
    end;
    if not FPageEditor.ObjRepeat then
      FPageEditor.ToolbarComponent.btnNoSelect.Down := True
    else
      DrawFocusRect(RM_OldRect);
  end;

begin
  if Button <> mbLeft then Exit;
  FMouseButtonDown := False;
  DrawPage(dmShape);

  //inserting a new object
  if Cursor = crCross then
  begin
    FMode := mdSelect;
    begin
      DrawFocusRect(RM_OldRect);
      if (RM_OldRect.Left = RM_OldRect.Right) and
        (RM_OldRect.Top = RM_OldRect.Bottom) then
        RM_OldRect := RM_OldRect1;
    end;
    NormalizeRect(RM_OldRect);
    FObjectsSelecting := False;

    FObjectsSelecting := False;
    _InsertControl;
    Exit;
  end;

  //calculating which objects contains in frame (if user select it with mouse+Ctrl key)
  if FObjectsSelecting then
  begin
    DrawFocusRect(RM_OldRect);
    FObjectsSelecting := False;
    NormalizeRect(RM_OldRect);
    for i := 0 to FDesignerForm.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.PageObjects[i];
      if t.IsBand then Continue;
      with RM_OldRect do
      begin
        if not ((t.spLeft_Designer > Right) or (t.spLeft_Designer + t.spWidth_Designer < Left) or
          (t.spTop_Designer > Bottom) or (t.spTop_Designer + t.spHeight_Designer < Top)) then
        begin
          t.Selected := True;
          Inc(FDesignerForm.SelNum);
        end;
      end;
    end;
    GetMultipleSelected;
    FPageEditor.Editor_SelectionChanged(True);
    DrawPage(dmSelection);
    Exit;
  end;

  // splitting
  if FMoved and RM_SelectedManyObject and (Cursor = crHSplit) then //同时改变
  begin
    with FSplitInfo do
    begin
      dx := SplRect.Left - SplX;
      if (View1.spWidth_Designer + dx > 0) and (View2.spWidth_Designer - dx > 0) then
      begin
        View1.spWidth_Designer := View1.spWidth_Designer + dx;
        View2.spLeft_Designer := View2.spLeft_Designer + dx;
        View2.spWidth_Designer := View2.spWidth_Designer - dx;
        FDesignerForm.Modified := True;
      end;
    end;
    GetMultipleSelected;
    Draw(FDesignerForm.TopSelected, RM_ClipRgn);
    Exit;
  end;

  // redrawing all FMoved or resized objects
  if not FMoved then
  begin
    FPageEditor.Editor_SelectionChanged(True);
    DrawPage(dmSelection);
  end;
  if (FDesignerForm.SelNum >= 1) and FMoved then
  begin
    liNeedReDraw := True;
    if ((Cursor = crSizeNS) or FBandMoved) and FPageEditor.IsBandsSelect(t) then
    begin
    end;

    if FDesignerForm.SelNum > 1 then
    begin
      if liNeedRedraw then
      begin
        Draw(FDesignerForm.TopSelected, RM_ClipRgn);
        GetMultipleSelected;
        FPageEditor.Editor_SelectionChanged(True);
      end;
    end
    else
    begin
      t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
      NormalizeCoord(t);
      if liNeedRedraw then
        Draw(FDesignerForm.TopSelected, RM_ClipRgn);
      FPageEditor.Editor_SelectionChanged(True);
    end;
  end;
  FMoved := False;
  FCursorType := ctNone;
end;

procedure TRMWorkSpace.OnMouseMoveEvent(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, kx, ky, w: Integer;
  t, t1, lBnd: TRMView;
  liBand: TRMView;
  lRgn: HRGN;
  lFlag: Boolean;

  function _Cont(px, py, x, y: Integer): Boolean;
  begin
    Result := (x >= px - w) and (x <= px + w + 1) and (y >= py - w) and (y <= py + w + 1);
  end;

  function _GridCheck: Boolean;
  begin
    with FDesignerForm do
    begin
      Result := (kx >= GridSize) or (kx <= -GridSize) or
        (ky >= GridSize) or (ky <= -GridSize);
      if Result then
      begin
        kx := kx - kx mod GridSize;
        ky := ky - ky mod GridSize;
      end;
    end;
  end;

  procedure _CheckWidthHeight(t: TRMView; aCursor1, aCursor2: TRMCursorType);
  begin
    if (t.spWidth_Designer < 0) or (t.spHeight_Designer < 0) then
    begin
      NormalizeCoord(t);
      FCursorType := aCursor1;
    end
    else
      FCursorType := aCursor2;
  end;

  function _isSplitting: Boolean; { 检查是不是两个选择了两个水平相连的对象，是的话，可以同时改变两个对象的width }
  var
    i, j: Integer;
  begin
    Result := False;
    if not FMouseButtonDown and (FDesignerForm.SelNum > 1) and (FMode = mdSelect) then
    begin
      for i := 0 to FDesignerForm.PageObjects.Count - 1 do
      begin
        t := FDesignerForm.PageObjects[i];
        if (not t.IsBand) and t.Selected then
        begin
          if (x >= t.spLeft_Designer) and (x <= t.spRight_Designer) and (y >= t.spTop_Designer) and (y <= t.spBottom_Designer) then
          begin
            for j := 0 to FDesignerForm.PageObjects.Count - 1 do
            begin
              t1 := FDesignerForm.PageObjects[j];
              if t1.IsBand or (t1 = t) or (not t1.Selected) then Continue;
              if (t.spLeft_Designer = t1.spRight_Designer) and (x >= t.spLeft_Designer) and (x <= t.spLeft_Designer + 2) then // 水平相邻，可以同时改变width
              begin
                Cursor := crHSplit;
                with FSplitInfo do
                begin
                  SplRect := Rect(x, t.spTop_Designer, x, t.spTop_Designer + t.spHeight_Designer);
                  if t.spLeft_Designer = t1.spLeft_Designer + t1.spWidth_Designer then
                  begin
                    SplX := t.spLeft_Designer;
                    View1 := t1;
                    View2 := t;
                  end
                  else
                  begin
                    SplX := t1.spLeft_Designer;
                    View1 := t;
                    View2 := t1;
                  end;
                  SplRect.Left := SplX;
                  SplRect.Right := SplX;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    // splitting
    if (Cursor = crHSplit) and FMouseButtonDown and RM_SelectedManyObject and (FMode = mdSelect) then
    begin
      Result := True;
      kx := x - FLastX;
      ky := 0;
      if (not FDesignerForm.GridAlign) or _GridCheck then
      begin
        with FSplitInfo do
        begin
          DrawHSplitter(SplRect);
          SplRect := Rect(SplRect.Left + kx, SplRect.Top, SplRect.Right + kx, SplRect.Bottom);
          DrawHSplitter(SplRect);
        end;
        FLastX := x - ((x - FLastX) - kx);
      end;
    end;
  end;

  procedure _SetMaxResizeHeight(aBand: TRMView; var ky: Integer);
  var
    i, lidx: Integer;
    t: TRMView;
  begin
    if ky >= 0 then Exit;
    for i := 0 to FDesignerForm.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.PageObjects[i];
      if (not t.IsBand) and (t.spTop_Designer >= aBand.spTop_Designer) and (t.spBottom_Designer <= aBand.spBottom_Designer) then
      begin
        lidx := aBand.spBottom_Designer - t.spBottom_Designer;
        if lidx < -ky then
          ky := -lidx;
      end;
    end;
    if - ky > aBand.spHeight_Designer then ky := -aBand.spHeight_Designer;
  end;

  procedure _GetDefaultSize(var aKx, aKy: Integer);
  var
    lIndex: Integer;
  begin
    if FDesignerForm.Page is TRMDialogPage then
    begin
      lIndex := FPageEditor.ToolbarComponent.SelectedObjIndex;
      if lIndex >= rmgtAddIn then
        RMAddIns(lIndex - rmgtAddIn).ClassRef.DefaultSize(aKx, aKy);
    end
    else
      FPageEditor.GetDefaultSize(kx, ky);
  end;

begin
  if FDesignerForm.Page = nil then Exit;

  FMoved := True; w := 2;
  if RM_FirstChange and FMouseButtonDown and not FObjectsSelecting then
  begin
    kx := x - FLastX;
    ky := y - FLastY;
    if not FDesignerForm.GridAlign or _GridCheck then
    begin
      FPageEditor.GetRegion;
      if (kx <> 0) or (ky <> 0) then
        FDesignerForm.AddUndoAction(rmacEdit);
    end;
  end;

  if not FMouseButtonDown then
  begin
    if FPageEditor.ToolbarComponent.btnNoSelect.Down then
    begin
      FMode := mdSelect;
      Cursor := crDefault;
      if FDesignerForm.SelNum = 0 then
      begin
        FPageEditor.FShowSizes := False;
        RM_OldRect := Rect(x, y, x, y);
        FPageEditor.ShowObjMsg;
      end;
    end
    else
    begin
      FMode := mdInsert; // 选择了控件，准备增加
      if Cursor <> crCross then
      begin
        RoundCoord(x, y);
        _GetDefaultSize(kx, ky);
        RM_OldRect := Rect(x, y, x + kx, y + ky);
        DrawFocusRect(RM_OldRect);
      end;
      Cursor := crCross;
    end;
  end;

  if (FMode = mdInsert) and (not FMouseButtonDown) then
  begin
    DrawFocusRect(RM_OldRect);
    RoundCoord(x, y);
    OffsetRect(RM_OldRect, x - RM_OldRect.Left, y - RM_OldRect.Top);
    DrawFocusRect(RM_OldRect);
    FPageEditor.FShowSizes := True;
    FPageEditor.ShowObjMsg;
    FPageEditor.FShowSizes := False;
    Exit;
  end;

  // cursor shapes
  if not FMouseButtonDown and (FDesignerForm.SelNum = 1) and (FMode = mdSelect) then
  begin
    t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
    if _Cont(t.spLeft_Designer, t.spTop_Designer, x, y) or _Cont(t.spLeft_Designer + t.spWidth_Designer, t.spTop_Designer + t.spHeight_Designer, x, y) then
      Cursor := crSizeNWSE // 改变一个对象大小
    else if _Cont(t.spLeft_Designer + t.spWidth_Designer, t.spTop_Designer, x, y) or _Cont(t.spLeft_Designer, t.spTop_Designer + t.spHeight_Designer, x, y) then
      Cursor := crSizeNESW
    else if _Cont(t.spLeft_Designer + t.spWidth_Designer div 2, t.spTop_Designer, x, y) or _Cont(t.spLeft_Designer + t.spWidth_Designer div 2, t.spTop_Designer + t.spHeight_Designer, x, y) then
      Cursor := crSizeNS
    else if _Cont(t.spLeft_Designer, t.spTop_Designer + t.spHeight_Designer div 2, x, y) or _Cont(t.spLeft_Designer + t.spWidth_Designer, t.spTop_Designer + t.spHeight_Designer div 2, x, y) then
      Cursor := crSizeWE
    else
      Cursor := crDefault;
  end;

  // selecting a lot of objects
  if FMouseButtonDown and FObjectsSelecting then
  begin
    DrawFocusRect(RM_OldRect);
    if Cursor = crCross then
      RoundCoord(x, y);
    RM_OldRect := Rect(RM_OldRect.Left, RM_OldRect.Top, x, y);
    DrawFocusRect(RM_OldRect);
    FPageEditor.FShowSizes := True;
    if Cursor = crCross then
      FPageEditor.ShowObjMsg;
    FPageEditor.FShowSizes := False;
    Exit;
  end;

  // selecting a lot of objects
  if FObjectsSelecting then // 选择Objects
  begin
    DrawFocusRect(RM_OldRect);
    RM_OldRect := Rect(RM_OldRect.Left, RM_OldRect.Top, x, y);
    DrawFocusRect(RM_OldRect);
    Exit;
  end;

  if _IsSplitting then
  begin
    Exit;
  end;

  // moving
  if FMouseButtonDown and (FMode = mdSelect) and (FDesignerForm.SelNum >= 1) and (Cursor = crDefault) then
  begin
    kx := x - FLastX;
    ky := y - FLastY;
    if FDesignerForm.GridAlign and not _GridCheck then Exit;
    if RM_FirstBandMove and (FDesignerForm.SelNum = 1) and ((kx <> 0) or (ky <> 0)) and not (ssAlt in Shift) then
    begin
      if TRMView(FDesignerForm.PageObjects[FDesignerForm.TopSelected]).isBand then
      begin
        lBnd := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
        for i := 0 to FDesignerForm.PageObjects.Count - 1 do
        begin
          t := FDesignerForm.PageObjects[i];
          if not t.IsBand then
            if (t.spLeft_Designer >= lBnd.spLeft_Designer) and (t.spLeft_Designer + t.spWidth_Designer <= lBnd.spLeft_Designer + lBnd.spWidth_Designer) and
              (t.spTop_Designer >= lBnd.spTop_Designer) and (t.spTop_Designer + t.spHeight_Designer <= lBnd.spTop_Designer + lBnd.spHeight_Designer) then
            begin
              t.Selected := True;
              Inc(FDesignerForm.SelNum);
            end;
        end;
        GetMultipleSelected;
      end;
    end;

    if (kx <> 0) or (ky <> 0) then
    begin
      RM_FirstBandMove := False;
    end;

    DrawPage(dmShape);
    for i := 0 to FDesignerForm.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.PageObjects[i];
      if not t.Selected then Continue;

      if t.IsCrossBand then
      begin
        t.spLeft_Designer := t.spLeft_Designer + kx;
        if kx <> 0 then FDesignerForm.Modified := True;
      end
      else if not FPageEditor.IsBandsSelect(liBand) then //对Band,控制其不能左右移动！
      begin
        t.spLeft_Designer := t.spLeft_Designer + kx;
        if kx <> 0 then
        begin
          FDesignerForm.Modified := True;
          FBandMoved := True;
        end;
      end;
      t.spTop_Designer := t.spTop_Designer + ky;
      if ky <> 0 then
      begin
        FDesignerForm.Modified := True;
        FBandMoved := True;
      end;
    end;
    DrawPage(dmShape);
    Inc(FLastX, kx);
    Inc(FLastY, ky);
    FPageEditor.ShowObjMsg;
  end;

  // resizing
  if FMouseButtonDown and (FMode = mdSelect) and (FDesignerForm.SelNum = 1) and (Cursor <> crDefault) then
  begin
    kx := x - FLastX;
    ky := y - FLastY;
    if FDesignerForm.GridAlign and not _GridCheck then Exit;
    DrawPage(dmShape);
    t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
    if t.IsBand then
    begin
      if TRMCustomBandView(t).IsCrossBand then
        ky := 0
      else
      begin
        kx := 0;
        _SetMaxResizeHeight(t, ky);
      end;
    end;
    FDesignerForm.Modified := True;
    w := 3;
    if Cursor = crSizeNWSE then // 右下角,左上角
    begin
      if ((FCursorType = ct1) or _Cont(t.spLeft_Designer, t.spTop_Designer, FLastX, FLastY)) and
        (FCursorType <> ct2) then
      begin
        t.spLeft_Designer := t.spLeft_Designer + kx;
        t.spWidth_Designer := t.spWidth_Designer - kx;
        t.spTop_Designer := t.spTop_Designer + ky;
        t.spHeight_Designer := t.spHeight_Designer - ky;
        _CheckWidthHeight(t, ct2, ct1);
      end
      else
      begin
        t.spWidth_Designer := t.spWidth_Designer + kx;
        t.spHeight_Designer := t.spHeight_Designer + ky;
        _CheckWidthHeight(t, ct1, ct2);
      end;
      if (ky <> 0) and t.IsBand and (not t.IsCrossBand) then
        FBandMoved := True;
    end;

    if Cursor = crSizeNESW then // 右上角,左下角
    begin
      if ((FCursorType = ct3) or _Cont(t.spLeft_Designer + t.spWidth_Designer, t.spTop_Designer, FLastX, FLastY)) and
        (FCursorType <> ct4) then
      begin
        t.spTop_Designer := t.spTop_Designer + ky;
        t.spWidth_Designer := t.spWidth_Designer + kx;
        t.spHeight_Designer := t.spHeight_Designer - ky;
        _CheckWidthHeight(t, ct4, ct3);
      end
      else
      begin
        t.spLeft_Designer := t.spLeft_Designer + kx;
        t.spWidth_Designer := t.spWidth_Designer - kx;
        t.spHeight_Designer := t.spHeight_Designer + ky;
        _CheckWidthHeight(t, ct3, ct4);
      end;
      if (ky <> 0) and t.IsBand and (not t.IsCrossBand) then
        FBandMoved := True;
    end;

    if Cursor = crSizeWE then // 改变width
    begin
      if ((FCursorType = ct5) or _Cont(t.spLeft_Designer, t.spTop_Designer + t.spHeight_Designer div 2, FLastX, FLastY)) and
        (FCursorType <> ct6) then
      begin
        t.spLeft_Designer := t.spLeft_Designer + kx;
        t.spWidth_Designer := t.spWidth_Designer - kx;
        _CheckWidthHeight(t, ct6, ct5);
      end
      else
      begin
        t.spWidth_Designer := t.spWidth_Designer + kx;
        _CheckWidthHeight(t, ct5, ct6);
      end;
    end;

    if Cursor = crSizeNS then // 改变Height
    begin
      if ((FCursorType = ct7) or _Cont(t.spLeft_Designer + t.spWidth_Designer div 2, t.spTop_Designer, FLastX, FLastY)) and
        (FCursorType <> ct8) then
      begin
        t.spTop_Designer := t.spTop_Designer + ky;
        t.spHeight_Designer := t.spHeight_Designer - ky;
        _CheckWidthHeight(t, ct8, ct7);
      end
      else
      begin
        t.spHeight_Designer := t.spHeight_Designer + ky;
        _CheckWidthHeight(t, ct7, ct8);
      end;
    end;

    DrawPage(dmShape);
    FLastX := x - ((x - FLastX) - kx);
    FLastY := y - ((y - FLastY) - ky);
    FPageEditor.ShowObjMsg;
  end;

  if (not (FDesignerForm.Page is TRMDialogPage)) and RM_Class.RMShowDropDownField and
    (not FMouseButtonDown) and (FMode = mdSelect) and (Cursor = crDefault) then
  begin
    t1 := FCurrentView;
    FCurrentView := nil;
    FCurrentBand := nil;
    for i := FDesignerForm.PageObjects.Count - 1 downto 0 do
    begin
      t := FDesignerForm.PageObjects[i];
      if not t.IsBand then
      begin
        lRgn := t.GetClipRgn(rmrtNormal);
        lFlag := PtInRegion(lRgn, X, Y);
        DeleteObject(lRgn);
        if lFlag and (t is TRMReportView) and RMHavePropertyName(t, 'DataField') then
        begin
          lBnd := FDesignerForm.GetParentBand(TRMReportView(t));
          if (lBnd is TRMBandMasterData) and (TRMBandMasterData(lBnd).DataSetName <> '') and
            (not TRMBandMasterData(lBnd).IsVirtualDataSet) then
          begin
            FCurrentView := TRMReportView(t);
            FCurrentBand := TRMBandMasterData(lBnd);
          end;
          Break;
        end;
      end;
    end;

    if t1 <> FCurrentView then
    begin
      if t1 <> nil then
        DrawRect(t1);
        //DrawObject(t1);
      //DrawPage(dmAll);
      //Repaint;

      if FCurrentView <> nil then
        DrawRect(FCurrentView);
        //DrawObject(FCurrentView);
    end;
  end;
end;

procedure TRMWorkSpace.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if ((FMode = mdInsert) and not FMouseButtonDown) or FDragFlag then
  begin
    DrawFocusRect(RM_OldRect);
    OffsetRect(RM_OldRect, -10000, -10000);
    Exit;
  end;
end;

procedure TRMWorkSpace.OnDoubleClickEvent(Sender: TObject);
begin
  FMouseButtonDown := False;
  if FDesignerForm.SelNum = 0 then
  begin
    if FDesignerForm.Page is TRMReportPage then
    begin
      FDoubleClickFlag := True;
    end
    else
    begin
    end
  end
  else if FDesignerForm.SelNum = 1 then
  begin
    FPageEditor.ShowEditor;
    FDoubleClickFlag := True;
  end;
end;

procedure TRMWorkSpace.DrawHSplitter(aRect: TRect);
begin
  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    MoveTo(aRect.Left, aRect.Top);
    LineTo(aRect.Right, aRect.Bottom);
    Pen.Mode := pmCopy;
  end;
end;

procedure TRMWorkSpace.DrawFocusRect(aRect: TRect);
begin
  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Rectangle(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
    Pen.Mode := pmCopy;
    Brush.Style := bsSolid;
  end;
end;

procedure TRMWorkSpace.DrawSelection(t: TRMView);
var
  px, py: Word;

  procedure _DrawPoint(x, y: Word);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x, y);
  end;

begin
  if not t.Selected then Exit;
  with t do
  begin
    Canvas.Pen.Width := 5;
    Canvas.Pen.Mode := pmXor;
    Canvas.Pen.Color := clWhite;
    px := spLeft_Designer + spWidth_Designer div 2;
    py := spTop_Designer + spHeight_Designer div 2;
    _DrawPoint(spLeft_Designer, spTop_Designer);
    _DrawPoint(spLeft_Designer + spWidth_Designer, spTop_Designer);
    _DrawPoint(spLeft_Designer, spTop_Designer + spHeight_Designer);
    _DrawPoint(spLeft_Designer + spWidth_Designer, spTop_Designer + spHeight_Designer);
    Canvas.Pen.Color := clWhite;
    if FDesignerForm.SelNum = 1 then
    begin
      _DrawPoint(px, spTop_Designer);
      _DrawPoint(px, spTop_Designer + spHeight_Designer);
      _DrawPoint(spLeft_Designer, py);
      _DrawPoint(spLeft_Designer + spWidth_Designer, py);
    end;
    Canvas.Pen.Mode := pmCopy;
  end;
end;

procedure TRMWorkSpace.DrawShape(t: TRMView);
begin
  if t.Selected then
  begin
    with t do
    begin
      if FPageEditor.FShapeMode = smFrame then
        DrawFocusRect(Rect(spLeft_Designer, spTop_Designer, spLeft_Designer + spWidth_Designer + 1, spTop_Designer + spHeight_Designer + 1))
      else
      begin
        with Canvas do
        begin
          Pen.Width := 1;
          Pen.Mode := pmNot;
          Brush.Style := bsSolid;
          Rectangle(spLeft_Designer, spTop_Designer, spLeft_Designer + spWidth_Designer + 1, spTop_Designer + spHeight_Designer + 1);
          Pen.Mode := pmCopy;
        end;
      end;
    end;
  end;
end;

procedure TRMWorkSpace.DrawObject(t: TRMView);
var
  lBmp: TBitmap;
begin
  t.Draw(Canvas);
  if THackView(t).HaveEventProp then
    Canvas.Draw(t.spLeft_Designer + 1, t.spTop_Designer + 1, FBmp_Event);

  if (t is TRMCustomMemoView) and (TRMCustomMemoView(t).Highlight.Condition <> '') then
    Canvas.Draw(t.spLeft_Designer + 1 + 8, t.spTop_Designer + 1, FBmp_HighLight);

  if RM_Class.RMShowDropDownField and (FCurrentView = t) then
  begin
    lBmp := TBitmap.Create;
    try
      lBmp.LoadFromResourceName(hInstance, 'RM_DropDownField');
      Canvas.Draw(FCurrentView.spRight_Designer - 16, FCurrentView.spTop_Designer + 1, lBmp);
    finally
      lBmp.Free;
    end;
  end;
end;

procedure TRMWorkSpace.DrawRect(aView: TRMView);
var
//  i: Integer;
//  t: TRMView;
//  lObjects: TList;
  lSaveObj: TRMReportView;
begin
  if FCurrentView = aView then
  begin
    if RM_Class.RMShowDropDownField then
    begin
      DrawObject(FCurrentView);
    end;
  end
  else
  begin
    lSaveObj := FCurrentView;
    try
      ReDrawPage;
    finally
      FCurrentView := lSaveObj;
    end;    
  end;

{  lObjects := THackPage(FDesignerForm.Page).Objects;
  lRgn1 := CreateRectRgn(aView.spLeft_Designer, aView.spTop_Designer, aView.spRight_Designer, aView.spBottom_Designer);
  try
    for i := 0 to lObjects.Count - 1 do
    begin
      t := lObjects[i];
      lRgn2 := CreateRectRgn(t.spLeft_Designer, t.spTop_Designer, t.spRight_Designer, t.spBottom_Designer);
      if (not t.IsBand) and (CombineRgn(lRgn2, lRgn1, lRgn2, RGN_AND) <> NULLREGION) then
        DrawObject(t);

      DeleteObject(lRgn2);
    end;
  finally
    DeleteObject(lRgn1);
  end;}
end;

procedure TRMWorkSpace.Draw(N: Integer; aClipRgn: HRGN);
var
  i: Integer;
  t: TRMView;
  R, R1: HRGN;
  lObjects: TList;
  lHavePic: Boolean;

  procedure _DrawBackground;
  var
    i, j: Integer;
    lDefaultColor: TColor;
  begin
    lDefaultColor := clBlack;
    with Canvas do
    begin
      Brush.Bitmap := nil;
      if FDesignerForm.ShowGrid and (FDesignerForm.GridSize <> 18) then
      begin
        with FPageEditor.FGridBitmap.Canvas do
        begin
          if FDesignerForm.Page is TRMDialogPage then
            Brush.Color := TRMDialogPage(FDesignerForm.Page).Color
          else
            Brush.Color := FDesignerForm.WorkSpaceColor;
          FillRect(Rect(0, 0, 8, 8));
          Pixels[0, 0] := lDefaultColor;
          if FDesignerForm.GridSize = 4 then
          begin
            Pixels[4, 0] := lDefaultColor;
            Pixels[0, 4] := lDefaultColor;
            Pixels[4, 4] := lDefaultColor;
          end;
        end;
        Brush.Bitmap := FPageEditor.FGridBitmap;
      end
      else
      begin
        if FDesignerForm.Page is TRMDialogPage then
          Brush.Color := TRMDialogPage(FDesignerForm.Page).Color
        else
          Brush.Color := FDesignerForm.WorkSpaceColor;
        Brush.Style := bsSolid;
      end;

      FillRgn(Handle, R, Brush.Handle);
      if FDesignerForm.ShowGrid and (FDesignerForm.GridSize = 18) then
      begin
        i := 0;
        while i < Width do
        begin
          j := 0;
          while j < Height do
          begin
            if RectVisible(Handle, Rect(i, j, i + 1, j + 1)) then
              SetPixel(Handle, i, j, lDefaultColor);
            Inc(j, FDesignerForm.GridSize);
          end;
          Inc(i, FDesignerForm.GridSize);
        end;
      end;
    end;
  end;

  procedure _DrawbkGroundPic; // 背景图片
  var
    liRect: TRect;
    lPicWidth, lPicHeight: Integer;
  begin
    if lHavePic then
    begin
      with THackReportPage(FDesignerForm.Page).FbkPicture do
      begin
        lPicWidth := Round(TRMReportPage(FDesignerForm.Page).bkPictureWidth * FDesignerForm.Factor / 100);
        lPicHeight := Round(TRMReportPage(FDesignerForm.Page).bkPictureHeight * FDesignerForm.Factor / 100);
        liRect := Rect(0, 0, lPicWidth, lPicHeight);
        OffsetRect(liRect, -Round(TRMReportPage(FDesignerForm.Page).spMarginLeft * FDesignerForm.Factor / 100),
          -Round(TRMReportPage(FDesignerForm.Page).spMarginTop * FDesignerForm.Factor / 100));
        OffsetRect(liRect, Round(TRMReportPage(FDesignerForm.Page).spBackGroundLeft * FDesignerForm.Factor / 100),
          Round(TRMReportPage(FDesignerForm.Page).spBackGroundTop * FDesignerForm.Factor / 100));
        RMPrintGraphic(Canvas, liRect, Graphic, False, True, False);
      end;
    end;
  end;

  function _IsVisible(t: TRMView): Boolean;
  var
    R: HRGN;
  begin
    R := t.GetClipRgn(rmrtNormal);
    Result := CombineRgn(R, R, aClipRgn, RGN_AND) <> NULLREGION;
    DeleteObject(R);
  end;

  procedure _DrawMargins;
  var
    i, j, lColumnWidth: Integer;
  begin
    with Canvas do
    begin
      Brush.Style := bsClear;
      Pen.Width := 1;
      Pen.Color := clGray;
      Pen.Style := psSolid;
      Pen.Mode := pmCopy;
      if FDesignerForm.Page is TRMReportPage then
      begin
        Rectangle(0, 0, Width, Height);
        with TRMReportPage(FDesignerForm.Page) do
        begin
          if ColumnCount > 1 then
          begin
            lColumnWidth := (Width - ((ColumnCount - 1) * spColumnGap)) div ColumnCount;
            Pen.Style := psDot;
            j := 0;
            for i := 1 to ColumnCount do
            begin
              Rectangle(j, 0, j + lColumnWidth + 1, Height);
              j := j + lColumnWidth + spCOlumnGap;
            end;
            Pen.Style := psSolid;
          end;
        end;
      end;
    end;
  end;

begin
  FCurrentView := nil;
  if (FDesignerForm.Page = nil) or FDisableDraw then Exit;

  FDesignerForm.Report.DocMode := rmdmDesigning;
  lObjects := THackPage(FDesignerForm.Page).Objects;
  if aClipRgn = 0 then
  begin
    with Canvas.ClipRect do
      aClipRgn := CreateRectRgn(Left, Top, Right, Bottom);
  end;

  lHavePic := (FDesignerForm.Page is TRMReportPage) and (THackReportPage(FDesignerForm.Page).FbkPicture <> nil) and
    (THackReportPage(FDesignerForm.Page).FbkPicture.Graphic <> nil);
  SetTextCharacterExtra(Canvas.Handle, 0);
  R := CreateRectRgn(0, 0, Width, Height);
  for i := lObjects.Count - 1 downto 0 do
  begin
    t := lObjects[i];
    if lHavePic and t.IsBand then Continue;

    if THackView(t).IsChildView then
    begin
      Continue;
    end;

    if i <= N then
    begin
      if t.Selected then
        DrawObject(t)
      else if _IsVisible(t) then
      begin
        R1 := CreateRectRgn(0, 0, 1, 1);
        CombineRgn(R1, aClipRgn, R, RGN_AND);
        SelectClipRgn(Canvas.Handle, R1);
        DeleteObject(R1);
        DrawObject(t);
      end;
    end;

    SetTextCharacterExtra(Canvas.Handle, 0);
    R1 := t.GetClipRgn(rmrtNormal);
    CombineRgn(R, R, R1, RGN_DIFF);
    DeleteObject(R1);
    SelectClipRgn(Canvas.Handle, R);
  end;

  CombineRgn(R, R, aClipRgn, RGN_AND);
  _DrawBackground;
  _DrawbkGroundPic;

  if lHavePic then
  begin
    for i := lObjects.Count - 1 downto 0 do
    begin
      t := lObjects[i];
      //      if not t.IsBand then
      DrawObject(t);
    end;
  end;

  DeleteObject(R);
  DeleteObject(aClipRgn);
  SelectClipRgn(Canvas.Handle, 0);
  _DrawMargins;
  if not FMouseButtonDown then
  begin
    DrawPage(dmSelection);
  end;
end;

procedure TRMWorkSpace.DrawPage(aDrawMode: TRMDesignerDrawMode);
var
  i: Integer;
  t: TRMView;
begin
  if FDesignerForm.Report.DocMode <> rmdmDesigning then Exit;
  for i := 0 to FDesignerForm.PageObjects.Count - 1 do
  begin
    t := FDesignerForm.PageObjects[i];
    case aDrawMode of
      dmAll: t.Draw(Canvas);
      dmSelection: DrawSelection(t);
      dmShape: DrawShape(t);
    end;
  end;
end;

procedure TRMWorkSpace.RedrawPage;
begin
  Draw(10000, 0);
end;

procedure TRMWorkSpace.DoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  kx, ky: Integer;
begin
  Accept := (Source = FDesignerForm.FieldForm.lstFields) and
    (FDesignerForm.DesignerRestrictions * [rmdrDontCreateObj] = []) and
    (FDesignerForm.Page is TRMReportPage);
  if not Accept then Exit;

  if not FDragFlag then
  begin
    FDragFlag := True;
    FPageEditor.GetDefaultSize(kx, ky);
    RM_OldRect := Rect(x - 4, y - 4, x + kx - 4, y + ky - 4);
  end
  else
    DrawFocusRect(RM_OldRect);

  RoundCoord(x, y);
  OffsetRect(RM_OldRect, x - RM_OldRect.Left - 4, y - RM_OldRect.Top - 4);
  DrawFocusRect(RM_OldRect);
end;

procedure TRMWorkSpace.DoDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  t: TRMView;
begin
  FDragFlag := False;
  DrawPage(dmSelection);
  FDesignerForm.UnSelectAll;
  FPageEditor.ToolbarComponent.FSelectedObjIndex := rmgtMemo;
  FPageEditor.ToolbarComponent.FBtnMemoView.Down := True;
  Cursor := crCross;
  OnMouseUpEvent(nil, mbLeft, [], 0, 0);
  t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
  t.Memo.Text := '[' + FDesignerForm.FieldForm.DBField + ']';
  if t is TRMCustomMemoView then
    TRMCustomMemoView(t).DBFieldOnly := True;

  DrawSelection(t);
  t.Draw(Canvas);
  DrawSelection(t);
end;

procedure TRMWorkSpace.CopyToClipboard;
var
  hMem: THandle;
  pMem: pointer;
  lStream: TMemoryStream;

  procedure _SelectionToMemStream(aStream: TMemoryStream);
  var
    i, liNum: Integer;
    t: TRMView;
  begin
    aStream.Clear;
    RMWriteInt32(aStream, 0);
    liNum := 0;
    for i := 0 to FDesignerForm.Page.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.Page.PageObjects[i];
      if t.Selected then
      begin
        RMWriteByte(aStream, t.ObjectType);
        RMWriteString(aStream, t.ClassName);
        THackView(t).StreamMode := rmsmDesigning;
        t.SaveToStream(aStream);
        Inc(liNum);
      end;
    end;

    aStream.Position := 0;
    RMWriteInt32(aStream, liNum);
    aStream.Seek(0, soFromEnd);
  end;

begin
  lStream := TMemoryStream.Create;
  try
    _SelectionToMemStream(lStream);
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
          ClipBoard.SetAsHandle(CF_REPORTMACHINE, hMem);
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

procedure TRMWorkSpace.DeleteObjects(aAddUndoAction: Boolean);
var
  i: Integer;
  t: TRMView;
begin
  if FDesignerForm.DesignerRestrictions * [rmdrDontDeleteObj] <> [] then Exit;

  if aAddUndoAction then
  begin
    FDesignerForm.AddUndoAction(rmacDelete);
  end;

  FPageEditor.GetRegion;
  DrawPage(dmSelection);
  for i := FDesignerForm.Page.Objects.Count - 1 downto 0 do
  begin
    t := FDesignerForm.Page.Objects[i];
    if t.Selected and (t.Restrictions * [rmrtDontDelete] = []) then
    begin
      if FCurrentView = t then
        FCurrentView := nil;

      FDesignerForm.Page.Delete(i);
      FDesignerForm.Modified := True;
    end;
  end;

  FDesignerForm.ResetSelection;
  FDesignerForm.FirstSelected := nil;
  Draw(10000, RM_ClipRgn);
end;

procedure TRMWorkSpace.PasteFromClipboard;
var
  minx, miny: Integer;
  t: TRMView;
  b: Byte;
  lPoint: TPoint;
  hMem: THandle;
  pMem: pointer;
  hSize: DWORD;
  liStream: TMemoryStream;
  i, liCount: Integer;

  procedure _CreateName(t: TRMView);
  begin
    if FDesignerForm.Report.FindObject(t.Name) <> nil then
    begin
      t.CreateName(FDesignerForm.Report);
      t.Name := t.Name;
    end;
  end;

  procedure _GetMinXY;
  var
    i, liCount: Integer;
  begin
    liStream.Seek(soFromBeginning, 0);
    liCount := RMReadInt32(liStream);
    for i := 0 to liCount - 1 do
    begin
      b := RMReadByte(liStream);
      t := RMCreateObject(b, RMReadString(liStream));
      try
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(liStream);
        if Round(t.spLeft / FDesignerForm.Factor * 100) < minx then
          minx := Round(t.spLeft / FDesignerForm.Factor * 100);
        if Round(t.spTop / FDesignerForm.Factor * 100) < miny then
          miny := Round(t.spTop / FDesignerForm.Factor * 100);
      finally
        t.Free;
      end;
    end;

    if (lPoint.X >= 0) and (lPoint.X < Self.Width) and (lPoint.Y >= 0) and
      (lPoint.Y < Self.Height) then
    begin
      minx := lPoint.X - minx;
      miny := lPoint.Y - miny;
    end
    else
    begin
      minx := -minx + (-Self.Left) div FDesignerForm.GridSize * FDesignerForm.GridSize;
      miny := -miny + (-Self.Left) div FDesignerForm.GridSize * FDesignerForm.GridSize;
    end;
  end;

begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanPaste then
    begin
      FDesignerForm.CodeMemo.RMClipBoardPaste;
      FDesignerForm.ShowPosition;
    end;
    Exit;
  end;

  GetCursorPos(lPoint);
  lPoint := Self.ScreenToClient(lPoint);

  FDesignerForm.UnSelectAll;
  FDesignerForm.SelNum := 0;
  minx := 32767;
  miny := 32767;

  liStream := nil;
  Clipboard.Open;
  try
    hMem := Clipboard.GetAsHandle(CF_REPORTMACHINE);
    pMem := GlobalLock(hMem);
    if pMem <> nil then
    begin
      hSize := GlobalSize(hMem);
      liStream := TMemoryStream.Create;
      try
        liStream.Write(pMem^, hSize);
      finally
        GlobalUnlock(hMem);
      end;
    end;
  finally
    Clipboard.Close;
  end;

  if liStream = nil then Exit;

  try
    _GetMinXY;
    liStream.Seek(soFromBeginning, 0);
    liCount := RMReadInt32(liStream);
    for i := 0 to liCount - 1 do
    begin
      b := RMReadByte(liStream);
      t := RMCreateObject(b, RMReadString(liStream));
      t.NeedCreateName := False;
      try
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(liStream);
        if (t is TRMSubReportView) or
          ((FDesignerForm.Page is TRMReportPage) and (t is TRMDialogComponent)) or
          (FDesignerForm.Page is TRMDialogPage) and (t is TRMReportView) then
        begin
          t.Free;
          Continue;
        end;

        if t.IsBand then
        begin
          if not (TRMCustomBandView(t).BandType in [rmbtMasterData, rmbtDetailData, rmbtHeader, rmbtFooter,
            rmbtGroupHeader, rmbtGroupFooter]) and FDesignerForm.RMCheckBand(TRMCustomBandView(t).BandType) then
          begin
            t.Free;
            Continue;
          end;
        end;

        t.Selected := True;
        Inc(FDesignerForm.SelNum);
        t.ParentPage := FDesignerForm.Page;
        _CreateName(t);

        begin
          t.spLeft_Designer := t.spLeft_Designer + minx;
          t.spTop_Designer := t.spTop_Designer + miny;
        end;

        FDesignerForm.SetObjectID(t);
      finally
      end;
    end;
  finally
    liStream.Free;
    FPageEditor.Editor_SelectionChanged(True);
    FPageEditor.SendBandsToDown;
    Self.GetMultipleSelected;
    FPageEditor.Editor_RedrawPage;
    FDesignerForm.Modified := True;
    FDesignerForm.AddUndoAction(rmacInsert);
  end;
end;

procedure TRMWorkSpace.SelectAll;
var
  i: Integer;
  t, liBand: TRMView;
begin
  if FPageEditor.IsBandsSelect(liBand) then //是否选择当前Band中的所有对象
  begin
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := TRMView(FDesignerForm.Objects[i]);
      if (not t.IsBand) and (t.spTop_Designer >= liBand.spTop_Designer) and (t.spHeight_Designer <= liBand.spHeight_Designer) then
      begin
        t.Selected := True;
        Inc(FDesignerForm.SelNum);
      end;
    end;
  end
  else
  begin
    FDesignerForm.SelNum := 0;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      TRMView(FDesignerForm.Objects[i]).Selected := True;
      Inc(FDesignerForm.SelNum);
    end;
  end;
end;

procedure TRMWorkSpace.OnFieldListBoxClick(Sender: TObject);
begin
  FFieldListBox.Hide;
  if (FCurrentView <> nil) and (FFieldListBox.ItemIndex >= 0) then
  begin
    FDesignerForm.BeforeChange;
    RMSetPropValue(FCurrentView,
      'DataField',
      Format('[%s."%s"]', [FCurrentBand.DataSetName, FFieldListBox.Items[FFieldListBox.ItemIndex]]));
    if FCurrentView is TRMCustomMemoView then
      TRMCustomMemoVIew(FCurrentView).DBFieldOnly := True;

    if (FCurrentView <> nil) and (not FCurrentView.Selected) then
    begin
      DrawRect(FCurrentView);
    end;

    FDesignerForm.AfterChange;
  end;
end;

procedure TRMWorkSpace.OnFieldListBoxDrawItem(aControl: TWinControl; aIndex: Integer;
  aRect: TRect; aState: TOwnerDrawState);
var
  lBmp: TBitmap;
begin
  lBmp := TBitmap.Create;
  try
    lBmp.LoadFromResourceName(hInstance, 'RM_FLD2');
    with TListBox(aControl) do
    begin
      Canvas.FillRect(aRect);
      Canvas.BrushCopy(
        Bounds(aRect.Left + 2, aRect.Top, lBmp.Width, lBmp.Height),
        lBmp,
        Bounds(0, 0, lBmp.Width, lBmp.Height),
        lBmp.TransparentColor);
      Canvas.TextOut(aRect.Left + 4 + lBmp.Width, aRect.Top, Items[aIndex]);
    end;
  finally
    lBmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarComponent }

const
  ButtonWidth = 28;

constructor TRMToolbarComponent.CreateComp(aOwner: TComponent);

  procedure _CreateBandsMenu;
  var
    bt: TRMBandType;
    item: TMenuItem;
  begin
    FBandsMenu := TPopupMenu.Create(AOwner);
    FBandsMenu.AutoHotkeys := maManual;
    FBandsMenu.OnPopup := OnBandMenuPopup;

    for bt := rmbtReportTitle to rmbtCrossChild do
    begin
      item := TMenuItem.Create(FBandsMenu);
      item.Caption := RMBandNames[TRMBandType(bt)];
      item.Tag := Ord(bt);
      item.OnClick := OnAddBandEvent;
      FBandsMenu.Items.Add(item);
    end;
  end;

begin
  inherited Create(aOwner);

  FPageEditor := TRMReportPageEditor(aOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  FWorkSpace := FPageEditor.FWorkSpace;
  FOldPageType := -1;
  Parent := {FPageEditor.Panel2} FDesignerForm;
  BevelInner := bvLowered; //bvNone;
  BevelOuter := bvNone;
  Align := alLeft;
  ClientWidth := ButtonWidth + 2;
  FControlIndex := 3;

  FImageList := TImageList.Create(Self);
  FImageList.Width := 24;
  FImageList.Height := 24;
  FPopupMenuComponent := TPopupMenu.Create(Self);
  FPopupMenuComponent.AutoHotkeys := maManual;
  FPopupMenuComponent.Images := FImageList;

  FBtnNoSelect := TSpeedButton.Create(Self);
  with FBtnNoSelect do
  begin
    Parent := Self;
    Flat := True;
    Glyph.LoadFromResourceName(hInstance, 'RM_ComponentNoSelect');
    SetBounds(1, 1, ButtonWidth, ButtonWidth);
    AllowAllUp := True;
    GroupIndex := 9999;
    OnClick := OnOB1ClickEvent;
    Tag := -1;
    ShowHint := True;
    RMSetStrProp(FBtnNoSelect, 'Hint', rmRes + 132);
  end;

{$IFDEF USE_TB2K}
  FBtnUp := TSpeedButton.Create(Self);
{$ELSE}
  FBtnUp := TRMToolbarButton.Create(Self);
{$ENDIF}
  with FBtnUp do
  begin
    Parent := Self;
    Flat := True;
    Glyph.LoadFromResourceName(hInstance, 'RM_MYSPINUP');
    SetBounds(1, FBtnNoSelect.Top + FBtnNoSelect.Height, ButtonWidth, 16);
    Tag := -1;
{$IFNDEF USE_TB2K}
    Repeating := True;
{$ENDIF}
    OnClick := OnBtnUpClickEvent;
  end;

{$IFDEF USE_TB2K}
  FBtnDown := TSpeedButton.Create(Self);
{$ELSE}
  FBtnDown := TRMToolbarButton.Create(Self);
{$ENDIF}
  with FBtnDown do
  begin
    Parent := Self;
    Flat := True;
    Glyph.LoadFromResourceName(hInstance, 'RM_MYSPINDOWN');
    SetBounds(1, Self.Height - 16, ButtonWidth, 16);
    Tag := -1;
{$IFNDEF USE_TB2K}
    Repeating := True;
{$ENDIF}
    OnClick := OnBtnDownClickEvent;
  end;

  _CreateBandsMenu;
  OnResize := OnResizeEvent;
end;

destructor TRMToolbarComponent.Destroy;
begin
  inherited;
end;

const
  DefaultControlBmps: array[0..4] of string = ('RM_ComponentMemo', 'RM_ComponentCalcMemo',
    'RM_ComponentPicture', 'RM_ComponentShape', 'RM_ComponentSubReport');
  DefaultControlTyps: array[0..4] of byte = (rmgtMemo, rmgtCalcMemo, rmgtPicture, rmgtShape,
    rmgtSubReport);
  DefaultControlHints: array[0..4] of Integer = (rmRes + 133, rmRes + 137, rmRes + 135,
    SInsShape, rmRes + 136);

procedure TRMToolbarComponent.CreateObjects;
var
  liNeedCreate: Boolean;
  liNowTop: Integer;
  lAddInObjectInfo: TRMAddinObjectInfo;
  lButton: TSpeedButton;

  procedure _CreateBandObject;
  var
    i: Integer;
    liButton: TSpeedButton;
  begin
    FObjectBand := TSpeedButton.Create(Self);
    with FObjectBand do
    begin
      Parent := Self;
      Flat := True;
      SetBounds(1, liNowTop, ButtonWidth, ButtonWidth);
      Glyph.LoadFromResourceName(hInstance, 'RM_ComponentBand');
      Tag := rmgtBand;
      AllowAllUp := True;
      GroupIndex := 9999;
      OnClick := OnButtonBandClickEvent;
      OnMouseDown := OnOB2MouseDownEvent;
      ShowHint := True;
      RMSetStrProp(FObjectBand, 'Hint', rmRes + 134);
      Inc(liNowTop, ButtonWidth);
    end;

    for i := Low(DefaultControlBmps) to High(DefaultControlBmps) do
    begin
      liButton := TSpeedButton.Create(Self);
      with liButton do
      begin
        Parent := Self;
        Flat := True;
        SetBounds(1, liNowTop, ButtonWidth, ButtonWidth);
        Glyph.LoadFromResourceName(hInstance, DefaultControlBmps[i]);
        Tag := DefaultControlTyps[i];
        AllowAllUp := True;
        GroupIndex := 9999;
        OnClick := OnOB2ClickEvent;
        OnMouseDown := OnOB2MouseDownEvent;
        ShowHint := True;
        RMSetStrProp(liButton, 'Hint', DefaultControlHints[i]);
        if i = 0 then
          FBtnMemoView := liButton;
      end;
      Inc(liNowTop, ButtonWidth);
    end;
  end;

  procedure _CreateButtons(aPageFlag: Boolean);
  var
    i: Integer;
  begin
    for i := 0 to RMAddInsCount - 1 do
    begin
      lAddInObjectInfo := RMAddIns(i);
      if lAddInObjectInfo.IsPage and
        (((FOldPageType = 1) and (lAddInObjectInfo.IsControl)) or
        ((FOldPageType = 2) and (not lAddInObjectInfo.IsControl))) then
      begin
        if (lAddInObjectInfo.ClassRef = nil) and (not aPageFlag) then Continue;
        if (lAddInObjectInfo.ClassRef <> nil) and (aPageFlag) then Continue;

        lButton := TSpeedButton.Create(Self);
        with lButton do
        begin
          Parent := Self;
          Flat := True;
          SetBounds(1, liNowTop, ButtonWidth, ButtonWidth);
          AllowAllUp := True;
          OnClick := OnOB2ClickEvent;

          if (lAddInObjectInfo.Page <> '') and (aPageFlag) then
          begin
            GroupIndex := 0;
            OnClick := OnOB2ClickEvent_1;
          end
          else if (lAddInObjectInfo.Page = '') and (not aPageFlag) then
          begin
            OnClick := OnOB2ClickEvent;
            OnMouseDown := OnOB2MouseDownEvent;
            GroupIndex := 9999;
          end;

          ShowHint := True;
          Glyph.LoadFromResourceName(Hinstance, lAddInObjectInfo.ButtonBmpRes);
          Tag := rmgtAddIn + i;
          Hint := lAddInObjectInfo.ButtonHint;
        end;
      end;
      Inc(liNowTop, ButtonWidth);
    end;
  end;

begin
  if FDesignerForm.Page is TRMDialogPage then
    liNeedCreate := FOldPageType <> 1
  else
    liNeedCreate := FOldPageType <> 2;

  if not liNeedCreate then Exit;

  FSelectedObjIndex := -1;
  while ControlCount > 3 do
    Controls[3].Free;

  FControlIndex := 3;
  liNowTop := FBtnUp.Top + FBtnUp.Height;
  if FDesignerForm.Page is TRMDialogPage then FOldPageType := 1 else FOldPageType := 2;

  FObjectBand := nil;
  if FOldPageType = 2 then
    _CreateBandObject;

  _CreateButtons(False);
  _CreateButtons(True);
  RefreshControls;
end;

procedure TRMToolbarComponent.OnButtonBandClickEvent(Sender: TObject);
begin
//
end;

procedure TRMToolbarComponent.OnOB2ClickEvent(Sender: TObject);
begin
  FBtnNoSelect.Down := not TSpeedButton(Sender).Down;
end;

procedure TRMToolbarComponent.OnOB2MouseDownEvent(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FWorkSpace.FPageEditor.ObjRepeat := ssShift in Shift;
  FPageEditor.FWorkSpace.Cursor := crDefault;
  FSelectedObjIndex := TSpeedButton(Sender).Tag;
end;

procedure TRMToolbarComponent.OnAddInObectMenuItemClick(Sender: TObject);
begin
  FBtnNoSelect.Down := False;
  FWorkSpace.FPageEditor.ObjRepeat := False;
  FPageEditor.FWorkSpace.Cursor := crDefault;
  FSelectedObjIndex := TMenuItem(Sender).Tag;
end;

procedure TRMToolbarComponent.OnOB2ClickEvent_1(Sender: TObject);
var
  i, j: Integer;
  lPage: string;
  lMenuItem: TMenuItem;
  lPoint: TPoint;
  lBmp: TBitmap;
begin
  lPage := RMAddIns(TSpeedButton(Sender).Tag - rmgtAddIn).Page;
  FPopupMenuComponent.Items.Clear;
  FImageList.Clear;

  lBmp := TBitmap.Create;
  try
    j := 0;
    for i := 0 to RMAddInsCount - 1 do
    begin
      if (not RMAddIns(i).IsPage) and (RMAddIns(i).Page = lPage) then
      begin
        lBmp.LoadFromResourceName(Hinstance, RMAddIns(i).ButtonBmpRes);
        //        FImageList.Add(lBmp, nil);
        FImageList.AddMasked(lBmp, lBmp.TransparentColor);

        lMenuItem := TMenuItem.Create(Self);
        lMenuItem.Caption := RMAddIns(i).ButtonHint;
        if (lMenuItem.Caption = '') and (RMAddIns(i).ClassRef <> nil) then
          lMenuItem.Caption := RMAddIns(i).ClassRef.ClassName;
        lMenuItem.Tag := rmgtAddIn + i;
        lMenuItem.OnClick := OnAddInObectMenuItemClick;
        lMenuItem.ImageIndex := j;
        FPopupMenuComponent.Items.Add(lMenuItem);
        Inc(j);
      end;
    end;
  finally
    FreeAndNil(lBmp);
  end;

  lPoint := Point(TSpeedButton(Sender).Left + TSpeedButton(Sender).Height,
    TSpeedButton(Sender).Top);
  lPoint := ClientToScreen(lPoint);
  FPopupMenuComponent.Popup(lPoint.X, lPoint.Y);
end;

procedure TRMToolbarComponent.OnBandMenuPopup(Sender: TObject);
var
  i: Integer;
  lItem: TMenuItem;
  t: TRMView;
  lIsSubreport: Boolean;
begin
  FBtnNoSelect.Down := True;
  t := FDesignerForm.IsSubreport(FDesignerForm.CurPage);
  if (t <> nil) and (TRMSubReportView(t).SubReportType = rmstChild) then
    lIsSubreport := True
  else
    lIsSubreport := False;

  for i := 0 to FBandsMenu.Items.Count - 1 do
  begin
    lItem := FBandsMenu.Items[i];
    lItem.Enabled := (TRMBandType(lItem.Tag) in [rmbtHeader, rmbtFooter, rmbtGroupHeader,
      rmbtGroupFooter, rmbtMasterData, rmbtDetailData]) or
      (not FDesignerForm.RMCheckBand(TRMBandType(lItem.Tag)));

    if lIsSubreport and (TRMBandType(lItem.Tag) in
      [rmbtReportTitle, rmbtReportSummary, rmbtPageHeader, rmbtPageFooter,
      {rmbtGroupHeader, rmbtGroupFooter,}rmbtColumnHeader, rmbtColumnFooter]) then
      lItem.Enabled := False;
  end;
end;

procedure TRMToolbarComponent.OnAddBandEvent(Sender: TObject);
var
  t, t1: TRMView;
  lTop, dx, dy: Integer;

  function _GetMaxTop: Integer;
  var
    i: Integer;
    t: TRMView;
  begin
    Result := 0;
    for i := 0 to FDesignerForm.PageObjects.Count - 1 do
    begin
      t := FDesignerForm.PageObjects[i];
      if t.IsBand and (not TRMCustomBandView(t).IsCrossBand) and
        (t.spBottom_Designer > Result) then
        Result := t.spBottom_Designer;
    end;
    if RM_Class.RMShowBandTitles then
      Result := Result + 24;
  end;

begin
  if FDesignerForm.SelNum = 1 then
    t1 := FDesignerForm.PageObjects[FDesignerForm.TopSelected]
  else
    t1 := nil;

  FDesignerForm.UnSelectAll;
  FPageEditor.FWorkSpace.DrawPage(dmSelection);

  t := RMCreateBand(TRMBandType(TComponent(Sender).Tag));
  t.ParentPage := FDesignerForm.Page;
  FDesignerForm.SetObjectID(t);
  if TRMBandType(TComponent(Sender).Tag) in [rmbtCrossHeader..rmbtCrossChild,
    rmbtOverlay] then
  begin
    t.Selected := True;
    dx := 36;
    dy := 36;
    FPageEditor.GetDefaultSize(dx, dy);
    FDesignerForm.SelNum := 1;
    if TRMBandType(TComponent(Sender).Tag) = rmbtOverlay then
    begin
      t.spTop_Designer := _GetMaxTop;
      t.spHeight_Designer := dy;
    end
    else
    begin
      t.spLeft_Designer := 0;
      t.spTop_Designer := 0;
      t.spWidth_Designer := dx;
      t.spHeight_Designer := dy;
    end;
    FPageEditor.SendBandsToDown;
  end
  else
  begin
    lTop := FPageEditor.FWorkSpace.Height;
    if (t1 <> nil) and t1.IsBand and (TRMCustomBandView(t1).BandType in [rmbtMasterData, rmbtDetailData]) then
    begin
      case TRMCustomBandView(t).BandType of
        rmbtGroupHeader, rmbtHeader: lTop := t1.spTop_Designer - 1;
        rmbtGroupFooter, rmbtFooter: lTop := t1.spTop_Designer + t1.spBottom_Designer;
      end;
    end;
    t.spTop_Designer := lTop;
    t.spHeight_Designer := 24;
    FPageEditor.SendBandsToDown;
    FWorkSpace.RedrawPage;
    t.Selected := True;
    FDesignerForm.SelNum := 1;
  end;

  FDesignerForm.Modified := True;
  FPageEditor.SendBandsToDown;
  FPageEditor.FWorkSpace.Draw(FDesignerForm.TopSelected, RM_ClipRgn);
  FDesignerForm.CurPageEditor.Editor_SelectionChanged(True);
  FDesignerForm.ShowPosition;
  FDesignerForm.AddUndoAction(rmacInsert);
end;

procedure TRMToolbarComponent.OnOB1ClickEvent(Sender: TObject);
begin
  FBtnNoSelect.Down := True;
  FWorkSpace.FPageEditor.ObjRepeat := False;
end;

procedure TRMToolbarComponent.RefreshControls;
var
  i: Integer;
  liControl: TControl;
  liNowTop: Integer;
begin
  FBusy := True;
  liNowTop := FBtnUp.Top + FBtnUp.Height;
  for i := 3 to ControlCount - 1 do
  begin
    liControl := Controls[i];
    if i < FControlIndex then
      liControl.Visible := False
    else if liNowTop + ButtonWidth < FBtnDown.Top then
    begin
      liControl.Visible := True;
      liControl.Top := liNowTop;
      Inc(liNowTop, ButtonWidth);
    end
    else
      liControl.Visible := False;
  end;

  FBtnUp.Enabled := FControlIndex > 3;
  FBtnDown.Enabled := not Controls[ControlCount - 1].Visible;
  FBusy := False;
end;

procedure TRMToolbarComponent.OnResizeEvent(Sender: TObject);
begin
  FBtnDown.Top := Self.Height - FBtnDown.Height;
  if not FBusy then
    RefreshControls;
end;

procedure TRMToolbarComponent.OnBtnUpClickEvent(Sender: TObject);
begin
  if FControlIndex > 3 then
  begin
    Dec(FControlIndex);
    if not FBusy then
      RefreshControls;
  end;
end;

procedure TRMToolbarComponent.OnBtnDownClickEvent(Sender: TObject);
begin
  if FControlIndex < ControlCount then
  begin
    Inc(FControlIndex);
    if not FBusy then
      RefreshControls;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDialogForm }

constructor TRMDialogForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  FDesignerForm := TRMDesignerForm(RMDesigner);
end;

procedure TRMDialogForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FDesignerForm.Handle;
end;

procedure TRMDialogForm.WMMove(var Message: TMessage);
begin
  inherited;
  if Assigned(OnResize) then
    OnResize(nil);
end;

procedure TRMDialogForm.SetPageFormProp;
begin
  with TRMDialogPage(FDesignerForm.page) do
  begin
    Self.OnResize := nil;
    Self.SetBounds(Left, Top, Width, Height);
    Self.Caption := Caption;
    Self.Color := Color;
    //  FPageForm.BorderStyle := BorderStyle;
    Self.Font := Font;

    Self.OnResize := Self.OnFormResizeEvent;
    Self.OnCloseQuery := OnFormCloseQueryEvent;
    Self.OnKeyDown := OnFormKeyDownEvent;
  end;
end;

procedure TRMDialogForm.OnFormResizeEvent(Sender: TObject);
begin
  if FDesignerForm.Page is TRMDialogPage then
  begin
    FDesignerForm.Modified := FDesignerForm.Modified or
      (TRMDialogPage(FDesignerForm.Page).Left <> Left) or
      (TRMDialogPage(FDesignerForm.Page).Top <> Top) or
      (TRMDialogPage(FDesignerForm.Page).Width <> Width) or
      (TRMDialogPage(FDesignerForm.Page).Height <> Height);

    TRMDialogPage(FDesignerForm.Page).Left := Left;
    TRMDialogPage(FDesignerForm.Page).Top := Top;
    TRMDialogPage(FDesignerForm.Page).Width := Width;
    TRMDialogPage(FDesignerForm.Page).Height := Height;
    if FDesignerForm.SelNum = 0 then
      FDesignerForm.ShowPosition;
  end;
end;

procedure TRMDialogForm.OnFormCloseQueryEvent(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TRMDialogForm.OnFormKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Chr(Key) = 'C') and (ssCtrl in Shift) then
    Key := vk_Insert;
  if (Chr(Key) = 'X') and (ssCtrl in Shift) then
  begin
    Key := vk_Delete;
    Shift := [ssShift];
  end;
  if (Chr(Key) = 'V') and (ssCtrl in Shift) then
  begin
    Key := vk_Insert;
    Shift := [ssShift];
  end
  else if (Chr(Key) = 'A') and (ssCtrl in Shift) then
  begin
    TRMReportPageEditor(FDesignerForm.CurPageEditor).FWorkSpace.SelectAll;
  end;

  FDesignerForm.CurPageEditor.Editor_KeyDown(Sender, Key, Shift);
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarEdit }

constructor TRMToolbarEdit.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
var
  i, liOffset: Integer;
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMReportPageEditor(AOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  DockRow := 1;
  DockPos := 0;
  Name := 'GridReport_ToolbarEdit';
  CloseButton := False;
  ParentForm := FDesignerForm;

  FcmbFont := TRMFontComboBox.Create(Self);
  with FcmbFont do
  begin
    Parent := Self;
    Height := 21;
    Width := 120;
    //      Device := rmfdBoth;
    TrueTypeOnly := True;
    Tag := TAG_SetFontName;
    OnChange := FPageEditor.FDesignerForm.DoClick;
  end;
  FcmbFontSize := TRMComboBox97 {TComboBox}.Create(Self);
  with FcmbFontSize do
  begin
    Parent := Self;
    Height := 21;
    Width := 50;
    DropDownCount := 12;
    if RMIsChineseGB then
      liOffset := 0
    else
      liOffset := 13;
    for i := Low(RMDefaultFontSizeStr) + liOffset to High(RMDefaultFontSizeStr) do
      Items.Add(RMDefaultFontSizeStr[i]);
    Tag := TAG_SetFontSize;
    OnChange := FPageEditor.FDesignerForm.DoClick;
  end;
  ToolbarSep971 := TRMToolbarSep.Create(Self);
  with ToolbarSep971 do
  begin
    AddTo := Self;
  end;

  btnFontBold := TRMToolbarButton.Create(Self);
  with btnFontBold do
  begin
    Tag := 0;
    AllowAllUp := True;
    GroupIndex := 1;
    ImageIndex := 0;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_FontBold;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFontItalic := TRMToolbarButton.Create(Self);
  with btnFontItalic do
  begin
    Tag := 1;
    AllowAllUp := True;
    GroupIndex := 2;
    ImageIndex := 1;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_FontItalic;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFontUnderline := TRMToolbarButton.Create(Self);
  with btnFontUnderline do
  begin
    Tag := 2;
    AllowAllUp := True;
    GroupIndex := 3;
    ImageIndex := 2;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_FontUnderline;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep972 := TRMToolbarSep.Create(Self);
  with ToolbarSep972 do
  begin
    AddTo := Self;
  end;

  FBtnFontColor := TRMColorPickerButton.Create(Self);
  with FBtnFontColor do
  begin
    Tag := TAG_FontColor;
    Parent := Self;
    ParentShowHint := True;
    ColorType := rmptFont;
    OnColorChange := FPageEditor.FDesignerForm.DoClick;
  end;
  ToolbarSep973 := TRMToolbarSep.Create(Self);
  with ToolbarSep973 do
  begin
    AddTo := Self;
  end;
  FBtnHighlight := TRMToolbarButton.Create(Self);
  with FBtnHighlight do
  begin
    ImageIndex := 3;
    Images := FDesignerForm.ImageListFont;
    OnClick := BtnHighlightClick;
    AddTo := Self;
  end;
  ToolbarSep9730 := TRMToolbarSep.Create(Self);
  with ToolbarSep9730 do
  begin
    AddTo := Self;
  end;

  btnHLeft := TRMToolbarButton.Create(Self);
  with btnHLeft do
  begin
    GroupIndex := 4;
    ImageIndex := 4;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_HAlignLeft;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnHCenter := TRMToolbarButton.Create(Self);
  with btnHCenter do
  begin
    GroupIndex := 4;
    ImageIndex := 5;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_HAlignCenter;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnHRight := TRMToolbarButton.Create(Self);
  with btnHRight do
  begin
    GroupIndex := 4;
    ImageIndex := 6;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_HAlignRight;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnHSpaceEqual := TRMToolbarButton.Create(Self);
  with btnHSpaceEqual do
  begin
    GroupIndex := 4;
    ImageIndex := 7;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_HAlignEuqal;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep974 := TRMToolbarSep.Create(Self);
  with ToolbarSep974 do
  begin
    AddTo := Self;
  end;

  btnVTop := TRMToolbarButton.Create(Self);
  with btnVTop do
  begin
    GroupIndex := 6;
    ImageIndex := 8;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_VAlignTop;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnVCenter := TRMToolbarButton.Create(Self);
  with btnVCenter do
  begin
    GroupIndex := 6;
    ImageIndex := 9;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_VAlignCenter;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnVBottom := TRMToolbarButton.Create(Self);
  with btnVBottom do
  begin
    GroupIndex := 6;
    ImageIndex := 10;
    Images := FPageEditor.FDesignerForm.ImageListFont;
    Tag := TAG_VAlignBottom;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep975 := TRMToolbarSep.Create(Self);
  with ToolbarSep975 do
  begin
    AddTo := Self;
  end;

  Localize;
//  EndUpdate;
end;

procedure TRMToolbarEdit.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 082);
  RMSetStrProp(btnFontBold, 'Hint', rmRes + 115);
  RMSetStrProp(btnFontItalic, 'Hint', rmRes + 116);
  RMSetStrProp(btnFontUnderline, 'Hint', rmRes + 117);
  RMSetStrProp(btnHLeft, 'Hint', rmRes + 107);
  RMSetStrProp(btnHCenter, 'Hint', rmRes + 109);
  RMSetStrProp(btnHRight, 'Hint', rmRes + 108);
  RMSetStrProp(btnHSpaceEqual, 'Hint', rmRes + 114);
  RMSetStrProp(btnVTop, 'Hint', rmRes + 112);
  RMSetStrProp(btnVCenter, 'Hint', rmRes + 111);
  RMSetStrProp(btnVBottom, 'Hint', rmRes + 113);
  RMSetStrProp(FBtnFontColor, 'Hint', rmRes + 208);
  RMSetStrProp(FBtnHighlight, 'Hint', rmRes + 119);
end;

procedure TRMToolbarEdit.BtnHighlightClick(Sender: TObject);
var
  t: TRMView;
  tmp: TRMHilightForm;
begin
  t := FDesignerForm.Objects[FDesignerForm.TopSelected];
  if (t = nil) or (not (t is TRMCustomMemoView)) then Exit;

  tmp := TRMHilightForm.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;

  FDesignerForm.RedrawPage;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarAlign }

constructor TRMToolbarAlign.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMReportPageEditor(AOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  DockRow := 2;
  DockPos := 10; //ToolbarBorder.DockPos + ToolbarBorder.Width;
  Name := 'ToolbarAlign';
  ParentForm := FDesignerForm;

  btnAlignLeft := TRMToolbarButton.Create(Self);
  with btnAlignLeft do
  begin
    ImageIndex := 0;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignLeftClick;
    AddTo := Self;
  end;
  btnAlignHCenter := TRMToolbarButton.Create(Self);
  with btnAlignHCenter do
  begin
    ImageIndex := 1;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignHCenterClick;
    AddTo := Self;
  end;
  btnAlignRight := TRMToolbarButton.Create(Self);
  with btnAlignRight do
  begin
    ImageIndex := 2;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignRightClick;
    AddTo := Self;
  end;
  btnAlignTop := TRMToolbarButton.Create(Self);
  with btnAlignTop do
  begin
    ImageIndex := 3;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignTopClick;
    AddTo := Self;
  end;
  btnAlignVCenter := TRMToolbarButton.Create(Self);
  with btnAlignVCenter do
  begin
    ImageIndex := 4;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignVCenterClick;
    AddTo := Self;
  end;
  btnAlignBottom := TRMToolbarButton.Create(Self);
  with btnAlignBottom do
  begin
    ImageIndex := 5;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignBottomClick;
    AddTo := Self;
  end;
  ToolbarSep9720 := TRMToolbarSep.Create(Self);
  with ToolbarSep9720 do
  begin
    AddTo := Self;
  end;

  btnAlignHSE := TRMToolbarButton.Create(Self);
  with btnAlignHSE do
  begin
    ImageIndex := 6;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignHSEClick;
    AddTo := Self;
  end;
  btnAlignVSE := TRMToolbarButton.Create(Self);
  with btnAlignVSE do
  begin
    ImageIndex := 7;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignVSEClick;
    AddTo := Self;
  end;
  ToolbarSep9721 := TRMToolbarSep.Create(Self);
  with ToolbarSep9721 do
  begin
    AddTo := Self;
  end;

  btnAlignHWCenter := TRMToolbarButton.Create(Self);
  with btnAlignHWCenter do
  begin
    ImageIndex := 8;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignHWCenterClick;
    AddTo := Self;
  end;
  btnAlignVWCenter := TRMToolbarButton.Create(Self);
  with btnAlignVWCenter do
  begin
    ImageIndex := 9;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignVWCenterClick;
    AddTo := Self;
  end;
  ToolbarSep9710 := TRMToolbarSep.Create(Self);
  with ToolbarSep9710 do
  begin
    AddTo := Self;
  end;

  btnAlignLeftRight := TRMToolbarButton.Create(Self);
  with btnAlignLeftRight do
  begin
    ImageIndex := 10;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignLeftRightClick;
    AddTo := Self;
  end;
  btnAlignTopBottom := TRMToolbarButton.Create(Self);
  with btnAlignTopBottom do
  begin
    ImageIndex := 11;
    Images := FDesignerForm.ImageListAlign;
    OnClick := btnAlignTopBottomClick;
    AddTo := Self;
  end;

  Localize;
//  EndUpdate;
end;

procedure TRMToolbarAlign.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 84);
  RMSetStrProp(btnAlignLeft, 'Hint', rmRes + 138);
  RMSetStrProp(btnAlignHCenter, 'Hint', rmRes + 139);
  RMSetStrProp(btnAlignHSE, 'Hint', rmRes + 140);
  RMSetStrProp(btnAlignHWCenter, 'Hint', rmRes + 141);
  RMSetStrProp(btnAlignRight, 'Hint', rmRes + 142);
  RMSetStrProp(btnAlignTop, 'Hint', rmRes + 143);
  RMSetStrProp(btnAlignVSE, 'Hint', rmRes + 144);
  RMSetStrProp(btnAlignVWCenter, 'Hint', rmRes + 145);
  RMSetStrProp(btnAlignVCenter, 'Hint', rmRes + 146);
  RMSetStrProp(btnAlignBottom, 'Hint', rmRes + 147);
  RMSetStrProp(btnAlignLeftRight, 'Hint', rmRes + 199);
  RMSetStrProp(btnAlignTopBottom, 'Hint', rmRes + 215);
end;

function TRMToolbarAlign.GetLeftObject: Integer;
var
  i: Integer;
  t: TRMView;
  x: Integer;
begin
  t := FDesignerForm.Objects[FDesignerForm.TopSelected];
  x := t.spLeft_Designer;
  Result := FDesignerForm.TopSelected;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      if t.spLeft_Designer < x then
      begin
        x := t.spLeft_Designer;
        Result := i;
      end;
    end;
  end;
end;

function TRMToolbarAlign.GetTopObject: Integer;
var
  i: Integer;
  t: TRMView;
  y: Integer;
begin
  Result := FDesignerForm.TopSelected;
  t := FDesignerForm.Objects[Result];
  y := t.spTop_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      if t.spTop_Designer < y then
      begin
        y := t.spTop_Designer;
        Result := i;
      end;
    end;
  end;
end;

function TRMToolbarAlign.GetRightObject: Integer;
var
  i: Integer;
  t: TRMView;
  x: Integer;
begin
  Result := FDesignerForm.TopSelected;
  t := FDesignerForm.Objects[Result];
  x := t.spRight_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      if t.spRight_Designer > x then
      begin
        x := t.spRight_Designer;
        Result := i;
      end;
    end;
  end;
end;

function TRMToolbarAlign.GetBottomObject: Integer;
var
  i: Integer;
  t: TRMView;
  y: Integer;
begin
  t := FDesignerForm.Objects[FDesignerForm.TopSelected];
  y := t.spBottom_Designer;
  Result := FDesignerForm.TopSelected;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      if t.spBottom_Designer > y then
      begin
        y := t.spBottom_Designer;
        Result := i;
      end;
    end;
  end;
end;

procedure TRMToolbarAlign.btnAlignLeftClick(Sender: TObject); //左对齐
var
  i: Integer;
  t: TRMView;
  x: Integer;
  liBand: TRMView;
  s: TList;
  y: Integer;
begin
  FPageEditor.IsBandsSelect(liBand);
  if (liBand <> nil) and (not liBand.IsCrossBand) then
  begin
    FDesignerForm.BeforeChange;
    s := TList.Create;
    try
      t := FDesignerForm.Objects[GetLeftObject];
      x := 0;
      y := t.spTop_Designer;
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t := FDesignerForm.Objects[i];
        if (not t.IsBand) and (t.spTop_Designer >= liBand.spTop_Designer) and (t.spRight_Designer <= liBand.spRight_Designer) then
          s.Add(t);
      end;
      for i := 0 to s.Count - 1 do
      begin
        t := s[i];
        t.spLeft_Designer := x;
        t.spTop_Designer := y;
        x := x + t.spWidth_Designer;
      end;
    finally
      s.Free;
    end;
  end
  else
  begin
    if FDesignerForm.SelNum < 2 then Exit;

    FDesignerForm.BeforeChange;
    t := FPageEditor.GetFirstSelected;
    x := t.spLeft_Designer;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if t.Selected then
        t.spLeft_Designer := x;
    end;
  end;

  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignHCenterClick(Sender: TObject); //水平居中
var
  i: Integer;
  t: TRMView;
  x: Integer;
begin
  FDesignerForm.BeforeChange;
  t := FPageEditor.GetFirstSelected;
  x := t.spLeft_Designer + t.spWidth_Designer div 2;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if (not t.IsBand) and t.Selected then
      t.spLeft_Designer := x - t.spWidth_Designer div 2;
  end;
  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignRightClick(Sender: TObject); //右对齐
var
  i: Integer;
  t: TRMView;
  x: Integer;
  liBand: TRMView;
  s: TList;
  y: Integer;
begin
  FPageEditor.IsBandsSelect(liBand);
  if (liBand <> nil) and (not liBand.IsCrossBand) then
  begin
    FDesignerForm.BeforeChange;
    s := TList.Create;
    try
      t := FDesignerForm.Objects[GetRightObject];
      x := FPageEditor.FWorkSpace.Width;
      y := t.spTop_Designer;
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t := FDesignerForm.Objects[i];
        if (not t.IsBand) and (t.spTop_Designer >= liBand.spTop_Designer) and (t.spBottom_Designer <= liBand.spBottom_Designer) then
          s.Add(t);
      end;
      for i := s.Count - 1 downto 0 do
      begin
        t := s[i];
        t.spLeft_Designer := x - t.spWidth_Designer;
        t.spTop_Designer := y;
        x := x - t.spWidth_Designer;
      end;
    finally
      s.Free;
    end;
  end
  else
  begin
    if FDesignerForm.SelNum < 2 then
      Exit;
    FDesignerForm.BeforeChange;
    t := FPageEditor.GetFirstSelected;
    x := t.spRight_Designer;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if t.Selected then
        t.spLeft_Designer := x - t.spWidth_Designer;
    end;
  end;

  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignTopClick(Sender: TObject); //顶对齐
var
  i: Integer;
  t: TRMView;
  y: Integer;
  lHaveBand: Boolean;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  FDesignerForm.BeforeChange;
  t := FPageEditor.GetFirstSelected;
  y := t.spTop_Designer;
  lHaveBand := False;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      t.spTop_Designer := y;
      lHaveBand := lHaveBand or t.IsBand;
    end;
  end;

  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignVCenterClick(Sender: TObject); //垂直居中
var
  i: Integer;
  t: TRMView;
  y: Integer;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  FDesignerForm.BeforeChange;
  t := FPageEditor.GetFirstSelected;
  y := t.spTop_Designer + t.spHeight_Designer div 2;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if (not t.IsBand) and t.Selected then
      t.spTop_Designer := y - t.spHeight_Designer div 2;
  end;
  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignBottomClick(Sender: TObject); //底对齐
var
  i: Integer;
  t: TRMView;
  y: Integer;
  lHaveBand: Boolean;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  FDesignerForm.BeforeChange;
  t := FPageEditor.GetFirstSelected;
  y := t.spBottom_Designer;
  lHaveBand := False;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      t.spTop_Designer := y - t.spHeight_Designer;
      lHaveBand := lHaveBand or t.IsBand;
    end;
  end;

  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignHSEClick(Sender: TObject); //水平平均分布各列
var
  s: TList;
  i, dx: Integer;
  t: TRMView;
begin
  if FDesignerForm.SelNum < 3 then Exit;
  FDesignerForm.BeforeChange;
  s := TList.Create;
  try
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if (not t.IsBand) and t.Selected then
        s.Add(t);
    end;
    dx := (TRMView(s[s.Count - 1]).spLeft_Designer - TRMView(s[0]).spLeft_Designer) div (s.Count - 1);
    for i := 1 to s.Count - 2 do
    begin
      t := s[i];
      if (not t.IsBand) and t.Selected then
        t.spLeft_Designer := TRMView(s[i - 1]).spLeft_Designer + dx;
    end;
  finally
    s.Free;
    FDesignerForm.AfterChange;
  end;
end;

procedure TRMToolbarAlign.btnAlignVSEClick(Sender: TObject); //垂直平均分布各列
var
  s: TList;
  i, dy: Integer;
  t: TRMView;
begin
  if FDesignerForm.SelNum < 3 then Exit;
  FDesignerForm.BeforeChange;
  s := TList.Create;
  try
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if (not t.IsBand) and t.Selected then
        s.Add(t);
    end;
    dy := (TRMView(s[s.Count - 1]).spTop_Designer - TRMView(s[0]).spTop_Designer) div (s.Count - 1);
    for i := 1 to s.Count - 2 do
    begin
      t := s[i];
      if (not t.IsBand) and t.Selected then
        t.spTop_Designer := TRMView(s[i - 1]).spTop_Designer + dy;
    end;
  finally
    s.Free;
    FDesignerForm.AfterChange;
  end;
end;

procedure TRMToolbarAlign.btnAlignHWCenterClick(Sender: TObject); //窗口水平居中
var
  i: Integer;
  t: TRMView;
  x: Integer;
begin
  if FDesignerForm.SelNum = 0 then Exit;
  FDesignerForm.BeforeChange;
  t := FDesignerForm.Objects[GetLeftObject];
  x := t.spLeft_Designer;
  t := FDesignerForm.Objects[GetRightObject];
  x := x + (t.spRight_Designer - x - FPageEditor.FWorkSpace.Width) div 2;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if (not t.IsBand) and t.Selected then
      t.spLeft_Designer := t.spLeft_Designer - x;
  end;
  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignVWCenterClick(Sender: TObject); //窗口垂直居中
var
  i: Integer;
  t: TRMView;
  y: Integer;
begin
  if FDesignerForm.SelNum = 0 then Exit;
  FDesignerForm.BeforeChange;
  t := FDesignerForm.Objects[GetTopObject];
  y := t.spTop_Designer;
  t := FDesignerForm.Objects[GetBottomObject];
  y := y + (t.spBottom_Designer - y - FPageEditor.FWorkSpace.Height) div 2;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if (not t.IsBand) and t.Selected then
      t.spTop_Designer := t.spTop_Designer - y;
  end;
  FDesignerForm.AfterChange;
end;

procedure TRMToolbarAlign.btnAlignLeftRightClick(Sender: TObject);
var
  i, j: Integer;
  t: TRMView;
  tmpLeft: Integer;
  s: TList;
begin
  if FDesignerForm.SelNum = 0 then Exit;

  FDesignerForm.BeforeChange;
  s := TList.Create;
  try
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if (not t.IsBand) and t.Selected then
        s.Add(t);
    end;
    for i := 0 to s.Count - 1 do
    begin
      for j := i + 1 to s.Count - 1 do
      begin
        if TRMView(s[i]).spLeft_Designer > TRMView(s[j]).spLeft_Designer then
          s.Exchange(i, j);
      end;
    end;

    tmpLeft := TRMView(s[0]).spRight_Designer;
    for i := 1 to s.Count - 1 do
    begin
      t := TRMView(s[i]);
      t.spLeft_Designer := tmpLeft;
      tmpLeft := tmpLeft + t.spWidth_Designer;
    end;
  finally
    s.Free;
    FDesignerForm.AfterChange;
  end;
end;

procedure TRMToolbarAlign.btnAlignTopBottomClick(Sender: TObject);
var
  i, j: Integer;
  t: TRMView;
  tmpTop: Integer;
  s: TList;
begin
  if (FDesignerForm.SelNum = 0) or FPageEditor.IsBandsSelect(t) then Exit;

  FDesignerForm.BeforeChange;
  s := TList.Create;
  try
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if (not t.IsBand) and t.Selected then
        s.Add(t);
    end;
    for i := 0 to s.Count - 1 do
    begin
      for j := i + 1 to s.Count - 1 do
      begin
        if TRMView(s[i]).spTop_Designer > TRMView(s[j]).spTop_Designer then
          s.Exchange(i, j);
      end;
    end;

    tmpTop := TRMView(s[0]).spBottom_Designer;
    for i := 1 to s.Count - 1 do
    begin
      t := TRMView(s[i]);
      t.spTop_Designer := tmpTop;
      tmpTop := tmpTop + t.spHeight_Designer;
    end;
  finally
    s.Free;
    FDesignerForm.AfterChange;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarSize }

constructor TRMToolbarSize.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpDate;
  Dockedto := DockTo;
  FPageEditor := TRMReportPageEditor(AOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  DockRow := 2;
  DockPos := 100;
  Name := 'ToolbarSize';
  ParentForm := FDesignerForm;

  btnSetWidthToMin := TRMToolbarButton.Create(Self);
  with btnSetWidthToMin do
  begin
    ImageIndex := 0;
    Images := FDesignerForm.ImageListSize;
    OnClick := btnSetWidthToMinClick;
    AddTo := Self;
  end;
  btnSetWidthToMax := TRMToolbarButton.Create(Self);
  with btnSetWidthToMax do
  begin
    ImageIndex := 1;
    Images := FDesignerForm.ImageListSize;
    OnClick := btnSetWidthToMaxClick;
    AddTo := Self;
  end;
  ToolbarSep979 := TRMToolbarSep.Create(Self);
  with ToolbarSep979 do
  begin
    AddTo := Self;
  end;

  btnSetHeightToMin := TRMToolbarButton.Create(Self);
  with btnSetHeightToMin do
  begin
    ImageIndex := 2;
    Images := FDesignerForm.ImageListSize;
    OnClick := btnSetHeightToMinClick;
    AddTo := Self;
  end;
  btnSetHeightToMax := TRMToolbarButton.Create(Self);
  with btnSetHeightToMax do
  begin
    ImageIndex := 3;
    Images := FDesignerForm.ImageListSize;
    OnClick := btnSetHeightToMaxClick;
    AddTo := Self;
  end;

  Localize;
//  EndUpdate;
end;

procedure TRMToolbarSize.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 85);
  RMSetStrProp(btnSetWidthToMin, 'Hint', rmRes + 202);
  RMSetStrProp(btnSetWidthToMax, 'Hint', rmRes + 203);
  RMSetStrProp(btnSetHeightToMin, 'Hint', rmRes + 204);
  RMSetStrProp(btnSetHeightToMax, 'Hint', rmRes + 205);
end;

procedure TRMToolbarSize.btnSetWidthToMinClick(Sender: TObject); //宽度最小
var
  i: Integer;
  t: TRMView;
  tmpWidth: Integer;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  t := FPageEditor.GetFirstSelected;
  if t.IsBand then Exit;

  FDesignerForm.BeforeChange;
  tmpWidth := t.spWidth_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and TRMCustomBandView(t).IsCrossBand)) then
    begin
      if t.spWidth_Designer < tmpWidth then
        tmpWidth := t.spWidth_Designer;
    end;
  end;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and TRMCustomBandView(t).IsCrossBand)) then
      t.spWidth_Designer := tmpWidth;
  end;

  FPageEditor.FWorkSpace.GetMultipleSelected;
  FDesignerForm.RedrawPage;
end;

procedure TRMToolbarSize.btnSetWidthToMaxClick(Sender: TObject); //宽度最大
var
  i: Integer;
  t: TRMView;
  tmpWidth: Integer;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  t := FPageEditor.GetFirstSelected;
  if t.IsBand then Exit;

  FDesignerForm.BeforeChange;
  tmpWidth := t.spWidth_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and TRMCustomBandView(t).IsCrossBand)) then
    begin
      if t.spWidth_Designer > tmpWidth then
        tmpWidth := t.spWidth_Designer;
    end;
  end;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and TRMCustomBandView(t).IsCrossBand)) then
      t.spWidth_Designer := tmpWidth;
  end;

  FPageEditor.FWorkSpace.GetMultipleSelected;
  FDesignerForm.RedrawPage;
end;

procedure TRMToolbarSize.btnSetHeightToMinClick(Sender: TObject); //高度最小
var
  i: Integer;
  t: TRMView;
  tmpHeight: Integer;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  t := FPageEditor.GetFirstSelected;
  FDesignerForm.BeforeChange;
  tmpHeight := t.spHeight_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and (not TRMCustomBandView(t).IsCrossBand))) then
    begin
      if t.spHeight_Designer < tmpHeight then
        tmpHeight := t.spHeight_Designer;
    end;
  end;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and (not TRMCustomBandView(t).IsCrossBand))) then
    begin
      t.spHeight_Designer := tmpHeight;
    end;
  end;

  FPageEditor.FWorkSpace.GetMultipleSelected;
  FDesignerForm.RedrawPage;
end;

procedure TRMToolbarSize.btnSetHeightToMaxClick(Sender: TObject); //高度最大
var
  i: Integer;
  t: TRMView;
  tmpHeight: Integer;
begin
  if FDesignerForm.SelNum < 2 then Exit;

  t := FPageEditor.GetFirstSelected;
  FDesignerForm.BeforeChange;
  tmpHeight := t.spHeight_Designer;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and (not TRMCustomBandView(t).IsCrossBand))) then
    begin
      if t.spHeight_Designer > tmpHeight then
        tmpHeight := t.spHeight_Designer;
    end;
  end;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected and ((not t.IsBand) or
      (t.IsBand and (not TRMCustomBandView(t).IsCrossBand))) then
    begin
      t.spHeight_Designer := tmpHeight;
    end;
  end;

  FPageEditor.FWorkSpace.GetMultipleSelected;
  FDesignerForm.RedrawPage;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarBorder }

constructor TRMToolbarBorder.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
var
  i: Integer;
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMReportPageEditor(AOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  DockRow := 2;
  DockPos := 0;
  Name := 'ToolbarBorder';
  ParentForm := FDesignerForm;

  btnFrameLeft := TRMToolbarButton.Create(Self);
  with btnFrameLeft do
  begin
    Tag := TAG_SetFrameLeft;
    AllowAllUp := True;
    GroupIndex := 4;
    ImageIndex := 1;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameRight := TRMToolbarButton.Create(Self);
  with btnFrameRight do
  begin
    Tag := TAG_SetFrameRight;
    AllowAllUp := True;
    GroupIndex := 3;
    ImageIndex := 3;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameTop := TRMToolbarButton.Create(Self);
  with btnFrameTop do
  begin
    Tag := TAG_SetFrameTop;
    AllowAllUp := True;
    GroupIndex := 2;
    ImageIndex := 0;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameBottom := TRMToolbarButton.Create(Self);
  with btnFrameBottom do
  begin
    Tag := TAG_SetFrameBottom;
    AllowAllUp := True;
    GroupIndex := 1;
    ImageIndex := 2;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep9717 := TRMToolbarSep.Create(Self);
  with ToolbarSep9717 do
  begin
    AddTo := Self;
  end;

  btnSetFrame := TRMToolbarButton.Create(Self);
  with btnSetFrame do
  begin
    Tag := TAG_SetFrame;
    ImageIndex := 4;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnNoFrame := TRMToolbarButton.Create(Self);
  with btnNoFrame do
  begin
    Tag := TAG_NoFrame;
    ImageIndex := 5;
    Images := FDesignerForm.ImageListFrame;
    OnClick := FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep9722 := TRMToolbarSep.Create(Self);
  with ToolbarSep9722 do
  begin
    AddTo := Self;
  end;

  FBtnBackColor := TRMColorPickerButton.Create(FDesignerForm);
  with FBtnBackColor do
  begin
    Parent := Self;
    Tag := TAG_BackColor;
    ParentShowHint := True;
    ColorType := rmptFill;
    OnColorChange := FDesignerForm.DoClick;
  end;
  FBtnFrameColor := TRMColorPickerButton.Create(FDesignerForm);
  with FBtnFrameColor do
  begin
    Parent := Self;
    Tag := TAG_FrameColor;
    ParentShowHint := True;
    ColorType := rmptLine; //rmptHighlight;
    OnColorChange := FDesignerForm.DoClick;
  end;
  ToolbarSep9719 := TRMToolbarSep.Create(Self);
  with ToolbarSep9719 do
  begin
    AddTo := Self;
  end;

  btnSetFrameStyle := TRMFrameStyleButton {TRMToolbarButton}.Create(Self);
  with btnSetFrameStyle do
  begin
    Images := FDesignerForm.ImageListFrame;
{$IFDEF USE_TB2K}
    Parent := Self;
    FDesignerForm.ImageListFrame.GetBitmap(6, Glyph);
{$ELSE}
    ImageIndex := 6;
    AddTo := Self;
{$ENDIF}
    OnStyleChange := btnSetFrameStyle_OnChange;
  end;
  FCmbFrameWidth := TRMComboBox97.Create(FDesignerForm);
  with FCmbFrameWidth do
  begin
    Parent := Self;
    Width := 44;
    Tag := TAG_FrameSize;
    DropDownCount := 14;
    Items.Add('0.1');
    Items.Add('0.5');
    Items.Add('1');
    Items.Add('1.5');
    for i := 2 to 10 do
      Items.Add(IntToStr(i));

    OnClick := FDesignerForm.DoClick;
  end;

  FBtnBackColor.CurrentColor := 0;
  FBtnFrameColor.CurrentColor := 0;

  Localize;
//  EndUpdate;
end;

procedure TRMToolbarBorder.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 083);
  RMSetStrProp(FCmbFrameWidth, 'Hint', rmRes + 194);
  RMSetStrProp(btnSetFrameStyle, 'Hint', rmRes + 191);
  RMSetStrProp(btnSetFrame, 'Hint', rmRes + 126);
  RMSetStrProp(FBtnFrameColor, 'Hint', rmRes + 210);
  RMSetStrProp(FBtnBackColor, 'Hint', rmRes + 209);
  RMSetStrProp(btnNoFrame, 'Hint', rmRes + 127);
  RMSetStrProp(btnSetFrame, 'Hint', rmRes + 126);
  RMSetStrProp(btnFrameRight, 'Hint', rmRes + 125);
  RMSetStrProp(btnFrameBottom, 'Hint', rmRes + 124);
  RMSetStrProp(btnFrameLeft, 'Hint', rmRes + 123);
  RMSetStrProp(btnFrameTop, 'Hint', rmRes + 122);
end;

procedure TRMToolbarBorder.SetStatus;
var
  t: TRMView;
begin
  if FDesignerForm.SelNum = 1 then
  begin
    t := FDesignerForm.Objects[FDesignerForm.TopSelected];
    if not t.IsBand then
    begin
      with t do
      begin
        btnFrameTop.Down := TopFrame.Visible;
        btnFrameLeft.Down := LeftFrame.Visible;
        btnFrameBottom.Down := BottomFrame.Visible;
        btnFrameRight.Down := RightFrame.Visible;
        FBtnBackColor.CurrentColor := FillColor;
        FBtnFrameColor.CurrentColor := t.TopFrame.Color;
        FCmbFrameWidth.Text := FloatToStrF(RMFromMMThousandths(t.TopFrame.mmWidth, rmutScreenPixels), ffGeneral, 2, 2);
      end;
    end;
  end
  else if FDesignerForm.SelNum > 1 then
  begin
    btnFrameTop.Down := False;
    btnFrameLeft.Down := False;
    btnFrameBottom.Down := False;
    btnFrameRight.Down := False;
    FBtnBackColor.CurrentColor := 0;
    FCmbFrameWidth.Text := '1';
  end;
end;

procedure TRMToolbarBorder.btnSetFrameStyle_OnChange(Sender: TObject);
begin
  FDesignerForm.DoClick(Sender);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarAddinTools }

constructor TRMToolbarAddinTools.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMReportPageEditor(AOwner);
  FDesignerForm := FPageEditor.FDesignerForm;
  DockRow := 1;
  DockPos := 100;
  Name := 'ToolBarAddinTools';
  ParentForm := FDesignerForm;

  btnDBField := TRMToolbarButton.Create(Self);
  with btnDBField do
  begin
    ImageIndex := 27;
    Images := FDesignerForm.ImageListStand;
    OnClick := btnDBFieldClick;
    AddTo := Self;
    Hint := RMLoadStr(rmRes + 62);
  end;
  btnExpression := TRMToolbarButton.Create(Self);
  with btnExpression do
  begin
    ImageIndex := 21;
    Images := FDesignerForm.ImageListStand;
    OnClick := btnExpressionClick;
    AddTo := Self;
    Hint := RMLoadStr(rmRes + 701);
  end;

  btnInsertFields := TRMToolbarButton.Create(Self);
  with btnInsertFields do
  begin
    AllowAllUp := True;
    Hint := RMLoadStr(rmRes + 110);
    GroupIndex := 1;
    ImageIndex := 0;
    Images := FDesignerForm.ImageListAddinTools;
    OnClick := BtnInsertFieldsClick;
    AddTo := Self;
  end;

  Localize;
//  EndUpdate;
end;

procedure TRMToolbarAddinTools.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 200);
end;

procedure TRMToolbarAddinTools.btnDBFieldClick(Sender: TObject);
var
  i: Integer;
  lStr: string;
  t: TRMView;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.ReadOnly then Exit;

    lStr := FDesignerForm.InsertDBField(nil);
    if lStr <> '' then
    begin
      Delete(lStr, 1, 1);
      Delete(lStr, Length(lStr), 1);
      lStr := 'GetValue(''' + lStr + ''')';
{$IFNDEF USE_SYNEDIT}
      if FDesignerForm.CodeMemo.SelLength = 0 then
        FDesignerForm.CodeMemo.SelStart := FDesignerForm.CodeMemo.PosFromCaret(FDesignerForm.CodeMemo.CaretX, FDesignerForm.CodeMemo.CaretY);
{$ENDIF}

      FDesignerForm.CodeMemo.SelText := lStr;
      FDesignerForm.CodeMemo.SelLength := 0;
    end;
  end
  else
  begin
    i := FDesignerForm.TopSelected;
    t := nil;
    if (i >= 0) and (i < FDesignerForm.Objects.Count) then
      t := FDesignerForm.Objects[i];
    lStr := FDesignerForm.InsertDBField(t);
    if lStr <> '' then
    begin
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t := FDesignerForm.Objects[i];
        if t.Selected and (t is TRMReportView) and (not TRMReportView(t).IsBand) then
        begin
          t.Memo.Text := lStr;
          if t is TRMCustomMemoView then
            TRMCustomMemoView(t).DBFieldOnly := True;
        end;
      end;

      FDesignerForm.AfterChange;
    end;
  end;
end;

procedure TRMToolbarAddinTools.btnExpressionClick(Sender: TObject);
var
  i: Integer;
  lStr: string;
  t: TRMView;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.ReadOnly then Exit;

    if RMGetExpression('', lStr, nil, True) then
    begin
      if lStr <> '' then
      begin
{$IFNDEF USE_SYNEDIT}
        if FDesignerForm.CodeMemo.SelLength = 0 then
          FDesignerForm.CodeMemo.SelStart := FDesignerForm.CodeMemo.PosFromCaret(FDesignerForm.CodeMemo.CaretX, FDesignerForm.CodeMemo.CaretY);
{$ENDIF}

        FDesignerForm.CodeMemo.SelText := lStr;
        FDesignerForm.CodeMemo.SelLength := 0;
      end;
    end;
  end
  else
  begin
    i := FDesignerForm.TopSelected;
    t := nil;
    if (i >= 0) and (i < FDesignerForm.Objects.Count) then
      t := FDesignerForm.Objects[i];

    lStr := FDesignerForm.InsertExpression(t);
    if lStr <> '' then
    begin
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t := FDesignerForm.Objects[i];
        if t.Selected and (t is TRMReportView) and (not TRMReportView(t).IsBand) then
        begin
          t.Memo.Text := lStr;
          if t is TRMCustomMemoView then
            TRMCustomMemoView(t).DBFieldOnly := False;
        end;
      end;

      FDesignerForm.AfterChange;
    end;
  end;
end;

procedure TRMToolbarAddinTools.BtnInsertFieldsClick(Sender: TObject);
begin
  FPageEditor.Pan9.Click;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMReportPageEditor }

constructor TRMReportPageEditor.CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm);

  procedure _CreateComps;
  begin
    Panel2 := TRMPanel.Create(Self);
    with Panel2 do
    begin
      Parent := TWinControl(aOwner);
      Align := alClient;
      BevelOuter := bvLowered;
      Visible := False;
    end;

    pnlHorizontalRuler := TRMPanel.Create(Self);
    with pnlHorizontalRuler do
    begin
      Parent := Panel2;
      Height := 29;
      Align := alTop;
      BevelOuter := bvNone;
      Caption := '';
{$IFDEF COMPILER7_UP}
      ParentBackground := False; //加上此行代码可解决;
{$ENDIF}
    end;

    pnlVerticalRuler := TRMPanel.Create(Self);
    with pnlVerticalRuler do
    begin
      Parent := Panel2;
      Width := 29;
      Align := alLeft;
      BevelOuter := bvNone;
      Caption := '';
{$IFDEF COMPILER7_UP}
      ParentBackground := False; //加上此行代码可解决;
{$ENDIF}
    end;

    FScrollBox := TRMNewScrollBox.Create(Self);
    with FScrollBox do
    begin
      Parent := Panel2;
      HorzScrollBar.Tracking := True;
      VertScrollBar.Tracking := True;
      Align := alClient;
      BorderStyle := bsNone;
      Color := clGray;
      ParentColor := False;
      TabOrder := 2;
    end;

    pnlWorkSpace := TRMPanel.Create(Self);
    with pnlWorkSpace do
    begin
      Parent := FScrollBox;
      Caption := '';
      BevelOuter := bvNone;
      Color := clHighlightText;
{$IFDEF COMPILER7_UP}
      ParentBackground := False; //加上此行代码可解决;
{$ENDIF}
      TabOrder := 1;
    end;

    FHRuler := TRMDesignerRuler.Create(pnlHorizontalRuler);
    FHRuler.Parent := pnlHorizontalRuler;
    FHRuler.Units := RMUnits;
    FHRuler.Orientation := roHorizontal;
    FHRuler.SetBounds(pnlVerticalRuler.Width, 0, pnlHorizontalRuler.Width, pnlHorizontalRuler.Height);

    FVRuler := TRMDesignerRuler.Create(pnlVerticalRuler);
    FVRuler.Parent := pnlVerticalRuler;
    FVRuler.Units := RMUnits;
    FVRuler.Orientation := roVertical;
    FVRuler.SetBounds(0, 0, pnlVerticalRuler.Width, pnlVerticalRuler.Height);

    FToolbarEdit := TRMToolbarEdit.CreateAndDock(Self, FDesignerForm.Dock971);
    FToolbarAddinTools := TRMToolbarAddinTools.CreateAndDock(Self, FDesignerForm.Dock971);
    FToolbarBorder := TRMToolbarBorder.CreateAndDock(Self, FDesignerForm.Dock971);
    FToolbarAlign := TRMToolbarAlign.CreateAndDock(Self, FDesignerForm.Dock971);
    FToolbarSize := TRMToolbarSize.CreateAndDock(Self, FDesignerForm.Dock971);

    Panel7 := TPanel.Create(Self);
    with Panel7 do
    begin
      Visible := False;
      Caption := '';
      Parent := aDesignerForm;
      SetBounds(78, FDesignerForm.StatusBar1.Top + 3, 256, 15);
      BevelOuter := bvNone;
    end;
    PBox1 := TPaintBox.Create(Self);
    with PBox1 do
    begin
      Parent := Panel7;
      Align := alClient;
      OnPaint := PBox1Paint;
    end;
  end;

  // 主菜单
  procedure _CreateMainMenu;
  begin
{$IFDEF USE_TB2K}
    FMainMenu := FDesignerForm.MainMenu;
{$ELSE}
    FMainMenu := TRMMenuBar.Create(Self);
    with FMainMenu do
    begin
      Name := 'MenuBar';
      AutoHotkeys := maManual;
    end;
{$ENDIF}

    barEdit := TRMSubmenuItem.Create(Self);
    with barEdit do
    begin
{$IFDEF USE_TB2K}
      FDesignerForm.MainMenu.Items.Insert(1, barEdit);
{$ELSE}
      AddToMenu(FMainMenu);
{$ENDIF}
      GroupIndex := 2;
      Caption := '&Edit';
      OnClick := barFileClick;
    end;
    padUndo := TRMmenuItem.Create(Self);
    with padUndo do
    begin
      ImageIndex := 8;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Undo';
      ShortCut := Menus.ShortCut(Ord('Z'), [ssCtrl]);
      OnClick := Editor_BtnUndoClick;
      AddToMenu(barEdit);
    end;
    padRedo := TRMmenuItem.Create(Self);
    with padRedo do
    begin
      ImageIndex := 9;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Redo';
      ShortCut := Menus.ShortCut(Ord('Z'), [ssShift, ssCtrl]);
      OnClick := Editor_BtnRedoClick;
      AddToMenu(barEdit);
    end;
    N47 := TRMSeparatorMenuItem.Create(Self);
    N47.AddToMenu(barEdit);
    padCut := TRMmenuItem.Create(Self);
    with padCut do
    begin
      ImageIndex := 5;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Cut';
      ShortCut := 16472;
      OnClick := Editor_BtnCutClick;
      AddToMenu(barEdit);
    end;
    padCopy := TRMmenuItem.Create(Self);
    with padCopy do
    begin
      ImageIndex := 6;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Copy';
      ShortCut := 16451;
      OnClick := Editor_BtnCopyClick;
      AddToMenu(barEdit);
    end;
    padPaste := TRMmenuItem.Create(Self);
    with padPaste do
    begin
      ImageIndex := 7;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Paste';
      ShortCut := 16470;
      OnClick := Editor_BtnPasteClick;
      AddToMenu(barEdit);
    end;
    padDelete := TRMmenuItem.Create(Self);
    with padDelete do
    begin
      ImageIndex := 22;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Delete';
      ShortCut := 16430;
      OnClick := padDeleteClick;
      AddToMenu(barEdit);
    end;
    padSelectAll := TRMmenuItem.Create(Self);
    with padSelectAll do
    begin
      ImageIndex := 12;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Select all';
      ShortCut := 16449;
      OnClick := btnSelectAllClick;
      AddToMenu(barEdit);
    end;
    padEdit := TRMmenuItem.Create(Self);
    with padEdit do
    begin
      ImageIndex := 23;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Edit...';
      OnClick := padEditClick;
      AddToMenu(barEdit);
    end;
    N3 := TRMSeparatorMenuItem.Create(Self);
    N3.AddToMenu(barEdit);
    padEditReplace := TRMmenuItem.Create(Self);
    with padEditReplace do
    begin
      ImageIndex := 24;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Find && Replace...';
      OnClick := padEditReplaceClick;
      AddToMenu(barEdit);
    end;
    N26 := TRMSeparatorMenuItem.Create(Self);
    N26.AddToMenu(barEdit);
    padBringtoFront := TRMmenuItem.Create(Self);
    with padBringtoFront do
    begin
      ImageIndex := 10;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Bring to Front';
      OnClick := btnBringtoFrontClick;
      AddToMenu(barEdit);
    end;
    padSendtoBack := TRMmenuItem.Create(Self);
    with padSendtoBack do
    begin
      ImageIndex := 11;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Send to back';
      OnClick := btnSendtoBackClick;
      AddToMenu(barEdit);
    end;
    N4 := TRMSeparatorMenuItem.Create(Self);
    N4.AddToMenu(barEdit);
    itmEditLockControls := TRMmenuItem.Create(Self);
    with itmEditLockControls do
    begin
      ImageIndex := 25;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Lock Controls';
      OnClick := itmEditLockControlsClick;
      AddToMenu(barEdit);
    end;

    barTools := TRMSubmenuItem.Create(Self);
    with barTools do
    begin
{$IFDEF USE_TB2K}
      FDesignerForm.MainMenu.Items.Insert(3, barTools);
{$ELSE}
      AddToMenu(FMainMenu);
{$ENDIF}
      GroupIndex := 21;
      Caption := '&Tools';
    end;
    padSetToolbar := TRMSubmenuItem.Create(Self);
    with padSetToolbar do
    begin
      Caption := 'Tools bar';
      OnClick := padSetToolbarClick;
      AddToMenu(barTools);
    end;
    Pan2 := TRMmenuItem.Create(Self);
    with Pan2 do
    begin
      Tag := 1;
      Caption := 'Standard';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan3 := TRMmenuItem.Create(Self);
    with Pan3 do
    begin
      Tag := 2;
      Caption := 'Text';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan1 := TRMmenuItem.Create(Self);
    with Pan1 do
    begin
      Caption := 'Border';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan4 := TRMmenuItem.Create(Self);
    with Pan4 do
    begin
      Tag := 3;
      Caption := 'Objects';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan6 := TRMmenuItem.Create(Self);
    with Pan6 do
    begin
      Tag := 4;
      Caption := 'Alignment palette';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan8 := TRMmenuItem.Create(Self);
    with Pan8 do
    begin
      Tag := 7;
      Caption := 'Size palette';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan7 := TRMmenuItem.Create(Self);
    with Pan7 do
    begin
      Tag := 6;
      Caption := 'Extra tools';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    Pan5 := TRMmenuItem.Create(Self);
    with Pan5 do
    begin
      Tag := 5;
      Caption := 'Object Inspector';
      ShortCut := 122;
      OnClick := Pan5Click;
      AddToMenu(padSetToolbar);
    end;
    Pan9 := TRMmenuItem.Create(Self);
    with Pan9 do
    begin
      Tag := 8;
      Caption := 'Insert DB fields';
      OnClick := Pan2Click;
      AddToMenu(padSetToolbar);
    end;
    padAddTools := TRMmenuItem.Create(Self);
    with padAddTools do
    begin
      Caption := 'Extra tools';
      Enabled := False;
      AddToMenu(barTools);
    end;
    padOptions := TRMmenuItem.Create(Self);
    with padOptions do
    begin
      Caption := 'Options...';
      OnClick := padOptionsClick;
      AddToMenu(barTools);
    end;
    FDesignerForm.AddLanguageMenu(barTools);
  end;

  // 右键菜单
  procedure _CreatePopupMenu;
  begin
    FPopupMenu := TRMPopupMenu.Create(Self);
    with FPopupMenu do
    begin
      AutoHotkeys := maManual;
      OnPopup := Popup1Popup;
    end;

    padpopCut := TRMMenuItem.Create(Self);
    with padpopCut do
    begin
      AddToMenu(FPopupMenu);
      ImageIndex := 5;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Cut';
      ShortCut := 16472;
      OnClick := Editor_BtnCutClick;
    end;

    padpopCopy := TRMMenuItem.Create(Self);
    with padpopCopy do
    begin
      AddToMenu(FPopupMenu);
      ImageIndex := 6;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Copy';
      ShortCut := 16451;
      OnClick := Editor_BtnCopyClick;
    end;

    padpopPaste := TRMMenuItem.Create(Self);
    with padpopPaste do
    begin
      AddToMenu(FPopupMenu);
      ImageIndex := 7;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Paste';
      ShortCut := 16470;
      OnClick := Editor_BtnPasteClick;
    end;

    padpopDelete := TRMMenuItem.Create(Self);
    with padpopDelete do
    begin
      AddToMenu(FPopupMenu);
      ImageIndex := 22;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Delete';
      ShortCut := 16430;
      OnClick := padDeleteClick;
    end;

    N8 := TRMSeparatorMenuItem.Create(Self);
    N8.AddToMenu(FPopupMenu);

    padpopFrame := TRMMenuItem.Create(Self);
    with padpopFrame do
    begin
      AddToMenu(FPopupMenu);
      Caption := 'Frame...';
      OnClick := padpopFrameClick;
    end;

    padpopEdit := TRMMenuItem.Create(Self);
    with padpopEdit do
    begin
      AddToMenu(FPopupMenu);
      Caption := 'Edit...';
      OnClick := padpopEditClick;
    end;

    padpopClearContents := TRMMenuItem.Create(Self);
    with padpopClearContents do
    begin
      Caption := 'Clear Contents';
      OnClick := padpopClearContentsClick;
      AddToMenu(FPopupMenu);
    end;
  end;

begin
  inherited CreateComp(aOwner, aDesignerForm);

  FWorkSpace := nil;
  FFindReplaceForm := nil;
  FDesignerForm := aDesignerForm;
  _CreateComps;
  _CreateMainMenu;
  _CreatePopupMenu;

  FWorkSpace := TRMWorkSpace.Create(pnlWorkSpace);
  FWorkSpace.DesignerForm := aDesignerForm;
  FWorkSpace.FPageEditor := Self;
//  FWorkSpace.PopupMenu := Popup1;
  FWorkSpace.ShowHint := True;

  FToolbarComponent := TRMToolbarComponent.CreateComp(Self);

  FGridBitmap := TBitmap.Create;
  with FGridBitmap do
  begin
    Width := 8;
    Height := 8;
  end;

  FShapeMode := smFrame;
  Localize;
  LoadIni;

  FScrollBox.OnResize := OnScrollBox1ResizeEvent;
{$IFNDEF USE_TB2k}
  FDesignerForm.MainMenu.Merge(FMainMenu);
{$ENDIF}
end;

destructor TRMReportPageEditor.Destroy;
begin
  SaveIni;
  FreeAndNil(FGridBitmap);
  FreeAndNil(FFindReplaceForm);
  if FWorkSpace <> nil then
  begin
    FWorkSpace.Parent := nil;
    FreeAndNil(FWorkSpace);
  end;

  inherited Destroy;
end;

procedure TRMReportPageEditor.Localize;
begin
  RMSetStrProp(padpopCut, 'Caption', rmRes + 148);
  RMSetStrProp(padpopCopy, 'Caption', rmRes + 149);
  RMSetStrProp(padpopPaste, 'Caption', rmRes + 150);
  RMSetStrProp(padpopDelete, 'Caption', rmRes + 151);
  RMSetStrProp(padpopEdit, 'Caption', rmRes + 153);
  RMSetStrProp(padpopFrame, 'Caption', rmRes + 214);
  RMSetStrProp(padpopClearContents, 'Caption', rmRes + 881);

  RMSetStrProp(barEdit, 'Caption', rmRes + 163);
  RMSetStrProp(padUndo, 'Caption', rmRes + 164);
  RMSetStrProp(padRedo, 'Caption', rmRes + 165);
  RMSetStrProp(padCut, 'Caption', rmRes + 166);
  RMSetStrProp(padCopy, 'Caption', rmRes + 167);
  RMSetStrProp(padPaste, 'Caption', rmRes + 168);
  RMSetStrProp(padDelete, 'Caption', rmRes + 169);
  RMSetStrProp(padSelectAll, 'Caption', rmRes + 170);
  RMSetStrProp(padEdit, 'Caption', rmRes + 171);
  RMSetStrProp(padBringtoFront, 'Caption', rmRes + 174);
  RMSetStrProp(padSendtoBack, 'Caption', rmRes + 175);
  RMsetStrProp(padEditReplace, 'Caption', rmRes + 217);
  RMSetStrProp(barTools, 'Caption', rmRes + 176);
  RMSetStrProp(padSetToolbar, 'Caption', rmRes + 177);
  RMSetStrProp(padAddTools, 'Caption', rmRes + 178);
  RMSetStrProp(padOptions, 'Caption', rmRes + 179);
  RMSetStrProp(itmEditLockControls, 'Caption', rmRes + 226);

  RMSetStrProp(Pan1, 'Caption', rmRes + 180);
  RMSetStrProp(Pan2, 'Caption', rmRes + 181);
  RMSetStrProp(Pan3, 'Caption', rmRes + 182);
  RMSetStrProp(Pan4, 'Caption', rmRes + 183);
  RMSetStrProp(Pan5, 'Caption', rmRes + 184);
  RMSetStrProp(Pan6, 'Caption', rmRes + 185);
  RMSetStrProp(Pan7, 'Caption', rmRes + 186);
  RMSetStrProp(Pan8, 'Caption', rmRes + 206);
  RMSetStrProp(Pan9, 'Caption', rmRes + 110);
end;

const
  rsSelection = 'Selection';

procedure TRMReportPageEditor.SaveIni;
var
  Ini: TRegIniFile;
  Nm: string;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + '\RMReport');
  try
    Nm := rsForm + Name;
    Ini.WriteInteger(Nm, rsSelection, Integer(FShapeMode));
    Ini.WriteBool(Nm, ToolbarComponent.ClassName + '_Visible', ToolbarComponent.Visible);
  finally
    Ini.Free;
  end;

  RMSaveToolbars('\RMReport', [FToolbarEdit, FToolBarAddinTools, FToolbarBorder, FToolbarAlign, FToolbarSize]);
  if THackDesigner(FDesignerForm).IsPreviewDesign then
  begin
    RMSaveToolbars('\RMReport', [FDesignerForm.ToolbarModifyPrepared]);
  end;
end;

procedure TRMReportPageEditor.LoadIni;
var
  Ini: TRegIniFile;
  Nm: string;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + '\RMReport');
  try
    Nm := rsForm + Name;
    FHRuler.Units := RMUnits;
    FVRuler.Units := RMUnits;
    FShapeMode := TRMShapeMode(Ini.ReadInteger(Nm, rsSelection, 0));
    ToolbarComponent.Visible := Ini.ReadBool(Nm, ToolbarComponent.ClassName + '_Visible', True);
  finally
    Ini.Free;
  end;

  RMRestoreToolbars('\RMReport', [FToolbarEdit, FToolBarAddinTools, FToolbarBorder, FToolbarAlign, FToolbarSize]);
  if THackDesigner(FDesignerForm).IsPreviewDesign and THackDesigner(FDesignerForm).ShowModifyToolbar then
  begin
    RMRestoreToolbars('\RMReport', [FDesignerForm.ToolbarModifyPrepared]);
    FDesignerForm.ToolbarModifyPrepared.Visible := True;
  end;
end;

procedure TRMReportPageEditor.Editor_Tab1Changed;
begin
  if FWorkSpace.PageForm <> nil then
    FWorkSpace.PageForm.Visible := False;
end;

procedure TRMReportPageEditor.Editor_OnFormMouseWheelUp(aUp: Boolean);
begin
  if aUp then
    FScrollBox.VertScrollBar.Position := FScrollBox.VertScrollBar.Position - 8 * 2
  else
    FScrollBox.VertScrollBar.Position := FScrollBox.VertScrollBar.Position + 8 * 2;
end;

procedure TRMReportPageEditor.Editor_InitToolbarComponent;
begin
  ToolbarComponent.btnNoSelect.Click;
end;

procedure TRMReportPageEditor.Editor_DisableDraw;
begin
  FWorkSpace.DisableDraw := True;
  FWorkSpace.CurrentView := nil;
  ToolbarComponent.btnNoSelect.Click;
  if FWorkSpace.FFieldListBox.Visible then
    FWorkSpace.FFieldListBox.Hide;
end;

procedure TRMReportPageEditor.Editor_EnableDraw;
begin
  FWorkSpace.DisableDraw := False;
end;

procedure TRMReportPageEditor.Editor_RedrawPage;
begin
  FWorkSpace.Draw(10000, 0);
end;

procedure TRMReportPageEditor.Editor_Resize;
begin
  with FScrollBox do
  begin
    HorzScrollBar.Position := 0;
    VertScrollBar.Position := 0;
  end;

  FWorkSpace.SetPage;

  Panel7.Top := FDesignerForm.StatusBar1.Top;
//  Panel7.Top := FDesignerForm.StatusBar1.Top + 3;
  Panel7.Show;
end;

procedure TRMReportPageEditor.Editor_Init;
begin
  FDesignerForm.Busy := False;
  FDesignerForm.InspBusy := False;
  FWorkSpace.Init;
  FHRuler.Units := RMUnits;
  FVRuler.Units := RMUnits;

  FToolbarComponent.btnNoSelect.Click;
  Panel7.Top := FDesignerForm.StatusBar1.Top + 3;
  Panel7.Show;
end;

procedure TRMReportPageEditor.Editor_SetCurPage;
var
  lSaveModified: Boolean;
  lWidth, lHeight: Integer;
begin
  FWorkSpace.CurrentView := nil;
  FToolbarComponent.CreateObjects;
  if (FDesignerForm.Page is TRMDialogPage) and (FWorkSpace.PageForm = nil) then
  begin
    FWorkSpace.PageForm := TRMDialogForm.CreateNew(nil, 0);
    FWorkSpace.Parent := FWorkSpace.PageForm;
    FWorkSpace.PageForm.SetPageFormProp;

    FWorkSpace.Color := clBtnFace;
    FWorkSpace.PageForm.Icon := FDesignerForm.Icon;
    FOldFactor := FDesignerForm.Factor;
    FDesignerForm.Factor := 100;
  end
  else if (FDesignerForm.Page is TRMReportPage) and (FWorkSpace.PageForm <> nil) then
  begin
    if FOldFactor > 0 then
      FDesignerForm.Factor := FOldFactor;

    FOldFactor := FDesignerForm.Factor;
    FWorkSpace.Parent := pnlWorkSpace;
    FWorkSpace.Color := clWhite;

    FreeAndNil(FWorkSpace.PageForm);
  end;

  pnlHorizontalRuler.Visible := (FDesignerForm.Page is TRMReportPage);
  pnlVerticalRuler.Visible := pnlHorizontalRuler.Visible;
  if (FDesignerForm.Page is TRMDialogPage) and (FWorkSpace.PageForm <> nil) then
  begin
    lSaveModified := FDesignerForm.Modified;
    FWorkSpace.PageForm.SetPageFormProp;
    FWorkSpace.PageForm.Show;
    FDesignerForm.Modified := lSaveModified;
  end;

  FScrollBox.VertScrollBar.Position := 0;
  FScrollBox.HorzScrollBar.Position := 0;
  if FDesignerForm.Page is TRMDialogPage then
  begin
    pnlWorkSpace.SetBounds(0, 0, 0, 0);
  end
  else
  begin
    lWidth := Round(TRMReportPage(FDesignerForm.Page).PrinterInfo.ScreenPageWidth * FDesignerForm.Factor / 100);
    lHeight := Round(TRMReportPage(FDesignerForm.Page).PrinterInfo.ScreenPageHeight * FDesignerForm.Factor / 100);
    if FDesignerForm.UnlimitedHeight then
      lHeight := lHeight * 3;

    pnlWorkSpace.Color := FDesignerForm.WorkSpaceColor;
    pnlWorkSpace.SetBounds(0, 0, lWidth, lHeight);
    FScrollBox.VertScrollBar.Range := pnlWorkSpace.Height + 10;
    FScrollBox.HorzScrollBar.Range := pnlWorkSpace.Width + 10;
    FHRuler.Width := lWidth + Screen.PixelsPerInch + 20;
    FVRuler.Height := lHeight + Screen.PixelsPerInch + 20;
    FHRuler.ScrollOffset := 0;
    FVRuler.ScrollOffset := 0;
  end;

  FWorkSpace.SetPage;
  FDesignerForm.ResetSelection;
  SendBandsToDown;
  FWorkSpace.Repaint;

  Panel2.Visible := True;
  if FDesignerForm.Page is TRMReportPage then
    FScrollBox.SetFocus;
end;

procedure TRMReportPageEditor.Editor_SelectionChanged(aRefreshInspProp: Boolean);
var
  t: TRMView;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  try
    FDesignerForm.EnableControls;
    FToolbarBorder.SetStatus;
    t := nil;
    if FDesignerForm.SelNum = 1 then
    begin
      t := FDesignerForm.Objects[FDesignerForm.TopSelected];
    end
    else if FDesignerForm.SelNum > 1 then
    begin
      t := FDesignerForm.Objects[FDesignerForm.TopSelected];
      FToolbarEdit.FCmbFont.ItemIndex := -1;
      FToolbarEdit.FCmbFontSize.Text := '';
      FToolbarEdit.btnFontBold.Down := False;
      FToolbarEdit.btnFontItalic.Down := False;
      FToolbarEdit.btnFontUnderline.Down := False;
      FToolbarEdit.btnHLeft.Down := False;
      FToolbarEdit.btnVCenter.Down := False;
    end;

    if (t <> nil) and not t.IsBand then
    begin
      if t is TRMCustomMemoView then
      begin
        with t as TRMCustomMemoView do
        begin
          FToolbarEdit.FBtnFontColor.CurrentColor := Font.Color;
          if FToolbarEdit.FCmbFont.ItemIndex <> FToolbarEdit.FCmbFont.Items.IndexOf(Font.Name) then
            FToolbarEdit.FCmbFont.ItemIndex := FToolbarEdit.FCmbFont.Items.IndexOf(Font.Name);

          RMSetFontSize(TComboBox(FToolbarEdit.FCmbFontSize), Font.Height, Font.Size);
          FToolbarEdit.btnFontBold.Down := fsBold in Font.Style;
          FToolbarEdit.btnFontItalic.Down := fsItalic in Font.Style;
          FToolbarEdit.btnFontUnderline.Down := fsUnderline in Font.Style;
          case VAlign of
            rmVTop: FToolbarEdit.btnVTop.Down := True;
            rmVBottom: FToolbarEdit.btnVBottom.Down := True;
          else
            FToolbarEdit.btnVCenter.Down := True;
          end;
          case HAlign of
            rmhLeft: FToolbarEdit.btnHLeft.Down := True;
            rmhCenter: FToolbarEdit.btnHCenter.Down := True;
            rmhRight: FToolbarEdit.btnHRight.Down := True;
          else
            FToolbarEdit.btnHSpaceEqual.Down := True;
          end;
        end;
      end;
    end;

    if aRefreshInspProp then Editor_ShowPosition;
    Editor_ShowContent;
  finally
    FDesignerForm.Busy := False;
  end;
end;

procedure TRMReportPageEditor.Editor_FillInspFields;
var
  i, lCount: Integer;
  t, t1: TRMView;
  lObjects: array of TPersistent;
begin
  if not FDesignerForm.InspForm.Visible then Exit;
  if FDesignerForm.InspBusy then Exit;

  FDesignerForm.InspBusy := True;
  if FDesignerForm.SelNum > 0 then
    t := FDesignerForm.Objects[FDesignerForm.TopSelected]
  else
    t := nil;

  if (FDesignerForm.SelNum = 1) and (FDesignerForm.InspForm.Insp.ObjectCount = 1) and
    (FDesignerForm.InspForm.Insp.IndexOf(t) >= 0) then
  begin
    FDesignerForm.InspForm.Insp.UpdateItems;
    FDesignerForm.InspBusy := False;
    Exit;
  end;

  FDesignerForm.InspForm.BeginUpdate;
  FDesignerForm.InspForm.ClearObjects;
  FDesignerForm.InspForm.Insp.ReadOnly := False;
  if FDesignerForm.SelNum > 0 then
  begin
    lCount := 1;
    SetLength(lObjects, 1);
    lObjects[0] := t;
    if FDesignerForm.SelNum > 1 then
    begin
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t1 := FDesignerForm.Objects[i];
        if TRMView(t1).Selected and (t1 <> t) then
        begin
          Inc(lCount);
          SetLength(lObjects, lCount);
          lObjects[lCount - 1] := t1;
          if (FDesignerForm.DesignerRestrictions * [rmdrDontModifyObj] <> []) or (t1.Restrictions * [rmrtDontModify] <> []) then
            FDesignerForm.InspForm.Insp.ReadOnly := True;
        end;
      end;
    end;

    FDesignerForm.InspForm.AddObjects(lObjects);
    FDesignerForm.InspForm.SetCurrentObject(t.ClassName, t.Name);
  end
  else
  begin
    FDesignerForm.InspForm.AddObject(FDesignerForm.Page);
    FDesignerForm.InspForm.SetCurrentObject(FDesignerForm.Page.ClassName, FDesignerForm.Page.Name);
  end;

  FDesignerForm.InspForm.EndUpdate;
  FDesignerForm.InspBusy := False;
end;

procedure TRMReportPageEditor.Editor_ShowPosition;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    PBox1Paint(nil);
  end
  else
  begin
    if not FDesignerForm.InspBusy then
      Editor_FillInspFields;

    FDesignerForm.StatusBar1.Repaint;
    PBox1Paint(nil);
  end;
end;

procedure TRMReportPageEditor.Editor_ShowContent;
var
  t: TRMView;
  s: string;
begin
  s := '';
  if FDesignerForm.SelNum = 1 then
  begin
    t := FDesignerForm.Objects[FDesignerForm.TopSelected];
    s := t.Name;
    if t.IsBand then
      s := s + ': ' + RMBandNames[TRMCustomBandView(t).BandType]
    else if t.Memo.Count > 0 then
      s := s + ': ' + t.Memo[0];
  end;

  FDesignerForm.StatusBar1.Panels[2].Text := s;
end;

function TRMReportPageEditor.Editor_PageObjects: TList;
begin
  Result := FDesignerForm.Page.Objects;
end;

procedure TRMReportPageEditor.Editor_OnInspGetObjects(aList: TStrings);
var
  i: Integer;

  procedure _AddItem(aObj: TObject);
  var
    lStr: string;
  begin
  //dejoy modify
    lStr := '%-12s %-s'; //添加形如 'Memo1 TRMMemoView'字串

    if aObj is TRMPersistent then
      aList.Add(Format(lStr, [TRMPersistent(aObj).Name, TObject(aObj).ClassName]))
    else if aObj is TComponent then
      aList.Add(Format(lStr, [TComponent(aObj).Name, TObject(aObj).ClassName]));
  end;

begin
  aList.Clear;

  with FDesignerForm do
  begin
  //  List.Add(Format(s,[.Report.Name,Report.ClassName]));
    for i := 0 to Objects.Count - 1 do
      _AddItem(Objects[i]);

    for i := 0 to Report.Pages.Count - 1 do
      _AddItem(Report.Pages[i]);
  end;
end;

procedure TRMReportPageEditor.OnScrollBox1ResizeEvent(Sender: TObject);
begin
  FWorkSpace.SetPage;
end;

function TRMReportPageEditor.IsBandsSelect(var Band: TRMView): Boolean;
var
  i: Integer;
  t: TRMView;
begin
  Result := False;
  Band := nil;
  with THackPage(FDesignerForm.Page) do
  begin
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if t.Selected and t.IsBand then
      begin
        Band := t;
        Result := True;
        Break;
      end;
    end;
  end;
end;

procedure TRMReportPageEditor.GetRegion;
var
  i: Integer;
  t: TRMView;
  R: HRGN;
begin
  RM_ClipRgn := CreateRectRgn(0, 0, 0, 0);
  for i := 0 to THackPage(FDesignerForm.Page).Objects.Count - 1 do
  begin
    t := THackPage(FDesignerForm.Page).Objects[i];
    if t.Selected then
    begin
      R := t.GetClipRgn(rmrtExtended);
      CombineRgn(RM_ClipRgn, RM_ClipRgn, R, RGN_OR);
      DeleteObject(R);
    end;
  end;
  RM_FirstChange := False;
end;

function TRMReportPageEditor.GetFirstSelected: TRMView;
begin
  if FDesignerForm.FirstSelected <> nil then
    Result := FDesignerForm.FirstSelected
  else
    Result := FDesignerForm.Objects[FDesignerForm.TopSelected];
end;

procedure _SetBit(var w: Word; e: Boolean; m: Integer);
begin
  if e then
    w := w or m
  else
    w := w and not m;
end;

procedure TRMReportPageEditor.Editor_DoClick(Sender: TObject);
var
  i, b: Integer;
  t: TRMView;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacEdit);
  FWorkSpace.DrawPage(dmSelection);
  GetRegion;
  b := TControl(Sender).Tag;
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if (not t.Selected) or t.IsBand then Continue;

    with t do
    begin
      if t is TRMCustomMemoView then
      begin
        with TRMCustomMemoView(t) do
        begin
          case b of
            TAG_SetFontName:
              begin
                if FToolbarEdit.FCmbFont.ItemIndex >= 0 then
                begin
                  StyleName := '';
                  RM_LastFontName := FToolbarEdit.FCmbFont.Text;
                  if RMIsChineseGB then
                  begin
                    if ByteType(RM_LastFontName, 1) = mbSingleByte then
                      RM_LastFontCharset := ANSI_CHARSET
                    else
                      RM_LastFontCharset := GB2312_CHARSET;
                  end;
                  Font.Name := RM_LastFontName;
                  Font.Charset := RM_LastFontCharset;
                end;
              end;
            TAG_SetFontSize:
              begin
                if FToolbarEdit.FCmbFontSize.ItemIndex >= 0 then
                begin
                  StyleName := '';
                  RM_LastFontSize := RMGetFontSize(TComboBox(FToolbarEdit.FCmbFontSize));
                  if RM_LastFontSize >= 0 then
                    Font.Size := RM_LastFontSize
                  else
                    Font.Height := RM_LastFontSize;
                end;
              end;
            TAG_FontBold:
              begin
                StyleName := '';
                RM_LastFontStyle := RMGetFontStyle(Font.Style);
                _SetBit(RM_LastFontStyle, FToolbarEdit.btnFontBold.Down, 2);
                Font.Style := RMSetFontStyle(RM_LastFontStyle);
              end;
            TAG_FontItalic:
              begin
                StyleName := '';
                RM_LastFontStyle := RMGetFontStyle(Font.Style);
                _SetBit(RM_LastFontStyle, FToolbarEdit.btnFontItalic.Down, 1);
                Font.Style := RMSetFontStyle(RM_LastFontStyle);
              end;
            TAG_FontUnderline:
              begin
                StyleName := '';
                RM_LastFontStyle := RMGetFontStyle(Font.Style);
                _SetBit(RM_LastFontStyle, FToolbarEdit.btnFontUnderline.Down, 4);
                Font.Style := RMSetFontStyle(RM_LastFontStyle);
              end;
            TAG_HAlignLeft..TAG_HAlignEuqal:
              begin
                RM_LastHAlign := TRMHAlign(b - TAG_HAlignLeft);
                HAlign := RM_LastHAlign;
                TRMToolbarButton(Sender).Down := True;
              end;
            TAG_FontColor:
              begin
                Font.Color := FToolbarEdit.FBtnFontColor.CurrentColor;
                RM_LastFontColor := Font.Color;
              end;
            TAG_VAlignTop..TAG_VAlignBottom:
              begin
                RM_LastVAlign := TRMVAlign(b - TAG_VAlignTop);
                VAlign := RM_LastVAlign;
                TRMToolbarButton(Sender).Down := True;
              end;
          end;
        end;
      end;

      case b of
        TAG_SetFrameTop: TopFrame.Visible := FToolbarBorder.btnFrameTop.Down;
        TAG_SetFrameLeft: LeftFrame.Visible := FToolbarBorder.btnFrameLeft.Down;
        TAG_SetFrameBottom: BottomFrame.Visible := FToolbarBorder.btnFrameBottom.Down;
        TAG_SetFrameRight: RightFrame.Visible := FToolbarBorder.btnFrameRight.Down;
        TAG_BackColor:
          begin
            FillColor := FToolbarBorder.FBtnBackColor.CurrentColor;
            RM_LastFillColor := FillColor;
          end;
        TAG_FrameSize:
          begin
            LeftFrame.mmWidth := RMToMMThousandths(StrToFloat(FToolbarBorder.FCmbFrameWidth.Text), rmutScreenPixels);
            TopFrame.mmWidth := LeftFrame.mmWidth;
            RightFrame.mmWidth := LeftFrame.mmWidth;
            BottomFrame.mmWidth := LeftFrame.mmWidth;
            RM_LastFrameWidth := TopFrame.mmWidth;
          end;
        TAG_FrameColor:
          begin
            LeftFrame.Color := FToolbarBorder.FBtnFrameColor.CurrentColor;
            TopFrame.Color := LeftFrame.Color;
            RightFrame.Color := LeftFrame.Color;
            BottomFrame.Color := LeftFrame.Color;
            RM_LastFrameColor := LeftFrame.Color;
          end;
        TAG_SetFrame:
          begin
            LeftFrame.Visible := True;
            RightFrame.Visible := True;
            TopFrame.Visible := True;
            BottomFrame.Visible := True;
            RM_LastLeftFrameVisible := True;
            RM_LastTopFrameVisible := True;
            RM_LastRightFrameVisible := True;
            RM_LastBottomFrameVisible := True;
          end;
        TAG_NoFrame:
          begin
            LeftFrame.Visible := False;
            RightFrame.Visible := False;
            TopFrame.Visible := False;
            BottomFrame.Visible := False;
            RM_LastLeftFrameVisible := False;
            RM_LastTopFrameVisible := False;
            RM_LastRightFrameVisible := False;
            RM_LastBottomFrameVisible := False;
          end;
        TAG_FrameStyle1..TAG_FrameStyle5:
          begin
            LeftFrame.Style := TPenStyle(b - TAG_FrameStyle1);
            TopFrame.Style := LeftFrame.Style;
            RightFrame.Style := LeftFrame.Style;
            BottomFrame.Style := LeftFrame.Style;
          end;
        TAG_FrameStyle6:
          begin
            LeftFrame.DoubleFrame := not LeftFrame.DoubleFrame;
            TopFrame.DoubleFrame := LeftFrame.DoubleFrame;
            RightFrame.DoubleFrame := LeftFrame.DoubleFrame;
            BottomFrame.DoubleFrame := LeftFrame.DoubleFrame;
          end;
      end; {end Case}
    end; {end for }
  end;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  FWorkSpace.Draw(FDesignerForm.TopSelected, RM_ClipRgn);
  Editor_FillInspFields;
  Editor_SelectionChanged(True);
end;

procedure TRMReportPageEditor.Editor_SelectObject(aObjName: string);
var
  i: Integer;
  t: TRMView;
  lPage: TRMCustomPage;
begin
  t := FDesignerForm.Page.FindObject(aObjName);
  if t <> nil then
  begin
    FDesignerForm.UnSelectAll;
    FDesignerForm.SelNum := 1;
    t.Selected := True;
    Editor_SelectionChanged(True);
    FDesignerForm.RedrawPage;
    FWorkSpace.GetMultipleSelected;
  end
  else
  begin
    lPage := nil;
    for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
    begin
      lPage := FDesignerForm.Report.Pages[i];
      if AnsiCompareText(aObjName, lPage.Name) = 0 then
      begin
        Break;
      end;
    end;

    if lPage = FDesignerForm.Page then
    begin
      FDesignerForm.SelNum := 0;
      Editor_SelectionChanged(True);
    end
    else
      FDesignerForm.CurPage := StrToInt(Copy(aObjName, 5, 9999)) - 1;
  end;
end;

procedure TRMReportPageEditor.Editor_AfterChange;
begin
  FWorkSpace.DrawPage(dmSelection);
  FWorkSpace.Draw(FDesignerForm.TopSelected, 0);
end;

procedure TRMReportPageEditor.PBox1Paint(Sender: TObject);
var
  t: TRMView;
  p: TPoint;
  s: string;
  nx, ny: Double;
  x, y, dx, dy: Integer;

  function TopLeft: TPoint;
  var
    i: Integer;
    t: TRMView;
  begin
    Result.x := 10000;
    Result.y := 10000;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if t.Selected then
      begin
        if t.spLeft_Designer < Result.x then
          Result.x := t.spLeft_Designer;
        if t.spTop_Designer < Result.y then
          Result.y := t.spTop_Designer;
      end;
    end;
  end;

begin
  if (FWorkSpace = nil) or FWorkSpace.DisableDraw then Exit;

  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    PBox1.Canvas.FillRect(Rect(0, 0, PBox1.Width, PBox1.Height));
    PBox1.Canvas.TextOut(0, 0, RMLoadStr(rmRes + 578) + IntToStr(FDesignerForm.CodeMemo.CaretY) +
      '  ' + RMLoadStr(rmRes + 579) + IntToStr(FDesignerForm.CodeMemo.CaretX));
    Exit;
  end;

  nx := RM_OldRect.Left;
  ny := RM_OldRect.Top;
  with PBox1.Canvas do
  begin
    FillRect(Rect(0, 0, PBox1.Width, PBox1.Height));
    FDesignerForm.ImageListPosition.Draw(PBox1.Canvas, 2, 0, 0);
    if not ((FDesignerForm.SelNum = 0) and (FWorkSpace.EditMode = mdSelect)) then
      FDesignerForm.ImageListPosition.Draw(PBox1.Canvas, 92, 0, 1);
    if (FDesignerForm.SelNum = 1) or FShowSizes then
    begin
      t := nil;
      if FShowSizes then
      begin
        x := RM_OldRect.Left;
        y := RM_OldRect.Top;
        dx := RM_OldRect.Right - x;
        dy := RM_OldRect.Bottom - y;
      end
      else
      begin
        t := FDesignerForm.Objects[FDesignerForm.TopSelected];
        x := t.spLeft_Designer;
        y := t.spTop_Designer;
        dx := t.spWidth_Designer;
        dy := t.spHeight_Designer;
      end;

      nx := x;
      ny := y;
      if RMUnits = rmutScreenPixels then
        s := IntToStr(x) + ';' + IntToStr(y)
      else
      begin
        s := FloatToStrF(RMFromScreenPixels(x, RMUnits), ffFixed, 4, 2) + ';' +
          FloatToStrF(RMFromScreenPixels(y, RMUnits), ffFixed, 4, 2);
      end;
      TextOut(20, 1, s);

      if RMUnits = rmutScreenPixels then
        s := IntToStr(dx) + ';' + IntToStr(dy)
      else
      begin
        s := FloatToStrF(RMFromScreenPixels(dx, RMUnits), ffFixed, 4, 2) + ';' +
          FloatToStrF(RMFromScreenPixels(dy, RMUnits), ffFixed, 4, 2);
      end;
      TextOut(110, 1, s);

      if not FShowSizes and (t.ObjectType = rmgtPicture) then
      begin
        with t as TRMPictureView do
        begin
          if (Picture.Graphic <> nil) and (not Picture.Graphic.Empty) then
          begin
            if RMUnits = rmutScreenPixels then
              s := IntToStr(dx * 100 div Picture.Width) + ',' + IntToStr(dy * 100 div Picture.Height)
            else
            begin
              s := FloatToStrF(RMFromScreenPixels(dx * 100 div Picture.Width, RMUnits), ffFixed, 4, 2) + ',' +
                FloatToStrF(RMFromScreenPixels(dy * 100 div Picture.Height, RMUnits), ffFixed, 4, 2);
            end;
            TextOut(170, 1, '% ' + s);
          end;
        end;
      end;
    end
    else if (FDesignerForm.SelNum > 0) and RM_SelectedManyObject then
    begin
      p := TopLeft;
      if RMUnits = rmutScreenPixels then
        s := IntToStr(p.x) + ';' + IntToStr(p.y)
      else
      begin
        s := FloatToStrF(RMFromScreenPixels(p.x, RMUnits), ffFixed, 4, 2) + ';' +
          FloatToStrF(RMFromScreenPixels(p.y, RMUnits), ffFixed, 4, 2);
      end;
      TextOut(20, 1, s);

      nx := 0;
      ny := 0;
      if RM_OldRect1.Right - RM_OldRect1.Left <> 0 then
        nx := (RM_OldRect.Right - RM_OldRect.Left) / (RM_OldRect1.Right - RM_OldRect1.Left);
      if RM_OldRect1.Bottom - RM_OldRect1.Top <> 0 then
        ny := (RM_OldRect.Bottom - RM_OldRect.Top) / (RM_OldRect1.Bottom - RM_OldRect1.Top);

      if RMUnits = rmutScreenPixels then
        s := IntToStr(Round(nx * 100)) + ',' + IntToStr(Round(ny * 100))
      else
      begin
        s := FloatToStrF(RMFromScreenPixels(Round(nx * 100), RMUnits), ffFixed, 4, 2) + ',' +
          FloatToStrF(RMFromScreenPixels(Round(ny * 100), RMUnits), ffFixed, 4, 2);
      end;
      TextOut(170, 1, '% ' + s);

      nx := p.x;
      ny := p.y;
    end
    else if (FDesignerForm.SelNum = 0) and (FWorkSpace.EditMode = mdSelect) then
    begin
      x := RM_OldRect.Left;
      y := RM_OldRect.Top;
      nx := x;
      ny := y;
      if RMUnits = rmutScreenPixels then
        s := IntToStr(x) + ';' + IntToStr(y)
      else
      begin
        s := FloatToStrF(RMFromScreenPixels(x, RMUnits), ffFixed, 4, 2) + ';' +
          FloatToStrF(RMFromScreenPixels(y, RMUnits), ffFixed, 4, 2);
      end;
      TextOut(20, 1, s);
    end
  end;

  if FDesignerForm.Page is TRMReportPage then
  begin
    SetRulerOffset;
    x := Round(TRMReportPage(FDesignerForm.Page).spMarginLeft * FDesignerForm.Factor / 100);
    y := Round(TRMReportPage(FDesignerForm.Page).spMarginTop * FDesignerForm.Factor / 100);
    FHRuler.SetGuides(Trunc(x + nx - FHRuler.ScrollOffset), 0);
    FVRuler.SetGuides(Trunc(y + ny - FVRuler.ScrollOffset), 0);
  end;
end;

procedure TRMReportPageEditor.ShowObjMsg;
begin
  PBox1.Invalidate;
end;

procedure TRMReportPageEditor.SetRulerOffset;
begin
  if pnlWorkSpace.Left <= 0 then
  begin
    FHRuler.ScrollOffset := -pnlWorkSpace.Left;
  end;
  if pnlWorkSpace.Top <= 0 then
  begin
    FVRuler.ScrollOffset := -pnlWorkSpace.Top;
  end;
end;

procedure TRMReportPageEditor.SendBandsToDown;
var
  i, j, n, k: Integer;
  t: TRMView;
begin
  n := THackPage(FDesignerForm.Page).Objects.Count;
  j := 0;
  i := n - 1;
  k := 0;
  while j < n do
  begin
    t := THackPage(FDesignerForm.Page).Objects[i];
    if t.IsBand then
    begin
      THackPage(FDesignerForm.Page).Objects.Delete(i);
      THackPage(FDesignerForm.Page).Objects.Insert(0, t);
      Inc(k);
    end
    else
      Dec(i);

    Inc(j);
  end;

  for i := 0 to n - 1 do // sends btOverlay to back
  begin
    t := THackPage(FDesignerForm.Page).Objects[i];
    if t.IsBand and (TRMCustomBandView(t).BandType = rmbtOverlay) then
    begin
      THackPage(FDesignerForm.Page).Objects.Delete(i);
      THackPage(FDesignerForm.Page).Objects.Insert(0, t);
      break;
    end;
  end;

  i := 0;
  j := 0;
  while j < n do // sends btColumnXXX to front
  begin
    t := THackPage(FDesignerForm.Page).Objects[i];
    if t.IsBand and (TRMCustomBandView(t).IsCrossBand) then
    begin
      THackPage(FDesignerForm.Page).Objects.Delete(i);
      THackPage(FDesignerForm.Page).Objects.Insert(k - 1, t);
    end
    else
      Inc(i);
    Inc(j);
  end;
end;

procedure TRMReportPageEditor.GetDefaultSize(var aWidth, aHeight: Integer);
begin
  if FDesignerForm.GridSize = 18 then
    aWidth := 18 * 6
  else
    aWidth := 96;

  aHeight := 24;
  if (FToolbarComponent.ObjectBand <> nil) and FToolbarComponent.ObjectBand.Down then
    aWidth := FWorkSpace.Width;
end;

procedure TRMReportPageEditor.Editor_SetObjectsID;
var
  i, j: Integer;
begin
  FDesignerForm.ObjID := 0;
  for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
  begin
    for j := 0 to THackPage(FDesignerForm.Report.Pages[i]).Objects.Count - 1 do
    begin
      THackView(THackPage(FDesignerForm.Report.Pages[i]).Objects[j]).ObjectID := FDesignerForm.ObjID;
      Inc(FDesignerForm.ObjID);
    end;
  end;
end;

procedure TRMReportPageEditor.Editor_BtnCutClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCut then
    begin
      FDesignerForm.CodeMemo.RMClipBoardCut;
      Editor_ShowPosition;
    end;
  end
  else
  begin
    FWorkSpace.CopyToClipboard;
    FWorkSpace.DeleteObjects(True);
    FDesignerForm.FirstSelected := nil;
    FDesignerForm.EnableControls;
    Editor_ShowPosition;
    FDesignerForm.RedrawPage;
  end;
end;

procedure TRMReportPageEditor.Editor_BtnCopyClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCopy then
    begin
      FDesignerForm.CodeMemo.RMClipBoardCopy;
      Editor_ShowPosition;
    end;
  end
  else
  begin
    FWorkSpace.CopyToClipboard;
    FDesignerForm.EnableControls;
  end;
end;

procedure TRMReportPageEditor.Editor_BtnPasteClick(Sender: TObject);
var
  minx, miny, lNewX, lNewY: Integer;
  t: TRMView;
  b: Byte;
  lPoint: TPoint;
  hMem: THandle;
  pMem: pointer;
  hSize: DWORD;
  lStream: TMemoryStream;
  i, lCount: Integer;

  procedure _CreateName(t: TRMView);
  begin
    if FDesignerForm.Report.FindObject(t.Name) <> nil then
    begin
      t.CreateName(FDesignerForm.Report);
      t.Name := t.Name;
    end;
  end;

  procedure _GetMinXY;
  var
    i, lCount: Integer;
  begin
    lStream.Seek(soFromBeginning, 0);
    lCount := RMReadInt32(lStream);
    for i := 0 to lCount - 1 do
    begin
      b := RMReadByte(lStream);
      t := RMCreateObject(b, RMReadString(lStream));
      try
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(lStream);
        if Round(t.spLeft / FDesignerForm.Factor * 100) < minx then
          minx := Round(t.spLeft / FDesignerForm.Factor * 100);
        if Round(t.spTop / FDesignerForm.Factor * 100) < miny then
          miny := Round(t.spTop / FDesignerForm.Factor * 100);
      finally
        t.Free;
      end;
    end;

    if (lPoint.X >= 0) and (lPoint.X < FWorkSpace.Width) and (lPoint.Y >= 0) and
      (lPoint.Y < FWorkSpace.Height) then
    begin
      minx := lPoint.X - minx;
      miny := lPoint.Y - miny;
    end
    else
    begin
      minx := -minx + (-FWorkSpace.Left) div FDesignerForm.GridSize * FDesignerForm.GridSize;
      miny := -miny + (-FWorkSpace.Left) div FDesignerForm.GridSize * FDesignerForm.GridSize;
    end;
  end;

begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanPaste then
    begin
      FDesignerForm.CodeMemo.RMClipBoardPaste;
      FDesignerForm.ShowPosition;
    end;
    Exit;
  end;

  GetCursorPos(lPoint);
  lPoint := FWorkSpace.ScreenToClient(lPoint);

  FDesignerForm.UnSelectAll;
  FDesignerForm.SelNum := 0;
  minx := 32767;
  miny := 32767;

  lStream := nil;
  Clipboard.Open;
  try
    hMem := Clipboard.GetAsHandle(CF_REPORTMACHINE);
    pMem := GlobalLock(hMem);
    if pMem <> nil then
    begin
      hSize := GlobalSize(hMem);
      lStream := TMemoryStream.Create;
      try
        lStream.Write(pMem^, hSize);
      finally
        GlobalUnlock(hMem);
      end;
    end;
  finally
    Clipboard.Close;
  end;

  if lStream = nil then Exit;

  try
    _GetMinXY;
    lStream.Seek(soFromBeginning, 0);
    lCount := RMReadInt32(lStream);
    for i := 0 to lCount - 1 do
    begin
      b := RMReadByte(lStream);
      t := RMCreateObject(b, RMReadString(lStream));
      t.NeedCreateName := False;
      try
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(lStream);
        if (t is TRMSubReportView) or
          ((FDesignerForm.Page is TRMReportPage) and (t is TRMDialogComponent)) or
          (FDesignerForm.Page is TRMDialogPage) and (t is TRMReportView) then
        begin
          t.Free;
          Continue;
        end;

        if t.IsBand then
        begin
          if not (TRMCustomBandView(t).BandType in [rmbtMasterData, rmbtDetailData, rmbtHeader, rmbtFooter,
            rmbtGroupHeader, rmbtGroupFooter]) and FDesignerForm.RMCheckBand(TRMCustomBandView(t).BandType) then
          begin
            t.Free;
            Continue;
          end;
        end;

        t.Selected := True;
        Inc(FDesignerForm.SelNum);
        t.ParentPage := FDesignerForm.Page;
        _CreateName(t);

        begin
          lNewX := t.spLeft_Designer + minx;
          lNewY := t.spTop_Designer + miny;
          FWorkSpace.RoundCoord(lNewX, lNewY);
          t.spLeft_Designer := lNewX;
          t.spTop_Designer := lNewY;
        end;

        FDesignerForm.SetObjectID(t);
      finally
      end;
    end;
  finally
    lStream.Free;
    Editor_SelectionChanged(True);
    SendBandsToDown;
    FWorkSpace.GetMultipleSelected;
    FDesignerForm.RedrawPage;
    FDesignerForm.Modified := True;
    Editor_AddUndoAction(rmacInsert);
  end;
end;

procedure TRMReportPageEditor.Popup1Popup(Sender: TObject);
var
  i: Integer;
  t, t1: TRMView;
  fl: Boolean;

  procedure _AddAutoArrangeMenuItem;
  var
    MenuItem: TRMMenuItem;
  begin
    MenuItem := TRMMenuItem.Create(Self);
    MenuItem.Caption := RMLoadStr(rmRes + 212);
    MenuItem.OnClick := OnpadAutoArrangeClick;
    FPopupMenu.Items.Add(MenuItem);
  end;

  procedure _AddOtherMenuItem;
  var
    MenuItem: TRMMenuItem;
  begin
    FPopupMenu.Items.Add(RMNewLine());

    MenuItem := TRMMenuItem.Create(Self);
    MenuItem.Caption := RMLoadStr(rmRes + 211);
    MenuItem.Checked := FDesignerForm.InspForm.Visible;
    MenuItem.OnClick := Pan5Click;
    FPopupMenu.Items.Add(MenuItem);

    padpopFrame.Enabled := FToolbarBorder.btnFrameTop.Enabled;
  end;

begin
  FDesignerForm.EnableControls;
  while FPopupMenu.Items.Count > DefaultPopupItemsCount do
    FPopupMenu.Items.Delete(DefaultPopupItemsCount);

  if FDesignerForm.SelNum = 1 then
  begin
    if TRMView(FDesignerForm.Objects[FDesignerForm.TopSelected]).IsBand then
      _AddAutoArrangeMenuItem;

    TRMView(FDesignerForm.Objects[FDesignerForm.TopSelected]).DefinePopupMenu(TRMCustomMenuItem(FPopupMenu.Items));
  end
  else if FDesignerForm.SelNum > 1 then
  begin
    t := FDesignerForm.Objects[FDesignerForm.TopSelected];
    fl := True;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t1 := FDesignerForm.Objects[i];
      if t1.Selected and (t.ClassName <> t1.ClassName) then
      begin
        fl := False;
        Break;
      end;
    end;

    if fl then
      t.DefinePopupMenu(TRMCustomMenuItem(FPopupMenu.Items));

    if fl and t.IsBand then
    begin
      fl := True;
      for i := 0 to FDesignerForm.Objects.Count - 1 do
      begin
        t1 := FDesignerForm.Objects[i];
        if t1.Selected and (not t1.IsBand) then
        begin
          fl := False;
          Break;
        end;
      end;

      if fl then _AddAutoArrangeMenuItem;
    end;
  end;

  _AddOtherMenuItem;
end;

procedure TRMReportPageEditor.padDeleteClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCut then
    begin
      FDesignerForm.CodeMemo.RMDeleteSelected;
      FDesignerForm.ShowPosition;
    end;
  end
  else
    FWorkSpace.DeleteObjects(True);
end;

procedure TRMReportPageEditor.padpopFrameClick(Sender: TObject);
var
  t: TRMView;
  tmp: TRMFormFrameProp;
begin
  t := FDesignerForm.Objects[FDesignerForm.TopSelected];
  tmp := TRMFormFrameProp.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;
end;

procedure TRMReportPageEditor.padpopEditClick(Sender: TObject);
begin
  ShowEditor;
end;

procedure TRMReportPageEditor.padpopClearContentsClick(Sender: TObject);
var
  i: Integer;
  lList: TList;
  t: TRMView;
begin
  FDesignerForm.BeforeChange;
  lList := FDesignerForm.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if t.Selected and (not t.IsBand) then
      THackView(t).ClearContents;
  end;
  FDesignerForm.AfterChange;
end;

procedure TRMReportPageEditor.OnpadAutoArrangeClick(Sender: TObject);
var
  i: Integer;
  t: TRMView;
  s, liBandList: TList;
  liWidths: TStringList;
  liLeft: Integer;

  procedure ArrangeOneBand(aFirstTime: Boolean; aBand: TRMView);
  var
    i, j: Integer;
    t: TRMView;
    lix, liy, lidy: Integer;
  begin
    s.Clear;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := TRMView(FDesignerForm.Objects[i]);
      if (not t.IsBand) and (t.spTop_Designer >= aBand.spTop_Designer) and (t.spBottom_Designer <= aBand.spBottom_Designer) then
        s.Add(t);
    end;

    for i := 0 to s.Count - 1 do
    begin
      for j := i + 1 to s.Count - 1 do
      begin
        if TRMView(s[i]).spLeft_Designer > TRMView(s[j]).spLeft_Designer then
          s.Exchange(i, j);
      end;
    end;

    if s.Count > 0 then
    begin
      if aFirstTime then
      begin
        liLeft := TRMView(s[0]).spLeft_Designer;
        liWidths.Add(IntToStr(TRMView(s[0]).spWidth_Designer));
      end
      else
      begin
        TRMView(s[0]).spLeft_Designer := liLeft;
        if liWidths.Count > 0 then
          TRMView(s[0]).spWidth_Designer := StrToInt(liWidths[0]);
      end;

      lix := TRMView(s[0]).spRight_Designer;
      liy := TRMView(s[0]).spTop_Designer;
      lidy := TRMView(s[0]).spHeight_Designer;
      for i := 1 to s.Count - 1 do
      begin
        t := TRMView(s[i]);
        t.spLeft_Designer := lix;
        t.spTop_Designer := liy;
        t.spHeight_Designer := lidy;

        if aFirstTime then
          liWidths.Add(IntToStr(t.spWidth_Designer))
        else
        begin
          if i < liWidths.Count then
            t.spWidth_Designer := StrToInt(liWidths[i]);
        end;
        Inc(lix, t.spWidth_Designer);
      end;
    end;
  end;

begin
  if TRMView(FDesignerForm.Objects[FDesignerForm.TopSelected]).IsBand then
  begin
    FDesignerForm.BeforeChange;
    s := TList.Create;
    liBandList := TList.Create;
    liWidths := TStringList.Create;
    try
      if FDesignerForm.SelNum = 1 then
        liBandList.Add(FDesignerForm.Objects[FDesignerForm.TopSelected])
      else
      begin
        for i := 0 to FDesignerForm.Objects.Count - 1 do
        begin
          t := TRMView(FDesignerForm.Objects[i]);
          if t.Selected and t.IsBand then
            liBandList.Add(t);
        end;
      end;

      liLeft := 0;
      for i := 0 to liBandList.Count - 1 do
      begin
        ArrangeOneBand(i = 0, liBandList[i]);
      end;
    finally
      s.Free;
      liBandList.Free;
      liWidths.Free;
    end;

    FWorkSpace.GetMultipleSelected;
    FDesignerForm.RedrawPage;
  end;
end;

procedure TRMReportPageEditor.Editor_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  lStepX, lStepY: Integer;
  i, tx, ty, tx1, ty1, d, d1: Integer;
  t, t1: TRMView;
begin
  lStepX := 0;
  lStepY := 0;
  if (Key = vk_F11) and (Shift = []) then
  begin
    Pan5Click(Pan5);
  end
  else if Key = vk_F9 then
    FDesignerForm.ToolbarStandard.btnPreview.Click
  else if (Key = vk_Escape) and (not FWorkSpace.MouseButtonDown) then
  begin
    ToolbarComponent.btnNoSelect.Down := True;
    FWorkSpace.Perform(CM_MOUSELEAVE, 0, 0);
    FWorkSpace.OnMouseMoveEvent(nil, [], 0, 0);
    FDesignerForm.UnSelectAll;
    FDesignerForm.RedrawPage;
    Editor_SelectionChanged(True);
  end
  else if (Key = vk_Return) and (FDesignerForm.ActiveControl = FToolbarEdit.FCmbFontSize) then
  begin
    Key := 0;
    Editor_DoClick(FToolbarEdit.FCmbFontSize);
  end
  else if (((Key = vk_Return) and (ssCtrl in Shift)) or (Key = vk_F2)) and EditEnabled then
  begin
    if ssCtrl in Shift then
      FDesignerForm.RMMemoViewEditor(nil)
    else
      ShowEditor;
  end
  else if (Key = vk_Delete) and DelEnabled then
  begin
    FWorkSpace.DeleteObjects(True);
    Key := 0;
  end
  else if (Chr(Key) = 'F') and (ssCtrl in Shift) and DelEnabled then
  begin
    FToolbarBorder.btnSetFrame.Click;
    Key := 0;
  end
  else if (Chr(Key) = 'D') and (ssCtrl in Shift) and DelEnabled then
  begin
    FToolbarBorder.btnNoFrame.Click;
    Key := 0;
  end
  else if (Chr(Key) = 'G') and (ssCtrl in Shift) then
  begin
    FDesignerForm.ShowGrid := not FDesignerForm.ShowGrid;
    Key := 0;
  end
  else if (ssCtrl in Shift) and EditEnabled then
  begin
    if Chr(Key) = 'B' then
    begin
      FToolbarEdit.btnFontBold.Down := not FToolbarEdit.btnFontBold.Down;
      Editor_DoClick(FToolbarEdit.btnFontBold);
    end
    else if Chr(Key) = 'I' then
    begin
      FToolbarEdit.btnFontItalic.Down := not FToolbarEdit.btnFontItalic.Down;
      Editor_DoClick(FToolbarEdit.btnFontItalic);
    end
    else if Chr(Key) = 'U' then
    begin
      FToolbarEdit.btnFontUnderline.Down := not FToolbarEdit.btnFontUnderline.Down;
      Editor_DoClick(FToolbarEdit.btnFontUnderline);
    end;
  end;

  if CutEnabled then
  begin
    if (Key = vk_Delete) and (ssShift in Shift) then
      FDesignerForm.ToolbarStandard.btnCut.Click;
  end;
  if CopyEnabled then
  begin
    if (Key = vk_Insert) and (ssCtrl in Shift) then
      FDesignerForm.ToolbarStandard.btnCopy.Click;
  end;
  if PasteEnabled then
  begin
    if (Key = vk_Insert) and (ssShift in Shift) then
      FDesignerForm.ToolbarStandard.btnPaste.Click;
  end;
  if Key = vk_Prior then
  begin
    with FScrollBox.VertScrollBar do
    begin
      Position := Position - 200;
      Key := 0;
    end;
  end
  else if Key = vk_Next then
  begin
    with FScrollBox.VertScrollBar do
    begin
      Position := Position + 200;
      Key := 0;
    end;
  end;

  if FDesignerForm.SelNum > 0 then
  begin
    if Key = vk_Up then
      lStepY := -1
    else if Key = vk_Down then
      lStepY := 1
    else if Key = vk_Left then
      lStepX := -1
    else if Key = vk_Right then
      lStepX := 1;
    if (lStepX <> 0) or (lStepY <> 0) then
    begin
      if ssCtrl in Shift then
        MoveObjects(lStepX, lStepY, False)
      else if ssShift in Shift then
        MoveObjects(lStepX, lStepY, True)
      else if FDesignerForm.SelNum = 1 then
      begin
        t := FDesignerForm.Objects[FDesignerForm.TopSelected];
        tx := t.spLeft_Designer;
        ty := t.spTop_Designer;
        tx1 := t.spRight_Designer;
        ty1 := t.spBottom_Designer;
        d := 10000;
        t1 := nil;
        for i := 0 to FDesignerForm.Objects.Count - 1 do
        begin
          t := FDesignerForm.Objects[i];
          if not t.Selected and (not t.IsBand) then
          begin
            d1 := 10000;
            if lStepX <> 0 then
            begin
              if t.spBottom_Designer < ty then
                d1 := ty - (t.spBottom_Designer)
              else if t.spTop_Designer > ty1 then
                d1 := t.spTop_Designer - ty1
              else if (t.spTop_Designer <= ty) and (t.spBottom_Designer >= ty1) then
                d1 := 0
              else
                d1 := t.spTop_Designer - ty;
              if ((t.spLeft_Designer <= tx) and (lStepX = 1)) or
                ((t.spRight_Designer >= tx1) and (lStepX = -1)) then
                d1 := 10000;
              if lStepX = 1 then
              begin
                if t.spLeft_Designer >= tx1 then
                  d1 := d1 + t.spLeft_Designer - tx1
                else
                  d1 := d1 + t.spLeft_Designer - tx;
              end
              else if t.spRight_Designer <= tx then
                d1 := d1 + tx - t.spRight_Designer
              else
                d1 := d1 + tx1 - t.spRight_Designer;
            end
            else if lStepY <> 0 then
            begin
              if t.spRight_Designer < tx then
                d1 := tx - t.spRight_Designer
              else if t.spLeft_Designer > tx1 then
                d1 := t.spLeft_Designer - tx1
              else if (t.spLeft_Designer <= tx) and (t.spRight_Designer >= tx1) then
                d1 := 0
              else
                d1 := t.spLeft_Designer - tx;
              if ((t.spTop_Designer <= ty) and (lStepY = 1)) or ((t.spBottom_Designer >= ty1) and (lStepY = -1)) then
                d1 := 10000;
              if lStepY = 1 then
              begin
                if t.spTop_Designer >= ty1 then
                  d1 := d1 + t.spTop_Designer - ty1
                else
                  d1 := d1 + t.spTop_Designer - ty;
              end
              else if t.spBottom_Designer <= ty then
                d1 := d1 + ty - t.spBottom_Designer
              else
                d1 := d1 + ty1 - t.spBottom_Designer;
            end;
            if d1 < d then
            begin
              d := d1;
              t1 := t;
            end;
          end;
        end;
        if t1 <> nil then
        begin
          t := FDesignerForm.Objects[FDesignerForm.TopSelected];
          if not (ssAlt in Shift) then
          begin
            FWorkSpace.DrawPage(dmSelection);
            FDesignerForm.UnSelectAll;
            FDesignerForm.SelNum := 1;
            t1.Selected := True;
            FWorkSpace.DrawPage(dmSelection);
          end
          else
          begin
            if (t1.spLeft_Designer >= t.spRight_Designer) and (Key = vk_Right) then
              t.spLeft_Designer := t1.spLeft_Designer - t.spWidth_Designer
            else if (t1.spTop_Designer > t.spBottom_Designer) and (Key = vk_Down) then
              t.spTop_Designer := t1.spTop_Designer - t.spHeight_Designer
            else if (t1.spRight_Designer <= t.spLeft_Designer) and (Key = vk_Left) then
              t.spLeft_Designer := t1.spRight_Designer
            else if (t1.spBottom_Designer <= t.spTop_Designer) and (Key = vk_Up) then
              t.spTop_Designer := t1.spBottom_Designer;

            FDesignerForm.RedrawPage;
          end;

          Editor_SelectionChanged(True);
        end;
      end;
    end;
  end;
end;

function TRMReportPageEditor.RectTypEnabled: Boolean;
begin
  Result := [rmssMemo, rmssOther, rmssMultiple] * SelStatus <> [];
end;

function TRMReportPageEditor.ZEnabled: Boolean;
begin
  Result := [rmssBand, rmssMemo, rmssOther, rmssMultiple] * SelStatus <> [];
end;

function TRMReportPageEditor.CutEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCut and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := [rmssBand, rmssMemo, rmssOther, rmssMultiple] * SelStatus <> [];
end;

function TRMReportPageEditor.CopyEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCopy and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := [rmssBand, rmssMemo, rmssOther, rmssMultiple] * SelStatus <> [];
end;

function TRMReportPageEditor.PasteEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanPaste and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := Clipboard.HasFormat(CF_REPORTMACHINE);
end;

function TRMReportPageEditor.DelEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCut and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := [rmssBand, rmssMemo, rmssOther, rmssMultiple] * SelStatus <> [];
end;

function TRMReportPageEditor.EditEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := False
  else
    Result := [rmssBand, rmssMemo, rmssOther] * SelStatus <> [];
end;

function TRMReportPageEditor.RedoEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanRedo and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := (FDesignerForm.RedoBufferLength > 0);
end;

function TRMReportPageEditor.UndoEnabled: Boolean;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanUndo and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := (FDesignerForm.UndoBufferLength > 0);
end;

function TRMReportPageEditor.GetSelectionStatus: TRMSelectionStatus;
var
  t: TRMView;
begin
  Result := [];
  if FDesignerForm.SelNum = 1 then
  begin
    t := FDesignerForm.Objects[FDesignerForm.TopSelected];
    if t.IsBand then
      Result := [rmssBand]
    else if t is TRMCustomMemoView then
      Result := [rmssMemo]
    else
      Result := [rmssOther];
  end
  else if FDesignerForm.SelNum > 1 then
    Result := [rmssMultiple];
end;

procedure TRMReportPageEditor.MoveObjects(dx, dy: Integer; Resize: Boolean);
var
  i: Integer;
  t: TRMView;

  function _CanResize: Boolean;
  var
    i: Integer;
  begin
    Result := True;
    if (dx >= 0) and (dy >= 0) then Exit;
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if t.Selected then
      begin
        if (t.spWidth_Designer + dx < 0) or (t.spHeight_Designer + dy < 0) then
        begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;

begin
  if Resize then
  begin
    if not _CanResize then Exit;
  end;

  Editor_AddUndoAction(rmacEdit);
  FDesignerForm.Modified := True;
  GetRegion;
  FWorkSpace.DrawPage(dmSelection);
  for i := 0 to FDesignerForm.Objects.Count - 1 do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      if Resize then // 改变大小
      begin
        t.spWidth_Designer := t.spWidth_Designer + dx;
        t.spHeight_Designer := t.spHeight_Designer + dy;
      end
      else // 移动位置
      begin
        if t.IsBand then
        begin
          if TRMCustomBandView(t).BandType in [rmbtOverlay, rmbtCrossHeader..rmbtCrossChild] then
          begin
            t.spLeft_Designer := t.spLeft_Designer + dx;
            t.spTop_Designer := t.spTop_Designer + dy;
          end;
        end
        else
        begin
          t.spLeft_Designer := t.spLeft_Designer + dx;
          t.spTop_Designer := t.spTop_Designer + dy;
        end;
      end;
    end;
  end;

  FDesignerForm.ShowPosition;
  FWorkSpace.GetMultipleSelected;
  FWorkSpace.Draw(FDesignerForm.TopSelected, RM_ClipRgn);
end;

procedure TRMReportPageEditor.ShowEditor;
var
  t: TRMView;

  procedure _EditDataBand;
  begin
    with TRMBandEditorForm.Create(nil) do
    begin
      ShowEditor(t);
      Free;
    end;
  end;

  procedure _EditGroupHeaderBand;
  begin
    with TRMGroupEditorForm.Create(nil) do
    begin
      ShowEditor(t);
      Free;
    end;
  end;

begin
  t := FDesignerForm.Objects[FDesignerForm.TopSelected];

  if ((t.Restrictions * [rmrtDontModify]) <> []) or
    (FDesignerForm.DesignerRestrictions * [rmdrDontEditObj] <> []) then Exit;

  if t.ObjectType = rmgtSubReport then
    FDesignerForm.CurPage := (t as TRMSubReportView).SubPage
  else
  begin
    FWorkSpace.DrawPage(dmSelection);
    if not t.IsBand then
    begin
      t.ShowEditor;
    end
    else
    begin
      if (t is TRMBandMasterData) or (t is TRMBandCrossHeader) then
        _EditDataBand
      else if t is TRMBandGroupHeader then
        _EditGroupHeaderBand
    end;

    FWorkSpace.DrawPage(dmSelection);
    FWorkSpace.Draw(FDesignerForm.TopSelected, t.GetClipRgn(rmrtExtended));
  end;

  FDesignerForm.ShowPosition;
  Editor_ShowContent;
end;

procedure TRMReportPageEditor.barFileClick(Sender: TObject);
begin
  FDesignerForm.EnableControls;
  itmEditLockControls.Checked := (FDesignerForm.DesignerRestrictions * [rmdrDontSizeObj, rmdrDontMoveObj]) <> [];
end;

procedure TRMReportPageEditor.btnSelectAllClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    FDesignerForm.CodeMemo.SelectAll;
    //FCodeMemo.Command(ecSelAll);
    FDesignerForm.ShowPosition;
  end
  else
  begin
    FWorkSpace.DrawPage(dmSelection);
    FWorkSpace.SelectAll;
    FWorkSpace.GetMultipleSelected;
    FWorkSpace.DrawPage(dmSelection);
    Editor_SelectionChanged(True);
  end;
end;

procedure TRMReportPageEditor.padEditClick(Sender: TObject);
begin
  ShowEditor;
end;

procedure TRMReportPageEditor.padEditReplaceClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
  end
  else
  begin
    if FFindReplaceForm = nil then
    begin
      FFindReplaceForm := TRMFindReplaceForm.Create(FDesignerForm);
      TRMFindReplaceForm(FFindReplaceForm).OnModifyView := OnFindReplaceView;
    end;
    FFindReplaceForm.Show;
  end;
end;

procedure TRMReportPageEditor.btnBringtoFrontClick(Sender: TObject);
var
  i, j, n: Integer;
  t: TRMView;
begin
  FDesignerForm.AddUndoAction(rmacZOrder);
  n := FDesignerForm.Objects.Count - 1;
  i := 0;
  for j := 0 to n do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      FDesignerForm.Objects.Delete(i);
      FDesignerForm.Objects.Add(t);
    end
    else
      Inc(i);
  end;

  FDesignerForm.Modified := True;
  SendBandsToDown;
  FDesignerForm.RedrawPage;
end;

procedure TRMReportPageEditor.btnSendtoBackClick(Sender: TObject);
var
  t: TRMView;
  i, j, n: Integer;
begin
  FDesignerForm.AddUndoAction(rmacZOrder);
  n := FDesignerForm.Objects.Count;
  j := 0;
  i := n - 1;
  while j < n do
  begin
    t := FDesignerForm.Objects[i];
    if t.Selected then
    begin
      FDesignerForm.Objects.Delete(i);
      FDesignerForm.Objects.Insert(0, t);
    end
    else
      Dec(i);
    Inc(j);
  end;

  FDesignerForm.Modified := True;
  SendBandsToDown;
  FDesignerForm.RedrawPage;
end;

procedure TRMReportPageEditor.itmEditLockControlsClick(Sender: TObject);
begin
  if RMDesignerComp = nil then Exit;

  if itmEditLockControls.Checked then
  begin
    if FDesignerForm.SaveDesignerRestrictions * [rmdrDontSizeObj, rmdrDontMoveObj] = [] then
      FDesignerForm.DesignerRestrictions := FDesignerForm.DesignerRestrictions - [rmdrDontSizeObj, rmdrDontMoveObj];
  end
  else
  begin
    if FDesignerForm.SaveDesignerRestrictions * [rmdrDontSizeObj, rmdrDontMoveObj] = [] then
      FDesignerForm.DesignerRestrictions := FDesignerForm.SaveDesignerRestrictions + [rmdrDontSizeObj, rmdrDontMoveObj];
  end;
end;

procedure TRMReportPageEditor.padSetToolbarClick(Sender: TObject);
begin
  Pan1.Checked := FToolbarBorder.Visible;
  Pan2.Checked := FDesignerForm.ToolbarStandard.Visible;
  Pan3.Checked := FToolbarEdit.Visible;
  Pan4.Checked := FToolbarComponent.Visible;
  Pan5.Checked := FDesignerForm.InspForm.Visible;
  Pan6.Checked := FToolbarAlign.Visible;
  Pan7.Checked := FToolBarAddinTools.Visible;
  Pan8.Checked := FToolBarSize.Visible;
  Pan9.Checked := FDesignerForm.FieldForm.Visible;
end;

procedure TRMReportPageEditor.Pan2Click(Sender: TObject);

  procedure _SetShow(aControls: array of TWinControl; i: Integer; aVisible: Boolean);
  begin
    if aControls[i] is TRMToolbar then
      TRMToolbar(aControls[i]).Visible := aVisible
    else if aControls[i] is TForm then
      TForm(aControls[i]).Visible := aVisible
    else if aControls[i] is TRMToolWin then
    begin
      TRMToolWin(aControls[i]).Visible := aVisible;
      if aVisible then
        TRMToolWin(aControls[i]).BringToFront;
    end
    else
      aControls[i].VIsible := aVisible;
  end;

begin
  with TRMMenuItem(Sender) do
  begin
    Checked := not Checked;
    if Tag = 8 then // insert fields
    begin
      if not THackDesigner(FDesignerForm).IsPreviewDesign then
        ShowFieldsDialog(Checked);
    end
    else if Tag = 11 then
      _SetShow([FDesignerForm.ToolbarModifyPrepared], 0, Checked)
    else
      _SetShow([FToolbarBorder, FDesignerForm.ToolbarStandard, FToolbarEdit, ToolbarComponent,
        FToolbarAlign, FDesignerForm.InspForm, FToolBarAddinTools, FToolBarSize], Tag, Checked);
  end;
end;

procedure TRMReportPageEditor.Pan5Click(Sender: TObject);
begin
  //dejoy changed
  if Sender is TRMMenuItem then
  begin
    with Sender as TRMMenuItem do
    begin
      FDesignerForm.InspForm.Visible := not FDesignerForm.InspForm.Visible;
      Checked := FDesignerForm.InspForm.Visible;
      Pan5.Checked := Checked;
    end;
  end
  else
  begin
    with Sender as TMenuItem do
    begin
      FDesignerForm.InspForm.Visible := not FDesignerForm.InspForm.Visible;
      Checked := FDesignerForm.InspForm.Visible;
      Pan5.Checked := Checked;
    end;
  end;

  if FDesignerForm.InspForm.Visible then
  begin
    FDesignerForm.InspForm.BringToFront;
    Editor_FillInspFields;
  end;
end;

procedure TRMReportPageEditor.padOptionsClick(Sender: TObject);
var
  lSaveShowBandTitles: Boolean;
  lOldPage: Integer;
  tmp: TRMDesOptionsForm;
begin
  lSaveShowBandTitles := RMShowBandTitles;
  lOldPage := FDesignerForm.CurPage;
  tmp := TRMDesOptionsForm.Create(nil);
  try
    tmp.CB1.Checked := FDesignerForm.ShowGrid;
    tmp.CB2.Checked := FDesignerForm.GridAlign;
    case FDesignerForm.GridSize of
      4: tmp.RB1.Checked := True;
      8: tmp.RB2.Checked := True;
      18: tmp.RB3.Checked := True;
    end;
    case RMUnits of
      rmutScreenPixels: tmp.RB6.Checked := True;
      rmutInches: tmp.RB7.Checked := True;
      rmutMillimeters: tmp.RB8.Checked := True;
      rmutMMThousandths: tmp.RB9.Checked := True;
    end;
    tmp.CB5.Checked := RM_Class.RMShowBandTitles;
    tmp.CB7.Checked := RM_Class.RMLocalizedPropertyNames;
    tmp.ChkShowDropDownField.Checked := RM_Class.RMShowDropDownField;
    tmp.chkAutoOpenLastFile.Checked := FDesignerForm.AutoOpenLastFile;
    tmp.WorkSpaceColor := FDesignerForm.WorkSpaceColor;
    tmp.InspColor := FDesignerForm.InspFormColor;

    if tmp.ShowModal = mrOK then
    begin
      FDesignerForm.ShowGrid := tmp.CB1.Checked;
      FDesignerForm.GridAlign := tmp.CB2.Checked;
      if tmp.RB1.Checked then
        FDesignerForm.GridSize := 4
      else if tmp.RB2.Checked then
        FDesignerForm.GridSize := 8
      else
        FDesignerForm.GridSize := 18;

      if tmp.RB6.Checked then
        RMUnits := rmutScreenPixels
      else if tmp.RB7.Checked then
        RMUnits := rmutInches
      else if tmp.RB8.Checked then
        RMUnits := rmutMillimeters
      else
        RMUnits := rmutMMThousandths;
      RM_Class.RMShowBandTitles := tmp.CB5.Checked;
      RM_Class.RMLocalizedPropertyNames := tmp.CB7.Checked;
      RM_Class.RMShowDropDownField := tmp.ChkShowDropDownField.Checked;
      FDesignerForm.AutoOpenLastFile := tmp.chkAutoOpenLastFile.Checked;
      FDesignerForm.WorkSpaceColor := tmp.WorkSpaceColor;
      FDesignerForm.InspFormColor := tmp.InspColor;

      FHRuler.Units := RMUnits;
      FVRuler.Units := RMUnits;
      if lSaveShowBandTitles <> RMShowBandTitles then
        FDesignerForm.SetOldCurPage(-1);

      FDesignerForm.CurPage := lOldPage;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMReportPageEditor.OnFindReplaceView(Sender: TObject);
begin
  FWorkSpace.DrawPage(dmSelection);
  FDesignerForm.UnSelectAll;
  TRMView(Sender).Selected := True;
  FDesignerForm.SelNum := 1;
  Editor_SelectionChanged(True);
  FWorkSpace.DrawPage(dmSelection);
end;

procedure TRMReportPageEditor.ShowFieldsDialog(aVisible: Boolean);
begin
  FToolbarAddinTools.btnInsertFields.Down := aVisible;
  if aVisible then
  begin
    FDesignerForm.FieldForm.Visible := True;
    FDesignerForm.FieldForm.RefreshData;
    FDesignerForm.FieldForm.SetFocus;
  end
  else
  begin
    FDesignerForm.FieldForm.Visible := False;
  end;
end;

procedure TRMReportPageEditor.Editor_EnableControls;

  function _FontTypEnabled: Boolean;
  begin
    Result := ([rmssMemo, rmssMultiple] * SelStatus <> []) and (FDesignerForm.Page is TRMReportPage);
  end;

begin
  ToolbarComponent.Enabled := FDesignerForm.Tab1.TabIndex > 0;
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnUndo, padUndo], UndoEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnRedo, padRedo], RedoEnabled);

  with FToolbarBorder do
  begin
    FDesignerForm.SetControlsEnabled([btnFrameTop, btnFrameLeft, btnFrameBottom, btnFrameRight, btnSetFrame, btnNoFrame, FBtnBackColor, FBtnFrameColor, FCmbFrameWidth, btnSetFrameStyle],
      RectTypEnabled and (FDesignerForm.Page is TRMReportPage));
  end;
  with FToolbarEdit do
    FDesignerForm.SetControlsEnabled([FBtnFontColor, FcmbFont, FcmbFontSize, btnFontBold,
      btnFontItalic, btnFontUnderline, btnHLeft, btnHRight, btnHCenter, btnHSpaceEqual, btnVTop, btnVBottom, btnVCenter, FBtnHighlight],
        _FontTypEnabled);

  FToolbarAddinTools.Visible := (not THackDesigner(FDesignerForm).IsPreviewDesign);
  FToolbarAddinTools.btnExpression.Enabled := (FDesignerForm.Tab1.TabIndex = 0) or
    ((FDesignerForm.Page is TRMReportPage) and (FDesignerForm.SelNum = 1));
  FToolbarAddinTools.btnDBField.Enabled := FToolbarAddinTools.btnExpression.Enabled;
  with FDesignerForm.ToolbarStandard do
    FDesignerForm.SetControlsEnabled([btnBringtoFront, btnSendtoBack, padBringtoFront, padSendtoBack, GB3], ZEnabled);

  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnCut, padCut, padpopCut], CutEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnCopy, padCopy, padpopCopy], CopyEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnPaste, padPaste, padpopPaste], PasteEnabled);
  FDesignerForm.SetControlsEnabled([padDelete, padpopDelete], DelEnabled);
  FDesignerForm.SetControlsEnabled([padEdit, padpopEdit, padpopClearContents, padpopFrame], EditEnabled);
  FDesignerForm.SetControlsEnabled([padEditReplace], FDesignerForm.Tab1.TabIndex > 0);
  with FToolbarAlign do
  begin
    FDesignerForm.SetControlsEnabled([btnAlignLeft, btnAlignHCenter, btnAlignRight, btnAlignTop, btnAlignVCenter, btnAlignBottom], FDesignerForm.SelNum > 1);
    FDesignerForm.SetControlsEnabled([btnAlignHSE, btnAlignVSE, { btnAlignHWCenter, btnAlignVWCenter,} btnAlignLeftRight, btnAlignTopBottom], FDesignerForm.SelNum > 1);
    FDesignerForm.SetControlsEnabled([btnAlignHWCenter, btnAlignVWCenter], FDesignerForm.SelNum >= 1);
  end;
  with FToolbarSize do
    FDesignerForm.SetControlsEnabled([btnSetWidthToMin, btnSetWidthToMax, btnSetHeightToMin, btnSetHeightToMax], FDesignerForm.SelNum > 1);

  FToolbarAddinTools.btnInsertFields.Down := FDesignerForm.FieldForm.Visible;
  Pan9.Checked := FToolbarAddinTools.btnInsertFields.Down;
  FToolbarAddinTools.btnInsertFields.Enabled := (FDesignerForm.Tab1.TabIndex > 0);
  FDesignerForm.ToolbarStandard.cmbScale.Enabled := (FDesignerForm.Page is TRMReportPage);
  FDesignerForm.ToolbarStandard.GB1.Down := FDesignerForm.ShowGrid;
  FDesignerForm.ToolbarStandard.GB2.Down := FDesignerForm.GridAlign;
  with FDesignerForm.ToolbarStandard do
    FDesignerForm.SetControlsEnabled([GB1, GB2, btnBringtoFront, btnSendtoBack, btnSelectAll], (FDesignerForm.Tab1.TabIndex > 0));

  FDesignerForm.StatusBar1.Repaint;
  PBox1Paint(nil);
end;

procedure TRMReportPageEditor.Editor_BtnUndoClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanUndo then
    begin
      FDesignerForm.CodeMemo.RMUndo;
      FDesignerForm.ShowPosition;
    end;
  end
  else if FDesignerForm.UndoBufferLength > 0 then
    Undo(@FDesignerForm.UndoBuffer);
end;

procedure TRMReportPageEditor.Editor_BtnRedoClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanRedo then
    begin
      FDesignerForm.CodeMemo.RMRedo;
      FDesignerForm.ShowPosition;
    end;
  end
  else if FDesignerForm.RedoBufferLength > 0 then
    Undo(@FDesignerForm.RedoBuffer);
end;

type
  TRMUndoObject = class(TObject)
  private
    FAryObjID: array of Integer;
  protected
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TRMUndoObject.Create;
begin
  inherited Create;

  SetLength(FAryObjID, 0);
end;

destructor TRMUndoObject.Destroy;
begin
  SetLength(FAryObjID, 0);

  inherited Destroy;
end;

procedure TRMReportPageEditor.Editor_AddUndoAction(aAction: TRMUndoAction);
var
  i: Integer;
  t: TRMView;
  lList: TList;
begin
  if (RMDesignerComp <> nil) and (not RMDesignerComp.UseUndoRedo) then Exit;

  FDesignerForm.ClearRedoBuffer;
  lList := TList.Create;
  try
    for i := 0 to FDesignerForm.Objects.Count - 1 do
    begin
      t := FDesignerForm.Objects[i];
      if (t.Selected or (aAction = rmacZOrder)) and (not THackView(t).DontUndo) then
      begin
        if (aAction = rmacDelete) and (t.Restrictions * [rmrtDontDelete] = []) then
          lList.Add(t)
        else
          lList.Add(t);
      end;
    end;

    if lList.Count > 0 then
      AddAction(@FDesignerForm.UndoBuffer, aAction, lList)
  finally
    lList.Free;
  end;
end;

procedure TRMReportPageEditor.AddAction(aBuffer: PRMUndoBuffer;
  aAction: TRMUndoAction; aList: TList);

  procedure _SelectionToMemStream(aStream: TMemoryStream);
  var
    i: Integer;
    t: TRMView;
  begin
    RMWriteInt32(aStream, aList.Count);
    for i := 0 to aList.Count - 1 do
    begin
      t := aList[i];
      THackView(t).StreamMode := rmsmDesigning;
      RMWriteByte(aStream, t.ObjectType);
      RMWriteString(aStream, t.ClassName);
      t.SaveToStream(aStream);
    end;
  end;

var
  i: Integer;
  lBufferLength: Integer;
  lAddUndoObj: TRMUndoObject;
begin
  if FUndoBusy then Exit;

  FUndoBusy := True;
  if aBuffer = @FDesignerForm.UndoBuffer then
    lBufferLength := FDesignerForm.UndoBufferLength
  else
    lBufferLength := FDesignerForm.RedoBufferLength;

  if lBufferLength >= RM_MaxUndoBuffer then
  begin
    FDesignerForm.ReleaseAction(@aBuffer[0]);
    for i := 0 to RM_MaxUndoBuffer - 2 do
      aBuffer^[i] := aBuffer^[i + 1];

    lBufferLength := RM_MaxUndoBuffer - 1;
    aBuffer[lBufferLength].Stream := nil;
    aBuffer[lBufferLength].AddObj := nil;
  end;

  aBuffer[lBufferLength].Action := aAction;
  aBuffer[lBufferLength].Page := FDesignerForm.CurPage;
  if aBuffer[lBufferLength].AddObj = nil then
  begin
    lAddUndoObj := TRMUndoObject.Create;
    aBuffer[lBufferLength].AddObj := lAddUndoObj;
    SetLength(lAddUndoObj.FAryObjID, aList.Count);
  end
  else
    SetLength(TRMUndoObject(aBuffer[lBufferLength].AddObj).FAryObjID, aList.Count);

  for i := 0 to aList.Count - 1 do
    TRMUndoObject(aBuffer[lBufferLength].AddObj).FAryObjID[i] := THackView(aList[i]).ObjectID;

  case aAction of
    rmacInsert:
      begin
      end;
    rmacDelete, rmacEdit:
      begin
        aBuffer[lBufferLength].Stream := TMemoryStream.Create;
        _SelectionToMemStream(aBuffer[lBufferLength].Stream);
      end;
    rmacZOrder:
      begin
      end;
  end;

  if aBuffer = @FDesignerForm.UndoBuffer then
  begin
    FDesignerForm.UndoBufferLength := lBufferLength + 1;
  end
  else
  begin
    FDesignerForm.RedoBufferLength := lBufferLength + 1;
  end;

  FDesignerForm.Modified := True;
  FUndoBusy := False;
end;

procedure TRMReportPageEditor.Undo(aBuffer: PRMUndoBuffer);
var
  i: Integer;
  lBufferLength: Integer;
  lUndoObject: TRMUndoObject;

  function _FindObjectByID(aID: Integer): Integer;
  var
    i: Integer;
    t: TRMView;
  begin
    Result := -1;
    for i := 0 to THackPage(FDesignerForm.Page).Objects.Count - 1 do
    begin
      t := THackPage(FDesignerForm.Page).Objects[i];
      if THackView(t).ObjectID = aID then
      begin
        Result := i;
        Break;
      end;
    end;
  end;

  procedure _LoadObjects(aStream: TMemoryStream);
  var
    i, lCount: Integer;
    t: TRMView;
    lType: Byte;
    lHaveBand: Boolean;
  begin
    lHaveBand := False;
    aStream.Position := 0;
    lCount := RMReadInt32(aStream);
    for i := 0 to lCount - 1 do
    begin
      lType := RMReadByte(aStream);
      t := RMCreateObject(lType, RMReadString(aStream));
      t.NeedCreateName := False;
      THackView(t).StreamMode := rmsmDesigning;
      t.LoadFromStream(aStream);
      t.ParentPage := FDesignerForm.Page;
      if t.IsBand then lHaveBand := True;
    end;

    if lHaveBand then
    begin
      SendBandsToDown;
    end;
  end;

  procedure _AssignObjects(aStream: TMemoryStream);
  var
    i, lCount: Integer;
    t: TRMView;
  begin
    aStream.Position := 0;
    lCount := RMReadInt32(aStream);
    for i := 0 to lCount - 1 do
    begin
      RMReadByte(aStream);
      RMReadString(aStream);
      t := FDesignerForm.Objects[_FindObjectByID(TRMUndoObject(aBuffer[lBufferLength - 1].AddObj).FAryObjId[i])];
      t.NeedCreateName := False;
      THackView(t).StreamMode := rmsmDesigning;
      t.LoadFromStream(aStream);
    end;
  end;

  procedure _SetUndo(isDeleteAction: Boolean);
  var
    i: Integer;
    lList: TList;
    lAction: TRMUndoAction;
    lUndoObject: TRMUndoObject;
  begin
    lList := TList.Create;
    try
      lAction := rmacEdit;
      case aBuffer[lBufferLength - 1].Action of
        rmacInsert:
          begin
            lAction := rmacDelete;
            lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
            for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
              lList.Add(FDesignerForm.Objects[_FindObjectByID(lUndoObject.FAryObjID[i])]);
          end;
        rmacDelete:
          begin
            lAction := rmacInsert;
            lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
            if isDeleteAction then
            begin
              for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
                lList.Add(FDesignerForm.Objects[_FindObjectByID(lUndoObject.FAryObjID[i])]);
            end;
          end;
        rmacEdit:
          begin
            lAction := rmacEdit;
            lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
            for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
              lList.Add(FDesignerForm.Objects[_FindObjectByID(lUndoObject.FAryObjID[i])]);
          end;
        rmacZOrder:
          begin
            lAction := rmacZOrder;
            lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
            for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
              lList.Add(FDesignerForm.Objects[_FindObjectByID(lUndoObject.FAryObjID[i])]);
          end;
      end;

      if aBuffer = @FDesignerForm.UndoBuffer then
        AddAction(@FDesignerForm.RedoBuffer, lAction, lList)
      else
        AddAction(@FDesignerForm.UndoBuffer, lAction, lList);
    finally
      lList.Free;
    end;

  end;

begin
  if (RMDesignerComp <> nil) and (not RMDesignerComp.UseUndoRedo) then Exit;

  if aBuffer = @FDesignerForm.UndoBuffer then
    lBufferLength := FDesignerForm.UndoBufferLength
  else
    lBufferLength := FDesignerForm.RedoBufferLength;

  if aBuffer[lBufferLength - 1].Page <> FDesignerForm.CurPage then Exit;

  FWorkSpace.CurrentView := nil;
  if aBuffer[lBufferLength - 1].Action <> rmacDelete then
    _SetUndo(False);

  case aBuffer[lBufferLength - 1].Action of
    rmacInsert:
      begin
        lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
        for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
        begin
          FDesignerForm.Page.Delete(_FindObjectByID(lUndoObject.FAryObjID[i]));
        end;
      end;
    rmacDelete:
      begin
        _LoadObjects(aBuffer[lBufferLength - 1].Stream);
      end;
    rmacEdit:
      begin
        _AssignObjects(aBuffer[lBufferLength - 1].Stream);
      end;
    rmacZOrder:
      begin
        lUndoObject := TRMUndoObject(aBuffer[lBufferLength - 1].AddObj);
        for i := Low(lUndoObject.FAryObjID) to High(lUndoObject.FAryObjID) do
        begin
          FDesignerForm.Objects[i] := FDesignerForm.Objects[_FindObjectByID(lUndoObject.FAryObjID[i])];
        end;
      end;
  end;

  if aBuffer[lBufferLength - 1].Action = rmacDelete then
    _SetUndo(True);

  FDesignerForm.ReleaseAction(@aBuffer[lBufferLength - 1]);
  if aBuffer = @FDesignerForm.UndoBuffer then
    FDesignerForm.UndoBufferLength := FDesignerForm.UndoBufferLength - 1
  else
    FDesignerForm.RedoBufferLength := FDesignerForm.RedoBufferLength - 1;

  FDesignerForm.ResetSelection;
  FDesignerForm.RedrawPage;
end;

procedure TRMReportPageEditor.Editor_OnInspAfterModify(Sender: TObject;
  const aPropName, aPropValue: string);
begin
  if FDesignerForm.InspForm.Insp.Objects[0] is TRMDialogPage then
  begin
    FWorkSpace.PageForm.SetPageFormProp;
  end
  else if FDesignerForm.InspForm.Insp.Objects[0] is TRMCustomBandView then
  begin
  end;

  if AnsiCompareText(aPropName, 'Name') = 0 then
  begin
    FDesignerForm.InspForm.SetCurrentObject(FDesignerForm.InspForm.Insp.Objects[0].ClassName, aPropValue);
  end;

  FDesignerForm.Modified := True;
  FDesignerForm.RedrawPage;
  FDesignerForm.SetPageTabs;
  FDesignerForm.StatusBar1.Repaint;
  PBox1Paint(nil);
  Editor_SelectionChanged(False);
  if FDesignerForm.FieldForm.Visible then
    FDesignerForm.FieldForm.RefreshData;
end;

procedure TRMReportPageEditor.Editor_BtnDeletePageClick(Sender: TObject);

  procedure _AlignmentSubReports(aPageNo: Integer);
  var
    i, j: Integer;
    t: TRMView;
  begin
    with FDesignerForm.Report do
    begin
      for i := 0 to Pages.Count - 1 do
      begin
        j := 0;
        while j < THackPage(Pages[i]).Objects.Count do
        begin
          t := THackPage(Pages[i]).Objects[j];
          if t.ObjectType = rmgtSubReport then
          begin
            if TRMSubReportView(t).SubPage = aPageNo then
            begin
              Pages[i].Delete(j);
              Dec(j);
            end
            else if TRMSubReportView(t).SubPage > aPageNo then
              TRMSubReportView(t).SubPage := TRMSubReportView(t).SubPage - 1;
          end;
          Inc(j);
        end;
      end;
    end;
  end;

  procedure _RemovePage(aPageNo: Integer);
  begin
    FDesignerForm.Modified := True;
    with FDesignerForm.Report do
    begin
      if (aPageNo >= 0) and (aPageNo < Pages.Count) then
      begin
        if Pages.Count = 1 then
          Pages[aPageNo].Clear
        else
        begin
          FDesignerForm.Report.Pages.Delete(aPageNo);
          FDesignerForm.Tab1.Tabs.Delete(aPageNo + 1);
          _AlignmentSubReports(aPageNo);

          FDesignerForm.CurPage := 0;
        end;
      end;
    end;
  end;

begin
  if FDesignerForm.DesignerRestrictions * [rmdrDontDeletePage] <> [] then Exit;

  if FDesignerForm.Report.Pages.Count > 1 then
  begin
    if Application.MessageBox(PChar(RMLoadStr(SRemovePg)),
      PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNo) = mrYes then
    begin
      _RemovePage(FDesignerForm.CurPage);
    end;
  end;
end;

procedure TRMReportPageEditor.Editor_BeforeFormDestroy;
begin
  FWorkSpace.DisableDraw := True;
  FWorkSpace.CurrentView := nil;
end;

procedure TRMReportPageEditor.Editor_Localize;
begin
  Localize;
end;

initialization
  CF_REPORTMACHINE := RegisterClipboardFormat('WHF_ReportMachine');

  RMRegisterPageEditor(TRMReportPage, TRMReportPageEditor);
  RMRegisterPageButton(RMLoadStr(rmRes + 099), '13', True, 'TRMReportPage');

  RMRegisterPageEditor(TRMDialogPage, TRMReportPageEditor);
  RMRegisterPageButton(RMLoadStr(rmRes + 193), '14', False, '');

end.

