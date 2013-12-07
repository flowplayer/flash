package org.osmf.adobepass.events
{
	import flash.events.Event;

	/**
	 * This event is dispatched on Authentication state changes.
	 */ 
	public class AuthenticationEvent extends Event
	{
		public static const AUTHN_SUCCESS:String = "authnSuccess";
		public static const AUTHN_FAILED:String = "authnFailed";		

		public function AuthenticationEvent(type:String, errorCode:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_errorCode = errorCode;
		}
		
		override public function clone():Event
		{
			return new AuthenticationEvent(type, errorCode, bubbles, cancelable);
		}
		
		public function get errorCode():String
		{
			return _errorCode;
		}

		private var _errorCode:String;

	}
}