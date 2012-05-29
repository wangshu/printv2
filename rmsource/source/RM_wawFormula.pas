unit RM_wawFormula;

{$I rm.inc}

interface

uses
  Windows, Classes, SysUtils,
  RM_wawFormula_iftab,RM_wawBIFF8;

type
  rwawOperatorInfo=record
    Name: String[2];
    Priority: Integer;
    ptg: Byte;
  end;

  pwawOperatorInfo=^rwawOperatorInfo;

  rwawOperator=record 
    OperatorInfo: pwawOperatorInfo;
    iftab: Word;
    ParCount: Integer;
    OperandExists: Boolean;
  end;

  pwawOperator=^rwawOperator;

  TwawCompileOpStack=class (TObject) 
  private
    FList: TList;
    FCurPos: Integer;
    FLastFunction: pwawOperator;
    function GetItem (i: Integer): pwawOperator;
    function GetCount: Integer;
  public
    property Items[i: Integer]: pwawOperator read GetItem; default;
    property Count:Integer read GetCount;
    property LastFunction:pwawOperator read FLastFunction write FLastFunction;
    function Push: pwawOperator;
    function Pop: pwawOperator;
    function Last: pwawOperator;
    procedure Reset;
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

  TwawExtSheet=class (TObject) 
  private
    FName: String;
    FiSUPBOOK: Integer;
    Fitab: Integer;
  public
    property Name:String read FName;
    property iSUPBOOK:Integer read FiSUPBOOK;
    property itab:Integer read Fitab;
    constructor Create (_Name: String; _iSUPBOOK: Integer; _itab: Integer);
  end;

  TwawExtWorkbook=class (TObject) 
  private
    FName: String;
    FSheets: TList;
    function GetSheet (i: Integer): TwawExtSheet;
    function GetSheetsCount: Integer;
  public
    property Sheets[i: Integer]: TwawExtSheet read GetSheet; default;
    property SheetsCount:Integer read GetSheetsCount;
    property Name:String read FName;
    constructor Create (_Name: String);
    destructor Destroy; override;
  end;

  TwawExtRefs=class (TObject) 
  private
    FBooks: TList;
    FSheets: TList;
    function GetBook (i: Integer): TwawExtWorkbook;
    function GetSheet (i: Integer): TwawExtSheet;
    function GetBooksCount: Integer;
    function GetSheetsCount: Integer;
  public
    property Books[i: Integer]: TwawExtWorkbook read GetBook; default;
    property BooksCount:Integer read GetBooksCount;
    property Sheets[i: Integer]: TwawExtSheet read GetSheet;
    property SheetsCount:Integer read GetSheetsCount;
    function GetSheetIndex (BookName: String; SheetName: String): Integer;
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

  TwawExcelFormulaCompiler=class (TObject) 
  private
    FCompileOpStack: TwawCompileOpStack;
    FExtRefs: TwawExtRefs;
    procedure SetError (ErrorMessage: String);
  public
    property ExtRefs:TwawExtRefs read FExtRefs;
    procedure CompileFormula (s: String; var Ptgs: PChar; var PtgsSize: Integer);
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

