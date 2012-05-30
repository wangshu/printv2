unit RM_Printer;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, WinSpool, SyncObjs, RM_Common, RM_Const, RM_Const1;

const
  rmpgLetter = 1;
  rmpgLetterSmall = 2;
  rmpgTabloid = 3;
  rmpgLedger = 4;
  Legal = 5;
  rmpgStatement = 6;
  rmpgExecutive = 7;
  rmpgA3 = 8;
  rmpgA4 = 9;
  rmpgA4Small = 10;
  rmpgA5 = 11;
  rmpgB4 = 12;
  rmpgB5 = 13;
  rmpgFolio = 14;
  rmpgQuarto = 15;
  qr10X14 = 16;
  rmpgqr11X17 = 17;
  rmpgNote = 18;
  rmpgEnv9 = 19;
  rmpgEnv10 = 20;
  rmpgEnv11 = 21;
  rmpgEnv12 = 22;
  rmpgEnv14 = 23;
  rmpgCSheet = 24;
  rmpgDSheet = 25;
  rmpgESheet = 26;
  rmpg16K = 800;
  rmpg32K = 801;
  rmpg32KBIG = 802;
  rmpgKh = 803;
  rmpgZh = 804;
  rmpgCustom = 256;

type
  TRMDuplex = (rmdpNone, rmdpHorizontal, rmdpVertical);
  TRMPrinterCapType = (pcPaperNames, pcPapers, pcPaperWidths, pcPaperHeights,
    pcBinNames, pcBins);

 { TRMPrinterInfo }
  TRMPrinterInfo = class(TObject)
  private
    FDriver: PChar;
    FDevice: PChar;
    FPort: PChar;
    FIsValid: Boolean;
    FAlreadlyGetInfo: Boolean;
    FDeviceHandle: THandle;
    FAddinPaperSizeIndex: Integer;
    FLock: TCriticalSection;

    FPaperNames: TStringList;
    FBinNames: TStringList;
    FBins: TStringList;
    FPaperWidths: TStringList;
    FPaperHeights: TStringList;
    FPaperSizes: TStringList;
    function GetPaperWidth(index: Integer): Integer;
    function GetPaperHeight(index: Integer): Integer;
    procedure SetPaperWidth(index: Integer; Value: Integer);
    procedure SetPaperHeight(index: Integer; Value: Integer);
    function GetPaperSize(index: Integer): Integer;
    function GetBin(index: Integer): Integer;
    procedure GetDeviceCapability(aPrinterCap: TRMPrinterCapType; sl: TStrings);
    procedure ValidatePaperSizes;
    procedure ValidatePaperBins;
    procedure GetPrinterCaps(aVirtualPrinter: Boolean);
//    function GetCustomPaperSize: Integer;
  protected
  public
    constructor Create(aDriver, aDevice, aPort: PChar);
    destructor Destroy; override;

    function PaperSizesCount: Integer;
    function GetPaperSizeIndex(pgSize: Integer): Integer;
    function GetBinIndex(pgBin: Integer): Integer;

    property Device: PChar read FDevice;
    property Driver: PChar read FDriver;
    property Port: PChar read FPort;
    property IsValid: Boolean read FIsValid write FIsValid;
    property AddinPaperSizeIndex: Integer read FAddinPaperSizeIndex;
    property PaperNames: TStringList read FPaperNames;
    property BinNames: TStringList read FBinNames;
    property PaperWidths[index: Integer]: Integer read GetPaperWidth write SetPaperWidth;
    property PaperHeights[index: Integer]: Integer read GetPaperHeight write SetPaperHeight;
    property PaperSizes[index: Integer]: Integer read GetPaperSize;
    property Bins[index: Integer]: Integer read GetBin;
//    property CustomPaperSize: Integer read GetCustomPaperSize;
  end;

  { TRMPrinterList }
  TRMPrinterList = class(TObject)
  private
    FDefaultPrinterIndex: Integer;
    FPrinters: TStrings;
    FLock: TCriticalSection;

    procedure BuildPrinterList;
    procedure FreePrinterList;
    function GetCount: Integer;
    function GetPrinterInfo(Index: Integer): TRMPrinterInfo;
    procedure GetDefaultPrinter;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Refresh;

    property Count: Integer read GetCount;
    property Printers: TStrings read FPrinters;
    property PrinterInfo[index: Integer]: TRMPrinterInfo read GetPrinterInfo;
  end;

 { TRMCustomPrinter }
  TRMCustomPrinter = class(TObject)
  private
    FAborted: Boolean;
    FCanGrayScale: Boolean;
    FCanvas: TCanvas;
    FDC: HDC;
    FCurrentInfo: TRMPrinterInfo;
    FDefaultBin: Integer;
    FDocumentName: string;
    FFileName: string;
    FPageNumber: Longint;
    FPrinting: Boolean;
    FPrinterHandle: THandle;
    FPrinterIndex: Integer;
    FResetDC: Boolean;
    FStartPage: Boolean;
    FDevMode: THandle;
    FOnSetupChange: TNotifyEvent;
    FPDevMode: PDeviceMode;
    FPageGutters: TRect;
    FPixelsPerInch: TPoint;
    FPaperWidth, FPaperHeight: Longint;
    FPrintableHeight: Longint;
    FPrintableWidth: Longint;
    FDefaultPaperWidth, FDefaultPaperHeight: Integer;
    FDefaultPaperOr: TRMPrinterOrientation;
    FFactorX, FFactorY: Double;
    FTruePaperWidth, FTruePaperHeight: Longint;
    FColorPrint: Boolean;
    FDuplex: TRMDuplex;
    FLock: TCriticalSection;

    function GetPrinterName: string;
    procedure FreeDC;
    procedure FreeDevMode;
    procedure FreePrinterHandle;
    procedure FreePrinterResources;
    function GetCanGrayScale: Boolean;
    function GetCanvas: TCanvas;
    function GetDC: HDC;
    function GetDocumentProperties: THandle;
    function GetPrinterHandle: THandle;
    function GetPrinterInfo: TRMPrinterInfo;
    function GetPDevMode: PDevMode;
    function GetPageGutters: TRect;
    function GetPaperWidth: Longint;
    function GetPaperHeight: Longint;
    function GetPixelsPerInch: TPoint;
    function GetPrintableHeight: LongInt;
    function GetPrintableWidth: LongInt;
    procedure ResetDC;
    procedure SetPrinterIndex(Value: Integer);
  protected
    procedure DeviceContextChanged;
    property PDevMode: PDevMode read GetPDevMode;
    property CurrentInfo: TRMPrinterInfo read FCurrentInfo;
    property DefaultBin: Integer read FDefaultBin;
  public
    PaperSize: Integer;
    Orientation: TRMPrinterOrientation;
    Bin: Integer;
    DefaultPaper: Integer;

    constructor Create; virtual;
    destructor Destroy; override;

    procedure BeginDoc;
    procedure Abort;
    procedure EndDoc;
    procedure EndPage;
    procedure NewPage;
    procedure GetDevMode(var aDevMode: THandle);
    procedure SetDevMode(aDevMode: THandle);
    function HasColor: Boolean;
    procedure UpdateForm(const aFormName: string; aDimensions: TPoint; aPrintArea: TRect);

    property PrinterHandle: THandle read GetPrinterHandle;
    property Aborted: Boolean read FAborted;
    property Canvas: TCanvas read GetCanvas;
    property DC: HDC read GetDC;
    property Title: string read FDocumentName write FDocumentName;
    property FileName: string read FFileName write FFileName;
    property PageNumber: Longint read FPageNumber;
    property Printing: Boolean read FPrinting;
    property PrinterIndex: Integer read FPrinterIndex write SetPrinterIndex;
    property PrinterName: string read GetPrinterName;
    property PrinterInfo: TRMPrinterInfo read GetPrinterInfo;

    property FactorX: Double read FFactorX;
    property FactorY: Double read FFactorY;
    property CanGrayScale: Boolean read GetCanGrayScale;
    property PageGutters: TRect read GetPageGutters;
    property PixelsPerInch: TPoint read GetPixelsPerInch;
    property PrintableHeight: Longint read GetPrintableHeight;
    property PrintableWidth: Longint read GetPrintableWidth;
    property PaperWidth: Longint read GetPaperWidth;
    property PaperHeight: Longint read GetPaperHeight;
    property DefaultPaperWidth: Longint read FDefaultPaperWidth;
    property DefaultPaperHeight: Longint read FDefaultPaperHeight;
    property DefaultPaperOr: TRMPrinterOrientation read FDefaultPaperOr;
    property ColorPrint: Boolean read FColorPrint write FColorPrint;
    property Duplex: TRMDuplex read FDuplex write FDuplex;
    property OnChange: TNotifyEvent read FOnSetupChange write FOnSetupChange;
  end;

  { TRMPrinter }
  TRMPrinter = class(TRMCustomPrinter)
  private
    FCopies: Integer;

    procedure SetSettings(aPgWidth, aPgHeight: Integer);
  protected
    procedure GetSettings;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure FillPrinterInfo(var p: TRMPageInfo);
    procedure SetPrinterInfo(aPageSize, aPageWidth, aPageHeight, aPageBin: Integer;
      aPageOrientation: TRMPrinterOrientation; aSetImmediately: Boolean);
    function IsEqual(apgSize, apgWidth, apgHeight, apgBin: Integer; apgOr: TRMPrinterOrientation;
      aDuplex: TRMDuplex): Boolean;
    function PropertiesDlg: Boolean;
    procedure Update;
    property Copies: Integer read FCopies write FCopies default 1;
  end;

 { TRMPageSetting }
  TRMPageSetting = class(TPersistent)
  private
    FTitle: string;
    FPageName: string;
    FPageSize: Word;
    FPageWidth, FPageHeight: Integer;
    FPageOr: TRMPrinterOrientation;
    FPageBin: Integer;
    FPrintBackGroundPicture: Boolean;
    FMarginLeft, FMarginTop, FMarginRight, FMarginBottom: Double;
    FPrintToPrevPage: Boolean;
    FScaleFrameWidth: Boolean;
    FUnlimitedHeight: Boolean;
    FDoublePass: Boolean;
    FColCount: Integer;
    FColGap: Double;
    FPrinterName: string;
    FColorPrint: Boolean;
    FNewPageAfterPrint: Boolean;
    FConvertNulls: Boolean;

    procedure SetColCount(Value: Integer);
    procedure SetValue(Index: integer; Value: Double);
    procedure SetPageOr(Value: TRMPrinterOrientation);
  protected
  public
    property PageName: string read FPageName write FPageName;
    property PageSize: Word read FPageSize write FPageSize;
    property PageWidth: Integer read FPageWidth write FPageWidth;
    property PageHeight: Integer read FPageHeight write FPageHeight;
    property PageOr: TRMPrinterOrientation read FPageOr write SetPageOr;
    property PageBin: Integer read FPageBin write FPageBin;
    property PrintToPrevPage: Boolean read FPrintToPrevPage write FPrintToPrevPage;
    property DoublePass: Boolean read FDoublePass write FDoublePass;
    property PrintBackGroundPicture: Boolean read FPrintBackGroundPicture write FPrintBackGroundPicture;
    property ScaleFrameWidth: Boolean read FScaleFrameWidth write FScaleFrameWidth;
    property UnlimitedHeight: Boolean read FUnlimitedHeight write FUnlimitedHeight;
    property ColCount: Integer read FColCount write SetColCount;
    property ColGap: Double index 4 read FColGap write SetValue;
    property MarginLeft: Double index 0 read FMarginLeft write SetValue;
    property MarginTop: Double index 1 read FMarginTop write SetValue;
    property MarginRight: Double index 2 read FMarginRight write SetValue;
    property MarginBottom: Double index 3 read FMarginBottom write SetValue;
    property PrinterName: string read FPrinterName write FPrinterName;
    property ColorPrint: Boolean read FColorPrint write FColorPrint;
    property NewPageAfterPrint: Boolean read FNewPageAfterPrint write FNewPageAfterPrint;
    property Title: string read FTitle write FTitle;
    property ConvertNulls: Boolean read FConvertNulls write FConvertNulls;
  published
  end;

