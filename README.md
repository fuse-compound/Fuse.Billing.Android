## Description

This is an example of using the in app billing functionality on Android using a Fuse app.

The app got two views:

* Subscriptions.ux: For testing subscriptions, requires publishing to Play
* MockedTests.ux: Single app purchases using static responses
  - Info about static responses can be found [here](https://developer.android.com/google/play/billing/billing_testing.html)

## Setup guide

NOTE: This setup guide has been adapted from the the corresponding [guide](https://github.com/googlesamples/android-play-billing/edit/master/TrivialDrive/README.md)
for the Google provided InAppBilling example.

This sample can't be run as-is. You have to create your own
application instance in the Developer Console and modify this
sample to point to it. Here is what you must do:

ON THE GOOGLE PLAY DEVELOPER CONSOLE

1. Create an application on the Developer Console, available at
   https://play.google.com/apps/publish/.

2. Copy the application's public key (a base-64 string). You can find this in
   the "Services & APIs" section under "Licensing & In-App Billing".

IN THE CODE

3. Open main.js, find the declaration of base64EncodedPublicKey and
   replace the placeholder value with the public key you retrieved in Step 2.

4. Change the sample's package name to your package name. To do that, update the
   package name in .unoproj file.

5. Export an APK, signing it with your PRODUCTION (not debug) developer certificate.

BACK TO THE GOOGLE PLAY DEVELOPER CONSOLE

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
   infinite_gas_monthly and yearly for infinite_gas_yearly. To prevent being charged
   while testing, set the trial period to 7 days.

10. Publish your APK to the Alpha channel. Wait 2-3 hours for Google Play to process the APK
   If you don't wait for Google Play to process the APK, you might see errors where Google Play
   says that "this version of the application is not enabled for in-app billing" or something
   similar. Ensure that the In-App products move to the "Active" state within the console before
   testing.

TEST THE CODE

11. Install the APK signed with your PRODUCTION certificate, to a
test device.[*]
12. Run the app.
13. Make purchases using the test account you added in Step 7.

Remember to refund any real purchases you make, if you don't want the
charges to actually to through. Remember, you can use the tester functionality within
the Google Play console to define test Google Accounts that won't be charged.
When using the tester functionality make sure to look for "Test" language appended
to each receipt. If you don't see "Test" then you will need to be sure to refund/cancel
the charge.

[*]: it will be easier to use a test device that doesn't have your
developer account logged in; this is because, if you attempt to purchase
an in-app item using the same account that you used to publish the app,
the purchase will not go through.
