
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{           Chart Add-In Object           }
{                                         }
{*****************************************}

unit RM_DBChart;

interface

{$I RM.inc}

{$IFDEF TeeChart}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, Buttons, RM_Common, RM_Class, RM_Ctrls,
  TeeProcs, TeEngine, Chart, Series, DBChart, DB, RM_DataSet
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER4_UP}, ImgList{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type

  TRMDBChartObject = class(TComponent) // fake component
  end;

  { TRMDBChartSeries }
  TRMDBChartSeries = class
  private
    FLegendView, FValueView, FLabelView: string;
    FTitle: string;
    FColor: TColor;
    FChartType: Byte;
    FShowMarks, FColored: Boolean;
    FMarksStyle: Byte;
    FDataSet: string;
  protected
  public
    constructor Create;
  published
    property DataSet: string read FDataSet write FDataSet;
    property LegendView: string read FLegendView write FLegendView;
    property ValueView: string read FValueView write FValueView;
    property LabelView: string read FLabelView write FLabelView;
    property Title: string read FTitle write FTitle;
    property Color: TColor read FColor write FColor;
    property ChartType: Byte read FChartType write FChartType;
    property ShowMarks: Boolean read FShowMarks write FShowMarks;
    property Colored: Boolean read FColored write FColored;
    property MarksStyle: Byte read FMarksStyle write FMarksStyle;
  end;

  {TRMDBChartView}
  TRMDBChartView = class(TRMReportView)
  private
    FPrintType: TRMPrintMethodType;
    FDBChart: TDBChart;
    FPicture: TMetafile;
    FList: TList;
    FChartDim3D, FChartShowLegend, FChartShowAxis: Boolean;

    function GetUseChartSetting: Boolean;
    procedure SetUseChartSetting(Value: Boolean);
    procedure ShowChart;
    function GetSeries(Index: Integer): TRMDBChartSeries;
    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
  protected
    procedure Prepare; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
    function GetViewCommon: string; override;
    procedure ClearContents; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear;
    function SeriesCount: Integer;
    function AddSeries: TRMDBChartSeries;
    procedure DeleteSeries(Index: Integer);

    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure DefinePopupMenu(Popup: TRMCustomMenuItem); override;
//    procedure OnHook(aView: TRmView); override;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    procedure ShowEditor; override;
    procedure AssignChart(AChart: TCustomChart);
    property Series[Index: Integer]: TRMDBChartSeries read GetSeries;
    property DBChart: TDBChart read FDBChart;
  published
    property PrintType: TRMPrintMethodType read FPrintType write FPrintType;
    property UseChartSetting: Boolean read GetUseChartSetting write SetUseChartSetting;
    property Memo;
    property ChartDim3D: Boolean read FChartDim3D write FChartDim3D;
    property ChartShowLegend: Boolean read FChartShowLegend write FChartShowLegend;
    property ChartShowAxis: Boolean read FChartShowAxis write FChartShowAxis;
    property ReprintOnOverFlow;
    property ShiftWith;
    property BandAlign;
    property LeftFrame;
    property RightFrame;
    property TopFrame;
    property BottomFrame;
    property FillColor;
    property DirectDraw: Boolean read GetDirectDraw write SetDirectDraw;
    property PrintFrame;
    property Printable;
    property OnPreviewClick;
    property OnPreviewClickUrl;
  end;

  { TRMChartForm }
  TRMDBChartForm = class(TForm)
    Page1: TPageControl;
    Tab1: TTabSheet;
    gpbSeriesType: TGroupBox;
    Tab2: TTabSheet;
    btnOk: TButton;
    btnCancel: TButton;
    gpbSeriesOptions: TGroupBox;
    chkSeriesMultiColor: TCheckBox;
    chkSeriesShowMarks: TCheckBox;
    Tab3: TTabSheet;
    gpbMarks: TGroupBox;
    rdbStyle1: TRadioButton;
    rdbStyle2: TRadioButton;
    rdbStyle3: TRadioButton;
    rdbStyle4: TRadioButton;
    rdbStyle5: TRadioButton;
    TabSheet1: TTabSheet;
    ListBox1: TListBox;
    gpbChartOptions: TGroupBox;
    chkChartShowLegend: TCheckBox;
    chkChartShowAxis: TCheckBox;
    PopupMenu1: TPopupMenu;
    Add1: TMenuItem;
    Delete1: TMenuItem;
    chkChartDim3D: TCheckBox;
    EditTitle1: TMenuItem;
    N1: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    gpbObjects: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label6: TLabel;
    ImageList1: TImageList;
    cmbSeriesType: TComboBox;
    cmbLegend: TComboBox;
    cmbValue: TComboBox;
    cmbLabel: TComboBox;
    cmbDataSet: TComboBox;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure EditTitle1Click(Sender: TObject);
    procedure chkSeriesMultiColorClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbSeriesTypeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbDataSetChange(Sender: TObject);
    procedure cmbDataSetDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    FChartView: TRMDBChartView;
    FReport: TRMReport;
    FSeries: TRMDBChartSeries;
    FBtnColor: TRMColorPickerButton;
    FDataSetBMP, FFieldBMP: TBitmap;

    procedure Localize;
    procedure LoadSeriesOptions;
    procedure SaveSeriesOptions;
  public
    { Public declarations }
  end;

  TRMCustomDBTeeChartUIClass = class of TRMCustomDBTeeChartUI;

  TRMCustomDBTeeChartUI = class
  public
    class procedure Edit(aTeeChart: TCustomChart); virtual;
  end;

  {TRMTeeChartUIPlugIn }
  TRMTeeChartUIPlugIn = class
  private
    class function GetChartUIClass(aTeeChart: TCustomChart): TRMCustomDBTeeChartUIClass;
  public
    class procedure Register(aChartUIClass: TRMCustomDBTeeChartUIClass);
    class procedure UnRegister(aChartUIClass: TRMCustomDBTeeChartUIClass);
    class procedure Edit(aTeeChart: TCustomChart);
  end; {class, TRMTeeChartUIPlugIn}
{$ENDIF}

implementation

{$IFDEF TeeChart}
uses Math, RM_Utils, RM_Const, RM_Const1, RMInterpreter_Chart;

{$R *.DFM}

const
  flChartUseChartSetting = $2;
  flChartDirectDraw = $4;

type
  THackPage = class(TRMCustomPage)
  end;

  THackView = class(TRMView)
  end;

  TSeriesClass = class of TChartSeries;

const
  ChartTypes: array[0..5] of TSeriesClass =
  (TLineSeries, TAreaSeries, TPointSeries, TBarSeries, THorizBarSeries, TPieSeries);

var
  uDBChartUIClassList: TList;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDBChartSeries }

