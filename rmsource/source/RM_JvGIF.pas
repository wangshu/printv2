{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvGIF.PAS, released on 2002-07-04.

The Initial Developers of the Original Code are: Fedor Koshevnikov, Igor Pavluk and Serge Korolev
Copyright (c) 1997, 1998 Fedor Koshevnikov, Igor Pavluk and Serge Korolev
Copyright (c) 2001,2002 SGB Software
All Rights Reserved.

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
  GIF support is native for VisualCLX so this file is VCL only
-----------------------------------------------------------------------------}
// $Id: JvGIF.pas,v 1.30 2005/02/17 10:20:34 marquardt Exp $

unit RM_JvGIF;

{$I RM.INC}
{$I rm_jvcl.inc}
{$I rm_vclonly.inc}

interface

uses
{$IFDEF UNITVERSIONING}
  JclUnitVersioning,
{$ENDIF UNITVERSIONING}
  Windows,
{$IFDEF HAS_UNIT_RTLCONSTS}
  RTLConsts,
{$ENDIF HAS_UNIT_RTLCONSTS}
  SysUtils, Classes, Graphics, Controls;

const
  RT_GIF = 'GIF'; { GIF Resource Type }

type
  TGIFVersion = (gvUnknown, gv87a, gv89a);
  TGIFBits = 1..8;
  TDisposalMethod = (dmUndefined, dmLeave, dmRestoreBackground,
    dmRestorePrevious, dmReserved4, dmReserved5, dmReserved6, dmReserved7);

  TGIFColorItem = packed record
    Red: Byte;
    Green: Byte;
    Blue: Byte;
  end;

  TGIFColorTable = packed record
    Count: Integer;
    Colors: packed array[Byte] of TGIFColorItem;
  end;

  TJvGIFFrame = class;
  TGIFData = class;
  TGIFItem = class;

  TJvGIFImage = class(TGraphic)
  private
    FImage: TGIFData;
    FVersion: TGIFVersion;
    FItems: TList;
    FFrameIndex: Integer;
    FScreenWidth: Word;
    FScreenHeight: Word;
    FBackgroundColor: TColor;
    FLooping: Boolean;
    FCorrupted: Boolean;
    FRepeatCount: Word;
    function GetBitmap: TBitmap;
    function GetCount: Integer;
    function GetComment: TStrings;
    function GetScreenWidth: Integer;
    function GetScreenHeight: Integer;
    function GetGlobalColorCount: Integer;
    procedure UpdateScreenSize;
    procedure SetComment(Value: TStrings);
    function GetFrame(Index: Integer): TJvGIFFrame;
    procedure SetFrameIndex(Value: Integer);
    procedure SetBackgroundColor(Value: TColor);
    procedure SetLooping(Value: Boolean);
    procedure SetRepeatCount(Value: Word);
    procedure ReadSignature(Stream: TStream);
    procedure DoProgress(Stage: TProgressStage; PercentDone: Byte;
      const Msg: string);
    function GetCorrupted: Boolean;
    function GetTransparentColor: TColor;
    function GetBackgroundColor: TColor;
    function GetPixelFormat: TPixelFormat;
    procedure EncodeFrames(ReverseDecode: Boolean);
    procedure ReadStream(Size: Longint; Stream: TStream; ForceDecode: Boolean);
    procedure WriteStream(Stream: TStream; WriteSize: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Draw(ACanvas: TCanvas; const ARect: TRect); override;
    function Equals(Graphic: TGraphic): Boolean; override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    function GetPalette: HPALETTE; override;
    function GetTransparent: Boolean; override;
    procedure ClearItems;
    procedure NewImage;
    procedure UniqueImage;
    procedure ReadData(Stream: TStream); override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure WriteData(Stream: TStream); override;
    property Bitmap: TBitmap read GetBitmap; { volatile }
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear;
    procedure DecodeAllFrames;
    procedure EncodeAllFrames;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;
    procedure LoadFromResourceName(Instance: THandle; const ResName: string;
      ResType: PChar);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer;
      ResType: PChar);
    function AddFrame(Value: TGraphic): Integer; virtual;
    procedure DeleteFrame(Index: Integer);
    procedure MoveFrame(CurIndex, NewIndex: Integer);
    procedure Grayscale(ForceEncoding: Boolean);
    property BackgroundColor: TColor read GetBackgroundColor write SetBackgroundColor;
    property Comment: TStrings read GetComment write SetComment;
    property Corrupted: Boolean read GetCorrupted;
    property Count: Integer read GetCount;
    property Frames[Index: Integer]: TJvGIFFrame read GetFrame; default;
    property FrameIndex: Integer read FFrameIndex write SetFrameIndex;
    property GlobalColorCount: Integer read GetGlobalColorCount;
    property Looping: Boolean read FLooping write SetLooping;
    property PixelFormat: TPixelFormat read GetPixelFormat;
    property RepeatCount: Word read FRepeatCount write SetRepeatCount;
    property ScreenWidth: Integer read GetScreenWidth;
    property ScreenHeight: Integer read GetScreenHeight;
    property TransparentColor: TColor read GetTransparentColor;
    property Version: TGIFVersion read FVersion;
  end;

  TJvGIFFrame = class(TPersistent)
  private
    FOwner: TJvGIFImage;
    FBitmap: TBitmap;
    FImage: TGIFItem;
    FExtensions: TList;
    FTopLeft: TPoint;
    FInterlaced: Boolean;
    FCorrupted: Boolean;
    FGrayscale: Boolean;
    FTransparentColor: TColor;
    FAnimateInterval: Word;
    FDisposal: TDisposalMethod;
    FLocalColors: Boolean;
    function GetBitmap: TBitmap;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetColorCount: Integer;
    function FindComment(ForceCreate: Boolean): TStrings;
    function GetComment: TStrings;
    procedure SetComment(Value: TStrings);
    procedure SetTransparentColor(Value: TColor);
    procedure SetDisposalMethod(Value: TDisposalMethod);
    procedure SetAnimateInterval(Value: Word);
    procedure SetTopLeft(const Value: TPoint);
    procedure NewBitmap;
    procedure NewImage;
    procedure SaveToBitmapStream(Stream: TMemoryStream);
    procedure EncodeBitmapStream(Stream: TMemoryStream);
    procedure EncodeRasterData;
    procedure UpdateExtensions;
    procedure WriteImageDescriptor(Stream: TStream);
    procedure WriteLocalColorMap(Stream: TStream);
    procedure WriteRasterData(Stream: TStream);
  protected
    constructor Create(AOwner: TJvGIFImage); virtual;
    procedure LoadFromStream(Stream: TStream);
    procedure AssignTo(Dest: TPersistent); override;
    procedure GrayscaleImage(ForceEncoding: Boolean);
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Draw(ACanvas: TCanvas; const ARect: TRect;
      Transparent: Boolean);
    property AnimateInterval: Word read FAnimateInterval write SetAnimateInterval;
    property Bitmap: TBitmap read GetBitmap; { volatile }
    property ColorCount: Integer read GetColorCount;
    property Comment: TStrings read GetComment write SetComment;
    property DisposalMethod: TDisposalMethod read FDisposal write SetDisposalMethod;
    property Interlaced: Boolean read FInterlaced;
    property Corrupted: Boolean read FCorrupted;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
    property Origin: TPoint read FTopLeft write SetTopLeft;
    property Height: Integer read GetHeight;
    property Width: Integer read GetWidth;
  end;

  TGIFData = class(TSharedImage)
  private
    FComment: TStringList;
    FAspectRatio: Byte;
    FBitsPerPixel: Byte;
    FColorResBits: Byte;
    FColorMap: TGIFColorTable;
  protected
    procedure FreeHandle; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGIFItem = class(TSharedImage)
  private
    FImageData: TMemoryStream;
    FSize: TPoint;
    FPackedFields: Byte;
    FBitsPerPixel: Byte;
    FColorMap: TGIFColorTable;
  protected
    procedure FreeHandle; override;
  public
    destructor Destroy; override;
  end;

var
  CF_GIF: Word; { Clipboard format for GIF image }

{ Load incomplete or corrupted images without exceptions }

// (rom) changed to var to allow changes
var
  GIFLoadCorrupted: Boolean = True;

function GIFVersionName(Version: TGIFVersion): string;
procedure JvGif_Dummy;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$RCSfile: JvGIF.pas,v $';
    Revision: '$Revision: 1.30 $';
    Date: '$Date: 2005/02/17 10:20:34 $';
    LogPath: 'JVCL\run'
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  Consts, Math,
  RM_JvUtils;

{$RANGECHECKS OFF}

resourcestring
  RsGIFImage = 'CompuServe GIF Image';

  RsEChangeGIFSize = 'Cannot change the Size of a GIF image';
  RsENoGIFData = 'No GIF Data to write';
  RsEUnrecognizedGIFExt = 'Unrecognized extension block: %.2x';
  RsEWrongGIFColors = 'Wrong number of colors; must be a power of 2';
  RsEBadGIFCodeSize = 'GIF code size not in range 2 to 9';
  RsEGIFDecodeError = 'GIF encoded data is corrupt';
  RsEGIFEncodeError = 'GIF image encoding error';
  RsEGIFVersion = 'Unknown GIF version';
  RsEPixelFormatNotImplemented = 'BitmapToMemoryStream: pixel format not implemented';
  RsEBitCountNotImplemented = 'BitmapToMemoryStream: bit count not implemented';

const
  MaxPixelCount = 32767;

const
  // for CreateCompatibleDC
  HDC_DESKTOP = HDC(0);

type
  EJVCLException = class(Exception);

  TJvRGBTriple = packed record
    rgbBlue: Byte;
    rgbGreen: Byte;
    rgbRed: Byte;
  end;

  PJvRGBArray = ^TJvRGBArray;
  TJvRGBArray = array[0..MaxPixelCount] of TJvRGBTriple;
  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array[0..MaxPixelCount] of TRGBQuad;
  PRGBPalette = ^TRGBPalette;
  TRGBPalette = array[Byte] of TRGBQuad;

const
  PaletteMask = $02000000;

type
  TMappingMethod = (mmHistogram, mmQuantize, mmTrunc784, mmTrunc666,
    mmTripel, mmGrayscale);

var
  DefaultMappingMethod: TMappingMethod = mmHistogram;


function PaletteColor(Color: TColor): Longint;
begin
  Result := ColorToRGB(Color) or PaletteMask;
end;

procedure StretchBltTransparent(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, Srch: Integer; Palette: HPALETTE;
  TransparentColor: TColorRef);
var
  Color: TColorRef;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBITMAP;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBITMAP;
  MemDC, BackDC, ObjectDC, SaveDC: HDC;
  palDst, palMem, palSave, palObj: HPALETTE;
begin
  { Create some DCs to hold temporary data }
  BackDC := CreateCompatibleDC(DstDC);
  ObjectDC := CreateCompatibleDC(DstDC);
  MemDC := CreateCompatibleDC(DstDC);
  SaveDC := CreateCompatibleDC(DstDC);
  { Create a bitmap for each DC }
  bmAndObject := CreateBitmap(SrcW, Srch, 1, 1, nil);
  bmAndBack := CreateBitmap(SrcW, Srch, 1, 1, nil);
  bmAndMem := CreateCompatibleBitmap(DstDC, DstW, DstH);
  bmSave := CreateCompatibleBitmap(DstDC, SrcW, Srch);
  { Each DC must select a bitmap object to store pixel data }
  bmBackOld := SelectObject(BackDC, bmAndBack);
  bmObjectOld := SelectObject(ObjectDC, bmAndObject);
  bmMemOld := SelectObject(MemDC, bmAndMem);
  bmSaveOld := SelectObject(SaveDC, bmSave);
  { Select palette }
  palDst := 0;
  palMem := 0;
  palSave := 0;
  palObj := 0;
  if Palette <> 0 then
  begin
    palDst := SelectPalette(DstDC, Palette, True);
    RealizePalette(DstDC);
    palSave := SelectPalette(SaveDC, Palette, False);
    RealizePalette(SaveDC);
    palObj := SelectPalette(ObjectDC, Palette, False);
    RealizePalette(ObjectDC);
    palMem := SelectPalette(MemDC, Palette, True);
    RealizePalette(MemDC);
  end;
  { Set proper mapping mode }
  SetMapMode(SrcDC, GetMapMode(DstDC));
  SetMapMode(SaveDC, GetMapMode(DstDC));
  { Save the bitmap sent here }
  BitBlt(SaveDC, 0, 0, SrcW, Srch, SrcDC, SrcX, SrcY, SRCCOPY);
  { Set the background color of the source DC to the color,         }
  { contained in the parts of the bitmap that should be transparent }
  Color := SetBkColor(SaveDC, PaletteColor(TransparentColor));
  { Create the object mask for the bitmap by performing a BitBlt()  }
  { from the source bitmap to a monochrome bitmap                   }
  BitBlt(ObjectDC, 0, 0, SrcW, Srch, SaveDC, 0, 0, SRCCOPY);
  { Set the background color of the source DC back to the original  }
  SetBkColor(SaveDC, Color);
  { Create the inverse of the object mask }
  BitBlt(BackDC, 0, 0, SrcW, Srch, ObjectDC, 0, 0, NOTSRCCOPY);
  { Copy the background of the main DC to the destination }
  BitBlt(MemDC, 0, 0, DstW, DstH, DstDC, DstX, DstY, SRCCOPY);
  { Mask out the places where the bitmap will be placed }
  StretchBlt(MemDC, 0, 0, DstW, DstH, ObjectDC, 0, 0, SrcW, Srch, SRCAND);
  { Mask out the transparent colored pixels on the bitmap }
  BitBlt(SaveDC, 0, 0, SrcW, Srch, BackDC, 0, 0, SRCAND);
  { XOR the bitmap with the background on the destination DC }
  StretchBlt(MemDC, 0, 0, DstW, DstH, SaveDC, 0, 0, SrcW, Srch, SRCPAINT);
  { Copy the destination to the screen }
  BitBlt(DstDC, DstX, DstY, DstW, DstH, MemDC, 0, 0, SRCCOPY);
  { Restore palette }
  if Palette <> 0 then
  begin
    SelectPalette(MemDC, palMem, False);
    SelectPalette(ObjectDC, palObj, False);
    SelectPalette(SaveDC, palSave, False);
    SelectPalette(DstDC, palDst, True);
  end;
  { Delete the memory bitmaps }
  DeleteObject(SelectObject(BackDC, bmBackOld));
  DeleteObject(SelectObject(ObjectDC, bmObjectOld));
  DeleteObject(SelectObject(MemDC, bmMemOld));
  DeleteObject(SelectObject(SaveDC, bmSaveOld));
  { Delete the memory DCs }
  DeleteDC(MemDC);
  DeleteDC(BackDC);
  DeleteDC(ObjectDC);
  DeleteDC(SaveDC);
end;

procedure StretchBitmapTransparent(Dest: TCanvas; Bitmap: TBitmap;
  TransparentColor: TColor; DstX, DstY, DstW, DstH, SrcX, SrcY,
  SrcW, Srch: Integer);
var
  CanvasChanging: TNotifyEvent;
begin
  if DstW <= 0 then
    DstW := Bitmap.Width;
  if DstH <= 0 then
    DstH := Bitmap.Height;
  if (SrcW <= 0) or (Srch <= 0) then
  begin
    SrcX := 0;
    SrcY := 0;
    SrcW := Bitmap.Width;
    Srch := Bitmap.Height;
  end;
  {$IFDEF VisualCLX}
  Dest.Start;
  {$ENDIF VisualCLX}
  if not Bitmap.Monochrome then
    SetStretchBltMode(Dest.Handle, STRETCH_DELETESCANS);
  CanvasChanging := Bitmap.Canvas.OnChanging;
  Bitmap.Canvas.Lock;
  try
    Bitmap.Canvas.OnChanging := nil;
    {$IFDEF VisualCLX}
    Bitmap.Canvas.Start;
    {$ENDIF VisualCLX}
    if TransparentColor = clNone then
    begin
      StretchBlt(Dest.Handle, DstX, DstY, DstW, DstH, Bitmap.Canvas.Handle,
        SrcX, SrcY, SrcW, Srch, Cardinal(Dest.CopyMode));
    end
    else
    begin
      if TransparentColor = clDefault then
        TransparentColor := Bitmap.Canvas.Pixels[0, Bitmap.Height - 1];
      if Bitmap.Monochrome then
        TransparentColor := clWhite
      else
        TransparentColor := ColorToRGB(TransparentColor);
      {$IFDEF VCL}
      StretchBltTransparent(Dest.Handle, DstX, DstY, DstW, DstH,
        Bitmap.Canvas.Handle, SrcX, SrcY, SrcW, Srch,
        Bitmap.Palette, TransparentColor);
      {$ENDIF VCL}
      {$IFDEF VisualCLX}
      StretchBltTransparent(Dest.Handle, DstX, DstY, DstW, DstH,
        Bitmap.Canvas.Handle, SrcX, SrcY, SrcW, Srch,
        0, TransparentColor);
      {$ENDIF VisualCLX}
    end;
    {$IFDEF VisualCLX}
    Bitmap.Canvas.Stop;
    {$ENDIF VisualCLX}
  finally
    Bitmap.Canvas.OnChanging := CanvasChanging;
    Bitmap.Canvas.Unlock;
    {$IFDEF VisualCLX}
    Dest.Stop;
    {$ENDIF VisualCLX}
  end;
end;

procedure StretchBitmapRectTransparent(Dest: TCanvas; DstX, DstY,
  DstW, DstH: Integer; SrcRect: TRect; Bitmap: TBitmap;
  TransparentColor: TColor);
begin
  with SrcRect do
    StretchBitmapTransparent(Dest, Bitmap, TransparentColor,
      DstX, DstY, DstW, DstH, Left, Top, Right - Left, Bottom - Top);
end;

procedure InvalidBitmap;
begin
  raise EInvalidGraphic.CreateRes(@SInvalidBitmap);
end;

function WidthBytes(I: Longint): Longint;
begin
  Result := ((I + 31) div 32) * 4;
