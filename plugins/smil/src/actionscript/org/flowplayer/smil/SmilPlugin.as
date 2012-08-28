/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil {
    import flash.display.Sprite;
    import org.flowplayer.model.PluginFactory;

    public class SmilPlugin extends Sprite implements PluginFactory{

        public function newPlugin():Object {
            return new SmilResolver();
        }
    }
}