constructor TRMDBChartSeries.Create;
begin
  inherited Create;

  FDataSet := '';
  FColored := False;
  FValueView := '';
  FLegendView := '';
  FTitle := '';
  FColor := clTeeColor;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMDBChartView }

constructor TRMDBChartView.Create;
begin
  inherited Create;
  BaseName := 'DBChart';
//  WantHook := True;
  UseChartSetting := False;

  FDBChart := TDBChart.Create(RMDialogForm);
  with FDBChart do
  begin
    Parent := RMDialogForm;
    Visible := False;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;

  FChartDim3D := True;
  FChartShowLegend := True;
  FPrintType := rmptMetafile;

  FPicture := TMetafile.Create;
  FList := TList.Create;
end;

destructor TRMDBChartView.Destroy;
begin
  Clear;
  if RMDialogForm <> nil then
  begin
    FDBChart.Free;
    FDBChart := nil;
  end;
  FPicture.Free;
  FList.Free;
  inherited Destroy;
end;

procedure TRMDBChartView.Clear;
begin
  while FList.Count > 0 do
  begin
    TRMDBChartSeries(FList[0]).Free;
    FList.Delete(0);
  end;
end;

function TRMDBChartView.SeriesCount: Integer;
begin
  Result := FList.Count;
end;

function TRMDBChartView.AddSeries: TRMDBChartSeries;
var
  liSeries: TRMDBChartSeries;

  procedure _SetSeriesTitle;
  var
    i, j: Integer;
    listr: string;
    liFlag: Boolean;
  begin
    for i := 1 to 9999 do
    begin
      listr := 'Series' + IntToStr(i);
      liFlag := True;
      for j := 0 to FList.Count - 1 do
      begin
        if AnsiCompareText(Series[j].Title, listr) = 0 then
        begin
          liFlag := False;
          Break;
        end;
      end;

      if liFlag then
      begin
        liSeries.Title := listr;
        Break;
      end;
    end;
  end;

begin
  liSeries := TRMDBChartSeries.Create;
  _SetSeriesTitle;
  FList.Add(liSeries);
  Result := liSeries;
end;

procedure TRMDBChartView.DeleteSeries(Index: Integer);
begin
  if (Index >= 0) and (Index < FList.Count) then
  begin
    TRMDBChartSeries(FList[Index]).Free;
    FList.Delete(Index);
  end;
end;

function TRMDBChartView.GetSeries(Index: Integer): TRMDBChartSeries;
begin
  Result := nil;
  if (Index >= 0) and (Index < FList.Count) then
    Result := TRMDBChartSeries(FList[Index]);
end;

procedure TRMDBChartView.AssignChart(AChart: TCustomChart);
var
  liSeries: TChartSeries;
  liSeriesClass: TChartSeriesClass;
  i: Integer;
begin
  Clear;
  FDBChart.RemoveAllSeries;
  FDBChart.Assign(AChart);
  for i := 0 to AChart.SeriesCount - 1 do
  begin
    liSeriesClass := TChartSeriesClass(AChart.Series[i].ClassType);
    liSeries := liSeriesClass.Create(FDBChart);
    liSeries.Assign(aChart.Series[i]);
    FDBChart.AddSeries(liSeries);
  end;

  FDBChart.Name := '';
  for i := 0 to FDBChart.SeriesList.Count - 1 do
    FDBChart.SeriesList[i].Name := '';
  Memo.Clear;
  FPicture.Clear;
