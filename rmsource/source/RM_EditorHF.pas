unit RM_EditorHF;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, RM_Common, RM_Class;

type
  TRMFormEditorHF = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    memTitle: TMemo;
    GroupBox2: TGroupBox;
    memCaptionLeft: TMemo;
    memCaptionCenter: TMemo;
    memCaptionRight: TMemo;
    FontDialog1: TFontDialog;
    Panel2: TPanel;
    GroupBox4: TGroupBox;
    memFooterLeft: TMemo;
    memFooterCenter: TMemo;
    memFooterRight: TMemo;
    GroupBox3: TGroupBox;
    memHeaderLeft: TMemo;
    memHeaderCenter: TMemo;
    memHeaderRight: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure memTitleDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses
  RM_Utils, RM_Const, RM_Const1, RM_EditorMemo;

{$R *.DFM}

procedure TRMFormEditorHF.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(TabSheet1, 'Caption', rmRes + 867);
  RMSetStrProp(Label3, 'Caption', rmRes + 868);
  RMSetStrProp(Label4, 'Caption', rmRes + 869);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 870);
  RMSetStrProp(Label1, 'Caption', rmRes + 871);
  RMSetStrProp(Label2, 'Caption', rmRes + 872);

  RMSetStrProp(Self, 'Caption', rmRes + 873);
  RMSetStrProp(btnOK, 'Caption', SOK);
  RMSetStrProp(btnCancel, 'Caption', SCancel);
end;

procedure TRMFormEditorHF.Label1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    if Sender = Label1 then
      memTitle.Font.Assign(FontDialog1.Font)
    else if Sender = Label2 then
    begin
      memCaptionLeft.Font.Assign(FontDialog1.Font);
      memCaptionCenter.Font.Assign(FontDialog1.Font);
      memCaptionRight.Font.Assign(FontDialog1.Font);
    end
    else if Sender = Label3 then
    begin
      memHeaderLeft.Font.Assign(FontDialog1.Font);
      memHeaderCenter.Font.Assign(FontDialog1.Font);
      memHeaderRight.Font.Assign(FontDialog1.Font);
    end
    else if Sender = Label4 then
    begin
      memFooterLeft.Font.Assign(FontDialog1.Font);
      memFooterCenter.Font.Assign(FontDialog1.Font);
      memFooterRight.Font.Assign(FontDialog1.Font);
    end;
  end;
end;

procedure TRMFormEditorHF.memTitleDblClick(Sender: TObject);
var
  tmp: TRMEditorForm;
begin
  tmp := TRMEditorForm(RMDesigner.EditorForm);
  tmp.Memo.Lines.Assign(TMemo(Sender).Lines);
  if tmp.Execute then
    TMemo(Sender).Lines.Assign(tmp.Memo.Lines);
end;

procedure TRMFormEditorHF.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  Localize;
end;

end.
