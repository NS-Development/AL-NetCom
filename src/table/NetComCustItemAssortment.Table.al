table 50105 "NetCom Cust. Item Assortment"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            ToolTip = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No.';
            ToolTip = 'Item No.';
            TableRelation = Item."No.";
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name where("No." = field("Customer No.")));
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Item No.")
        {
            Clustered = true;
        }
    }
}