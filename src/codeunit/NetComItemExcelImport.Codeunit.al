codeunit 50109 "NetCom Item Excel Import"
{
    procedure ImportItemDataFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        Item: Record Item;
        NetComCustItemAssortment: Record "NetCom Cust. Item Assortment";
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        UploadInStream: InStream;
        SheetNameInStream: InStream;
        OpenBookInStream: InStream;
        TempBlobOutStream: OutStream;
        FileName: Text;
        SheetName: Text;
        ItemNo: Code[20];
        GTIN: Code[50];
        SalesText: Text;
        RowNo: Integer;
        MaxRowNo: Integer;
        UpdatedCount: Integer;
        SkippedCount: Integer;
        ShouldProcessRow: Boolean;
        SalesTextByRow: Dictionary of [Integer, Text];
        UploadDialogTitleLbl: Label 'Vaelg Excel-fil med varedata';
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

        // Read Sales Text (column F) directly from XLSX XML to avoid 250-char truncation.
        LoadSalesTextByRowFromXlsx(DataCompression, TempBlob, SheetName, SalesTextByRow);

        TempExcelBuffer.Reset();
        if not TempExcelBuffer.FindLast() then
            exit;

        MaxRowNo := TempExcelBuffer."Row No.";

        for RowNo := 2 to MaxRowNo do begin
            ShouldProcessRow := true;
            ItemNo := CopyStr(GetCellText(TempExcelBuffer, RowNo, 2), 1, MaxStrLen(Item."No."));

            if ItemNo <> '' then
                if not Item.Get(ItemNo) then begin
                    SkippedCount += 1;
                    ShouldProcessRow := false;
                end;

            if ShouldProcessRow and (ItemNo = '') then begin
                GTIN := CopyStr(GetCellText(TempExcelBuffer, RowNo, 1), 1, MaxStrLen(Item.GTIN));
                if GTIN = '' then begin
                    SkippedCount += 1;
                    ShouldProcessRow := false;
                end;

                if ShouldProcessRow then begin
                    Item.Reset();
                    Item.SetRange(GTIN, GTIN);
                    if not Item.FindFirst() then begin
                        SkippedCount += 1;
                        ShouldProcessRow := false;
                    end;
                end;
            end;

            if ShouldProcessRow then begin
                Item."NetCom Item Name 30" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 3), 1, MaxStrLen(Item."NetCom Item Name 30"));
                Item."NetCom Item Name 60" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 4), 1, MaxStrLen(Item."NetCom Item Name 60"));
                Item."NetCom Item Name 64" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 5), 1, MaxStrLen(Item."NetCom Item Name 64"));
                Item."NetCom UNSPSC" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 17), 1, MaxStrLen(Item."NetCom UNSPSC"));
                Item."NetCom Expired replaced by" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 18), 1, MaxStrLen(Item."NetCom Expired replaced by"));
                // Item."NetCom User Manual (URL)" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 19), 1, MaxStrLen(Item."NetCom User Manual (URL)"));
                // Item."NetCom Data Sheet (URL)" := CopyStr(GetCellText(TempExcelBuffer, RowNo, 20), 1, MaxStrLen(Item."NetCom Data Sheet (URL)"));
                Item.Modify(true);

                if not SalesTextByRow.Get(RowNo, SalesText) then
                    SalesText := GetCellText(TempExcelBuffer, RowNo, 6);
                // Column F can contain HTML and is stored unchanged in the blob field.
                SalesText := NormalizeLineBreaks(SalesText);
                Item.NetComSetSalesText(SalesText);

                NetComCustItemAssortment.Reset();
                NetComCustItemAssortment.SetRange("Item No.", Item."No.");
                NetComCustItemAssortment.SetRange("Customer No.", '70280000');
                if NetComCustItemAssortment.IsEmpty then begin
                    NetComCustItemAssortment.Init();
                    NetComCustItemAssortment."Customer No." := '70280000';
                    NetComCustItemAssortment."Item No." := Item."No.";
                    NetComCustItemAssortment.Insert();
                end;

                UpdatedCount += 1;
            end;
        end;

        Message(ImportFinishedMsg, UpdatedCount, SkippedCount);
    end;

    local procedure LoadSalesTextByRowFromXlsx(var DataCompression: Codeunit "Data Compression"; var SourceBlob: Codeunit "Temp Blob"; SheetName: Text; var SalesTextByRow: Dictionary of [Integer, Text])
    var
        SheetXmlBlob: Codeunit "Temp Blob";
        SharedStringsBlob: Codeunit "Temp Blob";
        SharedStringsByIndex: Dictionary of [Integer, Text];
        SheetXmlText: Text;
        SharedStringsXmlText: Text;
        WorksheetEntryName: Text;
    begin
        DataCompression.OpenZipArchive(SourceBlob, false);

        WorksheetEntryName := ResolveWorksheetEntryName(DataCompression, SheetName);
        if WorksheetEntryName = '' then
            WorksheetEntryName := 'xl/worksheets/sheet1.xml';

        if DataCompression.ExtractEntry('xl/sharedStrings.xml', SharedStringsBlob) > 0 then begin
            SharedStringsXmlText := ReadTempBlobAsText(SharedStringsBlob);
            ParseSharedStrings(SharedStringsXmlText, SharedStringsByIndex);
        end;

        if DataCompression.ExtractEntry(WorksheetEntryName, SheetXmlBlob) > 0 then begin
            SheetXmlText := ReadTempBlobAsText(SheetXmlBlob);
            ParseSheetForSalesText(SheetXmlText, SharedStringsByIndex, SalesTextByRow);
        end;

        DataCompression.CloseZipArchive();
    end;

    local procedure ResolveWorksheetEntryName(var DataCompression: Codeunit "Data Compression"; SheetName: Text): Text
    var
        WorkbookBlob: Codeunit "Temp Blob";
        WorkbookRelsBlob: Codeunit "Temp Blob";
        WorkbookXml: Text;
        WorkbookRelsXml: Text;
        SheetTag: Text;
        RelationshipId: Text;
        TargetPath: Text;
    begin
        if DataCompression.ExtractEntry('xl/workbook.xml', WorkbookBlob) = 0 then
            exit('');
        if DataCompression.ExtractEntry('xl/_rels/workbook.xml.rels', WorkbookRelsBlob) = 0 then
            exit('');

        WorkbookXml := ReadTempBlobAsText(WorkbookBlob);
        WorkbookRelsXml := ReadTempBlobAsText(WorkbookRelsBlob);

        SheetTag := FindSheetTagByName(WorkbookXml, SheetName);
        if SheetTag = '' then
            SheetTag := FindFirstTag(WorkbookXml, '<sheet');
        if SheetTag = '' then
            exit('');

        RelationshipId := ExtractAttributeValue(SheetTag, 'r:id');
        if RelationshipId = '' then
            exit('');

        TargetPath := FindRelationshipTarget(WorkbookRelsXml, RelationshipId);
        exit(NormalizeWorksheetTarget(TargetPath));
    end;

    local procedure FindSheetTagByName(XmlText: Text; SheetName: Text): Text
    var
        SearchPos: Integer;
        TagText: Text;
        CurrentName: Text;
    begin
        SearchPos := 1;
        while FindNextTag(XmlText, '<sheet', SearchPos, TagText) do begin
            CurrentName := DecodeXmlText(ExtractAttributeValue(TagText, 'name'));
            if CurrentName = SheetName then
                exit(TagText);
        end;
        exit('');
    end;

    local procedure FindRelationshipTarget(XmlText: Text; RelationshipId: Text): Text
    var
        SearchPos: Integer;
        TagText: Text;
        CurrentId: Text;
    begin
        SearchPos := 1;
        while FindNextTag(XmlText, '<Relationship', SearchPos, TagText) do begin
            CurrentId := ExtractAttributeValue(TagText, 'Id');
            if CurrentId = RelationshipId then
                exit(ExtractAttributeValue(TagText, 'Target'));
        end;
        exit('');
    end;

    local procedure NormalizeWorksheetTarget(TargetPath: Text): Text
    begin
        if TargetPath = '' then
            exit('');

        if CopyStr(TargetPath, 1, 1) = '/' then
            TargetPath := CopyStr(TargetPath, 2);

        if CopyStr(LowerCase(TargetPath), 1, 3) = 'xl/' then
            exit(TargetPath);

        if CopyStr(LowerCase(TargetPath), 1, 11) = 'worksheets/' then
            exit('xl/' + TargetPath);

        exit('xl/worksheets/' + TargetPath);
    end;

    local procedure ParseSharedStrings(SharedStringsXml: Text; var SharedStringsByIndex: Dictionary of [Integer, Text])
    var
        SearchPos: Integer;
        SiStartPos: Integer;
        SiEndPos: Integer;
        SiBlock: Text;
        IndexNo: Integer;
        CombinedText: Text;
    begin
        SearchPos := 1;
        IndexNo := 0;

        while FindTextAtOrAfter(SharedStringsXml, '<si', SearchPos, SiStartPos) do begin
            if not FindTextAtOrAfter(SharedStringsXml, '</si>', SiStartPos, SiEndPos) then
                exit;

            SiBlock := CopyStr(SharedStringsXml, SiStartPos, (SiEndPos - SiStartPos) + StrLen('</si>'));
            CombinedText := ExtractAllTextNodes(SiBlock);
            SetDictionaryText(SharedStringsByIndex, IndexNo, CombinedText);

            IndexNo += 1;
            SearchPos := SiEndPos + StrLen('</si>');
        end;
    end;

    local procedure ParseSheetForSalesText(SheetXml: Text; SharedStringsByIndex: Dictionary of [Integer, Text]; var SalesTextByRow: Dictionary of [Integer, Text])
    var
        SearchPos: Integer;
        CellStartPos: Integer;
        CellTagEndPos: Integer;
        CellEndPos: Integer;
        CellTag: Text;
        CellBlock: Text;
        CellRef: Text;
        CellType: Text;
        RowNo: Integer;
        CellValue: Text;
        IsColumnFCell: Boolean;
    begin
        SearchPos := 1;
        while FindTextAtOrAfter(SheetXml, '<c', SearchPos, CellStartPos) do begin
            if not FindTextAtOrAfter(SheetXml, '>', CellStartPos, CellTagEndPos) then
                exit;

            CellTag := CopyStr(SheetXml, CellStartPos, CellTagEndPos - CellStartPos + 1);
            CellRef := ExtractAttributeValue(CellTag, 'r');
            IsColumnFCell := IsColumnFReference(CellRef, RowNo);
            if not IsColumnFCell then
                SearchPos := CellTagEndPos + 1
            else
                if CopyStr(CellTag, StrLen(CellTag), 2) = '/>' then begin
                    SetDictionaryText(SalesTextByRow, RowNo, '');
                    SearchPos := CellTagEndPos + 1;
                end else begin
                    if not FindTextAtOrAfter(SheetXml, '</c>', CellTagEndPos + 1, CellEndPos) then
                        exit;

                    CellBlock := CopyStr(SheetXml, CellTagEndPos + 1, CellEndPos - CellTagEndPos - 1);
                    CellType := ExtractAttributeValue(CellTag, 't');
                    CellValue := GetCellValueFromBlock(CellBlock, CellType, SharedStringsByIndex);
                    SetDictionaryText(SalesTextByRow, RowNo, CellValue);

                    SearchPos := CellEndPos + StrLen('</c>');
                end;
        end;
    end;

    local procedure GetCellValueFromBlock(CellBlock: Text; CellType: Text; SharedStringsByIndex: Dictionary of [Integer, Text]): Text
    var
        RawValue: Text;
        SharedIndex: Integer;
        SharedValue: Text;
    begin
        if CellType = 'inlineStr' then
            exit(ExtractAllTextNodes(CellBlock));

        if CellType = 's' then begin
            RawValue := ExtractTagValue(CellBlock, 'v');
            if Evaluate(SharedIndex, RawValue) then
                if SharedStringsByIndex.Get(SharedIndex, SharedValue) then
                    exit(SharedValue);
            exit('');
        end;

        RawValue := ExtractTagValue(CellBlock, 'v');
        if RawValue = '' then
            RawValue := ExtractAllTextNodes(CellBlock);
        exit(DecodeXmlText(RawValue));
    end;

    local procedure ExtractAllTextNodes(XmlFragment: Text): Text
    var
        SearchPos: Integer;
        TStartPos: Integer;
        TOpenEndPos: Integer;
        TClosePos: Integer;
        ValuePart: Text;
        Combined: Text;
    begin
        SearchPos := 1;
        Combined := '';

        while FindTextAtOrAfter(XmlFragment, '<t', SearchPos, TStartPos) do begin
            if not FindTextAtOrAfter(XmlFragment, '>', TStartPos, TOpenEndPos) then
                exit(DecodeXmlText(Combined));

            if CopyStr(XmlFragment, TOpenEndPos - 1, 2) = '/>' then
                SearchPos := TOpenEndPos + 1
            else begin
                if not FindTextAtOrAfter(XmlFragment, '</t>', TOpenEndPos + 1, TClosePos) then
                    exit(DecodeXmlText(Combined));

                ValuePart := CopyStr(XmlFragment, TOpenEndPos + 1, TClosePos - TOpenEndPos - 1);
                Combined += DecodeXmlText(ValuePart);
                SearchPos := TClosePos + StrLen('</t>');
            end;
        end;

        exit(DecodeXmlText(Combined));
    end;

    local procedure ExtractTagValue(XmlFragment: Text; TagName: Text): Text
    var
        OpenTag: Text;
        CloseTag: Text;
        StartPos: Integer;
        OpenEndPos: Integer;
        ClosePos: Integer;
    begin
        OpenTag := '<' + TagName;
        CloseTag := '</' + TagName + '>';

        if not FindTextAtOrAfter(XmlFragment, OpenTag, 1, StartPos) then
            exit('');
        if not FindTextAtOrAfter(XmlFragment, '>', StartPos, OpenEndPos) then
            exit('');
        if not FindTextAtOrAfter(XmlFragment, CloseTag, OpenEndPos + 1, ClosePos) then
            exit('');

        exit(CopyStr(XmlFragment, OpenEndPos + 1, ClosePos - OpenEndPos - 1));
    end;

    local procedure ReadTempBlobAsText(var TempBlob: Codeunit "Temp Blob"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        BlobInStream: InStream;
    begin
        TempBlob.CreateInStream(BlobInStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(BlobInStream, TypeHelper.LFSeparator()));
    end;

    local procedure FindFirstTag(XmlText: Text; TagStart: Text): Text
    var
        SearchPos: Integer;
        TagText: Text;
    begin
        SearchPos := 1;
        if FindNextTag(XmlText, TagStart, SearchPos, TagText) then
            exit(TagText);
        exit('');
    end;

    local procedure FindNextTag(XmlText: Text; TagStart: Text; var SearchPos: Integer; var TagText: Text): Boolean
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        if not FindTextAtOrAfter(XmlText, TagStart, SearchPos, StartPos) then
            exit(false);
        if not FindTextAtOrAfter(XmlText, '>', StartPos, EndPos) then
            exit(false);

        TagText := CopyStr(XmlText, StartPos, EndPos - StartPos + 1);
        SearchPos := EndPos + 1;
        exit(true);
    end;

    local procedure FindTextAtOrAfter(SourceText: Text; SearchText: Text; FromPos: Integer; var FoundPos: Integer): Boolean
    var
        RelativePos: Integer;
        SearchArea: Text;
    begin
        if FromPos < 1 then
            FromPos := 1;
        if FromPos > StrLen(SourceText) then
            exit(false);

        SearchArea := CopyStr(SourceText, FromPos);
        RelativePos := StrPos(SearchArea, SearchText);
        if RelativePos = 0 then
            exit(false);

        FoundPos := FromPos + RelativePos - 1;
        exit(true);
    end;

    local procedure ExtractAttributeValue(TagText: Text; AttributeName: Text): Text
    var
        Pattern: Text;
        AttributePos: Integer;
        ValueStartPos: Integer;
        ValueEndPos: Integer;
        ValueArea: Text;
    begin
        Pattern := AttributeName + '="';
        AttributePos := StrPos(TagText, Pattern);
        if AttributePos = 0 then
            exit('');

        ValueStartPos := AttributePos + StrLen(Pattern);
        ValueArea := CopyStr(TagText, ValueStartPos);
        ValueEndPos := StrPos(ValueArea, '"');
        if ValueEndPos = 0 then
            exit('');

        exit(CopyStr(ValueArea, 1, ValueEndPos - 1));
    end;

    local procedure IsColumnFReference(CellRef: Text; var RowNo: Integer): Boolean
    var
        PosNo: Integer;
        ColumnLetters: Text;
        RowText: Text;
    begin
        if CellRef = '' then
            exit(false);

        PosNo := 1;
        while (PosNo <= StrLen(CellRef)) and (CopyStr(CellRef, PosNo, 1) in ['A' .. 'Z', 'a' .. 'z']) do
            PosNo += 1;

        ColumnLetters := UpperCase(CopyStr(CellRef, 1, PosNo - 1));
        RowText := CopyStr(CellRef, PosNo);

        if ColumnLetters <> 'F' then
            exit(false);
        if not Evaluate(RowNo, RowText) then
            exit(false);

        exit(true);
    end;

    local procedure DecodeXmlText(ValueText: Text): Text
    begin
        ValueText := ReplaceXmlNumericEntities(ValueText);
        ValueText := ValueText.Replace('&lt;', '<');
        ValueText := ValueText.Replace('&gt;', '>');
        ValueText := ValueText.Replace('&quot;', '"');
        ValueText := ValueText.Replace('&apos;', '''');
        ValueText := ValueText.Replace('&amp;', '&');
        exit(ValueText);
    end;

    local procedure ReplaceXmlNumericEntities(ValueText: Text): Text
    var
        StartPos: Integer;
        EndPos: Integer;
        EntityText: Text;
        CodeText: Text;
        EntityCode: Integer;
        Prefix: Text;
        Suffix: Text;
        ReplacedText: Text;
    begin
        StartPos := StrPos(ValueText, '&#');
        while StartPos > 0 do begin
            EndPos := StrPos(CopyStr(ValueText, StartPos), ';');
            if EndPos = 0 then
                exit(ValueText);

            EndPos := StartPos + EndPos - 1;
            EntityText := CopyStr(ValueText, StartPos, EndPos - StartPos + 1);
            CodeText := CopyStr(EntityText, 3, StrLen(EntityText) - 3);

            if TryParseXmlNumericCode(CodeText, EntityCode) then begin
                Prefix := CopyStr(ValueText, 1, StartPos - 1);
                Suffix := CopyStr(ValueText, EndPos + 1);
                ReplacedText := Prefix + Format(GetAsciiCharacter(EntityCode)) + Suffix;
                ValueText := ReplacedText;
            end else
                StartPos := EndPos + 1;

            StartPos := StrPos(ValueText, '&#');
        end;

        exit(ValueText);
    end;

    local procedure TryParseXmlNumericCode(CodeText: Text; var EntityCode: Integer): Boolean
    begin
        if CopyStr(LowerCase(CodeText), 1, 1) = 'x' then
            exit(TryParseHexNumber(CopyStr(CodeText, 2), EntityCode));

        exit(Evaluate(EntityCode, CodeText));
    end;

    local procedure TryParseHexNumber(HexText: Text; var Number: Integer): Boolean
    var
        PosNo: Integer;
        DigitNo: Integer;
        CurrentChar: Text;
    begin
        Number := 0;
        if HexText = '' then
            exit(false);

        for PosNo := 1 to StrLen(HexText) do begin
            CurrentChar := UpperCase(CopyStr(HexText, PosNo, 1));
            if (CurrentChar >= '0') and (CurrentChar <= '9') then
                Evaluate(DigitNo, CurrentChar)
            else
                case CurrentChar of
                    'A':
                        DigitNo := 10;
                    'B':
                        DigitNo := 11;
                    'C':
                        DigitNo := 12;
                    'D':
                        DigitNo := 13;
                    'E':
                        DigitNo := 14;
                    'F':
                        DigitNo := 15;
                    else
                        exit(false);
                end;

            Number := (Number * 16) + DigitNo;
        end;

        exit(true);
    end;

    local procedure SetDictionaryText(var TextDictionary: Dictionary of [Integer, Text]; KeyNo: Integer; NewValue: Text)
    begin
        if TextDictionary.ContainsKey(KeyNo) then
            TextDictionary.Remove(KeyNo);
        TextDictionary.Add(KeyNo, NewValue);
    end;

    local procedure GetCellText(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    var
        CellValue: Text;
        CellName: Text;
        BufferFallbackValue: Text;
    begin
        // Primary read using cell name.
        CellName := GetCellName(RowNo, ColNo);
        CellValue := ExcelBuffer.GetValueByCellName(CellName);

        // Fallback: some environments still expose max 250 chars from direct read.
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

        // Some Excel Buffer implementations split long values into these fields.
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

    local procedure NormalizeLineBreaks(InputText: Text): Text
    var
        CR: Char;
        LF: Char;
        CrLf: Text;
        LfText: Text;
        CrText: Text;
        HtmlLineBreak: Text;
    begin
        CR := 13;
        LF := 10;

        CrLf := Format(CR) + Format(LF);
        LfText := Format(LF);
        CrText := Format(CR);
        HtmlLineBreak := '<br />';

        // Excel can store line breaks as escaped control tokens.
        InputText := DecodeExcelEscapedLineBreaks(InputText);

        // Normalize to LF first.
        InputText := InputText.Replace(CrLf, LfText);
        InputText := InputText.Replace(CrText, LfText);

        // RichContent displays HTML; plain newlines are often rendered as spaces.
        exit(InputText.Replace(LfText, HtmlLineBreak));
    end;

    local procedure DecodeExcelEscapedLineBreaks(InputText: Text): Text
    var
        CR: Char;
        LF: Char;
        CrLf: Text;
        LfText: Text;
    begin
        CR := 13;
        LF := 10;
        CrLf := Format(CR) + Format(LF);
        LfText := Format(LF);

        InputText := InputText.Replace('_x000D__x000A_', CrLf);
        InputText := InputText.Replace('_x000d__x000a_', CrLf);
        InputText := InputText.Replace('_x000A_', LfText);
        InputText := InputText.Replace('_x000a_', LfText);
        InputText := InputText.Replace('_x000D_', Format(CR));
        InputText := InputText.Replace('_x000d_', Format(CR));

        exit(InputText);
    end;
}
