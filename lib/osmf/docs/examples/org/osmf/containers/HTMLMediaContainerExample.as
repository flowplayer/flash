package
{
	import flash.display.Sprite;
	
	import org.osmf.elements.HTMLElement;
	import org.osmf.media.URLResource;

	public class HTMLMediaContainerExample extends Sprite
	{
		public function HTMLMediaContainerExample()
		{
			super();
			
			// This will invoke a JavaScript callback (onHTMLMediaContainerConstructed(container))
			// that may be used to add listeners to new elements being added or removed to the 
			// container.
			var container:HTMLMediaContainer = new HTMLMediaContainer();
			
			var element:HTMLElement = new HTMLElement();
			element.resource = new URLResource("http://example.com/an/asset/JS/will/handle.pgn");
			
			// This will invoke a JavaScript callback (container.onElementAdd(element)) that
			// allows JavaScript to process the passed URL, and to communicate back to the 
			// framework what traits the element will support:
			container.addMediaElement(element);
		}
		
	}
}