unit RM_EditorConfirmReplace;

{$I RM.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TRMConfirmReplaceDialog = class(TForm)
    btnReplace: TButton;
    lblConfirmation: TLabel;
    btnSkip: TButton;
    btnCancel: TButton;
    btnReplaceAll: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
    procedure PrepareShow(AEditorRect: TRect; X, Y1, Y2: integer;
      AReplaceText: string);
  end;

var
  RMConfirmReplaceDialog: TRMConfirmReplaceDialog;

implementation

{$R *.DFM}

resourcestring
  SAskReplaceText = 'Replace this occurence of "%s"?';

{ TConfirmReplaceDialog }

procedure TRMConfirmReplaceDialog.FormCreate(Sender: TObject);
begin
  Image1.Picture.Icon.Handle := LoadIcon(0, IDI_QUESTION);
end;

procedure TRMConfirmReplaceDialog.PrepareShow(AEditorRect: TRect;
  X, Y1, Y2: integer; AReplaceText: string);
var
  nW, nH: integer;
begin
  lblConfirmation.Caption := Format(SAskReplaceText, [AReplaceText]);
  nW := AEditorRect.Right - AEditorRect.Left;
  nH := AEditorRect.Bottom - AEditorRect.Top;

  if nW <= Width then
    X := AEditorRect.Left - (Width - nW) div 2
  else begin
    if X + Width > AEditorRect.Right then
      X := AEditorRect.Right - Width;
  end;
  if Y2 > AEditorRect.Top + MulDiv(nH, 2, 3) then
    Y2 := Y1 - Height - 4
  else
    Inc(Y2, 4);
  SetBounds(X, Y2, Width, Height);
end;

procedure TRMConfirmReplaceDialog.FormDestroy(Sender: TObject);
begin
  RMConfirmReplaceDialog := nil;
end;

initialization

finalization
  FreeAndNil(RMConfirmReplaceDialog);

end.

