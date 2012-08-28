/*
 * Author: Daniel Rossi, <electroteque at gmail com>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.util {

    import flash.accessibility.AccessibilityProperties;
    import flash.display.DisplayObjectContainer;

    public class AccessibilityUtil {

        public function AccessibilityUtil() {

        }

        public static function setAccessible(display:DisplayObjectContainer, name:String):void
        {
            var accessProps:AccessibilityProperties = new AccessibilityProperties();
            accessProps.name = name;
            display.accessibilityProperties = accessProps;

            display.tabEnabled = true;
            display.tabChildren = false;

        }
    }
}
