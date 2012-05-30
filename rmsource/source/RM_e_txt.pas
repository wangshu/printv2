
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{           Text export filter            }
{                                         }
{*****************************************}

unit RM_e_txt;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, Dialogs,
  StdCtrls, Controls, RM_Common, RM_Class;

type
  { TRMExportOneLine }
  TRMExportViewInfo = class(TObject)
  private
    FText: string;
    FView: TRMReportView;
  protected
  public
    constructor Create(aText: string; aObj: TObject);

    property Text: string read FText write FText;
    property View: TRMReportView read FView write FView;
  end;

  TRMExportOneLine = class(TObject)
  private
    FList: TList;
    function GetItem(Index: Integer): TRMExportViewInfo;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Clear;
    procedure Add(aText: string; aObj: TObject);

    property Items[Index: Integer]: TRMExportViewInfo read GetItem; default;
  end;

  { TRMExportLines }
  TRMExportLines = class(TObject)
  private
    FList: TList;
    FScaleY: Double;

    function GetItem(Index: Integer): TRMExportOneLine;
  protected
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Add(aText: string; aObj: TObject);

    property Items[Index: Integer]: TRMExportOneLine read GetItem; default;
  end;

  { TRMTextExport }
  TRMTextExport = class(TRMExportFilter)
  private
    FScaleX, FScaleY: Double;
    FKillEmptyLines: Boolean;
    FConvertToOEM: Boolean;
    FExportFrames: Boolean;
    FUsePseudographic: Boolean;
    FPageBreaks: Boolean;
    FCurReportView: TRMReportView;

    FLines: TRMExportLines;
  protected
    procedure InternalOnePage(aPage: TRMEndPage; aLines: TRMExportLines); virtual;
    procedure OnText(aDrawRect: TRect; x, y: Integer; const aText: string; View: TRMView); override;
    procedure OnExportPage(const aPage: TRMEndPage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ShowModal: Word; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
  published
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
    property KillEmptyLines: Boolean read FKillEmptyLines write FKillEmptyLines default True;
    property ConvertToOEM: Boolean read FConvertToOEM write FConvertToOEM default False;
    property ExportFrames: Boolean read FExportFrames write FExportFrames default False;
    property UsePseudographic: Boolean read FUsePseudographic write FUsePseudographic default False;
    property PageBreaks: Boolean read FPageBreaks write FPageBreaks default True;
  end;

  { TRMTXTExportForm }
  TRMTXTExportForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB4: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    CB5: TCheckBox;
    CB3: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    procedure CB3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses RM_Utils, RM_Const;

{$R *.DFM}

type
  THackRMView = class(TRMReportView)
  end;

  THackMemoView = class(TRMCustomMemoView)
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TRMExportViewInfo }

constructor TRMExportViewInfo.Create(aText: string; aObj: TObject);
begin
  inherited Create;

  FText := aText;
  FView := TRMReportView(aObj);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMExportOneLine }

constructor TRMExportOneLine.Create;
begin
  inherited Create;

  FList := TList.Create;
end;

destructor TRMExportOneLine.Destroy;
begin
  Clear;
  FreeAndNil(FList);

  inherited Destroy;
end;

function TRMExportOneLine.Count: Integer;
begin
  Result := FList.Count;
end;

procedure TRMExportOneLine.Clear;
var
  i: Integer;
begin
  try
    for i := 0 to FList.Count - 1 do
      TRMExportViewInfo(FList[i]).Free;
  finally
    FList.Clear;
  end;
end;

procedure TRMExportOneLine.Add(aText: string; aObj: TObject);
var
  i: Integer;
begin
  if (FList.Count = 0) then
    FList.Add(TRMExportViewInfo.Create(aText, aObj))
  else
  begin
    i := FList.Count - 1;
    while i >= 0 do
    begin
      if TRMReportView(aObj).spLeft > TRMExportViewInfo(FList[i]).View.spLeft then
      begin
        Break;
      end;

      Dec(i)
    end;

    FList.Insert(i + 1, TRMExportViewInfo.Create(aText, aObj));
  end;
