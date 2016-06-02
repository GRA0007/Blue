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

// BlockArg.as
// John Maloney, August 2009
//
// A MultiBlockArg is 

package blocks {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BevelFilter;
	import flash.text.*;
	import scratch.BlockMenus;
	import translation.Translator;
	import util.Color;
	import ui.ProcedureSpecEditor;
	import uiwidgets.*;
	import watchers.ListWatcher;

public class MultiBlockArg extends BlockArg {
	
	public var argType:String;
	public var fields:Array;


	public function MultiBlockArg(type:String, color:int) {
		this.type = type;
		fields = [];
		super(type, color);
		if (color == -1) { // copy for clone; omit graphics
			return;
		}
		var c:int = Color.scaleBrightness(color, 0.92);
		if (type == 'q') {
			// Multi string inputs
			base = new BlockShape(BlockShape.RectShape, c);
			addEventListener(MouseEvent.MOUSE_DOWN, invokeMenu);
		} else {
			return;
		}
	}

	override public function labelOrNull():* { return fields ? fields : [] }

	override public function setArgValue(value:*, label:* = null):void {
		// if provided, labels are displayed in fields, rather than 
		// the values. This is used for sprite names and to support
		// translation.
		argValue = [];
		if (fields != null) {
			for (var i:int = 0; i <= value.length; i++) {
				addField();
				fields[i].setArgValue(value[i]);
			}
			textChanged(null);
			for (i = 0; i <= fields.length; i++) {
				argValue.push(fields[i] is Block ? fields[i] : fields.argValue) // PLEASE DON'T NEST THESE :P
			}
			return;
		}
		base.redraw();
	}

	private function invokeMenu(evt:MouseEvent):void {
		if ((menuIcon != null) && (evt.localX <= menuIcon.x)) return;
		addField();
	}

	private function addField():void {
		var b:BlockArg = new BlockArg(type == "q" ? "s" : "n", base.color);
		// Make sure to update arrows
		fields.push(b);
		addChild(b);
	}

}}