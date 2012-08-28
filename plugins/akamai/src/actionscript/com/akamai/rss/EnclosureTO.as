package com.akamai.rss{
	
	/**
	 * The EnclosureTO class is a transfer object defining the data representation of
	 * an enclosure node in a media RSS feed.<p/>
	 * This class is used by the AkamaiMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 * 
	 */
	public class EnclosureTO {

		public var length:Number;
		public var type:String;
		public var url:String;
		
	}
}