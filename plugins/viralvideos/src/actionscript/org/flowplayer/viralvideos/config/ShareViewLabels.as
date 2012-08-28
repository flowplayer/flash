/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009-2011 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.viralvideos.config {

    public class ShareViewLabels {
        private var _title:String = "Click on an icon to share this video";


        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }
    }
}