program print_v2;

uses
  Forms,
  fm_main_Unit in 'fm_main_Unit.pas' {frm_main},
  Comm_Unit in 'Comm_Unit.pas',
  frm_about_Unit in 'frm_about_Unit.pas' {AboutBox},
  frm_Authorization_Unit in 'frm_Authorization_Unit.pas' {frm_Authorization},
  md5 in 'md5.pas',
  NativeXml in 'NativeXml.pas',
  Symbol_Unit in 'Symbol_Unit.pas',
  frm_printInfo_Unit in 'frm_printInfo_Unit.pas' {frm_printInfo},
  frm_attribInfoUnit in 'frm_attribInfoUnit.pas' {frm_attribInfo},
  webservice in 'webservice.pas';

{$R *.res}

begin
      Application.Initialize;
      Application.CreateForm(Tfrm_main, frm_main);
  Application.Run;
end.

