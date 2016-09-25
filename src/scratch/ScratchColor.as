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

// ScratchColor.as
// NoMod-Programming, June 2016
// Uses code from DjDolphin's Jackalope mod (https://github.com/djdolphin/jackalope/)
//
// A ScratchColor is a return type (and variable type) used in scratch to 
// represent a number that is a color

package scratch {
	import blocks.BlockShape;
	import blocks.BlockArg;

public class ScratchColor extends BlockShape {
		public function ScratchColor(color:int) {
			this.color = color;
			this.shape = RectShape;
			setShape(shape);
			//filters = BlockArg.blockArgFilters();
			setWidthAndTopHeight(13, 13, true);
		}
		
		override public function toString():String {
			return String(color);
		}
		
		public function toJSON():Object {
			return {type: 'ScratchColor', color: color};
		}
	}
}