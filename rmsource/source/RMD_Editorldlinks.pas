unit RMD_Editorldlinks;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DB, Buttons, Dialogs, RMD_DBWrap, RM_PropInsp;

const
  SPrimary = 'Primary';
  SLinkDesigner = 'SLinkDesigner';

type

{ TFieldLink }

  TRMDFieldLinkProperty = class(TELStringPropEditor)
  private
  	FFullIndexName: string;
    FChanged: Boolean;
    FDataSet: TRMDDataSet;
    FIndexName: string;
    FIndexFieldNames: string;
  protected
    function GetDataSet: TRMDDataSet;
    procedure GetFieldNamesForIndex(aList: TStrings); virtual;
    function GetIndexBased: Boolean; virtual;
    function GetIndexDefs: TIndexDefs; virtual;
    function GetIndexFieldNames: string; virtual;
    function GetMasterFields: string; virtual; abstract;

    procedure SetIndexFieldNames(const Value: string); virtual;
    procedure SetIndexName(const Value: string); virtual;
    function GetIndexName: string; virtual;
    procedure SetMasterFields(const Value: string); virtual; abstract;
  public
    constructor CreateWith(ADataSet: TRMDDataSet); virtual;
    procedure GetIndexNames(List: TStrings);
    property IndexBased: Boolean read GetIndexBased;
    property IndexDefs: TIndexDefs read GetIndexDefs;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property Changed: Boolean read FChanged;
    property DataSet: TRMDDataSet read GetDataSet;
    property FullIndexName: string read FFullIndexName;

    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

{ TLink Fields }

  TRMDFieldsLinkForm = class(TForm)
    MasterList: TListBox;
    BindList: TListBox;
    Label30: TLabel;
    Label31: TLabel;
    IndexList: TComboBox;
    IndexLabel: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnAdd: TButton;
    btnDelete: TButton;
    btnClear: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    DetailList: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure BindingListClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure BindListClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure IndexListChange(Sender: TObject);
  private
    FDetailDataSet: TRMDDataSet;
    FMasterDataSet: TDataSet;
    FDataSetProxy: TRMDFieldLinkProperty;
    FFullIndexName: string;
    MasterFieldList: string;
    IndexFieldList: string;
    OrderedDetailList: TStringList;
    OrderedMasterList: TStringList;
    procedure OrderFieldList(OrderedList, List: TStrings);
    procedure AddToBindList(const Str1, Str2: string);
    procedure Localize;
    procedure Initialize;
    procedure SetDataSet(Value: TRMDDataSet);
  public
    function Edit: Boolean;
    //property MasterDS: TDataSet read FMasterDataSet write FMasterDataSet;
    property DetailDS: TRMDDataSet read FDetailDataSet write SetDataSet;
    property DataSetProxy: TRMDFieldLinkProperty read FDataSetProxy write FDataSetProxy;
    property FullIndexName: string read FFullIndexName;
  end;

implementation

uses
  RM_Const, RM_Const1, RM_Utils;

{$R *.dfm}

{ Utility Functions }

function StripFieldName(const Fields: string; var Pos: Integer): string;
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(Fields)) and (Fields[I] <> ';') do Inc(I);
  Result := Copy(Fields, Pos, I - Pos);
  if (I <= Length(Fields)) and (Fields[I] = ';') then Inc(I);
  Pos := I;
end;

function StripDetail(const Value: string): string;
var
  S: string;
  I: Integer;
begin
  S := Value;
  I := 0;
  while Pos('->', S) > 0 do
  begin
    I := Pos('->', S);
    S[I] := ' ';
  end;
  Result := Copy(Value, 0, I - 2);
end;

function StripMaster(const Value: string): string;
var
  S: string;
  I: Integer;
begin
  S := Value;
  I := 0;
  while Pos('->', S) > 0 do
  begin
    I := Pos('->', S);
    S[I] := ' ';
  end;
  Result := Copy(Value, I + 3, Length(Value));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDFieldLinkProperty }

constructor TRMDFieldLinkProperty.CreateWith(aDataSet: TRMDDataSet);
begin
  FDataSet := aDataSet;
end;

function TRMDFieldLinkProperty.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praReadOnly];
end;

procedure TRMDFieldLinkProperty.Edit;
var
	tmp: TRMDFieldsLinkForm;
begin
	tmp := TRMDFieldsLinkForm.Create(nil);
  try
  	tmp.DataSetProxy := Self;
    tmp.DetailDS := DataSet;
    FChanged := tmp.Edit;
    if FChanged then
    begin
    	FFullIndexName := tmp.FullIndexName;
			Modified;
    end;
  finally
  	tmp.Free;
  end;
end;

function TRMDFieldLinkProperty.GetIndexBased: Boolean;
begin
  Result := FDataSet.IndexBased;
