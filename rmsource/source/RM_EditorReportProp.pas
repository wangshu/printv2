unit RM_EditorReportProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Common, RM_Class;

type
  TRMReportProperty = class(TForm)
    GroupBox1: TGroupBox;
    lblTitle: TLabel;
    lblAuthor: TLabel;
    lblCompany: TLabel;
    lblCopyRight: TLabel;
    lblComment: TLabel;
    edtTitle: TEdit;
    edtAuthor: TEdit;
    edtCompany: TEdit;
    edtCopyRight: TEdit;
    memComment: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    ReportInfo: TRMReportInfo;
  end;

implementation

{$R *.DFM}

uses RM_Utils, RM_Const, RM_Const1;

procedure TRMReportProperty.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 820);
  RMSetStrProp(lblTitle, 'Caption', rmRes + 372);
  RMSetStrProp(lblAuthor, 'Caption', rmRes + 816);
  RMSetStrProp(lblCompany, 'Caption', rmRes + 817);
  RMSetStrProp(lblCopyRight, 'Caption', rmRes + 818);
  RMSetStrProp(lblComment, 'Caption', rmRes + 819);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMReportProperty.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMReportProperty.FormShow(Sender: TObject);
begin
  edtTitle.Text := ReportInfo.Title;
  edtAuthor.Text := ReportInfo.Author;
  edtCompany.Text := ReportInfo.Company;
  edtCopyRight.Text := ReportInfo.CopyRight;
  memComment.Lines.Text := ReportInfo.Comment;
end;

procedure TRMReportProperty.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  if ModalResult = mrOK then
  begin
    ReportInfo.Title := edtTitle.Text;
    ReportInfo.Author := edtAuthor.Text;
    ReportInfo.Company := edtCompany.Text;
    ReportInfo.CopyRight := edtCopyRight.Text;
    ReportInfo.Comment := memComment.Lines.Text;
  end;
end;

end.

