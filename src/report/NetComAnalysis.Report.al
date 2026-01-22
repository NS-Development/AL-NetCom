report 50101 "NetCom Analysis"
{
    UsageCategory = None;
    // DefaultRenderingLayout = LayoutName;
    ProcessingOnly = true;
    Caption = 'Analysis';

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromDateOption; FromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From Date';
                        ToolTip = 'From Date';
                    }
                    field(ToDateOption; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To Date';
                        ToolTip = 'To Date';
                    }
                    // field(ShowOnlyWithTaxOption; ShowOnlyWithTax)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Show only lines tax';
                    //     ToolTip = 'Show only lines tax';
                    // }
                    // field(ShowSalesOption; ShowSales)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Show Sales';
                    //     ToolTip = 'Show sales transactions.';

                    // }
                    // field(ShowPurchasesOption; ShowPurchases)
                    // {
                    //     ApplicationArea = All;
                    //     Caption = 'Show Purchases';
                    //     ToolTip = 'Show purchase transactions.';
                    // }
                }
            }
        }
        // trigger OnOpenPage()
        // begin
        //     ShowSales := true;
        // end;
    }

    trigger OnPreReport()
    var
        UserSetup: Record "User Setup";
        NetComRptBufTable: Record "NetCom Report Buffer Table";
        TextLabel01Lbl: Label 'This page is last updated on %1', Comment = '%1 = Update date time';
        TextLabel02Lbl: Label 'Date filter: %1', Comment = '%1 = Date label';

    begin
        NetComRptBufTable.Reset();
        NetComRptBufTable.SetRange("User Id", UserId);
        NetComRptBufTable.SetRange("Report Id", CurrPageId);
        NetComRptBufTable.DeleteAll();

        if not UserSetup.Get(UserId) then
            UserSetup.Init();

        Clear(NetComRptBufTableIndent0);

        // Make Header
        NextEntryNo += 1;
        NetComRptBufTable."NetCom Item Description" := StrSubstNo(TextLabel01Lbl, CurrentDateTime);
        InsertRptBufTable(0, NextEntryNo, NetComRptBufTable);

        NextEntryNo += 1;
        NetComRptBufTable."NetCom Item Description" := StrSubstNo(TextLabel02Lbl, Format(FromDate) + '..' + Format(ToDate));
        InsertRptBufTable(0, NextEntryNo, NetComRptBufTable);

        ProcessItems();
    end;

    procedure SetPageId(PageId: Integer)
    begin
        CurrPageId := PageId;
    end;

    local procedure InsertRptBufTable(Indent: Integer; InputNextEntryNo: Integer; var FSRptBufTable: Record "NetCom Report Buffer Table")
    var
        NetComReportBufferTable: Record "NetCom Report Buffer Table";
    begin
        NetComReportBufferTable := FSRptBufTable;
        FSRptBufTable.Init();

        NetComReportBufferTable."Entry No." := InputNextEntryNo;
        NetComReportBufferTable."User Id" := CopyStr(UserId, 1, 50);
        NetComReportBufferTable."Report Id" := CurrPageId;
        NetComReportBufferTable."Integer 01" := Indent;
        NetComReportBufferTable."DateTime 03" := CurrentDateTime;
        NetComReportBufferTable.Insert();
    end;

    local procedure SumLine(InputText: Code[20]; RptBufTable: Record "NetCom Report Buffer Table")
    begin
        NetComRptBufTableIndent0."Code 01" := InputText;
        NetComRptBufTableIndent0."NetCom Amount sold" += RptBufTable."NetCom Amount sold";
        NetComRptBufTableIndent0."NetCom Gross Weight" += RptBufTable."NetCom Gross Weight";
        NetComRptBufTableIndent0."NetCom Net Weight" += RptBufTable."NetCom Net Weight";
        NetComRptBufTableIndent0."NetCom Weight" += RptBufTable."NetCom Weight";
    end;


    #region Testing methods
    local procedure ProcessItems()
    var
        NetComRptBufTable: Record "NetCom Report Buffer Table";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemsTotalLbl: Label 'Items Total';
        ItemsHeadlinesLbl: Label 'Items';
        AmountSold: Decimal;
        GrossWeightSold: Decimal;
        NetWeightSold: Decimal;
        ElectronicSold: Decimal;
    begin
        #region Sales
        NextEntryNo += 1;

        Clear(NetComRptBufTable);
        NetComRptBufTable."Code 01" := ItemsHeadlinesLbl;
        InsertRptBufTable(0, NextEntryNo, NetComRptBufTable);

        Item.Reset();
        if Item.findset() then
            repeat
                AmountSold := 0;
                GrossWeightSold := 0;
                NetWeightSold := 0;
                ElectronicSold := 0;

                if (Item."NetCom Packaging" = true) or (Item."NetCom Electronic" = true) then begin
                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetCurrentKey("Item No.");
                    ItemLedgerEntry.SetRange("Item No.", Item."No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            AmountSold := AmountSold + ItemLedgerEntry.Quantity;

                            if Item."NetCom Electronic" then
                                ElectronicSold := ElectronicSold + Item."Net Weight";
                        Until ItemLedgerEntry.Next() = 0;

                    AmountSold := -AmountSold;

                    if Item."NetCom Packaging" = true then begin
                        GrossWeightSold := AmountSold * Item."Gross Weight";
                        NetWeightSold := AmountSold * Item."Net Weight";
                    end;

                    if AmountSold <> 0 then begin
                        NextEntryNo += 1;

                        Clear(NetComRptBufTable);
                        NetComRptBufTable."Code 01" := ItemsHeadlinesLbl;
                        // NetComRptBufTable."NetCom Document No." := ItemLedgerEntry."Document No.";
                        NetComRptBufTable."NetCom Item No." := Item."No.";
                        NetComRptBufTable."NetCom Item Description" := Item.Description;
                        NetComRptBufTable."NetCom Net Weight" := NetWeightSold;
                        NetComRptBufTable."NetCom Gross Weight" := GrossWeightSold;
                        NetComRptBufTable."NetCom Weight" := GrossWeightSold - NetWeightSold;
                        NetComRptBufTable."NetCom Amount sold" := AmountSold;
                        NetComRptBufTable."Electronic Net. Weight" := ElectronicSold;

                        SumLine(ItemsTotalLbl, NetComRptBufTable);
                        InsertRptBufTable(1, NextEntryNo, NetComRptBufTable);
                    end;
                end;
            until Item.Next() = 0;

        NextEntryNo += 1;
        InsertRptBufTable(0, NextEntryNo, NetComRptBufTableIndent0);
        #endregion Sales
    end;

    // local procedure ProcessPurchases()
    // var
    //     NetComRptBufTable: Record "NetCom Report Buffer Table";
    //     ItemLedgerEntry: Record "Item Ledger Entry";
    //     PurchaseHeadlinesLbl: Label 'Purchase';
    //     PurchaseTotalLbl: Label 'Purchase Total';
    // begin
    //     #region Purchase
    //     Clear(NetComRptBufTableIndent0);

    //     NextEntryNo += 1;

    //     Clear(NetComRptBufTable);
    //     NetComRptBufTable."Code 01" := PurchaseHeadlinesLbl;
    //     InsertRptBufTable(0, NextEntryNo, NetComRptBufTable);

    //     ItemLedgerEntry.Reset();
    //     ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
    //     ItemLedgerEntry.SetRange("Posting Date", FromDate, ToDate);

    //     if ItemLedgerEntry.FindSet() then
    //         repeat
    //             if (ShowOnlyWithTax = false) or
    //                     ((ShowOnlyWithTax = true) and
    //                      ((ItemLedgerEntry."NetCom Cardboard in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Glass in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Hard Plastic in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Soft Plastic in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Tree in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Metal in g" <> 0) or
    //                       (ItemLedgerEntry."NetCom Paper in g" <> 0))) then begin
    //                 NextEntryNo += 1;

    //                 Clear(NetComRptBufTable);
    //                 NetComRptBufTable."Code 01" := PurchaseHeadlinesLbl;
    //                 NetComRptBufTable."NetCom Document No." := ItemLedgerEntry."Document No.";
    //                 NetComRptBufTable."NetCom Cardboard in g" := ItemLedgerEntry."NetCom Cardboard in g";
    //                 NetComRptBufTable."NetCom Glass in g" := ItemLedgerEntry."NetCom Glass in g";
    //                 NetComRptBufTable."NetCom Hard Plastic in g" := ItemLedgerEntry."NetCom Hard Plastic in g";
    //                 NetComRptBufTable."NetCom Soft Plastic in g" := ItemLedgerEntry."NetCom Soft Plastic in g";
    //                 NetComRptBufTable."NetCom Tree in g" := ItemLedgerEntry."NetCom Tree in g";
    //                 NetComRptBufTable."NetCom Metal in g" := ItemLedgerEntry."NetCom Metal in g";
    //                 NetComRptBufTable."NetCom Paper in g" := ItemLedgerEntry."NetCom Paper in g";
    //                 NetComRptBufTable."NetCom Item No." := ItemLedgerEntry."Item No.";
    //                 NetComRptBufTable."NetCom Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
    //                 SumLine(PurchaseTotalLbl, NetComRptBufTable);
    //                 InsertRptBufTable(1, NextEntryNo, NetComRptBufTable);
    //             end;
    //         Until ItemLedgerEntry.Next() = 0;
    //     NextEntryNo += 1;
    //     InsertRptBufTable(0, NextEntryNo, NetComRptBufTableIndent0);
    //     #endregion Purchase
    // end;
    #endregion Testing methods

    var
        NetComRptBufTableIndent0: Record "NetCom Report Buffer Table";
        FromDate: Date;
        ToDate: Date;
        CurrPageId: Integer;
        NextEntryNo: Integer;
        ShowOnlyWithTax: Boolean;
        ShowPurchases: Boolean;
        ShowSales: Boolean;
}