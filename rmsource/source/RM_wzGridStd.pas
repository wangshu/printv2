unit RM_wzGridStd;

interface

{$I RM.inc}

uses
  Windows, Controls, Classes, RM_Wizard;

type
  TRMWizardGridSimple = class(TRMCustomReportWizard)
  private
    FStream: TMemoryStream;
  protected
  public
    class function ClassDescription: string; override;
    class function ClassBitmap: THandle; override;

    constructor Create; override;
    destructor Destroy; override;

    function DoCreateReport: Boolean; override;
    procedure GetReportStream(aStream: TMemoryStream); override;
  end;

implementation

uses
  RM_GridReportMaster;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMWizardGridSimple }

class function TRMWizardGridSimple.ClassDescription: string;
begin
  Result := 'Simple GridReport';
end;

class function TRMWizardGridSimple.ClassBitmap: THandle;
begin
	Result := 0;
end;

constructor TRMWizardGridSimple.Create;
begin
  inherited;

  FStream := TMemoryStream.Create;
end;

destructor TRMWizardGridSimple.Destroy;
begin
  FStream.Free;

  inherited;
end;

function TRMWizardGridSimple.DoCreateReport: Boolean;
var
  lReportMaster: TRMGridReportMaster;
begin
  Result := False;
  lReportMaster := TRMGridReportMaster.Create(nil);
  try
    if lReportMaster.DesignTemplate then
    begin
      Result := lReportMaster.CreateReport;
      if Result then
      begin
      	FStream.Clear;
        lReportMaster.Report.SaveToStream(FStream);
      end;
    end;
  finally
    lReportMaster.Free;
  end;
end;

procedure TRMWizardGridSimple.GetReportStream(aStream: TMemoryStream);
begin
	FStream.Position := 0;
	aStream.CopyFrom(FStream, 0);
end;

initialization
	RMRegisterWizard(TRMWizardGridSimple);

finalization

end.

