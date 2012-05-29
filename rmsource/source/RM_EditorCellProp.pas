
unit RM_EditorCellProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, RM_Common, RM_Class, RM_Ctrls, RM_DsgCtrls, Buttons;

type

  TRMFrameMsg = record
    FrameVisible: Boolean;
    FrameStyle: TPenStyle;
    FrameWidth: Double;
    FrameColor: TColor;
    FrameDouble: Boolean;
  end;

  TRMCellPropForm = class(TForm)
    PageCtlCellProp: TPageControl;
    TabSheetCellType: TTabSheet;
    TabSheetAlign: TTabSheet;
    TabSheetFont: TTabSheet;
    BtnOk: TButton;
    BtnCancel: TButton;
    LabelAlign: TLabel;
    BevelAlign: TBevel;
    LabelFontName: TLabel;
    LabelHAlign: TLabel;
    LabelVAlign: TLabel;
    cmbHAlign: TComboBox;
    cmbVAlign: TComboBox;
    LabelControl: TLabel;
    BevelControl: TBevel;
    ChkBoxAutoWordBreak: TCheckBox;
    LabelFontStyle: TLabel;
    LabelFontSize: TLabel;
    lstFontName: TListBox;
    lstFontStyle: TListBox;
    lstFontSize: TListBox;
    LabelFontColor: TLabel;
    GbxFontPreview: TGroupBox;
    PanelFontPreview2: TPanel;
    PanelFontPreview1: TPanel;
    LabelIntro1: TLabel;
    PanelFontColor: TPanel;
    BtnSetFontColor: TButton;
    EditFontSize: TEdit;
    ColorDialogCellProp: TColorDialog;
    lstFormatFolder: TListBox;
    Label1: TLabel;
    edtFormatDec: TEdit;
    edtForamtStr: TEdit;
    Label2: TLabel;
    edtFormatSpl: TEdit;
    lstFormatType: TListBox;
    Label3: TLabel;
    TabSheet1: TTabSheet;
    btnBorderTop: TSpeedButton;
    btnBorderHInternal: TSpeedButton;
    btnBorderBottom: TSpeedButton;
    btnBorderLeft: TSpeedButton;
    btnBorderVInternal: TSpeedButton;
    btnBorderRight: TSpeedButton;
    btnBorderAll: TSpeedButton;
    btnBorderInside: TSpeedButton;
    btnBorderFrame: TSpeedButton;
    btnBorderNoFrame: TSpeedButton;
    BorderPanel: TPanel;
    BordersBox: TPaintBox;
    EDLeftStyle: TComboBox;
    chkDoubleLeft: TCheckBox;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstFontStyleClick(Sender: TObject);
    procedure lstFontSizeClick(Sender: TObject);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure lstFontNameClick(Sender: TObject);
    procedure BtnSetFontColorClick(Sender: TObject);
    procedure cmbHAlignClick(Sender: TObject);
    procedure cmbVAlignClick(Sender: TObject);
    procedure lstFormatFolderClick(Sender: TObject);
    procedure lstFormatTypeClick(Sender: TObject);
    procedure edtFormatSplEnter(Sender: TObject);
    procedure EditFontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure lstFontNameDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure btnBorderFrameClick(Sender: TObject);
    procedure btnBorderNoFrameClick(Sender: TObject);
    procedure EDLeftStyleDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnBorderInsideClick(Sender: TObject);
    procedure btnBorderAllClick(Sender: TObject);
    procedure btnBorderTopClick(Sender: TObject);
    procedure BordersBoxPaint(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCellRange: TRect;
    FDisplayFormat: TRMFormat;
    FDisplayFormatStr: string;
    FTrueTypeBMP: TBitmap;
    FDeviceBMP: TBitmap;
    FBusy: Boolean;

    FCmbFrameWidth: TComboBox;
    FBtnFrameColor: TRMColorPickerButton;
    FFrameMsgs: array[1..6] of TRMFrameMsg;
    FFrameButtons: array[1..6] of TSpeedButton;
    FFrameChanged: Boolean;

    procedure Localize;
    procedure GetFirstCellProp;
    procedure SetControlState;
    procedure ShowFormatPanels;
    procedure ShowBorderSample;
    procedure SetFrameMsg(aMsgs: array of Integer);
  public
    ParentGrid: Pointer;
  end;

implementation

{$R *.DFM}

uses RM_Grid, RM_Const, RM_Const1, RM_Utils;

const
  CategCount = 5;

type
  THackMemoView = class(TRMCustomMemoView)
  end;

function EnumFontsProc(var EnumLogFont: TEnumLogFont; var TextMetric: TNewTextMetric;
  FontType: Integer; Data: LPARAM): Integer; export; stdcall;
var
  FaceName: string;
begin
  FaceName := StrPas(EnumLogFont.elfLogFont.lfFaceName);
  with TListBox(Data) do
  begin
    if (Items.IndexOf(FaceName) < 0) and
      (FontType and TRUETYPE_FONTTYPE = TRUETYPE_FONTTYPE) then
    begin
      Items.AddObject(FaceName, TObject(FontType));
    end;
  end;
  Result := 1;
end;

procedure TRMCellPropForm.Localize;
var
  i, liOffset: Integer;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(TabSheetCellType, 'Caption', rmRes + 675);
  RMSetStrProp(Label1, 'Caption', rmRes + 422);
  RMSetStrProp(Label2, 'Caption', rmRes + 423);
  RMSetStrProp(Label3, 'Caption', rmRes + 424);

  RMSetStrProp(TabSheetAlign, 'Caption', rmRes + 676);
  cmbHAlign.Items.Clear;
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 107));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 109));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 108));
  cmbHAlign.Items.Add(RMLoadStr(rmRes + 114));
  cmbVAlign.Items.Clear;
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 112));
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 111));
  cmbVAlign.Items.Add(RMLoadStr(rmRes + 113));
  RMSetStrProp(LabelHAlign, 'Caption', rmRes + 678);
  RMSetStrProp(LabelVAlign, 'Caption', rmRes + 679);
  RMSetStrProp(LabelAlign, 'Caption', rmRes + 680);
  RMSetStrProp(LabelControl, 'Caption', rmRes + 681);
  RMSetStrProp(ChkBoxAutoWordBreak, 'Caption', rmRes + 682);

  RMSetStrProp(TabSheetFont, 'Caption', rmRes + 522);
  RMSetStrProp(LabelFontName, 'Caption', rmRes + 522);
  RMSetStrProp(LabelFontStyle, 'Caption', rmRes + 683);
  RMSetStrProp(LabelFontSize, 'Caption', rmRes + 684);
  RMSetStrProp(LabelFontColor, 'Caption', rmRes + 685);
  RMSetStrProp(GbxFontPreview, 'Caption', rmRes + 196);
  if RMIsChineseGB then
    liOffset := 0
  else
    liOffset := 13;
  for i := Low(RMDefaultFontSizeStr) + liOffset to High(RMDefaultFontSizeStr) do
    lstFontSize.Items.Add(RMDefaultFontSizeStr[i]);
  lstFontStyle.Items.Clear;
  lstFontStyle.Items.Add(RMLoadStr(rmRes + 686));
  lstFontStyle.Items.Add(RMLoadStr(rmRes + 687));
  lstFontStyle.Items.Add(RMLoadStr(rmRes + 688));
  lstFontStyle.Items.Add(RMLoadStr(rmRes + 689));

  RMSetStrProp(TabSheet1, 'Caption', rmRes + 677);
  RMSetStrProp(chkDoubleLeft, 'Caption', rmRes + 864);
  RMSetStrProp(Label4, 'Caption', rmRes + 865);

	RMSetStrProp(Self, 'Caption', rmRes + 929);
  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMCellPropForm.GetFirstCellProp;
