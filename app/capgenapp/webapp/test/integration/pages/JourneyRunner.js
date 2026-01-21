sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"capgenapp/test/integration/pages/AssetMastersList",
	"capgenapp/test/integration/pages/AssetMastersObjectPage"
], function (JourneyRunner, AssetMastersList, AssetMastersObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('capgenapp') + '/test/flpSandbox.html#capgenapp-tile',
        pages: {
			onTheAssetMastersList: AssetMastersList,
			onTheAssetMastersObjectPage: AssetMastersObjectPage
        },
        async: true
    });

    return runner;
});