end;

function TRMDFieldLinkProperty.GetIndexDefs: TIndexDefs;
begin
  Result := FDataSet.IndexDefs;
end;

function TRMDFieldLinkProperty.GetIndexFieldNames: string;
begin
  Result := FIndexFieldNames;
end;

procedure TRMDFieldLinkProperty.SetIndexFieldNames(const Value: string);
begin
  FIndexFieldNames := Value;
end;

procedure TRMDFieldLinkProperty.GetIndexNames(List: TStrings);
var
  i: Integer;
begin
  if IndexDefs <> nil then
  begin
    for i := 0 to IndexDefs.Count - 1 do
    begin
      if (ixPrimary in IndexDefs.Items[i].Options) and (IndexDefs.Items[i].Name = '') then
        List.Add(SPrimary)
      else
        List.Add(IndexDefs.Items[i].Name);
    end;
  end;
end;

procedure TRMDFieldLinkProperty.GetFieldNamesForIndex(aList: TStrings);
var
  i: Integer;
  str: string;

  procedure _SetFieldNames(aField: string);
  var
    lPos: Integer;
    lStr: string;
  begin
    aList.Clear;
    lPos := 1;
    while lPos > 0 do
    begin
      lStr := RMstrGetToken(aField, ';', lPos);
      aList.Add(lStr);
    end;
  end;

begin
  if IndexDefs <> nil then
  begin
    for i := 0 to IndexDefs.Count - 1 do
    begin
      if FIndexName = SPrimary then
      begin
        if (ixPrimary in IndexDefs.Items[i].Options) and (IndexDefs.Items[i].Name = '') then
        begin
          str := IndexDefs.Items[i].Fields;
          _SetFieldNames(str);
        end;
      end
      else if FIndexName = IndexDefs.Items[i].Name then
      begin
        str := IndexDefs.Items[i].Fields;
          _SetFieldNames(str);
      end;
    end;
  end;
end;

function TRMDFieldLinkProperty.GetIndexName: string;
begin
  Result := FIndexName;
end;

procedure TRMDFieldLinkProperty.SetIndexName(const Value: string);
begin
  FIndexName := Value;
end;

function TRMDFieldLinkProperty.GetDataSet: TRMDDataset;
begin
  if FDataSet = nil then
    FDataSet := TRMDDataSet(GetInstance(0));

  Result := FDataSet;
end;

{function TRMDFieldLinkProperty.GetMasterFields: string;
begin
  Result := FMasterFields;
end;

procedure TRMDFieldLinkProperty.SetMasterFields(const Value: string);
begin
  FMasterFields := Value;
end;}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDFieldsLinkForm }

procedure TRMDFieldsLinkForm.FormCreate(Sender: TObject);
begin
  OrderedDetailList := TStringList.Create;
  OrderedMasterList := TStringList.Create;
end;

procedure TRMDFieldsLinkForm.FormDestroy(Sender: TObject);
begin
  OrderedDetailList.Free;
  OrderedMasterList.Free;
end;

function TRMDFieldsLinkForm.Edit;
var
  i: Integer;
  lFound: Boolean;
begin
  Localize;
  Initialize;
  if ShowModal = mrOK then
  begin
    if FullIndexName <> '' then
    begin
      lFound := False;
      if FullIndexName = SPrimary then
      begin
        if DataSetProxy.IndexBased and (DataSetProxy.IndexDefs <> nil) then
        begin
          for i := 0 to DataSetProxy.IndexDefs.Count - 1 do
          begin
            if (ixPrimary in DataSetProxy.IndexDefs.Items[i].Options) and (DataSetProxy.IndexDefs.Items[i].Name = '') then
            begin
              lFound := True;
              FFullIndexName := '';
              DataSetProxy.IndexFieldNames := DataSetProxy.IndexDefs.Items[i].Fields;
            end;
          end;
        end;
      end;

      if not lFound then
        DataSetProxy.IndexName := FullIndexName;
    end
    else
      DataSetProxy.IndexFieldNames := IndexFieldList;

    DataSetProxy.MasterFields := MasterFieldList;
    Result := True;
  end
  else
    Result := False;
end;

procedure TRMDFieldsLinkForm.SetDataSet(Value: TRMDDataset);
var
  lIndexDefs: TIndexDefs;
begin
  Value.DataSet.FieldDefs.Update;
  lIndexDefs := DataSetProxy.IndexDefs;
  if Assigned(lIndexDefs) then
  	lIndexDefs.Update;

  if not Assigned(Value.DataSet.DataSource) or not Assigned(Value.DataSet.DataSource.DataSet) then
    DatabaseError('SMissingDataSource', Value.DataSet);

  Value.DataSet.DataSource.DataSet.FieldDefs.Update;
  FDetailDataSet := Value;
  FMasterDataSet := Value.DataSet.DataSource.DataSet;
