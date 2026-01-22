page 50107 "NetCom Analysis"
{
    ApplicationArea = All;
    Caption = 'Packaging tax overview';
    PageType = List;
    SourceTable = "NetCom Report Buffer Table";
    UsageCategory = Lists;
    // PromotedActionCategories = 'New,Process,Report,Show';
    Editable = false;
    // SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = Rec."Integer 01";
                ShowAsTree = true;

                field("Code 01"; Rec."Code 01")
                {
                    Caption = 'Group';
                    ToolTip = 'Group';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                }
                field("NetCom Item No."; Rec."NetCom Item No.")
                {
                    Caption = 'Item No.';
                    ToolTip = 'Item No.';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                }
                field("NetCom Item Description"; Rec."NetCom Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Item Description';
                }

                field("NetCom Amount sold"; Rec."NetCom Amount sold")
                {
                    ToolTip = 'Amount sold';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    BlankZero = true;
                    DecimalPlaces = 0 : 0;
                }
                field("NetCom Gross Weight"; Rec."NetCom Gross Weight")
                {
                    ToolTip = 'Gross Weight';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    BlankZero = true;
                    DecimalPlaces = 2 : 2;
                }
                field("NetCom Net Weight"; Rec."NetCom Net Weight")
                {
                    ToolTip = 'Net Weight';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    BlankZero = true;
                    DecimalPlaces = 2 : 2;
                }
                field("NetCom Weight"; Rec."NetCom Weight")
                {
                    ToolTip = 'Weight';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    BlankZero = true;
                    DecimalPlaces = 2 : 2;
                }
                field("Electronic Net. Weight"; Rec."Electronic Net. Weight")
                {
                    ToolTip = 'Electronic Net Weight';
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    BlankZero = true;
                    DecimalPlaces = 2 : 2;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Update)
            {
                Caption = 'Update';
                ToolTip = 'Update';
                Image = Refresh;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    NetComAnalysis: Report "NetCom Analysis";
                begin
                    Clear(NetComAnalysis);
                    // NetComAnalysis.SetTableView(SalesHeader);
                    NetComAnalysis.SetPageId(PageId());
                    NetComAnalysis.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure PageId(): Integer;
    begin
        Exit(50017)
    end;

    trigger OnOpenPage()
    var
    // UserSetup: Record "User Setup";
    // PageUpdateMsg: Label 'The page is last updated on %1';        
    begin
        Rec.Reset();
        Rec.FilterGroup(2);
        Rec.SetRange("User Id", UserId);
        Rec.SetRange("Report Id", PageId());
        Rec.FilterGroup(0);

        // If not UserSetup.get(UserId) then begin
        //     UserSetup."User ID" := UserId;
        //     UserSetup.Insert();
        // end;
        // UserSetup."Brugeropsætning adgang" := true;
        // UserSetup."Page Inbound Sales Orders" := UserSetup."Page Inbound Sales Orders"::"Show own";
        // UserSetup.Modify();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleIsStrong := Rec."Integer 01" = 0;
    end;

    var
        StyleIsStrong: Boolean;
}