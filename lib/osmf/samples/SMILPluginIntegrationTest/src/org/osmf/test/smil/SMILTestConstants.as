/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.test.smil
{
	/**
	 * Centralized test class for SMIL constants, such as URLs to SMIL documents.
	 **/
	public class SMILTestConstants
	{
		public static const MISSING_SMIL_DOCUMENT_URL:String = "http://bad.url.com//missing_smil.smil";
		
		public static const INVALID_SMIL_DOCUMENT_URL:String = "http://bad.url.com/smil/invalid_smil_response.xml";
		public static const INVALID_SMIL_DOCUMENT_CONTENTS:String = "<NotASMILDocument/>";

		private static const BASE_TEST_URL:String = "http://mediapm.edgesuite.net/osmf/content/test/smil/";

		public static const SMIL_DOCUMENT_SEQ_URL:String = BASE_TEST_URL + "seq-test.smil";
		public static const SMIL_DOCUMENT_PAR_URL:String = BASE_TEST_URL + "par-test.smil";
		
		public static const SMIL_DOCUMENT_MBR_URL:String = "http://mediapm.edgesuite.net/osmf/content/test/smil/elephants_dream.smil";
		
		public static const SMIL_DOCUMENT_CONTENTS:XML =
			<smil xmlns="http://www.w3.org/2005/SMIL21/Language">
			  <head>
			    <layout>
					<region id="banner" />
					<region id="content" />
			    </layout>
			  </head>
			  <body>
			    <seq>
					<video region="content" src="http://flipside.corp.adobe.com/test_assets/flv/COMBOVER_PEVX_7015_30.flv" dur="30s" />
					<video region="content" src="http://flipside.corp.adobe.com/test_assets/flv/HarryPotter5.flv" dur="132s" />
					<video region="content" src="http://flipside.corp.adobe.com/test_assets/flv/COMBOVER_PEVX_7015_30.flv" dur="30s" />
			    </seq>
			  </body>
			</smil>
			
		public static const SMIL_DOCUMENT_CONTENTS_FULL:XML = 
			<smil xmlns="http://www.w3.org/2005/SMIL21/Language">
			  <head>
			    <layout>
				<region id="banner" />
				<region id="content" />
				<region id="logo" />
			    </layout>
			  </head>
			  <body>
			    <par>
			      <seq>
			        <par>
					  <img region="banner" src="http://flipside.corp.adobe.com/testing/mod_flipside/imgs/MOD_banner1.gif" dur="50s" type="image/gif" />
					  <img region="logo" src="http://flipside.corp.adobe.com/testing/mod_flipside/imgs/MOD_logo1.jpg" dur="50s"/>
					</par>
					<par>
					  <audio src="http://example.com/song1.mp3" dur="50s" />
					</par>
					<par>
					  <image region="banner" src="http://flipside.corp.adobe.com/testing/mod_flipside/imgs/MOD_banner3.gif" dur="50s" type="image/jpeg" />
					  <image region="logo" src="http://flipside.corp.adobe.com/testing/mod_flipside/imgs/MOD_logo1.jpg" dur="50s"/>
					</par>
			      </seq>
			      <seq>
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-1.flv" dur="20.58s" />
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-2.flv" dur="17.07s" />
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-3.flv" dur="21.2s" />
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-4.flv" dur="31.579s" />
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-5.flv" dur="24.88s" />
					<video region="content" src="http://flipside.corp.adobe.com/testing/pirates3/Pirates3-6.flv" dur="36.842s" />
			      </seq>
			    </par>
			  </body>
			</smil>
						
		public static const SMIL_DOCUMENT_CONTENTS_NO_BODY:XML = 
			<smil xmlns="http://www.w3.org/2005/SMIL21/Language">
			  <head>
			    <layout>
				<region id="banner" />
				<region id="content" />
			    </layout>
			  </head>
			    <seq>
					<video region="content" src="http://flipside.corp.adobe.com/test_assets/flv/HarryPotter5.flv" dur="132s" />
			    </seq>
			</smil>
			
		public static const SMIL_DOCUMENT_CONTENTS_MBR:XML = 
			<smil>
			  <head>
			    <meta base="rtmp://cp67126.edgefcs.net/ondemand" />
			  </head>
			  <body>
			    <switch>
			      <video src="mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_408kbps.mp4" system-bitrate="408000"/>
			      <video src="mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_608kbps.mp4" system-bitrate="608000"/>
			      <video src="mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_908kbps.mp4" system-bitrate="908000"/>
			      <video src="mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_1308kbps.mp4" system-bitrate="1308000"/>
			      <video src="mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1280x720_24.0fps_1708kbps.mp4" system-bitrate="1708000"/>
			    </switch>
			  </body>
			</smil>
		
	}
}
