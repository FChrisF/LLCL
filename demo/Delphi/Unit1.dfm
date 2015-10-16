object Form1: TForm1
  Left = 198
  Top = 114
  Width = 416
  Height = 595
  Caption = 'LLCL - Just testing...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 512
    Width = 26
    Height = 13
    Caption = 'Label'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 140
    Width = 129
    Height = 65
    Caption = '&GroupBox1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 9
    object RadioButton1: TRadioButton
      Left = 20
      Top = 19
      Width = 93
      Height = 17
      Caption = 'RadioButton1 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsItalic]
      ParentFont = False
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 20
      Top = 38
      Width = 85
      Height = 17
      Alignment = taLeftJustify
      Caption = 'RadioButton2'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      TabStop = True
    end
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 12
    Width = 133
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemHeight = 13
    ParentFont = False
    TabOrder = 0
    Text = 'sample text'
    OnChange = ComboBox1Change
    Items.Strings = (
      '11'
      '22'
      '44'
      '33')
  end
  object Edit1: TEdit
    Left = 276
    Top = 12
    Width = 125
    Height = 21
    TabOrder = 12
    Text = 'New item name'
    OnChange = Edit1Change
    OnDblClick = Edit1DblClick
  end
  object Button1: TButton
    Left = 184
    Top = 12
    Width = 75
    Height = 25
    Caption = '&Add'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 11
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 184
    Top = 44
    Width = 75
    Height = 25
    Caption = '&Clear'
    TabOrder = 13
    OnClick = Button3Click
  end
  object ListBox1: TListBox
    Left = 184
    Top = 76
    Width = 217
    Height = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ItemHeight = 13
    Items.Strings = (
      '444'
      '111'
      '333'
      '222')
    ParentFont = False
    TabOrder = 16
    OnDblClick = ListBox1DblClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 216
    Width = 393
    Height = 285
    Lines.Strings = (
      'asd'
      'zxc')
    ScrollBars = ssVertical
    TabOrder = 17
  end
  object Button2: TButton
    Left = 276
    Top = 44
    Width = 53
    Height = 25
    Caption = 'GetText'
    TabOrder = 14
    OnClick = Button2Click
  end
  object Button4: TButton
    Left = 348
    Top = 44
    Width = 53
    Height = 25
    Caption = 'SetText'
    TabOrder = 15
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 76
    Width = 73
    Height = 17
    Alignment = taLeftJustify
    AllowGrayed = True
    Caption = 'CheckBox1'
    State = cbGrayed
    TabOrder = 4
  end
  object Button6: TButton
    Left = 88
    Top = 92
    Width = 53
    Height = 25
    Caption = 'Grayed'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 148
    Top = 12
    Width = 29
    Height = 25
    Caption = 'DD'
    TabOrder = 1
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 80
    Top = 44
    Width = 61
    Height = 21
    Caption = 'Disabled'
    Enabled = False
    TabOrder = 3
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 144
    Top = 180
    Width = 33
    Height = 25
    Caption = 'Sh/H'
    TabOrder = 10
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 8
    Top = 44
    Width = 69
    Height = 21
    Caption = 'Invisible!!!'
    TabOrder = 2
    Visible = False
    OnClick = Button10Click
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 96
    Width = 73
    Height = 17
    Caption = 'CheckBox2'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 116
    Width = 73
    Height = 17
    Alignment = taLeftJustify
    Caption = 'CheckBox3'
    TabOrder = 6
  end
  object ComboBox2: TComboBox
    Left = 148
    Top = 44
    Width = 25
    Height = 129
    Style = csSimple
    ItemHeight = 13
    TabOrder = 8
    Text = '10'
    Items.Strings = (
      '5'
      '4'
      '3'
      '2'
      '1')
  end
  object StaticText1: TStaticText
    Left = 44
    Top = 512
    Width = 68
    Height = 17
    Alignment = taCenter
    AutoSize = False
    BorderStyle = sbsSunken
    Caption = 'StaticText'
    TabOrder = 18
  end
  object Button5: TButton
    Left = 120
    Top = 512
    Width = 94
    Height = 25
    Cancel = True
    Caption = 'Cancel Button'
    TabOrder = 19
    OnClick = Button5Click
  end
  object Button11: TButton
    Left = 216
    Top = 512
    Width = 94
    Height = 25
    Caption = 'Default Button'
    Default = True
    TabOrder = 20
    OnClick = Button11Click
  end
  object ProgressBar1: TProgressBar
    Left = 320
    Top = 516
    Width = 81
    Height = 16
    TabOrder = 21
  end
  object StaticText2: TStaticText
    Left = 184
    Top = 184
    Width = 217
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = '(Reserved for dynamic control)'
    TabOrder = 22
    Visible = False
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 368
  end
  object MainMenu1: TMainMenu
    Left = 336
    object MenuItem1: TMenuItem
      Caption = '&Menu1'
      object MenuItem3: TMenuItem
        AutoCheck = True
        Caption = 'Menu11'
        Checked = True
      end
      object MenuItem4: TMenuItem
        Caption = 'Menu12'
        Enabled = False
      end
      object MenuItem13: TMenuItem
        Caption = '-'
      end
      object MenuItem11: TMenuItem
        Caption = 'Open File...'
        OnClick = MenuItem11Click
      end
      object MenuItem12: TMenuItem
        Caption = 'Save File...'
        OnClick = MenuItem12Click
      end
      object MenuItem5: TMenuItem
        Caption = '-'
      end
      object MenuItem6: TMenuItem
        Caption = 'Quit'
        OnClick = MenuItem6Click
      end
    end
    object MenuItem2: TMenuItem
      Caption = 'M&enu2'
      object MenuItem7: TMenuItem
        Caption = 'Menu21'
        OnClick = MenuItem7Click
      end
      object MenuItem8: TMenuItem
        Caption = 'Menu22'
        OnClick = MenuItem8Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 304
    object MenuItem9: TMenuItem
      Caption = 'Popup1'
      OnClick = MenuItem9Click
    end
    object MenuItem10: TMenuItem
      Caption = 'Popup2'
      OnClick = MenuItem10Click
    end
  end
  object XPManifest1: TXPManifest
    Left = 272
  end
  object SaveDialog1: TSaveDialog
    Left = 240
  end
  object OpenDialog1: TOpenDialog
    Left = 208
  end
end
