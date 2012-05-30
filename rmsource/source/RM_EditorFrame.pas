unit RM_EditorFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, RM_Class, RM_Common, RM_Ctrls;

type
  TRMFormFrameProp = class(TRMObjEditorForm)
    GroupBox2: TGroupBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    GroupBox1: TGroupBox;
    EDLeftStyle: TComboBox;
    CBLeftVisible: TCheckBox;
    CBTopVisible: TCheckBox;
    CBRightVisible: TCheckBox;
    CBBottomVisible: TCheckBox;
    EDBottomStyle: TComboBox;
    EDRightStyle: TComboBox;
    EDTopStyle: TComboBox;
    chkDoubleLeft: TCheckBox;
    chkDoubleTop: TCheckBox;
    chkDoubleRight: TCheckBox;
    chkDoubleBottom: TCheckBox;
    procedure EDLeftStyleDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FBtnLeft: TRMSpinEdit;
    FBtnRight: TRMSpinEdit;
    FBtnTop: TRMSpinEdit;
    FBtnBottom: TRMSpinEdit;

    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
  end;

implementation

uses RM_Utils, RM_Const, RM_Const1;

{$R *.DFM}

type
  THackPage = class(TRMCustomPage)
  end;

function TRMFormFrameProp.ShowEditor(View: TRMView): TModalResult;
var
  i: Integer;
  t: TRMView;
  liList: TList;

  procedure _SaveFrameProp;
  begin
    t.LeftFrame.Visible := CBLeftVisible.Checked;
    t.LeftFrame.Style := TPenStyle(EDLeftStyle.ItemIndex);
    t.LeftFrame.mmWidth := RMToMMThousandths(FBtnLeft.Value, rmutScreenPixels);
    t.LeftFrame.DoubleFrame := chkDoubleLeft.Checked;

    t.TopFrame.Visible := CBTopVisible.Checked;
    t.TopFrame.Style := TPenStyle(EDTopStyle.ItemIndex);
    t.TopFrame.mmWidth := RMToMMThousandths(FBtnTop.Value, rmutScreenPixels);
    t.TopFrame.DoubleFrame := chkDoubleTop.Checked;

    t.RightFrame.Visible := CBRightVisible.Checked;
    t.RightFrame.Style := TPenStyle(EDRightStyle.ItemIndex);
    t.RightFrame.mmWidth := RMToMMThousandths(FBtnRight.Value, rmutScreenPixels);
    t.RightFrame.DoubleFrame := chkDoubleRight.Checked;

    t.BottomFrame.Visible := CBBottomVisible.Checked;
    t.BottomFrame.Style := TPenStyle(EDBottomStyle.ItemIndex);
    t.BottomFrame.mmWidth := RMToMMThousandths(FBtnBottom.Value, rmutScreenPixels);
    t.BottomFrame.DoubleFrame := chkDoubleBottom.Checked;

    t.LeftRightFrame := 0;
    if SpeedButton1.Down then
      t.LeftRightFrame := 1;
    if SpeedButton2.Down then
      t.LeftRightFrame := 2;
    if SpeedButton3.Down then
      t.LeftRightFrame := 3;
    if SpeedButton4.Down then
      t.LeftRightFrame := 4;
    if SpeedButton5.Down then
      t.LeftRightFrame := 5;
    if SpeedButton6.Down then
      t.LeftRightFrame := 6;
  end;

