package org.osmf.adobepass.events
{
	import flash.events.Event;

	/**
	 * This event is dispatched on token request state changes.
	 */ 
	public class TokenEvent extends Event
	{		
		public static const TOKEN_REQUEST_FAILED:String = "tokenRequestFailed";
		public static const TOKEN_REQUEST_SUCCESS:String = "tokenRequestSuccess";

		public function TokenEvent(type:String, token:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_token = token;
		}
		
		override public function clone():Event
		{
			return new TokenEvent(type, token, bubbles, cancelable);
		}
		
		public function get token():String
		{
			return _token;
		}

		private var _token:String;

	}
}