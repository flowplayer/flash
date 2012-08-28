/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.time {
    
	import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.controls.config.BorderedWidgetConfig;

    public class TimeViewConfig extends BorderedWidgetConfig {
		
		private var _durationColor:String;
		private var _fontSize:Number = 14;
		private var _separator:String = "/";
		private var _timeColor:String;
	

		/*
         * Duration Color.
         */

        public function get durationColor():Number {
            return StyleSheetUtil.colorValue(_durationColor);
        }

        public function get durationAlpha():Number {
            return StyleSheetUtil.colorAlpha(_durationColor);
        }

        public function setDurationColor(color:String):void {
            _durationColor = color;
        }


		/*
		 * Font Size
		 */
		public function get fontSize():Number {
			return _fontSize;
		}
		
		public function setFontSize(value:Number):void {
			_fontSize = value;
		}
		
		
		/*
		 * Separator
		 */
		public function get separator():String {
			return _separator;
		}
		
		public function setSeparator(value:String):void {
			_separator = value;
		}
		
		
        /*
         * Time Color.
         */

        public function get timeColor():Number {
            return StyleSheetUtil.colorValue(_timeColor);
        }

        public function get timeAlpha():Number {
            return StyleSheetUtil.colorAlpha(_durationColor);
        }

        public function setTimeColor(color:String):void {
            _timeColor = color;
        }
        
    }
}