end;

procedure TRMDFieldsLinkForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Label30, 'Caption', rmRes + 3130);
  RMSetStrProp(Label31, 'Caption', rmRes + 3131);
  RMSetStrProp(Label2, 'Caption', rmRes + 3132);
  RMSetStrProp(btnAdd, 'Caption', rmRes + 3133);
  RMSetStrProp(btnClear, 'Caption', rmRes + 3134);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDFieldsLinkForm.Initialize;
var
  SIndexName: string;

  procedure SetUpLists(const MasterFieldList, DetailFieldList: string);
  var
    I, J: Integer;
    MasterFieldName, DetailFieldName: string;
  begin
    I := 1;
    J := 1;
    while (I <= Length(MasterFieldList)) and (J <= Length(DetailFieldList)) do
    begin
      MasterFieldName := StripFieldName(MasterFieldList, I);
      DetailFieldName := StripFieldName(DetailFieldList, J);
      if (MasterList.Items.IndexOf(MasterFieldName) <> -1) and
        (OrderedDetailList.IndexOf(DetailFieldName) <> -1) then
      begin
        with OrderedDetailList do
          Objects[IndexOf(DetailFieldName)] := TObject(True);
        with DetailList.Items do Delete(IndexOf(DetailFieldName));
        with MasterList.Items do Delete(IndexOf(MasterFieldName));
        BindList.Items.Add(Format('%s -> %s',
          [DetailFieldName, MasterFieldName]));
        btnClear.Enabled := True;
      end;
    end;
  end;

begin
  if not DataSetProxy.IndexBased then
  begin
    IndexLabel.Visible := False;
    IndexList.Visible := False;
  end
  else
  begin
    with DataSetProxy do
    begin
      GetIndexNames(IndexList.Items);
      if IndexFieldNames <> '' then
        SIndexName := IndexDefs.FindIndexForFields(IndexFieldNames).Name
      else SIndexName := IndexName;
      if (SIndexName <> '') and (IndexList.Items.IndexOf(SIndexName) >= 0) then
        IndexList.ItemIndex := IndexList.Items.IndexOf(SIndexName) else
        IndexList.ItemIndex := 0;
    end;
  end;

  with DataSetProxy do
  begin
    MasterFieldList := MasterFields;
    if (IndexFieldNames = '') and (IndexName <> '') and
      (IndexDefs.IndexOf(IndexName) >= 0) then
      IndexFieldList := IndexDefs[IndexDefs.IndexOf(IndexName)].Fields
    else
      IndexFieldList := IndexFieldNames;
  end;
  IndexListChange(nil);
  FMasterDataSet.GetFieldNames(MasterList.Items);
  OrderedMasterList.Assign(MasterList.Items);
  SetUpLists(MasterFieldList, IndexFieldList);
end;

procedure TRMDFieldsLinkForm.IndexListChange(Sender: TObject);
var
  I: Integer;
  IndexExp: string;
begin
  DetailList.Items.Clear;
  if DataSetProxy.IndexBased then
  begin
    DataSetProxy.IndexName := IndexList.Text;
    I := DataSetProxy.IndexDefs.IndexOf(DataSetProxy.IndexName);
    if I <> -1 then
      IndexExp := DataSetProxy.IndexDefs.Items[I].Expression;
    if IndexExp <> '' then
      DetailList.Items.Add(IndexExp)
    else
      DataSetProxy.GetFieldNamesForIndex(DetailList.Items);
  end
  else
  begin
    DetailDS.DataSet.GetFieldNames(DetailList.Items);
  end;

  MasterList.Items.Assign(OrderedMasterList);
  OrderedDetailList.Assign(DetailList.Items);
  for I := 0 to OrderedDetailList.Count - 1 do
    OrderedDetailList.Objects[I] := TObject(False);
  BindList.Clear;
  btnAdd.Enabled := False;
  btnClear.Enabled := False;
  btnDelete.Enabled := False;
  MasterList.ItemIndex := -1;
end;

procedure TRMDFieldsLinkForm.OrderFieldList(OrderedList, List: TStrings);
var
  I, J: Integer;
  MinIndex, Index, FieldIndex: Integer;
begin
  for J := 0 to List.Count - 1 do
  begin
    MinIndex := $7FFF;
    FieldIndex := -1;
    for I := J to List.Count - 1 do
    begin
      Index := OrderedList.IndexOf(List[I]);
      if Index < MinIndex then
      begin
        MinIndex := Index;
        FieldIndex := I;
      end;
    end;
    List.Move(FieldIndex, J);
  end;
end;

procedure TRMDFieldsLinkForm.AddToBindList(const Str1, Str2: string);
var
  I: Integer;
  NewField: string;
  NewIndex: Integer;
