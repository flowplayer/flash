package org.osmf.syndication.media
{
	import flexunit.framework.TestCase;
	
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.syndication.model.Enclosure;
	import org.osmf.syndication.model.Entry;

	public class TestSyndicationMediaGenerator extends TestCase
	{
		public function testMediaGenerator():void
		{
			var entry:Entry = new Entry();
			var enclosure:Enclosure = new Enclosure();
			enclosure.url = "http://foo.bar/movie.mov";
			enclosure.type = "video/quicktime";
			enclosure.length = 120;
			
			entry.enclosure = enclosure;
			var generator:SyndicationMediaGenerator = new SyndicationMediaGenerator();
			var mediaElement:MediaElement = generator.createMediaElement(entry);
		}
		
		public function testMediaGeneratorWithDefaultFactory():void
		{
			var entry:Entry = new Entry();
			var enclosure:Enclosure = new Enclosure();
			var factory:DefaultMediaFactory = new DefaultMediaFactory();
			
			enclosure.url = "http://foo.bar/movie.mov";
			
			entry.enclosure = enclosure;
			var generator:SyndicationMediaGenerator = new SyndicationMediaGenerator(factory);
			generator.mediaFactory == factory;
			var mediaElement:MediaElement = generator.createMediaElement(entry);			
		}
	}
}
