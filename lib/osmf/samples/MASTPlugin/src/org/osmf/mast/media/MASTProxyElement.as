/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*  Contributor(s): Akamai Technologies
*                  Eyewonder, LLC
* 
******************************************************/
package org.osmf.mast.media
{
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.mast.MASTPluginInfo;
	import org.osmf.mast.loader.MASTDocumentProcessedEvent;
	import org.osmf.mast.loader.MASTDocumentProcessor;
	import org.osmf.mast.loader.MASTLoadTrait;
	import org.osmf.mast.loader.MASTLoader;
	import org.osmf.mast.managers.MASTConditionManager;
	import org.osmf.mast.model.*;
	import org.osmf.mast.traits.MASTPlayTrait;
	import org.osmf.mast.types.MASTConditionType;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.vast.media.CompanionElement;
	import org.osmf.vast.media.VASTTrackingProxyElement;
	import org.osmf.vast.metadata.VASTMetadata;
	import org.osmf.vpaid.elements.VPAIDElement;
	import org.osmf.vpaid.metadata.VPAIDMetadata;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	import org.osmf.logging.Log;
	}
	
	/**
	 * The MASTProxyElement class is a wrapper for the media supplied.
	 * It's purpose is to override the loadable and playable traits to 
	 * allow the processing of a MAST document and to insert the media
	 * elements found in the MAST payload.
	 */
	public class MASTProxyElement extends ProxyElement
	{		
		/**
		 * Constructor.
		 * 
		 * @param proxiedElement The MediaElement to proxy.
		 * @param mediaFactory Optional MediaFactory.  If specified, then all
		 * MediaElements will be created through the factory.  If not specified,
		 * then all MediaElements will be directly instantiated. 
		 **/
		public function MASTProxyElement(proxiedElement:MediaElement=null, mediaFactory:MediaFactory=null)
		{
			super(proxiedElement);
			
			this.mediaFactory = mediaFactory;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set proxiedElement(value:MediaElement):void
		{
			var serialElement:SerialElement;
			
			if (value != null &&
				!(value is SerialElement))
			{
				// Wrap any child in a SerialElement.
				serialElement = new SerialElement();
				serialElement.addChild(value);
				
				value = serialElement;
			}
			
			super.proxiedElement = value;
			
			if (value != null)
			{
				// Override the LoadTrait with our own custom LoadTrait,
				// which retrieves the MAST document, parses it, and sets up
				// the triggers in relation to our wrapped MediaElement.
				//
				
				// Get the MAST url resource from the metadata of the element
				// that is wrapped.
				serialElement = super.proxiedElement as SerialElement;
				var mediaElement:MediaElement = serialElement.getChildAt(0);
				
				var tempResource:MediaResourceBase = (mediaElement && mediaElement.resource != null) ? mediaElement.resource : resource;
				if (tempResource == null)
				{
					throw new IllegalOperationError(ERROR_MISSING_RESOURCE);
				}
				
				var metadata:Metadata = tempResource.getMetadataValue(MASTPluginInfo.MAST_METADATA_NAMESPACE) as Metadata;
				if (metadata == null)
				{
					throw new IllegalOperationError(ERROR_MISSING_MAST_METADATA);
				}			
				
				var mastURL:String = metadata.getValue(MASTPluginInfo.MAST_METADATA_KEY_URI);
				
				loadTrait = new MASTLoadTrait(new MASTLoader(), new URLResource(mastURL));
				
				loadTrait.addEventListener
					( LoadEvent.LOAD_STATE_CHANGE
					, onLoadStateChange
					);
				
				addTrait(MediaTraitType.LOAD, loadTrait); 
				
				// Override the PlayTrait so we can do any necessary
				// pre-processing, such as a payload that would cause a 
				// pre-roll.
				
				var playTrait:PlayTrait = new MASTPlayTrait();
				addTrait(MediaTraitType.PLAY, playTrait);
			}
		}
		
		private function removeCustomPlayTrait():void
		{
			var playTrait:MASTPlayTrait = this.getTrait(MediaTraitType.PLAY) as MASTPlayTrait;
			
			if (playTrait)
			{
				removeTrait(MediaTraitType.PLAY);
				
				if (playTrait.playRequestPending)
				{
					// Call play on the original trait
					var orgPlayTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
					
					if (orgPlayTrait == null)
					{
						// Trait is not present yet, we need to wait for it to be added
						addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
					}
					else
					{
						
						orgPlayTrait.play();
					}
				}	
			}
		}
			
		private function onTraitAdd(event:MediaElementEvent):void
		{
			removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			if (event.traitType == MediaTraitType.PLAY)
			{
				var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
				playTrait.play();
			}
		}
				
		private function onLoadStateChange(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY)
			{
				var processor:MASTDocumentProcessor = new MASTDocumentProcessor(mediaFactory);
				processor.addEventListener(MASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed, false, 0, true);
				var mediaElement:MediaElement = (proxiedElement as SerialElement).getChildAt(0);
				
				var causesPendingPlayRequest:Boolean = processor.processDocument(loadTrait.document, mediaElement);

				// If there was no condition that causes a pending play request
				// remove the custom IPlayable
				if (!causesPendingPlayRequest)
				{
					removeCustomPlayTrait();
				}

				// Our work is done, remove the custom ILoadable.  This will
				// expose the base ILoadable, which we can then use to do
				// the actual load.
				removeTrait(MediaTraitType.LOAD);
				var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
				if (loadTrait)
				{
					loadTrait.load();
				}
			}
			else if (event.loadState == LoadState.LOAD_ERROR)
			{
				dispatchEvent(event.clone());
			}
		}
		
		private function onDocumentProcessed(event:MASTDocumentProcessedEvent):void
		{
			var serialElement:SerialElement = proxiedElement as SerialElement;
			var parellelElement:ParallelElement;
			// Each inline element needs to be inserted into the location that
			// will cause it to be the current (or next) item.
			for each (var inlineElement:MediaElement in event.inlineElements)
			{
				var insertionIndex:int = getInsertionIndex(serialElement, event.condition);
				var tempMediaElement:MediaElement = null;
				
				var nonlinear:Boolean;
				var mediaElement:MediaElement;
				if (inlineElement is VASTTrackingProxyElement)
				{
					mediaElement = ProxyElement(ProxyElement(inlineElement).proxiedElement).proxiedElement;		
				}	
							
				//Check to see if we have a nonlinear VPAIDElemet
				if(mediaElement is VPAIDElement)
				{
					
					nonlinear = mediaElement.getMetadata(VPAIDMetadata.NAMESPACE).getValue(VPAIDMetadata.NON_LINEAR_CREATIVE);
					// Quick solution to pass mast container info over to VPAIDElement. There may be a better way (metadata maybe?)
					try{
						if ((mediaElement as VPAIDElement).MASTWidth == -1)
						{
							(mediaElement as VPAIDElement).MASTWidth = container["width"];
							(mediaElement as VPAIDElement).MASTHeight = container["height"];
						}
					}
					catch(error:Error) {}
				}
				if(nonlinear)
				{
					//Currently we support running only 1 nonlinear Ad per ad call.
					if (insertionIndex == 0)
					{
						//store content video element
						tempMediaElement = serialElement.getChildAt(0);
													
						parellelElement = new ParallelElement();				
						parellelElement.addChild(tempMediaElement);	
						parellelElement.addChild(mediaElement);
														
						//serialElement.addChild(parellelElement);
					}
				}else{
					
					var companionElement:Boolean = inlineElement is CompanionElement;
					if(!companionElement)
					{
						// If we are inserting at zero, we need to remove the original and then
						// add it again to force SerialElement to update it's listening index
						if (insertionIndex == 0)
						{
							tempMediaElement = serialElement.removeChildAt(0);
						}
						
						if (!(mediaElement is VPAIDElement))
						{
							mediaContainer = container as MediaContainer;
							mediaContainer.buttonMode = true;
							mediaContainer.addEventListener(MouseEvent.MOUSE_UP, onContainerClick);
							
							if(mediaElement is VideoElement)
							{
								
								if(mediaElement.hasTrait(MediaTraitType.TIME))
								{
									
									var timeTrait:TimeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
									timeTrait.addEventListener(TimeEvent.COMPLETE, onTimeComplete);
									
								}
							}	

					
						}
						serialElement.addChildAt(inlineElement, insertionIndex);
						
						if (tempMediaElement != null)
						{
							serialElement.addChild(tempMediaElement);
						}
					}
				}
				//Currently we support running only 1 nonlinear Ad per ad call.  There are sizing issues with adding multiple 
				//parallel elements to a serial element that need to be resolved. Future revisions will allow running multiple nonlinear Ads
				if(parellelElement)
				{
					super.proxiedElement = parellelElement;
				}
				
				
			}
			// Now we can remove the custom PlayTrait
			this.removeCustomPlayTrait();
		}
		
		private function onTimeComplete(e:TimeEvent):void
		{
			
			mediaContainer.buttonMode = false;
			mediaContainer.removeEventListener(MouseEvent.MOUSE_UP, onContainerClick);
		}	
		
		private function onContainerClick(event:MouseEvent):void
		{
			var vastMetadata:Metadata = proxiedElement.getMetadata(VASTMetadata.NAMESPACE);
			if(vastMetadata)
				vastMetadata.addValue(VASTMetadata.CLICKTHRU, event);
		}
		
		private function getInsertionIndex(serialElement:SerialElement, condition:MASTCondition):int
		{
			// Generally, the insertion index is the index of the current
			// child, so that the inserted child becomes the new current child.
			var index:int = 0;
			
			if ((condition.type == MASTConditionType.EVENT) && (MASTConditionManager.conditionIsPostRoll(condition)))
			{
				index++;
			}
			else
			{	
				// However, if our current child is in the midst of playback, we
				// don't want to interrupt it, so we insert immediately after the
				// current child.
				var currentChild:MediaElement = serialElement.getChildAt(index);
				if (currentChild != null)
				{
					// Treat it as playing if it's playing or has a positive currentTime.
					var timeTrait:TimeTrait = currentChild.getTrait(MediaTraitType.TIME) as TimeTrait;
					if (timeTrait != null && timeTrait.currentTime > 0)
					{
						index++;
					}
					else
					{
						var playTrait:PlayTrait = currentChild.getTrait(MediaTraitType.PLAY) as PlayTrait;
						if (playTrait != null && playTrait.playState == PlayState.PLAYING)
						{
							index++;
						}
					}
				}
			}
			
			CONFIG::LOGGING
			{
				logger.debug("MASTProxyElement - getInsertionIndex() about to return "+index);
			}
			return index;
		}
		
		private var loadTrait:MASTLoadTrait;
		private var mediaFactory:MediaFactory;
		private var mediaContainer:MediaContainer;
		private static const ERROR_MISSING_MAST_METADATA:String = "Media Element is missing MAST metadata";
		private static const ERROR_MISSING_RESOURCE:String = "Media Element is missing a valid resource";
		
		CONFIG::LOGGING
		private static const logger:Logger = Log.getLogger("org.osmf.mast.media.MASTProxyElement");			
		
	}
}