end;

function TRMExportOneLine.GetItem(Index: Integer): TRMExportViewInfo;
begin
  Result := FList[Index];
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMExportLines }

constructor TRMExportLines.Create;
begin
  inherited Create;

  FScaleY := 1;
  FList := TList.Create;
end;

destructor TRMExportLines.Destroy;
begin
  Clear;
  FreeAndNil(FList);

  inherited Destroy;
end;

function TRMExportLines.Count: Integer;
begin
  Result := FList.Count;
end;

procedure TRMExportLines.Clear;
var
  i: Integer;
begin
  try
    for i := 0 to FList.Count - 1 do
      TRMExportOneLine(FList[i]).Free;
  finally
    FList.Clear;
  end;
end;

procedure TRMExportLines.Add(aText: string; aObj: TObject);
var
  i, lRowNo, lCount: Integer;
begin
  lRowNo := Round(TRMReportView(aObj).spTop / FScaleY);
  lCount := lRowNo - FList.Count;
  for i := 0 to lCount do
    FList.Add(TRMExportOneLine.Create);

  TRMExportOneLine(FList[lRowNo]).Add(aText, aObj);
end;

function TRMExportLines.GetItem(Index: Integer): TRMExportOneLine;
begin
  Result := FList[Index];
end;

const
  Frames = '|-+++++++++';
  Pseudo = #179#196#218#191#192#217#193#195#194#180#197;
  PseudoHex = #5#10#6#12#3#9#11#7#14#13#15;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  {TRMTextExport}

constructor TRMTextExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if AnsiCompareText(ClassName, 'TRMTextExport') = 0 then
    RMRegisterExportFilter(Self, RMLoadStr(STextFile) + ' (*.txt)', '*.txt');

  CreateFile := True;
  ShowDialog := True;

  FScaleX := 1;
  FScaleY := 1;
  FKillEmptyLines := True;
  FConvertToOEM := False;
  FExportFrames := False;
  FUsePseudographic := False;
  FPageBreaks := True;

  FLines := TRMExportLines.Create;
end;

destructor TRMTextExport.Destroy;
begin
  RMUnRegisterExportFilter(Self);
  FreeAndNil(FLines);

  inherited Destroy;
end;

procedure TRMTextExport.OnBeginPage;
begin
  inherited;

  FLines.Clear;
  FLines.FScaleY := 14 / ScaleY;
end;

procedure TRMTextExport.OnEndPage;
begin
  inherited;
end;

procedure TRMTextExport.InternalOnePage(aPage: TRMEndPage; aLines: TRMExportLines);
var
  i, j, lCount: Integer;
  lStrList: TStringList;
  lStr: string;
  lIsEmpty: Boolean;
  lAddIndex: Integer;
  lXPos: Integer;
  lOneLine: TRMExportOneLine;
  t: TRMReportView;

  procedure _AddLine(aStr: string);
  var
    i: Integer;
    lOneLine: string;
  begin
    if lAddIndex >= lStrList.Count then
    begin
      lStrList.Add(aStr);
      Exit;
    end;

    lOneLine := lStrList[lAddIndex];
    if Length(aStr) > Length(lOneLine) then
      lOneLine := lOneLine + StringOfChar(' ', Length(aStr) - Length(lOneLine));

    for i := 1 to Length(aStr) do
    begin
      if lOneLine[i] = ' ' then
        lOneLine[i] := aStr[i];
    end;

    lStrList[lAddIndex] := lOneLine;
  end;

  function _ReplaceFrames(s: string): string;
  var
    i, n: Integer;
  begin
    for i := 1 to Length(s) do
    begin
      n := Pos(s[i], PseudoHex);
      if n <> 0 then
      begin
        if UsePseudoGraphic then
          s[i] := Pseudo[n]
        else
          s[i] := Frames[n];
      end;
    end;
    Result := s;
  end;

  procedure _WriteToStream;
  var
    i: Integer;
    lStr: string;
  begin
    for i := 0 to lStrList.Count - 1 do
    begin
      lStr := lStrList[i];
      if ConvertToOEM then
        CharToOEMBuff(@lStr[1], @lStr[1], Length(lStr));

      lStr := _ReplaceFrames(lStr) + #13#10;
      ExportStream.Write(lStr[1], Length(lStr));
    end;

    if PageBreaks then
    begin
      lStr := #12;
      ExportStream.Write(lStr[1], Length(lStr));
    end;
  end;

