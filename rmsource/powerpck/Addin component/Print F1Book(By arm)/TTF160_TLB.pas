unit TTF160_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130  $
// File generated on 2001-8-12 20:42:17 from Type Library described below.

// ************************************************************************  //
// Type Lib: d:\delphivcl\FormulaOne6\TTF16.ocx (1)
// LIBID: {B0475000-7740-11D1-BDC3-0020AF9F8E6E}
// LCID: 0
// Helpfile: d:\delphivcl\FormulaOne6\TTF16.hlp
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\stdole2.tlb)
//   (2) v2.0 StdType, (C:\WINNT\System32\olepro32.dll)
//   (3) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: Member 'Type' of 'IF1FileSpec' changed to 'Type_'
//   Hint: Member 'Type' of 'IF1NumberFormat' changed to 'Type_'
//   Hint: Member 'Type' of 'IF1Book' changed to 'Type_'
//   Hint: Parameter 'Array' of IF1Book.CopyDataFromArray changed to 'Array_'
//   Hint: Parameter 'Array' of IF1Book.CopyDataToArray changed to 'Array_'
//   Hint: Member 'Type' of 'IF1BookView' changed to 'Type_'
//   Hint: Parameter 'Array' of IF1BookView.CopyDataFromArray changed to 'Array_'
//   Hint: Parameter 'Array' of IF1BookView.CopyDataToArray changed to 'Array_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WRITEABLECONST ON}

interface

