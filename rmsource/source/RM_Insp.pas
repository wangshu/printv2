unit RM_Insp;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Comctrls, RM_Common, RM_DsgCtrls, RM_PropInsp, TypInfo
{$IFDEF USE_TB2K}
  , TB2Item, TB2Dock, TB2Toolbar
{$ELSE}
{$IFDEF USE_INTERNALTB97}
  , RM_TB97Ctls, RM_TB97Tlbr, RM_TB97
{$ELSE}
  , TB97Ctls, TB97Tlbr, TB97
{$ENDIF}
{$ENDIF}
{$IFDEF COMPILER6_UP}, Variants{$ENDIF};

const
  RMCompletionStr: array[0..21] of string = (
    'arrayd * array declaration (var) *array[0..|] of ;',
    'arrayc * array declaration (const) *array[0..|] of = ()',
    'ifeb * if then else *if | then/nbegin/n/nend/nelse/nbegin/n/nend;',
    'ife * if then (no begin/end) else (no begin/end) *if | then/n/nelse',
    'ifb * if statement *if | then/nbegin/n/nend;',
    'ifs * if (no begin/end) *if | then',
    'casee * case statement (with else) *case | of /n  : ;/n  : ;/nelse/n  ;/nend;',
    'cases * case statement *case | of/n  : ;/n  : ;/nend;',
    'forb * for statement *for | :=  to  do/nbegin/n/nend;',
    'fors * for (no begin/end) *for | :=  to  do',
    'whiles * while (no begin) *while | do',
    'whileb * while statement *while | do/nbegin/n/nend;',
    'procedure * procedure declaration *procedure |();/nbegin/n/nend;',
    'function * function declaration *function |(): ;/nbegin/n/nend;',
    'withs * with (no begin) *with | do',
    'withb * with statement *with | do/nbegin/n/nend;',
    'trycf * try finally (with Create/Free) *variable := typename.Create;/ntry/n/nfinally/n  variable.Free;/nend;',
    'tryf * try finally *try/n  |/nfinally/n/nend;',
    'trye * try except *try/n  |/nexcept/n/nend;',
    'classc * class declaration (with Create/Destroy overrides) *T| = class(T)/nprivate/n/nprotected/n/npublic/n  constructor Create; override;/n  destructor Destroy; override;/npublished/n/nend;',
    'classd * class declaration (no parts) *T| = class(T)/n/nend;',
    'classf * class declaration (all parts) *T| = class(T)/nprivate/n/nprotected/n/npublic/n/npublished/n/nend;'
    );
