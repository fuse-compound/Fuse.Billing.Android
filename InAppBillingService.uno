using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Permissions;
using Uno.Threading;

namespace Fuse.Billing.Android
{
	// NOCOMMIT! Move to its own file
	public enum InAppBillingResponse
	{
		ConnectionError = -1, // RemoteException
		Ok = 0,
		UserCancelled = 1,
		ServiceUnavailable = 2,
		BillingUnavailable = 3,
		ItemUnavailable = 4,
		DeveloperError = 5,
		Error = 6,
		ItemAlreadyOwned = 7,
		ItemNotOwned = 8
	}


	[ForeignInclude(Language.Java, "java.util.Arrays")]
	[ForeignInclude(Language.Java, "java.util.ArrayList")]
	[ForeignInclude(Language.Java, "android.os.RemoteException")]
	[ForeignInclude(Language.Java, "com.android.vending.billing.IInAppBillingService")]
	[ForeignInclude(Language.Java, "android.os.Bundle")]
	extern(Android) public class InAppBillingService
	{
		Java.Object _service;


		[Foreign(Language.Java)]
		private int IsBillingSupportedInternal(int apiVersion, string packageName, string type)
		@{
			try {
				IInAppBillingService service = (IInAppBillingService)@{InAppBillingService:Of(_this)._service:Get()};
				return service.isBillingSupported(apiVersion, packageName, type);
			} catch (RemoteException exception) {
				return -1;
			}
		@}


		[Foreign(Language.Java)]
		private string GetSkuDetailsInternal(int apiVersion, string packageName, string type, string[] skus)
		@{
			try {
				IInAppBillingService service = (IInAppBillingService)@{InAppBillingService:Of(_this)._service:Get()};
				Bundle skusBundle = new Bundle();
				skusBundle.putStringArrayList("ITEM_ID_LIST", new ArrayList(Arrays.asList(skus.copyArray())));
				Bundle resultBundle = service.getSkuDetails(apiVersion, packageName, type, skusBundle);
				StringBuilder jsonBuilder = new StringBuilder();
				jsonBuilder.append("{\"responseCode\":");
				jsonBuilder.append(resultBundle.getInt("RESPONSE_CODE"));
				jsonBuilder.append(",\"detailsList\":");
				jsonBuilder.append('[');
				ArrayList<String> detailsList = resultBundle.getStringArrayList("DETAILS_LIST");
				Boolean first = true;
				for (String skuDetails : detailsList) {
					if (!first)
						jsonBuilder.append(',');
					jsonBuilder.append(skuDetails);
					first = false;
				}
				jsonBuilder.append(']');
				jsonBuilder.append('}');
				return jsonBuilder.toString();
			} catch (RemoteException exception) {
				return null;
			}
		@}

	}
}
