page 50111 "NetCom Env. Tax Preview"
{
    PageType = List;
    SourceTable = "NetCom Env. Tax Preview";
    Caption = 'Environmental Tax Preview';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item to update.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item description.';
                }
                field("Packaging Weight"; Rec."Packaging Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies gross weight minus net weight in kilograms, with a minimum of zero.';
                }
                field("Existing Environmental Tax"; Rec."Existing Environmental Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the environmental tax currently stored on the item.';
                }
                field("New Environmental Tax"; Rec."New Environmental Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies packaging weight multiplied by the environmental tax per kilogram, rounded to two decimal places.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateItems)
            {
                ApplicationArea = All;
                Caption = 'Update Items';
                ToolTip = 'Updates all items in the preview, including items hidden by filters, with the new environmental tax.';
                Image = UpdateDescription;

                trigger OnAction()
                var
                    UpdatedCount: Integer;
                    UpdatedMsg: Label '%1 items were updated.', Comment = '%1 = Number of updated items';
                begin
                    UpdatedCount := EnvironmentalTax.ApplyPreview(Rec, TaxPerKg);
                    Message(UpdatedMsg, UpdatedCount);
                    CurrPage.Close();
                end;
            }
        }
        area(Promoted)
        {
            actionref(UpdateItems_Promoted; UpdateItems) { }
        }
    }

    trigger OnOpenPage()
    var
        NoChangesMsg: Label 'No packaging items need their environmental tax updated.';
    begin
        EnvironmentalTax.BuildPreview(Rec, TaxPerKg);
        if Rec.IsEmpty() then
            Message(NoChangesMsg);
    end;

    var
        EnvironmentalTax: Codeunit "NetCom Environmental Tax";
        TaxPerKg: Decimal;
}
