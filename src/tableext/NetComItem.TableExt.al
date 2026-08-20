tableextension 50104 "NetCom Item" extends Item
{
    fields
    {
        field(50100; "NetCom Environmental Tax"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Environmental Tax';
            ToolTip = 'Specifies the environmental tax for the item.';
        }
        field(50101; "NetCom Electronic"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Electronic';
            ToolTip = 'Specifies whether the item is electronic.';
        }
        field(50102; "NetCom Packaging"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Packaging';
            ToolTip = 'Packaging.';
        }
        field(50150; "NetCom Item Name 30"; Code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Name 30';
            ToolTip = 'Specifies the item name (30 characters) for the item.';
        }
        field(50151; "NetCom Item Name 60"; Code[60])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Name 60';
            ToolTip = 'Specifies the item name (60 characters) for the item.';
        }
        field(50152; "NetCom Item Name 64"; Text[64])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Name 64';
            ToolTip = 'Specifies the item name (64 characters) for the item.';
        }
        field(50153; "NetCom Sales Text"; Blob)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sales Text';
            ToolTip = 'Specifies the sales text for the item.';
        }
        field(50154; "NetCom Expired replaced by"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Expired replaced by';
            ToolTip = 'Specifies the item number that replaces this item.';
            TableRelation = Item."No.";
        }
        field(50155; "NetCom User Manual (URL)"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'User Manual (URL)';
            ToolTip = 'Specifies the user manual URL for the item.';
        }
        field(50156; "NetCom Item Name 30 (Text)"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Name 30 (Text)';
            ToolTip = 'Specifies the item name (30 characters) for the item as text.';

            trigger OnValidate()
            begin
                Rec.Validate("NetCom Item Name 30", Rec."NetCom Item Name 30 (Text)");
            end;
        }
        field(50157; "NetCom UNSPSC"; Code[8])
        {
            DataClassification = ToBeClassified;
            Caption = 'UNSPSC';
            ToolTip = 'Specifies the UNSPSC code for the item.';
        }
    }

    procedure NetComSetSalesText(SalesText: Text)
    var
        OutStream: OutStream;
    begin
        Clear("NetCom Sales Text");
        "NetCom Sales Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(SalesText);
        Modify();
    end;

    procedure NetComGetSalesText() SalesText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        ReadingDataSkippedMsg: Label 'Loading field %1 will be skipped because there was an error when reading the data.\To fix the current data, contact your administrator.\Alternatively, you can overwrite the current data by entering data in the field.', Comment = '%1=field caption';
    begin
        CalcFields("NetCom Sales Text");
        "NetCom Sales Text".CreateInStream(InStream, TEXTENCODING::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), SalesText) then
            Message(ReadingDataSkippedMsg, FieldCaption("NetCom Sales Text"));
    end;
}