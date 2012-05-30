
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{              Picture editor             }
{                                         }
{*****************************************}

unit RM_EditorPicture;

interface

{$I RM.inc}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, RM_Const, RM_Class;

type
  TRMPictureEditorForm = class(TRMObjEditorForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    btnLoadImage: TButton;
    btnClearImage: TButton;
    btnSaveImage: TButton;
    ScrollBox1: TScrollBox;
    ImagePaintBox: TPaintBox;
    procedure btnClearImageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImagePaintBoxPaint(Sender: TObject);
    procedure btnLoadImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveImageClick(Sender: TObject);
  private
    { Private declarations }
    FPicture: TPicture;
    FPictureTypes: string;

    procedure Localize;
    procedure SetPicture(Value: TPicture);
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
    function ShowbkPicture(page: TRMReportPage): TModalResult;

    property Picture: TPicture read FPicture write SetPicture;
    property PictureTypes: string read FPictureTypes write FPictureTypes;
  end;

implementation

{$R *.DFM}

uses RM_Utils, ClipBrd{$IFDEF OPENPICTUREDLG}, ExtDlgs{$ENDIF};

type
  THackPage = class(TRMReportPage)
  end;

function TRMPictureEditorForm.ShowEditor(View: TRMView): TModalResult;
begin
  FPicture.Assign((View as TRMPictureView).Picture);
  Result := ShowModal;
  if Result = mrOk then
  begin
    RMDesigner.BeforeChange;
    TRMPictureView(View).Picture.Assign(FPicture);
    RMDesigner.AfterChange;
  end;
end;

function TRMPictureEditorForm.ShowbkPicture(page: TRMReportPage): TModalResult;
begin
  FPicture.Assign(THackPage(page).FbkPicture);
  Result := ShowModal;
  if Result = mrOk then
  begin
    RMDesigner.BeforeChange;
    Page.BackPicture := FPicture;
    RMDesigner.AfterChange;
  end;
end;

procedure TRMPictureEditorForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 460);
  RMSetStrProp(btnLoadImage, 'Caption', rmRes + 462);
  RMSetStrProp(btnClearImage, 'Caption', rmRes + 463);
  RMSetStrProp(btnSaveImage, 'Caption', rmRes + 465);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMPictureEditorForm.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
  ImagePaintBox.Invalidate;
end;

procedure TRMPictureEditorForm.btnClearImageClick(Sender: TObject);
begin
  FPicture.Graphic := nil;
  ImagePaintBox.Invalidate;
end;

procedure TRMPictureEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = vk_Insert) and (ssShift in Shift)) or
    ((Chr(Key) = 'V') and (ssCtrl in Shift)) then
  begin
    FPicture.Assign(Clipboard);
    ImagePaintBox.Invalidate;
  end;
end;

procedure TRMPictureEditorForm.ImagePaintBoxPaint(Sender: TObject);
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
          Canvas.StretchDraw(DrawRect, FPicture.Graphic);
        end
        else
        begin
          with DrawRect do
          begin
            Canvas.Draw(Left + (Right - Left - FPicture.Width) div 2, Top + (Bottom - Top -
              FPicture.Height) div 2, FPicture.Graphic);
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

procedure TRMPictureEditorForm.btnLoadImageClick(Sender: TObject);
var
  {$IFDEF OPENPICTUREDLG}
  OpenDlg: TOpenPictureDialog;
  {$ELSE}
  OpenDlg: TOpenDialog;
  {$ENDIF}
begin
  {$IFDEF OPENPICTUREDLG}
  OpenDlg := TOpenPictureDialog.Create(nil);
  {$ELSE}
  OpenDlg := TOpenDialog.Create(nil);
  {$ENDIF}
  try
    OpenDlg.Options := [ofHideReadOnly];
    OpenDlg.Filter := RMLoadStr(SPictFile) + FPictureTypes;
    if OpenDlg.Execute then
    begin
      FPicture.LoadFromFile(OpenDlg.FileName);
      ImagePaintBox.Invalidate;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TRMPictureEditorForm.FormCreate(Sender: TObject);
var
  s, s1: string;
begin
  Localize;
  FPicture := TPicture.Create;

  s := '*.bmp *.ico *.wmf *.emf';
  s1 := '*.bmp;*.ico;*.wmf;*.emf';
  {$IFDEF JPEG}
  s := s + ' *.jpg';
  s1 := s1 + ';*.jpg';
  {$ENDIF}
  {$IFDEF RXGIF}
  s := s + ' *.gif';
  s1 := s1 + ';*.gif';
  {$ENDIF}
  FPictureTypes := ' (' + s + ')|' + s1 + '|' + RMLoadStr(SAllFiles) + '|*.*';
end;

procedure TRMPictureEditorForm.FormDestroy(Sender: TObject);
begin
  FPicture.Free;
end;

procedure TRMPictureEditorForm.btnSaveImageClick(Sender: TObject);
var
  {$IFDEF OPENPICTUREDLG}
  SaveDlg: TSavePictureDialog;
  {$ELSE}
  SaveDlg: TSaveDialog;
  {$ENDIF}
  s, s1: string;
begin
  if FPicture.Graphic = nil then Exit;

  {$IFDEF OPENPICTUREDLG}
  SaveDlg := TSavePictureDialog.Create(nil);
  {$ELSE}
  SaveDlg := TSaveDialog.Create(nil);
  {$ENDIF}
  try
    SaveDlg.Options := [ofHideReadOnly];
    s := '*.bmp *.ico *.wmf *.emf';
    s1 := '*.bmp;*.ico;*.wmf;*.emf';
    {$IFDEF JPEG}
    s := s + ' *.jpg';
    s1 := s1 + ';*.jpg';
    {$ENDIF}
    {$IFDEF RXGIF}
    s := s + ' *.gif';
    s1 := s1 + ';*.gif';
    {$ENDIF}
    SaveDlg.Filter := RMLoadStr(SPictFile) + ' (' + s + ')|' + s1 + '|' + RMLoadStr(SAllFiles) + '|*.*';
    SaveDlg.DefaultExt := GraphicExtension(TGraphicClass(FPicture.Graphic.ClassType));
    SaveDlg.Filter := GraphicFilter(TGraphicClass(FPicture.Graphic.ClassType));
    if SaveDlg.Execute then
    begin
      FPicture.SaveToFile(SaveDlg.FileName);
    end;
  finally
    SaveDlg.Free;
  end;
end;

end.

 