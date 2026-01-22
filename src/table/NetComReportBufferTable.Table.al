table 50103 "NetCom Report Buffer Table"
{
    Caption = 'Report Buffer Table';
    DataClassification = ToBeClassified;
    // TableType = Temporary;

    fields
    {
        field(1; "User Id"; Code[50])
        {
            Caption = 'User Id';
            DataClassification = ToBeClassified;
        }
        field(2; "Report Id"; Integer)
        {
            Caption = 'Report Id';
            DataClassification = ToBeClassified;
        }
        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(4; "NetCom Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item"."No.";
        }
        field(5; "NetCom Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Description';
        }
        field(11; "Code 01"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "NetCom Document No."; text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Document No.';
        }
        field(13; "Code 03"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Code 04"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Code 05"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Text 01"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Text 02"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Text 03"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Integer 01"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Integer 02"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(71; "NetCom Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DataClassification = ToBeClassified;
        }
        field(72; "NetCom Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = ToBeClassified;
        }
        field(73; "NetCom Weight"; Decimal)
        {
            Caption = 'Weight';
            DataClassification = ToBeClassified;
        }
        field(74; "NetCom Amount sold"; Decimal)
        {
            Caption = 'Amount sold';
            DataClassification = ToBeClassified;
        }
        field(75; "Electronic Net. Weight"; Decimal)
        {
            Caption = 'Electronic Net Weight';
            DataClassification = ToBeClassified;
        }
        field(76; "Decimal 06"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(77; "Decimal 07"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(78; "Decimal 08"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(79; "Decimal 09"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Decimal 10"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(81; "Decimal 11"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(82; "Decimal 12"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(83; "Decimal 13"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(84; "Decimal 14"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(85; "Decimal 15"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(86; "Decimal 16"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(87; "Decimal 17"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(88; "Decimal 18"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(89; "Decimal 19"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Decimal 20"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(91; "Decimal 21"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(92; "Decimal 22"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(93; "Decimal 23"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(94; "Decimal 24"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(95; "Decimal 25"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(96; "Decimal 26"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(97; "Decimal 27"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(98; "Decimal 28"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(99; "Decimal 29"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Decimal 30"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(101; "Decimal 31"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(102; "Decimal 32"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(103; "Decimal 33"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(104; "Decimal 34"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(105; "Decimal 35"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(106; "Decimal 36"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(107; "Decimal 37"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(108; "Decimal 38"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(109; "Decimal 39"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(110; "Decimal 40"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(111; "Decimal 41"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(112; "Decimal 42"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(113; "Decimal 43"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(114; "Decimal 44"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(115; "Decimal 45"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(116; "Decimal 46"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(117; "Decimal 47"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(118; "Decimal 48"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(119; "Decimal 49"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(120; "Decimal 50"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(121; "Decimal 51"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(122; "Decimal 52"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(123; "Decimal 53"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(124; "Decimal 54"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(125; "Decimal 55"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(126; "Decimal 56"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(127; "Decimal 57"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(128; "Decimal 58"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(129; "Decimal 59"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(201; "Date 01"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(202; "Date 02"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(203; "Date 03"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(204; "Date 04"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(205; "Date 05"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(211; "DateTime 01"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(212; "DateTime 02"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(213; "DateTime 03"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "User Id", "Report Id", "Entry No.")
        {
            Clustered = true;
        }
    }
}