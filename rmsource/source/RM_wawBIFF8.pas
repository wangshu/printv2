unit RM_wawBIFF8;

interface

uses
  Windows;

const
  XLSMaxRowsInSheet = $00010000;
  XLSMaxRowsInBlock = $20;
  XLSMaxCellsInRow = $0100;
  XLSMaxBlocks = $0800;
  XLSMaxColorsInPalette = $38;

  b8_IMDATA = $7F;
  b8_OBJ = $5D;
  b8_EOF = $0A;
  b8_BOF = $0809;
  b8_COLINFO = $7D;
  b8_XF = $E0;
  b8_LABEL = $0204;
  b8_BLANK = $0201;
  b8_DIMENSIONS = $0200;
  b8_ROW = $0208;
  b8_INTERFACHDR = $E1;
  b8_INTERFACEND = $E2;
  b8_MMS = $C1;
  b8_CODEPAGE = $42;
  b8_TABID = $013D;
  b8_FNGROUPCOUNT = $9C;
  b8_WINDOWPROTECT = $19;
  b8_PROTECT = $12;
  b8_PASSWORD = $13;
  b8_WINDOW1 = $3D;
  b8_BACKUP = $40;
  b8_HIDEOBJ = $8D;
  b8_1904 = $22;
  b8_PRECISION = $0E;
  b8_BOOKBOOL = $DA;
  b8_FONT = $31;
  b8_FORMAT = $041E;
  b8_COUNTRY = $8C;
  b8_INDEX = $020B;
  b8_CALCMODE = $0D;
  b8_CALCCOUNT = $0C;
  b8_REFMODE = $0F;
  b8_ITERATION = $11;
  b8_SAVERECALC = $5F;
  b8_DELTA = $10;
  b8_PRINTHEADERS = $2A;
  b8_PRINTGRIDLINES = $2B;
  b8_GRIDSET = $82;
  b8_GUTS = $80;
  b8_DEFAULTROWHEIGHT = $0225;
  b8_WSBOOL = $81;
  b8_HEADER = $14;
  b8_FOOTER = $15;
  b8_HCENTER = $83;
  b8_VCENTER = $84;
  b8_DEFCOLWIDTH = $55;
  b8_WRITEACCESS = $5C;
  b8_DOUBLESTREAMFILE = $0161;
  b8_PROT4REV = $01AF;
  b8_PROT4REVPASS = $01BC;
  b8_REFRESHALL = $01B7;
  b8_USESELFS = $0160;
  b8_BOUNDSHEET = $85;
  b8_WINDOW2 = $023E;
  b8_SELECTION = $1D;
  b8_DBCELL = $D7;
  b8_MULBLANK = $BE;
  b8_FORMULA = $06;
  b8_MERGE = $E5;
  b8_PALETTE = $92;
  b8_CONTINUE = $3C;
  b8_SETUP = $A1;
  b8_SST = $FC;
  b8_EXTSST = $FF;
  b8_LABELSST = $FD;
  b8_NUMBER = $0203;
  b8_MSODRAWING = $EC;
  b8_MSODRAWINGGROUP = $EB;
  b8_SUPBOOK = $01AE;
  b8_EXTERNSHET = $17;
  b8_OBJ_OT_PictureObject = $08;
  b8_OBJ_grbit_fSel = $01;
  b8_OBJ_grbit_fAutoSize = $02;
  b8_OBJ_grbit_fMove = $04;
  b8_OBJ_grbit_reserved1 = $08;
  b8_OBJ_grbit_fLocked = $10;
  b8_OBJ_grbit_reserved2 = $20;
  b8_OBJ_grbit_reserved3 = $40;
  b8_OBJ_grbit_fGrouped = $80;
  b8_OBJ_grbit_fHidden = $0100;
  b8_OBJ_grbit_fVisible = $0200;
  b8_OBJ_grbit_fPrint = $0400;
  b8_OBJPICTURE_grbit_fAutoPict = $01;
  b8_OBJPICTURE_grbit_fDde = $02;
  b8_OBJPICTURE_grbit_fIcon = $04;
  b8_HORIZONTALPAGEBREAKS = $1B;
  b8_BOF_vers = $0600;
  b8_BOF_dt_WorkbookGlobals = $05;
  b8_BOF_dt_VisualBasicModule = $06;
  b8_BOF_dt_Worksheet = $10;
  b8_BOF_dt_Chart = $20;
  b8_BOF_dt_MacroSheet = $40;
  b8_BOF_dt_WorkspaceFile = $0100;
  b8_BOF_rupBuild_Excel97 = $0DBB;
  b8_BOF_rupYear_Excel07 = $7CD; //$7CC;
  b8_XF_Opt1_fLocked = $01;
  b8_XF_Opt1_fHidden = $02;
  b8_XF_Opt1_fStyleXF = $04;
  b8_XF_Opt1_f123Prefix = $08;
  b8_XF_Opt1_ixfParent = $FFF0;
  b8_XF_Opt2_alcGeneral = $00;
  b8_XF_Opt2_alcLeft = $01;
  b8_XF_Opt2_alcCenter = $02;
  b8_XF_Opt2_alcRight = $03;
  b8_XF_Opt2_alcFill = $04;
  b8_XF_Opt2_alcJustify = $05;
  b8_XF_Opt2_alcCenterAcrossSelection = $06;
  b8_XF_Opt2_fWrap = $08;
  b8_XF_Opt2_alcVTop = $00;
  b8_XF_Opt2_alcVCenter = $10;
  b8_XF_Opt2_alcVBottom = $20;
  b8_XF_Opt2_alcVJustify = $30;
  b8_XF_Opt3_fMergeCell = $20;
  b8_XF_Opt3_fAtrNum = $0400;
  b8_XF_Opt3_fAtrFnt = $0800;
  b8_XF_Opt3_fAtrAlc = $1000;
  b8_XF_Opt3_fAtrBdr = $2000;
  b8_XF_Opt3_fAtrPat = $4000;
  b8_XF_Opt3_fAtrProt = $8000;
  b8_XF_Border_None = $00;
  b8_XF_Border_Thin = $01;
  b8_XF_Border_Medium = $02;
  b8_XF_Border_Dashed = $03;
  b8_XF_Border_Dotted = $04;
  b8_XF_Border_Thick = $05;
  b8_XF_Border_Double = $06;
  b8_XF_Border_Hair = $07;
  b8_XF_Border_MediumDashed = $08;
  b8_XF_Border_DashDot = $09;
  b8_XF_Border_MediumDashDot = $0A;
  b8_XF_Border_DashDotDot = $0B;
  b8_XF_Border_MediumDashDotDot = $0C;
  b8_XF_Border_SlantedDashDot = $0D;
  b8_INTERFACHDR_cv_IBMPC = $01B5;
  b8_INTERFACHDR_cv_Macintosh = $8000;
  b8_INTERFACHDR_cv_ANSI = $4B0;//$04E4;
  b8_CODEPAGE_cv_IBMPC = $01B5;
  b8_CODEPAGE_cv_Macintosh = $8000;
  b8_CODEPAGE_cv_ANSI = $4B0;//$04E4;
  b8_WINDOW1_grbit_fHidden = $01;
  b8_WINDOW1_grbit_fIconic = $02;
  b8_WINDOW1_grbit_fDspHScroll = $08;
  b8_WINDOW1_grbit_fDspVScroll = $10;
  b8_WINDOW1_grbit_fBotAdornment = $20;
  b8_FONT_grbit_fItalic = $02;
  b8_FONT_grbit_fStrikeout = $08;
  b8_FONT_grbit_fOutline = $10;
  b8_FONT_grbit_fShadow = $20;
  b8_DEFAULTROWHEIGHT_fUnsynced = $01;
  b8_DEFAULTROWHEIGHT_fDyZero = $02;
  b8_DEFAULTROWHEIGHT_fExAsc = $04;
  b8_DEFAULTROWHEIGHT_fExDsc = $08;
  b8_WSBOOL_fShowAutoBreaks = $01;
  b8_WSBOOL_fDialog = $10;
  b8_WSBOOL_fApplyStyles = $20;
  b8_WSBOOL_fRwSumsBelow = $40;
  b8_WSBOOL_fColSumsRight = $80;
  b8_WSBOOL_fFitToPage = $0100;
  b8_WSBOOL_fDspGuts = $0200;
  b8_WSBOOL_fAee = $0400;
  b8_WSBOOL_fAfe = $8000;
  b8_WINDOW1_fHidden = $01;
  b8_WINDOW1_fIconic = $02;
  b8_WINDOW1_fDspHScroll = $08;
  b8_WINDOW1_fDspVScroll = $10;
  b8_WINDOW1_fBotAdornment = $20;
  b8_WINDOW2_grbit_fDspFmla = $01;
  b8_WINDOW2_grbit_fDspGrid = $02;
  b8_WINDOW2_grbit_fDspRwCol = $04;
  b8_WINDOW2_grbit_fFrozen = $08;
  b8_WINDOW2_grbit_fDspZeros = $10;
  b8_WINDOW2_grbit_fDefaultHdr = $20;
  b8_WINDOW2_grbit_fArabic = $40;
  b8_WINDOW2_grbit_fDspGuts = $80;
  b8_WINDOW2_grbit_fFrozenNoSplit = $0100;
  b8_WINDOW2_grbit_fSelected = $0200;
  b8_WINDOW2_grbit_fPaged = $0400;
  b8_WINDOW2_grbit_fSLV = $0800;
  b8_ROW_grbit_fCollapsed = $10;
  b8_ROW_grbit_fDefault = $100; //waw
  b8_ROW_grbit_fDyZero = $20;
  b8_ROW_grbit_fUnsynced = $40;
  b8_ROW_grbit_fGhostDirty = $80;
  b8_ROW_grbit_mask_iOutLevel = $07;
  b8_COLINFO_fHidden = $01;
  b8_COLINFO_fCollapsed = $1000;
  b8_SETUP_fLeftToRight = $01;
  b8_SETUP_fLandscape = $02;
  b8_SETUP_fNoPls = $04;
  b8_SETUP_fNoColor = $08;
  b8_SETUP_fDraft = $10;
  b8_SETUP_fNotes = $20;
  b8_SETUP_fNoOrient = $40;
  b8_SETUP_fUsePage = $80;
  b8_LEFTMARGIN = $26;
  b8_RIGHTMARGIN = $27;
  b8_TOPMARGIN = $28;
  b8_BOTTOMMARGIN = $29;
  b8_MSOFBH_inst_mask = $FFF0;
  b8_MSOFBH_ver_mask = $0F;
  b8_msoContainerVer = $0F;
  b8_msofbtBSEVer = $02;
  b8_msofbtDggContainer = $F000;
  b8_msofbtDgg = $F006;
  b8_msofbtCLSID = $F016;
  b8_msofbtOPT = $F00B;
  b8_msofbtColorMRU = $F11A;
  b8_msofbtSplitMenuColors = $F11E;
  b8_msofbtBstoreContainer = $F001;
  b8_msofbtBSE = $F007;
  b8_msofbtBlip = $F018;
  b8_msofbtDgContainer = $F002;
  b8_msofbtDg = $F008;
  b8_msofbtRegroupItems = $F118;
  b8_msofbtColorScheme = $F120;
  b8_msofbtSpgrContainer = $F003;
  b8_msofbtSpContainer = $F004;
  b8_msofbtSpgr = $F009;
  b8_msofbtSp = $F00A;
  b8_msofbtTextbox = $F00C;
  b8_msofbtClientTextbox = $F00D;
  b8_msofbtAnchor = $F00E;
  b8_msofbtChildAnchor = $F00F;
  b8_msofbtClientAnchor = $F010;
  b8_msofbtClientData = $F011;
  b8_msofbtOleObject = $F11F;
  b8_msofbtDeletedPspl = $F11D;
  b8_msofbtSolverContainer = $F005;
  b8_msofbtConnectorRule = $F012;
  b8_msomsofbtAlignRule = $F013;
  b8_msofbtArcRule = $F014;
  b8_msofbtClientRule = $F015;
  b8_msofbtCalloutRule = $F017;
  b8_msofbtSelection = $F119;
  b8_msoblipERROR = $00;
  b8_msoblipUNKNOWN = $01;
  b8_msoblipEMF = $02;
  b8_msoblipWMF = $03;
  b8_msoblipPICT = $04;
  b8_msoblipJPEG = $05;
  b8_msoblipPNG = $06;
  b8_msoblipDIB = $07;
  b8_msoblipFirstClient = $20;
  b8_msoblipLastClient = $21;
  b8_fsp_fGroup = $01;
  b8_fsp_fChild = $02;
  b8_fsp_fPatriarch = $04;
  b8_fsp_fDeleted = $08;
  b8_fsp_fOleShape = $10;
  b8_fsp_fHaveMaster = $20;
  b8_fsp_fFlipH = $40;
  b8_fsp_fFlipV = $80;
  b8_fsp_fConnector = $0100;
  b8_fsp_fHaveAnchor = $0200;
  b8_fsp_fBackground = $0400;
  b8_fsp_fHaveSpt = $0800;
  b8_fsp_reserved = $FFFFF001;
  b8_FORMULA_fAlwaysCalc = $01;
  b8_FORMULA_fCalcOnLoad = $02;
  b8_FORMULA_fShrFmla = $08;

