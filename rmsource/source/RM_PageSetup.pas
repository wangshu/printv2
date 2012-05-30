unit RM_PageSetup;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, RM_Printer, RM_Ctrls, RM_Common, RM_Class;

type
  { TRMPageImage }
  TRMPageImage = class(TShape)
  private
    FColumns: Integer;
    FPageImage: TBitMap;
    procedure DrawPage;
  protected
    procedure Paint; override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetLayout(aColumns: Integer; aRowSpacing: Single);
  end;

  { TRMPageSetupForm }
  TRMPageSetupForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox2: TGroupBox;
    imgLandScape: TImage;
    imgPortrait: TImage;
    rdbPortrait: TRadioButton;
    rdbLandscape: TRadioButton;
    GroupBox1: TGroupBox;
    chkPrintToPrevPage: TCheckBox;
    TabSheet4: TTabSheet;
    chkUnlimitedHeight: TCheckBox;
    cmbPaperNames: TComboBox;
    lblPaperWidth: TLabel;
    lblPaperHeight: TLabel;
    lblPaperSize: TLabel;
    lstBinNames: TListBox;
    lblPaperTray: TLabel;
    grbPreview: TGroupBox;
    lblPrinterName: TLabel;
    cmbPrinterNames: TComboBox;
    chkDoublePass: TCheckBox;
    chkTaoda: TCheckBox;
    chkColorPrint: TCheckBox;
    Label9: TLabel;
    edtTitle: TEdit;
    chkNewPage: TCheckBox;
    GroupBox5: TGroupBox;
    lblColCount: TLabel;
    lblColGap: TLabel;
    GroupBox3: TGroupBox;
    lblMarginTop: TLabel;
    lblMarginBottom: TLabel;
    lblMarginLeft: TLabel;
    lblMarginRight: TLabel;
    chkConvertNulls: TCheckBox;
    chkPageMode: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cmbPrinterNamesChange(Sender: TObject);
    procedure cmbPaperNamesChange(Sender: TObject);
    procedure rdbPortraitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtTitleExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lstBinNamesClick(Sender: TObject);
  private
    { Private declarations }
    FPreviewPage: TRMPageImage;
    FPageSetting: TRMPageSetting;
    FUpdating: Boolean;
    FPrinterInfo: TRMPrinterInfo;
    FCurReport: TRMReport;
    FCurPrinter: TRMPrinter;

    FSpinPaperHeight: TRMSpinEdit;
    FSpinPaperWidth: TRMSpinEdit;
    FSpinMarginTop: TRMSpinEdit;
    FSpinMarginBottom: TRMSpinEdit;
    FSpinMarginLeft: TRMSpinEdit;
    FSpinMarginRight: TRMSpinEdit;
    FSpinColCount: TRMSpinEdit;
    FSpinColGap: TRMSpinEdit;

    procedure PaperChange;
    procedure PrinterChange;

    procedure Localize;
    procedure Init;
    procedure OnPagerWidthExitEvent(Sender: TObject);
    procedure OnMarginExitEvent(Sender: TObject);
  public
    { Public declarations }
    function PreviewPageSetup: Boolean;
    function Execute: Boolean;

    property CurReport: TRMReport read FCurReport write FCurReport;
    property PageSetting: TRMPageSetting read FPageSetting;
    property CurPrinter: TRMPrinter read FCurPrinter write FCurPrinter;
  end;

implementation

{$R *.DFM}

uses Math, RM_Utils, RM_Const, RM_Const1;

var
  FForm: TRMPageSetupForm;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  {TRMPageImage}

constructor TRMPageImage.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FPageImage := TBitMap.Create;
  FColumns := 0;
  Color := clBtnFace;
end;

destructor TRMPageImage.Destroy;
begin
  FPageImage.Free;
  inherited Destroy;
end;

procedure TRMPageImage.SetLayout(aColumns: Integer; aRowSpacing: Single);
begin
  FColumns := aColumns;
  DrawPage;
end;

