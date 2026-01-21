using AssetService as service from '../../srv/service';

// Procurement Annotations

annotate service.PurchaseRequisition with @(
    UI.HeaderInfo : { TypeName : 'Purchase Requisition', TypeNamePlural : 'Purchase Requisitions', Title : { Value : Description } },
    UI.LineItem : [
        { Value : Description, Label : 'Description' },
        { Value : Asset_ID, Label : 'Asset' },
        { Value : Amount, Label : 'Amount' },
        { Value : Status, Label : 'Status', Criticality : StatusCriticality }
    ],
    UI.Facets : [ { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Main', Label : 'Main Info' } ],
    UI.FieldGroup #Main : { Data : [ { Value : Description }, { Value : Asset_ID }, { Value : Amount }, { Value : Status } ] }
);

annotate service.PurchaseOrder with @(
    UI.HeaderInfo : { TypeName : 'Purchase Order', TypeNamePlural : 'Purchase Orders', Title : { Value : ID } },
    UI.LineItem : [
        { Value : ID, Label : 'PO Number' },
        { Value : Vendor, Label : 'Vendor' },
        { Value : Amount, Label : 'Amount' },
        { Value : Status, Label : 'Status' }
    ],
    UI.Facets : [
        { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Main', Label : 'PO Details' },
        { $Type : 'UI.ReferenceFacet', Target : 'GoodsReceipt/@UI.LineItem', Label : 'Goods Receipts' },
        { $Type : 'UI.ReferenceFacet', Target : 'InvoiceReceipt/@UI.LineItem', Label : 'Invoices' }
    ],
    UI.FieldGroup #Main : { Data : [ { Value : Vendor }, { Value : Amount }, { Value : Status } ] }
);

annotate service.InvoiceReceipt with @(
    UI.LineItem : [
        { Value : ID, Label : 'Invoice No' },
        { Value : Amount, Label : 'Amount' },
        { Value : PostingDate, Label : 'Posting Date' }
    ]
);
