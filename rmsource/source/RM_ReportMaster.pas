unit RM_ReportMaster;

{$I RM.INC}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls,
  ComCtrls, Dialogs, Menus, RM_Common, RM_Class, RM_DataSet
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMTree = class;

  TRMColumnInfo = class(TObject)
  private
    FDataFont: TFont;
    FDataHAlign: TRMHAlign;
    FDataVAlign: TRMVAlign;
    FDataFillColor: TColor;
    FDataFieldName: string;

    FTitleFont: TFont;
    FTitleCaption: string; // ÁÐÃû³Æ
    FTitleHAlign: TRMHAlign;
    FTitleVAlign: TRMVAlign;
    FTitleFillColor: TColor;
    FWidth: Integer;

    procedure SetDisplayFormat(Value: string);
    procedure SetDataFont(Value: TFont);
    procedure SetTitleFont(Value: TFont);
  protected
    FDisplayFormat: string;
    FormatFlag: TRMFormat;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(aSource: TRMColumnInfo);
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property Width: Integer read FWidth write FWidth;

    property DataFieldName: string read FDataFieldName write FDataFieldName;
    property DataFont: TFont read FDataFont write SetDataFont;
    property DataHAlign: TRMHAlign read FDataHAlign write FDataHAlign;
    property DataVAlign: TRMVAlign read FDataVAlign write FDataVAlign;
    property DataFillColor: TColor read FDataFillColor write FDataFillColor;

    property TitleCaption: string read FTitleCaption write FTitleCaption;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property TitleHAlign: TRMHAlign read FTitleHAlign write FTitleHAlign;
    property TitleVAlign: TRMVAlign read FTitleVAlign write FTitleVAlign;
    property TitleFillColor: TColor read FTitleFillColor write FTitleFillColor;
  published
  end;

  { TRMTreeNode }
  TRMTreeNode = class(TObject)
  private
    FOwnerTree: TRMTree;
    FParentNode: TRMTreeNode;
    FList: TList;
    FText: string;
    FColumnInfo: TRMColumnInfo;

    function GetAbsIndex: Integer;
    function GetCount: Integer;
    function GetIndex: Integer;
    function GetLevel: Integer;
    function GetItem(aIndex: Integer): TRMTreeNode;
    procedure SetItem(aIndex: Integer; aValue: TRMTreeNode);
  protected
  public
    constructor Create(aOwnerTree: TRMTree; aParentNode: TRMTreeNode);
    destructor Destroy; override;
    procedure Assign(ASource: TRMTreeNode);
    procedure Clear;
    procedure Delete;
    procedure DeleteChild(aIndex: Integer);
    function IndexOf(aNode: TRMTreeNode): Integer;
    function GetFirstChild: TRMTreeNode;
    function GetFirstSibling: TRMTreeNode;
    function GetPrevSibling: TRMTreeNode;
    function GetNextSibling: TRMTreeNode;
    function GetLastSibling: TRMTreeNode;
    function GetNext: TRMTreeNode;
    function GetSiblingCount: Integer;

    property Item[Index: Integer]: TRMTreeNode read GetItem write SetItem; default;
    property Level: Integer read GetLevel;
    property Count: Integer read GetCount;
    property Index: Integer read GetIndex;
    property AbsIndex: Integer read GetAbsIndex;
    property ParentNode: TRMTreeNode read FParentNode;
    property Text: string read FText write FText;
    property ColumnInfo: TRMColumnInfo read FColumnInfo;
  end;

  { TRMTree }
  TRMTree = class(TObject)
  private
    FList: TList;

    function GetCount: Integer;
    function GetItem(aIndex: Integer): TRMTreeNode;
    procedure SetItem(aIndex: Integer; aValue: TRMTreeNode);
  protected
    function AddObject(aSibling: TRMTreeNode; const aText: string): TRMTreeNode;
    function InsertObject(aTarget: TRMTreeNode; const aText: string): TRMTreeNode;
    function AddChildObject(aParent: TRMTreeNode; const aText: string): TRMTreeNode;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(aSource: TRMTree);
    procedure Clear;
    function Add(aSibling: TRMTreeNode; const aText: string): TRMTreeNode;
    function AddChild(aParent: TRMTreeNode; const aText: string): TRMTreeNode;
    function Insert(aTarget: TRMTreeNode; const aText: string): TRMTreeNode;
    procedure DeleteChild(aIndex: Integer);
    function IndexOf(aNode: TRMTreeNode): Integer;

    property Items[Index: Integer]: TRMTreeNode read GetItem write SetItem; default;
    property Count: Integer read GetCount;
  end;

  { TRMCustomReportMaster }
  TRMCustomReportMaster = class(TComponent)
  private
    FDefaultFont: TFont;
    FAutoHCenter: Boolean;
    FAutoVCenter: Boolean;
    FAutoAppendBlank: Boolean;

    procedure SetDefaultFont(Value: TFont);
  protected
    FReport: TRMReport;
    FDataSet: TRMDataSet;
    FReportDataTree: TRMTree;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function DesignTemplate: Boolean;
    procedure DesignReport;
    procedure ShowReport;
    procedure PrintReport;
    function CreateReport: Boolean; virtual;

    procedure LoadFromStream(aStream: TStream);
    procedure SaveToStream(aStream: TStream);
    procedure LoadFromFile(aFileName: string);
    procedure SaveToFile(aFileName: string);
    property ReportDataTree: TRMTree read FReportDataTree;

    property Report: TRMReport read FReport;
  published
    property DataSet: TRMDataSet read FDataSet write FDataSet;
    property DefaultFont: TFont read FDefaultFont write SetDefaultFont;
    property AutoAppendBlank: Boolean read FAutoAppendBlank write FAutoAppendBlank;
    property AutoHCenter: Boolean read FAutoHCenter write FAutoHCenter;
    property AutoVCenter: Boolean read FAutoVCenter write FAutoVCenter;
  end;