var
  i, j: Integer;
  liFound: Boolean;
  liCell: TRMCellInfo;
  t: TRMView;
begin
  liFound := False; t := nil;
  for i := FCellRange.Top to FCellRange.Bottom do
  begin
    j := FCellRange.Left;
    liFound := False;
    while j <= FCellRange.Right do
    begin
      liCell := TRMGridEx(ParentGrid).Cells[j, i];
      if liCell.StartRow = i then
      begin
        if liCell.View is TRMCustomMemoView then
        begin
          t := liCell.View;
          FDisplayFormat := THackMemoView(liCell.View).FormatFlag;
          FDisplayFormatStr := TRMCustomMemoView(liCell.View).DisplayFormat;
          liFound := True;
          Break;
        end;
      end;
      j := liCell.EndCol + 1;
    end;

    if liFound then
      Break;
  end;

  // Format
  lstFormatFolder.Items.Clear;
  for i := 0 to CategCount - 1 do
    lstFormatFolder.Items.Add(RMLoadStr(SCateg1 + i));
  lstFormatFolder.ItemIndex := FDisplayFormat.FormatIndex1;
  if lstFormatFolder.ItemIndex < 0 then lstFormatFolder.ItemIndex := 0;
  lstFormatFolderClick(nil);
  lstFormatType.ItemIndex := FDisplayFormat.FormatIndex2;
  if lstFormatType.ItemIndex < 0 then lstFormatType.ItemIndex := 0;
  lstFormatTypeClick(nil);

  // Layout
  if liFound then
  begin
    cmbHAlign.ItemIndex := Byte(TRMCustomMemoView(t).HAlign);
    cmbVAlign.ItemIndex := Byte(TRMCustomMemoView(t).VAlign);
    ChkBoxAutoWordBreak.Checked := THackMemoView(t).Wordwrap;
  end
  else
  begin
    cmbHAlign.ItemIndex := 0;
    cmbVAlign.ItemIndex := 0;
    ChkBoxAutoWordBreak.Checked := False;
  end;

  // Font
  if liFound then
  begin
    lstFontName.ItemIndex := lstFontName.Items.IndexOf(TRMCustomMemoView(t).Font.Name);
    if TRMCustomMemoView(t).Font.Style = [] then
      lstFontStyle.ItemIndex := 0
    else if TRMCustomMemoView(t).Font.Style = [fsItalic] then
      lstFontStyle.ItemIndex := 1
    else if TRMCustomMemoView(t).Font.Style = [fsBold] then
      lstFontStyle.ItemIndex := 2
    else if TRMCustomMemoView(t).Font.Style = [fsBold, fsItalic] then
      lstFontStyle.ItemIndex := 3
    else
      lstFontStyle.ItemIndex := 0;

    PanelFontColor.Color := TRMCustomMemoView(t).Font.Color;
    lstFontStyle.ItemIndex := 0;
    RMSetFontSize1(TListBox(lstFontSize), TRMCustomMemoView(t).Font.Size);
    PanelFontPreview1.Font.Assign(TRMCustomMemoView(t).Font);
  end
  else
  begin
    lstFontName.ItemIndex := 0;
    PanelFontColor.Color := clBlack;
    lstFontStyle.ItemIndex := 0;
    lstFontSize.ItemIndex := 0;
    PanelFontPreview1.Font.Name := lstFontName.Items[0];
    PanelFontPreview1.Font.Color := clBlack;
    PanelFontPreview1.Font.Style := [];
    PanelFontPreview1.Font.Size := RMGetFontSize1(lstFontSize.ItemIndex, lstFontSize.Items[lstFontSize.ItemIndex]);
  end;

  // Frame
  FFrameChanged := False;
  for i := 1 to 6 do
  begin
    FFrameMsgs[i].FrameStyle := psSolid;
    FFrameMsgs[i].FrameWidth := 1;
    FFrameMsgs[i].FrameColor := clBlack;
    FFrameMsgs[i].FrameDouble := False;
    FFrameMsgs[i].FrameVisible := False;
  end;
  FFrameButtons[1] := btnBorderTop;
  FFrameButtons[2] := btnBorderHInternal;
  FFrameButtons[3] := btnBorderBottom;
  FFrameButtons[4] := btnBorderLeft;
  FFrameButtons[5] := btnBorderVInternal;
  FFrameButtons[6] := btnBorderRight;

  FCmbFrameWidth.Text := '1';
  EDLeftStyle.ItemIndex := 0;
