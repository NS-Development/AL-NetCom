table 50104 "NetCom Inload Service"
{
    DataClassification = ToBeClassified;
    Caption = 'Inload Service';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name where("No." = field("Customer No.")));
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
        field(21; "Document Reference ID"; Media)
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Reference ID';
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