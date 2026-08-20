codeunit 50107 "NetCom Inload Service"
{
    trigger OnRun()
    begin
        ExportInloadFiles(false);
    end;

    procedure ExportInloadFiles(ForceGenerateFile: Boolean)
    var
        NetComInloadService: Record "NetCom Inload Service";
        NetComInloadService2: Record "NetCom Inload Service";
        MillisecondsToRemove: BigInteger;
    begin
        NetComInloadService.Reset();
        if NetComInloadService.FindSet() then
            repeat
                case NetComInloadService."Export Interval" of
                    NetComInloadService."Export Interval"::"0 Hours":
                        MillisecondsToRemove := 0;
                    NetComInloadService."Export Interval"::"4 Hours":
                        MillisecondsToRemove := 14400000;
                    NetComInloadService."Export Interval"::"6 Hours":
                        MillisecondsToRemove := 21600000;
                    NetComInloadService."Export Interval"::"8 Hours":
                        MillisecondsToRemove := 28800000;
                    NetComInloadService."Export Interval"::"1 Day":
                        MillisecondsToRemove := 86400000;
                    NetComInloadService."Export Interval"::"2 Days":
                        MillisecondsToRemove := 172800000;
                    NetComInloadService."Export Interval"::"7 Days":
                        MillisecondsToRemove := 604800000;
                end;

                if ExportInloadFile(NetComInloadService, MillisecondsToRemove, ForceGenerateFile) then begin
                    NetComInloadService2.Reset();
                    NetComInloadService2.SetRange("Customer No.", NetComInloadService."Customer No.");
                    if NetComInloadService2.FindFirst() then begin
                        NetComInloadService2.Export := true;
                        NetComInloadService2.Modify(true);
                    end;
                end;
            until NetComInloadService.Next() = 0;
    end;

    local procedure ExportInloadFile(NetComInloadService: Record "NetCom Inload Service"; Milliseconds: BigInteger; ForceGenerateFile: Boolean): Boolean
    var
        Customer: Record Customer;
        NetComInloadService2: Record "NetCom Inload Service";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        CsvBuilder: TextBuilder;
        FileName: Text;
        Duration: Duration;
    begin
        Duration := Milliseconds;
        if not Customer.Get(NetComInloadService."Customer No.") then
            exit(false);

        if ForceGenerateFile or ((CurrentDateTime - Duration) >= NetComInloadService."Latest Export") or (NetComInloadService."Latest Export" = 0DT) then begin
            BuildInloadCsv(CsvBuilder, Customer."No.");

            // Use Windows encoding so Danish characters render correctly in Excel/CSV viewers.
            TempBlob.CreateOutStream(OutStream, TextEncoding::Windows);
            OutStream.WriteText(CsvBuilder.ToText());
            TempBlob.CreateInStream(InStream, TextEncoding::Windows);

            NetComInloadService2.Reset();
            NetComInloadService2.SetRange("Customer No.", NetComInloadService."Customer No.");
            if NetComInloadService2.FindFirst() then begin
                FileName := StrSubstNo(InloadFileNameLbl, NetComInloadService."Customer No.");
                NetComInloadService2."Document Reference ID".ImportStream(InStream, FileName);
                NetComInloadService2.Modify();
                Commit();
            end;

            exit(true);
        end else
            exit(false);
    end;

    local procedure BuildInloadCsv(var CsvBuilder: TextBuilder; CustomerNo: Code[20])
    var
        Item: Record Item;
        NetComWebImpProductData: Record "NetCom Web Imp. Product Data";
        NetComWebImpProductData2: Record "NetCom Web Imp. Product Data";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        NetComCustItemAssortment: Record "NetCom Cust. Item Assortment";
        LineBuilder: TextBuilder;
        SalesText: Text;
        DeliveryText: Text;
        DiscontinuedText: Text;
        BrandText: Text;
        PcsQty: Decimal;
        PackQty: Decimal;
        MinOrderQty: Decimal;
        LengthMm: Decimal;
        WidthMm: Decimal;
        HeightMm: Decimal;
        VolumeDm3: Decimal;
        DiscountPct: Decimal;
        NetPrice: Decimal;
    begin
        Clear(CsvBuilder);
        CsvBuilder.AppendLine(
            'EAN;Varenr.;TEKST30;TEKST60;Produktnavn;Salgstekst;Basisenhed;Forpakning 1;Forpakning 2;Bruttovægt inkl. emballage (kg.);Nettovægt (kg.);Volumen i DM3;Længde(MM) i Emballage;Bredde(MM) i Emballage;Højde(MM) i Emballage;Valuta;Bruttopris;Rabat %;Nettopris;Toldnr.;Oprindelsesland;UNSPSC;Udgået erstattes af;Produktbillede;Leverandør URL;Vejledning;Datablad;Leveringstid;Minimumsbestilling;Ordremultiplum;Brand;Udgået;Miljøafgift');

        NetComCustItemAssortment.Reset();
        NetComCustItemAssortment.SetRange("Customer No.", CustomerNo);
        if NetComCustItemAssortment.FindSet() then
            repeat
                Item.Reset();
                Item.SetAutoCalcFields("NSW Exist as Variant");
                Item.SetRange("No.", NetComCustItemAssortment."Item No.");
                Item.SetFilter(GTIN, '<>%1', '');
                if Item.FindFirst() then begin
                    NetComWebImpProductData.Reset();
                    NetComWebImpProductData.SetRange("Item No.", Item."No.");
                    if Item."NSW Exist as Variant" then
                        NetComWebImpProductData.SetFilter("Webshop Variant ID", '<>%1', 0);
                    if NetComWebImpProductData.FindFirst() then begin
                        SalesText := Item.NetComGetSalesText();
                        PcsQty := GetPcsQuantity(Item, ItemUnitOfMeasure);
                        PackQty := GetPackQuantity(Item, ItemUnitOfMeasure);
                        GetStkDimensions(Item, ItemUnitOfMeasure, LengthMm, WidthMm, HeightMm);
                        VolumeDm3 := CalculateVolumeDm3(LengthMm, WidthMm, HeightMm);
                        DeliveryText := GetExpectedDeliveryText(Item);
                        MinOrderQty := GetMinOrderQuantity(Item);
                        BrandText := NetComWebImpProductData.Brand;
                        DiscontinuedText := GetDiscontinuedText(Item, NetComWebImpProductData);
                        DiscountPct := GetDiscountPct(CustomerNo, Item);
                        NetPrice := Item."Unit Price" * (1 - (DiscountPct / 100));

                        Clear(LineBuilder);
                        AppendCsvField(LineBuilder, Item.GTIN);
                        AppendCsvField(LineBuilder, Item."No.");
                        AppendCsvField(LineBuilder, Format(Item."NetCom Item Name 30"));
                        AppendCsvField(LineBuilder, Format(Item."NetCom Item Name 60"));
                        AppendCsvField(LineBuilder, Item."NetCom Item Name 64");
                        AppendCsvField(LineBuilder, SalesText);
                        AppendCsvField(LineBuilder, Item."Base Unit of Measure");
                        AppendCsvField(LineBuilder, FormatDecimal(PcsQty, 5));
                        AppendCsvField(LineBuilder, FormatDecimal(PackQty, 5));
                        AppendCsvField(LineBuilder, FormatDecimal(Item."Gross Weight", 3));
                        AppendCsvField(LineBuilder, FormatDecimal(Item."Net Weight", 3));
                        AppendCsvField(LineBuilder, FormatDecimal(VolumeDm3, 3));
                        AppendCsvField(LineBuilder, FormatDecimal(LengthMm, 2));
                        AppendCsvField(LineBuilder, FormatDecimal(WidthMm, 2));
                        AppendCsvField(LineBuilder, FormatDecimal(HeightMm, 2));
                        AppendCsvField(LineBuilder, 'DKK');
                        AppendCsvField(LineBuilder, FormatAmount2Decimals(Item."Unit Price"));
                        AppendCsvField(LineBuilder, FormatAmount2Decimals(DiscountPct));
                        AppendCsvField(LineBuilder, FormatAmount2Decimals(NetPrice));
                        AppendCsvField(LineBuilder, Item."Tariff No.");
                        AppendCsvField(LineBuilder, Item."Country/Region of Origin Code");
                        AppendCsvField(LineBuilder, Format(Item."NetCom UNSPSC"));
                        AppendCsvField(LineBuilder, Format(Item."NetCom Expired replaced by"));
                        AppendCsvField(LineBuilder, NetComWebImpProductData."Website Image Link");
                        AppendCsvField(LineBuilder, NetComWebImpProductData."Website Link");
                        AppendCsvField(LineBuilder, Item."NetCom User Manual (URL)");
                        AppendCsvField(LineBuilder, NetComWebImpProductData."Website File Link");
                        AppendCsvField(LineBuilder, DeliveryText);
                        AppendCsvField(LineBuilder, FormatDecimal(MinOrderQty, 2));
                        AppendCsvField(LineBuilder, '1');
                        AppendCsvField(LineBuilder, BrandText);
                        AppendCsvField(LineBuilder, DiscontinuedText);
                        AppendCsvField(LineBuilder, FormatDecimal(Item."NetCom Environmental Tax", 2));

                        CsvBuilder.AppendLine(LineBuilder.ToText());
                    end;
                end;
            until NetComCustItemAssortment.Next() = 0;
    end;

    local procedure GetPcsQuantity(Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure") Quantity: Decimal
    begin
        Clear(Quantity);
        if TryGetItemUnitOfMeasure(Item."No.", 'STK', ItemUnitOfMeasure) then
            exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
        if TryGetItemUnitOfMeasure(Item."No.", 'STK.', ItemUnitOfMeasure) then
            exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    local procedure GetPackQuantity(Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure") Quantity: Decimal
    begin
        Clear(Quantity);
        if TryGetItemUnitOfMeasure(Item."No.", 'PAK', ItemUnitOfMeasure) then
            exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
        if TryGetItemUnitOfMeasure(Item."No.", 'PAKKE', ItemUnitOfMeasure) then
            exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    local procedure GetStkDimensions(Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure"; var LengthMm: Decimal; var WidthMm: Decimal; var HeightMm: Decimal)
    var
        FoundSalesUom: Boolean;
    begin
        LengthMm := 0;
        WidthMm := 0;
        HeightMm := 0;

        if not TryGetItemUnitOfMeasure(Item."No.", 'STK', ItemUnitOfMeasure) then begin
            FoundSalesUom := (Item."Sales Unit of Measure" <> '') and TryGetItemUnitOfMeasure(Item."No.", Item."Sales Unit of Measure", ItemUnitOfMeasure);
            if not FoundSalesUom then
                if not TryGetItemUnitOfMeasure(Item."No.", Item."Base Unit of Measure", ItemUnitOfMeasure) then
                    exit;
        end;

        LengthMm := ItemUnitOfMeasure.Length;
        WidthMm := ItemUnitOfMeasure.Width;
        HeightMm := ItemUnitOfMeasure.Height;
    end;

    local procedure TryGetItemUnitOfMeasure(ItemNo: Code[20]; UomCode: Code[10]; var ItemUnitOfMeasure: Record "Item Unit of Measure"): Boolean
    begin
        ItemUnitOfMeasure.Reset();
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UomCode);
        exit(ItemUnitOfMeasure.FindFirst());
    end;

    local procedure CalculateVolumeDm3(LengthMm: Decimal; WidthMm: Decimal; HeightMm: Decimal): Decimal
    begin
        if (LengthMm = 0) or (WidthMm = 0) or (HeightMm = 0) then
            exit(0);

        exit((LengthMm) * (WidthMm) * (HeightMm));
    end;

    local procedure GetExpectedDeliveryText(var Item: Record Item): Text
    var
        ItemInventory: Decimal;
        BuildableAssemblyQty: Decimal;
    begin
        Item.CalcFields(Inventory, "Assembly BOM");
        ItemInventory := Item.Inventory;

        if Item."Assembly BOM" then begin
            BuildableAssemblyQty := GetBuildableAssemblyQuantity(Item."No.");
            if (ItemInventory + BuildableAssemblyQty) > 0 then
                exit('1D');

            exit(Format(Item."Lead Time Calculation"));
        end;

        if ItemInventory > 0 then
            exit('1D');

        exit(Format(Item."Lead Time Calculation"));
    end;

    local procedure GetBuildableAssemblyQuantity(ParentItemNo: Code[20]): Decimal
    var
        BOMComponent: Record "BOM Component";
        ComponentItem: Record Item;
        ComponentInventory: Decimal;
        ComponentBuildableQty: Decimal;
        MinBuildableQty: Decimal;
        HasInventoryComponent: Boolean;
    begin
        MinBuildableQty := 0;
        HasInventoryComponent := false;

        BOMComponent.Reset();
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        BOMComponent.SetFilter("Quantity per", '>%1', 0);

        if BOMComponent.FindSet() then
            repeat
                if ComponentItem.Get(BOMComponent."No.") then begin
                    ComponentItem.CalcFields(Inventory);
                    ComponentInventory := ComponentItem.Inventory;
                    ComponentBuildableQty := Round(ComponentInventory / BOMComponent."Quantity per", 1, '<');

                    if not HasInventoryComponent then begin
                        MinBuildableQty := ComponentBuildableQty;
                        HasInventoryComponent := true;
                    end else
                        if ComponentBuildableQty < MinBuildableQty then
                            MinBuildableQty := ComponentBuildableQty;
                end;
            until BOMComponent.Next() = 0;

        if not HasInventoryComponent then
            exit(0);

        if MinBuildableQty < 0 then
            exit(0);

        exit(MinBuildableQty);
    end;

    local procedure GetMinOrderQuantity(Item: Record Item): Decimal
    var
        MinOrderQty: Decimal;
    begin
        if TryGetNumericFieldValue(Item, 'NSW Min. Quantity', MinOrderQty) then
            exit(MinOrderQty);

        if TryGetNumericFieldValue(Item, 'Min. Antal', MinOrderQty) then
            exit(MinOrderQty);

        exit(0);
    end;

    local procedure GetDiscontinuedText(Item: Record Item; NetComWebImpProductData: Record "NetCom Web Imp. Product Data"): Text
    var
        Item2: Record Item;
        NetComWebImpProductData2: Record "NetCom Web Imp. Product Data";
        IsVisibleInWebshop: Boolean;
    begin
        if Item."NSW Exist as Variant" then begin
            if not NetComWebImpProductData.Status then
                exit('Udgået');

            Item2.Reset();
            Item2.SetRange("NSW Webshop ID", NetComWebImpProductData."Webshop ID");
            if Item2.FindFirst() then begin
                if TryGetBooleanFieldValue(Item2, 'Synlig i Webshop', IsVisibleInWebshop) then
                    if not IsVisibleInWebshop then
                        exit('Udgået');

                if TryGetBooleanFieldValue(Item2, 'NSW Visible in Webshop', IsVisibleInWebshop) then
                    if not IsVisibleInWebshop then
                        exit('Udgået');

                NetComWebImpProductData2.Reset();
                NetComWebImpProductData2.SetRange("Item No.", Item2."No.");
                NetComWebImpProductData2.SetRange("Webshop ID", NetComWebImpProductData."Webshop ID");
                NetComWebImpProductData2.SetRange("Webshop Variant ID", 0);
                if NetComWebImpProductData2.FindFirst() then begin
                    if not NetComWebImpProductData2.Status then
                        exit('Udgået');

                    if UpperCase(NetComWebImpProductData2.Type) = 'DISCONTINUED' then
                        exit('Udgået');
                end;
            end;
        end else begin
            if TryGetBooleanFieldValue(Item, 'Synlig i Webshop', IsVisibleInWebshop) then
                if not IsVisibleInWebshop then
                    exit('Udgået');

            if TryGetBooleanFieldValue(Item, 'NSW Visible in Webshop', IsVisibleInWebshop) then
                if not IsVisibleInWebshop then
                    exit('Udgået');

            if UpperCase(NetComWebImpProductData.Type) = 'DISCONTINUED' then
                exit('Udgået');
        end;

        exit('');
    end;

    local procedure GetDiscountPct(CustomerNo: Code[20]; Item: Record Item): Decimal
    var
        Customer: Record Customer;
        BestDiscount: Decimal;
    begin
        if not Customer.Get(CustomerNo) then
            exit(0);

        BestDiscount := 0;

        // All Customers
        BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::"All Customers", '', "Price Asset Type"::Item, Item."No.");
        BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::"All Customers", '', "Price Asset Type"::"Item Discount Group", Item."Item Disc. Group");

        // Specific customer
        BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::Customer, CustomerNo, "Price Asset Type"::Item, Item."No.");
        BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::Customer, CustomerNo, "Price Asset Type"::"Item Discount Group", Item."Item Disc. Group");

        // Customer discount group
        if Customer."Customer Disc. Group" <> '' then begin
            BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::"Customer Disc. Group", Customer."Customer Disc. Group", "Price Asset Type"::Item, Item."No.");
            BestDiscount := MaxDiscountFromPriceLine(BestDiscount, "Price Source Type"::"Customer Disc. Group", Customer."Customer Disc. Group", "Price Asset Type"::"Item Discount Group", Item."Item Disc. Group");
        end;

        exit(BestDiscount);
    end;

    local procedure MaxDiscountFromPriceLine(CurrentMax: Decimal; SourceType: Enum "Price Source Type"; SourceNo: Code[20];
                                                                                  AssetType: Enum "Price Asset Type";
                                                                                  AssetNo: Code[20]): Decimal
    var
        PriceListLine: Record "Price List Line";
    begin
        if AssetNo = '' then
            exit(CurrentMax);

        PriceListLine.Reset();
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.SetRange(Status, PriceListLine.Status::Active);
        PriceListLine.SetRange("Source Type", SourceType);
        PriceListLine.SetRange("Source No.", SourceNo);
        PriceListLine.SetRange("Asset Type", AssetType);
        PriceListLine.SetRange("Asset No.", AssetNo);
        PriceListLine.SetFilter("Minimum Quantity", '<=%1', 1);
        PriceListLine.SetFilter("Starting Date", '%1|<=%2', 0D, Today());
        PriceListLine.SetFilter("Ending Date", '%1|>=%2', 0D, Today());

        if PriceListLine.FindSet() then
            repeat
                if PriceListLine."Line Discount %" > CurrentMax then
                    CurrentMax := PriceListLine."Line Discount %";
            until PriceListLine.Next() = 0;

        exit(CurrentMax);
    end;

    local procedure TryGetBooleanFieldValue(RecordVariant: Variant; FieldName: Text; var BooleanValue: Boolean): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.GetTable(RecordVariant);
        if not DataTypeManagement.FindFieldByName(RecordRef, FieldRef, FieldName) then
            exit(false);

        if FieldRef.Type <> FieldRef.Type::Boolean then
            exit(false);

        BooleanValue := FieldRef.Value;
        exit(true);
    end;

    local procedure TryGetNumericFieldValue(RecordVariant: Variant; FieldName: Text; var DecimalValue: Decimal): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldTextValue: Text;
    begin
        RecordRef.GetTable(RecordVariant);
        if not DataTypeManagement.FindFieldByName(RecordRef, FieldRef, FieldName) then
            exit(false);

        case FieldRef.Type of
            FieldRef.Type::Decimal,
            FieldRef.Type::Integer,
            FieldRef.Type::BigInteger:
                begin
                    FieldTextValue := Format(FieldRef.Value);
                    exit(Evaluate(DecimalValue, FieldTextValue));
                end;
        end;

        exit(false);
    end;

    local procedure AppendCsvField(var LineBuilder: TextBuilder; FieldValue: Text)
    begin
        if LineBuilder.Length() > 0 then
            LineBuilder.Append(';');

        LineBuilder.Append('"');
        LineBuilder.Append(FieldValue.Replace('"', '""'));
        LineBuilder.Append('"');
    end;

    local procedure FormatDecimal(Value: Decimal; PrecisionDecimals: Integer): Text
    var
        RoundingPrecision: Decimal;
        FormattedValue: Text;
    begin
        case PrecisionDecimals of
            0:
                RoundingPrecision := 1;
            1:
                RoundingPrecision := 0.1;
            2:
                RoundingPrecision := 0.01;
            3:
                RoundingPrecision := 0.001;
            4:
                RoundingPrecision := 0.0001;
            5:
                RoundingPrecision := 0.00001;
            else
                RoundingPrecision := 0.01;
        end;

        FormattedValue := Format(Round(Value, RoundingPrecision, '='), 0, 9);
        exit(FormattedValue.Replace('.', ','));
    end;

    local procedure FormatAmount2Decimals(Value: Decimal): Text
    var
        FormattedValue: Text;
        DecimalSeparatorPos: Integer;
        DecimalPart: Text;
    begin
        FormattedValue := FormatDecimal(Value, 2);
        DecimalSeparatorPos := StrPos(FormattedValue, ',');

        if DecimalSeparatorPos = 0 then
            exit(FormattedValue + ',00');

        DecimalPart := CopyStr(FormattedValue, DecimalSeparatorPos + 1);
        if StrLen(DecimalPart) = 0 then
            exit(FormattedValue + '00');

        if StrLen(DecimalPart) = 1 then
            exit(FormattedValue + '0');

        if StrLen(DecimalPart) > 2 then
            exit(CopyStr(FormattedValue, 1, DecimalSeparatorPos + 2));

        exit(FormattedValue);
    end;

    var
        InloadFileNameLbl: Label 'Inload_%1.csv', Comment = '%1 = Customer No.';
}