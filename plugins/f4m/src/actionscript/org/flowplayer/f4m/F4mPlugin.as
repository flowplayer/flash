/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.f4m {
    import org.flowplayer.model.PluginFactory; 
    import flash.display.Sprite;

    public class F4mPlugin extends Sprite implements PluginFactory  {
        
        public function F4mPlugin() {
            
        }
        
        public function newPlugin():Object {
            return new F4mProvider();
        }
    }
}