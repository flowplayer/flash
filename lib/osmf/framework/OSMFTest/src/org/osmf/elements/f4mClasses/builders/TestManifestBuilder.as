package org.osmf.elements.f4mClasses.builders
{
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.osmf.elements.f4mClasses.builders.ManifestBuilder;
	import org.osmf.elements.f4mClasses.ManifestParser;

	public class TestManifestBuilder
	{
		private var builder:ManifestBuilder;

		[Before]
		public function setUp():void
		{
			builder = new ManifestBuilder();
		}

		[After]
		public function tearDown():void
		{
			builder = null;
		}

		[Test]
		public function testCanParseTrue():void
		{
			var test:String = "<?xml version='1.0' encoding='UTF-8'?><manifest xmlns='http://ns.adobe.com/f4m/1.0'></manifest>";
			var result:Boolean = builder.canParse(test);

			Assert.assertTrue(result);
		}

		[Test]
		public function testCanParseFalse():void
		{
			var test:String = "<?xml version='1.0' encoding='UTF-8'?><manifest xmlns='http://ns.adobe.com/f4m/2.0'></manifest>";
			var result:Boolean = builder.canParse(test);

			Assert.assertFalse(result);
		}

		[Test]
		public function testBuild():void
		{
			var test:String = "<?xml version='1.0' encoding='UTF-8'?><manifest xmlns='http://ns.adobe.com/f4m/1.0'></manifest>";
			var parser:ManifestParser = builder.build(test);

			assertThat(parser, isA(ManifestParser));
		}
	}
}