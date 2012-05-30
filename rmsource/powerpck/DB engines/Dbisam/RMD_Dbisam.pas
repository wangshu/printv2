
{*****************************************}
{                                         }
{           Report Machine 2.0            }
{           Wrapper for DBIASM            }
{                                         }
{*****************************************}

unit RMD_Dbisam;

interface

{$I RM.INC}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, Dialogs, Controls, StdCtrls,
  RM_Class, RMD_DBWrap, DBISAMTb
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMDDBISAMComponents = class(TComponent) // fake component
  end;

  TRMDDBISAMDatabase = class(TRMNonVisualControl)
  private
    FDatabase: TDBISAMDatabase;
    procedure PropEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: string; Value: Variant); override;
    function GetPropValue(Index: string): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
    property Database: TDBISAMDatabase read FDatabase;
  end;

 { TRMDDBISAMTable }
  TRMDDBISAMTable = class(TRMDTable)
  private
    FTable: TDBISAMTable;
  protected
    procedure GetDatabases(sl: TStrings); override;
    procedure GetTableNames(sl: TStrings); override;

    procedure SetPropValue(Index: string; Value: Variant); override;
    function GetPropValue(Index: string): Variant; override;
  public
    constructor Create; override;
    procedure GetIndexNames(sl: TStrings); override;
    procedure DefineProperties; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  { TRMDDBISAMQuery }
  TRMDDBISAMQuery = class(TRMDQuery)
  private
    FQuery: TDBISAMQuery;
  protected
    function GetParamName(Index: Integer): string; override;
    function GetParamType(Index: Integer): TFieldType; override;
    procedure SetParamType(Index: Integer; Value: TFieldType); override;
    function GetParamKind(Index: Integer): TRMParamKind; override;
    procedure SetParamKind(Index: Integer; Value: TRMParamKind); override;
    function GetParamText(Index: Integer): string; override;
    procedure SetParamText(Index: Integer; Value: string); override;
    function GetParamValue(Index: Integer): Variant; override;
    procedure SetParamValue(Index: Integer; Value: Variant); override;

    procedure GetDatabases(sl: TStrings); override;
    procedure GetTableNames(DB: string; Strings: TStrings); override;

    procedure SetPropValue(Index: string; Value: Variant); override;
    function GetPropValue(Index: string): Variant; override;
    function DoMethod(const MethodName: string; Pars: array of Variant): Variant; override;
  public
    constructor Create; override;
    procedure GetTableFieldNames(const DB, TName: string; sl: TStrings); override;
    procedure DefineProperties; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  published
  end;

implementation

uses RM_Common, RM_Const, RM_CmpReg, RM_utils;

{$R RMD_DBISAM.RES}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDBISAMDatabase}

constructor TRMDDBISAMDatabase.Create;
begin
  inherited Create;
  FDatabase := TDBISAMDatabase.Create(RMDialogForm);
  Component := FDatabase;
  BaseName := 'DBISAMDatabase';
  BmpRes := 'RMD_DBISAMDB';
  Flags := Flags or flDontUndo;
end;

destructor TRMDDBISAMDatabase.Destroy;
begin
  if Assigned(RMDialogForm) then
    FDatabase.Free;
  inherited Destroy;
end;

procedure TRMDDBISAMDatabase.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Connected', [rmdtBoolean], nil);
  AddProperty('DatabaseName', [rmdtString], nil);
  AddProperty('Directory', [rmdtString, rmdtHasEditor], PropEditor);
end;

procedure TRMDDBISAMDatabase.SetPropValue(Index: string; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'DATABASENAME' then
    FDatabase.DatabaseName := Value
  else if Index = 'DIRECTORY' then
    FDatabase.Directory := Value
  else if Index = 'CONNECTED' then
    FDatabase.Connected := Value;
end;

function TRMDDBISAMDatabase.GetPropValue(Index: string): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASENAME' then
    Result := FDatabase.DatabaseName
  else if Index = 'DIRECTORY' then
    Result := FDatabase.Directory
  else if Index = 'CONNECTED' then
    Result := FDatabase.Connected;
end;

procedure TRMDDBISAMDatabase.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FDatabase.DatabaseName := RMReadString(Stream);
  FDatabase.Directory := RMReadString(Stream);
  FDatabase.Connected := RMReadBoolean(Stream);
end;

procedure TRMDDBISAMDatabase.SaveToStream(Stream: TStream);
begin
	LVersion := 0;
  inherited SaveToStream(Stream);
  RMWriteString(Stream, FDatabase.DatabaseName);
  RMWriteString(Stream, FDatabase.Directory);
  RMWriteBoolean(Stream, FDatabase.Connected);
end;

procedure TRMDDBISAMDatabase.ShowEditor;
begin
  PropEditor(nil);
end;

procedure TRMDDBISAMDatabase.PropEditor(Sender: TObject);
var
  str: string;
  i: integer;
  t: TRMView;
begin
  if RMSelectDirectory('Ñ¡ÔñÎÄ¼þ¼Ð', '', str) then
  begin
    RMDesigner.BeforeChange;
    for i := 0 to RMDesigner.Page.Objects.Count - 1 do
    begin
      t := RMDesigner.Page.Objects[i];
      if (t.Selected) and (t is TRMDDBISAMDatabase) then
        TRMDDBISAMDatabase(t).FDatabase.Directory := str;
    end;
    RMDesigner.AfterChange;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDBISAMTable}

