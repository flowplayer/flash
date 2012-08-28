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

    public class ToggleButtonConfig {
        private var _buttonConfig:ButtonConfig;
		private var _downButtonConfig:ButtonConfig;
		
		public function ToggleButtonConfig(config:ButtonConfig, downConfig:ButtonConfig) {
			_buttonConfig = config;
			_downButtonConfig = downConfig;
		}
		
		public function get config():ButtonConfig {
			return _buttonConfig;
		}
		
		public function set config(config:ButtonConfig):void {
			_buttonConfig = config;
		}
		
       	public function get downConfig():ButtonConfig {
			return _downButtonConfig;
		}
		
		public function set downConfig(config:ButtonConfig):void {
			_downButtonConfig = config;
		}
    }
}