tableextension 50100 "NetCom Customer" extends Customer
{
    fields
    {
        field(50100; "NetCom Invoice Payment"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Invoice Payment';
        }
    }
}