package org.osmf.smpte.tt.media
{
	import org.osmf.elements.ParallelElement;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.events.ParseEvent;
	import org.osmf.smpte.tt.loader.SMPTETTLoadTrait;
	
	public class SMPTETTProxyElementAsync extends SMPTETTProxyElement
	{
		public function SMPTETTProxyElementAsync(proxiedElement:MediaElement=null, continueLoadOnFailure:Boolean=true)
		{
			super(proxiedElement, continueLoadOnFailure);
		}
		
		override protected function addToParallelElement(parallelElement:ParallelElement, p_captioningMediaElement:CaptioningMediaElement):void
		{
			/*
			Ensure that the value that we are adding is not already part of the element, 
			otherwise you will get an RTE. 
			
			This was a more relevant check it the first iteration, when all of the captions
			were added at each ParseEvent.PARTIAL event. 
			
			Subsequently, it *should* only be adding the new elements, but the check still seems worthwhile
			*/
			if (parallelElement.getChildIndex(p_captioningMediaElement) == -1)
			{
				parallelElement.addChild(p_captioningMediaElement);
			}
		}
		
		/*
		Initially, CaptioningMediaElement could return a null RegionLayoutTargetSprite.
		It has been fixed, but a null value is still possible
		*/
		override protected function regionSpriteAddMediaElement(document:CaptioningDocument, i:uint, p_captioningMediaElement:CaptioningMediaElement):void
		{
			var region:RegionLayoutTargetSprite =
				p_captioningMediaElement.addRegion(document.captionRegions[i]);				
			if (region)
			{
				region.mediaElement = mediaElement;
			}
			else
			{
				trace ("regionSpriteAddMediaElement failed " + i);
			}
		}
		
		
		
		override protected function addLoadTraitListeners(trait:SMPTETTLoadTrait):void
		{
			super.addLoadTraitListeners(trait);
			trait.addEventListener(ParseEvent.BEGIN, onParseEvent, false, 0, true);
			trait.addEventListener(ParseEvent.PROGRESS, onParseEvent, false, 0, true);
			trait.addEventListener(ParseEvent.PARTIAL, onParseEvent, false, 0, true);
			trait.addEventListener(ParseEvent.COMPLETE, onParseEvent, false, 0, true);
		}
		
		protected function onParseEvent(e:ParseEvent):void
		{
			switch(e.type)
			{
				case ParseEvent.PARTIAL:
					onPartialLoad(e);
					break;
			}
			dispatchEvent(e);
		}

		protected function onPartialLoad(e:ParseEvent):void
		{
			addMetaDataTimelineMarkers();
			
			//Make sure on partial loading of captions, we quickly get to the nearest one
			if (_mediaPlayer)
			{	
				if (_wasPlaying)
				{
					_mediaPlayer.play();
					_wasPlaying = false;
				}
				else if (_wasPaused && _mediaPlayer.playing)
				{
					_wasPaused = false;
				}
				showNearestCaption(_mediaPlayer.currentTime);
			}
		}
		
		
		/*
		Instead of building up a full list of captions, the captions are now removed from the array as they are being
		processed through each ParseEvent.PARTIAL event.
		*/
		override protected function addEachCaptionToMetaData(document:CaptioningDocument, SMPTETTMetadata:TimelineMetadata):void
		{
			if (document.captionElements)
			{
				var captionElements:Vector.<CaptionElement> = document.captionElements;
				var c:CaptionElement;
				var i:uint;
				var startAt:int = Math.max(0,SMPTETTMetadata.numMarkers-1);
				for (i=startAt; i<document.numTimelineMarkerEvents; i++)
				{
					c = captionElements[i];
					if (c)
					{
						SMPTETTMetadata.addMarker(c);
						if (SMPTETTProxyElement.DEBUG) addCaptionElementToDisplay(c);
					}
				}
			}
		}

	}
}