type

  TGetObjectsEvent = procedure(List: TStrings) of object;
  TSelectionChangedEvent = procedure(ObjName: string) of object;

  { TRMInspForm }
  TRMInspForm = class(TRMToolWin)
  private
    FTab: TTabControl;
    FCmbObjects: TComboBox;
    FInsp: TELPropertyInspector;
    FPanelTop: TPanel;
    FSplitter1: TSplitter;
    FPanelBottom, FPanel2: TPanel;
    FLabelTitle, FLabelCommon: TLabel;

    FCurObjectClassName: string;
    FSaveHeight: Integer;
{$IFNDEF COMPILER7_UP}
    FObjects: TStrings;
{$ENDIF}

    FOnGetObjects: TGetObjectsEvent;
    FOnSelectionChanged: TSelectionChangedEvent;

    function GetSplitterPos: Integer;
    procedure SetSplitterPos(Value: Integer);
    function GetSplitterPos1: Integer;
    procedure SetSplitterPos1(Value: Integer);
    procedure OnResizeEvent(Sender: TObject);
    procedure OnVisibleChangedEvent(Sender: TObject);
    procedure OnTabChangeEvent(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure Insp_OnClick(Sender: TObject);
    procedure OnGetEditorClassEvent(Sender: TObject;
      AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TELPropEditorClass);

    procedure cmbObjectsDropDown(Sender: TObject);
    procedure cmbObjectsClick(Sender: TObject);

    procedure WMLButtonDBLCLK(var Message: TWMNCLButtonDown); message WM_LBUTTONDBLCLK;
    procedure WMRButtonDBLCLK(var Message: TWMNCRButtonDown); message WM_RBUTTONDBLCLK;
    procedure OnMoveEvent(Sender: TObject);
    function GetObjects: TStrings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure AddObject(aObject: TPersistent);
    procedure AddObjects(aObjects: array of TPersistent);
    procedure ClearObjects;
    procedure SetCurrentObject(aClassName, aName: string);
    procedure SetCurReport(aObject: TObject);
    procedure RestorePos;
    procedure Localize;

    property Insp: TELPropertyInspector read FInsp;
    property Tab: TTabControl read FTab;
    property SplitterPos: Integer read GetSplitterPos write SetSplitterPos;
    property SplitterPos1: Integer read GetSplitterPos1 write SetSplitterPos1;
    property OnGetObjects: TGetObjectsEvent read FOnGetObjects write FOnGetObjects;
    property OnSelectionChanged: TSelectionChangedEvent read FOnSelectionChanged write FOnSelectionChanged;
    property Objects: TStrings read GetObjects;
    property cmbObjects: TComboBox read FcmbObjects;
  end;

procedure RMRegisterPropEditor(ATypeInfo: PTypeInfo; AObjectClass: TClass;
  const APropName: string; AEditorClass: TELPropEditorClass);

implementation

uses
  RM_Parser, RM_Class, RM_Const, RM_Const1, RM_Utils, RM_EditorMemo,
  RM_EditorBand, RM_EditorGroup, RM_EditorCalc, RM_EditorHilit,
  RM_EditorPicture, RM_EditorFormat, RM_EditorExpr, RM_Designer;

var
  FCurReport: TRMReport;
  FAddinPropEditors: TList;

type
  TRMAddinPropEditor = class
  private
  public
    TypeInfo: PTypeInfo;
    ObjectClass: TClass;
    PropName: string;
    EditorClass: TELPropEditorClass;
    constructor Create(ATypeInfo: PTypeInfo; AObjectClass: TClass;
      const APropName: string; AEditorClass: TELPropEditorClass);
  end;

constructor TRMAddinPropEditor.Create(ATypeInfo: PTypeInfo; AObjectClass: TClass;
  const APropName: string; AEditorClass: TELPropEditorClass);
begin
  inherited Create;
  TypeInfo := aTypeInfo;
  ObjectClass := aObjectClass;
  PropName := aPropName;
  EditorClass := aEditorClass;
end;

function RMAddinPropEditors: TList;
begin
  if FAddinPropEditors = nil then
    FAddinPropEditors := TList.Create;
  Result := FAddinPropEditors;
end;

procedure RMRegisterPropEditor(ATypeInfo: PTypeInfo; AObjectClass: TClass;
  const APropName: string; AEditorClass: TELPropEditorClass);
var
  liItem: TRMAddinPropEditor;
begin
  liItem := TRMAddinPropEditor.Create(aTypeInfo, aObjectClass, aPropName, aEditorClass);
  RMAddinPropEditors.Add(liItem);
end;

type
  THackView = class(TRMView)
  end;

  THackReportView = class(TRMReportView)
  end;

  THackPage = class(TRMCustomPage)
  end;

  TStringsPropEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TChildBandEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TGroupHeaderBandEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TGroupFooterBandEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TDataSetEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TGroupConditionEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TExpressionEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TCalcOptionsEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  THighlightEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TShiftWithEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TMasterMemoViewEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TPictureView_PictureEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TPageBackPictureEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TDataFieldEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TDisplayFormatEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  {created by dejoy}
  TMethodEditor = class(TELClassPropEditor)
  private
  protected
    function AllEqual: Boolean; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
    procedure Edit; override;
  end;

  TPicturePropEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TBitmapPropEditor = class(TELClassPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure Edit; override;
  end;

  TReportView_SubReportEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  TStyleNameEditor = class(TELStringPropEditor)
  protected
    function GetAttrs: TELPropAttrs; override;
    procedure GetValues(aValues: TStrings); override;
  end;

  {------------------------------------------------------------------------------}
  {------------------------------------------------------------------------------}
  { TStringsPropEditor }

function TStringsPropEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praReadOnly];
end;

procedure TStringsPropEditor.Edit;
var
  tmp: TRMEditorForm;
begin
  tmp := TRMEditorForm(RMDesigner.EditorForm);
  tmp.ToolBar2.Visible := True;
  tmp.Memo.Lines.Assign(TStrings(GetOrdValue(0)));
  if tmp.Execute then
    SetOrdValue(Longint(tmp.Memo.Lines));
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TChildBandEditor }

function TChildBandEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TChildBandEditor.GetValues(aValues: TStrings);
var
  i: Integer;
  t: TRMView;
  lList: TList;
  lParent: TPersistent;
  lCrossBand: Boolean;
