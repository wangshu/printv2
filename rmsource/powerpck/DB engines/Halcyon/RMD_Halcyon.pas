
{*****************************************}
{                                         }
{            Report Machine 2.0           }
{           Wrapper for Halcyon           }
{                                         }
{*****************************************}

unit RMD_Halcyon;

interface

{$I RM.INC}
uses
  Classes, SysUtils, Forms, ExtCtrls, DB, Dialogs, Controls, StdCtrls,
  RM_Class, RMD_DBWrap, JvInterpreter, Halcn6DB
{$IFDEF Delphi6}, Variants{$ENDIF};

type
  TRMDHalcyonComponents = class(TComponent) // fake component
  end;

 { TRMDHalcyonTable }
  TRMDHalcyonTable = class(TRMDTable)
  private
    FTable: THalcyonDataSet;
  protected
    function GetTableName: string; override;
    procedure SetTableName(Value: string); override;
    function GetFilter: string; override;
    procedure SetFilter(Value: string); override;
    function GetIndexName: string; override;
    procedure SetIndexName(Value: string); override;
    function GetMasterFields: string; override;
    procedure SetMasterFields(Value: string); override;
    function GetMasterSource: string; override;
    procedure SetMasterSource(Value: string); override;
    function GetDatabaseName: string; override;
    procedure SetDatabaseName(const Value: string); override;
    procedure GetIndexNames(sl: TStrings); override;
  public
    constructor Create; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  end;

implementation

uses RM_Common, RM_Const, RM_utils, RM_DsgCtrls, RM_PropInsp, RM_Insp;

{$R RMD_Halcyon.RES}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMDHalcyonTable}

constructor TRMDHalcyonTable.Create;
begin
  inherited Create;
  Typ := gtAddin;
  BaseName := 'HalcyonTable';
  FBmpRes := 'RMD_HalcyonTABLE';

  FTable := THalcyonDataSet.Create(RMDialogForm);
  DataSet := FTable;
end;

procedure TRMDHalcyonTable.LoadFromStream(aStream: TStream);
var
  SaveActive: Boolean;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  SaveActive := FTable.Active;
  FTable.Active := FALSE;
  FTable.EncryptionKey := RMReadString(aStream);
  FTable.Active := SaveActive;
end;

procedure TRMDHalcyonTable.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FTable.EncryptionKey);
end;

procedure TRMDHalcyonTable.GetIndexNames(sl: TStrings);
var
  i: integer;
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

function TRMDHalcyonTable.GetDatabaseName: string;
begin
  Result := FTable.DatabaseName;
end;

procedure TRMDHalcyonTable.SetDatabaseName(const Value: string);
begin
  FTable.Close;
  FTable.DatabaseName := Value;
end;

function TRMDHalcyonTable.GetTableName: string;
begin
  Result := FTable.TableName;
end;

procedure TRMDHalcyonTable.SetTableName(Value: string);
begin
  FTable.Active := False;
  FTable.TableName := Value;
end;

function TRMDHalcyonTable.GetFilter: string;
begin
  Result := FTable.Filter;
end;

procedure TRMDHalcyonTable.SetFilter(Value: string);
begin
  FTable.Active := False;
  FTable.Filter := Value;
  FTable.Filtered := Value <> '';
end;

function TRMDHalcyonTable.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

procedure TRMDHalcyonTable.SetIndexName(Value: string);
begin
  FTable.Active := False;
  FTable.IndexName := Value;
end;

function TRMDHalcyonTable.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TRMDHalcyonTable.SetMasterFields(Value: string);
begin
  FTable.MasterFields := Value;
end;

function TRMDHalcyonTable.GetMasterSource: string;
begin
  Result := RMGetDataSetName(FTable.Owner, FTable.MasterSource)
end;

procedure TRMDHalcyonTable.SetMasterSource(Value: string);
var
  liComponent: TComponent;
begin
  liComponent := RMFindComponent(FTable.Owner, Value);
  if (liComponent <> nil) and (liComponent is TDataSet) then
    FTable.MasterSource := RMGetDataSource(FTable.Owner, TDataSet(liComponent))
  else
    FTable.MasterSource := nil;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
type
  TRMDHalcyonTable_Editor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TIndexNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TTableNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDHalcyonTable_Editor }

function TRMDHalcyonTable_Editor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TRMDHalcyonTable_Editor.Edit;
var
  str: string;
  i: integer;
  t: TRMView;
begin
  if RMSelectDirectory(RMLoadStr(rmRes + 3252), '', str) then
  begin
    RMDesigner.BeforeChange;
    for i := 0 to RMDesigner.Page.Objects.Count - 1 do
    begin
      t := RMDesigner.Page.Objects[i];
      if (t.Selected) and (t is TRMDHalcyonTable) then
        TRMDHalcyonTable(t).FTable.DatabaseName := str;
    end;
    RMDesigner.AfterChange;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TIndexNameEditor }

function TIndexNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TIndexNameEditor.GetValues(AValues: TStrings);
var
  liTable: TRMDHalcyonTable;
begin
  liTable := TRMDHalcyonTable(GetInstance(0));
  liTable.GetIndexNames(aValues);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TTableNameEditor }

function TTableNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praValueList, praSortList];
end;

procedure TTableNameEditor.GetValues(AValues: TStrings);
var
  liStringList: TStringList;
  lTable: THalcyonDataSet;
begin
  lTable := TRMDHalcyonTable(GetInstance(0)).FTable;
  liStringList := TStringList.Create;
  try
    lTable.GetTableNames(liStringList);
    liStringList.Sort;
    aValues.Assign(liStringList);
  finally
    liStringList.Free;
  end;
end;

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TRMDHalcyonTable, 'TRMDHalcyonTable');

    RMRegisterPropEditor(TypeInfo(string), TRMDHalcyonTable, 'DatabaseName', TRMDHalcyonTable_Editor);
    RMRegisterPropEditor(TypeInfo(string), TRMDHalcyonTable, 'IndexName', TIndexNameEditor);
    RMRegisterPropEditor(TypeInfo(string), TRMDHalcyonTable, 'TableName', TTableNameEditor);
  end;
end;

initialization
  RMRegisterControl(TRMDHalcyonTable, 'RMD_HalcyonTABLECONTROL', RMLoadStr(SInsertTable) + '(Halcyon)');

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

end.

