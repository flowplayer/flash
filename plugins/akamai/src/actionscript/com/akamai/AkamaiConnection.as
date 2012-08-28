
package com.akamai
{
	
	import com.akamai.events.*;
	
	import flash.events.*;
	import flash.media.SoundTransform;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.utils.*;

	/**
	 * Dispatched when an error condition has occurred. The event provides an error number and a verbose description
	 * of each error:
	 * <table>
	 * <tr><th> Error Number</th><th>Description</th></tr>
	 * <tr><td>1</td><td>Hostname cannot be empty</td></tr>
	 * <tr><td>2</td><td>Buffer length must be &gt; 0.1</td></tr>
	 * <tr><td>3</td><td>Warning - this protocol is not supported on the Akamai network</td></tr>
	 * <tr><td>4</td><td>Warning - this port is not supported on the Akamai network</td></tr>
	 * <tr><td>5</td><td>Warning - unable to load XML data from ident request, will use domain name to connect</td></tr>
	 * <tr><td>6</td><td>Timed out while trying to connect</td></tr>
	 * <tr><td>7</td><td>Stream not found</td></tr>
	 * <tr><td>8</td><td>Cannot play, pause, seek, or resume since the stream is not defined</td></tr>
	 * <tr><td>9</td><td>Timed out trying to find the live stream</td></tr>
	 * <tr><td>10</td><td>Error requesting stream length</td></tr>
	 * <tr><td>11</td><td>Volume value out of range</td></tr>
	 * <tr><td>12</td><td>Network failure - unable to play the live stream</td></tr>
	 * <tr><td>13</td><td>Connection attempt rejected by server</td></tr>
	 * <tr><td>19</td><td>The Fast Start feature cannot be used with live streams</td></tr>
	 * <tr><td>21</td><td>NetStream IO Error event</td></tr>
	 * <tr><td>22</td><td>NetStream Failed - check your live stream auth params</td></tr>
	 * <tr><td>23</td><td>NetConnection connection attempt failed</td></tr>
	 * <tr><td>24</td><td>NetStream buffer has remained empty past timeout threshold</td></tr> 
	 * </table>
	 * 
	 * @eventType com.akamai.events.AkamaiErrorEvent.ERROR
	 */
 	[Event (name="error", type="com.akamai.events.AkamaiErrorEvent")]
 	/**
	 * Dispatched when a bandwidth estimate is complete. 
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.BANDWIDTH
	 */
 	[Event (name="bandwidth", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the class has successfully connected to the Akamai Streaming service.
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.CONNECTED
	 */
 	[Event (name="connected", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the class has detected, by analyzing the
	 * NetStream.netStatus events, the end of the stream. <p>
	 * Deprecated in favor of <code>om.akamai.events.AkamaiNotificationEvent.COMPLETE</code>
	 * when communicating with a FMS server. For progressive delivery
	 * of streams however, this event is the only reliable indication provided that the stream
	 * has ended. 
	 * 
	 * @see com.akamai.events.AkamaiNotificationEvent.COMPLETE
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.END_OF_STREAM
	 */
 	[Event (name="end", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the class has completed a stream length request and also if metadata matching the name "duration" is received
	 * while playing a progressive stream.
	 * 
	 * @see #getStreamLength
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.STREAM_LENGTH
	 */
 	[Event (name="streamlength", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the the class has successfully subscribed to a live stream.
	 * 
	 * @see #isLive
	 * @see #play
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.SUBSCRIBED
	 */
 	[Event (name="subscribed", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the class has unsubscribed from a live stream, or when the live stream it was previously subscribed
	 * to has ceased publication.
	 * 
	 * @see #isLive
	 * @see #play
	 * @see #unsubscribe
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.UNSUBSCRIBED
	 */
 	[Event (name="unsubscribed", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the class is making a new attempt to subscribe to a live stream
	 * 
	 * @see #isLive
	 * @see #play
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.SUBSCRIBE_ATTEMPT
	 */
 	[Event (name="subscribeattempt", type="com.akamai.events.AkamaiNotificationEvent")]
 	/**
	 * Dispatched when the NetStream object has changed status.
	 * 
	 * @see #createStream
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM
	 */
 	[Event (name="netstream", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the NetConnection object has changed status.
	 * This event is only dispatched for connections which have successfully connected, with a single exception,
	 * that being the case of a server rejection. In order for the server to communciate some reason for
	 * the rejection, the <code>info</code> parameter sent by the AkamaiStatusEvent will carry a <code>description</code>
	 * property, which is a text string indicating the type of rejection. This description can be extracted using the following code:
	 * <p/>
	 * <listing version="3.0">
	 * 		private function netStatusHandler(e:AkamaiStatusEvent):void {
	 *          if (e.info.code == "NetConnection.Connect.Rejected") {
	 *             trace("Rejected by server. Reason is "+e.info.description);
	 *          }
	 *      }</listing>
	 * 
	 * <p/>
	 * To support backward compatibility, the rules for what is returned by this description field are the following:<br />
	 * <ol>
	 * <li> If no custom header is configured in ghost metadata, FMServer will send
	 * "Access denied!" for both auth and allowance check failure to the end user.</li>
	 * <li> If a customer wants to distinguish the stream auth error from an allowance
	 * check error, then they need to update the Akamai Ghost MetaData with their own custom error
	 * message. Once their custom error message tag is set, then FMS will respond
	 * with "Access denied!" for all auth based errors and will respond with custom error
	 * from the ghost metadata for allowance check errors (Velvet Rope, Geo targeting etc).</li>
	 * </ol>
	 * <p/>
	 * An example of a standard rejection would be<p/>
	 * <code>
	 * Rejected by server. Reason is [ AccessManager.Reject ] : Access denied!
	 * </code>
	 * <p/>
	 * An example of a custom rejection would be<p/>
	 * <code>
	 * Rejected by server. Reason is [ AccessManager.Reject ] : Maximum bandwidth exceeded: custom error
	 * </code>
	 * <p/>
	 * Note the Error event #13 "Connection attempt rejected by server" will also fire every time a netconnection event 
	 * is dispatched with a info.code value of "NetConnection.Connect.Rejected".
	 * 
	 * @see #connect
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETCONNECTION
	 */
 	[Event (name="netconnection", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the class has completely played a stream or switches to a different stream in a server-side playlist.
	 * 
	 * @see #createStream
	 * @see #play
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM_PLAYSTATUS
	 */
 	[Event (name="playstatus", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the class receives descriptive information embedded in the
	 * video file being played.
	 * 
	 * @see #createStream
	 * @see #play
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM_METADATA
	 */
 	[Event (name="metadata", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the class receives an image embedded in a H.264 file.
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM_IMAGEDATA
	 */
 	[Event (name="imagedata", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the class receives text data embedded in a H.264 file.
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM_TEXTDATA
	 */
 	[Event (name="textdata", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when an embedded cue point is reached while playing an video file.
	 * 
	 * @see #createStream
	 * @see #play
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.NETSTREAM_CUEPOINT
	 */
 	[Event (name="cuepoint", type="com.akamai.events.AkamaiStatusEvent")]
 	/**
	 * Dispatched when the class receives information about ID3 data embedded in an MP3 file.
	 * 
	 * @see #getMp3Id3Info
	 * 
	 * @eventType com.akamai.events.AkamaiStatusEvent.MP3_ID3
	 */
 	[Event (name="id3", type="com.akamai.events.AkamaiStatusEvent")]
 	
 	 	
 	/**
	 * Dispatched repeatedly at the  <code>progressInterval</code> once class begins playing a stream. 
	 * Event is halted after <code>close</code> or <code>closeNetStream</code> is called. 
	 * 
	 * @see #progressInterval
	 * @see #close
	 * @see #closeNetStream
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.PROGRESS
	 */
	 [Event (name="progress", type="com.akamai.events.AkamaiNotificationEvent")]
	 
	/**
	 * Dispatched when a stream from a server is complete. Note that when connecting to progressive
	 * content this event will not be dispatched. The com.akamai.events.AkamaiNotificationEvent.END_OF_STREAM
	 * should be used instead, in order to detect when the stream has finished playing. 
	 * 
	 * @eventType com.akamai.events.AkamaiNotificationEvent.COMPLETE
	 * 
	 * @see com.akamai.events.AkamaiNotificationEvent.END_OF_STREAM
	 */
	 [Event (name="complete", type="com.akamai.events.AkamaiNotificationEvent")]
 	
 	
 	
	/**
	 *  The AkamaiConnection class manages the complexity of establishing a robust NetConnection
	 *  with the Akamai Streaming service.
	 *  It optionally creates a NetStream over that NetConnection and exposes an API to control the
	 *  playback of content over that NetStream. The AkamaiConnection class works with on-demand FLV and H.264 MP4 (both
	 *  streaming and progressive) and MP3 playback (streaming only), as well as live FLV streams. 
	 *
	 */
	public class AkamaiConnection extends EventDispatcher
	{

    	// Declare private vars
    	private var _hostName:String;
    	private var _appName:String;
		private var _isLive:Boolean;
		private var _port:String;
		private var _protocol:String;
		private var _createStream:Boolean;
		private var _maxBufferLength:uint;
		private var _useFastStartBuffer:Boolean;
		private var _akLoader:URLLoader;
		private var _ip:String;
		private var _isPaused:Boolean;
		private var _streamLength:uint;
		private var _nc:AkamaiNetConnection;
		private var _ns:NetStream;
		private var _nsId3:NetStream;
		private var _aConnections:Array;
		private var _connectionTimer:Timer;
		private var _timeOutTimer:Timer;
		private var _liveStreamTimer:Timer;
		private var _liveStreamRetryTimer:Timer;
		private var _liveFCSubscribeTimer:Timer;
		private var _progressTimer:Timer;
		private var _bufferFailureTimer:Timer;
		private var _liveStreamMasterTimeout:uint;
		private var _connectionAttempt:uint;
		private var _aNC:Array;
		private var _aboutToStop:uint;
		private var _volume:Number;
		private var _panning:Number;
		private var _fpadZone:Number;
		private var _connectionEstablished:Boolean;
		private var _streamEstablished:Boolean;
		private var _pendingLiveStreamName:String;
		private var _playingLiveStream:Boolean;
		private var _successfullySubscribed:Boolean;
		private var _authParams:String;
		private var _liveStreamAuthParams:String;
		private var _isProgressive:Boolean;
		private var _isBuffering:Boolean;
		private var _watchForBufferFailure:Boolean;
		
		// Declare private constants
		private const TIMEOUT:uint = 15000;
		private const LIVE_RETRY_INTERVAL:Number = 30000;
		private const LIVE_ONFCSUBSCRIBE_TIMEOUT:Number = 60000;
		private const DEFAULT_PROGRESS_INTERVAL:Number = 100;
		private const BUFFER_FAILURE_INTERVAL:Number = 20000;
		private const VERSION:String = "1.7";
		
		private var _onConnectionCreated:Function;
		/**
		 *  Constructor. 
		 */
		public function AkamaiConnection(onConnectionCreated:Function):void {
			_onConnectionCreated = onConnectionCreated;
			NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
			initVars();
			initializeTimers();
			
		}
		/**
		 * The connect method initiates a connection to either the Akamai Streaming service or a progressive
		 * link to a HTTP server. It accepts a single hostName parameter, which describes the host account with which 
		 * to connect. This parameter can optionally include the application name, separated by a "/". A progressive
		 * connection is requsted by passing the <code>null</code> object, or the string "null". All other strings
		 * are treated as requests for a streaming connection. Valid usage examples include:<ul>
		 * 			<li>instance_name.connect("cpxxxxx.edgefcs.net");</li>
		 * 			<li>instance_name.connect("cpxxxxx.edgefcs.net/ondemand");</li>
		 * 			<li>instance_name.connect("cpxxxxx.edgefcs.net/aliased_ondemand_app_name");</li>
		 *  		<li>instance_name.connect("aliased.domain.name/aliased_ondemand_app_name");</li>
		 * 			<li>instance_name.connect("cpxxxxx.live.edgefcs.net/live");</li>
		 * 		    <li>instance_name.connect(null);</li>
		 *  		<li>instance_name.connect("null");</li></ul>
		 *  If the application name is not specifed, then the class will use <em>ondemand</em>
		 *  if <code>isLive</code> is false and <em>live</em> if <code>isLive</code> is true.
		 *  To connect to a cp code requiring connection authorization, first set the <code>authParams</code>
		 *  property before calling this <code>connect</code> method. 
		 * <p/>
		 * If a connection attempt is rejected due to SWF auth being enabled for that CP code and the SWf being invalid,
		 * then either one of the following behaviors can occur:
		 * <ul><li> The connection will initially be accepted by the server and then closed a short moment after.
		 * This pattern can be detected by listening for the <code>connected</code> notification event followed by a <code>
		 * netconnection</code> status event with a info.code value of "NetConnection.Connect.Closed".<li>
		 * <li> Or the connection will never actually be accepted by the server and the connection attempt will fail.
		 * This pattern can be detected by listening for error event #23 "NetConnection connection attempt failed".
		 * </li></ul><p />
		 * 
		 * @param The Akamai hostname to which to connect. The application name may optionally be
		 * included in this string, separated from the hostname by a "/". For a progressive connection,
		 * pass <code>null</code>, either as a null object or as a string.
		 * 
		 * @see #isLive
		 * @see #authParams
		 */
		public function connect(hostName:String):void {
			if (hostName == null || hostName == "null") {
				setUpProgressiveConnection();
			} else {
				if (hostName == "" ) { 
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,1,"Hostname cannot be empty")); 
				} else {
					_isProgressive = false;
					_hostName = hostName.indexOf("/") != -1 ? hostName.slice(0,hostName.indexOf("/")):hostName;
					_appName = hostName.indexOf("/") != -1 && hostName.indexOf("/") != hostName.length-1 ? hostName.slice(hostName.indexOf("/")+1):isLive ? "live":"ondemand";
					_connectionEstablished = false;
					_streamEstablished = false;
					// request IP address of optimum server
					_akLoader= new URLLoader();	
					_akLoader.addEventListener("complete", akamaiXMLLoaded);
					_akLoader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError);
					_akLoader.load(new URLRequest("http://" + _hostName + "/fcs/ident"));
				}
			}

		}
		/**
		 * The last measured bandwidth value in kilobits/second. Requires that a NetConnection has been
		 * established and that <code>detectBandwidth()</code> has previously been called. Since bandwidth
		 * detection between the client and the server is an asynchronous operation,
		 * to request the bandwidth, you must first make a call to the <code>detectBandwidth()</code> method
		 * and then wait for notifcation from the AkamaiNotificationEvent.BANDWIDTH event before requesting
		 * this property value.
		 * <p />
		 * This property is not available with progressive playback. 
		 * 
		 * @return bandwidth estimate in kiloBits/sec, or -1 if the NetConnection has not yet been established.
		 * 
		 * @see #detectBandwidth
		 */
		// 
		public function get bandwidth():Number {
			return _connectionEstablished ? _nc.bandwidth : -1;
		};
		/**
		 * The last measured latency value, in milliseconds. The latency is an estimate of the time it
		 * takes a packet to travel from the client to the server.
		 * Requires that a NetConnection has been established and that <code>detectBandwidth()</code> method has previously been 
		 * called. Since bandwidth/latency detection between the client and the server is an asynchronous operation,
		 * to request the latency, you must first make a call to the <code>detectBandwidth()</code> method and then
		 * wait for notifcation from the AkamaiNotificationEvent.BANDWIDTH event before requesting this property value.
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return latency estimate in milliseconds, or -1 if the NetConnection has not yet been established.
		 * 
		 * @see #detectBandwidth
		 * @see #bandwidth
		 */
		public function get latency():Number {
			return _streamEstablished ? _nc.latency: -1;
		};
		/**
		 * The IP address of the server to which the class connected. This parameter will only be returned if the class has managed to
		 * successfully connect to the server. The class uses the IDENT function to locate the optimum (in terms
		 * of physical proximity and load) server for connections. 
		 * <p />
		 * This property is not available with progressive playback. 
		 * 
		 * @return Server IP address as a string if the connection has been made, otherwise null.
		 * 
		 */
		public function get serverIPaddress():String {
			return _connectionEstablished ? _ip: null;
		}
		/**
		 * The last hostName used by the class. If the hostName was sent in the <code>connect</code> method
		 * concatenated with the application name (for example <code>connect("cpxxxx.edgefcs.net/myappalias")</code>)
		 * then this method will only return "cpxxxx.edgefcs.net". Use the <code>appName</code> to retrieve the
		 * application name.
		 * 
		 * @return the last hostName used by the class
		 * 
		 * @see #appName
		 * 
		 */
		public function get hostName():String {
			return _hostName;
		}
		/**
		 * The last appName used by the class. 
		 * 
		 * @return the last appName used by the class
		 * 
		 * @see #appName
		 * 
		 */
		public function get appName():String {
			return _appName;
		}
		/**
		 * The port on which the class has connected. This parameter will only be returned if the class has managed to
		 * successfully connect to the server. Possible port values are "1935", "443", and "80". This property differs
		 * from requestedPort since it returns the port that was actually used and not the port combination that was requested.
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the port over which the connection has actually been made, otherwise null.
		 * 
		 * @see #requestedPort
		 */
		public function get actualPort():String {
			return _connectionEstablished ? _nc.port: null;
		}
		/**
		 * The name-value pairs required for invoking connection authorization services on the 
		 * Akamai network. Typically these include the "auth","aifp" and "slist"
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not commence with a "?", "&" or "/". An example of a valid authParams string
		 * would be:<p />
		 * 
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp&slist=secure/babutest
		 * 
		 * <p />
		 * These properties must be set before calling the <code>connect</code> method,
		 * since authorization is checked when the connection is first established.
		 * If the authorization parameters are rejected by the server, then error #13 
		 * will be dispatched  - "Connection attempt rejected by server".
		 * <p />
		 * For live stream, per stream authentication, which can occur in combination with connection
		 * authentication, set the <code>liveStreamAuthParams</code> parameters before calling
		 * the <code>play()</code> method. 
		 * 
		 * <p />
		 * Auth params cannot be used with progressive playback and are for streaming connections only. 
		 * 
		 * @return the authorization name-value pairs.
		 * 
		 * @default empty string.
		 *
		 * @see #connect
		 * @see #liveStreamAuthParams
		 */
		public function get authParams():String {
			return _authParams;
		}
		/**
		 *  @private
		 */
		public function set authParams(ap:String):void {
			_authParams = ap;
		}
		/**
		 * The name-value pairs required for invoking stream-level authorization services against
		 * live streams on the Akamai network. Typically these include the "auth" and "aifp" 
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not commence with a "?", "&" or "/". An example of a valid authParams string
		 * would be:<p />
		 * 
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp
		 * 
		 * <p />
		 * These properties must be set before calling the <code>play</code> method,
		 * since per stream authorization is invoked when the file is first played (as opposed
		 * to connection auth params which are invoked when the connection is made).
		 * If the stream-level authorization parameters are rejected by the server, then
		 * AkamaiErrorEvent.ERROR event #22 "NetStream Failed - check your live stream auth params"
		 * will be dispatched. The AkamaiStatusEvent.NETSREAM event will also be dispatched with a <code>info.code</code> property 
		 * of "NetStream.Failed". Note that the AkamaiStatusEvent.SUBSCRIBED event will be 
		 * dispatched, even though stream playback will fail.
		 *
		 * @see #authParams
		 * @see #play
		 */
		public function get liveStreamAuthParams():String {
			return _liveStreamAuthParams;
		}
		/**
		 *  @private
		 */
		public function set liveStreamAuthParams(ap:String):void {
			_liveStreamAuthParams = ap;
		}
		/**
		 * The port(s) over which the class may attempt to connect. These combinations are specified
		 * as a single string of ports separated by a delimiter.
		 * Possible requested port values are "any", "1935", "443" and "80", or
		 * any combination of these values, separated by the ',' delimiter. "any" is a reserved word meaning that the 
		 * class should attempt all of the ports which the Akamai network supports. Valid examples include
		 * "1935,80", "443,80" etc. The order in which the ports are specified is the order in which the connection
		 * attempts are made. All the ports for the first protocol (as specified by requestedProtocol) are attempted,
		 * followed by all the ports for the second protocol etc. For example, if requestedPort was set to "1935,80" and requestedProtocol
		 * to "rtmpt,rtmpe", then the connection attempt sequence would be:
		 * <ul>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:180</li>
		 * </ul>
		 * <p />
		 * If requestedPort is set to "any" (the default), then the port order is set to "1935,443,80". If both requestedPort
		 * and requestedProtocol are set to "any" then the following optimized sequence is used:
		 * <ul>
		 * <li> rtmp:1935</li>
		 * <li> rtmp:443</li>
		 * <li> rtmp:80</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpt:443</li>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:443</li>
		 * <li> rtmpe:80</li>
		 * <li> rtmpte:80</li>
		 * <li> rtmpte:443</li>
		 * <li> rtmpte:1935</li>
		 * </ul>
		 * <p />
		 * This property is not available with progressive playback. 
		 * 
		 * @return the requested port 
		 * 
		 * @default "any"
		 * 
		 * @see #actualPort
		 * @see #requestedProtocol
		 */
		public function get requestedPort():String {
			return _port;
		}
		/**
		 *  @private
		 */
		public function set requestedPort(p:String):void {
			var aPort:Array = p.split(",");
			for (var i:String in aPort) {
				if (!(aPort[i].toLowerCase() == "any" || aPort[i] == "1935" || aPort[i] == "80" || aPort[i] == "443")) {
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,4,"Warning - this port is not supported on the Akamai network"));
				} 
			}
			_port = p;
			
		}
		/**
		 * The protocol over which the class has connected. This parameter will only be returned if the class has managed to
		 * successfully connect to the server. Possible protocol values are "rtmp","rtmpt","rtmpe" or "rtmpte". This property will
		 * differ from requestedProtocol if the requestedProtocol value was "any", in which case this property will return
		 * the protocol that was actually used.
		 * 
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the protocol over which the connection has actually been made, otherwise null.
		 * 
		 * @see #requestedProtocol
		 */
		public function get actualProtocol():String {
			return _connectionEstablished ? _nc.protocol2 : null;
		}
		/**
		 * The protocol(s) over which the class was originally requested to connect via the <code>requestedProtocol</code> property.
		 * These combinations are specified as a single string of protocols separated by a delimiter.
		 * Possible requested protocol values are "any", "rtmp","rtmpt","rtmpe" or "rtmpte", or
		 * any combination of these values, separated by the ',' delimiter. "any" is a reserved word meaning that the 
		 * class should attempt all of the protocols which the Akamai network supports. Valid examples include
		 * "rtmpt,rtmp", "rtmpe,rtmpte" etc. The order in which the protocols are specified is the order in which the connection
		 * attempts are made. This property will differ from <code>actualProtocol</code> if the requestedProtocol value was "any", in which case <code>actualProtocol</code>
		 * will return the protocol that was actually used. The order in which the protocols are specified is the order in which the connection
		 * attempts are made. All the ports (as specified by requestedPort) for the first protocol are attempted,
		 * followed by all the ports for the second protocol etc. For example, if requestedPort was set to "1935,80" and requestedProtocol
		 * to "rtmpt,rtmpe", then the connection attempt sequence would be:
		 * <ul>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:180</li>
		 * </ul>
		 * <p />
		 * 
		 * If requestedProtocol is set to "any" (the default), then the protocol order is set to "rtmp,rtmpt,rtmpe,rtmpte". If both requestedPort
		 * and requestedProtocol are set to "any" then the following optimized sequence is used:
		 * <ul>
		 * <li> rtmp:1935</li>
		 * <li> rtmp:443</li>
		 * <li> rtmp:80</li>
		 * <li> rtmpt:80</li>
		 * <li> rtmpt:443</li>
		 * <li> rtmpt:1935</li>
		 * <li> rtmpe:1935</li>
		 * <li> rtmpe:443</li>
		 * <li> rtmpe:80</li>
		 * <li> rtmpte:80</li>
		 * <li> rtmpte:443</li>
		 * <li> rtmpte:1935</li>
		 * </ul>
		 * 
		 * <p />
		 * This property is not available with progressive playback.
		 * 
		 * @return the requested protocol 
		 * 
		 * @default "any"
		 * 
		 * @see #actualProtocol
		 * @see #requestedPort
		 */
		public function get requestedProtocol():String {
			return _protocol;
		}
		/**
		 *  @private
		 */
		public function set requestedProtocol(p:String):void {
			var aProtocol:Array = p.split(",");
			for (var i:String in aProtocol) {
				if (!(aProtocol[i].toLowerCase()== "any" || aProtocol[i].toLowerCase() == "rtmp" || aProtocol[i].toLowerCase() == "rtmpt" || aProtocol[i].toLowerCase() == "rtmpe" || aProtocol[i].toLowerCase() == "rtmpte")) {
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,3,"Warning - this protocol is not supported on the Akamai network"));
				} 
			}
			_protocol = p;
			
		}
		/**
		 * The interval in milliseconds at which the AkamaiNotificationEvent.PROGRESS is dispatched.
		 * This event commences with the first <code>play()</code> request and continues until <code>close()</code>
		 * is called. 
		 * 
		 * @return the AkamaiNotificationEvent.PROGRESS interval in milliseconds.
		 * 
		 * @default 100
		 * 
		 * @see #play
		 * @see #close
		 */
		public function get progressInterval():Number {
			return _progressTimer.delay;
		}
		/**
		 *  @private
		 */
		public function set progressInterval(delay:Number):void {
			_progressTimer.delay = delay;
		}
		/**
		 * The bytes downloaded by the current progressive stream. This property only has meaning
		 * for progressive streams. 
		 * 
		 * @return the bytes that have been downloaded for the current progressive stream.
		 */
		public function get bytesLoaded():Number {
			return _ns.bytesLoaded;
		}
		/**
		 * The total bytes of the current progressive stream. This property only has meaning
		 * for progressive streams. 
		 * 
		 * @return the total bytes of the current progressive stream.
		 */
		public function get bytesTotal():Number {
			return _ns.bytesTotal;
		}

		/**
		 * The version of this class. Akamai may release updates to this class and the version number
		 * will increment with each release. 
		 * 
		 */
		public function get version():String {
			return VERSION;
		}
		/**
		 * The desired buffer length set for the NetStream, in seconds. If <code>useFastStartBuffer</code> has
		 * been set false (the default), then this value will be used to set the constant buffer value on the NetStream. If
		 * <code>useFastStartBuffer</code> has been set true, then the NetStream buffer will alternate between 0.5
		 * (after a NetStream.Play.Start event) and the value set by this property.
		 * 
		 * @default 3
		 * 
		 * @see #useFastStartBuffer
		 * @see #bufferTime
		 * @see #bufferLength
		 * 
		 */
		public function get maxBufferLength():Number {
			return _maxBufferLength;
		}
		/**
		 * @private
		 */
		public function set maxBufferLength(length:Number):void{
			 if (length < 0.1) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,2,"Buffer length must be > 0.1")); 
			 } else {
				_maxBufferLength = length;
			 }
		}
		/**
		 * The number of seconds assigned to the buffer. This property returns a meaningful value
		 * if the NetStream has been created as a result of <code>createStream</code> being set true, or -1 otherwise.
		 * During normal operation, the flash client will work with the server to maintain a buffer length of between
		 * 1x and 2x this bufferTime value. If <code>maxBufferLength</code> has been set by the client, then
		 * <code>bufferTime</code> will always equal <code>maxBufferLength</code> if <code> useFastStartBuffer</code>
		 * is disabled. If <code> useFastStartBuffer</code> is enabled, then <code>bufferTime</code> will return 0.5
		 * until the first <code>NetStream.Buffer.Full</code> event, after which it will again match <code>maxBufferLength</code>.
		 * <p/>
		 * [DEPRECATED] - in v1.4 of this framework, this property was falsely documented as delivering the 'the bufferTime,
		 *  in seconds, currently reported by the stream.'. To retrieve the number of seconds actually in the buffer at any
		 * moment, use the bufferLength property.
		 * 
		 * @see #createStream
		 * @see #bufferLength
		 * @see #maxBufferLength
		 */
		public function get bufferTime():Number {
			return _streamEstablished ? _ns.bufferTime : -1;
		}
		/**
		 * The number of seconds of data currently in the buffer. This property returns a meaningful value
		 * if the NetStream has been created as a result of <code>createStream</code> being set true, or -1 otherwise.
		 * During normal operation, the flash client will work with the server to maintain a <code>bufferLength<code> value 
		 * of between 1x and 2x the bufferTime value. 
		 * 
		 * @see #createStream
		 * @see #bufferTime
		 * @see #maxBufferLength
		 */
		public function get bufferLength():Number {
			return _streamEstablished ? _ns.bufferLength: -1;
		}
		/**
		 * The buffer percentage currently reported by the stream. This property only returns a value if the
		 * a NetStream has been created as a result of <code>createStream</code> being set true. This property
		 * will always have an integer value between 0 and 100. The max value is capped at 100 even if the bufferLength
		 * exceeds the bufferTime.
		 * 
		 * @see #bufferTime
		 * @see #maxBufferLength
		 */
		public function get bufferPercentage():Number {
			return _streamEstablished ? Math.min(100,(Math.round(_ns.bufferLength*100/_ns.bufferTime))) : -1;
		}
		/**
		 * Defines whether the current connection is progressive or not.
		 * 
		 * @return true if the conenction is progressive or false if not. 
		 * 
		 * @see #connect
		 */
		public function get isProgressive():Boolean {
			return _isProgressive;
		}
		/**
		 * Defines whether the current stream is a live stream. Playback of live streams requires a subscription process
		 * to be managed by the class and is handled differently from on-demand streams.<p />
		 * Note that the Fast Start buffer management feature cannot be used with live streams, since live data cannot
		 * be prebuffered. If <code>useFastStartBuffer</code> is <code>true</code> when <code>isLive</code> is set <code>true</code>,
		 * then <code>useFastStartBuffer</code> will automatically be set <code>false</code> and error event #19 dispatched.
		 * 
		 * @default false
		 * @see #useFastStartBuffer
		 */
		public function get isLive():Boolean {
			return _isLive;
		}
		/**
		 * @private
		 */
		public function set isLive(isLive:Boolean):void {
			if (_useFastStartBuffer && isLive) {
				_useFastStartBuffer = false;
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,19,"The Fast Start feature cannot be used with live streams"));
			}
			_isLive = isLive;
		}
		/**
		 * The maximum number of seconds the class should wait before timing out while trying to locate a live stream
		 * on the network. This time begins decrementing the moment a <code>play</code> request is made against a live
		 * stream, or after the class receives an onUnpublish event while still playing a live stream, in which case it
		 * attempts to automatically reconnect. After this master time out has been triggered, the class will issue
		 * an Error event #9.
		 * 
		 * @default 3600
		 */
		public function get liveStreamMasterTimeout():Number {
			return _liveStreamMasterTimeout/1000;
		}
		/**
		 * @private
		 */
		public function set liveStreamMasterTimeout(numOfSeconds:Number):void {
			_liveStreamMasterTimeout = numOfSeconds*1000;
			_liveStreamTimer.delay = _liveStreamMasterTimeout;
		}
		/**
		 * Initiates a new bandwidth measurement. Note that the player for the Apple&reg; Mac OS&reg; operating system has a bug when detecting bandwidth on
		 * the latest Akamai network, so the class will call the old bandwidth detection methods when dealing with this client.
		 * To recover the estimated bandwidth value, wait for the AkamaiNotificationEvent.BANDWIDTH event and then inspect
		 * the <code>bandwidth</code> property.<p />
		 * (Apple&reg; and Mac OS&reg; are trademarks of Apple Inc., registered in the U.S. and other countries. Use of
		 * these marks is for information purposes only and is not intended to imply endorsement by Apple of
		 * Akamai products or services).
		 * 
		 * <p />
		 * This method is not available with progressive playback. To estimate bandwidth with progressive connections,
		 * use the HTTPBandwidthEstimate class. 
		 * 
		 * @see com.akamai.utilities.HTTPBandwidthEstimate
		 * 
		 * @return true if the connection has been established, otherwise false.
		 * 

		 */
		public function detectBandwidth():Boolean {
			if (_connectionEstablished) {
				if (Capabilities.version.indexOf("MAC") != -1) {
					_nc.expectBWDone = true;
					_nc.call("checkBandwidth",null);
				} else {
					// try the new bandwidth method first
					_nc.call("_checkbw",null);
				}
			}
			return _connectionEstablished 
		}
		/**
		 * Determines whether the class should create and manage a NetStream, in addition to establishing a NetConnection
		 * with the Akamai Streaming service.
		 * 
		 * @default false
		 */
		public function get createStream():Boolean {
			return _createStream;
		}
		/**
		 * @private
		 */
		public function set createStream(create:Boolean):void {
			_createStream = create;
		}
		/**
		 * Returns a reference to the active NetConnection object. This property will
		 * only return a valid reference if the connection was successful. Use this property to obtain
		 * access to NetConnection properties and methods that are not proxied by this class.
		 * 
		 * @return the NetConnection object, or null if the connection was unsuccessful.
		 */
		public function get netConnection():NetConnection {
			return _connectionEstablished ? NetConnection(_nc): null;
		}
		/**
		 * Returns a reference to the active NetStream object. This property will
		 * only return a valid reference if <code>createStream</code> was set true prior 
		 * to <code>connect</code> being called.
		 * 
		 * @return the NetStream object, or null if the NetStream was not established.
		 * 
		 * @see #createStream
		 */
		public function get netStream():NetStream {
			return _streamEstablished ? _ns: null;
		}
		/**
		 * Returns frames per second of the current NetStream. 
		 * 
		 */
		public function get fps():Number{
			return _streamEstablished ? _ns.currentFPS: -1;
		}
		/**
		 * Returns the number of seconds of data in the subscribing stream's buffer in live (unbuffered) mode. 
		 * This property will only return a valid reference if <code>createStream</code> was set true prior 
		 * to <code>connect</code> being called and the stream being played is a live stream. 
		 * 
		 * @see #createStream
		 * @see #isLive
		 */
		public function get liveDelay():Number{
			return (_streamEstablished  && _isLive)? _ns.liveDelay: -1;
		}
		/**
		 * Primary method for playing content on the active NetStream, if it exists. This method supports both streaming
		 * and progressive playback.
		 * <p />
		 * Streaming playback:
		 * <br />
		 * The stream name argument format will vary depending on the type of file you are streaming. The various conventions are best understood if we
		 * explain how the server processes the filename that it receives.  If there is no reserved prefix 
		 * at the start of the file, then FMS assumes that an FLV file is being played and will automatically append a ".flv" to the end of the stream name
		 * when retrieving the file from storage. If the stream name begins with "mp3:" then the server assumes that an .mp3 file is being played and will add 
		 * a ".mp3" extension to the filename. If the stream beins with "mp4:" then the server assumes a H.264 file is being played and will add
		 * a ".mp4" extension unless it detects another extension already there. Given this server-side behavior, the following stream naming rules apply:
		 * <br/>
		 * <ul><li>FLV files - when streaming .flv files (both vp6 and Spark codec), the file extension must NOT be included.
		 * If it is, then stream length lookup and playback will fail. </li>
		 * <li>MP3 files - the file extension must NOT be included. The reserved prefix "mp3:" must be used at the start of the stream name.</li>
		 * <li>H.264 files - this includes all files these extensions: .mp4, .m4v, .m4a, .mov, .3gp, f4v, f4p, f4a, and f4b.
		 * The file extension MUST be included, except if the file is a .mp4 file in which case the default extension of .mp4 will
		 * be applied. The reserved prefix "mp4:" must also be used at the start of the stream name. </li>
		 * </ul>
		 * <p />Examples of valid stream names include: <ul>
		 * <li>myfile</li>
		 * <li>myfolder/myfile</li>
		 * <li>my_live_stream&#64;567</li>
		 * <li>my_secure_live_stream&#64;s568</li>
		 * <li>mp3:myfolder/mymp3file</li>
		 * <li>mp4:myfolder/mymp4file</li>
		 * <li>mp4:myfolder/mymp4file.mp4</li>
		 * <li>mp4:myfolder/mymovfile.mov</li>
		 * <li>mp4:myfolder/my3gpfile.3gp</li>
		 * <li>mp4:myfolder/my3gpfile.f4v</li>
		 * </ul>
		 * Examples of invalid stream names include:
		 * <ul>
		 * <li>myfile.flv</li>
		 * <li>myfolder/myfile.flv</li>
		 * <li>myfolder/mymp3file.mp3</li>
		 * <li>mp3:myfolder/mymp3file.mp3</li>
		 * <li>myfolder/mymp4file.mp4</li>
		 * <li>mp4:myfolder/myf4vfile</li>
		 * <li>mp4:myfolder/myfmovfile</li>
		 * </ul>
		 * <p />
		 * Progressive playback:
		 * <br />
		 * The stream name argument must be an absolute or relative path to a FLV or H.264 file and must include the file
		 * extension. MP3 files cannot be played through this class using progressive playback. Ensure that the
		 * Flash player security sandbox restrictions do not prohibit the loading of the MP3 from the source
		 * being specified. Examples of valid stream arguments for progressive playback include:
		 * <ul>
		 * <li>http://myserver.mydomain.com/myfolder/myfile.flv</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.m4v</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.m4a</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.mov</li>
		 * <li>http://myserver.mydomain.com/myfolder/myfolder/myfile.3gp</li>
		 * <li>myfolder/myfile.flv</li>
		 * </ul>
		 * <p />
		 * Note that playback of H.264 files, both streaming and progressive, requires a flash client version greater than 9.0.60.
		 * 
		 * @param the name of the stream to play. 
		 */
		public function play(name:String):void {
			if (_streamEstablished) {
				if (!_progressTimer.running) {
					_progressTimer.start();				
				}
				_isPaused = false;
				if (_isLive) {
					if (_liveStreamAuthParams != "") {
						_pendingLiveStreamName = name.indexOf("?") != -1 ? name + "&"+_liveStreamAuthParams : name+"?"+_liveStreamAuthParams;
					} else {
						_pendingLiveStreamName = name;
					}
					_playingLiveStream = true;
					_successfullySubscribed = false;
					startLiveStream();					
				} else {
					_playingLiveStream = false;
					if (_isProgressive) {
						_ns.play(name);
					} else {
						_ns.play(name,0);
					}
					
				}
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,8,"Cannot play, pause, seek or resume since the stream is not defined"));
			}
		}
		/**
		 * Pauses the active netStream, if it exists.
		 */
		public function pause():void {
			if (_streamEstablished) {
				_ns.pause();
				_isPaused = true;
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,8,"Cannot play, pause, seek or resume since the stream is not defined"));
			}
		}
		/**
		 * Resumes the active netStream, if it exists.
		 */
		public function resume():void {
			if (_streamEstablished) {
				_ns.resume();
				_isPaused = false;
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,8,"Cannot play, pause, seek or resume since the stream is not defined"));
			}
		}
		/**
		 * Seeks the active NetStream to a specific offset, if the NetStream exists.
		 * 
		 * @param the time value, in seconds, to which to seek. 
		 */
		public function seek(offset:Number):void {
			if (_streamEstablished) {
				_ns.seek(offset);
			} else {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,8,"Cannot play, pause, seek or resume since the stream is not defined"));
			}
		}
		/**
		 * Initiates the process of unsubscribing from the active live NetStream. This method can only be called if
		 * the class is currently subscribed to a live stream. Since unsubscription is an asynchronous
		 * process, confirmation of a successful unsubscription is delivered via the AkamaiNotificationEvent.UNSUBSCRIBED event. 
		 * 
		 * @return true if previously subscribed, otherwise false.
		 */
		public function unsubscribe():Boolean {
			if (_successfullySubscribed) {
				resetAllLiveTimers();
				_playingLiveStream = false;
				_ns.play(false);
				_nc.call("FCUnsubscribe", null, _pendingLiveStreamName);
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * The buffer timeout value, in millseconds, of the NetStream. If, during playback, the buffer empties
		 * and does not fill again before the buffer timeout interval passes, then error # 24 "NetStream buffer
		 * has remained empty past timeout threshold" is dispatched.
		 * This value and error are designed to trap very rare network abnormalities in which the server never
		 * fills the buffer, nor sends a close event, thereby leaving the client in a hung state. As a developer,
		 * if you receive this error, you should reestablish the connection.<p/>
		 * Note - this event is only fired for on-demand streaming content, not for live streaming
		 * or progressively delivered content. 
		 * 
		 * @default 20,000
		 */
		public function get bufferTimeout():Number{
			return _bufferFailureTimer.delay;
		}
		/**
		 * @private
		 */
		public function set bufferTimeout(num:Number):void {
			_bufferFailureTimer.delay = num;
		}
		/**
		 * The volume of the current NetStream. Possible volume values lie between 0 (silent) and 1 (full volume).
		 * 
		 * @default 1
		 */
		public function get volume():Number{
			return _volume;
		}
		/**
		 * @private
		 */
		public function set volume(vol:Number):void {
			if (vol < 0 || vol > 1) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,11,"Volume value out of range"));
			} else {
				_volume = vol;
				if (_streamEstablished) {
					_ns.soundTransform = (new SoundTransform(_volume,_panning));
				}
			}
		}
		/**
		 * The panning of the current NetStream. Possible volume values lie between -1 (full left) to 1 (full right).
		 * 
		 * @default 0
		 */
		public function get panning():Number{
			return _panning;
		}
		/**
		 * @private
		 */
		public function set panning(panning:Number):void {
			if (panning < -1 || panning > 1) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,11,"Invalid volume parameters(s)"));
			} else {
				_panning = panning;
				if (_streamEstablished) {
					_ns.soundTransform = (new SoundTransform(_volume,_panning));
				}
			}
		}
		/**
		 * Returns the current time of the stream, in seconds. This property will only return a valid 
		 * value if the NetStream has been established.
		 */
		public function get time():Number {
			return _streamEstablished ?_ns.time : -1;
		}
		/**
		 * Returns the current time of the stream, as timecode HH:MM:SS. This property will only return a valid 
		 * value if the NetStream has been established.
		 */
		public function get timeAsTimeCode():String {
			return _streamEstablished ? timeCode(_ns.time): null;
		}
		/**
		 * Returns the buffering status of the stream. This value will be <code>true</code> after NetStream.Play.Start
		 * and before NetStream.Buffer.Full or NetStream.Buffer.Flush and <code>false</code> at all other times. 
		 */
		public function get isBuffering():Boolean {
			return _isBuffering;
		}
		/**
		 * Initiates the server request to measure the stream length of a file. Since this measurement is an asynchronous
		 * process, the stream length value can retrieved by calling the <code>streamLength</code> method after receiving 
		 * the AkamaiNotificationEvent.STREAM_LENGTH event. Note that the name of the file being measured is 
		 * decoupled from the file being played, meaning that you can request the length of one file while playing another.
		 * 
		 * @param the name of the file for which length is to be requested.
		 * 
		 * @see #streamLength
		 * 
		 * @return true if the connection has been established, otherwise false.
		 */
		public function requestStreamLength(filename:String):Boolean {
			if (!_connectionEstablished|| _isLive || filename == "") {
				return false;
			} else {
				_streamLength = undefined;
				// if the filename includes parameters, strip them off, since the server canot handle them.
				_nc.call("getStreamLength", new Responder(onStreamLengthResult, onStreamLengthFault), filename.indexOf("?") != -1 ? filename.slice(0,filename.indexOf("?")):filename );
				return true;
			}
		}
		/**
		 * Returns the stream length (duration) in seconds of the file specified by the last request to <code>requestStreamLength</code>. 
		 * This method can only be called after the AkamaiNotificationEvent.STREAM_LENGTH event has been received.
		 * 
		 * @return the length in seconds of the file
		 */
		public function get streamLength():Number {
				return _streamLength;
		}
		/**
		 * Returns the stream length (duration) in timecode HH:MM:SS format, of the file specified by the last request to
		 * <code>requestStreamLength</code>. This method can only be called after the
		 * AkamaiNotificationEvent.STREAM_LENGTH event has been received.
		 * 
		 * @return the length as timecode HH:MM:SS
		 */
		public function get streamLengthAsTimeCode():String{
			return _streamEstablished ? timeCode(_streamLength): null;
		}
		/**
		 * Initiates the process of extracting the ID3 information from an MP3 file. Since this process is asynchronous,
		 * the actual ID3 metadata is retrieved by listening for the AkamaiStatusEvent.MP3_ID3 and inspecting the <code>info</code> parameter.
		 * 
		 * @return false if the NetConnection has not yet defined, otherwise true. 
		 */
		public function getMp3Id3Info(filename:String):Boolean {
			if (!_connectionEstablished) {
				return false;
			} else {
				if (!(_nsId3 is NetStream)) {
					_nsId3 = new NetStream(_nc);
					_nsId3.client = this;
					_nsId3.addEventListener(Event.ID3,onId3);
					_nsId3.addEventListener(NetStatusEvent.NET_STATUS,id3StreamStatus);
	    		}
				if (filename.slice(0, 4) == "mp3:" || filename.slice(0, 4) == "id3:") {
					filename = filename.slice(4);
				}
				_nsId3.play("id3:"+filename);
				return true;
			}
		}
		/**
		 * Dictates whether a fast start (dual buffer) strategy should be used. A fast start buffer means that the
		 * NetStream buffer is set to value of 0.5 seconds after a NetStream.Play.Start or NetStream.Buffer.Empty event
		 * and then to maxBufferLength after the NetStream.Buffer.Full event is received. This gives the advantages of a
		 * fast stream start combined with a robust buffer for long-term bandwidth. Users whose connections
		 * are close to the bitrate of the stream may see very rapid stuttering of the stream with
		 * this approach, so it is best deployed in situations in which each users' bandwidth is several multiples
		 * of the streaming files' bitrate.<p />
		 * 
		 * Note that fast start cannot be used with LIVE STREAMS, since live data canot be prebuffered. If you attempt to set
		 * useFastStartBuffer to <code>true</code> when <code>isLive</code> is <code>true</code>, then error event #19
		 * "The Fast Start feature cannot be used with live streams" will be dispatched and the value will not be set.
		 * 
		 * @see maxBufferLength
		 * @see #isLive
		 */
		public function get useFastStartBuffer():Boolean {
			return _useFastStartBuffer;
		}
		/**
		 * @private
		 */
		public function set useFastStartBuffer(b:Boolean):void {
			if (_isLive && b) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,19,"The Fast Start feature cannot be used with live streams"));
			}else {
				_useFastStartBuffer = b;
				if (!b && _streamEstablished) {
					_ns.bufferTime = _maxBufferLength;
				}
			}
		}
		/**
		 * Closes the NetConnection and NetStream instances, if they exist.
		 * After calling this method, the API will cease to function, so this method
		 * should be the last method that is called when interacting with the class.
		 * 
		 */
		public function close():void {
			if (_streamEstablished) {
				_progressTimer.stop();
				_ns.close();
				_streamEstablished = false;
			}
			if (_connectionEstablished) {
				_nc.close();
				_connectionEstablished = false;
			}
		}
		/**
		 * Closes the NetStream instance only. This method stops playing all data on the stream,
		 * sets the time property to 0, and makes the stream available for another use.  
		 * If mutiple instances of the AkamaiConnection class are being used in a project, use this 
		 * method to close down streams as you switch playback between instances. 
		 * 
		 */
		public function closeNetStream():void {
			if (_streamEstablished) {
				_progressTimer.stop();
				_ns.close();
			}
		}
		/**
		 * Used internally by the class
		 * @private
		 */
		public function onId3( info:Object ):void
            {
                dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.MP3_ID3,info));
            }
		/**
		 * Catches netstream onTranstion events
		 * @private
		 */
		public function onTransition(info:Object,... args):void {
        		// no action is currently taken
    	}
    	/** Catches netstream onPlayStatus events
    	 * @private
    	 */
		public function onPlayStatus(info:Object):void {
        		dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM_PLAYSTATUS,info));
        		if (info.code == "NetStream.Play.Complete") {
        			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.COMPLETE));
        			_bufferFailureTimer.reset();
        			handleEnd();
        		}
    	}
    	/** Catches netstream onMetaData events and looks for duration of a progressive stream
    	 * @private
    	 */
		public function onMetaData(info:Object):void {
        		dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM_METADATA,info));
    			if (_isProgressive && !isNaN(info["duration"])) {
    				_streamLength = Number(info["duration"]);
					dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.STREAM_LENGTH)); 
    			}
    	}
    	/** Catches netstream onImageData events  - only relevent when playing H.264 content
    	 * @private
    	 */
		public function onImageData(info:Object):void {
        		dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM_IMAGEDATA,info));
    	}
    	/** Catches netstream onTextData events  - only relevent when playng H.264 content
    	 * @private
    	 */
		public function onTextData(info:Object):void {
        		dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM_TEXTDATA,info));
    	}
    	/** Catches netstream cuepoint events
    	 * @private
    	 */
		public function onCuePoint(info:Object):void {
        		dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM_CUEPOINT,info));
    	}
		/** Sets default values for certain variables
		 * @private
		 */
		private function initVars():void {	
			_createStream = false;
			_maxBufferLength = 3;
			_volume = 1;
			_panning = 0;
			_fpadZone = 0;
			_liveStreamMasterTimeout = 3600000;
			_useFastStartBuffer = false;
			_isBuffering = false;
			_watchForBufferFailure = false;
			_port = "any";
			_protocol = "any";
			_isLive = false;
			_authParams = "";
			_liveStreamAuthParams = "";
			_aboutToStop = 0;
		}
		/** Handles the responder result from a streamlength request.
		 * @private
		 */
		private function onStreamLengthResult(streamLength:Number):void {
			_streamLength = streamLength;
			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.STREAM_LENGTH)); 
		}
		/** Handles the responder fault after a streamlength request
		 * @private
		 */
		private function onStreamLengthFault():void {
			_streamLength = undefined;
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,10,"Error requesting stream length"))
		}
		/** Catches IO errors when requesting IDENT xml
		 * @private
		 */
		private function catchIOError(event:IOErrorEvent):void {
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,5,"Warning - unable to load XML data from ident request, will use domain name to connect"));	
			_ip = _hostName;
			buildConnectionSequence();
		}
	    /** Handles the XML return from the IDENT request
	    * @private
	    */
	    private function akamaiXMLLoaded(event:Event):void { 
				_ip = XML(_akLoader.data).ip;
				buildConnectionSequence();
				
		}
		/** Builds an array of connection strings and starts connecting
		 * @private
		 */
		private function buildConnectionSequence():void {
			var aPortProtocol:Array = buildPortProtocolSequence();
			_aConnections = new Array();
			_aNC = new Array();
			for (var a:uint = 0; a<aPortProtocol.length; a++) {
				var connectionObject:Object = new Object();
				var address:String = aPortProtocol[a].protocol+"://"+_ip+":"+aPortProtocol[a].port+"/"+_appName+"?_fcs_vhost="+_hostName+"&akmfv="+VERSION+(_authParams == "" ? "":"&"+_authParams);
				connectionObject.address = address;
				connectionObject.port = aPortProtocol[a].port;
				connectionObject.protocol = aPortProtocol[a].protocol;
				_aConnections.push(connectionObject);
			}
			_bufferFailureTimer.reset();
			_timeOutTimer.reset();
			_timeOutTimer.start();
			_connectionAttempt = 0;
			_connectionTimer.reset();
			_connectionTimer.delay = _authParams == "" ? 200:350;
			_connectionTimer.start();
			tryToConnect(null);
		}
		/** Attempts to connect to FMS using a particular connection string
		 * @private
		 */
		private function tryToConnect(evt:TimerEvent):void {
			var anc:AkamaiNetConnection = new AkamaiNetConnection()
			_onConnectionCreated(anc);
			_aNC[_connectionAttempt] = anc;
			_aNC[_connectionAttempt].addEventListener(NetStatusEvent.NET_STATUS,netStatus);
    		_aNC[_connectionAttempt].addEventListener(SecurityErrorEvent.SECURITY_ERROR,netSecurityError);
    		_aNC[_connectionAttempt].addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
			_aNC[_connectionAttempt].addEventListener(AkamaiNotificationEvent.BANDWIDTH,bubbleNotificationEvent);
			_aNC[_connectionAttempt].addEventListener(AkamaiStatusEvent.FCSUBSCRIBE,onFCSubscribe);
			_aNC[_connectionAttempt].addEventListener(AkamaiStatusEvent.FCUNSUBSCRIBE,onFCUnsubscribe);
			_aNC[_connectionAttempt].client = _aNC[_connectionAttempt];
			_aNC[_connectionAttempt].index = _connectionAttempt;
			_aNC[_connectionAttempt].expectBWDone = false;
			_aNC[_connectionAttempt].port = _aConnections[_connectionAttempt].port;
			_aNC[_connectionAttempt].protocol2 = _aConnections[_connectionAttempt].protocol;
			_aNC[_connectionAttempt].connection = this;
			try {
			_aNC[_connectionAttempt].connect(_aConnections[_connectionAttempt].address, false);
			}
			catch (error:Error) {
				// the connectionTimer will time out and report an error.
			}
			finally {
				_connectionAttempt++;
				if (_connectionAttempt >= _aConnections.length) {
					_connectionTimer.stop();
				}
			}
		}
		/** Catches events from the AkamaiNetConnection instance and bubbles them upward.
		 * @private
		 */
		private function bubbleNotificationEvent(e:AkamaiNotificationEvent):void {
				dispatchEvent(new AkamaiNotificationEvent(e.type)); 	
		}
		/** Handles the onFCSubscribe call from the server
		 * @private
		 */
		private function onFCSubscribe(e:AkamaiStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Play.Start" :
					resetAllLiveTimers();
					_successfullySubscribed = true;
					dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.SUBSCRIBED)); 
					_ns.play(_pendingLiveStreamName,-1);
					if (_isPaused) {
						_ns.pause();
					}
					break;
				case "NetStream.Play.StreamNotFound" :
					_liveStreamRetryTimer.reset();
					_liveStreamRetryTimer.start();
					break;
				} 
		}
		/** Handles the onFCUnsubscribe call from the server
		 * @private
		 */
		private function onFCUnsubscribe(e:AkamaiStatusEvent):void {
			switch (e.info.code) {
				case "NetStream.Play.Stop":
					_successfullySubscribed = false;
					dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.UNSUBSCRIBED)) 
					if (_playingLiveStream) {
						startLiveStream();
					}
				break;
			}
		}
		/** Notifies the parent that the stream has been unsubscribed
		 * @private
		 */
		private function unsubscribedFromStream(e:AkamaiStatusEvent):void {
			dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.FCUNSUBSCRIBE,e.info)); 
		}
		/** Handles all status events from the NetConnections
		 * @private
		 */
		private function netStatus(event:NetStatusEvent):void {
    		if (_connectionEstablished) {
    			// only dispatch netconnection events once we have a good connection, otherwise
    			// the user receives all the close() events when the parallel unused connection attempts
    			// are shut down. One exception is that if the connection is rejected, then a netconnection event
    			// is dispatched by the handleRejection() function.
    			dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETCONNECTION,event.info));
			}
			switch (event.info.code) {
				
				case "NetConnection.Connect.Rejected":
					handleRejection(event);
    				break;
    			case "NetStream.Connect.Failed":
    				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,23,"NetConnection connection attempt failed")); 
				case "NetConnection.Call.Failed":
					if (event.info.description.indexOf("_checkbw") != -1) {
						event.target.expectBWDone = true;
						event.target.call("checkBandwidth",null);
					}
					break;
				case "NetConnection.Connect.Success":
					_timeOutTimer.stop();
					_connectionTimer.stop();
					for (var i:uint = 0; i<_aNC.length; i++) {
						if (i != event.target.index) {
							_aNC[i].close();
							_aNC[i] = null;
						}
					}
					_nc = AkamaiNetConnection(event.target);
					if (_createStream) {
						setupStream();
					} else {
						handleGoodConnect();
					}	
					break;
			}
  		}
  		/** Utility function
		 * @private
		 */
		private function contains(prop:String,str:String):Boolean {
			var a:Array = prop.split(",");
			for each (var s:String in a) {
				if (s.toLowerCase() == str) {
					return true;
				}
			}
			return false;
		}
			
		/** Assembles the array of ports and protocols to be attempted
		 * @private
		 */
		private function buildPortProtocolSequence():Array {
			var aTemp:Array = new Array();
			if (_port == "any" && _protocol == "any") {
				aTemp = [{port:"1935",protocol:"rtmp"},
						 {port:"443",protocol:"rtmp"},
						 {port:"80",protocol:"rtmp"},
						 {port:"80",protocol:"rtmpt"},
						 {port:"443",protocol:"rtmpt"},
						 {port:"1935",protocol:"rtmpt"},
						 {port:"1935",protocol:"rtmpe"},
						 {port:"443",protocol:"rtmpe"},
						 {port:"80",protocol:"rtmpe"},
						 {port:"80",protocol:"rtmpte"},
						 {port:"443",protocol:"rtmpte"},
						 {port:"1935",protocol:"rtmpte"}];
			} else {
				if (contains(_port,"any")) {
					_port = "1935,443,80";
				}
				if (contains(_protocol,"any")) {
					_protocol= "rtmp,rtmpt,rtmpe,rtmpte";
				}
				var aPort:Array = _port.split(",");
				var aProtocol:Array = _protocol.split(",");
				for (var pr:Number =0; pr < aProtocol.length;pr++) {
					for (var po:Number =0; po < aPort.length;po++) {
						aTemp.push({port:aPort[po], protocol:aProtocol[pr]});
					}
				}
			}
			return aTemp;
		}
		/** Catches the master timeout when no connections have succeeded within TIMEOUT.
		 * @private
		 */
		private function masterTimeout(evt:Event):void {
			for (var i:uint = 0; i<_aNC.length; i++) {
				_aNC[i].close();
				_aNC[i] = null;
			}
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,6,"Timed-out while trying to connect")); 
		}
		/** Handles the case when the server rejects the connection
		 * @private
		 */
		private function handleRejection(event:NetStatusEvent):void {
			_timeOutTimer.stop();
			_connectionTimer.stop();
			for (var i:uint = 0; i<_aNC.length; i++) {
				_aNC[i].close();
				_aNC[i] = null;
			}
			dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETCONNECTION,event.info));
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,13,"Connection attempt rejected by server")); 
    	}
		/** Catches any netconnection net security errors
		 * @private
		 */
		private function netSecurityError(event:SecurityErrorEvent):void {
    			// no action currently taken
    	}
    	/** Catches any async errors
    	 * @private
    	 */
		private function asyncError(event:AsyncErrorEvent):void {
    	}
    	/** Creates the NetStream
    	 * @private
    	 */
		private function setupStream():void {
			_ns = new NetStream(_nc);
			_ns.bufferTime = _useFastStartBuffer ? 0.5 : _maxBufferLength;
			_ns.addEventListener(NetStatusEvent.NET_STATUS,streamStatus);
    		_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
    		_ns.addEventListener(IOErrorEvent.IO_ERROR,netStreamIOError);
    		_ns.client = this;
    		_ns.soundTransform = new SoundTransform(_volume,_panning);
    		_streamEstablished = true;
    		handleGoodConnect();
		}
		/** Handles NetStream IOError events
		 * @private
		 */
		private function netStreamIOError(event:IOErrorEvent):void {
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,21,"NetStream IO Error event:"+event.text)); 
		
		}
		/** Handles NetStream status events
		 * @private
		 */
		private function streamStatus(event:NetStatusEvent):void {
			dispatchEvent(new AkamaiStatusEvent(AkamaiStatusEvent.NETSTREAM,event.info));
			if (_useFastStartBuffer) {
				if (event.info.code == "NetStream.Play.Start" || event.info.code == "NetStream.Buffer.Empty") {
					_ns.bufferTime = 0.5;
				}
				if (event.info.code == "NetStream.Buffer.Full") {
					_ns.bufferTime = _maxBufferLength;
				}
			}
			switch(event.info.code) {
				case "NetStream.Play.Start":
					_aboutToStop = 0;
					_isBuffering = true;
					_watchForBufferFailure  = true;
					break;
				case "NetStream.Play.Stop":
					if (_aboutToStop == 2) {
						_aboutToStop = 0;
						handleEnd();
					} else {
						_aboutToStop = 1
					}
					_watchForBufferFailure  = false;
					_bufferFailureTimer.reset();
					break;
				case "NetStream.Buffer.Empty":
					if (_aboutToStop == 1) {
						_aboutToStop = 0;
						handleEnd();
					} else {
						_aboutToStop = 2
					}
					
					if (_watchForBufferFailure) {
						_bufferFailureTimer.start();
					}
					break;
				case "NetStream.Buffer.Full":
					_isBuffering = false;
					_bufferFailureTimer.reset();
					break;
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,7,"Stream not found")); 
					break;
				case "NetStream.Buffer.Flush":
					_isBuffering = false;
					break;
				case "NetStream.Failed":
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,22,"NetStream Failed - check your live stream auth params")); 
					break;
				case "NetStream.Play.Failed":
					dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,22,"NetStream Failed - check your live stream auth params")); 
					break;
			}
		}
	    /** Handles a id3 netStatus callback
		 * @private
		 */
		private function id3StreamStatus(e:NetStatusEvent):void {
			// Suppress the output since the netStream will report stream-not-found
		}
		/** Handles a successful connection
		 * @private
		 */
		private function handleGoodConnect():void {
			_connectionEstablished = true;
			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.CONNECTED)); 
		}
		/** Handles the detection of the end of a stream for FCS 1.7x servers which do
		 *  not issue the NetStream.onPlayStatus.Complete event
		 * @private
		 */
		private function handleEnd():void {
			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.END_OF_STREAM)); 
		}
		/** Catches the timeout when a live stream has been requested but cannot be found on the server
		 * @private
		 */
		private function liveStreamTimeout(e:TimerEvent):void {
			resetAllLiveTimers();
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,9,"Timed-out trying to find the live stream")); 
		}
		/** Utility funciton for generating time code
		 * @private
		 */
		private function timeCode(sec:Number):String {
			var h:Number = Math.floor(sec/3600);
			var m:Number = Math.floor((sec%3600)/60);
			var s:Number = Math.floor((sec%3600)%60);
			return (h == 0 ? "":(h<10 ? "0"+h.toString()+":" : h.toString()+":"))+(m<10 ? "0"+m.toString() : m.toString())+":"+(s<10 ? "0"+s.toString() : s.toString());
		}
		/** Begins subscription to a live stream
		 * @private
		 */
		private function startLiveStream():void {
			resetAllLiveTimers();
			_liveStreamTimer.start();
			fcsubscribe();
			
		}
		/** Calls FCsubscribe on the netconnection
		 * @private
		 */
		private function fcsubscribe():void {
			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.SUBSCRIBE_ATTEMPT));
			_nc.call("FCSubscribe", null, _pendingLiveStreamName);
			_liveFCSubscribeTimer.reset();
			_liveFCSubscribeTimer.start();
		}
		/** Handles the FCSubscribe retry
		 * @private
		 */
		private function retrySubscription(e:TimerEvent):void {
			fcsubscribe();
		}
		/** Handles a non-responsive FCSubscribe method on the server
		 * @private
		 */
		private function liveFCSubscribeTimeout(e:TimerEvent):void {
			resetAllLiveTimers();
			dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,12,"Network failure - unable to play the live stream")); 
		}
		/** Dispatches a progress event
		 * @private
		 */
		private function updateProgress(e:TimerEvent):void {
			dispatchEvent(new AkamaiNotificationEvent(AkamaiNotificationEvent.PROGRESS)); 
		}
		/** Dispatches a failed buffer event when streaming ondemand content
		 * @private
		 */
		private function handleBufferFailure(e:TimerEvent):void {
			if (!_isProgressive && !isLive) {
				dispatchEvent(new AkamaiErrorEvent(AkamaiErrorEvent.ERROR,24,"NetStream buffer has remained empty past timeout threshold")); 
			}
		}
		/** Utility method to reset all timers used in live stream subscription.
		 * @private
		 */
		private function resetAllLiveTimers():void {
			_liveStreamTimer.reset();
			_liveStreamRetryTimer.reset();
			_liveFCSubscribeTimer.reset();
			_bufferFailureTimer.reset();
			
		}
		/** Prepare all the timers that will be used by the class
		 * @private
		 */
		private function initializeTimers():void {
			// Master connection timeout
			_timeOutTimer = new Timer(TIMEOUT, 1);
			_timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
			// Controls the delay between each connection attempt
			_connectionTimer = new Timer(200);
			_connectionTimer.addEventListener(TimerEvent.TIMER, tryToConnect);
			// Master live stream timeout
			_liveStreamTimer = new Timer(_liveStreamMasterTimeout, 1);
			_liveStreamTimer.addEventListener(TimerEvent.TIMER_COMPLETE, liveStreamTimeout);
			// Timeout when waiting for a response from FCSubscribe
			_liveFCSubscribeTimer = new Timer(LIVE_ONFCSUBSCRIBE_TIMEOUT,1);
			_liveFCSubscribeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, liveFCSubscribeTimeout);
			// Retry interval when calling fcsubscribe
			_liveStreamRetryTimer = new Timer(LIVE_RETRY_INTERVAL,1);
			_liveStreamRetryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, retrySubscription);
			// Progress interval
			_progressTimer = new Timer(DEFAULT_PROGRESS_INTERVAL);
			_progressTimer.addEventListener(TimerEvent.TIMER, updateProgress);
			// Buffer failure interval
			_bufferFailureTimer  = new Timer(BUFFER_FAILURE_INTERVAL,1);
			_bufferFailureTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleBufferFailure);
		
		}
		/** Establish the progressive connection
		 * @private
		 */
		private function setUpProgressiveConnection():void {
			_isProgressive = true;
			_nc = new AkamaiNetConnection();
			_onConnectionCreated(_nc);
    		_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR,netSecurityError);
    		_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncError);
    		_nc.connect(null);
    		if (_createStream) {
					setupStream();
				} else {
					handleGoodConnect();
			}
			
		}
		
	}
}