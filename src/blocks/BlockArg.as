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
// A BlockArg represents a Block argument slot. Some BlockArgs, contain
// a text field that can be edited by the user. Others (e.g. booleans)
// are immutable. In either case, they be replaced by a reporter block
// of the right type. That is, dropping a reporter block onto a BlockArg
// inside a block causes the BlockArg to be replaced by the reporter.
// If a reporter is removed, a BlockArg is added to the block.
//
// To create a custom BlockArg widget such as a color picker, make a
// subclass of BlockArg for the widget. Your constructor is responsible
// for adding child display objects and setting its width and height.
// The widget must initialize argValue and update it as the user
// interacts with the widget. In some cases, the widget may need to
// override the setArgValue() method. If the widget can accept dropped
// arguments, it should set base to a BlockShape to support drag feedback.

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

public class BlockArg extends Sprite {

	public static const epsilon:Number = 1 / 4294967296;
	public static const NT_NOT_NUMBER:uint = 0;
	public static const NT_FLOAT:uint = 1;
	public static const NT_INT:uint = 2;

	public var type:String;
	public var base:BlockShape;
	public var argValue:* = '';
	public var numberType:uint = NT_NOT_NUMBER;
	public var isEditable:Boolean;
	public var field:TextField;
	public var menuName:String;
	public var menuItems:Array;

	protected var menuIcon:Shape;

	// BlockArg types:
	//	b - boolean (pointed)
	//	c - color selector
	//	d - number with menu (rounded w/ menu icon)
	//	m - string with menu (rectangular w/ menu icon)
	//	n - number (rounded)
	//	s - string (rectangular)
	//	none of the above - custom subclass of BlockArg
	public function BlockArg(type:String, color:int, editable:Boolean = false, menuName:String = '') {
		this.type = type;

		if (color == -1) { // copy for clone; omit graphics
			if ((type == 'd') || (type == 'n')) numberType = NT_FLOAT;
			return;
		}
		var c:int = Color.scaleBrightness(color, 0.92);
		if (type == 'b') {
			base = new BlockShape(BlockShape.BooleanShape, c);
			argValue = false;
		} else if (type == 'c') {
			base = new BlockShape(BlockShape.RectShape, c);
			this.menuName = 'colorPicker';
			addEventListener(MouseEvent.MOUSE_DOWN, invokeMenu);
		} else if (type == 'd') {
			base = new BlockShape(BlockShape.NumberShape, c);
			numberType = NT_FLOAT;
			if (menuName.charAt(0) == '[') {
					this.menuItems = menuName.slice(1,menuName.length - 1).split(',');
			} else {
					this.menuName = menuName;
			}
			addEventListener(MouseEvent.MOUSE_DOWN, invokeMenu);
		} else if (type.charAt(0) == 'm') {
			base = new BlockShape(BlockShape.RectShape, c);
			if (menuName.charAt(0) == '[') {
					this.menuItems = menuName.slice(1,menuName.length - 1).split(',');
			} else {
					this.menuName = menuName;
			}
			addEventListener(MouseEvent.MOUSE_DOWN, invokeMenu);
		} else if (type == 'n') {
			base = new BlockShape(BlockShape.NumberShape, c);
			numberType = NT_FLOAT;
			argValue = 0;
		} else if (type == 's') {
			base = new BlockShape(BlockShape.RectShape, c);
		}else if (type == 'f') {
			base = new BlockShape(BlockShape.RectShape, c);
		}else if (type == 'k') {
			base = new BlockShape(BlockShape.CmdShape, c);
			base.setWidthAndTopHeight(40, 30);
		} else {
			// custom type; subclass is responsible for adding
			// the desired children, setting width and height,
			// and optionally defining the base shape
			return;
		}

		if (type == 'c') {
			base.setWidthAndTopHeight(13, 13);
			setArgValue(Color.random());
		} else {
			base.setWidthAndTopHeight(30, Block.argTextFormat.size + 6); // 15 for normal arg font
		}
		base.filters = blockArgFilters();
		addChild(base);

		if ((type == 'd') || (type.charAt(0) == 'm')) { // add a menu icon
			menuIcon = new Shape();
			var g:Graphics = menuIcon.graphics;
			g.beginFill(0, 0.6); // darker version of base color
			g.lineTo(7, 0);
			g.lineTo(3.5, 4);
			g.lineTo(0, 0);
			g.endFill();
			menuIcon.y = 5;
			addChild(menuIcon);
		}

		if ((editable || numberType || (type.charAt(0) == 'm') )&& !(type == 'f')) { // add a string field
			field = makeTextField();
			if ((type == 'm') && !editable) field.textColor = 0xFFFFFF;
			else base.setWidthAndTopHeight(30, Block.argTextFormat.size + 5); // 14 for normal arg font
			field.text = numberType ? '10' : '';
			if (numberType) field.restrict = '0-9e.\\-'; // restrict to numeric characters
			if (editable) {
				base.setColor(0xFFFFFF); // if editable, set color to white
				isEditable = true;
			}
			field.addEventListener(FocusEvent.FOCUS_OUT, stopEditing);
			addChild(field);
			textChanged(null);
		}else if(type == 'f'){
			field = makeTextArea();
			if ((type == 'm') && !editable) field.textColor = 0xFFFFFF;
			else base.setWidthAndTopHeight(30, Block.argTextFormat.size + 5); // 14 for normal arg font
			field.text = numberType ? '10' : '';
			if (numberType) field.restrict = '0-9e.\\-'; // restrict to numeric characters
			if (editable) {
				base.setColor(0xFFFFFF); // if editable, set color to white
				isEditable = true;
			}
			field.addEventListener(FocusEvent.FOCUS_OUT, stopEditing);
			addChild(field);
			textChanged(null);
		} else {
			base.redraw();
		}
	}

