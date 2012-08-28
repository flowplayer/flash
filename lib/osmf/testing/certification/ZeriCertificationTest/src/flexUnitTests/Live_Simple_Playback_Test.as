package flexUnitTests
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
	import org.osmf.traits.PlayState;
	
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=3)]
	public class Live_Simple_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests Live Playback by:\n" +
				"1) Loading Stream\n" +
				"2) Playing Stream For 30 Minutes\n" +
				"3) Pausing Stream\n" +
				"4) Resuming Playback of Stream";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 3 );
		}

		public function Live_Simple_Playback_Test(resourceURI:String="")
		{
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 3 ));
		}
		
		//protected var playTime : Number;
		protected var pauseTime : Number;
		protected var pauseTimer : Timer;
		protected var havePaused : Boolean = false;
		protected var restartedPlayback : Boolean = false;
		
		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			super.timeEventHandler( event );
			
			if ( !( event.type == TimeEvent.CURRENT_TIME_CHANGE ))
				return;
			
			if ( !havePaused && ( event.time >= runTimeSec ) )
			{
				// Step 2 - Playback complete.
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				havePaused = true;
				pause();
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
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.SUCCESS ) );
			}
		}
		
		override public function executeTest() : void
		{
			// Step 1 - Loading complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
			//playTime = 10.0;
			//pauseTime = 5.0;
			//playTime = 5.0;
			pauseTime = 2.0;
		}
		
		protected function pauseTimeCompleteHandler( event : TimerEvent ) : void
		{
			// Step 3 - Pause complete.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			restartedPlayback = true;
			play();
		}
	}
}