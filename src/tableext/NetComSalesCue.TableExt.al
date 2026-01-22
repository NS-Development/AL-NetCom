tableextension 50101 "NetCom Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(50100; "NetCom Price Lists - Export"; Integer)
        {
            CalcFormula = count("NetCom Customer Price Service" where(Export = const(true)));
            Caption = 'Price Lists - Ready to Export';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}