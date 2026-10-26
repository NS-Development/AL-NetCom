table 50106 "NetCom Setup"
{
    Caption = 'NetCom Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NetCom Setup";
    DrillDownPageId = "NetCom Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Environmental Tax per Kg."; Decimal)
        {
            Caption = 'Environmental Tax per Kg.';
            ToolTip = 'Specifies the environmental tax per kilogram of packaging. Packaging weight is gross weight minus net weight, with a minimum of zero.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
