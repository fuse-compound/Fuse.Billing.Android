using Uno;
using Uno.UX;
using Uno.Threading;
using Fuse.Scripting;
using Uno.Permissions;

namespace Fuse.Billing.Android
{
	/**
		@scriptmodule FuseJS/Billing/Android

		Module for in-app purchases and subscriptions.

		Detailed documentation will be provided at a later stage.
		For now see the example `Fuse.Billing.Android.Example` for more information.
	*/
	[UXGlobalModule]
	public class BillingModule : NativeModule
	{
		static readonly BillingModule _instance;
		private IBillingHelper _helper;

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


		private IBillingHelper Helper
		{
			get
			{
				if defined(Android)
				{
					if (_helper == null)
					{
						throw new InvalidOperationException("In app billing not setup, calling setup() first is required.");
					}
					return _helper;
				}
				else
				{
					throw new NotSupportedException("Google play billing API only supported on Android");
				}
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
			@scriptmethod queryProductDetails(sku)
			@param sku Either a single SKU or array of SKU to get details for
			@return (Promise) A promise returning an array of product details

			The properties of the items returned is documented here:

			https://developer.android.com/google/play/billing/billing_reference.html
		*/
		Future<string> QueryProductDetails(object[] args)
		{
			return Helper.QueryProductDetails(ExtractJsonArrayStringArgument(args));
		}

		/**
			@scriptmethod querySubscriptionDetails(sku)
			@param sku Either a single SKU or array of SKU to get details for
			@return (Promise) A promise returning an array of subscription details

			The properties of the items returned is documented here:

			https://developer.android.com/google/play/billing/billing_reference.html
		*/
		Future<string> QuerySubscriptionDetails(object[] args)
		{
			return Helper.QuerySubscriptionDetails(ExtractJsonArrayStringArgument(args));
		}

		/**
			@scriptmethod purchase(sku)
			@param sku Either a product object retrieved using queryProductDetails or a sku string.
			@return (Promise) A promise that returns a JSON object describing the product purchased.

			Starts a purchase of a product. If the purchase is cancelled the promise will be rejected.
		*/
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

		/**
			@scriptmethod subscribe(sku)
			@param sku Either a subscription object retrieved using querySubscriptionDetails or a sku string.
			@return (Promise) A promise that returns a JSON object describing the subscription purchased.

			Starts a subscription. If the purchase is cancelled the returned promise will be rejected.
		*/
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


		/**
			@scriptmethod consume(purchaseItem)
			@param purchaseItem A previous consumable purchase item, retrieved using queryProductPurchases.
			@return (Promise) A promise that returns a JSON object describing the item consumed.

			Consumes a previously purchased item.
		*/
		Future<string> Consume(object[] args)
		{
			return Helper.Consume(Json.Stringify((Scripting.Object)args[0]));
		}


		/**
			@scriptmethod setup(publicKey)
			@param publicKey The public key for your application, from the developer console
			@return (Promise) A promise that's resolved when setup is complete

			This method needs to be called before any other method.
			It will first ask for the com.android.vending.BILLING permission.

			Then it will initialize the billing helper using the provided base-64 encoded
			RSA public key, which can be found under the "Services & APIs" section of
			the Google Play Developer Console.
		*/
		Future<Nothing> Setup(object[] args)
		{
			if defined(Android)
			{
				_helper = new BillingHelper((string)args[0] /* Base64 encoded public key */);
			}
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
