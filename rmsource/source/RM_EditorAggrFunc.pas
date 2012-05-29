
unit RM_EditorAggrFunc;

interface

{$I RM.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls
{$IFDEF COMPILER6_UP}
, Variants
{$ENDIF};
  

type
  TRMEditorAggrFunc = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    AggregatePanel: TGroupBox;
    lblDataBand: TLabel;
    lblDataSet: TLabel;
    lblDataField: TLabel;
    lblFunction: TLabel;
    lblExpression: TLabel;
    cmbField: TComboBox;
    cmbDataSet: TComboBox;
    cmbDataBand: TComboBox;
    chkCountInvisible: TCheckBox;
    cmbFunction: TComboBox;
    chkRunningTotal: TCheckBox;
  private
  public
  end;


implementation

{$R *.DFM}

end.

