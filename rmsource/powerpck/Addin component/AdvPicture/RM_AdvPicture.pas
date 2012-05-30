unit RM_AdvPicture;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, DB, Menus, RM_Const, RM_Class,
  AdvPicture, RM_Ctrls;

type
  { TRMAdvPictureView }
  TRMAdvPictureView = class(TRMReportView)
  private
    FPicture: TIPicture;
    FPictureSource: TRMPictureSource;
    FBlobType: TRMBlobType;
    FPictureFormat: TRMPictureFormat;

    procedure OnPictureStretchedClick(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);

    function GetPictureCenter: Boolean;
    procedure SetPictureCenter(value: Boolean);
    function GetPictureRatio: Boolean;
    procedure SetPictureRatio(value: Boolean);
    function GetPictureStretched: Boolean;
    procedure SetPictureStretched(value: Boolean);

    procedure _PictureEditor(Sender: TObject);
  protected
    function GetViewCommon: string; override;
    procedure GetBlob; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure DefinePopupMenu(aPopup: TPopupMenu); override;
    procedure ShowEditor; override;
  published
//    property BlobType: TRMBlobType read FBlobType write FBlobType;
//    property PictureFormat: TRMPictureFormat read FPictureFormat write FPictureFormat;
    property Picture: TIPicture read FPicture;
    property DataField;
    property PictureCenter: Boolean read GetPictureCenter write SetPictureCenter;
    property PictureRatio: Boolean read GetPictureRatio write SetPictureRatio;
    property PictureStretched: Boolean read GetPictureStretched write SetPictureStretched;
    property Transparent;
    property PictureSource: TRMPictureSource read FPictureSource write FPictureSource;
    property ReprintOnOverFlow;
    property ShiftWith;
    property BandAlign;
    property FillColor;
  end;

 { TRMadvPictureForm }
  TRMadvPictureForm = class(TRMObjEditorForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    ScrollBox1: TScrollBox;
    ImagePaintBox: TPaintBox;
    btnLoadImage: TButton;
    btnClearImage: TButton;
    procedure btnClearImageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImagePaintBoxPaint(Sender: TObject);
    procedure btnLoadImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FPicture: TIPicture;
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
  end;

implementation

{$R *.DFM}
{$R RM_AdvPicture.res}

uses RM_Common, RM_Utils, RM_Const1, ClipBrd{$IFDEF OPENPICTUREDLG}, ExtDlgs{$ENDIF};

const
  flPictCenter = $1;
  flPictRatio = $2;
  flPictStretched = $4;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMAdvPictureView}

constructor TRMAdvPictureView.Create;
begin
  inherited Create;
  BaseName := 'AdvPicture';

  FFlags := 0;
  FPictureSource := rmpsPicture;
  PictureStretched := True;
  PictureRatio := True;
  Transparent := False;
  FPictureFormat := rmpfBorland;
  FBlobType := rmbtAuto;

  FPicture := TIPicture.Create;
end;

destructor TRMAdvPictureView.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

procedure TRMAdvPictureView.Draw(aCanvas: TCanvas);
var
  liRect: TRect;
  kx, ky: Double;
  liWidth, liHeight, liWidth1, liHeight1: Integer;

  procedure _PrintGraphic;
  var
    lSaveMode: TCopyMode;
  begin
    lSaveMode := aCanvas.CopyMode;
    try
      if Transparent then
        aCanvas.CopyMode := cmSrcAnd
      else
        aCanvas.CopyMode := cmSrcCopy;

      ShowBackground;
      if DocMode <> rmdmDesigning then
        IntersectClipRect(aCanvas.Handle, liRect.Left, liRect.Top, liRect.Right, liRect.Bottom);
      RMPrintGraphic(aCanvas, liRect, FPicture, DocMode = rmdmPrinting);
    finally
      if DocMode <> rmdmDesigning then
        Windows.SelectClipRgn(aCanvas.Handle, 0);
      aCanvas.CopyMode := lSaveMode;
    end;
  end;

  procedure _DrawEmpty;
  var
    liBmp: TBitmap;
  begin
    with aCanvas do
    begin
      if RMIsChineseGB then
      begin
        Font.Name := '宋体';
        Font.Size := 9;
      end
      else
      begin
        Font.Name := 'Arial';
        Font.Size := 8;
      end;
      Font.Style := [];
      Font.Color := clBlack;
      Font.Charset := RMCharset;
      TextRect(RealRect, RealRect.Left + 20, RealRect.Top + 3, RMLoadStr(SPicture));
      liBmp := TBitmap.Create;
      liBmp.Handle := LoadBitmap(hInstance, 'RM_EMPTY');
      Draw(RealRect.Left + 1, RealRect.Top + 2, liBmp);
      liBmp.Free;
    end;
  end;

