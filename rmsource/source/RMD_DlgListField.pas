
{*****************************************}
{                                         }
{ Report Machine v2.0 - Data storage      }
{         Available fields list           }
{                                         }
{*****************************************}

unit RMD_DlgListField;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, RM_Const;

type
  TRMDFieldsListForm = class(TForm)
    lstFields: TListBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function FieldExists(FName: string): Boolean;
    procedure Localize;
  public
    { Public declarations }
    DataSet: TDataSet;
  end;

implementation

{$R *.DFM}

uses RMD_DBWrap, RM_Utils;

procedure TRMDFieldsListForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, Caption, rmRes + 3060);
  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

function TRMDFieldsListForm.FieldExists(FName: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  with DataSet do
  begin
    for i := 0 to FieldCount - 1 do
    begin
      if AnsiCompareText(Fields[i].FieldName, FName) = 0 then
      begin
        Result := True;
        break;
      end;
    end;
  end;
end;

procedure TRMDFieldsListForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  lstFields.Clear;
  with DataSet do
  begin
    FieldDefs.Update;
    for i := 0 to FieldDefs.Count - 1 do
    begin
      if not FieldExists(FieldDefs.Items[i].Name) then
        lstFields.Items.Add(FieldDefs.Items[i].Name);
    end;
  end;

  for i := 0 to lstFields.Items.Count - 1 do
    lstFields.Selected[i] := True;
end;

procedure TRMDFieldsListForm.FormClose(Sender: TObject;  var Action: TCloseAction);
var
  i: integer;
begin
  if ModalResult = mrOK then
  begin
    for i := 0 to lstFields.Items.Count - 1 do
    begin
      if lstFields.Selected[i] then
        RMFindFieldDef(DataSet, lstFields.Items[i]).CreateField(DataSet);
		end;
  end;
end;

procedure TRMDFieldsListForm.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.

