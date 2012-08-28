/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.audiovisual {
    import com.anttikupila.revolt.Revolt;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import org.flowplayer.config.Config;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.DisplayProperties;
    import org.flowplayer.model.DisplayPropertiesImpl;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;

    public class AudioVisual extends AbstractSprite implements Plugin {
        private var _visual:Revolt;
        private var _model:DisplayPluginModel;
        private var _player:Flowplayer;

        public function AudioVisual() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        /**
         * Starts visualization.
         */
        [External]
        public function start():void {
            _visual.start();
        }

        /**
         * Stops visualization
         * @return
         */
        [External]
        public function stop():void {
            _visual.stop();
        }

        /**
         * Swithches to the specified effect.
         * @param num
         * @return
         */
        [External]
        public function set effect(num:int):void {
            _visual.effect = num;
        }

        /**
         * Sets the effects. To select effects 2 and 4 set this property to <code>[2, 4]</code>
         * @param val an array specifying effect numbers to use. There are 6 effects numbered from zero to five.
         * @return
         */
        [External]
        public function set effects(val:Array):void {
            _visual.effects = val;
        }

        /**
         * Picks next random effect
         * @return
         */
        [External]
        public function nextEffect():void {
            _visual.nextEffect();
        }

        private function onAddedToStage(event:Event):void {
            createVisual();
            stage.addEventListener(Event.FULLSCREEN, onFullscreen);
        }

        private function createVisual():void {
            log.debug("createVisual()");
            _visual = new Revolt(stage.stageWidth, stage.stageHeight);
            addChild(_visual);
            _visual.addEventListener(MouseEvent.CLICK, onClick);
        }

        private function onFullscreen(event:Event):void {
            show();
        }

        private function onClick(event:MouseEvent):void {
            if (! _player) return;
            _player.toggle();
        }

        public function onConfig(model:PluginModel):void {
            _model = model as DisplayPluginModel;
        }


        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            _player = player;
            player.playlist.onBegin(show);
            player.playlist.onResume(show);
            player.playlist.onFinish(hide);
            player.playlist.onStop(hide);
            player.playlist.onPause(hide);
            _model.dispatchOnLoad();
        }


        private function show(event:ClipEvent = null):void {
            log.debug("show(), following screen " + followScreen);
            if (followScreen) {
                //                var props:Object = { left: _screen.position.left.asObject(), top: _screen.position.top.asObject(), width: _screen.dimensions.width.asObject(), height: _screen.dimensions.height.asObject() };
                var props:DisplayProperties = _player.screen.clone() as DisplayProperties;
                log.debug("animating to screen pos", props);
                props.zIndex = 1;
                props.opacity = 1;
                _player.animationEngine.animate(this, props);
            } else {
                log.debug("not following screen");
                _player.animationEngine.fadeIn(this);
            }
        }

        private function get followScreen():Boolean {
            return _model.config["followScreen"];
        }

        private function hide(event:ClipEvent):void {
            _player.animationEngine.fadeOut(this, 2000);
        }

        public function getDefaultConfig():Object {
            return { left: '50%', top: '50%', width: '100%', height: '100%', zIndex: 1, opacity: 0, followScreen: true };
        }

        override protected function onResize():void {
            _visual.width = width;
            _visual.height = height;
            _visual.x = 0;
            _visual.y = 0;
        }
    }
}