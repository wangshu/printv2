unit RM_EditorInsField;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, RM_DsgCtrls
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMInsFieldsForm = class(TRMToolWin)
  private
    FDataSetCount: Integer;
    FlstFields: TListBox;
    lstDatasets: TListBox;
    Splitter: TSplitter;
    FSaveHeight: Integer;

    FHeightChanged: TNotifyEvent;
    FOnCloseEvent: TNotifyEvent;
    FDatasetBmp1, FDatasetBmp2, FFieldBmp1, FFieldBmp2: TBitmap;

    procedure OnFormCloseEvent(Sender: TObject);
    procedure OnFormVisibleChangedEvent(Sender: TObject);
    procedure OnFormResizeEvent(Sender: TObject);
    procedure GetDatasets;
    procedure GetFieldName;

    procedure OnlstDatasetsClick(Sender: TObject);
    procedure OnlstDatasetsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure OnlstFieldsStartDrag(Sender: TObject; var DragObject: TDragObject);

    function GetSplitterPos: Integer;
    procedure SetSplitterPos(Value: Integer);
  protected
    procedure WMLButtonDBLCLK(var Message: TWMNCLButtonDown); message WM_LBUTTONDBLCLK;
    procedure WMRButtonDBLCLK(var Message: TWMNCRButtonDown); message WM_RBUTTONDBLCLK;
  public
    DBField: string;
    DefHeight: Integer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshData;
    procedure Localize;
    property OnHeightChanged: TNotifyEvent read FHeightChanged write FHeightChanged;
    property OnCloseEvent: TNotifyEvent read FOnCloseEvent write FOnCloseEvent;
    property lstFields: TListBox read FlstFields;
    property SplitterPos: Integer read GetSplitterPos write SetSplitterPos;
  end;

implementation

uses RM_Class, RM_Const, RM_Utils, RM_Const1;

var
  FLastDataset: string = '';

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMInsFieldsForm }

function TRMInsFieldsForm.GetSplitterPos: Integer;
begin
  Result := lstDatasets.Height;
end;

procedure TRMInsFieldsForm.SetSplitterPos(Value: Integer);
begin
  if (Value > 10) and (Value < ClientWidth - 50) then
  begin
    lstDatasets.Height := Value;
  end;
end;

constructor TRMInsFieldsForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  lstDatasets := TListBox.Create(Self);
  with lstDatasets do
  begin
    Parent := Self;
    Align := alTop;
    Height := 145;
    ItemHeight := 16;
    Style := lbOwnerDrawFixed;
    OnClick := OnlstDatasetsClick;
    OnDrawItem := OnlstDatasetsDrawItem;
  end;
  Splitter := TSplitter.Create(Self);
  with Splitter do
  begin
    Parent := Self;
    Align := alTop;
    Top := 2;
  end;
  FlstFields := TListBox.Create(Self);
  with FlstFields do
  begin
    Parent := Self;
    SetBounds(0, 147, 392, 153);
    Align := alClient;
    DragMode := dmAutomatic;
    ItemHeight := 16;
    Style := lbOwnerDrawFixed;
    OnDrawItem := OnlstDatasetsDrawItem;
    OnStartDrag := OnlstFieldsStartDrag;
  end;

  Localize;
  DefHeight := 300;

{$IFDEF USE_TB2k}
  Parent := TWinControl(AOwner);
  Floating := True;
{$ENDIF}
  FullSize := False;
  CloseButtonWhenDocked := True;
  UseLastDock := False;

  SetBounds(372, 202, 200, DefHeight);
  OnVisibleChanged := OnFormVisibleChangedEvent;
  OnClose := OnFormCloseEvent;
  OnResize := OnFormResizeEvent;
  FSaveHeight := ClientHeight;

  FFieldBmp1 := TBitmap.Create;
  FFieldBmp2 := TBitmap.Create;
  FDatasetBmp1 := TBitmap.Create;
  FDatasetBmp2 := TBitmap.Create;

  FFieldBmp1.LoadFromResourceName(HInstance, 'RM_FLD1');
  FFieldBmp2.LoadFromResourceName(HInstance, 'RM_FLD2');
  FDatasetBmp1.LoadFromResourceName(HInstance, 'RM_FLD3');
  FDatasetBmp2.LoadFromResourceName(HInstance, 'RM_FLD4');
end;

destructor TRMInsFieldsForm.Destroy;
begin
  FFieldBmp1.Free;
  FFieldBmp2.Free;
  FDatasetBmp1.Free;
  FDatasetBmp2.Free;

  inherited Destroy;
end;

procedure TRMInsFieldsForm.GetDatasets;
var
  liStringList: TStringList;
begin
  lstDatasets.Items.Clear;
  RMDesigner.Report.Dictionary.GetDataSets(lstDatasets.Items);
  FDataSetCount := lstDatasets.Items.Count;

  liStringList := TStringList.Create;
  try
    RMDesigner.Report.Dictionary.GetCategoryList(liStringList);
    liStringList.Add(RMLoadStr(SSystemVariables));
    lstDatasets.Items.AddStrings(liStringList);
  finally
    liStringList.Free;
  end;

  lstDatasets.ItemIndex := lstDatasets.Items.IndexOf(FLastDataset);
  if lstDatasets.ItemIndex < 0 then
    lstDatasets.ItemIndex := 0;
  if lstDatasets.ItemIndex >= 0 then
    OnlstDatasetsClick(nil)
  else
    lstFields.Items.Clear;
