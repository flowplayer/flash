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
package org.osmf.traits
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.DynamicLoader;
	import org.osmf.utils.SimpleResource;
	
	public class TestLoaderBaseAsSubclass extends TestLoaderBase
	{
		// Test cases that are ignore_ TO BE FIXED and uncommented		
		
		
//		override protected function createInterfaceObject(... args):Object
//		{
//			return new DynamicLoader();
//		}
//
//		override protected function get successfulResource():MediaResourceBase
//		{
//			return new SimpleResource(SimpleResource.SUCCESSFUL);
//		}
//
//		override protected function get failedResource():MediaResourceBase
//		{
//			return new SimpleResource(SimpleResource.FAILED);
//		}
//
//		override protected function get unhandledResource():MediaResourceBase
//		{
//			return new SimpleResource(SimpleResource.UNHANDLED);
//		}
//		
//		public function testLoadWithInvalidLoadTrait():void
//		{
//			var dynLoader:DynamicLoader = loader as DynamicLoader;
//			var loadTrait:LoadTrait = createLoadTrait(loader, successfulResource);
//			
//			// Can't load null.
//			try
//			{
//				dynLoader.load(null);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//			
//			dynLoader.doUpdateLoadTrait(loadTrait, LoadState.LOADING);
//			assertTrue(loadTrait.loadState == LoadState.LOADING);
//			
//			// Can't load while LOADING.
//			try
//			{
//				dynLoader.load(loadTrait);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//
//			dynLoader.doUpdateLoadTrait(loadTrait, LoadState.READY);
//			assertTrue(loadTrait.loadState == LoadState.READY);
//
//			// Can't load while READY.
//			try
//			{
//				dynLoader.load(loadTrait);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//			
//			// Can't load an invalid resource.
//			try
//			{
//				dynLoader.load(createLoadTrait(loader, unhandledResource));
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//		}
//		
//		public function testUnloadWithInvalidLoadTrait():void
//		{
//			var dynLoader:DynamicLoader = loader as DynamicLoader;
//			var loadTrait:LoadTrait = createLoadTrait(loader, successfulResource);
//			
//			// Can't unload null.
//			try
//			{
//				dynLoader.unload(null);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//			
//			assertTrue(loadTrait.loadState == LoadState.UNINITIALIZED);
//			
//			// Can't unload while UNINITIALIZED.
//			try
//			{
//				dynLoader.unload(loadTrait);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//
//			dynLoader.doUpdateLoadTrait(loadTrait, LoadState.UNLOADING);
//			assertTrue(loadTrait.loadState == LoadState.UNLOADING);
//
//			// Can't unload while UNLOADING.
//			try
//			{
//				dynLoader.unload(loadTrait);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//			
//			loadTrait = createLoadTrait(loader, unhandledResource);
//			dynLoader.doUpdateLoadTrait(loadTrait, LoadState.READY);
//			assertTrue(loadTrait.loadState == LoadState.READY);
//
//			// Can't unload an invalid resource.
//			try
//			{
//				dynLoader.unload(loadTrait);
//				
//				fail();
//			}
//			catch (e:IllegalOperationError)
//			{
//			}
//		}
	}
}