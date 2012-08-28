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
package org.flowplayer.ui {
    import flash.display.DisplayObject;

    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.Flowplayer;

    /**
     * A notification that can show any DisplayObject in the player's Panel.
     */
    internal class DisplayObjectNotification extends Notification {
        private var _view:DisplayObject;

        public function DisplayObjectNotification(player:Flowplayer, view:DisplayObject) {
            super(player);
            _view = view;
            addChild(_view);
//            sty
        }

        override protected function onResize():void {
            _view.height = height;
            _view.scaleX = _view.scaleY;
            Arrange.center(_view, width);
        }
    }
}
