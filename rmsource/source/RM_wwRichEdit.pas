
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{        wwRich Add-In Object             }
{                                         }
{*****************************************}

unit RM_wwRichEdit;

interface

{$I RM.inc}

{$IFDEF InfoPower}
uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Menus,
  Forms, Dialogs, Stdctrls, RM_Class, RM_Common, RM_Ctrls, RM_DsgCtrls, DB, Clipbrd,
  RichEdit, wwriched, ComCtrls, ToolWin, ExtCtrls
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMWWRichObject = class(TComponent) // fake component
  end;

  TRMSubscriptStyle = (rmssNone, rmssSubscript, rmssSuperscript);

 { TRMwwRichView }
  TRMWWRichView = class(TRMStretcheableView)
  private
    FStartCharPos, FEndCharPos, FSaveCharPos: Integer;
    FRichEdit, FSRichEdit: TwwDBRichEdit;
    FUseSRichEdit: Boolean;

    function SRichEdit: TwwDBRichEdit;
    procedure GetRichData(ASource: TCustomMemo);
    procedure DrawRichText(aDC: HDC; aFormatDC: HDC; const aRect: TRect; aCharRange: TCharRange);
    function FormatRange(aDC: HDC; aFormatDC: HDC; const aRect: TRect; aCharRange: TCharRange;
      aRender: Boolean): Integer;
    function DoCalcHeight: Integer;
    procedure ShowRichText(aRender: Boolean);
  protected
    procedure Prepare; override;
    procedure GetMemoVariables; override;
    function GetViewCommon: string; override;
    procedure ClearContents; override;

    function CalcHeight: Integer; override;
    function RemainHeight: Integer; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    procedure GetBlob; override;
    procedure LoadFromRichEdit(aRichEdit: TwwDBRichEdit);
    procedure DefinePopupMenu(aPopup: TRMCustomMenuItem); override;
    procedure ShowEditor; override;
  published
    property RichEdit: TwwDBRichEdit read FRichEdit;
    property GapLeft;
    property GapTop;
    property ShiftWith;
    property StretchWith;
    property TextOnly;
    property BandAlign;
    property LeftFrame;
    property RightFrame;
    property TopFrame;
    property BottomFrame;
    property FillColor;
    property PrintFrame;
    property Printable;
  end;

  { TRMwwRichForm }
  TRMwwRichForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    FontDialog: TFontDialog;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    EditPopupMenu: TPopupMenu;
    ItmCut: TMenuItem;
    ItmCopy: TMenuItem;
    ItmPaste: TMenuItem;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    ItemFileNew: TMenuItem;
    ItemFileOpen: TMenuItem;
    ItemFileSaveAs: TMenuItem;
    MenuItem5: TMenuItem;
    ItemFilePrint: TMenuItem;
    MenuItem7: TMenuItem;
    ItemFileExit: TMenuItem;
    MenuEdit: TMenuItem;
    ItemEditUndo: TMenuItem;
    MenuItem11: TMenuItem;
    ItemEditCut: TMenuItem;
    ItemEditCopy: TMenuItem;
    ItemEditPaste: TMenuItem;
    ItemFormatFont: TMenuItem;
    MenuItem16: TMenuItem;
    ItemInsertField: TMenuItem;
    MenuInsert: TMenuItem;
    MenuFormat: TMenuItem;
    ItemInserObject: TMenuItem;
    ItemInsertPicture: TMenuItem;
    ItemEditRedo: TMenuItem;
    ItemEditSelectAll: TMenuItem;
    N20: TMenuItem;
    ItemEditFind: TMenuItem;
    ItemEditFindNext: TMenuItem;
    ItemEditReplace: TMenuItem;
    PrintDialog: TPrintDialog;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    btnFileNew: TToolButton;
    btnFileOpen: TToolButton;
    btnFileSave: TToolButton;
    ToolButton4: TToolButton;
    btnFind: TToolButton;
    ToolButton6: TToolButton;
    btnCut: TToolButton;
    btnCopy: TToolButton;
    btnPaste: TToolButton;
    ToolButton10: TToolButton;
    btnUndo: TToolButton;
    btnRedo: TToolButton;
    ToolButton13: TToolButton;
    btnInsertField: TToolButton;
    ToolButton15: TToolButton;
    btnOK: TToolButton;
    btnCancel: TToolButton;
    ToolButton18: TToolButton;
    btnFontBold: TToolButton;
    btnFontItalic: TToolButton;
    btnFontUnderline: TToolButton;
    ToolButton22: TToolButton;
    ToolButton25: TToolButton;
    btnAlignLeft: TToolButton;
    btnAlignCenter: TToolButton;
    btnAlignRight: TToolButton;
    ToolButton29: TToolButton;
    btnBullets: TToolButton;
    btnJustify: TToolButton;
    ItemFormatParagraph: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RichEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditSelectAll(Sender: TObject);
    procedure btnFileNewClick(Sender: TObject);
    procedure btnFileOpenClick(Sender: TObject);
    procedure btnFileSaveClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnUndoApplyAlign(Sender: TObject; Align: TAlign;
      var Apply: Boolean);
    procedure btnRedoClick(Sender: TObject);
    procedure btnFontBoldClick(Sender: TObject);
    procedure btnFontItalicClick(Sender: TObject);
    procedure btnFontUnderlineClick(Sender: TObject);
    procedure btnAlignLeftClick(Sender: TObject);
    procedure btnBulletsClick(Sender: TObject);
    procedure ItemFileSaveAsClick(Sender: TObject);
    procedure ItemFilePrintClick(Sender: TObject);
    procedure ItemFileExitClick(Sender: TObject);
    procedure ItemFormatFontClick(Sender: TObject);
    procedure ItemInserObjectClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure ItemEditFindNextClick(Sender: TObject);
    procedure ItemEditReplaceClick(Sender: TObject);
    procedure btnInsertFieldClick(Sender: TObject);
    procedure ItemEditSelectAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnBulletsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ItemInsertPictureClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ItemFormatParagraphClick(Sender: TObject);
  private
    tempDown: boolean;
    FUpdating: Boolean;
    FFileName: string;
    FcmbFont: TRMFontComboBox;
    FcmbFontSize: TComboBox;
    FOpenPictureDialog: TOpenDialog;
    FRuler: TRMRuler;
    FBtnFontColor: TRMColorPickerButton;
    FBtnBackColor: TRMColorPickerButton;

    procedure SetFileName(const FileName: string);
    procedure UpdateCursorPos;
    procedure FocusEditor;
    procedure PerformFileOpen(const AFileName: string);
    procedure SetModified(Value: Boolean);
    procedure OnCmbFontChange(Sender: TObject);
    procedure OnCmbFontSizeChange(Sender: TObject);
    procedure RefreshControls;
    procedure SelectionChange(Sender: TObject);
    procedure OnColorChangeEvent(Sender: TObject);
    procedure Localize;
  public
    Editor: TwwDBRichEdit;
  end;
{$ENDIF}

