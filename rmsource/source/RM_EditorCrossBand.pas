
{******************************************}
{                                          }
{             Report Machine v2.0          }
{     Select Band datasource dialog        }
{                                          }
{******************************************}

unit RM_EditorCrossBand;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, RM_Class;

type
  TRMVBandEditorForm = class(TRMObjEditorForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    edtNum: TEdit;
    lstBands: TListBox;
    lstDatasets: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure lstBandsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstDatasetsClick(Sender: TObject);
    procedure lstDatasetsExit(Sender: TObject);
    procedure lstDatasetsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FBands: TList;
    FSaveDataSets: TStringList;
    FDataSetBMP, FBandBMP: TBitmap;
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
  end;

implementation

{$R *.DFM}

uses RM_Const, RM_Utils;

type
  THackPage = class(TRMCustomPage)
  end;

procedure TRMVBandEditorForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 485);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 486);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 487);
  RMSetStrProp(Label1, 'Caption', rmRes + 488);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMVBandEditorForm.ShowEditor(View: TRMView): TModalResult;
var
  i: Integer;

  procedure _GetBands;
  var
    i: Integer;
    t: TRMView;
  begin
    lstBands.Items.Clear;
    FBands.Clear;
    with THackPage(RMDesigner.Page) do
    begin
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        if t.IsBand and (TRMCustomBandView(t).BandType in [rmbtHeader, rmbtFooter,
          rmbtGroupHeader, rmbtGroupFooter, rmbtMasterData, rmbtDetailData]) then
        begin
          lstBands.Items.Add(t.Name + ': ' + RMBandNames[TRMCustomBandView(t).BandType]);
          FBands.Add(t);
          FSaveDataSets.Add(TRMCustomBandView(t).CrossDataSetName);
        end;
      end;
    end;
  end;

  procedure _GetDataSets;
  begin
    lstDatasets.Items.Clear;
    RMDesigner.Report.Dictionary.GetDataSets(lstDatasets.Items);
    lstDatasets.Items.Insert(0, RMLoadStr(SVirtualDataset));
    lstDatasets.Items.Insert(0, RMLoadStr(SNotAssigned));
  end;

begin
  _GetBands;
  _GetDataSets;

  lstBands.ItemIndex := 0;
  lstBandsClick(nil);

  Result := ShowModal;
  if Result = mrOK then
  begin
    lstDatasetsExit(nil);
    RMDesigner.BeforeChange;
    for i := 0 to FBands.Count - 1 do
      TRMCustomBandView(FBands[i]).CrossDataSetName := FSaveDataSets[i];
  end;
end;

procedure TRMVBandEditorForm.FormCreate(Sender: TObject);
begin
  FBands := TList.Create;
  FSaveDataSets := TStringList.Create;

  FDataSetBMP := TBitmap.Create;
  FDataSetBMP.LoadFromResourceName(hInstance, 'RM_BMPDATASET');

  FBandBMP := TBitmap.Create;
  FBandBMP.LoadFromResourceName(hInstance, 'RM_BMPBAND');

  Localize;
end;

procedure TRMVBandEditorForm.lstBandsClick(Sender: TObject);
var
  liIndex: Integer;
begin
  liIndex := lstBands.ItemIndex;
  if liIndex >= 0 then
  begin
    if (FSaveDataSets[liIndex] <> '') and (FSaveDataSets[liIndex][1] in ['0'..'9']) then
    begin
      edtNum.Text := FSaveDataSets[liIndex];
      lstDatasets.ItemIndex := 1;
    end
    else
    begin
      lstDatasets.ItemIndex := lstDatasets.Items.IndexOf(FSaveDataSets[liIndex]);
      if lstDatasets.ItemIndex < 0 then lstDataSets.ItemIndex := 0;
    end;
    lstDataSetsClick(nil);
  end;
end;

procedure TRMVBandEditorForm.FormDestroy(Sender: TObject);
begin
  FDataSetBMP.Free;
  FBandBMP.Free;
  FBands.Free;
  FSaveDataSets.Free;
end;

procedure TRMVBandEditorForm.lstDatasetsClick(Sender: TObject);
begin
  RMEnableControls([Label1, edtNum], lstDatasets.ItemIndex = 1);
end;

procedure TRMVBandEditorForm.lstDatasetsExit(Sender: TObject);
begin
  if lstBands.ItemIndex >= 0 then
  begin
    case lstDatasets.ItemIndex of
      0: FSaveDataSets[lstBands.ItemIndex] := '';
      1: FSaveDataSets[lstBands.ItemIndex] := edtNum.Text;
    else
      FSaveDataSets[lstBands.ItemIndex] := lstDatasets.Items[lstDatasets.ItemIndex];
    end;
  end;
end;

procedure TRMVBandEditorForm.lstDatasetsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  liBmp: TBitmap;
begin
  TListBox(Control).Canvas.FillRect(Rect);
  if Control = lstBands then
  begin
    liBmp := FBandBMP;
    s := lstBands.Items[Index];
  end
  else
  begin
    liBmp := FDataSetBMP;
    s := lstDatasets.Items[Index];
  end;

  if (Control = lstBands) or (Index > 0) then
    TListBox(Control).Canvas.BrushCopy(Bounds(Rect.Left + 2, Rect.Top, liBmp.Width, liBmp.Height),
      liBmp, Bounds(0, 0, liBmp.Width, liBmp.Height), liBmp.TransparentColor);
      
  TListBox(Control).Canvas.TextOut(Rect.Left + 4 + liBmp.Width, Rect.Top, s);
end;

end.