implementation

uses
  RM_Utils, RM_Const, RM_Const1, RM_EditorReportMaster;

function _InEffectListIndex(aList: TList; aIndex: Integer): Boolean;
begin
  Result := (aIndex > -1) and (aIndex < aList.Count);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMColumnInfo }
{------------------------------------------------------------------------------}

constructor TRMColumnInfo.Create;
begin
  inherited Create;

  FDataFont := TFont.Create;
  FDataFillColor := clNone;
  FDataHAlign := rmHCenter;
  FDataVAlign := rmVCenter;

  FTitleFont := TFont.Create;
  FTitleFillColor := clNone;
  FTitleHAlign := rmHCenter;
  FTitleVAlign := rmVCenter;
end;

destructor TRMColumnInfo.Destroy;
begin
  FreeAndNil(FDataFont);
  FreeAndNil(FTitleFont);

  inherited Destroy;
end;

procedure TRMColumnInfo.Assign(aSource: TRMColumnInfo);
begin
  DataFont.Assign(aSource.DataFont);
  DataHAlign := aSource.DataHAlign;
  DataVAlign := aSource.DataVAlign;
  DataFillColor := aSource.DataFillColor;
  DataFieldName := aSource.DataFieldName;

  TitleFont.Assign(aSource.TitleFont);
  TitleHAlign := aSource.TitleHAlign;
  TitleVAlign := aSource.TitleVAlign;
  TitleFillColor := aSource.TitleFillColor;
  TitleCaption := aSource.TitleCaption;

  DisplayFormat := aSource.DisplayFormat;
  Width := aSource.Width;
end;

procedure TRMColumnInfo.SetDisplayFormat(Value: string);
begin
  FDisplayFormat := Value;
  RMGetFormatStr_1(FDisplayFormat, FormatFlag);
end;

procedure TRMColumnInfo.SetDataFont(Value: TFont);
begin
  FDataFont.Assign(Value);
end;

procedure TRMColumnInfo.SetTitleFont(Value: TFont);
begin
  FTitleFont.Assign(Value);
end;

{------------------------------------------------------------------------------}
{ TRMTreeNode }

constructor TRMTreeNode.Create(aOwnerTree: TRMTree; aParentNode: TRMTreeNode);
begin
  inherited Create;

  FOwnerTree := aOwnerTree;
  FParentNode := aParentNode;

  FList := TList.Create;
  FColumnInfo := TRMColumnInfo.Create;
end;

destructor TRMTreeNode.Destroy;
begin
  Delete;
  FreeAndNil(FList);
  FreeAndNil(FColumnInfo);

  inherited Destroy;
end;

procedure TRMTreeNode.Assign(aSource: TRMTreeNode);
var
  i: Integer;
begin
  if aSource = nil then Exit;

  Clear;
  FText := aSource.FText;
  FColumnInfo.Assign(aSource.ColumnInfo);
  for i := 0 to aSource.Count - 1 do
    FOwnerTree.AddChild(Self, '').Assign(aSource[i]);
end;

