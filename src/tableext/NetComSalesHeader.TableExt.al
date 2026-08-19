tableextension 50106 "NetCom Sales Header" extends "Sales Header"
{
    fields
    {
        modify("External Document No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateExternalFields("External Document No.");
            end;
        }
        modify("CPM External Payment Reference")
        {
            trigger OnAfterValidate()
            begin
                UpdateExternalFields("CPM External Payment Reference");
            end;
        }
        modify("Your Reference")
        {
            trigger OnAfterValidate()
            begin
                UpdateExternalFields("Your Reference");
            end;
        }
    }

    local procedure UpdateExternalFields(inputValue: Text[100])
    begin
        "External Document No." := CopyStr(inputValue, 1, MaxStrLen("External Document No."));
        "CPM External Payment Reference" := CopyStr(inputValue, 1, MaxStrLen("CPM External Payment Reference"));
        "Your Reference" := CopyStr(inputValue, 1, MaxStrLen("Your Reference"));
    end;
}