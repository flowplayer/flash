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

package org.osmf.player.plugins
{
	
	import flash.events.Event;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.player.configuration.ConfigurationFlashvarsDeserializer;
	import org.osmf.player.configuration.InjectorModule;
	
	public class TestPluginWhitelist
	{	
		[Test] 
		public function testWhitelistHaltOnError():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost"; 
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = true;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			pluginLoader.loadPlugins();
			
			assertFalse(loaded);
			assertTrue(error);			
		}
		
		[Test] 
		public function testWhitelistProceedOnError():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost"; 
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);	
			
			assertEquals(1, pluginLoader.loadedCount);
		}
		
		[Test] 
		public function testFailProceed():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource(MockMediaFactory.REMOTE_INVALID_PLUGIN_SWF_URL);
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost";  
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);	
			
			assertEquals(0, pluginLoader.loadedCount);
			assertEquals(1, pluginLoader.failCount);
			assertEquals(PluginLoader.PLUGIN_LOAD_MAX_RETRY_COUNT, pluginLoader.retryCount);
		}
		
		[Test] 
		public function testRetryScenario():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false, 1);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost"; 
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);	
			
			assertEquals(1, pluginLoader.loadedCount);
			assertEquals(0, pluginLoader.failCount);
			assertEquals(1, pluginLoader.retryCount);
		}
		
		[Test] 
		public function testWhitelistMultipleHosts():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost3.corp.adobe.com";
			pluginLoadWhitelist[1]= "localhost"; 
			pluginLoadWhitelist[2]= "localhost4/path"; 
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = true;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(1, pluginLoader.loadedCount);
		}
		
		[Test] 
		public function testWhitelistMultipleHostsNothingMatches():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost3/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			pluginConfigurations[2] = new URLResource("http://localhost4/otherpath/myplugin.swf");
			pluginConfigurations[3] = new URLResource("http://localhost4/path3/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost3.corp.adobe.com";
			pluginLoadWhitelist[1]= "localhost"; 
			pluginLoadWhitelist[2]= "localhost4/path"; 
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertEquals(0, pluginLoader.loadedCount);		
			assertTrue(loaded);
			assertFalse(error);

		}
		
		[Test] 
		public function testWhitelistNoList():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost3/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();		
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(2, pluginLoader.loadedCount);		
			assertEquals(0, pluginLoader.failCount);
		}
		
		[Test] 
		public function testWhitelistNullList():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost3/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = null;
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(2, pluginLoader.loadedCount);		
			assertEquals(0, pluginLoader.failCount);
		}
		
		[Test] 
		public function testWhitelistEmptyStringInList():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost3/myplugin.swf");
			pluginConfigurations[1] = new URLResource("http://localhost2/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "";
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(0, pluginLoader.loadedCount);		
		}
		
		[Test] 
		public function testWhitelistNoWhitelistNoPlugins():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			var pluginLoadWhitelist:Vector.<String> = null;
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(0, pluginLoader.loadedCount);		
		}
		
		[Test] 
		public function testWhitelistNoPlugins():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost";
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(0, pluginLoader.loadedCount);		
		}
		
		
		[Test] 
		public function testRetryScenarioBlacklist():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false, 1);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/myplugin.swf");
		
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost1";
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = true;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertFalse(loaded);
			assertTrue(error);	
			
			assertEquals(0, pluginLoader.loadedCount);
			assertEquals(0, pluginLoader.failCount);
			assertEquals(0, pluginLoader.retryCount);
		}
		
		[Test] 
		public function testWhitelistHaltOnErrorRetry():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false, 1);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource("http://localhost/Invalid.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost";
			
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = true;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertFalse(loaded);
			assertTrue(error);	
			
			assertEquals(0, pluginLoader.loadedCount);
		}
		
		[Test] 
		public function testWhitelistFirstPluginInvalid():void
		{	
			var factory:MediaFactory;
			factory = new MockMediaFactory(false);
			
			var pluginConfigurations:Vector.<MediaResourceBase> = new Vector.<MediaResourceBase>();
			pluginConfigurations[0] = new URLResource(MockMediaFactory.REMOTE_INVALID_PLUGIN_SWF_URL);
			pluginConfigurations[1] = new URLResource("http://localhost/myplugin.swf");
			var pluginLoadWhitelist:Vector.<String> = new Vector.<String>();
			pluginLoadWhitelist[0]= "localhost"; 
			var pluginLoader:PluginLoader = new PluginLoader(pluginConfigurations, factory, pluginLoadWhitelist);
			pluginLoader.haltOnError = false;
			var loaded:Boolean = false;	
			var error:Boolean = false;
			
			pluginLoader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					loaded = true;
				}
			);	
			pluginLoader.addEventListener(MediaErrorEvent.MEDIA_ERROR, 
				function(event:MediaErrorEvent):void
				{
					error = true;
				}
			);	
			
			pluginLoader.loadPlugins();
			
			assertTrue(loaded);
			assertFalse(error);			
			assertEquals(1, pluginLoader.loadedCount);		
			assertEquals(1, pluginLoader.failCount);
		}	
	}
}