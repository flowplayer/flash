/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.sharing {
    import org.flowplayer.view.Flowplayer;

    public class Facebook extends AbstractShareCommand {
        private static const FACEBOOK_URL:String = "http://www.facebook.com/sharer.php?t={0}&u={1}";

        public function Facebook(player:Flowplayer) {
            super(player);
        }

        override protected function get popupDimensions():Array {
            return [620,440];
        }

        override protected function get serviceUrl():String {
            return FACEBOOK_URL;
        }

    }
}