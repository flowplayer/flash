package org.flexunit.events
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * <p>The <code>MediaCaseErrorEvent</code> defines events dispatched by a <code>MediaCase</code> instance to indicate
	 * certain general test case scenario events, such as a success, failure, timeout, or a step success.</p>
	 * @author cpillsbury
	 * 
	 */	
	public class MediaCaseErrorEvent extends ErrorEvent
	{
		public static const SUCCESS : String = "success";
		public static const FAILURE : String = "failure";
		public static const TIMEOUT : String = "timeout";
		public static const STEP_SUCCESS : String = "stepSuccess";
		
		/**
		 * Optional error id value for an associated error. 
		 */		
		public var id : int;
		
		/**
		 * Optional trigger event that caused the error event to get dispatched. 
		 */	
		public var triggerEvent : Event;
		
		/**
		 * Optional error to be sent along with the error event, usually one that prompted the event to get dispatched. 
		 */	
		public var error : Error;
		
		public function MediaCaseErrorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false,
											 text : String = "", id : int = 0, error : Error = null, triggerEvent : Event = null )
		{
			super( type, bubbles, cancelable, text );
			
			this.id = id;
			this.error = error;
			this.triggerEvent = triggerEvent;
		}
		
		/**
		 *  @private
		 */
		override public function clone() : Event
		{
			return new MediaCaseErrorEvent( type, bubbles, cancelable,
				text, id, error, triggerEvent );
		}
	}
}