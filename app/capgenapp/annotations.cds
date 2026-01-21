using { jouleSrv } from '../../srv/service.cds';

annotate jouleSrv.AssetMasters with @UI.DataPoint #CompanyCode: {
  Value: CompanyCode,
  Title: 'Company Code',
};
annotate jouleSrv.AssetMasters with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#CompanyCode', ID: 'CompanyCode' }
];
annotate jouleSrv.AssetMasters with @UI.HeaderInfo: {
  TypeName: 'Asset Master',
  TypeNamePlural: 'Asset Masters',
  Title: { Value: AssetID }
};
annotate jouleSrv.AssetMasters with {
  ID @UI.Hidden
};
annotate jouleSrv.AssetMasters with @UI.Identification: [{ Value: AssetID }];
annotate jouleSrv.AssetMasters with {
  AssetID @Common.Label: 'Asset ID';
  CompanyCode @Common.Label: 'Company Code';
  AssetClass @Common.Label: 'Asset Class';
  Description @Common.Label: 'Description';
  CapitalizedOn @Common.Label: 'Capitalized On';
  DepreciationValues @Common.Label: 'Depreciation Values'
};
annotate jouleSrv.AssetMasters with {
  ID @Common.Text: { $value: AssetID, ![@UI.TextArrangement]: #TextOnly };
};
annotate jouleSrv.AssetMasters with @UI.SelectionFields : [
 CompanyCode,
 AssetClass,
 CapitalizedOn
];
annotate jouleSrv.AssetMasters with @UI.LineItem : [
    { $Type: 'UI.DataField', Value: AssetID },
    { $Type: 'UI.DataField', Value: CompanyCode },
    { $Type: 'UI.DataField', Value: AssetClass },
    { $Type: 'UI.DataField', Value: Description },
    { $Type: 'UI.DataField', Value: CapitalizedOn }
];
annotate jouleSrv.DepreciationValues with @UI.LineItem #depreciationValuesSection: [
    { $Type: 'UI.DataField', Value: AssetID },
    { $Type: 'UI.DataField', Value: DepreciationArea },
    { $Type: 'UI.DataField', Value: AcquisitionValue },
    { $Type: 'UI.DataField', Value: OrdinaryDepreciation }

  ];


annotate jouleSrv.AssetMasters with @UI.Facets: [
  {
    $Type: 'UI.CollectionFacet',
    ID: 'depreciationDetailsTab',
    Label: 'Depreciation Details',
    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'depreciationValuesSection', Label: 'Depreciation Values', Target: 'DepreciationValues/@UI.LineItem#depreciationValuesSection' } ]
  }
];
annotate jouleSrv.DepreciationValues with {
  AssetMaster @Common.ValueList: {
    CollectionPath: 'AssetMasters',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: AssetMaster_ID,
        ValueListProperty: 'ID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'AssetID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'CompanyCode'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'AssetClass'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'Description'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'CapitalizedOn'
      },
    ],
  }
};
annotate jouleSrv.DepreciationValues with @UI.DataPoint #AssetID: {
  Value: AssetID,
  Title: 'Asset ID',
};
annotate jouleSrv.DepreciationValues with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#AssetID', ID: 'AssetID' }
];
annotate jouleSrv.DepreciationValues with @UI.HeaderInfo: {
  TypeName: 'Depreciation Value',
  TypeNamePlural: 'Depreciation Values'
};
annotate jouleSrv.DepreciationValues with {
  AssetID @Common.Label: 'Asset ID';
  DepreciationArea @Common.Label: 'Depreciation Area';
  AcquisitionValue @Common.Label: 'Acquisition Value';
  OrdinaryDepreciation @Common.Label: 'Ordinary Depreciation';
  AssetMaster @Common.Label: 'Asset Master'
};
annotate jouleSrv.DepreciationValues with {
  AssetMaster @Common.Text: { $value: AssetMaster.AssetID, ![@UI.TextArrangement]: #TextOnly };
};
annotate jouleSrv.DepreciationValues with @UI.SelectionFields: [
  AssetMaster_ID
];
annotate jouleSrv.DepreciationValues with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: AssetID },
    { $Type: 'UI.DataField', Value: DepreciationArea },
    { $Type: 'UI.DataField', Value: AcquisitionValue },
    { $Type: 'UI.DataField', Value: OrdinaryDepreciation },
    { $Type: 'UI.DataField', Label: 'Asset Master', Value: AssetMaster_ID }
];
annotate jouleSrv.DepreciationValues with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: AssetID },
    { $Type: 'UI.DataField', Value: DepreciationArea },
    { $Type: 'UI.DataField', Value: AcquisitionValue },
    { $Type: 'UI.DataField', Value: OrdinaryDepreciation },
    { $Type: 'UI.DataField', Label: 'Asset Master', Value: AssetMaster_ID }
]};
annotate jouleSrv.DepreciationValues with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: 'General Information', Target: '@UI.FieldGroup#Main' }
];