unit frm_Authorization_Unit;

interface

uses
      Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
      cxContainer, cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxProgressBar,
      StdCtrls;

type
      Tfrm_Authorization = class(TForm)
            cxProgressBar1: TcxProgressBar;
            Label1: TLabel;
            procedure FormShow(Sender: TObject);
            procedure FormClick(Sender: TObject);
      private
    { Private declarations }
      public
    { Public declarations }
      end;

var
      frm_Authorization: Tfrm_Authorization;

implementation

{$R *.dfm}

procedure Tfrm_Authorization.FormShow(Sender: TObject);
begin
      Application.ProcessMessages;
      ModalResult := mrOk;
end;

procedure Tfrm_Authorization.FormClick(Sender: TObject);
begin
      close;
end;

end.
