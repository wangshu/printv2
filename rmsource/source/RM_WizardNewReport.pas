
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{             Template viewer             }
{                                         }
{*****************************************}

unit RM_WizardNewReport;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, RM_Class, RM_Wizard
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF};

type
  TRMTemplForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    ImageList1: TImageList;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Memo1: TMemo;
    lsvTempl: TListView;
    lsvWizard: TListView;
    ImageListWizard: TImageList;
    procedure lsvTemplDblClick(Sender: TObject);
    procedure lsvTemplClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure lsvWizardClick(Sender: TObject);
  private
    { Private declarations }
    FReport: TRMReport;
    FFileExt: string;

    procedure ClearTempl;
    procedure GetTempReport;
    procedure GetWizard;
    procedure Localize;
  public
    { Public declarations }
    atype: Integer;
    TemplName: string;
    WizardClass: TRMReportWizardClass;

    property CurrentReport: TRMReport read FReport write FReport;
    property FileExt: string read FFileExt write FFileExt;
  end;

implementation

uses RM_Const, RM_Designer, RM_Utils;

{$R *.DFM}

type
  TTemplObject = class
  private
  protected
  public
    FileName: string;
  end;

var
  Path: string;

procedure TRMTemplForm.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 780);
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 781);
  RMSetStrProp(TabSheet1, 'Caption', rmRes + 782);
  RMSetStrProp(TabSheet2, 'Caption', rmRes + 783);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMTemplForm.ClearTempl;
begin
  while lsvTempl.Items.Count > 0 do
  begin
    TTemplObject(lsvTempl.Items[0].Data).Free;
    lsvTempl.Items.Delete(0);
  end;
end;

procedure TRMTemplForm.GetTempReport;
var
  SearchRec: TSearchRec;
  r: Word;
  tmp: TTemplObject;
begin
  Path := RMTemplateDir;
  if RMTemplateDir = '' then
    Path := ExtractFilePath(ParamStr(0))
  else if Path[Length(Path)] <> '\' then
    Path := Path + '\';

  ClearTempl;
  with lsvTempl.Items.Add do
  begin
    ImageIndex := 0;
    StateIndex := 0;
    Caption := RMLoadStr(rmRes + 839);

    tmp := TTemplObject.Create;
    tmp.FileName := '';
    Data := tmp;
  end;

  R := FindFirst(Path + FFileExt, faAnyFile, SearchRec);
  while R = 0 do
  begin
    if (SearchRec.Attr and faDirectory) = 0 then
    begin
      with lsvTempl.Items.Add do
      begin
        ImageIndex := 0;
        StateIndex := 0;
        Caption := ChangeFileExt(SearchRec.Name, '');

        tmp := TTemplObject.Create;
        tmp.FileName := Path + ChangeFileExt(SearchRec.Name, FFileExt);
        Data := tmp;
      end;
    end;
    R := FindNext(SearchRec);
  end;

  FindClose(SearchRec);
  Memo1.Lines.Clear;
  Image1.Picture.Bitmap.Assign(nil);
  btnOK.Enabled := False;
end;

procedure TRMTemplForm.GetWizard;
var
  lClass: TRMWizardClass;
  lIndex: Integer;
  lBitMap: TBitmap;
  FTemplateClasses: TList;
begin
  FTemplateClasses := rmGetWizardClassList;
  if FTemplateClasses.Count = 0 then Exit;

  lBitMap := TBitmap.Create;
{  for liIndex := 0 to FTemplateClasses.Count - 1 do
  begin
    lClass := TClass(FTemplateClasses[liIndex]);
    if (lBitMap.Width = 32) and (lBitMap.Height = 32) then
      ImageListWizard.AddMasked(lBitMap, clWhite);
  end;
}
  lsvWizard.LargeImages := ImageListWizard;
  for lIndex := 0 to FTemplateClasses.Count - 1 do
  begin
    lClass := TRMWizardClass(FTemplateClasses[lIndex]);
	    with lsvWizard.Items.Add do
  	  begin
    	  ImageIndex := lIndex;
      	Data := lClass;
	      Caption := TRMWizardClass(lClass).ClassDescription;
  	  end;
  end;

  lBitMap.Free;
  btnOK.Enabled := False;
end;

procedure TRMTemplForm.FormShow(Sender: TObject);
begin
  GetTempReport;
  GetWizard;
end;

procedure TRMTemplForm.lsvTemplClick(Sender: TObject);
begin
  btnOK.Enabled := lsvTempl.Selected <> nil;
  if btnOK.Enabled then
  begin
    atype := 1;
    TemplName := TTemplObject(lsvTempl.Selected.Data).FileName;
    if Length(TemplName) > 0 then
      FReport.LoadTemplate(TemplName, Memo1.Lines, Image1.Picture.Bitmap);
  end;
end;

procedure TRMTemplForm.lsvTemplDblClick(Sender: TObject);
begin
  if btnOK.Enabled then
    ModalResult := mrOk;
end;

procedure TRMTemplForm.FormCreate(Sender: TObject);
begin
	Localize;
  PageControl1.ActivePage := tabSheet1;
end;

procedure TRMTemplForm.FormDestroy(Sender: TObject);
begin
  ClearTempl;
end;

procedure TRMTemplForm.PageControl1Change(Sender: TObject);
begin
  btnOK.Enabled := FALSE;
end;

procedure TRMTemplForm.lsvWizardClick(Sender: TObject);
begin
  btnOK.Enabled := lsvWizard.Selected <> nil;
  if btnOK.Enabled then
  begin
    atype := 2;
    WizardClass := TRMReportWizardClass(lsvWizard.Selected.Data);
  end;
end;

end.

