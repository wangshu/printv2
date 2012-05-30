
{*****************************************}
{                                         }
{            Report Machine v2.0          }
{               Memo editor               }
{                                         }
{*****************************************}

unit RM_EditorMemo;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, RM_Class, ImgList, Dialogs,
  Clipbrd, ToolWin
{$IFDEF TntUnicode}, TntStdCtrls{$ENDIF};

type
  TRMEditorForm = class(TRMObjEditorForm)
    StatusBar: TStatusBar;
    ImageListFont: TImageList;
    FontDialog1: TFontDialog;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    btnInsExpr: TToolButton;
    btnInsDBField: TToolButton;
    btnInsFormat: TToolButton;
    ToolButton4: TToolButton;
    btnCut: TToolButton;
    btnCopy: TToolButton;
    btnPaste: TToolButton;
    BtnWordWrap: TToolButton;
    ToolButton9: TToolButton;
    btnOK: TToolButton;
    btnCancel: TToolButton;
    btnFont: TToolButton;
    btnBold: TToolButton;
    btnItalic: TToolButton;
    ToolButton15: TToolButton;
    btnUnderline: TToolButton;
    btnSpan: TToolButton;
    btnSup: TToolButton;
    btnSub: TToolButton;
    Panel1: TPanel;
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnInsDBFieldClick(Sender: TObject);
    procedure BtnWordWrapClick(Sender: TObject);
    procedure btnInsExprClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCutClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MemoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnBoldClick(Sender: TObject);
    procedure btnInsFormatClick(Sender: TObject);
  private
    FDBFieldOnly: Boolean;
    FView: TRMView;
    FRowStr, FColStr: string;
{$IFDEF TntUnicode}
    FMemo: TTntMemo;
{$ELSE}
    FMemo: TMemo;
{$ENDIF}

    procedure ShowStatusbar(Sender: TObject);
  public
    { Public declarations }
    procedure Localize;
    function ShowEditor(View: TRMView): TModalResult; override;
    function Execute: Boolean;
    property DBFieldOnly: Boolean read FDBFieldOnly write FDBFieldOnly;
    property Memo: {$IFDEF TntUnicode}TTntMemo{$ELSE}TMemo{$ENDIF} read FMemo;
  end;

implementation

{$R *.DFM}

uses
  Registry, RM_Const1, RM_Const, RM_Utils, RM_Common, RM_EditorFormat;

type
  THackMemoView = class(TRMCustomMemoView)
  end;

procedure TRMEditorForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 060);
  RMSetStrProp(btnInsExpr, 'Hint', rmRes + 061);
//  RMSetStrProp(btnInsExpr, 'Caption', rmRes + 701);
  RMSetStrProp(btnInsDBField, 'Hint', rmRes + 062);
//  RMSetStrProp(btnInsDBField, 'Caption', rmRes + 65);
  RMSetStrProp(btnCut, 'Hint', rmRes + 091);
  RMSetStrProp(btnCopy, 'Hint', rmRes + 092);
  RMSetStrProp(btnPaste, 'Hint', rmRes + 093);
  RMSetStrProp(BtnWordWrap, 'Hint', rmRes + 063);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);

  FRowStr := RMLoadStr(rmRes + 578);
  FColStr := RMLoadStr(rmRes + 579);
end;

function TRMEditorForm.Execute: Boolean;
begin
  Result := (ShowModal = mrOk);
end;

