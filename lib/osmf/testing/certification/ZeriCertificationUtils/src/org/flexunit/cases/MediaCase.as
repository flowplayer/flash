package org.flexunit.cases
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.interfaces.IMediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.MediaRunner;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	
	/**
	 * <code>MediaCaseErrorEvent</code> dispatched to indicate the test has succeeded.  Meant to be implemented by
	 * subclasses for case-specific success criteria. 
	 * 
	 * @see org.flexunit.events.MediaCaseErrorEvent
	 */	
	[Event(name="success", type="org.flexunit.events.MediaCaseErrorEvent")]
	
	/**
	 * <code>MediaCaseErrorEvent</code> dispatched to indicate the test has failed.  Any associated
	 * failure information (errors thrown, trigger events, real-language messages, will
	 * and should likewise be included with the event.  Can be used in subclasses
	 * to create custom failure criteria/error handling.
	 * 
	 * @see org.flexunit.events.MediaCaseErrorEvent
	 */	
	[Event(name="failure", type="org.flexunit.events.MediaCaseErrorEvent")]
	
	/**
	 * <code>MediaCaseErrorEvent</code> dispatched to indicate the test has timed out.  Meant to be used with
	 * the <code>testTimeoutMS</code> property.
	 * 
	 * @see #testTimeoutMS
	 * @see org.flexunit.events.MediaCaseErrorEvent
	 */	
	[Event(name="timeout", type="org.flexunit.events.MediaCaseErrorEvent")]
	
	/**
	 * <code>Event</code> dispatched to indicate the test has successfully loaded.
	 * 
	 * @see #load()
	 */	
	[Event(name="elementLoaded", type="flash.events.Event")]
	
	/**
	 * <code>Event</code> dispatched to indicate the test has successfully unloaded.
	 * 
	 * @see #unload()
	 */	
	[Event(name="elementUnloaded", type="flash.events.Event")]
	
	/**
	 * <code>Event</code> dispatched to indicate the test has successfully started playing.
	 * 
	 * @see #play()
	 */
	[Event(name="elementPlaying", type="flash.events.Event")]
	
	/**
	 * <code>Event</code> dispatched to indicate the test has successfully stopped.
	 * 
	 * @see #stop()
	 */
	[Event(name="elementStopped", type="flash.events.Event")]
	
	/**
	 * <p>The <code>MediaCase</code> class is the base class for all custom media case tests, implementing the <code>IMediaCase</code> 
	 * interface and dispatching the appropriate custom events to provide feedback to the <code>MediaRunner</code>.  It is meant
	 * to be subclassed for particular test scenarios.</p>
	 * 
	 * <p><b>Subclasses should:</b></p>
	 * <ul>
	 * <li>Call parent methods that wrap interactions with media element and media player where possible</li>
	 * <li>Override existant event listeners rather than add their own (since <code>MediaCase</code>'s event
	 * listeners are indirectly called and wrapped by a <code>try</code>/<code>catch</code> block).</li>
	 * </ul>
	 * 
	 * <p>This class wraps all direct interactions to the media player and media element, as well as providing try/catch wrappers
	 * everywhere possible in order to ensure no errors are thrown that won't be captured by the test runner.</p> 
	 * 
	 * @author cpillsbury
	 * 
	 */	
	public class MediaCase extends EventDispatcher implements IMediaCase
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		// TODO: MediaTestsClasses file to include (so don't need things like "importVar,", below).
		/**
		 * @private
		 * Variable to force an import of the MediaRunner. 
		 */		
		private var importVar : MediaRunner;
		
		/**
		 * @private
		 * internal flag to ensure that multiple failures in a single frame don't bubble up to the runner. 
		 */		
		protected var haveFailed : Boolean = false;
		
		//------------------------------------------------------------------------
		//
		//  Properties: IMediaCase
		//
		//------------------------------------------------------------------------

		//----------------------------------
		//  runTimeSec
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the runTimeSec property.
		 */	
		protected var _runTimeSec : Number;
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#runTimeSec
		 */	
		public function get runTimeSec() : Number
		{
			return _runTimeSec;
		}
		
		public function set runTimeSec( value : Number ) : void
		{
			if ( value == _runTimeSec )
				return;
			
			_runTimeSec = value;
		}
		
		//----------------------------------
		//  description
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the description property.
		 */	
		protected var _description : String;
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#description
		 */	
		public function get description() : String
		{
			return _description;
		}
		
		public function set description( value : String ) : void
		{
			if ( value == _description )
				return;
			
			_description = value;
		}
		
		//----------------------------------
		//  resourceURI
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the resourceURI property.
		 */
		protected var _resourceURI : String;
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#resourceURI
		 */	
		public function get resourceURI() : String
		{
			return _resourceURI;
		}
		
		public function set resourceURI( value : String ) : void
		{
			if ( value == _resourceURI )
				return;
			
			_resourceURI = value;
		}
		
		//----------------------------------
		//  streamType
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the streamType property.
		 */	
		protected var _streamType : String = StreamType.LIVE_OR_RECORDED;
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#streamType
		 * 
		 * @default StreamType.LIVE_OR_RECORDED
		 */		
		public function get streamType() : String
		{
			return _streamType;
		}
		
		public function set streamType( value : String ) : void
		{
			if ( value == _streamType )
				return;
			
			_streamType = value;
		}
		
		//----------------------------------
		//  testTimeoutMS
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the testTimeoutMS property.
		 */	
		protected var _testTimeoutMS : int = 1800000 + 360000;
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#testTimeoutMS
		 * 
		 * @default 180000
		 */	
		public function get testTimeoutMS() : int
		{
			return _testTimeoutMS;
		}
		
		public function set testTimeoutMS( value : int ) : void
		{
			if ( value == _testTimeoutMS )
				return;
			
			_testTimeoutMS = value;
		}
		
		//------------------------------------------------------------------------
		//
		//  Properties: Media Classes
		//
		//------------------------------------------------------------------------

		//----------------------------------
		//  mediaElement
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the mediaElement property.
		 */	
		protected var _mediaElement : MediaElement;
		
		/**
		 * The mediaElement used for a test scenario.
		 */		
		public function get mediaElement() : MediaElement
		{
			return _mediaElement;
		}
		
		//----------------------------------
		//  mediaFactory
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the mediaFactory property.
		 */	
		protected var _mediaFactory : MediaFactory;
		
		/**
		 * The mediaFactory used for a test scenario.
		 */	
		protected function get mediaFactory() : MediaFactory
		{
			if ( !_mediaFactory )
			{
				_mediaFactory = new DefaultMediaFactory();
				trace( "MediaCase:: get mediaFactory" );
				trace( "\tcreated new mediaFactory" );
			}
			
			return _mediaFactory;
		}
		
		//----------------------------------
		//  mediaPlayer
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the mediaPlayer property.
		 */
		protected var _mediaPlayer : MediaPlayer;
		
		/**
		 * The mediaPlayer used for a test scenario.
		 */	
		protected function get mediaPlayer() : MediaPlayer
		{
			if ( !_mediaPlayer )
			{
				_mediaPlayer = new MediaPlayer();
				trace( "MediaCase:: get mediaPlayer" );
				trace( "\tcreated new mediaPlayer" );
			}
			
			return _mediaPlayer;
		}
		
		//----------------------------------
		//  resource
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the resource property.
		 */
		protected var _resource : StreamingURLResource;
		
		/**
		 * The resource used for a test scenario.
		 */	
		protected function get resource() : StreamingURLResource
		{
			return _resource;
		}
		
		/**
		 * A 0-indexed value defining the total number of streams in a dynamic (adaptive bitrate) stream asset.
		 * 
		 * @see #maxAllowedDynamicStreamIndex
		 * @see #setDynamicStreamIndex()
		 */		
		public function get maxAllowedDynamicStreamIndex() : int
		{
			if ( !mediaPlayer || !mediaPlayer.isDynamicStream )
				return -1;
			
			var maxIndex : int = mediaPlayer.maxAllowedDynamicStreamIndex;
			trace( "MediaCase::get maxAllowedDynamicStreamIndex - " + maxIndex );
			return maxIndex;
		}
		
		/**
		 * A 0-indexed value defining the current stream number in a dynamic (adaptive bitrate) stream asset.
		 * 
		 * @see #maxAllowedDynamicStreamIndex
		 * @see #setDynamicStreamIndex()
		 */	
		public function get currentDynamicStreamIndex() : int
		{
			if ( !mediaPlayer || !mediaPlayer.isDynamicStream )
				return -1;
			
			var currentIndex : int = mediaPlayer.currentDynamicStreamIndex;
			trace( "MediaCase::get currentDynamicStreamIndex - " + currentIndex );
			return currentIndex;
		}
		
		//------------------------------------------------------------------------
		//
		//  Methods: IMediaCase
		//
		//------------------------------------------------------------------------
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#createResource()
		 */	
		public function createResource() : void
		{
			trace( "MediaCase::createResource()" );
			if ( !_resourceURI )
			{
				throw new Error( "No resource URI set." );
				return;
			}
			
			_resource = new StreamingURLResource( _resourceURI, _streamType );
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#createMediaElement()
		 */			
		public function createMediaElement() : void
		{
			trace( "MediaCase::createMediaElement()" );
			if ( !resource )
			{
				throw new Error( "Resource has not been created." );
				return;
			}
			if ( !mediaFactory )
			{
				throw new Error( "No MediaFactory created." );
				return;
			}
			_mediaElement = mediaFactory.createMediaElement( resource );
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#applyMediaElement()
		 */	
		public function applyMediaElement() : void
		{
			if ( !mediaElement )
			{
				throw new Error( "MediaElement has not been created." );
				return;
			}
			if ( !mediaPlayer )
			{
				throw new Error( "No MediaPlayer created." );
				return;
			}
			
			addMediaPlayerCapabilitiesListeners( mediaPlayer );
			addMediaPlayerTraitListeners( mediaPlayer );
			mediaPlayer.autoPlay = false;
			mediaPlayer.autoDynamicStreamSwitch = false;
			mediaPlayer.muted = true;
			mediaPlayer.media = mediaElement;
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#load()
		 */	
		public function load() : void
		{
			if ( !mediaPlayer || !mediaPlayer.canLoad )
			{
				throw new Error( "MediaPlayer cannot load media element." );
				return;
			}
			
			var loadTrait : LoadTrait = mediaElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
			loadTrait.addEventListener( LoaderEvent.LOAD_STATE_CHANGE, tryCatchElementLoadedHandler, false, 0 , true );
			loadTrait.load();
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#unload()
		 */	
		public function unload() : void
		{
			if ( !mediaPlayer || !mediaPlayer.media )
			{
				throw new Error( "MediaPlayer cannot unload media element." );
				return;
			}
			
			var loadTrait : LoadTrait = mediaElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
			loadTrait.addEventListener( LoaderEvent.LOAD_STATE_CHANGE, tryCatchElementUnloadedHandler, false, 0 , true );
			loadTrait.unload();
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#play()
		 */	
		public function play() : void
		{
			if ( !mediaPlayer || !mediaPlayer.canPlay )
			{
				throw new Error( "MediaPlayer cannot play media element." );
				return;
			}
			
			mediaPlayer.play();
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#seek()
		 */	
		public function seek( time : Number ) : void
		{
			if ( !mediaPlayer )
			{
				throw new Error( "MediaPlayer cannot seek on media element." );
				return;
			}
			
			mediaPlayer.seek( time );
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#stop()
		 */	
		public function stop() : void
		{
			if ( !mediaPlayer )
			{
				throw new Error( "MediaPlayer cannot stop media element." );
				return;
			}
			
			mediaPlayer.stop();
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#pause()
		 */	
		public function pause() : void
		{
			if ( !mediaPlayer || !mediaPlayer.canPause )
			{
				throw new Error( "MediaPlayer cannot play media element." );
				return;
			}
			
			mediaPlayer.pause();
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#executeTest()
		 */	
		public function executeTest() : void
		{
		}
		
		/**
		 * @copy org.flexunit.cases.interfaces.IMediaCase#uninitializeCase()
		 */	
		public function uninitializeCase() : void
		{
			removeMediaPlayerCapabilitiesListeners( mediaPlayer );
			removeMediaPlayerTraitListeners( mediaPlayer );
			_mediaPlayer = null;
			_mediaElement = null;
			_mediaFactory = null;
		}
		
		//------------------------------------------------------------------------
		//
		//  Methods
		//
		//------------------------------------------------------------------------
		
		/**
		 * Sets the dynamic stream index for a stream asset with adaptive bitrates.
		 * @param index the desired index to select.
		 * @return <code>true</code> if successfully applies index switch, otherwise <code>false</code>
		 */		
		public function setDynamicStreamIndex( index : int ) : Boolean
		{
			// TODO: Add error throwing or event dispatching on else cases.
			trace( "MediaCase::setDynamicStreamIndex(" + index + " )" );
			if ( mediaPlayer && mediaPlayer.isDynamicStream && !mediaPlayer.autoDynamicStreamSwitch && !mediaPlayer.dynamicStreamSwitching )
			{
				if ( index < mediaPlayer.maxAllowedDynamicStreamIndex )
				{
					trace( "\tactually switching up." );
					mediaPlayer.switchDynamicStreamIndex( index );
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @private
		 * Adds all trait-specific event listeners, as well as the <code>MediaErrorEvent.MEDIA_ERROR</code>,
		 * which is predominantly fired when a trait interaction fails, either directly or indirectly.
		 * @param mediaPlayer A <code>MediaPlayer</code> instance.  Standard use case passes the <code>mediaPlayer</code> object.
		 * 
		 */		
		protected function addMediaPlayerTraitListeners( mediaPlayer : MediaPlayer ) : void
		{
			mediaPlayer.addEventListener( TimeEvent.COMPLETE, tryCatchTimeEventHandler, false, 0, true );
			mediaPlayer.addEventListener( TimeEvent.CURRENT_TIME_CHANGE, tryCatchTimeEventHandler, false, 0, true );
			mediaPlayer.addEventListener( TimeEvent.DURATION_CHANGE, tryCatchTimeEventHandler, false, 0, true );
			mediaPlayer.addEventListener( PlayEvent.CAN_PAUSE_CHANGE, tryCatchPlayEventHandler, false, 0, true );
			mediaPlayer.addEventListener( PlayEvent.PLAY_STATE_CHANGE, tryCatchPlayEventHandler, false, 0, true );
			mediaPlayer.addEventListener( DynamicStreamEvent.SWITCHING_CHANGE, tryCatchDynamicStreamEventHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaErrorEvent.MEDIA_ERROR, tryCatchMediaErrorEventHandler, false, 0, true );
		}
		
		/**
		 * @private
		 * Adds all capability-specific event listeners.
		 * @param mediaPlayer A <code>MediaPlayer</code> instance.  Standard use case passes the <code>mediaPlayer</code> object.
		 * 
		 */	
		protected function addMediaPlayerCapabilitiesListeners( mediaPlayer : MediaPlayer ) : void
		{
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler, false, 0, true );
			mediaPlayer.addEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, tryCatchMediaPlayerStateChangedHandler, false, 0, true );
		}
		
		/**
		 * @private
		 * Removes all trait-specific event listeners, as well as the <code>MediaErrorEvent.MEDIA_ERROR</code>,
		 * which is predominantly fired when a trait interaction fails, either directly or indirectly.
		 * @param mediaPlayer A <code>MediaPlayer</code> instance.  Standard use case passes the <code>mediaPlayer</code> object.
		 * 
		 */	
		protected function removeMediaPlayerTraitListeners( mediaPlayer : MediaPlayer ) : void
		{
			mediaPlayer.removeEventListener( TimeEvent.COMPLETE, tryCatchTimeEventHandler );
			mediaPlayer.removeEventListener( TimeEvent.CURRENT_TIME_CHANGE, tryCatchTimeEventHandler );
			mediaPlayer.removeEventListener( TimeEvent.DURATION_CHANGE, tryCatchTimeEventHandler );
			mediaPlayer.removeEventListener( PlayEvent.CAN_PAUSE_CHANGE, tryCatchPlayEventHandler );
			mediaPlayer.removeEventListener( PlayEvent.PLAY_STATE_CHANGE, tryCatchPlayEventHandler );
			mediaPlayer.removeEventListener( DynamicStreamEvent.SWITCHING_CHANGE, tryCatchDynamicStreamEventHandler );
		}
		
		/**
		 * @private
		 * Removes all capability-specific event listeners.
		 * @param mediaPlayer A <code>MediaPlayer</code> instance.  Standard use case passes the <code>mediaPlayer</code> object.
		 * 
		 */	
		protected function removeMediaPlayerCapabilitiesListeners( mediaPlayer : MediaPlayer ) : void
		{
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE, tryCatchMediaPlayerCapabilityChangedHandler );
			mediaPlayer.removeEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, tryCatchMediaPlayerStateChangedHandler );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers: MediaPlayer
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for all capability change event.
		 */		
		private function tryCatchMediaPlayerStateChangedHandler( event : MediaPlayerStateChangeEvent ) : void
		{
			try
			{
				mediaPlayerStateChangedHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function mediaPlayerStateChangedHandler( event : MediaPlayerStateChangeEvent ) : void
		{
			trace( "MediaCase::mediaPlayerStateChangedHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\tstate - " + event.state );
			// Re-dispatch any MediaPlayerCapabilityChangeEvents
			dispatchEvent( event.clone() as MediaPlayerStateChangeEvent );
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for all capability change event.
		 */		
		private function tryCatchMediaPlayerCapabilityChangedHandler( event : MediaPlayerCapabilityChangeEvent ) : void
		{
			try
			{
				mediaPlayerCapabilityChangedHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function mediaPlayerCapabilityChangedHandler( event : MediaPlayerCapabilityChangeEvent ) : void
		{
			trace( "MediaCase::mediaPlayerCapabilityChangedHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\tenabled - " + event.enabled );
			// Re-dispatch any MediaPlayerCapabilityChangeEvents
			dispatchEvent( event.clone() as MediaPlayerCapabilityChangeEvent );
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for all play trait events.
		 */
		private function tryCatchPlayEventHandler( event : PlayEvent ) : void
		{
			try
			{
				playEventHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function playEventHandler( event : PlayEvent ) : void
		{
			trace( "MediaCase::playEventHandler( " + event + " )" );
			trace( "\tplayState - " + event.playState );
			switch ( event.playState )
			{
				case ( PlayState.PLAYING ) :
				{
					dispatchEvent( new Event( "elementPlaying" ) );
					break;
				}
				case ( PlayState.STOPPED ) :
				{
					dispatchEvent( new Event( "elementStopped" ) );
					break;
				}
			}
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for all time trait events.
		 */
		private function tryCatchTimeEventHandler( event : TimeEvent ) : void
		{
			try
			{
				timeEventHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			trace( "MediaCase::timeEventHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\ttime - " + event.time );
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for all dynamic stream events.
		 */
		private function tryCatchDynamicStreamEventHandler( event : DynamicStreamEvent ) : void
		{
			try
			{
				dynamicStreamEventHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function dynamicStreamEventHandler( event : DynamicStreamEvent ) : void
		{
			trace( "MediaCase::dynamicStreamEventHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\tautoSwitch - " + event.autoSwitch );
			trace( "\tswitching - " + event.switching );
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for load trait events when attempting to load a media element.
		 * @see #load()
		 */
		private function tryCatchElementLoadedHandler( event : LoadEvent ) : void
		{
			try
			{
				elementLoadedHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function elementLoadedHandler( event : LoadEvent ) : void
		{
			trace( "MediaCase::elementLoadedHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\tloadState - " + event.loadState );
			switch ( event.loadState )
			{
				case ( LoadState.READY ) :
				{
					var loadTrait : LoadTrait = mediaElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
					loadTrait.removeEventListener( LoaderEvent.LOAD_STATE_CHANGE, tryCatchElementLoadedHandler );
					dispatchEvent( new Event( "elementLoaded" ) );
					break;
				}
				case ( LoadState.LOAD_ERROR ) :
				{
					dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, LoadState.LOAD_ERROR, 0, null, event.clone() );
					break;
				}
			}
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler for load trait events when attempting to unload a media element.
		 * @see #unload()
		 */
		private function tryCatchElementUnloadedHandler( event : LoadEvent ) : void
		{
			try
			{
				elementUnloadedHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function elementUnloadedHandler( event : LoadEvent ) : void
		{
			trace( "MediaCase::elementUnloadedHandler( " + event + " )" );
			trace( "\t" + this );
			trace( "\tloadState - " + event.loadState );
			switch ( event.loadState )
			{
				case ( LoadState.UNINITIALIZED ) :
				//case ( LoadState.UNLOADING ) :
				{
					var loadTrait : LoadTrait = mediaElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
					loadTrait.removeEventListener( LoaderEvent.LOAD_STATE_CHANGE, tryCatchElementUnloadedHandler );
					dispatchEvent( new Event( "elementUnloaded" ) );
					break;
				}
				case ( LoadState.LOAD_ERROR ) :
				{
					dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, LoadState.LOAD_ERROR, 0, null, event.clone() );
					break;
				}
			}
		}
		
		/**
		 * @private
		 * <code>try</code>/<code>catch</code> wrapper event handler media error events.
		 */
		private function tryCatchMediaErrorEventHandler( event : MediaErrorEvent ) : void
		{
			try
			{
				mediaErrorEventHandler( event );
			}
			catch ( error : Error )
			{
				dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, error, event.clone() );
			}
		}
		
		protected function mediaErrorEventHandler( event : MediaErrorEvent ) : void
		{
			dispatchMediaCaseError( MediaCaseErrorEvent.FAILURE, false, false, "", 0, event.error, event.clone() );
		}
		
		/**
		 * @private
		 * Convenience method for dispatching <code>MediaCaseErrorEvent</code>'s.
		 */
		protected function dispatchMediaCaseError( type : String, bubbles : Boolean = false, cancelable : Boolean = false,
												   text : String = "", id : int = 0, error : Error = null, 
												   triggerEvent : Event = null ) : Boolean
		{
			if ( type == MediaCaseErrorEvent.FAILURE )
			{
				if ( haveFailed )
				{
					trace( "**** already failed!!!" );
					return false;
				}
				haveFailed = true;
			}
			var event : MediaCaseErrorEvent = new MediaCaseErrorEvent( type, bubbles, cancelable, text, id, error, triggerEvent );
			return dispatchEvent( event );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * @param resourceURI optional initialization value of the <code>resourceURI</code> property.  Used for parameterized testing.
		 * @param runTimeSec optional initialization value of the <code>runTimeSec</code> property.  Used for parameterized testing.
		 * 
		 * @see org.flexunit.runners.ParameterizedMediaRunner 
		 * 
		 */
		public function MediaCase( resourceURI : String = "", runTimeSec : Number = NaN )
		{
			trace( "MediaCase::MediaCase( " + resourceURI + " )" );
			trace( "\t" + this );
			if ( resourceURI )
				this._resourceURI = resourceURI;
			
			if ( runTimeSec )
				this._runTimeSec = runTimeSec;
		}
	}
}