end;

function PixelFormatToColors(PixelFormat: TPixelFormat): Integer;
begin
  case PixelFormat of
    pf1bit:
      Result := 2;
{$IFDEF VCL}
    pf4bit:
      Result := 16;
{$ENDIF VCL}
    pf8bit:
      Result := 256;
  else
    Result := 0;
  end;
end;

procedure HMemCpy(DstPtr, SrcPtr: Pointer; Amount: Longint);
begin
  Move(SrcPtr^, DstPtr^, Amount);
end;

procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  PixelFormat: TPixelFormat);
var
  DS: TDIBSection;
  Bytes: Integer;
begin
  DS.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DS), @DS);
  if Bytes = 0 then
    InvalidBitmap
  else
    if (Bytes >= (SizeOf(DS.dsbm) + SizeOf(DS.dsbmih))) and
      (DS.dsbmih.biSize >= DWORD(SizeOf(DS.dsbmih))) then
      BI := DS.dsbmih
    else
    begin
      FillChar(BI, SizeOf(BI), 0);
      with BI, DS.dsbm do
      begin
        biSize := SizeOf(BI);
        biWidth := bmWidth;
        biHeight := bmHeight;
      end;
    end;
  case PixelFormat of
    pf1bit: BI.biBitCount := 1;
    pf4bit: BI.biBitCount := 4;
    pf8bit: BI.biBitCount := 8;
    pf24bit: BI.biBitCount := 24;
  else
    BI.biBitCount := DS.dsbm.bmBitsPixel * DS.dsbm.bmPlanes;
  end;
  BI.biPlanes := 1;
  if BI.biSizeImage = 0 then
    BI.biSizeImage := BytesPerScanLine(BI.biWidth, BI.biBitCount, 32) *
      Abs(BI.biHeight);
end;

procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: Longint; BitCount: TPixelFormat);
var
  BI: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, BI, BitCount);
  if BI.biBitCount > 8 then
  begin
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if (BI.biCompression and BI_BITFIELDS) <> 0 then
      Inc(InfoHeaderSize, 12);
  end
  else
    InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) * (1 shl BI.biBitCount);
  ImageSize := BI.biSizeImage;
end;

function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; PixelFormat: TPixelFormat): Boolean;
var
  OldPal: HPALETTE;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), PixelFormat);
  with TBitmapInfoHeader(BitmapInfo) do
    biHeight := Abs(biHeight);
  OldPal := 0;
  DC := CreateCompatibleDC(HDC_DESKTOP);
  try
    if Palette <> 0 then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight,
      @Bits, TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
  finally
    if OldPal <> 0 then
      SelectPalette(DC, OldPal, False);
    DeleteDC(DC);
  end;
end;

function DIBFromBit(Src: HBITMAP; Pal: HPALETTE; PixelFormat: TPixelFormat;
  var Length: Longint): Pointer;
var
  HeaderSize: Integer;
  ImageSize: Longint;
  FileHeader: PBitmapFileHeader;
  BI: PBitmapInfoHeader;
  Bits: Pointer;
begin
  if Src = 0 then
    InvalidBitmap;
  InternalGetDIBSizes(Src, HeaderSize, ImageSize, PixelFormat);
  Length := SizeOf(TBitmapFileHeader) + HeaderSize + ImageSize;
  Result := AllocMemo(Length);
  try
    FillChar(Result^, Length, 0);
    FileHeader := Result;
    with FileHeader^ do
    begin
      bfType := $4D42;
      bfSize := Length;
      bfOffBits := SizeOf(FileHeader^) + HeaderSize;
    end;
    BI := PBitmapInfoHeader(Longint(FileHeader) + SizeOf(FileHeader^));
    Bits := Pointer(Longint(BI) + HeaderSize);
    InternalGetDIB(Src, Pal, BI^, Bits^, PixelFormat);
  except
    FreeMemo(Result);
    raise;
  end;
end;

const
  MAX_COLORS = 4096;

type
  TTriple = array[0..2] of Byte;

  PQColor = ^TQColor;
  TQColor = record
    RGB: TTriple;
    NewColorIndex: Byte;
    Count: Longint;
    PNext: PQColor;
  end;

  PQColorArray = ^TQColorArray;
  TQColorArray = array[0..MAX_COLORS - 1] of TQColor;

  PQColorList = ^TQColorList;
  TQColorList = array[0..MaxListSize - 1] of PQColor;

  PNewColor = ^TNewColor;
  TNewColor = record
    RGBMin: TTriple;
    RGBWidth: TTriple;
    NumEntries: Longint;
    Count: Longint;
    QuantizedColors: PQColor;
  end;

  PNewColorArray = ^TNewColorArray;
  TNewColorArray = array[Byte] of TNewColor;


procedure PInsert(ColorList: PQColorList; Number: Integer; SortRGBAxis: Integer);
var
  Q1, Q2: PQColor;
  I, J: Integer;
  Temp: PQColor;
begin
  for I := 1 to Number - 1 do
  begin
    Temp := ColorList^[I];
    J := I - 1;
    while J >= 0 do
    begin
      Q1 := Temp;
      Q2 := ColorList^[J];
      if Q1^.RGB[SortRGBAxis] - Q2^.RGB[SortRGBAxis] > 0 then
        Break;
      ColorList^[J + 1] := ColorList^[J];
      Dec(J);
    end;
    ColorList^[J + 1] := Temp;
  end;
end;

procedure PSort(ColorList: PQColorList; Number: Integer; SortRGBAxis: Integer);
var
  Q1, Q2: PQColor;
  I, J, N, Nr: Integer;
  Temp, Part: PQColor;
begin
  if Number < 8 then
  begin
    PInsert(ColorList, Number, SortRGBAxis);
    Exit;
  end;
  Part := ColorList^[Number div 2];
  I := -1;
  J := Number;
  repeat
    repeat
      Inc(I);
      Q1 := ColorList^[I];
      Q2 := Part;
      N := Q1^.RGB[SortRGBAxis] - Q2^.RGB[SortRGBAxis];
    until N >= 0;
    repeat
      Dec(J);
      Q1 := ColorList^[J];
      Q2 := Part;
      N := Q1^.RGB[SortRGBAxis] - Q2^.RGB[SortRGBAxis];
    until N <= 0;
    if I >= J then
      Break;
    Temp := ColorList^[I];
    ColorList^[I] := ColorList^[J];
    ColorList^[J] := Temp;
  until False;
  Nr := Number - I;
  if I < Number div 2 then
  begin
    PSort(ColorList, I, SortRGBAxis);
    PSort(PQColorList(@ColorList^[I]), Nr, SortRGBAxis);
  end
  else
  begin
    PSort(PQColorList(@ColorList^[I]), Nr, SortRGBAxis);
    PSort(ColorList, I, SortRGBAxis);
  end;
end;

function DivideMap(NewColorSubdiv: PNewColorArray; ColorMapSize: Integer;
  var NewColormapSize: Integer; LPSTR: Pointer): Integer;
var
  I, J: Integer;
  MaxSize, Index: Integer;
  NumEntries, MinColor, MaxColor: Integer;
  Sum, Count: Longint;
  QuantizedColor: PQColor;
  SortArray: PQColorList;
  SortRGBAxis: Integer;
begin
  Index := 0;
  SortRGBAxis := 0;
  while ColorMapSize > NewColormapSize do
  begin
    MaxSize := -1;
    for I := 0 to NewColormapSize - 1 do
    begin
      for J := 0 to 2 do
      begin
        if (NewColorSubdiv^[I].RGBWidth[J] > MaxSize) and
          (NewColorSubdiv^[I].NumEntries > 1) then
        begin
          MaxSize := NewColorSubdiv^[I].RGBWidth[J];
          Index := I;
          SortRGBAxis := J;
        end;
      end;
    end;
    if MaxSize = -1 then
    begin
      Result := 1;
      Exit;
    end;
    SortArray := PQColorList(LPSTR);
    J := 0;
    QuantizedColor := NewColorSubdiv^[Index].QuantizedColors;
    while (J < NewColorSubdiv^[Index].NumEntries) and
      (QuantizedColor <> nil) do
    begin
      SortArray^[J] := QuantizedColor;
      Inc(J);
      QuantizedColor := QuantizedColor^.PNext;
    end;
    PSort(SortArray, NewColorSubdiv^[Index].NumEntries, SortRGBAxis);
    for J := 0 to NewColorSubdiv^[Index].NumEntries - 2 do
      SortArray^[J]^.PNext := SortArray^[J + 1];
    SortArray^[NewColorSubdiv^[Index].NumEntries - 1]^.PNext := nil;
    NewColorSubdiv^[Index].QuantizedColors := SortArray^[0];
    QuantizedColor := SortArray^[0];
    Sum := NewColorSubdiv^[Index].Count div 2 - QuantizedColor^.Count;
    NumEntries := 1;
    Count := QuantizedColor^.Count;
    Dec(Sum, QuantizedColor^.PNext^.Count);
    while (Sum >= 0) and (QuantizedColor^.PNext <> nil) and
      (QuantizedColor^.PNext^.PNext <> nil) do
    begin
      QuantizedColor := QuantizedColor^.PNext;
      Inc(NumEntries);
      Inc(Count, QuantizedColor^.Count);
      Dec(Sum, QuantizedColor^.PNext^.Count);
    end;
    MaxColor := (QuantizedColor^.RGB[SortRGBAxis]) shl 4;
    MinColor := (QuantizedColor^.PNext^.RGB[SortRGBAxis]) shl 4;
    NewColorSubdiv^[NewColormapSize].QuantizedColors := QuantizedColor^.PNext;
    QuantizedColor^.PNext := nil;
    NewColorSubdiv^[NewColormapSize].Count := Count;
    Dec(NewColorSubdiv^[Index].Count, Count);
    NewColorSubdiv^[NewColormapSize].NumEntries :=
      NewColorSubdiv^[Index].NumEntries - NumEntries;
    NewColorSubdiv^[Index].NumEntries := NumEntries;
    for J := 0 to 2 do
    begin
      NewColorSubdiv^[NewColormapSize].RGBMin[J] :=
        NewColorSubdiv^[Index].RGBMin[J];
      NewColorSubdiv^[NewColormapSize].RGBWidth[J] :=
        NewColorSubdiv^[Index].RGBWidth[J];
    end;
    NewColorSubdiv^[NewColormapSize].RGBWidth[SortRGBAxis] :=
      NewColorSubdiv^[NewColormapSize].RGBMin[SortRGBAxis] +
      NewColorSubdiv^[NewColormapSize].RGBWidth[SortRGBAxis] -
      MinColor;
    NewColorSubdiv^[NewColormapSize].RGBMin[SortRGBAxis] := MinColor;
    NewColorSubdiv^[Index].RGBWidth[SortRGBAxis] :=
      MaxColor - NewColorSubdiv^[Index].RGBMin[SortRGBAxis];
    Inc(NewColormapSize);
  end;
  Result := 1;
end;

function Quantize(const Bmp: TBitmapInfoHeader; gptr, Data8: Pointer;
  var ColorCount: Integer; var OutputColormap: TRGBPalette): Integer;
type
  PWord = ^Word;
var
  P: PByteArray;
  LineBuffer, Data: Pointer;
  LineWidth: Longint;
  TmpLineWidth, NewLineWidth: Longint;
  I, J: Longint;
  Index: Word;
  NewColormapSize, NumOfEntries: Integer;
  Mems: Longint;
  cRed, cGreen, cBlue: Longint;
  LPSTR, Temp, Tmp: Pointer;
  NewColorSubdiv: PNewColorArray;
  ColorArrayEntries: PQColorArray;
  QuantizedColor: PQColor;
begin
  LineWidth := WidthBytes(Longint(Bmp.biWidth) * Bmp.biBitCount);
  Mems := (Longint(SizeOf(TQColor)) * (MAX_COLORS)) +
    (Longint(SizeOf(TNewColor)) * 256) + LineWidth +
    (Longint(SizeOf(PQColor)) * (MAX_COLORS));
  LPSTR := AllocMemo(Mems);
  try
    Temp := AllocMemo(Longint(Bmp.biWidth) * Longint(Bmp.biHeight) *
      SizeOf(Word));
    try
      ColorArrayEntries := PQColorArray(LPSTR);
      NewColorSubdiv := PNewColorArray(HugeOffset(LPSTR,
        Longint(SizeOf(TQColor)) * (MAX_COLORS)));
      LineBuffer := HugeOffset(LPSTR, (Longint(SizeOf(TQColor)) * (MAX_COLORS))
        +
        (Longint(SizeOf(TNewColor)) * 256));
      for I := 0 to MAX_COLORS - 1 do
      begin
        ColorArrayEntries^[I].RGB[0] := I shr 8;
        ColorArrayEntries^[I].RGB[1] := (I shr 4) and $0F;
        ColorArrayEntries^[I].RGB[2] := I and $0F;
        ColorArrayEntries^[I].Count := 0;
      end;
      Tmp := Temp;
      for I := 0 to Bmp.biHeight - 1 do
      begin
        HMemCpy(LineBuffer, HugeOffset(gptr, (Bmp.biHeight - 1 - I) *
          LineWidth), LineWidth);
        P := LineBuffer;
        for J := 0 to Bmp.biWidth - 1 do
        begin
          Index := (Longint(P^[2] and $F0) shl 4) +
            Longint(P^[1] and $F0) + (Longint(P^[0] and $F0) shr 4);
          Inc(ColorArrayEntries^[Index].Count);
          P := HugeOffset(P, 3);
          PWord(Tmp)^ := Index;
          Tmp := HugeOffset(Tmp, 2);
        end;
      end;
      for I := 0 to 255 do
      begin
        NewColorSubdiv^[I].QuantizedColors := nil;
        NewColorSubdiv^[I].Count := 0;
        NewColorSubdiv^[I].NumEntries := 0;
        for J := 0 to 2 do
        begin
          NewColorSubdiv^[I].RGBMin[J] := 0;
          NewColorSubdiv^[I].RGBWidth[J] := 255;
        end;
      end;
      I := 0;
      while I < MAX_COLORS do
      begin
        if ColorArrayEntries^[I].Count > 0 then
          Break;
        Inc(I);
      end;
      QuantizedColor := @ColorArrayEntries^[I];
      NewColorSubdiv^[0].QuantizedColors := @ColorArrayEntries^[I];
      NumOfEntries := 1;
      Inc(I);
      while I < MAX_COLORS do
      begin
        if ColorArrayEntries^[I].Count > 0 then
        begin
          QuantizedColor^.PNext := @ColorArrayEntries^[I];
          QuantizedColor := @ColorArrayEntries^[I];
          Inc(NumOfEntries);
        end;
        Inc(I);
      end;
      QuantizedColor^.PNext := nil;
      NewColorSubdiv^[0].NumEntries := NumOfEntries;
      NewColorSubdiv^[0].Count := Longint(Bmp.biWidth) * Longint(Bmp.biHeight);
      NewColormapSize := 1;
      DivideMap(NewColorSubdiv, ColorCount, NewColormapSize,
        HugeOffset(LPSTR, Longint(SizeOf(TQColor)) * (MAX_COLORS) +
        Longint(SizeOf(TNewColor)) * 256 + LineWidth));
      if NewColormapSize < ColorCount then
      begin
        for I := NewColormapSize to ColorCount - 1 do
          FillChar(OutputColormap[I], SizeOf(TRGBQuad), 0);
      end;
      for I := 0 to NewColormapSize - 1 do
      begin
        J := NewColorSubdiv^[I].NumEntries;
        if J > 0 then
        begin
          QuantizedColor := NewColorSubdiv^[I].QuantizedColors;
          cRed := 0;
          cGreen := 0;
          cBlue := 0;
          while QuantizedColor <> nil do
          begin
            QuantizedColor^.NewColorIndex := I;
            Inc(cRed, QuantizedColor^.RGB[0]);
            Inc(cGreen, QuantizedColor^.RGB[1]);
            Inc(cBlue, QuantizedColor^.RGB[2]);
            QuantizedColor := QuantizedColor^.PNext;
          end;
          with OutputColormap[I] do
          begin
            rgbRed := (Longint(cRed shl 4) or $0F) div J;
            rgbGreen := (Longint(cGreen shl 4) or $0F) div J;
            rgbBlue := (Longint(cBlue shl 4) or $0F) div J;
            rgbReserved := 0;
            if (rgbRed <= $10) and (rgbGreen <= $10) and (rgbBlue <= $10) then
              FillChar(OutputColormap[I], SizeOf(TRGBQuad), 0); { clBlack }
          end;
        end;
      end;
      TmpLineWidth := Longint(Bmp.biWidth) * SizeOf(Word);
      NewLineWidth := WidthBytes(Longint(Bmp.biWidth) * 8);
      FillChar(Data8^, NewLineWidth * Bmp.biHeight, #0);
      for I := 0 to Bmp.biHeight - 1 do
      begin
        LineBuffer := HugeOffset(Temp, (Bmp.biHeight - 1 - I) * TmpLineWidth);
        Data := HugeOffset(Data8, I * NewLineWidth);
        for J := 0 to Bmp.biWidth - 1 do
        begin
          PByte(Data)^ := ColorArrayEntries^[PWord(LineBuffer)^].NewColorIndex;
          LineBuffer := HugeOffset(LineBuffer, 2);
          Data := HugeOffset(Data, 1);
        end;
      end;
    finally
      FreeMemo(Temp);
    end;
  finally
    FreeMemo(LPSTR);
  end;
  ColorCount := NewColormapSize;
  Result := 0;
end;

type
  TTruncLine = procedure(Src, Dest: Pointer; CX: Integer);

  { For 6Rx6Gx6B, 7Rx8Gx4B palettes etc. }

const
  Scale04: array[0..3] of Byte = (0, 85, 170, 255);
  Scale06: array[0..5] of Byte = (0, 51, 102, 153, 204, 255);
  Scale07: array[0..6] of Byte = (0, 43, 85, 128, 170, 213, 255);
  Scale08: array[0..7] of Byte = (0, 36, 73, 109, 146, 182, 219, 255);

  { For 6Rx6Gx6B, 7Rx8Gx4B palettes etc. }

var
  TruncTablesInitialized: Boolean = False;
  TruncIndex04: array[Byte] of Byte;
  TruncIndex06: array[Byte] of Byte;
  TruncIndex07: array[Byte] of Byte;
  TruncIndex08: array[Byte] of Byte;

  { These functions initialises this module }

procedure InitTruncTables;

  function NearestIndex(Value: Byte; const Bytes: array of Byte): Byte;
  var
    B, I: Byte;
    Diff, DiffMin: Word;
  begin
    Result := 0;
    B := Bytes[0];
    DiffMin := Abs(Value - B);
    for I := 1 to High(Bytes) do
    begin
      B := Bytes[I];
      Diff := Abs(Value - B);
      if Diff < DiffMin then
      begin
        DiffMin := Diff;
        Result := I;
      end;
    end;
  end;

var
  I: Integer;
begin
  if not TruncTablesInitialized then
  begin
    TruncTablesInitialized := True;
    // (rom) secured because it is called in initialization section
    // (ahuser) moved from initialization section to "on demand" initialization
    try
      { For 7 Red X 8 Green X 4 Blue palettes etc. }
      for I := 0 to 255 do
      begin
        TruncIndex04[I] := NearestIndex(Byte(I), Scale04);
        TruncIndex06[I] := NearestIndex(Byte(I), Scale06);
        TruncIndex07[I] := NearestIndex(Byte(I), Scale07);
        TruncIndex08[I] := NearestIndex(Byte(I), Scale08);
      end;
    except
    end;
  end;
end;

procedure Trunc(const Header: TBitmapInfoHeader; Src, Dest: Pointer;
  DstBitsPerPixel: Integer; TruncLineProc: TTruncLine);
var
  SrcScanline, DstScanline: Longint;
  Y: Integer;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := ((Header.biWidth * DstBitsPerPixel + 31) div 32) * 4;
  for Y := 0 to Header.biHeight - 1 do
    TruncLineProc(HugeOffset(Src, Y * SrcScanline),
      HugeOffset(Dest, Y * DstScanline), Header.biWidth);
end;

{ return 6Rx6Gx6B palette
  This function makes the palette for the 6 red X 6 green X 6 blue palette.
  216 palette entrys used. Remaining 40 Left blank.
}

procedure TruncPal6R6G6B(var Colors: TRGBPalette);
var
  I, R, G, B: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), $80);
  I := 0;
  for R := 0 to 5 do
    for G := 0 to 5 do
      for B := 0 to 5 do
      begin
        Colors[I].rgbRed := Scale06[R];
        Colors[I].rgbGreen := Scale06[G];
        Colors[I].rgbBlue := Scale06[B];
        Colors[I].rgbReserved := 0;
        Inc(I);
      end;