end;

procedure TRMDBChartView.ShowChart;
var
  i: Integer;
  lMetafile: TMetafile;
  lBitmap: TBitmap;
  lChartSeries: TRMDBChartSeries;
  lFlag: Boolean;

  procedure _SetChartProp;
  begin
    FDBChart.View3D := ChartDim3D;
    FDBChart.Legend.Visible := ChartShowLegend;
    FDBChart.AxisVisible := ChartShowAxis;
    if not UseChartSetting then
    begin
      FDBChart.RemoveAllSeries;
      FDBChart.Frame.Visible := False;
      FDBChart.LeftWall.Brush.Style := bsClear;
      FDBChart.BottomWall.Brush.Style := bsClear;

      FDBChart.Legend.Font.Charset := rmCharset;
      FDBChart.BottomAxis.LabelsFont.Charset := rmCharset;
      FDBChart.LeftAxis.LabelsFont.Charset := rmCharset;
      FDBChart.TopAxis.LabelsFont.Charset := rmCharset;
      FDBChart.BottomAxis.LabelsFont.Charset := rmCharset;
{$IFDEF COMPILER4_UP}
      FDBChart.BackWall.Brush.Style := bsClear;
      FDBChart.View3DOptions.Elevation := 315;
      FDBChart.View3DOptions.Rotation := 360;
{$ENDIF}
    end;
  end;

  procedure _PaintChart;
  var
    SaveDx, SaveDy: Integer;
  begin
    if FillColor = clNone then
      DBChart.Color := clWhite
    else
      DBChart.Color := FillColor;

    SaveDX := RMToScreenPixels(mmSaveWidth, rmutMMThousandths);
    SaveDY := RMToScreenPixels(mmSaveHeight, rmutMMThousandths);
    case FPrintType of
      rmptMetafile:
        begin
          lMetafile := DBChart.TeeCreateMetafile(True {False}, Rect(0, 0, SaveDX, SaveDY));
          try
            RMPrintGraphic(Canvas, RealRect, lMetafile, IsPrinting, DirectDraw, False);
          finally
            lMetafile.Free;
          end;
        end;
      rmptBitmap:
        begin
          lBitmap := TBitmap.Create;
          try
            lBitmap.Width := SaveDX;
            lBitmap.Height := SaveDY;
            DBChart.Draw(lBitmap.Canvas, Rect(0, 0, SaveDX, SaveDY));
            RMPrintGraphic(Canvas, RealRect, lBitmap, IsPrinting, DirectDraw, False);
          finally
            lBitmap.Free;
          end;
        end;
    end;
  end;

  procedure _AddSeries(const aIndex: Integer);
  var
    lSeries: TChartSeries;
    lDataSet: TRMDataSet;
    lStr: string;
  begin
    FDBChart.View3DWalls := lChartSeries.ChartType <> 5;
{$IFDEF COMPILER4_UP}
    FDBChart.View3DOptions.Orthogonal := lChartSeries.ChartType <> 5;
{$ENDIF}

    if UseChartSetting and (aIndex < FDBChart.SeriesCount) then
      lSeries := FDBChart.SeriesList[aIndex]
    else
      lSeries := ChartTypes[lChartSeries.ChartType].Create(FDBChart);

    lSeries.Title := lChartSeries.Title;
    lSeries.ColorEachPoint := lChartSeries.Colored;
    lSeries.SeriesColor := lChartSeries.Color;
    lSeries.Marks.Visible := lChartSeries.ShowMarks;
    lSeries.Marks.Style := TSeriesMarksStyle(lChartSeries.MarksStyle);
    lSeries.Marks.Font.Charset := rmCharset;

    if UseChartSetting and (aIndex < FDBChart.SeriesCount) then
    begin
//      lSeries.Clear;
    end
    else
    begin
      FDBChart.AddSeries(lSeries);
    end;

		lDataSet := ParentReport.Dictionary.FindDataSet(ParentReport.Dictionary.RealDataSetName[lChartSeries.DataSet],
    	ParentReport.Owner, lStr);
    if (lDataSet is TRMDBDataSet) and (TRMDBDataSet(lDataSet).DataSet <> nil) then
    begin
      lSeries.DataSource := TRMDBDataSet(lDataSet).DataSet;
      try
        lSeries.XValues.ValueSource := ParentReport.Dictionary.RealFieldName[TRMDBDataSet(lDataSet), lChartSeries.LegendView];
        lSeries.YValues.ValueSource := ParentReport.Dictionary.RealFieldName[TRMDBDataSet(lDataSet), lChartSeries.ValueView];
        lSeries.XLabelsSource := ParentReport.Dictionary.RealFieldName[TRMDBDataSet(lDataSet), lChartSeries.LabelView];
      except
        lChartSeries.LegendView := '';
        lChartSeries.ValueView := '';
        lChartSeries.LabelView := '';
      end;
    end;
  end;