uses ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL,  
Windows{$IFDEF Delphi6}, Variants{$ENDIF};
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  TTF160MajorVersion = 6;
  TTF160MinorVersion = 1;

  LIBID_TTF160: TGUID = '{B0475000-7740-11D1-BDC3-0020AF9F8E6E}';

  IID_IF1RangeRef: TGUID = '{B0475020-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1RangeRef: TGUID = '{B0475021-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1FileSpec: TGUID = '{B0475023-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1FileSpec: TGUID = '{B0475024-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1ODBCConnect: TGUID = '{B0475027-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1ODBCConnect: TGUID = '{B0475028-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1ODBCQuery: TGUID = '{B0475029-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1ODBCQuery: TGUID = '{B047502A-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1ReplaceResults: TGUID = '{B047502B-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1ReplaceResults: TGUID = '{B047502C-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1NumberFormat: TGUID = '{B0475035-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1NumberFormat: TGUID = '{B0475036-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1CellFormat: TGUID = '{B047503D-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1CellFormat: TGUID = '{B047503E-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1PageSetup: TGUID = '{B047504D-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1PageSetup: TGUID = '{B047504C-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1Rect: TGUID = '{B0475040-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1Rect: TGUID = '{B0475041-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1ObjPos: TGUID = '{B0475042-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1ObjPos: TGUID = '{B0475043-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1FindReplaceInfo: TGUID = '{B0475047-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1FindReplaceInfo: TGUID = '{B0475048-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1DispAddInArray: TGUID = '{B047504F-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1AddInArray: TGUID = '{B0475050-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1DispAddInArrayEx: TGUID = '{B0475053-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1AddInArrayEx: TGUID = '{B0475054-7740-11D1-BDC3-0020AF9F8E6E}';
  IID_IF1EventArg: TGUID = '{B0475011-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1EventArg: TGUID = '{B0475012-7740-11D1-BDC3-0020AF9F8E6E}';
  DIID_IF1Book: TGUID = '{B0475001-7740-11D1-BDC3-0020AF9F8E6E}';
  DIID_DF1Events: TGUID = '{B0475002-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1Book: TGUID = '{B0475003-7740-11D1-BDC3-0020AF9F8E6E}';
  DIID_IF1BookView: TGUID = '{B0475032-7740-11D1-BDC3-0020AF9F8E6E}';
  CLASS_F1BookView: TGUID = '{B0475031-7740-11D1-BDC3-0020AF9F8E6E}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum F1ColWidthUnitsConstants
type
  F1ColWidthUnitsConstants = TOleEnum;
const
  F1ColWidthUnitsCharacters = $00000000;
  F1ColWidthUnitsTwips = $00000001;

// Constants for enum F1RowHeightConstants
type
  F1RowHeightConstants = TOleEnum;
const
  F1RowHeightAuto = $FFFFFFFF;

// Constants for enum F1ShowOffOnAutoConstants
type
  F1ShowOffOnAutoConstants = TOleEnum;
const
  F1Off = $00000000;
  F1On = $00000001;
  F1Auto = $00000002;

// Constants for enum F1ShowTabsConstants
type
  F1ShowTabsConstants = TOleEnum;
const
  F1TabsOff = $00000000;
  F1TabsBottom = $00000001;
  F1TabsTop = $00000002;

// Constants for enum F1ModeConstants
type
  F1ModeConstants = TOleEnum;
const
  F1ModeNormal = $00000000;
  F1ModeLine = $00000001;
  F1ModeRectangle = $00000002;
  F1ModeOval = $00000003;
  F1ModeArc = $00000004;
  F1ModeChart = $00000005;
  F1ModeField = $00000006;
  F1ModeButton = $00000007;
  F1ModePolygon = $00000008;
  F1ModeCheckBox = $00000009;
  F1ModeDropDown = $0000000A;

// Constants for enum F1PolyEditModeConstants
type
  F1PolyEditModeConstants = TOleEnum;
const
  F1PolyEditModeNormal = $00000000;
  F1PolyEditModePoints = $00000001;

// Constants for enum F1ShiftTypeConstants
type
  F1ShiftTypeConstants = TOleEnum;
const
  F1ShiftHorizontal = $00000001;
  F1ShiftVertical = $00000002;
  F1ShiftRows = $00000003;
  F1ShiftCols = $00000004;
  F1FixupNormal = $00000000;
  F1FixupPrepend = $00000010;
  F1FixupAppend = $00000020;

// Constants for enum F1ODBCExecuteErrorConstants
type
  F1ODBCExecuteErrorConstants = TOleEnum;
const
  F1ODBCErrorAbort = $00000000;
  F1ODBCErrorSkipRow = $00000001;
  F1ODBCErrorTryAgain = $00000002;

// Constants for enum F1CDataTypesConstants
type
  F1CDataTypesConstants = TOleEnum;
const
  F1CDataChar = $00000000;
  F1CDataDouble = $00000001;
  F1CDataDate = $00000002;
  F1CDataTime = $00000003;
  F1CDataTimeStamp = $00000004;
  F1CDataBool = $00000005;
  F1CDataLong = $00000006;

// Constants for enum F1HAlignConstants
type
  F1HAlignConstants = TOleEnum;
const
  F1HAlignGeneral = $00000001;
  F1HAlignLeft = $00000002;
  F1HAlignCenter = $00000003;
  F1HAlignRight = $00000004;
  F1HAlignFill = $00000005;
  F1HAlignJustify = $00000006;
  F1HAlignCenterAcrossCells = $00000007;

// Constants for enum F1VAlignConstants
type
  F1VAlignConstants = TOleEnum;
const
  F1VAlignTop = $00000001;
  F1VAlignCenter = $00000002;
  F1VAlignBottom = $00000003;

// Constants for enum F1ClearTypeConstants
type
  F1ClearTypeConstants = TOleEnum;
const
  F1ClearDlg = $00000000;
  F1ClearAll = $00000001;
  F1ClearFormats = $00000002;
  F1ClearValues = $00000003;

// Constants for enum F1FileTypeConstants
type
  F1FileTypeConstants = TOleEnum;
const
  F1FileTabbedText = $00000003;
  F1FileExcel5 = $00000004;
  F1FileFormulaOne3 = $00000005;
  F1FileTabbedTextValuesOnly = $00000006;
  F1FileHTML = $00000009;
  F1FileHTMLDataOnly = $0000000A;
  F1FileExcel97 = $0000000B;
  F1FileFormulaOne6 = $0000000C;

// Constants for enum F1ObjTypeConstants
type
  F1ObjTypeConstants = TOleEnum;
const
  F1ObjLine = $00000001;
  F1ObjRectangle = $00000002;
  F1ObjOval = $00000003;
  F1ObjArc = $00000004;
  F1ObjChart = $00000005;
  F1ObjButton = $00000007;
  F1ObjPolygon = $00000008;
  F1ObjCheckBox = $00000009;
  F1ObjDropDown = $0000000A;
  F1ObjPicture = $0000000B;

// Constants for enum F1FindReplaceConstants
type
  F1FindReplaceConstants = TOleEnum;
const
  F1FindMatchCase = $00000001;
  F1FindEntireCells = $00000002;
  F1FindMatchBytes = $00000004;
  F1FindByRows = $00000000;
  F1FindByColumns = $00000008;
  F1FindInFormulas = $00000000;
  F1FindInValues = $00000010;
  F1FindReplaceAll = $00000020;

// Constants for enum F1BeforeReplaceConstants
type
  F1BeforeReplaceConstants = TOleEnum;
const
  F1ReplaceYes = $00000000;
  F1ReplaceNo = $00000001;
  F1ReplaceCancel = $00000002;

// Constants for enum F1ErrorConstants
type
  F1ErrorConstants = TOleEnum;
const
  F1ErrorNone = $00000000;
  F1ErrorGeneral = $00004E21;
  F1ErrorBadArgument = $00004E22;
  F1ErrorNoMemory = $00004E23;
  F1ErrorBadFormula = $00004E24;
  F1ErrorBufTooShort = $00004E25;
  F1ErrorNotFound = $00004E26;
  F1ErrorBadRC = $00004E27;
  F1ErrorBadHSS = $00004E28;
  F1ErrorTooManyHSS = $00004E29;
  F1ErrorNoTable = $00004E2A;
  F1ErrorUnableToOpenFile = $00004E2B;
  F1ErrorInvalidFile = $00004E2C;
  F1ErrorInsertShiftOffTable = $00004E2D;
  F1ErrorOnlyOneRange = $00004E2E;
  F1ErrorNothingToPaste = $00004E2F;
  F1ErrorBadNumberFormat = $00004E30;
  F1ErrorTooManyFonts = $00004E31;
  F1ErrorTooManySelectedRanges = $00004E32;
  F1ErrorUnableToWriteFile = $00004E33;
  F1ErrorNoTransaction = $00004E34;
  F1ErrorNothingToPrint = $00004E35;
  F1ErrorPrintMarginsDontFit = $00004E36;
  F1ErrorCancel = $00004E37;
  F1ErrorUnableToInitializePrinter = $00004E38;
  F1ErrorStringTooLong = $00004E39;
  F1ErrorFormulaTooLong = $00004E3A;
  F1ErrorUnableToOpenClipboard = $00004E3B;
  F1ErrorPasteWouldOverflowSheet = $00004E3C;
  F1ErrorLockedCellsCannotBeModified = $00004E3D;
  F1ErrorLockedDocCannotBeModified = $00004E3E;
  F1ErrorInvalidName = $00004E3F;
  F1ErrorCannotDeleteNameInUse = $00004E40;
  F1ErrorUnableToFindName = $00004E41;
  F1ErrorNoWindow = $00004E42;
  F1ErrorSelection = $00004E43;
  F1ErrorTooManyObjects = $00004E44;
  F1ErrorInvalidObjectType = $00004E45;
  F1ErrorObjectNotFound = $00004E46;
  F1ErrorInvalidRequest = $00004E47;
  F1ErrorBadValidationRule = $00004E48;
  F1ErrorBadInputMask = $00004E49;
  F1ErrorValidationFailed = $00004E4A;
  F1ErrorNoODBCConnection = $00004E4B;
  F1ErrorUnableToLoadODBC = $00004E4C;
  F1ErrorUnsupportedFeature = $00004E4D;
  F1ErrorBadArray = $00004E4E;
  F1InvalidODBCParameterBinding = $00004E4F;
  F1InvalidStatementHandle = $00004E50;
  F1BadPrepareStatement = $00004E51;
  F1NotAvailableInSafeMode = $00004E52;
  F1ErrorMergedCellsCannotOverlap = $00004E53;
  F1ErrorCannotMergeHeaders = $00004E54;
  F1ErrorPartialMergedCell = $00004E55;
  F1ErrorPossibleDataLoss = $00004E56;
  F1ErrorCannotReplaceInValues = $00004E57;
  F1ErrorNothingToReplace = $00004E58;
  F1ErrorUnsupportedFile = $00004E5B;
  F1ErrorPasteDifferentShape = $00004E5C;
  F1ErrorIllegalMergedCellOperation = $00004E5D;

// Constants for enum F1ControlCellConstants
type
  F1ControlCellConstants = TOleEnum;
const
  F1ControlNoCell = $00000000;
  F1ControlCellValue = $00000001;
  F1ControlCellText = $00000002;

// Constants for enum F1BorderConstants
type
  F1BorderConstants = TOleEnum;
const
  F1HInsideBorder = $FFFFFFFE;
  F1VInsideBorder = $FFFFFFFF;
  F1TopBorder = $00000000;
  F1LeftBorder = $00000001;
  F1BottomBorder = $00000002;
  F1RightBorder = $00000003;

// Constants for enum F1PasteWhatConstants
type
  F1PasteWhatConstants = TOleEnum;
const
  F1PasteAll = $00000000;
  F1PasteFormulas = $00000001;
  F1PasteValues = $00000002;
  F1PasteFormats = $00000003;

// Constants for enum F1PasteOpConstants
type
  F1PasteOpConstants = TOleEnum;
const
  F1PasteOpNone = $00000000;

// Constants for enum F1BorderStyleConstants
type
  F1BorderStyleConstants = TOleEnum;
const
  F1BorderNone = $00000000;
  F1BorderThin = $00000001;
  F1BorderMedium = $00000002;
  F1BorderDashed = $00000003;
  F1BorderDotted = $00000004;
  F1BorderThick = $00000005;
  F1BorderDouble = $00000006;
  F1BorderHair = $00000007;
  F1BorderMediumDashed = $00000008;
  F1BorderDashDot = $00000009;
  F1BorderMediumDashDot = $0000000A;
  F1BorderDashDotDot = $0000000B;
  F1BorderMediumDashDotDot = $0000000C;
  F1BorderSlantedDashDot = $0000000D;

// Constants for enum F1BookBorderConstants
type
  F1BookBorderConstants = TOleEnum;
const
  F1BookBorderNone = $00000000;
  F1BookBorderThin = $00000001;

// Constants for enum F1DialogPageConstants
type
  F1DialogPageConstants = TOleEnum;
const
  F1AllPages = $7FFFFFFF;
  F1AllExcept = $80000000;
  F1NumberPage = $00000001;
  F1AlignmentPage = $00000002;
  F1FontPage = $00000004;
  F1BorderPage = $00000008;
  F1PatternsPage = $00000010;
  F1ProtectionPage = $00000020;
  F1ValidationPage = $00000040;
  F1LineStylePage = $00000080;
  F1NamePage = $00000100;
  F1OptionsPage = $00000200;
  F1AutoFillPage = $00000400;
  F1CalculationPage = $00000800;
  F1ColorPage = $00001000;
  F1EditPage = $00002000;
  F1GeneralPage = $00004000;
  F1ViewPage = $00008000;
  F1SelectionPage = $00010000;
  F1PagePage = $00020000;
  F1MarginsPage = $00040000;
  F1HeaderFooterPage = $00080000;
  F1SheetPage = $00100000;

// Constants for enum F1FormatTypeConstants
type
  F1FormatTypeConstants = TOleEnum;
const
  F1NoType = $FFFFFFFF;
  F1GeneralType = $00000000;
  F1NumberType = $00000001;
  F1CurrencyType = $00000002;
  F1DateType = $00000003;
  F1DateTimeType = $00000004;
  F1PercentType = $00000005;
  F1FractionType = $00000006;
  F1ScientificType = $00000007;
  F1StringType = $00000008;

// Constants for enum F1CharSetConstants
type
  F1CharSetConstants = TOleEnum;
const
  F1AnsiCharSet = $00000000;
  F1SymbolCharSet = $00000002;
  F1ShiftJisCharSet = $00000080;
  F1HangeulCharSet = $00000081;
  F1HangulCharSet = $00000081;
  F1GB2312CharSet = $00000086;
  F1ChineseBig5CharSet = $00000088;
  F1OemCharSet = $000000FF;
  F1JohabCharSet = $00000082;
  F1HebrewCharSet = $000000B1;
  F1ArabicCharSet = $000000B2;
  F1GreekCharSet = $000000A1;
  F1TurkishCharSet = $000000A2;
  F1VietnameseCharSet = $000000A3;
  F1ThaiCharSet = $000000DE;
  F1EastEuropeCharSet = $000000EE;
  F1RussianCharSet = $000000CC;
  F1MacCharSet = $0000004D;
  F1BalticCharSet = $000000BA;

// Constants for enum F1CellAttrConstants
type
  F1CellAttrConstants = TOleEnum;
const
  F1CellAlignHorizontal = $00000008;
  F1CellWordWrap = $00000009;
  F1CellAlignVertical = $0000000A;
  F1CellFontName = $0000000B;
  F1CellFontCharSet = $0000000C;
  F1CellFontSize = $0000000D;
  F1CellFontBold = $0000000E;
  F1CellFontItalic = $0000000F;
  F1CellFontUnderline = $00000010;
  F1CellFontStrikeout = $00000011;
  F1CellFontColor = $00000012;
  F1CellNumberFormat = $00000013;
  F1CellPatternStyle = $00000014;
  F1CellPatternFG = $00000015;
  F1CellPatternBG = $00000016;
  F1CellProtectionLocked = $00000017;
  F1CellProtectionHidden = $00000018;
  F1CellValidationRule = $00000019;
  F1CellValidationText = $0000001A;
  F1CellMergeCells = $0000001B;

// Constants for enum F1PgSetupAttrConstants
type
  F1PgSetupAttrConstants = TOleEnum;
const
  F1PgSetupLandscape = $00000000;
  F1PgSetupFitPages = $00000001;
  F1PgSetupScale = $00000002;
  F1PgSetupPagesWide = $00000003;
  F1PgSetupPagesTall = $00000004;
  F1PgSetupPaperSize = $00000005;
  F1PgSetupFirstPageNumber = $00000006;
  F1PgSetupAutoPageNumber = $00000007;
  F1PgSetupLeftMargin = $00000008;
  F1PgSetupTopMargin = $00000009;
  F1PgSetupRightMargin = $0000000A;
  F1PgSetupBottomMargin = $0000000B;
  F1PgSetupHeaderMargin = $0000000C;
  F1PgSetupFooterMargin = $0000000D;
  F1PgSetupCenterHoriz = $0000000E;
  F1PgSetupCenterVert = $0000000F;
  F1PgSetupHeader = $00000010;
  F1PgSetupFooter = $00000011;
  F1PgSetupGridLines = $00000012;
  F1PgSetupBlackAndWhite = $00000013;
  F1PgSetupRowHeadings = $00000014;
  F1PgSetupColHeadings = $00000015;
  F1PgSetupLeftToRight = $00000016;
  F1PgSetupPrintArea = $00000017;
  F1PgSetupPrintTitles = $00000018;

// Constants for enum F1PaperSizeConstants
type
  F1PaperSizeConstants = TOleEnum;
const
  F1PaperLetter = $00000001;
  F1PaperLetterSmall = $00000002;
  F1PaperTabloid = $00000003;
  F1PaperLedger = $00000004;
  F1PaperLegal = $00000005;
  F1PaperStatement = $00000006;
  F1PaperExecutive = $00000007;
  F1PaperA3 = $00000008;
  F1PaperA4 = $00000009;
  F1PaperA4Small = $0000000A;
  F1PaperA5 = $0000000B;
  F1PaperB4 = $0000000C;
  F1PaperB5 = $0000000D;
  F1PaperFolio = $0000000E;
  F1PaperQuarto = $0000000F;
  F1Paper10x14 = $00000010;
  F1Paper11x17 = $00000011;
  F1PaperNote = $00000012;
  F1PaperEnv9 = $00000013;
  F1PaperEnv10 = $00000014;
  F1PaperEnv11 = $00000015;
  F1PaperEnv12 = $00000016;
  F1PaperEnv14 = $00000017;
  F1PaperCSheet = $00000018;
  F1PaperDSheet = $00000019;
  F1PaperESheet = $0000001A;
  F1PaperEnvDL = $0000001B;
  F1PaperEnvC5 = $0000001C;
  F1PaperEnvC3 = $0000001D;
  F1PaperEnvC4 = $0000001E;
  F1PaperEnvC6 = $0000001F;
  F1PaperEnvC65 = $00000020;
  F1PaperEnvB4 = $00000021;
  F1PaperEnvB5 = $00000022;
  F1PaperEnvB6 = $00000023;
  F1PaperEnvItaly = $00000024;
  F1PaperEnvMonarch = $00000025;
  F1PaperEnvPersonal = $00000026;
  F1PaperFanfoldUS = $00000027;
  F1PaperFanfoldStdGerman = $00000028;
  F1PaperFanfoldLglGerman = $00000029;

// Constants for enum F1MousePointerConstants
type
  F1MousePointerConstants = TOleEnum;
const
  F1Default = $00000000;
  F1Arrow = $00000001;
  F1Cross = $00000002;
  F1IBeam = $00000003;
  F1Icon = $00000004;
  F1Size = $00000005;
  F1SizeNESW = $00000006;
  F1SizeNS = $00000007;
  F1SizeNWSE = $00000008;
  F1SizeWE = $00000009;
  F1UpArrow = $0000000A;
  F1Hourglass = $0000000B;
  F1NoDrop = $0000000C;
  F1ArrowAndHourglass = $0000000D;
  F1ArrowAndQuestion = $0000000E;
  F1SizeAll = $0000000F;
  F1Custom = $00000063;

// Constants for enum F1AddInErrorConstants
type
  F1AddInErrorConstants = TOleEnum;
const
  F1AddInNullError = $00004EE9;
  F1AddInDivZeroError = $00004EEA;
  F1AddInValueError = $00004EEB;
  F1AddInRefError = $00004EEC;
  F1AddInNameError = $00004EED;
  F1AddInNumError = $00004EEE;
  F1AddInNaError = $00004EEF;

// Constants for enum F1AddInArrayTypeConstants
type
  F1AddInArrayTypeConstants = TOleEnum;
const
  F1AddIn2dArea = $00000001;
  F1AddIn3dArea = $00000002;
  F1AddInRegion = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IF1RangeRef = interface;
  IF1RangeRefDisp = dispinterface;
  IF1FileSpec = interface;
  IF1FileSpecDisp = dispinterface;
  IF1ODBCConnect = interface;
  IF1ODBCConnectDisp = dispinterface;
  IF1ODBCQuery = interface;
  IF1ODBCQueryDisp = dispinterface;
  IF1ReplaceResults = interface;
  IF1ReplaceResultsDisp = dispinterface;
  IF1NumberFormat = interface;
  IF1NumberFormatDisp = dispinterface;
  IF1CellFormat = interface;
  IF1CellFormatDisp = dispinterface;
  IF1PageSetup = interface;
  IF1PageSetupDisp = dispinterface;
  IF1Rect = interface;
  IF1RectDisp = dispinterface;
  IF1ObjPos = interface;
  IF1ObjPosDisp = dispinterface;
  IF1FindReplaceInfo = interface;
  IF1FindReplaceInfoDisp = dispinterface;
  IF1DispAddInArray = interface;
  IF1DispAddInArrayDisp = dispinterface;
  IF1DispAddInArrayEx = interface;
  IF1DispAddInArrayExDisp = dispinterface;
  IF1EventArg = interface;
  IF1EventArgDisp = dispinterface;
  IF1Book = dispinterface;
  DF1Events = dispinterface;
  IF1BookView = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  F1RangeRef = IF1RangeRef;
  F1FileSpec = IF1FileSpec;
  F1ODBCConnect = IF1ODBCConnect;
  F1ODBCQuery = IF1ODBCQuery;
  F1ReplaceResults = IF1ReplaceResults;
  F1NumberFormat = IF1NumberFormat;
  F1CellFormat = IF1CellFormat;
  F1PageSetup = IF1PageSetup;
  F1Rect = IF1Rect;
  F1ObjPos = IF1ObjPos;
  F1FindReplaceInfo = IF1FindReplaceInfo;
  F1AddInArray = IF1DispAddInArray;
  F1AddInArrayEx = IF1DispAddInArrayEx;
  F1EventArg = IF1EventArg;
  F1Book = IF1Book;
  F1BookView = IF1BookView;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPUserType1 = ^IF1EventArg; {*}
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// Interface: IF1RangeRef
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475020-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1RangeRef = interface(IDispatch)
    ['{B0475020-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_StartRow: Integer; safecall;
    function  Get_StartCol: Integer; safecall;
    function  Get_EndRow: Integer; safecall;
    function  Get_EndCol: Integer; safecall;
    function  Get_Rows: Integer; safecall;
    function  Get_Cols: Integer; safecall;
    property StartRow: Integer read Get_StartRow;
    property StartCol: Integer read Get_StartCol;
    property EndRow: Integer read Get_EndRow;
    property EndCol: Integer read Get_EndCol;
    property Rows: Integer read Get_Rows;
    property Cols: Integer read Get_Cols;
  end;

// *********************************************************************//
// DispIntf:  IF1RangeRefDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475020-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1RangeRefDisp = dispinterface
    ['{B0475020-7740-11D1-BDC3-0020AF9F8E6E}']
    property StartRow: Integer readonly dispid 1;
    property StartCol: Integer readonly dispid 2;
    property EndRow: Integer readonly dispid 3;
    property EndCol: Integer readonly dispid 4;
    property Rows: Integer readonly dispid 5;
    property Cols: Integer readonly dispid 6;
  end;

// *********************************************************************//
// Interface: IF1FileSpec
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475023-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1FileSpec = interface(IDispatch)
    ['{B0475023-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Name: WideString; safecall;
    function  Get_Type_: F1FileTypeConstants; safecall;
    procedure Set_Name(const pName: WideString); safecall;
    procedure Set_Type_(pType: F1FileTypeConstants); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Type_: F1FileTypeConstants read Get_Type_ write Set_Type_;
  end;

// *********************************************************************//
// DispIntf:  IF1FileSpecDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475023-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1FileSpecDisp = dispinterface
    ['{B0475023-7740-11D1-BDC3-0020AF9F8E6E}']
    property Name: WideString dispid 1;
    property Type_: F1FileTypeConstants dispid 2;
  end;

// *********************************************************************//
// Interface: IF1ODBCConnect
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475027-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ODBCConnect = interface(IDispatch)
    ['{B0475027-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_ConnectStr: WideString; safecall;
    procedure Set_ConnectStr(const pConnect: WideString); safecall;
    function  Get_RetCode: Smallint; safecall;
    procedure Set_RetCode(pRetCode: Smallint); safecall;
    property ConnectStr: WideString read Get_ConnectStr write Set_ConnectStr;
    property RetCode: Smallint read Get_RetCode write Set_RetCode;
  end;

// *********************************************************************//
// DispIntf:  IF1ODBCConnectDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475027-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ODBCConnectDisp = dispinterface
    ['{B0475027-7740-11D1-BDC3-0020AF9F8E6E}']
    property ConnectStr: WideString dispid 1;
    property RetCode: Smallint dispid 2;
  end;

// *********************************************************************//
// Interface: IF1ODBCQuery
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475029-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ODBCQuery = interface(IDispatch)
    ['{B0475029-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_QueryStr: WideString; safecall;
    procedure Set_QueryStr(const pQuery: WideString); safecall;
    function  Get_SetColNames: WordBool; safecall;
    procedure Set_SetColNames(pSetColNames: WordBool); safecall;
    function  Get_SetColFormats: WordBool; safecall;
    procedure Set_SetColFormats(pSetColFormats: WordBool); safecall;
    function  Get_SetColWidths: WordBool; safecall;
    procedure Set_SetColWidths(pSetColWidths: WordBool); safecall;
    function  Get_SetMaxRC: WordBool; safecall;
    procedure Set_SetMaxRC(pSetMaxRC: WordBool); safecall;
    function  Get_RetCode: Smallint; safecall;
    procedure Set_RetCode(pRetCode: Smallint); safecall;
    property QueryStr: WideString read Get_QueryStr write Set_QueryStr;
    property SetColNames: WordBool read Get_SetColNames write Set_SetColNames;
    property SetColFormats: WordBool read Get_SetColFormats write Set_SetColFormats;
    property SetColWidths: WordBool read Get_SetColWidths write Set_SetColWidths;
    property SetMaxRC: WordBool read Get_SetMaxRC write Set_SetMaxRC;
    property RetCode: Smallint read Get_RetCode write Set_RetCode;
  end;

// *********************************************************************//
// DispIntf:  IF1ODBCQueryDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475029-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ODBCQueryDisp = dispinterface
    ['{B0475029-7740-11D1-BDC3-0020AF9F8E6E}']
    property QueryStr: WideString dispid 1;
    property SetColNames: WordBool dispid 2;
    property SetColFormats: WordBool dispid 3;
    property SetColWidths: WordBool dispid 4;
    property SetMaxRC: WordBool dispid 5;
    property RetCode: Smallint dispid 6;
  end;

// *********************************************************************//
// Interface: IF1ReplaceResults
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047502B-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ReplaceResults = interface(IDispatch)
    ['{B047502B-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Found: Integer; safecall;
    function  Get_Replaced: Integer; safecall;
    property Found: Integer read Get_Found;
    property Replaced: Integer read Get_Replaced;
  end;

// *********************************************************************//
// DispIntf:  IF1ReplaceResultsDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047502B-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ReplaceResultsDisp = dispinterface
    ['{B047502B-7740-11D1-BDC3-0020AF9F8E6E}']
    property Found: Integer readonly dispid 1;
    property Replaced: Integer readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IF1NumberFormat
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475035-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1NumberFormat = interface(IDispatch)
    ['{B0475035-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_NumberFormat: WideString; safecall;
    function  Get_NumberFormatLocal: WideString; safecall;
    function  Get_Index: Integer; safecall;
    function  Get_Type_: F1FormatTypeConstants; safecall;
    property NumberFormat: WideString read Get_NumberFormat;
    property NumberFormatLocal: WideString read Get_NumberFormatLocal;
    property Index: Integer read Get_Index;
    property Type_: F1FormatTypeConstants read Get_Type_;
  end;

// *********************************************************************//
// DispIntf:  IF1NumberFormatDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475035-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1NumberFormatDisp = dispinterface
    ['{B0475035-7740-11D1-BDC3-0020AF9F8E6E}']
    property NumberFormat: WideString readonly dispid 1;
    property NumberFormatLocal: WideString readonly dispid 2;
    property Index: Integer readonly dispid 3;
    property Type_: F1FormatTypeConstants readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IF1CellFormat
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047503D-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1CellFormat = interface(IDispatch)
    ['{B047503D-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_AlignHorizontal: F1HAlignConstants; safecall;
    procedure Set_AlignHorizontal(pAlignHorizontal: F1HAlignConstants); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Set_WordWrap(pWordWrap: WordBool); safecall;
    function  Get_AlignVertical: F1VAlignConstants; safecall;
    procedure Set_AlignVertical(pAlignVertical: F1VAlignConstants); safecall;
    function  Get_BorderStyle(WhichBorder: F1BorderConstants): F1BorderStyleConstants; safecall;
    procedure Set_BorderStyle(WhichBorder: F1BorderConstants; pBorderStyle: F1BorderStyleConstants); safecall;
    function  Get_BorderColor(WhichBorder: F1BorderConstants): OLE_COLOR; safecall;
    procedure Set_BorderColor(WhichBorder: F1BorderConstants; pBorderColor: OLE_COLOR); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontName(const pFontName: WideString); safecall;
    function  Get_FontCharSet: F1CharSetConstants; safecall;
    procedure Set_FontCharSet(pFontCharSet: F1CharSetConstants); safecall;
    function  Get_FontSize: Smallint; safecall;
    procedure Set_FontSize(pFontSize: Smallint); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontBold(pFontBold: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontItalic(pFontItalic: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontUnderline(pFontUnderline: WordBool); safecall;
    function  Get_FontStrikeout: WordBool; safecall;
    procedure Set_FontStrikeout(pFontStrikeout: WordBool); safecall;
    function  Get_FontColor: OLE_COLOR; safecall;
    procedure Set_FontColor(pFontColor: OLE_COLOR); safecall;
    function  Get_MergeCells: WordBool; safecall;
    procedure Set_MergeCells(pMergeCells: WordBool); safecall;
    function  Get_NumberFormat(hSS: Integer): WideString; safecall;
    procedure Set_NumberFormat(hSS: Integer; const pNumberFormat: WideString); safecall;
    function  Get_NumberFormatLocal(hSS: Integer): WideString; safecall;
    procedure Set_NumberFormatLocal(hSS: Integer; const pNumberFormatLocal: WideString); safecall;
    function  Get_PatternStyle: Smallint; safecall;
    procedure Set_PatternStyle(pPatternStyle: Smallint); safecall;
    function  Get_PatternFG: OLE_COLOR; safecall;
    procedure Set_PatternFG(pPatternFG: OLE_COLOR); safecall;
    function  Get_PatternBG: OLE_COLOR; safecall;
    procedure Set_PatternBG(pPatternBG: OLE_COLOR); safecall;
    function  Get_ProtectionLocked: WordBool; safecall;
    procedure Set_ProtectionLocked(pProtectionLocked: WordBool); safecall;
    function  Get_ProtectionHidden: WordBool; safecall;
    procedure Set_ProtectionHidden(pProtectionHidden: WordBool); safecall;
    function  Get_ValidationRule(hSS: Integer): WideString; safecall;
    procedure Set_ValidationRule(hSS: Integer; const pValidationRule: WideString); safecall;
    function  Get_ValidationRuleLocal(hSS: Integer): WideString; safecall;
    procedure Set_ValidationRuleLocal(hSS: Integer; const pValidationRuleLocal: WideString); safecall;
    function  Get_ValidationRuleRC(hSS: Integer; nRow: Integer; nCol: Integer): WideString; safecall;
    procedure Set_ValidationRuleRC(hSS: Integer; nRow: Integer; nCol: Integer; 
                                   const pValidationRuleRC: WideString); safecall;
    function  Get_ValidationRuleLocalRC(hSS: Integer; nRow: Integer; nCol: Integer): WideString; safecall;
    procedure Set_ValidationRuleLocalRC(hSS: Integer; nRow: Integer; nCol: Integer; 
                                        const pValidationRuleLocalRC: WideString); safecall;
    function  Get_ValidationText: WideString; safecall;
    procedure Set_ValidationText(const pValidationText: WideString); safecall;
    function  Get_IsDefined(Attribute: F1CellAttrConstants): WordBool; safecall;
    procedure Set_IsDefined(Attribute: F1CellAttrConstants; pIsDefined: WordBool); safecall;
    function  Get_IsBorderDefined(Border: F1BorderConstants): WordBool; safecall;
    procedure Set_IsBorderDefined(Border: F1BorderConstants; pIsBorderDefined: WordBool); safecall;
    property AlignHorizontal: F1HAlignConstants read Get_AlignHorizontal write Set_AlignHorizontal;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property AlignVertical: F1VAlignConstants read Get_AlignVertical write Set_AlignVertical;
    property BorderStyle[WhichBorder: F1BorderConstants]: F1BorderStyleConstants read Get_BorderStyle write Set_BorderStyle;
    property BorderColor[WhichBorder: F1BorderConstants]: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontCharSet: F1CharSetConstants read Get_FontCharSet write Set_FontCharSet;
    property FontSize: Smallint read Get_FontSize write Set_FontSize;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontStrikeout: WordBool read Get_FontStrikeout write Set_FontStrikeout;
    property FontColor: OLE_COLOR read Get_FontColor write Set_FontColor;
    property MergeCells: WordBool read Get_MergeCells write Set_MergeCells;
    property NumberFormat[hSS: Integer]: WideString read Get_NumberFormat write Set_NumberFormat;
    property NumberFormatLocal[hSS: Integer]: WideString read Get_NumberFormatLocal write Set_NumberFormatLocal;
    property PatternStyle: Smallint read Get_PatternStyle write Set_PatternStyle;
    property PatternFG: OLE_COLOR read Get_PatternFG write Set_PatternFG;
    property PatternBG: OLE_COLOR read Get_PatternBG write Set_PatternBG;
    property ProtectionLocked: WordBool read Get_ProtectionLocked write Set_ProtectionLocked;
    property ProtectionHidden: WordBool read Get_ProtectionHidden write Set_ProtectionHidden;
    property ValidationRule[hSS: Integer]: WideString read Get_ValidationRule write Set_ValidationRule;
    property ValidationRuleLocal[hSS: Integer]: WideString read Get_ValidationRuleLocal write Set_ValidationRuleLocal;
    property ValidationRuleRC[hSS: Integer; nRow: Integer; nCol: Integer]: WideString read Get_ValidationRuleRC write Set_ValidationRuleRC;
    property ValidationRuleLocalRC[hSS: Integer; nRow: Integer; nCol: Integer]: WideString read Get_ValidationRuleLocalRC write Set_ValidationRuleLocalRC;
    property ValidationText: WideString read Get_ValidationText write Set_ValidationText;
    property IsDefined[Attribute: F1CellAttrConstants]: WordBool read Get_IsDefined write Set_IsDefined;
    property IsBorderDefined[Border: F1BorderConstants]: WordBool read Get_IsBorderDefined write Set_IsBorderDefined;
  end;

// *********************************************************************//
// DispIntf:  IF1CellFormatDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047503D-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1CellFormatDisp = dispinterface
    ['{B047503D-7740-11D1-BDC3-0020AF9F8E6E}']
    property AlignHorizontal: F1HAlignConstants dispid 1;
    property WordWrap: WordBool dispid 2;
    property AlignVertical: F1VAlignConstants dispid 3;
    property BorderStyle[WhichBorder: F1BorderConstants]: F1BorderStyleConstants dispid 4;
    property BorderColor[WhichBorder: F1BorderConstants]: OLE_COLOR dispid 5;
    property FontName: WideString dispid 6;
    property FontCharSet: F1CharSetConstants dispid 7;
    property FontSize: Smallint dispid 8;
    property FontBold: WordBool dispid 9;
    property FontItalic: WordBool dispid 10;
    property FontUnderline: WordBool dispid 11;
    property FontStrikeout: WordBool dispid 12;
    property FontColor: OLE_COLOR dispid 13;
    property MergeCells: WordBool dispid 28;
    property NumberFormat[hSS: Integer]: WideString dispid 14;
    property NumberFormatLocal[hSS: Integer]: WideString dispid 15;
    property PatternStyle: Smallint dispid 16;
    property PatternFG: OLE_COLOR dispid 17;
    property PatternBG: OLE_COLOR dispid 18;
    property ProtectionLocked: WordBool dispid 19;
    property ProtectionHidden: WordBool dispid 20;
    property ValidationRule[hSS: Integer]: WideString dispid 21;
    property ValidationRuleLocal[hSS: Integer]: WideString dispid 22;
    property ValidationRuleRC[hSS: Integer; nRow: Integer; nCol: Integer]: WideString dispid 23;
    property ValidationRuleLocalRC[hSS: Integer; nRow: Integer; nCol: Integer]: WideString dispid 24;
    property ValidationText: WideString dispid 25;
    property IsDefined[Attribute: F1CellAttrConstants]: WordBool dispid 26;
    property IsBorderDefined[Border: F1BorderConstants]: WordBool dispid 27;
  end;

// *********************************************************************//
// Interface: IF1PageSetup
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047504D-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1PageSetup = interface(IDispatch)
    ['{B047504D-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Landscape: WordBool; safecall;
    procedure Set_Landscape(pLandscape: WordBool); safecall;
    function  Get_FitPages: WordBool; safecall;
    procedure Set_FitPages(pFitPages: WordBool); safecall;
    function  Get_PrintScale: Smallint; safecall;
    procedure Set_PrintScale(pScale: Smallint); safecall;
    function  Get_PagesWide: Integer; safecall;
    procedure Set_PagesWide(pPagesWide: Integer); safecall;
    function  Get_PagesTall: Integer; safecall;
    procedure Set_PagesTall(pPagesTall: Integer); safecall;
    function  Get_PaperSize: F1PaperSizeConstants; safecall;
    procedure Set_PaperSize(pPaperSize: F1PaperSizeConstants); safecall;
    function  Get_FirstPageNumber: Integer; safecall;
    procedure Set_FirstPageNumber(pFirstPageNumber: Integer); safecall;
    function  Get_AutoPageNumber: WordBool; safecall;
    procedure Set_AutoPageNumber(pAutoPageNumber: WordBool); safecall;
    function  Get_LeftMargin: Double; safecall;
    procedure Set_LeftMargin(pLeftMargin: Double); safecall;
    function  Get_TopMargin: Double; safecall;
    procedure Set_TopMargin(pTopMargin: Double); safecall;
    function  Get_RightMargin: Double; safecall;
    procedure Set_RightMargin(pRightMargin: Double); safecall;
    function  Get_BottomMargin: Double; safecall;
    procedure Set_BottomMargin(pBottomMargin: Double); safecall;
    function  Get_HeaderMargin: Double; safecall;
    procedure Set_HeaderMargin(pHeaderMargin: Double); safecall;
    function  Get_FooterMargin: Double; safecall;
    procedure Set_FooterMargin(pFooterMargin: Double); safecall;
    function  Get_CenterHoriz: WordBool; safecall;
    procedure Set_CenterHoriz(pCenterHoriz: WordBool); safecall;
    function  Get_CenterVert: WordBool; safecall;
    procedure Set_CenterVert(pCenterVert: WordBool); safecall;
    function  Get_Header: WideString; safecall;
    procedure Set_Header(const pHeader: WideString); safecall;
    function  Get_Footer: WideString; safecall;
    procedure Set_Footer(const pFooter: WideString); safecall;
    function  Get_GridLines: WordBool; safecall;
    procedure Set_GridLines(pGridLines: WordBool); safecall;
    function  Get_BlackAndWhite: WordBool; safecall;
    procedure Set_BlackAndWhite(pBlackAndWhite: WordBool); safecall;
    function  Get_RowHeadings: WordBool; safecall;
    procedure Set_RowHeadings(pRowHeadings: WordBool); safecall;
    function  Get_ColHeadings: WordBool; safecall;
    procedure Set_ColHeadings(pColHeadings: WordBool); safecall;
    function  Get_LeftToRight: WordBool; safecall;
    procedure Set_LeftToRight(pLeftToRight: WordBool); safecall;
    function  Get_IsDefined(Attribute: F1PgSetupAttrConstants): WordBool; safecall;
    procedure Set_IsDefined(Attribute: F1PgSetupAttrConstants; pIsDefined: WordBool); safecall;
    function  Get_PrintArea: WideString; safecall;
    procedure Set_PrintArea(const pPrintArea: WideString); safecall;
    function  Get_PrintAreaLocal: WideString; safecall;
    procedure Set_PrintAreaLocal(const pPrintAreaLocal: WideString); safecall;
    function  Get_PrintTitles: WideString; safecall;
    procedure Set_PrintTitles(const pPrintTitles: WideString); safecall;
    function  Get_PrintTitlesLocal: WideString; safecall;
    procedure Set_PrintTitlesLocal(const pPrintTitlesLocal: WideString); safecall;
    property Landscape: WordBool read Get_Landscape write Set_Landscape;
    property FitPages: WordBool read Get_FitPages write Set_FitPages;
    property PrintScale: Smallint read Get_PrintScale write Set_PrintScale;
    property PagesWide: Integer read Get_PagesWide write Set_PagesWide;
    property PagesTall: Integer read Get_PagesTall write Set_PagesTall;
    property PaperSize: F1PaperSizeConstants read Get_PaperSize write Set_PaperSize;
    property FirstPageNumber: Integer read Get_FirstPageNumber write Set_FirstPageNumber;
    property AutoPageNumber: WordBool read Get_AutoPageNumber write Set_AutoPageNumber;
    property LeftMargin: Double read Get_LeftMargin write Set_LeftMargin;
    property TopMargin: Double read Get_TopMargin write Set_TopMargin;
    property RightMargin: Double read Get_RightMargin write Set_RightMargin;
    property BottomMargin: Double read Get_BottomMargin write Set_BottomMargin;
    property HeaderMargin: Double read Get_HeaderMargin write Set_HeaderMargin;
    property FooterMargin: Double read Get_FooterMargin write Set_FooterMargin;
    property CenterHoriz: WordBool read Get_CenterHoriz write Set_CenterHoriz;
    property CenterVert: WordBool read Get_CenterVert write Set_CenterVert;
    property Header: WideString read Get_Header write Set_Header;
    property Footer: WideString read Get_Footer write Set_Footer;
    property GridLines: WordBool read Get_GridLines write Set_GridLines;
    property BlackAndWhite: WordBool read Get_BlackAndWhite write Set_BlackAndWhite;
    property RowHeadings: WordBool read Get_RowHeadings write Set_RowHeadings;
    property ColHeadings: WordBool read Get_ColHeadings write Set_ColHeadings;
    property LeftToRight: WordBool read Get_LeftToRight write Set_LeftToRight;
    property IsDefined[Attribute: F1PgSetupAttrConstants]: WordBool read Get_IsDefined write Set_IsDefined;
    property PrintArea: WideString read Get_PrintArea write Set_PrintArea;
    property PrintAreaLocal: WideString read Get_PrintAreaLocal write Set_PrintAreaLocal;
    property PrintTitles: WideString read Get_PrintTitles write Set_PrintTitles;
    property PrintTitlesLocal: WideString read Get_PrintTitlesLocal write Set_PrintTitlesLocal;
  end;

// *********************************************************************//
// DispIntf:  IF1PageSetupDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047504D-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1PageSetupDisp = dispinterface
    ['{B047504D-7740-11D1-BDC3-0020AF9F8E6E}']
    property Landscape: WordBool dispid 1;
    property FitPages: WordBool dispid 2;
    property PrintScale: Smallint dispid 3;
    property PagesWide: Integer dispid 4;
    property PagesTall: Integer dispid 5;
    property PaperSize: F1PaperSizeConstants dispid 6;
    property FirstPageNumber: Integer dispid 7;
    property AutoPageNumber: WordBool dispid 8;
    property LeftMargin: Double dispid 9;
    property TopMargin: Double dispid 10;
    property RightMargin: Double dispid 11;
    property BottomMargin: Double dispid 12;
    property HeaderMargin: Double dispid 13;
    property FooterMargin: Double dispid 14;
    property CenterHoriz: WordBool dispid 15;
    property CenterVert: WordBool dispid 16;
    property Header: WideString dispid 17;
    property Footer: WideString dispid 18;
    property GridLines: WordBool dispid 19;
    property BlackAndWhite: WordBool dispid 20;
    property RowHeadings: WordBool dispid 21;
    property ColHeadings: WordBool dispid 22;
    property LeftToRight: WordBool dispid 23;
    property IsDefined[Attribute: F1PgSetupAttrConstants]: WordBool dispid 24;
    property PrintArea: WideString dispid 25;
    property PrintAreaLocal: WideString dispid 26;
    property PrintTitles: WideString dispid 27;
    property PrintTitlesLocal: WideString dispid 28;
  end;

// *********************************************************************//
// Interface: IF1Rect
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475040-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1Rect = interface(IDispatch)
    ['{B0475040-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Top: Integer; safecall;
    function  Get_Left: Integer; safecall;
    function  Get_Bottom: Integer; safecall;
    function  Get_Right: Integer; safecall;
    function  Get_Height: Integer; safecall;
    function  Get_Width: Integer; safecall;
    property Top: Integer read Get_Top;
    property Left: Integer read Get_Left;
    property Bottom: Integer read Get_Bottom;
    property Right: Integer read Get_Right;
    property Height: Integer read Get_Height;
    property Width: Integer read Get_Width;
  end;

// *********************************************************************//
// DispIntf:  IF1RectDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475040-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1RectDisp = dispinterface
    ['{B0475040-7740-11D1-BDC3-0020AF9F8E6E}']
    property Top: Integer readonly dispid 1;
    property Left: Integer readonly dispid 2;
    property Bottom: Integer readonly dispid 3;
    property Right: Integer readonly dispid 4;
    property Height: Integer readonly dispid 5;
    property Width: Integer readonly dispid 6;
  end;

// *********************************************************************//
// Interface: IF1ObjPos
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475042-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ObjPos = interface(IDispatch)
    ['{B0475042-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_StartRow: Single; safecall;
    function  Get_StartCol: Single; safecall;
    function  Get_EndRow: Single; safecall;
    function  Get_EndCol: Single; safecall;
    function  Get_Rows: Single; safecall;
    function  Get_Cols: Single; safecall;
    property StartRow: Single read Get_StartRow;
    property StartCol: Single read Get_StartCol;
    property EndRow: Single read Get_EndRow;
    property EndCol: Single read Get_EndCol;
    property Rows: Single read Get_Rows;
    property Cols: Single read Get_Cols;
  end;

// *********************************************************************//
// DispIntf:  IF1ObjPosDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475042-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1ObjPosDisp = dispinterface
    ['{B0475042-7740-11D1-BDC3-0020AF9F8E6E}']
    property StartRow: Single readonly dispid 1;
    property StartCol: Single readonly dispid 2;
    property EndRow: Single readonly dispid 3;
    property EndCol: Single readonly dispid 4;
    property Rows: Single readonly dispid 5;
    property Cols: Single readonly dispid 6;
  end;

// *********************************************************************//
// Interface: IF1FindReplaceInfo
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475047-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1FindReplaceInfo = interface(IDispatch)
    ['{B0475047-7740-11D1-BDC3-0020AF9F8E6E}']
    function  FindNext: WordBool; safecall;
    procedure Replace(const ReplaceWith: WideString); safecall;
    function  Get_Row: Integer; safecall;
    function  Get_Col: Integer; safecall;
    property Row: Integer read Get_Row;
    property Col: Integer read Get_Col;
  end;

// *********************************************************************//
// DispIntf:  IF1FindReplaceInfoDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475047-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1FindReplaceInfoDisp = dispinterface
    ['{B0475047-7740-11D1-BDC3-0020AF9F8E6E}']
    function  FindNext: WordBool; dispid 1;
    procedure Replace(const ReplaceWith: WideString); dispid 2;
    property Row: Integer readonly dispid 3;
    property Col: Integer readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IF1DispAddInArray
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047504F-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1DispAddInArray = interface(IDispatch)
    ['{B047504F-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Rows: Integer; safecall;
    function  Get_Cols: Integer; safecall;
    function  GetArrayType: F1AddInArrayTypeConstants; safecall;
    function  GetValue(nRow: Integer; nCol: Integer): OleVariant; safecall;
    function  IterStart: WordBool; safecall;
    function  IterNext: WordBool; safecall;
    function  IterGetValue: OleVariant; safecall;
    function  IterGetValueEx(out pRow: Integer; out pCol: Integer): OleVariant; safecall;
    property Rows: Integer read Get_Rows;
    property Cols: Integer read Get_Cols;
  end;

// *********************************************************************//
// DispIntf:  IF1DispAddInArrayDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B047504F-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1DispAddInArrayDisp = dispinterface
    ['{B047504F-7740-11D1-BDC3-0020AF9F8E6E}']
    property Rows: Integer readonly dispid 2;
    property Cols: Integer readonly dispid 3;
    function  GetArrayType: F1AddInArrayTypeConstants; dispid 4;
    function  GetValue(nRow: Integer; nCol: Integer): OleVariant; dispid 0;
    function  IterStart: WordBool; dispid 5;
    function  IterNext: WordBool; dispid 6;
    function  IterGetValue: OleVariant; dispid 7;
    function  IterGetValueEx(out pRow: Integer; out pCol: Integer): OleVariant; dispid 8;
  end;

// *********************************************************************//
// Interface: IF1DispAddInArrayEx
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475053-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1DispAddInArrayEx = interface(IDispatch)
    ['{B0475053-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Areas: Integer; safecall;
    function  Get_Rows(nArea: Integer): Integer; safecall;
    function  Get_Cols(nArea: Integer): Integer; safecall;
    function  GetArrayType: F1AddInArrayTypeConstants; safecall;
    function  GetValue(nArea: Integer; nRow: Integer; nCol: Integer): OleVariant; safecall;
    function  IterStart: WordBool; safecall;
    function  IterNext: WordBool; safecall;
    function  IterGetValue: OleVariant; safecall;
    function  IterGetValueEx(out pArea: Integer; out pRow: Integer; out pCol: Integer): OleVariant; safecall;
    property Areas: Integer read Get_Areas;
    property Rows[nArea: Integer]: Integer read Get_Rows;
    property Cols[nArea: Integer]: Integer read Get_Cols;
  end;

// *********************************************************************//
// DispIntf:  IF1DispAddInArrayExDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475053-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1DispAddInArrayExDisp = dispinterface
    ['{B0475053-7740-11D1-BDC3-0020AF9F8E6E}']
    property Areas: Integer readonly dispid 1;
    property Rows[nArea: Integer]: Integer readonly dispid 2;
    property Cols[nArea: Integer]: Integer readonly dispid 3;
    function  GetArrayType: F1AddInArrayTypeConstants; dispid 4;
    function  GetValue(nArea: Integer; nRow: Integer; nCol: Integer): OleVariant; dispid 0;
    function  IterStart: WordBool; dispid 5;
    function  IterNext: WordBool; dispid 6;
    function  IterGetValue: OleVariant; dispid 7;
    function  IterGetValueEx(out pArea: Integer; out pRow: Integer; out pCol: Integer): OleVariant; dispid 8;
  end;

// *********************************************************************//
// Interface: IF1EventArg
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475011-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1EventArg = interface(IDispatch)
    ['{B0475011-7740-11D1-BDC3-0020AF9F8E6E}']
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(pValue: OleVariant); safecall;
    property Value: OleVariant read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IF1EventArgDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B0475011-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1EventArgDisp = dispinterface
    ['{B0475011-7740-11D1-BDC3-0020AF9F8E6E}']
    property Value: OleVariant dispid 0;
  end;

// *********************************************************************//
// DispIntf:  IF1Book
// Flags:     (4112) Hidden Dispatchable
// GUID:      {B0475001-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1Book = dispinterface
    ['{B0475001-7740-11D1-BDC3-0020AF9F8E6E}']
    property BackColor: OLE_COLOR dispid 3;
    property Col: Integer dispid 4;
    property Row: Integer dispid 5;
    property ShowHScrollBar: F1ShowOffOnAutoConstants dispid 6;
    property Text: WideString dispid 7;
    property Number: Double dispid 8;
    property Formula: WideString dispid 9;
    property FixedCol: Integer dispid 10;
    property FixedCols: Integer dispid 11;
    property FixedRow: Integer dispid 12;
    property FixedRows: Integer dispid 13;
    property ShowGridLines: WordBool dispid 14;
    property ShowRowHeading: WordBool dispid 15;
    property ShowSelections: F1ShowOffOnAutoConstants dispid 16;
    property LeftCol: Integer dispid 17;
    property MaxCol: Integer dispid 18;
    property MaxRow: Integer dispid 19;
    property TopRow: Integer dispid 20;
    property AllowResize: WordBool dispid 21;
    property AllowSelections: WordBool dispid 22;
    property AllowFormulas: WordBool dispid 23;
    property AllowInCellEditing: WordBool dispid 24;
    property ShowVScrollBar: F1ShowOffOnAutoConstants dispid 25;
    property AllowFillRange: WordBool dispid 26;
    property AllowMoveRange: WordBool dispid 27;
    property SelStartCol: Integer dispid 28;
    property SelStartRow: Integer dispid 29;
    property SelEndCol: Integer dispid 30;
    property SelEndRow: Integer dispid 31;
    property ExtraColor: OLE_COLOR dispid 32;
    property FileName: WideString dispid 33;
    property AutoRecalc: WordBool dispid 34;
    property PrintGridLines: WordBool dispid 35;
    property PrintRowHeading: WordBool dispid 36;
    property PrintHCenter: WordBool dispid 37;
    property PrintVCenter: WordBool dispid 38;
    property PrintLeftToRight: WordBool dispid 39;
    property PrintHeader: WideString dispid 40;
    property PrintFooter: WideString dispid 41;
    property PrintLeftMargin: Double dispid 42;
    property PrintTopMargin: Double dispid 43;
    property PrintRightMargin: Double dispid 44;
    property PrintBottomMargin: Double dispid 45;
    property PrintArea: WideString dispid 46;
    property PrintTitles: WideString dispid 47;
    property PrintNoColor: WordBool dispid 48;
    property Selection: WideString dispid 49;
    property TableName: WideString dispid 50;
    property DoCancelEdit: WordBool dispid 51;
    property DoSelChange: WordBool dispid 52;
    property DoStartEdit: WordBool dispid 53;
    property DoEndEdit: WordBool dispid 54;
    property DoStartRecalc: WordBool dispid 55;
    property DoEndRecalc: WordBool dispid 56;
    property DoClick: WordBool dispid 57;
    property DoDblClick: WordBool dispid 58;
    property ShowColHeading: WordBool dispid 59;
    property PrintColHeading: WordBool dispid 60;
    property Entry: WideString dispid 61;
    property Repaint: WordBool dispid 62;
    property AllowArrows: WordBool dispid 63;
    property AllowTabs: WordBool dispid 64;
    property FormattedText: WideString dispid 65;
    property RowMode: WordBool dispid 66;
    property AllowDelete: WordBool dispid 67;
    property EnableProtection: WordBool dispid 68;
    property MinCol: Integer dispid 69;
    property MinRow: Integer dispid 70;
    property DoTopLeftChanged: WordBool dispid 71;
    property AllowEditHeaders: WordBool dispid 72;
    property DoObjClick: WordBool dispid 73;
    property DoObjDblClick: WordBool dispid 74;
    property AllowObjSelections: WordBool dispid 75;
    property DoRClick: WordBool dispid 76;
    property DoRDblClick: WordBool dispid 77;
    property Clip: WideString dispid 78;
    property ClipValues: WideString dispid 79;
    property PrintLandscape: WordBool dispid 80;
    property Enabled: WordBool dispid -514;
    property BorderStyle: F1BookBorderConstants dispid -504;
    property AppName: WideString dispid 81;
    property HdrHeight: Smallint dispid 82;
    property HdrWidth: Smallint dispid 83;
    property NumberFormat: WideString dispid 84;
    property TopLeftText: WideString dispid 85;
    property EnterMovesDown: WordBool dispid 86;
    property LastCol: Integer dispid 87;
    property LastRow: Integer dispid 88;
    property Logical: WordBool dispid 89;
    property Mode: F1ModeConstants dispid 90;
    property PolyEditMode: F1PolyEditModeConstants dispid 91;
    property ViewScale: Smallint dispid 92;
    property SelectionCount: Smallint dispid 93;
    property Title: WideString dispid 94;
    property Type_: Smallint dispid 95;
    property ShowFormulas: WordBool dispid 96;
    property ShowZeroValues: WordBool dispid 97;
    property DoObjValueChanged: WordBool dispid 99;
    property ScrollToLastRC: WordBool dispid 100;
    property Modified: WordBool dispid 101;
    property DoObjGotFocus: WordBool dispid 102;
    property DoObjLostFocus: WordBool dispid 103;
    property PrintDevMode: OLE_HANDLE dispid 104;
    property NumSheets: Integer dispid 105;
    property Sheet: Integer dispid 106;
    property ColWidthUnits: F1ColWidthUnitsConstants dispid 107;
    property ShowTypeMarkers: WordBool dispid 108;
    property ShowTabs: F1ShowTabsConstants dispid 109;
    property ShowEditBar: WordBool dispid 110;
    property ShowEditBarCellRef: WordBool dispid 111;
    property AllowDesigner: WordBool dispid 1;
    property hWnd: OLE_HANDLE dispid -515;
    property AllowAutoFill: WordBool dispid 112;
    property Compressed: WordBool dispid 299;
    property FontName: WideString dispid 1300;
    property FontSize: Smallint dispid 1301;
    property FontBold: WordBool dispid 1302;
    property FontItalic: WordBool dispid 1303;
    property FontUnderline: WordBool dispid 1304;
    property FontStrikeout: WordBool dispid 1305;
    property FontColor: OLE_COLOR dispid 1306;
    property FontCharSet: F1CharSetConstants dispid 1433;
    property HAlign: F1HAlignConstants dispid 1307;
    property WordWrap: WordBool dispid 1308;
    property VAlign: F1VAlignConstants dispid 1309;
    property LaunchWorkbookDesigner: WordBool dispid 1310;
    property PrintHeaderMargin: Double dispid 1311;
    property PrintFooterMargin: Double dispid 1312;
    property FormulaLocal: WideString dispid 1326;
    property NumberFormatLocal: WideString dispid 1330;
    property SelectionLocal: WideString dispid 1331;
    property DataTransferRange: WideString dispid 1334;
    property CanEditPaste: WordBool dispid 1344;
    property ObjPatternStyle: Smallint dispid 1354;
    property ObjPatternFG: OLE_COLOR dispid 1355;
    property ObjPatternBG: OLE_COLOR dispid 1356;
    property DefaultFontName: WideString dispid 1361;
    property DefaultFontSize: Smallint dispid 1362;
    property SelHdrRow: WordBool dispid 1363;
    property SelHdrCol: WordBool dispid 1364;
    property SelHdrTopLeft: WordBool dispid 1365;
    property IterationEnabled: WordBool dispid 1366;
    property IterationMax: Smallint dispid 1367;
    property IterationMaxChange: Double dispid 1368;
    property PrintScale: Smallint dispid 1389;
    property PrintScaleFitToPage: WordBool dispid 1390;
    property PrintScaleFitVPages: Integer dispid 1392;
    property PrintScaleFitHPages: Integer dispid 1391;
    property LineStyle: Smallint dispid 1395;
    property LineColor: OLE_COLOR dispid 1396;
    property LineWeight: Smallint dispid 1397;
    property ODBCSQLState: WideString dispid 1403;
    property ODBCNativeError: Integer dispid 1404;
    property ODBCErrorMsg: WideString dispid 1405;
    property DataTransferHeadings: WordBool dispid 1413;
    property FormatPaintMode: WordBool dispid 1420;
    property CanEditPasteSpecial: WordBool dispid 1421;
    property PrecisionAsDisplayed: WordBool dispid 1427;
    property DoSafeEvents: WordBool dispid 1430;
    property DefaultFontCharSet: F1CharSetConstants dispid 1436;
    property WantAllWindowInfoChanges: WordBool dispid 1440;
    property URL: WideString dispid 1441;
    property MousePointer: F1MousePointerConstants dispid -521;
    property MouseIcon: IPictureDisp dispid -522;
    property DataLossIsError: WordBool dispid 1444;
    property MinimalRecalc: WordBool dispid 1445;
    property AllowCellTextDlg: WordBool dispid 1446;
    property ShowLockedCellsError: WordBool dispid 1447;
    property PrintDevNames: OLE_HANDLE dispid 1450;
    property PrintCopies: Smallint dispid 1456;
    property AddInCount: Smallint dispid 1461;
    property AllowFormatByEntry: WordBool dispid 1462;
    property NumberRC[nRow: Integer; nCol: Integer]: Double dispid 279;
    procedure FormatCellsDlg(Pages: Integer); dispid 1350;
    property ColText[nCol: Integer]: WideString dispid 272;
    property DefinedName[const Name: WideString]: WideString dispid 273;
    property EntryRC[nRow: Integer; nCol: Integer]: WideString dispid 274;
    property FormattedTextRC[nRow: Integer; nCol: Integer]: WideString readonly dispid 275;
    property FormulaRC[nRow: Integer; nCol: Integer]: WideString dispid 276;
    property LastColForRow[nRow: Integer]: Integer readonly dispid 277;
    property LogicalRC[nRow: Integer; nCol: Integer]: WordBool dispid 278;
    property RowText[nRow: Integer]: WideString dispid 280;
    property TextRC[nRow: Integer; nCol: Integer]: WideString dispid 281;
    property TypeRC[nRow: Integer; nCol: Integer]: Smallint readonly dispid 282;
    property ObjCellType[ObjID: Integer]: F1ControlCellConstants dispid 1369;
    property ObjCellRow[ObjID: Integer]: Integer dispid 1370;
    property ObjCellCol[ObjID: Integer]: Integer dispid 1371;
    property ObjSelection[nSelection: Smallint]: Integer readonly dispid 1372;
    procedure EditPasteValues; dispid 113;
    procedure GetAlignment(out pHorizontal: Smallint; out pWordWrap: WordBool; 
                           out pVertical: Smallint; out pOrientation: Smallint); dispid 114;
    procedure GetBorder(out pLeft: Smallint; out pRight: Smallint; out pTop: Smallint; 
                        out pBottom: Smallint; out pShade: Smallint; out pcrLeft: Integer; 
                        out pcrRight: Integer; out pcrTop: Integer; out pcrBottom: Integer); dispid 115;
    procedure GetFont(out pName: WideString; out pSize: Smallint; out pBold: WordBool; 
                      out pItalic: WordBool; out pUnderline: WordBool; out pStrikeout: WordBool; 
                      out pcrColor: Integer; out pOutline: WordBool; out pShadow: WordBool); dispid 116;
    procedure GetLineStyle(out pStyle: Smallint; out pcrColor: Integer; out pWeight: Smallint); dispid 117;
    procedure GetPattern(out pPattern: Smallint; out pcrFG: Integer; out pcrBG: Integer); dispid 118;
    procedure GetProtection(out pLocked: WordBool; out pHidden: WordBool); dispid 119;
    procedure GetTabbedText(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                            bValuesOnly: WordBool; out phText: OLE_HANDLE); dispid 120;
    procedure SetTabbedText(nStartRow: Integer; nStartCol: Integer; out pRows: Integer; 
                            out pCols: Integer; bValuesOnly: WordBool; const pText: WideString); dispid 121;
    procedure AddColPageBreak(nCol: Integer); dispid 122;
    procedure AddPageBreak; dispid 123;
    procedure AddRowPageBreak(nRow: Integer); dispid 124;
    procedure AddSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer); dispid 125;
    procedure Attach(const Title: WideString); dispid 126;
    procedure AttachToSS(hSrcSS: Integer); dispid 127;
    procedure CalculationDlg; dispid 128;
    procedure CancelEdit; dispid 129;
    procedure CheckRecalc; dispid 130;
    procedure ClearClipboard; dispid 131;
    procedure ClearRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                         ClearType: F1ClearTypeConstants); dispid 132;
    procedure ColorPaletteDlg; dispid 133;
    procedure ColWidthDlg; dispid 134;
    procedure CopyAll(hSrcSS: Integer); dispid 135;
    procedure CopyRange(nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; nDstC2: Integer; 
                        hSrcSS: Integer; nSrcR1: Integer; nSrcC1: Integer; nSrcR2: Integer; 
                        nSrcC2: Integer); dispid 136;
    procedure DefinedNameDlg; dispid 137;
    procedure DeleteDefinedName(const pName: WideString); dispid 138;
    procedure DeleteRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          ShiftType: F1ShiftTypeConstants); dispid 139;
    procedure Draw(hDC: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                   nRow: Integer; nCol: Integer; out pRows: Integer; out pCols: Integer; 
                   nFixedRow: Integer; nFixedCol: Integer; nFixedRows: Integer; nFixedCols: Integer); dispid 140;
    procedure EditClear(ClearType: F1ClearTypeConstants); dispid 141;
    procedure EditCopy; dispid 142;
    procedure EditCopyDown; dispid 143;
    procedure EditCopyRight; dispid 144;
    procedure EditCut; dispid 145;
    procedure EditDelete(ShiftType: F1ShiftTypeConstants); dispid 146;
    procedure EditInsert(InsertType: F1ShiftTypeConstants); dispid 147;
    procedure EditPaste; dispid 148;
    procedure EndEdit; dispid 149;
    procedure FilePageSetupDlg; dispid 150;
    procedure FilePrint(bShowPrintDlg: WordBool); dispid 151;
    procedure FilePrintSetupDlg; dispid 152;
    procedure FormatAlignmentDlg; dispid 153;
    procedure FormatBorderDlg; dispid 154;
    procedure FormatCurrency0; dispid 155;
    procedure FormatCurrency2; dispid 156;
    procedure FormatDefaultFontDlg; dispid 157;
    procedure FormatFixed; dispid 158;
    procedure FormatFixed2; dispid 159;
    procedure FormatFontDlg; dispid 160;
    procedure FormatFraction; dispid 161;
    procedure FormatGeneral; dispid 162;
    procedure FormatHmmampm; dispid 163;
    procedure FormatMdyy; dispid 164;
    procedure FormatNumberDlg; dispid 165;
    procedure FormatPatternDlg; dispid 166;
    procedure FormatPercent; dispid 167;
    procedure FormatScientific; dispid 168;
    procedure GetActiveCell(out pRow: Integer; out pCol: Integer); dispid 169;
    property ColWidth[nCol: Integer]: Smallint dispid 283;
    property RowHeight[nRow: Integer]: Smallint dispid 284;
    procedure GetDefaultFont(out pBuf: WideString; out pSize: Smallint); dispid 170;
    procedure GetHdrSelection(out pTopLeftHdr: WordBool; out pRowHdr: WordBool; 
                              out pColHdr: WordBool); dispid 171;
    procedure GetIteration(out pIteration: WordBool; out pMaxIterations: Smallint; 
                           out pMaxChange: Double); dispid 172;
    procedure GetPrintScale(out pScale: Smallint; out pFitToPage: WordBool; out pVPages: Integer; 
                            out pHPages: Integer); dispid 173;
    procedure GetSelection(nSelection: Smallint; out pR1: Integer; out pC1: Integer; 
                           out pR2: Integer; out pC2: Integer); dispid 174;
    procedure GotoDlg; dispid 175;
    procedure HeapMin; dispid 176;
    procedure InitTable; dispid 177;
    procedure InsertRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          InsertType: F1ShiftTypeConstants); dispid 178;
    procedure LineStyleDlg; dispid 179;
    procedure MoveRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                        nRowOffset: Integer; nColOffset: Integer); dispid 180;
    procedure ObjAddItem(ObjID: Integer; const ItemText: WideString); dispid 181;
    procedure ObjAddSelection(ObjID: Integer); dispid 182;
    procedure ObjBringToFront; dispid 183;
    procedure ObjDeleteItem(ObjID: Integer; nItem: Smallint); dispid 184;
    procedure ObjGetCell(ObjID: Integer; out pControlCellType: Smallint; out pRow: Integer; 
                         out pCol: Integer); dispid 185;
    procedure ObjGetPos(ObjID: Integer; out pX1: Single; out pY1: Single; out pX2: Single; 
                        out pY2: Single); dispid 186;
    procedure ObjGetSelection(nSelection: Smallint; out pID: Integer); dispid 187;
    procedure ObjInsertItem(ObjID: Integer; nItem: Smallint; const ItemText: WideString); dispid 188;
    procedure ObjNameDlg; dispid 189;
    procedure ObjNew(ObjType: Smallint; nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                     out pID: Integer); dispid 190;
    procedure ObjNewPicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pID: Integer; 
                            hMF: OLE_HANDLE; nMapMode: Integer; nWndExtentX: Integer; 
                            nWndExtentY: Integer); dispid 191;
    procedure ObjOptionsDlg; dispid 192;
    procedure ObjPosToTwips(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pX: Integer; 
                            out pY: Integer; out pCX: Integer; out pCY: Integer; 
                            out pShown: Smallint); dispid 193;
    procedure ObjSendToBack; dispid 194;
    procedure ObjSetCell(ObjID: Integer; CellType: Smallint; nRow: Integer; nCol: Integer); dispid 195;
    procedure ObjSetPicture(ObjID: Integer; hMF: OLE_HANDLE; nMapMode: Smallint; 
                            nWndExtentX: Integer; nWndExtentY: Integer); dispid 196;
    procedure ObjSetPos(ObjID: Integer; nX1: Single; nY1: Single; nX2: Single; nY2: Single); dispid 197;
    procedure ObjSetSelection(ObjID: Integer); dispid 198;
    procedure OpenFileDlg(const pTitle: WideString; hWndParent: OLE_HANDLE; out pBuf: WideString); dispid 199;
    procedure ProtectionDlg; dispid 200;
    procedure RangeToTwips(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                           out pX: Integer; out pY: Integer; out pCX: Integer; out pCY: Integer; 
                           out pShown: Smallint); dispid 201;
    procedure Read(const pPathName: WideString; out pFileType: Smallint); dispid 202;
    procedure ReadFromBlob(hBlob: OLE_HANDLE; nReservedBytes: Smallint); dispid 203;
    procedure Recalc; dispid 204;
    procedure RemoveColPageBreak(nCol: Integer); dispid 205;
    procedure RemovePageBreak; dispid 206;
    procedure RemoveRowPageBreak(nRow: Integer); dispid 207;
    procedure RowHeightDlg; dispid 208;
    procedure SaveFileDlg(const pTitle: WideString; out pBuf: WideString; out pFileType: Smallint); dispid 209;
    procedure SaveWindowInfo; dispid 210;
    procedure SetActiveCell(nRow: Integer; nCol: Integer); dispid 211;
    procedure SetAlignment(HAlign: Smallint; bWordWrap: WordBool; VAlign: Smallint; 
                           nOrientation: Smallint); dispid 212;
    procedure SetBorder(nOutline: Smallint; nLeft: Smallint; nRight: Smallint; nTop: Smallint; 
                        nBottom: Smallint; nShade: Smallint; crOutline: OLE_COLOR; 
                        crLeft: OLE_COLOR; crRight: OLE_COLOR; crTop: OLE_COLOR; crBottom: OLE_COLOR); dispid 213;
    procedure SetColWidth(nCol1: Integer; nCol2: Integer; nWidth: Smallint; bDefColWidth: WordBool); dispid 214;
    procedure SetColWidthAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                              bSetDefaults: WordBool); dispid 215;
    procedure SetDefaultFont(const Name: WideString; nSize: Smallint); dispid 216;
    procedure SetFont(const pName: WideString; nSize: Smallint; bBold: WordBool; bItalic: WordBool; 
                      bUnderline: WordBool; bStrikeout: WordBool; crColor: OLE_COLOR; 
                      bOutline: WordBool; bShadow: WordBool); dispid 217;
    procedure SetHdrSelection(bTopLeftHdr: WordBool; bRowHdr: WordBool; bColHdr: WordBool); dispid 218;
    procedure SetIteration(bIteration: WordBool; nMaxIterations: Smallint; nMaxChange: Double); dispid 219;
    procedure SetLineStyle(nStyle: Smallint; crColor: OLE_COLOR; nWeight: Smallint); dispid 220;
    procedure SetPattern(nPattern: Smallint; crFG: OLE_COLOR; crBG: OLE_COLOR); dispid 221;
    procedure SetPrintAreaFromSelection; dispid 222;
    procedure SetPrintScale(nScale: Smallint; bFitToPage: WordBool; nVPages: Smallint; 
                            nHPages: Smallint); dispid 223;
    procedure SetPrintTitlesFromSelection; dispid 224;
    procedure SetProtection(bLocked: WordBool; bHidden: WordBool); dispid 225;
    procedure SetRowHeight(nRow1: Integer; nRow2: Integer; nHeight: Smallint; 
                           bDefRowHeight: WordBool); dispid 226;
    procedure SetRowHeightAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                               bSetDefaults: WordBool); dispid 227;
    procedure SetSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer); dispid 228;
    procedure ShowActiveCell; dispid 229;
    procedure Sort3(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                    bSortByRows: WordBool; nKey1: Integer; nKey2: Integer; nKey3: Integer); dispid 230;
    procedure SortDlg; dispid 231;
    procedure StartEdit(bClear: WordBool; bInCellEditFocus: WordBool; bArrowsExitEditMode: WordBool); dispid 232;
    procedure SwapTables(hSS2: OLE_HANDLE); dispid 233;
    procedure TransactCommit; dispid 234;
    procedure TransactRollback; dispid 235;
    procedure TransactStart; dispid 236;
    procedure TwipsToRC(x: Integer; y: Integer; out pRow: Integer; out pCol: Integer); dispid 237;
    procedure SSUpdate; dispid 238;
    function  SSVersion: Smallint; dispid 239;
    procedure Write(const PathName: WideString; FileType: Smallint); dispid 240;
    procedure WriteToBlob(out phBlob: OLE_HANDLE; nReservedBytes: Smallint); dispid 241;
    procedure SetRowHidden(nRow1: Integer; nRow2: Integer; bHidden: WordBool); dispid 242;
    procedure SetColHidden(nCol1: Integer; nCol2: Integer; bHidden: WordBool); dispid 243;
    procedure SetColWidthTwips(nCol1: Integer; nCol2: Integer; nWidth: Smallint; 
                               bDefColWidth: WordBool); dispid 244;
    property DefinedNameByIndex[nName: Smallint]: WideString readonly dispid 285;
    property SheetName[nSheet: Smallint]: WideString dispid 286;
    property PaletteEntry[nEntry: Integer]: OLE_COLOR dispid 287;
    procedure EditInsertSheets; dispid 245;
    procedure EditDeleteSheets; dispid 246;
    procedure InsertSheets(nSheet: Integer; nSheets: Integer); dispid 247;
    procedure DeleteSheets(nSheet: Integer; nSheets: Integer); dispid 248;
    procedure Refresh; dispid -550;
    property ColWidthTwips[nCol: Integer]: Smallint dispid 288;
    function  NextColPageBreak(Col: Integer): Integer; dispid 249;
    function  NextRowPageBreak(Row: Integer): Integer; dispid 250;
    function  ObjFirstID: Integer; dispid 251;
    function  ObjNextID(ObjID: Integer): Integer; dispid 252;
    function  ObjGetItemCount(ObjID: Integer): Smallint; dispid 253;
    function  ObjGetType(ObjID: Integer): F1ObjTypeConstants; dispid 254;
    function  ObjGetSelectionCount: Smallint; dispid 255;
    function  FormatRCNr(Row: Integer; Col: Integer; DoAbsolute: WordBool): WideString; dispid 256;
    function  SS: Integer; dispid 257;
    property ObjItem[ObjID: Integer; nItem: Smallint]: WideString dispid 289;
    property ObjItems[ObjID: Integer]: WideString dispid 290;
    property ObjName[ObjID: Integer]: WideString dispid 291;
    property ObjText[ObjID: Integer]: WideString dispid 292;
    property ObjValue[ObjID: Integer]: Smallint dispid 293;
    property ObjVisible[ObjID: Integer]: WordBool dispid 294;
    function  ObjNameToID(const Name: WideString): Integer; dispid 259;
    function  DefinedNameCount: Integer; dispid 260;
    property AutoFillItems[nIndex: Smallint]: WideString dispid 295;
    procedure ValidationRuleDlg; dispid 261;
    procedure SetValidationRule(const Rule: WideString; const Text: WideString); dispid 262;
    procedure GetValidationRule(out Rule: WideString; out Text: WideString); dispid 263;
    function  AutoFillItemsCount: Smallint; dispid 264;
    procedure CopyRangeEx(nDstSheet: Integer; nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; 
                          nDstC2: Integer; hSrcSS: Integer; nSrcSheet: Integer; nSrcR1: Integer; 
                          nSrcC1: Integer; nSrcR2: Integer; nSrcC2: Integer); dispid 265;
    procedure Sort(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; bSortByRows: WordBool; 
                   Keys: OleVariant); dispid 266;
    property ColHidden[nCol: Integer]: WordBool dispid 296;
    property RowHidden[nRow: Integer]: WordBool dispid 297;
    procedure DeleteAutoFillItems(nIndex: Smallint); dispid 267;
    procedure ODBCConnect(var pConnect: WideString; bShowErrors: WordBool; out pRetCode: Smallint); dispid 268;
    procedure ODBCDisconnect; dispid 269;
    procedure ODBCQuery(var pQuery: WideString; nRow: Integer; nCol: Integer; 
                        bForceShowDlg: WordBool; var pSetColNames: WordBool; 
                        var pSetColFormats: WordBool; var pSetColWidths: WordBool; 
                        var pSetMaxRC: WordBool; out pRetCode: Smallint); dispid 270;
    property SheetSelected[nSheet: Integer]: WordBool dispid 298;
    procedure LaunchDesigner; dispid 271;
    procedure AboutBox; dispid -552;
    procedure PrintPreviewDC(hDC: OLE_HANDLE; nPage: Smallint; out pPages: Smallint); dispid 1313;
    procedure PrintPreview(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                           nPage: Smallint; out pPages: Smallint); dispid 1314;
    property EntrySRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1315;
    property FormattedTextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString readonly dispid 1316;
    property FormulaSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1317;
    property LogicalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WordBool dispid 1318;
    property NumberSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Double dispid 1319;
    property TextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1320;
    property TypeSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Smallint readonly dispid 1321;
    procedure WriteRange(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; FileType: Smallint); dispid 1322;
    procedure InsertHTML(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; bDataOnly: WordBool; 
                         const pAnchorName: WideString); dispid 1323;
    procedure FilePrintEx(bShowPrintDlg: WordBool; bPrintWorkbook: WordBool); dispid 1324;
    procedure FilePrintPreview; dispid 1325;
    property FormulaLocalRC[nRow: Integer; nCol: Integer]: WideString dispid 1327;
    property FormulaLocalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1328;
    property DefinedNameLocal[const Name: WideString]: WideString dispid 1329;
    procedure CopyDataFromArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                                nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant); dispid 1332;
    procedure CopyDataToArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                              nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant); dispid 1333;
    procedure FindDlg; dispid 1335;
    procedure ReplaceDlg; dispid 1336;
    procedure Find(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; nCol1: Integer; 
                   nRow2: Integer; nCol2: Integer; Flags: Smallint; out pFound: Integer); dispid 1337;
    procedure Replace(const FindWhat: WideString; const ReplaceWith: WideString; nSheet: Integer; 
                      nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                      Flags: Smallint; out pFound: Integer; out pReplaced: Integer); dispid 1338;
    procedure ODBCError(out pSQLState: WideString; out pNativeError: Integer; 
                        out pErrorMsg: WideString); dispid 1339;
    procedure ODBCPrepare(const SQLStr: WideString; out pRetCode: Smallint); dispid 1340;
    procedure ODBCBindParameter(nParam: Integer; nCol: Integer; CDataType: Smallint; 
                                out pRetCode: Smallint); dispid 1341;
    procedure ODBCExecute(nRow1: Integer; nRow2: Integer; out pRetCode: Smallint); dispid 1342;
    procedure InsertDlg; dispid 1343;
    procedure ObjNewPolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; out pID: Integer; 
                            ArrayX: OleVariant; ArrayY: OleVariant; bClosed: WordBool); dispid 1345;
    procedure ObjSetPolygonPoints(nID: Integer; ArrayX: OleVariant; ArrayY: OleVariant; 
                                  bClosed: WordBool); dispid 1346;
    procedure DefRowHeightDlg; dispid 1347;
    procedure DefColWidthDlg; dispid 1348;
    procedure DeleteDlg; dispid 1349;
    procedure FormatObjectDlg(Pages: Integer); dispid 1351;
    procedure OptionsDlg(Pages: Integer); dispid 1353;
    procedure FormatSheetDlg(Pages: Integer; bDesignerMode: WordBool); dispid 1352;
    function  GetTabbedTextEx(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                              bValuesOnly: WordBool): WideString; dispid 1359;
    function  SetTabbedTextEx(nStartRow: Integer; nStartCol: Integer; bValuesOnly: WordBool; 
                              const pText: WideString): IF1RangeRef; dispid 1360;
    function  ObjCreate(ObjType: F1ObjTypeConstants; nX1: Single; nY1: Single; nX2: Single; 
                        nY2: Single): Integer; dispid 1373;
    function  ObjCreatePicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; hMF: OLE_HANDLE; 
                               nMapMode: Integer; nWndExtentX: Integer; nWndExtentY: Integer): Integer; dispid 1374;
    function  ReadEx(const pPathName: WideString): F1FileTypeConstants; dispid 1375;
    function  WriteToBlobEx(nReservedBytes: Smallint): OLE_HANDLE; dispid 1376;
    function  ObjCreatePolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; ArrayX: OleVariant; 
                               ArrayY: OleVariant; bClosed: WordBool): Integer; dispid 1377;
    function  ObjGetPosEx(ObjID: Integer): IF1ObjPos; dispid 1378;
    function  ObjPosShown(X1: Single; Y1: Single; X2: Single; Y2: Single): Smallint; dispid 1379;
    property SelectionEx[nSelection: Smallint]: IF1RangeRef readonly dispid 1380;
    function  ObjPosToTwipsEx(X1: Single; Y1: Single; X2: Single; Y2: Single): IF1Rect; dispid 1381;
    function  RangeToTwipsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect; dispid 1382;
    function  RangeShown(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer): Smallint; dispid 1383;
    function  TwipsToRow(nTwips: Integer): Integer; dispid 1384;
    function  TwipsToCol(nTwips: Integer): Integer; dispid 1385;
    function  PrintPreviewDCEx(hDC: OLE_HANDLE; nPage: Smallint): Smallint; dispid 1386;
    function  PrintPreviewEx(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                             nPage: Smallint): Smallint; dispid 1387;
    procedure SaveFileDlgEx(const Title: WideString; const pFileSpec: IF1FileSpec); dispid 1388;
    procedure ODBCConnectEx(const pConnectObj: IF1ODBCConnect; bShowErrors: WordBool); dispid 1401;
    procedure ODBCQueryEx(const pQueryObj: IF1ODBCQuery; nRow: Integer; nCol: Integer; 
                          bForceShowDlg: WordBool); dispid 1402;
    function  ODBCPrepareEx(const SQLStr: WideString): Smallint; dispid 1406;
    function  ODBCBindParameterEx(nParam: Integer; nCol: Integer; CDataType: F1CDataTypesConstants): Smallint; dispid 1407;
    function  ODBCExecuteEx(nRow1: Integer; nRow2: Integer): Smallint; dispid 1408;
    function  FindEx(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; nCol1: Integer; 
                     nRow2: Integer; nCol2: Integer; Flags: Smallint): Integer; dispid 1409;
    function  ReplaceEx(const FindWhat: WideString; const ReplaceWith: WideString; nSheet: Integer; 
                        nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                        Flags: Smallint): IF1ReplaceResults; dispid 1410;
    function  ODBCQueryKludge: IF1ODBCQuery; dispid 1411;
    function  ODBCConnectKludge: IF1ODBCConnect; dispid 1412;
    function  OpenFileDlgEx(const pTitle: WideString; hWndParent: OLE_HANDLE): WideString; dispid 1414;
    function  CreateBookView: IF1BookView; dispid 1416;
    function  FileSpecKludge: IF1FileSpec; dispid 1419;
    procedure EditPasteSpecial(PasteWhat: F1PasteWhatConstants; PasteOp: F1PasteOpConstants); dispid 1422;
    procedure PasteSpecialDlg; dispid 1423;
    function  GetFirstNumberFormat: IF1NumberFormat; dispid 1424;
    procedure GetNextNumberFormat(const pNumberFormat: IF1NumberFormat); dispid 1425;
    function  RangeToPixelsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect; dispid 1426;
    procedure WriteEx(const PathName: WideString; FileType: F1FileTypeConstants); dispid 1428;
    procedure WriteRangeEx(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                           nCol2: Integer; const pPathName: WideString; 
                           FileType: F1FileTypeConstants); dispid 1429;
    procedure GetFontEx(out pName: WideString; out pCharSet: F1CharSetConstants; 
                        out pSize: Smallint; out pBold: WordBool; out pItalic: WordBool; 
                        out pUnderline: WordBool; out pStrikeout: WordBool; out pcrColor: Integer; 
                        out pOutline: WordBool; out pShadow: WordBool); dispid 1431;
    procedure SetFontEx(const pName: WideString; CharSet: F1CharSetConstants; nSize: Smallint; 
                        bBold: WordBool; bItalic: WordBool; bUnderline: WordBool; 
                        bStrikeout: WordBool; crColor: OLE_COLOR; bOutline: WordBool; 
                        bShadow: WordBool); dispid 1432;
    procedure GetDefaultFontEx(out pBuf: WideString; out pCharSet: F1CharSetConstants; 
                               out pSize: Smallint); dispid 1434;
    procedure SetDefaultFontEx(const Name: WideString; CharSet: F1CharSetConstants; nSize: Smallint); dispid 1435;
    function  CreateNewCellFormat: IF1CellFormat; dispid 1437;
    function  GetCellFormat: IF1CellFormat; dispid 1438;
    procedure SetCellFormat(const CellFormat: IF1CellFormat); dispid 1439;
    function  ErrorNumberToText(SSError: Integer): WideString; dispid 258;
    function  DefineSearch(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; 
                           nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint): IF1FindReplaceInfo; dispid 1448;
    procedure SetDevNames(const DriverName: WideString; const DeviceName: WideString; 
                          const Port: WideString); dispid 1451;
    procedure FilePageSetupDlgEx(Pages: Integer); dispid 1452;
    function  CreateNewPageSetup: IF1PageSetup; dispid 1453;
    function  GetPageSetup: IF1PageSetup; dispid 1454;
    procedure SetPageSetup(const PageSetup: IF1PageSetup); dispid 1455;
    procedure AddInDlg; dispid 1457;
    function  LoadAddIn(const Path: WideString; bEnabled: WordBool): Smallint; dispid 1458;
    property AddInPath[nAddIn: Smallint]: WideString readonly dispid 1459;
    property AddInEnabled[nAddIn: Smallint]: WordBool dispid 1460;
  end;

// *********************************************************************//
// DispIntf:  DF1Events
// Flags:     (4112) Hidden Dispatchable
// GUID:      {B0475002-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  DF1Events = dispinterface
    ['{B0475002-7740-11D1-BDC3-0020AF9F8E6E}']
    procedure Click(nRow: Integer; nCol: Integer); dispid 1;
    procedure DblClick(nRow: Integer; nCol: Integer); dispid 2;
    procedure CancelEdit; dispid 3;
    procedure SelChange; dispid 4;
    procedure StartEdit(var EditString: WideString; var Cancel: Smallint); dispid 5;
    procedure SafeStartEdit(var EditString: IF1EventArg; var CancelFlag: IF1EventArg); dispid 22;
    procedure EndEdit(var EditString: WideString; var Cancel: Smallint); dispid 6;
    procedure SafeEndEdit(var EditString: IF1EventArg; var CancelFlag: IF1EventArg); dispid 23;
    procedure StartRecalc; dispid 7;
    procedure EndRecalc; dispid 8;
    procedure TopLeftChanged; dispid 9;
    procedure ObjClick(var ObjName: WideString; ObjID: Integer); dispid 10;
    procedure ObjDblClick(var ObjName: WideString; ObjID: Integer); dispid 11;
    procedure RClick(nRow: Integer; nCol: Integer); dispid 12;
    procedure RDblClick(nRow: Integer; nCol: Integer); dispid 13;
    procedure ObjValueChanged(var ObjName: WideString; ObjID: Integer); dispid 14;
    procedure Modified; dispid 15;
    procedure MouseDown(Button: Smallint; Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -605;
    procedure MouseUp(Button: Smallint; Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -607;
    procedure MouseMove(Button: Smallint; Shift: Smallint; x: OLE_XPOS_PIXELS; y: OLE_YPOS_PIXELS); dispid -606;
    procedure ObjGotFocus(var ObjName: WideString; ObjID: Integer); dispid 16;
    procedure ObjLostFocus(var ObjName: WideString; ObjID: Integer); dispid 17;
    procedure ValidationFailed(var pEntry: WideString; nSheet: Integer; nRow: Integer; 
                               nCol: Integer; var pShowMessage: WideString; var pAction: Smallint); dispid 18;
    procedure SafeValidationFailed(var EntryString: IF1EventArg; nSheet: Integer; nRow: Integer; 
                                   nCol: Integer; var MessageString: IF1EventArg; 
                                   var Action: IF1EventArg); dispid 24;
    procedure KeyPress(var KeyAscii: Smallint); dispid -603;
    procedure KeyDown(var KeyCode: Smallint; Shift: Smallint); dispid -602;
    procedure KeyUp(var KeyCode: Smallint; Shift: Smallint); dispid -604;
    procedure Found(nSheet: Integer; nRow: Integer; nCol: Integer; var pCancel: Smallint); dispid 19;
    procedure SafeFound(nSheet: Integer; nRow: Integer; nCol: Integer; var CancelFlag: IF1EventArg); dispid 25;
    procedure BeforeReplace(var newString: WideString; nSheet: Integer; nRow: Integer; 
                            nCol: Integer; var pAction: Smallint); dispid 20;
    procedure SafeBeforeReplace(var newString: IF1EventArg; nSheet: Integer; nRow: Integer; 
                                nCol: Integer; var Action: IF1EventArg); dispid 26;
    procedure ODBCExecuteError(nRow: Integer; nCol: Integer; var pAction: Smallint); dispid 21;
    procedure SafeODBCExecuteError(nRow: Integer; nCol: Integer; var Action: IF1EventArg); dispid 27;
  end;

// *********************************************************************//
// DispIntf:  IF1BookView
// Flags:     (4112) Hidden Dispatchable
// GUID:      {B0475032-7740-11D1-BDC3-0020AF9F8E6E}
// *********************************************************************//
  IF1BookView = dispinterface
    ['{B0475032-7740-11D1-BDC3-0020AF9F8E6E}']
    property BackColor: OLE_COLOR dispid 3;
    property Col: Integer dispid 4;
    property Row: Integer dispid 5;
    property ShowHScrollBar: F1ShowOffOnAutoConstants dispid 6;
    property Text: WideString dispid 7;
    property Number: Double dispid 8;
    property Formula: WideString dispid 9;
    property FixedCol: Integer dispid 10;
    property FixedCols: Integer dispid 11;
    property FixedRow: Integer dispid 12;
    property FixedRows: Integer dispid 13;
    property ShowGridLines: WordBool dispid 14;
    property ShowRowHeading: WordBool dispid 15;
    property ShowSelections: F1ShowOffOnAutoConstants dispid 16;
    property LeftCol: Integer dispid 17;
    property MaxCol: Integer dispid 18;
    property MaxRow: Integer dispid 19;
    property TopRow: Integer dispid 20;
    property AllowResize: WordBool dispid 21;
    property AllowSelections: WordBool dispid 22;
    property AllowFormulas: WordBool dispid 23;
    property AllowInCellEditing: WordBool dispid 24;
    property ShowVScrollBar: F1ShowOffOnAutoConstants dispid 25;
    property AllowFillRange: WordBool dispid 26;
    property AllowMoveRange: WordBool dispid 27;
    property SelStartCol: Integer dispid 28;
    property SelStartRow: Integer dispid 29;
    property SelEndCol: Integer dispid 30;
    property SelEndRow: Integer dispid 31;
    property ExtraColor: OLE_COLOR dispid 32;
    property FileName: WideString dispid 33;
    property AutoRecalc: WordBool dispid 34;
    property PrintGridLines: WordBool dispid 35;
    property PrintRowHeading: WordBool dispid 36;
    property PrintHCenter: WordBool dispid 37;
    property PrintVCenter: WordBool dispid 38;
    property PrintLeftToRight: WordBool dispid 39;
    property PrintHeader: WideString dispid 40;
    property PrintFooter: WideString dispid 41;
    property PrintLeftMargin: Double dispid 42;
    property PrintTopMargin: Double dispid 43;
    property PrintRightMargin: Double dispid 44;
    property PrintBottomMargin: Double dispid 45;
    property PrintArea: WideString dispid 46;
    property PrintTitles: WideString dispid 47;
    property PrintNoColor: WordBool dispid 48;
    property Selection: WideString dispid 49;
    property TableName: WideString dispid 50;
    property ShowColHeading: WordBool dispid 59;
    property PrintColHeading: WordBool dispid 60;
    property Entry: WideString dispid 61;
    property Repaint: WordBool dispid 62;
    property AllowArrows: WordBool dispid 63;
    property AllowTabs: WordBool dispid 64;
    property FormattedText: WideString dispid 65;
    property RowMode: WordBool dispid 66;
    property AllowDelete: WordBool dispid 67;
    property EnableProtection: WordBool dispid 68;
    property MinCol: Integer dispid 69;
    property MinRow: Integer dispid 70;
    property AllowEditHeaders: WordBool dispid 72;
    property AllowObjSelections: WordBool dispid 75;
    property Clip: WideString dispid 78;
    property ClipValues: WideString dispid 79;
    property PrintLandscape: WordBool dispid 80;
    property AppName: WideString dispid 81;
    property HdrHeight: Smallint dispid 82;
    property HdrWidth: Smallint dispid 83;
    property NumberFormat: WideString dispid 84;
    property TopLeftText: WideString dispid 85;
    property EnterMovesDown: WordBool dispid 86;
    property LastCol: Integer dispid 87;
    property LastRow: Integer dispid 88;
    property Logical: WordBool dispid 89;
    property ViewScale: Smallint dispid 92;
    property SelectionCount: Smallint dispid 93;
    property Title: WideString dispid 94;
    property Type_: Smallint dispid 95;
    property ShowFormulas: WordBool dispid 96;
    property ShowZeroValues: WordBool dispid 97;
    property ScrollToLastRC: WordBool dispid 100;
    property Modified: WordBool dispid 101;
    property PrintDevMode: OLE_HANDLE dispid 104;
    property NumSheets: Integer dispid 105;
    property Sheet: Integer dispid 106;
    property ColWidthUnits: F1ColWidthUnitsConstants dispid 107;
    property ShowTypeMarkers: WordBool dispid 108;
    property ShowTabs: F1ShowTabsConstants dispid 109;
    property ShowEditBar: WordBool dispid 110;
    property ShowEditBarCellRef: WordBool dispid 111;
    property AllowAutoFill: WordBool dispid 112;
    property Compressed: WordBool dispid 299;
    property FontName: WideString dispid 1300;
    property FontSize: Smallint dispid 1301;
    property FontBold: WordBool dispid 1302;
    property FontItalic: WordBool dispid 1303;
    property FontUnderline: WordBool dispid 1304;
    property FontStrikeout: WordBool dispid 1305;
    property FontColor: OLE_COLOR dispid 1306;
    property FontCharSet: F1CharSetConstants dispid 1433;
    property HAlign: F1HAlignConstants dispid 1307;
    property WordWrap: WordBool dispid 1308;
    property VAlign: F1VAlignConstants dispid 1309;
    property PrintHeaderMargin: Double dispid 1311;
    property PrintFooterMargin: Double dispid 1312;
    property FormulaLocal: WideString dispid 1326;
    property NumberFormatLocal: WideString dispid 1330;
    property SelectionLocal: WideString dispid 1331;
    property DataTransferRange: WideString dispid 1334;
    property CanEditPaste: WordBool dispid 1344;
    property ObjPatternStyle: Smallint dispid 1354;
    property ObjPatternFG: OLE_COLOR dispid 1355;
    property ObjPatternBG: OLE_COLOR dispid 1356;
    property DefaultFontName: WideString dispid 1361;
    property DefaultFontSize: Smallint dispid 1362;
    property SelHdrRow: WordBool dispid 1363;
    property SelHdrCol: WordBool dispid 1364;
    property SelHdrTopLeft: WordBool dispid 1365;
    property IterationEnabled: WordBool dispid 1366;
    property IterationMax: Smallint dispid 1367;
    property IterationMaxChange: Double dispid 1368;
    property PrintScale: Smallint dispid 1389;
    property PrintScaleFitToPage: WordBool dispid 1390;
    property PrintScaleFitVPages: Integer dispid 1392;
    property PrintScaleFitHPages: Integer dispid 1391;
    property LineStyle: Smallint dispid 1395;
    property LineColor: OLE_COLOR dispid 1396;
    property LineWeight: Smallint dispid 1397;
    property ODBCSQLState: WideString dispid 1403;
    property ODBCNativeError: Integer dispid 1404;
    property ODBCErrorMsg: WideString dispid 1405;
    property DataTransferHeadings: WordBool dispid 1413;
    property CanEditPasteSpecial: WordBool dispid 1421;
    property PrecisionAsDisplayed: WordBool dispid 1427;
    property DefaultFontCharSet: F1CharSetConstants dispid 1436;
    property WantAllWindowInfoChanges: WordBool dispid 1440;
    property DataLossIsError: WordBool dispid 1444;
    property MinimalRecalc: WordBool dispid 1445;
    property AllowCellTextDlg: WordBool dispid 1446;
    property ShowLockedCellsError: WordBool dispid 1447;
    property AddInCount: Smallint dispid 1461;
    property NumberRC[nRow: Integer; nCol: Integer]: Double dispid 279;
    property ColText[nCol: Integer]: WideString dispid 272;
    property DefinedName[const Name: WideString]: WideString dispid 273;
    property EntryRC[nRow: Integer; nCol: Integer]: WideString dispid 274;
    property FormattedTextRC[nRow: Integer; nCol: Integer]: WideString readonly dispid 275;
    property FormulaRC[nRow: Integer; nCol: Integer]: WideString dispid 276;
    property LastColForRow[nRow: Integer]: Integer readonly dispid 277;
    property LogicalRC[nRow: Integer; nCol: Integer]: WordBool dispid 278;
    property RowText[nRow: Integer]: WideString dispid 280;
    property TextRC[nRow: Integer; nCol: Integer]: WideString dispid 281;
    property TypeRC[nRow: Integer; nCol: Integer]: Smallint readonly dispid 282;
    property ObjCellType[ObjID: Integer]: F1ControlCellConstants dispid 1369;
    property ObjCellRow[ObjID: Integer]: Integer dispid 1370;
    property ObjCellCol[ObjID: Integer]: Integer dispid 1371;
    property ObjSelection[nSelection: Smallint]: Integer readonly dispid 1372;
    procedure EditPasteValues; dispid 113;
    procedure GetAlignment(out pHorizontal: Smallint; out pWordWrap: WordBool; 
                           out pVertical: Smallint; out pOrientation: Smallint); dispid 114;
    procedure GetBorder(out pLeft: Smallint; out pRight: Smallint; out pTop: Smallint; 
                        out pBottom: Smallint; out pShade: Smallint; out pcrLeft: Integer; 
                        out pcrRight: Integer; out pcrTop: Integer; out pcrBottom: Integer); dispid 115;
    procedure GetFont(out pName: WideString; out pSize: Smallint; out pBold: WordBool; 
                      out pItalic: WordBool; out pUnderline: WordBool; out pStrikeout: WordBool; 
                      out pcrColor: Integer; out pOutline: WordBool; out pShadow: WordBool); dispid 116;
    procedure GetLineStyle(out pStyle: Smallint; out pcrColor: Integer; out pWeight: Smallint); dispid 117;
    procedure GetPattern(out pPattern: Smallint; out pcrFG: Integer; out pcrBG: Integer); dispid 118;
    procedure GetProtection(out pLocked: WordBool; out pHidden: WordBool); dispid 119;
    procedure GetTabbedText(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                            bValuesOnly: WordBool; out phText: OLE_HANDLE); dispid 120;
    procedure SetTabbedText(nStartRow: Integer; nStartCol: Integer; out pRows: Integer; 
                            out pCols: Integer; bValuesOnly: WordBool; const pText: WideString); dispid 121;
    procedure AddColPageBreak(nCol: Integer); dispid 122;
    procedure AddPageBreak; dispid 123;
    procedure AddRowPageBreak(nRow: Integer); dispid 124;
    procedure AddSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer); dispid 125;
    procedure Attach(const Title: WideString); dispid 126;
    procedure AttachToSS(hSrcSS: Integer); dispid 127;
    procedure CheckRecalc; dispid 130;
    procedure ClearClipboard; dispid 131;
    procedure ClearRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                         ClearType: F1ClearTypeConstants); dispid 132;
    procedure CopyAll(hSrcSS: Integer); dispid 135;
    procedure CopyRange(nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; nDstC2: Integer; 
                        hSrcSS: Integer; nSrcR1: Integer; nSrcC1: Integer; nSrcR2: Integer; 
                        nSrcC2: Integer); dispid 136;
    procedure DeleteDefinedName(const pName: WideString); dispid 138;
    procedure DeleteRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          ShiftType: F1ShiftTypeConstants); dispid 139;
    procedure Draw(hDC: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                   nRow: Integer; nCol: Integer; out pRows: Integer; out pCols: Integer; 
                   nFixedRow: Integer; nFixedCol: Integer; nFixedRows: Integer; nFixedCols: Integer); dispid 140;
    procedure EditClear(ClearType: F1ClearTypeConstants); dispid 141;
    procedure EditCopy; dispid 142;
    procedure EditCopyDown; dispid 143;
    procedure EditCopyRight; dispid 144;
    procedure EditCut; dispid 145;
    procedure EditDelete(ShiftType: F1ShiftTypeConstants); dispid 146;
    procedure EditInsert(InsertType: F1ShiftTypeConstants); dispid 147;
    procedure EditPaste; dispid 148;
    procedure FormatCurrency0; dispid 155;
    procedure FormatCurrency2; dispid 156;
    procedure FormatFixed; dispid 158;
    procedure FormatFixed2; dispid 159;
    procedure FormatFraction; dispid 161;
    procedure FormatGeneral; dispid 162;
    procedure FormatHmmampm; dispid 163;
    procedure FormatMdyy; dispid 164;
    procedure FormatPercent; dispid 167;
    procedure FormatScientific; dispid 168;
    procedure GetActiveCell(out pRow: Integer; out pCol: Integer); dispid 169;
    property ColWidth[nCol: Integer]: Smallint dispid 283;
    property RowHeight[nRow: Integer]: Smallint dispid 284;
    procedure GetDefaultFont(out pBuf: WideString; out pSize: Smallint); dispid 170;
    procedure GetHdrSelection(out pTopLeftHdr: WordBool; out pRowHdr: WordBool; 
                              out pColHdr: WordBool); dispid 171;
    procedure GetIteration(out pIteration: WordBool; out pMaxIterations: Smallint; 
                           out pMaxChange: Double); dispid 172;
    procedure GetPrintScale(out pScale: Smallint; out pFitToPage: WordBool; out pVPages: Integer; 
                            out pHPages: Integer); dispid 173;
    procedure GetSelection(nSelection: Smallint; out pR1: Integer; out pC1: Integer; 
                           out pR2: Integer; out pC2: Integer); dispid 174;
    procedure HeapMin; dispid 176;
    procedure InitTable; dispid 177;
    procedure InsertRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          InsertType: F1ShiftTypeConstants); dispid 178;
    procedure MoveRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                        nRowOffset: Integer; nColOffset: Integer); dispid 180;
    procedure ObjAddItem(ObjID: Integer; const ItemText: WideString); dispid 181;
    procedure ObjAddSelection(ObjID: Integer); dispid 182;
    procedure ObjBringToFront; dispid 183;
    procedure ObjDeleteItem(ObjID: Integer; nItem: Smallint); dispid 184;
    procedure ObjGetCell(ObjID: Integer; out pControlCellType: Smallint; out pRow: Integer; 
                         out pCol: Integer); dispid 185;
    procedure ObjGetPos(ObjID: Integer; out pX1: Single; out pY1: Single; out pX2: Single; 
                        out pY2: Single); dispid 186;
    procedure ObjGetSelection(nSelection: Smallint; out pID: Integer); dispid 187;
    procedure ObjInsertItem(ObjID: Integer; nItem: Smallint; const ItemText: WideString); dispid 188;
    procedure ObjNew(ObjType: Smallint; nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                     out pID: Integer); dispid 190;
    procedure ObjNewPicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pID: Integer; 
                            hMF: OLE_HANDLE; nMapMode: Integer; nWndExtentX: Integer; 
                            nWndExtentY: Integer); dispid 191;
    procedure ObjPosToTwips(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pX: Integer; 
                            out pY: Integer; out pCX: Integer; out pCY: Integer; 
                            out pShown: Smallint); dispid 193;
    procedure ObjSendToBack; dispid 194;
    procedure ObjSetCell(ObjID: Integer; CellType: Smallint; nRow: Integer; nCol: Integer); dispid 195;
    procedure ObjSetPicture(ObjID: Integer; hMF: OLE_HANDLE; nMapMode: Smallint; 
                            nWndExtentX: Integer; nWndExtentY: Integer); dispid 196;
    procedure ObjSetPos(ObjID: Integer; nX1: Single; nY1: Single; nX2: Single; nY2: Single); dispid 197;
    procedure ObjSetSelection(ObjID: Integer); dispid 198;
    procedure OpenFileDlg(const pTitle: WideString; hWndParent: OLE_HANDLE; out pBuf: WideString); dispid 199;
    procedure RangeToTwips(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                           out pX: Integer; out pY: Integer; out pCX: Integer; out pCY: Integer; 
                           out pShown: Smallint); dispid 201;
    procedure Read(const pPathName: WideString; out pFileType: Smallint); dispid 202;
    procedure ReadFromBlob(hBlob: OLE_HANDLE; nReservedBytes: Smallint); dispid 203;
    procedure Recalc; dispid 204;
    procedure RemoveColPageBreak(nCol: Integer); dispid 205;
    procedure RemovePageBreak; dispid 206;
    procedure RemoveRowPageBreak(nRow: Integer); dispid 207;
    procedure SaveWindowInfo; dispid 210;
    procedure SetActiveCell(nRow: Integer; nCol: Integer); dispid 211;
    procedure SetAlignment(HAlign: Smallint; bWordWrap: WordBool; VAlign: Smallint; 
                           nOrientation: Smallint); dispid 212;
    procedure SetBorder(nOutline: Smallint; nLeft: Smallint; nRight: Smallint; nTop: Smallint; 
                        nBottom: Smallint; nShade: Smallint; crOutline: OLE_COLOR; 
                        crLeft: OLE_COLOR; crRight: OLE_COLOR; crTop: OLE_COLOR; crBottom: OLE_COLOR); dispid 213;
    procedure SetColWidth(nCol1: Integer; nCol2: Integer; nWidth: Smallint; bDefColWidth: WordBool); dispid 214;
    procedure SetColWidthAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                              bSetDefaults: WordBool); dispid 215;
    procedure SetDefaultFont(const Name: WideString; nSize: Smallint); dispid 216;
    procedure SetFont(const pName: WideString; nSize: Smallint; bBold: WordBool; bItalic: WordBool; 
                      bUnderline: WordBool; bStrikeout: WordBool; crColor: OLE_COLOR; 
                      bOutline: WordBool; bShadow: WordBool); dispid 217;
    procedure SetHdrSelection(bTopLeftHdr: WordBool; bRowHdr: WordBool; bColHdr: WordBool); dispid 218;
    procedure SetIteration(bIteration: WordBool; nMaxIterations: Smallint; nMaxChange: Double); dispid 219;
    procedure SetLineStyle(nStyle: Smallint; crColor: OLE_COLOR; nWeight: Smallint); dispid 220;
    procedure SetPattern(nPattern: Smallint; crFG: OLE_COLOR; crBG: OLE_COLOR); dispid 221;
    procedure SetPrintAreaFromSelection; dispid 222;
    procedure SetPrintScale(nScale: Smallint; bFitToPage: WordBool; nVPages: Smallint; 
                            nHPages: Smallint); dispid 223;
    procedure SetPrintTitlesFromSelection; dispid 224;
    procedure SetProtection(bLocked: WordBool; bHidden: WordBool); dispid 225;
    procedure SetRowHeight(nRow1: Integer; nRow2: Integer; nHeight: Smallint; 
                           bDefRowHeight: WordBool); dispid 226;
    procedure SetRowHeightAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                               bSetDefaults: WordBool); dispid 227;
    procedure SetSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer); dispid 228;
    procedure ShowActiveCell; dispid 229;
    procedure Sort3(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                    bSortByRows: WordBool; nKey1: Integer; nKey2: Integer; nKey3: Integer); dispid 230;
    procedure SwapTables(hSS2: OLE_HANDLE); dispid 233;
    procedure TransactCommit; dispid 234;
    procedure TransactRollback; dispid 235;
    procedure TransactStart; dispid 236;
    procedure TwipsToRC(x: Integer; y: Integer; out pRow: Integer; out pCol: Integer); dispid 237;
    procedure SSUpdate; dispid 238;
    function  SSVersion: Smallint; dispid 239;
    procedure Write(const PathName: WideString; FileType: Smallint); dispid 240;
    procedure WriteToBlob(out phBlob: OLE_HANDLE; nReservedBytes: Smallint); dispid 241;
    procedure SetRowHidden(nRow1: Integer; nRow2: Integer; bHidden: WordBool); dispid 242;
    procedure SetColHidden(nCol1: Integer; nCol2: Integer; bHidden: WordBool); dispid 243;
    procedure SetColWidthTwips(nCol1: Integer; nCol2: Integer; nWidth: Smallint; 
                               bDefColWidth: WordBool); dispid 244;
    property DefinedNameByIndex[nName: Smallint]: WideString readonly dispid 285;
    property SheetName[nSheet: Smallint]: WideString dispid 286;
    property PaletteEntry[nEntry: Integer]: OLE_COLOR dispid 287;
    procedure EditInsertSheets; dispid 245;
    procedure EditDeleteSheets; dispid 246;
    procedure InsertSheets(nSheet: Integer; nSheets: Integer); dispid 247;
    procedure DeleteSheets(nSheet: Integer; nSheets: Integer); dispid 248;
    property ColWidthTwips[nCol: Integer]: Smallint dispid 288;
    function  NextColPageBreak(Col: Integer): Integer; dispid 249;
    function  NextRowPageBreak(Row: Integer): Integer; dispid 250;
    function  ObjFirstID: Integer; dispid 251;
    function  ObjNextID(ObjID: Integer): Integer; dispid 252;
    function  ObjGetItemCount(ObjID: Integer): Smallint; dispid 253;
    function  ObjGetType(ObjID: Integer): F1ObjTypeConstants; dispid 254;
    function  ObjGetSelectionCount: Smallint; dispid 255;
    function  FormatRCNr(Row: Integer; Col: Integer; DoAbsolute: WordBool): WideString; dispid 256;
    function  SS: Integer; dispid 257;
    property ObjItem[ObjID: Integer; nItem: Smallint]: WideString dispid 289;
    property ObjItems[ObjID: Integer]: WideString dispid 290;
    property ObjName[ObjID: Integer]: WideString dispid 291;
    property ObjText[ObjID: Integer]: WideString dispid 292;
    property ObjValue[ObjID: Integer]: Smallint dispid 293;
    property ObjVisible[ObjID: Integer]: WordBool dispid 294;
    function  ObjNameToID(const Name: WideString): Integer; dispid 259;
    function  DefinedNameCount: Integer; dispid 260;
    property AutoFillItems[nIndex: Smallint]: WideString dispid 295;
    procedure SetValidationRule(const Rule: WideString; const Text: WideString); dispid 262;
    procedure GetValidationRule(out Rule: WideString; out Text: WideString); dispid 263;
    function  AutoFillItemsCount: Smallint; dispid 264;
    procedure CopyRangeEx(nDstSheet: Integer; nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; 
                          nDstC2: Integer; hSrcSS: Integer; nSrcSheet: Integer; nSrcR1: Integer; 
                          nSrcC1: Integer; nSrcR2: Integer; nSrcC2: Integer); dispid 265;
    procedure Sort(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; bSortByRows: WordBool; 
                   Keys: OleVariant); dispid 266;
    property ColHidden[nCol: Integer]: WordBool dispid 296;
    property RowHidden[nRow: Integer]: WordBool dispid 297;
    procedure DeleteAutoFillItems(nIndex: Smallint); dispid 267;
    procedure ODBCConnect(var pConnect: WideString; bShowErrors: WordBool; out pRetCode: Smallint); dispid 268;
    procedure ODBCDisconnect; dispid 269;
    procedure ODBCQuery(var pQuery: WideString; nRow: Integer; nCol: Integer; 
                        bForceShowDlg: WordBool; var pSetColNames: WordBool; 
                        var pSetColFormats: WordBool; var pSetColWidths: WordBool; 
                        var pSetMaxRC: WordBool; out pRetCode: Smallint); dispid 270;
    property SheetSelected[nSheet: Integer]: WordBool dispid 298;
    procedure PrintPreviewDC(hDC: OLE_HANDLE; nPage: Smallint; out pPages: Smallint); dispid 1313;
    procedure PrintPreview(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                           nPage: Smallint; out pPages: Smallint); dispid 1314;
    property EntrySRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1315;
    property FormattedTextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString readonly dispid 1316;
    property FormulaSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1317;
    property LogicalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WordBool dispid 1318;
    property NumberSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Double dispid 1319;
    property TextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1320;
    property TypeSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Smallint readonly dispid 1321;
    procedure WriteRange(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; FileType: Smallint); dispid 1322;
    procedure InsertHTML(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; bDataOnly: WordBool; 
                         const pAnchorName: WideString); dispid 1323;
    property FormulaLocalRC[nRow: Integer; nCol: Integer]: WideString dispid 1327;
    property FormulaLocalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString dispid 1328;
    property DefinedNameLocal[const Name: WideString]: WideString dispid 1329;
    procedure CopyDataFromArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                                nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant); dispid 1332;
    procedure CopyDataToArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                              nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant); dispid 1333;
    procedure ODBCError(out pSQLState: WideString; out pNativeError: Integer; 
                        out pErrorMsg: WideString); dispid 1339;
    procedure ODBCPrepare(const SQLStr: WideString; out pRetCode: Smallint); dispid 1340;
    procedure ODBCBindParameter(nParam: Integer; nCol: Integer; CDataType: Smallint; 
                                out pRetCode: Smallint); dispid 1341;
    procedure ODBCExecute(nRow1: Integer; nRow2: Integer; out pRetCode: Smallint); dispid 1342;
    procedure ObjNewPolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; out pID: Integer; 
                            ArrayX: OleVariant; ArrayY: OleVariant; bClosed: WordBool); dispid 1345;
    procedure ObjSetPolygonPoints(nID: Integer; ArrayX: OleVariant; ArrayY: OleVariant; 
                                  bClosed: WordBool); dispid 1346;
    function  GetTabbedTextEx(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                              bValuesOnly: WordBool): WideString; dispid 1359;
    function  SetTabbedTextEx(nStartRow: Integer; nStartCol: Integer; bValuesOnly: WordBool; 
                              const pText: WideString): IF1RangeRef; dispid 1360;
    function  ObjCreate(ObjType: F1ObjTypeConstants; nX1: Single; nY1: Single; nX2: Single; 
                        nY2: Single): Integer; dispid 1373;
    function  ObjCreatePicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; hMF: OLE_HANDLE; 
                               nMapMode: Integer; nWndExtentX: Integer; nWndExtentY: Integer): Integer; dispid 1374;
    function  ReadEx(const pPathName: WideString): F1FileTypeConstants; dispid 1375;
    function  WriteToBlobEx(nReservedBytes: Smallint): OLE_HANDLE; dispid 1376;
    function  ObjCreatePolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; ArrayX: OleVariant; 
                               ArrayY: OleVariant; bClosed: WordBool): Integer; dispid 1377;
    function  ObjGetPosEx(ObjID: Integer): IF1ObjPos; dispid 1378;
    function  ObjPosShown(X1: Single; Y1: Single; X2: Single; Y2: Single): Smallint; dispid 1379;
    property SelectionEx[nSelection: Smallint]: IF1RangeRef readonly dispid 1380;
    function  ObjPosToTwipsEx(X1: Single; Y1: Single; X2: Single; Y2: Single): IF1Rect; dispid 1381;
    function  RangeToTwipsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect; dispid 1382;
    function  RangeShown(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer): Smallint; dispid 1383;
    function  TwipsToRow(nTwips: Integer): Integer; dispid 1384;
    function  TwipsToCol(nTwips: Integer): Integer; dispid 1385;
    function  PrintPreviewDCEx(hDC: OLE_HANDLE; nPage: Smallint): Smallint; dispid 1386;
    function  PrintPreviewEx(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                             nPage: Smallint): Smallint; dispid 1387;
    procedure ODBCConnectEx(const pConnectObj: IF1ODBCConnect; bShowErrors: WordBool); dispid 1401;
    procedure ODBCQueryEx(const pQueryObj: IF1ODBCQuery; nRow: Integer; nCol: Integer; 
                          bForceShowDlg: WordBool); dispid 1402;
    function  ODBCPrepareEx(const SQLStr: WideString): Smallint; dispid 1406;
    function  ODBCBindParameterEx(nParam: Integer; nCol: Integer; CDataType: F1CDataTypesConstants): Smallint; dispid 1407;
    function  ODBCExecuteEx(nRow1: Integer; nRow2: Integer): Smallint; dispid 1408;
    function  OpenFileDlgEx(const pTitle: WideString; hWndParent: OLE_HANDLE): WideString; dispid 1414;
    function  CreateBookView: IF1BookView; dispid 1416;
    procedure EditPasteSpecial(PasteWhat: F1PasteWhatConstants; PasteOp: F1PasteOpConstants); dispid 1422;
    function  GetFirstNumberFormat: IF1NumberFormat; dispid 1424;
    procedure GetNextNumberFormat(const pNumberFormat: IF1NumberFormat); dispid 1425;
    function  RangeToPixelsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect; dispid 1426;
    procedure WriteEx(const PathName: WideString; FileType: F1FileTypeConstants); dispid 1428;
    procedure WriteRangeEx(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                           nCol2: Integer; const pPathName: WideString; 
                           FileType: F1FileTypeConstants); dispid 1429;
    procedure GetFontEx(out pName: WideString; out pCharSet: F1CharSetConstants; 
                        out pSize: Smallint; out pBold: WordBool; out pItalic: WordBool; 
                        out pUnderline: WordBool; out pStrikeout: WordBool; out pcrColor: Integer; 
                        out pOutline: WordBool; out pShadow: WordBool); dispid 1431;
    procedure SetFontEx(const pName: WideString; CharSet: F1CharSetConstants; nSize: Smallint; 
                        bBold: WordBool; bItalic: WordBool; bUnderline: WordBool; 
                        bStrikeout: WordBool; crColor: OLE_COLOR; bOutline: WordBool; 
                        bShadow: WordBool); dispid 1432;
    procedure GetDefaultFontEx(out pBuf: WideString; out pCharSet: F1CharSetConstants; 
                               out pSize: Smallint); dispid 1434;
    procedure SetDefaultFontEx(const Name: WideString; CharSet: F1CharSetConstants; nSize: Smallint); dispid 1435;
    function  CreateNewCellFormat: IF1CellFormat; dispid 1437;
    function  GetCellFormat: IF1CellFormat; dispid 1438;
    procedure SetCellFormat(const CellFormat: IF1CellFormat); dispid 1439;
    function  ErrorNumberToText(SSError: Integer): WideString; dispid 258;
    function  DefineSearch(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; 
                           nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint): IF1FindReplaceInfo; dispid 1448;
    function  CreateNewPageSetup: IF1PageSetup; dispid 1453;
    function  GetPageSetup: IF1PageSetup; dispid 1454;
    procedure SetPageSetup(const PageSetup: IF1PageSetup); dispid 1455;
    function  LoadAddIn(const Path: WideString; bEnabled: WordBool): Smallint; dispid 1458;
    property AddInPath[nAddIn: Smallint]: WideString readonly dispid 1459;
    property AddInEnabled[nAddIn: Smallint]: WordBool dispid 1460;
  end;

