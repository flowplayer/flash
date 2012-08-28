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

    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.StreamSelectionManager;
    import org.flowplayer.net.BitrateResource;

    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;



    import org.flowplayer.model.DisplayProperties;

    import flash.display.Stage;
    import flash.display.StageDisplayState;

    import org.flowplayer.bwcheck.config.Config;

    import org.osmf.net.DynamicStreamingItem;
    import org.osmf.net.NetStreamMetricsBase;
import org.osmf.net.NetStreamSwitchManager;

public class BWStreamSelectionManager extends StreamSelectionManager {

        private var _config:Config;
        private static var bwSelectLog:Log = new Log("org.flowplayer.bwcheck.net::BWStreamSelectionManager");
        private var dynamicStreamingItems:Vector.<DynamicStreamingItem>;
        //private var _netStreamMetrics:NetStreamMetricsBase;
        private var _netStreamSwitchManager:NetStreamSwitchManager;

        public function BWStreamSelectionManager(bitrateResource:BitrateResource, player:Flowplayer, resolver:ClipURLResolver, config:Config) {
            super(bitrateResource, player, resolver);
            _config = config;
        }

        override public function getStreamIndex(bandwidth:Number):Number {

            //#417 if screen size rule is disabled do not do screen size checks for the index.
            if (!_config.qos.screen) return super.getStreamIndex(bandwidth);

            for (var i:Number = streamItems.length - 1; i >= 0; i--) {

                var item:BitrateItem = streamItems[i];

                bwSelectLog.debug("candidate '" + item.streamName + "' has width " + item.width + ", bitrate " + item.bitrate);

                var enoughBw:Boolean = bandwidth >= item.bitrate;
                var bitrateSpecified:Boolean = item.bitrate > 0;
                bwSelectLog.debug("fits screen? " + fitsScreen(item, _player, _config) + ", enough BW? " + enoughBw + ", bitrate specified? " + bitrateSpecified);

                if (fitsScreen(item, _player, _config) && enoughBw && bitrateSpecified) {
                    bwSelectLog.debug("selecting bitrate with width " + item.width + " and bitrate " + item.bitrate);
                    //#417 disable setting the index with a screen size rule and manual switch with dynamic also enabled as it resets the index and causes issues obtaining the previous item.
                    //currentIndex = i;
                    return i;
                    break;
                }
            }
            return -1;
        }

        internal static function fitsScreen(item:BitrateItem, player:Flowplayer, config:Config):Boolean {
            if (! item.width) return true;

            var screen:DisplayProperties = player.screen;
            var stage:Stage = screen.getDisplayObject().stage;
            // take the size from screen when the screen width is 100% --> by default works on HW scaled mode also
            var screenWidth:Number = stage.displayState == StageDisplayState.FULL_SCREEN && screen.widthPct == 100 ? stage.fullScreenWidth : screen.getDisplayObject().width;

            bwSelectLog.debug("screen width is " + screenWidth);

            // max container width specified --> allows for resizing the player or for going above the current screen width
            if (config.maxWidth > 0 && ! player.isFullscreen()) {
                return config.maxWidth >= item.width;
            }
            return screenWidth >= item.width;
        }

        override public function changeStreamNames(mappedBitrate:BitrateItem):void {
            super.changeStreamNames(mappedBitrate);
            var url:String = mappedBitrate.url;
            currentIndex = mappedBitrate.index;
            _player.currentClip.setCustomProperty("bwcheckResolvedUrl", url);
        }

        //#352 if using secure names filenames will not be returned so use metric index instead
        override public function fromName(name:String):BitrateItem {
            var item:BitrateItem = super.fromName(name);

            if (_netStreamSwitchManager) {
                return item ? item : getItem(_netStreamSwitchManager.netStreamMetrics.currentIndex);
            }

            return item;
        }

        override public function get currentBitrateItem():BitrateItem {
            return _netStreamSwitchManager ? super.getItem(_netStreamSwitchManager.currentIndex) : super.currentBitrateItem;
        }

        override public function get currentIndex():Number {
            return _netStreamSwitchManager ? _netStreamSwitchManager.currentIndex : super.currentIndex;
        }

        override public function set currentIndex(value:Number):void {
            _netStreamSwitchManager ? _netStreamSwitchManager.currentIndex = value : super.currentIndex = value;
        }

        override public function set currentBitrateItem(value:BitrateItem):void {
            super.currentBitrateItem = value;
            if (_netStreamSwitchManager) _netStreamSwitchManager.currentIndex = value.index;
        }

        public function set qosSwitchManager(value:NetStreamSwitchManager):void {
            _netStreamSwitchManager = value;
        }
    }
}
