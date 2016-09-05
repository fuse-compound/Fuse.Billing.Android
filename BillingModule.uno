using Uno;
using Uno.UX;
using Uno.Threading;
using Fuse.Scripting;
using Uno.Permissions;

namespace Fuse.Billing.Android
{
	[UXGlobalModule]
	public class BillingModule : NativeModule
	{
		static readonly BillingModule _instance;
		extern(Android) private BillingHelper _helper;

		public BillingModule()
		{
			if (_instance != null) return;
			Resource.SetGlobalKey(_instance = this, "FuseJS/Billing/Android");

			AddMember(new NativePromise<string, object>("queryProductPurchases", QueryProductPurchases, ParseJson));
			AddMember(new NativePromise<string, object>("querySubscriptionPurchases", QuerySubscriptionPurchases, ParseJson));
			AddMember(new NativePromise<string, object>("queryProductDetails", QueryProductDetails, ParseJson));
			AddMember(new NativePromise<string, object>("querySubscriptionDetails", QuerySubscriptionDetails, ParseJson));
			AddMember(new NativePromise<string, object>("purchase", Purchase, ParseJson));
			AddMember(new NativePromise<string, object>("subscribe", Subscribe, ParseJson));
			AddMember(new NativePromise<string, object>("consume", Consume, ParseJson));
			AddMember(new NativePromise<Nothing, object>("setup", Setup, ToUndefined));
		}


		extern(Android) private BillingHelper Helper
		{
			get
			{
				if (_helper == null)
				{
					throw new InvalidOperationException("In app billing not setup, calling setup() first is required.");
				}
				return _helper;
			}
		}


		/**
			@scriptmethod queryProductPurchases()
			@return (Promise) A promise returning an array of purchased product items

			Purchases a normal product by sku
		*/
		Future<string> QueryProductPurchases(object[] args)
		{
			return Helper.QueryProductPurchases();
		}


		/**
			@scriptmethod querySubscriptionPurchases()
			@return (Promise) A promise returning an array of purchased subscriptions

			Purchases a subscription by sku of subscription.
		*/
		Future<string> QuerySubscriptionPurchases(object[] args)
		{
			return Helper.QuerySubscriptionPurchases();
		}


		/**
			@scriptmethod queryProductDetails()
			@param sku(s) Either a single SKU or array of SKU to get details for
			@return (Promise) A promise returning an array of product details

			The properties of the items returned is documented here:

			https://developer.android.com/google/play/billing/billing_reference.html
		*/
		Future<string> QueryProductDetails(object[] args)
		{
			return Helper.QueryProductDetails(ExtractJsonArrayStringArgument(args));
		}

		Future<string> QuerySubscriptionDetails(object[] args)
		{
			return Helper.QuerySubscriptionDetails(ExtractJsonArrayStringArgument(args));
		}

		Future<string> Purchase(object[] args)
		{
			var argErrorMessage = "First argument must either be a string or sku details object.";
			if (args.Length < 1)
				throw new ArgumentException(argErrorMessage);
			var argAsObj = args[0] as Scripting.Object;
			string sku = argAsObj != null ? (argAsObj["productId"] as string) : (args[0] as string);
			if (sku == null)
				throw new ArgumentException(argErrorMessage);
			return Helper.Purchase(sku);
		}

		Future<string> Subscribe(object[] args)
		{
			var argErrorMessage = "First argument must either be a string or sku details object.";
			if (args.Length < 1)
				throw new ArgumentException(argErrorMessage);
			var argAsObj = args[0] as Scripting.Object;
			string sku = argAsObj != null ? (argAsObj["productId"] as string) : (args[0] as string);
			if (sku == null)
				throw new ArgumentException(argErrorMessage);
			return Helper.Subscribe(sku);
		}

		Future<string> Consume(object[] args)
		{
			return Helper.Consume(Json.Stringify((Scripting.Object)args[0]));
		}


		Future<Nothing> Setup(object[] args)
		{
			_helper = new BillingHelper((string)args[0] /* Base64 encoded public key */);
			// TODO: Actually await the permission request
			Helper.RequestBillingPermission();
			return Helper.Setup();
		}


		static string ExtractJsonArrayStringArgument(object[] args)
		{
			var argErrorMessage = "First argument must either be a sku or array of skus";
			if (args.Length < 1)
				throw new ArgumentException(argErrorMessage);
			var argAsArray = args[0] as Scripting.Array;
			string skuArrayJsonString = null;
			if (argAsArray != null)
			{
				skuArrayJsonString = Json.Stringify(argAsArray);
			}
			else
			{
				var argAsString = args[0] as string;
				if (argAsString != null)
				{
					skuArrayJsonString = "[" + Json.Escape(argAsString) + "]";
				}
			}
			if (skuArrayJsonString == null)
				throw new ArgumentException(argErrorMessage);
			return skuArrayJsonString;
		}

		static object ParseJson(Context context, string jsonString)
		{
			return context.ParseJson(jsonString);
		}

		static object ToUndefined<T>(Context context, T nothing)
		{
			return context.Evaluate("(no file)", "undefined");
		}
	}
}