function RMPrinters: TRMPrinterList;
function RMPrinter: TRMPrinter;

{$EXTERNALSYM DeviceCapabilities}
function DeviceCapabilities(pDevice, pPort: PChar; fwCapability: Word;
  pOutput: PChar; DevMode: PDeviceMode): Integer; stdcall;
{$EXTERNALSYM DeviceCapabilitiesA}
function DeviceCapabilitiesA(pDevice, pPort: PAnsiChar; fwCapability: Word;
  pOutput: PAnsiChar; DevMode: PDeviceModeA): Integer; stdcall;
{$EXTERNALSYM DeviceCapabilitiesW}
function DeviceCapabilitiesW(pDevice, pPort: PWideChar; fwCapability: Word;
  pOutput: PWideChar; DevMode: PDeviceModeW): Integer; stdcall;
procedure RMAddPaperInfo_1(aPaperName: string; aPaperWidth, aPaperHeight: Integer);

implementation

uses Consts, RM_Utils, RM_Class;

const
  cUnknown = 'Unknown';
  RMAddInPaperPos = 800;

type
  TPaperInfo = record
    Typ: Integer;
    Name: string;
    X, Y: Integer;
  end;

const
  PAPERCOUNT = 67;
  RMAddInPaperInfo: array[0..10] of TPaperInfo = (
    (Typ: 800; Name: ''; X: 1840; Y: 2600), //16开(18.4 x 26 厘米)
    (Typ: 801; Name: ''; X: 1300; Y: 1840), //32开(13 x 18.4 厘米)
    (Typ: 802; Name: ''; X: 1400; Y: 2030), //大32开(14 x 20.3 厘米)
    (Typ: 803; Name: ''; X: 3778; Y: 2794), //宽行连续纸
    (Typ: 804; Name: ''; X: 2159; Y: 2794), //窄行连续纸
    (Typ: 805; Name: ''; X: 0;    Y: 0),
    (Typ: 806; Name: ''; X: 0;    Y: 0),
    (Typ: 807; Name: ''; X: 0;    Y: 0),
    (Typ: 808; Name: ''; X: 0;    Y: 0),
    (Typ: 809; Name: ''; X: 0;    Y: 0),
    (Typ: 810; Name: ''; X: 0;    Y: 0)
    );

  RMDefaultPaperInfo: array[0..PAPERCOUNT - 1] of TPaperInfo = (
    (Typ: 1; Name: ''; X: 2159; Y: 2794),
    (Typ: 2; Name: ''; X: 2159; Y: 2794),
    (Typ: 3; Name: ''; X: 2794; Y: 4318),
    (Typ: 4; Name: ''; X: 4318; Y: 2794),
    (Typ: 5; Name: ''; X: 2159; Y: 3556),
    (Typ: 6; Name: ''; X: 1397; Y: 2159),
    (Typ: 7; Name: ''; X: 1842; Y: 2667),
    (Typ: 8; Name: ''; X: 2970; Y: 4200),
    (Typ: 9; Name: ''; X: 2100; Y: 2970),
    (Typ: 10; Name: ''; X: 2100; Y: 2970),
    (Typ: 11; Name: ''; X: 1480; Y: 2100),
    (Typ: 12; Name: ''; X: 2500; Y: 3540),
    (Typ: 13; Name: ''; X: 1820; Y: 2570),
    (Typ: 14; Name: ''; X: 2159; Y: 3302),
    (Typ: 15; Name: ''; X: 2150; Y: 2750),
    (Typ: 16; Name: ''; X: 2540; Y: 3556),
    (Typ: 17; Name: ''; X: 2794; Y: 4318),
    (Typ: 18; Name: ''; X: 2159; Y: 2794),
    (Typ: 19; Name: ''; X: 984; Y: 2254),
    (Typ: 20; Name: ''; X: 1048; Y: 2413),
    (Typ: 21; Name: ''; X: 1143; Y: 2635),
    (Typ: 22; Name: ''; X: 1207; Y: 2794),
    (Typ: 23; Name: ''; X: 1270; Y: 2921),
    (Typ: 24; Name: ''; X: 4318; Y: 5588),
    (Typ: 25; Name: ''; X: 5588; Y: 8636),
    (Typ: 26; Name: ''; X: 8636; Y: 11176),
    (Typ: 27; Name: ''; X: 1100; Y: 2200),
    (Typ: 28; Name: ''; X: 1620; Y: 2290),
    (Typ: 29; Name: ''; X: 3240; Y: 4580),
    (Typ: 30; Name: ''; X: 2290; Y: 3240),
    (Typ: 31; Name: ''; X: 1140; Y: 1620),
    (Typ: 32; Name: ''; X: 1140; Y: 2290),
    (Typ: 33; Name: ''; X: 2500; Y: 3530),
    (Typ: 34; Name: ''; X: 1760; Y: 2500),
    (Typ: 35; Name: ''; X: 1760; Y: 1250),
    (Typ: 36; Name: ''; X: 1100; Y: 2300),
    (Typ: 37; Name: ''; X: 984; Y: 1905),
    (Typ: 38; Name: ''; X: 920; Y: 1651),
    (Typ: 39; Name: ''; X: 3778; Y: 2794),
    (Typ: 40; Name: ''; X: 2159; Y: 3048),
    (Typ: 41; Name: ''; X: 2159; Y: 3302),
    (Typ: 42; Name: ''; X: 2500; Y: 3530),
    (Typ: 43; Name: ''; X: 1000; Y: 1480),
    (Typ: 44; Name: ''; X: 2286; Y: 2794),
    (Typ: 45; Name: ''; X: 2540; Y: 2794),
    (Typ: 46; Name: ''; X: 3810; Y: 2794),
    (Typ: 47; Name: ''; X: 2200; Y: 2200),
    (Typ: 50; Name: ''; X: 2355; Y: 3048),
    (Typ: 51; Name: ''; X: 2355; Y: 3810),
    (Typ: 52; Name: ''; X: 2969; Y: 4572),
    (Typ: 53; Name: ''; X: 2354; Y: 3223),
    (Typ: 54; Name: ''; X: 2101; Y: 2794),
    (Typ: 55; Name: ''; X: 2100; Y: 2970),
    (Typ: 56; Name: ''; X: 2355; Y: 3048),
    (Typ: 57; Name: ''; X: 2270; Y: 3560),
    (Typ: 58; Name: ''; X: 3050; Y: 4870),
    (Typ: 59; Name: ''; X: 2159; Y: 3223),
    (Typ: 60; Name: ''; X: 2100; Y: 3300),
    (Typ: 61; Name: ''; X: 1480; Y: 2100),
    (Typ: 62; Name: ''; X: 1820; Y: 2570),
    (Typ: 63; Name: ''; X: 3220; Y: 4450),
    (Typ: 64; Name: ''; X: 1740; Y: 2350),
    (Typ: 65; Name: ''; X: 2010; Y: 2760),
    (Typ: 66; Name: ''; X: 4200; Y: 5940),
    (Typ: 67; Name: ''; X: 2970; Y: 4200),
    (Typ: 68; Name: ''; X: 3220; Y: 4450),
    (Typ: DMPAPER_USER; Name: ''; X: 0; Y: 0));

