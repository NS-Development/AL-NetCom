tableextension 50105 "NetCom Sales Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "NetCom Environmental Fee Acc."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Environmental Fee G/L Account';
            ToolTip = 'Specifies the G/L account for environmental fees.';
            TableRelation = "G/L Account"."No.";
        }
        field(50101; "NetCom Environmental Fee Grp."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Environmental Fee Product Posting Group';
            ToolTip = 'Specifies the group for environmental fees.';
            TableRelation = "Gen. Product Posting Group".Code;
        }
    }
}