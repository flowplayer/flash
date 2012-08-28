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
package org.osmf.smpte.tt.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.mx_internal;
	import mx.utils.BitFlagUtil;
	
	import spark.components.ToggleButton;
	import spark.components.VideoPlayer;
	
	use namespace mx_internal;
	
	public class SMPTETTVideoPlayer extends VideoPlayer
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static const CAPTIONS_SOURCE_PROPERTY_FLAG:uint = 1 << 10;
		
		/**
		 *  @private
		 */
		private static const SHOW_CAPTIONS_PROPERTY_FLAG:uint = 1 << 11;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *   
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function SMPTETTVideoPlayer()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  An optional skin part to toggle the display of captions.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var captionButton:ToggleButton;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 *  Several properties are proxied to videoDisplay.  However, when videoDisplay
		 *  is not around, we need to store values set on VideoPlayer.  This object 
		 *  stores those values.  If videoDisplay is around, the values are stored 
		 *  on the videoDisplay directly.  However, we need to know what values 
		 *  have been set by the developer on the VideoPlayer (versus set on 
		 *  the videoDisplay or defaults of the videoDisplay) as those are values 
		 *  we want to carry around if the videoDisplay changes (via a new skin). 
		 *  In order to store this info effeciently, videoDisplayProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitely set on this VideoPlayer.  When the 
		 *  contentGroup is not around, videoDisplayProperties is a typeless 
		 *  object to store these proxied properties.  When videoDisplay is around,
		 *  videoDisplayProperties stores booleans as to whether these properties 
		 *  have been explicitely set or not.
		 */
		private var videoDisplayProperties:Object = {};
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  captionsSource
		//----------------------------------
		
		[Inspectable(category="General", defaultValue="null")]
		[Bindable("captionsSourceChanged")]
		
		/**
		 *  @copy spark.components.VideoDisplay#captionsSource
		 * 
		 *  @default null
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get captionsSource():String
		{
			if (videoDisplay && videoDisplay is SMPTETTVideoDisplay)
			{
				return SMPTETTVideoDisplay(videoDisplay).captionsSource;
			}
			else
			{
				var v:* = videoDisplayProperties.captionsSource;
				return (v === undefined) ? null : v;
			}
		}
		
		/**
		 * @private
		 */
		public function set captionsSource(value:String):void
		{
			if (videoDisplay && videoDisplay is SMPTETTVideoDisplay)
			{
				SMPTETTVideoDisplay(videoDisplay).captionsSource = value;
				videoDisplayProperties = BitFlagUtil.update(videoDisplayProperties as uint, 
					CAPTIONS_SOURCE_PROPERTY_FLAG, true);
			}
			else
			{
				videoDisplayProperties.captionsSource = value;
			}
		}
		
		//----------------------------------
		//  showCaptions
		//----------------------------------
		
		[Inspectable(category="General", defaultValue="false")]
		[Bindable("showCaptionsChanged")]
		
		/**
		 *  @copy spark.components.VideoDisplay#captionsSource
		 * 
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get showCaptions():Boolean
		{
			if (videoDisplay && videoDisplay is SMPTETTVideoDisplay)
			{
				return SMPTETTVideoDisplay(videoDisplay).showCaptions;
			}
			else
			{
				var v:* = videoDisplayProperties.showCaptions;
				return (v === undefined) ? false : v;
			}
		}
		
		/**
		 * @private
		 */
		public function set showCaptions(value:Boolean):void
		{
			if (videoDisplay && videoDisplay is SMPTETTVideoDisplay)
			{
				SMPTETTVideoDisplay(videoDisplay).showCaptions = value;
				videoDisplayProperties = BitFlagUtil.update(videoDisplayProperties as uint, 
					SHOW_CAPTIONS_PROPERTY_FLAG, true);
			}
			else
			{
				videoDisplayProperties.showCaptions = value;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == videoDisplay && videoDisplay is SMPTETTVideoDisplay)
			{
				// just strictly for binding purposes
				videoDisplay.addEventListener("captionsSourceChanged", dispatchEvent);
				videoDisplay.addEventListener("showCaptionsChanged", videoDisplay_showCaptionsChangedHandler);
				
				// copy proxied values from videoProperties (if set) to video
				
				var newVideoProperties:uint = 0;
								
				if (videoDisplayProperties.captionsSource !== undefined)
				{
					SMPTETTVideoDisplay(videoDisplay).captionsSource = videoDisplayProperties.captionsSource;
					newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
						CAPTIONS_SOURCE_PROPERTY_FLAG, true);
				}
				
				if (videoDisplayProperties.showCaptions !== undefined)
				{
					SMPTETTVideoDisplay(videoDisplay).showCaptions = videoDisplayProperties.showCaptions;
					newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
						SHOW_CAPTIONS_PROPERTY_FLAG, true);
				}
				
				videoDisplayProperties = newVideoProperties;
				
				if (captionButton)
				{
					captionButton.selected = SMPTETTVideoDisplay(videoDisplay).showCaptions;
				}
				
			}
			else if (instance == captionButton)
			{
				captionButton.addEventListener(MouseEvent.CLICK, captionButton_clickHandler);
			}
		}
		
		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == videoDisplay)
			{
				// validate before doing anything with the videoDisplay.
				// This is so if the video element hasn't been validated, it won't start playing.
				// plus this way we'll get a valid currentTime and all those other properties 
				// we are interested in.
				videoDisplay.validateNow();
				
				// copy proxied values from video (if explicitely set) to videoProperties
				
				var newVideoProperties:Object = {};
				
				if (BitFlagUtil.isSet(videoDisplayProperties as uint, CAPTIONS_SOURCE_PROPERTY_FLAG))
					newVideoProperties.captionsSource = SMPTETTVideoDisplay(videoDisplay).captionsSource;
				
				if (BitFlagUtil.isSet(videoDisplayProperties as uint, SHOW_CAPTIONS_PROPERTY_FLAG))
					newVideoProperties.showCaptions = SMPTETTVideoDisplay(videoDisplay).showCaptions;
				
				videoDisplayProperties = newVideoProperties;
				
				// just strictly for binding purposes
				videoDisplay.removeEventListener("captionsSourceChanged", dispatchEvent);
				videoDisplay.removeEventListener("showCaptionsChanged", videoDisplay_showCaptionsChangedHandler);
			}
			else if (instance == captionButton)
			{
				captionButton.removeEventListener(MouseEvent.CLICK, captionButton_clickHandler);
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function videoDisplay_showCaptionsChangedHandler(event:Event):void
		{
			if (captionButton)
				captionButton.selected = showCaptions;
			//trace(event+"\t"+showCaptions);
			dispatchEvent(event);
		}
		
		/**
		 *  @private
		 */
		private function captionButton_clickHandler(event:MouseEvent):void
		{
			if (showCaptions)
				showCaptions = false;
			else
				showCaptions = true;
			
			captionButton.selected = showCaptions;
		}
		
	}
}