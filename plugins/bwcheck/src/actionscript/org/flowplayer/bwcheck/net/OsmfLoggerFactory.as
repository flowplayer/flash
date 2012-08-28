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
package org.flowplayer.bwcheck.net {
    import org.osmf.logging.Logger;
    import org.osmf.logging.LoggerFactory;

    public class OsmfLoggerFactory extends LoggerFactory {
        public function OsmfLoggerFactory() {
        }

        override public function getLogger(category:String):Logger {
            return new OsmfLogger(category);
        }
    }
}