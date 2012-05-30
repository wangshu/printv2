unit RM_Cross;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, DB, Buttons, RM_Common, RM_Class, RM_DataSet
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMCrossObject = class(TComponent)
  end;

  TIntArrayCell = array[0..0] of Integer;
  PIntArrayCell = ^TIntArrayCell;

  { TRMQuickIntarray }
  TRMQuickIntArray = class
  private
    arr: PIntArrayCell;
    len: Integer;
    function GetCell(Index: Integer): Integer;
    procedure SetCell(Index: Integer; const Value: Integer);
  public
    constructor Create(Length: Integer);
    destructor Destroy; override;
    property Cell[Index: Integer]: Integer read GetCell write SetCell; default;
  end;

  { TRMArray }
  TRMArray = class(TObject)
  private
    FFlag_Insert: Boolean;
    FInsertPos: Integer;
    FSortColHeader, FSortRowHeader: Boolean;
    FRows: TStringList;
    FColumns: TStringList;
    FCellItemsCount: Integer;
    FReport: TRMReport;

    function GetCell(const Row, Col: string; Index3: Integer): Variant;
    procedure SetCell(const aRow, aCol: string; aIndex3: Integer; aValue: Variant);
    function GetCellByIndex(Row, Col, Index3: Integer): Variant;
    function GetCellArray(Row, Col: Integer): Variant;
    procedure SetCellArray(Row, Col: Integer; Value: Variant);
    procedure SetSortColHeader(Value: Boolean);
    procedure SetSortRowHeader(Value: Boolean);
  public
    constructor Create(CellItemsCount: Integer; aReport: TRMReport);
    destructor Destroy; override;
    procedure Clear;
    property Columns: TStringList read FColumns;
    property Rows: TStringList read FRows;
    property CellItemsCount: Integer read FCellItemsCount;
    property Cell[const Row, Col: string; Index3: Integer]: Variant read GetCell write SetCell;
    property CellByIndex[Row, Col, Index3: Integer]: Variant read GetCellByIndex;
    property CellArray[Row, Col: Integer]: Variant read GetCellArray write SetCellArray;
    property SortColHeader: Boolean read FSortColHeader write SetSortColHeader;
    property SortRowHeader: Boolean read FSortRowHeader write SetSortRowHeader;
  end;

  { TRMCrossArray }
  TRMCrossArray = class(TRMArray)
  private
    FRMDataset: TRMDataset;
    FRowFields, FColFields, FCellFields: TStringList;
    FRowTypes, FColTypes: array[0..31] of Variant;
    FTopLeftSize: TSize;
    FHeaderString: string;
    FRowTotalString: string;
    FRowGrandTotalString: string;
    FColumnTotalString: string;
    FColumnGrandTotalString: string;
    FAddColumnsHeader: TStrings;

    function GetIsTotalRow(Index: Integer): Boolean;
    function GetIsTotalColumn(Index: Integer): Boolean;
  public
    DoDataCol: Boolean;
    ShowRowNo: Boolean;
    DataStr: string;

    constructor Create(aReport: TRMReport; DS: TRMDataset; RowFields, ColFields, CellFields: string);
    destructor Destroy; override;
    procedure Build;
    property HeaderString: string read FHeaderString write FHeaderString;
    property RowTotalString: string read FRowTotalString write FRowTotalString;
    property RowGrandTotalString: string read FRowGrandTotalString write FRowGrandTotalString;
    property ColumnTotalString: string read FColumnTotalString write FColumnTotalString;
    property ColumnGrandTotalString: string read FColumnGrandTotalString write FColumnGrandTotalString;
    property TopLeftSize: TSize read FTopLeftSize;
    property IsTotalRow[Index: Integer]: Boolean read GetIsTotalRow;
    property IsTotalColumn[Index: Integer]: Boolean read GetIsTotalColumn;
  end;

  { TRMCrossView }
  TRMCrossView = class(TRMReportView)
  private
    FDataHeight, FDataWidth: Integer;
    FHeaderHeight, FHeaderWidth: string;
    FCrossArray: TRMCrossArray;
    FColumnWidths: TRMQuickIntArray;
    FColumnHeights: TRMQuickIntArray;
    FLastTotalCol: TRMQuickIntArray;
    FFlag: Boolean;
    FSkip: Boolean;
    FRowDataSet: TRMUserDataset;
    FColumnDataSet: TRMUserDataset;
    FRepeatCaptions: Boolean;
    FInternalFrame: Boolean;
    FShowHeader: Boolean;
    FDefDY: Integer;
    FLastX: Integer;
    FMaxGTHeight, FMaxCellHeight: Integer;
    FMaxString: string;
    FDictionary: TStrings;
    FAddColumnsHeader: TStrings;
    FRowNoHeader: string;

    FSavedOnBeforePrint: TRMOnBeforePrintEvent;
    FSavedOnPrintColumn: TRMPrintColumnEvent;

    function OneObject(aPage: TRMReportPage; Name1, Name2: string): TRMMemoView;
    function ParentPage: TRMReportPage;
    procedure CreateObjects;
    procedure CalcWidths;
    procedure MakeBands;
    procedure OnReportPrintColumnEvent(aColNo: Integer; var aWidth: Integer);
    procedure OnReportBeforePrintEvent(aMemo: TWideStringList; aView: TRMReportView);

    function GetShowRowTotal: Boolean;
    procedure SetShowRowTotal(Value: Boolean);
    function GetShowColTotal: Boolean;
    procedure SetShowColTotal(Value: Boolean);
    function GetShowIndicator: Boolean;
    procedure SetShowIndicator(Value: Boolean);
    function GetSortColHeader: Boolean;
    procedure SetSortColHeader(Value: Boolean);
    function GetSortRowHeader: Boolean;
    procedure SetSortRowHeader(Value: Boolean);
    function GetMergeRowHeader: Boolean;
    procedure SetMergeRowHeader(Value: Boolean);
    function GetShowRowNo: Boolean;
    procedure SetShowRowNo(Value: Boolean);

    function GetInternalFrame: Boolean;
    procedure SetInternalFrame(Value: Boolean);
    function GetRepeatCaptions: Boolean;
    procedure SetRepeatCaptions(Value: Boolean);
    function GetDataWidth: Integer;
    procedure SetDataWidth(Value: Integer);
    function GetDataHeight: Integer;
    procedure SetDataHeight(Value: Integer);
    function GetHeaderWidth: string;
    procedure SetHeaderWidth(Value: string);
    function GetHeaderHeight: string;
    procedure SetHeaderHeight(Value: string);
    function GetRowNoHeader: string;
    procedure SetRowNoHeader(Value: string);

    function GetDictName(aStr: string): string;
    function GetDataCellText: string;

    function GetHeaderHeightByIndex(aIndex: Integer): Integer;
    function GetHeaderWidthByIndex(aIndex: Integer): Integer;

    procedure OnColumnDataSetFirstEvent(Sender: TObject);
  protected
    procedure Prepare; override;
    procedure UnPrepare; override;
    function IsCrossView: Boolean; override;
  public
    class function CanPlaceOnGridView: Boolean; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;

    property RowDataSet: TRMUserDataset read FRowDataSet;
    property ColumnDataSet: TRMUserDataset read FColumnDataSet;
  published
    property InternalFrame: Boolean read GetInternalFrame write SetInternalFrame;
    property RepeatCaptions: Boolean read GetRepeatCaptions write SetRepeatCaptions;
    property DataWidth: Integer read GetDataWidth write SetDataWidth;
    property DataHeight: Integer read GetDataHeight write SetDataHeight;
    property HeaderWidth: string read GetHeaderWidth write SetHeaderWidth;
    property HeaderHeight: string read GetHeaderHeight write SetHeaderHeight;
    property RowNoHeader: string read GetRowNoHeader write SetRowNoHeader;
    property ShowRowTotal: Boolean read GetShowRowTotal write SetShowRowTotal;
    property ShowColumnTotal: Boolean read GetShowColTotal write SetShowColTotal;
    property ShowIndicator: Boolean read GetShowIndicator write SetShowIndicator;
    property SortColHeader: Boolean read GetSortColHeader write SetSortColHeader;
    property SortRowHeader: Boolean read GetSortRowHeader write SetSortRowHeader;
    property MergeRowHeader: Boolean read GetMergeRowHeader write SetMergeRowHeader;
    property ShowRowNo: Boolean read GetShowRowNo write SetShowRowNo;

    property Dictionary: TStrings read FDictionary write FDictionary;
    property AddColumnHeader: TStrings read FAddColumnsHeader write FAddColumnsHeader;
  end;

  { TRMCrossForm }
  TRMCrossForm = class(TForm)
    GroupBox1: TGroupBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    Shape1: TShape;
    Shape2: TShape;
    GroupBox2: TGroupBox;
    DatasetsLB: TComboBox;
    FieldsLB: TListBox;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    ComboBox2: TComboBox;
    CheckBox1: TCheckBox;
    btnExchange: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure DatasetsLBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ListBox3Enter(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ListBox3Click(Sender: TObject);
    procedure ListBox4Click(Sender: TObject);
    procedure ComboBox2Click(Sender: TObject);
    procedure ListBox4DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure FieldsLBDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FieldsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBox3DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExchangeClick(Sender: TObject);
    procedure ListBox3KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FListBox: TListBox;
    FBusy: Boolean;
    DrawPanel: TPanel;
    procedure FillDatasetsLB;
    procedure Localize;
    procedure ClearSelection(Sender: TObject);
  public
    { Public declarations }
    Cross: TRMCrossView;
  end;

implementation

{$R *.DFM}

uses
  RM_Const, RM_Utils, RM_Insp, RM_PropInsp, RM_EditorStrings;

const
  flCrossShowRowTotal = $2;
  flCrossShowColTotal = $4;
  flCrossShowIndicator = $8;
  flCrossSortColHeader = $10;
  flCrossSortRowHeader = $20;
  flCrossMergeRowHeader = $40;
  flCrossShowRowNo = $80;

type
  PRMArrayCell = ^TRMArrayCell;
  TRMArrayCell = record
    Items: Variant;
  end;

  { TRMCrossGroupItem }
  TRMCrossGroupItem = class(TObject)
  private
    Parent: TRMCrossArray;
    FArray: Variant;
    FCellItemsCount: Integer;
    FGroupName: TStringList;
    FIndex: Integer;
    FCount: TRMQuickIntArray;
    FStartFrom: Integer;
    procedure Reset(NewGroupName: string; StartFrom: Integer);
    procedure AddValue(Value: Variant);
    function IsBreak(GroupName: string): Boolean;
    procedure CheckAvg;
    property Value: Variant read FArray;
  public
    constructor Create(AParent: TRMCrossArray; GroupName: string; Index, CellItemsCount: Integer);
    destructor Destroy; override;
  end;

  { TRMCrossList }
  TRMCrossList = class
  private
    FList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(v: TRMCrossView);
    procedure Delete(v: TRMCrossView);
  end;

  { TDrawPanel }
  TDrawPanel = class(TPanel)
  private
    FColumnFields: TStrings;
    FRowFields: TStrings;
    FCellFields: TStrings;
    LastX, LastY, DefDx, DefDy: Integer;
    procedure Draw(x, y, dx, dy: Integer; aStr: string);
    procedure DrawColumnCells;
    procedure DrawRowCells;
    procedure DrawCellField;
    procedure DrawBorderLines(pos: byte);
  public
    procedure Paint; override;
  end;

var
  FCrossList: TRMCrossList;

function RMCrossList: TRMCrossList;
begin
  if FCrossList = nil then
  begin
    FCrossList := TRMCrossList.Create;
  end;
  Result := FCrossList;
end;

function HasTotal(s: string): Boolean;
begin
  Result := Pos('+', s) <> 0;
end;

function FuncName(s: string): string;
begin
  if HasTotal(s) then
  begin
    Result := LowerCase(Copy(s, Pos('+', s) + 1, 255));
    if Result = '' then
      Result := 'sum';
  end
  else
    Result := '';
end;

function _PureName(s: string): string;
begin
  if HasTotal(s) then
    Result := Copy(s, 1, Pos('+', s) - 1)
  else
    Result := s;
end;

function CharCount(ch: Char; s: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
  begin
    if s[i] = ch then
      Inc(Result);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCrossGroupItem }

constructor TRMCrossGroupItem.Create(AParent: TRMCrossArray; GroupName: string;
  Index, CellItemsCount: Integer);
begin
  inherited Create;
  Parent := AParent;
  FCellItemsCount := CellItemsCount;
  FArray := VarArrayCreate([0, CellItemsCount - 1], varVariant);
  FCount := TRMQuickIntArray.Create(CellItemsCount);
  FGroupName := TStringList.Create;
  FIndex := Index;
  Reset(GroupName, 0);
end;

destructor TRMCrossGroupItem.Destroy;
begin
  FGroupName.Free;
  VarClear(FArray);
  FCount.Free;
  inherited Destroy;
end;

procedure TRMCrossGroupItem.Reset(NewGroupName: string; StartFrom: Integer);
var
  i: Integer;
  s: string;
begin
  FStartFrom := StartFrom;
  RMSetCommaText(NewGroupName, FGroupName);
  for i := 0 to FCellItemsCount - 1 do
  begin
    FCount[i] := 0;
    s := FuncName(Parent.FCellFields[i]);
    if (s = 'max') or (s = 'min') then
      FArray[i] := Null
    else
      FArray[i] := 0;
  end;
end;

function TRMCrossGroupItem.IsBreak(GroupName: string): Boolean;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  RMSetCommaText(GroupName, sl);
  Result := (FIndex < sl.Count) and (FIndex < FGroupName.Count) and
    (sl[FIndex] <> FGroupName[FIndex]);
  sl.Free;
end;

procedure TRMCrossGroupItem.AddValue(Value: Variant);
var
  i: Integer;
  s: string;
begin
  if TVarData(Value).VType >= varArray then
  begin
    for i := 0 to FCellItemsCount - 1 do
    begin
      if (Value[i] <> Null) and HasTotal(Parent.FCellFields[i]) then
      begin
        s := FuncName(Parent.FCellFields[i]);
        if (s = 'sum') or (s = 'count') then
          FArray[i] := FArray[i] + Value[i]
        else if s = 'min' then
        begin
          if (FArray[i] = Null) or (FArray[i] > Value[i]) then
            FArray[i] := Value[i];
        end
        else if s = 'max' then
        begin
          if FArray[i] < Value[i] then
            FArray[i] := Value[i];
        end
        else if s = 'avg' then
        begin
          FArray[i] := FArray[i] + Value[i];
          FCount[i] := FCount[i] + 1;
        end;
      end;
    end;
  end;
end;

procedure TRMCrossGroupItem.CheckAvg;
var
  i: Integer;
  s: string;
begin
  for i := 0 to FCellItemsCount - 1 do
  begin
    s := FuncName(Parent.FCellFields[i]);
    if s = 'avg' then
    begin
      if FCount[i] <> 0 then
        FArray[i] := FArray[i] / FCount[i]
      else
        FArray[i] := Null;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMArray }

