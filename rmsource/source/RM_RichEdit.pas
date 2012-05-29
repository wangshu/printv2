
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{          RxRich Add-In Object           }
{                                         }
{*****************************************}

unit RM_RichEdit;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Menus, Db,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ClipBrd, ToolWin,
  RM_Class, RM_common, RM_Ctrls, RM_DsgCtrls, RichEdit
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF JVCLCTLS}, JvRichEdit{$ELSE}, RM_JvRichEdit{$ENDIF}
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMRichObject = class(TComponent) // fake component
  end;

 { TRMRichView }
  TRMRichView = class(TRMStretcheableView)
  private
    FRichEdit, FSRichEdit: TJvRichEdit;
    FSaveCharPos, FEndCharPos, FStartCharPos: Integer;
    FUseSRichEdit: Boolean;

    function SRichEdit: TJvRichEdit;
    procedure GetRichData(ASource: TCustomMemo);
    function FormatRange(aDC: HDC; aFormatDC: HDC; const aRect: TRect; aCharRange: TCharRange;
      aRender: Boolean): Integer;
    function DoCalcHeight: Integer;
    procedure ShowRichText(aRender: Boolean);
  protected
    procedure Prepare; override;
    procedure GetMemoVariables; override;
    function GetViewCommon: string; override;
    procedure ClearContents; override;
    function GetExportMode: TRMExportMode; override;
    function GetExportData: string; override;

    function CalcHeight: Integer; override;
    function RemainHeight: Integer; override;

    procedure GetBlob; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    procedure DefinePopupMenu(Popup: TRMCustomMenuItem); override;
    procedure ShowEditor; override;
    procedure LoadFromRichEdit(aRichEdit: TJvRichEdit);
  published
    property RichEdit: TJvRichEdit read FRichEdit;
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
    property OnPreviewClick;
    property OnPreviewClickUrl;
  end;

  TRMRxRichView = class(TRMRichView)
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  {TRMRxRichForm}
  TRMRichForm = class(TForm)
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
    ItemEditPasteSpecial: TMenuItem;
    ItemEditSelectAll: TMenuItem;
    N20: TMenuItem;
    ItemEditFind: TMenuItem;
    ItemEditFindNext: TMenuItem;
    ItemEditReplace: TMenuItem;
    N23: TMenuItem;
    ItemEditObjProps: TMenuItem;
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
    ToolButton31: TToolButton;
    btnSuperscript: TToolButton;
    btnSubscript: TToolButton;
    ItemFormatParagraph: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RichEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditorProtectChange(Sender: TObject; StartPos,
      EndPos: Integer; var AllowChange: Boolean);
    procedure EditorTextNotFound(Sender: TObject; const FindText: string);
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
    procedure ItemFormatFontClick(Sender: TObject);
    procedure ItemInserObjectClick(Sender: TObject);
    procedure ItemInsertPictureClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure ItemEditPasteSpecialClick(Sender: TObject);
    procedure ItemEditFindNextClick(Sender: TObject);
    procedure ItemEditReplaceClick(Sender: TObject);
    procedure ItemEditObjPropsClick(Sender: TObject);
    procedure btnInsertFieldClick(Sender: TObject);
    procedure btnSuperscriptClick(Sender: TObject);
    procedure ItemEditSelectAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ItemFormatParagraphClick(Sender: TObject);
  private
    FFileName: string;
    FUpdating: Boolean;
    FProtectChanging: Boolean;
//    FClipboardMonitor: TJvClipboardMonitor;
    FOpenPictureDialog: TOpenDialog;
    FcmbFont: TRMFontComboBox;
    FcmbFontSize: TComboBox;
    FRuler: TRMRuler;
    FBtnFontColor: TRMColorPickerButton;
    FBtnBackColor: TRMColorPickerButton;
    FView: TRMRichView;

    function CurrText: TJvTextAttributes;
    procedure SetFileName(const FileName: string);
{$IFDEF OPENPICTUREDLG}
    procedure EditFindDialogClose(Sender: TObject; Dialog: TFindDialog);
{$ENDIF}
    procedure SetEditRect;
    procedure UpdateCursorPos;
    procedure FocusEditor;
    procedure ClipboardChanged(Sender: TObject);
    procedure PerformFileOpen(const AFileName: string);
    procedure SetModified(Value: Boolean);
    procedure OnCmbFontChange(Sender: TObject);
    procedure OnCmbFontSizeChange(Sender: TObject);
    procedure SelectionChange(Sender: TObject);
    procedure OnColorChangeEvent(Sender: TObject);
    procedure Localize;
  public
    Editor: TJvRichEdit;
  end;

implementation

