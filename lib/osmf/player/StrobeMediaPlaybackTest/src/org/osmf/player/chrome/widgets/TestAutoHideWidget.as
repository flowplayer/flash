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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osmf.player.chrome.metadata.ChromeMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;

	public class TestAutoHideWidget
	{
		[Test]
		public function testAutoHideWidgetWithoutTimeout():void
		{
			var autoHideWidget:AutoHideWidget = new AutoHideWidget();
			var media:MediaElement = new MediaElement();
			autoHideWidget.media = media;
			autoHideWidget.autoHide = true;	
			autoHideWidget.autoHideTimeout = 0;	
			FlexGlobals.topLevelApplication.stage.addChild(autoHideWidget);
			
				
			autoHideWidget.visible = false;
			
			autoHideWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, false));
			assertTrue(autoHideWidget.visible);
			
			autoHideWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false));
			assertFalse(autoHideWidget.visible);				
		}
		
		[Test(async, timeout=10000)]
		public function testAutoHideWidgetWithTimeout():void
		{
			var autoHideWidget:AutoHideWidget = new AutoHideWidget();
			var media:MediaElement = new MediaElement();
			autoHideWidget.media = media;
			
			FlexGlobals.topLevelApplication.stage.addChild(autoHideWidget);
			
			autoHideWidget.autoHide = true;
			autoHideWidget.autoHideTimeout = 3000;
			autoHideWidget.visible = false;
			
			autoHideWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, false));
			FlexGlobals.topLevelApplication.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false));
			assertTrue(autoHideWidget.visible);
			
			
			autoHideWidget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false));
			FlexGlobals.topLevelApplication.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false));
			
			assertTrue(autoHideWidget.visible);
			
			var timer:Timer = new Timer(3500, 1);
			Async.handleEvent(this, 
				timer, 
				TimerEvent.TIMER, 
				function(event:Event, param2:*=null):void
				{
					assertFalse(autoHideWidget.visible);
					
					FlexGlobals.topLevelApplication.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false));
					assertTrue(autoHideWidget.visible);		
				},
				4000
			);
			timer.start();
					
		}
	}
}