
{******************************************}
{                                          }
{  Report Machine v2.0 - Dialog designer   }
{         Standard Dialog controls         }
{                                          }
{******************************************}

unit RM_DialogCtls;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, RM_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, Comctrls, Extctrls, Mask, CheckLst,
  Buttons,
  RM_Common
  {$IFDEF USE_INTERNAL_JVCL}
  , rm_JvTypes, rm_JvInterpreter, rm_JvInterpreter_StdCtrls, rm_JvInterpreter_Controls
  {$ELSE}
  , JvTypes, JvInterpreter, JvInterpreter_StdCtrls, JvInterpreter_Controls
  {$ENDIF}
  {$IFDEF JVCLCTLS}
  , JvToolEdit
  {$ENDIF}
  {$IFDEF COMPILER6_UP}, Variants{$ENDIF};

type
  TRMDialogControls = class(TComponent) // fake component
  end;

  { TRMCustomControl }
  TRMCustomControl = class(TRMDialogControl)
  private
    function GetColor: TColor;
    procedure SetColor(Value: TColor);
    function GetEnabled: Boolean;
    procedure SetEnabled(Value: Boolean);
    function GetShowHint: Boolean;
    procedure SetShowHint(Value: Boolean);
    function GetHint: string;
    procedure SetHint(Value: string);
    function GetOnClickEvent: TNotifyEvent;
    procedure SetOnClickEvent(Value: TNotifyEvent);
    function GetOnDblClickEvent: TNotifyEvent;
    procedure SetOnDblClickEvent(Value: TNotifyEvent);
  protected
    function GetFont: TFont; override;
    procedure SetFont(Value: TFont); override;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
  public
    constructor Create; override;
    procedure AssignControl(AControl: TControl);
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    procedure ShowEditor; override;

    property Control: TControl read FControl;
  published
    //    property ParentFont;
    property Left;
    property Top;
    property Width;
    property Height;
    property ShowHint: Boolean read GetShowHint write SetShowHint;
    property Hint: string read GetHint write SetHint;
    property Color: TColor read GetColor write SetColor;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property OnClick: TNotifyEvent read GetOnClickEvent write SetOnClickEvent;
    property OnDblClick: TNotifyEvent read GetOnDblClickEvent write SetOnDblClickEvent;
  end;

  { TRMLabelControl }
  TRMLabelControl = class(TRMCustomControl)
  private
    FLabel: TLabel;
    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetAutoSize: Boolean;
    procedure SetAutoSize(Value: Boolean);
    function GetAlignment: TAlignment;
    procedure SetAlignment(Value: TAlignment);
    function GetWordwrap: Boolean;
    procedure SetWordwrap(Value: Boolean);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(aCanvas: TCanvas); override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property Caption: string read GetCaption write SetCaption;
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
    property Wordwrap: Boolean read GetWordwrap write SetWordwrap;
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    //    property LabelCtl: TLabel read FLabel;
  end;

  { TRMEditControl }
  TRMEditControl = class(TRMCustomControl)
  private
    FEdit: TEdit;

    function GetText: string;
    procedure SetText(Value: string);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Text: string read GetText write SetText;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    //    property EditCtl: TEdit read FEdit;
  end;

  { TRMMaskEditControl }
  TRMMaskEditControl = class(TRMCustomControl)
  private
    FEdit: TMaskEdit;

    function GetEditMask: string;
    procedure SetEditMask(Value: string);
    function GetText: string;
    procedure SetText(Value: string);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property MaskEdit: TMaskEdit read FEdit;
  published
    property Font;
    property TabOrder;
    property EditMask: string read GetEditMask write SetEditMask;
    property Text: string read GetText write SetText;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    //    property EditCtl: TMaskEdit read FEdit;
  end;

  { TRMMemoControl }
  TRMMemoControl = class(TRMCustomControl)
  private
    FMemo: TMemo;

    function GetLines: TStrings;
    procedure SetLines(Value: TStrings);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Lines: TStrings read GetLines write SetLines;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    //    property MemoCtrl: TMemo read FMemo;
  end;

  { TRMButtonControl }
  TRMButtonControl = class(TRMCustomControl)
  private
    FButton: TButton;

    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetCancel: Boolean;
    procedure SetCancel(Value: Boolean);
    function GetDefault: Boolean;
    procedure SetDefault(Value: Boolean);
    function GetModalResult: TModalResult;
    procedure SetModalResult(Value: TModalResult);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Caption: string read GetCaption write SetCaption;
    property Cancel: Boolean read GetCancel write SetCancel;
    property Default: Boolean read GetDefault write SetDefault;
    property ModalResult: TModalResult read GetModalResult write SetModalResult;
    //    property ButtonCtl: TButton read FButton;
  end;

  { TRMCheckBoxControl }
  TRMCheckBoxControl = class(TRMCustomControl)
  private
    FCheckBox: TCheckBox;

    function GetChecked: Boolean;
    procedure SetChecked(Value: Boolean);
    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetAlignment: TAlignment;
    procedure SetAlignment(Value: TAlignment);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Checked: Boolean read GetChecked write SetChecked;
    property Caption: string read GetCaption write SetCaption;
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    //    property CheckBoxCtl: TCheckBox read FCheckBox;
  end;

  { TRMRadioButtonControl }
  TRMRadioButtonControl = class(TRMCustomControl)
  private
    FRadioButton: TRadioButton;

    function GetChecked: Boolean;
    procedure SetChecked(Value: Boolean);
    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetAlignment: TAlignment;
    procedure SetAlignment(Value: TAlignment);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Checked: Boolean read GetChecked write SetChecked;
    property Caption: string read GetCaption write SetCaption;
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    //    property RadioButtonCtl: TRadioButton read FRadioButton;
  end;

  { TRMListBoxControl }
  TRMListBoxControl = class(TRMCustomControl)
  private
    FListBox: TListBox;

    function GetItems: TStrings;
    procedure SetItems(Value: TStrings);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    //    property ListBoxCtl: TListBox read FListBox;
  end;

  TRMComboBoxStyle = (rmcsDropDown, rmcsDropDownList, rmcsLookup);

  { TRMComboBoxControl }
  TRMComboBoxControl = class(TRMCustomControl)
  private
    FComboBox: TComboBox;
    FStyle: TRMComboBoxStyle;

    procedure ComboBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function GetItems: TStrings;
    procedure SetItems(Value: TStrings);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
    function GetText: string;
    procedure SetText(Value: string);
    procedure SetStyle(Value: TRMComboBoxStyle);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Text: string read GetText write SetText;
    property Style: TRMComboBoxStyle read FStyle write SetStyle;
    //    property ComboBoxCtl: TComboBox read FComboBox;
  end;

  TRMDateEditControl = class(TRMCustomControl)
  private
    FDateEdit: TDateTimePicker;

    function GetDate: TDate;
    procedure SetDate(Value: TDate);
    function GetTime: TTime;
    procedure SetTime(Value: TTime);
    function GetDateFormat: TDTDateFormat;
    procedure SetDateFormat(Value: TDTDateFormat);
    function GetKind: TDateTimeKind;
    procedure SetKind(Value: TDateTimeKind);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
  published
    property Font;
    property TabOrder;
    property Date: TDate read GetDate write SetDate;
    property Time: TTime read GetTime write SetTime;
    property DateFormat: TDTDateFormat read GetDateFormat write SetDateFormat;
    property Kind: TDateTimeKind read GetKind write SetKind;
    //    property DateEditCtl: TDateTimePicker read FDateEdit;
  end;

  {$IFDEF JVCLCTLS}
  TRMRXDateEditControl = class(TRMCustomControl)
  private
    FDateEdit: TJvDateEdit;

    function GetText: string;
    procedure SetText(Value: string);
    function GetDialogTitle: string;
    procedure SetDialogTitle(Value: string);
    function GetStartOfWeek: TDayOfWeekName;
    procedure SetStartOfWeek(Value: TDayOfWeekName);
    function GetYearDigits: TYearDigits;
    procedure SetYearDigits(Value: TYearDigits);
    function GetClickKey: TShortCut;
    procedure SetClickKey(Value: TShortCut);
    function GetCalendarStyle: TCalendarStyle;
    procedure SetCalendarStyle(Value: TCalendarStyle);
    function GetDefaultToday: Boolean;
    procedure SetDefaultToday(Value: Boolean);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant; Args: array of Variant): Boolean; override;
    function SetPropValue(aObject: TObject; aPropName: string; aValue: Variant): Boolean; override;
  published
    //    property DateEditCtl: TJvDateEdit read FDateEdit;
    property Font;
    property TabOrder;
    property Text: string read GetText write SetText;
    property DialogTitle: string read GetDialogTitle write SetDialogTitle;
    property StartOfWeek: TDayOfWeekName read GetStartOfWeek write SetStartOfWeek;
    property YearDigits: TYearDigits read GetYearDigits write SetYearDigits;
    property ClickKey: TShortCut read GetClickKey write SetClickKey;
    property CalendarStyle: TCalendarStyle read GetCalendarStyle write SetCalendarStyle;
    property DefaultToday: Boolean read GetDefaultToday write SetDefaultToday;
  end;
  {$ENDIF}

  { TRMCheckListBoxControl }
  TRMCheckListBoxControl = class(TRMCustomControl)
  private
    FCheckListBox: TCheckListBox;

    function GetItems: TStrings;
    procedure SetItems(Value: TStrings);
    function GetItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property CheckListBox: TCheckListBox read FCheckListBox;
  published
    property Font;
    property TabOrder;
    property Items: TStrings read GetItems write SetItems;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
  end;

  { TRMPanelControl }
  TRMPanelControl = class(TRMCustomControl)
  private
    FPanel: TPanel;

    function GetBevelInner: TPanelBevel;
    procedure SetBevelInner(Value: TPanelBevel);
    function GetBevelOuter: TPanelBevel;
    procedure SetBevelOuter(Value: TPanelBevel);
    function GetBevelWidth: Integer;
    procedure SetBevelWidth(Value: Integer);
    function GetBorderStyle: TBorderStyle;
    procedure SetBorderStyle(Value: TBorderStyle);
    function GetBorderWidth: Integer;
    procedure SetBorderWidth(Value: Integer);
    function GetCaption: string;
    procedure SetCaption(Value: string);
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    function IsContainer: Boolean; override;
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property Panel: TPanel read FPanel;
  published
    property Font;
    property TabOrder;
    property BevelInner: TPanelBevel read GetBevelInner write SetBevelInner;
    property BevelOuter: TPanelBevel read GetBevelOuter write SetBevelOuter;
    property BevelWidth: Integer read GetBevelWidth write SetBevelWidth;
    property BorderStyle: TBorderStyle read GetBorderStyle write SetBorderStyle;
    property BorderWidth: Integer read GetBorderWidth write SetBorderWidth;
    property Caption: string read GetCaption write SetCaption;
  end;

  { TRMGroupBoxControl }
  TRMGroupBoxControl = class(TRMCustomControl)
  private
    FGroupBox: TGroupBox;
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
    function IsContainer: Boolean; override;
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property GroupBox: TGroupBox read FGroupBox;
  published
    property Font;
    property TabOrder;
    function GetCaption: string;
    procedure SetCaption(Value: string);
    property Caption: string read GetCaption write SetCaption;
  end;

  { TRMImageControl }
  TRMImageControl = class(TRMCustomControl)
  private
    FImage: TImage;

    function GetPicture: TPicture;
    procedure SetPicture(Value: TPicture);
    function GetAutoSize(Index: Integer): Boolean;
    procedure SetAutoSize(Index: Integer; Value: Boolean);
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property Image: TImage read FImage;
  published
    property Picture: TPicture read GetPicture write SetPicture;
    property AutoSize: Boolean index 0 read GetAutoSize write SetAutoSize;
    property Center: Boolean index 1 read GetAutoSize write SetAutoSize;
    property Stretch: Boolean index 2 read GetAutoSize write SetAutoSize;
    property Transparent: Boolean index 3 read GetAutoSize write SetAutoSize;
  end;

  { TRMBevelControl }
  TRMBevelControl = class(TRMCustomControl)
  private
    FBevel: TBevel;
  protected
    function GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
      Args: array of Variant): Boolean; override;
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property Bevel: TBevel read FBevel;
  published
  end;

  { TRMSpeedButtonControl }
  TRMSpeedButtonControl = class(TRMCustomControl)
  private
    FSpeedButton: TSpeedButton;

    function GetCaption: string;
    procedure SetCaption(Value: string);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property SpeedButton: TSpeedButton read FSpeedButton;
  published
    property Font;
    property TabOrder;
    property Caption: string read GetCaption write SetCaption;
  end;

  { TRMBitBtnControl }
  TRMBitBtnControl = class(TRMCustomControl)
  private
    FBitBtn: TBitBtn;

    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetCancel: Boolean;
    procedure SetCancel(Value: Boolean);
    function GetDefault: Boolean;
    procedure SetDefault(Value: Boolean);
    function GetModalResult: TModalResult;
    procedure SetModalResult(Value: TModalResult);
    function GetGlyph: TBitmap;
    procedure SetGlyph(Value: TBitmap);
    function GetKind: TBitBtnKind;
    procedure SetKind(Value: TBitBtnKind);
    function GetLayout: TButtonLayout;
    procedure SetLayout(Value: TButtonLayout);
    function GetNumGlyphs: Integer;
    procedure SetNumGlyphs(Value: Integer);
    function GetSpacing: Integer;
    procedure SetSpacing(Value: Integer);
  protected
  public
    class procedure DefaultSize(var aKx, aKy: Integer); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure SaveToStream(aStream: TStream); override;

    property BitBtn: TBitBtn read FBitBtn;
  published
    property Font;
    property TabOrder;
    property Caption: string read GetCaption write SetCaption;
    property Cancel: Boolean read GetCancel write SetCancel;
    property Default: Boolean read GetDefault write SetDefault;
    property ModalResult: TModalResult read GetModalResult write SetModalResult;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property Kind: TBitBtnKind read GetKind write SetKind;
    property Layout: TButtonLayout read GetLayout write SetLayout;
    property NumGlyphs: Integer read GetNumGlyphs write SetNumGlyphs;
    property Spacing: Integer read GetSpacing write SetSpacing;
  end;

