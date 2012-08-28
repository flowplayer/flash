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

import org.flowplayer.util.Log;
import org.flowplayer.model.ClipEventType;
import org.flowplayer.model.Clip;

public class DefaultSeekDataStore {
    protected var log:Log = new Log(this);
    protected var _keyFrameTimes:Array;
    protected var _keyFrameFilePositions:Array;
    private var _prevSeekTime:Number = 0;

    private function init(clip:Clip, metaData:Object):void {
        if (! metaData) return;
        log.debug("will extract keyframe metadata");
        try {
            _keyFrameTimes = extractKeyFrameTimes(metaData);
            _keyFrameFilePositions = extractKeyFrameFilePositions(metaData);
        } catch (e:Error) {
            log.error("error getting keyframes " + e.message);
            clip.dispatch(ClipEventType.ERROR, e.message);
        }
//        log.info("_keyFrameTimes array lenth is " + (_keyFrameTimes ? _keyFrameTimes.length+"" : "null array"));
//        log.info("_keyFrameFilePositions array lenth is " + (_keyFrameFilePositions ? _keyFrameFilePositions.length+"" : "null array"));
    }

    public static function create(clip:Clip, metaData:Object):DefaultSeekDataStore {
        var log:Log = new Log("org.flowplayer.pseudostreaming::DefaultKeyFrameStore");
        log.debug("extracting keyframe times and filepositions");
        var store:DefaultSeekDataStore = metaData.seekpoints ? new H264SeekDataStore() : new FLVSeekDataStore();
        store.init(clip, metaData);
        return store;
    }

    protected function extractKeyFrameFilePositions(metadata:Object):Array {
        return null;
    }

    protected function extractKeyFrameTimes(metadata:Object):Array {
        return null;
    }

    internal function allowRandomSeek():Boolean {
        return _keyFrameTimes != null && _keyFrameTimes.length > 0;        
    }

    internal function get dataAvailable():Boolean {
        return _keyFrameTimes != null;
    }


    public function getQueryStringStartValue(seekPosition: Number, rangeBegin:Number = 0, rangeEnd:Number = undefined):Number {
        if (!rangeEnd) {
            rangeEnd = _keyFrameTimes.length - 1;
        }
        if (rangeBegin == rangeEnd || rangeEnd - rangeBegin == 1) {
             _prevSeekTime =_keyFrameTimes[rangeBegin];
             return queryParamValue(rangeBegin);
        }

        var rangeMid:Number = Math.floor((rangeEnd + rangeBegin)/2);
        if (_keyFrameTimes[rangeMid] >= seekPosition) {
            return getQueryStringStartValue(seekPosition, rangeBegin, rangeMid);
        } else {
            var offset:Number = (rangeEnd - rangeMid) == 1 ? 0 : 1;
            return getQueryStringStartValue(seekPosition, rangeMid + offset, rangeEnd);
        }
    }

    protected function queryParamValue(pos:Number):Number {
        return _keyFrameFilePositions[pos];
    }

    public function reset():void {
        _prevSeekTime = 0;
    }

    public function inBufferSeekTarget(target:Number):Number {
        return Math.max(target - _prevSeekTime, 0);
    }

    public function currentPlayheadTime(time:Number, start:Number):Number {
        return (time - start) + _prevSeekTime;
    }
}

}