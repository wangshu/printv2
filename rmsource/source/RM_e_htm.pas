
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{           Html export filter            }
{                                         }
{*****************************************}

unit RM_e_htm;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, ExtDlgs, RM_Class, RM_e_main
{$IFDEF RXGIF}, JvGIF{$ENDIF}
{$IFDEF JPEG}, JPeg{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  CLinkForeColor = $00FF0000; // BGR
  CLinkBackColor = $00FFFFFF; // BGR
  CLinkHoverForeColor = $00FFFFFF; // BGR
  CLinkHoverBackColor = $00FF0000; // BGR

type
 { TRMHTMExport }
  TRMHTMExport = class(TRMMainExportFilter)
  private
    FImgFileNames: TStringList;
    FRepFileNames: TStringList;
    FCreateMHTFile: Boolean;

    FImageDir: string;
    FImageEncodeDir: string;
    FImageCreateDir: string;
    FAltText: string;
    FLinkTextFirst: string;
    FLinkTextNext: string;
    FLinkTextPrev: string;
    FLinkTextLast: string;
    FLinkFont: TFont;
    FLinkBackColor: TColor;
    FLinkHoverForeColor: TColor;
    FLinkHoverBackColor: TColor;
    FLinkImgSRCFirst: string;
    FLinkImgSRCNext: string;
    FLinkImgSRCPrev: string;
    FLinkImgSRCLast: string;
    FSeparateFilePerPage: Boolean;
    FShowNavigator: Boolean;
    FUseTextLinks: Boolean;

    FSingleFile: Boolean;
    FOptimizeForIE: Boolean;
    FCSSClasses: TStringList;
    FImagesStream: TMemoryStream;

    FBeforeSaveGraphic: TBeforeSaveGraphicEvent;
    FAfterSaveGraphic: TAfterSaveGraphicEvent;

    function GetImgFileCount: Integer;
    function GetRepFileCount: Integer;
    procedure SetLinkFont(const Value: TFont);
    function SaveBitmapAs(aBmp: TBitmap; aImgFormat: TRMEFImageFormat
{$IFDEF JPEG}; aJPEGQuality: TJPEGQualityRange{$ENDIF}; const aBaseName: string): string;
    function GetNativeText(const aText: string): string;
    function GetOffsetFromTop: Integer;

    procedure WriteHeader;
    procedure WriteFooter;
  protected
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure InternalOnePage(aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ImgFileCount: Integer read GetImgFileCount;
    property ImgFileNames: TStringList read FImgFileNames;
    property RepFileCount: Integer read GetRepFileCount;
    property RepFileNames: TStringList read FRepFileNames;
    function ShowModal: Word; override;
  published
    property PixelFormat;
    property ImageDir: string read FImageDir write FImageDir;
    property LinkTextFirst: string read FLinkTextFirst write FLinkTextFirst;
    property LinkTextNext: string read FLinkTextNext write FLinkTextNext;
    property LinkTextPrev: string read FLinkTextPrev write FLinkTextPrev;
    property LinkTextLast: string read FLinkTextLast write FLinkTextLast;
    property LinkBackColor: TColor read FLinkBackColor write FLinkBackColor default CLinkBackColor;
    property LinkHoverForeColor: TColor read FLinkHoverForeColor write FLinkHoverForeColor default CLinkHoverForeColor;
    property LinkHoverBackColor: TColor read FLinkHoverBackColor write FLinkHoverBackColor default CLinkHoverBackColor;
    property LinkImgSRCFirst: string read FLinkImgSRCFirst write FLinkImgSRCFirst;
    property LinkImgSRCNext: string read FLinkImgSRCNext write FLinkImgSRCNext;
    property LinkImgSRCPrev: string read FLinkImgSRCPrev write FLinkImgSRCPrev;
    property LinkImgSRCLast: string read FLinkImgSRCLast write FLinkImgSRCLast;
    property LinkFont: TFont read FLinkFont write SetLinkFont;
    property SeparateFilePerPage: Boolean read FSeparateFilePerPage write FSeparateFilePerPage default True;
    property ShowNavigator: Boolean read FShowNavigator write FShowNavigator default True;
    property UseTextLinks: Boolean read FUseTextLinks write FUseTextLinks default True;
    property OptimizeForIE: Boolean read FOptimizeForIE write FOptimizeForIE default True;
    property SingleFile: Boolean read FSingleFile write FSingleFile default False;
    property CreateMHTFile: Boolean read FCreateMHTFile write FCreateMHTFile;

    property BeforeSaveGraphic: TBeforeSaveGraphicEvent read FBeforeSaveGraphic write FBeforeSaveGraphic;
    property AfterSaveGraphic: TAfterSaveGraphicEvent read FAfterSaveGraphic write FAfterSaveGraphic;
  end;

 { TRMHTMExportForm }
  TRMHTMLExportForm = class(TForm)
    ColorDialog: TColorDialog;
    OpenPictureDialog: TOpenPictureDialog;
    FontDialog: TFontDialog;
    btnOK: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    lblImageFolder: TLabel;
    btnImages: TSpeedButton;
    chkExportFrames: TCheckBox;
    gbExportImages: TGroupBox;
    lblExportImageFormat: TLabel;
    lblJPEGQuality: TLabel;
    cmbImageFormat: TComboBox;
    edJPEGQuality: TEdit;
    UpDown1: TUpDown;
    edImageDirectory: TEdit;
    TabSheet2: TTabSheet;
    chkSingleFile: TCheckBox;
    chkSepFilePerPage: TCheckBox;
    gbShowNavigator: TGroupBox;
    lblBackGroundColor: TLabel;
    lblHoverForeColor: TLabel;
    lblHoverBackColor: TLabel;
    shpBackgroundColor: TShape;
    shpHoverForeColor: TShape;
    shpHoverBackColor: TShape;
    gbUseLinks: TGroupBox;
    pcShowNavigator: TPageControl;
    tsUseTextLinks: TTabSheet;
    lblFirst: TLabel;
    lblLast: TLabel;
    lblNext: TLabel;
    lblPrevious: TLabel;
    lblLinkCaptions: TLabel;
    btnSetFont: TButton;
    edFirst: TEdit;
    edPrevious: TEdit;
    edNext: TEdit;
    edLast: TEdit;
    tsUseGraphicLinks: TTabSheet;
    lblUseGraphicLinksFirst: TLabel;
    lblUseGraphicLinksPrevious: TLabel;
    lblUseGraphicLinksNext: TLabel;
    lblUseGraphicLinksLast: TLabel;
    btnFirst: TSpeedButton;
    btnPrevious: TSpeedButton;
    btnNext: TSpeedButton;
    btnLast: TSpeedButton;
    lblImageSource: TLabel;
    edUseGraphicLinksFirst: TEdit;
    edUseGraphicLinksPrevious: TEdit;
    edUseGraphicLinksLast: TEdit;
    edUseGraphicLinksNext: TEdit;
    chkCreateMHTFile: TCheckBox;
    chkExportImages: TCheckBox;
    Label4: TLabel;
    cmbPixelFormat: TComboBox;
    chkShowNavigator: TCheckBox;
    rbtnUseTextLinks: TRadioButton;
    rbtnUseGraphicLinks: TRadioButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnImagesClick(Sender: TObject);
    procedure chkShowNavigatorClick(Sender: TObject);
    procedure shpHoverForeColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure shpHoverForeColorMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure rbtnUseTextLinksClick(Sender: TObject);
    procedure rbtnUseGraphicLinksClick(Sender: TObject);
    procedure btnSetFontClick(Sender: TObject);
    procedure chkExportImagesClick(Sender: TObject);
    procedure cmbImageFormatChange(Sender: TObject);
    procedure edJPEGQualityKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkSingleFileClick(Sender: TObject);
    procedure chkCreateMHTFileClick(Sender: TObject);
  private
    FExportFilter: TRMExportFilter;
    MousePoint: TPoint;
    procedure Localize;
  protected
    property ExportFilter: TRMExportFilter read FExportFilter write FExportFilter;
  public
  end;

implementation

{$R *.DFM}

uses RM_Common, RM_Const, RM_Utils, RM_DsgCtrls;

const
  CPageEndLineWidth = 2;
  CRLF = #13#10;

  MIME_ENCODED_LINE_BREAK = 76;
  MIME_DECODED_LINE_BREAK = MIME_ENCODED_LINE_BREAK div 4 * 3;
  MIME_BUFFER_SIZE = MIME_DECODED_LINE_BREAK * 3 * 4 * 4;

  MIME_ENCODE_TABLE: array[0..63] of Byte = (
    065, 066, 067, 068, 069, 070, 071, 072, //  00 - 07
    073, 074, 075, 076, 077, 078, 079, 080, //  08 - 15
    081, 082, 083, 084, 085, 086, 087, 088, //  16 - 23
    089, 090, 097, 098, 099, 100, 101, 102, //  24 - 31
    103, 104, 105, 106, 107, 108, 109, 110, //  32 - 39
    111, 112, 113, 114, 115, 116, 117, 118, //  40 - 47
    119, 120, 121, 122, 048, 049, 050, 051, //  48 - 55
    052, 053, 054, 055, 056, 057, 043, 047); // 56 - 63
  MIME_PAD_CHAR = Byte('=');

type
  PByte4 = ^TByte4;
  TByte4 = packed record
    b1: Byte;
    b2: Byte;
    b3: Byte;
    b4: Byte;
  end;

  PByte3 = ^TByte3;
  TByte3 = packed record
    b1: Byte;
    b2: Byte;
    b3: Byte;
  end;

  THackMemoView = class(TRMCustomMemoView)
  end;

  THackFilter = class(TRMExportFilter)
  end;

	THackRMIEMData = class(TRMIEMData);

{ ---------------------------------------------------------------------------- }
{ Stream Encoding & Decoding
{ ---------------------------------------------------------------------------- }

procedure MimeEncodeNoCRLF(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);
var
  B, InnerLimit, OuterLimit: Cardinal;
  InPtr: PByte3;
  OutPtr: PByte4;
begin
  if InputByteCount = 0 then Exit;

  InPtr := @InputBuffer;
  OutPtr := @OutputBuffer;

  OuterLimit := InputByteCount div 3 * 3;

  InnerLimit := Cardinal(InPtr);
  Inc(InnerLimit, OuterLimit);

  { Last line loop. }
  while Cardinal(InPtr) < InnerLimit do
  begin
      { Read 3 bytes from InputBuffer. }
    B := InPtr^.b1;
    B := B shl 8;
    B := B or InPtr^.b2;
    B := B shl 8;
    B := B or InPtr^.b3;
    Inc(InPtr);
      { Write 4 bytes to OutputBuffer (in reverse order). }
    OutPtr^.b4 := MIME_ENCODE_TABLE[B and $3F];
    B := B shr 6;
    OutPtr^.b3 := MIME_ENCODE_TABLE[B and $3F];
    B := B shr 6;
    OutPtr^.b2 := MIME_ENCODE_TABLE[B and $3F];
    B := B shr 6;
    OutPtr^.b1 := MIME_ENCODE_TABLE[B];
    Inc(OutPtr);
  end;

  { End of data & padding. }
  case InputByteCount - OuterLimit of
    1:
      begin
        B := InPtr^.b1;
        B := B shl 4;
        OutPtr.b2 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b1 := MIME_ENCODE_TABLE[B];
        OutPtr.b3 := MIME_PAD_CHAR; { Pad remaining 2 bytes. }
        OutPtr.b4 := MIME_PAD_CHAR;
      end;
    2:
      begin
        B := InPtr^.b1;
        B := B shl 8;
        B := B or InPtr^.b2;
        B := B shl 2;
        OutPtr.b3 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b2 := MIME_ENCODE_TABLE[B and $3F];
        B := B shr 6;
        OutPtr.b1 := MIME_ENCODE_TABLE[B];
        OutPtr.b4 := MIME_PAD_CHAR; { Pad remaining byte. }
      end;
  end;
end;

procedure MimeEncodeFullLines(const InputBuffer; const InputByteCount: Cardinal; out OutputBuffer);
var
  B, InnerLimit, OuterLimit: Cardinal;
  InPtr: PByte3;
  OutPtr: PByte4;
begin
  { Do we have enough input to encode a full line? }
  if InputByteCount < MIME_DECODED_LINE_BREAK then Exit;

  InPtr := @InputBuffer;
  OutPtr := @OutputBuffer;

  InnerLimit := Cardinal(InPtr);
  Inc(InnerLimit, MIME_DECODED_LINE_BREAK);

  OuterLimit := Cardinal(InPtr);
  Inc(OuterLimit, InputByteCount);

  { Multiple line loop. }
  repeat

    { Single line loop. }
    repeat
      { Read 3 bytes from InputBuffer. }
      B := InPtr^.b1;
      B := B shl 8;
      B := B or InPtr^.b2;
      B := B shl 8;
      B := B or InPtr^.b3;
      Inc(InPtr);
      { Write 4 bytes to OutputBuffer (in reverse order). }
      OutPtr^.b4 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b3 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b2 := MIME_ENCODE_TABLE[B and $3F];
      B := B shr 6;
      OutPtr^.b1 := MIME_ENCODE_TABLE[B];
      Inc(OutPtr);
    until Cardinal(InPtr) >= InnerLimit;

    { Write line break (CRLF). }
    OutPtr^.b1 := 13;
    OutPtr^.b2 := 10;
    Inc(Cardinal(OutPtr), 2);

    Inc(InnerLimit, MIME_DECODED_LINE_BREAK);
  until InnerLimit > OuterLimit;
end;

function MimeEncodedSize(const InputSize: Cardinal): Cardinal;
begin
  if InputSize > 0 then
    Result := (InputSize + 2) div 3 * 4 + (InputSize - 1) div MIME_DECODED_LINE_BREAK * 2
  else
    Result := InputSize;
end;

procedure MimeEncodeStream(const InputStream: TStream; const OutputStream: TStream);
var
  InputBuffer: array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: array[0..(MIME_BUFFER_SIZE + 2) div 3 * 4 + MIME_BUFFER_SIZE div MIME_DECODED_LINE_BREAK * 2 - 1] of Byte;
  BytesRead: Cardinal;
  IDelta, ODelta: Cardinal;
begin
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));

  while BytesRead = SizeOf(InputBuffer) do
  begin
    MimeEncodeFullLines(InputBuffer, SizeOf(InputBuffer), OutputBuffer);
    OutputStream.Write(OutputBuffer, SizeOf(OutputBuffer));
    BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
  end;

  MimeEncodeFullLines(InputBuffer, BytesRead, OutputBuffer);

  IDelta := BytesRead div MIME_DECODED_LINE_BREAK; // Number of lines processed.
  ODelta := IDelta * (MIME_ENCODED_LINE_BREAK + 2);
  IDelta := IDelta * MIME_DECODED_LINE_BREAK;
  MimeEncodeNoCRLF(Pointer(Cardinal(@InputBuffer) + IDelta)^, BytesRead - IDelta, Pointer(Cardinal(@OutputBuffer) + ODelta)^);

  OutputStream.Write(OutputBuffer, MimeEncodedSize(BytesRead));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMHTMExport}

