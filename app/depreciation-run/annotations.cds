using AssetService as service from '../../srv/service';

annotate service.DepreciationRun with @(
    UI.HeaderInfo : { TypeName : 'Depreciation Run', TypeNamePlural : 'Depreciation Runs', Title : { Value : Period } },
    UI.LineItem : [
        { Value : FiscalYear, Label : 'Fiscal Year' },
        { Value : Period, Label : 'Period' },
        { Value : TestRun, Label : 'Test Run' },
        { Value : Status, Label : 'Status', Criticality : StatusCriticality }, // Need to define Criticality logic or field
        { $Type : 'UI.DataFieldForAction', Action : 'AssetService.execute', Label : 'Execute Run' }
    ],
    UI.Facets : [ 
        { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Run', Label : 'Run Details' },
        { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Log', Label : 'Log' },
        { $Type : 'UI.ReferenceFacet', Target : 'DepreciationPosting/@UI.LineItem', Label : 'Postings' }
    ],
    UI.FieldGroup #Run : { Data : [ { Value : FiscalYear }, { Value : Period }, { Value : TestRun }, { Value : Status } ] },
    UI.FieldGroup #Log : { Data : [ { Value : Log } ] }
);

annotate service.DepreciationPosting with @(
    UI.LineItem : [
        { Value : Asset_ID, Label : 'Asset' },
        { Value : Amount, Label : 'Amount' },
        { Value : Period, Label : 'Period' }
    ]
);
