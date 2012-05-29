unit frm_about_Unit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
      Buttons, ExtCtrls;

type
      TAboutBox = class(TForm)
            Panel1: TPanel;
            ProgramIcon: TImage;
            ProductName: TLabel;
            Version: TLabel;
            Copyright: TLabel;
            Comments: TLabel;
            OKButton: TButton;
            Label1: TLabel;
            edt_sn: TEdit;
            procedure FormCreate(Sender: TObject);
      private
    { Private declarations }
      public
    { Public declarations }
      end;

var
      AboutBox: TAboutBox;

implementation

uses
      Comm_Unit;

{$R *.dfm}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
      edt_sn.Text := getMD5(NBGetAdapterAddress(0));
end;

end.
