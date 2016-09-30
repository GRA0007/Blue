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

// PaletteSelectorItem.as
// John Maloney, August 2009
//
// A PaletteSelectorItem is a text button for a named category in a PaletteSelector.
// It handles mouse over, out, and up events and changes its appearance when selected.

package ui {
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	import com.greensock.TweenLite;

public class PaletteSelectorItem extends Sprite {

	public var categoryID:int;
	public var label:TextField;
	public var label2:TextField;
	public var isSelected:Boolean;
	public var colorBar:Shape;
	public var colorBarMSK1:Shape;
	public var colorBarMSK2:Shape;
	private var color:uint;
	public var colorBarW:int=7;

	public function PaletteSelectorItem(id: int, s:String, c:uint) {
		categoryID = id;
		addLabel(s);
		color = c;
		colorBar=new Shape();
		colorBarMSK1=new Shape();
		colorBarMSK2=new Shape();
		var g:Graphics = colorBar.graphics;



        g.clear();
        g.beginFill(color);//0x2196F3);
		g.drawRect(0, 0, colorBarW,label.height+2);
		addChild(colorBar);
		colorBar.x=8;

		g = colorBarMSK1.graphics;



        g.clear();
        g.beginFill(color);//0x2196F3);
		g.drawRect(0, 0, colorBarW,label.height+2);
		g = colorBarMSK2.graphics;
		addChild(colorBarMSK1);
		colorBarMSK1.x=8;



        g.clear();
        g.beginFill(color);//0x2196F3);
		g.drawRect(0, 0, colorBarW,label.height+2);
		//addChild(colorBar);
		addChild(colorBarMSK2);
		colorBarMSK2.x=8;
		addChild(label);
		addChild(label2);
		label2.mask=colorBarMSK1;
		label.mask=colorBarMSK2;
		setSelected(false);
		addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		addEventListener(MouseEvent.CLICK, mouseUp);
	}

	private function addLabel(s:String):void {
		label = new TextField();
		label.autoSize = TextFieldAutoSize.LEFT;
		label.selectable = false;
		label.text = s;
		addChild(label);
		label2 = new TextField();
		label2.autoSize = TextFieldAutoSize.LEFT;
		label2.selectable = false;
		label2.text = s;

		addChild(label2);
	}
	public function renderColorBar(){
		var tabInset:int = 8;
		var w:int = 100;
		var g:Graphics = colorBar.graphics;



        g.clear();
        g.beginFill(color);//0x2196F3);
g.drawRect(0, 0, colorBarW,Math.max(label.height+2,20));

g = colorBarMSK1.graphics;



g.clear();
g.beginFill(color);//0x2196F3);
g.drawRect(0, 0, colorBarW,Math.max(label.height+2,20));
//colorBarMSK1.x=8;

g = colorBarMSK2.graphics;


g.clear();
g.beginFill(color);//0x2196F3);
g.drawRect(colorBarW, 0, w - tabInset - 1,Math.max(label.height+2,20));
//addChild(colorBar);
//colorBarMSK2.x=8;
	}
	public function setSelected(flag:Boolean):void {
		var w:int = 100;
		var h:int = label.height + 2;
		var tabInset:int = 8;
		var tabW:int = 7;
		isSelected = flag;
		var fmt:TextFormat = new TextFormat(CSS.font, 12, ((isSelected && false) ? CSS.white : CSS.textColor+0x313131),true);// isSelected);
		label.setTextFormat(fmt);
		label.x = 17;
		label.y = 1;

		var fmt2:TextFormat = new TextFormat(CSS.font, 12, ( CSS.white ), true);//isSelected);
		label2.setTextFormat(fmt2);
		label2.x = 17;
		label2.y = 1;

		var g:Graphics = this.graphics;
		g.clear();
		g.beginFill(0xFF00, 0); // invisible, but mouse sensitive
		g.drawRect(0, 0, w, h);
		g.endFill();
		renderColorBar();

		TweenLite.to(this,0.5, {colorBarW:flag? w - tabInset - 1:7, onUpdate:renderColorBar});
		//g.beginFill(color);
		//g.drawRect(tabInset, 1, isSelected ? w - tabInset - 1 : tabW, h - 2);
		//g.endFill();
	}

	private function mouseOver(event:MouseEvent):void {
		//label.textColor = isSelected ? CSS.white : CSS.buttonLabelOverColor;
	}

	private function mouseOut(event:MouseEvent):void {
		//label.textColor = isSelected ? CSS.white : CSS.offColor;
	}

	private function mouseUp(event:MouseEvent):void {
		if (parent is PaletteSelector) {
			PaletteSelector(parent).select(categoryID, event.shiftKey);
		}
	}

}}