constructor TRMArray.Create(CellItemsCount: Integer; aReport: TRMReport);
begin
  inherited Create;
  FReport := aReport;
  FCellItemsCount := CellItemsCount;
  FRows := TStringList.Create;
  FRows.Sorted := True;
  FColumns := TStringList.Create;
  FColumns.Sorted := True;
end;

destructor TRMArray.Destroy;
begin
  Clear;
  FRows.Free;
  FColumns.Free;
  inherited Destroy;
end;

procedure TRMArray.Clear;
var
  i, j: Integer;
  sl: TList;
  p: PRMArrayCell;
begin
  for i := 0 to FRows.Count - 1 do
  begin
    sl := Pointer(FRows.Objects[i]);
    if sl <> nil then
    begin
      for j := 0 to sl.Count - 1 do
      begin
        p := sl[j];
        if p <> nil then
        begin
          VarClear(p.Items);
          Dispose(p);
        end;
      end;
    end;
    sl.Free;
  end;

  FRows.Clear;
end;

function TRMArray.GetCell(const Row, Col: string; Index3: Integer): Variant;
var
  i1, i2: Integer;
  sl: TList;
  p: PRMArrayCell;
begin
  Result := Null;
  i1 := FRows.IndexOf(Row);
  i2 := FColumns.IndexOf(Col);
  if (i1 = -1) or (i2 = -1) or (Index3 >= FCellItemsCount) then
    Exit;
  i2 := Integer(FColumns.Objects[i2]);

  if i1 < FRows.Count then
    sl := Pointer(FRows.Objects[i1])
  else
    sl := nil;
  if sl <> nil then
  begin
    if i2 < sl.Count then
      p := sl[i2]
    else
      p := nil;
    if p <> nil then
      Result := p^.Items[Index3];
  end;
end;

procedure TRMArray.SetCell(const aRow, aCol: string; aIndex3: Integer; aValue: Variant);
var
  i, j, lRow, lCol: Integer;
  sl: TList;
  p: PRMArrayCell;
begin
  lRow := FRows.IndexOf(aRow);
  lCol := FColumns.IndexOf(aCol);
  if (lCol >= 0) then
    lCol := Integer(FColumns.Objects[lCol]);

  if lRow = -1 then // row does'nt exists, so create it
  begin
    sl := TList.Create;
    if FFlag_Insert and (not FRows.Sorted) and (FInsertPos < FRows.Count) then
      FRows.InsertObject(FInsertPos, aRow, sl)
    else
      FRows.AddObject(aRow, sl);

    lRow := FRows.IndexOf(aRow);
  end;

  if lCol = -1 then // column does'nt exists, so create it
  begin
    if FFlag_Insert and (not FColumns.Sorted) then
      FColumns.InsertObject(FInsertPos, aCol, TObject(FColumns.Count))
    else
      FColumns.AddObject(aCol, TObject(FColumns.Count));

    lCol := FColumns.Count - 1;
  end;

  sl := Pointer(FRows.Objects[lRow]);
  p := nil;
  if lCol < sl.Count then
    p := sl[lCol]
  else
  begin
    lCol := lCol - sl.Count;
    for i := 0 to lCol do
    begin
      New(p);
      p^.Items := VarArrayCreate([-1, FCellItemsCount - 1], varVariant);
      for j := -1 to FCellItemsCount - 1 do
        p^.Items[j] := Null;

      sl.Add(p);
    end;
  end;

  p^.Items[aIndex3] := aValue;
end;

function TRMArray.GetCellByIndex(Row, Col, Index3: Integer): Variant;
var
  sl: TList;
  p: PRMArrayCell;
begin
  Result := Null;
  if (Row = -1) or (Col = -1) or (Index3 >= FCellItemsCount) then
    Exit;
  if Col < FColumns.Count then
    Col := Integer(FColumns.Objects[Col]);

  if Row < FRows.Count then
    sl := Pointer(FRows.Objects[Row])
  else
    sl := nil;
  if sl <> nil then
  begin
    if Col < sl.Count then
      p := sl[Col]
    else
      p := nil;
    if p <> nil then
      Result := p^.Items[Index3];
  end;
end;

function TRMArray.GetCellArray(Row, Col: Integer): Variant;
var
  sl: TList;
  p: PRMArrayCell;
begin
  Result := Null;
  if (Row = -1) or (Col = -1) then
    Exit;
  if Col < FColumns.Count then
    Col := Integer(FColumns.Objects[Col]);

  if Row < FRows.Count then
    sl := Pointer(FRows.Objects[Row])
  else
    sl := nil;
  if sl <> nil then
  begin
    if Col < sl.Count then
      p := sl[Col]
    else
      p := nil;
    if p <> nil then
      Result := p^.Items;
  end;
end;

procedure TRMArray.SetCellArray(Row, Col: Integer; Value: Variant);
var
  i: Integer;
  lList: TList;
  p: PRMArrayCell;
begin
  if (Row = -1) or (Col = -1) then
    Exit;
  Cell[FRows[Row], Columns[Col], 0] := 0;

  if Col < FColumns.Count then
    Col := Integer(FColumns.Objects[Col]);

  if Row < FRows.Count then
    lList := Pointer(FRows.Objects[Row])
  else
    lList := nil;
  if lList <> nil then
  begin
    if Col < lList.Count then
      p := lList[Col]
    else
      p := nil;
    if p <> nil then
    begin
      for i := 0 to FCellItemsCount - 1 do
        p^.Items[i] := Value[i];
    end;
  end;
end;

procedure TRMArray.SetSortColHeader(Value: Boolean);
begin
  FSortColHeader := Value;
  FColumns.Sorted := FSortColHeader;
end;

procedure TRMArray.SetSortRowHeader(Value: Boolean);
begin
  FSortRowHeader := Value;
  FRows.Sorted := FSortRowHeader;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCrossArray }

procedure _Sort(aStringList: TStringList);
var
  n, i: Integer;

  function _SubStrCount(aSubStr, aStr: string): Integer;
  var //取子串在子串中出现多少次
    i, l: Integer;
  begin
    Result := 0;
    l := Length(aSubStr);
    for i := 1 to Length(aStr) - l do
    begin
      if Copy(aStr, i, l) = aSubStr then
        inc(Result);
    end;
  end;

  procedure _Sort1(aStringList: TStringList; n: Integer);
  var
    i, j: Integer;
    lString1, lString2: string;
    lStrList: TStringList;

    function _PreNSubString(aString: string; n: Integer): string;
    var
      i, j, k: Integer;
    begin //取第N个';'前的子串
      j := 0;
      k := 0;
      for i := 1 to Length(aString) do
      begin
        k := i;
        if aString[i - 1] = ';' then
          inc(j);
        if j = n then
          break;
      end;
      Result := Copy(aString, 1, k - 1);
    end;

  begin
    lStrList := TStringList.Create;
    try
      for i := 0 to aStringList.Count - 1 do
      begin
        if aStringList.Strings[i] <> '' then //没有被选过的才参加选择
        begin
          lString1 := _PreNSubString(aStringList.Strings[i], n);
          lStrList.AddObject(aStringList[i], aStringList.Objects[i]);
          aStringList.Strings[i] := ''; //已经被选过的清空
          for j := (i + 1) to (aStringList.Count - 1) do //扫描剩下没有选过的串
          begin
            if aStringList.Strings[j] <> '' then
            begin
              lString2 := _PreNSubString(aStringList.Strings[j], n);
              if lString2 = lString1 then
              begin
                lStrList.AddObject(aStringList[j], aStringList.Objects[j]);
                aStringList.Strings[j] := '';
              end;
            end;
          end;
        end;
      end;
      aStringList.Clear;
      aStringList.Assign(lStrList);
    finally
      lStrList.Free;
    end;
  end;

begin //需要进行N次排序
  n := _SubStrCount(';', aStringList.Strings[0]);
  for i := 1 to n do
  begin
    _Sort1(aStringList, i);
  end;
end;

constructor TRMCrossArray.Create(aReport: TRMReport; DS: TRMDataset; RowFields, ColFields, CellFields: string);
begin
  FRMDataset  := DS;
  FRowFields := TStringList.Create;
  FColFields := TStringList.Create;
  FCellFields := TStringList.Create;

  while (Length(RowFields) > 0) and (RowFields[Length(RowFields)] in ['+', ';']) do
    RowFields := Copy(RowFields, 1, Length(RowFields) - 1);
  while (Length(ColFields) > 0) and (ColFields[Length(ColFields)] in ['+', ';']) do
    ColFields := Copy(ColFields, 1, Length(ColFields) - 1);

  RMSetCommaText(RowFields, FRowFields);
  RMSetCommaText(ColFields, FColFields);
  RMSetCommaText(CellFields, FCellFields);

  inherited Create(FCellFields.Count, aReport);

  FSortColHeader := True;
  FSortRowHeader := True;
  FAddColumnsHeader := TStringList.Create;
end;

destructor TRMCrossArray.Destroy;
begin
  FreeAndNil(FRowFields);
  FreeAndNil(FColFields);
  FreeAndNil(FCellFields);
  FreeAndNil(FAddColumnsHeader);
  inherited Destroy;
end;

const
  RMftNone = 0;
  RMftRight = 1;
  RMftBottom = 2;
  RMftLeft = 4;
  RMftTop = 8;

