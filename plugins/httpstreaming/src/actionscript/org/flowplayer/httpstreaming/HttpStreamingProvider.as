/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.httpstreaming {


    import flash.events.NetStatusEvent;
    import flash.net.NetStream;
    import flash.net.NetConnection;
    import flash.utils.setTimeout;

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.NumberUtil;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    import org.osmf.logging.Log;
    import org.osmf.net.httpstreaming.HTTPNetStream;
    import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFactory;
    import org.osmf.net.httpstreaming.dvr.DVRInfo;
    import org.osmf.metadata.Metadata;
    import org.osmf.metadata.MetadataNamespaces;
    import org.osmf.media.URLResource;
    import org.osmf.events.DVRStreamInfoEvent;


    import org.flowplayer.bwcheck.net.OsmfLoggerFactory;
    import org.flowplayer.httpstreaming.Config;

    public class HttpStreamingProvider extends NetStreamControllingStreamProvider implements Plugin {
        private var _bufferStart:Number;
        private var _config:Config;
        private var _startSeekDone:Boolean;
        private var _model:PluginModel;
        private var _previousClip:Clip;
        private var _player:Flowplayer;
        private var netResource:URLResource;
        private var _dvrInfo:DVRInfo;
        private var _dvrIsRecording:Boolean;
        private var _initialSeekTime:Number;
        
        override public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;

            CONFIG::LOGGING {
                Log.loggerFactory = new OsmfLoggerFactory();
            }
        }
    
        override public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");
            _player = player;
            
            _player.playlist.current.onSeek(function(event:ClipEvent):void {

                //if we have dvr info determine if its a dvr or live position.
                if (_dvrInfo) {
                    if (event.info <= dvrSeekOffset) {
                        dispatchDVREvent(_dvrInfo);
                    } else {
                        dispatchLiveEvent(Number(event.info));
                    }
                }
            });



            _model.dispatchOnLoad();
        }
    
        override protected function getClipUrl(clip:Clip):String {
            return clip.completeUrl;
        }
    
        override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
            if (!netResource) return;

            clip.onPlayStatus(onPlayStatus);
            _bufferStart = clip.currentTime;
            _startSeekDone = false;
            //reset dvr info
            _dvrInfo = null;
            _dvrIsRecording = false;

            //netStream.client = new NetStreamClient(clip, _player.config, streamCallbacks);
            netStream.play(clip.url, clip.start);
        }

        private function onPlayStatus(event:ClipEvent) : void {
            log.debug("onPlayStatus() -- " + event.info.code);
            if (event.info.code == "NetStream.Play.TransitionComplete"){
                dispatchEvent(new ClipEvent(ClipEventType.SWITCH_COMPLETE));
            }
            return;
        }

        override protected function onNetStatus(event:NetStatusEvent) : void {
            log.debug("onNetStatus(), code: " + event.info.code + ", paused? " + paused + ", seeking? " + seeking);
            switch(event.info.code){
                case "NetStream.Play.Transition":
                    log.debug("Stream Transition -- " + event.info.details);
                    dispatchEvent(new ClipEvent(ClipEventType.SWITCH, event.info.details));
                    break;
                case "NetStream.Play.UnpublishNotify":
                case "NetStream.Play.Stop":
                    //#550 for live streams once unpublished,  stop the player to prevent streamnotfound errors reconnecting.
                   _player.stop();
                    break;
            }
            return;
        }

        override protected function doSeek(event : ClipEvent, netStream : NetStream, seconds : Number) : void {
            var seekTime:int = int(seconds);
            _bufferStart = seekTime;
            log.debug("calling netStream.seek(" + seekTime + ")");
            seeking = true;

            //#515 when seeking on startup set a delay or else the initial time is treated as the clip start time.
            if (time <= 0 ) {
                setTimeout(function():void {
                    netStream.seek(seconds);
                }, 250);
                return;
            }
            netStream.seek(seekTime);
        }

        override protected function doSwitchStream(event:ClipEvent, netStream:NetStream, clip:Clip, netStreamPlayOptions:Object = null):void {      
            log.debug("doSwitchStream()");

			_previousClip = clip;

            if (netStream.hasOwnProperty("play2") && netStreamPlayOptions) {
                import flash.net.NetStreamPlayOptions;
                if (netStreamPlayOptions is NetStreamPlayOptions) {
					log.debug("doSwitchStream() calling play2()")
					netStream.play2(netStreamPlayOptions as NetStreamPlayOptions);
				}
			} else {
                //fix for #338, don't set the currentTime when dynamic stream switching
                _bufferStart = clip.currentTime;
                clip.currentTime = Math.floor(_previousClip.currentTime + netStream.time);
				load(event, clip);
                dispatchEvent(event);
			}
        }

        override protected function onMetaData(event:ClipEvent):void {
            log.debug("in NetStreamControllingStremProvider.onMetaData: " + event.target);

            //if we are not dvr recording dispatch start
            if (! clip.startDispatched && !_dvrIsRecording) {
                clip.dispatch(ClipEventType.START, pauseAfterStart);
                clip.startDispatched = true;
            }

            if (pauseAfterStart) {
                pauseToFrame();
            }
            switching = false;
        }

        override public function get allowRandomSeek():Boolean {
           return true;
        }
    
        override protected function canDispatchBegin():Boolean {
            return true;
        }

        override protected function canDispatchStreamNotFound():Boolean {
            return false;
        }
    
        public function getDefaultConfig():Object {
            return null;
        }
        
        override public function get type():String {
            return "httpstreaming";    
        }

        private function onDVRStreamInfo(event:DVRStreamInfoEvent):void
        {
            //this.netStream.removeEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);

            _dvrInfo = event.info as DVRInfo;

            _dvrIsRecording = _dvrInfo.isRecording;

            //don't update unless we are dvr recording
            if (!_dvrIsRecording) return;

            clip.duration = _dvrInfo.curLength;
            clip.setCustomProperty("dvrInfo", _dvrInfo);

            //start at dvr not live position
            //if clip start has not been dispatch seek to the live position and dispatch start
            if (!_config.startLivePosition || clip.startDispatched) return;

            //dispatch the dvr event
            dispatchDVREvent(_dvrInfo);

            //dispatch clip start
            clip.dispatch(ClipEventType.START, false);
            clip.startDispatched = true;

            //seek to the closest offset to the live position determined by the current dvr duration, buffertime and live snap offset.
            var livePosition:Number = Math.max(0, dvrSeekOffset);
            this.netStream.seek(livePosition);

            dispatchLiveEvent(livePosition);

        }

        private function dispatchDVREvent(dvrInfo:DVRInfo):void
        {
            log.debug("Seeking to DVR position");
            clip.dispatch(ClipEventType.PLAY_STATUS, {
                type: "dvr",
                info: dvrInfo
            });
        }

        private function dispatchLiveEvent(livePosition:Number):void
        {
            log.debug("Seeking to Live position");
            clip.dispatch(ClipEventType.PLAY_STATUS, {
                type: "live",
                info: livePosition
            });
        }

        private function get dvrSeekOffset():Number
        {
            return clip.duration - netStream.bufferTime - _config.dvrSnapToLiveClockOffset;
        }

        override protected function createNetStream(connection:NetConnection):NetStream {


            if (!clip.getCustomProperty("urlResource")) return super.createNetStream(connection);

            clip.type = ClipType.VIDEO;

            netResource = clip.getCustomProperty("urlResource") as URLResource;

            var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, new HTTPStreamingF4FFactory(), netResource);

            //#452 dvr integration
            var metadata:Metadata = netResource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
            if (metadata) {
                clip.setCustomProperty("dvr", true);
                httpNetStream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO, onDVRStreamInfo);
            }

            return httpNetStream;
        }

        override public function get bufferStart() : Number {
            if (!clip) return 0;
            if (!netStream) return 0;
            return Math.max(0, getCurrentPlayheadTime(netStream));
        }

        override public function get bufferEnd() : Number {
            if (!clip) return 0;
            if (!netStream) return 0;
            return getCurrentPlayheadTime(netStream) + netStream.bufferLength;
        }
    }
}