// *********************************************************************//
// The Class CoF1RangeRef provides a Create and CreateRemote method to          
// create instances of the default interface IF1RangeRef exposed by              
// the CoClass F1RangeRef. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1RangeRef = class
    class function Create: IF1RangeRef;
    class function CreateRemote(const MachineName: string): IF1RangeRef;
  end;

// *********************************************************************//
// The Class CoF1FileSpec provides a Create and CreateRemote method to          
// create instances of the default interface IF1FileSpec exposed by              
// the CoClass F1FileSpec. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1FileSpec = class
    class function Create: IF1FileSpec;
    class function CreateRemote(const MachineName: string): IF1FileSpec;
  end;

// *********************************************************************//
// The Class CoF1ODBCConnect provides a Create and CreateRemote method to          
// create instances of the default interface IF1ODBCConnect exposed by              
// the CoClass F1ODBCConnect. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1ODBCConnect = class
    class function Create: IF1ODBCConnect;
    class function CreateRemote(const MachineName: string): IF1ODBCConnect;
  end;

// *********************************************************************//
// The Class CoF1ODBCQuery provides a Create and CreateRemote method to          
// create instances of the default interface IF1ODBCQuery exposed by              
// the CoClass F1ODBCQuery. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1ODBCQuery = class
    class function Create: IF1ODBCQuery;
    class function CreateRemote(const MachineName: string): IF1ODBCQuery;
  end;

