unit RM_DsgGridReport;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus, Commctrl, Clipbrd, Buttons,
  RM_Class, RM_Preview, RM_Common, RM_DsgCtrls, RM_Ctrls,
  RM_GridReport, RM_Grid, RM_Designer, rm_ZlibEx
{$IFDEF USE_TB2K}
  , TB2Item, TB2Dock, TB2Toolbar
{$ELSE}
{$IFDEF USE_INTERNALTB97}
  , RM_TB97Ctls, RM_TB97Tlbr, RM_TB97
{$ELSE}
  , TB97Ctls, TB97Tlbr, TB97
{$ENDIF}
{$ENDIF}
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMGridReportDesigner = class(TRMCustomDesigner);

  TRMGridReportPageEditor = class;

  { TRMToolbarEdit }
  TRMToolbarEdit = class(TRMToolbar)
  private
    FPageEditor: TRMGridReportPageEditor;
    FcmbFont: TRMFontComboBox;
    FcmbFontSize: TRMComboBox97;
    ToolbarSep971: TRMToolbarSep;

    btnFontBold: TRMToolbarButton;
    btnFontItalic: TRMToolbarButton;
    btnFontUnderline: TRMToolbarButton;
    ToolbarSep972: TRMToolbarSep;

    FBtnFontColor: TRMColorPickerButton;
    FBtnBackColor: TRMColorPickerButton;
    FBtnFrameColor: TRMColorPickerButton;
    FCmbFrameWidth: TRMComboBox97;
    ToolbarSep973: TRMToolbarSep;

    FBtnHighlight: TRMToolbarButton;
    ToolbarSep975: TRMToolbarSep;

    btnHLeft: TRMToolbarButton;
    btnHCenter: TRMToolbarButton;
    btnHRight: TRMToolbarButton;
    btnHSpaceEqual: TRMToolbarButton;
    ToolbarSep974: TRMToolbarSep;

    btnVTop: TRMToolbarButton;
    btnVCenter: TRMToolbarButton;
    btnVBottom: TRMToolbarButton;

    procedure Localize;
    procedure BtnHighlightClick(Sender: TObject);
  public
    constructor CreateAndDock(aOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarBorder }
  TRMToolbarBorder = class(TRMToolbar)
  private
    FPageEditor: TRMGridReportPageEditor;
    btnFrameTop: TRMToolbarButton;
    btnFrameLeft: TRMToolbarButton;
    btnFrameBottom: TRMToolbarButton;
    btnFrameRight: TRMToolbarButton;
    ToolbarSep971: TRMToolbarSep;

    btnNoBorder: TRMToolbarButton;
    btnSetBorder: TRMToolbarButton;
    btnTopBorder: TRMToolbarButton;
    btnBottomBorder: TRMToolbarButton;
    ToolbarSep972: TRMToolbarSep;

    btnBias1Border: TRMToolbarButton;
    btnBias2Border: TRMToolbarButton;
    ToolbarSep973: TRMToolbarSep;

    btnDecWidth: TRMToolbarButton;
    btnIncWidth: TRMToolbarButton;
    btnDecHeight: TRMToolbarButton;
    btnIncHeight: TRMToolbarButton;
    ToolbarSep974: TRMToolbarSep;

    btnColumnMin: TRMToolbarButton;
    btnColumnMax: TRMToolbarButton;
    btnRowMin: TRMToolbarButton;
    btnRowMax: TRMToolbarButton;
    ToolbarSep975: TRMToolbarSep;

    cmbBands: TRMComboBox97;
{$IFDEF USE_TB2K}
    btnAddBand: TRMSubmenuItem;
{$ELSE}
    btnAddBand: TRMToolbarButton;
{$ENDIF}
{$IFDEF USE_TB2K}
    btnDeleteBand: TRMSubmenuItem;
{$ELSE}
    btnDeleteBand: TRMToolbarButton;
{$ENDIF}

    procedure Localize;
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarGrid }
  TRMToolbarGrid = class(TRMToolbar)
  private
    FPageEditor: TRMGridReportPageEditor;
    btnInsertColumn: TRMToolbarButton;
    btnInsertRow: TRMToolbarButton;
    btnAddColumn: TRMToolbarButton;
    btnAddRow: TRMToolbarButton;
    ToolbarSep1: TRMToolbarSep;

    btnDeleteColumn: TRMToolbarButton;
    btnDeleteRow: TRMToolbarButton;
    btnSetRowsAndColumns: TRMToolbarButton;
    ToolbarSep2: TRMToolbarSep;

    btnMerge: TRMToolbarButton;
    btnSplit: TRMToolbarButton;
    btnMergeRow: TRMToolbarButton;
    btnMergeColumn: TRMToolbarButton;

    procedure Localize;
    procedure OnAddColumnClick(Sender: TObject);
    procedure OnAddRowClick(Sender: TObject);
    procedure OnMergeColumnClick(Sender: TObject);
    procedure OnMergeRowClick(Sender: TObject);
    procedure OnBtnSetRowsAndColumnsClick(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarCellEdit }
  TRMToolbarCellEdit = class(TRMToolbar)
  private
    FPageEditor: TRMGridReportPageEditor;

    FBtnDBField: TRMToolbarButton;
    FBtnExpression: TRMToolbarButton;
    FEdtMemo: TEdit;

    procedure Localize;
    procedure CellEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMGridReportPageEditor }
  TRMGridReportPageEditor = class(TRMCustomPageEditor)
  private
    FPageObjectList: TList;
    FDesignerForm: TRMDesignerForm;
    FGrid: TRMGridEx;
    FAddinObjects: TStringList;
    FPageStream: TMemoryStream;
    FUndoBusy: Boolean;
    FFieldListBox: TListBox;

    Panel2: TRMPanel;
    ToolbarEdit: TRMToolbarEdit;
    ToolbarBorder: TRMToolbarBorder;
    ToolbarGrid: TRMToolbarGrid;
    ToolbarCellEdit: TRMToolbarCellEdit;
    FPopupMenuBands: TRMPopupMenu;
    FPopupMenuDeleteBands: TRMPopupMenu;

    // Grid 右键菜单
    FSelectionMenu: TRMPopupMenu;
    itmGridMenuBandProp: TRMMenuItem;
    itmCellProp: TRMMenuItem;
//    itmSplit1: TRMSeparatorMenuItem;
    itmMergeCells: TRMMenuItem;
    itmSplitCells: TRMMenuItem;
    N3: TRMSeparatorMenuItem;
    itmInsert: TRMSubmenuItem;
    itmInsertLeftColumn: TRMMenuItem;
    itmInsertRightColumn: TRMMenuItem;
    N10: TRMSeparatorMenuItem;
    itmInsertTopRow: TRMMenuItem;
    itmInsertBottomRow: TRMMenuItem;
    itmSep1: TRMSeparatorMenuItem;
    itmInsertLeftCell: TRMMenuItem;
    itmInsertTopCell: TRMMenuItem;
    itmDelete: TRMSubmenuItem;
    itmDeleteColumn: TRMMenuItem;
    itmDeleteRow: TRMMenuItem;
    itmDeleteSep1: TRMSeparatorMenuItem;
    itmDeleteLeftCell: TRMMenuItem;
    itmDeleteTopCell: TRMMenuItem;
    N6: TRMSeparatorMenuItem;
    itmCellType: TRMSubmenuItem;
    itmMemoView: TRMMenuItem;
    itmCalcMemoView: TRMMenuItem;
    itmPictureView: TRMMenuItem;
    itmSubReportView: TRMMenuItem;
    itmInsertBand: TRMSubmenuItem;
    itmSelectBand: TRMSubmenuItem;
    N4: TRMSeparatorMenuItem;
    itmFrameType: TRMMenuItem;
    itmEdit: TRMMenuItem;
    padpopClearContents: TRMMenuItem;
    padpopOtherProp: TRMMenuItem;
    N100: TRMSeparatorMenuItem;
    SelectionMenu_popCut: TRMMenuItem;
    SelectionMenu_popCopy: TRMMenuItem;
    SelectionMenu_popPaste: TRMMenuItem;
//    N101: TRMSeparatorMenuItem;
    N102: TRMSeparatorMenuItem;

    // 主菜单
    FMainMenu: TRMMenuBar;
    MenuEdit: TRMSubmenuItem;
    MenuEditUndo: TRMMenuItem;
    MenuEditRedo: TRMMenuItem;
    N12: TRMSeparatorMenuItem;
    MenuEditCut: TRMMenuItem;
    MenuEditCopy: TRMMenuItem;
    MenuEditPaste: TRMMenuItem;
    MenuEditDelete: TRMMenuItem;
    MenuEditSelectAll: TRMMenuItem;
    N11: TRMSeparatorMenuItem;
    MenuEditCopyPage: TRMMenuItem;
    MenuEditPastePage: TRMMenuItem;

    MenuCell: TRMSubmenuItem;
    MenuCellProperty: TRMMenuItem;
    MenuCellTableSize: TRMMenuItem;
    MenuCellRow: TRMSubmenuItem;
    itmRowHeight: TRMMenuItem;
    itmAverageRowHeight: TRMMenuItem;
    MenuCellColumn: TRMSubmenuItem;
    itmColumnHeight: TRMMenuItem;
    itmAverageColumnWidth: TRMMenuItem;
    N8: TRMSeparatorMenuItem;
    MenuCellInsertCell: TRMSubmenuItem;
    itmInsertCellLeft: TRMMenuItem;
    itmInsertCellTop: TRMMenuItem;
    MenuCellInsertColumn: TRMMenuItem;
    MenuCellInsertRow: TRMMenuItem;
    MenuCellDeleteColumn: TRMMenuItem;
    MenuCellDeleteRow: TRMMenuItem;
    N18: TRMSeparatorMenuItem;
    MenuCellMerge: TRMMenuItem;
    MenuCellReverse: TRMMenuItem;

    MenuEditToolbar: TRMSubmenuItem;
    padSetToolbar: TRMSubmenuItem;
    itmToolbarStandard: TRMMenuItem;
    itmToolbarText: TRMMenuItem;
    itmToolbarBorder: TRMMenuItem;
    itmToolbarGrid: TRMMenuItem;
    itmToolbarInspector: TRMMenuItem;
    itmToolbarInsField: TRMMenuItem;
    itmToolbarCellEdit: TRMMenuItem;
    padAddTools: TRMmenuItem;
    MenuEditOptions: TRMMenuItem;
    // 主菜单结束

    function GetUnitType: TRMUnitType;
    procedure SetUnitType(aValue: TRMUnitType);

    procedure Localize;
    procedure SetGridProp;
    procedure SetGridNilProp;
    procedure RefreshProp;
    procedure SetGridHeader;

    procedure OnFieldListBoxClick(Sender: TObject);
    procedure OnFieldListBoxDrawItem(aControl: TWinControl; aIndex: Integer; aRect: TRect; aState: TOwnerDrawState);
    procedure OnGridDropDownField(aCol, aRow: Integer);
    procedure OnGridDropDownFieldClick(aDropDown: Boolean; X, Y: Integer);
    procedure OnGridDblClickEvent(Sender: TObject);
    procedure OnGridClick(Sender: TObject);
    procedure OnGridChange(Sender: TObject);
    procedure OnGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OnGridDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure OnGridRowHeaderClick(Sender: TObject; X, Y: Integer);
    procedure OnGridRowHeaderDblClick(Sender: TObject);
    procedure OnGridBeginSizingCell(Sender: TObject);
    procedure OnGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnGridBeforeChangeCell(aGrid: TRMGridEx; aCell: TRMCellInfo);

    procedure SelectionMenuPopup(Sender: TObject);
    procedure itmInsertLeftColumnClick(Sender: TObject);
    procedure itmInsertTopRowClick(Sender: TObject);
    procedure itmDeleteColumnClick(Sender: TObject);
    procedure itmDeleteRowClick(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure btnSplitClick(Sender: TObject);
    procedure btnDBFieldClick(Sender: TObject);
    procedure btnExpressionClick(Sender: TObject);
    procedure btnColumnMinClick(Sender: TObject);
    procedure btnColumnMaxClick(Sender: TObject);
    procedure btnRowMinClick(Sender: TObject);
    procedure btnRowMaxClick(Sender: TObject);
    procedure cmbBandsDropDown(Sender: TObject);
    procedure cmbBandsClick(Sender: TObject);
    procedure btnDeleteBandClick(Sender: TObject);
    procedure PopupMenuBandsPopup(Sender: TObject);
    procedure PopupMenuDeleteBandsPopup(Sender: TObject);
    procedure DeleteOneBand(aBandName: string; aBand: TRMView);
    function HaveBand(aBandType: TRMBandType): Boolean;
    procedure OnDeleteBandEvent(Sender: TObject);
    procedure OnAddBandEvent(Sender: TObject);
    procedure MenuCellPropertyClick(Sender: TObject);
    procedure itmInsertRightColumnClick(Sender: TObject);
    procedure itmInsertBottomRowClick(Sender: TObject);
    procedure itmInsertLeftCellClick(Sender: TObject);
    procedure itmInsertTopCellClick(Sender: TObject);
    procedure itmDeleteLeftCellClick(Sender: TObject);
    procedure itmDeleteTopCellClick(Sender: TObject);
    procedure itmMemoViewClick(Sender: TObject);
    procedure itmFrameTypeClick(Sender: TObject);
    procedure itmEditClick(Sender: TObject);
    procedure padpopClearContentsClick(Sender: TObject);
    procedure itmGridMenuBandClick(Sender: TObject);
    procedure Pan5Click(Sender: TObject);
    procedure MenuEditDeleteClick(Sender: TObject);
    procedure MenuEditSelectAllClick(Sender: TObject);
    procedure MenuEditCopyPageClick(Sender: TObject);
    procedure MenuEditPastePageClick(Sender: TObject);
    procedure MenuCellTableSizeClick(Sender: TObject);
    procedure itmRowHeightClick(Sender: TObject);
    procedure itmAverageRowHeightClick(Sender: TObject);
    procedure itmColumnHeightClick(Sender: TObject);
    procedure itmAverageColumnWidthClick(Sender: TObject);
    procedure SaveIni;
    procedure LoadIni;
    procedure itmToolbarStandardClick(Sender: TObject);
    procedure MenuEditOptionsClick(Sender: TObject);
    procedure MenuEditToolbarClick(Sender: TObject);
    function _GetSelectionStatus: TRMSelectionStatus;
    function _DelEnabled: Boolean;
    function _CutEnabled: Boolean;
    function _CopyEnabled: Boolean;
    function _PasteEnabled: Boolean;
    procedure SetBandMenuItemEnable(aMenuItem: TRMMenuItem);
  protected
    procedure Undo(aBuffer: PRMUndoBuffer);
    procedure AddAction(aBuffer: PRMUndoBuffer; aAction: TRMUndoAction;
      aObject: TObject; aRec: PRMUndoRec);
  public
    constructor CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm); override;
    destructor Destroy; override;

    procedure Editor_BtnUndoClick(Sender: TObject); override;
    procedure Editor_BtnRedoClick(Sender: TObject); override;
    procedure Editor_AddUndoAction(aAction: TRMUndoAction); override;

    procedure Editor_BeforeFormDestroy; override;
    procedure Editor_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure Editor_DisableDraw; override;
    procedure Editor_EnableDraw; override;
    procedure Editor_RedrawPage; override;
    procedure Editor_Resize; override;
    procedure Editor_Init; override;
    procedure Editor_EnableControls; override;
    procedure Editor_SetCurPage; override;
    procedure Editor_SelectionChanged(aRefreshInspProp: Boolean); override;
    function Editor_PageObjects: TList; override;
    procedure Editor_ShowContent; override;
    procedure Editor_ShowPosition; override;
    procedure Editor_FillInspFields; override;
    procedure Editor_OnInspGetObjects(aList: TStrings); override;
    procedure Editor_OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string); override;
    procedure Editor_DoClick(Sender: TObject); override;
    procedure Editor_SelectObject(aObjName: string); override;
    procedure Editor_SetObjectsID; override;
    procedure Editor_BtnDeletePageClick(Sender: TObject); override;
    procedure Editor_BtnCutClick(Sender: TObject); override;
    procedure Editor_BtnCopyClick(Sender: TObject); override;
    procedure Editor_BtnPasteClick(Sender: TObject); override;
    procedure Editor_MenuFilePreview1Click(Sender: TObject); override;
    procedure Editor_MenuFileHeaderFooterClick(Sender: TObject); override;

    property UnitType: TRMUnitType read GetUnitType write SetUnitType;
  published
  end;

implementation

uses
  Math, Registry, RM_Const, RM_Const1, RM_Utils, RM_EditorMemo,
  RM_EditorPicture, RM_EditorHilit, RM_EditorFrame, RM_EditorField, RM_EditorExpr,
  RM_Printer, RM_EditorFormat, RM_EditorCalc, RM_EditorGroup, RM_EditorBand,
  RM_DesignerOptions,
  RM_EditorCellProp, RM_EditorGridCols, RM_EditorCellWidth, RM_EditorHF,
  RM_wzGridStd;

const
  RM_AddInObjectOffset = 4;

type
  THackView = class(TRMView)
  end;

  THackReportView = class(TRMReportView)
  end;

  THackPage = class(TRMCustomPage)
  end;

  THackGridEx = class(TRMGridEx)
  end;

  THackDesigner = class(TRMDesignerForm)
  end;

var
  FUnitType: TRMUnitType;

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
  FPageEditor := TRMGridReportPageEditor(AOwner);
  DockRow := 1;
  DockPos := 0;
  Name := 'GridReport_ToolbarEdit';
  CloseButton := False;
  ParentForm := FPageEditor.FDesignerForm;

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
  FBtnBackColor := TRMColorPickerButton.Create(Self);
  with FBtnBackColor do
  begin
    Parent := Self;
    Tag := TAG_BackColor;
    ParentShowHint := True;
    ColorType := rmptFill;
    OnColorChange := FPageEditor.FDesignerForm.DoClick;
  end;
  FBtnFrameColor := TRMColorPickerButton.Create(Self);
  with FBtnFrameColor do
  begin
    Parent := Self;
    Tag := TAG_FrameColor;
    ParentShowHint := True;
    ColorType := rmptLine; //rmptHighlight;
    OnColorChange := FPageEditor.FDesignerForm.DoClick;
  end;
  FCmbFrameWidth := TRMComboBox97.Create(Self);
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

    OnClick := FPageEditor.FDesignerForm.DoClick;
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
    Images := FPageEditor.FDesignerForm.ImageListFont;
    OnClick := BtnHighlightClick;
    AddTo := Self;
  end;
  ToolbarSep975 := TRMToolbarSep.Create(Self);
  with ToolbarSep975 do
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

//  EndUpdate;
  Localize;
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
  RMSetStrProp(FBtnFrameColor, 'Hint', rmRes + 210);
  RMSetStrProp(FBtnBackColor, 'Hint', rmRes + 209);
  RMSetStrProp(FCmbFrameWidth, 'Hint', rmRes + 194);
  RMSetStrProp(FBtnHighlight, 'Hint', rmRes + 119);
end;

procedure TRMToolbarEdit.BtnHighlightClick(Sender: TObject);
var
  t: TRMView;
  tmp: TRMHilightForm;
begin
  t := FPageEditor.FDesignerForm.PageObjects[FPageEditor.FDesignerForm.TopSelected];
  if t = nil then Exit;
  if not (t is TRMCustomMemoView) then Exit;

  tmp := TRMHilightForm.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarGrid }

constructor TRMToolbarGrid.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMGridReportPageEditor(AOwner);
  DockRow := 3;
  DockPos := 0;
  Name := 'GridReport_ToolbarGrid';
  CloseButton := False;
  ParentForm := FPageEditor.FDesignerForm;

  btnInsertColumn := TRMToolbarButton.Create(Self);
  with btnInsertColumn do
  begin
    ImageIndex := 29;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.itmInsertLeftColumnClick;
    AddTo := Self;
  end;
  btnInsertRow := TRMToolbarButton.Create(Self);
  with btnInsertRow do
  begin
    ImageIndex := 30;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.itmInsertTopRowClick;
    AddTo := Self;
  end;
  btnAddColumn := TRMToolbarButton.Create(Self);
  with btnAddColumn do
  begin
    ImageIndex := 31;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := OnAddColumnClick;
    AddTo := Self;
  end;
  btnAddRow := TRMToolbarButton.Create(Self);
  with btnAddRow do
  begin
    ImageIndex := 32;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := OnAddRowClick;
    AddTo := Self;
  end;
  ToolbarSep1 := TRMToolbarSep.Create(Self);
  with ToolbarSep1 do
  begin
    AddTo := Self;
  end;

  btnDeleteColumn := TRMToolbarButton.Create(Self);
  with btnDeleteColumn do
  begin
    ImageIndex := 33;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.itmDeleteColumnClick;
    AddTo := Self;
  end;
  btnDeleteRow := TRMToolbarButton.Create(Self);
  with btnDeleteRow do
  begin
    ImageIndex := 34;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.itmDeleteRowClick;
    AddTo := Self;
  end;
  btnSetRowsAndColumns := TRMToolbarButton.Create(Self);
  with btnSetRowsAndColumns do
  begin
    ImageIndex := 39;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := OnBtnSetRowsAndColumnsClick;
    AddTo := Self;
  end;
  ToolbarSep2 := TRMToolbarSep.Create(Self);
  with ToolbarSep2 do
  begin
    AddTo := Self;
  end;

  btnMerge := TRMToolbarButton.Create(Self);
  with btnMerge do
  begin
    ImageIndex := 35;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.btnMergeClick;
    AddTo := Self;
  end;
  btnSplit := TRMToolbarButton.Create(Self);
  with btnSplit do
  begin
    ImageIndex := 36;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.btnSplitClick;
    AddTo := Self;
  end;
  btnMergeColumn := TRMToolbarButton.Create(Self);
  with btnMergeColumn do
  begin
    ImageIndex := 37;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := OnMergeColumnClick;
    AddTo := Self;
  end;
  btnMergeRow := TRMToolbarButton.Create(Self);
  with btnMergeRow do
  begin
    ImageIndex := 38;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := OnMergeRowClick;
    AddTo := Self;
  end;

