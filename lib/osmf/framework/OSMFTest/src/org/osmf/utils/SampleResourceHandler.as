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
package org.osmf.utils
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	
	public class SampleResourceHandler
	{
		/**
		 * Either pass in a handler, or give this handler a URL to match.
		 **/
		public function SampleResourceHandler(handler:Function,urlToMatch:String=null):void
		{
			this.handler = handler;
			this.urlToMatch = urlToMatch;
		}
		
		public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var result:Boolean = false;
			
			if (handler != null)
			{
				result = handler.call(null,resource);
			}
			else
			{
				var urlResource:URLResource = resource as URLResource;
				if (urlResource)
				{
					result = (urlResource.url.toString() == urlToMatch);
				}
			}
			
			return result;
		}

		private var handler:Function;
		private var urlToMatch:String;
	}
}