constructor TRMHTMExport.Create(AOwner: TComponent);
begin
  inherited;
  RMRegisterExportFilter(Self, RMLoadStr(SHTMFile) + ' (*.htm)' , '*.htm');

  CreateFile := True;
  CanMangeRotationText := False;

  FImageDir := '';
  FAltText := '';
  FLinkTextFirst := RMLoadStr(rmRes + 1796);
  FLinkTextPrev := RMLoadStr(rmRes + 1795);
  FLinkTextNext := RMLoadStr(rmRes + 1794);
  FLinkTextLast := RMLoadStr(rmRes + 1793);
  FLinkFont := TFont.Create;

  FLinkFont.Size := 18;
  FLinkFont.Color := CLinkForeColor;
  FLinkBackColor := CLinkBackColor;
  FLinkHoverForeColor := CLinkHoverForeColor;
  FLinkHoverBackColor := CLinkHoverBackColor;
  FLinkImgSRCFirst := '';
  FLinkImgSRCNext := '';
  FLinkImgSRCPrev := '';
  FLinkImgSRCLast := '';
  FSeparateFilePerPage := True;
  FShowNavigator := True;
  FUseTextLinks := True;
  FSingleFile := False;

  FCSSClasses := TStringList.Create;
  FOptimizeForIE := True;