// *********************************************************************//
// The Class CoF1ReplaceResults provides a Create and CreateRemote method to          
// create instances of the default interface IF1ReplaceResults exposed by              
// the CoClass F1ReplaceResults. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1ReplaceResults = class
    class function Create: IF1ReplaceResults;
    class function CreateRemote(const MachineName: string): IF1ReplaceResults;
  end;

// *********************************************************************//
// The Class CoF1NumberFormat provides a Create and CreateRemote method to          
// create instances of the default interface IF1NumberFormat exposed by              
// the CoClass F1NumberFormat. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1NumberFormat = class
    class function Create: IF1NumberFormat;
    class function CreateRemote(const MachineName: string): IF1NumberFormat;
  end;

// *********************************************************************//
// The Class CoF1CellFormat provides a Create and CreateRemote method to          
// create instances of the default interface IF1CellFormat exposed by              
// the CoClass F1CellFormat. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1CellFormat = class
    class function Create: IF1CellFormat;
    class function CreateRemote(const MachineName: string): IF1CellFormat;
  end;

// *********************************************************************//
// The Class CoF1PageSetup provides a Create and CreateRemote method to          
// create instances of the default interface IF1PageSetup exposed by              
// the CoClass F1PageSetup. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1PageSetup = class
    class function Create: IF1PageSetup;
    class function CreateRemote(const MachineName: string): IF1PageSetup;
  end;

