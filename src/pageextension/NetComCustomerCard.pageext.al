pageextension 50101 "NetCom Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            group("NetCom NSW")
            {
                Caption = 'Webshop';

                field("NetCom Invoice Payment"; Rec."NetCom Invoice Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if field is marked the, Customer is able to pay with Invoice at Webshop';
                }
            }
        }
    }
}