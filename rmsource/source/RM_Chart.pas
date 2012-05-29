
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{           Chart Add-In Object           }
{                                         }
{*****************************************}

unit RM_Chart;

interface

{$I RM.inc}

{$IFDEF TeeChart}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, Buttons, ImgList, RM_Common, RM_Class, RM_Ctrls,
  RM_DataSet, TeeProcs, TeEngine, Chart, Series, GanttCh, DB, RM_PropInsp
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}
  , Variants
{$ENDIF};

type

  TRMChartObject = class(TComponent) // fake component
  end;

  TRMChartSeriesDataType = (rmdtBandData, rmdtDBData, rmdtFixedData);
  TRMChartSeriesSortOrder = (rmsoNone, rmsoAscending, rmsoDescending);

  { TRMChartSeries }
  TRMChartSeries = class(TPersistent)
  private
    FXValues: array of Variant;
    FYValues: array of Variant;
    FXObject, FYObject, FTop10Label: string;
    FTitle: string;
    FColor: TColor;
    FChartType: Byte;
    FShowMarks, FColored: Boolean;
    FMarksStyle: Byte;
    FTop10Num: Integer;
    FDataType: TRMChartSeriesDataType;
    FSortOrder: TRMChartSeriesSortOrder;
    FDataSet: string;
  protected
  public
    constructor Create;
    procedure Init;
    procedure GetData(aReport: TRMReport);
  published
    property DataSet: string read FDataSet write FDataSet;
    property XObject: string read FXObject write FXObject;
    property YObject: string read FYObject write FYObject;
    property Top10Label: string read FTop10Label write FTop10Label;
    property Title: string read FTitle write FTitle;
    property Color: TColor read FColor write FColor;
    property ChartType: Byte read FChartType write FChartType;
    property ShowMarks: Boolean read FShowMarks write FShowMarks;
    property Colored: Boolean read FColored write FColored;
    property MarksStyle: Byte read FMarksStyle write FMarksStyle;
    property Top10Num: Integer read FTop10Num write FTop10Num;
    property DataType: TRMChartSeriesDataType read FDataType write FDataType;
    property SortOrder: TRMChartSeriesSortOrder read FSortOrder write FSortOrder;
    property XValues: string read FXObject write FXObject;
    property YValues: string read FYObject write FYObject;
  end;

  {TRMChartView}
  TRMChartView = class(TRMReportView)
  private
    FPrintType: TRMPrintMethodType;
    FChart: TChart;
    FPicture: TMetafile;
    FSeriesList: TList;
    FChartDim3D, FChartShowLegend, FChartShowAxis: Boolean;
    FSaveMemo: string;

    procedure ShowChart;
    function GetUseChartSetting: Boolean;
    procedure SetUseChartSetting(Value: Boolean);
    function GetSeries(Index: Integer): TRMChartSeries;
    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
  protected
    procedure Prepare; override;
    procedure PlaceOnEndPage(aStream: TStream); override;
    procedure GetEndPageData(aStream: TStream); override;
    function GetViewCommon: string; override;
    procedure ClearContents; override;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    procedure OnHook(aView: TRmView); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear;
    function SeriesCount: Integer;
    function AddSeries: TRMChartSeries;
    procedure DeleteSeries(Index: Integer);

    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure DefinePopupMenu(Popup: TRMCustomMenuItem); override;
    procedure ShowEditor; override;
    procedure AssignChart(AChart: TCustomChart);
    property Series[Index: Integer]: TRMChartSeries read GetSeries;
    property Chart: TChart read FChart;
  published
    property PrintType: TRMPrintMethodType read FPrintType write FPrintType;
    property UseChartSetting: Boolean read GetUseChartSetting write SetUseChartSetting;
    property UseDoublePass;
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
  TRMChartForm = class(TForm)
    Page1: TPageControl;
    btnOk: TButton;
    btnCancel: TButton;
    Tab3: TTabSheet;
    gpbMarks: TGroupBox;
    rdbStyle1: TRadioButton;
    rdbStyle2: TRadioButton;
    rdbStyle3: TRadioButton;
    rdbStyle4: TRadioButton;
    rdbStyle5: TRadioButton;
    TabSheet1: TTabSheet;
    btnCharUI: TButton;
    rdbDataSource: TRadioGroup;
    rdbSortType: TRadioGroup;
    GroupBox3: TGroupBox;
    btnAddSeries: TSpeedButton;
    btnDeleteSeries: TSpeedButton;
    TreeView1: TTreeView;
    Panel1: TPanel;
    ImageList2: TImageList;
    PopupSeries: TPopupMenu;
    mnuLine: TMenuItem;
    mnuArea: TMenuItem;
    mnuPoint: TMenuItem;
    mnuBar: TMenuItem;
    mnuHorizBar: TMenuItem;
    mnuPie: TMenuItem;
    mnuGantt: TMenuItem;
    mnuFastLine: TMenuItem;
    gpbChartOptions: TGroupBox;
    chkChartShowLegend: TCheckBox;
    chkChartShowAxis: TCheckBox;
    chkChartDim3D: TCheckBox;
    gpbSeriesType: TGroupBox;
    cmbSeriesType: TComboBox;
    gpbSeriesOptions: TGroupBox;
    chkSeriesMultiColor: TCheckBox;
    chkSeriesShowMarks: TCheckBox;
    gpbObjects: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    cmbLegend: TComboBox;
    cmbValue: TComboBox;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    cmbDataSet: TComboBox;
    GroupBox1: TGroupBox;
    lblXValue: TLabel;
    lblYValue: TLabel;
    edtXValues: TEdit;
    edtYValues: TEdit;
    gpbTopGroup: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    editTop10Num: TEdit;
    edtTop10Label: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCharUIClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbSeriesTypeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure rdbDataSourceClick(Sender: TObject);
    procedure cmbDataSetChange(Sender: TObject);
    procedure cmbDataSetDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure TreeView1Click(Sender: TObject);
    procedure mnuLineClick(Sender: TObject);
    procedure cmbSeriesTypeClick(Sender: TObject);
    procedure chkChartShowAxisClick(Sender: TObject);
    procedure TreeView1Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure TreeView1Edited(Sender: TObject; Node: TTreeNode;
      var S: String);
  private
    { Private declarations }
    FChartView: TRMChartView;
    FSeries: TRMChartSeries;
    FBtnColor: TRMColorPickerButton;
    FReport: TRMReport;
    FDataSetBMP, FFieldBMP: TBitmap;
    FInspector: TELPropertyInspector;
    FOldSelected: TTreeNode;

    procedure Localize;
    procedure SetInspControls;
    procedure LoadSeriesOptions;
    procedure SaveSeriesOptions;
    procedure SetSeriesType(aNode: TTreeNode; aChartType: Integer);
    procedure OnColorChangeEvent(Sender: TObject);
    procedure OnAfterModifyEvent(Sender: TObject; const aPropName, aPropValue: string);
    procedure SetTreeView;
  public
    { Public declarations }
  end;

  TRMCustomTeeChartUIClass = class of TRMCustomTeeChartUI;

  TRMCustomTeeChartUI = class
  public
    class procedure Edit(aTeeChart: TCustomChart); virtual;
  end;

  {TRMTeeChartUIPlugIn }
  TRMTeeChartUIPlugIn = class
  private
    class function GetChartUIClass: TRMCustomTeeChartUIClass;
  public
    class procedure Register(aChartUIClass: TRMCustomTeeChartUIClass);
    class procedure UnRegister(aChartUIClass: TRMCustomTeeChartUIClass);
    class procedure Edit(aTeeChart: TCustomChart);
    class function HaveChartEditor: Boolean;
  end; {class, TRMTeeChartUIPlugIn}
{$ENDIF}

