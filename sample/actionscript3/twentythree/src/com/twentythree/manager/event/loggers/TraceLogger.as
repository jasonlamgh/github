package com.twentythree.manager.event.loggers {
	/*		
    ___________________________________________________________________________________________________

    Trace Logger for EventManager - part of EventManager {EventListenerManager} rev. 1
    http://code.google.com/p/as3listenermanager/
	Copyright (c) 2010 Michael Dinkelaker
    ___________________________________________________________________________________________________      
	
	This is the Default Logger
	
	*/		

	/**
	 * EventManager's default Logger
	 * you can find some more preset Classes in this package/folder for Thunderbolt, Arthropod, etc.
	 * to replace the TraceLogger.
	 * 
	 * @see EventManager.installLogger(l:IEventManagerLogger);
	 */
	public class TraceLogger implements IEventManagerLogger {
//	public class TraceLogger implements IEventManagerLogger {

		public function init():void {			
		}
		
		public function info(msg:String):void {
			trace(msg);
		}
		
		public function warn(msg:String):void {
			trace(msg);
		}
		
		public function error(msg:String):void {
			trace(msg);
		}
	}
	
}