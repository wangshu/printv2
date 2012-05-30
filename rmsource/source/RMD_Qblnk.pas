
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{      Query Builder Link Options         }
{                                         }
{*****************************************}

unit RMD_Qblnk;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TRMDFormQBLink = class(TForm)
    RadioOpt: TRadioGroup;
    RadioType: TRadioGroup;
    BtnOk: TButton;
    BtnCancel: TButton;
    txtTable1: TStaticText;
    txtTable2: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtCol1: TStaticText;
    Label4: TLabel;
    txtCol2: TStaticText;
    procedure FormCreate(Sender: TObject);
  private
  	procedure Localize;
  end;

implementation

uses RM_Const, RM_Utils;

{$R *.DFM}

procedure TRMDFormQBLink.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDFormQBLink.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.
