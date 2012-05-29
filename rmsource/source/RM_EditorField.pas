
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{               Fields list               }
{                                         }
{*****************************************}

unit RM_EditorField;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TRMFieldsForm = class(TForm)
    lstFields: TListBox;
    lstDatasets: TListBox;
    btnOK: TButton;
    btnCancel: TButton;
    chkUseTableName: TCheckBox;
    procedure lstFieldsDblClick(Sender: TObject);
    procedure lstDatasetsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstDatasetsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FDataSetBMP, FDataSetBMP1, FFieldBMP, FFieldBMP1: TBitmap;
    FDataSetCount: Integer;
    FDBFieldOnly: Boolean;

    procedure Localize;
  public
    { Public declarations }
    SelectedField: string;

    property DBFieldOnly: Boolean read FDBFieldOnly write FDBFieldOnly;
  end;

implementation

{$R *.DFM}

uses
  Registry, RM_Class, RM_Const, RM_Const1, RM_DataSet, RM_Utils, RM_Designer;

procedure TRMFieldsForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 450);
  RMSetStrProp(chkUseTableName, 'Caption', rmRes + 722);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMFieldsForm.lstDatasetsClick(Sender: TObject);
var
  i: Integer;
begin
  if lstDataSets.ItemIndex >= 0 then
  begin
    if lstDataSets.ItemIndex < FDataSetCount then
      RMDesigner.Report.Dictionary.GetDataSetFields(lstDataSets.Items[lstDataSets.ItemIndex],
        lstFields.Items)
    else if lstDataSets.Items[lstDataSets.ItemIndex] = RMLoadStr(SSystemVariables) then
    begin
      lstFields.Items.Clear;
      for i := 0 to RMSpecCount - 1 do
        lstFields.Items.Add(RMLoadStr(SVar1 + i));
      for i := 0 to RMVariables.Count - 1 do
        lstFields.Items.Add(RMVariables.Name[i]);
    end
    else
      RMDesigner.Report.Dictionary.GetVariablesList(lstDataSets.Items[lstDataSets.ItemIndex],
        lstFields.Items);
  end
  else
    lstFields.Items.Clear;
end;

procedure TRMFieldsForm.FormShow(Sender: TObject);

  procedure _GetDataSets;
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
  end;

begin
  _GetDataSets;
  lstDataSets.ItemIndex := lstDataSets.Items.IndexOf(RM_Dsg_LastDataSet);
  if lstDataSets.ItemIndex < 0 then lstDataSets.ItemIndex := 0;
  lstDatasetsClick(nil);
end;

procedure TRMFieldsForm.lstFieldsDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TRMFieldsForm.FormCreate(Sender: TObject);
begin
  FDataSetBMP := TBitmap.Create;
  FDataSetBMP1 := TBitmap.Create;
  FFieldBMP := TBitmap.Create;
  FFieldBMP1 := TBitmap.Create;

  FDataSetBMP.LoadFromResourceName(hInstance, 'RM_FLD1');
  FDataSetBMP1.LoadFromResourceName(hInstance, 'RM_FLD3');
  FFieldBMP.LoadFromResourceName(hInstance, 'RM_FLD2');
  FFieldBMP1.LoadFromResourceName(hInstance, 'RM_FLD4');

  Localize;
end;

procedure TRMFieldsForm.FormDestroy(Sender: TObject);
begin
  FDataSetBMP.Free;
  FDataSetBMP1.Free;
  FFieldBMP.Free;
  FFieldBMP1.Free;
end;

procedure TRMFieldsForm.lstDatasetsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
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
        liBmp := FDataSetBMP
      else
        liBmp := FDataSetBMP1
    end
    else
    begin
      if lstDatasets.ItemIndex < FDatasetCount then
        liBmp := FFieldBMP
      else
        liBmp := FFieldBMP1;
    end;

    Canvas.FillRect(Rect);
    Canvas.BrushCopy(
      Bounds(Rect.Left + 2, Rect.Top, liBmp.Width, liBmp.Height),
      liBmp,
      Bounds(0, 0, liBmp.Width, liBmp.Height),
      liBmp.TransparentColor);
    Canvas.TextOut(Rect.Left + 4 + liBmp.Width, Rect.Top, s);
  end;
end;

procedure TRMFieldsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if (lstDatasets.ItemIndex >= 0) and (lstFields.ItemIndex >= 0) then
    begin
      if lstDatasets.ItemIndex < FDatasetCount then
      begin
      	FDBFieldOnly := True;
        RM_Dsg_LastDataSet := lstDatasets.Items[lstDatasets.ItemIndex];
        if Integer(lstFields.Items.Objects[lstFields.ItemIndex]) = 1 then
          SelectedField := lstFields.Items[lstFields.ItemIndex]
        else
        begin
          if chkUseTableName.Checked then
            SelectedField := RM_Dsg_LastDataSet + '."'
          else
            SelectedField := '"';
          SelectedField := SelectedField + lstFields.Items[lstFields.ItemIndex] + '"';
        end;
      end
      else if lstDataSets.Items[lstDataSets.ItemIndex] = RMLoadStr(SSystemVariables) then
      begin
      	FDBFieldOnly := False;
        if lstFields.ItemIndex < RMSpecCount then
          SelectedField := RMSpecFuncs[lstFields.ItemIndex]
        else
          SelectedField := lstFields.Items[lstFields.ItemIndex];
      end
      else
        SelectedField := lstFields.Items[lstFields.ItemIndex];
    end;
  end;
end;

end.