begin
  lFlag := True;
  for i := 0 to FList.Count - 1 do
  begin
    lChartSeries := Series[i];
    if (lChartSeries.DataSet <> '') and ((lChartSeries.LegendView <> '') or
      (lChartSeries.ValueView <> '')) then
    begin
      lFlag := False;
      Break;
    end;
  end;

  if lFlag and (Memo.Count = 0) then
  begin
    if FPicture.Width = 0 then
      _PaintChart
    else
      Canvas.StretchDraw(RealRect, FPicture);
    Exit;
  end;

  if FList.Count < 1 then Exit;

  _SetChartProp;
  for i := 0 to FList.Count - 1 do
  begin
    lChartSeries := Series[i];
    _AddSeries(i);
  end;

  //FDBChart.RefreshData;
  _PaintChart;
end;

procedure TRMDBChartView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  CalcGaps;
  ShowBackground;
  ShowChart;
  ShowFrame;
  RestoreCoord;
end;

procedure TRMDBChartView.PlaceOnEndPage(aStream: TStream);
begin
  inherited PlaceOnEndPage(aStream);
  Memo.Text := '';
end;

procedure TRMDBChartView.LoadFromStream(aStream: TStream);
var
  b: Byte;
  liStream: TMemoryStream;
  i, liCount: Integer;
  liSeries: TRMDBChartSeries;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);

  Clear;
  FPicture.Clear;
  ChartDim3D := RMReadBoolean(aStream);
  ChartShowLegend := RMReadBoolean(aStream);
  ChartShowAxis := RMReadBoolean(aStream);
  FPrintType := TRMPrintMethodType(RMReadByte(aStream));
  liCount := RMReadWord(aStream);
  for i := 1 to liCount do
  begin
    liSeries := AddSeries;
    liSeries.DataSet := RMReadString(aStream);
    liSeries.LegendView := RMReadString(aStream);
    liSeries.ValueView := RMReadString(aStream);
    liSeries.LabelView := RMReadString(aStream);
    liSeries.Title := RMReadString(aStream);
    liSeries.Color := RMReadInt32(aStream);
    liSeries.ChartType := RMReadByte(aStream);
    liSeries.ShowMarks := RMReadBoolean(aStream);
    liSeries.Colored := RMReadBoolean(aStream);
    liSeries.MarksStyle := RMReadByte(aStream);
  end;

  b := RMReadByte(aStream);
  if b = 1 then
  begin
    liStream := TMemoryStream.Create;
    try
      liStream.CopyFrom(aStream, RMReadInt32(aStream));
      liStream.Position := 0;
      FPicture.LoadFromStream(liStream);
    finally
      liStream.Free;
    end;
  end;

  b := RMReadByte(aStream);
  if b = 1 then
  begin
    FDBChart.Free;
    FDBChart := TDBChart.Create(RMDialogForm);
    with FDBChart do
    begin
      Parent := RMDialogForm;
      Visible := False;
      BevelInner := bvNone;
      BevelOuter := bvNone;
    end;

    liStream := TMemoryStream.Create;
    try
      liStream.CopyFrom(aStream, RMReadInt32(aStream));
      liStream.Position := 0;
      liStream.ReadComponent(FDBChart);
      FDBChart.Name := '';
      for i := 0 to FDBChart.SeriesList.Count - 1 do
        FDBChart.SeriesList[i].Name := '';
    finally
      liStream.Free;
    end;
  end;
end;

procedure TRMDBChartView.SaveToStream(aStream: TStream);
var
  liStream: TMemoryStream;
  liEMF: TMetafile;
  i: Integer;
  liFlag: Boolean;
  liSeries: TRMDBChartSeries;
  liSavePos, liSavePos1, liPos: Integer;
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);

  liFlag := True;
  for i := 0 to FList.Count - 1 do
  begin
    liSeries := Series[i];
    if (liSeries.LegendView <> '') or (liSeries.ValueView <> '') then
    begin
      liFlag := False;
      Break;
    end;
  end;

  RMWriteBoolean(aStream, ChartDim3D);
  RMWriteBoolean(aStream, ChartShowLegend);
  RMWriteBoolean(aStream, ChartShowAxis);
  RMWriteByte(aStream, Byte(FPrintType));
  RMWriteWord(aStream, FList.Count);
  for i := 0 to FList.Count - 1 do
  begin
    RMWriteString(aStream, Series[i].DataSet);
    RMWriteString(aStream, Series[i].LegendView);
    RMWriteString(aStream, Series[i].ValueView);
    RMWriteString(aStream, Series[i].LabelView);
    RMWriteString(aStream, Series[i].Title);
    RMWriteInt32(aStream, Series[i].Color);
    RMWriteByte(aStream, Series[i].ChartType);
    RMWriteBoolean(aStream, Series[i].ShowMarks);
    RMWriteBoolean(aStream, Series[i].Colored);
    RMWriteByte(aStream, Series[i].MarksStyle);
  end;

  if liFlag and (Memo.Count = 0) then
  begin
    RMWriteByte(aStream, 1);
    liStream := TMemoryStream.Create;
    liEMF := nil;
    try
      liEMF := FDBChart.TeeCreateMetafile(FALSE, Rect(0, 0, spWidth, spHeight));
      liEMF.SaveToStream(liStream);

      liStream.Position := 0;
      RMWriteInt32(aStream, liStream.Size);
      aStream.CopyFrom(liStream, 0);
    finally
      liStream.Free;
      if liEMF <> nil then liEMF.Free;
    end;
  end
  else
    RMWriteByte(aStream, 0);

  if UseChartSetting then
  begin
    FDBChart.Name := '';
    for i := 0 to FDBChart.SeriesList.Count - 1 do
      FDBChart.SeriesList[i].Name := '';

    RMWriteByte(aStream, 1);
    liSavePos := aStream.Position;
    RMWriteInt32(aStream, liSavePos);
    liSavePos1 := aStream.Position;
    aStream.WriteComponent(FDBChart);
    liPos := aStream.Position;
    aStream.Position := liSavePos;
    RMWriteInt32(aStream, liPos - liSavePos1);
    aStream.Position := liPos;
  end
  else
    RMWriteByte(aStream, 0);
