reportextension 50101 "NetCom Standard Sales Invoice" extends "Standard Sales - Invoice"
{
    dataset
    {
        add(Line)
        {
            column(NetComDescription_Line; NetComDescription)
            {
            }
        }
        modify(Line)
        {
            trigger OnBeforePreDataItem()
            begin
                EnvironmentalFee := 0;
            end;

            trigger OnAfterAfterGetRecord()
            var
                Item: Record Item;
                TypeHelper: Codeunit "Type Helper";
            begin
                SkipLine := false;
                if Line.Type = Line.Type::"G/L Account" then
                    if Line."Gen. Prod. Posting Group" = SalesSetup."NetCom Environmental Fee Grp." THEN BEGIN
                        EnvironmentalFee := EnvironmentalFee + Line.Amount;
                        SkipLine := true;
                    end;

                if SkipLine then
                    CurrReport.Skip();

                // Get serial numbers for item lines
                if Line.Type = Line.Type::Item then
                    SerialNumbers := NetComGetSerialNumbers(Line);

                NetComDescription := Line.Description;
                if Line."VAT Prod. Posting Group" = 'OMVENDT' then
                    NetComDescription := NetComDescription + TypeHelper.NewLine() + ReversePaymentObligationLbl;
                if Line.Type = Line.Type::Item then
                    if Item.Get(Line."No.") then begin
                        if Item.GTIN <> '' then
                            NetComDescription := NetComDescription + TypeHelper.NewLine() + GTINLbl + Item.GTIN;
                        if Item."Country/Region of Origin Code" <> '' then
                            NetComDescription := NetComDescription + TypeHelper.NewLine() + CountryOfOriginLbl + Item."Country/Region of Origin Code";
                        if Item."Tariff No." <> '' then
                            NetComDescription := NetComDescription + TypeHelper.NewLine() + TariffNoLbl + Item."Tariff No.";
                    end;
                if SerialNumbers <> '' then
                    NetComDescription := NetComDescription + TypeHelper.NewLine() + SerialNumbers;
            end;
        }
        modify(ReportTotalsLine)
        {
            trigger OnAfterPreDataItem()
            begin
                NetComCreateReportTotalLines();
            end;
        }
    }

    rendering
    {
        layout(NetComStandardSalesInvoice)
        {
            Type = Word;
            LayoutFile = 'src\layout\NetComStandardSalesInvoice.docx';
        }
    }

    local procedure NetComCreateReportTotalLines()
    begin
        ReportTotalsLine.DeleteAll();
        if (TotalInvDiscAmount <> 0) or (TotalAmountVAT <> 0) then
            ReportTotalsLine.Add(NetComSubtotalLbl, TotalSubTotal - EnvironmentalFee, true, false, false, Header."Currency Code");
        if TotalInvDiscAmount <> 0 then begin
            ReportTotalsLine.Add(NetComInvDiscountAmtLbl, TotalInvDiscAmount, false, false, false, Header."Currency Code");
            if TotalAmountVAT <> 0 then
                if Header."Prices Including VAT" then
                    ReportTotalsLine.Add(TotalInclVATText, TotalAmountInclVAT, true, false, false, Header."Currency Code")
                else
                    ReportTotalsLine.Add(TotalExclVATText, TotalAmount, true, false, false, Header."Currency Code");
        end;
        if EnvironmentalFee <> 0 then
            ReportTotalsLine.Add(EnvironmentalFeeLbl, EnvironmentalFee, true, false, false, Header."Currency Code");
        if TotalAmountVAT <> 0 then begin
            ReportTotalsLine.Add(VATAmountLine.VATAmountText(), TotalAmountVAT, false, true, false, Header."Currency Code");
            if TotalVATAmountLCY <> TotalAmountVAT then
                ReportTotalsLine.Add(VATAmountLine.VATAmountText() + NetComLCYTxt, TotalVATAmountLCY, false, true, false);
        end;
    end;

    local procedure NetComGetSerialNumbers(var SalesInvoiceLine: Record "Sales Invoice Line") SerialNos: Text
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempSerialNo: Text;
        SerialNoList: List of [Text];
    begin
        SerialNos := '';

        // Use Value Entry to get only the serial numbers for THIS invoice line
        ValueEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        ValueEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
        ValueEntry.SetRange("Item No.", SalesInvoiceLine."No.");
        if ValueEntry.FindSet() then
            repeat
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                    if ItemLedgerEntry."Serial No." <> '' then begin
                        TempSerialNo := ItemLedgerEntry."Serial No.";
                        // Avoid duplicates
                        if not SerialNoList.Contains(TempSerialNo) then begin
                            SerialNoList.Add(TempSerialNo);
                            if SerialNos <> '' then
                                SerialNos += ', ';
                            SerialNos += TempSerialNo;
                        end;
                    end;
            until ValueEntry.Next() = 0;

        if SerialNos <> '' then
            SerialNos := SerialNosLbl + SerialNos;
    end;

    var
        SkipLine: Boolean;
        EnvironmentalFee: Decimal;
        SerialNumbers: Text;
        NetComDescription: Text;
        EnvironmentalFeeLbl: Label 'Environmental Tax';
        NetComSubtotalLbl: Label 'Subtotal';
        NetComInvDiscountAmtLbl: Label 'Invoice Discount';
        NetComLCYTxt: label ' (LCY)';
        SerialNosLbl: Label 'Serial Numbers: ';
        CountryOfOriginLbl: Label 'Country of Origin: ';
        TariffNoLbl: Label 'Tariff No.: ';
        ReversePaymentObligationLbl: Label 'Reverse charge: As a buyer, you must calculate the sales tax for the item yourself on your VAT return.';
        GTINLbl: Label 'GTIN: ';
}