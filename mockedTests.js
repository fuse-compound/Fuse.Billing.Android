console.log("Hello world");
var InAppBilling = require("FuseJS/Billing/Android");
var Observable = require("FuseJS/Observable");
var log = Observable("started\n");

function debugLog(msg) {
	console.log("DEBUG: " + msg);
	log.value += msg + "\n";
}

var isBusy = Observable(false);

function runTestSteps() {
	var testSku = "android.test.purchased";
	isBusy.value = true;

	try {
		InAppBilling.queryProductPurchases().then(function(purchases) {
			debugLog("Query product purchases result:\n" + JSON.stringify(purchases));
			var testPurchase = purchases.find(function (x) { return x.productId == testSku; });
			if (testPurchase) {
				debugLog("Starting consume:");
				return InAppBilling.consume(testPurchase)
					.then(function () { debugLog("purchase consumed!"); });
			}
		}).then(function() {
			debugLog("Querying subscription purchases");
			return InAppBilling.querySubscriptionPurchases()
				.then(function(purchases) { debugLog("querySubscriptionPurchases result:\n" + JSON.stringify(purchases)); });
		}).then(function() {
			return InAppBilling.queryProductDetails(testSku)
				.then(function(result) { debugLog("queryProductDetails result:\n" + JSON.stringify(result)); });
		}).then(function() {
			return InAppBilling.purchase(testSku);
		}).then(function(purchase) {
			debugLog("Purchase successful:\n" + JSON.stringify(purchase));
		}).then(function() {
			return InAppBilling.purchase("android.test.canceled");
		}).catch(function (error) {
			log.value += "error: " + error;
		}).then(function() {
			isBusy.value = false;
		});
		//	log.value = JSON.stringify(JSON.parse(inventory), null, "  ");
	}
	catch (error) {
		debugLog("Catched exception:\n" + error);
		isBusy.value = false;
	}
}

module.exports = {
	isBusy: isBusy,
	run: runTestSteps,
	log: log
};
