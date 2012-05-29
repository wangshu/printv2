
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{           Rich Add-In Object            }
{                                         }
{*****************************************}

unit RM_TntRichEdit;

interface

{$I RM.inc}
uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Menus,
  Forms, RM_RichEdit
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF};

type
  { TRMTntRichView }
  TRMTntRichView = class(TRMRichView)
  private
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
  published
  end;

implementation

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMTntRichView}

constructor TRMTntRichView.Create;
begin
  inherited Create;
  BaseName := 'TntRich';
end;

destructor TRMTntRichView.Destroy;
begin
  inherited Destroy;
end;

const
	cRM = 'RM_RichEdit';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass(cRM, TRMTntRichView, 'TRMTntRichView');
  end;
end;


initialization
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

end.

