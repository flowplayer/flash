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
package org.osmf.vast
{
	/**
	 * Centralized test class for VAST constants, such as URLs to VAST documents.
	 **/
	public class VASTTestConstants
	{
		public static const IMPRESSION_URL1:String = "http://mediapm.edgesuite.net/strobe/content/test/train.jpg";
		public static const IMPRESSION_URL2:String = "http://mediapm.edgesuite.net/strobe/content/test/train.jpg";

		public static const MISSING_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/missing_vast_inline_ad_response.xml";
		
		public static const INVALID_XML_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/invalid_xml_vast_inline_ad_response.xml";
		public static const INVALID_XML_VAST_DOCUMENT_CONTENTS:String =
			"<NotValidXML>";

		public static const INVALID_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/invalid_vast_inline_ad_response.xml";
		public static const INVALID_VAST_DOCUMENT_CONTENTS:String =
			"<NotAVastDocument/>";

		public static const VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/sample_vast_inline_ad_response.xml";
		public static const VAST_DOCUMENT_CONTENTS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad id="myad">
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
						<Description>Spiderman video trailer</Description>
						<Survey>
							<URL><![CDATA[ http://www.dynamiclogic.com/tracker?campaignId=234&site=yahoo]]></URL>
						</Survey>
						<Error>
							<URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
						</Error>
						<Impression>
							<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
							<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?imp]]></URL>
						</Impression>
						<TrackingEvents>
							<Tracking event="start">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?start]]></URL>
							</Tracking>
							<Tracking event="midpoint">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?mid]]></URL>
							</Tracking>
							<Tracking event="firstQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?fqtl]]></URL>
							</Tracking>
							<Tracking event="thirdQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?tqtl]]></URL>
							</Tracking>
							<Tracking event="complete">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?comp]]></URL>
							</Tracking>
							<Tracking event="pause">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
							</Tracking>
							<Tracking event="replay">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
							</Tracking>
							<Tracking event="fullscreen">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
							</Tracking>
							<Tracking event="stop">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?stop]]></URL>
							</Tracking>
						</TrackingEvents>
						<Video>
							<Duration>00:00:15</Duration>
							<AdID>AdID</AdID>
							<VideoClicks>
								<ClickThrough>
									<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</ClickThrough>
								<ClickTracking>
									<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
									<URL id="athirdadsever"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</ClickTracking>
								<CustomClick>
									<URL id="redclick"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
									<URL id="blueclick"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</CustomClick>
							</VideoClicks>
							<MediaFiles>
								<MediaFile delivery="streaming" bitrate="250" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/low/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com//high/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/high/filename.wmv]]></URL>
			            </MediaFile>
			            <MediaFile delivery="streaming" bitrate="200" width="200" height="200" type="video/x-ms-wmv">
			                <URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/medium/filename.wmv]]></URL>
			            </MediaFile>
			            <MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-ms-wmv">
			                <URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.wmv]]></URL>
			            </MediaFile>
			            <MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
			                <URL><![CDATA[http://progressive.hostlocation.com//high/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="200" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/medium/filename.ra]]></URL>
			            </MediaFile>
			            <MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-ra">
			                <URL><![CDATA[rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.ra]]></URL>
			            </MediaFile>
			            <MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-ra">
			                <URL><![CDATA[http://progressive.hostlocation.com//high/filename.ra]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.ra]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.ra]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>
						<CompanionAds>
							<Companion id="rich media banner" width="468" height="60" resourceType="iframe" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
							<Companion id="banner" width="728" height="90" resourceType="script" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adj/etc.js]]></URL>
							</Companion>
							<Companion id="banner" width="468" height="60" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://media.doubleclick.net/foo.jpg]]></URL>
								<CompanionClickThrough>
									<URL><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</CompanionClickThrough>
							</Companion>
						</CompanionAds>
						<NonLinearAds>
							<NonLinear id="overlay" width="150" height="60" resourceType="static" creativeType="SWF" apiFramework="IAB">
								<URL><![CDATA[http://ad.server.com/adx/etc.xml]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
							<NonLinear id="bumper" width="250" height="300" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://ad.doubleclick.net/adx/etc.jpg]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
						</NonLinearAds>
						<Extensions>
							<Extension type="adServer">
								<TemplateVersion>3.002</TemplateVersion>
								<AdServingData>
									<DeliveryData>
										<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
										<MyAdId>43534850</MyAdId>
									</DeliveryData>
								</AdServingData>
							</Extension>
						</Extensions>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		public static const OUTER_WRAPPER_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/sample_vast_wrapper_ad_response1.xml";
		public static const OUTER_WRAPPER_VAST_DOCUMENT_CONTENTS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="myad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://flipside.corp.adobe.com/brian/strobe/vast/sample_vast_wrapper_ad_response2.xml]]></URL>
			    </VASTAdTagURL>
			    <Error>
			        <URL><![CDATA[http://www.wrapper.com/tracker?noPlay=true&impressionTracked=false]]></URL>
			    </Error>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?imp]]></URL>
			    </Impression>
			    <TrackingEvents>
			        <Tracking event="midpoint">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?mid]]></URL>
			        </Tracking>
			        <Tracking event="firstQuartile">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?fqtl]]></URL>
			        </Tracking>
			        <Tracking event="thirdQuartile">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?tqtl]]></URL>
			        </Tracking>
			        <Tracking event="complete">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?comp]]></URL>
			        </Tracking>
			        <Tracking event="mute">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?mute]]></URL>
			        </Tracking>
			        <Tracking event="pause">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?pause]]></URL>
			        </Tracking>
			        <Tracking event="replay">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?replay]]></URL>
			        </Tracking>
			        <Tracking event="fullscreen">
			            <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?full]]></URL>
			        </Tracking>
			     </TrackingEvents>
			     <VideoClicks>
			        <ClickTracking>
						 <URL id="myadsever"><![CDATA[http://www.wrapper.com/tracker?click]]></URL>
			        </ClickTracking>
			    </VideoClicks>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
			
		public static const INNER_WRAPPER_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/sample_vast_wrapper_ad_response2.xml";
		public static const INNER_WRAPPER_VAST_DOCUMENT_CONTENTS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="myad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://flipside.corp.adobe.com/brian/strobe/vast/sample_vast_inline_ad_response.xml]]></URL>
			    </VASTAdTagURL>
			    <Error>
			        <URL><![CDATA[http://www.secondarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
			    </Error>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?imp]]></URL>
			    </Impression>
			    <TrackingEvents>
			        <Tracking event="midpoint">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?mid]]></URL>
			        </Tracking>
			        <Tracking event="firstQuartile">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?fqtl]]></URL>
			        </Tracking>
			        <Tracking event="thirdQuartile">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?tqtl]]></URL>
			        </Tracking>
			        <Tracking event="complete">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?comp]]></URL>
			        </Tracking>
			        <Tracking event="mute">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?mute]]></URL>
			        </Tracking>
			        <Tracking event="pause">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?pause]]></URL>
			        </Tracking>
			        <Tracking event="replay">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?replay]]></URL>
			        </Tracking>
			        <Tracking event="fullscreen">
			            <URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?full]]></URL>
			        </Tracking>
			     </TrackingEvents>
			     <VideoClicks>
			        <ClickTracking>
						<URL id="myadsever"><![CDATA[http://www.secondarysite.com/tracker?click]]></URL>
			        </ClickTracking>
			     </VideoClicks>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
			
		public static const WRAPPER_WITH_INVALID_WRAPPED_VAST_DOCUMENT_URL:String = "http://flipside.corp.adobe.com/brian/strobe/vast/invalid_vast_wrapper_ad_response.xml";
		public static const WRAPPER_WITH_INVALID_WRAPPED_VAST_DOCUMENT_CONTENTS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="myad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://flipside.corp.adobe.com/brian/strobe/vast/missing_vast_inline_ad_response.xml]]></URL>
			    </VASTAdTagURL>
			    <Error>
			        <URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
			    </Error>
			    <Impression>
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
			    <TrackingEvents>
			        <Tracking event="midpoint">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
			        </Tracking>
			        <Tracking event="firstQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
			        </Tracking>
			        <Tracking event="thirdQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
			        </Tracking>
			        <Tracking event="complete">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
			        </Tracking>
			        <Tracking event="mute">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mute]]></URL>
			        </Tracking>
			        <Tracking event="pause">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
			        </Tracking>
			        <Tracking event="replay">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
			        </Tracking>
			        <Tracking event="fullscreen">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
			        </Tracking>
			     </TrackingEvents>
			        <VideoClicks>
			            <ClickTracking>
							 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
			            </ClickTracking>
			        </VideoClicks>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
	}
}