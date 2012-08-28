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
package org.osmf.media
{
	import org.osmf.elements.beaconClasses.Beacon;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicBeaconElement;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.MockHTTPLoader;
	
	public class TestMediaPlayerWithBeaconElement extends TestMediaPlayer
	{
		// Overrides
		//
		
		override public function setUp():void
		{
			// Change this to HTTPLoader to run against the network.
			httpLoader = new MockHTTPLoader();
			
			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			httpLoader = null;
		}
				
		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			if (httpLoader is MockHTTPLoader)
			{
				MockHTTPLoader(httpLoader).setExpectationForURL(PING_URL, true, null);
				MockHTTPLoader(httpLoader).setExpectationForURL(INVALID_URL, false, null);
			}
			
			return new DynamicBeaconElement(new Beacon(PING_URL, httpLoader));
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return false;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new URLResource(PING_URL)
		}

		override protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			return new URLResource(INVALID_URL);
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.PLAY];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [MediaTraitType.PLAY];
		}
		
		[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
		
		private static const PING_URL:String = "http://example.com";
		private static const INVALID_URL:String = "http://www.adobe.com/invalidURL";
		
		private var httpLoader:HTTPLoader;
	}
}
