/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.net {
    import org.flowplayer.bwcheck.config.Config;

    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.IStreamSelectionManager;

    import org.osmf.net.SwitchingRuleBase;
    import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
    import org.osmf.net.NetStreamMetricsBase;

    public class ScreenSizeRule extends SwitchingRuleBase {
        private var _player:Flowplayer;
        private var log:Log = new Log(this);
        private var _bitrates:Vector.<BitrateItem>;
        private var _config:Config;

        public function ScreenSizeRule(metrics:NetStreamMetricsBase, streamSelectionManager:IStreamSelectionManager, player:Flowplayer, config:Config) {
            super(metrics);
            _bitrates = streamSelectionManager.bitrates;
            _player = player;
            _config = config;
        }

        override public function getNewIndex():int {

            for (var i:Number = _bitrates.length - 1; i >= 0; i--) {
                var item:BitrateItem = _bitrates[i];

                log.debug("candidate '" + item.streamName + "' has width " + item.width);

                var fitsScreen:Boolean = BWStreamSelectionManager.fitsScreen(item, _player, _config);
                log.debug("fits screen? " + fitsScreen);

                if (fitsScreen) {
                    log.debug("selecting bitrate with width " + item.width + ", index " + i);
                    return i;
                    break;
                }
            }
            return -1;
        }

        private function get rtmpMetrics():RTMPNetStreamMetrics {
            return metrics as RTMPNetStreamMetrics;
        }

    }
}