/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 package org.flowplayer.ui.buttons {

     import org.flowplayer.view.AbstractSprite;

     public class ConfigurableWidget extends AbstractSprite {

		public function configure(config:Object):void { throw new Error("You must override configure method"); }
      
        public function set enabled(value:Boolean):void { throw new Error("You must override enabled setter"); }

		public function get enabled():Boolean { throw new Error("You must override enabled getter"); return true; }
		
    }
}
