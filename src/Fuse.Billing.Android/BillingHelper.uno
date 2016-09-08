using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Permissions;
using Uno.Threading;

namespace Fuse.Billing.Android
{
	[ForeignInclude(Language.Java, "java.util.Arrays")]
	[ForeignInclude(Language.Java, "java.util.List")]
	[ForeignInclude(Language.Java, "java.util.Map")]
	[ForeignInclude(Language.Java, "org.json.JSONException")]
	[ForeignInclude(Language.Java, "com.fuse.billing.android.IabHelper")]
	[ForeignInclude(Language.Java, "com.fuse.billing.android.Purchase")]
	[ForeignInclude(Language.Java, "com.fuse.billing.android.IabException")]
	[ForeignInclude(Language.Java, "com.fuse.billing.android.IabResult")]
	[ForeignInclude(Language.Java, "android.app.Activity")]
	[ForeignInclude(Language.Java, "android.content.Intent")]
	[ForeignInclude(Language.Java, "org.json.JSONObject")]
	extern(Android) internal class BillingHelper : IBillingHelper
	{
		private const string ItemTypeInApp = "inapp";
		private const string ItemTypeSubs = "subs";

		Java.Object _helper;
		NothingPromise _setupPromise;

		public BillingHelper(string publicKey)
		{
			Initialize(publicKey);
		}

		[Foreign(Language.Java)]
		private void Initialize(string publicKey)
		@{
			final IabHelper helper = new IabHelper(com.fuse.Activity.getRootActivity(), publicKey);

			helper.enableDebugLogging(true);

			@{BillingHelper:Of(_this)._helper:Set(helper)};
			com.fuse.Activity.ResultListener resultListener = new com.fuse.Activity.ResultListener() {
				public boolean onResult(int requestCode, int resultCode, Intent data) {
					return helper.handleActivityResult(requestCode, resultCode, data);
				}
			};
			com.fuse.Activity.subscribeToResults(resultListener);
		@}


		public Future<PlatformPermission> RequestBillingPermission()
		{
			return Permissions.Request(BillingPermission.BILLING);
		}


		public Future<string> QueryProductPurchases()
		{
			return RunTask<string, string>(QueryPurchasesSync, ItemTypeInApp);
		}


		public Future<string> QueryProductDetails(string skuArrayJsonString)
		{
			return RunTask<string, string, string>(QuerySkuDetailsSync, ItemTypeInApp, skuArrayJsonString);
		}

		public Future<string> QuerySubscriptionPurchases()
		{
			return RunTask<string, string>(QueryPurchasesSync, ItemTypeSubs);
		}

		public Future<string> QuerySubscriptionDetails(string skuArrayJsonString)
		{
			return RunTask<string, string, string>(QuerySkuDetailsSync, ItemTypeSubs, skuArrayJsonString);
		}


		public Future<string> Consume(string jsonItemInfo)
		{
			return RunTask<string, string>(ConsumeSync, jsonItemInfo);
		}

		public Future<string> Subscribe(string sku)
		{
			var promise = new CustomPromise<string>();
			StartPurchaseFlow(sku, ItemTypeSubs, promise.Resolve, promise.Reject);
			return promise;
		}

		public Future<string> Purchase(string sku)
		{
			var promise = new CustomPromise<string>();
			StartPurchaseFlow(sku, ItemTypeInApp, promise.Resolve, promise.Reject);
			return promise;
		}

		public Future<Nothing> Setup()
		{
			_setupPromise = new NothingPromise();
			Permissions.Request(BillingPermission.BILLING).Then(OnPermissionGranted, OnPermissionFailed);
			return _setupPromise;
		}

		private void OnPermissionGranted(PlatformPermission permission)
		{
			StartSetup(_setupPromise.Resolve, _setupPromise.Reject);
		}

		private void OnPermissionFailed(Exception exception)
		{
			_setupPromise.Reject(exception);
		}

		[Foreign(Language.Java)]
		private string ConsumeSync(string purchaseItemJson)
		@{
			IabHelper helper = (IabHelper)@{BillingHelper:Of(_this)._helper:Get()};
			try {
				helper.consume(purchaseItemJson);
				return purchaseItemJson;
			}
			catch(IabException exception) {
				throw new RuntimeException(exception);
			}
		@}

		[Foreign(Language.Java)]
		private void StartPurchaseFlow(string sku, string itemType, Action<string> onPurchaseFinishedHandler, Action<string> onPurchaseFailedHandler)
		@{
			IabHelper helper = (IabHelper)@{BillingHelper:Of(_this)._helper:Get()};
			Activity activity = com.fuse.Activity.getRootActivity();
			IabHelper.OnIabPurchaseFinishedListener listener =
				new IabHelper.OnIabPurchaseFinishedListener() {
					public void onIabPurchaseFinished(IabResult result, Purchase info) {
						if (!result.isSuccess()) {
							onPurchaseFailedHandler.run(result.getMessage());
						}
						else {
							try {
								String serializedInfo = info.toJSON().toString();
								onPurchaseFinishedHandler.run(serializedInfo);
							}
							catch (JSONException jsonException) {
								onPurchaseFailedHandler.run(jsonException.toString());
							}
						}
					}
				};
			try {
				helper.launchPurchaseFlow(
					activity,
					sku,
					itemType,
					null, // oldSkus (for subscription replacement)
					1337, // request code doesn't matter?
					listener,
					"" // extraData, developer payload. Might add this as an argument.
				);
			} catch(IabHelper.IabAsyncInProgressException exception) {
				onPurchaseFailedHandler.run(exception.toString());
			}
		@}

		[Foreign(Language.Java)]
		private void StartSetup(Action onResolved, Action<string> onRejected)
		@{
			IabHelper helper = (IabHelper)@{BillingHelper:Of(_this)._helper:Get()};
			helper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
				public void onIabSetupFinished(IabResult result) {
					// TODO: Will there be a memory leak here? Probably will, don't know exactly
					//       how Java handles captures of locals to anonymous inner class.
					if (result.isSuccess()) {
						onResolved.run();
					}
					else {
						onRejected.run(result.getMessage());
					}
				}
			});
		@}

		[Foreign(Language.Java)]
		private string QueryPurchasesSync(string itemType)
		@{
			IabHelper helper = (IabHelper)@{BillingHelper:Of(_this)._helper:Get()};
			try {
				return helper.queryPurchasesAsJsonString(itemType);
			}
			catch (IabException exception) {
				throw new RuntimeException(exception);
			}
		@}

		[Foreign(Language.Java)]
		private string QuerySkuDetailsSync(string itemType, string skuArrayJsonString)
		@{
			IabHelper helper = (IabHelper)@{BillingHelper:Of(_this)._helper:Get()};
			try {
				return helper.querySkuDetailsAsJsonString(itemType, skuArrayJsonString);
			}
			catch (IabException exception) {
				throw new RuntimeException(exception);
			}
		@}

		private static Future<TResult> RunTask<T1, T2, T3, TResult>(Func<T1, T2, T3, TResult> del, T1 arg1, T2 arg2, T3 arg3)
		{
			return Promise<TResult>.Run(new SingleInvokeClosure<T1, T2, T3, TResult>(del, arg1, arg2, arg3).Invoke);
		}

		private static Future<TResult> RunTask<T1, T2, TResult>(Func<T1, T2, TResult> del, T1 arg1, T2 arg2)
		{
			return Promise<TResult>.Run(new SingleInvokeClosure<T1, T2, TResult>(del, arg1, arg2).Invoke);
		}

		private static Future<TResult> RunTask<T1, TResult>(Func<T1, TResult> del, T1 arg1)
		{
			return Promise<TResult>.Run(new SingleInvokeClosure<T1, TResult>(del, arg1).Invoke);
		}

		private class NothingPromise : CustomPromise<Nothing>
		{
			public void Resolve()
			{
				base.Resolve(default(Nothing));
			}
		}

		private class CustomPromise<T> : Promise<T>
		{
			// This is a custom promise to make a delegate for Rejecting
			// using a string (message) possible (for Android interop)
			public void Reject(string message)
			{
					try
					{
						throw new InvalidOperationException(message);
					}
					catch (InvalidOperationException exception)
					{
						base.Reject(exception);
					}
			}
		}

		// Closure that's known to only be invoked once, and cleaned up after that call
		private class SingleInvokeClosure<T1, T2, T3, TResult>
		{
			private Func<T1, T2, T3, TResult> _del;
			private T1 _arg1;
			private T2 _arg2;
			private T3 _arg3;

			public SingleInvokeClosure(Func<T1, T2, T3, TResult> del, T1 arg1, T2 arg2, T3 arg3)
			{
				_del = del;
				_arg1 = arg1;
				_arg2 = arg2;
				_arg3 = arg3;
			}

			public TResult Invoke()
			{
				// Clean before calling to avoid cycles
				var del = _del;
				var arg1 = _arg1;
				var arg2 = _arg2;
				var arg3 = _arg3;
				_del = null;
				_arg1 = default(T1);
				_arg2 = default(T2);
				_arg3 = default(T3);
				return del(arg1, arg2, arg3);
			}
		}
		// Closure that's known to only be invoked once, and cleaned up after that call
		private class SingleInvokeClosure<T1, T2, TResult>
		{
			private Func<T1, T2, TResult> _del;
			private T1 _arg1;
			private T2 _arg2;

			public SingleInvokeClosure(Func<T1, T2, TResult> del, T1 arg1, T2 arg2)
			{
				_del = del;
				_arg1 = arg1;
				_arg2 = arg2;
			}

			public TResult Invoke()
			{
				// Clean before calling to avoid cycles
				var del = _del;
				var arg1 = _arg1;
				var arg2 = _arg2;
				_del = null;
				_arg1 = default(T1);
				_arg2 = default(T2);
				return del(arg1, arg2);
			}
		}
		// Closure that's known to only be invoked once, and cleaned up after that call
		private class SingleInvokeClosure<T1, TResult>
		{
			private Func<T1, TResult> _del;
			private T1 _arg1;

			public SingleInvokeClosure(Func<T1, TResult> del, T1 arg1)
			{
				_del = del;
				_arg1 = arg1;
			}

			public TResult Invoke()
			{
				// Clean before calling to avoid cycles
				var del = _del;
				var arg1 = _arg1;
				_del = null;
				_arg1 = default(T1);
				return del(arg1);
			}
		}
	}
}
