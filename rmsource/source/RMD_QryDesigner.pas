
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{            Query properties             }
{                                         }
{*****************************************}

unit RMD_QryDesigner;

interface

{$I RM.inc}

uses
  Windows, CommCtrl, SysUtils, Controls, ComCtrls, Classes, Graphics, ExtCtrls, Menus,
  Messages, StdCtrls, Forms, CheckLst, DB, Dialogs, Buttons, RMD_DBWrap, RM_DsgCtrls,
  ImgList
  {$IFDEF USE_SYNEDIT}, SynHighlighterSQL{$ENDIF};

type
  TRMListColumnEvent = procedure(aListView: TListView; aColumn: TListColumn) of object;

  { TRMListView }
  TRMListView = class(TListView)
  private
    FOnColumnResize: TRMListColumnEvent;
    FOnVerticalScroll: TNotifyEvent;
    FOnHorizontalScroll: TNotifyEvent;
    FOnScroll: TNotifyEvent;
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure WMVScroll(var Message: TWMHScroll); message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMVScroll); message WM_HSCROLL;
  protected
    procedure DoColumnResize(aColumn: TListColumn); virtual;
    procedure DoVerticalScroll; virtual;
    procedure DoHorizontalScroll; virtual;
    procedure DoScroll; virtual;
  public
    property OnColumnResize: TRMListColumnEvent read FOnColumnResize write FOnColumnResize;
    property OnVerticalScroll: TNotifyEvent read FOnVerticalScroll write FOnVerticalScroll;
    property OnHorizontalScroll: TNotifyEvent read FOnHorizontalScroll write FOnHorizontalScroll;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
  end;

  { TRMQBListView }
  TRMQBListView = class(TRMListView)
  private
  protected
    procedure DisplayEditControls(aVisible: Boolean); virtual;
    procedure SelectedSelectItemEvent(Sender: TObject; Item: TListItem; Selected: Boolean); virtual;
    procedure SelectedResizeEvent(Sender: TObject); virtual;
    procedure SelectedDblClickEvent(Sender: TObject); virtual;

    procedure SelectedScrollEvent(Sender: TObject);
    procedure SelectedColumnResizeEvent(aListView: TListView; aColumn: TListColumn);
    procedure SelectedClickEvent(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TRMQBFieldsListView }
  TRMQBFieldListView = class(TRMQBListView)
  private
    procedure _AddItem(Sender: TObject; aItemIndex: integer);
    procedure DeleteItem(Sender: TObject; aItemIndex: integer);
    procedure _DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure _DoDragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TRMQBCalcListView }
  TRMQBCalcListView = class(TRMQBListView)
  private
    procedure _AddItem(Sender: TObject; aItemIndex: integer);
    procedure _DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure _DoDragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
    procedure DisplayEditControls(aVisible: Boolean); override;
    procedure SelectedSelectItemEvent(Sender: TObject; Item: TListItem; Selected: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TRMQBLbx }
  TRMQBLbx = class(TCheckListBox)
  private
    FLoading: Boolean;
    function GetItemY(Item: integer): integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ClickCheck; override;
  end;

  { TRMQBTable }
  TRMQBTable = class(TPanel)
  private
    FCapturing: Boolean;
    FMouseDownSpot: TPoint;
    FLbx: TRMQBLbx;
    FTableName: string;
    FTableAlias: string;
    FEdtTableAlias: TEdit;
    FPopupMenu: TPopupMenu;

    procedure Activate(const ATableName: string; X, Y: Integer);
    function GetRowY(FldN: integer): integer;
    procedure _UnlinkBtn(Sender: TObject);
    procedure _DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure _DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure _CloseBtn(Sender: TObject);
    procedure _EditTableAlias(Sender: TObject);
    procedure _AfterEditTableAlias(Sender: TObject);
    procedure _EditTableAliasKeyPress(Sender: TObject; var Key: Char);
    procedure _MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure _MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure _MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure _Resize(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TRMQBLink }
  TRMQBLink = class(TShape)
  private
    Tbl1, Tbl2: TRMQBTable;
    FldN1, FldN2: integer;
    FldNam1, FldNam2: string;
    FLinkOpt, FLinkType: integer;
    LnkX, LnkY: byte;
    Rgn: HRgn;
    FPopMenu: TPopupMenu;
    procedure _Click(X, Y: integer);
    procedure CMHitTest(var Message: TCMHitTest); message CM_HitTest;
    function ControlAtPos(const Pos: TPoint): TControl;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure WndProc(var Message: TMessage); override;
    procedure Paint; override;
  end;

  { TRMQBArea }
  TRMQBArea = class(TScrollBox)
  public
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetOptions(Sender: TObject);
    procedure InsertTable(X, Y: Integer);
    function InsertLink(_tbl1, _tbl2: TRMQBTable; _fldN1, _fldN2: Integer): TRMQBLink;
    function FindTable(TableName: string): TRMQBTable;
    function FindLink(Link: TRMQBLink): boolean;
    function FindOtherLink(Link: TRMQBLink; Tbl: TRMQBTable; FldN: integer): boolean;
    procedure ReboundLink(Link: TRMQBLink);
    procedure ReboundLinks4Table(ATable: TRMQBTable);
    procedure Unlink(Sender: TObject);
    procedure UnlinkTable(ATable: TRMQBTable);
    procedure _DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure _DragDrop(Sender, Source: TObject; X, Y: Integer);
  end;

  { TRMDQueryDesignerForm }
  TRMDQueryDesignerForm = class(TForm)
    pnlButtons: TPanel;
    Panel1: TPanel;
    pgcDesigner: TPageControl;
    TabSheetFields: TTabSheet;
    TabSheetCalc: TTabSheet;
    TabSheetSQL: TTabSheet;
    VSplitter: TSplitter;
    Image1: TImage;
    ImageList1: TImageList;
    cmbCalc: TComboBox;
    Panel3: TPanel;
    FieldsB: TSpeedButton;
    ParamsB: TSpeedButton;
    TabSheetGroup: TTabSheet;
    TabSheetSort: TTabSheet;
    edtExpr: TEdit;
    Panel5: TPanel;
    btnAddGroup: TSpeedButton;
    btnDeleteGroup: TSpeedButton;
    pnlGroupLeft: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    lstGroupLeft: TListBox;
    lstGroupRight: TListBox;
    pnlSortLeft: TPanel;
    Panel9: TPanel;
    lstSortLeft: TListBox;
    Panel10: TPanel;
    btnAddSort: TSpeedButton;
    btnDeleteSort: TSpeedButton;
    Panel11: TPanel;
    Panel12: TPanel;
    btnSortAsc: TSpeedButton;
    btnSortDec: TSpeedButton;
    Panel4: TPanel;
    Panel13: TPanel;
    Label7: TLabel;
    Panel14: TPanel;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    lsvSortRight: TListView;
    Panel8: TPanel;
    Panel15: TPanel;
    Panel17: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    pmnSQLMemo: TPopupMenu;
    padModifySQL: TMenuItem;
    Bevel2: TBevel;
    Bevel1: TBevel;
    btnOK: TSpeedButton;
    btnCancel: TSpeedButton;
    btnNew: TSpeedButton;
    btnLoadFromFile: TSpeedButton;
    btnSaveToFile: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Panel16: TPanel;
    lsbTables: TListBox;
    Panel18: TPanel;
    cmbDatabase: TComboBox;
    Splitter1: TSplitter;
    Panel2: TPanel;
    btnModifySQL: TSpeedButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FieldsBClick(Sender: TObject);
    procedure ParamsBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lsbTablesDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure cmbCalcChange(Sender: TObject);
    procedure edtExprKeyPress(Sender: TObject; var Key: Char);
    procedure edtExprExit(Sender: TObject);
    procedure pgcDesignerChange(Sender: TObject);
    procedure TabSheetGroupResize(Sender: TObject);
    procedure TabSheetSortResize(Sender: TObject);
    procedure lstGroupLeftDblClick(Sender: TObject);
    procedure lstGroupRightDblClick(Sender: TObject);
    procedure lstSortLeftDblClick(Sender: TObject);
    procedure lsvSortRightDblClick(Sender: TObject);
    procedure btnSortAscClick(Sender: TObject);
    procedure btnSortDecClick(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure padModifySQLClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnLoadFromFileClick(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure Panel18Resize(Sender: TObject);
    procedure lsbTablesDblClick(Sender: TObject);
    procedure cmbDatabaseChange(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
  private
    { Private declarations }
    FQuery: TRMDQuery;
    FSaveSQL: string;
    FSaveEditSQLAsText: Boolean;
    FSaveVisualSQL: TStringList;
    FSaveDatabase: string;
    SQLMemo: TRMSynEditor;
    {$IFDEF USE_SYNEDIT}
    FSynSQLSyn: TSynSQLSyn;
    {$ENDIF}

    FFieldListView: TRMQBFieldListView;
    FCalcListView: TRMQBCalcListView;

    procedure ApplySettings;
    procedure ClearAll;
    procedure SetQuery(Value: TRMDQuery);
    procedure DecodeVisualSQL;
    procedure SaveVisualSQL;
    procedure SetEditSQLAsText;
    procedure Localize;
  protected
    QBArea: TRMQBArea;
  public
    { Public declarations }
    property Query: TRMDQuery read FQuery write SetQuery;
  end;

implementation

uses RM_Class, RMD_QueryParm, RMD_EditorField, RM_Const, RM_Utils, RMD_Qblnk;

{$R *.DFM}

var
  FForm: TRMDQueryDesignerForm;

const
  Hand = 15;
  Hand2 = 12;

  //  sSort: array[0..2] of string = ('', 'Asc', 'Desc');
  //  sSort_1: array[0..2] of string = ('²»ÅÅÐò', 'ÉýÐò', '½µÐò');
  sFunc: array[0..5] of string = ('Sum', 'Count', 'Avg', 'Max', 'Min', '');
  sFunc_1: array[0..5] of string = ('Sum', 'Count', 'Avg', 'Max', 'Min', 'Expression');
  sLinkOpt: array[0..5] of string = ('=', '<', '>', '=<', '=>', '<>');
  sOuterJoin: array[1..3] of string = (' LEFT OUTER JOIN ', ' RIGHT OUTER JOIN ',
    ' FULL OUTER JOIN ');

type

  { TRMSQL }
  TRMSQL = class
  private
    FTables: TStringList;
    FTableAlias: TStringList;
    FColumns: TStringList;
    FGroups: TStringList;
    FSorts: TStringList;
    FWheres: TStringList;
    procedure geTables;
    procedure geColumns;
    procedure geGroups;
    procedure geSorts;
    procedure geWheres;
    function MakeFieldAlias(const str: string): string;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Encode;
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  {TRMSQL}

constructor TRMSQL.Create;
begin
  inherited Create;
  FTables := TStringList.Create;
  FTableAlias := TStringList.Create;
  FColumns := TStringList.Create;
  FGroups := TStringList.Create;
  FSorts := TStringList.Create;
  FWheres := TStringList.Create;
end;

destructor TRMSQL.Destroy;
begin
  FTables.Free;
  FTableAlias.Free;
  FColumns.Free;
  FGroups.Free;
  FSorts.Free;
  FWheres.Free;
  inherited Destroy;
end;

const
  ReservedWords: array[0..4] of string = ('size', 'option', 'position', 'level', 'date');

function TRMSQL.MakeFieldAlias(const str: string): string;
var
  aPos: integer;

  function isResrvedWord: Boolean;
  var
    aStr: string;
    i: integer;
  begin
    aStr := Copy(str, Pos('.', str) + 1, 99999);
    for i := 0 to High(ReservedWords) do
    begin
      if AnsiCompareText(aStr, ReservedWords[i]) = 0 then
      begin
        Result := TRUE;
        Exit;
      end;
    end;
    Result := FALSE;
  end;

begin
  if (FTables.Count = 1) and (Pos(' ', str) = 0) and (not isResrvedWord) then
    Result := Copy(str, Pos('.', str) + 1, 99999)
  else
  begin
    aPos := Pos('.', str);
    if Copy(str, aPos + 1, 99999) = '*' then
      Result := Copy(str, 1, aPos) + Copy(str, aPos + 1, 99999)
    else
      Result := Copy(str, 1, aPos) + '"' + Copy(str, aPos + 1, 99999) + '"';
  end;
end;

procedure TRMSQL.Encode;
var
  s: string;
  i: integer;
begin
  geTables;
  geColumns;
  geGroups;
  geSorts;
  geWheres;

  FForm.SQLMemo.Lines.Clear;
  for i := 0 to FColumns.Count - 1 do // SELECT
  begin
    if i = 0 then
      s := 'SELECT '
    else
      s := s + ', ';
    s := s + FColumns[i];
    if (length(s) > 60) or (i = FColumns.Count - 1) then
    begin
      FForm.SQLMemo.Lines.Add(s);
      s := '    ';
    end;
  end;

  for i := 0 to FTables.Count - 1 do // FROM
  begin
    if i = 0 then
      s := 'FROM '
    else
      s := s + ', ';
    if Length(FTableAlias[i]) > 0 then
    begin
      if Pos(' ', FTables[i]) > 0 then
        s := s + Format('"%s" %s', [FTables[i], FTableAlias[i]])
      else
        s := s + Format('%s %s', [FTables[i], FTableAlias[i]]);
    end
    else
      s := s + FTables[i];

    if (length(s) > 60) or (i = FTables.Count - 1) then
    begin
      FForm.SQLMemo.Lines.Add(s);
      s := '    ';
    end;
  end;

  for i := 0 to FWheres.Count - 1 do // WHERE
  begin
    if i = 0 then
      s := 'WHERE '
    else
      s := s + ' AND ';
    s := s + FWheres[i];
    if (length(s) > 60) or (i = FWheres.Count - 1) then
    begin
      FForm.SQLMemo.Lines.Add(s);
      s := '    ';
    end;
  end;

  for i := 0 to FGroups.Count - 1 do // GROUP BY
  begin
    if i = 0 then
      s := 'GROUP BY '
    else
      s := s + ', ';
    s := s + FGroups[i];
    if (length(s) > 60) or (i = FGroups.Count - 1) then
    begin
      FForm.SQLMemo.Lines.Add(s);
      s := '    ';
    end;
  end;

  for i := 0 to FSorts.Count - 1 do // ORDER BY
  begin
    if i = 0 then
      s := 'ORDER BY '
    else
      s := s + ', ';
    s := s + FSorts[i];
    if (length(s) > 60) or (i = FSorts.Count - 1) then
    begin
      FForm.SQLMemo.Lines.Add(s);
      s := '    ';
    end;
  end;
end;

procedure TRMSQL.geTables;
var
  i: integer;
  Link: TRMQBLink;
  tbl1, tbl2: string;
  sl: TStringList;
begin
  FTables.Clear;
  FTableAlias.Clear;
  sl := TStringList.Create;
  try
    for i := 0 to FForm.QBArea.ControlCount - 1 do // search tables for joins
    begin
      if FForm.QBArea.Controls[i] is TRMQBLink then
      begin
        Link := TRMQBLink(FForm.QBArea.Controls[i]);
        if Link.FLinkType > 0 then
        begin
          tbl1 := LowerCase(Link.Tbl1.FTableAlias);
          tbl2 := LowerCase(Link.Tbl2.FTableAlias);
          FTables.Add(LowerCase(Link.Tbl1.FTableName) + ' ' + tbl1
            + sOuterJoin[Link.FLinkType] + LowerCase(Link.Tbl2.FTableName) + ' ' + tbl2 + ' ON '
            + tbl1 + '.' + LowerCase(Link.FldNam1) + sLinkOpt[Link.FLinkOpt]
            + tbl2 + '.' + LowerCase(Link.FldNam2));
          FTableAlias.Add('');

          if sl.IndexOf(Link.Tbl1.FTableName) < 0 then
            sl.Add(Link.Tbl1.FTableName);
          if sl.IndexOf(Link.Tbl2.FTableName) < 0 then
            sl.Add(Link.Tbl2.FTableName);
        end;
      end;
    end;

    for i := 0 to FForm.QBArea.ControlCount - 1 do
    begin
      if FForm.QBArea.Controls[i] is TRMQBTable then
      begin
        if sl.IndexOf(TRMQBTable(FForm.QBArea.Controls[i]).FTableName) < 0 then
        begin
          sl.Add(TRMQBTable(FForm.QBArea.Controls[i]).FTableName);
          FTables.Add(TRMQBTable(FForm.QBArea.Controls[i]).FTableName);
          FTableAlias.Add(TRMQBTable(FForm.QBArea.Controls[i]).FTableAlias);
        end;
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMSQL.geColumns;
var
  i: integer;
  str: string;
begin
  FColumns.Clear;
  for i := 0 to FForm.FFieldListView.Items.Count - 1 do
  begin
    str := FForm.FFieldListView.Items[i].SubItems[0];
    if Pos('.', str) > 0 then
      str := Copy(str, Pos('.', str) + 1, 99999);
    if str <> FForm.FFieldListView.Items[i].Caption then
      str := ' ' + FForm.FFieldListView.Items[i].Caption
    else
      str := '';
    str := MakeFieldAlias(FForm.FFieldListView.Items[i].SubItems[0]) + str;
    FColumns.Add(str);
  end;

  for i := 0 to FForm.FCalcListView.Items.Count - 1 do
  begin
    if AnsiCompareText(FForm.FCalcListView.Items[i].SubItems[2], sFunc_1[0]) = 0 then
      FColumns.Add(sFunc[0] + '(' + FForm.FCalcListView.Items[i].SubItems[0] + ') ' + FForm.FCalcListView.Items[i].Caption)
    else if AnsiCompareText(FForm.FCalcListView.Items[i].SubItems[2], sFunc_1[1]) = 0 then
      FColumns.Add(sFunc[1] + '(' + FForm.FCalcListView.Items[i].SubItems[0] + ') ' + FForm.FCalcListView.Items[i].Caption)
    else if AnsiCompareText(FForm.FCalcListView.Items[i].SubItems[2], sFunc_1[2]) = 0 then
      FColumns.Add(sFunc[2] + '(' + FForm.FCalcListView.Items[i].SubItems[0] + ') ' + FForm.FCalcListView.Items[i].Caption)
    else if AnsiCompareText(FForm.FCalcListView.Items[i].SubItems[2], sFunc_1[3]) = 0 then
      FColumns.Add(sFunc[3] + '(' + FForm.FCalcListView.Items[i].SubItems[0] + ') ' + FForm.FCalcListView.Items[i].Caption)
    else if AnsiCompareText(FForm.FCalcListView.Items[i].SubItems[2], sFunc_1[4]) = 0 then
      FColumns.Add(sFunc[4] + '(' + FForm.FCalcListView.Items[i].SubItems[0] + ') ' + FForm.FCalcListView.Items[i].Caption)
    else
      FColumns.Add(FForm.FCalcListView.Items[i].SubItems[0] + ' ' + FForm.FCalcListView.Items[i].Caption);
  end;
end;

procedure TRMSQL.geGroups;
var
  i: integer;
begin
  FSorts.Clear;
  for i := 0 to FForm.lstGroupRight.Items.Count - 1 do
  begin
    FGroups.Add(MakeFieldAlias(FForm.lstGroupRight.Items[i]));
  end;
end;

procedure TRMSQL.geSorts;
var
  i: integer;
  str: string;
begin
  FSorts.Clear;
  for i := 0 to FForm.lsvSortRight.Items.Count - 1 do
  begin
    str := MakeFieldAlias(FForm.lsvSortRight.Items[i].Caption);
    if Length(FForm.lsvSortRight.Items[i].SubItems[0]) > 0 then
      str := str + ' DESC';
    FSorts.Add(str);
  end;
end;

procedure TRMSQL.geWheres;
var
  i: integer;
  str: string;
  Link: TRMQBLink;
begin
  FWheres.Clear;
  for i := 0 to FForm.QBArea.ControlCount - 1 do
  begin
    if FForm.QBArea.Controls[i] is TRMQBLink then
    begin
      Link := TRMQBLink(FForm.QBArea.Controls[i]);
      if Link.FLinkType = 0 then
      begin
        str := MakeFieldAlias(Link.tbl1.FTableAlias + '.' + Link.fldNam1) + sLinkOpt[Link.FLinkOpt] +
          MakeFieldAlias(Link.tbl2.FTableAlias + '.' + Link.fldNam2);
        FWheres.Add(LowerCase(str));
      end;
    end;
  end;
end;

procedure CalcEditControlPosition(aListView: TListView; aControl: TControl; aItem: TListItem; aFieldPosition: Integer);
var
  i: Integer;
  Offset: Integer;
  Left: Integer;
  Width: Integer;
  ControlEdge: Integer;
  ListViewEdge: Integer;
begin
  if (aItem = nil) then
  begin
    aControl.Visible := False;
    Exit;
  end;

  Offset := (aListView.Columns.Count - aFieldPosition) + 1;
  Left := 0;
  for i := 0 to aListView.Columns.Count - Offset do
    Left := Left + aListView.Columns[i].Width;

  ControlEdge := Left + aListView.Columns[aFieldPosition].Width;
  ListViewEdge := (aListView.Left + aListView.Width);
  Width := aListView.Columns[aFieldPosition].Width;
  Left := Left + aItem.Left;
  if ControlEdge > ListViewEdge then
    Width := (Width - (ControlEdge - ListViewEdge)) - 2;
  if Width < 12 then
    aControl.Visible := False
  else
  begin
    aControl.Visible := True;
    if aControl is TComboBox then
    begin
      aControl.Left := Left + 1;
      aControl.Top := aItem.Top;
      aControl.Width := Width - 2;
    end
    else if aControl is TEdit then
    begin
      aControl.Left := Left + 1;
      aControl.Top := aItem.Top;
      aControl.Width := Width - 2;
    end
    else if aControl is TCheckBox then
    begin
      aControl.Left := Left + 1;
      aControl.Top := aItem.Top + 2;
      aControl.Width := Width - 3;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMListView}

procedure TRMListView.WMHScroll(var Message: TWMVScroll);
begin
  inherited;
  DoHorizontalScroll;
  DoScroll;
end;

procedure TRMListView.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  DoVerticalScroll;
  DoScroll;
end;

procedure TRMListView.DoVerticalScroll;
begin
  if Assigned(FOnVerticalScroll) then
    FOnVerticalScroll(Self);
end;

procedure TRMListView.DoHorizontalScroll;
begin
  if Assigned(FOnHorizontalScroll) then
    FOnHorizontalScroll(Self);
end;

procedure TRMListView.DoScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

procedure TRMListView.WMNotify(var Message: TWMNotify);
begin
  inherited;
  if (ViewStyle <> vsReport) then
    Exit;
  with Message.NMHdr^ do
    case code of
      HDN_ITEMCHANGING:
        with PHDNotify(Pointer(Message.NMHdr))^, PItem^ do
        begin
          if (Mask and HDI_WIDTH) <> 0 then
          begin
            Column[Item].Width := cxy;
            DoColumnResize(Column[Item]);
          end;
        end;
    end;
end;

procedure TRMListView.DoColumnResize(aColumn: TListColumn);
begin
  if Assigned(FOnColumnResize) then
    FOnColumnResize(Self, aColumn);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBListView}

constructor TRMQBListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ViewStyle := vsReport;
  ColumnClick := FALSE;

  OnColumnResize := SelectedColumnResizeEvent;
  {$IFNDEF COMPILER3_UP}
  OnResize := SelectedResizeEvent;
  {$ENDIF}
  OnScroll := SelectedScrollEvent;
  OnClick := SelectedClickEvent;
  OnDblClick := SelectedDblClickEvent;
  {$IFDEF COMPILER4_UP}
  OnSelectItem := SelectedSelectItemEvent;
  {$ENDIF}
end;

procedure TRMQBListView.DisplayEditControls(aVisible: Boolean);
begin
end;

procedure TRMQBListView.SelectedSelectItemEvent(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
end;

procedure TRMQBListView.SelectedScrollEvent(Sender: TObject);
begin
  DisplayEditControls(False);
end;

procedure TRMQBListView.SelectedResizeEvent(Sender: TObject);
begin
end;

procedure TRMQBListView.SelectedColumnResizeEvent(aListView: TListView; aColumn: TListColumn);
begin
  SelectedSelectItemEvent(Self, Self.Selected, True);
end;

procedure TRMQBListView.SelectedClickEvent(Sender: TObject);
var
  Point: TPoint;
  ListItem: TListItem;
begin
  GetCursorPos(Point);
  Point := ScreenToClient(Point);
  ListItem := GetItemAt(2, Point.Y);
  Selected := ListItem;
  {$IFDEF Delphi3Only}
  //SelectedSelectItemEvent(Sender, ListItem, True);
  {$ENDIF}
end;

procedure TRMQBListView.SelectedDblClickEvent(Sender: TObject);
begin
  if Selected <> nil then
    Items.Delete(Selected.Index);

  {$IFDEF Delphi3Only}
  //SelectedSelectItemEvent(Self, nil, False);
  {$ENDIF}
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBFieldListView}

constructor TRMQBFieldListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnDragOver := _DoDragOver;
  OnDragDrop := _DoDragDrop;

  with Columns.Add do
  begin
    Caption := 'Field Alias';
    Width := 100;
  end;
  with Columns.Add do
  begin
    Caption := 'Field SQL Alias';
    Width := 180;
  end;
end;

procedure TRMQBFieldListView._AddItem(Sender: TObject; aItemIndex: integer);
var
  tmp: TRMQBTable;
  str: string;
  i: integer;
begin
  tmp := TRMQBTable(Sender);
  str := tmp.FTableAlias + '.' + tmp.FLbx.Items[aItemIndex];
  for i := 0 to FForm.FFieldListView.Items.Count - 1 do
  begin
    if str = FForm.FFieldListView.Items[i].SubItems[0] then
      Exit;
  end;

  with FForm.FFieldListView.Items.Add do
  begin
    Caption := tmp.FLbx.Items[aItemIndex];
    SubItems.Add(str);
  end;
end;

procedure TRMQBFieldListView.DeleteItem(Sender: TObject; aItemIndex: integer);
var
  tmp: TRMQBTable;
  i: integer;
  str: string;
begin
  tmp := TRMQBTable(Sender);
  str := tmp.FTableAlias + '.' + tmp.FLbx.Items[aItemIndex];
  for i := 0 to FForm.FFieldListView.Items.Count - 1 do
  begin
    if str = FForm.FFieldListView.Items[i].SubItems[0] then
    begin
      FForm.FFieldListView.Items.Delete(i);
      Break;
    end;
  end;
end;

procedure TRMQBFieldListView._DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Source is TCheckListBox) and (TWinControl(Source).Parent is TRMQBTable) then
    Accept := TRUE;