begin
  lParent := GetInstance(0);
  lCrossBand := False;
  if (lParent is TRMCustomBandView) and TRMCustomBandView(lParent).IsCrossBand then
    lCrossBand := True;

  lList := RMDesigner.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if (t.IsBand) and (t <> lParent) then
    begin
      if lCrossBand and (TRMCustomBandView(t).BandType in [rmbtCrossChild]) then
        aValues.Add(t.Name);
      if (not lCrossBand) and (TRMCustomBandView(t).BandType in [rmbtChild]) then
        aValues.Add(t.Name);
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TGroupHeaderBandEditor }

function TGroupHeaderBandEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TGroupHeaderBandEditor.GetValues(aValues: TStrings);
var
  i: Integer;
  t: TRMView;
  lList: TList;
  lParent: TPersistent;
  lCrossBand: Boolean;
begin
  lParent := GetInstance(0);
  lCrossBand := False;
  if (lParent is TRMCustomBandView) and TRMCustomBandView(lParent).IsCrossBand then
    lCrossBand := True;

  lList := RMDesigner.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if (t.IsBand) and (t <> lParent) then
    begin
      if lCrossBand and (TRMCustomBandView(t).BandType in [rmbtCrossMasterData, rmbtCrossDetailData]) then
        aValues.Add(t.Name);
      if (not lCrossBand) and (TRMCustomBandView(t).BandType in [rmbtMasterData, rmbtDetailData]) then
        aValues.Add(t.Name);
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TGroupFooterBandEditor }

function TGroupFooterBandEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TGroupFooterBandEditor.GetValues(aValues: TStrings);
var
  i: Integer;
  t: TRMView;
  lList: TList;
  lParent: TPersistent;
  lCrossBand: Boolean;
begin
  lParent := GetInstance(0);
  lCrossBand := False;
  if (lParent is TRMCustomBandView) and TRMCustomBandView(lParent).IsCrossBand then
    lCrossBand := True;

  lList := RMDesigner.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if (t.IsBand) and (t <> lParent) then
    begin
      if lCrossBand and (TRMCustomBandView(t).BandType in [rmbtCrossGroupHeader]) then
        aValues.Add(t.Name);
      if (not lCrossBand) and (TRMCustomBandView(t).BandType in [rmbtGroupHeader]) then
        aValues.Add(t.Name);
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDataSetEditor }

function TDataSetEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TDataSetEditor.Edit;
var
  tmp: TRMBandEditorForm;
begin
  tmp := TRMBandEditorForm.Create(nil);
  try
    if tmp.ShowEditor(TRMView(GetInstance(0))) = mrOK then
      SetStrValue(TRMBandMasterData(GetInstance(0)).DataSetName);
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TGroupConditionEditor }

function TGroupConditionEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TGroupConditionEditor.Edit;
var
  tmp: TRMGroupEditorForm;
begin
  tmp := TRMGroupEditorForm.Create(nil);
  try
    tmp.ShowEditor(TRMView(GetInstance(0)));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TExpressionEditor }

function TExpressionEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog];
end;

procedure TExpressionEditor.Edit;
var
  lStr: string;
begin
  lStr := GetStrValue(0);
  if RM_EditorExpr.RMGetExpression('', lStr, nil, False) then
  begin
    if lStr <> '' then
    begin
      if not ((lStr[1] = '[') and (lStr[Length(lStr)] = ']') and
        (Pos('[', Copy(lStr, 2, 999999)) = 0)) then
        lStr := '[' + lStr + ']';
    end;

    SetStrValue(lStr);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TCalcOptionsEditor }

function TCalcOptionsEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praDialog, praReadOnly];
end;

procedure TCalcOptionsEditor.Edit;
var
  tmp: TRMCalcMemoEditorForm;
begin
  tmp := TRMCalcMemoEditorForm.Create(nil);
  try
    tmp.ShowEditor(TRMView(GetInstance(0)));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ THighlightEditor }

function THighlightEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praDialog, praReadOnly];
end;

procedure THighlightEditor.Edit;
var
  tmp: TRMHilightForm;
begin
  tmp := TRMHilightForm.Create(nil);
  try
    tmp.ShowEditor(TRMView(GetInstance(0)));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TShiftWithEditor }

function TShiftWithEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TShiftWithEditor.GetValues(aValues: TStrings);
var
  i, j: Integer;
  t: TRMView;
  liParentBand: TRMView;
  lList: TList;
begin
  lList := RMDesigner.PageObjects;
  t := TRMView(GetInstance(0));
  for i := 0 to lList.Count - 1 do
  begin
    liParentBand := lList[i];
    if (t.spTop >= liParentBand.spTop) and (t.spBottom <= liParentBand.spBottom) then
    begin
      for j := 0 to lList.Count - 1 do
      begin
        t := lList[j];
        if THackView(t).Stretched and (t is TRMStretcheableView) and (GetInstance(0) <> t) and
          (t.spTop >= liParentBand.spTop) and (t.spBottom <= liParentBand.spBottom) then
          aValues.Add(t.Name);
      end;
      Break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TMasterMemoViewEditor }

function TMasterMemoViewEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TMasterMemoViewEditor.GetValues(aValues: TStrings);
var
  i: Integer;
  t: TRMView;
  lList: TList;
begin
  lList := RMDesigner.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if (t is TRMCustomMemoView) and (GetInstance(0) <> t) then
      aValues.Add(t.Name);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TPictureView_PictureEditor }

function TPictureView_PictureEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praDialog, praReadOnly];
end;

procedure TPictureView_PictureEditor.Edit;
var
  tmp: TRMPictureEditorForm;
begin
  tmp := TRMPictureEditorForm.Create(nil);
  try
    tmp.ShowEditor(TRMView(GetInstance(0)));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TPageBackPictureEditor }

function TPageBackPictureEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praSubProperties, praDialog, praReadOnly];
end;

procedure TPageBackPictureEditor.Edit;
var
  tmp: TRMPictureEditorForm;
begin
  tmp := TRMPictureEditorForm.Create(nil);
  try
    tmp.ShowbkPicture(TRMReportPage(GetInstance(0)));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDataFieldEditor }

function TDataFieldEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praDialog];
end;

procedure TDataFieldEditor.Edit;
var
  lStr: string;
begin
  lStr := RMDesigner.InsertDBField(TRMView(GetInstance(0)));
  if lStr <> '' then
    SetStrValue(lStr);
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TDisplayFormatEditor }

type
  THackMemoView = class(TRMCustomMemoView)
  end;

function TDisplayFormatEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praDialog, praMultiSelect];
end;

procedure TDisplayFormatEditor.Edit;
var
  t: TRMView;
  tmp: TRMDisplayFormatForm;
begin
  t := TRMView(GetInstance(0));
  if not (t is TRMCustomMemoView) then Exit;

  tmp := TRMDisplayFormatForm.Create(nil);
  try
    tmp.ShowEditor(t);
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

function TMethodEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praValueList, praSortList, praMethodProp];
end;

procedure TMethodEditor.Edit;
var
  t: TObject;
  ts, s, OldFunName, FunName: string;
begin
  t := GetInstance(0);
  s := '%s_%s';
  OldFunName := Value;
  FunName := OldFunName;
  if FunName = '' then
  begin
    if t is TRMPersistent then
      ts := TRMPersistent(t).Name
    else if t is TRMReport then
      ts := 'Report'
    else if t is TComponent then
      ts := TComponent(t).Name;

    FunName := Format(s, [ts, PropName]);
  end;
  Value := FunName;
end;

procedure TMethodEditor.GetValues(AValues: TStrings);
begin
  RMDesigner.GetMethodsList(PropTypeInfo, AValues);
end;

function TMethodEditor.GetValue: string;
var
  t: TPersistent;
begin
  t := GetInstance(0);

  Result := FCurReport.ReportEventVars.GetEventPropVar(t, PropName);
end;

procedure TMethodEditor.SetValue(const Value: string);
var
  t: TPersistent;
  lPropInf: PPropInfo;
  lFunName, lOldValue: string;
  lDefine: string;
  lsPropName: string;
  lSelObjList: TList;
  i: integer;

  procedure _DoSetPropEvent;
  var
    j: integer;
  begin
    if SameText(lOldValue, Value) then Exit;
    for j := 0 to lSelObjList.Count - 1 do
    begin
      t := lSelObjList[j];
      FCurReport.ReportEventVars.SetEventPropVar(t, lsPropName, lFunName)
    end;
    Modified;
  end;

