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

package org.osmf.player.configuration
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;

	public class TestConfigurationXMLDeserializer
	{
		[Before]
		public function setup():void
		{
			var injector:InjectorModule = new InjectorModule();			
			deserializer = injector.getInstance(ConfigurationXMLDeserializer);
			configuration = injector.getInstance(PlayerConfiguration);
		}
		
		[Test]
		public function testSrc():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var config:XML =
				<config>
					<src>{url}</src>
				</config>;
			
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
		}
		
		[Test]
		public function testSrcAttribute():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var config:XML =
				<config src={url}>
				</config>;;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
		}		
		
		
		[Test]
		public function testPlugin():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<plugin src={pluginUrl}>						
						<metadata id="NAMESPACE_D"> 
							<param name="account" value="gfgdfg"/>
							<param name="trackingServer" value="corp1.d1.sc.omtrdc.net"/>
						</metadata>
					</plugin>
				</config>;
			
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			
			assertEquals(1, pluginConfigurations.length);
			assertEquals(pluginUrl, (pluginConfigurations[0] as URLResource).url);
			assertEquals("gfgdfg", pluginConfigurations[0].getMetadataValue("NAMESPACE_D").getValue("account"));
			assertEquals("corp1.d1.sc.omtrdc.net", pluginConfigurations[0].getMetadataValue("NAMESPACE_D").getValue("trackingServer"));
		}
		
		[Test]
		public function testPluginInvalidMetadataElement():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<plugin src={pluginUrl}>						
						<invalid id="NAMESPACE_D"> 
							<param name="account" value="gfgdfg"/>
							<param name="trackingServer" value="corp1.d1.sc.omtrdc.net"/>
						</invalid>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals(1, pluginConfigurations.length);
			assertEquals(pluginUrl, (pluginConfigurations[0] as URLResource).url);
			assertNull(pluginConfigurations[0].getMetadataValue("NAMESPACE_D"));
		}
		
		[Test]
		public function testPluginMetadataNoNamespace():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<plugin src={pluginUrl}>						
						<metadata> 
							<param name="account" value="gfgdfg"/>
							<param name="trackingServer" value="corp1.d1.sc.omtrdc.net"/>
							<param name="mynumber" value="12345"/>
							<param name="bool" value="False"/>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals(1, pluginConfigurations.length);
			assertEquals(pluginUrl, (pluginConfigurations[0] as URLResource).url);
			assertEquals("gfgdfg", pluginConfigurations[0].getMetadataValue("account"));
			assertEquals("corp1.d1.sc.omtrdc.net", pluginConfigurations[0].getMetadataValue("trackingServer"));
			assertEquals(12345, pluginConfigurations[0].getMetadataValue("mynumber"));
			assertEquals(false, pluginConfigurations[0].getMetadataValue("bool"));

		}
		
		[Test]
		public function testPrimitiveBoolean():void			
		{
			var config:XML =
				<config>				
					<metadata> 
						<param name="bool" value="False"/>
					</metadata>
				</config>;
			deserializer.deserialize(config);
			assertEquals(false, configuration.metadata.bool);
		}
		
		[Test]
		public function testAssetMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<metadata id="NAMESPACE_D"> 
						<param name="account" value="gfgdfg"/>
						<param name="trackingServer" value="corp1.d1.sc.omtrdc.net"/>                        
					</metadata>
				</config>;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals("gfgdfg", configuration.metadata["NAMESPACE_D"]["account"]);
			assertEquals("corp1.d1.sc.omtrdc.net", configuration.metadata["NAMESPACE_D"]["trackingServer"]);
		}
		
		[Test]
		public function testAssetMetadataNoNamespace():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<metadata> 
						<param name="account" value="gfgdfg"/>
						<param name="trackingServer" value="corp1.d1.sc.omtrdc.net"/>                        
					</metadata>
				</config>;
			
			
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals("gfgdfg", configuration.metadata.account);
			assertEquals("corp1.d1.sc.omtrdc.net", configuration.metadata.trackingServer);
		}	
		
		
		[Test]
		public function testAssetMetadataComplexAllNoNamespace():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<metadata> 
						<time>13:59:58</time>
						<autoTrack>true</autoTrack>
						<trackSeconds>12</trackSeconds>
						<empty></empty>
						<urls type="array">
							<url>http://unu.com</url>
							<url>http://doi.com</url>
							<url>http://trei.com</url>
							<item>http://patru.com</item>
							<empty></empty>
						</urls>
						<objects type="array">
							<ob1>
								<child1>true</child1>
								<child2>unknown string</child2>
								<child3>100000</child3>
							</ob1>
							<ob2>
								<child1>false</child1>
								<child2>strings are good</child2>
								<child3>33.33</child3>
								<empty></empty>
							</ob2>
							<ob3>
								<child1>true</child1>
								<child2><![CDATA[my string <>& needs cdata]]></child2>
								<child3>-10</child3>
							</ob3>
						</objects>
						<deepobject1>
							<deepobject2>
								<deepobject3>
									<deepobject40>
										Deep value 4 0
									</deepobject40>
									<deepobject4>
										Deep value 4 
									</deepobject4>
									<empty></empty>
								</deepobject3>
							</deepobject2>
							<deepobject20>
								Deep value 2 0
							</deepobject20>
						</deepobject1>
						<emptyarray type="array">
						</emptyarray>
						<bigarray type="array">
							<urls1 type="array">
								<url>http://unu.com</url>
								<url>http://doi.com</url>
								<url>http://trei.com</url>
								<item>http://patru.com</item>
							</urls1>
							<urls1 type="array">
								<url>http://cinci.com</url>
								<url>http://sase.com</url>
								<url>http://sapte.com</url>
							</urls1>				
						</bigarray>
						<unknowntype type="unknown">
							Unknown
						</unknowntype>		
						<emptytype type="">
							emptytype
						</emptytype>	
						<arraywithouttype>
							<url>http://unu.com</url>
							<url>http://doi.com</url>
							<url>http://trei.com</url>
						</arraywithouttype>
						<twin>
							twin nr. 1
						</twin>	
						<twin>
							twin nr. 2
						</twin>                      
					</metadata>
				</config>;

			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals("13:59:58", configuration.metadata.time);
			assertEquals(true, configuration.metadata.autoTrack);
			assertEquals(12, configuration.metadata.trackSeconds);
			assertEquals("", configuration.metadata.empty);
			
			assertEquals(5, configuration.metadata.urls.length);
			assertEquals("http://patru.com", configuration.metadata.urls[3]);
			assertEquals("", configuration.metadata.urls[4]);
			
			assertEquals(3, configuration.metadata.objects.length);
