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
	import __AS3__.vec.Vector;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import flexunit.framework.Assert;
	
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DVREvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.utils.DynamicMediaElement;

	public class TestTraitEventDispatcher
	{
		[Before]
		public function setUp():void
		{
			caughtEvents = new Vector.<Event>();
			dispatcher = new TraitEventDispatcher();
		}
		
		[After]
		public function tearDown():void
		{
			dispatcher = null
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testWithoutElement():void
		{			
			//Test Trait events without a mediaElement.
			dispatcher.addEventListener(AudioEvent.MUTED_CHANGE, catchEvents);
			dispatcher.removeEventListener(AudioEvent.MUTED_CHANGE, catchEvents);
			
			//Test Non-trait events
			dispatcher.addEventListener(Event.ENTER_FRAME, catchEvents);
					
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
			
			Assert.assertEquals(1, caughtEvents.length);
			Assert.assertEquals(Event.ENTER_FRAME, caughtEvents[0].type);
			
			dispatcher.removeEventListener(Event.ENTER_FRAME, catchEvents);		
			
			dispatcher.dispatchEvent(new Event(Event.ENTER_FRAME));
						
			Assert.assertEquals(1, caughtEvents.length);
				
		}
		
		
		private function testWithElement(events:Vector.<Event>, properties:Vector.<String>, traitType:String):void
		{
			var itr:Number = 0;
			var itr2:Number = 0;
			
			for (itr = 0; itr < events.length; itr++)
			{
				dispatcher.addEventListener(events[itr].type, catchEvents);
			}
							
			var media:DynamicMediaElement = new DynamicMediaElement([traitType], null, null, true); 
			dispatcher.media = media;
				
		
			var trait:MediaTraitBase = media.getTrait(traitType) ;
			
			for (itr = 0; itr < events.length; itr++)
			{
				trait.dispatchEvent(events[itr]);
			}
						
			Assert.assertEquals(events.length, caughtEvents.length);
						
			for (itr = 0; itr < events.length; itr++)
			{
				Assert.assertEquals(caughtEvents[itr].type,  events[itr].type );
				Assert.assertTrue(caughtEvents[itr] is (getDefinitionByName(getQualifiedClassName(events[itr])) as Class) );
				for (itr2 = 0; itr2 < properties.length; itr2++)
				{
					Assert.assertEquals(events[itr][properties[itr2]], caughtEvents[itr][properties[itr2]]);
				}
			}			
						
			//Negative case - no events dispatched
		
			DynamicMediaElement(dispatcher.media).doRemoveTrait(traitType);
				
			for (itr = 0; itr < events.length; itr++)
			{
				trait.dispatchEvent(events[itr]);
			}
			
			Assert.assertEquals(events.length, caughtEvents.length);
			
			//Now Readd	
			media.doAddTrait(traitType, trait);
			//But remove the element		
			dispatcher.media = null;
			
			for (itr = 0; itr < events.length; itr++)
			{
				trait.dispatchEvent(events[itr]);
			}
			
			Assert.assertEquals(events.length, caughtEvents.length);	
			
			dispatcher.media = media;
			
			//clear out the events:
			caughtEvents.splice(0, caughtEvents.length);
			
			for (itr = 0; itr < events.length; itr++)
			{
				trait.dispatchEvent(events[itr]);
			}
			
			Assert.assertEquals(events.length, caughtEvents.length);
			for (itr = 0; itr < events.length; itr++)
			{
				Assert.assertTrue(caughtEvents[itr] is (getDefinitionByName(getQualifiedClassName(events[itr])) as Class) );
				Assert.assertEquals(caughtEvents[itr].type,  events[itr].type );
				for (itr2 = 0; itr2 < properties.length; itr2++)
				{
					Assert.assertEquals(events[itr][properties[itr2]], caughtEvents[itr][properties[itr2]]);
				}
			}		
						
		}
		
		[Test]
		public function testAudioEvents():void
		{
			var muteEvent:AudioEvent = new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, true, 0, 0);
			var volumeEvent:AudioEvent = new AudioEvent(AudioEvent.VOLUME_CHANGE, false, false, false, .2, 0);
			var panEvent:AudioEvent = new AudioEvent(AudioEvent.PAN_CHANGE, false, false, true, 0, -.2);
			
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(muteEvent,volumeEvent,panEvent);
			properties.push("muted","volume","pan");
			
			testWithElement(events, properties, MediaTraitType.AUDIO);									 
		}
		
		[Test]
		public function testDisplayObjectEvents():void
		{			
			var event1:DisplayObjectEvent = new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, false, false, new Sprite(), new Sprite(), 150, 150, 300, 500);
			var event2:DisplayObjectEvent = new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE, false, false, new Sprite(), new Sprite(), 100, 100, 200, 200);
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event2);
			
			properties.push("newDisplayObject", "oldDisplayObject", "oldWidth", "oldHeight", "newHeight", "newWidth");
			
			testWithElement(events, properties, MediaTraitType.DISPLAY_OBJECT);									 
		}
		
		[Test]
		public function testBufferEvents():void
		{
			var event1:BufferEvent = new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE, false, false, true, 200);
			var event2:BufferEvent = new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, false, 100);
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event2);
			var ev:BufferEvent;
			properties.push("buffering", "bufferTime");
			
			testWithElement(events, properties, MediaTraitType.BUFFER);											 
		}
		
		[Test]
		public function testSeekEvents():void
		{
			var event1:SeekEvent = new SeekEvent(SeekEvent.SEEKING_CHANGE, false, false, true, 12);
			var event2:SeekEvent = new SeekEvent(SeekEvent.SEEKING_CHANGE, false, false, false, 15 );
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event2);
			
			properties.push("time");
			
			testWithElement(events, properties, MediaTraitType.SEEK);											 
		}
		
		[Test]
		public function testPlayEvents():void
		{
			var event1:PlayEvent = new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE, false, false, PlayState.PAUSED, false);
			var event2:PlayEvent = new PlayEvent(PlayEvent.PLAY_STATE_CHANGE, false, false, PlayState.PLAYING, true );
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event2);
			
			properties.push("playState", "canPause");
			
			testWithElement(events, properties, MediaTraitType.PLAY);						 
		}
		
		[Test]
		public function testTimeEvents():void
		{
			var event1:TimeEvent = new TimeEvent(TimeEvent.COMPLETE, false, false, 3);
			//Trait doesn't dispatch this, but MP does
			//var event2:TimeEvent = new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE, false, false, 1 );
			var event3:TimeEvent = new TimeEvent(TimeEvent.DURATION_CHANGE, false, false, 3 );
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event3);
			
			properties.push("time");
			
			testWithElement(events, properties, MediaTraitType.TIME);										 
		}
		
		[Test]
		public function testDRMEvents():void
		{
			var event1:DRMEvent = new DRMEvent(DRMEvent.DRM_STATE_CHANGE, DRMState.AUTHENTICATION_COMPLETE, false, false, new Date(1), new Date(2), 4, "server1", null, null );
			var event2:DRMEvent = new DRMEvent(DRMEvent.DRM_STATE_CHANGE, DRMState.AUTHENTICATING, false, false, new Date(8), new Date(9), 4, "server1", null, null );
			var event3:DRMEvent = new DRMEvent(DRMEvent.DRM_STATE_CHANGE, DRMState.AUTHENTICATION_NEEDED, false, false, new Date(11), new Date(12), 4, "server1", null, null );
			var event4:DRMEvent = new DRMEvent(DRMEvent.DRM_STATE_CHANGE, DRMState.AUTHENTICATION_ERROR, false, false, new Date(11), new Date(12), 4, "server1", null, new MediaError(1, "detail") );
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1,event2, event3, event4);
			
			properties.push("drmState", "mediaError", "endDate", "period", "serverURL", "startDate", "token");
			
			testWithElement(events, properties, MediaTraitType.DRM);													 
		}

		[Test]
		public function testDVREvents():void
		{
			var event1:DVREvent = new DVREvent(DVREvent.IS_RECORDING_CHANGE);
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1);
			
			testWithElement(events, properties, MediaTraitType.DVR);													 
		}
		
		[Test]
		public function  testDynamicStreamEvents():void
		{
			var event1:DynamicStreamEvent = new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE, false, false, false, false);
			var event2:DynamicStreamEvent = new DynamicStreamEvent(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, false, false, false, true );
			var event3:DynamicStreamEvent = new DynamicStreamEvent(DynamicStreamEvent.SWITCHING_CHANGE, false, false, true, true );
						
			var events:Vector.<Event> = new Vector.<Event>();
			var properties:Vector.<String> = new Vector.<String>();
			events.push(event1, event2, event3);
			
			properties.push("autoSwitch", "switching");
			
			testWithElement(events, properties, MediaTraitType.DYNAMIC_STREAM);										 
		}
				
		private function catchEvents(event:Event):void
		{
			caughtEvents.push(event);
		}		
		
		private var caughtEvents:Vector.<Event>;
		private var dispatcher:TraitEventDispatcher;
	}
}