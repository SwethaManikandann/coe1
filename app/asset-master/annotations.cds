using AssetService as service from '../../srv/service';

annotate service.AssetMaster with @(
    UI.HeaderInfo : {
        TypeName : 'Asset',
        TypeNamePlural : 'Assets',
        Title : { $Type : 'UI.DataField', Value : Description },
        Description : { $Type : 'UI.DataField', Value : AssetClass }
    },
    UI.SelectionFields : [ CompanyCode, AssetClass, Status ],
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : CompanyCode, Label : 'Company Code' },
        { $Type : 'UI.DataField', Value : AssetClass, Label : 'Asset Class' },
        { $Type : 'UI.DataField', Value : Description, Label : 'Description' },
        { $Type : 'UI.DataField', Value : Status, Label : 'Status', Criticality: StatusCriticality }, // Need to define Criticality if used
        { $Type : 'UI.DataField', Value : CapitalizedOn, Label : 'Capitalized On' },
        { $Type : 'UI.DataField', Value : NetBookValue, Label : 'Net Book Value' } // Calculated or from assoc? NBV is in DepValues. need assoc.
    ],
    UI.Facets : [
        { $Type : 'UI.ReferenceFacet', Label : 'General Info', Target : '@UI.FieldGroup#General' },
        { $Type : 'UI.ReferenceFacet', Label : 'Depreciation', Target : 'DepreciationValues/@UI.LineItem' }
    ],
    UI.FieldGroup #General : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Value : CompanyCode },
            { $Type : 'UI.DataField', Value : AssetClass },
            { $Type : 'UI.DataField', Value : Description },
            { $Type : 'UI.DataField', Value : CostCenter },
            { $Type : 'UI.DataField', Value : UsefulLife },
            { $Type : 'UI.DataField', Value : StartDepreciationDate },
            { $Type : 'UI.DataField', Value : Status },
            { $Type : 'UI.DataField', Value : CapitalizedOn }
        ]
    }
);

annotate service.DepreciationValues with @(
    UI.LineItem : [
        { $Type : 'UI.DataField', Value : DepreciationArea, Label : 'Area' },
        { $Type : 'UI.DataField', Value : AcquisitionValue, Label : 'Acquisition Value' },
        { $Type : 'UI.DataField', Value : OrdinaryDepreciation, Label : 'Accumulated Dep.' },
        { $Type : 'UI.DataField', Value : NetBookValue, Label : 'Net Book Value' },
        { $Type : 'UI.DataField', Value : Currency_code, Label : 'Currency' }
    ]
);
