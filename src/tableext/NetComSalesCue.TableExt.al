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
        field(50101; "NetCom Inload - Export"; Integer)
        {
            CalcFormula = count("NetCom Inload Service" where(Export = const(true)));
            Caption = 'Inload - Ready to Export';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}