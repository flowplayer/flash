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
package org.osmf.metadata
{
	import flexunit.framework.Assert;

	public class TestTimelineMarker
	{
		[Test]
		public function testTimelineMarker():void
		{
			var marker:TimelineMarker = new TimelineMarker(120, 5);
			
			Assert.assertEquals(120, marker.time);
			Assert.assertEquals(5, marker.duration);
		}
		
		[Test]
		public function testTimelineMarkerNaN():void
		{
			var marker:TimelineMarker = new TimelineMarker(37);
			
			Assert.assertEquals(37, marker.time);
			Assert.assertEquals(NaN, marker.duration);
		}
	}
}
