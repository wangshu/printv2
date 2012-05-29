unit RM_E_WMF;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_E_Graphic;

type
 { TRMWMFExport }
  TRMWMFExport = class(TRMGraphicExport)
  protected
    procedure InternalOnePage(aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
  end;

  { TRMEMFExportForm }
  TRMWMFExportForm = class(TForm)
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
{ TRMWMFExport }

constructor TRMWMFExport.Create(AOwner: TComponent);
begin
  inherited;
  FFileExtension := 'wmf';
  RMRegisterExportFilter(Self, RMLoadStr(SWMFFile), '*.wmf');
end;

function TRMWMFExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else
    with TRMWMFExportForm.Create(nil) do
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

procedure TRMWMFExport.InternalOnePage(aPage: TRMEndPage);
var
	liEMF: TMetafile;
	liEMFCanvas: TMetafileCanvas;
begin
	liEMF := TMetafile.Create;
	try
		liEMF.Enhanced := False;
		liEMF.Transparent := False;
		liEMF.Width :=  FPageWidth;
		liEMF.Height := FPageHeight;
	 	liEMFCanvas := TMetafileCanvas.Create(liEMF, 0);
		aPage.Draw(ParentReport, liEMFCanvas, Rect(0, 0, FPageWidth, FPageHeight));
		liEMFCanvas.Free;
		liEMF.SaveToStream(ExportStream);
	finally
		liEMF.Free;
	end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMEMFExportForm }

procedure TRMWMFExportForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1809);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);

  btnCancel.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMWMFExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

