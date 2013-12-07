package org.osmf.syndication.parsers.extensions
{
	import __AS3__.vec.Vector;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.syndication.model.extensions.itunes.ITunesCategory;
	import org.osmf.syndication.model.extensions.itunes.ITunesExtension;
	import org.osmf.syndication.model.rss20.RSSCategory;
	import org.osmf.syndication.model.rss20.RSSFeed;
	import org.osmf.syndication.parsers.FeedParser;
	import org.osmf.syndication.parsers.TestFeedParser;

	public class TestITunesExtensionParser extends TestCase
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
		
		public function testRSSWithITunes():void
		{
			var feed:RSSFeed = parser.parse(INLINE_RSS_WITH_ITUNES) as RSSFeed;
			var itunes:ITunesExtension = feed.feedExtensions[0] as ITunesExtension;
			assertTrue(itunes != null);
			assertTrue(itunes.subtitle == "A show about everything");
			assertTrue(itunes.author == "John Doe");
			assertTrue(itunes.summary == "All About Everything is a show about everything. Each week we dive into any subject known to man and talk about it as much as we can. Look for our Podcast in the iTunes Store");
			assertTrue(itunes.owner.name == "John Doe");
			assertTrue(itunes.owner.email == "john.doe@example.com");
			assertTrue(itunes.imageURL == "http://example.com/podcasts/everything/AllAboutEverything.jpg");
			
			var categories:Vector.<ITunesCategory> = itunes.categories;
			assertTrue(categories != null);
			
			var category:ITunesCategory = categories[0];
			assertTrue(category.name == "Technology");
			
			var subcategories:Vector.<RSSCategory> = category.subCategories;
			assertTrue(subcategories != null);
			
			var subcategory:RSSCategory = subcategories[0];
			assertTrue(subcategory.name == "Gadgets");
			
			category = categories[1];
			assertTrue(category.name == TestFeedParser.htmlUnescape("TV &amp; Film"));
			
			var block:String = itunes.block;
			assertTrue(block == "yes");
			
			var explicit:String = itunes.explicit;
			assertTrue(explicit == "yes");
			
			var newFeed:String = itunes.newFeedURL;
			assertTrue(newFeed == "http://newlocation.com/example.rss");
		}
		
		private static const INLINE_RSS_WITH_ITUNES:XML = 
			<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
			<channel>
				<title>All About Everything</title>
				<link>http://www.example.com/podcasts/everything/index.html</link>
				<language>en-us</language>
				<copyright>&#x2117; &amp; &#xA9; 2005 John Doe &amp; Family</copyright>
				<itunes:subtitle>A show about everything</itunes:subtitle>
				<itunes:author>John Doe</itunes:author>
				<itunes:summary>All About Everything is a show about everything. Each week we dive into any subject known to man and talk about it as much as we can. Look for our Podcast in the iTunes Store</itunes:summary>
				<description>All About Everything is a show about everything. Each week we dive into any subject known to man and talk about it as much as we can. Look for our Podcast in the iTunes Store</description>
				<itunes:owner>
					<itunes:name>John Doe</itunes:name>
					<itunes:email>john.doe@example.com</itunes:email>
				</itunes:owner>
				<itunes:image href="http://example.com/podcasts/everything/AllAboutEverything.jpg" />
				<itunes:category text="Technology">
					<itunes:category text="Gadgets"/>
				</itunes:category>
				<itunes:category text="TV &amp; Film"/>
				<itunes:bogus text="Adding a bogus itunes extension tag here on purpose." />
    			<itunes:block>yes</itunes:block>
    			<itunes:explicit>yes</itunes:explicit>
				<itunes:new-feed-url>http://newlocation.com/example.rss</itunes:new-feed-url>      				
				<item>
					<title>Shake Shake Shake Your Spices</title>
					<itunes:author>John Doe</itunes:author>
					<itunes:subtitle>A short primer on table spices</itunes:subtitle>
					<itunes:summary>This week we talk about salt and pepper shakers, comparing and contrasting pour rates, construction materials, and overall aesthetics. Come and join the party!</itunes:summary>
					<enclosure url="http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4a" length="8727310" type="audio/x-m4a" />
					<guid>http://example.com/podcasts/archive/aae20050615.m4a</guid>
					<pubDate>Wed, 15 Jun 2005 19:00:00 GMT</pubDate>
					<itunes:duration>7:04</itunes:duration>
					<itunes:keywords>salt, pepper, shaker, exciting</itunes:keywords>
				</item>
				<item>
					<title>Socket Wrench Shootout</title>
					<itunes:author>Jane Doe</itunes:author>
					<itunes:subtitle>Comparing socket wrenches is fun!</itunes:subtitle>
					<itunes:summary>This week we talk about metric vs. old english socket wrenches. Which one is better? Do you really need both? Get all of your answers here.</itunes:summary>
					<enclosure url="http://example.com/podcasts/everything/AllAboutEverythingEpisode2.mp3" length="5650889" type="audio/mpeg" />
					<guid>http://example.com/podcasts/archive/aae20050608.mp3</guid>
					<pubDate>Wed, 8 Jun 2005 19:00:00 GMT</pubDate>
					<itunes:duration>4:34</itunes:duration>
					<itunes:keywords>metric, socket, wrenches, tool</itunes:keywords>
				</item>
				<item>
					<title>Red, Whine, &amp; Blue</title>
					<itunes:author>Various</itunes:author>
					<itunes:subtitle>Red + Blue != Purple</itunes:subtitle>
					<itunes:summary>This week we talk about surviving in a Red state if you are a Blue person. Or vice versa.</itunes:summary>
					<enclosure url="http://example.com/podcasts/everything/AllAboutEverythingEpisode1.mp3" length="4989537" type="audio/mpeg" />
					<guid>http://example.com/podcasts/archive/aae20050601.mp3</guid>
					<pubDate>Wed, 1 Jun 2005 19:00:00 GMT</pubDate>
					<itunes:duration>3:59</itunes:duration>
					<itunes:keywords>politics, red, blue, state</itunes:keywords>
				</item>
			</channel>
			</rss>
			
		private var parser:FeedParser;
			
	}
}