end;

procedure TRMQBFieldListView._DoDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if not (Source is TCheckListBox) then
    exit;
  _AddItem(TWinControl(Source).Parent, TRMQBTable(TWinControl(Source).Parent).FLbx.ItemIndex);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBCalcListView}

constructor TRMQBCalcListView.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);
  OnDragOver := _DoDragOver;
  OnDragDrop := _DoDragDrop;
  for i := Low(sFunc_1) to High(sFunc_1) do
    FForm.cmbCalc.Items.Add(sFunc_1[i]);

  with Columns.Add do
  begin
    Caption := 'Field Alias';
    Width := 100;
  end;
  with Columns.Add do
  begin
    Caption := 'Field SQL Alias';
    Width := 180;
  end;
  with Columns.Add do
  begin
    Caption := 'Table';
    Width := 100;
  end;
  with Columns.Add do
  begin
    Caption := 'Function';
    Width := 100;
  end;
  with Columns.Add do
  begin
    Caption := 'Expression';
    Width := 120;
  end;
end;

procedure TRMQBCalcListView._AddItem(Sender: TObject; aItemIndex: integer);
var
  tmp: TRMQBTable;
begin
  tmp := TRMQBTable(Sender);
  with FForm.FCalcListView.Items.Add do
  begin
    Caption := tmp.FLbx.Items[aItemIndex];
    SubItems.Add(tmp.FTableAlias + '.' + tmp.FLbx.Items[aItemIndex]);
    SubItems.Add(tmp.FTableAlias);
    SubItems.Add(sFunc_1[0]);
    SubItems.Add('');
  end;
