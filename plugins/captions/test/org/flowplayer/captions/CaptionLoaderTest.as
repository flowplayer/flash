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

    import org.flowplayer.captions.parsers.JSONParser;

    import org.flowplayer.captions.parsers.SRTParser;
    import org.flowplayer.captions.parsers.TTXTParser;

    import org.flowplayer.model.Clip;

    public class CaptionLoaderTest extends TestCase {
        private var processor:CaptionLoader;
        private var _clip:Clip;

        override public function setUp():void {
            processor = new CaptionLoader(null, null, new Config());
            _clip = new Clip();
        }

        public function testCreateSubRipParser():void {
            _clip.setCustomProperty("captionFormat", "subrip");
            assertTrue(processor.createParser(_clip,  {}) is SRTParser);
        }

        public function testCreateJSONParser():void {
            _clip.setCustomProperty("captionFormat", "json");
            assertTrue(processor.createParser(_clip,  {}) is JSONParser);
        }

        public function testCreateTimedTextParser():void {
            _clip.setCustomProperty("captionFormat", "tt");
            assertTrue(processor.createParser(_clip,  {}) is TTXTParser);
        }
    }
}
