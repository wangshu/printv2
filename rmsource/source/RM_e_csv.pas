
{*****************************************}
{                                         }
{          Report Machine v1.0            }
{            CSV export filter            }
{                                         }
{*****************************************}

unit RM_e_csv;

interface

{$I RM.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls,
  RM_Common, RM_Class, RM_E_TXT, Controls;

type
  TRMCSVExport = class(TRMTextExport)
  private
    FDelimiter: Char;
  protected
    procedure InternalOnePage(aPage: TRMEndPage; aLines: TRMExportLines); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
  published
    property Delimiter: Char read FDelimiter write FDelimiter;
  end;

  { TRMCSVExportForm }
  TRMCSVExportForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    Label4: TLabel;
    E3: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses RM_Const, RM_Utils;

{$R *.DFM}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMCSVExport}

constructor TRMCSVExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RMRegisterExportFilter(Self, RMLoadStr(SCSVFile) + ' (*.csv)', '*.csv');

  CreateFile := True;
  ShowDialog := True;

  ScaleX := 1;
  ScaleY := 1;
  KillEmptyLines := True;
  ConvertToOEM := False;
  Delimiter := ';';
end;

procedure TRMCSVExport.InternalOnePage(aPage: TRMEndPage; aLines: TRMExportLines);
var
  i, j, k, tc1, tc2: Integer;
  lStr: string;
  lOneLine: TRMExportOneLine;

  procedure _WriteOneLine;
  begin
    if not KillEmptyLines or (lStr <> '') then
    begin
      if ConvertToOEM then
        CharToOEMBuff(@lStr[1], @lStr[1], Length(lStr));

      lStr := lStr + #13#10;
      ExportStream.Write(lStr[1], Length(lStr));
    end;
  end;

begin
  for i := 0 to aLines.Count - 1 do
  begin
    lOneLine := aLines[i];
    lStr := '';
    tc1 := 0;
    for j := 0 to lOneLine.Count - 1 do
    begin
      tc2 := Round(lOneLine[j].View.spLeft / (64 / ScaleX));
      for k := 0 to tc2 - tc1 - 1 do
        lStr := lStr + Delimiter;

      if Pos(Delimiter, lOneLine[j].Text) > 0 then
        lStr := lStr + '"' + lOneLine[j].Text + '"'
      else
        lStr := lStr + lOneLine[j].Text;

      tc1 := tc2;
    end;
    _WriteOneLine;
  end;
end;

function TRMCSVExport.ShowModal: Word;
begin
  if not ShowDialog then
  begin
    Result := mrOk;
    Exit;
  end;

  with TRMCSVExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ConvertToOEM;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);
    E3.Text := Delimiter;

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
    KillEmptyLines := CB1.Checked;
    ConvertToOEM := CB2.Checked;
    if (E3.Text <> '') and (E3.Text <> '"') then
      Delimiter := E3.Text[1];
    Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMCSVExportForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 1810);
  RMSetStrProp(CB1, 'Caption', rmRes + 1801);
  RMSetStrProp(CB2, 'Caption', rmRes + 1802);
  RMSetStrProp(Label1, 'Caption', rmRes + 1806);
  RMSetStrProp(Label4, 'Caption', rmRes + 1811);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMCSVExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

initialization

end.

