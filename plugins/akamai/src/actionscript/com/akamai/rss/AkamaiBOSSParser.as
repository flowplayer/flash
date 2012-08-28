package com.akamai.rss{

	import com.akamai.events.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error. The errors thrown by this class include:
	 * <table>
	 * <tr><th> Error Number</th><th>Description</th></tr>
	 * <tr><td>14</td><td>HTTP loading operation failed</td></tr>
	 * <tr><td>15</td><td>XML is not well formed</td></tr>
	 * <tr><td>17</td><td>Class is busy and cannot process your request</td></tr>
	 * <tr><td>18</td><td>XML does not conform to BOSS standard</td></tr>
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
	 * The AkamaiBOSSParser class loads and parses XML metafiles returned by the Akamai StreamOS BOSS service. There are three
	 * different types of metafiles that this parser recognizes:<p />
	 * Metafile version I
	 * <listing version="3.0">
	 *  &lt;FLVPlayerConfig&gt;
	 *      &lt;serverName&gt;cpxxxxx.edgefcs.net&lt;/serverName&gt;
	 *      &ltfallbackServerName>cpyyyyy.edgefcs.net</fallbackServerName&gt;
	 *      &lt;appName&gt;ondemand&lt;/appName&gt;
	 *      &lt;streamName&gt;&lt;![CDATA[xxxxx/6c/04/6c0442cadf77337d43a89fc56d2b28f9-461c1402]]/&gt;&lt;/streamName>
	 *      &lt;isLive&gt;false&lt;/isLive&gt;
	 *      &lt;bufferTime&gt;2&lt;/bufferTime&gt;
	 *  &lt;/FLVPlayerConfig&gt;
	 * </listing>
	 * <p/>
	 * Metafile version II
	 * <listing version="3.0">
	 *  &lt;FLVPlayerConfig&gt;
	 *   &lt;stream&gt;
	 *	  &lt;entry&gt;
	 *      &lt;serverName&gt;cpxxxxx.edgefcs.net&lt;/serverName&gt;
	 *      &lt;appName&gt;ondemand&lt;/appName&gt;
	 *      &lt;streamName&gt;&lt;![CDATA[xxxxx/6c/04/6c0442cadf77337d43a89fc56d2b28f9-461c1402]]/&gt;&lt;/streamName>
	 *      &lt;isLive&gt;false&lt;/isLive&gt;
	 *      &lt;bufferTime&gt;2&lt;/bufferTime&gt;
	 *    &lt;/entry&gt;
	 *  &lt;/stream&gt;
	 * &lt;/FLVPlayerConfig&gt;
	 * </listing>
	 * <p/>
	 * Metafile version III is deprecated.
	 * <p/>
	 * Metafile version IV <br/>
	 * On-demand sample:
	 * <listing version="3.0">
	 * 	 &lt;smil xmlns="http://www.w3.org/2005/SMIL21/Language" title="EdgeBOSS-SMIL:1.0"&gt;
  	 *      &lt;video src="rtmp://cpxxxxx.edgefcs.net/ondemand/flash/63/dc/63dcaade59637ee0193a5a2b95a40113-47d04e26" title="Superbowl 2008: Bud Light: Deli" copyright="2008. All Rights Reserved." author="Anheuser Busch" clipBegin="1s" clipEnd="30s" dur="60s"&gt;
     *         &lt;param name="connectAuthParams" value="auth=AUTH&aifp=AIFP" valuetype="data"/&gt;
     *         &lt;param name="keywords" value="football, beer, bud light, NFL" valuetype="data"/&gt;
     *         &lt;param name="isLive" value="0" valuetype="data"/&gt;
     *      &lt;/video&gt;
     *   &lt;/smil&gt;
	 * </listing>
	 * <p/>
	 * Live sample:
	 * <listing version="3.0">
	 * 	 &lt;smil xmlns="http://www.w3.org/2005/SMIL21/Language" title="EdgeBOSS-SMIL:1.0"&gt;
  	 *      &lt;video src="rtmp://cpxxxxx.live.edgefcs.net/live/smellhound&#64;1641" title="Stream OS Live Events Flash Format Test" copyright="2008. All Rights Reserved." author="Akamai Technologies, Inc."&gt;
     *         &lt;param name="playAuthParams" value="auth=AUTH&aifp=AIFP" valuetype="data"/&gt;
     *         &lt;param name="keywords" value="football, beer, bud light, NFL" valuetype="data"/&gt;
     *         &lt;param name="isLive" value="1" valuetype="data"/&gt;
     *      &lt;/video&gt;
     *   &lt;/smil&gt;
	 * </listing>
	 * <p/>
	 */
	public class AkamaiBOSSParser extends EventDispatcher {

		// Declare vars
		private var _xml:XML;
		private var _rawData:String;
		private var _serverName:String;
		private var _appName:String;
		private var _streamName:String;
		private var _protocol:String;
		private var _isLive:Boolean;
		private var _bufferTime:Number;
		private var _busy:Boolean;
		private var _timeoutTimer:Timer;
		private var _fallbackServerName:String;
		private var _connectAuthParams:String;
		private var _playAuthParams:String;
		private var _source:String;
		private var _title:String;
		private var _copyright:String;
		private var _author:String;
		private var _clipBegin:String;
		private var _clipEnd:String;
		private var _duration:String;
		private var _keywords:String;
		private var _secondaryEncoderSrc:String;
		private var _versionOfMetafile:String;
		private var _ns:Namespace;
		
		
		//Declare constants
		public const VERSION:String = "2.0";
		private const TIMEOUT_MILLISECONDS:uint= 15000;
		public const METAFILE_VERSION_I:String = "METAFILE_VERSION_I";
		public const METAFILE_VERSION_II:String = "METAFILE_VERSION_II";
		public const METAFILE_VERSION_IV:String = "METAFILE_VERSION_IV";

		/**
		 * Constructor
		 * @private
		 */
		public function AkamaiBOSSParser():void {
			_busy = false;
			_timeoutTimer = new Timer(TIMEOUT_MILLISECONDS,1);
			_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,doTimeOut);
		}
		/**
		 * Loads a BOSS metafile and initiates the parsing process.
		 * 
		 * @return true if the load is initiated otherwise false if the class is busy
		 * 
		 * @see isBusy
		 */
		public function load(src:String):Boolean {
			if (!_busy) {
				_busy = true;
				_timeoutTimer.reset();
				_timeoutTimer.start();
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener("complete",xmlLoaded);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR,catchIOError);
				xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, catchSecurityError);
				xmlLoader.load(new URLRequest(src));
				return true;
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,17,"Class is busy and cannot process your request"));
				return false;
			}
		}
		/**
		 * The raw data string returned by the BOSS service. This value will still
		 * be populated even if the data is not well-formed XML, to assist with debugging.
		 * 
		 */
		public function get rawData():String {
			return _rawData;
		}
		/**
		 * The BOSS metafile as an XML object. 
		 * 
		 */
		public function get xml():XML {
			return _xml;
		}
		/**
		 * The Akamai hostname, in the form cpxxxxx.edgefcs.net
		 * 
		 */
		public function get serverName():String{
			return _serverName;
		}
		/**
		 * The Akamai application name
		 * 
		 */
		public function get appName():String {
			return _appName;
		}
		/**
		 * The stream name
		 * 
		 */
		public function get streamName():String {
			return _streamName;
		}
		/**
		 * The Akamai Hostname, a concatenation of the server and application names
		 * 
		 */
		public function get hostName():String {
			return _serverName+"/"+_appName;
		}
		/**
		 * Boolean parameter indicating whether the stream is live or not
		 * 
		 */
		public function get isLive():Boolean {
			return _isLive;
		}
		/**
		 * The auth parameter string (auth=xxxx&aifp=yyyy&slist=zzzzz) to be used at connection time.
		 * Note that for Type I and Type II metafiles, the auth params are appended to the appName value.
		 * This class will strip them from the appName and expose them via the connectAuthParams property. This
		 * is a departure in behavior from Media Framework versions prior to 1.7, where auth params were left
		 * attached as part of the app name and were not exposed via the connectAuthParams property for
		 * Type I and II feeds. 
		 * 
		 */
		public function get connectAuthParams():String {
			return _connectAuthParams;
		}
		/**
		 * The auth parameter string(auth=xxxx&aifp=yyyy&slist=zzzzz) to be used at stream play time.
		 * Note that for Type I and Type II metafiles, the auth params are appended to the streamName value.
		 * This class will strip them from the streamName and expose them via the playAuthParams property. This
		 * is a departure in behavior from Media Framework versions prior to 1.7, where auth params were left
		 * attached as part of the stream name and were not exposed via the playAuthParams property for
		 * Type I and II feeds. 
		 * 
		 */
		public function get playAuthParams():String {
			return _playAuthParams;
		}
		/**
		 * The fallback server name. This property is only available with metafile type I.
		 * 
		 */
		public function get fallbackServerName():String {
			return _fallbackServerName;
		}
		/**
		 * The requested protocol attribute. This property is only available with metafile type IV.
		 * Note that a protocol of "rtmp" is the default and implies that port/protocol negotiation
		 * should be performed to select the optimum protocol. A protocol value of "rtmpe" implies that
		 * the account can only accept "rtmpe" or "rtmpte" connections and any subsequent connection attempts
		 * should be limited to just those two protocols. 
		 * 
		 */
		public function get protocol():String {
			return _protocol;
		}
		/**
		 * The video source attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get source():String {
			return _source;
		}
		/**
		 * The video title attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get title():String {
			return _title;
		}
		/**
		 * The video copyright attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get copyright():String {
			return _copyright;
		}
		/**
		 * The video author attribute. This property is only available with metafile type IV.
		 * 
		 */
		public function get author():String {
			return _author;
		}
		/**
		 * The designated clip start time. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get clipBegin():String {
			return _clipBegin;
		}
		/**
		 * The designated clip end time. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get clipEnd():String {
			return _clipEnd;
		}
		/**
		 * The stream duration. This property is only available with metafile type IV.
		 * Note that this value is a string, not a number and it may include the character "s" to indicate seconds e.g 30s.
		 * 
		 */
		public function get duration():String {
			return _duration;
		}
		/**
		 * A list of comma separated keywords to be associated with the video. This property is only available with metafile type IV.
		 * 
		 */
		public function get keywords():String {
			return _keywords;
		}
		/**
		 * A backup or secondary encoder source. This property is only available with metafile type IV when isLive is "1" and even then
		 * is not required to be present.
		 * 
		 */
		public function get secondaryEncoderSrc():String {
			return _secondaryEncoderSrc;
		}
		/**
		 * The classification of the metafile type, assuming it has been recognized by the class. Possible
		 * values are the constants:
		 * <ul>
		 * <li>METAFILE_VERSION_I</li>
		 * <li>METAFILE_VERSION_II</li>
		 * <li>METAFILE_VERSION_IV</li>
		 * </ul>
		 * 
		 */
		public function get versionOfMetafile():String {
			return _versionOfMetafile;
		}
		/**
		 * Boolean parameter indicating whether the class is already busy loading a metafile. Since the 
		 * load is asynchronous, the class will not allow a new <code>load()</code> request until
		 * the prior request has ended.
		 * 
		 */
		public function get isBusy():Boolean {
			return _busy;
		}
		/**
		 * The buffer time designated for this stream
		 * 
		 */
		public function get bufferTime():Number {
			return _bufferTime;
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
				_xml=XML(_rawData);
				dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.LOADED));
				parseXML();
			} catch (err:Error) {
				_busy = false;
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,15,"XML is not well formed"));
			}
		}
		/** Parses the RSS xml metafile into useful properties
		 * @private
		 */
		private function parseXML():void {
			if (!verifyRSS(_xml)) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,18,"XML does not conform to BOSS standard"));
			} else {
				switch (_versionOfMetafile) {
					case METAFILE_VERSION_I:
						_serverName = _xml.serverName;
						_fallbackServerName = _xml.fallbackServerName;
						_appName = _xml.appName.split("?")[0];
						_streamName = _xml.streamName.split("?")[0];
						_isLive = _xml.isLive.toString().toUpperCase() == "TRUE";
						_bufferTime = Number(xml.bufferTime);
						_connectAuthParams = _xml.appName.split("?")[1];
						_playAuthParams = _xml.streamName.split("?")[1];
						dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.PARSED));
					break;
					case METAFILE_VERSION_II:
						_serverName = _xml.stream.entry.serverName;
						_appName = _xml.stream.entry.appName.split("?")[0];
						_streamName = _xml.stream.entry.streamName.split("?")[0];
						_isLive = _xml.stream.entry.isLive.toString().toUpperCase() == "TRUE";
						_bufferTime = Number(xml.stream.entry.bufferTime);
						_connectAuthParams = _xml.stream.entry.appName.split("?")[1];
						_playAuthParams = _xml.stream.entry.streamName.split("?")[1];
						dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.PARSED));
					break;
					case METAFILE_VERSION_IV:
						_source = _xml._ns::video.@src;
						_title= _xml._ns::video.@title;
						_author= _xml._ns::video.@author;
						_clipBegin= _xml._ns::video.@clipBegin;
						_clipEnd= _xml._ns::video.@clipEnd;
						_duration= _xml._ns::video.@dur;
						_connectAuthParams = _xml._ns::video._ns::param.(@name=="connectAuthParams").@value;
						_playAuthParams = _xml._ns::video._ns::param.(@name=="playAuthParams").@value;
						_keywords = _xml._ns::video._ns::param.(@name=="keywords").@value;
						_secondaryEncoderSrc = _xml._ns::video._ns::param.(@name=="secondaryEncoderSrc").@value;
						_serverName = parseServerName(_source);
						_appName = parseAppName(_source);
						_streamName = parseStreamName(_source);
						_protocol = parseProtocol(_source);
						_isLive = _xml._ns::video._ns::param.(@name=="isLive").@value == "1";
						dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.PARSED));
					break;
				}
			}
			_busy = false;
		}
		/** Parses the server name from the source
		 * @private
		 */
		private function parseServerName(s:String):String {
			return s.split("/")[2];
		}
		/** Parses the application name from the source
		 * @private
		 */
		private function parseAppName(s:String):String {
			return s.split("/")[3];
		}
		/** Parses the stream name from the source
		 * @private
		 */
		private function parseStreamName(s:String):String {
			return s.slice(s.indexOf(this.hostName)+this.hostName.length+1);
		}
		/** Parses the protocol from the source
		 * @private
		 */
		private function parseProtocol(s:String):String {
			return s.slice(0,s.indexOf(":")).toLowerCase();
		}
		/** A simple verification routine to check if the XML received conforms
		 * to some basic BOSS requirements. This routine does not validate against
		 * any DTD.
		 * @private
		 */
		private function verifyRSS(src:XML):Boolean {
			// First, let's identify the type of BOSS metafile we are dealing with
			// by examining the first node
			var isVerified:Boolean;
			switch (src.localName()) {
				case "FLVPlayerConfig":
					if (src.stream == undefined && src.stream.entry == undefined) {
						_versionOfMetafile = METAFILE_VERSION_I;
						isVerified = !(src.serverName == undefined || src.appName == undefined || src.streamName == undefined || src.isLive == undefined  || src.bufferTime == undefined);
					} else {
						_versionOfMetafile = METAFILE_VERSION_II;
						isVerified = !(src.stream.entry.serverName == undefined || src.stream.entry.appName == undefined || src.stream.entry.streamName == undefined || src.stream.entry.isLive == undefined  || src.stream.entry.bufferTime == undefined);
					}
				break;
				case "smil":
					_ns = new Namespace("http://www.w3.org/2005/SMIL21/Language");
					if (src.attribute("title").toString() == "EdgeBOSS-SMIL:1.0"){
						_versionOfMetafile = METAFILE_VERSION_IV;
						isVerified = !(src._ns::video.@src == undefined);
					} else {
						isVerified = false;
					}
				break;
				default:
				 	isVerified = false;
				 break;
			}
			return isVerified;
		}

		/** Catches IO errors when requesting the xml 
		 * @private
		 */
		private function catchIOError(e:IOErrorEvent):void {
			_busy = false;
			_timeoutTimer.stop();
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,14,"HTTP loading operation failed"));
		}
		/** Catches Security errors when requesting the xml 
		 * @private
		 */
		private function catchSecurityError(e:SecurityErrorEvent):void {
			catchIOError(null);
		}
		
	}
}