package org.osmf
{
	import flexunit.framework.TestSuite;
	
	import org.osmf.test.captioning.TestCaptioningPluginInfo;
	import org.osmf.test.captioning.loader.TestCaptioningLoader;
	import org.osmf.test.captioning.media.TestCaptioningProxyElement;
	import org.osmf.test.captioning.parsers.TestDFXPParser;

	public class CaptioningPluginIntegrationTests extends TestSuite
	{
		public function CaptioningPluginIntegrationTests(param:Object=null)
		{
			super(param);
			
			addTestSuite(TestCaptioningPluginInfo);
			addTestSuite(TestCaptioningLoader);
			addTestSuite(TestCaptioningProxyElement);
			addTestSuite(TestDFXPParser);
		}
	}
}
