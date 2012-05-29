unit RM_Const1;

interface

uses
	Graphics;

const
  RMCurrentVersion = 66; // (2005.9.18日更新)
  RMCurrentVersionStr = 'Version 5.61 (Build 2006.9.7)';

  RMInchPerMM: Single = 0.03937;
  RMFormatNumCount = 4;
  RMFormatDateCount = 7;
  RMFormatTimeCount = 4;
  RMFormatBooleanCount = 4;

  RMSpecCount = 10;
  RMSpecFuncs: array[0..RMSpecCount - 1] of string =
  ('_RM_Page', '_RM_ApplicationPath', '_RM_Date', '_RM_Time', '_RM_DateTime',
  '_RM_Line', '_RM_LineThough', '_RM_Column', '_RM_Current', '_RM_TotalPages');
  RMColors: array[0..41] of TColor =
  (clWhite, clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal,
    clGray, clSilver, clRed, clLime, clYellow, clBlue, clFuchsia,
    clAqua, clNone,
    clScrollBar, clBackground, clActiveCaption, clInactiveCaption,
    clMenu, clWindow, clWindowFrame, clMenuText, clWindowText,
    clCaptionText, clActiveBorder, clInactiveBorder, clAppWorkSpace,
    clHighlight, clHighlightText, clBtnFace, clBtnShadow, clGrayText,
    clBtnText, clInactiveCaptionText, clBtnHighlight, cl3DDkShadow,
    cl3DLight, clInfoText, clInfoBk);
  RMColorNames: array[0..41] of string =
  ('clWhite', 'clBlack', 'clMaroon', 'clGreen', 'clOlive', 'clNavy',
    'clPurple', 'clTeal', 'clGray', 'clSilver', 'clRed', 'clLime',
    'clYellow', 'clBlue', 'clFuchsia', 'clAqua', 'clTransparent',
    'clScrollBar', 'clBackground', 'clActiveCaption', 'clInactiveCaption',
    'clMenu', 'clWindow', 'clWindowFrame', 'clMenuText', 'clWindowText',
    'clCaptionText', 'clActiveBorder', 'clInactiveBorder', 'clAppWorkSpace',
    'clHighlight', 'clHighlightText', 'clBtnFace', 'clBtnShadow', 'clGrayText',
    'clBtnText', 'clInactiveCaptionText', 'clBtnHighlight', 'cl3DDkShadow',
    'cl3DLight', 'clInfoText', 'clInfoBk');

  RMDefaultFontSizeStr: array[0..31] of string = (
    '初号', '小初', '一号', '小一', '二号', '小二', '三号', '小三', '四号', '小四', '五号',
    '小五', '六号', '5', '6', '7', '8', '9', '10', '11', '12', '14', '16', '18', '20',
    '22', '24', '26', '28', '36', '48', '72');
  RMDefaultFontSize: array[0..12] of Smallint = (-56, -48, -35, -32, -29, -24, -21, -20, -19, -16, -14, -12,
    -10);
//  RMDefaultFontSize: array[0..12] of byte = (42, 36, 26, 24, 22, 18, 16, 15, 14, 12, 11, 9,
//    8);

  RMBreakChars: set of Char = [' ', #13, '-'];

  RMVIRTUALPRINTER_NAME = 'Virtual Printer';
  RMDEFAULTPRINTER_NAME = 'Default Printer';
  RMTrialVersionStr = 'Unregistered evaluation copy of ReportMachine!' + #13#10 +
  	'http://www.reportmachine.net';

const
  rsToolBar = 'ToolBar\';
  rsForm = 'Form\';
  rsWidth = 'Width';
  rsHeight = 'Height';
  rsTop = 'Top';
  rsLeft = 'Left';
  rsVisible = 'isVisible';
  rsX = 'XPosition';
  rsY = 'YPosition';
  rsDockName = 'DockName';
  rsDocked = 'Docked';
  rsWindowState = 'WindowState';
  rsMaximized = 'Maximized';
  rsLocalPropNames = 'LocalPropNames';
  rsUseTableName = 'UseTableName';
  rsOpenFiles = 'Last Open Files';

var
	RMIsChineseGB: Boolean;

implementation

uses RM_Const, RM_Common, RM_Utils;

initialization
	RMIsChineseGB := RMLoadStr(SRMIsChineseGB) = '1';

end.
