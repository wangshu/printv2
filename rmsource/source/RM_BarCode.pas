{-----------------------------------------------------------------------------
 Unit Name: RM_barC2
 Author:    lz
 Email:     SinMax@163.net
 此代码献给所有喜欢编码的朋友，和我的最爱的huang xiao。
-----------------------------------------------------------------------------}

unit RM_BarCode;

interface

{$I RM.INC}

{$IFDEF TurboPower}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Math, StdCtrls, RM_Class, Buttons, ExtCtrls, ComCtrls,
  RM_Common, RM_Ctrls, RM_DsgCtrls
  , RM_StBarC, RM_St2DBarC //SysTools 4.0 incold
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  cbDefaultText = '12345678';

type

  TRMBarCodeAngleType = (rmatNone, rmat90, rmat180, rmat270);

  TRMBarCodeObject = class(TComponent) // fake component
  end;

  TRMBarCodeInfo = class(TPersistent)
  private
    FBarCode: TStBarCode;
    FRotationType: TRMBarCodeAngleType;

    function GetBarTextFont: TFont;
    procedure SetBarTextFont(Value: TFont);
    function GetAddCheckChar: Boolean;
    procedure SetAddCheckChar(Value: Boolean);
    function GetBarCodeType: TStBarCodeType;
    procedure SetBarCodeType(Value: TStBarCodeType);
    function GetBarColor: TColor;
    procedure SetBarColor(Value: TColor);
    function GetTallGuardBars: Boolean;
    procedure SetTallGuardBars(Value: Boolean);
    function GetSupplementalCode: string;
    procedure SetSupplementalCode(Value: string);
    function GetShowGuardChars: Boolean;
    procedure SetShowGuardChars(Value: Boolean);
    function GetShowCode: Boolean;
    procedure SetShowCode(Value: Boolean);
    function GetExtendedSyntax: Boolean;
    procedure SetExtendedSyntax(Value: Boolean);
    function GetBearerBars: Boolean;
    procedure SetBearerBars(Value: Boolean);
    function GetCode128Subset: TStCode128CodeSubset;
    procedure SetCode128Subset(Value: TStCode128CodeSubset);
    function GetBarWidth: Double;
    procedure SetBarWidth(Value: Double);
    function GetBarNarrowToWideRatio: Integer;
    procedure SetBarNarrowToWideRatio(Value: Integer);
    function GetBarToSpaceRatio: Double;
    procedure SetBarToSpaceRatio(Value: Double);
  public
    constructor Create(aBarCode: TStBarCode);
    destructor Destroy; override;
  published
    property BarTextFont: TFont read GetBarTextFont write SetBarTextFont;
    property RotationType: TRMBarCodeAngleType read FRotationType write FRotationType;
    property AddCheckChar: Boolean read GetAddCheckChar write SetAddCheckChar;
    property BarCodeType: TStBarCodeType read GetBarCodeType write SetBarCodeType;
    property BarColor: TColor read GetBarColor write SetBarColor;
    property TallGuardBars: Boolean read GetTallGuardBars write SetTallGuardBars;
    property SupplementalCode: string read GetSupplementalCode write SetSupplementalCode;
    property ShowGuardChars: Boolean read GetShowGuardChars write SetShowGuardChars;
    property ShowCode: Boolean read GetShowCode write SetShowCode;
    property ExtendedSyntax: Boolean read GetExtendedSyntax write SetExtendedSyntax;
    property BearerBars: Boolean read GetBearerBars write SetBearerBars;
    property Code128Subset: TStCode128CodeSubset read GetCode128Subset write SetCode128Subset;
    property BarToSpaceRatio: Double read GetBarToSpaceRatio write SetBarToSpaceRatio;
    property BarNarrowToWideRatio: Integer read GetBarNarrowToWideRatio write SetBarNarrowToWideRatio;
    property BarWidth: Double read GetBarWidth write SetBarWidth;
  end;

  { TRMBarCodeView }
  TRMBarCodeView = class(TRMReportView)
  private
    FBarCode: TStBarCode;
    FBarCodeInfo: TRMBarCodeInfo;

    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
  protected
    function GetViewCommon: string; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure Draw(aCanvas: TCanvas); override;

    procedure ShowEditor; override;
  published
    property LeftFrame;
    property TopFrame;
    property RightFrame;
    property BottomFrame;
    property FillColor;
    property DataField;
    //property BarCode: TStBarCode read FBarCode;
    property DirectDraw: Boolean read GetDirectDraw write SetDirectDraw;
    property PrintFrame;
    property Printable;
    property BarCodeInfo: TRMBarCodeInfo read FBarCodeInfo write FBarCodeInfo;
    property OnPreviewClick;
    property OnPreviewClickUrl;
  end;

  TRM2DBarcodeType = (rmbtPDF417, rmbtMAXI);

  { TRM2DBarCodeView }
  TRM2DBarCodeView = class(TRMReportView)
  private
    FBarCodeType: TRM2DBarCodeType;
    FViewpdf417: TStPDF417Barcode;
    FViewMaxi: TStMaxiCodeBarcode;

    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
  protected
    function GetViewCommon: string; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure Draw(aCanvas: TCanvas); override;

    procedure ShowEditor; override;
    procedure DefinePopupMenu(aPopup: TRMCustomMenuItem); override;
  published
    property LeftFrame;
    property TopFrame;
    property RightFrame;
    property BottomFrame;
    property FillColor;
    property Memo;
    property BarCodeType: TRM2DBarCodeType read FBarCodeType write FBarCodeType;
    //    property PDF417Barcode: TStPDF417Barcode read FViewpdf417;
    property MaxiCodeBarcode: TStMaxiCodeBarcode read FViewMaxi;
    property DirectDraw: Boolean read GetDirectDraw write SetDirectDraw;
    property PrintFrame;
    property Printable;
    property OnPreviewClick;
    property OnPreviewClickUrl;
  end;

  { TRMBar2CodeForm }
  TRM2DBarCodeForm = class(TForm)
    SaveDialog1: TSaveDialog;
    Panel3: TPanel;
    DBBtn: TSpeedButton;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    edtCode: TMemo;
    Choos2DType: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    cmbMaxiMode: TComboBox;
    Label10: TLabel;
    Edit2: TEdit;
    Edit4: TEdit;
    Label12: TLabel;
    Label11: TLabel;
    Edit3: TEdit;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label8: TLabel;
    GroupBox3: TGroupBox;
    Label6: TLabel;
    Label9: TLabel;
    CheckBox2: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox2: TComboBox;
    ComboBox4: TComboBox;
    Edit1: TEdit;
    Edit5: TEdit;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DBBtnClick(Sender: TObject);
    procedure SpinEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpinEdit2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinEdit3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBox2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure barcolorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure backgroundColorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnOKKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCancelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit4KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit4KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Choos2DTypeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure edtCodeChange(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox5KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinEdit1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure cmbMaxiModeChange(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton2Click(Sender: TObject);
    procedure RB1Click(Sender: TObject);
    procedure rb2Click(Sender: TObject);
    procedure rb3Click(Sender: TObject);
  private
    { Private declarations }
    FView: TRMView;
    FPDF417: TStPDF417Barcode;
    FMaxi: TStMaxiCodeBarcode;
    FSpinEdit1, FSpinEdit2, FSpinEdit3: TRMSpinEdit;
    FBusy: Boolean;
    function Check2BarCode(S: ansistring): Boolean;
    procedure Localize;
    procedure ShowSample;
  public
    { Public declarations }
  end;

  {$ENDIF}
implementation

{$R *.dfm}

{$IFDEF TurboPower}

uses RM_Const, RM_Utils, RM_EditorBarCode;

const
  flBarcodeDirectDraw = $2;

procedure RotateWmf(AWmf, DestWmf: TMetaFile; const Angle: Double);
var
  d1, d2, d3, d4, d5, d6: Double;
  pXf: XFORM;
  liMetafile: TMetafile;
  liMetafileCanvas: TMetafileCanvas;
  R: TRect;

  function _CalAngle(PointX, PointY: Double): Double;
  var
    d1, d2, d3: Double;
  begin
    d1 := -PointX;
    d2 := -PointY;
    if d1 <> 0 then
    begin
      d3 := ArcTan(Abs(d2 / d1)) * 180 / PI;
      if (d2 > 0) and (d1 < 0) then
        d3 := 180 - d3
      else if (d2 <= 0) and (d1 < 0) then
        d3 := d3 + 180
      else if (d2 < 0) and (d1 > 0) then
        d3 := 360 - d3;
    end
    else
    begin
      if d2 > 0 then
        d3 := 90
      else if D2 < 0 then
        d3 := 270
      else
        d3 := -1;
    end;
    Result := d3;
  end;

begin
  if not Assigned(AWmf) or (Angle = 0) then
    Exit;
  if (AWmf.Width = 0) or (AWmf.Height = 0) then
    Exit;

  with pXf do
  begin
    d3 := -Angle * PI / 180;
    d1 := COS(d3);
    d2 := SIN(d3);

    eM11 := d1;
    eM12 := d2;
    eM21 := -d2;
    eM22 := d1;

    d4 := AWmf.Width / 2;
    d5 := AWmf.Height / 2;

    d3 := _CalAngle(d4, d5) - Angle;
    d3 := -d3 * PI / 180;

    d6 := sqrt(d4 * d4 + d5 * d5);
    d1 := COS(d3) * d6 + d4;
    d2 := -SIN(d3) * d6 + d5;

    eDx := d1;
    eDy := d2;
  end;

  liMetafile := TMetafile.Create;
  try
    R := Rect(0, 0, AWmf.Width, AWmf.Height);
    liMetafile.Width := AWmf.Width;
    liMetafile.Height := AWmf.Height;

    liMetafileCanvas := TMetafileCanvas.Create(liMetafile, 0);
    try
      SetGraphicsMode(AWmf.Handle, GM_COMPATIBLE);
      SetGraphicsMode(liMetafileCanvas.Handle, GM_ADVANCED);
      SetWorldTransform(liMetafileCanvas.Handle, pXf);
      PlayEnhMetaFile(liMetafileCanvas.Handle, AWmf.Handle, R);
    finally
      liMetafileCanvas.Free;
    end;

    DestWmf.Clear;
    DestWmf.Assign(liMetafile);
  finally
    liMetafile.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBarCodeInfo }

constructor TRMBarCodeInfo.Create(aBarCode: TStBarCode);
begin
  inherited Create;

  FRotationType := rmatNone;
  FBarCode := aBarCode;
end;

destructor TRMBarCodeInfo.Destroy;
begin
  inherited;
end;

function TRMBarCodeInfo.GetBarTextFont: TFont;
begin
  Result := FBarCode.Font;
end;

procedure TRMBarCodeInfo.SetBarTextFont(Value: TFont);
begin
  FBarCode.Font.Assign(Value);
end;

function TRMBarCodeInfo.GetAddCheckChar: Boolean;
begin
  Result := FBarCode.AddCheckChar;
end;

procedure TRMBarCodeInfo.SetAddCheckChar(Value: Boolean);
begin
  FBarCode.AddCheckChar := Value;
end;

function TRMBarCodeInfo.GetBarCodeType: TStBarCodeType;
begin
  Result := FBarCode.BarCodeType;
end;

procedure TRMBarCodeInfo.SetBarCodeType(Value: TStBarCodeType);
begin
  FBarCode.BarCodeType := Value;
end;

function TRMBarCodeInfo.GetBarColor: TColor;
begin
  Result := FBarCode.BarColor;
end;

procedure TRMBarCodeInfo.SetBarColor(Value: TColor);
begin
  FBarCode.BarColor := Value;
end;

function TRMBarCodeInfo.GetTallGuardBars: Boolean;
begin
  Result := FBarCode.TallGuardBars;
end;

procedure TRMBarCodeInfo.SetTallGuardBars(Value: Boolean);
begin
  FBarCode.TallGuardBars := Value;
end;

function TRMBarCodeInfo.GetSupplementalCode: string;
begin
  Result := FBarCode.SupplementalCode;
end;

procedure TRMBarCodeInfo.SetSupplementalCode(Value: string);
begin
  FBarCode.SupplementalCode := Value;
end;

function TRMBarCodeInfo.GetShowGuardChars: Boolean;
begin
  Result := FBarCode.ShowGuardChars;
end;

procedure TRMBarCodeInfo.SetShowGuardChars(Value: Boolean);
begin
  FBarCode.ShowGuardChars := Value;
end;

function TRMBarCodeInfo.GetShowCode: Boolean;
begin
  Result := FBarCode.ShowCode;
end;

procedure TRMBarCodeInfo.SetShowCode(Value: Boolean);
begin
  FBarCode.ShowCode := Value;
end;

function TRMBarCodeInfo.GetExtendedSyntax: Boolean;
begin
  Result := FBarCode.ExtendedSyntax;
end;

procedure TRMBarCodeInfo.SetExtendedSyntax(Value: Boolean);
begin
  FBarCode.ExtendedSyntax := Value;
end;

function TRMBarCodeInfo.GetBearerBars: Boolean;
begin
  Result := FBarCode.BearerBars;
end;

procedure TRMBarCodeInfo.SetBearerBars(Value: Boolean);
begin
  FBarCode.BearerBars := Value;
end;

function TRMBarCodeInfo.GetCode128Subset: TStCode128CodeSubset;
begin
  Result := FBarCode.Code128Subset;
end;

procedure TRMBarCodeInfo.SetCode128Subset(Value: TStCode128CodeSubset);
begin
  FBarCode.Code128Subset := Value;
end;

function TRMBarCodeInfo.GetBarWidth: Double;
begin
  Result := FBarCode.BarWidth;
end;

procedure TRMBarCodeInfo.SetBarWidth(Value: Double);
begin
  FBarCode.BarWidth := Value;
end;

function TRMBarCodeInfo.GetBarNarrowToWideRatio: Integer;
begin
  Result := FBarCode.BarNarrowToWideRatio;
end;

procedure TRMBarCodeInfo.SetBarNarrowToWideRatio(Value: Integer);
begin
  FBarCode.BarNarrowToWideRatio := Value;
end;

function TRMBarCodeInfo.GetBarToSpaceRatio: Double;
begin
  Result := FBarCode.BarToSpaceRatio;
end;

procedure TRMBarCodeInfo.SetBarToSpaceRatio(Value: Double);
begin
  FBarCode.BarToSpaceRatio := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBarCodeView }

