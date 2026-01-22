pageextension 50102 "NetCom Customer List" extends "Customer List"
{
    layout
    {
        addlast(Control1)
        {
            field("NetCom Invoice Payment"; Rec."NetCom Invoice Payment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if field is marked the, Customer is able to pay with Invoice at Webshop';
            }
        }
    }
}