package org.osmf
{
	import flexunit.framework.TestSuite;
	
	import org.osmf.test.mast.loader.TestMASTLoader;
	import org.osmf.test.mast.adapter.TestMASTAdapter;
	import org.osmf.test.mast.media.TestMASTProxyElement;
	import org.osmf.test.mast.managers.TestMASTConditionManager;
	import org.osmf.test.mast.TestMASTPluginInfo;
	import org.osmf.test.mast.parser.TestMASTParser;

	public class MASTPluginIntegrationTests extends TestSuite
	{
		public function MASTPluginIntegrationTests(param:Object=null)
		{
			super(param);
			
			addTestSuite(TestMASTLoader);
			addTestSuite(TestMASTAdapter);
			addTestSuite(TestMASTProxyElement);
			addTestSuite(TestMASTPluginInfo);
			addTestSuite(TestMASTParser);
			addTestSuite(TestMASTConditionManager);
		}
		
	}
}