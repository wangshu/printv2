unit frm_printInfo_Unit;

interface

uses
      Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
      cxContainer, cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxGroupBox,
      cxRadioGroup, StdCtrls, cxDropDownEdit, cxMaskEdit, cxSpinEdit,
      cxTextEdit, NativeXml, Menus, cxButtons;

type
      Tfrm_printInfo = class(TForm)
            cxGroupBox1: TcxGroupBox;
            cxGroupBox2: TcxGroupBox;
            edt_title: TcxTextEdit;
            sedt_width: TcxSpinEdit;
            sedt_height: TcxSpinEdit;
            cb_font: TcxComboBox;
            cb_reporttype: TcxComboBox;
            Label1: TLabel;
            Label2: TLabel;
            Label3: TLabel;
            Label4: TLabel;
            Label5: TLabel;
            cxRadioGroup1: TcxRadioGroup;
            cxButton1: TcxButton;
            cxButton2: TcxButton;
            procedure FormShow(Sender: TObject);
            procedure cxButton2Click(Sender: TObject);
            procedure cxButton1Click(Sender: TObject);
      private
    { Private declarations }
            filename: string;
      public
    { Public declarations }
            node: TXmlNode;

      end;

var
      frm_printInfo: Tfrm_printInfo;

implementation

uses Symbol_Unit;



{$R *.dfm}

procedure Tfrm_printInfo.FormShow(Sender: TObject);
begin

      if (node.AttributeCount > 0) then
      begin
            edt_title.Text := node.AttributeByName[REPORT_TITLE];
            sedt_width.Text := node.AttributeByName[REPORT_WIDTH];
            sedt_height.Text := node.AttributeByName[REPORT_HEIGHT];
            cb_font.ItemIndex := cb_font.Properties.Items.IndexOf(node.AttributeByName[REPORT_FONT]);
            cb_reporttype.ItemIndex := cb_font.Properties.Items.IndexOf(node.AttributeByName[REPORT_TYPE]);
            filename := node.AttributeByName[REPORT_FILE_NAME];
      end

end;

procedure Tfrm_printInfo.cxButton2Click(Sender: TObject);
begin
      node.AttributeByName[REPORT_TITLE] := edt_title.Text;
      node.AttributeByName[REPORT_WIDTH] := sedt_width.Text;
      node.AttributeByName[REPORT_HEIGHT] := sedt_height.Text;
      node.AttributeByName[REPORT_FONT] := cb_font.Text;
      node.AttributeByName[REPORT_TYPE] := cb_reporttype.Text;
      node.AttributeByName[REPORT_FILE_NAME] := filename;
      ModalResult := mrOk;
end;

procedure Tfrm_printInfo.cxButton1Click(Sender: TObject);
begin
      ModalResult := mrCancel;
end;

end.
