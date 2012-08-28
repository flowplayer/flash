/*
 * Author: Anssi Piirainen, api@iki.fi
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.menu.ui {

    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import fp.MenuButton;

    import org.flowplayer.model.DisplayPluginModel;

    import org.flowplayer.ui.dock.Dock;

    import org.flowplayer.ui.buttons.ButtonEvent;
    import org.flowplayer.ui.controllers.AbstractButtonController;
import org.flowplayer.view.AnimationEngine;
import org.flowplayer.view.Flowplayer;

    public class MenuButtonController extends AbstractButtonController {
        private var _menu:Menu;
        private var _model:DisplayPluginModel;

		public function MenuButtonController(player:Flowplayer,  menuModel:DisplayPluginModel) {
            _player = player;
            _menu = menuModel.getDisplayObject() as Menu;
            _model = menuModel;
		}
		
		override public function get name():String {
			return "menu";
		}

		override public function get defaults():Object {
			return {
				tooltipEnabled: true,
				tooltipLabel: "Menu",
				visible: true,
				enabled: true
			};
		}

		override protected function get faceClass():Class {
			// we could have return fp.NextButton but we need it as string for skinless controls
			return MenuButton;
		}

		override protected function onButtonClicked(event:ButtonEvent):void {
            var model:DisplayPluginModel = DisplayPluginModel(_player.pluginRegistry.getPlugin(_model.name));

            var show:Boolean = _menu.alpha == 0 || ! _menu.visible || ! _menu.parent;
            if (show) {
                _menu.updateModelProp("display", "block");
                log.debug("showing menu");
                _menu.alpha = 0; // make sure the initial value before fade is sensible
                _player.animationEngine.fadeIn(_menu);
            } else {
                log.debug("hiding menu");
                _menu.alpha = 1; // make sure the initial value before fade is sensible
                _player.animationEngine.fadeOut(_menu);
            }
//            setListeners(show);
		}
//
//        private function setListeners(add:Boolean):void {
//            var func:String = add ? "addEventListener" : "removeEventListener";
//            _menu[func](MouseEvent.ROLL_OUT, onRollOut);
//        }
//
//        private function onRollOut(event:MouseEvent):void {
//            log.debug("onRollOut()");
//            _menu.startAutoHide();
//        }
	}
}

