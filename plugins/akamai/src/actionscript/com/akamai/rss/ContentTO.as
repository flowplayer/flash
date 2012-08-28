package com.akamai.rss{
	
	/**
	 * The ContentTO class is a transfer object defining the data representation of
	 * a content node in a media RSS feed.<p />
	 * This class is used by the AkamaiMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 */
	public class ContentTO {

		public var fileSize:Number;
		public var type:String;
		public var medium:String;
		public var isDefault:String;
		public var expression:String;
		public var bitrate:Number;
		public var framerate:Number;
		public var samplingrate:Number;
		public var channels:String;
		public var duration:String;
		public var height:Number;
		public var width:Number;
		public var lang:String;
		public var url:String;
		
	}
}