begin //dejoy
  lOldValue := Self.Value;
  t := GetInstance(0);
  lFunName := Value;
  lPropInf := GetPropInfo(0);
  lsPropName := PropName;

  if (lPropInf.PropType^.Kind <> tkMethod) then
    Exit;
  if SameText(lOldValue, lFunName) then
  begin
    RMDesigner.GotoMethod(lFunName);
    Exit;
  end;
  lSelObjList := TList.Create;
  try

    for i := 0 to PropCount - 1 do
      lSelObjList.Add(GetInstance(i));

    if Trim(lFunName) <> '' then
    begin
      lDefine := GetMethodDefinition(PropTypeInfo);
      Insert(Value, lDefine, Pos('(', lDefine));

      if not RMDesigner.FunctionExists(lFunName) then //事件函数代码不存在
      begin
        if (lOldValue = '') then //原事件函数未赋值,则新增代码
        begin
          if RMDesigner.DefineMethod(lFunName, lDefine) then
          begin
            RMDesigner.GotoMethod(lFunName);
          end;
        end
        else //原事件函数已赋值则改名
        begin
          RMDesigner.RenameMethod(lOldValue, lFunName);
          FCurReport.ReportEventVars.RenameEventProc(lOldValue, lFunName);
        end;
      end;
    end;

    _DoSetPropEvent;

  finally
    lSelObjList.Free;
  end;

end;


function TMethodEditor.AllEqual: Boolean;
var
  LI: Integer;
  t: TPersistent;
  lpropName, LV: string;
begin
  Result := True;
  lpropName := PropName;
  t := GetInstance(0);
  LV := FCurReport.ReportEventVars.GetEventPropVar(t, lpropName);

  if PropCount > 1 then
    for LI := 1 to PropCount - 1 do
      with FCurReport.ReportEventVars do
        if not SameText(GetEventPropVar(GetInstance(LI), lpropName), Lv) then
        begin
          Result := False;
          Break;
        end;

end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TPicturePropEditor }

function TPicturePropEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praReadOnly];
end;

procedure TPicturePropEditor.Edit;
var
  tmp: TRMPictureEditorForm;
begin
  tmp := TRMPictureEditorForm.Create(nil);
  try
    tmp.Picture := TPicture(GetOrdValue(0));
    if tmp.ShowModal = mrOK then
      SetOrdValue(Longint(tmp.Picture));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TBitmapPropEditor }

function TBitmapPropEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praReadOnly];
end;

procedure TBitmapPropEditor.Edit;
var
  tmp: TRMPictureEditorForm;
begin
  tmp := TRMPictureEditorForm.Create(nil);
  try
    tmp.PictureTypes := ' (*.bmp)|*.bmp';
    tmp.Picture.Assign(TBitmap(GetOrdValue(0)));
    if tmp.ShowModal = mrOK then
      SetOrdValue(Longint(tmp.Picture.Bitmap));
  finally
    tmp.Free;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TReportView_SubReportEditor }

function TReportView_SubReportEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TReportView_SubReportEditor.GetValues(aValues: TStrings);
var
  i: Integer;
  t: TRMView;
  lList: TList;
begin
  lList := RMDesigner.PageObjects;
  for i := 0 to lList.Count - 1 do
  begin
    t := lList[i];
    if (t is TRMSubReportView) and (TRMSubReportView(t).SubReportType = rmstChild) then
      aValues.Add(t.Name);
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TStyleNameEditor }

function TStyleNameEditor.GetAttrs: TELPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TStyleNameEditor.GetValues(aValues: TStrings);
var
  lReport: TRMReport;
  i: Integer;
begin
  lReport := THackView(GetInstance(0)).ParentReport;
  for i := 0 to lReport.TextStyles.Count - 1 do
  begin
    aValues.Add(lReport.TextStyles[i].StyleName);
  end;
end;




{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMInspForm }

procedure TRMInspForm.OnGetEditorClassEvent(Sender: TObject;
  AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TELPropEditorClass);
begin
  aEditorClass := nil;
  if aPropInfo.PropType^.Kind = tkMethod then
  begin
    aEditorClass := TMethodEditor;
  end;
end;