//  EndUpdate;
  Localize;
end;

procedure TRMToolbarGrid.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 244);
  RMSetStrProp(btnInsertColumn, 'Hint', rmRes + 236);
  RMSetStrProp(btnInsertRow, 'Hint', rmRes + 237);
  RMSetStrProp(btnAddColumn, 'Hint', rmRes + 238);
  RMSetStrProp(btnAddRow, 'Hint', rmRes + 239);
  RMSetStrProp(btnDeleteColumn, 'Hint', rmRes + 240);
  RMSetStrProp(btnDeleteRow, 'Hint', rmRes + 241);
  RMSetStrProp(btnMerge, 'Hint', rmRes + 805);
  RMSetStrProp(btnSplit, 'Hint', rmRes + 806);
  RMSetStrProp(btnMergeColumn, 'Hint', rmRes + 242);
  RMSetStrProp(btnMergeRow, 'Hint', rmRes + 243);
  RMSetStrProp(btnSetRowsAndColumns, 'Hint', rmRes + 693);
end;

procedure TRMToolbarGrid.OnAddColumnClick(Sender: TObject);
begin
  FPageEditor.Editor_AddUndoAction(rmacChangeGrid);
  FPageEditor.FDesignerForm.Modified := True;
  FPageEditor.FGrid.ColCount := FPageEditor.FGrid.ColCount + 1;
end;

procedure TRMToolbarGrid.OnAddRowClick(Sender: TObject);
begin
  FPageEditor.Editor_AddUndoAction(rmacChangeGrid);
  FPageEditor.FDesignerForm.Modified := True;
  FPageEditor.FGrid.RowCount := FPageEditor.FGrid.RowCount + 1;
end;

procedure TRMToolbarGrid.OnMergeColumnClick(Sender: TObject);
var
  i: Integer;
  lRect: TRect;
begin
  FPageEditor.FDesignerForm.Modified := True;
  lRect := FPageEditor.FGrid.Selection;
  for i := lRect.Left to lRect.Right do
  begin
    FPageEditor.FGrid.MergeCell(i, lRect.Top, i, lRect.Bottom);
  end;
end;

procedure TRMToolbarGrid.OnMergeRowClick(Sender: TObject);
var
  i: Integer;
  lRect: TRect;
begin
  FPageEditor.FDesignerForm.Modified := True;
  lRect := FPageEditor.FGrid.Selection;
  for i := lRect.Top to lRect.Bottom do
  begin
    FPageEditor.FGrid.MergeCell(lRect.Left, i, lRect.Right, i);
  end;
end;

procedure TRMToolbarGrid.OnBtnSetRowsAndColumnsClick(Sender: TObject);
var
  lRect: TRect;
begin
  FPageEditor.Editor_AddUndoAction(rmacChangeGrid);
  lRect := FPageEditor.FGrid.Selection;
  FPageEditor.FGrid.RowCount := lRect.Bottom + 1;
  FPageEditor.FGrid.ColCount := lRect.Right + 1;
  FPageEditor.FDesignerForm.Modified := True;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarCellEdit }

constructor TRMToolbarCellEdit.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMGridReportPageEditor(AOwner);
  DockRow := 3;
  DockPos := 100;
  Name := 'GridReport_ToolbarCellEdit';
  CloseButton := True;
  ParentForm := FPageEditor.FDesignerForm;

  FBtnDBField := TRMToolbarButton.Create(Self);
  with FBtnDBField do
  begin
    ImageIndex := 27;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.btnDBFieldClick;
    AddTo := Self;
  end;
  FBtnExpression := TRMToolbarButton.Create(Self);
  with FBtnExpression do
  begin
    ImageIndex := 21;
    Images := FPageEditor.FDesignerForm.ImageListStand;
    OnClick := FPageEditor.btnExpressionClick;
    AddTo := Self;
  end;
  FEdtMemo := TEdit.Create(Self);
  with FEdtMemo do
  begin
    Parent := Self;
    OnKeyUp := CellEditKeyUp;
    Width := 400;
    //    AddTo := Self;
  end;

//  EndUpdate;
  Localize;
end;

procedure TRMToolbarCellEdit.Localize;
begin
  RMSetStrProp(FBtnExpression, 'Hint', rmRes + 701);
  RMSetStrProp(FBtnDBField, 'Hint', rmRes + 62);

  RMSetStrProp(Self, 'Caption', rmRes + 866);
end;

procedure TRMToolbarCellEdit.CellEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FPageEditor.FDesignerForm.BeforeChange;
  FPageEditor.FGrid.Cells[FPageEditor.FGrid.Col, FPageEditor.FGrid.Row].View.Memo.Text := Self.FEdtMemo.Text;
  FPageEditor.FDesignerForm.AfterChange;
  THackGridEx(FPageEditor.FGrid).InvalidateCell(FPageEditor.FGrid.Col, FPageEditor.FGrid.Row);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarBorder }

constructor TRMToolbarBorder.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FPageEditor := TRMGridReportPageEditor(AOwner);
  DockRow := 2;
  DockPos := 0;
  Name := 'GridReport_ToolbarBorder';
  ParentForm := FPageEditor.FDesignerForm;

  btnFrameLeft := TRMToolbarButton.Create(Self);
  with btnFrameLeft do
  begin
    AllowAllUp := True;
    GroupIndex := 2;
    ImageIndex := 11;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_SetFrameLeft;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameRight := TRMToolbarButton.Create(Self);
  with btnFrameRight do
  begin
    AllowAllUp := True;
    GroupIndex := 4;
    ImageIndex := 12;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_SetFrameRight;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameTop := TRMToolbarButton.Create(Self);
  with btnFrameTop do
  begin
    AllowAllUp := True;
    GroupIndex := 1;
    ImageIndex := 13;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_SetFrameTop;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnFrameBottom := TRMToolbarButton.Create(Self);
  with btnFrameBottom do
  begin
    AllowAllUp := True;
    GroupIndex := 3;
    ImageIndex := 14;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_SetFrameBottom;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep971 := TRMToolbarSep.Create(Self);
  with ToolbarSep971 do
  begin
    AddTo := Self;
  end;

  btnNoBorder := TRMToolbarButton.Create(Self);
  with btnNoBorder do
  begin
    ImageIndex := 7;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_NoFrame;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnSetBorder := TRMToolbarButton.Create(Self);
  with btnSetBorder do
  begin
    ImageIndex := 8;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_SetFrame;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnTopBorder := TRMToolbarButton.Create(Self);
  with btnTopBorder do
  begin
    ImageIndex := 10;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_Frame1;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnBottomBorder := TRMToolbarButton.Create(Self);
  with btnBottomBorder do
  begin
    ImageIndex := 9;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_Frame2;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep972 := TRMToolbarSep.Create(Self);
  with ToolbarSep972 do
  begin
    AddTo := Self;
  end;

  btnBias1Border := TRMToolbarButton.Create(Self);
  with btnBias1Border do
  begin
    AllowAllUp := True;
    GroupIndex := 40;
    ImageIndex := 15;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_Frame3;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  btnBias2Border := TRMToolbarButton.Create(Self);
  with btnBias2Border do
  begin
    AllowAllUp := True;
    GroupIndex := 41;
    ImageIndex := 16;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_Frame4;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
  end;
  ToolbarSep973 := TRMToolbarSep.Create(Self);
  with ToolbarSep973 do
  begin
    AddTo := Self;
  end;

  btnDecWidth := TRMToolbarButton.Create(Self);
  with btnDecWidth do
  begin
    ImageIndex := 21;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_DecWidth;
    OnClick := FPageEditor.FDesignerForm.DoClick;
{$IFNDEF USE_TB2k}
    Repeating := True;
{$ENDIF}
    AddTo := Self;
  end;
  btnIncWidth := TRMToolbarButton.Create(Self);
  with btnIncWidth do
  begin
    ImageIndex := 19;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_IncWidth;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
{$IFNDEF USE_TB2k}
    Repeating := True;
{$ENDIF}
  end;
  btnDecHeight := TRMToolbarButton.Create(Self);
  with btnDecHeight do
  begin
    ImageIndex := 18;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_DecHeight;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
{$IFNDEF USE_TB2k}
    Repeating := True;
{$ENDIF}
  end;
  btnIncHeight := TRMToolbarButton.Create(Self);
  with btnIncHeight do
  begin
    ImageIndex := 20;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    Tag := TAG_IncHeight;
    OnClick := FPageEditor.FDesignerForm.DoClick;
    AddTo := Self;
{$IFNDEF USE_TB2k}
    Repeating := True;
{$ENDIF}
  end;
  ToolbarSep974 := TRMToolbarSep.Create(Self);
  with ToolbarSep974 do
  begin
    AddTo := Self;
  end;

  btnColumnMin := TRMToolbarButton.Create(Self);
  with btnColumnMin do
  begin
    ImageIndex := 0;
    Images := FPageEditor.FDesignerForm.ImageListSize;
    OnClick := FPageEditor.btnColumnMinClick;
    AddTo := Self;
  end;
  btnColumnMax := TRMToolbarButton.Create(Self);
  with btnColumnMax do
  begin
    ImageIndex := 1;
    Images := FPageEditor.FDesignerForm.ImageListSize;
    OnClick := FPageEditor.btnColumnMaxClick;
    AddTo := Self;
  end;
  btnRowMin := TRMToolbarButton.Create(Self);
  with btnRowMin do
  begin
    ImageIndex := 2;
    Images := FPageEditor.FDesignerForm.ImageListSize;
    OnClick := FPageEditor.btnRowMinClick;
    AddTo := Self;
  end;
  btnRowMax := TRMToolbarButton.Create(Self);
  with btnRowMax do
  begin
    ImageIndex := 3;
    Images := FPageEditor.FDesignerForm.ImageListSize;
    OnClick := FPageEditor.btnRowMaxClick;
    AddTo := Self;
  end;
  ToolbarSep975 := TRMToolbarSep.Create(Self);
  with ToolbarSep975 do
  begin
    AddTo := Self;
  end;

  cmbBands := TRMComboBox97.Create(Self);
  with cmbBands do
  begin
    parent := Self;
    Height := 21;
    Width := 180;
    DropDownCount := 12;
    OnClick := FPageEditor.cmbBandsClick;
    OnDropDown := FPageEditor.cmbBandsDropDown;
    Perform(CB_SETDROPPEDWIDTH, 240, 0);
  end;
{$IFDEF USE_TB2K}
  btnAddBand := TRMSubmenuItem.Create(Self);
{$ELSE}
  btnAddBand := TRMToolbarButton.Create(Self);
{$ENDIF}
  with btnAddBand do
  begin
    ImageIndex := 23;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    AddTo := Self;
    DropdownCombo := True;
{$IFNDEF USE_TB2k}
    DropdownMenu := FPageEditor.FPopupMenuBands;
{$ENDIF}
  end;
{$IFDEF USE_TB2K}
  btnDeleteBand := TRMSubmenuItem.Create(Self);
{$ELSE}
  btnDeleteBand := TRMToolbarButton.Create(Self);
{$ENDIF}
  with btnDeleteBand do
  begin
    ImageIndex := 22;
    Images := FPageEditor.FDesignerForm.ImageListFrame;
    AddTo := Self;
    DropdownCombo := True;
{$IFNDEF USE_TB2k}
    DropdownMenu := FPageEditor.FPopupMenuDeleteBands;
{$ENDIF}

    OnClick := FPageEditor.btnDeleteBandClick;
  end;

//  EndUpdate;
  Localize;
end;

procedure TRMToolbarBorder.Localize;
begin
  RMSetStrProp(Self, 'Caption', rmRes + 083);
  RMSetStrProp(btnFrameLeft, 'Hint', rmRes + 123);
  RMSetStrProp(btnFrameRight, 'Hint', rmRes + 125);
  RMSetStrProp(btnFrameTop, 'Hint', rmRes + 122);
  RMSetStrProp(btnFrameBottom, 'Hint', rmRes + 124);
  RMSetStrProp(btnNoBorder, 'Hint', rmRes + 127);
  RMSetStrProp(btnSetBorder, 'Hint', rmRes + 126);

  RMSetStrProp(btnTopBorder, 'Hint', rmRes + 234);
  RMSetStrProp(btnBottomBorder, 'Hint', rmRes + 235);
  RMSetStrProp(btnBias1Border, 'Hint', rmRes + 232);
  RMSetStrProp(btnBias2Border, 'Hint', rmRes + 233);

  RMSetStrProp(btnDecWidth, 'Hint', rmRes + 228);
  RMSetStrProp(btnIncWidth, 'Hint', rmRes + 229);
  RMSetStrProp(btnDecHeight, 'Hint', rmRes + 230);
  RMSetStrProp(btnIncHeight, 'Hint', rmRes + 231);

  RMSetStrProp(btnAddBand, 'Hint', rmRes + 134);
  RMSetStrProp(btnDeleteBand, 'Hint', rmRes + 227);

  RMSetStrProp(btnColumnMin, 'Hint', rmRes + 202);
  RMSetStrProp(btnColumnMax, 'Hint', rmRes + 203);
  RMSetStrProp(btnRowMin, 'Hint', rmRes + 204);
  RMSetStrProp(btnRowMax, 'Hint', rmRes + 205);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMReportPageEditor }

constructor TRMGridReportPageEditor.CreateComp(aOwner: TComponent;
  aDesignerForm: TRMDesignerForm);

  procedure _CreateComps;
  begin
    Panel2 := TRMPanel.Create(Self);
    with Panel2 do
    begin
      Name := 'Panel2';
      Parent := TWinControl(aOwner);
      Caption := '';
      Align := alClient;
      BevelOuter := bvLowered;
      TabOrder := 0;
    end;

    FPopupMenuBands := TRMPopupMenu.Create(Self);
    with FPopupMenuBands do
    begin
      Name := 'PopupMenuBands';
      AutoHotkeys := maManual;
      OnPopup := PopupMenuBandsPopup;
    end;
    FPopupMenuDeleteBands := TRMPopupMenu.Create(Self);
    with FPopupMenuDeleteBands do
    begin
      AutoHotkeys := maManual;
      OnPopup := PopupMenuDeleteBandsPopup;
    end;

    // 主菜单
    ToolbarEdit := TRMToolbarEdit.CreateAndDock(Self, FDesignerForm.Dock971);
    ToolbarBorder := TRMToolbarBorder.CreateAndDock(Self, FDesignerForm.Dock971);
    ToolbarGrid := TRMToolbarGrid.CreateAndDock(Self, FDesignerForm.Dock971);
    ToolbarCellEdit := TRMToolbarCellEdit.CreateAndDock(Self, FDesignerForm.Dock971);
  end;

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

    MenuEdit := TRMSubmenuItem.Create(Self);
    with MenuEdit do
    begin
      Caption := 'Edit';
{$IFDEF USE_TB2K}
      FDesignerForm.MainMenu.Items.Insert(1, MenuEdit);
{$ELSE}
      AddToMenu(FMainMenu);
{$ENDIF}
      GroupIndex := 2;
    end;
    MenuEditUndo := TRMMenuItem.Create(Self);
    with MenuEditUndo do
    begin
      ImageIndex := 8;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Undo';
      ShortCut := Menus.ShortCut(Ord('Z'), [ssCtrl]);
      OnClick := Editor_BtnUndoClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditRedo := TRMMenuItem.Create(Self);
    with MenuEditRedo do
    begin
      ImageIndex := 9;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Redo';
      ShortCut := Menus.ShortCut(Ord('Z'), [ssShift, ssCtrl]);
      OnClick := Editor_BtnRedoClick;
      AddToMenu(MenuEdit);
    end;
    N12 := TRMSeparatorMenuItem.Create(Self);
    N12.AddToMenu(MenuEdit);
    MenuEditCut := TRMMenuItem.Create(Self);
    with MenuEditCut do
    begin
      ImageIndex := 5;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Cut';
      ShortCut := Menus.ShortCut(Word('X'), [ssCtrl]);
      OnClick := Editor_BtnCutClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditCopy := TRMMenuItem.Create(Self);
    with MenuEditCopy do
    begin
      ImageIndex := 6;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Copy';
      ShortCut := Menus.ShortCut(Word('C'), [ssCtrl]);
      OnClick := Editor_BtnCopyClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditPaste := TRMMenuItem.Create(Self);
    with MenuEditPaste do
    begin
      ImageIndex := 7;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Paste';
      ShortCut := Menus.ShortCut(Word('V'), [ssCtrl]);
      OnClick := Editor_BtnPasteClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditDelete := TRMMenuItem.Create(Self);
    with MenuEditDelete do
    begin
      ImageIndex := 22;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Delete';
      ShortCut := Menus.ShortCut(VK_DELETE, [ssCtrl]);
      OnClick := MenuEditDeleteClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditSelectAll := TRMMenuItem.Create(Self);
    with MenuEditSelectAll do
    begin
      ImageIndex := 12;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Select All';
      ShortCut := Menus.ShortCut(Word('A'), [ssCtrl]);
      OnClick := MenuEditSelectAllClick;
      AddToMenu(MenuEdit);
    end;
    N11 := TRMSeparatorMenuItem.Create(Self);
    N11.AddToMenu(MenuEdit);
    MenuEditCopyPage := TRMMenuItem.Create(Self);
    with MenuEditCopyPage do
    begin
      Caption := 'Copy Page';
      OnClick := MenuEditCopyPageClick;
      AddToMenu(MenuEdit);
    end;
    MenuEditPastePage := TRMMenuItem.Create(Self);
    with MenuEditPastePage do
    begin
      Caption := 'Paste Page';
      OnClick := MenuEditPastePageClick;
      AddToMenu(MenuEdit);
    end;

    MenuCell := TRMSubmenuItem.Create(Self);
    with MenuCell do
    begin
      Caption := 'Cell';
{$IFDEF USE_TB2K}
      FDesignerForm.MainMenu.Items.Insert(2, MenuCell);
{$ELSE}
      AddToMenu(FMainMenu);
{$ENDIF}
      GroupIndex := 3;
    end;
    MenuCellProperty := TRMMenuItem.Create(Self);
    with MenuCellProperty do
    begin
      ImageIndex := 27;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Prop...';
      OnClick := MenuCellPropertyClick;
      AddToMenu(MenuCell);
    end;
    MenuCellTableSize := TRMMenuItem.Create(Self);
    with MenuCellTableSize do
    begin
      ImageIndex := 10;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Column & Row...';
      OnClick := MenuCellTableSizeClick;
      AddToMenu(MenuCell);
    end;
    MenuCellRow := TRMSubmenuItem.Create(Self);
    with MenuCellRow do
    begin
      Caption := 'Row';
      AddToMenu(MenuCell);
    end;
    itmRowHeight := TRMMenuItem.Create(Self);
    with itmRowHeight do
    begin
      Caption := 'Row Height...';
      OnClick := itmRowHeightClick;
      AddToMenu(MenuCellRow);
    end;
    itmAverageRowHeight := TRMMenuItem.Create(Self);
    with itmAverageRowHeight do
    begin
      Caption := 'Average Row Height';
      OnClick := itmAverageRowHeightClick;
      AddToMenu(MenuCellRow);
    end;
    MenuCellColumn := TRMSubmenuItem.Create(Self);
    with MenuCellColumn do
    begin
      Caption := 'Column';
      AddToMenu(MenuCell);
    end;
    itmColumnHeight := TRMMenuItem.Create(Self);
    with itmColumnHeight do
    begin
      Caption := 'Column Width...';
      OnClick := itmColumnHeightClick;
      AddToMenu(MenuCellColumn);
    end;
    itmAverageColumnWidth := TRMMenuItem.Create(Self);
    with itmAverageColumnWidth do
    begin
      Caption := 'Average Column Width';
      OnClick := itmAverageColumnWidthClick;
      AddToMenu(MenuCellColumn);
    end;
    N8 := TRMSeparatorMenuItem.Create(Self);
    N8.AddToMenu(MenuCell);
    MenuCellInsertCell := TRMSubmenuItem.Create(Self);
    with MenuCellInsertCell do
    begin
      Caption := 'Insert Cell';
      AddToMenu(MenuCell);
    end;
    itmInsertCellLeft := TRMMenuItem.Create(Self);
    with itmInsertCellLeft do
    begin
      Caption := 'Left';
      AddToMenu(MenuCellInsertCell);
    end;
    itmInsertCellTop := TRMMenuItem.Create(Self);
    with itmInsertCellTop do
    begin
      Caption := 'Top';
      AddToMenu(MenuCellInsertCell);
    end;
    MenuCellInsertColumn := TRMMenuItem.Create(Self);
    with MenuCellInsertColumn do
    begin
      ImageIndex := 0;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Insert Column';
      OnClick := itmInsertLeftColumnClick;
      AddToMenu(MenuCell);
    end;
    MenuCellInsertRow := TRMMenuItem.Create(Self);
    with MenuCellInsertRow do
    begin
      ImageIndex := 1;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Insert Row';
      OnClick := itmInsertTopRowClick;
      AddToMenu(MenuCell);
    end;
    MenuCellDeleteColumn := TRMMenuItem.Create(Self);
    with MenuCellDeleteColumn do
    begin
      ImageIndex := 4;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Delete Column';
      OnClick := itmDeleteColumnClick;
      AddToMenu(MenuCell);
    end;
    MenuCellDeleteRow := TRMMenuItem.Create(Self);
    with MenuCellDeleteRow do
    begin
      ImageIndex := 5;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Delete Row';
      OnClick := itmDeleteRowClick;
      AddToMenu(MenuCell);
    end;
    N18 := TRMSeparatorMenuItem.Create(Self);
    N18.AddToMenu(MenuCell);
    MenuCellMerge := TRMMenuItem.Create(Self);
    with MenuCellMerge do
    begin
      ImageIndex := 6;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Merge';
      OnClick := btnMergeClick;
      AddToMenu(MenuCell);
    end;
    MenuCellReverse := TRMMenuItem.Create(Self);
    with MenuCellReverse do
    begin
      ImageIndex := 7;
      Images := FDesignerForm.ImageListStand;
      Caption := 'Reverse';
      OnClick := btnSplitClick;
      AddToMenu(MenuCell);
    end;