implementation

{$IFDEF TeeChart}
uses
  Math, RM_Utils, RM_Const, RM_Const1, RMInterpreter_Chart;

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
  ChartTypes: array[0..7] of TSeriesClass =
  (TLineSeries, TAreaSeries, TPointSeries, TBarSeries, THorizBarSeries,
    TPieSeries, TGanttSeries, TFastLineSeries);

var
  uChartUIClassList: TList;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMChartSeries }

constructor TRMChartSeries.Create;
begin
  inherited Create;

  FColored := False;
  FYObject := '';
  FXObject := '';
  FTop10Label := '';
  FTop10Num := 0;
  FTitle := '';
  FColor := clTeeColor;
  FDataType := rmdtBandData;
  FSortOrder := rmsoNone;
end;

procedure TRMChartSeries.Init;
begin
  SetLength(FXValues, 0);
  SetLength(FYValues, 0);
end;

function _ExtractStr(const aStr: string; var aPos: Integer): string;
var
  i: Integer;
begin
  i := aPos;
  while (i <= Length(aStr)) and (aStr[i] <> ';') do
    Inc(i);

  Result := Copy(aStr, aPos, i - aPos);
  if (i <= Length(aStr)) and (aStr[i] = ';') then
    Inc(i);

  aPos := i;
end;

procedure TRMChartSeries.GetData(aReport: TRMReport);

  procedure _GetDataSetData;
  var
    lRMDataSet: TRMDataSet;
    lDataSet: TDataSet;
    lStr: string;
    lXField, lYField: TField;
  begin
    lRMDataSet := aReport.Dictionary.FindDataSet(aReport.Dictionary.RealDataSetName[FDataSet],
      aReport.Owner, lStr);
    if not (lRMDataSet is TRMDBDataSet) or (TRMDBDataSet(lRMDataSet).DataSet = nil) then Exit;

    lDataSet := TRMDBDataSet(lRMDataSet).DataSet;
    lStr := aReport.Dictionary.RealFieldName[lRMDataSet, XObject];
    if lStr <> '' then
      lXField := lDataSet.FieldByName(lStr)
    else
      lXField := nil;

    lStr := aReport.Dictionary.RealFieldName[lRMDataSet, YObject];
    if lStr <> '' then
      lYField := lDataSet.FieldByName(lStr)
    else
      lYField := nil;

    lDataSet.First;
    while not lDataSet.Eof do
    begin
      if lXField <> nil then
      begin
        SetLength(FXValues, Length(FXValues) + 1);
        FXValues[Length(FXValues) - 1] := lXField.AsString;
      end;

      if lYField <> nil then
      begin
        SetLength(FYValues, Length(FYValues) + 1);
        lStr := lYField.AsString;
        if RMIsValidFloat(lStr) then
          FYValues[Length(FYValues) - 1] := RMStrToFloat(lStr)
        else
          FYValues[Length(FYValues) - 1] := 0;
      end;

      lDataSet.Next;
    end;
  end;

  procedure _GetFixedData;
  var
    lPos: Integer;
    lStr, lStr1: string;
  begin
    lPos := 1;
    lStr := XObject;
    while lPos <= Length(lStr) do
    begin
      SetLength(FXValues, Length(FXValues) + 1);
      FXValues[Length(FXValues) - 1] := _ExtractStr(lStr, lPos);
    end;

    lPos := 1;
    lStr := YObject;
    while lPos <= Length(lStr) do
    begin
      lStr1 := _ExtractStr(lStr, lPos);
      SetLength(FYValues, Length(FYValues) + 1);
      if RMIsValidFloat(lStr1) then
        FYValues[Length(FYValues) - 1] := RMStrToFloat(lStr1)
      else
        FYValues[Length(FYValues) - 1] := 0;
    end;
  end;

  procedure _SortData;
  var
    i, lOffset: Integer;
    lStrList: TStringList;
  begin
    if SortOrder = rmsoNone then Exit;

    lStrList := TStringList.Create;
    try
      lStrList.Duplicates := dupAccept;
      for i := 0 to High(FYValues) do
      begin
        lStrList.Add(Format('%18.2f=%s', [Double(FYValues[i]), string(FXValues[i])]));
      end;

      lStrList.Sort;
      for i := 0 to High(FYValues) do
      begin
        if SortOrder = rmsoAscending then
          lOffset := i
        else
          lOffset := High(FYValues) - i;

        FYValues[lOffset] := RMStrToFloat(lStrList.Names[i]);
{$IFDEF COMPILER7_UP}
        FXValues[lOffset] := lStrList.ValueFromIndex[i];
{$ELSE}
        FXValues[lOffset] := lStrList.Values[lStrList.Names[i]];
{$ENDIF}
      end;
    finally
      lStrList.Free;
    end;
  end;

  procedure _SetTop10Value;
  var
    i: Integer;
    lTotalValue: Double;
  begin
    if (Top10Num < 1) or (Top10Num >= Length(FYValues)) or (Top10Label = '') then Exit;

    lTotalValue := 0;
    for i := Top10Num - 1 to High(FYValues) do
      lTotalValue := lTotalValue + FYValues[i];

    SetLength(FXValues, Top10Num);
    SetLength(FYValues, Top10Num);

    FXValues[Top10Num - 1] := Top10Label;
    FYValues[Top10Num - 1] := lTotalValue;
  end;

begin
  case DataType of
    rmdtDBData:
      begin
        Init;
        _GetDataSetData;
      end;
    rmdtBandData:
      begin
      end;
    rmdtFixedData:
      begin
        Init;
        _GetFixedData;
      end;
  end;

  if Length(FXValues) < Length(FYValues) then
    SetLength(FYValues, Length(FXValues))
  else if Length(FXValues) > Length(FYValues) then
    SetLength(FXValues, Length(FYValues));

  _SortData;
  _SetTop10Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMChartView }

constructor TRMChartView.Create;
begin
  inherited Create;
  BaseName := 'Chart';
  WantHook := True;
  UseChartSetting := False;

  FChart := TChart.Create(RMDialogForm);
  with FChart do
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
  FSeriesList := TList.Create;
end;

destructor TRMChartView.Destroy;
begin
  Clear;
  if RMDialogForm <> nil then
  begin
    FreeAndNil(FChart);
  end;

  FPicture.Free;
  FSeriesList.Free;
  inherited Destroy;
end;

procedure TRMChartView.Clear;
begin
  while FSeriesList.Count > 0 do
  begin
    TRMChartSeries(FSeriesList[0]).Free;
    FSeriesList.Delete(0);
  end;
end;

function TRMChartView.SeriesCount: Integer;
begin
  Result := FSeriesList.Count;
end;

function TRMChartView.AddSeries: TRMChartSeries;
var
  lSeries: TRMChartSeries;

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
      for j := 0 to FSeriesList.Count - 1 do
      begin
        if AnsiCompareText(Series[j].Title, listr) = 0 then
        begin
          liFlag := False;
          Break;
        end;
      end;

      if liFlag then
      begin
        lSeries.Title := listr;
        Break;
      end;
    end;
  end;

begin
  lSeries := TRMChartSeries.Create;
  _SetSeriesTitle;
  FSeriesList.Add(lSeries);
  Result := lSeries;
end;

procedure TRMChartView.DeleteSeries(Index: Integer);
begin
  if (Index >= 0) and (Index < FSeriesList.Count) then
  begin
    TRMChartSeries(FSeriesList[Index]).Free;
    FSeriesList.Delete(Index);
  end;
