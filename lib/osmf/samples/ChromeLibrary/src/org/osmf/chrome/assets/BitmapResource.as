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
	import flash.geom.Rectangle;
	
	public class BitmapResource extends AssetResource
	{
		public function BitmapResource(id:String, url:String, local:Boolean, scale9:Rectangle)
		{
			_scale9 = scale9;
			
			super(id, url, local);
		}
		
		public function get scale9():Rectangle
		{
			return _scale9;	
		}
		
		private var _scale9:Rectangle;
	}
}