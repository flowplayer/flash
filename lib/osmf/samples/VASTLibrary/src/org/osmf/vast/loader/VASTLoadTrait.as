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
*  Contributor(s): Eyewonder, LLC
*  
*****************************************************/

package org.osmf.vast.loader
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.vast.media.CacheBuster;
	import org.osmf.vast.model.VASTDataObject;
	
	/**
	 * LoadTrait for VAST documents.
	 **/
	public class VASTLoadTrait extends LoadTrait
	{
		public function VASTLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			var cacheBuster:CacheBuster = new CacheBuster();
			var URLString:String = URLResource(resource).url;
			
			var bustedString:String = cacheBuster.cacheBustURL(URLString);
			var newResource:URLResource = new URLResource(bustedString);
			
			super(loader, newResource);
		}

		/**
		 * The root level object in the VAST document object model.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get vastDocument():VASTDataObject
		{
			return _vastDocument;
		}
		
		public function set vastDocument(value:VASTDataObject):void
		{
			_vastDocument = value;
		}
		
		private var _vastDocument:VASTDataObject;
	}
}