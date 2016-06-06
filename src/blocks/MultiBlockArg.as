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
// A MultiBlockArg is a subclass of argmorph that is an array of argmorphs
// which can be added to or removed from by the user

package blocks {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BevelFilter;
	import flash.text.*;
	import blocks.*;
	import scratch.BlockMenus;
	import translation.Translator;
	import util.Color;
	import flash.geom.Point;
	import ui.ProcedureSpecEditor;
	import uiwidgets.*;
	import watchers.ListWatcher;

public class MultiBlockArg extends BlockArg {
	
	public var fields:Array = [];
	protected var addIcon:Shape;
	protected var removeIcon:Shape;


	public function MultiBlockArg(type:String, color:int) {
		super(type, color);
		if (color == -1) { // copy for clone; omit graphics
			return;
		}
		var c:int = Color.scaleBrightness(color, 0.92);
		base = new BlockShape(BlockShape.RectShape, c);
		this.menuName = 'colorPicker';
		addEventListener(MouseEvent.MOUSE_DOWN, invokeMenu);
		base.setWidthAndTopHeight(30, Block.argTextFormat.size + 6);
		base.setColor(color & 0xFFFFFF);
		base.filters = [];
		isEditable = true;
		addChild(base);
		base.redraw();
		addIcon = new Shape();
			var g:Graphics = addIcon.graphics;
			g.beginFill(0, 0.6); // darker version of base color
			g.lineTo(4,3.5);
			g.lineTo(0,7);
			g.lineTo(0,0);
			g.endFill();
			addIcon.y = 5;
		addChild(addIcon);
		removeIcon = new Shape();
			g = removeIcon.graphics;
			g.beginFill(0, 0.6); // darker version of base color
			g.moveTo(4,0);
			g.lineTo(0,3.5);
			g.lineTo(4,7);
			g.lineTo(4,0)
			g.endFill();
			removeIcon.y = 5;
		addField("foo");
	}

	override public function setArgValue(value:*, label:* = null):void {
		argValue = value;
		for each (var oldArg:* in fields) {
			oldArg.parent.removeChild(oldArg);
		}
		fields = [];
		if (value.length > 0) {
			for each (var labelArg:* in value) {
				addField(labelArg);
			}
		}
		fixLayout();
	}

	public function fixLayout():void {
		var w:int = 0;
		if (fields.length > 0) {
		var maxH:int = 0;
		var argField:*;
		for each (argField in fields) {
			maxH = Math.max(maxH,argField.height)
		}
		base.height = maxH + 2;
		for each (argField in fields) {
			argField.x = w;
			argField.y = base.height / 2 - (argField.height / 2); // Center in owner
			w = w + argField.base.w + 3;
			}
		}
		w = Math.max(14, (addIcon.width + ((removeIcon.parent != null) ? removeIcon.width : 0) + 7 + w));
		addIcon.x = w - addIcon.width - 3;
		y = base.height / 2 - (addIcon.height / 2);
		addIcon.y = y;
		if (removeIcon.parent != null) {
		removeIcon.y = addIcon.y;
		removeIcon.x = w - addIcon.width - removeIcon.width - 4;
		}
		base.setWidth(w);
		base.redraw();
		if (parent is Block) Block(parent).fixExpressionLayout();
		if (parent is MultiBlockArg) MultiBlockArg(parent).fixLayout();
		// Since this gets called when any of the args change, just set the argvalue here
		argValue = [];
	}

	private function invokeMenu(evt:MouseEvent):void {
		if (fields.length > 0) {
		for each (var argField:* in fields) {
			if (argField is BlockArg) {
				if (argField.hitTestPoint(evt.stageX, evt.stageY, true)) {
					argField.startEditing(evt);
					}
				}
			}
		}
		if (addIcon.hitTestPoint(evt.stageX, evt.stageY)) {
			addField();
		}
		if (removeIcon.hitTestPoint(evt.stageX, evt.stageY) && (removeIcon.parent != null)) {
			removeField();
		}
		evt.stopImmediatePropagation();
	}

	private function addField(value:String = null):void {
		var b:BlockArg = new BlockArg(type == "q" ? "s" : "n", base.color, true);
		if (value) b.setArgValue(value);
		// Make sure to update arrows
		fields.push(b);
		if (fields.length > 0) {
			addChild(removeIcon);
		}
		addChild(b);
		fixLayout();
	}

	public function replaceArgWithBlock(oldArg:DisplayObject, b:Block, pane:DisplayObjectContainer):void {
		var i:int = fields.indexOf(oldArg);
		if (i < 0) return;

		// remove the old argument
		oldArg.parent.removeChild(oldArg);
		fields[i] = b;
		addChild(b);
		fixLayout();

		if (oldArg is Block) {
			// leave old block in pane
			var o:Block = Block(parent).owningBlock();
			var p:Point = pane.globalToLocal(o.localToGlobal(new Point(o.width + 5, (o.height - oldArg.height) / 2)));
			oldArg.x = p.x;
			oldArg.y = p.y;
			pane.addChild(oldArg);
		}
		Block(parent).topBlock().fixStackLayout();
	}

	public function removeBlock(b:Block):void {
		var i:int = fields.indexOf(b);
		b.parent.removeChild(b);
		if (i < 0) return;

		var newBlock:BlockArg = new BlockArg(type == "q" ? "s" : "n", base.color, true);
		fields[i] = newBlock;
		addChild(fields[i]);
		fixLayout();
		Block(parent).topBlock().fixStackLayout();
	}

	override public function getArgValue():* {
		var newArgValue:Array = [];
		if (fields.length > 0) {
			for each (var argField:* in fields) {
				newArgValue.push((argField as BlockArg).argValue);
				}
			}
		argValue = newArgValue;
		return newArgValue;
	}

	private function removeField():void {
		var b:* = fields.pop();
		if (fields.length < 1) {
			removeChild(removeIcon);
		}
		b.parent.removeChild(b);
		if (b is Block) {
			// leave old block in pane
			var o:Block = Block(parent).owningBlock();
			var p:Point = Scratch.app.scriptsPane.globalToLocal(o.localToGlobal(new Point(o.width + 5, (o.height - b.height) / 2)));
			b.x = p.x;
			b.y = p.y;
			Scratch.app.scriptsPane.addChild(b);
		}
		fixLayout();
	}

	override public function startEditing(evt:*):void {
		invokeMenu(evt);
	}

}}