procedure TRMCrossArray.Build;
var
  i: Integer;
  v: Variant;
  s1, s2: string;

  function GetFieldValues(sl: TStringList): string;
  var
    i, j, n: Integer;
    s: string;
    v: Variant;
    d: Double;
  begin
    Result := '';
    for i := 0 to sl.Count - 1 do
    begin
      s := _PureName(sl[i]);
      v := FRMDataSet.FieldValue[FReport.Dictionary.RealFieldName[FRMDataSet, s]];

      if (TVarData(v).VType = varOleStr) or (TVarData(v).VType = varString) then
        Result := Result + VarToStrDef(v,'') + ';'
      else
      begin
        if v = Null then
          d := 0
        else
        begin
          d := v;
          if sl = FRowFields then
            FRowTypes[i] := v
          else if sl = FColFields then
            FColTypes[i] := v;
        end;

        s := Format('%2.6f', [d]);
        n := 32 - Length(s);
        for j := 1 to n do
          s := ' ' + s;

        Result := Result + s + ';';
      end;
    end;
    if Result <> '' then
      Result := Copy(Result, 1, Length(Result) - 1);
  end;

  procedure FormGroup(NewGroup, OldGroup: string; Direction: Boolean; aIndex: Integer);
  var
    i, j: Integer;
    sl1, sl2: TStringList;

    procedure FormGroup1(Index: Integer);
    var
      i: Integer;
      s: string;
    begin
      s := '';
      for i := 0 to Index - 1 do
        s := s + sl1[i] + ';';
      s := s + sl1[Index] + '+;+';
      if Direction then
      begin
        if HasTotal(FColFields[Index]) then
          Cell[Rows[0], s, 0] := 0
      end
      else if HasTotal(FRowFields[Index]) then
        Cell[s, Columns[0], 0] := 0;
    end;

  begin
    sl1 := TStringList.Create;
    sl2 := TStringList.Create;
    RMSetCommaText(OldGroup, sl1);
    RMSetCommaText(NewGroup, sl2);
    FFlag_Insert := (Direction and (not SortColHeader)) or (not Direction and (not SortRowHeader));
    try
      for i := 0 to sl1.Count - 1 do
      begin
        if (NewGroup = '') or (sl1[i] <> sl2[i]) then
        begin
          for j := sl1.Count - 1 downto i do
          begin
            FormGroup1(j);
            Inc(FInsertPos);
          end;
          Break;
        end;
      end;
    finally
      FFlag_Insert := False;
      FreeAndNil(sl1);
      FreeAndNil(sl2);
    end;
  end;

  procedure MakeTotals(sl: TStringList; Direction: Boolean); // Direction=True sl=Columns else sl=Rows
  var
    i: Integer;
    s, Old: string;
  begin
    Old := sl[0];
    i := 0;
    FInsertPos := 0;
    while i < sl.Count do
    begin
      s := sl[i];
      if (s <> Old) and (Pos('+', s) = 0) then
      begin
        FormGroup(s, Old, Direction, i - 1);
        Old := s;
      end;
      Inc(i);
    end;
    FormGroup('', sl[sl.Count - 1], Direction, sl.Count);
  end;

  procedure CalcTotals(FieldsSl, RowsSl, ColumnsSl: TStringList);
  var
    i, j, k, i1: Integer;
    lList: TList;
    cg: TRMCrossGroupItem;
  begin
    lList := TList.Create;
    lList.Add(TRMCrossGroupItem.Create(Self, '', FieldsSl.Count, FCellItemsCount)); // grand total
    for i := 0 to FieldsSl.Count - 1 do
      lList.Add(TRMCrossGroupItem.Create(Self, ColumnsSl[0], i, FCellItemsCount));

    for i := 0 to RowsSl.Count - 1 do
    begin
      for k := 0 to FieldsSl.Count do
        TRMCrossGroupItem(lList[k]).Reset(ColumnsSl[0], 0);
      for j := 0 to ColumnsSl.Count - 1 do
      begin
        for k := 0 to FieldsSl.Count do
        begin
          cg := TRMCrossGroupItem(lList[k]);
          if cg.IsBreak(ColumnsSl[j]) or ((k = 0) and (j = ColumnsSl.Count - 1)) then
          begin
            if (k = 0) or HasTotal(FieldsSl[k - 1]) then
            begin
              cg.CheckAvg;
              if RowsSl = Rows then
              begin
                CellArray[i, j] := cg.Value;
                Cell[Rows[0], Columns[j], -1] := cg.FStartFrom;
              end
              else
              begin
                CellArray[j, i] := cg.Value;
                Cell[Rows[j], Columns[0], -1] := cg.FStartFrom;
              end;
            end;

            i1 := j;
            while i1 < ColumnsSl.Count do
            begin
              if Pos('+;+', ColumnsSl[i1]) = 0 then
                break;
              Inc(i1);
            end;
            if i1 < ColumnsSl.Count then
              cg.Reset(ColumnsSl[i1], j);
            break;
          end
          else if Pos('+;+', ColumnsSl[j]) = 0 then
          begin
            if RowsSl = Rows then
              cg.AddValue(CellArray[i, j])
            else
              cg.AddValue(CellArray[j, i]);
          end;
        end;
      end;
    end;

    for i := 0 to FieldsSl.Count do
      TRMCrossGroupItem(lList[i]).Free;

    FreeAndNil(lList);
  end;

  procedure CheckAvg;
  var
    i, j: Integer;
    v: Variant;
    n: TRMQuickIntArray;
    Check: Boolean;

    procedure CalcAvg(i1, j1: Integer);
    var
      i, j, k: Integer;
      v1: Variant;
    begin
      for i := 0 to FCellFields.Count - 1 do
      begin
        v[i] := 0;
        n[i] := 0;
      end;

      for i := CellByIndex[i1, 0, -1] to i1 - 1 do
      begin
        for j := CellByIndex[0, j1, -1] to j1 - 1 do
        begin
          if (not IsTotalRow[i]) and (not IsTotalColumn[j]) then
          begin
            for k := 0 to FCellFields.Count - 1 do
            begin
              if FuncName(FCellFields[k]) = 'avg' then
              begin
                v1 := CellByIndex[i, j, k];
                if v1 <> Null then
                begin
                  n[k] := n[k] + 1;
                  v[k] := v[k] + v1;
                end;
              end;
            end;
          end;
        end;
      end;

      for i := 0 to FCellFields.Count - 1 do
      begin
        if FuncName(FCellFields[i]) = 'avg' then
        begin
          if n[i] <> 0 then
            Cell[Rows[i1], Columns[j1], i] := v[i] / n[i]
          else
            Cell[Rows[i1], Columns[j1], i] := Null;
        end;
      end;
    end;

  begin
    v := VarArrayCreate([0, FCellFields.Count - 1], varVariant);
    n := TRMQuickIntArray.Create(FCellFields.Count);

    Check := False;
    for i := 0 to FCellFields.Count - 1 do
    begin
      if FuncName(FCellFields[i]) = 'avg' then
      begin
        Check := True;
        break;
      end;
    end;

    if Check then
    begin
      for i := 0 to Rows.Count - 1 do
      begin
        if IsTotalRow[i] or (i = Rows.Count - 1) then
        begin
          for j := 0 to Columns.Count - 1 do
          begin
            if IsTotalColumn[j] or (j = Columns.Count - 1) then
              CalcAvg(i, j);
          end;
        end;
      end;
    end;

    for i := 0 to Rows.Count - 1 do
      Cell[Rows[i], Columns[0], -1] := Null;
    for i := 0 to Columns.Count - 1 do
      Cell[Rows[0], Columns[i], -1] := Null;

    VarClear(v);
    n.Free;
  end;

  procedure _MakeColumnHeader;
  var
    i, j, n, cn: Integer;
    s: string;
    sl, sl1: TStringList;
    Flag: Boolean;
    d: Double;
    lValue: Variant;

    function _CompareSl(Index: Integer): Boolean;
    begin
      Result := (sl.Count > Index) and (sl1.Count > Index) and (sl[Index] = sl1[Index]);
    end;

  begin
    sl := TStringList.Create;
    sl1 := TStringList.Create;
    cn := CharCount(';', Columns[0]) + 1; // height of header
    FTopLeftSize.cy := cn;

    FFlag_Insert := True;
    for i := 0 to cn do
    begin
      FInsertPos := i;
      Cell[Chr(i), Columns[0], 0] := '';
    end;
    FFlag_Insert := False;

    for i := 0 to Columns.Count - 1 do
      Cell[#0, Columns[i], -1] := rmftTop or rmftBottom;

    Cell[#0, Columns[0], 0] := FHeaderString;
    Cell[#0, Columns[0], -1] := rmftLeft or rmftTop or rmftBottom;
    Cell[#0, Columns[Columns.Count - 1], -1] := rmftTop or rmftRight;
    for i := 1 to FAddColumnsHeader.Count do
      Cell[#0, Columns[Columns.Count - 1 - i], -1] := rmftTop or rmftRight;

    for i := 1 to cn do
    begin
      Cell[Chr(i), Columns[Columns.Count - 1], -1] := rmftLeft or rmftRight;
      for j := 1 to FAddColumnsHeader.Count do
        Cell[Chr(i), Columns[Columns.Count - 1 - j], -1] := rmftLeft or rmftRight;
    end;

    Cell[#1, Columns[Columns.Count - 1 - FAddColumnsHeader.Count], 0] := FColumnGrandTotalString;
    Cell[#1, Columns[Columns.Count - 1 - FAddColumnsHeader.Count], -1] := rmftLeft or rmftTop or rmftRight;
    for i := 0 to FAddColumnsHeader.Count - 1 do
    begin
      Cell[#1, Columns[Columns.Count - 1 - i], 0] := FAddColumnsHeader[FAddColumnsHeader.Count - 1 - i];
      Cell[#1, Columns[Columns.Count - 1 - i], -1] := rmftLeft or rmftTop or rmftRight;
    end;

    for i := 0 to Columns.Count - 2 - FAddColumnsHeader.Count do
    begin
      s := Columns[i];
      RMSetCommaText(s, sl);
      if Pos('+;+', s) <> 0 then
      begin
        n := CharCount(';', s);
        for j := 1 to n - 1 do
          Cell[Chr(j), s, -1] := rmftTop;

        for j := n to cn do
        begin
          if j = n then
          begin
            Cell[Chr(j), s, 0] := FColumnTotalString;
            Cell[Chr(j), s, -1] := rmftRight or rmftLeft or rmftTop;
          end
          else
            Cell[Chr(j), s, -1] := rmftRight or rmftLeft;
        end;
      end
      else
      begin
        Flag := False;
        for j := 0 to cn - 1 do
        begin
          if (not Flag) and _CompareSl(j) then
            Cell[Chr(j + 1), s, -1] := rmftTop
          else
          begin
            if TVarData(FColTypes[j]).VType = varDate then
            begin
              d := StrToFloat(Trim(sl[j]));
              TVarData(FColTypes[j]).VDate := d;
              lValue := FColTypes[j];
            end
            else if (TVarData(FColTypes[j]).VType = varString) or
              (TVarData(FColTypes[j]).VType = varOleStr) or
              (TVarData(FColTypes[j]).VType = varEmpty) or
              (TVarData(FColTypes[j]).VType = varNull) then
            begin
              lValue := '';
            	if j < sl.Count then
	              lValue := Trim(sl[j])
            end
            else
            begin
							lValue := '';
            	if j < sl.Count then
              begin
	              d := StrToFloat(Trim(sl[j]));
  	            lValue := FloatToStr(d);
              end;
            end;

            Cell[Chr(j + 1), s, 0] := lValue;
            Cell[Chr(j + 1), s, -1] := rmftTop or rmftLeft or rmftRight;
            Flag := True;
          end;
        end;
      end;
      
      sl1.Assign(sl);
    end;

    FreeAndNil(sl);
    FreeAndNil(sl1);
  end;

  procedure _MakeRowHeader;
  var
    i, j, n, cn: Integer;
    s: string;
    sl, sl1: TStringList;
    Flag: Boolean;
    d: Double;
    v: Variant;
    lNowRowNo: Integer;

    function CompareSl(Index: Integer): Boolean;
    begin
      Result := (sl.Count > Index) and (sl1.Count > Index) and (sl[Index] = sl1[Index]);
    end;

    procedure CellOr(Index1, Index2: string; Value: Integer);
    var
      v: Variant;
    begin
      v := Cell[Index1, Index2, -1];
      if v = Null then
        v := 0;
      v := v or Value;
      Cell[Index1, Index2, -1] := v;
    end;

  begin
    sl := TStringList.Create;
    sl1 := TStringList.Create;
    cn := CharCount(';', Rows[FTopLeftSize.cy + 1]) + 1 + Ord(DoDataCol) + Ord(ShowRowNo); // width of header
    FTopLeftSize.cx := cn;

    FFlag_Insert := True;
    for i := 0 to cn - 1 do
    begin
      FInsertPos := i;
      Cell[Rows[0], Chr(i), 0] := '';
    end;
    FFlag_Insert := False;

    Cell[Rows[Rows.Count - 1], #0, 0] := FRowGrandTotalString;
    Cell[Rows[Rows.Count - 1], #0, -1] := rmftTop or rmftBottom or rmftLeft;

    for i := 1 to cn - 1 do
      Cell[Rows[Rows.Count - 1], Chr(i), -1] := rmftTop or rmftBottom;

    if DoDataCol then
    begin
      for i := FTopLeftSize.cy + 1 to Rows.Count - 1 do
      begin
        Cell[Rows[i], Chr(cn - 1), 0] := DataStr;
        Cell[Rows[i], Chr(cn - 1), -1] := 15;
      end;
    end;

    for i := 0 to FTopLeftSize.cy do
    begin
      for j := 0 to cn - 1 do
        Cell[Chr(i), Chr(j), -1] := 0;
    end;

    lNowRowNo := 1;
    for i := FTopLeftSize.cy + 1 to Rows.Count - 2 do
    begin
      s := Rows[i];
      RMSetCommaText(s, sl);
      if Pos('+;+', s) <> 0 then
      begin
        n := CharCount(';', s);
        for j := 1 to n - 1 + Ord(ShowRowNo) do
          Cell[s, Chr(j - 1), -1] := rmftLeft;

        for j := n + Ord(ShowRowNo) to cn - Ord(DoDataCol) do
        begin
          if (j = n + Ord(ShowRowNo)) then
          begin
            Cell[s, Chr(j - 1), 0] := FRowTotalString;
            Cell[s, Chr(j - 1), -1] := rmftLeft or rmftTop;
          end
          else
          begin
            Cell[s, Chr(j - 1), -1] := rmftTop or rmftBottom;
          end;
        end;
      end
      else
      begin
        Flag := False;
        for j := Ord(ShowRowNo) to cn - 1 - Ord(DoDataCol) do
        begin
          if (not Flag) and CompareSl(j - Ord(ShowRowNo)) then
          begin
            Cell[s, Chr(j), 0] := Null;  // whf add, 2005/11/28
            Cell[s, Chr(j), -1] := rmftLeft;
            if ShowRowNo and (j = 1) then
              Cell[s, Chr(0), -1] := rmftLeft;
          end
          else
          begin
            if TVarData(FRowTypes[j - Ord(ShowRowNo)]).VType = varDate then
            begin
              d := StrToFloat(Trim(sl[j - Ord(ShowRowNo)]));
              TVarData(FRowTypes[j]).VDate := d;
              v := FRowTypes[j];
            end
            else if (TVarData(FRowTypes[j - Ord(ShowRowNo)]).VType = varString) or
            (TVarData(FRowTypes[j - Ord(ShowRowNo)]).VType = varOleStr) or
            (TVarData(FRowTypes[j - Ord(ShowRowNo)]).VType = varEmpty) or
            (TVarData(FRowTypes[j - Ord(ShowRowNo)]).VType = varNull) then
              v := Trim(sl[j - Ord(ShowRowNo)])
            else
            begin
              d := StrToFloat(Trim(sl[j - Ord(ShowRowNo)]));
              v := FloatToStr(d);
            end;
            Cell[s, Chr(j), 0] := v;
            Cell[s, Chr(j), -1] := rmftTop or rmftLeft;
            if ShowRowNo and (j = 1) then
            begin
              Cell[s, Chr(0), 0] := lNowRowNo;
              Cell[s, Chr(0), -1] := rmftTop or rmftLeft;
              Inc(lNowRowNo);
            end;
            Flag := True;
          end;
        end;
      end;
      sl1.Assign(sl);
    end;

    FreeAndNil(sl);
    FreeAndNil(sl1);

    for i := cn to Columns.Count - 1 do
      CellOr(Rows[Rows.Count - 1], Columns[i], 15);
    for i := cn to Columns.Count - 1 do
      CellOr(Rows[FTopLeftSize.cy], Columns[i], rmftBottom);
    for i := 0 to cn - 1 - ord(DoDataCol) do
      CellOr(Rows[Rows.Count - 2], Columns[i], rmftBottom);
  end;

begin
  FRMDataSet.Open;
  FRMDataSet.First;
  while not FRMDataSet.EOF do
  begin
    Application.ProcessMessages;
    for i := 0 to FCellFields.Count - 1 do
    begin
      v := FRMDataSet.FieldValue[FReport.Dictionary.RealFieldName[FRMDataSet, _PureName(FCellFields[i])]];

      if FuncName(FCellFields[i]) = 'count' then
      begin
        if VarIsNull(v) then
          v := 0
        else
          v := 1;
      end;

      s1 := GetFieldValues(FRowFields);
      s2 := GetFieldValues(FColFields);
      if Cell[s1, s2, i] = Null then
        Cell[s1, s2, i] := v
      else
        Cell[s1, s2, i] := Cell[s1, s2, i] + v;
    end;
    FRMDataSet.Next;
  end;

  if Columns.Count = 0 then
    Exit;

  if (not SortColHeader) and (CharCount(';', Columns[0]) > 0) then
    _Sort(FColumns);
  if (not SortRowHeader) and (CharCount(';', Rows[0]) > 0) then
    _Sort(FRows);

  MakeTotals(Columns, True);
  Cell[Rows[0], Columns[Columns.Count - 1] + '+', 0] := 0;
  MakeTotals(Rows, False);
  Cell[Rows[Rows.Count - 1] + '+', Columns[0], 0] := 0;

  CalcTotals(FColFields, Rows, Columns);
  CalcTotals(FRowFields, Columns, Rows);
  CheckAvg;

  for i := 0 to FAddColumnsHeader.Count - 1 do
  begin
    Cell[Rows[0], Columns[Columns.Count - 1] + '+', 0] := 0;
  end;

  _MakeColumnHeader;
  _MakeRowHeader;
end;

function TRMCrossArray.GetIsTotalRow(Index: Integer): Boolean;
begin
  Result := Pos('+;+', Rows[Index]) <> 0;
end;

function TRMCrossArray.GetIsTotalColumn(Index: Integer): Boolean;
begin
  Result := Pos('+;+', Columns[Index]) <> 0;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMQuickArray }

constructor TRMQuickIntArray.Create(Length: Integer);
begin
  inherited Create;

  Len := Length;
  GetMem(arr, Len * SizeOf(TIntArrayCell));
  for Length := 0 to Len - 1 do
    arr[Length] := 0;
end;

destructor TRMQuickIntArray.Destroy;
begin
  FreeMem(arr, Len * SizeOf(TIntArrayCell));

  inherited;
end;

function TRMQuickIntArray.GetCell(Index: Integer): Integer;
begin
  Result := arr[Index];
end;

procedure TRMQuickIntArray.SetCell(Index: Integer; const Value: Integer);
begin
  arr[Index] := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCrossList }

function PureName1(s: string): string;
begin
  if Pos('+', s) <> 0 then
    Result := Copy(s, 1, Pos('+', s) - 1)
  else
    Result := s;
end;

constructor TRMCrossList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TRMCrossList.Destroy;
begin
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TRMCrossList.Add(v: TRMCrossView);
begin
  FList.Add(v);
  v.FSavedOnBeforePrint := v.ParentReport.OnBeforePrint;
  v.ParentReport.OnBeforePrint := v.OnReportBeforePrintEvent;
  v.FSavedOnPrintColumn := v.ParentReport.OnPrintColumn;
  v.ParentReport.OnPrintColumn := v.OnReportPrintColumnEvent;
end;

procedure TRMCrossList.Delete(v: TRMCrossView);
var
  i: Integer;
  v1: TRMCrossView;
begin
  v.ParentReport.OnBeforePrint := v.FSavedOnBeforePrint;
  v.ParentReport.OnPrintColumn := v.FSavedOnPrintColumn;

  i := FList.IndexOf(v);
  FList.Delete(i);

  if (i = 0) and (FList.Count > 0) then
  begin
    v := TRMCrossView(FList[0]);
    v.FSavedOnBeforePrint := v.ParentReport.OnBeforePrint;
    v.FSavedOnPrintColumn := v.ParentReport.OnPrintColumn;
  end;

  for i := 1 to FList.Count - 1 do
  begin
    v := TRMCrossView(FList[i]);
    v1 := TRMCrossView(FList[i - 1]);
    v.FSavedOnBeforePrint := v1.OnReportBeforePrintEvent;
    v.FSavedOnPrintColumn := v1.OnReportPrintColumnEvent;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMCrossView}

class function TRMCrossView.CanPlaceOnGridView: Boolean;
begin
  Result := False;
end;

function TRMCrossView.IsCrossView: Boolean;
begin
  Result := True;
end;

constructor TRMCrossView.Create;
begin
  inherited Create;
  FCrossArray := nil;
  BaseName := 'Cross';

  DontUndo := True;
  OnePerPage := True;
  Restrictions := [rmrtDontSize, rmrtDontEditMemo];
  spWidth := 348;
  spHeight := 94;
  Visible := False;
  LeftFrame.Visible := True;
  TopFrame.Visible := True;
  RightFrame.Visible := True;
  BottomFrame.Visible := True;

  ParentReport := RMCurReport;
  RMCrossList.Add(Self);

  ShowRowTotal := True;
  ShowColumnTotal := True;
  ShowIndicator := True;
  SortColHeader := True;
  SortRowHeader := True;
  FInternalFrame := True;
  FDataWidth := 0; FDataHeight := 0;
  FHeaderWidth := '0';
  FHeaderHeight := '0';
  FDefDY := 18;

  FDictionary := TStringList.Create;
  FAddColumnsHeader := TStringList.Create;
end;

destructor TRMCrossView.Destroy;
var
  i: Integer;
  lPage: TRMReportPage;

  procedure _Del(s: string);
  var
    t: TRMView;
  begin
    if lPage <> nil then
    begin
      t := lPage.FindObject(s);
      if t <> nil then
        lPage.Delete(lPage.Objects.IndexOf(t));
    end;
  end;

begin
  lPage := nil;
  for i := 0 to ParentReport.Pages.Count - 1 do
  begin
    if ParentReport.Pages[i].FindObject(Self.Name) <> nil then
    begin
      lPage := TRMReportPage(ParentReport.Pages[i]);
      Break;
    end;
  end;

  _Del('ColumnHeaderMemo' + Name);
  _Del('ColumnTotalMemo' + Name);
  _Del('GrandColumnTotalMemo' + Name);
  _Del('RowHeaderMemo' + Name);
  _Del('CellMemo' + Name);
  _Del('RowTotalMemo' + Name);
  _Del('GrandRowTotalMemo' + Name);
  _Del('ColHeaderMemo' + Name);
  _Del('CrossHeaderMemo' + Name);

  RMCrossList.Delete(Self);

  FreeAndNil(FDictionary);
  FreeAndNil(FAddColumnsHeader);

  inherited Destroy;
end;

type
  THackReport = class(TRMReport)
  end;

  THackReportPage = class(TRMReportPage)
  end;

  THackReportView = class(TRMReportView)
  end;

  THackMemoView = class(TRMMemoView)
  end;

  THackUserDataset = class(TRMUserDataset)
  end;

function TRMCrossView.OneObject(aPage: TRMReportPage; Name1, Name2: string): TRMMemoView;
begin
  Result := TRMMemoView(RMCreateObject(rmgtMemo, ''));
  Result.ParentPage := aPage;
  Result.Name := Name1 + Name;
  Result.Memo.Add(Name2);
  Result.Font.Style := [fsBold];
  Result.spWidth := 80;
  Result.spHeight := FDefDY;
  Result.HAlign := rmHCenter;
  Result.VAlign := rmVCenter;
  Result.LeftFrame.Visible := True;
  Result.RightFrame.Visible := True;
  Result.TopFrame.Visible := True;
  Result.BottomFrame.Visible := True;
  Result.Restrictions := [rmrtDontSize, rmrtDontMove, rmrtDontDelete];
  THackMemoView(Result).IsChildView := True;
  Result.Visible := False;
end;

function TRMCrossView.ParentPage: TRMReportPage;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to ParentReport.Pages.Count - 1 do
  begin
    if ParentReport.Pages[i].FindObject(Self.Name) <> nil then
    begin
      Result := TRMReportPage(ParentReport.Pages[i]);
      Break;
    end;
  end;
end;

procedure TRMCrossView.CreateObjects;
var
  v: TRMMemoView;
  p: TRMReportPage;
begin
  p := ParentPage;

  OneObject(p, 'ColumnHeaderMemo', RMLoadStr(rmRes + 755)); //'Header'

  v := OneObject(p, 'ColumnTotalMemo', RMLoadStr(rmRes + 756)); //'Total'
  v.FillColor := $F5F5F5;

  v := OneObject(p, 'GrandColumnTotalMemo', RMLoadStr(rmRes + 757)); //'Grand total'
  v.FillColor := clSilver;

  OneObject(p, 'RowHeaderMemo', RMLoadStr(rmRes + 755)); //'Header'

  v := OneObject(p, 'CellMemo', RMLoadStr(rmRes + 758)); //'Cell'
  v.Font.Style := [];

  v := OneObject(p, 'RowTotalMemo', RMLoadStr(rmRes + 756)); //'Total'
  v.FillColor := $F5F5F5;

  v := OneObject(p, 'GrandRowTotalMemo', RMLoadStr(rmRes + 757)); //'Grand total'
  v.FillColor := clSilver;

  OneObject(p, 'CrossHeaderMemo', '');
end;

procedure TRMCrossView.ShowEditor;
var
  tmp: TRMCrossForm;
begin
  tmp := TRMCrossForm.Create(Application);
  try
    tmp.Cross := Self;
    tmp.ShowModal;
  finally
    tmp.Free;
  end;
end;

procedure TRMCrossView.Draw(aCanvas: TCanvas);
var
  v: TRMView;
  bmp, lBmp2: TBitmap;
  p: TRMReportPage;

  procedure _Draw(t: TRMView);
  begin
    t.Draw(aCanvas);
    if TRMMemoView(t).Highlight.Condition <> '' then
      aCanvas.Draw(t.spLeft_Designer + 1, t.spTop_Designer + 1, lBmp2);
  end;

begin
  if ParentReport.FindObject('ColumnHeaderMemo' + Name) = nil then
    CreateObjects;

  BeginDraw(aCanvas);
  CalcGaps;
  ShowBackground;
  ShowFrame;
  bmp := TBitmap.Create;
  lBmp2 := TBitmap.Create;
  try
    lBmp2.LoadFromResourceName(hInstance, 'RM_HIGHLIGHT');

    v := ParentReport.FindObject('ColumnHeaderMemo' + Name);
    v.SetspBounds(spLeft + 92, spTop + 8, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('ColumnTotalMemo' + Name);
    v.SetspBounds(spLeft + 176, spTop + 8, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('GrandColumnTotalMemo' + Name);
    v.SetspBounds(spLeft + 260, spTOp + 8, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('RowHeaderMemo' + Name);
    v.SetspBounds(spLeft + 8, spTop + 28, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('CellMemo' + Name);
    v.SetspBounds(spLeft + 92, spTop + 28, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('RowTotalMemo' + Name);
    v.SetspBounds(spLeft + 8, spTop + 48, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('GrandRowTotalMemo' + Name);
    v.SetspBounds(spLeft + 8, spTop + 68, v.spWidth, v.spHeight);
    _Draw(v);

    v := ParentReport.FindObject('CrossHeaderMemo' + Name);
    if v = nil then
    begin
      p := ParentPage;
      v := OneObject(p, 'CrossHeaderMemo', '');
    end;
    v.SetspBounds(spLeft + 8, spTop + 8, v.spWidth, v.spHeight);
    _Draw(v);

    bmp.Handle := LoadBitmap(hInstance, 'RM_CrossObject');
    aCanvas.Draw(spLeft + spWidth - 20, spTop + spHeight - 20, bmp);
  finally
    bmp.Free;
    lBmp2.Free;
    RestoreCoord;
  end;
end;

procedure TRMCrossView.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FInternalFrame := RMReadBoolean(aStream);
  FRepeatCaptions := RMReadBoolean(aStream);
  FShowHeader := RMReadBoolean(aStream);
  FDataWidth := RMReadInt32(aStream);
  FDataHeight := RMReadInt32(aStream);
  FHeaderWidth := RMReadString(aStream);
  FHeaderHeight := RMReadString(aStream);
  FDictionary.Text := RMReadString(aStream);
  FRowNoHeader := RMReadString(aStream);
  RMReadMemo(aStream, FAddColumnsHeader);
  OnePerPage := True;
end;

procedure TRMCrossView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteBoolean(aStream, FInternalFrame);
  RMWriteBoolean(aStream, FRepeatCaptions);
  RMWriteBoolean(aStream, FShowHeader);
  RMWriteInt32(aStream, FDataWidth);
  RMWriteInt32(aStream, FDataHeight);
  RMWriteString(aStream, FHeaderWidth);
  RMWriteString(aStream, FHeaderHeight);
  RMWriteString(aStream, FDictionary.Text);
  RMWriteString(aStream, FRowNoHeader);
  RMWriteMemo(aStream, FAddColumnsHeader);
end;

procedure TRMCrossView.CalcWidths;
var
  i, w, maxw, h, maxh, k: Integer;
  v: TRMView;
  b: TBitmap;
  m: TWideStringList;
begin
  ParentReport.CurrentPage := ParentPage;

  FFlag := True;
  if FDataWidth <= 0 then
    FColumnWidths := TRMQuickIntArray.Create(FCrossArray.Columns.Count + 1)
  else if (FHeaderWidth = '') or (FHeaderWidth = '0') then
    FColumnWidths := TRMQuickIntArray.Create(FCrossArray.TopLeftSize.cx + 1);

  FColumnHeights := TRMQuickIntArray.Create(FCrossArray.TopLeftSize.cy + 2);
  FLastTotalCol := TRMQuickIntArray.Create(FCrossArray.TopLeftSize.cy + 1);

  if FDataHeight > 0 then
    FMaxCellHeight := FDataHeight
  else
    FMaxCellHeight := 0;

  FMaxGTHeight := 0;
  if not ShowRowTotal then
    FRowDataSet.RangeEndCount := FRowDataSet.RangeEndCount - 1;
  if not ShowColumnTotal then
    FColumnDataSet.RangeEndCount := FColumnDataSet.RangeEndCount - 1;

  for k := 0 to FCrossArray.CellItemsCount - 1 do
  begin
    v := ParentReport.FindObject('CrossMemo@' + IntToStr(k) + Name);
    m := TWideStringList.Create;
    b := TBitmap.Create;
    THackMemoView(v).Canvas := b.Canvas;

    if (FHeaderWidth = '') or (FHeaderWidth = '0') then
    begin
      FColumnDataSet.First;
      while FColumnDataSet.RecordNo < FCrossArray.TopLeftSize.cx do
      begin
        maxw := 0;

        FRowDataSet.First;
        FRowDataSet.Next;
        while not FRowDataSet.EOF do
        begin
          OnReportBeforePrintEvent(nil, TRMReportView(v));
          m.Assign(v.Memo);
          if m.Count = 0 then
            m.Add(' ');
          w := THackMemoView(v).CalcWidth(m) + 5;
          if w > maxw then
            maxw := w;
          FRowDataSet.Next;
        end;
        if FColumnWidths.Cell[FColumnDataSet.RecordNo] < maxw then
          FColumnWidths.Cell[FColumnDataSet.RecordNo] := maxw;
        FColumnDataSet.Next;
      end;
    end;

    if FDataWidth <= 0 then
    begin
      THackUserDataset(FColumnDataSet).FRecordNo := FCrossArray.TopLeftSize.cx;
      while not FColumnDataSet.EOF do
      begin
        maxw := 0;

        FRowDataSet.First;
        FRowDataSet.Next;
        while not FRowDataSet.EOF do
        begin
          OnReportBeforePrintEvent(nil, TRMReportView(v));
          m.Assign(v.Memo);
          if m.Count = 0 then
            m.Add(' ');
          w := THackMemoView(v).CalcWidth(m) + 5;
          if w > maxw then
            maxw := w;
          FRowDataSet.Next;
        end;
        if FColumnWidths.Cell[FColumnDataSet.RecordNo] < maxw then
          FColumnWidths.Cell[FColumnDataSet.RecordNo] := maxw;
        FColumnDataSet.Next;
      end;
      FColumnWidths.Cell[FCrossArray.Columns.Count] := 0;
    end;

    FRowDataSet.First;
    for i := 0 to FCrossArray.TopLeftSize.cy do
    begin
      maxh := 0;

      FColumnDataSet.First;
      while not FColumnDataSet.EOF do
      begin
        w := v.spWidth;
        v.spWidth := 1000;
        h := RMToScreenPixels(THackMemoView(v).CalcHeight, rmutMMThousandths);
        v.spWidth := w;
        if h > maxh then
          maxh := h;
        FColumnDataSet.Next;
      end;

      if (FHeaderHeight <> '') and (FHeaderHeight <> '0') then // WHF Modify
      begin
        FColumnHeights.Cell[i] := GetHeaderHeightByIndex(i);
      end
      else
      begin
        if maxh > v.spHeight then
          FColumnHeights.Cell[i] := maxh
        else
          FColumnHeights.Cell[i] := v.spHeight;
      end;
      FRowDataSet.Next;
    end;

    FColumnDataSet.First;
    while not FColumnDataSet.EOF do
    begin
      w := v.spWidth;
      v.spWidth := 1000;
      h := RMToScreenPixels(THackMemoView(v).CalcHeight, rmutMMThousandths);
      v.spWidth := w;
      if h > FMaxCellHeight then
        FMaxCellHeight := h;
      FColumnDataSet.Next;
    end;

    if ShowRowTotal or ShowColumnTotal then
    begin
      THackUserDataset(FRowDataSet).FRecordNo := FRowDataSet.RangeEndCount - 1;
      FColumnDataSet.First;
      while not FColumnDataSet.EOF do
      begin
        w := v.spWidth;
        v.spWidth := 1000;
        h := RMToScreenPixels(THackMemoView(v).CalcHeight, rmutMMThousandths);
        v.spWidth := w;
        if h > FMaxGTHeight then
          FMaxGTHeight := h;
        FColumnDataSet.Next;
      end;
    end;

    THackMemoView(v).DrawMode := rmdmAll;
    FreeAndNil(m);
    FreeAndNil(b);
  end;

  if FMaxCellHeight < FDefDy then
    FMaxCellHeight := FDefDY;
  if FMaxGTHeight < FDefDy then
    FMaxGTHeight := FDefDY;
  FFlag := False;
  FLastX := 0;
end;

procedure TRMCrossView.OnReportPrintColumnEvent(aColNo: Integer; var aWidth: Integer);
var
  i: Integer;
  lCurView: TRMView;
begin
  lCurView := ParentReport.CurrentView;
  if (not FSkip) and (Pos(Name, lCurView.Name) > 0) then
  begin
    if FDataWidth <= 0 then
      aWidth := FColumnWidths.Cell[aColNo - 1 + FCrossArray.TopLeftSize.cx]
    else
      aWidth := FDataWidth;

    for i := 0 to FCrossArray.CellItemsCount - 1 do
      ParentReport.FindObject('CrossMemo@' + IntToStr(i) + Name).spWidth := aWidth;

    if FRowDataSet.RecordNo < FCrossArray.TopLeftSize.cy then
    begin
      for i := 0 to FCrossArray.TopLeftSize.cy - 1 do
        ParentReport.FindObject('CrossMemo_' + IntToStr(i) + Name).spWidth := aWidth;
    end;
  end;

  if Assigned(FSavedOnPrintColumn) then
    FSavedOnPrintColumn(aColNo, aWidth);
end;

function _GetString(S: string; N: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if S[i] = ';' then
      Dec(N)
    else if N = 1 then
      Result := Result + s[i]
    else if N = 0 then
      break;
  end;
end;

function _GetPureString(S: string; N: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if S[i] = ';' then
      Dec(N)
    else if N = 1 then
      Result := Result + s[i]
    else if N = 0 then
      break;
  end;
  Result := PureName1(Result);
end;

procedure TRMCrossView.OnReportBeforePrintEvent(aMemo: TWideStringList; aView: TRMReportView);
var
  lValue: Variant;
  lStr: WideString;
  lStr1: WideString;
  i, j, lRow, lCol, lColCount: Integer;
  lRowHeaderFlag: Boolean;
  lHAlign: TRMHAlign;
  lVAlign: TRMVAlign;
  t: TRMMemoView;
  ft: Word;
  lCurPage: THackReportPage;
  lCurBand: TRMBand;

  procedure _Assign(m1, m2: TRMMemoView);
  begin
    m1.RotationType := m2.RotationType;
    m1.FillColor := m2.FillColor;
    THackMemoView(m1).FDisplayFormat := THackMemoView(m2).FDisplayFormat;
    THackMemoView(m1).FormatFlag := THackMemoView(m2).FormatFlag;
    m1.spGapLeft := m2.spGapLeft;
    m1.spGapTop := m2.spGapTop;
    m1.Highlight.Assign(m2.Highlight);
    m1.LineSpacing := m2.LineSpacing;
    m1.CharacterSpacing := m2.CharacterSpacing;
    m1.Font := m2.Font;
    m1.HAlign := TRMMemoView(m2).HAlign;
    m1.VAlign := TRMMemoView(m2).VAlign;
  end;

begin
  lCurPage := THackReportPage(ParentReport.CurrentPage);
  lCurBand := ParentReport.CurrentBand;

  if (not FSkip) and (Pos('CrossMemo', aView.Name) = 1) and (Pos(Name, aView.Name) > 0) then
  begin
    i := 0;
    lRow := FRowDataSet.RecordNo;
    lCol := FColumnDataSet.RecordNo;
    if not FFlag then
    begin
      while FRowDataSet.RecordNo <= FCrossArray.TopLeftSize.cy do
        FRowDataSet.Next;
      while FColumnDataSet.RecordNo < FCrossArray.TopLeftSize.cx do
        FColumnDataSet.Next;
      lRow := FRowDataSet.RecordNo;
      lCol := FColumnDataSet.RecordNo;
      if aView.Name <> 'CrossMemo@0' + Name then
      begin
        lStr := Copy(aView.Name, 1, Pos(Name, aView.Name) - 1);
        if (lStr[10] = '_') or (lStr[10] = '@') or (lStr[10] = '~') then
        begin
          if lStr[10] = '@' then
            i := StrToInt(Copy(lStr, 11, 255))
          else if lStr[10] = '~' then
          begin
            Delete(lStr, 1, 10);
            lRow := StrToInt(Copy(lStr, 1, Pos('~', lStr) - 1));
            Delete(lStr, 1, Pos('~', lStr));
            lCol := StrToInt(lStr);
          end
          else
          begin
            lRow := StrToInt(Copy(lStr, 11, 255));
            if not FShowHeader then
              Inc(lRow);
          end;
        end
        else
          lCol := StrToInt(Copy(lStr, 10, 255));
      end;
    end
    else if aView.Name <> 'CrossMemo' + Name then
    begin
      lStr := Copy(aView.Name, 1, Pos(Name, aView.Name) - 1);
      if lStr[10] = '@' then
        i := StrToInt(Copy(lStr, 11, 255));
    end;

    if not FShowHeader and (lRow = 0) then
      Inc(lRow);
    if not FFlag then
    begin
      if lRow <= FCrossArray.TopLeftSize.cy then
        aView.spHeight := FColumnHeights.Cell[lRow];
      aView.Visible := True;
      if lCol < FCrossArray.TopLeftSize.cx then
      begin
        if (FHeaderWidth = '') or (FHeaderWidth = '0') then
          aView.spWidth := FColumnWidths.Cell[lCol]
        else
          aView.spWidth := GetHeaderWidthByIndex(lCol);
      end
      else if FDataWidth <= 0 then
        aView.spWidth := FColumnWidths.Cell[lCol]
      else
        aView.spWidth := FDataWidth;
    end;

    _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('CellMemo' + Name)));
    lHAlign := TRMMemoView(aView).HAlign;
    lVAlign := TRMMemoView(aView).VAlign;
    if FInternalFrame then
    begin
      aView.LeftFrame.Visible := True;
      aView.TopFrame.Visible := True;
      aView.RightFrame.Visible := True;
      aView.BottomFrame.Visible := True;
    end
    else
    begin
      aView.LeftFrame.Visible := True;
      aView.RightFrame.Visible := True;
      aView.TopFrame.Visible := False;
      aView.BottomFrame.Visible := False;
    end;

    if (lRow = FCrossArray.TopLeftSize.cy + 1) and (lCol >= FCrossArray.TopLeftSize.cx) then
    begin
      if (not aView.TopFrame.Visible) and (not aView.BottomFrame.Visible) and
        (aView.LeftFrame.Visible or aView.RightFrame.Visible) then
        aView.TopFrame.Visible := True;
    end;

    lValue := FCrossArray.CellByIndex[lRow, lCol, -1];
    if lValue <> Null then
    begin
      aView.LeftFrame.Visible := (lValue and rmftLeft) = rmftLeft;
      aView.RightFrame.Visible := (lValue and rmftRight) = rmftRight;
      aView.TopFrame.Visible := (lValue and rmftTop) = rmftTop;
      aView.BottomFrame.Visible := (lValue and rmftBottom) = rmftBottom;
    end;

    if lRow = FCrossArray.Rows.Count - 2 then
      aView.BottomFrame.Visible := True;

    if not ShowColumnTotal and (FAddColumnsHeader.Count > 0) and (lCol >= FCrossArray.Columns.Count - 1 - FAddColumnsHeader.Count) then
      lValue := FCrossArray.CellByIndex[lRow, lCol + 1, 0]
    else
      lValue := FCrossArray.CellByIndex[lRow, lCol, 0];
    if lValue = Null then
      lStr := ''
    else
      lStr := lValue;

    lRowHeaderFlag := False;
    if lRow <= FCrossArray.TopLeftSize.cy then // header
    begin
      _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('ColumnHeaderMemo' + Name)));
      if lCurPage.Flag_ColumnNewPage and (Pos('CrossMemo_', aView.Name) = 1) then
        aView.LeftFrame.Visible := True;
      lRowHeaderFlag := True;
      if not FFlag then
      begin
        if lCol >= FCrossArray.TopLeftSize.cx then
        begin
          if lRow > 0 then
          begin
            aView.Visible := (lValue <> Null) or (lCol - FLastTotalCol.Cell[lRow - 1] = 1);
            if (aView.Visible and (lCol < FCrossArray.Columns.Count - 1)) and
              (FCrossArray.CellByIndex[lRow, lCol + 1, 0] = Null) then
            begin
              for i := lCol + 1 to FCrossArray.Columns.Count - 1 do
              begin
                ft := FCrossArray.CellByIndex[lRow, i, -1];
                if FDataWidth <= 0 then
                  j := aView.spWidth + FColumnWidths.Cell[i]
                else
                  j := aView.spWidth + FDataWidth;

                if not ((ft <> rmftTop) and (ft and rmftLeft <> 0)) then
                begin
                  if aView.spLeft + j <= lCurPage.PrinterInfo.ScreenPageWidth - lCurPage.spMarginRight then
                    aView.spWidth := j
                  else
                  begin
                    FLastTotalCol.Cell[lRow - 1] := i - 1;
                    Break;
                  end;
                end
                else
                  Break;
              end;
            end;
          end
          else
          begin
            aView.Visible := (lValue <> Null) or (lCol - FLastX = 1);
            aView.TopFrame.Visible := True;
            aView.BottomFrame.Visible := True;
            aView.RightFrame.Visible := True;

            if TRMMemoView(aView).HAlign = rmHCenter then
              TRMMemoView(aView).HAlign := rmHLeft;
            if aView.Visible and (lCol < FCrossArray.Columns.Count - 1) then
            begin
              lColCount := FCrossArray.Columns.Count - 1;
              if not ShowColumnTotal then
                Dec(lColCount);
              for i := lCol + 1 to lColCount do
              begin
                if FDataWidth <= 0 then
                  j := aView.spWidth + FColumnWidths.Cell[i]
                else
                  j := aView.spWidth + FDataWidth;
                if aView.spLeft + j <= lCurPage.PrinterInfo.ScreenPageWidth - lCurPage.spMarginRight then
                  aView.spWidth := j
                else
                begin
                  FLastX := i - 1;
                  Break;
                end;
              end;
            end;
          end;
        end
        else
        begin // lRow Header
          if lRow = FCrossArray.TopLeftSize.cy then
          begin
            aView.LeftFrame.Visible := True;
            aView.TopFrame.Visible := True;
            aView.RightFrame.Visible := True;
            aView.BottomFrame.Visible := True;
          end
          else
          begin
            lValue := '';
            if lCol = FCrossArray.TopLeftSize.cx - 1 then
            begin
              aView.LeftFrame.Visible := False;
              aView.TopFrame.Visible := False;
              aView.RightFrame.Visible := True;
              aView.BottomFrame.Visible := False;
            end
            else
            begin
              aView.LeftFrame.Visible := False;
              aView.TopFrame.Visible := False;
              aView.RightFrame.Visible := False;
              aView.BottomFrame.Visible := False;
            end;
            if (lCol = 0) then
              aView.LeftFrame.Visible := True;
            if lRow = 0 then
            begin
              aView.TopFrame.Visible := True;
              if not FCrossArray.DoDataCol then
                aView.BottomFrame.Visible := True;
              if (lCol = 0) then
              begin
                if not FCrossArray.DoDataCol then
                begin
                  for j := 1 to FCrossArray.CellItemsCount do
                    lValue := lValue + '';
                end;
              end;
            end;
          end;
        end;
      end;

      if (lCol < FCrossArray.TopLeftSize.cx) and (lRow = FCrossArray.TopLeftSize.cy) then
      begin
        if ShowRowNo then // 显示序号
        begin
          if lCol = 0 then
            lValue := RowNoHeader
          else
          begin
            if (lCol = FCrossArray.TopLeftSize.cx - 1 - 1) and FCrossArray.DoDataCol then
              lValue := RMLoadStr(rmRes + 760)
            else
              lValue := GetDictName(_GetPureString(Self.Memo.Strings[1], lCol + 1 - 1));
          end;
        end
        else
        begin
          if (lCol = FCrossArray.TopLeftSize.cx - 1) and FCrossArray.DoDataCol then
            lValue := RMLoadStr(rmRes + 760)
          else
            lValue := GetDictName(_GetPureString(Self.Memo.Strings[1], lCol + 1));
        end;
      end;
    end
    else if (lCol < FCrossArray.TopLeftSize.cx) and (lRow > FCrossArray.TopLeftSize.cy) then // lRow header
    begin
      _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('RowHeaderMemo' + Name)));
      if FFlag and (lCol = FCrossArray.TopLeftSize.cx - 1) and FCrossArray.DoDataCol then
        lValue := FMaxString;
      lRowHeaderFlag := True;
    end;

    if (lCol >= FCrossArray.Columns.Count - 1 - FAddColumnsHeader.Count) and
      (lCol <= FCrossArray.Columns.Count - 1) and (lRow > 0) then // grand total column
    begin
      if ShowColumnTotal and (lCol = FCrossArray.Columns.Count - 1 - FAddColumnsHeader.Count) then
        _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('GrandColumnTotalMemo' + Name)))
      else if lRow = FCrossArray.Rows.Count - 1 then
        _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('GrandRowTotalMemo' + Name)));
      if (not FFlag) and (lRow <= FCrossArray.TopLeftSize.cy) then
      begin
        if (FLastTotalCol.Cell[lRow - 1] < lCol) or (not ShowColumnTotal) then
        begin
          for j := lRow - 1 to FCrossArray.TopLeftSize.cy do
            FLastTotalCol.Cell[j] := lCol;
          aView.spHeight := 0;
          for j := lRow to FCrossArray.TopLeftSize.cy do
            aView.spHeight := aView.spHeight + FColumnHeights.Cell[j];
        end
        else
          aView.Visible := False;
      end;
    end
    else if lRow = FCrossArray.Rows.Count - 1 then // grand total lRow
    begin
      _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('GrandRowTotalMemo' + Name)));
      if not FFlag then
      begin
        lCurBand.spHeight := FMaxGTHeight * FCrossArray.CellItemsCount;
        if (lCol = FCrossArray.TopLeftSize.cx) and (aView.spHeight = FMaxCellHeight) then
        begin
          aView.spTop := aView.spTop - i * (FMaxCellHeight - FMaxGTHeight);
          aView.spHeight := FMaxGTHeight;
        end
        else if lCol < FCrossArray.TopLeftSize.cx then
          aView.spHeight := lCurBand.spHeight
        else
          aView.spHeight := FMaxGTHeight;
      end;
    end
    else if FCrossArray.IsTotalColumn[lCol] and (lRow > 0) then // "total" column
    begin
      if aView.LeftFrame.Visible then
      begin
        _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('ColumnTotalMemo' + Name)));
        if (not FFlag) and (lRow <= FCrossArray.TopLeftSize.cy) then
        begin
          if (FLastTotalCol.Cell[lRow - 1] < lCol) or lCurPage.Flag_NewPage then
          begin
            for j := lRow - 1 to FCrossArray.TopLeftSize.cy do
              FLastTotalCol.Cell[j] := lCol;
            aView.spHeight := 0;
            for j := lRow to FCrossArray.TopLeftSize.cy do
              aView.spHeight := aView.spHeight + FColumnHeights.Cell[j];
          end
          else
            aView.Visible := False;
        end;
      end;
    end
    else if FCrossArray.IsTotalRow[lRow] then // "total" lRow
    begin
      if (lCol >= FCrossArray.TopLeftSize.cx) or aView.TopFrame.Visible then
      begin
        _Assign(TRMMemoView(aView), TRMMemoView(ParentReport.FindObject('RowTotalMemo' + Name)));
      end;
    end;

    if not lRowHeaderFlag then
    begin
      TRMMemoView(aView).HAlign := lHAlign;
      TRMMemoView(aView).VAlign := lVAlign;
      t := TRMMemoView(ParentReport.FindObject('CellMemo' + Name));
      THackMemoView(aView).FDisplayFormat := THackMemoView(t).FDisplayFormat;
      THackMemoView(aView).FormatFlag := THackMemoView(t).FormatFlag;
    end;

    if (lCol >= FCrossArray.TopLeftSize.cx) and (lRow > FCrossArray.TopLeftSize.cy) then // cross body
    begin
      lStr := '';
      if not ShowColumnTotal and (FAddColumnsHeader.Count > 0) and (lCol >= FCrossArray.Columns.Count - 1 - FAddColumnsHeader.Count) then
        lValue := FCrossArray.CellByIndex[lRow, lCol + 1, i]
      else
        lValue := FCrossArray.CellByIndex[lRow, lCol, i];

      RMVariables['RMCrossVariable'] := lValue;
      ParentReport.CurrentView := aView;
      THackReport(ParentReport).InternalOnGetValue(aView, 'RMCrossVariable', lStr1);
      lStr := lStr1;
      if i < FCrossArray.CellItemsCount - 1 then
        aView.BottomFrame.Visible := not aView.BottomFrame.Visible;
      if i > 0 then
        aView.TopFrame.Visible := not aView.TopFrame.Visible;
    end
    else
    begin
      if lValue = Null then
        lStr := ''
      else
      begin
        RMVariables['RMCrossVariable'] := lValue;
        ParentReport.CurrentView := aView;
        THackReport(ParentReport).InternalOnGetValue(aView, 'RMCrossVariable', lStr);
        if ((VarType(lValue) = varOleStr) or (VarType(lValue) =  varString)) and
        	(lValue = RMLoadStr(rmRes + 757)) then
        begin
          THackReport(ParentReport).CurrentValue := 0;
        end;
      end;
    end;

    if Pos('CrossMemo', aView.Name) = 1 then
    begin
      lStr1 := Copy(aView.Name, 1, Pos(Name, aView.Name) - 1);
      if not ((lStr1[10] = '_') or (lStr1[10] = '@') or (lStr1[10] = '~')) then
      begin
        if lCurPage.Flag_NewPage then
          aView.TopFrame.Visible := True
        else if lCurPage.mmCurrentY + TRMReportView(lCurPage.FindObject('MasterData_' + Name)).mmHeight * 2 > lCurPage.mmCurrentBottomY then
          aView.BottomFrame.Visible := True;

        if MergeRowHeader then // 合并Row Header
        begin
          if aView.Visible then
          begin
            TRMMemoView(aView).RepeatedOptions.SuppressRepeated := True;
            TRMMemoView(aView).RepeatedOptions.MergeRepeated := True;
            THackMemoView(aView).FMergeEmpty := True;
            aView.TopFrame.Visible := True;
          end;
          if lStr <> '' then // 初始化
          begin
            lRowHeaderFlag := False;
            for i := 0 to FCrossArray.TopLeftSize.cx - 1 do
            begin
              if aView.Name = 'CrossMemo' + IntToStr(i) + Name then
              begin
                lRowHeaderFlag := True;
                Break;
              end;
            end;
            if lRowHeaderFlag then
            begin
              for i := 0 to FCrossArray.TopLeftSize.cx - 1 do
                THackMemoView(ParentReport.FindObject('CrossMemo' + IntToStr(i) + Name)).LastValue := '';
            end;
          end; // end if lStr <> ''
        end; // end if MergeRowHeader
      end;
    end;

    TRMMemoView(aView).AutoWidth := False;
    TRMMemoView(aView).WordWrap := True;
    aView.Memo.Text := lStr;
  end;

  if Assigned(FSavedOnBeforePrint) then
    FSavedOnBeforePrint(Memo, aView);
end;

type
  THackRMDataset = class(TRMDataset);

procedure TRMCrossView.OnColumnDataSetFirstEvent(Sender: TObject);
begin
  while FColumnDataSet.RecordNo < FCrossArray.TopLeftSize.cx do
    FColumnDataSet.Next;
  while FRowDataSet.RecordNo <= FCrossArray.TopLeftSize.cy do
    FRowDataSet.Next;
end;

function TRMCrossView.GetShowRowTotal: Boolean;
begin
  Result := (FFlags and flCrossShowRowTotal) <> 0;
end;

procedure TRMCrossView.SetShowRowTotal(Value: Boolean);
begin
  FFlags := (FFlags and not flCrossShowRowTotal);
  if value then
    FFlags := FFlags + flCrossShowRowTotal;
end;

function TRMCrossView.GetShowColTotal: Boolean;
begin
  Result := (FFlags and flCrossShowColTotal) <> 0;
end;

procedure TRMCrossView.SetShowColTotal(Value: Boolean);
begin
  FFlags := (FFlags and not flCrossShowColTotal);
  if value then
    FFlags := FFlags + flCrossShowColTotal;
end;

function TRMCrossView.GetShowIndicator: Boolean;
begin
  Result := (FFlags and flCrossShowIndicator) <> 0;
end;

procedure TRMCrossView.SetShowIndicator(Value: Boolean);
begin
  FFlags := (FFlags and not flCrossShowIndicator);
  if Value then
    FFlags := FFlags + flCrossShowIndicator;
end;

function TRMCrossView.GetSortColHeader: Boolean;
begin
  Result := (FFlags and flCrossSortColHeader) <> 0;
end;

procedure TRMCrossView.SetSortColHeader(Value: Boolean);
begin
  FFlags := (FFlags and not flCrossSortColHeader);
  if Value then
    FFlags := FFlags + flCrossSortColHeader;
end;

function TRMCrossView.GetSortRowHeader: Boolean;
begin
  Result := (FFlags and flCrossSortRowHeader) <> 0;
end;

procedure TRMCrossView.SetSortRowHeader(Value: Boolean);
begin
  FFlags := (FFlags and not flCrossSortRowHeader);
  if Value then
    FFlags := FFlags + flCrossSortRowHeader;
end;

function TRMCrossView.GetMergeRowHeader: Boolean;
begin
  Result := (FFlags and flCrossMergeRowHeader) <> 0;
end;

procedure TRMCrossView.SetMergeRowHeader(Value: Boolean);
begin
  FFlags := FFlags and not flCrossMergeRowHeader;
  if Value then
    FFlags := FFlags + flCrossMergeRowHeader;
end;

function TRMCrossView.GetShowRowNo: Boolean;
begin
  Result := (FFlags and flCrossShowRowNo) <> 0;
end;

procedure TRMCrossView.SetShowRowNo(Value: Boolean);
begin
  FFlags := FFlags and not flCrossShowRowNo;
  if Value then
    FFlags := FFlags + flCrossShowRowNo;
end;

function TRMCrossView.GetInternalFrame: Boolean;
begin
  Result := FInternalFrame;
end;

procedure TRMCrossView.SetInternalFrame(Value: Boolean);
begin
  FInternalFrame := Value;
end;

function TRMCrossView.GetRepeatCaptions: Boolean;
begin
  Result := FRepeatCaptions;
end;

procedure TRMCrossView.SetRepeatCaptions(Value: Boolean);
begin
  FRepeatCaptions := Value;
end;

function TRMCrossView.GetDataWidth: Integer;
begin
  Result := FDataWidth;
end;

procedure TRMCrossView.SetDataWidth(Value: Integer);
begin
  FDataWidth := Value;
end;

function TRMCrossView.GetDataHeight: Integer;
begin
  Result := FDataHeight;
end;

procedure TRMCrossView.SetDataHeight(Value: Integer);
begin
  FDataHeight := Value;
end;

function TRMCrossView.GetHeaderWidth: string;
begin
  Result := FHeaderWidth;
end;

procedure TRMCrossView.SetHeaderWidth(Value: string);
begin
  FHeaderWidth := Value;
end;

function TRMCrossView.GetHeaderHeight: string;
begin
  Result := FHeaderHeight;
end;

procedure TRMCrossView.SetHeaderHeight(Value: string);
begin
  FHeaderHeight := Value;
end;

function TRMCrossView.GetRowNoHeader: string;
begin
  Result := FRowNoHeader;
end;

procedure TRMCrossView.SetRowNoHeader(Value: string);
begin
  FRowNoHeader := Value;
end;

function TRMCrossView.GetDictName(aStr: string): string;
begin
  Result := aStr;
  if FDictionary.Values[aStr] <> EmptyStr then
    Result := FDictionary.Values[aStr];
end;

function TRMCrossView.GetDataCellText: string;
var
  lList: TStringList;
  i: Integer;
  ss: string;

  function _GoodString: string;
  var
    lList: TStringList;
    i: Integer;
    lStr, ss: string;
  begin
    lStr := Memo[3];
    lList := TStringList.Create;
    for i := 0 to CharCount(';', lStr) - 1 do
    begin
      ss := Copy(lStr, 1, Pos(';', lStr) - 1);
      Delete(lStr, 1, Pos(';', lStr));
      lList.Add(ss);
    end;

    Result := lList.Text;
    FreeAndNil(lList);
  end;

begin
  lList := TStringList.Create;
  lList.Text := _GoodString;
  FMaxString := '';
  for i := 0 to lList.Count - 1 do
  begin
    ss := lList[i];
    ss := GetDictName(ss);
    if Length(ss) > Length(FMaxString) then
      FMaxString := ss;
    lList[i] := ss;
  end;

  Result := lList.Text;
  lList.Free;
end;

function TRMCrossView.GetHeaderHeightByIndex(aIndex: Integer): Integer;
var
  lPos: Integer;
  lStr: string;
begin
  lstr := FHeaderHeight;
  lPos := Pos(';', lstr);
  while (aIndex > 0) and (lPos > 0) do
  begin
    Dec(aIndex);
    Delete(lstr, 1, lPos);
    lPos := Pos(';', lstr);
  end;

  if (aIndex > 0) or (lstr = '') then
    lstr := FHeaderHeight;
  lPos := Pos(';', lstr);
  if lPos > 0 then
    lstr := Copy(lstr, 1, lPos - 1);
  Result := StrToInt(lstr);
end;

function TRMCrossView.GetHeaderWidthByIndex(aIndex: Integer): Integer;
var
  lPos: Integer;
  lStr: string;
begin
  if not ShowRowNo then Inc(aIndex);
  lstr := FHeaderWidth;
  lPos := Pos(';', lstr);
  while (aIndex > 0) and (lPos > 0) do
  begin
    Dec(aIndex);
    Delete(lstr, 1, lPos);
    lPos := Pos(';', lstr);
  end;

  if (aIndex > 0) or (lstr = '') then
    lstr := FHeaderWidth;
  lPos := Pos(';', lstr);
  if lPos > 0 then
    lstr := Copy(lstr, 1, lPos - 1);
  Result := StrToInt(lstr);
end;

procedure TRMCrossView.Prepare;
var
  i: Integer;
  lValue: TRMView;
//  lRMDBDataSet: TRMDBDataSet;
  lRMDataset: TRMDataset;
//  lDataSet: TDataSet;
  lStr: string;
begin
  if THackReport(ParentReport).IsSecondTime then Exit;

  Visible := False;
  FSkip := False;
  if (Memo.Count < 4) or (Trim(Memo[0]) = '') {or (Trim(Memo[1]) = '')} {or
    (Trim(Memo[2]) = '')} or (Trim(Memo[3]) = '') then
  begin
    FSkip := True;
    Exit;
  end;

  if ParentReport.FindObject('ColumnHeaderMemo' + Name) = nil then
    CreateObjects;

//  lDataSet := nil;

  //dejoy 2006-07-12 21:54
  lRMDataset := ParentReport.Dictionary.FindDataSet(Memo[0], ParentReport.Owner,lStr);
  if (lRMDataset <> nil) and (lRMDataset is TRMDBDataSet) then
  begin
    //lRMDBDataSet := TRMDBDataSet(lRMDataset) ;
    //lDataSet := lRMDBDataSet.DataSet;
  end;
  FCrossArray := TRMCrossArray.Create(ParentReport, lRMDataset, Memo[1], Memo[2], Memo[3]);
  FCrossArray.SortColHeader := SortColHeader;
  FCrossArray.SortRowHeader := SortRowHeader;

  if FCrossArray.FRMDataSet = nil then
  begin
    FCrossArray.Free;
    FSkip := True;
    Exit;
  end;

  lValue := ParentReport.FindObject('ColumnTotalMemo' + Name);
  if (lValue <> nil) and (lValue.Memo.Count > 0) then
    FCrossArray.ColumnTotalString := lValue.Memo[0];

  if ShowColumnTotal then
  begin
    lValue := ParentReport.FindObject('GrandColumnTotalMemo' + Name);
    if (lValue <> nil) and (lValue.Memo.Count > 0) then
      FCrossArray.ColumnGrandTotalString := lValue.Memo[0];
  end;

  lValue := ParentReport.FindObject('RowTotalMemo' + Name);
  if (lValue <> nil) and (lValue.Memo.Count > 0) then
    FCrossArray.RowTotalString := lValue.Memo[0];

  if ShowRowTotal then
  begin
    lValue := ParentReport.FindObject('GrandRowTotalMemo' + Name);
    if (lValue <> nil) and (lValue.Memo.Count > 0) then
      FCrossArray.RowGrandTotalString := lValue.Memo[0];
  end;

  FCrossArray.HeaderString := ' ';
  for i := 1 to CharCount(';', Memo.Strings[2]) do
  begin
    if i > 1 then
      FCrossArray.HeaderString := FCrossArray.HeaderString + '    ';
    FCrossArray.HeaderString := FCrossArray.HeaderString + GetDictName(_GetPureString(Memo.Strings[2], i));
  end;

  FCrossArray.DoDataCol := (CharCount(';', Memo[3]) > 1) and FShowHeader;
  FCrossArray.DataStr := GetDataCellText;
  FCrossArray.ShowRowNo := ShowRowNo;
  FCrossArray.FAddColumnsHeader.Assign(FAddColumnsHeader);

  FCrossArray.Build;
  if FCrossArray.Columns.Count = 0 then
  begin
    FCrossArray.Free;
    FSkip := True;
    Exit;
  end;

  FRowDataSet := TRMUserDataset.Create(ParentReport.Owner);
  FRowDataSet.Name := 'RowDataSet' + Name;
  FRowDataSet.RangeEnd := rmreCount;
  FRowDataSet.RangeEndCount := FCrossArray.Rows.Count;

  FColumnDataSet := TRMUserDataset.Create(ParentReport.Owner);
  FColumnDataSet.Name := 'ColumnDataSet' + Name;
  FColumnDataSet.RangeEnd := rmreCount;
  FColumnDataSet.RangeEndCount := FCrossArray.Columns.Count;
  THackRMDataset(FColumnDataSet).FOnAfterFirst := OnColumnDataSetFirstEvent;

  MakeBands;

  //ParentReport.SaveToFile('e:\ls.rmf');
  inherited;
end;

procedure TRMCrossView.MakeBands;
var
  i, d, d1, dx, dh: Integer;
  lBandMasterHeader: TRMBandHeader;
  lBandMasterData: TRMBandMasterData;
  lBandCrossHeader: TRMBandCrossHeader;
  lBandCrossMasterData: TRMBandCrossMasterData;
  t, t1: TRMMemoView;
  lPage: TRMReportPage;
begin
  lPage := ParentPage;

  lBandMasterHeader := TRMBandHeader.Create; // master header
  lBandMasterHeader.ParentPage := lPage;
  lBandMasterHeader.Name := 'Header_' + Name;
  lBandMasterHeader.SetspBounds(0, 400, 0, FDefDY);
  lBandMasterHeader.ReprintOnNewPage := FRepeatCaptions;

  lBandMasterData := TRMBandMasterData.Create; // master data
  lBandMasterData.ParentPage := lPage;
  lBandMasterData.Name := 'MasterData_' + Name;
  lBandMasterData.SetspBounds(0, 500, 0, FDefDY);
  lBandMasterData.DataSetName := FRowDataSet.Name;
//  lBandMasterData.CrossDataSetName := 'ColumnDataSet' + Name;
  lBandMasterData.Stretched := True;

  lBandCrossHeader := TRMBandCrossHeader.Create; // cross header
  lBandCrossHeader.ParentPage := lPage;
  lBandCrossHeader.Name := 'CrossHeader_' + Name;
  lBandCrossHeader.SetspBounds(lPage.spMarginLeft, 0, 60, FDefDY);
  lBandCrossHeader.ReprintOnNewPage := True;

  lBandCrossMasterData := TRMBandCrossMasterData.Create; // cross data
  lBandCrossMasterData.ParentPage := lPage;
  lBandCrossMasterData.Name := 'CrossMasterData_' + Name;
  lBandCrossMasterData.SetspBounds(500, 0, 60, FDefDY);
  lBandCrossMasterData.DataSetName := FColumnDataSet.Name;

  d := lBandMasterData.spTop;
  dh := lBandMasterData.spHeight;
  for i := 0 to FCrossArray.CellItemsCount - 1 do
  begin
    t := TRMMemoView.Create;
    t.ParentPage := lPage;
    t.Name := 'CrossMemo@' + IntToStr(i) + Name;
    t.SetspBounds(lBandCrossMasterData.spLeft, d, lBandCrossMasterData.spWidth, dh);
    Inc(d, dh);
    lBandMasterData.spHeight := lBandMasterData.spHeight + dh;
  end;

  ParentReport.CurrentPage := nil;
  CalcWidths;

  lBandMasterHeader.spHeight := 0;
  d := lBandMasterHeader.spTop;
  for i := 0 to FCrossArray.TopLeftSize.cy - 1 + ord(FShowHeader) do // 交叉表数据栏 + 主项标头栏
  begin
    t := TRMMemoView.Create;
    t.ParentPage := lPage;
    dh := FColumnHeights.Cell[i + Ord(not FShowHeader)];
    t.SetspBounds(lBandCrossMasterData.spLeft, d, lBandCrossMasterData.spWidth, dh);
    t.Name := 'CrossMemo_' + IntToStr(i) + Name;
    lBandMasterHeader.spHeight := lBandMasterHeader.spHeight + dh;
    Inc(d, dh);
  end;

  lBandMasterData.spTop := lBandMasterHeader.spTop + lBandMasterHeader.spHeight + 30;
  lBandMasterData.spHeight := FMaxCellHeight * FCrossArray.CellItemsCount;
  dh := FMaxCellHeight;
  d := lBandMasterData.spTop;
  for i := 0 to FCrossArray.CellItemsCount - 1 do // 交叉表数据栏 + 主项数据栏
  begin
    t := TRMMemoView(ParentReport.FindObject('CrossMemo@' + IntToStr(i) + Name));
    t.ParentPage := lPage;
    t.spTop := d;
    t.spHeight := dh;
    Inc(d, dh);
  end;

  lBandCrossHeader.spWidth := 0;
  d := lBandCrossHeader.spLeft;
  for i := 0 to FCrossArray.TopLeftSize.cx - 1 do // 交叉表标头栏 + 主项数据栏
  begin
    t := TRMMemoView.Create;
    t.ParentPage := lPage;
    if (FHeaderWidth = '') or (FHeaderWidth = '0') then
      dx := FColumnWidths.Cell[i]
    else
      dx := GetHeaderWidthByIndex(i);

    t.SetspBounds(d, lBandMasterData.spTop, dx, lBandMasterData.spHeight);
    t.Name := 'CrossMemo' + IntToStr(i) + Name;
    lBandCrossHeader.spWidth := lBandCrossHeader.spWidth + dx;
    Inc(d, dx);
  end;

  if ShowIndicator or FShowHeader then
  begin
    t1 := TRMMemoView(lPage.FindObject('CrossHeaderMemo' + Name));
    if t1 <> nil then
    begin
      d := 0;
      for i := 0 to FCrossArray.TopLeftSize.cy - 1 do
      begin
        d := d + FColumnHeights.Cell[i + Ord(not FShowHeader)];
      end;

      t := TRMMemoView.Create;
      t.ParentPage := lPage;
      t.Name := 'IndicatorMemo0' + Name;
      t.SetspBounds(lBandCrossHeader.spLeft, lBandMasterHeader.spTop, 0, lBandMasterHeader.spHeight);
      t.LeftFrame.Visible := True;
      t.RightFrame.Visible := True;
      t.TopFrame.Visible := True;
      t.BottomFrame.Visible := True;

      t.spHeight := d;
      t.spWidth := 0;
      for i := 0 to FCrossArray.TopLeftSize.cx - 1 do
      begin
        if (FHeaderWidth = '') or (FHeaderWidth = '0') then
          t.spWidth := t.spWidth + FColumnWidths[i]
        else
          t.spWidth := t.spWidth + GetHeaderWidthByIndex(i);
      end;

      THackMemoView(t).FFlags := THackMemoView(t1).FFlags;
      THackMemoView(t).IsChildView := False;
      t.RotationType := TRMMemoView(t1).RotationType;
      t.LeftFrame.Assign(t1.LeftFrame);
      t.RightFrame.Assign(t1.RightFrame);
      t.TopFrame.Assign(t1.TopFrame);
      t.BottomFrame.Assign(t1.BottomFrame);
      t.FillColor := t1.FillColor;
      THackMemoView(t).FDisplayFormat := THackMemoView(t1).FDisplayFormat;
      THackMemoView(t).FormatFlag := THackMemoView(t1).FormatFlag;
      t.spGapLeft := TRMMemoView(t1).spGapLeft;
      t.spGapTop := TRMMemoView(t1).spGapTop;
      t.Highlight.Assign(TRMMemoView(t1).Highlight);
      t.LineSpacing := TRMMemoView(t1).LineSpacing;
      t.CharacterSpacing := TRMMemoView(t1).CharacterSpacing;
      t.Font.Assign(TRMMemoView(t1).Font);
      t.Memo.Assign(t1.Memo);
      t.HAlign := TRMMemoView(t1).HAlign;
      t.VAlign := TRMMemoView(t1).VAlign;
    end;
  end;

  if FShowHeader then
  begin
    d := lBandMasterHeader.spTop;
    for i := 0 to FCrossArray.TopLeftSize.cy - 1 do
      d := d + FColumnHeights.Cell[i];

    d1 := lBandCrossHeader.spLeft;
    dh := FColumnHeights.Cell[FCrossArray.TopLeftSize.cy];
    for i := 0 to FCrossArray.TopLeftSize.cx - 1 do
    begin
      t := TRMMemoView.Create;
      t.ParentPage := lPage;
      if (FHeaderWidth = '') or (FHeaderWidth = '0') then
        dx := FColumnWidths.Cell[i]
      else
        dx := GetHeaderWidthByIndex(i);

      t.SetspBounds(d1, d, dx, dh);
      t.Name := 'CrossMemo~' + IntToStr(FCrossArray.TopLeftSize.cy) + '~' + IntToStr(i) + Name;
      Inc(d1, dx);
    end;
  end;
end;

procedure TRMCrossView.UnPrepare;
begin
  if not FSkip then
  begin
    FreeAndNil(FCrossArray);
    FreeAndNil(FRowDataSet);
    FreeAndNil(FColumnDataSet);
    FreeAndNil(FColumnWidths);
    FreeAndNil(FColumnHeights);
    FreeAndNil(FLastTotalCol);
  end;

  inherited;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMCrossForm}

procedure TRMCrossForm.FillDatasetsLB;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  DatasetsLB.Items.BeginUpdate;
  RMDesigner.Report.Dictionary.GetDataSets(DatasetsLB.Items);
  DatasetsLB.Items.EndUpdate;
  sl.Free;
end;

procedure TRMCrossForm.DatasetsLBClick(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
begin
  if Integer(DatasetsLB.Items.Objects[DatasetsLB.ItemIndex]) = 1 then
  begin
    sl := TStringList.Create;
    RMDesigner.Report.Dictionary.GetVariablesList(DatasetsLB.Items[DatasetsLB.ItemIndex], sl);
    FieldsLB.Items.Clear;
    for i := 0 to sl.Count - 1 do
      FieldsLB.Items.AddObject(sl[i], TObject(1));
    sl.Free;
  end
  else
    RMDesigner.Report.Dictionary.GetDataSetFields(DatasetsLB.Items[DatasetsLB.ItemIndex],
      FieldsLB.Items)
end;

procedure TRMCrossForm.ListBox3Enter(Sender: TObject);
begin
  FListBox := TListBox(Sender);
end;

procedure TRMCrossForm.ClearSelection(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to GroupBox1.ControlCount - 1 do
  begin
    if (GroupBox1.Controls[i] <> Sender) and (GroupBox1.Controls[i] is TListBox) then
      (GroupBox1.Controls[i] as TListBox).ItemIndex := -1;
  end;
  CheckBox1.Enabled := Sender <> ListBox4;
  ComboBox2.Enabled := Sender = ListBox4;
end;

procedure TRMCrossForm.ListBox3Click(Sender: TObject);
var
  lStr: string;
begin
  if (FListBox <> nil) and (FListBox.ItemIndex <> -1) then
  begin
    lStr := FListBox.Items[FListBox.ItemIndex];
    FBusy := True;
    CheckBox1.Checked := Pos('+', lStr) <> 0;
    FBusy := False;
  end;
  ClearSelection(Sender);
end;

procedure TRMCrossForm.CheckBox1Click(Sender: TObject);
var
  i: Integer;
  lStr: string;
begin
  if FBusy then
    Exit;
  if (FListBox <> nil) and (FListBox.ItemIndex <> -1) then
  begin
    i := FListBox.ItemIndex;
    lStr := FListBox.Items[i];
    if Pos('+', lStr) <> 0 then
      lStr := Copy(lStr, 1, Length(lStr) - 1)
    else
      lStr := lStr + '+';
    FListBox.Items[i] := lStr;
    FListBox.ItemIndex := i;
  end;
  TDrawPanel(DrawPanel).Paint;
end;

procedure TRMCrossForm.ListBox4Click(Sender: TObject);
var
  lStr: string;
begin
  FBusy := True;
  if ListBox4.ItemIndex <> -1 then
  begin
    ComboBox2.Enabled := True;
    lStr := ListBox4.Items[ListBox4.ItemIndex];
    if Pos('+', lStr) = 0 then
      ComboBox2.ItemIndex := 0
    else
    begin
      lStr := AnsiLowerCase(Copy(lStr, Pos('+', lStr) + 1, 255));
      if (lStr = '') or (lStr = 'sum') then
        ComboBox2.ItemIndex := 1
      else if lStr = 'min' then
        ComboBox2.ItemIndex := 2
      else if lStr = 'max' then
        ComboBox2.ItemIndex := 3
      else if lStr = 'avg' then
        ComboBox2.ItemIndex := 4
      else if lStr = 'count' then
        ComboBox2.ItemIndex := 5
    end;
  end;
  FBusy := False;
  ClearSelection(Sender);
end;

procedure TRMCrossForm.ComboBox2Click(Sender: TObject);
var
  i: Integer;
  lStr: string;
begin
  if FBusy then
    Exit;
  if ListBox4.ItemIndex <> -1 then
  begin
    i := ListBox4.ItemIndex;
    lStr := PureName1(ListBox4.Items[i]);
    case ComboBox2.ItemIndex of
      0: ;
      1: lStr := lStr + '+';
      2: lStr := lStr + '+min';
      3: lStr := lStr + '+max';
      4: lStr := lStr + '+avg';
      5: lStr := lStr + '+count';
    end;
    ListBox4.Items[i] := lStr;
    ListBox4.ItemIndex := i;
  end;
end;

procedure TRMCrossForm.ListBox3DblClick(Sender: TObject);
begin
  CheckBox1.Checked := not CheckBox1.Checked;
end;

procedure TRMCrossForm.ListBox4DrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  lStr: string;
begin
  with TListBox(Control).Canvas do
  begin
    lStr := TListBox(Control).Items[Index];
    FillRect(ARect);
    if Pos('+', lStr) <> 0 then
    begin
      TextOut(ARect.Left + 1, ARect.Top, Copy(lStr, 1, Pos('+', lStr) - 1));
      lStr := Copy(lStr, Pos('+', lStr) + 1, 255);
      if lStr = '' then
      begin
        if Control = ListBox4 then
          lStr := 'sum'
        else
          lStr := 'total';
      end;
      TextOut(ARect.Right - TextWidth(lStr) - 2, ARect.Top, lStr);
    end
    else
      TextOut(ARect.Left + 1, ARect.Top, lStr);
  end;
end;

procedure TRMCrossForm.FieldsLBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := TListBox(Source).Items.Count > 0;
end;

function GetLBIndex(LB: TListBox; lStr: string): Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to LB.Items.Count - 1 do
  begin
    if PureName1(Lb.Items[i]) = lStr then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TRMCrossForm.FieldsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  lStr: string;
  i: Integer;
  L4Exist: Boolean;
begin
  if (Source = Sender) and (Source <> FieldsLB) then
  begin
    i := TListBox(Source).ItemAtPos(Point(x, y), True);
    if i = -1 then
      i := TListBox(Source).Items.Count - 1;
    TListBox(Source).Items.Exchange(TListBox(Source).ItemIndex, i);
  end
  else if Source <> Sender then
  begin
    if TListBox(Source).ItemIndex = -1 then
      Exit;
    lStr := PureName1(TListBox(Source).Items[TListBox(Source).ItemIndex]);
    L4Exist := GetLBIndex(ListBox4, lStr) >= 0;
    if Source = FieldsLB then
      lStr := lStr + '+';
    if (not ((Source = ListBox4) and (Sender = FieldsLB))) and
      (not ((Source = FieldsLB) and (Sender <> ListBox4) and L4Exist)) then
      TListBox(Sender).Items.Add(lStr);
    i := GetLBIndex(FieldsLB, PureName1(lStr));
    if (Source = ListBox4) and (Sender <> FieldsLB) and (i <> -1) then
    begin
      FieldsLB.Items.Delete(i);
      repeat
        i := GetLBIndex(ListBox4, PureName1(lStr));
        if i <> -1 then
          ListBox4.Items.Delete(i);
      until i = -1;
    end;
    if (Source <> FieldsLB) and (Sender = ListBox4) then
      FieldsLB.Items.Add(lStr);
    if (not ((Source = FieldsLB) and (Sender = ListBox4))) and (not ((Source = FieldsLB) and L4Exist)) then
    begin
      i := TListBox(Source).ItemIndex;
      if (i <> -1) and (Pos(PureName1(lStr), TListBox(Source).Items[i]) = 1) then
        TListBox(Source).Items.Delete(i);
    end;
  end;
  TDrawPanel(DrawPanel).Paint;
end;

procedure TRMCrossForm.FormShow(Sender: TObject);
var
  i: Integer;
  sl: TStringList;
  lStr: string;
begin
  sl := TStringList.Create;
  FillDatasetsLB;
  if DatasetsLB.Items.Count = 0 then
    Exit;

  if Cross.Memo.Count >= 4 then
  begin
    i := DatasetsLB.Items.IndexOf(Cross.Memo[0]);
    if i <> -1 then
    begin
      DatasetsLB.ItemIndex := i;
      DatasetsLBClick(nil);

      RMSetCommaText(Cross.Memo[1], sl);
      for i := 0 to sl.Count - 1 do
      begin
        lStr := PureName1(sl[i]);
        if FieldsLB.Items.IndexOf(lStr) <> -1 then
          FieldsLB.Items.Delete(FieldsLB.Items.IndexOf(lStr));
      end;
      ListBox2.Items.Assign(sl);

      RMSetCommaText(Cross.Memo[2], sl);
      for i := 0 to sl.Count - 1 do
      begin
        lStr := PureName1(sl[i]);
        if FieldsLB.Items.IndexOf(lStr) <> -1 then
          FieldsLB.Items.Delete(FieldsLB.Items.IndexOf(lStr));
      end;
      ListBox3.Items.Assign(sl);

      RMSetCommaText(Cross.Memo[3], sl);
      ListBox4.Items.Assign(sl);
    end;
  end
  else
  begin
    if DatasetsLB.Items.Count > 0 then
      DatasetsLB.ItemIndex := 0;
    DatasetsLBClick(nil);
    ListBox2.Clear;
    ListBox3.Clear;
    ListBox4.Clear;
  end;

  sl.Free;
end;

procedure TRMCrossForm.FormHide(Sender: TObject);
var
  i: Integer;
  lStr: string;
begin
  if ModalResult = mrOk then
  begin
    RMDesigner.BeforeChange;
    Cross.Memo.Clear;
    Cross.Memo.Add(DatasetsLB.Items[DatasetsLB.ItemIndex]);

    lStr := '';
    for i := 0 to ListBox2.Items.Count - 1 do
      lStr := lStr + ListBox2.Items[i] + ';';
    Cross.Memo.Add(lStr);

    lStr := '';
    for i := 0 to ListBox3.Items.Count - 1 do
      lStr := lStr + ListBox3.Items[i] + ';';
    Cross.Memo.Add(lStr);

    lStr := '';
    for i := 0 to ListBox4.Items.Count - 1 do
      lStr := lStr + ListBox4.Items[i] + ';';
    Cross.Memo.Add(lStr);
  end;
end;

procedure TRMCrossForm.FormCreate(Sender: TObject);
begin
  Localize;
  DrawPanel := TDrawPanel.Create(Self);
  DrawPanel.Parent := Self;
  DrawPanel.Align := alBottom;
  DrawPanel.Height := ClientHeight - 244;
  DrawPanel.BevelOuter := bvNone;
  DrawPanel.BorderStyle := bsSingle;
end;

procedure TRMCrossForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 750);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 751);
  RMSetStrProp(CheckBox1, 'Caption', rmRes + 752);
  RMSetStrProp(Label1, 'Caption', rmRes + 753);
  RMSetStrProp(Self, 'Caption', rmRes + 754);

  btnOK.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDrawPanel }

