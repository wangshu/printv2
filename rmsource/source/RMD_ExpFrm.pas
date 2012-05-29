
{*****************************************}
{                                         }
{   Report Machine v2.0 - Data storage    }
{          Report Explorer Form           }
{                                         }
{*****************************************}

unit RMD_ExpFrm;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, Buttons, ComCtrls, RMD_ReportExplorer
{$IFDEF COMPILER4_UP}, ImgList, ToolWin{$ENDIF};

type
  TRMDFormReportExplorer = class(TForm)
    sbrExplorer: TStatusBar;
    pnlFolders: TPanel;
    pnlFolderTitle: TPanel;
    trvFolders: TTreeView;
    pnlReports: TPanel;
    pnlReportTitle: TPanel;
    MainMenu: TMainMenu;
    barFile: TMenuItem;
    padFileOpen: TMenuItem;
    padFileNew: TMenuItem;
    miN1: TMenuItem;
    padFileClose: TMenuItem;
    barView: TMenuItem;
    padViewStatusBar: TMenuItem;
    N6: TMenuItem;
    padViewList: TMenuItem;
    padViewDetails: TMenuItem;
    padViewToolbar: TMenuItem;
    padFileNewFolder: TMenuItem;
    padFileNewReport: TMenuItem;
    N2: TMenuItem;
    padFileDelete: TMenuItem;
    padFileRename: TMenuItem;
    N4: TMenuItem;
    padFilePrint: TMenuItem;
    padFilePrintPreview: TMenuItem;
    ImageListToolBar: TImageList;
    ppmReports: TPopupMenu;
    ppmReportsView: TMenuItem;
    N8: TMenuItem;
    ppmReportsNewFolder: TMenuItem;
    ppmReportsNewReport: TMenuItem;
    ppmReportsViewList: TMenuItem;
    ppmReportsViewDetails: TMenuItem;
    ppmFolders: TPopupMenu;
    ppmFoldersExplore: TMenuItem;
    MenuItem4: TMenuItem;
    ppmFoldersNewFolder: TMenuItem;
    ppmFoldersNewReport: TMenuItem;
    ppmFoldersOpen: TMenuItem;
    N9: TMenuItem;
    ppmFoldersDelete: TMenuItem;
    ppmFoldersRename: TMenuItem;
    N10: TMenuItem;
    ppmReportsDelete: TMenuItem;
    ppmReportsRename: TMenuItem;
    N5: TMenuItem;
    ImageListTreeView: TImageList;
    splViews: TSplitter;
    ppmFoldersEmptyRecycleBin: TMenuItem;
    ImageListListView: TImageList;
    N1: TMenuItem;
    ppmPrint: TMenuItem;
    ppmPrintPreview: TMenuItem;
    ToolBar: TToolBar;
    btnUpOneLevel: TToolButton;
    btnOpenReport: TToolButton;
    ToolButton3: TToolButton;
    btnNewFolder: TToolButton;
    btnNewReport: TToolButton;
    ToolButton6: TToolButton;
    btnPrint: TToolButton;
    btnPrintPreview: TToolButton;
    ToolButton9: TToolButton;
    btnDelete: TToolButton;
    ToolButton11: TToolButton;
    btnViewList: TToolButton;
    btnViewDetails: TToolButton;
    ToolButton14: TToolButton;
    btnClose: TToolButton;
    procedure padFilePrintClick(Sender: TObject);
    procedure padFilePrintPreviewClick(Sender: TObject);
    procedure padFileOpenClick(Sender: TObject);
    procedure padFileNewReportClick(Sender: TObject);
    procedure padFileDeleteClick(Sender: TObject);
    procedure padViewListClick(Sender: TObject);
    procedure padViewDetailsClick(Sender: TObject);
    procedure padViewToolbarClick(Sender: TObject);
    procedure padViewStatusBarClick(Sender: TObject);
    procedure padFileCloseClick(Sender: TObject);
    procedure padFileNewFolderClick(Sender: TObject);
    procedure trvFoldersEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure padFileRenameClick(Sender: TObject);
    procedure trvFoldersDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure trvFoldersDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure trvFoldersEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
    procedure ppmReportsPopup(Sender: TObject);
    procedure ppmFoldersPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ppmFoldersEmptyRecycleBinClick(Sender: TObject);
    procedure trvFoldersChange(Sender: TObject; Node: TTreeNode);
    procedure btnUpOneLevelClick(Sender: TObject);
  private
    FListView: TRMItemListView;
    FReportExplorer: TRMReportExplorer;
    FAllFoldersNode: TTreeNode;
    FRecycleBinNode: TTreeNode;
    function FindDataInTreeView(aTreeView: TTreeView; aData: Integer): TTreeNode;
    function FindNearestNode(aNode: TTreeNode): TTreeNode;
    procedure ListDoubleClickEvent(Sender: TObject);
    procedure ListFolderChangeEvent(Sender: TObject);
    procedure ListRenameFolderEvent(Sender: TObject; aFolderId: Integer; const aNewName: string);
    procedure ListSelectionChangeEvent(Sender: TObject);
    procedure LoadFromIniFile;
    procedure OpenItem;
    procedure SaveToIniFile;
    procedure SelectFolder(aFolderId: Integer);
    procedure SetViewStyle(Value: Boolean);
    procedure SetViewToolbar(Value: Boolean);
    procedure SetViewStatusBar(Value: Boolean);
    procedure UpdateRecycleBin;
    procedure UpdateStatusBar;
    procedure UpdateTreeView;
    procedure Localize;
  protected
    function GetReportExplorer: TRMReportExplorer;
    procedure SetReportExplorer(Value: TRMReportExplorer);
  public
    property ReportExplorer: TRMReportExplorer read GetReportExplorer write SetReportExplorer;
    procedure Refresh;
    procedure RefreshCurrentListView;
    procedure RefreshCurrentListItem;
  end;

