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

// ColorPrims.as
// NoMod-Programming, May 2016
//
// Scratch color primitives.

package primitives {
	import blocks.*;
	import util.*;

	import flash.display.*;
	import flash.geom.*;
	import flash.utils.Dictionary;

	import interpreter.*;

	import scratch.*;

public class ColorPrims {

	private var app:Scratch;
	private var interp:Interpreter;

	public function ColorPrims(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;
	}

	public function addPrimsTo(primTable:Dictionary, specialTable:Dictionary):void {
		primTable['colorAtPixel']		= primGetColor;
		primTable['colorAsHex']			= primColorAsHex;
		primTable['colorHexAsColor']	= primHexAsColor;
		primTable['color=']				= function(b:*):Boolean {return uint(interp.numarg(b[0])) == uint(interp.numarg(b[1]));};
		primTable['colorNegated']		= primNegateColor;
		primTable['colorMix']			= primColorMix;
		primTable['colorColorInput']	= function(b:*):ScratchColor {return new ScratchColor(interp.numarg(b[0]))};
		primTable['colorRGB']			= function(b:*):ScratchColor {var r:uint = interp.numarg(b[0]); var g:uint = interp.numarg(b[1]); var b:* = interp.numarg(b[2]); return new ScratchColor(uint(255 << 24| r << 16 | g << 8 | b))};
		primTable['colorLighter']		= function(b:*):ScratchColor {var scaleColor:uint = interp.numarg(b[0]); var percent:int = interp.numarg(b[1]); return new ScratchColor(Color.scaleBrightness(scaleColor, percent))};
		primTable['colorType']			= primColorType;
		primTable['colorHSL']			= function(b:*):ScratchColor {return new ScratchColor(Color.fromHSV(interp.numarg(b[0]),interp.numarg(b[1]),interp.numarg(b[2])))}
	}


	private function primColorType(b:Array):* {
		var color1:uint = interp.numarg(b[0]);
		var type: * = b[1];
		switch (type) {
			case "hue": return (Color.rgb2hsv(color1))[0];
			case "saturation": return (Color.rgb2hsv(color1))[1];
			case "lightness": return (Color.rgb2hsv(color1))[2];
			case "red": return ((color1 >> 16) & 255);
			case "green": return ((color1 >> 8) & 255);
			case "blue": return (color1 & 255);
		}
		return '';
	}

	private function primColorMix(b:Array):* {
		var color1: int = (interp.numarg(b[0]));
		var color2: int = (interp.numarg(b[1]));
		var returnColor: uint = (Color.mixRGB(color1,color2,interp.numarg(b[2])/(interp.numarg(b[3]) * 2))) | (255 << 24);
		return new ScratchColor(returnColor);
	}

	private function primNegateColor(b:Array):* {
		var color1:uint = (interp.numarg(b[0]));
		var hexVal:uint = (color1 * -1) + 4294967296;
		hexVal = hexVal ? hexVal | 0xFF000000 : 0xFFFFFFFF;
		return new ScratchColor(hexVal);
	}

	private function primColorAsHex(b:Array):* {
		var hexVal:uint = (interp.numarg(b[0]));
		hexVal = hexVal ? hexVal | 0xFF000000 : 0xFFFFFFFF;
		var stringHex:String = hexVal.toString(16);
		return "#" + stringHex;
	}

	private function primHexAsColor(b:Array):* {
		 var hex:String = String(b[0]);
		 if (((hex.length) > 1) && (hex.charAt(0) === "#")) {
		 	return new ScratchColor(Number('0x' + hex.slice(1,(hex.length))));
		 }
		 return '';
	}

	private function rgbtohex(red:Number, green:Number, blue:Number):* {
		var intVal:int = red << 16 | green << 8 | blue;
		var hexVal:String = intVal.toString(16);
		hexVal = "#" + (hexVal.length < 6 ? "0" + hexVal : hexVal);
		return hexVal;
	}


	//Color picker
	private var onePixel:BitmapData = new BitmapData(1, 1);

	private function pixelColorAt(x:int, y:int):ScratchColor {
		var m:Matrix = new Matrix();
		m.translate(-x, -y);
		onePixel.fillRect(onePixel.rect, 0);
		if (app.isIn3D) app.stagePane.visible = true;
		onePixel.draw(app, m);
		if (app.isIn3D) app.stagePane.visible = false;
		var x:int = onePixel.getPixel32(0, 0);
		return new ScratchColor(x ? x | 0xFF000000 : 0xFFFFFFFF); // alpha is always 0xFF
	}


	private function primGetColor(b:Array):* {
		var colorX:int = interp.numarg(b[0]);
		var colorY:int = interp.numarg(b[1]);
		return (pixelColorAt(Math.round(colorX + 240), Math.round(180 - colorY)));
	}
}}