//			assertEquals(true, configuration.metadata.urls[0].child1);
//			assertEquals(33.33, configuration.metadata.urls[1].child3);
//			assertEquals("my string <>& needs cdata", configuration.metadata.urls.objects[2].child2);
			
			assertEquals("Deep value 2 0", configuration.metadata.deepobject1.deepobject20);
			assertEquals("Deep value 4 0", configuration.metadata.deepobject1.deepobject2.deepobject3.deepobject40);
			assertEquals("Deep value 4", configuration.metadata.deepobject1.deepobject2.deepobject3.deepobject4);
			
			assertEquals(0, configuration.metadata.emptyarray.length);
			
			assertEquals("http://unu.com", configuration.metadata.bigarray[0][0]);
			assertEquals("http://sapte.com", configuration.metadata.bigarray[1][2]);

			assertEquals("Unknown", configuration.metadata.unknowntype);
			
			assertEquals("emptytype", configuration.metadata.emptytype);
			
			assertEquals(null, configuration.metadata.arraywithouttype.length);
			assertEquals("http://trei.com", configuration.metadata.arraywithouttype.url);
		
			assertEquals("twin nr. 2", configuration.metadata.twin);
			
		}	
		
		[Test]
		public function testOmnitureMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<account>jdoe</account>
							<debugTracking>true</debugTracking>
							<trackLocal>true</trackLocal>
							<account>jdoe</account>
							<visitorNamespace>corp1</visitorNamespace>
							<trackingServer>corp1.d1.sc.omtrdc.net</trackingServer>
							<pageName>OSMF Player</pageName>
							<Media>
								<trackWhilePlaying>true</trackWhilePlaying>
								<trackSeconds>15</trackSeconds>
								<autoTrack>true</autoTrack>
							</Media> 
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("jdoe", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].account);
			assertEquals(15, configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].Media.trackSeconds);
		}	
		
		
		[Test]
		public function testPluginAutodetectionNoMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>
					<src>{url}</src>
					<plugin src={pluginUrl}>		
						<metadata> 
							<mystring>jdoe</mystring>
							<myCdataString><![CDATA[my string <>& needs cdata]]></myCdataString>
							<mynumber>12</mynumber>
							<myfloat>12.12345678901</myfloat>
							<mynegativenumber>-10</mynegativenumber>
							<myCdataNumber><![CDATA[123.4]]></myCdataNumber>
							<myCdataBool><![CDATA[FaLsE]]></myCdataBool>
							<emptycdata><![CDATA[]]></emptycdata>
							<empty></empty>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(url, configuration.src);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("jdoe", configuration.plugins.p0.metadata.mystring);
			assertEquals("my string <>& needs cdata", configuration.plugins.p0.metadata.myCdataString);
			assertEquals(123.4, configuration.plugins.p0.metadata.myCdataNumber);
			assertEquals(false, configuration.plugins.p0.metadata.myCdataBool);
			assertEquals("", configuration.plugins.p0.metadata.emptycdata);
			assertEquals("", configuration.plugins.p0.metadata.empty);


			assertEquals(12, configuration.plugins.p0.metadata.mynumber);
			assertEquals(12.12345678901, configuration.plugins.p0.metadata.myfloat);
			assertEquals(-10, configuration.plugins.p0.metadata.mynegativenumber);
		}
		
		[Test]
		public function testPluginComplexArrayMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 					
							<medias type="Array">
								<Media>
									<trackWhilePlaying>true</trackWhilePlaying>
									<trackSeconds>14</trackSeconds>
									<autoTrack>true</autoTrack>
								</Media> 
								<Media>
									<trackWhilePlaying>true</trackWhilePlaying>
									<trackSeconds>15</trackSeconds>
									<autoTrack>true</autoTrack>
								</Media> 
							</medias>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals(14, configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].medias[0].trackSeconds);
		}	
		

		
		[Test]
		public function testPluginSimpleArrayMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<servers type="Array">
								<server>server1</server>
								<server>server2</server>
							</servers>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("server1", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers[0]);
			assertEquals("server2", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers[1]);
		}	
		
		[Test]
		public function testPluginArray1ElementMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<servers type="Array">
								<server>server1</server>
							</servers>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("server1", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers[0]);
		}	
		
		[Test]
		public function testPluginArrayNoElementMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<servers type="Array">
							</servers>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals(0, configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers.length);
		}	
		
		[Test]
		public function testPluginArrayEmptyElementMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<servers type="ArrAy">
									<server></server>
							</servers>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals(1, configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers.length);
			assertEquals("", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers[0]);
		}	
		
		[Test]
		public function testPluginArrayBadTypeMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<servers type="unknown">
									<server1>http://server1</server1>
									<server2>http://server2</server2>
							</servers>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals(null, configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers.length);
			assertEquals("http://server2", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].servers.server2);
		}
		
		[Test]
		public function testPluginArrayOfArraysMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<bigarray type="array">
								<urls1 type="array">
									<url>http://unu.com</url>
									<url>http://doi.com</url>
									<url>http://trei.com</url>
									<item>http://patru.com</item>
								</urls1>
								<urls1 type="array">
									<url>http://cinci.com</url>
									<url>http://sase.com</url>
									<url>http://sapte.com</url>
								</urls1>				
							</bigarray>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("http://unu.com", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].bigarray[0][0]);
			assertEquals("http://sapte.com", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].bigarray[1][2]);
		}	
		
		[Test]
		public function testPluginArrayWithoutTypeMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<arraynotype>
								<urls1>one
								</urls1>
								<urls1>two
								</urls1>				
							</arraynotype>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertNull(configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].arraynotype.length);
			assertEquals("two", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].arraynotype.urls1);
		}	
		
		[Test]
		public function testPluginSameNameMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 
							<twin>
								twin nr. 1
							</twin>	
							<twin>
								twin nr. 2
							</twin>	
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("twin nr. 2", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].twin);
		}	
		
		[Test]
		public function testPluginDeepObjectsMetadata():void			
		{
			var url:String = "http://mysite.com/my.flv";
			var pluginUrl:String = "http://mysite.com/myplugin.swf";
			var config:XML =
				<config>		
					<plugin src={pluginUrl}>		
						<metadata id="com.omniture.AppMeasurement"> 					
							<deepobject1>
								<deepobject2>
									<deepobject3>
										<deepobject40>
											Deep value 4 0
										</deepobject40>
										<deepobject4>
											Deep value 4 
										</deepobject4>
										<empty></empty>
									</deepobject3>
								</deepobject2>
								<deepobject20>
									Deep value 2 0
								</deepobject20>
							</deepobject1>
						</metadata>
					</plugin>
				</config>;
			deserializer.deserialize(config);
			assertEquals(pluginUrl, configuration.plugins.p0.src);
			assertEquals("Deep value 2 0", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].deepobject1.deepobject20);
			assertEquals("Deep value 4 0", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].deepobject1.deepobject2.deepobject3.deepobject40);
			assertEquals("Deep value 4", configuration.plugins.p0.metadata["com.omniture.AppMeasurement"].deepobject1.deepobject2.deepobject3.deepobject4);
		}
		
		private function get pluginConfigurations():Vector.<MediaResourceBase>
		{
			return ConfigurationUtils.transformDynamicObjectToMediaResourceBases(configuration.plugins);
		}
		
		private var deserializer:ConfigurationXMLDeserializer;
		private var configuration:PlayerConfiguration;
	}
}