type
  THackBarCode = class(TStBarCode)
  end;

constructor TRMBarCodeView.Create;
begin
  inherited Create;
  BaseName := 'BarCode';

  FBarCode := TStBarCode.Create(nil);
  FBarCodeInfo := TRMBarCodeInfo.Create(FBarCode);
end;

destructor TRMBarCodeView.Destroy;
begin
  FreeAndNil(FBarCodeInfo);
  FreeAndNil(FBarCode);

  inherited Destroy;
end;

procedure TRMBarCodeView.Draw(aCanvas: TCanvas);
var
  liCodeStr: string;
  EMF, liEmf1: TMetafile;
  EMFCanvas: TMetafileCanvas;
begin
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);

  if (Memo1.Count > 0) and (Length(Memo1[0]) > 0) and
    ((FBarCode.BarCodeType in [bcCode39, bcCode128, bcCodabar]) or RMisNumeric(Memo1[0])) then
    liCodeStr := Trim(Memo1[0])
  else
    liCodeStr := '';//cbDefaultText;   // 不显示空字符

  try
    FBarCode.Code := liCodeStr;
  except
    FBarCode.Code := cbDefaultText;
  end;

  EMF := TMetafile.Create;
  EMF.Width := spWidth;
  EMF.Height := spHeight;
  EMFCanvas := TMetafileCanvas.Create(EMF, 0);
  FBarCode.PaintToCanvas(EMFCanvas, Rect(0, 0, spWidth, spHeight));

  EMFCanvas.Free;

  CalcGaps;

  liEmf1 := nil;
  ShowBackground;
  IntersectClipRect(aCanvas.Handle, RealRect.Left, RealRect.Top, RealRect.Right, RealRect.Bottom);
  try
    case FBarCodeInfo.RotationType of
      rmatNone:
        begin
          RMPrintGraphic(aCanvas, RealRect, emf, IsPrinting, DirectDraw, False);
          //          aCanvas.StretchDraw(RealRect, EMF);
        end;
      rmat90:
        begin
          liEMF1 := TMetafile.Create;
          liEMF1.Width := spWidth;
          liEMF1.Height := spHeight;
          RotateWmf(emf, liEmf1, 90);
          RMPrintGraphic(aCanvas, RealRect, liEmf1, IsPrinting, DirectDraw, False);
          aCanvas.StretchDraw(RealRect, liEmf1);
        end;
      rmat180:
        begin
          liEMF1 := TMetafile.Create;
          liEMF1.Width := spWidth;
          liEMF1.Height := spHeight;
          RotateWmf(emf, liEmf1, 180);
          RMPrintGraphic(aCanvas, RealRect, liEmf1, IsPrinting, DirectDraw, False);
          //          aCanvas.StretchDraw(RealRect, liEmf1);
        end;
      rmat270:
        begin
          liEMF1 := TMetafile.Create;
          liEMF1.Width := spWidth;
          liEMF1.Height := spHeight;
          RotateWmf(emf, liEmf1, 270);
          RMPrintGraphic(aCanvas, RealRect, liEmf1, IsPrinting, DirectDraw, False);
          //          aCanvas.StretchDraw(RealRect, liEmf1);
        end;
    end;
  finally
    Windows.SelectClipRgn(aCanvas.Handle, 0);
  end;
  liEmf1.Free;
  EMF.Free;

  ShowFrame;
  RestoreCoord;
