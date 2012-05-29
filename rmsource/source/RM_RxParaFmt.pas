unit RM_RxParaFmt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TRMParaFormatDlg = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    IndentBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Alignment: TRadioGroup;
    SpacingBox: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtSpaceBefore: TEdit;
    edtSpaceAfter: TEdit;
    edtLineSpacing: TEdit;
    edtLeftIndent: TEdit;
    edtRightIndent: TEdit;
    edtFirstIndent: TEdit;
    UpDownSpaceBefore: TUpDown;
    UpDownSpaceAfter: TUpDown;
    UpDownLineSpacing: TUpDown;
    UpDownLeftIndent: TUpDown;
    UpDownRightIndent: TUpDown;
    UpDownFirstIndent: TUpDown;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses RM_Utils, RM_Const1, RM_Const;

procedure TRMParaFormatDlg.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(IndentBox, 'Caption', rmRes + 840);
  RMSetStrProp(Label1, 'Caption', rmRes + 841);
  RMSetStrProp(Label2, 'Caption', rmRes + 842);
  RMSetStrProp(Label3, 'Caption', rmRes + 843);
  RMSetStrProp(Alignment, 'Caption', rmRes + 844);
  Alignment.Items.Clear;
  Alignment.Items.Add(RMLoadStr(rmRes + 845));
  Alignment.Items.Add(RMLoadStr(rmRes + 846));
  Alignment.Items.Add(RMLoadStr(rmRes + 847));
  RMSetStrProp(SpacingBox, 'Caption', rmRes + 848);
  RMSetStrProp(Label4, 'Caption', rmRes + 849);
  RMSetStrProp(Label5, 'Caption', rmRes + 850);
  RMSetStrProp(Label6, 'Caption', rmRes + 851);

  RMSetStrProp(Self, 'Caption', rmRes + 853);
  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMParaFormatDlg.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.