implementation

{$R *.DFM}

uses Registry, RM_Const, RM_Utils;

function RMGetScreenRes: TPoint;
var
  DC: HDC;
begin
  DC := GetDC(0);
  Result.X := GetDeviceCaps(DC, HORZRES);
  Result.Y := GetDeviceCaps(DC, VERTRES);
  ReleaseDC(0, DC);
end;

procedure TRMDFormReportExplorer.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(pnlFolderTitle, 'Caption', rmRes + 3135);
  RMSetStrProp(btnUpOneLevel, 'Hint', rmRes + 3136);
  RMSetStrProp(btnOpenReport, 'Hint', rmRes + 3137);
  RMSetStrProp(btnNewFolder, 'Hint', rmRes + 3138);
  RMSetStrProp(btnNewReport, 'Hint', rmRes + 3139);
  RMSetStrProp(btnPrint, 'Hint', rmRes + 3140);
  RMSetStrProp(btnPrintPreview, 'Hint', rmRes + 3141);
  RMSetStrProp(btnDelete, 'Hint', rmRes + 3142);
  RMSetStrProp(btnViewList, 'Hint', rmRes + 3143);
  RMSetStrProp(btnViewDetails, 'Hint', rmRes + 3144);
  RMSetStrProp(btnClose, 'Hint', rmRes + 3145);
  RMSetStrProp(barFile, 'Caption', rmRes + 154);
  RMSetStrProp(padFileOpen, 'Caption', rmRes + 3137);
  RMSetStrProp(padFileNew, 'Caption', rmRes + 3146);
  RMSetStrProp(padFileNewFolder, 'Caption', rmRes + 3147);
  RMSetStrProp(padFileNewReport, 'Caption', rmRes + 3148);
  RMSetStrProp(padFilePrint, 'Caption', rmRes + 3140);
  RMSetStrProp(padFilePrintPreview, 'Caption', rmRes + 3141);
  RMSetStrProp(padFileDelete, 'Caption', rmRes + 3142);
  RMSetStrProp(padFileRename, 'Caption', rmRes + 3149);
  RMSetStrProp(padFileClose, 'Caption', rmRes + 3145);
  RMSetStrProp(barView, 'Caption', rmRes + 3150);
  RMSetStrProp(padViewToolbar, 'Caption', rmRes + 3151);
  RMSetStrProp(padViewStatusBar, 'Caption', rmRes + 3152);
  RMSetStrProp(padViewList, 'Caption', rmRes + 3153);
  RMSetStrProp(padViewDetails, 'Caption', rmRes + 3154);
  RMSetStrProp(ppmReportsNewFolder, 'Caption', rmRes + 3138);
  RMSetStrProp(ppmReportsNewReport, 'Caption', rmRes + 3139);
  RMSetStrProp(ppmReportsDelete, 'Caption', rmRes + 3142);
  RMSetStrProp(ppmReportsRename, 'Caption', rmRes + 3149);
  RMSetStrProp(ppmPrint, 'Caption', rmRes + 3140);
  RMSetStrProp(ppmPrintPreview, 'Caption', rmRes + 3141);
  RMSetStrProp(ppmReportsView, 'Caption', rmRes + 3150);
  RMSetStrProp(ppmReportsViewList, 'Caption', rmRes + 3153);
  RMSetStrProp(ppmReportsViewDetails, 'Caption', rmRes + 3154);
  RMSetStrProp(ppmFoldersExplore, 'Caption', rmRes + 3155);
  RMSetStrProp(ppmFoldersOpen, 'Caption', rmRes + 3137);
  RMSetStrProp(ppmFoldersEmptyRecycleBin, 'Caption', rmRes + 3156);
  RMSetStrProp(ppmFoldersNewFolder, 'Caption', rmRes + 3138);
  RMSetStrProp(ppmFoldersNewReport, 'Caption', rmRes + 3139);
  RMSetStrProp(ppmFoldersDelete, 'Caption', rmRes + 3142);
  RMSetStrProp(ppmFoldersRename, 'Caption', rmRes + 3149);
