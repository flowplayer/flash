/*
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2012 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.electroteque.m3u8 {
    import org.flowplayer.model.PluginFactory; 
    import flash.display.Sprite;

    public class HttpStreamingHlsPlugin extends Sprite implements PluginFactory  {
        
        public function HttpStreamingHlsPlugin() {
            
        }
        
        public function newPlugin():Object {
            return new HttpStreamingHlsProvider();
        }
    }
}