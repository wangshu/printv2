
{******************************************}
{                                          }
{           Report Machine v2.0            }
{              Print dialog                }
{                                          }
{                                          }
{******************************************}

unit RM_PrintDlg;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, WinSpool, RM_Ctrls, RM_Printer;

type
  TRMPrintDialogForm = class(TForm)
    GroupBox2: TGroupBox;
    rdbPrintAll: TRadioButton;
    rbdPrintCurPage: TRadioButton;
    rbdPrintPapges: TRadioButton;
    edtPages: TEdit;
    Label2: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    cmbPrinters: TComboBox;
    btnPrinterProp: TButton;
    GroupBox3: TGroupBox;
    lblCopies: TLabel;
    chkCollate: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    cmbPrintAll: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    imgCollate: TImage;
    lblStatus: TLabel;
    lblType: TLabel;
    lblPosition: TLabel;
    lblCommon: TLabel;
    Image3: TImage;
    Image2: TImage;
    chkTaoda: TCheckBox;
    GroupBox4: TGroupBox;
    Label3: TLabel;
    cmbScalePapers: TComboBox;
    lblScale: TLabel;
    GroupBox5: TGroupBox;
    lblPrnOffsetTop: TLabel;
    lbllblPrnOffsetLeft: TLabel;
    chkColorPrint: TCheckBox;
    procedure cmbPrintersDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure btnPrinterPropClick(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure rbdPrintPapgesClick(Sender: TObject);
    procedure chkCollateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbPrintersChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FOldIndex: Integer;
    FScale: TRMSpinEdit;
    FSpinOffsetTop, FSpinOffsetLeft: TRMSpinEdit;
    FPrintOffsetTop, FPrintOffsetLeft: Integer;
    FSpinCopies: TRMSpinEdit;

    procedure SpinOffsetTopChangeEvent(Sender: TObject);
    procedure Localize;
    procedure UpdateCollationSettings;
    procedure UpdatePrinterSettings;
    procedure FillScalePapers;
    function GetScale: Integer;
    function GetCopies: Integer;
    procedure SetCopies(Value: Integer);
  public
    { Public declarations }
    NeedRebuild: Boolean;
    CurrentPrinter: TRMPrinter;

    procedure GetPageInfo(var aPaperWidth, aPaperHeight, apgSize: Integer);
    procedure ChangeVirtualPrinter;
    property ScaleFactor: Integer read GetScale;
    property PrintOffsetTop: Integer read FPrintOffsetTop write FPrintOffsetTop;
    property PrintOffsetLeft: Integer read FPrintOffsetLeft write FPrintOffsetLeft;
    property Copies: Integer read GetCopies write SetCopies;
  end;

implementation

{$R *.DFM}

uses RM_Const, RM_Common, RM_Utils, RM_Class;

procedure TRMPrintDialogForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 040);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 041);
  RMSetStrProp(btnPrinterProp, 'Caption', rmRes + 042);
  RMSetStrProp(GroupBox3, 'Caption', rmRes + 043);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 044);
  RMSetStrProp(rdbPrintAll, 'Caption', rmRes + 045);
  RMSetStrProp(rbdPrintCurPage, 'Caption', rmRes + 046);
  RMSetStrProp(rbdPrintPapges, 'Caption', rmRes + 047);
  RMSetStrProp(Label2, 'Caption', rmRes + 048);
  RMSetStrProp(Label4, 'Caption', rmRes + 049);
  RMSetStrProp(lblCopies, 'Caption', rmRes + 050);
  RMSetStrProp(chkCollate, 'Caption', rmRes + 051);
  RMSetStrProp(Label5, 'Caption', rmRes + 052);
  RMSetStrProp(Label6, 'Caption', rmRes + 56);
  RMSetStrProp(Label7, 'Caption', rmRes + 57);
  RMSetStrProp(Label8, 'Caption', rmRes + 58);
  RMSetStrProp(Label9, 'Caption', rmRes + 1831);
  RMSetStrProp(chkTaoda, 'Caption', rmRes + 375);
  RMSetStrProp(GroupBox4, 'Caption', rmRes + 1860);
  RMSetStrProp(Label3, 'Caption', rmRes + 1861);
  RMSetStrProp(lblScale, 'Caption', rmRes + 1863);
  RMSetStrProp(lblPrnOffsetTop, 'Caption', rmRes + 370);
  RMSetStrProp(lbllblPrnOffsetLeft, 'Caption', rmRes + 404);
  RMSetStrProp(GroupBox5, 'Caption', rmRes + 414);
  RMSetStrProp(chkColorPrint, 'Caption', rmRes + 369);

  cmbPrintAll.Items.Add(RMLoadStr(rmRes + 53));
  cmbPrintAll.Items.Add(RMLoadStr(rmRes + 54));
  cmbPrintAll.Items.Add(RMLoadStr(rmRes + 55));

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMPrintDialogForm.ChangeVirtualPrinter;
begin
  UpdatePrinterSettings;