	public function labelOrNull():* { return field ? field.text : null }

	public function setArgValue(value:*, label:* = null):void {
		// if provided, label is displayed in field, rather than the value
		// this is used for sprite names and to support translation
		argValue = value;
		if (field != null) {
			var s:String = (value == null) ? '' : value;
			field.text = (label) ? label : s;
			if (menuName && !label && (value is String) && (value != '')) {
				if (BlockMenus.shouldTranslateItemForMenu(value, menuName)) {
					// Translate menu value
					field.text = Translator.map(value);
				}
			}
			textChanged(null);
			argValue = value; // set argValue after textChanged()
			return;
		}
		if (type == 'c') base.setColor(int(argValue) & 0xFFFFFF);
		base.redraw();
	}

	public function startEditing(evt:*):void {
		if (isEditable) {
			field.type = TextFieldType.INPUT;
			field.selectable = true;
			if (field.text.length == 0) field.text = '  ';
			field.setSelection(0, field.text.length);
			root.stage.focus = field;
		}
	}

	protected function stopEditing(ignore:*):void {
		field.type = TextFieldType.DYNAMIC;
		field.selectable = false;
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

	public function getArgValue():* {
		return argValue;
	}

	protected function makeTextField():TextField {
		var tf:TextField = new TextField();
		var offsets:Array = argTextInsets(type);
		tf.x = offsets[0];
		tf.y = offsets[1];
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.defaultTextFormat = Block.argTextFormat;
		tf.selectable = false;
		tf.addEventListener(Event.CHANGE, textChanged);
		return tf;
	}
	protected function makeTextArea():TextField {
		var tf:TextField = new TextField();
		var offsets:Array = argTextInsets(type);
		tf.x = offsets[0];
		tf.y = offsets[1];
		tf.multiline = true;
		//tf.wordWrap = true;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.defaultTextFormat = Block.argTextFormat;
		tf.selectable = false;
		tf.addEventListener(Event.CHANGE, textChanged);
		return tf;
	}

	protected function argTextInsets(type:String = ''):Array {
		if (type == 'b') return [5, 0];
		return numberType ? [3, 0] : [2, -1];
	}

	protected function textChanged(evt:*):void {
		argValue = field.text;
		if (numberType) {
			// optimization: coerce to a number if possible
			var n:Number = Number(argValue);
			if (!isNaN(n)) {
				argValue = n;

				// For number arguments that are integers AND do NOT contain a decimal point, mark them as an INTEGER (used by pick random)
				numberType = (field.text.indexOf('.') == -1 && n is int) ? NT_INT : NT_FLOAT;
			}
			else
				numberType = NT_FLOAT;
		}
		// fix layout:
		var padding:int = (type == 'n') ? 3 : 0;
		if (type == 'b') padding = 8;
		if (menuIcon != null) padding = (type == 'd') ? 10 : 13;
		var w:int = Math.max(14, field.textWidth + 6 + padding);
		if (menuIcon) menuIcon.x = w - menuIcon.width - 3;
		base.setWidth(w);
		if(type== 'f'){
			base.setWidthAndTopHeight(w,Math.max(Block.argTextFormat.size + 5, field.textHeight+5));
		}
		base.redraw();
		if (parent is Block) Block(parent).fixExpressionLayout();
		if (parent is MultiBlockArg) MultiBlockArg(parent).fixLayout();

		if (evt && Scratch.app) Scratch.app.setSaveNeeded();
	}

	private function invokeMenu(evt:MouseEvent):void {
		if ((menuIcon != null) && (evt.localX <= menuIcon.x)) return;
		if (parent is ProcedureSpecEditor) return chooseMenuItems();
		if (Block.MenuHandlerFunction != null) {
			Block.MenuHandlerFunction(evt, parent, this, menuName, menuItems);
			evt.stopImmediatePropagation();
		}
	}

	protected function chooseMenuItems():void {
		var d:DialogBox = new DialogBox(chooseMenuItems2);
		d.addTitle('Edit Menu Items');
		d.addWidget(new ListWatcher('', (type.length == 1) ? [] : (type.slice(3,type.length - 1)).split(",") ));
		d.addAcceptCancelButtons('OK');
		d.showOnStage(Scratch.app.stage, true);
	}

	protected function chooseMenuItems2(dialog:DialogBox):void {
		var listItems:Array = ListWatcher(dialog.widget).contents;
		if (listItems.length == 0) {
			type = 'm';
			return;
		}
		var newMenuItems:Array = [];
		for each (var name:String in listItems) {
			if (/\S/.test(name)) newMenuItems.push(name);
		}
		type = 'm.[' + newMenuItems.join(',') + ']';
	}
}}
