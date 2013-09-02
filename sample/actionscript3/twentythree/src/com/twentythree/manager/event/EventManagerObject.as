package com.twentythree.manager.event {
	/*
    ___________________________________________________________________________________________________

    EventManagerObject - part of EventManager {EventListenerManager} 1.26
    http://code.google.com/p/as3listenermanager/
    ___________________________________________________________________________________________________


    Copyright (c) 2009, 2010 Michael Dinkelaker

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

	import flash.events.IEventDispatcher;
	import flash.system.System;	

	/**
	 * EventManagerObject Class internally used by EventManager
	 */
	public class EventManagerObject {

		public var object:IEventDispatcher, group:String;
		private var eventMappings:Array;
		
		//  ________________________________________________________________________________PUBLIC METHODS		
		public function initialize(obj:IEventDispatcher, evt:String, fct:Function, grp:String="", autoremove:Boolean=false, protection:Boolean=false):void {			
			object = obj; group = grp; eventMappings = [];
			addEventMapping(evt, fct, autoremove, protection);
		}
		public function addEventMapping(evt:String, fct:Function, autoremove:Boolean, protection:Boolean):void {
			eventMappings = addTheEventMapping(eventMappings, object, evt, group, fct, autoremove, autoRemoveHandler, protection);
		}
		public function removeEventMapping(n:int):void {
			eventMappings = modifyEventMapping(eventMappings, object, EventManager.JOB_REMOVE, group, n, autoRemoveHandler);
		}
		public function enableEventMapping(n:int):void {
			eventMappings = modifyEventMapping(eventMappings, object, EventManager.JOB_ENABLE, group, n, autoRemoveHandler);
		}
		public function disableEventMapping(n:int):void {
			eventMappings = modifyEventMapping(eventMappings, object, EventManager.JOB_DISABLE, group, n, autoRemoveHandler);
		}
		public function showEventMappings(onlyAutoRemoves:Boolean = false):String {
			return showTheEventMappings(eventMappings, object, group, onlyAutoRemoves);
		}		
		public function findEventMapping(evt:String, fct:Function, auto_remove:Boolean=false):int {
			return EventMappingsFinder(eventMappings, evt, fct, auto_remove);
		}		
		public function size():int {
			return eventMappings.length;
		}
		//  ________________________________________________________________________________PRIVATE METHODS
		private static function addTheEventMapping(eventMappings:Array, object:IEventDispatcher, evt:String, group:String, fct:Function, autoremove:Boolean, autoRemoveHandler:Function, protection:Boolean):Array {			
			eventMappings.push(new EventManagerMO(evt, fct, autoremove, true, protection));
			fct = (autoremove) ? autoRemoveHandler : fct;
			addListener(object, evt, fct);
			if (EventManager.profilerFunction != null) checkProfiling(EventManagerMO(eventMappings[int(eventMappings.length-1)]), object, group, EventManager.JOB_ADD);
			return eventMappings;
		}
		private static function showTheEventMappings(eventMappings:Array, object:IEventDispatcher, group:String, onlyAutoRemoves:Boolean):String {
			var i:int = eventMappings.length, evListing:String = "\n\n\tobject: "+object+", "+"group: '"+group+"'";
			var mObj:EventManagerMO;
			while (--i > -1) {
				mObj = EventManagerMO(eventMappings[i]);
				if (!onlyAutoRemoves || (onlyAutoRemoves && Boolean(mObj.auto_remove) ))
				evListing += "\n\t\tevent: '"+mObj.event+"', enabled: '"+mObj.enabled+"', auto_remove: '"+mObj.auto_remove+"', listener: '"+mObj.listener+"'";
			}
			return evListing;
		}
		private function autoRemoveHandler(e:*):void {  // rev 144 EventManager 1.22
			eventMappings = executeAutoRemove(eventMappings, object, e, group, autoRemoveHandler);
		}
		private static function executeAutoRemove(eventMappings:Array, object:IEventDispatcher, e:*, group:String, autoRemoveHandler:Function):Array {
			var fctVect:Array = [], i:int;
			while ( (i = EventMappingsFinder(eventMappings, e.type, null, true) ) > -1) {
				    fctVect.push(EventManagerMO(eventMappings[i]).listener);
					eventMappings = modifyEventMapping(eventMappings, object, EventManager.JOB_REMOVE, group, i, autoRemoveHandler)
			}
			if (eventMappings.length == 0 && (( i = EventManager.findEventManagerObject(object)) > -1) ) EventManager.removeEventManagerObject(i);
			while (fctVect.length > 0) (fctVect.pop() as Function)(e);
			return eventMappings;
		}
		private static function EventMappingsFinder(eventMappings:Array, evt:String, fct:Function = null, auto_remove:Boolean=false):int {
			var i:int = eventMappings.length, found:int = 0, toFind:int = 1;			
			if (evt != "") ++toFind; if (fct != null) ++toFind;
			var mObj:EventManagerMO;
			while (--i > -1 && toFind > 0) {
				mObj = EventManagerMO(eventMappings[i]);
				if (mObj.event == evt) ++found;
				if (mObj.listener == fct) ++found;
				if (mObj.auto_remove == auto_remove) ++found;
				if (found == toFind) break;
				else found = 0;
			}
			return i;
		}
		private static function checkProfiling(mObj:EventManagerMO, object:IEventDispatcher, group:String, job:String):void {
			if (EventManager.profilerFunction != null) {
				if (EventManager.profilerFunction(object, group, job, mObj)) EventManager.logIt(job + " " + object + ", " + "group: '"
					+ group + "', event: '" + mObj.event + "', enabled: '" + mObj.enabled + "'" 
					+ "', AUTOREMOVE: '" + mObj.auto_remove + ", 'PROTECTED: '" + mObj.protection+ "'", EventManager.LOG_PROFILING);
			}
		}
		private static function modifyEventMapping(eventMappings:Array, object:IEventDispatcher, job:String, group:String, n:int, autoRemoveHandlerFct:Function = null):Array {
			var fct:Function = null, remAll:Boolean = (n == -1) ? true : false;
			var mObj:EventManagerMO;
			n = (remAll) ? eventMappings.length : ++n;
						
			while (--n > -1) {
				mObj = EventManagerMO(eventMappings[n]);
				
				if (!mObj.protection) {	// 1.25 protection		
					
					checkProfiling(mObj, object, group, job);
					fct = (mObj.auto_remove) ? autoRemoveHandlerFct : mObj.listener;
					
					switch (job) {
						case EventManager.JOB_DISABLE:
							if (mObj.enabled && !mObj.auto_remove) { // 1.25 don't disable auto_removes
								mObj.enabled = false;
								removeListener(object, mObj.event, fct);							
							}
							break;
						case EventManager.JOB_ENABLE:
							if (!mObj.enabled) {
								addListener(object, mObj.event, fct);
								mObj.enabled = true;
							}
							break;
						case EventManager.JOB_REMOVE:
							if (mObj.enabled) {
								removeListener(object, mObj.event, fct);
							}
							eventMappings.splice(n, 1);
							break;
					}
				}
				if (!remAll) break;
			}
			return eventMappings;
		}

		private static function addListener(object:IEventDispatcher, evt:String, fct:Function):void {
			object.addEventListener(evt, fct, EventManager.useCapture);
		}
		private static function removeListener(object:IEventDispatcher, evt:String, fct:Function):void {
			object.removeEventListener(evt, fct);
		}
	}
}
internal class EventManagerMO {
	
	public var event:String,
			   listener:Function,			   			   
			   auto_remove:Boolean,
			   enabled:Boolean,
			   protection:Boolean;
	
	public function EventManagerMO(evt:String, lstnr:Function, ar:Boolean, en:Boolean, p:Boolean) {
		event = evt; listener = lstnr; auto_remove = ar; enabled = en; protection = p;		
	}
}