{    MenuInsertObject := TRMSubmenuItem.Create(Self);
    with MenuInsertObject do
    begin
   Caption := 'Insert';
     AddToMenu(MenuBar);
    end;}

    MenuEditToolbar := TRMSubmenuItem.Create(Self);
    with MenuEditToolbar do
    begin
      Caption := 'Tools bar';
{$IFDEF USE_TB2K}
      FDesignerForm.MainMenu.Items.Insert(4, MenuEditToolbar);
{$ELSE}
      AddToMenu(FMainMenu);
{$ENDIF}
      GroupIndex := 21;
    end;
    padSetToolbar := TRMSubmenuItem.Create(Self);
    with padSetToolbar do
    begin
      Caption := 'Tools bar';
      OnClick := MenuEditToolbarClick;
      AddToMenu(MenuEditToolbar);
    end;
    itmToolbarStandard := TRMMenuItem.Create(Self);
    with itmToolbarStandard do
    begin
      Caption := 'Standard';
      Tag := 0;
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarText := TRMMenuItem.Create(Self);
    with itmToolbarText do
    begin
      Tag := 1;
      Caption := 'Text';
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarBorder := TRMMenuItem.Create(Self);
    with itmToolbarBorder do
    begin
      Tag := 2;
      Caption := 'Border';
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarGrid := TRMMenuItem.Create(Self);
    with itmToolbarGrid do
    begin
      Tag := 5;
      Caption := 'Grid';
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarInspector := TRMMenuItem.Create(Self);
    with itmToolbarInspector do
    begin
      Tag := 3;
      Caption := 'Object Inspector';
      ShortCut := 122;
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarInsField := TRMMenuItem.Create(Self);
    with itmToolbarInsField do
    begin
      Tag := 4;
      Caption := 'Insert DB fields';
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    itmToolbarCellEdit := TRMMenuItem.Create(Self);
    with itmToolbarCellEdit do
    begin
      Tag := 6;
      Caption := 'Cell Edit';
      OnClick := itmToolbarStandardClick;
      AddToMenu(padSetToolbar);
    end;
    padAddTools := TRMmenuItem.Create(Self);
    with padAddTools do
    begin
      Caption := 'Extra tools';
      Enabled := False;
      AddToMenu(MenuEditToolbar);
    end;
    MenuEditOptions := TRMMenuItem.Create(Self);
    with MenuEditOptions do
    begin
      Caption := 'Options...';
      OnClick := MenuEditOptionsClick;
      AddToMenu(MenuEditToolbar);
    end;

    FDesignerForm.AddLanguageMenu(MenuEditToolbar);
  end;

  procedure _CreateGridPopupMenu;
  begin
    // Grid右键菜单
    FSelectionMenu := TRMPopupMenu.Create(Self);
    with FSelectionMenu do
    begin
      OnPopup := SelectionMenuPopup;
      AutoHotKeys := maManual;
      Images := FDesignerForm.ImageListStand;
    end;
    itmGridMenuBandProp := TRMMenuItem.Create(Self);
    with itmGridMenuBandProp do
    begin
      Caption := 'Band DataSet...';
      OnClick := OnGridRowHeaderDblClick;
      AddToMenu(FSelectionMenu);
    end;

    SelectionMenu_popCut := TRMMenuItem.Create(Self);
    with SelectionMenu_popCut do
    begin
      Caption := 'Cut';
      ImageIndex := 12;
      OnClick := Editor_BtnCutClick;
      AddToMenu(FSelectionMenu);
    end;
    SelectionMenu_popCopy := TRMMenuItem.Create(Self);
    with SelectionMenu_popCopy do
    begin
      Caption := 'Copy';
      ImageIndex := 13;
      OnClick := Editor_BtnCopyClick;
      AddToMenu(FSelectionMenu);
    end;
    SelectionMenu_popPaste := TRMMenuItem.Create(Self);
    with SelectionMenu_popPaste do
    begin
      Caption := 'Paste';
      ImageIndex := 14;
      OnClick := Editor_BtnPasteClick;
      AddToMenu(FSelectionMenu);
    end;
    N102 := TRMSeparatorMenuItem.Create(Self);
    N102.AddToMenu(FSelectionMenu);

    itmCellProp := TRMMenuItem.Create(Self);
    with itmCellProp do
    begin
      ImageIndex := 40;
      Caption := 'Prop...';
      OnClick := MenuCellPropertyClick;
      AddToMenu(FSelectionMenu);
    end;
//    itmSplit1 := TRMSeparatorMenuItem.Create(Self);
//    itmSplit1.AddToMenu(FSelectionMenu);
    itmMergeCells := TRMMenuItem.Create(Self);
    with itmMergeCells do
    begin
      ImageIndex := 35;
      Caption := 'Merge Cells';
      OnClick := btnMergeClick;
      AddToMenu(FSelectionMenu);
    end;
    itmSplitCells := TRMMenuItem.Create(Self);
    with itmSplitCells do
    begin
      ImageIndex := 36;
      Caption := 'Split Cells';
      OnClick := btnSplitClick;
      AddToMenu(FSelectionMenu);
    end;
    N3 := TRMSeparatorMenuItem.Create(Self);
    N3.AddToMenu(FSelectionMenu);
    itmInsert := TRMSubmenuItem.Create(Self);
    with itmInsert do
    begin
      Caption := 'Insert';
      AddToMenu(FSelectionMenu);
    end;
    itmInsertLeftColumn := TRMMenuItem.Create(Self);
    with itmInsertLeftColumn do
    begin
      Caption := 'Left Column';
      OnClick := itmInsertLeftColumnClick;
      AddToMenu(itmInsert);
    end;
    itmInsertRightColumn := TRMMenuItem.Create(Self);
    with itmInsertRightColumn do
    begin
      Caption := 'Right Column';
      OnClick := itmInsertRightColumnClick;
      AddToMenu(itmInsert);
    end;
    N10 := TRMSeparatorMenuItem.Create(Self);
    N10.AddToMenu(itmInsert);
    itmInsertTopRow := TRMMenuItem.Create(Self);
    with itmInsertTopRow do
    begin
      Caption := 'Top Row';
      OnClick := itmInsertTopRowClick;
      AddToMenu(itmInsert);
    end;
    itmInsertBottomRow := TRMMenuItem.Create(Self);
    with itmInsertBottomRow do
    begin
      Caption := 'Bottom Row';
      OnClick := itmInsertBottomRowClick;
      AddToMenu(itmInsert);
    end;

    itmSep1 := TRMSeparatorMenuItem.Create(Self);
    itmSep1.AddToMenu(itmInsert);
    itmInsertLeftCell := TRMMenuItem.Create(Self);
    with itmInsertLeftCell do
    begin
      Caption := RMLoadStr(rmRes + 258);
      OnClick := itmInsertLeftCellClick;
      AddToMenu(itmInsert);
    end;
    itmInsertTopCell := TRMMenuItem.Create(Self);
    with itmInsertTopCell do
    begin
      Caption := RMLoadStr(rmRes + 259);
      OnClick := itmInsertTopCellClick;
      AddToMenu(itmInsert);
    end;
    itmDelete := TRMSubmenuItem.Create(Self);
    with itmDelete do
    begin
      Caption := 'Delete';
      AddToMenu(FSelectionMenu);
    end;
    itmDeleteColumn := TRMMenuItem.Create(Self);
    with itmDeleteColumn do
    begin
      Caption := 'Column';
      OnClick := itmDeleteColumnClick;
      AddToMenu(itmDelete);
    end;
    itmDeleteRow := TRMMenuItem.Create(Self);
    with itmDeleteRow do
    begin
      Caption := 'Row';
      OnClick := itmDeleteRowClick;
      AddToMenu(itmDelete);
    end;
    itmDeleteSep1 := TRMSeparatorMenuItem.Create(Self);
    itmDeleteSep1.AddToMenu(itmDelete);
    itmDeleteLeftCell := TRMMenuItem.Create(Self);
    with itmDeleteLeftCell do
    begin
      Caption := RMLoadStr(rmRes + 268);
      OnClick := itmDeleteLeftCellClick;
      AddToMenu(itmDelete);
    end;
    itmDeleteTopCell := TRMMenuItem.Create(Self);
    with itmDeleteTopCell do
    begin
      Caption := RMLoadStr(rmRes + 269);
      OnClick := itmDeleteTopCellClick;
      AddToMenu(itmDelete);
    end;
    N6 := TRMSeparatorMenuItem.Create(Self);
    N6.AddToMenu(FSelectionMenu);

    itmCellType := TRMSubmenuItem.Create(Self);
    with itmCellType do
    begin
      Caption := 'Cell Type';
      AddToMenu(FSelectionMenu);
    end;
    itmMemoView := TRMMenuItem.Create(Self);
    with itmMemoView do
    begin
      Caption := 'Memo View';
      Checked := True;
      GroupIndex := 1;
      RadioItem := true;
      OnClick := itmMemoViewClick;
      Tag := rmgtMemo;
      AddToMenu(itmCellType);
    end;
    itmCalcMemoView := TRMMenuItem.Create(Self);
    with itmCalcMemoView do
    begin
      Tag := rmgtCalcMemo;
      Caption := 'Calc Memo View';
      GroupIndex := 1;
      RadioItem := true;
      OnClick := itmMemoViewClick;
      Tag := rmgtCalcMemo;
      AddToMenu(itmCellType);
    end;
    itmPictureView := TRMMenuItem.Create(Self);
    with itmPictureView do
    begin
      Tag := rmgtPicture;
      Caption := 'Picture View';
      GroupIndex := 1;
      RadioItem := true;
      OnClick := itmMemoViewClick;
      AddToMenu(itmCellType);
    end;
    itmSubReportView := TRMMenuItem.Create(Self);
    with itmSubReportView do
    begin
      Tag := rmgtSubReport;
      Caption := 'SubReport View';
      GroupIndex := 1;
      RadioItem := true;
      OnClick := itmMemoViewClick;
      AddToMenu(itmCellType);
    end;
    itmInsertBand := TRMSubmenuItem.Create(Self);
    with itmInsertBand do
    begin
      Caption := 'Band';
      AddToMenu(FSelectionMenu);
    end;
    itmSelectBand := TRMSubmenuItem.Create(Self);
    itmSelectBand.AddToMenu(FSelectionMenu);
    N4 := TRMSeparatorMenuItem.Create(Self);
    N4.AddToMenu(FSelectionMenu);
    itmFrameType := TRMMenuItem.Create(Self);
    with itmFrameType do
    begin
      Caption := 'Frame Type...';
      OnClick := itmFrameTypeClick;
      AddToMenu(FSelectionMenu);
    end;
    itmEdit := TRMMenuItem.Create(Self);
    with itmEdit do
    begin
      Caption := 'Edit...';
      OnClick := itmEditClick;
      AddToMenu(FSelectionMenu);
    end;
    padpopClearContents := TRMMenuItem.Create(Self);
    with padpopClearContents do
    begin
      Caption := 'Clear Contents';
      OnClick := padpopClearContentsClick;
      AddToMenu(FSelectionMenu);
    end;

    N100 := TRMSeparatorMenuItem.Create(Self);
    N100.AddToMenu(FSelectionMenu);
    padpopOtherProp := TRMMenuItem.Create(Self);
    with padpopOtherProp do
    begin
      Caption := 'Other Prop';
      AddToMenu(FSelectionMenu);
      RMSetStrProp(padpopOtherProp, 'Caption', rmRes + 913);
    end;
  end;

  procedure _CreateOneItem(aBandType: TRMBandType);
  var
  {$IFDEF USE_TB2K}
    lItem: TTBItem;
  {$ELSE}
    litem: TRMMenuItem;
  {$ENDIF}
    lMenuItem: TRMMenuItem;
  begin
{$IFDEF USE_TB2k}
    lItem := TTBItem.Create(ToolbarBorder.btnAddBand);
    lItem.Tag := Ord(aBandType);
    lItem.Caption := RMBandNames[TRMBandType(aBandType)];
    lItem.OnClick := OnAddBandEvent;
    ToolbarBorder.btnAddBand.Add(lItem);
{$ELSE}
    litem := TRMMenuItem.Create(FPopupMenuBands);
    litem.Caption := RMBandNames[aBandType];
    litem.Tag := Ord(aBandType);
    litem.OnClick := OnAddBandEvent;
    FPopupMenuBands.Items.Add(litem);
{$ENDIF}

    lMenuItem := TRMMenuItem.Create(itmInsertBand);
    lMenuItem.Caption := RMBandNames[TRMBandType(aBandType)];
    lMenuItem.Tag := Ord(aBandType);
    lMenuItem.OnClick := OnAddBandEvent;
    itmInsertBand.Add(lMenuItem);
  end;

  procedure _CreateBandsMenuItems;
  var
    bt: TRMBandType;
  begin
    for bt := rmbtReportTitle to rmbtGroupFooter do
    begin
      _CreateOneItem(bt);
    end;

    _CreateOneItem(rmbtChild);
  end;

var
  i: Integer;
  lMenuItem: TRMMenuItem;

begin
  inherited CreateComp(aOwner, aDesignerForm);

  FGrid := nil;
  FDesignerForm := aDesignerForm;
  FPageStream := TMemoryStream.Create;

  _CreateComps;
  _CreateMainMenu;
  _CreateGridPopupMenu;
  _CreateBandsMenuItems;

  itmPictureView.Tag := rmgtPicture;
  itmSubReportView.Tag := rmgtSubReport;
  FAddinObjects := TStringList.Create;
  FAddinObjects.Clear;
  for i := 0 to RMAddInsCount - 1 do
  begin
    if not RMAddIns(i).IsControl then
    begin
      if (RMAddIns(i).ClassRef = nil) or (not RMAddIns(i).ClassRef.CanPlaceOnGridView) then Continue;

      lMenuItem := TRMMenuItem.Create(itmCellType);
      lMenuItem.GroupIndex := itmMemoView.GroupIndex;
      lMenuItem.RadioItem := True;
      lMenuItem.Tag := rmgtAddIn;
      lMenuItem.Caption := RMAddIns(i).ButtonHint;
      lMenuItem.OnClick := itmMemoViewClick;
      FAddinObjects.Add(RMAddIns(i).ClassRef.ClassName);
      itmCellType.Add(lMenuItem);
    end;
  end;

  FFieldListBox := TListBox.Create(Self);
  with FFieldListBox do
  begin
    Visible := False;
    Parent := FDesignerForm;
    Ctl3D := False;
    Style := lbOwnerDrawFixed;
    ItemHeight := 16;
    OnClick := OnFieldListBoxClick;
    OnDrawItem := OnFieldListBoxDrawItem;
  end;

  Localize;
  LoadIni;

{$IFNDEF USE_TB2k}
  FDesignerForm.MainMenu.Merge(FMainMenu);
{$ENDIF}
end;

destructor TRMGridReportPageEditor.Destroy;
begin
  SaveIni;
{$IFNDEF USE_TB2k}
  FDesignerForm.MainMenu.Unmerge(FMainMenu);
{$ENDIF}
  SetGridNilProp;
  FreeAndNil(FPageObjectList);
  FreeAndNil(FAddinObjects);
  FreeAndNil(FPageStream);

  inherited Destroy;
end;

procedure TRMGridReportPageEditor.SaveIni;
begin
  RMSaveToolbars('\GridReport', [ToolbarBorder, ToolbarEdit, ToolbarGrid, ToolbarCellEdit]);
end;

procedure TRMGridReportPageEditor.LoadIni;
begin
  RMRestoreToolbars('\GridReport', [ToolbarEdit, ToolbarBorder, ToolbarGrid, ToolbarCellEdit]);
end;

procedure TRMGridReportPageEditor.Localize;
begin
  RMSetStrProp(MenuEdit, 'Caption', rmRes + 163);
  RMSetStrProp(MenuEditCopyPage, 'Caption', rmRes + 861);
  RMSetStrProp(MenuEditPastePage, 'Caption', rmRes + 862);
  RMSetStrProp(MenuEditCut, 'Caption', rmRes + 166);
  RMSetStrProp(MenuEditCopy, 'Caption', rmRes + 167);
  RMSetStrProp(MenuEditPaste, 'Caption', rmRes + 168);
  RMSetStrProp(MenuEditDelete, 'Caption', rmRes + 169);
  RMSetStrProp(MenuEditSelectAll, 'Caption', rmRes + 170);
  RMSetStrProp(MenuEditUndo, 'Caption', rmRes + 164);
  RMSetStrProp(MenuEditRedo, 'Caption', rmRes + 165);

  RMSetStrProp(padSetToolbar, 'Caption', rmRes + 177);
  RMSetStrProp(padAddTools, 'Caption', rmRes + 178);
  RMSetStrProp(MenuEditToolbar, 'Caption', rmRes + 177);
  RMSetStrProp(MenuEditOptions, 'Caption', rmRes + 179);
  RMSetStrProp(itmToolbarStandard, 'Caption', rmRes + 181);
  RMSetStrProp(itmToolbarText, 'Caption', rmRes + 182);
  RMSetStrProp(itmToolbarBorder, 'Caption', rmRes + 180);
  RMSetStrProp(itmToolbarInspector, 'Caption', rmRes + 184);
  RMSetStrProp(itmToolbarInsField, 'Caption', rmRes + 110);
//  RMSetStrProp(itmToolbarGrid, 'Caption', rmRes + 0);
  RMSetStrProp(itmToolbarCellEdit, 'Caption', rmRes + 866);

  RMSetStrProp(MenuCell, 'Caption', rmRes + 807);
  RMSetStrProp(MenuCellMerge, 'Caption', rmRes + 805);
  RMSetStrProp(MenuCellReverse, 'Caption', rmRes + 806);
  RMSetStrProp(MenuCellProperty, 'Caption', rmRes + 694);
  RMSetStrProp(MenuCellInsertColumn, 'Caption', rmRes + 801);
  RMSetStrProp(MenuCellInsertRow, 'Caption', rmRes + 802);
  RMSetStrProp(MenuCellDeleteColumn, 'Caption', rmRes + 803);
  RMSetStrProp(MenuCellDeleteRow, 'Caption', rmRes + 804);
  RMSetStrProp(MenuCellTableSize, 'Caption', rmRes + 692);
  RMSetStrProp(MenuCellRow, 'Caption', rmRes + 245);
  RMSetStrProp(MenuCellColumn, 'Caption', rmRes + 246);
  RMSetStrProp(itmRowHeight, 'Caption', rmRes + 247);
  RMSetStrProp(itmAverageRowHeight, 'Caption', rmRes + 248);
  RMSetStrProp(itmColumnHeight, 'Caption', rmRes + 249);
  RMSetStrProp(itmAverageColumnWidth, 'Caption', rmRes + 250);
  RMSetStrProp(MenuCellInsertCell, 'Caption', rmRes + 252);
  RMSetStrProp(itmInsertCellLeft, 'Caption', rmRes + 808);
  RMSetStrProp(itmInsertCellTop, 'Caption', rmRes + 810);
  RMSetStrProp(SelectionMenu_popCut, 'Caption', rmRes + 166);
  RMSetStrProp(SelectionMenu_popCopy, 'Caption', rmRes + 167);
  RMSetStrProp(SelectionMenu_popPaste, 'Caption', rmRes + 168);
