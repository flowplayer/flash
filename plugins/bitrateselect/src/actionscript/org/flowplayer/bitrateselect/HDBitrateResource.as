/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.bitrateselect {

    import org.flowplayer.net.BitrateResource;
    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.model.Clip;

    public class HDBitrateResource extends BitrateResource {

        private var _hasHD:Boolean = false;

        override public function addBitratesToClip(clip:Clip):Vector.<BitrateItem> {

            var streamingItems:Vector.<BitrateItem> = super.addBitratesToClip(clip);

            if (streamingItems.length == 2) {

                var item1:BitrateItem = streamingItems[0] as BitrateItem;
                var item2:BitrateItem = streamingItems[streamingItems.length - 1] as BitrateItem;

                setHdProperty(item1, item2, clip);

                log.debug("HD feature enabled? " + _hasHD);
            }

            return streamingItems;
        }

        private function setHdProperty(item1:BitrateItem, item2:BitrateItem, clip:Clip):void {
            if (!(item1.hd || item2.hd || item1.sd || item2.sd)) return;
            _hasHD = true;

            if (item1.hd) {
                clip.setCustomProperty("hdBitrateItem", item1);
                clip.setCustomProperty("sdBitrateItem", item2);
                item2.sd = true;
                return;
            }
            if (item1.sd) {
                clip.setCustomProperty("sdBitrateItem", item1);
                clip.setCustomProperty("hdBitrateItem", item2);
                item2.hd = true;
                return;
            }
            setHdProperty(item2, item1, clip);
        }

        public function get hasHD():Boolean {
            return _hasHD;
        }
    }
}
