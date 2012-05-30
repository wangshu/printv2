unit frm_Authorization_Unit;

interface

uses
      Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
      cxContainer, cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxProgressBar,
      StdCtrls, ExtCtrls;

type
      Tfrm_Authorization = class(TForm)
            Label1: TLabel;
    Timer1: TTimer;
            procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
      private
    { Private declarations }
      public
    { Public declarations }
      end;

var
      frm_Authorization: Tfrm_Authorization;

implementation

uses frm_attribInfoUnit, webservice, Comm_Unit;

{$R *.dfm}

procedure Tfrm_Authorization.FormShow(Sender: TObject);

begin
   Timer1.Enabled:=true;
end;

procedure Tfrm_Authorization.Timer1Timer(Sender: TObject);
var
  service:WebServiceSoap;
begin
     service:=GetWebServiceSoap() ;
  try
    if service.CheckOpen(getMD5(NBGetAdapterAddress(0))) then
    begin

      Application.ProcessMessages;
      ModalResult := mrOk;
      end
      else
      begin
        ModalResult := mrCancel;
      end;
   except
        ModalResult := mrCancel;
   end;
end;

end.