end;

procedure TRMInsFieldsForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 450);
end;

procedure TRMInsFieldsForm.OnlstDatasetsClick(Sender: TObject);
var
  i: Integer;
begin
  if lstDataSets.ItemIndex >= 0 then
  begin
    if lstDataSets.ItemIndex < FDataSetCount then
      RMDesigner.Report.Dictionary.GetDataSetFields(lstDataSets.Items[lstDataSets.ItemIndex],
        FlstFields.Items)
    else if lstDataSets.Items[lstDataSets.ItemIndex] = RMLoadStr(SSystemVariables) then
    begin
      FlstFields.Items.Clear;
      for i := 0 to RMSpecCount - 1 do
        FlstFields.Items.Add(RMLoadStr(SVar1 + i));
    end
    else
      RMDesigner.Report.Dictionary.GetVariablesList(lstDataSets.Items[lstDataSets.ItemIndex],
        FlstFields.Items);
  end
  else
    FlstFields.Items.Clear;
end;

procedure TRMInsFieldsForm.GetFieldName;
begin
  if lstDatasets.Items.Count > 0 then
    FLastDataset := lstDatasets.Items[lstDatasets.ItemIndex];

  if (lstDatasets.ItemIndex >= 0) and (FlstFields.ItemIndex >= 0) then
  begin
    if lstDatasets.ItemIndex < FDatasetCount then
    begin
      FLastDataSet := lstDatasets.Items[lstDatasets.ItemIndex];
      if Integer(FlstFields.Items.Objects[FlstFields.ItemIndex]) = 1 then
        DBField := FlstFields.Items[FlstFields.ItemIndex]
      else
      begin
        DBField := FLastDataSet + '."';
        DBField := DBField + FlstFields.Items[FlstFields.ItemIndex] + '"';
      end;
    end
    else if lstDataSets.Items[lstDataSets.ItemIndex] = RMLoadStr(SSystemVariables) then
      DBField := RMSpecFuncs[FlstFields.ItemIndex]
    else
      DBField := FlstFields.Items[FlstFields.ItemIndex];
  end;
end;

procedure TRMInsFieldsForm.RefreshData;
begin
  if not Visible then Exit;
  if lstDatasets.Items.Count > 0 then
    FLastDataset := lstDatasets.Items[lstDatasets.ItemIndex];
  GetDatasets;
end;

procedure TRMInsFieldsForm.OnlstDatasetsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: string;
  liBmp: TBitmap;
begin
  with TListBox(Control) do
  begin
    s := Items[Index];
    if Control = lstDatasets then
    begin
      if Index < FDatasetCount then
        liBmp := FDataSetBMP1
      else
        liBmp := FDataSetBMP2
    end
    else
    begin
      if lstDatasets.ItemIndex < FDatasetCount then
        liBmp := FFieldBMP1
      else
        liBmp := FFieldBMP2;
    end;

    Canvas.FillRect(aRect);
    Canvas.BrushCopy(
      Bounds(aRect.Left + 2, aRect.Top, liBmp.Width, liBmp.Height),
      liBmp,
      Bounds(0, 0, liBmp.Width, liBmp.Height),
      liBmp.TransparentColor);
    Canvas.TextOut(aRect.Left + 4 + liBmp.Width, aRect.Top, s);
  end;
end;

procedure TRMInsFieldsForm.OnlstFieldsStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  GetFieldName;
end;

procedure TRMInsFieldsForm.OnFormVisibleChangedEvent(Sender: TObject);
begin
  if Visible then
  begin
    RefreshData;
  end
  else
  begin
  end;
end;

procedure TRMInsFieldsForm.OnFormCloseEvent(Sender: TObject);
begin
  if Assigned(FOnCloseEvent) then
    FOnCloseEvent(Self);

  GetFieldName;
  if RMDesigner.Visible then
    RMDesigner.SetFocus;
end;

procedure TRMInsFieldsForm.OnFormResizeEvent(Sender: TObject);
begin
  FSaveHeight := ClientHeight;
end;

procedure TRMInsFieldsForm.WMLButtonDBLCLK(var Message: TWMNCLButtonDown);
var
  liSaveHeight: Integer;
begin
  if ClientHeight > 0 then
  begin
    liSaveHeight := ClientHeight;
    ClientHeight := 0;
    FSaveHeight := liSaveHeight;
  end
  else
    ClientHeight := FSaveHeight;
end;

procedure TRMInsFieldsForm.WMRButtonDBLCLK(var Message: TWMNCRButtonDown);
var
  liSaveHeight: Integer;
begin
  if ClientHeight > 0 then
  begin
    liSaveHeight := ClientHeight;
    ClientHeight := 0;
    FSaveHeight := liSaveHeight;
  end
  else
    ClientHeight := FSaveHeight;
end;

end.