procedure TRMTreeNode.Clear;
var
  i: Integer;
  lNode: TRMTreeNode;
begin
  for i := FList.Count - 1 downto 0 do
  begin
    lNode := Item[i];
    lNode.Delete;
    lNode.Free;
  end;

  FList.Clear;
end;

procedure TRMTreeNode.Delete;
var
  lIndex: Integer;
begin
  Clear;
  lIndex := Self.Index;
  if FParentNode = nil then
  begin
    if lIndex >= 0 then
      FOwnerTree.FList.Delete(lIndex);
  end
  else
  begin
    if lIndex >= 0 then
      FParentNode.FList.Delete(lIndex);
  end;
end;

procedure TRMTreeNode.DeleteChild(aIndex: Integer);
var
  lNode: TRMTreeNode;
begin
  lNode := Item[aIndex];
  if lNode <> nil then
  begin
    lNode.Delete;
    lNode.Free;
  end;
end;

function TRMTreeNode.GetAbsIndex: Integer;
var
  i: Integer;
  lNode: TRMTreeNode;
begin
  lNode := FOwnerTree.Items[0];
  Result := -1;
  i := 0;
  while lNode <> nil do
  begin
    if lNode = Self then
    begin
      Result := i;
      Exit;
    end;

    lNode := lNode.GetNext;
    Inc(i);
  end;
end;

function TRMTreeNode.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TRMTreeNode.GetSiblingCount: Integer;
begin
  if FParentNode <> nil then
    Result := FParentNode.Count
  else
    Result := FOwnerTree.Count;
end;

function TRMTreeNode.GetFirstChild: TRMTreeNode;
begin
  if FList.Count > 0 then
    Result := Item[0] // TRMTreeNode(FList[0])
  else
    Result := nil;
end;

function TRMTreeNode.GetIndex: Integer;
begin
  if FParentNode <> nil then
    Result := FParentNode.IndexOf(Self)
  else
    Result := FOwnerTree.IndexOf(Self);
end;

function TRMTreeNode.GetItem(aIndex: Integer): TRMTreeNode;
begin
  if _InEffectListIndex(FList, aIndex) then
    Result := TRMTreeNode(FList[aIndex])
  else
    Result := nil;
end;

function TRMTreeNode.GetLevel: Integer;
var
  lParentNode: TRMTreeNode;
begin
  Result := 0;
  lParentNode := FParentNode;
  while lParentNode <> nil do
  begin
    Inc(Result);
    lParentNode := lParentNode.ParentNode;
  end;
end;

function TRMTreeNode.GetNext: TRMTreeNode;
begin
  Result := GetFirstChild;
  if Result = nil then
  begin
    Result := GetNextSibling;
    if Result = nil then
    begin
      Result := ParentNode;
      if Result <> nil then
        Result := Result.GetNextSibling;
    end;
  end;
end;

function TRMTreeNode.GetFirstSibling: TRMTreeNode;
var
  lIndex: Integer;
begin
  lIndex := Self.Index;
  if FParentNode <> nil then
    Result := FParentNode.Item[lIndex]
  else
    Result := FOwnerTree.Items[lIndex];
end;

function TRMTreeNode.GetLastSibling: TRMTreeNode;
begin
  if FParentNode <> nil then
    Result := FParentNode.Item[FParentNode.Count - 1]
  else
    Result := FOwnerTree.Items[FOwnerTree.Count - 1];
end;

function TRMTreeNode.GetNextSibling: TRMTreeNode;
var
  lIndex: Integer;
begin
  lIndex := Self.Index;
  if FParentNode <> nil then
  begin
    if lIndex < FParentNode.Count - 1 then
      Result := FParentNode.Item[lIndex + 1]
    else
      Result := nil;
  end
  else
  begin
    if lIndex < FOwnerTree.Count - 1 then
      Result := FOwnerTree.Items[lIndex + 1]
    else
      Result := nil;
  end;
end;

function TRMTreeNode.GetPrevSibling: TRMTreeNode;
var
  lIndex: Integer;
begin
  lIndex := Self.Index;
  if lIndex = 0 then
    Result := nil
  else
  begin
    if FParentNode <> nil then
      Result := FParentNode.Item[lIndex - 1]
    else
      Result := FOwnerTree.Items[lIndex - 1];
  end;
end;

function TRMTreeNode.IndexOf(aNode: TRMTreeNode): Integer;
begin
  Result := FList.IndexOf(aNode);
end;