constructor TRMInspForm.Create(AOwner: TComponent);

  procedure _RegisterPropEditor;
  var
    i: Integer;
    liItem: TRMAddinPropEditor;
  begin
    FInsp.RegisterPropEditor(TypeInfo(TWideStrings), nil, 'Memo', TStringsPropEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBand, 'ChildBand', TChildBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandHeader, 'DataBandName', TGroupHeaderBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandFooter, 'DataBandName', TGroupHeaderBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandGroupHeader, 'MasterBandName', TGroupHeaderBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandGroupFooter, 'GroupHeaderBandName', TGroupFooterBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandDetailData, 'MasterBandName', TGroupHeaderBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCustomBandView, 'DataSetName', TDataSetEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBandGroupHeader, 'GroupCondition', TGroupConditionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcMemoView, 'ResultExpression', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBand, 'PrintCondition', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBand, 'NewPageCondition', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMBand, 'OutlineText', TExpressionEditor);

    FInsp.RegisterPropEditor(TypeInfo(TRMHighlight), TRMCustomMemoView, 'Highlight', THighlightEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMHighlight, 'Condition', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMReportView, 'ShiftWith', TShiftWithEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMReportView, 'StretchWith', TShiftWithEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMReportView, 'ShiftRelativeTo', TShiftWithEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMReportView, 'DataField', TDataFieldEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMRepeatedOptions, 'MasterMemoView', TMasterMemoViewEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), nil, 'DisplayFormat', TDisplayFormatEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), nil, 'StyleName', TStyleNameEditor);

    FInsp.RegisterPropEditor(TypeInfo(TRMCalcOptions), TRMCalcMemoView, 'CalcOptions', TCalcOptionsEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcOptions, 'Filter', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcOptions, 'IntalizeValue', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcOptions, 'AggregateValue', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcOptions, 'AggrBandName', TGroupHeaderBandEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMCalcOptions, 'ResetGroupName', TExpressionEditor);
    FInsp.RegisterPropEditor(TypeInfo(string), TRMReportView, 'SubReport', TReportView_SubReportEditor);

    FInsp.RegisterPropEditor(TypeInfo(TPicture), nil, 'Picture', TPicturePropEditor);
    FInsp.RegisterPropEditor(TypeInfo(TPicture), TRMPictureView, 'Picture', TPictureView_PictureEditor);
    FInsp.RegisterPropEditor(TypeInfo(TPicture), TRMReportPage, 'BackPicture', TPageBackPictureEditor);
    FInsp.RegisterPropEditor(TypeInfo(TBitmap), nil, '', TBitmappropEditor);

    if FAddinPropEditors <> nil then
    begin
      for i := 0 to FAddinPropEditors.Count - 1 do
      begin
        liItem := FAddinPropEditors[i];
        with liItem do
          FInsp.RegisterPropEditor(TypeInfo, ObjectClass, PropName, EditorClass);
      end;
    end;
  end;

begin
  inherited Create(AOwner);

  FPanelTop := TPanel.Create(Self);
  FPanelTop.Parent := Self;
  FPanelTop.Align := alTop;
  FPanelTop.Height := 26;
  FPanelTop.BevelOuter := bvNone;

{$IFNDEF COMPILER7_UP}
  FObjects := TStringList.Create();
{$ENDIF}
  FcmbObjects := TComboBox.Create(Self);
  with FcmbObjects do
  begin
    Parent := FPanelTop;
    SetBounds(0, 2, 21, 169);
    Style := csDropDownList;
    DropDownCount := 12;
    ItemHeight := 15;
    Sorted := True;
{$IFDEF COMPILER7_UP}
    Items.NameValueSeparator := ' ';
{$ENDIF}
    OnClick := cmbObjectsClick;
    OnDropDown := cmbObjectsDropDown;
  end;

  FTab := TTabControl.Create(Self);
  with FTab do
  begin
    Parent := Self;
    HotTrack := True;
    Align := alClient;
    OnChange := OnTabChangeEvent;
  end;

  FInsp := TELPropertyInspector.Create(Self);
  with FInsp do
  begin
    Parent := FTab;
    Align := alClient;
    OnClick := Insp_OnClick;
    OnGetEditorClass := OnGetEditorClassEvent;
  end;
  _RegisterPropEditor;

  FSplitter1 := TSplitter.Create(Self);
  with FSplitter1 do
  begin
    Parent := Self;
    Align := alBottom;
    Cursor := crVSplit;
  end;

  FPanelBottom := TPanel.Create(Self);
  with FPanelBottom do
  begin
    Parent := Self;
    Align := alBottom;
    Height := 54;
    BevelOuter := bvNone;
    BorderWidth := 2;
  end;
  FPanel2 := TPanel.Create(Self);
  with FPanel2 do
  begin
    Parent := FPanelBottom;
    SetBounds(2, 2, 172, 50);
    Align := alClient;
    BevelOuter := bvLowered;
    OnResize := Panel2Resize;
  end;
  FLabelTitle := TLabel.Create(Self);
  with FLabelTitle do
  begin
    Parent := FPanel2;
    SetBounds(6, 1, 155, 13);
    AutoSize := False;
  end;
  FLabelCommon := TLabel.Create(Self);
  with FLabelCommon do
  begin
    Parent := FPanel2;
    SetBounds(12, 17, 154, 28);
    AutoSize := False;
    Color := clBtnFace;
    WordWrap := True;
  end;