end;

{ truncate to 6Rx6Gx6B one line }

procedure TruncLine6R6G6B(Src, Dest: Pointer; CX: Integer);
var
  X: Integer;
  R, G, B: Byte;
begin
  InitTruncTables;
  for X := 0 to CX - 1 do
  begin
    B := TruncIndex06[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    G := TruncIndex06[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    R := TruncIndex06[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    PByte(Dest)^ := 6 * (6 * R + G) + B;
    Dest := HugeOffset(Dest, 1);
  end;
end;

{ truncate to 6Rx6Gx6B }

procedure Trunc6R6G6B(const Header: TBitmapInfoHeader;
  const Data24, Data8: Pointer);
begin
  Trunc(Header, Data24, Data8, 8, TruncLine6R6G6B);
end;

{ return 7Rx8Gx4B palette
  This function makes the palette for the 7 red X 8 green X 4 blue palette.
  224 palette entrys used. Remaining 32 Left blank.
  Colours calculated to match those used by 8514/A PM driver.
}

procedure TruncPal7R8G4B(var Colors: TRGBPalette);
var
  I, R, G, B: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), $80);
  I := 0;
  for R := 0 to 6 do
    for G := 0 to 7 do
      for B := 0 to 3 do
      begin
        Colors[I].rgbRed := Scale07[R];
        Colors[I].rgbGreen := Scale08[G];
        Colors[I].rgbBlue := Scale04[B];
        Colors[I].rgbReserved := 0;
        Inc(I);
      end;
end;

{ truncate to 7Rx8Gx4B one line }

procedure TruncLine7R8G4B(Src, Dest: Pointer; CX: Integer);
var
  X: Integer;
  R, G, B: Byte;
begin
  InitTruncTables;
  for X := 0 to CX - 1 do
  begin
    B := TruncIndex04[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    G := TruncIndex08[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    R := TruncIndex07[Byte(Src^)];
    Src := HugeOffset(Src, 1);
    PByte(Dest)^ := 4 * (8 * R + G) + B;
    Dest := HugeOffset(Dest, 1);
  end;
end;

{ truncate to 7Rx8Gx4B }

procedure Trunc7R8G4B(const Header: TBitmapInfoHeader;
  const Data24, Data8: Pointer);
begin
  Trunc(Header, Data24, Data8, 8, TruncLine7R8G4B);
end;

{ Grayscale support }

procedure GrayPal(var Colors: TRGBPalette);
var
  I: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), 0);
  for I := 0 to 255 do
    FillChar(Colors[I], 3, I);
end;

procedure GrayScale(const Header: TBitmapInfoHeader; Data24, Data8: Pointer);
var
  SrcScanline, DstScanline: Longint;
  Y, X: Integer;
  Src, Dest: PByte;
  R, G, B: Byte;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := (Header.biWidth + 3) and not 3;
  for Y := 0 to Header.biHeight - 1 do
  begin
    Src := Data24;
    Dest := Data8;
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Src^;
      Src := HugeOffset(Src, 1);
      G := Src^;
      Src := HugeOffset(Src, 1);
      R := Src^;
      Src := HugeOffset(Src, 1);
      Dest^ := Byte(Longint(Word(R) * 77 + Word(G) * 150 + Word(B) * 29) shr 8);
      Dest := HugeOffset(Dest, 1);
    end;
    Data24 := HugeOffset(Data24, SrcScanline);
    Data8 := HugeOffset(Data8, DstScanline);
  end;
end;

{ Tripel conversion }

procedure TripelPal(var Colors: TRGBPalette);
var
  I: Byte;
begin
  FillChar(Colors, SizeOf(TRGBPalette), 0);
  for I := 0 to $40 do
  begin
    Colors[I].rgbRed := I shl 2;
    Colors[I + $40].rgbGreen := I shl 2;
    Colors[I + $80].rgbBlue := I shl 2;
  end;
end;

procedure Tripel(const Header: TBitmapInfoHeader; Data24, Data8: Pointer);
var
  SrcScanline, DstScanline: Longint;
  Y, X: Integer;
  Src, Dest: PByte;
  R, G, B: Byte;
begin
  SrcScanline := (Header.biWidth * 3 + 3) and not 3;
  DstScanline := (Header.biWidth + 3) and not 3;
  for Y := 0 to Header.biHeight - 1 do
  begin
    Src := Data24;
    Dest := Data8;
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Src^;
      Src := HugeOffset(Src, 1);
      G := Src^;
      Src := HugeOffset(Src, 1);
      R := Src^;
      Src := HugeOffset(Src, 1);
      case ((X + Y) mod 3) of
        0: Dest^ := Byte(R shr 2);
        1: Dest^ := Byte($40 + (G shr 2));
        2: Dest^ := Byte($80 + (B shr 2));
      end;
      Dest := HugeOffset(Dest, 1);
    end;
    Data24 := HugeOffset(Data24, SrcScanline);
    Data8 := HugeOffset(Data8, DstScanline);
  end;
end;

{ Histogram/Frequency-of-use method of color reduction }

const
  MAX_N_COLS = 2049;
  MAX_N_HASH = 5191;

function Hash(R, G, B: Byte): Word;
begin
  Result := Word(Longint(Longint(R + G) * Longint(G + B) * Longint(B + R)) mod MAX_N_HASH);
end;

type
  PFreqRecord = ^TFreqRecord;
  TFreqRecord = record
    B: Byte;
    G: Byte;
    R: Byte;
    Frequency: Longint;
    Nearest: Byte;
  end;

  PHist = ^THist;
  THist = record
    ColCount: Longint;
    Rm: Byte;
    Gm: Byte;
    BM: Byte;
    Freqs: array[0..MAX_N_COLS - 1] of TFreqRecord;
    HashTable: array[0..MAX_N_HASH - 1] of Word;
  end;

function CreateHistogram(R, G, B: Byte): PHist;
{ create empty histogram }
begin
  GetMem(Result, SizeOf(THist));
  with Result^ do
  begin
    Rm := R;
    Gm := G;
    BM := B;
    ColCount := 0;
  end;
  FillChar(Result^.HashTable, MAX_N_HASH * SizeOf(Word), 255);
end;

procedure ClearHistogram(var Hist: PHist; R, G, B: Byte);
begin
  with Hist^ do
  begin
    Rm := R;
    Gm := G;
    BM := B;
    ColCount := 0;
  end;
  FillChar(Hist^.HashTable, MAX_N_HASH * SizeOf(Word), 255);
end;

procedure DeleteHistogram(var Hist: PHist);
begin
  FreeMem(Hist, SizeOf(THist));
  Hist := nil;
end;

function AddToHistogram(var Hist: THist; const Header: TBitmapInfoHeader;
  Data24: Pointer): Boolean;
{ add bitmap data to histogram }
var
  Step24: Integer;
  HashColor, Index: Word;
  Rm, Gm, BM, R, G, B: Byte;
  X, Y, ColCount: Longint;
begin
  Step24 := ((Header.biWidth * 3 + 3) and not 3) - Header.biWidth * 3;
  Rm := Hist.Rm;
  Gm := Hist.Gm;
  BM := Hist.BM;
  ColCount := Hist.ColCount;
  for Y := 0 to Header.biHeight - 1 do
  begin
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Byte(Data24^) and BM;
      Data24 := HugeOffset(Data24, 1);
      G := Byte(Data24^) and Gm;
      Data24 := HugeOffset(Data24, 1);
      R := Byte(Data24^) and Rm;
      Data24 := HugeOffset(Data24, 1);
      HashColor := Hash(R, G, B);
      repeat
        Index := Hist.HashTable[HashColor];
        if (Index = $FFFF) or ((Hist.Freqs[Index].R = R) and
          (Hist.Freqs[Index].G = G) and (Hist.Freqs[Index].B = B)) then
          Break;
        Inc(HashColor);
        if HashColor = MAX_N_HASH then
          HashColor := 0;
      until False;
      { Note: loop will always be broken out of }
      { We don't allow HashTable to fill up above half full }
      if Index = $FFFF then
      begin
        { Not found in Hash table }
        if ColCount = MAX_N_COLS then
        begin
          Result := False;
          Exit;
        end;
        Hist.Freqs[ColCount].Frequency := 1;
        Hist.Freqs[ColCount].B := B;
        Hist.Freqs[ColCount].G := G;
        Hist.Freqs[ColCount].R := R;
        Hist.HashTable[HashColor] := ColCount;
        Inc(ColCount);
      end
      else
      begin
        { Found in Hash table, update index }
        Inc(Hist.Freqs[Index].Frequency);
      end;
    end;
    Data24 := HugeOffset(Data24, Step24);
  end;
  Hist.ColCount := ColCount;
  Result := True;
end;

procedure PalHistogram(var Hist: THist; var Colors: TRGBPalette;
  ColorsWanted: Integer);
{ work out a palette from Hist }
var
  I, J: Longint;
  MinDist, Dist: Longint;
  MaxJ, MinJ: Longint;
  DeltaB, DeltaG, DeltaR: Longint;
  MaxFreq: Longint;
begin
  I := 0;
  MaxJ := 0;
  MinJ := 0;
  { Now find the ColorsWanted most frequently used ones }
  while (I < ColorsWanted) and (I < Hist.ColCount) do
  begin
    MaxFreq := 0;
    for J := 0 to Hist.ColCount - 1 do
      if Hist.Freqs[J].Frequency > MaxFreq then
      begin
        MaxJ := J;
        MaxFreq := Hist.Freqs[J].Frequency;
      end;
    Hist.Freqs[MaxJ].Nearest := Byte(I);
    Hist.Freqs[MaxJ].Frequency := 0; { Prevent later use of Freqs[MaxJ] }
    Colors[I].rgbBlue := Hist.Freqs[MaxJ].B;
    Colors[I].rgbGreen := Hist.Freqs[MaxJ].G;
    Colors[I].rgbRed := Hist.Freqs[MaxJ].R;
    Colors[I].rgbReserved := 0;
    Inc(I);
  end;
  { Unused palette entries will be medium grey }
  while I <= 255 do
  begin
    Colors[I].rgbRed := $80;
    Colors[I].rgbGreen := $80;
    Colors[I].rgbBlue := $80;
    Colors[I].rgbReserved := 0;
    Inc(I);
  end;
  { For the rest, find the closest one in the first ColorsWanted }
  for I := 0 to Hist.ColCount - 1 do
  begin
    if Hist.Freqs[I].Frequency <> 0 then
    begin
      MinDist := 3 * 256 * 256;
      for J := 0 to ColorsWanted - 1 do
      begin
        DeltaB := Hist.Freqs[I].B - Colors[J].rgbBlue;
        DeltaG := Hist.Freqs[I].G - Colors[J].rgbGreen;
        DeltaR := Hist.Freqs[I].R - Colors[J].rgbRed;
        Dist := Longint(DeltaR * DeltaR) + Longint(DeltaG * DeltaG) +
          Longint(DeltaB * DeltaB);
        if Dist < MinDist then
        begin
          MinDist := Dist;
          MinJ := J;
        end;
      end;
      Hist.Freqs[I].Nearest := Byte(MinJ);
    end;
  end;
end;

procedure MapHistogram(var Hist: THist; const Header: TBitmapInfoHeader;
  Data24, Data8: Pointer);
{ map bitmap data to Hist palette }
var
  Step24: Integer;
  Step8: Integer;
  HashColor, Index: Longint;
  Rm, Gm, BM, R, G, B: Byte;
  X, Y: Longint;
begin
  Step24 := ((Header.biWidth * 3 + 3) and not 3) - Header.biWidth * 3;
  Step8 := ((Header.biWidth + 3) and not 3) - Header.biWidth;
  Rm := Hist.Rm;
  Gm := Hist.Gm;
  BM := Hist.BM;
  for Y := 0 to Header.biHeight - 1 do
  begin
    for X := 0 to Header.biWidth - 1 do
    begin
      B := Byte(Data24^) and BM;
      Data24 := HugeOffset(Data24, 1);
      G := Byte(Data24^) and Gm;
      Data24 := HugeOffset(Data24, 1);
      R := Byte(Data24^) and Rm;
      Data24 := HugeOffset(Data24, 1);
      HashColor := Hash(R, G, B);
      repeat
        Index := Hist.HashTable[HashColor];
        if (Hist.Freqs[Index].R = R) and (Hist.Freqs[Index].G = G) and
          (Hist.Freqs[Index].B = B) then
          Break;
        Inc(HashColor);
        if HashColor = MAX_N_HASH then
          HashColor := 0;
      until False;
      PByte(Data8)^ := Hist.Freqs[Index].Nearest;
      Data8 := HugeOffset(Data8, 1);
    end;
    Data24 := HugeOffset(Data24, Step24);
    Data8 := HugeOffset(Data8, Step8);
  end;
end;

procedure Histogram(const Header: TBitmapInfoHeader; var Colors: TRGBPalette;
  Data24, Data8: Pointer; ColorsWanted: Integer; Rm, Gm, BM: Byte);
{ map single bitmap to frequency optimised palette }
var
  Hist: PHist;
begin
  Hist := CreateHistogram(Rm, Gm, BM);
  try
    repeat
      if AddToHistogram(Hist^, Header, Data24) then
        Break
      else
      begin
        if Gm > Rm then
          Gm := Gm shl 1
        else
          if Rm > BM then
            Rm := Rm shl 1
          else
            BM := BM shl 1;
        ClearHistogram(Hist, Rm, Gm, BM);
      end;
    until False;
    { Above loop will always be exited as if masks get rough   }
    { enough, ultimately number of unique colours < MAX_N_COLS }
    PalHistogram(Hist^, Colors, ColorsWanted);
    MapHistogram(Hist^, Header, Data24, Data8);
  finally
    DeleteHistogram(Hist);
  end;
end;

{ Change bits per pixel in a General Bitmap }

function GetBitmapPixelFormat(Bitmap: TBitmap): TPixelFormat;
begin
  Result := Bitmap.PixelFormat;
end;

function BitmapToMemoryStream(Bitmap: TBitmap; PixelFormat: TPixelFormat;
  Method: TMappingMethod): TMemoryStream;
var
  FileHeader: PBitmapFileHeader;
  BI, NewBI: PBitmapInfoHeader;
  Bits: Pointer;
  NewPalette: PRGBPalette;
  NewHeaderSize: Integer;
  ImageSize, Length, Len: Longint;
  P, InitData: Pointer;
  ColorCount: Integer;
  SourceBitmapFormat: TPixelFormat;
begin
  Result := nil;
  if Bitmap.Handle = 0 then
    InvalidBitmap;
  SourceBitmapFormat := GetBitmapPixelFormat(Bitmap);
  if (SourceBitmapFormat = PixelFormat) and
    (Method <> mmGrayscale) then
  begin
    Result := TMemoryStream.Create;
    try
      Bitmap.SaveToStream(Result);
      Result.Position := 0;
    except
      Result.Free;
      raise;
    end;
    Exit;
  end;
  if not (PixelFormat in [pf1bit, pf4bit, pf8bit, pf24bit]) then
    raise EJVCLException.CreateRes(@RsEPixelFormatNotImplemented)
  else
    if PixelFormat in [pf1bit, pf4bit] then
    begin
      P := DIBFromBit(Bitmap.Handle, Bitmap.Palette, PixelFormat, Length);
      try
        Result := TMemoryStream.Create;
        try
          Result.Write(P^, Length);
          Result.Position := 0;
        except
          Result.Free;
          raise;
        end;
      finally
        FreeMemo(P);
      end;
      Exit;
    end;
  { pf8bit - expand to 24bit first }
  InitData := DIBFromBit(Bitmap.Handle, Bitmap.Palette, pf24bit, Len);
  try
    BI := PBitmapInfoHeader(Longint(InitData) + SizeOf(TBitmapFileHeader));
    if BI^.biBitCount <> 24 then
      raise EJVCLException.CreateRes(@RsEBitCountNotImplemented);
    Bits := Pointer(Longint(BI) + SizeOf(TBitmapInfoHeader));
    InternalGetDIBSizes(Bitmap.Handle, NewHeaderSize, ImageSize, PixelFormat);
    Length := SizeOf(TBitmapFileHeader) + NewHeaderSize;
    P := AllocMemo(Length);
    try
      FillChar(P^, Length, #0);
      NewBI := PBitmapInfoHeader(Longint(P) + SizeOf(TBitmapFileHeader));
      NewPalette := PRGBPalette(Longint(NewBI) + SizeOf(TBitmapInfoHeader));
      FileHeader := PBitmapFileHeader(P);
      InitializeBitmapInfoHeader(Bitmap.Handle, NewBI^, PixelFormat);
      case Method of
        mmQuantize:
          begin
            ColorCount := 256;
            Quantize(BI^, Bits, Bits, ColorCount, NewPalette^);
            NewBI^.biClrImportant := ColorCount;
          end;
        mmTrunc784:
          begin
            TruncPal7R8G4B(NewPalette^);
            Trunc7R8G4B(BI^, Bits, Bits);
            NewBI^.biClrImportant := 224;
          end;
        mmTrunc666:
          begin
            TruncPal6R6G6B(NewPalette^);
            Trunc6R6G6B(BI^, Bits, Bits);
            NewBI^.biClrImportant := 216;
          end;
        mmTripel:
          begin
            TripelPal(NewPalette^);
            Tripel(BI^, Bits, Bits);
          end;
        mmHistogram:
          begin
            Histogram(BI^, NewPalette^, Bits, Bits,
              PixelFormatToColors(PixelFormat), 255, 255, 255);
          end;
        mmGrayscale:
          begin
            GrayPal(NewPalette^);
            GrayScale(BI^, Bits, Bits);
          end;
      end;
      with FileHeader^ do
      begin
        bfType := $4D42;
        bfSize := Length;
        bfOffBits := SizeOf(FileHeader^) + NewHeaderSize;
      end;
      Result := TMemoryStream.Create;
      try
        Result.Write(P^, Length);
        if SourceBitmapFormat = pfDevice then
          Result.Write(Bits^, ImageSize)
        else
          Result.Write(Bits^, ImageSize div 3);
        Result.Position := 0;
      except
        Result.Free;
        raise;
      end;
    finally
      FreeMemo(P);
    end;
  finally
    FreeMemo(InitData);
  end;
end;

function BitmapToMemory(Bitmap: TBitmap; Colors: Integer): TStream;
var
  PixelFormat: TPixelFormat;
begin
  if Colors <= 2 then
    PixelFormat := pf1bit
  else
    if Colors <= 16 then
      PixelFormat := pf4bit
    else
      if Colors <= 256 then
        PixelFormat := pf8bit
      else
        PixelFormat := pf24bit;
  Result := BitmapToMemoryStream(Bitmap, PixelFormat, DefaultMappingMethod);
end;

procedure SaveBitmapToFile(const FileName: string; Bitmap: TBitmap;
  Colors: Integer);
var
  Memory: TStream;
begin
  if Bitmap.Monochrome then
    Colors := 2;
  Memory := BitmapToMemory(Bitmap, Colors);
  try
    TMemoryStream(Memory).SaveToFile(FileName);
  finally
    Memory.Free;
  end;
end;

procedure SetBitmapPixelFormat(Bitmap: TBitmap; PixelFormat: TPixelFormat;
  Method: TMappingMethod);
var
  M: TMemoryStream;
begin
  if (Bitmap.Handle = 0) or (GetBitmapPixelFormat(Bitmap) = PixelFormat) then
    Exit;
  M := BitmapToMemoryStream(Bitmap, PixelFormat, Method);
  try
    Bitmap.LoadFromStream(M);
  finally
    M.Free;
  end;
end;

procedure GrayscaleBitmap(Bitmap: TBitmap);
begin
  SetBitmapPixelFormat(Bitmap, pf8bit, mmGrayscale);
end;

procedure JvGif_Dummy;
begin
end;

procedure GifError(const Msg: string);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EInvalidGraphicOperation.Create(Msg)at ReturnAddr;
end;

{$IFDEF RANGECHECKS_ON}
{$RANGECHECKS ON}
{$ENDIF RANGECHECKS_ON}

//=== { TSharedImage } =======================================================

const
  GIFSignature = 'GIF';
  GIFVersionStr: array[TGIFVersion] of PChar = (#0#0#0, '87a', '89a');

function GIFVersionName(Version: TGIFVersion): string;
begin
  Result := StrPas(GIFVersionStr[Version]);
end;

const
  CODE_TABLE_SIZE = 4096;
  HASH_TABLE_SIZE = 17777;
  MAX_LOOP_COUNT = 30000;

  CHR_EXT_INTRODUCER = '!';
  CHR_IMAGE_SEPARATOR = ',';
  CHR_TRAILER = ';'; { indicates the end of the GIF Data stream }

  { Image descriptor bit masks }
  ID_LOCAL_COLOR_TABLE = $80; { set if a local color table follows }
  ID_INTERLACED = $40; { set if image is interlaced }
  ID_SORT = $20; { set if color table is sorted }
  ID_RESERVED = $0C; { reserved - must be set to $00 }
  ID_COLOR_TABLE_SIZE = $07; { Size of color table as above }

  { Logical screen descriptor packed field masks }
  LSD_GLOBAL_COLOR_TABLE = $80; { set if global color table follows L.S.D. }
  LSD_COLOR_RESOLUTION = $70; { Color resolution - 3 bits }
  LSD_SORT = $08; { set if global color table is sorted - 1 bit }
  LSD_COLOR_TABLE_SIZE = $07; { Size of global color table - 3 bits }
                                { Actual Size = 2^value+1    - value is 3 bits }

  { Graphic control extension packed field masks }
  GCE_TRANSPARENT = $01; { whether a transparency Index is given }
  GCE_USER_INPUT = $02; { whether or not user input is expected }
  GCE_DISPOSAL_METHOD = $1C; { the way in which the graphic is to be treated after being displayed }
  GCE_RESERVED = $E0; { reserved - must be set to $00 }

  { Application extension }
  AE_LOOPING = $01; { looping Netscape extension }

  GIFColors: array[TGIFBits] of Word = (2, 4, 8, 16, 32, 64, 128, 256);

function ColorsToBits(ColorCount: Word): Byte;
var
  I: TGIFBits;
begin
  Result := 0;
  for I := Low(TGIFBits) to High(TGIFBits) do
    if ColorCount = GIFColors[I] then
    begin
      Result := I;
      Exit;
    end;
  GifError(RsEWrongGIFColors);
end;

function ColorsToPixelFormat(Colors: Word): TPixelFormat;
begin
  if Colors <= 2 then
    Result := pf1bit
  else
    if Colors <= 16 then
      Result := pf4bit
    else
      if Colors <= 256 then
        Result := pf8bit
      else
        Result := pf24bit;
end;

function ItemToRGB(Item: TGIFColorItem): Longint;
begin
  with Item do
    Result := RGB(Red, Green, Blue);
end;

function GrayColor(Color: TColor): TColor;
var
  Index: Integer;
begin
  Index := Byte(Longint(Word(GetRValue(Color)) * 77 +
    Word(GetGValue(Color)) * 150 + Word(GetBValue(Color)) * 29) shr 8);
  Result := RGB(Index, Index, Index);
end;

procedure GrayColorTable(var ColorTable: TGIFColorTable);
var
  I: Byte;
  Index: Integer;
begin
  for I := 0 to ColorTable.Count - 1 do
  begin
    with ColorTable.Colors[I] do
    begin
      Index := Byte(Longint(Word(Red) * 77 + Word(Green) * 150 +
        Word(Blue) * 29) shr 8);
      Red := Index;
      Green := Index;
      Blue := Index;
    end;
  end;
end;

function FindColorIndex(const ColorTable: TGIFColorTable;
  Color: TColor): Integer;
begin
  if Color <> clNone then
    for Result := 0 to ColorTable.Count - 1 do
      if ItemToRGB(ColorTable.Colors[Result]) = ColorToRGB(Color) then
        Exit;
  Result := -1;
end;

{ The following types and function declarations are used to call into
  functions of the GIF implementation of the GIF image
  compression/decompression standard. }

type
  TGIFHeader = packed record
    Signature: array[0..2] of Char; { contains 'GIF' }
    Version: array[0..2] of Char; { '87a' or '89a' }
  end;

  TScreenDescriptor = packed record
    ScreenWidth: Word; { logical screen width }
    ScreenHeight: Word; { logical screen height }
    PackedFields: Byte;
    BackgroundColorIndex: Byte; { Index to global color table }
    AspectRatio: Byte; { actual ratio = (AspectRatio + 15) / 64 }
  end;

  TImageDescriptor = packed record
    ImageLeftPos: Word; { column in pixels in respect to left of logical screen }
    ImageTopPos: Word; { row in pixels in respect to top of logical screen }
    ImageWidth: Word; { width of image in pixels }
    ImageHeight: Word; { height of image in pixels }
    PackedFields: Byte;
  end;

{ GIF Extensions support }

type
  TExtensionType = (etGraphic, etPlainText, etApplication, etComment);

const
  ExtLabels: array[TExtensionType] of Byte = ($F9, $01, $FF, $FE);
  LoopExtNS: string[11] = 'NETSCAPE2.0';
  LoopExtAN: string[11] = 'ANIMEXTS1.0';

type
  TGraphicControlExtension = packed record
    BlockSize: Byte; { should be 4 }
    PackedFields: Byte;
    DelayTime: Word; { in centiseconds }
    TransparentColorIndex: Byte;
    Terminator: Byte;
  end;

  TPlainTextExtension = packed record
    BlockSize: Byte; { should be 12 }
    Left: Word;
    Top: Word;
    Width: Word;
    Height: Word;
    CellWidth: Byte;
    CellHeight: Byte;
    FGColorIndex: Byte;
    BGColorIndex: Byte;
  end;

  TAppExtension = packed record
    BlockSize: Byte; { should be 11 }
    AppId: array[1..8] of Byte;
    Authentication: array[1..3] of Byte;
  end;

  TExtensionRecord = packed record
    case ExtensionType: TExtensionType of
      etGraphic:
      (GCE: TGraphicControlExtension);
      etPlainText:
      (PTE: TPlainTextExtension);
      etApplication:
      (APPE: TAppExtension);
  end;

//=== { TExtension } =========================================================

type
  TExtension = class(TPersistent)
  private
    FExtType: TExtensionType;
    FData: TStringList;
    FExtRec: TExtensionRecord;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function IsLoopExtension: Boolean;
  end;

destructor TExtension.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

procedure TExtension.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TExtension) then
  begin
    FExtType := TExtension(Source).FExtType;
    FExtRec := TExtension(Source).FExtRec;
    if TExtension(Source).FData <> nil then
    begin
      if FData = nil then
        FData := TStringList.Create;
      FData.Assign(TExtension(Source).FData);
    end;
  end
  else
    inherited Assign(Source);
end;

function TExtension.IsLoopExtension: Boolean;
begin
  Result := (FExtType = etApplication) and (FData.Count > 0) and
    (CompareMem(@FExtRec.APPE.AppId, @LoopExtNS[1], FExtRec.APPE.BlockSize) or
    CompareMem(@FExtRec.APPE.AppId, @LoopExtAN[1], FExtRec.APPE.BlockSize)) and
    (Length(FData[0]) >= 3) and (Byte(FData[0][1]) = AE_LOOPING);
end;

procedure FreeExtensions(Extensions: TList); near;
begin
  if Extensions <> nil then
  begin
    while Extensions.Count > 0 do
    begin
      TObject(Extensions[0]).Free;
      Extensions.Delete(0);
    end;
    Extensions.Free;
  end;
end;

function FindExtension(Extensions: TList; ExtType: TExtensionType): TExtension;
var
  I: Integer;
begin
  if Extensions <> nil then
    for I := Extensions.Count - 1 downto 0 do
    begin
      Result := TExtension(Extensions[I]);
      if (Result <> nil) and (Result.FExtType = ExtType) then
        Exit;
    end;
  Result := nil;
end;

{
function CopyExtensions(Source: TList): TList; near;
var
  I: Integer;
  Ext: TExtension;
begin
  Result := TList.Create;
  try
    for I := 0 to Source.Count - 1 do
      if (Source[I] <> nil) and (TObject(Source[I]) is TExtension) then
      begin
        Ext := TExtension.Create;
        try
          Ext.Assign(Source[I]);
          Result.Add(Ext);
        except
          Ext.Free;
          raise;
        end;
      end;
  except
    Result.Free;
    raise;
  end;
end;
}

type
  TProgressProc = procedure(Stage: TProgressStage; PercentDone: Byte;
    const Msg: string) of object;

{ GIF reading/writing routines

  Procedures to read and write GIF files, GIF-decoding and encoding
  based on freeware C source code of GBM package by Andy Key
  (nyangau att interalpha dott co dott uk). The home page of GBM author is
  at http://www.interalpha.net/customer/nyangau/. }

type
  PIntCodeTable = ^TIntCodeTable;
  TIntCodeTable = array[0..CODE_TABLE_SIZE - 1] of Word;

  PReadContext = ^TReadContext;
  TReadContext = record
    Inx: Longint;
    Size: Longint;
    Buf: array[0..255 + 4] of Byte;
    CodeSize: Longint;
    ReadMask: Longint;
  end;

  PWriteContext = ^TWriteContext;
  TWriteContext = record
    Inx: Longint;
    CodeSize: Longint;
    Buf: array[0..255 + 4] of Byte;
  end;

  TOutputContext = record
    W: Longint;
    H: Longint;
    X: Longint;
    Y: Longint;
    BitsPerPixel: Integer;
    Pass: Integer;
    Interlace: Boolean;
    LineIdent: Longint;
    Data: Pointer;
    CurrLineData: Pointer;
  end;

  PImageDict = ^TImageDict;
  TImageDict = record
    Tail: Word;
    Index: Word;
    Col: Byte;
  end;

  PDictTable = ^TDictTable;
  TDictTable = array[0..CODE_TABLE_SIZE - 1] of TImageDict;

function InitHash(P: Longint): Longint;
begin
  Result := (P + 3) * 301;
end;

function InterlaceStep(Y, Height: Integer; var Pass: Integer): Integer;
begin
  Result := Y;
  case Pass of
    0, 1:
      Inc(Result, 8);
    2:
      Inc(Result, 4);
    3:
      Inc(Result, 2);
  end;
  if Result >= Height then
  begin
    if Pass = 0 then
    begin
      Pass := 1;
      Result := 4;
      if Result < Height then
        Exit;
    end;
    if Pass = 1 then
    begin
      Pass := 2;
      Result := 2;
      if Result < Height then
        Exit;
    end;
    if Pass = 2 then
    begin
      Pass := 3;
      Result := 1;
    end;
  end;
end;

procedure ReadImageStream(Stream, Dest: TStream; var Desc: TImageDescriptor;
  var Interlaced, LocalColors, Corrupted: Boolean; var BitsPerPixel: Byte;
  var ColorTable: TGIFColorTable);
var
  CodeSize, BlockSize: Byte;
begin
  Corrupted := False;
  Stream.ReadBuffer(Desc, SizeOf(TImageDescriptor));
  Interlaced := (Desc.PackedFields and ID_INTERLACED) <> 0;
  if (Desc.PackedFields and ID_LOCAL_COLOR_TABLE) <> 0 then
  begin
    { Local colors table follows }
    BitsPerPixel := 1 + Desc.PackedFields and ID_COLOR_TABLE_SIZE;
    LocalColors := True;
    ColorTable.Count := 1 shl BitsPerPixel;
    Stream.ReadBuffer(ColorTable.Colors[0],
      ColorTable.Count * SizeOf(TGIFColorItem));
  end
  else
  begin
    LocalColors := False;
    FillChar(ColorTable, SizeOf(ColorTable), 0);
  end;
  Stream.ReadBuffer(CodeSize, 1);
  Dest.Write(CodeSize, 1);
  repeat
    Stream.Read(BlockSize, 1);
    if (Stream.Position + BlockSize) > Stream.Size then
    begin
      Corrupted := True;
      Stream.Position := Stream.Size;
      Exit;
    end;
    Dest.Write(BlockSize, 1);
    if (Stream.Position + BlockSize) > Stream.Size then
    begin
      BlockSize := Stream.Size - Stream.Position;
      Corrupted := True;
    end;
    if BlockSize > 0 then
      Dest.CopyFrom(Stream, BlockSize);
  until (BlockSize = 0) or (Stream.Position >= Stream.Size);
end;

procedure FillRGBPalette(const ColorTable: TGIFColorTable;
  var Colors: TRGBPalette);
var
  I: Byte;
begin
  FillChar(Colors, SizeOf(Colors), $80);
  for I := 0 to ColorTable.Count - 1 do
  begin
    Colors[I].rgbRed := ColorTable.Colors[I].Red;
    Colors[I].rgbGreen := ColorTable.Colors[I].Green;
    Colors[I].rgbBlue := ColorTable.Colors[I].Blue;
    Colors[I].rgbReserved := 0;
  end;
end;

function ReadCode(Stream: TStream; var Context: TReadContext): Longint;
var
  RawCode: Longint;
  ByteIndex: Longint;
  Bytes: Byte;
  BytesToLose: Longint;
begin
  while (Context.Inx + Context.CodeSize > Context.Size) and
    (Stream.Position < Stream.Size) do
  begin
    { not enough bits in buffer - refill it }
    { Not very efficient, but infrequently called }
    BytesToLose := Context.Inx shr 3;
    { Note biggest Code Size is 12 bits. And this can at worst span 3 Bytes }
    Move(Context.Buf[Word(BytesToLose)], Context.Buf[0], 3);
    Context.Inx := Context.Inx and 7;
    Context.Size := Context.Size - (BytesToLose shl 3);
    Stream.ReadBuffer(Bytes, 1);
    if Bytes > 0 then
      Stream.ReadBuffer(Context.Buf[Word(Context.Size shr 3)], Bytes);
    Context.Size := Context.Size + (Bytes shl 3);
  end;
  ByteIndex := Context.Inx shr 3;
  RawCode := Context.Buf[Word(ByteIndex)] +
    (Word(Context.Buf[Word(ByteIndex + 1)]) shl 8);
  if Context.CodeSize > 8 then
    RawCode := RawCode + (Longint(Context.Buf[ByteIndex + 2]) shl 16);
  RawCode := RawCode shr (Context.Inx and 7);
  Context.Inx := Context.Inx + Byte(Context.CodeSize);
  Result := RawCode and Context.ReadMask;
end;

procedure Output(Value: Byte; var Context: TOutputContext);
var
  P: PByte;
begin
  if Context.Y >= Context.H then
    Exit;
  case Context.BitsPerPixel of
    1:
      begin
        P := HugeOffset(Context.CurrLineData, Context.X shr 3);
        if (Context.X and $07) <> 0 then
          P^ := P^ or Word(Value shl (7 - (Word(Context.X and 7))))
        else
          P^ := Byte(Value shl 7);
      end;
    4:
      begin
        P := HugeOffset(Context.CurrLineData, Context.X shr 1);
        if (Context.X and 1) <> 0 then
          P^ := P^ or Value
        else
          P^ := Byte(Value shl 4);
      end;
    8:
      begin
        P := HugeOffset(Context.CurrLineData, Context.X);
        P^ := Value;
      end;
  end;
  Inc(Context.X);
  if Context.X < Context.W then
    Exit;
  Context.X := 0;
  if Context.Interlace then
    Context.Y := InterlaceStep(Context.Y, Context.H, Context.Pass)
  else
    Inc(Context.Y);
  Context.CurrLineData := HugeOffset(Context.Data,
    (Context.H - 1 - Context.Y) * Context.LineIdent);
end;

procedure ReadGIFData(Stream: TStream; const Header: TBitmapInfoHeader;
  Interlaced, LoadCorrupt: Boolean; IntBitPerPixel: Byte; Data: Pointer;
  var Corrupted: Boolean; ProgressProc: TProgressProc);
var
  MinCodeSize, Temp: Byte;
  MaxCode, BitMask, InitCodeSize: Longint;
  ClearCode, EndingCode, FirstFreeCode, FreeCode: Word;
  I, OutCount, Code: Longint;
  CurCode, OldCode, InCode, FinalChar: Word;
  Prefix, Suffix, OutCode: PIntCodeTable;
  ReadCtxt: TReadContext;
  OutCtxt: TOutputContext;
  TableFull: Boolean;
begin
  Corrupted := False;
  OutCount := 0;
  OldCode := 0;
  FinalChar := 0;
  TableFull := False;
  Prefix := AllocMem(SizeOf(TIntCodeTable));
  try
    Suffix := AllocMem(SizeOf(TIntCodeTable));
    try
      OutCode := AllocMem(SizeOf(TIntCodeTable) + SizeOf(Word));
      try
        if Assigned(ProgressProc) then
          ProgressProc(psStarting, 0, '');
        try
          Stream.ReadBuffer(MinCodeSize, 1);
          if (MinCodeSize < 2) or (MinCodeSize > 9) then
          begin
            if LoadCorrupt then
            begin
              Corrupted := True;
              MinCodeSize := Max(2, Min(MinCodeSize, 9));
            end
            else
              GifError(RsEBadGIFCodeSize);
          end;
          { Initial read context }
          ReadCtxt.Inx := 0;
          ReadCtxt.Size := 0;
          ReadCtxt.CodeSize := MinCodeSize + 1;
          ReadCtxt.ReadMask := (1 shl ReadCtxt.CodeSize) - 1;
          { Initialise pixel-output context }
          OutCtxt.X := 0;
          OutCtxt.Y := 0;
          OutCtxt.Pass := 0;
          OutCtxt.W := Header.biWidth;
          OutCtxt.H := Header.biHeight;
          OutCtxt.BitsPerPixel := Header.biBitCount;
          OutCtxt.Interlace := Interlaced;
          OutCtxt.LineIdent := ((Header.biWidth * Header.biBitCount + 31)
            div 32) * 4;
          OutCtxt.Data := Data;
          OutCtxt.CurrLineData := HugeOffset(Data, (Header.biHeight - 1) *
            OutCtxt.LineIdent);
          BitMask := (1 shl IntBitPerPixel) - 1;
          { 2 ^ MinCodeSize accounts for all colours in file }
          ClearCode := 1 shl MinCodeSize;
          EndingCode := ClearCode + 1;
          FreeCode := ClearCode + 2;
          FirstFreeCode := FreeCode;
          { 2^ (MinCodeSize + 1) includes clear and eoi Code and space too }
          InitCodeSize := ReadCtxt.CodeSize;
          MaxCode := 1 shl ReadCtxt.CodeSize;
          Code := ReadCode(Stream, ReadCtxt);
          while (Code <> EndingCode) and (Code <> $FFFF) and
            (OutCtxt.Y < OutCtxt.H) do
          begin
            if Code = ClearCode then
            begin
              ReadCtxt.CodeSize := InitCodeSize;
              MaxCode := 1 shl ReadCtxt.CodeSize;
              ReadCtxt.ReadMask := MaxCode - 1;
              FreeCode := FirstFreeCode;
              Code := ReadCode(Stream, ReadCtxt);
              CurCode := Code;
              OldCode := Code;
              if Code = $FFFF then
                Break;
              FinalChar := (CurCode and BitMask);
              Output(Byte(FinalChar), OutCtxt);
              TableFull := False;
            end
            else
            begin
              CurCode := Code;
              InCode := Code;
              if CurCode >= FreeCode then
              begin
                CurCode := OldCode;
                OutCode^[OutCount] := FinalChar;
                Inc(OutCount);
              end;
              while CurCode > BitMask do
              begin
                if OutCount > CODE_TABLE_SIZE then
                begin
                  if LoadCorrupt then
                  begin
                    CurCode := BitMask;
                    OutCount := 1;
                    Corrupted := True;
                    Break;
                  end
                  else
                    GifError(RsEGIFDecodeError);
                end;
                OutCode^[OutCount] := Suffix^[CurCode];
                Inc(OutCount);
                CurCode := Prefix^[CurCode];
              end;
              if Corrupted then
                Break;
              FinalChar := CurCode and BitMask;
              OutCode^[OutCount] := FinalChar;
              Inc(OutCount);
              for I := OutCount - 1 downto 0 do
                Output(Byte(OutCode^[I]), OutCtxt);
              OutCount := 0;
              { Update dictionary }
              if not TableFull then
              begin
                Prefix^[FreeCode] := OldCode;
                Suffix^[FreeCode] := FinalChar;
                { Advance to next free slot }
                Inc(FreeCode);
                if FreeCode >= MaxCode then
                begin
                  if ReadCtxt.CodeSize < 12 then
                  begin
                    Inc(ReadCtxt.CodeSize);
                    MaxCode := MaxCode shl 1;
                    ReadCtxt.ReadMask := (1 shl ReadCtxt.CodeSize) - 1;
                  end
                  else
                    TableFull := True;
                end;
              end;
              OldCode := InCode;
            end;
            Code := ReadCode(Stream, ReadCtxt);
            if Stream.Size > 0 then
            begin
              Temp := System.Trunc(100.0 * (Stream.Position / Stream.Size));
              if Assigned(ProgressProc) then
                ProgressProc(psRunning, Temp, '');
            end;
          end; { while }
          if Code = $FFFF then
            GifError('SReadError');
        finally
          if Assigned(ProgressProc) then
          begin
            if ExceptObject = nil then
              ProgressProc(psEnding, 100, '')
            else
              ProgressProc(psEnding, 0, Exception(ExceptObject).Message);
          end;
        end;
      finally
        FreeMem(OutCode, SizeOf(TIntCodeTable) + SizeOf(Word));
      end;
    finally
      FreeMem(Suffix, SizeOf(TIntCodeTable));
    end;
  finally
    FreeMem(Prefix, SizeOf(TIntCodeTable));
  end;
end;

procedure WriteCode(Stream: TStream; Code: Longint;
  var Context: TWriteContext);
var
  BufIndex: Longint;
  Bytes: Byte;
begin
  BufIndex := Context.Inx shr 3;
  Code := Code shl (Context.Inx and 7);
  Context.Buf[BufIndex] := Context.Buf[BufIndex] or Code;
  Context.Buf[BufIndex + 1] := (Code shr 8);
  Context.Buf[BufIndex + 2] := (Code shr 16);
  Context.Inx := Context.Inx + Context.CodeSize;
  if Context.Inx >= 255 * 8 then
  begin
    { Flush out full buffer }
    Bytes := 255;
    Stream.WriteBuffer(Bytes, 1);
    Stream.WriteBuffer(Context.Buf, Bytes);
    Move(Context.Buf[255], Context.Buf[0], 2);
    FillChar(Context.Buf[2], 255, 0);
    Context.Inx := Context.Inx - (255 * 8);
  end;
end;

procedure FlushCode(Stream: TStream; var Context: TWriteContext);
var
  Bytes: Byte;
begin
  Bytes := (Context.Inx + 7) shr 3;
  if Bytes > 0 then
  begin
    Stream.WriteBuffer(Bytes, 1);
    Stream.WriteBuffer(Context.Buf, Bytes);
  end;
  { Data block terminator - a block of zero Size }
  Bytes := 0;
  Stream.WriteBuffer(Bytes, 1);
end;

procedure FillColorTable(var ColorTable: TGIFColorTable;
  const Colors: TRGBPalette; Count: Integer);
var
  I: Byte;
begin
  FillChar(ColorTable, SizeOf(ColorTable), 0);
  ColorTable.Count := Min(256, Count);
  for I := 0 to ColorTable.Count - 1 do
  begin
    ColorTable.Colors[I].Red := Colors[I].rgbRed;
    ColorTable.Colors[I].Green := Colors[I].rgbGreen;
    ColorTable.Colors[I].Blue := Colors[I].rgbBlue;
  end;
end;

procedure WriteGIFData(Stream: TStream; var Header: TBitmapInfoHeader;
  Interlaced: Boolean; Data: Pointer; ProgressProc: TProgressProc);
  { LZW encode data }
var
  LineIdent: Longint;
  MinCodeSize, Col, Temp: Byte;
  InitCodeSize, X, Y: Longint;
  Pass: Integer;
  MaxCode: Longint; { 1 shl CodeSize }
  ClearCode, EndingCode, LastCode, Tail: Longint;
  I, HashValue: Longint;
  LenString: Word;
  Dict: PDictTable;
  HashTable: TList;
  PData: PByte;
  WriteCtxt: TWriteContext;
begin
  LineIdent := ((Header.biWidth * Header.biBitCount + 31) div 32) * 4;
  Tail := 0;
  HashValue := 0;
  Dict := AllocMem(SizeOf(TDictTable));
  try
    HashTable := TList.Create;
    try
      for I := 0 to HASH_TABLE_SIZE - 1 do
        HashTable.Add(nil);
      { Initialise encoder variables }
      InitCodeSize := Header.biBitCount + 1;
      if InitCodeSize = 2 then
        Inc(InitCodeSize);
      MinCodeSize := InitCodeSize - 1;
      Stream.WriteBuffer(MinCodeSize, 1);
      ClearCode := 1 shl MinCodeSize;
      EndingCode := ClearCode + 1;
      LastCode := EndingCode;
      MaxCode := 1 shl InitCodeSize;
      LenString := 0;
      { Setup write context }
      WriteCtxt.Inx := 0;
      WriteCtxt.CodeSize := InitCodeSize;
      FillChar(WriteCtxt.Buf, SizeOf(WriteCtxt.Buf), 0);
      WriteCode(Stream, ClearCode, WriteCtxt);
      for I := 0 to HASH_TABLE_SIZE - 1 do
        HashTable[I] := nil;
      Data := HugeOffset(Data, (Header.biHeight - 1) * LineIdent);
      Y := 0;
      Pass := 0;
      if Assigned(ProgressProc) then
        ProgressProc(psStarting, 0, '');
      try
        while Y < Header.biHeight do
        begin
          PData := HugeOffset(Data, -(Y * LineIdent));
          for X := 0 to Header.biWidth - 1 do
          begin
            case Header.biBitCount of
              8:
                begin
                  Col := PData^;
                  PData := HugeOffset(PData, 1);
                end;
              4:
                begin
                  if X and 1 <> 0 then
                  begin
                    Col := PData^ and $0F;
                    PData := HugeOffset(PData, 1);
                  end
                  else
                    Col := PData^ shr 4;
                end;
            else { must be 1 }
              begin
                if X and 7 = 7 then
                begin
                  Col := PData^ and 1;
                  PData := HugeOffset(PData, 1);
                end
                else
                  Col := (PData^ shr (7 - (X and $07))) and $01;
              end;
            end;
            Inc(LenString);
            if LenString = 1 then
            begin
              Tail := Col;
              HashValue := InitHash(Col);
            end
            else
            begin
              HashValue := HashValue * (Col + LenString + 4);
              I := HashValue mod HASH_TABLE_SIZE;
              HashValue := HashValue mod HASH_TABLE_SIZE;
              while (HashTable[I] <> nil) and
                ((PImageDict(HashTable[I])^.Tail <> Tail) or
                (PImageDict(HashTable[I])^.Col <> Col)) do
              begin
                Inc(I);
                if I >= HASH_TABLE_SIZE then
                  I := 0;
              end;
              if HashTable[I] <> nil then { Found in the strings table }
                Tail := PImageDict(HashTable[I])^.Index
              else
              begin
                { Not found }
                WriteCode(Stream, Tail, WriteCtxt);
                Inc(LastCode);
                HashTable[I] := @Dict^[LastCode];
                PImageDict(HashTable[I])^.Index := LastCode;
                PImageDict(HashTable[I])^.Tail := Tail;
                PImageDict(HashTable[I])^.Col := Col;
                Tail := Col;
                HashValue := InitHash(Col);
                LenString := 1;
                if LastCode >= MaxCode then
                begin
                  { Next Code will be written longer }
                  MaxCode := MaxCode shl 1;
                  Inc(WriteCtxt.CodeSize);
                end
                else
                  if LastCode >= CODE_TABLE_SIZE - 2 then
                  begin
                  { Reset tables }
                    WriteCode(Stream, Tail, WriteCtxt);
                    WriteCode(Stream, ClearCode, WriteCtxt);
                    LenString := 0;
                    LastCode := EndingCode;
                    WriteCtxt.CodeSize := InitCodeSize;
                    MaxCode := 1 shl InitCodeSize;
                    for I := 0 to HASH_TABLE_SIZE - 1 do
                      HashTable[I] := nil;
                  end;
              end;
            end;
          end; { for X loop }
          if Interlaced then
            Y := InterlaceStep(Y, Header.biHeight, Pass)
          else
            Inc(Y);
          Temp := System.Trunc(100.0 * (Y / Header.biHeight));
          if Assigned(ProgressProc) then
            ProgressProc(psRunning, Temp, '');
        end; { while Y loop }
        WriteCode(Stream, Tail, WriteCtxt);
        WriteCode(Stream, EndingCode, WriteCtxt);
        FlushCode(Stream, WriteCtxt);
      finally
        if Assigned(ProgressProc) then
        begin
          if ExceptObject = nil then
            ProgressProc(psEnding, 100, '')
          else
            ProgressProc(psEnding, 0, Exception(ExceptObject).Message);
        end;
      end;
    finally
      HashTable.Free;
    end;
  finally
    FreeMem(Dict, SizeOf(TDictTable));
  end;
end;

//=== { TGIFItem } ===========================================================

destructor TGIFItem.Destroy;
begin
  FImageData.Free;
  inherited Destroy;
end;

procedure TGIFItem.FreeHandle;
begin
  if FImageData <> nil then
    FImageData.SetSize(0);
end;

//=== { TGIFData } ===========================================================

constructor TGIFData.Create;
begin
  inherited Create;
  FComment := TStringList.Create;
end;

destructor TGIFData.Destroy;
begin
  FComment.Free;
  inherited Destroy;
end;

procedure TGIFData.FreeHandle;
begin
  if FComment <> nil then
    FComment.Clear;
end;

//=== { TJvGIFFrame } ========================================================

constructor TJvGIFFrame.Create(AOwner: TJvGIFImage);
begin
  FOwner := AOwner;
  inherited Create;
  NewImage;
end;

destructor TJvGIFFrame.Destroy;
begin
  FBitmap.Free;
  FreeExtensions(FExtensions);
  FImage.Release;
  inherited Destroy;
end;

procedure TJvGIFFrame.SetAnimateInterval(Value: Word);
begin
  if FAnimateInterval <> Value then
  begin
    FAnimateInterval := Value;
    if Value > 0 then
      FOwner.FVersion := gv89a;
    FOwner.Changed(FOwner);
  end;
end;

procedure TJvGIFFrame.SetDisposalMethod(Value: TDisposalMethod);
begin
  if FDisposal <> Value then
  begin
    FDisposal := Value;
    if Value <> dmUndefined then
      FOwner.FVersion := gv89a;
    FOwner.Changed(FOwner);
  end;
end;

procedure TJvGIFFrame.SetTopLeft(const Value: TPoint);
begin
  if (FTopLeft.X <> Value.X) or (FTopLeft.Y <> Value.Y) then
  begin
    FTopLeft.X := Value.X;
    FTopLeft.Y := Value.Y;
    FOwner.FScreenWidth := Max(FOwner.FScreenWidth,
      FImage.FSize.X + FTopLeft.X);
    FOwner.FScreenHeight := Max(FOwner.FScreenHeight,
      FImage.FSize.Y + FTopLeft.Y);
    FOwner.Changed(FOwner);
  end;
end;

procedure TJvGIFFrame.SetTransparentColor(Value: TColor);
begin
  if FTransparentColor <> Value then
  begin
    FTransparentColor := Value;
    if Value <> clNone then
      FOwner.FVersion := gv89a;
    FOwner.Changed(FOwner);
  end;
end;

function TJvGIFFrame.GetBitmap: TBitmap;
var
  Mem: TMemoryStream;
begin
  Result := FBitmap;
  if (Result = nil) or Result.Empty then
  begin
    NewBitmap;
    Result := FBitmap;
    if Assigned(FImage.FImageData) then
    try
      Mem := TMemoryStream.Create;
      try
        SaveToBitmapStream(Mem);
        FBitmap.LoadFromStream(Mem);
        if not FBitmap.Monochrome then
          FBitmap.HandleType := bmDDB;
      finally
        Mem.Free;
      end;
    except
      raise;
    end;
  end;
end;

function TJvGIFFrame.GetHeight: Integer;
begin
  if Assigned(FBitmap) or Assigned(FImage.FImageData) then
    Result := Bitmap.Height
  else
    Result := 0;
end;

function TJvGIFFrame.GetWidth: Integer;
begin
  if Assigned(FBitmap) or Assigned(FImage.FImageData) then
    Result := Bitmap.Width
  else
    Result := 0;
end;

function TJvGIFFrame.GetColorCount: Integer;
begin
  Result := FImage.FColorMap.Count;
  if (Result = 0) and Assigned(FBitmap) and (FBitmap.Palette <> 0) then
    Result := PaletteEntries(FBitmap.Palette);
end;

procedure TJvGIFFrame.GrayscaleImage(ForceEncoding: Boolean);
var
  Mem: TMemoryStream;
  TransIndex: Integer;
begin
  if not FGrayscale and (Assigned(FBitmap) or
    Assigned(FImage.FImageData)) then
  begin
    if Assigned(FImage.FImageData) and (FImage.FColorMap.Count > 0) then
    begin
      FBitmap.Free;
      FBitmap := nil;
      TransIndex := FindColorIndex(FImage.FColorMap, FTransparentColor);
      GrayColorTable(FImage.FColorMap);
      if TransIndex >= 0 then
        FTransparentColor := ItemToRGB(FImage.FColorMap.Colors[TransIndex])
      else
        FTransparentColor := clNone;
      FGrayscale := True;
      try
        GetBitmap;
      except
        on EAbort do
          ;
      else
        raise;
      end;
    end
    else
    begin
      Mem := BitmapToMemoryStream(Bitmap, pf8bit, mmGrayscale);
      try
        FImage.Release;
        FImage := TGIFItem.Create;
        FImage.Reference;
        if ForceEncoding then
          EncodeBitmapStream(Mem);
        FGrayscale := True;
        if FTransparentColor <> clNone then
          FTransparentColor := GrayColor(FTransparentColor);
        FBitmap.LoadFromStream(Mem);
      finally
        Mem.Free;
      end;
    end;
  end;
end;

procedure TJvGIFFrame.Assign(Source: TPersistent);
var
  AComment: TStrings;
begin
  if Source = nil then
  begin
    NewImage;
    FBitmap.Free;
    FBitmap := nil;
  end
  else
    if Source is TJvGIFFrame then
    begin
      if Source <> Self then
      begin
        FImage.Release;
        FImage := TJvGIFFrame(Source).FImage;
        if TJvGIFFrame(Source).FOwner <> FOwner then
          FLocalColors := True
        else
          FLocalColors := TJvGIFFrame(Source).FLocalColors;
        FImage.Reference;
        FTopLeft := TJvGIFFrame(Source).FTopLeft;
        FInterlaced := TJvGIFFrame(Source).FInterlaced;
        if TJvGIFFrame(Source).FBitmap <> nil then
        begin
          NewBitmap;
          FBitmap.Assign(TJvGIFFrame(Source).FBitmap);
        end;
        FTransparentColor := TJvGIFFrame(Source).FTransparentColor;
        FAnimateInterval := TJvGIFFrame(Source).FAnimateInterval;
        FDisposal := TJvGIFFrame(Source).FDisposal;
        FGrayscale := TJvGIFFrame(Source).FGrayscale;
        FCorrupted := TJvGIFFrame(Source).FCorrupted;
        AComment := TJvGIFFrame(Source).FindComment(False);
        if (AComment <> nil) and (AComment.Count > 0) then
          SetComment(AComment);
      end;
    end
    else
      if Source is TJvGIFImage then
      begin
        if TJvGIFImage(Source).Count > 0 then
        begin
          if TJvGIFImage(Source).FrameIndex >= 0 then
            Assign(TJvGIFImage(Source).Frames[TJvGIFImage(Source).FrameIndex])
          else
            Assign(TJvGIFImage(Source).Frames[0]);
        end
        else
          Assign(nil);
      end
      else
        if Source is TGraphic then
        begin
    { TBitmap, TJPEGImage... }
          if TGraphic(Source).Empty then
          begin
            Assign(nil);
            Exit;
          end;
          NewImage;
          NewBitmap;
          try
            FBitmap.Assign(Source);
            if Source is TBitmap then
              FBitmap.Monochrome := TBitmap(Source).Monochrome;
          except
            FBitmap.Canvas.Brush.Color := clFuchsia;
            FBitmap.Width := TGraphic(Source).Width;
            FBitmap.Height := TGraphic(Source).Height;
            FBitmap.Canvas.Draw(0, 0, TGraphic(Source));
          end;
          if TGraphic(Source).Transparent then
          begin
            if Source is TBitmap then
              FTransparentColor := TBitmap(Source).TransparentColor
            else
              FTransparentColor := GetNearestColor(FBitmap.Canvas.Handle,
                ColorToRGB(FBitmap.Canvas.Brush.Color));
          end;
        end
        else
          inherited Assign(Source);
  if FOwner <> nil then
    FOwner.UpdateScreenSize;
end;

procedure TJvGIFFrame.AssignTo(Dest: TPersistent);
begin
  if (Dest is TJvGIFFrame) or (Dest is TJvGIFImage) then
    Dest.Assign(Self)
  else
    if Dest is TGraphic then
    begin
      Dest.Assign(Bitmap);
      if (Dest is TBitmap) and (FTransparentColor <> clNone) then
      begin
        TBitmap(Dest).TransparentColor := GetNearestColor(
          TBitmap(Dest).Canvas.Handle, ColorToRGB(FTransparentColor));
        TBitmap(Dest).Transparent := True;
      end;
    end
    else
      inherited AssignTo(Dest);
end;

procedure TJvGIFFrame.NewBitmap;
begin
  FBitmap.Free;
  FBitmap := TBitmap.Create;
end;

procedure TJvGIFFrame.NewImage;
begin
  if FImage <> nil then
    FImage.Release;
  FImage := TGIFItem.Create;
  FImage.Reference;
  FGrayscale := False;
  FCorrupted := False;
  FTransparentColor := clNone;
  FTopLeft := Point(0, 0);
  FInterlaced := False;
  FLocalColors := False;
  FAnimateInterval := 0;
  FDisposal := dmUndefined;
end;

function TJvGIFFrame.FindComment(ForceCreate: Boolean): TStrings;
var
  Ext: TExtension;
begin
  Ext := FindExtension(FExtensions, etComment);
  if (Ext = nil) and ForceCreate then
  begin
    Ext := TExtension.Create;
    try
      Ext.FExtType := etComment;
      if FExtensions = nil then
        FExtensions := TList.Create;
      FExtensions.Add(Ext);
    except
      Ext.Free;
      raise;
    end;
  end;
  if Ext <> nil then
  begin
    if (Ext.FData = nil) and ForceCreate then
      Ext.FData := TStringList.Create;
    Result := Ext.FData;
  end
  else
    Result := nil;
end;

function TJvGIFFrame.GetComment: TStrings;
begin
  Result := FindComment(True);
end;

procedure TJvGIFFrame.SetComment(Value: TStrings);
begin
  GetComment.Assign(Value);
end;

procedure TJvGIFFrame.UpdateExtensions;
var
  Ext: TExtension;
  I: Integer;
begin
  Ext := FindExtension(FExtensions, etGraphic);
  if (FAnimateInterval > 0) or (FTransparentColor <> clNone) or
    (FDisposal <> dmUndefined) then
  begin
    if Ext = nil then
    begin
      Ext := TExtension.Create;
      Ext.FExtType := etGraphic;
      if FExtensions = nil then
        FExtensions := TList.Create;
      FExtensions.Add(Ext);
      with Ext.FExtRec.GCE do
      begin
        BlockSize := 4;
        PackedFields := 0;
        Terminator := 0;
      end;
    end;
  end;
  if Ext <> nil then
    with Ext.FExtRec.GCE do
    begin
      DelayTime := FAnimateInterval div 10;
      I := FindColorIndex(FImage.FColorMap, FTransparentColor);
      if I >= 0 then
      begin
        TransparentColorIndex := I;
        PackedFields := PackedFields or GCE_TRANSPARENT;
      end
      else
        PackedFields := PackedFields and not GCE_TRANSPARENT;
      PackedFields := (PackedFields and not GCE_DISPOSAL_METHOD) or
        (Ord(FDisposal) shl 2);
    end;
  if FExtensions <> nil then
    for I := FExtensions.Count - 1 downto 0 do
    begin
      Ext := TExtension(FExtensions[I]);
      if (Ext <> nil) and (Ext.FExtType = etComment) and
        ((Ext.FData = nil) or (Ext.FData.Count = 0)) then
      begin
        Ext.Free;
        FExtensions.Delete(I);
      end;
    end;
  if (FExtensions <> nil) and (FExtensions.Count > 0) then
    FOwner.FVersion := gv89a;
end;

procedure TJvGIFFrame.EncodeBitmapStream(Stream: TMemoryStream);
var
  BI: PBitmapInfoHeader;
  ColorCount, W, H: Integer;
  Bits, Pal: Pointer;
begin
  ColorCount := 0;
  Stream.Position := 0;
  BI := PBitmapInfoHeader(Longint(Stream.Memory) + SizeOf(TBitmapFileHeader));
  W := BI^.biWidth;
  H := BI^.biHeight;
  Pal := PRGBPalette(Longint(BI) + SizeOf(TBitmapInfoHeader));
  Bits := Pointer(Longword(Stream.Memory) + PBitmapFileHeader(Stream.Memory)^.bfOffBits);
  case BI^.biBitCount of
    1:
      ColorCount := 2;
    4:
      ColorCount := 16;
    8:
      ColorCount := 256;
  else
    GifError(RsEGIFEncodeError);
  end;
  FInterlaced := False;
  FillColorTable(FImage.FColorMap, PRGBPalette(Pal)^, ColorCount);
  if FImage.FImageData = nil then
    FImage.FImageData := TMemoryStream.Create
  else
    FImage.FImageData.SetSize(0);
  try
    WriteGIFData(FImage.FImageData, BI^, FInterlaced, Bits, FOwner.DoProgress);
  except
    on EAbort do
    begin
      NewImage; { OnProgress can raise EAbort to cancel image save }
      raise;
    end
  else
    raise;
  end;
  FImage.FBitsPerPixel := 1;
  while FImage.FColorMap.Count > 1 shl FImage.FBitsPerPixel do
    Inc(FImage.FBitsPerPixel);
  if FOwner.FImage.FColorMap.Count = 0 then
  begin
    FOwner.FImage.FColorMap := FImage.FColorMap;
    FOwner.FImage.FBitsPerPixel := FImage.FBitsPerPixel;
    FLocalColors := False;
  end
  else
    FLocalColors := True;
  FImage.FSize.X := W;
  FImage.FSize.Y := H;
  FOwner.FScreenWidth := Max(FOwner.FScreenWidth, FImage.FSize.X + FTopLeft.X);
  FOwner.FScreenHeight := Max(FOwner.FScreenHeight, FImage.FSize.Y + FTopLeft.Y);
end;

procedure TJvGIFFrame.EncodeRasterData;
var
  Method: TMappingMethod;
  Mem: TMemoryStream;
begin
  if not Assigned(FBitmap) or FBitmap.Empty then
    GifError(RsENoGIFData);
  if not (GetBitmapPixelFormat(FBitmap) in [pf1bit, pf4bit, pf8bit]) then
  begin
    if FGrayscale then
      Method := mmGrayscale
    else
      Method := DefaultMappingMethod;
    Mem := BitmapToMemoryStream(FBitmap, pf8bit, Method);
    if Method = mmGrayscale then
      FGrayscale := True;
  end
  else
    Mem := TMemoryStream.Create;
  try
    if Mem.Size = 0 then
      FBitmap.SaveToStream(Mem);
    EncodeBitmapStream(Mem);
  finally
    Mem.Free;
  end;
end;

procedure TJvGIFFrame.WriteImageDescriptor(Stream: TStream);
var
  ImageDesc: TImageDescriptor;
begin
  with ImageDesc do
  begin
    PackedFields := 0;
    if FLocalColors then
    begin
      FImage.FBitsPerPixel := 1;
      while FImage.FColorMap.Count > 1 shl FImage.FBitsPerPixel do
        Inc(FImage.FBitsPerPixel);
      PackedFields := (PackedFields or ID_LOCAL_COLOR_TABLE) +
        (FImage.FBitsPerPixel - 1);
    end;
    if FInterlaced then
      PackedFields := PackedFields or ID_INTERLACED;
    ImageLeftPos := FTopLeft.X;
    ImageTopPos := FTopLeft.Y;
    ImageWidth := FImage.FSize.X;
    ImageHeight := FImage.FSize.Y;
  end;
  Stream.Write(ImageDesc, SizeOf(TImageDescriptor));
end;

procedure TJvGIFFrame.WriteLocalColorMap(Stream: TStream);
begin
  if FLocalColors then
    with FImage.FColorMap do
      Stream.Write(Colors[0], Count * SizeOf(TGIFColorItem));
end;

procedure TJvGIFFrame.WriteRasterData(Stream: TStream);
begin
  Stream.WriteBuffer(FImage.FImageData.Memory^, FImage.FImageData.Size);
end;

procedure TJvGIFFrame.SaveToBitmapStream(Stream: TMemoryStream);

  function ConvertBitsPerPixel: TPixelFormat;
  begin
    Result := pfDevice;
    case FImage.FBitsPerPixel of
      1:
        Result := pf1bit;
      2..4:
        Result := pf4bit;
      5..8:
        Result := pf8bit;
    else
      GifError(RsEWrongGIFColors);
    end;
  end;

var
  HeaderSize: Longword;
  Length: Longword;
  BI: TBitmapInfoHeader;
  BitFile: TBitmapFileHeader;
  Colors: TRGBPalette;
  Bits: Pointer;
  Corrupt: Boolean;
begin
  with BI do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := FImage.FSize.X;
    biHeight := FImage.FSize.Y;
    biPlanes := 1;
    biBitCount := 0;
    case ConvertBitsPerPixel of
      pf1bit:
        biBitCount := 1;
      pf4bit:
        biBitCount := 4;
      pf8bit:
        biBitCount := 8;
    end;
    biCompression := BI_RGB;
    biSizeImage := (((biWidth * biBitCount + 31) div 32) * 4) * biHeight;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  HeaderSize := SizeOf(TBitmapFileHeader) + SizeOf(TBitmapInfoHeader) +
    SizeOf(TRGBQuad) * (1 shl BI.biBitCount);
  Length := HeaderSize + BI.biSizeImage;
  Stream.SetSize(0);
  Stream.Position := 0;
  with BitFile do
  begin
    bfType := $4D42; { BM }
    bfSize := Length;
    bfOffBits := HeaderSize;
  end;
  Stream.Write(BitFile, SizeOf(TBitmapFileHeader));
  Stream.Write(BI, SizeOf(TBitmapInfoHeader));
  FillRGBPalette(FImage.FColorMap, Colors);
  Stream.Write(Colors, SizeOf(TRGBQuad) * (1 shl BI.biBitCount));
  Bits := AllocMemo(BI.biSizeImage);
  try
    FillChar(Bits^, BI.biSizeImage, #0);
    FImage.FImageData.Position := 0;
    ReadGIFData(FImage.FImageData, BI, FInterlaced, GIFLoadCorrupted,
      FImage.FBitsPerPixel, Bits, Corrupt, FOwner.DoProgress);
    FCorrupted := FCorrupted or Corrupt;
    Stream.WriteBuffer(Bits^, BI.biSizeImage);
  finally
    FreeMemo(Bits);
  end;
  Stream.Position := 0;
end;

function ColorItemTwiceInColorMap(Index: Integer; ColorMap: TGIFColorTable): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := 0;
  while (I < ColorMap.Count) and not Result do
  begin
    if (I = Index) then
    begin
      Inc(I);
    end
    else
    begin
      Result := (ItemToRGB(ColorMap.Colors[Index]) = ItemToRGB(ColorMap.Colors[I]));
    end;
    Inc(I);
  end;
end;

procedure TJvGIFFrame.LoadFromStream(Stream: TStream);
var
  ImageDesc: TImageDescriptor;
  I, Offset, TransIndex: Integer;
begin
  FImage.FImageData := TMemoryStream.Create;
  try
    ReadImageStream(Stream, FImage.FImageData, ImageDesc, FInterlaced,
      FLocalColors, FCorrupted, FImage.FBitsPerPixel, FImage.FColorMap);
    if FCorrupted and not GIFLoadCorrupted then
      GifError('SReadError');
    FImage.FImageData.Position := 0;
    with ImageDesc do
    begin
      if ImageHeight = 0 then
        ImageHeight := FOwner.FScreenHeight;
      if ImageWidth = 0 then
        ImageWidth := FOwner.FScreenWidth;
      FTopLeft := Point(ImageLeftPos, ImageTopPos);
      FImage.FSize := Point(ImageWidth, ImageHeight);
      FImage.FPackedFields := PackedFields;
    end;
    if not FLocalColors then
      FImage.FColorMap := FOwner.FImage.FColorMap;
    FAnimateInterval := 0;
    if FExtensions <> nil then
    begin
      for I := 0 to FExtensions.Count - 1 do
        with TExtension(FExtensions[I]) do
          if FExtType = etGraphic then
          begin
            if (FExtRec.GCE.PackedFields and GCE_TRANSPARENT) <> 0 then
            begin
              TransIndex := FExtRec.GCE.TransparentColorIndex;
              if FImage.FColorMap.Count > TransIndex then
              begin
                // Mantis 2135: Ensure that the transparent color does not appear
                // twice in the palette or the second color index would end up
                // being transparent as well
                Offset := -1;
                while ColorItemTwiceInColorMap(TransIndex, FImage.FColorMap) do
                begin
                  if FImage.FColorMap.Colors[TransIndex].Blue = 0 then
                    Offset := 1
                  else
                    if FImage.FColorMap.Colors[TransIndex].Blue = 255 then
                      Offset := -1;
                  Inc(FImage.FColorMap.Colors[TransIndex].Blue, Offset);
                end;

                FTransparentColor := ItemToRGB(FImage.FColorMap.Colors[TransIndex]);
              end;
            end
            else
              FTransparentColor := clNone;
            FAnimateInterval := Max(FExtRec.GCE.DelayTime * 10, FAnimateInterval);
            FDisposal := TDisposalMethod((FExtRec.GCE.PackedFields and GCE_DISPOSAL_METHOD) shr 2);
          end;
    end;
  except
    FImage.FImageData.Free;
    FImage.FImageData := nil;
    raise;
  end;
end;

procedure TJvGIFFrame.Draw(ACanvas: TCanvas; const ARect: TRect;
  Transparent: Boolean);
begin
  if (FTransparentColor <> clNone) and Transparent then
  begin
    with ARect do
      StretchBitmapRectTransparent(ACanvas, Left, Top, Right - Left,
        Bottom - Top, Bounds(0, 0, Bitmap.Width, Bitmap.Height), Bitmap,
        FTransparentColor);
  end
  else
    ACanvas.StretchDraw(ARect, Bitmap);
end;

//=== { TJvGIFImage } ========================================================

constructor TJvGIFImage.Create;
begin
  inherited Create;
  NewImage;
  inherited SetTransparent(True);
end;

destructor TJvGIFImage.Destroy;
begin
  OnChange := nil;
  FImage.Release;
  ClearItems;
  FItems.Free;
  inherited Destroy;
end;

procedure TJvGIFImage.Clear;
begin
  Assign(nil);
end;

procedure TJvGIFImage.ClearItems;
begin
  if FItems <> nil then
    while FItems.Count > 0 do
    begin
      TObject(FItems[0]).Free;
      FItems.Delete(0);
    end;
end;

procedure TJvGIFImage.Assign(Source: TPersistent);
var
  I: Integer;
  AFrame: TJvGIFFrame;
begin
  if Source = nil then
  begin
    NewImage;
    Changed(Self);
  end
  else
    if (Source is TJvGIFImage) and (Source <> Self) then
    begin
      FImage.Release;
      FImage := TJvGIFImage(Source).FImage;
      FImage.Reference;
      FVersion := TJvGIFImage(Source).FVersion;
      FBackgroundColor := TJvGIFImage(Source).FBackgroundColor;
      FRepeatCount := TJvGIFImage(Source).FRepeatCount;
      FLooping := TJvGIFImage(Source).FLooping;
      FCorrupted := TJvGIFImage(Source).FCorrupted;
      if FItems = nil then
        FItems := TList.Create
      else
        ClearItems;
      with TJvGIFImage(Source) do
      begin
        for I := 0 to FItems.Count - 1 do
        begin
          AFrame := TJvGIFFrame.Create(Self);
          try
            AFrame.FImage.FBitsPerPixel :=
              TJvGIFFrame(FItems[I]).FImage.FBitsPerPixel;
            AFrame.Assign(TJvGIFFrame(FItems[I]));
            AFrame.FLocalColors := TJvGIFFrame(FItems[I]).FLocalColors;
            Self.FItems.Add(AFrame);
          except
            AFrame.Free;
            raise;
          end;
        end;
        Self.FScreenWidth := FScreenWidth;
        Self.FScreenHeight := FScreenHeight;
      end;
      FFrameIndex := TJvGIFImage(Source).FFrameIndex;
      Changed(Self);
    end
    else
      if Source is TJvGIFFrame then
      begin
        NewImage;
        with TJvGIFFrame(Source).FOwner.FImage do
        begin
          FImage.FAspectRatio := FAspectRatio;
          FImage.FBitsPerPixel := FBitsPerPixel;
          FImage.FColorResBits := FColorResBits;
          Move(FColorMap, FImage.FColorMap, SizeOf(FColorMap));
        end;
        FFrameIndex := FItems.Add(TJvGIFFrame.Create(Self));
        TJvGIFFrame(FItems[FFrameIndex]).Assign(Source);
        if FVersion = gvUnknown then
          FVersion := gv87a;
        Changed(Self);
      end
      else
        if Source is TBitmap then
        begin
          NewImage;
          AddFrame(TBitmap(Source));
          Changed(Self);
        end
        else
          inherited Assign(Source);
end;

procedure TJvGIFImage.AssignTo(Dest: TPersistent);
begin
  if Dest is TJvGIFImage then
    Dest.Assign(Self)
  else
    if Dest is TGraphic then
    begin
      if Empty then
        Dest.Assign(nil)
      else
        if FFrameIndex >= 0 then
          TJvGIFFrame(FItems[FFrameIndex]).AssignTo(Dest)
        else
          Dest.Assign(Bitmap);
    end
    else
      inherited AssignTo(Dest);
end;

procedure TJvGIFImage.Draw(ACanvas: TCanvas; const ARect: TRect);
begin
  if FFrameIndex >= 0 then
    TJvGIFFrame(FItems[FFrameIndex]).Draw(ACanvas, ARect, Self.Transparent);
end;

function TJvGIFImage.GetBackgroundColor: TColor;
begin
  Result := FBackgroundColor;
end;

procedure TJvGIFImage.SetBackgroundColor(Value: TColor);
begin
  if Value <> FBackgroundColor then
  begin
    FBackgroundColor := Value;
    Changed(Self);
  end;
end;

procedure TJvGIFImage.SetLooping(Value: Boolean);
begin
  if Value <> FLooping then
  begin
    FLooping := Value;
    Changed(Self);
  end;
end;

procedure TJvGIFImage.SetRepeatCount(Value: Word);
begin
  if Min(Value, MAX_LOOP_COUNT) <> FRepeatCount then
  begin
    FRepeatCount := Min(Value, MAX_LOOP_COUNT);
    Changed(Self);
  end;
end;

function TJvGIFImage.GetPixelFormat: TPixelFormat;
var
  I: Integer;
begin
  Result := pfDevice;
  if not Empty then
  begin
    Result := ColorsToPixelFormat(FImage.FColorMap.Count);
    for I := 0 to FItems.Count - 1 do
    begin
      if (Frames[I].FImage.FImageData = nil) or
        (Frames[I].FImage.FImageData.Size = 0) then
      begin
        if Assigned(Frames[I].FBitmap) then
          Result := TPixelFormat(Max(Ord(Result),
            Ord(GetBitmapPixelFormat(Frames[I].FBitmap))))
        else
          Result := TPixelFormat(Max(Ord(Result), Ord(pfDevice)));
      end
      else
        if Frames[I].FLocalColors then
          Result := TPixelFormat(Max(Ord(Result),
            Ord(ColorsToPixelFormat(Frames[I].FImage.FColorMap.Count))));
    end;
  end;
end;

function TJvGIFImage.GetCorrupted: Boolean;
var
  I: Integer;
begin
  Result := FCorrupted;
  if not Result then
    for I := 0 to FItems.Count - 1 do
      if Frames[I].Corrupted then
      begin
        Result := True;
        Exit;
      end;
end;

function TJvGIFImage.GetTransparentColor: TColor;
begin
  if (FItems.Count > 0) and (FFrameIndex >= 0) then
    Result := TJvGIFFrame(FItems[FFrameIndex]).FTransparentColor
  else
    Result := clNone;
end;

function TJvGIFImage.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJvGIFImage.GetFrame(Index: Integer): TJvGIFFrame;
begin
  Result := TJvGIFFrame(FItems[Index]);
end;

procedure TJvGIFImage.SetFrameIndex(Value: Integer);
begin
  Value := Min(FItems.Count - 1, Max(-1, Value));
  if FFrameIndex <> Value then
  begin
    FFrameIndex := Value;
    PaletteModified := True;
    Changed(Self);
  end;
end;

function TJvGIFImage.Equals(Graphic: TGraphic): Boolean;
begin
  Result := (Graphic is TJvGIFImage) and
    (FImage = TJvGIFImage(Graphic).FImage);
end;

function TJvGIFImage.GetBitmap: TBitmap;
var
  Bmp: TBitmap;
begin
  if FItems.Count > 0 then
  begin
    if (FFrameIndex >= 0) and (FFrameIndex < FItems.Count) then
      Result := TJvGIFFrame(FItems[FFrameIndex]).Bitmap
    else
      Result := TJvGIFFrame(FItems[0]).Bitmap
  end
  else
  begin
    FFrameIndex := 0;
    Bmp := TBitmap.Create;
    try
      Bmp.Handle := 0;
      Assign(Bmp);
      Result := TJvGIFFrame(FItems[FFrameIndex]).Bitmap;
    finally
      Bmp.Free;
    end;
  end;
end;

function TJvGIFImage.GetGlobalColorCount: Integer;
begin
  Result := FImage.FColorMap.Count;
end;

function TJvGIFImage.GetEmpty: Boolean;
var
  I: Integer;
begin
  I := Max(FFrameIndex, 0);
  Result := (FItems.Count = 0) or
    ((TJvGIFFrame(FItems[I]).FBitmap = nil) and
    ((TJvGIFFrame(FItems[I]).FImage.FImageData = nil) or
    (TJvGIFFrame(FItems[I]).FImage.FImageData.Size = 0)));
end;

function TJvGIFImage.GetPalette: HPALETTE;
begin
  if FItems.Count > 0 then
    Result := Bitmap.Palette
  else
    Result := 0;
end;

function TJvGIFImage.GetTransparent: Boolean;
var
  I: Integer;
begin
  if inherited GetTransparent then
    for I := 0 to FItems.Count - 1 do
      if Frames[I].TransparentColor <> clNone then
      begin
        Result := True;
        Exit;
      end;
  Result := False;
end;

function TJvGIFImage.GetHeight: Integer;
begin
  if not Empty and (FFrameIndex >= 0) and (FFrameIndex < Count) then
    Result := TJvGIFFrame(FItems[FFrameIndex]).Bitmap.Height
  else
    Result := 0;
end;

function TJvGIFImage.GetWidth: Integer;
begin
  if not Empty and (FFrameIndex >= 0) and (FFrameIndex < Count) then
    Result := TJvGIFFrame(FItems[FFrameIndex]).Bitmap.Width
  else
    Result := 0;
end;

function TJvGIFImage.GetScreenWidth: Integer;
begin
  if Empty then
    Result := 0
  else
    Result := FScreenWidth;
end;

function TJvGIFImage.GetScreenHeight: Integer;
begin
  if Empty then
    Result := 0
  else
    Result := FScreenHeight;
end;

procedure TJvGIFImage.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
var
  Bmp: TBitmap;
  Stream: TMemoryStream;
  Size: Longint;
  Buffer: Pointer;
  Data: THandle;
begin
  { !! check for gif clipboard Data, mime type image/gif }
  Data := GetClipboardData(CF_GIF);
  if Data <> 0 then
  begin
    Buffer := GlobalLock(Data);
    try
      Stream := TMemoryStream.Create;
      try
        Stream.Write(Buffer^, GlobalSize(Data));
        Stream.Position := 0;
        Stream.Read(Size, SizeOf(Size));
        ReadStream(Size, Stream, False);
        if Count > 0 then
        begin
          FFrameIndex := 0;
          AData := GetClipboardData(CF_BITMAP);
          if AData <> 0 then
          begin
            Frames[0].NewBitmap;
            Frames[0].FBitmap.LoadFromClipboardFormat(CF_BITMAP,
              AData, APalette);
          end;
        end;
      finally
        Stream.Free;
      end;
    finally
      GlobalUnlock(Data);
    end;
  end
  else
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.LoadFromClipboardFormat(AFormat, AData, APalette);
      Assign(Bmp);
    finally
      Bmp.Free;
    end;
  end;
end;

procedure TJvGIFImage.LoadFromStream(Stream: TStream);
begin
  ReadStream(Stream.Size - Stream.Position, Stream, True);
end;

procedure TJvGIFImage.LoadFromResourceName(Instance: THandle; const ResName: string;
  ResType: PChar);
var
  Stream: TStream;
begin
  Stream := TResourceStream.Create(Instance, ResName, ResType);
  try
    ReadStream(Stream.Size - Stream.Position, Stream, True);
  finally
    Stream.Free;
  end;
end;

procedure TJvGIFImage.LoadFromResourceID(Instance: THandle; ResID: Integer;
  ResType: PChar);
var
  Stream: TStream;
begin
  Stream := TResourceStream.CreateFromID(Instance, ResID, ResType);
  try
    ReadStream(Stream.Size - Stream.Position, Stream, True);
  finally
    Stream.Free;
  end;
end;

procedure TJvGIFImage.UpdateScreenSize;
var
  I: Integer;
begin
  FScreenWidth := 0;
  FScreenHeight := 0;
  for I := 0 to FItems.Count - 1 do
    if Frames[I] <> nil then
    begin
      FScreenWidth := Max(FScreenWidth, Frames[I].Width +
        Frames[I].FTopLeft.X);
      FScreenHeight := Max(FScreenHeight, Frames[I].Height +
        Frames[I].FTopLeft.Y);
    end;
end;

function TJvGIFImage.AddFrame(Value: TGraphic): Integer;
begin
  FFrameIndex := FItems.Add(TJvGIFFrame.Create(Self));
  TJvGIFFrame(FItems[FFrameIndex]).Assign(Value);
  if FVersion = gvUnknown then
    FVersion := gv87a;
  if FItems.Count > 1 then
    FVersion := gv89a;
  Result := FFrameIndex;
end;

procedure TJvGIFImage.DeleteFrame(Index: Integer);
begin
  Frames[Index].Free;
  FItems.Delete(Index);
  UpdateScreenSize;
  if FFrameIndex >= FItems.Count then
    Dec(FFrameIndex);
  Changed(Self);
end;

procedure TJvGIFImage.MoveFrame(CurIndex, NewIndex: Integer);
begin
  FItems.Move(CurIndex, NewIndex);
  FFrameIndex := NewIndex;
  Changed(Self);
end;

procedure TJvGIFImage.NewImage;
begin
  if FImage <> nil then
    FImage.Release;
  FImage := TGIFData.Create;
  FImage.Reference;
  if FItems = nil then
    FItems := TList.Create;
  ClearItems;
  FCorrupted := False;
  FFrameIndex := -1;
  FBackgroundColor := clNone;
  FRepeatCount := 1;
  FLooping := False;
  FVersion := gvUnknown;
end;

procedure TJvGIFImage.UniqueImage;
var
  Temp: TGIFData;
begin
  if FImage = nil then
    NewImage
  else
    if FImage.RefCount > 1 then
    begin
      Temp := TGIFData.Create;
      with Temp do
      try
        FComment.Assign(FImage.FComment);
        FAspectRatio := FImage.FAspectRatio;
        FBitsPerPixel := FImage.FBitsPerPixel;
        FColorResBits := FImage.FColorResBits;
        FColorMap := FImage.FColorMap;
      except
        Temp.Free;
        raise;
      end;
      FImage.Release;
      FImage := Temp;
      FImage.Reference;
    end;
end;

function TJvGIFImage.GetComment: TStrings;
begin
  Result := FImage.FComment;
end;

procedure TJvGIFImage.SetComment(Value: TStrings);
begin
  UniqueImage;
  FImage.FComment.Assign(Value);
end;

procedure TJvGIFImage.DecodeAllFrames;
var
  FrameNo, I: Integer;
begin
  for FrameNo := 0 to FItems.Count - 1 do
  try
    TJvGIFFrame(FItems[FrameNo]).GetBitmap;
  except
    on EAbort do
    begin { OnProgress can raise EAbort to cancel image load }
      for I := FItems.Count - 1 downto FrameNo do
      begin
        TObject(FItems[I]).Free;
        FItems.Delete(I);
      end;
      FCorrupted := True;
      Break;
    end;
  else
    raise;
  end;
end;

procedure TJvGIFImage.EncodeFrames(ReverseDecode: Boolean);
var
  FrameNo: Integer;
begin
  for FrameNo := 0 to FItems.Count - 1 do
    with TJvGIFFrame(FItems[FrameNo]) do
    begin
      if (FImage.FImageData = nil) or (FImage.FImageData.Size = 0) then
      begin
        FImage.FImageData.Free;
        FImage.FImageData := nil;
        EncodeRasterData;
        if ReverseDecode and (FBitmap.Palette = 0) then
        begin
          FBitmap.Free;
          FBitmap := nil;
          try
            GetBitmap;
          except
            on EAbort do
              ; { OnProgress can raise EAbort to cancel encoding }
          else
            raise;
          end;
        end;
      end;
      UpdateExtensions;
    end;
end;

procedure TJvGIFImage.EncodeAllFrames;
begin
  EncodeFrames(True);
end;

procedure TJvGIFImage.ReadData(Stream: TStream);
var
  Size: Longint;
begin
  Stream.Read(Size, SizeOf(Size));
  ReadStream(Size, Stream, True);
end;

procedure TJvGIFImage.ReadSignature(Stream: TStream);
var
  I: TGIFVersion;
  S: string[3];
begin
  FVersion := gvUnknown;
  SetLength(S, 3);
  Stream.Read(S[1], 3);
  if CompareText(GIFSignature, S) <> 0 then
    GifError(RsEGIFVersion);
  SetLength(S, 3);
  Stream.Read(S[1], 3);
  for I := Low(TGIFVersion) to High(TGIFVersion) do
    if CompareText(S, StrPas(GIFVersionStr[I])) = 0 then
    begin
      FVersion := I;
      Break;
    end;
  if FVersion = gvUnknown then
    GifError(RsEGIFVersion);
end;

procedure TJvGIFImage.ReadStream(Size: Longint; Stream: TStream;
  ForceDecode: Boolean);
var
  SeparatorChar: Char;
  NewItem: TJvGIFFrame;
  Extensions: TList;
  ScreenDesc: TScreenDescriptor;
  Data: TMemoryStream;

  procedure ReadScreenDescriptor(Stream: TStream);
  begin
    Stream.Read(ScreenDesc, SizeOf(ScreenDesc));
    FScreenWidth := ScreenDesc.ScreenWidth;
    FScreenHeight := ScreenDesc.ScreenHeight;
    with FImage do
    begin
      FAspectRatio := ScreenDesc.AspectRatio;
      FBitsPerPixel := 1 + (ScreenDesc.PackedFields and
        LSD_COLOR_TABLE_SIZE);
      FColorResBits := 1 + (ScreenDesc.PackedFields and
        LSD_COLOR_RESOLUTION) shr 4;
    end;
  end;

  procedure ReadGlobalColorMap(Stream: TStream);
  begin
    if (ScreenDesc.PackedFields and LSD_GLOBAL_COLOR_TABLE) <> 0 then
      with FImage.FColorMap do
      begin
        Count := 1 shl FImage.FBitsPerPixel;
        Stream.Read(Colors[0], Count * SizeOf(TGIFColorItem));
        if Count > ScreenDesc.BackgroundColorIndex then
          FBackgroundColor := ItemToRGB(Colors[ScreenDesc.BackgroundColorIndex]);
      end;
  end;

  function ReadDataBlock(Stream: TStream): TStringList;
  var
    BlockSize: Byte;
    S: string;
  begin
    Result := TStringList.Create;
    try
      repeat
        Stream.Read(BlockSize, SizeOf(Byte));
        if BlockSize <> 0 then
        begin
          SetLength(S, BlockSize);
          Stream.Read(S[1], BlockSize);
          Result.Add(S);
        end;
      until (BlockSize = 0) or (Stream.Position >= Stream.Size);
    except
      Result.Free;
      raise;
    end;
  end;

  function ReadExtension(Stream: TStream): TExtension;
  var
    ExtensionLabel: Byte;
  begin
    Result := TExtension.Create;
    try
      Stream.Read(ExtensionLabel, SizeOf(Byte));
      with Result do
        if ExtensionLabel = ExtLabels[etGraphic] then
        begin
          { graphic control extension }
          FExtType := etGraphic;
          Stream.Read(FExtRec.GCE, SizeOf(TGraphicControlExtension));
        end
        else
          if ExtensionLabel = ExtLabels[etComment] then
          begin
          { comment extension }
            FExtType := etComment;
            FData := ReadDataBlock(Stream);
          end
          else
            if ExtensionLabel = ExtLabels[etPlainText] then
            begin
          { plain text extension }
              FExtType := etPlainText;
              Stream.Read(FExtRec.PTE, SizeOf(TPlainTextExtension));
              FData := ReadDataBlock(Stream);
            end
            else
              if ExtensionLabel = ExtLabels[etApplication] then
              begin
          { application extension }
                FExtType := etApplication;
                Stream.Read(FExtRec.APPE, SizeOf(TAppExtension));
                FData := ReadDataBlock(Stream);
              end
              else
                GifError(Format(RsEUnrecognizedGIFExt, [ExtensionLabel]));
    except
      Result.Free;
      raise;
    end;
  end;

  function ReadSeparator(Stream: TStream): Char;
  begin
    Result := #0;
    while (Stream.Size > Stream.Position) and (Result = #0) do
      Stream.Read(Result, SizeOf(Byte));
  end;

  function ReadExtensionBlock(Stream: TStream; var SeparatorChar: Char): TList;
  var
    NewExt: TExtension;
  begin
    Result := nil;
    try
      while SeparatorChar = CHR_EXT_INTRODUCER do
      begin
        NewExt := ReadExtension(Stream);
        if NewExt.FExtType = etPlainText then
        begin
          { plain text data blocks are not supported,
            clear all previous readed extensions }
          FreeExtensions(Result);
          Result := nil;
        end;
        if NewExt.FExtType in [etPlainText, etApplication] then
        begin
          { check for loop extension }
          if NewExt.IsLoopExtension then
          begin
            FLooping := True;
            FRepeatCount := Min(MakeWord(Byte(NewExt.FData[0][2]),
              Byte(NewExt.FData[0][3])), MAX_LOOP_COUNT);
          end;
          { not supported yet, must be ignored }
          NewExt.Free;
        end
        else
        begin
          if Result = nil then
            Result := TList.Create;
          Result.Add(NewExt);
        end;
        if Stream.Size > Stream.Position then
          SeparatorChar := ReadSeparator(Stream)
        else
          SeparatorChar := CHR_TRAILER;
      end;
      if (Result <> nil) and (Result.Count = 0) then
      begin
        Result.Free;
        Result := nil;
      end;
    except
      if Result <> nil then
        Result.Free;
      raise;
    end;
  end;

var
  I: Integer;
  Ext: TExtension;
begin
  NewImage;
  with FImage do
  begin
    Data := TMemoryStream.Create;
    try
      TMemoryStream(Data).SetSize(Size);
      Stream.ReadBuffer(Data.Memory^, Size);
      if Size > 0 then
      begin
        Data.Position := 0;
        ReadSignature(Data);
        ReadScreenDescriptor(Data);
        ReadGlobalColorMap(Data);
        SeparatorChar := ReadSeparator(Data);
        while not (SeparatorChar in [CHR_TRAILER, #0]) and not
          (Data.Position >= Data.Size) do
        begin
          Extensions := ReadExtensionBlock(Data, SeparatorChar);
          if SeparatorChar = CHR_IMAGE_SEPARATOR then
          try
            NewItem := TJvGIFFrame.Create(Self);
            try
              if FImage.FColorMap.Count > 0 then
                NewItem.FImage.FBitsPerPixel :=
                  ColorsToBits(FImage.FColorMap.Count);
              NewItem.FExtensions := Extensions;
              Extensions := nil;
              NewItem.LoadFromStream(Data);
              FItems.Add(NewItem);
            except
              NewItem.Free;
              raise;
            end;
            if not (Data.Position >= Data.Size) then
            begin
              SeparatorChar := ReadSeparator(Data);
            end
            else
              SeparatorChar := CHR_TRAILER;
            if not (SeparatorChar in [CHR_EXT_INTRODUCER,
              CHR_IMAGE_SEPARATOR, CHR_TRAILER]) then
            begin
              SeparatorChar := #0;
                {GifError(RsEGIFDecodeError);}
            end;
          except
            FreeExtensions(Extensions);
            raise;
          end
          else
            if (FComment.Count = 0) and (Extensions <> nil) then
            begin
              try
              { trailig extensions }
                for I := 0 to Extensions.Count - 1 do
                begin
                  Ext := TExtension(Extensions[I]);
                  if (Ext <> nil) and (Ext.FExtType = etComment) then
                  begin
                    if FComment.Count > 0 then
                      FComment.Add(#13#10 + #13#10);
                    FComment.AddStrings(Ext.FData);
                  end;
                end;
              finally
                FreeExtensions(Extensions);
              end;
            end
            else
              if not (SeparatorChar in [CHR_TRAILER, #0]) then
                GifError('SReadError');
        end;
      end;
    finally
      Data.Free;
    end;
  end;
  if Count > 0 then
  begin
    FFrameIndex := 0;
    if ForceDecode then
    try
      GetBitmap; { force bitmap creation }
    except
      Frames[0].Free;
      FItems.Delete(0);
      raise;
    end;
  end;
  PaletteModified := True;
  Changed(Self);
end;

procedure TJvGIFImage.SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
  var APalette: HPALETTE);
var
  Stream: TMemoryStream;
  Data: THandle;
  Buffer: Pointer;
  I: Integer;
begin
  { !! check for gif clipboard format, mime type image/gif }
  if FItems.Count = 0 then
    Exit;
  Frames[0].Bitmap.SaveToClipboardFormat(AFormat, AData, APalette);
  for I := 0 to FItems.Count - 1 do
    with Frames[I] do
    begin
      if (FImage.FImageData = nil) or (FImage.FImageData.Size = 0) then
        Exit;
    end;
  Stream := TMemoryStream.Create;
  try
    WriteStream(Stream, True);
    Stream.Position := 0;
    Data := GlobalAlloc(HeapAllocFlags, Stream.Size);
    try
      if Data <> 0 then
      begin
        Buffer := GlobalLock(Data);
        try
          Stream.Read(Buffer^, Stream.Size);
          SetClipboardData(CF_GIF, Data);
        finally
          GlobalUnlock(Data);
        end;
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TJvGIFImage.WriteData(Stream: TStream);
begin
  WriteStream(Stream, True);
end;

procedure TJvGIFImage.SetHeight(Value: Integer);
begin
  GifError(RsEChangeGIFSize);
end;

procedure TJvGIFImage.SetWidth(Value: Integer);
begin
  GifError(RsEChangeGIFSize);
end;

procedure TJvGIFImage.WriteStream(Stream: TStream; WriteSize: Boolean);
var
  Separator: Char;
  Temp: Byte;
  FrameNo: Integer;
  Frame: TJvGIFFrame;
  Mem: TMemoryStream;
  Size: Longint;
  StrList: TStringList;

  procedure WriteSignature(Stream: TStream);
  var
    Header: TGIFHeader;
  begin
    Header.Signature := GIFSignature;
    Move(GIFVersionStr[FVersion][0], Header.Version[0], 3);
    Stream.Write(Header, SizeOf(TGIFHeader));
  end;

  procedure WriteScreenDescriptor(Stream: TStream);
  var
    ColorResBits: Byte;
    ScreenDesc: TScreenDescriptor;
    I: Integer;
  begin
    UpdateScreenSize;
    with ScreenDesc do
    begin
      ScreenWidth := Self.FScreenWidth;
      ScreenHeight := Self.FScreenHeight;
      AspectRatio := FImage.FAspectRatio;
      PackedFields := 0;
      BackgroundColorIndex := 0;
      if FImage.FColorMap.Count > 0 then
      begin
        PackedFields := PackedFields or LSD_GLOBAL_COLOR_TABLE;
        ColorResBits := ColorsToBits(FImage.FColorMap.Count);
        if FBackgroundColor <> clNone then
          for I := 0 to FImage.FColorMap.Count - 1 do
            if ColorToRGB(FBackgroundColor) =
              ItemToRGB(FImage.FColorMap.Colors[I]) then
            begin
              BackgroundColorIndex := I;
              Break;
            end;
        PackedFields := PackedFields + ((ColorResBits - 1) shl 4) +
          (FImage.FBitsPerPixel - 1);
      end;
    end;
    Stream.Write(ScreenDesc, SizeOf(ScreenDesc));
  end;

  procedure WriteDataBlock(Stream: TStream; Data: TStrings);
  var
    I: Integer;
    S: string;
    BlockSize: Byte;
  begin
    for I := 0 to Data.Count - 1 do
    begin
      S := Data[I];
      BlockSize := Min(Length(S), 255);
      if BlockSize > 0 then
      begin
        Stream.Write(BlockSize, SizeOf(Byte));
        Stream.Write(S[1], BlockSize);
      end;
    end;
    BlockSize := 0;
    Stream.Write(BlockSize, SizeOf(Byte));
  end;

  procedure WriteExtensionBlock(Stream: TStream; Extensions: TList);
  var
    I: Integer;
    Ext: TExtension;
    ExtensionLabel: Byte;
    SeparateChar: Char;
  begin
    SeparateChar := CHR_EXT_INTRODUCER;
    for I := 0 to Extensions.Count - 1 do
    begin
      Ext := TExtension(Extensions[I]);
      if Ext <> nil then
      begin
        Stream.Write(SeparateChar, SizeOf(Byte));
        ExtensionLabel := ExtLabels[Ext.FExtType];
        Stream.Write(ExtensionLabel, SizeOf(Byte));
        case Ext.FExtType of
          etGraphic:
            begin
              Stream.Write(Ext.FExtRec.GCE, SizeOf(TGraphicControlExtension));
            end;
          etComment:
            WriteDataBlock(Stream, Ext.FData);
          etPlainText:
            begin
              Stream.Write(Ext.FExtRec.PTE, SizeOf(TPlainTextExtension));
              WriteDataBlock(Stream, Ext.FData);
            end;
          etApplication:
            begin
              Stream.Write(Ext.FExtRec.APPE, SizeOf(TAppExtension));
              WriteDataBlock(Stream, Ext.FData);
            end;
        end;
      end;
    end;
  end;

begin
  if FItems.Count = 0 then
    GifError(RsENoGIFData);
  EncodeFrames(False);
  Mem := TMemoryStream.Create;
  try
    if FImage.FComment.Count > 0 then
      FVersion := gv89a;
    WriteSignature(Mem);
    WriteScreenDescriptor(Mem);
    if FImage.FColorMap.Count > 0 then
    begin
      with FImage.FColorMap do
        Mem.Write(Colors[0], Count * SizeOf(TGIFColorItem));
    end;
    if FLooping and (FItems.Count > 1) then
    begin
      { write looping extension }
      Separator := CHR_EXT_INTRODUCER;
      Mem.Write(Separator, SizeOf(Byte));
      Temp := ExtLabels[etApplication];
      Mem.Write(Temp, SizeOf(Byte));
      Temp := SizeOf(TAppExtension) - SizeOf(Byte);
      Mem.Write(Temp, SizeOf(Byte));
      Mem.Write(LoopExtNS[1], Temp);
      StrList := TStringList.Create;
      try
        StrList.Add(Char(AE_LOOPING) + Char(LoByte(FRepeatCount)) +
          Char(HiByte(FRepeatCount)));
        WriteDataBlock(Mem, StrList);
      finally
        StrList.Free;
      end;
    end;
    Separator := CHR_IMAGE_SEPARATOR;
    for FrameNo := 0 to FItems.Count - 1 do
    begin
      Frame := TJvGIFFrame(FItems[FrameNo]);
      if Frame.FExtensions <> nil then
        WriteExtensionBlock(Mem, Frame.FExtensions);
      Mem.Write(Separator, SizeOf(Byte));
      Frame.WriteImageDescriptor(Mem);
      Frame.WriteLocalColorMap(Mem);
      Frame.WriteRasterData(Mem);
    end;
    if FImage.FComment.Count > 0 then
    begin
      Separator := CHR_EXT_INTRODUCER;
      Mem.Write(Separator, SizeOf(Byte));
      Temp := ExtLabels[etComment];
      Mem.Write(Temp, SizeOf(Byte));
      WriteDataBlock(Mem, FImage.FComment);
    end;
    Separator := CHR_TRAILER;
    Mem.Write(Separator, SizeOf(Byte));
    Size := Mem.Size;
    if WriteSize then
      Stream.Write(Size, SizeOf(Size));
    Stream.Write(Mem.Memory^, Size);
  finally
    Mem.Free;
  end;
end;

procedure TJvGIFImage.Grayscale(ForceEncoding: Boolean);
var
  I: Integer;
begin
  if FItems.Count = 0 then
    GifError(RsENoGIFData);
  for I := 0 to FItems.Count - 1 do
    Frames[I].GrayscaleImage(ForceEncoding);
  if FBackgroundColor <> clNone then
  begin
    if FImage.FColorMap.Count > 0 then
    begin
      I := FindColorIndex(FImage.FColorMap, FBackgroundColor);
      GrayColorTable(FImage.FColorMap);
      if I >= 0 then
        FBackgroundColor := ItemToRGB(FImage.FColorMap.Colors[I])
      else
        FBackgroundColor := GrayColor(FBackgroundColor);
    end
    else
      FBackgroundColor := GrayColor(FBackgroundColor);
  end;
  PaletteModified := True;
  Changed(Self);
end;

procedure TJvGIFImage.SaveToStream(Stream: TStream);
begin
  WriteStream(Stream, False);
end;

procedure TJvGIFImage.DoProgress(Stage: TProgressStage; PercentDone: Byte;
  const Msg: string);
begin
  Progress(Self, Stage, PercentDone, False, Rect(0, 0, 0, 0), Msg);
end;

procedure Init;
begin
  CF_GIF := RegisterClipboardFormat('GIF Image');
{$IFDEF VCL}
{$IFDEF COMPILER7_UP}
  GroupDescendentsWith(TJvGIFFrame, TControl);
  GroupDescendentsWith(TJvGIFImage, TControl);
{$ENDIF COMPILER7_UP}
  RegisterClasses([TJvGIFFrame, TJvGIFImage]);
{$ENDIF VCL}
{$IFDEF USE_JV_GIF}
  TPicture.RegisterFileFormat('gif', RsGIFImage, TJvGIFImage);
  TPicture.RegisterClipboardFormat(CF_GIF, TJvGIFImage);
{$ENDIF USE_JV_GIF}
end;

initialization
{$IFDEF UNITVERSIONING}
  RegisterUnitVersion(HInstance, UnitVersioning);
{$ENDIF UNITVERSIONING}
  Init;

finalization
{$IFDEF USE_JV_GIF}
  TPicture.UnRegisterGraphicClass(TJvGIFImage);
{$ENDIF USE_JV_GIF}
{$IFDEF UNITVERSIONING}
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.