procedure TRMTreeNode.SetItem(aIndex: Integer; aValue: TRMTreeNode);
begin
  FList[aIndex] := aValue;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMTree }

constructor TRMTree.Create;
begin
  inherited Create;

  FList := TList.Create;
end;

destructor TRMTree.Destroy;
begin
  Clear;
  FList.Free;

  inherited Destroy;
end;

procedure TRMTree.Assign(aSource: TRMTree);
var
  i: Integer;
begin
  if aSource = nil then Exit;

  Clear;
  for i := 0 to aSource.Count - 1 do
    Add(nil, '').Assign(aSource.Items[I]);
end;

procedure TRMTree.Clear;
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
    DeleteChild(i);
end;

procedure TRMTree.DeleteChild(aIndex: Integer);
var
  lNode: TRMTreeNode;
begin
  lNode := Items[aIndex];
  if lNode <> nil then
  begin
    lNode.Delete;
    lNode.Free;
  end;
end;

function TRMTree.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TRMTree.GetItem(aIndex: Integer): TRMTreeNode;
begin
  if _InEffectListIndex(FList, aIndex) then
    Result := TRMTreeNode(FList[aIndex])
  else
    Result := nil;
end;

function TRMTree.IndexOf(aNode: TRMTreeNode): Integer;
begin
  Result := FList.IndexOf(aNode);
end;

procedure TRMTree.SetItem(aIndex: Integer; aValue: TRMTreeNode);
begin
  FList[aIndex] := aValue;
end;

function TRMTree.Add(aSibling: TRMTreeNode; const aText: string): TRMTreeNode;
begin
  Result := AddObject(aSibling, aText);
end;

function TRMTree.AddChild(aParent: TRMTreeNode; const aText: string): TRMTreeNode;
begin
  if aParent = nil then
    Result := Add(nil, aText)
  else
    Result := AddChildObject(aParent, aText);
end;

function TRMTree.AddChildObject(aParent: TRMTreeNode; const aText: string): TRMTreeNode;
begin
  if aParent <> nil then
  begin
    Result := TRMTreeNode.Create(Self, aParent);
    Result.FText := aText;
    aParent.FList.Add(Result);
  end
  else
    Result := nil;
end;

function TRMTree.AddObject(aSibling: TRMTreeNode; const aText: string): TRMTreeNode;
var
  lParentNode: TRMTreeNode;
begin
  if aSibling <> nil then
    lParentNode := aSibling.ParentNode
  else
    lParentNode := nil;

  Result := TRMTreeNode.Create(Self, lParentNode);
  Result.FText := aText;
  if lParentNode = nil then
    FList.Add(Result)
  else
    lParentNode.FList.Add(Result);
end;

function TRMTree.Insert(aTarget: TRMTreeNode; const aText: string): TRMTreeNode;
begin
  Result := InsertObject(aTarget, aText);
end;

function TRMTree.InsertObject(aTarget: TRMTreeNode; const aText: string): TRMTreeNode;
var
  lIndex: Integer;
begin
  if aTarget = nil then
    Result := AddObject(nil, aText)
  else
  begin
    lIndex := aTarget.Index;
    aTarget := aTarget.ParentNode;
    if aTarget = nil then
    begin
      Result := TRMTreeNode.Create(Self, nil);
      FList.Insert(lIndex, Result);
    end
    else
    begin
      Result := TRMTreeNode.Create(Self, aTarget);
      ATarget.FList.Insert(lIndex, Result);
    end;

    Result.FText := aText;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomReportMaster }

constructor TRMCustomReportMaster.Create(aOwner: TComponent);
begin
  inherited;

  FReport := nil;
  FReportDataTree := TRMTree.Create;
  FDefaultFont := TFont.Create;
end;

destructor TRMCustomReportMaster.Destroy;
begin
  FreeAndNil(FReport);
  FreeAndNil(FReportDataTree);
  FreeAndNil(FDefaultFont);

  inherited;
end;

function TRMCustomReportMaster.CreateReport: Boolean;
begin
  Result := False;
end;

function TRMCustomReportMaster.DesignTemplate: Boolean;
var
  tmp: TRMFormReportMaster;
begin
  tmp := TRMFormReportMaster.Create(nil);
  try
    Result := tmp.Execute(Self);
  finally
    tmp.Free;
  end;
end;

procedure TRMCustomReportMaster.DesignReport;
begin
  if CreateReport then
    FReport.DesignReport;
end;

procedure TRMCustomReportMaster.ShowReport;
begin
  if CreateReport then
    FReport.ShowReport;
