package de.betriebsraum.video {

    public class BufferCalculator {
        // buffer padding in sec.
        // should be at least twice as long as the keyframe interval and fps, e.g.:
        // keyframe interval of 30 at 30fps --> min. 2 sec.
        public static var BUFFER_PADDING:Number = 3;

        // flvLength in sec., flvBitrate and bandwidth in kBits/Sec
        public static function calculate(flvLength:Number, flvBitrate:Number, bandwidth:Number):Number {
            var bufferTime:Number;
            if (flvBitrate > bandwidth) {
                bufferTime = Math.ceil(flvLength - flvLength / (flvBitrate / bandwidth));
            } else {
                bufferTime = 0;
            }
            return bufferTime + BUFFER_PADDING;

        }
    }

}
