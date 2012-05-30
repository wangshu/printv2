
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{          Report Wizard Reg              }
{                                         }
{*****************************************}


unit RM_Wizard;

interface

{$I RM.inc}

uses
  Windows, Controls, Classes, RM_Common, RM_Class;

type

  TRMWizardClass = class of TRMWizard;
  TRMReportWizardClass = class of TRMCustomReportWizard;

  { TRMWizard }
  TRMWizard = class
  public
    class function ClassDescription: string; virtual;
    class function ClassBitmap: THandle; virtual;
  end;

  { TrmCustomReportWizard }
  TRMCustomReportWizard = class(TRMWizard)
  private
  protected
  public
		constructor Create; virtual;
    function DoCreateReport: Boolean; virtual; abstract;
    procedure GetReportStream(aStream: TMemoryStream); virtual; abstract;
  end;

procedure RMRegisterWizard(aWizardClass: TRMWizardClass);
procedure RMUnRegisterWizard(aWizardClass: TRMWizardClass);

function RMGetWizardClassList: TList;

implementation

var
  FWizardClassList: TList = nil;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMWizard }

class function TRMWizard.ClassDescription: string;
begin
  Result := ClassName;
end;

class function TRMWizard.ClassBitmap: THandle;
begin
	Result := 0;
//  Result := ppBitmapFromResource('PPNOWIZARDBITMAP');
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TrmCustomReportWizard}
constructor TrmCustomReportWizard.Create;
begin
	Inherited Create;
end;

function RMGetWizardClassList: TList;
begin
  if FWizardClassList = nil then
    FWizardClassList := TList.Create;

  Result := FWizardClassList;
end;

procedure RMRegisterWizard(aWizardClass: TRMWizardClass);
var
  lClassList: TList;
  lindex: Integer;
begin
  if aWizardClass = nil then Exit;

  lClassList := rmGetWizardClassList;
  lIndex := lClassList.IndexOf(aWizardClass);
  if lIndex < 0 then
  begin
    lClassList.Add(aWizardClass);
  end;
end;

procedure RMUnRegisterWizard(aWizardClass: TRMWizardClass);
var
  lClassList: TList;
  liIndex: Integer;
begin
  if aWizardClass = nil then Exit;

  if FWizardClassList = nil then Exit;
  lClassList := rmGetWizardClassList;
  liIndex := lClassList.IndexOf(aWizardClass);
  if liIndex >= 0 then
  begin
    lClassList.Delete(liIndex);
  end;
end;

initialization

finalization
  FWizardClassList.Free;
  FWizardClassList := nil;

end.