begin
  chkDoubleLeft.Checked := View.LeftFrame.DoubleFrame;
  chkDoubleTop.Checked := View.TopFrame.DoubleFrame;
  chkDoubleRight.Checked := View.RightFrame.DoubleFrame;
  chkDoubleBottom.Checked := View.BottomFrame.DoubleFrame;

  CBLeftVisible.Checked := View.LeftFrame.Visible;
  EDLeftStyle.ItemIndex := Byte(View.LeftFrame.Style);
  FBtnLeft.Value := RMFromMMThousandths(View.LeftFrame.mmWidth, rmutScreenPixels);

  CBTopVisible.Checked := View.TopFrame.Visible;
  EDTopStyle.ItemIndex := Byte(View.TopFrame.Style);
  FBtnTop.Value := RMFromMMThousandths(View.TopFrame.mmWidth, rmutScreenPixels);

  CBRightVisible.Checked := View.RightFrame.Visible;
  EDRightStyle.ItemIndex := Byte(View.RightFrame.Style);
  FBtnRight.Value := RMFromMMThousandths(View.RightFrame.mmWidth, rmutScreenPixels);

  CBBottomVisible.Checked := View.BottomFrame.Visible;
  EDBottomStyle.ItemIndex := Byte(View.BottomFrame.Style);
  FBtnBottom.Value := RMFromMMThousandths(View.BottomFrame.mmWidth, rmutScreenPixels);

  SpeedButton1.Down := View.LeftRightFrame = 1;
  SpeedButton2.Down := View.LeftRightFrame = 2;
  SpeedButton3.Down := View.LeftRightFrame = 3;
  SpeedButton4.Down := View.LeftRightFrame = 4;
  SpeedButton5.Down := View.LeftRightFrame = 5;
  SpeedButton6.Down := View.LeftRightFrame = 6;

  Result := ShowModal;
  if Result = mrOK then
  begin
    RMDesigner.BeforeChange;
    liList := RMDesigner.PageObjects;
    for i := 0 to liList.Count - 1 do
    begin
      t := liList[i];
      if t.Selected and (not t.IsBand) then
        _SaveFrameProp;
    end;
    RMDesigner.AfterChange;
  end;
end;

procedure TRMFormFrameProp.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(CBLeftVisible, 'Caption', rmRes + 796);
  RMSetStrProp(CBTopVisible, 'Caption', rmRes + 797);
  RMSetStrProp(CBRightVisible, 'Caption', rmRes + 798);
  RMSetStrProp(CBBottomVisible, 'Caption', rmRes + 799);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 800);
  RMSetStrProp(chkDoubleLeft, 'Caption', rmRes + 864);
  RMSetStrProp(chkDoubleTop, 'Caption', rmRes + 864);
  RMSetStrProp(chkDoubleRight, 'Caption', rmRes + 864);
  RMSetStrProp(chkDoubleBottom, 'Caption', rmRes + 864);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 863);
  RMSetStrProp(Self, 'Caption', rmRes + 865);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMFormFrameProp.EDLeftStyleDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
const
  LineWidth = 4;
var
  i: integer;
begin
  with TComboBox(Control).Canvas do
  begin
    Pen.Color := clBlack;
    Pen.Style := TPenStyle(index);
    Brush.Color := clWhite;
    FillRect(Rect);

    i := Rect.Top + (Rect.Bottom - Rect.Top - LineWidth) div 2;
    for i := i to i + LineWidth - 1 do
    begin
      MoveTo(Rect.Left + 3, i);
      LineTo(Rect.Right - 3, i);
    end;
  end;
end;

procedure TRMFormFrameProp.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FBtnLeft := TRMSpinEdit.Create(Self);
  with FBtnLeft do
  begin
    Parent := GroupBox1;
    SetBounds(195, 11, 56, 21);
    ValueType := rmvtFloat;
    MinValue := 0.01;
    Increment := 0.5;
  end;
  FBtnTop := TRMSpinEdit.Create(Self);
  with FBtnTop do
  begin
    Parent := GroupBox1;
    SetBounds(195, 35, 56, 21);
    ValueType := rmvtFloat;
    MinValue := 0.01;
    Increment := 0.5;
  end;
  FBtnRight := TRMSpinEdit.Create(Self);
  with FBtnRight do
  begin
    Parent := GroupBox1;
    SetBounds(195, 59, 56, 21);
    ValueType := rmvtFloat;
    MinValue := 0.01;
    Increment := 0.5;
  end;
  FBtnBottom := TRMSpinEdit.Create(Self);
  with FBtnBottom do
  begin
    Parent := GroupBox1;
    SetBounds(195, 83, 56, 21);
    ValueType := rmvtFloat;
    MinValue := 0.01;
    Increment := 0.5;
  end;


  Localize;
  for i := 0 to Integer(High(TPenStyle)) - 2 do
  begin
    EDLeftStyle.Items.Add('');
    EDTopStyle.Items.Add('');
    EDRightStyle.Items.Add('');
    EDBottomStyle.Items.Add('');
  end;
end;

end.