end;

procedure TRMDBChartView.DefinePopupMenu(Popup: TRMCustomMenuItem);
begin
  inherited DefinePopupMenu(Popup);
end;

procedure TRMDBChartView.Prepare;
begin
  Memo.Clear;
end;

procedure TRMDBChartView.ShowEditor;
var
  tmpForm: TRMDBChartForm;
  liStream: TMemoryStream;
begin
  liStream := TMemoryStream.Create;
  tmpForm := TRMDBChartForm.Create(Application);
  try
    SaveToStream(liStream);
    liStream.Position := 0;
//    RMVersion := RMCurrentVersion;
    tmpForm.FReport := ParentReport;
    tmpForm.FChartView.LoadFromStream(liStream);
    if tmpForm.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      liStream.Clear;
      tmpForm.FChartView.SaveToStream(liStream);
      liStream.Position := 0;
//      RMVersion := RMCurrentVersion;
      LoadFromStream(liStream);
      RMDesigner.AfterChange;
    end;
  finally
    liStream.Free;
    tmpForm.Free;
  end;
end;

function TRMDBChartView.GetUseChartSetting: Boolean;
begin
  Result := FFlags and flChartUseChartSetting = flChartUseChartSetting;
end;

procedure TRMDBChartView.SetUseChartSetting(Value: Boolean);
begin
  FFlags := FFlags and (not flChartUseChartSetting);
//{$IFDEF TeeChartPro}
  if Value then
    FFlags := FFlags + flChartUseChartSetting;
//{$ENDIF}
end;

function TRMDBChartView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flChartDirectDraw) = flChartDirectDraw;
end;

procedure TRMDBChartView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flChartDirectDraw);
  if Value then
    FFlags := FFlags + flChartDirectDraw;
end;

function TRMDBChartView.GetViewCommon: string;
begin
  Result := '[DBChart]';
end;

procedure TRMDBChartView.ClearContents;
begin
  Clear;
  inherited;
end;

function TRMDBChartView.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'DBChart' then
  begin
    aValue := O2V(FDBChart);
  end
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomDBTeeChartUI }

class procedure TRMCustomDBTeeChartUI.Edit(aTeeChart: TCustomChart);
begin
end;

{******************************************************************************
 *
 ** C H A R T   U I   P L U G I N
 *
{******************************************************************************}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMTeeChartUIPlugIn}

class procedure TRMTeeChartUIPlugIn.Register(aChartUIClass: TRMCustomDBTeeChartUIClass);
begin
//  uChartUIPlugInLock.Acquire;
  try
    uDBChartUIClassList.Add(aChartUIClass);
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class procedure TRMTeeChartUIPlugIn.UnRegister(aChartUIClass: TRMCustomDBTeeChartUIClass);
begin
//  uChartUIPlugInLock.Acquire;
  try
    uDBChartUIClassList.Remove(aChartUIClass);
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class function TRMTeeChartUIPlugIn.GetChartUIClass(aTeeChart: TCustomChart): TRMCustomDBTeeChartUIClass;
begin
//  uChartUIPlugInLock.Acquire;
  try
    if uDBChartUIClassList.Count > 0 then
      Result := TRMCustomDBTeeChartUIClass(uDBChartUIClassList[0])
    else
      Result := nil;
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class procedure TRMTeeChartUIPlugIn.Edit(aTeeChart: TCustomChart);
var
  lChartUIClass: TRMCustomDBTeeChartUIClass;
begin
  lChartUIClass := GetChartUIClass(aTeeChart);
  if (lChartUIClass <> nil) then
    lChartUIClass.Edit(aTeeChart);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMChartForm }

procedure SetControlsEnabled(aControl: TWinControl; aEnabled: Boolean);
var
  i: Integer;
begin
  for i := 0 to aControl.ControlCount - 1 do
  begin
    aControl.Controls[i].Enabled := aEnabled;
  end;
end;

