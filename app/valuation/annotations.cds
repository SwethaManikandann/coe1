using AssetService as service from '../../srv/service';

annotate service.AssetValuation with @(
    UI.HeaderInfo : { TypeName : 'Valuation', TypeNamePlural : 'Valuations', Title : { Value : Type } },
    UI.LineItem : [
        { Value : Asset_ID, Label : 'Asset' },
        { Value : ValuationDate, Label : 'Posting Date' },
        { Value : Type, Label : 'Type' },
        { Value : Amount, Label : 'Amount' },
        { Value : DocNumber, Label : 'Document No' }
    ],
    UI.Facets : [ { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Main', Label : 'Details' } ],
    UI.FieldGroup #Main : { Data : [ { Value : Asset_ID }, { Value : ValuationDate }, { Value : Type }, { Value : Amount } ] }
);
