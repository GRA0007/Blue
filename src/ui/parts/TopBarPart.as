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

// TopBarPart.as
// John Maloney, November 2011
//
// This part holds the Scratch Logo, cursor tools, screen mode buttons, and more.

package ui.parts {
import flash.display.*;
import flash.events.MouseEvent;
import flash.text.*;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import assets.Resources;
import interpreter.*;

import extensions.ExtensionDevManager;
import scratch.*;
import watchers.ListWatcher;

import flash.display.*;
import flash.events.MouseEvent;
import flash.text.*;

import translation.Translator;

import uiwidgets.*;
import util.*;
import flash.filters.DropShadowFilter;
public class TopBarPart extends UIPart {

	private var shape:Shape;
	protected var languageButton:IconButton;
	protected var logo:IconButton;
	protected var logoButton:IconButton;

	protected var fileMenu:IconButton;
	protected var editMenu:IconButton;
	protected var aboutButton:IconButton;

	private var copyTool:IconButton;
	private var cutTool:IconButton;
	private var growTool:IconButton;
	private var shrinkTool:IconButton;
	private var helpTool:IconButton;
	private var toolButtons:Array = [];
	private var toolOnMouseDown:String;

	private var offlineNotice:TextField;
	private const offlineNoticeFormat:TextFormat = new TextFormat(CSS.font, 13, CSS.white, true);

	protected var loadExperimentalButton:Button;
	protected var exportButton:Button;
	protected var extensionLabel:TextField;

	public function TopBarPart(app:Scratch) {
		this.app = app;
		addButtons();
		addLogo();
		refresh();
		var shadow:DropShadowFilter = new DropShadowFilter();
shadow.distance = 2;
shadow.alpha=0.3;
shadow.blurX=6;
shadow.blurY=6;
shadow.angle = 90;
        //this.filters=[shadow];
	}

	protected function addButtons():void {
		addChild(shape = new Shape());
		addChild(languageButton = new IconButton(app.setLanguagePressed, 'languageButton'));
		languageButton.isMomentary = true;
		addTextButtons();
		addToolButtons();
		if (Scratch.app.isExtensionDevMode) {
			addChild(logoButton = new IconButton(app.logoButtonPressed, Resources.createBmp('scratchxlogo')));
			const desiredButtonHeight:Number = 20;
			logoButton.scaleX = logoButton.scaleY = 1;
			var scale:Number = desiredButtonHeight / logoButton.height;
			logoButton.scaleX = logoButton.scaleY = scale;

			addChild(exportButton = new Button('Save Project', function():void { app.exportProjectToFile(); }));
			addChild(extensionLabel = makeLabel('My Extension', offlineNoticeFormat, 2, 2));

			var extensionDevManager:ExtensionDevManager = Scratch.app.extensionManager as ExtensionDevManager;
			if (extensionDevManager) {
				addChild(loadExperimentalButton = extensionDevManager.makeLoadExperimentalExtensionButton());
			}
		}
	}

	public static function strings():Array {
		if (Scratch.app) {
			Scratch.app.showFileMenu(Menu.dummyButton());
			Scratch.app.showEditMenu(Menu.dummyButton());
		}
		return ['File', 'Edit', 'Tips', 'About', 'Duplicate', 'Delete', 'Grow', 'Shrink', 'Block help', 'Offline Editor'];
	}

	protected function removeTextButtons():void {
		if (fileMenu.parent) {
			removeChild(fileMenu);
			removeChild(editMenu);
			removeChild(aboutButton);
		}
	}

	private function addLogo() : void {
		var logoClicked:Function = null;
		logoClicked = function(param1:*):void {
			//TODO: Get a new website :P
			navigateToURL(new URLRequest("http://blue.gwiddle.co.uk"), "_self");
			trace("REDIRECTING");
		};
		logo = new IconButton(logoClicked, "scratchlogo");
		logo.isMomentary = true;
		addChild(this.logo);
	}

	public function updateTranslation():void {
		removeTextButtons();
		addTextButtons();
		if (offlineNotice) offlineNotice.text = Translator.map('Offline Editor');
		refresh();
	}

	public function setWidthHeight(w:int, h:int):void {
		this.w = w;
		this.h = h;
		var g:Graphics = shape.graphics;
		g.clear();
		g.beginFill(false?0x448AFF:0x2962FF);
		g.drawRect(0, 0, w, h);
		g.endFill();
		fixLayout();
	}

/*	protected function fixLogoLayout():int {
		var nextX:int = 9;
		if (logoButton) {
			logoButton.x = nextX;
			logoButton.y = 5;
			nextX += logoButton.width + buttonSpace;
		}
		return nextX;
	}

	protected const buttonSpace:int = 12;*/
	protected function fixLayout():void {
		var buttonY:int = 5;
		logo.x = 1;
		logo.y = 3;
		languageButton.x = logo.x + logo.width + 9;
		languageButton.y = buttonY - 1;

		// new/more/tips buttons
		const buttonSpace:int = 12;
		var nextX:int = languageButton.x + languageButton.width + 13;
		fileMenu.x = nextX;
		fileMenu.y = buttonY;
		nextX += fileMenu.width + buttonSpace;

		editMenu.x = nextX;
		editMenu.y = buttonY;
		nextX += editMenu.width + buttonSpace;

		aboutButton.x = nextX;
		aboutButton.y = buttonY;
		nextX += aboutButton.width + buttonSpace;

		// cursor tool buttons
		var space:int = 3;
		copyTool.x = app.isOffline ? 493 : 427;
		cutTool.x = copyTool.right() + space;
		growTool.x = cutTool.right() + space;
		shrinkTool.x = growTool.right() + space;
		helpTool.x = shrinkTool.right() + space;
		copyTool.y = cutTool.y = shrinkTool.y = growTool.y = helpTool.y = buttonY - 3;

		if (offlineNotice) {
			offlineNotice.x = w - offlineNotice.width - 5;
			offlineNotice.y = 5;
		}

		// From here down, nextX is the next item's right edge and decreases after each item
		nextX = w - 5;

		if (loadExperimentalButton) {
			loadExperimentalButton.x = nextX - loadExperimentalButton.width;
			loadExperimentalButton.y = h + 5;
			// Don't upload nextX: we overlap with other items. At most one set should show at a time.
		}

		if (exportButton) {
			exportButton.x = nextX - exportButton.width;
			exportButton.y = h + 5;
			nextX = exportButton.x - 5;
		}

		if (extensionLabel) {
			extensionLabel.x = nextX - extensionLabel.width;
			extensionLabel.y = h + 5;
			nextX = extensionLabel.x - 5;
		}
	}

	public function refresh():void {
		if (app.isOffline) {
			helpTool.visible = app.isOffline;
		}

		if (Scratch.app.isExtensionDevMode) {
			var hasExperimental:Boolean = app.extensionManager.hasExperimentalExtensions();
			exportButton.visible = hasExperimental;
			extensionLabel.visible = hasExperimental;
			loadExperimentalButton.visible = !hasExperimental;

			var extensionDevManager:ExtensionDevManager = app.extensionManager as ExtensionDevManager;
			if (extensionDevManager) {
				extensionLabel.text = extensionDevManager.getExperimentalExtensionNames().join(', ');
			}
		}
		fixLayout();
	}

	protected function addTextButtons():void {
		addChild(fileMenu = makeMenuButton('File', app.showFileMenu, true));
		addChild(editMenu = makeMenuButton('Edit', app.showEditMenu, true));
		addChild(aboutButton = makeMenuButton("About", app.showAboutDialog, false));
	}

	private function addToolButtons():void {
		function selectTool(b:IconButton):void {
			var newTool:String = '';
			if (b == copyTool) newTool = 'copy';
			if (b == cutTool) newTool = 'cut';
			if (b == growTool) newTool = 'grow';
			if (b == shrinkTool) newTool = 'shrink';
			if (b == helpTool) newTool = 'help';
			if (newTool == toolOnMouseDown) {
				clearToolButtons();
				CursorTool.setTool(null);
			} else {
				clearToolButtonsExcept(b);
				CursorTool.setTool(newTool);
			}
		}

		toolButtons.push(copyTool = makeToolButton('copyTool', selectTool));
		toolButtons.push(cutTool = makeToolButton('cutTool', selectTool));
		toolButtons.push(growTool = makeToolButton('growTool', selectTool));
		toolButtons.push(shrinkTool = makeToolButton('shrinkTool', selectTool));
		toolButtons.push(helpTool = makeToolButton('helpTool', selectTool));
		if(!app.isMicroworld){
			for each (var b:IconButton in toolButtons) {
				addChild(b);
			}
		}
		SimpleTooltips.add(copyTool, {text: 'Duplicate', direction: 'bottom'});
		SimpleTooltips.add(cutTool, {text: 'Delete', direction: 'bottom'});
		SimpleTooltips.add(growTool, {text: 'Grow', direction: 'bottom'});
		SimpleTooltips.add(shrinkTool, {text: 'Shrink', direction: 'bottom'});
		SimpleTooltips.add(helpTool, {text: 'Block help', direction: 'bottom'});
	}

	public function clearToolButtons():void {
		clearToolButtonsExcept(null)
	}

	private function clearToolButtonsExcept(activeButton:IconButton):void {
		for each (var b:IconButton in toolButtons) {
			if (b != activeButton) b.turnOff();
		}
	}

	private function makeToolButton(iconName:String, fcn:Function):IconButton {
		function mouseDown(evt:MouseEvent):void {
			toolOnMouseDown = CursorTool.tool
		}

		var onImage:Sprite = toolButtonImage(iconName, CSS.overColor, 1);
		var offImage:Sprite = toolButtonImage(iconName, 0, 0);
		var b:IconButton = new IconButton(fcn, onImage, offImage);
		b.actOnMouseUp();
		b.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); // capture tool on mouse down to support deselecting
		return b;
	}

	private function toolButtonImage(iconName:String, color:int, alpha:Number):Sprite {
		const w:int = 23;
		const h:int = 24;
		var img:Bitmap;
		var result:Sprite = new Sprite();
		var g:Graphics = result.graphics;
		g.clear();
		g.beginFill(color, alpha);
		g.drawRoundRect(0, 0, w, h, 8, 8);
		g.endFill();
		result.addChild(img = Resources.createBmp(iconName));
		img.x = Math.floor((w - img.width) / 2);
		img.y = Math.floor((h - img.height) / 2);
		return result;
	}

	protected function makeButtonImg(s:String, c:int, isOn:Boolean):Sprite {
		var result:Sprite = new Sprite();

		var label:TextField = makeLabel(Translator.map(s), CSS.topBarButtonFormat, 2, 2);
		label.textColor = CSS.white;
		label.x = 6;
		result.addChild(label); // label disabled for now

		var w:int = label.textWidth + 16;
		var h:int = 22;
		var g:Graphics = result.graphics;
		g.clear();
		g.beginFill(c);
		g.drawRoundRect(0, 0, w, h, 8, 8);
		g.endFill();

		return result;
	}
}
}