procedure TDrawPanel.Draw(x, y, dx, dy: Integer; aStr: string);
begin
  with Canvas do
  begin
    Pen.Color := clBlack;
    Rectangle(x, y, x + dx + 1, y + dy + 1);
    TextRect(Rect(x + 1, y + 1, x + dx - 1, y + dy - 1), x + 3, y + 3, aStr);
  end;
end;

procedure TDrawPanel.DrawColumnCells;
var
  i, StartX, CurX, CurY, CurDX, CurDY: Integer;
  lStr: string;
begin
  CurX := 10 + FRowFields.Count * DefDX;
  CurY := 10 + (FColumnFields.Count - 1) * DefDY;
  CurDX := DefDX; CurDY := DefDY;
  StartX := CurX;

  i := FColumnFields.Count - 1;

// create cell
  Canvas.Brush.Color := clWhite;
  Draw(CurX, CurY, CurDX, CurDY, PureName1(FColumnFields[i]));
  Dec(CurY, DefDY);
  Inc(CurDY, DefDY);
  Inc(CurX, DefDX);

  Dec(i);
  while i >= -1 do
  begin
// Header cell
    Canvas.Brush.Color := clWhite;
    if i <> -1 then
      Draw(StartX, CurY, CurDX, DefDY, PureName1(FColumnFields[i]));