var
  FRMPrinters: TRMPrinterList = nil;
  FRMPrinter: TRMPrinter;
  FAddInPaperCount: Integer = 5;

procedure RMAddPaperInfo_1(aPaperName: string; aPaperWidth, aPaperHeight: Integer);
begin
  if FAddInPaperCount > High(RMAddInPaperInfo) then Exit;

  Inc(FAddInPaperCount);
  RMAddInPaperInfo[FAddInPaperCount - 1].Name := aPaperName;
  RMAddInPaperInfo[FAddInPaperCount - 1].X := aPaperWidth;
  RMAddInPaperInfo[FAddInPaperCount - 1].Y := aPaperHeight;
end;

function RMPrinters: TRMPrinterList;
begin
  if FRMPrinters = nil then
  begin
    FRMPrinters := TRMPrinterList.Create;
  end;
  Result := FRMPrinters;
end;

function RMPrinter: TRMPrinter;
begin
  if FRMPrinter = nil then
  begin
    FRMPrinter := TRMPrinter.Create;
    FRMPrinter.PrinterIndex := 0;
    FRMPrinter.GetSettings;
  end;
  Result := FRMPrinter;
end;

function FetchStr(var Str: PChar): PChar;
var
  P: PChar;
begin
  Result := Str;
  if Str = nil then
    Exit;
  P := Str;
  while P^ = ' ' do
    Inc(P);
  Result := P;
  while (P^ <> #0) and (P^ <> ',') do
    Inc(P);
  if P^ = ',' then
  begin
    P^ := #0;
    Inc(P);
  end;
  Str := P;
end;

function RMCopyHandle(aHandle: THandle): THandle;
var
  lpSource, lpDest: PChar;
  llSize: LongInt;
  lHandle: THandle;
begin
  Result := 0;
  if aHandle = 0 then Exit;

  llSize := GlobalSize(aHandle);
  lHandle := GlobalAlloc(GHND, llSize);
  if lHandle <> 0 then
  begin
    try
      lpSource := GlobalLock(aHandle);
      lpDest := GlobalLock(lHandle);
      if (lpSource <> nil) and (lpDest <> nil) then
        Move(lpSource^, lpDest^, llSize);
    finally
      GlobalUnlock(aHandle);
      GlobalUnlock(lHandle);
    end;
  end;
  Result := lHandle;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrinterInfo}

constructor TRMPrinterInfo.Create(aDriver, aDevice, aPort: PChar);
begin
  inherited Create;

  FLock := TCriticalSection.Create;
  FIsValid := True;
  FAlreadlyGetInfo := FALSE;

  FPaperNames := TStringList.Create;
  FBinNames := TStringList.Create;
  FBins := TStringList.Create;
  FPaperWidths := TStringList.Create;
  FPaperHeights := TStringList.Create;
  FPaperSizes := TStringList.Create;

  FDriver := StrNew(ADriver);
  FDevice := StrNew(ADevice);
  FPort := StrNew(APort);
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion < 4) then
  begin
    if FDriver = nil then
      FDriver := StrAlloc(1);
    if FDevice = nil then
      FDevice := StrAlloc(1);
    if FPort = nil then
      FPort := StrAlloc(1);
  end;
end;

destructor TRMPrinterInfo.Destroy;
begin
  FLock.Acquire;
  try
    FPaperNames.Free;
    FBinNames.Free;
    FBins.Free;
    FPaperWidths.Free;
    FPaperHeights.Free;
    FPaperSizes.Free;

    StrDispose(FDriver);
    StrDispose(FDevice);
    StrDispose(FPort);
  finally
    FLock.Release;
    FLock.Free;
  end;

  inherited Destroy;
end;

{function TRMPrinterInfo.GetCustomPaperSize: Integer;
begin
  FLock.Acquire;
  try
    Result := 256;
    if FPaperSizes.Count > 0 then
      Result := StrToInt(FPaperSizes[FPaperSizes.Count - 1]);
  finally
    FLock.Release;
  end;
end;}

function TRMPrinterInfo.PaperSizesCount: Integer;
begin
  FLock.Acquire;
  try
    Result := FPaperSizes.Count;
  finally
    FLock.Release;
  end;
end;

function DeviceCapabilities; external winspl name 'DeviceCapabilitiesA';
function DeviceCapabilitiesA; external winspl name 'DeviceCapabilitiesA';
function DeviceCapabilitiesW; external winspl name 'DeviceCapabilitiesW';

type
  TCapStructure = (csString, csWord, csPoint, csInteger);

procedure TRMPrinterInfo.GetDeviceCapability(aPrinterCap: TRMPrinterCapType; sl: TStrings);
var
  lResultBuf: PChar;
  lpCurrentItem: Pointer;
  i: Integer;
  lCount: LongInt;
  lItemSize: Word;
  lItem: PChar;
  lpPoint: ^TPoint;
  lpWord: ^Word;
  lCapability: Word;
  lCapStructure: TCapStructure;

  function _GetCapabWinAPI: Boolean;
  begin
    Result := False;
    lResultBuf := nil;
    try
      lCount := DeviceCapabilities(FDevice, FPort, lCapability, nil, nil);
    except
    end;

    if lCount > 0 then
    begin
      GetMem(lResultBuf, (lCount * lItemSize) + 1);
      try
        DeviceCapabilities(FDevice, FPort, lCapability, lResultBuf, nil);
      except
        FreeMem(lResultBuf, (lCount * lItemSize) + 1);
        raise;
      end;
      Result := True;
    end;
  end;

begin
  FLock.Acquire;
  try
    FDeviceHandle := 0;
    sl.Clear;
    case aPrinterCap of
      pcPaperNames:
        begin
          lItemSize := 64;
          lCapability := DC_PAPERNAMES;
          lCapStructure := csString;
        end;
      pcPapers:
        begin
          lItemSize := SizeOf(Word);
          lCapability := dc_Papers;
          lCapStructure := csWord;
        end;
      pcPaperWidths, pcPaperHeights:
        begin
          lItemSize := SizeOf(TPoint);
          lCapability := dc_PaperSize;
          lCapStructure := csPoint;
        end;
      pcBinNames:
        begin
          lItemSize := 24;
          lCapability := DC_BINNAMES;
          lCapStructure := csString;
        end;
      pcBins:
        begin
          lItemSize := SizeOf(Word);
          lCapability := dc_Bins;
          lCapStructure := csWord;
        end;
    else
      Exit;
    end;

    if _GetCapabWinAPI then
    begin
      GetMem(lItem, lItemSize + 1);
      lpCurrentItem := lResultBuf;
      for i := 0 to lCount - 1 do
      begin
        case lCapStructure of
          csString: // papaer names
            begin
              StrLCopy(lItem, lpCurrentItem, lItemSize);
              sl.Add(StrPas(lItem));
            end;
          csWord:
            begin
              lpWord := lpCurrentItem;
              sl.Add(IntToStr(lpWord^));
            end;
          csPoint:
            begin
              lpPoint := lpCurrentItem;
              if aPrinterCap = pcPaperWidths then
                sl.Add(IntToStr(lpPoint^.X))
              else
                sl.Add(IntToStr(lpPoint^.Y));
            end;
        end;

        if i < lCount - 1 then
          lpCurrentItem := PChar(lpCurrentItem) + lItemSize;
      end;
      FreeMem(lItem, lItemSize + 1);
      FreeMem(lResultBuf, (lCount * lItemSize) + 1);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterInfo.ValidatePaperSizes;
var
  i: integer;
  lstr: string;
  lCustomPos: Integer;
  lPointPaperSize: TPoint;

  function PaperSizeToName(aIndex: Word): string;
  begin
    Result := cUnknown;
    if aIndex < PAPERCOUNT then
      Result := RMLoadStr(SPaper1 + aIndex)
    else if aIndex = DMPAPER_USER then
      Result := RMLoadStr(SRMCustomPaperSize);
  end;

  function PaperDimensionsToName(aWidth, aHeight: Integer): string;
  begin
    Result := IntToStr(aWidth div 10) + ' x ' + IntToStr(aHeight div 10) + ' mm';
  end;

  function PaperSizeToDimensions(aPaperSize: Word): TPoint;
  begin
    if aPaperSize < PAPERCOUNT then
    begin
      Result.X := RMDefaultPaperInfo[aPaperSize].X;
      Result.Y := RMDefaultPaperInfo[aPaperSize].Y;
    end
    else
    begin
      Result.X := 0; Result.Y := 0;
    end;
  end;