end;

destructor TRMHTMExport.Destroy;
begin
  FLinkFont.Free;
  FCssClasses.Free;
  inherited Destroy;
end;

function TRMHTMExport.GetImgFileCount: Integer;
begin
  Result := FImgFileNames.Count;
end;

function TRMHTMExport.GetRepFileCount: Integer;
begin
  Result := FRepFileNames.Count;
end;

procedure TRMHTMExport.SetLinkFont(const Value: TFont);
begin
  FLinkFont.Assign(Value);
end;

procedure TRMHTMExport.OnBeginDoc;
var
  K: Integer;
  TempDir: string;
begin
  inherited;
  FRepFileNames := TStringList.Create;
  FImgFileNames := TStringList.Create;

  SingleFile := SingleFile or FCreateMHTFile;
  if FCreateMHTFile then
    FImagesStream := TMemoryStream.Create
  else
    FImagesStream := nil;

  FRepFileNames.Add(FileName);
  if SeparateFilePerPage or (ParentReport.EndPages.Count <> 1) then
  begin
    for K := 1 to (ParentReport.EndPages.Count - 1) do
      FRepFileNames.Add(ExtractFilePath(FileName) + RMMakeFileName(FileName, 'htm', K + 1));
  end;

  FImageEncodeDir := Trim(ImageDir);
  FImageCreateDir := ExtractFilePath(FileName);
  if FImageEncodeDir <> '' then
  begin
    TempDir := GetCurrentDir;
    SetCurrentDir(FImageCreateDir);
    FImageCreateDir := RMAppendTrailingBackslash(ExpandFileName(FImageEncodeDir));
    if not RMDirectoryExists(FImageCreateDir) then
      RMForceDirectories(FImageCreateDir);
    FImageEncodeDir := StringReplace(RMAppendTrailingBackslash(FImageEncodeDir), '\', '/', [rfReplaceAll]);
    SetCurrentDir(TempDir);
  end;
end;

procedure TRMHTMExport.OnEndDoc;
var
  lStream: TMemoryStream;
begin
  if FCreateMHTFile and (ExportStream.Size > 0) then
  begin
    lStream := TMemoryStream.Create;
    try
{----生成主文档----}
      WriteToStream(lStream, 'Content-Type: multipart/related;' + CRLF);
      WriteToStream(lStream, '	boundary="===Test MHT by Town===";' + CRLF);
      WriteToStream(lStream, '	type="text/html"' + CRLF);
      WriteToStream(lStream, '' + CRLF);
      WriteToStream(lStream, 'This is a mht sample Produced By Town' + CRLF); //您可以在这里写任何东西
      WriteToStream(lStream, 'This is a multi-part message in MIME format.' + CRLF);
      WriteToStream(lStream, '--===Test MHT by Town===' + CRLF);
      WriteToStream(lStream, 'Content-Type: text/html; charset=gb2312' + CRLF);
      WriteToStream(lStream, 'Content-Transfer-Encoding: 8bit' + CRLF);
      WriteToStream(lStream, '' + CRLF);

      ExportStream.Position := 0;
      lStream.CopyFrom(ExportStream, ExportStream.Size);
      ExportStream.Size := 0;

      WriteToStream(lStream, '--===Test MHT by Town===' + CRLF);
      lStream.Position := 0;
      ExportStream.CopyFrom(lStream, lStream.Size);

      lStream.Clear;
      if FImagesStream.Size > 0 then
      begin
        FImagesStream.Position := 0;
        ExportStream.CopyFrom(FImagesStream, FImagesStream.Size);
      end;
    finally
      lStream.Free;
    end;
  end;

  FRepFileNames.Free;
  FImgFileNames.Free;
  FImagesStream.Free;
  inherited OnEndDoc;
end;

const
  Bold: array[Boolean] of string = ('', ' bold');
  Italic: array[Boolean] of string = ('', ' italic');

  ANSICodePageIDs: array[0..13] of record
    ISOCode: string;
    WinCode: Integer;
  end = (
    (ISOCode: 'ISO-8859-11'; WinCode: 874), {Thai}
    (ISOCode: 'Windows-932'; WinCode: 932), {Japanese}
    (ISOCode: 'gb2312-80'; WinCode: 936), {Chinese (PRC, Singapore)}
    (ISOCode: 'Windows-949'; WinCode: 949), {Korean}
    (ISOCode: 'csbig5'; WinCode: 950), {Chinese (Taiwan, Hong Kong)}
    (ISOCode: 'ISO-10646'; WinCode: 1200), {Unicode (BMP of ISO 10646)}
    (ISOCode: 'ISO-8859-2'; WinCode: 1250), {Eastern European}
    (ISOCode: 'ISO-8859-5'; WinCode: 1251), {Latin/Cyrillic}
    (ISOCode: 'ISO-8859-1'; WinCode: 1252), {Latin 1 (US, Western Europe)}
    (ISOCode: 'ISO-8859-7'; WinCode: 1253), {Greek}
    (ISOCode: 'ISO-8859-9'; WinCode: 1254), {Turkish}
    (ISOCode: 'ISO-8859-8'; WinCode: 1255), {Hebrew}
    (ISOCode: 'ISO-8859-6'; WinCode: 1256), {Latin/Arabic}
    (ISOCode: 'ISO-8859-13'; WinCode: 1257) {Baltic}
    );

procedure TRMHTMExport.WriteHeader; // html文件头
var
  S: string;

  function _GetISOCharSet(WinCP: Integer): string;
  var
    I: Integer;
  begin
    Result := '';
    for I := Low(ANSICodePageIDs) to High(ANSICodePageIDs) do
    begin
      if ANSICodePageIDs[I].WinCode = WinCP then
      begin
        Result := ANSICodePageIDs[I].ISOCode;
        Break;
      end;
    end;
  end;

begin
  FCSSClasses.Clear;
  S := '<HTML>' + CRLF + '<HEAD>' + CRLF + '<TITLE>' + ParentReport.ReportInfo.Title + '</TITLE>' + CRLF +
    '<META HTTP-EQUIV="Content-Style-Type" CONTENT="text/css" CHARSET="' +
    _GetISOCharSet(GetACP) + '">' + CRLF;

  if not SingleFile and SeparateFilePerPage and ShowNavigator then
  begin
    S := S + '<STYLE>' + CRLF + '<!--' + CRLF +
      '  A:link {font: ' + IntToStr(FLinkFont.Size) + 'pt ' + FLinkFont.Name +
      '; text-decoration: none; color: ' + RMColorBGRToRGB(FLinkFont.Color) +
      '; background-color: ' + RMColorBGRToRGB(FLinkBackColor) +
      '}' + CRLF +
      '  A:visited {font: ' + IntToStr(FLinkFont.Size) + 'pt ' + FLinkFont.Name +
      '; text-decoration: none; color: ' + RMColorBGRToRGB(FLinkFont.Color) +
      '; background-color: ' + RMColorBGRToRGB(FLinkBackColor) +
      '}' + CRLF +
      '  A:hover {font: ' + IntToStr(FLinkFont.Size) + 'pt ' + FLinkFont.Name +
      '; text-decoration: none; color: ' + RMColorBGRToRGB(FLinkHoverForeColor) +
      '; background-color: ' + RMColorBGRToRGB(FLinkHoverBackColor) +
      '}' + CRLF +
      '-->' + CRLF + '</STYLE>';
  end;

  S := S + CRLF + '</HEAD>' + CRLF + CRLF + '<BODY BGCOLOR = "#FFFFFF">' + CRLF;
  WriteToStream(ExportStream, S);
end;

const
  ATextFormat = '<A %sTITLE="%s">%s</A>';
  AImageFormat = '<A %sTITLE="%s"><IMG SRC="%s" ALT="%s"></A>';

procedure TRMHTMExport.WriteFooter;
var
  S: string;

  function _GetNavHTML: string;
  var
    FirstPage, LastPage: Boolean;
    FirstLnk, PrevLnk, NextLnk, LastLnk: string;
  begin
    FirstLnk := '';
    PrevLnk := '';
    NextLnk := '';
    LastLnk := '';
    Result := '';
    FirstPage := (FPageNo = 0);
    LastPage := (FPageNo = ParentReport.EndPages.Count - 1);
    if not FirstPage then
    begin
      FirstLnk := 'HREF="' + ExtractFileName(FRepFileNames[0]) + '" ';
      PrevLnk := 'HREF="' + ExtractFileName(FRepFileNames[FPageNo - 1]) + '" ';
    end;
    if not LastPage then
    begin
      LastLnk := 'HREF="' + ExtractFileName(FRepFileNames[ParentReport.EndPages.Count - 1]) + '" ';
      NextLnk := 'HREF="' + ExtractFileName(FRepFileNames[FPageNo + 1]) + '" ';
    end;

    if FUseTextLinks then
      Result := Format(ATextFormat,
        [FirstLnk, FLinkTextFirst, FLinkTextFirst]) + '&nbsp;' +
        Format(ATextFormat, [PrevLnk, FLinkTextPrev, FLinkTextPrev]) + '&nbsp;' +
        Format(ATextFormat, [NextLnk, FLinkTextNext, FLinkTextNext]) + '&nbsp;' +
        Format(ATextFormat, [LastLnk, FLinkTextLast, FLinkTextLast])
    else
      Result := Format(AImageFormat, [FirstLnk, FLinkTextFirst, FLinkImgSRCFirst, FLinkTextFirst]) + '&nbsp;' +
        Format(AImageFormat, [PrevLnk, FLinkTextPrev, FLinkImgSRCPrev, FLinkTextPrev]) + '&nbsp;' +
        Format(AImageFormat, [NextLnk, FLinkTextNext, FLinkImgSRCNext, FLinkTextNext]) + '&nbsp;' +
        Format(AImageFormat, [LastLnk, FLinkTextLast, FLinkImgSRCLast, FLinkTextLast]);
  end;

begin
  if SingleFile and (FPageNo < ParentReport.EndPages.Count - 1) then
  begin
    S := '<DIV STYLE="' +
      'position: absolute; ' +
      'top:' + IntToStr(Round((FPageNo + 1) * FPageHeight)) + 'px">' +
      '<HR SIZE= ' + IntToStr(Round(CPageEndLineWidth)) + ' ' +
      'WIDTH= ' + IntToStr(Round(FPageWidth - 10)) + ' ' +
      'NOSHADE></DIV>' + CRLF;
    WriteToStream(ExportStream, S);
  end
  else if not SeparateFilePerPage then
  begin
    S := '<DIV STYLE="' +
      'position: absolute; ' +
      'top: ' + IntToStr(Round((FPageNo + 1) * FPageHeight)) + 'px">' +
      '<HR SIZE= ' + IntToStr(Round(CPageEndLineWidth)) + ' ' +
      'WIDTH= ' + IntToStr(Round(FPageWidth - 10)) + ' ' +
      'NOSHADE></DIV>' + CRLF;
    WriteToStream(ExportStream, S);
  end
  else if (not SingleFile) and SeparateFilePerPage and ShowNavigator and (ParentReport.EndPages.Count > 1) then
  begin
    S := '<DIV STYLE="' +
      'position: absolute; ' +
      'top: ' + IntToStr(Round(FPageHeight)) + 'px; ' +
      'left: ' + IntToStr(Round(ParentReport.EndPages[0].spMarginLeft)) + 'px; ' +
      'font: ' + IntToStr(FLinkFont.Size) + 'pt ' + FLinkFont.Name +
      '; color: ' + RMColorBGRToRGB(FLinkFont.Color) + '; ' +
      'background: ' + RMColorBGRToRGB(FLinkBackColor) + '">' +
      _GetNavHTML + '</DIV>' + CRLF;
    WriteToStream(ExportStream, S);
  end;

  if (not SingleFile) or (FPageNo = ParentReport.EndPages.Count - 1) then
  begin
    S := CRLF + '</BODY>' + CRLF + '</HTML>' + CRLF;
    WriteToStream(ExportStream, S);
  end;
end;

procedure TRMHTMExport.InternalOnePage(aPage: TRMEndPage);
var
  lReuseImageIndex: Integer;
  lFileName: string;

  procedure _SetReuseImageIndex(aViewName: string; aViewIndex: Integer);
  var
    lUniqueImage: Boolean;
  begin
    lUniqueImage := True;
    lReuseImageIndex := -1;
    FAltText := ExtractFileName(lFileName);
    if Assigned(FBeforeSaveGraphic) then
      FBeforeSaveGraphic(Self, aViewName, lUniqueImage, lReuseImageIndex, FAltText);

    if not lUniqueImage then
    begin
      if lReuseImageIndex >= FDataList.Count then
        lReuseImageIndex := -1
      else if lReuseImageIndex = -1 then
        lReuseImageIndex := FImgFileNames.IndexOfObject(TObject(aViewIndex));
    end
    else
      lReuseImageIndex := -1;
  end;

  function _ExportPicture(aDataRec: TRMIEMData): string; // 导出图片
  var
    lImageIndex: Integer;
  begin
    Result := '';
    if (not ExportImages) or (THackRMIEMData(aDataRec).FGraphic = nil) then Exit;

    _SetReuseImageIndex(aDataRec.Obj.Name, aDataRec.ViewIndex);
    if (lReuseImageIndex <> -1) and (lReuseImageIndex < FImgFileNames.Count) then
    begin
      lFileName := FImgFileNames[lReuseImageIndex];
      lImageIndex := lReuseImageIndex;
    end
    else
    begin
      lFileName := FImageCreateDir + RMMakeImgFileName(ExtractFileName(FileName), 'bmp', ImgFileCount + 1);
      lFileName := SaveBitmapAs(TBitmap(aDataRec.Graphic),
        ExportImageFormat{$IFDEF JPEG}, JPEGQuality{$ENDIF}, ChangeFileExt(lFileName, ''));
      lImageIndex := FImgFileNames.AddObject(lFileName, TObject(aDataRec.ViewIndex));
    end;
    FreeAndNil(THackRMIEMData(aDataRec).FGraphic);

    if Assigned(FAfterSaveGraphic) then
      FAfterSaveGraphic(Self, aDataRec.Obj.Name, lImageIndex);

    Result := '<IMG SRC="' + lFileName + '" ALT="' + FAltText + '">';
  end;

  procedure _ExportText(aDataRec: TRMIEMData);
  var
    i, lCount: Integer;
    t: TRMCustomMemoView;
    lOutputStr: string;
    lTextRec: pRMEFTextRec;

    function _TextDecor: string;
    begin
      Result := '';
      if ((t.Font.Style - [fsBold, fsItalic]) <> []) then
      begin
        Result := '; text-decoration:';
        if fsUnderline in t.Font.Style then
          Result := Result + ' underline';
        if fsStrikeOut in t.Font.Style then
          Result := Result + ' line-through';
      end;
    end;

  begin
    lCount := aDataRec.TextListCount;
    t := TRMCustoMMemoView(aDataRec.Obj);
    for i := 0 to lCount - 1 do
    begin
      lTextRec := aDataRec.TextList[i];
      lTextRec.Left := lTextRec.Left + aPage.spMarginLeft;
      lTextRec.Top := lTextRec.Top + aPage.spMarginTop + GetOffsetFromTop;
      lOutputStr := '<DIV STYLE="' +
        'position: absolute; ' +
        'top: ' + IntToStr(lTextRec.Top) + 'px; ' +
        'left: ' + IntToStr(lTextRec.Left) + 'px; ' +
        'width: ' + IntToStr(Round(lTextRec.TextWidth * 2.5)) + 'px; ' +
        'font:' + Italic[fsItalic in (t.Font.Style)] + Bold[fsBold in (t.Font.Style)] + ' ' +
        IntToStr(t.Font.Size) + 'pt ' + t.Font.Name + _TextDecor + '; ' +
        'color: #' + RMColorBGRToRGB(t.Font.Color) + '">';

      lOutputStr := lOutputStr + GetNativeText(lTextRec.Text) + '</DIV>' + CRLF;
      WriteToStream(ExportStream, lOutputStr);
    end;
  end;

  procedure _Encodedata;
  var
    i: Integer;
    lDataRec: TRMIEMData;
    lImageSource, lBackGroundInfo, lBorderInfo, S: string;

    function _GetBorderInfo: string;
    var
      Attrib: string;
    begin
      Result := '';
      if not ExportFrames then Exit;

      Attrib := IntToStr(Round(lDataRec.Obj.TopFrame.spWidth)) + 'px solid ' +
        '#' + RMColorBGRToRGB(lDataRec.Obj.TopFrame.Color);

      if lDataRec.Obj.TopFrame.Visible then
        Result := '; border-top: ' + Attrib;
      if lDataRec.Obj.RightFrame.Visible then
        Result := Result + '; border-right: ' + Attrib;
      if lDataRec.Obj.BottomFrame.Visible then
        Result := Result + '; border-bottom: ' + Attrib;
      if lDataRec.Obj.LeftFrame.Visible then
        Result := Result + '; border-Left: ' + Attrib;
    end;

  begin
    for i := 0 to FDataList.Count - 1 do
    begin
      Application.ProcessMessages;
      lDataRec := FDataList[I];
      lDataRec.Left := lDataRec.Left + aPage.spMarginLeft;
      lDataRec.Top := lDataRec.Top + aPage.spMarginTop + GetOffsetFromTop;
      lImageSource := '';
      lBorderInfo := '';
      lBackGroundInfo := '';
      if lDataRec.ObjType = rmemPicture then
        lImageSource := _ExportPicture(lDataRec);

      S := '';
      if ExportFrames and (lDataRec.Obj.FillColor <> clNone) then
        lBackGroundInfo := '; background-color: #' + RMColorBGRToRGB(lDataRec.Obj.FillColor);

      S := '<DIV STYLE="font: 0pt' + lBackGroundInfo + '; ' +
        'position: absolute; ' +
        'top: ' + IntToStr(lDataRec.Top) + 'px; ' +
        'left: ' + IntToStr(lDataRec.Left) + 'px; ' +
        'width: ' + IntToStr(lDataRec.Width) + 'px; ' +
        'height: ' + IntToStr(lDataRec.Height + 1) + 'px';

      if ExportFrames and ((lDataRec.Obj.ClassName = TRMMemoView.ClassName) or
        (lDataRec.Obj.ClassName = TRMCalcMemoView.ClassName)) then
      begin
        lBorderInfo := _GetBorderInfo;
        S := S + lBorderInfo + ';">';
      end
      else
        S := S + ';">';
      S := S + lImageSource + '</DIV>' + CRLF;

      if (lBackGroundInfo <> '') or (lBorderInfo <> '') or (lImageSource <> '') then
        WriteToStream(ExportStream, S);
    end;
  end;

  procedure _EncodeText;
  var
    i: Integer;
    lDataRec: TRMIEMData;
  begin
    for i := 0 to FDataList.Count - 1 do
    begin
      Application.ProcessMessages;
      lDataRec := FDataList[I];
      if lDataRec.ObjType = rmemText then
        _ExportText(lDataRec);
    end;
  end;

begin
  if (not SingleFile) and (FPageNo <> 0) then
  begin
    ExportStream := TFileStream.Create(FRepFileNames[FPageNo], fmCreate);
    WriteHeader;
  end;
  if FPageNo = 0 then WriteHeader;

  _EncodeData;
  _EncodeText;
  WriteFooter;
  if (not SingleFile) and (FPageNo < ParentReport.EndPages.Count - 1) then
  begin
    FreeAndNil(ExportStream);
  end;
end;

function TRMHTMExport.SaveBitmapAs(aBmp: TBitmap; aImgFormat: TRMEFImageFormat
{$IFDEF JPEG}; aJPEGQuality: TJPEGQualityRange{$ENDIF}; const aBaseName: string): string;
var
  lFileExt: string;
  lStream, lEncodeStream: TMemoryStream;
  lPicture: TPicture;
begin
  Result := aBaseName;
  if FCreateMHTFile then
    Result := ExtractFileName(Result);

  lStream := TMemoryStream.Create;
  lEncodeStream := TMemoryStream.Create;
  lPicture := TPicture.Create;
  try
    SaveBitmapToPicture(aBmp, aImgFormat{$IFDEF JPEG}, aJPEGQuality{$ENDIF}, lPicture);
    lFileExt := '.bmp';
    case aImgFormat of
      ifBMP:
        begin
        end;
      ifGIF:
        begin
{$IFDEF RXGIF}
          lFileExt := '.gif';
{$ELSE}
{$IFDEF JPEG}
          lFileExt := '.jpg';
{$ENDIF}
{$ENDIF}
        end;
      ifJPG:
        begin
{$IFDEF JPEG}
          lFileExt := '.jpg';
{$ENDIF}
        end;
    end;

    Result := Result + lFileExt;
    if FCreateMHTFile then
      lPicture.Graphic.SaveToStream(lStream)
    else
      lPicture.SaveToFile(Result);

    if FCreateMHTFile and (lStream.Size > 0) then
    begin
      WriteToStream(FImagesStream, '--===Test MHT by Town===' + CRLF);
      WriteToStream(FImagesStream, 'Content-Type: image/' + lFileExt + CRLF);
      WriteToStream(FImagesStream, 'Content-Transfer-Encoding: base64' + CRLF);
      WriteToStream(FImagesStream, 'Content-Location:' + Result + CRLF);
      WriteToStream(FImagesStream, '' + CRLF);
      lStream.Position := 0;
      MimeEncodeStream(lStream, lEncodeStream);
      lEncodeStream.Position := 0;
      FImagesStream.CopyFrom(lEncodeStream, lEncodeStream.Size);
      WriteToStream(FImagesStream, '' + CRLF);
    end;
  finally
    lPicture.Free;
    lStream.Free;
    lEncodeStream.Free;
  end;
end;

function TRMHTMExport.GetNativeText(const aText: string): string;
begin
  Result := StringReplace(aText, ' ', '&nbsp;', [rfReplaceAll]);
end;

function TRMHTMExport.GetOffsetFromTop: Integer;
begin
  Result := Round(FPageHeight + cPageEndLineWidth) * (FPageNo) * Ord(SingleFile);
end;

function TRMHTMExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else
  begin
    with TRMHTMLExportForm.Create(nil) do
    try
      Exportfilter := Self;
      Application.ProcessMessages;
      Result := ShowModal;
    finally
      Free;
    end;
  end;

  if FCreateMHTFile then
    FileName := ChangeFileExt(FileName, '.mht')
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMHTMLExportForm}

