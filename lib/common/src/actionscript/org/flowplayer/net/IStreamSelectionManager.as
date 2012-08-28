
package org.flowplayer.net {
    public interface IStreamSelectionManager {

        function get bitrates():Vector.<BitrateItem>;
        function get bitrateResource():BitrateResource;
        function getDefaultStream():BitrateItem;;
        function getStreamIndex(bitrate:Number):Number;
        function getStream(bitrate:Number):BitrateItem;
        function getMappedBitrate(bandwidth:Number = -1):BitrateItem;
        function get currentIndex():Number;
        function set currentIndex(value:Number):void;
        function get currentBitrateItem():BitrateItem;
        function set currentBitrateItem(value:BitrateItem):void;
        function get streamItems():Vector.<BitrateItem>;
        function changeStreamNames(mappedBitrate:BitrateItem):void;
        function fromName(name:String):BitrateItem;

    }
}
