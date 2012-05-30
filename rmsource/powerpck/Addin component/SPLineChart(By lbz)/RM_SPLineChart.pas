unit RM_SPLineChart;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RM_Class, ExtCtrls, TeeProcs, TeEngine, Series, StdCtrls, ComCtrls,
  ClipBrd, Menus, splines, math, DB, RM_Ctrls
{$IFDEF Delphi6}, Variants{$ENDIF};

type

  TRMSPLineChartObject = class(TComponent) // fake component
  end;

  { TRMSPLineChartView }
  TRMSPLineChartView = class(TRMReportView)
  private
    CurStr: Integer;
    LastLegend: string;
    function ShowChart: Boolean;
  protected
    procedure ExpandVariables;
  public
    grS: byte;
    splx, sply: array of real;
    memox, memoy: TStringlist;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure OnHook(View: TRMView); override;
    procedure savedataspline;
    procedure ShowEditor; override;
  end;

  { TRMSPLineChartForm }
  TRMSPLineChartForm = class(TRMObjEditorForm)
    Button1: TButton;
    Button2: TButton;
    Page1: TPageControl;
    Tab2: TTabSheet;
    CheckBox1: TCheckBox;
    M1: TMemo;
    Label1: TLabel;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure M1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TRMView): TModalResult; override;
  end;


implementation

uses RM_Const, RM_Const1, RM_Utils, RM_Common;

{$R *.DFM}
{$R RM_SPLineChart.RES}

const
  S_Page1 = '数据';
  S_CheckBox1 = '坐标细格';
  S_Label1 = '坐标点数据:(按X,Y各一行的顺序排列)';
  S_Button3 = '数据库字段';
  S_Caption = 'B样条图形';

type
  THackView = class(TRMView)
  end;

  TSeriesClass = class of TChartSeries;

function maxvalue(x: array of real): real;
var
  t: real;
  i: integer;
begin
  t := 0;
  for i := 0 to high(x) do
  begin
    if t < x[i] then t := x[i];
  end;
  maxvalue := t;
end;

function minvalue(x: array of real): real;
var
  t: real;
  i: integer;
begin
  t := maxvalue(x);
  for i := 0 to high(x) do
  begin
    if t > x[i] then t := x[i];
  end;
  minvalue := t;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMSPLineChartView }

constructor TRMSPLineChartView.Create;
begin
  inherited Create;
  BaseName := 'SPLineChart';
  grs := 0;
  FFlags := 1; // Flags or flWantHook;
  Memox := TStringList.Create;
  Memoy := TStringList.Create;
  memo.Clear;
  memo.add('8.1');
  memo.add('1.67');
  memo.add('10.2');
  memo.add('1.71');
  memo.add('12.9');
  memo.add('1.8');
  memo.add('15.8');
  memo.add('1.83');
  memo.add('19');
  memo.add('1.76');
end;

destructor TRMSPLineChartView.Destroy;
begin
  memox.Free;
  memoY.Free;
  splx := nil;
  sply := nil;
  inherited Destroy; //LBZ 2001.12.30
end;

procedure TRMSPLineChartView.savedataspline;
var
  i, error: integer;
begin
  splx := nil;
  sply := nil;
  if memox.Count > 0 then
  begin
    setlength(splx, memox.count);
    setlength(sply, memox.count);
    for i := 0 to memox.Count - 1 do
    begin
      val(memox.strings[i], splx[i], error);
      val(memoy.strings[i], sply[i], error);
    end;
  end;
end;

procedure TRMSPLineChartView.ExpandVariables;
var
  i, j: Integer;
  s: string;

  procedure GetData(var s: string);
  var
    i, j: Integer;
    s1, s2: string;
  begin
    i := 1;
    repeat
      while (i < Length(s)) and (s[i] <> '[') do Inc(i);
      s1 := RMGetBrackedVariable(s, i, j);
      if i <> j then
      begin
        Delete(s, i, j - i + 1);
        s2 := '';
        InternalOnGetValue(Self, s1, s2, False);
        Insert(s2, s, i);
        Inc(i, Length(s2));
        j := 0;
      end;
    until i = j;
  end;

