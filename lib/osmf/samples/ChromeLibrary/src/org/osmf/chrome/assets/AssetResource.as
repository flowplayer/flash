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

package org.osmf.chrome.assets
{
	public class AssetResource
	{
		public function AssetResource(id:String, url:String, local:Boolean)
		{
			_id = id;
			_url = url;
			_local = local;
		}

		public function get id():String
		{
			return _id;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function get local():Boolean
		{
			return _local;
		}
		
		private var _id:String;
		private var _url:String;
		private var _local:Boolean;
	}
}