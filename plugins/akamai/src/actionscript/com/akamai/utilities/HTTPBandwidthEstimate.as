package com.akamai.utilities{

	// AS3 generic imports
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * Dispatched when the class has completed the bandwidth estimate. The value of the
	 * estimate can be retrieved by querying the <code> bandwidth</code> property of the class.
	 * @see #bandwidth
	 */
 	[Event (name="complete", type="flash.events.Event")]
	
	/**
	 * Dispatched when an error condition has occurred. The <code>text</code> attribute
	 * of the event will describe why the error has occured. The possible errors thrown by this class include:
	 * <ol>
	 * 	<li>"You must specify a target file to use for the test as an argument of the start() call" - thrown when no load
	 * target is specified in the <code>start</code> request.</li>
	 * <li> "This class instance is busy making a bandwidth estimate" - occurs when the start() is called and the class instance
	 * is already in the midst of making a bandwidth estimate. </li>
	 * <li>"Timed out trying to measure the bandwidth" - it took longer than the default timeout interval 
	 * to complete the bandwidth estimate. The default timeout interval is 15 seconds. </li>
	 * <li>IO Error - text may vary - the class is unable to load the target specified in the <code>start</code> request.</li>
	 * </ol>
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
 	[Event (name="error", type="flash.events.ErrorEvent")]
	
	/**
	 *  The HTTPBandwidthEstimate class estimates the bandwidth of a client's internet
	 * connection by timing how fast it can download a target object via HTTP request. This target is specified
	 * by the client as an argument of the <code>start</code> method. A <code>complete</code>
	 * event signals the successful estimation. Error events are thrown if the class is unable
	 * to access the payload via HTTP, if no payload is specified, if it is busy, or if it times-out
	 * while making the estimate.<p />
	 * The default time taken by the class to make the estimate is 3,000 milliseconds. This can be modified
	 * by the user by specifying the optional second attribute of the <code>start</code> method, which 
	 * specifies the time in millseconds that the class should use to make the estimate. The longer the time,
	 * the more accurate the result. 
	 *
	 */
	
	public class HTTPBandwidthEstimate extends EventDispatcher {
		
		//Declare vars
		private var _source:String;
		private var _timeoutTimer:Timer;
		private var _busy:Boolean;
		private var _startTime:uint;
		private var _kbps:uint;
		private var _loader:URLLoader 
		private var _delay:Number;
	
		// Declare constants
		private const TIMEOUT_MILLISECONDS:uint= 15000;

		/**
		 * Constructor
		 * @private
		 */
		public function HTTPBandwidthEstimate():void {
			_busy = false;
			_timeoutTimer = new Timer(TIMEOUT_MILLISECONDS,1);
			_timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,doTimeOut);
		}
		/**
		 * Initiates the bandwidth estimate. The <code>src</code> argument is required and cannot be empty.
		 * The bandwidth result is retrieved by waiting for the <code> complete </code> event to fire
		 * and then  querying the <code> bandwidth </code> property. 
		 * <p/>
		 * @param the HTTP path to the download target (required.) This load target should have the following attributes:
		 * <ul>
		 * <li> It should reference a highly compressed binary object, such as a .flv, .zip, or .jpg object. </li>
		 * <li> It should be at least 20MB in size, or at least large enough that the entire file will NOT be downloaded
		 * within the estimation period, which has a default of 3000 milliseconds. 
		 * <li> Optimally, it should be mounted on the same server that will deliver the media files for which this
		 * bandwidth estimate is required, so that it is actually measuring the effective bandwidth between the client
		 * and those media servers. Using one of the actual media files as a load target is therefore a good idea.</li>
		 * <li> To avoid false results due to browser caching of the load target, a random string will be added by the class
		 * to each request to this target. For example, a target of "http://myserver.com/mybigfile.flv" will actually be requested
		 * as "http://myserver.com/mybigfile.flv?cachebust=0.9707476454786956".</li>
		 * </ul>
		 * @param the max time in milliseconds to spend on the estimate (optional). The default value is 3000. Ensure that this value
		 * does not exceed the default timeout interval of 15,000 millseconds, or else the class will time-out before it completes its test.
		 * @see #bandwidth
		 */
		public function start(src:String = "",delay:Number=3000):void {
			if (src == "") {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"You must specify a target file to use for the test as an argument of the start() call"));
			} else if (_busy) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"This class instance is busy making a bandwidth estimate"));
			} else {
			_source = src;
			_delay = delay;
			_source = _source + (_source.indexOf("?") != -1 ? "&":"?") + "cachebust=" + Math.random();
			_loader = new URLLoader();
			_loader.addEventListener("complete",loadedHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR,IOErrorHandler);
			_loader.addEventListener(ProgressEvent.PROGRESS ,progressHandler);
			_busy = true;
			_timeoutTimer.reset();
			_timeoutTimer.start();
			_startTime = getTimer();
			_loader.load(new URLRequest(_source));
			}

		}
		/** Returns the last estimated bandwidth value, in kilobits per second, or undefined if no
		* value has been measured. Wait for the <code>complete</code> event to be dispatched
		* before querying this property. 
		* @returns the bandwidth estimate in kilobits per second.
		*/

		public function get bandwidth():Number{
			return _kbps;
		}
		/** Handles the complete loading of the target
		 * @private
		 */
		private function loadedHandler(e:Event):void {
			trace("fuly loaded");
			_timeoutTimer.stop();
			if (_busy) {
				handleEnd(_loader.bytesLoaded);
			}
		}
		/** Handles the download progress 
		 * @private
		 */
		private function progressHandler(e:ProgressEvent):void {
			if ((getTimer() - _startTime) > _delay) {
				handleEnd(e.bytesLoaded);
			}
		}
		/** Handles the end of the measurement period
		 * @private
		 */
		 private function handleEnd(bytes:uint):void {
			 _loader.close();
			 _timeoutTimer.stop();
			 var deltaSeconds:Number = (getTimer() - _startTime)/1000;
			 _kbps = Math.round((bytes*8/1000)/deltaSeconds);
			 _busy = false;
			 dispatchEvent (new Event("complete"));
		 }
		/** Catches IO errors when requesting the target
		 * @private
		 */
		private function IOErrorHandler(e:IOErrorEvent):void {
			_busy = false;
			_timeoutTimer.stop();
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,e.text));
		}
		/** Catches the time out of the initial load request.
		  * @private
		  */
		private function doTimeOut(e:TimerEvent):void {
			_busy = false;
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Timed out trying to measure the bandwidth"));
		}
	}
}