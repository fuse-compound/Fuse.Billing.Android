
var Observable = require("FuseJS/Observable");
var InAppBilling = require("FuseJS/Billing/Android");

var pubKey = "CONSTRUCT_YOUR_KEY_AND_PLACE_IT_HERE";

var setupCompleted = Observable(false);
var setupMessage = Observable("Running setup");
try {
	InAppBilling.setup(pubKey)
		.then(function() {
			setupCompleted.value = true;
		})
		.catch(function(error) {
			setupMessage.value = "Setup failed:\n" + error;
		});
}
catch (error) {
	setupMessage.value = "Setup failed:\n" + error;
}

module.exports = {
	setupCompleted: setupCompleted,
	setupMessage: setupMessage
};


