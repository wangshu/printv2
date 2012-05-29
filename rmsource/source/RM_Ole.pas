
{*****************************************}
{                                         }
{         Report Machine v2.0             }
{            OLE Add-In Object            }
{                                         }
{*****************************************}

unit RM_Ole;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, OleCtnrs, DB, RM_DataSet, RM_Class, ActiveX, RM_Ctrls
{$IFDEF USE_INTERNAL_JVCL}, rm_JvInterpreter{$ELSE}, JvInterpreter{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMOLEObject = class(TComponent) // fake component
  end;

 { TRMOleView }
  TRMOLEView = class(TRMReportView)
  private
    FOleContainer: TOleContainer;
    FPrintType: TRMPrintMethodType;

    function GetSizeMode: TSizeMode;
    procedure SetSizeMode(Value: TSizeMode);
    function GetDirectDraw: Boolean;
    procedure SetDirectDraw(Value: Boolean);
  protected
    procedure GetBlob; override;
    function GetViewCommon: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure DefinePopupMenu(Popup: TRMCustomMenuItem); override;
    procedure ShowEditor; override;

    procedure LoadFromOle(aOle: TOleContainer);
  published
    property OleContainer: TOleContainer read FOleContainer;
    property SizeMode: TSizeMode read GetSizeMode write SetSizeMode;
    property PrintType: TRMPrintMethodType read FPrintType write FPrintType;
    property LeftFrame;
    property RightFrame;
    property TopFrame;
    property BottomFrame;
    property FillColor;
    property ReprintOnOverFlow;
    property ShiftWith;
    property BandAlign;
    property DirectDraw: Boolean read GetDirectDraw write SetDirectDraw;
    property DataField;
    property PrintFrame;
    property Printable;
  end;

  { TRMOleFomr }
  TRMOleForm = class(TForm)
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    ItmInsertObject: TMenuItem;
    ItmObjectProp: TMenuItem;
    OleContainer1: TOleContainer;
    Panel1: TPanel;
    btnInsert: TButton;
    btnEdit: TButton;
    btnOk: TButton;
    procedure btnInsertClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure PopupVerbMenuClick(Sender: TObject);
    procedure OnCopyObject(Sender: TObject);
    procedure OnDeleteObject(Sender: TObject);
    procedure OnPasteObject(Sender: TObject);
    procedure OnEditObjectProp(Sender: TObject);
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses RM_Common, RM_Utils, RM_Const, RM_Const1;

{$R *.DFM}

const
  flOleDirectDraw = $2;

procedure AssignOle(aDest, aSource: TOleContainer);
var
  liStream: TMemoryStream;
begin
  if aSource.OleObjectInterface = nil then
  begin
    aDest.DestroyObject;
    Exit;
  end;

  liStream := TMemoryStream.Create;
  try
    aSource.SaveToStream(liStream);
    liStream.Position := 0;
    aDest.LoadFromStream(liStream);
  finally
    liStream.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMOLEView}

constructor TRMOLEView.Create;
begin
  inherited Create;
  BaseName := 'Ole';

  FOleContainer := TOleContainer.Create(nil);
  with FOleContainer do
  begin
    Parent := RMDialogForm;
    Visible := False;
    AllowInPlace := False;
    AutoVerbMenu := False;
    BorderStyle := bsNone;
  end;
  SizeMode := smClip;
  FPrintType := rmptMetafile;
end;

destructor TRMOLEView.Destroy;
begin
  if RMDialogForm <> nil then
  begin
    FOleContainer.Free;
    FOleContainer := nil;
  end;
  inherited Destroy;
end;

