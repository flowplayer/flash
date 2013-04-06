package org.osmf.test.mast.parser
{
	import __AS3__.vec.Vector;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.mast.model.*;
	import org.osmf.mast.parser.MASTParser;
	import org.osmf.test.mast.MASTTestConstants;

	public class TestMASTParser extends TestCase
	{
		public function testParser():void
		{
			var parser:MASTParser = new MASTParser();
			var mastDocument:MASTDocument = parser.parse(MASTTestConstants.MAST_DOCUMENT_TEST_PARSER.toXMLString());
			
			assertTrue(mastDocument.triggers.length > 0);

			for each (var trigger:MASTTrigger in mastDocument.triggers)
			{
				for each (var source:MASTSource in trigger.sources)
				{
					assertNotNull(source);
					var altRef:String = source.altReference;
					var sources:Vector.<MASTSource> = source.sources;
					for each( var target:MASTTarget in source.targets)
					{
						var id:String = target.id;
						assertNotNull(id);
						
						var regionName:String = target.regionName;
						assertNotNull(regionName);
						
						var targets:Vector.<MASTTarget> = target.targets;
					}
				}
			}
		}
		
		public function testParserWithBadFile():void
		{
			var parser:MASTParser = new MASTParser();
			
			try
			{
				var mastDocument:MASTDocument = parser.parse(MASTTestConstants.MAST_DOCUMENT_TEST_PARSER_BAD_DATA.toXMLString());
				fail();
			}
			catch (error:ArgumentError)
			{
				
			}
			
		}
		
			
	}
}
