/**
* Encrypts and decrypts text with the TEA (Block) algorithm.
* @authors Mika Palmu
* @version 2.0
*
* Original Javascript implementation:
* Chris Veness, Movable Type Ltd: www.movable-type.co.uk
* Algorithm: David Wheeler & Roger Needham, Cambridge University Computer Lab
* See http://www.movable-type.co.uk/scripts/TEAblock.html
*/

package com.meychi.ascrypt {

public class TEA {

	/**
	* Encrypts a string with the specified key.
	*/
	public static function encrypt(src:String, key:String):String {
		var v:Array = charsToLongs(strToChars(src));
		var k:Array = charsToLongs(strToChars(key));
		var n:Number = v.length;
		var p:Number;
		if (n == 0) return "";
		if (n == 1) v[n++] = 0;
		var z:Number = v[n-1], y:Number = v[0], delta:Number = 0x9E3779B9;
		var mx:Number, e:Number, q:Number = Math.floor(6+52/n), sum:Number = 0;
		while (q-- > 0) {
			sum += delta;
			e = sum>>>2 & 3;
			for (p = 0; p<n-1; p++) {
				//trace("k:"+k.length+":"+(p&3^e));
				y = v[p+1];
				mx = (z>>>5^y<<2)+(y>>>3^z<<4)^(sum^y)+(k[p&3^e]^z);
				z = v[p] += mx;
			}
			y = v[0];
			mx = (z>>>5^y<<2)+(y>>>3^z<<4)^(sum^y)+(k[p&3^e]^z);
			z = v[n-1] += mx;
		}
		return charsToHex(longsToChars(v));
	}

	/**
	* Decrypts a string with the specified key.
	*/
	public static function decrypt(src:String, key:String):String {
		var v:Array = charsToLongs(hexToChars(src));
		var k:Array = charsToLongs(strToChars(key));
		var n:Number = v.length;
		var p:Number;
		if (n == 0) return "";
		var z:Number = v[n-1], y:Number = v[0], delta:Number = 0x9E3779B9;
		var mx:Number, e:Number, q:Number = Math.floor(6 + 52/n);
		var sum:Number = q*delta;
		while (sum != 0) {
			e = sum>>>2 & 3;
			for(p = n-1; p > 0; p--){
				z = v[p-1];
				mx = (z>>>5^y<<2)+(y>>>3^z<<4)^(sum^y)+(k[p&3^e]^z);
				y = v[p] -= mx;
			}
			z = v[n-1];
			mx = (z>>>5^y<<2)+(y>>>3^z<<4)^(sum^y)+(k[p&3^e]^z);
			y = v[0] -= mx;
			sum -= delta;
		}
		return charsToStr(longsToChars(v));
	}
	
	/**
	* Private methods.
	*/
	private static function charsToLongs(chars:Array):Array {
		var temp:Array = new Array(Math.ceil(chars.length/4));
		for (var i:Number = 0; i<temp.length; i++) {
			temp[i] = chars[i*4] + (chars[i*4+1]<<8) + (chars[i*4+2]<<16) + (chars[i*4+3]<<24);
		}
		return temp;
	}
	private static function longsToChars(longs:Array):Array {
		var codes:Array = new Array();
		for (var i:Number = 0; i<longs.length; i++) {
			codes.push(longs[i] & 0xFF, longs[i]>>>8 & 0xFF, longs[i]>>>16 & 0xFF, longs[i]>>>24 & 0xFF);
		}
		return codes;
	}
	private static function longToChars(longs:Number):Array {
		var codes:Array = new Array();
		codes.push(longs & 0xFF, longs>>>8 & 0xFF, longs>>>16 & 0xFF, longs>>>24 & 0xFF);
		return codes;
	}
	private static function charsToHex(chars:Array):String {
		var result:String = new String("");
		var hexes:Array = new Array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
		for (var i:Number = 0; i<chars.length; i++) {
			result += hexes[chars[i] >> 4] + hexes[chars[i] & 0xf];
		}
		return result;
	}
	private static function hexToChars(hex:String):Array {
		var codes:Array = new Array();
		for (var i:Number = (hex.substr(0, 2) == "0x") ? 2 : 0; i<hex.length; i+=2) {
			codes.push(parseInt(hex.substr(i, 2), 16));
		}
		return codes;
	}
	private static function charsToStr(chars:Array):String {
		var result:String = new String("");
		for (var i:Number = 0; i<chars.length; i++) {
			result += String.fromCharCode(chars[i]);
		}
		return result;
	}
	private static function strToChars(str:String):Array {
		var codes:Array = new Array();
		for (var i:Number = 0; i<str.length; i++) {
			codes.push(str.charCodeAt(i));
		}
		return codes;
	}
	
}
}