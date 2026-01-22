page 50105 "NetCom Sales Order Scan Lines"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Scan Lines';
    SourceTableView = where("Qty. to Ship" = filter(> 0));


    layout
    {
        area(Content)
        {
            group(Scan)
            {
                Caption = 'Scan';
                group(ScannedNoGroup)
                {
                    ShowCaption = false;
                    Editable = ScannedNoQuickEntry;
                    Enabled = ScannedNoQuickEntry;

                    field(ScannedNo; ScannedNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Scan Item';
                        ToolTip = 'Scan the Item No. or EAN code of the item.';

                        trigger OnValidate()
                        var
                            NetComScanFunctions: Codeunit "NetCom Scan Functions";
                        begin
                            ItemNo := NetComScanFunctions.ScanItem(Rec, ScannedNo, SerialNoRequired, true);
                            // ScannedQty := NSWMSFunctions.CalculateScanned(Rec);
                            ScannedItemNo := ScannedNo;

                            CurrPage.Update();
                        end;
                    }
                }
                group(SerialNoGroup)
                {
                    // Visible = SerialNoRequired;
                    // Editable = SerialNoRequired;
                    ShowCaption = false;
                    field(ScannedSerialNo; ScannedSerialNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Scan Serial No';
                        ToolTip = 'Scan the serial number of the item.';

                        trigger OnValidate()
                        var
                            Item: Record Item;
                            NetComScanFunctions: Codeunit "NetCom Scan Functions";
                            Msg001Lbl: Label 'You have to scan Item No. before scan serial no.!';
                            Msg002Lbl: Label 'Item Tracking Code is not set for item no. %1!', Comment = '%1 = Item No.';
                            SerialNos: List of [Code[50]];
                        begin
                            if ItemNo = '' then begin
                                Message(Msg001Lbl);
                                Error('');
                            end else begin
                                Item.Get(ItemNo);
                                if Item."Item Tracking Code" = '' then begin
                                    Message(StrSubstNo(Msg002Lbl, ItemNo));
                                    Error('');
                                end;

                                Clear(SerialNos);
                                ScannedNoQuickEntry := NetComScanFunctions.ScanSerialNo(Rec, ItemNo, ScannedItemNo, ScannedSerialNo, SerialNos, true);
                                // ScannedQty := NSWMSFunctions.CalculateScanned(Rec);
                                ScannedSerialNo := '';

                                // PageCheckScanFinished();

                                // GetLatestSerialNo();
                            end;
                            CurrPage.Update();
                        end;
                    }
                }
            }

            repeater(GroupName)
            {
                Editable = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of the sales line.';
                    StyleExpr = StyleExpression;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    Caption = 'No.';
                    ToolTip = 'Specifies the item number.';
                    StyleExpr = StyleExpression;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the item.';
                    StyleExpr = StyleExpression;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the quantity of the item.';
                    StyleExpr = StyleExpression;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    Caption = 'Qty. to Ship';
                    ToolTip = 'Specifies the quantity of the item that is to be shipped.';
                    StyleExpr = StyleExpression;
                }
                field("NetCom Scanned Qty."; Rec."NetCom Scanned Qty.")
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                    Editable = false;
                    DecimalPlaces = 0 : 2;
                    Caption = 'NetCom Scanned Qty.';
                    ToolTip = 'Specifies the quantity of the item that has been scanned by NetCom.';
                    StyleExpr = StyleExpression;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ItemTrackingLines)
            {
                ApplicationArea = ItemTracking;
                Caption = 'Item &Tracking Lines';
                Image = ItemTrackingLines;
                ShortCutKey = 'Ctrl+Alt+I';
                Enabled = Rec.Type = Rec.Type::Item;
                ToolTip = 'View or edit serial, lot and package numbers for the selected item. This action is available only for lines that contain an item.';

                trigger OnAction()
                begin
                    Rec.OpenItemTrackingLines();
                end;
            }
            action(UpdateScannedQty)
            {
                ApplicationArea = All;
                Caption = 'Update Scanned Qty.';
                Image = UpdateDescription;
                ToolTip = 'Update the scanned quantity of the selected line.';

                trigger OnAction()
                var
                    NetComScanUpdateQuantity: Page "NetCom Scan Update Quantity";
                begin
                    Clear(NetComScanUpdateQuantity);
                    NetComScanUpdateQuantity.SetTableView(Rec);
                    NetComScanUpdateQuantity.SetRecord(Rec);
                    if NetComScanUpdateQuantity.RunModal() = Action::LookupOK then
                        CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ScannedNoQuickEntry := true;
    end;

    trigger OnAfterGetRecord()
    begin
        // SerialNoRequired := false;
        ScannedNo := '';

        if Rec.Type = Rec.Type::Item then begin
            if Rec."Qty. to Ship" = Rec."NetCom Scanned Qty." then
                StyleExpression := 'Success'
            else
                StyleExpression := 'Attention';
        end else
            StyleExpression := 'Standard';
    end;

    var
        StyleExpression: Text;
        ItemNo: Code[20];
        ScannedItemNo: Code[100];
        ScannedNo: Code[20];
        ScannedSerialNo: Code[2048];
        SerialNoRequired: Boolean;
        ScannedNoQuickEntry: Boolean;
}