end;

procedure TRMCellPropForm.SetControlState;
var
  i, j: Integer;
  liCell: TRMCellInfo;

  procedure _SetOneCell;
  begin
    // Format;
    if liCell.View is TRMCustomMemoView then
    begin
      THackMemoView(liCell.View).FormatFlag := FDisplayFormat;
      THackMemoView(liCell.View).FDisplayFormat := FDisplayFormatStr;
    end;

    // Layout
    liCell.HAlign := TRMHAlign(cmbHAlign.ItemIndex);
    liCell.VAlign := TRMVAlign(cmbVAlign.ItemIndex);
    if liCell.View is TRMCustomMemoView then
    begin
      THackMemoView(liCell.View).Wordwrap := ChkBoxAutoWordBreak.Checked;
    end;

    // Font
    liCell.Font.Assign(PanelFontPreview1.Font);

    // Border
    if FFrameChanged then
    begin
      if liCell.StartRow = FCellRange.Top then
      begin
        liCell.View.TopFrame.Visible := FFrameMsgs[1].FrameVisible;
        liCell.View.TopFrame.Color := FFrameMsgs[1].FrameColor;
        liCell.View.TopFrame.mmWidth := RMToMMThousandths(FFrameMsgs[1].FrameWidth, rmutScreenPixels);
        liCell.View.TopFrame.Style := FFrameMsgs[1].FrameStyle;
        liCell.View.TopFrame.DoubleFrame := FFrameMsgs[1].FrameDouble;
      end
      else
      begin
        liCell.View.TopFrame.Visible := FFrameMsgs[2].FrameVisible;
        liCell.View.TopFrame.Color := FFrameMsgs[2].FrameColor;
        liCell.View.TopFrame.mmWidth := RMToMMThousandths(FFrameMsgs[2].FrameWidth, rmutScreenPixels);
        liCell.View.TopFrame.Style := FFrameMsgs[2].FrameStyle;
        liCell.View.TopFrame.DoubleFrame := FFrameMsgs[2].FrameDouble;
      end;

      if liCell.EndRow = FCellRange.Bottom then
      begin
        liCell.View.BottomFrame.Visible := FFrameMsgs[3].FrameVisible;
        liCell.View.BottomFrame.Color := FFrameMsgs[3].FrameColor;
        liCell.View.BottomFrame.mmWidth := RMToMMThousandths(FFrameMsgs[3].FrameWidth, rmutScreenPixels);
        liCell.View.BottomFrame.Style := FFrameMsgs[3].FrameStyle;
        liCell.View.BottomFrame.DoubleFrame := FFrameMsgs[3].FrameDouble;
      end
      else
      begin
        liCell.View.BottomFrame.Visible := FFrameMsgs[2].FrameVisible;
        liCell.View.BottomFrame.Color := FFrameMsgs[2].FrameColor;
        liCell.View.BottomFrame.mmWidth := RMToMMThousandths(FFrameMsgs[2].FrameWidth, rmutScreenPixels);
        liCell.View.BottomFrame.Style := FFrameMsgs[2].FrameStyle;
        liCell.View.BottomFrame.DoubleFrame := FFrameMsgs[2].FrameDouble;
      end;

      if liCell.StartCol = FCellRange.Left then
      begin
        liCell.View.LeftFrame.Visible := FFrameMsgs[4].FrameVisible;
        liCell.View.LeftFrame.Color := FFrameMsgs[4].FrameColor;
        liCell.View.LeftFrame.mmWidth := RMToMMThousandths(FFrameMsgs[4].FrameWidth, rmutScreenPixels);
        liCell.View.LeftFrame.Style := FFrameMsgs[4].FrameStyle;
        liCell.View.LeftFrame.DoubleFrame := FFrameMsgs[4].FrameDouble;
      end
      else
      begin
        liCell.View.LeftFrame.Visible := FFrameMsgs[5].FrameVisible;
        liCell.View.LeftFrame.Color := FFrameMsgs[5].FrameColor;
        liCell.View.LeftFrame.mmWidth := RMToMMThousandths(FFrameMsgs[5].FrameWidth, rmutScreenPixels);
        liCell.View.LeftFrame.Style := FFrameMsgs[5].FrameStyle;
        liCell.View.LeftFrame.DoubleFrame := FFrameMsgs[5].FrameDouble;
      end;

      if liCell.EndCol = FCellRange.Right then
      begin
        liCell.View.RightFrame.Visible := FFrameMsgs[6].FrameVisible;
        liCell.View.RightFrame.Color := FFrameMsgs[6].FrameColor;
        liCell.View.RightFrame.mmWidth := RMToMMThousandths(FFrameMsgs[6].FrameWidth, rmutScreenPixels);
        liCell.View.RightFrame.Style := FFrameMsgs[6].FrameStyle;
        liCell.View.RightFrame.DoubleFrame := FFrameMsgs[6].FrameDouble;
      end
      else
      begin
        liCell.View.RightFrame.Visible := FFrameMsgs[5].FrameVisible;
        liCell.View.RightFrame.Color := FFrameMsgs[5].FrameColor;
        liCell.View.RightFrame.mmWidth := RMToMMThousandths(FFrameMsgs[5].FrameWidth, rmutScreenPixels);
        liCell.View.RightFrame.Style := FFrameMsgs[5].FrameStyle;
        liCell.View.RightFrame.DoubleFrame := FFrameMsgs[5].FrameDouble;
      end;
    end;
  end;

