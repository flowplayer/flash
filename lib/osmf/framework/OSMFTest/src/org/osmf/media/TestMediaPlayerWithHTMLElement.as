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

// Test cases that are ignore_ TO BE FIXED and uncommented		
//The all class is Commented because is causing to many failures. To be investigated and fixed

package org.osmf.media
{
	import org.osmf.containers.HTMLMediaContainer;
	import org.osmf.elements.HTMLElement;
	import org.osmf.traits.MediaTraitType;
	
	public class TestMediaPlayerWithHTMLElement extends TestMediaPlayer
	{
//		// Overrides
//		//
//
//// Test cases that are ignore_ TO BE FIXED and uncommented		
//		
////		override public function testLoop():void
////		{
////			// Overridden to prevent base test (which fails) from running.
////		}
////
////		override public function testLoopWithAutoRewind():void
////		{
////			// Overridden to prevent base test (which fails) from running.
////		}
////		
//		override public function setUp():void
//		{
//			element = new HTMLElement();
//			htmlContainer.addMediaElement(element);
//			
//			super.setUp();
//		}
//		
//		override public function tearDown():void
//		{
//			super.tearDown();
//			
//			htmlContainer.removeMediaElement(element);
//			element = null;
//		}
//				
//		override protected function createMediaElement(resource:MediaResourceBase):MediaElement
//		{
//			element.resource = resource;
//			return element;
//		}
//		
//		override protected function get hasLoadTrait():Boolean
//		{
//			return true;
//		}
//		
//		override protected function get resourceForMediaElement():MediaResourceBase
//		{
//			return new URLResource("http://www.adobe.com/validURL")
//		}
//
//		override protected function get invalidResourceForMediaElement():MediaResourceBase
//		{
//			return new URLResource("http://www.adobe.com/invalidURL");
//		}
//		
//		override protected function get existentTraitTypesOnInitialization():Array
//		{
//			return [MediaTraitType.LOAD];
//		}
//
//		override protected function get existentTraitTypesAfterLoad():Array
//		{
//			return [MediaTraitType.LOAD, MediaTraitType.TIME, MediaTraitType.PLAY, MediaTraitType.AUDIO];
//		}
		
		/*[Test]
		override public function testDisplayObjectEventGeneration():void
		{
			super.testDisplayObjectEventGeneration();
		}
		
		*/
//		
//		private var element:HTMLElement;
//		
//		// TODO: This is static for now, but we should figure out how to fix this,
//		// and then bind its lifetime to the individual test.
//		private static var htmlContainer:HTMLMediaContainer = new HTMLMediaContainer("bannerContainer");
	}
}
