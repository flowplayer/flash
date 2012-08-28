package com.akamai.rss{

	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.akamai.rss.*;
	import com.akamai.events.*;
	import flash.xml.XMLNode;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. The errors thrown by this class include:
	 * <table>
	 * <tr><th> Error Number</th><th>Description</th></tr>
	 * <tr><td>14</td><td>HTTP loading operation failed</td></tr>
	 * <tr><td>15</td><td>XML is not well formed</td></tr>
	 * <tr><td>16</td><td>XML does not conform to Media RSS standard</td></tr>
	 * <tr><td>17</td><td>Class is busy and cannot process your request</td></tr>
	 * <tr><td>20</td><td>Timed out trying to load the XML file</td></tr>
	 * </table>
	 * 
	 * @eventType com.akamai.events.AkamaiErrorEvent.ERROR
	 */
 	[Event (name="error", type="com.akamai.events.AkamaiErrorEvent")]
	/**
	 * Dispatched when the BOSS xml response has been successfully loaded. 
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.LOADED
	 */
 	[Event (name="loaded", type="com.akamai.events.AkamaiNotificationEvent")]
	/**
	 * Dispatched when the BOSS xml response has been successfully parsed. 
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.PARSED
	 */
 	[Event (name="parsed", type="com.akamai.events.AkamaiNotificationEvent")]
	/**
	 * The AkamaiMediaRSS class loads a Media RSS playlist, parses it and makes utility
	 * properties and methods available which expose the contents of that feed.
	 *  
	 */
	public class AkamaiMediaRSS extends EventDispatcher {

		// Declare vars
		private var _rss:XML;
		private var _rawData:String;
		private var _title:String;
		private var _description:String;
		private var _imageUrl:String;
		private var _itemCount:Number;
		private var _itemArray:Array;
		private var _busy:Boolean;
		private var _timeoutTimer:Timer;
		
		//Declare constants
		public const VERSION:String = "1.0";
		private const TIMEOUT_MILLISECONDS:uint= 15000;
		
		// Declare namespaces
		private var mediaNs:Namespace;
		
		/**
		 * Constructor
		 * @private
		 */
		public function AkamaiMediaRSS():void {
			_busy = false;
			_timeoutTimer = new Timer(TIMEOUT_MILLISECONDS,1);
			_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,doTimeOut);
		}
		/**
		 * Loads a Media RSS feed and initiates the parsing process.
		 * 
		 * @return true if the load is initiated otherwise false if the class is busy
		 * 
		 * @see isBusy
		 */
		public function load(src:String):Boolean{
			if (!_busy) {
				_busy = true;
				_timeoutTimer.reset();
				_timeoutTimer.start();
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener("complete",xmlLoaded);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR,catchIOError);
				xmlLoader.load(new URLRequest(src));
				return true;
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,17,"Class is busy and cannot process your request"));
				return false;
			}
		}
		/**
		 * The raw data string returned by the RSS service. This value will still
		 * be populated even if the data is not well-formed XML, to assist with debugging.
		 * 
		 * @return string representing the text returned by the RSS service.
		 * 
		 */
		public function get rawData():String {
			return _rawData;
		}
		/**
		 * The RSS feed as an XML object. 
		 * 
		 */
		public function get rssAsXml():XML {
			return _rss;
		}
		/**
		 * The RSS item at the given index. 
		 * 
		 */
		public function getItemAt(i:uint):ItemTO {
			return _itemArray[i];
		}
		/**
		 * The title of the RSS feed 
		 * 
		 */
		public function get title():String {
			return _title;
		}
		/**
		 * The description of the RSS feed 
		 * 
		 */
		public function get description():String {
			return _description;
		}
		/**
		 * The image URL of the feed
		 * 
		 */
		public function get imageUrl():String {
			return _imageUrl;
		}
		/**
		 * The number of items in the feed 
		 * 
		 */
		public function get itemCount():Number {
			return _itemCount;
		}
		/**
		 * The items as an array of ItemTO objects 
		 * 
		 */
		public function get itemArray():Array {
			return _itemArray;
		}
		/**
		 * The items as an XMLList
		 * 
		 */
		public function get itemXmlList():XMLList{
			return XMLList(_rss.channel.item);
		}
		/** Catches the time out of the initial load request.
		  * @private
		  */
		private function doTimeOut(e:TimerEvent):void {
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,20,"Timed out trying to load the XML file"));
		}
		/** Handles the XML request response
		    * @private
		    */
		private function xmlLoaded(e:Event):void {
			_timeoutTimer.stop();
			_rawData=e.currentTarget.data.toString();
			try {
				_rss=XML(_rawData);
				dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.LOADED));
				parseXML();
			} catch (err:Error) {
				trace(err.message);
				_busy = false;
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,15,"XML is not well formed"));
			}
		}
		/** Parses the RSS xml feed into useful properties
		 * @private
		 */
		private function parseXML():void {
			_busy = false;
			if (!verifyRSS(_rss)) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,16,"XML does not conform to Media RSS standard"));
			} else {
				mediaNs = new Namespace("http://search.yahoo.com/mrss");
				_title=_rss.channel.title;
				_description=_rss.channel.description;
				_imageUrl=_rss.channel.image.url;
				_itemCount=_rss.channel.item.length();
				_itemArray=new Array  ;
				for (var i:uint=0; i < _itemCount; i++) {
					var item:ItemTO=new ItemTO();
					item.title=_rss.channel.item[i].title;
					item.author=_rss.channel.item[i].author;
					item.description=_rss.channel.item[i].description;
					item.pubDate=_rss.channel.item[i].pubDate;
					var enclosure:EnclosureTO = new EnclosureTO();
					enclosure.url =_rss.channel.item[i].enclosure.@url;
					enclosure.length=Number(_rss.channel.item[i].enclosure.@length.toString());
					enclosure.type=_rss.channel.item[i].enclosure.@type;
					item.enclosure = enclosure;
					if (_rss.channel.item[i].mediaNs::group == undefined) {
						item.media = buildMediaObject(_rss.channel.item[i]);
					
					} else {
						item.media = buildMediaObject(XML(_rss.channel.item[i].mediaNs::group));
						
					}
					_itemArray.push(item);
					
				}
				dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.PARSED));
			}
			
		}
		private function buildMediaObject(node:XML):Media {
				var media:Media = new Media();
				for (var k:uint=0;k<node.mediaNs::thumbnail.length();k++) {
					// It is possible for media items to contain mutiple thumbnail definitions.
					// Here we opt to take the first item found.
					var thumbnail:ThumbnailTO = new ThumbnailTO();
					thumbnail.url = node.mediaNs::thumbnail[k].@url;
					thumbnail.height = Number(node.mediaNs::thumbnail[k].@height);
					thumbnail.width = Number(node.mediaNs::thumbnail[k].@width);
					thumbnail.time = node.mediaNs::thumbnail[k].@width;
					media.thumbnailArray.push(thumbnail);
				}
				for (var i:uint=0;i<node.mediaNs::content.length();i++) {
					var content:ContentTO = new ContentTO();
					content.fileSize=Number(node.mediaNs::content[i].@fileSize);
					content.type=node.mediaNs::content[i].@type;
					content.medium=node.mediaNs::content[i].@medium;
					content.isDefault=node.mediaNs::content[i].@isDefault;
					content.expression=node.mediaNs::content[i].@expression;
					content.bitrate=Number(node.mediaNs::content[i].@bitrate);
					content.framerate=Number(node.mediaNs::content[i].@framerate);
					content.samplingrate=Number(node.mediaNs::content[i].@samplingrate);
					content.channels=node.mediaNs::content[i].@channels;
					content.duration=node.mediaNs::content[i].@duration;
					content.height=Number(node.mediaNs::content[i].@height);
					content.width=Number(node.mediaNs::content[i].@width);
					content.lang = node.mediaNs::content[i].@lang;
					content.url =node.mediaNs::content[i].@url;
					media.contentArray.push(content);
				}
				media.title = node.mediaNs::title;
				media.description = node.mediaNs::description;
				media.copyright = node.mediaNs::copyright;
				media.keywords = node.mediaNs::keywords;
				media.thumbnail = media.thumbnailArray[0];
				//
				return media;
			
		}
		/** A simple verification routine to check if the XML received conforms
		 * to some basic RSS requirements. This routine does not validate against
		 * the DTD.
		 * @private
		 */
		private function verifyRSS(src:XML):Boolean {
			var verified:Boolean = true;
			if (src.@version == undefined) {
				verified = false;
			}
			if (src.channel.title == undefined || src.channel.link == undefined || src.channel.description == undefined) {
				verified = false;
			}
			if (src.channel.item is XMLList) {
				for each (var item:XML in _rss.channel.item) {
					if (item.title == undefined && item.description == undefined) {
						verified = false;
					}
				}

			} else {
				if (src.channel.item != undefined && src.channel.item.title == undefined && src.channel.item.description == undefined) {
					verified = false;
				}
			}
			return verified;
		}

		/** Catches IO errors when requesting the xml 
		 * @private
		 */
		private function catchIOError(e:IOErrorEvent):void {
			_timeoutTimer.stop();
			_busy = false;
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,14,"HTTP loading operation failed"));
		}
	}
}