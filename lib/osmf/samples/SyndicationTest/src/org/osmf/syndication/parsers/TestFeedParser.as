package org.osmf.syndication.parsers
{
	import flash.xml.XMLDocument;
	
	import flexunit.framework.TestCase;

	public class TestFeedParser extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			parser = new FeedParser();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			parser = null;
		}
		
		public function testParseInvalidDocuments():void
		{
			assertTrue(parser.parse(new XML()) == null);
			assertTrue(parser.parse(<foo/>) == null);
			
			try
			{
				parser.parse(null);
				fail();
			}
			catch(error:ArgumentError)
			{
				// Swallow
			}
		}
		
		public static function htmlUnescape(str:String):String
		{
		    return new XMLDocument(str).firstChild.nodeValue;
		}

		private var parser:FeedParser;
	}
}