constructor TRMDDBISAMTable.Create;
begin
  inherited Create;
  FTable := TDBISAMTable.Create(RMDialogForm);
  DataSet := FTable;

  Component := FTable;
  BaseName := 'DBISAMTable';
  BmpRes := 'RMD_DBISAMTABLE';
end;

procedure TRMDDBISAMTable.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    FTable.DBSession.GetDatabaseNames(liStringList);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    sl.Free;
  end;
end;

procedure TRMDDBISAMTable.GetIndexNames(sl: TStrings);
var
  i: Integer;
begin
  sl.Clear;
  try
    if (Length(FTable.TableName) > 0) and (FTable.IndexDefs <> nil) then
    begin
      FTable.IndexDefs.Update;
      for i := 0 to FTable.IndexDefs.Count - 1 do
      begin
        if FTable.IndexDefs[i].Name <> '' then
          sl.Add(FTable.IndexDefs[i].Name);
      end;
    end;
  except
  end;
end;

procedure TRMDDBISAMTable.GetTableNames(sl: TStrings);
var
  liStringList: TStringList;
begin
  if FTable.DatabaseName <> '' then
  begin
    liStringList := TStringList.Create;
    try
      FTable.DBSession.GetTableNames(FTable.DatabaseName, liStringList);
      liStringList.Sort;
      sl.Assign(liStringList);
    finally
      sl.Free;
    end;
  end;
end;

procedure TRMDDBISAMTable.DefineProperties;
begin
  inherited DefineProperties;
end;

procedure TRMDDBISAMTable.SetPropValue(Index: string; Value: Variant);
var
  d: TComponent;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'INDEXNAME' then
    FTable.IndexFieldNames := Value //FTable.IndexName := Value
  else if Index = 'MASTERSOURCE' then
  begin
    d := RMFindComponent(FTable.Owner, Value);
    FTable.MasterSource := RMGetDataSource(FTable.Owner, TDataSet(d));
  end
  else if Index = 'MASTERFIELDS' then
    FTable.MasterFields := Value
  else if Index = 'TABLENAME' then
  begin
    FTable.Close;
    FTable.TableName := Value;
  end
  else if index = 'DATABASE' then
  begin
    FTable.Close;
    FTable.DatabaseName := Value;
  end
end;

function TRMDDBISAMTable.GetPropValue(Index: string): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'INDEXNAME' then
    Result := FTable.IndexFieldNames //Result := FTable.IndexName
  else if Index = 'MASTERSOURCE' then
    Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
  else if Index = 'MASTERFIELDS' then
    Result := FTable.MasterFields
  else if Index = 'TABLENAME' then
    Result := FTable.TableName
  else if Index = 'DATABASE' then
    Result := FTable.DatabaseName;
end;

procedure TRMDDBISAMTable.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
end;

procedure TRMDDBISAMTable.SaveToStream(Stream: TStream);
begin
	LVersion := 0;
  inherited SaveToStream(Stream);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDDBISAMQuery}

constructor TRMDDBISAMQuery.Create;
begin
  inherited Create;
  FQuery := TDBISAMQuery.Create(RMDialogForm);
  DataSet := FQuery;

  Component := FQuery;
  BaseName := 'DBISAMQuery';
  BmpRes := 'RMD_DBISAMQUERY';
end;

procedure TRMDDBISAMQuery.DefineProperties;
begin
  inherited DefineProperties;
end;

procedure TRMDDBISAMQuery.SetPropValue(Index: string; Value: Variant);
var
  d: TComponent;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if index = 'DATABASE' then
  begin
    FQuery.Close;
    FQuery.DatabaseName := Value;
  end
  else if Index = 'DATASOURCE' then
  begin
    d := RMFindComponent(FQuery.Owner, Value);
    FQuery.DataSource := RMGetDataSource(FQuery.Owner, TDataSet(d));
  end
  else if index = 'PARAMS.COUNT' then
  begin
  end
  else if Index = 'SQL' then
  begin
    FQuery.Close;
    FQuery.SQL.Text := Value;
  end
end;

