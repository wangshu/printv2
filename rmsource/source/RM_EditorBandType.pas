
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{           Select Band dialog            }
{                                         }
{*****************************************}

unit RM_EditorBandType;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, RM_Class, RM_Const;

type
  TRMBandTypesForm = class(TForm)
    btnOK: TButton;
    grbBands: TGroupBox;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure bClick(Sender: TObject);
    procedure bDblClick(Sender: TObject);
    procedure Localize;
  public
    { Public declarations }
    SelectedTyp: TRMBandType;
    IsSubreport: Boolean;
  end;

implementation

uses RM_Designer, RM_Utils;

{$R *.DFM}

procedure TRMBandTypesForm.FormShow(Sender: TObject);
var
  lWidth: Integer;

  function _FindMaxLen: Integer;
  var
    lBandType: TRMBandType;
  begin
    Result := 0;
    for lBandType := rmbtReportTitle to rmbtNone do
    begin
      if Canvas.TextWidth(RMBandNames[lBandType]) > Result then
        Result := Canvas.TextWidth(RMBandNames[lBandType]);
    end;

    Result := Result;
  end;

  procedure _SetButtons(aIsCrossBand: Boolean; aParent: TGroupBox);
	var
	  i, j: Integer;
  	lFirstFlag: Boolean;
	  lButton: TRadioButton;
  begin
	  lFirstFlag := True; j := 0;
    for i := Ord(rmbtReportTitle) to Ord(rmbtNone) - 1 do
    begin
    	if aIsCrossBand and (not (TRMBandType(i) in [rmbtCrossHeader..rmbtCrossChild])) then Continue;
      if (not aIsCrossBand) and (TRMBandType(i) in [rmbtCrossHeader..rmbtCrossChild]) then Continue;

      lButton := TRadioButton.Create(aParent);
      lButton.Parent := aParent;
      lButton.Left := lWidth * (j div 6) + 12 + 30 * (j div 6);
      lButton.Top := (j mod 6) * 20 + 20;

      lButton.Width := Canvas.TextWidth(RMBandNames[TRMBandType(i)]) + 20;
      lButton.Tag := i;
      lButton.Caption := RMBandNames[TRMBandType(i)];
      lButton.OnClick := bClick;
      lButton.OnDblClick := bDblClick;
      lButton.Enabled := (TRMBandType(i) in [rmbtHeader, rmbtFooter, rmbtMasterData, rmbtDetailData,
        rmbtGroupHeader, rmbtGroupFooter, rmbtChild, rmbtCrossHeader..rmbtCrossChild]) or
        (not TRMDesignerForm(RMDesigner).RMCheckBand(TRMBandType(i)));
      if IsSubreport and (TRMBandType(i) in
        [rmbtReportTitle, rmbtReportSummary, rmbtPageHeader, rmbtPageFooter,
       {rmbtGroupHeader, rmbtGroupFooter,}rmbtColumnHeader, rmbtColumnFooter]) then
        lButton.Enabled := False;

      if (not aIsCrossBand) and lButton.Enabled and lFirstFlag then
      begin
        lButton.Checked := True;
        SelectedTyp := TRMBandType(i);
        lFirstFlag := False;
      end;

      Inc(j);
    end;
  end;

begin
  Localize;

  lWidth := _FindMaxLen;
  grbBands.ClientWidth := lWidth * 3 + 12 + 30 * 3;
  GroupBox1.ClientWidth := grbBands.ClientWidth;
  ClientWidth := grbBands.Width + grbBands.Left * 3;
  _SetButtons(False, grbBands);
  _SetButtons(True, GroupBox1);

  btnOK.Left := ClientWidth - btnOK.Width - btnCancel.Width - 10;
  btnCancel.Left := ClientWidth - btnOK.Width - 5;
end;

procedure TRMBandTypesForm.bClick(Sender: TObject);
begin
  SelectedTyp := TRMBandType((Sender as TComponent).Tag);
end;

procedure TRMBandTypesForm.bDblClick(Sender: TObject);
begin
  btnOK.Click;
end;

procedure TRMBandTypesForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 510);
  RMSetStrProp(grbBands, 'Caption', rmRes + 511);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 512);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

end.

