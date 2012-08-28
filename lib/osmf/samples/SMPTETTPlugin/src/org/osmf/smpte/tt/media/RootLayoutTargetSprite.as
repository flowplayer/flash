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
	import flash.accessibility.AccessibilityProperties;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutRenderer;
	import org.osmf.layout.LayoutRendererBase;
	import org.osmf.layout.LayoutTargetSprite;
	import org.osmf.media.MediaElement;
	
	public class RootLayoutTargetSprite extends LayoutTargetSprite
	{
		public function RootLayoutTargetSprite(layoutRenderer:LayoutRendererBase=null, layoutMetadata:LayoutMetadata=null)
		{
			super(layoutMetadata);
			
			_layoutRenderer = layoutRenderer || new LayoutRenderer();
			_layoutRenderer.container = this;
			
			this.accessibilityProperties = new AccessibilityProperties();
			this.accessibilityProperties.silent = true;
		}
		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		public function set mediaElement(value:MediaElement):void
		{
			_mediaElement = value;
		}
		
		/**
		 * The layout renderer that renders the LayoutTarget instances within
		 * this container.
		 **/
		public function get layoutRenderer():LayoutRendererBase
		{
			return _layoutRenderer;
		}
		
		/**
		 * Defines if the children of the container that display outside of its bounds 
		 * will be clipped or not.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */		
		public function get clipChildren():Boolean
		{
			return scrollRect != null;
		}
		
		public function set clipChildren(value:Boolean):void
		{
			if (value && scrollRect == null)
			{
				scrollRect = new Rectangle(0, 0, _layoutRenderer.measuredWidth, _layoutRenderer.measuredHeight);
			}
			else if (value == false && scrollRect)
			{
				scrollRect = null;
			} 
		}
		
		/**
		 * Defines the container's background color. By default, this value
		 * is set to NaN, which results in no background being drawn.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */		
		public function get backgroundColor():Number
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:Number):void
		{
			if (value != _backgroundColor)
			{
				_backgroundColor = value;
				drawBackground();
			}
		}
		
		/**
		 * Defines the container's background alpha. By default, this value
		 * is set to 1, which results in the background being fully opaque.
		 * 
		 * Note that a container will not have a background drawn unless its
		 * backgroundColor property is set.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
			if (value != _backgroundAlpha)
			{
				_backgroundAlpha = value;
				drawBackground();
			}
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 **/
		override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
		{			
			if(lastAvailableWidth == availableWidth && lastAvailableHeight == availableHeight) return;
			
			//trace(this+".layout("+availableWidth+","+availableHeight+","+deep+")");
			
			super.layout(availableWidth, availableHeight, deep);
			
			width = availableWidth;
			height = availableHeight;
			measure();
			validateNow();
			
			lastAvailableWidth = availableWidth;
			lastAvailableHeight = availableHeight;
			
			if (!isNaN(backgroundColor))
			{
				drawBackground();
			}
			
			if (scrollRect)
			{
				scrollRect = new Rectangle(0, 0, availableWidth, availableHeight);
			}
			
			dispatchEvent(new Event(Event.RESIZE));
			
		}
		
		/**
		 * @private
		 */
		override public function validateNow():void
		{
			_layoutRenderer.validateNow();
		}
		
		// Internals
		//
		
		private function drawBackground():void
		{
			
			graphics.clear();			
			
			if	(	!isNaN(_backgroundColor)
				&& 	_backgroundAlpha != 0
				&&	lastAvailableWidth
				&&	lastAvailableHeight
			)
			{
				graphics.beginFill(_backgroundColor,_backgroundAlpha);
				graphics.drawRect(0, 0, lastAvailableWidth, lastAvailableHeight);
				graphics.endFill();
			}
		}
		
		private var _mediaElement:MediaElement;
		private var _layoutRenderer:LayoutRendererBase;
		
		private var _backgroundColor:Number;
		private var _backgroundAlpha:Number;
		
		protected var lastAvailableWidth:Number;
		protected var lastAvailableHeight:Number;
	}
}