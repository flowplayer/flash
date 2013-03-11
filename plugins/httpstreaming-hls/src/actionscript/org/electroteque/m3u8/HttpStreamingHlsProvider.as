/*
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2012 Electroteque Media
 *
 * The Initial Developer of the Apple-OSMF feature is Matthew Kaufman http://code.google.com/p/apple-http-osmf/
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.electroteque.m3u8 {

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipError;
    import org.flowplayer.model.ErrorCode;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.controller.NetStreamControllingStreamProvider;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.ErrorHandler;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.net.BitrateItem;
    
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;
    import flash.net.NetConnection;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.setTimeout;

    import at.matthew.httpstreaming.parser.HttpStreamingM3U8ManifestParser;
    import at.matthew.httpstreaming.model.HttpStreamingM3U8Manifest;
    import at.matthew.httpstreaming.HTTPStreamingM3U8Factory;

    import org.osmf.media.MediaResourceBase;
    import org.osmf.media.URLResource;

    import org.osmf.events.ParseEvent;

    import org.osmf.net.DynamicStreamingResource;
    import org.osmf.net.DynamicStreamingItem;
    import org.osmf.net.StreamingURLResource;

    import org.osmf.net.httpstreaming.HTTPNetStream;

    CONFIG::REDIRECT {
        import flash.net.URLLoader;
        import flash.net.URLRequest;
        import flash.events.IOErrorEvent;
        import flash.events.Event;
        import flash.net.URLRequestMethod;
        import flash.net.URLVariables;
    }

    CONFIG::LOGGING
    {
        import org.osmf.logging.Log;
    }

    public class HttpStreamingHlsProvider extends NetStreamControllingStreamProvider implements ClipURLResolver, ErrorHandler, Plugin {
        protected var _bufferStart:Number;
        protected var _config:Config;
        protected var _startSeekDone:Boolean;
        protected var _model:PluginModel;
        protected var _player:Flowplayer;
        protected var _clip:Clip;
        protected var _currentClip:Clip;
        protected var _previousClip:Clip;
        protected var manifest:HttpStreamingM3U8Manifest;
        protected var parser:HttpStreamingM3U8ManifestParser;
        protected var resource:MediaResourceBase;
        protected var netResource:URLResource;
        protected var dynResource:DynamicStreamingResource;
        protected var streamResource:StreamingURLResource;
        protected var _isDynamicStreamResource:Boolean = false;
        protected var _successListener:Function;
        protected var _retryTimer:Timer;
        protected var _retryCount:int;
        private var _receivedStop:Boolean;
        private var _hasNext:Boolean;

        /**
         * @inherit
         * @param model
         */
        override public function onConfig(model:PluginModel):void {
            _model = model;

            CONFIG::LOGGING
            {
                Log.loggerFactory = new OsmfLoggerFactory();
            }

            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;

        }

        /**
         * load event
         * @param player
         */
        override public function onLoad(player:Flowplayer):void {
            log.info("onLoad()");
            _player = player;
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
            clip.onPlayStatus(onPlayStatus);

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
            _clip = clip;
            _successListener = successListener;

            if (clip.resolvedUrl) {
                if (_successListener != null) {
                    _successListener(_clip);
                }
                return;
            }

            if (CONFIG::REDIRECT) {
                if (_config.redirectUrl) {
                    getRedirectUrl(_clip.completeUrl, onM3U8RedirectUrl);
                } else {
                    loadM3U8(_clip.completeUrl, onM3U8Loaded);
                }
            } else {
                loadM3U8(_clip.completeUrl, onM3U8Loaded);
            }

            //loadM3U8(_clip.completeUrl, onM3U8Loaded);
        }

        CONFIG::REDIRECT {
        /**
         * Reload the m3u8 feed with the redirected url
         * @param url
         */
        private function onM3U8RedirectUrl(url:String):void
        {
            _clip.setResolvedUrl(null, url);
            loadM3U8(_clip.resolvedUrl, onM3U8Loaded);
        }

        /**
         * Get the redirection url to obtain the baseurl from using a proxy script.
         * This is required because of a limitation in flash obtaining the response url.
         *
         * @param m3u8Url
         * @param loadedCallback
         */
        private function getRedirectUrl(m3u8Url:String, loadedCallback:Function):void {

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, function(event:Event):void {
                if (!URLLoader(event.target).data) {
                    handleStreamNotFound("Redirected url not found");
                    return;
                }
                loadedCallback(URLLoader(event.target).data);
            });

            loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
                handleStreamNotFound("Error loading Redirect service");
            });

            var urlVars:URLVariables = new URLVariables();
            urlVars.url = encodeURI(m3u8Url);

            var request:URLRequest = new URLRequest(encodeURI(_config.redirectUrl));
            request.method = URLRequestMethod.POST;
            request.data = urlVars;

            loader.load(request);

        }
        }


        /**
         * Loads the M3u8 playlist
         * @param m3u8Url
         * @param loadedCallback
         */
        protected function loadM3U8(m3u8Url:String, loadedCallback:Function):void {
            if (!_player) return;
            log.debug("connect(), loading M3U8 file from " + m3u8Url);

            var loader:ResourceLoader = _player.createLoader();
            loader.errorHandler = this;
            loader.load(m3u8Url, function(loader:ResourceLoader):void {
                log.debug("M3U8 file received");
                loadedCallback(String(loader.getContent()));
            }, true);
        }

        /**
         * M3u8 playlist loaded and parsing the manifest
         * @param m3u8Content
         */
        protected function onM3U8Loaded(m3u8Content:String):void {
            stopM3U8Reload();
            parseM3U8Manifest(m3u8Content);
        }

        /**
         * formats the streaming items
         * @param streamItems
         * @return
         */
        protected function formatStreamItems(streamItems:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
            var bitrateItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
            var bitrateOptions:Object = {};
            if (_clip.getCustomProperty("bitrates")) {
                bitrateOptions = _clip.getCustomProperty("bitrates");
            } else {
                bitrateOptions.default = streamItems[0].bitrate;

                if (streamItems.length == 2) {
                    bitrateOptions.sd = streamItems[0].bitrate;
                    bitrateOptions.hd = streamItems[streamItems.length - 1].bitrate;
                }
            }

            for (var index:int = 0; index < streamItems.length; index++) {
                var item:DynamicStreamingItem = streamItems[index];

                var bitrateItem:BitrateItem = new BitrateItem();
                bitrateItem.url = item.streamName;
                bitrateItem.bitrate = item.bitrate;
                bitrateItem.index = index;
                bitrateItem.width = item.width;
                bitrateItem.height = item.height;
                if (bitrateOptions.default == bitrateItem.bitrate) bitrateItem.isDefault = true;
                if (bitrateOptions.sd == bitrateItem.bitrate) bitrateItem.sd = true;
                if (bitrateOptions.hd == bitrateItem.bitrate) bitrateItem.hd = true;
                if (bitrateOptions.labels) bitrateItem.label = bitrateOptions.labels[bitrateItem.bitrate];
                bitrateItems.push(bitrateItem);
            }
            return bitrateItems;
        }

        /**
         * M3u8 manifest parsing has finished
         */
        protected function onM3U8Finished():void
        {
            log.debug("M3U8 Manifest Finished");

            try
            {
                resource = parser.createResource(manifest, new URLResource(_clip.completeUrl));

                //dynamic streaming resource
                if (resource is DynamicStreamingResource) {
                    dynResource = resource as DynamicStreamingResource;
                    //formats the stream items to be ready for the bwcheck plugin
                    dynResource.streamItems = formatStreamItems(dynResource.streamItems);
                    _isDynamicStreamResource = true;
                    _clip.setCustomProperty("bitrateItems", dynResource.streamItems);
                    _clip.setCustomProperty("urlResource", dynResource);

                } else {
                    //single bitrate resource
                    streamResource = resource as StreamingURLResource;

                    log.debug("Manifest parsed with a single stream " + manifest.media[0].url);
                    _clip.setResolvedUrl(this, streamResource.url);
                    _clip.setCustomProperty("urlResource", streamResource);
                }

                _clip.setCustomProperty("manifestInfo",manifest);


                if (_successListener != null) {
                    _successListener(_clip);
                }

            }
            catch (error:Error)
            {
                handleStreamNotFound(error.message);
            }
        }

        /**
         * Handle stream not found errors, for live streams use connection reattempts until it becomes available.
         * @param message
         */
        private function handleStreamNotFound(message:String):void
        {
            log.error(message);

            if (_clip.live) {
                retryM3U8Load();
                return;
            }

            _clip.dispatchError(ClipError.STREAM_NOT_FOUND, message);
        }

        /**
         * Stop the playlist loading timer
         */
        protected function stopM3U8Reload():void
        {
            if (_retryTimer) {
                _retryTimer.stop();
                _retryTimer.removeEventListener(TimerEvent.TIMER, onM3U8LoadRetry);
                _retryTimer.reset();
                _retryTimer = null;
                _retryCount = 0;
            }
        }

        /**
         * Attempt to reconnect or stop if the retry count has reached it's limit.
         */
        private function retryM3U8Load():void
        {
            if (!_retryTimer) {
                _retryTimer = new Timer(_config.retryInterval);
                _retryTimer.addEventListener(TimerEvent.TIMER, onM3U8LoadRetry);
                _retryTimer.start();
                log.error("Reattempting to load media from M3U8 manifest " + _clip.completeUrl);
            }

            _retryCount++;

            if (_retryCount > _config.maxRetries) {
                stopM3U8Reload();
            }
        }

        /**
         * Reload the M3U8 feed after a set interval.
         * @param event
         */
        private function onM3U8LoadRetry(event:TimerEvent):void
        {
            log.error("Reattempting to load media from M3U8 manifest " + _clip.completeUrl);
            loadM3U8(_clip.completeUrl, onM3U8Loaded);
        }

        /**
         * Formats the baseUrl
         * @param url
         * @return
         */
        protected function getRootUrl(url:String):String
        {
            var path:String = url.substr(0, url.lastIndexOf("/"));

            return path;
        }

        private function parseM3U8Manifest(M3U8Content:String):void {
            // log.debug("M3U8 Content: " + M3U8Content);
            log.debug("Parsing M3U8 Manifest");
            parser = new HttpStreamingM3U8ManifestParser();

            parser.addEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
            parser.addEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);


            try
            {
                parser.parse(M3U8Content, getRootUrl(_clip.completeUrl), _clip.completeUrl);
            }
            catch (parseError:Error)
            {

                log.error(parseError.errorID + " " + parseError.getStackTrace());
            }
        }

        /**
         * M3u8 parser completed
         * @param event
         */
        protected function onParserLoadComplete(event:ParseEvent):void
        {
            parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
            parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

            manifest = event.data as HttpStreamingM3U8Manifest;
            onM3U8Finished();
        }

        /**
         * M3u8 parser error
         * @param event
         */
        protected function onParserLoadError(event:ParseEvent):void
        {
            parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
            parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);
            log.error("Error parsing manifest");
        }

        /**
         * resolver failure listener
         * @param listener
         */
        public function set onFailure(listener:Function):void {

        }

        public function showError(message:String):void
        {

        }

        /**
         * Handle stream not found errors for missing M3U8 feeds
         * @param error
         * @param info
         * @param throwError
         */
        public function handleError(error:ErrorCode, info:Object = null, throwError:Boolean = true):void
        {
            handleStreamNotFound(error.message);
        }

        /**
         * handles netstatus events
         * @param event
         * @return
         */
        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        protected function onPlayStatus(event:ClipEvent) : void {
            log.debug("onPlayStatus() -- " + event.info.code);
            if (event.info.code == "NetStream.Play.TransitionComplete"){
                dispatchEvent(new ClipEvent(ClipEventType.SWITCH_COMPLETE));
            }
            return;
        }

        /**
         * Setup switch events on the netstream
         * @param event
         */
        override protected function onNetStatus(event:NetStatusEvent) : void {
            log.debug("onNetStatus(), code: " + event.info.code + ", paused? " + paused + ", seeking? " + seeking);
            switch(event.info.code){
                case "NetStream.Play.Transition":
                    log.debug("Stream Transition -- " + event.info.details);
                    dispatchEvent(new ClipEvent(ClipEventType.SWITCH, event.info.details));
                    break;
                case "NetStream.Play.Complete":
                    clip.dispatchBeforeEvent(new ClipEvent(ClipEventType.FINISH));
                break;
                case "NetStream.Play.Stop":
                    _receivedStop = true;
                    _hasNext = _player.playlist.hasNext();
                    break;
                case "NetStream.Buffer.Empty":
                    if ((clip.duration - _player.status.time < 1 && clip.duration > 0) && !_player.playlist.hasNext())
                    {
                        doStop(new ClipEvent(ClipEventType.STOP), netStream);
                    }
                    break;
            }
            return;
        }

        /**
         * @inherit
         * @param event
         * @param netStream
         * @param closeStreamAndConnection
         */
       override protected function doStop(event:ClipEvent, netStream:NetStream, closeStreamAndConnection:Boolean = true):void {
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
           // if (seekTime <= 0) return;

           // if (seekTime == 0) seekTime = -1;


            //#515 when seeking on startup set a delay or else the initial time is treated as the clip start time.
            if (time <= 0 ) {
                setTimeout(function():void {
                    netStream.seek(seconds);
                }, 250);
                return;
            }
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
            //if (!clip) return 0;
            //if (!netStream) return 0;
            return 0;
            //return Math.max(0, getCurrentPlayheadTime(netStream));
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
            if (!clip.getCustomProperty("urlResource")) return super.createNetStream(connection);
            clip.type = ClipType.VIDEO;
            netResource = clip.getCustomProperty("urlResource") as URLResource;
            var httpNetStream:HTTPNetStream = new HTTPNetStream(connection, new HTTPStreamingM3U8Factory(), netResource);
            return httpNetStream;
        }
    }
}