end;

function TRMChartView.GetSeries(Index: Integer): TRMChartSeries;
begin
  Result := nil;
  if (Index >= 0) and (Index < FSeriesList.Count) then
    Result := TRMChartSeries(FSeriesList[Index]);
end;

procedure TRMChartView.AssignChart(AChart: TCustomChart);
var
  lSeries: TChartSeries;
  lSeriesClass: TChartSeriesClass;
  i: Integer;
begin
  Clear;
  FChart.RemoveAllSeries;
  FChart.Assign(AChart);
  for i := 0 to AChart.SeriesCount - 1 do
  begin
    if not aChart.SeriesList[i].Active then Continue;

    lSeriesClass := TChartSeriesClass(AChart.Series[i].ClassType);
    lSeries := lSeriesClass.Create(FChart);
    lSeries.Assign(aChart.Series[i]);
    FChart.AddSeries(lSeries);
  end;

  FChart.Name := '';
  for i := 0 to FChart.SeriesList.Count - 1 do
    FChart.SeriesList[i].Name := '';

  Memo.Clear;
  FPicture.Clear;
end;

procedure TRMChartView.ShowChart;
var
  lChartSeries: TRMChartSeries;
  lXValues, lYValues: TStringList;

  procedure _SetChartProp;
  begin
    FChart.View3D := ChartDim3D;
    FChart.Legend.Visible := ChartShowLegend;
    FChart.AxisVisible := ChartShowAxis;
    if not UseChartSetting then
    begin
      //FChart.RemoveAllSeries;
      FChart.Frame.Visible := False;
      FChart.LeftWall.Brush.Style := bsClear;
      FChart.BottomWall.Brush.Style := bsClear;

      FChart.Legend.Font.Charset := rmCharset;
      FChart.BottomAxis.LabelsFont.Charset := rmCharset;
      FChart.LeftAxis.LabelsFont.Charset := rmCharset;
      FChart.TopAxis.LabelsFont.Charset := rmCharset;
      FChart.BottomAxis.LabelsFont.Charset := rmCharset;
{$IFDEF COMPILER4_UP}
      FChart.BackWall.Brush.Style := bsClear;
      FChart.View3DOptions.Elevation := 315;
      FChart.View3DOptions.Rotation := 360;
{$ENDIF}
    end;
  end;

  procedure _PaintChart;
  var
    lSaveDx, lSaveDy: Integer;
    lMetafile: TMetafile;
    lBitmap: TBitmap;
  begin
    if FillColor = clNone then
      Chart.Color := clWhite
    else
      Chart.Color := FillColor;

    lSaveDX := RMToScreenPixels(mmSaveWidth, rmutMMThousandths);
    lSaveDY := RMToScreenPixels(mmSaveHeight, rmutMMThousandths);
    case FPrintType of
      rmptMetafile:
        begin
          lMetafile := Chart.TeeCreateMetafile(True {False}, Rect(0, 0, lSaveDX, lSaveDY));
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
            lBitmap.Width := lSaveDX;
            lBitmap.Height := lSaveDY;
            Chart.Draw(lBitmap.Canvas, Rect(0, 0, lSaveDX, lSaveDY));
            RMPrintGraphic(Canvas, RealRect, lBitmap, IsPrinting, DirectDraw, False);
          finally
            lBitmap.Free;
          end;
        end;
    end;
  end;

  procedure _AddSeries(aIndex: Integer; aHaveLabel: Boolean);
  var
    i, lCount: Integer;
    lSeries: TChartSeries;

    procedure _SetSeriesType;
    begin
      if UseChartSetting or (aIndex < Chart.SeriesCount) then
        lSeries := Chart.SeriesList[aIndex]
      else
      begin
        lSeries := ChartTypes[lChartSeries.ChartType].Create(Chart);
        Chart.AddSeries(lSeries);

        lSeries.Title := lChartSeries.Title;
        lSeries.ColorEachPoint := lChartSeries.Colored;
        lSeries.Marks.Visible := lChartSeries.ShowMarks;
        lSeries.Marks.Style := TSeriesMarksStyle(lChartSeries.MarksStyle);
      end;

      lSeries.Clear;
      Chart.View3DWalls := lChartSeries.ChartType <> 5;
      lSeries.Marks.Font.Charset := rmCharset;
  {$IFDEF COMPILER4_UP}
      Chart.View3DOptions.Orthogonal := lChartSeries.ChartType <> 5;
  {$ENDIF}
    end;

  begin
    _SetSeriesType;
    lCount := Min(lXValues.Count, lYValues.Count);
    for i := 0 to lCount - 1 do
    begin
      if aHaveLabel then
      begin
        if lSeries.ColorEachPoint then
          lSeries.AddXY(StrToFloat(lXValues[i]), StrToFloat(lYValues[i]), '', clTeeColor)
        else
          lSeries.AddXY(RMStrToFloat(lXValues[i]), StrToFloat(lYValues[i]), '', lChartSeries.Color);
      end
      else
      begin
        if lSeries.ColorEachPoint then
          lSeries.Add(StrToFloat(lYValues[i]), lXValues[i], clTeeColor)
        else
          lSeries.Add(StrToFloat(lYValues[i]), lXValues[i], lChartSeries.Color);
      end;
    end;
  end;

  procedure _BuildSeries;
  var
    i, lPos: Integer;
    lXStr, lYStr: string;
    lFlag_NumberString: Boolean;
    lStr: string;
  begin
    if Memo.Count < FSeriesList.Count * 2 then Exit;

    for i := 0 to FSeriesList.Count - 1 do
    begin
      lXStr := Memo[i * 2];
      lYStr := Memo[i * 2 + 1];

      if (lXStr <> '') and (lXStr[Length(lXStr)] <> ';') then
        lXStr := lXStr + ';';
      if (lYStr <> '') and (lYStr[Length(lYStr)] <> ';') then
        lYStr := lYStr + ';';

      lXValues.Clear; lYValues.Clear;
      lFlag_NumberString := True;
      for lPos := 1 to Length(lXStr) do
      begin
        if not (lXStr[lPos] in ['-', ' ', ';', '.', '0'..'9']) then
        begin
          lFlag_NumberString := False;
          Break;
        end;
      end;

      lPos := 1;
      while lPos <= Length(lXStr) do
        lXValues.Add(_ExtractStr(lXStr, lPos));

      lPos := 1;
      while lPos <= Length(lYStr) do
      begin
        lStr := _ExtractStr(lYStr, lPos);
        if RMisNumeric(lStr) then
          lYValues.Add(SysUtils.Format('%12.3f', [RMStrToFloat(lStr)]))
        else
          lYValues.Add('0');
      end;

      lChartSeries := Series[i];
      _AddSeries(i, lFlag_NumberString);
    end;
  end;

begin
  if (FSeriesList.Count < 1) and (Memo.Count = 0) then
  begin
    if FPicture.Width = 0 then
      _PaintChart
    else
      Canvas.StretchDraw(RealRect, FPicture);

    Exit;
  end;

  lXValues := TStringList.Create;
  lYValues := TStringList.Create;
  try
    _SetChartProp;
    _BuildSeries;
    _PaintChart;
  finally
    lXValues.Free;
    lYValues.Free;
  end;
end;

procedure TRMChartView.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  Memo1.Assign(Memo);
  CalcGaps;
  ShowBackground;
  ShowChart;
  ShowFrame;
  RestoreCoord;
end;

