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

    import org.flowplayer.model.Clip;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;

    public class BitrateResource {
        protected var log:Log = new Log(this);

        protected function sort(bitrates:Vector.<BitrateItem>):Vector.<BitrateItem> {
            var sorter:Function = function (a:BitrateItem, b:BitrateItem):Number {
                // increasing bitrate order
                if (a.bitrate == b.bitrate) {
                    // decreasing width inside the same bitrate
                    if (a.width == b.width) {
                        return 0;
                    } else if (a.width < b.width) {
                        return 1;
                    }
                    return -1;


                } else if (a.bitrate > b.bitrate) {
                    return 1;
                }
                return -1;
            };
            return bitrates.concat().sort(sorter);
        }

        public function addBitratesToClip(clip:Clip):Vector.<BitrateItem> {
            log.debug("addBitratesToClip()");

            var streamingItems:Vector.<BitrateItem>;

            if (!clip.getCustomProperty("bitrateItems")) {
                streamingItems = new Vector.<BitrateItem>();

                var i:int = 0;

                // sort the bitrateitems in ascording order before generating the list.
                var bitrates:Array = (clip.getCustomProperty("bitrates") as Array).sortOn(["bitrate"], Array.NUMERIC);


                for each(var props:Object in bitrates) {
                    var bitrateItem:BitrateItem = new PropertyBinder(new BitrateItem()).copyProperties(props) as BitrateItem;

                    bitrateItem.index = i;

                    streamingItems.push(bitrateItem);
                    i++;
                }

                //set the BitrateItem to the clip to be reused later in the streamselector
                //clip.setCustomProperty("bitrateItems", sort(streamingItems));
                 clip.setCustomProperty("bitrateItems", streamingItems);
            } else {
                //we have a BitrateItems list configured in another plugin
                //Fixed casting issue if a DynamicStreamingItem resource #339
                //streamingItems = sort(Vector.<BitrateItem>(clip.getCustomProperty("bitrateItems")));
                streamingItems = Vector.<BitrateItem>(clip.getCustomProperty("bitrateItems"));
            }

            return streamingItems;
        }
    }

}
