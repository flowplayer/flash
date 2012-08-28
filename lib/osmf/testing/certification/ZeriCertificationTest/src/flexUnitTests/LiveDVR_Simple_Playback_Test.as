package flexUnitTests
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.StreamType;
	import org.osmf.traits.PlayState;
	
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=5)]
	public class LiveDVR_Simple_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests Live+DVR Playback by:\n" +
				"1) Loading Stream\n" +
				"2) Playing Stream For 30 Minutes\n" +
				"3) Seek to Beginning of Stream\n" +
				"4) Seek to Middle of Stream\n" +
				"5) Seek back to Live Stream";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 5 );
		}
		
		protected var haveSeekedStart : Boolean = false;
		protected var haveSeekedMidpoint : Boolean = false;
		protected var haveSeekedToLive : Boolean = false;
		
		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			super.timeEventHandler( event );
			
			if ( !( event.type == TimeEvent.CURRENT_TIME_CHANGE ))
				return;
			
			if ( !haveSeekedStart && ( event.time >= runTimeSec ) )
			{
				// Step 2 - Playback complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				haveSeekedStart = true;
				seek( 0 );
			}
		}
		
		override protected function mediaPlayerStateChangedHandler( event : MediaPlayerStateChangeEvent ) : void
		{
			super.mediaPlayerStateChangedHandler( event );
			
			if ( !haveSeekedStart )
				return;
			
			if ( !haveSeekedMidpoint && ( event.state == MediaPlayerState.PLAYING ) )
			{
				// Step 3 - Have seeked to beginning complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				trace( "seeked to beginning!" );
				trace( "mediaPlayer.currentTime - " + mediaPlayer.currentTime );
				var seekToMidpoint : Number = mediaPlayer.duration / 2;
				haveSeekedMidpoint = true;
				seek( seekToMidpoint );
			}
			else if ( !haveSeekedToLive && ( event.state == MediaPlayerState.PLAYING ) )
			{
				// Step 4 - Have seeked to midpoint complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				trace( "seeked back to live!" );
				trace( "mediaPlayer.currentTime - " + mediaPlayer.currentTime );
				haveSeekedToLive = true;
				seek( mediaPlayer.duration );
			}
			else if ( haveSeekedStart && haveSeekedMidpoint && haveSeekedToLive && ( event.state == MediaPlayerState.PLAYING ) )
			{
				dispatchEvent( new MediaCaseErrorEvent( "success" ) );
			}
		}
		
		override public function executeTest() : void
		{
			// Step 1 - Loading complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
		}
		
		public function LiveDVR_Simple_Playback_Test( resourceURI : String = "" )
		{
			// Note: NEEDS TO HAPPEN IN CONSTRUCTOR.
			streamType = StreamType.DVR;
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 5 ));
		}
	}
}