/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Thomas Dubois, thomas _at_ flowplayer.org
 * Copyright (c) 2010 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.cloudfrontsignedurl {
    import flash.display.Sprite;
    import org.flowplayer.model.PluginFactory;

    public class CloudFrontSignedUrlPlugin extends Sprite implements PluginFactory{

        public function newPlugin():Object {
            return new CloudFrontSignedUrl();
        }
    }
}