end;

procedure TRMDFormReportExplorer.Refresh;
begin
  UpdateTreeView;
  SelectFolder(FReportExplorer.CurrentFolderId);
  FListView.ItemName := FReportExplorer.CurrentItemName;
end;

procedure TRMDFormReportExplorer.RefreshCurrentListView;
begin
  SelectFolder(FReportExplorer.CurrentFolderId);
  FListView.ItemName := FReportExplorer.CurrentItemName;
end;

procedure TRMDFormReportExplorer.RefreshCurrentListItem;
begin
  FListView.ItemName := FReportExplorer.CurrentItemName;
end;

function TRMDFormReportExplorer.GetReportExplorer: TRMReportExplorer;
begin
  Result := FReportExplorer;
end;

procedure TRMDFormReportExplorer.SetReportExplorer(Value: TRMReportExplorer);
begin
  FReportExplorer := Value;
  FListView.ReportExplorer := Value;
end;

procedure TRMDFormReportExplorer.LoadFromIniFile; //调入配置
var
  IniFile: TRegIniFile;
  lScreenRes: TPoint;
  liLeft: Integer;
  liTop: Integer;
  liWidth: Integer;
  liHeight: Integer;
  liWindowState: Integer;
begin
  IniFile := TRegIniFile.Create(FReportExplorer.RootKey);
  try
    liLeft := IniFile.ReadInteger('Position', 'Left', -1);
    if liLeft <> -1 then
    begin
      lScreenRes := RMGetScreenRes;
      liWidth := 790;
      liHeight := 600;
      if lScreenRes.X <> 1024 then
      begin
        liWidth := (liWidth * lScreenRes.X) div 1024;
        liHeight := (Height * lScreenRes.Y) div 768;
      end;

      liLeft := (Screen.Width - liWidth) div 2;
      liTop := (Screen.Height - liHeight) div 2;
      liWindowState := IniFile.ReadInteger('Position', 'WindowState', Ord(wsNormal));
      if TWindowState(liWindowState) = wsNormal then
      begin
        liLeft := IniFile.ReadInteger('Position', 'Left', liLeft);
        liTop := IniFile.ReadInteger('Position', 'Top', liTop);
        liWidth := IniFile.ReadInteger('Position', 'Width', liWidth);
        liHeight := IniFile.ReadInteger('Position', 'Height', liHeight);
      end;

      SetBounds(liLeft, liTop, liWidth, liHeight);
      if TWindowState(liWindowState) <> wsMinimized then
        WindowState := TWindowState(liWindowState);
      SetViewStyle(IniFile.ReadBool('State', 'ViewList', True));
      SetViewToolbar(IniFile.ReadBool('State', 'ViewToolbar', True));
      SetViewStatusBar(IniFile.ReadBool('State', 'ViewStatusBar', True));

      FListView.SortMode := IniFile.ReadInteger('State', 'SortMode', 1);
      FListView.Columns[0].Width := IniFile.ReadInteger('State', 'ListViewColumn1Width', 250);
      FListView.Columns[1].Width := IniFile.ReadInteger('State', 'ListViewColumn2Width', 120);
      FListView.Columns[2].Width := IniFile.ReadInteger('State', 'ListViewColumn3Width', 100);
      FListView.Columns[3].Width := IniFile.ReadInteger('State', 'ListViewColumn4Width', 140);
      FListView.FolderId := IniFile.ReadInteger('State', 'Selected Folder', 0);
      FListView.ItemName := IniFile.ReadString('State', 'Selected Item', '');

      FReportExplorer.CurrentFolderId := FListView.FolderId;
      FReportExplorer.CurrentItemName := FListView.ItemName;
    end
    else
      WindowState := wsMaximized;
  finally
    IniFile.Free;
  end;
