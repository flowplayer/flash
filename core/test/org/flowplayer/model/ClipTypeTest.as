/*    
 *    Copyright (c) 2008, 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Flowplayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Flowplayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.model {
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;	

	/**
	 * @author anssi
	 */
	public class ClipTypeTest extends TestCase {
		public static var suite:TestSuite = new TestSuite(ClipTypeTest);

		public function ClipTypeTest(methodName:String = null) {
			super(methodName);
		}
		
		public function testFromFileExtension():void {
			assertEquals(ClipType.IMAGE, ClipType.fromFileExtension("image.png"));
			assertEquals(ClipType.IMAGE, ClipType.fromFileExtension("image.gif"));
			assertEquals(ClipType.IMAGE, ClipType.fromFileExtension("image.jpg"));

			assertEquals(ClipType.VIDEO, ClipType.fromFileExtension("video.flv"));
			assertEquals(ClipType.VIDEO, ClipType.fromFileExtension("video.mp4"));
			assertEquals(ClipType.VIDEO, ClipType.fromFileExtension("video.mpeg4"));
			assertEquals(ClipType.VIDEO, ClipType.fromFileExtension("noextension"));
		}
	}
}
