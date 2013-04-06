package org.osmf.syndication.parsers.extensions
{
	import flash.utils.Dictionary;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.syndication.model.Entry;
	import org.osmf.syndication.model.Feed;
	import org.osmf.syndication.model.FeedTextType;
	import org.osmf.syndication.model.extensions.mrss.*;
	import org.osmf.syndication.model.rss20.*;
	import org.osmf.syndication.parsers.FeedParser;

	public class TestMediaRSSExtensionParser extends TestCase
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

		public function testParseInlineMRSSWithGroups():void
		{
			var feed:Feed = parser.parse(INLINE_MRSS_DOCUMENT_WITH_GROUPS);
			assertTrue(feed != null);
			assertTrue(feed.description.type == FeedTextType.TEXT);
			assertTrue(feed.description.text == "Songs galore at different bitrates");
			assertTrue(feed.id == null);
			assertTrue(feed.title.type == FeedTextType.TEXT);
			assertTrue(feed.title.text == "Song Site");
			assertTrue(feed.entries.length == 1);
			
			var entry:Entry = feed.entries[0];
			assertTrue(entry.title.text == "Cool song by an artist");
			assertTrue(entry.description == null);
			assertTrue(entry.id == null);
			assertTrue(entry.feedExtensions != null);
			
			var mediaRSSExtension:MediaRSSExtension = feed.feedExtensions[0] as MediaRSSExtension;
			assertTrue(mediaRSSExtension != null)
			assertTrue(mediaRSSExtension.description.text == "This was some really bizarre band I listened to as a young lad.");
			
        	assertTrue(mediaRSSExtension.keywords == "kitty, cat, big dog, yarn, fluffy");
        	assertTrue(mediaRSSExtension.copyright.url == "http://blah.com/additional-info.html");	
			assertTrue(mediaRSSExtension.copyright.text == "2005 FooBar Media");
			
			mediaRSSExtension = entry.feedExtensions[0] as MediaRSSExtension;
			assertTrue(mediaRSSExtension != null);
			
			var group:MediaRSSGroup = mediaRSSExtension.groups[0];
			assertTrue(group != null);
			
			var contents:Vector.<MediaRSSContent> = group.contents;
			assertTrue(contents != null);
			assertTrue(contents.length == 5);
			
			var content:MediaRSSContent = group.contents[0];
			assertTrue(content.url == "http://www.foo.com/song64kbps.mp3");
			assertTrue(content.fileSize == 1000);
			assertTrue(content.bitrate == 64);
			assertTrue(content.type == "audio/mpeg");
			assertTrue(content.isDefault == "true");
			assertTrue(content.expression == "full");

			content = group.contents[4];
			assertTrue(content.url == "http://www.foo.com/song.wav");
			assertTrue(content.fileSize == 16000);
			assertTrue(content.type == "audio/x-wav");
			assertTrue(content.expression == "full");
			assertTrue(content.channels == 2);
			assertTrue(content.duration == 120);
			assertTrue(content.language == "en");
			
			var credits:Vector.<MediaRSSCredit> = group.credits;
			assertTrue(credits.length == 2);
			
			var credit:MediaRSSCredit = credits[0];
			assertTrue(credit.role == "musician");
			assertTrue(credit.scheme == "");
			assertTrue(credit.text == "band member 1");
			
			var categories:Vector.<MediaRSSCategory> = group.categories;
			var category:MediaRSSCategory = categories[0];
			assertTrue(category.text == "music/artist name/album/song");
			category = categories[1];			
			assertTrue(category.scheme == "http://foo.org");
			assertTrue(category.label == "Test Label");
			assertTrue(category.text == "Test Category");
			
			var rating:MediaRSSRating = group.rating;
			assertTrue(rating.text == "nonadult");
		}
		
		public function testParseInlineMRSS():void
		{
			var feed:Feed = parser.parse(INLINE_MRSS_DOCUMENT);
			assertTrue(feed != null);
			assertTrue(feed.title.text == "Song Site");
			assertTrue(feed.entries != null);
			assertTrue(feed.entries.length == 1);
			
			var entry:RSSItem = feed.entries[0] as RSSItem;
			assertTrue(entry.link == "http://www.foo.com");
			assertTrue(entry.published == "Mon, 27 Aug 2001 16:08:56 PST");
			assertTrue(entry.feedExtensions != null);
			assertTrue(entry.feedExtensions.length == 1);
			
			var mediaRSSExtension:MediaRSSExtension = entry.feedExtensions[0] as MediaRSSExtension;
			assertTrue(mediaRSSExtension != null);
			assertTrue(mediaRSSExtension.content.url == "http://www.foo.com/video.mov");
			assertTrue(mediaRSSExtension.content.fileSize == 2000);
			assertTrue(mediaRSSExtension.content.bitrate == 128);
			assertTrue(mediaRSSExtension.content.type == "video/quicktime");
			assertTrue(mediaRSSExtension.content.expression == "full");
			
			var community:MediaRSSCommunity = mediaRSSExtension.community;
			assertTrue(community != null);
			assertTrue(community.starRatingAverage == 3.5);
			assertTrue(community.starRatingCount == 20);
			assertTrue(community.starRatingMin == 1);
			assertTrue(community.starRatingMax == 10);
			
			var comments:Vector.<String> = mediaRSSExtension.comments;
			assertTrue(comments != null);
			assertTrue(comments[0] == "comment1");
			assertTrue(comments[1] == "comment2");

			var embed:MediaRSSEmbed = mediaRSSExtension.embed;
			assertTrue(embed.url == "http://www.foo.com/player.swf");
			assertTrue(embed.width == 512);
			assertTrue(embed.height == 323);
			
			var embedParams:Dictionary = embed.embedValues;
			assertTrue(embedParams["type"] == "application/x-shockwave-flash");
			assertTrue(embedParams["width"] == "512");
			assertTrue(embedParams["height"] == "323");
			assertTrue(embedParams["allowFullScreen"] == "true");
			assertTrue(embedParams["flashVars"] ="id=12345&vid=678912i&lang=en-us&intl=us&thumbUrl=http://www.foo.com/thumbnail.jpg");
			
			var responses:Vector.<String> = mediaRSSExtension.responses;
			assertTrue(responses != null);
			assertTrue(responses[0] == "www.response1.com");
			assertTrue(responses[1] == "www.response2.com");
			
			var backLinks:Vector.<String> = mediaRSSExtension.backLinks;
			assertTrue(backLinks != null);
			assertTrue(backLinks[0] == "www.backLink1.com");
			assertTrue(backLinks[1] == "www.backLink2.com");
			
			var status:MediaRSSStatus = mediaRSSExtension.status;
			assertTrue(status.state == "active");
			
			var prices:Vector.<MediaRSSPrice> = mediaRSSExtension.prices;
			var price:MediaRSSPrice = prices[0];
			assertTrue(prices != null);
			assertTrue(price.type == "rent");
			assertTrue(price.price == "19.99");
			assertTrue(price.currency == "EUR");
			
			var license:MediaRSSLicense = mediaRSSExtension.license;
			assertTrue(license.type == "text/html");
			assertTrue(license.url == "http://www.licensehost.com/license");
			assertTrue(license.text == "Sample license for a video");
			
			var subtitles:Vector.<MediaRSSSubtitle> = mediaRSSExtension.subtitles;
			var subtitle:MediaRSSSubtitle = subtitles[0];
			assertTrue(subtitle.type =="application/smil");
			assertTrue(subtitle.language == "en-us");
			assertTrue(subtitle.url =="http://www.foo.org/subtitle.smil");
			
			var peerLink:MediaRSSPeerLink = mediaRSSExtension.peerLink;
            assertTrue(peerLink.type =="application/x-bittorrent ");
            assertTrue(peerLink.url =="http://www.foo.org/sampleFile.torrent");
            
            var restrictions:Vector.<MediaRSSRestriction> = mediaRSSExtension.restrictions;
            var restriction:MediaRSSRestriction = restrictions[0];
            assertTrue(restriction.type == "sharing");
            assertTrue(restriction.relationship == "deny");
            
            var scenes:Vector.<MediaRSSScene> = mediaRSSExtension.scenes;
            var scene:MediaRSSScene = scenes[0];
            assertTrue(scene.title == "sceneTitle1");
            assertTrue(scene.description == "sceneDesc1");
            assertTrue(scene.startTime == "00:15");
            assertTrue(scene.endTime == "00:45");
            
            var thumb:MediaRSSThumbnail = mediaRSSExtension.thumbnails[0] as MediaRSSThumbnail;
            assertTrue(thumb.url == "http://bogus.feed.com/thumb.png");
            
            var hash:MediaRSSHash = mediaRSSExtension.hashes[0] as MediaRSSHash;
            assertTrue(hash.algo == "md5");
            assertTrue(hash.text == "dfdec888b72151965a34b4b59031290a");

		}
			
		private static const INLINE_MRSS_DOCUMENT_WITH_GROUPS:XML = 
			<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
			<channel>
			<title>Song Site</title>
			<link>http://www.foo.com</link>
			<description>Songs galore at different bitrates</description>
        	<media:description type="plain">This was some really bizarre band I listened to as a young lad.</media:description>			
        	<media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>
        	<media:copyright url="http://blah.com/additional-info.html">2005 FooBar Media</media:copyright>        		
			    <item>
			        <title>Cool song by an artist</title>
			        <link>http://www.foo.com/item1.htm</link>
			        <media:group>
			            <media:content url="http://www.foo.com/song64kbps.mp3" 
			            fileSize="1000" bitrate="64" type="audio/mpeg" 
			            isDefault="true" expression="full"/>
			            <media:content url="http://www.foo.com/song128kbps.mp3" 
			            fileSize="2000" bitrate="128" type="audio/mpeg" 
			            expression="full"/>
			            <media:content url="http://www.foo.com/song256kbps.mp3" 
			            fileSize="4000" bitrate="256" type="audio/mpeg" 
			            expression="full"/>
			            <media:content url="http://www.foo.com/song512kbps.mp3.torrent" 
			            fileSize="8000" type="application/x-bittorrent;enclosed=audio/mpeg" 
			            expression="full"/>
			            <media:content url="http://www.foo.com/song.wav" 
			            fileSize="16000" type="audio/x-wav" expression="full" channels="2" 
			            duration="120" lang="en"/>
			            <media:credit role="musician">band member 1</media:credit>
			            <media:credit role="musician">band member 2</media:credit>
			            <media:category>music/artist name/album/song</media:category>
				        <media:category scheme="http://foo.org" label="Test Label">Test Category</media:category>
			            <media:rating>nonadult</media:rating>
			        </media:group>
			        <media:group>
			        </media:group>
			    </item>
			</channel>
			</rss>
			
		private static const INLINE_MRSS_DOCUMENT:XML = 
			<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
			<channel>
			<title>Song Site</title>
			<description>mRSS example with new fields added in v1.5.0</description>
				<item>
			                <link>http://www.foo.com</link>
			                <pubDate>Mon, 27 Aug 2001 16:08:56 PST</pubDate>
			                <media:content url="http://www.foo.com/video.mov" fileSize="2000" bitrate="128" type="video/quicktime" expression="full"/>
			                <media:community>
			                    <media:starRating average="3.5" count="20" min="1" max="10"/>
			                    <media:statistics views="5" favorites="5"/>
			                    <media:tags>news: 5, abc:3</media:tags>
			                </media:community>
			                <media:comments>
			                    <media:comment>comment1</media:comment>
			                    <media:comment>comment2</media:comment>
			                </media:comments>
			                <media:embed url="http://www.foo.com/player.swf" width="512" height="323" >
			                    <media:param name="type">application/x-shockwave-flash</media:param>
			                    <media:param name="width">512</media:param>
			                    <media:param name="height">323</media:param>
			                    <media:param name="allowFullScreen">true</media:param>
			                    <media:param name="flashVars">id=12345&vid=678912i&lang=en-us&intl=us&thumbUrl=http://www.foo.com/thumbnail.jpg</media:param>
			                    <media:param bogus="intential bogus param name">foo bar</media:param>
			                    <media:param />
			                </media:embed>
			                <media:responses>
			                  <media:response>www.response1.com</media:response>
			                  <media:response>www.response2.com</media:response>
			                </media:responses>
			                <media:backLinks>
			                  <media:backLink>www.backLink1.com</media:backLink>
			                  <media:backLink>www.backLink2.com</media:backLink>
			                </media:backLinks>
			                <media:status state="active"/>
			                <media:price type="rent" price="19.99" currency="EUR" />
			                <media:license type="text/html" href="http://www.licensehost.com/license"> Sample license for a video </media:license>
			                <media:subTitle type="application/smil" lang="en-us"  href="http://www.foo.org/subtitle.smil"  />
			                <media:peerLink type="application/x-bittorrent " href="http://www.foo.org/sampleFile.torrent"  />
			                <media:restriction type="sharing" relationship="deny" />
			                <media:scenes>
			                    <media:scene>
			                        <sceneTitle>sceneTitle1</sceneTitle>
			                        <sceneDescription>sceneDesc1</sceneDescription>
			                        <sceneStartTime>00:15</sceneStartTime>
			                        <sceneEndTime>00:45</sceneEndTime>
			                    </media:scene>
			                </media:scenes>
      						<media:thumbnail url="http://bogus.feed.com/thumb.png"/>
        					<media:hash algo="md5">dfdec888b72151965a34b4b59031290a</media:hash>      							                
			    </item>
			</channel>
			</rss>
			
		private var parser:FeedParser;
			
	}
}
