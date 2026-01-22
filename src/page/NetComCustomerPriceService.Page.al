page 50101 "NetCom Customer Price Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NetCom Customer Price Service";
    Caption = 'Customer Price List Export';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer No.';
                }
                // field("Cloud Storage Folder ID"; Rec."Cloud Storage Folder ID")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Cloud Storage Folder ID';
                // }
                field("Export Interval"; Rec."Export Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Export Interval';
                }
                field(Export; Rec.Export)
                {
                    ApplicationArea = All;
                    ToolTip = 'Export';
                }
                field("Skip Web Description"; Rec."Skip Web Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Skip Web Description';
                }
                field("Latest Export"; Rec."Latest Export")
                {
                    ApplicationArea = All;
                    ToolTip = 'Latest Export';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(GeneratePriceLists)
            {
                ApplicationArea = All;
                Caption = 'Generate Price Lists';
                ToolTip = 'Generate Price Lists';
                Image = Export;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"NetCom Customer Price Service");
                end;
            }
            // action(ExportToOneDrive)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Export To OneDrive';
            //     ToolTip = 'Export To OneDrive';
            //     Image = LaunchWeb;

            //     trigger OnAction()
            //     var
            //         NetComCustomerPriceService: Codeunit "NetCom Customer Price Service";
            //     begin
            //         NetComCustomerPriceService.ExportToOneDrive(Rec."Customer No.");
            //     end;
            // }
            // action(ExportAllToOneDrive)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Export All To OneDrive';
            //     ToolTip = 'Export All To OneDrive';
            //     Image = LaunchWeb;

            //     trigger OnAction()
            //     var
            //         NetComCustomerPriceService: Codeunit "NetCom Customer Price Service";
            //     begin
            //         if Rec.FindSet() then
            //             repeat
            //                 NetComCustomerPriceService.ExportToOneDrive(Rec."Customer No.");
            //             until Rec.Next() = 0;

            //     end;
            // }
            // group(ExportToOneDrive)
            // {
            //     Caption = 'TEST New OneDrive Connection';
            action(ExportToOneDrive)
            {
                ApplicationArea = All;
                Caption = 'Export To OneDrive';
                ToolTip = 'Export To OneDrive';
                Image = LaunchWeb;

                trigger OnAction()
                var
                    NetComCustomerPriceService: Record "NetCom Customer Price Service";
                    NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
                begin
                    NetComCustomerPriceService := Rec;
                    NetComCustomerPriceService.SetRecFilter();
                    NetComOneDriveGraphAPI.UploadFile(NetComCustomerPriceService);
                end;
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
                    if Rec.FindSet() then
                        repeat
                            NetComCustomerPriceService := Rec;
                            NetComCustomerPriceService.SetRecFilter();
                            NetComOneDriveGraphAPI.UploadFile(NetComCustomerPriceService);
                        until Rec.Next() = 0;
                end;
            }
            // }
        }
        area(Promoted)
        {
            actionref(GeneratePriceListsPromoted; GeneratePriceLists) { }
            actionref(ExportToOneDrivePromoted; ExportToOneDrive) { }
            actionref(ExportAllToOneDrivePromoted; ExportAllToOneDrive) { }
        }
    }
}