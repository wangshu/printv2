
{*****************************************}
{                                         }
{          Report Machine v2.0            }
{             Designer options            }
{                                         }
{*****************************************}

unit RM_DesignerOptions;

interface

{$I RM.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, RM_common, RM_DsgCtrls;

type
  TRMDesOptionsForm = class(TForm)
    PageControl1: TPageControl;
    Tab1: TTabSheet;
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    GroupBox3: TGroupBox;
    RB6: TRadioButton;
    RB7: TRadioButton;
    RB8: TRadioButton;
    GroupBox4: TGroupBox;
    RB1: TRadioButton;
    RB2: TRadioButton;
    RB3: TRadioButton;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox5: TGroupBox;
    CB5: TCheckBox;
    CB7: TCheckBox;
    chkAutoOpenLastFile: TCheckBox;
    Tab2: TTabSheet;
    GroupBox2: TGroupBox;
    btnWorkSpaceColor: TButton;
    pnbWorkSpace: TPaintBox;
    btnInspColor: TButton;
    pnbInsp: TPaintBox;
    ColorDialog1: TColorDialog;
    RB9: TRadioButton;
    chkAutoChangeBandPos: TCheckBox;
    chkShowDropDownField: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnWorkSpaceColorClick(Sender: TObject);
    procedure pnbWorkSpacePaint(Sender: TObject);
    procedure pnbInspPaint(Sender: TObject);
    procedure btnInspColorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    WorkSpaceColor, InspColor: TColor;
  end;


implementation

{$R *.DFM}

uses Registry, RM_Class, RM_Utils, RM_Const, RM_Const1;

procedure TRMDesOptionsForm.Localize;
begin
  Font.Name := RMLoadStr(SRMDefaultFontName);
  Font.Size := StrToInt(RMLoadStr(SRMDefaultFontSize));
  Font.Charset := StrToInt(RMLoadStr(SCharset));

  RMSetStrProp(Self, 'Caption', rmRes + 280);
  RMSetStrProp(Tab1, 'Caption', rmRes + 281);
  RMSetStrProp(Tab2, 'Caption', rmRes + 297);

  RMSetStrProp(GroupBox1, 'Caption', rmRes + 282);
  RMSetStrProp(GroupBox3, 'Caption', rmRes + 284);
  RMSetStrProp(GroupBox4, 'Caption', rmRes + 285);
  RMSetStrProp(GroupBox5, 'Caption', rmRes + 297);
  RMSetStrProp(CB1, 'Caption', rmRes + 286);
  RMSetStrProp(CB2, 'Caption', rmRes + 287);
  RMSetStrProp(CB5, 'Caption', rmRes + 299);
  RMSetStrProp(CB7, 'Caption', rmRes + 311);
  RMSetStrProp(RB1, 'Caption', rmRes + 289);
  RMSetStrProp(RB2, 'Caption', rmRes + 290);
  RMSetStrProp(RB3, 'Caption', rmRes + 291);
  RMSetStrProp(RB6, 'Caption', rmRes + 294);
  RMSetStrProp(RB7, 'Caption', rmRes + 296);
  RMSetStrProp(RB8, 'Caption', rmRes + 295);
  RMSetStrProp(RB9, 'Caption', rmRes + 315);
  RMSetStrProp(chkAutoOpenLastFile, 'Caption', rmRes + 312);
  RMSetStrProp(chkAutoChangeBandPos, 'Caption', rmRes + 314);

  RMSetStrProp(GroupBox2, 'Caption', rmRes + 685);
  RMSetStrProp(btnWorkSpaceColor, 'Caption', rmRes + 313);
  RMSetStrProp(btnInspColor, 'Caption', rmRes + 70);
  RMSetStrProp(chkShowDropDownField, 'Caption', rmRes + 316);

  btnOK.Caption := RMLoadStr(SOk);
  btnCancel.Caption := RMLoadStr(SCancel);
end;

procedure TRMDesOptionsForm.FormCreate(Sender: TObject);
begin
  PageControl1.Activepage := Tab1;

  Localize;
end;

procedure TRMDesOptionsForm.btnWorkSpaceColorClick(Sender: TObject);
begin
  ColorDialog1.Color := WorkSpaceColor;
  if ColorDialog1.Execute then
  begin
    WorkSpaceColor := ColorDialog1.Color;
    pnbWorkSpacePaint(nil);
  end;
end;

procedure TRMDesOptionsForm.pnbWorkSpacePaint(Sender: TObject);
begin
  with pnbWorkSpace do
  begin
    Canvas.Brush.Color := WorkSpaceColor;
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
end;

procedure TRMDesOptionsForm.pnbInspPaint(Sender: TObject);
begin
  with pnbInsp do
  begin
    Canvas.Brush.Color := InspColor;
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
end;

procedure TRMDesOptionsForm.btnInspColorClick(Sender: TObject);
begin
  ColorDialog1.Color := InspColor;
  if ColorDialog1.Execute then
  begin
    InspColor := ColorDialog1.Color;
    pnbInspPaint(nil);
  end;
end;

procedure TRMDesOptionsForm.FormShow(Sender: TObject);
begin
    pnbWorkSpacePaint(nil);
    pnbInspPaint(nil);
end;

end.