end;

procedure TRMQBCalcListView._DoDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Source is TCheckListBox) and (TWinControl(Source).Parent is TRMQBTable) then
    Accept := TRUE;
end;

procedure TRMQBCalcListView._DoDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if not (Source is TCheckListBox) then
    exit;
  _AddItem(TWinControl(Source).Parent, TRMQBTable(TWinControl(Source).Parent).FLbx.ItemIndex);
end;

procedure TRMQBCalcListView.DisplayEditControls(aVisible: Boolean);
begin
  FForm.cmbCalc.Visible := aVisible;
  FForm.edtExpr.Visible := aVisible;
  FForm.edtExpr.Enabled := FForm.cmbCalc.ItemIndex = 5;
end;

procedure TRMQBCalcListView.SelectedSelectItemEvent(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if (Item = nil) or not Selected then
    DisplayEditControls(False)
  else
  begin
    CalcEditControlPosition(FForm.FCalcListView, FForm.cmbCalc, Item, 3);
    CalcEditControlPosition(FForm.FCalcListView, FForm.edtExpr, Item, 4);
    FForm.cmbCalc.ItemIndex := FForm.cmbCalc.Items.IndexOf(Item.SubItems[2]);
    FForm.edtExpr.Text := Item.SubItems[3];
    DisplayEditControls(TRUE);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBLbx}

constructor TRMQBLbx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLoading := false;
end;

procedure TRMQBLbx.ClickCheck;
begin
  inherited;
  if FLoading then Exit;
  if Checked[ItemIndex] then
  begin
    if FForm.pgcDesigner.ActivePage = FForm.TabSheetFields then
    begin
      FForm.FFieldListView._AddItem(Self.Parent, ItemIndex);
    end;
  end
  else
  begin
    FForm.FFieldListView.DeleteItem(Self.Parent, ItemIndex);
  end;
