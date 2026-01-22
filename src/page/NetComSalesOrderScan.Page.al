page 50104 "NetCom Sales order Scan"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Sales Header";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Sales Order';

    layout
    {
        area(Content)
        {
            part(NetComSalesLines; "NetCom Sales Order Scan Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}