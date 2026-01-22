page 50100 "CalcTempPrice"
{
    // ApplicationArea = All;
    Caption = 'CalcTempPrice';
    PageType = Card;
    SourceTable = "Calc. Price Buffer";
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = All;
                }
                field(CustomerVendorNo; Rec.CustomerVendorNo)
                {
                    ApplicationArea = All;
                }
                field("Contact No."; Rec."Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Calculation Date"; Rec."Calculation Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Price Asset Type"; Rec."Price Asset Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
    end;
}
