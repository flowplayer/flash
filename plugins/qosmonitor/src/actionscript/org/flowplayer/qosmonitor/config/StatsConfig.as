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

package org.flowplayer.qosmonitor.config {
	/**
	 * @author danielr
	 */
	import org.flowplayer.util.Log;

	public class StatsConfig {
		protected var log:Log = new Log(this);

		private var _values:Object = new Object();
		private var _properties:Array = ["bandwidth", "buffer", "frames", "bitrate", "metrics"];

		public function reset():void {
			_values = new Object();
		}

		public function get bandwidth():Boolean {
			return value("bandwidth");
		}

		public function set bandwidth(value:Boolean):void {
			_values["bandwidth"] = value;
		}

		public function get buffer():Boolean {
			return value("buffer");
		}

		public function set buffer(value:Boolean):void {
			_values["buffer"] = value;
		}

		public function get frames():Boolean {
			return value("frames", false);
		}

		public function set frames(value:Boolean):void {
			_values["frames"] = value;
		}

		public function get bitrate():Boolean {
			return value("bitrate");
		}

		public function set bitrate(value:Boolean):void {
			_values["bitrate"] = value;
		}

		public function get metrics():Boolean {
			return value("metrics");
		}

		public function set metrics(value:Boolean):void {
			_values["metrics"] = value;
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
	}
}
