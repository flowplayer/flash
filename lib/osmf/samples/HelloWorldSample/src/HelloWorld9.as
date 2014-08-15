/*****************************************************
*  
*  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.F4MElement;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.StreamingXMLResource;
	
	
	/**
	 * Another simple OSMF application, building on HelloWorld2.as.
	 * 
	 * Plays a video, then shows a SWF, then plays another video.
	 **/
	[SWF(backgroundColor="0xdedede", width=640, height=480)]
	public class HelloWorld9 extends Sprite
	{
		public function HelloWorld9()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 			
 			// Create the container class that displays the media.
 			container = new MediaContainer();
			container.x = 0;
			container.y = 0;
			container.width = stage.stageWidth;
			container.height = stage.stageHeight;
			addChild(container);
			
			// Create some layout metadata from the MediaElement.  This will cause
			// it to be centered in the container, with no scaling of content.
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			layoutMetadata.layoutMode = LayoutMode.NONE;
			layoutMetadata.scaleMode = ScaleMode.LETTERBOX;
			layoutMetadata.percentHeight = 100;
			layoutMetadata.percentWidth = 100;
			layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;

			// create media element
			var streamingXMLResource:StreamingXMLResource = new StreamingXMLResource(XML_F4M, XML_PATH);
			var f4MElement:F4MElement = new F4MElement(streamingXMLResource);			
			container.addMediaElement(f4MElement);
			
			player = new MediaPlayer();
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onPlayerStateChange);
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			
			player.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
			player.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, onNumDynamicStreamChange);
			player.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
			
			player.muted = false;
			player.loop = false;
			player.autoPlay = false;
			player.media = f4MElement;
			player.bufferTime = 4 ;
			player.autoDynamicStreamSwitch=true;
		}
		
		private function onPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{
			switch (event.state)
			{
				case MediaPlayerState.READY:
					{	
						trace("started");
						player.play();
					}
					break;
				case MediaPlayerState.PLAYING:
					break;
			}
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			trace("[Error]", event.toString());	
		}
		
		private function onAutoSwitchChange(event:DynamicStreamEvent):void
		{
			trace(" [MBR]", event.toString());	
		}

		private function onNumDynamicStreamChange(event:DynamicStreamEvent):void
		{
			trace(" [MBR]", event.toString());	
		}
		
		private function onSwitchingChange(event:DynamicStreamEvent):void
		{
			trace(" [MBR]", event.toString());	
		}
		
		private var player:MediaPlayer;
		private var container:MediaContainer;
		private var start:Boolean = true;
		
		private static const XML_F4M:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <manifest xmlns=\"http://ns.adobe.com/f4m/1.0\"> 	<mimeType> 		 	</mimeType> 	<streamType> 		recorded 	</streamType> 	<duration> 		0 	</duration> 	<fragment-duration>  		30000 	</fragment-duration> 	<bootstrapInfo 		 profile=\"named\" 		 id=\"bootstrap1459\" 	> 		AAABq2Fic3QAAAAAAAAAFAAAAAPoAAAAAAAJPCoAAAAAAAAAAAAAAAAAAQAAABlhc3J0AAAAAAAAAAABAAAAAQAAABUBAAABZmFmcnQAAAAAAAAD6AAAAAAVAAAAAQAAAAAAAAAAAAB1lAAAAAMAAAAAAADrQgAAdsAAAAAEAAAAAAABYf8AAHUwAAAABQAAAAAAAddNAAB0zAAAAAYAAAAAAAJMNwAActgAAAAHAAAAAAACvy0AAHeIAAAACAAAAAAAAzaRAAB0BAAAAAkAAAAAAAOqcAAAeFAAAAAKAAAAAAAEIr0AAHUwAAAACwAAAAAABJfJAABzPAAAAAwAAAAAAAULAQAAdAQAAAANAAAAAAAFfuAAAHX4AAAADgAAAAAABfT2AAB3iAAAAA8AAAAAAAZsewAAdGgAAAAQAAAAAAAG4OAAAHTMAAAAEQAAAAAAB1WoAAB1+AAAABIAAAAAAAfLnQAAc6AAAAATAAAAAAAIPxgAAHUwAAAAFAAAAAAACLRmAAB1lAAAABUAAAAAAAkqGAAAEfgAAAAAAAAAAAAAAAAAAAAAAA== 	</bootstrapInfo> 	<media 		 streamId=\"DTV1700K.mp4\" 		 url=\"http://10.122.233.48:8134/jit/DTV1700K.mp4\" 		 bootstrapInfoId=\"bootstrap1459\" bitrate=\"1700\" 	> 		<metadata> 			AgAKb25NZXRhRGF0YQgAAAAAAAhkdXJhdGlvbgBAgupTSQua9wAFd2lkdGgAQJQAAAAAAAAABmhlaWdodABAhoAAAAAAAAAMdmlkZW9jb2RlY2lkAgAEYXZjMQAMYXVkaW9jb2RlY2lkAgAEbXA0YQAKYXZjcHJvZmlsZQBAU0AAAAAAAAAIYXZjbGV2ZWwAQEAAAAAAAAAABmFhY2FvdAAAAAAAAAAAAAAOdmlkZW9mcmFtZXJhdGUAQD34UeuFHrgAD2F1ZGlvc2FtcGxlcmF0ZQBA53AAAAAAAAANYXVkaW9jaGFubmVscwBAAAAAAAAAAAAJdHJhY2tpbmZvCgAAAAIDAAZsZW5ndGgAQXFMd4AAAAAACXRpbWVzY2FsZQBA3USAAAAAAAAIbGFuZ3VhZ2UCAANlbmcAAAkDAAZsZW5ndGgAQXu0o7AAAAAACXRpbWVzY2FsZQBA53AAAAAAAAAIbGFuZ3VhZ2UCAANlbmcAAAkAAAk= 		</metadata> 	</media>  	<bootstrapInfo 		 profile=\"named\" 		 id=\"bootstrap1550\" 	> 		AAABq2Fic3QAAAAAAAAAFAAAAAPoAAAAAAAJPCoAAAAAAAAAAAAAAAAAAQAAABlhc3J0AAAAAAAAAAABAAAAAQAAABUBAAABZmFmcnQAAAAAAAAD6AAAAAAVAAAAAQAAAAAAAAAAAAB1lAAAAAMAAAAAAADrQgAAdsAAAAAEAAAAAAABYf8AAHUwAAAABQAAAAAAAddNAAB0zAAAAAYAAAAAAAJMNwAActgAAAAHAAAAAAACvy0AAHeIAAAACAAAAAAAAzaRAAB0BAAAAAkAAAAAAAOqcAAAeFAAAAAKAAAAAAAEIr0AAHUwAAAACwAAAAAABJfJAABzPAAAAAwAAAAAAAULAQAAdAQAAAANAAAAAAAFfuAAAHX4AAAADgAAAAAABfT2AAB3iAAAAA8AAAAAAAZsewAAdGgAAAAQAAAAAAAG4OAAAHTMAAAAEQAAAAAAB1WoAAB1+AAAABIAAAAAAAfLnQAAc6AAAAATAAAAAAAIPxgAAHUwAAAAFAAAAAAACLRmAAB1lAAAABUAAAAAAAkqGAAAEfgAAAAAAAAAAAAAAAAAAAAAAA== 	</bootstrapInfo> 	<media 		 streamId=\"DTV6000K.mp4\" 		 url=\"http://10.122.233.48:8134/jit/DTV6000K.mp4\" 		 bootstrapInfoId=\"bootstrap1550\" bitrate=\"6000\" 	> 		<metadata> 			AgAKb25NZXRhRGF0YQgAAAAAAAhkdXJhdGlvbgBAgupTSQua9wAFd2lkdGgAQJQAAAAAAAAABmhlaWdodABAhoAAAAAAAAAMdmlkZW9jb2RlY2lkAgAEYXZjMQAMYXVkaW9jb2RlY2lkAgAEbXA0YQAKYXZjcHJvZmlsZQBAU0AAAAAAAAAIYXZjbGV2ZWwAQEAAAAAAAAAABmFhY2FvdAAAAAAAAAAAAAAOdmlkZW9mcmFtZXJhdGUAQD34UeuFHrgAD2F1ZGlvc2FtcGxlcmF0ZQBA53AAAAAAAAANYXVkaW9jaGFubmVscwBAAAAAAAAAAAAJdHJhY2tpbmZvCgAAAAIDAAZsZW5ndGgAQXFMd4AAAAAACXRpbWVzY2FsZQBA3USAAAAAAAAIbGFuZ3VhZ2UCAANlbmcAAAkDAAZsZW5ndGgAQXu0o7AAAAAACXRpbWVzY2FsZQBA53AAAAAAAAAIbGFuZ3VhZ2UCAANlbmcAAAkAAAk= 		</metadata> 	</media>  </manifest>";
		private static const XML_PATH:String = "http://catherine.corp.adobe.com/osmf/mlm_tests";
	}
}
