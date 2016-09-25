/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// ReadStream.as
// John Maloney, October 2009
//
// A simple character stream with two character look-ahead and tokenization.

package util {
public class ReadStream {

	private var src:String, i:int;

	public function ReadStream(s:String) {
		src = s;
		i = 0;
	}

	public function atEnd():Boolean {
		return i >= src.length;
	}

	public function next():String {
		if (i >= src.length) return '';
		return src.charAt(i++);
	}

	public function peek():String {
		return (i < src.length) ? src.charAt(i) : '';
	}

	public function peek2():String {
		return ((i + 1) < src.length) ? src.charAt(i + 1) : '';
	}

	public function peekString(n:int):String { return src.slice(i, i + n) }

	public function nextString(n:int):String {
		i += n;
		return src.slice(i - n, i);
	}

	public function pos():int { return i }

	public function setPos(newPos:int):void { i = newPos }

	public function skip(count:int):void { i += count }

	public function skipWhiteSpace():void {
		while ((i < src.length) && (src.charCodeAt(i) <= 32)) i++;
	}

	public function upToEnd():String {
		var result:String = (i < src.length) ? src.slice(i, src.length) : '';
		i = src.length;
		return result;
	}

	public static function tokenize(s:String):Array {
		var stream:ReadStream = new ReadStream(s);
		var result:Array = [];
		while (!stream.atEnd()) {
			var token:String = stream.nextToken();
			if (token.length > 0) result.push(token);
		}
		return result;
	}

	public function nextToken():String {
		skipWhiteSpace();
		if (atEnd()) return '';
		var token:String = '';
		var isArg:Boolean;
		var start:int = i;
		var inBrackets:Boolean = false;
		while (i < src.length) {
			var ch:String = src.charAt(i);
			if (inBrackets) {
				if (ch == ']') {
					inBrackets = false
				}
				token += ch;
				i++;
				continue;
			}
			if (src.charCodeAt(i) <= 32 && !inBrackets) break;
			if (ch == '\\') {
				token += ch + src.charAt(i + 1);
				i += 2;
				continue;
			}
			if (ch == '[') {
				inBrackets = true
			}
			if (ch == '%') {
				if (i > start) break; // percent sign starts new token
				isArg = true;
			}
			// certain punctuation marks following an argument start a new token
			// example: 'touching %m?' (question mark after arg starts a new token) vs. 'loud?' (doesn't)
			if (isArg && (ch == '?' || ch == '-')) break;
			token += ch;
			i++;
		}
		return token;
	}

	public static function escape(s:String):String {
		return s.replace(/[\\%@]/g, '\\$&');
	}

	public static function unescape(s:String):String {
		var result:String = '';
		for (var i:int = 0; i < s.length; i++) {
			var ch:String = s.charAt(i);
			if (ch == '\\') {
				result += s.charAt(i + 1);
				i++;
			} else {
				result += ch;
			}
		}
		return result;
	}

}}
