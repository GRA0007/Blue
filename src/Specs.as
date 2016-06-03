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

// Specs.as
// John Maloney, April 2010
//
// This file defines the command blocks and categories.
// To add a new command:
//		a. add a specification for the new command to the commands array
//		b. add a primitive for the new command to the interpreter

package {
	import flash.display.Bitmap;
	import assets.Resources;

public class Specs {

	public static const GET_VAR:String = "readVariable";
	public static const SET_VAR:String = "setVar:to:";
	public static const CHANGE_VAR:String = "changeVar:by:";
	public static const GET_LIST:String = "contentsOfList:";
	public static const CALL:String = "call";
	public static const CALL_BOOLEAN:String = "callb";
	public static const CALL_NUMBER:String = "callr";
	public static const CALL_C:String = "callc";
	public static const PROCEDURE_DEF:String = "procDef";
	public static const GET_PARAM:String = "getParam";
	public static const GET_LOOP:String = "getLoop";

	public static const motionCategory:int = 1;
	public static const looksCategory:int = 2;
	public static const eventsCategory:int = 5;
	public static const controlCategory:int = 6;
	public static const operatorsCategory:int = 8;
	public static const dataCategory:int = 9;
	public static const myBlocksCategory:int = 10;
	public static const listCategory:int = 12;
	public static const extensionsCategory:int = 20;

	public static var variableColor:int = 0xEE7D16; // Scratch 1.4: 0xF3761D
	public static var listColor:int = 0xCC5B22; // Scratch 1.4: 0xD94D11
	public static var procedureColor:int = 0x632D99; // 0x531E99;
	public static var parameterColor:int = 0x5947B1;
	public static var extensionsColor:int = 0x4B4A60; // 0x72228C; // 0x672D79;

	private static const undefinedColor:int = 0xD42828;

	public static const categories:Array = [
	 // id   category name	color
		[0,  "undefined",	0xD42828],
		[1,  "Motion",		0x4a6cd4],
		[2,  "Looks",		0x8a55d7],
		[3,  "Sound",		0xbb42c3],
		[4,  "Pen",			0x0e9a6c], // Scratch 1.4: 0x009870
		[5,  "Events",		0xc88330],
		[6,  "Control",		0xe1a91a],
		[7,  "Sensing",		0x2ca5e2],
		[8,  "Operators",	0x5cb712],
		[9,  "Data",		variableColor],
		[10, "More Blocks",	procedureColor],
		[11, "Parameter",	parameterColor],
		[12, "List",		listColor],
		[20, "Extension",	extensionsColor],
		[13,  "System",		0x2600ff],
		[14,  "Dialogs",	0x9ba758],
		[15,  "Program",	0x026f2e],
		[16,  "Strings",	0x949400],
		[17,  "Websockets",	0x39bf93],
		[18,  "Color",		0x2e2e2e]
	];

	public static function blockColor(categoryID:int):int {
		if (categoryID > 100) categoryID -= 100;
		for each (var entry:Array in categories) {
			if (entry[0] == categoryID) return entry[2];
		}
		return undefinedColor;
	}

	public static function entryForCategory(categoryName:String):Array {
		for each (var entry:Array in categories) {
			if (entry[1] == categoryName) return entry;
		}
		return [1, categoryName, 0xFF0000]; // should not happen
	}

	public static function nameForCategory(categoryID:int):String {
		if (categoryID > 100) categoryID -= 100;
		for each (var entry:Array in categories) {
			if (entry[0] == categoryID) return entry[1];
		}
		return "Unknown";
	}

	public static function IconNamed(name:String):* {
		// Block icons are 2x resolution to look better when scaled.
		var icon:Bitmap;
		if (name == "greenFlag") icon = Resources.createBmp('flagIcon');
		if (name == "stop") icon = Resources.createBmp('stopIcon');
		if (name == "turnLeft") icon = Resources.createBmp('turnLeftIcon');
		if (name == "turnRight") icon = Resources.createBmp('turnRightIcon');
		if (name == "cookie") icon = Resources.createBmp('cookieIcon');
		if (icon != null) icon.scaleX = icon.scaleY = 0.5;
		return icon;
	}

	public static var commands:Array = [
		// block specification					type, cat, opcode			default args (optional)
		// motion
		["move %n steps",						" ", 1, "forward:",					10],
		["turn @turnRight %n degrees",			" ", 1, "turnRight:",				15],
		["turn @turnLeft %n degrees",			" ", 1, "turnLeft:",				15],
		["--"],
		["point in direction %d.direction",		" ", 1, "heading:",					90],
		["point towards %m.spriteOrMouse",		" ", 1, "pointTowards:",			"mouse-pointer"],
		["point towards x: %n y: %n",			" ", 1, "pointTowardsX:y:",			10, 10],
		["--"],
		["go to x:%n y:%n",						" ", 1, "gotoX:y:"],
		["go to %m.location",				" ", 1, "gotoSpriteOrMouse:",		"mouse-pointer"],
		["glide %n secs to x:%n y:%n",			" ", 1, "glideSecs:toX:y:elapsed:from:"],
		["--"],
		["change x by %n",						" ", 1, "changeXposBy:",			10],
		["set x to %n",							" ", 1, "xpos:",					0],
		["change y by %n",						" ", 1, "changeYposBy:",			10],
		["set y to %n",							" ", 1, "ypos:",					0],
		["--"],
		["if on edge, bounce",					" ", 1, "bounceOffEdge"],
		["-"],
		["set rotation style %m.rotationStyle",	" ", 1, "setRotationStyle", 		"left-right"],
		["-"],
		["make %m.draggable",					" ", 1, "makeDraggable",			"draggable"],
		["draggable?",							"b", 1, "draggable"],
		["--"],
		["x position",							"r", 1, "xpos"],
		["y position",							"r", 1, "ypos"],
		["direction",							"r", 1, "heading"],
		["rotation style",						"r", 1, "rotationStyle"],
		
		// stage motion
		["EXPERIMENTAL (WIP)",					"h", 101, "experimentfakeprim"],
		["scroll right %n",						" ", 101, "scrollRight",		10],
		["scroll up %n",						" ", 101, "scrollUp",			10],
		["align scene %m.scrollAlign",			" ", 101, "scrollAlign",		'bottom-left'],
		["x scroll",							"r", 101, "xScroll"],
		["y scroll",							"r", 101, "yScroll"],

		// looks
		["say %s for %n secs",					" ", 2, "say:duration:elapsed:from:",	"Hello!", 2],
		["say %s",								" ", 2, "say:",							"Hello!"],
		["think %s for %n secs",				" ", 2, "think:duration:elapsed:from:", "Hmm...", 2],
		["think %s",							" ", 2, "think:",						"Hmm..."],
		["-"],
		["show",								" ", 2, "show"],
		["hide",								" ", 2, "hide"],
		["visible?",							"b", 2, "visible"],
		["-"],
		["switch costume to %m.costume",		" ", 2, "lookLike:",				"costume1"],
		["next costume",						" ", 2, "nextCostume"],
		["switch backdrop to %m.backdrop",		" ", 2, "startScene", 				"backdrop1"],
		["-"],
		["change %m.effect effect by %n",		" ", 2, "changeGraphicEffect:by:",	"color", 25],
		["set %m.effect effect to %n",			" ", 2, "setGraphicEffect:to:",		"color", 0],
		["%m.effect effect",					"r", 2, ":effect",					"color"],
		["clear graphic effects",				" ", 2, "filterReset"],
		["-"],
		["change size by %n",					" ", 2, "changeSizeBy:",	 		10],
		["set size to %n%",						" ", 2, "setSizeTo:", 				100],
		["-"],
		["go to front",							" ", 2, "comeToFront"],
		["go back %n layers",					" ", 2, "goBackByLayers:", 			1],
		["-"],
		["costume name",						"r", 2, "costumeName"],
		["costume #",							"r", 2, "costumeIndex"],
		["backdrop name",						"r", 2, "sceneName"],
		["size",								"r", 2, "scale"],

		// stage looks
		["switch backdrop to %m.backdrop",			" ", 102, "startScene", 			"backdrop1"],
		["switch backdrop to %m.backdrop and wait", " ", 102, "startSceneAndWait",		"backdrop1"],
		["next backdrop",							" ", 102, "nextScene"],
		["-"],
		["change %m.effect effect by %n",		" ", 102, "changeGraphicEffect:by:",	"color", 25],
		["set %m.effect effect to %n",			" ", 102, "setGraphicEffect:to:",		"color", 0],
		["%m.effect effect",					"r", 102, ":effect",					"color"],
		["clear graphic effects",				" ", 102, "filterReset"],
		["-"],
		["backdrop name",						"r", 102, "sceneName"],
		["backdrop #",							"r", 102, "backgroundIndex"],
		["-"],
		["hide all sprites",					" ", 102, "hideAll"],

		// sound
		["play sound %m.sound",					" ", 3, "playSound:",						"pop"],
		["play sound %m.sound until done",		" ", 3, "doPlaySoundAndWait",				"pop"],
		["stop all sounds",						" ", 3, "stopAllSounds"],
		["-"],
		["play drum %d.drum for %n beats",		" ", 3, "playDrum",							1, 0.25],
		["rest for %n beats",					" ", 3, "rest:elapsed:from:",				0.25],
		["-"],
		["play note %d.note for %n beats",		" ", 3, "noteOn:duration:elapsed:from:",	60, 0.5],
		["set instrument to %d.instrument",		" ", 3, "instrument:",						1],

		["-"],
		["change volume by %n",					" ", 3, "changeVolumeBy:",					-10],
		["set volume to %n%",					" ", 3, "setVolumeTo:", 					100],
		["volume",								"r", 3, "volume"],
		["-"],
		["change tempo by %n",					" ", 3, "changeTempoBy:",					20],
		["set tempo to %n bpm",					" ", 3, "setTempoTo:",						60],
		["tempo",								"r", 3,  "tempo"],
		["-"],
		["internal volume",						"r", 3, "internalVolume"],
		["length of sound %m.sound in seconds",	"r", 3, "lengthOfSound:",					"pop"],

		// pen
		["clear",								" ", 4, "clearPenTrails"],
		["-"],
		["stamp",								" ", 4, "stampCostume"],
		["-"],
		["pen down",							" ", 4, "putPenDown"],
		["pen up",								" ", 4, "putPenUp"],
		["pen down?",							"b", 4, "isPenDown"],
		["-"],
		["set pen color to %c",					" ", 4, "penColor:"],
		["change pen color by %n",				" ", 4, "changePenHueBy:"],
		["set pen color to %n",					" ", 4, "setPenHueTo:", 		0],
		["pen hue",								"r", 4, "penHue"],
		["-"],
		["change pen shade by %n",				" ", 4, "changePenShadeBy:"],
		["set pen shade to %n",					" ", 4, "setPenShadeTo:",		50],
		["pen shade",							"r", 4, "penShade"],
		["-"],
		["change pen size by %n",				" ", 4, "changePenSizeBy:",		1],
		["set pen size to %n",					" ", 4, "penSize:", 			1],
		["pen size",							"r", 4, "penSize"],
		["-"],

		// stage pen
		["clear",								" ", 104, "clearPenTrails"],

		// triggers
		["when @greenFlag clicked",				"h", 5, "whenGreenFlag"],
		["when %m.key key pressed",				"h", 5, "whenKeyPressed", 		"space"],
		["when this sprite clicked",			"h", 5, "whenClicked"],
		["when backdrop switches to %m.backdrop", "h", 5, "whenSceneStarts", 	"backdrop1"],
		["--"],
		["when %m.triggerSensor > %n",			"h", 5, "whenSensorGreaterThan", "loudness", 10],
		["--"],
		["when I receive %m.broadcast",			"h", 5, "whenIReceive",			""],
		["wait until I receive %m.broadcast",	" ", 5, "waitUntilIReceive:",	"message1"],
		["repeat until I receive %m.broadcast",	"c", 5, "repeatUntilIReceive:",	"message1"],
		["-"],
		["broadcast %m.broadcast",				" ", 5, "broadcast:",			""],
		["broadcast %m.broadcast and wait",		" ", 5, "doBroadcastAndWait",	""],

		// control - sprite
		["wait %n secs",						" ", 6, "wait:elapsed:from:",	1],
		["-"],
		["repeat %n",							"c", 6, "doRepeat", 10],
		["forever",								"cf",6, "doForever"],
		["-"],
		["if %b then",							"c", 6, "doIf"],
		["if %b then",							"e", 6, "doIfElse"],
		["for each %m.var in %n",				"c", 6, "doForLoop", "v", 10],
		["while %b",							"c", 6, "doWhile"],
		["all at once",							"c", 6, "warpSpeed"],
		["wait until %b",						" ", 6, "doWaitUntil"],
		["repeat until %b",						"c", 6, "doUntil"],
		["-"],
		["stop %m.stop",						"f", 6, "stopScripts", "all"],
		["-"],
		["when I start as a clone",				"h", 6, "whenCloned"],
		["create clone of %m.spriteOnly",		" ", 6, "createCloneOf"],
		["delete this clone",					"f", 6, "deleteClone"],
		["clone count",							"r", 6, "cloneCount"],
		["-"],
		["noop",								"r", 99, "COUNT"],
		["counter",								"r", 6, "COUNT"],
		["clear counter",						" ", 6, "CLR_COUNT"],
		["incr counter",						" ", 6, "INCR_COUNT"],

		// control - stage
		["wait %n secs",						" ", 106, "wait:elapsed:from:",	1],
		["-"],
		["repeat %n",							"c", 106, "doRepeat", 10],
		["forever",								"cf",106, "doForever"],
		["-"],
		["if %b then",							"c", 106, "doIf"],
		["if %b then",							"e", 106, "doIfElse"],
		["for each %m.var in %n",				"c", 106, "doForLoop", "v", 10],
		["while %b",							"c", 106, "doWhile"],
		["all at once",							"c", 106, "warpSpeed"],
		["wait until %b",						" ", 106, "doWaitUntil"],
		["repeat until %b",						"c", 106, "doUntil"],
		["-"],
		["stop %m.stop",						"f", 106, "stopScripts", "all"],
		["-"],
		["create clone of %m.spriteOnly",		" ", 106, "createCloneOf"],
		["clone count",							"r", 106, "cloneCount"],
		["-"],
		["noop",								"r", 99, "COUNT"],
		["counter",								"r", 106, "COUNT"],
		["clear counter",						" ", 106, "CLR_COUNT"],
		["incr counter",						" ", 106, "INCR_COUNT"],

		// sensing
		["touching %m.touching?",				"b", 7, "touching:",			""],
		["touching color %c?",					"b", 7, "touchingColor:"],
		["color %c is touching %c?",			"b", 7, "color:sees:"],
		["distance to %m.spriteOrMouse",		"r", 7, "distanceTo:",			""],
		["distance to x: %n y: %n",				"r", 7, "distanceToX:y:",		10, 10],
		["-"],
		["ask %s and wait",						" ", 7, "doAsk", 				"What's your name?"],
		["answer",								"r", 7, "answer"],
		["-"],
		["sprite name",							"r", 7, "spriteName"],
		["-"],
		["key %m.key pressed?",					"b", 7, "keyPressed:",			"space"],
		["mouse down?",							"b", 7, "mousePressed"],
		["mouse x",								"r", 7, "mouseX"],
		["mouse y",								"r", 7, "mouseY"],
		["-"],
		["loudness",							"r", 7, "soundLevel"],
		["-"],
		["video %m.videoMotionType on %m.stageOrThis", "r", 7, "senseVideoMotion", "motion"],
		["turn video %m.videoState",			" ", 7, "setVideoState",			"on"],
		["set video transparency to %n%",		" ", 7, "setVideoTransparency",		50],
		["-"],
		["timer",								"r", 7, "timer"],
		["reset timer",							" ", 7, "timerReset"],
		["-"],
		["%m.attribute of %m.spriteOrStage",	"r", 7, "getAttribute:of:"],
		["-"],
		["current %m.timeAndDate", 				"r", 7, "timeAndDate",			"minute"],
		["days since 2000", 					"r", 7, "timestamp"],
		["username",							"r", 7, "getUserName"],

		// stage sensing
		["ask %s and wait",						" ", 107, "doAsk", 				"What's your name?"],
		["answer",								"r", 107, "answer"],
		["-"],
		["key %m.key pressed?",					"b", 107, "keyPressed:",		"space"],
		["mouse down?",							"b", 107, "mousePressed"],
		["mouse x",								"r", 107, "mouseX"],
		["mouse y",								"r", 107, "mouseY"],
		["-"],
		["loudness",							"r", 107, "soundLevel"],
		["-"],
		["video %m.videoMotionType on %m.stageOrThis", "r", 107, "senseVideoMotion", "motion", "Stage"],
		["turn video %m.videoState",			" ", 107, "setVideoState",			"on"],
		["set video transparency to %n%",		" ", 107, "setVideoTransparency",	50],
		["-"],
		["timer",								"r", 107, "timer"],
		["reset timer",							" ", 107, "timerReset"],
		["-"],
		["%m.attribute of %m.spriteOrStage",	"r", 107, "getAttribute:of:"],
		["-"],
		["current %m.timeAndDate", 				"r", 107, "timeAndDate",		"minute"],
		["days since 2000", 					"r", 107, "timestamp"],
		["username",							"r", 107, "getUserName"],

		// operators
		["%n + %n",								"r", 8, "+",					"", ""],
		["%n - %n",								"r", 8, "-",					"", ""],
		["%n * %n",								"r", 8, "*",					"", ""],
		["%n / %n",								"r", 8, "/",					"", ""],
		["%n ^ %n",								"r", 8, "^",					"", ""],
		["-"],
		["bitwise %n %m.[and,or,xor,-,shift left,shift right] %n",					"r", 8, "computeBitwiseFunction:of:", 5, "and", 3],
		// Did the above to demonstrate how custom menu options will work...
		["-"],
		["pick random %n to %n",		"r", 8, "randomFrom:to:",		1, 10],
		["-"],
		["%s < %s",								"b", 8, "<",					"", ""],
		["%s ≤ %s",								"b", 8, "≤",					"", ""],
		["%s = %s",								"b", 8, "=",					"", ""],
		["%s ≠ %s",								"b", 8, "≠",					"", ""],
		["%s > %s",								"b", 8, ">",					"", ""],
		["%s ≥ %s",								"b", 8, "≥",					"", ""],
		["-"],
		["true",								"b", 8, "true"],
		["false",								"b", 8, "false"],
		["%n % chance of true",					"b", 8, ":%ChanceOfTrue",		"50"],
		["%s as boolean",						"b", 8, ":asBoolean",			"true"],
		["%s is %m.opType",						"b", 8, ":isType",				"5", "a number"],
		["case sensitive %s = %s",				"b", 8, "caseSensitive",		"meow", "Meow"],
		["if %b then %s else %s",				"r", 8, "if:then:else:"],
		["-"],
		["%b and %b",							"b", 8, "&"],
		["%b or %b",							"b", 8, "|"],
		["not %b",								"b", 8, "not"],
		["-"],
		["%n mod %n",							"r", 8, "%",					"", ""],
		["round %n",							"r", 8, "rounded", 				""],
		["-"],
		["%m.mathOp of %n",						"r", 8, "computeFunction:of:",	"sqrt", 9],
		["%m.constant",							"r", 8, "constant",				"pi"],

		//More Blocks 10
		["report %s",							"f", 10, "report",				""],
		["define temporary variables %s",		"c", 10, "doDefineVars",		"foo,bar,baz"],
		["get temporary variable %s",			"r", 10, "getDefinedVars",		"foo"],
		["set temporary variable %s to %s",		" ", 10, "setDefinedVars",		"foo", "0"],

		// variables
		["create variable %s for all sprites %b",			" ", 9, "addVariable"],
		["delete variable %s",								" ", 9, "removeVariable"],
		["set %m.var to %s",								" ", 9, SET_VAR],
		["change %m.var by %n",								" ", 9, CHANGE_VAR],
		["show variable %m.var",							" ", 9, "showVariable:"],
		["hide variable %m.var",							" ", 9, "hideVariable:"],
		["move %m.var to x: %n y: %n",						" ", 9, "move:toX:y:"],
		["set %m.var style to %m.varStyle",					" ", 9, "set:styleTo:"],
		["set %m.var color to %c",							" ", 9, "varSet:colorTo:"],
		["--"],
		["@cookie %s",										"R", 9, "cookieGetVariable"],
		["-"],
		["@cookie set cookie variable %s to %s",			" ", 9, "cookieSetVariable"],
		["@cookie change cookie variable %s by %n",			" ", 9, "cookieChangeVariable"],

		// lists
		["add %s to %m.list",								" ", 12, "append:toList:"],
		["-"],
		["delete %d.listDeleteItem of %m.list",				" ", 12, "deleteLine:ofList:"],
		["insert %s at %d.listItem of %m.list",				" ", 12, "insert:at:ofList:"],
		["replace item %d.listItem of %m.list with %s",		" ", 12, "setLine:ofList:to:"],
		["-"],
		["item %d.listItem of %m.list",						"r", 12, "getLine:ofList:"],
		["length of %m.list",								"r", 12, "lineCountOfList:"],
		["%m.list contains %s?",							"b", 12, "list:contains:"],
		["-"],
		["show list %m.list",								" ", 12, "showList:"],
		["hide list %m.list",								" ", 12, "hideList:"],
		["set %m.list color to %c",							" ", 12, "listSet:colorTo:"],
		
		//System 13
		["save %s to file %s",					" ", 13, "save:toFile:", "hello world", "file.txt"],
		["-"],
		["load text from file",					"R", 13, "loadTextFromFile"],
		["load text from line %n of file",		"R", 13, "loadTextFromLineOfFile"],
		["file contents",						"r", 13, "fileContents"],
		["--"],
		["load text file to list %m.list",		" ", 13, "loadTextFileToList:"],
		["export list %m.list to text file",	" ", 13, "exportList:toTextFile"],
		["--"],
		["open url %s",							" ", 13, "openUrl:", "http://www.google.com"],
		["read url %s",							"R", 13, "readUrl:", "http://www.google.com"],
		["read line %n of url %s",				"R", 13, "readLine:ofUrl:", "1", "http://www/google.com"],
		["-"],
		["internet connection?",				"b", 13, "internetConnection"],
		
		//Program 15
		["%m.screenMode mode",					" ", 15, ":mode", "fullscreen"],
		["fullscreen mode?",					"b", 15, "fullscreenMode"],
		["-"],
		["set cursor to %m.cursor",				" ", 15, "setCursorTo:", "normal"],
		["-"],
		/*["copy %s to clipboard",				" ", 15, "copy:toClipboard", "hello world"],
		["clipboard",							"r", 15, "clipboard"],*/
		["comment %s",							" ", 15, "inlineComment"],
		["comment %s",							"c", 15, "blockComment"],
		["-"],
		["%m.turbo turbo mode",					" ", 15, "toggleTurboMode",		"activate"],
		["turbo mode?",							"b", 15, "turboMode"],
		["-"],
		["set max. clone count to %n",			" ", 15, "setMaxCloneCount",	"300"],
		["max. clone count",					"r", 15, "maxCloneCount"],
		
		//Dialogs 14
		["dialog notify with title %s and message %s", " ", 14, "dialogNotify", "Well Done!", "Congratulations, you won!"],
		["dialog confirm with title %s and message %s", "b", 14, "dialogConfirm", "Are you sure?", "Are you sure you would like to continue?"],
		["dialog ask with title %s and message %s", "r", 14, "dialogAsk", "Info", "What's your name?"],
		["---"],
		["custom dialog %s %s %s %s %s %s %s %s %s", "R", 14, "customDialog"],
		["last custom dialog entry",			"r", 14, "lastCustomDialogEntry"],
		["-"],
		["title %s",							"r", 14, "customDialogTitle"],
		["text %s",								"r", 14, "customDialogText"],
		["%s line break %s",						"r", 14, "customDialogNewLine"],
		["-"],
		["%m.customDialogOptionType with options %s %s %s %s", "r", 14, "customDialogOptions", "checkboxes"],
		["%m.customDialogFieldType field with name %s and default input %s", "r", 14, "customDialogInputField", "string"],
		["-"],
		["buttons %s %s %s %s",					"r", 14, "customDialogButtons", "OK", "Cancel"],
		["-"],
		["close all dialogs",					" ", 14, "customDialogCloseAll"],
		
		
		//Strings 16
		["join %s %s",							"r", 16, "concatenate:with:",	"hello ", "world"],
		["letter %n of %s",						"r", 16, "letter:of:",			1, "world"],
		["letters %n to %n of %s",				"r", 16, "letters:to:of:",		1, 3, "world"],
		["length of %s",						"r", 16, "stringLength:",		"world"],
		["-"],
		["%s contains %s",						"b", 16, ":contains:",			"haystack", "needle"],
		["%m.stringAlter %s",					"r", 16, "alterString",			"uppercase", "meow"],
		["-"],
		["times %s is in %s",					"r", 16, "times:isIn:",			"a", "raincoat"],
		["replace letters %n to %n of %s with %s", "r", 16, "replaceBetween",	2, 4, "crust", "a"],
		["replace every %s in %s with %s",		"r", 16, "replaceEvery",			"m", "mat", "c"],
		["repeat %s %n times",					"r", 16, "repeat::times",		"do", 2],
		["-"],
		["ascii for %s",						"r", 16, "asciiFor:",			"A"],
		["ascii %n as string",					"r", 16, "ascii:asString",		"65"],
		
		//Websockets 17
		["connect to ip %s port %s",			" ", 17, "websocketConnect",	"127.0.0.0", "80"],
		["disconnect",							" ", 17, "websocketDisconnect"],
		["connection status",					"R", 17, "websocketStatus"],
		["-"],
		["send %s",								" ", 17, "websocketSend",		""],
		["when I recieve %s",					"h", 17, "websocketRecieve",	""],
		
		//Color 18
		["color at pixel x: %n y: %n",			"r", 18, "colorAtPixel",		0, 0],
		["color %c",							"r", 18, "colorColorInput"],
		["color r: %n g: %n b: %n",				"r", 18, "colorRGB",			255, 255, 255],
		["color h: %n s: %n l: %n",				"r", 18, "colorHSL",			200, 100, 50],
		["%c %m.colorType",						"r", 18, "colorType",			, "hue"],
		["-"],
		["color %c lighter by %n",				"r", 18, "colorLighter",		0x39bf93, 10],
		["mix %c and %c with ratio %n : %n",	"r", 18, "colorMix",			0x000000, 0xFFFFFF, 50, 50],
		["-"],
		["%c = %c",								"b", 18, "color="],
		["%c negated",							"r", 18, "colorNegated"],
		["-"],
		["%c as hex",							"r", 18, "colorAsHex"],
		["hex %s as color",						"r", 18, "colorHexAsColor",		"#0099ff"],

		// obsolete blocks from Scratch 1.4 that may be used in older projects
		["play drum %n for %n beats",			" ", 98, "drum:duration:elapsed:from:", 1, 0.25], // Scratch 1.4 MIDI drum
		["set instrument to %n",				" ", 98, "midiInstrument:", 1],
		["loud?",								"b", 98, "isLoud"],

		// obsolete blocks from Scratch 1.4 that are converted to new forms (so should never appear):
		["abs %n",								"r", 98, "abs"],
		["sqrt %n",								"r", 98, "sqrt"],
		["stop script",							"f", 98, "doReturn"],
		["stop all",							"f", 98, "stopAll"],
		["switch to background %m.costume",		" ", 98, "showBackground:", "backdrop1"],
		["next background",						" ", 98, "nextBackground"],
		["forever if %b",						"cf",98, "doForeverIf"],

		// testing and experimental control prims

		// stage motion (scrolling)

		// other obsolete blocks from alpha/beta
		["user id",								"r", 99, "getUserId"],

	];

	public static var extensionSpecs:Array = ["when %m.booleanSensor", "when %m.sensor %m.lessMore %n", "sensor %m.booleanSensor?", "%m.sensor sensor value", "turn %m.motor on for %n secs", "turn %m.motor on", "turn %m.motor off", "set %m.motor power to %n", "set %m.motor2 direction to %m.motorDirection", "when distance %m.lessMore %n", "when tilt %m.eNe %n", "distance", "tilt"];

}}
