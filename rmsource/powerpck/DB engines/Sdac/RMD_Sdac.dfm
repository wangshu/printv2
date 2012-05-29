object RMDSdacDBEdit: TRMDSdacDBEdit
  Left = 286
  Top = 290
  BorderStyle = bsToolWindow
  Caption = 'MSConnectionEditorForm'
  ClientHeight = 281
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnShow = FormShow
  DesignSize = (
    450
    281)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 434
    Height = 232
    ActivePage = shConnect
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object shConnect: TTabSheet
      Caption = 'Connect'
      DesignSize = (
        426
        204)
      object shRed: TShape
        Left = 24
        Top = 175
        Width = 15
        Height = 15
        Anchors = [akLeft, akBottom]
        Brush.Color = clBtnFace
        Pen.Color = clBtnShadow
        Shape = stCircle
      end
      object shYellow: TShape
        Left = 41
        Top = 175
        Width = 15
        Height = 15
        Anchors = [akLeft, akBottom]
        Brush.Color = clBtnFace
        Enabled = False
        Pen.Color = clBtnShadow
        Shape = stCircle
      end
      object shGreen: TShape
        Left = 58
        Top = 175
        Width = 15
        Height = 15
        Anchors = [akLeft, akBottom]
        Brush.Color = clBtnFace
        Enabled = False
        Pen.Color = clBtnShadow
        Shape = stCircle
      end
      object Panel: TPanel
        Left = 8
        Top = 8
        Width = 273
        Height = 150
        Anchors = [akLeft, akTop, akBottom]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object lbUsername: TLabel
          Left = 16
          Top = 20
          Width = 48
          Height = 13
          Caption = 'Username'
        end
        object lbPassword: TLabel
          Left = 16
          Top = 53
          Width = 46
          Height = 13
          Caption = 'Password'
        end
        object lbServer: TLabel
          Left = 16
          Top = 86
          Width = 31
          Height = 13
          Caption = 'Server'
        end
        object lbDatabase: TLabel
          Left = 16
          Top = 118
          Width = 46
          Height = 13
          Caption = 'Database'
        end
        object edServer: TComboBox
          Left = 104
          Top = 82
          Width = 153
          Height = 21
          ItemHeight = 13
          TabOrder = 2
          OnDropDown = edServerDropDown
          OnExit = edServerExit
        end
        object edUsername: TEdit
          Left = 104
          Top = 16
          Width = 153
          Height = 21
          TabOrder = 0
          OnExit = edUsernameExit
        end
        object edPassword: TMaskEdit
          Left = 104
          Top = 49
          Width = 153
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
          OnExit = edPasswordExit
        end
        object edDatabase: TComboBox
          Left = 104
          Top = 114
          Width = 153
          Height = 21
          ItemHeight = 13
          TabOrder = 3
          OnDropDown = edDatabaseDropDown
          OnExit = edDatabaseExit
        end
      end
      object btConnect: TButton
        Left = 92
        Top = 170
        Width = 89
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Connect'
        Default = True
        TabOrder = 3
        OnClick = btConnectClick
      end
      object btDisconnect: TButton
        Left = 192
        Top = 170
        Width = 89
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Disconnect'
        TabOrder = 4
        OnClick = btDisconnectClick
      end
      object cbLoginPrompt: TCheckBox
        Left = 296
        Top = 8
        Width = 121
        Height = 17
        Caption = 'LoginPrompt'
        TabOrder = 1
        OnClick = cbLoginPromptClick
      end
      object rgAuth: TRadioGroup
        Left = 296
        Top = 32
        Width = 121
        Height = 65
        Caption = 'Authentication'
        Items.Strings = (
          'Windows'
          'SQL Server')
        TabOrder = 2
        OnClick = rgAuthClick
      end
    end
  end
  object btClose: TButton
    Left = 366
    Top = 249
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 1
  end
end