// *********************************************************************//
// The Class CoF1Rect provides a Create and CreateRemote method to          
// create instances of the default interface IF1Rect exposed by              
// the CoClass F1Rect. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1Rect = class
    class function Create: IF1Rect;
    class function CreateRemote(const MachineName: string): IF1Rect;
  end;

// *********************************************************************//
// The Class CoF1ObjPos provides a Create and CreateRemote method to          
// create instances of the default interface IF1ObjPos exposed by              
// the CoClass F1ObjPos. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1ObjPos = class
    class function Create: IF1ObjPos;
    class function CreateRemote(const MachineName: string): IF1ObjPos;
  end;

// *********************************************************************//
// The Class CoF1FindReplaceInfo provides a Create and CreateRemote method to          
// create instances of the default interface IF1FindReplaceInfo exposed by              
// the CoClass F1FindReplaceInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1FindReplaceInfo = class
    class function Create: IF1FindReplaceInfo;
    class function CreateRemote(const MachineName: string): IF1FindReplaceInfo;
  end;

// *********************************************************************//
// The Class CoF1AddInArray provides a Create and CreateRemote method to          
// create instances of the default interface IF1DispAddInArray exposed by              
// the CoClass F1AddInArray. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1AddInArray = class
    class function Create: IF1DispAddInArray;
    class function CreateRemote(const MachineName: string): IF1DispAddInArray;
  end;

// *********************************************************************//
// The Class CoF1AddInArrayEx provides a Create and CreateRemote method to          
// create instances of the default interface IF1DispAddInArrayEx exposed by              
// the CoClass F1AddInArrayEx. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1AddInArrayEx = class
    class function Create: IF1DispAddInArrayEx;
    class function CreateRemote(const MachineName: string): IF1DispAddInArrayEx;
  end;

// *********************************************************************//
// The Class CoF1EventArg provides a Create and CreateRemote method to          
// create instances of the default interface IF1EventArg exposed by              
// the CoClass F1EventArg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1EventArg = class
    class function Create: IF1EventArg;
    class function CreateRemote(const MachineName: string): IF1EventArg;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TF1Book6