procedure TRMOLEView.Draw(aCanvas: TCanvas);
var
  liBitmap: TBitmap;
  w, h: Integer;

  procedure _PaintControl(aRect: TRect);
  var
    lMetafile: TMetafile;
    lMetaFileCanvas: TMetaFileCanvas;
    lBitmap: TBitmap;
    liRect: TRect;
  begin
    if (aRect.Right < aRect.Left) or (aRect.Bottom < aRect.Top) then Exit;
    
    liRect := Rect(0, 0, aRect.Right - aRect.Left, aRect.Bottom - aRect.Top);
    case FPrintType of
      rmptMetafile:
        begin
          lMetafile := TMetaFile.Create;
          lMetaFile.Enhanced := True;
          lMetaFile.Width := aRect.Right - aRect.Left + 1;
          lMetaFile.Height := aRect.Bottom - aRect.Top + 1;
          lMetaFileCanvas := TMetaFileCanvas.Create(lMetaFile, 0);
          try
            OleDraw(FOleContainer.OleObjectInterface, DVASPECT_CONTENT, lMetaFileCanvas.Handle, liRect);
            lMetaFileCanvas.Free;
            RMPrintGraphic(aCanvas, aRect, lMetaFile, IsPrinting, DirectDraw, True);
          finally
            lMetafile.Free;
          end;
        end;
      rmptBitmap:
        begin
          lBitmap := TBitmap.Create;
          try
            lBitmap.Width := aRect.Right - aRect.Left + 1;
            lBitmap.Height := aRect.Bottom - aRect.Top + 1;
            OleDraw(FOleContainer.OleObjectInterface, DVASPECT_CONTENT, lBitmap.Canvas.Handle, liRect);
            RMPrintGraphic(aCanvas, aRect, lBitmap, IsPrinting, DirectDraw, True);
          finally
            lBitmap.Free;
          end;
        end;
    end;
  end;

  function _HimetricToPixels(const P: TPoint): TPoint;
  begin
    Result.X := MulDiv(P.X, RMPixPerInchX, 2540);
    Result.Y := MulDiv(P.Y, RMPixPerInchY, 2540);
  end;

  procedure _DrawOLE;
  var
    liPoint: TPoint;
    liRect: TRect;
    liViewSize: TPoint;
    lidx, lidy: Integer;
  begin
    lidx := FOleContainer.Width;
    lidy := FOleContainer.Height;
    with FOleContainer do
    begin
      if SizeMode <> smStretch then
      begin
        OleObjectInterface.GetExtent(DVASPECT_CONTENT, liViewSize);
        liPoint := _HimetricToPixels(liViewSize);
        if SizeMode = smScale then
        begin
          if lidx * liPoint.Y > lidy * liPoint.X then
          begin
            liPoint.X := liPoint.X * lidy div liPoint.Y;
            liPoint.Y := lidy;
          end
          else
          begin
            liPoint.Y := liPoint.Y * lidx div liPoint.X;
            liPoint.X := lidx;
          end;
        end;

        if SizeMode = smCenter then //居中
        begin
          liRect := RealRect;
          w := RealRect.Right - RealRect.Left;
          h := RealRect.Bottom - RealRect.Top;
          OffsetRect(liRect, (w - Round(FactorX * liPoint.X)) div 2, (h - Round(FactorY * liPoint.Y)) div 2);
          liRect.Right := liRect.Left + Round(liPoint.X * FactorX);
          liRect.Bottom := liRect.Top + Round(liPoint.Y * FactorY);
        end
        else if SizeMode = smScale then //缩放
        begin
          liRect.Left := RealRect.Left + (lidx - liPoint.X) div 2;
          liRect.Top := RealRect.Top + (lidy - liPoint.Y) div 2;
          liRect.Right := liRect.Left + liPoint.X;
          liRect.Bottom := liRect.Top + liPoint.Y;
        end
        else if SizeMode = smClip then //原始大小
        begin
          SetRect(liRect, RealRect.Left, RealRect.Top, RealRect.Left + Round(liPoint.X * FactorX),
            RealRect.Top + Round(liPoint.Y * FactorY));
        end;
      end
      else
        SetRect(liRect, RealRect.Left, RealRect.Top, RealRect.Right, RealRect.Bottom);

        _PaintControl(liRect);
    end;
  end;

  procedure _DrawDefaultText;
  begin
    with aCanvas do
    begin
      if RMIsChineseGB then
      begin
        Font.Name := '宋体'; //'Arial';
        Font.Size := 9; //8;
      end
      else
      begin
        Font.Name := 'Arial';
        Font.Size := 8;
      end;
      Font.Style := [];
      Font.Color := clBlack;
      TextRect(RealRect, RealRect.Left + 20, RealRect.Top + 3, '[OLE]');
      liBitmap := TBitmap.Create;
      liBitmap.Handle := LoadBitmap(hInstance, 'RM_EMPTY');
      Draw(RealRect.Left + 1, RealRect.Top + 2, liBitmap);
      liBitmap.Free;
    end;
  end;

begin
  BeginDraw(aCanvas);
  CalcGaps;
  IntersectClipRect(aCanvas.Handle, RealRect.Left, RealRect.Top, RealRect.Right, RealRect.Bottom);
  try
    if (RealRect.Right > RealRect.Left) and (RealRect.Bottom > RealRect.Top) then
    begin
      ShowBackground;

      if FOleContainer.OleObjectInterface <> nil then
      begin
        FOleContainer.Width := RealRect.Right - RealRect.Left;
        FOleContainer.Height := RealRect.Bottom - RealRect.Top;
        _DrawOLE;
      end
      else if DocMode = rmdmDesigning then
        _DrawDefaultText;

    end;
    ShowFrame;
    RestoreCoord;
  finally
    Windows.SelectClipRgn(aCanvas.Handle, 0);
  end;
