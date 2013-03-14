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
package 
{
	import flash.display.Sprite;
	
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.*;
	import org.osmf.metadata.Metadata;
	
	[SWF(width="640", height="360", backgroundColor="0x000000",frameRate="25")]
	public class ControlBarSample extends Sprite
	{
		public function ControlBarSample()
		{
			// Construct an OSMFConfiguration helper class:	
			osmf = new OSMFConfiguration();
			
			// Construct the main element to play back. This will be a
			// parallel element, that will hold the main content to
			// playback, and the control bar (from a plug-in) as its
			// children:
			osmf.mediaElement = constructRootElement();
			osmf.view = this;
			
			// Add event listeners to the plug-in manager so we'll get
			// a heads-up when the control bar plug-in finishes loading:
			osmf.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			osmf.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
			
			// Ask the plug-in manager to load the control bar plug-in:
			osmf.factory.loadPlugin(pluginResource);
		}
		
		// Internals
		//
		
		private var osmf:OSMFConfiguration;
		private var rootElement:ParallelElement;
		
		private function onPluginLoaded(event:MediaFactoryEvent):void
		{
			// The plugin loaded successfully. We can now construct a control
			// bar media element, and add it as a child to the root parallel
			// element:
			rootElement.addChild(constructControlBarElement());
		}
		
		private function onPluginLoadError(event:MediaFactoryEvent):void
		{
			trace("ERROR: the control bar plugin failed to load.");
		}
		
		private function constructRootElement():MediaElement
		{
			// Construct a parallel media element to hold the main content,
			// and later on, the control bar.
			rootElement = new ParallelElement();
			rootElement.addChild(constructVideoElement());
			
			// Use the layout api to set the parallel element's width and
			// height. Make it as big as the stage currently is:
			var rootElementLayout:LayoutMetadata = new LayoutMetadata();
			rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);
			rootElementLayout.width = stage.stageWidth;
			rootElementLayout.height = stage.stageHeight;
			
			return rootElement;
		}
		
		private function constructVideoElement():MediaElement
		{
			// Construct a metadata object that we can append to the video's collection
			// of metadata. The control bar plug-in will use the metadata to identify
			// the video element as its target:
			var controlBarTarget:Metadata = new Metadata();
			controlBarTarget.addValue(ID, "mainContent");
			
			// Construct a video element:
			var video:MediaElement = osmf.factory.createMediaElement(new URLResource(VIDEO_URL));
			
			// Add the metadata to the video's metadata:
			video.addMetadata(ControlBarPlugin.NS_CONTROL_BAR_TARGET, controlBarTarget);
			
			return video;
		}
		
		private function constructControlBarElement():MediaElement
		{
			// Construct a metadata object that we'll send to the media factory on
			// requesting a control bar element to be instantiated. The factory
			// will use it to parameterize the element. Specifically, the ID field
			// will tell the plug-in what the ID of the content it should control
			// is:
			var controlBarSettings:Metadata = new Metadata();
			controlBarSettings.addValue(ID, "mainContent");
			
			// Add the metadata to an otherwise empty media resource object:
			var resource:MediaResourceBase = new MediaResourceBase();
			resource.addMetadataValue(ControlBarPlugin.NS_CONTROL_BAR_SETTINGS, controlBarSettings);
			
			// Request the media factory to construct a control bar element. The
			// factory will infer a control bar element is requested by inspecting
			// the resource's metadata (and encountering a metadata object of namespace
			// NS_CONTROL_BAR_SETTINGS there):
			var controlBar:MediaElement = osmf.factory.createMediaElement(resource);
			
			// Set some layout properties on the control bar. Specifically, have it
			// appear at the bottom of the parallel element, horizontally centererd:
			var layout:LayoutMetadata = controlBar.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
			if (layout == null)
			{
				layout = new LayoutMetadata();
				controlBar.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
			}
			layout.verticalAlign = VerticalAlign.BOTTOM;
			layout.horizontalAlign = HorizontalAlign.CENTER;
			
			// Make sure that the element shows over the video: element's with a
			// higher order number set are placed higher in the display list:
			layout.index = 1;
			
			return controlBar;
		}
		
		/* static */
		
		private static const VIDEO_URL:String
			= "http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv";
			
		private static var ID:String = "ID";
		
		// Comment out to load the plug-in for a SWF (instead of using static linking, for testing):	
		//private static const pluginResource:URLResource = new URLResource("http://mediapm.edgesuite.net/osmf/swf/ControlBarPlugin.swf");
		
		private static const pluginResource:PluginInfoResource = new PluginInfoResource(new ControlBarPlugin().pluginInfo);
	}
}