implementation

uses RM_Utils, RM_Const, RM_EditorStrings;

{$R RM_DialogCtls.RES}
{$R RM_LNG4.RES}

type
  THackControl = class(TControl)
  end;

  {-----------------------------------------------------------------------------}
  {-----------------------------------------------------------------------------}
  { TRMCustomControl }

constructor TRMCustomControl.Create;
begin
  inherited Create;
end;

function TRMCustomControl.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'CONTROL' then
  begin
    aValue := O2V(FControl);
  end
  else if aPropName = 'BUTTONCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'LABELCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'EDITCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'MEMOCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'CHECKBOXCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'RADIOBUTTONXCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'LISTBOXCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'COMBOBOXCTL' then
    aValue := O2V(FControl)
  else if aPropName = 'DATEEDITCTL' then
    aValue := O2V(FControl)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMCustomControl.LoadFromStream(aStream: TStream);
var
  lVersion: Integer;
begin
  inherited LoadFromStream(aStream);
  lVersion := RMReadWord(aStream);
  Color := RMReadInt32(aStream);
  Enabled := RMReadBoolean(aStream);
  RMReadFont(aStream, Font);
  TabOrder := RMReadInt32(aStream);
  if lVersion >=5 then
  begin
    ShowHint := RMReadBoolean(aStream);
    Hint := RMReadString(aStream);
  end;
