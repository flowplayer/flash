package com.akamai.rss{
	

	import flash.events.EventDispatcher;
	
	[Bindable]
	/**
	 * The ThumbnailTO class is a transfer object defining the data representation of
	 * a thumbnail node in a media RSS feed.<p/>
	 * This class is used by the AkamaiMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 * 
	 * 
	 */
	public class ThumbnailTO extends EventDispatcher{

		public var height:Number;
		public var width:Number;
		public var time:String;
		public var url:String;
		
	}
}