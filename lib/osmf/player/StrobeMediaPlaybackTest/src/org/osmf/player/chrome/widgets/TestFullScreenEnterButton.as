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

package org.osmf.player.chrome.widgets
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	
	import org.flexunit.asserts.*;
	import org.osmf.MockMediaElement;
	import org.osmf.player.chrome.events.WidgetEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	public class TestFullScreenEnterButton extends Sprite
	{
		[Test]
		public function testVisibility():void
		{	
			var fullScreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();			
			var media:MockMediaElement = new MockMediaElement();
			fullScreenEnterButton.media = media;
			assertFalse(fullScreenEnterButton.visible);
			media.addSomeTrait(new DisplayObjectTrait(this));
			assertTrue(fullScreenEnterButton.visible);
			media.removeSomeTrait(MediaTraitType.DISPLAY_OBJECT);
			assertFalse(fullScreenEnterButton.visible);
			media.addSomeTrait(new DisplayObjectTrait(new Sprite()));
			assertTrue(fullScreenEnterButton.visible);			
			fullScreenEnterButton.media = null;
			assertFalse(fullScreenEnterButton.visible);
		}
		
		[Test]
		public function testMouseClick():void
		{	
			var fullScreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();			
			var media:MockMediaElement = new MockMediaElement();
			fullScreenEnterButton.media = media;
			media.addSomeTrait(new DisplayObjectTrait(this));
			var fullScreen:Boolean = false;
			fullScreenEnterButton.addEventListener(WidgetEvent.REQUEST_FULL_SCREEN, 
				function(event:Event):void 
				{
					fullScreen = true;
				}
			);
			fullScreenEnterButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false));
				
			assertTrue(fullScreen);			
		}
		
		[Test]
		public function testAddingToStage():void
		{	
			var fullScreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();			
			var media:MockMediaElement = new MockMediaElement();
			fullScreenEnterButton.media = media;
			media.addSomeTrait(new DisplayObjectTrait(new Sprite()));
			FlexGlobals.topLevelApplication.stage.addChild(fullScreenEnterButton);
			
			assertNotNull(fullScreenEnterButton.stage);
		}
		
		
		[Test]
		public function testGoToFullScreen():void
		{	
			var fullScreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();			
			var media:MockMediaElement = new MockMediaElement();
			fullScreenEnterButton.media = media;
			media.addSomeTrait(new DisplayObjectTrait(new Sprite()));
			FlexGlobals.topLevelApplication.stage.addChild(fullScreenEnterButton);
			
			FlexGlobals.topLevelApplication.stage.dispatchEvent(new FullScreenEvent(FullScreenEvent.FULL_SCREEN, true, false));
			
			// We cannot force it into fullscreen, so the button remains visible.
			assertTrue(fullScreenEnterButton.visible);
		}
		
		
		[Test]
		public function testGoToFullScreenWithNullMediaElement():void
		{	
			var fullScreenEnterButton:FullScreenEnterButton = new FullScreenEnterButton();			
			var media:MockMediaElement = new MockMediaElement();
			fullScreenEnterButton.media = media;
			media.addSomeTrait(new DisplayObjectTrait(new Sprite()));
			FlexGlobals.topLevelApplication.stage.addChild(fullScreenEnterButton);
			fullScreenEnterButton.media = null;
			FlexGlobals.topLevelApplication.stage.dispatchEvent(new FullScreenEvent(FullScreenEvent.FULL_SCREEN, true, false));			
			assertFalse(fullScreenEnterButton.visible);
		}
	}
}