end;

procedure TRMBarCodeView.PlaceOnEndPage(aStream: TStream);
begin
  inherited;
end;

procedure TRMBarCodeView.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FBarCodeInfo.RotationType := TRMBarCodeAngleType(RMReadByte(aStream));
  RMReadFont(aStream, FBarCode.Font);
  FBarCode.AddCheckChar := RMReadBoolean(aStream);
  FBarCode.BarCodeType := TStBarCodeType(RMReadByte(aStream));
  FBarCode.BarColor := RMReadInt32(aStream);
  FBarCode.BarToSpaceRatio := RMReadInt32(aStream) / 1000;
  FBarCode.BarNarrowToWideRatio := RMReadInt32(aStream);
  FBarCode.BarWidth := RMReadInt32(aStream) / 1000;
  FBarCode.BearerBars := RMReadBoolean(aStream);
  FBarCode.Code128Subset := TStCode128CodeSubset(RMReadByte(aStream));
  FBarCode.ExtendedSyntax := RMReadBoolean(aStream);
  FBarCode.ShowCode := RMReadBoolean(aStream);
  FBarCode.ShowGuardChars := RMReadBoolean(aStream);
  FBarCode.SupplementalCode := RMReadString(aStream);
  FBarCode.TallGuardBars := RMReadBoolean(aStream);
end;

procedure TRMBarCodeView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0); // 版本号
  RMWriteByte(aStream, Byte(FBarCodeInfo.RotationType));
  RMWriteFont(aStream, FBarCode.Font);
  RMWriteBoolean(aStream, FBarCode.AddCheckChar);
  RMWriteByte(aStream, Byte(FBarCode.BarCodeType));
  RMWriteInt32(aStream, FBarCode.BarColor);
  RMWriteInt32(aStream, Round(FBarCode.BarToSpaceRatio * 1000));
  RMWriteInt32(aStream, FBarCode.BarNarrowToWideRatio);
  RMWriteInt32(aStream, Round(FBarCode.BarWidth * 1000));
  RMWriteBoolean(aStream, FBarCode.BearerBars);
  RMWriteByte(aStream, Byte(FBarCode.Code128Subset));
  RMWriteBoolean(aStream, FBarCode.ExtendedSyntax);
  RMWriteBoolean(aStream, FBarCode.ShowCode);
  RMWriteBoolean(aStream, FBarCode.ShowGuardChars);
  RMWriteString(aStream, FBarCode.SupplementalCode);
  RMWriteBoolean(aStream, FBarCode.TallGuardBars);
end;

procedure TRMBarCodeView.ShowEditor;
var
  tmp: TRMBarcodeForm;
