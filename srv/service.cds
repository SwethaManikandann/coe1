using { sap.fiaa as my } from '../db/schema';

service AssetService {
    @odata.draft.enabled
    entity AssetMaster as projection on my.AssetMaster actions {
        action block();
        action unblock();
    };

    entity DepreciationValues as projection on my.DepreciationValues;

    // Process 2: Procurement
    @odata.draft.enabled
    entity PurchaseRequisition as projection on my.PurchaseRequisition;
    entity PurchaseOrder as projection on my.PurchaseOrder;
    entity GoodsReceipt as projection on my.GoodsReceipt;
    entity InvoiceReceipt as projection on my.InvoiceReceipt;

    // Process 3: Retirement
    @odata.draft.enabled
    entity AssetRetirement as projection on my.AssetRetirement;

    // Process 4: Valuation
    @odata.draft.enabled
    entity AssetValuation as projection on my.AssetValuation;

    // Process 5: Month-End Closing
    @odata.draft.enabled
    entity DepreciationRun as projection on my.DepreciationRun actions {
        action execute();
    };
    entity DepreciationPosting as projection on my.DepreciationPosting;

    // Process 6 & Legacy
    entity YearEndClosing as projection on my.YearEndClosing actions {
        action closeYear();
    };
    entity LegacyAsset as projection on my.LegacyAsset actions {
        action migrate();
    };
    entity LegacyMigrationControl as projection on my.LegacyMigrationControl;
}