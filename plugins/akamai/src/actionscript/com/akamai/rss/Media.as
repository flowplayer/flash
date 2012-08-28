package com.akamai.rss{
	

	import com.akamai.rss.*;
	import flash.events.EventDispatcher;
	
	[Bindable]
	/**
	 * The Media class holds the data referenced by the media namespace in a RSS file. 
	 * This class is used by the AkamaiMediaRSS class and is not invoked directly by
	 * end users.<p/>
	 * The properties in this class (with the exception of <code>ContentArray</code>) are defined by the Media RSS specification which can
	 * be viewed at <a href="http://search.yahoo.com/mrss" target="_blank">http://search.yahoo.com/mrss</a>.
	 * 
	 */
	public class Media extends EventDispatcher{
		/**
		 * An array of ContentTO objects. If the parent item contains a group tag, then
		 * each content source within that group tag is added to this array. For items
		 * without a group tag, the array length will be 1 and it will a hold a single entry
		 * which is the content tag contained within that item. Use the utility function
		 * <code>getContentAt(index:uint)</code> to retrieve a specific ContentTO object with
		 * the correct type. 
		 * 
		 */
		public var contentArray:Array;
		public var copyright:String;
		public var title:String;
		public var description:String;
		public var keywords:String;
		/**
		 * The first item in the thumbnailArray. Provided for backwards compatibility.
		 * 
		 */
		public var thumbnail:ThumbnailTO;
		/**
		 * An array of ThumnbnailTO objects, since it is permissable for RSS feeds to reference 
		 * multiple thumbnails for each content item. 
		 * 
		 */
		public var thumbnailArray:Array;
		
		/**
		 * Constructor
		 * 
		 */
		public function Media():void {
			contentArray = new Array();
			thumbnailArray = new Array();
		}
		/**
		 * Returns the ContentTO object at the requested index.
		 * 
		 * @see com.akamai.rss.ContentTO
		 */
		public function getContentAt(index:uint):ContentTO {
			return ContentTO(contentArray[index]);
		}
	}
}