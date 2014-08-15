/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.f4m {

        import flash.events.NetStatusEvent;
        import flash.events.TimerEvent;
        import flash.utils.Timer;

        import org.flowplayer.model.Plugin;
        import org.flowplayer.model.PluginModel;
        import org.flowplayer.model.Clip;
        import org.flowplayer.model.ClipError;
        import org.flowplayer.model.ErrorCode;

        import org.flowplayer.controller.ResourceLoader;
        import org.flowplayer.controller.StreamProvider;
        import org.flowplayer.controller.ClipURLResolver;

        import org.flowplayer.util.PropertyBinder;
        import org.flowplayer.util.Log;
        import org.flowplayer.util.URLUtil;

        import org.flowplayer.view.ErrorHandler;
        import org.flowplayer.view.Flowplayer;


        import org.flowplayer.net.BitrateItem;

        import org.flowplayer.f4m.config.Config;

        import org.osmf.elements.f4mClasses.DRMAdditionalHeader;
        import org.osmf.elements.f4mClasses.Manifest;
        import org.osmf.elements.f4mClasses.ManifestParser;
        import org.osmf.elements.f4mClasses.MultiLevelManifestParser;

        import org.osmf.media.MediaResourceBase;
        import org.osmf.media.URLResource;

        import org.osmf.events.ParseEvent;

        import org.osmf.net.DynamicStreamingResource;
        import org.osmf.net.DynamicStreamingItem;
        import org.osmf.net.StreamingURLResource;
        import org.osmf.net.StreamType;


        public class F4mProvider implements ClipURLResolver, ErrorHandler, Plugin {
            private var _config:Config;
            private var _model:PluginModel;
            private var log:Log = new Log(this);
            private var _failureListener:Function;
            private var _successListener:Function;
            private var _clip:Clip;
            private var _player:Flowplayer;
            private var manifest:Manifest;
            private var parser:ManifestParser;
            private var netResource:MediaResourceBase;
            private var dynResource:DynamicStreamingResource;
            private var streamResource:StreamingURLResource;
            private var _isDynamicStreamResource:Boolean = false;
            private var _retryTimer:Timer;
            private var _retryCount:int;
    

            public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
                _clip = clip;
                _successListener = successListener;
                loadF4M(_clip.completeUrl, onF4MLoaded);
            }

            [External]
            public function resolveF4M(f4mUrl:String):void {
                log.debug("resolveF4M()");
                loadF4M(f4mUrl, onF4MLoaded);
            }

            private function loadF4M(f4mUrl:String, loadedCallback:Function):void {
                if (!_player) return;
                log.debug("connect(), loading F4M file from " + f4mUrl);

                var loader:ResourceLoader = _player.createLoader();
                loader.errorHandler = this;
                loader.load(f4mUrl, function(loader:ResourceLoader):void {
                    log.debug("F4M file received");
                    loadedCallback(String(loader.getContent()));
                }, true);
            }

            public function showError(message:String):void
            {

            }

            /**
             * Handle stream not found errors for missing f4m feeds
             * @param error
             * @param info
             * @param throwError
             */
		    public function handleError(error:ErrorCode, info:Object = null, throwError:Boolean = true):void
            {
                handleStreamNotFound(error.message);
            }

            private function onF4MLoaded(f4mContent:String):void {
                stopF4MReload();
                parseF4MManifest(f4mContent);
            }

            protected function formatStreamItems(streamItems:Vector.<DynamicStreamingItem>):Vector.<DynamicStreamingItem> {
                var bitrateItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

                //if we have custom bitrates property set on the bitrates clip property
                var bitrateOptions:Array = [];
                if (_clip.getCustomProperty("bitrates")) {
                    bitrateOptions = _clip.getCustomProperty("bitrates") as Array;
                    bitrateOptions.sortOn(["bitrate"], Array.NUMERIC);
                }

                for (var index:int = 0; index < dynResource.streamItems.length; index++) {
                    var item:DynamicStreamingItem = streamItems[index];

                    var bitrateItem:BitrateItem = new BitrateItem();
                    bitrateItem.url = item.streamName;
                    bitrateItem.bitrate = item.bitrate;
                    bitrateItem.index = index;

                    if (item.width) {
                        bitrateItem.width = item.width;
                    } else if (manifest.media[index].metadata && manifest.media[index].metadata.width) {
                        bitrateItem.width = manifest.media[index].metadata.width;
                    }

                    if (item.height) {
                        bitrateItem.height = item.height;
                    } else if (manifest.media[index].metadata && manifest.media[index].metadata.height) {
                        bitrateItem.height = manifest.media[index].metadata.height;
                    }

                    bitrateItem.index = index;

                    //if we have custom bitrates property set on the bitrates clip property
                    //set the custom bitrate label, sd, hd properties
                    if (bitrateOptions[index] && bitrateOptions)  {
                        var itemConfig:Object = bitrateOptions[index];
                        if (itemConfig.hasOwnProperty("label")) bitrateItem.label = itemConfig.label;
                        if (itemConfig.hasOwnProperty("sd")) bitrateItem.sd = itemConfig.sd;
                        if (itemConfig.hasOwnProperty("hd")) bitrateItem.hd = itemConfig.hd;
                        if (itemConfig.hasOwnProperty("isDefault")) bitrateItem.isDefault = itemConfig.isDefault as Boolean;
                    }

                    bitrateItems.push(bitrateItem);
                }
                return bitrateItems;
            }

            private function setClipTypeAndBuffer():void
            {
                if (_isDynamicStreamResource) {
                    switch (manifest.streamType) {
                        case StreamType.DVR:
                            _clip.live = true;
                            _clip.stopLiveOnPause = false;
                            _clip.bufferLength = _config.dvrDynamicBufferTime;
                            break;
                        case StreamType.LIVE:
                            _clip.live = true;
                            _clip.bufferLength = _config.liveDynamicBufferTime;
                            break;
                        default:
                            _clip.bufferLength = _config.dynamicBufferTime;
                            break;
                    }
                } else {
                    switch (manifest.streamType) {
                        case StreamType.DVR:
                            _clip.live = true;
                            _clip.stopLiveOnPause = false;
                            _clip.bufferLength = _config.dvrBufferTime;
                        break;
                        case StreamType.LIVE:
                            _clip.live = true;
                            _clip.bufferLength = _config.liveBufferTime;
                        break;
                    }
                }
            }

            private function onF4MFinished():void
            {
                log.debug("F4M Manifest Finished");


                    //#493 add option to include application instance for rtmp base urls.
                    if (!manifest.urlIncludesFMSApplicationInstance && manifest.baseURL)
                        manifest.urlIncludesFMSApplicationInstance = _config.includeApplicationInstance;

                    try
                    {
                        netResource = parser.createResource(manifest, new URLResource(_clip.completeUrl));
                    }
                    catch (error:Error)
                    {
                        handleStreamNotFound(error.message);
                        return;
                    }

                    if (netResource is DynamicStreamingResource) {
                        dynResource = netResource as DynamicStreamingResource;
                        //formats the stream items to be ready for the bwcheck plugin
                        dynResource.streamItems = formatStreamItems(dynResource.streamItems);
                        _isDynamicStreamResource = true;
                        _clip.setCustomProperty("bitrateItems", dynResource.streamItems);
                        _clip.setCustomProperty("urlResource", dynResource);

                    } else {
                        streamResource = netResource as StreamingURLResource;

                        log.debug("Manifest parsed with a single stream " + manifest.media[0].url);
                        _clip.setResolvedUrl(this, streamResource.url);
                        _clip.setCustomProperty("urlResource", streamResource);
                    }


                    if (manifest.baseURL && URLUtil.isRtmpUrl(manifest.baseURL)) {
                        _clip.setCustomProperty("netConnectionUrl", manifest.baseURL);
                    }

                    //set the clip buffer and live clip property
                    setClipTypeAndBuffer();

                    _clip.setCustomProperty("manifestInfo",manifest);


                    if (_successListener != null) {
                       _successListener(_clip);
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
                    retryF4mLoad();
                    return;
                }

                _clip.dispatchError(ClipError.STREAM_NOT_FOUND, message);
            }

            /**
             * Stop the connection reattempts
             */
            private function stopF4MReload():void
            {
                if (_retryTimer) {
                    _retryTimer.stop();
                    _retryTimer.removeEventListener(TimerEvent.TIMER, onF4MLoadRetry);
                    _retryTimer.reset();
                    _retryTimer = null;
                    _retryCount = 0;
                }
            }

            /**
             * Attempt to reconnect or stop if the retry count has reached it's limit.
             */
            private function retryF4mLoad():void
            {
                if (!_retryTimer) {
                    _retryTimer = new Timer(_config.retryInterval);
                    _retryTimer.addEventListener(TimerEvent.TIMER, onF4MLoadRetry);
                    _retryTimer.start();
                    log.error("Reattempting to load media from F4m manifest " + _clip.completeUrl);
                }

                _retryCount++;

                if (_retryCount > _config.maxRetries) {
                    stopF4MReload();
                }
            }

            /**
             * Reload the f4m feed after a set interval.
             * @param event
             */
            private function onF4MLoadRetry(event:TimerEvent):void
            {
                log.error("Reattempting to load media from F4m manifest " + _clip.completeUrl);
                loadF4M(_clip.completeUrl, onF4MLoaded);
            }

            private function getRootUrl(url:String):String
            {
                var path:String = url.substr(0, url.lastIndexOf("/"));

                return path;
            }

            private function parseF4MManifest(f4mContent:String):void {
               // log.debug("F4M Content: " + f4mContent);
                log.debug("Parsing F4M Manifest");
                parser = getParser();

                parser.addEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
				parser.addEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);


                try
                {
                    //#489 create base url from the clip complete url, issue causing multiple forward slashes.
                    parser.parse(f4mContent, _clip.baseUrl ? URLUtil.baseUrl(_clip.completeUrl) : "");
                }
                catch (parseError:Error)
                {

                    log.error(parseError.errorID + " " + parseError.getStackTrace());
                }
            }

            private function onParserLoadComplete(event:ParseEvent):void
            {
                parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
                parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

                manifest = event.data as Manifest;
                onF4MFinished();
            }

            private function onParserLoadError(event:ParseEvent):void
            {
                parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
                parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);
                log.error("Error parsing manifest");
            }

            private function getParser():ManifestParser
            {
                if (_config.version == 2)
                {
                    return new MultiLevelManifestParser();
                }

                return new ManifestParser();
            }

            public function set onFailure(listener:Function):void {
                _failureListener = listener;
            }

            public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
                return true;
            }

            public function onConfig(model:PluginModel):void {
                _model = model;
                _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
            }

            public function onLoad(player:Flowplayer):void {
                log.info("onLoad()");
                _player = player;
                _model.dispatchOnLoad();
            }

            public function getDefaultConfig():Object {
                return null;
            }

    }
}