begin
  // Format
  FDisplayFormat.FormatIndex1 := lstFormatFolder.ItemIndex;
  FDisplayFormat.FormatIndex2 := lstFormatType.ItemIndex;
  FDisplayFormat.FormatPercent := StrToIntDef(edtFormatDec.Text, 0);
  if edtFormatSpl.Text <> '' then
    FDisplayFormat.FormatdelimiterChar := edtFormatSpl.Text[1]
  else
    FDisplayFormat.FormatdelimiterChar := ',';
  if edtForamtStr.Enabled then
    FDisplayFormatStr := edtForamtStr.Text;

  for i := FCellRange.Top to FCellRange.Bottom do
  begin
    j := FCellRange.Left;
    while j <= FCellRange.Right do
    begin
      liCell := TRMGridEx(ParentGrid).Cells[j, i];
      if liCell.StartRow = i then
      begin
        _SetOneCell;
      end;
      j := liCell.EndCol + 1;
    end;
  end;
end;

procedure TRMCellPropForm.FormShow(Sender: TObject);
var
  liDC: HDC;
begin
  liDC := GetDC(0);
  try
    EnumFontFamilies(RMDesigner.Report.ReportPrinter.DC, nil, @EnumFontsProc, Longint(lstFontName));
  finally
    ReleaseDC(0, liDC);
  end;

  Localize;
  FCellRange := TRect(TRMGridEx(ParentGrid).Selection);
  GetFirstCellProp;
