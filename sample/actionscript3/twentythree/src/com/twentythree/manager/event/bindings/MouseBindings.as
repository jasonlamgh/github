package com.twentythree.manager.event.bindings {
	/*
    ___________________________________________________________________________________________________

    MouseBindings - part of EventManager {EventListenerManager} rev.1
    http://code.google.com/p/as3listenermanager/
    ___________________________________________________________________________________________________


    Copyright (c) 2010 Michael Dinkelaker

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

 	  http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
	*/
		
	import util.elm.bindings.EventMappings;
	import flash.events.MouseEvent;
	import flash.events.IEventDispatcher;
	
	/**
	 * Easy MouseBindings with EventManager
	 */
	public class MouseBindings {
		
		
		/**
		 * Bind several MouseEvents to one EventDispatcher, to one Listener Function and to one Group.
		 *
		 * @example <listing version="4.0">
		 * import util.elm.bindings.MouseBindings;		 
		 *
		 * package {
		 *     public class MyClass extends Sprite {
		 *
		 *         public function MyClass() {
		 * 		       this.name = "Button";
		 * 		       MouseBindings.binTo(this, mouseHandler, "myGroup");
		 *         }
		 * 
		 *         public function mouseHandler(e:MouseEvent) {
		 * 		       switch (e.type) {
		 * 		           case MouseEvent.CLICK:
		 * 		               trace("you clicked: "+e.currentTarget.name);
		 * 		               break;
		 * 		           case MouseEvent.ROLL_OVER:
		 * 		              trace("you rolled over"+e.currentTarget.name);
		 * 		              break;
		 * 		       }
		 *         }
		 * }
		 * </listing>
		 */
		public static function bindTo(obj:IEventDispatcher, fct:Function, group:String = "", click:Boolean = true, doubleClick:Boolean = false, rollOut:Boolean = true, rollOver:Boolean = true):void {		
			var map:EventMappings = new EventMappings();
			map.addItem(click, MouseEvent.CLICK);
			map.addItem(doubleClick, MouseEvent.DOUBLE_CLICK);
			map.addItem(rollOut, MouseEvent.ROLL_OUT);
			map.addItem(rollOver, MouseEvent.ROLL_OVER);
			
			EventMappings.bind(obj, fct, group, map.getIterator());						
		}
		
		/**
		 * Bind several MouseEvents to one EventDispatcher, one Listener Function and one Group.
		 * (These are all MouseEvents starting with MOUSE_???)		 
		 *
		 * @example <listing version="4.0">
		 * import util.elm.bindings.MouseBindings;		 
		 *
		 * package {
		 *     public class MyClass extends Sprite {
		 *
		 *         public function MyClass() {
		 * 		       MouseBindings.binMouseTo(this, mouseHandler, "myGroup", false, false, false, false, false, true);  //  bind only MOUSE_WHEEL
		 *         }
		 * 
		 *         public function mouseHandler(e:MouseEvent) {
		 *         }
		 * 
		 * }
		 * </listing>
		 */
		public static function bindMouseTo(obj:flash.events.IEventDispatcher, fct:Function, group:String = "", up:Boolean = true, down:Boolean  = true, out:Boolean  = true, over:Boolean  = true, move:Boolean  = true, wheel:Boolean  = true):void {
			var map:EventMappings = new EventMappings();
			map.addItem(up, MouseEvent.MOUSE_UP);
			map.addItem(down, MouseEvent.MOUSE_DOWN);		
			map.addItem(out, MouseEvent.MOUSE_OUT);
			map.addItem(over, MouseEvent.MOUSE_OVER);
			map.addItem(move, MouseEvent.MOUSE_MOVE);
			map.addItem(wheel, MouseEvent.MOUSE_WHEEL);
			
			EventMappings.bind(obj, fct, group, map.getIterator());
		}
		
		/**
		 * Adds handCursor to one ore more DisplayObject/s
		 * MouseBindings.hC(); Method takes one or endless more parameters. 
		 * Not working? Try to add a tranparent (catcher) MovieClip above of your graphic in the clip.
		 *
		 * @example <listing version="4.0">
		 * MouseBindings.hC(btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8);
		 * MouseBindings.hC(otherButton);
		 * </listing>
		 */
		public static function hC(...args):void {
			var i:int = args.length;
			while (--i > -1) {				
				args[i].buttonMode = true;
				args[i].useHandCursor = true;	
			}
		}
	}
}