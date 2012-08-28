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
package org.flowplayer.ui.buttons {
    import org.flowplayer.util.StyleSheetUtil;
	import org.flowplayer.ui.buttons.ButtonConfig;

    public class TooltipButtonConfig extends ButtonConfig {
        private var _tooltipColor:String;
		private var _tooltipTextColor:String;
		private var _marginBottom:Number = 5;
		private var _tooltipEnabled:Boolean;
		private var _tooltipLabel:String;
		
        /*
         * Color.
         */

        public function get tooltipColor():Number {
            return StyleSheetUtil.colorValue(_tooltipColor);
        }

        public function get tooltipAlpha():Number {
            return StyleSheetUtil.colorAlpha(_tooltipColor);
        }

        public function setTooltipColor(color:String):void {
            _tooltipColor = color;
        }

		public function get tooltipTextColor():Number {
            return StyleSheetUtil.colorValue(_tooltipTextColor);
        }

        public function get tooltipTextAlpha():Number {
            return StyleSheetUtil.colorAlpha(_tooltipTextColor);
        }

        public function setTooltipTextColor(color:String):void {
            _tooltipTextColor = color;
        }

		public function get marginBottom():Number {
			return _marginBottom;
		}
		
		public function set marginBottom(margin:Number):void {
			_marginBottom = margin;
		}
		
		public function get tooltipEnabled():Boolean {
			return _tooltipEnabled;
		}
		
		public function setTooltipEnabled(enabled:Boolean):void {
			_tooltipEnabled = enabled;
		}
		
		public function get tooltipLabel():String {
			return _tooltipLabel;
		}
		
		public function setTooltipLabel(label:String):void {
			_tooltipLabel = label;
		}
    }
}