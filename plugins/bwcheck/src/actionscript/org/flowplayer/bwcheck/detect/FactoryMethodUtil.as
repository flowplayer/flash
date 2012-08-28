/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {
    import flash.utils.getDefinitionByName;

    /**
     * @author danielr
     */
    public class FactoryMethodUtil {

        public static function getFactoryMethod(base:String, method:String):Class {
            return Class(getDefinitionByName(base + ucFirst(method)));
        }

        public static function ucFirst(value:String):String {
            return String(value.toLowerCase().charAt(0).toUpperCase() + value.substr(1, value.length).toLowerCase());
        }
    }
}