{$IFDEF USE_TB2k}
  Parent := TWinControl(AOwner);
  Floating := True;
{$ENDIF}
  FullSize := False;
  CloseButtonWhenDocked := True;
  UseLastDock := False;

  SetBounds(438, 179, 184, 308);
  FSaveHeight := ClientHeight;
  OnResize := OnResizeEvent;
  OnVisibleChanged := OnVisibleChangedEvent;
  OnMove := OnMoveEvent;

  OnResizeEvent(nil);
  Localize;
end;

destructor TRMInspForm.Destroy;
begin
{$IFNDEF COMPILER7_UP}
  FObjects.Free();
{$ENDIF}
  inherited Destroy;
end;

procedure TRMInspForm.SetCurReport(aObject: TObject);
begin
  FCurReport := TRMReport(aObject);
end;

procedure TRMInspForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  FInsp.Font.Assign(Font);

  RMSetStrProp(Self, 'Caption', rmRes + 70);
  Tab.Tabs.Clear;
  Tab.Tabs.Add(RMLoadStr(rmRes + 71));
  Tab.Tabs.Add(RMLoadStr(rmRes + 72));

  FLabelCommon.Font.Color := clBlue;
end;

procedure TRMInspForm.BeginUpdate;
begin
  FInsp.BeginUpdate;
end;

procedure TRMInspForm.EndUpdate;
begin
  FInsp.EndUpdate;
  Insp_OnClick(nil);
end;

procedure TRMInspForm.AddObject(aObject: TPersistent);
begin
  FInsp.Add(aObject);
end;

procedure TRMInspForm.AddObjects(aObjects: array of TPersistent);
begin
  FInsp.AddObjects(aObjects);
end;

procedure TRMInspForm.ClearObjects;
begin
  FInsp.Clear;
end;

procedure TRMInspForm.SetCurrentObject(aClassName, aName: string);
begin
  if (FcmbObjects.ItemIndex < 0) or (Objects.Names[FcmbObjects.ItemIndex] <> aName) then
  begin
    FCurObjectClassName := aClassName;
    cmbObjectsDropDown(nil);
    FcmbObjects.ItemIndex := Objects.IndexOfName(aName);
  end;
end;

{$IFNDEF COMPILER7_UP}

function CVStringsSep(Src, dsc: TStrings; OldSep, NewSep: Char): boolean;
var
  i: integer;
begin
  Result := false;
  if (Src = nil) or (Src.Count = 0) then Exit;
  if dsc = nil then dsc := TStringList.Create();

  Dsc.Clear;
  Dsc.AddStrings(Src);
  for i := 0 to Dsc.Count - 1 do
  begin
    Dsc[i] := StringReplace(Dsc[i], OldSep, NewSep, []);
  end;
  Result := True;
end;
{$ENDIF}

procedure TRMInspForm.cmbObjectsDropDown(Sender: TObject);
var
  s: string;
begin
  if FcmbObjects.ItemIndex <> -1 then
    s := Objects.Names[FcmbObjects.ItemIndex]
  else
    s := '';

  if Assigned(FOnGetObjects) then
    FOnGetObjects(FcmbObjects.Items);

{$IFNDEF COMPILER7_UP}
  CVStringsSep(FcmbObjects.Items, FObjects, ' ', '='); //转换
{$ENDIF}
  FcmbObjects.ItemIndex := Objects.IndexOfName(s);
end;

procedure TRMInspForm.cmbObjectsClick(Sender: TObject);
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Objects.Names[FCmbObjects.ItemIndex]);
end;

procedure TRMInspForm.OnResizeEvent(Sender: TObject);
begin
  FSaveHeight := ClientHeight;
  FcmbObjects.Width := ClientWidth;
end;

