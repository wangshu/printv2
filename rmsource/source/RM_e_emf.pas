unit RM_e_emf;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_E_Graphic;

type
 { TRMEMFExport }
  TRMEMFExport = class(TRMGraphicExport)
  protected
    procedure InternalOnePage(aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
  end;

  { TRMEMFExportForm }
  TRMEMFExportForm = class(TForm)
    gbBMP: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edScaleX: TEdit;
    Label3: TLabel;
    edScaleY: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    procedure Localize;
  protected
  public
  end;

implementation

uses RM_Common, RM_Const, RM_Utils;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMEMFExport}

constructor TRMEMFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFileExtension := 'emf';
  RMRegisterExportFilter(Self, RMLoadStr(SEMFFile), '*.emf');
end;

function TRMEMFExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else
  begin
    with TRMEMFExportForm.Create(nil) do
    begin
      try
        edScaleX.Text := FloatToStr(Self.ScaleX);
        edScaleY.Text := FloatToStr(Self.ScaleY);
        Result := ShowModal;
        if Result = mrOK then
        begin
          Self.ScaleX := StrToFloat(edScaleX.Text);
          Self.ScaleY := StrToFloat(edScaleY.Text);
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TRMEMFExport.InternalOnePage(aPage: TRMEndPage);
var
  EMF: TMetafile;
  EMFCanvas: TMetafileCanvas;
  R: TRect;
begin
  EMF := TMetafile.Create;
  R := Rect(0, 0, FPageWidth + 1, FPageHeight + 1);
  try
    EMF.Enhanced := True;
    EMF.Transparent := False;
    EMF.Width := FPageWidth;
    EMF.Height := FPageHeight;
    EMFCanvas := TMetafileCanvas.Create(EMF, 0);

    EMFCanvas.Brush.Color := clWhite;
    EMFCanvas.Brush.Style := bsSolid;
    EMFCanvas.FillRect(R);

		DrawbkPicture(EMFCanvas);
    aPage.Draw(ParentReport, EMFCanvas, Rect(0, 0, FPageWidth, FPageHeight));
    EMFCanvas.Free;
    EMF.SaveToStream(ExportStream);
  finally
    EMF.Free;
  end;
  inherited OnEndPage;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMEMFExportForm}

procedure TRMEMFExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1809);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);

  btnCancel.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMEMFExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

