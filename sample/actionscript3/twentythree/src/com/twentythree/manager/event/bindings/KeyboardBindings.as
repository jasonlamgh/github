package com.twentythree.manager.event.bindings {
	/*
    ___________________________________________________________________________________________________

    KeyboardBindings - part of EventManager {EventListenerManager} rev.1
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
	import flash.events.KeyboardEvent;
	import flash.events.IEventDispatcher;
	
	/**
	 * Easy KeyboardBindings with EventManager
	 */
	public class KeyboardBindings {
		
		/**
		 * Bind KeyboardEvents to one EventDispatcher, to one Listener Function and to one Group.		 
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
		public static function bindTo(obj:IEventDispatcher, fct:Function, group:String = "", keyDown:Boolean=true, keyUp:Boolean=false):void {						
			var map:EventMappings = new EventMappings();
			map.addItem(keyDown, KeyboardEvent.KEY_DOWN);
			map.addItem(keyUp, KeyboardEvent.KEY_UP);			
			EventMappings.bind(obj, fct, group, map.getIterator());
		}
	}
}