end;

procedure TRMDFormReportExplorer.SaveToIniFile; //保存配置
var
  IniFile: TRegIniFile;
begin
  IniFile := TRegIniFile.Create(FReportExplorer.RootKey);
  try
    with IniFile do
    begin
      WriteInteger('Position', 'WindowState', Ord(WindowState));
      WriteInteger('Position', 'Left', Left);
      WriteInteger('Position', 'Top', Top);
      WriteInteger('Position', 'Width', Width);
      WriteInteger('Position', 'Height', Height);
      WriteBool('State', 'ViewList', padViewList.Checked);
      WriteBool('State', 'ViewToolbar', padViewToolbar.Checked);
      WriteBool('State', 'ViewStatusBar', padViewStatusBar.Checked);
      WriteInteger('State', 'SortMode', FListView.SortMode);
      WriteInteger('State', 'ListViewColumn1Width', FListView.Columns[0].Width);
      WriteInteger('State', 'ListViewColumn2Width', FListView.Columns[1].Width);
      WriteInteger('State', 'ListViewColumn3Width', FListView.Columns[2].Width);
      WriteInteger('State', 'ListViewColumn4Width', FListView.Columns[3].Width);
      WriteInteger('State', 'Selected Folder', FListView.FolderId);
      WriteString('State', 'Selected Item', FListView.ItemName);
    end;
  finally
    IniFile.Free;
  end;
end;

procedure TRMDFormReportExplorer.SetViewToolbar(Value: Boolean);
begin
  padViewToolbar.Checked := Value;
  ToolBar.Visible := Value;
end;

procedure TRMDFormReportExplorer.SetViewStatusBar(Value: Boolean);
begin
  padViewStatusBar.Checked := Value;
  sbrExplorer.Visible := Value;
end;

procedure TRMDFormReportExplorer.SetViewStyle(Value: Boolean);
begin
  if Value then
  begin
    padViewList.Checked := True;
    ppmReportsViewList.Checked := True;
    btnViewDetails.Down := False;
    btnViewList.Down := True;
    FListView.ViewStyle := vsList;
  end
  else
  begin
    padViewDetails.Checked := True;
    ppmReportsViewDetails.Checked := True;
    btnViewList.Down := False;
    btnViewDetails.Down := True;
    FListView.ViewStyle := vsReport;
  end;
end;

procedure TRMDFormReportExplorer.OpenItem; //打开，修改报表
begin
  if FListView.FolderId = rmitRecycleBin then Exit;
  if FListView.ItemType = rmitFolder then Exit;

  Cursor := crHourGlass;
  FListView.Cursor := crHourGlass;
  try
    FReportExplorer.Open(FListView.ItemId, FListView.FolderId, FListVIew.ItemType, FListView.ItemName);
  finally
    Cursor := crDefault;
    FListView.Cursor := crDefault;
  end;
end;

procedure TRMDFormReportExplorer.SelectFolder(aFolderId: Integer); //选择文件夹
var
  Index: integer;
  ItemFound: TTreeNode;
begin
  Index := 0; ItemFound := nil;
  while Index < trvFolders.Items.Count do
  begin
    if Integer(trvFolders.Items[Index].Data) = aFolderId then
    begin
      ItemFound := trvFolders.Items[Index];
      Break;
    end;
    Inc(Index);
  end;

  if ItemFound <> nil then
    trvFolders.Selected := ItemFound
  else
    trvFolders.Selected := trvFolders.Items[0];

  FListView.FolderId := Integer(trvFolders.Selected.Data);
  UpdateStatusBar;
end;

procedure TRMDFormReportExplorer.UpdateStatusBar;
var
  item: TTreeNode;
