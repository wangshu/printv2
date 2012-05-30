
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{       Highlight attributes dialog       }
{                                         }
{*****************************************}

unit RM_EditorHilit;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, RM_Const, ExtCtrls, RM_Class, RM_common, RM_Ctrls, RM_DsgCtrls;

type
  TRMHilightForm = class(TRMObjEditorForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    chkFontBold: TCheckBox;
    chkFontItalic: TCheckBox;
    chkFontUnderline: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    RB1: TRadioButton;
    RB2: TRadioButton;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    btnExpr: TSpeedButton;
    procedure RB1Click(Sender: TObject);
    procedure btnExprClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FView: TRMView;
    FBtnFontColor: TRMColorPickerButton;
    FBtnBackColor: TRMColorPickerButton;
    procedure OnColorChangeEvent(Sender: TObject);
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(aView: TRMView): TModalResult; override;
  end;

implementation

uses RM_Utils, RM_EditorExpr;

{$R *.DFM}

type
  THackPage = class(TRMCustomPage)
  end;

function TRMHilightForm.ShowEditor(aView: TRMView): TModalResult;
var
  i: Integer;
  t: TRMView;
  liList: TList;
begin
	FView := aView;
  FBtnFontColor.CurrentColor := TRMCustomMemoView(aView).Highlight.Font.Color;
  FBtnBackColor.CurrentColor := TRMCustomMemoView(aView).Highlight.Color;
  chkFontBold.Checked := fsBold in TRMCustomMemoView(aView).Highlight.Font.Style;
  chkFontItalic.Checked := fsItalic in TRMCustomMemoView(aView).Highlight.Font.Style;
  chkFontUnderline.Checked := fsUnderline in TRMCustomMemoView(aView).Highlight.Font.Style;
  Edit1.Text := TRMCustomMemoView(aView).Highlight.Condition;

  if FBtnBackColor.CurrentColor = clNone then
    RB1.Checked := True
  else
    RB2.Checked := True;
  RB1Click(nil);

  Result := ShowModal;
  if Result = mrOk then
  begin
    RMDesigner.BeforeChange;
    liList := RMDesigner.PageObjects;
    for i := 0 to liList.Count - 1 do
    begin
      t := liList[i];
      if t.Selected and (t is TRMCustomMemoView) then
      begin
        TRMCustomMemoView(t).Highlight.Condition := Edit1.Text;
        TRMCustomMemoView(t).Highlight.Font.Color := FBtnFontColor.CurrentColor;
        if RB1.Checked then
          TRMCustomMemoView(t).Highlight.Color := clNone
        else
          TRMCustomMemoView(t).Highlight.Color := FBtnBackColor.CurrentColor;
        if chkFontBold.Checked then
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style + [fsBold]
        else
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style - [fsBold];
        if chkFontItalic.Checked then
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style + [fsItalic]
        else
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style - [fsItalic];
        if chkFontUnderline.Checked then
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style + [fsUnderline]
        else
          TRMCustomMemoView(t).Highlight.Font.Style := TRMMemoView(t).Highlight.Font.Style - [fsUnderline];
      end;
    end;
    RMDesigner.AfterChange;
  end;
end;

procedure TRMHilightForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 520);
  RMSetStrProp(GroupBox3, 'Caption', rmRes + 521);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 522);
  RMSetStrProp(chkFontBold, 'Caption', rmRes + 524);
  RMSetStrProp(chkFontItalic, 'Caption', rmRes + 525);
  RMSetStrProp(chkFontUnderline, 'Caption', rmRes + 526);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 527);
  RMSetStrProp(RB1, 'Caption', rmRes + 529);
  RMSetStrProp(RB2, 'Caption', rmRes + 530);
  RMSetStrProp(btnExpr, 'Hint', rmRes + 061);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMHilightForm.RB1Click(Sender: TObject);
begin
  FBtnBackColor.Enabled := RB2.Checked;
end;

procedure TRMHilightForm.btnExprClick(Sender: TObject);
var
  lExpr: string;
begin
	lExpr := Edit1.Text;
  if RM_EditorExpr.RMGetExpression('', lExpr, nil, False) then
	begin
    Edit1.Text := lExpr;
  end;
end;

procedure TRMHilightForm.FormCreate(Sender: TObject);
begin
  FBtnFontColor := TRMColorPickerButton.Create(Self);
  with FBtnFontColor do
  begin
    Parent := GroupBox1;
    Flat := False;
    SetBounds(122, 48, 110, 25);
//    Caption := RMLoadStr(rmRes + 523);
    ColorType := rmptFont;
    OnColorChange := OnColorChangeEvent;
  end;
  FBtnBackColor := TRMColorPickerButton.Create(Self);
  with FBtnBackColor do
  begin
    Parent := GroupBox2;
    Flat := False;
    SetBounds(122, 32, 110, 25);
//    Caption := RMLoadStr(rmRes + 528);
    ColorType := rmptHighlight;
    OnColorChange := OnColorChangeEvent;
  end;

  Localize;
end;

procedure TRMHilightForm.OnColorChangeEvent(Sender: TObject);
begin
end;

end.