//  FillScalePapers;
end;

procedure TRMPrintDialogForm.GetPageInfo(var aPaperWidth, aPaperHeight, apgSize: Integer);
var
  liPrintInfo: TRMPrinterInfo;
  liPrinterIndex: Integer;
begin
  apgSize := FScale.AsInteger;
  if cmbScalePapers.ItemIndex < 1 then
  begin
    apgSize := -1;
  end
  else
  begin
    if cmbPrinters.ItemIndex = 0 then
      liPrinterIndex := 0
    else
      liPrinterIndex := cmbPrinters.ItemIndex + 1;
    liPrintInfo := RMPrinters.PrinterInfo[liPrinterIndex];
    apgSize := liPrintInfo.PaperSizes[cmbScalePapers.ItemIndex - 1];
    aPaperWidth := liPrintInfo.PaperWidths[cmbScalePapers.ItemIndex - 1];
    aPaperHeight := liPrintInfo.PaperHeights[cmbScalePapers.ItemIndex - 1];
  end;
end;

procedure TRMPrintDialogForm.FillScalePapers;
var
  i: Integer;
  liPrintInfo: TRMPrinterInfo;
  liPrinterIndex: Integer;
begin
  cmbScalePapers.Items.Clear;
  cmbScalePapers.Items.Add(RMLoadStr(rmRes + 1862));
  if cmbPrinters.ItemIndex = 0 then
    liPrinterIndex := 0
  else
    liPrinterIndex := cmbPrinters.ItemIndex + 1;
  if liPrinterIndex >= 0 then
  begin
    liPrintInfo := RMPrinters.PrinterInfo[liPrinterIndex];
    with liPrintInfo do
    begin
      for i := 0 to PaperSizesCount - 2 do
      begin
        cmbScalePapers.Items.Add(PaperNames[i]);
      end;
    end;
  end;
  cmbScalePapers.ItemIndex := 0;
end;

procedure TRMPrintDialogForm.UpdateCollationSettings;
begin
  if (chkCollate.Checked) then
    imgCollate.Picture.Bitmap.Assign(Image2.Picture.Bitmap)
  else
    imgCollate.Picture.Bitmap.Assign(Image3.Picture.Bitmap)
end;

procedure TRMPrintDialogForm.UpdatePrinterSettings;
var
  info: PPrinterInfo2;
  pcbNeeded, count: DWORD;
  str: string;
  liPrinterIndex: Integer;
