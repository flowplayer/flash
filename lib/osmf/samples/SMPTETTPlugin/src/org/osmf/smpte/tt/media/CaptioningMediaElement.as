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
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.smpte.tt.captions.CaptionElement;
	import org.osmf.smpte.tt.captions.CaptionRegion;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class CaptioningMediaElement extends MediaElement
	{		
		public function CaptioningMediaElement()
		{
			super();
		}
		
		private var _showCaptions:Boolean = true;
		
		public function get showCaptions():Boolean
		{
			return _showCaptions;
		}

		public function set showCaptions(value:Boolean):void
		{
			_showCaptions = value;
			
			if (_rootContainer)
			{
				_rootContainer.visible = _showCaptions;
			}
		}

		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}

		public function set mediaElement(value:MediaElement):void
		{
			_mediaElement = value;
			
			if (!_rootContainer) buildRootContainer();
			
			var dot:DisplayObjectTrait = _mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			if (dot 
				&& dot.mediaWidth 
				&& dot.mediaHeight)
			{	
				trace("setMediaElement {mediaHeight:"+ dot.mediaWidth +", mediaWidth:"+dot.mediaHeight+"}");
				
				setIntrinsicDimensions(dot.mediaWidth, dot.mediaHeight);
			}
		}

		private function buildRootContainer(width:Number=NaN, height:Number=NaN):void
		{				
			
			_rootContainer = new RootLayoutTargetSprite();
						
			_displayObjectTrait = new LayoutTargetSpriteDisplayObjectTrait(_rootContainer, width, height);
			addTrait(MediaTraitType.DISPLAY_OBJECT, _displayObjectTrait);
			
			_rootContainer.addEventListener(Event.RESIZE, rootContainer_resizeHandler);

			// set visibility of the _rootContainer based on showCaptions
			_rootContainer.visible = showCaptions;
		}
		
		public function addRegion(value:CaptionRegion):RegionLayoutTargetSprite
		{
			
			if (!_regionsHash)
			{
				_regionsHash = new Dictionary();
			}
			var region:RegionLayoutTargetSprite;
			if (!_regionsHash[value.id])
			{
				region = new RegionLayoutTargetSprite(value);
				_regionsHash[value.id] = region;
				if (_rootContainer) _rootContainer.layoutRenderer.addTarget(region);
			} 
			else
			{
				region = _regionsHash[value.id]
			}
			return region;
		}
		
		public function getRegionById(id:String):RegionLayoutTargetSprite
		{
			if (!_regionsHash) return null;			
			return _regionsHash[id] as RegionLayoutTargetSprite;
		}
		
		public function removeRegionById(id:String):void
		{
			if (_regionsHash && _regionsHash[id])
			{
				var region:RegionLayoutTargetSprite = _regionsHash[id];
				if (_rootContainer) _rootContainer.layoutRenderer.removeTarget(region);
				delete _regionsHash[id];
			}
		}
		
		public function addCaption(value:CaptionElement):void
		{
			if (_rootContainer)
			{
				var timeTrait:TimeTrait;
				var testTime:Number = value.begin;
				if (mediaElement)
				{
					timeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				}
				for each(var r:RegionLayoutTargetSprite in _regionsHash)
				{
					r.validateCaption(value.begin, value.end, testTime);
				}
			}
			//trace("addCaption: "+value.id);
			if (value.regionId && _regionsHash[value.regionId])
			{
				_currentCaption = value;
				if (_rootContainer)
				{
					var targetRegion:RegionLayoutTargetSprite = 
							RegionLayoutTargetSprite(_regionsHash[value.regionId]);
					targetRegion.addCaption(value);
					if (value.siblings)
					{
						for each(var s:CaptionElement in value.siblings){
							addCaption(s);
						}
					}
				}
			}
		}
		
		public function removeCaption(value:CaptionElement=null):void
		{
			var r:RegionLayoutTargetSprite;
			if (!value){
				for each(r in _regionsHash)
				{
					r.removeCaption();
				}
				return;
			}
			if (_rootContainer)
			{
				for each(r in _regionsHash)
				{
					r.validateCaption();
				}
			}
			//trace("removeCaption: "+value.id);
			if (value.regionId && _regionsHash[value.regionId]){
				var targetRegion:RegionLayoutTargetSprite = 
						RegionLayoutTargetSprite(_regionsHash[value.regionId]);
				if (_rootContainer)
				{
					targetRegion.removeCaption(value);
					if (value.siblings){
						for each(var s:CaptionElement in value.siblings){
							removeCaption(s);
						}
					}
				}
				_currentCaption = null;
			}
		}
		
		public function clear():void{
			if (_regionsHash){
				_currentCaption = null;
				for(var i:String in _regionsHash){
					var r:RegionLayoutTargetSprite = _regionsHash[i] as RegionLayoutTargetSprite;
					r.clear();
					if (_rootContainer) _rootContainer.layoutRenderer.removeTarget(r);
					delete _regionsHash[i];
				}
			}
			if (_displayObjectTrait){
				removeTrait(MediaTraitType.DISPLAY_OBJECT);
			}
			delete this;
		}
		
		private function redrawCaptions():void
		{
			if (_regionsHash)		
			{	
				for each(var r:RegionLayoutTargetSprite in _regionsHash)
				{
					r.redrawCaption();
				}
				/*
				removeCaption();
				var cme:CaptioningMediaElement = this;
				_rootContainer.addEventListener(Event.ENTER_FRAME, 
					function(e:Event):void
					{
						e.target.removeEventListener(Event.ENTER_FRAME,arguments.callee);
						cme.addCaption(cachedCurrentCaption);
					});
				*/
			}
		}
		
		private function rootContainer_resizeHandler(event:Event):void
		{
			redrawCaptions();
		}
		
		public function validateCaptions():void
		{
			if (_regionsHash)
			{
				for each(var r:RegionLayoutTargetSprite in _regionsHash){
					r.validateCaption();
				}
			}
		}
		
		public function setIntrinsicDimensions(width:Number, height:Number, fireEvent:Boolean=true):void
		{
			trace(this + " setIntrinsicDimensions: {width : "+width+", height : "+height+", _measuredWidth : "+_measuredWidth+", _measuredHeight : "+_measuredHeight+" }");
			
			if (_measuredWidth == width && _measuredHeight == height) return;
			
			if (_rootContainer)
			{	
				_displayObjectTrait.newMediaSize(width, height);
				
				if (_mediaElement)
				{	
					var layoutMetadata:LayoutMetadata = _mediaElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
					
					if (layoutMetadata)
					{	
						_rootContainer.layoutMetadata.scaleMode = layoutMetadata.scaleMode;
						_rootContainer.layoutMetadata.verticalAlign = layoutMetadata.verticalAlign;
						_rootContainer.layoutMetadata.horizontalAlign = layoutMetadata.horizontalAlign;
						_rootContainer.layoutMetadata.percentWidth = layoutMetadata.percentWidth;
						_rootContainer.layoutMetadata.percentHeight = layoutMetadata.percentHeight;
						_rootContainer.layoutMetadata.index = 1;
						
						layoutMetadata.index = 0;
						_mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);					
					}
					
					redrawCaptions();
				}
				_displayObjectTrait.dispatchEvent
				( new DisplayObjectEvent
					( DisplayObjectEvent.MEDIA_SIZE_CHANGE, false, false
						, null, null
						, _measuredWidth
						, _measuredHeight
						, _measuredWidth = width
						, _measuredHeight = height
					)
				);
			}	
		}
		
		private var _mediaElement:MediaElement;
		private var _regionsHash:Dictionary;
		private var _rootContainer:RootLayoutTargetSprite;
		private var _displayObjectTrait:LayoutTargetSpriteDisplayObjectTrait;
		private var _currentCaption:CaptionElement;
		private var _measuredWidth:Number = NaN;
		private var _measuredHeight:Number = NaN;
	}
}