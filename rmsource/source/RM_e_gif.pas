unit RM_e_gif;

interface

{$I RM.INC}

{$IFDEF RXGIF}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_E_Graphic, JvGIF;

type
 { TRMGIFExport }
  TRMGIFExport = class(TRMGraphicExport)
  private
    FMonochrome: Boolean;
		FPixelFormat: TPixelFormat;
  protected
    procedure InternalOnePage(aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
  published
    property Monochrome: Boolean read FMonochrome write FMonochrome default False;
    property PixelFormat: TPixelFormat read FPixelFormat write FPixelFormat default pf24bit;
  end;

  { TRMGIFExportForm }
  TRMGIFExportForm = class(TForm)
    gbGIF: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    chkMonochrome: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    edScaleX: TEdit;
    Label3: TLabel;
    edScaleY: TEdit;
    Label4: TLabel;
    cmbPixelFormat: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure Localize;
  protected
  public
  end;
{$ENDIF}

implementation

{$IFDEF RXGIF}
uses RM_Common, RM_Const, RM_Utils;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMGIFExport}

constructor TRMGIFExport.Create(AOwner: TComponent);
begin
  inherited;
  FMonochrome := False;
  FFileExtension := 'gif';
  RMRegisterExportFilter(Self, RMLoadStr(SGIFFile), '*.gif');
end;

function TRMGIFExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else
  begin
    with TRMGIFExportForm.Create(nil) do
    begin
      try
        edScaleX.Text := FloatToStr(Self.ScaleX);
        edScaleY.Text := FloatToStr(Self.ScaleY);
        chkMonochrome.Checked := Self.Monochrome;
        Result := ShowModal;
        if Result = mrOK then
        begin
          Self.ScaleX := StrToFloat(edScaleX.Text);
          Self.ScaleY := StrToFloat(edScaleY.Text);
          Self.Monochrome := chkMonochrome.Checked;
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TRMGIFExport.InternalOnePage(aPage: TRMEndPage);
var
  lGIF: TGraphic;
  lBMP: TBitmap;
begin
  lGIF := TJvGIFImage.Create;
  try
    lBMP := TBitmap.Create;
    lBMP.Width := FPageWidth;
    lBMP.Height := FPageHeight;
    lBMP.Monochrome := FMonochrome;
    lBmp.PixelFormat := FPixelFormat;
		DrawbkPicture(lBmp.Canvas);
    aPage.Draw(ParentReport, lBMP.Canvas, Rect(0, 0, FPageWidth, FPageHeight));
    lGIF.Assign(lBMP);
    lGIF.SaveToStream(ExportStream);
    lBMP.Free;
  finally
    lGIF.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMGIFExportForm}

procedure TRMGIFExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1790);
  RMSetStrProp(chkMonochrome, 'Caption', rmRes + 1808);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);
  RMSetStrProp(Label4, 'Caption', rmRes + 1788);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMGIFExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;
{$ENDIF}
end.

