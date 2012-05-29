unit QR2RMConv;

interface

{$I qr2rm.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, QuickRpt, QRCtrls, QRPrntr, Printers, RM_Class, RM_Dataset, RM_Printer,
  RM_Common, DB,
{$IFDEF RM_Delphi6}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF};

type

	{ TQR2RMConv }
  TQR2RMConv = class(TComponent)
  private
    { Private declarations }
    FSource: TQuickRep;
    FTarget: TRMReport;
    procedure SetSource(Value: TQuickRep);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetBandAlignment(Control: TControl; v: TRMReportView);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Convert;
    property Target: TRMReport read FTarget;
  published
    property Source: TQuickRep read FSource write SetSource;
  end;

  { TQR2RMConvEditor }
  TQR2RMConvEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

procedure Register;

implementation

uses Math, RM_RichEdit;

procedure Register;
begin
  RegisterComponents('ReportMachine Conver', [TQR2RMConv]);
  RegisterComponentEditor(TQR2RMConv, TQR2RMConvEditor);
end;

type
	THackQRLabel = class(TQRCustomLabel)
  end;

  THackReportView = class(TRMReportView)
  end;

function RMReplaceStr(const S, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then
    begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until I <= 0;
end;

procedure AssignRich(Rich1, Rich2: TRichEdit);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  try
    with Rich2 do
    begin
      SelStart := 0;
      SelLength := Length(Text);
      SelAttributes.Protected := FALSE;
      Lines.SaveToStream(st);
    end;
    st.Position := 0;
    Rich1.Lines.LoadFromStream(st);
  finally
    st.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TQR2RMConv }
constructor TQR2RMConv.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Assigned(AOwner) and (AOwner is TQuickRep) then
    FSource := TQuickRep(AOwner);
end;

destructor TQR2RMConv.Destroy;
begin
  inherited Destroy;
end;

procedure TQR2RMConv.SetSource(Value: TQuickRep);
begin
  FSource := Value;
end;

procedure TQR2RMConv.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FSource then
      FSource := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

procedure TQR2RMConv.Convert;
var
  lBand: TRMView;
  v, bkView: TRMView;
  qrb: TQRBand;
  Control: TControl;
  i, j, maxdy: Integer;
  liPage: TRMReportPage;
  RMDBDataSet, RMDBSubDetailDataSet: TRMDBDataset;

  procedure SetFrame(Constrol: TControl);
  begin
  	maxdy := Max(maxdy, Control.Top + Control.Height);
    v.Name := Control.Name;
		if Control.Top < 0 then
	    v.SetspBounds(Control.Left + liPage.spMarginLeft, qrb.Top, Control.Width, Control.Height)    else
	    v.SetspBounds(Control.Left + liPage.spMarginLeft, Control.Top + qrb.Top, Control.Width, Control.Height);

    v.LeftFrame.Visible := TQRCustomLabel(Control).Frame.DrawLeft;
    v.LeftFrame.spWidth := TQRCustomLabel(Control).Frame.Width;
    v.LeftFrame.Style := TRMPenStyle(TQRCustomLabel(Control).Frame.Style);

    v.TopFrame.Visible := TQRCustomLabel(Control).Frame.DrawTop;
    v.TopFrame.spWidth := TQRCustomLabel(Control).Frame.Width;
    v.TopFrame.Style := TRMPenStyle(TQRCustomLabel(Control).Frame.Style);

    v.RightFrame.Visible := TQRCustomLabel(Control).Frame.DrawRight;
    v.RightFrame.spWidth := TQRCustomLabel(Control).Frame.Width;
    v.RightFrame.Style := TRMPenStyle(TQRCustomLabel(Control).Frame.Style);

    v.BottomFrame.Visible := TQRCustomLabel(Control).Frame.DrawBottom;
    v.BottomFrame.spWidth := TQRCustomLabel(Control).Frame.Width;
    v.BottomFrame.Style := TRMPenStyle(TQRCustomLabel(Control).Frame.Style);

    SetBandAlignment(Control, TRMReportView(v));
  end;

  procedure _CreateMemoView(Control: TControl);
  begin
    v := RMCreateObject(gtMemo, '');
    SetFrame(Control);

    case TQRCustomLabel(Control).Alignment of
      taLeftJustify: TRMMemoView(v).HAlign := rmhLeft;
      taRightJustify: TRMMemoView(v).HAlign := rmhRight;
      taCenter: TRMMemoView(v).HAlign := rmhCenter;
    end;

    TRMMemoView(v).Font := TQRCustomLabel(Control).Font;
		if not THackQRLabel(Control).Transparent then
	    v.FillColor := TQRCustomLabel(Control).Color;
    TRMMemoView(v).Visible := TQRCustomLabel(Control).Visible;
    TRMMemoView(v).Wordwrap := TQRCustomLabel(Control).WordWrap;
    TRMMemoView(v).Stretched := TQRCustomLabel(Control).AutoStretch;
    TRMMemoView(v).AutoWidth := TQRCustomLabel(Control).AutoSize;
  end;

  procedure CreateRMReport;
  var
    i: Integer;
    str: string;
  begin
    FTarget := TRMReport.Create(FSource.Owner);
    FTarget.ReportInfo.Title := FSource.ReportTitle;
    FTarget.ShowProgress := FSource.ShowProgress;
