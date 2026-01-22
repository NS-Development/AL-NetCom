tableextension 50103 "NetCom Sales Line" extends "Sales Line"
{
    fields
    {
        field(50100; "NetCom Scanned Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Scanned Qty.';
        }
    }
}