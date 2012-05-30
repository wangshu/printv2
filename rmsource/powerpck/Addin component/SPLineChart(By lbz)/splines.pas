unit splines;

interface

uses
  windows, sysutils, classes, dialogs;

const
  maxnovertices = 100;

type
  TVertex = record
    x, y, z: single;
  end;

  psplinerow = ^tsplinerow;
  tsplinerow = array[0..0] of tvertex;

  tbspline = class
  private
    nopoints: integer;
    vertexlist: psplinerow;
    ifnterpolated: boolean;
  public
    constructor create;
    procedure free;
    procedure clear;
    procedure phantompoints;
    procedure interpolate;
    function value(parameter: single): tvertex;
    procedure addvertex(vertex: tvertex);
    procedure insertvertex(pos: integer; vertex: tvertex);
    procedure deletevertex(vertexnr: word);
    procedure changevertex(vertexnr: word; x, y: single);
    function numberofvertices: word;
    function vertexIsknuckle(var nr: integer): boolean;
    procedure knuckleon(nr: integer);
    procedure knuckleoff(nr: integer);
    function vertexnr(nr: integer): TVertex;
  published
    property interpolated: boolean read ifnterpolated;
  end;

  TSplines = class(TComponent)
  private
    Fsplinerow: TList;
    function GetNumberofSplines: word;
  protected
  public
    constructor create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure addspline(bspline: tbspline);
    procedure clear;
    procedure insertspline(pos: integer; bspline: TBSpline);
    procedure deleteSpline(BSpline: Tbspline);
    function getsplineNr(Nr: word): TBSpline;
  published
    property Numberofsplines: word read Getnumberofsplines;
  end;

implementation

constructor TBSpline.create;
begin
  inherited create;
  ifnterpolated := false;
  nopoints := 0;
  getmem(vertexlist, (maxnovertices + 2) * sizeof(tvertex));
end;

procedure TBspline.free;
begin
  if vertexlist <> nil then
    freemem(vertexList, (maxnovertices + 2) * sizeof(tvertex));
  inherited free;
end;

procedure TBspline.clear;
begin
  Ifnterpolated := false;
  nopoints := 0;
end;

procedure TBspline.phantompoints;
var index: integer;
begin
  if nopoints > 1 then
  begin
    index := 0;
    vertexlist^[index].x := 2 * vertexlist^[index + 1].x - vertexlist^[index + 2].x;
    vertexlist^[index].y := 2 * vertexlist^[index + 1].y - vertexlist^[index + 2].y;
    vertexlist^[index].z := 2 * vertexlist^[index + 1].z - vertexlist^[index + 2].z;
    vertexlist^[nopoints + 1].x := 2 * vertexlist^[nopoints].x - vertexlist^[nopoints - 1].x;
    vertexlist^[nopoints + 1].y := 2 * vertexlist^[nopoints].y - vertexlist^[nopoints - 1].y;
    vertexlist^[nopoints + 1].z := 2 * vertexlist^[nopoints].z - vertexlist^[nopoints - 1].z;
  end;
end;

procedure TBSpline.interpolate;
const
  maxerror = 1E-6;
  matrixsize = maxnovertices + 2;
type
  tmatrix = array[1..matrixsize, 1..matrixsize] of single;
  pmatrix = ^TMatrix;
var
  matrix: Pmatrix;
  size: word;
  a, b, c: integer;
  factor: single;
  tmp: psplinerow;