end;

function TRMQBLbx.GetItemY(Item: integer): integer;
begin
  Result := Item * ItemHeight + ItemHeight div 2 + 1;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBTable}

constructor TRMQBTable.Create(AOwner: TComponent);
var
  MenuItem: TMenuItem;
begin
  inherited Create(AOwner);
  Visible := FALSE;
  FPopupMenu := TPopupMenu.Create(Self);
  {$IFDEF COMPILER5_UP}
  FPopupMenu.AutoHotkeys := maManual;
  FPopupMenu.AutoLineReduction := maManual;
  {$ENDIF}

  MenuItem := TMenuItem.Create(Self);
  MenuItem.Caption := 'Unlink';
  MenuItem.OnClick := _UnlinkBtn;
  FPopupMenu.Items.Add(MenuItem);

  MenuItem := TMenuItem.Create(Self);
  MenuItem.Caption := 'Remove Table';
  MenuItem.OnClick := _CloseBtn;
  FPopupMenu.Items.Add(MenuItem);

  MenuItem := TMenuItem.Create(Self);
  MenuItem.Caption := '-';
  FPopupMenu.Items.Add(MenuItem);

  MenuItem := TMenuItem.Create(Self);
  MenuItem.Caption := 'Edit Table Alias';
  MenuItem.OnClick := _EditTableAlias;
  FPopupMenu.Items.Add(MenuItem);

  ShowHint := True;
  BorderWidth := 4;
  OnMouseDown := _MouseDown;
  OnMouseMove := _MouseMove;
  OnMouseUp := _MouseUp;
  OnResize := _Resize;
  PopupMenu := FPopupMenu;

  FLbx := TRMQBLbx.Create(Self);
  FLbx.Parent := Self;
  FLbx.Style := lbOwnerDrawFixed;
  FLbx.Align := alBottom;
  FLbX.Top := 24;
  FLbx.DragMode := dmAutomatic;
  FLbx.PopupMenu := FPopupMenu;
  FLbx.OnDragOver := _DragOver;
  FLbx.OnDragDrop := _DragDrop;

  FEdtTableAlias := TEdit.Create(Self);
  with FEdtTableAlias do
  begin
    Parent := Self;
    Left := 20;
    Top := 2;
    Width := 17;
    Visible := FALSE;
    OnExit := _AfterEditTableAlias;
    OnKeyPress := _EditTableAliasKeyPress;
  end;
end;

destructor TRMQBTable.Destroy;
begin
  inherited Destroy;
end;

procedure TRMQBTable.Paint;
begin
  inherited Paint;
  Canvas.TextOut((Width - Canvas.TextWidth(FTableAlias)) div 2, 6, FTableAlias)
end;

function TRMQBTable.GetRowY(FldN: integer): integer;
var
  pnt: TPoint;
begin
  pnt.X := FLbx.Left;
  pnt.Y := FLbx.Top + FLbx.GetItemY(FldN);
  pnt := Parent.ScreenToClient(ClientToScreen(pnt));
  Result := pnt.Y;
end;

procedure TRMQBTable._CloseBtn(Sender: TObject);
begin
  TRMQBArea(Parent).UnlinkTable(Self);
  Free;
end;

procedure TRMQBTable._EditTableAlias(Sender: TObject);
begin
  FEdtTableAlias.Text := FTableAlias;
  FEdtTableAlias.Modified := FALSE;
  FEdtTableAlias.Visible := TRUE;
  FEdtTableAlias.SetFocus;
end;

procedure TRMQBTable._AfterEditTableAlias(Sender: TObject);
var
  i: integer;

  function ReplaceStr(const aSource, aSubStr, aSubStr1: string): string;
  var
    aPos: integer;
  begin
    Result := aSource;
    aPos := Pos(aSubStr + '.', Result);
    while aPos > 0 do
    begin
      System.Delete(Result, aPos, Length(aSubStr));
      System.Insert(aSubStr1, Result, aPos);
      aPos := Pos(aSubStr + '.', Result);
    end;
  end;

begin
  if FEdtTableAlias.Modified and (Length(FEdtTableAlias.Text) > 0) then
  begin
    for i := 0 to FForm.FFieldListView.Items.Count - 1 do
      FForm.FFieldListView.Items[i].SubItems[0] := ReplaceStr(FForm.FFieldListView.Items[i].SubItems[0], FTableAlias, FEdtTableAlias.Text);
    for i := 0 to FForm.FCalcListView.Items.Count - 1 do
      FForm.FCalcListView.Items[i].SubItems[0] := ReplaceStr(FForm.FCalcListView.Items[i].SubItems[0], FTableAlias, FEdtTableAlias.Text);
    for i := 0 to FForm.lstGroupRight.Items.Count - 1 do
      FForm.lstGroupRight.Items[i] := ReplaceStr(FForm.lstGroupRight.Items[i], FTableAlias, FEdtTableAlias.Text);
    for i := 0 to FForm.lsvSortRight.Items.Count - 1 do
      FForm.lsvSortRight.Items[i].Caption := ReplaceStr(FForm.lsvSortRight.Items[i].Caption, FTableAlias, FEdtTableAlias.Text);

    FTableAlias := FEdtTableAlias.Text;
    FEdtTableAlias.Modified := FALSE;
  end;
  FEdtTableAlias.Visible := FALSE;
end;

procedure TRMQBTable._EditTableAliasKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    _AfterEditTableAlias(nil);
  end;
end;

procedure TRMQBTable._Resize(Sender: TObject);
begin
  FEdtTableAlias.Width := Width - FEdtTableAlias.Left - 4;
end;

type
  THackQuery = class(TRMDQuery)
  end;

procedure TRMQBTable.Activate(const ATableName: string; X, Y: Integer);
begin
  Hint := ATableName;
  FTableName := ATableName;
  if Pos('.', ATableName) > 0 then
    FTableAlias := Copy(ATableName, 1, Pos('.', ATableName) - 1)
  else
    FTableAlias := ATableName;

  FLbx.Items.Clear;
  FLbx.Items.BeginUpdate;
  THackQuery(FForm.FQuery).GetTableFieldNames(FForm.cmbDatabase.Text, FTableName, FLbx.Items);
  FLbx.Items.Insert(0, '*');
  FLbx.Items.EndUpdate;

  Top := Y;
  Left := X;
  FLbx.Height := FLbx.ItemHeight * FLbx.Items.Count + 4;
  Height := FLbx.Height + 4 + 22;
  Visible := true;
end;

procedure TRMQBTable._UnlinkBtn(Sender: TObject);
begin
  TRMQBArea(Parent).UnlinkTable(Self);
end;

procedure TRMQBTable._DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source is TCustomListBox) and (TWinControl(Source).Parent is TRMQBTable) then
    Accept := true;
end;

procedure TRMQBTable._DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  nRow: integer;
  hRow: integer;
begin
  if Source = Self.FLbx then
    exit;
  if Source is TCustomListBox then
  begin
    if TWinControl(Source).Parent is TRMQBTable then
    begin
      hRow := FLbx.ItemHeight;
      if hRow <> 0 then
        nRow := Y div hRow
      else
        nRow := 0;
      if nRow > FLbx.Items.Count - 1 then
        nRow := FLbx.Items.Count - 1;
      if Source <> FLbx then
        TRMQBArea(Parent).InsertLink(TRMQBTable(TWinControl(Source).Parent), Self,
          TRMQBTable(TWinControl(Source).Parent).FLbx.ItemIndex, nRow)
      else
      begin
        if nRow <> FLbx.ItemIndex then
          TRMQBArea(Parent).InsertLink(Self, Self, FLbx.ItemIndex, nRow);
      end;
    end
    else if Source = FForm.lsbTables then
    begin
      X := X + Left + TWinControl(Sender).Left;
      Y := Y + Top + TWinControl(Sender).Top;
      TRMQBArea(Parent).InsertTable(X, Y);
    end;
  end
end;

procedure TRMQBTable._MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  BringToFront;
  if Button = mbLeft then
  begin
    SetCapture(Self.Handle);
    FCapturing := TRUE;
    FMouseDownSpot.X := x;
    FMouseDownSpot.Y := Y;
  end;
end;

procedure TRMQBTable._MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FCapturing then
  begin
    Left := Left - (FMouseDownSpot.x - x);
    Top := Top - (FMouseDownSpot.y - y);
  end;
end;

procedure TRMQBTable._MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FCapturing then
  begin
    ReleaseCapture;
    FCapturing := false;
  end;
  TRMQBArea(Parent).ReboundLinks4Table(Self);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBLink}

constructor TRMQBLink.Create(AOwner: TComponent);
var
  mnuArr: array[1..4] of TMenuItem;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 105;
  Height := 105;
  Rgn := CreateRectRgn(0, 0, Hand, Hand);
  mnuArr[1] := NewItem('', 0, false, false, nil, 0, 'mnuLinkName');
  mnuArr[2] := NewLine;
  mnuArr[3] := NewItem('Link options', 0, false, true, TRMQBArea(AOwner).SetOptions, 0, 'mnuOptions');
  mnuArr[4] := NewItem('Unlink', 0, false, true, TRMQBArea(AOwner).Unlink, 0, 'mnuUnlink');
  FPopMenu := NewPopupMenu(Self, 'mnu', paLeft, false, mnuArr);
  FPopMenu.PopupComponent := Self;
end;

destructor TRMQBLink.Destroy;
begin
  DeleteObject(Rgn);
  inherited Destroy;
end;

procedure TRMQBLink.Paint;
var
  ArrRgn, pntArray: array[1..4] of TPoint;
  ArrCnt: integer;
