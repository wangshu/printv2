
{*****************************************}
{                                         }
{   Report Machine v2.0 - Data storage    }
{            Report Explorer              }
{                                         }
{*****************************************}

unit RMD_ReportExplorer;

interface

{$I RM.INC}

uses
  Windows, Classes, SysUtils, Forms, Controls, Graphics, Menus, Dialogs, ComCtrls,
  DB, RM_Class
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  rmitAllFolders = 0;
  rmitReport = 1;
  rmitFolder = 255;
  rmitRecycleBin = -2;

type
  TRMRenameFolderEvent = procedure(Sender: TObject; aFolderId: Integer; const aNewName: string) of object;
  TRMReportExplorer = class;

  { TRMFolderFieldNames }
  TRMFolderFieldNames = class(TPersistent)
  private
    FName: string;
    FFolderId: string;
    FParentId: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FolderId: string read FFolderId write FFolderId;
    property Name: string read FName write FName;
    property ParentId: string read FParentId write FParentId;
  end;

  { TRMItemFieldNames }
  TRMItemFieldNames = class(TPersistent)
  private
    FDeleted: string;
    FFolderId: string;
    FItemId: string;
    FModified: string;
    FName: string;
    FSize: string;
    FTemplate: string;
    FItemType: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Deleted: string read FDeleted write FDeleted;
    property FolderId: string read FFolderId write FFolderId;
    property ItemId: string read FItemId write FItemId;
    property Modified: string read FModified write FModified;
    property Name: string read FName write FName;
    property Size: string read FSize write FSize;
    property Template: string read FTemplate write FTemplate;
    property ItemType: string read FItemType write FItemType;
  end;

  { TRMFolderInfo }
  TRMFolderInfo = class
  private
    FName: string;
    FFolderId: Integer;
    FParentId: Integer;
  public
    property Name: string read FName write FName;
    property FolderId: Integer read FFolderId write FFolderId;
    property ParentId: Integer read FParentId write FParentId;
  end;

  { TRMItemInfo }
  TRMItemInfo = class
  private
    FDeleted: TDateTime;
    FFolderId: Integer;
    FItemId: Integer;
    FModified: TDateTime;
    FName: string;
    FSize: Integer;
    FItemType: Integer;
  public
    property Deleted: TDateTime read FDeleted write FDeleted;
    property FolderId: Integer read FFolderId write FFolderId;
    property ItemId: Integer read FItemId write FItemId;
    property Modified: TDateTime read FModified write FModified;
    property Name: string read FName write FName;
    property Size: Integer read FSize write FSize;
    property ItemType: Integer read FItemType write FItemType;
  end;

  PRMListItemData = ^TRMListItemData;
  TRMListItemData = packed record
    ItemId: Integer;
    ItemType: Smallint;
  end;

  { TRMItemListView }
  TRMItemListView = class(TListView)
  private
    FAllFolders: Boolean;
    FFolderId: Integer;
    FOnDoubleClick: TNotifyEvent;
    FOnFolderChange: TNotifyEvent;
    FOnRenameFolder: TRMRenameFolderEvent;
    FOnSelectionChange: TNotifyEvent;
    FReportExplorer: TRMReportExplorer;
    FSelectionCount: Integer;
    FSelectionSize: Integer;
    FSortMode: Integer;

    procedure DoOnFolderChange;
    procedure DoOnRenameFolder(aFolderId: Integer; const aNewName: string);
    procedure DoOnSelectionChange;
    function GetItemId: Integer;
    function GetItemName: string;
    function GetItemType: Integer;
    procedure GetItemsForFolder;
    procedure GetSelectedItems(aList: TStrings);
    procedure SetFolderId(aFolderId: Integer);
    procedure SetItemName(aName: string);
    procedure SetReportExplorer(aExplorer: TRMReportExplorer);
    procedure SetSortMode(aSortMode: Integer);
    procedure SetSortModeDescription;

    procedure ChangeEvent(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure CompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ColumnClickEvent(Sender: TObject; Column: TListColumn);
    procedure DblClickEvent(Sender: TObject);
    procedure DragDropEvent(Sender, Source: TObject; X, Y: Integer);
    procedure DragOverEvent(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure EditedEvent(Sender: TObject; Item: TListItem; var S: string);
    procedure EditingEvent(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
  protected
    procedure SetParent(aParent: TWinControl); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure DeleteSelection;
    procedure EmptyRecycleBin;
    procedure MoveSelectionToFolder(aFolderId: Integer);
    procedure RenameItem;
    procedure ClearData;

    property AllFolders: Boolean read FAllFolders;
    property FolderId: Integer read FFolderId write SetFolderId;
    property ItemName: string read GetItemName write SetItemName;
    property ItemId: Integer read GetItemId;
    property ItemType: Integer read GetItemType;
    property ReportExplorer: TRMReportExplorer read FReportExplorer write SetReportExplorer;
    property SelectionCount: Integer read FSelectionCount;
    property SelectionSize: Integer read FSelectionSize;
    property SortMode: Integer read FSortMode write SetSortMode;

    property OnDoubleClick: TNotifyEvent read FOnDoubleClick write FOnDoubleClick;
    property OnFolderChange: TNotifyEvent read FOnFolderChange write FOnFolderChange;
    property OnRenameFolder: TRMRenameFolderEvent read FOnRenameFolder write FOnRenameFolder;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
  end;

  { TRMReportItem }
  TRMReportItem = class(TCollectionItem)
  private
    FReport: TRMReport;
  protected
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Report: TRMReport read FReport write FReport;
  end;

  TRMReportItemClass = class of TRMReportItem;

  { TRMReportItems }
  TRMReportItems = class(TCollection)
  private
    FReportExplorer: TRMReportExplorer;
    function GetItem(Index: Integer): TRMReportItem;
    procedure SetItem(Index: Integer; Value: TRMReportItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(aReportExplorer: TRMReportExplorer; aReportItemClass: TRMReportItemClass);
    function Add: TRMReportItem;
    property Items[Index: Integer]: TRMReportItem read GetItem write SetItem; default;
  end;

  { TRMReportExplorer }
  TRMReportExplorer = class(TComponent)
  private
    FForm: TForm;
    FCurrentFolderId: Integer;
    FCurrentItemName: string;
    FCurrentItemType: Integer;
    FRecyclingItems: Boolean;
    FYesToAll: Boolean;
    FFolderFieldNames: TRMFolderFieldNames;
    FFolderDataSet: TDataSet;
    FItemFieldNames: TRMItemFieldNames;
    FItemDataSet: TDataSet;
    FRootKey: string;
    FInsertRecordFlag: Boolean;
    FRefreshFlag: Boolean;
    FReports: TRMReportItems;
    FCurrentReport: TRMReport;

    procedure SetReports(Value: TRMReportItems);
    procedure SetFolderFieldNames(aFolderFieldNames: TRMFolderFieldNames);
    procedure SetItemFieldNames(aItemFieldNames: TRMItemFieldNames);
    procedure DeleteItemsInFolder(aFolderId: Integer);
    function LocateItemRecord(const aId: Integer): Boolean;
    function IsReport(const aId: Integer): Boolean;
    function MoveFolderToFolder(aFolderId, aNewParentId: Integer): Boolean;
    function MoveItemToFolder(aItemId, aNewFolderId: Integer): Boolean;
    function GetNewReportName(aFolderId: Integer): string;
    function ValidFolderName(aParentId: Integer; aFolderName: string): Boolean;
    function GetCurrentReportIndex(aReportType: Byte): Integer;

    procedure OnSaveReportEvent(Report: TRMReport; var ReportName: string; SaveAs: Boolean; var Saved: Boolean);
  protected
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(aComponent: TComponent; Operation: TOperation); override;
    procedure Execute;
    procedure New(aFolderId: Integer);
    procedure Open(const aItemId, aFolderId, aItemType: Integer; aReportName: string);
    procedure Print(const aItemId, aFolderId, aItemType: Integer; const aReportName: string);
    procedure PrintPreview(const aItemId, aFolderId, aItemType: Integer; const aReportName: string);

    function GetParentId(aFolderId: Integer): Integer;
    procedure GetFolders(aList: TStrings);
    procedure GetItems(aFolderId: Integer; aList: TStrings);
    function GetNewFolderName(aParentId: Integer): string;
    function ChangeFolder(aItemId, aNewFolderId: Integer): Boolean;
    function ChangeParentFolder(aFolderId, aNewParentId: Integer): Boolean;
    procedure AddFolder(aParentId: Integer; aFolderName: string; var aFolderId: Integer);
    procedure RenameFolder(aFolderId: Integer; const aNewName: string);
    procedure Rename(aItemId: Integer; aNewName: string);
    procedure Delete(aItemId: Integer);
    function DeleteFolder(aFolderId: Integer): Boolean;
    procedure GetChildFolders(aFolderId: Integer; aList: TStrings);
    function GetFolderName(aFolderId: Integer): string;

    property CurrentItemName: string read FCurrentItemName write FCurrentItemName;
    property CurrentFolderId: Integer read FCurrentFolderId write FCurrentFolderId;
  published
    property FolderFieldNames: TRMFolderFieldNames read FFolderFieldNames write SetFolderFieldNames;
    property FolderDataSet: TDataSet read FFolderDataSet write FFolderDataSet;
    property ItemFieldNames: TRMItemFieldNames read FItemFieldNames write SetItemFieldNames;
    property ItemDataSet: TDataSet read FItemDataSet write FItemDataSet;
    property RootKey: string read FRootKey write FRootKey;
    property Reports: TRMReportItems read FReports write SetReports;
  end;

implementation

uses
  RM_Designer, RMD_ExpFrm, RM_Utils, RM_Const, RMD_DlgSelectReportType;

function RMGetTypeDesc(aItemType: Integer): string;
begin
  case aItemType of
    rmitReport: Result := RMLoadStr(rmRes + 3157); //'Report';
    rmitFolder: Result := RMLoadStr(rmRes + 3158); //'Folder';
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMFolderFieldNames}

constructor TRMFolderFieldNames.Create;
begin
  inherited Create;
  FFolderId := 'FolderId';
  FName := 'Name';
  FParentId := 'ParentId';
end;

destructor TRMFolderFieldNames.Destroy;
begin
  inherited Destroy;
end;

procedure TRMFolderFieldNames.Assign(Source: TPersistent);
var
  lSource: TRMFolderFieldNames;
begin
  if not (Source is TRMFolderFieldNames) then
    Exit;
  lSource := TRMFolderFieldNames(Source);
  FFolderId := lSource.FolderId;
  FName := lSource.Name;
  FParentId := lSource.ParentId;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMItemFieldNames}

constructor TRMItemFieldNames.Create;
begin
  inherited Create;
  FDeleted := 'Deleted';
  FFolderId := 'FolderId';
  FItemId := 'ItemId';
  FItemType := 'ItemType';
  FModified := 'Modified';
  FName := 'Name';
  FSize := 'Size';
  FTemplate := 'Template';
end;

destructor TRMItemFieldNames.Destroy;
begin
  inherited Destroy;
end;

procedure TRMItemFieldNames.Assign(Source: TPersistent);
var
  lSource: TRMItemFieldNames;
begin
  if not (Source is TRMItemFieldNames) then
    Exit;
  lSource := TRMItemFieldNames(Source);
  FDeleted := lSource.Deleted;
  FFolderId := lSource.FolderId;
  FItemId := lSource.ItemId;
  FItemType := lSource.ItemType;
  FModified := lSource.Modified;
  FName := lSource.Name;
  FSize := lSource.Size;
  FTemplate := lSource.Template;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMItemListView}

constructor TRMItemListView.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FAllFolders := False;
  FFolderId := 0;
//  FItemTypeFilter := rmitAllFolders;
  FOnDoubleClick := nil;
  FOnFolderChange := nil;
  FOnRenameFolder := nil;
  FOnSelectionChange := nil;
  FReportExplorer := nil;
  FSelectionCount := 0;
  FSelectionSize := 0;
  FSortMode := 1;

  OnChange := ChangeEvent;
  OnColumnClick := ColumnClickEvent;
  OnCompare := CompareEvent;
  OnDblClick := DblClickEvent;
  OnDragDrop := DragDropEvent;
  OnDragOver := DragOverEvent;
  OnEdited := EditedEvent;
  OnEditing := EditingEvent;

  DragCursor := crDefault;
  DragMode := dmAutomatic;
  SortType := stText;
end;

destructor TRMItemListView.Destroy;
begin
  ClearData;
  inherited Destroy;
end;

procedure TRMItemListView.ClearData;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
  begin
    if Items[i].Data <> nil then
    begin
      Dispose(Items[i].Data);
      Items[i].Data := nil;
    end;
  end;
  Items.Clear;
end;

procedure TRMItemListView.SetParent(aParent: TWinControl);
var
  liColumn: TListColumn;
begin
  inherited SetParent(aParent);
  if (Columns.Count > 0) or (csDestroying in ComponentState) then
    Exit;

  liColumn := Columns.Add;
  liColumn.Width := 250;
  liColumn := Columns.Add;
  liColumn.Width := 120;
  liColumn.Alignment := taRightJustify;
  liColumn := Columns.Add;
  liColumn.Width := 100;
  liColumn := Columns.Add;
  liColumn.Width := 140;
end;

procedure TRMItemListView.SetReportExplorer(aExplorer: TRMReportExplorer);
begin
  FReportExplorer := aExplorer;
end;

procedure TRMItemListView.SetItemName(aName: string);
var
  liFound: Boolean;
  i: Integer;
  liListItem: TListItem;
begin
  liListItem := nil;
  liFound := False;
  for i := 0 to Items.Count - 1 do
  begin
    liListItem := Items[i];
    if AnsiCompareText(liListItem.Caption, aName) = 0 then
    begin
      liFound := True;
      Break;
    end;
  end;

  if liFound then
  begin
    Selected := liListItem;
    DoOnSelectionChange;
  end;
end;

procedure TRMItemListView.SetFolderId(aFolderId: Integer);
begin
  FFolderId := aFolderId;
  GetItemsForFolder;
end;

procedure TRMItemListView.SetSortMode(aSortMode: Integer);
begin
  FSortMode := aSortMode;
  SetSortModeDescription;
end;

function TRMItemListView.GetItemId: Integer;
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  if (liListItem <> nil) and (liListItem.Data <> nil) then
    Result := PRMListItemData(liListItem.Data).ItemId
  else
    Result := -1;
end;

function TRMItemListView.GetItemType: Integer;
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  if (liListItem <> nil) and (liListItem.Data <> nil) then
    Result := PRMListItemData(liListItem.Data).ItemType
  else
    Result := -1;
end;

function TRMItemListView.GetItemName: string;
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  if liListItem <> nil then
    Result := liListItem.Caption
  else
    Result := '';
end;

procedure TRMItemListView.DoOnFolderChange;
begin
  if Assigned(FOnFolderChange) then
    FOnFolderChange(Self);
end;

procedure TRMItemListView.DoOnRenameFolder(aFolderId: Integer; const aNewName: string);
begin
  if Assigned(FOnRenameFolder) then
    FOnRenameFolder(Self, aFolderId, aNewName);
end;

procedure TRMItemListView.DoOnSelectionChange;
begin
  if Assigned(FOnSelectionChange) then
    FOnSelectionChange(Self);
end;

procedure TRMItemListView.ChangeEvent(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  liListItem: TListItem;
  liSize: Integer;
  str: string;
  liStringList: TStrings;
  i: Integer;
begin
  liStringList := TStringList.Create;
  try
    GetSelectedItems(liStringList);
    liSize := 0;
    for i := 0 to liStringList.Count - 1 do
    begin
      liListItem := TListItem(liStringList.Objects[i]);
      if PRMListItemData(liListItem.Data).ItemType <> rmitFolder then
      begin
        FAllFolders := False;
        str := liListItem.SubItems[0];
        str := Copy(str, 1, Length(str) - Length('KB')); {'KB'}
        liSize := liSize + Round(StrToFloat(str) * 1024);
      end;
    end;

    FAllFolders := True;
    FSelectionCount := liStringList.Count;
    FSelectionSize := liSize;
    DoOnSelectionChange;
  finally
    liStringList.Free;
  end;
end;

procedure TRMItemListView.DblClickEvent(Sender: TObject);
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  if liListItem = nil then Exit;

  if PRMListItemData(liListItem.Data).ItemType = rmitFolder then
  begin
    FFolderId := PRMListItemData(liListItem.Data).ItemId;
    GetItemsForFolder;
    DoOnFolderChange;
  end
  else
  begin
    if Assigned(FOnDoubleClick) then
      FOnDoubleClick(Self);
  end;
end;

procedure TRMItemListView.ColumnClickEvent(Sender: TObject; Column: TListColumn);
begin
  if FSortMode = Column.Index + 1 then
    FSortMode := FSortMode * -1
  else
    FSortMode := Column.Index + 1;
  AlphaSort;
  SetSortModeDescription;
end;

procedure TRMItemListView.CompareEvent(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  liSize1: Integer;
  liSize2: Integer;
  liDateTime1: TDateTime;
  liDateTime2: TDateTime;
  liDiff: Double;
begin
  if (PRMListItemData(Item1.Data).ItemType = rmitFolder) and (PRMListItemData(Item2.Data).ItemType = rmitFolder) then
  begin
    case FSortMode of
      1: Compare := AnsiCompareText(Item1.Caption, Item2.Caption);
      -1: Compare := AnsiCompareText(Item2.Caption, Item1.Caption);
    end;
  end
  else if PRMListItemData(Item1.Data).ItemType = rmitFolder then
    Compare := -1
  else if PRMListItemData(Item2.Data).ItemType = rmitFolder then
    Compare := 1
  else
  begin
    case FSortMode of
      1: Compare := AnsiCompareText(Item1.Caption, Item2.Caption);
      -1: Compare := AnsiCompareText(Item2.Caption, Item1.Caption);
      2, -2:
        begin
          liSize1 := Round(StrToFloat(Copy(Item1.SubItems[0], 1, Length(Item1.SubItems[0]) - 2)));
          liSize2 := Round(StrToFloat(Copy(Item2.SubItems[0], 1, Length(Item2.SubItems[0]) - 2)));
          if FSortMode = 2 then
            Compare := liSize1 - liSize2
          else
            Compare := liSize2 - liSize1;
        end;
      3: Compare := AnsiCompareText(Item1.SubItems[1], Item2.SubItems[1]);
      -3: Compare := AnsiCompareText(Item2.SubItems[1], Item1.SubItems[1]);
      4, -4:
        begin
          liDateTime1 := StrToDateTime(Item1.SubItems[2]);
          liDateTime2 := StrToDateTime(Item2.SubItems[2]);
          if FSortMode = 4 then
            liDiff := liDateTime1 - liDateTime2
          else
            liDiff := liDateTime2 - liDateTime1;
          if liDiff > 0 then
            Compare := 1
          else if liDiff < 0 then
            Compare := -1
          else
            Compare := 0;
        end;
    end;
  end;

  if Compare = 0 then
    Compare := AnsiCompareText(Item1.Caption, Item2.Caption);
end;

procedure TRMItemListView.DragDropEvent(Sender, Source: TObject; X, Y: Integer);
var
  liListItem: TListItem;
begin
  liListItem := GetItemAt(X, Y);
  if liListItem = nil then Exit;
  if PRMListItemData(liListItem.Data).ItemType <> rmitFolder then Exit;

  MoveSelectionToFolder(PRMListItemData(liListItem.Data).ItemId);
end;

procedure TRMItemListView.DragOverEvent(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  liListItem: TListItem;
begin
  liListItem := GetItemAt(X, Y);
  if liListItem <> nil then
    Accept := PRMListItemData(liListItem.Data).ItemType = rmitFolder
  else
    Accept := False;
end;

procedure TRMItemListView.EditingEvent(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := FFolderId <> -2;
end;

procedure TRMItemListView.EditedEvent(Sender: TObject; Item: TListItem; var S: string);
begin
  if PRMListItemData(Item.Data).ItemType = rmitFolder then
  begin
    DoOnRenameFolder(PRMListItemData(Item.Data).ItemId, S);
    FReportExplorer.RenameFolder(PRMListItemData(Item.Data).ItemId, S);
  end
  else
  begin
    FReportExplorer.Rename(PRMListItemData(Item.Data).ItemId, S);
  end;
end;

procedure TRMItemListView.MoveSelectionToFolder(aFolderId: Integer);
var
  liListItem: TListItem;
  i: Integer;
  liStringList: TStrings;
  liChange: Boolean;
  liFolderChange: Boolean;
begin
  liStringList := TStringList.Create;
  try
    GetSelectedItems(liStringList);
    liChange := False;
    liFolderChange := False;
    for i := 0 to liStringList.Count - 1 do
    begin
      liListItem := TListItem(liStringList.Objects[i]);
      if PRMListItemData(liListItem.Data).ItemType = rmitFolder then
      begin
        if FReportExplorer.ChangeParentFolder(PRMListItemData(liListItem.Data).ItemId, aFolderId) then
          liFolderChange := True;
      end
      else
      begin
        if FReportExplorer.ChangeFolder(PRMListItemData(liListItem.Data).ItemId, aFolderId) then
          liChange := True;
      end;
    end;

    if liFolderChange then
      DoOnFolderChange
    else if liChange then
      GetItemsForFolder;
  finally
    liStringList.Free;
  end;
end;

procedure TRMItemListView.EmptyRecycleBin;
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    FReportExplorer.GetItems(-2, liStringList);
    while liStringList.Count > 0 do
    begin
      TRMItemInfo(liStringList.Objects[0]).Free;
      liStringList.Delete(0);
    end;

    FReportExplorer.DeleteItemsInFolder(-2);
    DoOnFolderChange;
  finally
    liStringList.Free;
  end;
end;

procedure TRMItemListView.DeleteSelection;
var
  liListItem: TListItem;
  liStringList: TStrings;
  i: Integer;
  lbFolderChange: Boolean;
begin
  if Application.MessageBox(PChar(RMLoadStr(rmRes + 3167)), PChar(RMLoadStr(rmRes + 3168)),
    MB_ICONQUESTION + MB_YESNO) <> IDYES then
    Exit;

  lbFolderChange := False;
  liStringList := TStringList.Create;
  Items.BeginUpdate;
  try
    GetSelectedItems(liStringList);
    for i := 0 to liStringList.Count - 1 do
    begin
      liListItem := TListItem(liStringList.Objects[i]);
      if PRMListItemData(liListItem.Data).ItemType = rmitFolder then
        lbFolderChange := True;

      if FFolderId = rmitRecycleBin then
        FReportExplorer.Delete(PRMListItemData(liListItem.Data).ItemId)
      else
      begin
        if PRMListItemData(liListItem.Data).ItemType = rmitFolder then
          FReportExplorer.ChangeParentFolder(PRMListItemData(liListItem.Data).ItemId, -2)
        else
          FReportExplorer.ChangeFolder(PRMListItemData(liListItem.Data).ItemId, -2);
      end;

      if liListItem.Data <> nil then
      begin
        Dispose(liListItem.Data);
        liListItem.Data := nil;
      end;
      liListItem.Free;
    end;

    if lbFolderChange then
      DoOnFolderChange;
  finally
    Items.EndUpdate;
    liStringList.Free;
  end;
end;

procedure TRMItemListView.RenameItem;
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  if (liListItem <> nil) and (liListItem.Data <> nil) then
    liListItem.EditCaption;
end;

procedure TRMItemListView.SetSortModeDescription;
var
  str: string;
  liIndex: Integer;
begin
  Columns[0].Caption := RMLoadStr(rmRes + 3163); {Name}
  Columns[1].Caption := RMLoadStr(rmRes + 3164); {Size}
  Columns[2].Caption := RMLoadStr(rmRes + 3165); {Type}
  Columns[3].Caption := RMLoadStr(rmRes + 3166); {Modified}
  case FSortMode of
    1: str := ' ' + ''; {(a > z)}
    -1: str := ' ' + ''; {(z > a)}
    2: str := ' ' + ''; {(small > large)}
    -2: str := ' ' + ''; {(large > small)}
    3: str := ' ' + ''; {(a > z)}
    -3: str := ' ' + ''; {(z > a)}
    4: str := ' ' + ''; {(older > newer)}
    -4: str := ' ' + ''; {(newer > older)}
  end;

  if FSortMode < 0 then
    liIndex := (FSortMode * -1) - 1
  else
    liIndex := FSortMode - 1;

  Columns[liIndex].Caption := Columns[liIndex].Caption + str;
end;

procedure TRMItemListView.GetSelectedItems(aList: TStrings);
var
  liListItem: TListItem;
begin
  liListItem := Selected;
  while liListItem <> nil do
  begin
    aList.AddObject(liListItem.Caption, liListItem);
    liListItem := GetNextItem(liListItem, sdAll, [isSelected]);
  end;
end;

procedure TRMItemListView.GetItemsForFolder;
var
  lFolders: TStringList;
  lFolderInfo: TRMFolderInfo;
  lItemNames: TStringList;
  lItem: TListItem;
  i: Integer;
  lItemInfo: TRMItemInfo;
  liTotalSize: Integer;
  liData: PRMListItemData;
begin
  lFolders := TStringList.Create;
  lItemNames := TStringList.Create;
  Items.BeginUpdate;
  try
    ClearData;
    Items.Clear;
    FReportExplorer.GetChildFolders(FFolderId, lFolders);
    for i := 0 to lFolders.Count - 1 do
    begin
      lFolderInfo := TRMFolderInfo(lFolders.Objects[i]);
      lItem := Items.Add;
      lItem.Caption := lFolderInfo.Name;

      New(liData);
      liData.ItemId := lFolderInfo.FolderId;
      liData.ItemType := rmitFolder;
      lItem.Data := liData;

      lItem.ImageIndex := 3;
      lItem.SubItems.Add('');
      lItem.SubItems.Add(RMGetTypeDesc(rmitFolder));
      lFolderInfo.Free;
    end;

    FReportExplorer.GetItems(FFolderId, lItemNames);

    liTotalSize := 0;
    for i := 0 to lItemNames.Count - 1 do
    begin
      lItemInfo := TRMItemInfo(lItemNames.Objects[i]);
      lItem := Items.Add;
      lItem.Caption := lItemInfo.Name;
      lItem.ImageIndex := 0; //lItemInfo.ItemType - 1;

      New(liData);
      liData.ItemId := lItemInfo.ItemId;
      liData.ItemType := lItemInfo.ItemType;
      lItem.Data := liData;

      lItem.SubItems.Add(Format('%8.2f', [lItemInfo.Size / 1024]) + 'KB');
      lItem.SubItems.Add(RMGetTypeDesc(rmitReport));
      lItem.SubItems.Add(FormatDateTime(ShortDateFormat + ' ' + ShortTimeFormat, lItemInfo.Modified));
      liTotalSize := liTotalSize + lItemInfo.Size;
      lItemInfo.Free;
    end;

    FSelectionCount := lItemNames.Count;
    FSelectionSize := liTotalSize;
  finally
    Items.EndUpdate;
    lFolders.Free;
    lItemNames.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMReportItem}

constructor TRMReportItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TRMReportItem.Assign(Source: TPersistent);
begin
  if Source is TRMReportItem then
  begin
    FReport := TRMReportItem(Source).Report;
  end
  else
    inherited Assign(Source);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMReportItems}

constructor TRMReportItems.Create(aReportExplorer: TRMReportExplorer; aReportItemClass: TRMReportItemClass);
begin
  inherited Create(aReportItemClass);
  FReportExplorer := aReportExplorer;
end;

function TRMReportItems.GetOwner: TPersistent;
begin
  Result := FReportExplorer;
end;

function TRMReportItems.Add: TRMReportItem;
begin
  Result := TRMReportItem(inherited Add);
end;

function TRMReportItems.GetItem(Index: Integer): TRMReportItem;
begin
  Result := TRMReportItem(inherited GetItem(Index));
end;

procedure TRMReportItems.SetItem(Index: Integer; Value: TRMReportItem);
begin
  inherited SetItem(Index, Value);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMReportExplorer}

type
  THackReport = class(TRMReport)
  end;

constructor TRMReportExplorer.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FRootKey := 'Software\WHF SoftWare\Report Machine\Report Explorer\';

  FFolderFieldNames := TRMFolderFieldNames.Create;
  FFolderDataSet := nil;

  FItemFieldNames := TRMItemFieldNames.Create;
  FItemDataSet := nil;

  FForm := nil;
  FReports := TRMReportItems.Create(Self, TRMReportItem);
end;

destructor TRMReportExplorer.Destroy;
begin
  FReports.Free; FReports := nil;
  FFolderFieldNames.Free;
  FItemFieldNames.Free;
  inherited Destroy;
end;

procedure TRMReportExplorer.Notification(aComponent: TComponent; Operation: TOperation);
var
  i: Integer;
begin
  inherited Notification(aComponent, Operation);
  if Operation = opRemove then
  begin
    if aComponent = FFolderDataSet then
      FFolderDataSet := nil
    else if aComponent = FItemDataSet then
      FItemDataSet := nil
    else if aComponent is TRMReport then
    begin
      for i := 0 to FReports.Count - 1 do
      begin
        if FReports[i].Report = aComponent then
          FReports[i].Report := nil;
      end;
    end;
  end;
end;

function TRMReportExplorer.IsReport(const aId: Integer): Boolean;
begin
  Result := LocateItemRecord(aId);
end;

function TRMReportExplorer.LocateItemRecord(const aId: Integer): Boolean;
begin
  Result := FItemDataSet.Locate(FItemFieldNames.ItemId, aId, [loCaseInsensitive]);
end;

procedure TRMReportExplorer.SetReports(Value: TRMReportItems);
begin
  FReports.Assign(Value);
end;

procedure TRMReportExplorer.SetFolderFieldNames(aFolderFieldNames: TRMFolderFieldNames);
begin
  FFolderFieldNames.Assign(aFolderFieldNames);
end;

procedure TRMReportExplorer.SetItemFieldNames(aItemFieldNames: TRMItemFieldNames);
begin
  FItemFieldNames.Assign(aItemFieldNames);
end;

procedure TRMReportExplorer.DeleteItemsInFolder(aFolderId: Integer);
begin
  while FItemDataSet.Locate(FItemFieldNames.FolderId, aFolderId, [loCaseInsensitive]) do
    FItemDataSet.Delete;
end;

procedure TRMReportExplorer.Execute;
begin
  if (not Assigned(FFolderDataSet)) or (not Assigned(FItemDataSet)) then
    Exit;

  if not FFolderDataSet.Active then
    FFolderDataSet.Active := TRUE;
  if not FItemDataSet.Active then
    FItemDataSet.Active := TRUE;

  FForm := TRMDFormReportExplorer.Create(nil);
  try
    TRMDFormReportExplorer(FForm).ReportExplorer := Self;
    FForm.ShowModal;
  finally
    FForm.Free; FForm := nil;
  end;
end;

function TRMReportExplorer.MoveFolderToFolder(aFolderId, aNewParentId: Integer): Boolean;
var
  str: string;
  liCollidingId: Integer;
  liAllReportsMoved: Boolean;
  liAllFoldersMoved: Boolean;
  liResult: Word;

  function _MoveFoldersToFolder(aOldFolderId, aNewFolderId: Integer): Boolean;
  var
    liList: TStringList;
    i: Integer;
    liFolderInfo: TRMFolderInfo;
  begin
    Result := True;
    liList := TStringList.Create;
    try
      GetChildFolders(aOldFolderId, liList);
      for i := 0 to liList.Count - 1 do
      begin
        liFolderInfo := TRMFolderInfo(liList.Objects[i]);
        if not MoveFolderToFolder(liFolderInfo.FolderId, aNewFolderId) then
          Result := False;
        liFolderInfo.Free;
      end;
    finally
      liList.Free;
    end;
  end;

  function _MoveItemsToFolder(aOldFolderId, aNewFolderId: Integer): Boolean;
  var
    liList: TStringList;
    i: Integer;
    liItemInfo: TRMItemInfo;
  begin
    Result := True;
    liList := TStringList.Create;
    try
      GetItems(aOldFolderId, liList);
      for i := 0 to liList.Count - 1 do
      begin
        liItemInfo := TRMItemInfo(liList.Objects[i]);
        if not MoveItemToFolder(liItemInfo.ItemId, aNewFolderId) then
          Result := False;
        liItemInfo.Free;
      end;
    finally
      liList.Free;
    end;
  end;

begin
  Result := False;
  str := GetFolderName(aFolderId);
  if FRecyclingItems then
  begin
    liCollidingId := -2;
    _MoveFoldersToFolder(aFolderId, liCollidingId);
    _MoveItemsToFolder(aFolderId, liCollidingId);
    DeleteFolder(aFolderId);
    Result := True;
  end
  else if not ValidFolderName(aNewParentId, str) then
  begin
    liCollidingId := FFolderDataSet[FFolderFieldNames.FolderId];
    if not FYesToAll then
    begin
      liResult := mrYesToAll;
      case liResult of
        mrYesToAll: FYesToAll := True;
        mrNo: Exit;
        mrCancel: Exit;
      end;
    end;

    liAllFoldersMoved := _MoveFoldersToFolder(aFolderId, liCollidingId);
    liAllReportsMoved := _MoveItemsToFolder(aFolderId, liCollidingId);
    if liAllReportsMoved and liAllFoldersMoved then
      DeleteFolder(aFolderId);
    Result := True;
  end
  else
  begin
    if FFolderDataSet.Locate(FFolderFieldNames.FolderId, aFolderId, [loCaseInsensitive]) then
    begin
      FFolderDataSet.Edit;
      FFolderDataSet[FFolderFieldNames.ParentId] := aNewParentId;
      FFolderDataSet.Post;
      Result := True;
    end;
  end;
end;

type
  THackDeisgner = class(TRMReportDesigner)
  end;

procedure TRMReportExplorer.New(aFolderId: Integer);
var
  i: Integer;
  tmp: TRMDSelectReportTypeForm;
begin
  if FReports.Count = 0 then Exit;

  for i := 0 to FReports.Count -1 do
  begin
    if FReports[i].Report <> nil then
      FReports[i].Report.Clear;
  end;

  FCurrentReport := nil;
  if FReports.Count = 1 then
  begin
    if (FReports[0].Report <> nil) and (RMDesignerComp <> nil) then
    begin
      FCurrentReport := FReports[0].Report;
      RMDesignerComp.OnSaveReport := OnSaveReportEvent;
    end;
  end
  else
  begin
    tmp := TRMDSelectReportTypeForm.Create(nil);
    try
      tmp.lstReportType.Items.Clear;
      for i := 0 to FReports.Count - 1 do
      begin
        if FReports[i].Report <> nil then
          tmp.lstReportType.Items.Add(FReports[i].Report.ReportCommon)
        else
          tmp.lstReportType.Items.Add('');
      end;

      if tmp.ShowModal = mrOK then
      begin
        i := tmp.lstReportType.ItemIndex;
        if (FReports[i].Report <> nil) and (RMDesignerComp <> nil) then
        begin
          FCurrentReport := FReports[i].Report;
          RMDesignerComp.OnSaveReport := OnSaveReportEvent;
        end;
      end;
    finally
      tmp.Free;
    end;
  end;

  if FCurrentReport <> nil then
  begin
    FCurrentFolderId := aFolderId;
    FCurrentItemName := GetNewReportName(aFolderId);
    FCurrentItemType := FCurrentReport.ReportClassType; // rmitReport;
    FInsertRecordFlag := True;
    FRefreshFlag := False;

    FCurrentReport.Clear;
    FCurrentReport.DesignReport;
    if FRefreshFlag then
      TRMDFormReportExplorer(FForm).RefreshCurrentListView;
  end;
end;

function TRMReportExplorer.GetCurrentReportIndex(aReportType: Byte): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FReports.Count - 1 do
  begin
    if (FReports[i].Report <> nil) and (FReports[i].Report.ReportClassType = aReportType) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TRMReportExplorer.Open(const aItemId, aFolderId, aItemType: Integer; aReportName: string);
var
  liIndex: Integer;
begin
  for liIndex := 0 to FReports.Count -1 do
  begin
    if FReports[liIndex].Report <> nil then
      FReports[liIndex].Report.Clear;
  end;

  if IsReport(aItemId) then
  begin
    liIndex := GetCurrentReportIndex(aItemType);
    if (liIndex >= 0) and (RMDesignerComp <> nil) then
    begin
      FCurrentReport := FReports[liIndex].Report;
      FCurrentItemName := aReportName;
      FCurrentFolderId := aFolderId;

      FCurrentReport.LoadFromBlobField(TBlobField(FItemDataSet.FindField(FItemFieldNames.Template)));
      FCurrentReport.FileName := aReportName;
      FInsertRecordFlag := False;
      FRefreshFlag := False;

      RMDesignerComp.OnSaveReport := OnSaveReportEvent;
      FCurrentReport.DesignReport;
      if FRefreshFlag then
        TRMDFormReportExplorer(FForm).RefreshCurrentListItem;
    end;
  end;
end;

procedure TRMReportExplorer.OnSaveReportEvent(Report: TRMReport; var ReportName: string; SaveAs: Boolean; var Saved: Boolean);
begin
  if SaveAs then
  begin
    Saved := False;
    Exit;
  end;

  if FInsertRecordFlag then
  begin
    FItemDataSet.Append;
    FItemDataSet[FItemFieldNames.Name] := FCurrentItemName;
    FItemDataSet[FItemFieldNames.ItemType] := FCurrentItemType;
    FItemDataSet[FItemFieldNames.FolderId] := FCurrentFolderId;
    FInsertRecordFlag := False;
  end
  else
  begin
    FItemDataSet.Edit;
  end;

  FCurrentReport.SaveToBlobField(TBlobField(FItemDataSet.FindField(FItemFieldNames.Template)));
  FItemDataSet[FItemFieldNames.Size] := TBlobField(FItemDataSet.FindField(FItemFieldNames.Template)).BlobSize;
  FItemDataSet[FItemFieldNames.Modified] := Now;
  FItemDataSet.Post;
  FRefreshFlag := TRUE;
end;

procedure TRMReportExplorer.Print(const aItemId, aFolderId, aItemType: Integer;
  const aReportName: string);
var
  liIndex: Integer;
begin
  if IsReport(aItemid) then
  begin
    liIndex := GetCurrentReportIndex(aItemType);
    if liIndex >= 0 then
    begin
      FCurrentReport := FReports[liIndex].Report;
      FCurrentFolderId := aFolderId;
      FCurrentReport.LoadFromBlobField(TBlobField(FItemDataSet.FindField(FItemFieldNames.Template)));
      FCurrentReport.PrintReport;
    end;
  end;
end;

procedure TRMReportExplorer.PrintPreview(const aItemId, aFolderId, aItemType: Integer;
  const aReportName: string);
var
  liIndex: Integer;
begin
  if IsReport(aItemid) then
  begin
    liIndex := GetCurrentReportIndex(aItemType);
    if liIndex >= 0 then
    begin
      FCurrentReport := FReports[liIndex].Report;
      FCurrentFolderId := aFolderId;
      FCurrentReport.LoadFromBlobField(TBlobField(FItemDataSet.FindField(FItemFieldNames.Template)));
      FCurrentReport.ShowReport;
    end;
  end;
end;

procedure TRMReportExplorer.Rename(aItemId: Integer; aNewName: string);
begin
  if LocateItemRecord(aItemId) then
  begin
    FItemDataSet.Edit;
    FItemDataSet[FItemFieldNames.Name] := aNewName;
    FItemDataset.Post;
  end;
end;

function TRMReportExplorer.GetParentId(aFolderId: Integer): Integer;
begin
  Result := -1;
  if FFolderDataSet.Locate(FFolderFieldNames.FolderId, aFolderId, [loCaseInsensitive]) then
    Result := FFolderDataSet[FFolderFieldNames.ParentId];
end;

procedure TRMReportExplorer.GetFolders(aList: TStrings);
var
  lFolderInfo: TRMFolderInfo;
begin
  aList.Clear;
  FFolderDataSet.First;
  while not FFolderDataSet.EOF do
  begin
    lFolderInfo := TRMFolderInfo.Create;
    lFolderInfo.Name := FFolderDataSet[FFolderFieldNames.Name];
    lFolderInfo.FolderId := FFolderDataSet[FFolderFieldNames.FolderId];
    lFolderInfo.ParentId := FFolderDataSet[FFolderFieldNames.ParentId];
    aList.AddObject(lFolderInfo.Name, lFolderInfo);

    FFolderDataSet.Next;
  end;
end;

procedure TRMReportExplorer.GetItems(aFolderId: Integer; aList: TStrings);
var
  lItemInfo: TRMItemInfo;
begin
  aList.Clear;
  if not Assigned(FItemDataSet) then Exit;

  if not FItemDataSet.Active then
    FItemDataSet.Active := TRUE;

  FItemDataSet.First;
  while not FItemDataSet.EOF do
  begin
    if (FItemDataSet[FItemFieldNames.FolderId] = aFolderId) then
//      ((aItemType = 0) or (FItemDataSet[FItemFieldNames.ItemType] >  aItemType)) then
    begin
      lItemInfo := TRMItemInfo.Create;
      if FItemDataSet[FItemFieldNames.Deleted] <> Null then
        lItemInfo.Deleted := FItemDataSet[FItemFieldNames.Deleted];

      if FItemDataSet[FItemFieldNames.Modified] <> Null then
        lItemInfo.Modified := FItemDataSet[FItemFieldNames.Modified];

      lItemInfo.FolderId := FItemDataSet[FItemFieldNames.FolderId];
      lItemInfo.ItemId := FItemDataSet[FItemFieldNames.ItemId];
      lItemInfo.ItemType := FItemDataSet[FItemFieldNames.ItemType];
      lItemInfo.Name := FItemDataSet[FItemFieldNames.Name];
      lItemInfo.Size := FItemDataSet[FItemFieldNames.Size];
      aList.AddObject(lItemInfo.Name, lItemInfo);
    end;
    FItemDataSet.Next;
  end;
end;

function TRMReportExplorer.GetNewFolderName(aParentId: Integer): string;
var
  liFolders: TStringList;
  i: Integer;
  liFolderName: string;
  liIncrement: Integer;
begin
  liFolders := TStringList.Create;
  try
    GetChildFolders(aParentId, liFolders);
    liFolderName := 'New Folder';
    i := liFolders.IndexOf(liFolderName);
    liIncrement := 1;
    while i <> -1 do
    begin
      liFolderName := 'New Folder' + ' (' + IntToStr(liIncrement) + ')';
      i := liFolders.IndexOf(liFolderName);
      Inc(liIncrement);
    end;

    for i := 0 to liFolders.Count - 1 do
      TRMFolderInfo(liFolders.Objects[i]).Free;
  finally
    liFolders.Free;
    Result := liFolderName;
  end;
end;

function TRMReportExplorer.ChangeFolder(aItemId, aNewFolderId: Integer): Boolean;
begin
  if aNewFolderId = rmitRecycleBin then
    FRecyclingItems := True;

  Result := MoveItemToFolder(aItemId, aNewFolderId);
  if aNewFolderId = rmitRecycleBin then
    FRecyclingItems := False;
end;

function TRMReportExplorer.ChangeParentFolder(aFolderId, aNewParentId: Integer): Boolean;

  procedure _RejectMoveFolder(const aFolderName: string);
  var
    str: string;
  begin
    str := Format('Error Moving Folder %s', [aFolderName]);
    Application.MessageBox(PChar(str), PChar(RMLoadStr(rmRes + 3168)),
      MB_ICONERROR + MB_OK);
  end;

begin
  Result := False;
  if aFolderId = aNewParentId then
  begin
    _RejectMoveFolder(GetFolderName(aFolderId));
    Exit;
  end;

  if aNewParentId = rmitRecycleBin then
    FRecyclingItems := True;

  FYesToAll := False;
  Result := MoveFolderToFolder(aFolderId, aNewParentId);
  if aNewParentId = rmitRecycleBin then
    FRecyclingItems := False;
end;

procedure TRMReportExplorer.AddFolder(aParentId: Integer; aFolderName: string; var aFolderId: Integer);

  function _LocateFolderRecord(const aFolderName: string; aParentId: Integer): Boolean;
  var
    lsFieldNames: string;
  begin
    lsFieldNames := FFolderFieldNames.Name + ';' + FFolderFieldNames.ParentId;
    Result := FFolderDataSet.Locate(lsFieldNames, VarArrayOf([aFolderName, aParentId]), [loCaseInsensitive]);
  end;

begin
  FFolderDataSet.Insert;
  FFolderDataSet[FolderFieldNames.Name] := aFolderName;
  FFolderDataSet[FFolderFieldNames.ParentId] := aParentId;
  FFolderDataSet.Post;
  if _LocateFolderRecord(aFolderName, aParentId) then
    aFolderId := FFolderDataSet[FFolderFieldNames.FolderId]
  else
    aFolderId := -1;

  if aFolderId = 0 then
  begin
    FFolderDataSet.Delete;
    FFolderDataSet.Insert;
    FFolderDataSet[FFolderFieldNames.Name] := aFolderName;
    FFolderDataSet[FFolderFieldNames.ParentId] := aParentId;
    FFolderDataSet.Post;
    if _LocateFolderRecord(aFolderName, aParentId) then
      aFolderId := FFolderDataSet[FFolderFieldNames.FolderId]
    else
      aFolderId := -1;
  end;
end;

procedure TRMReportExplorer.RenameFolder(aFolderId: Integer; const aNewName: string);
begin
  if FFolderDataSet.Locate(FFolderFieldNames.FolderId, aFolderId, [loCaseInsensitive]) then
  begin
    FFolderDataSet.Edit;
    FFolderDataSet[FFolderFieldNames.Name] := aNewName;
    FFolderDataSet.Post;
  end;
end;

procedure TRMReportExplorer.Delete(aItemId: Integer);
begin
  if LocateItemRecord(aItemId) then
    FItemDataSet.Delete;
end;

function TRMReportExplorer.DeleteFolder(aFolderId: Integer): Boolean;
begin
  Result := False;
  if (aFolderId = 0) or (aFolderId = -2) then Exit;

  while FFolderDataSet.Locate(FFolderFieldNames.ParentId, aFolderId, [loCaseInsensitive]) do
    DeleteFolder(FFolderDataSet[FFolderFieldNames.FolderId]);

  DeleteItemsInFolder(aFolderId);
  if FFolderDataSet.Locate(FFolderFieldNames.FolderId, aFolderId, [loCaseInsensitive]) then
    FFolderDataSet.Delete;
  Result := True;
end;

procedure TRMReportExplorer.GetChildFolders(aFolderId: Integer; aList: TStrings);
var
  lFolderInfo: TRMFolderInfo;
begin
  aList.Clear;
  if not Assigned(FFolderDataSet) then Exit;

  FFolderDataSet.First;
  while not FFolderDataSet.EOF do
  begin
    if FFolderDataSet[FFolderFieldNames.ParentId] = aFolderId then
    begin
      lFolderInfo := TRMFolderInfo.Create;
      lFolderInfo.Name := FFolderDataSet[FFolderFieldNames.Name];
      lFolderInfo.FolderId := FFolderDataSet[FFolderFieldNames.FolderId];
      lFolderInfo.ParentId := FFolderDataSet[FFolderFieldNames.ParentId];
      aList.AddObject(lFolderInfo.Name, lFolderInfo);
    end;
    FFolderDataSet.Next;
  end;
end;

function TRMReportExplorer.GetFolderName(aFolderId: Integer): string;
begin
  Result := '';
  if FFolderDataSet.Locate(FFolderFieldNames.FolderId, aFolderId, [loCaseInsensitive]) then
    Result := FFolderDataSet[FFolderFieldNames.Name];
end;

function TRMReportExplorer.MoveItemToFolder(aItemId, aNewFolderId: Integer): Boolean;
begin
  Result := False;
  if False {(not FRecyclingItems) and LocateItemRecord(aItemId)} then
  begin
    Self.Delete(aItemId);
  end
  else if LocateItemRecord(aItemId) then
  begin
    FItemDataSet.Edit;
    FItemDataSet[FItemFieldNames.FolderId] := aNewFolderId;
    FItemDataSet.Post;
    Result := True;
  end;
end;

function TRMReportExplorer.GetNewReportName(aFolderId: Integer): string;
var
  liReports: TStringList;
  liIndex: Integer;
  liReportName: string;
  liIncrement: Integer;
begin
  liReports := TStringList.Create;
  try
    GetItems(aFolderId, liReports);
    liReportName := 'New Report';
    liIndex := liReports.IndexOf(liReportName);
    liIncrement := 1;
    while liIndex <> -1 do
    begin
      liReportName := 'New Report' + ' (' + IntToStr(liIncrement) + ')';
      liIndex := liReports.IndexOf(liReportName);
      Inc(liIncrement);
    end;

    for liIndex := 0 to liReports.Count - 1 do
      TRMItemInfo(liReports.Objects[liIndex]).Free;
  finally
    liReports.Free;
    Result := liReportName;
  end;
end;

function TRMReportExplorer.ValidFolderName(aParentId: Integer; aFolderName: string): Boolean;
var
  str: string;
begin
  Result := False;
  if Length(aFolderName) = 0 then Exit;

  str := FFolderFieldNames.Name + ';' + FFolderFieldNames.ParentId;
  Result := not (FFolderDataSet.Locate(str, VarArrayOf([aFolderName, aParentId]), [loCaseInsensitive]));
end;

end.

