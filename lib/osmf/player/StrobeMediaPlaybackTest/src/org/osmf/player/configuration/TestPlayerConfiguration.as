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
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.URLResource;
	import org.osmf.player.configuration.*;
	
	
	public class TestPlayerConfiguration
	{			
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			var injector:InjectorModule = new InjectorModule();
			defaultPlayerConfiguration = injector.getInstance(ConfigurationProxy);
		}
		
		[Before]
		public function setup():void
		{
			injector = new InjectorModule();
			playerConfiguration = injector.getInstance(ConfigurationProxy);
			deserializer = injector.getInstance(ConfigurationFlashvarsDeserializer);
		}
		
		[After]
		public function tearDown():void
		{
			parameters = null;
			playerConfiguration = null;
		}
		
		//------------------------------------- default values
		[Test(description="Test default values for all parameters")]
		public function testDefaults():void
		{
			//test the default value.
			parameters = {
				//empty
			};			
			deserializer.deserialize(parameters);
			assertEquals("backgroundColor is not default", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor );
			assertEquals("src is not default", defaultPlayerConfiguration.src , playerConfiguration.src );
			assertEquals("autoHideControlBar is not default", defaultPlayerConfiguration.controlBarAutoHide, playerConfiguration.controlBarAutoHide );
			assertEquals("autoSwitchQuality is not default", defaultPlayerConfiguration.autoSwitchQuality , playerConfiguration.autoSwitchQuality );		
			assertEquals("loop is not default", defaultPlayerConfiguration.loop, playerConfiguration.loop );
			assertEquals("autoPlay is not default", defaultPlayerConfiguration.autoPlay , playerConfiguration.autoPlay );
			assertEquals("initialBufferTime is not default", defaultPlayerConfiguration.initialBufferTime, playerConfiguration.initialBufferTime );
			assertEquals("expandedBufferTime is not default", defaultPlayerConfiguration.expandedBufferTime , playerConfiguration.expandedBufferTime );
			assertEquals("scaleMode is not default", defaultPlayerConfiguration.scaleMode, playerConfiguration.scaleMode );
			assertEquals("controlBarPosition is not default", defaultPlayerConfiguration.controlBarMode , playerConfiguration.controlBarMode );
			assertEquals("smoothing is not default", defaultPlayerConfiguration.videoRenderingMode, playerConfiguration.videoRenderingMode );
			
/*			//change to this values when values are established
			assertEquals("backgroundColor is not default", 0, playerConfiguration.backgroundColor );
			assertEquals("src is not default", "" , playerConfiguration.src );
			assertEquals("controlBarAutoHide is not default", true, playerConfiguration.controlBarAutoHide );
			assertEquals("autoSwitchQuality is not default", true , playerConfiguration.autoSwitchQuality );		
			assertEquals("loop is not default", false, playerConfiguration.loop );
			assertEquals("autoPlay is not default", false , playerConfiguration.autoPlay );
			assertEquals("initialBufferTime is not default", 1, playerConfiguration.initialBufferTime );
			assertEquals("expandedBufferTime is not default", 10 , playerConfiguration.expandedBufferTime );
			assertEquals("scaleMode is not default", ScaleMode.LETTERBOX, playerConfiguration.scaleMode );
			assertEquals("controlBarMode is not default", ControlBarPosition.BOTTOM , playerConfiguration.controlBarMode );
			assertEquals("smoothing is not default", Smoothing.AUTO, playerConfiguration.smoothing );
*/						
		}
		
		//------------------------------------- src
		
		[Test(description="Test src settings valid url")]
		public function testSrcSettingsValid():void
		{
			parameters = {
				src:"http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv?test=a%20%20b&mimi=titi"
			};			
			deserializer.deserialize(parameters);
			assertEquals("src not correctly set", parameters.src, playerConfiguration.src);			
		}
		
		[Test(description="Test src settings nonvalid url")]
		public function testSrcSettingsInvalid1():void		
		{
			parameters = {
				src:"://http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv"
			};			
			deserializer.deserialize(parameters);
			assertEquals("invalid src is set", defaultPlayerConfiguration.src, playerConfiguration.src);			
		}
		
		[Test(description="Test src settings javascript")]
		public function testSrcSettingsJavascript():void		
		{
			parameters = {
				src:"javascript:alert('test')"
			};			
			deserializer.deserialize(parameters);
			assertEquals("javascript src is set", defaultPlayerConfiguration.src, playerConfiguration.src);			
		}
		
		[Test(description="Test src settings empty url")]
		public function testSrcSettingsInvalid2():void		
		{
			parameters = {
				src:""
			};			
			deserializer.deserialize(parameters);
			assertEquals("invalid src is set", defaultPlayerConfiguration.src, playerConfiguration.src);			
		}
		
		[Test(description="Test src settings null url")]
		public function testSrcSettingsInvalid3():void		
		{
			parameters = {
				src:null
			};			
			deserializer.deserialize(parameters);
			assertEquals("invalid src is set", defaultPlayerConfiguration.src, playerConfiguration.src);			
		}	
		
		//------------------------------------- scaleMode
		[Test(description="Test scaleMode settings")]
		public function testScaleModeSettings():void
		{
			parameters = {
				scaleMode:ScaleMode.NONE
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct scaleMode parameter not set", ScaleMode.NONE , playerConfiguration.scaleMode);		
			
			parameters = {
				scaleMode:ScaleMode.LETTERBOX
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct scaleMode parameter not set", ScaleMode.LETTERBOX, playerConfiguration.scaleMode);			
			
			parameters = {
				scaleMode:ScaleMode.STRETCH
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct scaleMode parameter not set", ScaleMode.STRETCH, playerConfiguration.scaleMode);			
			
			parameters = {
				scaleMode:ScaleMode.ZOOM
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct scaleMode parameter not set", ScaleMode.ZOOM, playerConfiguration.scaleMode);			
			
		}
		
		[Test(description="Test scaleMode invalid settings")]
		public function testScaleModeSettingsInvalid1():void
			{			
			parameters = {
				scaleMode:"mistyped"
			};			
			deserializer.deserialize(parameters);
			assertEquals("Invalid scaleMode is set", defaultPlayerConfiguration.scaleMode, playerConfiguration.scaleMode);			
		}
		
		[Test(description="Test scaleMode empty settings")]
		public function testScaleModeSettingsInvalid2():void
		{			
			parameters = {
				scaleMode:""
			};			
			deserializer.deserialize(parameters);
			assertEquals("Empty scaleMode is set", defaultPlayerConfiguration.scaleMode, playerConfiguration.scaleMode);			
		}
		
		[Test(description="Test scaleMode null settings")]
		public function testScaleModeSettingsInvalid3():void
		{			
			parameters = {
				scaleMode:null
			};			
			deserializer.deserialize(parameters);
			assertEquals("Null scaleMode is set", defaultPlayerConfiguration.scaleMode, playerConfiguration.scaleMode);			
		}
		
		//------------------------------------- controlBarMode
		
		[Test(description="Test controlBarMode settings")]
		public function testControlBarPositionSettings():void
		{
			parameters = {
				controlBarMode:ControlBarMode.DOCKED
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct controlBarMode parameter not set", ControlBarMode.DOCKED, playerConfiguration.controlBarMode);		
						
			parameters = {
				controlBarMode:ControlBarMode.FLOATING
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct controlBarMode parameter not set", ControlBarMode.FLOATING, playerConfiguration.controlBarMode);			
			
			parameters = {
				controlBarMode:ControlBarMode.NONE
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct controlBarMode parameter not set", ControlBarMode.NONE, playerConfiguration.controlBarMode);			
			
		}
		
		[Test(description="Test controlBarMode invalid settings")]
		public function testControlBarModeSettingsInvalid1():void
		{			
			parameters = {
				controlBarMode:"mistyped"
			};			
			deserializer.deserialize(parameters);
			assertEquals("Invalid controlBarMode is set", defaultPlayerConfiguration.controlBarMode, playerConfiguration.controlBarMode);			
		}
		
		[Test(description="Test controlBarMode empty settings")]
		public function testControlBarModeSettingsInvalid2():void
		{			
			parameters = {
				controlBarMode:""
			};			
			deserializer.deserialize(parameters);
			assertEquals("Empty controlBarMode is set", defaultPlayerConfiguration.controlBarMode, playerConfiguration.controlBarMode);			
		}

		[Test(description="Test controlBarMode null settings")]
		public function testControlBarModeSettingsInvalid3():void
		{			
			parameters = {
				controlBarMode:null
			};			
			deserializer.deserialize(parameters);
			assertEquals("Null controlBarMode is set", defaultPlayerConfiguration.controlBarMode, playerConfiguration.controlBarMode);			
		}
		
		//------------------------------------- smoothing
		
		[Test(description="Test smoothing settings")]
		public function testSmoothingSettings():void
		{
			parameters = {
				videoRenderingMode:VideoRenderingMode.AUTO
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct smoothing parameter not set", VideoRenderingMode.AUTO, playerConfiguration.videoRenderingMode);		
			
			parameters = {
				videoRenderingMode:VideoRenderingMode.NONE
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct smoothing parameter not set", VideoRenderingMode.NONE, playerConfiguration.videoRenderingMode);			
			
			parameters = {
				videoRenderingMode:VideoRenderingMode.SMOOTHING
			};			
			deserializer.deserialize(parameters);
			assertEquals("correct smoothing parameter not set", VideoRenderingMode.SMOOTHING, playerConfiguration.videoRenderingMode);			
		}
		
		
		[Test(description="Test smoothing invalid settings")]
		public function testSmoothingInvalid1():void
		{			
			parameters = {
				videoRenderingMode:32
			};			
			deserializer.deserialize(parameters);
			assertEquals("Invalid smoothing is set", defaultPlayerConfiguration.videoRenderingMode, playerConfiguration.videoRenderingMode);			
		}	
	
		//------------------------------------- color
		
		//------------------------------------- backgroundColor
		[Test(description="Test backgroundColor settings")]
		public function testColorSetting():void
		{	
			//set the background color
			parameters = {
				backgroundColor:"FF0000" //red
			};			
			deserializer.deserialize(parameters);
			assertEquals(16711680, playerConfiguration.backgroundColor);
			
			//check a short value
			parameters = {
				backgroundColor:"FF" //blue
			};			
			deserializer.deserialize(parameters);
			assertEquals("short value not accepted", 255, playerConfiguration.backgroundColor);
			
			//check a base 10 existing value
			parameters = {
				backgroundColor:"10" //blue
			};			
			deserializer.deserialize(parameters);
			assertEquals("int value incorrectly processed", 16, playerConfiguration.backgroundColor);
		}
		
		[Test(description="Test backgroundColor invalid settings")]
		public function testColorSettingInvalid1():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:"mistyped this"
			};			
			deserializer.deserialize(parameters);
			assertEquals("default backgroundColor not set on non-numbers ",  defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}
		
		[Test(description="Test backgroundColor number too big settings")]
		public function testColorSettingInvalid2():void
		{	
			//number too big.
			parameters = {
				backgroundColor:"1000000"
			};			
			deserializer.deserialize(parameters);
			assertEquals("a number that is not a color code is accepted", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}	
		
		[Test(description="Test backgroundColor # settings")]
		public function testColorSettingHtmlColor():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:"#FF0000"
			};			
			deserializer.deserialize(parameters);
			assertEquals(0xff0000, playerConfiguration.backgroundColor);
		}	
		
		[Test(description="Test backgroundColor 0x settings")]
		public function testColorSettingHtmlColor2():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:"0xFF0000"
			};			
			deserializer.deserialize(parameters);
			assertEquals("a number that starts with 0x is not accepted", 0xff0000, playerConfiguration.backgroundColor);
		}	
	
		[Test(description="Test backgroundColor #0x settings")]
		public function testColorSettingHtmlColor3():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:"#0xFF0000"
			};			
			deserializer.deserialize(parameters);
			assertEquals("a number that starts with #0x is accepted", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}	
		
		[Test(description="Test backgroundColor #0x empty settings")]
		public function testColorSettingHtmlColor4():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:"#"
			};			
			deserializer.deserialize(parameters);
			assertEquals("a number that starts containing only # is accepted", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}
		
		[Test(description="Test backgroundColor empty settings")]
		public function testColorSettingInvalid4():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:""
			};			
			deserializer.deserialize(parameters);
			assertEquals("empty string for backgroundColor", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}	
		
		[Test(description="Test backgroundColor null settings")]
		public function testColorSettingInvalid5():void
		{	
			//set an invalid value and check that the default is being used.
			parameters = {
				backgroundColor:null
			};			
			deserializer.deserialize(parameters);
			assertEquals("null string for backgroundColor", defaultPlayerConfiguration.backgroundColor, playerConfiguration.backgroundColor);
		}
		
		//------------------------------------- boolean
		[Test(description="Test boolean true settings")]
		public function testBooleanSettingsTrue():void
		{
			parameters = {
				autoPlay:"true", 
				controlBarAutoHide:"True",
				loop:"tRue", 
				autoRewind:"TRUE"   
			};			
			deserializer.deserialize(parameters);
			assertTrue("true value not set for autoPlay", playerConfiguration.autoPlay);
			assertTrue("true value not set for controlBarAutoHide", playerConfiguration.controlBarAutoHide);
			assertTrue("true value not set for loop", playerConfiguration.loop);			
			assertTrue(playerConfiguration.autoRewind);
		}
		
		[Test(description="Test boolean false settings")]
		public function testBooleanSettingsFalse():void
		{
			parameters = {
				autoPlay:"false", 
				controlBarAutoHide:"False",
				loop:"fAlse", 
				autoSwitchQuality:"FALSE"   
			};			
			deserializer.deserialize(parameters);
			assertFalse("false value not set for autoPlay", playerConfiguration.autoPlay);
			assertFalse("false value not set for controlBarAutoHide", playerConfiguration.controlBarAutoHide);
			assertFalse("false value not set for loop", playerConfiguration.loop);			
			assertFalse("false value not set for autoSwitchQuality", playerConfiguration.autoSwitchQuality);
		}
		
		[Test(description="Test boolean invalid settings")]
		public function testBooleanSettingsInvalid():void
		{
			parameters = {
				autoPlay:"what3ver", //the default should be used
				controlBarAutoHide:"what3ver", //the default should be used
				loop:"what3ver", //the default should be used
				autoSwitchQuality:"what3ver"   //the default should be used
			};			
			deserializer.deserialize(parameters);
			assertEquals("default value not set for autoPlay", defaultPlayerConfiguration.autoPlay, playerConfiguration.autoPlay);
			assertEquals("default value not set for controlBarAutoHide", defaultPlayerConfiguration.controlBarAutoHide, playerConfiguration.controlBarAutoHide);
			assertEquals("default value not set for loop", defaultPlayerConfiguration.loop, playerConfiguration.loop);			
			assertEquals("default value not set for autoSwitchQuality", defaultPlayerConfiguration.autoSwitchQuality, playerConfiguration.autoSwitchQuality);
		}
		
		[Test(description="Test boolean empty settings")]
		public function testBooleanSettingsEmpty():void
		{
			parameters = {
				autoPlay:"", 
				controlBarAutoHide:"",
				loop:"", 
				autoSwitchQuality:""   
			};			
			deserializer.deserialize(parameters);
			assertEquals("default value not set for autoPlay", defaultPlayerConfiguration.autoPlay, playerConfiguration.autoPlay);
			assertEquals("default value not set for controlBarAutoHide", defaultPlayerConfiguration.controlBarAutoHide, playerConfiguration.controlBarAutoHide);
			assertEquals("default value not set for loop", defaultPlayerConfiguration.loop, playerConfiguration.loop);			
			assertEquals("default value not set for autoSwitchQuality", defaultPlayerConfiguration.autoSwitchQuality, playerConfiguration.autoSwitchQuality);
		}		
		
		[Test(description="Test boolean null settings")]
		public function testBooleanSettingsNull():void
		{
			parameters = {
				autoPlay:null, 
				controlBarAutoHide:null,
				loop:null, //the default should be used
				autoSwitchQuality:null   //the default should be used
			};			
			deserializer.deserialize(parameters);
			assertEquals("default value not set for autoPlay", defaultPlayerConfiguration.autoPlay, playerConfiguration.autoPlay);
			assertEquals("default value not set for controlBarAutoHide", defaultPlayerConfiguration.controlBarAutoHide, playerConfiguration.controlBarAutoHide);
			assertEquals("default value not set for loop", defaultPlayerConfiguration.loop, playerConfiguration.loop);			
			assertEquals("default value not set for autoSwitchQuality", defaultPlayerConfiguration.autoSwitchQuality, playerConfiguration.autoSwitchQuality);
		}
		
		//------------------------------------- numeric
		
		[Test(description="Test numeric settings")]
		public function testNumericSettings():void
		{
			parameters = {
				initialBufferTime:"2.12345678901", 
				expandedBufferTime:"10"			
			};			
			deserializer.deserialize(parameters);
			assertEquals("initialBufferTime not set correctly", 2.12345678901, playerConfiguration.initialBufferTime);			
			assertEquals("expandedBufferTime not set correctly", 10, playerConfiguration.expandedBufferTime);
		}
		
		[Test(description="Test numeric invalid settings")]
		public function testNumericSettingsInvalid():void
		{	
			parameters = {
				initialBufferTime:"other", 
				expandedBufferTime:"other"			
			};			
			deserializer.deserialize(parameters);
			assertEquals("initialBufferTime not set to default", defaultPlayerConfiguration.initialBufferTime, playerConfiguration.initialBufferTime);			
			assertEquals("expandedBufferTime not set to default", defaultPlayerConfiguration.expandedBufferTime, playerConfiguration.expandedBufferTime);
		}
		
		[Test(description="Test numeric zero settings")]
		public function testNumericSettingsZero():void
		{	
			parameters = {
				initialBufferTime:"0", 
				expandedBufferTime:"0"			
			};			
			deserializer.deserialize(parameters);
			assertEquals("initialBufferTime not set to default", 0, playerConfiguration.initialBufferTime);			
			assertEquals("expandedBufferTime not set to default", 0, playerConfiguration.expandedBufferTime);
		}
		
		[Test(description="Test numeric empty settings")]
		public function testNumericSettingsEmpty():void
		{	
			parameters = {
				initialBufferTime:"", 
				expandedBufferTime:""			
			};			
			deserializer.deserialize(parameters);
			assertEquals("initialBufferTime not set to default", defaultPlayerConfiguration.initialBufferTime, playerConfiguration.initialBufferTime);			
			assertEquals("expandedBufferTime not set to default", defaultPlayerConfiguration.expandedBufferTime, playerConfiguration.expandedBufferTime);
		}
		
		[Test(description="Test numeric null settings")]
		public function testNumericSettingsNull():void
		{	
			parameters = {
				initialBufferTime:null, 
				expandedBufferTime:null			
			};			
			deserializer.deserialize(parameters);
			assertEquals("initialBufferTime not set to default", defaultPlayerConfiguration.initialBufferTime, playerConfiguration.initialBufferTime);			
			assertEquals("expandedBufferTime not set to default", defaultPlayerConfiguration.expandedBufferTime, playerConfiguration.expandedBufferTime);
		}
		
//		[Test(description="Test numeric negative settings")]
//		public function testNumericSettingsNegative():void
//		{	
//			parameters = {
//				initialBufferTime:"-1.3", 
//				expandedBufferTime:"-10"			
//			};			
//			deserializer.deserialize(parameters);
//			assertEquals("initialBufferTime not set to default", defaultPlayerConfiguration.initialBufferTime, playerConfiguration.initialBufferTime);			
//			assertEquals("expandedBufferTime not set to default", defaultPlayerConfiguration.expandedBufferTime, playerConfiguration.expandedBufferTime);
//		}
//		
		[Test(description="Test uint settings")]
		public function testUIntSettings():void
		{	
			parameters = {
				highQualityThreshold:"280"		
			};			
			deserializer.deserialize(parameters);
			assertEquals("highQualityThreshold not set to 280", 280, playerConfiguration.highQualityThreshold);
		}
//		
//		[Test(description="Test uint negative settings")]
//		public function testUIntSettingsNegative():void
//		{	
//			parameters = {
//				highQualityThreshold:"-2"		
//			};			
//			deserializer.deserialize(parameters);
//			assertEquals("highQualityThreshold not set to default", defaultPlayerConfiguration.highQualityThreshold, playerConfiguration.highQualityThreshold);
//		}
		
		[Test(description="Test uint invalid settings")]
		public function testUIntSettingsInvalid():void
		{	
			parameters = {
				highQualityThreshold:"Other"		
			};			
			deserializer.deserialize(parameters);
			assertEquals("highQualityThreshold not set to default", defaultPlayerConfiguration.highQualityThreshold, playerConfiguration.highQualityThreshold);
		}
		
//		[Test(description="Test uint zero settings")]
//		public function testUIntSettingsZero():void
//		{	
//			parameters = {
//				highQualityThreshold:"0"		
//			};			
//			deserializer.deserialize(parameters);
//			assertEquals("highQualityThreshold not set to default", 0, playerConfiguration.highQualityThreshold);
//		}
//		
		[Test(description="Asset metadata")]
		public function testSrcTitle():void
		{	
			parameters = {
				src_title : "title"		
			};			
			deserializer.deserialize(parameters);
			assertEquals(parameters.src_title, playerConfiguration.metadata.title);
		}
		
		
		[Test(description="Asset metadata")]
		public function testSrcOtherNamespace():void
		{   
			parameters = {
				src_title : "title"  ,
				src_namespace : "namespace_a",
				src_namespace_n : "namespace_d",
				src_n_author : "author"
			};           
			deserializer.deserialize(parameters);
			
			assertEquals("invalid title is set", parameters.src_title, playerConfiguration.metadata.namespace_a["title"]);
			assertEquals("invalid author is set", parameters.src_n_author, playerConfiguration.metadata.namespace_d["author"]);
			
		}
		
		[Test(description="Asset metadata")]
		public function testSrcOnlyOtherNamespace():void
		{   
			parameters = {
				src_title : "title"  ,   
				src_namespace_n : "namespace_d",
				src_n_author : "author"
			};           
			deserializer.deserialize(parameters);
			assertEquals("invalid title is set", parameters.src_title, playerConfiguration.metadata.title);
			assertEquals("invalid author is set", parameters.src_n_author, playerConfiguration.metadata.namespace_d["author"]);
			
		}
		
		[Test]
		public function testPluginNamedSrc():void
		{
			parameters = {
				plugin_src:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				src_namespace: "PLUGIN_NAMESPACE",
				src_videoName: "Video Name"				
			};			
			
			deserializer.deserialize(parameters);
			assertEquals(parameters.src_videoName, playerConfiguration.metadata["PLUGIN_NAMESPACE"]["videoName"]);
		}
		
		[Test]
		public function testLocalRTMP():void
		{
			parameters = {
				src:"rtmp:/vod/sample"	
			};			
			
			deserializer.deserialize(parameters);				
			
			assertEquals(parameters.src, playerConfiguration.src);
		}
		
		
		[Test]
		public function testLocalRTMPTE():void
		{
			parameters = {
				src:"rtmpte:/vod/sample"	
			};			
			
			deserializer.deserialize(parameters);				
			
			assertEquals(parameters.src, playerConfiguration.src);
		}
		
		private static var defaultPlayerConfiguration:ConfigurationProxy;
		private var parameters:Object;
		private var playerConfiguration:ConfigurationProxy;
		private var deserializer:ConfigurationFlashvarsDeserializer;
		
		private var injector:InjectorModule;
	}
}
