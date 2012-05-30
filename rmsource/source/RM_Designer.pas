unit RM_Designer;

interface

{$I RM.INC}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Printers, Menus, ComCtrls, ExtCtrls, Clipbrd, Commctrl,
  TypInfo, ImgList,
  RM_Class, RM_Preview, RM_Common, RM_DsgCtrls, RM_Ctrls, RM_Insp, RM_PropInsp,
  RM_EditorInsField, RM_CodeGen
{$IFDEF USE_INTERNAL_JVCL}
  , rm_JvInterpreter, rm_JvInterpreterParser, rm_JvInterpreterConst
{$ELSE}
  , JvInterpreter, JvInterpreterParser, JvInterpreterConst
{$ENDIF}
{$IFDEF USE_TB2K}
  , TB2Item, TB2Dock, TB2Toolbar
{$ELSE}
{$IFDEF USE_INTERNALTB97}
  , RM_TB97Ctls, RM_TB97Tlbr, RM_TB97
{$ELSE}
  , TB97Ctls, TB97Tlbr, TB97
{$ENDIF}
{$ENDIF}
{$IFDEF USE_SYNEDIT}
  , SynEdit, SynEditRegexSearch, SynEditSearch, SynEditTypes
{$ENDIF}

{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  RM_MaxUndoBuffer = 100;

const
  crPencil = 11;
  DefaultPopupItemsCount = 9;

  TAG_SetFrameTop = 1;
  TAG_SetFrameLeft = 2;
  TAG_SetFrameBottom = 3;
  TAG_SetFrameRight = 4;
  TAG_BackColor = 5;
  //  TAG_FrameStyle = 6;

  TAG_SetFontName = 7;
  TAG_SetFontSize = 8;

  TAG_FontBold = 9;
  TAG_FontItalic = 10;
  TAG_FontUnderline = 11;

  TAG_HAlignLeft = 12;
  TAG_HAlignCenter = 13;
  TAG_HAlignRight = 14;
  TAG_HAlignEuqal = 15;

  TAG_FrameSize = 16;
  TAG_FontColor = 17;
  TAG_FrameColor = 19;

  TAG_SetFrame = 20;
  TAG_NoFrame = 21;

  TAG_FrameStyle1 = 25;
  TAG_FrameStyle2 = 26;
  TAG_FrameStyle3 = 27;
  TAG_FrameStyle4 = 28;
  TAG_FrameStyle5 = 29;
  TAG_FrameStyle6 = 30;

  TAG_VAlignTop = 31;
  TAG_VAlignCenter = 32;
  TAG_VAlignBottom = 33;

  TAG_Frame1 = 22;
  TAG_Frame2 = 23;
  TAG_Frame3 = 24;
  TAG_Frame4 = 25;
  TAG_DecWidth = 26;
  TAG_IncWidth = 27;
  TAG_DecHeight = 28;
  TAG_IncHeight = 29;

type
  TRMUndoAction = (rmacInsert, rmacDelete, rmacEdit, rmacZOrder,
    rmacChangeCellSize, rmacChangeGrid, rmacChangePage);

  TRMSelectionType = (rmssBand, rmssMemo, rmssOther, rmssMultiple);
  TRMSelectionStatus = set of TRMSelectionType;

  TRMUndoRec = record
    Action: TRMUndoAction;
    Page: Integer;
    Stream: TMemoryStream;
    AddObj: TObject;
  end;
  PRMUndoRec = ^TRMUndoRec;

  TRMUndoBuffer = array[0..RM_MaxUndoBuffer - 1] of TRMUndoRec;
  PRMUndoBuffer = ^TRMUndoBuffer;

  TRMDesignerForm = class;

  { TRMDesigner }
  TRMDesigner = class(TRMCustomDesigner) // fake component
  private
    FOpenFileCount: Integer;
    FTemplDir, FOpenDir, FSaveDir: string;
    FDesignerRestrictions: TRMDesignerRestrictions;
    FDefaultDictionaryFile: string;
    FUseUndoRedo: Boolean;
    FDefaultPageClass: string;

    procedure SetOpenFileCount(Value: Integer);
    procedure SetDesignerRestrictions(Value: TRMDesignerRestrictions);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OpenFileCount: Integer read FOpenFileCount write SetOpenFileCount default 4;
    property OpenDir: string read FOpenDir write FOpenDir;
    property SaveDir: string read FSaveDir write FSaveDir;
    property TemplateDir: string read FTemplDir write FTemplDir;
    property DesignerRestrictions: TRMDesignerRestrictions read FDesignerRestrictions write SetDesignerRestrictions;
    property DefaultDictionaryFile: string read FDefaultDictionaryFile write FDefaultDictionaryFile;
    property UseUndoRedo: Boolean read FUseUndoRedo write FUseUndoRedo default True;
    property DefaultPageClassName: string read FDefaultPageClass write FDefaultPageClass;

    property OnShowAboutForm;
    property OnLoadReport;
    property OnSaveReport;
    property OnNewReport;
    property OnClose;
    property OnShow;
  end;

 { TRMCustomPageEditor }
  TRMCustomPageEditor = class(TComponent)
  private
  protected
    FDesignerForm: TRMDesignerForm;
  public
    constructor CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm); virtual;
    destructor Destroy; override;
    procedure Editor_Localize; virtual;

    procedure Editor_BtnUndoClick(Sender: TObject); virtual;
    procedure Editor_BtnRedoClick(Sender: TObject); virtual;
    procedure Editor_AddUndoAction(aAction: TRMUndoAction); virtual;

    procedure Editor_BeforeFormDestroy; virtual;
    procedure Editor_OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string); virtual;
    procedure Editor_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure Editor_OnFormMouseWheelUp(aUp: Boolean); virtual;
    procedure Editor_Tab1Changed; virtual;
    procedure Editor_DisableDraw; virtual;
    procedure Editor_EnableDraw; virtual;
    procedure Editor_RedrawPage; virtual;
    procedure Editor_Resize; virtual;
    procedure Editor_Init; virtual;
    procedure Editor_SetCurPage; virtual;
    procedure Editor_SelectionChanged(aRefreshInspProp: Boolean); virtual;
    procedure Editor_FillInspFields; virtual;
    procedure Editor_ShowPosition; virtual;
    procedure Editor_ShowContent; virtual;
    function Editor_PageObjects: TList; virtual;
    procedure Editor_OnInspGetObjects(aList: TStrings); virtual;
    procedure Editor_DoClick(Sender: TObject); virtual;
    procedure Editor_SelectObject(ObjName: string); virtual;
    procedure Editor_AfterChange; virtual;
    procedure Editor_SetObjectsID; virtual;
    procedure Editor_BtnCutClick(Sender: TObject); virtual;
    procedure Editor_BtnCopyClick(Sender: TObject); virtual;
    procedure Editor_BtnPasteClick(Sender: TObject); virtual;
    procedure Editor_InitToolbarComponent; virtual;
    procedure Editor_EnableControls; virtual;
    procedure Editor_BtnDeletePageClick(Sender: TObject); virtual;
    procedure Editor_MenuFilePreview1Click(Sender: TObject); virtual;
    procedure Editor_MenuFileHeaderFooterClick(Sender: TObject); virtual;
  published
  end;

  { TRMDefaultPageEditor }
  TRMDefaultPageEditor = class(TRMCustomPageEditor)
  private
    FPanel: TPanel;
  public
    constructor CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm); override;
    destructor Destroy; override;

    procedure Editor_BtnDeletePageClick(Sender: TObject); override;
  end;

  { TRMToolbarModifyPrepared }
  TRMToolbarModifyPrepared = class(TRMToolbar)
  private
    FDesignerForm: TRMDesignerForm;
    btnModifyPreviedFirst: TRMToolbarButton;
    btnModifyPreviedPrev: TRMToolbarButton;
    btnModifyPreviedNext: TRMToolbarButton;
    btnModifyPreviedLast: TRMToolbarButton;
    btnAutoSave: TRMToolbarButton;
    Edit1: TRMEdit;

    procedure Localize;
    procedure _EditPreparedReport(aNewPageNo: Integer);
    procedure btnModifyPreviedFirstClick(Sender: TObject);
    procedure btnModifyPreviedPrevClick(Sender: TObject);
    procedure btnModifyPreviedLastClick(Sender: TObject);
    procedure btnModifyPreviedNextClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure btnAutoSaveClick(Sender: TObject);
  public
    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMToolbarStandard }
  TRMToolbarStandard = class(TRMToolbar)
  private
    FAryButton: array of TObject;
    FDesignerForm: TRMDesignerForm;
    procedure Localize;
    procedure OnCmbScaleChangeEvent(Sender: TObject);
  public
    BtnFileNew: TRMToolbarButton;
    btnFileSave: TRMToolbarButton;
{$IFDEF USE_TB2K}
    btnFileOpen: TRMSubmenuItem;
{$ELSE}
    btnFileOpen: TRMToolbarButton;
{$ENDIF}
    btnPreview1: TRMToolbarButton;
    btnPreview: TRMToolbarButton;
    btnPrint: TRMToolbarButton;
    btnCut: TRMToolbarButton;
    btnCopy: TRMToolbarButton;
    btnPaste: TRMToolbarButton;
    ToolbarSep972: TRMToolbarSep;
    btnRedo: TRMToolbarButton;
    btnUndo: TRMToolbarButton;
    ToolbarSep973: TRMToolbarSep;
    btnBringtoFront: TRMToolbarButton;
    btnSendtoBack: TRMToolbarButton;
    btnSelectAll: TRMToolbarButton;
    ToolbarSep974: TRMToolbarSep;

    ToolbarSep9723: TRMToolbarSep;
    btnDeletePage: TRMToolbarButton;
    btnPageSetup: TRMToolbarButton;
    ToolbarSep975: TRMToolbarSep;
    GB2: TRMToolbarButton;
    GB3: TRMToolbarButton;
    GB1: TRMToolbarButton;
    ToolbarSep976: TRMToolbarSep;
    btnExit: TRMToolbarButton;
    ToolbarSep971: TRMToolbarSep;
    ToolbarSepScale: TRMToolbarSep;
    cmbScale: TRMComboBox97 {TComboBox};

    constructor CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
  end;

  { TRMVirtualReportDesigner }
  TRMVirtualReportDesigner = class(TRMReportDesigner)
  private
{$IFDEF USE_SYNEDIT}
    FSearchBackwards: boolean;
    FSearchCaseSensitive: boolean;
    FSearchFromCaret: boolean;
    FSearchFromCaret1: Boolean;
    FSearchSelectionOnly: boolean;
    FSearchTextAtCaret: boolean;
    FSearchWholeWords: boolean;
    FSearchRegex: boolean;

    FSearchText: string;
    FSearchTextHistory: string;
    FReplaceText: string;
    FReplaceTextHistory: string;

    FSynEditSearch: TSynEditSearch;
    FSynEditRegexSearch: TSynEditRegexSearch;
{$ELSE}
    FScriptCanReplace: Boolean;
    FFindDialog: TFindDialog;
    FReplaceDialog: TReplaceDialog;
{$ENDIF}

