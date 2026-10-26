table 50107 "NetCom Env. Tax Preview"
{
    Caption = 'Environmental Tax Preview';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Existing Environmental Tax"; Decimal)
        {
            Caption = 'Existing Environmental Tax';
            DecimalPlaces = 2 : 5;
        }
        field(4; "Packaging Weight"; Decimal)
        {
            Caption = 'Packaging Weight';
            DecimalPlaces = 0 : 5;
        }
        field(5; "New Environmental Tax"; Decimal)
        {
            Caption = 'New Environmental Tax';
            DecimalPlaces = 2 : 2;
        }
        field(6; "Item Modified At"; DateTime)
        {
            Caption = 'Item Modified At';
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}
