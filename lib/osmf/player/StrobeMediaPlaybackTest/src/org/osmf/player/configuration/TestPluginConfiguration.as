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
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.chrome.configuration.ConfigurationUtils;

	public class TestPluginConfiguration
	{	
		[Before]
		public function setup():void
		{
			plugins = {};
			var injector:InjectorModule = new InjectorModule();
			configurationFlashvarsDeserializer = injector.getInstance(ConfigurationFlashvarsDeserializer);
		}
		
		[Test]
		public function testMultipleNamespaces():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				echo_namespace: PLUGIN_NAMESPACE,
				echo_videoName: "Video Name",
				echo_description: "Video Description",
				echo_namespace_ns2: PLUGIN_NAMESPACE2,
				echo_ns2_videoName: "Video Name2",
				echo_ns2_description: "Video Description2"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertEquals("invalid videoName is set", parameters.echo_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName"));
			assertEquals("invalid description is set", parameters.echo_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("description"));
			
			assertEquals("invalid videoName is set", parameters.echo_ns2_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE2).getValue("videoName"));
			assertEquals("invalid description is set", parameters.echo_ns2_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE2).getValue("description"));
		}
		
		[Test]
		public function testMultiplePluginsMultipleNamespaces():void
		{
			var parameters:Object = {
				plugin_echo:"http://localhost/acucu-osmf/depot/main/strobe/Strobe.SWF/trunk/ConfigurationEchoPlugin/bin/ConfigurationEchoPlugin.swf",
				echo_namespace: PLUGIN_NAMESPACE,
				echo_namespace_ns2: PLUGIN_NAMESPACE2,
				echo_videoName: "Video Name",
				echo_description: "Video Description",
				
				echo_ns2_videoName: "Video Name 2",
				echo_ns2_description: "Video Description 2",
				
				plugin_echo2:"http://localhost/acucu-osmf/depot/main/strobe/Strobe.SWF/trunk/ConfigurationEchoPlugin/bin/ConfigurationEchoPlugin.swf",
				echo2_namespace: PLUGIN_NAMESPACE,
				echo2_namespace_ns2: PLUGIN_NAMESPACE2,
				echo2_videoName: "Video Name",
				echo2_description: "Video Description",
				
				echo2_ns2_videoName: "Video Name 2",
				echo2_ns2_description: "Video Description 2"
			};	
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(2, pluginConfigurations.length);
			for each (var pluginMetadata:URLResource in pluginConfigurations)
			{
				assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
				assertEquals("invalid videoName is set", parameters.echo_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName"));
				assertEquals("invalid description is set", parameters.echo_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("description"));
				
				assertEquals("invalid videoName is set", parameters.echo_ns2_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE2).getValue("videoName"));
				assertEquals("invalid description is set", parameters.echo_ns2_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE2).getValue("description"));
			}
		}
		
		[Test]
		public function testTwoAliasForTheSameNamespace():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				echo_namespace: PLUGIN_NAMESPACE,
				echo_videoName: "Video Name",
				echo_description: "Video Description",
				echo_namespace_ns2: PLUGIN_NAMESPACE,
				echo_ns2_videoName2: "Video Name2",
				echo_ns2_description2: "Video Description2"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertEquals("invalid videoName is set", parameters.echo_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName"));
			assertEquals("invalid description is set", parameters.echo_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("description"));
			
			assertEquals("invalid videoName2 is set", parameters.echo_ns2_videoName2, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName2"));
			assertEquals("invalid description2 is set", parameters.echo_ns2_description2, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("description2"));
		}
	
		
		[Test]
		public function testAliasNamedNamespace():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				echo_namespace_namespace: PLUGIN_NAMESPACE,
				echo_namespace_videoName: "Video Name"				
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertNull("invalid videoName is set", pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE));
		}
		
		[Test]
		public function testAliasNamedPlugin():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				echo_namespace_plugin: PLUGIN_NAMESPACE,
				echo_plugin_videoName: "Video Name"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertEquals("invalid videoName is set", parameters.echo_plugin_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName"));
		}
		
		[Test]
		public function testAliasWithSeparator():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				echo_namespace_n_s: PLUGIN_NAMESPACE,
				echo_n_s_videoName: "Video Name"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertNull("invalid videoName is set", pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE));
		}
		
		[Test]
		public function testAliasSpecial():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				"echo_namespace_n$s": PLUGIN_NAMESPACE
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertNull("invalid videoName is set", pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE));
		}
	
		[Test]
		public function testAliasEmpty():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",			
				echo_namespace_: PLUGIN_NAMESPACE,
				echo__videoName: "Video Name"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertNull("invalid videoName is set", pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE));
		}
		
		[Test]
		public function testConfigurationDeserialization():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				echo_namespace: PLUGIN_NAMESPACE,
				echo_videoName: "Video Name",
				echo_description: "Video Description"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertEquals("invalid videoName is set", parameters.echo_videoName, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("videoName"));
			assertEquals("invalid description is set", parameters.echo_description, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("description"));
		}
		
		[Test]
		public function testSeparatorInParamName():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				echo_namespace: PLUGIN_NAMESPACE,
				echo_video_name: "Video Name"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertEquals("invalid video_name is set", parameters.echo_video_name, pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE).getValue("video_name"));
		}
		
		[Test]
		public function testNoNamespace():void
		{
			parameters = {
				plugin_echo:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				echo_video_name: "Video Name"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			var pluginMetadata:URLResource = pluginConfigurations[0] as URLResource;
			assertEquals("invalid src is set", parameters.plugin_echo, pluginMetadata.url);
			assertNull("namespace is set", pluginMetadata.getMetadataValue(PLUGIN_NAMESPACE));
		}		
		
		[Test]
		public function testPluginNamedPlugin():void
		{
			parameters = {
				plugin_plugin:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf",
				plugin_videoName: "Video Name",
				plugin_description: "Video Description"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(0, pluginConfigurations.length);
		}
		
		[Test]
		public function testPluginNoNamePlugin():void
		{
			parameters = {
				plugin_:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(0, pluginConfigurations.length);
		}
		
		[Test]
		public function testPluginNoAlphaFirstPlugin():void
		{
			parameters = {
				plugin_1:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(0, pluginConfigurations.length);
		}

		[Test]
		public function testPluginAlphaFirstPlugin():void
		{
			parameters = {
				plugin_a:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
		}
		
		[Test]
		public function testPluginAlphaFirstSpecialNextPlugin():void
		{
			parameters = {
				plugin_A0:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
		}
		
		[Test]
		public function testMultiplePlugins():void
		{
			parameters = {
				plugin_plugin1:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf?ver=1",
				plugin_plugin2:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf?ver=2"
			};			
			//just to suggest the plugin is different
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(2, pluginConfigurations.length);
		}
		
		[Test]
		public function testSeparatorInPluginName():void
		{
			parameters = {
				plugin_video_chat:"http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, pluginConfigurations);
			assertEquals("incorrectly named plugin was added", 0, pluginConfigurations.length);		
		}

		[Test]
		public function testRelativePluginPath():void
		{
			parameters = {
				plugin_echo:"ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals("relative paths should be accepted", 1, pluginConfigurations.length);
		}
		
		[Test]
		public function testinvalidPluginPath():void
		{
			parameters = {
				plugin_echo:"__!#http://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(0, pluginConfigurations.length);
		}
		
		[Test]
		public function testPluginhttps():void
		{
			parameters = {
				plugin_p1:"https://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(1, pluginConfigurations.length);
		}
		
		[Test]
		public function testPluginjavascript():void
		{
			parameters = {
				plugin_a1:"javascript://lolek.corp.adobe.com/strobe/player/current/ConfigurationEchoPlugin.swf"
			};			
			configurationFlashvarsDeserializer.deserializePluginConfigurations(parameters, plugins);
			assertEquals(0, pluginConfigurations.length);
		}
		
		private function get pluginConfigurations():Vector.<MediaResourceBase>
		{
			return ConfigurationUtils.transformDynamicObjectToMediaResourceBases(plugins);
		}
		
		private var configurationFlashvarsDeserializer:ConfigurationFlashvarsDeserializer;
		private var parameters:Object;
		private var plugins:Object;
				
		private static const PLUGIN_NAMESPACE:String = "http://www.osmf.org/plugin/metadata/1.0";
		private static const PLUGIN_NAMESPACE2:String = "http://www.osmf.org/plugin/metadata/2.0";
	}
}