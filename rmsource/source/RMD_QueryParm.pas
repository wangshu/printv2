
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{            Params editor                }
{                                         }
{*****************************************}

unit RMD_QueryParm;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, RMD_DBWrap, RM_Const, ExtCtrls, Buttons;

type
  TRMDParamsForm = class(TForm)
    GroupBox1: TGroupBox;
    Label2: TLabel;
    lstParams: TListBox;
    cmbType: TComboBox;
    rdbValue: TRadioButton;
    rbdAssignFromMaster: TRadioButton;
    btnOK: TButton;
    Label1: TLabel;
    edtValue: TEdit;
    Panel1: TPanel;
    btnExpr: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure lstParamsClick(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure rbdAssignFromMasterClick(Sender: TObject);
    procedure btnExprClick(Sender: TObject);
    procedure edtValueExit(Sender: TObject);
    procedure rdbValueClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FBusy: Boolean;
    function CurParam: Integer;
    procedure Localize;
  public
    { Public declarations }
    Query: TRMDQuery;
  end;

implementation

uses RM_Class, RM_Utils;

{$R *.DFM}

type
	THackRMQuery = class(TRMDQuery)
  end;

procedure TRMDParamsForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 3110);
  RMSetStrProp(Label2, 'Caption', rmRes + 3111);
  RMSetStrProp(Label1, 'Caption', rmRes + 3112);
  RMSetStrProp(rdbValue, 'Caption', rmRes + 3113);
  RMSetStrProp(rbdAssignFromMaster, 'Caption', rmRes + 3115);
  RMSetStrProp(btnExpr, 'Hint', rmRes + 575);

  btnOK.Caption := RMLoadStr(SOk);
end;

function TRMDParamsForm.CurParam: Integer;
begin
  Result := Query.ParamIndex(lstParams.Items[lstParams.ItemIndex]);
end;

procedure TRMDParamsForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Query.ParamCount - 1 do
    lstParams.Items.Add(Query.ParamName[i]);
  for i := 0 to 10 do
    cmbType.Items.Add(RMLoadStr(SParamType1 + i));
  lstParams.ItemIndex := 0;
  lstParamsClick(nil);
end;

procedure TRMDParamsForm.lstParamsClick(Sender: TObject);
var
  i: Integer;
begin
  cmbType.ItemIndex := -1;
  for i := 0 to 10 do
  begin
    if Query.ParamType[CurParam] = RMParamTypes[i] then
    begin
      cmbType.ItemIndex := i;
      break;
    end;
  end;

  FBusy := True;
  edtValue.Text := '';
  edtValue.Enabled := False;
  if Query.ParamKind[CurParam] = rmpkValue then
  begin
    edtValue.Text := Query.ParamText[CurParam];
    edtValue.Enabled := True;
    rdbValue.Checked := True;
  end
  else
    rbdAssignFromMaster.Checked := True;
  FBusy := False;
end;

procedure TRMDParamsForm.cmbTypeChange(Sender: TObject);
begin
  Query.ParamType[CurParam] := RMParamTypes[cmbType.ItemIndex];
  if edtValue.Enabled then
    edtValueExit(nil);
end;

procedure TRMDParamsForm.rbdAssignFromMasterClick(Sender: TObject);
begin
  if FBusy then Exit;
  edtValue.Text := '';
  edtValue.Enabled := False;
  Query.ParamKind[CurParam] := rmpkAssignFromMaster;
end;

procedure TRMDParamsForm.btnExprClick(Sender: TObject);
begin
  edtValue.Text := RMDesigner.InsertExpression(nil);
end;

procedure TRMDParamsForm.edtValueExit(Sender: TObject);
begin
  Query.ParamText[CurParam] := edtValue.Text;
end;

procedure TRMDParamsForm.rdbValueClick(Sender: TObject);
begin
  if FBusy then Exit;
  edtValue.Enabled := True;
  Query.ParamKind[CurParam] := rmpkValue;
end;

procedure TRMDParamsForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
	if edtValue.Enabled then edtValueExit(nil);
end;

procedure TRMDParamsForm.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.

