pageextension 50108 "NetCom Item List" extends "Item List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Processing)
        {
            action(NetComExportItemDataExcel)
            {
                ApplicationArea = All;
                Caption = 'Export Item Data (Excel)';
                ToolTip = 'Export separate Excel template for NetCom item data.';
                Image = ExportToExcel;

                trigger OnAction()
                var
                    NetComItemExcelExchange: Codeunit "NetCom Item Excel Exchange";
                begin
                    NetComItemExcelExchange.ExportTemplateToExcel();
                end;
            }

            action(NetComImportItemDataExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Item Data (Excel)';
                ToolTip = 'Import separate Excel template and update NetCom item data.';
                Image = ImportExcel;

                trigger OnAction()
                var
                    NetComItemExcelExchange: Codeunit "NetCom Item Excel Exchange";
                begin
                    NetComItemExcelExchange.ImportTemplateFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }

        addlast(Promoted)
        {
            group(NetComGroup)
            {
                Caption = 'NetCom';
                group(NetComExportImportData)
                {
                    Caption = 'Export/Import Data';
                    actionref(NetComExportItemDataExcel_Promoted; NetComExportItemDataExcel) { }
                    actionref(NetComImportItemDataExcel_Promoted; NetComImportItemDataExcel) { }
                }
            }
        }
    }
}