begin
  BeginDraw(aCanvas);
  CalcGaps;
  if (RealRect.Right >= RealRect.Left) and (RealRect.Bottom >= RealRect.Top) then
  begin
    if (FPicture <> nil) and (not FPicture.Empty) then
    begin
      if PictureStretched then // 缩放图片
      begin
        if PictureRatio then
        begin
          liWidth := RealRect.Right - RealRect.Left;
          liHeight := RealRect.Bottom - RealRect.Top;
          kx := liWidth / FPicture.Width;
          ky := liHeight / FPicture.Height;
          if kx < ky then
            liRect := Rect(RealRect.Left, RealRect.Top, RealRect.Right, RealRect.Top + Round(FPicture.Height * kx))
          else
            liRect := Rect(RealRect.Left, RealRect.Top, RealRect.Left + Round(FPicture.Width * ky), RealRect.Bottom);
          liWidth1 := liRect.Right - liRect.Left;
          liHeight1 := liRect.Bottom - liRect.Top;
          if PictureCenter then
            OffsetRect(liRect, (liWidth - liWidth1) div 2, (liHeight - liHeight1) div 2);
        end
        else
          liRect := RealRect;
      end
      else // 原始大小
      begin
        liRect := RealRect;
        liWidth := Round(FactorX * FPicture.Width);
        liHeight := Round(FactorY * FPicture.Height);
        liRect.Right := liRect.Left + liWidth;
        liRect.Bottom := liRect.Top + liHeight;
        if PictureCenter then
          OffsetRect(liRect, (RealRect.Right - RealRect.Left - liWidth) div 2,
            (RealRect.Bottom - RealRect.Top - liHeight) div 2);
      end;

      _PrintGraphic;
    end
    else
    begin
      ShowBackground;
      if DocMode = rmdmDesigning then
        _DrawEmpty;
    end;
  end;

  ShowFrame;
  RestoreCoord;
end;

procedure TRMAdvPictureView.LoadFromStream(aStream: TStream);
var
  lStream: TMemoryStream;
  lPictureEmpty: Boolean;
  lPos: Integer;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FPictureSource := TRMPictureSource(RMReadByte(aStream));
  FBlobType := TRMBlobType(RMReadByte(aStream));
  FPictureFormat := TRMPictureFormat(RMReadByte(aStream));

  lPictureEmpty := RMReadBoolean(aStream);
  lPos := RMReadInt32(aStream);
  lStream := TMemoryStream.Create;
  try
    lStream.CopyFrom(aStream, lPos - aStream.Position);
    lStream.Position := 0;
    if not lPictureEmpty then
      FPicture.LoadFromStream(lStream);
  finally
    lStream.Free;
    aStream.Seek(lPos, soFromBeginning);
  end;
end;

procedure TRMAdvPictureView.SaveToStream(aStream: TStream);
var
  lPictureEmpty: Boolean;
  lSavePos, lPos: Integer;
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(FPictureSource));
  RMWriteByte(aStream, Byte(FBlobType));
  RMWriteByte(aStream, Byte(FPictureFormat));

  lPictureEmpty := FPicture.Empty;
  RMWriteBoolean(aStream, lPictureEmpty);
  lSavePos := aStream.Position;
  RMWriteInt32(aStream, lSavePos);
  if not lPictureEmpty  then
    FPicture.SaveToStream(aStream);

  lPos := aStream.Position;
  aStream.Seek(lSavePos, soFromBeginning);
  RMWriteInt32(aStream, lPos);
  aStream.Seek(0, soFromEnd);
