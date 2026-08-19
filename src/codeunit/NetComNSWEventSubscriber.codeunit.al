codeunit 50101 "NetCom NSW Event Subscriber"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NSW API", 'User_OnAfter_CreateOrUpdate', '', false, false)]
    local procedure NetCom_NSWAPIUserOnAfterCreateOrUpdate(NSWCustomerUser: Record "NSW Customer User"; var CustomDataIdListAdd: List of [Integer]; var CustomDataIdListRemove: List of [Integer])
    var
        Customer: Record Customer;
    begin
        Clear(CustomDataIdListAdd);
        Clear(CustomDataIdListRemove);
        if Customer.Get(NSWCustomerUser."Customer No.") then
            if Customer."NetCom Invoice Payment" then begin
                CustomDataIdListRemove.Add(1);
                CustomDataIdListAdd.Add(2);
            end else
                CustomDataIdListRemove.Add(2);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NSW API", 'OnAfter_OrderHandling', '', false, false)]
    local procedure NetCom_NSWAPI_OnAfterBuildSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."NSW Reference No." <> '' then begin
            SalesHeader.Validate("External Document No.", CopyStr(SalesHeader."NSW Reference No.", 1, MaxStrLen(SalesHeader."External Document No.")));
            SalesHeader.Modify();
        end;
    end;
}