procedure TRMHTMLExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1830);
  RMSetStrProp(chkExportFrames, 'Caption', rmRes + 1803);
  RMSetStrProp(chkExportImages, 'Caption', rmRes + 1821);
  RMSetStrProp(lblExportImageFormat, 'Caption', rmRes + 1816);
  RMSetStrProp(lblJPEGQuality, 'Caption', rmRes + 1814);

  RMSetStrProp(lblImageFolder, 'Caption', rmRes + 1818);
  RMSetStrProp(chkSepFilePerPage, 'Caption', rmRes + 1819);
  RMSetStrProp(chkShowNavigator, 'Caption', rmRes + 1823);
  RMSetStrProp(lblHoverForeColor, 'Caption', rmRes + 1824);
  RMSetStrProp(lblBackGroundColor, 'Caption', rmRes + 1825);
  RMSetStrProp(lblHoverBackColor, 'Caption', rmRes + 1826);
  RMSetStrProp(lblLinkCaptions, 'Caption', rmRes + 1827);
  RMSetStrProp(btnSetFont, 'Caption', SFont);
  RMSetStrProp(lblFirst, 'Caption', rmRes + 1828);
  RMSetStrProp(lblPrevious, 'Caption', rmRes + 1829);
  RMSetStrProp(lblNext, 'Caption', rmRes + 1799);
  RMSetStrProp(lblLast, 'Caption', rmRes + 1798);
  RMSetStrProp(lblUseGraphicLinksFirst, 'Caption', rmRes + 1828);
  RMSetStrProp(lblUseGraphicLinksPrevious, 'Caption', rmRes + 1829);
  RMSetStrProp(lblUseGraphicLinksNext, 'Caption', rmRes + 1799);
  RMSetStrProp(lblUseGraphicLinksLast, 'Caption', rmRes + 1798);
  RMSetStrProp(lblImageSource, 'Caption', rmRes + 1797);
  RMSetStrProp(rbtnUseTextLinks, 'Caption', rmRes + 1792);
  RMSetStrProp(rbtnUseGraphicLinks, 'Caption', rmRes + 1791);

  RMSetStrProp(TabSheet1, 'Caption', rmRes + 2);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 1787);
  RMSetStrProp(chkSingleFile, 'Caption', rmRes + 1786);
  RMSetStrProp(chkCreateMHTFile, 'Caption', rmRes + 1780);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMHTMLExportForm.btnImagesClick(Sender: TObject);
