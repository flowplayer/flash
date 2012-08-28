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
package
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;

	/**
	 * JavaScriptPlaylist hello world sample
	 **/
	public class JavaScriptPlaylist extends Sprite
	{
		public function JavaScriptPlaylist()
		{
 			sprite = new MediaPlayerSprite();
			addChild(sprite);
			sprite.resource = new URLResource("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");
			
			if (ExternalInterface.available)
			{
				// Register a javascript callback function
				ExternalInterface.addCallback("setResourceURL", setResourceURL);
				
				// Notify the hosting page that the player is ready to be controlled
				var callbackFunction:String = 
					"function(objectID) {" +
					"  if (typeof onHelloWorldJavaScriptLoaded == 'function') { " +
					"    onHelloWorldJavaScriptLoaded(objectID); " +
					"  } " +
					"} ";
				ExternalInterface.call(callbackFunction, ExternalInterface.objectID);
			}
		}
		
		/**
		 * Creates an URL resource and starts playing it.
		 */ 
		public function setResourceURL(url:String):void
		{
			sprite.resource = new URLResource(url);			
		}
		
		private var sprite:MediaPlayerSprite;
	}
}