{$IFDEF USE_SYNEDIT}
    procedure OnCodeMemoReplaceText(Sender: TObject; const aSearch,
      aReplace: string; aLine, aColumn: Integer; var Action: TSynReplaceAction);
    procedure OnCodeMemoStatusChange(Sender: TObject; Changes: TSynStatusChanges);
{$ELSE}
    procedure OnCodeMemoSelectionChangeEvent(Sender: TObject); virtual;

    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Show(Sender: TObject);
    procedure FindNext;
    procedure Replace_FindNext;
{$ENDIF}

    procedure DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OnCodeMemoChangeEvent(Sender: TObject); virtual;
    procedure DoSearchReplaceText(aReplace: Boolean; aBackwards: Boolean);
    procedure ShowSearchReplaceDialog(aReplace: Boolean);

  protected
    FCodeGenEngine: TRMCodeGenEngine;
    FCodeMemo: TRMSynEditor;
    FTab1: TRMTabControl;
    FMouseDown, FTabChange: Boolean;

    FInAssignScript:Boolean;
    procedure BeginUpdateScript;
    procedure EndUpdateScript;
    procedure DoCodeGenGetScript(const AList: TStrings);
    procedure DoCodeGenScriptChanged(Sender: TObject);
    procedure SetModified(Value: Boolean); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    {//begin 自动生成事件框架相关代码  作者: dejoy}
    function GetEditorScriptPos: integer; override;
    procedure SetEditorScriptPos(const Value: integer); override;

    function GetEditorScriptText: string;override;
    procedure SetEditorScriptText(const Value: string);override;
    function GetEditorScript: TStrings;override;
    procedure SetEditorScript(Value: TStrings);override;

    function FunctionExists(const aFuncName: string): Boolean; override;
    function DefineMethod(const AFuncName,AFuncDefine: string): boolean;override;
    function GotoMethod(const AFuncName: string): boolean; override;
    function RenameMethod(const ACurName,ANewName: string): boolean;override;

    procedure GetMethodsList(ATypeInfo: PTypeInfo; AValues: TStrings);override;

    procedure ShowPosition; virtual; abstract;
    procedure EnableControls; virtual; abstract;

    property CodeGenEngine: TRMCodeGenEngine read FCodeGenEngine;
    property CodeMemo: TRMSynEditor read FCodeMemo;
    {//End 自动生成事件框架相关代码  作者: dejoy}
    
    property Tab1: TRMTabControl read FTab1;
  end;

  { TRMDesignerForm }
  TRMDesignerForm = class(TRMVirtualReportDesigner)
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    ImageListStand: TImageList;
    ImageListFont: TImageList;
    ImageListFrame: TImageList;
    ImageListAlign: TImageList;
    ImageListSize: TImageList;
    ImageListPosition: TImageList;
    ImageListModifyPreview: TImageList;
    ImageListAddinTools: TImageList;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FInspBusy: Boolean;
    FInspForm: TRMInspForm;
    FFindReplaceForm: TForm;
    FOpenFiles: TStringList;
    FAutoOpenLastFile: Boolean;
    FWorkSpaceColor: TColor;
    FInspFormColor: TColor;
    FFieldForm: TRMInsFieldsForm;
    FEditorForm: TForm;
    FUndoBufferLength, FRedoBufferLength: Integer;

    FBusy: Boolean; // busy flag. need!
    FUnlimitedHeight: Boolean;
    FCurPage: Integer;
    FCurPageEditor: TRMCustomPageEditor;
    FCurDocName, FCaption: string;
    FOldFactor: Integer;
    FShowGrid, FGridAlign: Boolean;
    FGridSize: Integer;
    FPopupMenuOpendFiles: TRMPopupMenu;

    // 主菜单
    FMainMenu: TRMMenuBar;
    FBarFile: TRMSubmenuItem;
    padFileNew: TRMmenuItem;
    padFileOpen: TRMmenuItem;
    padFileSave: TRMmenuItem;
    padFileSaveAs: TRMmenuItem;
    N40: TRMSeparatorMenuItem;
    padVarList: TRMmenuItem;
    LoadDictionary1: TRMmenuItem;
    MergeDictionary1: TRMmenuItem;
    SaveAsDictionary1: TRMmenuItem;
    N21: TRMSeparatorMenuItem;
    padPageSetup: TRMmenuItem;
    padPreview: TRMmenuItem;
    FMenuFileHeaderFooter: TRMMenuItem;
    padPrint: TRMmenuItem;
    N24: TRMSeparatorMenuItem;
    padFileProperty: TRMmenuItem;
    N2: TRMSeparatorMenuItem;
    itmFileFile1: TRMmenuItem;
    itmFileFile2: TRMmenuItem;
    itmFileFile3: TRMmenuItem;
    itmFileFile4: TRMmenuItem;
    itmFileFile5: TRMmenuItem;
    itmFileFile6: TRMmenuItem;
    itmFileFile7: TRMmenuItem;
    itmFileFile8: TRMmenuItem;
    itmFileFile9: TRMmenuItem;
    N1: TRMSeparatorMenuItem;
    padFileExit: TRMmenuItem;

    FBarSearch: TRMSubmenuItem;
    padSearchFind: TRMMenuItem;
    padSearchReplace: TRMMenuItem;
    padSearchFindAgain: TRMMenuItem;

    FBarHelp: TRMSubmenuItem;
    padHelp: TRMmenuItem;
    N18: TRMSeparatorMenuItem;
    padAbout: TRMmenuItem;
    padSep: TRMSeparatorMenuItem;
    padLanguage: TRMSubmenuItem;
    //MenuBar End

    FToolbarStandard: TRMToolbarStandard;
    FToolbarModifyPrepared: TRMToolbarModifyPrepared;

    procedure padHelpClick(Sender: TObject);
    procedure padFilePropertyClick(Sender: TObject);
    procedure btnPageSetupClick(Sender: TObject);
    procedure btnFileSaveClick(Sender: TObject);
    procedure padPrintClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure padAboutClick(Sender: TObject);
    procedure padFileNewClick(Sender: TObject);
    procedure padVarListClick(Sender: TObject);
    procedure LoadDictionary1Click(Sender: TObject);
    procedure MergeDictionary1Click(Sender: TObject);
    procedure SaveAsDictionary1Click(Sender: TObject);
    procedure itmFileFile9Click(Sender: TObject);
    procedure btnFileOpenClick(Sender: TObject);
    procedure btnFileNewClick(Sender: TObject);
    procedure padFileSaveAsClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnAddPageClick(Sender: TObject);
    procedure btnAddFormClick(Sender: TObject);
    procedure btnDeletePageClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure btnRedoClick(Sender: TObject);
    procedure padSearchFindClick(Sender: TObject);
    procedure padSearchReplaceClick(Sender: TObject);
    procedure padSearchFindAgainClick(Sender: TObject);
    procedure MenuFilePreview1Click(Sender: TObject);
    procedure MenuFileHeaderFooterClick(Sender: TObject);

    procedure OnFieldsDialogCloseEvnet(Sender: TObject);

    procedure Localize;
    procedure SaveIni;
    procedure LoadIni;
    function FileSave: Boolean;
    function FileSaveAs: Boolean;
    procedure CreateDefaultPage;

    procedure Tab1Change(Sender: TObject);
    procedure Tab1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Tab1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Tab1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Tab1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure Tab1DragDrop(Sender, Source: TObject; X, Y: Integer);
{$IFDEF Raize}
    procedure Tab1Changing(Sender: TObject; NewIndex: Integer; var AllowChange: Boolean);
{$ELSE}
    procedure Tab1Changing(Sender: TObject; var AllowChange: Boolean);
{$ENDIF}

    procedure SetCurDocName(Value: string);
    procedure OnInspBeforeModify(Sender: TObject; const aPropName: string);
    procedure OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string);

    procedure GB1Click(Sender: TObject);
    procedure GB2Click(Sender: TObject);
    procedure GB3Click(Sender: TObject);

    procedure SetOpenFileMenuItems(const aNewFile: string);

    procedure OnDockRequestDockEvent(Sender: TObject; Bar: TRMCustomDockableWindow; var Accept: Boolean);
    procedure OnFormMouseWheelUpEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure OnFormMouseWheelDownEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure OnLanguageItemClick(Sender: TObject);

    procedure OpenFile(aFileName: string);
    procedure SetGridShow(Value: Boolean);
    procedure SetGridAlign(Value: Boolean);
    procedure SetGridSize(Value: Integer);
  protected
    function GetModified: Boolean; override;
    procedure SetModified(Value: Boolean); override;
    procedure SetFactor(Value: Integer); override;
    function GetDesignerRestrictions: TRMDesignerRestrictions; override;
    procedure SetDesignerRestrictions(Value: TRMDesignerRestrictions); override;
  public
    { Public declarations }
    FirstSelected: TRMView;
    SelNum: Integer; // number of objects currently selected
    Dock971: TRMDock;
    Dock972: TRMDock;
    Dock973: TRMDock;
    Dock974: TRMDock;
    ObjID: Integer;
    SaveDesignerRestrictions: TRMDesignerRestrictions;
    UndoBuffer, RedoBuffer: TRMUndoBuffer;

    procedure ClearUndoBuffer;
    procedure ClearRedoBuffer;
    procedure ReleaseAction(aActionRec: PRMUndoRec);

    procedure BeforeChange; override;
    procedure AfterChange; override;
    function InsertDBField(t: TRMView): string; override;
    function InsertExpression(t: TRMView): string; override;
    procedure InspSelectionChanged(ObjName: string);

    procedure RMMemoViewEditor(t: TRMView); override;
    procedure RMFontEditor(Sender: TObject); override;
    procedure RMDisplayFormatEditor(Sender: TObject); override;
    procedure RMPictureViewEditor(t: TRMView); override;
    procedure RMCalcMemoEditor(Sender: TObject); override;

    procedure AddLanguageMenu(aParentMenu: TRMSubmenuItem);
    function EditorForm: TForm; override;
    function GetParentBand(t: TRMReportView): TRMReportView;
    procedure EnableControls; override;
    procedure InspGetObjects(List: TStrings);
    procedure SetObjectsID;
    procedure DoClick(Sender: TObject);

    function PageSetup(aRepaint: Boolean): Boolean;
    function RMCheckBand(b: TRMBandType): Boolean;
    function IsSubreport(PageN: Integer): TRMView;
    function TopSelected: Integer;
    procedure SetObjectID(t: TRMView);
    procedure RedrawPage;
    procedure UnSelectAll;
    function Objects: TList;
    procedure ShowPosition; override;
    function PageObjects: TList; override;

    procedure SetPageTabs;
    procedure SetCurPage(Value: Integer);
    procedure ResetSelection;
    procedure AddUndoAction(aAction: TRMUndoAction);
    procedure SetOldCurPage(Value: Integer);
    procedure SetControlsEnabled(const Ar: array of TObject; aEnabled: Boolean);

    property MenuFileHeaderFooter: TRMMenuItem read FMenuFileHeaderFooter;
    property UndoBufferLength: Integer read FUndoBufferLength write FUndoBufferLength;
    property RedoBufferLength: Integer read FRedoBufferLength write FRedoBufferLength;
    property ToolbarModifyPrepared: TRMToolbarModifyPrepared read FToolbarModifyPrepared;
    property ToolbarStandard: TRMToolbarStandard read FToolbarStandard;
    property MainMenu: TRMMenuBar read FMainMenu;
    property BarFile: TRMSubmenuItem read FBarFile;
    property BarSearch: TRMSubmenuItem read FBarSearch;
    property BarHelp: TRMSubmenuItem read FBarHelp;
    property Busy: Boolean read FBusy write FBusy; // busy flag. need!
    property InspBusy: Boolean read FInspBusy write FInspBusy;
    property CurPageEditor: TRMCustomPageEditor read FCurPageEditor;
    property FieldForm: TRMInsFieldsForm read FFieldForm;
    property InspForm: TRMInspForm read FInspForm;
    property CurPage: Integer read FCurPage write SetCurPage;
    property CurDocName: string read FCurDocName write SetCurDocName;
    property AutoOpenLastFile: Boolean read FAutoOpenLastFile write FAutoOpenLastFile;
    property WorkSpaceColor: TColor read FWorkSpaceColor write FWorkSpaceColor;
    property InspFormColor: TColor read FInspFormColor write FInspFormColor;
    property UnlimitedHeight: Boolean read FUnlimitedHeight write FUnlimitedHeight;
    property GridAlign: Boolean read FGridAlign write SetGridAlign;
    property GridSize: Integer read FGridSize write SetGridSize;
    property ShowGrid: Boolean read FShowGrid write SetGridShow;
  end;

procedure RMAssignImages(aSrcBmp: TBitmap; aDstImgList: TImageList); overload;
procedure RMAssignImages(aRes: string; aDstImgList: TImageList); overload;
procedure RMAddLanguageDll(aDllFileName: string; aCaption: string);

var
  RM_LastFontName: string;
  RM_LastFontSize: Integer;
  RM_LastFontCharset: Word;
  RM_LastFontStyle: Word;
  RM_LastFontColor: TColor;
  RM_LastHAlign: TRMHAlign;
  RM_LastVAlign: TRMVAlign;
  RM_LastFillColor: TColor;
  RM_LastFrameWidth: Integer;
  RM_LastFrameColor: TColor;
  RM_LastLeftFrameVisible: Boolean;
  RM_LastTopFrameVIsible: Boolean;
  RM_LastRightFrameVisible: Boolean;
  RM_LastBottomFrameVisible: Boolean;
  RM_CurLanguage: string = '';

  RM_Dsg_LastDataSet: string = '';
  RMTemplateDir: string = '';

  RMDesignerComp: TRMDesigner = nil;

implementation

{$R *.DFM}

uses
  ShellApi,
  RM_DsgForm, Registry, RM_Const, RM_Const1, RM_Utils, RM_EditorMemo, RM_EditorPicture, RM_EditorField,
  RM_EditorExpr, RM_PageSetup, RM_EditorReportProp, RM_DesignerOptions, RM_Printer, RM_About,
  RM_EditorFormat, RM_EditorDictionary, RM_EditorFindReplace, RM_EditorTemplate,
  RM_EditorCalc, RM_Wizard, RM_WizardNewReport
{$IFDEF USE_SYNEDIT}
  ,RM_EditorConfirmReplace, RM_EditorReplaceText, RM_EditorSearchText
{$ENDIF}
  ;

const
  rsGridShow = 'GridShow';
  rsGridAlign = 'GridAlign';
  rsGridSize = 'GridSize';
  rsUnits = 'Units';
  rsEdit = 'EditAfterInsert';
  rsBandTitles = 'BandTitles';
  rsAutoOpenLastFile = 'AutoOpenLastFile';
  rsWorkSpaceColor = 'WorkSpaceColor';
  rsInspFormColor = 'InspFormColor';
  rsLocalizedPropertyName = 'LocalizedPropertyName';
  rsShowDropDownField = 'ShowDropDownField';
  rsLanguage = 'Language';

type
  THackView = class(TRMView)
  end;

  THackPage = class(TRMCustomPage)
  end;

  THackReportPage = class(TRMReportPage)
  end;

  THackReport = class(TRMReport)
  end;

var
  FEditAfterInsert: Boolean;
  FLanguageList: TStringList = nil;
  FLanguageNameList: TStringList = nil;

procedure RMAssignImages(aSrcBmp: TBitmap; aDstImgList: TImageList);
var
  lBmp: TBitmap;
  lLeft, lTop: Integer;
  lWidth, lHeight: Integer;
begin
  lWidth := aDstImgList.Width;
  lHeight := aDstImgList.Height;
  lBmp := TBitmap.Create;
  try
    lBmp.Width := lWidth;
    lBmp.Height := lHeight;
    lTop := 0;
    while lTop < aSrcBmp.Height do
    begin
      lLeft := 0;
      while lLeft < aSrcBmp.Width do
      begin
        lBmp.Canvas.CopyRect(Rect(0, 0, lWidth, lHeight), aSrcBmp.Canvas,
          Rect(lLeft, lTop, lLeft + lWidth, lTop + lHeight));

        aDstImgList.AddMasked(lBmp, lBmp.TransparentColor);
        lLeft := lLeft + lWidth;
      end;

      lTop := lTop + lHeight;
    end;
  finally
    lBmp.Free;
  end;
end;

procedure RMAssignImages(aRes: string; aDstImgList: TImageList);
var
  lBmp: TBitmap;
begin
  lBmp := TBitmap.Create;
  try
    lBmp.LoadFromResourceName(hInstance, aRes);
    RMAssignImages(lBmp, aDstImgList);
  finally
    lBmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDesigner}

constructor TRMDesigner.Create(AOwner: TComponent);
begin
  //  if Assigned(FDesignerComp) then
  //    raise Exception.Create('You already have one TRMDesigner component');
  inherited Create(AOwner);

  FDefaultPageClass := '';
  RMDesignerComp := Self;
  FOpenFileCount := 4;
  FDefaultDictionaryFile := '';
  FUseUndoRedo := True;
end;

destructor TRMDesigner.Destroy;
begin
  RMDesignerComp := nil;
  inherited Destroy;
end;

procedure TRMDesigner.SetOpenFileCount(Value: Integer);
begin
  if (Value >= 0) and (Value <= 9) then
    FOpenFileCount := Value;
end;

procedure TRMDesigner.SetDesignerRestrictions(Value: TRMDesignerRestrictions);
begin
  FDesignerRestrictions := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomPageEditor }

constructor TRMCustomPageEditor.CreateComp(aOwner: TComponent;
  aDesignerForm: TRMDesignerForm);
begin
  inherited Create(aOwner);

  FDesignerForm := aDesignerForm;
end;

destructor TRMCustomPageEditor.Destroy;
begin
  inherited Destroy;
end;

procedure TRMCustomPageEditor.Editor_Localize;
begin
  //
end;

procedure TRMCustomPageEditor.Editor_AddUndoAction(aAction: TRMUndoAction);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnUndoClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnRedoClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_DisableDraw;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_EnableDraw;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_RedrawPage;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_Resize;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_Init;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_SetCurPage;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_SelectionChanged(aRefreshInspProp: Boolean);
begin
 //
end;

procedure TRMCustomPageEditor.Editor_FillInspFields;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_ShowPosition;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_ShowContent;
begin
 //
end;

function TRMCustomPageEditor.Editor_PageObjects: TList;
begin
  Result := nil;
end;

procedure TRMCustomPageEditor.Editor_OnInspGetObjects(aList: TStrings);
begin
 //
end;

procedure TRMCustomPageEditor.Editor_DoClick(Sender: TObject);
begin
 //
end;

procedure TRMCustomPageEditor.Editor_SelectObject(ObjName: string);
begin
 //
end;

procedure TRMCustomPageEditor.Editor_AfterChange;
begin
 //
end;

procedure TRMCustomPageEditor.Editor_SetObjectsID;
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnCutClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnCopyClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnPasteClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_Tab1Changed;
begin
  //
end;

procedure TRMCustomPageEditor.Editor_OnFormMouseWheelUp(aUp: Boolean);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_InitToolbarComponent;
begin
  //
end;

procedure TRMCustomPageEditor.Editor_EnableControls;
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BtnDeletePageClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_OnInspAfterModify(Sender: TObject;
  const aPropName, aPropValue: string);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_MenuFilePreview1Click(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_MenuFileHeaderFooterClick(Sender: TObject);
begin
  //
end;

procedure TRMCustomPageEditor.Editor_BeforeFormDestroy;
begin
  //
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDefaultPageEditor }

constructor TRMDefaultPageEditor.CreateComp(aOwner: TComponent; aDesignerForm: TRMDesignerForm);
begin
  inherited CreateComp(aOwner, aDesignerForm);

  FPanel := TPanel.Create(Self);
  with FPanel do
  begin
    Parent := TWinControl(aOwner);
    Align := alClient;
    BevelOuter := bvLowered;
  end;
end;

destructor TRMDefaultPageEditor.Destroy;
begin
  inherited Destroy;
end;

procedure TRMDefaultPageEditor.Editor_BtnDeletePageClick(Sender: TObject);

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

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

constructor TRMToolbarModifyPrepared.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);
begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FDesignerForm := TRMDesignerForm(AOwner);
  ParentForm := FDesignerForm;
  DockRow := 4;
  DockPos := 0;
  Name := 'ToolbarModifyPrepared';
  CloseButton := False;

  btnModifyPreviedFirst := TRMToolbarButton.Create(Self);
  with btnModifyPreviedFirst do
  begin
    Width := 60;
    Images := FDesignerForm.ImageListModifyPreview;
    ImageIndex := 0;
    OnClick := btnModifyPreviedFirstClick;
    AddTo := Self;
{$IFDEF USE_TB2k}
    DisplayMode := nbdmImageAndText;
{$ELSE}
    DisplayMode := dmBoth;
{$ENDIF}
  end;
  btnModifyPreviedPrev := TRMToolbarButton.Create(Self);
  with btnModifyPreviedPrev do
  begin
    Width := 60;
    Images := FDesignerForm.ImageListModifyPreview;
    ImageIndex := 1;
    OnClick := btnModifyPreviedPrevClick;
    AddTo := Self;
{$IFDEF USE_TB2k}
    DisplayMode := nbdmImageAndText;
{$ELSE}
    DisplayMode := dmBoth;
{$ENDIF}
  end;
  Edit1 := TRMEdit.Create(Self);
  with Edit1 do
  begin
    Width := 64;
    Text := '1';
    OnKeyPress := Edit1KeyPress;
    AddTo := Self;
  end;
  btnModifyPreviedNext := TRMToolbarButton.Create(Self);
  with btnModifyPreviedNext do
  begin
    Width := 60;
    Images := FDesignerForm.ImageListModifyPreview;
    ImageIndex := 2;
    OnClick := btnModifyPreviedNextClick;
    AddTo := Self;
{$IFDEF USE_TB2k}
    DisplayMode := nbdmImageAndText;
{$ELSE}
    DisplayMode := dmBoth;
{$ENDIF}
  end;
  btnModifyPreviedLast := TRMToolbarButton.Create(Self);
  with btnModifyPreviedLast do
  begin
    Width := 60;
    Images := FDesignerForm.ImageListModifyPreview;
    ImageIndex := 3;
    OnClick := btnModifyPreviedLastClick;
    AddTo := Self;
{$IFDEF USE_TB2k}
    DisplayMode := nbdmImageAndText;
{$ELSE}
    DisplayMode := dmBoth;
{$ENDIF}
  end;
  btnAutoSave := TRMToolbarButton.Create(Self);
  with btnAutoSave do
  begin
    Width := 60;
    AllowAllup := True;
    GroupIndex := 1;
    OnClick := btnAutoSaveClick;
    AddTo := Self;
  end;

//  EndUpdate;
  Localize;
end;

procedure TRMToolbarModifyPrepared.Localize;
begin
  RMSetStrProp(btnModifyPreviedFirst, 'Caption', rmRes + 218);
  RMSetStrProp(btnModifyPreviedPrev, 'Caption', rmRes + 219);
  RMSetStrProp(btnModifyPreviedNext, 'Caption', rmRes + 220);
  RMSetStrProp(btnModifyPreviedLast, 'Caption', rmRes + 221);
  RMSetStrProp(btnAutoSave, 'Caption', rmRes + 222);
end;

type
  THackPages = class(TRMPages)
  end;

  THackEndPage = class(TRMEndPage)
  end;

procedure TRMToolbarModifyPrepared._EditPreparedReport(aNewPageNo: Integer);
var
  liEndPage: TRMEndPage;
  liPicture: TPicture;
  libkPic: TRMbkPicture;
  lipicLeft, lipicTop, liPicWidth, liPicHeight: Integer;
  w: Word;
begin
  if FDesignerForm.Modified then
  begin
    if btnAutoSave.Down then
      w := mrYes
    else
      w := Application.MessageBox(PChar(RMLoadStr(SSaveChanges) + '?'),
        PChar(RMLoadStr(SConfirm)), mb_YesNoCancel + mb_IconQuestion);

    if w = mrYes then
    begin
      FDesignerForm.Report.EndPages[FDesignerForm.EndPageNo].ObjectsToStream(FDesignerForm.Report);
      FDesignerForm.Report.CanRebuild := False;
      RMDesigner.Modified := False;
      FDesignerForm.Report.Modified := True;
    end
    else if w = mrCancel then
      Exit;
  end;

  FDesignerForm.Modified := False;
  FDesignerForm.EndPageNo := aNewPageNo;
  libkPic := FDesignerForm.Report.EndPages.bkPictures[FDesignerForm.Report.EndPages[aNewPageNo].bkPictureIndex];
  if libkPic <> nil then
  begin
    liPicture := TPicture.Create;
    liPicture.Assign(libkPic.Picture);
    lipicLeft := libkPic.Left;
    lipicTop := libkPic.Top;
    liPicWidth := libkPic.Width;
    liPicHeight := libkPic.Height;
  end
  else
  begin
    liPicture := nil;
    lipicLeft := 0;
    lipicTop := 0;
    liPicWidth := 0;
    liPicHeight := 0;
  end;

  try
    THackPages(FDesignerForm.Report.Pages).FPages.Clear;
    FDesignerForm.Report.EndPages[FDesignerForm.EndPageNo].StreamToObjects(FDesignerForm.Report, False);

    liEndPage := FDesignerForm.Report.EndPages[FDesignerForm.EndPageNo];
    THackPages(FDesignerForm.Report.Pages).FPages.Add(liEndPage.Page);

    if liPicture <> nil then
    begin
      THackReportPage(liEndPage.Page).FbkPicture.Assign(liPicture);
      liEndPage.Page.bkPictureWidth := liPicWidth;
      liEndPage.Page.bkPictureHeight := liPicHeight;
    end;
    liEndPage.Page.BackPictureLeft := lipicLeft;
    liEndPage.Page.BackPictureTop := lipicTop;
  finally
    liPicture.Free;
    FDesignerForm.CurPage := 0;
    Edit1.Text := IntToStr(FDesignerForm.EndPageNo + 1);
  end;
end;

procedure TRMToolbarModifyPrepared.btnModifyPreviedFirstClick(Sender: TObject);
begin
  if FDesignerForm.EndPageNo <> 0 then
  begin
    _EditPreparedReport(0);
  end;
end;

procedure TRMToolbarModifyPrepared.btnModifyPreviedPrevClick(Sender: TObject);
begin
  if FDesignerForm.EndPageNo > 0 then
  begin
    _EditPreparedReport(FDesignerForm.EndPageNo - 1);
  end;
end;

procedure TRMToolbarModifyPrepared.btnModifyPreviedLastClick(Sender: TObject);
begin
  if FDesignerForm.EndPageNo <> FDesignerForm.Report.EndPages.Count - 1 then
  begin
    _EditPreparedReport(FDesignerForm.Report.EndPages.Count - 1);
  end;
end;