end;

procedure TRMCellPropForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  PageCtlCellProp.ActivePage := TabSheetCellType;
  FTrueTypeBMP := RMCreateBitmap('RM_TRUETYPE_FNT');
  FDeviceBMP := RMCreateBitmap('RM_DEVICE_FNT');

  for i := 0 to Integer(High(TPenStyle)) - 2 do
  begin
    EDLeftStyle.Items.Add('');
  end;

  FCmbFrameWidth := TComboBox.Create(Self);
  with FCmbFrameWidth do
  begin
    Parent := TabSheet1;
    DropDownCount := 14;
    SetBounds(200, 68, 119, 21);
    Items.Add('0.1');
    Items.Add('0.5');
    Items.Add('1');
    Items.Add('1.5');
    for i := 2 to 9 do
      Items.Add(IntToStr(i));
  end;

  FBtnFrameColor := TRMColorPickerButton.Create(Self);
  with FBtnFrameColor do
  begin
    Parent := TabSheet1;
    Flat := False;
    SetBounds(200, 92, 119, 21);
//    Caption := RMLoadStr(rmRes + 523);
    ColorType := rmptLine;
//    OnColorChange := OnColorChangeEvent;
  end;

  FBusy := False;
end;

procedure TRMCellPropForm.FormDestroy(Sender: TObject);
begin
  FTrueTypeBmp.Free;
  FDeviceBmp.Free;