//    FTarget.PrintIfEmpty := FSource.PrintIfEmpty;
    FTarget.DefaultCopies := FSource.PrinterSettings.Copies;

    FTarget.Pages.Clear;
    liPage := FTarget.Pages.AddReportPage;
    FSource.Page.Units := MM;
    liPage.ChangePaper(rmpgCustom, Round(FSource.Page.Width * 10), Round(FSource.Page.Length * 10),
      liPage.PageBin, TRMPrinterOrientation(FSource.Page.Orientation));

    FSource.Page.Units := Pixels;
    liPage.spMarginLeft := Round(FSource.Page.LeftMargin);
    liPage.spMarginTop := Round(FSource.Page.TopMargin);
    liPage.spMarginRight := Round(FSource.Page.RightMargin);
    liPage.spMarginBottom := Round(FSource.Page.BottomMargin);

    RMDBDataSet := TRMDBDataset.Create(FSource.Owner);
    RMDBDataSet.DataSet := FSOurce.DataSet;
    i := 1;
    while True do
    begin
      str := 'RMDBDataset' + IntToStr(i);
      if FSource.Owner.FindComponent(str) = nil then
      begin
        RMDBDataset.Name := str;
        Break;
      end;
      Inc(i);
    end;

    FTarget.Dataset := RMDBDataSet;
  end;

  procedure CreateSubDetailDataSet;
  var
    i: Integer;
    str: string;
  begin
    RMDBSubDetailDataSet := TRMDBDataset.Create(FSource.Owner);
    RMDBSubDetailDataSet.DataSet := FSOurce.DataSet;
    i := 1;
    while True do
    begin
      str := 'RMDBDataset' + IntToStr(i);
      if FSource.Owner.FindComponent(str) = nil then
      begin
        RMDBSubDetailDataSet.Name := str;
        Break;
      end;
      Inc(i);
    end;
  end;

  procedure _SetSubDetailDataSet(ds: TDataSet);
  begin
		if (ds <> nil) and (ds <> RMDBDataSet.DataSet) then
    	RMDBSubDetailDataSet.DataSet := ds;
  end;
