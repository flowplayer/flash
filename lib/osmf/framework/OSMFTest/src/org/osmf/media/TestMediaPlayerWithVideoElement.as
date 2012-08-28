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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.media
{
	import org.osmf.elements.VideoElement;
	import org.osmf.netmocker.MockNetLoader;
	import org.osmf.netmocker.NetConnectionExpectation;
	import org.osmf.utils.TestConstants;
	
	public class TestMediaPlayerWithVideoElement extends TestMediaPlayerWithLightweightVideoElement
	{
		// Overrides
		//
				
		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			if (loader is MockNetLoader)
			{
				// Give our mock loader an arbitrary duration and size to ensure
				// we get metadata.
				MockNetLoader(loader).netStreamExpectedDuration = 1;//TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_DURATION;
				MockNetLoader(loader).netStreamExpectedWidth = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_WIDTH;
				MockNetLoader(loader).netStreamExpectedHeight = TestConstants.REMOTE_PROGRESSIVE_VIDEO_EXPECTED_HEIGHT;
			
				if (resource == INVALID_RESOURCE)
				{
					MockNetLoader(loader).netConnectionExpectation = NetConnectionExpectation.INVALID_FMS_APPLICATION;
				}
			}

			return new VideoElement(resource, loader);
		}
		
		[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
	}
}
