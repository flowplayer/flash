/***********************************************************
 * 
 * Copyright 2011 Adobe Systems Incorporated. All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/
package org.osmf.smpte.tt.media
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.containers.IMediaContainer;
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.TimelineMarker;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.smpte.tt.SMPTETTPluginInfo;
	import org.osmf.smpte.tt.architecture.creation.SMPTETTFactoryFacade;
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptioningDocument;
	import org.osmf.smpte.tt.captions.TimedTextElement;
	import org.osmf.smpte.tt.captions.TimedTextElementType;
	import org.osmf.smpte.tt.loader.SMPTETTLoadTrait;
	import org.osmf.smpte.tt.loader.SMPTETTLoader;
	import org.osmf.smpte.tt.timing.TimeExpression;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * The SMPTETTProxyElement class is a wrapper for the media supplied.
	 * It's purpose is to override the loadable trait to allow the retrieval and
	 * processing of an Timed Text file used for captioning.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class SMPTETTProxyElement extends ProxyElement
	{
		/**
		 * Constant for the MediaError that is triggered when the proxiedElement
		 * is invalid (e.g. doesn't have the captioning metadata).
		 **/ 
		public static const MEDIA_ERROR_INVALID_PROXIED_ELEMENT:int = 2201;
		
		public static const DEBUG:Boolean = false;
		
		/**
		 * Constructor.
		 * 
		 * @inheritDoc
		 * 
		 * @param continueLoadOnFailure Specifies whether or not the 
		 * class should continue the load process if the captioning
		 * document fails to load. The default value is <code>true</code>.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function SMPTETTProxyElement(proxiedElement:MediaElement=null, continueLoadOnFailure:Boolean=true)
		{			
			super(proxiedElement);
			_continueLoadOnFailure = continueLoadOnFailure;
		}
		
		
		/**
		 * The MediaElement for which this ProxyElement serves as a proxy.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}

		/**
		 * Specifies whether or not this class should continue loading
		 * the media element when the captioning document
		 * fails to load.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get continueLoadOnFailure():Boolean
		{
			return _continueLoadOnFailure;
		}
				
		/**
		 * @private
		 */
		override public function set proxiedElement(value:MediaElement):void
		{
			super.proxiedElement = value; 
						
			if (value != null)
			{				
				// Override the LoadTrait with our own custom LoadTrait,
				// which retrieves the Timed Text document, parses it, and sets up
				// the object model representing the caption data.
				
				// Store a reference to the original proxied MediaElement
				_mediaElement = super.proxiedElement;
				
				// Create a parallel element to hold the media and watermark image elements
				var parallelElement:ParallelElement = new ParallelElement();
							
				// Add the media element as a child of the parallel element
				parallelElement.addChild( mediaElement );
				
				// Set new parallelElement as the proxiedElement
				super.proxiedElement = parallelElement;
				
				// Get the mediaElement resource of the element that is wrapped.				
				var tempResource:MediaResourceBase = (mediaElement && mediaElement.resource != null) ? mediaElement.resource : resource;
				
				if (tempResource == null)
				{
					dispatchEvent(new MediaErrorEvent( MediaErrorEvent.MEDIA_ERROR, false, false, 
									new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
				}
				else
				{
					var metadata:Metadata = tempResource.getMetadataValue(SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE) as Metadata;
					
					if (metadata == null)
					{
						if (!_continueLoadOnFailure)
						{
							dispatchEvent(new MediaErrorEvent( MediaErrorEvent.MEDIA_ERROR, false, false, 
											new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
						} else
						{
							metadata = new Metadata();
							tempResource.addMetadataValue(SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE, metadata);
						}
					}
					
					// In order to respond to resize and scrub events, 
					// store a reference to the _mediaFactory, _mediaContainer and _mediaPlayer
					_mediaFactory = metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY) as MediaFactory;
					_mediaContainer = metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER) as IMediaContainer;
					_mediaPlayer = metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER) as MediaPlayer;
					
					// Get initial showCaptions value
					var showCaptions:* = metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS);
					if(showCaptions!==null && showCaptions is Boolean)
						captioningEnabled = showCaptions;
					
					// Get the SMPTE-TT url resource from the metadata of the element
					// that is wrapped.	
					var timedTextURL:String = metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI);
					
					// If the SMPTE-TT url resource exists, load the captions
					if (timedTextURL)
					{
						loadCaptions(timedTextURL);
					} 
					else if (!_continueLoadOnFailure)
					{	
						dispatchEvent(new MediaErrorEvent( MediaErrorEvent.MEDIA_ERROR, false, false, 
										new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
					}
					
					// Listen for traits to be added so we can add any desired event listeners on any
					// traits we care about.
					proxiedElement.addEventListener( MediaElementEvent.TRAIT_ADD, _onAddTrait, false, 0, true );
					proxiedElement.addEventListener( MediaElementEvent.TRAIT_REMOVE, _onRemoveTrait, false, 0, true );
					
					// Listen for metadata to be added so we can add any desired event listeners on any
					// metadata facets we care about.
					proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd, false, 0, true);
					
					// Listen for metadata to be removed so we can remove an event listener.
					proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove, false, 0, true);
					
					// Listen for metadata add change and remove events so that we can respond to changes
					// to the SMPTE-TT url and showCaptions
					metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdd, false, 0, true);
					metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange, false, 0, true);
					metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemove, false, 0, true);
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function get resource():MediaResourceBase
		{		
			return mediaElement ? mediaElement.resource : null;
		}
		
		/**
		 * @private
		 */		
		override public function set resource(value:MediaResourceBase):void
		{	
			if (mediaElement != null)
			{
				mediaElement.resource = value;
			}
		}
		
		/**
		 * @private
		 */
		protected function onMetadataValueAdd(event:MetadataEvent):void
		{
			debug(event.type+ " { "+event.key +", " +event.value+" } ");
			var metadata:Metadata = event.target as Metadata;
			switch(event.key)
			{
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY:
				{
					_mediaFactory = event.value as MediaFactory;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER:
				{
					_mediaContainer = event.value as MediaContainer;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER:
				{
					_mediaPlayer = event.value as MediaPlayer;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI:
				{
					proxiedElement.removeMetadata(SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE);
					var timedTextURL:String = event.value as String;
					if (timedTextURL)
					{ 
						loadCaptions(timedTextURL);
					}
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS:
				{
					captioningEnabled = Boolean(event.value);
					break;
				}
			}
			if (_queueLoad && _timedTextURL)
			{
				loadCaptions(_timedTextURL);
			}
		}
		
		/**
		 * @private
		 */
		protected function onMetadataValueChange(event:MetadataEvent):void
		{
			debug(event.type+ " { "+event.key +", " +event.value+" } ");
			var metadata:Metadata = event.target as Metadata;
			switch(event.key)
			{
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY:
				{
					_mediaFactory = event.value as MediaFactory;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER:
				{
					_mediaContainer = event.value as MediaContainer;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER:
				{
					_mediaPlayer = event.value as MediaPlayer;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI:
				{
					proxiedElement.removeMetadata(SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE);
					var timedTextURL:String = event.value as String;
					if (timedTextURL)
					{ 
						loadCaptions(timedTextURL);
					}
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS:
				{
					captioningEnabled = Boolean(event.value);
					break;
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function onMetadataValueRemove(event:MetadataEvent):void
		{
			//debug(event.type+ " { "+event.key +", " +event.value+" } ");
			var metadata:Metadata = event.target as Metadata;
			switch(event.key)
			{
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY:
				{
					_mediaFactory = null;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER:
				{
					_mediaContainer = null;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER:
				{
					_mediaPlayer = null;
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI:
				{
					proxiedElement.removeMetadata(SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE);
					break;
				}
				case SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS:
				{
					captioningEnabled = Boolean(event.value);
					break;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function loadCaptions(timedTextURL:String):void
		{
			var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
			
			if (!timeTrait || timeTrait.duration==0
				|| !_mediaPlayer
				|| !_mediaContainer
				|| !_mediaFactory)
			{
				debug("queueLoad of "+timedTextURL);
				_queueLoad = true;
				_timedTextURL = timedTextURL;
				return;
			}
			
			_queueLoad = false;
			_timedTextURL = null;
			
			debug( "loadCaptions(\""+timedTextURL+"\");");
			
			var smptettLoader:SMPTETTLoader = SMPTETTFactoryFacade.getSMPTETTLoader();
			var urlResource:URLResource = new URLResource(timedTextURL);
			
			
			if (_mediaPlayer)
			{
				// pauseMediaPlayerDuringLoadCaptions();
				updateEndTimetoMediaDuration(smptettLoader);
			}
			
			loadTrait = createLoadTrait(smptettLoader,urlResource);	
			addLoadTraitListeners(loadTrait);
			loadTrait.load();
			// addTrait(MediaTraitType.LOAD, loadTrait);
		}

		protected function pauseMediaPlayerDuringLoadCaptions():void
		{
			if(_mediaPlayer.canPause)
			{
				if (_mediaPlayer.playing) _wasPlaying = true;
				if (_mediaPlayer.paused) _wasPaused = true;
				_mediaPlayer.pause();
			}
		}

		protected function updateEndTimetoMediaDuration(smptettLoader:SMPTETTLoader):void
		{
			if(_mediaPlayer.duration)
			{
				TimeExpression.initializeParameters();
				smptettLoader.endTime = TimeExpression.parse(_mediaPlayer.duration+"s");
			}
		}

		protected function createLoadTrait(smptettLoader:SMPTETTLoader, urlResource:URLResource):SMPTETTLoadTrait
		{
			return new SMPTETTLoadTrait(smptettLoader, urlResource);
		}

		protected function addLoadTraitListeners(trait:SMPTETTLoadTrait):void
		{
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, int.MAX_VALUE, true);
		}
		
		/**
		 * @private
		 */
		protected function onLoadStateChange(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{				
				addMetaDataTimelineMarkers();
				cleanUp();
			}
			else if (event.loadState == LoadState.LOAD_ERROR)
			{
				onLoadStateChange_Error(event);
			}
		}


		protected function addMetaDataTimelineMarkers():void
		{
			var document:CaptioningDocument = loadTrait.document;
		
			// Create a TimelineMetadata object to associate
			// the captions with the media element.
			var SMPTETTMetadata:TimelineMetadata = getOrCreateTimelineMetaData();
			if (document) 
					addTimelineMarkers(document, SMPTETTMetadata);
		
			// cleanUp();
		}

		protected function getOrCreateTimelineMetaData():TimelineMetadata
		{
			var SMPTETTMetadata:TimelineMetadata = proxiedElement.getMetadata(SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
			if (SMPTETTMetadata == null)
			{
				SMPTETTMetadata = new TimelineMetadata(proxiedElement);
				proxiedElement.addMetadata(SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE, SMPTETTMetadata);
			}
			return SMPTETTMetadata;
		}


		protected function onLoadStateChange_Error(event:LoadEvent):void
		{
			if (!_continueLoadOnFailure)
			{
				dispatchEvent(event.clone());
			}
			else
			{
				cleanUp();
			}
		}
		
		
		/**
		 * @private
		 */
		private function cleanUp():void
		{	
			// Our work is done, remove the custom LoadTrait.  This will
			// expose the base LoadTrait, which we can then use to do
			// the actual load.
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
						
			if (loadTrait != null 
				&& loadTrait.loadState == LoadState.UNINITIALIZED)
				loadTrait.load();	
			
			if (_mediaPlayer && _mediaPlayer.canPlay)
			{
				
				if (_wasPlaying)
				{
					_mediaPlayer.play();
					_wasPlaying = false;
				} 
				else if (_wasPaused)
				{
					_mediaPlayer.pause();
					_wasPaused = false;
				}
				
				showNearestCaption(_mediaPlayer.currentTime);
			}		
		}
		
		protected var captionElementsDisplayed:Dictionary;
		protected var totalCaptionElementsToDisplay:uint = 0;
		
		/**
		 * @private
		 */
		protected function addTimelineMarkers(document:CaptioningDocument, 
											SMPTETTMetadata:TimelineMetadata):void
		{
			buildCaptioningMediaElement(document);
			
			addEachCaptionToMetaData(document,SMPTETTMetadata);
		}

		protected function addEachCaptionToMetaData(document:CaptioningDocument, SMPTETTMetadata:TimelineMetadata):void
		{
			for each(var c:CaptionElement in document.captionElements){
		
				if (c)
				{
					SMPTETTMetadata.addMarker(c);
					if (DEBUG) addCaptionElementToDisplay(c);
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function addCaptionElementToDisplay(captionElement:CaptionElement):void
		{
			if (!DEBUG) return;
			
			if (!captionElementsDisplayed)
			{ 
				captionElementsDisplayed = new Dictionary();
			}
			if (captionElement.captionElementType == TimedTextElementType.Text)
			{
				captionElementsDisplayed[captionElement] = {index:totalCaptionElementsToDisplay++, displayed:false};
			} else
			{
				var c:CaptionElement;
				for each(c in captionElement.children)
				{
					addCaptionElementToDisplay(c);
				}
				
				for each(c in captionElement.siblings)
				{
					addCaptionElementToDisplay(c);
				}
			}
		}
		
		protected function flagCaptionElementAsDisplayed(captionElement:CaptionElement):void
		{
			
			if (!DEBUG) return;
						
			if (captionElement.captionElementType == TimedTextElementType.Text 
				&& captionElementsDisplayed[captionElement]
				&& captionElementsDisplayed[captionElement].displayed == false)
			{
				captionElementsDisplayed[captionElement].displayed = true;
				debug((captionElementsDisplayed[captionElement].index)+" of "+(totalCaptionElementsToDisplay-1)+":\t"+captionElement.regionId+"\t"+TimeExpression.parse(captionElement.begin+"s")+"\t"+TimeExpression.parse(captionElement.end+"s")+"\t"+captionElement.content);
			} else
			{
				var c:CaptionElement;
				for each(c in captionElement.children)
				{
					flagCaptionElementAsDisplayed(c);
				}
				
				for each(c in captionElement.siblings)
				{
					flagCaptionElementAsDisplayed(c);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function buildCaptioningMediaElement(document:CaptioningDocument):void
		{
			if (captioningMediaElement) {return;}
			
			var mediaContainer:IMediaContainer = proxiedElement.container;
			
			if (!mediaContainer && _mediaContainer)  
				mediaContainer = _mediaContainer;
			
			var parallelElement:ParallelElement =  super.proxiedElement as ParallelElement;
			
			if (!captioningMediaElement)
				captioningMediaElement = new CaptioningMediaElement();
			
			captioningMediaElement.showCaptions = _captioningEnabled;
			
			if (parallelElement)
			{				
				addToParallelElement(parallelElement,captioningMediaElement);
				
				captioningMediaElement.mediaElement = mediaElement;
				
				var len:int = document.captionRegions.length
				for (var i:uint=0; i<len; i++)
				{
					regionSpriteAddMediaElement(document,i,captioningMediaElement);
				}
			}
		}

		protected function regionSpriteAddMediaElement(document:CaptioningDocument, i:uint, p_captioningMediaElement:CaptioningMediaElement):void
		{
			var region:RegionLayoutTargetSprite =
					p_captioningMediaElement.addRegion(document.captionRegions[i]);				
			region.mediaElement = mediaElement;
		}


		protected function addToParallelElement(parallelElement:ParallelElement, p_captioningMediaElement:CaptioningMediaElement):void
		{
			parallelElement.addChild(p_captioningMediaElement);
		}

		
		/**
		 * @private
		 */		
		private function onShowCaption(event:TimelineMetadataEvent):void
		{
			var captionElement:CaptionElement = event.marker as CaptionElement;
			var ns:String = _namespaces[event.currentTarget];
			
			// Make sure this is a caption object, and just for good measure, 
			// we'll also check the namespace				
			if (captionElement != null 
				&& ns == SMPTETTPluginInfo.SMPTETT_TEMPORAL_METADATA_NAMESPACE)
			{
				_currentCaption = captionElement;
				captioningMediaElement.addCaption(captionElement);
				
				if (DEBUG) flagCaptionElementAsDisplayed(captionElement);
				
				// Start the _currentPositionTimer to monitor playhead position.
				if(_currentPositionTimer 
					&& (_seeked
						|| hasDescendantMarkerEvents(TimedTextElement(captionElement))))
				{
					_currentPositionTimer.delay = CURRENT_POSITION_UPDATE_INTERVAL;
					_currentPositionTimer.start();
				}
			}
		}
		
		/**
		 * @private
		 */	
		private function hasDescendantMarkerEvents(timedTextElement:TimedTextElement):Boolean
		{
			var bool:Boolean = false;
			var t:TimedTextElement;
			for each(t in timedTextElement.animations)
			{
				if(t.begin != timedTextElement.begin || t.end != timedTextElement.end)
				{
					return true;
				}
			}
			for each(t in timedTextElement.children)
			{
				if(t.begin != timedTextElement.begin || t.end != timedTextElement.end)
				{
					return true;
				} else 
				{
					bool = hasDescendantMarkerEvents(t);
				}
			}	
			for each(t in timedTextElement.siblings)
			{
				if(t.begin != timedTextElement.begin || t.end != timedTextElement.end)
				{
					return true;
				} else 
				{
					bool = hasDescendantMarkerEvents(t);
				}
			}
			var captionElement:CaptionElement = timedTextElement as CaptionElement;
			if(captionElement)
			{
				var regionLayoutTargetSprite:RegionLayoutTargetSprite = captioningMediaElement.getRegionById(captionElement.regionId);
				if(regionLayoutTargetSprite && regionLayoutTargetSprite.captionRegion.animations.length>0)
				{
					return true;
				}
			}
			return bool;
		}
		
		/**
		 * @private
		 */		
		private function onHideCaption(event:TimelineMetadataEvent):void
		{
			var captionElement:CaptionElement = event.marker as CaptionElement;

			if (_currentCaption 
				&& _currentCaption.time == captionElement.time)
			{
				 clearCaptionElement(captionElement);
				 _currentCaption = null;
			}
		}
		
		/**
		 * @private
		 */	
		private function clearCaptionElement(captionElement:CaptionElement):void
		{
			if (captioningMediaElement)
			{
				captioningMediaElement.removeCaption(captionElement);
			
				if(_currentPositionTimer)
				{
					_currentPositionTimer.stop();
					captioningMediaElement.validateCaptions();
				}
			}
		}
		
		/**
		 * @private
		 */	
		private function clearCaptionText():void
		{
			if (captioningMediaElement && _currentCaption)
			{
				clearCaptionElement(_currentCaption);
				_currentCaption = null;
			}
		}
		
		/**
		 * @private
		 */
		private function onMetadataAdd(event:MediaElementEvent):void
		{
			var metadata:TimelineMetadata = event.metadata as TimelineMetadata;
			
			if (metadata)
			{
				debug(">>> Timeline metadata added to "+event.target+", namespace="+event.namespaceURL+" "+event.metadata);
				_namespaces[metadata] = event.namespaceURL;
				_timelineMetadata = metadata;
				_timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onShowCaption, false, 0, true);
				_timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onHideCaption, false, 0, true);
			} 
			else
			{
				debug(">>> Other metadata added to "+event.target+", namespace="+event.namespaceURL+" "+event.metadata);
				mediaElement.addMetadata(event.namespaceURL, event.metadata);	
			}
		}
		
		/**
		 * @private
		 */
		private function onMetadataRemove(event:MediaElementEvent):void
		{
			var metadata:TimelineMetadata = event.metadata as TimelineMetadata;
			
			if (metadata && _timelineMetadata)
			{
				debug(">>> Timeline metadata removed from "+event.target+", namespace="+event.namespaceURL);
				delete _namespaces[metadata];
				_timelineMetadata.removeEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onShowCaption);
				_timelineMetadata.removeEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onHideCaption);
				_timelineMetadata = null;
			}
			else
			{
				debug(">>> Other metadata removed from "+event.target+", namespace=" + event.namespaceURL + " " + event.metadata);
				mediaElement.removeMetadata(event.namespaceURL);
			}
		}
		
		/**
		 * @private
		 */
		private function onPlayStateChange(event:PlayEvent):void
		{
			debug(event.target + " onPlayStateChange: " + event.playState);
			if (!captioningMediaElement) return;
			if (event.playState != PlayState.PLAYING)
			{
				if (_wasPlaying) _wasPlaying = false;
				_currentPositionTimer.stop();
				captioningMediaElement.validateCaptions();
			} 
			else if (event.playState != PlayState.PAUSED)
			{
				if (_wasPaused) _wasPaused = false;
			}
		}
		
		/**
		 * @private
		 */
		private function onDisplayObjectChange(event:DisplayObjectEvent):void
		{
			debug(event.target + " onDisplayObjectChange: " + event.newDisplayObject);
		}
		
		/**
		 * @private
		 */
		private function onMediaSizeChange(event:DisplayObjectEvent):void
		{			
			var dot:DisplayObjectTrait = _mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			
			if (!dot) return;
			
			debug(dot+" "+ dot.displayObject + " onMediaSizeChange: {mediaWidth:"+dot.mediaWidth+", mediaHeight:"+dot.mediaHeight+"}");

			if (captioningMediaElement 
				&& !isNaN(dot.mediaWidth) 
				&& !isNaN(dot.mediaHeight)
				&& dot.mediaWidth
				&& dot.mediaHeight)
				captioningMediaElement.setIntrinsicDimensions(dot.mediaWidth, dot.mediaHeight);
		}
		
		/**
		 * @private
		 */
		private function onSeekingChange(event:SeekEvent):void
		{
			// debug(event.target + " onSeekingChange: " + event.seeking);
			_currentPositionTimer.stop();
			_seeked = true;
			if (event.seeking) 
				clearCaptionText();
			showNearestCaption(event.time);
			_seeked = false;
		}
		
		private function findNearestCaption(time:Number):CaptionElement
		{
			if (!_timelineMetadata) return null;
			var i:int = 0;
			var toShow:CaptionElement;
			var	captionElement:CaptionElement;
			while (i<_timelineMetadata.numMarkers)
			{
				captionElement = _timelineMetadata.getMarkerAt(i) as CaptionElement;
				if (captionElement.isActiveAtPosition(time,true))
				{
					toShow = captionElement;
				} else if (toShow
						 &&	time>captionElement.end 
						 && captionElement.end<toShow.end)
				{
					toShow = null;
				}
				i++;
			}
			return toShow;
		}
		
		/**
		 * @private
		 */
		protected function showNearestCaption(time:Number):void
		{
			var toShow:CaptionElement = findNearestCaption(time);
			if (toShow)
				_timelineMetadata.dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_TIME_REACHED, false, false, toShow as TimelineMarker));
		}
		
		/**
		 * @private
		 */
		private function onTimerTick(event:TimerEvent=null):void
		{
			if (captioningMediaElement)
				captioningMediaElement.validateCaptions();
		}
		
		/**
		 * @private
		 */
		protected function _onAddTrait( event:MediaElementEvent ):void
		{
			debug( "Add: " + event.target +" "+event.traitType );
			var trait:MediaTraitBase;
						
			switch( event.traitType )
			{
				case MediaTraitType.PLAY:
				{
					var pTrait:PlayTrait = proxiedElement.getTrait( MediaTraitType.PLAY) as PlayTrait;
					pTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange, false, 0, true);
					break;
				}
				case MediaTraitType.DISPLAY_OBJECT:
				{
					var doTrait:DisplayObjectTrait = proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
					doTrait.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange, false, 0, true);
					doTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange, false, 0, true);
					
					doTrait.displayObject.addEventListener(Event.ADDED_TO_STAGE, onDisplayObjectAddedToStage, false, 0, true);
					break;
				}
				case MediaTraitType.SEEK:
				{
					var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
					seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange, false, 0, true);
					break;
				}
				case MediaTraitType.TIME:
				{
					var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
					if (_queueLoad && _timedTextURL)
					{
						loadCaptions(_timedTextURL);
					}
					if(!_currentPositionTimer)
					{
						_currentPositionTimer = new Timer(CURRENT_POSITION_UPDATE_INTERVAL);
						_currentPositionTimer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
					}	
					break;
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function _onRemoveTrait( event:MediaElementEvent ):void
		{
			debug( "Remove: " + event.target +" " + event.traitType );
			var trait:MediaTraitBase;
			
			switch( event.traitType )
			{
				case MediaTraitType.PLAY:
				{
					var pTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
					pTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
					break;
				}
				case MediaTraitType.DISPLAY_OBJECT:
				{
					var doTrait:DisplayObjectTrait = proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
					doTrait.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
					doTrait.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
					if (captioningMediaElement)
						captioningMediaElement.clear();
					break;
				}
				case MediaTraitType.SEEK:
				{
					var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
					seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
					break;
				}
				case MediaTraitType.TIME:
				{
					var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
					
					if (_currentPositionTimer)
					{
						_currentPositionTimer.delay = CURRENT_POSITION_UPDATE_INTERVAL;
						_currentPositionTimer.stop();
						_currentPositionTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
						_currentPositionTimer = null;
					}
					break;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function onDisplayObjectAddedToStage(event:Event):void
		{
			event.target.removeEventListener(Event.ADDED_TO_STAGE, onDisplayObjectAddedToStage);
			
			CURRENT_POSITION_UPDATE_INTERVAL = Math.round(4000 / DisplayObject(event.target).stage.frameRate);
			
			if (_currentPositionTimer)
				_currentPositionTimer.delay = CURRENT_POSITION_UPDATE_INTERVAL;
		}
		
		/**
		 * @private
		 */
		private function get captioningEnabled():Boolean
		{
			return _captioningEnabled;
		}
		
		/**
		 * @private
		 */
		private function set captioningEnabled(value:Boolean):void
		{
			_captioningEnabled = value;
			if (captioningMediaElement)
				captioningMediaElement.showCaptions = Boolean(value);
		}
		
		/**
		 * @private
		 */
		private function debug(msg:String):void
		{
			if (DEBUG)
			{
				trace(msg);
				if (ExternalInterface.available)
					ExternalInterface.call("function(msg){ if (console && console.log) console.log(msg); }",msg);
			}
		}
		
		protected var loadTrait:SMPTETTLoadTrait;
		private var _continueLoadOnFailure:Boolean;
		private var _mediaElement:MediaElement;
		private var captioningMediaElement:CaptioningMediaElement;
		private var _seeked:Boolean = false;
		private var _currentPositionTimer:Timer;
		private var _captioningEnabled:Boolean = true;
		private var _timelineMetadata:TimelineMetadata;
		private var _currentCaption:CaptionElement;	
		private var _namespaces:Dictionary = new Dictionary();
		private var _mediaContainer:IMediaContainer;
		protected var _mediaPlayer:MediaPlayer;
		private var _mediaFactory:MediaFactory;
		protected var _wasPlaying:Boolean = false;
		protected var _wasPaused:Boolean = false;
		private var _queueLoad:Boolean = false;
		private var _timedTextURL:String;
				
		private static const ERROR_MISSING_TTML_METADATA:String = "Media Element is missing TTML metadata";
		private static const ERROR_MISSING_RESOURCE:String = "Media Element is missing a valid resource";
		private static var CURRENT_POSITION_UPDATE_INTERVAL:int = 250;
	}
}