begin
  Memo1.Clear;
  memox.Clear;
  memoy.clear;
  j := 0;
  for i := 0 to Memo.Count - 1 do
  begin
    s := Memo[i];
    if (Length(trim(s)) > 0) and (DocMode <> rmdmDesigning) then GetData(s);
    Memo1.Add(s);
    if length(trim(s)) > 0 then
    begin
      if j = 0 then memox.Add(s);
      if j = 1 then memoy.add(s);
      inc(j);
      if j > 1 then j := 0;
    end;
  end;
  if memox.Count > memoy.Count then
  begin
    if memoy.count = 0 then memoy.Add('0')
    else memoy.Add(memoy[memoy.count - 1]);
  end;
end;

function TRMSPLineChartView.ShowChart: Boolean;

  procedure splineDraw(Canvas: TCanvas);
  var
    bspline: TBspline;
    vertex: tvertex;
    i, j, error: integer;
    v: Tvertex;
    r, r1, t, width1: real;
    ma1, maxs1, mins1, maxs2, xlmax, xlmin: real;
    min1, bl: real;
    _l, _t, _r, _w, _h: integer;
    SPlines: TSPLines;
  begin
    SPlines := TSPlines.create(nil);
    Canvas.pen.Width := 1;
    _l := RealRect.Left;
    _w := RealRect.Right - RealRect.Left;
    _h := RealRect.Bottom - RealRect.Top;
    _r := RealRect.Right;
    _t := RealRect.Top;
    maxs1 := maxvalue(splx);
    mins1 := minvalue(splx);
    maxs2 := maxvalue(sply);
    ma1 := 0;
    r1 := 1;
    bspline := nil;
    xlmin := 0;
    min1 := 0;
    xlmax := 0;
    r := 0;
    if maxs1 <> mins1 then
    begin
      bspline := tbspline.create;
      if memox.Count > 0 then
      begin
        for i := 0 to memox.Count - 1 do
        begin
          val(memox.strings[i], vertex.x, error);
          val(memoy.strings[i], vertex.y, error);
          vertex.z := 0;
          bspline.addvertex(vertex);
        end;
      end;
      bspline.interpolate;
      splines.addspline(bspline);
      for i := 1 to splines.Numberofsplines do
      begin
        bspline := splines.getsplineNr(i);
        if bspline <> nil then
        begin
          ma1 := 0;
          min1 := maxs2;
          xlmin := maxs1;
          xlmax := 0;
          for j := 0 to 1000 do
          begin
            v := bspline.value(j / 1000);
            if min1 > v.y then min1 := v.y;
            if xlmin > v.x then xlmin := v.x; //含水率最小值
            if xlmax < v.x then xlmax := v.x; //含水率最大值
            if ma1 < v.y then
            begin
              ma1 := v.y;
            end;
          end;
        end;
      end;
      if xlmax - xlmin <> 0 then r := (_w - 40 * FactorX) / (xlmax - xlmin)
      else r := 1;
      if maxs2 - min1 <> 0 then r1 := (_h - 40 * FactorY) / (ma1 - min1)
      else r1 := 1;
    end;

    canvas.Pen.color := clblack;
    canvas.Pen.Style := psSolid;
    canvas.pen.Width := 2;
    canvas.Rectangle(_l + round(35 * FactorX), _t + round(20 * FactorY), RealRect.Right - round(4 * FactorX), RealRect.Bottom - round(19 * FactorY));
    canvas.pen.Width := 1;
    if (DocMode = rmdmPrinting) then canvas.Pen.color := clblack
    else canvas.Pen.color := clgray;
    canvas.Pen.Style := psdot;
    t := (_w - 40 * FactorX) / 24;
    Canvas.Font.Color := clblack;
    bl := (xlmax - xlmin) / 24;
    for i := 0 to 24 do //x轴
    begin
      if i in [0, 4, 8, 12, 16, 20, 24] then
      begin
        Canvas.Pen.Style := psSolid;
        Canvas.font.size := 9;
        width1 := canvas.TextWidth(trim(SysUtils.format('%4.1f', [xlmin + bl * i]))) div 2;
        if i = 24 then Canvas.TextOut(round(i * t + round(35 * FactorX) - width1 * 2) + _l, RealRect.Bottom - round(15 * FactorY), trim(SysUtils.format('%5.2f', [xlmin + bl * i])))
        else Canvas.TextOut(round(i * t + round(35 * FactorX) - width1) + _l, RealRect.Bottom - round(15 * FactorY), trim(SysUtils.format('%5.2f', [xlmin + bl * i])));
        if grs = 0 then
        begin
          Canvas.Moveto(round(i * t + round(35 * FactorX)) + _l, RealRect.Bottom - round(17 * FactorY));
          Canvas.Lineto(round(i * t + round(35 * FactorX)) + _l, RealRect.Top + round(20 * FactorY));
        end;
      end
      else Canvas.Pen.Style := psdot;
      if grs = 1 then
      begin
        if i in [0, 4, 8, 12, 16, 20, 24] then
          Canvas.Moveto(round(i * t + round(35 * FactorX)) + _l, RealRect.Bottom - round(17 * FactorY))
        else
          Canvas.Moveto(round(i * t + round(35 * FactorX)) + _l, RealRect.Bottom - round(20 * FactorY));
        Canvas.Lineto(round(i * t + round(35 * FactorX)) + _l, RealRect.Top + round(20 * FactorY));
      end;
    end;
    t := (_h - round(40 * FactorY)) / 24;
    bl := (ma1 - min1) / 24;
    for i := 24 downto 0 do
    begin
      if i in [0, 4, 8, 12, 16, 20, 24] then
      begin
        canvas.Pen.Style := psSolid;
        Canvas.font.size := 9;
        Canvas.TextOut(_L + round(2 * FactorX), RealRect.Bottom - round(i * t + round(25 * FactorY)), trim(SysUtils.format('%6.3f', [min1 + bl * i])));
        if grs = 0 then
        begin
          if i in [0, 4, 8, 12, 16, 20, 24] then
            Canvas.Moveto(_l + round(32 * FactorX), round(i * t + round(20 * FactorY)) + _t)
          else
            Canvas.Moveto(_l + round(35 * FactorX), round(i * t + round(20 * FactorY)) + _t);
          Canvas.Lineto(_r - round(5 * FactorX), round(i * t + round(20 * FactorY)) + _t);
        end;
      end
      else Canvas.Pen.Style := psdot;
      if grs = 1 then
      begin
        if i in [0, 4, 8, 12, 16, 20, 24] then
          Canvas.Moveto(_l + round(32 * FactorX), round(i * t + round(20 * FactorY)) + _t)
        else
          Canvas.Moveto(_l + round(35 * FactorX), round(i * t + round(20 * FactorY)) + _t);
        Canvas.Lineto(_r - round(5 * FactorX), round(i * t + round(20 * FactorY)) + _t);
      end;
    end;

    Canvas.Pen.Style := psSolid;
    Canvas.Brush.color := clwhite;
    Canvas.brush.Style := bssolid;
    if maxs1 <> mins1 then
    begin
      for i := 1 to splines.Numberofsplines do
      begin
        bspline := splines.getsplineNr(i);
        if bspline <> nil then
        begin
          ma1 := 0;
          for j := 0 to 1000 do
          begin
            v := bspline.value(j / 1000);
            if ma1 < v.y then
            begin
              ma1 := v.y;
            end;
            if j = 0 then
            begin
              if (DocMode = rmdmPrinting) then
                canvas.Pen.color := clblack
              else
                canvas.Pen.color := clred;
              canvas.moveto(round((v.x - xlmin) * r + round(35 * FactorX) + _l), round(RealRect.Bottom - round(20 * FactorY) - (v.y - min1) * r1));
            end
            else canvas.LineTo(round((v.x - xlmin) * r + round(35 * FactorX) + _l), round(RealRect.Bottom - round(20 * FactorY) - (v.y - min1) * r1));
          end;

          for j := 1 to bspline.numberofvertices do
          begin
            if bspline.interpolated then v := bspline.value((j - 1) / (bspline.numberofvertices - 1))
            else v := bspline.vertexnr(j);
            if (DocMode = rmdmPrinting) then canvas.Pen.color := clblack
            else canvas.Pen.color := clred;
            canvas.Ellipse(round((v.x - xlmin) * r + round(35 * FactorX) + _l) - round(2 * FactorX), (RealRect.Bottom - round(20 * FactorY)) - round((v.y - min1) * r1) - round(2 * FactorY), round((v.x - xlmin) * r + round(35 * FactorX)) + _l + 2, (RealRect.Bottom - round(20 * FactorY)) - round((v.y - min1) * r1) + round(2 * FactorY));
          end;
        end;
      end;
      splines.clear;
      bspline.free;
    end;
  end;

