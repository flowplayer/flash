/*
 *    Copyright (c) 2008-2011 Flowplayer Oy *
 *    This file is part of FlowPlayer.
 *
 *    FlowPlayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    FlowPlayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.bwcheck.config {
	/**
	 * @author api
	 */
	import org.flowplayer.util.Log;

	public class QosRulesConfig {
		protected var log:Log = new Log(this);

		private var _values:Object = new Object();
		private var _properties:Array = ["bwUp", "bwDown", "frames", "buffer", "screen","ratio"];
        private var _minBufferLength:Number = 2;
        private var _minDroppedFrames:Number = 10;
        private var _bitrateSafety:Number = 1.0;
        private var _framesToLow:Number = 24;
        private var _framesToTwo:Number = 20;
        private var _framesToOne:Number = 10;
        private var _ruleCheckInterval:Number = 1000;
        private var _maxUpSwitchesPerStream:int = 3;
        private var _waitDurationAfterDownSwitch:int = 30000;
        private var _clearFailedCountInterval:Number = 1;
        private var _bufferScaleDownFactor:Number = 0.6;

		public function reset():void {
			_values = new Object();
		}

        public function get bufferScaleDownFactor():Number {
            return _bufferScaleDownFactor;
        }

        public function set bufferScaleDownFactor(value:Number):void {
            _bufferScaleDownFactor = value;
        }

        public function get minBufferLength():Number {
            return _minBufferLength;
        }

        public function set minBufferLength(value:Number):void {
            _minBufferLength = value;
        }

        public function get minDroppedFrames():Number {
            return _minDroppedFrames;
        }

        public function set minDroppedFrames(value:Number):void {
            _minDroppedFrames = value;
        }

        public function get framesToLow():Number {
            return _framesToLow;
        }

        public function set framesToLow(value:Number):void {
            _framesToLow = value;
        }

        public function get framesToTwo():Number {
            return _framesToTwo;
        }

        public function set framesToTwo(value:Number):void {
            _framesToTwo = value;
        }

        public function get framesToOne():Number {
            return _framesToLow;
        }

        public function set framesToOne(value:Number):void {
            _framesToOne = value;
        }

        public function get bitrateSafety():Number {
            return _bitrateSafety;
        }

        public function set bitrateSafety(value:Number):void {
            _bitrateSafety = value;
        }

		public function get bwUp():Boolean {
			return value("bwUp");
		}

		public function set bwUp(value:Boolean):void {
			_values["bwUp"] = value;
		}

		public function get bwDown():Boolean {
			return value("bwDown");
		}

		public function set bwDown(value:Boolean):void {
			_values["bwDown"] = value;
		}

		public function get frames():Boolean {
			return value("frames", false);
		}

		public function set frames(value:Boolean):void {
			_values["frames"] = value;
		}

		public function get buffer():Boolean {
			return value("buffer");
		}

		public function set buffer(value:Boolean):void {
			_values["buffer"] = value;
		}

		public function get screen():Boolean {
			return value("screen");
		}

		public function set screen(value:Boolean):void {
			_values["screen"] = value;
		}

        public function get ratio():Boolean {
			return value("ratio");
		}

		public function set ratio(value:Boolean):void {
			_values["ratio"] = value;
		}

        protected function value(prop:String, defaultVal:Boolean = true):Boolean {
            if (_values[prop] == undefined) return defaultVal;
            return _values[prop];
        }

		public function set all(value:Boolean):void {
			for (var i:Number = 0;i < _properties.length; i++) {
				if (_values[_properties[i]] == undefined) {
					_values[_properties[i]] = value;
				}
			}
		}

        public function get ruleCheckInterval():Number {
            return _ruleCheckInterval;
        }

        public function set ruleCheckInterval(value:Number):void {
            _ruleCheckInterval = value;
        }

        public function get clearFailedCountInterval():Number {
            return _clearFailedCountInterval;
        }

        public function set clearFailedCountInterval(value:Number):void {
            _clearFailedCountInterval = value;
        }

        public function get waitDurationAfterDownSwitch():int {
            return _waitDurationAfterDownSwitch;
        }

        public function set waitDurationAfterDownSwitch(value:int):void {
            _waitDurationAfterDownSwitch = value;
        }

        public function get maxUpSwitchesPerStream():int {
            return _maxUpSwitchesPerStream;
        }

        public function set maxUpSwitchesPerStream(value:int):void {
            _maxUpSwitchesPerStream = value;
        }
	}
}
