pageextension 50107 "NetCom Item Card" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("NetCom Environmental Tax"; Rec."NetCom Environmental Tax")
            {
                ApplicationArea = All;
            }
            field("NetCom Packaging"; Rec."NetCom Packaging")
            {
                ApplicationArea = All;
            }
            field("NetCom Electronic"; Rec."NetCom Electronic")
            {
                ApplicationArea = All;
            }
        }
    }
}