procedure TRMDBChartForm.FormCreate(Sender: TObject);
begin
  FDataSetBMP := TBitmap.Create;
  FFieldBMP := TBitmap.Create;

  FDataSetBMP.LoadFromResourceName(hInstance, 'RM_FLD1');
  FFieldBMP.LoadFromResourceName(hInstance, 'RM_FLD2');


  Page1.ActivePage := TabSheet1;
  FBtnColor := TRMColorPickerButton.Create(Self);
  FBtnColor.Parent := gpbSeriesOptions;
  FBtnColor.SetBounds(120, 34, 115, 25);

  cmbLegend.Items.Clear;
  cmbValue.Items.Assign(cmbLegend.Items);
  cmbLabel.Items.Assign(cmbLegend.Items);
  FChartView := TRMDBChartView(RMCreateObject(rmgtAddin, 'TRMDBChartView'));
  Localize;
end;

procedure TRMDBChartForm.FormDestroy(Sender: TObject);
begin
  FChartView.Free;

  FDataSetBMP.Free;
  FFieldBMP.Free;
end;

procedure TRMDBChartForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 590);
  RMSetStrProp(Tab1, 'Caption', rmRes + 591);
  RMSetStrProp(Tab2, 'Caption', rmRes + 592);
  RMSetStrProp(Tab3, 'Caption', rmRes + 604);
  RMSetStrProp(TabSheet1, 'Caption', rmRes + 597);
  RMSetStrProp(gpbSeriesType, 'Caption', rmRes + 593);
  RMSetStrProp(gpbObjects, 'Caption', rmRes + 594);
  RMSetStrProp(gpbSeriesOptions, 'Caption', rmRes + 595);
  RMSetStrProp(gpbMarks, 'Caption', rmRes + 605);
  RMSetStrProp(gpbChartOptions, 'Caption', rmRes + 595);

  RMSetStrProp(chkChartDim3D, 'Caption', rmRes + 596);
  RMSetStrProp(chkChartShowLegend, 'Caption', rmRes + 598);
  RMSetStrProp(chkChartShowAxis, 'Caption', rmRes + 599);

  RMSetStrProp(chkSeriesShowMarks, 'Caption', rmRes + 600);
  RMSetStrProp(chkSeriesMultiColor, 'Caption', rmRes + 601);

  RMSetStrProp(rdbStyle1, 'Caption', rmRes + 606);
  RMSetStrProp(rdbStyle2, 'Caption', rmRes + 607);
  RMSetStrProp(rdbStyle3, 'Caption', rmRes + 608);
  RMSetStrProp(rdbStyle4, 'Caption', rmRes + 609);
  RMSetStrProp(rdbStyle5, 'Caption', rmRes + 610);

  RMSetStrProp(Label1, 'Caption', rmRes + 602);
  RMSetStrProp(Label2, 'Caption', rmRes + 603);
  RMSetStrProp(Label6, 'Caption', rmRes + 622);
  RMSetStrProp(Label7, 'Caption', rmRes + 621);

  RMSetStrProp(Add1, 'Caption', rmRes + 616);
  RMSetStrProp(Delete1, 'Caption', rmRes + 617);
  RMSetStrProp(EditTitle1, 'Caption', rmRes + 618);
  RMSetStrProp(MoveUp1, 'Caption', rmRes + 619);
  RMSetStrProp(MoveDown1, 'Caption', rmRes + 620);

  cmbSeriesType.Items.Clear;
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 624));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 625));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 626));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 627));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 628));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 629));

  RMSetStrProp(cmbValue, 'Hint', rmRes + 630);
  RMSetStrProp(cmbLegend, 'Hint', rmRes + 630);

  RMSetStrProp(Button1, 'Caption', rmRes + 623);
  btnOk.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDBChartForm.LoadSeriesOptions;

  procedure _SetRButton(b: array of TRadioButton; n: Integer);
  begin
    if (n >= Low(b)) and (n <= High(b)) then
      b[n].Checked := True;
  end;

begin
  SetControlsEnabled(gpbChartOptions, FSeries <> nil);
  SetControlsEnabled(gpbSeriesType, FSeries <> nil);
  SetControlsEnabled(gpbSeriesOptions, FSeries <> nil);
  SetControlsEnabled(gpbObjects, FSeries <> nil);
  SetControlsEnabled(gpbSeriesType, FSeries <> nil);

  chkChartShowLegend.Checked := FChartView.ChartShowLegend;
  chkChartShowAxis.Checked := FChartView.ChartShowAxis;
  chkChartDim3D.Checked := FChartView.ChartDim3D;

  if FSeries = nil then Exit;

  cmbSeriesType.ItemIndex := FSeries.ChartType;
  _SetRButton([rdbStyle1, rdbStyle2, rdbStyle3, rdbStyle4, rdbStyle5], FSeries.MarksStyle);
  chkSeriesShowMarks.Checked := FSeries.ShowMarks;
  chkSeriesMultiColor.Checked := FSeries.Colored;
  cmbLegend.Text := FSeries.LegendView;
  cmbValue.Text := FSeries.ValueView;
  cmbLabel.Text := FSeries.LabelView;
  FBtnColor.CurrentColor := Fseries.Color;
  FBtnColor.Enabled := not chkSeriesMultiColor.Checked;

  cmbDataSet.ItemIndex := cmbDataSet.Items.IndexOf(FSeries.DataSet);
  cmbDataSetChange(nil);
  cmbLegend.ItemIndex := cmbLegend.Items.IndexOf(FSeries.LegendView);
  cmbValue.ItemIndex := cmbValue.Items.IndexOf(FSeries.ValueView);
  cmbLabel.ItemIndex := cmbLabel.Items.IndexOf(FSeries.LabelView);
