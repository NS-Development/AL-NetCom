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
            cuegroup(OneDriveCustomerPriceLists)
            {
                Caption = 'Customer - Price Lists';

                field("NetCom Price Lists - Export"; Rec."NetCom Price Lists - Export")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NetCom Customer Price Service";
                    ToolTip = 'Customer Price Service';
                }
            }
            cuegroup(OneDriveInload)
            {
                Caption = 'Inload';
                field("NetCom Inload - Export"; Rec."NetCom Inload - Export")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NetCom Inload Service";
                    ToolTip = 'Inload Service';
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
            action(ExportAllToOneDrivePriceLists)
            {
                ApplicationArea = All;
                Caption = 'Export All To OneDrive (Price Lists)';
                ToolTip = 'Export All To OneDrive (Price Lists)';
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
            action(ExportAllToOneDriveInload)
            {
                ApplicationArea = All;
                Caption = 'Export All To OneDrive (Inload)';
                ToolTip = 'Export All To OneDrive (Inload)';
                Image = LaunchWeb;

                trigger OnAction()
                var
                    NetComInloadService: Record "NetCom Inload Service";
                    NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
                begin
                    NetComInloadService.Reset();
                    if NetComInloadService.FindSet() then
                        repeat
                            NetComOneDriveGraphAPI.UploadFileInload(NetComInloadService);
                        until NetComInloadService.Next() = 0;
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
            action(InloadExport)
            {
                ApplicationArea = All;
                Caption = 'Inload Export';
                ToolTip = 'Inload Export';
                Image = LaunchWeb;
                RunObject = page "NetCom Inload Service";
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