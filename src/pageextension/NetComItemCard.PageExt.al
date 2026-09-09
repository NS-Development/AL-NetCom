pageextension 50107 "NetCom Item Card" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("NetCom Environmental Tax"; Rec."NetCom Environmental Tax")
            {
                ApplicationArea = All;
            }
            field("NetCom Packaging"; Rec."NetCom Packaging")
            {
                ApplicationArea = All;
            }
            field("NetCom Electronic"; Rec."NetCom Electronic")
            {
                ApplicationArea = All;
            }
        }
        addlast(content)
        {
            group(NetComItemExport)
            {
                Caption = 'NetCom Item Export Data';
                field("NetCom UNSPSC"; Rec."NetCom UNSPSC")
                {
                    ApplicationArea = All;
                }
                field("NetCom Item Name 30 (Text)"; Rec."NetCom Item Name 30 (Text)")
                {
                    ApplicationArea = All;
                }
                field("NetCom Item Name 30"; Rec."NetCom Item Name 30")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NetCom Item Name 60"; Rec."NetCom Item Name 60")
                {
                    ApplicationArea = All;
                }
                field("NetCom Item Name 64"; Rec."NetCom Item Name 64")
                {
                    ApplicationArea = All;
                }
                field("NetCom Expired replaced by"; Rec."NetCom Expired replaced by")
                {
                    ApplicationArea = All;
                }
                field("NetCom User Manual (URL)"; Rec."NetCom User Manual (URL)")
                {
                    ApplicationArea = All;
                }
            }
            group(NetComSalesText)
            {
                Caption = 'Sales Text';

                field("Sales Text"; SalesText)
                {
                    ToolTip = 'Specifies the sales text for the item.';
                    ApplicationArea = All;
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        Rec.NetComSetSalesText(SalesText);
                    end;
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(NetComImportItemExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Item Data (Excel)';
                ToolTip = 'Imports item export fields from an Excel file.';
                Image = ImportExcel;

                trigger OnAction()
                var
                    NetComItemExcelImport: Codeunit "NetCom Item Excel Import";
                begin
                    NetComItemExcelImport.ImportItemDataFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
        addlast(navigation)
        {
            action(NetComCustItemAssortment)
            {
                ApplicationArea = All;
                Caption = 'Item Assortment';
                ToolTip = 'Item Assortment';
                Image = ItemTrackingLines;

                trigger OnAction()
                var
                    CustItemAssortment: Record "NetCom Cust. Item Assortment";
                begin
                    CustItemAssortment.Reset();
                    CustItemAssortment.SetRange("Item No.", Rec."No.");
                    PAGE.Run(PAGE::"NetCom Cust. Item Assortment", CustItemAssortment);
                end;
            }
        }

        addlast(Category_Category4)
        {
            actionref(NetComCustItemAssortment_Promoted; NetComCustItemAssortment) { }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SalesText := Rec.NetComGetSalesText();
    end;

    var
        SalesText: Text;
}