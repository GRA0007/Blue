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

package ui {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import assets.Resources;
	import blocks.*;
	import uiwidgets.*;
	import util.*;
	import translation.Translator;

public class ProcedureSpecEditor extends Sprite {

	private var isEdit:Boolean;
	private var base:Shape;
	private var shape:int;
	private var blockShape:BlockShape;
	private var row:Array = [];

	private var moreLabel:TextField;
	private var moreButton:IconButton;
	private var shapeLabels:Array = [];
	private var shapeIcons:Array = [];
	private var shapeButtons:Array = [];
	private var buttonLabels:Array = [];
	private var buttons:Array = [];

	private var warpCheckbox:IconButton;
	private var warpLabel:TextField;

	private var deleteButton:IconButton;
	private var focusItem:DisplayObject;

	private const labelColor:int = 0x8738bf; // 0x6c36b3; // 0x9c35b3;
	private const selectedLabelColor:int = 0xefa6ff;

	public function ProcedureSpecEditor(originalSpec:String, inputNames:Array, warpFlag:Boolean, type:String, isEdit:Boolean) {
		this.isEdit = isEdit;

		addChild(base = new Shape());
		setWidthHeight(350, 10);

		shape = type == "b" ? BlockShape.BooleanShape : type == "r" ? BlockShape.NumberShape : type == "c" ? BlockShape.LoopShape : BlockShape.CmdShape;
		blockShape = new BlockShape(shape, Specs.procedureColor);
		blockShape.setWidthAndTopHeight(100, 25, true);
		addChild(blockShape);

		addChild(moreLabel = makeLabel('Options', 12));
		moreLabel.addEventListener(MouseEvent.MOUSE_DOWN, toggleButtons);

		addChild(moreButton = new IconButton(toggleButtons, 'reveal'));
		moreButton.disableMouseover();

		addButtonsAndLabels();
		addwarpCheckbox();

		addChild(deleteButton = new IconButton(deleteItem, Resources.createBmp('removeItem')));

		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		addEventListener(Event.CHANGE, textChange);
		addEventListener(FocusEvent.FOCUS_OUT, focusChange);
		addEventListener(FocusEvent.FOCUS_IN, focusChange);

		addSpecElements(originalSpec, inputNames);
		warpCheckbox.setOn(warpFlag);
		showButtons(false);
	}

	public static function strings():Array {
		return [
			'Options', 'Run without screen refresh',
			'Add number input:',
			'Add string input:',
			'Add boolean input:',
			'Add label text:',
			"Doesn't report",
			'Reports number or text',
			'Reports true or false',
			"Runs blocks inside it"
		];
	}

	private function setWidthHeight(w:int, h:int):void {
		var g:Graphics = base.graphics;
		g.clear();
		g.beginFill(CSS.white);
		g.drawRect(0, 0, w, h);
		g.endFill();
	}

	private function clearRow():void {
		for each (var el:DisplayObject in row) {
			if (el.parent) el.parent.removeChild(el);
		}
		row = [];
	}

	private function addSpecElements(spec:String, inputNames:Array):void {
		function addElement(o:DisplayObject):void {
			row.push(o);
			addChild(o);
		}
		clearRow();
		var i:int = 0;
		for each (var s:String in ReadStream.tokenize(spec)) {
			if ((s.length >= 2) && (s.charAt(0) == '%')) { // argument spec
				var argSpec:String = s.charAt(1);
				var arg:BlockArg = null;
				if (argSpec == 'b') arg = makeBooleanArg();
				if (argSpec == 'n') arg = makeNumberArg();
				if (argSpec == 's') arg = makeStringArg();
				if (argSpec == 'c') arg = makeColorArg();
				if (argSpec == 'm') arg = makeMenuArg();
				if (argSpec == 'k') arg = makeStackArg();
				if (arg) {
					arg.setArgValue(inputNames[i++]);
					addElement(arg);
				}
			} else {
				if ((row.length > 0) && (row[row.length - 1] is TextField)) {
					TextField(row[row.length - 1]).appendText(' ' + s);
				} else {
					addElement(makeTextField(s));
				}
			}
		}
		if ((row.length == 0) || (row[row.length - 1] is BlockArg)) addElement(makeTextField(''));
		fixLayout();
	}

	public function spec():String {
		var result:String = '';
		for each (var o:* in row) {
			if (o is TextField) result += TextField(o).text;
			if (o is BlockArg) result += '%' + BlockArg(o).type;
			if ((result.length > 0) && (result.charAt(result.length - 1) != ' ')) result += ' ';
		}
		if ((result.length > 0) && (result.charAt(result.length - 1) == ' ')) result = result.slice(0, result.length - 1);
		return result;
	}

	public function type():String {
		return shape == BlockShape.BooleanShape ? "b" : shape == BlockShape.NumberShape ? "r" : shape == BlockShape.LoopShape ? "c" : " ";
	}

	public function defaultArgValues():Array {
		var result:Array = [];
		for each (var el:* in row) {
			if (el is BlockArg) {
				var arg:BlockArg = BlockArg(el);
				var v:* = 0;
				if (arg.type == 'b') v = false;
				if (arg.type == 'n') v = 10;
				if (arg.type == 's') v = '';
				if (arg.type == 'm') v = '';
				if (arg.type == 'c') v = 0xA0A0A0;
				if (arg.type == 'k') v = null;
				result.push(v);
			}
		}
		return result;
	}

	public function warpFlag():Boolean {
		// True if the 'run without screen refresh' (i.e. 'warp speed') box is checked.
		return warpCheckbox.isOn();
	}

	public function inputNames():Array {
		var result:Array = [];
		for each (var o:* in row) {
			if (o is BlockArg) result.push(BlockArg(o).field.text);
		}
		return result;
	}

	private function addButtonsAndLabels():void {
		shapeLabels = [
			makeLabel("Doesn't report", 14),
			makeLabel('Reports number or text', 14),
			makeLabel('Reports true or false', 14),
			//makeLabel("Runs blocks inside it", 14),
		];
		shapeButtons = [
			new IconButton(function():void { setShape(BlockShape.CmdShape) }, null),
			new IconButton(function():void { setShape(BlockShape.NumberShape) }, null),
			new IconButton(function():void { setShape(BlockShape.BooleanShape) }, null)//,
			//new IconButton(function():void { setShape(BlockShape.LoopShape) }, null)
		];
		buttonLabels = [
			makeLabel('Add number input:', 14),
			makeLabel('Add string input:', 14),
			makeLabel('Add boolean input:', 14),
			makeLabel('Add color input:', 14),
			makeLabel('Add menu input:', 14),
			makeLabel('Add stack input:', 14),
			makeLabel('Add label text:', 14)
		];
		buttons = [
			new Button('', function():void { appendObj(makeNumberArg()) }),
			new Button('', function():void { appendObj(makeStringArg()) }),
			new Button('', function():void { appendObj(makeBooleanArg()) }),
			new Button('', function():void { appendObj(makeColorArg()) }),
			new Button('', function():void { appendObj(makeMenuArg()) }),
			new Button('', function():void { appendObj(makeStackArg());
				if(shape!=BlockShape.CmdShape){
			for(var i:int=0;i<row.length;i++){
				if ((row[i] is BlockArg) && (BlockArg(row[i]).type == 'k')) {
					var oldIndex:int = row.indexOf(row[i]) - 1;
					removeChild(row[i]);
					if (oldIndex > -1) setFocus(row[oldIndex]);
					fixLayout();
				}
				if (row.length == 0) {
					appendObj(makeTextField(''));
					TextField(row[0]).width = 27;
				}
			}
		}}),
			new Button('text', function():void { appendObj(makeTextField('')) })
		];

		shapeButtons[0].setOn(true);

		const lightGray:int = 0xA0A0A0;
		var icon:BlockShape;

		shapeIcons = [];
		icon = new BlockShape(BlockShape.CmdShape, Specs.procedureColor);
		icon.setWidthAndTopHeight(34, 18, true);
		shapeIcons.push(icon);

		icon = new BlockShape(BlockShape.NumberShape, Specs.procedureColor);
		icon.setWidthAndTopHeight(34, 18, true);
		shapeIcons.push(icon);

		icon = new BlockShape(BlockShape.BooleanShape, Specs.procedureColor);
		icon.setWidthAndTopHeight(34, 18, true);
		shapeIcons.push(icon);

		icon = new BlockShape(BlockShape.LoopShape, Specs.procedureColor);
		icon.setWidthAndTopHeight(50, 18, true);
		//shapeIcons.push(icon);

		icon = new BlockShape(BlockShape.NumberShape, lightGray);
		icon.setWidthAndTopHeight(25, 14, true);
		buttons[0].setIcon(icon);

		icon = new BlockShape(BlockShape.RectShape, lightGray);
		icon.setWidthAndTopHeight(22, 14, true);
		buttons[1].setIcon(icon);

		icon = new BlockShape(BlockShape.BooleanShape, lightGray);
		icon.setWidthAndTopHeight(25, 14, true);
		buttons[2].setIcon(icon);

		icon = new BlockShape(BlockShape.RectShape, lightGray);
		icon.setWidthAndTopHeight(14, 14, true);
		buttons[3].setIcon(icon);

		icon = new BlockShape(BlockShape.RectShape, lightGray);
		icon.setWidthAndTopHeight(25, 14, true);
		buttons[4].setIcon(icon);
		icon = new BlockShape(BlockShape.CmdShape, lightGray);
		icon.setWidthAndTopHeight(34, 18, true);
		buttons[5].setIcon(icon);
	}

	private function addwarpCheckbox():void {
		addChild(warpCheckbox = new IconButton(null, 'checkbox'));
		warpCheckbox.disableMouseover();
		addChild(warpLabel = makeLabel('Run without screen refresh', 14));
	}

	private function makeLabel(s:String, fontSize:int):TextField {
		var tf:TextField = new TextField();
		tf.selectable = false;
		tf.defaultTextFormat = new TextFormat(CSS.font, fontSize, CSS.textColor);
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.text = Translator.map(s);
		addChild(tf);
		return tf;
	}

	private function toggleButtons(ignore:*):void {
		var buttonsShowing:Boolean = buttons[0].parent != null;
		showButtons(!buttonsShowing);
	}

	private function deleteItem(ignore:*):void {
		if (focusItem) {
			var oldIndex:int = row.indexOf(focusItem) - 1;
			removeChild(focusItem);
			if (oldIndex > -1) setFocus(row[oldIndex]);
			fixLayout();
		}
		if (row.length == 0) {
			appendObj(makeTextField(''));
			TextField(row[0]).width = 27;
		}
	}

	private function showButtons(showParams:Boolean):void {
		var label:TextField, b:Button, ib:IconButton, shape:BlockShape;
		if (showParams) {
			for each (label in buttonLabels) addChild(label);
			if (!isEdit) for each (label in shapeLabels) addChild(label);
			for each (b in buttons) addChild(b);
			if (!isEdit) for each (ib in shapeButtons) addChild(ib);
			if (!isEdit) for each (shape in shapeIcons) addChild(shape);
			addChild(warpCheckbox);
			addChild(warpLabel);
		} else {
			for each (label in buttonLabels) if (label.parent) removeChild(label);
			for each (label in shapeLabels) if (label.parent) removeChild(label);
			for each (b in buttons) if (b.parent) removeChild(b);
			for each (ib in shapeButtons) if (b.parent) removeChild(b);
			for each (shape in shapeIcons) if (shape.parent) removeChild(shape);
			if (warpCheckbox.parent) removeChild(warpCheckbox);
			if (warpLabel.parent) removeChild(warpLabel);
		}

		moreButton.setOn(showParams);

		setWidthHeight(base.width, showParams ? 215 : 55);
		deleteButton.visible = showParams && (row.length > 1);
		if (parent is DialogBox) DialogBox(parent).fixLayout();
	}

	private function setShape(shape:int):void {
		this.shape = shape;
		var ob:IconButton = shapeButtons[shape == BlockShape.BooleanShape ? 2 : shape == BlockShape.NumberShape ? 1 : shape == BlockShape.LoopShape ? 3 : 0];
		if (shape == BlockShape.LoopShape) shape = BlockShape.LoopShape;
		for each (var ib:IconButton in shapeButtons) {
			ib.setOn(ib == ob);
		}

		var k:int = getChildIndex(blockShape);
		removeChildAt(k);
		blockShape = new BlockShape(shape, Specs.procedureColor);
		addChildAt(blockShape, k);
		if(shape!=BlockShape.CmdShape){
		for(var i:int=0;i<row.length;i++){
			if ((row[i] is BlockArg) && (BlockArg(row[i]).type == 'k')) {
				var oldIndex:int = row.indexOf(row[i]) - 1;
				removeChild(row[i]);
				if (oldIndex > -1) setFocus(row[oldIndex]);
				fixLayout();
			}
			if (row.length == 0) {
				appendObj(makeTextField(''));
				TextField(row[0]).width = 27;
			}
		}
	}
		fixLayout();
	}

	private function makeBooleanArg():BlockArg {
		var result:BlockArg = new BlockArg('b', 0xFFFFFF, true);
		result.setArgValue(unusedArgName('boolean'));
		return result;
	}

	private function makeNumberArg():BlockArg {
		var result:BlockArg = new BlockArg('n', 0xFFFFFF, true);
		result.field.restrict = null; // allow any string to be entered, not just numbers
		result.setArgValue(unusedArgName('number'));
		return result;
	}

	private function makeStringArg():BlockArg {
		var result:BlockArg = new BlockArg('s', 0xFFFFFF, true);
		result.setArgValue(unusedArgName('string'));
		return result;
	}

		private function makeColorArg():BlockArg {
		var result:BlockArg = new BlockArg('c', 0xFFFFFF, true);
		result.setArgValue(unusedArgName('color'));
		return result;
	}
	private function makeStackArg():BlockArg {
	var result:BlockArg = new BlockArg('k', 0xFFFFFF, true);
	result.setArgValue(unusedArgName('stack'));
	return result;
}

		private function makeMenuArg():BlockArg {
		var result:BlockArg = new BlockArg('m', 0xFFFFFF, true);
		result.setArgValue(unusedArgName('menu'));
		return result;
	}

	private function unusedArgName(prefix:String):String {
		var usedNames:Array = [];
		for each (var el:* in row) {
			if (el is BlockArg) usedNames.push(el.field.text);
		}
		var i:int = 1;
		while (usedNames.indexOf(prefix + i) > -1) i++;
		return prefix + i;
	}

	private function appendObj(o:DisplayObject):void {
		row.push(o);
		addChild(o);
		if (stage) {
			if (o is TextField) stage.focus = TextField(o);
			if (o is BlockArg) stage.focus = BlockArg(o).field;
		}
		fixLayout();
		if (parent is DialogBox) DialogBox(parent).fixLayout();
	}

	private function makeTextField(contents:String):TextField {
		var result:TextField = new TextField();
		result.borderColor = 0;
		result.backgroundColor = labelColor;
		result.background = true;
		result.type = TextFieldType.INPUT;
		result.defaultTextFormat = new TextFormat(CSS.font, 12, 0xFFFFFF);
		if (contents.length > 0) {
			result.width = 1000;
			result.text = contents;
			result.width = Math.max(10, result.textWidth + 2);
		} else {
			result.width = 27;
		}
		result.height = result.textHeight + 5;
		return result;
	}

	private function removeDeletedElementsFromRow():void {
		// Remove elements that have been delete (e.g. args that were being dragged out).
		// Also, ensure that there is exactly one text field between args.
		var tf:TextField;
		var newRow:Array = [];
		for each (var el:DisplayObject in row) {
			if (el.parent) newRow.push(el);
		}
		row = newRow;
	}

	private function fixLayout():void {
		removeDeletedElementsFromRow();
		blockShape.x = 10;
		blockShape.y = 10;
		var leftX:int = blockShape.x + (shape == BlockShape.BooleanShape ? 14 : shape == BlockShape.LoopShape ? 10 : 6);
		var nextX:int = blockShape.x + (shape == BlockShape.BooleanShape ? 14 : shape == BlockShape.LoopShape ? 10 : 6);
		var nextY:int = blockShape.y + 5;
		var maxH:int = 20;
		var maxW:int=0;
		var preWasStack:Boolean=false;
		for each (var o:DisplayObject in row) maxH = Math.max(maxH, o.height);
		for each (o in row) {
			if ((o is BlockArg) && (BlockArg(o).type == 'k') && (!preWasStack)) {
				nextX=leftX+0;
				nextY+=30;
			}
			o.x = nextX;

			o.y = nextY + int((20 - o.height) / 2) + ((o is TextField) ? 1 : 1);
			nextX += o.width + 4;
			maxW=Math.max(maxW, nextX);
			maxH=Math.max(nextY, maxH);
			if ((o is BlockArg) && (BlockArg(o).type == 's')) nextX -= 2;
			if ((o is BlockArg) && (BlockArg(o).type == 'k')) {
				nextX=leftX+0;
				nextY+=30;
				 preWasStack=true;
			}else{
				preWasStack=false;
			}
		}
		if (preWasStack) {

			maxH=maxH+6;
		}
		preWasStack=false;
		leftX = blockShape.x + (shape == BlockShape.BooleanShape ? maxH/2+5 : shape == BlockShape.LoopShape ? 10 :  shape == BlockShape.CmdShape ?6:maxH/2);
		nextX= leftX+0;
		nextY= blockShape.y + 5;
		for each (o in row) {
			if ((o is BlockArg) && (BlockArg(o).type == 'k') && (!preWasStack)) {
				nextX=leftX+0;
				nextY+=30;
			}
			o.x = nextX;

			o.y = nextY + int((20 - o.height) / 2) + ((o is TextField) ? 1 : 1);
			nextX += o.width + 4;
			maxW=Math.max(maxW, nextX);
			maxH=Math.max(nextY, maxH);
			if ((o is BlockArg) && (BlockArg(o).type == 's')) nextX -= 2;
			if ((o is BlockArg) && (BlockArg(o).type == 'k')) {
				nextX=leftX+0;
				nextY+=30;
				 preWasStack=true;
			}else{
				preWasStack=false;
			}
		}
		var blockW:int = Math.max(40, maxW + leftX - blockShape.x-12);
		blockShape.setWidthAndTopHeight(blockW, maxH +11, true);
		if(shape == BlockShape.CmdShape){
			var kI:int = 0;
			if(blockShape.parent!=null) kI=getChildIndex(blockShape);

			if(blockShape.parent!=null) blockShape.parent.removeChild(blockShape);
			blockShape = new BlockShape(BlockShape.CmdShape, Specs.procedureColor);
			//base.owner=this;
			blockShape.setCrazyShape(row,BlockShape.CmdShape, Specs.procedureColor);
			blockShape.args=row;
			addChildAt(blockShape, kI);
			blockShape.redraw();
			for each (o in row) {
				if ((o is BlockArg) && (BlockArg(o).type == 'k') ) {
					o.x=15
					if(o.parent==null) this.addChild(o);
				}

			}
		}
		moreButton.x = 0;
		moreButton.y = blockShape.y + blockShape.height + (shape == BlockShape.CmdShape ? 12 : 15);

		moreLabel.x = 10;
		moreLabel.y = moreButton.y - 4;

		var rowY:int = blockShape.y + blockShape.height + (shape == BlockShape.CmdShape ? 30 : 33);
		for (var i:int = 0; i < buttons.length; i++) {
			buttonLabels[i].x = blockShape.x + 45;
			buttonLabels[i].y = rowY;
			buttons[i].x = 240;
			buttons[i].y = rowY - 4;
			rowY += 30;
		}

		if (!isEdit) {
			for (i = 0; i < shapeButtons.length; i++) {
				shapeButtons[i].x = blockShape.x + 46;
				shapeButtons[i].y = rowY + 4;
				shapeIcons[i].x = shapeButtons[i].x + shapeButtons[i].width + 8;
				shapeIcons[i].y = rowY;
				shapeLabels[i].x = shapeIcons[i].x + shapeIcons[i].width + 8;
				shapeLabels[i].y = rowY;
				rowY += shapeIcons[i].height + 5;
			}
		}

		warpCheckbox.x = blockShape.x + 46;
		warpCheckbox.y = rowY + 4;

		warpLabel.x = warpCheckbox.x + 18;
		warpLabel.y = warpCheckbox.y - 3;

		updateDeleteButton();
		if (parent is DialogBox) DialogBox(parent).fixLayout();
	}

	/* Editing Parameter Names */

	public function click(evt:MouseEvent):void { editArg(evt) }
	public function doubleClick(evt:MouseEvent):void { editArg(evt) }

	private function editArg(evt:MouseEvent):void {
		var arg:BlockArg = evt.target.parent as BlockArg;
		if (arg && arg.isEditable) arg.startEditing(evt);
	}

	private function mouseDown(evt:MouseEvent):void {
		if ((evt.target == this) && blockShape.hitTestPoint(evt.stageX, evt.stageY)) {
			// make the first text field the input focus when user clicks on the block shape
			// but misses all the text fields
			for each (var o:DisplayObject in row) {
				if (o is TextField) { stage.focus = TextField(o); return; }
			}
		}
	}

	private function textChange(evt:Event):void {
		var tf:TextField = evt.target as TextField;
		if (tf) fixLabelWidth(tf);
		fixLayout();
	}

	private function fixLabelWidth(tf:TextField):void {
		tf.width = 1000;
		tf.text = tf.text; // recompute textWidth
		tf.width = Math.max(10, tf.textWidth + 6);
	}

	public function setInitialFocus():void {
		if (row.length == 0) appendObj(makeTextField(''));
		var tf:TextField = row[0] as TextField;
		if (tf) {
			if (tf.text.length == 0) tf.width = 27;
			else fixLabelWidth(tf);
			fixLayout();
		}
		setFocus(row[0]);
	}

	private function setFocus(o:DisplayObject):void {
		if (!stage) return;
		if (o is TextField) stage.focus = TextField(o);
		if (o is BlockArg) stage.focus = BlockArg(o).field;
	}

	private function focusChange(evt:FocusEvent):void {
		// Update label fields to show focus.
		for each (var o:DisplayObject in row) {
			if (o is TextField) {
				var tf:TextField = TextField(o);
				var hasFocus:Boolean = (stage != null) && (tf == stage.focus);
				tf.textColor = hasFocus ? 0 : 0xFFFFFF;
				tf.backgroundColor = hasFocus ? selectedLabelColor : labelColor;
			}
		}
		if (evt.type == FocusEvent.FOCUS_IN) updateDeleteButton();
	}

	private function updateDeleteButton():void {
		// Adjust the position and visibility of the delete button.
		var hasFocus:Boolean;
		var labelCount:int = 0;
		if (stage == null) return;
		if (row.length > 0) focusItem = row[0];
		for each (var o:DisplayObject in row) {
			if (o is TextField) {
				if (stage.focus == o) focusItem = o;
				labelCount++;
			}
			if (o is BlockArg) {
				if (stage.focus == BlockArg(o).field ) focusItem = o;
			}
		}
		if (focusItem) {
			var r:Rectangle = focusItem.getBounds(this);
			deleteButton.x = r.x + int(r.width / 2) - 6;
		}
		deleteButton.visible = (row.length > 1);
		deleteButton.y = -6;
	}

}}
