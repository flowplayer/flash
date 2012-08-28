package org.flowplayer.qosmonitor.config {

    import org.flowplayer.util.PropertyBinder;

    public class Config {

        private var _interval:Number = 100;
        private var _info:Boolean = false;
        private var _canvas:Object;
        private var _stats:StatsConfig = new StatsConfig();

        public function get canvas():Object {
            if (! _canvas) {
                _canvas = {
                    backgroundGradient: 'none',
                    border: 'none',

                    borderRadius: 0,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',

                    '.stats': {
                        fontSize: 12
                    },
                    '.label': {
                        fontSize: 12
                    }
                };
            }
            return _canvas;
        }

        public function set canvas(value:Object):void {
            var canvasConfig:Object = canvas;
            for (var prop:String in value) {
                canvasConfig[prop] = value[prop];
            }
        }

        public function get interval():Number {
            return _interval;
        }

        public function set interval(value:Number):void {
            _interval = value;
        }

        public function get info():Boolean {
            return _info;
        }

        public function set info(value:Boolean):void {
            _info = value;
        }

        public function setStats(value:Object):void {
            new PropertyBinder(_stats).copyProperties(value);
        }

        public function get stats():StatsConfig {
            return _stats;
        }
        
    }
}
