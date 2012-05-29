unit RM_e_Jpeg;

interface

{$I RM.INC}

{$IFDEF JPEG}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_E_Graphic, JPEG, ComCtrls;

type
 { TRMJPEGExport }
  TRMJPEGExport = class(TRMGraphicExport)
  private
    FGrayscale: Boolean;
    FProgressiveEncoding: Boolean;
    FQuality: TJPEGQualityRange;
    FPixelFormat: TPixelFormat;
  protected
    procedure InternalOnePage(aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
  published
    property Grayscale: Boolean read FGrayscale write FGrayscale default False;
    property ProgressiveEncoding: Boolean read FProgressiveEncoding write FProgressiveEncoding default True;
    property Quality: TJPEGQualityRange read FQuality write FQuality default High(TJPEGQualityRange);
    property PixelFormat: TPixelFormat read FPixelFormat write FPixelFormat default pf24bit;
  end;

  { TRMJPEGExportForm }
  TRMJPEGExportForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    gbJPEG: TGroupBox;
    lblQuality: TLabel;
    chkGrayscale: TCheckBox;
    chkProgressiveEncoding: TCheckBox;
    edQuality: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edScaleX: TEdit;
    Label3: TLabel;
    edScaleY: TEdit;
    UpDown1: TUpDown;
    Label4: TLabel;
    cmbPixelFormat: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure edQualityKeyPress(Sender: TObject; var Key: Char);
  private
    procedure Localize;
  protected
  public
  end;

{$ENDIF}
implementation

{$IFDEF JPEG}
uses RM_Common, RM_Const, RM_Utils;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMJPEGExport}

constructor TRMJPEGExport.Create(AOwner: TComponent);
begin
  inherited;
  FGrayscale := False;
  FPixelFormat := pf24bit;
  FProgressiveEncoding := True;
  FQuality := High(TJPEGQualityRange);
  FFileExtension := 'jpg';
  RMRegisterExportFilter(Self, RMLoadStr(SJPEGFile), '*.jpg');
end;

function TRMJPEGExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else
  begin
    with TRMJPEGExportForm.Create(nil) do
    begin
      try
        edScaleX.Text := FloatToStr(Self.ScaleX);
        edScaleY.Text := FloatToStr(Self.ScaleY);
        chkGrayscale.Checked := Self.Grayscale;
        chkProgressiveEncoding.Checked := Self.ProgressiveEncoding;
				UpDown1.Position := Self.Quality;
        cmbPixelFormat.ItemIndex := Integer(Self.PixelFormat);
        Result := ShowModal;
        if Result = mrOK then
        begin
          Self.ScaleX := StrToFloat(edScaleX.Text);
          Self.ScaleY := StrToFloat(edScaleY.Text);
          Self.Grayscale := chkGrayscale.Checked;
          Self.ProgressiveEncoding := chkProgressiveEncoding.Checked;
          Self.Quality := StrToInt(edQuality.Text);
          Self.PixelFormat := TPixelFormat(cmbPixelFormat.ItemIndex);
        end;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TRMJPEGExport.InternalOnePage(aPage: TRMEndPage);
var
  liJPEG: TJPEGImage;
  liBMP: TBitMap;
begin
  liJPEG := TJPEGImage.Create;
  liBMP := nil;
  try
    liJPEG.Grayscale := FGrayscale;
    liJPEG.ProgressiveEncoding := FProgressiveEncoding;
    liJPEG.CompressionQuality := FQuality;
    liBMP := TBitmap.Create;
    liBMP.Width := FPageWidth;
    liBMP.Height := FPageHeight;
    liBmp.PixelFormat := FPixelFormat;
		DrawbkPicture(liBmp.Canvas);
    aPage.Draw(ParentReport, liBMP.Canvas, Rect(0, 0, FPageWidth, FPageHeight));
    liJPEG.Assign(liBMP);
    liJPEG.SaveToStream(ExportStream);
  finally
    liBMP.Free;
    liJPEG.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMJPEGExportForm}

procedure TRMJPEGExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1789);
  RMSetStrProp(chkGrayscale, 'Caption', rmRes + 1812);
  RMSetStrProp(chkProgressiveEncoding, 'Caption', rmRes + 1813);
  RMSetStrProp(lblQuality, 'Caption', rmRes + 1814);
  RMSetStrProp(lblQuality, 'Hint', rmRes + 1815);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);
  RMSetStrProp(Label4, 'Caption', rmRes + 1788);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMJPEGExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMJPEGExportForm.edQualityKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;
{$ENDIF}
end.