// Total cell
    if (i = -1) or (Pos('+', FColumnFields[i]) <> 0) then
    begin
      Canvas.Brush.Color := $F5F5F5;
      if i <> -1 then
        lStr := RMLoadStr(rmRes + 759) {'Total of '} + PureName1(FColumnFields[i])
      else
      begin
        Inc(CurY, DefDY);
        Dec(CurDY, DefDY);
        Canvas.Brush.Color := clSilver;
        lStr := RMLoadStr(rmRes + 757); //'Grand total';
      end;
      LastX := CurX + DefDX;
      Draw(CurX, CurY, DefDX, CurDY, lStr);
      Inc(CurDX, DefDX);
      Inc(CurX, DefDX);
    end;
    Dec(CurY, DefDY);
    Inc(CurDY, DefDY);

    Dec(i);
  end;
end;

procedure TDrawPanel.DrawRowCells;
var
  i, StartY, CurX, CurY, CurDX, CurDY, DefDY: Integer;
begin
  DefDY := Self.DefDY;
  CurX := 10 + (FRowFields.Count - 1) * DefDX;
  CurY := 10 + FColumnFields.Count * DefDY;
  StartY := CurY;
  DefDY := 18 * FCellFields.Count;
  CurDX := DefDX; CurDY := DefDY;

  i := FRowFields.Count - 1;

