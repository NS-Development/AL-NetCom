pageextension 50100 "NetCom Item Journal" extends "Item Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addlast("F&unctions")
        {
            action(ImportItems)
            {

                ApplicationArea = All;
                Caption = 'Import Items';
                Image = Import;
                ToolTip = 'Import Items';

                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"NetCom Import Item Primo", true, true);
                end;
            }
        }
    }
}