
{*****************************************}
{                                         }
{          Report Machine v3.0            }
{              Include file               }
{                                         }
{*****************************************}

//{$DEFINE JVCLCTLS}
{$DEFINE USE_INTERNAL_JVCL}
{$IFDEF JVCLCTLS}
{$UNDEF USE_INTERNAL_JVCL}
{$ENDIF}

{$IFDEF USE_INTERNAL_JVCL}
{$I rm_jvcl.inc}
{$ELSE}
{$I jvcl.inc}
{$ENDIF}

//{$DEFINE TrialVersion}
{$DEFINE RM_ENTVersion}

{$DEFINE USE_INTERNALTB97} // Use Toolbutton 97 使用rm集成的tb97,如果已安装tb97,注释掉此行
//{$DEFINE USE_TB2K}  // Use Toolbutton 2K 使用tb2K,取消此行的注释
//{$DEFINE USE_TB2K_TBX}  // Use Toolbutton 2K 使用tb2K,取消此行的注释

//{$DEFINE llPDFLib} // Use llPDFLib to Export PDF File
//{$DEFINE USE_IMAGEEN}  // Use ImageEn to Export multi page Tiff File
//{$DEFINE TntUnicode} // Use TntUnicode, Support Unicode

//-------------------- Use SynEdit -------------------------------------
//{$DEFINE USE_SYNEDIT}

//-------------------- Raize ---------------------------------------------------
//{$DEFINE Raize}

//-------------------- FlatStyle -----------------------------------------------
//如果使用FlatStyle
//{$DEFINE FlatStyle}

{$B-} {- Complete Boolean Evaluation }
{$R-} {- Range-Checking }
{$V-} {- Var-String Checking }
{$T-} {- Typed @ operator }
{$X+} {- Extended syntax }
{$P+} {- Open string params }
{$J+} {- Writeable structured consts }
{$H+} {- Use long strings by default }

{$IFDEF BCB}
{$OBJEXPORTALL on}
{$ENDIF}

//------------------- GIF images -----------------------------------
// GIF images - need RXLib. Adds approximately
// If you want to show GIF images in "Picture" object, uncomment
// the following line:
{$DEFINE RXGIF}

//------------------- InfoPower -----------------------------------
// If you want to TwwDBRichEdit, Print TwwDBGrid Use TRMFormReport, uncomment
// the following line:
//{$DEFINE InfoPower}

//-------------------- Use RichEdit 2.0 ---------------------------------
{$DEFINE USE_RICHEDIT_VER_20}

//------------------- TeeChart component ----------------------------
{$DEFINE TeeChart}
//{$DEFINE TeeChart40}

//--------------------Decision Grid----------------------------------
//{$DEFINE DecisionGrid}

//------------------- JPEG images -----------------------------------
// JPEG images - only available in Delphi 3 and above. Adds approximately
// 100Kb to your EXE.
// If you want to show jpeg images in "Picture" object, uncomment
// the following line:
{$DEFINE JPEG}

//------------------- "Open Picture" dialog -------------------------
// Only available in Delphi 3 and above. Adds approximately 60Kb to your EXE.
// If you want to use standard "Open picture" dialog in picture editor,
// uncomment the following line:
{$DEFINE OPENPICTUREDLG}

//------------------- EHLib 1.54 or Above -----------------------------------
// If you want to Print TDBGridEh Use TRMFormReport, uncomment
// the following line:
//{$DEFINE EHLib}
//{$DEFINE EHLib20}

//------------------ Use TurboPower --------------------------------
{$DEFINE TurboPower}

//-------------------- Zlib ---------------------------------------
{$DEFINE Zlib}

//-----------------Data Manager -----------------------------
{$DEFINE DM_ADO} //Support ADO
{$DEFINE DM_BDE} //Support BDE
{$DEFINE DM_IBX} //Support InterBase Express
{$DEFINE DM_DBX}
{$DEFINE DM_MIDAS}

//-------------------------------------------------------------------
{$IFNDEF COMPILER5_UP}
{$UNDEF DM_ADO}
{$UNDEF DM_IBX}
{$ENDIF}

{$IFNDEF COMPILER6_UP}
{$UNDEF DM_DBX}
{$ENDIF}

{$IFNDEF COMPILER4_UP}
{$UNDEF USE_TB2K}
{$ENDIF}

{$IFDEF Raize }
{$UNDEF FlatStyle}
{$UNDEF JVCLCTLS}
{$ENDIF}

{$IFDEF TrialVersion}
{$UNDEF DM_IBX}
{$UNDEF DM_DBX}
{$UNDEF DM_MIDAS}
{$ENDIF}

{$IFNDEF JVCLCTLS}
{$UNDEF RXGIF}
{$ENDIF}

{$IFNDEF USE_TB2K}
{$UNDEF USE_TB2K_TBX}
{$ENDIF}

