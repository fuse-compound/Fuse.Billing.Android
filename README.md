## Introduction

The `Fuse.Billing.Android` library makes it possible to receive payments through Google Play.

The library is partially based on source code from the [TrivialDrive](https://github.com/googlesamples/android-play-billing/tree/master/TrivialDrive)
example from Google.

## Usage

Before writing any code it's a good idea to get familiar with the features and limitations of the In-app billing API by
skimming through the [official documentation for In-app billing](https://developer.android.com/google/play/billing/index.html).
on Android.

### Adding package reference

To use this package we have to start by cloning the
[fusetools/Fuse.Billing.Android](https://github.com/fusetools/Fuse.Billing.Android)
repository. And then inside the `Projects` section of _your_ `.unoproj` file add a reference to
`src/Fuse.Billing.Android/Fuse.Billing.Android.unoproj`.

```
  "Projects": ["../../Fuse.Billing.Android/src/Fuse.Billing.Android/Fuse.Billing.Android.unoproj"]
```

### Initialization

Now we need to require the `FuseJS/Billing/Android` module.

However, before using the API we'll have to call the `setup` function of the module, which will return a promise that
will be resolved when the API is ready for use.

```
var InAppBilling = require("FuseJS/Billing/Android");

InAppBilling.setup("insert your app's public key here")
  .then(function() {
    console.log("Setup completed");
  })
  .catch(function(error) {
    console.log("Setup failed");
  });
```

The `setup` function takes the public key for your application, found in the Google Play Developer Console.

### API summary

One-time item purchases:

- `purchase` - Start purchase of item
- `queryProductPurchases` - Query currently purchased items for the active Google Play user
- `queryProductDetails` - Query details for products, given a list of skus
- `consume` - Consume a purchased item

Subscription items:

- `querySubscriptionPurchases` - Query currently active subscription for Google play user
- `subscribe` - Start purchase of new subscription

The API is asynchronous, and all of the functions returns a [promise](https://www.promisejs.org/).

For now complete [reference documentation](src/Fuse.Billing.Android/BillingModule.uno) for the API can found in the comments of [BillingModule.uno](src/Fuse.Billing.Android/BillingModule.uno).
Proper generated documentation will become available at some later point.

## Testing

It is possible to test one-time purchases _before_ publishing your app, by making use of certain special SKU codes that
returns static predefined responses.

However, for testing subscription purchases publishing is mandatory.

For more information on how to do testing see [Testing In-app Billing](https://developer.android.com/google/play/billing/billing_testing.html)
from the official documentation.

## Example app

There is a test application available in [src/Fuse.Billing.Android.Example](src/Fuse.Billing.Android.Example).

This app got two pages:

* Subscriptions.ux: For testing subscriptions, requires publishing to Play
* MockedTests.ux: Single app purchases using static responses
  - Info about static responses can be found [here](https://developer.android.com/google/play/billing/billing_testing.html)

You can alternate between the pages by dragging sideways. Note that zero effort has been used on esthetiques here.

### Example setup guide

This sample can't be run as-is. You have to create your own
application instance in the Developer Console and modify this
sample to point to it. Here is what you must do:

This setup guide is based on the corresponding [guide](https://github.com/googlesamples/android-play-billing/edit/master/TrivialDrive/README.md)
for the originial "TrivialDrive" example from Google, and adapted for use with included example.

#### On the Google Play Developer Console

1. Create an application on the Developer Console, available at
   https://play.google.com/apps/publish/.

2. Copy the application's public key (a base-64 string). You can find this in
   the "Services & APIs" section under "Licensing & In-App Billing".

#### In the code

3. Open main.js, find the declaration of base64EncodedPublicKey and
   replace the placeholder value with the public key you retrieved in Step 2.

4. Change the sample's package name to your package name. To do that, update the
   package name in .unoproj file.

5. Export an APK, signing it with your PRODUCTION (not debug) developer certificate.

#### Back to the Google Play Developer Console

6. Upload your APK to Google Play for Alpha Testing.

7. Make sure to add your test account (the one you will use to test purchases)
   to the "testers" section of your app. Your test account CANNOT BE THE SAME AS
   THE PUBLISHER ACCOUNT. If it is, your purchases won't go through.

8. Under In-app Products, create MANAGED in-app items with these IDs:
       premium, gas
   Set their prices to 1 dollar. You can choose a different price if you like.

9. Under In-app Products, create SUBSCRIPTION items with these IDs:
       infinite_gas_monthly, infinite_gas_yearly
   Set their prices to 1 dollar and the billing recurrence to monthly for
   `infinite_gas_monthly` and yearly for `infinite_gas_yearly`. To prevent being charged
   while testing, set the trial period to 7 days.

10. Publish your APK to the Alpha channel. Wait 2-3 hours for Google Play to process the APK
   If you don't wait for Google Play to process the APK, you might see errors where Google Play
   says that "this version of the application is not enabled for in-app billing" or something
   similar. Ensure that the In-App products move to the "Active" state within the console before
   testing.

#### Test the code

11. Install the APK signed with your PRODUCTION certificate, to a
test device.
12. Run the app.
13. Make purchases using the test account you added in Step 7.

Remember to refund any real purchases you make, if you don't want the
charges to actually to through. Remember, you can use the tester functionality within
the Google Play console to define test Google Accounts that won't be charged.
When using the tester functionality make sure to look for "Test" language appended
to each receipt. If you don't see "Test" then you will need to be sure to refund/cancel
the charge.

It will be easier to use a test device that doesn't have your
developer account logged in; this is because, if you attempt to purchase
an in-app item using the same account that you used to publish the app,
the purchase will not go through.

## License
-------
Copyright 2016 Fusetools AS

Licensed under the [Apache License,version 2.0](LICENSE).

This software contains modified code from the TrivialDrive example by Google, which is also licensed under the Apache License 2.0. The original source code can be obtained at:

https://github.com/googlesamples/android-play-billing/tree/master/TrivialDrive