begin
  tmp := TRMBarcodeForm.Create(nil);
  try
  	tmp.View := Self;
    tmp.edtCode.Text := cbDefaultText;
    tmp.cmbTypes.ItemIndex := ord(FBarCode.BarCodeType);
    tmp.chkAddCheckChar.Checked := FBarCode.AddCheckChar;
    tmp.eZoom.Text := FloatToStr(FBarCode.BarToSpaceRatio);
    tmp.chkViewText.Checked := FBarCode.ShowCode;
    tmp.chkTallGuardBars.Checked := FBarCode.TallGuardBars;
    if Memo.Count > 0 then
      tmp.edtCode.Text := Memo.Strings[0];
    if tmp.ShowModal = mrOk then
    begin
      RMDesigner.BeforeChange;
      Memo.Clear;
      Memo.Add(tmp.edtCode.Text);
      FBarCode.BarCodeType := TStBarCodeType(tmp.cmbTypes.ItemIndex);
      FBarCode.AddCheckChar := tmp.chkAddCheckChar.Checked;
      FBarCode.BarToSpaceRatio := StrToFloat(tmp.eZoom.Text);
      FBarCode.ShowCode := tmp.chkViewText.Checked;
      FBarCode.TallGuardBars := tmp.chkTallGuardBars.Checked;
    end;
  finally
    tmp.Free;
  end;
end;

function TRMBarCodeView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flBarCodeDirectDraw) = flBarCodeDirectDraw;
end;

procedure TRMBarCodeView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flBarCodeDirectDraw);
  if Value then
    FFlags := FFlags + flBarCodeDirectDraw;
end;

function TRMBarCodeView.GetViewCommon: string;
begin
  Result := '[BarCode]';
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRM2DBarCodeView }

constructor TRM2DBarCodeView.Create;
begin
  inherited Create;
  BaseName := 'BarCode2D';

  FBarCodeType := rmbtPDF417;

  FViewpdf417 := TStPDF417Barcode.Create(nil);
  FViewMaxi := TStMaxiCodeBarcode.Create(nil); //121 * 121
  FillColor := clWhite;
  spHeight := 80;
  spWidth := 300;
end;

destructor TRM2DBarCodeView.Destroy;
begin
  FViewpdf417.Free;
  FViewMaxi.Free;
  inherited Destroy;
end;

type
  THack2dBarCode = class(TStCustom2DBarcode)
  end;

procedure TRM2DBarCodeView.Draw(aCanvas: TCanvas);
var
  liBarCodeStr: string;
  liEmf: TMetafile;
  liEmfCanvas: TMetafileCanvas;
  Fixcolor: Tcolor;
begin
  //  spHeight := Param.cheight + 4;
  //  spWidth := Param.cwidth + 4;
  Fixcolor := clWhite; // $00F8F8F8; //248 248 248 2003-3-25
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  if Memo1.Count > 0 then
  begin
    liBarCodeStr := Trim(Memo1.Text);
    if liBarCodeStr <> '' then
      SetLength(liBarCodeStr, Length(liBarCodeStr) - 2);
  end
  else
    liBarCodeStr := '';

  liEmf := TMetafile.Create;
  liEmf.Width := spWidth;
  liEmf.Height := spHeight;
  liEmfCanvas := TMetafileCanvas.Create(liEmf, 0);

  if FBarCodeType = rmbtpdf417 then
  begin
    FViewpdf417.code := liBarCodeStr;
    FViewpdf417.SetBounds(0, 0, spWidth, spHeight);
    THack2dBarCode(FViewpdf417).GenerateBarcodeBitmap(spWidth, spHeight);
    with FViewpdf417 do
    begin
    	if FillColor = clNone then
      begin
	      //liEMFCanvas.Brush.Color := clRed;
      end
      else
	      liEMFCanvas.Brush.Color := FillColor;
      liEMFCanvas.Brushcopy(Rect(0, 0, Bitmap.Width, Bitmap.Height), Bitmap,
        Rect(0, 0, Bitmap.Width, Bitmap.Height), Fixcolor);
    end;
  end
  else
  begin
    FViewMaxi.Code := liBarCodeStr;
    FViewMaxi.SetBounds(0, 0, spWidth, spHeight);
    THack2dBarCode(FViewMaxi).GenerateBarcodeBitmap(spWidth, spHeight);
    with FViewMaxi do
    begin
    	if FillColor = clNone then
      begin
	      //liEMFCanvas.Brush.Color := clRed;
      end  
      else
	      liEMFCanvas.Brush.Color := FillColor;

      liEMFCanvas.Brushcopy(Rect(0, 0, Bitmap.Width, Bitmap.Height), Bitmap,
        Rect(0, 0, Bitmap.Width, Bitmap.Height), Fixcolor);
    end;
  end;

  liEmfCanvas.Free;
  CalcGaps;
  ShowBackground;
  if liBarCodeStr <> '' then
  begin
	  IntersectClipRect(aCanvas.Handle, RealRect.Left, RealRect.Top, RealRect.Right, RealRect.Bottom);
  	try
	    RMPrintGraphic(aCanvas, RealRect, liEmf, IsPrinting, DirectDraw, False);
  	  //    aCanvas.StretchDraw(RealRect, liEMF);
	  finally
  	  Windows.SelectClipRgn(aCanvas.Handle, 0);
	  end;
  end;

  liEMF.Free;
  ShowFrame;
  RestoreCoord;
end;

procedure TRM2DBarCodeView.PlaceOnEndPage(aStream: TStream);
begin
  inherited;
end;

procedure TRM2DBarCodeView.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FBarCodeType := TRM2DBarCodeType(RMReadByte(aStream));
  if FBarCodeType = rmbtpdf417 then
  begin
    FViewpdf417.ECCLevel := TStPDF417ECCLevels(RMReadByte(aStream));
    FViewpdf417.NumColumns := RMReadInt32(aStream);
    FViewpdf417.NumRows := RMReadInt32(aStream);
    FViewpdf417.Truncated := RMReadBoolean(aStream);

    FViewpdf417.BarHeight := RMReadInt32(aStream);
    FViewpdf417.BarHeightToWidth := RMReadInt32(aStream);
    FViewpdf417.BarWidth := RMReadInt32(aStream);
    FViewpdf417.CaptionLayout := TTextLayout(RMReadByte(aStream));
    FViewpdf417.ExtendedSyntax := RMReadBoolean(aStream);
    FViewpdf417.RelativeBarHeight := RMReadBoolean(aStream);
    FViewpdf417.QuietZone := RMReadInt32(aStream);
    FViewpdf417.Caption := RMReadString(aStream);
    RMReadFont(aStream, FViewpdf417.Font);
  end
  else if FBarCodeType = rmbtMAXI then
  begin
    FViewMaxi.AutoScale := RMReadBoolean(aStream);
    FViewMaxi.CarrierCountryCode := RMReadInt32(aStream);
    FViewMaxi.CarrierPostalCode := RMReadString(aStream);
    FViewMaxi.CarrierServiceClass := RMReadInt32(aStream);
    FViewMaxi.HorPixelsPerMM := RMReadInt32(aStream) / 1000;
    FViewMaxi.Mode := TStMaxiCodeMode(RMReadByte(aStream));
    FViewMaxi.VerPixelsPerMM := RMReadInt32(aStream) / 1000;

    FViewMaxi.BarHeight := RMReadInt32(aStream);
    FViewMaxi.BarHeightToWidth := RMReadInt32(aStream);
    FViewMaxi.BarWidth := RMReadInt32(aStream);
    FViewMaxi.CaptionLayout := TTextLayout(RMReadByte(aStream));
    FViewMaxi.ExtendedSyntax := RMReadBoolean(aStream);
    FViewMaxi.RelativeBarHeight := RMReadBoolean(aStream);
    FViewMaxi.QuietZone := RMReadInt32(aStream);
    FViewMaxi.Caption := RMReadString(aStream);
    RMReadFont(aStream, FViewMaxi.Font);
  end;
