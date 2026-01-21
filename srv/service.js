const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const {
        AssetMaster,
        DepreciationValues,
        PurchaseRequisition,
        PurchaseOrder,
        InvoiceReceipt,
        AssetRetirement,
        AssetValuation,
        DepreciationRun,
        DepreciationPosting,
        YearEndClosing,
        LegacyAsset,
        LegacyMigrationControl
    } = this.entities;

    // -----------------------------------------------------------------------
    // Process 1: Asset Master Validation & Logic
    // -----------------------------------------------------------------------
    this.before(['CREATE', 'UPDATE'], AssetMaster, (req) => {
        if (!req.data.CompanyCode && req.method === 'CREATE') {
            req.error(400, 'CompanyCode is mandatory');
        }
    });

    this.before('DELETE', AssetMaster, async (req) => {
        const asset = await SELECT.one.from(AssetMaster).where({ ID: req.data.ID });
        if (!asset) return;

        if (asset.CapitalizedOn) {
            req.error(400, 'Cannot delete capitalized asset. Use Retirement instead.');
        }

        const depValues = await SELECT.from(DepreciationValues).where({ Asset_ID: req.data.ID });
        if (depValues.length > 0) {
            req.error(400, 'Cannot delete asset with depreciation values. Remove values first.');
        }
    });

    this.on('block', AssetMaster, async (req) => {
        await UPDATE(AssetMaster).set({ Status: 'Blocked' }).where({ ID: req.params[0] });
        return this.read(AssetMaster, req.params[0]);
    });

    this.on('unblock', AssetMaster, async (req) => {
        await UPDATE(AssetMaster).set({ Status: 'Active' }).where({ ID: req.params[0] });
        return this.read(AssetMaster, req.params[0]);
    });

    // -----------------------------------------------------------------------
    // Process 2: Procurement Logic (Auto-Capitalization)
    // -----------------------------------------------------------------------
    this.before('CREATE', InvoiceReceipt, async (req) => {
        const { PurchaseOrder_ID, Amount } = req.data;
        if (!PurchaseOrder_ID) return;

        const po = await SELECT.one.from(PurchaseOrder).where({ ID: PurchaseOrder_ID });
        if (!po) req.error(404, 'Purchase Order not found');

        if (Number(Amount) > Number(po.Amount)) {
            req.error(400, `Invoice amount ${Amount} exceeds PO Amount ${po.Amount}`);
        }
    });

    this.after('CREATE', InvoiceReceipt, async (invoice, req) => {
        const po = await SELECT.one.from(PurchaseOrder).where({ ID: invoice.PurchaseOrder_ID });
        if (!po) return;

        const pr = await SELECT.one.from(PurchaseRequisition).where({ ID: po.PurchaseRequisition_ID });
        if (!pr || !pr.Asset_ID) return;

        const assetId = pr.Asset_ID;
        const asset = await SELECT.one.from(AssetMaster).where({ ID: assetId });

        if (!asset.CapitalizedOn) {
            console.log(`Capitalizing Asset ${assetId} on ${invoice.PostingDate}`);
            await UPDATE(AssetMaster).set({
                CapitalizedOn: invoice.PostingDate,
                Status: 'Active'
            }).where({ ID: assetId });
        }

        let depValues = await SELECT.from(DepreciationValues).where({ Asset_ID: assetId, DepreciationArea: '01' });

        if (depValues.length === 0) {
            await INSERT.into(DepreciationValues).entries({
                Asset_ID: assetId,
                DepreciationArea: '01',
                AcquisitionValue: invoice.Amount,
                OrdinaryDepreciation: 0,
                NetBookValue: invoice.Amount,
                Currency_code: 'USD'
            });
        } else {
            const currentAcq = Number(depValues[0].AcquisitionValue || 0);
            const newAcq = currentAcq + Number(invoice.Amount);
            const currentNBV = Number(depValues[0].NetBookValue || 0);
            const newNBV = currentNBV + Number(invoice.Amount);

            await UPDATE(DepreciationValues)
                .set({ AcquisitionValue: newAcq, NetBookValue: newNBV })
                .where({ Asset_ID: assetId, DepreciationArea: '01' });
        }
    });

    // -----------------------------------------------------------------------
    // Process 3: Retirement Logic
    // -----------------------------------------------------------------------
    this.before('CREATE', AssetRetirement, async (req) => {
        const { Asset_ID, RetirementDate, Amount, Type } = req.data;
        const asset = await SELECT.one.from(AssetMaster).where({ ID: Asset_ID });

        if (!asset) req.error(404, 'Asset not found');
        if (asset.Status !== 'Active') req.error(400, `Asset is ${asset.Status}. Only Active assets can be retired.`);
        if (!asset.CapitalizedOn) req.error(400, 'Asset must be capitalized before retirement.');

        if (new Date(RetirementDate) < new Date(asset.CapitalizedOn)) {
            req.error(400, `Retirement Date ${RetirementDate} cannot be before Capitalization Date ${asset.CapitalizedOn}`);
        }

        if (Type === 'Scrap' && Number(Amount) !== 0) {
            req.error(400, 'Scrapped assets must have zero proceeds.');
        }

        const depValues = await SELECT.one.from(DepreciationValues).where({ Asset_ID: Asset_ID, DepreciationArea: '01' });
        const nbv = depValues ? Number(depValues.NetBookValue) : 0;

        if (Number(Amount) > nbv) {
            req.error(400, `Retirement amount (${Amount}) cannot exceed Net Book Value (${nbv}) [Strict Rule]`);
        }
    });

    this.after('CREATE', AssetRetirement, async (retire, req) => {
        const newStatus = retire.Type === 'Scrap' ? 'Scrapped' : 'Retired';
        await UPDATE(AssetMaster).set({ Status: newStatus }).where({ ID: retire.Asset_ID });
    });

    // -----------------------------------------------------------------------
    // Process 4: Valuation Logic
    // -----------------------------------------------------------------------
    this.before('CREATE', AssetValuation, async (req) => {
        const { Asset_ID, Type, Amount } = req.data;
        const asset = await SELECT.one.from(AssetMaster).where({ ID: Asset_ID });

        if (!asset || asset.Status === 'Retired' || asset.Status === 'Scrapped') {
            req.error(400, 'Cannot post valuation to Retired/Scrapped asset.');
        }

        req.data.DocNumber = 'DOC-' + Math.floor(Math.random() * 100000);

        const depValues = await SELECT.one.from(DepreciationValues).where({ Asset_ID: Asset_ID, DepreciationArea: '01' });
        const nbv = depValues ? Number(depValues.NetBookValue) : 0;
        const acq = depValues ? Number(depValues.AcquisitionValue) : 0;

        if (Type === 'ManualDepreciation') {
            if (Number(Amount) > nbv) req.error(400, 'Manual Depreciation cannot exceed Net Book Value');
        }

        if (Type === 'WriteUp') {
            if ((nbv + Number(Amount)) > acq) {
                req.error(400, 'Write-up cannot increase NBV beyond initial Acquisition Value.');
            }
        }
    });

    this.after('CREATE', AssetValuation, async (val, req) => {
        const { Asset_ID, Type, Amount } = val;

        let updateData = {};
        const depValues = await SELECT.one.from(DepreciationValues).where({ Asset_ID: Asset_ID, DepreciationArea: '01' });
        if (!depValues) return;

        let newNBV = Number(depValues.NetBookValue);
        let newAcq = Number(depValues.AcquisitionValue);

        if (Type === 'PostCapitalization') {
            newAcq += Number(Amount);
            newNBV += Number(Amount);
            updateData = { AcquisitionValue: newAcq, NetBookValue: newNBV };
        } else if (Type === 'WriteUp') {
            newNBV += Number(Amount);
            updateData = { NetBookValue: newNBV };
        } else if (Type === 'ManualDepreciation') {
            newNBV -= Number(Amount);
            updateData = { NetBookValue: newNBV };
        }

        if (Object.keys(updateData).length > 0) {
            await UPDATE(DepreciationValues).set(updateData).where({ Asset_ID: Asset_ID, DepreciationArea: '01' });
        }
    });

    // -----------------------------------------------------------------------
    // Process 5: Month-End Closing Logic
    // -----------------------------------------------------------------------
    this.on('execute', DepreciationRun, async (req) => {
        const runId = req.params[0];
        const run = await SELECT.one.from(DepreciationRun).where({ ID: runId });

        if (!run) req.error(404, 'Run not found');
        if (run.Status === 'Executed') req.error(400, 'Run already executed');

        const assets = await SELECT.from(AssetMaster).where({ Status: 'Active' });
        let log = [];
        let postings = [];

        log.push(`Starting Depreciation Run ${run.Period}/${run.FiscalYear} (Test: ${run.TestRun})`);

        for (const asset of assets) {
            const depVal = await SELECT.one.from(DepreciationValues).where({ Asset_ID: asset.ID, DepreciationArea: '01' });
            if (!depVal || !depVal.AcquisitionValue || !asset.UsefulLife) continue;

            const acq = Number(depVal.AcquisitionValue);
            const life = Number(asset.UsefulLife);
            if (life === 0) continue;

            const annualDep = acq / life;
            const monthlyDep = annualDep / 12;

            const nbv = Number(depVal.NetBookValue);
            if (nbv <= 0) continue;

            const actualDep = Math.min(monthlyDep, nbv);

            log.push(`Asset ${asset.Description}: Posted ${actualDep.toFixed(2)}`);

            if (!run.TestRun) {
                postings.push({
                    DepreciationRun_ID: runId,
                    Asset_ID: asset.ID,
                    Amount: actualDep,
                    FiscalYear: run.FiscalYear,
                    Period: run.Period
                });

                const newNBV = nbv - actualDep;
                const newOrdDep = Number(depVal.OrdinaryDepreciation) + actualDep;
                await UPDATE(DepreciationValues).set({
                    NetBookValue: newNBV,
                    OrdinaryDepreciation: newOrdDep
                }).where({ Asset_ID: asset.ID, DepreciationArea: '01' });
            }
        }

        const logString = log.join('\n');

        if (!run.TestRun) {
            if (postings.length > 0) {
                await INSERT.into(DepreciationPosting).entries(postings);
            }
            await UPDATE(DepreciationRun).set({ Status: 'Executed', Log: logString }).where({ ID: runId });
        } else {
            await UPDATE(DepreciationRun).set({ Log: logString }).where({ ID: runId });
        }
    });

    // -----------------------------------------------------------------------
    // Process 6: Year-End Closing
    // -----------------------------------------------------------------------
    this.on('closeYear', YearEndClosing, async (req) => {
        const id = req.params[0];
        const closing = await SELECT.one.from(YearEndClosing).where({ ID: id });

        // Simulating checks
        // 1. All runs executed?
        const openRuns = await SELECT.from(DepreciationRun).where({ FiscalYear: closing.FiscalYear, Status: 'Planned' });
        if (openRuns.length > 0) {
            req.error(400, 'Cannot close year. There are planned depreciation runs remaining.');
        }

        await UPDATE(YearEndClosing).set({ Status: 'Closed', Log: 'Year successfully closed. all periods locked.' }).where({ ID: id });
    });

    // -----------------------------------------------------------------------
    // Legacy Migration
    // -----------------------------------------------------------------------
    this.on('migrate', LegacyAsset, async (req) => {
        const id = req.params[0];
        const legacy = await SELECT.one.from(LegacyAsset).where({ ID: id });

        if (legacy.Status === 'Migrated') req.error(400, 'Already migrated');

        // Check Migration Control
        const control = await SELECT.one.from(LegacyMigrationControl).where({ Status: 'Open' });
        if (!control) req.error(400, 'Migration is not currently open.');

        // Create Asset Master
        const assetDesc = legacy.Description || 'Legacy Asset ' + legacy.LegacyAssetNumber;
        const newAsset = await INSERT.into(AssetMaster).entries({
            CompanyCode: '1000', // Default
            AssetClass: 'LEGACY',
            Description: assetDesc,
            CapitalizedOn: legacy.AcquisitionDate,
            Status: 'Active',
            StartDepreciationDate: legacy.MigrationDate // or Acq Date
        });

        // Create Values with historical data
        // NBV = Acq - AccDep
        const nbv = Number(legacy.AcquisitionValue) - Number(legacy.AccumulatedDepreciation);

        await INSERT.into(DepreciationValues).entries({
            Asset_ID: newAsset.results[0].ID, // Get ID
            DepreciationArea: '01',
            AcquisitionValue: legacy.AcquisitionValue,
            OrdinaryDepreciation: legacy.AccumulatedDepreciation,
            NetBookValue: nbv,
            Currency_code: 'USD'
        });

        await UPDATE(LegacyAsset).set({ Status: 'Migrated', MigrationDate: new Date().toISOString().split('T')[0] }).where({ ID: id });
    });

});