begin
  lblType.Caption := '';
  lblPosition.Caption := '';
  lblCommon.Caption := '';
  lblStatus.Caption := '';
  if cmbPrinters.ItemIndex = 0 then
    liPrinterIndex := 0
  else
    liPrinterIndex := cmbPrinters.ItemIndex + 1;
  if liPrinterIndex >= 0 then
  begin
    WinSpool.GetPrinter(CurrentPrinter.PrinterHandle, 2, nil, 0, @count);
    GetMem(info, count);
    try
      if WinSpool.GetPrinter(CurrentPrinter.PrinterHandle, 2, info, count, @pcbNeeded) then
      begin
        lblType.Caption := info^.pDriverName;
        lblPosition.Caption := info^.pPortName;
        lblCommon.Caption := info^.pComment;
        if info^.cJobs > 0 then
          str := RMLoadStr(rmRes + 1864)
        else
          str := RMLoadStr(rmRes + 1865);
        if info^.Status <> 0 then
        begin
          case info^.Status of
            PRINTER_STATUS_BUSY: str := RMLoadStr(rmRes + 1833);
            PRINTER_STATUS_DOOR_OPEN: str := RMLoadStr(rmRes + 1834);
            PRINTER_STATUS_ERROR: str := RMLoadStr(rmRes + 1835);
            PRINTER_STATUS_INITIALIZING: str := RMLoadStr(rmRes + 1836);
            PRINTER_STATUS_IO_ACTIVE: str := RMLoadStr(rmRes + 1837);
            PRINTER_STATUS_MANUAL_FEED: str := RMLoadStr(rmRes + 1838);
            PRINTER_STATUS_NO_TONER: str := RMLoadStr(rmRes + 1839);
            PRINTER_STATUS_NOT_AVAILABLE: str := RMLoadStr(rmRes + 1840);
            PRINTER_STATUS_OFFLINE: str := RMLoadStr(rmRes + 1841);
            PRINTER_STATUS_OUT_OF_MEMORY: str := RMLoadStr(rmRes + 1842);
            PRINTER_STATUS_OUTPUT_BIN_FULL: str := RMLoadStr(rmRes + 1843);
            PRINTER_STATUS_PAGE_PUNT: str := RMLoadStr(rmRes + 1844);
            PRINTER_STATUS_PAPER_JAM: str := RMLoadStr(rmRes + 18345);
            PRINTER_STATUS_PAPER_OUT: str := RMLoadStr(rmRes + 1846);
            PRINTER_STATUS_PAPER_PROBLEM: str := RMLoadStr(rmRes + 1847);
            PRINTER_STATUS_PAUSED: str := RMLoadStr(rmRes + 1848);
            PRINTER_STATUS_PENDING_DELETION: str := RMLoadStr(rmRes + 1849);
            PRINTER_STATUS_PRINTING: str := RMLoadStr(rmRes + 1850);
            PRINTER_STATUS_PROCESSING: str := RMLoadStr(rmRes + 1851);
            PRINTER_STATUS_TONER_LOW: str := RMLoadStr(rmRes + 1852);
            PRINTER_STATUS_USER_INTERVENTION: str := RMLoadStr(rmRes + 1853);
            PRINTER_STATUS_WAITING: str := RMLoadStr(rmRes + 1834);
            PRINTER_STATUS_WARMING_UP: str := RMLoadStr(rmRes + 1855);
          end;
        end;
        if info^.cJobs > 0 then
        begin
          if Length(str) > 0 then
            str := str + ':';
          str := str + Format(RMLoadStr(rmRes + 1856), [info^.cJobs]);
        end;
        lblStatus.Caption := str;
      end;
    finally
      FreeMem(info, count);
//			WinSpool.ClosePrinter(CurrentPrinter.PrinterHandle);
    end;
  end;
end;

procedure TRMPrintDialogForm.FormCreate(Sender: TObject);
begin
  NeedRebuild := False;

  FScale := TRMSpinEdit.Create(Self);
  with FScale do
  begin
    Parent := GroupBox4;
    SetBounds(cmbScalePapers.Left, lblScale.Top, cmbScalePapers.Width, 21);
    Value := 100;
    MinValue := 1;
  end;

  FSpinOffsetTop := TRMSpinEdit.Create(Self);
  with FSpinOffsetTop do
  begin
    Parent := GroupBox5;
    SetBounds(lblPrnOffsetTop.Left+lblPrnOffsetTop.Width + 2, lblPrnOffsetTop.Top,
      GroupBox5.Width- lblPrnOffsetTop.Left-lblPrnOffsetTop.Width -10, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    Tag := 1;
    OnChange := SpinOffsetTopChangeEvent;
  end;
  FSpinOffsetLeft := TRMSpinEdit.Create(Self);
  with FSpinOffsetLeft do
  begin
    Parent := GroupBox5;
    SetBounds(FSpinOffsetTop.Left, lbllblPrnOffsetLeft.Top, FSpinOffsetTop.Width, 21);
    ValueType := rmvtFloat;
    MinValue := -MaxInt;
    Increment := 0.1;
    Tag := 2;
    OnChange := SpinOffsetTopChangeEvent;
  end;

  FSpinCopies := TRMSpinEdit.Create(Self);
  with FSPinCopies do
  begin
    Parent := GroupBox3;
    SetBounds(chkCollate.Left, lblCopies.Top, 64, 21);
    MinValue := 1;
  end;

  Localize;
end;

procedure TRMPrintDialogForm.cmbPrintersDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with cmbPrinters.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clOlive);
    TextOut(ARect.Left + 24, ARect.Top + 1, cmbPrinters.Items[Index]);
  end;
