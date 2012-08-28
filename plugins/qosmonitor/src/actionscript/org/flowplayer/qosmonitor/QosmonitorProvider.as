/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.qosmonitor {

    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.view.StyleableSprite;

    import org.flowplayer.net.BitrateItem;

    import flash.events.TimerEvent;

    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;

    import flash.display.Sprite;

    import flash.utils.Timer;

    import flash.net.NetStream;

    import org.flowplayer.qosmonitor.config.Config;


    public class QosmonitorProvider extends StyleableSprite implements Plugin {
        private var _config:Config;
        private var _model:PluginModel;
        private var _player:Flowplayer;
        private var _statsTimer:Timer;
        private var _netStream:NetStream;
        private var _clip:Clip;

        private var _metrics:Object;
        private var _bwcheck:Object;

        private var _bandwidthLabel:TextField;
        private var _bandwidthStats:TextField;
        private var _bufferLengthLabel:TextField;
        private var _bufferLengthStats:TextField;
        private var _droppedFramesLabel:TextField;
        private var _droppedFramesStats:TextField;
        private var _bitrateItemLabel:TextField;
        private var _bitrateItemStats:TextField;

        private var _avgBandwidthLabel:TextField;
        private var _avgBandwidthStats:TextField;
        private var _avgDroppedFramesLabel:TextField;
        private var _avgDroppedFramesStats:TextField;
        private var _avgFramesLabel:TextField;
        private var _avgFramesStats:TextField;

        private var _statsContainer:Sprite;
        private var _bandwidthContainer:Sprite;
        private var _bufferLengthContainer:Sprite;
        private var _droppedFramesContainer:Sprite;
        private var _bitrateItemContainer:Sprite;

        private var _avgBandwidthContainer:Sprite;
        private var _avgDroppedFramesContainer:Sprite;
        private var _avgFramesContainer:Sprite;

        private const PADDING_X:int = 10;
        private const MARGIN_TOP:int = 10;
        private const PADDING_Y:int = 3;


    
        
        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;

            this.rootStyle = _config.canvas;
        }

        private function applyForClip(clip:Clip):Boolean {
            return "rtmp httpstreaming".indexOf(_player.streamProvider.type) >= 0;
        }
    
        public function onLoad(player:Flowplayer):void {
            _player = player;
            log.info("onLoad()");

            //#500 get the metrics from the bwcheck plugin.
            var plugin:DisplayProperties = _player.pluginRegistry.getPlugin("bwcheck") as DisplayProperties;
            _bwcheck = Object(plugin.getDisplayObject());

            createStatsView();

            _statsTimer = new Timer(_config.interval);
			_statsTimer.addEventListener(TimerEvent.TIMER, updateStats);

            _player.playlist.onSwitch(function(event:ClipEvent):void {
                updateBitrateItemStats();
            });

            _player.playlist.onSwitchFailed(function(event:ClipEvent):void {
                updateBitrateItemStats();
            });

            _player.playlist.onSwitchComplete(function(event:ClipEvent):void {
                updateBitrateItemStats();
            });

            _player.playlist.onStart(function(event:ClipEvent):void {
                _netStream = _player.streamProvider.netStream;
                _clip = _player.playlist.current;
                _statsTimer.start();

                updateBitrateItemStats();
            },applyForClip);

            _player.playlist.onFinish(function(event:ClipEvent):void {
                _statsTimer.stop();
            });

            _player.playlist.onPause(function(event:ClipEvent):void {
                _statsTimer.stop();
            });

            _player.playlist.onResume(function(event:ClipEvent):void {
                _statsTimer.start();
            });

            _model.dispatchOnLoad();
        }

        private function updateStatsText(text:TextField, info:String):void {
            text.htmlText = "<span class=\"stats\">" + info + "</span>";
        }

        private function updateBandwidthStats():void {
            if (!_config.stats.bandwidth) return;
            updateStatsText(_bandwidthStats,
                    formatBytes(_netStream.info.maxBytesPerSecond) +
                            " - " + formatBytes(_netStream.info.playbackBytesPerSecond)
                    );


        }

        private function updateBufferStats():void {
            if (!_config.stats.buffer) return;
            updateStatsText(_bufferLengthStats,Math.round(_netStream.bufferLength) + "");
        }

        private function updateDroppedFramesStats():void {
            if (!_config.stats.frames) return;
            updateStatsText(_droppedFramesStats,
                     _netStream.info.droppedFrames + ""
                    );
        }

        private function updateBitrateItemStats():void {
            if (!_config.stats.bitrate) return;
            if (!_clip.getCustomProperty("streamSelectionManager")) return;
            var bitrateItem:BitrateItem = BitrateItem(_clip.getCustomProperty("streamSelectionManager").currentBitrateItem);
            updateStatsText(_bitrateItemStats,
                    bitrateItem.bitrate + " kbps (" + bitrateItem.index + "," + bitrateItem.width +"px)"
                    );
        }

        private function updateMetrics():void {
            if (!_config.stats.metrics) return;
            //#500 get the metrics from the bwcheck plugin.
            if (!_metrics && !_bwcheck) return;
            if (!_metrics) _metrics = _bwcheck.netStreamMetrics;

            updateStatsText(_avgBandwidthStats, formatBytes(_metrics.averageMaxBytesPerSecond) + "");
            updateStatsText(_avgDroppedFramesStats, Math.round(_metrics.averageDroppedFPS) + "");
            updateStatsText(_avgFramesStats, Math.round(_metrics.droppedFPS) + "");
        }

        private function updateStats(event:TimerEvent):void
        {
            updateBandwidthStats();
            updateBufferStats();
            updateDroppedFramesStats();
            updateMetrics();

            if (_config.info) log.debug("NetStreamInfo - " + _netStream.info);

        }

        private function formatBytes(value:Number):Number {
            return Math.round(value * 8 / 1024);
        }

        protected function createField():TextField {
            var field:TextField = _player.createTextField();
            field.selectable = false;
            field.focusRect = false;
            field.tabEnabled = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.height = 15;
            field.styleSheet = style.styleSheet;
            return field;
        }

        protected function createLabelField(value:String):TextField {
            var field:TextField = createField();
            field.htmlText = "<span class=\"label\">" + value + ":</span>";
            return field;
        }

        protected function createStatsField():TextField {
            var field:TextField = createField();
            return field;
        }



        private function createStatsView():void {
            _statsContainer = new Sprite();
            addChild(_statsContainer);

            //setup netstream stats
            //bandidth stats
            _bandwidthContainer = new Sprite();

            _bandwidthLabel = createLabelField("Bandwidth (kbps)");
            _bandwidthContainer.addChild(_bandwidthLabel);

            _bandwidthStats = createStatsField();
            _bandwidthContainer.addChild(_bandwidthStats);

            _bandwidthStats.x = _bandwidthLabel.textWidth + 5;

            _statsContainer.addChild(_bandwidthContainer);

            //buffer stats
            _bufferLengthContainer = new Sprite();

            _bufferLengthLabel = createLabelField("Buffer Length (seconds)");
            _bufferLengthContainer.addChild(_bufferLengthLabel);

            _bufferLengthStats = createStatsField();
            _bufferLengthContainer.addChild(_bufferLengthStats);

            _bufferLengthStats.x = _bufferLengthLabel.textWidth + 5;

            _statsContainer.addChild(_bufferLengthContainer);

            //dropped frame stats
            _droppedFramesContainer = new Sprite();

            _droppedFramesLabel = createLabelField("Dropped Frames");
            _droppedFramesContainer.addChild(_droppedFramesLabel);

            _droppedFramesStats = createStatsField();
            _droppedFramesContainer.addChild(_droppedFramesStats);

            _droppedFramesStats.x = _droppedFramesLabel.textWidth + 5;

            _statsContainer.addChild(_droppedFramesContainer);


            //bitrate item stats
            _bitrateItemContainer = new Sprite();

            _bitrateItemLabel = createLabelField("Current Bitrate");
            _bitrateItemContainer.addChild(_bitrateItemLabel);

            _bitrateItemStats = createStatsField();
            _bitrateItemContainer.addChild(_bitrateItemStats);

            _bitrateItemStats.x = _bitrateItemLabel.textWidth + 5;

            _statsContainer.addChild(_bitrateItemContainer);

            //setup metrics based stats
            //average bandwidth stats
            _avgBandwidthContainer = new Sprite();

            _avgBandwidthLabel = createLabelField("Avg Bandwidth (kbps)");
            _avgBandwidthContainer.addChild(_avgBandwidthLabel);

            _avgBandwidthStats = createStatsField();
            _avgBandwidthContainer.addChild(_avgBandwidthStats);

            _avgBandwidthStats.x = _avgBandwidthLabel.x + _avgBandwidthLabel.textWidth + 5;


            _statsContainer.addChild(_avgBandwidthContainer);

            //average dropped frames stats
            _avgDroppedFramesContainer = new Sprite();

            _avgDroppedFramesLabel = createLabelField("Avg Dropped Frames");
            _avgDroppedFramesContainer.addChild(_avgDroppedFramesLabel);

            _avgDroppedFramesStats = createStatsField();
            _avgDroppedFramesContainer.addChild(_avgDroppedFramesStats);

            _avgDroppedFramesStats.x = _avgDroppedFramesLabel.x + _avgDroppedFramesLabel.textWidth + 5;

            _statsContainer.addChild(_avgDroppedFramesContainer);

            //metrics calculated frames stats
            _avgFramesContainer = new Sprite();

            _avgFramesLabel = createLabelField("Avg Frames");
            _avgFramesContainer.addChild(_avgFramesLabel);

            _avgFramesStats = createStatsField();
            _avgFramesContainer.addChild(_avgFramesStats);

            _avgFramesStats.x = _avgFramesLabel.x + _avgFramesLabel.textWidth + 5;

            _statsContainer.addChild(_avgFramesContainer);



            arrangeStatsView();


        }

        private function arrangeStatsView():void {

            //setup standard netstream stats
            _bandwidthContainer.x = PADDING_X;
            _bandwidthContainer.y = MARGIN_TOP;

            _bufferLengthContainer.x = PADDING_X;
            _bufferLengthContainer.y = _bandwidthContainer.y + _bandwidthContainer.height + (PADDING_Y * 2);

            _droppedFramesContainer.x = PADDING_X;
            _droppedFramesContainer.y = _bufferLengthContainer.y + _bufferLengthContainer.height + (PADDING_Y * 2);

            _bitrateItemContainer.x = PADDING_X;
            _bitrateItemContainer.y = _droppedFramesContainer.y + _droppedFramesContainer.height + (PADDING_Y * 2);

            //setup metrics stats
            _avgBandwidthContainer.x = this.width / 2;
            _avgBandwidthContainer.y = MARGIN_TOP;

            _avgDroppedFramesContainer.x = this.width / 2;
            _avgDroppedFramesContainer.y = _avgBandwidthContainer.y + _avgBandwidthContainer.height + (PADDING_Y * 2);

            _avgFramesContainer.x = this.width / 2;
            _avgFramesContainer.y = _avgDroppedFramesContainer.y + _avgDroppedFramesContainer.height + (PADDING_Y * 2);
        }

        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            arrangeStatsView();
        }
    
         //implements
        public function getDefaultConfig():Object {
            return {
                top: "0",
                left: "2",

                background: "#000000",
                opacity: 0.8,
                borderRadius: 0,
                border: 'none',
                width: "100%",
                height: "50%"
            };
        }


        
    }
}
