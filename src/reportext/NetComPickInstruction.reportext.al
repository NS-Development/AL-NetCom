reportextension 50100 "NetCom Pick Instruction" extends "Pick Instruction"
{
    dataset
    {
        add("Sales Header")
        {
            column(ShipToName_Lbl; ShipToNameLbl) { }
            column(ShipToAddress_Lbl; ShipToAddressLbl) { }
            column(ShipToPostCodeCity_Lbl; ShipToPostCodeCityLbl) { }
            column(SalesHeader_ShipToName; "Sales Header"."Ship-to Name") { }
            column(SalesHeader_ShipToAddress; "Sales Header"."Ship-to Address") { }
            column(SalesHeader_ShipToPostCodeCity; "Sales Header"."Ship-to Post Code" + ' ' + "Sales Header"."Ship-to City") { }
        }
        add("Sales Line")
        {
            column(ItemStock_Lbl; ItemStockLbl) { }
            column(Item_Stock; ItemStock) { }
        }

        modify("Sales Line")
        {
            trigger OnAfterAfterGetRecord()
            var
                Item: Record Item;
            begin
                ItemStock := 0;
                if Item.Get("Sales Line"."No.") then begin
                    Item.CalcFields(Inventory);
                    ItemStock := Item.Inventory;
                end;
            end;
        }
    }

    rendering
    {
        layout(NetCom_PickInstruction)
        {
            Type = RDLC;
            LayoutFile = 'src\layout\NetComPickInstruction.rdlc';
        }
    }

    var
        ItemStock: Decimal;
        ItemStockLbl: Label 'Stock';
        ShipToNameLbl: Label 'Ship-to Name';
        ShipToAddressLbl: Label 'Ship-to Address';
        ShipToPostCodeCityLbl: Label 'Ship-to Post Code / City';
}