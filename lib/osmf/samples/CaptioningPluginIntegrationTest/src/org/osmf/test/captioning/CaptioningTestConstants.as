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

package org.osmf.test.captioning
{
	/**
	 * Centralized test class for Captioning constants, such as URLs to Captioning documents.
	 **/
	public class CaptioningTestConstants
	{
		public static const MISSING_CAPTIONING_DOCUMENT_URL:String = "http://bad.url.com//missing_captioning.xml";
		
		public static const INVALID_XML_CAPTIONING_DOCUMENT_URL:String = "http://bad.url.com/captioning/invalid_xml_captioning_response.xml";
		public static const INVALID_XML_CAPTIONING_DOCUMENT_CONTENTS:String = "<NotValidXML>";

		public static const INVALID_CAPTIONING_DOCUMENT_URL:String = "http://bad.url.com/captioning/invalid_captioning_response.xml";
		public static const INVALID_CAPTIONING_DOCUMENT_CONTENTS:String = "<NotACaptioningDocument/>";

		private static const BASE_W3C_TEST_SUITE_URL:String = "http://mediapm.edgesuite.net/osmf/content/test/captioning/dfxp-testsuite/";

		public static const CAPTIONING_DOCUMENT_URL:String = BASE_W3C_TEST_SUITE_URL + "Content/Br001.xml";
		
		public static const CAPTIONING_DOCUMENT_CONTENTS:XML =
			<tt xml:lang="en"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
			  <head>
			    <metadata> 
			      <ttm:title>Content Test - Br - 001</ttm:title>
			      <ttm:desc>Test the br element.</ttm:desc>
			      <ttm:copyright>Copyright (C) 2008 W3C (MIT, ERCIM, Keio).</ttm:copyright>
			    </metadata>
			  </head>
			  <body>
			    <div>
			      <p begin="0s" end="10s">This text must be on the first line.<br/>This text on a second line.</p>
			    </div>
			  </body>
			</tt>
			
		public static const CAPTIONING_DOCUMENT_CONTENTS_FULL:XML = 
			<tt xml:lang="en"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
			  <head>
			    <metadata> 
			      <ttm:title>Content Test - Br - 001</ttm:title>
			      <ttm:desc>Test the br element.</ttm:desc>
			      <ttm:copyright>Copyright (C) 2008 W3C (MIT, ERCIM, Keio).</ttm:copyright>
			    </metadata>
				<styling>
					<style id="s1" tts:fontStyle="italic" tts:fontWeight="bold"/>
					<style id="s2" tts:fontStyle="italic"/>
					<style id="s3" tts:backgroundColor="red" tts:color="green"/>
					<style id="s4" tts:wrapOption="nowrap"/>
					<style id="s5" tts:color="#aabbff"/>
					<style id="s6" tts:color="#aabbffaa"/>
					<style id="s7" tts:color="rgb(255,0,0)"/>
					<style id="s8" tts:color="rgba(0,255,0,125)"/>
					<style id="s9" tts:color="bogus"/>
					<style id="s10" tts:color="0xffcccc"/>
					<style id="s11" tts:fontFamily="proportionalSansSerif"/>
					<style id="s12" tts:fontFamily="monospace,sansSerif"/>
					<style id="s13" tts:fontFamily="Verdana"/>	
					<style id="s14" tts:fontFamily="Bogus 12345"/>
					<style id="s15" tts:fontFamily="default, monospace, sanSerif"/>
					<style id="s16" tts:fontSize="12"/>
					<style id="s16" tts:fontSize="12%"/>
					<style id="s16" tts:fontSize="+12"/>
					<style id="s16" tts:fontSize="12.4"/>
					<style id="s16" tts:fontSize="12px"/>									
				</styling>
			  </head>
			  <body>
			    <div>
			      <p begin="0s" end="10s">This text must be on the first line.<br/>This text on a second line.</p>
			      <p begin="00:00:11:00">Second caption.</p>
			      <p begin="5h">I don't we are ever <span style="s1">going to</span> see <span style="s2">this</span> one.</p>
			      <p begin="3m">Show this one at <span>3</span> minutes.</p>
			      <p begin="10">Seconds with no <span><br/></span>qualifier.</p>
			      <p>No begin or end <span style="s3">tag</span> on this one.</p>
			      <p dur="15s">Caption with a dur.</p>
			      <p>
					<span tts:display="none">
					      <set begin="1s" dur="1s" tts:display="auto"/>
					      This is a caption.
					    </span>
				  </p>
			      
			    </div>
			  </body>
			</tt>
			
		public static const CAPTIONING_DOCUMENT_CONTENTS_NO_BODY:XML = 
			<tt xml:lang="en"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
			  <head>
			    <metadata> 
			      <ttm:title>Content Test - Br - 001</ttm:title>
			      <ttm:desc>Test the br element.</ttm:desc>
			      <ttm:copyright>Copyright (C) 2008 W3C (MIT, ERCIM, Keio).</ttm:copyright>
			    </metadata>
			  </head>
			    <div>
			      <p begin="0s" end="10s">This text must be on the first line.<br/>This text on a second line.</p>
			    </div>
			</tt>

		public static const CAPTIONING_DOCUMENT_CONTENTS_NO_DIV:XML = 
			<tt xml:lang="en"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
			  <head>
			    <metadata> 
			      <ttm:title>Content Test - Br - 001</ttm:title>
			      <ttm:desc>Test the br element.</ttm:desc>
			      <ttm:copyright>Copyright (C) 2008 W3C (MIT, ERCIM, Keio).</ttm:copyright>
			    </metadata>
			  </head>
			  <body>
			      <p begin="0s" end="10s">This text must be on the first line.<br/>This text on a second line.</p>
			  </body>
			</tt>
			
	}
}
