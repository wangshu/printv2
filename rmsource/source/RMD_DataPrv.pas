
{*****************************************}
{                                         }
{   Report Machine v2.0  - Data storage   }
{            Preview Data                 }
{                                         }
{*****************************************}

unit RMD_DataPrv;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DB, DBGrids, StdCtrls, DBCtrls, ExtCtrls, Buttons;

type
  TRMDFormPreviewData = class(TForm)
    Panel1: TPanel;
    edtRecordNo: TEdit;
    lblRecord: TLabel;
    spbFirst: TSpeedButton;
    spbPrior: TSpeedButton;
    spbNext: TSpeedButton;
    spbLast: TSpeedButton;
    Panel2: TPanel;
    btnOK: TButton;
    DBGrid1: TDBGrid;
    procedure spbFirstClick(Sender: TObject);
    procedure spbPriorClick(Sender: TObject);
    procedure spbNextClick(Sender: TObject);
    procedure spbLastClick(Sender: TObject);
    procedure edtRecordNoExit(Sender: TObject);
    procedure edtRecordNoKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    FRecordCount: Longint;
    FCurrentRecord: Longint;
    FDataSet: TDataSet;
    function GetDataSource: TDataSource;
    procedure SetDataSource(aDataSource: TDataSource);
    procedure MoveBy(aIncrement: Longint);
  protected
    {override from ancestor}
		procedure LocateRecord;
    procedure Localize;
  public
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;

implementation

uses RM_Utils, RM_Const;

{$R *.DFM}

procedure TRMDFormPreviewData.Localize;
begin
	Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(lblRecord, 'Caption', rmRes + 3250);

  btnOK.Caption := RMLoadStr(SOK);
end;

procedure TRMDFormPreviewData.LocateRecord;
var
  liNewRecord: Longint;
begin
  try
    liNewRecord := StrToInt(edtRecordNo.Text);
		if liNewRecord <> FCurrentRecord then
	    MoveBy(liNewRecord - FCurrentRecord);
  except
    edtRecordNo.Text := IntToStr(FCurrentRecord);
  end;
end;

procedure TRMDFormPreviewData.SetDataSource(aDataSource: TDataSource);
begin
  if (aDataSource <> nil) then
    FDataSet := aDataSource.DataSet
  else
    FDataSet := nil;

  if FDataSet <> nil then
  begin
		if not FDataSet.Active then
    	FDataSet.Active := TRUE;
    FRecordCount := FDataSet.RecordCount;
  end
  else
    FRecordCount := 0;

  FCurrentRecord := 0;
  MoveBy(1);
  DBGrid1.DataSource := aDataSource;
end;

function TRMDFormPreviewData.GetDataSource: TDataSource;
begin
  Result := DBGrid1.DataSource;
end;

procedure TRMDFormPreviewData.MoveBy(aIncrement: Longint);
begin
  if (FDataSet = nil) then Exit;
  Inc(FCurrentRecord, aIncrement);
  if (FCurrentRecord <= 1) then
  begin
    FCurrentRecord := 1;
    FDataSet.First;
  end
  else if (FCurrentRecord >= FRecordCount) then
  begin
    FCurrentRecord := FRecordCount;
    FDataSet.Last;
  end
  else
    FDataSet.MoveBy(aIncrement);
  edtRecordNo.Text := IntToStr(FCurrentRecord);
end;

procedure TRMDFormPreviewData.spbFirstClick(Sender: TObject);
begin
  MoveBy((FRecordCount + 1) * -1);
end;

procedure TRMDFormPreviewData.spbPriorClick(Sender: TObject);
begin
  MoveBy(-1);
end;

procedure TRMDFormPreviewData.spbNextClick(Sender: TObject);
begin
  MoveBy(1);
end;

procedure TRMDFormPreviewData.spbLastClick(Sender: TObject);
begin
  MoveBy(FRecordCount + 1);
end;

procedure TRMDFormPreviewData.edtRecordNoExit(Sender: TObject);
begin
	LocateRecord;
end;

procedure TRMDFormPreviewData.edtRecordNoKeyPress(Sender: TObject;
  var Key: Char);
begin
	if Key = #13 then
  	LocateRecord;
end;

procedure TRMDFormPreviewData.FormCreate(Sender: TObject);
begin
	Localize;
end;

end.

