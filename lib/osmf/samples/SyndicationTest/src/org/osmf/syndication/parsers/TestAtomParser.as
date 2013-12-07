package org.osmf.syndication.parsers
{
	import __AS3__.vec.Vector;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.syndication.model.FeedText;
	import org.osmf.syndication.model.FeedTextType;
	import org.osmf.syndication.model.atom.AtomCategory;
	import org.osmf.syndication.model.atom.AtomEntry;
	import org.osmf.syndication.model.atom.AtomFeed;
	import org.osmf.syndication.model.atom.AtomPerson;

	public class TestAtomParser extends TestCase
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

		public function testParseAtomSimple():void
		{
			var feed:AtomFeed = parser.parse(INLINE_ATOM_DOCUMENT_SIMPLE) as AtomFeed;
			assertTrue(feed != null);
			assertTrue(feed.title.text == "Example Feed");
			assertTrue(feed.link.url == "http://example.org/");
			assertTrue(feed.updated == "2003-12-13T18:30:02Z");
			assertTrue(feed.authors != null);
			assertTrue(feed.authors[0].name == "John Doe");
			assertTrue(feed.id == "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6");
			assertTrue(feed.entries != null);
			assertTrue(feed.entries.length == 1);
			
			var entry:AtomEntry = feed.entries[0] as AtomEntry;
			assertTrue(entry.title.text == "Atom-Powered Robots Run Amok");
			assertTrue(entry.link.url == "http://example.org/2003/12/13/atom03");
			assertTrue(entry.id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a");
			assertTrue(entry.updated == "2003-12-13T18:30:02Z");
			assertTrue(entry.description.text == "Some text.");
		}
		
		public function testParseAtom():void
		{
			var feed:AtomFeed = parser.parse(INLINE_ATOM_DOCUMENT) as AtomFeed;
			assertTrue(feed != null);
			assertTrue(feed.subtitle.type == FeedTextType.HTML);
			assertTrue(feed.subtitle.text != "");
			assertTrue(feed.rights.text == "Copyright (c) 2003, Mark Pilgrim");

			var contributors:Vector.<AtomPerson> = feed.contributors;
			assertTrue(contributors != null);
			assertTrue(contributors.length == 1);
			
			var contributor:AtomPerson = contributors[0];
			assertTrue(contributor.name == "Jane Doe");
			assertTrue(contributor.url == "http://www.janedoe.com"); 

			var icon:String = feed.icon;
			var logo:String = feed.logo;
			assertTrue(icon == "/icon.jpg");
			assertTrue(logo == "/logo.jpg");		     
			
			var categories:Vector.<AtomCategory> = feed.categories;
			assertTrue(categories != null);
			assertTrue(categories.length == 1);
			
			var category:AtomCategory = categories[0];
			assertTrue(category != null);
			assertTrue(category.term == "sports");			
			
			var entry:AtomEntry = feed.entries[0] as AtomEntry;
			assertTrue(entry != null);
			assertTrue(entry.published == "2003-12-13T08:29:29-04:00");
			
			categories = entry.categories;
			assertTrue(categories != null);
			assertTrue(categories.length == 1);
			
			category = categories[0];
			assertTrue(category != null);
			assertTrue(category.term == "technology");
			assertTrue(category.scheme == "scheme.category.tech");
			assertTrue(category.label == "technology");
			
			var source:AtomFeed = entry.source;
			assertTrue(source.id == "http://example.org/");
			assertTrue(source.title.text == "Fourty-Two");
			assertTrue(source.updated == "2003-12-13T18:30:02Z");
			assertTrue(source.rights.text == "© 2005 Example, Inc.");
			
			var rights:FeedText = entry.rights;
			assertTrue(rights.type == FeedTextType.HTML);
			
			var test:String = TestFeedParser.htmlUnescape("&amp;copy; 2005 John Doe");
			assertTrue(rights.text == test);
		}
		
		private static const INLINE_ATOM_DOCUMENT_SIMPLE:XML = 
			<feed xmlns="http://www.w3.org/2005/Atom">
			  <title>Example Feed</title>
			  <link href="http://example.org/"></link>
			  <updated>2003-12-13T18:30:02Z</updated>
			  <author>
			    <name>John Doe</name>
			  </author>
			  <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
			  <entry>
			    <title>Atom-Powered Robots Run Amok</title>
			    <link href="http://example.org/2003/12/13/atom03"/>
			    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
			    <updated>2003-12-13T18:30:02Z</updated>
			    <summary>Some text.</summary>
			  </entry>
			</feed>
		
		private static const INLINE_ATOM_DOCUMENT:XML = 
		   <feed xmlns="http://www.w3.org/2005/Atom">
		     <title type="text">dive into mark</title>
		     <subtitle type="html">
		       A &lt;em&gt;lot&lt;/em&gt; of effort
		       went into making this effortless
		     </subtitle>
		     <updated>2005-07-31T12:29:29Z</updated>
		     <id>tag:example.org,2003:3</id>
			<contributor>
			  <name>Jane Doe</name>
			  <uri>http://www.janedoe.com</uri>
			</contributor>		     
		     <link rel="alternate" type="text/html"
		      hreflang="en" href="http://example.org/"/>
		     <link rel="self" type="application/atom+xml"
		      href="http://example.org/feed.atom"/>
		     <rights>Copyright (c) 2003, Mark Pilgrim</rights>
		     <generator uri="http://www.example.com/" version="1.0">
		       Example Toolkit
		     </generator>
			<icon>/icon.jpg</icon>
			<logo>/logo.jpg</logo>
			<category term="sports"/>					     
		     <entry>
		       <title>Atom draft-07 snapshot</title>
		       <link rel="alternate" type="text/html"
		        href="http://example.org/2005/04/02/atom"/>
		       <link rel="enclosure" type="audio/mpeg" length="1337"
		        href="http://example.org/audio/ph34r_my_podcast.mp3"/>
		       <id>tag:example.org,2003:3.2397</id>
		       <updated>2005-07-31T12:29:29Z</updated>
		       <published>2003-12-13T08:29:29-04:00</published>
				<rights type="html">
				  &amp;copy; 2005 John Doe
				</rights>		       
			   <category term="technology" scheme="scheme.category.tech" label="technology"/>
				<source>
				  <id>http://example.org/</id>
				  <title>Fourty-Two</title>
				  <updated>2003-12-13T18:30:02Z</updated>
				  <rights>© 2005 Example, Inc.</rights>
				</source>			          
		       <author>
		         <name>Mark Pilgrim</name>
		         <uri>http://example.org/</uri>
		         <email>f8dy@example.com</email>
		       </author>
		       <contributor>
		         <name>Sam Ruby</name>
		       </contributor>
		       <contributor>
		         <name>Joe Gregorio</name>
		       </contributor>
		       <content type="xhtml" xml:lang="en"
		        xml:base="http://diveintomark.org/">
		         <div xmlns="http://www.w3.org/1999/xhtml">
		           <p><i>[Update: The Atom draft is finished.]</i></p>
		         </div>
		       </content>
		     </entry>
		   </feed>
		   
		private var parser:FeedParser;
	}
}
