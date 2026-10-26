codeunit 50108 "NetCom Environmental Tax"
{
    procedure CalculateTax(Item: Record Item; TaxPerKg: Decimal): Decimal
    begin
        if not Item."NetCom Packaging" then
            exit(0);

        exit(Round(PackagingWeight(Item) * TaxPerKg, 0.01));
    end;

    procedure PackagingWeight(Item: Record Item): Decimal
    begin
        if Item."Gross Weight" < Item."Net Weight" then
            exit(0);

        exit(Item."Gross Weight" - Item."Net Weight");
    end;

    procedure UpdateItemTax(var Item: Record Item)
    var
        Setup: Record "NetCom Setup";
    begin
        if Item."NetCom Packaging" then
            Setup.Get();

        Item.Validate("NetCom Environmental Tax", CalculateTax(Item, Setup."Environmental Tax per Kg."));
    end;

    procedure BuildPreview(var Preview: Record "NetCom Env. Tax Preview"; var TaxPerKg: Decimal)
    var
        Setup: Record "NetCom Setup";
        Item: Record Item;
        NewTax: Decimal;
    begin
        Setup.Get();
        TaxPerKg := Setup."Environmental Tax per Kg.";
        Preview.Reset();
        Preview.DeleteAll();
        Item.SetRange("NetCom Packaging", true);
        if Item.FindSet() then
            repeat
                NewTax := CalculateTax(Item, TaxPerKg);
                if Item."NetCom Environmental Tax" <> NewTax then begin
                    Preview.Init();
                    Preview."Item No." := Item."No.";
                    Preview.Description := Item.Description;
                    Preview."Existing Environmental Tax" := Item."NetCom Environmental Tax";
                    Preview."Packaging Weight" := PackagingWeight(Item);
                    Preview."New Environmental Tax" := NewTax;
                    Preview."Item Modified At" := Item.SystemModifiedAt;
                    Preview.Insert();
                end;
            until Item.Next() = 0;
    end;

    procedure ApplyPreview(var Preview: Record "NetCom Env. Tax Preview"; TaxPerKg: Decimal): Integer
    var
        Setup: Record "NetCom Setup";
        Item: Record Item;
        UpdatedCount: Integer;
        SetupChangedErr: Label 'The environmental tax rate has changed. Close the preview and open it again before updating items.';
        ItemChangedErr: Label 'Item %1 has changed or been deleted. Close the preview and open it again before updating items.', Comment = '%1 = Item number';
    begin
        Setup.LockTable();
        Setup.Get();
        if Setup."Environmental Tax per Kg." <> TaxPerKg then
            Error(SetupChangedErr);

        Item.LockTable();
        Preview.Reset();
        if Preview.FindSet() then
            repeat
                if not Item.Get(Preview."Item No.") then
                    Error(ItemChangedErr, Preview."Item No.");
                if (Item.SystemModifiedAt <> Preview."Item Modified At") or
                   (not Item."NetCom Packaging") or
                   (Item."NetCom Environmental Tax" <> Preview."Existing Environmental Tax") or
                   (PackagingWeight(Item) <> Preview."Packaging Weight") or
                   (CalculateTax(Item, TaxPerKg) <> Preview."New Environmental Tax")
                then
                    Error(ItemChangedErr, Preview."Item No.");

                Item.Validate("NetCom Environmental Tax", Preview."New Environmental Tax");
                Item.Modify(true);
                UpdatedCount += 1;
            until Preview.Next() = 0;

        Preview.DeleteAll();
        exit(UpdatedCount);
    end;
}
