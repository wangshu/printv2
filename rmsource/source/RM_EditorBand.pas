
{*****************************************}
{                                         }
{            Report Machine v2.0          }
{     Select Band datasource dialog       }
{                                         }
{*****************************************}

unit RM_EditorBand;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, RM_Class, RM_Ctrls;

type
  TRMBandEditorForm = class(TRMObjEditorForm)
    btnOK: TButton;
    btnCancel: TButton;
    GB1: TGroupBox;
    Label2: TLabel;
    lstDatasets: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure lstDatasetsClick(Sender: TObject);
    procedure lstDatasetsDblClick(Sender: TObject);
    procedure lstDatasetsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FBitmap: TBitmap;
    FEdtNum: TRMSpinEdit;

    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(t: TRMView): TModalResult; override;
  end;

implementation

{$R *.DFM}

uses RM_Const, RM_Utils, RM_Designer;

type
  THackView = class(TRMView)
  end;

function TRMBandEditorForm.ShowEditor(t: TRMView): TModalResult;

  procedure _GetDataSets;
  begin
    lstDatasets.Items.Clear;
    RMDesigner.Report.Dictionary.GetDataSets(lstDatasets.Items);
    lstDatasets.Items.Insert(0, RMLoadStr(SVirtualDataset));
    lstDatasets.Items.Insert(0, RMLoadStr(SNotAssigned));
  end;

begin
  _GetDataSets;
  if TRMBandMasterData(t).IsVirtualDataSet then
  begin
    FEdtNum.Text := TRMBandMasterData(t).DataSetName;
    lstDatasets.ItemIndex := 1;
  end
  else
    lstDatasets.ItemIndex := lstDatasets.Items.IndexOf(TRMBandMasterData(t).DataSetName);

  lstDatasetsClick(nil);
  if lstDatasets.ItemIndex < 0 then lstDatasets.ItemIndex := 0;

  Result := ShowModal;
  if Result = mrOK then
  begin
    RMDesigner.BeforeChange;
    case lstDatasets.ItemIndex of
      0: TRMBandMasterData(t).DataSetName := '';
      1: TRMBandMasterData(t).DataSetName := FEdtNum.Text;
    else
      TRMBandMasterData(t).DataSetName := lstDatasets.Items[lstDatasets.ItemIndex];
    end;

    if not TRMBandMasterData(t).IsVirtualDataSet then
	    RM_Dsg_LastDataSet := TRMBandMasterData(t).DataSetName;
  end;
end;

procedure TRMBandEditorForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 480);
  RMSetStrProp(Label2, 'Caption', rmRes + 482);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMBandEditorForm.FormCreate(Sender: TObject);
begin
  FBitmap := TBitmap.Create;
  FBitmap.LoadFromResourceName(hInstance, 'RM_BMPDATASET');

  FEdtNum := TRMSpinEdit.Create(Self);
  FEdtNum.Parent := Self;
  FEdtNum.Text := '1';
  FEdtNum.SetBounds(252, 182, 72, 21);

  Localize;
end;

procedure TRMBandEditorForm.lstDatasetsClick(Sender: TObject);
begin
  RMEnableControls([Label2, FEdtNum], lstDatasets.ItemIndex = 1);
end;

procedure TRMBandEditorForm.lstDatasetsDblClick(Sender: TObject);
begin
  btnOk.Click;
end;

procedure TRMBandEditorForm.lstDatasetsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
begin
  s := lstDatasets.Items[Index];
  lstDatasets.Canvas.FillRect(Rect);
  if Index > 0 then
    lstDatasets.Canvas.BrushCopy(Bounds(Rect.Left + 2, Rect.Top, FBitmap.Width, FBitmap.Height),
      FBitmap, Bounds(0, 0, FBitmap.Width, FBitmap.Height), FBitmap.TransparentColor);
  lstDatasets.Canvas.TextOut(Rect.Left + 4 + FBitmap.Width, Rect.Top, s);
end;

procedure TRMBandEditorForm.FormDestroy(Sender: TObject);
begin
  FBitmap.Free;
end;

end.