//  RMSetStrProp(SelectionMenu_popInsert, 'Caption', rmRes + 169);
//  RMSetStrProp(SelectionMenu_popDelete, 'Caption', rmRes + 169);

  RMSetStrProp(itmGridMenuBandProp, 'Caption', rmRes + 875);
  RMSetStrProp(itmCellProp, 'Caption', rmRes + 694);
  RMSetStrProp(itmMergeCells, 'Caption', rmRes + 805);
  RMSetStrProp(itmSplitCells, 'Caption', rmRes + 806);
  RMSetStrProp(itmInsert, 'Caption', rmRes + 702);
  RMSetStrProp(itmInsertLeftColumn, 'Caption', rmRes + 808);
  RMSetStrProp(itmInsertRightColumn, 'Caption', rmRes + 809);
  RMSetStrProp(itmInsertTopRow, 'Caption', rmRes + 810);
  RMSetStrProp(itmInsertBottomRow, 'Caption', rmRes + 811);
  RMSetStrProp(itmDelete, 'Caption', rmRes + 350);
  RMSetStrProp(itmDeleteColumn, 'Caption', rmRes + 812);
  RMSetStrProp(itmDeleteRow, 'Caption', rmRes + 813);
  RMSetStrProp(itmCellType, 'Caption', rmRes + 814);
  RMSetStrProp(itmFrameType, 'Caption', rmRes + 214);
  RMSetStrProp(itmEdit, 'Caption', rmRes + 153);
  RMSetStrProp(padpopClearContents, 'Caption', rmRes + 881);
  RMSetStrProp(itmMemoView, 'Caption', rmRes + 133);
  RMSetStrProp(itmCalcMemoView, 'Caption', rmRes + 197);
  RMSetStrProp(itmPictureView, 'Caption', rmRes + 135);
  RMSetStrProp(itmSubReportView, 'Caption', rmRes + 136);
  RMSetStrProp(itmInsertBand, 'Caption', rmRes + 860);
  RMSetStrProp(itmSelectBand, 'Caption', rmRes + 876);
end;

type
  TRMUndoObject = class(TObject)
  private
    FAryObjID: array of Integer;
    FAryRow: array of Integer;
    FAryCol: array of Integer;
  protected
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TRMUndoObject.Create;
begin
  inherited Create;

  SetLength(FAryObjID, 0);
  SetLength(FAryRow, 0);
  SetLength(FAryCol, 0);
end;

destructor TRMUndoObject.Destroy;
begin
  SetLength(FAryObjID, 0);
  SetLength(FAryRow, 0);
  SetLength(FAryCol, 0);

  inherited Destroy;
end;

procedure TRMGridReportPageEditor.Editor_BtnUndoClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanUndo then
    begin
      FDesignerForm.CodeMemo.RMUndo;
      Editor_ShowPosition;
    end;
  end
  else
  begin
    Undo(@FDesignerForm.UndoBuffer);
    RefreshProp;
    FDesignerForm.AfterChange;
  end;
end;

procedure TRMGridReportPageEditor.Editor_BtnRedoClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanRedo then
    begin
      FDesignerForm.CodeMemo.RMRedo;
      Editor_ShowPosition;
    end;
  end
  else
  begin
    Undo(@FDesignerForm.RedoBuffer);
    RefreshProp;
    FDesignerForm.AfterChange;
  end;
end;

procedure TRMGridReportPageEditor.Editor_AddUndoAction(aAction: TRMUndoAction);
begin
  if (RMDesignerComp <> nil) and (not RMDesignerComp.UseUndoRedo) then Exit;

  FDesignerForm.ClearRedoBuffer;
  if aAction in [rmacChangeCellSize, rmacChangeGrid, rmacChangePage] then
  begin
    AddAction(@FDesignerForm.UndoBuffer, aAction, nil, nil);
  end
  else
    AddAction(@FDesignerForm.UndoBuffer, aAction, FGrid, nil);

  FDesignerForm.EnableControls;
end;

procedure TRMGridReportPageEditor.AddAction(aBuffer: PRMUndoBuffer; aAction: TRMUndoAction;
  aObject: TObject; aRec: PRMUndoRec);
var
  i: Integer;
  lBufferLength: Integer;
  lUndoObject: TRMUndoObject;

  function _FindObjectByID(aID: Integer): TRMView;
  var
    i: Integer;
    t: TRMView;
  begin
    Result := nil;
    for i := 0 to THackPage(FDesignerForm.Page).Objects.Count - 1 do
    begin
      t := THackPage(FDesignerForm.Page).Objects[i];
      if THackView(t).ObjectID = aID then
      begin
        Result := t;
        Break;
      end;
    end;
  end;

  procedure _SaveOneView(t: TRMView; aStream: TMemoryStream);
  begin
    THackView(t).StreamMode := rmsmDesigning;
    RMWriteByte(aStream, t.ObjectType);
    RMWriteString(aStream, t.ClassName);
    t.SaveToStream(aStream);
  end;

  procedure _SaveSelectionCells(aStream: TMemoryStream);
  var
    i, lRow, lCol, lCount: Integer;
    lCell: TRMCellInfo;
    lSavePos: Integer;
    t: TRMView;
    lStream: TMemoryStream;
    lUndoObject: TRMUndoObject;
  begin
    lStream := TMemoryStream.Create;
    try
      if aObject is TMemoryStream then
      begin
        lUndoObject := TRMUndoObject(aRec.AddObj);
        RMWriteInt32(lStream, Length(lUndoObject.FAryRow));
        for i := 0 to Length(lUndoObject.FAryRow) - 1 do
        begin
          lCell := FGrid.Cells[lUndoObject.FAryCol[i], lUndoObject.FAryRow[i]];
          RMWriteInt32(lStream, lUndoObject.FAryRow[i]);
          RMWriteInt32(lStream, lUndoObject.FAryCol[i]);
          _SaveOneView(lCell.View, lStream);
        end;

        RMWriteInt32(lStream, Length(lUndoObject.FAryObjID));
        for i := 0 to Length(lUndoObject.FAryObjID) - 1 do
        begin
          t := _FindObjectByID(lUndoObject.FAryObjID[i]);
          if t <> nil then
            _SaveOneView(t, lStream);
        end;

        RMCompressStream(lStream, aStream, zcFastest);
      end
      else
      begin
        lCount := 0;
        lUndoObject := TRMUndoObject(aBuffer[lBufferLength].AddObj);
        RMWriteInt32(lStream, 0);
        for lRow := 1 to FGrid.RowCount - 1 do
        begin
          lCol := 1;
          while lCol < FGrid.ColCount do
          begin
            lCell := FGrid.Cells[lCol, lRow];
            if (lCell.StartRow = lRow) and lCell.View.Selected then
            begin
              RMWriteInt32(lStream, lRow);
              RMWriteInt32(lStream, lCol);
              _SaveOneView(lCell.View, lStream);

              Inc(lCount);
              SetLength(lUndoObject.FAryRow, lCount);
              SetLength(lUndoObject.FAryCol, lCount);
              lUndoObject.FAryRow[lCount - 1] := lRow;
              lUndoObject.FAryCol[lCount - 1] := lCol;
            end;
            lCol := lCell.EndCol + 1;
          end;
        end;

        lSavePos := lStream.Position;
        lStream.Position := 0;
        RMWriteInt32(lStream, lCount);
        lStream.Position := lSavePos;
        RMWriteInt32(lStream, 0);
        lCount := 0;
        for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
        begin
          if TRMView(FDesignerForm.Page.Objects[i]).Selected then
          begin
            _SaveOneView(FDesignerForm.Page.Objects[i], lStream);
            Inc(lCount);
            SetLength(lUndoObject.FAryObjID, lCount);
            lUndoObject.FAryObjID[lCount - 1] := THackView(FDesignerForm.Page.Objects[i]).ObjectID;
          end;
        end;
        lStream.Position := lSavePos;
        RMWriteInt32(lStream, lCount);

        RMCompressStream(lStream, aStream, zcFastest);
      end;
    finally
      lStream.Free;
    end;
  end;

  procedure _SaveCellSize(aStream: TMemoryStream);
  var
    i: Integer;
  begin
    RMWriteInt32(aStream, FGrid.RowCount);
    RMWriteInt32(aStream, FGrid.ColCount);
    for i := 1 to FGrid.RowCount - 1 do
      RMWriteInt32(aStream, FGrid.RowHeights[i]);
    for i := 1 to FGrid.ColCount - 1 do
      RMWriteInt32(aStream, FGrid.ColWidths[i]);
  end;

  procedure _SaveGridProp(aStream: TMemoryStream);
  var
    lStream: TMemoryStream;
  begin
    lStream := TMemoryStream.Create;
    try
      FGrid.SaveToStream(lStream);
      RMCompressStream(lStream, aStream, zcFastest);
    finally
      lStream.Free;
    end;
  end;

  procedure _SavePageProp(aStream: TMemoryStream);
  var
    i: Integer;
    t: TRMView;
    lStream: TMemoryStream;
  begin
    lStream := TMemoryStream.Create;
    try
      RMWriteInt32(lStream, FDesignerForm.Page.Objects.Count);
      for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
      begin
        t := FDesignerForm.Page.Objects[i];
        RMWriteByte(lStream, t.ObjectType);
        RMWriteString(lStream, t.ClassName);
        THackView(t).StreamMode := rmsmDesigning;
        t.SaveToStream(lStream);
      end;

      THackPage(FDesignerForm.Page).SaveToStream(lStream);
      RMCompressStream(lStream, aStream, zcFastest);
    finally
      lStream.Free;
    end;
  end;

begin
  if FUndoBusy then Exit;

  FUndoBusy := True;
  try
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
    end;

    aBuffer[lBufferLength].Action := aAction;
    aBuffer[lBufferLength].Page := FDesignerForm.CurPage;
    if aBuffer[lBufferLength].AddObj = nil then
    begin
      lUndoObject := TRMUndoObject.Create;
      aBuffer[lBufferLength].AddObj := lUndoObject;
    end;

    lUndoObject := TRMUndoObject(aBuffer[lBufferLength].AddObj);
    if aRec <> nil then
    begin
      SetLength(lUndoObject.FAryObjID, Length(TRMUndoObject(aRec.AddObj).FAryObjID));
      for i := 0 to Length(TRMUndoObject(aRec.AddObj).FAryObjID) - 1 do
        lUndoObject.FAryObjID[i] := TRMUndoObject(aRec.AddObj).FAryObjID[i];

      SetLength(lUndoObject.FAryRow, Length(TRMUndoObject(aRec.AddObj).FAryRow));
      SetLength(lUndoObject.FAryCol, Length(TRMUndoObject(aRec.AddObj).FAryRow));
      for i := 0 to Length(TRMUndoObject(aRec.AddObj).FAryRow) - 1 do
      begin
        lUndoObject.FAryRow[i] := TRMUndoObject(aRec.AddObj).FAryRow[i];
        lUndoObject.FAryCol[i] := TRMUndoObject(aRec.AddObj).FAryCol[i];
      end;
    end
    else
    begin
      SetLength(lUndoObject.FAryObjID, 0);
      SetLength(lUndoObject.FAryRow, 0);
      SetLength(lUndoObject.FAryCol, 0);
    end;

    case aAction of
      rmacChangeCellSize:
        begin
          aBuffer[lBufferLength].Stream := TMemoryStream.Create;
          _SaveCellSize(aBuffer[lBufferLength].Stream);
        end;
      rmacChangeGrid:
        begin
          aBuffer[lBufferLength].Stream := TMemoryStream.Create;
          _SaveGridProp(aBuffer[lBufferLength].Stream);
        end;
      rmacEdit:
        begin
          aBuffer[lBufferLength].Stream := TMemoryStream.Create;
          _SaveSelectionCells(aBuffer[lBufferLength].Stream);
        end;
      rmacChangePage:
        begin
          aBuffer[lBufferLength].Stream := TMemoryStream.Create;
          _SavePageProp(aBuffer[lBufferLength].Stream);
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
  finally
    FDesignerForm.Modified := True;
    FUndoBusy := False;
  end;
end;

procedure TRMGridReportPageEditor.Undo(aBuffer: PRMUndoBuffer);
var
  lBufferLength: Integer;

  procedure _SetUndo;
  var
    lAction: TRMUndoAction;
    lObject: TObject;
  begin
    lAction := rmacEdit;
    lObject := nil;
    case aBuffer[lBufferLength - 1].Action of
      rmacChangeCellSize:
        begin
          lAction := rmacChangeCellSize;
          lObject := nil;
        end;
      rmacChangeGrid:
        begin
          lAction := rmacChangeGrid;
          lObject := nil;
        end;
      rmacEdit:
        begin
          lAction := rmacEdit;
          lObject := aBuffer[lBufferLength - 1].Stream;
        end;
      rmacChangePage:
        begin
          lAction := rmacChangePage;
          lObject := nil;
        end;
    end;

    if aBuffer = @FDesignerForm.UndoBuffer then
    begin
      if lAction = rmacEdit then
        AddAction(@FDesignerForm.RedoBuffer, lAction, lObject, @aBuffer[lBufferLength - 1])
      else
        AddAction(@FDesignerForm.RedoBuffer, lAction, lObject, nil);
    end
    else
    begin
      if lAction = rmacEdit then
        AddAction(@FDesignerForm.UndoBuffer, lAction, lObject, @aBuffer[lBufferLength - 1])
      else
        AddAction(@FDesignerForm.UndoBuffer, lAction, lObject, nil);
    end;
  end;

  procedure _RestoreSelectionCells(aStream: TMemoryStream);
  var
    i, lCount, lRow, lCol: Integer;
    t: TRMView;
    lObjectTyp: Byte;
    lObjectClassName: string;
    lStream: TMemoryStream;

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

    procedure _LoadOneView;
    var
      lCreateFlag: Boolean;
    begin
      lCreateFlag := False;
      lObjectTyp := RMReadByte(aStream);
      lObjectClassName := RMReadString(aStream);
      t := FDesignerForm.Page.Objects[_FindObjectByID(TRMUndoObject(aBuffer[lBufferLength - 1].AddObj).FAryObjID[i])];
      if t = nil then
      begin
        lCreateFlag := True;
        t := RMCreateObject(lObjectTyp, lObjectClassName);
      end;

      t.NeedCreateName := False;
      THackView(t).StreamMode := rmsmDesigning;
      t.LoadFromStream(aStream);
      if lCreateFlag then
        t.Free;
    end;

  begin
    lStream := TMemoryStream.Create;
    try
      aStream.Position := 0;
      RMDeCompressStream(aStream, lStream);
      lStream.Position := 0;
      lCount := RMReadInt32(lStream);
      for i := 0 to lCount - 1 do // 恢复grid中cell
      begin
        lRow := RMReadInt32(lStream);
        lCol := RMReadInt32(lStream);
        lObjectTyp := RMReadByte(lStream);
        lObjectClassName := RMReadString(lStream);
        FGrid.Cells[lCol, lRow].ReCreateView(lObjectTyp, lObjectClassName);
        t := FGrid.Cells[lCol, lRow].View;
        t.NeedCreateName := False;
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(lStream);
      end;

      lCount := RMReadInt32(lStream); // 恢复bands
      for i := 0 to lCount - 1 do
      begin
        _LoadOneView;
      end;
    finally
      lStream.Free;
    end;
  end;

  procedure _RestoreCellSize(aStream: TMemoryStream);
  var
    i: Integer;
  begin
    aStream.Position := 0;
    FGrid.RowCount := RMReadInt32(aStream);
    FGrid.ColCount := RMReadInt32(aStream);
    for i := 1 to FGrid.RowCount - 1 do
      FGrid.RowHeights[i] := RMReadInt32(aStream);
    for i := 1 to FGrid.ColCount - 1 do
      FGrid.ColWidths[i] := RMReadInt32(aStream);
  end;

  procedure _RestoreGridProp(aStream: TMemoryStream);
  var
    lStream: TMemoryStream;
    lSaveWidth, lSaveHeight: Integer;
  begin
    lStream := TMemoryStream.Create;
    lSaveWidth := FGrid.Width;
    lSaveHeight := FGrid.Height;
    try
      aStream.Position := 0;
      RMDeCompressStream(aStream, lStream);
      lStream.Position := 0;
      FGrid.LoadFromStream(lStream);
    finally
      FGrid.Width := lSaveWidth;
      FGrid.Height := lSaveHeight;
      SetGridHeader;
      lStream.Free;
    end;
  end;

  procedure _RestorePageProp(aStream: TMemoryStream);
  var
    i, lCount: Integer;
    b: Byte;
    t: TRMView;
    lStream: TMemoryStream;
  begin
    lStream := TMemoryStream.Create;
    try
      aStream.Position := 0;
      RMDeCompressStream(aStream, lStream);
      lStream.Position := 0;
      FDesignerForm.Page.Clear;
      lCount := RMReadInt32(lStream);
      for i := 0 to lCount - 1 do
      begin
        b := RMReadByte(lStream);
        t := RMCreateObject(b, RMReadString(lStream));
        t.NeedCreateName := False;
        THackView(t).StreamMode := rmsmDesigning;
        t.LoadFromStream(lStream);
        t.ParentPage := FDesignerForm.Page;
      end;

      THackPage(FDesignerForm.Page).LoadFromStream(lStream);
      THackPage(FDesignerForm.Page).AfterLoaded;
      SetGridHeader;
    finally
      lStream.Free;
    end;
  end;

begin
  if (RMDesignerComp <> nil) and (not RMDesignerComp.UseUndoRedo) then Exit;

  if aBuffer = @FDesignerForm.UndoBuffer then
    lBufferLength := FDesignerForm.UndoBufferLength
  else
    lBufferLength := FDesignerForm.RedoBufferLength;

  if aBuffer[lBufferLength - 1].Page <> FDesignerForm.CurPage then Exit;

  _SetUndo;
  case aBuffer[lBufferLength - 1].Action of
    rmacChangeCellSize:
      begin
        _RestoreCellSize(aBuffer[lBufferLength - 1].Stream);
      end;
    rmacChangeGrid:
      begin
        _RestoreGridProp(aBuffer[lBufferLength - 1].Stream);
      end;
    rmacEdit:
      begin
        _RestoreSelectionCells(aBuffer[lBufferLength - 1].Stream);
      end;
    rmacChangePage:
      begin
        _RestorePageProp(aBuffer[lBufferLength - 1].Stream);
      end;
  end;

  FDesignerForm.ReleaseAction(@aBuffer[lBufferLength - 1]);
  if aBuffer = @FDesignerForm.UndoBuffer then
    FDesignerForm.UndoBufferLength := FDesignerForm.UndoBufferLength - 1
  else
    FDesignerForm.RedoBufferLength := FDesignerForm.RedoBufferLength - 1;

  FDesignerForm.EnableControls;
end;

procedure TRMGridReportPageEditor.Editor_DisableDraw;
begin
  FDesignerForm.Busy := False;
  FDesignerForm.InspBusy := False;
  SetGridNilProp;
  if FFieldListBox.Visible then
    FFieldListBox.Hide;
end;

procedure TRMGridReportPageEditor.Editor_EnableDraw;
begin
 //
end;

procedure TRMGridReportPageEditor.Editor_RedrawPage;
begin
 //
end;

procedure TRMGridReportPageEditor.Editor_Resize;
begin
 //
end;

procedure TRMGridReportPageEditor.Editor_Init;
begin
  FDesignerForm.Busy := False;
  FDesignerForm.InspBusy := False;
  SetGridNilProp;
end;

procedure TRMGridReportPageEditor.Editor_SetCurPage;
begin
  SetGridNilProp;

  FGrid := TRMGridReportPage(FDesignerForm.Page).Grid;
  SetGridProp;
  FGrid.CreateViewsName;
  FGrid.SetFocus;
  FDesignerForm.ResetSelection;
  cmbBandsDropDown(nil);
  OnGridClick(nil);
end;

procedure TRMGridReportPageEditor.Editor_SelectionChanged(aRefreshInspProp: Boolean);
var
  t: TRMView;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  try
    FDesignerForm.EnableControls;
    t := FGrid.Cells[FGrid.Selection.Left, FGrid.Selection.Top].View;
    ToolbarBorder.btnFrameTop.Down := t.TopFrame.Visible;
    ToolbarBorder.btnFrameLeft.Down := t.LeftFrame.Visible;
    ToolbarBorder.btnFrameBottom.Down := t.BottomFrame.Visible;
    ToolbarBorder.btnFrameRight.Down := t.RightFrame.Visible;
    ToolbarBorder.btnBias1Border.Down := t.LeftRightFrame = 4;
    ToolbarBorder.btnBias2Border.Down := t.LeftRightFrame = 1;

    ToolbarEdit.FBtnBackColor.CurrentColor := t.FillColor;
    ToolbarEdit.FBtnFrameColor.CurrentColor := t.TopFrame.Color;
    ToolbarEdit.FCmbFrameWidth.Text := FloatToStrF(RMFromMMThousandths(t.TopFrame.mmWidth, rmutScreenPixels), ffGeneral, 2, 2);
    if t is TRMCustomMemoView then
    begin
      with TRMCustomMemoView(t) do
      begin
        ToolbarEdit.FBtnFontColor.CurrentColor := Font.Color;
        if ToolbarEdit.FcmbFont.ItemIndex <> ToolbarEdit.FcmbFont.Items.IndexOf(Font.Name) then
          ToolbarEdit.FcmbFont.ItemIndex := ToolbarEdit.FcmbFont.Items.IndexOf(Font.Name);
        RMSetFontSize(TComboBox(ToolbarEdit.FCmbFontSize), Font.Height, Font.Size);
        ToolbarEdit.btnFontBold.Down := fsBold in Font.Style;
        ToolbarEdit.btnFontItalic.Down := fsItalic in Font.Style;
        ToolbarEdit.btnFontUnderline.Down := fsUnderline in Font.Style;
        case VAlign of
          rmVTop: ToolbarEdit.btnVTop.Down := True;
          rmVBottom: ToolbarEdit.btnVBottom.Down := True;
        else
          ToolbarEdit.btnVCenter.Down := True;
        end;
        case HAlign of
          rmhLeft: ToolbarEdit.btnHLeft.Down := True;
          rmhCenter: ToolbarEdit.btnHCenter.Down := True;
          rmhRight: ToolbarEdit.btnHRight.Down := True;
        else
          ToolbarEdit.btnHSpaceEqual.Down := True;
        end;
      end;
    end;

    if aRefreshInspProp then FDesignerForm.ShowPosition;

    FGrid.InvalidateRect(FGrid.Selection);
    Editor_ShowContent;
  finally
    FDesignerForm.Busy := False;
  end;
