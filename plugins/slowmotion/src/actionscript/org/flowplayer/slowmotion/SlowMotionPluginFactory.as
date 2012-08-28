/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.slowmotion {
    import flash.display.Sprite;

    import org.flowplayer.model.PluginFactory;

    public class SlowMotionPluginFactory extends Sprite implements PluginFactory {

        public function newPlugin():Object {
            return new SlowMotionPlugin();
        }
    }
}