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
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	/**
	 * Loader for the VideoProxyElement.  The load operation simply generates
	 * the new URL to apply.
	 **/
	public class VideoProxyLoader extends LoaderBase
	{
		/**
		 * @private
		 **/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			// Always true, for simplicity.
			return true;
		}
		
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			// Here's a new URL, this will replace the previous URL.
			// Note that this class could do other preflight activities
			// (we just rewrite the URL as an example).
			var url:String = "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
			
			var vpLoadTrait:VideoProxyLoadTrait = loadTrait as VideoProxyLoadTrait;
			vpLoadTrait.url = url;
			updateLoadTrait(loadTrait, LoadState.READY);
		}
	}
}