begin
  if tbl1 <> tbl2 then
  begin
    if ((LnkX = 1) and (LnkY = 1)) or ((LnkX = 4) and (LnkY = 2)) then
    begin
      pntArray[1].X := 0;
      pntArray[1].Y := Hand div 2;
      pntArray[2].X := Hand;
      pntArray[2].Y := Hand div 2;
      pntArray[3].X := Width - Hand;
      pntArray[3].Y := Height - Hand div 2;
      pntArray[4].X := Width;
      pntArray[4].Y := Height - Hand div 2;
      ArrRgn[1].X := pntArray[2].X + 5;
      ArrRgn[1].Y := pntArray[2].Y - 5;
      ArrRgn[2].X := pntArray[2].X - 5;
      ArrRgn[2].Y := pntArray[2].Y + 5;
      ArrRgn[3].X := pntArray[3].X - 5;
      ArrRgn[3].Y := pntArray[3].Y + 5;
      ArrRgn[4].X := pntArray[3].X + 5;
      ArrRgn[4].Y := pntArray[3].Y - 5;
    end;
    if Width > Hand + Hand2 then
    begin
      if ((LnkX = 2) and (LnkY = 1)) or ((LnkX = 3) and (LnkY = 2)) then
      begin
        pntArray[1].X := 0;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Hand;
        pntArray[2].Y := Hand div 2;
        pntArray[3].X := Width - 5;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := Width - Hand;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X + 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X - 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X - 5;
        ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X + 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
      if ((LnkX = 3) and (LnkY = 1)) or ((LnkX = 2) and (LnkY = 2)) then
      begin
        pntArray[1].X := Width - Hand;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Width - 5;
        pntArray[2].Y := Hand div 2;
        pntArray[3].X := Hand;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := 0;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X - 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X + 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X + 5;
        ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X - 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
    end
    else
    begin
      if ((LnkX = 2) and (LnkY = 1)) or ((LnkX = 3) and (LnkY = 2)) or
        ((LnkX = 3) and (LnkY = 1)) or ((LnkX = 2) and (LnkY = 2)) then
      begin
        pntArray[1].X := 0;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Width - Hand2;
        pntArray[2].Y := Hand div 2;
        pntArray[3].X := Width - Hand2;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := 0;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X - 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X + 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X + 5;
        ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X - 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
    end;
    if ((LnkX = 4) and (LnkY = 1)) or ((LnkX = 1) and (LnkY = 2)) then
    begin
      pntArray[1].X := Width;
      pntArray[1].Y := Hand div 2;
      pntArray[2].X := Width - Hand;
      pntArray[2].Y := Hand div 2;
      pntArray[3].X := Hand;
      pntArray[3].Y := Height - Hand div 2;
      pntArray[4].X := 0;
      pntArray[4].Y := Height - Hand div 2;
      ArrRgn[1].X := pntArray[2].X - 5;
      ArrRgn[1].Y := pntArray[2].Y - 5;
      ArrRgn[2].X := pntArray[2].X + 5;
      ArrRgn[2].Y := pntArray[2].Y + 5;
      ArrRgn[3].X := pntArray[3].X + 5;
      ArrRgn[3].Y := pntArray[3].Y + 5;
      ArrRgn[4].X := pntArray[3].X - 5;
      ArrRgn[4].Y := pntArray[3].Y - 5;
    end;
  end
  else
  begin
    pntArray[1].X := 0;
    pntArray[1].Y := Hand div 2;
    pntArray[2].X := Hand - 5;
    pntArray[2].Y := Hand div 2;
    pntArray[3].X := Hand - 5;
    pntArray[3].Y := Height - Hand div 2;
    pntArray[4].X := 0;
    pntArray[4].Y := Height - Hand div 2;
    ArrRgn[1].X := pntArray[2].X + 5;
    ArrRgn[1].Y := pntArray[2].Y - 5;
    ArrRgn[2].X := pntArray[2].X - 5;
    ArrRgn[2].Y := pntArray[2].Y + 5;
    ArrRgn[3].X := pntArray[3].X - 5;
    ArrRgn[3].Y := pntArray[3].Y + 5;
    ArrRgn[4].X := pntArray[3].X + 5;
    ArrRgn[4].Y := pntArray[3].Y - 5;
  end;
  Canvas.PolyLine(pntArray);
  Canvas.Brush := Parent.Brush;
  DeleteObject(Rgn);
  ArrCnt := 4;
  Rgn := CreatePolygonRgn(ArrRgn, ArrCnt, ALTERNATE);
end;

procedure TRMQBLink._Click(X, Y: integer);
var
  pnt: TPoint;
begin
  pnt.X := X;
  pnt.Y := Y;
  pnt := ClientToScreen(pnt);
  FPopMenu.Popup(pnt.X, pnt.Y);
end;

procedure TRMQBLink.CMHitTest(var Message: TCMHitTest);
begin
  if PtInRegion(Rgn, Message.XPos, Message.YPos) then
    Message.Result := 1;
end;

function TRMQBLink.ControlAtPos(const Pos: TPoint): TControl;
var
  I: integer;
  scrnP, P: TPoint;
begin
  scrnP := ClientToScreen(Pos);
  for I := Parent.ControlCount - 1 downto 0 do
  begin
    Result := Parent.Controls[I];
    if (Result is TRMQBLink) and (Result <> Self) then
    begin
      with Result do
      begin
        P := Result.ScreenToClient(scrnP);
        if Perform(CM_HITTEST, 0, integer(PointToSmallPoint(P))) <> 0 then
          Exit;
      end;
    end;
  end;
  Result := nil;
end;

procedure TRMQBLink.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_RBUTTONDOWN) or (Message.Msg = WM_LBUTTONDOWN) then
  begin
    if not PtInRegion(Rgn, TWMMouse(Message).XPos, TWMMouse(Message).YPos) then
      ControlAtPos(SmallPointToPoint(TWMMouse(Message).Pos))
    else
      _Click(TWMMouse(Message).XPos, TWMMouse(Message).YPos);
  end;
  inherited WndProc(Message);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMQBArea}

procedure TRMQBArea.CreateParams(var Params: TCreateParams);
begin
  inherited;
  OnDragOver := _DragOver;
  OnDragDrop := _DragDrop;
end;

procedure TRMQBArea.SetOptions(Sender: TObject);
var
  AForm: TRMDFormQBLink;
  ALink: TRMQBLink;
begin
  if TPopupMenu(Sender).Owner is TRMQBLink then
  begin
    ALink := TRMQBLink(TPopupMenu(Sender).Owner);
    AForm := TRMDFormQBLink.Create(Application);
    AForm.txtTable1.Caption := ALink.tbl1.FTableName;
    AForm.txtCol1.Caption := ALink.fldNam1;
    AForm.txtTable2.Caption := ALink.tbl2.FTableName;
    AForm.txtCol2.Caption := ALink.fldNam2;
    AForm.RadioOpt.ItemIndex := ALink.FLinkOpt;
    AForm.RadioType.ItemIndex := ALink.FLinkType;
    if AForm.ShowModal = mrOk then
    begin
      ALink.FLinkOpt := AForm.RadioOpt.ItemIndex;
      ALink.FLinkType := AForm.RadioType.ItemIndex;
    end;
    AForm.Free;
  end;
end;

procedure TRMQBArea.InsertTable(X, Y: Integer);
var
  NewTable: TRMQBTable;
begin
  if FindTable(FForm.lsbTables.Items[FForm.lsbTables.ItemIndex]) <> nil then
  begin
    ShowMessage('This table is already inserted.');
    Exit;
  end;

  NewTable := TRMQBTable.Create(Self);
  NewTable.Parent := Self;
  try
    NewTable.Activate(FForm.lsbTables.Items[FForm.lsbTables.ItemIndex], X, Y);
  except
    NewTable.Free;
  end;
end;

function TRMQBArea.InsertLink(_tbl1, _tbl2: TRMQBTable; _fldN1, _fldN2: Integer): TRMQBLink;
begin
  Result := TRMQBLink.Create(Self);
  with Result do
  begin
    Parent := Self;
    tbl1 := _tbl1;
    tbl2 := _tbl2;
    fldN1 := _fldN1;
    fldN2 := _fldN2;
    fldNam1 := tbl1.FLbx.Items[fldN1];
    fldNam2 := tbl2.FLbx.Items[fldN2];
  end;
  if FindLink(Result) then
  begin
    ShowMessage('These tables are already linked.');
    Result.Free;
    Result := nil;
    Exit;
  end;
  with Result do
  begin
    tbl1.FLbx.Checked[fldN1] := TRUE;
    tbl2.FLbx.Checked[fldN2] := TRUE;
    OnDragOver := _DragOver;
    OnDragDrop := _DragDrop;
  end;
  ReboundLink(Result);
  Result.Visible := True;
end;

function TRMQBArea.FindTable(TableName: string): TRMQBTable;
var
  i: integer;
  TempTable: TRMQBTable;
begin
  Result := nil;
  for i := ControlCount - 1 downto 0 do
  begin
    if Controls[i] is TRMQBTable then
    begin
      TempTable := TRMQBTable(Controls[i]);
      if TempTable.FTableName = TableName then
      begin
        Result := TempTable;
        Exit;
      end;
    end;
  end;
end;

function TRMQBArea.FindLink(Link: TRMQBLink): boolean;
var
  i: integer;
  TempLink: TRMQBLink;
begin
  Result := false;
  for i := ControlCount - 1 downto 0 do
  begin
    if Controls[i] is TRMQBLink then
    begin
      TempLink := TRMQBLink(Controls[i]);
      if TempLink <> Link then
      begin
        if (((TempLink.tbl1 = Link.tbl1) and (TempLink.fldN1 = Link.fldN1)) and
          ((TempLink.tbl2 = Link.tbl2) and (TempLink.fldN2 = Link.fldN2))) or
          (((TempLink.tbl1 = Link.tbl2) and (TempLink.fldN1 = Link.fldN2)) and
          ((TempLink.tbl2 = Link.tbl1) and (TempLink.fldN2 = Link.fldN1))) then
        begin
          Result := true;
          Exit;
        end;
      end;
    end;
  end;
end;

function TRMQBArea.FindOtherLink(Link: TRMQBLink; Tbl: TRMQBTable; FldN: integer): boolean;
var
  i: integer;
  OtherLink: TRMQBLink;
