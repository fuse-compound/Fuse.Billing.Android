using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Permissions;

namespace Fuse.Billing.Android
{
	[TargetSpecificImplementation]
	internal extern(Android) class BillingPermission
	{
		public static PlatformPermission BILLING
		{
			get
			{
				debug_log "not stripped!";
				return _vending_billing();
			}
		}

		[TargetSpecificImplementation]
		static extern PlatformPermission _vending_billing()
		{
			var name = "com.android.vending.BILLING";
			return extern<PlatformPermission>(name)"@{Uno.Permissions.PlatformPermission(string):New($0)}";
		}
	}
}
