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
package org.osmf.smpte.tt
{
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	import org.osmf.smpte.tt.architecture.creation.SMPTETTFactoryFacade;
	import org.osmf.smpte.tt.media.SMPTETTProxyElement;
	
	/**
	 * Encapsulation of a SMPTE-TT plugin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class SMPTETTPluginInfo extends PluginInfo
	{
		// Constants for specifying the Timed Text document URL on the resource metadata
		public static const SMPTETT_METADATA_NAMESPACE:String = "http://www.osmf.org/smpte-tt/1.0";
		public static const SMPTETT_METADATA_KEY_URI:String = "uri";
		public static const SMPTETT_METADATA_KEY_MEDIAFACTORY:String = "MediaFactory";
		public static const SMPTETT_METADATA_KEY_MEDIAPLAYER:String = "MediaPlayer";
		public static const SMPTETT_METADATA_KEY_MEDIACONTAINER:String = "MediaContainer";
		public static const SMPTETT_METADATA_KEY_SHOWCAPTIONS:String = "showCaptions";
		
		// Constants for the temporal metadata (captions)
		public static const SMPTETT_TEMPORAL_METADATA_NAMESPACE:String = "http://www.osmf.org/temporal/smpte-tt";
		
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.6
		 */
		public function SMPTETTPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var item:MediaFactoryItem = new MediaFactoryItem
											("org.osmf.smpte.tt.SMPTETTPluginInfo"
											 ,canHandleResourceCallback
											 ,createSMPTETTProxyElement
											 ,MediaFactoryItemType.PROXY);
											 
												
			
			
			items.push(item);
			
			super(items, creationNotificationFunction);
		}
		
		private function canHandleResourceCallback(resource:MediaResourceBase):Boolean
		{
			var result:Boolean = true;
			/*
			if (resource != null)
			{
				
				var settings:Metadata
						= resource.getMetadataValue(SMPTETT_METADATA_NAMESPACE) as Metadata;
				
				result = settings != null;
				
			}
			*/
			return result;	
		}
		
		private function createSMPTETTProxyElement():MediaElement
		{
			//return new SMPTETTProxyElement();
			return SMPTETTFactoryFacade.getSMPTETTProxyElement();
		}
		
		// OSMF will invoke this function for any MediaElement returned by
		// MediaFactory.createMediaElement. Note that this function will
		// even be invoked for MediaElements created prior to the loading
		// of this plug-in, so as to isolate the plug-in from load order
		// dependencies.
		private function creationNotificationFunction(media:MediaElement):void
		{
			if (media is VideoElement)
			{
				VideoElement( media ).smoothing = true;
			}
		}
	}
}