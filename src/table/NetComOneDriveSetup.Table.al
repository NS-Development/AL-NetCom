table 50102 "NetCom OneDrive Setup"
{
    Caption = 'NetCom OneDrive Setup';
    DataClassification = ToBeClassified;
    LookupPageId = "NetCom OneDrive Setup";
    DrillDownPageId = "NetCom OneDrive Setup";

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }
        field(10; "Azure Tenant ID"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Azure Tenant ID';
        }

        field(11; "Azure App Client ID"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Azure App Client ID';
        }
        field(12; "Azure App Client Secret"; Text[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = Masked;
            Caption = 'Azure App Client Secret';
        }
        field(13; "Authentication User"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Authentication User';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}