end;

procedure TRMOLEView.LoadFromStream(aStream: TStream);
var
  b: Byte;
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  SizeMode := TSizeMode(RMReadByte(aStream));
  FPrintType := TRMPrintMethodType(RMReadByte(aStream));
  b := RMReadByte(aStream);
  if b = 1 then
    FOleContainer.LoadFromStream(aStream);
end;

procedure TRMOLEView.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(SizeMode));
  RMWriteByte(aStream, Byte(FPrintType));
  if FOleContainer.OleObjectInterface <> nil then
  begin
    RMWriteByte(aStream, 1);
    FOleContainer.SaveToStream(aStream);
  end
  else
    RMWriteByte(aStream, 0);
end;

procedure TRMOLEView.GetBlob;
var
  lStream: TMemoryStream;
begin
  if ParentReport.Flag_TableEmpty or FDataSet.FieldIsNull(FDataFieldName) then
  begin
    FOleContainer.DestroyObject;
    Exit;
  end;

  lStream := TMemoryStream.Create;
  try
    FDataSet.AssignBlobFieldTo(FDataFieldName, lStream);
    FOleContainer.LoadFromStream(lStream);
  finally
    lStream.Free;
  end;
end;

procedure TRMOLEView.DefinePopupMenu(Popup: TRMCustomMenuItem);
begin
end;

procedure TRMOLEView.ShowEditor;
var
  tmpForm: TRMOleForm;
begin
  tmpForm := TRMOleForm.Create(Application);
  try
    AssignOle(tmpForm.OleContainer1, FOleContainer);
    if tmpForm.ShowModal = mrOK then
    begin
      RMDesigner.BeforeChange;
      AssignOle(FOleContainer, tmpForm.OleContainer1);
      tmpForm.OleContainer1.DestroyObject;
      RMDesigner.AfterChange;
    end;
  finally
    tmpForm.Free;
  end;
end;

function TRMOleView.GetSizeMode: TSizeMode;
begin
  Result := FOleContainer.SizeMode;
end;

procedure TRMOleView.LoadFromOle(aOle: TOleContainer);
begin
  AssignOle(FOleContainer, aOle);
end;

procedure TRMOleView.SetSizeMode(Value: TSizeMode);
begin
  FOleContainer.SizeMode := Value;
end;

function TRMOleView.GetDirectDraw: Boolean;
begin
  Result := (FFlags and flOleDirectDraw) = flOleDirectDraw;
end;

procedure TRMOleView.SetDirectDraw(Value: Boolean);
begin
  FFlags := (FFlags and not flOleDirectDraw);
  if Value then
    FFlags := FFlags + flOleDirectDraw;
end;

function TRMOleView.GetViewCommon: string;
begin
  Result := '[Ole]';
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{TRMOLEForm}

procedure TRMOleForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 550);
  RMSetStrProp(btnInsert, 'Caption', rmRes + 551);
  RMSetStrProp(btnEdit, 'Caption', rmRes + 552);
  RMSetStrProp(ItmInsertObject, 'Caption', rmRes + 554);
  RMSetStrProp(ItmObjectProp, 'Caption', rmRes + 558);

  btnOk.Caption := RMLoadStr(rmRes + 553);
end;

procedure TRMOleForm.btnInsertClick(Sender: TObject);
begin
  with OleContainer1 do
  begin
    Screen.Cursor := crHourGlass;
    try
      if InsertObjectDialog then
        DoVerb(PrimaryVerb);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TRMOleForm.btnEditClick(Sender: TObject);
begin
  if OleContainer1.OleObjectInterface <> nil then
    OleContainer1.DoVerb(ovPrimary);
end;

type
  THackOleContainer = class(TOleContainer)
  end;

procedure TRMOleForm.PopupVerbMenuClick(Sender: TObject);
begin
  OleContainer1.DoVerb((Sender as TMenuItem).Tag);
end;

procedure TRMOleForm.OnCopyObject(Sender: TObject);
begin
  OleContainer1.Copy;
end;

procedure TRMOleForm.OnDeleteObject(Sender: TObject);
begin
  OleContainer1.DestroyObject;
end;

