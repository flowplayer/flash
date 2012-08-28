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
package org.flowplayer.captions {
    import flexunit.framework.TestCase;

    import org.flowplayer.model.Cuepoint;

    public class CaptionTest extends TestCase {

        public function testParseTemplate():void {
            var cap:Caption = new Caption("{text}, {time}",  1, 3, "haloo", null);
            var cuepoint:Cuepoint = Cuepoint.createDynamic(10, "embedded");
            cuepoint.parameters = cap;

            trace(cap.getHtml(cuepoint));
        }
    }
}