implementation

{$IFDEF InfoPower}

{$R *.DFM}

uses
  RM_Parser, RM_Utils, RM_Const, RM_Const1, RM_Printer
{$IFDEF OPENPICTUREDLG}, ExtDlgs{$ENDIF}
{$IFDEF JPeg}, JPeg{$ENDIF}
{$IFDEF RXGIF}, JvGIF{$ENDIF};

procedure RMWWAssignRich(Rich1, Rich2: TwwDBRichEdit);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  Rich2.Lines.SaveToStream(st);
  st.Position := 0;
  Rich1.Lines.LoadFromStream(st);
  st.Free;
end;

function _GetSpecial(const s: string; Pos: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
{  for i := 1 to Pos do
  begin
    if s[i] in [#10, #13] then
      Inc(Result);
  end;
}
//WHF Add
  i := 1;
  while i <= Pos do
  begin
    if ByteType(s, i) = mbLeadByte then
    begin
      Result := Result + 2;
      Inc(i);
    end
    else if s[i] in [#10, #13] then
      Inc(Result);
    Inc(i);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMWWRichView}

constructor TRMWWRichView.Create;
begin
  inherited Create;
  BaseName := 'wwRich';

  FRichEdit := TwwDBRichEdit.Create(RMDialogForm);
  with FRichEdit do
  begin
    Parent := RMDialogForm;
    Visible := False;
    Font.Charset := StrToInt(RMLoadStr(SCharset));
    Font.Name := RMLoadStr(SRMDefaultFontName);
    Font.Size := 11;
  end;
end;

destructor TRMwwRichView.Destroy;
begin
  if RMDialogForm <> nil then
  begin
    FRichEdit.Free;
    FRichEdit := nil;
    FSRichEdit.Free;
    FSRichEdit := nil;
  end;
  inherited Destroy;
end;

function TRMwwRichView.SRichEdit: TwwDBRichEdit;
begin
  if FSRichEdit = nil then
  begin
    FSRichEdit := TwwDBRichEdit.Create(RMDialogForm);
    with FSRichEdit do
    begin
      Parent := RMDialogForm;
      Visible := False;
    end;
  end;
  Result := FSRichEdit;
end;

procedure TRMwwRichView.GetRichData(ASource: TCustomMemo);
var
  R: string;
  i, j: Integer;
  lStr: WideString;
begin
  if ParentReport.Flag_TableEmpty then
  begin
    ASource.Lines.Text := '';
    Exit;
  end;

  with ASource do
  begin
    try
      Lines.BeginUpdate;
      i := Pos('[', Text);
      while i > 0 do
      begin
        SelStart := i - 1 - _GetSpecial(Text, i) div 2;
        R := RMAnsiGetBrackedVariable(Text, i, j);
        InternalOnGetValue(Self, R, lStr);
        SelLength := j - i + 1;
        SelText := lStr;

        i := Pos('[', Text);
      end;
    finally
      Lines.EndUpdate;
    end;
  end;
end;

function TRMwwRichView.DoCalcHeight: Integer;
var
  liFormatRange: TFormatRange;
  liLastChar, liMaxLen: Integer;
  liPixelsPerInchX: Integer;
  liPixelsPerInchY: Integer;
  lTextMetric: TTextMetric;
  liTolerance: Integer;
  liPrinter: TRMPrinter;
  liDC: HDC;
  liPrinterWidth: Integer;
  liFont: TFont;
begin
  liPrinter := GetPrinter;
  if (liPrinter <> nil) and (liPrinter.DC <> 0) then
    liDC := liPrinter.DC
  else
    liDC := GetDC(0);

  try
    FillChar(liFormatRange, SizeOf(TFormatRange), 0);
    liFormatRange.hdc := liDC;
    liFormatRange.hdcTarget := liFormatRange.hdc;
    liPixelsPerInchX := GetDeviceCaps(liDC, LOGPIXELSX);
    liPixelsPerInchY := GetDeviceCaps(liDC, LOGPIXELSY);

    if (liPrinter <> nil) and (liPrinter.DC <> 0) then
    begin
      liFont := TFont.Create;
      liFont.Assign(SRichEdit.SelAttributes);
      liPrinter.Canvas.Font := liFont;
      GetTextMetrics(liPrinter.Canvas.Handle, lTextMetric);
      liFont.Free;
    end
    else
      lTextMetric.tmDescent := 0;

    liPrinterWidth := Round(RMFromMMThousandths_Printer(
      (mmSaveWidth - mmSaveGapX * 2 - _CalcHFrameWidth(mmSaveFWLeft, mmSaveFWRight)),
      rmrtHorizontal, liPrinter));
    liPrinterWidth := Round(liPrinterWidth * 1440.0 / liPixelsPerInchX);
    liTolerance := Round(Abs(SRichEdit.SelAttributes.Size) * liPixelsPerInchY / 72);

    liFormatRange.rc := Rect(0, 0, liPrinterWidth, Round(10000000 * 1440.0 / liPixelsPerInchY));
    liFormatRange.rcPage := liFormatRange.rc;
    liLastChar := FStartCharPos;
    liMaxLen := SRichEdit.GetTextLen;
    liFormatRange.chrg.cpMin := liLastChar;
    liFormatRange.chrg.cpMax := -1;
    SRichEdit.Perform(EM_FORMATRANGE, 0, Integer(@liFormatRange));
    if liMaxLen = 0 then
      Result := 0
    else if (liFormatRange.rcPage.bottom <> liFormatRange.rc.bottom) then
      Result := Round(liFormatRange.rc.bottom / (1440.0 / liPixelsPerInchY))
    else
      Result := 0;

    SRichEdit.Perform(EM_FORMATRANGE, 0, 0);
    Result := Result + lTextMetric.tmDescent + liTolerance;
    Result := Round(RMToMMThousandths_Printer(Result, rmrtVertical, liPrinter) + 0.5);
  finally
    if (liPrinter = nil) or (liPrinter.DC = 0) then
      ReleaseDC(liDC, 0);
  end;
end;

{$WARNINGS OFF}

procedure TRMwwRichView.DrawRichText(aDC: HDC; aFormatDC: HDC; const aRect: TRect; aCharRange: TCharRange);
begin
  FormatRange(aDC, aFormatDC, aRect, aCharRange, True);
end;

function TRMwwRichView.FormatRange(aDC: HDC; aFormatDC: HDC; const aRect: TRect;
  aCharRange: TCharRange; aRender: Boolean): Integer;
var
  liFormatRange: TFormatRange;
  liSaveMapMode: Integer;
  liPixelsPerInchX: Integer;
  liPixelsPerInchY: Integer;
  liRender: Integer;
  liRichEdit: TwwDBRichEdit;
begin
  if aRender then liRichEdit := FRichEdit else liRichEdit := SRichEdit;

  FillChar(liFormatRange, SizeOf(TFormatRange), 0);
  liFormatRange.hdc := aDC;
  liFormatRange.hdcTarget := aFormatDC;

  liPixelsPerInchX := GetDeviceCaps(aDC, LOGPIXELSX);
  liPixelsPerInchY := GetDeviceCaps(aDC, LOGPIXELSY);

  liFormatRange.rc.left := (aRect.Left * 1440 div liPixelsPerInchX) + 45;
  liFormatRange.rc.right := aRect.Right * 1440 div liPixelsPerInchX;
  liFormatRange.rc.top := aRect.Top * 1440 div liPixelsPerInchY;
  liFormatRange.rc.bottom := aRect.Bottom * 1440 div liPixelsPerInchY;
  liFormatRange.rcPage := liFormatRange.rc;
  liFormatRange.chrg.cpMin := aCharRange.cpMin;
  liFormatRange.chrg.cpMax := aCharRange.cpMax;

  if aRender then
    liRender := 1
  else
    liRender := 0;

  liSaveMapMode := SetMapMode(liFormatRange.hdc, MM_TEXT);
  liRichEdit.Perform(EM_FORMATRANGE, 0, 0); { flush buffer}
  try
    Result := liRichEdit.Perform(EM_FORMATRANGE, liRender, Longint(@liFormatRange));
  finally
    liRichEdit.Perform(EM_FORMATRANGE, 0, 0);
    SetMapMode(liFormatRange.hdc, liSaveMapMode);
  end;
end;

procedure TRMwwRichView.ShowRichText(aRender: Boolean);
var
  liCharRange: TCharRange;

  procedure _ShowRichOnPrinter;
  var
    liPrinter: TRMPrinter;
  begin
    liPrinter := GetPrinter;
    DrawRichText(Canvas.Handle, liPrinter.DC, RealRect, liCharRange);
  end;

  procedure _ShowRichOnScreen;
  var
    liMetaFile: TMetaFile;
    liMetaFileCanvas: TMetaFileCanvas;
    liDC: HDC;
    liPrinter: TRMPrinter;
    liBitmap: TBitmap;
    liCanvasRect: TRect;
    liWidth, liHeight: Integer;
  begin
    liPrinter := RMPrinter;
    if liPrinter.DC <> 0 then
      liDC := liPrinter.DC
    else
      liDC := GetDC(0);

    liMetaFile := TMetaFile.Create;
    try
      if aRender then
      begin
        liWidth := mmSaveWidth - mmSaveGapX * 2 - _CalcHFrameWidth(mmSaveFWLeft, mmSaveFWRight);
        liHeight := mmSaveHeight - mmSaveGapY * 2 - _CalcVFrameWidth(mmSaveFWTop, mmSaveFWBottom);
      end
      else
      begin
        liWidth := mmWidth - mmGapLeft * 2 - _CalcHFrameWidth(LeftFrame.mmWidth, RightFrame.mmWidth);
        liHeight := mmHeight - mmGapTop * 2 - _CalcVFrameWidth(TopFrame.mmWidth, BottomFrame.mmWidth);
      end;

      liCanvasRect := Rect(0, 0,
        Round(RMFromMMThousandths_Printer(liWidth, rmrtHorizontal, liPrinter)) + 1,
        Round(RMFromMMThousandths_Printer(liHeight, rmrtVertical, liPrinter)));
      liMetaFile.Width := liCanvasRect.Right - liCanvasRect.Left;
      liMetaFile.Height := liCanvasRect.Bottom - liCanvasRect.Top;

      liMetaFileCanvas := TMetaFileCanvas.Create(liMetaFile, liDC);
      liMetaFileCanvas.Brush.Style := bsClear;

      FEndCharPos := FormatRange(liMetaFileCanvas.Handle, liDC, liCanvasRect, liCharRange, aRender);

      liMetaFileCanvas.Free;
      if liPrinter.DC = 0 then
        ReleaseDC(0, liDC);

      if aRender then
      begin
        if DocMode = rmdmDesigning then
        begin
          liBitmap := TBitmap.Create;
          liBitmap.Width := RealRect.Right - RealRect.Left + 1;
          liBitmap.Height := RealRect.Bottom - RealRect.Top + 1;
          liBitmap.Canvas.StretchDraw(Rect(0, 0, liBitmap.Width, liBitmap.Height), liMetaFile);
          Canvas.Draw(RealRect.Left, RealRect.Top, liBitmap);
          liBitmap.Free;
        end
        else
          Canvas.StretchDraw(RealRect, liMetaFile);
      end;
    finally
      liMetaFile.Free;
    end;
  end;

begin
  FEndCharPos := FStartCharPos;
  liCharRange.cpMax := -1;
  liCharRange.cpMin := FEndCharPos;
  if DocMode = rmdmPrinting then
    _ShowRichOnPrinter
  else
    _ShowRichOnScreen;
end;
{$WARNINGS ON}

procedure TRMwwRichView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  CalcGaps;
  with aCanvas do
  begin
    ShowBackground;
    FStartCharPos := 0;
    InflateRect(RealRect, -RMToScreenPixels(mmGapLeft, rmutMMThousandths),
      -RMToScreenPixels(mmGapTop, rmutMMThousandths));
    if (spWidth > 0) and (spHeight > 0) then
      ShowRichText(True);
    ShowFrame;
  end;
  RestoreCoord;
end;

procedure TRMwwRichView.Prepare;
begin
  inherited Prepare;
  FStartCharPos := 0;
end;

procedure TRMwwRichView.GetMemoVariables;
begin
  if OutputOnly then Exit;

  if DrawMode = rmdmAll then
  begin
    Memo1.Assign(Memo);
    InternalOnBeforePrint(Memo1, Self);
    RMwwAssignRich(SRichEdit, FRichEdit);
    if not TextOnly then
      GetRichData(SRichEdit);

	  if (not OutputOnly) and Assigned(OnBeforePrint) then
  	  OnBeforePrint(Self);
  end;
end;

procedure TRMwwRichView.PlaceOnEndPage(aStream: TStream);
var
  n: integer;
begin
  BeginDraw(Canvas);
  if not Visible then Exit;

  GetMemoVariables;
  if DrawMode = rmdmPart then
  begin
    FStartCharPos := FEndCharPos;
    ShowRichText(False);
    n := SRichEdit.GetTextLen - FEndCharPos + 1;
    if n > 0 then
    begin
      SRichEdit.SelStart := FEndCharPos;
      SRichEdit.SelLength := n;
      SRichEdit.SelText := '';
    end;

    SRichEdit.SelStart := 0;
    SRichEdit.SelLength := FSaveCharPos;
    SRichEdit.SelText := '';

    FSaveCharPos := FEndCharPos;
  end;

  aStream.Write(Typ, 1);
  RMWriteString(aStream, ClassName);
  FUseSRichEdit := True;
  try
    SaveToStream(aStream);
  finally
    FUseSRichEdit := False;
  end;
end;

function TRMwwRichView.CalcHeight: Integer;
begin
  FEndCharPos := 0;
  FSaveCharPos := 0;
  Result := 0;
  if not Visible then
    Exit;

  CalcGaps;
  DrawMode := rmdmAll;
  GetMemoVariables;
//  DrawMode := rmdmAfterCalcHeight;

  FStartCharPos := 0;
  CalculatedHeight := RMToMMThousandths(spGapTop * 2 + _CalcVFrameWidth(TopFrame.spWidth, BottomFrame.spWidth), rmutScreenPixels) +
    DoCalcHeight;
  RestoreCoord;
  Result := CalculatedHeight;
end;

function TRMwwRichView.RemainHeight: Integer;
begin
  DrawMode := rmdmAll;
  GetMemoVariables;
//  DrawMode := rmdmAfterCalcHeight;

  FStartCharPos := FEndCharPos + 1;
  ActualHeight := RMToMMThousandths(spGapTop * 2 + _CalcVFrameWidth(TopFrame.spWidth, BottomFrame.spWidth), rmutScreenPixels) +
    DoCalcHeight;
  Result := ActualHeight;
end;

procedure TRMwwRichView.LoadFromStream(aStream: TStream);
var
  b: Byte;
  liSavePos: Integer;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  b := RMReadByte(aStream);
  liSavePos := RMReadInt32(aStream);
  if b > 0 then
    FRichEdit.Lines.LoadFromStream(aStream);
  aStream.Seek(liSavePos, soFromBeginning);
end;

procedure TRMwwRichView.SaveToStream(aStream: TStream);
var
  b: Byte;
  liSavePos, liPos: Integer;
  liRichEdit: TwwDBRichEdit;
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  if FUseSRichEdit then
    liRichEdit := SRichEdit
  else
    liRichEdit := FRichEdit;

  if liRichEdit.Lines.Count > 0 then b := 1 else b := 0;
  RMWriteByte(aStream, b);

  liSavePos := aStream.Position;
  RMWriteInt32(aStream, liSavePos);
  if b > 0 then
    liRichEdit.Lines.SaveToStream(aStream);

  liPos := aStream.Position;
  aStream.Seek(liSavePos, soFromBeginning);
  RMWriteInt32(aStream, liPos);
  aStream.Seek(liPos, soFromBeginning);
end;

procedure TRMwwRichView.GetBlob;
var
  liStream: TMemoryStream;
begin
  liStream := TMemoryStream.Create;
  try
    if not ParentReport.Flag_TableEmpty then
      FDataSet.AssignBlobFieldTo(FDataFieldName, liStream);
    FRichEdit.Lines.LoadFromStream(liStream);
  finally
    liStream.Free;
  end;
end;

procedure TRMWWRichView.ShowEditor;
var
  tmpForm: TRMwwRichForm;
begin
  tmpForm := TRMwwRichForm.Create(Application);
  try
    RMwwAssignRich(tmpForm.Editor, RichEdit);
    tmpForm.Editor.MeasurementUnits := RichEdit.MeasurementUnits;
    if tmpForm.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      RMwwAssignRich(RichEdit, tmpForm.Editor);
      RMDesigner.AfterChange;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMwwRichView.DefinePopupMenu(aPopup: TRMCustomMenuItem);
begin
  inherited DefinePopupMenu(aPopup);
end;

procedure TRMwwRichView.LoadFromRichEdit(aRichEdit: TwwDBRichEdit);
begin
  RMwwAssignRich(FRichEdit, aRichEdit);
end;

function TRMWWRichView.GetViewCommon;
begin
  Result := '[ww Rich]';
end;

procedure TRMWWRichView.ClearContents;
begin
  FRichEdit.Clear;
  inherited;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMWWRichForm}

procedure TRMwwRichForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

//  Caption := RMLoadStr(rmRes + 560);
  RMSetStrProp(btnFileNew, 'Hint', rmRes + 155);
  RMSetStrProp(btnFileOpen, 'Hint', rmRes + 561);
  RMSetStrProp(btnFileSave, 'Hint', rmRes + 562);
  RMSetStrProp(btnUndo, 'Hint', rmRes + 94);
  RMSetStrProp(btnRedo, 'Hint', rmRes + 95);
  RMSetStrProp(btnFind, 'Hint', rmRes + 582);
  RMSetStrProp(btnFontBold, 'Hint', rmRes + 564);
  RMSetStrProp(btnFontItalic, 'Hint', rmRes + 565);
  RMSetStrProp(btnFontUnderline, 'Hint', rmRes + 569);
  RMSetStrProp(btnAlignLeft, 'Hint', rmRes + 566);
  RMSetStrProp(btnAlignCenter, 'Hint', rmRes + 567);
  RMSetStrProp(btnAlignRight, 'Hint', rmRes + 568);
  RMSetStrProp(btnBullets, 'Hint', rmRes + 570);
  RMSetStrProp(btnInsertField, 'Hint', rmRes + 575);
  RMSetStrProp(btnCut, 'Hint', rmRes + 91);
  RMSetStrProp(btnCopy, 'Hint', rmRes + 92);
  RMSetStrProp(btnPaste, 'Hint', rmRes + 93);

  ItmCut.Caption := btnCut.Hint;
  ItmCopy.Caption := btnCopy.Hint;
  ItmPaste.Caption := btnPaste.Hint;
  RMSetStrProp(MenuFile, 'Caption', rmRes + 154);
  RMSetStrProp(ItemFileNew, 'Caption', rmRes + 155);
  RMSetStrProp(ItemFileOpen, 'Caption', rmRes + 156);
  RMSetStrProp(ItemFileSaveAs, 'Caption', rmRes + 157);
  RMSetStrProp(ItemFilePrint, 'Caption', rmRes + 159);
  RMSetStrProp(ItemFileExit, 'Caption', rmRes + 162);
  RMSetStrProp(MenuEdit, 'Caption', rmRes + 163);
  RMSetStrProp(ItemEditUndo, 'Caption', rmRes + 164);
  RMSetStrProp(ItemEditRedo, 'Caption', rmRes + 165);
  RMSetStrProp(ItemEditCut, 'Caption', rmRes + 166);
  RMSetStrProp(ItemEditCopy, 'Caption', rmRes + 167);
  RMSetStrProp(ItemEditPaste, 'Caption', rmRes + 168);
  RMSetStrProp(ItemEditSelectAll, 'Caption', rmRes + 170);
  RMSetStrProp(ItemEditFind, 'Caption', rmRes + 582);
  RMSetStrProp(ItemEditFindNext, 'Caption', rmRes + 583);
  RMSetStrProp(ItemEditReplace, 'Caption', rmRes + 584);
  RMSetStrProp(MenuInsert, 'Caption', rmRes + 586);
  RMSetStrProp(ItemInserObject, 'Caption', rmRes + 587);
  RMSetStrProp(ItemInsertPicture, 'Caption', rmRes + 588);
  RMSetStrProp(ItemInsertField, 'Caption', rmRes + 575);
  RMSetStrProp(MenuFormat, 'Caption', rmRes + 589);
  RMSetStrProp(ItemFormatFont, 'Caption', rmRes + 576);
  RMSetStrProp(ItemFormatParagraph, 'Caption', rmRes + 852);

  btnOK.Hint := RMLoadStr(rmRes + 573);
  btnCancel.Hint := RMLoadStr(rmRes + 574);
end;

procedure TRMwwRichForm.SelectionChange(Sender: TObject);
begin
  RefreshControls;
end;

procedure TRMwwRichForm.RefreshControls;
var
  haveSelection, haveText: boolean;
  lFont: TFont;
  lFontHeight: Integer;
begin
  try
    FUpdating := True;
    FRuler.UpdateInd;
    btnFontBold.down := fsBold in Editor.SelAttributes.Style;
    btnFontUnderline.down := fsUnderline in Editor.SelAttributes.Style;
    btnFontItalic.down := fsItalic in Editor.SelAttributes.Style;
    FCmbFont.FontName := Editor.SelAttributes.Name;

    lFont := TFont.Create;
    lFont.Size := Editor.SelAttributes.Size;
    lFontHeight := lFont.Height;
    lFont.Free;
    RMSetFontSize(TComboBox(FCmbFontSize), lFontHeight, Editor.SelAttributes.Size);

    btnBullets.down := Editor.Paragraph.Numbering = nsBullet;
//	  btnHighlight.Down:= (Editor.GetTextBackgroundColor <> 0) and
//                         (Editor.GetTextBackgroundColor <> ColorToRGB(clWindow));
    if ord(Editor.Paragraph.Alignment) = PFA_FULLJUSTIFY - 1 then
      btnJustify.Down := True
    else
    begin
      case Editor.Paragraph.Alignment of
        taLeftJustify: btnAlignLeft.Down := True;
        taCenter: btnAlignCenter.Down := True;
        taRightJustify: btnAlignRight.Down := True;
      end;
    end;

    ItemEditPaste.Enabled := Editor.CanPaste and (not Editor.readonly);
    btnPaste.Enabled := ItemEditPaste.Enabled;
    ItmPaste.Enabled := ItemEditPaste.Enabled;
    ItemEditUndo.Enabled := Editor.CanUndo;
    ItemEditRedo.Enabled := Editor.CanRedo;
    btnUndo.Enabled := ItemEditUndo.Enabled;
    btnRedo.Enabled := ItemEditRedo.Enabled;

    haveSelection := Editor.SelLength > 0; //Editor.CanCut;
    haveText := (Editor.Lines.Count > 1) or
      (Editor.Lines.Count = 1) and (Editor.Lines[0] <> '');
    ItemEditCut.Enabled := haveSelection and (not Editor.readonly);
    btnCut.Enabled := ItemEditCut.Enabled;
    ItmCut.Enabled := ItemEditCut.Enabled;
    ItemEditCopy.Enabled := haveSelection;
    btnCopy.Enabled := ItemEditCopy.Enabled;
    ItmCopy.Enabled := ItemEditCopy.Enabled;
    ItemEditSelectAll.Enabled := haveText;
    ItemEditFind.Enabled := haveText;
    btnFind.Enabled := ItemEditFind.Enabled;
    ItemEditFindNext.Enabled := Editor.CanFindNext;
    ItemEditReplace.Enabled := haveText and (not Editor.readOnly);
  finally
    FUpdating := False;
  end;
end;

procedure TRMwwRichForm.FocusEditor;
begin
  with Editor do
    if CanFocus then
      SetFocus;
end;

procedure TRMwwRichForm.SetFileName(const FileName: string);
begin
  FFileName := FileName;
  Editor.Title := ExtractFileName(FileName);
end;

{ Event Handlers }

procedure TRMwwRichForm.FormCreate(Sender: TObject);
var
  i, liOffset: Integer;
  s, s1: string;
begin
  Localize;
  Editor := TwwDBRichEdit.Create(Self);
  with Editor do
  begin
    Parent := Self;
    Align := alClient;
    HideSelection := False;
    PopupMenu := EditPopupMenu;
    WantTabs := True;
    ScrollBars := ssBoth;

    OnSelectionChange := SelectionChange;
    OnChange := RichEditChange;
  end;

  FcmbFont := TRMFontComboBox.Create(ToolBar2);
  with FcmbFont do
  begin
    Parent := ToolBar2;
    Left := 0;
    Top := 0;
    Height := 21;
    Width := 150;
    Tag := 7;
//    Device := rmfdPrinter;
    OnChange := OnCmbFontChange;
  end;
  FcmbFontSize := TComboBox.Create(ToolBar2);
  with FcmbFontSize do
  begin
    Parent := ToolBar2;
    Left := 150;
    Top := 0;
    Height := 21;
    Width := 59;
    Tag := 8;
    DropDownCount := 12;
    if RMIsChineseGB then
      liOffset := 0
    else
      liOffset := 13;
    for i := Low(RMDefaultFontSizeStr) + liOffset to High(RMDefaultFontSizeStr) do
      Items.Add(RMDefaultFontSizeStr[i]);
    OnChange := OnCmbFontSizeChange;
  end;
  FBtnFontColor := TRMColorPickerButton.Create(ToolBar2);
  with FBtnFontColor do
  begin
    Parent := ToolBar2;
    Left := ToolButton18.Left + ToolButton18.Width;
    Top := 0;
    ColorType := rmptFont;
    OnColorChange := OnColorChangeEvent;
  end;
  FBtnBackColor := TRMColorPickerButton.Create(ToolBar2);
  with FBtnBackColor do
  begin
    Parent := ToolBar2;
    Left := FBtnFontColor.Left + FBtnFontColor.Width;
    Top := 0;
    ColorType := rmptFill;
    OnColorChange := OnColorChangeEvent;
  end;

  FRuler := TRMRuler.Create(Self);
  with FRuler do
  begin
    Top := ToolBar2.Top + ToolBar2.Height;
    RichEdit := TCustomRichEdit(Editor);
    Align := alTop;
    Height := 26;
    OnIndChanged := SelectionChange;
  end;

{$IFDEF OPENPICTUREDLG}
//  Editor.OnCloseFindDialog := EditFindDialogClose;
  FOpenPictureDialog := TOpenPictureDialog.Create(Self);
{$ELSE}
  FOpenPictureDialog := TOpenDialog.Create(Self);
{$ENDIF}

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
  FOpenPictureDialog.Filter := RMLoadStr(SPictFile) + ' (' + s + ')|' + s1 + '|' + RMLoadStr(SAllFiles) + '|*.*';

  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SetFileName('Untitled');
  HandleNeeded;
end;

procedure TRMwwRichForm.PerformFileOpen(const AFileName: string);
begin
  try
    Editor.Lines.LoadFromFile(AFileName);
  finally
  end;
  SetFileName(AFileName);
  Editor.SetFocus;
  Editor.Modified := False;
  SetModified(False);
end;

procedure TRMwwRichForm.UpdateCursorPos;
var
  CharPos: TPoint;
begin
  CharPos := Editor.CaretPos;
  StatusBar.Panels[0].Text := Format('ÐÐ: %3d  ÁÐ: %3d', [CharPos.Y + 1, CharPos.X + 1]);
  BtnCopy.Enabled := Editor.SelLength > 0;
  ItemEditCopy.Enabled := BtnCopy.Enabled;
  ItmCopy.Enabled := BtnCopy.Enabled;
  BtnCut.Enabled := ItemEditCopy.Enabled;
  ItmCut.Enabled := btnCut.Enabled;
  ItemEditCut.Enabled := ItemEditCopy.Enabled;
end;

procedure TRMwwRichForm.FormShow(Sender: TObject);
begin
  UpdateCursorPos;
  RichEditChange(nil);
  SetModified(FALSE);
  RefreshControls;
  FocusEditor;
end;

procedure TRMwwRichForm.RichEditChange(Sender: TObject);
begin
  SetModified(Editor.Modified);
  { Undo }
  BtnUndo.Enabled := Editor.CanUndo;
  ItemEditUndo.Enabled := btnUndo.Enabled;
  { Redo }
  ItemEditRedo.Enabled := Editor.CanRedo;
  btnRedo.Enabled := ItemEditRedo.Enabled;
end;

procedure TRMwwRichForm.SetModified(Value: Boolean);
begin
  if Value then
    StatusBar.Panels[1].Text := 'ÐÞ¸Ä'
  else
    StatusBar.Panels[1].Text := '';
end;

procedure TRMwwRichForm.FormDestroy(Sender: TObject);
begin
  FRuler.Free;
end;

procedure TRMwwRichForm.EditSelectAll(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TRMwwRichForm.btnFileNewClick(Sender: TObject);
begin
  SetFileName('Untitled');
  try
    Editor.Lines.Clear;
    Editor.Modified := False;
    Editor.ReadOnly := False;
    SetModified(False);
    with Editor do
    begin
      DefAttributes.Assign(Font);
      SelAttributes.Assign(Font);
    end;
  finally
  end;
end;

procedure TRMwwRichForm.btnFileOpenClick(Sender: TObject);
begin
  OpenDialog.Filter := RMLoadStr(SRTFFile) + '(*.rtf)|*.rtf' + '|' +
    RMLoadStr(STextFile) + '(*.txt)|*.txt';
  if OpenDialog.Execute then
  begin
    PerformFileOpen(OpenDialog.FileName);
    Editor.ReadOnly := ofReadOnly in OpenDialog.Options;
  end;
end;

procedure TRMwwRichForm.btnFileSaveClick(Sender: TObject);
begin
  if FFileName = 'Untitled' then
    ItemFileSaveAs.Click
  else
  begin
    Editor.Lines.SaveToFile(FFileName);
    Editor.Modified := False;
    SetModified(False);
    RichEditChange(nil);
  end;
end;

procedure TRMwwRichForm.btnFindClick(Sender: TObject);
begin
  Editor.ExecuteFindDialog;
end;

procedure TRMwwRichForm.btnCutClick(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TRMwwRichForm.btnCopyClick(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TRMwwRichForm.btnPasteClick(Sender: TObject);
begin
  Editor.PasteFromClipboard;
end;

procedure TRMwwRichForm.btnUndoApplyAlign(Sender: TObject; Align: TAlign;
  var Apply: Boolean);
begin
  Editor.Undo;
  RichEditChange(nil);
end;

procedure TRMwwRichForm.btnRedoClick(Sender: TObject);
begin
  SendMessage(Editor.Handle, EM_REDO, 0, 0);
  RefreshControls;
end;

procedure TRMwwRichForm.btnFontBoldClick(Sender: TObject);
begin
  Editor.SetStyleAttribute(fsBold, not TempDown);
  RefreshControls;
end;

procedure TRMwwRichForm.btnFontItalicClick(Sender: TObject);
begin
  Editor.SetStyleAttribute(fsItalic, not TempDown);
  RefreshControls;
end;

procedure TRMwwRichForm.btnFontUnderlineClick(Sender: TObject);
begin
  Editor.SetStyleAttribute(fsUnderline, not TempDown);
  RefreshControls;
end;

procedure TRMwwRichForm.btnAlignLeftClick(Sender: TObject);
begin
  Editor.Paragraph.Alignment := TAlignment(TComponent(Sender).Tag);
  RefreshControls;
end;

procedure TRMwwRichForm.btnBulletsClick(Sender: TObject);
begin
  Editor.SetBullet(not TempDown);
  RefreshControls;
end;

procedure TRMwwRichForm.btnBulletsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  tempdown := TToolButton(Sender).down;
end;

procedure TRMwwRichForm.ItemFileSaveAsClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    Editor.Lines.SaveToFile(SaveDialog.FileName);
    SetFileName(SaveDialog.FileName);
    Editor.Modified := False;
    SetModified(False);
    RichEditChange(nil);
  end;
  FocusEditor;
end;

procedure TRMwwRichForm.ItemFilePrintClick(Sender: TObject);
begin
  if PrintDialog.Execute then
    Editor.Print(FFileName);
end;

procedure TRMwwRichForm.ItemFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TRMwwRichForm.ItemFormatFontClick(Sender: TObject);
begin
  Editor.ExecuteFontDialog;
  RefreshControls;
end;

procedure TRMwwRichForm.ItemInserObjectClick(Sender: TObject);
begin
  Editor.InsertObjectDialog;
end;

procedure TRMwwRichForm.btnUndoClick(Sender: TObject);
begin
  SendMessage(Editor.Handle, EM_UNDO, 0, 0);
  RefreshControls;
end;

procedure TRMwwRichForm.ItemEditFindNextClick(Sender: TObject);
begin
  Editor.FindNextMatch;
end;

procedure TRMwwRichForm.ItemEditReplaceClick(Sender: TObject);
begin
  Editor.ExecuteReplaceDialog;
end;

procedure TRMwwRichForm.btnInsertFieldClick(Sender: TObject);
var
  s: string;
begin
  if RMDesigner <> nil then
  begin
    s := RMDesigner.InsertExpression(nil);
    if s <> '' then
      Editor.SelText := s;
  end;
end;

procedure TRMwwRichForm.ItemEditSelectAllClick(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TRMwwRichForm.OnCmbFontChange(Sender: TObject);
var
  Format: TCharFormat;
begin
  if Editor.selAttributes.Name = FCmbFont.FontName then
    exit;
  FillChar(Format, SizeOf(TCharFormat), 0);
  Format.cbSize := SizeOf(TCharFormat);
  with Format do
  begin
    dwMask := CFM_FACE or CFM_CHARSET;
    StrPLCopy(szFaceName, FCmbFont.FontName, SizeOf(szFaceName));
    bCharSet := Editor.GetCharSetOfFontName(FCmbFont.FontName);
  end;
  SendMessage(Editor.Handle, EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@Format));
end;

procedure TRMwwRichForm.OnCmbFontSizeChange(Sender: TObject);
var
  liFontSize: Integer;
  lFont: TFont;
begin
  liFontSize := RMGetFontSize(TComboBox(FCmbFontSize));

  if liFontSize > 0 then
    Editor.SelAttributes.Size := liFontSize
  else
  begin
    lFont := TFont.Create;
    lFont.Height := liFontSize;
    liFontSize := lFont.Size;
    Editor.SelAttributes.Size := liFontSize;
    lFont.Free;
  end;

  Editor.SetFocus;
  RefreshControls;
end;

procedure TRMwwRichForm.btnOKClick(Sender: TObject);
begin
  OnResize := nil;
  ModalResult := mrOK;
end;

procedure TRMwwRichForm.btnCancelClick(Sender: TObject);
begin
  OnResize := nil;
  ModalResult := mrCancel;
end;

procedure TRMwwRichForm.ItemInsertPictureClick(Sender: TObject);
var
  Pict: TPicture;
begin
  with FOpenPictureDialog do
  begin
    if Execute then
    begin
      Pict := TPicture.Create;
      try
        Pict.LoadFromFile(FileName);
        Clipboard.Assign(Pict);
        Editor.PasteFromClipboard;
      finally
        Pict.Free;
      end;
    end;
  end;
end;

procedure TRMwwRichForm.FormResize(Sender: TObject);
begin
  SelectionChange(Sender);
end;

procedure TRMwwRichForm.OnColorChangeEvent(Sender: TObject);
begin
  if Sender = FBtnFontColor then
    Editor.SelAttributes.Color := FBtnFontColor.CurrentColor
  else
  begin
    Editor.SetTextBackgroundColor(FBtnBackColor.CurrentColor);
    RefreshControls;
  end;
end;

procedure TRMwwRichForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  OnResize := nil;
end;

procedure TRMwwRichForm.ItemFormatParagraphClick(Sender: TObject);
begin
  if Editor.ExecuteParagraphDialog then
    FRuler.UpdateInd;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMRichView_LoadFromRichEdit(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMWWRichView(Args.Obj).LoadFromRichEdit(TwwDBRichEdit(V2O(Args.Values[0])));
end;


procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMWWRichView, 'TRMWWRichView');

    AddGet(TRMWWRichView, 'LoadFromRichEdit', TRMRichView_LoadFromRichEdit, 1, [0], varEmpty);
  end;
end;

initialization
  RMRegisterObjectByRes(TRMWWRichView, 'RM_WWRichObject', RMLoadStr(SInsWwRichObject), nil);
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

{$ENDIF}
end.