begin
  Item := trvFolders.Selected;
  if Item <> nil then
  begin
    if Integer(Item.Data) = rmitRecycleBin then
    begin
      btnUpOneLevel.Enabled := False;
      btnNewFolder.Enabled := False;
      btnNewReport.Enabled := False;
      btnOpenReport.Enabled := False;

      padFileOpen.Enabled := btnOpenReport.Enabled;
      padFileNewFolder.Enabled := False;
      padFileNewReport.Enabled := False;
      padFileRename.Enabled := False;
    end
    else
    begin
      btnUpOneLevel.Enabled := Integer(Item.Data) <> rmitAllFolders;
      btnNewFolder.Enabled := True;
      btnNewReport.Enabled := True;
      btnOpenReport.Enabled := True;

      padFileOpen.Enabled := True;
      padFileNewFolder.Enabled := True;
      padFileNewReport.Enabled := True;
      padFileRename.Enabled := TRUE;
    end;
  end;

  btnPrint.Enabled := FListView.Focused and (FListView.ItemType >= rmitReport) and
    (FListView.ItemType < rmitFolder);
  btnPrintPreview.Enabled := btnPrint.Enabled;
  ppmPrint.Enabled := btnPrint.Enabled;
  ppmPrintPreview.Enabled := btnPrint.Enabled;
  padFilePrint.Enabled := btnPrint.Enabled;
  padFilePrintPreview.Enabled := btnPrint.Enabled;

  item := trvFolders.Selected;
  btnDelete.Enabled := (FListView.Selected <> nil) or
    ((item <> nil) and (Integer(Item.Data) > rmitAllFolders));
end;

procedure TRMDFormReportExplorer.UpdateRecycleBin;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    FReportExplorer.GetItems(rmitRecycleBin, sl);
    if sl.Count > 0 then
    begin
      FRecycleBinNode.ImageIndex := 1;
      FRecycleBinNode.SelectedIndex := 1;
    end
    else
    begin
      FRecycleBinNode.ImageIndex := 3;
      FRecycleBinNode.SelectedIndex := 3;
    end;
  finally
    while sl.Count > 0 do
    begin
      TRMItemInfo(sl.Objects[0]).Free;
      sl.Delete(0);
    end;
    sl.Free;
  end;
end;

procedure TRMDFormReportExplorer.padFilePrintClick(Sender: TObject); //打印报表
begin
  if FListView.ItemName <> '' then
    FReportExplorer.Print(FListView.ItemId, FListView.FolderId, FListView.ItemType, FListView.ItemName);
end;

procedure TRMDFormReportExplorer.padFilePrintPreviewClick(Sender: TObject); //预览报表
begin
  if FListView.ItemName <> '' then
    FReportExplorer.PrintPreview(FListView.ItemId, FListView.FolderId, FListView.ItemType, FListView.ItemName);
end;

procedure TRMDFormReportExplorer.padFileOpenClick(Sender: TObject);
begin
  if trvFolders.Focused then
  begin
    if (trvFolders.Selected <> nil) and (not trvFolders.Selected.Expanded) then
      trvFolders.Selected.Expanded := True;
  end
  else
    OpenItem;
end;

procedure TRMDFormReportExplorer.padFileNewReportClick(Sender: TObject); //新报表
var
  i: Integer;
begin
  if trvFolders.Selected <> nil then
    i := Integer(trvFolders.Selected.Data)
  else
    i := rmitAllFolders;
  FReportExplorer.New(i);
end;

procedure TRMDFormReportExplorer.padFileNewFolderClick(Sender: TObject); //新文件夹
var
  Item: TTreeNode;
  lsName: string;
  FolderId: Integer;
begin
  Item := trvFolders.Selected;
  if (Item = nil) or (Integer(Item.Data) = rmitRecycleBin) then Exit;
  trvFolders.Items.BeginUpdate;
  lsName := FReportExplorer.GetNewFolderName(Integer(Item.Data));
  if (trvFolders.Selected <> nil) then
    FReportExplorer.AddFolder(Integer(trvFolders.Selected.Data), lsName, FolderID)
  else
    FReportExplorer.AddFolder(rmitAllFolders, lsName, FolderId);

  Item := trvFolders.Items.AddChild(trvFolders.Selected, lsName);
  Item.Data := TObject(FolderID);
  Item.ImageIndex := 0;
  Item.SelectedIndex := 2;
  if (Item.Parent <> nil) then
    Item.Parent.Expand(False);
  trvFolders.Selected := Item;
  trvFolders.Items.EndUpdate;
  trvFolders.Selected.EditText;
