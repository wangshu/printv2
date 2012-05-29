{*****************************************}
{                                         }
{         Report Machine v2.4             }
{           HTML Memo样式 Object          }
{                                         }
{*****************************************}

unit RM_htmlmemo;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Menus, ClipBrd, RM_Class, RM_Ctrls
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type

  TjanHTMLElement = class(TObject)
  private
    FFontSize: integer;
    FText: string;
    FFontName: string;
    FFontStyle: TFontStyles;
    FFontColor: TColor;
    FAscent: integer;
    FHeight: integer;
    FWidth: integer;
    FSolText: string;
    FEolText: string;
    FBreakLine: boolean;
    Fsups: boolean;
    Fsubs: boolean;
    procedure SetFontName(const Value: string);
    procedure SetFontSize(const Value: integer);
    procedure SetFontStyle(const Value: TFontStyles);
    procedure SetText(const Value: string);
    procedure SetFontColor(const Value: TColor);
    procedure SetAscent(const Value: integer);
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure SetEolText(const Value: string);
    procedure SetSolText(const Value: string);
    procedure SetBreakLine(const Value: boolean);
    procedure SetSup(const Value: boolean);
    procedure SetSub(const Value: boolean);
  protected
  public
    procedure Break(ACanvas: TCanvas; available: integer);
    property Text: string read FText write SetText;
    property SolText: string read FSolText write SetSolText;
    property EolText: string read FEolText write SetEolText;
    property FontName: string read FFontName write SetFontName;
    property FontSize: integer read FFontSize write SetFontSize;
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle;
    property FontColor: TColor read FFontColor write SetFontColor;
    property Height: integer read FHeight write SetHeight;
    property Width: integer read FWidth write SetWidth;
    property Ascent: integer read FAscent write SetAscent;
    property BreakLine: boolean read FBreakLine write SetBreakLine;
    property Sups: boolean read FSups write SetSup;
    property Subs: boolean read FSubs write SetSub;
  end;

  TjanHTMLElementStack = class(TList)
  private
  protected
  public
    destructor Destroy; override;
    procedure Clear; override;
    // will free ALL elements in the stack
    procedure push(Element: TjanHTMLElement);
    function pop: TjanHTMLElement;
    // calling routine is responsible for freeing the element.
    function peek: TjanHTMLElement;
    // calling routine must NOT free the element
  end;

  TjanMarkupLabel = class(TGraphicControl)
  private
    { Private declarations }
    ElementStack: TjanHTMLElementStack;
    TagStack: TjanHTMLElementStack;
    FText: string;
    FBackColor: TColor;
    FMarginLeft: integer;
    FMarginRight: integer;
    FMarginTop: integer;
    procedure ParseHTML(s: string);
    procedure RenderHTML;
    procedure HTMLClearBreaks;
    procedure HTMLElementDimensions;
    procedure SetBackColor(const Value: TColor);
    procedure SetText(const Value: string);
    procedure SetMarginLeft(const Value: integer);
    procedure SetMarginRight(const Value: integer);
    procedure SetMarginTop(const Value: integer);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    { Published declarations }
    property Text: string read FText write SetText;
    property BackColor: TColor read FBackColor write SetBackColor;
    property MarginLeft: integer read FMarginLeft write SetMarginLeft;
    property MarginRight: integer read FMarginRight write SetMarginRight;
    property MarginTop: integer read FMarginTop write SetMarginTop;
  end;

  TRMHTMLMemoObject = class(TComponent) // fake component
  end;

  THTMLElement = class(TObject)
  private
    FFontSize: integer;
    FText: string;
    FFontName: string;
    FFontStyle: TFontStyles;
    FFontColor: TColor;
    FAscent: integer;
    FHeight: integer;
    FWidth: integer;
    FSolText: string;
    FEolText: string;
    FBreakLine: boolean;
    Fsups: boolean;
    Fsubs: boolean;
    Fspans: boolean;
    procedure SetFontName(const Value: string);
    procedure SetFontSize(const Value: integer);
    procedure SetFontStyle(const Value: TFontStyles);
    procedure SetText(const Value: string);
    procedure SetFontColor(const Value: TColor);
    procedure SetAscent(const Value: integer);
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure SetEolText(const Value: string);
    procedure SetSolText(const Value: string);
    procedure SetBreakLine(const Value: boolean);
    procedure SetSup(const Value: boolean);
    procedure SetSub(const Value: boolean);
    procedure Setspan(const Value: boolean);
  protected
  public
    procedure Break(ACanvas: TCanvas; available: integer);
    property Text: string read FText write SetText;
    property SolText: string read FSolText write SetSolText;
    property EolText: string read FEolText write SetEolText;
    property FontName: string read FFontName write SetFontName;
    property FontSize: integer read FFontSize write SetFontSize;
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle;
    property FontColor: TColor read FFontColor write SetFontColor;
    property Height: integer read FHeight write SetHeight;
    property Width: integer read FWidth write SetWidth;
    property Ascent: integer read FAscent write SetAscent;
    property BreakLine: boolean read FBreakLine write SetBreakLine;
    property Sups: boolean read FSups write SetSup;
    property Subs: boolean read FSubs write SetSub;
    property Spans: boolean read FSpans write SetSpan;
  end;

  THTMLElementStack = class(TList)
  private
  protected
  public
    destructor Destroy; override;
    procedure Clear; override;
    procedure push(Element: THTMLElement);
    function pop: THTMLElement;
    function peek: THTMLElement;
  end;

  TRMHTMLMemoView = class(TRMReportView)
  private
    ElementStack: THTMLElementStack;
    TagStack: THTMLElementStack;
    FText: string;
    FBackColor: TColor;
    FMarginLeft: integer;
    FMarginRight: integer;
    FMarginTop: integer;
    procedure ParseHTML(s: string);
    procedure HTMLClearBreaks;
    procedure SetBackColor(const Value: TColor);
    procedure SetMarginLeft(const Value: integer);
    procedure SetMarginRight(const Value: integer);
    procedure SetMarginTop(const Value: integer);
    function ShowHTML: Boolean;
  protected
    procedure ExpandVariables;
  public
    VDC, HDC: byte;
    width1, height1: integer;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure OnHook(View: TRMView); override;
    procedure RenderHTML;
    procedure writeHTML(value: string);
    procedure HTMLElementDimensions;
    procedure ShowEditor; override;
  published
    property BackColor: TColor read FBackColor write SetBackColor;
    property MarginLeft: integer read FMarginLeft write SetMarginLeft;
    property MarginRight: integer read FMarginRight write SetMarginRight;
    property MarginTop: integer read FMarginTop write SetMarginTop;
  end;

  { TRMHtmlForm }
  TRMHtmlForm = class(TRMObjEditorForm)
    Button1: TButton;
    Button2: TButton;
    ScrollBox1: TScrollBox;
    FontDialog1: TFontDialog;
    Panel1: TPanel;
    M1: TMemo;
    Button3: TButton;
    btnFont: TSpeedButton;
    btnFontItalic: TSpeedButton;
    btnFontBold: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton1: TSpeedButton;
    GroupBox1: TGroupBox;
    HLB: TSpeedButton;
    HCB: TSpeedButton;
    HRB: TSpeedButton;
    VLB: TSpeedButton;
    VCB: TSpeedButton;
    VRB: TSpeedButton;
    Label1: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure M1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure M1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure btnFontItalicClick(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure btnFontBoldClick(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FLabel: TjanMarkupLabel;

    procedure Localize;
  public
    function ShowEditor(View: TRMView): TModalResult; override;
  end;

implementation

uses RM_Const, RM_Utils, RM_Common;

{$R *.DFM}

function RMHTMLStringToColor(v: string; var col: Tcolor): boolean;
var
  vv: string;
begin
  if copy(v, 1, 1) <> '#' then
  begin
    vv := 'cl' + v;
    try
      col := stringtoColor(vv);
      result := true;
    except
      result := false;
    end;
  end
  else
  begin
    try
      vv := '$' + copy(v, 6, 2) + copy(v, 4, 2) + copy(v, 2, 2);
      col := stringtocolor(vv);
      result := true;
    except
      result := false;
    end
  end
end;

{ TjanHTMLElement }

procedure TjanHTMLElement.Break(ACanvas: TCanvas; available: integer);
var
  s: string;
  i, w: integer;
begin
  Acanvas.font.name := fontname;
  Acanvas.font.size := fontsize;
  Acanvas.font.style := fontstyle;
  Acanvas.font.color := fontcolor;
  if solText = '' then
    s := Text
  else
    s := Eoltext;
  if acanvas.TextWidth(s) <= available then
  begin
    soltext := s;
    eoltext := '';
    exit;
  end;
  for i := length(s) downto 1 do
  begin
    if s[i] = ' ' then
    begin
      w := acanvas.TextWidth(copy(s, 1, i));
      if w <= available then
      begin
        soltext := copy(s, 1, i);
        eoltext := copy(s, i + 1, length(s));
        exit;
      end;
    end;
  end;
end;

procedure TjanHTMLElement.SetAscent(const Value: integer);
begin
  FAscent := Value;
end;

procedure TjanHTMLElement.SetBreakLine(const Value: boolean);
begin
  FBreakLine := Value;
end;

procedure TjanHTMLElement.SetSup(const Value: boolean);
begin
  FSups := Value;
end;

procedure TjanHTMLElement.SetSub(const Value: boolean);
begin
  FSubs := Value;
end;

procedure TjanHTMLElement.SetEolText(const Value: string);
begin
  FEolText := Value;
end;

procedure TjanHTMLElement.SetFontColor(const Value: TColor);
begin
  FFontColor := Value;
end;

procedure TjanHTMLElement.SetFontName(const Value: string);
begin
  FFontName := Value;
end;

procedure TjanHTMLElement.SetFontSize(const Value: integer);
begin
  FFontSize := Value;
end;

procedure TjanHTMLElement.SetFontStyle(const Value: TFontStyles);
begin
  FFontStyle := Value;
end;

procedure TjanHTMLElement.SetHeight(const Value: integer);
begin
  FHeight := Value;
end;

procedure TjanHTMLElement.SetSolText(const Value: string);
begin
  FSolText := Value;
end;

procedure TjanHTMLElement.SetText(const Value: string);
begin
  FText := Value;
end;

procedure TjanHTMLElement.SetWidth(const Value: integer);
begin
  FWidth := Value;
end;

{ TjanHTMLElementStack }

procedure TjanHTMLElementStack.Clear;
var
  i, c: integer;
begin
  c := count;
  if c > 0 then
    for i := 0 to c - 1 do
      TjanHTMLElement(items[i]).free;
  inherited;
end;

destructor TjanHTMLElementStack.Destroy;
begin
  clear;
  inherited;
end;

function TjanHTMLElementStack.peek: TjanHTMLElement;
var
  c: integer;
begin
  c := count;
  if c = 0 then
    result := nil
  else
  begin
    result := TjanHTMLElement(items[c - 1]);
  end;
end;

function TjanHTMLElementStack.pop: TjanHTMLElement;
var
  c: integer;
begin
  c := count;
  if c = 0 then
    result := nil
  else
  begin
    result := TjanHTMLElement(items[c - 1]);
    delete(c - 1);
  end;
end;

procedure TjanHTMLElementStack.push(Element: TjanHTMLElement);
begin
  add(Element);
end;

{ TjanMarkupLabel }

constructor TjanMarkupLabel.create(AOwner: TComponent);
begin
  inherited;
  Elementstack := TjanHTMLElementStack.Create;
  TagStack := TjanHTMLElementStack.Create;
  FBackcolor := clwhite;
  Width := 200;
  Height := 100;
  FMarginLeft := 5;
  FMarginRight := 5;
  FMargintop := 5;
end;

destructor TjanMarkupLabel.destroy;
begin
  ElementStack.free;
  TagStack.free;
  inherited;
end;

procedure TjanMarkupLabel.HTMLClearBreaks;
var
  i, c: integer;
  El: TjanHTMLElement;
begin
  c := ElementStack.Count;
  if c = 0 then exit;
  for i := 0 to c - 1 do
  begin
    el := TjanHTMLElement(ElementStack.items[i]);
    el.SolText := '';
    el.EolText := '';
  end;
end;

procedure TjanMarkupLabel.HTMLElementDimensions;
var
  i, c: integer;
  El: TjanHTMLElement;
  h, a, w: integer;
  tm: Textmetric;
  s: string;
begin
  c := ElementStack.Count;
  if c = 0 then exit;
  for i := 0 to c - 1 do
  begin
    el := TjanHTMLElement(ElementStack.items[i]);
    s := el.Text;
    canvas.font.name := el.FontName;
    canvas.font.size := el.FontSize;
    canvas.font.style := el.FontStyle;
    canvas.font.Color := el.FontColor;
    gettextmetrics(canvas.handle, tm);
    h := tm.tmHeight;
    a := tm.tmAscent;
    w := canvas.TextWidth(s);
    el.Height := h;
    el.Ascent := a;
    el.Width := w;
  end;
end;

procedure TjanMarkupLabel.paint;
begin
  RenderHTML;
end;

procedure TjanMarkupLabel.ParseHTML(s: string);
var
  p: integer;
  se, st: string;
  ftext: string;
  fstyle: TfontStyles;
  sup, sub: boolean;
  fname: string;
  fsize: integer;
  fbreakLine: boolean;
  aColor, fColor: Tcolor;
  Element: TjanHTMLElement;

  procedure pushTag;
  begin
    Element := TjanHTMLElement.Create;
    element.FontName := fname;
    element.FontSize := fsize;
    element.FontStyle := fstyle;
    element.FontColor := fColor;
    Element.Sups := sup;
    Element.Subs := sub;
    TagStack.push(Element);
  end;

  procedure popTag;
  begin
    Element := TagStack.pop;
    if element <> nil then
    begin
      fname := element.FontName;
      fsize := element.FontSize;
      fstyle := element.FontStyle;
      fcolor := element.FontColor;
      Element.sups := element.sups;
      Element.subs := element.subs;
      Element.Free;
    end;
  end;

  procedure pushElement;
  begin
    Element := TjanHTMLElement.Create;
    Element.Text := ftext;
    element.FontName := fname;
    element.FontSize := fsize;
    element.FontStyle := fstyle;
    element.FontColor := fColor;
    element.BreakLine := fBreakLine;
    fBreakLine := false;
    element.sups := sup;
    sup := false;
    element.subs := sub;
    sub := false;
    ElementStack.push(Element);
  end;

  procedure parseTag(ss: string);
  var
    pp: integer;
    atag, apar, aval: string;
    havepar: boolean;
  begin
    ss := trim(ss);
    havepar := false;
    pp := pos(' ', ss);
    if pp = 0 then
    begin // tag only
      atag := ss;
    end
    else
    begin // tag + atrributes
      atag := copy(ss, 1, pp - 1);
      ss := trim(copy(ss, pp + 1, length(ss)));
      havepar := true;
    end;
    // handle atag
    atag := lowercase(atag);
    if atag = 'br' then
      fBreakLine := true
    else if atag = 'b' then
    begin // bold
      pushtag;
      fstyle := fstyle + [fsbold];
    end
    else if atag = '/b' then
    begin // cancel bold
      fstyle := fstyle - [fsbold];
      poptag;
    end
    else if atag = 'i' then
    begin // italic
      pushtag;
      fstyle := fstyle + [fsitalic];
    end
    else if atag = '/i' then
    begin // cancel italic
      fstyle := fstyle - [fsitalic];
      poptag;
    end
    else if atag = 'u' then
    begin // underline
      pushtag;
      fstyle := fstyle + [fsunderline];
    end
    else if atag = '/u' then
    begin // cancel underline
      fstyle := fstyle - [fsunderline];
      poptag;
    end
    else if atag = 'font' then
    begin
      pushtag;
    end
    else if atag = '/font' then
    begin
      poptag;
    end
    else if atag = 'sup' then
    begin
      pushtag;
      sup := true;
    end
    else if atag = '/sup' then
    begin
      sup := false;
      poptag;
    end
    else if atag = 'sub' then
    begin
      pushtag;
      sub := true;
    end
    else if atag = '/sub' then
    begin
      sub := false;
      poptag;
    end;
    if havepar then
    begin
      repeat
        pp := pos('="', ss);
        if pp > 0 then
        begin
          aPar := lowercase(trim(copy(ss, 1, pp - 1)));
          delete(ss, 1, pp + 1);
          pp := pos('"', ss);
          if pp > 0 then
          begin
            aVal := copy(ss, 1, pp - 1);
            delete(ss, 1, pp);
            if aPar = 'face' then
            begin
              fname := aVal;
            end
            else if aPar = 'size' then
            try
              fsize := strtoint(aval);
            except
            end
            else if aPar = 'color' then
            try
              if RMHTMLStringToColor(aval, aColor) then
                fcolor := aColor;
            except
            end
          end;
        end;
      until pp = 0;
    end;
  end;
begin
  ElementStack.Clear;
  TagStack.Clear;
  fstyle := [];
  fname := '宋体';
  fsize := 9;
  fColor := clblack;
  fBreakLine := false;
  sup := false;
  sub := false;
  repeat
    p := pos('<', s);
    if p = 0 then
    begin
      fText := s;
      PushElement;
    end
    else
    begin
      if p > 1 then
      begin
        se := copy(s, 1, p - 1);
        ftext := se;
        pushElement;
        delete(s, 1, p - 1);
      end;
      p := pos('>', s);
      if p > 0 then
      begin
        st := copy(s, 2, p - 2);
        delete(s, 1, p);
        parseTag(st);
      end;
    end;
  until p = 0;
end;

procedure TjanMarkupLabel.RenderHTML;
var
  R: trect;
  x, y, xav, clw: integer;
  baseline: integer;
  i, c: integer;
  el: TjanHTMLElement;
  eol: boolean;
  ml: integer; // margin left
  isol, ieol: integer;
  maxheight, maxascent: integer;
  pendingBreak: boolean;

  procedure SetFont(ee: TjanHTMLElement);
  begin
    with canvas do
    begin
      font.name := ee.FontName;
      font.Size := ee.FontSize;
      font.Style := ee.FontStyle;
      font.Color := ee.FontColor;
    end;
  end;

  procedure RenderString(ee: TjanHTMLElement);
  var
    ss: string;
    ww: integer;
    t: integer;
  begin
    t := ee.FFontSize;
    SetFont(ee);
    if ee.soltext <> '' then
    begin
      if (ee.fsups) or (ee.fsubs) then
      begin
        t := ee.FFontSize;
        ee.FFontSize := ee.FFontSize div 2;
        SetFont(ee);
      end;
      ss := ee.SolText;
      ww := canvas.TextWidth(ss);
      if ee.Subs then canvas.TextOut(x, y + baseline - ee.Ascent div 2, ss)
      else canvas.TextOut(x, y + baseline - ee.Ascent, ss);
      x := x + ww;
    end;
    if (ee.fsups) or (ee.fsubs) then
    begin
      ee.FFontSize := t;
      SetFont(ee);
    end;
  end;

begin
  R := clientrect;
  canvas.Brush.color := BackColor;
  canvas.FillRect(R);
  c := ElementStack.Count;
  if c = 0 then exit;
  HTMLClearBreaks;
  clw := ClientWidth - FMarginRight;
  ml := MarginLeft;
  canvas.Brush.style := bsclear;
  y := FMarginTop;
  isol := 0;
  pendingBreak := false;
  ieol := 0;
  repeat
    i := isol;
    xav := clw;
    maxHeight := 0;
    maxAscent := 0;
    eol := false;
    repeat // scan line
      el := TjanHTMLElement(ElementStack.items[i]);
      if el.BreakLine then
      begin
        if not pendingBreak then
        begin
          pendingBreak := true;
          ieol := i;
          break;
        end
        else
          pendingBreak := false;
      end;
      if el.Height > maxheight then maxheight := el.Height;
      if el.Ascent > maxAscent then maxAscent := el.Ascent;
      el.Break(canvas, xav);
      if el.soltext <> '' then
      begin
        xav := xav - canvas.TextWidth(el.Soltext);
        if el.EolText = '' then
        begin
          if i >= c - 1 then
          begin
            eol := true;
            ieol := i;
          end
          else
          begin
            inc(i);
          end
        end
        else
        begin
          eol := true;
          ieol := i;
        end;
      end
      else
      begin // eol
        eol := true;
        ieol := i;
      end;
    until eol;
    // render line
    x := ml;
    baseline := maxAscent;
    for i := isol to ieol do
    begin
      el := TjanHTMLElement(ElementStack.items[i]);
      RenderString(el);
    end;
    y := y + maxHeight;
    isol := ieol;
  until (ieol >= c - 1) and (el.EolText = '');
end;

procedure TjanMarkupLabel.SetBackColor(const Value: TColor);
begin
  if value <> FBackColor then
  begin
    FBackcolor := Value;
    invalidate;
  end;
end;

procedure TjanMarkupLabel.SetMarginLeft(const Value: integer);
begin
  FMarginLeft := Value;
  invalidate;
end;

procedure TjanMarkupLabel.SetMarginRight(const Value: integer);
begin
  FMarginRight := Value;
  invalidate;
end;

procedure TjanMarkupLabel.SetMarginTop(const Value: integer);
begin
  FMarginTop := Value;
  invalidate;
end;

procedure TjanMarkupLabel.SetText(const Value: string);
const
  cr = chr(13) + chr(10);
  tab = chr(9);
var
  s: string;
begin
  if value = FText then exit;
  s := value;
  s := stringreplace(s, cr, ' ', [rfreplaceall]);
  s := Trimright(s);
  parseHTML(s);
  HTMLElementDimensions;
  FText := s;
  invalidate;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMHTMLMemoView }

constructor TRMHTMLMemoView.Create;
begin
  inherited Create;
  BaseName := 'HTMLMemo';
  Elementstack := THTMLElementStack.Create;
  TagStack := THTMLElementStack.Create;
  FBackcolor := clwhite;
  FMarginLeft := 5;
  FMarginRight := 5;
  FMargintop := 5;
  Vdc := 1;
  hdc := 1;
  FFlags := 1; // Flags or flWantHook;
  memo.Clear;
end;

destructor TRMHTMLMemoView.Destroy;
begin
  ElementStack.free;
  TagStack.free;
  inherited Destroy; //2002.1.14 LBZ Move
end;

procedure THTMLElement.Break(ACanvas: TCanvas; available: integer);
var
  s: string;
  t, t1, i, w: integer;
begin
  Acanvas.font.name := fontname;
  Acanvas.font.size := fontsize;
  t := fontsize;
  t1 := t;
  if (sups) or (subs) then t := t div 2;
  Acanvas.font.size := t;
  Acanvas.font.style := fontstyle;
  Acanvas.font.color := fontcolor;
  if solText = '' then
    s := Text
  else
    s := Eoltext;
  if acanvas.TextWidth(s) <= available then
  begin
    soltext := s;
    eoltext := '';
    exit;
  end;
  for i := length(s) downto 1 do
  begin
    if s[i] = ' ' then
    begin
      w := acanvas.TextWidth(copy(s, 1, i));
      if w <= available then
      begin
        soltext := copy(s, 1, i);
        eoltext := copy(s, i + 1, length(s));
        exit;
      end;
    end;
  end;
  fontsize := t1;
  Acanvas.font.size := t1;
end;

procedure THTMLElement.SetAscent(const Value: integer);
begin
  FAscent := Value;
end;

procedure THTMLElement.SetBreakLine(const Value: boolean);
begin
  FBreakLine := Value;
end;

procedure THTMLElement.SetSup(const Value: boolean);
begin
  FSups := Value;
end;

procedure THTMLElement.SetSub(const Value: boolean);
begin
  FSubs := Value;
end;

procedure THTMLElement.SetSpan(const Value: boolean);
begin
  Fspans := Value;
end;

procedure THTMLElement.SetEolText(const Value: string);
begin
  FEolText := Value;
end;

procedure THTMLElement.SetFontColor(const Value: TColor);
begin
  FFontColor := Value;
end;

procedure THTMLElement.SetFontName(const Value: string);
begin
  FFontName := Value;
end;

procedure THTMLElement.SetFontSize(const Value: integer);
begin
  FFontSize := Value;
end;

procedure THTMLElement.SetFontStyle(const Value: TFontStyles);
begin
  FFontStyle := Value;
end;

procedure THTMLElement.SetHeight(const Value: integer);
begin
  FHeight := Value;
end;

procedure THTMLElement.SetSolText(const Value: string);
begin
  FSolText := Value;
end;

procedure THTMLElement.SetText(const Value: string);
begin
  FText := Value;
end;

procedure THTMLElement.SetWidth(const Value: integer);
begin
  FWidth := Value;
end;

{ THTMLElementStack }

procedure THTMLElementStack.Clear;
var
  i, c: integer;
begin
  c := count;
  if c > 0 then
    for i := 0 to c - 1 do
      THTMLElement(items[i]).free;
  inherited;
end;

destructor THTMLElementStack.Destroy;
begin
  clear;
  inherited;
end;

function THTMLElementStack.peek: THTMLElement;
var
  c: integer;
begin
  c := count;
  if c = 0 then
    result := nil
  else
  begin
    result := THTMLElement(items[c - 1]);
  end;
end;

function THTMLElementStack.pop: THTMLElement;
var
  c: integer;
begin
  c := count;
  if c = 0 then
    result := nil
  else
  begin
    result := THTMLElement(items[c - 1]);
    delete(c - 1);
  end;
end;

procedure THTMLElementStack.push(Element: THTMLElement);
begin
  add(Element);
end;

(**********************************)

procedure TRMHTMLMemoView.HTMLClearBreaks;
var
  i, c: integer;
  El: THTMLElement;
begin
  c := ElementStack.Count;
  if c = 0 then exit;
  for i := 0 to c - 1 do
  begin
    el := THTMLElement(ElementStack.items[i]);
    el.SolText := '';
    el.EolText := '';
  end;
end;

procedure TRMHTMLMemoView.HTMLElementDimensions;
var
  i, c, t, t1: integer;
  El: THTMLElement;
  h, a, w: integer;
  tm: Textmetric;
  s: string;
begin
  //  SetTextCharacterExtra(Canvas.Handle, CharSpacing);
  c := ElementStack.Count;
  width1 := 0;
  height1 := 0;
  if c = 0 then exit;
  for i := 0 to c - 1 do
  begin
    el := THTMLElement(ElementStack.items[i]);
    s := el.Text;
    t := el.FontSize;
    t1 := t;
    if (el.Sups) or (el.Subs) then t := t div 2;
    canvas.font.size := t;
    //    canvas.font.size := el.fontsize;
    canvas.font.name := el.FontName;
    canvas.font.style := el.FontStyle;
    canvas.font.Color := el.FontColor;
    w := canvas.TextWidth(s);
    canvas.font.size := t1;
    gettextmetrics(canvas.handle, tm);
    h := tm.tmHeight;
    a := tm.tmAscent;
    canvas.font.size := t1;
    width1 := width1 + w;
    el.Height := h;
    el.Ascent := a;
    el.Width := w;
    if height1 < h then height1 := h;
  end;
end;

procedure TRMHTMLMemoView.ParseHTML(s: string);
var
  p: integer;
  se, st: string;
  ftext: string;
  fstyle: TfontStyles;
  sup, sub, span: boolean;
  fname: string;
  fsize: integer;
  fbreakLine: boolean;
  aColor, fColor: Tcolor;
  Element: THTMLElement;

  procedure pushTag;
  begin
    Element := THTMLElement.Create;
    element.FontName := fname;
    element.FontSize := fsize;
    element.FontStyle := fstyle;
    element.FontColor := fColor;
    Element.Sups := sup;
    Element.Subs := sub;
    Element.Spans := span;
    TagStack.push(Element);
  end;

  procedure popTag;
  begin
    Element := TagStack.pop;
    if element <> nil then
    begin
      fname := element.FontName;
      fsize := element.FontSize;
      fstyle := element.FontStyle;
      fcolor := element.FontColor;
      Element.sups := element.sups;
      Element.subs := element.subs;
      Element.spans := element.spans;
      Element.Free;
    end;
  end;

  procedure pushElement;
  begin
    Element := THTMLElement.Create;
    Element.Text := ftext;
    element.FontName := fname;
    element.FontSize := fsize;
    element.FontStyle := fstyle;
    element.FontColor := fColor;
    element.BreakLine := fBreakLine;
    fBreakLine := false;
    element.sups := sup;
    sup := false;
    element.subs := sub;
    sub := false;
    element.spans := span;
    span := false;
    ElementStack.push(Element);
  end;

  procedure parseTag(ss: string);
  var
    pp, error: integer;
    atag, apar, aval: string;
    havepar: boolean;
  begin
    ss := trim(ss);
    havepar := false;
    pp := pos(' ', ss);
    if pp = 0 then
    begin // tag only
      atag := ss;
    end
    else
    begin // tag + atrributes
      atag := copy(ss, 1, pp - 1);
      ss := trim(copy(ss, pp + 1, length(ss)));
      havepar := true;
    end;
    // handle atag
    atag := lowercase(atag);
    if atag = 'br' then
      fBreakLine := true
    else if atag = 'b' then
    begin // bold
      pushtag;
      fstyle := fstyle + [fsbold];
    end
    else if atag = '/b' then
    begin // cancel bold
      fstyle := fstyle - [fsbold];
      poptag;
    end
    else if atag = 'i' then
    begin // italic
      pushtag;
      fstyle := fstyle + [fsitalic];
    end
    else if atag = '/i' then
    begin // cancel italic
      fstyle := fstyle - [fsitalic];
      poptag;
    end
    else if atag = 'u' then
    begin // underline
      pushtag;
      fstyle := fstyle + [fsunderline];
    end
    else if atag = '/u' then
    begin // cancel underline
      fstyle := fstyle - [fsunderline];
      poptag;
    end
    else if atag = 'font' then
    begin
      pushtag;
    end
    else if atag = '/font' then
    begin
      poptag;
    end
    else if atag = 'sup' then
    begin
      pushtag;
      sup := true;
    end
    else if atag = '/sup' then
    begin
      sup := false;
      poptag;
    end
    else if atag = 'sub' then
    begin
      pushtag;
      sub := true;
    end
    else if atag = '/sub' then
    begin
      sub := false;
      poptag;
    end
    else if atag = 'span' then
    begin
      pushtag;
      span := true;
    end
    else if atag = '/span' then
    begin
      span := false;
      poptag;
    end;
    if havepar then
    begin
      repeat
        pp := pos('="', ss);
        if pp > 0 then
        begin
          aPar := lowercase(trim(copy(ss, 1, pp - 1)));
          delete(ss, 1, pp + 1);
          pp := pos('"', ss);
          if pp > 0 then
          begin
            aVal := copy(ss, 1, pp - 1);
            delete(ss, 1, pp);
            if aPar = 'face' then
            begin
              fname := aVal;
            end
            else if aPar = 'size' then
            try
              val(aval, fsize, error);
            except
            end
            else if aPar = 'color' then
            try
              if RMHTMLStringToColor(aval, aColor) then
                fcolor := aColor;
            except
            end
          end;
        end;
      until pp = 0;
    end;
  end;
begin
  ElementStack.Clear;
  TagStack.Clear;
  fstyle := [];
  fname := '宋体';
  fsize := 9;
  fColor := clblack;
  fBreakLine := false;
  sup := false;
  sub := false;
  span := false;
  repeat
    p := pos('<', s);
    if p = 0 then
    begin
      fText := s;
      PushElement;
    end
    else
    begin
      if p > 1 then
      begin
        se := copy(s, 1, p - 1);
        ftext := se;
        pushElement;
        delete(s, 1, p - 1);
      end;
      p := pos('>', s);
      if p > 0 then
      begin
        st := copy(s, 2, p - 2);
        delete(s, 1, p);
        parseTag(st);
      end;
    end;
  until p = 0;
end;

procedure TRMHTMLMemoView.RenderHTML;
var
  x1, y1, x, xold, y, xav, clw: integer;
  baseline: integer;
  i, i0, c: integer;
  el: THTMLElement;
  eol: boolean;
  ml: integer; // margin left
  isol, ieol: integer;
  maxheight, maxascent: integer;
  pendingBreak: boolean;
  SMemo: TStringList; // temporary memo used during TRMView drawing

  procedure SetFont(ee: THTMLElement);
  begin
    with canvas do
    begin
      font.name := ee.FontName;
      font.Size := ee.FontSize;
      font.Style := ee.FontStyle;
      font.Color := ee.FontColor;
    end;
  end;

  procedure OutLine(const str: string);
  begin
    SMemo.Add(str);
  end;

  procedure WrapLine(const s: string; x: integer);
  var
    k, cur, beg, last: Integer;
    bIsDBCS: Boolean;
    iCutlength: integer;
  begin
    //  SetTextCharacterExtra(Canvas.Handle, CharSpacing);
    last := 1;
    beg := 1;
    if (Length(s) <= 1) or (x + Canvas.TextWidth(s) <= spWidth + RealRect.Left) then OutLine(s)
    else
    begin
      bisdbcs := false;
      k := 0;
      for cur := 1 to Length(s) do
      begin
        icutlength := cur;
        if bIsDBCS then
        begin
          bIsDBCS := false;
          k := 0;
        end
        else
          if windows.isDBCSLeadByte(byte(s[cur])) then
          begin
            bIsDBCS := true; //判断是否为中文
            k := 1;
          end;
        if x + Canvas.TextWidth(Copy(s, beg, cur - beg + 1 + k)) >= spWidth + RealRect.Left then //>= maxwidth
        begin
          x := xold;
          if bisDBCS then dec(icutlength); //如果最后一个字是中文，少截一个字节
          if last = beg then last := icutlength; //if last = beg then last := cur;
          outLine(copy(s, beg, last - beg + 1));
          if last = length(s) then //1999.4.26  if last = cur then
          begin
            beg := cur;
            break;
          end;
          beg := last + 1;
          last := beg;
        end;
      end;
      if beg <> cur then OutLine(Copy(s, beg, cur - beg + 1));
    end;
  end;

  procedure RenderString(ee: THTMLElement);
  var
    ss, s1: string;
    i: integer;
    t: integer;

    procedure showchar(s1: string);
    begin
      if ee.Subs then canvas.TextOut(x, y + baseline - ee.Ascent div 2, s1)
      else canvas.TextOut(x, y + baseline - ee.Ascent, s1);
      if ee.Fspans then //上划线
      begin
        canvas.pen.Width := 1;
        canvas.pen.color := ee.FontColor;
        canvas.pen.Style := psSolid;
        if ee.Subs then
        begin
          canvas.MoveTo(x, y + baseline - ee.Ascent div 2);
          canvas.LineTo(x + canvas.TextWidth(s1), y + baseline - ee.Ascent div 2);
        end
        else
        begin
          canvas.MoveTo(x, y + baseline - ee.Ascent);
          canvas.LineTo(x + canvas.TextWidth(s1), y + baseline - ee.Ascent);
        end;
      end;
      x := x + canvas.TextWidth(s1);
    end;

  begin
    t := ee.FFontSize;
    SetFont(ee);
    if ee.soltext <> '' then
    begin
      if (ee.fsups) or (ee.fsubs) then
      begin
        t := ee.FFontSize;
        ee.FFontSize := ee.FFontSize div 2;
        SetFont(ee);
      end;
      ss := ee.SolText;
      s1 := '';
      i0 := 1;
      SMemo := TStringList.Create;
      smemo.Clear;
      WrapLine(ss, x);
      if smemo.Count > 0 then
      begin
        for i := 0 to smemo.Count - 1 do
        begin
          if (y < spHeight + RealRect.Top - maxheight) then showchar(smemo[i]);
          if i = smemo.Count - 1 then
          begin
            if x > spWidth + RealRect.Left then
            begin
              x := xold;
              y := y + maxHeight;
            end;
          end
          else
          begin
            x := xold;
            y := y + maxHeight;
          end;
        end;
      end;
      smemo.free;
    end;
    if (ee.fsups) or (ee.fsubs) then
    begin
      ee.FFontSize := t;
      SetFont(ee);
    end;
  end;

  (***************************************)
  function HTMLLine(ee: THTMLElement): integer;
  var
    ss, s1: string;
    i: integer;
    t: integer;

    procedure showchar(s1: string);
    begin
      x := x + canvas.TextWidth(s1);
    end;

  begin
    t := ee.FFontSize;
    SetFont(ee);
    if ee.soltext <> '' then
    begin
      if (ee.fsups) or (ee.fsubs) then
      begin
        t := ee.FFontSize;
        ee.FFontSize := ee.FFontSize div 2;
        SetFont(ee);
      end;
      ss := ee.SolText;
      s1 := '';
      i0 := 1;
      SMemo := TStringList.Create;
      smemo.Clear;
      WrapLine(ss, x);
      if smemo.Count > 0 then
      begin
        for i := 0 to smemo.Count - 1 do
        begin
          if (y < spHeight + RealRect.Top - maxheight) then showchar(smemo[i]);
          if i = smemo.Count - 1 then
          begin
            if x > spWidth + RealRect.Left then
            begin
              x := xold;
              y := y + maxHeight;
            end;
          end
          else
          begin
            x := xold;
            y := y + maxHeight;
          end;
        end;
      end;
      smemo.free;
    end;
    if (ee.fsups) or (ee.fsubs) then
    begin
      ee.FFontSize := t;
      SetFont(ee);
    end;
    result := 0;
  end;
  (***************************************)

begin
  //  SetTextCharacterExtra(Canvas.Handle, CharSpacing);
  canvas.Brush.color := BackColor;
  canvas.Brush.style := bsclear;
  c := ElementStack.Count;
  if c = 0 then exit;
  HTMLClearBreaks;
  clw := spWidth;
  if width1 > spWidth then clw := width1 + spGapLeft;
  ml := spGapLeft;
  isol := 0;
  {
    y := gapy + RealRect.Top;
    if height1 < spHeight then
    begin
      if vdc = 0 then y := gapy + RealRect.Top; //垂直 顶对齐
      if (vdc = 1) and (height1 < spHeight) then y := round(RealRect.Top + spHeight / 2 - height1 / 2); //垂直居中
      if (vdc = 2) and (height1 < spHeight) then y := round(RealRect.Top + spHeight - height1 - gapy); //垂直对底
    end;
  }
  x := ml + RealRect.Left;
  if width1 < spWidth then
  begin
    if hdc = 0 then x := ml + RealRect.Left; //居左
    if (hdc = 1) and (width1 < spWidth) then x := round(RealRect.Left + spWidth / 2 - width1 / 2); //居中
    if (hdc = 2) and (width1 < spWidth) then x := round(RealRect.Left + spWidth - width1 - spGapLeft); //居右
  end;
  xold := x;

  ieol := 0;
  pendingBreak := false;
  repeat
    i := isol;
    xav := clw;
    maxHeight := 0;
    maxAscent := 0;
    eol := false;
    repeat // scan line
      el := THTMLElement(ElementStack.items[i]);
      if el.BreakLine then
      begin
        if not pendingBreak then
        begin
          pendingBreak := true;
          ieol := i;
          break;
        end
        else
          pendingBreak := false;
      end;
      if el.Height > maxheight then maxheight := el.Height;
      if el.Ascent > maxAscent then maxAscent := el.Ascent;
      el.Break(canvas, xav);
      if el.soltext <> '' then
      begin
        xav := xav - canvas.TextWidth(el.Soltext);
        if el.EolText = '' then
        begin
          if i >= c - 1 then
          begin
            eol := true;
            ieol := i;
          end
          else
          begin
            inc(i);
          end
        end
        else
        begin
          eol := true;
          ieol := i;
        end;
      end
      else
      begin // eol
        eol := true;
        ieol := i;
      end;
    until eol;

    x1 := x;
    y1 := y;
    for i := isol to ieol do
    begin
      el := THTMLElement(ElementStack.items[i]);
    end;
    if y + maxheight - y1 < spHeight then
    begin
      if vdc = 0 then y := spGapTop + RealRect.Top; //垂直 顶对齐
      if (vdc = 1) and (height1 < spHeight) then y := round(RealRect.Top + spHeight / 2 - (y + maxHeight - y1) / 2); //垂直居中
      if (vdc = 2) and (height1 < spHeight) then y := round(RealRect.Top + spHeight - (y + maxHeight - y1) - spGapTop); //垂直对底
    end
    else y := spGapTop + RealRect.Top; //垂直 顶对齐
    x := x1;

    baseline := maxAscent;
    for i := isol to ieol do
    begin
      el := THTMLElement(ElementStack.items[i]);
      RenderString(el);
    end;
    if spHeight < maxheight then
    begin
      spHeight := maxheight + spGapTop;
      CalcGaps;
    end;
    isol := ieol;
  until (ieol >= c - 1) and (el.EolText = '');
end;

procedure TRMHTMLMemoView.SetBackColor(const Value: TColor);
begin
  if value <> FBackColor then
  begin
    FBackcolor := Value;
  end;
end;

procedure TRMHTMLMemoView.SetMarginLeft(const Value: integer);
begin
  FMarginLeft := Value;
end;

procedure TRMHTMLMemoView.SetMarginRight(const Value: integer);
begin
  FMarginRight := Value;
end;

procedure TRMHTMLMemoView.SetMarginTop(const Value: integer);
begin
  FMarginTop := Value;
end;

procedure TRMHTMLMemoView.writeHTML(value: string);
const
  cr = chr(13) + chr(10);
  tab = chr(9);
var
  s: string;
begin
  if value = FText then exit;
  s := value;
  s := stringreplace(s, cr, ' ', [rfreplaceall]);
  s := Trimright(s);
  parseHTML(s);
  HTMLElementDimensions;
  //  if width1 > 0 then spWidth := width1+gapx;
  FText := s;
end;

(***********************************)

procedure TRMHTMLMemoView.ExpandVariables;
var
  i: Integer;
  s: string;

  function GetBrackedVariable(s: string; var i, j: Integer): string;
  var
    c: Integer;
    fl1, fl2: Boolean;
  begin
    j := i;
    fl1 := True;
    fl2 := True;
    c := 0;
    Result := '';
    if s = '' then Exit;
    Dec(j);
    repeat
      Inc(j);
      if fl1 and fl2 then
        if s[j] = '[' then
        begin
          if c = 0 then i := j;
          Inc(c);
        end
        else if s[j] = ']' then Dec(c);
      if fl1 then
        if s[j] = '"' then fl2 := not fl2;
      if fl2 then
        if s[j] = '''' then fl1 := not fl1;
    until (c = 0) or (j >= Length(s));
    Result := Copy(s, i + 1, j - i - 1);
  end;

  procedure GetData(var s: string);
  var
    i, j: Integer;
    s1, s2: WideString;
  begin
    i := 1;
    repeat
      while (i < Length(s)) and (s[i] <> '[') do Inc(i);
      s1 := GetBrackedVariable(s, i, j);
      if i <> j then
      begin
        Delete(s, i, j - i + 1);
        s2 := '';
        InternalOnGetValue(Self, s1, s2);
        Insert(s2, s, i);
        Inc(i, Length(s2));
        j := 0;
      end;
    until i = j;
  end;
begin
  Memo1.Clear;
  for i := 0 to Memo.Count - 1 do
  begin
    s := Memo[i];
    if (Length(trim(s)) > 0) and (DocMode <> rmdmDesigning) then
      GetData(s);
    Memo1.Add(s);
  end;
end;

function TRMHTMLMemoView.ShowHTML: Boolean;
begin
  RenderHTML;
  Result := True;
end;

procedure TRMHTMLMemoView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  ExpandVariables;
  if memo1.Count > 0 then
    writeHTML(memo1.Text);
  CalcGaps;
  ShowBackground;
  ShowHTML;
  ShowFrame;
  RestoreCoord;
end;

procedure TRMHTMLMemoView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  Stream.Read(vdc, SizeOf(vdc));
  Stream.Read(hdc, SizeOf(hdc));
end;

procedure TRMHTMLMemoView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(vdc, SizeOf(vdc));
  Stream.Write(hdc, SizeOf(hdc));
end;

procedure TRMHTMLMemoView.OnHook(View: TRMView);
begin
end;

procedure TRMHTMLMemoView.ShowEditor;
var
  i: byte;
  tmp: TRMHtmlForm;
begin
  tmp := TRMHtmlForm.Create(nil);
  try
    with tmp do
    begin
      if vdc = 0 then vlb.Down := true;
      if vdc = 1 then vcb.Down := true;
      if vdc = 2 then vrb.Down := true;
      if hdc = 0 then hlb.Down := true;
      if hdc = 1 then hcb.Down := true;
      if hdc = 2 then hrb.Down := true;
      FLabel.text := '';
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
				RMDesigner.BeforeChange;
        if vlb.Down then vdc := 0;
        if vcb.Down then vdc := 1;
        if vrb.Down then vdc := 2;
        if hlb.Down then hdc := 0;
        if hcb.Down then hdc := 1;
        if hrb.Down then hdc := 2;
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
{ TRMHtmlForm }

function TRMHtmlForm.ShowEditor(View: TRMView): TModalResult;
begin
  Result := mrOK;
end;

procedure TRMHtmlForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 914);
  RMSetStrProp(Label1, 'Caption', rmRes + 915);
  RMSetStrProp(Button3, 'Caption', rmRes + 916);
  RMSetStrProp(btnFont, 'Caption', rmRes + 917);
  RMSetStrProp(btnFontItalic, 'Caption', rmRes + 918);
  RMSetStrProp(btnFontBold, 'Caption', rmRes + 919);
  RMSetStrProp(SpeedButton1, 'Caption', rmRes + 920);
  RMSetStrProp(SpeedButton3, 'Caption', rmRes + 921);
  RMSetStrProp(SpeedButton6, 'Caption', rmRes + 922);
  RMSetStrProp(SpeedButton4, 'Caption', rmRes + 923);

  RMSetStrProp(Button1, 'Caption', SOK);
  RMSetStrProp(Button2, 'Caption', SCancel);
end;

procedure TRMHtmlForm.Button3Click(Sender: TObject);
var
  s: string;
begin
  s := RMDesigner.InsertDBField(nil);
  if s <> '' then
  begin
    ClipBoard.Clear;
    ClipBoard.AsText := s;
    M1.PasteFromClipboard;
    M1.SetFocus;
  end;
end;

procedure TRMHtmlForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TRMHtmlForm.M1KeyDown(Sender: TObject; var Key: Word;
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

procedure TRMHtmlForm.M1Change(Sender: TObject);
var
  i: byte;
begin
  if m1.lines.Count > 0 then
  begin
    FLabel.text := '';
    for i := 0 to m1.lines.count - 1 do
      FLabel.text := FLabel.text + m1.lines.Strings[i];
  end;
end;

procedure TRMHtmlForm.SpeedButton1Click(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<sup>' + strpas(buffer) + '</sup>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.SpeedButton3Click(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<sub>' + strpas(buffer) + '</sub>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.btnFontClick(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s, color: string;
begin
  if FontDialog1.Execute then
  begin
    color := ColorToString(fontdialog1.Font.color);
    if copy(color, 1, 2) = 'cl' then color := copy(color, 3, length(color) - 2);
    Size := m1.SelLength;
    Inc(Size);
    GetMem(Buffer, Size);
    m1.GetSelTextBuf(Buffer, size);
    s := '<font face="' + fontdialog1.Font.Name + '" size="' + inttostr(fontdialog1.Font.size) + '" color="' + color + '">' + strpas(buffer) + '</font>';
    FreeMem(Buffer, Size);
    m1.SelText := s;
    M1.SetFocus;
  end;
end;

procedure TRMHtmlForm.btnFontItalicClick(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<i>' + strpas(buffer) + '</i>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.SpeedButton4Click(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<u>' + strpas(buffer) + '</u>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.btnFontBoldClick(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<b>' + strpas(buffer) + '</b>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.SpeedButton6Click(Sender: TObject);
var
  Buffer: PChar;
  size: integer;
  s: string;
begin
  Size := m1.SelLength;
  Inc(Size);
  GetMem(Buffer, Size);
  m1.GetSelTextBuf(Buffer, size);
  s := '<span>' + strpas(buffer) + '</span>';
  FreeMem(Buffer, Size);
  m1.SelText := s;
  M1.SetFocus;
end;

procedure TRMHtmlForm.FormActivate(Sender: TObject);
begin
  M1.SetFocus;
end;

procedure TRMHtmlForm.FormCreate(Sender: TObject);
begin
  FLabel := TjanMarkupLabel.create(Self);
  FLabel.Parent := ScrollBox1;
  FLabel.Align := alClient;

  Localize;
end;

procedure TRMHtmlForm.FormDestroy(Sender: TObject);
begin
  FLabel.Free;
end;

initialization
  RMRegisterObjectByRes(TRMHTMLMemoView, 'RM_HTMLMemoObject', 'HTML标签', nil);

finalization

end.

