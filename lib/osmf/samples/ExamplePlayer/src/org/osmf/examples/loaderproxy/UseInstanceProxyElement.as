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
package org.osmf.examples.loaderproxy
{
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingURLResource;
	
	/**
	 * A ProxyElement which ensures that the resource is a StreamingURLResource
	 * with urlIncludesFMSApplicationInstance set to true.
	 * 
	 * Some CDNs require this parameter to be set to true, others don't.  For
	 * those that do, customers aren't always aware of this requirement and as
	 * a result end up getting "stream not found" errors.  This class could be
	 * used in the plugin for a CDN that requires the parameter to be set to
	 * true.  It ensures that the proxiedElement's resource has the parameter
	 * set to true, even if the resource wasn't initialized that way. 
	 **/
	public class UseInstanceProxyElement extends ProxyElement
	{
		/**
		 * Constructor.
		 **/
		public function UseInstanceProxyElement(proxiedElement:MediaElement)
		{
			super(proxiedElement);
			
			// For elements that already have a resource, make sure we rewrite it.
			// (Note that this won't have much effect if the proxied element is
			// already loaded.  There's little we can do in that case.)
			if (proxiedElement.resource != null)
			{
				this.resource = proxiedElement.resource;
			}
		}

		/**
		 * @private
		 **/
		override public function set resource(value:MediaResourceBase):void
		{
			if (value != null && value is URLResource)
			{
				if (value is StreamingURLResource)
				{
					// Set the use-instance param to true.
					StreamingURLResource(value).urlIncludesFMSApplicationInstance = true;
				}
				else
				{
					var urlResource:URLResource = value as URLResource;
					
					// Create a copy of the resource, with the use-instance param set to true.
					var streamingResource:StreamingURLResource = new StreamingURLResource(urlResource.url);
					streamingResource.mediaType = urlResource.mediaType;
					streamingResource.mimeType = urlResource.mimeType;
					streamingResource.urlIncludesFMSApplicationInstance = true;
					for each (var nsurl:String in urlResource.metadataNamespaceURLs)
					{
						streamingResource.addMetadataValue(nsurl, urlResource.getMetadataValue(nsurl));
					}
					
					value = streamingResource;
				}
			}
			
			super.resource = value;
		}
	}
}