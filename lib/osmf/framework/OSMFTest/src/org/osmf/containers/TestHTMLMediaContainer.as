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
package org.osmf.containers
{
	import flash.external.ExternalInterface;
	
	import org.flexunit.Assert;
	import org.osmf.elements.HTMLElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	
	public class TestHTMLMediaContainer
	{		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testAddMediaElementNull():void
		{
			var container:HTMLMediaContainer = new HTMLMediaContainer("test");
			container.addMediaElement(null);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testAddMediaElementEmptyMediaElement():void
		{
			var container:HTMLMediaContainer = new HTMLMediaContainer("test");
			container.addMediaElement(new MediaElement());
		}
		
		[Test]
		public function testHTMLMediaContainer():void
		{
			if (ExternalInterface.available)
			{
				var container:HTMLMediaContainer = new HTMLMediaContainer("test");
									
				var element:HTMLElement = new HTMLElement();
				container.addMediaElement(element);
				
				Assert.assertTrue(container.containsMediaElement(element));
				Assert.assertFalse(container.containsMediaElement(null));
				Assert.assertFalse(container.containsMediaElement(new MediaElement()));
				
				try
				{
					container.removeMediaElement(null);
					
					Assert.fail();
				}
				catch(e:Error)
				{
				}
				
				try
				{
					container.removeMediaElement(new MediaElement());
					
					Assert.fail();
				}
				catch(e:Error)
				{
				}
				
				container.removeMediaElement(element);
				Assert.assertFalse(container.containsMediaElement(element));
				
				container.addMediaElement(element);
				Assert.assertTrue(container.containsMediaElement(element));
				
				var element2:HTMLElement = new HTMLElement();
				container.addMediaElement(new ProxyElement(new ProxyElement(element2)));
					
				Assert.assertTrue(container.containsMediaElement(element2));
				
				// Test if the container constructs its own id if we omit it:
				var container2:HTMLMediaContainer = new HTMLMediaContainer();
			}
		}
	}
}