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

package org.osmf.qos
{
	import flash.events.TimerEvent;
	import flash.net.NetStreamInfo;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.traits.MediaTraitType;

	public class VideoQoSProxyElement extends ProxyElement
	{
		// Public Interface
		//
			
		public function VideoQoSProxyElement(proxiedElement:MediaElement=null)
		{
			instanceNumber = instanceCounter++;
			
			super(proxiedElement);
		}
		
		// Overrides
		//
		
		override public function set proxiedElement(value:MediaElement):void
		{
			reset();
			
			if (value is VideoElement)
			{
				setup(VideoElement(value));
			}
			
			super.proxiedElement = value;
		}
		
		// Internals
		//
		
		private function reset():void
		{
			videoElement = null;
			
			if (timer != null)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer = null;
			}
		}
		
		private function setup(videoElement:VideoElement):void
		{
			this.videoElement = videoElement;
			
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(event:TimerEvent):void
		{
			var loadTrait:NetStreamLoadTrait
				=	videoElement.getTrait(MediaTraitType.LOAD)
				as	NetStreamLoadTrait;
				
			var metadata:VideoQoSPluginMetadata
				= videoElement.getMetadata(VideoQoSPluginMetadata.NAMESPACE)
				as VideoQoSPluginMetadata;
			
			if (metadata != null && (loadTrait == null || loadTrait.netStream == null))
			{
				removeMetadata(VideoQoSPluginMetadata.NAMESPACE);
				metadata = null;
			}
			else if (metadata == null)
			{
				metadata = new VideoQoSPluginMetadata();
				addMetadata(VideoQoSPluginMetadata.NAMESPACE, metadata);
			}
			
			if (metadata != null && loadTrait.netStream != null)
			{
				var qos:NetStreamInfo = loadTrait.netStream.info;
				
				metadata.addValue
					( VideoQoSPluginMetadata.CURRENT_FPS
					, loadTrait.netStream.currentFPS.toFixed(3)
					);
					
				metadata.addValue
					( VideoQoSPluginMetadata.DROPPED_FRAMES
					, qos.droppedFrames.toString() 
					);
				
			}
		}
		
		private var instanceNumber:int;
		private var timer:Timer;
		private var videoElement:VideoElement;
		private static var instanceCounter:int = 0;
	}
}