end;

procedure TRM2DBarCodeView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0); // 版本号
  RMWriteByte(aStream, Byte(FBarCodeType));
  if FBarCodeType = rmbtpdf417 then
  begin
    RMWriteByte(aStream, Byte(FViewpdf417.ECCLevel));
    RMWriteInt32(aStream, FViewpdf417.NumColumns);
    RMWriteInt32(aStream, FViewpdf417.NumRows);
    RMWriteBoolean(aStream, FViewpdf417.Truncated);

    RMWriteInt32(aStream, FViewpdf417.BarHeight);
    RMWriteInt32(aStream, FViewpdf417.BarHeightToWidth);
    RMWriteInt32(aStream, FViewpdf417.BarWidth);
    RMWriteByte(aStream, Byte(FViewpdf417.CaptionLayout));
    RMWriteBoolean(aStream, FViewpdf417.ExtendedSyntax);
    RMWriteBoolean(aStream, FViewpdf417.RelativeBarHeight);
    RMWriteInt32(aStream, FViewpdf417.QuietZone);
    RMWriteString(aStream, FViewpdf417.Caption);
    RMWriteFont(aStream, FViewpdf417.Font);
  end
  else if FBarCodeType = rmbtMAXI then
  begin
    RMWriteBoolean(aStream, FViewMaxi.AutoScale);
    RMWriteInt32(aStream, FViewMaxi.CarrierCountryCode);
    RMWriteString(aStream, FViewMaxi.CarrierPostalCode);
    RMWriteInt32(aStream, FViewMaxi.CarrierServiceClass);
    RMWriteInt32(aStream, Round(FViewMaxi.HorPixelsPerMM * 1000));
    RMWriteByte(aStream, Byte(FViewMaxi.Mode));
    RMWriteInt32(aStream, Round(FViewMaxi.VerPixelsPerMM * 1000));

    RMWriteInt32(aStream, FViewMaxi.BarHeight);
    RMWriteInt32(aStream, FViewMaxi.BarHeightToWidth);
    RMWriteInt32(aStream, FViewMaxi.BarWidth);
    RMWriteByte(aStream, Byte(FViewMaxi.CaptionLayout));
    RMWriteBoolean(aStream, FViewMaxi.ExtendedSyntax);
    RMWriteBoolean(aStream, FViewMaxi.RelativeBarHeight);
    RMWriteInt32(aStream, FViewMaxi.QuietZone);
    RMWriteString(aStream, FViewMaxi.Caption);
    RMWriteFont(aStream, FViewMaxi.Font);
  end;
end;

procedure TRM2DBarCodeView.ShowEditor;
var
  tmpForm: TRM2DBarcodeForm;
begin
  tmpForm := TRM2DBarcodeForm.Create(nil);
  try
  	tmpForm.FView := Self;
    tmpForm.FBusy := True;
    tmpForm.edtCode.Text := Memo.Text;

    tmpForm.CheckBox2.Checked := FViewpdf417.Caption <> '';
    tmpForm.Edit1.Text := FViewpdf417.Caption;
    tmpForm.ComboBox2.ItemIndex := Byte(FViewpdf417.CaptionLayout);
    tmpForm.FSpinEdit1.Value := FViewpdf417.BarWidth;

    tmpForm.FSpinEdit2.Value := FViewpdf417.NumColumns;
    tmpForm.FSpinEdit3.Value := FViewpdf417.NumRows;
    tmpForm.CheckBox1.Checked := FViewpdf417.Truncated;
    tmpForm.ComboBox1.ItemIndex := Byte(FViewpdf417.ECCLevel);
    tmpForm.CheckBox3.Checked := FViewpdf417.RelativeBarHeight;
    // tmpForm.CheckBox4.Checked:=FViewpdf417.ParentColor;
    if FViewpdf417.Alignment = taCenter then
      tmpForm.rb2.Checked := True
    else if FViewpdf417.Alignment = taLeftJustify then
      tmpForm.rb1.Checked := True
    else if FViewpdf417.Alignment = taRightJustify then
      tmpForm.rb3.Checked := True;

    tmpForm.CheckBox5.Checked := FViewMaxi.Caption <> '';
    tmpForm.Edit5.Text := FViewMaxi.Caption;
    tmpForm.ComboBox4.ItemIndex := Byte(FViewMaxi.CaptionLayout);
    tmpForm.Edit2.Text := IntToStr(FViewMaxi.CarrierCountryCode);
    tmpForm.Edit3.Text := FViewMaxi.CarrierPostalCode;
    tmpForm.edit4.text := IntToStr(FViewMaxi.CarrierServiceClass);
    tmpForm.cmbMaxiMode.ItemIndex := Byte(FViewMaxi.Mode);
    if FBarCodeType = rmbtpdf417 then
      tmpForm.Choos2DType.ActivePage := tmpForm.tabSheet1
    else
      tmpForm.Choos2DType.ActivePage := tmpForm.tabSheet2;

    if tmpForm.ShowModal = mrOk then
    begin
      RMDesigner.BeforeChange;
      Memo.Clear;
      Memo.Add(tmpForm.edtCode.Text);
      if tmpForm.Choos2DType.ActivePage = tmpForm.TabSheet1 then
      begin
        FBarCodeType := rmbtpdf417;
        if tmpForm.CheckBox2.Checked then
          FViewpdf417.Caption := tmpForm.Edit1.Text
        else
          FViewpdf417.Caption := '';
        FViewpdf417.CaptionLayout := TTextLayout(tmpForm.ComboBox2.ItemIndex);
        FViewpdf417.BarWidth := tmpForm.FSpinEdit1.AsInteger;
        FViewpdf417.NumColumns := tmpForm.FSpinEdit2.AsInteger;
        FViewpdf417.NumRows := tmpForm.FSpinEdit3.AsInteger;
        FViewpdf417.Truncated := tmpForm.CheckBox1.Checked;
        //  FViewpdf417.ParentColor:=tmpForm.CheckBox4.Checked;

        if tmpForm.rb2.Checked = True then
          FViewpdf417.Alignment := taCenter
        else if tmpForm.rb1.Checked = True then
          FViewpdf417.Alignment := taLeftJustify
        else if tmpForm.rb3.Checked = True then
          FViewpdf417.Alignment := taRightJustify;

        FViewpdf417.RelativeBarHeight := tmpForm.CheckBox3.Checked;
        FViewpdf417.ECCLevel := TStPDF417ECCLevels(tmpForm.ComboBox1.ItemIndex);
      end
      else if tmpForm.Choos2DType.ActivePage = tmpForm.TabSheet2 then
      begin
        FBarCodeType := rmbtMaxi;
        if tmpForm.CheckBox5.Checked then
          FViewMaxi.Caption := tmpForm.Edit5.Text
        else
          FViewMaxi.Caption := '';
        FViewMaxi.CaptionLayout := TTextLayout(tmpForm.ComboBox4.ItemIndex);
        FViewMaxi.CarrierCountryCode := StrToInt(tmpForm.Edit2.Text);
        FViewMaxi.CarrierPostalCode := tmpForm.Edit3.Text;
        FViewMaxi.CarrierServiceClass := StrToInt(tmpForm.edit4.text);
        FViewMaxi.Mode := TStMaxiCodeMode(tmpForm.cmbMaxiMode.ItemIndex);
      end;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRM2DBarCodeView.DefinePopupMenu(aPopup: TRMCustomMenuItem);
