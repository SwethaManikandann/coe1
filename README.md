# SAP FI-AA Asset Accounting (CAP + Fiori Elements)

This project implements an End-to-End Asset Accounting solution using SAP Cloud Application Programming Model (CAP) and Fiori Elements.

## Features
- **Process 1: Asset Master Management**: Create, Edit, Block, Delete Assets.
- **Process 2: Procurement**: Integrated flow (PR -> PO -> GR -> Invoice) with **Auto-Capitalization**.
- **Process 3: Retirement**: Sale and Scrapping of assets with validation.
- **Process 4: Valuation**: Post-Capitalization, Write-Ups, Manual Depreciation.
- **Process 5: Month-End Closing**: Depreciation Run Cockpit (Simulation & Posting).
- **Process 6: Year-End Closing**: Fiscal Year controlling.
- **Legacy Migration**: Tool to migrate legacy assets.

## Project Structure
- `db/schema.cds`: Data Models (AssetMaster, Procurement, Valuation, etc.)
- `srv/service.cds`: OData Service Definitions & Actions
- `srv/service.js`: Business Logic & Validations (Strict Waterfall implementation)
- `app/`: Fiori Elements Annotations (Asset Master, Procurement, Retirement, Valuation, Dep Run)

## Setup & Deployment

### Local Development
1. Install dependencies:
   ```bash
   npm install
   ```
2. Run locally (requires HANA or SQLite, configured for HANA in package.json):
   ```bash
   cds watch
   ```
   *Note: If using SQLite locally, ensure `@cap-js/sqlite` is installed and `package.json` uses `sql` kind `sqlite`.*

### Deployment to SAP HANA Cloud
1. Build the project:
   ```bash
   npm run build
   ```
   This generates the `mta_archives/asset-accounting_1.0.0.mtar` file.

2. Deploy to Cloud Foundry:
   ```bash
   npm run deploy
   ```
   *Ensure you are logged into CF (`cf login`) and targeting a space with HANA Cloud entitlement.*

## Fiori Apps
Once deployed or running locally, access the Launchpad or individual apps via:
- **Asset Management**: `/webapp/index.html#Asset-manage`
- **Procurement**: `/webapp/index.html#PurchaseOrder-manage`
- **Depreciation Run**: `/webapp/index.html#DepreciationRun-manage`

## Test Scripts
1. **Create Asset**: Go to Asset App -> Create.
2. **Procure**: Create PO, then create Invoice -> Verify Asset Capitalization Date.
3. **Retire**: Create Asset Retirement -> Verify Asset Status change.
4. **Depreciation**: Create Depreciation Run (Test=True) -> Execute -> Check Log.
