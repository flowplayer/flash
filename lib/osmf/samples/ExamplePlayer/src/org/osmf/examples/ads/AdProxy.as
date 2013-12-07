/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.examples.ads
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;

	public class AdProxy extends ProxyElement
	{
		public function AdProxy(proxiedElement:MediaElement=null)
		{
			displayObject = new Sprite();
			
			var format:TextFormat = new TextFormat("Verdana", 30, 0xffffff);
			format.align = TextFormatAlign.CENTER;
			format.font = "Verdana";
			
			label = new TextField();
			label.defaultTextFormat = format;
			
			displayObject.addChild(label);
			outerViewable = new AdProxyDisplayObjectTrait(displayObject);
			
			proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
			proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);
			
			super(proxiedElement);
			
			var traitsToBlock:Vector.<String> = new Vector.<String>();
			traitsToBlock[0] = MediaTraitType.SEEK;
			traitsToBlock[1] = MediaTraitType.TIME;
			
			blockedTraits = traitsToBlock;
			
			var timer:Timer = new Timer(300);
			timer.addEventListener(TimerEvent.TIMER, onTimerTick);
			timer.start();
		}
				
		private function onProxiedTraitsChange(event:MediaElementEvent):void
		{
			if (event.type == MediaElementEvent.TRAIT_ADD)
			{
				if (event.traitType == MediaTraitType.DISPLAY_OBJECT)
				{
					innerViewable = DisplayObjectTrait(proxiedElement.getTrait(event.traitType));
					if (_innerViewable)
					{
						addTrait(MediaTraitType.DISPLAY_OBJECT, outerViewable);
					}
				}
			}
			else
			{
				if (event.traitType == MediaTraitType.DISPLAY_OBJECT)
				{
					innerViewable = null;
					removeTrait(MediaTraitType.DISPLAY_OBJECT);
				}
			}
		}
		
		private function set innerViewable(value:DisplayObjectTrait):void
		{
			if (_innerViewable != value)
			{
				if (_innerViewable)
				{
					_innerViewable.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
					_innerViewable.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
				}
				
				_innerViewable = value;
				
				if (_innerViewable)
				{
					_innerViewable.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
					_innerViewable.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
				}
				
				updateView();
			}
		}
		
		private function onInnerDisplayObjectChange(event:DisplayObjectEvent):void
		{
			updateView();
		}
		
		private function onInnerMediaSizeChange(event:DisplayObjectEvent):void
		{
			outerViewable.setSize(event.newWidth, event.newHeight);
			
			label.width = event.newWidth;
		}
		
		private function updateView():void
		{
			if 	(	_innerViewable == null
				||	_innerViewable.displayObject == null
				||	displayObject.contains(_innerViewable.displayObject) == false
				)
			{
				if (displayObject.numChildren == 2)
				{
					displayObject.removeChildAt(0);
				}
				label.visible = false;
			}
			
			if	(	_innerViewable != null
				&&	_innerViewable.displayObject != null
				&&	displayObject.contains(_innerViewable.displayObject) == false
				)
			{
				displayObject.addChildAt(_innerViewable.displayObject, 0);
				label.visible = true;
			}
			
		}
		
		private function onTimerTick(event:TimerEvent):void
		{
			var labelText:String = "";
			if (proxiedElement != null)
			{
				var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait
				if (timeTrait && timeTrait.duration && (timeTrait.duration - timeTrait.currentTime) > 0.9)
				{
					labelText = "[ Advertisement - Remaining Time: "+ Math.round(timeTrait.duration - timeTrait.currentTime) + " seconds... ]";
				}
			}
			label.text = labelText;
		}
		
		private var _innerViewable:DisplayObjectTrait;
		private var outerViewable:AdProxyDisplayObjectTrait;
		private var displayObject:Sprite;
		private var label:TextField;
	}
}