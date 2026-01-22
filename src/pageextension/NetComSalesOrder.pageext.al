pageextension 50105 "NetCom Sales Order" extends "Sales Order"
{
    actions
    {
        addlast("F&unctions")
        {
            action(NetComSalesOrderScan)
            {
                ApplicationArea = All;
                Caption = 'Scan';
                ToolTip = 'Scan the EAN code or serial number of the item.';
                Image = BarCode;

                trigger OnAction()
                begin
                    Page.Run(Page::"NetCom Sales order Scan", Rec);
                end;
            }
        }

        addlast(Promoted)
        {
            actionref(NetComSalesOrderScan_Promoted; NetComSalesOrderScan) { }
        }
    }
}