end;

procedure TRMCustomControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 5);
  RMWriteInt32(aStream, Color);
  RMWriteBoolean(aStream, Enabled);
  RMWriteFont(aStream, Font);
  RMWriteInt32(aStream, TabOrder);
  RMWriteBoolean(aStream, ShowHint);
  RMWriteString(aStream, Hint);
end;

procedure TRMCustomControl.ShowEditor;
begin
end;

procedure TRMCustomControl.AssignControl(AControl: TControl);
begin
  FControl := AControl;
end;

function TRMCustomControl.GetFont: TFont;
begin
  Result := THackControl(FControl).Font;
end;

procedure TRMCustomControl.SetFont(Value: TFont);
begin
  THackControl(FControl).Font.Assign(Value);
end;

function TRMCustomControl.GetColor: TColor;
begin
  Result := THackControl(FControl).Color;
end;

procedure TRMCustomControl.SetColor(Value: TColor);
begin
  THackControl(FControl).Color := Value;
end;

function TRMCustomControl.GetEnabled: Boolean;
begin
  Result := FControl.Enabled;
end;

procedure TRMCustomControl.SetEnabled(Value: Boolean);
begin
  FControl.Enabled := Value;
end;

function TRMCustomControl.GetShowHint: Boolean;
begin
  Result := FControl.ShowHint;
end;

procedure TRMCustomControl.SetShowHint(Value: Boolean);
begin
  FControl.ShowHint := Value;
end;

function TRMCustomControl.GetHint: string;
begin
  Result := FControl.Hint;
end;

procedure TRMCustomControl.SetHint(Value: string);
begin
  FControl.Hint := Value;
end;

function TRMCustomControl.GetOnClickEvent: TNotifyEvent;
begin
  Result := THackControl(FControl).OnClick;
end;

procedure TRMCustomControl.SetOnClickEvent(Value: TNotifyEvent);
begin
  THackControl(FControl).OnClick := Value;
end;

function TRMCustomControl.GetOnDblClickEvent: TNotifyEvent;
begin
  Result := THackControl(FControl).OnDblClick;
end;

procedure TRMCustomControl.SetOnDblClickEvent(Value: TNotifyEvent);
begin
  THackControl(FControl).OnDblClick := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMLabelControl }

class procedure TRMLabelControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 65;
  aKy := 17;
end;

constructor TRMLabelControl.Create;
begin
  inherited Create;
  BaseName := 'Label';

  FLabel := TLabel.Create(nil);
  FLabel.Parent := RMDialogForm;
  FLabel.Caption := 'Label';
  AssignControl(FLabel);
end;

destructor TRMLabelControl.Destroy;
begin
  FreeAndNil(FLabel);
  inherited Destroy;
end;

procedure TRMLabelControl.Draw(aCanvas: TCanvas);
begin
  BeginDraw(aCanvas);
  if AutoSize then
  begin
    spWidth := FLabel.Width;
    spHeight := FLabel.Height;
  end
  else
  begin
    FLabel.Width := spWidth;
    FLabel.Height := spHeight;
  end;
  CalcGaps;
  PaintDesignControl;
  RestoreCoord;
end;

procedure TRMLabelControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Alignment := TAlignment(RMReadByte(aStream));
  AutoSize := RMReadBoolean(aStream);
  Caption := RMReadString(aStream);
  WordWrap := RMReadBoolean(aStream);
end;

procedure TRMLabelControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(Alignment));
  RMWriteBoolean(aStream, AutoSize);
  RMWriteString(aStream, Caption);
  RMWriteBoolean(aStream, WordWrap);
end;

function TRMLabelControl.GetCaption: string;
begin
  Result := FLabel.Caption;
end;

procedure TRMLabelControl.SetCaption(Value: string);
begin
  FLabel.Caption := Value;
end;

function TRMLabelControl.GetAutoSize: Boolean;
begin
  Result := FLabel.AutoSize;
end;

procedure TRMLabelControl.SetAutoSize(Value: Boolean);
begin
  FLabel.AutoSize := Value;
end;

function TRMLabelControl.GetAlignment: TAlignment;
begin
  Result := FLabel.Alignment;
end;

procedure TRMLabelControl.SetAlignment(Value: TAlignment);
begin
  FLabel.Alignment := Value;
end;

function TRMLabelControl.GetWordwrap: Boolean;
begin
  Result := FLabel.Wordwrap;
end;

procedure TRMLabelControl.SetWordwrap(Value: Boolean);
begin
  FLabel.Wordwrap := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMEditControl }

class procedure TRMEditControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 121;
  aKy := 21;
end;

constructor TRMEditControl.Create;
begin
  inherited Create;
  BaseName := 'Edit';

  FEdit := TEdit.Create(nil);
  FEdit.Parent := RMDialogForm;
  FEdit.Text := 'Edit';
  AssignControl(FEdit);
end;

destructor TRMEditControl.Destroy;
begin
  FreeAndNil(FEdit);
  inherited Destroy;
end;

procedure TRMEditControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Text := RMReadString(aStream);
  ReadOnly := RMReadBoolean(aStream);
end;

procedure TRMEditControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Text);
  RMWriteBoolean(aStream, ReadOnly);
end;

function TRMEditControl.GetText: string;
begin
  Result := FEdit.Text;
end;

procedure TRMEditControl.SetText(Value: string);
begin
  FEdit.Text := Value;
end;

function TRMEditControl.GetReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

procedure TRMEditControl.SetReadOnly(Value: Boolean);
begin
  FEdit.ReadOnly := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMMaskEditControl }

class procedure TRMMaskEditControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 121;
  aKy := 21;
end;

constructor TRMMaskEditControl.Create;
begin
  inherited Create;
  BaseName := 'MaskEdit';

  FEdit := TMaskEdit.Create(nil);
  FEdit.Parent := RMDialogForm;
  FEdit.Text := 'MaskEdit';
  AssignControl(FEdit);
end;

destructor TRMMaskEditControl.Destroy;
begin
  FreeAndNil(FEdit);
  inherited Destroy;
end;

procedure TRMMaskEditControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Text := RMReadString(aStream);
  ReadOnly := RMReadBoolean(aStream);
end;