end;

procedure TRMDBChartForm.SaveSeriesOptions;

  function _GetRButton(b: array of TRadioButton): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to High(b) do
    begin
      if b[i].Checked then
        Result := i;
    end;
  end;

begin
  FChartView.ChartShowLegend := chkChartShowLegend.Checked;
  FChartView.ChartShowAxis := chkChartShowAxis.Checked;
  FChartView.ChartDim3D := chkChartDim3D.Checked;

  if FSeries = nil then Exit;

  if cmbSeriesType.ItemIndex >= 0 then
    FSeries.ChartType := cmbSeriesType.ItemIndex;
  FSeries.MarksStyle := _GetRButton([rdbStyle1, rdbStyle2, rdbStyle3, rdbStyle4, rdbStyle5]);
  FSeries.ShowMarks := chkSeriesShowMarks.Checked;
  FSeries.Colored := chkSeriesMultiColor.Checked;

  Fseries.Color := FBtnColor.CurrentColor;
  FSeries.DataSet := cmbDataSet.Text;
  FSeries.LegendView := cmbLegend.Text;
  FSeries.ValueView := cmbValue.Text;
  FSeries.LabelView := cmbLabel.Text;
end;

procedure TRMDBChartForm.Add1Click(Sender: TObject);
begin
  SaveSeriesOptions;
  FSeries := FChartView.AddSeries;
  ListBox1.Items.Add(FSeries.Title);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  LoadSeriesOptions;
end;

procedure TRMDBChartForm.Delete1Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then
  begin
    FChartView.DeleteSeries(ListBox1.ItemIndex);
    ListBox1.Items.Delete(ListBox1.ItemIndex);
    ListBox1.ItemIndex := 0;
    if ListBox1.ItemIndex >= 0 then
      FSeries := FChartView.Series[ListBox1.ItemIndex]
    else
      FSeries := nil;
    LoadSeriesOptions;
  end;
end;

procedure TRMDBChartForm.FormShow(Sender: TObject);
var
  i: Integer;

  procedure _GetDatasets;
  begin
    cmbDataSet.Items.BeginUpdate;
    FReport.Dictionary.GetDataSets(cmbDataSet.Items);
    cmbDataSet.Items.Insert(0, RMLoadStr(SNotAssigned));
    cmbDataSet.Items.EndUpdate;
  end;

begin
  _GetDataSets;

  Button1.Visible := FChartView.UseChartSetting;
  Tab1.TabVisible := not Button1.Visible;
  Tab3.TabVisible := not Button1.Visible;

  ListBox1.Clear;
  for i := 0 to FChartView.SeriesCount - 1 do
  begin
    ListBox1.Items.Add(FChartView.Series[i].Title);
  end;
  ListBox1.ItemIndex := 0;
  if ListBox1.ItemIndex >= 0 then
    FSeries := FChartView.Series[0]
  else
    FSeries := nil;
  LoadSeriesOptions;
end;

procedure TRMDBChartForm.ListBox1Click(Sender: TObject);
begin
  SaveSeriesOptions;
  if ListBox1.ItemIndex >= 0 then
    FSeries := FChartView.Series[ListBox1.ItemIndex]
  else
    FSeries := nil;
  LoadSeriesOptions;
end;

procedure TRMDBChartForm.PopupMenu1Popup(Sender: TObject);
begin
  Add1.Enabled := (not Button1.Visible);
  Delete1.Enabled := (FSeries <> nil) and (not Button1.Visible);
  EditTitle1.Enabled := (FSeries <> nil) and (not Button1.Visible);
  MoveUp1.Enabled := (FSeries <> nil) and (not Button1.Visible);
  MoveDown1.Enabled := (FSeries <> nil) and (not Button1.Visible);
end;

procedure TRMDBChartForm.MoveUp1Click(Sender: TObject);
var
  liIndex: Integer;
begin
  liIndex := ListBox1.ItemIndex;
  if liIndex > 0 then
  begin
    ListBox1.Items.Exchange(liIndex, liIndex - 1);
    FChartView.FList.Exchange(liIndex, liIndex - 1);
  end;
end;

procedure TRMDBChartForm.MoveDown1Click(Sender: TObject);
var
  liIndex: Integer;
begin
  liIndex := ListBox1.ItemIndex;
  if liIndex < ListBox1.Items.Count - 1 then
  begin
    ListBox1.Items.Exchange(liIndex, liIndex + 1);
    FChartView.FList.Exchange(liIndex, liIndex + 1);
  end;
