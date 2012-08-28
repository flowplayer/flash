package com.akamai.events
{
	import flash.events.Event;
	
	/**
	 * The AkamaiStatusEvent class provides notification that an object's status has changed.
	 * These objects are characterized by having a common <code>info</code> object which describes that change. 
	 * 
	 * @see com.akamai.AkamaiConnection
	 */
	public class AkamaiStatusEvent extends Event
	{
		/** 
		 * The AkamaiStatusEvent.NETSTREAM constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, which indicates that NetStream has changed status.
		 */
  			public static const NETSTREAM:String = "netstream";
  		/** 
		 * The AkamaiStatusEvent.NETCONNECTION constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, which indicates that NetConnection has changed status.
		 */
  			public static const NETCONNECTION:String = "netconnection";
  		/** 
		 * The AkamaiStatusEvent.NETSTREAM_PLAYSTATUS constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when a NetStream object has completely played a stream,
		 * or when it switches to a different stream in a server-side playlist.
		 * This handler returns information objects that provide information in addition to what's returned
		 * by the netStatus event. You can use this handler to trigger actions in your code when a NetStream
		 * object has switched from one stream to another stream in a playlist (as indicated by the information
		 * object NetStream.Play.Switch) or when a NetStream object has played to the end (as indicated by the
		 * information object NetStream.Play.Complete). 
		 */
  			public static const NETSTREAM_PLAYSTATUS:String = "playstatus";
  		/** 
		 * The AkamaiStatusEvent.NETSTREAM_METADATA constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when the AkamaiConnection class receives descriptive
		 * information embedded in the FLV file being played. This event is triggered after a call to
		 * the <code>NetStream.play()</code> method, but before the video playhead has advanced.
		 * In many cases, the duration value embedded in FLV metadata approximates the actual duration,
		 * but is not exact. In other words, it does not always match the value of the NetStream.time property
		 * when the playhead is at the end of the video stream. 
		 */
  			public static const NETSTREAM_METADATA:String = "metadata";
  		/** 
		 * The AkamaiStatusEvent.NETSTREAM_IMAGEDATA constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when the AkamaiConnection class receives an image embedded
		 * in the H.264 file being played. The onImageData method is a callback like
		 * onMetaData that sends image data as a byte array through an AMF0 data channel. The image data
		 * can be in JPEG, PNG, or GIF formats. As the information is a byte array, this functionality is
		 * only supported for ActionScript 3.0 client SWFs. The <code>info</code> property of the event will
		 * hold the image data object and the imageData.data object holds the actual byte array.
		 */
  			public static const NETSTREAM_IMAGEDATA:String = "imagedata";
  		/** 
		 * The AkamaiStatusEvent.NETSTREAM_TEXTDATA constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when the AkamaiConnection class receives text data embedded
		 * in the H.264 file being played. The onTextData method is a callback like onMetaData that sends text
		 * data through an AMF0 data channel. The text data is always in UTF-8 format and can contain additional
		 * information about formatting based on the 3GP timed text specification. This functionality is fully
		 * supported in ActionScript 2.0 and 3.0 because it does not use a byte array.The <code>info</code> property of the event will
		 * hold the text data object and the textData.text object holds the actual text.
		 */
  			public static const NETSTREAM_TEXTDATA:String = "textdata";
  		/** 
		 * The AkamaiStatusEvent.NETSTREAM_CUEPOINT constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when an embedded cue point is reached while playing an FLV file.
		 * You can use this handler to trigger actions in your code when the video reaches a specific cue point,
		 * which lets you synchronize other actions in your application with video playback events. 
		 * The following types of cue points can be embedded in an FLV file:
		 * <ul><li>A navigation cue point specifies a keyframe within the FLV file, and the cue point's time
		 * property corresponds to that exact keyframe. Navigation cue points are often used as bookmarks or entry
		 * points to let users navigate through the video file. </li>
		 * <li>An event cue point is specified by time, whether or not that time corresponds to a specific keyframe.
		 * An event cue point usually represents a time in the video when something happens that could be used to
		 * trigger other application events.</li></ul>.
		 */
  			public static const NETSTREAM_CUEPOINT:String = "cuepoint";
  			
  		/** 
		 * The AkamaiStatusEvent.MP3_ID3 constant defines the value of an AkamaiStatusEvent's
		 * <code>type</code> property, dispatched when the the class receives information about
		 * ID3 data embedded in an MP3 file. To trigger this event, first make a request to the
		 * <code>getMp3Id3Info</code> method.
		 * 
		 * @see com.akamai.AkamaiConnection#getMp3Id3Info
		 */
  			public static const MP3_ID3:String = "id3";
  		/** 
		 * @private
		 * Used internally by the AkamaiConenciton and AkamaiNetConnection classes.
		 */
  			public static const FCSUBSCRIBE:String = "fcsubscribe";
  		/** 
		 * @private
		 * Used internally by the AkamaiConenciton and AkamaiNetConnection classes.
		 */
  			public static const FCUNSUBSCRIBE:String = "fcunsubscribe";
  			
  		
		// Define public variables
		/**
		 * An object with properties that describe the object's status or error condition. 
		 * This object is a direct proxy of the standard <code>netStatus</code>, <code>onMetaData</code>
		 * <code>onCuePoint</code> info objects returned by native NetStream and NetConnection events, so view
		 * the relevant system documentation for details of what each <code>info</code> object contains. 
		 */ 

            public var info:Object;
            
		/**
		 * Constructor. Normally called by the AkamaiConnection class, not used in application code.
		 * 
		 * @param type The event type; indicates the action that caused the event.
		 * @param info An object specifying the status condition.
		 */
            public function AkamaiStatusEvent(type:String, info:Object)             {
                // Call the constructor of the superclass.
                super(type);
                // Set the new properties.
                this.info = info;
             
   			}

        	/** 
            * @private 
            * Override the inherited clone() method.
            */
        	override public function clone():Event {
            	return new AkamaiStatusEvent(type, info);
        	}

	}
}