begin
  if FSource = nil then
    raise Exception.Create('(TQuickRep)');

  CreateRMReport;
  for i := 0 to FSource.BandList.Count - 1 do
  begin
    qrb := TQRBand(FSource.BandList[i]);
    maxdy := qrb.Height;
    lBand := nil;
    case qrb.BandType of
      rbTitle:
        begin
          lBand := RMCreateBand(rmbtReportTitle);
          TRMBandReportTitle(lBand).Stretched := True;
        end;
      rbPageHeader:
        begin
          lBand := RMCreateBand(rmbtPageHeader);
          TRMBandPageHeader(lBand).Stretched := True;
        end;
      rbDetail:
        begin
          lBand := RMCreateBand(rmbtMasterData);
          TRMBandMasterData(lBand).DataSetName := RMDBDataSet.Name;
          TRMBandMasterData(lBand).Stretched := True;
        end;
      rbPageFooter:
      	begin
          lBand := RMCreateBand(rmbtPageFooter);
        end;
      rbSummary:
      	begin
          lBand := RMCreateBand(rmbtReportSummary);
          TRMBandReportSummary(lBand).Stretched := True;
        end;
      rbGroupHeader:
        begin
          lBand := RMCreateBand(rmbtGroupHeader);
          TRMBandGroupHeader(lBand).GroupCondition := '[' + TQRGroup(qrb).Expression + ']';
        end;
      rbGroupFooter:
      	begin
          lBand := RMCreateBand(rmbtGroupFooter);
        end;
      rbSubDetail:
        begin
          lBand := RMCreateBand(rmbtDetailData);
          TRMBandDetailData(lBand).Stretched := True;
          CreateSubDetailDataSet;
          TRMBandDetailData(lBand).DataSetName := RMDBSubDetailDataSet.Name;
        end;
      rbColumnHeader:
      	begin
          lBand := RMCreateBand(rmbtColumnHeader);
          TRMBandColumnHeader(lBand).Stretched := True;
        end;
      rbOverlay:
      	begin
          lBand := RMCreateBand(rmbtOverlay);
        end;
      rbChild:
      	begin
        end;
    else
      lBand := RMCreateBand(rmbtNone);
    end;

    lBand.ParentPage := liPage;
    lBand.SetspBounds(qrb.Left, qrb.Top, qrb.Width, qrb.Height);
    lBand.Name := qrb.Name;

    if TRMBand(lBand).BandType <> rmbtPageFooter then
    begin
//      if Assigned(qrb.ChildBand) then
//        lBand.ChildBand := qrb.ChildBand.Name;
    end;

    bkView := nil;
    if qrb.Color <> clWhite then
    begin
	    bkView := RMCreateObject(gtMemo, '');
      bkView.SetspBounds(qrb.Left, qrb.Top, qrb.Width, qrb.Height);
      bkView.FillColor := qrb.Color;
      bkView.ParentPage := liPage;
    end;

    for j := 0 to qrb.ControlCount - 1 do
    begin
      Control := qrb.Controls[j];
      if Control is TQRCustomLabel then
      begin
        _CreateMemoView(Control);
        TRMMemoView(v).spGapLeft := 0;
        TRMMemoView(v).spGapTop := 0;
        if Control is TQRDBText then
        begin
          v.Memo.Text := Format('[%s.%s."%s"]', [TQRDBText(Control).DataSet.Owner.Name, TQRDBText(Control).DataSet.Name, TQRDBText(Control).DataField]);
					_SetSubDetailDataSet(TQRDBText(Control).DataSet);
				end
        else if Control is TQRLabel then
          v.Memo.Add(TQRLabel(Control).Caption)
        else if Control is TQRMemo then
          v.Memo.Assign(TQRMemo(Control).Lines)
        else if Control is TQRExprMemo then
        begin
          v.Memo.Assign(TQRExprMemo(Control).Lines);
          v.Memo.Text := RMReplaceStr(v.Memo.Text, '{', '[');
          v.Memo.Text := RMReplaceStr(v.Memo.Text, '}', ']');
        end
        else if Control is TQRExpr then
          v.Memo.Add('[' + TQRExpr(Control).Expression + ']')
        else if Control is TQRSysData then
        begin
          _CreateMemoView(Control);
          case TQRSysData(Control).Data of
            qrsDate: v.Memo.Text := '[Date]';
            qrsDateTime: v.Memo.Text := '[Date] [Time]';
            qrsDetailCount: v.Memo.Text := '';
            qrsDetailNo: v.Memo.Text := '[Line#]';
            qrsPageNumber: v.Memo.Text := '[Page#]';
