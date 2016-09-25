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

// LooksPrims.as
// John Maloney, April 2010
//
// Looks primitives.

package primitives {
	import flash.utils.Dictionary;
	import blocks.*;
	import interpreter.*;
	import scratch.*;

public class LooksPrims {

	private var app:Scratch;
	private var interp:Interpreter;

	public function LooksPrims(app:Scratch, interpreter:Interpreter) {
		this.app = app;
		this.interp = interpreter;
	}

	public function addPrimsTo(primTable:Dictionary, specialTable:Dictionary):void {
		primTable['lookLike:']				= primShowCostume;
		primTable['nextCostume']			= primNextCostume;
		primTable['costumeIndex']			= primCostumeIndex;
		primTable['costumeName']			= primCostumeName;

		primTable['showBackground:']		= primShowCostume; // used by Scratch 1.4 and earlier (doesn't start scene hats)
		primTable['nextBackground']			= primNextCostume; // used by Scratch 1.4 and earlier (doesn't start scene hats)
		primTable['backgroundIndex']		= primSceneIndex;
		primTable['sceneName']				= primSceneName;
		primTable['nextScene']				= function(b:*):* { startScene('next backdrop', false) };
		primTable['startScene']				= function(b:*):* { startScene(b[0], false) };
		primTable['startSceneAndWait']		= function(b:*):* { startScene(b[0], true) };

		specialTable['say:duration:elapsed:from:']		= function(b:*):* { showBubbleAndWait(b, 'talk') };
		primTable['say:']							= function(b:*):* { showBubble(b, 'talk') };
		specialTable['think:duration:elapsed:from:']	= function(b:*):* { showBubbleAndWait(b, 'think') };
		primTable['think:']							= function(b:*):* { showBubble(b, 'think') };

		primTable['changeGraphicEffect:by:'] = primChangeEffect;
		primTable['setGraphicEffect:to:']	= primSetEffect;
		primTable[':effect']				= primGetEffect;
		primTable['filterReset']			= primClearEffects;

		primTable['changeSizeBy:']			= primChangeSize;
		primTable['setSizeTo:']				= primSetSize;
		primTable['scale']					= primSize;

		primTable['show']					= primShow;
		primTable['hide']					= primHide;
		primTable['visible']				= primVisible;
		primTable['hideAll']				= primHideAll;

		primTable['comeToFront']			= primGoFront;
		primTable['goBackByLayers:']		= primGoBack;

		primTable['setVideoState']			= primSetVideoState;
		primTable['setVideoTransparency']	= primSetVideoTransparency;

		primTable['scrollAlign']			= primScrollAlign;
		primTable['scrollRight']			= primScrollRight;
		primTable['scrollUp']				= primScrollUp;
		primTable['xScroll']				= function(b:*):* { return app.stagePane.xScroll };
		primTable['yScroll']				= function(b:*):* { return app.stagePane.yScroll };
	}

	private function primNextCostume(b:Array):void {
		var s:ScratchObj = interp.targetObj();
		if (s != null) s.showCostume(s.currentCostumeIndex + 1);
		if (s.visible) interp.redraw();
	}

	private function primShowCostume(b:Array):void {
		var s:ScratchObj = interp.targetObj();
		if (s == null) return;
		var arg:* = b[0];
		if (typeof(arg) == 'number') {
			s.showCostume(arg - 1);
		} else {
			var i:int = s.indexOfCostumeNamed(arg);
			if (i >= 0) {
				s.showCostume(i);
			} else if ('previous costume' == arg) {
				s.showCostume(s.currentCostumeIndex - 1);
			} else if ('next costume' == arg) {
				s.showCostume(s.currentCostumeIndex + 1);
			} else {
				var n:Number = Interpreter.asNumber(arg);
				if (!isNaN(n)) s.showCostume(n - 1);
				else return; // arg did not match a costume name nor is it a valid number
			}
		}
		if (s.visible) interp.redraw();
	}

	private function primCostumeIndex(b:Array):Number {
		var s:ScratchObj = interp.targetObj();
		return (s == null) ? 1 : s.costumeNumber();
	}

	private function primCostumeName(b:Array):String {
		var s:ScratchObj = interp.targetObj();
		return (s == null) ? '' : s.currentCostume().costumeName;
	}

	private function primSceneIndex(b:Array):Number {
		return app.stagePane.costumeNumber();
	}

	private function primSceneName(b:Array):String {
		return app.stagePane.currentCostume().costumeName;
	}

	private function startScene(s:String, waitFlag:Boolean):void {
		if ('next backdrop' == s) s = backdropNameAt(app.stagePane.currentCostumeIndex + 1);
		else if ('previous backdrop' == s) s = backdropNameAt(app.stagePane.currentCostumeIndex - 1);
		else {
			var n:Number = Interpreter.asNumber(s);
			if (!isNaN(n)) {
				n = (Math.round(n) - 1) % app.stagePane.costumes.length;
				if (n < 0) n += app.stagePane.costumes.length;
				s = app.stagePane.costumes[n].costumeName;
			}
		}
		interp.startScene(s, waitFlag);
	}

	private function backdropNameAt(i:int):String {
		var costumes:Array = app.stagePane.costumes;
		return costumes[(i + costumes.length) % costumes.length].costumeName;
	}

	private function showBubbleAndWait(b:Array, type:String):void {
		var text:*, secs:Number;
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return;
		if (interp.activeThread.firstTime) {
			text = b[0];
			secs = interp.numarg(b[1]);
			s.showBubble(text, type, b);
			if (s.visible) interp.redraw();
			interp.startTimer(secs);
		} else {
			if (interp.checkTimer() && s.bubble && (s.bubble.getSource() == b)) {
				s.hideBubble();
			}
		}
	}

	private function showBubble(b:Array, type:String = null):void {
		var text:*, secs:Number;
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return;
		if (type == null) { // combined talk/think/shout/whisper command
			type = b[0];
			text = b[1];
		} else { // talk or think command
			text = b[0];
		}
		s.showBubble(text, type, b);
		if (s.visible) interp.redraw();
	}

	private function primChangeEffect(b:Array):void {
		var s:ScratchObj = interp.targetObj();
		if (s == null) return;
		var filterName:String = b[0];
		var delta:Number = interp.numarg(b[1]);
		if(delta == 0) return;

		var newValue:Number = s.filterPack.getFilterSetting(filterName) + delta;
		s.filterPack.setFilter(filterName, newValue);
		s.applyFilters();
		if (s.visible || s == Scratch.app.stagePane) interp.redraw();
	}

	private function primSetEffect(b:Array):void {
		var s:ScratchObj = interp.targetObj();
		if (s == null) return;
		var filterName:String = b[0];
		var newValue:Number = interp.numarg(b[1]);
		if(s.filterPack.setFilter(filterName, newValue))
			s.applyFilters();
		if (s.visible || s == Scratch.app.stagePane) interp.redraw();
	}
	private function primGetEffect(b:Array) : Number {
		var s:ScratchObj = interp.targetObj();
		if(s == null)
		{
			return 0;
		}
		var filterName:String = b[0];
		return s.filterPack.getFilterSetting(filterName);
	}

	private function primClearEffects(b:Array):void {
		var s:ScratchObj = interp.targetObj();
		s.clearFilters();
		s.applyFilters();
		if (s.visible || s == Scratch.app.stagePane) interp.redraw();
	}

	private function primChangeSize(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return;
		var oldScale:Number = s.scaleX;
		s.setSize(s.getSize() + interp.numarg(b[0]));
		if (s.visible && (s.scaleX != oldScale)) interp.redraw();
	}

	private function primSetSize(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return;
		s.setSize(interp.numarg(b[0]));
		if (s.visible) interp.redraw();
	}

	private function primSize(b:Array):Number {
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return 100;
		return Math.round(s.getSize()); // reporter returns rounded size, as in Scratch 1.4
	}

	private function primShow(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if (s == null) return;
		s.visible = true;
		if(!app.isIn3D) s.applyFilters();
		s.updateBubble();
		if (s.visible) interp.redraw();
	}

	private function primHide(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if ((s == null) || !s.visible) return;
		s.visible = false;
		if(!app.isIn3D) s.applyFilters();
		s.updateBubble();
		interp.redraw();
	}
	
	private function primVisible(b:Array):Boolean {
		var s:ScratchSprite = interp.targetSprite();
		return s.visible;
	}

	private function primHideAll(b:Array):void {
		// Hide all sprites and delete all clones. Only works from the stage.
		if (!interp.targetObj().isStage) return;
		app.stagePane.deleteClones();
		for (var i:int = 0; i < app.stagePane.numChildren; i++) {
			var o:* = app.stagePane.getChildAt(i);
			if (o is ScratchSprite) {
				o.visible = false;
				o.updateBubble();
			}
		}
		interp.redraw();
	}

	private function primGoFront(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if ((s == null) || (s.parent == null)) return;
		s.parent.setChildIndex(s, s.parent.numChildren - 1);
		if (s.visible) interp.redraw();
	}

	private function primGoBack(b:Array):void {
		var s:ScratchSprite = interp.targetSprite();
		if ((s == null) || (s.parent == null)) return;
		var newIndex:int = s.parent.getChildIndex(s) - interp.numarg(b[0]);
		newIndex = Math.max(minSpriteLayer(), Math.min(newIndex, s.parent.numChildren - 1));

		if (newIndex > 0 && newIndex < s.parent.numChildren) {
			s.parent.setChildIndex(s, newIndex);
			if (s.visible) interp.redraw();
		}
	}

	private function minSpriteLayer():int {
		// Return the lowest sprite layer.
		var stg:ScratchStage = app.stagePane;
		return stg.getChildIndex(stg.videoImage ? stg.videoImage : stg.penLayer) + 1;
	}

	private function primSetVideoState(b:Array):void {
		app.stagePane.setVideoState(b[0]);
	}

	private function primSetVideoTransparency(b:Array):void {
		app.stagePane.setVideoTransparency(interp.numarg(b[0]));
		app.stagePane.setVideoState('on');
	}

	private function primScrollAlign(b:Array):void {
		if (!interp.targetObj().isStage) return;
		app.stagePane.scrollAlign(b[0]);
	}

	private function primScrollRight(b:Array):void {
		if (!interp.targetObj().isStage) return;
		app.stagePane.scrollRight(interp.numarg(b[0]));
	}

	private function primScrollUp(b:Array):void {
		if (!interp.targetObj().isStage) return;
		app.stagePane.scrollUp(interp.numarg(b[0]));
	}
}}
