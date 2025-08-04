object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'fMain'
  ClientHeight = 518
  ClientWidth = 858
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object btnLoadDLLs: TBitBtn
    Left = 8
    Top = 8
    Width = 185
    Height = 25
    Cursor = crHandPoint
    Caption = 'Load DLLs'
    TabOrder = 0
    OnClick = btnLoadDLLsClick
  end
  object lvTasks: TListView
    Left = 8
    Top = 39
    Width = 833
    Height = 282
    Columns = <
      item
        Caption = #1048#1084#1103' '#1079#1072#1076#1072#1095#1080
        Width = 150
      end
      item
        Caption = #1054#1087#1080#1089#1072#1085#1080#1077
        Width = 100
      end
      item
        Caption = 'DLL'
        Width = 300
      end>
    Items.ItemData = {}
    TabOrder = 1
    ViewStyle = vsReport
    OnSelectItem = lvTasksSelectItem
  end
  object btnExecute: TBitBtn
    Left = 766
    Top = 327
    Width = 75
    Height = 25
    Caption = 'btnExecute'
    TabOrder = 2
    OnClick = btnExecuteClick
  end
  object StringGrid1: TStringGrid
    Left = 8
    Top = 327
    Width = 737
    Height = 185
    ColCount = 2
    TabOrder = 3
  end
  object dlgOpenDlls: TOpenDialog
    Filter = '(*.dll)|*.dll'
    Options = [ofHideReadOnly, ofNoChangeDir, ofAllowMultiSelect, ofFileMustExist, ofEnableSizing]
    Left = 792
    Top = 416
  end
end