procedure TRMChartView.PlaceOnEndPage(aStream: TStream);
var
  i: Integer;
begin
  inherited PlaceOnEndPage(aStream);
  Memo.Text := '';
  for i := 0 to FSeriesList.Count - 1 do
  begin
    Series[i].Init;
  end;
end;

procedure TRMChartView.GetEndPageData(aStream: TStream);
var
  i, j: Integer;
  lStr: string;
  lSeries: TRMChartSeries;
begin
  if UseDoublePass and (ParentReport.MasterReport.DoublePass and ParentReport.MasterReport.FinalPass) then
  begin
    Memo1.Text := FSaveMemo;
  end
  else
  begin
    for i := 0 to FSeriesList.Count - 1 do
    begin
      lSeries := Series[i];
      lSeries.GetData(ParentReport);
      lStr := '';
      for j := 0 to High(lSeries.FXValues) do
      begin
        if j > 0 then
          lStr := lStr + ';';

        lStr := lStr + string(lSeries.FXValues[j]);
      end;
      Memo1.Add(lStr);

      lStr := '';
      for j := 0 to High(lSeries.FYValues) do
      begin
        if j > 0 then
          lStr := lStr + ';';

        lStr := lStr + string(lSeries.FYValues[j]);
      end;
      Memo1.Add(lStr);
    end;
  end;
end;

procedure TRMChartView.LoadFromStream(aStream: TStream);
var
  lVersion: Integer;
  lType: Byte;
  lStream: TMemoryStream;
  i, lCount: Integer;
  lSeries: TRMChartSeries;
begin
  inherited LoadFromStream(aStream);
  lVersion := RMReadWord(aStream);

  Clear;
  FPicture.Clear;
  ChartDim3D := RMReadBoolean(aStream);
  ChartShowLegend := RMReadBoolean(aStream);
  ChartShowAxis := RMReadBoolean(aStream);
  FPrintType := TRMPrintMethodType(RMReadByte(aStream));
  lCount := RMReadWord(aStream);
  for i := 1 to lCount do
  begin
    lSeries := AddSeries;
    lSeries.XObject := RMReadString(aStream);
    lSeries.YObject := RMReadString(aStream);
    if lVersion < 2 then
      RMReadString(aStream);
    lSeries.Top10Label := RMReadString(aStream);
    lSeries.Title := RMReadString(aStream);
    lSeries.Color := RMReadInt32(aStream);
    lSeries.ChartType := RMReadByte(aStream);
    lSeries.ShowMarks := RMReadBoolean(aStream);
    lSeries.Colored := RMReadBoolean(aStream);
    lSeries.MarksStyle := RMReadByte(aStream);
    lSeries.Top10Num := RMReadInt32(aStream);
    if lVersion >= 1 then
    begin
      lSeries.DataType := TRMChartSeriesDataType(RMReadByte(aStream));
      lSeries.SortOrder := TRMChartSeriesSortOrder(RMReadByte(aStream));
      lSeries.DataSet := RMReadString(aStream);
    end;
  end;

  lType := RMReadByte(aStream);
  if lType = 1 then
  begin
    lStream := TMemoryStream.Create;
    try
      lStream.CopyFrom(aStream, RMReadInt32(aStream));
      lStream.Position := 0;
      FPicture.LoadFromStream(lStream);
    finally
      lStream.Free;
    end;
  end;

  lType := RMReadByte(aStream);
  if lType = 1 then
  begin
    FreeAndNil(FChart);
    FChart := TChart.Create(RMDialogForm);
    with FChart do
    begin
      Parent := RMDialogForm;
      Visible := False;
      BevelInner := bvNone;
      BevelOuter := bvNone;
    end;

    lStream := TMemoryStream.Create;
    try
      lStream.CopyFrom(aStream, RMReadInt32(aStream));
      lStream.Position := 0;
      lStream.ReadComponent(FChart);
      FChart.Name := '';
      for i := 0 to FChart.SeriesList.Count - 1 do
        FChart.SeriesList[i].Name := '';
    finally
      lStream.Free;
    end;
  end;
end;

procedure TRMChartView.SaveToStream(aStream: TStream);
var
  lStream: TMemoryStream;
  lEMF: TMetafile;
  i: Integer;
  lSavePos, lSavePos1, lPos: Integer;
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 2);

  RMWriteBoolean(aStream, ChartDim3D);
  RMWriteBoolean(aStream, ChartShowLegend);
  RMWriteBoolean(aStream, ChartShowAxis);
  RMWriteByte(aStream, Byte(FPrintType));
  RMWriteWord(aStream, FSeriesList.Count);
  for i := 0 to FSeriesList.Count - 1 do
  begin
    RMWriteString(aStream, Series[i].XObject);
    RMWriteString(aStream, Series[i].YObject);
    RMWriteString(aStream, Series[i].Top10Label);
    RMWriteString(aStream, Series[i].Title);
    RMWriteInt32(aStream, Series[i].Color);
    RMWriteByte(aStream, Series[i].ChartType);
    RMWriteBoolean(aStream, Series[i].ShowMarks);
    RMWriteBoolean(aStream, Series[i].Colored);
    RMWriteByte(aStream, Series[i].MarksStyle);
    RMWriteInt32(aStream, Series[i].Top10Num);
    RMWriteByte(aStream, Byte(Series[i].DataType));
    RMWriteByte(aStream, Byte(Series[i].SortOrder));
    RMWriteString(aStream, Series[i].DataSet);
  end;

  if (FSeriesList.Count < 1) and (Memo.Count = 0) then
  begin
    RMWriteByte(aStream, 1);
    lStream := TMemoryStream.Create;
    lEMF := nil;
    try
      lEMF := FChart.TeeCreateMetafile(False, Rect(0, 0, spWidth, spHeight));
      lEMF.SaveToStream(lStream);

      lStream.Position := 0;
      RMWriteInt32(aStream, lStream.Size);
      aStream.CopyFrom(lStream, 0);
    finally
      lStream.Free;
      FreeAndNil(lEMF);
    end;
  end
  else
    RMWriteByte(aStream, 0);

  if UseChartSetting then
  begin
    RMWriteByte(aStream, 1);
    FChart.Name := '';
    for i := 0 to FChart.SeriesList.Count - 1 do
      FChart.SeriesList[i].Name := '';

    lSavePos := aStream.Position;
    RMWriteInt32(aStream, lSavePos);
    lSavePos1 := aStream.Position;
    aStream.WriteComponent(FChart);
    lPos := aStream.Position;
    aStream.Position := lSavePos;
    RMWriteInt32(aStream, lPos - lSavePos1);
    aStream.Position := lPos;
  end
  else
    RMWriteByte(aStream, 0);
end;

procedure TRMChartView.DefinePopupMenu(Popup: TRMCustomMenuItem);
begin
  inherited DefinePopupMenu(Popup);
end;

procedure TRMChartView.Prepare;
var
  i: Integer;
begin
  if not ParentReport.MasterReport.FinalPass then
    FSaveMemo := '';

  Memo.Clear;
  for i := 0 to FSeriesList.Count - 1 do
  begin
    Series[i].Init;
  end;
end;