begin
  if nopoints < 3 then
    exit;
  getmem(tmp, (nopoints + 2) * sizeof(tvertex));
  size := sizeof(tmatrix);
  getmem(matrix, size);
  fillchar(matrix^, size, 0);
  for a := 2 to nopoints - 1 do
  begin
    matrix^[a, a - 1] := 1 / 6;
    matrix^[a, a] := 2 / 3;
    Matrix^[a, a + 1] := 1 / 6;
  end;
  matrix^[1, 1] := 1;
  matrix^[nopoints, nopoints] := 1;
  for a := 2 to nopoints - 1 do
    if (abs(vertexlist^[a].x - vertexlist^[a - 1].x) < 1E-5) and
      (abs(vertexlist^[a].x - vertexlist^[a + 1].x) < 1E-5) and
      (abs(vertexlist^[a].y - vertexlist^[a - 1].y) < 1E-5) and
      (abs(vertexlist^[a].y - vertexlist^[a + 1].y) < 1E-5) then
      for b := a - 1 to a + 1 do
      begin
        matrix^[b, b - 1] := 0;
        matrix^[b, b] := 1;
        matrix^[b, b + 1] := 0;
      end;
  for a := 1 to nopoints do
    if abs(matrix^[a, a]) < maxerror then
    begin
      freemem(matrix, size);
      freemem(tmp, (nopoints + 2) * sizeof(tvertex));
      exit;
    end;
  for a := 1 to nopoints do
  begin
    for b := a + 1 to nopoints do
    begin
      factor := matrix^[b, a] / matrix^[a, a];
      for c := 1 to nopoints do
        matrix^[b, c] := matrix^[b, c] - factor * matrix^[a, c];
      vertexlist^[b].x := vertexlist^[b].x - factor * vertexList^[b - 1].x;
      vertexlist^[b].y := vertexlist^[b].y - factor * vertexList^[b - 1].y;
    end;
  end;
  tmp^[nopoints].x := vertexlist^[nopoints].x / matrix^[nopoints, nopoints];
  tmp^[nopoints].y := vertexlist^[nopoints].y / matrix^[nopoints, nopoints];
  for a := nopoints - 1 downto 1 do
  begin
    tmp^[a].x := (1 / matrix^[a, a]) * (vertexlist^[a].x - matrix^[a, a + 1] * tmp^[a + 1].x);
    tmp^[a].y := (1 / matrix^[a, a]) * (vertexlist^[a].y - matrix^[a, a + 1] * tmp^[a + 1].y);
  end;
  freemem(vertexlist, (nopoints + 2) * sizeof(tvertex));
  vertexlist := tmp;
  freemem(matrix, size);
  phantompoints;
  ifnterpolated := true;
end;

function TBSpline.value(parameter: single): TVertex;
var b, c: integer;
  dist: extended;
  mix: extended;
begin
  result.x := 0;
  result.y := 0;
  result.x := 0;
  b := trunc((nopoints - 1) * parameter);
  for c := b - 2 to b + 3 do
  begin
    dist := abs((nopoints - 1) * parameter - (c - 1));
    if dist < 2 then
    begin
      if dist < 1 then
        mix := 4 / 6 - dist * dist + 0.5 * dist * dist * dist
      else
        mix := (2 - dist) * (2 - dist) * (2 - dist) / 6;
      result.x := result.x + vertexlist^[c].x * mix;
      result.y := result.y + vertexlist^[c].y * mix;
      result.z := result.z + vertexlist^[c].z * mix;
    end;
  end;
end;

function TBSpline.vertexIsknuckle(var nr: integer): boolean;
var v1, v2, v3: tvertex;
begin
  result := false;
  if (nr > 1) and (nr < nopoints - 1) then
  begin
    v1 := vertexnr(nr - 2);
    v2 := vertexnr(nr - 1);
    v3 := vertexnr(nr);
    if (abs(v1.x - v2.x) < 1E-5) and (abs(v2.x - v3.x) < 1E-5) and
      (abs(v1.y - v2.y) < 1E-5) and (abs(v2.y - v3.y) < 1E-5) then
    begin
      result := true;
      nr := nr - 1;
      exit;
    end;
    v1 := vertexnr(nr - 1);
    v2 := vertexnr(nr);
    v3 := vertexnr(nr + 1);
    if (abs(v1.x - v2.x) < 1E-5) and (abs(v2.x - v3.x) < 1E-5) and
      (abs(v1.y - v2.y) < 1E-5) and (abs(v2.y - v3.y) < 1E-5) then
    begin
      result := true;
      exit;
    end;
    v1 := vertexnr(nr);
    v2 := vertexnr(nr + 1);
    v3 := vertexnr(nr + 2);
    if (abs(v1.x - v2.x) < 1E-5) and (abs(v2.x - v3.x) < 1E-5) and
      (abs(v1.y - v2.y) < 1E-5) and (abs(v2.y - v3.y) < 1E-5) then
    begin
      result := true;
      nr := nr + 1;
      exit;
    end;
  end;