begin
  if FPaperNames.Count > FPaperSizes.Count then
  begin
    for i := FPaperNames.Count - 1 downto FPaperSizes.Count do
      FPaperNames.Delete(i);
  end
  else if FPaperNames.Count < FPaperSizes.Count then
  begin
    FPaperNames.Clear;
    for i := 0 to FPaperSizes.Count - 1 do
    begin
      lstr := PaperSizeToName(StrToInt(FPaperSizes[i]));
      if lstr = cUnknown then
      begin
        if (i < FPaperHeights.Count) and (i < FPaperWidths.Count) then
          lstr := PaperDimensionsToName(StrToInt(FPaperWidths[i]), StrToInt(FPaperHeights[i]))
        else
          lstr := cUnknown + ': ' + FPaperSizes[i];
      end;
      FPaperNames.Add(lstr);
    end;
  end;

  lCustomPos := FPaperSizes.IndexOf('256');
  if lCustomPos < 0 then
  begin
    for i := 0 to FPaperNames.Count - 1 do
    begin
      lstr := UpperCase(FPaperNames[i]);
      if (Pos('CUSTOM',lstr) > 0) or (Pos('USER', lstr) > 0) then
      begin
        lCustomPos := i;
        Break;
      end;
    end;
  end;

  if (lCustomPos >= 0) and (lCustomPos < FPaperNames.Count) then
  begin
    FPaperNames[lCustomPos] := RMLoadStr(SRMCustomPaperSize);
    if lCustomPos = FPaperSizes.Count then
    begin
      FPaperSizes.Add('256');
      FPaperWidths.Add('0'); FPaperHeights.Add('0');
    end;
  end
  else if lCustomPos < 0 then //add custom option
  begin
    lCustomPos := FPaperNames.Add(RMLoadStr(SRMCustomPaperSize));
    FPaperSizes.Add('256');
    FPaperWidths.Add('0'); FPaperHeights.Add('0');
  end;

  //note: some print drivers do not return Width & Height of PaperSizes (just the "PaperSize: Word" value
 //check the paper widths & heights
  for i := 0 to FPaperSizes.Count - 1 do
  begin
    if (i > FPaperWidths.Count - 1) or (i > FPaperHeights.Count - 1) then
    begin
      lPointPaperSize := PaperSizeToDimensions(StrToInt(FPaperSizes[i]));
      if i > FPaperWidths.Count - 1 then
        FPaperWidths.Add(IntToStr(lPointPaperSize.X))
      else
        FPaperWidths[i] := IntToStr(lPointPaperSize.X);
      if i > FPaperHeights.Count - 1 then
        FPaperHeights.Add(IntToStr(lPointPaperSize.Y))
      else
        FPaperHeights[i] := IntToStr(lPointPaperSize.Y);
    end;
  end;

  for i := FPaperSizes.Count - 1 downto 0 do //remove any unsupported paper sizes
  begin
    if FPaperNames[i] = RMLoadStr(SRMCustomPaperSize) then
      Continue;
    if (FPaperWidths[i] = '0') or (FPaperHeights[i] = '0') then
    begin
      FPaperSizes.Delete(i);
      FPaperWidths.Delete(i);
      FPaperHeights.Delete(i);
      if i < FPaperNames.Count then
        FPaperNames.Delete(i);
    end;
  end;

  if (lCustomPos >= 0) and (lCustomPos < FPaperNames.Count - 1) then //make sure 'Custom' is last in the list
  begin
    FPaperNames.Move(lCustomPos, FPaperNames.Count - 1);
    FPaperSizes.Move(lCustomPos, FPaperSizes.Count - 1);
    FPaperWidths.Move(lCustomPos, FPaperWidths.Count - 1);
    FPaperHeights.Move(lCustomPos, FPaperHeights.Count - 1);
  end;

  FAddinPaperSizeIndex := FPaperNames.Count - 1;
  for i := 0 to FAddInPaperCount - 1 do //增加的纸张类型
  begin
    lstr := RMAddinPaperInfo[i].Name;
    if lstr = '' then
      lstr := RMLoadStr(SPaper800 + i);

    FPaperNames.Insert(FPaperNames.Count - 1, lstr);
    FPaperSizes.Insert(FPaperSizes.Count - 1, IntToStr(RMAddinPaperInfo[i].Typ));
    FPaperWidths.Insert(FPaperWidths.Count - 1, IntToStr(RMAddinPaperInfo[i].X));
    FPaperHeights.Insert(FPaperHeights.Count - 1, IntToStr(RMAddinPaperInfo[i].Y));
  end;
end;

procedure TRMPrinterInfo.ValidatePaperBins;
var
  i: Integer;
begin
  if FBinNames.Count > FBins.Count then
  begin
    for i := FBinNames.Count - 1 downto FBins.Count do
      FBinNames.Delete(i)
  end
  else if FBinNames.Count < FBins.Count then
  begin
    for i := FBins.Count - 1 downto FBinNames.Count do
      FBins.Delete(i);
  end;

  i := FBinNames.IndexOf(RMLoadStr(SDefaultBin));
  if i < 0 then
  begin
    FBinNames.Insert(0, RMLoadStr(SDefaultBin));
    FBins.Insert(0, IntToStr($FFFF));
  end;
end;

procedure TRMPrinterInfo.GetPrinterCaps(aVirtualPrinter: Boolean);
var
  i: Integer;
