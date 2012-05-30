unit RM_EditorFindReplace;

interface

{$I RM.INC}
uses
  Windows, Forms, Buttons, Graphics, SysUtils, Dialogs, ComCtrls, RM_Class, RM_Designer,
  StdCtrls, Controls, Classes, Menus;

type
//  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);
  TSearchFunction = function(const AText, ASubText: string): Boolean;
  TReplaceFunction = function(const AText, AFromText, AToText: string): string;

 {TRMFindReplaceForm}
  TRMFindReplaceForm = class(TForm)
    chkCase: TCheckBox;
    cmbReplace: TComboBox;
    cmbSearch: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    chkMemo: TCheckBox;
    btnSearch: TBitBtn;
    btnStop: TBitBtn;
    btnReplace: TBitBtn;
    btnReplaceAll: TBitBtn;
    btnClose: TBitBtn;
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    Search1: TMenuItem;
    Stop1: TMenuItem;
    N1: TMenuItem;
    Replace1: TMenuItem;
    ReplaceAll1: TMenuItem;
    N2: TMenuItem;
    ClearResults1: TMenuItem;
    procedure btnStopClick(Sender: TObject);
    procedure chkCaseClick(Sender: TObject);
    procedure ClearResults1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnReplaceAllClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
    FDesigner: TRMDesignerForm;
    FSearcher: TSearchFunction;
    FReplacer: TReplaceFunction;
    FModified: Boolean;
    FOnModifyView: TNotifyEvent;
    FStopFlag: Boolean;

    procedure SetModified(AView: TRMView);
    procedure UpdateCombos;
    procedure Localize;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function Comparator(t: TRMView): Boolean;

    property OnModifyView: TNotifyEvent read FOnModifyView write FOnModifyView;
  end;

implementation

{$R *.dfm}

uses RM_Utils, RM_Const, RM_Const1;

function AnsiContainsText(const AText, ASubText: string): Boolean;
begin
  Result := AnsiPos(AnsiUppercase(ASubText), AnsiUppercase(AText)) > 0;
end;

function AnsiReplaceText(const AText, AFromText, AToText: string): string;
begin
  Result := StringReplace(AText, AFromText, AToText, [rfReplaceAll, rfIgnoreCase]);
end;

function AnsiContainsStr(const AText, ASubText: string): Boolean;
begin
  Result := AnsiPos(ASubText, AText) > 0;
end;

function AnsiReplaceStr(const AText, AFromText, AToText: string): string;
begin
  Result := StringReplace(AText, AFromText, AToText, [rfReplaceAll]);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMFindReplaceForm }

procedure TRMFindReplaceForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 823);
  RMSetStrProp(Label1, 'Caption', rmRes + 821);
  RMSetStrProp(Label2, 'Caption', rmRes + 822);
  RMSetStrProp(chkCase, 'Caption', rmRes + 824);
//  RMSetStrProp(chkScript, 'Caption', rmRes + 825);
  RMSetStrProp(chkMemo, 'Caption', rmRes + 826);
  RMSetStrProp(btnSearch, 'Caption', rmRes + 827);
  RMSetStrProp(btnReplace, 'Caption', rmRes + 828);
  RMSetStrProp(btnStop, 'Caption', rmRes + 829);
  RMSetStrProp(btnReplaceAll, 'Caption', rmRes + 830);
  RMSetStrProp(btnClose, 'Caption', rmRes + 831);
  RMSetStrProp(ListView1.Columns[0], 'Caption', rmRes + 832);
  RMSetStrProp(ListView1.Columns[1], 'Caption', rmRes + 834);
//  RMSetStrProp(ListView1.Columns[2], 'Caption', rmRes + 835);
end;

constructor TRMFindReplaceForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDesigner := TRMDesignerForm(AOwner);
  FSearcher := AnsiContainsText;
  FReplacer := AnsiReplaceText;
  FModified := False;
  Localize;