procedure TRMInspForm.OnVisibleChangedEvent(Sender: TObject);
begin
end;

function TRMInspForm.GetSplitterPos: Integer;
begin
  Result := FInsp.Splitter;
end;

procedure TRMInspForm.SetSplitterPos(Value: Integer);
begin
  if (Value > 10) and (Value < FInsp.ClientWidth - 10) then
  begin
    FInsp.Splitter := Value;
  end;
end;

function TRMInspForm.GetSplitterPos1: Integer;
begin
  Result := FInsp.Height;
end;

procedure TRMInspForm.SetSplitterPos1(Value: Integer);
begin
  FInsp.Height := Value;
end;

procedure TRMInspForm.OnTabChangeEvent(Sender: TObject);
begin
  BeginUpdate;
  if FTab.TabIndex = 0 then
    FInsp.PropKinds := [pkProperties]
  else
    FInsp.PropKinds := [pkEvents];
  EndUpdate;
end;

procedure TRMInspForm.WMLButtonDBLCLK(var Message: TWMNCLButtonDown);
var
  liSaveHeight: Integer;
begin
  FInsp.ClosePopup;
  if ClientHeight > 0 then
  begin
    liSaveHeight := ClientHeight;
    ClientHeight := 0;
    FSaveHeight := liSaveHeight;
  end
  else
    ClientHeight := FSaveHeight;
end;

procedure TRMInspForm.RestorePos;
begin
  if ClientHeight > 0 then
  begin
  end
  else
    ClientHeight := FSaveHeight;
end;

procedure TRMInspForm.WMRButtonDBLCLK(var Message: TWMNCRButtonDown);
var
  liSaveHeight: Integer;
begin
  FInsp.ClosePopup;
  if ClientHeight > 0 then
  begin
    liSaveHeight := ClientHeight;
    ClientHeight := 0;
    FSaveHeight := liSaveHeight;
  end
  else
    ClientHeight := FSaveHeight;
end;

procedure TRMInspForm.OnMoveEvent(Sender: TObject);
begin
  FInsp.ClosePopup;
end;

function TRMInspForm.GetObjects: TStrings;
begin
{$IFDEF COMPILER7_UP}
  Result := FcmbObjects.Items;
{$ELSE}
  Result := FObjects;
{$ENDIF}
end;

procedure TRMInspForm.Panel2Resize(Sender: TObject);
begin
  FLabelTitle.Width := FPanel2.ClientWidth - FLabelTitle.Left - 2;
  FLabelCommon.Width := FPanel2.ClientWidth - FLabelCommon.Left - 2;
  FLabelCommon.Height := FPanel2.ClientHeight - FLabelCommon.Top - 2;
end;

procedure TRMInspForm.Insp_OnClick(Sender: TObject);
var
  lActiveItem: TELPropsPageItem;
  t: TPersistent;
  PropInf: PPropInfo;
begin
  lActiveItem := FInsp.ActiveItem;
  t := TPersistent(FInsp.Objects[0]); //dejoy modify by 2003-9-28
  if lActiveItem = nil then
  begin
    FLabelTitle.Caption := '';
    FLabelCommon.Caption := '';
  end
  else
  begin
    if RMLocalizedPropertyNames then
      FLabelTitle.Caption := lActiveItem.VirtualCaption
    else
      FLabelTitle.Caption := lActiveItem.Caption;

    //dejoy added begin at 2003-9-28
    PropInf := GetPropInfo(t, lActiveItem.Caption, [tkMethod]);
    if PropInf <> nil then
    begin
      FLabelCommon.Caption := GetMethodDefinition(PropInf.PropType^);
      if lActiveItem.PropCommon <> FLabelTitle.Caption then
        FLabelCommon.Caption := FLabelCommon.Caption + #13#10 + lActiveItem.PropCommon;
    end
    else
      FLabelCommon.Caption := lActiveItem.PropCommon;
    //dejoy added end at 2003-9-28
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure ClearPropeditors;
var
  i: Integer;
begin
  if FAddinPropEditors <> nil then
  begin
    for i := 0 to FAddinPropEditors.Count - 1 do
    begin
      TRMAddinPropEditor(FAddinPropEditors[i]).Free;
    end;
    FAddinPropEditors.Clear;
  end;
end;

initialization

finalization
  if FAddinPropEditors <> nil then
  begin
    ClearPropeditors;
    FAddinPropEditors.Free;
    FAddinPropEditors := nil;
  end;

end.

