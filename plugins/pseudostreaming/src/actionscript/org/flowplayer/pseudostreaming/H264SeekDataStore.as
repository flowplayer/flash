/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <support@flowplayer.org>
 * Copyright (c) 2008-2011 Flowplayer Oy
 * H.264 support by: Arjen Wagenaar, <h264@code-shop.com>
 * Copyright (c) 2009 CodeShop B.V.
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.pseudostreaming {

import org.flowplayer.model.Clip;

public class H264SeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameTimes(metaData:Object):Array {
        var times:Array = new Array();
        for (var j:Number = 0; j != metaData.seekpoints.length; ++j) {
          times[j] = Number(metaData.seekpoints[j]['time']);
//          log.debug("keyFrame[" + j + "] = " + _keyFrameTimes[j]);
        }
        return times;
    }

    override protected function queryParamValue(pos:Number):Number {
        return _keyFrameTimes[pos] + 0.01;
    }
}

}