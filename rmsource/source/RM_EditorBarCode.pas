unit RM_EditorBarCode;

interface

{$I RM.INC}
{$IFDEF TurboPower}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, RM_Class, RM_StBarC;

type
  { TRMBarCodeForm }
  TRMBarCodeForm = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    GroupBox1: TGroupBox;
    chkAddCheckChar: TCheckBox;
    chkViewText: TCheckBox;
    Label3: TLabel;
    eZoom: TEdit;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    edtCode: TEdit;
    DBBtn: TSpeedButton;
    cmbTypes: TComboBox;
    Label2: TLabel;
    Panel1: TPanel;
    chkTallGuardBars: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure DBBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtCodeChange(Sender: TObject);
    procedure cmbTypesChange(Sender: TObject);
    procedure chkAddCheckCharClick(Sender: TObject);
    procedure RB1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure eZoomExit(Sender: TObject);
    procedure eZoomKeyPress(Sender: TObject; var Key: Char);
  private
    FBarcode: TStBarCode;
    procedure ShowSample;
    procedure Localize;
  public
  	View: TRMView;
  end;

{$ENDIF}
implementation

{$R *.DFM}

{$IFDEF TurboPower}
uses RM_Const, RM_Utils, RM_BarCode;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMBarCodeForm}

procedure TRMBarCodeForm.ShowSample;
begin
  if cmbTypes.ItemIndex < 0 then Exit;

  try
    FBarCode.Code := cbDefaultText;
    FBarCode.BarCodeType := TStBarCodeType(cmbTypes.ItemIndex);
    FBarCode.AddCheckChar := chkAddCheckChar.Checked;
    FBarCode.BarToSpaceRatio := StrToFloat(eZoom.Text);
    FBarCode.ShowCode := chkViewText.Checked;
    FBarCode.TallGuardBars := chkTallGuardBars.Checked;
    if (TStBarCodeType(cmbTypes.ItemIndex) in [bcCode39, bcCode128,  bcCodabar]) or
      RMIsNumeric(edtCode.Text) then
      FBarCode.Code := edtCode.Text
    else
      FBarCode.Code := cbDefaultText;
  except
    FBarCode.Code := cbDefaultText;
  end;
end;

procedure TRMBarCodeForm.FormCreate(Sender: TObject);
begin
  FBarCode := TStBarCode.Create(Self);
  FBarCode.Parent := Panel1;
  FBarCode.Align := alClient;
  Localize;
end;

procedure TRMBarCodeForm.FormActivate(Sender: TObject);
begin
  edtCode.SetFocus;
end;

procedure TRMBarCodeForm.DBBtnClick(Sender: TObject);
var
  s: string;
begin
  s := RMDesigner.InsertExpression(View);
  if s <> '' then
    edtCode.Text := s;
end;

procedure TRMBarCodeForm.edtCodeChange(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.cmbTypesChange(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.chkAddCheckCharClick(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.RB1Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.FormShow(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.SpeedButton1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(eZoom.Text);
  Inc(i);
  eZoom.Text := IntToStr(i);
  ShowSample;
end;

procedure TRMBarCodeForm.SpeedButton2Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(eZoom.Text);
  Dec(i);
  if i <= 0 then i := 1;
  eZoom.Text := IntToStr(i);
  ShowSample;
end;

procedure TRMBarCodeForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 650);
  RMSetStrProp(Label1, 'Caption', rmRes + 651);
  RMSetStrProp(Label2, 'Caption', rmRes + 652);
  RMSetStrProp(Label3, 'Caption', rmRes + 659);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 653);
  RMSetStrProp(chkAddCheckChar, 'Caption', rmRes + 654);
  RMSetStrProp(chkViewText, 'Caption', rmRes + 655);
  RMSetStrProp(DBBtn, 'Hint', rmRes + 656);

  btnOk.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMBarCodeForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    try
      ShowSample;
    except
      MessageBox(0, PChar(RMLoadStr(SBarcodeError)), PChar(RMLoadStr(SError)),
        mb_Ok + mb_IconError);
      CanClose := False;
    end;
  end;
end;

procedure TRMBarCodeForm.eZoomExit(Sender: TObject);
begin
  ShowSample;
end;

procedure TRMBarCodeForm.eZoomKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ShowSample;
end;

initialization
{$ENDIF}
end.

