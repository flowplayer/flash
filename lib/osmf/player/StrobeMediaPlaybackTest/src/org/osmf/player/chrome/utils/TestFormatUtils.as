/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.chrome.utils
{
	import org.flexunit.asserts.assertEquals;

	public class TestFormatUtils
	{
		[Test]
		public function formatTimeStatusStart():void
		{
			assertEquals("0:00 / 0:00", FormatUtils.formatTimeStatus(0, 0, false).join(" / "));
		}
		
		[Test]
		public function formatTimeStatusLive():void
		{
			assertEquals("Live / 0:00", FormatUtils.formatTimeStatus(0, 0, true).join(" / "));
		}
		
		[Test]
		public function formatTimeStatusHoursLive():void
		{
			assertEquals("   Live / 3:58:03", FormatUtils.formatTimeStatus(60*60*3+58*60, 60*60*3+58*60+3, true).join(" / "));
		}
		
		[Test]
		public function formatTimeStatusHours():void
		{
			assertEquals("3:58:00 / 3:58:03", FormatUtils.formatTimeStatus(60*60*3+58*60, 60*60*3+58*60+3, false).join(" / "));
		}
		
		[Test]
		public function formatTimeStatusMinutesLive():void
		{
			assertEquals(" Live / 58:03", FormatUtils.formatTimeStatus(58*60, 58*60+3, true).join(" / "));
		}
		
		[Test]
		public function formatTimeStatusMinutes():void
		{
			assertEquals("00:03 / 58:03", FormatUtils.formatTimeStatus(3, 58*60+3, false).join(" / "));
		}
		
		[Test]
		public function formatLiveOnly():void
		{
			assertEquals("0:03 / Live", FormatUtils.formatTimeStatus(3, NaN, false).join(" / "));
		}
	}
}