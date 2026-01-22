codeunit 50105 "NetCom Scan Functions"
{
    procedure ScanItem(Variant: Variant; ScannedItemNo: Code[100]; var SerialNoRequired: Boolean; RegisterScan: Boolean) ItemNo: Code[20];
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        LineItemNo: Code[20];
        Msg001Lbl: Label 'Item not found!';
        Msg002Lbl: Label 'STOP! - You scanned wrong Item!';
    begin
        ItemNo := '';
        LineItemNo := '';
        Clear(RecordRef);

        if Variant.IsRecord then begin
            RecordRef.GetTable(Variant);
            case RecordRef.Number of
                Database::"Sales Line",
                Database::"Service Line",
                Database::"Purchase Line":
                    begin
                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'No.');
                        LineItemNo := FieldRef.Value;
                    end;
            end;
        end;

        if ScannedItemNo <> '' then begin
            Item.Reset();
            Item.SetCurrentKey(GTIN);
            Item.SetRange(GTIN, ScannedItemNo);
            if Item.FindFirst() then
                if Item."No." = LineItemNo then
                    ItemNo := Item."No."
                else begin
                    Message(Msg002Lbl);
                    Error('');
                end;
        end;

        if ItemNo <> '' then begin
            ItemReference.Reset();
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Reference No.", ScannedItemNo);
            if ItemReference.FindFirst() then
                if ItemReference."Item No." = LineItemNo then
                    ItemNo := ItemReference."Item No."
                else begin
                    Message(Msg002Lbl);
                    Error('');
                end;
        end;

        if ItemNo = '' then begin
            ItemReference.Reset();
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
            ItemReference.SetRange("Reference No.", ScannedItemNo);
            if ItemReference.FindFirst() then
                if ItemReference."Item No." = LineItemNo then
                    ItemNo := ItemReference."Item No."
                else begin
                    Message(Msg002Lbl);
                    Error('');
                end;
        end;

        if ItemNo = '' then begin
            Item.Reset();
            Item.SetCurrentKey("Vendor Item No.");
            Item.SetRange("Vendor Item No.", ScannedItemNo);
            if Item.FindFirst() then
                if Item."No." = LineItemNo then
                    ItemNo := Item."No."
                else begin
                    Message(Msg002Lbl);
                    Error('');
                end;
        end;

        if ItemNo = '' then begin
            Item.Reset();
            if Item.Get(ScannedItemNo) then
                if (Item."No." = LineItemNo) or (LineItemNo = '') then
                    ItemNo := Item."No."
                else begin
                    Message(Msg002Lbl);
                    Error('');
                end;
        end;

        if ItemNo = '' then
            Message(Msg001Lbl)
        else
            if Item.Get(ItemNo) then
                if Item."Item Tracking Code" <> '' then
                    SerialNoRequired := true
                else
                    SerialNoRequired := false;

        if (ItemNo <> '') and (SerialNoRequired = false) then
            CreateScan(Variant, ItemNo, ScannedItemNo, '', '', 1, RegisterScan);
        // CalculateScanned(Variant);
    end;

    procedure CreateScan(Variant: Variant; ItemNo: Code[20]; ScannedItemNo: Code[100]; SerialNo: Code[50]; ScannedSerialNo: Code[2048]; Quantity: Decimal; RegisterScan: Boolean)
    var
        SalesLine: Record "Sales Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        DocType: Enum "Sales Document Type";
        DocumentNo: Code[100];
        LineNo: Integer;
        TableId: Integer;
        Msg001Lbl: Label 'Scan not registered!';
    begin
        DocumentNo := '';
        LineNo := 0;
        DocType := DocType::Quote;

        Clear(RecordRef);

        if Variant.IsRecord then begin
            RecordRef.GetTable(Variant);
            case RecordRef.Number of
                Database::"Sales Line",
                Database::"Service Line",
                Database::"Purchase Line":
                    begin
                        // SalesLine.Get(RecordRef.RecordId);
                        // ItemNo := RecordRef.Field(6);

                        TableId := RecordRef.Number;

                        if ItemNo = '' then begin
                            DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'No.');
                            ItemNo := FieldRef.Value;
                        end;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document Type');
                        DocType := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document No.');
                        DocumentNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Line No.');
                        LineNo := FieldRef.Value;

                        // DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Location Code');
                        // LocationCode := FieldRef.Value;
                    end;
            end;
        end;

        if RegisterScan then
            if DocumentNo <> '' then begin
                if TableId = Database::"Sales Line" then begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", DocType);
                    SalesLine.SetRange("Document No.", DocumentNo);
                    SalesLine.SetRange("Line No.", LineNo);
                    if SalesLine.FindFirst() then begin
                        SalesLine.Validate("NetCom Scanned Qty.", SalesLine."NetCom Scanned Qty." + Quantity);
                        SalesLine.Modify(true);

                        RegisterSerialNo(SalesLine, Quantity, SerialNo);
                    end else begin
                        Message(Msg001Lbl);
                        Error('');
                    end;
                end;
            end else begin
                Message(Msg001Lbl);
                Error('');
            end;
    end;

    procedure ScanSerialNo(Variant: Variant; ItemNo: Code[20]; ScannedItemNo: Code[100]; ScannedSerialNo: Code[2048]; SerialNos: List of [Code[50]]; RegisterScan: Boolean) QuickEntry: Boolean
    var
        SerialNumber: Code[50];
        SerialNo: Code[50];
        i: Integer;
        counter: Integer;
        CharPos: Integer;
        FindValue: Boolean;
        Err001Lbl: Label 'You have to scan Item No. before scanning Serial No.!';
    begin
        QuickEntry := true;

        if ItemNo = '' then
            Error(Err001Lbl);

        if StrLen(ScannedSerialNo) > 50 then begin
            QuickEntry := false;

            //Træk serienumre ud og put i liste
            for i := 1 to StrLen(ScannedSerialNo) do begin
                FindValue := false;

                if CopyStr(ScannedSerialNo, i, 1) = ',' then begin
                    counter := counter + 1;

                    if counter >= 6 then
                        FindValue := true;

                    if FindValue then begin
                        CharPos := StrPos(CopyStr(ScannedSerialNo, i + 1), ',');

                        if CharPos = 0 then
                            CharPos := StrLen(ScannedSerialNo);


                        SerialNumber := CopyStr(CopyStr(ScannedSerialNo, i + 1, CharPos - 1), 1, 50);

                        //Insert Serial No in list if not omitted.
                        if not SerialNos.Contains(SerialNumber) then
                            SerialNos.Add(SerialNumber);
                    end;
                end;
            end;
        end else
            if not SerialNos.Contains(CopyStr(ScannedSerialNo, 1, 50)) then
                SerialNos.Add(CopyStr(ScannedSerialNo, 1, 50));

        foreach SerialNo in SerialNos do
            CreateScan(Variant, ItemNo, ScannedItemNo, SerialNo, ScannedSerialNo, 1, RegisterScan);
    end;

    local procedure RegisterSerialNo(Variant: Variant; Quantity: Decimal; SerialNo: Code[50])
    var
        SalesLine: Record "Sales Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        DocType: Enum "Sales Document Type";
        DocumentNo: Code[100];
        LineNo: Integer;
        TableId: Integer;
    begin

        if SerialNo <> '' then begin
            Clear(RecordRef);

            if Variant.IsRecord then begin
                RecordRef.GetTable(Variant);
                case RecordRef.Number of
                    Database::"Sales Line",
                    Database::"Service Line",
                    Database::"Purchase Line":
                        begin
                            TableId := RecordRef.Number;

                            DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document Type');
                            DocType := FieldRef.Value;

                            DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document No.');
                            DocumentNo := FieldRef.Value;

                            DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Line No.');
                            LineNo := FieldRef.Value;
                        end;
                end;
            end;

            case TableId of
                Database::"Sales Line":
                    //if SalesLine.Get(SalesLine."Document Type"::Order, Rec."Table Reference", Rec."Table Reference ID") then
                    if SalesLine.Get(DocType, DocumentNo, LineNo) then
                        InsertUpdateReservationEntry(SalesLine, Quantity, SerialNo, false);
            // Database::"Purchase Line":
            //if PurchaseLine.Get(PurchaseLine."Document Type"::Order, Rec."Table Reference", Rec."Table Reference ID") then
            // if PurchaseLine.Get(Rec."Table Sales/Purch Doc Type", Rec."Table Reference", Rec."Table Reference ID") then
            //     InsertUpdateReservationEntry(PurchaseLine, Delete);
            end;
        end;
    end;

    procedure InsertUpdateReservationEntry(Variant: Variant; Quantity: Decimal; SerialNo: Code[50]; Delete: Boolean)
    var
        ReservationEntry: Record "Reservation Entry";
        CheckReservationEntry: Record "Reservation Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        TableNo: Integer;
        SourceSubType: Integer;
        LineNo: Integer;
        ItemLedgerEntryQty: Decimal;
        ReservationEntryQty: Decimal;
        ItemNo: Code[20];
        DocumentNo: Code[20];
        JournalBatchName: Code[20];
        LocationCode: Code[20];
        ReservationEntryDate: Date;
        Msg001Lbl: Label 'Serial No. %1 is not disponible in BC!\\Scan interrupted!', Comment = '%1 = Serial No.';
        Msg002Lbl: Label 'Serial No. %1 is already scanned on Purchase Order %2 in BC!\\Scan interrupted!', Comment = '%1 = Serial No., %2 = Purchase Order No.';
    begin
        Clear(RecordRef);

        if Variant.IsRecord then begin
            RecordRef.GetTable(Variant);
            case RecordRef.Number of
                Database::"Sales Line",
                Database::"Purchase Line":
                    begin
                        TableNo := RecordRef.Number;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document Type');
                        SourceSubType := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'No.');
                        ItemNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Document No.');
                        DocumentNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Line No.');
                        LineNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Location Code');
                        LocationCode := FieldRef.Value;

                        if TableNo = Database::"Sales Line" then begin
                            DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Shipment Date');
                            ReservationEntryDate := FieldRef.Value;
                        end else
                            if TableNo = Database::"Purchase Line" then begin
                                DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Expected Receipt Date');
                                ReservationEntryDate := FieldRef.Value;
                            end;
                    end;
                Database::"Item Journal Line":
                    begin
                        TableNo := RecordRef.Number;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Entry Type');
                        SourceSubType := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Item No.');
                        ItemNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Journal Template Name');
                        DocumentNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Journal Batch Name');
                        JournalBatchName := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Line No.');
                        LineNo := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Location Code');
                        LocationCode := FieldRef.Value;

                        DataTypeManagement.FindFieldByName(RecordRef, FieldRef, 'Posting Date');
                        ReservationEntryDate := FieldRef.Value;
                    end;
            end;
        end;

        // if Delete then begin
        //     ReservationEntry.Reset();
        //     ReservationEntry.SETRANGE("Source Type", TableNo);
        //     ReservationEntry.SETRANGE("Source Subtype", SourceSubType);
        //     ReservationEntry.SETRANGE("Source ID", DocumentNo);
        //     ReservationEntry.SetRange("Source Batch Name", JournalBatchName);
        //     ReservationEntry.SETRANGE("Source Ref. No.", LineNo);
        //     ReservationEntry.SETRANGE("Serial No.", SerialNo);
        //     if ReservationEntry.FindFirst() then
        //         if ((TableNo = Database::"Sales Line") and (SourceSubType = 1)) or
        //             ((TableNo = Database::"Purchase Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
        //             (TableNo = Database::"Item Journal Line") then begin
        //             if ReservationEntry.Quantity = -xRec.Quantity then
        //                 ReservationEntry.Delete(true)
        //             else begin
        //                 ReservationEntry.Validate(Quantity, ReservationEntry.Quantity + xRec.Quantity);
        //                 ReservationEntry.Modify(true);
        //             end;
        //         end else
        //             if ((TableNo = Database::"Sales Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
        //                 ((TableNo = Database::"Purchase Line") and ((SourceSubType = 1))) then
        //                 if ReservationEntry.Quantity = xRec.Quantity then
        //                     ReservationEntry.Delete(true)
        //                 else begin
        //                     ReservationEntry.Validate(Quantity, ReservationEntry.Quantity - xRec.Quantity);
        //                     ReservationEntry.Modify(true);
        //                 end;
        // end else begin
        ItemLedgerEntryQty := 0;
        ReservationEntryQty := 0;

        if ((TableNo = Database::"Sales Line") and (SourceSubType = 1)) //or
             then begin //(TableNo = Database::"Item Journal Line") //310522
            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetCurrentKey("Serial No.");
            ItemLedgerEntry.SetRange("Serial No.", SerialNo);
            ItemLedgerEntry.SetRange("Item No.", ItemNo);
            ItemLedgerEntry.SetRange("Location Code", LocationCode);
            if ItemLedgerEntry.FindSet() then begin
                //ItemLedgerEntry.CalcSums(Quantity);
                //ItemLedgerEntryQty := ItemLedgerEntry.Quantity;
                ItemLedgerEntry.CalcSums("Remaining Quantity");
                ItemLedgerEntryQty := ItemLedgerEntry."Remaining Quantity";
            end;

            CheckReservationEntry.Reset();
            CheckReservationEntry.SetCurrentKey("Serial No.");
            CheckReservationEntry.SetRange("Item No.", ItemNo);
            CheckReservationEntry.SetRange("Serial No.", SerialNo);
            CheckReservationEntry.SetRange("Location Code", LocationCode);
            CheckReservationEntry.SetFilter(Quantity, '<%1', 0);
            if CheckReservationEntry.FindSet() then begin
                CheckReservationEntry.CalcSums(Quantity);
                ReservationEntryQty := CheckReservationEntry.Quantity;
            end;

            // if (ItemLedgerEntryQty + ReservationEntryQty - Quantity) < 0 then begin
            //     Message(Msg001Lbl, SerialNo);
            //     Error('');
            // end;
        end else
            if ((TableNo = Database::"Sales Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
                (TableNo = Database::"Purchase Line") then begin
                CheckReservationEntry.Reset();
                CheckReservationEntry.SetCurrentKey("Serial No.");
                CheckReservationEntry.SetRange("Serial No.", SerialNo);
                CheckReservationEntry.SetRange("Item No.", ItemNo);
                CheckReservationEntry.SetRange("Source Type", TableNo);
                CheckReservationEntry.SetRange("Source Subtype", 1);
                if CheckReservationEntry.FindFirst() then begin
                    Message(Msg002Lbl, SerialNo, CheckReservationEntry."Source ID");
                    Error('');
                end;
            end;

        ReservationEntry.Reset();
        ReservationEntry.SetRange("Source Type", TableNo);
        ReservationEntry.SetRange("Source Subtype", SourceSubType);
        ReservationEntry.SetRange("Source ID", DocumentNo);
        ReservationEntry.SetRange("Source Batch Name", JournalBatchName);
        ReservationEntry.SetRange("Source Ref. No.", LineNo);
        ReservationEntry.SetRange("Serial No.", SerialNo);
        if ReservationEntry.FindFirst() then begin
            if ((TableNo = Database::"Sales Line") and (SourceSubType = 1)) or
                ((TableNo = Database::"Purchase Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
                (TableNo = Database::"Item Journal Line") then
                ReservationEntry.Validate("Quantity (Base)", ReservationEntry.Quantity - Quantity)
            else
                if ((TableNo = Database::"Sales Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
                    ((TableNo = Database::"Purchase Line") and ((SourceSubType = 1))) then
                    ReservationEntry.Validate("Quantity (Base)", ReservationEntry.Quantity + Quantity);
            ReservationEntry.Modify(true);
        end else begin
            ReservationEntry.Init();
            ReservationEntry.Validate("Entry No.", 0);
            ReservationEntry.Validate("Item No.", ItemNo);
            if ((TableNo = Database::"Sales Line") and (SourceSubType = 1)) or
                ((TableNo = Database::"Purchase Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
                ((TableNo = Database::"Item Journal Line") and ((SourceSubType = 1) or (SourceSubType = 3) or (SourceSubType = 4))) then begin
                ReservationEntry.Validate("Quantity (Base)", -Quantity);
                ReservationEntry.Validate(Positive, false);
                ReservationEntry.Validate("Shipment Date", ReservationEntryDate);
            end else
                if ((TableNo = Database::"Sales Line") and ((SourceSubType = 3) or (SourceSubType = 5))) or
                    ((TableNo = Database::"Purchase Line") and ((SourceSubType = 1))) or
                    ((TableNo = Database::"Item Journal Line") and ((SourceSubType = 0) or (SourceSubType = 2))) then begin
                    ReservationEntry.Validate("Quantity (Base)", Quantity);
                    ReservationEntry.Validate(Positive, true);
                    ReservationEntry.Validate("Expected Receipt Date", ReservationEntryDate);
                end;
            ReservationEntry.Validate("Source Type", TableNo);
            ReservationEntry.Validate("Source Subtype", SourceSubType);
            ReservationEntry.Validate("Location Code", LocationCode);
            ReservationEntry.Validate("Source ID", DocumentNo);
            ReservationEntry.Validate("Source Batch Name", JournalBatchName);
            ReservationEntry.Validate("Source Ref. No.", LineNo);
            ReservationEntry.Validate("Creation Date", WorkDate());
            ReservationEntry.Validate("Serial No.", SerialNo);
            if TableNo = Database::"Item Journal Line" then
                ReservationEntry.Validate("New Serial No.", SerialNo);

            if SerialNo <> '' then
                ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Serial No.");
            ReservationEntry."Created By" := CopyStr(UserId, 1, MaxStrLen(ReservationEntry."Created By"));
            if TableNo = Database::"Item Journal Line" then
                ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Prospect)
            else
                ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Surplus);
            ReservationEntry.Insert(true);
        end;
        // end;
    end;

    procedure CheckScannedProducts(inSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Err001Lbl: Label 'Item %1 (%2) is not scanned!', Comment = '%1 = Item No., %2 = Description';
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", inSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", inSalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Qty. to Ship", '>0');
        if SalesLine.FindSet() then
            repeat
                if Item.Get(SalesLine."No.") then
                    if Item.GTIN <> '' then
                        if SalesLine."NetCom Scanned Qty." = 0 then
                            Error(Err001Lbl, SalesLine."No.", SalesLine.Description);
            until SalesLine.Next() = 0;
    end;
}