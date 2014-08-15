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
package org.osmf.utils
{
	/**
	 * Centralized test class for constants, such as URLs to resources.
	 * 
	 * If your test is the only one that needs a constant, then the
	 * constant should be scoped to the test class.  Only place it here
	 * if it makes sense for multiple test classes to use it.
	 **/
	public class TestConstants
	{
		// Videos
		//
		
		public static const REMOTE_PROGRESSIVE_VIDEO:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
		public static const REMOTE_PROGRESSIVE_VIDEO_EXPECTED_DURATION:Number = 30;
		public static const REMOTE_PROGRESSIVE_VIDEO_EXPECTED_WIDTH:Number = 640;
		public static const REMOTE_PROGRESSIVE_VIDEO_EXPECTED_HEIGHT:Number = 352;
		public static const REMOTE_PROGRESSIVE_VIDEO_EXPECTED_BYTES:Number = 12345;
		
		public static const REMOTE_STREAMING_VIDEO:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
		public static const REMOTE_STREAMING_VIDEO_EXPECTED_DURATION:Number = 35;
		public static const REMOTE_STREAMING_VIDEO_EXPECTED_WIDTH:Number = 640;
		public static const REMOTE_STREAMING_VIDEO_EXPECTED_HEIGHT:Number = 352;
		
		public static const REMOTE_STREAMING_VIDEO_RTMP:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_RTMPS:String
			= "rtmps://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_RTMPT:String
			= "rtmpt://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_RTMPE:String
			= "rtmpe://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_RTMPTE:String
			= "rtmpte://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_1935:String
			= "rtmp://cp67126.edgefcs.net:1935/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
		
		public static const REMOTE_STREAMING_VIDEO_443:String
			= "rtmp://cp67126.edgefcs.net:443/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const REMOTE_STREAMING_VIDEO_80:String
			= "rtmp://cp67126.edgefcs.net:80/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
			
		public static const INVALID_STREAMING_VIDEO:String
			= "rtmp://cp67126.edgefcsfail.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv"
		
		public static const DEFAULT_PORT_PROTOCOL_RESULT:String = "1935rtmp443rtmp80rtmp1935rtmps443rtmps80rtmps1935rtmpt443rtmpt80rtmpt";
		
		public static const RESULT_FOR_RTMPTE_443:String = "443rtmpte";
		
		public static const REMOTE_STREAMING_VIDEO_WITH_PORT_PROTOCOL:String
			= "rtmpte://cp67126.edgefcs.net:443/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv";
		
		public static const CONNECT_ADDRESS_REMOTE_WITH_RTMPTE_443:String = "rtmpte://cp67126.edgefcs.net:443/ondemand";
		
		public static const REMOTE_DYNAMIC_STREAMING_VIDEO_HOST:String = "rtmp://cp60395.edgefcs.net/ondemand";
		
		public static const REMOTE_DYNAMIC_STREAMING_VIDEO_STREAMS:Array =
		[ 
			{stream:"mp4:videos/encoded2/Train_450kbps.mp4", bitrate:"450000"},
			{stream:"mp4:videos/encoded2/Train_700kbps.mp4", bitrate:"700000"},
			{stream:"mp4:videos/encoded2/Train_900kbps.mp4", bitrate:"900000"},
			{stream:"mp4:videos/encoded2/Train_1000kbps_H.mp4", bitrate:"1000000"},
		]
		
		public static const REMOTE_STREAMING_VIDEO_LIVE:String
			= "rtmp://cp34973.live.edgefcs.net/live/Flash_live_bm_500K@9319";

		// Images
		//
		
		public static const REMOTE_IMAGE_FILE:String = "http://mediapm.edgesuite.net/strobe/content/test/train.jpg";
		public static const REMOTE_INVALID_IMAGE_FILE:String = "http://mediapm.edgesuite.net/fail/strobe/content/test/train.jpg";
		
		public static const LOCAL_IMAGE_FILE:String = "assets/image.gif";

		// Audio
		//
		
		public static const LOCAL_SOUND_FILE:String = "assets/sound.mp3";
		public static const LOCAL_SOUND_FILE_EXPECTED_BYTES:Number = 30439;
		public static const LOCAL_INVALID_SOUND_FILE:String = "assets/invalid.mp3";
		
		public static const STREAMING_AUDIO_FILE:String
			= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";

		public static const INVALID_STREAMING_AUDIO_FILE:String
			= "rtmp://cp67126.edgefcsfail.net/ondemand/mp3:mediapm/ovp/content/test/video/nocc_small.mp3";
			
		// HTTP Streaming
		//
		
		// This bootstrap box was taken from the <bootstrapInfo> field generated
		// for the shuttle-720p video's manifest, which is located here:
		// 		http://fms1j009f.corp.adobe.com/zeri-media/Fragments_Source_Media_Unprotected/MBR/shuttle/shuttle-mbr.f4m
		// TODO: Post this and the media file publicly when we have a place to put them. 
		public static const ABST_BOX_DATA:String = "AAABGmFic3QAAAAAAAAADwAAAAPoAAAAAAAA7ekAAAAAAAAAAAAAAAAAAQAAABlhc3J0AAAAAAAAAAABAAAAAQAAAA8BAAAA1WFmcnQAAAAAAAAD6AAAAAAMAAAAAQAAAAAAAAAAAAARMAAAAAMAAAAAAAAiaAAADOQAAAAEAAAAAAAAL1AAABEwAAAABgAAAAAAAFG4AAAM5AAAAAcAAAAAAABeoAAAETAAAAAJAAAAAAAAgSoAAAyAAAAACgAAAAAAAI3OAAARMAAAAAsAAAAAAACfAwAADtgAAAAMAAAAAAAArd8AABEwAAAADQAAAAAAAL8TAAAM5AAAAA4AAAAAAADL+gAAETAAAAAPAAAAAAAA3S8AABDM";
		
		// This AFRA box was taken from the shuttle-720p.f4x file, which is located here:
		//		http://fms1j009f.corp.adobe.com/zeri-media/Fragments_Source_Media_Unprotected/MBR/shuttle/shuttle-720p.f4x
		// TODO: Post this and the media file publicly when we have a place to put them.
		public static const AFRA_BOX_DATA:String = "AAAB+WFmcmEAAAAA4AAAA+gAAAAAAAAADwAAAAAAAAAAAAAAAQAAAAEAAAAAAAofUgAAAAAAAAAAAAAAAAAAETQAAAABAAAAAgAAAAAAQCdbAAAAAAAAAAAAAAAAAAAiaAAAAAEAAAADAAAAAABy3ZgAAAAAAAAAAAAAAAAAAC9QAAAAAQAAAAQAAAAAAJdI4QAAAAAAAAAAAAAAAAAAQIQAAAABAAAABQAAAAAA0CltAAAAAAAAAAAAAAAAAABRuAAAAAEAAAAGAAAAAAECGTsAAAAAAAAAAAAAAAAAAF6gAAAAAQAAAAcAAAAAASF1lwAAAAAAAAAAAAAAAAAAb9QAAAABAAAACAAAAAABX6IMAAAAAAAAAAAAAAAAAACBKgAAAAEAAAAJAAAAAAGaRKgAAAAAAAAAAAAAAAAAAI3OAAAAAQAAAAoAAAAAAcAHowAAAAAAAAAAAAAAAAAAnwMAAAABAAAACwAAAAAB49KkAAAAAAAAAAAAAAAAAACt3wAAAAEAAAAMAAAAAAIYd80AAAAAAAAAAAAAAAAAAL8TAAAAAQAAAA0AAAAAAkrsbAAAAAAAAAAAAAAAAAAAy/oAAAABAAAADgAAAAACcR6jAAAAAAAAAAAAAAAAAADdLwAAAAEAAAAPAAAAAAKuC8cAAAAAAAAAAA==";
	}
}