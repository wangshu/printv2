
{******************************************}
{                                          }
{           Report Machine v2.0            }
{           Search text dialog             }
{                                          }
{******************************************}

unit RM_DlgFind;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Const;

type
  TRMPreviewSearchForm = class(TForm)
    Label1: TLabel;
    edtSearchTxt: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    chkCaseSensitive: TCheckBox;
    GroupBox2: TGroupBox;
    rdbFromFirst: TRadioButton;
    rdbFromCursor: TRadioButton;
    chkWholewords: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses RM_Common, RM_Utils;
{$R *.DFM}

procedure TRMPreviewSearchForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 000);
  RMSetStrProp(Label1, 'Caption', rmRes + 001);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 002);
  RMSetStrProp(chkCaseSensitive, 'Caption', rmRes + 003);
  RMSetStrProp(chkWholewords, 'Caption', rmRes + 377);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 004);
  RMSetStrProp(rdbFromFirst, 'Caption', rmRes + 005);
  RMSetStrProp(rdbFromCursor, 'Caption', rmRes + 006);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMPreviewSearchForm.FormShow(Sender: TObject);
begin
  edtSearchTxt.SetFocus;
  edtSearchTxt.SelectAll;
end;

procedure TRMPreviewSearchForm.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.