end;

procedure TRMGridReportPageEditor.Editor_FillInspFields;
var
  i, lCount: Integer;
  t, t1: TRMView;
  lList: TList;
  lObjects: array of TPersistent;
begin
  if (not FDesignerForm.InspForm.Visible) or (FDesignerForm.InspBusy) then Exit;

  FDesignerForm.InspBusy := True;
  try
    lList := Editor_PageObjects;
    if FDesignerForm.SelNum > 0 then
      t := lList[FDesignerForm.TopSelected]
    else
      t := nil;

    if (FDesignerForm.SelNum = 1) and (FDesignerForm.InspForm.Insp.ObjectCount = 1) and
      (FDesignerForm.InspForm.Insp.IndexOf(t) >= 0) then
    begin
      FDesignerForm.InspForm.Insp.UpdateItems;
    //    FInspForm.BeginUpdate;
    //    FInspForm.Insp.State := FInspForm.Insp.State + [ppsChanged];
    //    FInspForm.EndUpdate;
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
        for i := 0 to lList.Count - 1 do
        begin
          t1 := lList[i];
          if TRMView(t1).Selected and (t1 <> t) then
          begin
            Inc(lCount);
            SetLength(lObjects, lCount);
            lObjects[lCount - 1] := t1;
          //FInspForm.AddObject(t1);
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
  finally
    FDesignerForm.InspBusy := False;
  end;
end;

procedure TRMGridReportPageEditor.Editor_OnInspGetObjects(aList: TStrings);
var
  i: Integer;
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
  lSelection: TRect;

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
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
    _AddItem(FDesignerForm.Page.Objects[i]);
    //aList.Add(TRMView(FDesignerForm.Page.Objects[i]).Name);

  for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
    _AddItem(FDesignerForm.Report.Pages[i]);
//    aList.Add('Page' + IntToStr(i + 1));

  // Grid中的View
  lSelection := FGrid.Selection;
  for lCol := lSelection.Left to lSelection.Right do
  begin
    for lRow := lSelection.Top to lSelection.Bottom do
    begin
      lCell := FGrid.Cells[lCol, lRow];
      if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
      begin
        lCell.View.Selected := True;
        _AddItem(lCell.View);
        //aList.Add(lCell.View.Name);
      end;
    end;
  end;
end;

procedure TRMGridReportPageEditor.Editor_ShowPosition;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    FDesignerForm.StatusBar1.Panels[1].Text := RMLoadStr(rmRes + 578) +
      IntToStr(FDesignerForm.CodeMemo.CaretY) + '  ' + RMLoadStr(rmRes + 579) +
      IntToStr(FDesignerForm.CodeMemo.CaretX);
  end
  else
  begin
    FDesignerForm.StatusBar1.Panels[1].Text := '';
    if not FDesignerForm.InspBusy then
      Editor_FillInspFields;
  end;
end;

procedure TRMGridReportPageEditor.Editor_ShowContent;
var
  t: TRMView;
  lStr: string;
begin
  lStr := '';
  if FDesignerForm.SelNum = 1 then
  begin
    t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
    lStr := t.Name;
    if t.IsBand then
      lStr := lStr + ': ' + RMBandNames[TRMCustomBandView(t).BandType]
    else if t.Memo.Count > 0 then
      lStr := lStr + ': ' + t.Memo[0];
  end;

  FDesignerForm.StatusBar1.Panels[2].Text := lStr;
  if FGrid <> nil then
  begin
    ToolbarCellEdit.FEdtMemo.Text := FGrid.Cells[FGrid.Col, FGrid.Row].Text;
  end;
end;

function TRMGridReportPageEditor.Editor_PageObjects: TList;
var
  i, j: Integer;
  lCell: TRMCellInfo;
begin
  if FPageObjectList = nil then
    FPageObjectList := TList.Create;

  FPageObjectList.Clear;
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
    FPageObjectList.Add(FDesignerForm.Page.Objects[i]);

  if FGrid <> nil then
  begin
    for i := 1 to FGrid.RowCount - 1 do
    begin
      j := 1;
      while j < FGrid.ColCount do
      begin
        lCell := FGrid.Cells[j, i];
        if lCell.StartRow = i then
          FPageObjectList.Add(lCell.View);

        j := lCell.EndCol + 1;
      end;
    end;
  end;

  Result := FPageObjectList;
end;

procedure TRMGridReportPageEditor.SetGridProp;
begin
  FGrid.Parent := Panel2;
  FGrid.Align := alClient;
  FGrid.ScrollBars := ssBoth;
  FGrid.BorderStyle := bsSingle;

  if RMIsChineseGB then
    FGrid.ColWidths[0] := 80
  else
    FGrid.ColWidths[0] := 120;

  if (FDesignerForm.Page <> nil) and (FDesignerForm.Page is TRMGridReportPage) then
    FGrid.AutoCreateName := TRMGridReportPage(FDesignerForm.Page).AutoCreateName
  else
    FGrid.AutoCreateName := True;

  FGrid.CurrentCol := -1;
  FGrid.CurrentRow := -1;
  FGrid.DrawPicture := True;
//  if FDesignerComp <> nil then
//  	FGrid.DrawPicture := FDesignerComp.DrawPicture;

  FGrid.PopupMenu := FSelectionMenu;
  FGrid.OnDblClick := OnGridDblClickEvent;
  FGrid.OnClick := OnGridClick;
  FGrid.OnChange := OnGridChange;
  FGrid.OnDragOver := OnGridDragOver;
  FGrid.OnDragDrop := OnGridDragDrop;
  FGrid.OnRowHeaderClick := OnGridRowHeaderClick;
  FGrid.OnRowHeaderDblClick := OnGridRowHeaderDblClick;
  FGrid.OnBeginSizingCell := OnGridBeginSizingCell;
  FGrid.OnKeyDown := OnGridKeyDown;
  FGrid.OnBeforeChangeCell := OnGridBeforeChangeCell;
  FGrid.OnDropDownField := OnGridDropDownField;
  FGrid.OnDropDownFieldClick := OnGridDropDownFieldClick;

  SetGridHeader;
end;

procedure TRMGridReportPageEditor.SetGridNilProp;
begin
  if FGrid <> nil then
  begin
    FGrid.FreeEditor;
    FGrid.Parent := nil;
    FGrid.DrawPicture := False;
    FGrid.AutoCreateName := True;
    FGrid.Align := alNone;
    FGrid.PopupMenu := nil;
    FGrid.OnDblClick := nil;
    FGrid.OnClick := nil;
    FGrid.OnSelectCell := nil;
    FGrid.OnChange := nil;
    FGrid.OnDragOver := nil;
    FGrid.OnDragDrop := nil;
    FGrid.OnRowHeaderClick := nil;
    FGrid.OnRowHeaderDblClick := nil;
    FGrid.OnBeginSizingCell := nil;
    FGrid.OnKeyDown := nil;
    FGrid.OnBeforeChangeCell := nil;
    FGrid.OnDropDownField := nil;
    FGrid.OnDropDownFieldClick := nil;
  end;
  FGrid := nil;
end;

procedure TRMGridReportPageEditor.RefreshProp;
begin
  FGrid.InvalidateGrid;
  Editor_FillInspFields;
  Editor_SelectionChanged(True);
end;

procedure TRMGridReportPageEditor.SetGridHeader;
var
//  i, j, k: Integer;
//  t, t1: TRMView;
  i: Integer;
  t: TRMView;
begin
  if FGrid = nil then Exit;

  for i := 1 to FGrid.RowCount - 1 do
  begin
    t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[i];
    if t <> nil then
      FGrid.Cells[0, i].Text := RMBandNames[TRMCustomBandView(t).BandType]
    else
      FGrid.Cells[0, i].Text := '';
  end;
{  i := 1;
  while i < FGrid.RowCount do
  begin
    FGrid.SplitCell(0, FGrid.Cells[0, i].StartRow, 0, FGrid.Cells[0, i].EndRow);
    t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[i];
    if t <> nil then
    begin
      k := 0;
      for j := i + 1 to FGrid.RowCount - 1 do
      begin
        t1 := TRMGridReportPage(FDesignerForm.Page).RowBandViews[j];
        if t1 <> t then
          Break;

        Inc(k);
      end;

      FGrid.Cells[0, i].Text := RMBandNames[TRMCustomBandView(t).BandType];
      FGrid.MergeCell(0, i, 0, i + k);
      Inc(i, k + 1);
    end
    else
    begin
      FGrid.Cells[0, i].Text := '';
      Inc(i);
    end;
  end;}
end;

procedure TRMGridReportPageEditor.OnGridDblClickEvent(Sender: TObject);
var
  lCell: TRMCellInfo;
begin
  lCell := FGrid.GetCellInfo(FGrid.Selection.Left, FGrid.Selection.Top);
  if lCell.View is TRMSubReportView then
  begin
    FDesignerForm.CurPage := TRMSubReportView(lCell.View).SubPage;
  end
  else
    lCell.View.ShowEditor;
end;

procedure TRMGridReportPageEditor.OnGridClick(Sender: TObject);
var
  lSelection: TRect;
  lCell: TRMCellInfo;
  lCol, lRow: Integer;
  t: TRMView;
begin
  if FDesignerForm.Busy or (FGrid = nil) then Exit;
  if (FGrid.Col < 1) or (FGrid.Row < 1) then Exit;

  FDesignerForm.Busy := True;
  t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row];
  if t <> nil then
  begin
    ToolbarBorder.cmbBands.ItemIndex := ToolbarBorder.cmbBands.Items.IndexOf(
      RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')');
    if (t is TRMBandMasterData) and (not TRMBandMasterData(t).IsVirtualDataSet) and
      (TRMBandMasterData(t).DataSetName <> '') then
      RM_Dsg_LastDataSet := TRMBandMasterData(t).DataSetName;
  end
  else
  begin
    ToolbarBorder.cmbBands.ItemIndex := 0;
  end;

  if FGrid.HeaderClick then
  begin
    FDesignerForm.Busy := False;
    if t <> nil then
      FDesignerForm.InspSelectionChanged(t.Name);

    Exit;
  end;

  try
    FDesignerForm.UnSelectAll;
    lSelection := FGrid.Selection;
    for lCol := lSelection.Left to lSelection.Right do
    begin
      for lRow := lSelection.Top to lSelection.Bottom do
      begin
        lCell := FGrid.Cells[lCol, lRow];
        if (lCell.StartCol = lCol) and (lCell.StartRow = lRow) then
        begin
          Inc(FDesignerForm.SelNum);
          lCell.View.Selected := True;
        end;
      end;
    end;

    if RM_Class.RMShowDropDownField and (FGrid.Col = FGrid.CurrentCol) and
      (FGrid.Row = FGrid.CurrentRow) then
    begin
    end;
  finally
    FDesignerForm.Busy := False;
    Editor_SelectionChanged(True);
  end;
end;

procedure TRMGridReportPageEditor.OnGridChange(Sender: TObject);
begin
  FDesignerForm.Modified := True;
end;

procedure TRMGridReportPageEditor.OnGridDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := (Source = FDesignerForm.FieldForm.lstFields) and
    (FDesignerForm.DesignerRestrictions * [rmdrDontCreateObj] = []);
end;

procedure TRMGridReportPageEditor.OnGridDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  lCol, lRow: Integer;
  lCell: TRMCellInfo;
begin
  FGrid.MouseToCell(X, Y, lCol, lRow);
  if (lCol >= 1) and (lRow >= 1) then
  begin
    lCell := FGrid.Cells[lCol, lRow];
    if lCell.View is TRMCustomMemoView then
    begin
      if (FGrid.Row <> lCell.StartRow) or (FGrid.Col <> lCell.StartCol) then
      begin
        FGrid.Selection := Rect(lCell.StartCol, lCell.StartRow, lCell.EndCol, lCell.EndRow);
        OnGridClick(FGrid);
      end;

      FDesignerForm.BeforeChange;
      lCell.Text := '[' + FDesignerForm.FieldForm.DBField + ']';
      if lCell.View is TRMCustomMemoView then
        TRMCustomMemoView(lCell.View).DBFieldOnly := True;

      FGrid.InvalidateCell(lCell.StartCol, lCell.StartRow);
      //FGrid.InvalidateGrid;
      FDesignerForm.AfterChange;
    end;
  end;
end;

procedure TRMGridReportPageEditor.OnGridRowHeaderClick(Sender: TObject; X, Y: Integer);
var
  lBand: TRMView;
begin
  if FDesignerForm.Busy then Exit;

  lBand := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row];
  if lBand <> nil then
  begin
    //ToolbarBorder.cmbBands.ItemIndex := ToolbarBorder.cmbBands.Items.IndexOf(RMBandNames[TRMCustomBandView(lBand).BandType] + '(' + lBand.Name + ')');
    FDesignerForm.UnSelectAll;
    FDesignerForm.SelNum := 1;
    lBand.Selected := True;
    FDesignerForm.ShowPosition;
  end
  else
  begin
    //ToolbarBorder.cmbBands.ItemIndex := 0;
    FGrid.HeaderClick := False;
  end;
end;

procedure TRMGridReportPageEditor.OnGridRowHeaderDblClick(Sender: TObject);
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
  t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row];
  if t <> nil then
  begin
    FDesignerForm.InspSelectionChanged(t.Name);
    if (t is TRMBandMasterData) or (t is TRMBandCrossHeader) then
      _EditDataBand
    else if t is TRMBandGroupHeader then
      _EditGroupHeaderBand;
  end;
end;

procedure TRMGridReportPageEditor.OnGridBeginSizingCell(Sender: TObject);
begin
  Editor_AddUndoAction(rmacChangeCellSize);
end;

procedure TRMGridReportPageEditor.OnGridBeforeChangeCell(aGrid: TRMGridEx;
  aCell: TRMCellInfo);
begin
  FDesignerForm.Modified := True;
  Editor_AddUndoAction(rmacEdit);
end;

procedure TRMGridReportPageEditor.OnGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Shift = [] then
  begin
    if Key = VK_F2 then
      OnGridDblClickEvent(nil);
    if (Key = VK_RETURN) and (not (rmgoEditing in FGrid.Options)) then
      OnGridDblClickEvent(nil);
  end
  else if (Key = VK_UP) and (Shift = [ssAlt]) then
  begin
    ToolbarBorder.btnDecHeight.Click;
  end
  else if (Key = VK_DOWN) and (Shift = [ssAlt]) then
  begin
    ToolbarBorder.btnIncHeight.Click;
  end
  else if (Key = VK_LEFT) and (Shift = [ssAlt]) then
  begin
    ToolbarBorder.btnDecWidth.Click;
  end
  else if (Key = VK_RIGHT) and (Shift = [ssAlt]) then
  begin
    ToolbarBorder.btnIncWidth.Click;
  end;
end;

procedure TRMGridReportPageEditor.Editor_DoClick(Sender: TObject);
var
  i, j: Integer;
  lSelection: TRect;
  lCell: TRMCellInfo;

  procedure _SetOneCell;
  var
    lFontSize: Integer;
  begin
    if TControl(Sender).Tag in [TAG_SetFontName, TAG_SetFontSize, TAG_FontBold,
      TAG_FontItalic, TAG_FontUnderline] then
    begin
      if lCell.View is TRMCustomMemoView then
        TRMCustomMemoView(lCell.View).StyleName := '';
    end;

    case TControl(Sender).Tag of
      TAG_SetFontName:
        begin
          if ToolbarEdit.FcmbFont.ItemIndex >= 0 then
          begin
            lCell.Font.Name := ToolbarEdit.FcmbFont.Text;
            if RMIsChineseGB then
            begin
              if ByteType(lCell.Font.Name, 1) = mbSingleByte then
                lCell.Font.Charset := ANSI_CHARSET
              else
                lCell.Font.Charset := GB2312_CHARSET;
            end;
          end;
        end;
      TAG_SetFontSize:
        begin
          if ToolbarEdit.FCmbFontSize.ItemIndex >= 0 then
          begin
            lFontSize := RMGetFontSize(TComboBox(ToolbarEdit.FCmbFontSize));
            if lFontSize >= 0 then
              lCell.Font.Size := lFontSize
            else
              lCell.Font.Height := lFontSize;
          end;
        end;
      TAG_FontBold:
        begin
          if ToolbarEdit.btnFontBold.Down then
            lCell.Font.Style := lCell.Font.Style + [fsBold]
          else
            lCell.Font.Style := lCell.Font.Style - [fsBold];
        end;
      TAG_FontItalic:
        begin
          if ToolbarEdit.btnFontItalic.Down then
            lCell.Font.Style := lCell.Font.Style + [fsItalic]
          else
            lCell.Font.Style := lCell.Font.Style - [fsItalic];
        end;
      TAG_FontUnderline:
        begin
          if ToolbarEdit.btnFontUnderline.Down then
            lCell.Font.Style := lCell.Font.Style + [fsUnderline]
          else
            lCell.Font.Style := lCell.Font.Style - [fsUnderline];
        end;
      TAG_HAlignLeft..TAG_HAlignEuqal:
        begin
          lCell.HAlign := TRMHAlign(TControl(Sender).Tag - TAG_HAlignLeft);
          TRMToolbarButton(Sender).Down := True;
        end;
      TAG_FontColor:
        begin
          lCell.Font.Color := ToolbarEdit.FBtnFontColor.CurrentColor;
        end;
      TAG_VAlignTop..TAG_VAlignBottom:
        begin
          lCell.VAlign := TRMVAlign(TControl(Sender).Tag - TAG_VAlignTop);
          TRMToolbarButton(Sender).Down := True;
        end;
      TAG_SetFrameTop: lCell.View.TopFrame.Visible := ToolbarBorder.btnFrameTop.Down;
      TAG_SetFrameLeft: lCell.View.LeftFrame.Visible := ToolbarBorder.btnFrameLeft.Down;
      TAG_SetFrameBottom: lCell.View.BottomFrame.Visible := ToolbarBorder.btnFrameBottom.Down;
      TAG_SetFrameRight: lCell.View.RightFrame.Visible := ToolbarBorder.btnFrameRight.Down;
      TAG_BackColor:
        begin
          lCell.FillColor := ToolbarEdit.FBtnBackColor.CurrentColor;
        end;
      TAG_FrameColor:
        begin
          lCell.View.LeftFrame.Color := ToolbarEdit.FBtnFrameColor.CurrentColor;
          lCell.View.TopFrame.Color := ToolbarEdit.FBtnFrameColor.CurrentColor;
          lCell.View.RightFrame.Color := ToolbarEdit.FBtnFrameColor.CurrentColor;
          lCell.View.BottomFrame.Color := ToolbarEdit.FBtnFrameColor.CurrentColor;
        end;
      TAG_FrameSize:
        begin
          lCell.View.LeftFrame.mmWidth := RMToMMThousandths(StrToFloat(ToolbarEdit.FCmbFrameWidth.Text), rmutScreenPixels);
          lCell.View.TopFrame.mmWidth := lCell.View.LeftFrame.mmWidth;
          lCell.View.RightFrame.mmWidth := lCell.View.LeftFrame.mmWidth;
          lCell.View.BottomFrame.mmWidth := lCell.View.LeftFrame.mmWidth;
        end;
      TAG_SetFrame:
        begin
          lCell.View.LeftFrame.Visible := True;
          lCell.View.RightFrame.Visible := True;
          lCell.View.TopFrame.Visible := True;
          lCell.View.BottomFrame.Visible := True;
        end;
      TAG_NoFrame:
        begin
          lCell.View.LeftFrame.Visible := False;
          lCell.View.RightFrame.Visible := False;
          lCell.View.TopFrame.Visible := False;
          lCell.View.BottomFrame.Visible := False;
        end;
      TAG_Frame1:
        begin
          if lCell.StartRow = FGrid.Selection.Top then
            lCell.View.TopFrame.Visible := True;
          if lCell.StartCol = FGrid.Selection.Left then
            lCell.View.LeftFrame.Visible := True;
          if lCell.EndCol = FGrid.Selection.Right then
            lCell.View.RightFrame.Visible := True;
          if lCell.EndRow = FGrid.Selection.Bottom then
            lCell.View.BottomFrame.Visible := True;
        end;
      TAG_Frame2:
        begin
          if lCell.StartRow <> FGrid.Selection.Top then
            lCell.View.TopFrame.Visible := True;
          if lCell.StartCol <> FGrid.Selection.Left then
            lCell.View.LeftFrame.Visible := True;
          if lCell.EndCol <> FGrid.Selection.Right then
            lCell.View.RightFrame.Visible := True;
          if lCell.EndRow <> FGrid.Selection.Bottom then
            lCell.View.BottomFrame.Visible := True;
        end;
      TAG_Frame3:
        begin
          if ToolbarBorder.btnBias1Border.Down then
            lCell.View.LeftRightFrame := 4
          else
            lCell.View.LeftRightFrame := 0;
        end;
      TAG_Frame4:
        begin
          if ToolbarBorder.btnBias2Border.Down then
            lCell.View.LeftRightFrame := 1
          else
            lCell.View.LeftRightFrame := 0;
        end;
    end; {end Case}
  end;

begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  lSelection := FGrid.Selection;
  case TControl(Sender).Tag of
    TAG_DecWidth:
      begin
        Editor_AddUndoAction(rmacChangeCellSize);
        for i := lSelection.Left to lSelection.Right do
          FGrid.ColWidths[i] := FGrid.ColWidths[i] - 1;
      end;
    TAG_IncWidth:
      begin
        Editor_AddUndoAction(rmacChangeCellSize);
        for i := lSelection.Left to lSelection.Right do
          FGrid.ColWidths[i] := FGrid.ColWidths[i] + 1;
      end;
    TAG_DecHeight:
      begin
        Editor_AddUndoAction(rmacChangeCellSize);
        for i := lSelection.Top to lSelection.Bottom do
          FGrid.RowHeights[i] := FGrid.RowHeights[i] - 1;
      end;
    TAG_IncHeight:
      begin
        Editor_AddUndoAction(rmacChangeCellSize);
        for i := lSelection.Top to lSelection.Bottom do
          FGrid.RowHeights[i] := FGrid.RowHeights[i] + 1;
      end;
  else
    Editor_AddUndoAction(rmacEdit);
    for i := lSelection.Top to lSelection.Bottom do
    begin
      j := lSelection.Left;
      while j <= lSelection.Right do
      begin
        lCell := FGrid.Cells[j, i];
        if lCell.StartRow = i then
          _SetOneCell;
        j := lCell.EndCol + 1;
      end;
    end;
  end;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.Editor_SelectObject(aObjName: string);
var
  i: Integer;
  t: TRMView;
  lList: TList;
  lPage: TRMCustomPage;
begin
  lList := Editor_PageObjects;
  t := nil;
  for i := 0 to lList.Count - 1 do
  begin
    if AnsiCompareText(aObjName, TRMView(lList[i]).Name) = 0 then
    begin
      t := lList[i];
      Break;
    end;
  end;

  if t <> nil then
  begin
    FDesignerForm.UnSelectAll;
    FDesignerForm.SelNum := 1;
    t.Selected := True;
    Editor_SelectionChanged(True);
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

procedure TRMGridReportPageEditor.Editor_SetObjectsID;
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

procedure TRMGridReportPageEditor.itmInsertLeftColumnClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i, lCurCol: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp, 'Caption', rmRes + 854);
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 855);
    tmp.btnCount.MinValue := 1;
    tmp.btnCount.MaxValue := 99;
    tmp.btnCount.Value := 1;
    tmp.btnCount.Left := 120;
    tmp.RB6.Enabled := False;
    tmp.RB7.Enabled := False;
    tmp.RB8.Enabled := False;
    tmp.RB9.Enabled := False;
    if tmp.ShowModal = mrOK then
    begin
      Editor_AddUndoAction(rmacChangeGrid);
      FDesignerForm.Modified := True;
      lCurCol := FGrid.Col;
      THackGridEx(FGrid).InLoadSaveMode := True;
      for i := 1 to tmp.btnCount.AsInteger do
      begin
        FGrid.InsertColumn(lCurCol, False);
      end;

      FGrid.CreateViewsName;
      FGrid.InvalidateGrid;
    end;
  finally
    tmp.Free;
    THackGridEx(FGrid).InLoadSaveMode := False;
  end;
end;

procedure TRMGridReportPageEditor.itmInsertTopRowClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i, lCurRow: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp, 'Caption', rmRes + 856);
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 857);
    tmp.btnCount.MinValue := 1;
    tmp.btnCount.MaxValue := 99;
    tmp.btnCount.Value := 1;
    tmp.btnCount.Left := 120;
    tmp.RB6.Enabled := False;
    tmp.RB7.Enabled := False;
    tmp.RB8.Enabled := False;
    tmp.RB9.Enabled := False;
    if tmp.ShowModal = mrOK then
    begin
      Editor_AddUndoAction(rmacChangeGrid);
      FDesignerForm.Modified := True;
      lCurRow := FGrid.Row;
      THackGridEx(FGrid).InLoadSaveMode := True;
      for i := 1 to tmp.btnCount.AsInteger do
      begin
        FGrid.InsertRow(lCurRow, False);
      end;

      FGrid.CreateViewsName;
      SetGridHeader;
      FGrid.InvalidateGrid;
    end;
  finally
    tmp.Free;
    THackGridEx(FGrid).InLoadSaveMode := False;
  end;
end;

procedure TRMGridReportPageEditor.itmDeleteColumnClick(Sender: TObject);
var
  i, lBeginCol, lEndCol: Integer;
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  lBeginCol := FGrid.Selection.Left;
  lEndCol := FGrid.Selection.Right;
  for i := 0 to lEndCol - lBeginCol do
    FGrid.DeleteColumn(lBeginCol, i = (lEndCol - lBeginCol));

  FDesignerForm.Busy := False;
  OnGridClick(nil);
end;

procedure TRMGridReportPageEditor.itmDeleteRowClick(Sender: TObject);
var
  i, lBeginRow, lEndRow: Integer;
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  lBeginRow := FGrid.Selection.Top;
  lEndRow := FGrid.Selection.Bottom;
  for i := 0 to lEndRow - lBeginRow do
    FGrid.DeleteRow(lBeginRow, i = (lEndRow - lBeginRow));

  SetGridHeader;
  FDesignerForm.Busy := False;
  OnGridClick(nil);
end;

procedure TRMGridReportPageEditor.btnMergeClick(Sender: TObject);
begin
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;
  FGrid.MergeSelection;
end;

procedure TRMGridReportPageEditor.btnSplitClick(Sender: TObject);
var
  lRect: TRect;
begin
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  lRect := FGrid.Selection;
  FGrid.SplitCell(lRect.Left, lRect.Top, lRect.Right, lRect.Bottom);
end;