var
  S: string;
begin
  S := ExtractFilePath(THackFilter(FExportFilter).FileName);
  if RMSelectDirectory('', S, S) then
    edImageDirectory.Text := S;
end;

procedure TRMHTMLExportForm.chkShowNavigatorClick(Sender: TObject);
begin
  RMSetControlsEnable(gbShowNavigator, chkShowNavigator.Checked);
  rbtnUseTextLinks.Enabled := chkShowNavigator.Checked;
  rbtnUseGraphicLinks.Enabled := chkShowNavigator.Checked;
end;

procedure TRMHTMLExportForm.rbtnUseTextLinksClick(Sender: TObject);
begin
  pcShowNavigator.ActivePage := pcShowNavigator.Pages[(Sender as TRadioButton).Tag];
end;

procedure TRMHTMLExportForm.btnSetFontClick(Sender: TObject);
begin
  if FontDialog.Execute then
  begin
    edFirst.Font.Name := FontDialog.Font.Name;
    edFirst.Font.Color := FontDialog.Font.Color;
    edFirst.Font.Style := FontDialog.Font.Style;
    edPrevious.Font.Name := FontDialog.Font.Name;
    edPrevious.Font.Color := FontDialog.Font.Color;
    edPrevious.Font.Style := FontDialog.Font.Style;
    edNext.Font.Name := FontDialog.Font.Name;
    edNext.Font.Color := FontDialog.Font.Color;
    edNext.Font.Style := FontDialog.Font.Style;
    edLast.Font.Name := FontDialog.Font.Name;
    edLast.Font.Color := FontDialog.Font.Color;
    edLast.Font.Style := FontDialog.Font.Style;
  end;
