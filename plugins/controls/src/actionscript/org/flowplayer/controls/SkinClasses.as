package org.flowplayer.controls {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
    import org.flowplayer.util.Log;

	import fp.*;

    /**
     * Holds references to classes contained in the buttons.swc lib.
     * These are needed here because the classes are instantiated dynamically and without these
     * the compiler will not include thse classes into the controls.swf
     */
    public class SkinClasses {
        private static var log:Log = new Log("org.flowplayer.controls.buttons::SkinClasses");
        private static var _skinClasses:ApplicationDomain;

		// imports all assets of default buttons to controls.swf
		CONFIG::skin {
            private var foo:fp.FullScreenOnButton;
            private var bar:fp.FullScreenOffButton;
            private var next:fp.NextButton;
            private var prev:fp.PrevButton;
            private var dr:fp.Dragger;
            private var pause:fp.PauseButton;
            private var play:fp.PlayButton;
            private var stop:fp.StopButton;
            private var vol:fp.MuteButton;
            private var volOff:fp.UnMuteButton;
            private var scrubberLeft:fp.ScrubberLeftEdge;
            private var scrubberRight:fp.ScrubberRightEdge;
            private var scrubberTop:fp.ScrubberTopEdge;
            private var scrubberBottom:fp.ScrubberBottomEdge;
            private var buttonLeft:fp.ButtonLeftEdge;
            private var buttomRight:fp.ButtonRightEdge;
            private var buttomTop:fp.ButtonTopEdge;
            private var buttonBottom:fp.ButtonBottomEdge;
            private var timeLeft:fp.TimeLeftEdge;
            private var timeRight:fp.TimeRightEdge;
            private var timeTop:fp.TimeTopEdge;
            private var timeBottom:fp.TimeBottomEdge;
            private var volumeLeft:fp.VolumeLeftEdge;
            private var volumeRight:fp.VolumeRightEdge;
            private var volumeTop:fp.VolumeTopEdge;
            private var volumeBottom:fp.VolumeBottomEdge;
            private var defaults:SkinDefaults;
        }
        

        public static function getDisplayObject(name:String):DisplayObjectContainer {
            var clazz:Class = getClass(name);
            return new clazz() as DisplayObjectContainer;
        }

        public static function getClass(name:String):Class {
            log.debug("creating skin class " + name + (_skinClasses ? "from skin swf" : ""));
            if (_skinClasses) {
                return _skinClasses.getDefinition(name) as Class;
            }
            return getDefinitionByName(name) as Class;
        }

        public static function get defaults():Object {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["values"];
            } catch (e:Error) {
            }
            return null;
        }

        public static function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObjectContainer):Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getScrubberRightEdgeWidth"](nextWidgetToRight);
            } catch (e:Error) {
            }
            return 0;
        }

		public static function getVolumeSliderWidth():Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getVolumeSliderWidth"]();
            } catch (e:Error) {
            }
            return 40;
        }

        public static function set skinClasses(val:ApplicationDomain):void {
            log.debug("received skin classes " + val);
            _skinClasses = val;
        }


    }
}