procedure TRMGridReportPageEditor.btnDBFieldClick(Sender: TObject);
var
  lStr, lStr1: string;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.ReadOnly then Exit;
    lStr := RMDesigner.InsertDBField(nil);
    if lStr <> '' then
    begin
      Delete(lStr, 1, 1);
      Delete(lStr, Length(lStr), 1);
      lStr := 'GetValue(''' + lStr + ''')';
      if FDesignerForm.CodeMemo.SelLength > 0 then
        FDesignerForm.CodeMemo.SelText := lStr
      else
      begin
        lStr1 := FDesignerForm.CodeMemo.Lines[FDesignerForm.CodeMemo.CaretY];
        while Length(lStr1) <= FDesignerForm.CodeMemo.CaretX do
          lStr1 := lStr1 + ' ';
        System.Insert(lStr, lStr1, FDesignerForm.CodeMemo.CaretX + 1);
        FDesignerForm.CodeMemo.Lines[FDesignerForm.CodeMemo.CaretY] := lStr1;
      end;

      FDesignerForm.Modified := True;
    end;
  end
  else
  begin
    lStr := RMDesigner.InsertDBField(nil);
    if lStr <> '' then
    begin
      FDesignerForm.BeforeChange;
      FGrid.Cells[FGrid.Col, FGrid.Row].View.Memo.Text := lStr;
      if FGrid.Cells[FGrid.Col, FGrid.Row].View is TRMCustomMemoView then
        TRMCustomMemoView(FGrid.Cells[FGrid.Col, FGrid.Row].View).DBFieldOnly := FDesignerForm.DBFieldOnly;

      FDesignerForm.AfterChange;
      THackGridEx(FGrid).InvalidateCell(FGrid.Col, FGrid.Row);
    end;
  end;
end;

procedure TRMGridReportPageEditor.btnExpressionClick(Sender: TObject);
var
  lStr: string;
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

{        if FCodeMemo.SelLength > 0 then
          FCodeMemo.SelText := listr
        else
        begin
          listr1 := FCodeMemo.Lines[FCodeMemo.CaretY];
          while Length(listr1) <= FCodeMemo.CaretX do
            listr1 := listr1 + ' ';
          System.Insert(listr, listr1, FCodeMemo.CaretX + 1);
          FCodeMemo.Lines[FCodeMemo.CaretY] := listr1;
        end;}
      end;
    end;
  end
  else
  begin
    lStr := FDesignerForm.InsertExpression(nil);
    if lStr <> '' then
    begin
      FDesignerForm.BeforeChange;
      FGrid.Cells[FGrid.Col, FGrid.Row].View.Memo.Text := lStr;
      if FGrid.Cells[FGrid.Col, FGrid.Row].View is TRMCustomMemoView then
        TRMCustomMemoView(FGrid.Cells[FGrid.Col, FGrid.Row].View).DBFieldOnly := False;

      FDesignerForm.AfterChange;
      THackGridEx(FGrid).InvalidateCell(FGrid.Col, FGrid.Row);
    end;
  end;
end;

procedure TRMGridReportPageEditor.btnColumnMinClick(Sender: TObject);
var
  i, lMinColumn: Integer;
  lSelection: TRect;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeCellSize);
  lSelection := FGrid.Selection;
  lMinColumn := FGrid.ColWidths[lSelection.Left];
  for i := lSelection.Left to lSelection.Right do
    lMinColumn := Min(lMinColumn, FGrid.ColWidths[i]);
  for i := lSelection.Left to lSelection.Right do
    FGrid.ColWidths[i] := lMinColumn;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.btnColumnMaxClick(Sender: TObject);
var
  i, lMaxColumn: Integer;
  lSelection: TRect;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeCellSize);
  lSelection := FGrid.Selection;
  lMaxColumn := FGrid.ColWidths[lSelection.Left];
  for i := lSelection.Left to lSelection.Right do
    lMaxColumn := Max(lMaxColumn, FGrid.ColWidths[i]);
  for i := lSelection.Left to lSelection.Right do
    FGrid.ColWidths[i] := lMaxColumn;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.btnRowMinClick(Sender: TObject);
var
  i, lMinRowHeight: Integer;
  lSelection: TRect;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeCellSize);
  lSelection := FGrid.Selection;
  lMinRowHeight := FGrid.RowHeights[lSelection.Top];
  for i := lSelection.Top to lSelection.Bottom do
    lMinRowHeight := Min(lMinRowHeight, FGrid.RowHeights[i]);
  for i := lSelection.Top to lSelection.Bottom do
    FGrid.RowHeights[i] := lMinRowHeight;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.btnRowMaxClick(Sender: TObject);
var
  i, lMaxRowHeight: Integer;
  lSelection: TRect;
begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeCellSize);
  lSelection := FGrid.Selection;
  lMaxRowHeight := FGrid.RowHeights[lSelection.Top];
  for i := lSelection.Top to lSelection.Bottom do
    lMaxRowHeight := Max(lMaxRowHeight, FGrid.RowHeights[i]);
  for i := lSelection.Top to lSelection.Bottom do
    FGrid.RowHeights[i] := lMaxRowHeight;

  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.cmbBandsDropDown(Sender: TObject);
var
  i: Integer;
  t: TRMView;
  lSaveItemIndex: Integer;
begin
  lSaveItemIndex := ToolbarBorder.cmbBands.ItemIndex;
  ToolbarBorder.cmbBands.Items.Clear;
  ToolbarBorder.cmbBands.Items.Add('');
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
  begin
    t := FDesignerForm.Page.Objects[i];
    if t.IsBand then
      ToolbarBorder.cmbBands.Items.Add(RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')');
  end;
  ToolbarBorder.cmbBands.ItemIndex := lSaveItemIndex;
end;

procedure TRMGridReportPageEditor.cmbBandsClick(Sender: TObject);
var
  lStr: string;
  i: Integer;
begin
  FDesignerForm.Modified := True;
  if ToolbarBorder.cmbBands.ItemIndex < 1 then
  begin
    for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
      TRMGridReportPage(FDesignerForm.Page).RowBandViews[i] := nil;

    FDesignerForm.UnselectAll;
    Editor_SelectionChanged(True);
  end
  else
  begin
    lStr := ToolbarBorder.cmbBands.Text;
    if lStr <> '' then
    begin
      SetLength(lStr, Length(lStr) - 1);
      lStr := Copy(lStr, Pos('(', lStr) + 1, Length(lStr));
      for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
        TRMGridReportPage(FDesignerForm.Page).RowBandViews[i] := FDesignerForm.Page.FindObject(lStr);

      FDesignerForm.InspSelectionChanged(lStr);
    end;
  end;

  SetGridHeader;
  FGrid.InvalidateGrid;
end;

procedure TRMGridReportPageEditor.DeleteOneBand(aBandName: string; aBand: TRMView);
var
  i: Integer;
begin
  if aBandName <> '' then
  begin
    Editor_AddUndoAction(rmacChangePage);
    FDesignerForm.Modified := True;
    SetLength(aBandName, Length(aBandName) - 1);
    aBandName := Copy(aBandName, Pos('(', aBandName) + 1, Length(aBandName));
    for i := 0 to FGrid.RowCount - 1 do
    begin
      if TRMGridReportPage(FDesignerForm.Page).RowBandViews[i] = aBand then
      begin
        TRMGridReportPage(FDesignerForm.Page).RowBandViews[i] := nil;
        if i = FGrid.Row then
          ToolbarBorder.cmbBands.ItemIndex := 0;
      end
    end;

    cmbBandsDropDown(nil);
    SetGridHeader;
    FDesignerForm.Page.Delete(FDesignerForm.Page.IndexOf(aBandName));
    FGrid.InvalidateGrid;
    if AnsiCompareText(FDesignerForm.InspForm.cmbObjects.Text, aBandName) = 0 then
    begin
      FDesignerForm.UnSelectAll;
      FDesignerForm.SelNum := 0;
      Editor_SelectionChanged(True);
    end;
  end;
end;

procedure TRMGridReportPageEditor.btnDeleteBandClick(Sender: TObject);
var
  lStr: string;
begin
  if ToolbarBorder.cmbBands.ItemIndex > 0 then
  begin
    lStr := ToolbarBorder.cmbBands.Text;
    DeleteOneBand(lStr, TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row]);
  end;
end;

procedure TRMGridReportPageEditor.PopupMenuBandsPopup(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FPopupMenuBands.Items.Count - 1 do
    SetBandMenuItemEnable(TRMMenuItem(FPopupMenuBands.Items[i]));
end;

procedure TRMGridReportPageEditor.PopupMenuDeleteBandsPopup(Sender: TObject);
var
  i: Integer;
  t: TRMView;
{$IFDEF USE_TB2K}
  lItem: TTBItem;
{$ELSE}
  lItem: TRMMenuItem;
{$ENDIF}
begin
  FPopupMenuDeleteBands.Items.Clear;
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
  begin
    t := FDesignerForm.Page.Objects[i];
    if t.IsBand then
    begin
{$IFDEF USE_TB2k}
      lItem := TTBItem.Create(ToolbarBorder.btnDeleteBand);
      lItem.Tag := THackView(t).ObjectID;
      lItem.Caption := RMBandNames[TRMBandType(t)] + '(' + t.Name + ')';
      lItem.OnClick := OnDeleteBandEvent;
      ToolbarBorder.btnAddBand.Add(lItem);
{$ELSE}
      lItem := TRMMenuItem.Create(FPopupMenuDeleteBands);
      lItem.Caption := RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')';
      lItem.Tag := THackView(t).ObjectID;
      lItem.OnClick := OnDeleteBandEvent;
      FPopupMenuDeleteBands.Items.Add(litem);
{$ENDIF}
    end;
  end;
end;

function TRMGridReportPageEditor.HaveBand(aBandType: TRMBandType): Boolean;
var
  i: Integer;
  t: TRMView;
begin
  Result := False;
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
  begin
    t := FDesignerForm.Page.Objects[i];
    if t.IsBand then
    begin
      if aBandType = TRMCustomBandView(t).BandType then
      begin
        Result := True;
        break;
      end;
    end;
  end;
end;

procedure TRMGridReportPageEditor.OnDeleteBandEvent(Sender: TObject);
var
  t: TRMView;

  function _FindObjectByID(aID: Integer): TRMView;
  var
    i: Integer;
    t: TRMView;
  begin
    Result := nil;
    for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
    begin
      t := FDesignerForm.Page.Objects[i];
      if THackView(t).ObjectID = aID then
      begin
        Result := t;
        Break;
      end;
    end;
  end;

begin
  t := _FindObjectByID(TComponent(Sender).Tag);
  DeleteOneBand(RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')', t);
end;

procedure TRMGridReportPageEditor.OnAddBandEvent(Sender: TObject);
var
  i: integer;
  t: TRMView;
  lStr: string;
begin
  Editor_AddUndoAction(rmacChangePage);
  FDesignerForm.UnselectAll;
  t := RMCreateBand(TRMBandType(TComponent(Sender).Tag));
  t.ParentPage := FDesignerForm.Page;
  cmbBandsDropDown(nil);
  ToolbarBorder.cmbBands.ItemIndex := ToolbarBorder.cmbBands.Items.IndexOf(RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')');

  lStr := t.Name;
  for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
  begin
    TRMGridReportPage(FDesignerForm.Page).RowBandViews[i] := FDesignerForm.Page.FindObject(lStr);
  end;

  FDesignerForm.InspSelectionChanged(lStr);

  FDesignerForm.SetObjectID(t);
  SetGridHeader;
  FGrid.InvalidateGrid;
  FDesignerForm.Modified := True;

  OnGridRowHeaderDblClick(nil);
end;

const
  DefaultMenuItemNum = 5;

procedure TRMGridReportPageEditor.SelectionMenuPopup(Sender: TObject);
var
  i, lPos: Integer;
  lCell: TRMCellInfo;
  lMenuItem: TRMMenuItem;
  lBand: TRMView;

  procedure _CreateBandMenuItem(aMenu: TRMSubmenuItem);
  var
    i: Integer;
    lMenuItem: TRMMenuItem;
    t: TRMView;
  begin
    aMenu.Clear;
    lMenuItem := TRMMenuItem.Create(Self);
    lMenuItem.Caption := '[None]';
    lMenuItem.Tag := 0;
    lMenuItem.OnClick := itmGridMenuBandClick;
    lMenuItem.AddToMenu(aMenu);

    for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
    begin
      t := FDesignerForm.Page.Objects[i];
      if t.IsBand then
      begin
        lMenuItem := TRMMenuItem.Create(Self);
        lMenuItem.Caption := RMBandNames[TRMCustomBandView(t).BandType] + '(' + t.Name + ')';
        //        lMenuItem.Checked := FInspForm.Visible;
        lMenuItem.OnClick := itmGridMenuBandClick;
        lMenuItem.Tag := 1;
        lMenuItem.AddToMenu(aMenu);
      end;
    end;
  end;

begin
  if THackGridEx(FGrid).RightClickColHeader then // 列标题上右键事件
  begin
    Abort;
  end;

  //设置Band类型菜单可操作性
  for i := 0 to itmInsertBand.Count - 1 do
    SetBandMenuItemEnable(TRMMenuItem(itmInsertBand.Items[i]));

  if THackGridEx(FGrid).RightClickRowHeader then // 行标题上右键事件
  begin
    lBand := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row]; // 右键选择栏目栏目
    if lBand <> nil then
    begin
      ToolbarBorder.cmbBands.ItemIndex := ToolbarBorder.cmbBands.Items.IndexOf(RMBandNames[TRMCustomBandView(lBand).BandType] + '(' + lBand.Name + ')');
      FDesignerForm.UnSelectAll;
      FDesignerForm.SelNum := 1;
      lBand.Selected := True;
      Editor_ShowPosition;
    end;

    for i := 0 to FSelectionMenu.Items.Count - 1 do
      FSelectionMenu.Items[i].Visible := False;

    itmGridMenuBandProp.Visible := True;
    itmInsertBand.Visible := True;
    itmSelectBand.Visible := True;
    _CreateBandMenuItem(itmSelectBand);

    lPos := FSelectionMenu.Items.IndexOf(itmFrameType) + DefaultMenuItemNum;
    while FSelectionMenu.Items.Count > lPos do
      FSelectionMenu.Items.Delete(lPos);

    if TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Selection.Top] <> nil then
      TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Selection.Top].DefinePopupMenu(TRMCustomMenuItem(FSelectionMenu.Items));

    FSelectionMenu.Items.Add(RMNewLine());

    lMenuItem := TRMMenuItem.Create(Self);
    lMenuItem.Caption := RMLoadStr(rmRes + 211);
    lMenuItem.Checked := FDesignerForm.InspForm.Visible;
    lMenuItem.OnClick := Pan5Click;
    FSelectionMenu.Items.Add(lMenuItem);

    Exit;
  end
  else
  begin
    itmGridMenuBandProp.Visible := False;
    for i := 1 to FSelectionMenu.Items.Count - 1 do
      FSelectionMenu.Items[i].Visible := True;

    itmInsertBand.Visible := True;
    itmSelectBand.Visible := True;
  end;

  lCell := FGrid.GetCellInfo(FGrid.Selection.Left, FGrid.Selection.Top);
  case lCell.View.ObjectType of
    rmgtMemo: itmMemoView.Checked := True;
    rmgtCalcMemo: itmCalcMemoView.Checked := True;
    rmgtPicture: itmPictureView.Checked := True;
    rmgtSubReport: itmSubReportView.Checked := True;
  else
    itmCellType.Items[RM_AddInObjectOffset + FAddinObjects.IndexOf(lCell.View.ClassName)].Checked := True;
  end;

 // 设置单元格中view的属性的右键菜单
  padpopOtherProp.Clear;
  lPos := FSelectionMenu.Items.IndexOf(itmFrameType) + DefaultMenuItemNum;
  while FSelectionMenu.Items.Count > lPos do
    FSelectionMenu.Items.Delete(lPos);

  _CreateBandMenuItem(itmSelectBand);

  lCell.View.Selected := True;
//  lCell.View.DefinePopupMenu(TRMCustomMenuItem(FSelectionMenu.Items));
  lCell.View.DefinePopupMenu(padpopOtherProp);

  FSelectionMenu.Items.Add(RMNewLine());

  lMenuItem := TRMMenuItem.Create(Self);
  lMenuItem.Caption := RMLoadStr(rmRes + 211);
  lMenuItem.Checked := FDesignerForm.InspForm.Visible;
  lMenuItem.OnClick := Pan5Click;
  FSelectionMenu.Items.Add(lMenuItem);
end;

procedure TRMGridReportPageEditor.Editor_BtnCutClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCut then
    begin
      FDesignerForm.CodeMemo.RMClipBoardCut;
      Editor_ShowPosition;
    end;
  end
  else if FDesignerForm.Page is TRMGridReportPage then
  begin
    Editor_AddUndoAction(rmacChangeGrid);
    FGrid.CutCells(FGrid.Selection);
  end;
end;

procedure TRMGridReportPageEditor.Editor_BtnCopyClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCopy then
    begin
      FDesignerForm.CodeMemo.RMClipBoardCopy;
      Editor_ShowPosition;
    end;
  end
  else if FDesignerForm.Page is TRMGridReportPage then
  begin
    FGrid.CopyCells(FGrid.Selection);
  end;
end;

procedure TRMGridReportPageEditor.Editor_BtnPasteClick(Sender: TObject);
var
  lStartCell: TPoint;
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanPaste then
    begin
      FDesignerForm.CodeMemo.RMClipBoardPaste;
      Editor_ShowPosition;
    end;
  end
  else if FDesignerForm.Page is TRMGridReportPage then
  begin
    Editor_AddUndoAction(rmacChangeGrid);
    lStartCell.X := FGrid.Selection.Left;
    lStartCell.Y := FGrid.Selection.Top;
    FGrid.PasteCells(lStartCell);
    OnGridClick(nil);
  end;
end;

procedure TRMGridReportPageEditor.MenuCellPropertyClick(Sender: TObject);
var
  tmp: TRMCellPropForm;
begin
  tmp := TRMCellPropForm.Create(nil);
  try
    tmp.ParentGrid := FGrid;
    if tmp.ShowModal = mrOK then
    begin
      FDesignerForm.BeforeChange;
      FDesignerForm.AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMGridReportPageEditor.itmInsertRightColumnClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i, lCurCol: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp, 'Caption', rmRes + 858);
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 855);
    tmp.btnCount.MinValue := 1;
    tmp.btnCount.MaxValue := 99;
    tmp.btnCount.Value := 1;
    tmp.btnCount.Left := 120;
    tmp.RB6.Enabled := False;
    tmp.RB7.Enabled := False;
    tmp.RB8.Enabled := False;
    tmp.RB9.Enabled := False;
    if tmp.ShowModal = mrOK then
    begin
      Editor_AddUndoAction(rmacChangeGrid);
      FDesignerForm.Modified := True;
      lCurCol := FGrid.Col;
      if lCurCol = FGrid.ColCount - 1 then
        FGrid.ColCount := FGrid.ColCount + tmp.btnCount.AsInteger
      else
      begin
        THackGridEx(FGrid).InLoadSaveMode := True;
        for i := 1 to tmp.btnCount.AsInteger do
        begin
          FGrid.InsertColumn(lCurCol + 1, False);
        end;

        FGrid.CreateViewsName;
        FGrid.InvalidateGrid;
      end;
    end;
  finally
    tmp.Free;
    THackGridEx(FGrid).InLoadSaveMode := False;
  end;
end;

procedure TRMGridReportPageEditor.itmInsertBottomRowClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i, lCurRow: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp, 'Caption', rmRes + 859);
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 857);
    tmp.btnCount.MinValue := 1;
    tmp.btnCount.MaxValue := 99;
    tmp.btnCount.Value := 1;
    tmp.btnCount.Left := 120;
    tmp.RB6.Enabled := False;
    tmp.RB7.Enabled := False;
    tmp.RB8.Enabled := False;
    tmp.RB9.Enabled := False;
    if tmp.ShowModal = mrOK then
    begin
      Editor_AddUndoAction(rmacChangeGrid);
      FDesignerForm.Modified := True;
      lCurRow := FGrid.Row;
      if FGrid.Row = FGrid.RowCount - 1 then
        FGrid.RowCount := FGrid.RowCount + tmp.btnCount.AsInteger
      else
      begin
        THackGridEx(FGrid).InLoadSaveMode := True;
        for i := 1 to tmp.btnCount.AsInteger do
        begin
          FGrid.InsertRow(lCurRow + 1, False);
        end;

        FGrid.CreateViewsName;
        SetGridHeader;
        FGrid.InvalidateGrid;
      end;
    end;
  finally
    tmp.Free;
    THackGridEx(FGrid).InLoadSaveMode := False;
  end;
end;

procedure TRMGridReportPageEditor.itmInsertLeftCellClick(Sender: TObject);
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  FGrid.InsertCellRight(FGrid.Selection);
  FDesignerForm.Busy := False;
end;

procedure TRMGridReportPageEditor.itmInsertTopCellClick(Sender: TObject);
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  FGrid.InsertCellDown(FGrid.Selection);
  FDesignerForm.Busy := False;
end;

procedure TRMGridReportPageEditor.itmDeleteLeftCellClick(Sender: TObject);
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  FGrid.DeleteCellRight(FGrid.Selection);
  FDesignerForm.Busy := False;
end;

procedure TRMGridReportPageEditor.itmDeleteTopCellClick(Sender: TObject);
begin
  FDesignerForm.Busy := True;
  Editor_AddUndoAction(rmacChangeGrid);
  FDesignerForm.Modified := True;

  FGrid.DeleteCellDown(FGrid.Selection);
  FDesignerForm.Busy := False;
end;

procedure TRMGridReportPageEditor.itmMemoViewClick(Sender: TObject);
var
  lSelection: TRect;
  lCell: TRMCellInfo;
  i, j: Integer;

  procedure _CreateSubReport(aSubReportView: TRMView);
  var
    lPage: TRMReportPage;
  begin
    TRMSubReportView(aSubReportView).SubPage := FDesignerForm.Report.Pages.Count;
    with TRMGridReportPage(FDesignerForm.Page) do
    begin
      lPage := TRMGridReport(FDesignerForm.Report).AddGridReportPage;
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

  procedure _SetOneCell;
  var
    lNewType: Integer;
    lNewClassName: string;
  begin
    lNewClassName := '';
    case TRMMenuItem(Sender).Tag of
      rmgtMemo: lNewType := rmgtMemo;
      rmgtCalcMemo: lNewType := rmgtCalcMemo;
      rmgtPicture: lNewType := rmgtPicture;
      rmgtSubReport: lNewType := rmgtSubReport;
    else
      lNewType := rmgtAddIn;
      lNewClassName := FAddinObjects[itmCellType.IndexOf(TRMMenuItem(Sender)) - RM_AddInObjectOffset];
    end;

    lCell.ReCreateView(lNewType, lNewClassName);
    if lNewType = rmgtSubReport then
      _CreateSubReport(lCell.View);
  end;

begin
  if FDesignerForm.Busy then Exit;

  FDesignerForm.Busy := True;
  lSelection := FGrid.Selection;
  for i := lSelection.Top to lSelection.Bottom do
  begin
    j := lSelection.Left;
    while j <= lSelection.Right do
    begin
      lCell := FGrid.Cells[j, i];
      if lCell.StartRow = i then
        _SetOneCell;
      j := lCell.EndCol + 1;
    end;
  end;

  FGrid.CreateViewsName;
  FDesignerForm.Modified := True;
  FDesignerForm.Busy := False;
  RefreshProp;
end;

procedure TRMGridReportPageEditor.itmFrameTypeClick(Sender: TObject);
var
  t: TRMView;
  tmp: TRMFormFrameProp;
begin
  t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];
  tmp := TRMFormFrameProp.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;
end;

procedure TRMGridReportPageEditor.itmEditClick(Sender: TObject);
var
  t: TRMView;
begin
  t := FDesignerForm.PageObjects[FDesignerForm.TopSelected];

  if ((t.Restrictions * [rmrtDontModify]) <> []) or
    (FDesignerForm.DesignerRestrictions * [rmdrDontEditObj] <> []) then Exit;

  t.ShowEditor;
  Editor_ShowPosition;
  Editor_ShowContent;
end;

procedure TRMGridReportPageEditor.padpopClearContentsClick(Sender: TObject);
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

procedure TRMGridReportPageEditor.itmGridMenuBandClick(Sender: TObject);
begin
  if TRMMenuItem(Sender).Tag = 0 then
    ToolbarBorder.cmbBands.ItemIndex := 0
  else
    ToolbarBorder.cmbBands.ItemIndex := ToolbarBorder.cmbBands.Items.IndexOf(TRMMenuItem(Sender).Caption);

  cmbBandsClick(nil);
end;

procedure TRMGridReportPageEditor.Pan5Click(Sender: TObject);
begin
  with Sender as TRMMenuItem do
  begin
    FDesignerForm.InspForm.Visible := not FDesignerForm.InspForm.Visible;
    Checked := FDesignerForm.InspForm.Visible;
  end;

  if FDesignerForm.InspForm.Visible then
  begin
    FDesignerForm.InspForm.BringToFront;
    Editor_FillInspFields;
  end;
end;

procedure TRMGridReportPageEditor.MenuEditDeleteClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    if FDesignerForm.CodeMemo.RMCanCut then
    begin
      FDesignerForm.CodeMemo.RMDeleteSelected;
      Editor_ShowPosition;
    end;
  end;
end;

procedure TRMGridReportPageEditor.MenuEditSelectAllClick(Sender: TObject);
begin
  if FDesignerForm.Tab1.TabIndex = 0 then
  begin
    FDesignerForm.CodeMemo.SelectAll;
    //FCodeMemo.Command(ecSelAll);
    Editor_ShowPosition;
  end;
end;

procedure TRMGridReportPageEditor.MenuEditCopyPageClick(Sender: TObject);
var
  i: Integer;
  t: TRMView;
begin
  FPageStream.Clear;
  RMWriteInt32(FPageStream, FDesignerForm.Page.Objects.Count);
  for i := 0 to FDesignerForm.Page.Objects.Count - 1 do
  begin
    t := FDesignerForm.Page.Objects[i];
    RMWriteByte(FPageStream, t.ObjectType);
    RMWriteString(FPageStream, t.ClassName);
    THackView(t).StreamMode := rmsmDesigning;
    t.SaveToStream(FPageStream);
  end;
  THackPage(FDesignerForm.Page).SaveToStream(FPageStream);
end;

procedure TRMGridReportPageEditor.MenuEditPastePageClick(Sender: TObject);
var
  i, lCount: Integer;
  b: Byte;
  t: TRMView;
  lOldName: string;
begin
  lOldName := FDesignerForm.Page.Name;
  if FPageStream.Size > 0 then
  begin
    Editor_AddUndoAction(rmacChangeGrid);
    FDesignerForm.Page.Clear;
    FPageStream.Position := 0;
    lCount := RMReadInt32(FPageStream);
    for i := 0 to lCount - 1 do
    begin
      b := RMReadByte(FPageStream);
      t := RMCreateObject(b, RMReadString(FPageStream));
      t.NeedCreateName := False;
      THackView(t).StreamMode := rmsmDesigning;
      t.LoadFromStream(FPageStream);
      if t is TRMSubReportView then
      begin
        t.Free;
      end
      else
      begin
        t.ParentPage := FDesignerForm.Page;
      end;
    end;

    THackPage(FDesignerForm.Page).LoadFromStream(FPageStream);
    FDesignerForm.Page.Name := lOldName;
    THackPage(FDesignerForm.Page).AfterLoaded;

    FDesignerForm.Modified := False;
    cmbBandsDropDown(nil);
    OnGridClick(nil);
    FDesignerForm.SetObjectsID;
    SetGridHeader;
  end;
end;

procedure TRMGridReportPageEditor.MenuCellTableSizeClick(Sender: TObject);
var
  tmp: TRMGetGridColumnsForm;
begin
  tmp := TRMGetGridColumnsForm.Create(nil);
  try
    tmp.RowCountButton.Value := FGrid.RowCount;
    tmp.ColCountButton.Value := FGrid.ColCount;
    if tmp.ShowModal = mrOK then
    begin
      Editor_AddUndoAction(rmacChangeGrid);
      FDesignerForm.Modified := True;
      Screen.Cursor := crHourGlass;
      FGrid.ColCount := tmp.ColCountButton.AsInteger;
      FGrid.RowCount := tmp.RowCountButton.AsInteger;
      Editor_AddUndoAction(rmacChangeGrid);
    end;
  finally
    tmp.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRMGridReportPageEditor.itmRowHeightClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i: Integer;
  lRowHeight: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 695);
    RMSetStrProp(tmp, 'Caption', rmRes + 695);
    tmp.btnCount.ValueType := rmvtFloat;
    tmp.btnCount.MinValue := 0;
    tmp.UnitType := UnitType;
    tmp.btnCount.Value := RMFromMMThousandths(FGrid.mmRowHeights[FGrid.Row], UnitType);
    tmp.RB6Click(nil);
    if tmp.ShowModal = mrOK then
    begin
      UnitType := tmp.UnitType;
      lRowHeight := RMToMMThousandths(tmp.btnCount.Value, UnitType);
      Editor_AddUndoAction(rmacChangeCellSize);
      FDesignerForm.Modified := True;
      for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
        FGrid.mmRowHeights[i] := lRowHeight;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMGridReportPageEditor.itmAverageRowHeightClick(Sender: TObject);
var
  i, lTotalHeight, lCount: Integer;
begin
  lTotalHeight := 0;
  lCount := 0;
  for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
  begin
    lTotalHeight := lTotalHeight + FGrid.RowHeights[i];
    Inc(lCount);
  end;

  if lCount <= 1 then Exit;

  Editor_AddUndoAction(rmacChangeCellSize);
  for i := FGrid.Selection.Top to FGrid.Selection.Bottom do
  begin
    FGrid.RowHeights[i] := lTotalHeight div lCount;
  end;
end;

procedure TRMGridReportPageEditor.itmColumnHeightClick(Sender: TObject);
var
  tmp: TRMEditCellWidthForm;
  i: Integer;
  lColumnWidth: Integer;
begin
  tmp := TRMEditCellWidthForm.Create(nil);
  try
    RMSetStrProp(tmp.Label2, 'Caption', rmRes + 696);
    RMSetStrProp(tmp, 'Caption', rmRes + 696);

    tmp.btnCount.ValueType := rmvtFloat;
    tmp.btnCount.MinValue := 0;
    tmp.UnitType := UnitType;
    tmp.btnCount.Value := RMFromMMThousandths(FGrid.mmColWidths[FGrid.Col], UnitType);
    tmp.RB6Click(nil);
    if tmp.ShowModal = mrOK then
    begin
      UnitType := tmp.UnitType;
      lColumnWidth := RMToMMThousandths(tmp.btnCount.Value, UnitType);
      Editor_AddUndoAction(rmacChangeCellSize);
      FDesignerForm.Modified := True;
      for i := FGrid.Selection.Left to FGrid.Selection.Right do
        FGrid.mmColWidths[i] := lColumnWidth;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMGridReportPageEditor.itmAverageColumnWidthClick(Sender: TObject);
var
  i, lTotalWidth, lCount: Integer;
begin
  lTotalWidth := 0;
  lCount := 0;
  for i := FGrid.Selection.Left to FGrid.Selection.Right do
  begin
    lTotalWidth := lTotalWidth + FGrid.ColWidths[i];
    Inc(lCount);
  end;

  if lCount <= 1 then Exit;

  Editor_AddUndoAction(rmacChangeCellSize);
  for i := FGrid.Selection.Left to FGrid.Selection.Right do
  begin
    FGrid.ColWidths[i] := lTotalWidth div lCount;
  end;

  FDesignerForm.Modified := True;
end;

function TRMGridReportPageEditor.GetUnitType: TRMUnitType;
begin
  Result := FUnitType;
end;

procedure TRMGridReportPageEditor.SetUnitType(aValue: TRMUnitType);
begin
  FUnitType := aValue;
end;

procedure TRMGridReportPageEditor.itmToolbarStandardClick(Sender: TObject);

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
  //dejoy changed
  with Sender as TRMMenuItem do
  begin
    Checked := not Checked;
    _SetShow([FDesignerForm.ToolbarStandard, ToolbarEdit, ToolbarBorder, FDesignerForm.InspForm, FDesignerForm.FieldForm,
      ToolbarGrid, ToolbarCellEdit], Tag, Checked);
    if FDesignerForm.FieldForm.Visible then
      FDesignerForm.FieldForm.RefreshData;
  end;
end;

procedure TRMGridReportPageEditor.MenuEditOptionsClick(Sender: TObject);
var
  lSaveShowBandTitles: Boolean;
  lOldPage: Integer;
  tmp: TRMDesOptionsForm;
begin
  lSaveShowBandTitles := RMShowBandTitles;
  lOldPage := FDesignerForm.CurPage;
  tmp := TRMDesOptionsForm.Create(nil);
  try
    tmp.CB1.Checked := True;
    tmp.CB2.Checked := True;
    tmp.RB1.Checked := True;
    case FUnitType of
      rmutScreenPixels: tmp.RB6.Checked := True;
      rmutInches: tmp.RB7.Checked := True;
      rmutMillimeters: tmp.RB8.Checked := True;
      rmutMMThousandths: tmp.RB9.Checked := True;
    end;
    tmp.CB5.Checked := RM_Class.RMShowBandTitles;
    tmp.CB7.Checked := RM_Class.RMLocalizedPropertyNames;
    tmp.chkAutoOpenLastFile.Checked := FDesignerForm.AutoOpenLastFile;
    tmp.WorkSpaceColor := clWhite;
    tmp.InspColor := clWhite;
    tmp.ChkShowDropDownField.Checked := RM_Class.RMShowDropDownField;

    if tmp.ShowModal = mrOK then
    begin
      RM_Class.RMLocalizedPropertyNames := tmp.CB7.Checked;
      RM_Class.RMShowDropDownField := tmp.ChkShowDropDownField.Checked;
      FDesignerForm.AutoOpenLastFile := tmp.chkAutoOpenLastFile.Checked;
      FDesignerForm.AutoOpenLastFile := tmp.chkAutoOpenLastFile.Checked;
      if tmp.RB6.Checked then
        FUnitType := rmutScreenPixels
      else if tmp.RB7.Checked then
        FUnitType := rmutInches
      else if tmp.RB8.Checked then
        FUnitType := rmutMillimeters
      else
        FUnitType := rmutMMThousandths;

      if lSaveShowBandTitles <> RMShowBandTitles then
        FDesignerForm.SetOldCurPage(-1);

      FDesignerForm.CurPage := lOldPage;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMGridReportPageEditor.MenuEditToolbarClick(Sender: TObject);
begin
  itmToolbarStandard.Checked := FDesignerForm.ToolbarStandard.Visible;
  itmToolbarText.Checked := ToolbarEdit.Visible;
  itmToolbarBorder.Checked := ToolbarBorder.Visible;
  itmToolbarInspector.Checked := FDesignerForm.InspForm.Visible;
  itmToolbarInsField.Checked := FDesignerForm.FieldForm.Visible;
  itmToolbarGrid.Checked := ToolbarGrid.Visible;
  itmToolbarCellEdit.Checked := ToolbarCellEdit.Visible;
end;

function TRMGridReportPageEditor._GetSelectionStatus: TRMSelectionStatus;
var
  t: TRMView;
begin
  Result := [];
  if FDesignerForm.SelNum = 1 then
  begin
    t := FGrid.Cells[FGrid.Col, FGrid.Row].View;
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

function TRMGridReportPageEditor._DelEnabled: Boolean;
var
  lSelStatus: TRMSelectionStatus;
begin
  lSelStatus := _GetSelectionStatus;
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCut and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := False;
end;

function TRMGridReportPageEditor._CutEnabled: Boolean;
var
  lSelStatus: TRMSelectionStatus;
begin
  lSelStatus := _GetSelectionStatus;
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCut and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := FGrid.CanCut;
end;

function TRMGridReportPageEditor._CopyEnabled: Boolean;
var
  lSelStatus: TRMSelectionStatus;
begin
  lSelStatus := _GetSelectionStatus;
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanCopy
  else
    Result := FGrid.CanCopy;
end;

function TRMGridReportPageEditor._PasteEnabled: Boolean;
var
  lSelStatus: TRMSelectionStatus;
begin
  lSelStatus := _GetSelectionStatus;
  if FDesignerForm.Tab1.TabIndex = 0 then
    Result := FDesignerForm.CodeMemo.RMCanPaste and (not FDesignerForm.CodeMemo.ReadOnly)
  else
    Result := FGrid.CanPaste;
end;

procedure TRMGridReportPageEditor.Editor_EnableControls;
var
  lSelStatus: TRMSelectionStatus;

  function _FontTypEnabled: Boolean;
  var
    lSelStatus: TRMSelectionStatus;
  begin
    lSelStatus := _GetSelectionStatus;
    if FDesignerForm.Tab1.TabIndex = 0 then
      Result := False
    else
      Result := ([rmssMemo, rmssMultiple] * lSelStatus <> []) and (FDesignerForm.Page is TRMReportPage);
  end;

  function _EditEnabled: Boolean;
  begin
    if FDesignerForm.Tab1.TabIndex = 0 then
      Result := False
    else
      Result := False;
  end;

  function _RedoEnabled: Boolean;
  begin
    if FDesignerForm.Tab1.TabIndex = 0 then
      Result := FDesignerForm.CodeMemo.RMCanRedo and (not FDesignerForm.CodeMemo.ReadOnly)
    else
    begin
      Result := (FDesignerForm.RedoBufferLength > 0);
    end;
  end;

  function _UndoEnabled: Boolean;
  begin
    if FDesignerForm.Tab1.TabIndex = 0 then
      Result := FDesignerForm.CodeMemo.RMCanUndo and (not FDesignerForm.CodeMemo.ReadOnly)
    else
    begin
      Result := (FDesignerForm.UndoBufferLength > 0);
    end;
  end;

begin
  lSelStatus := _GetSelectionStatus;
  FDesignerForm.SetControlsEnabled([MenuEditCopyPage],
    (FDesignerForm.Tab1.TabIndex > 0));
  FDesignerForm.SetControlsEnabled([MenuEditPastePage],
    (FDesignerForm.Tab1.TabIndex > 0) and (FPageStream.Size > 0));
  FDesignerForm.SetControlsEnabled([FDesignerForm.MenuFileHeaderFooter],
    (FDesignerForm.Tab1.TabIndex > 0) and TRMGridReportPage(FDesignerForm.Page).UseHeaderFooter);
  FDesignerForm.ToolbarStandard.btnPreview1.Enabled := True;

  with ToolbarBorder do
  begin
    FDesignerForm.SetControlsEnabled([btnFrameTop, btnFrameLeft, btnFrameBottom, btnFrameRight, btnSetBorder, btnNoBorder,
      btnTopBorder, btnBottomBorder, btnBias1Border, btnBias2Border,
        btnDecWidth, btnIncWidth, btnDecHeight, btnIncHeight, cmbBands,
        btnAddBand, btnDeleteBand, btnColumnMin, btnColumnMax, btnRowMin, btnRowMax], (FDesignerForm.Tab1.TabIndex > 0));
  end;
  with ToolbarEdit do
  begin
    FDesignerForm.SetControlsEnabled([FBtnFontColor, FcmbFont, FcmbFontSize, btnFontBold, btnFontItalic,
      btnFontUnderline, btnHLeft, btnHRight, btnHCenter, btnHSpaceEqual, btnVTop,
        FBtnHighlight, btnVBottom, btnVCenter, FBtnBackColor, FBtnFrameColor, FCmbFrameWidth], _FontTypEnabled);
  end;
  with ToolbarGrid do
  begin
    FDesignerForm.SetControlsEnabled([btnInsertColumn, btnInsertRow, btnAddColumn, btnAddRow, btnDeleteColumn,
      btnDeleteRow, btnSetRowsAndColumns, btnMerge, btnSplit, btnMergeColumn, btnMergeRow],
        (FDesignerForm.Tab1.TabIndex > 0));
  end;

  ToolbarCellEdit.FBtnExpression.Enabled := True; {(Tab1.TabIndex = 0) or ((Page is TRMGridReportPage) and (SelNum = 1));}
  ToolbarCellEdit.FBtnDBField.Enabled := ToolbarCellEdit.FBtnExpression.Enabled; //(Tab1.TabIndex > 0);
  ToolbarCellEdit.FEdtMemo.Enabled := (FDesignerForm.Tab1.TabIndex > 0);

  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnCut, MenuEditCut, SelectionMenu_popCut], _CutEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnCopy, MenuEditCopy, SelectionMenu_popCopy], _CopyEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnPaste, MenuEditPaste, SelectionMenu_popPaste], _PasteEnabled);
  FDesignerForm.SetControlsEnabled([MenuEditDelete], _DelEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnUndo, MenuEditUndo], _UndoEnabled);
  FDesignerForm.SetControlsEnabled([FDesignerForm.ToolbarStandard.btnRedo, MenuEditRedo], _RedoEnabled);

  FDesignerForm.SetControlsEnabled([MenuEditSelectAll],
    (FDesignerForm.Tab1.TabIndex = 0));
  FDesignerForm.SetControlsEnabled([MenuCellTableSize, MenuCellInsertCell, MenuCellInsertColumn,
    MenuCellInsertRow, MenuCellDeleteColumn, MenuCellDeleteRow, MenuCellRow, MenuCellColumn],
      (FDesignerForm.Tab1.TabIndex > 0));
  FDesignerForm.SetControlsEnabled([itmInsert, itmDelete], (FDesignerForm.Tab1.TabIndex > 0));
  FDesignerForm.SetControlsEnabled([MenuCellMerge, MenuCellReverse, itmMergeCells, itmSplitCells, itmCellType],
    (FDesignerForm.Tab1.TabIndex > 0));
  FDesignerForm.SetControlsEnabled([MenuCellProperty], (FDesignerForm.Tab1.TabIndex > 0));

//  FToolbarAddinTools.btnInsertFields.Down := FDesignerForm.FieldForm.Visible;
  itmToolbarInsField.Checked := FDesignerForm.FieldForm.Visible;

  with FDesignerForm.ToolbarStandard do
    FDesignerForm.SetControlsEnabled([cmbScale, GB1, GB2, GB3, btnBringtoFront, btnSendtoBack, btnSelectAll], False);
end;

procedure TRMGridReportPageEditor.Editor_OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string);
begin
  if FDesignerForm.InspForm.Insp.Objects[0] is TRMCustomBandView then
  begin
  end
  else if FDesignerForm.InspForm.Insp.Objects[0] is TRMGridReportPage then
  begin
    if FGrid <> nil then
      FGrid.AutoCreateName := TRMGridReportPage(FDesignerForm.InspForm.Insp.Objects[0]).AutoCreateName;
  end;

  if AnsiCompareText(aPropName, 'Name') = 0 then
  begin
    FDesignerForm.InspForm.SetCurrentObject(FDesignerForm.InspForm.Insp.Objects[0].ClassName, aPropValue);
  end;

  FDesignerForm.Modified := True;
  FDesignerForm.SetPageTabs;
  FDesignerForm.StatusBar1.Repaint;
  Editor_SelectionChanged(False);
  if FDesignerForm.FieldForm.Visible then
    FDesignerForm.FieldForm.RefreshData;
end;

procedure TRMGridReportPageEditor.Editor_btnDeletePageClick(Sender: TObject);

  function _IsSubReportPage(aPageNo: Integer): Boolean;
  var
    i, lRow, lCol: Integer;
    lGrid: TRMGridEx;
    lCell: TRMCellInfo;
  begin
    Result := False;
    for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
    begin
      if not (FDesignerForm.Report.Pages[i] is TRMGridReportPage) then Continue;

      lGrid := TRMGridReportPage(FDesignerForm.Report.Pages[i]).Grid;
      for lRow := 1 to lGrid.RowCount - 1 do
      begin
        lCol := 1;
        while lCol < lGrid.ColCount do
        begin
          lCell := lGrid.Cells[lCol, lRow];
          if lCell.StartRow = lRow then
          begin
            if (lCell.View is TRMSubReportView) and (TRMSubReportView(lCell.View).SubPage = aPageNo) then
            begin
              Result := True;
              Exit;
            end;
          end;
          lCol := lCell.EndCol + 1;
        end;
      end;
    end;
  end;

  procedure _AlignmentSubReports(aPageNo: Integer);
  var
    i, lRow, lCol: Integer;
    lGrid: TRMGridEx;
    lCell: TRMCellInfo;
    t: TRMView;
  begin
    for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
    begin
      if not (FDesignerForm.Report.Pages[i] is TRMGridReportPage) then Continue;

      lGrid := TRMGridReportPage(FDesignerForm.Report.Pages[i]).Grid;
      for lRow := 1 to lGrid.RowCount - 1 do
      begin
        lCol := 1;
        while lCol < lGrid.ColCount do
        begin
          lCell := lGrid.Cells[lCol, lRow];
          if lCell.StartRow = lRow then
          begin
            t := lCell.View;
            if (t is TRMSubReportView) and (TRMSubReportView(t).SubPage > aPageNo) then
            begin
              TRMSubReportView(t).SubPage := TRMSubReportView(t).SubPage - 1;
            end;
          end;
          lCol := lCell.EndCol + 1;
        end;
      end;
    end;
  end;

  procedure _RemovePage(aPageNo: Integer);
  begin
    FDesignerForm.Modified := True;
    if (aPageNo >= 0) and (aPageNo < FDesignerForm.Report.Pages.Count) then
    begin
      SetGridNilProp;
      FDesignerForm.Report.Pages.Delete(aPageNo);
      FDesignerForm.Tab1.Tabs.Delete(aPageNo + 1);
      _AlignmentSubReports(aPageNo);

      FDesignerForm.CurPage := 0;
    end;
  end;

begin
  if FDesignerForm.DesignerRestrictions * [rmdrDontDeletePage] <> [] then Exit;

  if FDesignerForm.Report.Pages.Count > 1 then
  begin
    if _IsSubReportPage(FDesignerForm.CurPage) then
    begin
    end
    else
    begin
      if Application.MessageBox(PChar(RMLoadStr(SRemovePg)),
        PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNo) = mrYes then
      begin
        _RemovePage(FDesignerForm.CurPage);
      end;
    end;
  end;
end;

procedure TRMGridReportPageEditor.Editor_MenuFilePreview1Click(Sender: TObject);
var
  lSaveModalPreview: Boolean;
  lSaveVisible: Boolean;
  lSaveStream: TMemoryStream;
  lSaveModified: Boolean;

  procedure _ChangeObjects;
  var
    i, j: Integer;
    lPage: TRMCustomPage;
    t: TRMView;
    lGrid: TRMGridEx;
    lRow, lCol: Integer;
    lCell: TRMCellInfo;
  begin
    for i := 0 to FDesignerForm.Report.Pages.Count - 1 do
    begin
      lPage := FDesignerForm.Report.Pages[i];
      if lPage is TRMGridReportPage then
      begin
        lGrid := TRMGridReportPage(lPage).Grid;
        for j := 1 to lGrid.RowCount - 1 do
        begin
          TRMGridReportPage(lPage).RowBandViews[j] := nil;
        end;

        for lRow := 1 to lGrid.RowCount - 1 do
        begin
          lCol := 1;
          while lCol < lGrid.ColCount do
          begin
            lCell := lGrid.Cells[lCol, lRow];
            if lCell.StartRow = lRow then
            begin
              if lCell.View <> nil then
                THackReportView(lCell.View).TextOnly := True;
            end;
            lCol := lCell.EndCol + 1;
          end;
        end;
      end;

      for j := lPage.Objects.Count - 1 downto 0 do
      begin
        t := lPage.Objects[j];
        if t is TRMReportView then
          THackReportView(t).TextOnly := True;
        if t.IsBand then
        begin
          lPage.Delete(j);
        end;
      end;
    end;
  end;

begin
  if FDesignerForm.DesignerRestrictions * [rmdrDontPreviewReport] <> [] then Exit;

  FGrid := nil;
  lSaveModalPreview := FDesignerForm.Report.ModalPreview;
  lSaveVisible := FDesignerForm.InspForm.Visible;
  Application.ProcessMessages;
  FDesignerForm.Report.ModalPreview := True;
  FDesignerForm.Busy := True;
  FDesignerForm.InspBusy := True;
  FDesignerForm.Page := nil;

  lSaveModified := FDesignerForm.Modified;
  lSaveStream := TMemoryStream.Create;
  try
    FDesignerForm.Report.SaveToStream(lSaveStream);
    _ChangeObjects;

    FDesignerForm.Report.Script.Clear;
    FDesignerForm.InspForm.Hide;
    FDesignerForm.Report.Preview := nil;
    FDesignerForm.Report.ShowReport;
  finally
    lSaveStream.Position := 0;
    FDesignerForm.Report.LoadFromStream(lSaveStream);
    lSaveStream.Free;

    FDesignerForm.Report.ModalPreview := lSaveModalPreview;
    FDesignerForm.InspBusy := False;
    FDesignerForm.Busy := False;
    FDesignerForm.InspForm.Visible := lSaveVisible;
    FDesignerForm.Modified := lSaveModified;
    FDesignerForm.CurPage := FDesignerForm.CurPage;
    Editor_SelectionChanged(True);
    Screen.Cursor := crDefault;

    if FDesignerForm.Page is TRMGridReportPage then
      FGrid.SetFocus;
  end;
end;

procedure TRMGridReportPageEditor.Editor_MenuFileHeaderFooterClick(Sender: TObject);
var
  tmpForm: TRMFormEditorHF;
begin
  tmpForm := TRMFormEditorHF.Create(nil);
  try
    tmpForm.memHeaderLeft.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.LeftMemo);
    tmpForm.memHeaderCenter.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.CenterMemo);
    tmpForm.memHeaderRight.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.RightMemo);
    tmpForm.memHeaderLeft.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.Font);
    tmpForm.memHeaderCenter.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.Font);
    tmpForm.memHeaderRight.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.Font);

    tmpForm.memFooterLeft.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.LeftMemo);
    tmpForm.memFooterCenter.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.CenterMemo);
    tmpForm.memFooterRight.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.RightMemo);
    tmpForm.memFooterLeft.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.Font);
    tmpForm.memFooterCenter.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.Font);
    tmpForm.memFooterRight.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.Font);

    tmpForm.memTitle.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.TitleMemo);
    tmpForm.memTitle.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.TitleFont);

    tmpForm.memCaptionLeft.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.LeftMemo);
    tmpForm.memCaptionCenter.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.CenterMemo);
    tmpForm.memCaptionRight.Lines.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.RightMemo);
    tmpForm.memCaptionLeft.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.Font);
    tmpForm.memCaptionCenter.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.Font);
    tmpForm.memCaptionRight.Font.Assign(TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.Font);

    if tmpForm.ShowModal = mrOK then
    begin
      TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.LeftMemo.Assign(tmpForm.memHeaderLeft.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.CenterMemo.Assign(tmpForm.memHeaderCenter.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.RightMemo.Assign(tmpForm.memHeaderRight.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageHeaderMsg.Font.Assign(tmpForm.memHeaderLeft.Font);

      TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.LeftMemo.Assign(tmpForm.memFooterLeft.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.CenterMemo.Assign(tmpForm.memFooterCenter.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.RightMemo.Assign(tmpForm.memFooterRight.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageFooterMsg.Font.Assign(tmpForm.memFooterLeft.Font);

      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.TitleMemo.Assign(tmpForm.memTitle.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.TitleFont.Assign(tmpForm.memTitle.Font);

      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.LeftMemo.Assign(tmpForm.memCaptionLeft.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.CenterMemo.Assign(tmpForm.memCaptionCenter.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.RightMemo.Assign(tmpForm.memCaptionRight.Lines);
      TRMGridReportPage(FDesignerForm.Page).PageCaptionMsg.CaptionMsg.Font.Assign(tmpForm.memCaptionLeft.Font);
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMGridReportPageEditor.Editor_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_F11) and (Shift = []) then
  begin
    Pan5Click(itmToolbarInspector);
  end
//  else if (Key = vk_Escape) and (Page is TRMDialogPage) and (not FWorkSpace.MouseButtonDown) then
//  begin
//    ToolbarComponent.btnNoSelect.Down := True;
//    FWorkSpace.Perform(CM_MOUSELEAVE, 0, 0);
//    FWorkSpace.OnMouseMoveEvent(nil, [], 0, 0);
//    UnselectAll;
//    FWorkSpace.RedrawPage;
//    SelectionChanged(True);
//  end
  else if Key = vk_F9 then
    FDesignerForm.ToolbarStandard.btnPreview.Click
  else if (Key = vk_Return) and (FDesignerForm.ActiveControl = ToolbarEdit.FcmbFontSize) then
  begin
    Key := 0;
    Editor_DoClick(ToolbarEdit.FcmbFontSize);
  end
  else if (Key = vk_Delete) and _DelEnabled then
  begin
  end;

  if _CutEnabled then
  begin
    if (Key = vk_Delete) and (ssShift in Shift) then
      FDesignerForm.ToolbarStandard.btnCut.Click;
  end;
  if _CopyEnabled then
  begin
    if (Key = vk_Insert) and (ssCtrl in Shift) then
      FDesignerForm.ToolbarStandard.btnCopy.Click;
  end;
  if _PasteEnabled then
  begin
    if (Key = vk_Insert) and (ssShift in Shift) then
      FDesignerForm.ToolbarStandard.btnPaste.Click;
  end;
end;

procedure TRMGridReportPageEditor.OnGridDropDownField(aCol, aRow: Integer);
var
  t: TRMView;
  lCell: TRMCellInfo;
begin
  if not RM_Class.RMShowDropDownField then Exit;

  t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[aRow];
  if (t <> nil) and t.IsBand and (t is TRMBandMasterData) and
    (not TRMBandMasterData(t).IsVirtualDataSet) and (TRMBandMasterData(t).DataSetName <> '') then
  begin
    lCell := FGrid.Cells[aCol, aRow];
    if (lCell <> nil) and RMHavePropertyName(lCell.View, 'DataField') then
    begin
      FGrid.CurrentCol := aCol;
      FGrid.CurrentRow := aRow;
    end;
  end;
end;

procedure TRMGridReportPageEditor.OnGridDropDownFieldClick(aDropDown: Boolean;
  X, Y: Integer);
var
  t: TRMView;
  lView: TRMReportView;
  lRect: TRect;
  lPoint: TPoint;

  function _IsDropDownField: Boolean;
  begin
    Result := (X >= lRect.Right - 16) and (X <= lRect.Right) and
      (Y >= lRect.Top) and (Y <= lRect.Top + 16);
  end;

begin
  if (not aDropDown) or (not RM_Class.RMShowDropDownField) then
  begin
    FFieldListBox.Hide;
    Exit;
  end;

  t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row];
  if (t <> nil) and (t is TRMBandMasterData) and
    (not TRMBandMasterData(t).IsVirtualDataSet) and (TRMBandMasterData(t).DataSetName <> '') then
  begin
    lView := TRMReportView(FGrid.Cells[FGrid.Col, FGrid.Row].View);
    lRect := FGrid.GetCellRect(FGrid.Cells[FGrid.Col, FGrid.Row]);
    if _IsDropDownField then
    begin
      FDesignerForm.Report.Dictionary.GetDataSetFields(TRMBandMasterData(t).DataSetName, FFieldListBox.Items);
      if lView.Memo.Count > 0 then
        FFieldListBox.ItemIndex := FFieldListBox.Items.IndexOf(RMGetFieldName(lView.Memo[0]));

    //lRect.Left := lRect.Right - 160;
      lRect.Top := lRect.Top + 18;

      lPoint := FDesignerForm.ScreenToClient(FGrid.ClientToScreen(Point(lRect.Left, lRect.Top)));
//    	lPoint := ScreenToClient(FGrid.ClientToScreen(Point(lRect.Right,  lRect.Top)));
      lRect.Left := lPoint.X;
//	    lRect.Right := lPoint.X;
      lRect.Top := lPoint.Y;
      lRect.Right := lRect.Left + Max(140, FGrid.ColWidths[FGrid.Col]);
//    	lRect.Left := lRect.Right - 160;
      lRect.Bottom := lRect.Top + 200;
      FFieldListBox.BoundsRect := lRect;
      FFieldListBox.Show;
    end;
  end;
end;

procedure TRMGridReportPageEditor.OnFieldListBoxClick(Sender: TObject);
var
  lView: TRMView;
  t: TRMView;
begin
  FFieldListBox.Hide;

  lView := FGrid.Cells[FGrid.Col, FGrid.Row].View;
  t := TRMGridReportPage(FDesignerForm.Page).RowBandViews[FGrid.Row];

  if (lView <> nil) and (FFieldListBox.ItemIndex >= 0) and
    (t <> nil) and (t is TRMBandMasterData) and
    (not TRMBandMasterData(t).IsVirtualDataSet) and (TRMBandMasterData(t).DataSetName <> '') then
  begin
    FDesignerForm.BeforeChange;
    RMSetPropValue(lView,
      'DataField',
      Format('[%s."%s"]', [TRMBandMasterData(t).DataSetName, FFieldListBox.Items[FFieldListBox.ItemIndex]]));
    if lView is TRMCustomMemoView then
      TRMCustomMemoVIew(lView).DBFieldOnly := True;

    FDesignerForm.AfterChange;
    FGrid.InvalidateCell(FGrid.Col, FGrid.Row);
  end;
end;

procedure TRMGridReportPageEditor.OnFieldListBoxDrawItem(aControl: TWinControl; aIndex: Integer;
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

procedure TRMGridReportPageEditor.Editor_BeforeFormDestroy;
begin
  if THackDesigner(FDesignerForm).IsPreviewDesign or THackDesigner(FDesignerForm).IsPreviewDesignReport then
    FGrid := nil;

  SetGridNilProp;
end;

procedure TRMGridReportPageEditor.SetBandMenuItemEnable(aMenuItem: TRMMenuItem);
begin
  aMenuItem.Enabled := (TRMBandType(aMenuItem.Tag) in [rmbtHeader, rmbtFooter, rmbtGroupHeader,
    rmbtGroupFooter, rmbtMasterData, rmbtDetailData]) or
    (not HaveBand(TRMBandType((aMenuItem.Tag))));
end;

initialization
  RMRegisterPageEditor(TRMGridReportPage, TRMGridReportPageEditor);
  RMRegisterPageButton(RMLoadStr(rmRes + 099) + '(Grid)', '28', True, 'TRMGridReportPage');

  FUnitType := rmutScreenPixels;

  CF_RMGridCopyFormat := RegisterClipboardFormat('WHF_RMGrid_CopyFormat');

end.