begin
  NewIndex := OrderedDetailList.IndexOf(Str1);
  NewField := Format('%s -> %s', [Str1, Str2]);
  with BindList.Items do
  begin
    for I := 0 to Count - 1 do
    begin
      if OrderedDetailList.IndexOf(StripDetail(Strings[I])) > NewIndex then
      begin
        Insert(I, NewField);
        Exit;
      end;
    end;
    Add(NewField);
  end;
end;

procedure TRMDFieldsLinkForm.BindingListClick(Sender: TObject);
begin
  btnAdd.Enabled := (DetailList.ItemIndex <> LB_ERR) and
    (MasterList.ItemIndex <> LB_ERR);
end;

procedure TRMDFieldsLinkForm.btnAddClick(Sender: TObject);
var
  DetailIndex: Integer;
  MasterIndex: Integer;
begin
  DetailIndex := DetailList.ItemIndex;
  MasterIndex := MasterList.ItemIndex;
  AddToBindList(DetailList.Items[DetailIndex],
    MasterList.Items[MasterIndex]);
  with OrderedDetailList do
    Objects[IndexOf(DetailList.Items[DetailIndex])] := TObject(True);
  DetailList.Items.Delete(DetailIndex);
  MasterList.Items.Delete(MasterIndex);
  btnClear.Enabled := True;
  btnAdd.Enabled := False;
end;

procedure TRMDFieldsLinkForm.btnClearClick(Sender: TObject);
var
  I: Integer;
  BindValue: string;
begin
  for I := 0 to BindList.Items.Count - 1 do
  begin
    BindValue := BindList.Items[I];
    DetailList.Items.Add(StripDetail(BindValue));
    MasterList.Items.Add(StripMaster(BindValue));
  end;
  BindList.Clear;
  btnClear.Enabled := False;
  btnDelete.Enabled := False;
  OrderFieldList(OrderedDetailList, DetailList.Items);
  DetailList.ItemIndex := -1;
  MasterList.Items.Assign(OrderedMasterList);
  for I := 0 to OrderedDetailList.Count - 1 do
    OrderedDetailList.Objects[I] := TObject(False);
  btnAdd.Enabled := False;
end;

procedure TRMDFieldsLinkForm.btnDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  with BindList do
  begin
    for I := Items.Count - 1 downto 0 do
    begin
      if Selected[I] then
      begin
        DetailList.Items.Add(StripDetail(Items[I]));
        MasterList.Items.Add(StripMaster(Items[I]));
        with OrderedDetailList do
          Objects[IndexOf(StripDetail(Items[I]))] := TObject(False);
        Items.Delete(I);
      end;
    end;
    if Items.Count > 0 then Selected[0] := True;
    btnDelete.Enabled := Items.Count > 0;
    btnClear.Enabled := Items.Count > 0;
    OrderFieldList(OrderedDetailList, DetailList.Items);
    DetailList.ItemIndex := -1;
    OrderFieldList(OrderedMasterList, MasterList.Items);
    MasterList.ItemIndex := -1;
    btnAdd.Enabled := False;
  end;
end;

procedure TRMDFieldsLinkForm.BindListClick(Sender: TObject);
begin
  btnDelete.Enabled := BindList.ItemIndex <> LB_ERR;
end;

procedure TRMDFieldsLinkForm.btnOKClick(Sender: TObject);
var
  Gap: Boolean;
  I: Integer;
  FirstIndex: Integer;
begin
  FirstIndex := -1;
  MasterFieldList := '';
  IndexFieldList := '';
  FFullIndexName := '';
  if DataSetProxy.IndexBased then
  begin
    Gap := False;
    for I := 0 to OrderedDetailList.Count - 1 do
    begin
      if Boolean(OrderedDetailList.Objects[I]) then
      begin
        if Gap then
        begin
          MessageDlg(Format(SLinkDesigner,
            [OrderedDetailList[FirstIndex]]), mtError, [mbOK], 0);
          ModalResult := 0;
          DetailList.ItemIndex := DetailList.Items.IndexOf(OrderedDetailList[FirstIndex]);
          Exit;
        end;
      end
      else begin
        Gap := True;
        if FirstIndex = -1 then FirstIndex := I;
      end;
    end;
    if not Gap then FFullIndexName := DataSetProxy.IndexName;
  end;

  with BindList do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      MasterFieldList := Format('%s%s;', [MasterFieldList, StripMaster(Items[I])]);
      IndexFieldList := Format('%s%s;', [IndexFieldList, StripDetail(Items[I])]);
    end;
    if MasterFieldList <> '' then
      SetLength(MasterFieldList, Length(MasterFieldList) - 1);
    if IndexFieldList <> '' then
      SetLength(IndexFieldList, Length(IndexFieldList) - 1);
  end;
end;

end.