// Help String      : Tidestone Formula One 6.1 Workbook
// Default Interface: IF1Book
// Def. Intf. DISP? : Yes
// Event   Interface: DF1Events
// TypeFlags        : (38) CanCreate Licensed Control
// *********************************************************************//
  TF1Book6Click = procedure(Sender: TObject; nRow: Integer; nCol: Integer) of object;
  TF1Book6DblClick = procedure(Sender: TObject; nRow: Integer; nCol: Integer) of object;
  TF1Book6StartEdit = procedure(Sender: TObject; var EditString: WideString; var Cancel: Smallint) of object;
  TF1Book6SafeStartEdit = procedure(Sender: TObject; var EditString: IF1EventArg; 
                                                     var CancelFlag: IF1EventArg) of object;
  TF1Book6EndEdit = procedure(Sender: TObject; var EditString: WideString; var Cancel: Smallint) of object;
  TF1Book6SafeEndEdit = procedure(Sender: TObject; var EditString: IF1EventArg; 
                                                   var CancelFlag: IF1EventArg) of object;
  TF1Book6ObjClick = procedure(Sender: TObject; var ObjName: WideString; ObjID: Integer) of object;
  TF1Book6ObjDblClick = procedure(Sender: TObject; var ObjName: WideString; ObjID: Integer) of object;
  TF1Book6RClick = procedure(Sender: TObject; nRow: Integer; nCol: Integer) of object;
  TF1Book6RDblClick = procedure(Sender: TObject; nRow: Integer; nCol: Integer) of object;
  TF1Book6ObjValueChanged = procedure(Sender: TObject; var ObjName: WideString; ObjID: Integer) of object;
  TF1Book6ObjGotFocus = procedure(Sender: TObject; var ObjName: WideString; ObjID: Integer) of object;
  TF1Book6ObjLostFocus = procedure(Sender: TObject; var ObjName: WideString; ObjID: Integer) of object;
  TF1Book6ValidationFailed = procedure(Sender: TObject; var pEntry: WideString; nSheet: Integer; 
                                                        nRow: Integer; nCol: Integer; 
                                                        var pShowMessage: WideString; 
                                                        var pAction: Smallint) of object;
  TF1Book6SafeValidationFailed = procedure(Sender: TObject; var EntryString: IF1EventArg; 
                                                            nSheet: Integer; nRow: Integer; 
                                                            nCol: Integer; 
                                                            var MessageString: IF1EventArg; 
                                                            var Action: IF1EventArg) of object;
  TF1Book6Found = procedure(Sender: TObject; nSheet: Integer; nRow: Integer; nCol: Integer; 
                                             var pCancel: Smallint) of object;
  TF1Book6SafeFound = procedure(Sender: TObject; nSheet: Integer; nRow: Integer; nCol: Integer; 
                                                 var CancelFlag: IF1EventArg) of object;
  TF1Book6BeforeReplace = procedure(Sender: TObject; var newString: WideString; nSheet: Integer; 
                                                     nRow: Integer; nCol: Integer; 
                                                     var pAction: Smallint) of object;
  TF1Book6SafeBeforeReplace = procedure(Sender: TObject; var newString: IF1EventArg; 
                                                         nSheet: Integer; nRow: Integer; 
                                                         nCol: Integer; var Action: IF1EventArg) of object;
  TF1Book6ODBCExecuteError = procedure(Sender: TObject; nRow: Integer; nCol: Integer; 
                                                        var pAction: Smallint) of object;
  TF1Book6SafeODBCExecuteError = procedure(Sender: TObject; nRow: Integer; nCol: Integer; 
                                                            var Action: IF1EventArg) of object;

  TF1Book6 = class(TOleControl)
  private
    FOnClick: TF1Book6Click;
    FOnDblClick: TF1Book6DblClick;
    FOnCancelEdit: TNotifyEvent;
    FOnSelChange: TNotifyEvent;
    FOnStartEdit: TF1Book6StartEdit;
    FOnSafeStartEdit: TF1Book6SafeStartEdit;
    FOnEndEdit: TF1Book6EndEdit;
    FOnSafeEndEdit: TF1Book6SafeEndEdit;
    FOnStartRecalc: TNotifyEvent;
    FOnEndRecalc: TNotifyEvent;
    FOnTopLeftChanged: TNotifyEvent;
    FOnObjClick: TF1Book6ObjClick;
    FOnObjDblClick: TF1Book6ObjDblClick;
    FOnRClick: TF1Book6RClick;
    FOnRDblClick: TF1Book6RDblClick;
    FOnObjValueChanged: TF1Book6ObjValueChanged;
    FOnModified: TNotifyEvent;
    FOnObjGotFocus: TF1Book6ObjGotFocus;
    FOnObjLostFocus: TF1Book6ObjLostFocus;
    FOnValidationFailed: TF1Book6ValidationFailed;
    FOnSafeValidationFailed: TF1Book6SafeValidationFailed;
    FOnFound: TF1Book6Found;
    FOnSafeFound: TF1Book6SafeFound;
    FOnBeforeReplace: TF1Book6BeforeReplace;
    FOnSafeBeforeReplace: TF1Book6SafeBeforeReplace;
    FOnODBCExecuteError: TF1Book6ODBCExecuteError;
    FOnSafeODBCExecuteError: TF1Book6SafeODBCExecuteError;
    FIntf: IF1Book;
    function  GetControlInterface: IF1Book;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function  Get_NumberRC(nRow: Integer; nCol: Integer): Double;
    procedure Set_NumberRC(nRow: Integer; nCol: Integer; Param3: Double);
    function  Get_ColText(nCol: Integer): WideString;
    procedure Set_ColText(nCol: Integer; const Param2: WideString);
    function  Get_DefinedName(const Name: WideString): WideString;
    procedure Set_DefinedName(const Name: WideString; const Param2: WideString);
    function  Get_EntryRC(nRow: Integer; nCol: Integer): WideString;
    procedure Set_EntryRC(nRow: Integer; nCol: Integer; const Param3: WideString);
    function  Get_FormattedTextRC(nRow: Integer; nCol: Integer): WideString;
    function  Get_FormulaRC(nRow: Integer; nCol: Integer): WideString;
    procedure Set_FormulaRC(nRow: Integer; nCol: Integer;const Param3: WideString);
    function  Get_LastColForRow(nRow: Integer): Integer;
    function  Get_LogicalRC(nRow: Integer; nCol: Integer): WordBool;
    procedure Set_LogicalRC(nRow: Integer; nCol: Integer; Param3: WordBool);
    function  Get_RowText(nRow: Integer): WideString;
    procedure Set_RowText(nRow: Integer; const Param2: WideString);
    function  Get_TextRC(nRow: Integer; nCol: Integer): WideString;
    procedure Set_TextRC(nRow: Integer; nCol: Integer; const Param3: WideString);
    function  Get_TypeRC(nRow: Integer; nCol: Integer): Smallint;
    function  Get_ObjCellType(ObjID: Integer): F1ControlCellConstants;
    procedure Set_ObjCellType(ObjID: Integer; Param2: F1ControlCellConstants);
    function  Get_ObjCellRow(ObjID: Integer): Integer;
    procedure Set_ObjCellRow(ObjID: Integer; Param2: Integer);
    function  Get_ObjCellCol(ObjID: Integer): Integer;
    procedure Set_ObjCellCol(ObjID: Integer; Param2: Integer);
    function  Get_ObjSelection(nSelection: Smallint): Integer;
    function  Get_ColWidth(nCol: Integer): Smallint;
    procedure Set_ColWidth(nCol: Integer; Param2: Smallint);
    function  Get_RowHeight(nRow: Integer): Smallint;
    procedure Set_RowHeight(nRow: Integer; Param2: Smallint);
    function  Get_DefinedNameByIndex(nName: Smallint): WideString;
    function  Get_SheetName(nSheet: Smallint): WideString;
    procedure Set_SheetName(nSheet: Smallint; const Param2: WideString);
    function  Get_PaletteEntry(nEntry: Integer): OLE_COLOR;
    procedure Set_PaletteEntry(nEntry: Integer; Param2: OLE_COLOR);
    function  Get_ColWidthTwips(nCol: Integer): Smallint;
    procedure Set_ColWidthTwips(nCol: Integer; Param2: Smallint);
    function  Get_ObjItem(ObjID: Integer; nItem: Smallint): WideString;
    procedure Set_ObjItem(ObjID: Integer; nItem: Smallint; const Param3: WideString);
    function  Get_ObjItems(ObjID: Integer): WideString;
    procedure Set_ObjItems(ObjID: Integer; const Param2: WideString);
    function  Get_ObjName(ObjID: Integer): WideString;
    procedure Set_ObjName(ObjID: Integer; const Param2: WideString);
    function  Get_ObjText(ObjID: Integer): WideString;
    procedure Set_ObjText(ObjID: Integer; const Param2: WideString);
    function  Get_ObjValue(ObjID: Integer): Smallint;
    procedure Set_ObjValue(ObjID: Integer; Param2: Smallint);
    function  Get_ObjVisible(ObjID: Integer): WordBool;
    procedure Set_ObjVisible(ObjID: Integer; Param2: WordBool);
    function  Get_AutoFillItems(nIndex: Smallint): WideString;
    procedure Set_AutoFillItems(nIndex: Smallint; const Param2: WideString);
    function  Get_ColHidden(nCol: Integer): WordBool;
    procedure Set_ColHidden(nCol: Integer; Param2: WordBool);
    function  Get_RowHidden(nRow: Integer): WordBool;
    procedure Set_RowHidden(nRow: Integer; Param2: WordBool);
    function  Get_SheetSelected(nSheet: Integer): WordBool;
    procedure Set_SheetSelected(nSheet: Integer; Param2: WordBool);
    function  Get_EntrySRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
    procedure Set_EntrySRC(nSheet: Integer; nRow: Integer; nCol: Integer; const Param4: WideString);
    function  Get_FormattedTextSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
    function  Get_FormulaSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
    procedure Set_FormulaSRC(nSheet: Integer; nRow: Integer; nCol: Integer; const Param4: WideString);
    function  Get_LogicalSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WordBool;
    procedure Set_LogicalSRC(nSheet: Integer; nRow: Integer; nCol: Integer; Param4: WordBool);
    function  Get_NumberSRC(nSheet: Integer; nRow: Integer; nCol: Integer): Double;
    procedure Set_NumberSRC(nSheet: Integer; nRow: Integer; nCol: Integer; Param4: Double);
    function  Get_TextSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
    procedure Set_TextSRC(nSheet: Integer; nRow: Integer; nCol: Integer; const Param4: WideString);
    function  Get_TypeSRC(nSheet: Integer; nRow: Integer; nCol: Integer): Smallint;
    function  Get_FormulaLocalRC(nRow: Integer; nCol: Integer): WideString;
    procedure Set_FormulaLocalRC(nRow: Integer; nCol: Integer; const Param3: WideString);
    function  Get_FormulaLocalSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
    procedure Set_FormulaLocalSRC(nSheet: Integer; nRow: Integer; nCol: Integer; 
                                  const Param4: WideString);
    function  Get_DefinedNameLocal(const Name: WideString): WideString;
    procedure Set_DefinedNameLocal(const Name: WideString; const Param2: WideString);
    function  Get_SelectionEx(nSelection: Smallint): IF1RangeRef;
    function  Get_AddInPath(nAddIn: Smallint): WideString;
    function  Get_AddInEnabled(nAddIn: Smallint): WordBool;
    procedure Set_AddInEnabled(nAddIn: Smallint; Param2: WordBool);
  public
    procedure FormatCellsDlg(Pages: Integer);
    procedure EditPasteValues;
    procedure GetAlignment(out pHorizontal: Smallint; out pWordWrap: WordBool; 
                           out pVertical: Smallint; out pOrientation: Smallint);
    procedure GetBorder(out pLeft: Smallint; out pRight: Smallint; out pTop: Smallint; 
                        out pBottom: Smallint; out pShade: Smallint; out pcrLeft: Integer; 
                        out pcrRight: Integer; out pcrTop: Integer; out pcrBottom: Integer);
    procedure GetFont(out pName: WideString; out pSize: Smallint; out pBold: WordBool; 
                      out pItalic: WordBool; out pUnderline: WordBool; out pStrikeout: WordBool; 
                      out pcrColor: Integer; out pOutline: WordBool; out pShadow: WordBool);
    procedure GetLineStyle(out pStyle: Smallint; out pcrColor: Integer; out pWeight: Smallint);
    procedure GetPattern(out pPattern: Smallint; out pcrFG: Integer; out pcrBG: Integer);
    procedure GetProtection(out pLocked: WordBool; out pHidden: WordBool);
    procedure GetTabbedText(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                            bValuesOnly: WordBool; out phText: OLE_HANDLE);
    procedure SetTabbedText(nStartRow: Integer; nStartCol: Integer; out pRows: Integer; 
                            out pCols: Integer; bValuesOnly: WordBool; const pText: WideString);
    procedure AddColPageBreak(nCol: Integer);
    procedure AddPageBreak;
    procedure AddRowPageBreak(nRow: Integer);
    procedure AddSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer);
    procedure Attach(const Title: WideString);
    procedure AttachToSS(hSrcSS: Integer);
    procedure CalculationDlg;
    procedure CancelEdit;
    procedure CheckRecalc;
    procedure ClearClipboard;
    procedure ClearRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                         ClearType: F1ClearTypeConstants);
    procedure ColorPaletteDlg;
    procedure ColWidthDlg;
    procedure CopyAll(hSrcSS: Integer);
    procedure CopyRange(nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; nDstC2: Integer; 
                        hSrcSS: Integer; nSrcR1: Integer; nSrcC1: Integer; nSrcR2: Integer; 
                        nSrcC2: Integer);
    procedure DefinedNameDlg;
    procedure DeleteDefinedName(const pName: WideString);
    procedure DeleteRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          ShiftType: F1ShiftTypeConstants);
    procedure Draw(hDC: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                   nRow: Integer; nCol: Integer; out pRows: Integer; out pCols: Integer; 
                   nFixedRow: Integer; nFixedCol: Integer; nFixedRows: Integer; nFixedCols: Integer);
    procedure EditClear(ClearType: F1ClearTypeConstants);
    procedure EditCopy;
    procedure EditCopyDown;
    procedure EditCopyRight;
    procedure EditCut;
    procedure EditDelete(ShiftType: F1ShiftTypeConstants);
    procedure EditInsert(InsertType: F1ShiftTypeConstants);
    procedure EditPaste;
    procedure EndEdit;
    procedure FilePageSetupDlg;
    procedure FilePrint(bShowPrintDlg: WordBool);
    procedure FilePrintSetupDlg;
    procedure FormatAlignmentDlg;
    procedure FormatBorderDlg;
    procedure FormatCurrency0;
    procedure FormatCurrency2;
    procedure FormatDefaultFontDlg;
    procedure FormatFixed;
    procedure FormatFixed2;
    procedure FormatFontDlg;
    procedure FormatFraction;
    procedure FormatGeneral;
    procedure FormatHmmampm;
    procedure FormatMdyy;
    procedure FormatNumberDlg;
    procedure FormatPatternDlg;
    procedure FormatPercent;
    procedure FormatScientific;
    procedure GetActiveCell(out pRow: Integer; out pCol: Integer);
    procedure GetDefaultFont(out pBuf: WideString; out pSize: Smallint);
    procedure GetHdrSelection(out pTopLeftHdr: WordBool; out pRowHdr: WordBool; 
                              out pColHdr: WordBool);
    procedure GetIteration(out pIteration: WordBool; out pMaxIterations: Smallint; 
                           out pMaxChange: Double);
    procedure GetPrintScale(out pScale: Smallint; out pFitToPage: WordBool; out pVPages: Integer; 
                            out pHPages: Integer);
    procedure GetSelection(nSelection: Smallint; out pR1: Integer; out pC1: Integer; 
                           out pR2: Integer; out pC2: Integer);
    procedure GotoDlg;
    procedure HeapMin;
    procedure InitTable;
    procedure InsertRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                          InsertType: F1ShiftTypeConstants);
    procedure LineStyleDlg;
    procedure MoveRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                        nRowOffset: Integer; nColOffset: Integer);
    procedure ObjAddItem(ObjID: Integer; const ItemText: WideString);
    procedure ObjAddSelection(ObjID: Integer);
    procedure ObjBringToFront;
    procedure ObjDeleteItem(ObjID: Integer; nItem: Smallint);
    procedure ObjGetCell(ObjID: Integer; out pControlCellType: Smallint; out pRow: Integer; 
                         out pCol: Integer);
    procedure ObjGetPos(ObjID: Integer; out pX1: Single; out pY1: Single; out pX2: Single; 
                        out pY2: Single);
    procedure ObjGetSelection(nSelection: Smallint; out pID: Integer);
    procedure ObjInsertItem(ObjID: Integer; nItem: Smallint; const ItemText: WideString);
    procedure ObjNameDlg;
    procedure ObjNew(ObjType: Smallint; nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                     out pID: Integer);
    procedure ObjNewPicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pID: Integer; 
                            hMF: OLE_HANDLE; nMapMode: Integer; nWndExtentX: Integer; 
                            nWndExtentY: Integer);
    procedure ObjOptionsDlg;
    procedure ObjPosToTwips(nX1: Single; nY1: Single; nX2: Single; nY2: Single; out pX: Integer; 
                            out pY: Integer; out pCX: Integer; out pCY: Integer; 
                            out pShown: Smallint);
    procedure ObjSendToBack;
    procedure ObjSetCell(ObjID: Integer; CellType: Smallint; nRow: Integer; nCol: Integer);
    procedure ObjSetPicture(ObjID: Integer; hMF: OLE_HANDLE; nMapMode: Smallint; 
                            nWndExtentX: Integer; nWndExtentY: Integer);
    procedure ObjSetPos(ObjID: Integer; nX1: Single; nY1: Single; nX2: Single; nY2: Single);
    procedure ObjSetSelection(ObjID: Integer);
    procedure OpenFileDlg(const pTitle: WideString; hWndParent: OLE_HANDLE; out pBuf: WideString);
    procedure ProtectionDlg;
    procedure RangeToTwips(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                           out pX: Integer; out pY: Integer; out pCX: Integer; out pCY: Integer; 
                           out pShown: Smallint);
    procedure Read(const pPathName: WideString; out pFileType: Smallint);
    procedure ReadFromBlob(hBlob: OLE_HANDLE; nReservedBytes: Smallint);
    procedure Recalc;
    procedure RemoveColPageBreak(nCol: Integer);
    procedure RemovePageBreak;
    procedure RemoveRowPageBreak(nRow: Integer);
    procedure RowHeightDlg;
    procedure SaveFileDlg(const pTitle: WideString; out pBuf: WideString; out pFileType: Smallint);
    procedure SaveWindowInfo;
    procedure SetActiveCell(nRow: Integer; nCol: Integer);
    procedure SetAlignment(HAlign: Smallint; bWordWrap: WordBool; VAlign: Smallint; 
                           nOrientation: Smallint);
    procedure SetBorder(nOutline: Smallint; nLeft: Smallint; nRight: Smallint; nTop: Smallint; 
                        nBottom: Smallint; nShade: Smallint; crOutline: OLE_COLOR; 
                        crLeft: OLE_COLOR; crRight: OLE_COLOR; crTop: OLE_COLOR; crBottom: OLE_COLOR);
    procedure SetColWidth(nCol1: Integer; nCol2: Integer; nWidth: Smallint; bDefColWidth: WordBool);
    procedure SetColWidthAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                              bSetDefaults: WordBool);
    procedure SetDefaultFont(const Name: WideString; nSize: Smallint);
    procedure SetFont(const pName: WideString; nSize: Smallint; bBold: WordBool; bItalic: WordBool; 
                      bUnderline: WordBool; bStrikeout: WordBool; crColor: OLE_COLOR; 
                      bOutline: WordBool; bShadow: WordBool);
    procedure SetHdrSelection(bTopLeftHdr: WordBool; bRowHdr: WordBool; bColHdr: WordBool);
    procedure SetIteration(bIteration: WordBool; nMaxIterations: Smallint; nMaxChange: Double);
    procedure SetLineStyle(nStyle: Smallint; crColor: OLE_COLOR; nWeight: Smallint);
    procedure SetPattern(nPattern: Smallint; crFG: OLE_COLOR; crBG: OLE_COLOR);
    procedure SetPrintAreaFromSelection;
    procedure SetPrintScale(nScale: Smallint; bFitToPage: WordBool; nVPages: Smallint; 
                            nHPages: Smallint);
    procedure SetPrintTitlesFromSelection;
    procedure SetProtection(bLocked: WordBool; bHidden: WordBool);
    procedure SetRowHeight(nRow1: Integer; nRow2: Integer; nHeight: Smallint; 
                           bDefRowHeight: WordBool);
    procedure SetRowHeightAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                               bSetDefaults: WordBool);
    procedure SetSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer);
    procedure ShowActiveCell;
    procedure Sort3(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                    bSortByRows: WordBool; nKey1: Integer; nKey2: Integer; nKey3: Integer);
    procedure SortDlg;
    procedure StartEdit(bClear: WordBool; bInCellEditFocus: WordBool; bArrowsExitEditMode: WordBool);
    procedure SwapTables(hSS2: OLE_HANDLE);
    procedure TransactCommit;
    procedure TransactRollback;
    procedure TransactStart;
    procedure TwipsToRC(x: Integer; y: Integer; out pRow: Integer; out pCol: Integer);
    procedure SSUpdate;
    function  SSVersion: Smallint;
    procedure Write(const PathName: WideString; FileType: Smallint);
    procedure WriteToBlob(out phBlob: OLE_HANDLE; nReservedBytes: Smallint);
    procedure SetRowHidden(nRow1: Integer; nRow2: Integer; bHidden: WordBool);
    procedure SetColHidden(nCol1: Integer; nCol2: Integer; bHidden: WordBool);
    procedure SetColWidthTwips(nCol1: Integer; nCol2: Integer; nWidth: Smallint; 
                               bDefColWidth: WordBool);
    procedure EditInsertSheets;
    procedure EditDeleteSheets;
    procedure InsertSheets(nSheet: Integer; nSheets: Integer);
    procedure DeleteSheets(nSheet: Integer; nSheets: Integer);
    procedure Refresh;
    function  NextColPageBreak(Col: Integer): Integer;
    function  NextRowPageBreak(Row: Integer): Integer;
    function  ObjFirstID: Integer;
    function  ObjNextID(ObjID: Integer): Integer;
    function  ObjGetItemCount(ObjID: Integer): Smallint;
    function  ObjGetType(ObjID: Integer): F1ObjTypeConstants;
    function  ObjGetSelectionCount: Smallint;
    function  FormatRCNr(Row: Integer; Col: Integer; DoAbsolute: WordBool): WideString;
    function  SS: Integer;
    function  ObjNameToID(const Name: WideString): Integer;
    function  DefinedNameCount: Integer;
    procedure ValidationRuleDlg;
    procedure SetValidationRule(const Rule: WideString; const Text: WideString);
    procedure GetValidationRule(out Rule: WideString; out Text: WideString);
    function  AutoFillItemsCount: Smallint;
    procedure CopyRangeEx(nDstSheet: Integer; nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; 
                          nDstC2: Integer; hSrcSS: Integer; nSrcSheet: Integer; nSrcR1: Integer; 
                          nSrcC1: Integer; nSrcR2: Integer; nSrcC2: Integer);
    procedure Sort(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; bSortByRows: WordBool; 
                   Keys: OleVariant);
    procedure DeleteAutoFillItems(nIndex: Smallint);
    procedure ODBCConnect(var pConnect: WideString; bShowErrors: WordBool; out pRetCode: Smallint);
    procedure ODBCDisconnect;
    procedure ODBCQuery(var pQuery: WideString; nRow: Integer; nCol: Integer; 
                        bForceShowDlg: WordBool; var pSetColNames: WordBool; 
                        var pSetColFormats: WordBool; var pSetColWidths: WordBool; 
                        var pSetMaxRC: WordBool; out pRetCode: Smallint);
    procedure LaunchDesigner;
    procedure AboutBox;
    procedure PrintPreviewDC(hDC: OLE_HANDLE; nPage: Smallint; out pPages: Smallint);
    procedure PrintPreview(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                           nPage: Smallint; out pPages: Smallint);
    procedure WriteRange(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; FileType: Smallint);
    procedure InsertHTML(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                         nCol2: Integer; const pPathName: WideString; bDataOnly: WordBool; 
                         const pAnchorName: WideString);
    procedure FilePrintEx(bShowPrintDlg: WordBool; bPrintWorkbook: WordBool);
    procedure FilePrintPreview;
    procedure CopyDataFromArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                                nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant);
    procedure CopyDataToArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                              nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant);
    procedure FindDlg;
    procedure ReplaceDlg;
    procedure Find(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; nCol1: Integer; 
                   nRow2: Integer; nCol2: Integer; Flags: Smallint; out pFound: Integer);
    procedure Replace(const FindWhat: WideString; const ReplaceWith: WideString; nSheet: Integer; 
                      nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                      Flags: Smallint; out pFound: Integer; out pReplaced: Integer);
    procedure ODBCError(out pSQLState: WideString; out pNativeError: Integer; 
                        out pErrorMsg: WideString);
    procedure ODBCPrepare(const SQLStr: WideString; out pRetCode: Smallint);
    procedure ODBCBindParameter(nParam: Integer; nCol: Integer; CDataType: Smallint; 
                                out pRetCode: Smallint);
    procedure ODBCExecute(nRow1: Integer; nRow2: Integer; out pRetCode: Smallint);
    procedure InsertDlg;
    procedure ObjNewPolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; out pID: Integer; 
                            ArrayX: OleVariant; ArrayY: OleVariant; bClosed: WordBool);
    procedure ObjSetPolygonPoints(nID: Integer; ArrayX: OleVariant; ArrayY: OleVariant; 
                                  bClosed: WordBool);
    procedure DefRowHeightDlg;
    procedure DefColWidthDlg;
    procedure DeleteDlg;
    procedure FormatObjectDlg(Pages: Integer);
    procedure OptionsDlg(Pages: Integer);
    procedure FormatSheetDlg(Pages: Integer; bDesignerMode: WordBool);
    function  GetTabbedTextEx(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                              bValuesOnly: WordBool): WideString;
    function  SetTabbedTextEx(nStartRow: Integer; nStartCol: Integer; bValuesOnly: WordBool; 
                              const pText: WideString): IF1RangeRef;
    function  ObjCreate(ObjType: F1ObjTypeConstants; nX1: Single; nY1: Single; nX2: Single; 
                        nY2: Single): Integer;
    function  ObjCreatePicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; hMF: OLE_HANDLE; 
                               nMapMode: Integer; nWndExtentX: Integer; nWndExtentY: Integer): Integer;
    function  ReadEx(const pPathName: WideString): F1FileTypeConstants;
    function  WriteToBlobEx(nReservedBytes: Smallint): OLE_HANDLE;
    function  ObjCreatePolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; ArrayX: OleVariant; 
                               ArrayY: OleVariant; bClosed: WordBool): Integer;
    function  ObjGetPosEx(ObjID: Integer): IF1ObjPos;
    function  ObjPosShown(X1: Single; Y1: Single; X2: Single; Y2: Single): Smallint;
    function  ObjPosToTwipsEx(X1: Single; Y1: Single; X2: Single; Y2: Single): IF1Rect;
    function  RangeToTwipsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect;
    function  RangeShown(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer): Smallint;
    function  TwipsToRow(nTwips: Integer): Integer;
    function  TwipsToCol(nTwips: Integer): Integer;
    function  PrintPreviewDCEx(hDC: OLE_HANDLE; nPage: Smallint): Smallint;
    function  PrintPreviewEx(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                             nPage: Smallint): Smallint;
    procedure SaveFileDlgEx(const Title: WideString; const pFileSpec: IF1FileSpec);
    procedure ODBCConnectEx(const pConnectObj: IF1ODBCConnect; bShowErrors: WordBool);
    procedure ODBCQueryEx(const pQueryObj: IF1ODBCQuery; nRow: Integer; nCol: Integer; 
                          bForceShowDlg: WordBool);
    function  ODBCPrepareEx(const SQLStr: WideString): Smallint;
    function  ODBCBindParameterEx(nParam: Integer; nCol: Integer; CDataType: F1CDataTypesConstants): Smallint;
    function  ODBCExecuteEx(nRow1: Integer; nRow2: Integer): Smallint;
    function  FindEx(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; nCol1: Integer; 
                     nRow2: Integer; nCol2: Integer; Flags: Smallint): Integer;
    function  ReplaceEx(const FindWhat: WideString; const ReplaceWith: WideString; nSheet: Integer; 
                        nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                        Flags: Smallint): IF1ReplaceResults;
    function  ODBCQueryKludge: IF1ODBCQuery;
    function  ODBCConnectKludge: IF1ODBCConnect;
    function  OpenFileDlgEx(const pTitle: WideString; hWndParent: OLE_HANDLE): WideString;
    function  CreateBookView: IF1BookView;
    function  FileSpecKludge: IF1FileSpec;
    procedure EditPasteSpecial(PasteWhat: F1PasteWhatConstants; PasteOp: F1PasteOpConstants);
    procedure PasteSpecialDlg;
    function  GetFirstNumberFormat: IF1NumberFormat;
    procedure GetNextNumberFormat(const pNumberFormat: IF1NumberFormat);
    function  RangeToPixelsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect;
    procedure WriteEx(const PathName: WideString; FileType: F1FileTypeConstants);
    procedure WriteRangeEx(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                           nCol2: Integer; const pPathName: WideString; 
                           FileType: F1FileTypeConstants);
    procedure GetFontEx(out pName: WideString; out pCharSet: F1CharSetConstants; 
                        out pSize: Smallint; out pBold: WordBool; out pItalic: WordBool; 
                        out pUnderline: WordBool; out pStrikeout: WordBool; out pcrColor: Integer; 
                        out pOutline: WordBool; out pShadow: WordBool);
    procedure SetFontEx(const pName: WideString; CharSet: F1CharSetConstants; nSize: Smallint; 
                        bBold: WordBool; bItalic: WordBool; bUnderline: WordBool; 
                        bStrikeout: WordBool; crColor: OLE_COLOR; bOutline: WordBool; 
                        bShadow: WordBool);
    procedure GetDefaultFontEx(out pBuf: WideString; out pCharSet: F1CharSetConstants; 
                               out pSize: Smallint);
    procedure SetDefaultFontEx(const Name: WideString; CharSet: F1CharSetConstants; nSize: Smallint);
    function  CreateNewCellFormat: IF1CellFormat;
    function  GetCellFormat: IF1CellFormat;
    procedure SetCellFormat(const CellFormat: IF1CellFormat);
    function  ErrorNumberToText(SSError: Integer): WideString;
    function  DefineSearch(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; 
                           nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint): IF1FindReplaceInfo;
    procedure SetDevNames(const DriverName: WideString; const DeviceName: WideString; 
                          const Port: WideString);
    procedure FilePageSetupDlgEx(Pages: Integer);
    function  CreateNewPageSetup: IF1PageSetup;
    function  GetPageSetup: IF1PageSetup;
    procedure SetPageSetup(const PageSetup: IF1PageSetup);
    procedure AddInDlg;
    function  LoadAddIn(const Path: WideString; bEnabled: WordBool): Smallint;
    property  ControlInterface: IF1Book read GetControlInterface;
    property  DefaultInterface: IF1Book read GetControlInterface;
    property NumberRC[nRow: Integer; nCol: Integer]: Double read Get_NumberRC write Set_NumberRC;
    property ColText[nCol: Integer]: WideString read Get_ColText write Set_ColText;
    property DefinedName[const Name: WideString]: WideString read Get_DefinedName write Set_DefinedName;
    property EntryRC[nRow: Integer; nCol: Integer]: WideString read Get_EntryRC write Set_EntryRC;
    property FormattedTextRC[nRow: Integer; nCol: Integer]: WideString read Get_FormattedTextRC;
    property FormulaRC[nRow: Integer; nCol: Integer]: WideString read Get_FormulaRC write Set_FormulaRC;
    property LastColForRow[nRow: Integer]: Integer read Get_LastColForRow;
    property LogicalRC[nRow: Integer; nCol: Integer]: WordBool read Get_LogicalRC write Set_LogicalRC;
    property RowText[nRow: Integer]: WideString read Get_RowText write Set_RowText;
    property TextRC[nRow: Integer; nCol: Integer]: WideString read Get_TextRC write Set_TextRC;
    property TypeRC[nRow: Integer; nCol: Integer]: Smallint read Get_TypeRC;
    property ObjCellType[ObjID: Integer]: F1ControlCellConstants read Get_ObjCellType write Set_ObjCellType;
    property ObjCellRow[ObjID: Integer]: Integer read Get_ObjCellRow write Set_ObjCellRow;
    property ObjCellCol[ObjID: Integer]: Integer read Get_ObjCellCol write Set_ObjCellCol;
    property ObjSelection[nSelection: Smallint]: Integer read Get_ObjSelection;
    property ColWidth[nCol: Integer]: Smallint read Get_ColWidth write Set_ColWidth;
    property RowHeight[nRow: Integer]: Smallint read Get_RowHeight write Set_RowHeight;
    property DefinedNameByIndex[nName: Smallint]: WideString read Get_DefinedNameByIndex;
    property SheetName[nSheet: Smallint]: WideString read Get_SheetName write Set_SheetName;
    property PaletteEntry[nEntry: Integer]: OLE_COLOR read Get_PaletteEntry write Set_PaletteEntry;
    property ColWidthTwips[nCol: Integer]: Smallint read Get_ColWidthTwips write Set_ColWidthTwips;
    property ObjItem[ObjID: Integer; nItem: Smallint]: WideString read Get_ObjItem write Set_ObjItem;
    property ObjItems[ObjID: Integer]: WideString read Get_ObjItems write Set_ObjItems;
    property ObjName[ObjID: Integer]: WideString read Get_ObjName write Set_ObjName;
    property ObjText[ObjID: Integer]: WideString read Get_ObjText write Set_ObjText;
    property ObjValue[ObjID: Integer]: Smallint read Get_ObjValue write Set_ObjValue;
    property ObjVisible[ObjID: Integer]: WordBool read Get_ObjVisible write Set_ObjVisible;
    property AutoFillItems[nIndex: Smallint]: WideString read Get_AutoFillItems write Set_AutoFillItems;
    property ColHidden[nCol: Integer]: WordBool read Get_ColHidden write Set_ColHidden;
    property RowHidden[nRow: Integer]: WordBool read Get_RowHidden write Set_RowHidden;
    property SheetSelected[nSheet: Integer]: WordBool read Get_SheetSelected write Set_SheetSelected;
    property EntrySRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString read Get_EntrySRC write Set_EntrySRC;
    property FormattedTextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString read Get_FormattedTextSRC;
    property FormulaSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString read Get_FormulaSRC write Set_FormulaSRC;
    property LogicalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WordBool read Get_LogicalSRC write Set_LogicalSRC;
    property NumberSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Double read Get_NumberSRC write Set_NumberSRC;
    property TextSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString read Get_TextSRC write Set_TextSRC;
    property TypeSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: Smallint read Get_TypeSRC;
    property FormulaLocalRC[nRow: Integer; nCol: Integer]: WideString read Get_FormulaLocalRC write Set_FormulaLocalRC;
    property FormulaLocalSRC[nSheet: Integer; nRow: Integer; nCol: Integer]: WideString read Get_FormulaLocalSRC write Set_FormulaLocalSRC;
    property DefinedNameLocal[const Name: WideString]: WideString read Get_DefinedNameLocal write Set_DefinedNameLocal;
    property SelectionEx[nSelection: Smallint]: IF1RangeRef read Get_SelectionEx;
    property AddInPath[nAddIn: Smallint]: WideString read Get_AddInPath;
    property AddInEnabled[nAddIn: Smallint]: WordBool read Get_AddInEnabled write Set_AddInEnabled;
  published
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property  OnMouseUp;
    property  OnMouseMove;
    property  OnMouseDown;
    property  OnKeyUp;
    property  OnKeyPress;
    property  OnKeyDown;
    property BackColor: TColor index 3 read GetTColorProp write SetTColorProp stored False;
    property Col: Integer index 4 read GetIntegerProp write SetIntegerProp stored False;
    property Row: Integer index 5 read GetIntegerProp write SetIntegerProp stored False;
    property ShowHScrollBar: TOleEnum index 6 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Text: WideString index 7 read GetWideStringProp write SetWideStringProp stored False;
    property Number: Double index 8 read GetDoubleProp write SetDoubleProp stored False;
    property Formula: WideString index 9 read GetWideStringProp write SetWideStringProp stored False;
    property FixedCol: Integer index 10 read GetIntegerProp write SetIntegerProp stored False;
    property FixedCols: Integer index 11 read GetIntegerProp write SetIntegerProp stored False;
    property FixedRow: Integer index 12 read GetIntegerProp write SetIntegerProp stored False;
    property FixedRows: Integer index 13 read GetIntegerProp write SetIntegerProp stored False;
    property ShowGridLines: WordBool index 14 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowRowHeading: WordBool index 15 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowSelections: TOleEnum index 16 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property LeftCol: Integer index 17 read GetIntegerProp write SetIntegerProp stored False;
    property MaxCol: Integer index 18 read GetIntegerProp write SetIntegerProp stored False;
    property MaxRow: Integer index 19 read GetIntegerProp write SetIntegerProp stored False;
    property TopRow: Integer index 20 read GetIntegerProp write SetIntegerProp stored False;
    property AllowResize: WordBool index 21 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowSelections: WordBool index 22 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowFormulas: WordBool index 23 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowInCellEditing: WordBool index 24 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowVScrollBar: TOleEnum index 25 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AllowFillRange: WordBool index 26 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowMoveRange: WordBool index 27 read GetWordBoolProp write SetWordBoolProp stored False;
    property SelStartCol: Integer index 28 read GetIntegerProp write SetIntegerProp stored False;
    property SelStartRow: Integer index 29 read GetIntegerProp write SetIntegerProp stored False;
    property SelEndCol: Integer index 30 read GetIntegerProp write SetIntegerProp stored False;
    property SelEndRow: Integer index 31 read GetIntegerProp write SetIntegerProp stored False;
    property ExtraColor: TColor index 32 read GetTColorProp write SetTColorProp stored False;
    property FileName: WideString index 33 read GetWideStringProp write SetWideStringProp stored False;
    property AutoRecalc: WordBool index 34 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintGridLines: WordBool index 35 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintRowHeading: WordBool index 36 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintHCenter: WordBool index 37 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintVCenter: WordBool index 38 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintLeftToRight: WordBool index 39 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintHeader: WideString index 40 read GetWideStringProp write SetWideStringProp stored False;
    property PrintFooter: WideString index 41 read GetWideStringProp write SetWideStringProp stored False;
    property PrintLeftMargin: Double index 42 read GetDoubleProp write SetDoubleProp stored False;
    property PrintTopMargin: Double index 43 read GetDoubleProp write SetDoubleProp stored False;
    property PrintRightMargin: Double index 44 read GetDoubleProp write SetDoubleProp stored False;
    property PrintBottomMargin: Double index 45 read GetDoubleProp write SetDoubleProp stored False;
    property PrintArea: WideString index 46 read GetWideStringProp write SetWideStringProp stored False;
    property PrintTitles: WideString index 47 read GetWideStringProp write SetWideStringProp stored False;
    property PrintNoColor: WordBool index 48 read GetWordBoolProp write SetWordBoolProp stored False;
    property Selection: WideString index 49 read GetWideStringProp write SetWideStringProp stored False;
    property TableName: WideString index 50 read GetWideStringProp write SetWideStringProp stored False;
    property DoCancelEdit: WordBool index 51 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoSelChange: WordBool index 52 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoStartEdit: WordBool index 53 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoEndEdit: WordBool index 54 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoStartRecalc: WordBool index 55 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoEndRecalc: WordBool index 56 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoClick: WordBool index 57 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoDblClick: WordBool index 58 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowColHeading: WordBool index 59 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintColHeading: WordBool index 60 read GetWordBoolProp write SetWordBoolProp stored False;
    property Entry: WideString index 61 read GetWideStringProp write SetWideStringProp stored False;
    property Repaint: WordBool index 62 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowArrows: WordBool index 63 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowTabs: WordBool index 64 read GetWordBoolProp write SetWordBoolProp stored False;
    property FormattedText: WideString index 65 read GetWideStringProp write SetWideStringProp stored False;
    property RowMode: WordBool index 66 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowDelete: WordBool index 67 read GetWordBoolProp write SetWordBoolProp stored False;
    property EnableProtection: WordBool index 68 read GetWordBoolProp write SetWordBoolProp stored False;
    property MinCol: Integer index 69 read GetIntegerProp write SetIntegerProp stored False;
    property MinRow: Integer index 70 read GetIntegerProp write SetIntegerProp stored False;
    property DoTopLeftChanged: WordBool index 71 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowEditHeaders: WordBool index 72 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoObjClick: WordBool index 73 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoObjDblClick: WordBool index 74 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowObjSelections: WordBool index 75 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoRClick: WordBool index 76 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoRDblClick: WordBool index 77 read GetWordBoolProp write SetWordBoolProp stored False;
    property Clip: WideString index 78 read GetWideStringProp write SetWideStringProp stored False;
    property ClipValues: WideString index 79 read GetWideStringProp write SetWideStringProp stored False;
    property PrintLandscape: WordBool index 80 read GetWordBoolProp write SetWordBoolProp stored False;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp stored False;
    property BorderStyle: TOleEnum index -504 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AppName: WideString index 81 read GetWideStringProp write SetWideStringProp stored False;
    property HdrHeight: Smallint index 82 read GetSmallintProp write SetSmallintProp stored False;
    property HdrWidth: Smallint index 83 read GetSmallintProp write SetSmallintProp stored False;
    property NumberFormat: WideString index 84 read GetWideStringProp write SetWideStringProp stored False;
    property TopLeftText: WideString index 85 read GetWideStringProp write SetWideStringProp stored False;
    property EnterMovesDown: WordBool index 86 read GetWordBoolProp write SetWordBoolProp stored False;
    property LastCol: Integer index 87 read GetIntegerProp write SetIntegerProp stored False;
    property LastRow: Integer index 88 read GetIntegerProp write SetIntegerProp stored False;
    property Logical: WordBool index 89 read GetWordBoolProp write SetWordBoolProp stored False;
    property Mode: TOleEnum index 90 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PolyEditMode: TOleEnum index 91 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ViewScale: Smallint index 92 read GetSmallintProp write SetSmallintProp stored False;
    property SelectionCount: Smallint index 93 read GetSmallintProp write SetSmallintProp stored False;
    property Title: WideString index 94 read GetWideStringProp write SetWideStringProp stored False;
    property Type_: Smallint index 95 read GetSmallintProp write SetSmallintProp stored False;
    property ShowFormulas: WordBool index 96 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowZeroValues: WordBool index 97 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoObjValueChanged: WordBool index 99 read GetWordBoolProp write SetWordBoolProp stored False;
    property ScrollToLastRC: WordBool index 100 read GetWordBoolProp write SetWordBoolProp stored False;
    property Modified: WordBool index 101 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoObjGotFocus: WordBool index 102 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoObjLostFocus: WordBool index 103 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintDevMode: Integer index 104 read GetIntegerProp write SetIntegerProp stored False;
    property NumSheets: Integer index 105 read GetIntegerProp write SetIntegerProp stored False;
    property Sheet: Integer index 106 read GetIntegerProp write SetIntegerProp stored False;
    property ColWidthUnits: TOleEnum index 107 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ShowTypeMarkers: WordBool index 108 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowTabs: TOleEnum index 109 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property ShowEditBar: WordBool index 110 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowEditBarCellRef: WordBool index 111 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowDesigner: WordBool index 1 read GetWordBoolProp write SetWordBoolProp stored False;
    property hWnd: Integer index -515 read GetIntegerProp write SetIntegerProp stored False;
    property AllowAutoFill: WordBool index 112 read GetWordBoolProp write SetWordBoolProp stored False;
    property Compressed: WordBool index 299 read GetWordBoolProp write SetWordBoolProp stored False;
    property FontName: WideString index 1300 read GetWideStringProp write SetWideStringProp stored False;
    property FontSize: Smallint index 1301 read GetSmallintProp write SetSmallintProp stored False;
    property FontBold: WordBool index 1302 read GetWordBoolProp write SetWordBoolProp stored False;
    property FontItalic: WordBool index 1303 read GetWordBoolProp write SetWordBoolProp stored False;
    property FontUnderline: WordBool index 1304 read GetWordBoolProp write SetWordBoolProp stored False;
    property FontStrikeout: WordBool index 1305 read GetWordBoolProp write SetWordBoolProp stored False;
    property FontColor: TColor index 1306 read GetTColorProp write SetTColorProp stored False;
    property FontCharSet: TOleEnum index 1433 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property HAlign: TOleEnum index 1307 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property WordWrap: WordBool index 1308 read GetWordBoolProp write SetWordBoolProp stored False;
    property VAlign: TOleEnum index 1309 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property LaunchWorkbookDesigner: WordBool index 1310 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintHeaderMargin: Double index 1311 read GetDoubleProp write SetDoubleProp stored False;
    property PrintFooterMargin: Double index 1312 read GetDoubleProp write SetDoubleProp stored False;
    property FormulaLocal: WideString index 1326 read GetWideStringProp write SetWideStringProp stored False;
    property NumberFormatLocal: WideString index 1330 read GetWideStringProp write SetWideStringProp stored False;
    property SelectionLocal: WideString index 1331 read GetWideStringProp write SetWideStringProp stored False;
    property DataTransferRange: WideString index 1334 read GetWideStringProp write SetWideStringProp stored False;
    property CanEditPaste: WordBool index 1344 read GetWordBoolProp write SetWordBoolProp stored False;
    property ObjPatternStyle: Smallint index 1354 read GetSmallintProp write SetSmallintProp stored False;
    property ObjPatternFG: TColor index 1355 read GetTColorProp write SetTColorProp stored False;
    property ObjPatternBG: TColor index 1356 read GetTColorProp write SetTColorProp stored False;
    property DefaultFontName: WideString index 1361 read GetWideStringProp write SetWideStringProp stored False;
    property DefaultFontSize: Smallint index 1362 read GetSmallintProp write SetSmallintProp stored False;
    property SelHdrRow: WordBool index 1363 read GetWordBoolProp write SetWordBoolProp stored False;
    property SelHdrCol: WordBool index 1364 read GetWordBoolProp write SetWordBoolProp stored False;
    property SelHdrTopLeft: WordBool index 1365 read GetWordBoolProp write SetWordBoolProp stored False;
    property IterationEnabled: WordBool index 1366 read GetWordBoolProp write SetWordBoolProp stored False;
    property IterationMax: Smallint index 1367 read GetSmallintProp write SetSmallintProp stored False;
    property IterationMaxChange: Double index 1368 read GetDoubleProp write SetDoubleProp stored False;
    property PrintScale: Smallint index 1389 read GetSmallintProp write SetSmallintProp stored False;
    property PrintScaleFitToPage: WordBool index 1390 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintScaleFitVPages: Integer index 1392 read GetIntegerProp write SetIntegerProp stored False;
    property PrintScaleFitHPages: Integer index 1391 read GetIntegerProp write SetIntegerProp stored False;
    property LineStyle: Smallint index 1395 read GetSmallintProp write SetSmallintProp stored False;
    property LineColor: TColor index 1396 read GetTColorProp write SetTColorProp stored False;
    property LineWeight: Smallint index 1397 read GetSmallintProp write SetSmallintProp stored False;
    property ODBCSQLState: WideString index 1403 read GetWideStringProp write SetWideStringProp stored False;
    property ODBCNativeError: Integer index 1404 read GetIntegerProp write SetIntegerProp stored False;
    property ODBCErrorMsg: WideString index 1405 read GetWideStringProp write SetWideStringProp stored False;
    property DataTransferHeadings: WordBool index 1413 read GetWordBoolProp write SetWordBoolProp stored False;
    property FormatPaintMode: WordBool index 1420 read GetWordBoolProp write SetWordBoolProp stored False;
    property CanEditPasteSpecial: WordBool index 1421 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrecisionAsDisplayed: WordBool index 1427 read GetWordBoolProp write SetWordBoolProp stored False;
    property DoSafeEvents: WordBool index 1430 read GetWordBoolProp write SetWordBoolProp stored False;
    property DefaultFontCharSet: TOleEnum index 1436 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property WantAllWindowInfoChanges: WordBool index 1440 read GetWordBoolProp write SetWordBoolProp stored False;
    property URL: WideString index 1441 read GetWideStringProp write SetWideStringProp stored False;
    property MousePointer: TOleEnum index -521 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property MouseIcon: TPicture index -522 read GetTPictureProp write SetTPictureProp stored False;
    property DataLossIsError: WordBool index 1444 read GetWordBoolProp write SetWordBoolProp stored False;
    property MinimalRecalc: WordBool index 1445 read GetWordBoolProp write SetWordBoolProp stored False;
    property AllowCellTextDlg: WordBool index 1446 read GetWordBoolProp write SetWordBoolProp stored False;
    property ShowLockedCellsError: WordBool index 1447 read GetWordBoolProp write SetWordBoolProp stored False;
    property PrintDevNames: Integer index 1450 read GetIntegerProp write SetIntegerProp stored False;
    property PrintCopies: Smallint index 1456 read GetSmallintProp write SetSmallintProp stored False;
    property AddInCount: Smallint index 1461 read GetSmallintProp write SetSmallintProp stored False;
    property AllowFormatByEntry: WordBool index 1462 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnClick: TF1Book6Click read FOnClick write FOnClick;
    property OnDblClick: TF1Book6DblClick read FOnDblClick write FOnDblClick;
    property OnCancelEdit: TNotifyEvent read FOnCancelEdit write FOnCancelEdit;
    property OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;
    property OnStartEdit: TF1Book6StartEdit read FOnStartEdit write FOnStartEdit;
    property OnSafeStartEdit: TF1Book6SafeStartEdit read FOnSafeStartEdit write FOnSafeStartEdit;
    property OnEndEdit: TF1Book6EndEdit read FOnEndEdit write FOnEndEdit;
    property OnSafeEndEdit: TF1Book6SafeEndEdit read FOnSafeEndEdit write FOnSafeEndEdit;
    property OnStartRecalc: TNotifyEvent read FOnStartRecalc write FOnStartRecalc;
    property OnEndRecalc: TNotifyEvent read FOnEndRecalc write FOnEndRecalc;
    property OnTopLeftChanged: TNotifyEvent read FOnTopLeftChanged write FOnTopLeftChanged;
    property OnObjClick: TF1Book6ObjClick read FOnObjClick write FOnObjClick;
    property OnObjDblClick: TF1Book6ObjDblClick read FOnObjDblClick write FOnObjDblClick;
    property OnRClick: TF1Book6RClick read FOnRClick write FOnRClick;
    property OnRDblClick: TF1Book6RDblClick read FOnRDblClick write FOnRDblClick;
    property OnObjValueChanged: TF1Book6ObjValueChanged read FOnObjValueChanged write FOnObjValueChanged;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property OnObjGotFocus: TF1Book6ObjGotFocus read FOnObjGotFocus write FOnObjGotFocus;
    property OnObjLostFocus: TF1Book6ObjLostFocus read FOnObjLostFocus write FOnObjLostFocus;
    property OnValidationFailed: TF1Book6ValidationFailed read FOnValidationFailed write FOnValidationFailed;
    property OnSafeValidationFailed: TF1Book6SafeValidationFailed read FOnSafeValidationFailed write FOnSafeValidationFailed;
    property OnFound: TF1Book6Found read FOnFound write FOnFound;
    property OnSafeFound: TF1Book6SafeFound read FOnSafeFound write FOnSafeFound;
    property OnBeforeReplace: TF1Book6BeforeReplace read FOnBeforeReplace write FOnBeforeReplace;
    property OnSafeBeforeReplace: TF1Book6SafeBeforeReplace read FOnSafeBeforeReplace write FOnSafeBeforeReplace;
    property OnODBCExecuteError: TF1Book6ODBCExecuteError read FOnODBCExecuteError write FOnODBCExecuteError;
    property OnSafeODBCExecuteError: TF1Book6SafeODBCExecuteError read FOnSafeODBCExecuteError write FOnSafeODBCExecuteError;
  end;

// *********************************************************************//
// The Class CoF1BookView provides a Create and CreateRemote method to          
// create instances of the default interface IF1BookView exposed by              
// the CoClass F1BookView. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoF1BookView = class
    class function Create: IF1BookView;
    class function CreateRemote(const MachineName: string): IF1BookView;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

class function CoF1RangeRef.Create: IF1RangeRef;
begin
  Result := CreateComObject(CLASS_F1RangeRef) as IF1RangeRef;
end;

class function CoF1RangeRef.CreateRemote(const MachineName: string): IF1RangeRef;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1RangeRef) as IF1RangeRef;
end;

class function CoF1FileSpec.Create: IF1FileSpec;
begin
  Result := CreateComObject(CLASS_F1FileSpec) as IF1FileSpec;
end;

class function CoF1FileSpec.CreateRemote(const MachineName: string): IF1FileSpec;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1FileSpec) as IF1FileSpec;
end;

class function CoF1ODBCConnect.Create: IF1ODBCConnect;
begin
  Result := CreateComObject(CLASS_F1ODBCConnect) as IF1ODBCConnect;
end;

class function CoF1ODBCConnect.CreateRemote(const MachineName: string): IF1ODBCConnect;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1ODBCConnect) as IF1ODBCConnect;
end;

class function CoF1ODBCQuery.Create: IF1ODBCQuery;
begin
  Result := CreateComObject(CLASS_F1ODBCQuery) as IF1ODBCQuery;
end;

class function CoF1ODBCQuery.CreateRemote(const MachineName: string): IF1ODBCQuery;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1ODBCQuery) as IF1ODBCQuery;
end;

class function CoF1ReplaceResults.Create: IF1ReplaceResults;
begin
  Result := CreateComObject(CLASS_F1ReplaceResults) as IF1ReplaceResults;
end;

class function CoF1ReplaceResults.CreateRemote(const MachineName: string): IF1ReplaceResults;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1ReplaceResults) as IF1ReplaceResults;
end;

class function CoF1NumberFormat.Create: IF1NumberFormat;
begin
  Result := CreateComObject(CLASS_F1NumberFormat) as IF1NumberFormat;
end;

class function CoF1NumberFormat.CreateRemote(const MachineName: string): IF1NumberFormat;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1NumberFormat) as IF1NumberFormat;
end;

class function CoF1CellFormat.Create: IF1CellFormat;
begin
  Result := CreateComObject(CLASS_F1CellFormat) as IF1CellFormat;
end;

class function CoF1CellFormat.CreateRemote(const MachineName: string): IF1CellFormat;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1CellFormat) as IF1CellFormat;
end;

class function CoF1PageSetup.Create: IF1PageSetup;
begin
  Result := CreateComObject(CLASS_F1PageSetup) as IF1PageSetup;
end;

class function CoF1PageSetup.CreateRemote(const MachineName: string): IF1PageSetup;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1PageSetup) as IF1PageSetup;
end;

class function CoF1Rect.Create: IF1Rect;
begin
  Result := CreateComObject(CLASS_F1Rect) as IF1Rect;
end;

class function CoF1Rect.CreateRemote(const MachineName: string): IF1Rect;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1Rect) as IF1Rect;
end;

class function CoF1ObjPos.Create: IF1ObjPos;
begin
  Result := CreateComObject(CLASS_F1ObjPos) as IF1ObjPos;
end;

class function CoF1ObjPos.CreateRemote(const MachineName: string): IF1ObjPos;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1ObjPos) as IF1ObjPos;
end;

class function CoF1FindReplaceInfo.Create: IF1FindReplaceInfo;
begin
  Result := CreateComObject(CLASS_F1FindReplaceInfo) as IF1FindReplaceInfo;
end;

class function CoF1FindReplaceInfo.CreateRemote(const MachineName: string): IF1FindReplaceInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1FindReplaceInfo) as IF1FindReplaceInfo;
end;

class function CoF1AddInArray.Create: IF1DispAddInArray;
begin
  Result := CreateComObject(CLASS_F1AddInArray) as IF1DispAddInArray;
