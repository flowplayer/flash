package flexUnitTests
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.StreamType;
	import org.osmf.traits.PlayState;
	
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=6)]
	public class LiveDVR_Adaptive_Bitrate_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests Live+DVR Adaptive Bitrate Playback by:\n" +
				"1) Loading Stream\n" +
				"2) Playing Stream For 30 Minutes\n" +
				"3) Seek to Beginning of Stream\n" +
				"4) Switching Through Each Bitrate Stream\n" +
				"5) Seek to Middle of Stream\n" +
				"6) Switching Through Each Bitrate Stream\n" +
				"7) Seek back to Live Stream" +
				"8) Switching Through Each Bitrate Stream\n";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 6 );
		}
		
		protected var haveSeekedStart : Boolean = false;
		protected var haveSeekedMidpoint : Boolean = false;
		protected var haveSeekedToLive : Boolean = false;
		protected var streamIndexInc : int;
		protected var maxStreamIndex : int;
		protected var switching : Boolean = false;
		
		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			//super.timeEventHandler( event );
			
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
		
		override protected function dynamicStreamEventHandler( event : DynamicStreamEvent ) : void
		{
			super.dynamicStreamEventHandler( event );
			trace( "duration - " + mediaPlayer.duration );
			if ( switching && !event.switching )
			{
				if ( streamIndexInc < maxStreamIndex - 1 )
				{
					setDynamicStreamIndex( ++streamIndexInc );
				}
				else
				{
					switching = false;
					if ( !haveSeekedMidpoint )
					{
						// Step 4 - First Switched bitrates complete.
						dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
						trace( "seeked to beginning!" );
						trace( "mediaPlayer.currentTime - " + mediaPlayer.currentTime );
						var seekToMidpoint : Number = mediaPlayer.duration / 2;
						haveSeekedMidpoint = true;
						seek( seekToMidpoint );
					}
					else if ( !haveSeekedToLive )
					{
						// Step 6 - Second Switched bitrates complete.
						dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
						trace( "seeked back to live!" );
						trace( "mediaPlayer.currentTime - " + mediaPlayer.currentTime );
						haveSeekedToLive = true;
						seek( mediaPlayer.duration );
					}
					else if ( haveSeekedStart && haveSeekedMidpoint && haveSeekedToLive )
					{
						//TODO: ****** Actual test success! 
						trace( "Success!!" );
						dispatchEvent( new MediaCaseErrorEvent( "success" ) );
					}
				}
			}
		}
		
		override public function executeTest() : void
		{
			// Step 1 - Loading complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
			streamIndexInc = 0;
			maxStreamIndex = mediaPlayer.maxAllowedDynamicStreamIndex;
		}
		
		override protected function mediaPlayerStateChangedHandler( event : MediaPlayerStateChangeEvent ) : void
		{
			super.mediaPlayerStateChangedHandler( event );
			
			if ( !haveSeekedStart || switching )
				return;
			
			if ( !haveSeekedMidpoint && ( event.state == MediaPlayerState.PLAYING ) )
			{
				// Step 3 - Have seeked to beginning complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				switching = true;
				setDynamicStreamIndex( ++streamIndexInc );
			}
			else if ( !haveSeekedToLive && ( event.state == MediaPlayerState.PLAYING ) )
			{
				// Step 5 - Have seeked to midpoint complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				streamIndexInc = 0;
				switching = true;
				setDynamicStreamIndex( streamIndexInc );
			}
			else if ( haveSeekedToLive && ( event.state == MediaPlayerState.PLAYING ) )
			{
				// Step 7 - Have seeked to live complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				streamIndexInc = 0;
				switching = true;
				// (cannot keep playing once set to duration end unless stream is live)
				//dispatchEvent( new MediaCaseErrorEvent( "success" ) );
				setDynamicStreamIndex( streamIndexInc );
			}
		}

		public function LiveDVR_Adaptive_Bitrate_Playback_Test(resourceURI:String="")
		{
			// Note: NEEDS TO HAPPEN IN CONSTRUCTOR.
			streamType = StreamType.DVR;
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 6 ));
		}
	}
}