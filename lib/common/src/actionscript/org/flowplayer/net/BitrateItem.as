/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.net {
    import org.osmf.net.DynamicStreamingItem;

    /**
     * @author danielr
     */
    public class BitrateItem extends DynamicStreamingItem {
        public var url:String;
        public var isDefault:Boolean;
        public var index:int;
        public var label:String;
        public var hd:Boolean;
        public var sd:Boolean;

        public function BitrateItem():void {
            super(null, 0);
        }

        public function toString():String {
            return url + ", " + bitrate + ", is default? " + isDefault;
        }

        override public function get streamName():String {
            return url;
        }
    }
}
