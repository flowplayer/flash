/*    
 *    Author: Thomas Dubois, <thomas _at_ flowplayer org>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.controls.buttons {
    import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.controls.config.BorderedWidgetConfig;
	
    public class SliderConfig extends BorderedWidgetConfig {
        private var _color:String;
        private var _disabledColor:String;
		private var _gradient:Array;

		private var _barHeightRatio:Number;
		private var _draggerButtonConfig:TooltipButtonConfig;
		
		private var _enabled:Boolean = true;

        /*
         * Color.
         */

        public function get color():Number {
            return StyleSheetUtil.colorValue(_color);
        }

        public function get alpha():Number {
            return StyleSheetUtil.colorAlpha(_color);
        }

        public function setColor(color:String):void {
            _color = color;
        }

        public function get colorRGB():Array {
            return StyleSheetUtil.rgbValue(color);
        }

        public function get colorRGBA():Array {
            var rgba:Array = colorRGB;
            rgba.push(alpha);
            return rgba;
        }

        public function get disabledColor():Number {
            return StyleSheetUtil.colorValue(_disabledColor);
        }

        public function get disabledAlpha():Number {
            return StyleSheetUtil.colorAlpha(_disabledColor);
        }

        public function setDisabledColor(color:String):void {
            _disabledColor = color;
        }

        public function get disabledRGB():Array {
            return StyleSheetUtil.rgbValue(disabledColor);
        }

        public function get disabledRGBA():Array {
            var rgba:Array = disabledRGB;
            rgba.push(disabledAlpha);
            return rgba;
        }

		public function get gradient():Array {
			return _gradient;
		}
		
		public function setGradient(gradient:Array):void {
			_gradient = gradient;
		}
		
		public function get barHeightRatio():Number {
			return _barHeightRatio;
		}
		
		public function setBarHeightRatio(ratio:Number):void {
			_barHeightRatio = ratio;
		}
		
		public function get draggerButtonConfig():TooltipButtonConfig {
			return _draggerButtonConfig;
		}
		
		public function setDraggerButtonConfig(config:TooltipButtonConfig):void {
			_draggerButtonConfig = config;
		}
		
		/*
		 * Enabled 
		 */
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function setEnabled(value:Boolean):void {
			_enabled = value;
		}
    }
}