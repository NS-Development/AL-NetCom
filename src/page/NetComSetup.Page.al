page 50110 "NetCom Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = Card;
    SourceTable = "NetCom Setup";
    Caption = 'NetCom Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Environmental Tax per Kg."; Rec."Environmental Tax per Kg.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateAllItems)
            {
                ApplicationArea = All;
                Caption = 'Update All Items';
                ToolTip = 'Opens a preview of packaging items whose environmental tax will change. No items are updated until you choose Update Items.';
                Image = Calculate;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Commit();
                    Page.RunModal(Page::"NetCom Env. Tax Preview");
                end;
            }
        }
        area(Promoted)
        {
            actionref(UpdateAllItems_Promoted; UpdateAllItems) { }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
