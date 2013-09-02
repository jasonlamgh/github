package com.twentythree.manager.event.bindings {
	/*
    ___________________________________________________________________________________________________

    EventMappings - part of EventManager {EventListenerManager} rev.1
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

    import com.twentythree.manager.event.EventManager;
    import com.twentythree.manager.event.iterator.EventManagerIterator;

    import flash.events.IEventDispatcher;

    /**
	 * Helper Class for MouseBindings and KeyboardBindings 	 	
	 */
	public class EventMappings {
		
		protected var mappings:Array;
		
		public function EventMappings() {
			mappings = [];
		}
		
		public function addItem(item:Boolean, event:String):void {
			if (item) mappings.push(event);
		}
		
		public function getIterator():EventManagerIterator {
			return new EventManagerIterator(mappings);
		}
		
		public static function bind(obj:IEventDispatcher, fct:Function, group:String, it:EventManagerIterator):void {
			while (it.hasNext()) {
				EventManager.add(obj, String(it.next()), fct, group);
			}
		}		
	}	
}