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

package org.osmf.player.preloader
{
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.chrome.configuration.Configuration;
	import org.osmf.player.debug.Debugger;

	public class Preloader extends MovieClip
	{
		public function Preloader()
		{
			super();
			
			// Set the SWF scale mode, and listen to the stage change
			// dimensions:
			stage.align = StageAlign.TOP_LEFT;
			
			addEventListener(Event.ENTER_FRAME, progressDrawingEventHandler);
			stage.addEventListener(Event.RESIZE, progressDrawingEventHandler);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressDrawingEventHandler);
			loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			
			progressDrawingEventHandler();
			
			CONFIG::DEBUG
			{
				_debugger = new Debugger(loaderInfo.parameters["id"]);
			}
		}
		
		public function get debugger():Debugger
		{
			return _debugger;
		}
		
		// Internals
		//
		
		private var _debugger:Debugger;
		
		private static const WIDTH:Number = 150;
		private static const HEIGHT:Number = 12;
		
		public const configuration:Configuration = new Configuration();
		
		private function progressDrawingEventHandler(event:Event = null):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x000000, 0.5);
			var x:Number = stage.stageWidth / 2 - WIDTH / 2;
			var y:Number = stage.stageHeight / 2 - HEIGHT / 2
			var p:Number = loaderInfo.bytesLoaded / loaderInfo.bytesTotal;
			graphics.drawRect(x, y, WIDTH, HEIGHT);
			graphics.lineStyle(1, 0xFFFFFF, 1);
			graphics.drawRect(x + 1, y + 1, WIDTH - 2, HEIGHT - 2);
			graphics.beginFill(0xFFFFFF, 1);
			graphics.drawRect(x + 1, y + 1, (WIDTH - 2) * p, HEIGHT - 2);
			graphics.endFill();
		}
		
		private function onLoaderComplete(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, progressDrawingEventHandler);
			stage.removeEventListener(Event.RESIZE, progressDrawingEventHandler);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressDrawingEventHandler);
			loaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
			
			configuration.addEventListener(Event.COMPLETE, onConfigurationComplete);
			var configurationFileURL:String = loaderInfo.parameters.configuration;
			if (configurationFileURL != null)
			{
				configuration.loadFromFile(configurationFileURL, true);
			}
			else
			{
				trace("WARNING: configuration file not specified in SWF parameters");
				onConfigurationComplete(null);
			}
		}
		
		private function onConfigurationComplete(event:Event):void
		{
			graphics.clear();
			nextFrame();
			
			var player:Class = getDefinitionByName("OSMFPlayer") as Class;
			addChild(new player(this));
		}
	}
}