begin
  Result := false;
  for i := ControlCount - 1 downto 0 do
  begin
    if Controls[i] is TRMQBLink then
    begin
      OtherLink := TRMQBLink(Controls[i]);
      if OtherLink <> Link then
      begin
        if ((OtherLink.tbl1 = Tbl) and (OtherLink.fldN1 = FldN)) or
          ((OtherLink.tbl2 = Tbl) and (OtherLink.fldN2 = FldN)) then
        begin
          Result := true;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TRMQBArea.ReboundLink(Link: TRMQBLink);
var
  X1, X2,
    Y1, Y2: integer;
begin
  Link.FPopMenu.Items[0].Caption := Link.tbl1.FTableName + ' :: ' + Link.tbl2.FTableName;
  with Link do
  begin
    if Tbl1 = Tbl2 then
    begin
      X1 := Tbl1.Left + Tbl1.Width;
      X2 := Tbl1.Left + Tbl1.Width + Hand;
    end
    else
    begin
      if Tbl1.Left < Tbl2.Left then
      begin
        if Tbl1.Left + Tbl1.Width + Hand < Tbl2.Left then
        begin //A
          X1 := Tbl1.Left + Tbl1.Width;
          X2 := Tbl2.Left;
          LnkX := 1;
        end
        else
        begin //B
          if Tbl1.Left + Tbl1.Width > Tbl2.Left + Tbl2.Width then
          begin
            X1 := Tbl2.Left + Tbl2.Width;
            X2 := Tbl1.Left + Tbl1.Width + Hand;
            LnkX := 3;
          end
          else
          begin
            X1 := Tbl1.Left + Tbl1.Width;
            X2 := Tbl2.Left + Tbl2.Width + Hand;
            LnkX := 2;
          end;
        end;
      end
      else
      begin
        if Tbl2.Left + Tbl2.Width + Hand > Tbl1.Left then
        begin //C
          if Tbl2.Left + Tbl2.Width > Tbl1.Left + Tbl1.Width then
          begin
            X1 := Tbl1.Left + Tbl1.Width;
            X2 := Tbl2.Left + Tbl2.Width + Hand;
            LnkX := 2;
          end
          else
          begin
            X1 := Tbl2.Left + Tbl2.Width;
            X2 := Tbl1.Left + Tbl1.Width + Hand;
            LnkX := 3;
          end;
        end
        else
        begin //D
          X1 := Tbl2.Left + Tbl2.Width;
          X2 := Tbl1.Left;
          LnkX := 4;
        end;
      end;
    end;

    Y1 := Tbl1.GetRowY(FldN1);
    Y2 := Tbl2.GetRowY(FldN2);
    if Y1 < Y2 then
    begin //M
      Y1 := Tbl1.GetRowY(FldN1) - Hand div 2;
      Y2 := Tbl2.GetRowY(FldN2) + Hand div 2;
      LnkY := 1;
    end
    else
    begin //N
      Y2 := Tbl1.GetRowY(FldN1) + Hand div 2;
      Y1 := Tbl2.GetRowY(FldN2) - Hand div 2;
      LnkY := 2;
    end;
    SetBounds(X1, Y1, X2 - X1, Y2 - Y1);
  end;
end;

procedure TRMQBArea.ReboundLinks4Table(ATable: TRMQBTable);
var
  i: integer;
  Link: TRMQBLink;
begin
  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i] is TRMQBLink then
    begin
      Link := TRMQBLink(Controls[i]);
      if (Link.Tbl1 = ATable) or (Link.Tbl2 = ATable) then
        ReboundLink(Link);
    end;
  end;
end;

procedure TRMQBArea.Unlink(Sender: TObject);
var
  Link: TRMQBLink;
begin
  if TPopupMenu(Sender).Owner is TRMQBLink then
  begin
    Link := TRMQBLink(TPopupMenu(Sender).Owner);
    RemoveControl(Link);
    if not FindOtherLink(Link, Link.tbl1, Link.fldN1) then
    begin
      Link.tbl1.FLbx.Checked[Link.fldN1] := FALSE;
    end;
    if not FindOtherLink(Link, Link.tbl2, Link.fldN2) then
    begin
      Link.tbl2.FLbx.Checked[Link.fldN2] := FALSE;
    end;
    Link.Free;
  end;
end;

procedure TRMQBArea.UnlinkTable(ATable: TRMQBTable);
var
  i: integer;
  TempLink: TRMQBLink;
begin
  for i := ControlCount - 1 downto 0 do
  begin
    if Controls[i] is TRMQBLink then
    begin
      TempLink := TRMQBLink(Controls[i]);
      if (TempLink.Tbl1 = ATable) or (TempLink.Tbl2 = ATable) then
      begin
        RemoveControl(TempLink);
        if not FindOtherLink(TempLink, TempLink.tbl1, TempLink.fldN1) then
        begin
          TempLink.tbl1.FLbx.Checked[TempLink.fldN1] := FALSE;
        end;
        if not FindOtherLink(TempLink, TempLink.tbl2, TempLink.fldN2) then
        begin
          TempLink.tbl2.FLbx.Checked[TempLink.fldN2] := FALSE;
        end;
        TempLink.Free;
      end;
    end;
  end;
end;

procedure TRMQBArea._DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source = FForm.lsbTables) then
    Accept := true;
end;

procedure TRMQBArea._DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if not (Sender is TRMQBArea) then
  begin
    X := X + TControl(Sender).Left;
    Y := Y + TControl(Sender).Top;
  end;
  if Source = FForm.lsbTables then
    InsertTable(X, Y);
end;

type
  THackRMDQuery = class(TRMDQuery)
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  {TRMQueryPropForm}

procedure TRMDQueryDesignerForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  //  Caption := FQuery.DataSet.Name + ' ' + RMLoadStr(SParams);
  RMSetStrProp(TabSheetFields, 'Caption', rmRes + 3080);
  RMSetStrProp(TabSheetCalc, 'Caption', rmRes + 3081);
  RMSetStrProp(TabSheetGroup, 'Caption', rmRes + 3082);
  RMSetStrProp(TabSheetSort, 'Caption', rmRes + 3083);
  RMSetStrProp(Label7, 'Caption', rmRes + 3084);
  RMSetStrProp(FieldsB, 'Caption', rmRes + 3085);
  RMSetStrProp(ParamsB, 'Caption', rmRes + 3086);
  RMSetStrProp(btnNew, 'Hint', rmRes + 3087);
  RMSetStrProp(btnLoadFromFile, 'Hint', rmRes + 3088);
  RMSetStrProp(btnSaveToFile, 'Hint', rmRes + 3089);
  RMSetStrProp(lsvSortRight.Columns[0], 'Caption', rmRes + 3090);
  RMSetStrProp(lsvSortRight.Columns[1], 'Caption', rmRes + 3091);
  RMSetStrProp(OpenDialog1, 'Filter', rmRes + 3092);
  RMSetStrProp(SaveDialog1, 'Filter', rmRes + 3092);
  RMSetStrProp(padModifySQL, 'Caption', rmRes + 3093);
  RMSetStrProp(btnModifySQL, 'Caption', rmRes + 3093);

  btnOK.Hint := RMLoadStr(SOK);
  btnCancel.Hint := RMLoadStr(SCancel);
end;

procedure TRMDQueryDesignerForm.ClearAll;
var
  i: integer;
begin
  FFieldListView.Items.Clear;
  FCalcListView.Items.Clear;
  lstGroupLeft.Items.Clear;
  lstGroupRight.Items.Clear;
  lstSortLeft.Items.Clear;
  lsvSortRight.Items.Clear;
  for i := QBArea.ControlCount - 1 downto 0 do
    QBArea.Controls[i].Free;
end;

procedure TRMDQueryDesignerForm.SaveVisualSQL;
var
  i, j: integer;
  s: string;
  TempTable: TRMQBTable;
  TempLink: TRMQBLink;
begin
  FQuery.VisualSQL.Clear;
  if not FQuery.UseSQLBuilder then Exit;

  FQuery.VisualSQL.Add('[Tables]'); // save tables
  for i := 0 to QBArea.ControlCount - 1 do
  begin
    if QBArea.Controls[i] is TRMQBTable then
    begin
      TempTable := TRMQBTable(QBArea.Controls[i]);
      s := Format('%s,%d,%d', [TempTable.FTableName, TempTable.Top + QBArea.VertScrollBar.ScrollPos,
        TempTable.Left + QBArea.HorzScrollBar.ScrollPos]);
      for j := 0 to TempTable.FLbx.Items.Count - 1 do
      begin
        if TempTable.FLbx.Checked[j] then
          s := s + ',1'
        else
          s := s + ',0';
      end;
      FQuery.VisualSQL.Add(s + ';');
    end;
  end;

  FQuery.VisualSQL.Add('[Links]'); // save links
  for i := 0 to QBArea.ControlCount - 1 do
  begin
    if QBArea.Controls[i] is TRMQBLink then
    begin
      TempLink := TRMQBLink(QBArea.Controls[i]);
      s := Format('%s,%d,%s,%d,%d,%d', [TempLink.Tbl1.FTableName, TempLink.FldN1,
        TempLink.Tbl2.FTableName, TempLink.FldN2, TempLink.FLinkOpt, TempLink.FLinkType]);
      FQuery.VisualSQL.Add(s + ';');
    end;
  end;

  FQuery.VisualSQL.Add('[Fields]'); // save fields
  for i := 0 to FFieldListView.Items.Count - 1 do
  begin
    s := FFieldListView.Items[i].Caption + ',' + FFieldListView.Items[i].SubItems[0];
    FQuery.VisualSQL.Add(s + ';');
  end;

  FQuery.VisualSQL.Add('[Calc Fields]'); // save calc fields
  for i := 0 to FCalcListView.Items.Count - 1 do
  begin
    s := Format('%s,%s,%s,%s,%s', [FCalcListView.Items[i].Caption, FCalcListView.Items[i].SubItems[0],
      FCalcListView.Items[i].SubItems[1], FCalcListView.Items[i].SubItems[2], FCalcListView.Items[i].SubItems[3]]);
    FQuery.VisualSQL.Add(s + ';');
  end;

  FQuery.VisualSQL.Add('[Groups]'); // save groups
  for i := 0 to lstGroupRight.Items.Count - 1 do
  begin
    FQuery.VisualSQL.Add(lstGroupRight.Items[i] + ';');
  end;

  FQuery.VisualSQL.Add('[Sorts]'); // save sorts
  for i := 0 to lsvSortRight.Items.Count - 1 do
  begin
    s := lsvSortRight.Items[i].Caption + ',' + lsvSortRight.Items[i].SubItems[0];
    FQuery.VisualSQL.Add(s + ';');
  end;