end;

procedure TRMDFormReportExplorer.padFileDeleteClick(Sender: TObject);
var
  Node: TTreeNode;
  NewNode: TTreeNode;
  FolderId: Integer;
begin
  Node := trvFolders.Selected;
  if Node = nil then Exit;
  if trvFolders.Focused then
  begin
    FolderId := Integer(Node.Data);
    if (FolderId = rmitRecycleBin) or (FolderId = rmitAllFolders) then Exit;
    if Application.MessageBox(PChar(RMLoadStr(rmRes + 3161)), PChar(RMLoadStr(rmRes + 3162)),
      MB_ICONQUESTION + MB_YESNO) = IDYES then
    begin
      if FReportExplorer.ChangeParentFolder(FolderId, rmitRecycleBin) then
      begin
        NewNode := FindNearestNode(Node);
        SelectFolder(Integer(NewNode.Data));
        Node.Free;
      end;
    end;
  end
  else
    FListView.DeleteSelection;
  UpdateRecycleBin;
end;

procedure TRMDFormReportExplorer.padViewListClick(Sender: TObject);
begin
  SetViewStyle(True);
end;

procedure TRMDFormReportExplorer.padViewDetailsClick(Sender: TObject);
begin
  SetViewStyle(False);
end;

procedure TRMDFormReportExplorer.padViewToolbarClick(Sender: TObject);
begin
  SetViewToolbar(not (padViewToolbar.Checked));
end;

procedure TRMDFormReportExplorer.padViewStatusBarClick(Sender: TObject);
begin
  SetViewStatusBar(not (padViewStatusBar.Checked));
end;

procedure TRMDFormReportExplorer.padFileCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TRMDFormReportExplorer.trvFoldersEdited(Sender: TObject; Node: TTreeNode;
  var S: string); //重命名文件夹
begin
  FReportExplorer.RenameFolder(Integer(Node.Data), S);
end;

procedure TRMDFormReportExplorer.padFileRenameClick(Sender: TObject); //重命名报表
var
  Node: TTreeNode;
begin
  if trvFolders.Focused then
  begin
    Node := trvFolders.Selected;
    if (Node <> nil) and (Integer(Node.Data) > rmitAllFolders) then
      Node.EditText;
  end
  else
    FListView.RenameItem;
end;

procedure TRMDFormReportExplorer.ListDoubleClickEvent(Sender: TObject);
begin
  OpenItem;
end;

procedure TRMDFormReportExplorer.ListRenameFolderEvent(Sender: TObject; aFolderId: Integer; const aNewName: string);
var
  TreeNode: TTreeNode;
begin
  TreeNode := FindDataInTreeView(trvFolders, aFolderId);
  TreeNode.Text := aNewName;
end;

function TRMDFormReportExplorer.FindDataInTreeView(aTreeView: TTreeView; aData: Integer): TTreeNode;
var
  Index: Integer;
  TreeNode: TTreeNode;
begin
  Result := nil;
  if (aTreeView.Items.Count = 0) then Exit;

  Index := 0;
  TreeNode := aTreeView.Items[Index];
  while (Index < aTreeView.Items.Count) and (Integer(TreeNode.Data) <> aData) do
  begin
    Inc(Index);
    TreeNode := aTreeView.Items[Index];
  end;
  Result := TreeNode;
end;

procedure TRMDFormReportExplorer.ListFolderChangeEvent(Sender: TObject);
begin
//  UpdateTreeView;
  SelectFolder(FListView.FolderId);
end;

