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
// John Maloney, August 2009
//
// A ScratchColor is a return type (and variable type) used in scratch to 
// represent a number that is a color

package {

public class ScratchColor {

	public var color:uint = 0xFFFFFFFF;

	public function ScratchColor(newColor:uint) {
			color = newColor;
		}

	public function toString():String {
      return "Foo";
    }

	}
}