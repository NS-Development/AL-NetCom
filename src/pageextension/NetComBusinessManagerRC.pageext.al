pageextension 50103 "NetCom Business Manager RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control16)
        {
            part(OneDriveActivities; "NetCom OneDrive Activites")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}