procedure TRMChartView.OnHook(aView: TRMView);
var
  lSeries: TRMChartSeries;
  i: Integer;

  procedure _GetValue(const aObjName: string; aIndex: Integer);
  var
    lStr: string;
    lNewValue: string;
  begin
    if AnsiCompareText(aView.Name, aObjName) <> 0 then Exit;

    lNewValue := '';
    if THackView(aView).Memo1.Count > 0 then
    begin
      lStr := THackView(aView).Memo1[0];
      if lStr <> '' then
        lNewValue := lStr
      else
      begin
        if aIndex = 1 then
          lNewValue := '0;'
        else
          lNewValue := '';
      end
    end
    else
    begin
      if aIndex = 1 then
        lNewValue := '0'
      else
        lNewValue := '';
    end;

    if aIndex = 0 then
    begin
      SetLength(lSeries.FXValues, Length(lSeries.FXValues) + 1);
      lSeries.FXValues[Length(lSeries.FXValues) - 1] := lNewValue;
    end
    else if aIndex = 1 then
    begin
      SetLength(lSeries.FYValues, Length(lSeries.FYValues) + 1);
      if RMIsValidFloat(lNewValue) then
        lSeries.FYValues[Length(lSeries.FYValues) - 1] := RMStrToFloat(lNewValue)
      else
        lSeries.FYValues[Length(lSeries.FYValues) - 1] := 0;
    end;
  end;

begin
  for i := 0 to FSeriesList.Count - 1 do
  begin
    lSeries := Series[i];
    if lSeries.DataType = rmdtBandData then
    begin
      _GetValue(lSeries.XObject, 0);
      _GetValue(lSeries.YObject, 1);
    end;
  end;

  if UseDoublePass and
    (ParentReport.MasterReport.DoublePass and (not ParentReport.MasterReport.FinalPass)) then
  begin
    FSaveMemo := Memo.Text;
  end;
end;

procedure TRMChartView.ShowEditor;
var
  tmpForm: TRMChartForm;
  lStream: TMemoryStream;
  lSaveFlag: Boolean;
begin
  lStream := TMemoryStream.Create;
  tmpForm := TRMChartForm.Create(Application);
  lSaveFlag := UseChartSetting;
  try
    UseChartSetting := True;
    tmpForm.FReport := ParentReport;
    SaveToStream(lStream);
    lStream.Position := 0;
    tmpForm.FChartView.LoadFromStream(lStream);
    tmpForm.FChartView.UseChartSetting := lSaveFlag;

    UseChartSetting := lSaveFlag;
    if tmpForm.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      lStream.Clear;

      UseChartSetting := True;
      tmpForm.FChartView.UseChartSetting := True;
      tmpForm.FChartView.SaveToStream(lStream);
      lStream.Position := 0;
      LoadFromStream(lStream);
      RMDesigner.AfterChange;
    end;
  finally
    UseChartSetting := lSaveFlag;
    lStream.Free;
    tmpForm.Free;
  end;
end;

function TRMChartView.GetUseChartSetting: Boolean;
begin
  Result := FFlags and flChartUseChartSetting = flChartUseChartSetting;
end;

procedure TRMChartView.SetUseChartSetting(Value: Boolean);
begin
  FFlags := FFlags and (not flChartUseChartSetting);
//{$IFDEF TeeChartPro}
  if Value then
    FFlags := FFlags + flChartUseChartSetting;
//{$ENDIF}
end;

function TRMChartView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flChartDirectDraw) = flChartDirectDraw;
end;

procedure TRMChartView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flChartDirectDraw);
  if Value then
    FFlags := FFlags + flChartDirectDraw;
end;

function TRMChartView.GetViewCommon: string;
begin
  Result := '[Chart]';
end;

procedure TRMChartView.ClearContents;
begin
  Clear;
  inherited;
end;

function TRMChartView.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'CHART' then
  begin
    aValue := O2V(FChart);
  end
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCustomTeeChartUI }

class procedure TRMCustomTeeChartUI.Edit(aTeeChart: TCustomChart);
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

class procedure TRMTeeChartUIPlugIn.Register(aChartUIClass: TRMCustomTeeChartUIClass);
begin
//  uChartUIPlugInLock.Acquire;
  try
    uChartUIClassList.Add(aChartUIClass);
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class procedure TRMTeeChartUIPlugIn.UnRegister(aChartUIClass: TRMCustomTeeChartUIClass);
begin
//  uChartUIPlugInLock.Acquire;
  try
    uChartUIClassList.Remove(aChartUIClass);
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class function TRMTeeChartUIPlugIn.GetChartUIClass: TRMCustomTeeChartUIClass;
begin
//  uChartUIPlugInLock.Acquire;
  try
    if uChartUIClassList.Count > 0 then
      Result := TRMCustomTeeChartUIClass(uChartUIClassList[0])
    else
      Result := nil;
  finally
//    uChartUIPlugInLock.Release;
  end;
end;

class procedure TRMTeeChartUIPlugIn.Edit(aTeeChart: TCustomChart);
var
  lChartUIClass: TRMCustomTeeChartUIClass;
begin
  lChartUIClass := GetChartUIClass;
  if (lChartUIClass <> nil) then
    lChartUIClass.Edit(aTeeChart);
end;

class function TRMTeeChartUIPlugIn.HaveChartEditor: Boolean;
begin
  Result := (GetChartUIClass <> nil);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMChartForm }

procedure TRMChartForm.FormCreate(Sender: TObject);
var
  i, j: Integer;
  t: TRMView;
  liPage: TRMCustomPage;
begin
  FDataSetBMP := TBitmap.Create;
  FFieldBMP := TBitmap.Create;

  FDataSetBMP.LoadFromResourceName(hInstance, 'RM_FLD1');
  FFieldBMP.LoadFromResourceName(hInstance, 'RM_FLD2');

  Page1.ActivePage := TabSheet1;
  FBtnColor := TRMColorPickerButton.Create(Self);
  FBtnColor.Parent := gpbSeriesOptions;
  FBtnColor.ColorType := rmptFill;
  FBtnColor.Flat := False;
  FBtnColor.SetBounds(120, 30, 115, 25);
  FBtnColor.OnColorChange := OnColorChangeEvent;

  for i := 0 to RMDesigner.Report.Pages.Count - 1 do
  begin
    liPage := RMDesigner.Report.Pages[i];
    if liPage is TRMReportPage then
    begin
      for j := 0 to THackPage(liPage).Objects.Count - 1 do
      begin
        t := THackPage(liPage).Objects[j];
        if t is TRMCustomMemoView then
          cmbLegend.Items.Add(t.Name);
      end;
    end;
  end;

  cmbValue.Items.Assign(cmbLegend.Items);
  FChartView := TRMChartView(RMCreateObject(rmgtAddin, 'TRMChartView'));

  Panel1.BevelOuter := bvNone;
  FInspector := TELPropertyInspector.Create(Self);
  with FInspector do
  begin
    Parent := Panel1;
    Align := alClient;
    OnAfterModify := OnAfterModifyEvent;
  end;

  Localize;
end;

procedure TRMChartForm.FormDestroy(Sender: TObject);
begin
  FChartView.Free;

  FDataSetBMP.Free;
  FFieldBMP.Free;
end;

procedure TRMChartForm.Localize;
var
  i: Integer;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 590);
//  RMSetStrProp(Tab1, 'Caption', rmRes + 591);
//  RMSetStrProp(Tab2, 'Caption', rmRes + 592);
  RMSetStrProp(Tab3, 'Caption', rmRes + 604);
  RMSetStrProp(TabSheet1, 'Caption', rmRes + 592 {7});
  RMSetStrProp(gpbObjects, 'Caption', rmRes + 594);
  RMSetStrProp(gpbMarks, 'Caption', rmRes + 605);
  RMSetStrProp(gpbTopGroup, 'Caption', rmRes + 611);
  RMSetStrProp(gpbChartOptions, 'Caption', rmRes + 595);
  RMSetStrProp(gpbSeriesType, 'Caption', rmRes + 593);
  RMSetStrProp(gpbSeriesOptions, 'Caption', rmRes + 642);

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
  RMSetStrProp(Label3, 'Caption', rmRes + 612);
  RMSetStrProp(Label4, 'Caption', rmRes + 613);
  RMSetStrProp(Label5, 'Caption', rmRes + 614);

