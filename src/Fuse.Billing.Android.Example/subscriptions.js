var InAppBilling = require("FuseJS/Billing/Android");
var Observable = require("FuseJS/Observable");

var querySubscriptionPurchasesMockResult =
[
	{
		"orderId": "mock1337",
		"packageName": "mock",
		"productId": "infinite_gas_monthly",
		"itemType": "subs",
		"autoRenewing": true
	}
];

var log = Observable("");
var sku = Observable("infinite_gas_monthly");
var subscriptionPurchases = Observable(querySubscriptionPurchasesMockResult);

function debugLog(msg, o) {
	if (o) {
		msg += " " + JSON.stringify(o, null, "  ");
	}
	console.log(msg);
	log.value += msg + "\n";
}

function refresh() {
	InAppBilling.querySubscriptionPurchases()
		.then(function(result) {
			subscriptionPurchases.value = result;
			debugLog("querySubscriptionPurchases RESULT:", result);
		}).catch(function(error) {
			debugLog("querySubscriptionPurchases ERROR: " + error);
		});
}

function subscribe() {
	InAppBilling.subscribe(sku.value)
		.then(function(result) {
			debugLog("subscribe result: ", result);
		}).catch(function(error) {
			debugLog("subscribe ERROR: " + error);
		});
}

module.exports = {
	subscriptionPurchases: subscriptionPurchases.map(function(x) { return JSON.stringify(x, null, "  "); }),
	refresh: refresh,
	subscribe: subscribe,
	sku: sku,
	log: log
};

