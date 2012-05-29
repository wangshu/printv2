unit RM_EditorCellWidth;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Common, RM_Ctrls, RM_Class;

type
  TRMEditCellWidthForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    RB6: TRadioButton;
    RB7: TRadioButton;
    RB8: TRadioButton;
    RB9: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RB6Click(Sender: TObject);
  private
    { Private declarations }
    FOldUnitType: TRMUnitType;
    FmmOldValue: Integer;
    FBusy: Boolean;

    procedure Localize;
    function GetUnitType: TRMUnitType;
    procedure SetUnitType(Value: TRMUnitType);
    procedure OnbtnCountChangeEvent(Sender: TObject);
  public
    { Public declarations }
    btnCount: TRMSpinEdit;
    property UnitType: TRMUnitType read GetUnitType write SetUnitType;
  end;

implementation

{$R *.DFM}

uses RM_Utils, RM_Const, RM_Const1;

procedure TRMEditCellWidthForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(GroupBox3, 'Caption', rmRes + 284);
  RMSetStrProp(RB6, 'Caption', rmRes + 294);
  RMSetStrProp(RB7, 'Caption', rmRes + 296);
  RMSetStrProp(RB8, 'Caption', rmRes + 295);
  RMSetStrProp(RB9, 'Caption', rmRes + 315);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMEditCellWidthForm.GetUnitType: TRMUnitType;
begin
  if RB6.Checked then
    Result := rmutScreenPixels
  else if RB7.Checked then
    Result := rmutInches
  else if RB8.Checked then
    Result := rmutMillimeters
  else
    Result := rmutMMThousandths;
end;

procedure TRMEditCellWidthForm.SetUnitType(Value: TRMUnitType);
begin
  FOldUnitType := Value;
  if Value = rmutScreenPixels then
    RB6.Checked := True
  else if Value = rmutInches then
    RB7.Checked := True
  else if Value = rmutMillimeters then
    RB8.Checked := True
  else
    RB9.Checked := True;
end;

procedure TRMEditCellWidthForm.FormCreate(Sender: TObject);
begin
  btnCount := TRMSpinEdit.Create(Self);
  btnCount.OnChange := OnbtnCountChangeEvent;
  with btnCount do
  begin
    Parent := GroupBox1;
    SetBounds(80, 14, 100, 21);
    ValueType := rmvtInteger;
    MinValue := 2;
  end;

  Localize;
end;

procedure TRMEditCellWidthForm.FormShow(Sender: TObject);
begin
  GroupBox3.Visible := RB6.Enabled;
  if not GroupBox3.Visible then
    Height := 90;

  btnCount.SetFocus;
end;

procedure TRMEditCellWidthForm.RB6Click(Sender: TObject);
begin
  FBusy := True;
  try
    if RB6.Checked then
    begin
      btnCount.Decimal := 0;
      FOldUnitType := rmutScreenPixels;
      btnCount.Value := RMFromMMThousandths(FmmOldValue, rmutScreenPixels);
    end
    else if RB7.Checked then
    begin
      btnCount.Decimal := 2;
      FOldUnitType := rmutInches;
      btnCount.Value := RMFromMMThousandths(FmmOldValue, rmutInches);
    end
    else if RB8.Checked then
    begin
      btnCount.Decimal := 2;
      FOldUnitType := rmutMillimeters;
      btnCount.Value := RMFromMMThousandths(FmmOldValue, rmutMillimeters);
    end
    else
    begin
      btnCount.Decimal := 0;
      FOldUnitType := rmutMMThousandths;
      btnCount.Value := FmmOldValue;
    end;
  finally
    FBusy := False;
  end;
end;

procedure TRMEditCellWidthForm.OnbtnCountChangeEvent(Sender: TObject);
begin
  if FBusy then Exit;

  if RB6.Checked then
  begin
    FmmOldValue := RMToMMThousandths(btnCount.AsInteger, rmutScreenPixels);
  end
  else if RB7.Checked then
  begin
    FmmOldValue := RMToMMThousandths(btnCount.Value, rmutInches);
  end
  else if RB8.Checked then
  begin
    FmmOldValue := RMToMMThousandths(btnCount.Value, rmutMillimeters);
  end
  else
  begin
    FmmOldValue := btnCount.AsInteger;
  end;
end;

end.