end;

procedure TBSpline.knuckleon(nr: integer);
var i: integer;
begin
  if nopoints < maxnovertices - 2 then
  begin
    inc(nopoints, 2);
    for i := nopoints downto nr + 2 do
      vertexlist^[i] := vertexlist^[i - 2];
    vertexlist^[nr + 1] := vertexlist^[nr];
    vertexlist^[nr + 2] := vertexlist^[nr];
    phantompoints;
  end
  else
    messagedlg('Maximun number of vertices reached.', mterror, [mbok], 0);
end;

procedure TBSpline.knuckleoff(nr: integer);
begin
  if nopoints > 2 then
  begin
    if vertexIsknuckle(nr) then
    begin
      deletevertex(nr + 1);
      deletevertex(nr - 1);
    end;
  end;
end;

procedure TBSpline.insertvertex(pos: integer; vertex: TVertex);
var i: integer;
begin
  if nopoints < maxnovertices then
  begin
    inc(nopoints);
    for i := nopoints - 1 downto pos do
      vertexlist^[i + 1] := vertexList^[i];
    vertexList^[pos] := vertex;
    PhantomPoints;
  end
  else
    messagedlg('Maximun number of vertices reached.', mterror, [mbok], 0);
end;

procedure TBSpline.addvertex(vertex: TVertex);
begin
  if nopoints < maxnovertices then
  begin
    inc(nopoints);
    vertexList^[nopoints] := vertex;
    PhantomPoints;
  end
  else
    messagedlg('Maximun number of vertices reached.', mterror, [mbok], 0);
end;

procedure TBSpline.changevertex(vertexNr: word; x, y: single);
begin
  if (vertexNr > 0) and (vertexNr <= Nopoints) then
  begin
    VertexList^[vertexNr].x := x;
    VertexList^[vertexNr].y := y;
    PhantomPoints;
  end;
end;

procedure TBSpline.deletevertex(vertexNr: word);
var i: integer;
begin
  if (vertexnr > 0) and (vertexnr <= nopoints) then
  begin
    for i := vertexnr to nopoints - 1 do
      vertexlist^[i] := vertexlist^[i + 1];
    PhantomPoints;
  end;
end;

function TBSpline.vertexnr(nr: integer): TVertex;
begin
  result := vertexList^[nr];
end;

function TBSpline.numberofvertices: WORD;
begin
  result := noPoints;
end;

constructor TSplines.create(AOwner: TComponent);
begin
  inherited create(aowner);
  FSplineRow := Tlist.Create;
  FSplinerow.Capacity := 6000;
end;

destructor TSplines.destroy;
begin
  FSplinerow.Free;
  inherited destroy;
end;

procedure TSplines.addspline(bspline: TBspline);
begin
  if numberofsplines < fsplinerow.Capacity then
  begin
    FSplineRow.Add(BSpline);
  end
  else
    messagedlg('Maximum number of splines reached. (' + inttostr(Fsplinerow.count) + ')', mterror, [mbok], 0);
end;

procedure TSplines.clear;
begin
  while fsplinerow.Count > 0 do
    fsplinerow.delete(fsplinerow.count - 1);
  FSplinerow.Pack;
end;

procedure TSplines.insertspline(pos: integer; bspline: tbspline);
begin
  if numberofsplines < fsplinerow.Capacity then
  begin
    fsplinerow.Insert(pos, bspline);
  end
  else
    messagedlg('Maximum number of splines reached. (' + inttostr(Fsplinerow.count) + ')', mterror, [mbok], 0);
end;

procedure TSplines.deleteSpline(BSpline: TBspline);
var i: integer;
begin
  i := fsplinerow.IndexOf(Bspline);
  if i <> 1 then
  begin
    fsplinerow.Delete(i);
    Fsplinerow.Pack;
  end;
end;

function TSPlines.getsplineNr(nr: word): TBSpline;
begin
  if (nr >= 1) and (nr <= fsplinerow.Count) then
    result := fsplinerow.items[nr - 1]
  else
    result := nil;
end;

function TSplines.GetNumberofsplines: word;
begin
  result := fsplinerow.count;
end;

end.