end;

procedure TRMHTMLExportForm.btnOKClick(Sender: TObject);
begin
  with TRMHTMExport(ExportFilter) do
  begin
    ExportFrames := chkExportFrames.Checked;
    ExportImages := chkExportImages.Checked;
    ExportImageFormat := TRMEFImageFormat
      (cmbImageFormat.Items.Objects[cmbImageFormat.ItemIndex]);
{$IFDEF JPEG}
    JPEGQuality := StrToInt(edJPEGQuality.Text);
{$ENDIF}
    PixelFormat := TPixelFormat(cmbPixelFormat.ItemIndex);

    SingleFile := chkSingleFile.Checked;
    SeparateFilePerPage := chkSepFilePerPage.Checked;
    ShowNavigator := chkShowNavigator.Checked;

    LinkHoverForeColor := shpHoverForeColor.Brush.Color;
    LinkHoverBackColor := shpHoverBackColor.Brush.Color;
    LinkBackColor := shpBackGroundColor.Brush.Color;

    UseTextLinks := rbtnUseTextLinks.Checked;
    LinkTextFirst := edFirst.Text;
    LinkTextPrev := edPrevious.Text;
    LinkTextNext := edNext.Text;
    LinkTextLast := edLast.Text;
    LinkImgSRCFirst := edUseGraphicLinksFirst.Text;
    LinkImgSRCPrev := edUseGraphicLinksPrevious.Text;
    LinkImgSRCNext := edUseGraphicLinksNext.Text;
    LinkImgSRCLast := edUseGraphicLinksLast.Text;
    LinkFont := FontDialog.Font;

    ImageDir := edImageDirectory.Text;
    CreateMHTFile := chkCreateMHTFile.Checked;
  end;
