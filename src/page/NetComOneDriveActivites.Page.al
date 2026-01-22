page 50102 "NetCom OneDrive Activites"
{
    Caption = 'OneDrive Activites';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "Sales Cue";

    layout
    {
        area(Content)
        {
            cuegroup(OneDrive)
            {
                Caption = 'Customer - Price Lists';

                field("NetCom Price Lists - Export"; Rec."NetCom Price Lists - Export")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NetCom Customer Price Service";
                    ToolTip = 'Customer Price Service';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NetComOneDriveSetup)
            {
                ApplicationArea = All;
                Caption = 'NetCom OneDrive Setup';
                ToolTip = 'NetCom OneDrive Setup';
                Image = Setup;
                RunObject = page "NetCom OneDrive Setup";
            }
            action(ExportAllToOneDrive)
            {
                ApplicationArea = All;
                Caption = 'Export All To OneDrive';
                ToolTip = 'Export All To OneDrive';
                Image = LaunchWeb;

                trigger OnAction()
                var
                    NetComCustomerPriceService: Record "NetCom Customer Price Service";
                    NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
                begin
                    NetComCustomerPriceService.Reset();
                    if NetComCustomerPriceService.FindSet() then
                        repeat
                            NetComOneDriveGraphAPI.UploadFile(NetComCustomerPriceService);
                        until NetComCustomerPriceService.Next() = 0;
                end;
            }
            action(CustomerPriceListExport)
            {
                ApplicationArea = All;
                Caption = 'Customer Price List Export';
                ToolTip = 'Customer Price List Export';
                Image = LaunchWeb;
                RunObject = page "NetCom Customer Price Service";
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