end;

class function CoF1AddInArray.CreateRemote(const MachineName: string): IF1DispAddInArray;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1AddInArray) as IF1DispAddInArray;
end;

class function CoF1AddInArrayEx.Create: IF1DispAddInArrayEx;
begin
  Result := CreateComObject(CLASS_F1AddInArrayEx) as IF1DispAddInArrayEx;
end;

class function CoF1AddInArrayEx.CreateRemote(const MachineName: string): IF1DispAddInArrayEx;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1AddInArrayEx) as IF1DispAddInArrayEx;
end;

class function CoF1EventArg.Create: IF1EventArg;
begin
  Result := CreateComObject(CLASS_F1EventArg) as IF1EventArg;
end;

class function CoF1EventArg.CreateRemote(const MachineName: string): IF1EventArg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1EventArg) as IF1EventArg;
end;

procedure TF1Book6.InitControlData;
const
  CEventDispIDs: array [0..26] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000016,
    $00000006, $00000017, $00000007, $00000008, $00000009, $0000000A,
    $0000000B, $0000000C, $0000000D, $0000000E, $0000000F, $00000010,
    $00000011, $00000012, $00000018, $00000013, $00000019, $00000014,
    $0000001A, $00000015, $0000001B);
  CLicenseKey: array[0..36] of Word = ( $0042, $0030, $0034, $0037, $0035, $0030, $0034, $0039, $002D, $0037, $0037
    , $0034, $0030, $002D, $0031, $0031, $0064, $0031, $002D, $0042, $0044
    , $0043, $0033, $002D, $0030, $0030, $0032, $0030, $0041, $0046, $0039
    , $0046, $0038, $0045, $0036, $0045, $0000);
  CTPictureIDs: array [0..0] of DWORD = (
    $FFFFFDF6);
  CControlData: TControlData2 = (
    ClassID: '{B0475003-7740-11D1-BDC3-0020AF9F8E6E}';
    EventIID: '{B0475002-7740-11D1-BDC3-0020AF9F8E6E}';
    EventCount: 27;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: @CLicenseKey;
    Flags: $00000008;
    Version: 401;
    FontCount: 0;
    FontIDs: nil;
    PictureCount: 1;
    PictureIDs: @CTPictureIDs);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnClick) - Cardinal(Self);
end;

procedure TF1Book6.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IF1Book;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TF1Book6.GetControlInterface: IF1Book;
begin
  CreateControl;
  Result := FIntf;
end;

function  TF1Book6.Get_NumberRC(nRow: Integer; nCol: Integer): Double;
begin
  Result := DefaultInterface.NumberRC[nRow, nCol];
end;

procedure TF1Book6.Set_NumberRC(nRow: Integer; nCol: Integer; Param3: Double);
begin
  DefaultInterface.NumberRC[nRow, nCol] := Param3;
end;

function  TF1Book6.Get_ColText(nCol: Integer): WideString;
begin
  Result := DefaultInterface.ColText[nCol];
end;