procedure TRMPageImage.DrawPage;
var
  ldRatio: Double;
  liHeight, liWidth: Integer;
  liLeft, liTop, liRight, liBottom: Integer;
  ldScaleWidth, ldScaleHeight: Double;
  liMarginTop: Integer;
  liMarginBottom: Integer;
  liMarginLeft: Integer;
  liMarginRight: Integer;
  lPaperWidth, lPaperHeight: Double;
begin
  lPaperWidth := FForm.PageSetting.PageWidth;
  lPaperHeight := FForm.PageSetting.PageHeight;
  if lPaperHeight = 0 then Exit;

  ldRatio := lPaperWidth / lPaperHeight;
  liHeight := Height;
  liWidth := Round(ldRatio * liHeight);
  while (liWidth >= Width) do
  begin
    liHeight := liHeight - 20;
    liWidth := Round(ldRatio * liHeight);
  end;

  ldScaleWidth := liWidth / lPaperWidth;
  ldScaleHeight := liHeight / lPaperHeight;

  liMarginTop := Trunc(FForm.FSpinMarginTop.Value * 100 * ldScaleHeight);
  liMarginBottom := Trunc(FForm.FSpinMarginBottom.Value * 100 * ldScaleHeight);
  liMarginLeft := Trunc(FForm.FSpinMarginLeft.Value * 100 * ldScaleWidth);
  liMarginRight := Trunc(FForm.FSpinMarginRight.Value * 100 * ldScaleWidth);

  FPageImage.Width := Width;
  FPageImage.Height := Height;

  FPageImage.Canvas.Pen.Style := psSolid;
  FPageImage.Canvas.Brush.Style := bsSolid;
  FPageImage.Canvas.Brush.Color := clBtnFace;
  FPageImage.Canvas.FillRect(Rect(0, 0, Width, Height));

  liLeft := (Width - liWidth) div 2;
  liTop := (Height - liHeight) div 2;
  liRight := liLeft + liWidth;
  liBottom := liTop + liHeight;

  FPageImage.Canvas.Brush.Color := clWindow;
  FPageImage.Canvas.Rectangle(liLeft, liTop, liRight - 5, liBottom - 5);

  FPageImage.Canvas.Brush.Color := clGray; //clBlack;
  FPageImage.Canvas.FillRect(Rect(liLeft + 6, liTop + liHeight - 5, liRight, liBottom));
  FPageImage.Canvas.FillRect(Rect(liRight - 5, liTop + 6, liRight, liBottom));

  liLeft := liLeft + 1 + liMarginLeft;
  liTop := liTop + 1 + liMarginTop;
  liRight := liRight - 6 - liMarginRight;
  liBottom := liBottom - 6 - liMarginBottom;

  FPageImage.Canvas.Pen.Style := psDot;
  FPageImage.Canvas.Brush.Color := clWindow;
  {$IFDEF D5}
  FPageImage.Canvas.Rectangle(Rect(liLeft, liTop, liRight, liBottom));
  {$ELSE}
  FPageImage.Canvas.Rectangle(liLeft, liTop, liRight, liBottom);
  {$ENDIF}
  Invalidate;
end;

procedure TRMPageImage.Paint;
begin
  with Canvas do
    CopyRect(ClipRect, FPageImage.Canvas, ClipRect);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPageSetupForm}

