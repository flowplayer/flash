/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2010 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer {
    import flash.display.Sprite;

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipType;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginEvent;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.view.Flowplayer;

    public class EventListeningPlugin extends Sprite implements Plugin {

        /*
         * Create a logger instance. To see the logs for this class add following to the player configuration:
         * log: { level: 'debug', filter: 'org.flowplayer.EventListeningPlugin' }
         * The logs will show up in the Firebug console (or in the Safari/webkit consoles)
         */
        private var log:Log = new Log(this);

        private var _player:Flowplayer;
        private var _model:PluginModel;

        public function onConfig(model:PluginModel):void {
            _model = model;
        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad()");
            _player = player;

            // listen to clip start
            player.playlist.onStart(onClipStart);

            // listen to onFinsish events for Image clips
            player.playlist.onFinish(onImageClipFinished, function(clip:Clip):Boolean {
                return clip.type == ClipType.IMAGE;
            });

            // to listen events from other plugins, we need to first wait until all plugins are ready
            // this can be achieved by listening player.onLoad()
            player.onLoad(onPlayerLoad);

            // once initialized we need to dispatch onLoad
            _model.dispatchOnLoad();
        }

        private function onPlayerLoad(event:PlayerEvent):void {
            log.debug("onPlayerLoad()");
            addControlsPluginListeners(event.target as Flowplayer);
        }

        private function onClipStart(event:ClipEvent):void {
            log.debug("clip " + event.target + " started");
        }

        private function onImageClipFinished(event:ClipEvent):void {
            log.debug("image " + event.target + " is showing");

            // call some random function in the controlbar
            var controls:Plugin = getControlsModel().getDisplayObject() as Plugin;
            // disable all buttons
            controls["enable"]({ all: false });
        }

        private function getControlsModel():DisplayPluginModel {
            return _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
        }

        // hooks up listeners to the controlbar
        private function addControlsPluginListeners(player:Flowplayer):void {
            var controlsModel:DisplayPluginModel = getControlsModel();

            // listen to events also on "before phase". This is needed to catch onBeforeHidden and onBeforeShowed
            controlsModel.onBeforePluginEvent(onBeforeControlsEvent);

            controlsModel.onPluginEvent(onControlsEvent);

            log.debug("addControlsPluginListeners(), done");
        }

        private function onControlsEvent(event:PluginEvent):void {
            log.debug("received plugin event " + event.id);
            var model:DisplayPluginModel = event.target as DisplayPluginModel;
            log.debug("controls y-pos now is " + model.getDisplayObject().y);
        }

        private function onBeforeControlsEvent(event:PluginEvent):void {
            log.debug("received plugin event " + event.id);
            var model:DisplayPluginModel = event.target as DisplayPluginModel;
            log.debug("controls y-pos now is " + model.getDisplayObject().y);


            // prevent the controlbar from going hidden
            if (event.id == "onBeforeHidden") {
                event.preventDefault();
            }
        }

        public function getDefaultConfig():Object {
            return null;
        }
    }
}