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
	import flash.media.Video;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.mx_internal;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.smpte.tt.SMPTETTPluginInfo;
	import org.osmf.smpte.tt.media.SMPTETTProxyElement;
	
	import spark.components.VideoDisplay;
	
	use namespace mx_internal;
	
	public class SMPTETTVideoDisplay extends VideoDisplay
	{
		
		
		public function SMPTETTVideoDisplay()
		{
			super();
			SMPTETTPluginInfo;
			loadPlugin(getQualifiedClassName(SMPTETTPluginInfo));
			
			addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, 
							 mediaPlayerStateChangeHandler);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  We do different things in the source setter based on if we 
		 *  are initialized or not.
		 */
		private var initializedOnce:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  captionsSource
		//----------------------------------
		
		private var _captionsSource:String;
		private var captionsSourceChanged:Boolean;
		
		[Inspectable(category="General", defaultValue="null")]
		[Bindable("captionsSourceChanged")]
		
		/**
		 *  The captions source.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get captionsSource():String
		{
			return _captionsSource;
		}
		
		/**
		 * @private (setter)
		 */
		public function set captionsSource(value:String):void
		{
			_captionsSource = value;
			
			// if we haven't initialized, let's wait to set up the 
			// source in commitProperties() as it is dependent on other 
			// properties, like autoPlay and enabled, and those may not 
			// be set yet, especially if they are set via MXML.
			// Otherwise, if we have initialized, let's just set up the 
			// source immediately.  This way people can change the source 
			// and immediately call methods like seek().
			if (!initializedOnce)
			{
				captionsSourceChanged = true;
				invalidateProperties();
			}
			else
			{
				setUpCaptionsSource();
			}
			
			dispatchEvent(new Event("captionsSourceChanged"));
		}
		
		//----------------------------------
		//  showCaptions
		//----------------------------------
		
		private var _showCaptions:Boolean = false;
		private var showCaptionsChanged:Boolean;
		
		[Inspectable(category="General", defaultValue="false")]
		[Bindable("showCaptionsChanged")]
		
		/**
		 *  The displays captions when they are available.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get showCaptions():Boolean
		{
			return _showCaptions;
		}
		
		/**
		 * @private (setter)
		 */
		public function set showCaptions(value:Boolean):void
		{
			_showCaptions = value;
			
			setUpShowCaptions();
			
			dispatchEvent(new Event("showCaptionsChanged"));
		}
		
		/**
		 * @private
		 */
		public function loadPlugin(source:String):void
		{
			var pluginResource:MediaResourceBase;
			if (source.substr(0, 4) == "http" || source.substr(0, 4) == "file")
			{
				// This is a URL, create a URLResource
				pluginResource = new URLResource(source);
			}
			else
			{
				// Assume this is a class
				var pluginInfoRef:Class = getDefinitionByName(source) as Class;
				pluginResource = new PluginInfoResource(new pluginInfoRef);
			}
			
			loadPluginFromResource(pluginResource);
		}
		
		private function loadPluginFromResource(pluginResource:MediaResourceBase):void
		{
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, pluginLoadedHandler);
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, pluginLoadErrorHandler);
			mediaFactory.loadPlugin(pluginResource);
		}
		
		private function pluginLoadedHandler(event:MediaFactoryEvent):void
		{
			trace("Plugin LOADED!");
		}
		
		private function pluginLoadErrorHandler(event:MediaFactoryEvent):void
		{
			trace("Plugin LOAD Failed!");
		}
		
		/**
		 *  @private
		 *  Sets up the source for use.
		 */
		private function setUpCaptionsSource():void
		{
			if (!_captionsSource)
			{
				cleanUpCaptionsSource();
			}
			
			if (videoPlayer.media 
				&& videoPlayer.media.resource)
			{
				var resource:MediaResourceBase = videoPlayer.media.resource;
				
				var metadata:Metadata = resource.getMetadataValue(SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE) as Metadata;
					
				if (metadata)
				{
					if (showCaptions && metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI) != _captionsSource)
						metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI, _captionsSource);
					metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS, showCaptions);
					metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY, mediaFactory);
					metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER, videoPlayer);
					metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER, videoContainer);
				}
			}
		}
		
		/**
		 *  @private
		 *  Cancels the load, no matter what state it's in.  This is used when changing the captionSource.
		 */
		private function cleanUpCaptionsSource():void
		{
			if (videoPlayer.media && videoPlayer.media.resource)
			{
				var resource:MediaResourceBase = videoPlayer.media.resource;
				
				var metadata:Metadata = resource.getMetadataValue(SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE) as Metadata;
					
				if (metadata)
				{
					metadata.removeValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI);
					metadata.removeValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY);
					metadata.removeValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER);
					metadata.removeValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER);
				}
			}			
		}
		
		/**
		 *  @private
		 *  Sets up the source for use.
		 */
		private function setUpShowCaptions():void
		{
			if (videoPlayer.media && videoPlayer.media.resource)
			{
				var resource:MediaResourceBase = videoPlayer.media.resource;
				
				var metadata:Metadata = resource.getMetadataValue(SMPTETTPluginInfo.SMPTETT_METADATA_NAMESPACE) as Metadata;
				
				if (metadata)
				{
					metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_SHOWCAPTIONS, showCaptions);
					
					if (showCaptions 
						&& metadata.getValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI) != _captionsSource)
					{
						metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_URI, 
							_captionsSource);
						metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAFACTORY, 
							mediaFactory);
						metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIAPLAYER, 
							videoPlayer);
						metadata.addValue(SMPTETTPluginInfo.SMPTETT_METADATA_KEY_MEDIACONTAINER, 
							videoContainer);
					}
				}
			}
		}
		
		private function mediaPlayerStateChangeHandler(event:MediaPlayerStateChangeEvent):void
		{
			if(videoPlayer.media is SMPTETTProxyElement){
				var videoElement:VideoElement = SMPTETTProxyElement(videoPlayer.media).mediaElement as VideoElement;
				if(videoElement)
				{
					videoElement.smoothing = true;
					invalidateSize();
				}
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
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			initializedOnce = true;
			
			if (showCaptionsChanged)
			{
				showCaptionsChanged = false;
			}
			
			if (captionsSourceChanged)
			{
				captionsSourceChanged = false;
				
				setUpCaptionsSource();
			}
		}
	}
}