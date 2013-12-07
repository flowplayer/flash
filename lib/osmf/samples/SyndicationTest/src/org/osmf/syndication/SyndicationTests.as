package org.osmf.syndication
{
	import flexunit.framework.TestSuite;
	
	import org.osmf.syndication.loader.TestFeedLoader;
	import org.osmf.syndication.parsers.TestFeedParser;
	import org.osmf.syndication.parsers.TestAtomParser;
	import org.osmf.syndication.parsers.TestRSS20Parser;
	import org.osmf.syndication.parsers.extensions.TestITunesExtensionParser;
	import org.osmf.syndication.parsers.extensions.TestMediaRSSExtensionParser;
	import org.osmf.syndication.media.TestSyndicationMediaGenerator;
	
	public class SyndicationTests extends TestSuite
	{
		public function SyndicationTests(param:Object=null)
		{
			super(param);
			
			addTestSuite(TestFeedLoader);
			addTestSuite(TestFeedParser);
			addTestSuite(TestAtomParser);
			addTestSuite(TestRSS20Parser);
			addTestSuite(TestITunesExtensionParser);
			addTestSuite(TestMediaRSSExtensionParser);
			addTestSuite(TestSyndicationMediaGenerator);
		}
	}
}
