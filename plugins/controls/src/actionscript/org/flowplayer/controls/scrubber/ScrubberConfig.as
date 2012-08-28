/*    
 *    Author: Thomas Dubois, <thomas _at_ flowplayer org>
 *
 *    Copyright (c) 2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.controls.scrubber {
    import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.controls.buttons.SliderConfig;
	
    public class ScrubberConfig extends SliderConfig {
        private var _bufferColor:String;
		private var _bufferGradient:Array;
		
        /*
         * Color.
         */

        public function get bufferColor():Number {
            return StyleSheetUtil.colorValue(_bufferColor);
        }

        public function get bufferAlpha():Number {
            return StyleSheetUtil.colorAlpha(_bufferColor);
        }

        public function setBufferColor(color:String):void {
            _bufferColor = color;
        }

		public function get bufferGradient():Array {
			return _bufferGradient;
		}
		
		public function setBufferGradient(gradient:Array):void {
			_bufferGradient = gradient;
		}
    }
}