end;

procedure TRMHTMLExportForm.shpHoverForeColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MousePoint.x := X;
  MousePoint.y := Y;
end;

procedure TRMHTMLExportForm.shpHoverForeColorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := shpHoverBackColor.Brush.Color;
  if (((X = MousePoint.x) and (Y = MousePoint.y))
    and (Button = mbleft)) then
    if ColorDialog.Execute then
      (Sender as TShape).Brush.Color := ColorDialog.Color;
end;

procedure TRMHTMLExportForm.rbtnUseGraphicLinksClick(Sender: TObject);
begin
  pcShowNavigator.ActivePage := pcShowNavigator.Pages[(Sender as TRadioButton).Tag];
end;

procedure TRMHTMLExportForm.chkExportImagesClick(Sender: TObject);
begin
  RMSetControlsEnable(gbExportImages, chkExportImages.Checked);
  cmbImageFormatChange(Sender);
end;

procedure TRMHTMLExportForm.cmbImageFormatChange(Sender: TObject);
begin
  if chkExportImages.Checked and (cmbImageFormat.Text = ImageFormats[ifJPG]) then
  begin
    lblJPEGQuality.Enabled := True;
    edJPEGQuality.Enabled := True;
    edJPEGQuality.Color := clWindow;
  end
  else
  begin
    lblJPEGQuality.Enabled := False;
    edJPEGQuality.Enabled := False;
    edJPEGQuality.Color := clInactiveBorder;
  end;