procedure TRMOleForm.OnPasteObject(Sender: TObject);
begin
  OleContainer1.PasteSpecialDialog;
end;

procedure TRMOleForm.OnEditObjectProp(Sender: TObject);
begin
  OleContainer1.ObjectPropertiesDialog;
end;

procedure TRMOleForm.PopupMenu1Popup(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  while PopupMenu1.Items.Count > 0 do
    PopupMenu1.Items.Delete(0);
  with OleContainer1 do
  begin
    if (OleObjectInterface <> nil) and (ObjectVerbs.Count > 0) then
    begin
      for I := 0 to ObjectVerbs.Count - 1 do
      begin
        Item := TMenuItem.Create(Self);
        Item.Caption := ObjectVerbs[I];
        Item.Tag := I;
        Item.OnClick := PopupVerbMenuClick;
        PopupMenu1.Items.Add(Item);
      end;
      Item := TMenuItem.Create(Self);
      Item.Caption := '-';
      PopupMenu1.Items.Add(Item);
    end;

    Item := TMenuItem.Create(Self);
    RMSetStrProp(Item, 'Caption', rmRes + 554);
    Item.OnClick := btnInsertClick;
    PopupMenu1.Items.Add(Item);

    if CanPaste then
    begin
      Item := TMenuItem.Create(Self);
      RMSetStrProp(Item, 'Caption', rmRes + 555);
      Item.OnClick := onPasteObject;
      PopupMenu1.Items.Add(Item);
    end;
    if OleObjectInterface <> nil then
    begin
      Item := TMenuItem.Create(Self);
      RMSetStrProp(Item, 'Caption', rmRes + 556);
      Item.OnClick := OnCopyObject;
      PopupMenu1.Items.Add(Item);

      Item := TMenuItem.Create(Self);
      RMSetStrProp(Item, 'Caption', rmRes + 557);
      Item.OnClick := OnDeleteObject;
      PopupMenu1.Items.Add(Item);

      Item := TMenuItem.Create(Self);
      RMSetStrProp(Item, 'Caption', rmRes + 558);
      Item.OnClick := OnEditObjectProp;
      PopupMenu1.Items.Add(Item);
    end;
  end;
end;

procedure TRMOleForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMOleView_LoadFromOle(var Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMOleView(Args.Obj).LoadFromOle(TOleContainer(V2O(Args.Values[0])));
end;

procedure TRMPictureView_LoadFromFile(var Value: Variant; Args: TJvInterpreterArgs);
var
  lFileName: string;
begin
  lFileName := Args.Values[0];
  if (lFileName <> '') and FileExists(lFileName) then
    TRMOleView(Args.Obj).OleContainer.CreateObjectFromFile(ExpandFileName(lFileName), False)
  else
    TRMOleView(Args.Obj).OleContainer.DestroyObject;
end;

procedure TOleContainer_LoadFromFile(var Value: Variant; Args: TJvInterpreterArgs);
var
  lFileName: string;
begin
  lFileName := Args.Values[0];
  if (lFileName <> '') and FileExists(lFileName) then
    TOleContainer(Args.Obj).LoadFromFile(ExpandFileName(lFileName))
  else
    TOleContainer(Args.Obj).DestroyObject;
end;

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('ReportMachine', TOleContainer, 'TOleContainer');
    AddClass('ReportMachine', TRMOLEView, 'TRMOLEView');

    // TSizeMode
    AddConst('ReportMachine', 'smClip', smClip);
    AddConst('ReportMachine', 'smCenter', smCenter);
    AddConst('ReportMachine', 'smScale', smScale);
    AddConst('ReportMachine', 'smStretch', smStretch);
    AddConst('ReportMachine', 'smAutoSize', smAutoSize);

    AddGet(TRMOleView, 'LoadFromOle', TRMOleView_LoadFromOle, 1, [0], varEmpty);
    AddGet(TRMOleView, 'LoadFromFile', TRMPictureView_LoadFromFile, 1, [0], varEmpty);
    AddGet(TRMOleView, 'Assign', TRMOleView_LoadFromOle, 1, [0], varEmpty);
    //AddGet(TRMOleView, 'AssignBlobFieldName', TRMPictureView_AssignBlobFieldName, 1, [0], varEmpty);

    AddGet(TOleContainer, 'LoadFromFile', TOleContainer_LoadFromFile, 1, [0], varEmpty);
  end;
end;

initialization
  RMRegisterObjectByRes(TRMOLEView, 'RM_OLEObject', RMLoadStr(SInsOLEObject), TRMOleForm);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);

finalization

end.

