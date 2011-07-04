object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 453
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    1008
    453)
  PixelsPerInch = 96
  TextHeight = 13
  object edt1: TEdit
    Left = 40
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '90002@disha.com.cn'
  end
  object edt2: TEdit
    Left = 40
    Top = 51
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    Text = '111111'
  end
  object btn1: TButton
    Left = 86
    Top = 96
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 2
    OnClick = btn1Click
  end
  object mmo1: TMemo
    Left = 736
    Top = 24
    Width = 271
    Height = 428
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'mmo1')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btn2: TButton
    Left = 86
    Top = 136
    Width = 75
    Height = 25
    Caption = 'btn2'
    TabOrder = 4
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 48
    Top = 176
    Width = 75
    Height = 25
    Caption = 'btn3'
    TabOrder = 5
    OnClick = btn3Click
  end
  object mmo2: TMemo
    Left = 0
    Top = 232
    Width = 242
    Height = 105
    Lines.Strings = (
      '<iq xmlns="jabber:client" id="agsXMPP_55" '
      'type="get"><query '
      'xmlns="jabber:iq:roster"/></iq>')
    TabOrder = 6
  end
  object btn4: TButton
    Left = 144
    Top = 176
    Width = 75
    Height = 25
    Caption = 'btn4'
    TabOrder = 7
    OnClick = btn4Click
  end
  object redt1: TRichEdit
    Left = 440
    Top = 24
    Width = 290
    Height = 421
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'redt1')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 8
  end
  object cbb1: TComboBox
    Left = 8
    Top = 205
    Width = 145
    Height = 21
    TabOrder = 9
    Text = 'cbb1'
  end
  object btn5: TButton
    Left = 167
    Top = 201
    Width = 75
    Height = 25
    Caption = 'btn5'
    TabOrder = 10
  end
  object btn6: TButton
    Left = 16
    Top = 128
    Width = 75
    Height = 25
    Caption = 'btn6'
    TabOrder = 11
    OnClick = btn6Click
  end
  object mmo3: TMemo
    Left = 249
    Top = 24
    Width = 185
    Height = 265
    Lines.Strings = (
      'mmo3')
    TabOrder = 12
  end
  object edt3: TEdit
    Left = 249
    Top = 391
    Width = 121
    Height = 21
    TabOrder = 13
    Text = '3306@disha.com.cn'
  end
  object btn7: TButton
    Left = 376
    Top = 391
    Width = 75
    Height = 25
    Caption = 'btn7'
    TabOrder = 14
    OnClick = btn7Click
  end
  object mmo4: TMemo
    Left = 248
    Top = 295
    Width = 185
    Height = 89
    Lines.Strings = (
      'mmo4')
    TabOrder = 15
  end
  object chk1: TCheckBox
    Left = 145
    Top = 78
    Width = 97
    Height = 17
    Caption = 'chk1'
    TabOrder = 16
  end
  object btn8: TButton
    Left = 24
    Top = 352
    Width = 75
    Height = 25
    Caption = 'btn8'
    Enabled = False
    TabOrder = 17
    OnClick = btn8Click
  end
  object btn9: TButton
    Left = 105
    Top = 352
    Width = 75
    Height = 25
    Caption = 'btn9'
    TabOrder = 18
    OnClick = btn9Click
  end
  object dlgSave1: TSaveDialog
    Left = 40
    Top = 376
  end
  object flpndlg1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 88
    Top = 376
  end
end
