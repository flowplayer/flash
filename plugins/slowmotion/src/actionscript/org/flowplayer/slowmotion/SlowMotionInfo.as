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
package org.flowplayer.slowmotion {
    import org.flowplayer.model.Clip;

    public class SlowMotionInfo {
        private var _isTrickPlay:Boolean;
        private var _forwardDirection:Boolean;
        private var _timeOffset:Number;
        private var _speedMultiplier:Number;
        private var _clip:Clip;

        public function SlowMotionInfo(clip:Clip, isTrickPlay:Boolean, forwardDirection:Boolean, timeOffset:Number, speedMultiplier:Number) {
            _clip = clip;
            _isTrickPlay = isTrickPlay;
            _forwardDirection = forwardDirection;
            _timeOffset = timeOffset;
            _speedMultiplier = speedMultiplier;
        }

        public static function createForNormalSpeed(clip:Clip):SlowMotionInfo {
            return new SlowMotionInfo(clip, false, true, 0, 0);
        }

        public function adjustedTime(time:Number):Number {
            if (_isTrickPlay) {
                var inc:Number = ((time*1000)-_timeOffset) * _speedMultiplier;
                return Math.max(0, (_timeOffset + (_forwardDirection ? inc : -inc))/1000);
            }
            return time;
        }

        public function get isTrickPlay():Boolean {
            return _isTrickPlay;
        }

        public function get timeOffset():Number {
            return _timeOffset;
        }

        public function get speedMultiplier():Number {
            return _speedMultiplier;
        }

        public function get forwardDirection():Boolean {
            return _forwardDirection;
        }

        public function get clip():Clip {
            return _clip;
        }

        public function equals(info:SlowMotionInfo):Boolean {
            if (! info) return false;
            return _clip == info.clip && _isTrickPlay == info.isTrickPlay && _forwardDirection == info.forwardDirection &&
                    _timeOffset == info.timeOffset && _speedMultiplier == info.speedMultiplier;
        }

        public function toString():String {
            return "[SlowMotionInfo] clip: '" + _clip + "', isTrickPlay: " + _isTrickPlay + ", forward: " + _forwardDirection +
                    ", offset " + _timeOffset + ", multiplier " + _speedMultiplier;
        }
    }
}