//  RMSetStrProp(Add1, 'Caption', rmRes + 616);
//  RMSetStrProp(Delete1, 'Caption', rmRes + 617);
//  RMSetStrProp(EditTitle1, 'Caption', rmRes + 618);
//  RMSetStrProp(MoveUp1, 'Caption', rmRes + 619);
//  RMSetStrProp(MoveDown1, 'Caption', rmRes + 620);

  cmbSeriesType.Items.Clear;
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 624));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 625));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 626));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 627));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 628));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 629));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 643));
  cmbSeriesType.Items.Add(RMLoadStr(rmRes + 644));

  RMSetStrProp(GroupBox2, 'Caption', rmRes + 594);
  RMSetStrProp(Label7, 'Caption', rmRes + 602);
  RMSetStrProp(Label8, 'Caption', rmRes + 603);
  RMSetStrProp(Label10, 'Caption', rmRes + 621);

  RMSetStrProp(rdbDataSource, 'Caption', rmRes + 631);
  rdbDataSource.Items.Clear;
  rdbDataSource.Items.Add(RMLoadStr(rmRes + 632));
  rdbDataSource.Items.Add(RMLoadStr(rmRes + 633));
  rdbDataSource.Items.Add(RMLoadStr(rmRes + 634));
  RMSetStrProp(rdbSortType, 'Caption', rmRes + 635);
  rdbSortType.Items.Clear;
  rdbSortType.Items.Add(RMLoadStr(rmRes + 636));
  rdbSortType.Items.Add(RMLoadStr(rmRes + 637));
  rdbSortType.Items.Add(RMLoadStr(rmRes + 638));
  RMSetStrProp(GroupBox1, 'Caption', rmRes + 639);

  RMSetStrProp(lblXValue, 'Caption', rmRes + 640);
  RMSetStrProp(lblYValue, 'Caption', rmRes + 641);

  RMSetStrProp(btnCharUI, 'Caption', rmRes + 623);
  btnOk.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);

  for i := 0 to cmbSeriesType.Items.Count - 1 do
    PopupSeries.Items[i].Caption := cmbSeriesType.Items[i];
end;

procedure TRMChartForm.LoadSeriesOptions;

  procedure _SetRButton(b: array of TRadioButton; n: Integer);
  begin
    if (n >= Low(b)) and (n <= High(b)) then
      b[n].Checked := True;
  end;

begin
  FInspector.Clear;
  if (TreeView1.Selected = TreeView1.Items[0]) or (not FChartView.UseChartSetting) then
    FInspector.Add(FChartView.Chart)
  else
    FInspector.Add(FChartView.Chart.Series[TreeView1.Selected.AbsoluteIndex - 1]);

  RMSetControlsEnabled(gpbSeriesType, FSeries <> nil);
  RMSetControlsEnabled(gpbSeriesOptions, FSeries <> nil);
  RMSetControlsEnabled(gpbObjects, FSeries <> nil);
  RMSetControlsEnabled(gpbTopGroup, FSeries <> nil);
  RMSetControlsEnabled(gpbSeriesType, FSeries <> nil);
  RMSetControlsEnabled(rdbDataSource, FSeries <> nil);
  RMSetControlsEnabled(rdbSortType, FSeries <> nil);
  RMSetControlsEnabled(gpbMarks, FSeries <> nil);
  rdbDataSourceClick(nil);

  chkChartShowLegend.Checked := FChartView.ChartShowLegend;
  chkChartShowAxis.Checked := FChartView.ChartShowAxis;
  chkChartDim3D.Checked := FChartView.ChartDim3D;

  if FSeries = nil then
  begin
    rdbDataSourceClick(nil);
    Exit;
  end;

  cmbSeriesType.ItemIndex := FSeries.ChartType;
  _SetRButton([rdbStyle1, rdbStyle2, rdbStyle3, rdbStyle4, rdbStyle5], FSeries.MarksStyle);
  chkSeriesShowMarks.Checked := FSeries.ShowMarks;
  chkSeriesMultiColor.Checked := FSeries.Colored;
  editTop10Num.Text := IntToStr(FSeries.Top10Num);
  edtTop10Label.Text := FSeries.Top10Label;
  FBtnColor.CurrentColor := FSeries.Color;
  FBtnColor.Enabled := not chkSeriesMultiColor.Checked;
  rdbDataSource.ItemIndex := Byte(FSeries.DataType);
  rdbSortType.ItemIndex := Byte(FSeries.SortOrder);
  rdbDataSourceClick(nil);

  cmbLegend.Text := '';
  cmbValue.Text := '';
  cmbDataSet.Text := '';
  ComboBox1.Text := '';
  ComboBox2.Text := '';
  edtXValues.Text := '';
  edtYValues.Text := '';
  case FSeries.DataType of
    rmdtBandData:
      begin
        cmbLegend.Text := FSeries.XObject;
        cmbValue.Text := FSeries.YObject;
      end;
    rmdtDBData:
      begin
        cmbDataSet.ItemIndex := cmbDataSet.Items.IndexOf(FSeries.DataSet);
        cmbDataSetChange(nil);
        ComboBox2.ItemIndex := ComboBox2.Items.IndexOf(FSeries.YObject);
        ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(FSeries.XObject);
      end;
    rmdtFixedData:
      begin
        edtXValues.Text := FSeries.FXObject;
        edtYValues.Text := FSeries.FYObject;
      end;
  end;
end;

procedure TRMChartForm.SaveSeriesOptions;

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

  FSeries.Top10Num := StrToInt(editTop10Num.Text);
  FSeries.Top10Label := edtTop10Label.Text;
  FSeries.Color := FBtnColor.CurrentColor;
  FSeries.DataType := TRMChartSeriesDataType(rdbDataSource.ItemIndex);
  FSeries.SortOrder := TRMChartSeriesSortOrder(rdbSortType.ItemIndex);
  case FSeries.DataType of
    rmdtBandData:
      begin
        FSeries.XObject := cmbLegend.Text;
        FSeries.YObject := cmbValue.Text;
      end;
    rmdtDBData:
      begin
        FSeries.DataSet := cmbDataSet.Text;
        FSeries.YObject := ComboBox2.Text;
        FSeries.XObject := ComboBox1.Text;
      end;
    rmdtFixedData:
      begin
        FSeries.XObject := edtXValues.Text;
        FSeries.YObject := edtYValues.Text;
      end;
  end;
end;

procedure TRMChartForm.Add1Click(Sender: TObject);
var
  lPoint: TPoint;
begin
  lPoint := btnAddSeries.ClientToScreen(Point(0, btnAddSeries.Height));
  PopupSeries.Popup(lPoint.X, lPoint.Y);
end;

procedure TRMChartForm.Delete1Click(Sender: TObject);
var
  lIndex: Integer;
  lSeries: TChartSeries;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected.AbsoluteIndex < 1) then Exit;

  FOldSelected := TreeView1.Selected.GetPrev;
  lIndex := TreeView1.Selected.AbsoluteIndex - 1;
  FChartView.DeleteSeries(lIndex);
  TreeView1.Items.Delete(TreeView1.Selected);
  TreeView1.Selected := FOldSelected;

  lSeries := FChartView.Chart.Series[lIndex];
  FChartView.Chart.SeriesList.Delete(lIndex);
  lSeries.Free;

  lIndex := TreeView1.Selected.AbsoluteIndex - 1;
  if lIndex >= 0 then
    FSeries := FChartView.Series[lIndex]
  else
    FSeries := nil;

  LoadSeriesOptions;
  FOldSelected := TreeView1.Selected;
