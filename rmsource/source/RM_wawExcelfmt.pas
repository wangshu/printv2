unit RM_wawExcelFmt;

interface

type
  TwawCellDataType= (wawcdtNumber, wawcdtString, wawcdtFormula);

  TwawXLSLineStyleType=
   (wawlsNone, wawlsThin, wawlsMedium, wawlsDashed, wawlsDotted, wawlsThick,
    wawlsDouble, wawlsHair, wawlsMediumDashed, wawlsDashDot,
    wawlsMediumDashDot, wawlsDashDotDot, wawlsMediumDashDotDot,
    wawlsSlantedDashDot);

  TwawXLSWeightType= (wawxlHairline, wawxlThin, wawxlMedium, wawxlThick);

  TwawXLSBorderType=
   (wawxlDiagonalDown, wawxlDiagonalUp, wawxlEdgeBottom, wawxlEdgeLeft,
    wawxlEdgeRight, wawxlEdgeTop);

  TwawXLSBorderTypes=set of TwawXLSBorderType;

  TwawXLSHorizontalAlignmentType=
   (wawxlHAlignGeneral, wawxlHAlignLeft, wawxlHAlignCenter,
    wawxlHAlignRight, wawxlHAlignFill, wawxlHAlignJustify,
    wawxlHAlignCenterAcrossSelection);

  TwawXLSVerticalAlignmentType=
   (wawxlVAlignTop, wawxlVAlignCenter, wawxlVAlignBottom,
    wawxlVAlignJustify);

  TwawXLSOrderType= (wawxlDownThenOver, wawxlOverThenDown);

  TwawXLSOrientationType= (wawxlPortrait, wawxlLandscape);

  TwawXLSPaperSizeType=
   (wawxlPaperOther, wawxlPaperLetter, wawxlPaperLetterSmall,
    wawxlPaperTabloid, wawxlPaperLedger, wawxlPaperLegal,
    wawxlPaperStatement, wawxlPaperExecutive, wawxlPaperA3, wawxlPaperA4,
    wawxlPaperA4SmallSheet, wawxlPaperA5, wawxlPaperB4, wawxlPaperB5,
    wawxlPaperFolio, wawxlPaperQuartoSheet, wawxlPaper10x14,
    wawxlPaper11x17, wawxlPaperNote, wawxlPaper9Envelope,
    wawxlPaper10Envelope, wawxlPaper11Envelope, wawxlPaper12Envelope,
    wawxlPaper14Envelope, wawxlPaperCSheet, wawxlPaperDSheet,
    wawxlPaperESheet, wawxlPaperDLEnvelope, wawxlPaperC5Envelope,
    wawxlPaperC3Envelope, wawxlPaperC4Envelope, wawxlPaperC6Envelope,
    wawxlPaperC65Envelope, wawxlPaperB4Envelope, wawxlPaperB5Envelope,
    wawxlPaperB6Envelope, wawxlPaperItalyEnvelope,
    wawxlPaperMonarchEnvelope, wawxlPaper63_4Envelope,
    wawxlPaperUSStdFanfold, wawxlPaperGermanStdFanfold,
    wawxlPaperGermanLegalFanfold, wawxlPaperB4_ISO,
    wawxlPaperJapanesePostcard, wawxlPaper9x11, wawxlPaper10x11,
    wawxlPaper15x11, wawxlPaperEnvelopeInvite, wawxlPaperLetterExtra,
    wawxlPaperLegalExtra, wawxlPaperTabloidExtra, wawxlPaperA4Extra,
    wawxlPaperLetterTransverse, wawxlPaperA4Transverse,
    wawxlPaperLetterExtraTransverse, wawxlPaperSuperASuperAA4,
    wawxlPaperSuperBSuperBA3, wawxlPaperLetterPlus, wawxlPaperA4Plus,
    wawxlPaperA5Transverse, wawxlPaperB5_JIS_Transverse, wawxlPaperA3Extra,
    wawxlPaperA5Extra, wawxlPaperB5_ISO_Extra, wawxlPaperA2,
    wawxlPaperA3Transverse, wawxlPaperA3ExtraTransverse);

  TwawXLSPrintErrorsType=
   (wawxlPrintErrorsBlank, wawxlPrintErrorsDash, wawxlPrintErrorsDisplayed,
    wawxlPrintErrorsNA);

  TwawXLSFillPattern=
   (wawfpNone, wawfpAutomatic, wawfpChecker, wawfpCrissCross, wawfpDown,
    wawfpGray8, wawfpGray16, wawfpGray25, wawfpGray50, wawfpGray75,
    wawfpGrid, wawfpHorizontal, wawfpLightDown, wawfpLightHorizontal,
    wawfpLightUp, wawfpLightVertical, wawfpSemiGray75, wawfpSolid, wawfpUp,
    wawfpVertical);

  TwawXLSImageBorderLineStyle=
   (wawblsSolid, wawblsDash, wawblsDot, wawblsDashDot, wawblsDashDotDot,
    wawblsNull, wawblsDarkGray, wawblsMediumGray, wawblsLightGray);

  TwawXLSImageBorderLineWeight=
   (wawblwHairline, wawblwSingle, wawblwDouble, wawblwThick);

implementation

end.


