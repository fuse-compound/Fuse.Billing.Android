using Uno;
using Uno.Permissions;
using Uno.Threading;

namespace Fuse.Billing.Android
{
	internal interface IBillingHelper
	{
		Future<PlatformPermission> RequestBillingPermission();
		Future<string> QueryProductPurchases();
		Future<string> QueryProductDetails(string skuArrayJsonString);
		Future<string> QuerySubscriptionPurchases();
		Future<string> QuerySubscriptionDetails(string skuArrayJsonString);
		Future<string> Consume(string jsonItemInfo);
		Future<string> Subscribe(string sku, string optionsJsonString);
		Future<string> Purchase(string sku);
		Future<Nothing> Setup();
	}
}
