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
 * 
 **********************************************************/

package
{
	import org.osmf.youtube.*;
	import org.osmf.youtube.media.*;
	import org.osmf.youtube.net.*;
	import org.osmf.youtube.traits.*;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class YoutubePluginTests
	{
		public var testYoutubeTimeTrait:TestYoutubeTimeTrait;
		public var testYoutubeSeekTrait:TestYoutubeSeekTrait;
		public var testYoutubeAudioTrait:TestYoutubeAudioTrait;
		public var testYoutubePlayTrait:TestYoutubePlayTrait;
		public var testYoutubeDynamicStreamTrait:TestYoutubeDynamicStreamTrait;
		public var testYoutubePluginInfo:TestYoutubePluginInfo;
		public var testYoutubePlugin:TestYouTubePlugin;
		public var testYoutubeLoader:TestYoutubeLoader;
		public var testYoutubeElement:TestYoutubeElement;
	}
}