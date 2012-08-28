/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.config {
    import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.util.NumberUtil;

	import org.flowplayer.util.Log;

    public class BorderedWidgetConfig {
		
		protected var log:Log = new Log(this);
		
		private var _backgroundColor:String;
		private var _backgroundGradient:Array;
		private var _border:String;
		private var _borderRadius:Number;
		private var _heightRatio:Number;

		/*
         * Background Color.
         */

        public function get backgroundColor():Number {
            return StyleSheetUtil.colorValue(_backgroundColor);
        }

        public function get backgroundAlpha():Number {
            return StyleSheetUtil.colorAlpha(_backgroundColor);
        }

        public function setBackgroundColor(color:String):void {
            _backgroundColor = color;
        }

		
		/*
         * Background Gradient.
         */

        public function get backgroundGradient():Array {
            return _backgroundGradient;
        }

        public function setBackgroundGradient(gradient:Array):void {
            _backgroundGradient = gradient;
        }
		
		/*
         * Border
         */

        public function get borderColor():Number {
			return StyleSheetUtil.colorValue(StyleSheetUtil.parseShorthand('b', {b: _border})[2]);
        }

        public function get borderAlpha():Number {
			return StyleSheetUtil.colorAlpha(StyleSheetUtil.parseShorthand('b', {b: _border})[2]);
        }

		public function get borderWidth():Number {			
			// something about taking the hammer to get the circle into the square all :)
			return NumberUtil.decodePixels(StyleSheetUtil.parseShorthand('b', {b: _border})[0]);
		}

        public function setBorder(border:String):void {
            _border = border;
        }
		
	
		/*
		 * Border Radius
		 */
		public function get borderRadius():Number {
			return _borderRadius;
		}

		public function setBorderRadius(value:Number):void {
			_borderRadius = value;
		}
		
		
        /*
		 * Height ratio
		 */
		public function get heightRatio():Number {
			return _heightRatio;
		}
		
		public function setHeightRatio(value:Number):void {
			_heightRatio = value;
		}
		
		
    }
}