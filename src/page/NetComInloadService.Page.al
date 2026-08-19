page 50108 "NetCom Inload Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NetCom Inload Service";
    Caption = 'Inload Export';

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
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
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
            action(GenerateFiles)
            {
                ApplicationArea = All;
                Caption = 'Generate Files';
                ToolTip = 'Generate Files';
                Image = Export;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"NetCom Inload Service");
                end;
            }
            action(ExportToFile)
            {
                ApplicationArea = All;
                Caption = 'Export To File';
                ToolTip = 'Export To File';
                Image = Export;

                trigger OnAction()
                var
                    NetComInloadService: Record "NetCom Inload Service";
                    TempBlob: Codeunit "Temp Blob";
                    OutStream: OutStream;
                    InStream: InStream;
                    FileName: Text;
                    NothingToDownloadErr: Label 'Der er ingen fil i feltet Document Reference ID for kunde %1.', Comment = '%1 = Customer No.';
                    InloadFileNameLbl: Label 'Inload_%1.csv', Comment = '%1 = Customer No.';
                begin
                    NetComInloadService := Rec;
                    NetComInloadService.SetRecFilter();
                    if not NetComInloadService.FindFirst() then
                        exit;

                    TempBlob.CreateOutStream(OutStream);
                    if not NetComInloadService."Document Reference ID".ExportStream(OutStream) then
                        Error(NothingToDownloadErr, NetComInloadService."Customer No.");

                    TempBlob.CreateInStream(InStream);
                    FileName := StrSubstNo(InloadFileNameLbl, NetComInloadService."Customer No.");
                    DownloadFromStream(InStream, '', '', '', FileName);

                end;
            }
            action(ExportToOneDrive)
            {
                ApplicationArea = All;
                Caption = 'Export To OneDrive';
                ToolTip = 'Export To OneDrive';
                Image = LaunchWeb;

                trigger OnAction()
                var
                    NetComInloadService: Record "NetCom Inload Service";
                    NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
                begin
                    NetComInloadService := Rec;
                    NetComInloadService.SetRecFilter();
                    NetComOneDriveGraphAPI.UploadFileInload(NetComInloadService);
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
                    NetComInloadService: Record "NetCom Inload Service";
                    NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
                begin
                    if Rec.FindSet() then
                        repeat
                            NetComInloadService := Rec;
                            NetComInloadService.SetRecFilter();
                            NetComOneDriveGraphAPI.UploadFileInload(NetComInloadService);
                        until Rec.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            actionref(GenerateFilesPromoted; GenerateFiles) { }
            actionref(ExportToOneDrivePromoted; ExportToOneDrive) { }
            actionref(ExportAllToOneDrivePromoted; ExportAllToOneDrive) { }
        }
    }
}