type
  rb8BOF = packed record
    vers: Word;
    dt: Word;
    rupBuild: Word;
    rupYear: Word;
    bfh: Cardinal;
    sfo: Cardinal;
  end;

  rb8COLINFO = packed record
    colFirst: Word;
    colLast: Word;
    coldx: Word;    //ÏñËØ x 32  //waw
    ixfe: Word;
    grbit: Word;
//    res1: Byte;   //waw
    res1: Word;     //waw see from *.xls
  end;

  rb8XF = packed record
    ifnt: Word;
    ifmt: Word;
    Opt1: Word;
    Opt2: Byte;
    trot: Byte;
    Opt3: Word;
    Borders1: Word;
    Borders2: Word;
    Borders3: Cardinal;
    Colors: Word;
  end;

  pb8XF = ^rb8XF;

  rb8DIMENSIONS = packed record
    rwMic: Cardinal;
    rwMac: Cardinal;
    colMic: Word;
    colMac: Word;
    Res1: Word;
  end;

  rb8ROW = packed record
    rw: Word;
    colMic: Word;
    colMac: Word;
    miyRw: Word;      //ÏñËØ x 15  //waw
    irwMac: Word;
    Res1: Word;
    grbit: Word;
    ixfe: Word;
  end;

  rb8INTERFACHDR = packed record
    cv: Word;
  end;

  rb8MMS = packed record
    caitm: Byte;
    cditm: Byte;
  end;

  rb8CODEPAGE = packed record
    cv: Word;
  end;

  rb8FNGROUPCOUNT = packed record
    cFnGroup: Word;
  end;

  rb8WINDOWPROTECT = packed record
    fLockWn: Word;
  end;

  rb8PROTECT = packed record
    fLock: Word;
  end;

  rb8PASSWORD = packed record
    wPassword: Word;
  end;

  rb8BACKUP = packed record
    fBackupFile: Word;
  end;

  rb8HIDEOBJ = packed record
    fHideObj: Word;
  end;

  rb81904 = packed record
    f1904: Word;
  end;

  rb8PRECISION = packed record
    fFullPrec: Word;
  end;

  rb8BOOKBOOL = packed record
    fNoSaveSupp: Word;
  end;

  rb8FONT = packed record
    dyHeight: Word;
    grbit: Word;
    icv: Word;
    bls: Word;
    sss: Word;
    uls: Byte;
    bFamily: Byte;
    bCharSet: Byte;
    Res1: Byte;
    cch: Byte;
    cchgrbit: Byte;
  end;

  pb8FONT = ^rb8FONT;

  rb8FORMAT = packed record
    ifmt: Word;
    cch: Word;
    cchgrbit: Byte;
  end;

  pb8FORMAT = ^rb8FORMAT;

  rb8COUNTRY = packed record
    iCountryDef: Word;
    iCountryWinIni: Word;
  end;

  rb8INDEX = packed record
    Res1: Cardinal;
    rwMic: Cardinal;
    rwMac: Cardinal;
    Res2: Cardinal;
  end;

  pb8INDEX = ^rb8INDEX;

  rb8CALCMODE = packed record
    fAutoRecalc: Word;
  end;

  rb8CALCCOUNT = packed record
    cIter: Word;
  end;

  rb8REFMODE = packed record
    fRefA1: Word;
  end;

  rb8ITERATION = packed record
    fIter: Word;
  end;

  rb8DELTA = packed record
    numDelta: Int64;
  end;

  rb8SAVERECALC = packed record
    fSaveRecalc: Word;
  end;

  rb8PRINTHEADERS = packed record
    fPrintRwCol: Word;
  end;

  rb8PRINTGRIDLINES = packed record
    fPrintGrid: Word;
  end;

  rb8GRIDSET = packed record
    fGridSet: Word;
  end;

  rb8GUTS = packed record
    dxRwGut: Word;
    dyColGut: Word;
    iLevelRwMac: Word;
    iLevelColMac: Word;
  end;

  rb8DEFAULTROWHEIGHT = packed record
    grbit: Word;
    miyRw: Word;
  end;

  rb8WSBOOL = packed record
    grbit: Word;
  end;

  rb8HEADER = packed record
    cch: Word;
    cchgrbit: Byte;
  end;

  pb8HEADER = ^rb8HEADER;

  rb8FOOTER = packed record
    cch: Word;
    cchgrbit: Byte;
  end;

  pb8FOOTER = ^rb8FOOTER;

  rb8HCENTER = packed record
    fHCenter: Word;
  end;

  rb8VCENTER = packed record
    fVCenter: Word;
  end;

  rb8DEFCOLWIDTH = packed record
    cchdefColWidth: Word;
  end;

  rb8WRITEACCESS = packed record
    stName: array[$0..$6F] of Byte;
  end;

  rb8DOUBLESTREAMFILE = packed record
    fDSF: Word;
  end;

  rb8PROT4REV = packed record
    fRevLock: Word;
  end;

  rb8PROT4REVPASS = packed record
    wRevPass: Word;
  end;

  rb8WINDOW1 = packed record
    xWn: Word;
    yWn: Word;
    dxWn: Word;
    dyWn: Word;
    grbit: Word;
    itabCur: Word;
    itabFirst: Word;
    ctabSel: Word;
    wTabRatio: Word;
  end;

  rb8REFRESHALL = packed record
    fRefreshAll: Word;
  end;

  rb8USESELFS = packed record
    fUsesElfs: Word;
  end;

  rb8PALETTE = packed record
    ccv: Word;
    colors: array[$0..$37] of Cardinal;
  end;

  pb8PALETTE = ^rb8PALETTE;

  rb8BOUNDSHEET = packed record
    lbPlyPos: Cardinal;
    grbit: Word;
    cch: Byte;
    cchgrbit: Byte;
  end;

  pb8BOUNDSHEET = ^rb8BOUNDSHEET;

  rb8WINDOW2 = packed record
    grbit: Word;
    rwTop: Word;
    colLeft: Word;
    icvHdr: Cardinal;
    wScaleSLV: Word;
    wScaleNormal: Word;
    Res1: Cardinal;
  end;

  rb8SELECTION = packed record
    pnn: Byte;
    rwAct: Word;
    colAct: Word;
    irefAct: Word;
    cref: Word;
  end;

  pb8SELECTION = ^rb8SELECTION;

  rb8DBCELL = packed record
    dbRtrw: Cardinal;
  end;

  Tb8DBCELLCellsOffsArray = array[$0..$FF] of Word;

  rb8DBCELLfull = packed record
    dbRtrw: Cardinal;
    cellsOffs: Tb8DBCELLCellsOffsArray;
  end;

  rb8MERGErec = packed record
    top: Word;
    bottom: Word;
    left: Word;
    right: Word;
  end;

  pb8MERGErec = ^rb8MERGErec;

  rb8MERGE = packed record
    cnt: Word;
  end;

  pb8MERGE = ^rb8MERGE;

  rb8LABEL = packed record
    rw: Word;
    col: Word;
    ixfe: Word;
    cch: Word;
    cchgrbit: Byte;
  end;

  pb8LABEL = ^rb8LABEL;

  rb8BLANK = packed record
    rw: Word;
    col: Word;
    ixfe: Word;
  end;

  rb8MULBLANK = packed record
    rw: Word;
    colFirst: Word;
  end;

  pb8MULBLANK = ^rb8MULBLANK;

  rb8SETUP = packed record
    iPaperSize: Word;
    iScale: Word;     //page zoom value, unit: %
    iPageStart: Word;
    iFitWidth: Word;
    iFitHeight: Word;
    grbit: Word;
    iRes: Word;
    iVRes: Word;
    numHdr: Double;    //page headr height, unit: Inch
    numFtr: Double;    //page footer height, unit: Inch
    iCopies: Word;
  end;

  rb8SST = packed record
    cstTotal: Cardinal;
    cstUnique: Cardinal;
  end;

  pb8SST = ^rb8SST;

  rb8EXTSST = packed record
    Dsst: Word;
  end;

  pb8EXTSST = ^rb8EXTSST;

  rb8ISSTINF = packed record
    ib: Cardinal;
    cb: Word;
    res1: Word;
  end;

  pb8ISSTINF = ^rb8ISSTINF;

  rb8LABELSST = packed record
    rw: Word;
    col: Word;
    ixfe: Word;
    isst: Cardinal;
  end;

  rb8FORMULA = packed record
    rw: Word;
    col: Word;
    ixfe: Word;
    value: Double;
    grbit: Word;
    chn: Cardinal;
    cce: Word;
  end;

  pb8FORMULA = ^rb8FORMULA;

  rb8LEFTMARGIN = packed record
    num: Double;    //unit: Inch
  end;

  rb8RIGHTMARGIN = packed record
    num: Double;    //unit: Inch
  end;

  rb8TOPMARGIN = packed record
    num: Double;    //unit: Inch
  end;

  rb8BOTTOMMARGIN = packed record
    num: Double;    //unit: Inch
  end;

  rb8NUMBER = packed record
    rw: Word;
    col: Word;
    ixfe: Word;
    num: Double;
  end;

  pb8NUMBER = ^rb8NUMBER;

  rb8IMDATA = packed record
    cf: Word;
    env: Word;
    lcb: Cardinal;
  end;

  pb8IMDATA = ^rb8IMDATA;

  rb8OBJ = packed record
    cObj: Cardinal;
    OT: Word;
    id: Word;
    grbit: Word;
    colL: Word;
    dxL: Word;
    rwT: Word;
    dyT: Word;
    colR: Word;
    dxR: Word;
    rwB: Word;
    dyB: Word;
    cbMacro: Word;
    Reserved: array[$0..$5] of Byte;
  end;

  pb8OBJ = ^rb8OBJ;

  rb8OBJPICTURE = packed record
    icvBack: Byte;
    icvFore: Byte;
    fls: Byte;
    fAutoFill: Byte;
    icv: Byte;
    lns: Byte;
    lnw: Byte;
    fAutoBorder: Byte;
    frs: Word;
    cf: Word;
    Reserved1: Cardinal;
    cbPictFmla: Word;
    Reserved2: Word;
    grbit: Word;
    Reserved3: Cardinal;
  end;

  pb8OBJPICTURE = ^rb8OBJPICTURE;

  rb8HORIZONTALPAGEBREAKS = packed record
    cbrk: Word;
  end;

  pb8HORIZONTALPAGEBREAKS = ^rb8HORIZONTALPAGEBREAKS;

  rb8HORIZONTALPAGEBREAK = packed record
    row: Word;
    startcol: Word;
    endcol: Word;
  end;

  pb8HORIZONTALPAGEBREAK = ^rb8HORIZONTALPAGEBREAK;

  rb8SUPBOOK = packed record
    Ctab: Word;
    cch: Word;
    grbit: Byte;
    code: Word;
  end;

  pb8SUPBOOK = ^rb8SUPBOOK;

  rb8EXTERNSHEET = packed record
    cXTI: Word;
  end;

  pb8EXTERNSHEET = ^rb8EXTERNSHEET;

  rb8XTI = packed record
    iSUPBOOK: Word;
    itabFirst: Word;
    itabLast: Word;
  end;

  pb8XTI = ^rb8XTI;

  MSODGID = Cardinal;

  MSOSPID = Cardinal;

  rb8FSP = packed record
    spid: Cardinal;
    grfPersistent: Cardinal;
  end;

  pb8FSP = ^rb8FSP;

  rb8FOPTE = packed record
    pid_fBid_fComplex: Word;
    op: Cardinal;
  end;

  pb8FOPTE = ^rb8FOPTE;

  rb8MSOFBH = packed record
    inst_ver: Word;
    fbt: Word;
    cbLength: Cardinal;
  end;

  pb8MSOFBH = ^rb8MSOFBH;

  rb8FBSE = packed record
    btWin32: Byte;
    btMacOs: Byte;
    rgbUid: array[$0..$F] of Byte;
    tag: Word;
    size: Cardinal;
    cRef: Cardinal;
    foDelay: Cardinal;
    usage: Byte;
    cbName: Byte;
    unused2: Byte;
    unused3: Byte;
  end;

  pb8FBSE = ^rb8FBSE;

  rb8FBSEDIB = packed record
    Unknown: array[$0..$7] of Byte;
    rgbUid: array[$0..$F] of Byte;
    Tag: Byte;
  end;

  pb8FBSEDIB = ^rb8FBSEDIB;

  rb8FDGG = packed record
    spidMax: Cardinal;
    cidcl: Cardinal;
    cspSaved: Cardinal;
    cdgSaved: Cardinal;
  end;

  pb8FDGG = ^rb8FDGG;

  rb8FIDCL = packed record
    dgid: Cardinal;
    cspidCur: Cardinal;
  end;

  pb8FIDCL = ^rb8FIDCL;

  rb8FDG = packed record
    csp: Cardinal;
    spidCur: Cardinal;
  end;

  pb8FDG = ^rb8FDG;

  rb8FSPGR = packed record
    rcgBounds: TRect;
  end;

  pb8FSPGR = ^rb8FSPGR;

  rb8FDGGFull = packed record
    Header: rb8MSOFBH;
    FDGG: rb8FDGG;
  end;

  rb8FDGFull = packed record
    Header: rb8MSOFBH;
    FDG: rb8FDG;
  end;

  pb8FDGFull = ^rb8FDGFull;

  rb8FBSEFull = packed record
    Header: rb8MSOFBH;
    FBSE: rb8FBSE;
    FBSEDIB: rb8FBSEDIB;
  end;

  rb8FSPFull = packed record
    Header: rb8MSOFBH;
    FSP: rb8FSP;
  end;

  pb8FSPFull = ^rb8FSPFull;

  rb8FSPGRFull = packed record
    Header: rb8MSOFBH;
    FSPGR: rb8FSPGR;
  end;

  pb8FSPGRFull = ^rb8FSPGRFull;

