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
	import org.osmf.chrome.assets.AssetsManager;
	import org.osmf.chrome.configuration.LayoutAttributesParser;
	import org.osmf.chrome.configuration.WidgetsParser;
	import org.osmf.chrome.widgets.Widget;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	public class ControlBarElement extends MediaElement
	{
		// Embedded assets (see configuration.xml for their assignments):
		//
		
		[Embed(source="../assets/configuration.xml", mimeType="application/octet-stream")]
		private static const CONFIGURATION_XML:Class;
		
		[Embed(source="../assets/Standard0755.swf#Standard0755")]
		private static const DEFAULT_FONT:Class;
		
		[Embed(source="../assets/backDrop.png")]
		private static const BACKDROP:Class;
		
		[Embed(source="../assets/pause_disabled.png")]
		private static const PAUSE_DISABLED:Class;
		[Embed(source="../assets/pause_up.png")]
		private static const PAUSE_UP:Class;
		[Embed(source="../assets/pause_down.png")]
		private static const PAUSE_DOWN:Class;
		
		[Embed(source="../assets/stop_disabled.png")]
		private static const STOP_DISABLED:Class;
		[Embed(source="../assets/stop_up.png")]
		private static const STOP_UP:Class;
		[Embed(source="../assets/stop_down.png")]
		private static const STOP_DOWN:Class;
		
		[Embed(source="../assets/play_disabled.png")]
		private static const PLAY_DISABLED:Class;
		[Embed(source="../assets/play_up.png")]
		private static const PLAY_UP:Class;
		[Embed(source="../assets/play_down.png")]
		private static const PLAY_DOWN:Class;
		
		[Embed(source="../assets/scrubber_disabled.png")]
		private static const SCRUBBER_DISABLED:Class;
		[Embed(source="../assets/scrubber_up.png")]
		private static const SCRUBBER_UP:Class;
		[Embed(source="../assets/scrubber_down.png")]
		private static const SCRUBBER_DOWN:Class;
		[Embed(source="../assets/scrubBarTrack.png")]
		private static const SCRUB_BAR_TRACK:Class;
		
		// Public interface
		//
		
		public function addReference(target:MediaElement):void
		{
			if (this.target == null)
			{
				this.target = target;
				
				processTarget();
			}
		}
		
		private function processTarget():void
		{
			if (target != null && settings != null)
			{
				// We use the NS_CONTROL_BAR_TARGET namespaced metadata in order
				// to find out if the instantiated element is the element that our
				// control bar should control:
				var targetMetadata:Metadata = target.getMetadata(ControlBarPlugin.NS_CONTROL_BAR_TARGET);
				if (targetMetadata)
				{
					if 	(	targetMetadata.getValue(ID) != null
						&&	targetMetadata.getValue(ID) == settings.getValue(ID)
						)
					{
						controlBar.media = target;
					}
				}
			}
		}
		
		// Overrides
		//
		
		override public function set resource(value:MediaResourceBase):void
		{
			// Right after the media factory has instantiated us, it will set the
			// resource that it used to do so. We look the NS_CONTROL_BAR_SETTINGS
			// namespaced metadata, and retain it as our settings record 
			// (containing only one field: "ID" that tells us the ID of the media
			// element that we should be controlling):
			if (value != null)
			{
				settings
					= value.getMetadataValue(ControlBarPlugin.NS_CONTROL_BAR_SETTINGS) as Metadata;
					
				processTarget();
			}
			
			super.resource = value;
		}
		
		override protected function setupTraits():void
		{
			// Setup a control bar using the ChromeLibrary:
			setupControlBar();
			
			// Use the control bar's layout metadata as the element's layout metadata:
			var layoutMetadata:LayoutMetadata = new LayoutMetadata();
			LayoutAttributesParser.parse(controlBar.configuration, layoutMetadata);
			addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);
			
			// Signal that this media element is viewable: create a DisplayObjectTrait.
			// Assign controlBar (which is a Sprite) to be our view's displayObject.
			// Additionally, use its current width and height for the trait's mediaWidth
			// and mediaHeight properties:
			viewable = new DisplayObjectTrait(controlBar, controlBar.measuredWidth, controlBar.measuredHeight);
			// Add the trait:
			addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);
			
			controlBar.measure();
			
			super.setupTraits();	
		}
		
		// Internals
		//
		
		private function setupControlBar():void
		{
			try
			{
				var configuration:XML = XML(new CONFIGURATION_XML());
				
				var assetsManager:AssetsManager = new AssetsManager();
				assetsManager.addConfigurationAssets(configuration);
				assetsManager.load();
				
				var widgetsParser:WidgetsParser = new WidgetsParser()
				widgetsParser.parse(configuration.widgets.*, assetsManager);
				
				controlBar = widgetsParser.getWidget("controlBar");
			}
			catch (error:Error)
			{
				trace("WARNING: failed setting up control bar:", error.message);
			}
		}
		
		private var settings:Metadata;
		
		private var target:MediaElement;
		private var controlBar:Widget;
		private var viewable:DisplayObjectTrait;
		
		/* static */
		
		private static const ID:String = "ID";
	}
}