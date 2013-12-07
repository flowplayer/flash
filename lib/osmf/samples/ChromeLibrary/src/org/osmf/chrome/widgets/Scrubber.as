/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.osmf.chrome.events.ScrubberEvent;

	[Event(name="scrubStart", type="org.osmf.samples.controlbar.ScrubberEvent")]
	[Event(name="scrubUpdate", type="org.osmf.samples.controlbar.ScrubberEvent")]
	[Event(name="scrubEnd", type="org.osmf.samples.controlbar.ScrubberEvent")]
	
	public class Scrubber extends Sprite
	{
		public function Scrubber(up:DisplayObject, down:DisplayObject, disabled:DisplayObject)
		{
			this.up = up;
			this.down = down;
			this.disabled = disabled;
			
			scrubTimer = new Timer(1000);
			scrubTimer.addEventListener(TimerEvent.TIMER, onDraggingTimer);
			
			updateFace(this.up);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			super();
		}
		
		public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				_enabled = value;
				mouseEnabled = value;
				updateFace(_enabled ? up : disabled);
			}
		}
		
		public function set origin(value:Number):void
		{
			_origin = value;
		}
		public function get origin():Number
		{
			return _origin;
		}
		
		public function set range(value:Number):void
		{
			_range = value;
		}
		public function get range():Number
		{
			return _range;
		}
		
		public function start(lockCenter:Boolean = true):void
		{
			if (_enabled && scrubbing == false)
			{
				scrubbing = true;
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
				updateFace(down);
				startDrag(lockCenter, new Rectangle(_origin, y, _range, 0));
				scrubTimer.start();
				dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_START));
			}
		}
		
		// Overrides
		//
		
		override public function set x(value:Number):void
		{
			if (scrubbing == false)
			{
				super.x = value;
			}
		}
		
		// Internals
		//
		
		private function updateFace(face:DisplayObject):void
		{
			if (currentFace != face)
			{
				if (currentFace)
				{
					removeChild(currentFace);
				}
				
				currentFace = face;
				
				if (currentFace)
				{
					addChild(currentFace);
				}
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			start(false);
		}
		
		private function onStageExitDrag(event:MouseEvent):void
		{
			scrubTimer.stop();
			stopDrag();
			updateFace(up);
			scrubbing = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageExitDrag);
			dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_END));
		}
		
		private function onDraggingTimer(event:TimerEvent):void
		{
			dispatchEvent(new ScrubberEvent(ScrubberEvent.SCRUB_UPDATE));
		}
		
		private var currentFace:DisplayObject;
		private var up:DisplayObject;
		private var down:DisplayObject;
		private var disabled:DisplayObject;
		
		private var _enabled:Boolean = true;
		private var _origin:Number = 0;
		private var _range:Number = 100;
		
		private var scrubbing:Boolean;
		private var scrubTimer:Timer;
	}
}