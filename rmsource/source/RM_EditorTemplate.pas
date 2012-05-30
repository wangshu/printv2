
{*****************************************}
{                                         }
{            Report Machine v2.0          }
{            New Template form            }
{                                         }
{*****************************************}

unit RM_EditorTemplate;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, RM_Const, RM_Common;

type
  TRMTemplNewForm = class(TForm)
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    Image1: TImage;
    btnOpenBMPFile: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    Label1: TLabel;
    procedure btnOpenBMPFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses RM_Utils;

{$R *.DFM}

procedure TRMTemplNewForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 320);
  RMSetStrProp(Label1, 'Caption', rmRes + 321);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 322);
  RMSetStrProp(btnOpenBMPFile, 'Caption', rmRes + 323);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMTemplNewForm.btnOpenBMPFileClick(Sender: TObject);
begin
  OpenDialog1.Filter := RMLoadStr(SBMPFile) + ' (*.bmp)|*.bmp';
  with OpenDialog1 do
  begin
    if Execute then
      Image1.Picture.LoadFromFile(FileName);
  end;
end;

procedure TRMTemplNewForm.FormCreate(Sender: TObject);
begin
	Localize;
end;

procedure TRMTemplNewForm.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Image1.Picture.Assign(nil);
  Memo1.SetFocus;
end;

end.

 