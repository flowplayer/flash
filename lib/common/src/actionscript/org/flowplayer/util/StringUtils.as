
package org.flowplayer.util {
    public class StringUtils {

        public static function formatString(original:String, ...args):String {
            var replaceRegex:RegExp = /\{([0-9]+)\}/g;
            return original.replace(replaceRegex, function():String {
                if (args == null)
                {
                    return arguments[0];
                }
                else
                {
                    var resultIndex:uint = uint(between(arguments[0], '{', '}'));
                    return (resultIndex < args.length) ? args[resultIndex] : arguments[0];
                }
            });
        }


        public static function between(p_string:String, p_start:String, p_end:String):String {
            var str:String = '';
            if (p_string == null) { return str; }
            var startIdx:int = p_string.indexOf(p_start);
            if (startIdx != -1) {
                startIdx += p_start.length; // RM: should we support multiple chars? (or ++startIdx);
                var endIdx:int = p_string.indexOf(p_end, startIdx);
                if (endIdx != -1) { str = p_string.substr(startIdx, endIdx-startIdx); }
            }
            return str;
        }

        public static function buildQueryFromObject(data:Object):String {
			import flash.utils.describeType;
			var xml:XML = describeType(data);

			var args : Array = [];

			if (xml.@isDynamic.toString() == "true") {
				for (var y:String in data)
				{
					if (data[y] != undefined) {
						args.push(y + "=" + data[y]);
					}
				}
			}

			for each (var v:XML in xml.variable) {
				if (data[v.@name] != undefined) {
					args.push(v.@name + "=" + data[v.@name]);
				}
			}

			for each (v in xml.accessor) {
				if (data[v.@name] != undefined) {
					args.push(v.@name + "=" + data[v.@name]);
				}
			}
			return args.join("&");
		}

        public static function endsWith(input:String, suffix:String):Boolean {
            return (suffix == input.substring(input.length - suffix.length));
        }

        public static function startsWith(input:String, prefix:String):Boolean {
            return (prefix == input.substring(0, prefix.length));
        }
    }

}
