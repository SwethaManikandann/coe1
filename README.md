# Getting Started

Welcome to your new project.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | content for UI frontends goes here
`db/` | your domain models and data go here
`srv/` | your service models and code go here
`package.json` | project metadata and configuration
`readme.md` | this getting started guide


## Next Steps

- Open a new terminal and run `cds watch`
- (in VS Code simply choose _**Terminal** > Run Task > cds watch_)
- Start adding content, for example, a [db/schema.cds](db/schema.cds).


## Learn More

Learn more at https://cap.cloud.sap/docs/get-started/.


This CAP project and the included SAP Fiori application were generated with the Project Accelerator, using the prompt: You are acting as a Senior SAP S&#x2F;4HANA Asset Accounting (FI-AA) Solution Architect and SAP CAP (Node.js) Backend Developer.

Your task is to design and implement an END-TO-END SAP FI-AA Asset Accounting application FROM SCRATCH using SAP CAP on SAP HANA Cloud with a metadata-driven Fiori Elements UI.

==================================================== PROJECT PRINCIPLES (MANDATORY)
Follow a STRICT WATERFALL MODEL
Implement processes SEQUENTIALLY (Process 1 → Process 6)
NEVER refactor, modify, or break earlier processes
SAP Best Practices scope item: J62\_SA
Backend: SAP CAP (Node.js)
Database: SAP HANA Cloud ONLY (no SQLite, no mocks)
UI: Fiori Elements ONLY (no freestyle UI)
Seed data must load automatically via CSV on deploy
All logic must be realistic but simulated (no real FI&#x2F;MM integration)
==================================================== ARCHITECTURE
CAP Project Structure: &#x2F;db
schema.cds
data&#x2F;\*.csv &#x2F;srv
service.cds
service.js &#x2F;app
Fiori Elements apps
OData V4 services
Clear associations for navigation
Logical accounting document numbers
==================================================== PROCESS 1 — ASSET MASTER CREATION
Goal: Create Asset Master records.

Data Model: AssetMaster

AssetID (UUID, key)
CompanyCode (mandatory)
AssetClass
Description
CapitalizedOn (nullable)
CostCenter
UsefulLife
StartDepreciationDate
Status (Active | Blocked | Deleted)
CreatedBy
CreatedOn
DepreciationValues

ID (UUID, key)
AssetID (association)
DepreciationArea
AcquisitionValue
OrdinaryDepreciation
NetBookValue
Business Rules:

CompanyCode mandatory
Mandatory fields validated
Delete blocked if capitalized or depreciation exists
Block action only updates status
UI:

Home: “Asset Master Management”
List Report + Object Page
Tabs: Overview | Depreciation | History
Actions: Create, Edit, Delete, Block
==================================================== PROCESS 2 — ASSET ACQUISITION VIA PROCUREMENT (PR → PO → GR → INVOICE)
Entities:

PurchaseRequisition
PurchaseOrder
GoodsReceipt
InvoiceReceipt
AssetValue
Rules:

Asset must exist &amp; be Active
No skipping steps
Capitalization occurs at Invoice Receipt
Invoice amount validated vs PO
Asset values updated automatically
UI Flow: Asset → PR → PO → GR → IR

==================================================== PROCESS 3 — ASSET RETIREMENT
Scenarios:

Retirement with Customer (SALE)
Retirement without Customer
Scrapping
Entity: AssetRetirement

Rules:

Asset must be Active &amp; capitalized
Retirement date ≥ capitalization date
Retirement amount ≤ Net Book Value
Scrapped assets have zero proceeds
Asset status becomes Retired or Scrapped
Asset locked from future postings
==================================================== PROCESS 4 — ASSET VALUATION
Scenarios:

Transfer within Company Code
Post-Capitalization
Write-Up
Manual Depreciation
Reversal
Entities:

AssetValuation
AssetValueHistory
Rules:

Asset must be Active &amp; capitalized
Retired assets blocked
Net Book Value never &lt; 0
Write-up limited to acquisition value
==================================================== PROCESS 5 — MONTH-END CLOSING
Entities:

DepreciationRun
DepreciationPosting
MonthEndStatus
Rules:

Test run before productive run
Retired assets excluded
No postings in closed period
Planned depreciation only
NBV cannot go below zero
UI:

Depreciation Run cockpit
Read-only reports:
Asset Balances
Asset Transactions
Depreciation List
==================================================== PROCESS 6 — YEAR-END CLOSING
Rules:

All months must be closed
Final depreciation posted
Year locked after close
Carry forward balances
==================================================== LEGACY ASSET MIGRATION
Entities:

LegacyAsset
LegacyAssetValue
LegacyMigrationControl
Rules:

Migration allowed only before completion
Capitalization date must be historical
Net Book Value = Acquisition – Accumulated Depreciation
Legacy assets excluded from procurement
Once migration completed → locked forever
==================================================== SERVICE LAYER
All validations in srv&#x2F;service.js
before CREATE &#x2F; UPDATE hooks
Logical accounting document numbers
Audit fields everywhere
Delete disabled after financial impact
==================================================== UI REQUIREMENTS
Separate Fiori apps or sections per process
Crystal-clear navigation flow
Status visible at every step
Confirmation dialogs
Success &amp; error toasts
Dropdown value helps
==================================================== DELIVERABLES
db&#x2F;schema.cds (complete)
srv&#x2F;service.cds
srv&#x2F;service.js (all validations &amp; logic)
CSV seed data for all master tables
Fiori Elements UI annotations
Deployment configuration for HANA Cloud
README with:
Build steps
Deploy steps
Fiori preview URLs
Test flow mapping to SAP transactions
==================================================== FINAL INSTRUCTION
Build EVERYTHING in ONE COHERENT OUTPUT
Respect process order strictly
Do not leave placeholders
Assume this is a real enterprise implementation
Output production-ready code and explanations
BEGIN IMPLEMENTATION NOW.

Joule
cap-gen-app
You have requested a complex task. These are the steps I propose for performing it. Please review them, if needed enhance the content, and then execute them sequentially.

1. Generate CAP data model:

Define 11 data entities: AssetMaster, DepreciationValues, PurchaseRequisition, PurchaseOrder, GoodsReceipt, InvoiceReceipt, AssetValue, AssetRetirement, AssetValuation, AssetValueHistory, LegacyAsset. AssetMaster have properties: AssetID in UUID and key, CompanyCode in string and mandatory, AssetClass in string, Description in string, CapitalizedOn in date and nullable, CostCenter in string, UsefulLife in integer, StartDepreciationDate in date, Status in string and enum (Active | Blocked | Deleted), CreatedBy in string, CreatedOn in date. DepreciationValues have properties: ID in UUID and key, AssetID in association to AssetMaster, DepreciationArea in string, AcquisitionValue in decimal, OrdinaryDepreciation in decimal, NetBookValue in decimal. PurchaseRequisition have properties: ID in UUID and key, AssetID in association to AssetMaster, Description in string, Quantity in integer, UnitPrice in decimal. PurchaseOrder have properties: ID in UUID and key, RequisitionID in association to PurchaseRequisition, OrderDate in date, Supplier in string. GoodsReceipt have properties: ID in UUID and key, OrderID in association to PurchaseOrder, ReceiptDate in date, QuantityReceived in integer. InvoiceReceipt have properties: ID in UUID and key, ReceiptID in association to GoodsReceipt, InvoiceDate in date, Amount in decimal. AssetValue have properties: ID in UUID and key, AssetID in association to AssetMaster, ValueDate in date, Value in decimal. AssetRetirement have properties: ID in UUID and key, AssetID in association to AssetMaster, RetirementDate in date, RetirementType in string and enum (SALE | SCRAP), Amount in decimal. AssetValuation have properties: ID in UUID and key, AssetID in association to AssetMaster, ValuationDate in date, ValuationType in string and enum (TRANSFER | POST\_CAPITALIZATION | WRITE\_UP | MANUAL\_DEPRECIATION | REVERSAL), Amount in decimal. AssetValueHistory have properties: ID in UUID and key, AssetID in association to AssetMaster, HistoryDate in date, Value in decimal. LegacyAsset have properties: ID in UUID and key, AssetID in association to AssetMaster, MigrationDate in date, HistoricalValue in decimal.

2. Generate CAP sample data:

Generate sample data per requirement: Seed data must load automatically via CSV on deploy for AssetMaster, DepreciationValues, PurchaseRequisition, PurchaseOrder, GoodsReceipt, InvoiceReceipt, AssetValue, AssetRetirement, AssetValuation, AssetValueHistory, LegacyAsset.

3. Generate CAP application logic:

Implement logic to validate mandatory fields, block delete if capitalized or depreciation exists, update asset status to blocked, ensure no skipping steps in procurement, validate invoice amount vs PO, update asset values automatically, ensure retirement date ≥ capitalization date, ensure retirement amount ≤ Net Book Value, block retired assets from future postings, ensure Net Book Value never &lt; 0, limit write-up to acquisition value, exclude retired assets from month-end closing, ensure no postings in closed period, ensure all months closed before year-end closing, lock year after close, carry forward balances, allow legacy asset migration only before completion, ensure capitalization date is historical, calculate Net Book Value as Acquisition – Accumulated Depreciation, exclude legacy assets from procurement, lock legacy assets forever after migration..
