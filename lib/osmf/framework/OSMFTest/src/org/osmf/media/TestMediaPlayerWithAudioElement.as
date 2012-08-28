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
	import org.osmf.elements.AudioElement;
	import org.osmf.net.NetLoader;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.netmocker.NetConnectionExpectation;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.NetFactory;
	import org.osmf.utils.TestConstants;
	
	public class TestMediaPlayerWithAudioElement extends TestMediaPlayer
	{
		// Overrides
		//
				
		override public function setUp():void
		{
			netFactory = new NetFactory();
			loader = netFactory.createNetLoader();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			loader = null;
			netFactory = null;
		}

		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			if (loader is MockNetLoader)
			{
				// Give our mock loader an arbitrary duration.
				MockNetLoader(loader).netStreamExpectedDuration = 1;
			
				if (resource == INVALID_RESOURCE)
				{
					MockNetLoader(loader).netConnectionExpectation = NetConnectionExpectation.INVALID_FMS_APPLICATION;
				}
			}

			return new AudioElement(resource as URLResource, loader);
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return true;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			// Use a valid URL so that the tests will pass if we use
			// a real NetLoader rather than a MockNetLoader.
			return new URLResource(TestConstants.STREAMING_AUDIO_FILE);
		}

		override protected function get invalidResourceForMediaElement():MediaResourceBase
		{
			// Use an invalid URL so that the tests will fail if we use
			// a real NetLoader rather than a MockNetLoader.
			return INVALID_RESOURCE;
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.LOAD];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [ MediaTraitType.AUDIO
				   , MediaTraitType.BUFFER
				   , MediaTraitType.LOAD
				   , MediaTraitType.PLAY
				   , MediaTraitType.SEEK
				   , MediaTraitType.TIME
				   ];
		}
		
		[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
		
		// Internals
		//

		private static const INVALID_RESOURCE:URLResource = new URLResource(TestConstants.INVALID_STREAMING_AUDIO_FILE);
		
		private var netFactory:NetFactory;
		private var loader:NetLoader;
	}
}