procedure TRMMaskEditControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Text);
  RMWriteBoolean(aStream, ReadOnly);
end;

function TRMMaskEditControl.GetEditMask: string;
begin
  Result := FEdit.EditMask;
end;

procedure TRMMaskEditControl.SetEditMask(Value: string);
begin
  FEdit.EditMask := Value;
end;

function TRMMaskEditControl.GetText: string;
begin
  Result := FEdit.Text;
end;

procedure TRMMaskEditControl.SetText(Value: string);
begin
  FEdit.Text := Value;
end;

function TRMMaskEditControl.GetReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

procedure TRMMaskEditControl.SetReadOnly(Value: Boolean);
begin
  FEdit.ReadOnly := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMMemoControl }

class procedure TRMMemoControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 185;
  aKy := 89;
end;

constructor TRMMemoControl.Create;
begin
  inherited Create;
  BaseName := 'Memo';

  FMemo := TMemo.Create(nil);
  FMemo.Parent := RMDialogForm;
  FMemo.Text := 'Memo';
  AssignControl(FMemo);
end;

destructor TRMMemoControl.Destroy;
begin
  FreeAndNil(FMemo);
  inherited Destroy;
end;

procedure TRMMemoControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  FMemo.Text := RMReadString(aStream);
  FMemo.ReadOnly := RMReadBoolean(aStream);
end;

procedure TRMMemoControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, FMemo.Text);
  RMWriteBoolean(aStream, FMemo.ReadOnly);
end;

function TRMMemoControl.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

procedure TRMMemoControl.SetLines(Value: TStrings);
begin
  FMemo.Lines.Assign(Value);
end;

function TRMMemoControl.GetReadOnly: Boolean;
begin
  Result := FMemo.ReadOnly;
end;

procedure TRMMemoControl.SetReadOnly(Value: Boolean);
begin
  FMemo.ReadOnly := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMButtonControl }

class procedure TRMButtonControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 75;
  aKy := 25;
end;

constructor TRMButtonControl.Create;
begin
  inherited Create;
  BaseName := 'Button';

  FButton := TButton.Create(nil);
  FButton.Parent := RMDialogForm;
  FButton.Caption := 'Button';
  AssignControl(FButton);
end;

destructor TRMButtonControl.Destroy;
begin
  FreeAndNil(FButton);
  inherited Destroy;
end;

procedure TRMButtonControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Caption := RMReadString(aStream);
  ModalResult := RMReadWord(aStream);
  Cancel := RMReadBoolean(aStream);
  Default := RMReadBoolean(aStream);
end;

procedure TRMButtonControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Caption);
  RMWriteWord(aStream, ModalResult);
  RMWriteBoolean(aStream, Cancel);
  RMWriteBoolean(aStream, Default);
end;

function TRMButtonControl.GetCaption: string;
begin
  Result := FButton.Caption;
end;

procedure TRMButtonControl.SetCaption(Value: string);
begin
  FButton.Caption := Value;
end;

function TRMButtonControl.GetCancel: Boolean;
begin
  Result := FButton.Cancel;
end;

procedure TRMButtonControl.SetCancel(Value: Boolean);
begin
  FButton.Cancel := Value;
end;

function TRMButtonControl.GetDefault: Boolean;
begin
  Result := FButton.Default;
end;

procedure TRMButtonControl.SetDefault(Value: Boolean);
begin
  FButton.Default := Value;
end;

function TRMButtonControl.GetModalResult: TModalResult;
begin
  Result := FButton.ModalResult;
end;

procedure TRMButtonControl.SetModalResult(Value: TModalResult);
begin
  FButton.ModalResult := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMCheckBoxControl }

class procedure TRMCheckBoxControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 97;
  aKy := 17;
end;

constructor TRMCheckBoxControl.Create;
begin
  inherited Create;
  BaseName := 'CheckBox';

  FCheckBox := TCheckBox.Create(nil);
  FCheckBox.Parent := RMDialogForm;
  FCheckBox.Caption := 'CheckBox';
  AssignControl(FCheckBox);
end;

destructor TRMCheckBoxControl.Destroy;
begin
  FreeAndNil(FCheckBox);
  inherited Destroy;
end;

procedure TRMCheckBoxControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Alignment := TAlignment(RMReadByte(aStream));
  Checked := RMReadBoolean(aStream);
  Caption := RMReadString(aStream);
end;

procedure TRMCheckBoxControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(Alignment));
  RMWriteBoolean(aStream, Checked);
  RMWriteString(aStream, Caption);
end;

function TRMCheckBoxControl.GetChecked: Boolean;
begin
  Result := FCheckBox.Checked;
end;

procedure TRMCheckBoxControl.SetChecked(Value: Boolean);
begin
  FCheckBox.Checked := Value;
end;

function TRMCheckBoxControl.GetCaption: string;
begin
  Result := FCheckBox.Caption;
end;

procedure TRMCheckBoxControl.SetCaption(Value: string);
begin
  FCheckBox.Caption := Value;
end;

function TRMCheckBoxControl.GetAlignment: TAlignment;
begin
  Result := FCheckBox.Alignment;
end;

procedure TRMCheckBoxControl.SetAlignment(Value: TAlignment);
begin
  FCheckBox.Alignment := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMRadioButtonControl }

class procedure TRMRadioButtonControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 113;
  aKy := 17;
end;

constructor TRMRadioButtonControl.Create;
begin
  inherited Create;
  BaseName := 'RadioButton';

  FRadioButton := TRadioButton.Create(nil);
  FRadioButton.Parent := RMDialogForm;
  FRadioButton.Caption := 'RadioButton';
  AssignControl(FRadioButton);
end;

destructor TRMRadioButtonControl.Destroy;
begin
  FreeAndNil(FRadioButton);
  inherited Destroy;
end;

procedure TRMRadioButtonControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Alignment := TAlignment(RMReadByte(aStream));
  Checked := RMReadBoolean(aStream);
  Caption := RMReadString(aStream);
end;

procedure TRMRadioButtonControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Byte(Alignment));
  RMWriteBoolean(aStream, Checked);
  RMWriteString(aStream, Caption);
end;

function TRMRadioButtonControl.GetChecked: Boolean;
begin
  Result := FRadioButton.Checked;
end;

procedure TRMRadioButtonControl.SetChecked(Value: Boolean);
begin
  FRadioButton.Checked := Value;
end;

function TRMRadioButtonControl.GetCaption: string;
begin
  Result := FRadioButton.Caption;
end;

procedure TRMRadioButtonControl.SetCaption(Value: string);
begin
  FRadioButton.Caption := Value;
end;

function TRMRadioButtonControl.GetAlignment: TAlignment;
begin
  Result := FRadioButton.Alignment;
end;

procedure TRMRadioButtonControl.SetAlignment(Value: TAlignment);
begin
  FRadioButton.Alignment := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMListBoxControl }

class procedure TRMListBoxControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 121;
  aKy := 97;
end;

constructor TRMListBoxControl.Create;
begin
  inherited Create;
  BaseName := 'ListBox';

  FListBox := TListBox.Create(nil);
  FListBox.Parent := RMDialogForm;
  AssignControl(FListBox);
end;

destructor TRMListBoxControl.Destroy;
begin
  FreeAndNil(FListBox);
  inherited Destroy;
end;

