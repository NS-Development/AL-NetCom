pageextension 50104 "NetCom Item Tracking Lines" extends "Item Tracking Lines"
{
    layout
    {
        modify(AvailabilitySerialNo)
        {
            Visible = false;
        }
        modify(AvailabilityLotNo)
        {
            Visible = false;
        }
        modify("Lot No.")
        {
            Visible = false;
        }
        modify("Quantity (Base)")
        {
            QuickEntry = false;
        }
        modify("Qty. to Handle (Base)")
        {
            QuickEntry = false;
        }
        modify("Qty. to Invoice (Base)")
        {
            QuickEntry = false;
        }
        modify("Appl.-to Item Entry")
        {
            QuickEntry = false;
        }
    }
}