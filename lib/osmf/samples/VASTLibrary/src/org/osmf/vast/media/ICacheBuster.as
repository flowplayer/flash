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
	
	public interface ICacheBuster 
	{
		function cacheBustURL(urlToTag:String, cacheBusterType:String = 'VIDEO'):String;
		
		function randomizeCacheBuster(cacheBusterType:String, refresh:Boolean):void;
		
		function replaceWildcardWithCacheBuster( urlToTag:String, cacheBuster:Number ):String;
		
		function get adCacheBuster():Number;
		
		function set adCacheBuster(newNumber:Number):void;
		
		function get videoCacheBuster():Number;
		
		function set videoCacheBuster(newNumber:Number):void;
		
		function get randomNumber():Number;
		
		
	}
}