end;

procedure TRMCellPropForm.lstFontNameClick(Sender: TObject);
begin
  PanelFontPreview1.Font.Name := lstFontName.Items[lstFontName.ItemIndex];
  PanelFontPreview1.Caption := PanelFontPreview1.Font.Name;
  if RMIsChineseGB then
  begin
    if ByteType(PanelFontPreview1.Font.Name, 1) = mbSingleByte then
      PanelFontPreview1.Font.Charset := ANSI_CHARSET
    else
      PanelFontPreview1.Font.Charset := GB2312_CHARSET;
  end;
end;

procedure TRMCellPropForm.lstFontStyleClick(Sender: TObject);
begin
  case lstFontStyle.ItemIndex of
    0: PanelFontPreview1.Font.Style := [];
    1: PanelFontPreview1.Font.Style := [fsItalic];
    2: PanelFontPreview1.Font.Style := [fsBold];
    3: PanelFontPreview1.Font.Style := [fsBold, fsItalic];
  end;
end;

procedure TRMCellPropForm.lstFontSizeClick(Sender: TObject);
begin
  EditFontSize.Text := lstFontSize.Items[lstFontSize.ItemIndex];
  PanelFontPreview1.Font.Size := RMGetFontSize1(lstFontSize.ItemIndex, lstFontSize.Items[lstFontSize.ItemIndex]);
end;

procedure TRMCellPropForm.UpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  TEdit((Sender as TUpDown).Associate).Enabled := True;
end;

procedure TRMCellPropForm.BtnSetFontColorClick(Sender: TObject);
begin
  if ColorDialogCellProp.Execute then
  begin
    PanelFontPreview1.Font.Color := ColorDialogCellProp.Color;
    PanelFontColor.Color := ColorDialogCellProp.Color;
    PanelFontColor.Visible := True;
  end;
end;

procedure TRMCellPropForm.cmbHAlignClick(Sender: TObject);
begin
  if cmbVAlign.ItemIndex < 0 then
    cmbVAlign.ItemIndex := 0;
end;

procedure TRMCellPropForm.cmbVAlignClick(Sender: TObject);
begin
  if cmbHAlign.ItemIndex < 0 then
    cmbHAlign.ItemIndex := 0;
end;

procedure TRMCellPropForm.SetFrameMsg(aMsgs: array of Integer);
var
  i: Integer;
begin
  for i := Low(aMsgs) to High(aMsgs) do
  begin
    FFrameMsgs[aMsgs[i]].FrameStyle := TPenStyle(EDLeftStyle.ItemIndex);
    FFrameMsgs[aMsgs[i]].FrameWidth := StrToFloat(FCmbFrameWidth.Text);
    FFrameMsgs[aMsgs[i]].FrameColor := FBtnFrameColor.CurrentColor;
    FFrameMsgs[aMsgs[i]].FrameDouble := chkDoubleLeft.Checked;
    FFrameMsgs[aMsgs[i]].FrameVisible := FFrameButtons[aMsgs[i]].Down;
  end;
end;

procedure TRMCellPropForm.ShowBorderSample;
begin
  BordersBox.Invalidate;
end;

{$WARNINGS OFF}

procedure TRMCellPropForm.ShowFormatPanels;
begin
  RMEnableControls([Label1, Label2, edtFormatDec, edtFormatSpl], (lstFormatFolder.ItemIndex = 1) and (lstFormatType.ItemIndex <> lstFormatType.Items.Count - 1));
  if edtFormatDec.Enabled then
  begin
    edtFormatDec.Text := IntToStr(FDisplayFormat.FormatPercent);
    edtFormatSpl.Text := FDisplayFormat.FormatdelimiterChar;
  end
  else
  begin
    edtFormatDec.Text := '';
    edtFormatSpl.Text := '';
  end;

  RMEnableControls([Label3, edtForamtStr], lstFormatType.ItemIndex = lstFormatType.Items.Count - 1);
  if edtForamtStr.Enabled then
    edtForamtStr.Text := FDisplayFormatStr
  else
    edtForamtStr.Text := '';
end;

{$WARNINGS ON}

