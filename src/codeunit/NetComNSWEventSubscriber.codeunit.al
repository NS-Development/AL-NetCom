codeunit 50101 "NetCom NSW Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NSW API", 'User_OnAfter_CreateOrUpdate', '', true, true)]
    local procedure NSWAPIUserOnAfterCreateOrUpdate(NSWCustomerUser: Record "NSW Customer User"; var CustomDataIdListAdd: List of [Integer]; var CustomDataIdListRemove: List of [Integer])
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
}