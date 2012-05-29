unit frm_attribInfoUnit;

interface

uses
      Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
      cxContainer, cxEdit, dxSkinsCore, dxSkinsDefaultPainters,
      dxSkinscxPCPainter, Menus, cxSpinEdit, cxMaskEdit, cxGroupBox,
      cxRadioGroup, StdCtrls, cxMemo, cxTextEdit, cxButtons, cxPC, NativeXml;

type
      Tfrm_attribInfo = class(TForm)
            cxGroupBox1: TcxGroupBox;
            cxGroupBox2: TcxGroupBox;
            cxPageControl1: TcxPageControl;
            cxTabSheet1: TcxTabSheet;
            cxTabSheet2: TcxTabSheet;
            cxTabSheet3: TcxTabSheet;
            cxButton2: TcxButton;
            cxButton1: TcxButton;
            edt_item_name: TcxTextEdit;
            memo_enmu: TcxMemo;
            Label1: TLabel;
            rg_datetime: TcxRadioGroup;
            medt_date_max: TcxMaskEdit;
            medt_date_min: TcxMaskEdit;
            rg_num: TcxRadioGroup;
            sedt_num_max: TcxSpinEdit;
            sedt_num_min: TcxSpinEdit;
            Label2: TLabel;
            Label3: TLabel;
            Label4: TLabel;
            Label5: TLabel;
            rg_master: TcxRadioGroup;
            Label6: TLabel;
            Label7: TLabel;
    Label8: TLabel;
            procedure cxRadioGroup3PropertiesEditValueChanged(Sender: TObject);
            procedure FormShow(Sender: TObject);
            procedure cxButton2Click(Sender: TObject);
            procedure cxButton1Click(Sender: TObject);
      private
    { Private declarations }
      public
    { Public declarations }
            node: TXmlNode;
      end;

var
      frm_attribInfo: Tfrm_attribInfo;

implementation

uses Symbol_Unit;

{$R *.dfm}

procedure Tfrm_attribInfo.cxRadioGroup3PropertiesEditValueChanged(Sender: TObject);
begin
      self.cxPageControl1.Pages[0].TabVisible := False;
      self.cxPageControl1.Pages[1].TabVisible := false;
      self.cxPageControl1.Pages[2].TabVisible := false;

      self.cxPageControl1.Pages[rg_master.ItemIndex].Visible := true;
      self.cxPageControl1.ActivePageIndex := rg_master.ItemIndex;
      self.cxPageControl1.Pages[rg_master.ItemIndex].TabVisible := true;

end;

procedure Tfrm_attribInfo.FormShow(Sender: TObject);
begin
      if (node.AttributeCount > 0) then
      begin
            if node.AttributeByName[ITEM_TYPE] = ITEM_TYPE_INTEGER then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_NUMBER_MASTER_RADIO_INDEX;
                  rg_num.ItemIndex := ITEM_TYPE_INTEGER_CHILD_RADIO_INDEX;
                  sedt_num_max.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MAX];
                  sedt_num_min.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MIN];
            end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DOUBLE then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_NUMBER_MASTER_RADIO_INDEX;
                  rg_num.ItemIndex := ITEM_TYPE_DOUBLE_CHILD_RADIO_INDEX;
                  sedt_num_max.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MAX];
                  sedt_num_min.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MIN];
            end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DATE then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_DATETIME_MASTER_RADIO_INDEX;
                  rg_datetime.ItemIndex := ITEM_TYPE_DATE_CHILD_RADIO_INDEX;
                  medt_date_max.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MAX];
                  medt_date_min.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MIN];
            end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_DATETIME then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_DATETIME_MASTER_RADIO_INDEX;
                  rg_datetime.ItemIndex := ITEM_TYPE_DATETIME_CHILD_RADIO_INDEX;
                  medt_date_max.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MAX];
                  medt_date_min.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MIN];
            end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_TIME then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_DATETIME_MASTER_RADIO_INDEX;
                  rg_datetime.ItemIndex := ITEM_TYPE_TIME_CHILD_RADIO_INDEX;
            end else if node.AttributeByName[ITEM_TYPE] = Symbol_Unit.ITEM_TYPE_ENMU then
            begin
                  rg_master.ItemIndex := ITEM_TYPE_ENMU_MASTER_RADIO_INDEX;
                  memo_enmu.Text := node.AttributeByName[Symbol_Unit.ITEM_TYPE_ENMU_ITEMS];
            end
      end else
      begin
        rg_master.ItemIndex:=0;
        
      end;
      edt_item_name.Text := node.AttributeByName[ITEM_TITLE];
end;

procedure Tfrm_attribInfo.cxButton2Click(Sender: TObject);
begin
      node.AttributeByName[ITEM_TITLE] := edt_item_name.Text;
      case rg_master.ItemIndex of
            ITEM_TYPE_NUMBER_MASTER_RADIO_INDEX: begin
                        case rg_num.ItemIndex of
                              ITEM_TYPE_INTEGER_CHILD_RADIO_INDEX: begin
                                          node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_INTEGER;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MAX] := sedt_num_max.Text;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_INTEGER_MIN] := sedt_num_min.Text;
                                    end;
                              ITEM_TYPE_DOUBLE_CHILD_RADIO_INDEX: begin
                                          node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_DOUBLE;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MAX] := sedt_num_max.Text;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DOUBLE_MIN] := sedt_num_min.Text;
                                    end;
                        end;

                  end;
            ITEM_TYPE_DATETIME_MASTER_RADIO_INDEX: begin
                        case rg_datetime.ItemIndex of
                              ITEM_TYPE_TIME_CHILD_RADIO_INDEX: begin
                                          node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_TIME;
                                    end;
                              ITEM_TYPE_DATETIME_CHILD_RADIO_INDEX: begin
                                          node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_DATETIME;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MAX] := medt_date_max.Text;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATETIME_MIN] := medt_date_min.Text;
                                    end;
                              ITEM_TYPE_DATE_CHILD_RADIO_INDEX: begin
                                          node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_DATE;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MAX] := medt_date_max.Text;
                                          node.AttributeByName[Symbol_Unit.ITEM_TYPE_DATE_MIN] := medt_date_min.Text;
                                    end;
                        end;
                  end;
            ITEM_TYPE_ENMU_MASTER_RADIO_INDEX: begin
                        node.AttributeByName[ITEM_TYPE] := Symbol_Unit.ITEM_TYPE_ENMU;
                        node.AttributeByName[Symbol_Unit.ITEM_TYPE_ENMU_ITEMS] := memo_enmu.Text;
                  end;
      end;
      ModalResult := mrOk;
end;

procedure Tfrm_attribInfo.cxButton1Click(Sender: TObject);
begin
      ModalResult := mrCancel;
end;

end.

