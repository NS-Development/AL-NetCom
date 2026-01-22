codeunit 50100 "NetCom Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        NetComFunctions: Codeunit "NetCom Functions";
    //ConfirmManagement: Codeunit "Confirm Management";
    // ConfirmQuestionLbl: Label 'Posting date %1 is different from today %2.\Do you want to update posting date to %2?', Comment = '%1 = Posting Date, %2 = Today';
    begin
        if not GuiAllowed then
            exit;

        //Check if products with EAN No. has been scanned
        // if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
        //     NetComScanFunctions.CheckScannedProducts(SalesHeader);

        if SalesHeader."Posting Date" <> Today then begin
            SalesHeader.Validate("Posting Date", Today);
            SalesHeader.Modify(true);
        end;

        //Create Environmental Fee Lines
        if (SalesHeader."NSW Order ID" = 0) or (SalesHeader."NSW Payment Id" = 2) or (SalesHeader."NSW Payment Id" = 4) then
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) then
                NetComFunctions.CreateEnvironmentalFeeLines(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure PurchPostOnBeforePostSalesDoc(var PurchaseHeader: Record "Purchase Header")
    var
        Qst001Lbl: Label 'Posting date is %1.\Do you want to continue?', Comment = '%1 = Posting Date';
    begin
        if not GuiAllowed then
            exit;

        if not Confirm(StrSubstNo(Qst001Lbl, PurchaseHeader."Posting Date"), false) then
            Error('');
    end;
}