procedure TRMPageSetupForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 390);
  RMSetStrProp(TabSheet1, 'Caption', rmRes + 391);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 392);
  RMSetStrProp(rdbPortrait, 'Caption', rmRes + 393);
  RMSetStrProp(rdbLandscape, 'Caption', rmRes + 394);
  RMSetStrProp(lblPaperSize, 'Caption', rmRes + 395);
  RMSetStrProp(lblPaperWidth, 'Caption', rmRes + 396);
  RMSetStrProp(lblPaperHeight, 'Caption', rmRes + 397);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 398);
  RMSetStrProp(lblMarginLeft, 'Caption', rmRes + 400);
  RMSetStrProp(lblMarginTop, 'Caption', rmRes + 401);
  RMSetStrProp(lblMarginRight, 'Caption', rmRes + 402);
  RMSetStrProp(lblMarginBottom, 'Caption', rmRes + 403);
  RMSetStrProp(chkColorPrint, 'Caption', rmRes + 369);
  RMSetStrProp(chkNewPage, 'Caption', rmRes + 368);
  RMSetStrProp(TabSheet3, 'Caption', rmRes + 405);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 406);
  RMSetStrProp(chkPrintToPrevPage, 'Caption', rmRes + 407);
  RMSetStrProp(chkUnlimitedHeight, 'Caption', rmRes + 413);
  RMSetStrProp(chkConvertNulls, 'Caption', rmRes + 415);

  RMSetStrProp(TabSheet4, 'Caption', rmRes + 411);
  RMSetStrProp(lblPaperTray, 'Caption', rmRes + 412);
  RMSetStrProp(Label9, 'Caption', rmRes + 372);
  RMSetStrProp(chkDoublePass, 'Caption', rmRes + 374);
  RMSetStrProp(lblPrinterName, 'Caption', rmRes + 371);
  RMSetStrProp(chkTaoda, 'Caption', rmRes + 375);
  RMSetStrProp(grbPreview, 'Caption', rmRes + 399);

  RMSetStrProp(GroupBox3, 'Caption', rmRes + 398);
  RMSetStrProp(GroupBox5, 'Caption', rmRes + 408);
  RMSetStrProp(lblColCount, 'Caption', rmRes + 409);
  RMSetStrProp(lblColGap, 'Caption', rmRes + 410);
	RMSetStrProp(chkPageMode, 'Caption', rmRes + 270);

  btnOk.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMPageSetupForm.Execute: Boolean;
begin
  Init;
  Result := (ShowModal = mrOK);
end;

function TRMPageSetupForm.PreviewPageSetup: Boolean;
begin
  //  cmbPrinterNames.Enabled := False;
  //  TabSheet3.TabVisible := False;
  //  Result := ShowModal = mrOK;
  FSpinColCount.Enabled := False;
  FSpinColGap.Enabled := False;
  chkUnlimitedHeight.Visible := True;
	RM_Utils.RMSetStrProp(chkUnlimitedHeight, 'Caption', rmRes + 384);

  Init;
  if FCurReport <> nil then
  begin
		TabSheet3.TabVisible := FCurReport.CanRebuild;
  end;
  Result := (ShowModal = mrOK);
end;

procedure TRMPageSetupForm.PrinterChange;
var
  lIndex, lPaperCount: Integer;
  SaveWidth, SaveHeight: Integer;
begin
  FPrinterInfo := RMPrinters.PrinterInfo[cmbPrinterNames.ItemIndex];
  with FPrinterInfo do
  begin
    cmbPaperNames.Items.Assign(PaperNames);
    lstBinNames.Items.Assign(BinNames);

    if FPageSetting.PageOr = rmpoPortrait then
    begin
      SaveWidth := FPageSetting.PageWidth;
      saveHeight := FPageSetting.PageHeight;
    end
    else
    begin
      SaveWidth := FPageSetting.PageHeight;
      saveHeight := FPageSetting.PageWidth;
    end;

    lIndex := 0;
    lPaperCount := PaperSizesCount;
    while lIndex < lPaperCount do
    begin
      if (abs(PaperWidths[lIndex] - SaveWidth) <= 1) and (abs(PaperHeights[lIndex] - SaveHeight) <= 1) then
        Break;

      Inc(lIndex);
    end;

    if lIndex < lPaperCount then
      FPageSetting.PageSize := PaperSizes[lIndex]
    else
      FPageSetting.PageSize := PaperSizes[lPaperCount - 1];
  end;

  PaperChange;
end;

