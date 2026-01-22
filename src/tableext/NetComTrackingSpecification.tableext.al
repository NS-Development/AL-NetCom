tableextension 50102 "NetCom Tracking Specification" extends "Tracking Specification"
{
    fields
    {
        modify("Serial No.")
        {
            trigger OnAfterValidate()
            begin
                Validate("Quantity (Base)", 1);
            end;
        }
    }
}