end;

procedure TRMDQueryDesignerForm.DecodeVisualSQL;
var
  i, ii, j: integer;
  s, ss: string;
  NewTable: TRMQBTable;
  TableName: string;
  X, Y: integer;
  NewLink: TRMQBLink;
  Table1, Table2: TRMQBTable;
  FieldN1, FieldN2: integer;

  function GetNextVal(var s: string): string;
  var
    p: integer;
  begin
    Result := EmptyStr;
    p := Pos(',', s);
    if p = 0 then
    begin
      p := Pos(';', s);
      if p = 0 then
        Exit;
    end;
    Result := System.Copy(s, 1, p - 1);
    System.Delete(s, 1, p);
  end;

begin
  ClearAll;
  j := -1;
  for i := 0 to FQuery.VisualSQL.Count - 1 do
  begin
    if FQuery.VisualSQL[i] = '[Tables]' then
    begin
      j := i + 1;
      Break;
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read tables
    begin
      if FQuery.VisualSQL[i] = '[Links]' then
      begin
        j := i + 1;
        Break;
      end;
      s := FQuery.VisualSQL[i];
      TableName := GetNextVal(s);
      Y := StrToInt(GetNextVal(s));
      X := StrToInt(GetNextVal(s));
      NewTable := TRMQBTable.Create(QBArea);
      NewTable.Parent := QBArea;
      try
        NewTable.Activate(TableName, X, Y);
        NewTable.FLbx.FLoading := true;
        for ii := 0 to NewTable.FLbx.Items.Count - 1 do
        begin
          ss := GetNextVal(s);
          if ss <> EmptyStr then
          begin
            NewTable.FLbx.Checked[ii] := boolean(StrToInt(ss));
          end;
        end;
        NewTable.FLbx.FLoading := false;
      except
        NewTable.Free;
      end;
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read links
    begin
      if FQuery.VisualSQL[i] = '[Fields]' then
      begin
        j := i + 1;
        Break;
      end;
      s := FQuery.VisualSQL[i];
      Table1 := QBArea.FindTable(GetNextVal(s));
      FieldN1 := StrToInt(GetNextVal(s));
      Table2 := QBArea.FindTable(GetNextVal(s));
      FieldN2 := StrToInt(GetNextVal(s));
      NewLink := QBArea.InsertLink(Table1, Table2, FieldN1, FieldN2);
      NewLink.FLinkOpt := StrToInt(GetNextVal(s));
      NewLink.FLinkType := StrToInt(GetNextVal(s));
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read fields
    begin
      if FQuery.VisualSQL[i] = '[Calc Fields]' then
      begin
        j := i + 1;
        Break;
      end;
      s := FQuery.VisualSQL[i];
      with FFieldListView.Items.Add do
      begin
        Caption := GetNextVal(s);
        SubItems.Add(GetNextVal(s));
      end;
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read calc fields
    begin
      if FQuery.VisualSQL[i] = '[Groups]' then
      begin
        j := i + 1;
        Break;
      end;
      s := FQuery.VisualSQL[i];
      with FCalcListView.Items.Add do
      begin
        Caption := GetNextVal(s);
        SubItems.Add(GetNextVal(s));
        SubItems.Add(GetNextVal(s));
        SubItems.Add(GetNextVal(s));
        SubItems.Add(GetNextVal(s));
      end;
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read group
    begin
      if FQuery.VisualSQL[i] = '[Sorts]' then
      begin
        j := i + 1;
        Break;
      end;
      s := FQuery.VisualSQL[i];
      lstGroupRight.Items.Add(GetNextVal(s));
    end;
  end;

  if j >= 0 then
  begin
    for i := j to FQuery.VisualSQL.Count - 1 do // read sorts
    begin
      s := FQuery.VisualSQL[i];
      with lsvSortRight.Items.Add do
      begin
        Caption := GetNextVal(s);
        SubItems.Add(GetNextVal(s));
      end;
    end;
  end;
end;

procedure TRMDQueryDesignerForm.SetEditSQLAsText;
begin
  if FQuery.UseSQLBuilder then
  begin
    TabSheetFields.TabVisible := TRUE;
    TabSheetCalc.TabVisible := TRUE;
    TabSheetGroup.TabVisible := TRUE;
    TabSheetSort.TabVisible := TRUE;
    SQLMemo.PopupMenu := pmnSQLMemo;
    SQLMemo.Color := clBtnFace;
  end
  else
  begin
    TabSheetFields.TabVisible := FALSE;
    TabSheetCalc.TabVisible := FALSE;
    TabSheetGroup.TabVisible := FALSE;
    TabSheetSort.TabVisible := FALSE;
    SQLMemo.PopupMenu := nil;
    SQLMemo.Color := clWindow;
  end;
  SQLMemo.ReadOnly := FQuery.UseSQLBuilder;
end;

procedure TRMDQueryDesignerForm.SetQuery(Value: TRMDQuery);
begin
  FQuery := Value;
  FSaveSQL := FQuery.SQL;
  FSaveDatabase := FQuery.DatabaseName;
  FSaveEditSQLAsText := FQuery.UseSQLBuilder;
  FSaveVisualSQL.Assign(FQuery.VisualSQL);
  cmbDatabase.Enabled := False; //Value.CanChangeDatabase;
  if (FQuery.SQL <> '') and (FQuery.VisualSQL.Text = '') then
    FQuery.UseSQLBuilder := False;

  THackRMDQuery(FQuery).GetDatabases(cmbDatabase.Items);
  cmbDatabase.ItemIndex := cmbDatabase.Items.IndexOf(FQuery.DatabaseName);
  if cmbDatabase.ItemIndex < 0 then
    cmbDatabase.ItemIndex := 0;
  cmbDatabaseChange(nil);

  SetEditSQLAsText;
  if FQuery.UseSQLBuilder then
    DecodeVisualSQL
  else
    SQLMemo.Lines.Text := Value.SQL;
end;

procedure TRMDQueryDesignerForm.ApplySettings;
begin
  Query.DatabaseName := cmbDatabase.Text;
  Query.SQL := SQLMemo.Lines.Text;
  SaveVisualSQL;
end;

procedure TRMDQueryDesignerForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrCancel then
  begin
    Query.SQL := FSaveSQL;
    Query.DatabaseName := FSaveDatabase;
    Query.VisualSQL.Assign(FSaveVisualSQL);
    Query.UseSQLBuilder := FSaveEditSQLAsText;
  end;
end;

procedure TRMDQueryDesignerForm.FormDestroy(Sender: TObject);
begin
  FSaveVisualSQL.Free;
end;

procedure TRMDQueryDesignerForm.FieldsBClick(Sender: TObject);
var
  FieldsEditorForm: TRMDFieldsEditorForm;
begin
  ApplySettings;
  FieldsEditorForm := TRMDFieldsEditorForm.Create(nil);
  with FieldsEditorForm do
  begin
    Dataset := Query.DataSet;
    ShowModal;
    Free;
  end;
end;

procedure TRMDQueryDesignerForm.ParamsBClick(Sender: TObject);
var
  ParamsForm: TRMDParamsForm;
begin
  ApplySettings;
  //  if Assigned(Query.OnSQLTextChanged) then Query.OnSQLTextChanged(nil);
  if Query.ParamCount = 0 then
    Exit;
  ParamsForm := TRMDParamsForm.Create(nil);
  with ParamsForm do
  begin
    Query := Self.Query;
    Caption := Query.Name + ' ' + RMLoadStr(SParams);
    ShowModal;
    Free;
  end;
end;

procedure TRMDQueryDesignerForm.FormCreate(Sender: TObject);
begin
  Localize;

  {$IFDEF USE_SYNEDIT}
  FSynSQLSyn := TSynSQLSyn.Create(Self);
  {$ENDIF}
  SQLMemo := TRMSynEditor.Create(Self);
  with SQLMemo do
  begin
    Parent := tabSheetSQL;
    {$IFDEF USE_SYNEDIT}
    Highlighter := FSynSQLSyn;
    Gutter.ShowLineNumbers := True;
    {$ENDIF}
    SetHighLighter(rmhlSQL);
    ScrollBars := ssBoth;
    Font.Name := 'Courier New';
    Font.Size := 10;
    Align := alClient;
    Font.Charset := DEFAULT_CHARSET;
    SetGutterWidth(20);
    SetGroupUndo(True);
    SetUndoAfterSave(False);
  end;

  FForm := Self;
  pgcDesigner.ActivePage := TabSheetFields;
  FSaveVisualSQL := TStringList.Create;

  QBArea := TRMQBArea.Create(Self);
  QBArea.Parent := Panel2;
  QBArea.Align := alClient;

  FFieldListView := TRMQBFieldListView.Create(Self);
  FFieldListView.Parent := TabSheetFields;
  FFieldListView.Align := alClient;
  FFieldListView.SmallImages := ImageList1;

  FCalcListView := TRMQBCalcListView.Create(Self);
  FCalcListView.Parent := TabSheetCalc;
  FCalcListView.Align := alClient;
  FCalcListView.SmallImages := ImageList1;
  cmbCalc.BringToFront;
  edtExpr.BringToFront;
end;

procedure TRMDQueryDesignerForm.lsbTablesDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TListBox(Control) do
  begin
    Canvas.FillRect(ARect);
    Canvas.BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clGreen);
    Canvas.TextOut(ARect.Left + 20, ARect.Top + 1, Items[Index]);
  end;
end;

procedure TRMDQueryDesignerForm.cmbCalcChange(Sender: TObject);
begin
  if cmbCalc.ItemIndex >= 0 then
  begin
    FCalcListView.Selected.SubItems[2] := cmbCalc.Items[cmbCalc.ItemIndex];
  end;