const
  wawFormulaEndBracketChar = ')';
  wawFormulaStartBracketChar = '(';
  wawFormulaStringChar = '"';
  wawFormulaFuncParamsDelim = ';';
  wawFormulaPercentOperator = '%';
  wawFormulaUnaryPlusOperator = '+';
  wawFormulaUnaryMinusOperator = '-';
  wawFormulaUnaryOperators: set of Char = ['+', '-'];
  wawFormulaOperatorChars: set of Char = ['%'..'&', '*'..'+', '-', '/', '<'..'>', '^'];
  wawFormulaStartIdentChars: set of Char = ['$', '''', 'A'..'[','a'..'z'];
  wawFormulaIdentChars: set of Char = ['!', '$', '''', '.', '0'..':', '@'..'[', ']', '_', 'a'..'z'];
  wawOperatorsCount = $12;
  wawOperatorsInfos: array[$1..$12] of rwawOperatorInfo =
    ((Name: '('; Priority: $0; ptg: $00),
      (Name: ')'; Priority: $1; ptg: $00),
      (Name: '>='; Priority: $2; ptg: $0C),
      (Name: '<='; Priority: $2; ptg: $0A),
      (Name: '<>'; Priority: $2; ptg: $0E),
      (Name: '='; Priority: $2; ptg: $0B),
      (Name: '>'; Priority: $2; ptg: $0D),
      (Name: '<'; Priority: $2; ptg: $09),
      (Name: '&'; Priority: $3; ptg: $08),
      (Name: '+'; Priority: $4; ptg: $03),
      (Name: '-'; Priority: $4; ptg: $04),
      (Name: '*'; Priority: $5; ptg: $05),
      (Name: '/'; Priority: $5; ptg: $06),
      (Name: '^'; Priority: $6; ptg: $07),
      (Name: '%'; Priority: $7; ptg: $14),
      (Name: '+'; Priority: $8; ptg: $12),
      (Name: '-'; Priority: $8; ptg: $13),
      (Name: ''; Priority: $9; ptg: $FF));

  wawFormulaStartBracketOperatorIndex = $01;
  wawFormulaEndBracketOperatorIndex = $02;
  wawFormulaPercentOperatorIndex = $0F;
  wawFormulaUnaryPlusOperatorIndex = $10;
  wawFormulaUnaryMinusOperatorIndex = $11;
  wawFormulaFunctionOperatorIndex = $12;
  wawFormulaFunctionPriority = $09;
  wawFormulaStartBracketPriority = $00;
  wawFormulaEndBracketPriority = $01;
  wawFormulaPercentOperatorPriority = $07;

  swawFormulaCompileErrorInvalidBrackets = 'Invalid brackets';
  swawFormulaCompileErrorParameterWithoutFunction = 'Parameter without function';

  swawFormulaCompileErrorInvalidString = 'Invalid string';
  swawFormulaCompileErrorInvalidNumber = 'Invalid number [%s]';
  swawFormulaCompileErrorInvalidSymbol = 'Invalid symbol [%s]';
  swawFormulaCompileErrorUnknownOperator = 'Unknown operator [%s]';
  swawFormulaCompileErrorUnknownFunction = 'Unknown function [%s]';
  swawFormulaCompileErrorInvalidCellReference = 'Invalid cell reference [%s]';

  swawFormulaCompileErrorInvalidRangeReference = 'Invalid range reference [%s]';

  wawFormulaNumberChars: set of Char = ['.', '0'..'9'];

implementation

constructor TwawCompileOpStack.Create;
begin
 inherited Create;
 FList := TList.Create;
 FCurPos := -1;
end;

destructor TwawCompileOpStack.Destroy;
begin
 Clear;
 FList.Free;
 inherited Destroy;
end;

function TwawCompileOpStack.GetItem (i: Integer): pwawOperator;
begin
 Result := FList[i];  
end;

function TwawCompileOpStack.GetCount: Integer;
begin
 Result := FCurPos +1;
end;

procedure TwawCompileOpStack.Clear;
var
  i: Integer;
begin
 for i := 0 to FList.Count-1 do
  FreeMem(FList[i]);
 FList.Clear; 
 FCurPos := -1;
end;

procedure TwawCompileOpStack.Reset;
begin
 FCurPos := -1;
 FLastFunction := pwawOperator(nil);
end;

function TwawCompileOpStack.Push: pwawOperator;
begin
 inc(FCurPos);
 if FCurPos = FList.Count then
  begin
   GetMem(Result,sizeof(rwawOperator));
   FList.Add(Result);
  end
 else
  Result := FList[FCurPos]; 
end;

function TwawCompileOpStack.Pop: pwawOperator;
var
  i: Integer;
begin
 Dec(FCurPos);
 Result := Last;
 for i := Count-1 downto 1 do
   if pwawOperator(FList[i]).OperatorInfo.Priority = 9 then break;
 if (i >= 0) and (i< Count) then
  FLastFunction := FList[i]
 else
  FLastFunction := pwawOperator(nil);
end;

function TwawCompileOpStack.Last: pwawOperator;
begin
 if (FCurPos >= 0) and (FCurPos < FList.Count) then
   Result := FList[FCurPos]
 else
   Result := pwawOperator(nil);
end;

constructor TwawExtSheet.Create (_Name: String; _iSUPBOOK: Integer; _itab: Integer);
begin
  inherited Create;
  FName := _Name;
  FiSUPBOOK := _iSUPBOOK;
  Fitab := _itab;
end;

constructor TwawExtWorkbook.Create (_Name: String);
begin
 inherited Create;
 FName := _Name;
 FSheets := TList.Create;
end;

destructor TwawExtWorkbook.Destroy;
begin
 FSheets.Free;
 inherited Destroy;
end;

function TwawExtWorkbook.GetSheet (i: Integer): TwawExtSheet;
begin
 Result := FSheets[i];
end;

function TwawExtWorkbook.GetSheetsCount: Integer;
begin
 Result := FSheets.Count;
end;

constructor TwawExtRefs.Create;
begin
 inherited Create;
 FBooks := TList.Create;
 FSheets := TList.Create;
end;

destructor TwawExtRefs.Destroy;
begin
 Clear;
 FSheets.Free;
 FBooks.Free;
 inherited Destroy;
end;

function TwawExtRefs.GetBook (i: Integer): TwawExtWorkbook;
begin
 Result := FBooks[i];
end;

function TwawExtRefs.GetSheet (i: Integer): TwawExtSheet;
begin
 Result := FSheets[i];
end;

function TwawExtRefs.GetBooksCount: Integer;
begin
 Result := FBooks.Count;
end;

function TwawExtRefs.GetSheetsCount: Integer;
begin
 Result := FSheets.Count;
end;

procedure TwawExtRefs.Clear;
var
  i: Integer;
begin
 for i := 0 to SheetsCount -1 do
  Sheets[i].Free;
 for i := 0 to BooksCount -1 do
  Books[i].Free;
 FSheets.Clear;
 FBooks.Clear; 
end;

function TwawExtRefs.GetSheetIndex (BookName: String; SheetName: String): Integer;
var
  i: Integer;
  iBook: Integer;
  Book: TwawExtWorkbook;
  Sheet: TwawExtSheet;
begin
 Sheet := TwawExtSheet(nil);
 for iBook := 0 to BooksCount-1 do
   if (Books[iBook].Name = BookName) then break;

 if iBook >= BooksCount then
  begin
   Book := TwawExtWorkbook.Create(BookName);
   iBook := FBooks.Add(Book);
   Sheet := TwawExtSheet.Create(SheetName,iBook,0);
   Book.FSheets.Add(Sheet);
   Result := FSheets.Add(Sheet);
  end
 else
  begin
   Book := FBooks[iBook];
   for i := 0 to Book.SheetsCount-1 do
     if (Book.Sheets[i].Name = SheetName) then break;

   if i >= Book.SheetsCount then
    begin
     Sheet := TwawExtSheet.Create(SheetName,iBook,0);
     Book.FSheets.Add(Sheet);
     Result := FSheets.Add(Sheet);
    end
   else
    Result := FSheets.IndexOf(Sheet);
  end;
end;

constructor TwawExcelFormulaCompiler.Create
 ;
begin
 inherited Create;
 FExtRefs := TwawExtRefs.Create;
 FCompileOpStack := TwawCompileOpStack.Create;
end;

destructor TwawExcelFormulaCompiler.Destroy
 ;
begin
 FCompileOpStack.Free;
 FExtRefs.Free;
 inherited Destroy;
end;

procedure TwawExcelFormulaCompiler.Clear;
begin
 FExtRefs.Clear;
 FCompileOpStack.Clear;
end;

procedure TwawExcelFormulaCompiler.SetError(ErrorMessage: String);
begin
 raise Exception.Create(ErrorMessage);
end;

procedure TwawExcelFormulaCompiler.CompileFormula(s: String; var Ptgs: PChar;var PtgsSize: Integer);
var
  vd: Extended;
  Str: pptgStr;
  Last: pwawOperator;
  b1: String;
  ExtRef: String;
  CellRef: String;
  ExtBook: String;
  ExtSheet: String;
  i: Integer;
  j: Integer;
  l: Integer;
  vi: Integer;
  valCode: Integer;
  NewStrSize: Integer;
  CurStrSize: Integer;
  P: Pointer;
  procedure Addptg (_Ptg: Byte; _PtgData: Pointer; _PtgDataSize: Integer);
  begin
   ReallocMem(Ptgs,PtgsSize + _PtgDataSize +1);
   PByte(Ptgs + PtgsSize)^ := _Ptg;
   if _PtgData <> nil then
    MoveMemory(Pointer(Ptgs + PtgsSize +1), _PtgData, _PtgDataSize);
   PtgsSize := PtgsSize + _PtgDataSize +1;
  end;
  procedure AddptgOperator (o: pwawOperator);
  var
    FuncVar: rptgFuncVar;
  begin
    if o.OperatorInfo.ptg = Byte(255) then
     begin
      FuncVar.cargs := o.ParCount;
      FuncVar.iftab := o.iftab;
      Addptg(ptgFuncVar,@FuncVar,sizeof(FuncVar));
     end
    else
      Addptg(o.OperatorInfo.ptg,nil,0);
  end;
  procedure AddptgIdentificator (Ident: String);
  var
    p: Integer;
    Ref: rptgRef;
    Area: rptgArea;
    Ref3D: rptgRef3D;
    Area3D: rptgArea3D;
    function CompileCellRef (s: String; var rw: Word; var grbitCol: Word): Boolean;
    const
      SymbolA = $41;
      SymbolZ = $5A;
      SymbolsAZ = $1A;
    var
      i: Integer;
      l: Integer;
    begin
     Result := False;
     s := UpperCase(s);
     rw := 0;
     grbitCol := 0;
     l := Length(s);
     for i := l downto 1 do
      if s[i] > '9' then Break;
     if (i = 0) or (l = i) then exit;    //0x163
     rw := StrToInt(Copy(s,i+1,l)) -1;
     if s[i] <> '$' then
      grbitCol := grbitCol or $8000
     else
      begin
       if i = 1 then Exit;
       Dec(i);
      end;
     ValCode := i;
     for i:=i downto 1 do
      if (s[i] > 'Z') or (s[i] < 'A') then Break;
     if (s[i] = '$') then
      begin
      if (i <> 1) then  exit
      end
     else
      begin
      if (i <> 0) then  exit
      else grbitCol := grbitCol or $4000;
      end;
     case ValCode-i of
      1: grbitCol := grbitCol or Word(Word(s[ValCode]) - SymbolA);
      2: begin
         grbitCol := grbitCol or Word((Word(s[ValCode-1])-SymbolA+Byte(1))*Word(25));
         grbitCol := grbitCol or Word(Word(s[ValCode])- SymbolA+Byte(1));
         end;
      else Exit;
     end;
     Result := True;
    end;
  begin
   p := Pos('!',Ident);
   if p > 0 then
    begin
    if Ident[1] = char($27) then
     begin
     for p := 2 to Length(Ident) do
      if Ident[p] = char($27) then Break;
     if ((p >= Length(Ident)) or (Ident[p] <> PChar($21))) then
      SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]));
     CellRef := Copy(Ident,2,p-2);
     ExtRef := Trim(Copy(Ident,p+1,Length(Ident)));
     end
    else
     begin
     CellRef := Copy(Ident,1,p-1);
     ExtRef := Trim(Copy(Ident,p+1,Length(Ident)));
     end;
    CellRef := Trim(CellRef);
    if CellRef = '' then
      SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]));
    if CellRef[1] = '[' then
     begin
     for p := 2 to Length(CellRef) do
      if CellRef[p] = ']' then Break;
     if p > Length(CellRef) then
      SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]));
     ExtBook := Copy(CellRef,2,p-2);
     ExtSheet := Copy(CellRef,p+1,Length(CellRef));
     end
    else
     begin
     ExtBook := '';
     ExtSheet := CellRef;
     end;
    p := Pos(':',ExtRef);
    if p = 0 then
     begin
     if not CompileCellRef(ExtRef, Ref3D.rw, Ref3D.grbitCol) then
      SetError(Format(swawFormulaCompileErrorInvalidCellReference,[ExtRef]));
     Ref3D.ixti := ExtRefs.GetSheetIndex(ExtBook,ExtSheet);
     Addptg(ptgRef3D,@Ref3D,sizeof(rptgRef3D));
     end   
    else
     begin
     if not CompileCellRef(Copy(ExtRef,1,p-1),Area3D.rwFirst,Area3D.grbitColFirst) then
      SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]))
     else
      begin
      if not CompileCellRef(Copy(ExtRef,p+1,Length(Ident)),Area3D.rwLast,Area3D.grbitColLast) then
       SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]));
      Area3D.ixti := ExtRefs.GetSheetIndex(ExtBook,ExtSheet);
      Addptg(ptgArea3D,@Area3D,sizeof(rptgArea3D));
      end;
     end;
    end
   else
    begin
    p := Pos(':',Ident);
    if p = 0 then
     begin
     if not CompileCellRef(Ident,Ref.rw,Ref.grbitCol) then
        SetError(Format(swawFormulaCompileErrorInvalidCellReference,[Ident]));
     Addptg(ptgRef,@Ref,sizeof(rptgRef));
     end
    else
     begin 
     if not CompileCellRef(Copy(Ident,1,p-1),Area.rwFirst,Area.grbitColFirst) then
        SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]))
     else
      begin
      if not CompileCellRef(Copy(Ident,p+1,Length(Ident)),Area.rwLast,Area.grbitColLast) then
        SetError(Format(swawFormulaCompileErrorInvalidRangeReference,[Ident]))
      end;
     Addptg(ptgArea,@Area,sizeof(rptgArea));
     end;
    end;
  end;
  procedure AddptgStr (s: String);
  begin
   NewStrSize := Length(s)* sizeof(WideChar) + sizeof(rptgStr);
   if NewStrSize > CurStrSize then
   begin
    ReallocMem(Str,NewStrSize);
    CurStrSize := NewStrSize;
   end;
   P := PChar(PChar(@Str)+ sizeof(rptgStr));
   Str.cch := FormatStrToWideChar(s,P);
   Str.grbit := 1;
   Addptg(ptgStr,Str,Str.cch shl 1);
  end;
  procedure AddptgInt (n: Word);
  var
    int: rptgInt;
  begin
   int.w := n;
   Addptg(ptgInt,@int,sizeof(int));
  end;
  procedure AddptgNum (n: Double);
  var
    num: rptgNum;
  begin
   num.num := n;
   Addptg(ptgNum,@num,sizeof(num));
  end;
  function GetOperatorIndex (s: String): Integer;
  begin
   for Result :=1 to wawOperatorsCount do
     if s = wawOperatorsInfos[Result].Name then Break;
   if Result > wawOperatorsCount then
     SetError(Format(swawFormulaCompileErrorUnknownOperator,[s]));
  end;
  function GetFunction_iftab (s: String): Integer;
  begin
   for Result := 1 to wawExcelFunctionsCount do
     if AnsiCompareText(s, wawExcelFunctions[Result].FuncName) = 0 then Break;
   if Result > wawExcelFunctionsCount then
    SetError(Format(swawFormulaCompileErrorUnknownFunction,[s]))
   else
    Result := wawExcelFunctions[Result].iftab;
  end;
  function ProcessOperator (OperatorInfoIndex: Integer): pwawOperator;
  var
    Last: pwawOperator;
    oi: pwawOperatorInfo;
    f: Boolean;      //waw
  begin
   Result := pwawOperator(nil);
   oi := @(wawOperatorsInfos[OperatorInfoIndex]);
   Last := FCompileOpStack.Last;
   if (oi.Priority <> 0) and(Last <> nil) and (Last.OperatorInfo.Priority >= oi.Priority) then
    begin
    while (Last <> nil) and (Last.OperatorInfo.Priority >= oi.Priority) do
      begin
      AddptgOperator(Last);
      Last := FCompileOpStack.Pop;
      end;
    end;
   if oi.Priority <> 1 then
    begin
     Result := FCompileOpStack.Push;
     Result.OperatorInfo := oi;
     Result.ParCount := 0;
     Result.OperandExists := False;
    end
   else
    begin
     if Last = nil then
      SetError(swawFormulaCompileErrorInvalidBrackets)
     else
      begin
       f := Last.OperatorInfo.Priority <> 0;
       Last := FCompileOpStack.Pop;
       if Last = nil then
         Addptg(ptgParen,nil,0)
       else
        begin
         if Last.OperatorInfo.Priority <> 9 then
          Addptg(ptgParen,nil,0)
         else
          begin
           if (Last.OperandExists = True) then
             Inc(Last.ParCount)
           else
           begin
           if (Last.ParCount = 0) then
             begin
             if f then
              begin
              Addptg(ptgMissArg,nil,0);
              Inc(Last.ParCount);
              end;
             end
           else
             Inc(Last.ParCount);
           end;
          end;
        end;
      end;
    end;
  end;