end;

{$HINTS OFF}

procedure TRMAdvPictureView.GetBlob;
var
  lMemoryStream: TMemoryStream;
begin
  if ParentReport.Flag_TableEmpty then
  begin
    FPicture.Assign(nil);
    Exit;
  end;

  if FDataSet.FieldIsNull(FDataFieldName) then
    FPicture.Assign(nil)
  else
  begin
    lMemoryStream := TMemoryStream.Create;
    FDataSet.AssignBlobFieldTo(FDataFieldName, lMemoryStream);
    FPicture.LoadFromStream(lMemoryStream);
    lMemoryStream.Free;
  end
end;
{$HINTS ON}

procedure TRMAdvPictureView.ShowEditor;
begin
  _PictureEditor(Self);
end;

procedure TRMAdvPictureView._PictureEditor(Sender: TObject);
var
  tmp: TRMadvPictureForm;
begin
  tmp := TRMadvPictureForm.Create(nil);
  try
    tmp.ShowEditor(Self);
  finally
    tmp.Free;
  end;
end;

procedure TRMAdvPictureView.DefinePopupMenu(aPopup: TPopupMenu);
var
  m: TMenuItem;
begin
  inherited DefinePopupMenu(aPopup);

  m := TMenuItem.Create(aPopup);
  m.Caption := RMLoadStr(SStretched);
  m.OnClick := OnPictureStretchedClick;
  m.Checked := PictureStretched;
  aPopup.Items.Add(m);

  m := TMenuItem.Create(aPopup);
  m.Caption := RMLoadStr(SPictureCenter);
  m.OnClick := P1Click;
  m.Checked := PictureCenter;
  aPopup.Items.Add(m);

  m := TMenuItem.Create(aPopup);
  m.Caption := RMLoadStr(SKeepAspectRatio);
  m.OnClick := P2Click;
  m.Enabled := PictureStretched;
  if m.Enabled then
    m.Checked := PictureRatio;
  aPopup.Items.Add(m);
end;

procedure TRMAdvPictureView.OnPictureStretchedClick(Sender: TObject);
begin
  SetPropertyValue('PictureStretched', not TMenuItem(Sender).Checked);
end;

procedure TRMAdvPictureView.P1Click(Sender: TObject);
begin
  SetPropertyValue('PictureCenter', not TMenuItem(Sender).Checked);
end;

procedure TRMAdvPictureView.P2Click(Sender: TObject);
begin
  SetPropertyValue('PictureRatio', not TMenuItem(Sender).Checked);
end;

function TRMAdvPictureView.GetPictureCenter: Boolean;
begin
  Result := (FFlags and flPictCenter) = flPictCenter;
end;

procedure TRMAdvPictureView.SetPictureCenter(value: Boolean);
begin
  FFlags := (FFlags and not flPictCenter);
  if Value then
    FFlags := FFlags + flPictCenter;
end;

function TRMAdvPictureView.GetPictureRatio: Boolean;
begin
  Result := (FFlags and flPictRatio) = flPictRatio;
end;

procedure TRMAdvPictureView.SetPictureRatio(value: Boolean);
begin
  FFlags := (FFlags and not flPictRatio);
  if Value then
    FFlags := FFlags + flPictRatio;
end;

function TRMAdvPictureView.GetPictureStretched: Boolean;
begin
  Result := (FFlags and flPictStretched) = flPictStretched;
end;

procedure TRMAdvPictureView.SetPictureStretched(value: Boolean);
begin
  FFlags := (FFlags and not flPictStretched);
  if Value then
    FFlags := FFlags + flPictStretched;
end;

function TRMAdvPictureView.GetViewCommon: string;
begin
  Result := RMLoadStr(SPicture);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMadvPictureView }

