unit RM_EditorGridCols;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Ctrls;

type
  TRMGetGridColumnsForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    RowCountButton: TRMSpinEdit;
    ColCountButton: TRMSpinEdit;
  end;

implementation

{$R *.DFM}

uses RM_Utils, RM_Const, RM_Const1;

procedure TRMGetGridColumnsForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Label2, 'Caption', rmRes + 690);
  RMSetStrProp(Label1, 'Caption', rmRes + 691);
  RMSetStrProp(Self, 'Caption', rmRes + 693);
  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMGetGridColumnsForm.FormCreate(Sender: TObject);
begin
  RowCountButton := TRMSpinEdit.Create(Self);
  with RowCountButton do
  begin
    Parent := GroupBox1;
    SetBounds(83, 12, 121, 21);
    ValueType := rmvtInteger;
    MinValue := 2;
  end;

  ColCountButton := TRMSpinEdit.Create(Self);
  with ColCountButton do
  begin
    Parent := GroupBox1;
    SetBounds(83, 36, 121, 21);
    ValueType := rmvtInteger;
    MinValue := 2;
  end;

  Localize;
end;

procedure TRMGetGridColumnsForm.FormShow(Sender: TObject);
begin
  RowCountButton.SetFocus;
end;

end.
