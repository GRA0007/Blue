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

package uiwidgets {
import flash.display.*;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.*;
import flash.filters.DropShadowFilter;
import flash.filters.BevelFilter;
import com.greensock.TweenLite;
import com.greensock.TweenMax;


public class Button extends Sprite {

	private var labelOrIcon:DisplayObject;
	private var color:* = CSS.white;//CSS.titleBarColors;
	private var minWidth:int = 50;
	private var paddingX:Number = 5;
	private var compact:Boolean;

	private var action:Function; // takes no arguments
	private var eventAction:Function; // like action, but takes the event as an argument
	private var tipName:String;
	public var state:int=0;
	public var raised:Boolean=true;
	public var textColor:int = 0x2962FF;
	public var raiseY:Number=1;

	public function Button(label:String, action:Function = null, compact:Boolean = false, tipName:String = null,raised:Boolean = true) {
		this.action = action;
		this.compact = compact;
		this.tipName = tipName;
		addLabel(label);
		mouseChildren = false;
		addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		setColor(CSS.white);//titleBarColors);
		//setColor(0x4285f4);
		var shadow:DropShadowFilter = new DropShadowFilter();
shadow.distance = 1;
shadow.alpha=0.3;
shadow.blurX=6;
shadow.blurY=6;
shadow.angle = 90;
        this.filters=[shadow];
		this.setRaised(raised);
	}
	public function dropShadow(e:Number):DropShadowFilter{
		var shadow:DropShadowFilter = new DropShadowFilter();
shadow.distance = 1+e;
shadow.alpha=0.3;
shadow.blurX=e*2+2;
shadow.blurY=e*2+2;
shadow.angle = 90;
return shadow;
	}

	public function setLabel(s:String):void {
		if (labelOrIcon is TextField) {
			TextField(labelOrIcon).text = s;
			setMinWidthHeight(0, 0);
		} else {
			if ((labelOrIcon != null) && (labelOrIcon.parent != null)) labelOrIcon.parent.removeChild(labelOrIcon);
			addLabel(s);
		}
	}

	public function setIcon(icon:DisplayObject):void {
		if ((labelOrIcon != null) && (labelOrIcon.parent != null)) {
			labelOrIcon.parent.removeChild(labelOrIcon);
		}
		labelOrIcon = icon;
		if (icon != null) addChild(labelOrIcon);
		setMinWidthHeight(0, 0);
	}

    public function setWidth(val:int):void{
        paddingX = (val - labelOrIcon.width)/2;
        setMinWidthHeight(5, 5);
    }

	public function setMinWidthHeight(minW:int, minH:int):void {
		if (labelOrIcon != null) {
			if (labelOrIcon is TextField) {
				minW = Math.max(minWidth, labelOrIcon.width + paddingX * 2);
				minH = compact ? 20 : 26;
			} else {
				minW = Math.max(minWidth, labelOrIcon.width + 12);
				minH = Math.max(minH, labelOrIcon.height + 11);
			}
			labelOrIcon.x = ((minW - labelOrIcon.width) / 2);
			labelOrIcon.y = ((minH - labelOrIcon.height) / 2);
		}
		// outline
		graphics.clear();
		//graphics.lineStyle(0.5, CSS.borderColor, 1, true);
		if (color is Array) {
			var matr:Matrix = new Matrix();
			matr.createGradientBox(minW, minH, Math.PI / 2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF,0xFFFFFF], [100, 100], [0x00, 0xFF], matr);
		}
		else {graphics.beginFill(color);}
		if(!raised){

		graphics.beginFill(0,0);
	}else{
		//graphics.beginFill(0x888AF3);
	}
		graphics.drawRoundRect(0, 0, minW, minH, 3);
		graphics.endFill();
	}
	public function withTextColor(txtColor:int):Button{
		this.textColor=txtColor;
		return this;
	}
	public function setEventAction(newEventAction:Function):Function {
		var oldEventAction:Function = eventAction;
		eventAction = newEventAction;
		return oldEventAction;
	}
	public function addBevel():void{
		var f:BevelFilter = new BevelFilter(1);
		f.blurX = f.blurY = 1;
		f.highlightAlpha = 0.6;
		f.shadowAlpha = 0.6;
		//this.filters = [f].concat(filters || []);
		//this.filters[this.filters.length]=f;
	}
	private function mouseOver(evt:MouseEvent):void {
		//setColor(CSS.overColor)
		//setColor(0x4285f4);
		if(raised){
			if(this.filters.length<1){
        this.filters=[dropShadow(2)];
		addBevel();
	}else{
		TweenMax.to(this, 0.2, {dropShadowFilter:{distance:4,blurX:8,blurY:8}});
	}
	}else{
		this.filters=[];
		if (labelOrIcon is TextField) {
			TweenMax.to(labelOrIcon, 0.6, {hexColors:{textColor:this.textColor}});
			//(labelOrIcon as TextField).textColor=textColor;
		}
	}
	}

	private function mouseOut(evt:MouseEvent):void {
		//setColor(CSS.titleBarColors)
		//setColor(0x4285f4);
		if(raised){
			if(this.filters.length<1){
		this.filters=[dropShadow(1)];
		addBevel();
	}else{
		TweenMax.to(this, 0.2, {dropShadowFilter:{distance:1,blurX:2,blurY:2}});
	}
	}else{
		this.filters=[];
		if (labelOrIcon is TextField) {
			TweenMax.to(labelOrIcon, 0.6, {hexColors:{textColor:0x424242}});
			//(labelOrIcon as TextField).textColor=0x424242;
		}
	}
	}
	public function setRaised(raised:Boolean):Button{
		this.raised=raised;
		if(raised){
		this.filters=[dropShadow(1)];
		addBevel();
	}else{
		this.filters=[];
		if (labelOrIcon is TextField) {
			(labelOrIcon as TextField).textColor=0x424242;
		}
		graphics.clear();
		graphics.beginFill(0,0);
		graphics.drawRoundRect(0, 0, this.width, this.height, 3);
		graphics.endFill();
	}
	return this;
	}

	private function mouseDown(evt:MouseEvent):void {
		//setColor(0x4285f4);
		Menu.removeMenusFrom(stage)
	}

	private function mouseUp(evt:MouseEvent):void {
		setColor(CSS.titleBarColors);
		if (action != null) action();
		if (eventAction != null) eventAction(evt);
		evt.stopImmediatePropagation();
	}

	public function handleTool(tool:String, evt:MouseEvent):void {
		if (tool == 'help' && tipName) Scratch.app.showTip(tipName);
	}

	private function setColor(c:*):void {
		color = c;
		if (labelOrIcon is TextField) {
			(labelOrIcon as TextField).textColor = (c == CSS.overColor) ? CSS.white : CSS.buttonLabelColor;
			//(labelOrIcon as TextField).textColor = textColor;//(state) ? CSS.white : CSS.buttonLabelColor;

		}
		setMinWidthHeight(5, 5);
	}

	private function addLabel(s:String):void {
		var label:TextField = new TextField();
		label.autoSize = TextFieldAutoSize.LEFT;
		label.selectable = false;
		label.background = false;
		var tF:TextFormat=new TextFormat(CSS.font, 12, textColor);
		tF.bold=true;
		label.defaultTextFormat = tF;//CSS.normalTextFormat;
		//label.defaultTextFormat.bold=true;

		label.textColor=0x424242;// = textColor;//CSS.buttonLabelColor;
		label.text = s;
		labelOrIcon = label;
		setMinWidthHeight(0, 0);
		addChild(label);
	}

}
}
