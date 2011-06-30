object frmMain: TfrmMain
  Left = 333
  Top = 251
  Width = 686
  Height = 563
  Caption = 'NativeXml Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object mmDebug: TMemo
    Left = 0
    Top = 0
    Width = 678
    Height = 509
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Lucida Console'
    Font.Style = []
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    Left = 432
    Top = 104
    object File1: TMenuItem
      Caption = 'File'
      object mnuParse: TMenuItem
        Caption = 'Parse'
        OnClick = mnuParseClick
      end
      object mnuParseCanonical: TMenuItem
        Caption = 'Parse Canonical'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Caption = 'Exit'
        OnClick = mnuExitClick
      end
    end
    object est1: TMenuItem
      Caption = 'Test'
      object mnuTest1: TMenuItem
        Caption = 'Test 1'
        OnClick = mnuTest1Click
      end
      object mnuTest2: TMenuItem
        Caption = 'Test 2'
        OnClick = mnuTest2Click
      end
      object mnuTest3: TMenuItem
        Caption = 'Test 3'
        OnClick = mnuTest3Click
      end
      object mnuTest4: TMenuItem
        Caption = 'Test 4'
        OnClick = mnuTest4Click
      end
      object mnuTest5: TMenuItem
        Caption = 'Test 5'
        OnClick = mnuTest5Click
      end
      object mnuTest6: TMenuItem
        Caption = 'Test 6'
        OnClick = mnuTest6Click
      end
      object mnuTest7: TMenuItem
        Caption = 'Test 7'
        OnClick = mnuTest7Click
      end
      object mnuTest8: TMenuItem
        Caption = 'Test 8'
        OnClick = mnuTest8Click
      end
      object mnuTest9: TMenuItem
        Caption = 'Test 9'
        OnClick = mnuTest9Click
      end
      object mnuTest10: TMenuItem
        Caption = 'Test 10'
        OnClick = mnuTest10Click
      end
      object mnuTest11: TMenuItem
        Caption = 'Test 11'
        OnClick = mnuTest11Click
      end
      object mnuTest12: TMenuItem
        Caption = 'Test 12'
        OnClick = mnuTest12Click
      end
      object mnuTest13: TMenuItem
        Caption = 'Test 13'
        OnClick = mnuTest13Click
      end
      object mnuTest14: TMenuItem
        Caption = 'Test 14'
        OnClick = mnuTest14Click
      end
      object mnuTest15: TMenuItem
        Caption = 'Test 15'
        OnClick = mnuTest15Click
      end
      object mnuTest16: TMenuItem
        Caption = 'Test 16'
        OnClick = mnuTest16Click
      end
      object Test171: TMenuItem
        Caption = 'Test 17'
        OnClick = Test171Click
      end
    end
  end
end