begin
  inherited;
end;

function TRM2DBarCodeView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flBarCodeDirectDraw) = flBarCodeDirectDraw;
end;

procedure TRM2DBarCodeView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flBarCodeDirectDraw);
  if Value then
    FFlags := FFlags + flBarCodeDirectDraw;
end;

function TRM2DBarCodeView.GetViewCommon: string;
begin
  Result := '[2DBarCode]';
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBar2CodeForm }
{-----------------------------------------------------------------------------
  Procedure: BarcodeEditor
  Author:    lz
  Date:      21-二月-2003
  Arguments: Sender: TObject
  Result:    None
  Email : sinmax@163.net
-----------------------------------------------------------------------------}

procedure TRM2DBarCodeForm.FormCreate(Sender: TObject);
begin
  FPDF417 := TStPDF417Barcode.Create(Self);
  FPDF417.Parent := Panel1;
  FPDF417.Align := alClient;
  FPDF417.Code := edtCode.Text;

  FMaxi := TStMaxiCodeBarcode.Create(Self);
  FMaxi.Parent := Panel1;
  FMaxi.Align := alClient;
  FMaxi.Code := edtCode.Text;
  FMaxi.Visible := False;

  FSpinEdit1 := TRMSpinEdit.Create(Self);
  with FSpinEdit1 do
  begin
    Parent := GroupBox4;
    ValueType := rmvtInteger;
    SetBounds(47, 9, 85, 22);
    OnChange := SpinEdit1Change;
    MinValue := 1;
  end;
  FSpinEdit2 := TRMSpinEdit.Create(Self);
  with FSpinEdit2 do
  begin
    Parent := GroupBox4;
    ValueType := rmvtInteger;
    SetBounds(47, 34, 85, 22);
    OnChange := SpinEdit1Change;
    MinValue := 0;
  end;
  FSpinEdit3 := TRMSpinEdit.Create(Self);
  with FSpinEdit3 do
  begin
    Parent := GroupBox4;
    ValueType := rmvtInteger;
    SetBounds(195, 34, 90, 22);
    OnChange := SpinEdit1Change;
  end;
  edit1.Visible := False;
  edit5.Visible := False;
  Choos2DType.Visible := True;
  Localize;
end;

procedure TRM2DBarCodeForm.SpeedButton1Click(Sender: TObject);
begin
  SaveDialog1.FileName := '';
  SaveDialog1.DefaultExt := '.BMP';
  SaveDialog1.Filter := 'BMP图形文件(*.BMP)|*.BMP';
  if SaveDialog1.Execute then
  begin
    Fpdf417.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TRM2DBarCodeForm.DBBtnClick(Sender: TObject);
var
  s: string;
begin
  s := RMDesigner.InsertExpression(FView);
  if s <> '' then
    edtCode.SelText := s;
end;

procedure TRM2DBarCodeForm.SpinEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.SpinEdit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.SpinEdit3KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.ComboBox2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.CheckBox2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if CheckBox2.Checked then
  begin
    ComboBox2.Enabled := True;
    label6.Enabled := True;
    edit1.Enabled := True;
    label9.Enabled := true;
  end
  else
  begin
    ComboBox2.Enabled := false;
    label6.Enabled := false;
    edit1.Enabled := False;
    label9.Enabled := False;
  end;
end;

procedure TRM2DBarCodeForm.barcolorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.backgroundColorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (key = vk_return) then
    SelectNext(Sender as Twincontrol, true, true);
end;

procedure TRM2DBarCodeForm.btnOKKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_down) then
    SelectNext(Sender as Twincontrol, true, true)
  else if (key = vk_up) then
    SelectNext(Sender as Twincontrol, false, true);
end;

procedure TRM2DBarCodeForm.btnCancelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_down) then
    SelectNext(Sender as Twincontrol, true, true)
  else if (key = vk_up) then
    SelectNext(Sender as Twincontrol, false, true);
end;

procedure TRM2DBarCodeForm.CheckBox2Click(Sender: TObject);
begin
  ShowSample;
  if CheckBox2.Checked then
  begin
    ComboBox2.Visible := True;
    label13.Visible := True;
    edit1.Visible := True;
    label8.Visible := true;
  end
  else
  begin
    ComboBox2.Visible := False;
    label13.Visible := False;
    edit1.Visible := False;
    label8.Visible := False;
  end;
end;

procedure TRM2DBarCodeForm.FormResize(Sender: TObject);

begin
  ShowSample;
  {
   If RMBar2CodeForm.Width <= 481 Then
     RMBar2CodeForm.Width := 481;
   If RMBar2CodeForm.Height <= 337 Then
     RMBar2CodeForm.Height := 337;
 }
end;