begin
  SPLineDraw(Canvas);
  Result := True;
end;

procedure TRMSPLineChartView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  ExpandVariables;
  savedataspline;
  CalcGaps;
  ShowBackground;
  ShowChart;
  ShowFrame;
  RestoreCoord;
end;

procedure TRMSPLineChartView.LoadFromStream(Stream: TStream);
var
  b: Byte;
begin
  inherited LoadFromStream(Stream);
  with Stream do
  begin
    Read(b, 1);
    read(grs, sizeof(grs));
  end;
end;

procedure TRMSPLineChartView.SaveToStream(Stream: TStream);
var
  b: Byte;
begin
  inherited SaveToStream(Stream);
  with Stream do
  begin
    b := 0; // internal chart version
    Write(b, 1);
    Write(grs, sizeof(grs));
  end;
end;

procedure TRMSPLineChartView.DefinePopupMenu(Popup: TPopupMenu);
begin
  // no specific items in popup menu
end;

procedure TRMSPLineChartView.OnHook(View: TRMView);
var
  i: Integer;
  s: string;
begin
  if Memo.Count < 2 then
  begin
    Memo.Clear;
    Memo.Add('');
    Memo.Add('');
  end;
  i := 0;
  Inc(CurStr);
  if i >= 0 then
  begin
    if Memo.Count <= i then
      while Memo.Count <= i do
        Memo.Add('');
    if THackView(View).Memo1.Count > 0 then
    begin
      s := THackView(View).Memo1[0];
      if LastLegend <> s then
        Memo[i] := Memo[i] + s + ';';
      LastLegend := s;
    end;
  end;
