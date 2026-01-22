pageextension 50106 "NetCom Sales Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group(NetCom)
            {
                Caption = 'NetCom';

                field("NetCom Environmental Fee Acc."; Rec."NetCom Environmental Fee Acc.")
                {
                    ApplicationArea = All;
                }
                field("NetCom Environmental Fee Grp."; Rec."NetCom Environmental Fee Grp.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}