procedure TRMToolbarModifyPrepared.btnModifyPreviedNextClick(Sender: TObject);
begin
  if FDesignerForm.EndPageNo < FDesignerForm.Report.EndPages.Count - 1 then
  begin
    _EditPreparedReport(FDesignerForm.EndPageNo + 1);
  end;
end;

procedure TRMToolbarModifyPrepared.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  liPageNo: Integer;
begin
  if Key = #13 then
  begin
    try
      liPageNo := StrToInt(Edit1.Text);
      if liPageNo < 0 then
        liPageNo := 0;
      if liPageNo > FDesignerForm.Report.EndPages.Count - 1 then
        liPageNo := FDesignerForm.Report.EndPages.Count - 1;
      if FDesignerForm.EndPageNo <> liPageNo then
      begin
        _EditPreparedReport(liPageNo);
      end;
    except;
      Edit1.Text := IntToStr(FDesignerForm.EndPageNo);
    end;
  end;
end;

procedure TRMToolbarModifyPrepared.btnAutoSaveClick(Sender: TObject);
begin
  FDesignerForm.AutoSave := btnAutoSave.Down;
  TRMToolbarButton(Sender).Down := FDesignerForm.AutoSave;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMToolbarStandard }

constructor TRMToolbarStandard.CreateAndDock(AOwner: TComponent; DockTo: TRMDock);

  procedure _CreatePageButtons(aIsReportPage: Boolean);
  var
    i: Integer;
    lButton: TRMToolbarButton;
  begin
    for i := 0 to RMDsgPageButtonCount - 1 do
    begin
      if RMDsgPageButton(i).IsReportPage <> aIsReportPage then Continue;

      lButton := TRMToolbarButton.Create(Self);
      with lButton do
      begin
        Images := FDesignerForm.ImageListStand;
        ImageIndex := StrToInt(RMDsgPageButton(i).ButtonBmpRes);
        if RMDsgPageButton(i).IsReportPage then
          OnClick := FDesignerForm.btnAddPageClick
        else
          OnClick := FDesignerForm.btnAddFormClick;

        lButton.Hint := RMDsgPageButton(i).Caption;
        Tag := i;
        AddTo := Self;

        SetLength(FAryButton, Length(FAryButton) + 1);
        FAryButton[Length(FAryButton) - 1] := lButton;
      end;
    end;
  end;

begin
  inherited Create(AOwner);
  Visible := False;
//  BeginUpdate;
  Dockedto := DockTo;
  FDesignerForm := TRMDesignerForm(AOwner);
  ParentForm := FDesignerForm;
  DockRow := 0;
  DockPos := 0;
  Name := 'ToolbarStandard';
  CloseButton := False;

  btnFileNew := TRMToolbarButton.Create(Self);
  with btnFileNew do
  begin
    ImageIndex := 0;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnFileNewClick;
    AddTo := Self;
  end;
{$IFDEF USE_TB2K}
  btnFileOpen := TRMSubmenuItem.Create(Self);
{$ELSE}
  btnFileOpen := TRMToolbarButton.Create(Self);
{$ENDIF}
  with btnFileOpen do
  begin
    ImageIndex := 1;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnFileOpenClick;
    DropdownCombo := True;
{$IFDEF USE_TB2k}
    Self.Items.Add(btnFileOpen);
{$ELSE}
    AddTo := Self;
    DropdownMenu := FDesignerForm.FPopupMenuOpendFiles;
{$ENDIF}
  end;
  btnFileSave := TRMToolbarButton.Create(Self);
  with btnFileSave do
  begin
    ImageIndex := 2;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnFileSaveClick;
    AddTo := Self;
  end;
  ToolbarSep971 := TRMToolbarSep.Create(Self);
  with ToolbarSep971 do
  begin
    AddTo := Self;
  end;

  btnPrint := TRMToolbarButton.Create(Self);
  with btnPrint do
  begin
    ImageIndex := 3;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.padPrintClick;
    AddTo := Self;
  end;
  btnPreview := TRMToolbarButton.Create(Self);
  with btnPreview do
  begin
    ImageIndex := 4;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnPreviewClick;
    AddTo := Self;
  end;
  btnPreview1 := TRMToolbarButton.Create(Self);
  with btnPreview1 do
  begin
    ImageIndex := 45;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.MenuFilePreview1Click;
    AddTo := Self;
  end;
  ToolbarSep972 := TRMToolbarSep.Create(Self);
  with ToolbarSep972 do
  begin
    AddTo := Self;
  end;

  btnCut := TRMToolbarButton.Create(Self);
  with btnCut do
  begin
    ImageIndex := 5;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnCutClick;
    AddTo := Self;
  end;
  btnCopy := TRMToolbarButton.Create(Self);
  with btnCopy do
  begin
    ImageIndex := 6;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnCopyClick;
    AddTo := Self;
  end;
  btnPaste := TRMToolbarButton.Create(Self);
  with btnPaste do
  begin
    ImageIndex := 7;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnPasteClick;
    AddTo := Self;
  end;
  ToolbarSep973 := TRMToolbarSep.Create(Self);
  with ToolbarSep973 do
  begin
    AddTo := Self;
  end;

  btnRedo := TRMToolbarButton.Create(Self);
  with btnRedo do
  begin
    ImageIndex := 9;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnRedoClick;
    AddTo := Self;
  end;
  btnUndo := TRMToolbarButton.Create(Self);
  with btnUndo do
  begin
    ImageIndex := 8;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnUndoClick;
    AddTo := Self;
  end;
  ToolbarSep975 := TRMToolbarSep.Create(Self);
  with ToolbarSep975 do
  begin
    AddTo := Self;
  end;
  btnBringtoFront := TRMToolbarButton.Create(Self);
  with btnBringtoFront do
  begin
    ImageIndex := 10;
    Images := FDesignerForm.ImageListStand;
    //OnClick := FDesignerForm.btnBringtoFrontClick;
    AddTo := Self;
  end;
  btnSendtoBack := TRMToolbarButton.Create(Self);
  with btnSendtoBack do
  begin
    ImageIndex := 11;
    Images := FDesignerForm.ImageListStand;
    //OnClick := FDesignerForm.btnSendtoBackClick;
    AddTo := Self;
  end;
  btnSelectAll := TRMToolbarButton.Create(Self);
  with btnSelectAll do
  begin
    ImageIndex := 12;
    Images := FDesignerForm.ImageListStand;
    //OnClick := FDesignerForm.btnSelectAllClick;
    AddTo := Self;
  end;
  ToolbarSep974 := TRMToolbarSep.Create(Self);
  with ToolbarSep974 do
  begin
    AddTo := Self;
  end;

  SetLength(FAryButton, 0);
  _CreatePageButtons(True);
  _CreatePageButtons(False);
  btnDeletePage := TRMToolbarButton.Create(Self);
  with btnDeletePage do
  begin
    ImageIndex := 15;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnDeletePageClick;
    AddTo := Self;
  end;
  btnPageSetup := TRMToolbarButton.Create(Self);
  with btnPageSetup do
  begin
    ImageIndex := 16;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnPageSetupClick;
    AddTo := Self;
  end;
  ToolbarSep976 := TRMToolbarSep.Create(Self);
  with ToolbarSep976 do
  begin
    AddTo := Self;
  end;

  GB1 := TRMToolbarButton.Create(Self);
  with GB1 do
  begin
    Tag := 55;
    AllowAllUp := True;
    GroupIndex := 1;
    ImageIndex := 17;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.GB1Click;
    AddTo := Self;
  end;
  GB2 := TRMToolbarButton.Create(Self);
  with GB2 do
  begin
    Tag := 56;
    AllowAllUp := True;
    GroupIndex := 2;
    ImageIndex := 18;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.GB2Click;
    AddTo := Self;
  end;
  GB3 := TRMToolbarButton.Create(Self);
  with GB3 do
  begin
    Tag := 57;
    ImageIndex := 19;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.GB3Click;
    AddTo := Self;
  end;
  ToolbarSep9723 := TRMToolbarSep.Create(Self);
  with ToolbarSep9723 do
  begin
    AddTo := Self;
  end;

  cmbScale := TRMComboBox97 {TComboBox}.Create(Self);
  with cmbScale do
  begin
    Parent := Self;
    TabStop := False;
    cmbScale.
      Width := 50;
    Items.Add('25%');
    Items.Add('50%');
    Items.Add('75%');
    Items.Add('100%');
    Items.Add('150%');
    Items.Add('200%');
    Items.Add('400%');
    Text := '100%';

    OnChange := OnCmbScaleChangeEvent;
  end;
  ToolbarSepScale := TRMToolbarSep.Create(Self);
  with ToolbarSepScale do
  begin
    AddTo := Self;
  end;
//  cmbScale.Visible := False;
//  ToolbarSepScale.Visible := False;

  btnExit := TRMToolbarButton.Create(Self);
  with btnExit do
  begin
    ImageIndex := 20;
    Images := FDesignerForm.ImageListStand;
    OnClick := FDesignerForm.btnExitClick;
    AddTo := Self;
  end;

//  EndUpdate;
  Localize;
end;

procedure TRMToolbarStandard.Localize;
begin
  RMSetStrProp(btnFileNew, 'Hint', rmRes + 087);
  RMSetStrProp(btnFileOpen, 'Hint', rmRes + 088);
  RMSetStrProp(btnFileSave, 'Hint', rmRes + 089);
  RMSetStrProp(btnPreview, 'Hint', rmRes + 090);
  RMSetStrProp(btnPrint, 'Hint', rmRes + 937);
  RMSetStrProp(btnCut, 'Hint', rmRes + 091);
  RMSetStrProp(btnCopy, 'Hint', rmRes + 092);
  RMSetStrProp(btnPaste, 'Hint', rmRes + 093);
  RMSetStrProp(btnUndo, 'Hint', rmRes + 094);
  RMSetStrProp(btnRedo, 'Hint', rmRes + 095);
  RMSetStrProp(btnDeletePage, 'Hint', rmRes + 100);
  RMSetStrProp(btnPageSetup, 'Hint', rmRes + 101);
  RMSetStrProp(GB1, 'Hint', rmRes + 102);
  RMSetStrProp(GB2, 'Hint', rmRes + 103);
  RMSetStrProp(GB3, 'Hint', rmRes + 104);
  RMSetStrProp(btnExit, 'Hint', rmRes + 106);
  RMSetStrProp(btnBringtoFront, 'Hint', rmRes + 096);
  RMSetStrProp(btnSendtoBack, 'Hint', rmRes + 097);
  RMSetStrProp(btnSelectAll, 'Hint', rmRes + 098);
  RMSetStrProp(btnPreview1, 'Hint', rmRes + 877);
end;

procedure TRMToolbarStandard.OnCmbScaleChangeEvent(Sender: TObject);
var
  liStr: string;
begin
  FDesignerForm.SetFocus;
  if FDesignerForm.Page is TRMReportPage then
  begin
    liStr := Trim(cmbScale.Text);
    if liStr <> '' then
    begin
      if liStr[Length(liStr)] = '%' then
        SetLength(liStr, Length(liStr) - 1);
      FDesignerForm.Factor := StrToInt(liStr);
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMVirtualReportDesigner }
type
  //  TJvInterpreterArrayValues = array[0..10 - 1] of Integer;
  THackInterpreterFunDesc = class(TJvInterpreterFunctionDesc);

constructor TRMVirtualReportDesigner.Create(aOwner: TComponent);
{$IFNDEF USE_SYNEDIT}
var
  i: Integer;
{$ENDIF}
begin
  inherited;

{$IFDEF USE_SYNEDIT}
  FSynEditSearch := TSynEditSearch.Create(Self);
  FSynEditRegexSearch := TSynEditRegexSearch.Create(Self);
{$ELSE}
  FFindDialog := TFindDialog.Create(Self);
  FFindDialog.OnFind := FindDialog1Find;

  FReplaceDialog := TReplaceDialog.Create(Self);
  FReplaceDialog.OnFind := ReplaceDialog1Find;
  FReplaceDialog.OnReplace := ReplaceDialog1Replace;
  FReplaceDialog.OnShow := ReplaceDialog1Show;
{$ENDIF}

  FCodeMemo := TRMSynEditor.Create(Self);
  with FCodeMemo do
  begin
    Parent := Tab1;
    Visible := False;
{$IFDEF USE_SYNEDIT}
    WantTabs := True;
{$ENDIF}
    Align := alClient;
    SetHighLighter(rmhlPascal);
    Font.Name := 'Courier New';
    Font.Size := 10;
    SetGutterWidth(48);
    SetGroupUndo(True);
    SetUndoAfterSave(False);
    SetShowLineNumbers(True);
    SetReservedForeColor(clBlue);
    SetCommentForeColor(clGreen);

{$IFNDEF USE_SYNEDIT}
    Completion.DropDownCount := 8;
    Completion.Enabled := True;
    Completion.ItemHeight := 13;
    Completion.Interval := 800;
    Completion.ListBoxStyle := lbStandard;
    Completion.CaretChar := '|';
    Completion.CRLF := '/n';
    Completion.Separator := '*';
    Completion.Templates.Clear;
    for i := Low(RMCompletionStr) to High(RMCompletionStr) do
      Completion.Templates.Add(RMCompletionStr[i]);
{$ENDIF}

    OnChange := OnCodeMemoChangeEvent;
{$IFDEF USE_SYNEDIT}
    OnReplaceText := OnCodeMemoReplaceText;
    OnStatusChange := OnCodeMemoStatusChange;
{$ELSE}
    OnChangeStatus := OnCodeMemoSelectionChangeEvent;
{$ENDIF}
    OnDragOver := DoDragOver;
    OnDragDrop := DoDragDrop;
  end;

  FCodeGenEngine := TRMCodeGenEngine.Create;
  FCodeGenEngine.OnGetScript := DoCodeGenGetScript;
  FCodeGenEngine.OnScriptChanged := DoCodeGenScriptChanged;
end;

destructor TRMVirtualReportDesigner.Destroy;
begin
  FCodeGenEngine.Free;
  inherited;
end;

procedure TRMVirtualReportDesigner.OnCodeMemoChangeEvent(Sender: TObject);
begin
  Modified := True;
  EnableControls;
end;

{$IFDEF USE_SYNEDIT}

procedure TRMVirtualReportDesigner.DoSearchReplaceText(aReplace: Boolean;
  aBackwards: Boolean);
var
  lOptions: TSynSearchOptions;
begin
  if aReplace then
    lOptions := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    lOptions := [];

  if aBackwards then
    Include(lOptions, ssoBackwards);
  if FSearchCaseSensitive then
    Include(lOptions, ssoMatchCase);
  if not FSearchFromCaret1 then
    Include(lOptions, ssoEntireScope);
  if FSearchSelectionOnly then
    Include(lOptions, ssoSelectedOnly);
  if FSearchWholeWords then
    Include(lOptions, ssoWholeWord);
  if FSearchRegex then
    FCodeMemo.SearchEngine := FSynEditRegexSearch
  else
    FCodeMemo.SearchEngine := FSynEditSearch;

  if FCodeMemo.SearchReplace(FSearchText, FReplaceText, lOptions) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    //Statusbar.SimpleText := STextNotFound;
    if ssoBackwards in lOptions then
      FCodeMemo.BlockEnd := FCodeMemo.BlockBegin
    else
      FCodeMemo.BlockBegin := FCodeMemo.BlockEnd;

    FCodeMemo.CaretXY := FCodeMemo.BlockBegin;
  end;

  if RMConfirmReplaceDialog <> nil then
    FreeAndNil(RMConfirmReplaceDialog);
end;

procedure TRMVirtualReportDesigner.ShowSearchReplaceDialog(aReplace: Boolean);
var
  lDlg: TForm;
begin
  if aReplace then
    lDlg := TRMTextReplaceDialog.Create(Self)
  else
    lDlg := TRMTextSearchDialog.Create(Self);

  with TRMTextSearchDialog(lDlg) do
  begin
    try
      SearchBackwards := FSearchBackwards;
      SearchCaseSensitive := FSearchCaseSensitive;
      SearchFromCursor := FSearchFromCaret1;
      SearchInSelectionOnly := FSearchSelectionOnly;
      SearchText := FSearchText;
      if FSearchTextAtCaret then
      begin
        if FCodeMemo.SelAvail and (FCodeMemo.BlockBegin.Line = FCodeMemo.BlockEnd.Line) then
          SearchText := FCodeMemo.SelText
        else
          SearchText := FCodeMemo.GetWordAtRowCol(FCodeMemo.CaretXY);
      end;
      SearchTextHistory := FSearchTextHistory;
      if aReplace then
      begin
        with lDlg as TRMTextReplaceDialog do
        begin
          ReplaceText := FReplaceText;
          ReplaceTextHistory := FReplaceTextHistory;
        end;
      end;
      SearchWholeWords := FSearchWholeWords;
      if ShowModal = mrOK then
      begin
        FSearchBackwards := SearchBackwards;
        FSearchCaseSensitive := SearchCaseSensitive;
        FSearchFromCaret1 := SearchFromCursor;
        FSearchSelectionOnly := SearchInSelectionOnly;
        FSearchWholeWords := SearchWholeWords;
        FSearchRegex := SearchRegularExpression;
        FSearchText := SearchText;
        FSearchTextHistory := SearchTextHistory;
        if aReplace then
        begin
          with lDlg as TRMTextReplaceDialog do
          begin
            FReplaceText := ReplaceText;
            FReplaceTextHistory := ReplaceTextHistory;
          end;
        end;
        FSearchFromCaret1 := FSearchFromCaret1;
        if FSearchText <> '' then
        begin
          DoSearchReplaceText(aReplace, FSearchBackwards);
          FSearchFromCaret1 := True;
        end;
      end;
    finally
      lDlg.Free;
    end;
  end;
end;

procedure TRMVirtualReportDesigner.OnCodeMemoReplaceText(Sender: TObject; const aSearch,
  aReplace: string; aLine, aColumn: Integer; var Action: TSynReplaceAction);
var
  lPos: TPoint;
  lEditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else
  begin
    lPos := FCodeMemo.ClientToScreen(
      FCodeMemo.RowColumnToPixels(
      FCodeMemo.BufferToDisplayPos(
      BufferCoord(aColumn, aLine))));
    lEditRect := ClientRect;
    lEditRect.TopLeft := ClientToScreen(lEditRect.TopLeft);
    lEditRect.BottomRight := ClientToScreen(lEditRect.BottomRight);

    if RMConfirmReplaceDialog = nil then
      RMConfirmReplaceDialog := TRMConfirmReplaceDialog.Create(Application);
    RMConfirmReplaceDialog.PrepareShow(lEditRect, lPos.X, lPos.Y,
      lPos.Y + FCodeMemo.LineHeight, aSearch);
    case RMConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
    else
      Action := raCancel;
    end;
  end;
end;

procedure TRMVirtualReportDesigner.OnCodeMemoStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if scModified in Changes then
  begin
    Modified := True;
  end;

  if scSelection in Changes then
  begin
    ShowPosition;
  end;

  EnableControls;
end;

{$ELSE}

