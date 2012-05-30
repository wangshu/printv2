
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{              Fields list                }
{                                         }
{*****************************************}

unit RMD_EditorField;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, RM_Const;

type
  TRMDFieldsEditorForm = class(TForm)
    lstFields: TListBox;
    btnAddFields: TButton;
    btnAddLookup: TButton;
    btnSelectAll: TButton;
    btnDelete: TButton;
    btnOK: TButton;
    btnModifyLookup: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnAddFieldsClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddLookupClick(Sender: TObject);
    procedure btnModifyLookupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure FillList;
    procedure Localize;
  public
    { Public declarations }
    DataSet: TDataSet;
  end;

implementation

uses RM_Utils, RMD_DlgListField, RMD_DlgNewLookupField;

{$R *.DFM}

procedure TRMDFieldsEditorForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(btnAddFields, 'Caption', rmRes + 3040);
  RMSetStrProp(btnAddLookup, 'Caption', rmRes + 3041);
  RMSetStrProp(btnSelectAll, 'Caption', rmRes + 3042);
  RMSetStrProp(btnDelete, 'Caption', rmRes + 3043);
  RMSetStrProp(btnModifyLookup, 'Caption', rmRes + 3045);

  btnOK.Caption := RMLoadStr(rmRes + 3044);
end;

procedure TRMDFieldsEditorForm.FillList;
var
  i: Integer;
begin
  lstFields.Items.Clear;
  with DataSet do
  for i := 0 to FieldCount - 1 do
    lstFields.Items.Add(Fields[i].FieldName);
end;

procedure TRMDFieldsEditorForm.FormShow(Sender: TObject);
begin
  Caption := DataSet.Name + ' ' + RMLoadStr(SFields);
  FillList;
end;

procedure TRMDFieldsEditorForm.btnAddFieldsClick(Sender: TObject);
var
  FieldsListForm: TRMDFieldsListForm;
begin
	try
    DataSet.FieldDefs.Update;
	  FieldsListForm := TRMDFieldsListForm.Create(nil);
  	with FieldsListForm do
	  begin
  	  DataSet := Self.DataSet;
    	if ShowModal = mrOk then
      	FillList;
	    Free;
  	end;
  finally
  end;
end;

procedure TRMDFieldsEditorForm.btnSelectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstFields.Items.Count - 1 do
    lstFields.Selected[i] := True;
end;

procedure TRMDFieldsEditorForm.btnDeleteClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lstFields.Items.Count - 1 do
    if lstFields.Selected[i] then
      DataSet.FindField(lstFields.Items[i]).Free;
  FillList;
end;

procedure TRMDFieldsEditorForm.btnAddLookupClick(Sender: TObject);
var
  LookupFieldForm: TRMDLookupFieldForm;
begin
  LookupFieldForm := TRMDLookupFieldForm.Create(nil);
  with LookupFieldForm do
  begin
    Dataset := Self.Dataset;
    if ShowModal = mrOk then
      FillList;
    Free;
  end;
end;

procedure TRMDFieldsEditorForm.btnModifyLookupClick(Sender: TObject);
var
  LookupFieldForm: TRMDLookupFieldForm;
begin
	if lstFields.SelCount <= 0 then Exit;
  LookupFieldForm := TRMDLookupFieldForm.Create(nil);
  with LookupFieldForm do
  begin
    Dataset := Self.Dataset;
    ModifyLookupField(Dataset.FieldByName(lstFields.Items[lstFields.ItemIndex]));
    Free;
  end;
end;

procedure TRMDFieldsEditorForm.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.

