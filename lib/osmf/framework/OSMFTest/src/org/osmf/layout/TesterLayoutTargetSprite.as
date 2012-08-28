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
package org.osmf.layout
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.metadata.Metadata;

	public class TesterLayoutTargetSprite extends Sprite implements ILayoutTarget
	{
		// ILayoutTarget
		//
		
		public function get layoutMetadata():LayoutMetadata
		{
			return _layoutMetadata;
		}

/* 		public function set layoutMetadata(value:LayoutMetadata):void
		{
			_layoutMetadata = value;
		}
 */		
		public function get displayObject():DisplayObject
		{
			return this;
		}
		
		public function get measuredWidth():Number
		{
			return _measuredWidth;
		}
		
		public function get measuredHeight():Number
		{
			return _measuredHeight;
		}
		
		public function measure(deep:Boolean = true):void
		{
			//
		}
		
		public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
		{
			width = availableWidth;
			height = availableHeight;
		}
		
		//  Public API
		//
		
		public function TesterLayoutTargetSprite()
		{
			renderers = new LayoutTargetRenderers(this);
			
			super();
		}
		
		public function setIntrinsicDimensions(width:Number, height:Number):void
		{
			graphics.clear();
			
			graphics.beginFill(0xff0000);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			dispatchEvent
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
		
		private var _layoutMetadata:LayoutMetadata = new LayoutMetadata();
		
		private var renderers:LayoutTargetRenderers;
		
		private var _measuredWidth:Number;
		private var _measuredHeight:Number;
		
	}
}