end;

procedure TRMCustomReportMaster.PrintReport;
begin
  if CreateReport then
    FReport.PrintReport;
end;

procedure TRMCustomReportMaster.LoadFromStream(aStream: TStream);

  procedure _LoadOneNode(aParentNode: TRMTreeNode);
  var
    i: Integer;
    lNode: TRMTreeNode;
    lChildCount, lCount: Integer;
  begin
    lCount := RMReadInt32(aStream);
    for i := 0 to lCount - 1 do
    begin
      lChildCount := RMReadInt32(aStream);
      lNode := ReportDataTree.AddChild(aParentNode, '');
      lNode.ColumnInfo.TitleCaption := RMReadString(aStream);
      RMReadFont(aStream, lNode.ColumnInfo.TitleFont);
      lNode.ColumnInfo.TitleHAlign := TRMHAlign(RMReadByte(aStream));
      lNode.ColumnInfo.TitleVAlign := TRMVAlign(RMReadByte(aStream));
      lNode.ColumnInfo.TitleFillColor := RMReadInt32(aStream);

      lNode.ColumnInfo.DataFieldName := RMReadString(aStream);
      RMReadFont(aStream, lNode.ColumnInfo.DataFont);
      lNode.ColumnInfo.DataHAlign := TRMHAlign(RMReadByte(aStream));
      lNode.ColumnInfo.DataVAlign := TRMVAlign(RMReadByte(aStream));
      lNode.ColumnInfo.DataFillColor := RMReadInt32(aStream);

      lNode.ColumnInfo.Width := RMReadInt32(aStream);
      if lChildCount > 0 then
        _LoadOneNode(lNode);
    end;
  end;

begin
  FReportDataTree.Clear;
  if RMReadByte(aStream) = 1 then
  begin
    _LoadOneNode(nil);
  end;
end;

procedure TRMCustomReportMaster.SaveToStream(aStream: TStream);

  procedure _SaveOneNode(aNode: TRMTreeNode);
  begin
    RMWriteInt32(aStream, aNode.GetSiblingCount);
    while aNode <> nil do
    begin
      RMWriteInt32(aStream, aNode.Count);
      RMWriteString(aStream, aNode.ColumnInfo.TitleCaption);
      RMWriteFont(aStream, aNode.ColumnInfo.TitleFont);
      RMWriteByte(aStream, Byte(aNode.ColumnInfo.TitleHAlign));
      RMWriteByte(aStream, Byte(aNode.ColumnInfo.TitleVAlign));
      RMWriteInt32(aStream, aNode.ColumnInfo.TitleFillColor);

      RMWriteString(aStream, aNode.ColumnInfo.DataFieldName);
      RMWriteFont(aStream, aNode.ColumnInfo.DataFont);
      RMWriteByte(aStream, Byte(aNode.ColumnInfo.DataHAlign));
      RMWriteByte(aStream, Byte(aNode.ColumnInfo.DataVAlign));
      RMWriteInt32(aStream, aNode.ColumnInfo.DataFillColor);

      RMWriteInt32(aStream, aNode.ColumnInfo.Width);
      if aNode.Count > 0 then
        _SaveOneNode(aNode[0]);

      aNode := aNode.GetNextSibling;
    end;
  end;

begin
  if ReportDataTree.Count > 0 then
  begin
    RMWriteByte(aStream, 1);
    _SaveOneNode(ReportDataTree.Items[0]);
  end
  else
  begin
    RMWriteByte(aStream, 0);
  end;
end;

procedure TRMCustomReportMaster.LoadFromFile(aFileName: string);
var
  lStream: TFileStream;
begin
  if ExtractFileExt(aFileName) = '' then
    aFileName := aFileName + '.rmm';

  if FileExists(aFileName) then
  begin
    lStream := TFileStream.Create(aFileName, fmOpenRead);
    try
      LoadFromStream(lStream);
    finally
      lStream.Free;
    end;
  end;
end;

procedure TRMCustomReportMaster.SaveToFile(aFileName: string);
var
  lStream: TFileStream;
begin
  if ExtractFileExt(aFileName) = '' then
    aFileName := aFileName + '.rmm';

  lStream := TFileStream.Create(aFileName, fmCreate);
  try
    SaveToStream(lStream);
  finally
    lStream.Free;
  end;
end;

procedure TRMCustomReportMaster.SetDefaultFont(Value: TFont);
begin
	FDefaultFont.Assign(Value);
end;

end.

