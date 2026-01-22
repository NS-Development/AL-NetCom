page 50106 "NetCom Scan Update Quantity"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Update Quantity';
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(ScannedQty; ScannedQty)
                {
                    ApplicationArea = All;
                    Caption = 'Scanned Qty.';
                    ToolTip = 'Scanned quantity of the item.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ScannedQty := Rec."NetCom Scanned Qty.";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then begin
            Rec.Validate("NetCom Scanned Qty.", ScannedQty);
            Rec.Modify(true);
        end;
    end;

    var
        ScannedQty: Decimal;
}