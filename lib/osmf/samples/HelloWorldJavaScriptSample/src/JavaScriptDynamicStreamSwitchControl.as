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
*****************************************************/
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.F4MElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.traits.LoadState;

	/**
	 * JavaScriptDynamicStreamSwitchControl
	 **/
	public class JavaScriptDynamicStreamSwitchControl extends Sprite
	{
		public function JavaScriptDynamicStreamSwitchControl()
		{	
 			sprite = new MediaPlayerSprite();
			initialIndex = 4;
			maxIndex = 5;
			preloadF4MFile("http://zeridemo-f.akamaihd.net/content/inoutedit-mbr/inoutedit_h264_3000.f4m");
		}		
		
		/**
		 * Preload a f4m file so that we can set the initialIndex and the maxIndex on the DynamicStreamingResource.
		 */ 
		private function preloadF4MFile(F4MURL:String):void
		{
			var resource:URLResource = new URLResource(F4MURL);		
			var spriteTemp:MediaPlayerSprite = new MediaPlayerSprite();
			spriteTemp.mediaPlayer.autoPlay = false; 
			spriteTemp.mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange); 
			spriteTemp.resource = resource;
			
			function onDurationChange(event:Event):void 
			{ 
				// At this point the F4M file is fully loaded
				(event.target as MediaPlayer).removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange); 
				var resource:DynamicStreamingResource = (spriteTemp.media as F4MElement).proxiedElement.resource as DynamicStreamingResource;				
				playDynamicStreamingResource(resource);
			}
		}		
		
		private function playDynamicStreamingResource(resource:DynamicStreamingResource):void
		{
			resource.initialIndex = initialIndex; 
			
			sprite.mediaPlayer.maxAllowedDynamicStreamIndex = maxIndex;
			sprite.resource = resource; 			
			
			addChild(sprite); 
			
			if (ExternalInterface.available)
			{				
				// Register the javascript callback function
				ExternalInterface.addCallback("getAutoDynamicStreamSwitch", getAutoDynamicStreamSwitch);
				ExternalInterface.addCallback("setAutoDynamicStreamSwitch", setAutoDynamicStreamSwitch);
				ExternalInterface.addCallback("switchDynamicStreamIndex", switchDynamicStreamIndex);
				
				ExternalInterface.addCallback("getStreamItems", getStreamItems);
				ExternalInterface.addCallback("getCurrentDynamicStreamIndex", getCurrentDynamicStreamIndex);
				
				// Register the addEventListener callback function - will be used for re-routing events to 
				// the javascript layer.
				ExternalInterface.addCallback("addEventListener", javascriptAddEventListener);
				
				// Notify the hosting page that the player is ready to be controlled
				var callbackFunction:String = 
					"function(objectID) {" +
					"  if (typeof onHelloWorldJavaScriptLoaded == 'function') { " +
					"    onHelloWorldJavaScriptLoaded(objectID); " +
					"  } " +
					"} ";
				ExternalInterface.call(callbackFunction, ExternalInterface.objectID);
			}
		}
		
		/**
		 * Adds an event listener to the media player.
		 */ 
		private function javascriptAddEventListener(eventName:String, callbackFunctionName:String):void
		{
			sprite.mediaPlayer.addEventListener(eventName,
				function(event:Event):void
				{			
					ExternalInterface.call(callbackFunctionName, ExternalInterface.objectID);				
				}
			);		
		}
		
		private function getAutoDynamicStreamSwitch():Boolean
		{
			return sprite.mediaPlayer.autoDynamicStreamSwitch;
		}
		
		private function setAutoDynamicStreamSwitch(value:Boolean):void
		{
			sprite.mediaPlayer.autoDynamicStreamSwitch = value;
		}
		
		private function switchDynamicStreamIndex(streamIndex:int):void
		{
			 sprite.mediaPlayer.switchDynamicStreamIndex(streamIndex);
		}
		
		private function getCurrentDynamicStreamIndex():int
		{
			return sprite.mediaPlayer.currentDynamicStreamIndex;
		}		
		
		private function getStreamItems():Vector.<DynamicStreamingItem>
		{
			var streamItems:Vector.<DynamicStreamingItem> = 
				(sprite.resource as DynamicStreamingResource).streamItems;
			return streamItems;
		}
	
		private var initialIndex:int;
		private var maxIndex:int;
		
		private var sprite:MediaPlayerSprite;	
	}
}
