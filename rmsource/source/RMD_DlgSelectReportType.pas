unit RMD_DlgSelectReportType;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TRMDSelectReportTypeForm = class(TForm)
    GroupBox1: TGroupBox;
    lstReportType: TListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses
  RM_Const, RM_Const1, RM_Utils;

procedure TRMDSelectReportTypeForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 3169);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 3169);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDSelectReportTypeForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMDSelectReportTypeForm.FormShow(Sender: TObject);
begin
  lstReportType.ItemIndex := 0;
end;

end.