end;

procedure TRMSPLineChartView.ShowEditor;
var
  i: byte;
  tmp: TRMSPLineChartForm;
begin
  tmp := TRMSPLineChartForm.Create(nil);
  try
    with tmp do
    begin
      if grs = 1 then checkbox1.Checked := true
      else checkbox1.Checked := false;
      M1.Clear;
      if memo.Count > 0 then
      begin
        for i := 0 to memo.count - 1 do
        begin
          m1.Lines.Add(memo.strings[i]);
        end;
      end;
      if ShowModal = mrOk then
      begin
        if checkbox1.Checked then grs := 1
        else grs := 0;
        Memo.Clear;
        if m1.Lines.Count > 0 then
        begin
          for i := 0 to m1.lines.count - 1 do
            memo.Add(m1.lines.Strings[i]);
        end;
      end;
    end;
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMSPLineChartForm }

function TRMSPLineChartForm.ShowEditor(View: TRMView): TModalResult;
begin
  Result := mrOK;
end;

procedure TRMSPLineChartForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  Tab2.Caption := S_Page1;
  CheckBox1.Caption := S_CheckBox1;
  Label1.Caption := S_Label1;
  Button3.Caption := S_Button3;
  Caption := S_Caption;

  RMSetStrProp(Button1, 'Caption', SOK);
  RMSetStrProp(Button2, 'Caption', SCancel);
end;

procedure TRMSPLineChartForm.Button3Click(Sender: TObject);
var
  s: string;
begin
  s := RMDesigner.InsertDBField;
  if s <> '' then
  begin
    ClipBoard.Clear;
    ClipBoard.AsText := s;
    M1.PasteFromClipboard;
    M1.SetFocus;
  end;
{
  FieldsForm := TFieldsForm.Create(nil);
  with FieldsForm do
    if ShowModal = mrOk then
    begin
      ClipBoard.Clear;
      ClipBoard.AsText := '[' + DBField + ']';
      M1.PasteFromClipboard;
    end;
  FieldsForm.Free;
  M1.SetFocus;
}
end;

procedure TRMSPLineChartForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TRMSPLineChartForm.M1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Insert) and (Shift = []) then Button3Click(Self);
  if Key = vk_Escape then ModalResult := mrCancel;
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TRMSPLineChartForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

initialization
  RMRegisterObjectByRes(TRMSPLineChartView, 'RM_SPLineChartObject', 'B样条', nil);

finalization

end.