procedure TRMVirtualReportDesigner.DoSearchReplaceText(aReplace: Boolean;
  ABackwards: Boolean);
begin
  FindNext;
end;

procedure TRMVirtualReportDesigner.ShowSearchReplaceDialog(aReplace: Boolean);
begin
  if aReplace then
  begin
    FReplaceDialog.Execute;
  end
  else
  begin
    FFindDialog.FindText := FCodeMemo.GetWordOnCaret;
    FFindDialog.Execute;
  end;
end;

procedure TRMVirtualReportDesigner.OnCodeMemoSelectionChangeEvent(Sender: TObject);
begin
  ShowPosition;
  EnableControls;
end;

procedure TRMVirtualReportDesigner.FindDialog1Find(Sender: TObject);
begin
  FFindDialog.CloseDialog;
  FindNext;
end;

procedure TRMVirtualReportDesigner.ReplaceDialog1Find(Sender: TObject);
begin
  Replace_FindNext;
end;

procedure TRMVirtualReportDesigner.ReplaceDialog1Show(Sender: TObject);
begin
  FScriptCanReplace := False;
end;

procedure TRMVirtualReportDesigner.ReplaceDialog1Replace(Sender: TObject);
begin
  if frReplaceAll in FReplaceDialog.Options then
  begin
    if not FScriptCanReplace then
      Replace_FindNext;

    while FScriptCanReplace do
    begin
      FCodeMemo.SelText := FReplaceDialog.ReplaceText;
      Replace_FindNext;
    end;
  end
  else
  begin
    if not FScriptCanReplace then
      Replace_FindNext;

    if FScriptCanReplace then
    begin
      FCodeMemo.SelText := FReplaceDialog.ReplaceText;
      Replace_FindNext;
    end;
  end;
end;

procedure TRMVirtualReportDesigner.FindNext;
var
  lStr, lStr1: string;
  lPStr: PChar;
begin
  lStr := FCodeMemo.Lines.Text;
  lStr1 := FFindDialog.FindText;
  if not (frMatchCase in FFindDialog.Options) then
  begin
    lStr := ANSIUpperCase(lStr);
    lStr1 := ANSIUpperCase(lStr1);
  end;

  lPStr := StrPos(PChar(lStr) + FCodeMemo.SelStart, PChar(lStr1));
  if lPStr <> nil then
  begin
    FCodeMemo.SelStart := lPStr - PChar(lStr);
    FCodeMemo.SelLength := Length(lStr1);
  end;
end;

procedure TRMVirtualReportDesigner.Replace_FindNext;
var
  lStr, lStr1: string;
  lPStr: PChar;
begin
  FScriptCanReplace := False;
  lStr := FCodeMemo.Lines.Text;
  lStr1 := FReplaceDialog.FindText;
  if not (frMatchCase in FReplaceDialog.Options) then
  begin
    lStr := ANSIUpperCase(lStr);
    lStr1 := ANSIUpperCase(lStr1);
  end;

  lPStr := StrPos(PChar(lStr) + FCodeMemo.SelStart, PChar(lStr1));
  if lPStr <> nil then
  begin
    FCodeMemo.SelStart := lPStr - PChar(lStr);
    FCodeMemo.SelLength := Length(lStr1);
    FScriptCanReplace := True;
  end
  else
    FReplaceDialog.CloseDialog;
end;
{$ENDIF}

procedure TRMVirtualReportDesigner.DoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (not FCodeMemo.ReadOnly) and
    (Source = TRMDesignerForm(Self).FFieldForm.lstFields);
end;