procedure TRMListBoxControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  RMReadMemo(aStream, Items);
  ItemIndex := RMReadInt32(aStream);
end;

procedure TRMListBoxControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteMemo(aStream, Items);
  RMWriteInt32(aStream, ItemIndex);
end;

function TRMListBoxControl.GetItems: TStrings;
begin
  Result := FListBox.Items;
end;

procedure TRMListBoxControl.SetItems(Value: TStrings);
begin
  FListBox.Items.Assign(Value);
end;

function TRMListBoxControl.GetItemIndex: Integer;
begin
  Result := FListBox.ItemIndex;
end;

procedure TRMListBoxControl.SetItemIndex(Value: Integer);
begin
  FListBox.ItemIndex := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMComboBoxControl }

class procedure TRMComboBoxControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 145;
  aKy := 21;
end;

constructor TRMComboBoxControl.Create;
begin
  inherited Create;
  BaseName := 'ComboBox';

  FComboBox := TComboBox.Create(nil);
  FComboBox.Parent := RMDialogForm;
  FComboBox.OnDrawItem := ComboBoxDrawItem;
  FComboBox.OnKeyDown := OnKeyDown;
  AssignControl(FComboBox);
end;

destructor TRMComboBoxControl.Destroy;
begin
  FreeAndNil(FComboBox);
  inherited Destroy;
end;

procedure TRMComboBoxControl.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Style = rmcsLookup then
  begin
    if (Key = VK_DELETE) or (Key = VK_BACK) then
      FComboBox.ItemIndex := -1;
  end;
end;

procedure TRMComboBoxControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  RMReadMemo(aStream, Items);
  Style := TRMComboBoxStyle(RMReadByte(aStream));
  ItemIndex := RMReadInt32(aStream);
end;

procedure TRMComboBoxControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteMemo(aStream, Items);
  RMWriteByte(aStream, Byte(Style));
  RMWriteInt32(aStream, ItemIndex);
end;

procedure TRMComboBoxControl.ComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ComboBox: TComboBox;
  s: string;
begin
  ComboBox := Control as TComboBox;
  with ComboBox.Canvas do
  begin
    FillRect(Rect);
    s := ComboBox.Items[Index];
    if Pos(';', s) <> 0 then
      s := Copy(s, 1, Pos(';', s) - 1);
    TextOut(Rect.Left + 2, Rect.Top + 1, s);
  end;
end;

function TRMComboBoxControl.GetItems: TStrings;
begin
  Result := FComboBox.Items;
end;

procedure TRMComboBoxControl.SetItems(Value: TStrings);
begin
  FComboBox.Items.Assign(Value);
end;

function TRMComboBoxControl.GetItemIndex: Integer;
begin
  Result := FComboBox.ItemIndex;
end;

procedure TRMComboBoxControl.SetItemIndex(Value: Integer);
begin
  FComboBox.ItemIndex := Value;
end;

function TRMComboBoxControl.GetText: string;
begin
  Result := FComboBox.Text;
  if (Style = rmcsLookup) and (Pos(';', Result) <> 0) then
    Result := Trim(Copy(Result, Pos(';', Result) + 1, 255));
end;

procedure TRMComboBoxControl.SetText(Value: string);
begin
  FComboBox.Text := Value;
end;

procedure TRMComboBoxControl.SetStyle(Value: TRMComboBoxStyle);
begin
  FStyle := Value;
  FComboBox.Style := TComboBoxStyle(Value);
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMDateEditControl }

class procedure TRMDateEditControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 186;
  aKy := 21;
end;

constructor TRMDateEditControl.Create;
begin
  inherited Create;
  BaseName := 'DateEdit';

  FDateEdit := TDateTimePicker.Create(nil);
  FDateEdit.Parent := RMDialogForm;
  AssignControl(FDateEdit);
end;

destructor TRMDateEditControl.Destroy;
begin
  FreeAndNil(FDateEdit);
  inherited Destroy;
end;

procedure TRMDateEditControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Date := RMReadFloat(aStream);
  Time := RMReadFloat(aStream);
  DateFormat := TDTDateFormat(RMReadByte(aStream));
  Kind := TDateTimeKind(RMReadByte(aStream));
end;

procedure TRMDateEditControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteFloat(aStream, Date);
  RMWriteFloat(aStream, Time);
  RMWriteByte(aStream, Byte(DateFormat));
  RMWriteByte(aStream, Byte(Kind));
end;

function TRMDateEditControl.GetDate: TDate;
begin
  Result := FDateEdit.Date;
end;

procedure TRMDateEditControl.SetDate(Value: TDate);
begin
  FDateEdit.Date := Value;
end;

function TRMDateEditControl.GetTime: TTime;
begin
  Result := FDateEdit.Time;
end;

procedure TRMDateEditControl.SetTime(Value: TTime);
begin
  FDateEdit.Time := Value;
end;

function TRMDateEditControl.GetDateFormat: TDTDateFormat;
begin
  Result := FDateEdit.DateFormat;
end;

procedure TRMDateEditControl.SetDateFormat(Value: TDTDateFormat);
begin
  FDateEdit.DateFormat := Value;
end;

function TRMDateEditControl.GetKind: TDateTimeKind;
begin
  Result := FDateEdit.Kind;
end;

procedure TRMDateEditControl.SetKind(Value: TDateTimeKind);
begin
  FDateEdit.Kind := Value;
end;

{$IFDEF JVCLCTLS}
{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMRXDateEditControl }

class procedure TRMRXDateEditControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 121;
  aKy := 21;
end;

constructor TRMRXDateEditControl.Create;
begin
  inherited Create;
  BaseName := 'RxDateEdit';

  FDateEdit := TJvDateEdit.Create(nil);
  FDateEdit.Parent := RMDialogForm;
  FDateEdit.ButtonWidth := 19;
  AssignControl(FDateEdit);
end;

destructor TRMRXDateEditControl.Destroy;
begin
  FreeAndNil(FDateEdit);
  inherited Destroy;
end;

function TRMRXDateEditControl.GetPropValue(aObject: TObject; aPropName: string;
  var aValue: Variant; Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'DATE' then
    aValue := FDateEdit.Date
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

function TRMRXDateEditControl.SetPropValue(aObject: TObject; aPropName: string;
  aValue: Variant): Boolean;
begin
  Result := True;
  if aPropName = 'DATE' then
    FDateEdit.Date := aValue
  else
    Result := inherited SetPropValue(aObject, aPropName, aValue);
end;

procedure TRMRXDateEditControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Text := RMReadString(aStream);
  DialogTitle := RMReadString(aStream);
  StartOfWeek := TDayOfWeekName(RMReadByte(aStream));
  YearDigits := TYearDigits(RMReadByte(aStream));
  ClickKey := TShortCut(RMReadByte(aStream));
  CalendarStyle := TCalendarStyle(RMReadByte(aStream));
  DefaultToday := RMReadBoolean(aStream);
end;

procedure TRMRXDateEditControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Text);
  RMWriteString(aStream, DialogTitle);
  RMWriteByte(aStream, Byte(StartOfWeek));
  RMWriteByte(aStream, Byte(YearDigits));
  RMWriteByte(aStream, Byte(ClickKey));
  RMWriteByte(aStream, Byte(CalendarStyle));
  RMWriteBoolean(astream, DefaultToday);