end;

procedure TRMChartForm.FormShow(Sender: TObject);

  procedure _GetDatasets;
  begin
    cmbDataSet.Items.BeginUpdate;
    FReport.Dictionary.GetDataSets(cmbDataSet.Items);
    cmbDataSet.Items.Insert(0, RMLoadStr(SNotAssigned));
    cmbDataSet.Items.EndUpdate;
  end;

begin
  _GetDataSets;

  FInspector.Enabled := FChartView.UseChartSetting;
  btnCharUI.Visible := FChartView.UseChartSetting and TRMTeeChartUIPlugIn.HaveChartEditor;
  //Tab3.TabVisible := not Button1.Visible;

  SetTreeView;
  FOldSelected := TreeView1.Selected;
end;

procedure TRMChartForm.MoveUp1Click(Sender: TObject);
var
  lIndex: Integer;
begin
  if TreeView1.Selected = nil then Exit;

  lIndex := TreeView1.Selected.AbsoluteIndex - 1;
  if (lIndex > 0) then
  begin
    TreeView1.Selected.MoveTo(TreeView1.Selected.GetPrev, naInsert);
    FChartView.Chart.SeriesList.Exchange(lIndex, lIndex - 1);
    FChartView.FSeriesList.Exchange(lIndex, lIndex - 1);
  end;
end;

procedure TRMChartForm.MoveDown1Click(Sender: TObject);
var
  lIndex: Integer;
begin
  if TreeView1.Selected = nil then Exit;

  lIndex := TreeView1.Selected.AbsoluteIndex - 1;
  if (lIndex >= 0) and (lIndex < TreeView1.Items.Count - 2) then
  begin
    TreeView1.Selected.GetNext.MoveTo(TreeView1.Selected, naInsert);
    FChartView.Chart.SeriesList.Exchange(lIndex, lIndex + 1);
    FChartView.FSeriesList.Exchange(lIndex, lIndex + 1);
  end;
end;

procedure TRMChartForm.btnOkClick(Sender: TObject);
begin
  SaveSeriesOptions;
end;

procedure TRMChartForm.btnCharUIClick(Sender: TObject);
var
  i, lCount: Integer;
  lRMSeries: TRMChartSeries;
begin
  SaveSeriesOptions;

  FChartView.Chart.View3D := FChartView.ChartDim3D;
  FChartView.Chart.Legend.Visible := FChartView.ChartShowLegend;
  FChartView.Chart.AxisVisible := FChartView.ChartShowAxis;

  TRMTeeChartUIPlugIn.Edit(FChartView.Chart);

  FChartView.ChartDim3D := FChartView.Chart.View3D;
  FChartView.ChartShowLegend := FChartView.Chart.Legend.Visible;
  FChartView.ChartShowAxis := FChartView.Chart.AxisVisible;

  lCount := FChartView.SeriesCount - FChartView.Chart.SeriesCount - 1;
  for i := 0 to lCount do
  begin
    FChartView.DeleteSeries(FChartView.SeriesCount - 1);
  end;

  lCount := FChartView.Chart.SeriesCount - FChartView.SeriesCount - 1;
  for i := 0 to lCount do
  begin
    lRMSeries := FChartView.AddSeries;
    lRMSeries.Title := FChartView.FChart.Series[i].Title;
    lRMSeries.Colored := FChartView.FChart.Series[i].ColorEachPoint;
    lRMSeries.ShowMarks := FChartView.FChart.Series[i].Marks.Visible;
    lRMSeries.MarksStyle := Integer(FChartView.FChart.Series[i].Marks.Style);
  end;

  SetTreeView;
end;

procedure TRMChartForm.cmbSeriesTypeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  lStr: string;
  lBitmap: TBitmap;
begin
  lStr := cmbSeriesType.Items[Index];
  lBitmap := TBitmap.Create;
  try
    ImageList2.GetBitmap(Index + 1, lBitmap);
    cmbSeriesType.Canvas.FillRect(Rect);
    cmbSeriesType.Canvas.BrushCopy(
      Bounds(Rect.Left + 4, Rect.Top, lBitmap.Width, lBitmap.Height),
      lBitmap,
      Bounds(0, 0, lBitmap.Width, lBitmap.Height),
      lBitmap.TransparentColor);

    cmbSeriesType.Canvas.TextOut(Rect.Left + 10 + lBitmap.Width,
      Rect.Top + (Rect.Bottom - Rect.Top - cmbSeriesType.Canvas.TextHeight(lStr)) div 2,
      lStr);
  finally
    lBitmap.Free;
  end;
end;

procedure TRMChartForm.rdbDataSourceClick(Sender: TObject);
begin
  RMSetControlsEnabled(gpbObjects, (FSeries <> nil) and (rdbDataSource.ItemIndex = 0));
  RMSetControlsEnabled(GroupBox1, (FSeries <> nil) and (rdbDataSource.ItemIndex = 2));
  RMSetControlsEnabled(GroupBox2, (FSeries <> nil) and (rdbDataSource.ItemIndex = 1));
end;

procedure TRMChartForm.cmbDataSetChange(Sender: TObject);
begin
  if cmbDataSet.ItemIndex < 1 then
  begin
    ComboBox2.Items.Clear;
    ComboBox1.Items.Clear;
  end
  else
  begin
    FReport.Dictionary.GetDataSetFields(cmbDataSet.Items[cmbDataSet.ItemIndex], ComboBox2.Items);
    ComboBox1.Items.Assign(ComboBox2.Items);
  end;
end;