end;

procedure TRMDQueryDesignerForm.edtExprKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    FCalcListView.Selected.SubItems[3] := edtExpr.Text;
end;

procedure TRMDQueryDesignerForm.edtExprExit(Sender: TObject);
begin
  FCalcListView.Selected.SubItems[3] := edtExpr.Text;
end;

procedure TRMDQueryDesignerForm.pgcDesignerChange(Sender: TObject);
var
  tmp: TRMSQL;
  i: integer;
begin
  if pgcDesigner.ActivePage = tabSheetGroup then
  begin
    lstGroupLeft.Items.Clear;
    for i := 0 to FFieldListView.Items.Count - 1 do
      lstGroupLeft.Items.Add(FFieldListView.Items[i].SubItems[0]);
    for i := 0 to FCalcListView.Items.Count - 1 do
      lstGroupLeft.Items.Add(FCalcListView.Items[i].Caption);
  end
  else if pgcDesigner.ActivePage = tabSheetSort then
  begin
    lstSortLeft.Items.Clear;
    for i := 0 to FFieldListView.Items.Count - 1 do
      lstSortLeft.Items.Add(FFieldListView.Items[i].SubItems[0]);
    for i := 0 to FCalcListView.Items.Count - 1 do
      lstSortLeft.Items.Add(FCalcListView.Items[i].Caption);
  end
  else if (pgcDesigner.ActivePage = tabSheetSQL) and FQuery.UseSQLBuilder then
  begin
    tmp := TRMSQL.Create;
    tmp.Encode;
    tmp.Free;
  end;
end;

procedure TRMDQueryDesignerForm.TabSheetGroupResize(Sender: TObject);
begin
  pnlGroupLeft.Width := (tabSheetGroup.Width - Panel5.Width) div 2;
  panel15.Width := (Panel8.Width - Panel17.Width) div 2;
end;

procedure TRMDQueryDesignerForm.TabSheetSortResize(Sender: TObject);
begin
  pnlSortLeft.Width := (tabSheetSort.Width - Panel10.Width) div 2;
  panel4.Width := (Panel12.Width - Panel14.Width) div 2;
end;

procedure TRMDQueryDesignerForm.lstGroupLeftDblClick(Sender: TObject);
begin
  if lstGroupLeft.ItemIndex >= 0 then
  begin
    lstGroupRight.Items.Add(lstGroupLeft.Items[lstGroupLeft.ItemIndex]);
    lstGroupLeft.Items.Delete(lstGroupLeft.ItemIndex);
  end;
end;

procedure TRMDQueryDesignerForm.lstGroupRightDblClick(Sender: TObject);
begin
  if lstGroupRight.ItemIndex >= 0 then
  begin
    lstGroupLeft.Items.Add(lstGroupRight.Items[lstGroupRight.ItemIndex]);
    lstGroupRight.Items.Delete(lstGroupRight.ItemIndex);
  end;
end;

procedure TRMDQueryDesignerForm.lstSortLeftDblClick(Sender: TObject);
begin
  if lstSortLeft.ItemIndex >= 0 then
  begin
    with lsvSortRight.Items.Add do
    begin
      Caption := lstSortLeft.Items[lstSortLeft.ItemIndex];
      SubItems.Add('');
    end;
    lstSortLeft.Items.Delete(lstSortLeft.ItemIndex);
  end;
end;

procedure TRMDQueryDesignerForm.lsvSortRightDblClick(Sender: TObject);
begin
  if lsvSortRight.Selected <> nil then
  begin
    lstSortLeft.Items.Add(lsvSortRight.Selected.Caption);
    lsvSortRight.Items.Delete(lsvSortRight.Selected.Index);
  end;
end;

procedure TRMDQueryDesignerForm.btnSortAscClick(Sender: TObject);
begin
  if lsvSortRight.Selected <> nil then
  begin
    lsvSortRight.Selected.SubItems[0] := '';
  end;
end;

procedure TRMDQueryDesignerForm.btnSortDecClick(Sender: TObject);
begin
  if lsvSortRight.Selected <> nil then
  begin
    lsvSortRight.Selected.SubItems[0] := '½µÐò';
  end;
end;

procedure TRMDQueryDesignerForm.SpeedButton6Click(Sender: TObject);
var
  newItem, item: TListItem;
begin
  if (lsvSortRight.Selected <> nil) and (lsvSortRight.Selected.Index > 0) then
  begin
    lsvSortRight.Items.BeginUpdate;
    try
      item := lsvSortRight.Selected;
      newItem := lsvSortRight.Items.Insert(item.Index - 1);
      with newItem do
      begin
        caption := item.Caption;
        SubItems.Assign(item.SubItems);
      end;
      lsvSortRight.Items.Delete(item.Index);
      lsvSortRight.Selected := newItem;

      while (lsvSortRight.VisibleRowCount > 0) and ((newItem.Index - (lsvSortRight.TopItem.Index)) < 0) do
        lsvSortRight.Scroll(0, -10);
    finally
      lsvSortRight.Items.EndUpdate;
    end;
  end;
end;

procedure TRMDQueryDesignerForm.SpeedButton5Click(Sender: TObject);
var
  newItem: TListItem;
  aCaption, aAsc: string;
  aIndex: integer;
begin
  if (lsvSortRight.Selected <> nil) and (lsvSortRight.Selected.Index < lsvSortRight.Items.Count - 1) then
  begin
    lsvSortRight.Items.BeginUpdate;
    try
      aCaption := lsvSortRight.Selected.Caption;
      aAsc := lsvSortRight.Selected.SubItems[0];
      aIndex := lsvSortRight.Selected.Index + 1;
      lsvSortRight.Items.Delete(lsvSortRight.Selected.Index);
      newItem := lsvSortRight.Items.Insert(aIndex);
      with newItem do
      begin
        caption := aCaption;
        SubItems.Add(aAsc);
      end;
      lsvSortRight.Selected := newItem;

      while (lsvSortRight.VisibleRowCount > 0) and ((newItem.Index - (lsvSortRight.TopItem.Index)) >= lsvSortRight.VisibleRowCount) do
        lsvSortRight.Scroll(0, 10);
    finally
      lsvSortRight.Items.EndUpdate;
    end;
  end;
end;

procedure TRMDQueryDesignerForm.SpeedButton2Click(Sender: TObject);
begin
  if lstGroupRight.ItemIndex > 0 then
  begin
    lstGroupRight.Items.Exchange(lstGroupRight.ItemIndex, lstGroupRight.ItemIndex - 1);
  end;
end;

procedure TRMDQueryDesignerForm.SpeedButton1Click(Sender: TObject);
begin
  if (lstGroupRight.ItemIndex >= 0) and (lstGroupRight.ItemIndex < lstGroupRight.Items.Count - 1) then
  begin
    lstGroupRight.Items.Exchange(lstGroupRight.ItemIndex, lstGroupRight.ItemIndex + 1);
  end;
end;

procedure TRMDQueryDesignerForm.padModifySQLClick(Sender: TObject);
begin
  FQuery.UseSQLBuilder := False;
  SetEditSQLAsText;
  SQLMemo.SetFocus;
end;

procedure TRMDQueryDesignerForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRMDQueryDesignerForm.btnLoadFromFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if OpenDialog1.FilterIndex = 1 then
    begin
      FQuery.UseSQLBuilder := True;
      SetEditSQLAsText;
      SQLMemo.Lines.LoadFromFile(OpenDialog1.FileName);
    end
    else
    begin
      FQuery.UseSQLBuilder := False;
      SetEditSQLAsText;
      FQuery.VisualSQL.LoadFromFile(OpenDialog1.FileName);
      DecodeVisualSQL;
    end;
  end
end;

procedure TRMDQueryDesignerForm.btnSaveToFileClick(Sender: TObject);
var
  tmp: TRMSQL;
begin
  if SaveDialog1.Execute then
  begin
    if OpenDialog1.FilterIndex = 1 then
    begin
      if pgcDesigner.ActivePage <> tabSheetSQL then
      begin
        tmp := TRMSQL.Create;
        tmp.Encode;
        tmp.Free;
      end;
      SQLMemo.Lines.SaveToFile(SaveDialog1.FileName);
    end
    else
    begin
      SaveVisualSQL;
      FQuery.VisualSQL.SaveToFile(SaveDialog1.FileName);
    end;
  end;
end;

procedure TRMDQueryDesignerForm.btnOKClick(Sender: TObject);
var
  tmp: TRMSQL;
begin
  if pgcDesigner.ActivePage <> tabSheetSQL then
  begin
    tmp := TRMSQL.Create;
    tmp.Encode;
    tmp.Free;
  end;

  ApplySettings;
  try
    if Assigned(Query.OnSQLTextChanged) then
      Query.OnSQLTextChanged(nil);
    Query.DataSet.FieldDefs.Update;
    ModalResult := mrOK;
  except
    on E: exception do
    begin
      MessageBox(0, PChar(E.Message), PChar(RMLoadStr(SError)),
        mb_Ok + mb_IconError);
      //      MessageBox(0, PChar(RMLoadStr(SQueryError)), PChar(RMLoadStr(SError)),
      //        mb_Ok + mb_IconError);
      ModalResult := mrNone;
    end;
  end;
end;

procedure TRMDQueryDesignerForm.Panel18Resize(Sender: TObject);
begin
  cmbDatabase.Width := Panel18.ClientWidth;
end;

procedure TRMDQueryDesignerForm.lsbTablesDblClick(Sender: TObject);
begin
  QBArea.InsertTable(0, 0);
end;

procedure TRMDQueryDesignerForm.cmbDatabaseChange(Sender: TObject);
begin
  ClearAll;
  THackRMDQuery(FQuery).GetTableNames(cmbDatabase.Text, lsbTables.Items);
end;

procedure TRMDQueryDesignerForm.btnNewClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(RMLoadStr(rmRes + 3094)), PChar(RMLoadStr(SConfirm)), MB_ICONQUESTION + MB_YESNO) = ID_YES then
  begin
    ClearAll;
    SQLMemo.Lines.Clear;
  end;
end;

end.