const
  ptgInt = $1E;
  ptgNum = $1F;
  ptgStr = $17;
  ptgGT = $0D;
  ptgGE = $0C;
  ptgEQ = $0B;
  ptgNE = $0E;
  ptgLE = $0A;
  ptgLT = $09;
  ptgAdd = $03;
  ptgSub = $04;
  ptgMul = $05;
  ptgDiv = $06;
  ptgPower = $07;
  ptgPercent = $14;
  ptgConcat = $08;
  ptgUplus = $12;
  ptgUminus = $13;
  ptgParen = $15;
  ptgMissArg = $16;
  ptgRef = $44;
  ptgArea = $25;
  ptgFuncVar = $42;
  ptgRef3D = $5A;
  ptgArea3D = $3B;

type
  rptgInt = packed record
    w: Word;
  end;

  rptgNum = packed record
    num: Double;
  end;

  rptgStr = packed record
    cch: Byte;
    grbit: Byte;
  end;

  pptgStr = ^rptgStr;

  rptgRef = packed record
    rw: Word;
    grbitCol: Word;
  end;

  pptgRef = ^rptgRef;

  rptgArea = packed record
    rwFirst: Word;
    rwLast: Word;
    grbitColFirst: Word;
    grbitColLast: Word;
  end;

  pptgArea = ^rptgArea;

  rptgFuncVar = packed record
    cargs: Byte;
    iftab: Word;
  end;

  rptgRef3D = packed record
    ixti: Word;
    rw: Word;
    grbitCol: Word;
  end;

  pptgRef3D = ^rptgRef3D;

  rptgArea3D = packed record
    ixti: Word;
    rwFirst: Word;
    rwLast: Word;
    grbitColFirst: Word;
    grbitColLast: Word;
  end;

  pptgArea3D = ^rptgArea3D;

function FormatStrToWideChar(Source: string; Dest: PWideChar): Integer;
function FormatStrToWideChar1(Source: WideString; Dest: PWideChar): Integer;

implementation

function FormatStrToWideChar(Source: string; Dest: PWideChar): Integer;
var
  s2: WideString;
begin
  s2 := Source;
  CopyMemory(Dest, @s2[1], Length(s2) * Sizeof(WideChar));
  Result := Length(s2);
end;

function FormatStrToWideChar1(Source: WideString; Dest: PWideChar): Integer;
var
  s2: WideString;
begin
  s2 := Source;
  CopyMemory(Dest, @s2[1], Length(s2) * Sizeof(WideChar));
  Result := Length(s2);
end;

end.

