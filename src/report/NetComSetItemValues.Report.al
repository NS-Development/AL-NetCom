report 50102 "NetCom Set Item Values"
{
    UsageCategory = Administration;
    Caption = 'NetCom Set Item Values (One Time)';
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            trigger OnAfterGetRecord()
            begin
                case Item."Vendor No." of
                    '1004',
                    '2',
                    '159338798',
                    '1031',
                    'K00190',
                    '1000',
                    '1003',
                    '1008':
                        begin
                            Item."NetCom Packaging" := true;
                            Item.Modify();
                        end;
                end;
            end;
        }
    }
}