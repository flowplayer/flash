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

package org.osmf.youtube
{
	import flash.display.Sprite;

	import org.osmf.youtube.events.YouTubeEvent;

	public class MockYoutubePlayer extends YouTubePlayerProxy
	{

		public function MockYoutubePlayer()
		{
			yt = new Sprite();
			super(yt);
		}
		
		// Mocked API
		override public function getCurrentTime():Number
		{
			return _currentTime;
		}
		override public function seekTo(value:Number, allowSeekAhead:Boolean=true):void
		{
			if (!_slowSeek)
			{
				_currentTime = value;
			}
		}

		override public function mute():void
		{
			_muted = true;
		}

		override public function unMute():void
		{
			_muted = false;
		}


		override public function isMuted():Boolean
		{
			return _muted;
		}

		override public function getVolume():Number
		{
			return _volume;
		}

		override public function setVolume(value:Number):void
		{
			_volume = value;
		}


		override public function getPlayerState():int
		{
			return _state;
		}

		override public function playVideo():void
		{
			_state = 1;
			dispatchEvent(new YouTubeEvent("onStateChange", _state));
		}

		override public function pauseVideo():void
		{
			_state = 2;
			dispatchEvent(new YouTubeEvent("onStateChange", _state));
		}

		override public function getAvailableQualityLevels():Array
		{
			return _qualityLevels;
		}

		override public function getPlaybackQuality():String
		{
			return _currentQuality;
		}

		override public function setPlaybackQuality(value:String):void
		{
			_currentQuality = value;
		}

		// Internals

		//
		public function set currentTime(value:Number):void
		{
			_currentTime = value;
		}

		public function set slowSeek(value:Boolean):void
		{
			_slowSeek = value;
		}

		public function set qualityLevels(value:Array):void
		{
			_qualityLevels = value;
		}


		private var yt:Sprite;
		private var _muted:Boolean;

		private var _volume:Number;
		private var _qualityLevels:Array = ["medium"];
		private var _currentQuality:String = "medium";

		private var _state:int = -1;

		private var _currentTime:Number = 0;

		private var _slowSeek:Boolean;

	}
}