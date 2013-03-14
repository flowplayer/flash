package org.osmf.syndication.parsers
{
	import flexunit.framework.TestCase;
	
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.model.FeedTextType;
	import org.osmf.syndication.model.rss20.*;

	public class TestRSS20Parser extends TestCase
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
		
		public function testParseInlineRSSSimple():void
		{
			var feed:Feed = parser.parse(INLINE_RSS_DOCUMENT_SIMPLE);
			assertTrue(feed != null);
			assertTrue(feed.entries.length == 1);
			assertTrue(feed.feedExtensions == null);
			assertTrue(feed.id == null);
			assertTrue(feed.title.type == FeedTextType.TEXT);
			assertTrue(feed.title.text == "Title of page");
			assertTrue(feed.description.type == FeedTextType.TEXT);
			assertTrue(feed.description.text == "Description of page");
			
			var entry:Entry = feed.entries[0];
			assertTrue(entry.title.text == "Story about something");
			assertTrue((entry as RSSItem).link == "http://www.foo.com/item1.htm");
			assertTrue(entry.enclosure.url == "http://www.foo.com/file.mov");
			assertTrue(entry.enclosure.type == "video/quicktime");
			assertTrue(entry.enclosure.length == 320000);
		}
		
		public function testParseInlineRSS():void
		{
			var feed:Feed = parser.parse(INLINE_RSS_DOCUMENT);
			assertTrue(feed != null);
			assertTrue(feed.description.type == FeedTextType.TEXT); 
			assertTrue(feed.description.text == "Liftoff to Space Exploration.");
			assertTrue(feed.entries.length == 4);
			assertTrue(feed.feedExtensions == null);
			assertTrue(feed.id == null);
			assertTrue(feed.title.type == FeedTextType.TEXT);
			assertTrue(feed.title.text == "Liftoff News");
			
			var cloud:RSSCloud = (feed as RSSFeed).cloud;
			assertTrue(cloud != null);
			assertTrue(cloud.domain == "rpc.sys.com");
			assertTrue(cloud.port == "80");
			assertTrue(cloud.path == "/RPC2");
			assertTrue(cloud.registerProcedure == "myCloud.rssPleaseNotify");
			assertTrue(cloud.protocol == "xml-rpc");			
			
			var entry:Entry = feed.entries[0];
			assertTrue(entry.title.text == "Star City");
			assertTrue(entry.description.text.length > 0);
			assertTrue(entry.enclosure == null);
			assertTrue(entry.id == null);
			assertTrue(entry.published == "Tue, 03 Jun 2003 09:39:21 GMT");
			assertTrue(entry.feedExtensions == null);
			assertTrue((entry as RSSItem).author == "somedude@stoked.net");
			assertTrue((entry as RSSItem).guid == "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573");
			
			var category:RSSCategory = (entry as RSSItem).categories[0] as RSSCategory;
			assertTrue(category.domain == "http://www.testing.com/test/");
			assertTrue(category.name == "Test Item One");
			
			var source:RSSSource = (entry as RSSItem).source;
			assertTrue(source.url == "http://www.tomalak.org/links2.xml");
			assertTrue(source.name == "Tomalak's Realm");			
			
			var image:RSSImage = (feed as RSSFeed).image;
			assertTrue(image != null);
			assertTrue(image.title == "The image title goes here");
			assertTrue(image.url == "http://www.urlofthechannel.com/images/logo.gif");
			assertTrue(image.link == "http://www.urlofthechannel.com/");
			assertTrue(image.width == 20);
			assertTrue(image.height == 20);
			
			category = (feed as RSSFeed).categories[0] as RSSCategory;
			assertTrue(category.domain == "http://www.testing.com/test");
			assertTrue(category.name == "Test");
			
			assertTrue((feed as RSSFeed).copyright == "Copyright 2002, Spartanburg Herald-Journal");
			assertTrue((feed as RSSFeed).docs == "http://blogs.law.harvard.edu/tech/rss");
			assertTrue((feed as RSSFeed).generator == "Weblog Editor 2.0");
			assertTrue((feed as RSSFeed).language == "en-us");
			assertTrue((feed as RSSFeed).lastBuildDate == "Tue, 10 Jun 2003 09:41:01 GMT");
			assertTrue((feed as RSSFeed).link == "http://liftoff.msfc.nasa.gov/");
			assertTrue((feed as RSSFeed).managingEditor == "editor@example.com");
			assertTrue((feed as RSSFeed).pubDate == "Tue, 10 Jun 2003 04:00:00 GMT");
		}
		
		private static const INLINE_RSS_DOCUMENT_SIMPLE:XML = 
			<rss version="2.0">
			<channel>
			<title>Title of page</title>
			<link>http://www.foo.com</link>
			<description>Description of page</description>
			    <item>
			        <title>Story about something</title>
			        <link>http://www.foo.com/item1.htm</link>
			        <enclosure url="http://www.foo.com/file.mov" 
			        length="320000" type="video/quicktime"/>
			    </item>
			</channel>
			</rss>
		
		private static const INLINE_RSS_DOCUMENT:XML = 
			<rss version="2.0">
			   <channel>
			      <title>Liftoff News</title>
			      <copyright>Copyright 2002, Spartanburg Herald-Journal</copyright>
			      <link>http://liftoff.msfc.nasa.gov/</link>
			      <description>Liftoff to Space Exploration.</description>
			      <language>en-us</language>
			      <pubDate>Tue, 10 Jun 2003 04:00:00 GMT</pubDate>
				  <category domain="http://www.testing.com/test">Test</category>			
			      <lastBuildDate>Tue, 10 Jun 2003 09:41:01 GMT</lastBuildDate>
			      <docs>http://blogs.law.harvard.edu/tech/rss</docs>
			      <generator>Weblog Editor 2.0</generator>
			      <managingEditor>editor@example.com</managingEditor>
			      <webMaster>webmaster@example.com</webMaster>
				  <cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="myCloud.rssPleaseNotify" protocol="xml-rpc" />
				   <image>
				      <title>The image title goes here</title>
				      <url>http://www.urlofthechannel.com/images/logo.gif</url>
				      <link>http://www.urlofthechannel.com/</link>
				      <height>20</height>
				      <width>20</width>
				    </image>
 			      <item>
			         <title>Star City</title>
			         <link>http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp</link>
			         <description>How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href="http://howe.iki.rssi.ru/GCTC/gctc_e.htm"&gt;Star City&lt;/a&gt;.</description>
			         <pubDate>Tue, 03 Jun 2003 09:39:21 GMT</pubDate>
			         <guid>http://liftoff.msfc.nasa.gov/2003/06/03.html#item573</guid>
					 <author>somedude@stoked.net</author>	
				     <category domain="http://www.testing.com/test/">Test Item One</category>	
					 <source url="http://www.tomalak.org/links2.xml">Tomalak's Realm</source>				     		
			      </item>
			      <item>
			         <description>Sky watchers in Europe, Asia, and parts of Alaska and Canada will experience a &lt;a href="http://science.nasa.gov/headlines/y2003/30may_solareclipse.htm"&gt;partial eclipse of the Sun&lt;/a&gt; on Saturday, May 31st.</description>
			         <pubDate>Fri, 30 May 2003 11:06:42 GMT</pubDate>
			         <guid>http://liftoff.msfc.nasa.gov/2003/05/30.html#item572</guid>
			
			      </item>
			      <item>
			         <title>The Engine That Does More</title>
			         <link>http://liftoff.msfc.nasa.gov/news/2003/news-VASIMR.asp</link>
			         <description>Before man travels to Mars, NASA hopes to design new engines that will let us fly through the Solar System more quickly.  The proposed VASIMR engine would do that.</description>
			         <pubDate>Tue, 27 May 2003 08:37:32 GMT</pubDate>
			         <guid>http://liftoff.msfc.nasa.gov/2003/05/27.html#item571</guid>
			
			      </item>
			      <item>
			         <title>Astronauts' Dirty Laundry</title>
			         <link>http://liftoff.msfc.nasa.gov/news/2003/news-laundry.asp</link>
			         <description>Compared to earlier spacecraft, the International Space Station has many luxuries, but laundry facilities are not one of them.  Instead, astronauts have other options.</description>
			         <pubDate>Tue, 20 May 2003 08:56:02 GMT</pubDate>
			         <guid>http://liftoff.msfc.nasa.gov/2003/05/20.html#item570</guid>
			
			      </item>
			   </channel>
			</rss>
		
		private var parser:FeedParser;
		
	}
}