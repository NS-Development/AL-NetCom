codeunit 50106 "NetCom Functions"
{
    procedure CreateEnvironmentalFeeLines(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesLineCheck: Record "Sales Line";
        Item: Record Item;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TotalEnvironmentalFee: Decimal;
    begin
        SalesReceivablesSetup.Get();

        //Check if sales order already has an unposted environmental fee line
        SalesLineCheck.Reset();
        SalesLineCheck.SetRange("Document Type", SalesHeader."Document Type");
        SalesLineCheck.SetRange("Document No.", SalesHeader."No.");
        SalesLineCheck.SetRange(Type, SalesLineCheck.Type::"G/L Account");
        SalesLineCheck.SetRange("No.", SalesReceivablesSetup."NetCom Environmental Fee Acc.");
        SalesLineCheck.SetFilter("Qty. to Ship", '<>%1', 0);
        if SalesLineCheck.FindFirst() then
            SalesLineCheck.Delete(true);

        SalesLineCheck.Reset();
        SalesLineCheck.SetRange("Document Type", SalesHeader."Document Type");
        SalesLineCheck.SetRange("Document No.", SalesHeader."No.");
        SalesLineCheck.SetRange(Type, SalesLineCheck.Type::Item);
        if SalesLineCheck.FindSet() then
            repeat
                if Item.Get(SalesLineCheck."No.") then
                    if Item."NetCom Environmental Tax" <> 0 then
                        TotalEnvironmentalFee := TotalEnvironmentalFee + Item."NetCom Environmental Tax" * SalesLineCheck."Qty. to Ship";
            until SalesLineCheck.Next() = 0;

        // Create a new line for the environmental fee
        if TotalEnvironmentalFee = 0 then
            exit;

        if SalesHeader.Status = SalesHeader.Status::Released then
            SalesHeader.PerformManualReopen(SalesHeader);

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", GetNextSalesLineNo(SalesHeader."Document Type", SalesHeader."No."));
        SalesLine.Validate("Type", SalesLine."Type"::"G/L Account");
        SalesLine.Validate("No.", SalesReceivablesSetup."NetCom Environmental Fee Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit of Measure Code", 'STK');
        SalesLine.Validate("Unit Price", TotalEnvironmentalFee);
        SalesLine.Validate("Gen. Prod. Posting Group", SalesReceivablesSetup."NetCom Environmental Fee Grp.");
        SalesLine.Insert();
    end;

    procedure GetNextSalesLineNo(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000)
        else
            exit(10000);
    end;
}