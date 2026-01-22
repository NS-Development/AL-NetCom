codeunit 50103 "NetCom Customer Price Service"
{
    trigger OnRun()
    begin
        ExportPriceLists();
    end;

    local procedure ExportPriceLists()
    var
        NetComCustomerPriceService: Record "NetCom Customer Price Service";
        NetComCustomerPriceService2: Record "NetCom Customer Price Service";
        MillisecondsToRemove: BigInteger;
    begin
        NetComCustomerPriceService.Reset();
        if NetComCustomerPriceService.FindSet() then
            repeat
                case NetComCustomerPriceService."Export Interval" of
                    NetComCustomerPriceService."Export Interval"::"0 Hours":
                        MillisecondsToRemove := 0;
                    NetComCustomerPriceService."Export Interval"::"4 Hours":
                        MillisecondsToRemove := 14400000;
                    NetComCustomerPriceService."Export Interval"::"6 Hours":
                        MillisecondsToRemove := 21600000;
                    NetComCustomerPriceService."Export Interval"::"8 Hours":
                        MillisecondsToRemove := 28800000;
                    NetComCustomerPriceService."Export Interval"::"1 Day":
                        MillisecondsToRemove := 86400000;
                    NetComCustomerPriceService."Export Interval"::"2 Days":
                        MillisecondsToRemove := 172800000;
                    NetComCustomerPriceService."Export Interval"::"7 Days":
                        MillisecondsToRemove := 604800000;
                end;

                if ExportPriceList(NetComCustomerPriceService, MillisecondsToRemove) then begin
                    NetComCustomerPriceService2.Reset();
                    NetComCustomerPriceService2.SetRange("Customer No.", NetComCustomerPriceService."Customer No.");
                    if NetComCustomerPriceService2.FindFirst() then begin
                        NetComCustomerPriceService2.Export := true;
                        NetComCustomerPriceService2.Modify(true);
                    end;
                end;
            until NetComCustomerPriceService.Next() = 0;
    end;

    local procedure ExportPriceList(NetComCustomerPriceService: Record "NetCom Customer Price Service"; Milliseconds: BigInteger): Boolean
    var
        Customer: Record Customer;
        Item: Record Item;
        NetComCustomerPriceService2: Record "NetCom Customer Price Service";
        CustomerPriceListTempBlob: Codeunit "Temp Blob";
        // NetComOneDrive: Codeunit "NetCom One Drive";
        DocumentServiceManagement: Codeunit "Document Service Management";
        FileManagement: Codeunit "File Management";
        // NetComGDMediaMgt: Codeunit "NetCom GD Media Mgt.";
        NetComCustomerPriceList: Report "NetCom Customer Price List";
        // CustomerPriceListInStream: InStream;
        // DummyInStream: InStream;
        CustomerPriceListOutStream: OutStream;
        CustomerPriceListCaption: Text[50];
        Duration: Duration;
    begin
        Duration := Milliseconds;
        if not Customer.Get(NetComCustomerPriceService."Customer No.") then
            exit(false);

        if ((CurrentDateTime - Duration) >= NetComCustomerPriceService."Latest Export") or (NetComCustomerPriceService."Latest Export" = 0DT) then begin
            //DoExport....
            //Kald funktion hvor debitornr. sendes med og der returneres true/false afhængig af om det lykkedes at eksportere filen. HUSK at kontrollere at det er den korrekte debitor der tages.
            //NetComCustomerPriceService."Customer No."


            CustomerPriceListTempBlob.CreateOutStream(CustomerPriceListOutStream);
            NetComCustomerPriceList.InitializeRequest(Today, Enum::"Sales Price Source Type"::Customer, NetComCustomerPriceService."Customer No.", Customer."Currency Code");
            Item.Reset();
            Item.SetFilter(GTIN, '<>%1', '');
            NetComCustomerPriceList.SetTableView(Item);
            NetComCustomerPriceList.UseRequestPage(false);
            NetComCustomerPriceList.Run();

            // NetComCustomerPriceService2.Reset();
            // NetComCustomerPriceService2.SetRange("Customer No.", NetComCustomerPriceService."Customer No.");
            // if NetComCustomerPriceService2.FindFirst() then
            //     //DocumentServiceManagement.ShareWithOneDriveFromMedia(FileManagement.StripNotsupportChrInFileName('FOLDER[' + NetComCustomerPriceService."Customer No." + ']_' + 'PriceList_' + NetComCustomerPriceService."Customer No."), '.csv', NetComCustomerPriceService2."Document Reference ID".MediaId());
            //     DocumentServiceManagement.ShareWithOneDriveFromMedia(FileManagement.StripNotsupportChrInFileName('PriceList_' + NetComCustomerPriceService."Customer No."), '.csv', NetComCustomerPriceService2."Document Reference ID".MediaId());
            exit(true);
        end else
            exit(false);
    end;

    procedure ExportToOneDrive(CustomerNo: Code[20])
    var
        NetComCustomerPriceService: Record "NetCom Customer Price Service";
        DocumentServiceManagement: Codeunit "Document Service Management";
        FileManagement: Codeunit "File Management";
    begin
        NetComCustomerPriceService.Reset();
        NetComCustomerPriceService.SetRange("Customer No.", CustomerNo);
        if NetComCustomerPriceService.FindFirst() then begin
            //DocumentServiceManagement.ShareWithOneDriveFromMedia(FileManagement.StripNotsupportChrInFileName('FOLDER[' + NetComCustomerPriceService."Customer No." + ']_' + 'PriceList_' + NetComCustomerPriceService."Customer No."), '.csv', NetComCustomerPriceService2."Document Reference ID".MediaId());
            DocumentServiceManagement.ShareWithOneDriveFromMedia(FileManagement.StripNotsupportChrInFileName('PriceList_' + NetComCustomerPriceService."Customer No."), '.csv', NetComCustomerPriceService."Document Reference ID".MediaId());

            NetComCustomerPriceService.Export := false;
            NetComCustomerPriceService."Latest Export" := CurrentDateTime;
            NetComCustomerPriceService.Modify();
            Commit();
        end;
    end;
}