procedure TRMChartForm.cmbDataSetDrawItem(Control: TWinControl;
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

procedure TRMChartForm.SetSeriesType(aNode: TTreeNode; aChartType: Integer);
var
  lSeries: TChartSeries;
  lIndex: Integer;
begin
  lIndex := aNode.AbsoluteIndex - 1;
  if FChartView.Chart.SeriesCount <= lIndex then
  begin
    lSeries := ChartTypes[aChartType].Create(FChartView.Chart);
    FChartView.Chart.AddSeries(lSeries);
  end
  else if FSeries <> nil then
  begin
    lSeries := ChartTypes[aChartType].Create(FChartView.Chart);
    FChartView.Chart.AddSeries(lSeries);
    lSeries.Title := FChartView.Chart.Series[lIndex].Title;
    FChartView.Chart.SeriesList.Exchange(lIndex, FChartView.Chart.SeriesCount - 1);

    aNode.ImageIndex := aChartType + 1;
    aNode.SelectedIndex := aNode.ImageIndex;

    lSeries := FChartView.Chart.Series[FChartView.Chart.SeriesCount - 1];
    FChartView.Chart.SeriesList.Delete(FChartView.Chart.SeriesCount - 1);
    lSeries.Free;
  end;
end;

procedure TRMChartForm.TreeView1Click(Sender: TObject);
var
  lIndex: Integer;
begin
  if (TreeView1.Selected = nil) or (TreeView1.Selected = FOldSelected) then Exit;

  FOldSelected := TreeView1.Selected;
  SaveSeriesOptions;
  lIndex := TreeView1.Selected.AbsoluteIndex - 1;
  if lIndex >= 0 then
    FSeries := FChartView.Series[lIndex]
  else
    FSeries := nil;

  LoadSeriesOptions;
end;

procedure TRMChartForm.mnuLineClick(Sender: TObject);
var
  lNode: TTreeNode;
begin
  SaveSeriesOptions;

  FSeries := FChartView.AddSeries;
  FSeries.ChartType := TMenuItem(Sender).Tag;

  TreeView1.SetFocus;
  lNode := TreeView1.Items.AddChild(TreeView1.Items[0], FSeries.Title);
  lNode.ImageIndex := FSeries.ChartType + 1;
  lNode.SelectedIndex := lNode.ImageIndex;
  TreeView1.Selected := lNode;
  SetSeriesType(lNode, FSeries.ChartType);
  FChartView.FChart.Series[FChartView.FChart.SeriesCount - 1].Title := FSeries.Title;
  FOldSelected := TreeView1.Selected;

  //ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  LoadSeriesOptions;
end;

procedure TRMChartForm.cmbSeriesTypeClick(Sender: TObject);
begin
  if cmbSeriesType.ItemIndex >= 0 then
  begin
    FSeries.ChartType := cmbSeriesType.ItemIndex;
    SetSeriesType(TreeView1.Selected, FSeries.ChartType);
    FInspector.Clear;
    if TreeView1.Selected = TreeView1.Items[0] then
      FInspector.Add(FChartView.Chart)
    else
      FInspector.Add(FChartView.Chart.Series[TreeView1.Selected.AbsoluteIndex - 1]);
  end;
end;

procedure TRMChartForm.OnColorChangeEvent(Sender: TObject);
begin
  SetInspControls;
end;

procedure TRMChartForm.chkChartShowAxisClick(Sender: TObject);
begin
  SetInspControls;
end;

procedure TRMChartForm.SetInspControls;
begin
  FBtnColor.Enabled := not chkSeriesMultiColor.Checked;
  if not FInspector.Enabled then Exit;

  if FInspector.Objects[0] = FChartView.Chart then
  begin
    FChartView.Chart.AxisVisible := chkChartShowAxis.Checked;
    FChartView.Chart.Legend.Visible := chkChartShowLegend.Checked;
    FChartView.Chart.View3D := chkChartDim3D.Checked;
  end
  else
  begin
    TChartSeries(FInspector.Objects[0]).ColorEachPoint := chkSeriesMultiColor.Checked;
    TChartSeries(FInspector.Objects[0]).ColorEachPoint := chkSeriesMultiColor.Checked;
    TChartSeries(FInspector.Objects[0]).Marks.Visible := chkSeriesShowMarks.Checked;
    if rdbStyle1.Checked then
      TChartSeries(FInspector.Objects[0]).Marks.Style := TSeriesMarksStyle(0)
    else if rdbStyle2.Checked then
      TChartSeries(FInspector.Objects[0]).Marks.Style := TSeriesMarksStyle(1)
    else if rdbStyle3.Checked then
      TChartSeries(FInspector.Objects[0]).Marks.Style := TSeriesMarksStyle(2)
    else if rdbStyle4.Checked then
      TChartSeries(FInspector.Objects[0]).Marks.Style := TSeriesMarksStyle(3)
    else if rdbStyle5.Checked then
      TChartSeries(FInspector.Objects[0]).Marks.Style := TSeriesMarksStyle(4);
  end;

  FInspector.UpdateItems;
end;

procedure TRMChartForm.OnAfterModifyEvent(Sender: TObject; const aPropName, aPropValue: string);
begin
  if not FInspector.Enabled then Exit;

  if FInspector.Objects[0] = FChartView.Chart then
  begin
    chkChartShowAxis.Checked := FChartView.Chart.AxisVisible;
    chkChartShowLegend.Checked := FChartView.Chart.Legend.Visible;
    chkChartDim3D.Checked := FChartView.Chart.View3D;
  end
  else
  begin
    TreeView1.Selected.Text := TChartSeries(FInspector.Objects[0]).Title;
    chkSeriesMultiColor.Checked := TChartSeries(FInspector.Objects[0]).ColorEachPoint;
    chkSeriesShowMarks.Checked := TChartSeries(FInspector.Objects[0]).Marks.Visible;
    case Integer(TChartSeries(FInspector.Objects[0]).Marks.Style) of
      0: rdbStyle1.Checked := True;
      1: rdbStyle2.Checked := True;
      2: rdbStyle3.Checked := True;
      3: rdbStyle4.Checked := True;
      4: rdbStyle5.Checked := True;
    end;
  end;
end;

procedure TRMChartForm.SetTreeView;
var
  i: Integer;
  lNode: TTreeNode;
begin
  TreeView1.Items[0].DeleteChildren;
  for i := 0 to FChartView.SeriesCount - 1 do
  begin
    lNode := TreeView1.Items.AddChild(TreeView1.Items[0], FChartView.Series[i].Title);
    lNode.ImageIndex := FChartView.Series[i].ChartType + 1;
    lNode.SelectedIndex := lNode.ImageIndex;
    SetSeriesType(lNode, FChartView.Series[i].ChartType);
    FChartView.FChart.Series[i].Title := FChartView.Series[i].Title;
  end;

  TreeView1.Items[0].Expand(True);
  TreeView1.Selected := TreeView1.Items[0];
  LoadSeriesOptions;
end;

procedure TRMChartForm.TreeView1Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := not (TreeView1.Selected = TreeView1.Items[0]);
end;

procedure TRMChartForm.TreeView1Edited(Sender: TObject; Node: TTreeNode;
  var S: String);
begin
  if FSeries = nil then Exit;

  if Node <> TreeView1.Items[0] then
  begin
    FSeries.Title := S;
    FChartView.FChart[Node.AbsoluteIndex - 1].Title := S;
    SetInspControls;
  end;
end;



{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMChartView_AssignChart(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMChartView(Args.Obj).AssignChart(TChart(V2O(Args.Values[0])));
end;

procedure TRMChartView_Read_Count(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMChartView(Args.Obj).SeriesCount;
end;

procedure TRMChartView_Read_Items(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TRMChartView(Args.Obj).Series[Args.Values[0]]);
end;

procedure TRMChartView_Write_Items(const Value: Variant; Args: TJvInterpreterArgs);
begin
//  TList(Args.Obj).Items[Args.Values[0]] := V2P(Value);
end;

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TChart, 'TChart');
    AddClass('ReportMachine', TRMChartView, 'TRMChartView');
    AddCLass('ReportMachine', TRMChartSeries, 'TRMChartSeries');

    AddGet(TRMChartView, 'AssignChart', TRMChartView_AssignChart, 1, [0], varEmpty);

    AddGet(TRMChartView, 'Count', TRMChartView_Read_Count, 0, [0], varEmpty);
    AddGet(TRMChartView, 'SeriesCount', TRMChartView_Read_Count, 0, [0], varEmpty);
    AddIGet(TRMChartView, 'Series', TRMChartView_Read_Items, 1, [0], varEmpty);
    AddIDGet(TRMChartView, TRMChartView_Read_Items, 1, [0], varEmpty);
    AddISet(TRMChartView, 'Series', TRMChartView_Write_Items, 1, [1]);
    AddIDSet(TRMChartView, TRMChartView_Write_Items, 1, [1]);
  end;
end;

initialization
  uChartUIClassList := TList.Create;
  RMRegisterObjectByRes(TRMChartView, 'RM_CHAROBJECT', RMLoadStr(SInsChart), TRMChartForm);

  RMInterpreter_Chart.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization
  uChartUIClassList.Free;
  uChartUIClassList := nil;
{$ENDIF}
end.

