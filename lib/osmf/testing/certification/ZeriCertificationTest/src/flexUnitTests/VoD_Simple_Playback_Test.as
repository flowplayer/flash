package flexUnitTests
{
	import flash.events.Event;
	
	import org.flexunit.cases.MediaCase;
	import org.flexunit.events.MediaCaseErrorEvent;
	import org.flexunit.runners.ParameterizedMediaRunner;
	import org.osmf.events.TimeEvent;
	import org.osmf.managers.ResourceURLDataManager;
	
	[RunWith("org.flexunit.runners.ParameterizedMediaRunner")]
	[TestCase(order=1)]
	public class VoD_Simple_Playback_Test extends MediaCase
	{
		private var pr : ParameterizedMediaRunner;
		
		[Description]
		public static function getDescription() : String
		{
			return	"Tests VoD Playback by:\n" +
					"1) Loading Stream\n" +
					"2) Playing Stream";
		}
		
		[Parameters]
		public static function data():Array {
			//need to deal with this circumstance better -> throw new Error("Blah");
			return ResourceURLDataManager.getURIsForTestNumber( 1 );
		}

		//protected var playTime : Number;

		override protected function timeEventHandler( event : TimeEvent ) : void
		{
			// TODO: Make separate handlers for CURRENT_TIME_CHANGE events and DURATION_CHANGE events to reduce handler
			// calls.
			super.timeEventHandler( event );
			if ( ( event.type == TimeEvent.CURRENT_TIME_CHANGE ) && ( event.time >= runTimeSec ) )
			{
				dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.SUCCESS ) );
			}
		}
		
		override public function executeTest() : void
		{
			// If we've reached a call to "executeTest()," stream resource has already loaded.
			dispatchEvent( new MediaCaseErrorEvent( MediaCaseErrorEvent.STEP_SUCCESS ) );
			super.executeTest();
			//playTime = 120.0;
			//playTime = 10.0;
		}
		
		public function VoD_Simple_Playback_Test( resourceURI : String = "" )
		{
			super(resourceURI, ResourceURLDataManager.getRunTimeForTestNumber( 1 ));
		}
	}
}