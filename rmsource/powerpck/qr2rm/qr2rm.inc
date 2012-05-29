{$B-} {- Complete Boolean Evaluation }
{$R-} {- Range-Checking }
{$V-} {- Var-String Checking }
{$T-} {- Typed @ operator }
{$X+} {- Extended syntax }
{$P+} {- Open string params }
{$J+} {- Writeable structured consts }
{$H+} {- Use long strings by default }

{$IFDEF VER90}       // Delphi 2.0
  {$DEFINE RM_Delphi2}
{$ENDIF}

{$IFDEF VER100}      // Delphi 3.0
  {$DEFINE RM_Delphi3}
{$ENDIF}

{$IFDEF VER120}      // Delphi 4.0
  {$DEFINE RM_Delphi4}
{$ENDIF}

{$IFDEF VER130}      // Delphi 5.0
  {$DEFINE RM_Delphi4}
  {$DEFINE RM_Delphi5}
{$ENDIF}

{$IFDEF VER140}      // Delphi 6.0
  {$DEFINE RM_Delphi4}
  {$DEFINE RM_Delphi5}
  {$DEFINE RM_Delphi6}
{$ENDIF}

{$IFDEF VER93}       // Borland C++ Builder 1.0
  {$DEFINE RM_Delphi2}
{$ENDIF}

{$IFDEF VER110}      // Borland C++ Builder 3.0
  {$DEFINE RM_Delphi3}
  {$ObjExportAll on}
{$ENDIF}

{$IFDEF VER125}      // Borland C++ Builder 4.0
  {$DEFINE RM_Delphi4}
  {$ObjExportAll on}
{$ENDIF}