// create cell
  Canvas.Brush.Color := clWhite;
  Draw(CurX, CurY, CurDX, CurDY, PureName1(FRowFields[i]));
  Dec(CurX, DefDX);
  Inc(CurY, DefDY);
  Inc(CurDX, DefDX);

  Dec(i);
  while i >= 0 do
  begin
// Header cell
    Canvas.Brush.Color := clWhite;
    Draw(CurX, StartY, DefDX, CurDY, PureName1(FRowFields[i]));

// Total cell
    if Pos('+', FRowFields[i]) <> 0 then
    begin
      Canvas.Brush.Color := $F5F5F5;
      Draw(CurX, CurY, CurDX, DefDY, RMLoadStr(rmRes + 759) {'Total of '} + PureName1(FRowFields[i]));
      Inc(CurY, DefDY);
      Inc(CurDY, DefDY);
    end;

    Dec(CurX, DefDX);
    Inc(CurDX, DefDX);
    Dec(i);
  end;

// Grand total cell
  Canvas.Brush.Color := clSilver;
  LastY := CurY + DefDY;
  Draw(CurX + DefDX, CurY, CurDX - DefDX, DefDY, RMLoadStr(rmRes + 757) {'Grand total'});
end;

procedure TDrawPanel.DrawCellField;
var
  i, CurX, CurY: Integer;