procedure TRMCellPropForm.lstFormatFolderClick(Sender: TObject);
var
  i: Integer;
begin
  lstFormatType.Items.Clear;
  case lstFormatFolder.ItemIndex of
    0: // 字符型
      begin
        lstFormatType.Items.Add(RMLoadStr(SFormat11));
      end;
    1: // 数字型
      begin
        for i := 0 to RMFormatNumCount do
          lstFormatType.Items.Add(RMLoadStr(SFormat21 + i));
      end;
    2: // 日期型
      begin
        for i := 0 to RMFormatDateCount do
          lstFormatType.Items.Add(RMLoadStr(SFormat31 + i));
      end;
    3: // 时间型
      begin
        for i := 0 to RMFormatTimeCount do
          lstFormatType.Items.Add(RMLoadStr(SFormat41 + i));
      end;
    4: // 逻辑型
      begin
        for i := 0 to RMFormatBooleanCount do
          lstFormatType.Items.Add(RMLoadStr(SFormat51 + i));
      end;
  end;

  lstFormatType.ItemIndex := 0;
  lstFormatTypeClick(nil);
end;

procedure TRMCellPropForm.lstFormatTypeClick(Sender: TObject);
begin
  ShowFormatPanels;
end;

procedure TRMCellPropForm.edtFormatSplEnter(Sender: TObject);
begin
  edtFormatSpl.SelectAll;
end;

procedure TRMCellPropForm.EditFontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (integer(Key) in [$30..$39, VK_BACK, VK_INSERT, VK_END, VK_HOME]) then
    Key := #0;
end;

procedure TRMCellPropForm.lstFontNameDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TBitmap;
  BmpWidth: Integer;
  s: string;
  h: Integer;
begin
  lstFontName.Canvas.FillRect(Rect);
  BmpWidth := 15;
  if (Integer(lstFontName.Items.Objects[Index]) and TRUETYPE_FONTTYPE) <> 0 then
    Bitmap := FTrueTypeBMP
  else if (Integer(lstFontName.Items.Objects[Index]) and DEVICE_FONTTYPE) <> 0 then
    Bitmap := FDeviceBMP
  else
    Bitmap := nil;
  if Bitmap <> nil then
  begin
    BmpWidth := Bitmap.Width;
    lstFontName.Canvas.BrushCopy(Bounds(Rect.Left + 2, (Rect.Top + Rect.Bottom - Bitmap.Height)
      div 2, Bitmap.Width, Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
      Bitmap.Height), Bitmap.TransparentColor);
  end;

  Rect.Left := Rect.Left + BmpWidth + 6;
  s := lstFontName.Items[index];
  h := lstFontName.Canvas.TextHeight(s);
  lstFontName.Canvas.TextOut(Rect.Left, Rect.Top + (Rect.Bottom - Rect.Top - h) div 2, s);
end;

procedure TRMCellPropForm.btnBorderFrameClick(Sender: TObject);
begin
  FFrameChanged := True;
  btnBorderTop.Down := True;
  btnBorderBottom.Down := True;
  btnBorderLeft.Down := True;
  btnBorderRight.Down := True;
  SetFrameMsg([1, 3, 4, 6]);
  ShowBorderSample;
end;

procedure TRMCellPropForm.btnBorderNoFrameClick(Sender: TObject);
begin
  FFrameChanged := True;
  btnBorderTop.Down := False;
  btnBorderBottom.Down := False;
  btnBorderVInternal.Down := False;
  btnBorderLeft.Down := False;
  btnBorderRight.Down := False;
  btnBorderHInternal.Down := False;
  SetFrameMsg([1, 2, 3, 4, 5, 6]);
  ShowBorderSample;
end;

procedure TRMCellPropForm.EDLeftStyleDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  LineWidth = 4;
var
  i: integer;
begin
  with TComboBox(Control).Canvas do
  begin
    Pen.Color := clBlack;
    Pen.Style := TPenStyle(index);
    Brush.Color := clWhite;
    FillRect(Rect);

    i := Rect.Top + (Rect.Bottom - Rect.Top - LineWidth) div 2;
    for i := i to i + LineWidth - 1 do
    begin
      MoveTo(Rect.Left + 3, i);
      LineTo(Rect.Right - 3, i);
    end;
  end;
