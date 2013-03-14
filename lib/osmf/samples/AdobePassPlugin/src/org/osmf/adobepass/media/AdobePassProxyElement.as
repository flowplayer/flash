package org.osmf.adobepass.media
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.osmf.adobepass.entitlement.AccessEnablerHelper;
	import org.osmf.adobepass.events.TokenEvent;
	import org.osmf.adobepass.events.TrackingEvent;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	/**
	 * The AdobePassProxyElement class is a wrapper for the media supplied.
	 * It's purpose is to block the play trait to
	 * allow the processing of TVE Entitlement
	 */
	public class AdobePassProxyElement extends ProxyElement
	{
		private var settings:Object;

		public function AdobePassProxyElement(proxied:MediaElement, settings:Object)
		{
			super(proxied);
			
			this.settings = settings;
			blockedTraits.push(MediaTraitType.PLAY);

			// If no parent is set, assume that the parrent is the display trait
			if (hasTrait(MediaTraitType.DISPLAY_OBJECT) || settings.parent)
			{
				initTVE();
			}
			else
			{
				// No display trait available yet, wait for one
				addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			}
		}

		private function onTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.DISPLAY_OBJECT)
			{
				// Found a display trait
				removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				initTVE();
			}
		}

		private function initTVE():void
		{
			var displayable:DisplayObject
					= (getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).displayObject;

			if (displayable.stage)
			{
				completeInitTVE(displayable.stage);
			}
			else
			{
				// stage not available yet for current display trait
				displayable.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		private function onAddedToStage(event:Event):void
		{
			// stage is available now, proceed with tve workflows
			event.target.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			completeInitTVE((event.target as DisplayObject).stage);
		}

		private function completeInitTVE(stage:Stage):void
		{
			settings.parent = stage;
			settings.size = new Point(stage.stageWidth, stage.stageHeight);
			
			_accessEnabler = AccessEnablerHelper.getInstance(settings);
			
			// Listen for authentication results
			_accessEnabler.addEventListener(TokenEvent.TOKEN_REQUEST_FAILED, onTokenFailed);
			_accessEnabler.addEventListener(TokenEvent.TOKEN_REQUEST_SUCCESS, onTokenSuccess);
			_accessEnabler.addEventListener(TrackingEvent.TRACKING, onTracking);
			
			// Start tve entitlement
			_accessEnabler.checkAccess();			
		}

		private function onTracking(event:TrackingEvent):void
		{
			var trackingMetadata:Metadata = new Metadata();
			trackingMetadata.addValue("type", event.trackingType);
			trackingMetadata.addValue("data", event.data);
			trackingMetadata.addValue("adobePass", event.trackingType + ":" + event.data.join());
			
			addMetadata("http://www.adobe.com/products/adobepass", trackingMetadata);
			resource.addMetadataValue("http://www.adobe.com/products/adobepass", trackingMetadata);
		}

		private function onTokenFailed(event:TokenEvent):void
		{
			dispatchEvent(event.clone());
		}

		private function onTokenSuccess(event:TokenEvent):void
		{
			// Unblock the play trait
			var playTraitIndex:int = blockedTraits.indexOf(MediaTraitType.PLAY);
			blockedTraits = blockedTraits.slice(playTraitIndex, playTraitIndex);

			dispatchEvent(event.clone());
		}

		private var _accessEnabler:AccessEnablerHelper;

	}
}