begin
  CurX := 10 + FRowFields.Count * DefDX;
  CurY := 10 + FColumnFields.Count * DefDY;
  Canvas.Brush.Color := clWhite;

  for i := 0 to FCellFields.Count - 1 do
  begin
    Draw(CurX, CurY, DefDX, DefDY, PureName1(FCellFields[i]));
    Inc(CurY, DefDY);
  end;
end;

procedure TDrawPanel.DrawBorderLines(pos: byte);
begin
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Style := psDashDot;
  if Pos = 0 then
    Draw(10, 10, FRowFields.Count * DefDX, FColumnFields.Count * DefDY, '')
  else
  begin
    Canvas.MoveTo(10 + FRowFields.Count * DefDX, LastY);
    Canvas.LineTo(LastX, LastY);
    Canvas.MoveTo(LastX, 10 + FColumnFields.Count * DefDY);
    Canvas.LineTo(LastX, LastY);
  end;
  Canvas.Pen.Style := psSolid;
end;

procedure TDrawPanel.Paint;
begin
  Color := clWhite;
  inherited;
  FColumnFields := TRMCrossForm(Parent).ListBox3.Items;
  FRowFields := TRMCrossForm(Parent).ListBox2.Items;
  FCellFields := TRMCrossForm(Parent).ListBox4.Items;
  if (FColumnFields.Count < 1) or
    (FRowFields.Count < 1) or
    (FCellFields.Count < 1) then
    Exit;

  DefDx := 72; DefDy := 18;
  DrawBorderLines(0);
  DrawRowCells;
  DrawColumnCells;
  DrawCellField;
  DrawBorderLines(1);