procedure TRMDFormReportExplorer.ListSelectionChangeEvent(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TRMDFormReportExplorer.trvFoldersEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
begin
  if (Integer(Node.Data) = rmitAllFolders) or (Integer(Node.Data) = rmitRecycleBin) then
    AllowEdit := False;
end;

procedure TRMDFormReportExplorer.trvFoldersDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item: TTreeNode;
  tmpSelected: TTreeNode;
begin
  Accept := False;
  tmpSelected := trvFolders.Selected;
  if (tmpSelected = nil) then Exit;
  if (Source = trvFolders) and ((tmpSelected = FAllFoldersNode) or (tmpSelected = FRecycleBinNode)) then Exit;
  Item := trvFolders.GetNodeAt(X, Y);
  if (Source = trvFolders) and (Item <> nil) then
    Accept := (Item <> tmpSelected) and (Item <> tmpSelected.Parent)
  else
    Accept := True;
end;

procedure TRMDFormReportExplorer.trvFoldersDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  TargetItem: TTreeNode;
  SourceItem: TTreeNode;
  NewNode: TTreeNode;
  TargetFolderId: Integer;
  SourceFolderId: Integer;
  FolderId: Integer;
begin
  TargetItem := trvFolders.GetNodeAt(X, Y);
  if TargetItem <> nil then
  begin
    TargetFolderId := Integer(TargetItem.Data);
    if Source = trvFolders then
    begin
      SourceItem := trvFolders.Selected;
      if SourceItem = nil then Exit;
      SourceFolderId := Integer(SourceItem.Data);
      if FReportExplorer.ChangeParentFolder(SourceFolderId, TargetFolderId) then
      begin
        if TargetFolderId = rmitRecycleBin then
        begin
          NewNode := FindNearestNode(SourceItem);
          if NewNode <> nil then
            FolderId := Integer(NewNode.Data)
          else
            FolderId := rmitAllFolders;
        end
        else
          FolderId := SourceFolderId;

        UpdateTreeView;
        SelectFolder(FolderId);
      end;
    end
    else if Source = FListView then
    begin
      FListView.MoveSelectionToFolder(TargetFolderId);
      SourceItem := trvFolders.Selected;
      if SourceItem = nil then Exit;
      SourceFolderId := Integer(SourceItem.Data);
      if TargetFolderId = rmitRecycleBin then
        UpdateRecycleBin
      else if SourceFolderId = rmitRecycleBin then
        UpdateRecycleBin
    end;
  end;
end;

function TRMDFormReportExplorer.FindNearestNode(aNode: TTreeNode): TTreeNode;
begin
  Result := aNode.GetNextSibling;
  if (Result <> nil) then Exit;
  Result := aNode.GetPrevSibling;
  if (Result <> nil) then Exit;
  Result := aNode.Parent;
  if (Result <> nil) then Exit;
  Result := trvFolders.Items[0];
end;

procedure TRMDFormReportExplorer.UpdateTreeView;
var
  Index: Integer;
  Items: TTreeNodes;
  Item: TTreeNode;
  Folders: TStringList;
  FolderNodes: TStringList;
  FolderInfo: TRMFolderInfo;
  ParentIndex: Integer;
  ParentNode: TTreeNode;
begin
  Folders := TStringList.Create;
  FolderNodes := TStringList.Create;
  FReportExplorer.GetFolders(Folders);
  Items := trvFolders.Items;
  Items.BeginUpdate;
  Items.Clear;
  try
    FAllFoldersNode := trvFolders.Items.AddObject(nil, RMLoadStr(rmRes + 3159), TObject(rmitAllFolders));
    FAllFoldersNode.ImageIndex := 0;
    FAllFoldersNode.SelectedIndex := 2;
    FolderNodes.AddObject(IntToStr(rmitAllFolders), FAllFoldersNode);

    FRecycleBinNode := trvFolders.Items.AddObject(nil, RMLoadStr(rmRes + 3160), TObject(rmitRecycleBin));
    FolderNodes.AddObject(IntToStr(rmitRecycleBin), FRecycleBinNode);
    while Folders.Count > 0 do
    begin
      Index := 0;
      FolderInfo := TRMFolderInfo(Folders.Objects[Index]);
      ParentIndex := FolderNodes.IndexOf(IntToStr(FolderInfo.ParentId));
      while (ParentIndex = -1) and (Index < Folders.Count - 1) do
      begin
        Inc(Index);
        FolderInfo := TRMFolderInfo(Folders.Objects[Index]);
        ParentIndex := FolderNodes.IndexOf(IntToStr(FolderInfo.ParentId));
      end;
      if (ParentIndex <> -1) then
        ParentNode := TTreeNode(FolderNodes.Objects[ParentIndex])
      else
        ParentNode := FAllFoldersNode;

      Item := Items.AddChild(ParentNode, FolderInfo.Name);
      Item.Data := TObject(FolderInfo.FolderId);
      Item.ImageIndex := 0;
      Item.SelectedIndex := 2;
      FolderNodes.AddObject(IntToStr(FolderInfo.FolderId), Item);
      FolderInfo.Free;
      Folders.Delete(Index);
    end;
  finally
    UpdateRecycleBin;
    Items.EndUpdate;
    Folders.Free;
    FolderNodes.Free;
    FAllFoldersNode.Expanded := True;
  end;
end;

procedure TRMDFormReportExplorer.ppmReportsPopup(Sender: TObject);
var
  Node: TTreeNode;
  FolderId: Integer;
begin
  Node := trvFolders.Selected;
  if Node = nil then Exit;
  FolderId := Integer(Node.Data);
  if FolderId = rmitRecycleBin then
  begin
    ppmReportsNewFolder.Enabled := False;
    ppmReportsNewReport.Enabled := False;
    ppmReportsRename.Enabled := False;
  end
  else
  begin
    ppmReportsNewFolder.Enabled := True;
    ppmReportsNewReport.Enabled := True;
    ppmReportsRename.Enabled := True;
  end;
end;

procedure TRMDFormReportExplorer.ppmFoldersPopup(Sender: TObject);
var
  Node: TTreeNode;
  FolderId: Integer;
begin
  Node := trvFolders.Selected;
  if Node = nil then Exit;
  FolderId := Integer(Node.Data);
  ppmFoldersEmptyRecycleBin.Visible := (FolderId = rmitRecycleBin);
  if FolderId = rmitRecycleBin then
  begin
    ppmFoldersExplore.Enabled := False;
    ppmFoldersOpen.Enabled := False;
    ppmFoldersNewFolder.Enabled := False;
    ppmFoldersNewReport.Enabled := False;
    ppmFoldersDelete.Enabled := False;
    ppmFoldersRename.Enabled := False;
  end
  else if FolderId = rmitAllFolders then
  begin
    ppmFoldersExplore.Enabled := False;
    ppmFoldersOpen.Enabled := False;
    ppmFoldersNewFolder.Enabled := True;
    ppmFoldersNewReport.Enabled := True;
    ppmFoldersDelete.Enabled := False;
    ppmFoldersRename.Enabled := False;
  end
  else
  begin
    ppmFoldersExplore.Enabled := True;
    ppmFoldersOpen.Enabled := True;
    ppmFoldersNewFolder.Enabled := True;
    ppmFoldersNewReport.Enabled := True;
    ppmFoldersDelete.Enabled := True;
    ppmFoldersRename.Enabled := True;
  end;
end;

procedure TRMDFormReportExplorer.FormCreate(Sender: TObject);
begin
  Localize;
  FReportExplorer := nil;
  FListView := TRMItemListView.Create(Self);
  FListView.Parent := pnlReports;
  FListView.Align := alClient;
  FListView.MultiSelect := True;
  FListView.PopupMenu := ppmReports;
  FListView.ViewStyle := vsList;
  FListView.SmallImages := ImageListListView;
  FListView.HideSelection := FALSE;

  FListView.OnDoubleClick := ListDoubleClickEvent;
  FListView.OnFolderChange := ListFolderChangeEvent;
  FListView.OnRenameFolder := ListRenameFolderEvent;
  FListView.OnSelectionChange := ListSelectionChangeEvent;
end;

procedure TRMDFormReportExplorer.FormDestroy(Sender: TObject);
begin
  FListView.ClearData;
  SaveToIniFile;
end;

procedure TRMDFormReportExplorer.FormShow(Sender: TObject);
begin
  LoadFromIniFile;
  UpdateTreeView;
  SelectFolder(FListView.FolderId);
end;

procedure TRMDFormReportExplorer.ppmFoldersEmptyRecycleBinClick(Sender: TObject);
begin
  FListView.EmptyRecycleBin;
  UpdateRecycleBin;
end;

procedure TRMDFormReportExplorer.trvFoldersChange(Sender: TObject;
  Node: TTreeNode);
begin
  if Node <> nil then
    SelectFolder(Integer(Node.Data));
end;

procedure TRMDFormReportExplorer.btnUpOneLevelClick(Sender: TObject);
var
  Item: TTreeNode;
begin
  Item := trvFolders.Selected;
  if (Item.Parent <> nil) then
    SelectFolder(Integer(Item.Parent.Data));
end;

end.

