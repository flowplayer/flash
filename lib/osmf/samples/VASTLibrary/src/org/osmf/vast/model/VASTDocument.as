/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*  Contributor(s): Adobe Systems Inc.
* 
*****************************************************/
package org.osmf.vast.model
{
	import __AS3__.vec.Vector;
	
	/**
	 * This class represents the top level object of the VAST document object
	 * model.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTDocument extends VASTDataObject
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTDocument()
		{
			super(VASTDataObject.VERSION_1_0);
			
			_ads = new Vector.<VASTAd>();
		}
		
		/**
		 * Adds the given VASTAd to the document.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function addAd(ad:VASTAd):void
		{
			_ads.push(ad);
		}

		/**
		 * The collection of VASTAds in the document.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get ads():Vector.<VASTAd>
		{
			return _ads;
		}
		
		public function get version():Number
		{
			return _version;
		}
		
		public function set version(value:Number):void
		{
			_version = value;
		}
		private var _ads:Vector.<VASTAd>;
		private var _version:Number;
	}
}
