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

// Primitives.as
// John Maloney, April 2010
//
// Miscellaneous primitives. Registers other primitive modules.
// Note: A few control structure primitives are implemented directly in Interpreter.as.

package primitives {
	import flash.utils.Dictionary;
	import flash.desktop.ClipboardFormats;
	import flash.net.URLRequest
	import flash.net.navigateToURL;
	import flash.net.FileReference;
	import flash.events.Event;
	import flash.media.*;
	import flash.utils.*;
	import blocks.*;
	import interpreter.*;
	import scratch.ScratchSprite;
	import translation.Translator;
	import uiwidgets.*;
	import ui.*;
	import ui.parts.*;
	import uiwidgets.*;
	import ui.media.*;
	import flash.display.*;
	import scratch.*;
	import util.*;
	import flash.errors.IllegalOperationError;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReferenceList;
	import flash.net.LocalConnection;
	import flash.system.*;
	import flash.text.*;

public class Primitives {

	protected var app:Scratch;
	protected var interp:Interpreter;
	private var counter:int;

	public function Primitives(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;
	}

	public function addPrimsTo(primTable:Dictionary):void {
		// operators
		primTable["+"]				= function(b:*):* { return interp.numarg(b, 0) + interp.numarg(b, 1) };
		primTable["-"]				= function(b:*):* { return interp.numarg(b, 0) - interp.numarg(b, 1) };
		primTable["*"]				= function(b:*):* { return interp.numarg(b, 0) * interp.numarg(b, 1) };
		primTable["/"]				= function(b:*):* { return interp.numarg(b, 0) / interp.numarg(b, 1) };
		primTable["≥"]				= function(b:*):* { return interp.numarg(b, 0) >= interp.numarg(b, 1) };
		primTable["≤"]				= function(b:*):* { return interp.numarg(b, 0) <= interp.numarg(b, 1) };
		primTable["≠"]				= function(b:*):* { return interp.arg(b, 0) != interp.arg(b, 1) };
		primTable["^"]				= function(b:*):* { return Math.pow(interp.numarg(b, 0), interp.numarg(b, 1)) };
		primTable["randomFrom:to:"]	= primRandom;
		primTable["<"]				= function(b:*):* { return compare(interp.arg(b, 0), interp.arg(b, 1)) < 0 };
		primTable["="]				= function(b:*):* { return compare(interp.arg(b, 0), interp.arg(b, 1)) == 0 };
		primTable[">"]				= function(b:*):* { return compare(interp.arg(b, 0), interp.arg(b, 1)) > 0 };
		primTable["&"]				= function(b:*):* { return interp.arg(b, 0) && interp.arg(b, 1) };
		primTable["|"]				= function(b:*):* { return interp.arg(b, 0) || interp.arg(b, 1) };
		primTable["if:then:else:"]	= primIfThenElse;
		primTable[":asBoolean"]		= primAsBoolean;
		primTable[":isType"]		= primIsType;
		primTable["not"]			= function(b:*):* { return !interp.arg(b, 0) };
		primTable["abs"]			= function(b:*):* { return Math.abs(interp.numarg(b, 0)) };
		primTable["sqrt"]			= function(b:*):* { return Math.sqrt(interp.numarg(b, 0)) };
		
		primTable["true"]				= function(b:*):Boolean { return true };
		primTable["false"]				= function(b:*):Boolean { return false };
		primTable["constant"]			= primConstant;
		primTable[":%ChanceOfTrue"]		= primChance;

		primTable["concatenate:with:"]	= function(b:*):* { return ("" + interp.arg(b, 0) + interp.arg(b, 1)).substr(0, 10240); };
		primTable["letter:of:"]			= primLetterOf;
		primTable["letters:to:of:"]		= primLettersBetween;
		primTable["stringLength:"]		= function(b:*):* { return String(interp.arg(b, 0)).length };

		primTable["%"]					= primModulo;
		primTable["rounded"]			= function(b:*):* { return Math.round(interp.numarg(b, 0)) };
		primTable["computeFunction:of:"] = primMathFunction;
		
		//Strings
		primTable["alterString"]		= primAlterString;
		primTable["caseSensitive"]		= function(b:*):Boolean { return (interp.arg(b, 0) == interp.arg(b, 1)) };
		primTable["asciiFor:"]			= function(b:*):* { return (interp.arg(b, 0)).charCodeAt(0) };
		primTable["ascii:asString"]		= function(b:*):* { return String.fromCharCode(interp.numarg(b, 0)) };
		primTable[":contains:"]			= function(b:*):Boolean {
			var a:* = interp.arg(b, 0);
			if(a.indexOf(interp.arg(b, 1)) >= 0){
				return true;
			} else {
				return false;
			}
		}
		primTable["times:isIn:"]		= function(b:*):* {
			var str:String = interp.arg(b, 1);
			var char:String = interp.arg(b, 0);

			function countOccurences(str:String, char:String):Number {
				var count:Number = 0;

				for(var i:Number=0; i < str.length; i++) {
					if (str.charAt(i) == char) {
						count++;
					}
				}
				return count;
			}

			return countOccurences(str, char);
		}
		primTable["replaceEvery"]		= function(b:*):* {
			var str:String = interp.arg(b, 1);
			var search:String = interp.arg(b, 0);
			var replace:String = interp.arg(b, 2);

			function strReplace(str:String, search:String, replace:String):String {
				return str.split(search).join(replace);
			}
			return strReplace(str, search, replace);
		}
		primTable["replaceBetween"]		= function(b:*):* {
			//First, grab the text between the two numbers
			var s:String = interp.arg(b, 2);
			var n1:int = interp.numarg(b, 0) - 1;
			var n2:int = interp.numarg(b, 1);
			if ((n1 < 0) || (n2 >= s.length)) return "";
			var sect:String = s.slice(n1, n2);
			//Then the find-and-replace tactic (FLAWED!!! Can replace two bits of identicle text...)
			var str:String = interp.arg(b, 2);
			var search:String = sect;
			var replace:String = interp.arg(b, 3);

			function strReplace(str:String, search:String, replace:String):String {
				return str.split(search).join(replace);
			}
			return strReplace(str, search, replace);
		}
		primTable["repeat::times"]		= function(b:*):* {
			function repeatString(string:String, numTimes:uint):String {
				var output:String = "";
				for(var i:uint = 0; i < numTimes; i++)
				output += string;
				return output;
			}
			return repeatString(interp.arg(b, 0), interp.arg(b, 1));
		}

		// clone
		primTable["createCloneOf"]		= primCreateCloneOf;
		primTable["deleteClone"]		= primDeleteClone;
		primTable["whenCloned"]			= interp.primNoop;
		primTable["cloneCount"]			= function(b:*):* { return app.runtime.cloneCount };

		// testing (for development)
		primTable["NOOP"]				= interp.primNoop;
		primTable["COUNT"]				= function(b:*):* { return counter };
		primTable["INCR_COUNT"]			= function(b:*):* { counter++ };
		primTable["CLR_COUNT"]			= function(b:*):* { counter = 0 };
		
		//Connect
		primTable["openUrl:"]			= function(b:*):* {
			var url:* = interp.arg(b, 0);
			return navigateToURL(new URLRequest(url), "_blank");
		}
		
		primTable["internetConnection"]	= function(b:*):* {
//			return "true";
			return app.isOffline;
		}
		
		//System
		primTable["save:toFile:"] = function(b:*):* {
			var ss:* = interp.arg(b, 0);
			var nm:* = interp.arg(b, 1);
			var bytes:ByteArray = new ByteArray();
			var fileRef:FileReference=new FileReference();
			fileRef.save(ss, nm);
		}
		primTable["loadTextFromFile"] = function(b:*):* {
			var fileR:FileReference = new FileReference();
//			var textFilter = new FileFilter("Text files", "*.txt");
			fileR.addEventListener(Event.CANCEL, cancelHandler); // Add event handlers
			fileR.addEventListener(Event.SELECT, selectHandler);
			fileR.addEventListener(Event.COMPLETE, completeHandler);
			fileR.browse(); // Browse for file  [textFilter]

			function selectHandler(e:Event):void{ // file selected
				trace("selectHandler: "+fileR.name);
				fileR.load(); // load it
			}
			function cancelHandler(e:Event):void { // file select canceled
				trace("cancelled by user");
			}
			function completeHandler(e:Event):void { // file loaded
				trace("completeHandler: " + fileR.name);
				app.runtime.ba = fileR.data;
			}
		}
		primTable["fileContents"] = function(b:*):* { return app.runtime.ba };

		//Program
		primTable[":mode"] = function(b:*):* {
			var mod:* = interp.arg(b, 0);
			switch(mod) {
				case "fullscreen": app.activateTurboMode();
				case "normal": app.setSmallStageMode(false);
				case "small stage": app.setSmallStageMode(true);
			}
			return;
		}
/*		primTable["copy:toClipboard"]	= function(b:*):* {
			var copy:* = interp.arg(b, 0);
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, copy);
		}
		
		primTable["clipboard"]			= function(b:*):* {
			var pasteData:String  = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			return pasteData;
		}*/
		primTable["setCursorTo:"] = function(b:*):void {
			var customCursor:* = interp.arg(b, 0);
			CursorTool.setCustomBlockCursor(customCursor);
		}
		primTable["toggleTurboMode"] = function(b:*):void {
			var ac:* = interp.arg(b, 0);
			switch(ac) {
				case "activate": app.activateTurboMode();
				case "deactivate": app.deactivateTurboMode();
				case "toggle": app.toggleTurboMode();
			}
		}
		primTable["turboMode"] = function(b:*):Boolean {
			return interp.turboMode;
		}
		primTable["setMaxCloneCount"] = function(b:*):* {
			var newMaxCloneCount:* = interp.arg(b, 0);
			app.confirmCloneCountChange(newMaxCloneCount);
		}
		primTable["maxCloneCount"] = function(b:*):* {
			return (app.MaxCloneCount + 2);
		}
		primTable["dialogNotify"] = function(b:*):* {
			app.primDialogNotify(interp.arg(b, 0), interp.arg(b, 1))
		}
		primTable["dialogConfirm"] = function(b:*):* {
			if (b.requestState == 2) {
				b.requestState = 0;
				return b.response;
			}
			b.requestState = 1;
			var bool:Boolean;
			bool = app.primDialogConfirm(interp.arg(b, 0), interp.arg(b, 1));
//			return bool;
//			b.requestState = 2;
			b.requestState = 1;
			setTimeout(function():* {
				return bool;
				b.requestState = 2;
				b.response = bool;
			}, 500);
		}
/*		primTable["dialogAsk"] = function(b:*):* {
			app.primDialogAsk(interp.arg(b, 0), interp.arg(b, 1))
		}*/
		primTable["customDialogNewLine"] = function(b:*):* {
			return interp.arg(b, 0) + "\n" + interp.arg(b, 1)
		}
		primTable["customDialogTitle"] = function(b:*):* {
			return "d.addTitle('" + interp.arg(b, 0) + "')"
		}
		primTable["customDialogText"] = function(b:*):* {
			return "d.addText('" + interp.arg(b, 0) + "')"
		}
/*		primTable["customDialog"] = function(b:*):* {
			return app.primCustomDialog(interp.arg(b, 0), interp.arg(b, 1), interp.arg(b, 2), interp.arg(b, 3), interp.arg(b, 4), interp.arg(b, 5), interp.arg(b, 6), interp.arg(b, 7), interp.arg(b, 8));
		}*/
/*		primTable[":mode"] = function(b:*):* {
			var mo:* = interp.arg(b, 0);
			switch(mo) {
			case "fullscreen": return Math.PI;
			case "editor": app.exitPresentationMode();
			}
			return 0;
		}*/
//		primTable["fullscreenMode"] = function(b:*):* { return app.isInPresentationMode() };
		
		//Other Variable blocks
/*		primTable["varSet:colorTo:"] = function(b:*):* {
			var color:* = interp.arg(b, 0);
			Watcher.setColor(color)
		}*/

		new LooksPrims(app, interp).addPrimsTo(primTable);
		new MotionAndPenPrims(app, interp).addPrimsTo(primTable);
		new SoundPrims(app, interp).addPrimsTo(primTable);
		new VideoMotionPrims(app, interp).addPrimsTo(primTable);
		addOtherPrims(primTable);
	}

	protected function addOtherPrims(primTable:Dictionary):void {
		new SensingPrims(app, interp).addPrimsTo(primTable);
		new ListPrims(app, interp).addPrimsTo(primTable);
	}

	private function primRandom(b:Block):Number {
		var n1:Number = interp.numarg(b, 0);
		var n2:Number = interp.numarg(b, 1);
		var low:Number = (n1 <= n2) ? n1 : n2;
		var hi:Number = (n1 <= n2) ? n2 : n1;
		if (low == hi) return low;
		// if both low and hi are ints, truncate the result to an int
		if ((int(low) == low) && (int(hi) == hi)) {
			return low + int(Math.random() * ((hi + 1) - low));
		}
		return (Math.random() * (hi - low)) + low;
	}

	private function primLetterOf(b:Block):String {
		var s:String = interp.arg(b, 1);
		var i:int = interp.numarg(b, 0) - 1;
		if ((i < 0) || (i >= s.length)) return "";
		return s.charAt(i);
	}
	
	private function primChance(b:Block):Boolean {
		var i:int = interp.numarg(b, 0);
		return (Math.random()<=i / 100);
	}
	
	private function primLettersBetween(b:Block):String {
		var s:String = interp.arg(b, 2);
		var n1:int = interp.numarg(b, 0) - 1;
		var n2:int = interp.numarg(b, 1);
		if ((n1 < 0) || (n2 >= s.length)) return "";
		return s.slice(n1, n2);
	}

	private function primModulo(b:Block):Number {
		var n:Number = interp.numarg(b, 0);
		var modulus:Number = interp.numarg(b, 1);
		var result:Number = n % modulus;
		if (result / modulus < 0) result += modulus;
		return result;
	}

	private function primMathFunction(b:Block):Number {
		var op:* = interp.arg(b, 0);
		var n:Number = interp.numarg(b, 1);
		switch(op) {
		case "abs": return Math.abs(n);
		case "floor": return Math.floor(n);
		case "ceiling": return Math.ceil(n);
		case "int": return n - (n % 1); // used during alpha, but removed from menu
		case "sqrt": return Math.sqrt(n);
		case "sin": return Math.sin((Math.PI * n) / 180);
		case "cos": return Math.cos((Math.PI * n) / 180);
		case "tan": return Math.tan((Math.PI * n) / 180);
		case "asin": return (Math.asin(n) * 180) / Math.PI;
		case "acos": return (Math.acos(n) * 180) / Math.PI;
		case "atan": return (Math.atan(n) * 180) / Math.PI;
		case "ln": return Math.log(n);
		case "log": return Math.log(n) / Math.LN10;
		case "e ^": return Math.exp(n);
		case "10 ^": return Math.exp(n * Math.LN10);
		}
		return 0;
	}
	
	private function primConstant(b:Block):Number {
		var op:* = interp.arg(b, 0);
		switch(op) {
		case "pi": return Math.PI;
		case "e": return Math.E;
		case "golden ratio": return (Math.sqrt(5) + 1) / 2;
		}
		return 0;
	}

	private static var lcDict:Dictionary = new Dictionary();
	public static function compare(a1:*, a2:*):int {
		// This is static so it can be used by the list "contains" primitive.
		var n1:Number = Interpreter.asNumber(a1);
		var n2:Number = Interpreter.asNumber(a2);
		if (isNaN(n1) || isNaN(n2)) {
			// at least one argument can't be converted to a number: compare as strings
			var s1:String = lcDict[a1];
			if(!s1) s1 = lcDict[a1] = String(a1).toLowerCase();
			var s2:String = lcDict[a2];
			if(!s2) s2 = lcDict[a2] = String(a2).toLowerCase();
			return s1.localeCompare(s2);
		} else {
			// compare as numbers
			if (n1 < n2) return -1;
			if (n1 == n2) return 0;
			if (n1 > n2) return 1;
		}
		return 1;
	}

	private function primCreateCloneOf(b:Block):void {
		var objName:String = interp.arg(b, 0);
		var proto:ScratchSprite = app.stagePane.spriteNamed(objName);
		if ('_myself_' == objName) proto = interp.activeThread.target;
		if (!proto) return;
		if (app.runtime.cloneCount > app.MaxCloneCount) return;
		var clone:ScratchSprite = new ScratchSprite();
		if (proto.parent == app.stagePane)
			app.stagePane.addChildAt(clone, app.stagePane.getChildIndex(proto));
		else
			app.stagePane.addChild(clone);

		clone.initFrom(proto, true);
		clone.objName = proto.objName;
		clone.isClone = true;
		for each (var stack:Block in clone.scripts) {
			if (stack.op == "whenCloned") {
				interp.startThreadForClone(stack, clone);
			}
		}
		app.runtime.cloneCount++;
	}

	private function primDeleteClone(b:Block):void {
		var clone:ScratchSprite = interp.targetSprite();
		if ((clone == null) || (!clone.isClone) || (clone.parent == null)) return;
		if (clone.bubble && clone.bubble.parent) clone.bubble.parent.removeChild(clone.bubble);
		clone.parent.removeChild(clone);
		app.interp.stopThreadsFor(clone);
		app.runtime.cloneCount--;
	}
	
	private function primAlterString(b:Block):String {
		var string:* = interp.arg(b, 1);
		var type:* = interp.arg(b, 0);
		switch(type) {
		case "uppercase": return string.toUpperCase();
		case "lowercase": return string.toLowerCase();
		case "reverse": return reverseString(string);
		case "shuffle": return initRandomizeArray(string);
		case "trim blanks of": return trimBlanks(string);
		}
		return "ERROR!";
	}
	
	private function reverseString(tString:String):String {
		var tmp_array:Array=tString.split("");
		tmp_array.reverse();
		var tmpString:String=tmp_array.join("");
		return tmpString;
	}
	
	private function initRandomizeArray(string:String):String {
		var tmp_array:Array = string.split("");
		return randomizeArray(tmp_array);
	}
	
	private function randomizeArray(array:Array):String {
		var newArray:Array = new Array();
		while(array.length > 0){
			newArray.push(array.splice(Math.floor(Math.random()*array.length), 1));
		}
		var tmpString:String = newArray.join("");
		return tmpString;
	}
	
	private function trimBlanks(str:String):String {
		var rex:RegExp = /[\s\r\n]+/gim;
		str = str.replace(rex,'');
		return str;
	}
	
	private function primIfThenElse(b:Block):String {
		var If:* = interp.arg(b, 0);
		var Then:* = interp.arg(b, 1);
		var Else:* = interp.arg(b, 2);
		if (If == true) {
			return Then;
		} else {
			return Else;
		}
	}
	
	private function primAsBoolean(b:Block):Boolean {
		var bool:* = interp.arg(b, 0);
		if (bool == false) {
			return false;
		} else {
			return true;
		}
	}
	
	private function primIsType(b:Block):Boolean {
		var string:* = interp.arg(b, 0);
		var type:* = interp.arg(b, 1);
		switch(type) {
		case "a number": return string is Number;
		case "a string": return string is String;
		case "a boolean": return string is Boolean;
		case "a color": return string is Color;
		}
		return false;
	}

}}
