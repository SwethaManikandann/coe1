using AssetService as service from '../../srv/service';

annotate service.AssetRetirement with @(
    UI.HeaderInfo : { TypeName : 'Retirement', TypeNamePlural : 'Retirements', Title : { Value : Asset_ID } },
    UI.LineItem : [
        { Value : Asset_ID, Label : 'Asset' },
        { Value : RetirementDate, Label : 'Retirement Date' },
        { Value : Type, Label : 'Type' },
        { Value : Amount, Label : 'Amount (Proceeds)' },
        { Value : Customer, Label : 'Customer' },
        { Value : Status, Label : 'Status' }
    ],
    UI.FieldGroup #Main : { Data : [ { Value : Asset_ID }, { Value : RetirementDate }, { Value : Type }, { Value : Amount }, { Value : Customer } ] },
    UI.Facets : [ { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Main', Label : 'Retirement Details' } ]
);