end;

procedure TRMCrossForm.btnExchangeClick(Sender: TObject);
var
  lStr: string;
begin
  lStr := ListBox2.Items.Text;
  ListBox2.Items.Text := ListBox3.Items.Text;
  ListBox3.Items.Text := lStr;
  DrawPanel.Invalidate;
end;

procedure TRMCrossForm.ListBox3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lStr: string;
  i: Integer;
begin
  if Key = VK_DELETE then
  begin
    if TListBox(Sender).ItemIndex = -1 then
      Exit;
    lStr := PureName1(TListBox(Sender).Items[TListBox(Sender).ItemIndex]);
    FieldsLB.Items.Add(lStr);
    i := TListBox(Sender).ItemIndex;
    if (i <> -1) and (Pos(PureName1(lStr), TListBox(Sender).Items[i]) = 1) then
      TListBox(Sender).Items.Delete(i);

    TDrawPanel(DrawPanel).Paint;
  end;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TAddColumnsHeaderEditor = class(TELStringPropEditor)
  protected
    function GetValue: string; override;
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TDictionaryEditor = class(TELStringPropEditor)
  protected
    function GetValue: string; override;
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

function TAddColumnsHeaderEditor.GetValue: string;
begin
  Result := '(TStrings)';
end;

function TAddColumnsHeaderEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praReadOnly];
end;

procedure TAddColumnsHeaderEditor.Edit;
var
  tmp: TELStringsEditorDlg;
  t: TRMCrossView;
begin
  t := TRMCrossView(GetInstance(0));
  tmp := TELStringsEditorDlg.Create(nil);
  try
    tmp.Lines.Assign(t.FAddColumnsHeader);
    if tmp.ShowModal = mrOK then
      t.FAddColumnsHeader.Assign(tmp.Lines);
  finally
    tmp.Free;
  end;
end;

function TDictionaryEditor.GetValue: string;
begin
  Result := '(TStrings)';
end;

function TDictionaryEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praReadOnly];
end;

procedure TDictionaryEditor.Edit;
var
  i: Integer;
  tmp: TELStringsEditorDlg;
  t: TRMCrossView;
begin
  t := TRMCrossView(GetInstance(0));
  if t.Memo.Count < 4 then Exit;

  if (t.FDictionary.Count = 0) then
  begin
    for i := 1 to CharCount(';', t.Memo[1]) do
      t.FDictionary.Add(_GetPureString(t.Memo[1], i) + '=');
    for i := 1 to CharCount(';', t.Memo[2]) do
      t.FDictionary.Add(_GetPureString(t.Memo[2], i) + '=');
    for i := 1 to CharCount(';', t.Memo[3]) do
      t.FDictionary.Add(_GetString(t.Memo[3], i) + '=');
  end;

  tmp := TELStringsEditorDlg.Create(nil);
  try
    tmp.Lines.Assign(t.FDictionary);
    if tmp.ShowModal = mrOK then
      t.FDictionary.Assign(tmp.Lines);
  finally
    tmp.Free;
  end;
end;

initialization
  RMRegisterObjectByRes(TRMCrossView, 'RM_CrossObject', RMLoadStr(SInsertCrosstab), TRMCrossForm);

  RMRegisterPropEditor(TypeInfo(TStrings), TRMCrossView, 'Dictionary', TDictionaryEditor);
  RMRegisterPropEditor(TypeInfo(TStrings), TRMCrossView, 'AddColumnHeader', TAddColumnsHeaderEditor);

finalization
  FCrossList.Free;
  FCrossList := nil;

end.

