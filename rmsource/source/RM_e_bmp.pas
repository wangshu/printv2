unit RM_e_bmp;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RM_Class, RM_E_Graphic;

type

 { TRMBMPExport }
  TRMBMPExport = class(TRMGraphicExport)
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

  { TRMBMPExportForm }
  TRMBMPExportForm = class(TForm)
    gbBMP: TGroupBox;
    chkMonochrome: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edScaleX: TEdit;
    Label3: TLabel;
    edScaleY: TEdit;
    Label4: TLabel;
    cmbPixelFormat: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
  protected
    procedure Localize;
  public
  end;

implementation

{$R *.DFM}

uses RM_Common, RM_Const, RM_Utils;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMBMPExport}

constructor TRMBMPExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMonochrome := False;
  FPixelFormat := pf24bit;
  FFileExtension := 'bmp';
  RMRegisterExportFilter(Self, RMLoadStr(SBMPFile), '*.bmp');
end;

function TRMBMPExport.ShowModal: Word;
var
  tmp: TRMBMPExportForm;
begin
  if not ShowDialog then
    Result := mrOk
  else
  begin
    tmp := TRMBMPExportForm.Create(nil);
    try
      tmp.edScaleX.Text := FloatToStr(Self.ScaleX);
      tmp.edScaleY.Text := FloatToStr(Self.ScaleY);
      tmp.chkMonochrome.Checked := Self.Monochrome;
      tmp.cmbPixelFormat.ItemIndex := Integer(Self.PixelFormat);
      Result := tmp.ShowModal;
      if Result = mrOK then
      begin
        Self.ScaleX := StrToFloat(tmp.edScaleX.Text);
        Self.ScaleY := StrToFloat(tmp.edScaleY.Text);
        Self.Monochrome := tmp.chkMonochrome.Checked;
        Self.PixelFormat := TPixelFormat(tmp.cmbPixelFormat.ItemIndex);
      end;
    finally
      tmp.Free;
    end;
  end;
end;

procedure TRMBMPExport.InternalOnePage(aPage: TRMEndPage);
var
  liBitmap: TBitmap;
begin
  liBitmap := TBitmap.Create;
  try
    liBitmap.Width := FPageWidth;
    liBitmap.Height := FPageHeight;
    liBitmap.Monochrome := FMonochrome;
    liBitmap.PixelFormat := FPixelFormat;
    DrawbkPicture(liBitmap.Canvas);
    aPage.Draw(ParentReport, liBitmap.Canvas, Rect(0, 0, FPageWidth, FPageHeight));
    liBitmap.SaveToStream(ExportStream);
  finally
    liBitmap.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMBMPExportForm}

procedure TRMBMPExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1807);
  RMSetStrProp(chkMonochrome, 'Caption', rmRes + 1808);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);
  RMSetStrProp(Label4, 'Caption', rmRes + 1788);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMBMPExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

