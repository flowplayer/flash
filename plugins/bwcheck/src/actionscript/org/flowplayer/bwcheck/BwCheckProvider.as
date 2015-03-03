/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck {
    import de.betriebsraum.video.BufferCalculator;

    import flash.display.DisplayObject;
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;


    import org.flowplayer.bwcheck.net.OsmfLoggerFactory;
    import org.flowplayer.bwcheck.net.OsmfNetStreamClient;
    import org.flowplayer.net.BitrateItem;
    import org.flowplayer.net.IStreamSelectionManager;
    import org.flowplayer.net.StreamSwitchManager;
    import org.flowplayer.net.BitrateResource;

    import org.flowplayer.bwcheck.config.Config;
    import org.flowplayer.bwcheck.detect.BandwidthDetectEvent;
    import org.flowplayer.bwcheck.detect.BandwidthDetector;
    import org.flowplayer.bwcheck.net.ScreenSizeRule;
    import org.flowplayer.bwcheck.net.BWStreamSelectionManager;


    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.NetStreamClient;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;


    import org.osmf.net.DynamicStreamingItem;
    import org.osmf.net.DynamicStreamingResource;

    import org.osmf.net.NetStreamMetricsBase;



    CONFIG::LOGGING
    {
        import org.osmf.logging.Log;
    }

    CONFIG::enableRtmpMetrics {
        import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
        import org.osmf.net.rtmpstreaming.DroppedFramesRule;
        import org.osmf.net.rtmpstreaming.InsufficientBandwidthRule;
        import org.osmf.net.rtmpstreaming.InsufficientBufferRule;
        import org.osmf.net.rtmpstreaming.SufficientBandwidthRule;
        import org.osmf.net.NetStreamSwitchManagerBase;
        import org.osmf.net.SwitchingRuleBase;
        import org.osmf.net.NetStreamSwitchManager;
    }

    CONFIG::enableHttpMetrics {
        import org.osmf.net.metrics.MetricFactory;
        import org.osmf.net.metrics.MetricRepository;
        import org.osmf.net.metrics.DefaultMetricFactory;
        import org.osmf.net.qos.QoSInfoHistory;
        import org.osmf.net.rules.AfterUpSwitchBufferBandwidthRule;
        import org.osmf.net.rules.BufferBandwidthRule;
        import org.osmf.net.rules.DroppedFPSRule;
        import org.osmf.net.rules.EmptyBufferRule;
        import org.osmf.net.NetStreamSwitcher;
        import org.osmf.net.rules.RuleBase;
        import org.osmf.net.httpstreaming.DefaultHTTPStreamingSwitchManager;
        import org.osmf.net.NetStreamSwitchManagerBase;
    }


    public class BwCheckProvider extends AbstractSprite implements ClipURLResolver, Plugin {

        protected var _config:Config;
        protected var _netStream:NetStream;
        protected var _resolveSuccessListener:Function;
        protected var _failureListener:Function;
        protected var _clip:Clip;
        protected var _hasDetectedBW:Boolean = false;
        protected var _model:PluginModel;
        protected var _player:Flowplayer;
        protected var _resolving:Boolean;
        protected var _playButton:DisplayObject;
        protected var _provider:StreamProvider;
        protected var _bitrateStorage:BitrateStorage;
        protected var _detector:BandwidthDetector;

        protected var _switchManager:NetStreamSwitchManagerBase;
        protected var _netStreamMetrics:NetStreamMetricsBase;
        protected var dsResource:DynamicStreamingResource;

        protected var _streamSelectionManager:IStreamSelectionManager;
        protected var _streamSwitchManager:StreamSwitchManager;

        CONFIG::enableHttpMetrics {
            protected var BANDWIDTH_BUFFER_RULE_WEIGHTS:Vector.<Number> = new <Number>[7, 3];
            protected var BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD:uint = 2;
            protected var MAXIMUM_DROPPED_FPS_RATIO:Number = 0.1;
            protected var FPS_DESIRED_SAMPLE_LENGTH_IN_SECOND:int = 10;
            protected var AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD:uint = 2;
            protected var AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_MIN_RATIO:Number = 0.5;
            //protected var EMPTY_BUFFER_RULE_SCALE_DOWN_FACTOR:Number = 0.4;
            protected var QOS_MAX_HISTORY_LENGTH:Number = 10;
        }


        public function onConfig(model:PluginModel):void {
            log.debug("onConfig(_)");

            CONFIG::LOGGING
            {
            Log.loggerFactory = new OsmfLoggerFactory();
            }

            _config = new PropertyBinder(new Config()).copyProperties(model.config) as Config;

            _model = model;
            _bitrateStorage = new BitrateStorage(_config.bitrateProfileName, "/");
            _bitrateStorage.expiry = _config.cacheExpiry;

            log.debug("onConfig(), dynamic " + _config.dynamic);
        }

        protected function applyForClip(clip:Clip):Boolean {
            var bw:Object = clip.getCustomProperty("bwcheck");
            log.debug("applyForClip() ? " + bw);
            if (bw is Boolean && ! bw) return false;
            return true;
        }

        protected function canSwitchOnFullscreen():Boolean {
            //disabling fullscreen switching on dynamic for now  #336
            return _config.switchOnFullscreen && _player.playlist.current.provider != "http" && !_config.dynamic;
        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            _player = player;

            _detector = new BandwidthDetector(_model, _config, _player.playlist);
            _detector.addEventListener(BandwidthDetectEvent.DETECT_COMPLETE, onDetectorComplete);
            _detector.addEventListener(BandwidthDetectEvent.CLUSTER_FAILED, onClusterFailed);

            if (canSwitchOnFullscreen()) {
                _player.onFullscreen(onFullscreen);
                _player.onFullscreenExit(onFullscreen);
            }

            _player.playlist.onSwitch(function(event:ClipEvent):void {
                //fixes for #336 provide correction bitrateitem information when using dynamic stream switching
                //fixes for #352 for wowza streams with secure names that return the real name from the server, return the item from the metrics index instead.
                var newItem:DynamicStreamingItem = _streamSelectionManager.fromName(String(event.info));
                log.info("new item is " + newItem + ", (" + event.info + "), current " + _streamSelectionManager.currentBitrateItem);
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchBegin", newItem, _streamSelectionManager.currentBitrateItem);
            });

            _player.playlist.onSwitchFailed(function(event:ClipEvent):void {
                log.info("Transition failed with error " + event.info2.toString());
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitchFailed", "Transition failed with error " + event.info2.toString());
            });

            _player.playlist.onSwitchComplete(function(event:ClipEvent):void {
                log.info("Stream switch completed with item " + _streamSelectionManager.currentBitrateItem);
                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitch", _streamSelectionManager.currentBitrateItem);
            });


            _player.playlist.onStart(function(event:ClipEvent):void {
                log.debug("onStart() clip == " + clip);
                var clip:Clip = event.target as Clip;

                if (alreadyResolved(clip)) {

                    init(clip.getNetStream(), clip);

                    //only setup dynamic stream switching in these conditions
                    if (_config.dynamic && _streamSelectionManager is BWStreamSelectionManager) {
                        initQoS(clip.getNetStream(), clip);
                    }
                }
            }, applyForClip);

            var autoSwitch:Function = function(enable:Boolean):Function {
                return function(event:ClipEvent):void {
                    if (! _switchManager) return;
                    var newVal:Boolean = _config.dynamic && enable;
                    log.info("setting QOS state to " + newVal);
                    _switchManager.autoSwitch = newVal;

                }
            };

            _player.playlist.onPause(autoSwitch(false), applyForClip);
            _player.playlist.onStop(autoSwitch(false), applyForClip);
            _player.playlist.onStart(autoSwitch(true), applyForClip);
            _player.playlist.onResume(autoSwitch(true)),applyForClip;
            _player.playlist.onFinish(autoSwitch(false), applyForClip);


            _model.dispatchOnLoad();
        }

        protected function onFullscreen(event:PlayerEvent):void {
            log.debug("onFullscreen(), checking bandwidth and switching stream");
            checkBandwidthIfNotDetectedYet();
        }

        protected function alreadyResolved(clip:Clip):Boolean {
            return clip.getCustomProperty("bwcheckResolvedUrl") != null;
        }

        protected function hasDetectedBW():Boolean {
            if (! _config.rememberBitrate) return false;
            if (_hasDetectedBW) return true;
            if (isRememberedBitrateValid()) return true;
            return false;
        }

        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

        protected function detect():void {
            log.debug("connectServer()");
            _detector.detect();
        }

        protected function onClusterFailed(event:BandwidthDetectEvent):void {
            log.error("onClusterFailed(), will use default bitrate");
            useDefaultBitrate();
        }

        protected function onDetectorComplete(event:BandwidthDetectEvent):void {
            log.debug("onDetectorComplete()");
            event.stopPropagation();
            log.info("\n\n kbit Down: " + event.info.kbitDown + " Delta Down: " + event.info.deltaDown + " Delta Time: " + event.info.deltaTime + " Latency: " + event.info.latency);
            _hasDetectedBW = true;

            // Set the detected bandwidth
            var bandwidth:Number = event.info.kbitDown;
            var mappedBitrate:BitrateItem = getMappedBitrate(bandwidth);
            log.debug("bandwidth (kbitDown) " + bandwidth);
            log.info("mapped to bitrate " + mappedBitrate.bitrate);
            rememberBandwidth(bandwidth);

            selectBitrate(mappedBitrate, bandwidth);
        }

        protected function getMappedBitrate(bandwidth:Number = -1):BitrateItem {
            return _streamSelectionManager.getStream(bandwidth) as BitrateItem;
        }

        protected function dynamicBuffering(mappedBitrate:Number, detectedBitrate:Number):void {
            if (_config.dynamicBuffer) {
                _clip.onMetaData(function(event:ClipEvent):void {
                    _clip.bufferLength = BufferCalculator.calculate(_clip.metaData.duration, mappedBitrate, detectedBitrate);
                    log.info("Dynamically setting buffer time to " + _clip.bufferLength + "s");
                });

            }
        }

        protected function selectBitrate(mappedBitrate:BitrateItem, detectedBitrate:Number = -1):void {
            log.debug("selectBitrate()");

            dynamicBuffering(mappedBitrate.bitrate, detectedBitrate);

            if (_playButton && _playButton.hasOwnProperty("stopBuffering")) {
                _playButton["stopBuffering"]();
            }

            //move this event up to give it time before onStreamSwitchBegin is called.
            log.info("dispatching onBwDone, mapped bitrate: " + mappedBitrate.bitrate + " detected bitrate " + detectedBitrate + " url: " + mappedBitrate.streamName);
            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onBwDone", mappedBitrate, detectedBitrate);


            if (_resolving) {
                _streamSelectionManager.changeStreamNames(mappedBitrate);
                _resolveSuccessListener(_clip);
                _resolving = false;
            } else if (_netStream && (_player.isPlaying() || _player.isPaused())) {
                switchStream(mappedBitrate);
            } else {
                _streamSelectionManager.changeStreamNames(mappedBitrate);
            }


        }

        protected function switchStream(mappedBitrate:BitrateItem):void {
            _streamSwitchManager.switchStream(mappedBitrate);
        }

        [External]
        public function get bitrateItems():Vector.<DynamicStreamingItem> {
            return Vector.<DynamicStreamingItem>(_streamSelectionManager.bitrates);
        }

        /**
         * Store the detection and chosen bitrate if the rememberBitrate config property is set.
         */
        protected function rememberBandwidth(bw:int):void {
            if (_config.rememberBitrate) {
                _bitrateStorage.bandwidth = bw;
                log.debug("stored bandwidth " + bw);
            }

        }


        protected function isRememberedBitrateValid():Boolean {
            log.debug("isRememberedBitrateValid()");

            if (! _bitrateStorage.bandwidth) {
                log.debug("bandwidth not in SO");
                return false;
            }

            var expired:Boolean = _bitrateStorage.isExpired;
            log.info("is remembered bitrate expired?: " + expired + (expired ? ", age is " + _bitrateStorage.age : ""));

            return ! expired;
        }

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            log.debug("resolve " + clip);

            if (!clip.getCustomProperty("bitrates") && !clip.getCustomProperty("bitrateItems")) {
                log.info("Bitrates configuration not enabled for this clip");
                successListener(clip);
                return;
            }

            if (alreadyResolved(clip)) {
                log.info("resolve(): bandwidth already resolved for clip " + clip + ", will not detect again");
                successListener(clip);
                return;
            }

            _provider = provider;
            _resolving = true;
            _resolveSuccessListener = successListener;

            init(provider.netStream, clip);
            checkBandwidthIfNotDetectedYet();
        }


        protected function useDefaultBitrate():void {
            selectBitrate(getMappedBitrate(), -1);
        }

        protected function useStoredBitrate():void {
            var mappedBitrate:BitrateItem = getMappedBitrate(_bitrateStorage.bandwidth);
            log.info("using remembered bandwidth " + _bitrateStorage.bandwidth + ", maps to bitrate " + mappedBitrate.bitrate);
            selectBitrate(mappedBitrate, _bitrateStorage.bandwidth);
        }

        protected function checkBandwidthIfNotDetectedYet():void {
            if (! applyForClip(_player.playlist.current)) return;
            if (hasDetectedBW()) {
                useStoredBitrate();
            } else if (_config.checkOnStart) {
                log.info("not using remembered bandwidth, detecting now");
                detect();
            } else {
                log.info("using dynamic switching with default bitrate ");
                useDefaultBitrate();
            }
        }

        protected function init(netStream:NetStream, clip:Clip):void {
            log.debug("init(), netStream == " + netStream + ", clip == " + clip);
            _netStream = netStream;
            _clip = clip;

            if (!_clip.getCustomProperty("streamSelectionManager")) {
                _streamSelectionManager = new BWStreamSelectionManager(new BitrateResource(), _player, this, _config);
                _clip.setCustomProperty("streamSelectionManager",_streamSelectionManager);
            } else {
                _streamSelectionManager = _clip.getCustomProperty("streamSelectionManager") as IStreamSelectionManager;
            }

            initSwitchManager();
        }


        protected function initSwitchManager():void {
            _streamSwitchManager = new StreamSwitchManager(_netStream, _streamSelectionManager, _player);
        }

        protected function initQoS(netStream:NetStream, clip:Clip):void {
            log.info("initQoS(), netStream == " + netStream + ", host == " + _detector.host);

            import org.osmf.net.StreamType;

            //save the streaming resource and load for each clip in the playlist
            if (clip.getCustomProperty("urlResource")) {
                dsResource = clip.getCustomProperty("urlResource") as DynamicStreamingResource;
                dsResource.initialIndex = _streamSelectionManager.currentIndex;
            } else {
                dsResource = new DynamicStreamingResource(_detector.host);

                dsResource.streamItems = bitrateItems;
                dsResource.initialIndex = _streamSelectionManager.currentIndex;
                dsResource.streamType = _config.live ? StreamType.LIVE : StreamType.RECORDED;

                //#369 set clip start time for adding to play2 arguments.
                //#547 don't set the start property unless set, causes problems for live streams.
                if (clip.start) dsResource.clipStartTime = clip.start;
                clip.setCustomProperty("urlResource", dsResource);
            }
            //#500 setup osmf netclient when configuring metrics.
            if (netStream && ! (netStream.client is OsmfNetStreamClient)) {
                var netStreamClient:OsmfNetStreamClient = new OsmfNetStreamClient(NetStreamClient(netStream.client));
                netStream.client = netStreamClient;
            }

            setupMetrics(netStream);
        }

        protected function setupMetrics(netStream:NetStream):void {
            CONFIG::enableRtmpMetrics {
                //#500 fix for netstream metrics, do not set to the clip properties as it causes errors with event callbacks.
                setupRtmpMetrics(netStream);
            }

            CONFIG::enableHttpMetrics {
                setupHttpStreamingMetrics(netStream);
            }

            if (_streamSelectionManager is BWStreamSelectionManager) BWStreamSelectionManager(_streamSelectionManager).qosSwitchManager = _switchManager;
        }

        /**
         * rtmp streaming metrics
         */
        CONFIG::enableRtmpMetrics {
            protected function setupRtmpMetrics(netStream:NetStream):void
            {
                if (_provider.type == "rtmp") {
                    _netStreamMetrics = new RTMPNetStreamMetrics(netStream);
                    _netStreamMetrics.resource = dsResource;
                    _switchManager = new NetStreamSwitchManager(_provider.netConnection, netStream, dsResource, _netStreamMetrics, getRTMPSwitchingRules(_netStreamMetrics as RTMPNetStreamMetrics));

                    //set the clear failed count interval to the clip duration in milliseconds times a prescision value
                    NetStreamSwitchManager(_switchManager).clearFailedCountInterval = _config.qos.clearFailedCountInterval * (Math.round(_player.playlist.current.duration) * 1000);
                    NetStreamSwitchManager(_switchManager).maxUpSwitchesPerStream = _config.qos.maxUpSwitchesPerStream;
                    NetStreamSwitchManager(_switchManager).ruleCheckInterval = _config.qos.ruleCheckInterval;
                    NetStreamSwitchManager(_switchManager).waitDurationAfterDownSwitch = _config.qos.waitDurationAfterDownSwitch;

                    log.debug("using switch manager " + _switchManager);
                    _netStreamMetrics.startMeasurements();

                }
            }

            protected function getRTMPSwitchingRules(metrics:RTMPNetStreamMetrics):Vector.<SwitchingRuleBase> {
                var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
                addRule("bwUp", rules, new SufficientBandwidthRule(metrics, _config.qos.bitrateSafety, _config.qos.minDroppedFrames));
                addRule("bwDown", rules, new InsufficientBandwidthRule(metrics, _config.qos.bitrateSafety));
                addRule("frames", rules, new DroppedFramesRule(metrics, _config.qos.framesToOne, _config.qos.framesToTwo, _config.qos.framesToLow));
                addRule("buffer", rules, new InsufficientBufferRule(metrics, _config.qos.minBufferLength));
                addRule("screen", rules, new ScreenSizeRule(metrics, _streamSelectionManager, _player, _config));
                return rules;
            }

            protected function addRule(prop:String, rules:Vector.<SwitchingRuleBase>, rule:SwitchingRuleBase):void {
                if (_config.qos[prop]) {
                    log.info("using QoS switching rules " + rule);
                    rules.push(rule);
                }
            }
        }

        /**
         * http streaming metrics
         */
        CONFIG::enableHttpMetrics {
            protected function setupHttpStreamingMetrics(netStream:NetStream):void
            {
                if (_provider.type == "httpstreaming") {
                    //#70 refactored changes to dynamic stream switching support for httpstreaming with OSMF 2.0
                    //the switching apis and metrics are different between rtmp and httpstreaming therefore requires different setups.
                    //#70 change httpstreaming metrics to overridable methods.

                    /*
                     AdobePatentID="2278US01"
                     */

                    // Create a QoSInfoHistory, to hold a history of QoSInfo provided by the NetStream
                    var netStreamQoSInfoHistory:QoSInfoHistory = createQosInfoHistory(netStream);

                    // Create a MetricFactory, to be used by the metric repository for instantiating metrics
                    var metricFactory:MetricFactory = createMetricFactory(netStreamQoSInfoHistory);

                    // Create the MetricRepository, which caches metrics
                    var metricRepository:MetricRepository = createMetricRepository(metricFactory);

                    // Create the normal rule
                    var normalRules:Vector.<RuleBase> = createNormalRules(metricRepository);
                    var normalRuleWeights:Vector.<Number> = new Vector.<Number>();
                    normalRuleWeights.push(1);

                    // Create the emergency rules
                    var emergencyRules:Vector.<RuleBase> = createEmergencyRules(metricRepository);

                    // Create a NetStreamSwitcher, which will handle the low-level details of NetStream
                    // stream switching
                    var nsSwitcher:NetStreamSwitcher = createNetStreamSwitcher(netStream);

                    // Finally, return an instance of the DefaultSwitchManager, passing it
                    // the objects we instatiated above
                    _switchManager = new DefaultHTTPStreamingSwitchManager
                            ( netStream
                                    , nsSwitcher
                                    , metricRepository
                                    , emergencyRules
                                    , true
                                    , normalRules
                                    , normalRuleWeights
                            );
                }
            }

            //#70 changes to httpstreaming metrics rules
            protected function addHttpRule(prop:String, rules:Vector.<RuleBase>, rule:RuleBase):void {
                if (_config.qos[prop]) {
                    log.info("using QoS switching rules " + rule);
                    rules.push(rule);
                }
            }

            protected function createQosInfoHistory(netStream:NetStream):QoSInfoHistory
            {
                return new QoSInfoHistory(netStream, QOS_MAX_HISTORY_LENGTH);
            }

            protected function createMetricFactory(qosInfoHistory:QoSInfoHistory):MetricFactory
            {
                return new DefaultMetricFactory(qosInfoHistory);
            }

            protected function createMetricRepository(metricFactory:MetricFactory):MetricRepository
            {
                return new MetricRepository(metricFactory);
            }

            protected function createNormalRules(metricRepository:MetricRepository):Vector.<RuleBase>
            {
                var normalRules:Vector.<RuleBase> = new Vector.<RuleBase>();

                addHttpRule("bwUp", normalRules, new BufferBandwidthRule(
                        metricRepository,
                        BANDWIDTH_BUFFER_RULE_WEIGHTS,
                        BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD));

                return normalRules;
            }

            protected function createEmergencyRules(metricRepository:MetricRepository):Vector.<RuleBase>
            {
                var emergencyRules:Vector.<RuleBase> = new Vector.<RuleBase>();

                addHttpRule("frames", emergencyRules, new DroppedFPSRule(metricRepository, FPS_DESIRED_SAMPLE_LENGTH_IN_SECOND, MAXIMUM_DROPPED_FPS_RATIO));

                //#127 set a configurable scale down factor for the empty buffer rule, default was 0.4 set it to 0.6 to recommend a higher rate to switch back up to.
                addHttpRule("buffer", emergencyRules, new EmptyBufferRule(
                        metricRepository,
                        _config.qos.bufferScaleDownFactor));

                addHttpRule("bwDown", emergencyRules, new AfterUpSwitchBufferBandwidthRule( metricRepository
                        , AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_BUFFER_FRAGMENTS_THRESHOLD
                        , AFTER_UP_SWITCH_BANDWIDTH_BUFFER_RULE_MIN_RATIO));
                return emergencyRules;
            }

            protected function createNetStreamSwitcher(netStream:NetStream):NetStreamSwitcher
            {
                return new NetStreamSwitcher(netStream, dsResource);
            }
        }

        [External]
        public function currentItem():BitrateItem {
            log.info("currentItem(), _switchManager.currentIndex: " + (_switchManager ? _switchManager.currentIndex : "no switch manager") + ", streamSelectionManager.currentIndex: " + _streamSelectionManager.currentIndex );
            return BitrateItem(_streamSelectionManager.streamItems[_switchManager ? _switchManager.currentIndex : _streamSelectionManager.currentIndex]);
        }

        protected function getClipUrl(clip:Clip, mappedBitrate:BitrateItem):String {
            log.info("Resolved stream url: " + mappedBitrate.url);
            return mappedBitrate.url;
        }

        protected function checkCurrentClip():Boolean {
            var clip:Clip = _player.playlist.current;
            if (_clip == clip) return true;

            if (clip.urlResolvers && clip.urlResolvers.indexOf(_model.name) < 0) {
                return false;
            }
            _clip = clip;
            return true;
        }

        [External]
        public function checkBandwidth():void {
            log.debug("checkBandwidth");
            if (! checkCurrentClip()) return;
            _hasDetectedBW = false;
            _bitrateStorage.clear();
            detect();
        }

        [External]
        public function setBitrate(bitrate:Number):void {
            log.debug("set bitrate()");
            if (! checkCurrentClip()) return;

            try {
                if (_player.isPlaying() || _player.isPaused()) {

                    switchStream(getMappedBitrate(bitrate));
                    _config.dynamic = false;
                    if (_switchManager) {
                        _switchManager.autoSwitch = false;
                    }
                }
            } catch (e:Error) {
                log.error("error when switching streams " + e);
            }
        }

        [External]
        public function enableDynamic(enabled:Boolean):void {
            log.debug("set dynamic(), currently " + _config.dynamic + ", new value " + enabled);
            if (_config.dynamic == enabled) return;
            _config.dynamic = enabled;

            if (enabled) {
                if (! _switchManager) {
                    var clip:Clip = _player.playlist.current;
                    initQoS(clip.getNetStream(), clip);
                }
                _switchManager.autoSwitch = true;
            } else {
                if (_switchManager) {
                    _switchManager.autoSwitch = false;
                }
            }
        }

        [External]
        public function get labels():Object {
            var labels:Object = {};
            for (var i:int = 0; i < bitrateItems.length; i++) {
                var item:BitrateItem = bitrateItems[i] as BitrateItem;
                if (item.label) {
                    labels[item.bitrate] = item.label;
                }
            }
            return labels;
        }

        /**
         * Gets the current bitrate. The returned value is the bitrate in use after the latest bitrate transition has been completed. If
         * a transition is in progress the value reflects the bitrate right now being used, not the one we are changing to.
         * @return
         */
        [External]
        public function get bitrate():Number {

            log.debug("get bitrate()");
            if (! checkCurrentClip()) return undefined;

            if (_config.rememberBitrate && _bitrateStorage.bandwidth >= 0) {
                log.debug("get bitrate(), returning remembered bandwidth");
                var mappedBitrate:BitrateItem = getMappedBitrate(_bitrateStorage.bandwidth);
                return mappedBitrate.bitrate;
            }

            log.debug("get bitrate(), returning current bitrate");
            return currentItem().bitrate;
        }

        /**
         * Get the netstream metrics for external measurement monitoring.
         */
        [External]
        public function get netStreamMetrics():NetStreamMetricsBase
        {
            return _netStreamMetrics;
        }

        public function getDefaultConfig():Object {
            return {
                top: "45%",
                left: "50%",
                opacity: 1,
                borderRadius: 15,
                border: 'none',
                width: "80%",
                height: "80%"
            };
        }
    }
}