procedure TRMadvPictureForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 460);
  RMSetStrProp(btnLoadImage, 'Caption', rmRes + 462);
  RMSetStrProp(btnClearImage, 'Caption', rmRes + 463);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMadvPictureForm.ShowEditor(View: TRMView): TModalResult;
begin
  if TRMAdvPictureView(View).Picture.Empty then
    FPicture.Assign(nil)
  else
    FPicture.Assign(TRMAdvPictureView(View).Picture);

  Result := ShowModal;
  if Result = mrOk then
  begin
    RMDesigner.BeforeChange;
    TRMAdvPictureView(View).Picture.Assign(FPicture);
  end;
end;

procedure TRMadvPictureForm.btnClearImageClick(Sender: TObject);
begin
  FPicture.Assign(nil);
  ImagePaintBox.Invalidate;
end;

procedure TRMadvPictureForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = vk_Insert) and (ssShift in Shift)) or
    ((Chr(Key) = 'V') and (ssCtrl in Shift)) then
  begin
    FPicture.Assign(Clipboard);
    ImagePaintBox.Invalidate;
  end;
end;

procedure TRMadvPictureForm.ImagePaintBoxPaint(Sender: TObject);
var
  DrawRect: TRect;
begin
  with TPaintBox(Sender) do
  begin
    Canvas.Brush.Color := {Self.} Color;
    DrawRect := ClientRect; //Rect(Left, Top, Left + Width, Top + Height);
    if FPicture.Width > 0 then
    begin
      with DrawRect do
      begin
        if (FPicture.Width > Right - Left) or (FPicture.Height > Bottom - Top) then
        begin
          if FPicture.Width > FPicture.Height then
            Bottom := Top + MulDiv(FPicture.Height, Right - Left, FPicture.Width)
          else
            Right := Left + MulDiv(FPicture.Width, Bottom - Top, FPicture.Height);
          Canvas.StretchDraw(DrawRect, FPicture);
        end
        else
        begin
          with DrawRect do
          begin
            Canvas.Draw(Left + (Right - Left - FPicture.Width) div 2, Top + (Bottom - Top -
              FPicture.Height) div 2, FPicture);
          end;
        end;
      end;
    end
    else
    begin
      with DrawRect, Canvas do
      begin
        TextOut(Left + (Right - Left - TextWidth(RMLoadStr(SNotAssigned))) div 2, Top + (Bottom -
          Top - TextHeight(RMLoadStr(SNotAssigned))) div 2, RMLoadStr(SNotAssigned));
      end;
    end;
  end;
end;

procedure TRMadvPictureForm.btnLoadImageClick(Sender: TObject);
var
{$IFDEF OPENPICTUREDLG}
  OpenDlg: TOpenPictureDialog;
{$ELSE}
  OpenDlg: TOpenDialog;
{$ENDIF}
  s, s1: string;
begin
{$IFDEF OPENPICTUREDLG}
  OpenDlg := TOpenPictureDialog.Create(nil);
{$ELSE}
  OpenDlg := TOpenDialog.Create(nil);
{$ENDIF}
  try
    OpenDlg.Options := [ofHideReadOnly];
    s := '*.bmp *.ico *.wmf *.emf *.jpg *.jpeg *.gif';
    s1 := '*.bmp;*.ico;*.wmf;*.emf;*.jpg;*.jpeg;*.gif';
    OpenDlg.Filter := RMLoadStr(SPictFile) + ' (' + s + ')|' + s1 + '|' + RMLoadStr(SAllFiles) + '|*.*';
    if OpenDlg.Execute then
    begin
      FPicture.LoadFromFile(OpenDlg.FileName);
      ImagePaintBox.Invalidate;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TRMadvPictureForm.FormCreate(Sender: TObject);
begin
  Localize;
  FPicture := TIPicture.Create;
end;

procedure TRMadvPictureForm.FormDestroy(Sender: TObject);
begin
  FPicture.Free;
end;

initialization
  RMRegisterObjectByRes(TRMAdvPictureView, 'RM_ADVPICTURE', 'ssss', nil);

end.

