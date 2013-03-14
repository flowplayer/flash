package org.osmf.test.mast.adapter
{
	import flexunit.framework.TestCase;
	
	import org.osmf.mast.adapter.MASTAdapter;

	public class TestMASTAdapter extends TestCase
	{
		override public function setUp():void
		{
			_mastAdapter = new MASTAdapter();			
			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			_mastAdapter = null;			
		}
		
		public function testLookup():void
		{
			assertEquals("TimeTrait.duration", _mastAdapter.lookup(MASTAdapter.DURATION));
		}

		private var _mastAdapter:MASTAdapter;		
	}
}
