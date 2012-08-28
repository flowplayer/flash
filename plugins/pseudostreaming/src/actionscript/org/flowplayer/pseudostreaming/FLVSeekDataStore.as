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

public class FLVSeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameFilePositions(metaData:Object):Array {
        log.debug("extractKeyFrameFilePositions");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (! keyFrames) return null;
        return keyFrames.filepositions;
    }

    override protected function extractKeyFrameTimes(metaData:Object):Array {
        log.debug("extractKeyFrameTimes");
        var keyFrames:Object = extractKeyFrames(metaData);
        if (! keyFrames) return null;
        
        var keyFrameTimes:Array = keyFrames.times;
        if (! keyFrameTimes) {
            log.error("clip does not have keyframe metadata, cannot use pseudostreaming");
        }
        return keyFrameTimes as Array;
    }
    
    private function extractKeyFrames(metaData:Object):Object {
        var keyFrames:Object = metaData.keyframes;
//        log.debug("keyFrames: "+keyFrames);
        if (! keyFrames) {
            log.info("No keyframes in this file, random seeking cannot be done");
            return null;
        }
        return keyFrames;
    }

    override protected function queryParamValue(pos:Number):Number {
        return _keyFrameFilePositions[pos] as Number;
    }


    override public function inBufferSeekTarget(target:Number):Number {
        return target;
    }

    override public function currentPlayheadTime(time:Number, start:Number):Number {
        return time - start;
    }
}

}