function TRMDDBISAMQuery.GetPropValue(Index: string): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'DATABASE' then
    Result := FQuery.DatabaseName
  else if Index = 'DATASOURCE' then
    Result := RMGetDataSetName(FQuery.Owner, FQuery.DataSource)
  else if Index = 'PARAMS.COUNT' then
    Result := FQuery.Params.Count
  else if Index = 'SQL' then
    Result := FQuery.SQL.Text
  else if Index = 'SQL.COUNT' then
    Result := FQuery.SQL.Count
end;

function TRMDDBISAMQuery.DoMethod(const MethodName: string; Pars: array of Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Pars);
  if Result = Null then
    Result := LinesMethod(FQuery.SQL, MethodName, 'SQL', Pars[0], Pars[1], Pars[2]);
  if MethodName = 'EXECSQL' then
  begin
  	OnBeforeOpenQueryEvent(FQuery);
    FQuery.ExecSQL;
  end;
end;

procedure TRMDDBISAMQuery.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
end;

procedure TRMDDBISAMQuery.SaveToStream(Stream: TStream);
begin
	LVersion := 0;
  inherited SaveToStream(Stream);
end;

procedure TRMDDBISAMQuery.GetDatabases(sl: TStrings);
var
  liStringList: TStringList;
begin
  liStringList := TStringList.Create;
  try
    FQuery.DBSession.GetDatabaseNames(liStringList);
    liStringList.Sort;
    sl.Assign(liStringList);
  finally
    sl.Free;
  end;
end;

procedure TRMDDBISAMQuery.GetTableNames(DB: string; Strings: TStrings);
var
  sl: TStringList;
begin
  Strings.Clear;
  sl := TStringList.Create;
  try
    if FQuery.DatabaseName <> '' then
    begin
      try
        FQuery.DBSession.GetTableNames(FQuery.DatabaseName, sl);
        sl.Sort;
        Strings.Assign(sl);
      except
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure TRMDDBISAMQuery.GetTableFieldNames(const DB, TName: string; sl: TStrings);
var
  i: Integer;
  lStrings: TStringList;
  t: TDBISAMTable;
begin
  lStrings := TStringList.Create;
  t := TDBISAMTable.Create(RMDialogForm);
  try
    t.DatabaseName := FQuery.DatabaseName;
    t.TableName := tName;
    try
      t.FieldDefs.UpDate;
      for i := 0 to t.FieldDefs.Count - 1 do
        lStrings.Add(t.FieldDefs.Items[i].Name);
      lStrings.Sort;
      sl.Assign(lStrings);
    except;
    end;
  finally
    lStrings.Free;
    t.Free;
  end;
end;

function TRMDDBISAMQuery.GetParamName(Index: Integer): string;
begin
  Result := FQuery.Params[Index].Name;
end;

function TRMDDBISAMQuery.GetParamType(Index: Integer): TFieldType;
begin
  Result := FQuery.Params[Index].DataType;
end;

procedure TRMDDBISAMQuery.SetParamType(Index: Integer; Value: TFieldType);
begin
  FQuery.Params[Index].DataType := Value;
end;

function TRMDDBISAMQuery.GetParamKind(Index: Integer): TRMParamKind;
begin
  Result := rmpkValue;
  if not FQuery.Params[Index].Bound then
    Result := rmpkAssignFromMaster;
end;

procedure TRMDDBISAMQuery.SetParamKind(Index: Integer; Value: TRMParamKind);
begin
  if Value = rmpkAssignFromMaster then
  begin
    FQuery.Params[Index].Bound := False;
    FParams.Delete(FParams.IndexOf(FQuery.Params[Index].Name));
  end
  else
  begin
    FQuery.Params[Index].Clear;
    FQuery.Params[Index].Bound := True;
    FParams[FQuery.Params[Index].Name] := '';
  end;
end;

function TRMDDBISAMQuery.GetParamText(Index: Integer): string;
begin
  Result := '';
  if ParamKind[Index] = rmpkValue then
    Result := FParams[FQuery.Params[Index].Name];
end;

procedure TRMDDBISAMQuery.SetParamText(Index: Integer; Value: string);
begin
  if ParamKind[Index] = rmpkValue then
    FParams[FQuery.Params[Index].Name] := Value;
end;

function TRMDDBISAMQuery.GetParamValue(Index: Integer): Variant;
begin
  Result := FQuery.Params[Index].Value;
end;

procedure TRMDDBISAMQuery.SetParamValue(Index: Integer; Value: Variant);
begin
  FQuery.Params[Index].Value := Value;
end;


initialization
  RMRegisterControl(TRMDDBISAMDatabase, 'RMD_DBISAMDBCONTROL', RMLoadStr(SInsertDB) + '(Dbisam)');
  RMRegisterControl(TRMDDBISAMTable, 'RMD_DBISAMTABLECONTROL', RMLoadStr(SInsertTable) + '(Dbisam)');
  RMRegisterControl(TRMDDBISAMQuery, 'RMD_DBISAMQUERYCONTROL', RMLoadStr(SInsertQuery) + '(Dbisam)');

end.

