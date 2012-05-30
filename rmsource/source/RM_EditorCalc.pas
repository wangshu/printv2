
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{          CalcMemoView Editor            }
{                                         }
{*****************************************}

unit RM_EditorCalc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, RM_Class, Buttons;

type
  TRMCalcMemoEditorForm = class(TRMObjEditorForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    rdgType: TRadioGroup;
    lstGroups: TListBox;
    chkResetAfterPrint: TCheckBox;
    Label2: TLabel;
    chkCalcNoVisible: TCheckBox;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    edtFilter: TEdit;
    btnExpr: TSpeedButton;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    Edit2: TEdit;
    SpeedButton2: TSpeedButton;
    Label5: TLabel;
    cmbGroupBands: TComboBox;
    procedure btnExprClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rdgTypeClick(Sender: TObject);
  private
    { Private declarations }
    FView: TRMView;
    function GetGroupBand: string;
    procedure SetGroupBand(const Value: string);
    function GetResetGroupName: string;
    procedure SetResetGroupName(const Value: string);

    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
    property GroupBand: string read GetGroupBand write SetGroupBand;
    property ResetGroupName: string read GetResetGroupName write SetResetGroupName;
  end;

implementation

uses RM_Const, RM_Utils, RM_EditorExpr;

{$R *.DFM}

type
  THackPage = class(TRMCustomPage)
  end;

function TRMCalcMemoEditorForm.ShowEditor(View: TRMView): TModalResult;
var
  i: Integer;
  t: TRMView;
  liList: TList;

  procedure _FillGroups;
  var
    j: integer;
    t: TRMView;
    lStr: string;
    lPage: THackPage;
  begin
    lstGroups.Items.Add(RMLoadStr(SNotAssigned));
//    for i := 0 to RMDesigner.Report.Pages.Count - 1 do
    begin
//      liPage := THackPage(RMDesigner.Report.Pages[i]);
      lPage := THackPage(RMDesigner.Page);
      for j := 0 to lPage.Objects.Count - 1 do
      begin
        t := lPage.Objects[j];
        if t.IsBand and (TRMCustomBandView(t).BandType in [rmbtMasterData, rmbtDetailData,
        	rmbtCrossMasterData, rmbtCrossDetailData]) then
        begin
          lStr := t.Name;
          case TRMCustomBandView(t).BandType of
            rmbtMasterData, rmbtCrossMasterData: lStr := lStr + ' (Master Data)';
            rmbtDetailData, rmbtCrossDetailData: lStr := lStr + ' (Detail Data)';
          end;
          lstGroups.Items.Add(lStr);
        end;
      end;
    end;
  end;

  procedure _FillGroupHeaderBands;
  var
    j: integer;
    t: TRMView;
    liPage: THackPage;
  begin
    cmbGroupBands.Items.Add(RMLoadStr(SNotAssigned));
//    for i := 0 to RMDesigner.Report.Pages.Count - 1 do
    begin
//      liPage := THackPage(RMDesigner.Report.Pages[i]);
      liPage := THackPage(RMDesigner.Page);
      for j := 0 to liPage.Objects.Count - 1 do
      begin
        t := liPage.Objects[j];
        if t.IsBand and (TRMCustomBandView(t).BandType in [rmbtGroupHeader]) then
        begin
          cmbGroupBands.Items.Add(t.Name);
        end;
      end;
    end;
  end;

begin
	FView := View;
  _FillGroups;
  lstGroups.ItemIndex := 0;

  _FillGroupHeaderBands;
  cmbGroupBands.ItemIndex := 0;

  rdgType.ItemIndex := integer(TRMCalcMemoView(View).CalcOptions.CalcType);
  GroupBand := TRMCalcMemoView(View).CalcOptions.AggrBandName;
  ResetGroupName := TRMCalcMemoView(View).CalcOptions.ResetGroupName;
  chkResetAfterPrint.Checked := TRMCalcMemoView(View).CalcOptions.ResetAfterPrint;
  chkCalcNoVisible.Checked := TRMCalcMemoView(View).CalcOptions.CalcNoVisible;
  edtFilter.Text := TRMCalcMemoView(View).CalcOptions.Filter;
  Result := ShowModal;
  if Result = mrOK then
  begin
    RMDesigner.BeforeChange;
    liList := RMDesigner.PageObjects;
    for i := 0 to liList.Count - 1 do
    begin
      t := liList[i];
      if t.Selected and (t is TRMCalcMemoView) then
      begin
        TRMCalcMemoView(t).CalcOptions.CalcType := TRMDBCalcType(rdgType.ItemIndex);
        TRMCalcMemoView(t).CalcOptions.AggrBandName := GroupBand;
        TRMCalcMemoView(t).CalcOptions.ResetGroupName := ResetGroupName;
        TRMCalcMemoView(t).CalcOptions.ResetAfterPrint := chkResetAfterPrint.Checked;
        TRMCalcMemoView(t).CalcOptions.Filter := Trim(edtFilter.Text);
        TRMCalcMemoView(t).CalcOptions.CalcNoVisible := chkCalcNoVisible.Checked;
      end;
    end;

    RMDesigner.AfterChange;
  end;
end;

function TRMCalcMemoEditorForm.GetGroupBand: string;
var
  str: string;
begin
  Result := '';
  if lstGroups.ItemIndex > 0 then
  begin
    str := lstGroups.Items[lstGroups.ItemIndex];
    Result := Copy(str, 1, Pos(' ', str) - 1);
  end;
end;

procedure TRMCalcMemoEditorForm.SetGroupBand(const Value: string);
var
  i: integer;
  str: string;
begin
  for i := 0 to lstGroups.Items.Count - 1 do
  begin
    str := lstGroups.Items[i];
    str := Copy(str, 1, Pos(' ', str) - 1);
    if AnsiCompareText(Value, str) = 0 then
    begin
      lstGroups.ItemIndex := i;
      Break;
    end;
  end;
end;

function TRMCalcMemoEditorForm.GetResetGroupName: string;
begin
  Result := '';
  if cmbGroupBands.ItemIndex > 0 then
  begin
    Result := cmbGroupBands.Items[cmbGroupBands.ItemIndex];
  end;
end;

procedure TRMCalcMemoEditorForm.SetResetGroupName(const Value: string);
var
  lIndex: integer;
begin
  lIndex := cmbGroupBands.Items.IndexOf(Value);
  if lIndex > 0 then
    cmbGroupBands.ItemIndex := lIndex
  else
    cmbGroupBands.ItemIndex := 0;
end;

procedure TRMCalcMemoEditorForm.btnExprClick(Sender: TObject);
var
  expr: string;
begin
	if FView is TRMReportView then
	  expr := RMDesigner.InsertExpression(TRMReportView(FView))
  else
	  expr := RMDesigner.InsertExpression(nil);

  if expr <> '' then
  begin
    case TWinControl(Sender).Tag of
      0: edtFilter.Text := expr;
      1: Edit1.Text := expr;
      2: Edit2.Text := expr;
    end;
  end;
end;

procedure TRMCalcMemoEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMCalcMemoEditorForm.Localize;
var
  i: Integer;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 770);
  RMSetStrProp(rdgType, 'Caption', rmRes + 771);
  rdgType.Items.Clear;
  for i := 0 to 4 do
    rdgType.Items.Add(RMLoadStr(rmRes + 772 + i));
  rdgType.Items.Add(RMLoadStr(rmRes + 768));
  RMSetStrProp(Label1, 'Caption', rmRes + 777);
  RMSetStrProp(Label2, 'Caption', rmRes + 778);
  RMSetStrProp(chkResetAfterPrint, 'Caption', rmRes + 779);
  RMSetStrProp(chkCalcNoVisible, 'Caption', rmRes + 769);
  RMSetStrProp(btnExpr, 'Hint', rmRes + 656);
  RMSetStrProp(Label3, 'Caption', rmRes + 767);
  RMSetStrProp(Label4, 'Caption', rmRes + 766);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 765);
  RMSetStrProp(Label5, 'Caption', rmRes + 764);

  btnOK.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMCalcMemoEditorForm.rdgTypeClick(Sender: TObject);
begin
  RMSetControlsEnable(GroupBox2, rdgType.ItemIndex = 5);
end;

end.

