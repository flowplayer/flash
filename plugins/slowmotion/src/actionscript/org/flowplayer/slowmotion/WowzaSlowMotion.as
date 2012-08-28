/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.slowmotion {
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.TimeProvider;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginModel;

    public class WowzaSlowMotion extends AbstractSlowMotion {

        public function WowzaSlowMotion(model:PluginModel, playlist:Playlist, provider:StreamProvider, providerName:String) {
            super(model, playlist, provider, providerName);
            playlist.onSeek(onSeek, slowMotionClipFilter);
        }

        private function onSeek(event:ClipEvent):void {
            if (isTrickPlay()) {
                restartTrickPlay();
            }
        }

        private function restartTrickPlay():void {
            trickSpeed(info.speedMultiplier, info.forwardDirection);
        }

        override public function getTimeProvider():TimeProvider {
            return this;
        }

        override protected function normalSpeed():void {
            netStream.seek(time);
        }

        override protected function trickSpeed(multiplier:Number, forward:Boolean):void {
            log.info("trickSpeed(), multiplier == " + multiplier + ", time is " + time);
            var targetFps:Number = multiplier * 50;
            provider.netConnection.call("setFastPlay", null, multiplier, targetFps, forward ? 1 : -1);
            netStream.seek(time);
        }

        override public function getInfo(event:NetStatusEvent):SlowMotionInfo {
            if (event.info.code == "NetStream.Play.Start") {
				log.debug("Got Start");

                if (event.info.isFastPlay != undefined) {
					if ( event.info.isFastPlay ) {
						return new SlowMotionInfo(playlist.current, true, Number(event.info.fastPlayDirection) > 0, event.info.fastPlayOffset as Number, event.info.fastPlayMultiplier as Number);
	                    log.debug("isFastPlay = true");
					}
					else {
						log.debug("isFastPlay = false");
                        return new SlowMotionInfo(playlist.current, false, true, 0, 0);
					}

                }
            }
            return null;
        }
    }
}
