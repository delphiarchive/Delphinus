object CategoryFilterView: TCategoryFilterView
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  OnResize = FrameResize
  object tvCategories: TTreeView
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    Indent = 19
    ParentFont = False
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    TabOrder = 0
    OnAdvancedCustomDrawItem = tvCategoriesAdvancedCustomDrawItem
    OnChange = tvCategoriesChange
    OnChanging = tvCategoriesChanging
    OnCollapsing = tvCategoriesCollapsing
  end
end