procedure TF1Book6.Set_ColText(nCol: Integer; const Param2: WideString);
  { Warning: The property ColText has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ColText := Param2;
end;

function  TF1Book6.Get_DefinedName(const Name: WideString): WideString;
begin
  Result := DefaultInterface.DefinedName[Name];
end;

procedure TF1Book6.Set_DefinedName(const Name: WideString; const Param2: WideString);
  { Warning: The property DefinedName has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DefinedName := Param2;
end;

function  TF1Book6.Get_EntryRC(nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.EntryRC[nRow, nCol];
end;

procedure TF1Book6.Set_EntryRC(nRow: Integer; nCol: Integer; const Param3: WideString);
  { Warning: The property EntryRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.EntryRC := Param3;
end;

function  TF1Book6.Get_FormattedTextRC(nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormattedTextRC[nRow, nCol];
end;

function  TF1Book6.Get_FormulaRC(nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormulaRC[nRow, nCol];
end;

procedure TF1Book6.Set_FormulaRC(nRow: Integer; nCol: Integer; const Param3: WideString);
begin
DefaultInterface.FormulaRC[nRow, nCol] := Param3;
end;

function  TF1Book6.Get_LastColForRow(nRow: Integer): Integer;
begin
  Result := DefaultInterface.LastColForRow[nRow];
end;

function  TF1Book6.Get_LogicalRC(nRow: Integer; nCol: Integer): WordBool;
begin
  Result := DefaultInterface.LogicalRC[nRow, nCol];
end;

procedure TF1Book6.Set_LogicalRC(nRow: Integer; nCol: Integer; Param3: WordBool);
begin
  DefaultInterface.LogicalRC[nRow, nCol] := Param3;
end;

function  TF1Book6.Get_RowText(nRow: Integer): WideString;
begin
  Result := DefaultInterface.RowText[nRow];
end;

procedure TF1Book6.Set_RowText(nRow: Integer; const Param2: WideString);
  { Warning: The property RowText has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.RowText := Param2;
end;

function  TF1Book6.Get_TextRC(nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.TextRC[nRow, nCol];
end;

procedure TF1Book6.Set_TextRC(nRow: Integer; nCol: Integer; const Param3: WideString);
  { Warning: The property TextRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TextRC[nRow,nCol] := Param3;
end;

function  TF1Book6.Get_TypeRC(nRow: Integer; nCol: Integer): Smallint;
begin
  Result := DefaultInterface.TypeRC[nRow, nCol];
end;

function  TF1Book6.Get_ObjCellType(ObjID: Integer): F1ControlCellConstants;
begin
  Result := DefaultInterface.ObjCellType[ObjID];
end;

procedure TF1Book6.Set_ObjCellType(ObjID: Integer; Param2: F1ControlCellConstants);
begin
  DefaultInterface.ObjCellType[ObjID] := Param2;
end;

function  TF1Book6.Get_ObjCellRow(ObjID: Integer): Integer;
begin
  Result := DefaultInterface.ObjCellRow[ObjID];
end;

procedure TF1Book6.Set_ObjCellRow(ObjID: Integer; Param2: Integer);
begin
  DefaultInterface.ObjCellRow[ObjID] := Param2;
end;

function  TF1Book6.Get_ObjCellCol(ObjID: Integer): Integer;
begin
  Result := DefaultInterface.ObjCellCol[ObjID];
end;

procedure TF1Book6.Set_ObjCellCol(ObjID: Integer; Param2: Integer);
begin
  DefaultInterface.ObjCellCol[ObjID] := Param2;
end;

function  TF1Book6.Get_ObjSelection(nSelection: Smallint): Integer;
begin
  Result := DefaultInterface.ObjSelection[nSelection];
end;

function  TF1Book6.Get_ColWidth(nCol: Integer): Smallint;
begin
  Result := DefaultInterface.ColWidth[nCol];
end;

procedure TF1Book6.Set_ColWidth(nCol: Integer; Param2: Smallint);
begin
  DefaultInterface.ColWidth[nCol] := Param2;
end;

function  TF1Book6.Get_RowHeight(nRow: Integer): Smallint;
begin
  Result := DefaultInterface.RowHeight[nRow];
end;

procedure TF1Book6.Set_RowHeight(nRow: Integer; Param2: Smallint);
begin
  DefaultInterface.RowHeight[nRow] := Param2;
end;

function  TF1Book6.Get_DefinedNameByIndex(nName: Smallint): WideString;
begin
  Result := DefaultInterface.DefinedNameByIndex[nName];
end;

function  TF1Book6.Get_SheetName(nSheet: Smallint): WideString;
begin
  Result := DefaultInterface.SheetName[nSheet];
end;

procedure TF1Book6.Set_SheetName(nSheet: Smallint; const Param2: WideString);
  { Warning: The property SheetName has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.SheetName := Param2;
end;

function  TF1Book6.Get_PaletteEntry(nEntry: Integer): OLE_COLOR;
begin
  Result := DefaultInterface.PaletteEntry[nEntry];
end;

procedure TF1Book6.Set_PaletteEntry(nEntry: Integer; Param2: OLE_COLOR);
begin
  DefaultInterface.PaletteEntry[nEntry] := Param2;
end;

function  TF1Book6.Get_ColWidthTwips(nCol: Integer): Smallint;
begin
  Result := DefaultInterface.ColWidthTwips[nCol];
end;

procedure TF1Book6.Set_ColWidthTwips(nCol: Integer; Param2: Smallint);
begin
  DefaultInterface.ColWidthTwips[nCol] := Param2;
end;

function  TF1Book6.Get_ObjItem(ObjID: Integer; nItem: Smallint): WideString;
begin
  Result := DefaultInterface.ObjItem[ObjID, nItem];
end;

procedure TF1Book6.Set_ObjItem(ObjID: Integer; nItem: Smallint; const Param3: WideString);
  { Warning: The property ObjItem has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ObjItem := Param3;
end;

function  TF1Book6.Get_ObjItems(ObjID: Integer): WideString;
begin
  Result := DefaultInterface.ObjItems[ObjID];
end;

procedure TF1Book6.Set_ObjItems(ObjID: Integer; const Param2: WideString);
  { Warning: The property ObjItems has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ObjItems := Param2;
end;

function  TF1Book6.Get_ObjName(ObjID: Integer): WideString;
begin
  Result := DefaultInterface.ObjName[ObjID];
end;

procedure TF1Book6.Set_ObjName(ObjID: Integer; const Param2: WideString);
  { Warning: The property ObjName has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ObjName := Param2;
end;

function  TF1Book6.Get_ObjText(ObjID: Integer): WideString;
begin
  Result := DefaultInterface.ObjText[ObjID];
end;

procedure TF1Book6.Set_ObjText(ObjID: Integer; const Param2: WideString);
  { Warning: The property ObjText has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ObjText := Param2;
end;

function  TF1Book6.Get_ObjValue(ObjID: Integer): Smallint;
begin
  Result := DefaultInterface.ObjValue[ObjID];
end;

procedure TF1Book6.Set_ObjValue(ObjID: Integer; Param2: Smallint);
begin
  DefaultInterface.ObjValue[ObjID] := Param2;
end;

function  TF1Book6.Get_ObjVisible(ObjID: Integer): WordBool;
begin
  Result := DefaultInterface.ObjVisible[ObjID];
end;

procedure TF1Book6.Set_ObjVisible(ObjID: Integer; Param2: WordBool);
begin
  DefaultInterface.ObjVisible[ObjID] := Param2;
end;

function  TF1Book6.Get_AutoFillItems(nIndex: Smallint): WideString;
begin
  Result := DefaultInterface.AutoFillItems[nIndex];
end;

procedure TF1Book6.Set_AutoFillItems(nIndex: Smallint; const Param2: WideString);
  { Warning: The property AutoFillItems has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AutoFillItems := Param2;
end;

function  TF1Book6.Get_ColHidden(nCol: Integer): WordBool;
begin
  Result := DefaultInterface.ColHidden[nCol];
end;

procedure TF1Book6.Set_ColHidden(nCol: Integer; Param2: WordBool);
begin
  DefaultInterface.ColHidden[nCol] := Param2;
end;

function  TF1Book6.Get_RowHidden(nRow: Integer): WordBool;
begin
  Result := DefaultInterface.RowHidden[nRow];
end;

procedure TF1Book6.Set_RowHidden(nRow: Integer; Param2: WordBool);
begin
  DefaultInterface.RowHidden[nRow] := Param2;
end;

function  TF1Book6.Get_SheetSelected(nSheet: Integer): WordBool;
begin
  Result := DefaultInterface.SheetSelected[nSheet];
end;

procedure TF1Book6.Set_SheetSelected(nSheet: Integer; Param2: WordBool);
begin
  DefaultInterface.SheetSelected[nSheet] := Param2;
end;

function  TF1Book6.Get_EntrySRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.EntrySRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_EntrySRC(nSheet: Integer; nRow: Integer; nCol: Integer; 
                                const Param4: WideString);
  { Warning: The property EntrySRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.EntrySRC := Param4;
end;

function  TF1Book6.Get_FormattedTextSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormattedTextSRC[nSheet, nRow, nCol];
end;

function  TF1Book6.Get_FormulaSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormulaSRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_FormulaSRC(nSheet: Integer; nRow: Integer; nCol: Integer; 
                                  const Param4: WideString);
  { Warning: The property FormulaSRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FormulaSRC := Param4;
end;

function  TF1Book6.Get_LogicalSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WordBool;
begin
  Result := DefaultInterface.LogicalSRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_LogicalSRC(nSheet: Integer; nRow: Integer; nCol: Integer; Param4: WordBool);
begin
  DefaultInterface.LogicalSRC[nSheet, nRow, nCol] := Param4;
end;

function  TF1Book6.Get_NumberSRC(nSheet: Integer; nRow: Integer; nCol: Integer): Double;
begin
  Result := DefaultInterface.NumberSRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_NumberSRC(nSheet: Integer; nRow: Integer; nCol: Integer; Param4: Double);
begin
  DefaultInterface.NumberSRC[nSheet, nRow, nCol] := Param4;
end;

function  TF1Book6.Get_TextSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.TextSRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_TextSRC(nSheet: Integer; nRow: Integer; nCol: Integer; 
                               const Param4: WideString);
  { Warning: The property TextSRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TextSRC := Param4;
end;

function  TF1Book6.Get_TypeSRC(nSheet: Integer; nRow: Integer; nCol: Integer): Smallint;
begin
  Result := DefaultInterface.TypeSRC[nSheet, nRow, nCol];
end;

function  TF1Book6.Get_FormulaLocalRC(nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormulaLocalRC[nRow, nCol];
end;

procedure TF1Book6.Set_FormulaLocalRC(nRow: Integer; nCol: Integer; const Param3: WideString);
  { Warning: The property FormulaLocalRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FormulaLocalRC[nRow,nCol] := Param3;
end;

function  TF1Book6.Get_FormulaLocalSRC(nSheet: Integer; nRow: Integer; nCol: Integer): WideString;
begin
  Result := DefaultInterface.FormulaLocalSRC[nSheet, nRow, nCol];
end;

procedure TF1Book6.Set_FormulaLocalSRC(nSheet: Integer; nRow: Integer; nCol: Integer; 
                                       const Param4: WideString);
  { Warning: The property FormulaLocalSRC has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FormulaLocalSRC := Param4;
end;

function  TF1Book6.Get_DefinedNameLocal(const Name: WideString): WideString;
begin
  Result := DefaultInterface.DefinedNameLocal[Name];
end;

procedure TF1Book6.Set_DefinedNameLocal(const Name: WideString; const Param2: WideString);
  { Warning: The property DefinedNameLocal has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DefinedNameLocal := Param2;
end;

function  TF1Book6.Get_SelectionEx(nSelection: Smallint): IF1RangeRef;
begin
  Result := DefaultInterface.SelectionEx[nSelection];
end;

function  TF1Book6.Get_AddInPath(nAddIn: Smallint): WideString;
begin
  Result := DefaultInterface.AddInPath[nAddIn];
end;

function  TF1Book6.Get_AddInEnabled(nAddIn: Smallint): WordBool;
begin
  Result := DefaultInterface.AddInEnabled[nAddIn];
end;

procedure TF1Book6.Set_AddInEnabled(nAddIn: Smallint; Param2: WordBool);
begin
  DefaultInterface.AddInEnabled[nAddIn] := Param2;
end;

procedure TF1Book6.FormatCellsDlg(Pages: Integer);
begin
  DefaultInterface.FormatCellsDlg(Pages);
end;

procedure TF1Book6.EditPasteValues;
begin
  DefaultInterface.EditPasteValues;
end;

procedure TF1Book6.GetAlignment(out pHorizontal: Smallint; out pWordWrap: WordBool; 
                                out pVertical: Smallint; out pOrientation: Smallint);
begin
  DefaultInterface.GetAlignment(pHorizontal, pWordWrap, pVertical, pOrientation);
end;

procedure TF1Book6.GetBorder(out pLeft: Smallint; out pRight: Smallint; out pTop: Smallint; 
                             out pBottom: Smallint; out pShade: Smallint; out pcrLeft: Integer; 
                             out pcrRight: Integer; out pcrTop: Integer; out pcrBottom: Integer);
begin
  DefaultInterface.GetBorder(pLeft, pRight, pTop, pBottom, pShade, pcrLeft, pcrRight, pcrTop, 
                             pcrBottom);
end;

procedure TF1Book6.GetFont(out pName: WideString; out pSize: Smallint; out pBold: WordBool; 
                           out pItalic: WordBool; out pUnderline: WordBool; 
                           out pStrikeout: WordBool; out pcrColor: Integer; out pOutline: WordBool; 
                           out pShadow: WordBool);
begin
  DefaultInterface.GetFont(pName, pSize, pBold, pItalic, pUnderline, pStrikeout, pcrColor, 
                           pOutline, pShadow);
end;

procedure TF1Book6.GetLineStyle(out pStyle: Smallint; out pcrColor: Integer; out pWeight: Smallint);
begin
  DefaultInterface.GetLineStyle(pStyle, pcrColor, pWeight);
end;

procedure TF1Book6.GetPattern(out pPattern: Smallint; out pcrFG: Integer; out pcrBG: Integer);
begin
  DefaultInterface.GetPattern(pPattern, pcrFG, pcrBG);
end;

procedure TF1Book6.GetProtection(out pLocked: WordBool; out pHidden: WordBool);
begin
  DefaultInterface.GetProtection(pLocked, pHidden);
end;

procedure TF1Book6.GetTabbedText(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                                 bValuesOnly: WordBool; out phText: OLE_HANDLE);
begin
  DefaultInterface.GetTabbedText(nR1, nC1, nR2, nC2, bValuesOnly, phText);
end;

procedure TF1Book6.SetTabbedText(nStartRow: Integer; nStartCol: Integer; out pRows: Integer; 
                                 out pCols: Integer; bValuesOnly: WordBool; const pText: WideString);
begin
  DefaultInterface.SetTabbedText(nStartRow, nStartCol, pRows, pCols, bValuesOnly, pText);
end;

procedure TF1Book6.AddColPageBreak(nCol: Integer);
begin
  DefaultInterface.AddColPageBreak(nCol);
end;

procedure TF1Book6.AddPageBreak;
begin
  DefaultInterface.AddPageBreak;
end;

procedure TF1Book6.AddRowPageBreak(nRow: Integer);
begin
  DefaultInterface.AddRowPageBreak(nRow);
end;

procedure TF1Book6.AddSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer);
begin
  DefaultInterface.AddSelection(nRow1, nCol1, nRow2, nCol2);
end;

procedure TF1Book6.Attach(const Title: WideString);
begin
  DefaultInterface.Attach(Title);
end;

procedure TF1Book6.AttachToSS(hSrcSS: Integer);
begin
  DefaultInterface.AttachToSS(hSrcSS);
end;

procedure TF1Book6.CalculationDlg;
begin
  DefaultInterface.CalculationDlg;
end;

procedure TF1Book6.CancelEdit;
begin
  DefaultInterface.CancelEdit;
end;

procedure TF1Book6.CheckRecalc;
begin
  DefaultInterface.CheckRecalc;
end;

procedure TF1Book6.ClearClipboard;
begin
  DefaultInterface.ClearClipboard;
end;

procedure TF1Book6.ClearRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                              ClearType: F1ClearTypeConstants);
begin
  DefaultInterface.ClearRange(nRow1, nCol1, nRow2, nCol2, ClearType);
end;

procedure TF1Book6.ColorPaletteDlg;
begin
  DefaultInterface.ColorPaletteDlg;
end;

procedure TF1Book6.ColWidthDlg;
begin
  DefaultInterface.ColWidthDlg;
end;

procedure TF1Book6.CopyAll(hSrcSS: Integer);
begin
  DefaultInterface.CopyAll(hSrcSS);
end;

procedure TF1Book6.CopyRange(nDstR1: Integer; nDstC1: Integer; nDstR2: Integer; nDstC2: Integer; 
                             hSrcSS: Integer; nSrcR1: Integer; nSrcC1: Integer; nSrcR2: Integer; 
                             nSrcC2: Integer);
begin
  DefaultInterface.CopyRange(nDstR1, nDstC1, nDstR2, nDstC2, hSrcSS, nSrcR1, nSrcC1, nSrcR2, nSrcC2);
end;

procedure TF1Book6.DefinedNameDlg;
begin
  DefaultInterface.DefinedNameDlg;
end;

procedure TF1Book6.DeleteDefinedName(const pName: WideString);
begin
  DefaultInterface.DeleteDefinedName(pName);
end;

procedure TF1Book6.DeleteRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                               ShiftType: F1ShiftTypeConstants);
begin
  DefaultInterface.DeleteRange(nRow1, nCol1, nRow2, nCol2, ShiftType);
end;

procedure TF1Book6.Draw(hDC: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                        nRow: Integer; nCol: Integer; out pRows: Integer; out pCols: Integer; 
                        nFixedRow: Integer; nFixedCol: Integer; nFixedRows: Integer; 
                        nFixedCols: Integer);
begin
  DefaultInterface.Draw(hDC, x, y, cx, cy, nRow, nCol, pRows, pCols, nFixedRow, nFixedCol, 
                        nFixedRows, nFixedCols);
end;

procedure TF1Book6.EditClear(ClearType: F1ClearTypeConstants);
begin
  DefaultInterface.EditClear(ClearType);
end;

procedure TF1Book6.EditCopy;
begin
  DefaultInterface.EditCopy;
end;

procedure TF1Book6.EditCopyDown;
begin
  DefaultInterface.EditCopyDown;
end;

procedure TF1Book6.EditCopyRight;
begin
  DefaultInterface.EditCopyRight;
end;

procedure TF1Book6.EditCut;
begin
  DefaultInterface.EditCut;
end;

procedure TF1Book6.EditDelete(ShiftType: F1ShiftTypeConstants);
begin
  DefaultInterface.EditDelete(ShiftType);
end;

procedure TF1Book6.EditInsert(InsertType: F1ShiftTypeConstants);
begin
  DefaultInterface.EditInsert(InsertType);
end;

procedure TF1Book6.EditPaste;
begin
  DefaultInterface.EditPaste;
end;

procedure TF1Book6.EndEdit;
begin
  DefaultInterface.EndEdit;
end;

procedure TF1Book6.FilePageSetupDlg;
begin
  DefaultInterface.FilePageSetupDlg;
end;

procedure TF1Book6.FilePrint(bShowPrintDlg: WordBool);
begin
  DefaultInterface.FilePrint(bShowPrintDlg);
end;

procedure TF1Book6.FilePrintSetupDlg;
begin
  DefaultInterface.FilePrintSetupDlg;
end;

procedure TF1Book6.FormatAlignmentDlg;
begin
  DefaultInterface.FormatAlignmentDlg;
end;

procedure TF1Book6.FormatBorderDlg;
begin
  DefaultInterface.FormatBorderDlg;
end;

procedure TF1Book6.FormatCurrency0;
begin
  DefaultInterface.FormatCurrency0;
end;

procedure TF1Book6.FormatCurrency2;
begin
  DefaultInterface.FormatCurrency2;
end;

procedure TF1Book6.FormatDefaultFontDlg;
begin
  DefaultInterface.FormatDefaultFontDlg;
end;

procedure TF1Book6.FormatFixed;
begin
  DefaultInterface.FormatFixed;
end;

procedure TF1Book6.FormatFixed2;
begin
  DefaultInterface.FormatFixed2;
end;

procedure TF1Book6.FormatFontDlg;
begin
  DefaultInterface.FormatFontDlg;
end;

procedure TF1Book6.FormatFraction;
begin
  DefaultInterface.FormatFraction;
end;

procedure TF1Book6.FormatGeneral;
begin
  DefaultInterface.FormatGeneral;
end;

procedure TF1Book6.FormatHmmampm;
begin
  DefaultInterface.FormatHmmampm;
end;

procedure TF1Book6.FormatMdyy;
begin
  DefaultInterface.FormatMdyy;
end;

procedure TF1Book6.FormatNumberDlg;
begin
  DefaultInterface.FormatNumberDlg;
end;

procedure TF1Book6.FormatPatternDlg;
begin
  DefaultInterface.FormatPatternDlg;
end;

procedure TF1Book6.FormatPercent;
begin
  DefaultInterface.FormatPercent;
end;

procedure TF1Book6.FormatScientific;
begin
  DefaultInterface.FormatScientific;
end;

procedure TF1Book6.GetActiveCell(out pRow: Integer; out pCol: Integer);
begin
  DefaultInterface.GetActiveCell(pRow, pCol);
end;

procedure TF1Book6.GetDefaultFont(out pBuf: WideString; out pSize: Smallint);
begin
  DefaultInterface.GetDefaultFont(pBuf, pSize);
end;

procedure TF1Book6.GetHdrSelection(out pTopLeftHdr: WordBool; out pRowHdr: WordBool; 
                                   out pColHdr: WordBool);
begin
  DefaultInterface.GetHdrSelection(pTopLeftHdr, pRowHdr, pColHdr);
end;

procedure TF1Book6.GetIteration(out pIteration: WordBool; out pMaxIterations: Smallint; 
                                out pMaxChange: Double);
begin
  DefaultInterface.GetIteration(pIteration, pMaxIterations, pMaxChange);
end;

procedure TF1Book6.GetPrintScale(out pScale: Smallint; out pFitToPage: WordBool; 
                                 out pVPages: Integer; out pHPages: Integer);
begin
  DefaultInterface.GetPrintScale(pScale, pFitToPage, pVPages, pHPages);
end;

procedure TF1Book6.GetSelection(nSelection: Smallint; out pR1: Integer; out pC1: Integer; 
                                out pR2: Integer; out pC2: Integer);
begin
  DefaultInterface.GetSelection(nSelection, pR1, pC1, pR2, pC2);
end;

procedure TF1Book6.GotoDlg;
begin
  DefaultInterface.GotoDlg;
end;

procedure TF1Book6.HeapMin;
begin
  DefaultInterface.HeapMin;
end;

procedure TF1Book6.InitTable;
begin
  DefaultInterface.InitTable;
end;

procedure TF1Book6.InsertRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                               InsertType: F1ShiftTypeConstants);
begin
  DefaultInterface.InsertRange(nRow1, nCol1, nRow2, nCol2, InsertType);
end;

procedure TF1Book6.LineStyleDlg;
begin
  DefaultInterface.LineStyleDlg;
end;

procedure TF1Book6.MoveRange(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                             nRowOffset: Integer; nColOffset: Integer);
begin
  DefaultInterface.MoveRange(nRow1, nCol1, nRow2, nCol2, nRowOffset, nColOffset);
end;

procedure TF1Book6.ObjAddItem(ObjID: Integer; const ItemText: WideString);
begin
  DefaultInterface.ObjAddItem(ObjID, ItemText);
end;

procedure TF1Book6.ObjAddSelection(ObjID: Integer);
begin
  DefaultInterface.ObjAddSelection(ObjID);
end;

procedure TF1Book6.ObjBringToFront;
begin
  DefaultInterface.ObjBringToFront;
end;

procedure TF1Book6.ObjDeleteItem(ObjID: Integer; nItem: Smallint);
begin
  DefaultInterface.ObjDeleteItem(ObjID, nItem);
end;

procedure TF1Book6.ObjGetCell(ObjID: Integer; out pControlCellType: Smallint; out pRow: Integer; 
                              out pCol: Integer);
begin
  DefaultInterface.ObjGetCell(ObjID, pControlCellType, pRow, pCol);
end;

procedure TF1Book6.ObjGetPos(ObjID: Integer; out pX1: Single; out pY1: Single; out pX2: Single; 
                             out pY2: Single);
begin
  DefaultInterface.ObjGetPos(ObjID, pX1, pY1, pX2, pY2);
end;

procedure TF1Book6.ObjGetSelection(nSelection: Smallint; out pID: Integer);
begin
  DefaultInterface.ObjGetSelection(nSelection, pID);
end;

procedure TF1Book6.ObjInsertItem(ObjID: Integer; nItem: Smallint; const ItemText: WideString);
begin
  DefaultInterface.ObjInsertItem(ObjID, nItem, ItemText);
end;

procedure TF1Book6.ObjNameDlg;
begin
  DefaultInterface.ObjNameDlg;
end;

procedure TF1Book6.ObjNew(ObjType: Smallint; nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                          out pID: Integer);
begin
  DefaultInterface.ObjNew(ObjType, nX1, nY1, nX2, nY2, pID);
end;

procedure TF1Book6.ObjNewPicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                                 out pID: Integer; hMF: OLE_HANDLE; nMapMode: Integer; 
                                 nWndExtentX: Integer; nWndExtentY: Integer);
begin
  DefaultInterface.ObjNewPicture(nX1, nY1, nX2, nY2, pID, hMF, nMapMode, nWndExtentX, nWndExtentY);
end;

procedure TF1Book6.ObjOptionsDlg;
begin
  DefaultInterface.ObjOptionsDlg;
end;

procedure TF1Book6.ObjPosToTwips(nX1: Single; nY1: Single; nX2: Single; nY2: Single; 
                                 out pX: Integer; out pY: Integer; out pCX: Integer; 
                                 out pCY: Integer; out pShown: Smallint);
begin
  DefaultInterface.ObjPosToTwips(nX1, nY1, nX2, nY2, pX, pY, pCX, pCY, pShown);
end;

procedure TF1Book6.ObjSendToBack;
begin
  DefaultInterface.ObjSendToBack;
end;

procedure TF1Book6.ObjSetCell(ObjID: Integer; CellType: Smallint; nRow: Integer; nCol: Integer);
begin
  DefaultInterface.ObjSetCell(ObjID, CellType, nRow, nCol);
end;

procedure TF1Book6.ObjSetPicture(ObjID: Integer; hMF: OLE_HANDLE; nMapMode: Smallint; 
                                 nWndExtentX: Integer; nWndExtentY: Integer);
begin
  DefaultInterface.ObjSetPicture(ObjID, hMF, nMapMode, nWndExtentX, nWndExtentY);
end;

procedure TF1Book6.ObjSetPos(ObjID: Integer; nX1: Single; nY1: Single; nX2: Single; nY2: Single);
begin
  DefaultInterface.ObjSetPos(ObjID, nX1, nY1, nX2, nY2);
end;

procedure TF1Book6.ObjSetSelection(ObjID: Integer);
begin
  DefaultInterface.ObjSetSelection(ObjID);
end;

procedure TF1Book6.OpenFileDlg(const pTitle: WideString; hWndParent: OLE_HANDLE; 
                               out pBuf: WideString);
begin
  DefaultInterface.OpenFileDlg(pTitle, hWndParent, pBuf);
end;

procedure TF1Book6.ProtectionDlg;
begin
  DefaultInterface.ProtectionDlg;
end;

procedure TF1Book6.RangeToTwips(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                                out pX: Integer; out pY: Integer; out pCX: Integer; 
                                out pCY: Integer; out pShown: Smallint);
begin
  DefaultInterface.RangeToTwips(nRow1, nCol1, nRow2, nCol2, pX, pY, pCX, pCY, pShown);
end;

procedure TF1Book6.Read(const pPathName: WideString; out pFileType: Smallint);
begin
  DefaultInterface.Read(pPathName, pFileType);
end;

procedure TF1Book6.ReadFromBlob(hBlob: OLE_HANDLE; nReservedBytes: Smallint);
begin
  DefaultInterface.ReadFromBlob(hBlob, nReservedBytes);
end;

procedure TF1Book6.Recalc;
begin
  DefaultInterface.Recalc;
end;

procedure TF1Book6.RemoveColPageBreak(nCol: Integer);
begin
  DefaultInterface.RemoveColPageBreak(nCol);
end;

procedure TF1Book6.RemovePageBreak;
begin
  DefaultInterface.RemovePageBreak;
end;

procedure TF1Book6.RemoveRowPageBreak(nRow: Integer);
begin
  DefaultInterface.RemoveRowPageBreak(nRow);
end;

procedure TF1Book6.RowHeightDlg;
begin
  DefaultInterface.RowHeightDlg;
end;

procedure TF1Book6.SaveFileDlg(const pTitle: WideString; out pBuf: WideString; 
                               out pFileType: Smallint);
begin
  DefaultInterface.SaveFileDlg(pTitle, pBuf, pFileType);
end;

procedure TF1Book6.SaveWindowInfo;
begin
  DefaultInterface.SaveWindowInfo;
end;

procedure TF1Book6.SetActiveCell(nRow: Integer; nCol: Integer);
begin
  DefaultInterface.SetActiveCell(nRow, nCol);
end;

procedure TF1Book6.SetAlignment(HAlign: Smallint; bWordWrap: WordBool; VAlign: Smallint; 
                                nOrientation: Smallint);
begin
  DefaultInterface.SetAlignment(HAlign, bWordWrap, VAlign, nOrientation);
end;

procedure TF1Book6.SetBorder(nOutline: Smallint; nLeft: Smallint; nRight: Smallint; nTop: Smallint; 
                             nBottom: Smallint; nShade: Smallint; crOutline: OLE_COLOR; 
                             crLeft: OLE_COLOR; crRight: OLE_COLOR; crTop: OLE_COLOR; 
                             crBottom: OLE_COLOR);
begin
  DefaultInterface.SetBorder(nOutline, nLeft, nRight, nTop, nBottom, nShade, crOutline, crLeft, 
                             crRight, crTop, crBottom);
end;

procedure TF1Book6.SetColWidth(nCol1: Integer; nCol2: Integer; nWidth: Smallint; 
                               bDefColWidth: WordBool);
begin
  DefaultInterface.SetColWidth(nCol1, nCol2, nWidth, bDefColWidth);
end;

procedure TF1Book6.SetColWidthAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                                   bSetDefaults: WordBool);
begin
  DefaultInterface.SetColWidthAuto(nRow1, nCol1, nRow2, nCol2, bSetDefaults);
end;

procedure TF1Book6.SetDefaultFont(const Name: WideString; nSize: Smallint);
begin
  DefaultInterface.SetDefaultFont(Name, nSize);
end;

procedure TF1Book6.SetFont(const pName: WideString; nSize: Smallint; bBold: WordBool; 
                           bItalic: WordBool; bUnderline: WordBool; bStrikeout: WordBool; 
                           crColor: OLE_COLOR; bOutline: WordBool; bShadow: WordBool);
begin
  DefaultInterface.SetFont(pName, nSize, bBold, bItalic, bUnderline, bStrikeout, crColor, bOutline, 
                           bShadow);
end;

procedure TF1Book6.SetHdrSelection(bTopLeftHdr: WordBool; bRowHdr: WordBool; bColHdr: WordBool);
begin
  DefaultInterface.SetHdrSelection(bTopLeftHdr, bRowHdr, bColHdr);
end;

procedure TF1Book6.SetIteration(bIteration: WordBool; nMaxIterations: Smallint; nMaxChange: Double);
begin
  DefaultInterface.SetIteration(bIteration, nMaxIterations, nMaxChange);
end;

procedure TF1Book6.SetLineStyle(nStyle: Smallint; crColor: OLE_COLOR; nWeight: Smallint);
begin
  DefaultInterface.SetLineStyle(nStyle, crColor, nWeight);
end;

procedure TF1Book6.SetPattern(nPattern: Smallint; crFG: OLE_COLOR; crBG: OLE_COLOR);
begin
  DefaultInterface.SetPattern(nPattern, crFG, crBG);
end;

procedure TF1Book6.SetPrintAreaFromSelection;
begin
  DefaultInterface.SetPrintAreaFromSelection;
end;

procedure TF1Book6.SetPrintScale(nScale: Smallint; bFitToPage: WordBool; nVPages: Smallint; 
                                 nHPages: Smallint);
begin
  DefaultInterface.SetPrintScale(nScale, bFitToPage, nVPages, nHPages);
end;

procedure TF1Book6.SetPrintTitlesFromSelection;
begin
  DefaultInterface.SetPrintTitlesFromSelection;
end;

procedure TF1Book6.SetProtection(bLocked: WordBool; bHidden: WordBool);
begin
  DefaultInterface.SetProtection(bLocked, bHidden);
end;

procedure TF1Book6.SetRowHeight(nRow1: Integer; nRow2: Integer; nHeight: Smallint; 
                                bDefRowHeight: WordBool);
begin
  DefaultInterface.SetRowHeight(nRow1, nRow2, nHeight, bDefRowHeight);
end;

procedure TF1Book6.SetRowHeightAuto(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                                    bSetDefaults: WordBool);
begin
  DefaultInterface.SetRowHeightAuto(nRow1, nCol1, nRow2, nCol2, bSetDefaults);
end;

procedure TF1Book6.SetSelection(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer);
begin
  DefaultInterface.SetSelection(nRow1, nCol1, nRow2, nCol2);
end;

procedure TF1Book6.ShowActiveCell;
begin
  DefaultInterface.ShowActiveCell;
end;

procedure TF1Book6.Sort3(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer; 
                         bSortByRows: WordBool; nKey1: Integer; nKey2: Integer; nKey3: Integer);
begin
  DefaultInterface.Sort3(nRow1, nCol1, nRow2, nCol2, bSortByRows, nKey1, nKey2, nKey3);
end;

procedure TF1Book6.SortDlg;
begin
  DefaultInterface.SortDlg;
end;

procedure TF1Book6.StartEdit(bClear: WordBool; bInCellEditFocus: WordBool; 
                             bArrowsExitEditMode: WordBool);
begin
  DefaultInterface.StartEdit(bClear, bInCellEditFocus, bArrowsExitEditMode);
end;

procedure TF1Book6.SwapTables(hSS2: OLE_HANDLE);
begin
  DefaultInterface.SwapTables(hSS2);
end;

procedure TF1Book6.TransactCommit;
begin
  DefaultInterface.TransactCommit;
end;

procedure TF1Book6.TransactRollback;
begin
  DefaultInterface.TransactRollback;
end;

procedure TF1Book6.TransactStart;
begin
  DefaultInterface.TransactStart;
end;

procedure TF1Book6.TwipsToRC(x: Integer; y: Integer; out pRow: Integer; out pCol: Integer);
begin
  DefaultInterface.TwipsToRC(x, y, pRow, pCol);
end;

procedure TF1Book6.SSUpdate;
begin
  DefaultInterface.SSUpdate;
end;

function  TF1Book6.SSVersion: Smallint;
begin
  result:=DefaultInterface.SSVersion;
end;

procedure TF1Book6.Write(const PathName: WideString; FileType: Smallint);
begin
  DefaultInterface.Write(PathName, FileType);
end;

procedure TF1Book6.WriteToBlob(out phBlob: OLE_HANDLE; nReservedBytes: Smallint);
begin
  DefaultInterface.WriteToBlob(phBlob, nReservedBytes);
end;

procedure TF1Book6.SetRowHidden(nRow1: Integer; nRow2: Integer; bHidden: WordBool);
begin
  DefaultInterface.SetRowHidden(nRow1, nRow2, bHidden);
end;

procedure TF1Book6.SetColHidden(nCol1: Integer; nCol2: Integer; bHidden: WordBool);
begin
  DefaultInterface.SetColHidden(nCol1, nCol2, bHidden);
end;

procedure TF1Book6.SetColWidthTwips(nCol1: Integer; nCol2: Integer; nWidth: Smallint; 
                                    bDefColWidth: WordBool);
begin
  DefaultInterface.SetColWidthTwips(nCol1, nCol2, nWidth, bDefColWidth);
end;

procedure TF1Book6.EditInsertSheets;
begin
  DefaultInterface.EditInsertSheets;
end;

procedure TF1Book6.EditDeleteSheets;
begin
  DefaultInterface.EditDeleteSheets;
end;

procedure TF1Book6.InsertSheets(nSheet: Integer; nSheets: Integer);
begin
  DefaultInterface.InsertSheets(nSheet, nSheets);
end;

procedure TF1Book6.DeleteSheets(nSheet: Integer; nSheets: Integer);
begin
  DefaultInterface.DeleteSheets(nSheet, nSheets);
end;

procedure TF1Book6.Refresh;
begin
  DefaultInterface.Refresh;
end;

function  TF1Book6.NextColPageBreak(Col: Integer): Integer;
begin
  result:=DefaultInterface.NextColPageBreak(Col);
end;

function  TF1Book6.NextRowPageBreak(Row: Integer): Integer;
begin
  result:=DefaultInterface.NextRowPageBreak(Row);
end;

function  TF1Book6.ObjFirstID: Integer;
begin
  result:=DefaultInterface.ObjFirstID;
end;

function  TF1Book6.ObjNextID(ObjID: Integer): Integer;
begin
  result:=DefaultInterface.ObjNextID(ObjID);
end;

function  TF1Book6.ObjGetItemCount(ObjID: Integer): Smallint;
begin
  result:=DefaultInterface.ObjGetItemCount(ObjID);
end;

function  TF1Book6.ObjGetType(ObjID: Integer): F1ObjTypeConstants;
begin
  result:=DefaultInterface.ObjGetType(ObjID);
end;

function  TF1Book6.ObjGetSelectionCount: Smallint;
begin
  result:=DefaultInterface.ObjGetSelectionCount;
end;

function  TF1Book6.FormatRCNr(Row: Integer; Col: Integer; DoAbsolute: WordBool): WideString;
begin
  result:=DefaultInterface.FormatRCNr(Row, Col, DoAbsolute);
end;

function  TF1Book6.SS: Integer;
begin
  result:=DefaultInterface.SS;
end;

function  TF1Book6.ObjNameToID(const Name: WideString): Integer;
begin
  result:=DefaultInterface.ObjNameToID(Name);
end;

function  TF1Book6.DefinedNameCount: Integer;
begin
  result:=DefaultInterface.DefinedNameCount;
end;

procedure TF1Book6.ValidationRuleDlg;
begin
  DefaultInterface.ValidationRuleDlg;
end;

procedure TF1Book6.SetValidationRule(const Rule: WideString; const Text: WideString);
begin
  DefaultInterface.SetValidationRule(Rule, Text);
end;

procedure TF1Book6.GetValidationRule(out Rule: WideString; out Text: WideString);
begin
  DefaultInterface.GetValidationRule(Rule, Text);
end;

function  TF1Book6.AutoFillItemsCount: Smallint;
begin
  result:=DefaultInterface.AutoFillItemsCount;
end;

procedure TF1Book6.CopyRangeEx(nDstSheet: Integer; nDstR1: Integer; nDstC1: Integer; 
                               nDstR2: Integer; nDstC2: Integer; hSrcSS: Integer; 
                               nSrcSheet: Integer; nSrcR1: Integer; nSrcC1: Integer; 
                               nSrcR2: Integer; nSrcC2: Integer);
begin
  DefaultInterface.CopyRangeEx(nDstSheet, nDstR1, nDstC1, nDstR2, nDstC2, hSrcSS, nSrcSheet, 
                               nSrcR1, nSrcC1, nSrcR2, nSrcC2);
end;

procedure TF1Book6.Sort(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer; 
                        bSortByRows: WordBool; Keys: OleVariant);
begin
  DefaultInterface.Sort(nR1, nC1, nR2, nC2, bSortByRows, Keys);
end;

procedure TF1Book6.DeleteAutoFillItems(nIndex: Smallint);
begin
  DefaultInterface.DeleteAutoFillItems(nIndex);
end;

procedure TF1Book6.ODBCConnect(var pConnect: WideString; bShowErrors: WordBool; 
                               out pRetCode: Smallint);
begin
  DefaultInterface.ODBCConnect(pConnect, bShowErrors, pRetCode);
end;

procedure TF1Book6.ODBCDisconnect;
begin
  DefaultInterface.ODBCDisconnect;
end;

procedure TF1Book6.ODBCQuery(var pQuery: WideString; nRow: Integer; nCol: Integer; 
                             bForceShowDlg: WordBool; var pSetColNames: WordBool; 
                             var pSetColFormats: WordBool; var pSetColWidths: WordBool; 
                             var pSetMaxRC: WordBool; out pRetCode: Smallint);
begin
  DefaultInterface.ODBCQuery(pQuery, nRow, nCol, bForceShowDlg, pSetColNames, pSetColFormats, 
                             pSetColWidths, pSetMaxRC, pRetCode);
end;

procedure TF1Book6.LaunchDesigner;
begin
  DefaultInterface.LaunchDesigner;
end;

procedure TF1Book6.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

procedure TF1Book6.PrintPreviewDC(hDC: OLE_HANDLE; nPage: Smallint; out pPages: Smallint);
begin
  DefaultInterface.PrintPreviewDC(hDC, nPage, pPages);
end;

procedure TF1Book6.PrintPreview(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer; cy: Integer; 
                                nPage: Smallint; out pPages: Smallint);
begin
  DefaultInterface.PrintPreview(hWnd, x, y, cx, cy, nPage, pPages);
end;

procedure TF1Book6.WriteRange(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                              nCol2: Integer; const pPathName: WideString; FileType: Smallint);
begin
  DefaultInterface.WriteRange(nSheet, nRow1, nCol1, nRow2, nCol2, pPathName, FileType);
end;

procedure TF1Book6.InsertHTML(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                              nCol2: Integer; const pPathName: WideString; bDataOnly: WordBool; 
                              const pAnchorName: WideString);
begin
  DefaultInterface.InsertHTML(nSheet, nRow1, nCol1, nRow2, nCol2, pPathName, bDataOnly, pAnchorName);
end;

procedure TF1Book6.FilePrintEx(bShowPrintDlg: WordBool; bPrintWorkbook: WordBool);
begin
  DefaultInterface.FilePrintEx(bShowPrintDlg, bPrintWorkbook);
end;

procedure TF1Book6.FilePrintPreview;
begin
  DefaultInterface.FilePrintPreview;
end;

procedure TF1Book6.CopyDataFromArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; 
                                     nRow2: Integer; nCol2: Integer; bValuesOnly: WordBool; 
                                     Array_: OleVariant);
begin
  DefaultInterface.CopyDataFromArray(nSheet, nRow1, nCol1, nRow2, nCol2, bValuesOnly, Array_);
end;

procedure TF1Book6.CopyDataToArray(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                                   nCol2: Integer; bValuesOnly: WordBool; Array_: OleVariant);
begin
  DefaultInterface.CopyDataToArray(nSheet, nRow1, nCol1, nRow2, nCol2, bValuesOnly, Array_);
end;

procedure TF1Book6.FindDlg;
begin
  DefaultInterface.FindDlg;
end;

procedure TF1Book6.ReplaceDlg;
begin
  DefaultInterface.ReplaceDlg;
end;

procedure TF1Book6.Find(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; 
                        nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint; 
                        out pFound: Integer);
begin
  DefaultInterface.Find(FindWhat, nSheet, nRow1, nCol1, nRow2, nCol2, Flags, pFound);
end;

procedure TF1Book6.Replace(const FindWhat: WideString; const ReplaceWith: WideString; 
                           nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                           nCol2: Integer; Flags: Smallint; out pFound: Integer; 
                           out pReplaced: Integer);
begin
  DefaultInterface.Replace(FindWhat, ReplaceWith, nSheet, nRow1, nCol1, nRow2, nCol2, Flags, 
                           pFound, pReplaced);
end;

procedure TF1Book6.ODBCError(out pSQLState: WideString; out pNativeError: Integer; 
                             out pErrorMsg: WideString);
begin
  DefaultInterface.ODBCError(pSQLState, pNativeError, pErrorMsg);
end;

procedure TF1Book6.ODBCPrepare(const SQLStr: WideString; out pRetCode: Smallint);
begin
  DefaultInterface.ODBCPrepare(SQLStr, pRetCode);
end;

procedure TF1Book6.ODBCBindParameter(nParam: Integer; nCol: Integer; CDataType: Smallint; 
                                     out pRetCode: Smallint);
begin
  DefaultInterface.ODBCBindParameter(nParam, nCol, CDataType, pRetCode);
end;

procedure TF1Book6.ODBCExecute(nRow1: Integer; nRow2: Integer; out pRetCode: Smallint);
begin
  DefaultInterface.ODBCExecute(nRow1, nRow2, pRetCode);
end;

procedure TF1Book6.InsertDlg;
begin
  DefaultInterface.InsertDlg;
end;

procedure TF1Book6.ObjNewPolygon(X1: Single; Y1: Single; X2: Single; Y2: Single; out pID: Integer; 
                                 ArrayX: OleVariant; ArrayY: OleVariant; bClosed: WordBool);
begin
  DefaultInterface.ObjNewPolygon(X1, Y1, X2, Y2, pID, ArrayX, ArrayY, bClosed);
end;

procedure TF1Book6.ObjSetPolygonPoints(nID: Integer; ArrayX: OleVariant; ArrayY: OleVariant; 
                                       bClosed: WordBool);
begin
  DefaultInterface.ObjSetPolygonPoints(nID, ArrayX, ArrayY, bClosed);
end;

procedure TF1Book6.DefRowHeightDlg;
begin
  DefaultInterface.DefRowHeightDlg;
end;

procedure TF1Book6.DefColWidthDlg;
begin
  DefaultInterface.DefColWidthDlg;
end;

procedure TF1Book6.DeleteDlg;
begin
  DefaultInterface.DeleteDlg;
end;

procedure TF1Book6.FormatObjectDlg(Pages: Integer);
begin
  DefaultInterface.FormatObjectDlg(Pages);
end;

procedure TF1Book6.OptionsDlg(Pages: Integer);
begin
  DefaultInterface.OptionsDlg(Pages);
end;

procedure TF1Book6.FormatSheetDlg(Pages: Integer; bDesignerMode: WordBool);
begin
  DefaultInterface.FormatSheetDlg(Pages, bDesignerMode);
end;

function  TF1Book6.GetTabbedTextEx(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer;
                                   bValuesOnly: WordBool): WideString;
begin
  result:=DefaultInterface.GetTabbedTextEx(nR1, nC1, nR2, nC2, bValuesOnly);
end;

function  TF1Book6.SetTabbedTextEx(nStartRow: Integer; nStartCol: Integer; bValuesOnly: WordBool;
                                   const pText: WideString): IF1RangeRef;
begin
  result:=DefaultInterface.SetTabbedTextEx(nStartRow, nStartCol, bValuesOnly, pText);
end;

function  TF1Book6.ObjCreate(ObjType: F1ObjTypeConstants; nX1: Single; nY1: Single; nX2: Single;
                             nY2: Single): Integer;
begin
  result:=DefaultInterface.ObjCreate(ObjType, nX1, nY1, nX2, nY2);
end;

function  TF1Book6.ObjCreatePicture(nX1: Single; nY1: Single; nX2: Single; nY2: Single;
                                    hMF: OLE_HANDLE; nMapMode: Integer; nWndExtentX: Integer;
                                    nWndExtentY: Integer): Integer;
begin
  result:=DefaultInterface.ObjCreatePicture(nX1, nY1, nX2, nY2, hMF, nMapMode, nWndExtentX, nWndExtentY);
end;

function  TF1Book6.ReadEx(const pPathName: WideString): F1FileTypeConstants;
begin
  result:=DefaultInterface.ReadEx(pPathName);
end;

function  TF1Book6.WriteToBlobEx(nReservedBytes: Smallint): OLE_HANDLE;
begin
  result:=DefaultInterface.WriteToBlobEx(nReservedBytes);
end;

function  TF1Book6.ObjCreatePolygon(X1: Single; Y1: Single; X2: Single; Y2: Single;
                                    ArrayX: OleVariant; ArrayY: OleVariant; bClosed: WordBool): Integer;
begin
  result:=DefaultInterface.ObjCreatePolygon(X1, Y1, X2, Y2, ArrayX, ArrayY, bClosed);
end;

function  TF1Book6.ObjGetPosEx(ObjID: Integer): IF1ObjPos;
begin
  result:=DefaultInterface.ObjGetPosEx(ObjID);
end;

function  TF1Book6.ObjPosShown(X1: Single; Y1: Single; X2: Single; Y2: Single): Smallint;
begin
  result:=DefaultInterface.ObjPosShown(X1, Y1, X2, Y2);
end;

function  TF1Book6.ObjPosToTwipsEx(X1: Single; Y1: Single; X2: Single; Y2: Single): IF1Rect;
begin
  result:=DefaultInterface.ObjPosToTwipsEx(X1, Y1, X2, Y2);
end;

function  TF1Book6.RangeToTwipsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect;
begin
  result:=DefaultInterface.RangeToTwipsEx(nRow1, nCol1, nRow2, nCol2);
end;

function  TF1Book6.RangeShown(nR1: Integer; nC1: Integer; nR2: Integer; nC2: Integer): Smallint;
begin
  result:=DefaultInterface.RangeShown(nR1, nC1, nR2, nC2);
end;

function  TF1Book6.TwipsToRow(nTwips: Integer): Integer;
begin
  result:=DefaultInterface.TwipsToRow(nTwips);
end;

function  TF1Book6.TwipsToCol(nTwips: Integer): Integer;
begin
  result:=DefaultInterface.TwipsToCol(nTwips);
end;

function  TF1Book6.PrintPreviewDCEx(hDC: OLE_HANDLE; nPage: Smallint): Smallint;
begin
  result:=DefaultInterface.PrintPreviewDCEx(hDC, nPage);
end;

function  TF1Book6.PrintPreviewEx(hWnd: OLE_HANDLE; x: Integer; y: Integer; cx: Integer;
                                  cy: Integer; nPage: Smallint): Smallint;
begin
  result:=DefaultInterface.PrintPreviewEx(hWnd, x, y, cx, cy, nPage);
end;

procedure TF1Book6.SaveFileDlgEx(const Title: WideString; const pFileSpec: IF1FileSpec);
begin
  DefaultInterface.SaveFileDlgEx(Title, pFileSpec);
end;

procedure TF1Book6.ODBCConnectEx(const pConnectObj: IF1ODBCConnect; bShowErrors: WordBool);
begin
  DefaultInterface.ODBCConnectEx(pConnectObj, bShowErrors);
end;

procedure TF1Book6.ODBCQueryEx(const pQueryObj: IF1ODBCQuery; nRow: Integer; nCol: Integer; 
                               bForceShowDlg: WordBool);
begin
  DefaultInterface.ODBCQueryEx(pQueryObj, nRow, nCol, bForceShowDlg);
end;

function  TF1Book6.ODBCPrepareEx(const SQLStr: WideString): Smallint;
begin
  result:=DefaultInterface.ODBCPrepareEx(SQLStr);
end;

function  TF1Book6.ODBCBindParameterEx(nParam: Integer; nCol: Integer;
                                       CDataType: F1CDataTypesConstants): Smallint;
begin
  result:=DefaultInterface.ODBCBindParameterEx(nParam, nCol, CDataType);
end;

function  TF1Book6.ODBCExecuteEx(nRow1: Integer; nRow2: Integer): Smallint;
begin
  result:=DefaultInterface.ODBCExecuteEx(nRow1, nRow2);
end;

function  TF1Book6.FindEx(const FindWhat: WideString; nSheet: Integer; nRow1: Integer;
                          nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint): Integer;
begin
  result:=DefaultInterface.FindEx(FindWhat, nSheet, nRow1, nCol1, nRow2, nCol2, Flags);
end;

function  TF1Book6.ReplaceEx(const FindWhat: WideString; const ReplaceWith: WideString;
                             nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer;
                             nCol2: Integer; Flags: Smallint): IF1ReplaceResults;
begin
  result:=DefaultInterface.ReplaceEx(FindWhat, ReplaceWith, nSheet, nRow1, nCol1, nRow2, nCol2, Flags);
end;

function  TF1Book6.ODBCQueryKludge: IF1ODBCQuery;
begin
  result:=DefaultInterface.ODBCQueryKludge;
end;

function  TF1Book6.ODBCConnectKludge: IF1ODBCConnect;
begin
  result:=DefaultInterface.ODBCConnectKludge;
end;

function  TF1Book6.OpenFileDlgEx(const pTitle: WideString; hWndParent: OLE_HANDLE): WideString;
begin
  result:=DefaultInterface.OpenFileDlgEx(pTitle, hWndParent);
end;

function  TF1Book6.CreateBookView: IF1BookView;
begin
  result:=DefaultInterface.CreateBookView;
end;

function  TF1Book6.FileSpecKludge: IF1FileSpec;
begin
  result:=DefaultInterface.FileSpecKludge;
end;

procedure TF1Book6.EditPasteSpecial(PasteWhat: F1PasteWhatConstants; PasteOp: F1PasteOpConstants);
begin
  DefaultInterface.EditPasteSpecial(PasteWhat, PasteOp);
end;

procedure TF1Book6.PasteSpecialDlg;
begin
  DefaultInterface.PasteSpecialDlg;
end;

function  TF1Book6.GetFirstNumberFormat: IF1NumberFormat;
begin
  result:=DefaultInterface.GetFirstNumberFormat;
end;

procedure TF1Book6.GetNextNumberFormat(const pNumberFormat: IF1NumberFormat);
begin
  DefaultInterface.GetNextNumberFormat(pNumberFormat);
end;

function  TF1Book6.RangeToPixelsEx(nRow1: Integer; nCol1: Integer; nRow2: Integer; nCol2: Integer): IF1Rect;
begin
  result:=DefaultInterface.RangeToPixelsEx(nRow1, nCol1, nRow2, nCol2);
end;

procedure TF1Book6.WriteEx(const PathName: WideString; FileType: F1FileTypeConstants);
begin
  DefaultInterface.WriteEx(PathName, FileType);
end;

procedure TF1Book6.WriteRangeEx(nSheet: Integer; nRow1: Integer; nCol1: Integer; nRow2: Integer; 
                                nCol2: Integer; const pPathName: WideString; 
                                FileType: F1FileTypeConstants);
begin
  DefaultInterface.WriteRangeEx(nSheet, nRow1, nCol1, nRow2, nCol2, pPathName, FileType);
end;

procedure TF1Book6.GetFontEx(out pName: WideString; out pCharSet: F1CharSetConstants; 
                             out pSize: Smallint; out pBold: WordBool; out pItalic: WordBool; 
                             out pUnderline: WordBool; out pStrikeout: WordBool; 
                             out pcrColor: Integer; out pOutline: WordBool; out pShadow: WordBool);
begin
  DefaultInterface.GetFontEx(pName, pCharSet, pSize, pBold, pItalic, pUnderline, pStrikeout, 
                             pcrColor, pOutline, pShadow);
end;

procedure TF1Book6.SetFontEx(const pName: WideString; CharSet: F1CharSetConstants; nSize: Smallint; 
                             bBold: WordBool; bItalic: WordBool; bUnderline: WordBool; 
                             bStrikeout: WordBool; crColor: OLE_COLOR; bOutline: WordBool; 
                             bShadow: WordBool);
begin
  DefaultInterface.SetFontEx(pName, CharSet, nSize, bBold, bItalic, bUnderline, bStrikeout, 
                             crColor, bOutline, bShadow);
end;

procedure TF1Book6.GetDefaultFontEx(out pBuf: WideString; out pCharSet: F1CharSetConstants; 
                                    out pSize: Smallint);
begin
  DefaultInterface.GetDefaultFontEx(pBuf, pCharSet, pSize);
end;

procedure TF1Book6.SetDefaultFontEx(const Name: WideString; CharSet: F1CharSetConstants; 
                                    nSize: Smallint);
begin
  DefaultInterface.SetDefaultFontEx(Name, CharSet, nSize);
end;

function  TF1Book6.CreateNewCellFormat: IF1CellFormat;
begin
  result:=DefaultInterface.CreateNewCellFormat;
end;

function  TF1Book6.GetCellFormat: IF1CellFormat;
begin
  result:=DefaultInterface.GetCellFormat;
end;

procedure TF1Book6.SetCellFormat(const CellFormat: IF1CellFormat);
begin
  DefaultInterface.SetCellFormat(CellFormat);
end;

function  TF1Book6.ErrorNumberToText(SSError: Integer): WideString;
begin
  result:=DefaultInterface.ErrorNumberToText(SSError);
end;

function  TF1Book6.DefineSearch(const FindWhat: WideString; nSheet: Integer; nRow1: Integer; 
                                nCol1: Integer; nRow2: Integer; nCol2: Integer; Flags: Smallint): IF1FindReplaceInfo;
begin
  result:=DefaultInterface.DefineSearch(FindWhat, nSheet, nRow1, nCol1, nRow2, nCol2, Flags);
end;

procedure TF1Book6.SetDevNames(const DriverName: WideString; const DeviceName: WideString; 
                               const Port: WideString);
begin
  DefaultInterface.SetDevNames(DriverName, DeviceName, Port);
end;

procedure TF1Book6.FilePageSetupDlgEx(Pages: Integer);
begin
  DefaultInterface.FilePageSetupDlgEx(Pages);
end;

function  TF1Book6.CreateNewPageSetup: IF1PageSetup;
begin
  result:=DefaultInterface.CreateNewPageSetup;
end;

function  TF1Book6.GetPageSetup: IF1PageSetup;
begin
  result:=DefaultInterface.GetPageSetup;
end;

procedure TF1Book6.SetPageSetup(const PageSetup: IF1PageSetup);
begin
  DefaultInterface.SetPageSetup(PageSetup);
end;

procedure TF1Book6.AddInDlg;
begin
  DefaultInterface.AddInDlg;
end;

function  TF1Book6.LoadAddIn(const Path: WideString; bEnabled: WordBool): Smallint;
begin
  result:=DefaultInterface.LoadAddIn(Path, bEnabled);
end;

class function CoF1BookView.Create: IF1BookView;
begin
  Result := CreateComObject(CLASS_F1BookView) as IF1BookView;
end;

class function CoF1BookView.CreateRemote(const MachineName: string): IF1BookView;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_F1BookView) as IF1BookView;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TF1Book6]);
end;

end.

