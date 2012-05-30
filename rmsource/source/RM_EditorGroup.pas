
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{            Group band editor            }
{                                         }
{*****************************************}

unit RM_EditorGroup;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_Const, ExtCtrls, Buttons;

type
  TRMGroupEditorForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    GB1: TGroupBox;
    Edit1: TEdit;
    btnExpr: TSpeedButton;
    GroupBox1: TGroupBox;
    chkKeepFooter: TCheckBox;
    chkKeepTogether: TCheckBox;
    chkNewPageAfter: TCheckBox;
    chkOutline: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExprClick(Sender: TObject);
  private
    { Private declarations }
    FView: TRMView;
    procedure Localize;
  public
    { Public declarations }
    procedure ShowEditor(View: TRMView);
  end;

implementation

uses RM_Utils, RM_EditorExpr;

{$R *.DFM}

procedure TRMGroupEditorForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  GB1.Caption := RMLoadStr(rmRes + 491);
  btnExpr.Hint := RMLoadStr(rmRes + 492);

	RMSetStrProp(GroupBox1, 'Caption', rmRes + 873);
	RMSetStrProp(chkKeepFooter, 'Caption', rmRes + 884);
	RMSetStrProp(chkKeepTogether, 'Caption', rmRes + 883);
	RMSetStrProp(chkNewPageAfter, 'Caption', SFormNewPage);
	RMSetStrProp(chkOutline, 'Caption', rmRes + 493);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
  Caption := RMLoadStr(rmRes + 491{490});
end;

procedure TRMGroupEditorForm.ShowEditor(View: TRMView);
begin
	FView := View;
  Edit1.Text := TRMBandGroupHeader(View).GroupCondition;
  chkKeepFooter.Checked := TRMBandGroupHeader(View).KeepFooter;
  chkKeepTogether.Checked := TRMBandGroupHeader(View).KeepTogether;
  chkNewPageAfter.Checked := TRMBandGroupHeader(View).NewPageAfter;
  chkOutline.Checked := TRMBandGroupHeader(View).OutlineText <> '';
  if ShowModal = mrOk then
  begin
    RMDesigner.BeforeChange;
    TRMBandGroupHeader(View).GroupCondition := Edit1.Text;
    TRMBandGroupHeader(View).KeepFooter := chkKeepFooter.Checked;
    TRMBandGroupHeader(View).KeepTogether := chkKeepTogether.Checked;
    TRMBandGroupHeader(View).NewPageAfter := chkNewPageAfter.Checked;
    if chkOutline.Checked then
  	  TRMBandGroupHeader(View).OutlineText := Edit1.Text
    else
	    TRMBandGroupHeader(View).OutlineText := '';
  end;
end;

procedure TRMGroupEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMGroupEditorForm.FormShow(Sender: TObject);
begin
  Edit1.SelectAll;
end;

procedure TRMGroupEditorForm.btnExprClick(Sender: TObject);
var
  lExpr: string;
begin
	lExpr := Edit1.Text;
  if RM_EditorExpr.RMGetExpression('', lExpr, nil, False) then
	begin
    Edit1.Text := lExpr;
  end;
end;

end.