end;

procedure TRMCellPropForm.btnBorderInsideClick(Sender: TObject);
begin
  FFrameChanged := True;
  btnBorderHInternal.Down := True;
  btnBorderVInternal.Down := True;
  SetFrameMsg([2, 5]);
  ShowBorderSample;
end;

procedure TRMCellPropForm.btnBorderAllClick(Sender: TObject);
begin
  FFrameChanged := True;
  btnBorderTop.Down := True;
  btnBorderBottom.Down := True;
  btnBorderVInternal.Down := True;
  btnBorderLeft.Down := True;
  btnBorderRight.Down := True;
  btnBorderHInternal.Down := True;
  SetFrameMsg([1, 2, 3, 4, 5, 6]);
  ShowBorderSample;
end;

procedure TRMCellPropForm.btnBorderTopClick(Sender: TObject);
begin
  FFrameChanged := True;
  SetFrameMsg([TSpeedButton(Sender).Tag]);
  ShowBorderSample;
end;

const
  con_margin = 5;

const
  PenStyles: array[psSolid..psInsideFrame] of DWORD =
  (PS_SOLID, PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT, PS_NULL, PS_INSIDEFRAME);

procedure TRMCellPropForm.BordersBoxPaint(Sender: TObject);
var
  i: Integer;
  tb: {$IFDEF COMPILER4_UP}tagLOGBRUSH{$ELSE}TLogBrush{$ENDIF};
  NewH, OldH: HGDIOBJ;

  procedure _SetPS(aColor: TColor; aStyle: TPenStyle; aWidth: integer);
  begin
    tb.lbStyle := BS_SOLID;
    tb.lbColor := aColor;
    NewH := ExtCreatePen(PS_GEOMETRIC + PS_ENDCAP_SQUARE + PenStyles[aStyle], aWidth, tb, 0, nil);
    OldH := SelectObject(BordersBox.Canvas.Handle, NewH);
  end;

begin
  if FBusy then Exit;

  FBusy := True;
  for i := 1 to 6 do
  begin
    if not FFrameMsgs[i].FrameVisible then Continue;

    _SetPS(FFrameMsgs[i].FrameColor, FFrameMsgs[i].FrameStyle, Round(FFrameMsgs[i].FrameWidth));
    case i of
      1:
        begin
          MoveToEx(BordersBox.Canvas.Handle, con_margin, con_margin, nil);
          LineTo(BordersBox.Canvas.Handle, BordersBox.Width - con_margin, con_margin);
        end;
      2:
        begin
          MoveToEx(BordersBox.Canvas.Handle, con_margin, BordersBox.Height div 2, nil);
          LineTo(BordersBox.Canvas.Handle, BordersBox.Width - con_margin, BordersBox.Height div 2);
        end;
      3:
        begin
          MoveToEx(BordersBox.Canvas.Handle, con_margin, BordersBox.Height - con_margin, nil);
          LineTo(BordersBox.Canvas.Handle, BordersBox.Width - con_margin, BordersBox.Height - con_margin);
        end;
      4:
        begin
          MoveToEx(BordersBox.Canvas.Handle, con_margin, con_margin, nil);
          LineTo(BordersBox.Canvas.Handle, con_margin, BordersBox.Height - con_margin);
        end;
      5:
        begin
          MoveToEx(BordersBox.Canvas.Handle, BordersBox.Width div 2, con_margin, nil);
          LineTo(BordersBox.Canvas.Handle, BordersBox.Width div 2, BordersBox.Height - con_margin);
        end;
      6:
        begin
          MoveToEx(BordersBox.Canvas.Handle, BordersBox.Width - con_margin, con_margin, nil);
          LineTo(BordersBox.Canvas.Handle, BordersBox.Width - con_margin, BordersBox.Height - con_margin);
        end;
    end;

    SelectObject(BordersBox.Canvas.Handle, OldH);
    DeleteObject(NewH);
  end;

  FBusy := False;
end;

procedure TRMCellPropForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
    SetControlState;
end;

end.