//            qrsReportTitle: v.Memo.Text := FTarget.Title;
            qrsTime: v.Memo.Text := '[Time]';
          end;
        end;
        liPage.Objects.Add(v);
      end
      else if (Control is TQRDBImage) or (Control is TQRImage) then
      begin
        v := RMCreateObject(gtPicture, '');
        SetFrame(Control);
        TRMPictureView(v).PictureStretched := TQRImage(Control).Stretch;
        TRMPictureView(v).PictureCenter := TQRImage(Control).Center;
        if Control is TQRDBImage then
        begin
          v.Memo.Text := Format('[%s.%s."%s"]', [TQRDBImage(Control).DataSet.Owner.Name, TQRDBImage(Control).DataSet.Name, TQRDBImage(Control).DataField]);
					_SetSubDetailDataSet(TQRDBImage(Control).DataSet);
				end
        else
          TRMPictureView(v).Picture.Assign(TQRImage(Control).Picture);

        liPage.Objects.Add(v);
      end
      else if Control is TQRShape then
      begin
        v := RMCreateObject(gtAddin, 'TRMShapeView');
        SetFrame(Control);
        case TQRShape(Control).Shape of
        	qrsCircle: TRMShapeView(v).Shape := rmskEllipse;
					qrsHorLine: TRMShapeView(v).Shape := rmHorLine;
          qrsRectangle: TRMShapeView(v).Shape := rmskRectangle;
          qrsRightAndLeft: TRMShapeView(v).Shape := rmRightAndLeft;
          qrsTopAndBottom: TRMShapeView(v).Shape := rmTopAndBottom;
          qrsVertLine: TRMShapeView(v).Shape := rmVertLine;
        end;
        TRMShapeView(v).Pen.Mode := TQRShape(Control).Pen.Mode;
        TRMShapeView(v).TopFrame.Color := TQRShape(Control).Pen.Color;
        TRMShapeView(v).TopFrame.Width := TQRShape(Control).Pen.Width;
        TRMShapeView(v).TopFrame.Style := TRMPenStyle(TQRShape(Control).Pen.Style);

        liPage.Objects.Add(v);
      end
			else if (Control is TQRRichText) or (Control is TQRDBRichText) then
      begin
      	v := RMCreateObject(gtAddin, 'TRMRichView');
        SetFrame(Control);
        TRMRichView(v).Stretched := TQRRichText(Control).AutoStretch;
        TRMRichView(v).RichEdit.Alignment := TQRRichText(Control).Alignment;
        v.FillColor := TQRRichText(Control).Color;
        if Control is TQRDBRichText then
        begin
					if TQRDBRichText(Control).DataSet <> nil then
	          v.Memo.Text := Format('[%s.%s."%s"]', [TQRDBRichText(Control).DataSet.Owner.Name, TQRDBRichText(Control).DataSet.Name, TQRDBRichText(Control).DataField]);
					_SetSubDetailDataSet(TQRDBRichText(Control).DataSet);
				end
        else
        begin
        	if TQRRichText(Control).ParentRichEdit <> nil then
          	AssignRich(TRMRichView(v).RichEdit, TQRRichText(Control).ParentRichEdit)
          else
          	TRMRichView(v).RichEdit.Lines.Assign(TQRRichText(Control).Lines);
        end;

        liPage.Objects.Add(v);
      end;
    end;

    lBand.spHeight := maxdy;
    if bkView <> nil then bkView.spHeight := maxdy;
  end;
end;

procedure TQR2RMConv.SetBandAlignment(Control: TControl; v: TRMReportView);
var
  Alignment: TAlignment;
  AlignToBand: Boolean;
begin
  if Control is TQRCustomLabel then
  begin
    AlignToBand := False;
    Alignment := TQRCustomLabel(Control).Alignment;
    if (Control is TQRDBText) then
      AlignToBand := TQRDBText(Control).AlignToBand
    else if (Control is TQRExpr) then
      AlignToBand := TQRExpr(Control).AlignToBand
    else if (Control is TQRLabel) then
      AlignToBand := TQRLabel(Control).AlignToBand
    else if (Control is TQRMemo) then
      AlignToBand := TQRMemo(Control).AlignToBand
    else if (Control is TQRSysData) then
      AlignToBand := TQRSysData(Control).AlignToBand;
    if AlignToBand then
    begin
      case Alignment of
        taLeftJustify: THackReportView(v).BandAlign := rmbaLeft;
        taRightJustify: THackReportView(v).BandAlign := rmbaRight;
        taCenter: THackReportView(v).BandAlign := rmbaCenter;
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TQR2RMConvEditor }
procedure TQR2RMConvEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: TQR2RMConv(Component).Convert;
    1:
      begin
        if TQR2RMConv(Component).FTarget <> nil then
          TQR2RMConv(Component).FTarget.DesignReport;
      end;
  end;
end;

function TQR2RMConvEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Unknown method';
  case Index of
    0: Result := 'Convert';
    1: Result := 'Design Report';
  end;
end;

function TQR2RMConvEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.