end;

procedure TRMHTMLExportForm.edJPEGQualityKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TRMHTMLExportForm.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  Localize;
  cmbImageFormat.Items.Clear;
{$IFDEF RXGIF}
  cmbImageFormat.Items.AddObject(ImageFormats[ifGIF], TObject(ifGIF));
{$ENDIF}
{$IFDEF JPEG}
  cmbImageFormat.Items.AddObject(ImageFormats[ifJPG], TObject(ifJPG));
{$ENDIF}
  cmbImageFormat.Items.AddObject(ImageFormats[ifBMP], TObject(ifBMP));
  cmbImageFormat.ItemIndex := 0;
  pcShowNavigator.ActivePage := tsUseTextLinks;
end;

procedure TRMHTMLExportForm.FormShow(Sender: TObject);
begin
  with TRMHTMExport(ExportFilter) do
  begin
    chkExportFrames.Checked := ExportFrames;
    chkExportImages.Checked := ExportImages;
    cmbImageFormat.ItemIndex := cmbImageFormat.Items.IndexOfObject(TObject(Ord(ExportImageFormat)));
    if cmbImageFormat.ItemIndex < 0 then
      cmbImageFormat.ItemIndex := 0;
{$IFDEF JPEG}
    UpDown1.Position := JPEGQuality;
{$ENDIF}
    cmbPixelFormat.ItemIndex := Integer(PixelFormat);
    chkSepFilePerPage.Checked := SeparateFilePerPage;
    chkShowNavigator.Checked := ShowNavigator;
    chkSingleFile.Checked := SingleFile;

    shpHoverForeColor.Brush.Color := LinkHoverForeColor;
    shpHoverBackColor.Brush.Color := LinkHoverBackColor;
    shpBackGroundColor.Brush.Color := LinkBackColor;

    rbtnUseTextLinks.Checked := UseTextLinks;
    rbtnUseGraphicLinks.Checked := not UseTextLinks;

    edFirst.Text := LinkTextFirst;
    edPrevious.Text := LinkTextPrev;
    edNext.Text := LinkTextNext;
    edLast.Text := LinkTextLast;

    edUseGraphicLinksFirst.Text := LinkImgSRCFirst;
    edUseGraphicLinksPrevious.Text := LinkImgSRCPrev;
    edUseGraphicLinksNext.Text := LinkImgSRCNext;
    edUseGraphicLinksLast.Text := LinkImgSRCLast;

    FontDialog.Font := LinkFont;

    edFirst.Font.Name := FontDialog.Font.Name;
    edFirst.Font.Color := FontDialog.Font.Color;
    edPrevious.Font.Name := FontDialog.Font.Name;
    edPrevious.Font.Color := FontDialog.Font.Color;
    edNext.Font.Name := FontDialog.Font.Name;
    edNext.Font.Color := FontDialog.Font.Color;
    edLast.Font.Name := FontDialog.Font.Name;
    edLast.Font.Color := FontDialog.Font.Color;

    edImageDirectory.Text := ImageDir;
    chkCreateMHTFile.Checked := CreateMHTFile;
  end;
  chkExportImagesClick(Sender);
  chkSingleFileClick(Sender);
end;

procedure TRMHTMLExportForm.chkSingleFileClick(Sender: TObject);
begin
  RMSetControlsEnable(gbShowNavigator, (not chkSingleFile.Checked and chkShowNavigator.Checked));
  chkShowNavigator.Enabled := not chkSingleFile.Checked;
end;

procedure TRMHTMLExportForm.chkCreateMHTFileClick(Sender: TObject);
begin
  edImageDirectory.Enabled := not chkCreateMHTFile.Checked;
  btnImages.Enabled := not chkCreateMHTFile.Checked;
end;

end.

