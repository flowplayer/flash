/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>
 * Copyright (c) 2011Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bitrateselect {
    import org.flowplayer.model.PluginFactory; 
    import flash.display.Sprite;

    public class BitrateSelectPlugin extends Sprite implements PluginFactory  {

        public function newPlugin():Object {
            return new BitrateSelectProvider();
        }
    }
}