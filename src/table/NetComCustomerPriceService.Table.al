table 50101 "NetCom Customer Price Service"
{
    DataClassification = ToBeClassified;
    Caption = 'Customer Price Service';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(2; "Cloud Storage Folder ID"; Code[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Cloud Storage Folder ID';
        }
        field(5; "Export Interval"; Enum "NetCom Time Interval")
        {
            DataClassification = ToBeClassified;
            Caption = 'Export Interval';
        }
        field(10; Export; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export';
        }
        field(11; "Latest Export"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Latest Export';
        }
        field(20; "GD FileID"; Text[2048])
        {
            DataClassification = ToBeClassified;
            Caption = 'Google Drive File ID';
        }
        field(21; "Document Reference ID"; Media)
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Reference ID';
        }
        field(30; "Skip Web Description"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Skip Web Description';
        }
    }

    keys
    {
        key(NetComKey1; "Customer No.")
        {
            Clustered = true;
        }
    }
}