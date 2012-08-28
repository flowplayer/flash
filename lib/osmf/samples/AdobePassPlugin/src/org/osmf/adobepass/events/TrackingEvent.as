package org.osmf.adobepass.events
{
	import flash.events.Event;

	/**
	 * This event is dispatched on sendTrackingData callback;
	 */ 
	public class TrackingEvent extends Event
	{
		public static const TRACKING:String = "tracking";
		public function TrackingEvent(type:String
										, bubbles:Boolean=false
											, cancelable:Boolean=false
											  , trackingType:String = ""
												, data:Array=null)
		{
			super(type, bubbles, cancelable);
			_trackingType = trackingType;
			_data = data;
		}
		
		public function get data():Array
		{
			return _data;
		}
		
		public function get trackingType():String
		{
			return _trackingType;
		}
		
		private var _data:Array; 
		private var _trackingType:String;
	}
}