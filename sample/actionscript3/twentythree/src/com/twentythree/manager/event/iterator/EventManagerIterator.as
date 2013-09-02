package com.twentythree.manager.event.iterator  {
	/*
	___________________________________________________________________________________________________

	EventManagerArrayIterator - part of the EventListenerManager rev. 1
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
	
	/**
	 * Basic Iterator for EventManager and bindings.EventMappings
	 */
	public class EventManagerIterator implements IArrayIterator {

		private var elements:Array;
		public var pos:Number;
		public var cur:Number;

		function EventManagerIterator(arr:Array) {
			elements=arr;
			reset();
		}
		public function next():* {
			pos++;
			cur = (pos-1);
			return elements[cur];
		}
		public function current():* {
			return elements[cur];
		}
		public function hasNext():Boolean {
			if (pos>elements.length||elements[pos]==null) {
				return false;
			} else {
				return true;
			}
		}
		public function reset():void {
			pos=0;
			cur=0;
		}
	}
}