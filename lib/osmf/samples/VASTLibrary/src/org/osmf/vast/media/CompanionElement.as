/*****************************************************
*  
*  Copyright 2010 Eyewonder, LLC.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Eyewonder, LLC.
*  Portions created by Eyewonder, LLC. are Copyright (C) 2010 
*  Eyewonder, LLC. A Limelight Networks Business. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.vast.media
{
	import org.osmf.elements.HTMLElement;
	import org.osmf.vast.parser.base.VAST2CompanionElement;
	import org.osmf.vast.parser.base.VAST2TrackingData;

	public class CompanionElement extends HTMLElement
	{
		public function CompanionElement(companionElement:VAST2CompanionElement)
		{
			super();
			_companionElement = companionElement;
		}
		
		/**
		 * Pixel dimensions of companion
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get width():Number
		{
			return _companionElement.width;
		}
		
		/**
		 * Pixel dimensions of companion
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get height():Number
		{
			return _companionElement.height;
		}

		/**
		 * Data to be passed into the companion ads
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get adParameters():String
		{
			return _companionElement.adParameters;
		}
		
		/**
		 * Alt text to be displayed when companion is rendered in HTML environment.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get altText():String
		{
			return _companionElement.AltText;
		}

		/**
		 * The apiFramework defines the method to use for communication with the companion
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get apiFramework():String
		{
			return _companionElement.apiFramework;
		}
		
		/**
		 * URI to open as destination page when user clicks on the companion.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get companionClickThrough():String
		{
			return _companionElement.companionClickThrough;
		}

		/**
		 * Mime type of static resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get creativeType():String
		{
			return _companionElement.creativeType;
		}
		
		/**
		 * Pixel dimensions of expanding companion ad when in expanded state
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get expandedHeight():Number
		{
			return _companionElement.expandedHeight;
		}

		/**
		 * Pixel dimensions of expanding companion ad when in expanded state
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function expandedWidth():Number
		{
			return _companionElement.expandedWidth;
		}

		/**
		 * HTML to display the companion element
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function get htmlResource():String
		{
			return _companionElement.htmlResource;
		}		

		/**
		 * Optional identifier
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get id():String
		{
			return _companionElement.id;
		}

		/**
		 * URI source for an IFrame to display the companion element
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get iframeResource():String
		{
			return _companionElement.iframeResource;
		}		

		/**
		 * URI to a static file, such as an image or SWF file
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get staticResource():String
		{
			return _companionElement.staticResource;
		}
		
		/**
		 * Mime type of static resource
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get staticResourceCreativeType():String
		{
			return _companionElement.staticResourceCreativeType;
		}

		/**
		 * Tracking events for the companion ad. 
		 *  
		 * 	@see org.osmf.vast.parser.base.VAST2TrackingData
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trackingData():VAST2TrackingData
		{
			return _companionElement.trackingData;
		}
		
		private var _companionElement:VAST2CompanionElement;
	}
}