uses RM_Parser, RM_Utils, RM_Const, RM_Const1, RM_Printer,
  {JvVclUtils,}RM_RxParaFmt
{$IFDEF OPENPICTUREDLG}, ExtDlgs{$ENDIF}
{$IFDEF JPeg}, JPeg{$ENDIF}
{$IFDEF RXGIF}, JvGIF{$ENDIF};

const
  RulerAdj = 4 / 3;
  GutterWid = 6;
  UndoNames: array[TUndoName] of string =
  ('', 'typing', 'delete', 'drag and drop', 'cut', 'paste');

{$R *.DFM}

procedure RMRxAssignRich(Rich1, Rich2: TJvRichEdit);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  Rich2.Lines.SaveToStream(st);
  st.Position := 0;
  Rich1.Lines.LoadFromStream(st);
  st.Free;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMRichView }

constructor TRMRichView.Create;
begin
  inherited Create;
  BaseName := 'Rich';

  FUseSRichEdit := False;
  FRichEdit := TJvRichEdit.Create(RMDialogForm);
  with FRichEdit do
  begin
    Parent := RMDialogForm;
    Visible := False;
    Font.Charset := StrToInt(RMLoadStr(SCharset));
    Font.Name := RMLoadStr(SRMDefaultFontName);
    Font.Size := 11;
  end;
end;

destructor TRMRichView.Destroy;
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

function TRMRichView.SRichEdit: TJvRichEdit;
begin
  if FSRichEdit = nil then
  begin
    FSRichEdit := TJvRichEdit.Create(RMDialogForm);
    with FSRichEdit do
    begin
      Parent := RMDialogForm;
      Visible := False;
    end;
  end;
  Result := FSRichEdit;
end;

