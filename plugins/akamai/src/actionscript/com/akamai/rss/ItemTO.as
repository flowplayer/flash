package com.akamai.rss{
	

	import com.akamai.rss.*;
	import flash.events.EventDispatcher;
	 
	[Bindable]
	/**
	 * The ItemTO class is a transfer object defining the data representation of
	 * an item in a media RSS feed.<p/>
	 * This class is used by the AkamaiMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 * 
	 */
	public class ItemTO extends EventDispatcher {

		public var title:String;
		public var author:String;
		public var description:String;
		public var pubDate:String;
		public var enclosure:EnclosureTO;
		public var media:Media;
	}
}