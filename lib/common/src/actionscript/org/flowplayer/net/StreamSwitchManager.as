/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.net {

    import flash.net.NetStream;
    import flash.net.NetStreamPlayOptions;
    import flash.net.NetStreamPlayTransitions;

    import flash.events.NetStatusEvent;

    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.util.Log;


    public class StreamSwitchManager {

        private var _netStream:NetStream;
        private var _streamSelectionManager:IStreamSelectionManager;
        private var _player:Flowplayer;
        private var _previousBitrateItem:BitrateItem;


        protected var log:Log = new Log(this);

        public function StreamSwitchManager(netStream:NetStream, streamSelectionManager:IStreamSelectionManager, player:Flowplayer) {
            _netStream = netStream;
            _streamSelectionManager = streamSelectionManager;
            _player = player;
        }

        public function get previousBitrateItem():BitrateItem {
            return _previousBitrateItem;
        }


        public function switchStream(bitrateItem:BitrateItem):void {

            _previousBitrateItem = _streamSelectionManager.currentBitrateItem;

            _streamSelectionManager.changeStreamNames(bitrateItem);

            //#463 Adding switch prevention if the mapped bitrate has not changed.
            if (bitrateItem.bitrate == _previousBitrateItem.bitrate) {
                log.debug("Mapped bitrate " + bitrateItem.bitrate + " has not changed will not switch");
                return;
            }

            //#404 allow play2 for http streams, will reset correctly.
            if (_netStream && _netStream.hasOwnProperty("play2")) {

                var netStreamPlayOptions:NetStreamPlayOptions = new NetStreamPlayOptions();
                if (_previousBitrateItem) {
                    netStreamPlayOptions.oldStreamName = _previousBitrateItem.url;
                    netStreamPlayOptions.transition = NetStreamPlayTransitions.SWITCH;
                } else {
                    netStreamPlayOptions.transition = NetStreamPlayTransitions.RESET;
                }

                //#370 set the clip start time or else dynamic switching doesn't function correctly.
                //#547 don't set the start property unless set, causes problems for live streams.
                if (_player.currentClip.start) netStreamPlayOptions.start = _player.currentClip.start;
                netStreamPlayOptions.streamName = bitrateItem.url;

                //#417 provide previous item name in the logs.
                log.debug("calling switchStream with dynamic stream switch support, stream name is " + netStreamPlayOptions.streamName + ", previous stream name: " + _previousBitrateItem.streamName);

                //_player.streamProvider.netStream.play2(netStreamPlayOptions);
                _player.switchStream(_player.currentClip, netStreamPlayOptions);
            } else {
                log.debug("calling switchStream, stream name is " + bitrateItem.url);
                _player.switchStream(_player.currentClip);
            }

        }
    }
}
