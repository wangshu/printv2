unit RM_EditorFieldAlias;

interface

{$I RM.INC}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, RM_DataSet, RM_Utils, RM_Const
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMEditorFieldAlias = class(TForm)
    ListView1: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    btnReset: TButton;
    Label2: TLabel;
    edtDataSetAlias: TEdit;
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  private
    { Private declarations }
    FDataSet: TRMDataSet;
    procedure Localize;
  public
    { Public declarations }
    function Edit(aDataSet: TRMDataSet): Boolean;
  end;

implementation

{$R *.dfm}

function TRMEditorFieldAlias.Edit(aDataSet: TRMDataSet): Boolean;
var
  i, lIndex: Integer;
  lStrList: TStringList;
  lStr: string;
  lEmptyFlag: Boolean;
begin
  Result := False;

  FDataSet := aDataSet;
  lStrList := TStringList.Create;
  try
    aDataSet.GetFieldsList(lStrList);
    for i := 0 to lStrList.Count - 1 do
    begin
      lIndex := aDataSet.FieldAlias.IndexOfName(lStrList[i]);
      if lIndex >= 0 then
{$IFDEF COMPILER7_UP}
        lStrList[i] := lStrList[i] + '=' + aDataSet.FieldAlias.ValueFromIndex[lIndex]
{$ELSE}
        lStrList[i] := lStrList[i] + '=' + aDataSet.FieldAlias.Values[lStrList[i]]
{$ENDIF}
      else if aDataSet.FieldAlias.Count > 0 then
      begin
				lStrList[i] := lStrList[i] + '=';
      end
      else
      begin
        lStr := aDataSet.GetFieldDisplayLabel(lStrList[i]);
        if lStr <> '' then
          lStrList[i] := lStrList[i] + '=' + lStr
        else
          lStrList[i] := lStrList[i] + '=' + lStrList[i];
      end;
    end;

    ListView1.Items.Clear;
    for i := 0 to lStrList.Count - 1 do
    begin
      with ListView1.Items.Add do
      begin
{$IFDEF COMPILER7_UP}
        Caption := lStrList.ValueFromIndex[i];
{$ELSE}
        Caption := lStrList.Values[lStrList.Names[i]];
{$ENDIF}
        SubItems.Add(lStrList.Names[i]);
      end;
    end;

    if ListView1.Items.Count > 0 then
      ListView1.Selected := ListView1.Items[0];

    edtDataSetAlias.Text := aDataSet.AliasName;
    if ShowModal = mrOK then
    begin
      Result := True;
      lStrList.Clear;
      lEmptyFlag := True;
      for i := 0 to ListView1.Items.Count - 1 do
      begin
				if ListView1.Items[i].SubItems[0] <> ListView1.Items[i].Caption then
        	lEmptyFlag := False;

        lStrList.Add(Trim(ListView1.Items[i].SubItems[0]) + '=' + ListView1.Items[i].Caption);
      end;

      aDataSet.AliasName := edtDataSetAlias.Text;
      if lEmptyFlag then
      	aDataSet.FieldAlias.Clear
      else
	      aDataSet.FieldAlias.Assign(lStrList);
    end;
  finally
    lStrList.Free;
  end;
end;

procedure TRMEditorFieldAlias.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 926);
  RMSetStrProp(ListView1.Columns[0], 'Caption', rmRes + 924);
  RMSetStrProp(ListView1.Columns[1], 'Caption', rmRes + 925);
  RMSetStrProp(Label2, 'Caption', rmRes + 927);
  RMSetStrProp(btnReset, 'Caption', rmRes + 928);

  btnOk.Caption := RMLoadStr(SOK);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMEditorFieldAlias.ListView1KeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key = #13) and (ListView1.Selected <> nil) then
    ListView1.Selected.EditCaption;
end;

procedure TRMEditorFieldAlias.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TRMEditorFieldAlias.btnResetClick(Sender: TObject);
var
  i: Integer;
  lStrList: TStringList;
  lStr: string;
begin
  lStrList := TStringList.Create;
  try
    FDataSet.GetFieldsList(lStrList);
    for i := 0 to lStrList.Count - 1 do
    begin
      lStr := FDataSet.GetFieldDisplayLabel(lStrList[i]);
      if lStr <> '' then
        lStrList[i] := lStrList[i] + '=' + lStr
      else
        lStrList[i] := lStrList[i] + '=' + lStrList[i];
    end;

    ListView1.Items.Clear;
    for i := 0 to lStrList.Count - 1 do
    begin
      with ListView1.Items.Add do
      begin
{$IFDEF COMPILER7_UP}
        Caption := lStrList.ValueFromIndex[i];
{$ELSE}
        Caption := lStrList.Values[lStrList.Names[i]];
{$ENDIF}
        SubItems.Add(lStrList.Names[i]);
      end;
    end;
  finally
    lStrList.Free;
  end;
end;

end.

