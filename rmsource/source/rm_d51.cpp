//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("rm_d51.res");
USEPACKAGE("dsnide50.bpi");
USEPACKAGE("teeui50.bpi");
USEUNIT("RM_ChartUI.pas");
USEUNIT("RM_reg.pas");
USERES("RM_reg.dcr");
USEPACKAGE("rm_r51.bpi");
USEPACKAGE("Vcl50.bpi");
USEPACKAGE("Vclx50.bpi");
USEPACKAGE("vcljpg50.bpi");
USEPACKAGE("Vcldb50.bpi");
USEPACKAGE("vclado50.bpi");
USEPACKAGE("Vclbde50.bpi");
USEPACKAGE("Tee50.bpi");
USEUNIT("RM_DBChartUI.pas");
USEPACKAGE("teedb50.bpi");
USEPACKAGE("VCLMID50.bpi");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
	return 1;
}
//---------------------------------------------------------------------------
