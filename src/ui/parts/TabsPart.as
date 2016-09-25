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

// TabsPart.as
// John Maloney, November 2011
//
// This part holds the tab buttons to view scripts, costumes/scenes, or sounds.

package ui.parts {
	import flash.display.*;
	import flash.text.*;
	import translation.Translator;
	import uiwidgets.IconButton;
import flash.filters.DropShadowFilter;
import com.greensock.TweenLite;
public class TabsPart extends UIPart {

	private var scriptsTab:IconButton;
	private var imagesTab:IconButton;
	private var soundsTab:IconButton;
	private var underline:Shape;

	public function TabsPart(app:Scratch) {
		function selectScripts(b:IconButton):void { app.setTab('scripts') }
		function selectImages(b:IconButton):void { app.setTab('images') }
		function selectSounds(b:IconButton):void { app.setTab('sounds') }

		this.app = app;
		scriptsTab = makeTab('Scripts', selectScripts);
		imagesTab = makeTab('Images', selectImages); // changed to 'Costumes' or 'Scenes' by refresh()
		soundsTab = makeTab('Sounds', selectSounds);
		underline=new Shape();
		var g:Graphics = underline.graphics;



        g.clear();
        g.beginFill(0x2196F3);//0x2196F3);
g.drawRect(0, 0, 80,4);


		addChild(scriptsTab);
		addChild(imagesTab);
		addChild(soundsTab);
		addChild(underline);

		scriptsTab.turnOn();
	}

	public static function strings():Array {
		return ['Scripts', 'Costumes', 'Backdrops', 'Sounds'];
	}

	public function refresh():void {
		var label:String = ((app.viewedObj() != null) && app.viewedObj().isStage) ? 'Backdrops' : 'Costumes';
		imagesTab.setImage(makeTabImg(label, true), makeTabImg(label, false));
		fixLayout();
	}

	public function selectTab(tabName:String):void {
		scriptsTab.turnOff();
		imagesTab.turnOff();
		soundsTab.turnOff();
		if (tabName == 'scripts') {
			scriptsTab.turnOn();
			TweenLite.to(underline, 0.2, {x:scriptsTab.x});
			//var myTween:Tween = new Tween(underline, "x", Regular.easeInOut, underline.x, scriptsTab.x, 0.5, true);
		}
		if (tabName == 'images') {
			imagesTab.turnOn();
			TweenLite.to(underline, 0.2, {x:imagesTab.x});
			//var myTween:Tween = new Tween(underline, "x", Regular.easeInOut, underline.x, imagesTab.x, 0.5, true);
		}
		if (tabName == 'sounds'){
			soundsTab.turnOn();
			TweenLite.to(underline, 0.2, {x:soundsTab.x});
			//var myTween:Tween = new Tween(underline, "x", Regular.easeInOut, underline.x, soundsTab.x, 0.5, true);

		}
	}

	public function fixLayout():void {
		scriptsTab.x = 0;
		scriptsTab.y = 0;
		imagesTab.x = scriptsTab.x + scriptsTab.width + 0;
		imagesTab.y = 0;
		soundsTab.x = imagesTab.x + imagesTab.width + 0;
		soundsTab.y = 0;
		this.w = soundsTab.x + soundsTab.width;
		this.h = scriptsTab.height;
		underline.y=this.h-4;
	}

	public function updateTranslation():void {
		scriptsTab.setImage(makeTabImg('Scripts', true), makeTabImg('Scripts', false));
		soundsTab.setImage(makeTabImg('Sounds', true), makeTabImg('Sounds', false));
		refresh(); // updates imagesTabs
	}

	private function makeTab(label:String, action:Function):IconButton {
		return new IconButton(action, makeTabImg(label, true), makeTabImg(label, false), true);
	}

	private function makeTabImg(label:String, isSelected:Boolean):Sprite {
		var h:int = app.stagePane?this.app.stagePart.computeTopBarHeight():39;
		var img:Sprite = new Sprite();
		var tf:TextField = new TextField();
		var tFF:TextFormat=new TextFormat(CSS.font, 12, isSelected ? 0x2196F3 : 0x424242, false);
		tFF.bold=true;
		tf.defaultTextFormat = tFF;
		tf.text = Translator.map(label);
		tf.width = tf.textWidth + 5;
		tf.height = tf.textHeight + 5;
		var w:int = Math.max(tf.width + 20,80);
		tf.x = w/2-tf.width/2;
		tf.y = h/2-tf.height /2;
		img.addChild(tf);

		var g:Graphics = img.graphics;


		var r:int = 0;//9
        var pT:Array=[["m",0,h],["l",0,-h],["l",w,0],["l",0,h],["l",-w,0]];
        if (isSelected){
        g.clear();
        g.beginFill(CSS.grey100);//0x2196F3);//CSS.grey100);
g.drawRect(0, 0, w,h);
//g.beginFill(0x2196F3);//0x2196F3);
//g.drawRect(0,h-4,w,4);
		//drawBoxBkgGradientShape(g, Math.PI / 2, colors,[0x00, 0xFF], path, w, h);
		//g.lineStyle(0.5, borderColor, 1, true);
		//DrawPath.drawPath(path, g);
        }else{
        g.clear();
        g.beginFill(CSS.grey100);//0x2196F3);//CSS.grey100);
g.drawRect(0,0,w,h);
//g.beginFill(0xB3C1CC);
//g.drawRect(0,h-4,w,4);
        //drawSelected(g, [0xB1E0FF, 0x0077FF], pT, w, h);
        }
		//this.height=h;
		//if (isSelected) drawTopBar(g, CSS.titleBarColors, pT, w, h);
		//else drawSelected(g, [0xB1E0FF, 0x0077FF], pT, w, h);
		return img;
	}

}}