label L2cc;
begin
  FCompileOpStack.Reset;
  Str := nil;
  CurStrSize := 0;
  l := Length(s) +1;
  i := 1;
  try
   while i < l do
   begin
    if s[i] in wawFormulaStartIdentChars then
     begin
     if FCompileOpStack.LastFunction <> nil then
       FCompileOpStack.LastFunction.OperandExists := True;
     j := i;
     for i := i to l do
      if not (s[i] in wawFormulaIdentChars) then Break;
     for i := i to l do
      if s[i] > Char($20) then Break;
     b1 := Trim(Copy(s,j,i-j));
     if i <= l then
      begin
      if s[i] = wawFormulaStartBracketChar then
       begin
       FCompileOpStack.LastFunction := ProcessOperator(wawFormulaFunctionOperatorIndex);
       FCompileOpStack.LastFunction.iftab := GetFunction_iftab(b1);
       Continue;
       end;
      end;
     AddptgIdentificator(b1);
     Continue;
     end;

    if s[i] = wawFormulaFuncParamsDelim then
     begin
     if FCompileOpStack.LastFunction = nil then
      SetError(swawFormulaCompileErrorParameterWithoutFunction);
     if FCompileOpStack.LastFunction.OperandExists = False then
      Addptg(ptgMissArg,nil,0);
     Last := FCompileOpStack.Last;
     while Last.OperatorInfo.Priority > 0 do
      begin
      AddptgOperator(Last);
      Last := FCompileOpStack.Pop;
      end;
     FCompileOpStack.LastFunction.OperandExists := False;
     Inc(FCompileOpStack.LastFunction.ParCount);
     Inc(i);
     Continue;
     end;

    if s[i] = wawFormulaPercentOperator then
     begin
     ProcessOperator(wawFormulaPercentOperatorIndex);
     Inc(i);
     Continue;
     end;

    if s[i] in wawFormulaOperatorChars then
     begin
     j := i;
     for i := i to l do
      if not(s[i] in wawFormulaOperatorChars) then Break;
     b1 := Copy(s,j,i-j);
     vi := Length(b1);

     if (vi > 1) and (b1[vi] in wawFormulaUnaryOperators) then
      begin
      ProcessOperator(GetOperatorIndex(Copy(b1,1,vi-1)));
      if b1[vi] = wawFormulaUnaryPlusOperator then
       begin
       ProcessOperator(wawFormulaUnaryPlusOperatorIndex);
       Continue;
       end
      else
       begin
       ProcessOperator(wawFormulaUnaryMinusOperatorIndex);
       Continue;
       end;
      end;

     if (vi = 1) and (b1[1] in wawFormulaUnaryOperators) then
      begin
       for j := j downto 0 do
        if s[j] > Char($20) then Break;
       if j < 1 then goto L2cc;
       case s[j] of
         wawFormulaStartBracketChar: goto L2cc;
         wawFormulaFuncParamsDelim:
L2cc:     begin
          if b1[vi] = wawFormulaUnaryPlusOperator then
           begin
           ProcessOperator(wawFormulaUnaryPlusOperatorIndex);
           Continue;
           end
          else
           begin
           ProcessOperator(wawFormulaUnaryMinusOperatorIndex);
           Continue;
           end;
          end
         else
          begin
          ProcessOperator(GetOperatorIndex(b1));
          Continue;
          end;
       end;
      end;
     ProcessOperator(GetOperatorIndex(b1));
     Continue;
     end;

    if s[i] = wawFormulaStartBracketChar then
     begin
     ProcessOperator(wawFormulaStartBracketOperatorIndex);
     Inc(i);
     Continue;
     end;

    if s[i] = wawFormulaEndBracketChar then
     begin
     ProcessOperator(wawFormulaEndBracketOperatorIndex);
     Inc(i);
     Continue;
     end;

    if s[i] = wawFormulaStringChar then
     begin
     if FCompileOpStack.LastFunction <> nil then
      FCompileOpStack.LastFunction.iftab := 1;
     Inc(i);
     j:=i;
     for i := i to l do
      if s[i] = wawFormulaStringChar then Break;
     if i > l then
      SetError(swawFormulaCompileErrorInvalidString);
     AddptgStr(Copy(s,j,i-j));
     Continue;
     end;

    if s[i] in wawFormulaNumberChars then
     begin
     if FCompileOpStack.LastFunction <> nil then
      FCompileOpStack.LastFunction.iftab := 1;
     j := i;
     for i := i to l do
      if not(s[i] in wawFormulaNumberChars) then Break;
     b1 := Copy(s,j,i-j);
     val(b1,vi,valcode);
     if ( valcode = 0) and (vi < $FFFF) then
      begin
      AddptgInt(vi);
      Continue;
      end;
     if TextToFloat(PChar(b1),vd,fvExtended) = True then
      begin
      AddptgNum(vd);
      Continue;
      end
     else
      begin
      SetError(Format(swawFormulaCompileErrorInvalidNumber,[b1]));
      Continue;
      end;
     end;

    if s[i] > Char($20) then
     SetError(Format(swawFormulaCompileErrorInvalidSymbol,[b1]));
    Inc(i);
   end;
   Last := FCompileOpStack.Last;
   while FCompileOpStack.Last <> nil do
   begin
     if Last.OperatorInfo.Priority = 0 then
      SetError(swawFormulaCompileErrorInvalidBrackets);
     AddptgOperator(Last);
     Last := FCompileOpStack.Pop;
   end;
  finally
  end;
  if Str <> nil then FreeMem(Str);
end;

end.


