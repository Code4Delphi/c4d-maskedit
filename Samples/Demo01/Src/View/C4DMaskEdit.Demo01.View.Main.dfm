object C4DMaskEditDemo01ViewMain: TC4DMaskEditDemo01ViewMain
  Left = 0
  Top = 0
  Caption = 'C4DMaskEditDemo01ViewMain'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  TextHeight = 13
  object RadioButton1: TRadioButton
    Left = 80
    Top = 232
    Width = 113
    Height = 17
    Caption = 'RadioButton1'
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 80
    Top = 205
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 232
    Top = 78
    Width = 177
    Height = 25
    Caption = 'ShowMessage informa'#231#245'es'
    TabOrder = 2
    OnClick = Button1Click
  end
  object C4DMaskEdit1: TC4DMaskEdit
    Left = 80
    Top = 80
    Width = 121
    Height = 21
    DisplayFormat = ',0.00%'
    DecimalPlaces = 2
    CheckOnExit = False
    FormatOnEditing = True
    ZeroEmpty = True
    DecimalPlaceRound = True
    DecimalPlacesAlwaysShown = True
    TabOrder = 3
  end
  object C4DMaskEdit2: TC4DMaskEdit
    Left = 296
    Top = 152
    Width = 121
    Height = 21
    DisplayFormat = ',0.00'
    DecimalPlaces = 2
    CheckOnExit = False
    FormatOnEditing = True
    ZeroEmpty = True
    DecimalPlaceRound = False
    DecimalPlacesAlwaysShown = True
    TabOrder = 4
  end
end