function TRMEditorForm.ShowEditor(View: TRMView): TModalResult;
var
  lIni: TRegIniFile;
  lNm: string;

  procedure _DeleteTags;
  var
    i: Integer;
    lStr: WideString;
  begin
    for i := 0 to FMemo.Lines.Count - 1 do
    begin
      lStr := FMemo.Lines[i];
      if (Length(lStr) > 0) and (lStr[1] = #1) then
      begin
        Delete(lStr, 1, 1);
        FMemo.Lines[i] := lStr;
      end;
    end;

    if (FMemo.Lines.Count > 1) and (FMemo.Lines[FMemo.Lines.Count - 1] = #1) then
      FMemo.Lines.Delete(FMemo.Lines.Count - 1);
  end;

  procedure _AssignMemo;
  var
    i: Integer;
  begin
    FMemo.Lines.Clear;
    for i := 0 to FView.Memo.Count - 1 do
      FMemo.Lines.Add(FView.Memo[i]);
  end;

begin
  lIni := TRegIniFile.Create(RMRegRootKey);
  try
    lNm := rsForm + RMDesigner.ClassName;
    FView := View;

    BtnWordWrap.Click;
    _AssignMemo;
    //FMemo.Lines.Assign(FView.Memo);
    FMemo.Font.Name := lIni.ReadString(lNm, 'TextFontName', 'Arial');
    FMemo.Font.Size := lIni.ReadInteger(lNm, 'TextFontSize', 10);

    FMemo.Font.Name := TRMMemoView(FView).Font.Name;
    FMemo.Font.Size := 10;
    FMemo.Font.Charset := TRMMemoView(View).Font.Charset;
    if TRMMemoView(FView).WordWrap then
    begin
      _DeleteTags;
    end;

    ToolBar2.Visible := False;
    if FView is TRMCustomMemoView then
    begin
      FDBFieldOnly := TRMCustomMemoView(FView).DBFieldOnly;
      ToolBar2.Visible := TRMCustomMemoView(FView).AllowHtmlTag;
    end;

    FMemo.ReadOnly := rmrtDontModify in FView.Restrictions;
    Result := ShowModal;
    if (Result = mrOk) and (FView.Memo.Text <> FMemo.Lines.Text) then
    begin
      RMDesigner.BeforeChange;
      FMemo.WordWrap := False;
      FView.Memo.Text := FMemo.Lines.Text;
      if FView is TRMCustomMemoView then
        TRMCustomMemoView(FView).DBFieldOnly := False;

      RMDesigner.AfterChange;
    end;
  finally
    lIni.Free;
  end;
end;

const
  VK_A = 65;
  VK_X = 88;
  VK_Y = 89;
  VK_W = 87;
  VK_Q = 81;

procedure TRMEditorForm.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Insert) and (Shift = []) then
    btnInsDBFieldClick(Self)
  else if (Key = VK_A) and (Shift = [ssCtrl]) then
  begin
    FMemo.SelectAll
  end
  else if (Key = vk_X) and (Shift = [ssCtrl]) then
  begin
    FMemo.CutToClipboard
  end
  else if (Shift = [ssCtrl]) and ((Key = VK_W) or (Key = VK_RETURN)) then
  begin
    Key := 0;
    btnOk.Click;
  end
  else if (Key = vk_Escape) or ((Key = VK_Q) and (Shift = [ssCtrl])) then
  begin
    Key := 0;
    btnCancel.Click;
  end;
end;

procedure TRMEditorForm.btnInsDBFieldClick(Sender: TObject);
var
  s: string;
begin
  if FView is TRMReportView then
    s := RMDesigner.InsertDBField(TRMReportView(FView))
  else
    s := RMDesigner.InsertDBField(nil);

  if s <> '' then
    FMemo.SelText := s;
  FMemo.SetFocus;
end;

procedure TRMEditorForm.BtnWordWrapClick(Sender: TObject);
begin
  FMemo.WordWrap := BtnWordWrap.Down;
end;

procedure TRMEditorForm.btnInsExprClick(Sender: TObject);
var
  s: string;
begin
  if FView is TRMReportView then
    s := RMDesigner.InsertExpression(TRMReportView(FView))
  else
    s := RMDesigner.InsertExpression(nil);

  if s <> '' then
  begin
    FDBFieldOnly := False;
    FMemo.SelText := s;
  end;
  FMemo.SetFocus;
end;

procedure TRMEditorForm.FormCreate(Sender: TObject);
var
  Ini: TRegIniFile;
  Nm: string;
begin
{$IFDEF TntUnicode}
  FMemo := TTntMemo.Create(Panel1);
{$ELSE}
  FMemo := TMemo.Create(Panel1);
{$ENDIF}
  with FMemo do
  begin
    Parent := Panel1;
    Align := alClient;
    ScrollBars := ssVertical;
    OnKeyDown := MemoKeyDown;
    OnKeyUp := MemoKeyUp;
    OnMouseUp := MemoMouseUp;
  end;

  Localize;
  Ini := TRegIniFile.Create(RMRegRootKey);
  try
    Nm := rsForm + Self.ClassName;
    btnWordWrap.Down := Ini.ReadBool(Nm, 'WordWrap', True);
  finally
    Ini.Free;
  end;
end;

procedure TRMEditorForm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TRMEditorForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRMEditorForm.btnCutClick(Sender: TObject);
begin
  FMemo.CutToClipboard;
end;

procedure TRMEditorForm.btnCopyClick(Sender: TObject);
begin
  FMemo.CopyToClipboard;
end;

procedure TRMEditorForm.btnPasteClick(Sender: TObject);
begin
  FMemo.PasteFromClipboard;
end;

procedure TRMEditorForm.FormShow(Sender: TObject);
begin
  if FView is TRMCustomMemoView then
    FontDialog1.Font.Assign(TRMCustomMemoView(FView).Font);

  FMemo.SetFocus;
  ShowStatusbar(FMemo);
end;

procedure TRMEditorForm.FormDestroy(Sender: TObject);
var
  Ini: TRegIniFile;
  Nm: string;
begin
  Ini := TRegIniFile.Create(RMRegRootKey);
  try
    Nm := rsForm + Self.ClassName;
    Ini.WriteBool(Nm, 'WordWrap', BtnWordWrap.Down);
  finally
    Ini.Free;
  end;
end;

procedure TRMEditorForm.ShowStatusbar(Sender: TObject);
var
  Hang, Lie, Num, CharsLine: longint;
begin
  Num := SendMessage(TMemo(Sender).Handle, EM_LINEFROMCHAR,
    TMemo(Sender).SelStart, 0);
  CharsLine := SendMessage(TMemo(Sender).Handle, EM_LINEINDEX, Num, 0);
  Hang := Num + 1; //当前行
  Lie := (TMemo(Sender).SelStart - CharsLine) + 1; //当前列
  StatusBar.Panels[0].Text := FRowStr + IntToStr(Hang) + FColStr + IntToStr(Lie);
end;

procedure TRMEditorForm.MemoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ShowStatusbar(FMemo);
end;

procedure TRMEditorForm.MemoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowStatusbar(FMemo);
end;

procedure TRMEditorForm.btnBoldClick(Sender: TObject);
var
  lBuffer, lStr: string;
  lColor: string;
begin
  lStr := '';
{$IFDEF TntUnicode}
	FMemo.CopyToClipboard;
	lBuffer := Clipbrd.Clipboard.AsText;
{$ELSE}
  lBuffer := FMemo.SelText;
{$ENDIF}
  if Sender = btnFont then
  begin
    if FontDialog1.Execute then
    begin
      lColor := ColorToString(FontDialog1.Font.Color);
      if Copy(lColor, 1, 2) = 'cl' then
        lColor := Copy(lColor, 3, Length(lColor) - 2);

      lStr := '<font face="' + FontDialog1.Font.Name +
        '" size="' + IntToStr(FontDialog1.Font.size) +
        '" charset="' + IntToStr(FontDialog1.Font.Charset) +
        '" color="' + lColor + '">' +
        lBuffer + '</font>';
    end;
  end
  else if Sender = btnBold then
    lStr := '<b>' + lBuffer + '</b>'
  else if Sender = btnItalic then
    lStr := '<i>' + lBuffer + '</i>'
  else if Sender = btnSup then
    lStr := '<sup>' + lBuffer + '</sup>'
  else if Sender = btnSub then
    lStr := '<sub>' + lBuffer + '</sub>'
  else if Sender = btnSpan then
    lStr := '<strike>' + lBuffer + '</strike>'
  else if Sender = btnUnderline then
    lStr := '<u>' + lBuffer + '</u>';

  if lStr <> '' then
  begin
    FMemo.SelText := lStr;
    FMemo.SetFocus;
  end;
end;

procedure TRMEditorForm.btnInsFormatClick(Sender: TObject);
var
  tmp: TRMDisplayFormatForm;
  lStr: string;
  lStartPos: Integer;
begin
  tmp := TRMDisplayFormatForm.Create(nil);
  try
    lStr := tmp.Execute;
    if lStr <> '' then
    begin
      lStartPos := FMemo.SelStart;
      if (lStartPos > 0) and (FMemo.Text[lStartPos] = ']') then
        FMemo.SelStart := FMemo.SelStart - 1;

      FMemo.SelText := ' #' + lStr;
      FMemo.SetFocus;
    end;
  finally
    tmp.Free;
  end;
end;

end.