begin
  FLock.Acquire;
  try
    if FAlreadlyGetInfo then
      Exit;
    if aVirtualPrinter then
    begin
      FBinNames.Clear; FBins.Clear;
      FPaperNames.Clear; FPaperSizes.Clear;
      FPaperWidths.Clear; FPaperHeights.Clear;
      for i := Low(RMDefaultPaperInfo) to High(RMDefaultPaperInfo) do
      begin
        FPaperNames.Add(RMDefaultPaperInfo[i].Name);
        FPaperSizes.Add(IntToStr(RMDefaultPaperInfo[i].Typ));
        FPaperWidths.Add(IntToStr(RMDefaultPaperInfo[i].X));
        FPaperHeights.Add(IntToStr(RMDefaultPaperInfo[i].Y));
      end;
    end
    else
    begin
      GetDeviceCapability(pcPaperNames, FPaperNames);
      GetDeviceCapability(pcPapers, FPaperSizes);
      GetDeviceCapability(pcPaperWidths, FPaperWidths);
      GetDeviceCapability(pcPaperHeights, FPaperHeights);
      GetDeviceCapability(pcBinNames, FBinNames);
      GetDeviceCapability(pcBins, FBins);
    end;
    ValidatePaperSizes;
    ValidatePaperBins;
    FAlreadlyGetInfo := TRUE;
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetPaperWidth(index: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := StrToInt(FPaperWidths[index]);
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetPaperHeight(index: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := StrToInt(FPaperHeights[index]);
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterInfo.SetPaperWidth(index: Integer; Value: Integer);
begin
  FLock.Acquire;
  try
    FPaperWidths[index] := IntToStr(Value);
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterInfo.SetPaperHeight(index: Integer; Value: Integer);
begin
  FLock.Acquire;
  try
    FPaperHeights[index] := IntToStr(Value);
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetPaperSize(index: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := StrToInt(FPaperSizes[index]);
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetBin(index: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := 0;
    if index < FBins.Count then
      Result := StrToInt(FBins[index]);
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetPaperSizeIndex(pgSize: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := FPaperSizes.IndexOf(IntToStr(pgSize));
    if Result < 0 then
      Result := FPaperSizes.Count - 1; //Result := 0;
  finally
    FLock.Release;
  end;
end;

function TRMPrinterInfo.GetBinIndex(pgBin: Integer): Integer;
begin
  FLock.Acquire;
  try
    Result := FBins.IndexOf(IntToStr(pgBin));
    if Result < 0 then
      Result := 0;
  finally
    FLock.Release;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrinterList}

constructor TRMPrinterList.Create;
begin
  inherited Create;

  FLock := TCriticalSection.Create;

  FPrinters := TStringList.Create;
  BuildPrinterList;
  GetDefaultPrinter;
end;

destructor TRMPrinterList.Destroy;
begin
  FLock.Acquire;
  try
    FreePrinterList;
    FPrinters.Free;
  finally
    FLock.Release;
    FLock.Free;
  end;
  inherited Destroy;
end;

procedure TRMPrinterList.FreePrinterList;
var
  i: Integer;
begin
  for i := 0 to FPrinters.Count - 1 do
  begin
    FPrinters.Objects[i].Free;
    FPrinters.Objects[i] := nil;
  end;
end;

function TRMPrinterList.GetCount: Integer;
begin
  FLock.Acquire;
  try
    Result := FPrinters.Count;
  finally
    FLock.Release;
  end;
end;

function TRMPrinterList.GetPrinterInfo(Index: Integer): TRMPrinterInfo;
begin
  FLock.Acquire;
  try
    if Index = 0 then
      Index := FDefaultPrinterIndex;

    Result := TRMPrinterInfo(FPrinters.Objects[index]);
    if not Result.FAlreadlyGetInfo then
      Result.GetPrinterCaps(Index = 1);
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterList.Refresh;
begin
  FLock.Acquire;
  try
    BuildPrinterList;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterList.GetDefaultPrinter;
var
  I: Integer;
  lByteCnt, lStructCnt: DWORD;
  lDefaultPrinter: array[0..79] of Char;
  lCur, lDevice: PChar;
  lPrinterInfo: PPrinterInfo5;
begin
  FLock.Acquire;
  try
    FDefaultPrinterIndex := 1;
    lByteCnt := 0; lStructCnt := 0;
    if not EnumPrinters(PRINTER_ENUM_DEFAULT, nil, 5, nil, 0, lByteCnt, lStructCnt) and
      (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
      Exit;

    lPrinterInfo := AllocMem(lByteCnt);
    try
      EnumPrinters(PRINTER_ENUM_DEFAULT, nil, 5, lPrinterInfo, lByteCnt, lByteCnt, lStructCnt);
      if lStructCnt > 0 then
        lDevice := lPrinterInfo.pPrinterName
      else
      begin
        GetProfileString('windows', 'device', '', lDefaultPrinter, SizeOf(lDefaultPrinter) - 1);
        lCur := lDefaultPrinter;
        lDevice := FetchStr(lCur);
      end;
      with FPrinters do
      begin
        for i := 0 to Count - 1 do
        begin
          if string(TRMPrinterInfo(Objects[i]).Device) = lDevice then
          begin
            FDefaultPrinterIndex := i;
            Break;
          end;
        end;
      end;
    finally
      FreeMem(lPrinterInfo);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinterList.BuildPrinterList;
var
  lLineCur, lPort: PChar;
  lBuffer, lPrinterInfo: PChar;
  lFlags, lCount, lNumInfo: DWORD;
  I: Integer;
  lLevel: Byte;
  tmp: TRMPrinterInfo;
  lStr: string;
begin
  FLock.Acquire;
  try
    FreePrinterList; FPrinters.Clear;
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      lFlags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
      lLevel := 4;
    end
    else
    begin
      lFlags := PRINTER_ENUM_LOCAL;
      lLevel := 5;
    end;
    
    lCount := 0;
    EnumPrinters(lFlags, nil, lLevel, nil, 0, lCount, lNumInfo);
    if lCount > 0 then
    begin
      GetMem(lBuffer, lCount);
      try
        if not EnumPrinters(lFlags, nil, lLevel, PByte(lBuffer), lCount, lCount, lNumInfo) then
          Exit;

        lPrinterInfo := lBuffer;
        for I := 0 to lNumInfo - 1 do
        begin
          if lLevel = 4 then
          begin
            with PPrinterInfo4(lPrinterInfo)^ do
            begin
              tmp := TRMPrinterInfo.Create(nil, pPrinterName, nil);
              FPrinters.AddObject(pPrinterName, tmp);
              Inc(lPrinterInfo, sizeof(TPrinterInfo4));
            end;
          end
          else
          begin
            with PPrinterInfo5(lPrinterInfo)^ do
            begin
              lLineCur := pPortName;
              lPort := FetchStr(lLineCur);
              while lPort^ <> #0 do
              begin
                lStr := Format(SDeviceOnPort, [pPrinterName, lPort]);
                tmp := TRMPrinterInfo.Create(nil, pPrinterName, lPort);
                FPrinters.AddObject(lStr, tmp);
                lPort := FetchStr(lLineCur);
              end;
              
              Inc(lPrinterInfo, sizeof(TPrinterInfo5));
            end;
          end;
        end;
      finally
        FreeMem(lBuffer, lCount);
      end;
    end;

    tmp := TRMPrinterInfo.Create(nil, PChar(RMLoadStr(SDefaultPrinter)), nil);
    FPrinters.InsertObject(0, RMLoadStr(SDefaultPrinter), tmp);
    
    tmp := TRMPrinterInfo.Create(nil, PChar(RMLoadStr(SVirtualPrinter)), nil); // 虚拟打印机
    FPrinters.InsertObject(1, RMLoadStr(SVirtualPrinter), tmp);
  finally
    FLock.Release;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPrinterCanvas }
type
  TRMPrinterCanvas = class(TCanvas)
  private
    FPrinter: TRMCustomPrinter;
  public
    constructor Create(aPrinter: TRMCustomPrinter);
    procedure CreateHandle; override;
    procedure Changing; override;
    procedure UpdateDeviceContext;
  end;

constructor TRMPrinterCanvas.Create(aPrinter: TRMCustomPrinter);
begin
  inherited Create;
  FPrinter := aPrinter;
end;

procedure TRMPrinterCanvas.CreateHandle;
begin
  UpdateDeviceContext;
  Handle := FPrinter.DC;
end;

procedure TRMPrinterCanvas.Changing;
begin
  inherited Changing;
  UpdateDeviceContext;
end;

procedure TRMPrinterCanvas.UpdateDeviceContext;
var
  lFontSize: Integer;
begin
  if FPrinter = nil then
    Exit;
  if FPrinter.PixelsPerInch.Y <> Font.PixelsPerInch then
  begin
    lFontSize := Font.Size;
    Font.PixelsPerInch := FPrinter.PixelsPerInch.Y;
    Font.Size := lFontSize;
  end;

  if not FPrinter.CanGrayScale then
  begin
    if (Font.Color <> clBlack) and (Font.Color <> clWhite) then
      Font.Color := clBlack;
  end;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomPrinter }

constructor TRMCustomPrinter.Create;
begin
  inherited Create;

  FLock := TCriticalSection.Create;

  FAborted := False;
  FPageNumber := 0;
  FPrinting := False;
  FDocumentName := '';
  FFileName := '';
  FDC := 0;
  FDevMode := 0;
  FPrinterHandle := 0;
  FResetDC := False;
  FCanvas := nil;
  FCurrentInfo := nil;
  FPDevMode := nil;
end;

destructor TRMCustomPrinter.Destroy;
begin
  FreePrinterResources;
  FCanvas.Free;
  FLock.Free;

  inherited Destroy;
end;

procedure TRMCustomPrinter.BeginDoc;
var
  lDocInfo: TDocInfo;
begin
  if FPrinting then
    Exit;

  FLock.Acquire;
  try
    FPrinting := True;
    FAborted := False;
    FPageNumber := 0;
    FStartPage := False;

    FreeDC;
    ResetDC;

    FillChar(lDocInfo, SizeOf(lDocInfo), 0);
    lDocInfo.cbSize := SizeOf(lDocInfo);
    lDocInfo.lpszDocName := PChar(FDocumentName);
    if FFileName <> '' then
      lDocInfo.lpszOutput := PChar(FFileName);
    Windows.StartDoc(FDC, lDocInfo);
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.Abort;
begin
  if not FPrinting then
    Exit;
  FLock.Acquire;
  try
    Windows.AbortDoc(Canvas.Handle);
    FAborted := True;
    EndDoc;
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.EndDoc;
begin
  FLock.Acquire;
  try
    if not FPrinting then
      Exit;
    EndPage;
    if not FAborted then
      Windows.EndDoc(FDC);
    FreeDC;
    FPrinting := False;
    FStartPage := False;
    FAborted := False;
    FPageNumber := 0;
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.NewPage;
begin
  FLock.Acquire;
  try
    if not FPrinting or FStartPage then
      Exit;
    FStartPage := True;
    if FResetDC then
      ResetDC;
    Windows.StartPage(FDC);
    Inc(FPageNumber);
    Canvas.Refresh;
  finally
    Flock.Release;
  end;
end;

procedure TRMCustomPrinter.ResetDC;
var
  lNewDC: HDC;
begin
  FLock.Acquire;
  try
    if not FPrinting then Exit;

    FResetDC := False;
    Canvas.Refresh;
    if FDC <> 0 then
    begin
      lNewDC := Windows.ResetDC(FDC, FPDevMode^);
      if lNewDC <> 0 then
        FDC := lNewDC;
    end;
    DeviceContextChanged;
    TRMPrinterCanvas(Canvas).UpdateDeviceContext;
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.EndPage;
begin
  FLock.Acquire;
  try
    if (not FPrinting) or (not FStartPage) then
      Exit;
    FStartPage := False;
    Windows.EndPage(FDC);
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPrinterHandle: THandle;
begin
  FLock.Acquire;
  try
    if FPrinterHandle = 0 then
    begin
      FCurrentInfo := RMPrinters.PrinterInfo[FPrinterIndex];
      if FCurrentInfo <> nil then
        OpenPrinter(FCurrentInfo.Device, FPrinterHandle, nil);
    end;
    Result := FPrinterHandle;
  finally
    Flock.Release;
  end;
end;

procedure TRMCustomPrinter.GetDevMode(var aDevMode: THandle);
begin
  FLock.Acquire;
  try
    aDevMode := RMCopyHandle(GetDocumentProperties);
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetDocumentProperties: THandle;
var
  lStubDevMode: TDeviceMode;
  lPrinterInfo: TRMPrinterInfo;
begin
  FLock.Acquire;
  try
    Result := 0;
    if FDevMode = 0 then
    begin
      lPrinterInfo := RMPrinters.PrinterInfo[FPrinterIndex];
      if lPrinterInfo = nil then
        Exit;
      FDevMode := GlobalAlloc(GHND,
        DocumentProperties(0, PrinterHandle, lPrinterInfo.Device, lStubDevMode, lStubDevMode, 0));
      if FDevMode <> 0 then
      begin
        FPDevMode := GlobalLock(FDevMode);
        if DocumentProperties(0, PrinterHandle, lPrinterInfo.Device, FPDevMode^, FPDevMode^, DM_OUT_BUFFER) >= 0 then
        begin
          FDefaultBin := FPDevMode^.dmDefaultSource;
        end
        else
          FreeDevMode;
      end;
    end;
    Result := FDevMode;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPDevMode: PDevMode;
begin
  FLock.Acquire;
  try
    GetDocumentProperties;
    Result := FPDevMode;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetDC: HDC;
var
  lPrinterInfo: TRMPrinterInfo;
begin
  FLock.Acquire;
  try
    if FDC = 0 then
    begin
      lPrinterInfo := RMPrinters.PrinterInfo[FPrinterIndex];
      if (lPrinterInfo <> nil) and lPrinterInfo.IsValid then
      begin
        if FPrinting then
          FDC := CreateDC(lPrinterInfo.Driver, lPrinterInfo.Device, lPrinterInfo.Port, GetPDevMode)
        else
          FDC := CreateIC(lPrinterInfo.Driver, lPrinterInfo.Device, lPrinterInfo.Port, GetPDevMode);

        if FDC = 0 then
          lPrinterInfo.IsValid := False
        else
          lPrinterInfo.IsValid := True;

        if FCanvas <> nil then
          FCanvas.Handle := FDC;

        DeviceContextChanged;
      end;
    end;
    Result := FDC;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPrinterInfo: TRMPrinterInfo;
begin
  FLock.Acquire;
  try
    Result := RMPrinters.PrinterInfo[FPrinterIndex]
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.FreeDC;
begin
  if FDC = 0 then Exit;

  if FCanvas <> nil then
    FCanvas.Handle := 0;
  DeleteDC(FDC);
  FDC := 0;
end;

procedure TRMCustomPrinter.FreeDevMode;
begin
  if FDevMode = 0 then Exit;

  GlobalUnlock(FDevMode);
  GlobalFree(FDevMode);
  FDevMode := 0;
  FPDevMode := nil;
end;

procedure TRMCustomPrinter.FreePrinterHandle;
begin
  if FPrinterHandle <> 0 then
  begin
    ClosePrinter(FPrinterHandle);
    FPrinterHandle := 0;
    FCurrentInfo := nil;
  end;
end;

procedure TRMCustomPrinter.FreePrinterResources;
begin
  if FPrinting then Exit;

  FreeDC;
  FreeDevMode;
  FreePrinterHandle;
end;

function TRMCustomPrinter.GetCanvas: TCanvas;
begin
  FLock.Acquire;
  try
    if FCanvas = nil then
      FCanvas := TRMPrinterCanvas.Create(Self);
    Result := FCanvas;
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.SetDevMode(aDevMode: THandle);
begin
  FLock.Acquire;
  try
    if FPrinting then
      FResetDC := True
    else
      FreeDC;

    FreeDevMode;
    FDevMode := RMCopyHandle(aDevMode);
    FPDevMode := GlobalLock(FDevMode);
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPrinterName: string;
begin
	if (FPrinterIndex >= 0) and (FPrinterIndex < RMPrinters.Count) then
		Result := RMPrinters.Printers[FPrinterIndex]
  else
  	Result := '';  
end;

procedure TRMCustomPrinter.SetPrinterIndex(Value: Integer);
var
  lPrinterInfo: TRMPrinterInfo;
  lSaveWidth, lSaveHeight: Integer;
  i, lCount: Integer;
begin
  FLock.Acquire;
  try
    if FPrinting or (Value < 0) or (FPrinterIndex = Value) then Exit;

    FreeDC;
    lPrinterInfo := RMPrinters.PrinterInfo[Value];
    if lPrinterInfo <> nil then
      FPrinterIndex := Value;

    if (lPrinterInfo = nil) or (FCurrentInfo = lPrinterInfo) then Exit;

    lSaveWidth := -1; lSaveHeight := -1;
    try
      if FCurrentInfo <> nil then
      begin
        with PrinterInfo do
        begin
          i := GetPaperSizeIndex(Self.PaperSize);
          lSaveWidth := PaperWidths[i];
          lSaveHeight := PaperHeights[i];
        end;
      end;
    except
    end;

    if FCurrentInfo <> nil then
      FreePrinterResources;

    FCurrentInfo := lPrinterInfo;
    if (lSaveWidth > 0) and (lSaveHeight > 0) then
    begin
      i := 0; lCount := FCurrentInfo.PaperSizesCount;
      with FCurrentInfo do
      begin
        while i < lCount do
        begin
          try
            if (abs(PaperWidths[i] - lSaveWidth) <= 1) and
            	(abs(PaperHeights[i] - lSaveHeight) <= 1) then
              Break;
          except
          end;

          Inc(i);
        end;
        if i < lCount then
          Self.PaperSize := StrToInt(FPaperSizes[i])
        else
          Self.PaperSize := 256;
      end;
    end;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.HasColor: Boolean;
begin
  FLock.Acquire;
  try
    Result := (GetDeviceCaps(GetDC, NUMCOLORS) > 2) and (GetPDevMode^.dmColor = DMCOLOR_COLOR);
  finally
    FLock.Release;
  end;
end;

const
  FormLevel: Byte = 1;

procedure TRMCustomPrinter.UpdateForm(const aFormName: string; aDimensions: TPoint; aPrintArea: TRect);
var
  lSizeOfInfo: DWord;
  lFormInfo: TFormInfo1;
  lNewFormInfo, lCurrentFormInfo: PFormInfo1;
begin
	if Win32Platform <> VER_PLATFORM_WIN32_NT then Exit;

  FLock.Acquire;
  try
    with lFormInfo do
    begin
      Flags := 0;
      pName := PChar(aFormName);
      Size.cx := aDimensions.X;
      Size.cy := aDimensions.Y;
      ImageableArea.Left := aPrintArea.Left;
      ImageableArea.Top := aPrintArea.Top;
      ImageableArea.Right := aPrintArea.Right;
      ImageableArea.Bottom := aPrintArea.Bottom;
    end;

    lNewFormInfo := @lFormInfo;
    lSizeOfInfo := 0;
    Winspool.GetForm(PrinterHandle, PChar(aFormName), FormLevel, nil, 0, lSizeOfInfo);
    GetMem(lCurrentFormInfo, lSizeOfInfo);
    try
      if Winspool.GetForm(PrinterHandle, PChar(aFormName), FormLevel, lCurrentFormInfo, lSizeOfInfo, lSizeOfInfo) then
      begin
        if (lCurrentFormInfo.Size.cX <> lNewFormInfo.Size.cX) or
          (lCurrentFormInfo.Size.cY <> lNewFormInfo.Size.cY) or
          (lCurrentFormInfo.ImageableArea.Left <> lNewFormInfo.ImageableArea.Left) or
          (lCurrentFormInfo.ImageableArea.Top <> lNewFormInfo.ImageableArea.Top) or
          (lCurrentFormInfo.ImageableArea.Right <> lNewFormInfo.ImageableArea.Right) or
          (lCurrentFormInfo.ImageableArea.Bottom <> lNewFormInfo.ImageableArea.Bottom) then
          Winspool.SetForm(PrinterHandle, PChar(aFormName), FormLevel, lNewFormInfo);
      end
      else
      begin
        Winspool.AddForm(PrinterHandle, FormLevel, lNewFormInfo);
        //PrinterInfo.FAlreadlyGetInfo := False;
        //PrinterInfo;
      end;
    finally
      FreeMem(lCurrentFormInfo, lSizeOfInfo);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRMCustomPrinter.DeviceContextChanged;
begin
  FLock.Acquire;
  try
    if FDC = 0 then Exit;

    FPixelsPerInch.X := GetDeviceCaps(FDC, LOGPIXELSX);
    FPixelsPerInch.Y := GetDeviceCaps(FDC, LOGPIXELSY);

    FPaperWidth := GetDeviceCaps(FDC, PHYSICALWIDTH); //纸宽 ，单位为打印机象素
    FPaperHeight := GetDeviceCaps(FDC, PHYSICALHEIGHT);

    FPrintableWidth := GetDeviceCaps(FDC, HorzRes); //可打印纸宽 ，单位为打印机象素
    FPrintableHeight := GetDeviceCaps(FDC, VertRes);

    FPageGutters.Left := GetDeviceCaps(FDC, PHYSICALOFFSETX); //偏移量
    FPageGutters.Top := GetDeviceCaps(FDC, PHYSICALOFFSETY);

    FPageGutters.Right := FPaperWidth - FPageGutters.Left - FPrintableWidth;
    FPageGutters.Bottom := FPaperHeight - FPageGutters.Top - FPrintableHeight;

    FCanGrayScale := True;
    if (Win32Platform = VER_PLATFORM_WIN32_NT) and (GetDeviceCaps(FDC, SIZEPALETTE) = 2) and
      (GetDeviceCaps(FDC, NUMCOLORS) = 2) then
      FCanGrayScale := False;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetCanGrayScale: Boolean;
begin
  FLock.Acquire;
  try
    GetDC;
    Result := FCanGrayScale;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPaperWidth: Longint;
var
  lindex: Integer;

  function _GetDefaultValue: Longint;
  var
    i: Integer;
  begin
    with PrinterInfo do
    begin
      lindex := GetPaperSizeIndex(PaperSize);
      if Orientation = rmpoPortrait then
        Result := PaperWidths[lindex]
      else
        Result := PaperHeights[lindex];
    end;

    if Result = 0 then
    begin
      for i := Low(RMDefaultPaperInfo) to High(RMDefaultPaperInfo) do
      begin
        if RMDefaultPaperInfo[i].Typ = PaperSize then
        begin
          if Orientation = rmpoPortrait then
            Result := RMDefaultPaperInfo[i].X
          else
            Result := RMDefaultPaperInfo[i].Y;
          Break;
        end;
      end;
    end;

    if (Result = 0) and (lIndex = PrinterInfo.FPaperSizes.Count - 1) then
    begin
      Result := FDefaultPaperWidth;
    end;
  end;

begin
  FLock.Acquire;
  try
    GetDC;
    Result := _GetDefaultValue;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPaperHeight: Longint;
var
  lindex: Integer;

  function _GetDefaultValue: Longint;
  var
    i: Integer;
  begin
    with PrinterInfo do
    begin
      lindex := GetPaperSizeIndex(PaperSize);
      if Orientation = rmpoPortrait then
        Result := PaperHeights[lindex]
      else
        Result := PaperWidths[lindex];
    end;

    if Result = 0 then
    begin
      for i := Low(RMDefaultPaperInfo) to High(RMDefaultPaperInfo) do
      begin
        if RMDefaultPaperInfo[i].Typ = PaperSize then
        begin
          if Orientation = rmpoPortrait then
            Result := RMDefaultPaperInfo[i].Y
          else
            Result := RMDefaultPaperInfo[i].X;
          Break;
        end;
      end;
    end;

    if (Result = 0) and (lIndex = PrinterInfo.FPaperSizes.Count - 1) then
    begin
      Result := FDefaultPaperHeight;
    end;
  end;

begin
  FLock.Acquire;
  try
    GetDC;
    Result := _GetDefaultValue;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPageGutters: TRect;
begin
  FLock.Acquire;
  try
    GetDC;
    if FDC <> 0 then
      Result := FPageGutters
    else
      Result := Rect(0, 0, 0, 0);
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPixelsPerInch: TPoint;
begin
  FLock.Acquire;
  try
    GetDC;
    if FDC <> 0 then
      Result := FPixelsPerInch
    else
      Result := Point(Screen.PixelsPerInch, Screen.PixelsPerInch);
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPrintableHeight: LongInt;
begin
  FLock.Acquire;
  try
    GetDC;
    Result := FPrintableHeight;
  finally
    FLock.Release;
  end;
end;

function TRMCustomPrinter.GetPrintableWidth: LongInt;
begin
  FLock.Acquire;
  try
    GetDC;
    Result := FPrintableWidth;
  finally
    FLock.Release;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMPrinter}

constructor TRMPrinter.Create;
begin
  inherited Create;
  FCopies := 1;
  PaperSize := 9;
end;

destructor TRMPrinter.Destroy;
begin
  inherited Destroy;
end;

procedure TRMPrinter.FillPrinterInfo(var p: TRMPageInfo);
var
  lindex: Integer;
begin
  FLock.Acquire;
  try
    if (FPrinterIndex = 1) or (RMPrinters.Count = 2) then
    begin
      with PrinterInfo do
      begin
        lindex := GetPaperSizeIndex(PaperSize);
        if Orientation = rmpoPortrait then
        begin
          p.ScreenPageWidth := RMToScreenPixels(PaperWidths[lindex] * 100, rmutMMThousandths);
          p.ScreenPageHeight := RMToScreenPixels(PaperHeights[lindex] * 100, rmutMMThousandths);
        end
        else
        begin
          p.ScreenPageWidth := RMToScreenPixels(PaperHeights[lindex] * 100, rmutMMThousandths);
          p.ScreenPageHeight := RMToScreenPixels(PaperWidths[lindex] * 100, rmutMMThousandths);
        end;
      end;
    end
    else
    begin
      p.PrinterPageWidth := FPaperWidth;
      p.PrinterPageHeight := FPaperHeight;
      p.ScreenPageWidth := RMToScreenPixels(PaperWidth * 100, rmutMMThousandths);
      p.ScreenPageHeight := RMToScreenPixels(PaperHeight * 100, rmutMMThousandths);
      p.PrinterPageWidth := Round(PaperWidth * FPixelsPerInch.X * RMInchPerMM / 10);
      p.PrinterPageHeight := Round(PaperHeight * FPixelsPerInch.Y * RMInchPerMM / 10);

      p.PrinterOffsetX := PageGutters.Left;
      p.PrinterOffsetY := PageGutters.Top;
    end;

    FFactorX := p.PrinterPageWidth / p.ScreenPageWidth;
    FFactorY := p.PrinterPageHeight / p.ScreenPageHeight;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinter.GetSettings;
var
  lDevMode: THandle;
  lPDevMode: PDeviceMode;
begin
  FLock.Acquire;
  try
    GetDevMode(lDevMode);
    if lDevMode = 0 then
    begin
      DefaultPaper := DMPAPER_A4;
      FDefaultPaperWidth := PaperWidth;
      FDefaultPaperHeight := PaperHeight;
      FDefaultPaperOr := rmpoPortrait;
      Exit;
    end;

    lPDevMode := GlobalLock(lDevMode);
    if lPDevMode = nil then Exit;
    try
      try
        PaperSize := lPDevMode^.dmPaperSize;
        Bin := lPDevMode^.dmDefaultSource;
        if lPDevMode^.dmOrientation = DMORIENT_PORTRAIT then
          Orientation := rmpoPortrait
        else
          Orientation := rmpoLandscape;

        GlobalUnlock(lDevMode);
      except
        GlobalUnlock(lDevMode);
      end;

      DefaultPaper := PaperSize;
      GetDC;
      if FDC <> 0 then
      begin
        FDefaultPaperWidth := Round(FPaperWidth * 254 / FPixelsPerInch.X);
        FDefaultPaperHeight := Round(FPaperHeight * 254 / FPixelsPerInch.Y);
	      FDefaultPaperOr := Orientation;
      end;
    finally
      GlobalFree(lDevMode);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinter.SetSettings(aPgWidth, aPgHeight: Integer);
var
  lRect: TRect;
  lPoint: TPoint;
  lDevMode: THandle;
  lPDevMode: PDeviceMode;
  lIndex, lPaperWidth, lPaperHeight: Integer;
begin
  FLock.Acquire;
  try
    if PaperSize = PrinterInfo.PaperSizes[PrinterInfo.PaperSizesCount - 1] then
    begin
      lIndex := PrinterInfo.PaperSizesCount - 1;
      if Orientation = rmpoPortrait then
      begin
        PrinterInfo.PaperWidths[lIndex] := aPgWidth;
        PrinterInfo.PaperHeights[lIndex] := aPgHeight;
      end
      else
      begin
        PrinterInfo.PaperWidths[lIndex] := aPgHeight;
        PrinterInfo.PaperHeights[lIndex] := aPgWidth;
      end;

      if (FPrinterIndex = 1) or (RMPrinters.Count = 2) then // 虚拟打印机
        Exit;
    end;

    GetDevMode(lDevMode);
    lPDevMode := GlobalLock(lDevMode);
    if lPDevMode = nil then Exit;

    lPaperWidth := 0; lPaperHeight := 0;
    lIndex := PrinterInfo.GetPaperSizeIndex(PaperSize);
    if lIndex >= PrinterInfo.AddInPaperSizeIndex then
    begin
      with PrinterInfo do
      begin
        if lIndex = PaperSizesCount - 1 then
        begin
          lPaperWidth := aPgWidth;
          lPaperHeight := aPgHeight;
        end
        else
        begin
          if Orientation = rmpoPortrait then //竖放
          begin
            lPaperWidth := PaperWidths[lIndex];
            lPaperHeight := PaperHeights[lIndex];
          end
          else
          begin
            lPaperWidth := PaperHeights[lIndex];
            lPaperHeight := PaperWidths[lIndex];
          end;
        end;
      end;
    end;

    try
      if (Win32Platform = VER_PLATFORM_WIN32_NT) and (lIndex >= PrinterInfo.AddInPaperSizeIndex) then // WinNT,自定义纸张
      begin
        if Orientation = rmpoPortrait then //竖放
        begin
          lPoint.X := lPaperWidth * 100;
          lPoint.Y := lPaperHeight * 100;
        end
        else
        begin
          lPoint.X := lPaperHeight * 100;
          lPoint.Y := lPaperWidth * 100;
        end;
        lRect := Rect(0, 0, lPoint.X, lPoint.Y);

        UpdateForm('Custom', lPoint, lRect);
        //lPDevMode^.dmFields := DM_FORMNAME;
        lPDevMode^.dmFormName := 'Custom';
      end;

      FTruePaperWidth := aPgWidth;
      FTruePaperHeight := aPgHeight;
      lPDevMode^.dmFields := DM_COPIES or DM_DUPLEX or DM_ORIENTATION or DM_PAPERSIZE or
        DM_COLOR;

      lPDevMode^.dmPaperSize := PaperSize; //纸张类型
      if lIndex >= PrinterInfo.AddInPaperSizeIndex then
      begin
        lPDevMode^.dmFields := lpDevMode^.dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH;
//        if Win32Platform = VER_PLATFORM_WIN32_NT then
//          lpDevMode^.dmPaperSize := 512
//        else
//          lpDevMode^.dmPaperSize := PrinterInfo.CustomPaperSize;

        //lpDevMode^.dmPaperSize := 256;    // 2005.9.5  whf，可能有问题
        if Orientation = rmpoPortrait then //竖放
        begin
          lPDevMode^.dmPaperWidth := lPaperWidth;
          lPDevMode^.dmPaperLength := lPaperHeight;
        end
        else
        begin
          lPDevMode^.dmPaperWidth := lPaperHeight;
          lPDevMode^.dmPaperLength := lPaperWidth;
        end;
      end
      else
        lPDevMode^.dmFields := lPDevMode^.dmFields and not (DM_PAPERLENGTH or DM_PAPERWIDTH);

      lPDevMode^.dmDuplex := 1;
      if Orientation = rmpoPortrait then
        lPDevMode^.dmOrientation := DMORIENT_PORTRAIT
      else
        lPDevMode^.dmOrientation := DMORIENT_LANDSCAPE;
      if FCopies < 1 then
        lPDevMode^.dmCopies := 1
      else
        lPDevMode^.dmCopies := FCopies;
      if PrinterInfo.FBins.IndexOf(IntToStr(Bin)) >= 0 then //进纸方式
      begin
        if (Bin and $FFFF) <> $FFFF then
          lPDevMode^.dmDefaultSource := Bin
        else // 默认进纸方式
          lPDevMode^.dmDefaultSource := FDefaultBin;
        lPDevMode^.dmFields := lPDevMode^.dmFields or DM_DEFAULTSOURCE;
      end;

      if FColorPrint then // 彩色打印
        lPDevMode^.dmColor := DMCOLOR_COLOR
      else
        lPDevMode^.dmColor := DMCOLOR_MONOCHROME;
      case FDuplex of
        rmdpNone: lPDevMode^.dmDuplex := DMDUP_SIMPLEX;
        rmdpHorizontal: lPDevMode^.dmDuplex := DMDUP_HORIZONTAL;
        rmdpVertical: lPDevMode^.dmDuplex := DMDUP_VERTICAL;
      end;
    finally
      GlobalUnlock(lDevMode);
      SetDevMode(lDevMode);
      GlobalFree(lDevMode);
    end;
  finally
    FLock.Release;
  end;
end;

function TRMPrinter.IsEqual(apgSize, apgWidth, apgHeight, apgBin: Integer; apgOr: TRMPrinterOrientation;
  aDuplex: TRMDuplex): Boolean;
begin
  Result := (PaperSize = apgSize) and (Orientation = apgOr) and
    ((Bin = apgBin) or ((apgBin and $FFFF) = $FFFF)) and
    (abs(PaperWidth - apgWidth) <= 3) and (abs(PaperHeight - apgHeight) <= 3) and
    (Duplex = aDuplex);
end;

procedure TRMPrinter.SetPrinterInfo(aPageSize, aPageWidth, aPageHeight, aPageBin: Integer;
  aPageOrientation: TRMPrinterOrientation; aSetImmediately: Boolean);
var
  lIndex: Integer;
  lPrinterInfo: TRMPrinterInfo;

  procedure _SetpgSize;
  var
    lOldWidth, lOldHeight, lIndex: Integer;
  begin
    lIndex := lPrinterInfo.GetPaperSizeIndex(aPageSize);
    if lIndex >= lPrinterInfo.AddInPaperSizeIndex then  // 不是自定义纸张
    begin
      aPageSize := lPrinterInfo.PaperSizes[lIndex];
      Exit;
    end;

    if aPageOrientation = rmpoPortrait then //竖放
    begin
      lOldWidth := lPrinterInfo.PaperWidths[lIndex];
      lOldHeight := lPrinterInfo.PaperHeights[lIndex];
    end
    else
    begin
      lOldWidth := lPrinterInfo.PaperHeights[lIndex];
      lOldHeight := lPrinterInfo.PaperWidths[lIndex];
    end;

    if (abs(aPageWidth - lOldWidth) > 1) or (abs(aPageHeight - lOldHeight) > 1) then
    begin
      aPageSize := lPrinterInfo.PaperSizes[lPrinterInfo.PaperSizesCount - 1];
    end;
  end;

begin
	if Printing then Exit;

  FLock.Acquire;
  try
    lPrinterInfo := PrinterInfo;
//    if aPageSize = 256 then
//      aPageSize := PrinterInfo.CustomPaperSize;

    if (aPageWidth = 0) or (aPageHeight = 0) then // 可能是用代码设置页面信息
    begin
      lIndex := lPrinterInfo.GetPaperSizeIndex(aPageSize);
      if lIndex < lPrinterInfo.AddInPaperSizeIndex then
      begin
        if aPageOrientation = rmpoPortrait then //竖放
        begin
          aPageWidth := lPrinterInfo.PaperWidths[lIndex];
          aPageHeight := lPrinterInfo.PaperHeights[lIndex];
        end
        else
        begin
          aPageWidth := lPrinterInfo.PaperHeights[lIndex];
          aPageHeight := lPrinterInfo.PaperWidths[lIndex];
        end;
      end;
    end;

    if not aSetImmediately then
    begin
      if IsEqual(aPageSize, aPageWidth, aPageHeight, aPageBin, aPageOrientation, Duplex) then
        Exit;
    end;

    _SetpgSize; // 如果是自定义的大小，需要判断是否与旧的格式一样
    PaperSize := aPageSize;
    Orientation := aPageOrientation;
    Bin := aPageBin;
    SetSettings(aPageWidth, aPageHeight);
  finally
    FLock.Release;
  end;
end;

function TRMPrinter.PropertiesDlg: Boolean;
var
  lDevMode: THandle;
  lPDevMode: PDeviceMode;
  lForm: TForm;
  lResult: Boolean;
begin
  FLock.Acquire;
  try
    GetDevMode(lDevMode);
    Result := False;
    lResult := FALSE;
    try
      lPDevMode := GlobalLock(lDevMode);
      lForm := Screen.ActiveForm;
      if (lPDevMode <> nil) and (lForm <> nil) then
        lResult := (Winspool.DocumentProperties(lForm.Handle, PrinterHandle, PrinterInfo.Device, lPDevMode^, lPDevMode^, DM_IN_BUFFER or DM_IN_PROMPT or DM_OUT_BUFFER) > 0);

      if lResult then
      begin
        SetDevMode(lDevMode);
        Result := True;
      end;

      GlobalUnlock(lDevMode);
    finally
      GlobalFree(lDevMode);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRMPrinter.Update;
begin
  FLock.Acquire;
  try
//  GetSettings;
  finally
    FLock.Release;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPageSetting }

procedure TRMPageSetting.SetValue(Index: integer; Value: Double);
begin
  case Index of
    0: if Value >= 0 then
        FMarginLeft := Value;
    1: if Value >= 0 then
        FMarginTop := Value;
    2: if Value >= 0 then
        FMarginRight := Value;
    3: if Value >= 0 then
        FMarginBottom := Value;
    4: if Value >= 0 then
        FColGap := Value;
  end;
end;

procedure TRMPageSetting.SetColCount(Value: Integer);
begin
  if Value > 0 then
    FColCount := Value;
end;

procedure TRMPageSetting.SetPageOr(Value: TRMPrinterOrientation);
var
  liSavePageWidth: Integer;
begin
  if FPageOr = Value then
    Exit;
  FPageOr := Value;
  liSavePageWidth := FPageWidth;
  FPageWidth := FPageHeight;
  FPageHeight := liSavePageWidth;
end;


{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
var
  FSaveOnAfterInitEvent: TRMRMOnAfterInit;

procedure Init;
var
  i: Integer;
begin
  for i := 0 to PAPERCOUNT - 1 do
    RMDefaultPaperInfo[i].Name := RMLoadStr(SPaper1 + i);
end;

procedure OnAfterInitEvent(aFirstTime: Boolean);
begin
  Init;
  if Assigned(FSaveOnAfterInitEvent) then FSaveOnAfterInitEvent(aFirstTime);
end;

initialization
//  rmThreadDone := True;
  Init;
  FSaveOnAfterInitEvent := RMResourceManager.OnAfterInit;
  RMResourceManager.OnAfterInit := OnAfterInitEvent;

finalization
  FreeAndNil(FRMPrinter);
  FreeAndNil(FRMPrinters);

end.

