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

package org.osmf.chrome.widgets
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.configuration.LayoutAttributesParser;
	import org.osmf.chrome.hint.Hint;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.LayoutTargetEvent;
	import org.osmf.media.MediaElement;
	
	public class Widget extends FadingLayoutTargetSprite
	{
		public function Widget()
		{
			super();
			
			children = new Vector.<Widget>();
		}
		
		public function configure(xml:XML, assetManager:AssetsManager):void
		{
			_configuration = xml;
			_assetManager = assetManager;
			
			_id 		= String(xml.@id || "");
			fadeSteps	= parseInt(xml.@fadeSteps || "0");
			face 		= assetManager.getDisplayObject(xml.@face) || new Sprite();
			enabled		= String(xml.@enabled || "").toLocaleLowerCase() != "false";
			hint 		= xml.@hint != undefined ? xml.@hint : null;
			
			LayoutAttributesParser.parse(xml, layoutMetadata);
		}
		
		public function get configuration():XML
		{
			return _configuration;
		}
		
		public function get assetManager():AssetsManager
		{
			return _assetManager;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set media(value:MediaElement):void
		{
			if (_media != value)
			{
				var oldValue:MediaElement = _media;
				_media = null;
								
				if (oldValue)
				{
					oldValue.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					oldValue.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
					onMediaElementTraitsChange(null);
				}
				
				_media = value;
				
				if (_media)
				{
					_media.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitsChange);
					_media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaElementTraitsChange);
				}
				
				for each (var child:Widget in children)
				{
					child.media = _media;
				}
				
				processMediaElementChange(oldValue);
				onMediaElementTraitsChange(null);
			}
		}
		
		public function get media():MediaElement
		{
			return _media;
		}
		
		public function set face(value:DisplayObject):void
		{
			if (value != _face)
			{
				if (_face)
				{
					removeChild(_face);
				}
				_face = value;
				if (_face)
				{
					addChildAt(_face, 0);
				}
				
				measure();
			}
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled != value)
			{
				_enabled = value;
				processEnabledChange();
			}
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function addChildWidget(widget:Widget):void
		{
			if (layoutRenderer == null)
			{
				layoutRenderer = constructLayoutRenderer();
				if (layoutRenderer)
				{
					layoutRenderer.container = this;
				}
			}
			
			if (layoutRenderer != null)
			{
				layoutRenderer.addTarget(widget);
				children.push(widget);
				widget.media = _media;
			}
		}
		
		public function removeChildWidget(widget:Widget):void
		{
			if (layoutRenderer && layoutRenderer.hasTarget(widget))
			{
				layoutRenderer.removeTarget(widget);
				children.splice(children.indexOf(widget), 1);
			}
		}
		
		public function getChildWidget(id:String):Widget
		{
			var result:Widget
			
			for each (var child:Widget in children)
			{
				if (child.id && child.id.toLowerCase() == id.toLocaleLowerCase())
				{
					result = child;
					break;
				}
			}
			
			return result;
		}
		
		public function set hint(value:String):void
		{
			if (value != _hint)
			{
				if (_hint == null)
				{
					addEventListener(MouseEvent.ROLL_OVER, onRollOver);
					addEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
				
				if	(	stage
					&&	_hint
					&&	_hint != ""
					&&	Hint.getInstance(stage, _assetManager).text == _hint
					)
				{
					Hint.getInstance(stage, _assetManager).text = value;
				}
				
				_hint = value;
				
				if (_hint == null)
				{
					removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
					removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				}
			}
		}
		
		public function get hint():String
		{
			return _hint;
		}
		
		// Overrides
		//
		
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean=true):void
		{
			if (_face)
			{
				_face.width = availableWidth / scaleX;
				_face.height = availableHeight / scaleY;
			}
			super.layout(availableWidth, availableHeight, deep);
		}
		
		override public function set width(value:Number):void
		{
			if (_face)
			{
				_face.width = value / scaleX;
			}
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			if (_face)
			{
				_face.height = value / scaleY;
			}
			super.height = value;
		}
		
		override protected function onAddChildAt(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onAddChildAt(event);
		}

		override protected function onRemoveChild(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onRemoveChild(event);
		}
		
		override protected function onSetChildIndex(event:LayoutTargetEvent):void
		{
			event = new LayoutTargetEvent
				( event.type
				, event.bubbles
				, event.cancelable
				, event.layoutRenderer
				, event.layoutTarget
				, event.displayObject
				, event.index == -1 ? -1 : event.index + 1
				); 
			super.onSetChildIndex(event);
		}
		
		override protected function setSuperVisible(value:Boolean):void
		{
			super.setSuperVisible(value);
			layoutMetadata.includeInLayout = value && (configuration ? configuration.@includeInLayout != "false" : true);
		}
				
		// Stubs
		//
		
		protected function constructLayoutRenderer():LayoutRendererBase
		{
			return new LayoutRenderer();
		}
		
		protected function processEnabledChange():void
		{
		}
		
		protected function processMediaElementChange(oldMediaElement:MediaElement):void
		{
		}
		
		protected function onMediaElementTraitAdd(event:MediaElementEvent):void
		{
		}
		
		protected function onMediaElementTraitRemove(event:MediaElementEvent):void
		{	
		}
		
		protected function processRequiredTraitsAvailable(element:MediaElement):void
		{	
		}
		
		protected function processRequiredTraitsUnavailable(element:MediaElement):void
		{	
		}
		
		protected function get requiredTraits():Vector.<String>
		{
			return null;
		}

		// Internals
		//
		
		private var _media:MediaElement;
		
		private var _configuration:XML;
		private var _assetManager:AssetsManager;
		private var _id:String;
		private var _enabled:Boolean;
		private var _hint:String;
		
		private var _face:DisplayObject;
		private var layoutRenderer:LayoutRendererBase;
		
		private var children:Vector.<Widget>;
		
		private var _requiredTraitsAvailable:Boolean;
		
		private function onRollOver(event:MouseEvent):void
		{
			Hint.getInstance(stage, assetManager).text = _hint;
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			Hint.getInstance(stage, assetManager).text = null;
		}
		
		private function onMediaElementTraitsChange(event:MediaElementEvent = null):void
		{
			var element:MediaElement
				= event 
					? event.target as MediaElement
					: _media;
					
			var priorRequiredTraitsAvailable:Boolean = _requiredTraitsAvailable;
			
			if (element)
			{
				_requiredTraitsAvailable = true;
				for each (var type:String in requiredTraits)
				{
					if (element.hasTrait(type) == false)
					{
						_requiredTraitsAvailable = false;
						break;
					}
				}
			}
			else
			{
				_requiredTraitsAvailable = false;
			}
			
			if	(	event == null // always invoke handlers, if change is not event driven.
				||	_requiredTraitsAvailable != priorRequiredTraitsAvailable
				)
			{
				_requiredTraitsAvailable
					? processRequiredTraitsAvailable(element)
					: processRequiredTraitsUnavailable(element);
			}
			
			if (event)
			{
				event.type == MediaElementEvent.TRAIT_ADD
					? onMediaElementTraitAdd(event)
					: onMediaElementTraitRemove(event);
			}
		}
		
		// Utils
		//
		
		protected function parseAttribute(xml:XML, attributeName:String, defaultValue:*):*
		{
			var result:*;
			
			if (xml.@[attributeName] == undefined)
			{
				result = defaultValue;
			}
			else
			{
				result = xml.@[attributeName];
			}
			
			return result;
		}
	}
}