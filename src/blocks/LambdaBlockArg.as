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

// LambdaBlockArg.as
// NoMod-Programming, June 2016
//
// A LambdaBlockArg simply reports the block, allowing to a lambda to be constructed

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

public class LambdaBlockArg extends BlockArg {
	
	public var block:Block = null;

	public function LambdaBlockArg(type:String, color:int) {
		super(type, color);
		if (color == -1) { // copy for clone; omit graphics
			return;
		}
		base = new BlockShape(BlockShape.NumberShape, 0x545454);
		base.setWidthAndTopHeight(25, Block.argTextFormat.size + 5);
		base.filters = blockArgFilters();
		isEditable = false;
		addChild(base);
		base.redraw();
	}

	public static function blockArgFilters():Array {
		// filters for BlockArg outlines
		var f:BevelFilter = new BevelFilter(1);
		f.blurX = f.blurY = 2;
		f.highlightAlpha = 0.3;
		f.shadowAlpha = 0.6;
		f.angle = 240;  // change light angle to show indentation
		return [f];
	}

	override public function setArgValue(value:*, label:* = null):void {
		return
	}

	public function fixLayout():void {
		if (block != null) {
		block.x = 3;
		block.y = 3;
		base.setWidthAndTopHeight(block.width + 6, block.height + 6);
		} else {
		base.setWidthAndTopHeight(25, Block.argTextFormat.size + 5);
		this.width = 25;
		this.height = Block.argTextFormat.size + 5;
		}
		base.redraw();
		if (parent is Block) Block(parent).fixExpressionLayout();
		if (parent is Block) Block(parent).topBlock().fixStackLayout();
	}

	public function setLambda(b:Block):void {
		if (block != null) block.parent.removeChild(block);
		block = b;
		addChild(b);
		fixLayout();
	}

	public function insertBlock(b:Block):void {
		if (block != null) block.parent.removeChild(block);
		block = b;
		addChild(b);
		fixLayout();
	}

	public function removeBlock(b:Block):void {
		block = null;
		b.parent.removeChild(b);
		fixLayout();
	}

	public function replaceArgWithBlock(oldArg:DisplayObject, b:Block, pane:DisplayObjectContainer):void {
		if (block != null) block.parent.removeChild(block);
		block = b;
		addChild(b);
		fixLayout();
	}

	override public function getArgValue():* {
		return block;
	}

}}