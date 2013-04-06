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

package
{
	
			import flexunit.framework.Test;			
						
			import org.osmf.youtube.traits.TestYoutubeTimeTrait;
			import org.osmf.youtube.traits.TestYoutubeSeekTrait;
			import org.osmf.youtube.traits.TestYoutubePlayTrait;
			import org.osmf.youtube.traits.TestYoutubeDynamicStreamTrait;
			import org.osmf.youtube.traits.TestYoutubeAudioTrait;
			import org.osmf.youtube.net.TestYoutubeLoader;
			import org.osmf.youtube.media.TestYoutubeElement;
			import org.osmf.youtube.TestYoutubePluginInfo;
			
			public class YoutubePluginTests
			{
				public static var testsToRun:Array = new Array();
				
				public static function currentRunTestSuite():Array
				{
					
				testsToRun.push(org.osmf.youtube.TestYoutubePluginInfo);
				testsToRun.push(org.osmf.youtube.media.TestYoutubeElement);
				testsToRun.push(org.osmf.youtube.net.TestYoutubeLoader);
				testsToRun.push(org.osmf.youtube.traits.TestYoutubeAudioTrait);
				testsToRun.push(org.osmf.youtube.traits.TestYoutubeDynamicStreamTrait);
				testsToRun.push(org.osmf.youtube.traits.TestYoutubePlayTrait);
				testsToRun.push(org.osmf.youtube.traits.TestYoutubeSeekTrait);
				testsToRun.push(org.osmf.youtube.traits.TestYoutubeTimeTrait);
				return testsToRun;
					
					return testsToRun;
					
				}
			}
}