end;

function TRMRXDateEditControl.GetText: string;
begin
  Result := FDateEdit.Text;
end;

procedure TRMRXDateEditControl.SetText(Value: string);
begin
  FDateEdit.Text := Value;
end;

function TRMRXDateEditControl.GetDialogTitle: string;
begin
  Result := FDateEdit.DialogTitle;
end;

procedure TRMRXDateEditControl.SetDialogTitle(Value: string);
begin
  FDateEdit.DialogTitle := Value;
end;

function TRMRXDateEditControl.GetStartOfWeek: TDayOfWeekName;
begin
  Result := FDateEdit.StartOfWeek;
end;

procedure TRMRXDateEditControl.SetStartOfWeek(Value: TDayOfWeekName);
begin
  FDateEdit.StartOfWeek := Value;
end;

function TRMRXDateEditControl.GetYearDigits: TYearDigits;
begin
  Result := FDateEdit.YearDigits;
end;

procedure TRMRXDateEditControl.SetYearDigits(Value: TYearDigits);
begin
  FDateEdit.YearDigits := Value;
end;

function TRMRXDateEditControl.GetClickKey: TShortCut;
begin
  Result := FDateEdit.ClickKey;
end;

procedure TRMRXDateEditControl.SetClickKey(Value: TShortCut);
begin
  FDateEdit.ClickKey := Value;
end;

function TRMRXDateEditControl.GetCalendarStyle: TCalendarStyle;
begin
  Result := FDateEdit.CalendarStyle;
end;

procedure TRMRXDateEditControl.SetCalendarStyle(Value: TCalendarStyle);
begin
  FDateEdit.CalendarStyle := Value;
end;

function TRMRXDateEditControl.GetDefaultToday: Boolean;
begin
  Result := FDateEdit.DefaultToday;
end;

procedure TRMRXDateEditControl.SetDefaultToday(Value: Boolean);
begin
  FDateEdit.DefaultToday := Value;
end;
{$ENDIF}

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMCheckListBox }

class procedure TRMCheckListBoxControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 121;
  aKy := 97;
end;

constructor TRMCheckListBoxControl.Create;
begin
  inherited Create;
  BaseName := 'CheckListBox';

  FCheckListBox := TCheckListBox.Create(nil);
  FCheckListBox.Parent := RMDialogForm;

  AssignControl(FCheckListBox);
end;

destructor TRMCheckListBoxControl.Destroy;
begin
  FreeAndNil(FCheckListBox);
  inherited Destroy;
end;

function TRMCheckListBoxControl.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'CHECKLISTBOX' then
    aValue := O2V(FCheckListBox)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMCheckListBoxControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  RMReadMemo(aStream, Items);
  ItemIndex := RMReadInt32(aStream);
end;

procedure TRMCheckListBoxControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteMemo(aStream, Items);
  RMWriteInt32(aStream, ItemIndex);
end;

function TRMCheckListBoxControl.GetItems: TStrings;
begin
  Result := FCheckListBox.Items;
end;

procedure TRMCheckListBoxControl.SetItems(Value: TStrings);
begin
  FCheckListBox.Items.Assign(Value);
end;

function TRMCheckListBoxControl.GetItemIndex: Integer;
begin
  Result := FCheckListBox.ItemIndex;
end;

procedure TRMCheckListBoxControl.SetItemIndex(Value: Integer);
begin
  FCheckListBox.ItemIndex := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMPanelControl }

class procedure TRMPanelControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 185;
  aKy := 41;
end;

constructor TRMPanelControl.Create;
begin
  inherited Create;
  BaseName := 'Panel';

  FPanel := TPanel.Create(nil);
  FPanel.Parent := RMDialogForm;

  AssignControl(FPanel);
end;

destructor TRMPanelControl.Destroy;
begin
  FreeChildViews;
  FreeAndNil(FPanel);
  inherited Destroy;
end;

function TRMPanelControl.IsContainer: Boolean;
begin
  Result := True;
end;

function TRMPanelControl.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'PANEL' then
    aValue := O2V(FPanel)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMPanelControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  BevelInner := TPanelBevel(RMReadByte(aStream));
  BevelOuter := TPanelBevel(RMReadByte(aStream));
  BevelWidth := RMReadInt32(aStream);
  BorderStyle := TBorderStyle(RMReadByte(aStream));
  BorderWidth := RMReadInt32(aStream);
  Caption := RMReadString(aStream);
end;

procedure TRMPanelControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteByte(aStream, Integer(BevelInner));
  RMWriteByte(aStream, Integer(BevelOuter));
  RMWriteInt32(aStream, BevelWidth);
  RMWriteByte(aStream, Integer(BorderStyle));
  RMWriteInt32(aStream, BorderWidth);
  RMWriteString(aStream, Caption);
end;

function TRMPanelControl.GetBevelInner: TPanelBevel;
begin
  Result := FPanel.BevelInner;
end;

procedure TRMPanelControl.SetBevelInner(Value: TPanelBevel);
begin
  FPanel.BevelInner := Value;
end;

function TRMPanelControl.GetBevelOuter: TPanelBevel;
begin
  Result := FPanel.BevelOuter;
end;

procedure TRMPanelControl.SetBevelOuter(Value: TPanelBevel);
begin
  FPanel.BevelOuter := Value;
end;

function TRMPanelControl.GetBevelWidth: Integer;
begin
  Result := FPanel.BevelWidth;
end;

procedure TRMPanelControl.SetBevelWidth(Value: Integer);
begin
  FPanel.BevelWidth := Value;
end;

function TRMPanelControl.GetBorderStyle: TBorderStyle;
begin
  Result := FPanel.BorderStyle;
end;

procedure TRMPanelControl.SetBorderStyle(Value: TBorderStyle);
begin
  FPanel.BorderStyle := Value;
end;

function TRMPanelControl.GetBorderWidth: Integer;
begin
  Result := FPanel.BorderWidth;
end;

procedure TRMPanelControl.SetBorderWidth(Value: Integer);
begin
  FPanel.BorderWidth := Value;
end;

function TRMPanelControl.GetCaption: string;
begin
  Result := FPanel.Caption;
end;

procedure TRMPanelControl.SetCaption(Value: string);
begin
  FPanel.Caption := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMGroupBoxControl }

class procedure TRMGroupBoxControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 185;
  aKy := 105;
end;

constructor TRMGroupBoxControl.Create;
begin
  inherited Create;
  BaseName := 'GroupBox';

  FGroupBox := TGroupBox.Create(nil);
  FGroupBox.Parent := RMDialogForm;

  AssignControl(FGroupBox);
end;

destructor TRMGroupBoxControl.Destroy;
begin
  FreeChildViews;
  FreeAndNil(FGroupBox);
  inherited Destroy;
end;

function TRMGroupBoxControl.IsContainer: Boolean;
begin
  Result := True;
end;

function TRMGroupBoxControl.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'GROUPBOX' then
    aValue := O2V(FGroupBox)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMGroupBoxControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Caption := RMReadString(aStream);
end;

procedure TRMGroupBoxControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Caption);
end;

function TRMGroupBoxControl.GetCaption: string;
begin
  Result := FGroupBox.Caption;
end;

procedure TRMGroupBoxControl.SetCaption(Value: string);
begin
  FGroupBox.Caption := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMImageControl }

class procedure TRMImageControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 105;
  aKy := 105;
end;

constructor TRMImageControl.Create;
begin
  inherited Create;
  BaseName := 'Image';

  FImage := TImage.Create(nil);
  FImage.Parent := RMDialogForm;

  AssignControl(FImage);
end;

destructor TRMImageControl.Destroy;
begin
  FreeAndNil(FImage);
  inherited Destroy;
end;

function TRMImageControl.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'IMAGE' then
    aValue := O2V(FImage)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMImageControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  AutoSize := RMReadBoolean(aStream);
  Center := RMReadBoolean(aStream);
  Stretch := RMReadBoolean(aStream);
  Transparent := RMReadBoolean(aStream);
  RMLoadPicture(aStream, Picture);
end;

procedure TRMImageControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteBoolean(aStream, AutoSize);
  RMWriteBoolean(aStream, Center);
  RMWriteBoolean(aStream, Stretch);
  RMWriteBoolean(aStream, Transparent);
  RMWritePicture(aStream, Picture);
end;

function TRMImageControl.GetPicture: TPicture;
begin
  Result := FImage.Picture;
end;

procedure TRMImageControl.SetPicture(Value: TPicture);
begin
  FImage.Picture.Assign(Value);
end;

function TRMImageControl.GetAutoSize(Index: Integer): Boolean;
begin
  case Index of
    0: Result := FImage.AutoSize;
    1: Result := FImage.Center;
    2: Result := FImage.Stretch;
    4: Result := FImage.Transparent;
  else
    Result := False;
  end;
end;

procedure TRMImageControl.SetAutoSize(Index: Integer; Value: Boolean);
begin
  case Index of
    0: FImage.AutoSize := Value;
    1: FImage.Center := Value;
    2: FImage.Stretch := Value;
    4: FImage.Transparent := Value;
  end;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{ TRMBevelControl }

class procedure TRMBevelControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 50;
  aKy := 50;
end;

constructor TRMBevelControl.Create;
begin
  inherited Create;
  BaseName := 'Bevel';

  FBevel := TBevel.Create(nil);
  FBevel.Parent := RMDialogForm;

  AssignControl(FBevel);
end;

destructor TRMBevelControl.Destroy;
begin
  FreeAndNil(FBevel);
  inherited Destroy;
end;

function TRMBevelControl.GetPropValue(aObject: TObject; aPropName: string; var aValue: Variant;
  Args: array of Variant): Boolean;
begin
  Result := True;
  if aPropName = 'BEVEL' then
    aValue := O2V(FBevel)
  else
    Result := inherited GetPropValue(aObject, aPropName, aValue, Args);
end;

procedure TRMBevelControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
end;

procedure TRMBevelControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMSpeedButtonControl }

class procedure TRMSpeedButtonControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 23;
  aKy := 22;
end;

constructor TRMSpeedButtonControl.Create;
begin
  inherited Create;
  BaseName := 'SpeedButton';

  FSpeedButton := TSpeedButton.Create(nil);
  FSpeedButton.Parent := RMDialogForm;
  AssignControl(FSpeedButton);
end;

destructor TRMSpeedButtonControl.Destroy;
begin
  FreeAndNil(FSpeedButton);
  inherited Destroy;
end;

procedure TRMSpeedButtonControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Caption := RMReadString(aStream);
end;

procedure TRMSpeedButtonControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Caption);
end;

function TRMSpeedButtonControl.GetCaption: string;
begin
  Result := FSpeedButton.Caption;
end;

procedure TRMSpeedButtonControl.SetCaption(Value: string);
begin
  FSpeedButton.Caption := Value;
end;

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ TRMBitBtnControl }

class procedure TRMBitBtnControl.DefaultSize(var aKx, aKy: Integer);
begin
  aKx := 75;
  aKy := 25;
end;

constructor TRMBitBtnControl.Create;
begin
  inherited Create;
  BaseName := 'BitBtn';

  FBitBtn := TBitBtn.Create(nil);
  FBitBtn.Parent := RMDialogForm;
  FBitBtn.Caption := 'Button';
  AssignControl(FBitBtn);
end;

destructor TRMBitBtnControl.Destroy;
begin
  FreeAndNil(FBitBtn);
  inherited Destroy;
end;

procedure TRMBitBtnControl.LoadFromStream(aStream: TStream);
begin
  inherited LoadFromStream(aStream);
  RMReadWord(aStream);
  Caption := RMReadString(aStream);
  ModalResult := RMReadWord(aStream);
  Cancel := RMReadBoolean(aStream);
  Default := RMReadBoolean(aStream);
  Kind := TBitBtnKind(RMReadByte(aStream));
  Layout := TButtonLayout(RMReadByte(aStream));
  NumGlyphs := RMReadInt32(aStream);
  Spacing := RMReadInt32(aStream);
  RMLoadBitmap(aStream, Glyph);
end;

procedure TRMBitBtnControl.SaveToStream(aStream: TStream);
begin
  inherited SaveToStream(aStream);
  RMWriteWord(aStream, 0);
  RMWriteString(aStream, Caption);
  RMWriteWord(aStream, ModalResult);
  RMWriteBoolean(aStream, Cancel);
  RMWriteBoolean(aStream, Default);
  RMWriteByte(aStream, Byte(Kind));
  RMWriteByte(aStream, Byte(Layout));
  RMWriteInt32(aStream, NumGlyphs);
  RMWriteInt32(aStream, Spacing);
  RMSaveBitmap(aStream, Glyph);
end;

function TRMBitBtnControl.GetCaption: string;
begin
  Result := FBitBtn.Caption;
end;

procedure TRMBitBtnControl.SetCaption(Value: string);
begin
  FBitBtn.Caption := Value;
end;

function TRMBitBtnControl.GetCancel: Boolean;
begin
  Result := FBitBtn.Cancel;
end;

procedure TRMBitBtnControl.SetCancel(Value: Boolean);
begin
  FBitBtn.Cancel := Value;
end;

function TRMBitBtnControl.GetDefault: Boolean;
begin
  Result := FBitBtn.Default;
end;

procedure TRMBitBtnControl.SetDefault(Value: Boolean);
begin
  FBitBtn.Default := Value;
end;

function TRMBitBtnControl.GetModalResult: TModalResult;
begin
  Result := FBitBtn.ModalResult;
end;

procedure TRMBitBtnControl.SetModalResult(Value: TModalResult);
begin
  FBitBtn.ModalResult := Value;
end;

function TRMBitBtnControl.GetGlyph: TBitmap;
begin
  Result := FBitBtn.Glyph;
end;

procedure TRMBitBtnControl.SetGlyph(Value: TBitmap);
begin
  FBitBtn.Glyph.Assign(Value);
end;

function TRMBitBtnControl.GetKind: TBitBtnKind;
begin
  Result := FBitBtn.Kind;
end;

procedure TRMBitBtnControl.SetKind(Value: TBitBtnKind);
begin
  FBitBtn.Kind := Value;
end;

function TRMBitBtnControl.GetLayout: TButtonLayout;
begin
  Result := FBitBtn.Layout;
end;

procedure TRMBitBtnControl.SetLayout(Value: TButtonLayout);
begin
  FBitBtn.Layout := Value;
end;

function TRMBitBtnControl.GetNumGlyphs: Integer;
begin
  Result := FBitBtn.NumGlyphs;
