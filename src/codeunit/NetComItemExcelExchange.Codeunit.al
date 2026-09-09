codeunit 50120 "NetCom Item Excel Exchange"
{
    procedure ExportTemplateToExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        CustomerNoFilter: Text;
        ItemNoFilter: Text;
        DownloadInStream: InStream;
        DownloadOutStream: OutStream;
        DownloadFileName: Text;
        WorkbookNameLbl: Label 'NetCom_Item_ExportImport';
        WorksheetNameLbl: Label 'ItemData';
    begin
        if not GetExportFilters(CustomerNoFilter, ItemNoFilter) then
            exit;

        BuildHeader(TempExcelBuffer);
        BuildExportRowsFromAssortmentFilter(TempExcelBuffer, CustomerNoFilter, ItemNoFilter);

        TempExcelBuffer.CreateNewBook(WorksheetNameLbl);
        TempExcelBuffer.WriteSheet(WorksheetNameLbl, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(WorkbookNameLbl);

        TempBlob.CreateOutStream(DownloadOutStream);
        TempExcelBuffer.SaveToStream(DownloadOutStream, true);
        TempBlob.CreateInStream(DownloadInStream);
        DownloadFileName := WorkbookNameLbl + '.xlsx';
        DownloadFromStream(DownloadInStream, '', '', '', DownloadFileName);
    end;

    local procedure GetExportFilters(var CustomerNoFilter: Text; var ItemNoFilter: Text): Boolean
    var
        CustItemAssortmentFilter: Record "NetCom Cust. Item Assortment";
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddRecord(ItemFilterFilterLbl, CustItemAssortmentFilter);
        FilterPageBuilder.AddFieldNo(ItemFilterFilterLbl, CustItemAssortmentFilter.FieldNo("Item No."));
        FilterPageBuilder.AddFieldNo(ItemFilterFilterLbl, CustItemAssortmentFilter.FieldNo("Customer No."));

        if not FilterPageBuilder.RunModal() then
            exit(false);

        CustItemAssortmentFilter.SetView(FilterPageBuilder.GetView(ItemFilterFilterLbl));

        CustomerNoFilter := CustItemAssortmentFilter.GetFilter("Customer No.");
        ItemNoFilter := CustItemAssortmentFilter.GetFilter("Item No.");
        ValidateSingleCustomerFilter(CustomerNoFilter);

        exit(true);
    end;

    local procedure ValidateSingleCustomerFilter(CustomerNoFilter: Text)
    begin
        if CustomerNoFilter = '' then
            Error(CustomerNoRequiredErr);

        if ContainsDisallowedCustomerFilterSyntax(CustomerNoFilter) then
            Error(SingleCustomerOnlyErr);
    end;

    local procedure ContainsDisallowedCustomerFilterSyntax(CustomerNoFilter: Text): Boolean
    begin
        exit(
            (StrPos(CustomerNoFilter, '|') > 0) or
            (StrPos(CustomerNoFilter, '&') > 0) or
            (StrPos(CustomerNoFilter, '..') > 0) or
            (StrPos(CustomerNoFilter, '*') > 0) or
            (StrPos(CustomerNoFilter, '?') > 0) or
            (StrPos(CustomerNoFilter, '<') > 0) or
            (StrPos(CustomerNoFilter, '>') > 0) or
            (StrPos(CustomerNoFilter, '@') > 0));
    end;

    local procedure BuildExportRowsFromAssortmentFilter(var TempExcelBuffer: Record "Excel Buffer" temporary; CustomerNoFilter: Text; ItemNoFilter: Text)
    var
        NetComCustItemAssortment: Record "NetCom Cust. Item Assortment";
        TempNetComCustItemAssortment: Record "NetCom Cust. Item Assortment" temporary;
        Item: Record Item;
        Packaging1Qty: Decimal;
        Packaging2Qty: Decimal;
        LengthValue: Decimal;
        WidthValue: Decimal;
        HeightValue: Decimal;
    begin
        NetComCustItemAssortment.Reset();
        if CustomerNoFilter <> '' then
            NetComCustItemAssortment.SetFilter("Customer No.", CustomerNoFilter);
        if ItemNoFilter <> '' then
            NetComCustItemAssortment.SetFilter("Item No.", ItemNoFilter);

        if NetComCustItemAssortment.FindSet() then
            repeat
                if not TempNetComCustItemAssortment.Get('', NetComCustItemAssortment."Item No.") then begin
                    TempNetComCustItemAssortment.Init();
                    TempNetComCustItemAssortment."Customer No." := '';
                    TempNetComCustItemAssortment."Item No." := NetComCustItemAssortment."Item No.";
                    TempNetComCustItemAssortment.Insert();
                end;
            until NetComCustItemAssortment.Next() = 0;

        TempNetComCustItemAssortment.Reset();
        if TempNetComCustItemAssortment.FindSet() then
            repeat
                if Item.Get(TempNetComCustItemAssortment."Item No.") then begin
                    GetPackagingAndDimensions(Item, Packaging1Qty, Packaging2Qty, LengthValue, WidthValue, HeightValue);
                    BuildItemRow(TempExcelBuffer, Item, Packaging1Qty, Packaging2Qty, LengthValue, WidthValue, HeightValue);
                end;
            until TempNetComCustItemAssortment.Next() = 0;
    end;

    procedure ImportTemplateFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        Item: Record Item;
        TempBlob: Codeunit "Temp Blob";
        UploadInStream: InStream;
        OpenBookInStream: InStream;
        SheetNameInStream: InStream;
        TempBlobOutStream: OutStream;
        FileName: Text;
        SheetName: Text;
        ItemNo: Code[20];
        RowNo: Integer;
        MaxRowNo: Integer;
        UpdatedCount: Integer;
        SkippedCount: Integer;
        ShouldProcessRow: Boolean;
        GrossWeightValue: Decimal;
        NetWeightValue: Decimal;
        Packaging1Qty: Decimal;
        Packaging2Qty: Decimal;
        LengthValue: Decimal;
        WidthValue: Decimal;
        HeightValue: Decimal;
        UploadDialogTitleLbl: Label 'Vælg Excel-fil med varedata';
        UploadFilterLbl: Label 'Excel files (*.xlsx)|*.xlsx';
        ImportFinishedMsg: Label 'Import afsluttet. Opdaterede varer: %1. Sprunget over: %2.', Comment = '%1 = updated count, %2 = skipped count';
    begin
        if not UploadIntoStream(UploadDialogTitleLbl, '', UploadFilterLbl, FileName, UploadInStream) then
            exit;

        TempBlob.CreateOutStream(TempBlobOutStream);
        CopyStream(TempBlobOutStream, UploadInStream);

        TempBlob.CreateInStream(SheetNameInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(SheetNameInStream);

        TempBlob.CreateInStream(OpenBookInStream);
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(OpenBookInStream, SheetName);
        TempExcelBuffer.ReadSheet();

        TempExcelBuffer.Reset();
        if not TempExcelBuffer.FindLast() then
            exit;

        MaxRowNo := TempExcelBuffer."Row No.";

        for RowNo := 2 to MaxRowNo do begin
            ShouldProcessRow := true;

            ItemNo := CopyStr(GetCellText(TempExcelBuffer, RowNo, 1), 1, MaxStrLen(Item."No."));
            if ItemNo = '' then begin
                SkippedCount += 1;
                ShouldProcessRow := false;
            end;

            if ShouldProcessRow and (not Item.Get(ItemNo)) then begin
                SkippedCount += 1;
                ShouldProcessRow := false;
            end;

            if ShouldProcessRow then begin
                Item.Validate("NetCom Item Name 30 (Text)", CopyStr(GetCellText(TempExcelBuffer, RowNo, 2), 1, MaxStrLen(Item."NetCom Item Name 30 (Text)")));
                // Item.Validate("NetCom Item Name 30", CopyStr(GetCellText(TempExcelBuffer, RowNo, 3), 1, MaxStrLen(Item."NetCom Item Name 30")));
                Item."NetCom Item Name 60" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 4), 1, MaxStrLen(Item."NetCom Item Name 60"));
                Item."NetCom Item Name 64" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 5), 1, MaxStrLen(Item."NetCom Item Name 64"));

                GrossWeightValue := ParseDecimalFromCell(TempExcelBuffer, RowNo, 6, GrossWeightColumnLbl);
                NetWeightValue := ParseDecimalFromCell(TempExcelBuffer, RowNo, 7, NetWeightColumnLbl);
                Item.Validate("Gross Weight", GrossWeightValue);
                Item.Validate("Net Weight", NetWeightValue);

                Item."Tariff No." := CopyStr(GetCellText(TempExcelBuffer, RowNo, 8), 1, MaxStrLen(Item."Tariff No."));
                Item."Country/Region of Origin Code" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 9), 1, MaxStrLen(Item."Country/Region of Origin Code"));
                Item."NetCom UNSPSC" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 10), 1, MaxStrLen(Item."NetCom UNSPSC"));
                Item."NetCom Expired replaced by" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 11), 1, MaxStrLen(Item."NetCom Expired replaced by"));
                Item."NetCom User Manual (URL)" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 12), 1, MaxStrLen(Item."NetCom User Manual (URL)"));

                Item.Modify(true);

                Packaging1Qty := ParseDecimalFromCell(TempExcelBuffer, RowNo, 13, Packaging1ColumnLbl);
                Packaging2Qty := ParseDecimalFromCell(TempExcelBuffer, RowNo, 14, Packaging2ColumnLbl);
                LengthValue := ParseDecimalFromCell(TempExcelBuffer, RowNo, 15, LengthColumnLbl);
                WidthValue := ParseDecimalFromCell(TempExcelBuffer, RowNo, 16, WidthColumnLbl);
                HeightValue := ParseDecimalFromCell(TempExcelBuffer, RowNo, 17, HeightColumnLbl);

                UpdatePackagingAndDimensions(Item, Packaging1Qty, Packaging2Qty, LengthValue, WidthValue, HeightValue);
                UpdatedCount += 1;
            end;
        end;

        Message(ImportFinishedMsg, UpdatedCount, SkippedCount);
    end;

    local procedure BuildHeader(var TempExcelBuffer: Record "Excel Buffer" temporary)
    begin
        TempExcelBuffer.NewRow();
        AddExcelTextColumn(TempExcelBuffer, ItemNoColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, ItemName30TextColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, ItemName30ColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, ItemName60ColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, ItemName64ColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, GrossWeightColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, NetWeightColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, TariffColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, OriginCountryColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, UnspscColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, ReplacedByColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, UserManualColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, Packaging1ColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, Packaging2ColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, LengthColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, WidthColumnLbl);
        AddExcelTextColumn(TempExcelBuffer, HeightColumnLbl);
    end;

    local procedure BuildItemRow(var TempExcelBuffer: Record "Excel Buffer" temporary; Item: Record Item; Packaging1Qty: Decimal; Packaging2Qty: Decimal; LengthValue: Decimal; WidthValue: Decimal; HeightValue: Decimal)
    begin
        TempExcelBuffer.NewRow();
        AddExcelTextColumn(TempExcelBuffer, Item."No.");
        AddExcelTextColumn(TempExcelBuffer, Item."NetCom Item Name 30 (Text)");
        AddExcelTextColumn(TempExcelBuffer, Format(Item."NetCom Item Name 30"));
        AddExcelTextColumn(TempExcelBuffer, Format(Item."NetCom Item Name 60"));
        AddExcelTextColumn(TempExcelBuffer, Item."NetCom Item Name 64");
        AddExcelNumberColumn(TempExcelBuffer, Item."Gross Weight");
        AddExcelNumberColumn(TempExcelBuffer, Item."Net Weight");
        AddExcelTextColumn(TempExcelBuffer, Item."Tariff No.");
        AddExcelTextColumn(TempExcelBuffer, Item."Country/Region of Origin Code");
        AddExcelTextColumn(TempExcelBuffer, Format(Item."NetCom UNSPSC"));
        AddExcelTextColumn(TempExcelBuffer, Format(Item."NetCom Expired replaced by"));
        AddExcelTextColumn(TempExcelBuffer, Item."NetCom User Manual (URL)");
        AddExcelNumberColumn(TempExcelBuffer, Packaging1Qty);
        AddExcelNumberColumn(TempExcelBuffer, Packaging2Qty);
        AddExcelNumberColumn(TempExcelBuffer, LengthValue);
        AddExcelNumberColumn(TempExcelBuffer, WidthValue);
        AddExcelNumberColumn(TempExcelBuffer, HeightValue);
    end;

    local procedure AddExcelTextColumn(var TempExcelBuffer: Record "Excel Buffer" temporary; ValueText: Text)
    begin
        TempExcelBuffer.AddColumn(ValueText, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure AddExcelNumberColumn(var TempExcelBuffer: Record "Excel Buffer" temporary; ValueDecimal: Decimal)
    begin
        TempExcelBuffer.AddColumn(ValueDecimal, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetPackagingAndDimensions(Item: Record Item; var Packaging1Qty: Decimal; var Packaging2Qty: Decimal; var LengthValue: Decimal; var WidthValue: Decimal; var HeightValue: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        PcsUomCode: Code[10];
        PackUomCode: Code[10];
    begin
        Packaging1Qty := 0;
        Packaging2Qty := 0;
        LengthValue := 0;
        WidthValue := 0;
        HeightValue := 0;

        PcsUomCode := GetPreferredPcsUomCode(Item);
        if (PcsUomCode <> '') and TryGetItemUnitOfMeasure(Item."No.", PcsUomCode, ItemUnitOfMeasure) then begin
            Packaging1Qty := ItemUnitOfMeasure."Qty. per Unit of Measure";
            LengthValue := ItemUnitOfMeasure.Length;
            WidthValue := ItemUnitOfMeasure.Width;
            HeightValue := ItemUnitOfMeasure.Height;
        end;

        PackUomCode := GetPreferredPackUomCode(Item);
        if (PackUomCode <> '') and TryGetItemUnitOfMeasure(Item."No.", PackUomCode, ItemUnitOfMeasure) then
            Packaging2Qty := ItemUnitOfMeasure."Qty. per Unit of Measure";
    end;

    local procedure UpdatePackagingAndDimensions(Item: Record Item; Packaging1Qty: Decimal; Packaging2Qty: Decimal; LengthValue: Decimal; WidthValue: Decimal; HeightValue: Decimal)
    var
        PcsUomCode: Code[10];
        PackUomCode: Code[10];
    begin
        PcsUomCode := GetPreferredPcsUomCode(Item);
        if PcsUomCode <> '' then
            UpdateItemUnitOfMeasure(Item."No.", PcsUomCode, Packaging1Qty, LengthValue, WidthValue, HeightValue, true);

        if Packaging2Qty > 0 then begin
            PackUomCode := GetPreferredPackUomCode(Item);
            if PackUomCode = '' then
                PackUomCode := EnsurePackItemUnitOfMeasure(Item);
            if PackUomCode <> '' then
                UpdateItemUnitOfMeasure(Item."No.", PackUomCode, Packaging2Qty, 0, 0, 0, false);
        end;
    end;

    local procedure EnsurePackItemUnitOfMeasure(Item: Record Item): Code[10]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if TryGetItemUnitOfMeasure(Item."No.", 'PAK', ItemUnitOfMeasure) then
            exit('PAK');
        if TryGetItemUnitOfMeasure(Item."No.", 'PAKKE', ItemUnitOfMeasure) then
            exit('PAKKE');

        if UnitOfMeasure.Get('PAK') then begin
            CreateItemUnitOfMeasure(Item."No.", 'PAK');
            exit('PAK');
        end;

        if UnitOfMeasure.Get('PAKKE') then begin
            CreateItemUnitOfMeasure(Item."No.", 'PAKKE');
            exit('PAKKE');
        end;

        exit('');
    end;

    local procedure CreateItemUnitOfMeasure(ItemNo: Code[20]; UomCode: Code[10])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if TryGetItemUnitOfMeasure(ItemNo, UomCode, ItemUnitOfMeasure) then
            exit;

        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", ItemNo);
        ItemUnitOfMeasure.Validate(Code, UomCode);
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", 1);
        ItemUnitOfMeasure.Insert(true);
    end;

    local procedure UpdateItemUnitOfMeasure(ItemNo: Code[20]; UomCode: Code[10]; QtyPerUom: Decimal; LengthValue: Decimal; WidthValue: Decimal; HeightValue: Decimal; UpdateDimensions: Boolean)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if not TryGetItemUnitOfMeasure(ItemNo, UomCode, ItemUnitOfMeasure) then
            exit;

        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUom);
        if UpdateDimensions then begin
            ItemUnitOfMeasure.Validate(Length, LengthValue);
            ItemUnitOfMeasure.Validate(Width, WidthValue);
            ItemUnitOfMeasure.Validate(Height, HeightValue);
        end;

        ItemUnitOfMeasure.Modify(true);
    end;

    local procedure GetPreferredPcsUomCode(Item: Record Item): Code[10]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if TryGetItemUnitOfMeasure(Item."No.", 'STK', ItemUnitOfMeasure) then
            exit('STK');
        if TryGetItemUnitOfMeasure(Item."No.", 'STK.', ItemUnitOfMeasure) then
            exit('STK.');
        if (Item."Sales Unit of Measure" <> '') and TryGetItemUnitOfMeasure(Item."No.", Item."Sales Unit of Measure", ItemUnitOfMeasure) then
            exit(Item."Sales Unit of Measure");
        if (Item."Base Unit of Measure" <> '') and TryGetItemUnitOfMeasure(Item."No.", Item."Base Unit of Measure", ItemUnitOfMeasure) then
            exit(Item."Base Unit of Measure");

        exit('');
    end;

    local procedure GetPreferredPackUomCode(Item: Record Item): Code[10]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if TryGetItemUnitOfMeasure(Item."No.", 'PAK', ItemUnitOfMeasure) then
            exit('PAK');
        if TryGetItemUnitOfMeasure(Item."No.", 'PAKKE', ItemUnitOfMeasure) then
            exit('PAKKE');

        exit('');
    end;

    local procedure TryGetItemUnitOfMeasure(ItemNo: Code[20]; UomCode: Code[10]; var ItemUnitOfMeasure: Record "Item Unit of Measure"): Boolean
    begin
        ItemUnitOfMeasure.Reset();
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UomCode);
        exit(ItemUnitOfMeasure.FindFirst());
    end;

    local procedure ParseDecimalFromCell(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer; ColumnCaption: Text): Decimal
    var
        CellText: Text;
        ParsedValue: Decimal;
    begin
        CellText := DelChr(GetCellText(TempExcelBuffer, RowNo, ColNo), '<>', ' ');
        if CellText = '' then
            exit(0);

        if TryParseDecimal(CellText, ParsedValue) then
            exit(ParsedValue);

        Error(InvalidDecimalErr, RowNo, ColumnCaption, CellText);
    end;

    local procedure TryParseDecimal(ValueText: Text; var ParsedValue: Decimal): Boolean
    var
        NormalizedText: Text;
    begin
        if Evaluate(ParsedValue, ValueText) then
            exit(true);

        NormalizedText := ValueText.Replace(',', '.');
        if Evaluate(ParsedValue, NormalizedText) then
            exit(true);

        NormalizedText := ValueText.Replace('.', '');
        NormalizedText := NormalizedText.Replace(',', '.');
        if Evaluate(ParsedValue, NormalizedText) then
            exit(true);

        NormalizedText := ValueText.Replace(',', '');
        if Evaluate(ParsedValue, NormalizedText) then
            exit(true);

        exit(false);
    end;

    local procedure GetCellText(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    var
        CellValue: Text;
        CellName: Text;
        BufferFallbackValue: Text;
    begin
        CellName := GetCellName(RowNo, ColNo);
        CellValue := ExcelBuffer.GetValueByCellName(CellName);

        if StrLen(CellValue) >= 250 then begin
            BufferFallbackValue := GetCellTextFromBuffer(ExcelBuffer, RowNo, ColNo);
            if StrLen(BufferFallbackValue) > StrLen(CellValue) then
                CellValue := BufferFallbackValue;
        end;

        if CellValue <> '' then
            exit(CellValue);

        BufferFallbackValue := GetCellTextFromBuffer(ExcelBuffer, RowNo, ColNo);
        if BufferFallbackValue <> '' then
            exit(BufferFallbackValue);

        exit('');
    end;

    local procedure GetCellTextFromBuffer(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    var
        CellValue: Text;
    begin
        if not ExcelBuffer.Get(RowNo, ColNo) then
            exit('');

        CellValue := ExcelBuffer."Cell Value as Text";

        if ExcelBuffer.Formula <> '' then
            CellValue += ExcelBuffer.Formula;
        if ExcelBuffer.Formula2 <> '' then
            CellValue += ExcelBuffer.Formula2;
        if ExcelBuffer.Formula3 <> '' then
            CellValue += ExcelBuffer.Formula3;
        if (ExcelBuffer.Comment <> '') and (StrLen(CellValue) < 250) then
            CellValue += ExcelBuffer.Comment;

        exit(CellValue);
    end;

    local procedure GetCellName(RowNo: Integer; ColNo: Integer): Text
    begin
        exit(GetColumnLetters(ColNo) + Format(RowNo));
    end;

    local procedure GetColumnLetters(ColNo: Integer): Text
    var
        Letters: Text;
        Remainder: Integer;
    begin
        if ColNo <= 0 then
            exit('');

        while ColNo > 0 do begin
            Remainder := (ColNo - 1) mod 26;
            Letters := Format(GetAsciiCharacter(65 + Remainder)) + Letters;
            ColNo := (ColNo - 1) div 26;
        end;

        exit(Letters);
    end;

    local procedure GetAsciiCharacter(CharCode: Integer): Char
    var
        AsciiChar: Char;
    begin
        AsciiChar := CharCode;
        exit(AsciiChar);
    end;

    var
        ItemFilterFilterLbl: Label 'Varer';
        ItemNoColumnLbl: Label 'Varenr.';
        ItemName30TextColumnLbl: Label 'Varenavn 30 (tekst)';
        ItemName30ColumnLbl: Label 'Varenavn 30';
        ItemName60ColumnLbl: Label 'Varenavn 60';
        ItemName64ColumnLbl: Label 'Varenavn 64';
        GrossWeightColumnLbl: Label 'Bruttovægt inkl. emballage';
        NetWeightColumnLbl: Label 'Nettovægt';
        TariffColumnLbl: Label 'Tariff nr.';
        OriginCountryColumnLbl: Label 'Oprindelsesland';
        UnspscColumnLbl: Label 'UNSPSC';
        ReplacedByColumnLbl: Label 'Udgået erstattes af';
        UserManualColumnLbl: Label 'Brugermanual (URL)';
        Packaging1ColumnLbl: Label 'Forpakning 1';
        Packaging2ColumnLbl: Label 'Forpakning 2';
        LengthColumnLbl: Label 'Længde';
        WidthColumnLbl: Label 'Bredde';
        HeightColumnLbl: Label 'Højde';
        CustomerNoRequiredErr: Label 'Du skal angive et debitornr. i filteret.';
        SingleCustomerOnlyErr: Label 'Der må kun filtreres på ét debitornr.';
        InvalidDecimalErr: Label 'Ugyldig talværdi på række %1 i kolonnen %2: %3.', Comment = '%1 = row no, %2 = column caption, %3 = raw cell value';
}
