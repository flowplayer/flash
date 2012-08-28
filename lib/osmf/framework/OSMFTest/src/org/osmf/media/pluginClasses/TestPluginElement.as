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
package org.osmf.media.pluginClasses
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.TestMediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.Version;
	
	import org.flexunit.Assert;
	
	public class TestPluginElement extends TestMediaElement
	{
		override protected function createMediaElement():MediaElement
		{
			return new PluginElement(new StaticPluginLoader(new MediaFactory(), Version.version)); 
		}
		
		override protected function get hasLoadTrait():Boolean
		{
			return true;
		}
		
		override protected function get resourceForMediaElement():MediaResourceBase
		{
			return new PluginInfoResource(new SimpleVideoPluginInfo);
		}
		
		override protected function get existentTraitTypesOnInitialization():Array
		{
			return [MediaTraitType.LOAD];
		}

		override protected function get existentTraitTypesAfterLoad():Array
		{
			return [MediaTraitType.LOAD];
		}	

		[Test]
		public function testPluginElementConstruction():void
		{
			var pluginElement:MediaElement = new PluginElement(new StaticPluginLoader(new MediaFactory(), Version.version), new PluginInfoResource(null));
			Assert.assertTrue(pluginElement.resource != null);	
			Assert.assertTrue(pluginElement.resource is PluginInfoResource);
		}
	}
}