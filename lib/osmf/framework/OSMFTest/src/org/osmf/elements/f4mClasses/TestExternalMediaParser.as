package org.osmf.elements.f4mClasses
{
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.osmf.elements.f4mClasses.ExternalMediaParser;
	import org.osmf.events.ParseEvent;

	public class TestExternalMediaParser
	{

		[Before]
		public function setUp():void
		{
			parser = new ExternalMediaParser();
		}

		[After]
		public function tearDown():void
		{
			parser = null;
		}

		[Test(async, description="Tests a media node from a 2.0 F4M.")]
		public function testParseExternalMedia():void
		{
			var test:XML = <media
					href='http://samples.osmf.org/jit/sample1_150kbps.f4v.f4m'
					bitrate='150'
					/>;
			var asyncHandler:Function = Async.asyncHandler(this, handleExternalParseComplete, TIMEOUT, null, handleTimeout);
			parser.addEventListener(ParseEvent.PARSE_COMPLETE, asyncHandler, false, 0, true);
			parser.parse(test.toXMLString());
		}

		private function handleExternalParseComplete(event:ParseEvent, passThroughData:Object):void
		{
			Assert.assertNull(event.data);
		}

		[Test(async, description="Tests a media node from a 1.0 F4M.")]
		public function testParseInlineMedia():void
		{
			var test:XML = <media
					streamId='GL_TabletDesktop_1030kbps_768x432'
					url='http://samples.osmf.org/jit/sample1_150kbps'
					bitrate='1030'
					bootstrapInfoId='bootstrap971'
					>
					<metadata>
						AgAKb25NZXRhRGF0YQgAAAAAAAhkdXJhdGlvbgBAYwYy29GUIwAFd2lkdGgAQIgAAAAAAAAABmhlaWdodABAewAAAAAAAAAMdmlkZW9jb2RlY2lkAgAEYXZjMQAMYXVkaW9jb2RlY2lkAgAEbXA0YQAKYXZjcHJvZmlsZQBAUIAAAAAAAAAIYXZjbGV2ZWwAQD4AAAAAAAAABmFhY2FvdAAAAAAAAAAAAAAOdmlkZW9mcmFtZXJhdGUAQDf53LURIocAD2F1ZGlvc2FtcGxlcmF0ZQBA1YiAAAAAAAANYXVkaW9jaGFubmVscwBAAAAAAAAAAAAJdHJhY2tpbmZvCgAAAAIDAAZsZW5ndGgAQUveFIAAAAAACXRpbWVzY2FsZQBA13AAAAAAAAAIbGFuZ3VhZ2UCAANgYGAAAAkDAAZsZW5ndGgAQUmab4AAAAAACXRpbWVzY2FsZQBA1YiAAAAAAAAIbGFuZ3VhZ2UCAANgYGAAAAkAB2N1c3RkZWYKAAAAAAAACQ==
					</metadata>
				</media>;
			var asyncHandler:Function = Async.asyncHandler(this, handleInlineParseComplete, TIMEOUT, null, handleTimeout);
			parser.addEventListener(ParseEvent.PARSE_COMPLETE, asyncHandler, false, 0, true);
			parser.parse(test.toXMLString());
		}

		private function handleInlineParseComplete(event:ParseEvent, passThroughData:Object):void
		{
			var m:Media = event.data as Media;

			Assert.assertNotNull(m);
			Assert.assertEquals(m.url, 'http://samples.osmf.org/jit/sample1_150kbps');
			Assert.assertEquals(m.bitrate, 1030);
			Assert.assertEquals(m.bootstrapInfo.id, 'bootstrap971');
		}

		private function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("Timeout reached before event.");
		}

		private static const TIMEOUT:Number = 1000;

		private var parser:ExternalMediaParser;
	}
}