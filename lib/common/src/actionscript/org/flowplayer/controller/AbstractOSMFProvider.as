package org.flowplayer.controller
{
    import flash.display.DisplayObject;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.utils.Dictionary;

    import org.flowplayer.model.Clip;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.ClipEventType;
    import org.flowplayer.model.Playlist;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.osmf.events.LoadEvent;
    import org.osmf.media.MediaElement;
    import org.osmf.media.MediaPlayer;
    import org.osmf.net.NetClient;
    import org.osmf.net.NetStreamCodes;
    import org.osmf.net.NetStreamLoadTrait;
    import org.osmf.traits.DisplayObjectTrait;
    import org.osmf.traits.LoadState;
    import org.osmf.traits.MediaTraitType;

    /**
     * Abstract class for OSMF based stream providers.
     */
    public class AbstractOSMFProvider {
        private var log:Log = new Log(this);
        private static const CLASS_NAME:String = 'AbstractOSMFProvider';

        protected var _netStream:NetStream;
        protected var _streamCallbacks:Dictionary = new Dictionary();
        protected var _connectionClient:NetConnectionClient;
        protected var _playlist:Playlist;
        protected var _volumeController:VolumeController;
        protected var _pmodel:PluginModel;
        protected var media:MediaElement;
        protected var mediaController:MediaPlayer;
        protected var _video:Video;
        protected var clip:Clip;

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function getVideo(clip:Clip):DisplayObject
        {
            log.debug('accessing video object');
            return _video;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get bufferEnd():Number
        {
            return mediaController.bufferLength;
        }


        /**
         * Gets the type of StreamProvider either http, rtmp, psuedo.
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get type():String
        {
            return 'rtmp';//?
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get bufferStart():Number //??
        {
            return 0;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get time():Number
        {
            return mediaController.currentTime;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function pause(evt:ClipEvent):void
        {
            mediaController.pause();
            clip.dispatchEvent(evt);
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function resume(evt:ClipEvent):void
        {
            mediaController.play();
            clip.dispatchEvent(evt);
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function stop(evt:ClipEvent, closeStream:Boolean = false):void
        {
            mediaController.stop();
            clip.dispatchEvent(evt);
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get fileSize():Number
        {
            return mediaController.bytesTotal;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function attachStream(video:DisplayObject):void
        {
            Video(video).attachNetStream(_netStream);
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get allowRandomSeek():Boolean
        {
            return true;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function set volumeController(controller:VolumeController):void
        {
            _volumeController = controller;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get stopping():Boolean
        {
            return false;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function set playlist(playlist:Playlist):void
        {
            _playlist = playlist;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get playlist():Playlist
        {
            return _playlist;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function addConnectionCallback(name:String, listener:Function):void
        {
            _connectionClient.addConnectionCallback(name, listener);
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function addStreamCallback(name:String, listener:Function):void
        {
            _streamCallbacks[name] = listener;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get streamCallbacks():Dictionary
        {
            return _streamCallbacks;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get netStream():NetStream
        {
            return _netStream;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function get netConnection():NetConnection
        {
            log.warn('getting netconnection, not currently set')
            return null;
        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function set timeProvider(timeProvider:TimeProvider):void
        {

        }

        /**
         * #StreamProvider implementation
         * @inheritDoc
         */
        public function stopBuffering():void
        {

        }

        /**
         * #Plugin implementation
         * @inheritDoc
         */
        public function getDefaultConfig():Object
        {
            return null;
        }


        protected function onPluginsReady():void
        {
            log.debug('plugins ready');
            _pmodel.dispatchOnLoad(); // signal that plugin is ready
        }


        protected function onVTrait():void
        {
            var vTrait:DisplayObjectTrait = media.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
            _video = vTrait.displayObject as Video;
            log.debug(_video.toString());
            clip.setContent(_video); // got video

        }

        protected function onLoadStateChange(evt:LoadEvent):void
        {
            log.debug(evt.loadState)
            if (evt.loadState == LoadState.READY)
            {
                onNsTrait();
            } //fi
        } //()

        protected function onNsTrait():void
        {
            var nsTrait:NetStreamLoadTrait = media.getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
            if (!nsTrait)
            {
                return;
            }
            _netStream = nsTrait.netStream;
            if (!_netStream)
            {
                return;
            }
            log.debug(_netStream.toString());
            clip.setNetStream(nsTrait.netStream); //got the netstream

            NetClient(_netStream.client).addHandler(NetStreamCodes.ON_META_DATA,
                    onMetaData);

        }

        protected function onMetaData(data:Object):void
        {
            /*trace(data,'***');
             for(var key:String in data)
             {
             var value:Object = data[key];
             trace(key + " = " + value);
             }*/

            var client:NetStreamClient = new NetStreamClient(clip, null, null); // _player.config, null);
            client.onMetaData(data);
            clip.dispatchEvent(new ClipEvent(ClipEventType.METADATA));
            clip.dispatchEvent(new ClipEvent(ClipEventType.START));
            clip.dispatchEvent(new ClipEvent(ClipEventType.BUFFER_FULL));
        }
    }
}