procedure TRMRichView.GetRichData(ASource: TCustomMemo);
var
//  lVarName: string;
  i, j: Integer;
  lVarName, lStr: WideString;
  lSpecialNum: Integer;

  function _FindPos(aPos: Integer): Integer;
  var
    lPos: Integer;
    lStr: string;
  begin
    Result := 0;
    lStr := aSource.Text;
    lPos := aPos;
    lPos := RMPosEx('[', lStr, lPos);
    while lPos > 0 do
    begin
      if (lPos > 0) and (ByteType(lStr, lPos) = mbSingleByte) then
      begin
        Result := lPos;
        Break;
      end;

      lPos := RMPosEx('[', lStr, lPos + 1);
    end;
  end;

  function _GetSpecial(const s: WideString; aPos: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to aPos do
    begin
      if RM_utils.RMWideCharIn(s[i] ,[#10, #13]) then
        Inc(Result);
    end;
  end;

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
      i := RMPosEx('[', WideString(Text), 1);
      while (i > 0) do
      begin
        lSpecialNum := _GetSpecial(Text, i) div 2;
        SelStart := i - 1 - lSpecialNum;
        lVarName := RMGetBrackedVariable{RMAnsiGetBrackedVariable}(Text, i, j);
        if lVarName <> '' then
        begin
          InternalOnGetValue(Self, lVarName, lStr);
          SelLength := j - i + 1;
          SelText := lStr;
          i := RMPosEx('[', WideString(Text), i + Length(lStr) + 1);
        end
        else
          Break;  
      end;
    finally
      Lines.EndUpdate;
    end;
  end;
end;

function TRMRichView.DoCalcHeight: Integer;
var
  lFormatRange: TFormatRange;
  lLastChar, lMaxLen: Integer;
  lPixelsPerInchX: Integer;
  lPixelsPerInchY: Integer;
  lTextMetric: TTextMetric;
  lTolerance: Integer;
  lPrinter: TRMPrinter;
  lDC: HDC;
  lPrinterWidth: Integer;
  lFont: TFont;
begin
  lPrinter := GetPrinter;
  if (lPrinter <> nil) and (lPrinter.DC <> 0) then
    lDC := lPrinter.DC
  else
    lDC := GetDC(0);

  try
    FillChar(lFormatRange, SizeOf(TFormatRange), 0);
    lFormatRange.hdc := lDC;
    lFormatRange.hdcTarget := lFormatRange.hdc;
    lPixelsPerInchX := GetDeviceCaps(lDC, LOGPIXELSX);
    lPixelsPerInchY := GetDeviceCaps(lDC, LOGPIXELSY);

    if (lPrinter <> nil) and (lPrinter.DC <> 0) then
    begin
      lFont := TFont.Create;
      lFont.Assign(SRichEdit.SelAttributes);
      lPrinter.Canvas.Font := lFont;
      GetTextMetrics(lPrinter.Canvas.Handle, lTextMetric);
      lFont.Free;
    end
    else
      lTextMetric.tmDescent := 0;

    lPrinterWidth := Round(RMFromMMThousandths_Printer(
      (mmSaveWidth - mmSaveGapX * 2 - _CalcHFrameWidth(mmSaveFWLeft, mmSaveFWRight)),
      rmrtHorizontal, lPrinter));
    lPrinterWidth := Round(lPrinterWidth * 1440.0 / lPixelsPerInchX);
    lTolerance := Round(Abs(SRichEdit.SelAttributes.Size) * lPixelsPerInchY / 72);

    lFormatRange.rc := Rect(0, 0, lPrinterWidth, Round(10000000 * 1440.0 / lPixelsPerInchY));
    lFormatRange.rcPage := lFormatRange.rc;
    lLastChar := FStartCharPos;
    lMaxLen := SRichEdit.GetTextLen;
    lFormatRange.chrg.cpMin := lLastChar;
    lFormatRange.chrg.cpMax := -1;
    SRichEdit.Perform(EM_FORMATRANGE, 0, Integer(@lFormatRange));
    if lMaxLen = 0 then
      Result := 0
    else if (lFormatRange.rcPage.bottom <> lFormatRange.rc.bottom) then
      Result := Round(lFormatRange.rc.bottom / (1440.0 / lPixelsPerInchY))
    else
      Result := 0;

    SRichEdit.Perform(EM_FORMATRANGE, 0, 0);
    Result := Result + lTextMetric.tmDescent + lTolerance;
    Result := Round(RMToMMThousandths_Printer(Result, rmrtVertical, lPrinter) + 0.5);
  finally
    if (lPrinter = nil) or (lPrinter.DC = 0) then
      ReleaseDC(lDC, 0);
  end;
end;

{$WARNINGS OFF}

function TRMRichView.FormatRange(aDC: HDC; aFormatDC: HDC; const aRect: TRect;
  aCharRange: TCharRange; aRender: Boolean): Integer;
var
  liFormatRange: TFormatRange;
  liSaveMapMode: Integer;
  liPixelsPerInchX: Integer;
  liPixelsPerInchY: Integer;
  liRender: Integer;
  liRichEdit: TJvRichEdit;
begin
  if aRender then liRichEdit := FRichEdit else liRichEdit := SRichEdit;

  FillChar(liFormatRange, SizeOf(TFormatRange), 0);
  liFormatRange.hdc := aDC;
  liFormatRange.hdcTarget := aFormatDC;

  liPixelsPerInchX := GetDeviceCaps(aDC, LOGPIXELSX);
  liPixelsPerInchY := GetDeviceCaps(aDC, LOGPIXELSY);

  liFormatRange.rc.left := Round(aRect.Left * 1440.0 / liPixelsPerInchX) + 45;
  liFormatRange.rc.right := Round(aRect.Right * 1440.0 / liPixelsPerInchX);
  liFormatRange.rc.top := Round(aRect.Top * 1440.0 / liPixelsPerInchY);
  liFormatRange.rc.bottom := Round(aRect.Bottom * 1440.0 / liPixelsPerInchY);
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

procedure TRMRichView.ShowRichText(aRender: Boolean);
var
  lCharRange: TCharRange;

  procedure _ShowRichOnPrinter;
  begin
    FormatRange(Canvas.Handle, Canvas.Handle, RealRect, lCharRange, True);
  end;

  procedure _ShowRichOnScreen;
  var
    lMetaFile: TMetaFile;
    lMetaFileCanvas: TMetaFileCanvas;
    lDC: HDC;
    lPrinter: TRMPrinter;
    lBitmap: TBitmap;
    lCanvasRect: TRect;
    lWidth, lHeight: Integer;
  begin
    lPrinter := RMPrinter;
    if lPrinter.DC <> 0 then
      lDC := lPrinter.DC
    else
      lDC := GetDC(0);

    lMetaFile := TMetaFile.Create;
    lBitmap := nil;
    lMetaFileCanvas := nil;
    try
      if aRender then
      begin
        lWidth := mmSaveWidth - mmSaveGapX * 2 - _CalcHFrameWidth(mmSaveFWLeft, mmSaveFWRight);
        lHeight := mmSaveHeight - mmSaveGapY * 2 - _CalcVFrameWidth(mmSaveFWTop, mmSaveFWBottom);
      end
      else
      begin
        lWidth := mmWidth - mmGapLeft * 2 - _CalcHFrameWidth(LeftFrame.mmWidth, RightFrame.mmWidth);
        lHeight := mmHeight - mmGapTop * 2 - _CalcVFrameWidth(TopFrame.mmWidth, BottomFrame.mmWidth);
      end;

      lWidth := Round(RMFromMMThousandths_Printer(lWidth, rmrtHorizontal, lPrinter));
      lHeight := Round(RMFromMMThousandths_Printer(lHeight, rmrtVertical, lPrinter));

      lCanvasRect := Rect(0, 0, lWidth, lHeight);
      lMetaFile.Width := lWidth;
      lMetaFile.Height := lHeight;

      lMetaFileCanvas := TMetaFileCanvas.Create(lMetaFile, lDC);
      lMetaFileCanvas.Brush.Style := bsClear;

      FEndCharPos := FormatRange(lMetaFileCanvas.Handle, lDC, lCanvasRect, lCharRange, aRender);
      FreeAndNil(lMetaFileCanvas);
      if lPrinter.DC = 0 then
        ReleaseDC(0, lDC);

      if aRender then
      begin
        if DocMode = rmdmDesigning then
        begin
          lBitmap := TBitmap.Create;
          lBitmap.Width := RealRect.Right - RealRect.Left + 1;
          lBitmap.Height := RealRect.Bottom - RealRect.Top + 1;
          lBitmap.Canvas.StretchDraw(Rect(0, 0, lBitmap.Width, lBitmap.Height), lMetaFile);
          Canvas.Draw(RealRect.Left, RealRect.Top, lBitmap);
        end
        else
          Canvas.StretchDraw(RealRect, lMetaFile);
      end;
    finally
      FreeAndNil(lMetaFile);
      FreeAndNil(lBitmap);
    end;
  end;

begin
  FEndCharPos := FStartCharPos;
  lCharRange.cpMax := -1;
  lCharRange.cpMin := FEndCharPos;
  if DocMode = rmdmPrinting then
    _ShowRichOnPrinter
  else
    _ShowRichOnScreen;
end;
{$WARNINGS ON}

procedure TRMRichView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  CalcGaps;
  with aCanvas do
  begin
    ShowBackground;
    FStartCharPos := 0;
    InflateRect(RealRect, -_CalcHFrameWidth(LeftFrame.spWidth, RightFrame.spWidth),
      -_CalcVFrameWidth(TopFrame.spWidth, BottomFrame.spWidth));
    if (spWidth > 0) and (spHeight > 0) then
      ShowRichText(True);
    ShowFrame;
  end;
  RestoreCoord;
end;

procedure TRMRichView.Prepare;
begin
  inherited Prepare;
  FStartCharPos := 0;
end;

procedure TRMRichView.GetMemoVariables;
begin
  if OutputOnly then Exit;

  if DrawMode = rmdmAll then
  begin
    Memo1.Assign(Memo);
    InternalOnBeforePrint(Memo1, Self);
    RMRxAssignRich(SRichEdit, FRichEdit);
    if not TextOnly then
      GetRichData(SRichEdit);

    if (not OutputOnly) and Assigned(OnBeforePrint) then
      OnBeforePrint(Self);
  end;
end;

procedure TRMRichView.PlaceOnEndPage(aStream: TStream);
var
  n: integer;
begin
  BeginDraw(Canvas);
  if not Visible then Exit;

  GetMemoVariables;
  if not Visible then
  begin
    DrawMode := rmdmAll;
    Exit;
  end;

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

function TRMRichView.CalcHeight: Integer;
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

function TRMRichView.RemainHeight: Integer;
begin
  DrawMode := rmdmAll;
  GetMemoVariables;
//  DrawMode := rmdmAfterCalcHeight;

  FStartCharPos := FEndCharPos + 1;
  ActualHeight := RMToMMThousandths(spGapTop * 2 + _CalcVFrameWidth(TopFrame.spWidth, BottomFrame.spWidth), rmutScreenPixels) +
    DoCalcHeight;
  Result := ActualHeight;
end;

procedure TRMRichView.LoadFromStream(aStream: TStream);
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

procedure TRMRichView.SaveToStream(aStream: TStream);
var
  b: Byte;
  liSavePos, liPos: Integer;
  liRichEdit: TJvRichEdit;
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

procedure TRMRichView.GetBlob;
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

procedure TRMRichView.ShowEditor;
var
  tmpForm: TRMRichForm;
begin
  tmpForm := TRMRichForm.Create(Application);
  try
    tmpForm.FView := Self;
    RMRxAssignRich(tmpForm.Editor, FRichEdit);
    if tmpForm.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      RMRxAssignRich(FRichEdit, tmpForm.Editor);
      RMDesigner.AfterChange;
    end;
  finally
    tmpForm.Free;
  end;
end;

procedure TRMRichView.DefinePopupMenu(Popup: TRMCustomMenuItem);
begin
  inherited DefinePopupMenu(Popup);
end;

procedure TRMRichView.LoadFromRichEdit(aRichEdit: TJvRichEdit);
begin
  RMRxAssignRich(FRichEdit, aRichEdit);
end;

function TRMRichView.GetViewCommon: string;
begin
  Result := '[Rx Rich]';
end;

procedure TRMRichView.ClearContents;
begin
  FRichEdit.Clear;
  inherited;
end;

function TRMRichView.GetExportMode: TRMExportMode;
begin
  Result := rmemRtf;
end;

function TRMRichView.GetExportData: string;
var
  lTmp: TMemoryStream;
begin
  lTmp := TMemoryStream.Create;
  try
    FRichEdit.Lines.SaveToStream(lTmp);
    SetLength(Result, lTmp.Size);
    lTmp.Position := 0;
    lTmp.Read(Result[1], lTmp.Size);
  finally
    lTmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMRxRichView }

constructor TRMRxRichView.Create;
begin
  inherited Create;
  BaseName := 'RxRich';
end;

destructor TRMRxRichView.Destroy;
begin
  inherited Destroy;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMRxRichForm}

procedure TRMRichForm.Localize;
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
  RMSetStrProp(btnSuperscript, 'Hint', rmRes + 580);
  RMSetStrProp(btnSubscript, 'Hint', rmRes + 581);

  ItmCut.Caption := btnCut.Hint;
  ItmCopy.Caption := btnCopy.Hint;
  ItmPaste.Caption := btnPaste.Hint;
  RMSetStrProp(MenuFile, 'Caption', rmRes + 154);
  RMSetStrProp(ItemFileNew, 'Caption', rmRes + 155);
  RMSetStrProp(ItemFileOpen, 'Caption', rmRes + 156);
  RMSetStrProp(ItemFileSaveAs, 'Caption', rmRes + 188);
  RMSetStrProp(ItemFilePrint, 'Caption', rmRes + 159);
  RMSetStrProp(ItemFileExit, 'Caption', rmRes + 162);
  RMSetStrProp(MenuEdit, 'Caption', rmRes + 163);
  RMSetStrProp(ItemEditUndo, 'Caption', rmRes + 164);
  RMSetStrProp(ItemEditRedo, 'Caption', rmRes + 165);
  RMSetStrProp(ItemEditCut, 'Caption', rmRes + 166);
  RMSetStrProp(ItemEditCopy, 'Caption', rmRes + 167);
  RMSetStrProp(ItemEditPaste, 'Caption', rmRes + 168);
  RMSetStrProp(ItemEditPasteSpecial, 'Caption', rmRes + 572);
  RMSetStrProp(ItemEditSelectAll, 'Caption', rmRes + 170);
  RMSetStrProp(ItemEditFind, 'Caption', rmRes + 582);
  RMSetStrProp(ItemEditFindNext, 'Caption', rmRes + 583);
  RMSetStrProp(ItemEditReplace, 'Caption', rmRes + 584);
  RMSetStrProp(ItemEditObjProps, 'Caption', rmRes + 585);
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

procedure TRMRichForm.FocusEditor;
begin
  with Editor do
  begin
    if CanFocus then
      SetFocus;
  end;
end;

procedure TRMRichForm.SelectionChange(Sender: TObject);
var
  lFont: TFont;
  lFontHeight: Integer;
begin
  with Editor.Paragraph do
  begin
    try
      FUpdating := True;
      FRuler.UpdateInd;
      BtnFontBold.Down := fsBold in CurrText.Style;
      BtnFontItalic.Down := fsItalic in CurrText.Style;
      BtnFontUnderline.Down := fsUnderline in CurrText.Style;
      BtnBullets.Down := Boolean(Numbering);
      BtnSuperscript.Down := CurrText.SubscriptStyle = ssSuperscript;
      BtnSubscript.Down := CurrText.SubscriptStyle = ssSubscript;

      lFont := TFont.Create;
      lFont.Size := CurrText.Size;
      lFontHeight := lFont.Height;
      lFont.Free;
      RMSetFontSize(TComboBox(FCmbFontSize), lFontHeight, CurrText.Size);

      FCmbFont.FontName := CurrText.Name;
      case Ord(Alignment) of
        0: BtnAlignLeft.Down := True;
        1: BtnAlignRight.Down := True;
        2: BtnAlignCenter.Down := True;
      end;
      UpdateCursorPos;
    finally
      FUpdating := False;
    end;
  end;
end;

function TRMRichForm.CurrText: TJvTextAttributes;
begin
  if Editor.SelLength > 0 then
    Result := Editor.SelAttributes
  else
    Result := Editor.WordAttributes;
end;

procedure TRMRichForm.SetFileName(const FileName: string);
begin
  FFileName := FileName;
  Editor.Title := ExtractFileName(FileName);
end;

procedure TRMRichForm.SetEditRect;
var
  R: TRect;
  Offs: Integer;
begin
  with Editor do
  begin
    if SelectionBar then
      Offs := 3
    else
      Offs := 0;
    R := Rect(GutterWid + Offs, 0, ClientWidth - GutterWid, ClientHeight);
    SendMessage(Handle, EM_SETRECT, 0, Longint(@R));
  end;
end;

{ Event Handlers }

procedure TRMRichForm.FormCreate(Sender: TObject);
var
  i, liOffset: Integer;
  s, s1: string;
begin
  Localize;
  Editor := TJvRichEdit.Create(Self);
  with Editor do
  begin
    Parent := Self;
    Align := alClient;
    HideSelection := False;
    Editor.PopupMenu := Self.EditPopupMenu;
    WantTabs := False;
    ScrollBars := ssBoth;

    OnTextNotFound := EditorTextNotFound;
    OnSelectionChange := SelectionChange;
    OnProtectChange := EditorProtectChange;
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

  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SetFileName('Untitled');
  HandleNeeded;
  SelectionChange(Self);
{$IFDEF OPENPICTUREDLG}
  Editor.OnCloseFindDialog := EditFindDialogClose;
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

//  FClipboardMonitor := TJvClipboardMonitor.Create(Self);
//  FClipboardMonitor.OnChange := ClipboardChanged;
  BtnSuperscript.Enabled := RichEditVersion >= 2;
  BtnSubscript.Enabled := RichEditVersion >= 2;
  FBtnBackColor.Enabled := RichEditVersion >= 2;
end;

procedure TRMRichForm.PerformFileOpen(const AFileName: string);
begin
  FProtectChanging := True;
  try
    Editor.Lines.LoadFromFile(AFileName);
  finally
    FProtectChanging := False;
  end;
  SetFileName(AFileName);
  Editor.SetFocus;
  Editor.Modified := False;
  SetModified(False);
end;

procedure TRMRichForm.FormResize(Sender: TObject);
begin
  SetEditRect;
  SelectionChange(Sender);
end;

procedure TRMRichForm.FormPaint(Sender: TObject);
begin
  SetEditRect;
end;

procedure TRMRichForm.UpdateCursorPos;
var
  CharPos: TPoint;
begin
  CharPos := Editor.CaretPos;
  StatusBar.Panels[0].Text := Format('行: %3d  列: %3d', [CharPos.Y + 1, CharPos.X + 1]);
  BtnCopy.Enabled := Editor.SelLength > 0;
  ItemEditCopy.Enabled := BtnCopy.Enabled;
  ItmCopy.Enabled := BtnCopy.Enabled;
  BtnCut.Enabled := ItemEditCopy.Enabled;
  ItmCut.Enabled := btnCut.Enabled;
  ItemEditPasteSpecial.Enabled := btnCopy.Enabled;
  ItemEditCut.Enabled := ItemEditCopy.Enabled;
  ItemEditObjProps.Enabled := Editor.SelectionType = [stObject];
end;

procedure TRMRichForm.FormShow(Sender: TObject);
begin
  UpdateCursorPos;
  RichEditChange(nil);
  SetModified(FALSE);
  FocusEditor;
  ClipboardChanged(nil);
end;

procedure TRMRichForm.RichEditChange(Sender: TObject);
begin
  SetModified(Editor.Modified);
  { Undo }
  BtnUndo.Enabled := Editor.CanUndo;
  ItemEditUndo.Enabled := btnUndo.Enabled;
  ItemEditUndo.Caption := '取消(&U) ' + UndoNames[Editor.UndoName];
  { Redo }
  ItemEditRedo.Enabled := Editor.CanRedo;
  btnRedo.Enabled := ItemEditRedo.Enabled;
  ItemEditRedo.Caption := '重复(&R) ' + UndoNames[Editor.RedoName];
end;

procedure TRMRichForm.SetModified(Value: Boolean);
begin
  if Value then
    StatusBar.Panels[1].Text := '修改'
  else
    StatusBar.Panels[1].Text := '';
end;

procedure TRMRichForm.ClipboardChanged(Sender: TObject);
var
  E: Boolean;
begin
  E := Editor.CanPaste;
  btnPaste.Enabled := E;
  ItemEditPaste.Enabled := E;
  ItemEditPasteSpecial.Enabled := E;
  ItmPaste.Enabled := E;
end;

procedure TRMRichForm.FormDestroy(Sender: TObject);
begin
//  FClipboardMonitor.Free;
  FRuler.Free;
end;

procedure TRMRichForm.EditorTextNotFound(Sender: TObject;
  const FindText: string);
begin
  MessageDlg(Format('Text "%s" not found.', [FindText]), mtWarning,
    [mbOk], 0);
end;

{$IFDEF OPENPICTUREDLG}

procedure TRMRichForm.EditFindDialogClose(Sender: TObject; Dialog: TFindDialog);
begin
  FocusEditor;
end;
{$ENDIF}

procedure TRMRichForm.EditorProtectChange(Sender: TObject; StartPos,
  EndPos: Integer; var AllowChange: Boolean);
begin
  AllowChange := FProtectChanging;
end;

procedure TRMRichForm.EditSelectAll(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TRMRichForm.btnFileNewClick(Sender: TObject);
begin
  SetFileName('Untitled');
  FProtectChanging := True;
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
    SelectionChange(nil);
  finally
    FProtectChanging := False;
  end;
end;

procedure TRMRichForm.btnFileOpenClick(Sender: TObject);
begin
  OpenDialog.Filter := RMLoadStr(SRTFFile) + '(*.rtf)|*.rtf' + '|' +
    RMLoadStr(STextFile) + '(*.txt)|*.txt';
  if OpenDialog.Execute then
  begin
    PerformFileOpen(OpenDialog.FileName);
    Editor.ReadOnly := ofReadOnly in OpenDialog.Options;
  end;
end;

procedure TRMRichForm.btnFileSaveClick(Sender: TObject);
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

procedure TRMRichForm.btnFindClick(Sender: TObject);
begin
  with Editor do
    FindDialog(SelText);
end;

procedure TRMRichForm.btnCutClick(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TRMRichForm.btnCopyClick(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TRMRichForm.btnPasteClick(Sender: TObject);
begin
  Editor.PasteFromClipboard;
end;

procedure TRMRichForm.btnUndoApplyAlign(Sender: TObject; Align: TAlign;
  var Apply: Boolean);
begin
  Editor.Undo;
  RichEditChange(nil);
  SelectionChange(nil);
end;

procedure TRMRichForm.btnRedoClick(Sender: TObject);
begin
  Editor.Redo;
  RichEditChange(nil);
  SelectionChange(nil);
end;

procedure TRMRichForm.btnFontBoldClick(Sender: TObject);
begin
  if FUpdating then Exit;

  if btnFontBold.Down then
    CurrText.Style := CurrText.Style + [fsBold]
  else
    CurrText.Style := CurrText.Style - [fsBold];
end;

procedure TRMRichForm.btnFontItalicClick(Sender: TObject);
begin
  if FUpdating then Exit;

  if btnFontItalic.Down then
    CurrText.Style := CurrText.Style + [fsItalic]
  else
    CurrText.Style := CurrText.Style - [fsItalic];
end;

procedure TRMRichForm.btnFontUnderlineClick(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if btnFontUnderline.Down then
    CurrText.Style := CurrText.Style + [fsUnderline]
  else
    CurrText.Style := CurrText.Style - [fsUnderline];
end;

procedure TRMRichForm.btnAlignLeftClick(Sender: TObject);
begin
  if FUpdating then
    Exit;
  Editor.Paragraph.Alignment := TParaAlignment(TComponent(Sender).Tag);
end;

procedure TRMRichForm.btnBulletsClick(Sender: TObject);
begin
  if FUpdating then
    Exit;
  Editor.Paragraph.Numbering := TJvNumbering(btnBullets.Down);
end;

procedure TRMRichForm.ItemFileSaveAsClick(Sender: TObject);
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

procedure TRMRichForm.ItemFilePrintClick(Sender: TObject);
begin
  if PrintDialog.Execute then
    Editor.Print(FFileName);
end;

procedure TRMRichForm.ItemFormatFontClick(Sender: TObject);
begin
  FontDialog.Font.Assign(Editor.SelAttributes);
  if FontDialog.Execute then
  begin
    CurrText.Name := FontDialog.Font.Name;
    CurrText.Charset := FontDialog.Font.Charset;
    CurrText.Style := FontDialog.Font.Style;
    CurrText.Color := FontDialog.Font.Color;
    CurrText.Size := FontDialog.Font.Size;
    CurrText.Pitch := FontDialog.Font.Pitch;
//    CurrText.Assign(FontDialog.Font);
  end;

  FocusEditor;
end;

procedure TRMRichForm.ItemInserObjectClick(Sender: TObject);
begin
  Editor.InsertObjectDialog;
end;

procedure TRMRichForm.ItemInsertPictureClick(Sender: TObject);
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

procedure TRMRichForm.btnUndoClick(Sender: TObject);
begin
  Editor.Undo;
  RichEditChange(nil);
  SelectionChange(nil);
end;

procedure TRMRichForm.ItemEditPasteSpecialClick(Sender: TObject);
begin
  try
    Editor.PasteSpecialDialog;
  finally
    FocusEditor;
  end;
end;

procedure TRMRichForm.ItemEditFindNextClick(Sender: TObject);
begin
  if not Editor.FindNext then
  begin
    Exit;
//    Beep;
  end;

  FocusEditor;
end;

procedure TRMRichForm.ItemEditReplaceClick(Sender: TObject);
begin
  with Editor do
    ReplaceDialog(SelText, '');
end;

procedure TRMRichForm.ItemEditObjPropsClick(Sender: TObject);
begin
  Editor.ObjectPropertiesDialog;
end;

procedure TRMRichForm.btnInsertFieldClick(Sender: TObject);
var
  s: string;
begin
  if RMDesigner <> nil then
  begin
    s := RMDesigner.InsertExpression(FView);
    if s <> '' then
      Editor.SelText := s;
  end;
end;

procedure TRMRichForm.btnSuperscriptClick(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if btnSuperscript.Down then
    CurrText.SubscriptStyle := ssSuperscript
  else if btnSubscript.Down then
    CurrText.SubscriptStyle := ssSubscript
  else
    CurrText.SubscriptStyle := ssNone;
end;

procedure TRMRichForm.ItemEditSelectAllClick(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TRMRichForm.OnCmbFontChange(Sender: TObject);
begin
  if FUpdating then
    Exit;
  CurrText.Name := FCmbFont.FontName;
  if RMIsChineseGB then
  begin
    if ByteType(FCmbFont.FontName, 1) = mbSingleByte then
      CurrText.Charset := ANSI_CHARSET
    else
      CurrText.Charset := GB2312_CHARSET;
  end;
end;

procedure TRMRichForm.OnCmbFontSizeChange(Sender: TObject);
var
  liFontSize: Integer;
  lFont: TFont;
begin
  if FUpdating then Exit;

  liFontSize := RMGetFontSize(TComboBox(FCmbFontSize));
  if liFontSize > 0 then
    CurrText.Size := liFontSize
  else
  begin
    lFont := TFont.Create;
    lFont.Height := liFontSize;
    liFontSize := lFont.Size;
    CurrText.Size := liFontSize;
    lFont.Free;
  end;
end;

procedure TRMRichForm.btnOKClick(Sender: TObject);
begin
  OnResize := nil;
  ModalResult := mrOK;
end;

procedure TRMRichForm.btnCancelClick(Sender: TObject);
begin
  OnResize := nil;
  ModalResult := mrCancel;
end;

procedure TRMRichForm.OnColorChangeEvent(Sender: TObject);
begin
  if Sender = FBtnFontColor then
    CurrText.Color := FBtnFontColor.CurrentColor
  else
    CurrText.BackColor := FBtnBackColor.CurrentColor;
end;

procedure TRMRichForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  OnResize := nil;
end;

procedure TRMRichForm.ItemFormatParagraphClick(Sender: TObject);
var
  tmp: TRMParaFormatDlg;
begin
  tmp := TRMParaFormatDlg.Create(nil);
  try
    tmp.SpacingBox.Enabled := (RichEditVersion >= 2);
    tmp.UpDownLeftIndent.Position := Editor.Paragraph.LeftIndent;
    tmp.UpDownRightIndent.Position := Editor.Paragraph.RightIndent;
    tmp.UpDownFirstIndent.Position := Editor.Paragraph.FirstIndent;
    tmp.Alignment.ItemIndex := Ord(Editor.Paragraph.Alignment);
    tmp.UpDownSpaceBefore.Position := Editor.Paragraph.SpaceBefore;
    tmp.UpDownSpaceAfter.Position := Editor.Paragraph.SpaceAfter;
    tmp.UpDownLineSpacing.Position := Editor.Paragraph.LineSpacing;
    if tmp.ShowModal = mrOK then
    begin
      Editor.Paragraph.LeftIndent := tmp.UpDownLeftIndent.Position;
      Editor.Paragraph.RightIndent := tmp.UpDownRightIndent.Position;
      Editor.Paragraph.FirstIndent := tmp.UpDownFirstIndent.Position;
      Editor.Paragraph.Alignment := TParaAlignment(tmp.Alignment.ItemIndex);
      Editor.Paragraph.SpaceBefore := tmp.UpDownSpaceBefore.Position;
      Editor.Paragraph.SpaceAfter := tmp.UpDownSpaceAfter.Position;
      if tmp.UpDownLineSpacing.Position > 0 then
        Editor.Paragraph.LineSpacingRule := lsSpecifiedOrMore
      else
        Editor.Paragraph.LineSpacingRule := lsSingle;
      Editor.Paragraph.LineSpacing := tmp.UpDownLineSpacing.Position;
    end;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMRxRichView_LoadFromRichEdit(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMRichView(Args.Obj).LoadFromRichEdit(TJvRichEdit(V2O(Args.Values[0])));
end;

procedure TRMRxRichView_LoadFromFile(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMRichView(Args.Obj).RichEdit.Lines.LoadFromFile(Args.Values[0]);
end;


procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMRichView, 'TRMRichView');
    AddClass('ReportMachine', TJvRichEdit, 'TJvRichEdit');
    AddClass('ReportMachine', TRMRxRichView, 'TRMRxRichView');

    AddGet(TRMRichView, 'LoadFromRichEdit', TRMRxRichView_LoadFromRichEdit, 1, [0], varEmpty);
    AddGet(TRMRichView, 'LoadFromFile', TRMRxRichView_LoadFromFile, 1, [0], varEmpty);
  end;
end;

initialization
  RMRegisterObjectByRes(TRMRichView, 'RM_RichObject', RMLoadStr(SInsRichObject), TRMRichForm);
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

end.

