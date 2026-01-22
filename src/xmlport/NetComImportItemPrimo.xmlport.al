xmlport 50100 "NetCom Import Item Primo"
{
    Format = VariableText;
    Direction = Import;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    FieldSeparator = ';';


    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;

                textelement(ItemGroup)
                {

                }
                textelement(ItemNo)
                {

                }
                textelement(ItemName)
                {

                }
                textelement(Qty)
                {

                }
                textelement(AvgCostPrice)
                {

                }
                textelement(TotalCostAmount)
                {

                }

                trigger OnBeforeInsertRecord()
                var
                    ItemJournalLine: Record "Item Journal Line";
                    Item: Record Item;
                    QtyDec: Decimal;
                    TotalCostAmountDec: Decimal;
                begin
                    LineNo := LineNo + 10000;

                    Evaluate(QtyDec, Qty);
                    Evaluate(TotalCostAmountDec, TotalCostAmount);



                    Clear(ItemJournalLine);
                    ItemJournalLine.Init();
                    ItemJournalLine.Validate("Journal Template Name", 'VARE');
                    ItemJournalLine.Validate("Journal Batch Name", 'PRIMO');
                    ItemJournalLine.Validate("Line No.", LineNo);
                    if Item.Get(ItemNo) then
                        ItemJournalLine.Validate("Item No.", ItemNo);
                    ItemJournalLine.Validate("Posting Date", 20230608D);
                    if QtyDec < 0 then
                        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.")
                    else
                        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
                    ItemJournalLine.Validate("Document No.", 'PRIMO080623');
                    ItemJournalLine.Validate("Source Code", 'VAREKLD');
                    if not Item.Get(ItemNo) then
                        ItemJournalLine.Validate(Description, 'Varenr. ' + ItemNo + ' findes ikke i BC! Antal = ' + Qty + ', Total kostbeløb = ' + TotalCostAmount)
                    else begin
                        ItemJournalLine.Validate("Item No.", ItemNo);
                        if QtyDec < 0 then begin
                            ItemJournalLine.Validate(Quantity, -QtyDec);
                            ItemJournalLine.Validate(Amount, -TotalCostAmountDec);

                        end else begin
                            ItemJournalLine.Validate(Quantity, QtyDec);
                            ItemJournalLine.Validate(Amount, TotalCostAmountDec);
                        end;
                    end;

                    ItemJournalLine.Insert(true);
                end;
            }
        }
    }

    var
        LineNo: Integer;

}