procedure TRMPageSetupForm.PaperChange;
begin
  if FUpdating then Exit;

  FUpdating := True;
  try
    rdbPortrait.Checked := (FPageSetting.PageOr = rmpoPortrait);
    rdbLandscape.Checked := (FPageSetting.PageOr = rmpoLandscape);
    imgPortrait.Visible := rdbPortrait.Checked;
    imgLandScape.Visible := not rdbPortrait.Checked;

    FSpinPaperWidth.Value := FPageSetting.PageWidth / 100;
    FSpinPaperHeight.Value := FPageSetting.PageHeight / 100;

    lstBinNames.ItemIndex := FPrinterInfo.GetBinIndex(FPageSetting.PageBin);
    cmbPaperNames.ItemIndex := FPrinterInfo.GetPaperSizeIndex(FPageSetting.PageSize);

    RMEnableControls([FSpinPaperWidth, FSpinPaperHeight],
      cmbPaperNames.ItemIndex = cmbPaperNames.Items.Count - 1);
    if FSpinPaperWidth.Enabled then
    begin
      OnPagerWidthExitEvent(nil);
    end;

    FPreviewPage.DrawPage;
  finally
    FUpdating := False;
  end;
end;

procedure TRMPageSetupForm.FormCreate(Sender: TObject);
begin
	FCurReport := nil;
  Localize;
  FPageSetting := TRMPageSetting.Create;

  FSpinPaperWidth := TRMSpinEdit.Create(Self);
  with FSpinPaperWidth do
  begin
    Parent := TabSheet1;
    SetBounds(lblPaperWidth.BoundsRect.Right + 2, lblPaperWidth.Top, 86, 21);
    ValueType := rmvtFloat;
    OnExit := OnPagerWidthExitEvent;
    OnTopClick := OnPagerWidthExitEvent;
    OnBottomClick := OnPagerWidthExitEvent;
  end;
  FSpinPaperHeight := TRMSpinEdit.Create(Self);
  with FSpinPaperHeight do
  begin
    Parent := TabSheet1;
    SetBounds(FSpinPaperWidth.Left, lblPaperHeight.Top, 86, 21);
    ValueType := rmvtFloat;
    OnExit := OnPagerWidthExitEvent;
    OnTopClick := OnPagerWidthExitEvent;
    OnBottomClick := OnPagerWidthExitEvent;
  end;

  FSpinMarginTop := TRMSpinEdit.Create(Self);
  with FSpinMarginTop do
  begin
    Parent := GroupBox3;
    SetBounds(120, lblMarginTop.Top, GroupBox3.Width - 120 -4, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    OnBottomClick := OnMarginExitEvent;
    OnTopClick := OnMarginExitEvent;
    OnExit := OnMarginExitEvent;
  end;
  FSpinMarginBottom := TRMSpinEdit.Create(Self);
  with FSpinMarginBottom do
  begin
    Parent := GroupBox3;
    SetBounds(FSpinMarginTop.Left, lblMarginBottom.Top, FSpinMarginTop.Width, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    OnBottomClick := OnMarginExitEvent;
    OnTopClick := OnMarginExitEvent;
    OnExit := OnMarginExitEvent;
  end;
  FSpinMarginLeft := TRMSpinEdit.Create(Self);
  with FSpinMarginLeft do
  begin
    Parent := GroupBox3;
    SetBounds(FSpinMarginTop.Left, lblMarginLeft.Top, FSpinMarginTop.Width, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    OnBottomClick := OnMarginExitEvent;
    OnTopClick := OnMarginExitEvent;
    OnExit := OnMarginExitEvent;
  end;
  FSpinMarginRight := TRMSpinEdit.Create(Self);
  with FSpinMarginRight do
  begin
    Parent := GroupBox3;
    SetBounds(FSpinMarginTop.Left, lblMarginRight.Top, FSpinMarginTop.Width, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    OnBottomClick := OnMarginExitEvent;
    OnTopClick := OnMarginExitEvent;
    OnExit := OnMarginExitEvent;
  end;

  FSpinColCount := TRMSpinEdit.Create(Self);
  with FSpinColCount do
  begin
    Parent := GroupBox5;
    SetBounds(FSpinMarginTop.Left, lblColCount.Top,
       FSpinMarginTop.Width, 21);
    MinValue := 1;
    OnExit := OnMarginExitEvent;
  end;
  FSpinColGap := TRMSpinEdit.Create(Self);
  with FSpinColGap do
  begin
    Parent := GroupBox5;
    SetBounds(FSpinColCount.Left, lblColGap.Top, FSpinColCount.Width, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    OnExit := OnMarginExitEvent;
  end;

  FForm := Self;
  FPreviewPage := TRMPageImage.Create(Self);
  grbPreview.InsertControl(FPreviewPage);
  with FPreviewPage do
  begin
    Left := 5;
    Top := 20;
    Width := grbPreview.Width - 10;
    Height := grbPreview.Height - 30;
  end;

  PageControl1.ActivePage := TabSheet1;
end;

procedure TRMPageSetupForm.FormShow(Sender: TObject);
begin
  if FPageSetting.ColCount < 1 then
    FPageSetting.ColCount := 1;

  cmbPrinterNames.Items.Assign(RMPrinters.Printers);
  cmbPrinterNames.ItemIndex := FCurPrinter{RMPrinter}.PrinterIndex;
  edtTitle.Text := FPageSetting.Title;
  PrinterChange;
end;

procedure TRMPageSetupForm.cmbPrinterNamesChange(Sender: TObject);
begin
  PrinterChange;
end;

procedure TRMPageSetupForm.cmbPaperNamesChange(Sender: TObject);
var
  index: Integer;
begin
  index := cmbPaperNames.ItemIndex;
  if Index < 0 then
    Exit;
  FPageSetting.PageSize := FPrinterInfo.PaperSizes[index];
  if Index <> cmbPaperNames.Items.Count - 1 then
  begin
    with FPrinterInfo do
    begin
      if FPageSetting.PageOr = rmpoPortrait then
      begin
        FPageSetting.PageWidth := PaperWidths[index];
        FPageSetting.PageHeight := PaperHeights[index];
      end
      else
      begin
        FPageSetting.PageWidth := PaperHeights[index];
        FPageSetting.PageHeight := PaperWidths[index];
      end;
    end;
  end;

  PaperChange;
end;

procedure TRMPageSetupForm.rdbPortraitClick(Sender: TObject);
begin
  if rdbPortrait.Checked then
    FPageSetting.PageOr := rmpoPortrait
  else
    FPageSetting.PageOr := rmpoLandscape;

  PaperChange;
end;

procedure TRMPageSetupForm.OnPagerWidthExitEvent(Sender: TObject);
begin
  if ActiveControl <> btnCancel then
  begin
    FPageSetting.PageWidth := Round(FSpinPaperWidth.Value * 100);
    FPageSetting.PageHeight := Round(FSpinPaperHeight.Value * 100);
    PaperChange;
  end;
end;

procedure TRMPageSetupForm.OnMarginExitEvent(Sender: TObject);
begin
  if ActiveControl <> btnCancel then
  begin
    if FUpdating then Exit;

    FUpdating := True;
    try
      FPreviewPage.DrawPage;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TRMPageSetupForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  liLeft, liTop, liRight, liBottom: Double;
  liPrnInfo: TRMPageInfo;

  function dm(pxls: integer; mmInInch: integer): Double;
  begin
    Result := Round((pxls / RMInchPerMM / mmInInch) * 10) / 10;
  end;

begin
  if ModalResult = mrOK then
  begin
    try
      FCurPrinter{RMPrinter}.PrinterIndex := cmbPrinterNames.ItemIndex;
      FCurPrinter{RMPrinter}.SetPrinterInfo(FPageSetting.PageSize, FPageSetting.PageWidth, FPageSetting.PageHeight,
        FPageSetting.PageBin, FPageSetting.PageOr, False);
      FCurPrinter{RMPrinter}.FillPrinterInfo(liPrnInfo);

      liLeft := dm(FCurPrinter{RMPrinter}.PageGutters.Left, FCurPrinter{RMPrinter}.PixelsPerInch.X);
      liTop := dm(RMPrinter.PageGutters.Top, FCurPrinter{RMPrinter}.PixelsPerInch.Y);
      liRight := dm(FCurPrinter{RMPrinter}.PageGutters.Right, FCurPrinter{RMPrinter}.PixelsPerInch.X);
      liBottom := dm(FCurPrinter{RMPrinter}.PageGutters.Bottom, FCurPrinter{RMPrinter}.PixelsPerInch.Y);

      if (FPageSetting.MarginLeft < liLeft) or (FPageSetting.MarginTop < liTop) or
        (FPageSetting.MarginRight < liRight) or (FPageSetting.MarginBottom < liBottom) then
      begin
        if ((FPageSetting.MarginLeft - liLeft) < 0.01) or ((FPageSetting.MarginTop - liTop) < 0.01) or
          ((FPageSetting.MarginRight - liRight) < 0.01) or ((FPageSetting.MarginBottom - liBottom) < 0.01) then
        begin
          if Application.MessageBox(PChar(RMLoadStr(rmRes + 213)), PChar(RMLoadStr(SWarning)),
            MB_ICONEXCLAMATION + MB_YESNO) = IDYES then
          begin
            if FPageSetting.MarginLeft < liLeft then
              FPageSetting.MarginLeft := liLeft + 2.5;
            if FPageSetting.MarginTop < liTop then
              FPageSetting.MarginTop := liTop + 2.5;
            if FPageSetting.MarginRight < liRight then
              FPageSetting.MarginRight := liRight + 2.5;
            if FPageSetting.MarginBottom < liBottom then
              FPageSetting.MarginBottom := liBottom + 2.5;
          end;
        end;
      end;
    except
    end;
  end;
end;

procedure TRMPageSetupForm.edtTitleExit(Sender: TObject);
begin
  if ActiveControl <> btnCancel then
    FPageSetting.Title := edtTitle.Text;
end;

procedure TRMPageSetupForm.FormDestroy(Sender: TObject);
begin
  FPageSetting.Free;
end;

procedure TRMPageSetupForm.lstBinNamesClick(Sender: TObject);
begin
  if lstBinNames.ItemIndex >= 0 then
    FPageSetting.PageBin := FPrinterInfo.Bins[lstBinNames.ItemIndex];
end;

procedure TRMPageSetupForm.btnOKClick(Sender: TObject);
begin
  FPageSetting.PrintToPrevPage := chkPrintToPrevPage.Checked;
  FPageSetting.DoublePass := chkDoublePass.Checked;
  FPageSetting.PrintBackGroundPicture := chkTaoda.Checked;
  FPageSetting.ColorPrint := chkColorPrint.Checked;
  FPageSetting.NewPageAfterPrint := chkNewPage.Checked;
  FPageSetting.ConvertNulls := chkConvertNulls.Checked;
  FPageSetting.UnlimitedHeight := chkUnlimitedHeight.Checked;

  FPageSetting.MarginLeft := FSpinMarginLeft.Value * 10;
  FPageSetting.MarginTop := FSpinMarginTop.Value * 10;
  FPageSetting.MarginRight := FSpinMarginRight.Value * 10;
  FPageSetting.MarginBottom := FSpinMarginBottom.Value * 10;

  FPageSetting.ColCount := FSpinColCount.AsInteger;
  FPageSetting.ColGap := FSpinColGap.Value * 10;
end;

procedure TRMPageSetupForm.Init;
begin
  chkPrintToPrevPage.Checked := FPageSetting.PrintToPrevPage;
  chkDoublePass.Checked := FPageSetting.DoublePass;
  chkUnlimitedHeight.Checked := FPageSetting.UnlimitedHeight;
  chkTaoda.Checked := FPageSetting.PrintBackGroundPicture;
  chkColorPrint.Checked := FPageSetting.ColorPrint;
  chkNewPage.Checked := FPageSetting.NewPageAfterPrint;
  chkConvertNulls.Checked := FPageSetting.ConvertNulls;

  FSpinColCount.Value := FPageSetting.ColCount;
  FSpinColGap.Value := FPageSetting.ColGap / 10;

  FSpinMarginTop.Value := FPageSetting.MarginTop / 10;
  FSpinMarginBottom.Value := FPageSetting.MarginBottom / 10;
  FSpinMarginLeft.Value := FPageSetting.MarginLeft / 10;
  FSpinMarginRight.Value := FPageSetting.MarginRight / 10;
end;

end.