procedure TRMVirtualReportDesigner.DoDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  lStr: string;
begin
  lStr := TRMDesignerForm(Self).FFieldForm.DBField;
  if lStr <> '' then
  begin
    lStr := 'GetValue(''' + lStr + ''')';

{$IFNDEF USE_SYNEDIT}
    if FCodeMemo.SelLength = 0 then
      FCodeMemo.SelStart := FCodeMemo.PosFromCaret(FCodeMemo.CaretX, FCodeMemo.CaretY);
{$ENDIF}
    FCodeMemo.SelText := lStr;
    FCodeMemo.SelLength := 0;
//      lStr1 := FCodeMemo.Lines[FCodeMemo.CaretY];
//      while Length(lStr1) <= FCodeMemo.CaretX do
//        lStr1 := lStr1 + ' ';

//      System.Insert(lStr, lStr1, FCodeMemo.CaretX + 1);
//      FCodeMemo.Lines[FCodeMemo.CaretY] := lStr1;
//      FCodeMemo.SelText := 'ddd';
  end;
end;

procedure TRMVirtualReportDesigner.SetModified(Value: Boolean);
begin
  inherited;
  if Value then
    FCodeGenEngine.Modified;
end;

function TRMVirtualReportDesigner.FunctionExists(
  const aFuncName: string): Boolean;
begin
  Result := FCodeGenEngine.FunctionExists(AFuncName);
end;

function TRMVirtualReportDesigner.DefineMethod(const AFuncName,
  AFuncDefine: string): boolean;
begin
  Result := True;
  try
    FCodeMemo.BeginUpdate;
    try
      if not FCodeGenEngine.FunctionExists(AFuncName) then
      begin
        FCodeGenEngine.AddFunctionCode(AFuncName,AFuncDefine,nil);
      end;

    finally
      FCodeMemo.EndUpdate;
    end;

  except
    Result:=False;
  end;
end;

function TRMVirtualReportDesigner.GotoMethod(const AFuncName:string): boolean;
var
  i:Integer;
begin
  result := True;
  if FCodeGenEngine.FunctionExists(AFuncName) then
  begin
    i := FCodeGenEngine.GetFunctionPos(AFuncName);
    EditorScriptPos := i;
  end;
end;

function TRMVirtualReportDesigner.GetEditorScriptText: string;
begin
   Result := FCodeMemo.Lines.Text;
end;

procedure TRMVirtualReportDesigner.SetEditorScriptText(
  const Value: string);
begin
  FCodeMemo.ReadOnly := False;
  FCodeMemo.RMClearUndoBuffer;
  FCodeMemo.Lines.Text := Value;
  if FCodeMemo.Lines.Count = 0 then
  begin
    FCodeMemo.Lines.Add('unit Report;');
    FCodeMemo.Lines.Add('');
    FCodeMemo.Lines.Add('interface');
    FCodeMemo.Lines.Add('');
    FCodeMemo.Lines.Add('implementation');
    FCodeMemo.Lines.Add('');
    FCodeMemo.Lines.Add('procedure Main;');
    FCodeMemo.Lines.Add('begin');
    FCodeMemo.Lines.Add('');
    FCodeMemo.Lines.Add('end;');
    FCodeMemo.Lines.Add('');
    FCodeMemo.Lines.Add('end.');
  end;
  FCodeMemo.ReadOnly := (DesignerRestrictions * [rmdtDontEditScript]) = [rmdtDontEditScript];
//  FCodeGenEngine.Modified;
end;

function TRMVirtualReportDesigner.GetEditorScript: TStrings;
begin
 Result := FCodeMemo.Lines;
end;

function TRMVirtualReportDesigner.GetEditorScriptPos: integer;
begin
  Result := FCodeMemo.SelStart;
end;


//=== { TJclEventParamInfo } =================================================
Type
  // Event types
  IJclEventParamInfo = interface
    ['{7DAD5229-46EA-11D5-B0C0-4854E825F345}']
    function GetFlags: TParamFlags;
    function GetName: string;
    {$IFNDEF CLR}
    function GetRecSize: Integer;
    {$ENDIF ~CLR}
    function GetTypeName: string;
    function GetParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF};

    property Flags: TParamFlags read GetFlags;
    property Name: string read GetName;
    {$IFNDEF CLR}
    property RecSize: Integer read GetRecSize;
    {$ENDIF ~CLR}
    property TypeName: string read GetTypeName;
    property Param: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF} read GetParam;
  end;

  TJclEventParamInfo = class(TInterfacedObject, IJclEventParamInfo)
  private
    FParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF};
  protected
    function GetFlags: TParamFlags;
    function GetName: string;
    function GetRecSize: Integer;
    function GetTypeName: string;
    function GetParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF};
  public
    constructor Create(const AParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF});

    property Flags: TParamFlags read GetFlags;
    property Name: string read GetName;
    property RecSize: Integer read GetRecSize;
    property TypeName: string read GetTypeName;
    property Param: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF} read GetParam;
  end;

constructor TJclEventParamInfo.Create(const AParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF});
begin
  inherited Create;
  FParam := AParam;
end;

function TJclEventParamInfo.GetFlags: TParamFlags;
{$IFDEF CLR}
var
  Attr: Attribute;
{$ENDIF CLR}
begin
  {$IFDEF CLR}
  Result := [];
  if FParam.IsOut then
    Result := [pfOut]
  else
  if FParam.ParameterType.IsByRef then
    Result := [pfVar]
  else
  if FindAttribute(FParam.ParameterType, TypeOf(TConstantParamAttribute), Attr) then
    Result := [pfConst];

  with FParam.ParameterType do
    if IsArray or (IsByRef and HasElementType and GetElementType.IsArray) then
       Include(Result, pfArray);
  {$ELSE}
  Result := TParamFlags(PByte(Param)^);
  {$ENDIF CLR}
end;

function TJclEventParamInfo.GetName: string;
{$IFDEF CLR}
begin
  Result := FParam.Name;
end;
{$ELSE}
var
  PName: PShortString;
begin
  PName := Param;
  Inc(Integer(PName));
  Result := PName^;
end;
{$ENDIF CLR}

function TJclEventParamInfo.GetRecSize: Integer;
begin
  Result := 3 + Length(Name) + Length(TypeName);
end;

function TJclEventParamInfo.GetTypeName: string;
{$IFDEF CLR}
begin
  Result := FParam.ParameterType.Name;
end;
{$ELSE}
var
  PName: PShortString;
begin
  PName := Param;
  Inc(Integer(PName));
  Inc(Integer(PName), PByte(PName)^ + 1);
  Result := PName^;
end;
{$ENDIF CLR}

function TJclEventParamInfo.GetParam: {$IFDEF CLR}ParameterInfo{$ELSE}Pointer{$ENDIF};
begin
  Result := FParam;
end;

function _GetEventParameters(ATypeData: PTypeData;const ParamIdx: Integer): IJclEventParamInfo;
{$IFNDEF CLR}
var
  I: Integer;
  Param: Pointer;
{$ENDIF ~CLR}
begin
  Result := nil;
  {$IFDEF CLR}
  if ParamIdx < ATypeData.ParamCount then
    Result := TJclEventParamInfo.Create(ATypeData.Params[ParamIdx]);
  {$ELSE}
  Param := @ATypeData.ParamList[0];
  I := ParamIdx;
  while I >= 0 do
  begin
    Result := TJclEventParamInfo.Create(Param);
    Inc(Integer(Param), Result.RecSize);
    Dec(I);
  end;
  {$ENDIF CLR}
end;


procedure TRMVirtualReportDesigner.GetMethodsList(ATypeInfo: PTypeInfo;
  AValues: TStrings);
var
  i:integer;
  lFuncDesc:TJvInterpreterFunctionDesc;
  lTypeData: PTypeData;

  function _CmpParams(ap1:TJvInterpreterFunctionDesc;ap2:PTypeInfo):boolean;
  var
    ci:integer;
  begin
    Result:=false;
    if (ap1.ParamCount <> lTypeData.ParamCount) or
        (ap1.ResTyp <> varEmpty)  then
      Exit;
    for ci := 0 to ap1.ParamCount-1 do
    begin
      if Not SameText(ap1.ParamTypeNames[ci],
           _GetEventParameters(lTypeData,ci).TypeName) then
      begin
         Exit;
      end;
    end;
    Result:=true;
  end;
begin
  with FCodeGenEngine do
  begin
    CompileScript;
    lTypeData := TypInfo.GetTypeData(ATypeInfo);
    if ScriptEngine.Adapter.SrcFunctionList.Count<=0 then
      Exit;
    if lTypeData.MethodKind <> mkProcedure then
      Exit;
    with ScriptEngine.Adapter do
    begin
      for i := 0 to SrcFunctionList.Count-1 do
      begin
        lFuncDesc := TJvInterpreterSrcFunction(SrcFunctionList.Items[i]).FunctionDesc;
        if _CmpParams(lFuncDesc,ATypeInfo) then
           AValues.Add(lFuncDesc.Identifier);
      end;
    end;
 end;
end;

function TRMVirtualReportDesigner.RenameMethod(const ACurName,
  ANewName: string): boolean;
begin
  try
     Result := FCodeGenEngine.RenameFunction(ACurName,ANewName);
  except
    Result:=False;
  end;
end;

procedure TRMVirtualReportDesigner.SetEditorScript(Value: TStrings);
begin
  if Value <> nil then
    EditorScriptText := Value.Text;
end;

procedure TRMVirtualReportDesigner.SetEditorScriptPos(
  const Value: integer);
begin
  if FCodeMemo.SelStart <> Value then
  begin
    FCodeMemo.SelStart :=Value;
  end;
  if FTab1.TabIndex <> 0 then
  begin
    FTab1.TabIndex := 0;
  end;
    FTab1.OnChange(Tab1);
end;

procedure TRMVirtualReportDesigner.DoCodeGenGetScript(
  const AList: TStrings);
begin
  if FInAssignScript then
    Exit;
  BeginUpdateScript;
  AList.Clear;
  try
    AList.Assign(EditorScript);
  finally
    EndUpdateScript;
  end;

end;

procedure TRMVirtualReportDesigner.DoCodeGenScriptChanged(Sender: TObject);
begin
  if FInAssignScript then
    Exit;

  BeginUpdateScript;
  try
    EditorScriptText := TRMCodeGenEngine(Sender).ScriptText;
  finally
    EndUpdateScript;
  end;
end;

procedure TRMVirtualReportDesigner.BeginUpdateScript;
begin
  FInAssignScript := True;
end;

procedure TRMVirtualReportDesigner.EndUpdateScript;
begin
  FInAssignScript := False;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

{ TRMDesignerForm }

procedure TRMDesignerForm.SetObjectID(t: TRMView);
begin
  THackView(t).ObjectID := ObjID;
  Inc(ObjID);
end;

function TRMDesignerForm.PageObjects: TList;
begin
  Result := nil;
  if FCurPageEditor <> nil then
    Result := FCurPageEditor.Editor_PageObjects;

  if (Result = nil) and (Page <> nil) then
    Result := Page.Objects;
end;

function TRMDesignerForm.TopSelected: Integer;
var
  i: Integer;
  lList: TList;
begin
  lList := PageObjects;
  Result := 0;
  for i := lList.Count - 1 downto 0 do
  begin
    if TRMView(lList[i]).Selected then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TRMDesignerForm.IsSubreport(PageN: Integer): TRMView;
var
  i, j: Integer;
  t: TRMView;
  liPage: THackPage;
begin
  Result := nil;
  with Report do
  begin
    for i := 0 to Pages.Count - 1 do
    begin
      liPage := THackPage(Pages[i]);
      for j := 0 to liPage.Objects.Count - 1 do
      begin
        t := liPage.Objects[j];
        if t.ObjectType = rmgtSubReport then
        begin
          if TRMSubReportView(t).SubPage = PageN then
          begin
            Result := t;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function TRMDesignerForm.RMCheckBand(b: TRMBandType): Boolean;
var
  i: Integer;
  t: TRMView;
begin
  Result := False;
  for i := 0 to THackPage(Page).Objects.Count - 1 do
  begin
    t := THackPage(Page).Objects[i];
    if t.IsBand then
    begin
      if b = TRMCustomBandView(t).BandType then
      begin
        Result := True;
        break;
      end;
    end;
  end;
end;

function TRMDesignerForm.Objects: TList;
begin
  Result := THackPage(Page).Objects;
end;

procedure TRMDesignerForm.SetObjectsID;
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_SetObjectsID;
end;

procedure TRMDesignerForm.ReleaseAction(aActionRec: PRMUndoRec);
begin
  FreeAndNil(aActionRec.Stream);
  FreeAndNil(aActionRec.AddObj);
end;

procedure TRMDesignerForm.ClearUndoBuffer;
var
  i: Integer;
begin
  for i := 0 to FUndoBufferLength - 1 do
    ReleaseAction(@UndoBuffer[i]);

  FUndoBufferLength := 0;
  if (not FBusy) and (not FInspBusy) then
    EnableControls;
end;

procedure TRMDesignerForm.ClearRedoBuffer;
var
  i: Integer;
begin
  for i := 0 to FRedoBufferLength - 1 do
    ReleaseAction(@RedoBuffer[i]);

  FRedoBufferLength := 0;
  if (not FBusy) and (not FInspBusy) then
    EnableControls;
end;

procedure TRMDesignerForm.AddUndoAction(aAction: TRMUndoAction);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_AddUndoAction(aAction);
end;

procedure TRMDesignerForm.CreateDefaultPage;
var
  lPageClassName: string;
//  liBandPageHeader: TRMBandPageHeader;
//  liBandPageFooter: TRMBandPageFooter;
//  liBandMasterData: TRMBandMasterData;
begin
  if RMDesignerComp <> nil then
    lPageClassName := RMDesignerComp.DefaultPageClassName
  else
    lPageClassName := RMApplication.DefaultPageClassName;

  if lPageClassName = '' then
    lPageClassName := Report.DefaultPageClassName;

  Report.Pages.AddReportPage(lPageClassName);
  Report.Pages[0].CreateName(False);

  {  liBandPageHeader := TRMBandPageHeader.Create;
    liBandPageHeader.ParentPage := Report.Pages[0];
    liBandPageHeader.spHeight_Designer := 18 * 3;

    liBandPageFooter := TRMBandPageFooter.Create;
    liBandPageFooter.ParentPage := Report.Pages[0];
    liBandPageFooter.spHeight_Designer := 18 * 2;

    liBandMasterData := TRMBandMasterData.Create;
    liBandMasterData.ParentPage := Report.Pages[0];
    liBandMasterData.spHeight_Designer := 18 * 3;
  }

  if (RMDesignerComp <> nil) and (RMDesignerComp.DefaultDictionaryFile <> '') and
    FileExists(RMDesignerComp.DefaultDictionaryFile) then
    Report.Dictionary.LoadFromFile(RMDesignerComp.DefaultDictionaryFile);
end;

procedure TRMDesignerForm.InspSelectionChanged(ObjName: string);
begin
  if FCurPageEditor <> nil then
  begin
    FCurPageEditor.Editor_SelectObject(ObjName);
    if Tab1.TabIndex = 0 then
      FCurPageEditor.Editor_FillInspFields;
  end;
end;

procedure TRMDesignerForm.OnInspBeforeModify(Sender: TObject; const aPropName: string);
begin
  if DesignerRestrictions * [rmdrDontModifyObj] <> [] then Abort;

  if (not (csDesigning in Report.ComponentState)) and
    (FInspForm.Insp.Objects[0] is TRMView) and (System.Pos('rmrtDont', aPropName) <> 1) then
  begin
    if (TRMView(FInspForm.Insp.Objects[0]).Restrictions * [rmrtDontModify]) <> [] then
      Abort;
  end;

  BeforeChange;
end;

procedure TRMDesignerForm.OnInspAfterModify(Sender: TObject; const aPropName, aPropValue: string);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_OnInspAfterModify(Sender, aPropName, aPropValue);
end;

procedure TRMDesignerForm.SaveIni;
var
  Ini: TRegIniFile;
  Nm: string;
  i: Integer;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + '\RMReport');
  try
    Nm := rsForm + Name;
    Ini.WriteString(Nm, rsLanguage, RM_CurLanguage);
    Ini.WriteBool(Nm, rsLocalizedPropertyName, RMLocalizedPropertyNames);
    Ini.WriteBool(Nm, rsAutoOpenLastFile, AutoOpenLastFile);
    Ini.WriteBool(Nm, rsGridShow, ShowGrid);
    Ini.WriteBool(Nm, rsGridAlign, GridAlign);
    Ini.WriteInteger(Nm, rsGridSize, GridSize);
    Ini.WriteInteger(Nm, rsUnits, Word(RMUnits));
    Ini.WriteBool(Nm, rsEdit, FEditAfterInsert);
    Ini.WriteBool(Nm, rsBandTitles, RM_Class.RMShowBandTitles);
    Ini.WriteBool(Nm, rsShowDropDownField, RM_Class.RMShowDropDownField);
    Ini.WriteInteger(rsForm + FInspForm.ClassName, 'SplitPos', FInspForm.SplitterPos);
    Ini.WriteInteger(rsForm + FInspForm.ClassName, 'SplitPos1', FInspForm.SplitterPos1);
    Ini.WriteBool(Nm, rsUseTableName, UseTableName);
    Ini.WriteInteger(Nm, rsWorkSpaceColor, WorkSpaceColor);
    Ini.WriteInteger(Nm, rsInspFormColor, InspFormColor);
    if not IsPreviewDesign then
    begin
      Ini.WriteInteger(rsForm + FFieldForm.ClassName, 'SplitPos', FFieldForm.SplitterPos);
      Ini.EraseSection(rsOpenFiles);
      for i := 1 to FOpenFiles.Count do
        Ini.WriteString(rsOpenFiles, 'File' + IntToStr(i), FOpenFiles[i - 1]);
    end;
  finally
    Ini.Free;
  end;

  RMSaveToolbars('\RMReport', [ToolbarStandard]);
  RMSaveToolWinPosition('\RMReport', FInspForm);
  RMSaveFormPosition('\RMReport', Self);
  if not IsPreviewDesign then
  begin
    RMSaveToolWinPosition('\RMReport', FFieldForm);
  end;
end;

procedure TRMDesignerForm.LoadIni;
var
  Ini: TRegIniFile;
  Nm: string;
begin
  Ini := TRegIniFile.Create(RMRegRootKey + '\RMReport');
  try
    Nm := rsForm + Name;
    RM_CurLanguage := Ini.ReadString(Nm, rsLanguage, RM_CurLanguage);
    RMLocalizedPropertyNames := Ini.ReadBool(Nm, rsLocalizedPropertyName, RMLocalizedPropertyNames);
    FGridSize := Ini.ReadInteger(Nm, rsGridSize, 4);
    if FGridSize = 0 then
      FGridSize := 4;
    FGridAlign := Ini.ReadBool(Nm, rsGridAlign, True);
    FShowGrid := Ini.ReadBool(Nm, rsGridShow, True);
    RMUnits := TRMUnitType(Ini.ReadInteger(Nm, rsUnits, 0));
    FEditAfterInsert := Ini.ReadBool(Nm, rsEdit, False);
    RM_Class.RMShowBandTitles := Ini.ReadBool(Nm, rsBandTitles, True);
    RM_Class.RMShowDropDownField := Ini.ReadBool(Nm, rsShowDropDownField, True);
    UseTableName := Ini.ReadBool(Nm, rsUseTableName, True);
    RMRestoreToolWinPosition('\RMReport', FInspForm);
    FInspForm.SplitterPos := Ini.ReadInteger(rsForm + FInspForm.ClassName, 'SplitPos', 75);
    FInspForm.SplitterPos1 := Ini.ReadInteger(rsForm + FInspForm.ClassName, 'SplitPos1', FInspForm.SplitterPos1);
    FInspForm.Visible := Ini.ReadBool(rsForm + FInspForm.ClassName, rsVisible, True);
    WorkSpaceColor := Ini.ReadInteger(Nm, rsWorkSpaceColor, clWhite);
    InspFormColor := Ini.ReadInteger(Nm, rsInspFormColor, clWhite);
    FFieldForm.SplitterPos := Ini.ReadInteger(rsForm + FFieldForm.ClassName, 'SplitPos', 75);
  finally
    Ini.Free;
  end;

//  Dock971.BeginUpdate;
//  Dock972.BeginUpdate;
//  Dock973.BeginUpdate;
//  Dock974.BeginUpdate;
  try
    RMRestoreToolbars('\RMReport', [ToolbarStandard]);
    RMRestoreToolWinPosition('\RMReport', FFieldForm);
    if IsPreviewDesign then
      FFieldForm.Visible := False;
    RMRestoreFormPosition('\RMReport', Self);
  finally
//    Dock971.EndUpdate;
//    Dock972.EndUpdate;
//    Dock973.EndUpdate;
//    Dock974.EndUpdate;
  end;
end;

procedure TRMDesignerForm.SetOpenFileMenuItems(const aNewFile: string);
var
  i, lCount, liIndex: Integer;
  str: string;
{$IFDEF USE_TB2k}
  lItem: TTBItem;
{$ELSE}
  lItem: TMenuItem;
{$ENDIF}
  lDefaultOpenFileIndex: Integer;
begin
  if aNewFile <> '' then
  begin
    liIndex := FOpenFiles.IndexOf(aNewFile);
    if liIndex < 0 then
      FOpenFiles.Insert(0, aNewFile)
    else
    begin
      for i := liIndex - 1 downto 0 do
        FOpenFiles[i + 1] := FOpenFiles[i];
      FOpenFiles[0] := aNewFile;
    end;
    while FOpenFiles.Count > 9 do
      FOpenFiles.Delete(9);
  end;

  lDefaultOpenFileIndex := FBarFile.IndexOf(itmFileFile1) - 1;
{$IFDEF USE_TB2K}
  ToolbarStandard.btnFileOpen.Clear;
{$ELSE}
  while FPopupMenuOpendFiles.Items.Count > 0 do
    FPopupMenuOpendFiles.Items.Delete(0);
  for i := 0 to 9 do
  begin
    if FBarFile.Items[lDefaultOpenFileIndex + 1 + i].Visible then
    begin
    end;
  end;
{$ENDIF}
  lCount := FOpenFiles.Count;
  if (RMDesignerComp <> nil) and (lCount > RMDesignerComp.OpenFileCount) then
    lCount := RMDesignerComp.OpenFileCount;
  for i := 1 to lCount do
  begin
    str := RMMinimizeName(FOpenFiles[i - 1], Canvas, 400);
    FBarFile.Items[lDefaultOpenFileIndex + i].Caption := '&' + IntToStr(i) + ' ' + str;
    FBarFile.Items[lDefaultOpenFileIndex + i].Visible := True;
{$IFDEF USE_TB2k}
    lItem := TTBItem.Create(ToolbarStandard.btnFileOpen);
    lItem.Tag := FBarFile.Items[lDefaultOpenFileIndex + i].Tag;
    lItem.Caption := FBarFile.Items[lDefaultOpenFileIndex + i].Caption;
    lItem.OnClick := itmFileFile9Click;
    ToolbarStandard.btnFileOpen.Add(lItem);
{$ELSE}
    lItem := TMenuItem.Create(FPopupMenuOpendFiles);
    lItem.Tag := FBarFile.Items[lDefaultOpenFileIndex + i].Tag;
    lItem.Caption := FBarFile.Items[lDefaultOpenFileIndex + i].Caption;
    lItem.OnClick := itmFileFile9Click;
    FPopupMenuOpendFiles.Items.Add(lItem);
{$ENDIF}
  end;

  ToolbarStandard.btnFileOpen.DropdownCombo := lCount >= 1;
{$IFNDEF USE_TB2K}
  if lCount >= 1 then
    ToolbarStandard.btnFileOpen.DropdownMenu := FPopupMenuOpendFiles
  else
    ToolbarStandard.btnFileOpen.DropdownMenu := nil;
{$ENDIF}
  for i := lCount to 9 do
    FBarFile.Items[lDefaultOpenFileIndex + 1 + i].Visible := False;
  N1.Visible := lCount > 0;
end;

procedure TRMDesignerForm.InspGetObjects(List: TStrings);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_OnInspGetObjects(List);
end;

procedure TRMDesignerForm.DoClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_DoClick(Sender);
end;

procedure TRMDesignerForm.SetCurDocName(Value: string);
var
  lStr, lStr1: string;
begin
  FCurDocName := Value;
  if Report.ReportInfo.Title <> '' then
  begin
    lStr := Report.ReportInfo.Title;
    lStr1 := ExtractFileName(Value);
    if lStr1 <> '' then
      lStr := lStr + '(' + lStr1 + ')';
  end
  else
    lStr := ExtractFileName(Value);

  Caption := FCaption + ' - ' + lStr;
end;

function TRMDesignerForm.GetModified: Boolean;
begin
  Result := Report.Modified;
end;

procedure TRMDesignerForm.SetModified(Value: Boolean);
begin
  if Report.Modified = Value then Exit;
  Report.Modified := Value;
  if Value and (not IsPreviewDesign) then
    Report.ComponentModified := True;

//  ToolbarStandard.btnFileSave.Enabled := (not IsPreviewDesign) and Value;
//  padFileSave.Enabled := ToolbarStandard.btnFileSave.Enabled;
end;

procedure TRMDesignerForm.OnDockRequestDockEvent(Sender: TObject;
  Bar: TRMCustomDockableWindow; var Accept: Boolean);
begin
  Accept := not ((Bar = FInspForm) or (Bar = FFieldForm));
end;

procedure TRMDesignerForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  FCaption := RMLoadStr(rmRes + 080);
  RMSetStrProp(ToolbarStandard, 'Caption', rmRes + 081);

  RMSetStrProp(FBarFile, 'Caption', rmRes + 154);
  RMSetStrProp(padFileNew, 'Caption', rmRes + 155);
  RMSetStrProp(padFileOpen, 'Caption', rmRes + 156);
  RMSetStrProp(padFileSave, 'Caption', rmRes + 157);
  RMSetStrProp(padVarList, 'Caption', rmRes + 158);
  RMSetStrProp(padPrint, 'Caption', rmRes + 159);
  RMSetStrProp(padPageSetup, 'Caption', rmRes + 160);
  RMSetStrProp(padPreview, 'Caption', rmRes + 161);
  RMSetStrProp(MenuFileHeaderFooter, 'Caption', rmRes + 874);
  RMSetStrProp(padFileExit, 'Caption', rmRes + 162);

  RMSetStrProp(FBarHelp, 'Caption', rmRes + 190);
  RMSetStrProp(padAbout, 'Caption', rmRes + 187);
  RMSetStrProp(padFileSaveAs, 'Caption', rmRes + 188);
  RMSetStrProp(padHelp, 'Caption', rmRes + 189);
  RMSetStrProp(padFileProperty, 'Caption', rmRes + 216);

  RMSetStrProp(LoadDictionary1, 'Caption', rmRes + 223);
  RMSetStrProp(MergeDictionary1, 'Caption', rmRes + 224);
  RMSetStrProp(SaveAsDictionary1, 'Caption', rmRes + 225);
end;

procedure TRMDesignerForm.GB1Click(Sender: TObject);
begin
  ShowGrid := ToolbarStandard.GB1.Down;
  EnableControls;
end;

procedure TRMDesignerForm.GB2Click(Sender: TObject);
begin
  GridAlign := ToolbarStandard.GB2.Down;
  EnableControls;
end;

procedure TRMDesignerForm.GB3Click(Sender: TObject);
var
  i: Integer;
  t: TRMView;
begin
  AddUndoAction(rmacEdit);
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
    begin
      t.spLeft_Designer := Round(t.spLeft_Designer / GridSize) * GridSize;
      t.spTop_Designer := Round(t.spTop_Designer / GridSize) * GridSize;
      t.spWidth_Designer := Round(t.spWidth_Designer / GridSize) * GridSize;
      t.spHeight_Designer := Round(t.spHeight_Designer / GridSize) * GridSize;
      if t.spWidth_Designer = 0 then
        t.spWidth_Designer := GridSize;
      if t.spHeight_Designer = 0 then
        t.spHeight_Designer := GridSize;
    end;
  end;

  //FWorkSpace.GetMultipleSelected;
  RedrawPage;
  ShowPosition;
end;

procedure TRMDesignerForm.SetFactor(Value: Integer);
begin
  if FFactor <> Value then
  begin
    FFactor := Value;
    //FWorkSpace.Init;
    CurPage := CurPage;
  end;
end;

function TRMDesignerForm.GetDesignerRestrictions: TRMDesignerRestrictions;
begin
  if RMDesignerComp <> nil then
    Result := RMDesignerComp.DesignerRestrictions
  else
    Result := [];
end;

procedure TRMDesignerForm.SetDesignerRestrictions(Value: TRMDesignerRestrictions);
begin
  if RMDesignerComp <> nil then
    RMDesignerComp.DesignerRestrictions := Value;
end;

procedure TRMDesignerForm.FormCreate(Sender: TObject);

  procedure _CreateTabPanel;
  begin
    FTab1 := TRMTabControl.Create(Self);
    with FTab1 do
    begin
      Name := 'Tab1';
      Parent := Self;
      Align := alClient;
      HotTrack := True;
      MultiLine := False;
      TabOrder := 1;
      AddTab('Page1');
      TabIndex := 0;
      TabStop := False;
      OnChange := Tab1Change;
      OnChanging := Tab1Changing;
      OnMouseDown := Tab1MouseDown;
      OnMouseMove := Tab1MouseMove;
      OnMouseUp := Tab1MouseUp;
      OnDragOver := Tab1DragOver;
      OnDragDrop := Tab1DragDrop;
    end;

    //FTab1.TabPosition := tpBottom;
    FPopupMenuOpendFiles := TRMPopupMenu.Create(Self);
{$IFDEF USE_TB2K}
{$ELSE}
    FPopupMenuOpendFiles.AutoHotkeys := maManual;
    FPopupMenuOpendFiles.AutoLineReduction := maManual;
{$ENDIF}
  end;

  procedure _CreateDock;
  begin
    Dock971 := TRMDock.Create(Self);
    with Dock971 do
    begin
      Parent := Self;
      FixAlign := True;
      Position := dpTop;
      Name := 'Dock971';
      OnRequestDock := OnDockRequestDockEvent;
      BoundLines := [BlTop];
    end;
    Dock972 := TRMDock.Create(Self);
    with Dock972 do
    begin
      Parent := Self;
      FixAlign := True;
      Position := dpLeft;
      Name := 'Dock972';
    end;
    Dock973 := TRMDock.Create(Self);
    with Dock973 do
    begin
      Parent := Self;
      FixAlign := True;
      Position := dpRight;
      Name := 'Dock973';
    end;
    Dock974 := TRMDock.Create(Self);
    with Dock974 do
    begin
      Parent := Self;
      FixAlign := True;
      Position := dpBottom;
      Name := 'Dock974';
      OnRequestDock := OnDockRequestDockEvent;
    end;
  end;

  //Create MainMenu
  procedure _CreateMainMenu;
  begin
    FMainMenu := TRMMenuBar.Create(Self);
    with FMainMenu do
    begin
      Name := 'MenuBar';
{$IFDEF USE_TB2K}
      Parent := Self;
      Caption := RMLoadStr(rmRes + 251);
      MenuBar := True;
      Dockedto := Dock971;
{$ELSE}
      AutoHotkeys := maManual;
      AutoLineReduction := maManual;
{$ENDIF}
    end;

    FBarFile := TRMSubmenuItem.Create(Self);
    with FBarFile do
    begin
      Caption := '&File';
      AddToMenu(FMainMenu);
      GroupIndex := 1;
    end;
    padFileNew := TRMmenuItem.Create(Self);
    with padFileNew do
    begin
      //ImageIndex := 0;
      //Images := ImageListStand;
      Name := 'padFileNew';
      Caption := '&New...';
      ShortCut := 16462;
      OnClick := padFileNewClick;
      AddToMenu(FBarFile);
    end;
    padFileOpen := TRMmenuItem.Create(Self);
    with padFileOpen do
    begin
      //ImageIndex := 1;
      //Images := ImageListStand;
      Name := 'padFileOpen';
      Caption := '&Open...';
      ShortCut := 16463;
      OnClick := btnFileOpenClick;
      AddToMenu(FBarFile);
    end;
    padFileSave := TRMmenuItem.Create(Self);
    with padFileSave do
    begin
      //ImageIndex := 2;
      //Images := ImageListStand;
      Caption := 'Save';
      ShortCut := 16467;
      OnClick := btnFileSaveClick;
      AddToMenu(FBarFile);
    end;
    padFileSaveAs := TRMmenuItem.Create(Self);
    with padFileSaveAs do
    begin
      Caption := 'Save as...';
      OnClick := padFileSaveAsClick;
      AddToMenu(FBarFile);
    end;
    N40 := TRMSeparatorMenuItem.Create(Self);
    N40.AddToMenu(FBarFile);
    padVarList := TRMmenuItem.Create(Self);
    with padVarList do
    begin
      Caption := 'Dictionary...';
      OnClick := padVarListClick;
      AddToMenu(FBarFile);
    end;
    LoadDictionary1 := TRMmenuItem.Create(Self);
    with LoadDictionary1 do
    begin
      Caption := 'Import Dictionary...';
      OnClick := LoadDictionary1Click;
      AddToMenu(FBarFile);
    end;
    MergeDictionary1 := TRMmenuItem.Create(Self);
    with MergeDictionary1 do
    begin
      Caption := 'Merge Dictionary...';
      OnClick := MergeDictionary1Click;
      AddToMenu(FBarFile);
    end;
    SaveAsDictionary1 := TRMmenuItem.Create(Self);
    with SaveAsDictionary1 do
    begin
      Caption := 'Export Dictionary...';
      OnClick := SaveAsDictionary1Click;
      AddToMenu(FBarFile);
    end;
    N21 := TRMSeparatorMenuItem.Create(Self);
    N21.AddToMenu(FBarFile);
    padPageSetup := TRMmenuItem.Create(Self);
    with padPageSetup do
    begin
      //ImageIndex := 16;
      //Images := ImageListStand;
      Caption := 'Page Options...';
      OnClick := btnPageSetupClick;
      AddToMenu(FBarFile);
    end;
    FMenuFileHeaderFooter := TRMMenuItem.Create(Self);
    with FMenuFileHeaderFooter do
    begin
      ImageIndex := -1;
      Images := ImageListStand;
      Caption := 'Header/Footer...';
      OnClick := MenuFileHeaderFooterClick;
      AddToMenu(FBarFile);
    end;
    padPreview := TRMmenuItem.Create(Self);
    with padPreview do
    begin
      //ImageIndex := 4;
      //Images := ImageListStand;
      Caption := 'Print Preview...';
      ShortCut := 16464;
      OnClick := btnPreviewClick;
      AddToMenu(FBarFile);
    end;
    padPrint := TRMmenuItem.Create(Self);
    with padPrint do
    begin
      //ImageIndex := 3;
      //Images := ImageListStand;
      Caption := '&Print';
      OnClick := padPrintClick;
      AddToMenu(FBarFile);
    end;
    N24 := TRMSeparatorMenuItem.Create(Self);
    N24.AddToMenu(FBarFile);
    padFileProperty := TRMmenuItem.Create(Self);
    with padFileProperty do
    begin
      Caption := 'Property...';
      OnClick := padFilePropertyClick;
      AddToMenu(FBarFile);
    end;

    N2 := TRMSeparatorMenuItem.Create(Self);
    N2.AddToMenu(FBarFile);
    itmFileFile1 := TRMmenuItem.Create(Self);
    with itmFileFile1 do
    begin
      Tag := 1;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile2 := TRMmenuItem.Create(Self);
    with itmFileFile2 do
    begin
      Tag := 2;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile3 := TRMmenuItem.Create(Self);
    with itmFileFile3 do
    begin
      Tag := 3;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile4 := TRMmenuItem.Create(Self);
    with itmFileFile4 do
    begin
      Tag := 4;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile5 := TRMmenuItem.Create(Self);
    with itmFileFile5 do
    begin
      Tag := 5;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile6 := TRMmenuItem.Create(Self);
    with itmFileFile6 do
    begin
      Tag := 6;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile7 := TRMmenuItem.Create(Self);
    with itmFileFile7 do
    begin
      Tag := 7;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile8 := TRMmenuItem.Create(Self);
    with itmFileFile8 do
    begin
      Tag := 8;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;
    itmFileFile9 := TRMmenuItem.Create(Self);
    with itmFileFile9 do
    begin
      Tag := 9;
      OnClick := itmFileFile9Click;
      AddToMenu(FBarFile);
    end;

    N1 := TRMSeparatorMenuItem.Create(Self);
    N1.AddToMenu(FBarFile);
    padFileExit := TRMmenuItem.Create(Self);
    with padFileExit do
    begin
      //ImageIndex := 20;
      //Images := ImageListStand;
      Caption := '&Exit';
      OnClick := btnExitClick;
      AddToMenu(FBarFile);
    end;

    FBarSearch := TRMSubmenuItem.Create(Self);
    with FBarSearch do
    begin
      Caption := RMLoadStr(rmRes + 254);
      GroupIndex := 20;
      AddToMenu(FMainMenu);
    end;
    padSearchFind := TRMMenuItem.Create(Self);
    with padSearchFind do
    begin
      Caption := RMLoadStr(rmRes + 255);
      //      ImageIndex := 0;
      //      Images := ImageListStand;
      ShortCut := Menus.ShortCut(Word('F'), [ssCtrl]);
      OnClick := padSearchFindClick;
      AddToMenu(FBarSearch);
    end;
    padSearchReplace := TRMMenuItem.Create(Self);
    with padSearchReplace do
    begin
      Caption := RMLoadStr(rmRes + 256);
      //      ImageIndex := 0;
      //      Images := ImageListStand;
      ShortCut := Menus.ShortCut(Word('R'), [ssCtrl]);
      OnClick := padSearchReplaceClick;
      AddToMenu(FBarSearch);
    end;
    padSearchFindAgain := TRMMenuItem.Create(Self);
    with padSearchFindAgain do
    begin
      Caption := RMLoadStr(rmRes + 257);
      //      ImageIndex := 0;
      //      Images := ImageListStand;
      ShortCut := Menus.TextToShortCut('F3');
      OnClick := padSearchFindAgainClick;
      AddToMenu(FBarSearch);
    end;

    FBarHelp := TRMSubmenuItem.Create(Self);
    with FBarHelp do
    begin
      Caption := '&Help';
      AddToMenu(FMainMenu);
      GroupIndex := 40;
    end;
    padHelp := TRMmenuItem.Create(Self);
    with padHelp do
    begin
      //ImageIndex := 26;
      //Images := ImageListStand;
      Caption := 'Help contents...';
      ShortCut := 112;
      OnClick := padHelpClick;
      AddToMenu(FBarHelp);
    end;
    N18 := TRMSeparatorMenuItem.Create(Self);
    N18.AddToMenu(FBarHelp);
    padAbout := TRMmenuItem.Create(Self);
    with padAbout do
    begin
      Caption := '&About...';
      OnClick := padAboutClick;
      AddToMenu(FBarHelp);
    end;
  end;

var
  lIni: TRegIniFile;
  lNm: string;
  i: Integer;
begin
  AutoScroll := False;
  FWorkSpaceColor := clWhite;
  FEditorForm := nil;
  FOldFactor := -1;
  FFactor := 100;
  FCurPage := -1;
  FBusy := True;
  FGridAlign := True;
  FShowGrid := True;
  FGridSize := 4;
  FEditAfterInsert := False;
  RM_Class.RMShowBandTitles := True;
  UseTableName := True;

  FOpenFiles := TStringList.Create;

  _CreateTabPanel;
  _CreateDock;
//  Dock971.BeginUpdate;
  _CreateMainMenu;
  FToolbarStandard := TRMToolbarStandard.CreateAndDock(Self, Dock971);
  FToolbarModifyPrepared := TRMToolbarModifyPrepared.CreateAndDock(Self, Dock971);
//  Dock971.EndUpdate;

  FToolBarModifyPrepared.Visible := IsPreviewDesign and ShowModifyToolbar;

  OnMouseWheelUp := OnFormMouseWheelUpEvent;
  OnMouseWheelDown := OnFormMouseWheelDownEvent;

  if FLanguageList <> nil then
  begin
    lIni := TRegIniFile.Create(RMRegRootKey + '\RMReport');
    try
      lNm := rsForm + Name;
      RM_CurLanguage := lIni.ReadString(lNm, rsLanguage, RM_CurLanguage);
      if (RM_CurLanguage <> '') then
      begin
        i := FLanguageNameList.IndexOf(RM_CurLanguage);
        if i >= 0 then
          RMResourceManager.LoadResourceModule(FLanguageList[i]);
      end;
    finally
      lIni.Free;
    end;
  end;

  Localize;
end;

procedure TRMDesignerForm.FormDestroy(Sender: TObject);
begin
  FBusy := True;
  FInspBusy := True;
  FCurPageEditor.Editor_BeforeFormDestroy;
  ClearUndoBuffer;
  ClearRedoBuffer;
  if FInspForm <> nil then
  begin
    FInspForm.RestorePos;
    SaveIni;
  end;

  FreeAndNil(FEditorForm);
  FreeAndNil(FFindReplaceForm);
  FreeAndNil(FInspForm);
  FreeAndNil(FFieldForm);
  FreeAndNil(FOpenFiles);
  FreeAndNil(FCurPageEditor);
end;

procedure TRMDesignerForm.FormShow(Sender: TObject);

  procedure _RestoreOpenFiles;
  var
    Ini: TRegIniFile;
    i: Integer;
    str: string;
    Nm: string;
  begin
    Ini := TRegIniFile.Create(RMRegRootKey + '\RMReport');
    Nm := rsForm + Name;
    AutoOpenLastFile := Ini.ReadBool(Nm, rsAutoOpenLastFile, False);
    try
      if not IsPreviewDesign then
      begin
        for i := 1 to 9 do
        begin
          str := Ini.ReadString(rsOpenFiles, 'File' + IntToStr(i), '');
          if str = '' then
            Break;
          FOpenFiles.Add(str);
        end;
      end;
      SetOpenFileMenuItems('');
    finally
      Ini.Free;
    end;
  end;

begin
  Self.OnKeyDown := FormKeyDown;
  Factor := 100;
  Tab1.Tabs.Clear;
  if not IsPreviewDesign then
    Tab1.AddTab(RMLoadStr(rmRes + 253));

  Screen.Cursors[crPencil] := LoadCursor(hInstance, 'RM_PENCIL');
  FInspBusy := True;
  FInspForm := TRMInspForm.Create(Self);
  with FInspForm do
  begin
    SetCurReport(Report);
{$IFNDEF USE_TB2K}
    Parent := Self;
{$ENDIF}
    Insp.OnAfterModify := Self.OnInspAfterModify;
    Insp.OnBeforeModify := Self.OnInspBeforeModify;
    OnSelectionChanged := Self.InspSelectionChanged;
    OnGetObjects := Self.InspGetObjects;
  end;

  FFieldForm := TRMInsFieldsForm.Create(Self);
  with FFieldForm do
  begin
{$IFNDEF USE_TB2K}
    Parent := Self;
{$ENDIF}
    OnCloseEvent := OnFieldsDialogCloseEvnet;
  end;

  ClearUndoBuffer;
  ClearRedoBuffer;
  Report.DocMode := rmdmDesigning;
  if RMIsChineseGB then
    RM_LastFontName := '宋体'
  else
    RM_LastFontName := 'Arial';

  RM_LastFontSize := 10;
  _RestoreOpenFiles;
  if (Report.Pages.Count = 0) and AutoOpenLastFile and (FOpenFiles.Count > 0) then
    Report.LoadFromFile(FOpenFiles[0]);
  if Report.Pages.Count = 0 then
  begin
    Report.NewReport;
    CreateDefaultPage;
  end;

  LoadIni;
  CurPage := 0; // this cause page sizing
  CurDocName := Report.FileName;

  EditorScriptText :=  Report.Script.Text;

  Modified := False;
  FInspBusy := False;
  FBusy := False;
  ShowPosition;
  FormResize(nil);

  padPreview.Enabled := ToolbarStandard.btnPreview.Enabled;
  padPrint.Enabled := ToolbarStandard.btnPreview.Enabled;
  ToolbarStandard.btnPrint.Enabled := ToolbarStandard.btnPreview.Enabled;

  SetObjectsID;
  if (RMDesignerComp <> nil) and Assigned(RMDesignerComp.OnShow) then
    RMDesignerComp.OnShow(Self);

  if FFieldForm.Visible then
    FFieldForm.RefreshData;
end;

procedure TRMDesignerForm.FormResize(Sender: TObject);
begin
  if FBusy or (csDestroying in ComponentState) then Exit;

  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_Resize;
end;

procedure TRMDesignerForm.SetCurPage(Value: Integer);
var
  t: TRMView;
  lstr: string;

  procedure _CreatePageEditor;
  var
    i: Integer;
    lPageEditorClass: TClass;
  begin
    lPageEditorClass := nil;
    for i := 0 to RMPageEditorCount - 1 do
    begin
      if RMPageEditor(i).PageClass = Page.ClassType then
      begin
        lPageEditorClass := RMPageEditor(i).PageEditorClass;
        Break;
      end;
    end;

    if lPageEditorClass = nil then
    begin
      lPageEditorClass := TRMDefaultPageEditor;
    end;

    if (FCurPageEditor <> nil) and (FCurPageEditor.ClassType <> lPageEditorClass) then
    begin
      FreeAndNil(FCurPageEditor);
    end;

    if (lPageEditorClass <> nil) and (FCurPageEditor = nil) then
    begin
      FCurPageEditor := TRMCustomPageEditor(lPageEditorClass.NewInstance);
      FCurPageEditor.CreateComp(Tab1, Self);
    end;

    if FCurPageEditor <> nil then
    begin
      FCurPageEditor.Editor_Init;
      FCurPageEditor.Editor_SetCurPage;
      if RMCmp(FCurPageEditor.ClassName, 'TRMDefaultPageEditor') then
      begin
        TRMDefaultPageEditor(FCurPageEditor).FPanel.Caption := 'Need [' + Page.ClassName + '] Designer!!!';
        EnableControls;
      end;
    end;
  end;

begin
//  Dock971.BeginUpdate;
//  Dock972.BeginUpdate;
//  Dock973.BeginUpdate;
//  Dock974.BeginUpdate;
  FMainMenu.BeginUpdate;
  Self.DisableAlign;
  try
    if FCurPageEditor <> nil then
      FCurPageEditor.Editor_DisableDraw;

    FCodeMemo.Visible := False;
    FCurPage := Value;
    Page := Report.Pages[CurPage];
    lstr := Page.ClassName;
    if Page.Name = '' then Page.CreateName(False);

    Report.CurrentPage := Page;
    if Page is TRMReportPage then
    begin
      t := IsSubreport(CurPage);
      if t <> nil then
      begin
        case TRMSubReportView(t).SubReportType of
          rmstFixed:
            begin
              TRMReportPage(Page).spMarginLeft := 0;
              TRMReportPage(Page).spMarginTop := 0;
              TRMReportPage(Page).spMarginRight := 0;
              TRMReportPage(Page).spMarginBottom := 0;
              TRMReportPage(Page).PrinterInfo.ScreenPageWidth := t.spWidth;
              TRMReportPage(Page).PrinterInfo.ScreenPageHeight := t.spHeight;
            end;
          rmstChild, rmstStretcheable:
            begin
              TRMReportPage(Page).spMarginLeft := TRMReportPage(t.ParentPage).spMarginLeft;
              TRMReportPage(Page).spMarginTop := TRMReportPage(t.ParentPage).spMarginTop;
              TRMReportPage(Page).spMarginRight := TRMReportPage(t.ParentPage).spMarginRight;
              TRMReportPage(Page).spMarginBottom := TRMReportPage(t.ParentPage).spMarginBottom;
              TRMReportPage(Page).PrinterInfo := TRMReportPage(t.ParentPage).PrinterInfo;
            end;
        end;
      end;
    end;

    ToolbarStandard.cmbScale.Enabled := (Page is TRMReportPage);

    SetPageTabs;
    Tab1.TabIndex := FCurPage + 1;
    _CreatePageEditor;
  finally
    FMainMenu.EndUpdate;
    Self.EnableAlign;
//    Dock971.EndUpdate;
//    Dock972.EndUpdate;
//    Dock973.EndUpdate;
//    Dock974.EndUpdate;
  end;
end;

procedure TRMDesignerForm.BeforeChange;
begin
  AddUndoAction(rmacEdit);
  Modified := True;
end;

procedure TRMDesignerForm.AfterChange;
begin
  FCurPageEditor.Editor_AfterChange;
  FCurPageEditor.Editor_SelectionChanged(True);
end;

function TRMDesignerForm.InsertDBField(t: TRMView): string;
var
  tmp: TRMFieldsForm;
  lBand: TRMView;
begin
  Result := '';
  if t is TRMReportView then
  begin
    lBand := GetParentBand(TRMReportView(t));
    if (lBand is TRMBandMasterData) and (not TRMBandMasterData(lBand).IsVirtualDataSet) then
      RM_Dsg_LastDataSet := TRMBandMasterData(lBand).DataSetName;
  end;

  tmp := TRMFieldsForm.Create(nil);
  try
    tmp.chkUseTableName.Checked := UseTableName;
    if tmp.ShowModal = mrOk then
    begin
      if tmp.SelectedField <> '' then
      begin
        DBFieldOnly := tmp.DBFieldOnly;
        Result := '[' + tmp.SelectedField + ']';
      end;
      UseTableName := tmp.chkUseTableName.Checked;
    end;
  finally
    tmp.Free;
  end;
end;

function TRMDesignerForm.InsertExpression(t: TRMView): string;
var
  str: string;
  lBand: TRMView;
begin
  Result := '';
  if t is TRMReportView then
  begin
    lBand := GetParentBand(TRMReportView(t));
    if (lBand is TRMBandMasterData) and (not TRMBandMasterData(lBand).IsVirtualDataSet) then
      RM_Dsg_LastDataSet := TRMBandMasterData(lBand).DataSetName;
  end;

  if RM_EditorExpr.RMGetExpression('', str, nil, False) then
  begin
    Result := str;
    if Result <> '' then
    begin
      if not ((Result[1] = '[') and (Result[Length(Result)] = ']') and
        (Pos('[', Copy(Result, 2, 999999)) = 0)) then
      begin
        DBFieldOnly := False;
        Result := '[' + Result + ']';
      end;
    end;
  end;
end;

function TRMDesignerForm.EditorForm: TForm;
begin
  if FEditorForm = nil then
    FEditorForm := TRMEditorForm.Create(Application);

  Result := FEditorForm;
end;

function TRMDesignerForm.GetParentBand(t: TRMReportView): TRMReportView;
var
  i: Integer;
  t1: TRMView;
begin
  Result := nil;
  for i := 0 to Page.Objects.Count - 1 do
  begin
    t1 := Page.Objects[i];
    if t1.IsBand then
    begin
      if (t.spTop_Designer >= t1.spTop_Designer) and
        (t.spBottom_Designer <= t1.spBottom_Designer) then
      begin
        Result := TRMCustomBandView(t1);
        Break;
      end;
    end;
  end;
end;

procedure TRMDesignerForm.RMMemoViewEditor(t: TRMView);
begin
  if t = nil then
    t := PageObjects[TopSelected];

  if TRMEditorForm(EditorForm).ShowEditor(t) = mrOk then
  begin
  end;
end;

procedure TRMDesignerForm.RMPictureViewEditor(t: TRMView);
var
  tmp: TRMPictureEditorForm;
begin
  tmp := TRMPictureEditorForm.Create(nil);
  try
    if tmp.ShowEditor(t) = mrOK then
    begin
      BeforeChange;
      AfterChange;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMDesignerForm.RMFontEditor(Sender: TObject);
var
  t: TRMView;
  i: Integer;
  lFontDialog: TFontDialog;
  lList: TList;
begin
  lList := PageObjects;
  t := lList[TopSelected];
  if not (t is TRMCustomMemoView) then Exit;

  lFontDialog := TFontDialog.Create(nil);
  try
    lFontDialog.Font.Assign(TRMCustomMemoView(t).Font);
    if lFontDialog.Execute then
    begin
      RMDesigner.BeforeChange;
      for i := 0 to lList.Count - 1 do
      begin
        t := lList[i];
        if t.Selected and (t is TRMCustomMemoView) then
          TRMCustomMemoView(t).Font.Assign(lFontDialog.Font);
      end;

      RMDesigner.AfterChange;
    end;
  finally
    lFontDialog.Free;
  end;
end;

procedure TRMDesignerForm.RMDisplayFormatEditor(Sender: TObject);
var
  t: TRMView;
  tmp: TRMDisplayFormatForm;
begin
  t := PageObjects[TopSelected];
  if not (t is TRMCustomMemoView) then Exit;

  tmp := TRMDisplayFormatForm.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;
end;

procedure TRMDesignerForm.RMCalcMemoEditor(Sender: TObject);
var
  tmp: TRMCalcMemoEditorForm;
begin
  tmp := TRMCalcMemoEditorForm.Create(nil);
  try
    tmp.ShowEditor(PageObjects[TopSelected]);
  finally
    tmp.Free;
  end;
end;

procedure TRMDesignerForm.RedrawPage;
begin
  if (Tab1 <> nil) and (Tab1.TabIndex <> 0) then
    FCurPageEditor.Editor_RedrawPage;
end;

procedure TRMDesignerForm.ShowPosition;
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_ShowPosition;
end;

procedure TRMDesignerForm.ResetSelection;
begin
  UnSelectAll;
  SelNum := 0;
  EnableControls;
  ShowPosition;
end;

procedure TRMDesignerForm.SetControlsEnabled(const Ar: array of TObject; aEnabled: Boolean);
var
  i: Integer;
begin
  for i := Low(Ar) to High(Ar) do
  begin
    if Ar[i] is TRMToolbarButton then
      TRMToolbarButton(Ar[i]).Enabled := aEnabled
    else if Ar[i] is TControl then
      TControl(Ar[i]).Enabled := aEnabled
    else if Ar[i] is TRMMenuItem then
      TRMMenuItem(Ar[i]).Enabled := aEnabled
    else if Ar[i] is TMenuItem then
      TMenuItem(Ar[i]).Enabled := aEnabled;
  end;
end;

procedure TRMDesignerForm.EnableControls;
begin
  SetControlsEnabled([barSearch, padSearchFind, padSearchReplace, padSearchFindAgain], Tab1.TabIndex = 0);
  with ToolbarStandard do
    SetControlsEnabled([],
      (not IsPreviewDesign) and (DesignerRestrictions * [rmdrDontCreatePage] = []));

  MenuFileHeaderFooter.Enabled := False;
  ToolbarStandard.btnPreview1.Enabled := False;

  SetControlsEnabled([ToolbarStandard.btnDeletePage],
    (not IsPreviewDesign) and (Tab1.TabIndex > 0) and (DesignerRestrictions * [rmdrDontDeletePage] = []));
  SetControlsEnabled([padFileOpen, ToolbarStandard.btnFileOpen], (not IsPreviewDesign) and (not IsPreviewDesignReport));
  SetControlsEnabled([ToolbarStandard.btnFileNew, padFileNew], (not IsPreviewDesign) and (not IsPreviewDesignReport));
  SetControlsEnabled([ToolbarStandard.btnPrint, ToolbarStandard.btnPreview, padPrint, padPreview],
    ((not IsPreviewDesign) and (not IsPreviewDesignReport)) and (DesignerRestrictions * [rmdrDontPreviewReport] = []));
  SetControlsEnabled([ToolbarStandard.btnFileSave, padFileSave],
    ((not IsPreviewDesign) and (not IsPreviewDesignReport) and Modified) and (DesignerRestrictions * [rmdrDontSaveReport] = []));
  SetControlsEnabled([padFileSaveAs], (not IsPreviewDesign) and (not IsPreviewDesignReport) and (DesignerRestrictions * [rmdrDontSaveReport] = []));
  SetControlsEnabled([padVarList, LoadDictionary1, MergeDictionary1, SaveAsDictionary1],
    (not IsPreviewDesign) and (DesignerRestrictions * [rmdrDontEditVariables] = []));
  SetControlsEnabled([padPageSetup, ToolbarStandard.btnPageSetup],
    ((not IsPreviewDesign) and (Tab1.TabIndex > 0)) and (DesignerRestrictions * [rmdrDontChangeReportOptions] = []));
  SetControlsEnabled([ToolbarStandard.btnPrint, padPrint], padPrint.Enabled and (RMPrinters.Count >= 2));

  with ToolbarStandard do
    SetControlsEnabled(ToolbarStandard.FAryButton,
      (not IsPreviewDesign) and (Tab1.TabIndex > 0) and (DesignerRestrictions * [rmdrDontCreatePage] = []));
  SetControlsEnabled([ToolbarStandard.btnDeletePage],
    (not IsPreviewDesign) and (Tab1.TabIndex > 0) and (DesignerRestrictions * [rmdrDontDeletePage] = []));

  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_EnableControls;
end;

procedure TRMDesignerForm.OpenFile(aFileName: string);
var
  w: Integer;
  lOpened: Boolean;
begin
  if DesignerRestrictions * [rmdrDontLoadReport] <> [] then Exit;

  if Modified then
  begin
    w := Application.MessageBox(PChar(RMLoadStr(SSaveChanges) + ' ' + RMLoadStr(STo) + ' ' +
      ExtractFileName(FCurDocName) + '?'), PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);
    if w = mrCancel then Exit;
    if (w = mrYes) and (not FileSave) then Exit;
  end;

  FCurPageEditor.Editor_DisableDraw;
  FInspBusy := True;
  lOpened := False;
  if (not (csDesigning in Report.ComponentState)) and (RMDesignerComp <> nil) and
    Assigned(RMDesignerComp.OnLoadReport) then // 自定义打开
  begin
    RMDesignerComp.OnLoadReport(Report, aFileName, lOpened);
  end;

  if not lOpened then
  begin
    if aFileName = '' then
    begin
      OpenDialog1.FileName := '';
      OpenDialog1.Filter := RMLoadStr(SFormFile) + '|*.rmf;*.rls';
      if (RMDesignerComp <> nil) and (RMDesignerComp.OpenDir <> '') then
        OpenDialog1.InitialDir := RMDesignerComp.OpenDir;

      if OpenDialog1.Execute then
      begin
        aFileName := OpenDialog1.FileName;
        if ExtractFileExt(aFileName) = '' then
          aFileName := aFileName + '.rmf';
        if FileExists(aFileName) then
          lOpened := Report.LoadFromFile(aFileName);
      end;
    end
    else
      lOpened := Report.LoadFromFile(aFileName);
  end;

  FInspBusy := False;
  if lOpened then
  begin
    if Report.Pages.Count <= 0 then
      CreateDefaultPage;

    CurDocName := aFileName;
    Report.ComponentModified := True;
    FCurPage := -1;
    CurPage := 0; // do all
    SetOpenFileMenuItems(aFileName);
    SetObjectsID;
    EditorScriptText :=  Report.Script.Text;
    ClearUndoBuffer;
    ClearRedoBuffer;
    if FFieldForm.Visible then
      FFieldForm.RefreshData;

    Modified := False;
  end
  else
  begin
    CurPage := CurPage;
  end;
end;

procedure TRMDesignerForm.itmFileFile9Click(Sender: TObject);
begin
  if FileExists(FOpenFiles[TComponent(Sender).Tag - 1]) then
    OpenFile(FOpenFiles[TComponent(Sender).Tag - 1]);
end;

procedure TRMDesignerForm.btnFileOpenClick(Sender: TObject);
begin
  OpenFile('');
end;

procedure TRMDesignerForm.BtnFileNewClick(Sender: TObject);
var
  w: Word;
begin
  if DesignerRestrictions * [rmdrDontCreateReport] <> [] then Exit;

  if Modified then
  begin
    w := Application.MessageBox(PChar(RMLoadStr(SSaveChanges) + ' ' + RMLoadStr(STo) + ' ' +
      ExtractFileName(FCurDocName) + '?'),
      PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);
    if w = mrCancel then Exit;
    if w = mrYes then
    begin
      if not FileSave then Exit;
    end;
  end;

  FCurPageEditor.Editor_DisableDraw;
  Report.NewReport;
  if (RMDesignerComp <> nil) and (RMDesignerComp.DefaultDictionaryFile <> '') and
    FileExists(RMDesignerComp.DefaultDictionaryFile) then
    Report.Dictionary.LoadFromFile(RMDesignerComp.DefaultDictionaryFile);

  CreateDefaultPage;
  FCurPage := -1;
  CurPage := 0;
  CurDocName := RMLoadStr(SUntitled);
  EditorScriptText :=  Report.Script.Text;
  SetObjectsID;
  ClearUndoBuffer;
  ClearRedoBuffer;
  if FFieldForm.Visible then
    FFieldForm.RefreshData;

  Modified := False;
  Report.ComponentModified := True;
end;

function TRMDesignerForm.FileSaveAs: Boolean;
var
  lSaved: Boolean;
  lFileName: string;
  tmp: TRMTemplNewForm;
  lStrList: TWideStringList;
begin
  Result := False;
  if not FCodeMemo.ReadOnly then
  begin
    Report.Script.Text := EditorScriptText;
  end;

  if (not (csDesigning in Report.ComponentState)) and (RMDesignerComp <> nil) and
    Assigned(RMDesignerComp.OnSaveReport) then // 自定义保存
  begin
    lFileName := CurDocName;
    lSaved := True;
    RMDesignerComp.OnSaveReport(Report, lFileName, True, lSaved);
    if lSaved then
    begin
      Modified := False;
      CurDocName := lFileName;
      ClearUndoBuffer;
      ClearRedoBuffer;
      Exit;
    end;
  end;

  SaveDialog1.Filter := RMLoadStr(SFormFile) + ' (*.rmf)|*.rmf|';
  SaveDialog1.DefaultExt := '*.rmf';
  SaveDialog1.FileName := FCurDocName;
  if SaveDialog1.Execute then
  begin
    if SaveDialog1.FilterIndex = 1 then
    begin
      lFileName := ChangeFileExt(SaveDialog1.FileName, '.rmf');
      Report.SaveToFile(lFileName);
      Result := True;
      CurDocName := lFileName;
      SetOpenFileMenuItems(lFileName);
    end
    else
    begin
      lFileName := ChangeFileExt(SaveDialog1.FileName, '.rmt');
      if RMDesignerComp <> nil then
        RMTemplateDir := RMDesignerComp.TemplateDir;
      if RMTemplateDir <> '' then
        lFileName := RMTemplateDir + '\' + ExtractFileName(lFileName);

      tmp := TRMTemplNewForm.Create(nil);
      lStrList := TWideStringList.Create;
      try
        if tmp.ShowModal = mrOK then
        begin
          lStrList.Assign(tmp.Memo1.Lines);
          Report.SaveTemplate(lFileName, lStrList, tmp.Image1.Picture.Bitmap);
          Result := True;
        end;
      finally
        tmp.Free;
        lStrList.Free;
      end;
    end;
  end;

  if Result then
  begin
    Modified := False;
    ClearUndoBuffer;
    ClearRedoBuffer;
  end;
end;

procedure TRMDesignerForm.padFileSaveAsClick(Sender: TObject);
begin
  FileSaveAs;
end;

procedure TRMDesignerForm.btnPreviewClick(Sender: TObject);
var
  lSaveModalPreview: Boolean;
  lSaveVisible: Boolean;
  lSaveModified: Boolean;
begin
  if DesignerRestrictions * [rmdrDontPreviewReport] <> [] then Exit;

  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_DisableDraw;

  lSaveModalPreview := Report.ModalPreview;
  lSaveVisible := FInspForm.Visible;
  Application.ProcessMessages;
  Report.ModalPreview := True;
  UnSelectAll;
  RedrawPage;
  Page := nil;
  FBusy := True;
  FInspBusy := True;
  lSaveModified := Modified;
  THackReport(Report).FDesigning := False;
  try
    if not FCodeMemo.ReadOnly then
      Report.Script.Assign(FCodeMemo.CreateStringList);

    FInspForm.Hide;
    Report.Preview := nil;
    Report.ShowReport;
  finally
    THackReport(Report).FDesigning := True;
    THackReport(Report).Flag_PrintBackGroundPicture := False;
    Report.ModalPreview := lSaveModalPreview;
    FInspBusy := False;
    FBusy := False;
    FInspForm.Visible := lSaveVisible;
    Modified := lSaveModified;
    CurPage := CurPage;
    FCurPageEditor.Editor_SelectionChanged(True);
    Screen.Cursor := crDefault;
  end;
end;

procedure TRMDesignerForm.padPrintClick(Sender: TObject);
var
  lSaveVisible: Boolean;
begin
  if RMPrinters.Count < 2 then Exit;

  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_DisableDraw;

  lSaveVisible := FInspForm.Visible;
  Application.ProcessMessages;
  UnSelectAll;
  RedrawPage;
  Page := nil;
  FBusy := True;
  FInspBusy := True;
  THackReport(Report).FDesigning := False;
  try
    if not FCodeMemo.ReadOnly then
      Report.Script.Assign(FCodeMemo.CreateStringList);

    FInspForm.Hide;
    Report.PrintReport;
  finally
    THackReport(Report).FDesigning := True;
    THackReport(Report).Flag_PrintBackGroundPicture := False;
    FInspBusy := False;
    FBusy := False;
    FInspForm.Visible := lSaveVisible;
    CurPage := CurPage;
    FCurPageEditor.Editor_SelectionChanged(True);
    Screen.Cursor := crDefault;
  end;
end;

procedure TRMDesignerForm.btnCutClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnCutClick(Sender);
end;

procedure TRMDesignerForm.btnCopyClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnCopyClick(Sender);
end;

procedure TRMDesignerForm.btnPasteClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnPasteClick(Sender);
end;

function TRMDesignerForm.PageSetup(aRepaint: Boolean): Boolean;
var
  tmpForm: TRMPageSetupForm;
  lOldIndex: Integer;

  procedure _ChangeSubReportPaper;
  var
    i: Integer;
    t: TRMView;
    lPage: TRMReportPage;
  begin
    for i := 0 to THackPage(Page).Objects.Count - 1 do
    begin
      t := THackPage(Page).Objects[i];
      if t.ObjectType = rmgtSubReport then
      begin
        lPage := TRMReportPage(Report.Pages[TRMSubReportView(t).SubPage]);
        with TRMReportPage(Page) do
        begin
          lPage.ChangePaper(PageSize, PrinterInfo.ScreenPageWidth, PrinterInfo.ScreenPageHeight, PageBin, PageOrientation);
          lPage.mmMarginLeft := mmMarginLeft;
          lPage.mmMarginTop := mmMarginTop;
          lPage.mmMarginRight := mmMarginRight;
          lPage.mmMarginBottom := mmMarginBottom;
        end;
      end;
    end;
  end;

begin
  Result := False;
  if (not (Page is TRMReportPage)) or (IsSubReport(CurPage) <> nil) then Exit;

  FCurPageEditor.Editor_InitToolbarComponent;
  lOldIndex := Report.ReportPrinter.PrinterIndex;
  tmpForm := TRMPageSetupForm.Create(nil);
  try
    tmpForm.CurPrinter := Report.ReportPrinter;
    with TRMReportPage(Page) do
    begin
      tmpForm.PageSetting.PrinterName := Report.PrinterName;
      tmpForm.PageSetting.Title := Report.ReportInfo.Title;
      tmpForm.PageSetting.DoublePass := Report.DoublePass;
      tmpForm.PageSetting.PrintbackgroundPicture := Report.PrintbackgroundPicture;
      tmpForm.PageSetting.ColorPrint := Report.ColorPrint;
      tmpForm.PageSetting.NewPageAfterPrint := Report.AutoSetPageLength;
      tmpForm.PageSetting.PrintToPrevPage := PrintToPrevPage;
      tmpForm.PageSetting.UnlimitedHeight := FUnlimitedHeight;
      tmpForm.PageSetting.MarginLeft := mmMarginLeft / 1000;
      tmpForm.PageSetting.MarginTop := mmMarginTop / 1000;
      tmpForm.PageSetting.MarginRight := mmMarginRight / 1000;
      tmpForm.PageSetting.MarginBottom := mmMarginBottom / 1000;
      tmpForm.PageSetting.PageOr := PageOrientation;
      tmpForm.PageSetting.PageWidth := PageWidth;
      tmpForm.PageSetting.PageHeight := PageHeight;
      tmpForm.PageSetting.PageBin := PageBin;
      tmpForm.PageSetting.PageSize := PageSize;
      tmpForm.PageSetting.ColGap := mmColumnGap / 1000;
      tmpForm.PageSetting.ColCount := ColumnCount;
      tmpForm.PageSetting.ConvertNulls := Report.ConvertNulls;
      tmpForm.chkPageMode.Checked := (Report.PageCompositeMode = rmPagePerPage);
      if tmpForm.Execute then
      begin
        if lOldIndex <> tmpForm.cmbPrinterNames.ItemIndex then
        begin
          Report.ChangePrinter(Report.ReportPrinter.PrinterIndex, tmpForm.cmbPrinterNames.ItemIndex);
        end;

        mmColumnGap := Round(tmpForm.PageSetting.ColGap * 1000);
        ColumnCount := tmpForm.PageSetting.ColCount;
        mmMarginLeft := Round(tmpForm.PageSetting.MarginLeft * 1000);
        mmMarginTop := Round(tmpForm.PageSetting.MarginTop * 1000);
        mmMarginRight := Round(tmpForm.PageSetting.MarginRight * 1000);
        mmMarginBottom := Round(tmpForm.PageSetting.MarginBottom * 1000);

        Report.ReportInfo.Title := tmpForm.PageSetting.Title;
        Report.DoublePass := tmpForm.PageSetting.DoublePass;
        Report.PrintbackgroundPicture := tmpForm.PageSetting.PrintbackgroundPicture;
        Report.ColorPrint := tmpForm.PageSetting.ColorPrint;
        Report.AutoSetPageLength := tmpForm.PageSetting.NewPageAfterPrint;
        PrintToPrevPage := tmpForm.PageSetting.PrintToPrevPage;
        FUnlimitedHeight := tmpForm.PageSetting.UnlimitedHeight;
        Report.ConvertNulls := tmpForm.PageSetting.ConvertNulls;
        if tmpForm.chkPageMode.Checked then
          Report.PageCompositeMode := rmPagePerPage
        else
          Report.PageCompositeMode := rmReportPerReport;

        ChangePaper(tmpForm.PageSetting.PageSize, tmpForm.PageSetting.PageWidth,
          tmpForm.PageSetting.PageHeight, tmpForm.PageSetting.PageBin, tmpForm.PageSetting.PageOr);

        Modified := True;
        if aRepaint then
          CurPage := CurPage; // for repaint and other

        _ChangeSubReportPaper;
        Result := True;
      end;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMDesignerForm.btnAddPageClick(Sender: TObject);
begin
  if DesignerRestrictions * [rmdrDontCreatePage] <> [] then Exit;

  ResetSelection;
  Report.Pages.AddReportPage(RMDsgPageButton(TRMToolbarButton(Sender).Tag).PageClassName);
  Page := Report.Pages[Report.Pages.Count - 1];
  Page.CreateName(False);
  if PageSetup(False) then
  begin
    Modified := True;
    CurPage := Report.Pages.Count - 1;
  end
  else
  begin
    Report.Pages.Delete(Report.Pages.Count - 1);
    CurPage := CurPage;
  end;
end;

procedure TRMDesignerForm.btnAddFormClick(Sender: TObject);
begin
  if DesignerRestrictions * [rmdrDontCreatePage] <> [] then Exit;

  Page := Report.Pages.AddDialogPage;
  Page.CreateName(False);
  Modified := True;
  CurPage := Report.Pages.Count - 1;
end;

procedure TRMDesignerForm.btnDeletePageClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnDeletePageClick(Sender);
end;

procedure TRMDesignerForm.OnFieldsDialogCloseEvnet(Sender: TObject);
begin
  EnableControls;
end;

procedure TRMDesignerForm.SetPageTabs;
var
  i: Integer;
begin
  Tab1.Tabs.BeginUpdate;
  if Tab1.Tabs.Count - 1 = Report.Pages.Count then
  begin
    for i := 0 to Report.Pages.Count - 1 do
      Tab1.TabsCaption[i + 1] := Report.Pages[i].Name;
  end
  else
  begin
    Tab1.Tabs.Clear;
    Tab1.AddTab(RMLoadStr(rmRes + 253));
    for i := 0 to Report.Pages.Count - 1 do
    begin
      Tab1.AddTab(Report.Pages[i].Name);
    end;
  end;
  Tab1.Tabs.EndUpdate;
end;

procedure TRMDesignerForm.btnPageSetupClick(Sender: TObject);
begin
  if DesignerRestrictions * [rmdrDontEditPage] <> [] then Exit;

  PageSetup(True);
end;

function TRMDesignerForm.FileSave: Boolean;
var
  lSaved: Boolean;
  lFileName: string;
begin
  Result := False;
  if DesignerRestrictions * [rmdrDontSaveReport] <> [] then Exit;

  if not FCodeMemo.ReadOnly then
    Report.Script.Assign(FCodeMemo.CreateStringList);

  UseDefaultSave := True;
  if (not (csDesigning in Report.ComponentState)) and (RMDesignerComp <> nil) and
    Assigned(RMDesignerComp.OnSaveReport) then // 自定义保存
  begin
    lFileName := CurDocName; lSaved := True;
    RMDesignerComp.OnSaveReport(Report, lFileName, False, lSaved);
    if lSaved then
    begin
      Modified := False;
      CurDocName := lFileName;
      Result := True;
    end;
  end;

  if (not Result) and UseDefaultSave then
  begin
    if AnsiCompareText(FCurDocName, RMLoadStr(SUntitled)) <> 0 then
    begin
      Report.SaveToFile(FCurDocName);
      Modified := False;
      SetOpenFileMenuItems(FCurDocName);
      Result := True;
    end
    else
      Result := FileSaveAs;
  end;

  if Result then
  begin
    ClearUndoBuffer;
    ClearRedoBuffer;
  end;
end;

procedure TRMDesignerForm.btnFileSaveClick(Sender: TObject);
begin
  FileSave;
end;

procedure TRMDesignerForm.btnExitClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
    ModalResult := mrOk
  else
    Close;
end;

procedure TRMDesignerForm.btnUndoClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnUndoClick(Sender);
end;

procedure TRMDesignerForm.btnRedoClick(Sender: TObject);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_BtnRedoClick(Sender);
end;

procedure TRMDesignerForm.padAboutClick(Sender: TObject);
begin
  if (RMDesignerComp <> nil) and Assigned(RMDesignerComp.OnShowAboutForm) then
    RMDesignerComp.OnShowAboutForm(nil)
  else
    TRMFormAbout.Create(Application).ShowModal;
end;

procedure TRMDesignerForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_KeyDown(Sender, Key, Shift);
end;

procedure TRMDesignerForm.OnFormMouseWheelUpEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_OnFormMouseWheelUp(True);
end;

procedure TRMDesignerForm.OnFormMouseWheelDownEvent(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if FCurPageEditor <> nil then
    FCurPageEditor.Editor_OnFormMouseWheelUp(False);
end;

procedure TRMDesignerForm.padFilePropertyClick(Sender: TObject);
var
  tmp: TRMReportProperty;
begin
  tmp := TRMReportProperty.Create(nil);
  try
    tmp.ReportInfo := Report.ReportInfo;
    if tmp.ShowModal = mrOK then
    begin
      Report.ReportInfo := tmp.ReportInfo;
      Modified := True;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMDesignerForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  w: Integer;
begin
  if ((csDesigning in Report.ComponentState) and Report.StoreInDFM) or
    (not Modified) then
    CanClose := True
  else
  begin
    if not FCodeMemo.ReadOnly then
      Report.Script.Assign(FCodeMemo.CreateStringList);
    if (not IsPreviewDesign) and (not IsPreviewDesignReport) then
      w := Application.MessageBox(PChar(RMLoadStr(SSaveChanges) + ' ' + RMLoadStr(STo) + ' ' +
        ExtractFileName(CurDocName) + '?'), PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel)
    else if FToolbarModifyPrepared.btnAutoSave.Down then
      w := mrYes
    else
      w := Application.MessageBox(PChar(RMLoadStr(SSaveChanges) + '?'),
        PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);

    CanClose := False;
    case w of
      mrYes:
        begin
          if not IsPreviewDesign then
          begin
            if IsPreviewDesignReport then
            begin
              RMDesigner.Modified := False;
              Report.Modified := True;
              CanClose := True;
              ModalResult := mrOK;
            end
            else
            begin
              CanClose := FileSave;
              if CanClose then
              begin
                Modified := True;
                ModalResult := mrOK;
              end;
            end;
          end
          else // 预览时编辑
          begin
            Report.EndPages[EndPageNo].ObjectsToStream(Report);
            Report.CanRebuild := False;
            RMDesigner.Modified := False;
            Report.Modified := True;
            CanClose := True;
            ModalResult := mrOK;
          end;
        end;
      mrNo:
        begin
          CanClose := True;
          ModalResult := mrCancel;
        end;
    end;
  end;
end;

procedure TRMDesignerForm.padFileNewClick(Sender: TObject);
var
  tmpWizard: TRMCustomReportWizard;
  tmp: TRMTemplForm;
  lStream: TMemoryStream;
  lNewReportFlag: Boolean;
begin
  if (RMDesignerComp <> nil) and
    (RMDesignerComp.DesignerRestrictions * [rmdrDontCreateReport] <> []) then Exit;

  if RMDesignerComp <> nil then
    RMTemplateDir := RMDesignerComp.TemplateDir;

  lNewReportFlag := False;
  tmp := TRMTemplForm.Create(nil);
  try
    tmp.CurrentReport := Report;
    tmp.FileExt := '*.rmt';
    if tmp.ShowModal = mrOk then
    begin
      ClearUndoBuffer;
      ClearRedoBuffer;
      FCurPageEditor.Editor_DisableDraw;
      if tmp.atype = 1 then
      begin
        if Length(tmp.TemplName) > 0 then
        begin
          Report.LoadTemplate(tmp.TemplName, nil, nil);
          lNewReportFlag := True;
        end
        else
          ToolbarStandard.BtnFileNew.Click;
      end
      else
      begin
        tmpWizard := tmp.WizardClass.Create;
        lStream := TMemoryStream.Create;
        try
          if tmpWizard.DoCreateReport then
          begin
            tmpWizard.GetReportStream(lStream);

            lStream.Position := 0;
            Report.LoadFromStream(lStream);
            lNewReportFlag := True;
          end;
        finally
          tmpWizard.Free;
          lStream.Free;
        end;
      end;
    end;
  finally
    tmp.Free;
  end;

  if lNewReportFlag then
  begin
    if Report.Pages.Count < 1 then
      CreateDefaultPage;

    FCurPage := -1;
    CurPage := 0;
    CurDocName := RMLoadStr(SUntitled);
    Modified := False;
    Report.ComponentModified := True;
    EditorScriptText :=  Report.Script.Text;
    SetObjectsID;
    ClearUndoBuffer;
    ClearRedoBuffer;
    if FFieldForm.Visible then
      FFieldForm.RefreshData;
  end;
end;

procedure TRMDesignerForm.padVarListClick(Sender: TObject);
var
  tmp: TRMDictionaryForm;
begin
  if (RMDesignerComp <> nil) and
    (RMDesignerComp.DesignerRestrictions * [RMdrDontEditVariables] <> []) then Exit;

  tmp := TRMDictionaryForm.Create(nil);
  try
    tmp.CurReport := Report;
    if tmp.ShowModal = mrOk then
    begin
      Modified := True;
      AfterChange;
      if FFieldForm.Visible then
        FFieldForm.RefreshData;
    end;
  finally
    tmp.Free;
  end;
end;

procedure TRMDesignerForm.LoadDictionary1Click(Sender: TObject);
begin
  OpenDialog1.FileName := '';
  OpenDialog1.Filter := RMLoadStr(SDictFile) + ' (*.rmd)|*.rmd';
  if (RMDesignerComp <> nil) and (RMDesignerComp.OpenDir <> '') then
    OpenDialog1.InitialDir := RMDesignerComp.OpenDir;
  if OpenDialog1.Execute then
    Report.Dictionary.LoadFromFile(OpenDialog1.FileName);
end;

procedure TRMDesignerForm.MergeDictionary1Click(Sender: TObject);
begin
  OpenDialog1.FileName := '';
  OpenDialog1.Filter := RMLoadStr(SDictFile) + ' (*.rmd)|*.rmd';
  if (RMDesignerComp <> nil) and (RMDesignerComp.OpenDir <> '') then
    OpenDialog1.InitialDir := RMDesignerComp.OpenDir;
  if OpenDialog1.Execute then
    Report.Dictionary.MergeFromFile(OpenDialog1.FileName);
end;

procedure TRMDesignerForm.SaveAsDictionary1Click(Sender: TObject);
begin
  SaveDialog1.DefaultExt := '*.rmd';
  SaveDialog1.FileName := '';
  SaveDialog1.Filter := RMLoadStr(SDictFile) + ' (*.rmd)|*.rmd';
  if (RMDesignerComp <> nil) and (RMDesignerComp.SaveDir <> '') then
    SaveDialog1.InitialDir := RMDesignerComp.SaveDir;
  SaveDialog1.FileName := CurDocName;
  if SaveDialog1.Execute then
    Report.Dictionary.SaveToFile(ChangeFileExt(SaveDialog1.FileName, '.rmd'));
end;

procedure TRMDesignerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (RMDesignerComp <> nil) and Assigned(RMDesignerComp.OnClose) then
    RMDesignerComp.OnClose(Self);
end;

procedure TRMDesignerForm.padSearchFindClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(False);
end;

procedure TRMDesignerForm.padSearchReplaceClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(True);
end;

procedure TRMDesignerForm.padSearchFindAgainClick(Sender: TObject);
begin
  DoSearchReplaceText(False, False);
end;

procedure TRMDesignerForm.SetGridShow(Value: Boolean);
begin
  EnableControls;
  if FShowGrid = Value then Exit;

  FShowGrid := Value;
  RedrawPage;
end;

procedure TRMDesignerForm.SetGridAlign(Value: Boolean);
begin
  EnableControls;
  if FGridAlign = Value then Exit;
  FGridAlign := Value;
end;

procedure TRMDesignerForm.SetGridSize(Value: Integer);
begin
  if FGridSize = Value then Exit;
  FGridSize := Value;
  RedrawPage;
end;

procedure TRMDesignerForm.UnSelectAll;
var
  i: Integer;
  lList: TList;
begin
  SelNum := 0;
  lList := PageObjects;
  for i := 0 to lList.Count - 1 do
    TRMView(lList[i]).Selected := False;
end;

procedure TRMDesignerForm.SetOldCurPage(Value: Integer);
begin
  FCurPage := Value;
end;

procedure TRMDesignerForm.Tab1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Tab1.TabIndex > 0) and FMouseDown then
    Tab1.BeginDrag(False);
end;

procedure TRMDesignerForm.Tab1Change(Sender: TObject);
begin
  FMouseDown := False; FTabChange := True;
  if Tab1.TabIndex = 0 then
  begin
    if FCurPageEditor <> nil then
      FCurPageEditor.Editor_Tab1Changed;

    FCodeMemo.BringToFront;
    FCodeMemo.Visible := True;
    FCodeMemo.SetFocus;
    KeyPreview := False;
    EnableControls;
    Exit;
  end;

  CurPage := Tab1.TabIndex - 1;
  KeyPreview := True;
end;

procedure TRMDesignerForm.Tab1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (not FTabChange) then
    FMouseDown := True;

  FTabChange := False;
end;

procedure TRMDesignerForm.Tab1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  HitTestInfo: TTCHitTestInfo;
  HitIndex: Integer;
begin
  Accept := Source = Tab1;
  if Accept then
  begin
    HitTestInfo.pt := Point(X, Y);
    HitIndex := SendMessage(Tab1.Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));
    Accept := (HitIndex > 0) and (HitIndex < Tab1.TabIndex);
  end;
end;

procedure TRMDesignerForm.Tab1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i, HitIndex: Integer;
  HitTestInfo: TTCHitTestInfo;

  procedure _ChangeSubReports(OldIndex, NewIndex: Integer);
  var
    i, j: Integer;
    t: TRMView;
    liPage: TRMCustomPage;
  begin
    for i := 0 to Report.Pages.Count - 1 do
    begin
      liPage := Report.Pages[i];
      if liPage is TRMReportPage then
      begin
        for j := 0 to THackPage(liPage).Objects.Count - 1 do
        begin
          t := THackPage(liPage).Objects[j];
          if (t is TRMSubReportView) and (TRMSubReportView(t).SubPage = OldIndex) then
            TRMSubReportView(t).SubPage := NewIndex;
        end;
      end;
    end;
  end;

begin
  HitTestInfo.pt := Point(X, Y);
  HitIndex := SendMessage(Tab1.Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));
  if (HitIndex <= 0) or (HitIndex = Tab1.TabIndex) then Exit;

  if CurPage > HitIndex then
  begin
    _ChangeSubReports(CurPage, -1);
    for i := CurPage - 1 downto HitIndex do
      _ChangeSubReports(i, i + 1);
    _ChangeSubReports(-1, HitIndex);
  end
  else
  begin
    _ChangeSubReports(CurPage, -1);
    for i := CurPage + 1 to HitIndex do
      _ChangeSubReports(i, i - 1);
    _ChangeSubReports(-1, HitIndex);
  end;

  Tab1.Tabs.Move(CurPage, HitIndex);
  Report.Pages.Move(CurPage, HitIndex - 1);
  CurPage := HitIndex - 1;
  Modified := True;
end;

{$IFDEF Raize}

procedure TRMDesignerForm.Tab1Changing(Sender: TObject; NewIndex: Integer;
  var AllowChange: Boolean);
{$ELSE}

procedure TRMDesignerForm.Tab1Changing(Sender: TObject; var AllowChange: Boolean);
{$ENDIF}
var
  lErrorMsg: string;
begin
  if Tab1.TabIndex = 0 then
  begin
    AllowChange := False;
    try
      THackReport(Report).FScriptEngine.Pas.Assign(FCodeMemo.CreateStringList);
      THackReport(Report).FScriptEngine.Compile;
      AllowChange := True;
    except
      on E: EJvInterpreterError do
      begin
        lErrorMsg := 'Script Error:' + #13#10 + IntToStr(E.ErrCode) + ': ' + E.Message;
        if E.ErrPos > -1 then
        begin
          lErrorMsg := lErrorMsg + #13#10 + 'at Postion:' + IntToStr(E.ErrPos);
        end;

        Application.MessageBox(PChar(lErrorMsg), PChar(RMLoadStr(SError)), mb_Ok + mb_IconError);
      end;
    end;
  end;
end;

procedure TRMDesignerForm.Tab1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := False;
  if Tab1.Dragging then
    Tab1.EndDrag(False);
end;

procedure TRMDesignerForm.MenuFilePreview1Click(Sender: TObject);
begin
  FCurPageEditor.Editor_MenuFilePreview1Click(Sender);
end;

procedure TRMDesignerForm.MenuFileHeaderFooterClick(Sender: TObject);
begin
  FCurPageEditor.Editor_MenuFileHeaderFooterClick(Sender);
end;

procedure TRMDesignerForm.padHelpClick(Sender: TObject);
begin
  ShellExecute(0, nil, 'rmhelp.chm', nil, nil, SW_RESTORE);
end;

procedure TRMDesignerForm.AddLanguageMenu(aParentMenu: TRMSubmenuItem);
var
  i: Integer;
  lItem: TRMMenuItem;
begin
  if (FLanguageList = nil) or (FLanguageList.Count < 1) then Exit;

  padSep := TRMSeparatorMenuItem.Create(Self);
  with padSep do
  begin
    AddToMenu(aParentMenu);
  end;
  padLanguage := TRMSubmenuItem.Create(Self);
  with padLanguage do
  begin
    Caption := 'Language';
    AddToMenu(aParentMenu);
  end;

  for i := 0 to FLanguageList.Count - 1 do
  begin
    lItem := TRMMenuItem.Create(padLanguage);
    lItem.Tag := i;
    lItem.Caption := FLanguageNameList[i];
    lItem.OnClick := OnLanguageItemClick;
    lItem.AddToMenu(padLanguage);
    lItem.RadioItem := True;
    if (RM_CurLanguage = lItem.Caption) then
      lItem.Checked := True;
  end;
end;

procedure TRMDesignerForm.OnLanguageItemClick(Sender: TObject);
var
  lFileName: string;
begin
  lFileName := FLanguageList[TRMMenuItem(Sender).Tag];
  if FileExists(lFileName) then
  begin
    RM_CurLanguage := TRMMenuItem(Sender).Caption;
    TRMMenuItem(Sender).Checked := True;
    RMResourceManager.LoadResourceModule(lFileName);

    Dock971.BeginUpdate;
    Dock972.BeginUpdate;
    Dock973.BeginUpdate;
    Dock974.BeginUpdate;
    try
      Localize;
      FToolbarStandard.Localize;
      FToolbarModifyPrepared.Localize;
      if FInspForm <> nil then
        FInspForm.Localize;
      if FFieldForm <> nil then
        FFieldForm.Localize;
      if FEditorForm <> nil then
        TRMEditorForm(FEditorForm).Localize;
      if FCurPageEditor <> nil then
        FCurPageEditor.Editor_Localize;
    finally
      Dock971.EndUpdate;
      Dock972.EndUpdate;
      Dock973.EndUpdate;
      Dock974.EndUpdate;
    end;
  end;
end;

procedure RMAddLanguageDll(aDllFileName: string; aCaption: string);
begin
  if FLanguageList = nil then
  begin
    FLanguageList := TStringList.Create;
    FLanguageNameList := TStringList.Create;
  end;

  FLanguageList.Add(aDllFileName);
  FLanguageNameList.Add(aCaption);
end;

initialization
  RMDesignerComp := nil;
  RMDesignerClass := TRMDesignerForm;

  RM_LastFrameWidth := RMToMMThousandths(1, rmutScreenPixels);
  RM_LastFillColor := clNone;
  RM_LastFrameColor := clBlack;
  RM_LastFontColor := clBlack;
  RM_LastFontStyle := 0;
  RM_LastFontCharset := StrToInt(RMLoadStr(SCharset)); //RMCharset;
  RM_LastHAlign := rmHLeft;
  RM_LastVAlign := rmVTop;
  RMShowBandTitles := True;

finalization
  FreeAndNil(FLanguageList);
  FreeAndNil(FLanguageNameList);

end.

