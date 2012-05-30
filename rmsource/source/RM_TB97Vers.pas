unit RM_TB97Vers;

{
  Toolbar97
  Copyright (C) 1998-2001 by Jordan Russell
  For conditions of distribution and use, see LICENSE.TXT.

  Version constant

  $Id: TB97Vers.pas,v 1.5 2001/06/18 19:21:06 jr Exp $
}

{$I RM.INC}
interface

{$IFDEF USE_INTERNALTB97}
{$I RM_TB97Ver.inc}

const
  Toolbar97Version = '1.78';
  Toolbar97VersionPropText = 'Toolbar97 version ' + Toolbar97Version;

type
  TToolbar97Version = type string;

const
  Sig: PChar = '- ' + Toolbar97VersionPropText +
    {$IFDEF VER90}  '/D2'+ {$ENDIF} {$IFDEF VER93}  '/CB1'+ {$ENDIF}
    {$IFDEF VER100} '/D3'+ {$ENDIF} {$IFDEF VER110} '/CB3'+ {$ENDIF}
    {$IFDEF VER120} '/D4'+ {$ENDIF} {$IFDEF VER125} '/CB4'+ {$ENDIF}
    {$IFNDEF BCB} {$IFDEF VER130} '/D5'+ {$ENDIF} {$ELSE} {$IFDEF VER130} '/CB5'+ {$ENDIF} {$ENDIF}
    {$IFNDEF BCB} {$IFDEF VER140} '/D6'+ {$ENDIF} {$ELSE} {$IFDEF VER140} '/CB6'+ {$ENDIF} {$ENDIF}
    ', Copyright (C) 1998-2001 Jordan Russell -';

{$ENDIF}
implementation

{$IFDEF USE_INTERNALTB97}
initialization
  Sig := Sig;
{$ENDIF}  
end.

