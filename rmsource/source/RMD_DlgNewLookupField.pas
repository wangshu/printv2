
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{        Lookup field definition          }
{                                         }
{*****************************************}

unit RMD_DlgNewLookupField;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB;

type
  TRMDLookupFieldForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    cmbType: TComboBox;
    edtSize: TEdit;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cmbKey: TComboBox;
    cmbLookupDataSet: TComboBox;
    cmbLookupKey: TComboBox;
    cmbLookupField: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure cmbLookupDataSetChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FLookup: TDataset;
    FFlagModify: Boolean;
    FField: TField;
    procedure Localize;
  public
    { Public declarations }
    Dataset: TDataset;
    procedure ModifyLookupField(aField: TField);
  end;

implementation

uses RMD_DBWrap, RM_Const, RM_Utils;

{$R *.DFM}

procedure TRMDLookupFieldForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 3070);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 3071);
  RMSetStrProp(Label1, 'Caption', rmRes + 3072);
  RMSetStrProp(Label2, 'Caption', rmRes + 3073);
  RMSetStrProp(Label3, 'Caption', rmRes + 3074);
  RMSetStrProp(GroupBox2, 'Caption', rmRes + 3075);
  RMSetStrProp(Label4, 'Caption', rmRes + 3076);
  RMSetStrProp(Label5, 'Caption', rmRes + 3077);
  RMSetStrProp(Label6, 'Caption', rmRes + 3078);
  RMSetStrProp(Label7, 'Caption', rmRes + 3079);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDLookupFieldForm.ModifyLookupField(aField: TField);
var
	i: Integer;
begin
	FField := aField;
  FFlagModify := True;
	edtName.Text := aField.FieldName;
	for i := Low(RMFieldClasses) to High(RMFieldClasses) do
  begin
		if AnsiCompareText(aField.ClassName, RMFieldClasses[i].ClassName) = 0 then
    begin
    	cmbType.ItemIndex := i; Break;
    end;
  end;
  edtSize.Text := IntToStr(aField.Size);

	if aField.LookupDataSet <> nil then
	  cmbLookupDataSet.Text := aField.LookupDataSet.Name
  else
  	cmbLookupDataSet.Text := '';
  cmbLookupDataSetChange(nil);

  cmbKey.Text := aField.KeyFields;
  cmbLookupKey.Text := aField.LookupKeyFields;
  cmbLookupField.Text := aField.LookupResultField;
	ShowModal;
end;

procedure TRMDLookupFieldForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to 9 do
    cmbType.Items.Add(RMLoadStr(SFieldType1 + i));
  cmbType.ItemIndex := 0;
  Dataset.GetFieldNames(cmbKey.Items);
  RMGetComponents(DataSet.Owner, TDataSet, cmbLookupDataSet.Items, DataSet);
end;

procedure TRMDLookupFieldForm.cmbLookupDataSetChange(Sender: TObject);
begin
  FLookup := RMFindComponent(DataSet.Owner, cmbLookupDataSet.Text) as TDataset;
  cmbLookupKey.Items.Clear;
  cmbLookupField.Items.Clear;
  if FLookup <> nil then
  begin
    FLookup.GetFieldNames(cmbLookupKey.Items);
    cmbLookupField.Items.Assign(cmbLookupKey.Items);
  end;
  cmbLookupKey.Text := '';
  cmbLookupKey.Text := '';
end;

procedure TRMDLookupFieldForm.FormClose(Sender: TObject;  var Action: TCloseAction);
var
  Field: TField;
begin
  if ModalResult = mrOK then
  begin
		if FFlagModify then
    	Field := FField
    else
	    Field := RMFieldClasses[cmbType.ItemIndex].Create(Dataset);
    with Field do
    begin
      if Field is TStringField then
      try
        Size := StrToInt(edtSize.Text);
      except
        ModalResult := mrNone;
        MessageBox(0, PChar(RMLoadStr(SFieldSizeError)), PChar(RMLoadStr(SError)),
          mb_Ok + mb_IconError);
        edtSize.Text := '';
        ActiveControl := edtSize;
        Exit;
      end;
      Lookup := True;
      LookupDataset := FLookup;
      KeyFields := cmbKey.Text;
      LookupKeyFields := cmbLookupKey.Text;
      LookupResultField := cmbLookupField.Text;
      FieldName := edtName.Text;
      Dataset := Self.Dataset;
    end;
  end;
end;

procedure TRMDLookupFieldForm.FormCreate(Sender: TObject);
begin
	Localize;
	FFlagModify := False;
end;

end.

