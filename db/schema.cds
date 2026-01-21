namespace sap.fiaa;

using { managed, cuid, Currency } from '@sap/cds/common';

entity AssetMaster : cuid, managed {
    // key AssetID : UUID; // Removed redundant key, using cuid's ID
    // User asked for AssetID (UUID, key). cuid gives `ID`.
    // I will use `ID` from cuid as the technical key. If a separate display ID is needed, I'll add `AssetNumber`.
    // However, the prompt says "AssetID (UUID, key)". I'll stick to `ID` from cuid and alias it if needed in UI, or just use `ID`.
    
    CompanyCode : String(4) @mandatory;
    AssetClass : String(10);
    Description : String(255);
    CapitalizedOn : Date;
    CostCenter : String(10);
    UsefulLife : Integer; // In years
    StartDepreciationDate : Date;
    Status : String(20) enum { Active; Blocked; Deleted; Retired; Scrapped } default 'Active';
    
    // Associations
    DepreciationValues : Composition of many DepreciationValues on DepreciationValues.Asset = $self;
}

entity DepreciationValues : cuid {
    Asset : Association to AssetMaster;
    DepreciationArea : String(2); // e.g., 01, 15, 30
    AcquisitionValue : Decimal(15, 2);
    OrdinaryDepreciation : Decimal(15, 2);
    NetBookValue : Decimal(15, 2);
    Currency : Currency;
}

// Process 2: Procurement
entity PurchaseRequisition : cuid, managed {
    Description : String(255);
    Asset : Association to AssetMaster;
    Amount : Decimal(15, 2);
    Status : String(20) enum { Created; Released; Rejected } default 'Created';
}

entity PurchaseOrder : cuid, managed {
    PurchaseRequisition : Association to PurchaseRequisition;
    Vendor : String(100);
    Amount : Decimal(15, 2);
    Status : String(20) enum { Ordered; Delivered; Invoiced } default 'Ordered';
}

entity GoodsReceipt : cuid, managed {
    PurchaseOrder : Association to PurchaseOrder;
    PostingDate : Date;
    DocumentReference : String(20);
}

entity InvoiceReceipt : cuid, managed {
    PurchaseOrder : Association to PurchaseOrder;
    Amount : Decimal(15, 2); // Validated vs PO
    PostingDate : Date; // Becomes Capitalization Date if first acquisition
}

// Process 3: Retirement
entity AssetRetirement : cuid, managed {
    Asset : Association to AssetMaster;
    RetirementDate : Date;
    Amount : Decimal(15, 2); // Proceeds
    Customer : String(100); // Optional
    Type : String(20) enum { Sale; Scrap; Other } default 'Sale';
    Status : String(20) enum { Posted; Reversed } default 'Posted';
}

// Process 4: Valuation
entity AssetValuation : cuid, managed {
    Asset : Association to AssetMaster;
    ValuationDate : Date;
    Amount : Decimal(15, 2);
    Type : String(30) enum { Transfer; PostCapitalization; WriteUp; ManualDepreciation; Reversal };
    DocNumber : String(10); // Logical Accounting Doc Number
}

// Process 5: Month-End Closing
entity DepreciationRun : cuid, managed {
    FiscalYear : String(4);
    Period : String(3); // 001, 002...
    TestRun : Boolean default true;
    Status : String(20) enum { Planned; Executed; Error } default 'Planned';
    Log : LargeString;
}

entity DepreciationPosting : cuid, managed {
    DepreciationRun : Association to DepreciationRun;
    Asset : Association to AssetMaster;
    Amount : Decimal(15, 2);
    FiscalYear : String(4);
    Period : String(3);
}

// Process 6: Year-End Closing
entity YearEndClosing : cuid, managed {
    FiscalYear : String(4);
    Status : String(20) enum { Open; Closed } default 'Open';
    Log : LargeString;
}

// Legacy Migration
entity LegacyAsset : cuid, managed {
    LegacyAssetNumber : String(20);
    Description : String(255);
    AcquisitionDate : Date;
    AcquisitionValue : Decimal(15, 2);
    AccumulatedDepreciation : Decimal(15, 2);
    MigrationDate : Date;
    Status : String(20) enum { Pending; Migrated; Error } default 'Pending';
}

entity LegacyMigrationControl : cuid, managed {
    MigrationID : String(10);
    Status : String(20) enum { Open; Closed } default 'Open'; // Only allow migration if Open
}





