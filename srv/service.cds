using { joule } from '../db/schema.cds';

service jouleSrv {
  @odata.draft.enabled
  entity AssetMasters as projection on joule.AssetMasters;
  entity DepreciationValues as projection on joule.DepreciationValues;
}