namespace joule;

entity AssetMasters {
  key ID: UUID;
  AssetID: String @assert.unique @mandatory;
  CompanyCode: String(10);
  AssetClass: String(50);
  Description: String(100);
  CapitalizedOn: Date;
  DepreciationValues: Association to many DepreciationValues on DepreciationValues.AssetMaster = $self;
}

entity DepreciationValues {
  key ID: UUID;
  AssetID: String;
  DepreciationArea: String(50);
  AcquisitionValue: Decimal;
  OrdinaryDepreciation: Decimal;
  AssetMaster: Association to AssetMasters;
}
