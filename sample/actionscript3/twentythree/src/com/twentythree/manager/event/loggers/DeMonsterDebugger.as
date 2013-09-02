package com.twentythree.manager.event.loggers {
	/*	
	___________________________________________________________________________________________________

    DeMonsterDebugger Logger for EventManager - part of EventManager {EventListenerManager} rev. 1
    http://code.google.com/p/as3listenermanager/
	Copyright (c) 2010 Michael Dinkelaker
    ___________________________________________________________________________________________________      
	
	DeMonsterDebugger 2.5.1 - tracing (c) by Design Studio De Monsters
		http://demonsterdebugger.com/
		http://code.google.com/p/monsterdebugger/
		
		Examples:
		http://demonsterdebugger.com/features/howitworks
	*/
	
	import nl.demonsters.debugger.MonsterDebugger;	//  you need to download this
	import util.elm.loggers.IEventManagerLogger;

	public class DeMonsterDebugger implements IEventManagerLogger {
		
		private static var debugger:MonsterDebugger;
		
		public function init():void {
			debugger = new MonsterDebugger(this);			
		}
		
		public function info(msg:String):void {
            MonsterDebugger.trace(this, "EventManager #info: " + msg, 0x006633);
		}
		
		public function warn(msg:String):void {
			MonsterDebugger.trace(this, "EventManager #warn: " + msg, 0x0000FF);
		}
		
		public function error(msg:String):void {
			MonsterDebugger.trace(this, "EventManager #error: " + msg, 0xFF0000);
		}
	}
	
}