package org.osmf.test.captioning.parsers
{
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.captioning.model.Caption;
	import org.osmf.captioning.model.CaptionFormat;
	import org.osmf.captioning.model.CaptionStyle;
	import org.osmf.captioning.model.CaptioningDocument;
	import org.osmf.captioning.parsers.DFXPParser;
	import org.osmf.test.captioning.CaptioningTestConstants;

	public class TestDFXPParser extends TestCase
	{
		public function TestDFXPParser(methodName:String=null)
		{
			super(methodName);
		}
		public function testParser():void
		{
			var parser:DFXPParser = new DFXPParser();
			var document:CaptioningDocument = parser.parse(CaptioningTestConstants.CAPTIONING_DOCUMENT_CONTENTS_FULL.toXMLString());
			
			assertTrue(document.copyright.length > 0);
			assertTrue(document.description.length > 0);
			assertTrue(document.title.length > 0);
			
			assertTrue(document.numCaptions > 0);
			for (var i:int = 0; i < document.numCaptions; i++)
			{
				var caption:Caption = document.getCaptionAt(i);
				assertTrue(caption.clearText.length > 0);
				assertTrue(caption.text.length > 0);

				var maxIndex:int = caption.numCaptionFormats;
				try
				{
					caption.getCaptionFormatAt(maxIndex + 1);
					fail();
				}
				catch(err:IllegalOperationError)
				{
					
				}
				
				for (var j:int = 0; j < caption.numCaptionFormats; j++)
				{
					var format:CaptionFormat = caption.getCaptionFormatAt(j);
					assertTrue(format.startIndex >= 0);
					assertTrue(format.endIndex > format.startIndex);
					var style:CaptionStyle = format.style;
					
					if (style.backgroundColor != null)
					{
						assertTrue((style.backgroundColor as int) > 0);
					}
					
					if (style.backgroundColorAlpha != null)
					{
						assertTrue((style.backgroundColorAlpha as int) > 0);
					}
					
					if (style.fontFamily != null && style.fontFamily != "")
					{
						assertTrue(style.fontFamily.length > 0);
					}
					
					if (style.fontStyle != null && style.fontStyle != "")
					{
						assertTrue(style.fontStyle == "normal" || style.fontStyle == "italic");
					}
					
					if (style.fontWeight != null && style.fontWeight != "")
					{
						assertTrue(style.fontWeight == "normal" || style.fontWeight == "bold");
					}
					
					if (style.textAlign != null && style.textAlign != "")
					{
						assertTrue(style.textAlign == "left" || style.textAlign == "center" || style.textAlign == "right");
					}
					
				}
			}
		}
		
		public function testParserWithBadFile():void
		{
			var parser:DFXPParser = new DFXPParser();
			
			try
			{
				var document:CaptioningDocument = parser.parse(CaptioningTestConstants.INVALID_XML_CAPTIONING_DOCUMENT_CONTENTS);
				fail();
			}
			catch (error:Error)
			{
				
			}
		}

		public function testParserWithNoBodyTag():void
		{
			var parser:DFXPParser = new DFXPParser();
			var document:CaptioningDocument = parser.parse(CaptioningTestConstants.CAPTIONING_DOCUMENT_CONTENTS_NO_BODY.toXMLString());
			
			assertTrue(document.numCaptions == 0);
		}
		
		public function testParserWithNoDivTag():void
		{
			var parser:DFXPParser = new DFXPParser();
			var document:CaptioningDocument = parser.parse(CaptioningTestConstants.CAPTIONING_DOCUMENT_CONTENTS_NO_DIV.toXMLString());
			
			assertTrue(document.numCaptions > 0);

		}
		
		
	}
}
