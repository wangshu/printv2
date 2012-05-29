unit RM_wawConsts;

interface

const
  wawHTML_VERSION = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">';
  wawOPENTAGPREFIX = '<';
  wawCLOSETAGPREFIX = '</';
  wawTAGPOSTFIX = '>';
  wawTABLETAG = 'TABLE';
  wawROWTAG = 'TR';
  wawCELLTAG = 'TD';
  wawHEADTAG = 'HEAD';
  wawTITLETAG = 'TITLE';
  wawFORMTAG = 'FORM';
  wawHTMLTAG = 'HTML';
  wawBODYTAG = 'BODY';
  wawSTYLETAG = 'STYLE';
  wawANCHORTAG = 'A';
  wawPRETAG = 'PRE';
  wawCOLSPANATTRIBUTE = 'colspan';
  wawROWSPANATTRIBUTE = 'rowspan';
  wawWIDTHATTRIBUTE = 'width';
  wawHEIGHTATTRIBUTE = 'height';
  wawBLOCKSEPARATOR: AnsiString = #13#10;
  wawMAXOBJECTTYPENAME = $20;
  wawMAXLENGTH = $FF;
  wawMAXMARGINSTRING: array[$0..$1F] of Char = '                                ';

  wawMAXFSWD = $0200;
  wawFONT_BOLD = 'bold';
  wawFONT_NORMAL = 'normal';
  wawFONT_UNDERLINE = 'underline';
  wawFONT_STRIKE = 'line-through ';
  wawFONT_NONE = 'none';
  wawFONT_ITALIC = 'italic';
  wawTABLESTYLE = 'border-collapse:collapse';
  wawSTYLEFORMAT = 'c%d';
  wawVALIGN = 'vectical-align';
  wawTEXTTOP = 'text-top';
  wawMiddle = 'middle';
  wawTextBottom = 'text-bottom';
  wawTEXTALIGN = 'text-align';
  wawLEFT = 'left';
  wawRIGHT = 'right';
  wawCENTER = 'center';
  wawJustify = 'justify';
  wawBackgroundColor = 'background-color';
  wawHtml_quot = '&quot;';
  wawHtml_amp = '&amp;';
  wawHtml_lt = '&lt;';
  wawHtml_gt = '&gt;';
  wawHtml_space = '&nbsp;';
  wawHtml_crlf = '<BR>';
  wawDefFontFace = 'Arial';
  wawDefFontSize = 10;
  wawDefFontSymbol = 'x';
  wawSmRepInch = 2.54;
  wawPointPerInch72 = 72;
  wawPointPerInch96 = 96;
  wawPointPerInch14 = 1440;
  wawPointPerInch10 = 256;
  wawExcelHeightC  = 20;
  wawExcelWidthC1  = 416;//438; //waw
  wawExcelWidthC2  = (wawExcelWidthC1 - wawPointPerInch10); //waw

implementation

end.


