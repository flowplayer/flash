package flexUnitTests
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
	import org.osmf.traits.PlayState;
	
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=4)]
	public class Live_Adaptive_Bitrate_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests Live Adaptive Bitrate Playback by:\n" +
				"1) Loading Stream\n" +
				"2) Playing Stream For 30 Minutes\n" +
				"3) Switching Through Each Bitrate Stream\n" +
				"4) Pausing Stream\n" +
				"5) Resuming Playback of Stream\n" +
				"6) Switching Through Each Bitrate Stream";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 4 );
		}

		public function Live_Adaptive_Bitrate_Playback_Test(resourceURI:String="")
		{
			// Note: NEEDS TO HAPPEN IN CONSTRUCTOR.
			testTimeoutMS = 360000;
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 4 ));
		}
		
		//protected var playTime : Number;
		protected var pauseTime : Number;
		protected var pauseTimer : Timer;
		protected var playbackComplete : Boolean = false;
		protected var havePaused : Boolean = false;
		protected var restartedPlayback : Boolean = false;
		protected var playTimePerStreamChange : Number;
		protected var streamIndexInc : int;
		protected var maxStreamIndex : int;
		protected var switching : Boolean = false;
		
		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			super.timeEventHandler( event );
			
			if ( !( event.type == TimeEvent.CURRENT_TIME_CHANGE ))
				return;
			
			var currentExpectedTime : Number = runTimeSec + ( streamIndexInc * playTimePerStreamChange );
			
			if ( event.time >= runTimeSec && !playbackComplete )
			{
				playbackComplete = true;
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			}
			
			if ( !switching && ( event.time >= currentExpectedTime && streamIndexInc < maxStreamIndex ) )
			{
				trace( "\tswitching!" );
				switching = true;
				mediaPlayer.switchDynamicStreamIndex( ++streamIndexInc );
				trace( "\tstreamIndexInc - " + streamIndexInc );
				trace( "\tmaxStreamIndex - " + maxStreamIndex );
			}
		}
		
		override protected function playEventHandler( event : PlayEvent ) : void
		{
			super.playEventHandler( event );
			
			if ( havePaused && ( event.playState == PlayState.PAUSED ) )
			{
				pauseTimer = new Timer( pauseTime * 1000, 1 );
				pauseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, pauseTimeCompleteHandler, false, 0, true );
				pauseTimer.start();
			}
			
			if ( restartedPlayback && ( event.playState == PlayState.PLAYING ) )
			{
				// Step 5 - Resume Playback complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				switching = true;
				mediaPlayer.switchDynamicStreamIndex( 0 );
			}
		}
		
		override protected function dynamicStreamEventHandler( event : DynamicStreamEvent ) : void
		{
			trace( this );
			super.dynamicStreamEventHandler( event );
			if ( switching && ( event.switching == false ) )
			{
				trace( "\tdone switching!" );
				trace( "\tstreamIndexInc - " + streamIndexInc );
				trace( "\tmaxStreamIndex - " + maxStreamIndex );
				if ( streamIndexInc >= maxStreamIndex )
				{
					if ( !havePaused )
					{
						// Step 3 - Initial bitrate switch complete.
						dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
						havePaused = true;
						pause();
					}
					else
					{
						trace( "\tsuccess!" );
						dispatchEvent( new MediaCaseErrorEvent( "success" ) );
					}
				}
				switching = false;
			}
		}
		
		override public function executeTest() : void
		{
			// Step 1 - Loading complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
			//playTime = 10.0;
			//playTime = 5.0;
			pauseTime = 2.0;
			playTimePerStreamChange = 2.0;
			streamIndexInc = 0;
			maxStreamIndex = mediaPlayer.maxAllowedDynamicStreamIndex;
		}
		
		protected function pauseTimeCompleteHandler( event : TimerEvent ) : void
		{
			// Step 4 - Pause complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			restartedPlayback = true;
			play();
		}
	}
}