begin
  lStrList := TStringList.Create;
  try
    lCount := aLines.Count - 1;
    for i := 0 to lCount do // 每一行
    begin
      lStr := '';
      lIsEmpty := True;
      lAddIndex := lStrList.Count;
      lOneLine := aLines[i];
      for j := 0 to lOneLine.Count - 1 do // 一行中的所有列
      begin
        lIsEmpty := False;
        t := lOneLine[j].View;
        lXPos := Round(t.spLeft / (6.5 / ScaleX));
        if (t is TRMCustomMemoView) and (TRMCustomMemoView(t).HAlign = rmHRight) then
          lXPos := lXPos - Length(lOneLine[j].Text);

        lStr := lStr + StringOfChar(' ', lXPos - Length(lStr)) + lOneLine[j].Text;
      end;

      if (not KillEmptyLines) or (not lIsEmpty) then
        lStrList.Add(lStr);
    end;

    _WriteToStream;
  finally
    FreeAndNil(lStrList);
  end;
end;

procedure TRMTextExport.OnText(aDrawRect: TRect; x, y: Integer;
  const aText: string; View: TRMView);
begin
  FLines.Add(aText, FCurReportView);
end;

procedure TRMTextExport.OnExportPage(const aPage: TRMEndPage);
var
  i: Integer;
  t: TRMReportView;
  lSaveOffsetLeft, lSaveOffsetTop: Integer;
begin
  for i := 0 to aPage.Page.Objects.Count - 1 do
  begin
    t := aPage.Page.Objects[i];
    if t.IsBand or (t is TRMSubReportView) then Continue;

    FCurReportView := t;
    lSaveOffsetLeft := THackRMView(t).OffsetLeft;
    lSaveOffsetTop := THackRMView(t).OffsetTop;
    THackRMView(t).OffsetLeft := 0;
    THackRMView(t).OffsetTop := 0;
    THackRMView(t).ExportData;
    THackRMView(t).OffsetLeft := lSaveOffsetLeft;
    THackRMView(t).OffsetTop := lSaveOffsetTop;
  end;

  InternalOnePage(aPage, FLines);
end;

function TRMTextExport.ShowModal: Word;
begin
  if not ShowDialog then
  begin
    Result := mrOk;
    Exit;
  end;

  with TRMTXTExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ConvertToOEM;
    CB3.Checked := ExportFrames;
    CB4.Checked := UsePseudoGraphic;
    CB5.Checked := PageBreaks;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);
    CB3Click(nil);
    Result := ShowModal;
    try
      ScaleX := RMStrToFloat(E1.Text);
    except
      ScaleX := 1;
    end;
    try
      ScaleY := RMStrToFloat(E2.Text);
    except
      ScaleY := 1;
    end;
    FKillEmptyLines := CB1.Checked;
    ConvertToOEM := CB2.Checked;
    ExportFrames := CB3.Checked;
    UsePseudoGraphic := CB4.Checked;
    PageBreaks := CB5.Checked;
    Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMTXTExportForm}

procedure TRMTXTExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1800);
  RMSetStrProp(CB1, 'Caption', rmRes + 1801);
  RMSetStrProp(CB2, 'Caption', rmRes + 1802);
  RMSetStrProp(CB3, 'Caption', rmRes + 1803);
  RMSetStrProp(CB4, 'Caption', rmRes + 1804);
  RMSetStrProp(CB5, 'Caption', rmRes + 1805);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMTXTExportForm.CB3Click(Sender: TObject);
begin
  CB4.Enabled := CB3.Checked;
end;

procedure TRMTXTExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

initialization

end.