end;

procedure TRMDBChartForm.btnOkClick(Sender: TObject);
begin
  SaveSeriesOptions;
end;

procedure TRMDBChartForm.EditTitle1Click(Sender: TObject);
begin
  if FSeries = nil then Exit;
  FSeries.Title := InputBox('', '', FSeries.Title);
  ListBox1.Items[ListBox1.ItemIndex] := FSeries.Title;
end;

procedure TRMDBChartForm.chkSeriesMultiColorClick(Sender: TObject);
begin
  FBtnColor.Enabled := not chkSeriesMultiColor.Checked;
end;

procedure TRMDBChartForm.Button1Click(Sender: TObject);
var
  i, lCount: Integer;
begin
  SaveSeriesOptions;

  FChartView.DBChart.View3D := FChartView.ChartDim3D;
  FChartView.DBChart.Legend.Visible := FChartView.ChartShowLegend;
  FChartView.DBChart.AxisVisible := FChartView.ChartShowAxis;

  TRMTeeChartUIPlugIn.Edit(FChartView.DBChart);

  FChartView.ChartDim3D := FChartView.DBChart.View3D;
  FChartView.ChartShowLegend := FChartView.DBChart.Legend.Visible;
  FChartView.ChartShowAxis := FChartView.DBChart.AxisVisible;

  lCount := FChartView.SeriesCount - FChartView.DBChart.SeriesCount - 1;
  for i := 0 to lCount do
  begin
    FChartView.DeleteSeries(FChartView.SeriesCount - 1);
  end;

  lCount := FChartView.DBChart.SeriesCount - FChartView.SeriesCount - 1;
  for i := 0 to lCount do
  begin
    FChartView.AddSeries;
  end;

  ListBox1.Items.Clear;
  for i := 0 to FChartView.SeriesCount - 1 do
  begin
    ListBox1.Items.Add(FChartView.Series[i].Title);
  end;
  ListBox1.ItemIndex := 0;
  if ListBox1.ItemIndex >= 0 then
    FSeries := FChartView.Series[0]
  else
    FSeries := nil;
  LoadSeriesOptions;
end;

procedure TRMDBChartForm.cmbSeriesTypeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  liBitmap: TBitmap;
begin
  s := cmbSeriesType.Items[Index];
  liBitmap := TBitmap.Create;
  try
    ImageList1.GetBitmap(Index, liBitmap);
    cmbSeriesType.Canvas.FillRect(Rect);
    cmbSeriesType.Canvas.BrushCopy(
      Bounds(Rect.Left + 4, Rect.Top, liBitmap.Width, liBitmap.Height),
      liBitmap,
      Bounds(0, 0, liBitmap.Width, liBitmap.Height),
      liBitmap.TransparentColor);
    cmbSeriesType.Canvas.TextOut(Rect.Left + 10 + liBitmap.Width, Rect.Top + (Rect.Bottom - Rect.Top - cmbSeriesType.Canvas.TextHeight(s)) div 2, s);
  finally
    liBitmap.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMChartView_AssignChart(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMDBChartView(Args.Obj).AssignChart(TDBChart(V2O(Args.Values[0])));
end;

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TDBChart, 'TDBChart');
    AddClass('ReportMachine', TRMDBChartView, 'TRMDBChartView');

    AddGet(TRMDBChartView, 'AssignChart', TRMChartView_AssignChart, 1, [0], varEmpty)
  end;
end;

procedure TRMDBChartForm.cmbDataSetChange(Sender: TObject);
begin
  if cmbDataSet.ItemIndex < 1 then
  begin
    cmbLegend.Items.Clear;
    cmbValue.Items.Clear;
    cmbLabel.Items.Clear;
    Exit;
  end;

  FReport.Dictionary.GetDataSetFields(cmbDataSet.Items[cmbDataSet.ItemIndex], cmbLegend.Items);
  cmbValue.Items.Assign(cmbLegend.Items);
  cmbLabel.Items.Assign(cmbLegend.Items);
end;

procedure TRMDBChartForm.cmbDataSetDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  lBmp: TBitmap;
begin
  with TComboBox(Control) do
  begin
    s := Items[Index];
    if Control = cmbDataSet then
      lBmp := FDataSetBMP
    else
      lBmp := FFieldBMP;

    Canvas.FillRect(Rect);
    Canvas.BrushCopy(
      Bounds(Rect.Left + 2, Rect.Top, lBmp.Width, lBmp.Height),
      lBmp,
      Bounds(0, 0, lBmp.Width, lBmp.Height),
      lBmp.TransparentColor);
    Canvas.TextOut(Rect.Left + 4 + lBmp.Width, Rect.Top, s);
  end;
end;

initialization
  uDBChartUIClassList := TList.Create;
  RMRegisterObjectByRes(TRMDBChartView, 'RM_DBCHAROBJECT', RMLoadStr(rmRes + 2503), TRMDBChartForm);

  RMInterpreter_Chart.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization
  uDBChartUIClassList.Free;
  uDBChartUIClassList := nil;
{$ENDIF}
end.