end;

procedure TRMFindReplaceForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := TWinControl(Owner).Handle;
end;

procedure TRMFindReplaceForm.chkCaseClick(Sender: TObject);
begin
  if chkCase.Checked then
  begin
    FSearcher := AnsiContainsText;
    FReplacer := AnsiReplaceText;
  end
  else
  begin
    FSearcher := AnsiContainsStr;
    FReplacer := AnsiReplaceStr;
  end;
end;

procedure TRMFindReplaceForm.UpdateCombos;
begin
  if Trim(cmbSearch.Text) <> '' then
  begin
    if cmbSearch.Items.IndexOf(cmbSearch.Text) = -1 then
      cmbSearch.Items.Insert(0, cmbSearch.Text);
  end;

  if Trim(cmbReplace.Text) <> '' then
  begin
    if cmbReplace.Items.IndexOf(cmbReplace.Text) = -1 then
      cmbReplace.Items.Insert(0, cmbReplace.Text);
  end;
end;

function TRMFindReplaceForm.Comparator(t: TRMView): Boolean;
begin
  Result := (chkMemo.Checked and FSearcher(t.Memo.Text, cmbSearch.Text));
end;

procedure TRMFindReplaceForm.btnStopClick(Sender: TObject);
begin
  FStopFlag := True;
  btnSearch.Enabled := True;
  btnStop.Enabled := False;
  btnReplace.Enabled := (ListView1.Items.Count > 0);
  Search1.Enabled := True;
  Stop1.Enabled := False;
  Replace1.Enabled := (ListView1.Items.Count > 0);
  ClearResults1.Enabled := (ListView1.Items.Count > 0);

  if FModified then
  begin
    FModified := False;
    FDesigner.Modified := True;
    FDesigner.RedrawPage;
  end;
end;

procedure TRMFindReplaceForm.SetModified(AView: TRMView);
begin
  FDesigner.Modified := True;
  FModified := True;
end;

procedure TRMFindReplaceForm.ListView1DblClick(Sender: TObject);
var
  t: TRMView;
  ListItem: TListItem;
  i: Integer;
begin
  if ListView1.Items.Count > 0 then
  begin
    t := nil;
    ListItem := ListView1.ItemFocused;
    for i := 0 to FDesigner.Objects.Count do
    begin
      if AnsiCompareText(TRMView(FDesigner.Objects[i]).Name, ListItem.Caption) = 0 then
      begin
        t := TRMView(FDesigner.Objects[i]);
        Break;
      end;
    end;

    if t <> nil then
    begin
      SetModified(t);
      FDesigner.RMMemoViewEditor(t);
    end;
  end;
end;

procedure TRMFindReplaceForm.ClearResults1Click(Sender: TObject);
begin
  ListView1.Items.Clear;
end;

procedure TRMFindReplaceForm.btnReplaceClick(Sender: TObject);
var
  ListItem: TListItem;
  t: TRMView;
  i, rc: Integer;
  nonStop: Boolean;
  str: string;