procedure TRM2DBarCodeForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    key := #0;
  if sender is Tedit then
    if ('Edit2' = (sender as Tedit).name) then
    begin
      if (not ((key in ['0'..'9']) or (key = #8) or (key = #13) or (key = #40))) then
        abort;
    end;
end;

procedure TRM2DBarCodeForm.Edit3KeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    key := #0;
  if sender is Tedit then
    if ('Edit3' = (sender as Tedit).name) then
    begin
      if (not ((key in ['0'..'9']) or (key = #8) or (key = #13) or (key = #40))) then
        abort;
    end;
end;

procedure TRM2DBarCodeForm.Edit4KeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    key := #0;
  if sender is Tedit then
    if ('Edit4' = (sender as Tedit).name) then
    begin
      if (not ((key in ['0'..'9']) or (key = #8) or (key = #13) or (key = #40))) then
        abort;
    end;
end;

procedure TRM2DBarCodeForm.Edit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_down) then
    SelectNext(Sender as Twincontrol, true, true)
  else if (key = vk_up) then
    SelectNext(Sender as Twincontrol, false, true);
end;

procedure TRM2DBarCodeForm.Edit3KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_down) then
    SelectNext(Sender as Twincontrol, true, true)
  else if (key = vk_up) then
    SelectNext(Sender as Twincontrol, false, true);
end;

procedure TRM2DBarCodeForm.Edit4KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = vk_down) then
    SelectNext(Sender as Twincontrol, true, true)
  else if (key = vk_up) then
    SelectNext(Sender as Twincontrol, false, true);
end;

procedure TRM2DBarCodeForm.Choos2DTypeChange(Sender: TObject);
begin
  if Choos2DType.ActivePage = tabSheet1 then
  begin
    FPDF417.Visible := True;
    Fmaxi.Visible := False;
    edtCode.MaxLength := 0;
    ShowSample;
  end
  else if Choos2DType.ActivePage = tabSheet2 then
  begin
    FPDF417.Visible := False;
    edtCode.MaxLength := 85;
    if Length(edtCode.text) > 85 then
      edtCode.text := Copy(edtCode.text, 1, 80);

    Fmaxi.Visible := True;
    ShowSample;
  end;
end;

procedure TRM2DBarCodeForm.Localize;
var
  str: string;
  liPos: Integer;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Label1, 'Caption', rmRes + 260);
  RMSetStrProp(Label16, 'Caption', rmRes + 261);
  RMSetStrProp(Label14, 'Caption', rmRes + 261);
  RMSetStrProp(Label15, 'Caption', rmRes + 261);

  RMSetStrProp(Label2, 'Caption', rmRes + 262);
  RMSetStrProp(Label4, 'Caption', rmRes + 263);
  RMSetStrProp(Label3, 'Caption', rmRes + 264);
  RMSetStrProp(Label5, 'Caption', rmRes + 265);
  RMSetStrProp(CheckBox2, 'Caption', rmRes + 660);
  RMSetStrProp(Label6, 'Caption', rmRes + 661);
  RMSetStrProp(Label9, 'Caption', rmRes + 662);
  RMSetStrProp(CheckBox1, 'Caption', rmRes + 663);
  RMSetStrProp(CheckBox3, 'Caption', rmRes + 664);
  RMSetStrProp(rb1, 'Caption', rmRes + 665);
  RMSetStrProp(rb2, 'Caption', rmRes + 666);
  RMSetStrProp(rb3, 'Caption', rmRes + 665);

  RMSetStrProp(CheckBox5, 'Caption', rmRes + 660);
  RMSetStrProp(Label7, 'Caption', rmRes + 667);
  RMSetStrProp(Label8, 'Caption', rmRes + 662);
  RMSetStrProp(Label13, 'Caption', rmRes + 661);
  RMSetStrProp(Label10, 'Caption', rmRes + 668);
  RMSetStrProp(Label12, 'Caption', rmRes + 669);
  RMSetStrProp(Label11, 'Caption', rmRes + 670);
  cmbMaxiMode.Items.Clear;
  cmbMaxiMode.Items.Add(RMLoadStr(rmRes + 672));
  cmbMaxiMode.Items.Add('cmMode3');
  cmbMaxiMode.Items.Add(RMLoadStr(rmRes + 673));
  cmbMaxiMode.Items.Add(RMLoadStr(rmRes + 674));
  cmbMaxiMode.Items.Add('cmMode6');

  RMSetStrProp(DBBtn, 'Hint', rmRes + 656);

  str := RMLoadStr(rmRes + 671);
  ComboBox2.Items.Clear;
  liPos := Pos(';', str);
  while liPos > 0 do
  begin
    ComboBox2.Items.Add(Copy(str, 1, liPos - 1));
    Delete(str, 1, liPos);
    liPos := Pos(';', str);
  end;
  ComboBox2.Items.Add(str);
  ComboBox4.Items.Assign(ComboBox2.Items);

  btnOk.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRM2DBarCodeForm.ShowSample;
var
  Xsize, Ysize: integer;
begin
  if Check2BarCode(edtCode.text) = false then //条码 连续的数字溢出
    exit;
  if FBusy then
    Exit;

  FBusy := True;
  Fpdf417.code := '';
  ySize := FPDF417.Height;
  xSize := FPDF417.Width;

  if Choos2DType.ActivePage = tabSheet1 then //PDF417
  begin
    Fpdf417.BarWidth := FSpinEdit1.AsInteger;
    Fpdf417.NumColumns := FSpinEdit2.AsInteger;
    Fpdf417.NumRows := FSpinEdit3.AsInteger;
    Fpdf417.Height := Ysize;
    Fpdf417.Width := Xsize;
    case ComboBox1.ItemIndex of
      0: Fpdf417.ECCLevel := ecAuto;
      1: Fpdf417.ECCLevel := ecLevel0;
      2: Fpdf417.ECCLevel := ecLevel1;
      3: Fpdf417.ECCLevel := ecLevel2;
      4: Fpdf417.ECCLevel := ecLevel3;
      5: Fpdf417.ECCLevel := ecLevel4;
      6: Fpdf417.ECCLevel := ecLevel5;
      7: Fpdf417.ECCLevel := ecLevel6;
      8: Fpdf417.ECCLevel := ecLevel7;
      9: Fpdf417.ECCLevel := ecLevel8;
    else
      Fpdf417.ECCLevel := ecAuto;
    end;

    if CheckBox1.Checked then
      Fpdf417.Truncated := True
    else
      Fpdf417.Truncated := false;

    if CheckBox3.checked then
      Fpdf417.RelativeBarHeight := True
    else
      Fpdf417.RelativeBarHeight := False;

    //   If CheckBox4.checked Then
    //     Fpdf417.ParentColor := True
    //   Else
    //     Fpdf417.ParentColor := False;
    if rb2.Checked = True then
      Fpdf417.Alignment := taCenter
    else if rb1.Checked = True then
      Fpdf417.Alignment := taLeftJustify
    else if rb3.Checked = True then
      Fpdf417.Alignment := taRightJustify;

    if CheckBox2.Checked then
    begin
      Fpdf417.Caption := Edit1.Text;
      case ComboBox2.ItemIndex of
        0: Fpdf417.CaptionLayout := tlTop;
        1: Fpdf417.CaptionLayout := tlCenter;
        2: Fpdf417.CaptionLayout := tlBottom;
      else
        Fpdf417.CaptionLayout := tlCenter;
      end;
    end
    else
      Fpdf417.Caption := '';

    Fpdf417.Code := edtCode.text;
    label14.caption := 'Width:' + inttostr(Fpdf417.BarCodeWidth);
    label15.caption := 'Height:' + inttostr(Fpdf417.BarCodeHeight);
  end
  else if Choos2DType.ActivePage = tabSheet2 then //maxicode
  begin
    if cmbMaxiMode.ItemIndex = 0 then
    begin
      FMaxi.CarrierCountryCode := StrToInt(Edit2.Text);
      FMaxi.CarrierPostalCode := Edit3.Text;
      FMaxi.CarrierServiceClass := StrToInt(Edit4.Text);
      FMaxi.Mode := cmMode2;
    end
    else
    begin
      FMaxi.CarrierCountryCode := 0;
      FMaxi.CarrierPostalCode := '000000000';
      FMaxi.CarrierServiceClass := 0;
      FMaxi.Mode := cmMode4;
    end;

    if CheckBox5.Checked then
    begin
      FMaxi.Caption := Edit5.Text;
      case ComboBox4.itemindex of
        0: FMaxi.CaptionLayout := tlTop;
        1: FMaxi.CaptionLayout := tlCenter;
        2: FMaxi.CaptionLayout := tlBottom;
      else
        FMaxi.CaptionLayout := tlBottom;
      end;
    end
    else
      FMaxi.Caption := '';
    case cmbMaxiMode.ItemIndex of
      0: FMaxi.Mode := cmMode2;
      1: FMaxi.Mode := cmMode3;
      2: FMaxi.Mode := cmMode4;
      3: FMaxi.Mode := cmMode5;
      4: FMaxi.Mode := cmMode6;
    else
      FMaxi.Mode := cmMode4;
    end;
    FMaxi.code := edtCode.text;
    label14.caption := 'Width:' + inttostr(FMaxi.BarCodeWidth);
    label15.caption := 'Height:' + inttostr(FMaxi.BarCodeHeight);
  end
  else
  begin //其他 可以加入其他二维条码类型 退出
  end;

  FBusy := False;
end;

procedure TRM2DBarCodeForm.FormDestroy(Sender: TObject);
begin
  FPDF417.Free;
  FMaxi.Free;
end;

procedure TRM2DBarCodeForm.Edit1DblClick(Sender: TObject);
begin
  Edit1.Text := '';
end;

procedure TRM2DBarCodeForm.edtCodeChange(Sender: TObject);
begin

  if Check2BarCode(edtCode.Text) = False then
    Edtcode.Undo
  else
    ShowSample;
end;

procedure TRM2DBarCodeForm.CheckBox5Click(Sender: TObject);
begin
  ShowSample;
  if CheckBox5.Checked then
  begin
    ComboBox4.visible := True;
    label6.visible := True;
    edit5.visible := True;
    label9.visible := true;
  end
  else
  begin
    ComboBox4.visible := false;
    label6.visible := false;
    edit5.visible := False;
    label9.visible := False;
  end;
end;

procedure TRM2DBarCodeForm.CheckBox5KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if CheckBox5.Checked then
  begin
    ComboBox4.Enabled := True;
    label13.Enabled := True;
    edit5.Enabled := True;
    label8.Enabled := true;
  end
  else
  begin
    ComboBox4.Enabled := false;
    label13.Enabled := false;
    edit5.Enabled := False;
    label8.Enabled := False;
  end;
end;

procedure TRM2DBarCodeForm.SpinEdit1Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.ComboBox1Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.ComboBox2Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.Edit1Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.CheckBox1Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.CheckBox3Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.CheckBox4Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.Edit2Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.Edit4Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.Edit3Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.cmbMaxiModeChange(Sender: TObject);
begin
  if cmbMaxiMode.ItemIndex >= 0 then
    FMaxi.Mode := TStMaxiCodeMode(cmbMaxiMode.ItemIndex);
  ShowSample;

  if cmbMaxiMode.ItemIndex = 0 then
  begin
    label10.Enabled := True;
    label11.Enabled := True;
    label12.Enabled := True;
    edit2.Enabled := True;
    edit3.Enabled := True;
    edit4.Enabled := True;
  end
  else
  begin
    label10.Enabled := False;
    label11.Enabled := False;
    label12.Enabled := False;
    edit2.Enabled := False;
    edit3.Enabled := False;
    edit4.Enabled := False;
  end;
end;

procedure TRM2DBarCodeForm.ComboBox4Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.Edit5Change(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.FormShow(Sender: TObject);
begin
  Choos2DTypeChange(nil);
  cmbMaxiModeChange(nil);
  FBusy := False;
  ShowSample;
end;

function TRM2DBarCodeForm.Check2BarCode(S: ansistring): Boolean;
const
  Number = ['0'..'9']; //字符类型
var
  i, j, k: integer;
  WS: string;
  BKiss: TStringlist;
begin
  BKiss := TStringList.Create;
  try
    bKiss.Clear;
    S := Trim(S + '#');
    j := 0;
    Result := True;
    for i := 1 to Length(s) do
    begin
      WS := '';
      if not (S[i] in Number) then
      begin
        if Length(Copy(S, j + 1, i - j - 1)) <> 0 then
          WS := (Copy(S, j + 1, i - j - 1));
        j := i;
        if trim(WS) <> '' then
          BKiss.Append(ws);
      end;
    end;
    for k := 0 to BKiss.Count - 1 do
    begin
      if length(BKiss.Strings[k]) > 17 then
      begin
        Result := False;
        Application.MessageBox(Pchar('整形溢出错误,连续的数字不可以大于17位.' + #13 + '请效验数字类型字符"' +
          BKiss.Strings[k] +
          '"'), '错误', MB_OK +
          MB_ICONSTOP);

      end;
    end;
  finally
    FreeAndNil(BKiss);
  end;
end;

procedure TRM2DBarCodeForm.edtCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Check2BarCode(edtcode.Text) = false then
end;

procedure TRM2DBarCodeForm.SpeedButton2Click(Sender: TObject);
begin
  Application.MessageBox(Pchar(
    '二维条码PDF417技术的特点' + #13
    + '1 、信息量大 一个PDF417条码符号，可以将1848个字母字符或2729个数字字符或字母、数字混编字符进行    编码。在同等面积下，二维条码比一维条码信息含量高几十倍。' +
    #13
    + '2、容易印制 PDF417条码可以印在纸、卡片及各种常用条码载体上，可以用多种标准的打印技术及卡片印制   技术印制，包括：喷墨打印、激光打印、热敏／热转印条码打印机打印等。' +
    #13
    + '3、修正错误能力强 错误修正甚至可以将符号受损面积达50％的条码符号所含信息复现出来。' + #13
    + '4、译码可靠性高 在管理数据库测试中，阅读2000万个条码符号，没有出现一例译码错误，这说明PDF417具   有极高的可靠性。' +
    #13
    + '5、保密性强 PDF417可以把编码信息按密码格式进行编码,防止伪造条码符号或非法使用有关编码的信息。'
    ), '错误', MB_OK + MB_ICONINFORMATION);
end;

procedure TRM2DBarCodeForm.RB1Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.rb2Click(Sender: TObject);
begin
  ShowSample;
end;

procedure TRM2DBarCodeForm.rb3Click(Sender: TObject);
begin
  ShowSample;
end;

const
	cRM = 'RM_BarCode';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cRM, TRMBarCodeView, 'TRMBarCodeView');
    AddClass(cRM, TRM2DBarCodeView, 'TRM2DBarCodeView');
  end;
end;

initialization
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);
//  RMRegisterObjectByRes(TRMBarCodeView, 'RM_BarCodeObject', RMLoadStr(SInsBarcode), nil);
//  RMRegisterObjectByRes(TRM2DBarCodeView, 'RM_2BARCODEOBJECT', RMLoadStr(SInsBarcode), nil);
  RMRegisterControls('ReportPage Additional', 'RM_OtherComponent', False,
    [TRMBarCodeView, TRM2DBarCodeView],
    ['RM_BarCodeObject', 'RM_2BARCODEOBJECT'],
    [RMLoadStr(SInsBarcode), RMLoadStr(SInsBarcode)]);

finalization

  {$ENDIF}
end.

