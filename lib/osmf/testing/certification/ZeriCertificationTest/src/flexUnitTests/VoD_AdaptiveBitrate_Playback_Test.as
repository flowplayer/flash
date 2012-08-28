package flexUnitTests
{
	import flash.events.Event;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
		
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=2)]
	public class VoD_AdaptiveBitrate_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests VoD Adaptive Bitrate Playback by:\n" +
				"1) Loading Stream\n" +
				"2) Playing Stream\n" +
				"3) Switching Through Each Bitrate Stream";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 2 );
		}

		//protected var playTime : Number;
		protected var playTimePerStreamChange : Number;
		
		protected var playbackComplete : Boolean = false;
		
		protected var streamIndexInc : int;
		protected var maxStreamIndex : int;
		
		protected var switching : Boolean = false;
		
		override public function executeTest():void
		{
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
			//playTime = 10.0;
			playTimePerStreamChange = 5.0;
			streamIndexInc = 0;
			maxStreamIndex = mediaPlayer.maxAllowedDynamicStreamIndex;
		}
		
		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			trace( this );
			super.timeEventHandler( event );
			if ( event.type == TimeEvent.CURRENT_TIME_CHANGE )
			{
				var currentExpectedTime : Number = runTimeSec + ( streamIndexInc * playTimePerStreamChange );
				
				if ( event.time >= runTimeSec && !playbackComplete )
				{
					playbackComplete = true;
					// Step 2 - Playback complete.
					dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
				}
				
				if ( !switching && ( ( event.time >= currentExpectedTime ) && ( streamIndexInc < maxStreamIndex ) ) )
				{
					trace( "\tswitching!" );
					switching = true;
					mediaPlayer.switchDynamicStreamIndex( ++streamIndexInc );
					trace( "\tstreamIndexInc - " + streamIndexInc );
					trace( "\tmaxStreamIndex - " + maxStreamIndex );
				}
			}
		}
		
		override protected function dynamicStreamEventHandler( event : DynamicStreamEvent ) : void
		{
			trace( this );
			super.dynamicStreamEventHandler( event );
			if ( switching && ( event.switching == false ) )
			{
				trace( "\tdone switching!" );
				if ( streamIndexInc >= maxStreamIndex )
				{
					trace( "\tsuccess!" );
					dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.SUCCESS ) );
				}
				trace( "\tstreamIndexInc - " + streamIndexInc );
				trace( "\tmaxStreamIndex - " + maxStreamIndex );
				switching = false;
			}
		}
		
		public function VoD_AdaptiveBitrate_Playback_Test( resourceURI : String = "" )
		{
			// Note: NEEDS TO HAPPEN IN CONSTRUCTOR.
			testTimeoutMS = 360000;
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 2 ));
		}
	}
}