begin
  if ListView1.SelCount = 0 then
  begin
    ShowMessage(RMLoadStr(rmRes + 836));
    exit;
  end;

  FModified := False;
  nonStop := False;
  rc := 0;

  UpdateCombos;
  ListItem := ListView1.Selected;
  repeat
    t := nil;
    for i := 0 to FDesigner.Objects.Count do
    begin
      if AnsiCompareText(TRMView(FDesigner.Objects[i]).Name, ListItem.Caption) = 0 then
      begin
        t := TRMView(FDesigner.Objects[i]);
        break;
      end;
    end;

    if t = nil then
      continue;

    if not nonStop then
    begin
      str := Format(RMLoadStr(rmRes + 838), [#10#13, cmbSearch.Text, #10#13, #10#13, cmbReplace.Text]);
      rc := MessageDlg(str, mtConfirmation, [mbYes, mbNo, mbCancel, mbAll], 0);
    end;
    case rc of
      mrYes:
        begin
          if chkMemo.Checked then
          begin
            t.Memo.Text := FReplacer(t.Memo.Text, cmbSearch.Text, cmbReplace.Text);
            SetModified(t);
          end;
        end; // mrYes
      mrAll:
        begin
          nonStop := True;
          rc := mrYes;
        end; // mrAll
      mrCancel: break;
    end; // case

    ListItem := ListView1.GetNextItem(ListItem, sdAll, [isSelected]);
  until ListItem = nil;

  if FModified then
  begin
    FModified := False;
    FDesigner.Modified := True;
    FDesigner.RedrawPage;
  end;
end;

procedure TRMFindReplaceForm.btnReplaceAllClick(Sender: TObject);
var
  str: string;

  procedure _ReplaceAll;
  var
    i: Integer;
    t: TRMView;
    liItem: TListItem;
  begin
    i := 0;
    while (not FStopFlag) and (i < FDesigner.Objects.Count) do
    begin
      t := TRMView(FDesigner.Objects[i]);
      if Comparator(t) then
      begin
        liItem := ListView1.Items.Add;
        liItem.Caption := t.Name;
        liItem.SubItems.Add(t.Memo.Text);
        if chkMemo.Checked then
        begin
          t.Memo.Text := FReplacer(t.Memo.Text, cmbSearch.Text, cmbReplace.Text);
          SetModified(t);
        end;
      end;
      Inc(i);
      Application.ProcessMessages;
    end;

    if not FStopFlag then
      btnStop.Click;
  end;

begin
  str := Format(RMLoadStr(rmRes + 837), [#10#13, cmbSearch.Text, #10#13, #10#13, cmbReplace.Text]);
  if Application.MessageBox(PChar(str),
    PChar(RMLoadStr(SConfirm)), mb_IconQuestion + mb_YesNo) = IDYES then
  begin
    UpdateCombos;
    FStopFlag := False;
    btnSearch.Enabled := False;
    btnStop.Enabled := True;

    Search1.Enabled := False;
    Stop1.Enabled := True;

    ListView1.Items.Clear;
    _ReplaceAll;
  end;
end;

procedure TRMFindReplaceForm.btnCloseClick(Sender: TObject);
begin
  FStopFlag := True;
  ListView1.Items.Clear;
  Close;
end;

procedure TRMFindReplaceForm.btnSearchClick(Sender: TObject);

  procedure _SearchObjects;
  var
    i: Integer;
    liItem: TListItem;
    t: TRMView;
  begin
    i := 0;
    while (not FStopFlag) and (i < FDesigner.Objects.Count) do
    begin
      t := FDesigner.Objects[i];
      if Comparator(t) then
      begin
        liItem := ListView1.Items.Add;
        liItem.Caption := TRMView(t).Name;
        liItem.SubItems.Add(TRMView(t).Memo.Text);
      end;
      Inc(i);
      Application.ProcessMessages;
    end;

    if not FStopFlag then
      btnStop.Click;
  end;

begin
  UpdateCombos;

  FStopFlag := False;
  btnSearch.Enabled := False;
  btnStop.Enabled := True;

  Search1.Enabled := False;
  Stop1.Enabled := True;

  ListView1.Items.Clear;
  _SearchObjects;
end;

procedure TRMFindReplaceForm.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  t: TRMView;
  i: Integer;
begin
  if (Item = nil) or (Item.SubItems.Count <= 0) then Exit;
  for i := 0 to FDesigner.Objects.Count - 1 do
  begin
    if AnsiCompareText(TRMView(FDesigner.Objects[i]).Name, Item.Caption) = 0 then
    begin
      t := TRMView(FDesigner.Objects[i]);
      if Assigned(FOnModifyView) then
        FOnModifyView(t);
      Break;
    end;
  end;
end;

end.

