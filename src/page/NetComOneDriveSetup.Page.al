page 50103 "NetCom OneDrive Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = Card;
    SourceTable = "NetCom OneDrive Setup";
    Caption = 'NetCom OneDrive Setup';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Azure Tenant ID"; Rec."Azure Tenant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure Tenant ID';
                }
                field("Azure App Client ID"; Rec."Azure App Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure App Client ID';
                }
                field("Azure App Client Secret"; Rec."Azure App Client Secret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Azure App Client Secret';
                }
                field("Authentication User"; Rec."Authentication User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Authentication User';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}