/*
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2012 Electroteque Multimedia
 *
 * The Initial Developer of the Apple-OSMF feature is Matthew Kaufman http://code.google.com/p/apple-http-osmf/
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.electroteque.m3u8 {

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.ClipURLResolver;
    
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;
    import flash.net.NetConnection;

    import org.osmf.net.StreamingURLResource;
    import org.osmf.media.URLResource;
    import org.osmf.net.httpstreaming.HTTPNetStream;

    import at.matthew.httpstreaming.*;


    public class HttpStreamingHlsProvider extends NetStreamControllingStreamProvider implements ClipURLResolver, Plugin {
        private var _bufferStart:Number;
        private var _config:Config;
        private var _startSeekDone:Boolean;
        private var _model:PluginModel;
        private var _currentClip:Clip;
        private var _previousClip:Clip;
        private var netResource:URLResource;

        /**
         * @inherit
         * @param model
         */
        override public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
        }

        /**
         * load event
         * @param player
         */
        override public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");
            _model.dispatchOnLoad();
        }

        /**
         * configure clip url
         * @param clip
         * @return
         */
        override protected function getClipUrl(clip:Clip):String {
            return clip.completeUrl;
        }

        /**
         * load new stream
         * @param event
         * @param netStream
         * @param clip
         */
        override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
            if (!netResource) return;
            _bufferStart = clip.currentTime;
            _startSeekDone = false;
            netStream.play(clip.url, clip.start);
        }

        /**
         * url resolver
         * @param provider
         * @param clip
         * @param successListener
         */
        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
              netResource = new StreamingURLResource(clip.url);
              successListener(clip);
        }

        /**
         * resolver failure listener
         * @param listener
         */
        public function set onFailure(listener:Function):void {
                //_failureListener = listener;
        }

        /**
         * handles netstatus events
         * @param event
         * @return
         */
        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        /**
         * @inherit
         * @param event
         * @param netStream
         * @param closeStreamAndConnection
         */
        override protected function doStop(event:ClipEvent, netStream:NetStream, closeStreamAndConnection:Boolean = false):void {
            _currentClip = null;
            log.debug("Clearing clip and stopping ");
            super.doStop(event, netStream, closeStreamAndConnection);
        }

        /**
         * @inherit
         * @param event
         * @param netStream
         * @param seconds
         */
        override protected function doSeek(event : ClipEvent, netStream : NetStream, seconds : Number) : void {
            var seekTime:int = int(seconds);
            _bufferStart = seekTime;
            log.debug("calling netStream.seek(" + seekTime + ")");
            seeking = true;
            netStream.seek(seekTime);
        }

        /**
         * @inherit
         * @param event
         * @param netStream
         * @param clip
         * @param netStreamPlayOptions
         */
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

        /**
         * @inherit
         * @param event
         */
        override protected function onMetaData(event:ClipEvent):void {
            log.debug("in NetStreamControllingStremProvider.onMetaData: " + event.target);

            if (! clip.startDispatched) {
                clip.dispatch(ClipEventType.START, pauseAfterStart);
                clip.startDispatched = true;
            }

            if (pauseAfterStart) {
                pauseToFrame();
            }
            switching = false;
        }

        /**
         * @inherit
         */
        override public function get bufferStart() : Number {
            if (!clip) return 0;
            if (!netStream) return 0;
            return Math.max(0, getCurrentPlayheadTime(netStream));
        }

        /**
         * @inherit
         */
        override public function get bufferEnd() : Number {
            if (!clip) return 0;
            if (!netStream) return 0;
            return getCurrentPlayheadTime(netStream) + netStream.bufferLength;
        }

        /**
         * @inherit
         */
        override public function get allowRandomSeek():Boolean {
           return true;
        }

        /**
         * @inherit
         * @return
         */
        override protected function canDispatchBegin():Boolean {
            return true;
        }

        /**
         * @inherit
         * @param event
         */
        override protected function onNetStatus(event:NetStatusEvent):void {
            log.info("onNetStatus: " + event.info.code);

        }

        public function getDefaultConfig():Object {
            return null;
        }

        /**
         * @inherit
         */
        override public function get type():String {
            return "httpstreaminghls";
        }

        /**
         * @inherit
         * @param connection
         * @return
         */
        override protected function createNetStream(connection:NetConnection):NetStream {
            clip.type = ClipType.VIDEO;
            var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, new HTTPStreamingM3U8Factory(), netResource);
            return httpNetStream;
        }
    }
}
