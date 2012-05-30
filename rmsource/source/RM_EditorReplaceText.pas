unit RM_EditorReplaceText;

{$I RM.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TRMTextReplaceDialog = class(TForm)
    Label1: TLabel;
    cbSearchText: TComboBox;
    rgSearchDirection: TRadioGroup;
    gbSearchOptions: TGroupBox;
    cbSearchCaseSensitive: TCheckBox;
    cbSearchWholeWords: TCheckBox;
    cbSearchFromCursor: TCheckBox;
    cbSearchSelectedOnly: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    cbRegularExpression: TCheckBox;
    cbReplaceText: TComboBox;
    Label3: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    function GetSearchBackwards: boolean;
    function GetSearchCaseSensitive: boolean;
    function GetSearchFromCursor: boolean;
    function GetSearchInSelection: boolean;
    function GetSearchText: string;
    function GetSearchTextHistory: string;
    function GetSearchWholeWords: boolean;
    procedure SetSearchBackwards(Value: boolean);
    procedure SetSearchCaseSensitive(Value: boolean);
    procedure SetSearchFromCursor(Value: boolean);
    procedure SetSearchInSelection(Value: boolean);
    procedure SetSearchText(Value: string);
    procedure SetSearchTextHistory(Value: string);
    procedure SetSearchWholeWords(Value: boolean);
    procedure SetSearchRegularExpression(const Value: boolean);
    function GetSearchRegularExpression: boolean;
    function GetReplaceText: string;
    function GetReplaceTextHistory: string;
    procedure SetReplaceText(Value: string);
    procedure SetReplaceTextHistory(Value: string);
  public
    property SearchBackwards: boolean read GetSearchBackwards
      write SetSearchBackwards;
    property SearchCaseSensitive: boolean read GetSearchCaseSensitive
      write SetSearchCaseSensitive;
    property SearchFromCursor: boolean read GetSearchFromCursor
      write SetSearchFromCursor;
    property SearchInSelectionOnly: boolean read GetSearchInSelection
      write SetSearchInSelection;
    property SearchText: string read GetSearchText write SetSearchText;
    property SearchTextHistory: string read GetSearchTextHistory
      write SetSearchTextHistory;
    property SearchWholeWords: boolean read GetSearchWholeWords
      write SetSearchWholeWords;
    property SearchRegularExpression: boolean read GetSearchRegularExpression
      write SetSearchRegularExpression;
    property ReplaceText: string read GetReplaceText write SetReplaceText;
    property ReplaceTextHistory: string read GetReplaceTextHistory
      write SetReplaceTextHistory;
  end;

implementation

{$R *.DFM}

{ TTextSearchDialog }

function TRMTextReplaceDialog.GetSearchBackwards: boolean;
begin
  Result := rgSearchDirection.ItemIndex = 1;
end;

function TRMTextReplaceDialog.GetSearchCaseSensitive: boolean;
begin
  Result := cbSearchCaseSensitive.Checked;
end;

function TRMTextReplaceDialog.GetSearchFromCursor: boolean;
begin
  Result := cbSearchFromCursor.Checked;
end;

function TRMTextReplaceDialog.GetSearchInSelection: boolean;
begin
  Result := cbSearchSelectedOnly.Checked;
end;

function TRMTextReplaceDialog.GetSearchRegularExpression: boolean;
begin
  Result := cbRegularExpression.Checked;
end;

function TRMTextReplaceDialog.GetSearchText: string;
begin
  Result := cbSearchText.Text;
end;

function TRMTextReplaceDialog.GetSearchTextHistory: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to cbSearchText.Items.Count - 1 do begin
    if i >= 10 then
      break;
    if i > 0 then
      Result := Result + #13#10;
    Result := Result + cbSearchText.Items[i];
  end;
end;

function TRMTextReplaceDialog.GetSearchWholeWords: boolean;
begin
  Result := cbSearchWholeWords.Checked;
end;

procedure TRMTextReplaceDialog.SetSearchBackwards(Value: boolean);
begin
  rgSearchDirection.ItemIndex := Ord(Value);
end;

procedure TRMTextReplaceDialog.SetSearchCaseSensitive(Value: boolean);
begin
  cbSearchCaseSensitive.Checked := Value;
end;

procedure TRMTextReplaceDialog.SetSearchFromCursor(Value: boolean);
begin
  cbSearchFromCursor.Checked := Value;
end;

procedure TRMTextReplaceDialog.SetSearchInSelection(Value: boolean);
begin
  cbSearchSelectedOnly.Checked := Value;
end;

procedure TRMTextReplaceDialog.SetSearchText(Value: string);
begin
  cbSearchText.Text := Value;
end;

procedure TRMTextReplaceDialog.SetSearchTextHistory(Value: string);
begin
  cbSearchText.Items.Text := Value;
end;

procedure TRMTextReplaceDialog.SetSearchWholeWords(Value: boolean);
begin
  cbSearchWholeWords.Checked := Value;
end;

procedure TRMTextReplaceDialog.SetSearchRegularExpression(
  const Value: boolean);
begin
  cbRegularExpression.Checked := Value;
end;

function TRMTextReplaceDialog.GetReplaceText: string;
begin
  Result := cbReplaceText.Text;
end;

function TRMTextReplaceDialog.GetReplaceTextHistory: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to cbReplaceText.Items.Count - 1 do begin
    if i >= 10 then
      break;
    if i > 0 then
      Result := Result + #13#10;
    Result := Result + cbReplaceText.Items[i];
  end;
end;

procedure TRMTextReplaceDialog.SetReplaceText(Value: string);
begin
  cbReplaceText.Text := Value;
end;

procedure TRMTextReplaceDialog.SetReplaceTextHistory(Value: string);
begin
  cbReplaceText.Items.Text := Value;
end;

{ event handlers }

procedure TRMTextReplaceDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  s: string;
  i: integer;
begin
  if ModalResult = mrOK then begin
    s := cbSearchText.Text;
    if s <> '' then begin
      i := cbSearchText.Items.IndexOf(s);
      if i > -1 then begin
        cbSearchText.Items.Delete(i);
        cbSearchText.Items.Insert(0, s);
        cbSearchText.Text := s;
      end else
        cbSearchText.Items.Insert(0, s);
    end;
  end;
end;

end.

 