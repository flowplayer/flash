package flexUnitTests
{
	import org.flexunit.runners.MediaRunner;

	[RunWith("org.flexunit.runners.MediaRunner")]
	public class TestCustomRunner
	{	
		private var importVar : MediaRunner;
		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		public function testMediaRunner() : void
		{
			var something : String = "something.";
		}
	}
}