package
{
	import org.osmf.logging.Logger;

	public class ExampleLogger extends Logger
	{
		public function ExampleLogger(category:String)
		{
			super(category);
		}
		
		override public function debug(message:String, ... rest):void
		{
			trace(message);
		}
	}
}