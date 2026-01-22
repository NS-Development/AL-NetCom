tableextension 50104 "NetCom Item" extends Item
{
    fields
    {
        field(50100; "NetCom Environmental Tax"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Environmental Tax';
            ToolTip = 'Specifies the environmental tax for the item.';
        }
        field(50101; "NetCom Electronic"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Electronic';
            ToolTip = 'Specifies whether the item is electronic.';
        }
        field(50102; "NetCom Packaging"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Packaging';
            ToolTip = 'Packaging.';
        }
    }
}