end;

procedure TRMPrintDialogForm.btnPrinterPropClick(Sender: TObject);
begin
  if CurrentPrinter.PropertiesDlg then
    NeedRebuild := True;

  UpdatePrinterSettings;
end;

procedure TRMPrintDialogForm.E2Click(Sender: TObject);
begin
  rbdPrintPapges.Checked := True;
end;

procedure TRMPrintDialogForm.rbdPrintPapgesClick(Sender: TObject);
begin
  edtPages.SetFocus;
end;

procedure TRMPrintDialogForm.chkCollateClick(Sender: TObject);
begin
  UpdateCollationSettings;
end;

procedure TRMPrintDialogForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
    CurrentPrinter.PrinterIndex := FOldIndex;
end;

procedure TRMPrintDialogForm.cmbPrintersChange(Sender: TObject);
begin
  if cmbPrinters.ItemIndex = 0 then
    CurrentPrinter.PrinterIndex := cmbPrinters.ItemIndex
  else
    CurrentPrinter.PrinterIndex := cmbPrinters.ItemIndex + 1;
    
  UpdatePrinterSettings;
  FillScalePapers;
end;

procedure TRMPrintDialogForm.FormShow(Sender: TObject);
begin
  cmbPrinters.Items.Assign(RMPrinters.Printers);
  cmbPrinters.Items.Delete(1);
  FOldIndex := CurrentPrinter.PrinterIndex;
  if FOldIndex <= 1 then
    cmbPrinters.ItemIndex := 0
  else
    cmbPrinters.ItemIndex := FOldIndex - 1;
  if cmbPrinters.ItemIndex < 0 then
    cmbPrinters.ItemIndex := 0;
  chkCollateClick(nil);

  cmbPrintAll.ItemIndex := 0;
  cmbPrintAll.Left := Label5.Left + Label5.Width + 11;

  cmbScalePapers.ItemIndex := -1;

  cmbPrintersChange(nil);
  FSpinOffsetTop.Value := FPrintOffsetTop / 10000;
  FSpinOffsetLeft.Value := FPrintOffsetLeft / 10000;
end;

function TRMPrintDialogForm.GetScale: Integer;
begin
  try
    Result := FScale.AsInteger;
    if Result < 1 then
      Result := 1;
  except
    Result := 100;
  end;
end;

procedure TRMPrintDialogForm.SpinOffsetTopChangeEvent(Sender: TObject);
begin
  if TControl(Sender).Tag = 2 then
    FPrintOffsetLeft := Round(FSpinOffsetLeft.Value * 10000)
  else
    FPrintOffsetTop := Round(FSpinOffsetTop.Value * 10000);
end;

function TRMPrintDialogForm.GetCopies: Integer;
begin
  Result := FSpinCopies.AsInteger;
end;

procedure TRMPrintDialogForm.SetCopies(Value: Integer);
begin
  FSpinCopies.Value := Value;
end;

procedure TRMPrintDialogForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i: Integer;
begin
  if ModalResult = mrOK then
  begin
    edtPages.Text := Trim(edtPages.Text);
    if (Length(edtPages.Text) > 0) and (not (edtPages.Text[1] in ['1'..'9'])) then
    begin
      edtPages.SetFocus;
      CanClose := False;
    end;

    for i := 1 to Length(edtPages.Text) do
    begin
      if (not ((edtPages.Text[i] in ['0'..'9']) or (edtPages.Text[i] = ',') or (edtPages.Text[i] = '-'))) then
      begin
        Application.MessageBox('Page Number Setting Error!', PChar(SWarning), MB_ICONERROR + MB_OK);
        CanClose := False;
        edtPages.SetFocus;
        Break;
      end;
    end;
  end;
end;

end.