end;

procedure TRMBitBtnControl.SetNumGlyphs(Value: Integer);
begin
  FBitBtn.NumGlyphs := Value;
end;

function TRMBitBtnControl.GetSpacing: Integer;
begin
  Result := FBitBtn.Spacing;
end;

procedure TRMBitBtnControl.SetSpacing(Value: Integer);
begin
  FBitBtn.Spacing := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TRMCheckListBox_Read_Checked(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TRMCheckListBoxControl(Args.Obj).CheckListBox.Checked[Args.Values[0]];
end;

procedure TRMCheckListBox_Write_Checked(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TRMCheckListBoxControl(Args.Obj).CheckListBox.Checked[Args.Values[0]] := Value;
end;

procedure TCheckListBox_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(TCheckListBox.Create(V2O(Args.Values[0]) as TComponent));
end;

procedure TCheckListBox_Read_Checked(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := TCheckListBox(Args.Obj).Checked[Args.Values[0]];
end;

procedure TCheckListBox_Write_Checked(const Value: Variant; Args: TJvInterpreterArgs);
begin
  TCheckListBox(Args.Obj).Checked[Args.Values[0]] := Value;
end;

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

const
	cReportMachine = 'RM_DialogCtls';

procedure RM_RegisterRAI2Adapter(RAI2Adapter: TJvInterpreterAdapter);
begin
  with RAI2Adapter do
  begin
    AddClass('CheckLst', TCheckListBox, 'TCheckListBox');
    AddGet(TCheckListBox, 'Create', TCheckListBox_Create, 1, [varEmpty], varEmpty);
    AddIGet(TCheckListBox, 'Checked', TCheckListBox_Read_Checked, 1, [0], varEmpty);
    AddISet(TCheckListBox, 'Checked', TCheckListBox_Write_Checked, 1, [1]);

    AddClass(cReportMachine, TRMCustomControl, 'TRMCustomControl');
    AddClass(cReportMachine, TRMLabelControl, 'TRMLabelControl');
    AddClass(cReportMachine, TRMEditControl, 'TRMEditControl');
    AddClass(cReportMachine, TRMMemoControl, 'TRMMemoControl');
    AddClass(cReportMachine, TRMButtonControl, 'TRMButtonControl');
    AddClass(cReportMachine, TRMCheckBoxControl, 'TRMCheckBoxControl');
    AddClass(cReportMachine, TRMRadioButtonControl, 'TRMRadioButtonControl');
    AddClass(cReportMachine, TRMListBoxControl, 'TRMListBoxControl');
    AddClass(cReportMachine, TRMDateEditControl, 'TRMDateEditControl');
    {$IFDEF JVCLCTLS}
    AddClass(cReportMachine, TRMRXDateEditControl, 'TRMRXDateEditControl');
    {$ENDIF}
    AddClass(cReportMachine, TRMCheckListBoxControl, 'TRMCheckListBoxControl');
    AddClass(cReportMachine, TRMPanelControl, 'TRMPanelControl');
    AddClass(cReportMachine, TRMGroupBoxControl, 'TRMGroupBoxControl');
    AddClass(cReportMachine, TRMImageControl, 'TRMImageControl');
    AddClass(cReportMachine, TRMBevelControl, 'TRMBevelControl');
    AddClass(cReportMachine, TRMSpeedButtonControl, 'TRMSpeedButtonControl');
    AddClass(cReportMachine, TRMBitBtnControl, 'TRMBitBtnControl');

    AddIGet(TRMCheckListBoxControl, 'Checked', TRMCheckListBox_Read_Checked, 1, [0], varEmpty);
    AddISet(TRMCheckListBoxControl, 'Checked', TRMCheckListBox_Write_Checked, 1, [1]);
  end;

  RegisterClasses([TCheckListBox]);
end;

initialization
  RMRegisterControl(TRMLabelControl, 'RM_LABELCONTROL', RMLoadStr(SInsertLabel));
  RMRegisterControl(TRMEditControl, 'RM_EDITCONTROL', RMLoadStr(SInsertEdit));
  //  RMRegisterControl(TRMMaskEditControl, 'RM_MASKEDITCONTROL', RMLoadStr(SInsertEdit));
  RMRegisterControl(TRMMemoControl, 'RM_MEMOCONTROL', RMLoadStr(SInsertMemo));
  RMRegisterControl(TRMButtonControl, 'RM_BUTTONCONTROL', RMLoadStr(SInsertButton));
  RMRegisterControl(TRMCheckBoxControl, 'RM_CHECKBOXCONTROL', RMLoadStr(SInsertCheckBox));
  RMRegisterControl(TRMRadioButtonControl, 'RM_RADIOBUTTONCONTROL', RMLoadStr(SInsertRadioButton));
  RMRegisterControl(TRMListBoxControl, 'RM_LISTBOXCONTROL', RMLoadStr(SInsertListBox));
  RMRegisterControl(TRMComboBoxControl, 'RM_COMBOBOXCONTROL', RMLoadStr(SInsertComboBox));
  RMRegisterControl(TRMPanelControl, 'RM_PanelControl', 'Panel');
  RMRegisterControl(TRMGroupBoxControl, 'RM_GroupBoxControl', 'GroupBox');
  {$IFDEF JVCLCTLS}
  //  RMRegisterControl(TRMRXDateEditControl, 'RM_RXDATEEDITCONTROL', RMLoadStr(SInsertDateEdit));
  {$ENDIF}
  //  RMRegisterControl(TRMDateEditControl, 'RM_DATEEDITCONTROL', RMLoadStr(SInsertDateEdit));
  //  RMRegisterControl(TRMCheckListBoxControl, 'RM_CHECKLISTBOXCONTROL', RMLoadStr(SInsertCheckListBox));
  RMRegisterControls('DialogPage Additional', 'RM_OtherComponent', True,
    [TRMMaskEditControl, TRMCheckListBoxControl, TRMDateEditControl, TRMImageControl,
    TRMBevelControl, TRMSpeedButtonControl, TRMBitBtnControl
      {$IFDEF JVCLCTLS}, TRMRXDateEditControl{$ENDIF}],
    ['RM_MASKEDITCONTROL', 'RM_CHECKLISTBOXCONTROL', 'RM_DATEEDITCONTROL', 'RM_IMAGECONTROL',
    'RM_BevelControl', 'RM_SpeedButtonControl', 'RM_BitbtnControl'
      {$IFDEF JVCLCTLS}, 'RM_RXDATEEDITCONTROL'{$ENDIF}],
    ['MaskEdit', RMLoadStr(SInsertCheckListBox), RMLoadStr(SInsertDateEdit), 'Image',
    'Bevel', 'SpeedButton', 'BitBtn'
      {$IFDEF JVCLCTLS}, RMLoadStr(SInsertDateEdit){$ENDIF}]);

  RM_RegisterRAI2Adapter(GlobalJvInterpreterAdapter);
{$IFDEF USE_INTERNAL_JVCL}
  rm_JvInterpreter_StdCtrls.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
  rm_JvInterpreter_Controls.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
{$ELSE}
  JvInterpreter_StdCtrls.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
  JvInterpreter_Controls.RegisterJvInterpreterAdapter(GlobalJvInterpreterAdapter);
{$ENDIF}

finalization

end.

