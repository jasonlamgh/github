package com.twentythree.manager.event {
    import com.twentythree.manager.event.iterator.EventManagerIterator;
    import com.twentythree.manager.event.loggers.IEventManagerLogger;
    import com.twentythree.manager.event.loggers.TraceLogger;
    import com.twentythree.manager.event.profiler.IEventManagerProfilable;

    import flash.events.IEventDispatcher;

    /*
    ___________________________________________________________________________________________________

    EventManager {EventListenerManager} 1.26
    http://code.google.com/p/as3listenermanager/
    ___________________________________________________________________________________________________


    Copyright (c) 2008, 2009, 2010 Michael Dinkelaker, E-Mail: ilabor[at]gmail[dot]com

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
	 * EventManager Main Class.
	 */
	public class EventManager {
		/** @default LOG_LISTING				sets logging filter level.
		 * 										messages with the set value or greater will be logged.
		 *	  									values are:
		 *	  											LOG_LISTING:int = 1 (default show all),
		 *	  											LOG_SHOWING:int = 2
		 *	 							       			LOG_PROFILING:int = 3
		 *	 											LOG_INFO:int	= 20
		 *	  											LOG_WARNING:int = 40
		 *	               								LOG_ERROR:int   = 60		 	
		 **/
		public static var verboseLevel:int   = LOG_LISTING;
		/** @default false	set this to true if you want to enable the useCapture in addEventListener() **/		
		public static var useCapture:Boolean = false;	
		/** @private logger **/
		public static var logger:IEventManagerLogger;
		/** @private profilerFunction **/
		public static var  profilerFunction:Function = null;
		/** @private instance **/
		private static var instance:EventManager = null;
		/** @private objList **/
		private static var objList:Array;
		/** @private lastModifiedObjects **/
		private static var lastModifiedObjects:Array;
		/** @private showLogTitle **/
		private static var showLogTitle:String = "";

		public static const VERSION:String = "1.26";
		public static const	AUTHOR:String = "Michael Dinkelaker";		
		public static const	LOG_LISTING:int = 1;
		public static const	LOG_SHOWING:int = 2;
		public static const	LOG_PROFILING:int = 3;
		public static const	LOG_INFO:int	= 20;
		public static const	LOG_WARNING:int = 40;
		public static const	LOG_ERROR:int   = 60;
		public static const	JOB_DISABLE:String = "DISABLE";
		public static const	JOB_ENABLE:String = "ENABLE";
		public static const	JOB_REMOVE:String = "REMOVE";
		public static const	JOB_SHOW:String = "SHOW";
		public static const	JOB_ADD:String = "ADD";
		public static const	AUTOREMOVE:String = "AUTO_REMOVE";
		public static const	PROTECTED:String = "PROTECTED";
		/** @private GROUP **/				
		public static const	GROUP:String  = "group";
		/** @private EVENT **/		
		public static const	EVENT:String  = "event";
		/** @private OBJECT **/				
		public static const	OBJECT:String = "object";
		/** @private LISTENER **/
		public static const	LISTENER:String = "listener";
				
		// ________________________________________________________________________________PUBLIC METHODS
		/** @private **/
		public function EventManager(b:SingletonBlocker) {
			if (b == null) logIt("this static class should not be instantiated.", LOG_ERROR);
		}
		/**
		* Adds an eventListener
		*		
		* @param group String="" (optional) (an EventDispatcher can only belong to one group.)
		* @param special String="" (optional) EventManager.PROTECTED or EventManager.AUTOREMOVE
		* PROTECTED mappings can't be disabled or removed   
		* AUTOREMOVE mappings can't be disabled 
		*
		* @example
		* <listing version="4.0">import util.elm.EventManager;
		*  EventManager.add(mySprite, MouseEvent.CLICK, mouseHandler);  //  add with no group
		*  EventManager.add(mySprite0, MouseEvent.CLICK, mouseHandler, "myGroup");  //  add to group "myGroup";
		*  EventManager.add(mySprite0, MouseEvent.MOUSE_OVER, mouseHandler, "otherGroup");  //  mySprite0 still belongs to "myGroup" (use changeGroup())
		*  EventManager.add(mySprite1, MouseEvent.CLICK, mouseHandler, "myGroup", EventManager.AUTOREMOVE);  //  same group, but autoremoving when triggered
		*  EventManager.add(mySprite2, MouseEvent.CLICK, mouseHandler, "myGroup", EventManager.PROTECTED);  //  same group, but protected (not removable)
		*  function mouseHandler(e:MouseEvent):void {
		*      trace("after this click you can't click me again - because auto_remove was set to true!");
		*  }
		* </listing>
		*/		
		public static function add(obj:IEventDispatcher, evt:String, fct:Function, group:String="", special:String=""):void {
			init();
			var autoremove:Boolean = (special == AUTOREMOVE) ? true : false;
			var protection:Boolean = (special == PROTECTED) ? true : false;
			var i:int = findEventManagerObject(obj);
			if (i == -1) {
				objList.push(new EventManagerObject());
				objList[int(objList.length-1)].initialize(obj, evt, fct, group, autoremove, protection);
			}
			else {
				if (EventManagerObject(objList[i]).findEventMapping(evt, fct) == -1) {
					EventManagerObject(objList[i]).addEventMapping(evt, fct, autoremove, protection);
					if (EventManagerObject(objList[i]).group == "") EventManagerObject(objList[i]).group = group;
				} else logIt(obj+" already mapped event '"+evt+"' to that same function", LOG_INFO);
			}
		}
		//	________________________________________________________________________________ FacadingFunctions
		//	______ GROUP
		/**
		 * Remove all eventMappings from a group 
		 *
		 * @example remove all member events of group "myGroup" <listing version="4.0"> EventManager.disableGroup("myGroup");</listing>
		 */
		public static function removeGroup(grp:String):void {
			remove({group: grp});
		}
		/**
		 * Disable all eventMappings from a group
		 *
		 * @example disable all member events of group "myGroup" <listing version="4.0"> EventManager.disableGroup("myGroup");</listing>
		 */
		public static function disableGroup(grp:String):void {
			disable({group: grp});
		}
		/**
		 * Enable all eventMappings from a group
		 *
		 * @example enable all member events of group "myGroup" <listing version="4.0"> EventManager.enableGroup("myGroup");</listing>
		 */
		public static function enableGroup(grp:String):void {
			enable({group: grp});
		}
		/**
		 * Show all eventMappings from a group
		 *
		 * @example show all member events of group "myGroup" <listing version="4.0"> EventManager.showGroup("myGroup");</listing>
		 */
		public static function showGroup(grp:String):void {
			showLogTitle = "group: "+grp;
			show({group: grp});
		}
		//	______ EVENTS
		/**
		 * Remove all eventMappings with a specific event	
		 *
		 * @example remvove all clicks: <listing version="4.0"> EventManager.removeEvent(MouseEvent.CLICK);</listing>
		 */
		public static function removeEvent(evt:String):void {
			remove({event: evt});
		}
		/**
		 * Enable all eventMappings with a specific event
		 *
		 * @example enable all clicks: <listing version="4.0"> EventManager.enableEvent(MouseEvent.CLICK);</listing>
		 */
		public static function enableEvent(evt:String):void {
			enable({event: evt});
		}
		/**
		 * Disable all eventMappings with a specific event
		 *
		 * @example disable all clicks: <listing version="4.0"> EventManager.disableEvent(MouseEvent.CLICK);</listing>
		 */
		public static function disableEvent(evt:String):void {
			disable({event: evt});
		}
		/**
		 * Show all eventMappings with a specific event
		 *
		 * @example show all clicks <listing version="4.0"> EventManager.showEvent(MouseEvent.CLICK);</listing>
		 */
		public static function showEvent(evt:String):void {
			showLogTitle = "event: "+evt;
			show({event: evt});
		}
		//	______ LISTENER
		/**
		 * Remove all eventMappings which are mapped to a specific function
		 *
		 * @example <listing version="4.0"> EventManager.removeListener(mouseHandler);</listing>
		 */
		public static function removeListener(fct:Function):void {
			remove({listener: fct});
		}
		/**
		 * Enable all eventMappings which are mapped to a specific function
		 *
		 * @example <listing version="4.0"> EventManager.enableListener(mouseHandler);</listing>
		 */
		public static function enableListener(fct:Function):void {
			enable({listener: fct});
		}
		/**
		 * Disables all eventMappings which are mapped to a specific function
		 *
		 * @example <listing version="4.0"> EventManager.disableListener(mouseHandler);</listing>
		 */
		public static function disableListener(fct:Function):void {
			disable({listener: fct});
		}
		/**
		 * Show all eventMappings which are mapped to a specific function
		 *
		 * @example <listing version="4.0"> EventManager.showListener(mouseHandler);</listing>
		 */
		public static function showListener(fct:Function):void {
			showLogTitle = "listener: "+fct;
			show({listener: fct});
		}
		//	______ LISTENER+EVENT
		/**
		 * Remove all eventMappings which are mapped to a specific event and function 
		 *	
		 * @example <listing version="4.0"> EventManager.removeListenerEvent(mouseHandler, MouseEvent.CLICK);</listing>
		 */
		public static function removeListenerEvent(fct:Function, evt:String):void {
			remove({listener: fct, event: evt});
		}
		/**
		 * Enable all eventMappings which are mapped to a specific event and function		
		 *
		 * @example <listing version="4.0"> EventManager.enableListenerEvent(mouseHandler, MouseEvent.CLICK);</listing>
		 */
		public static function enableListenerEvent(fct:Function, evt:String):void {
			enable({listener: fct, event: evt});
		}
		/**
		 * Disable all eventMappings which are mapped to a specific event and function
		 *
		 * @example <listing version="4.0"> EventManager.disableListenerEvent(mouseHandler, MouseEvent.CLICK);</listing>
		 */
		public static function disableListenerEvent(fct:Function, evt:String):void {
			disable({listener: fct, event: evt});
		}
		/**
		 * Show all eventMappings which are mapped to a specific event and function
		 *
		 * @example <listing version="4.0"> EventManager.showListenerEvent(mouseHandler, MouseEvent.CLICK);</listing>
		 */
		public static function showListenerEvent(fct:Function, evt:String):void {
			showLogTitle = "listener: "+fct+" and event: "+evt;
			show({listener: fct, event: evt});
		}

		//	______ OBJECT
		/**
		 * Remove eventmappings from a specific EventDispatcher with optional specific event
		 * if no event is given all events will be removed from the EventDispatcher. 
		 *
		 * @param evt String="" (optional). 
		 *
		 * @example <listing version="4.0"> EventManager.removeObj(mySprite, MouseEvent.CLICK);</listing>
		 */
		public static function removeObj(obj:IEventDispatcher, evt:String=""):void {
			remove(prepObj(obj, evt));
		}
		/**
		 * Disable eventmappings from a specific EventDispatcher with optional specific event
		 * if no event is given all EventDispatcher's events will be disabled. 
		 *		 
		 * @param evt String="" (optional). 
		 *
		 * @example <listing version="4.0"> EventManager.disableObj(mySprite, MouseEvent.CLICK);</listing>
		 */
		public static function disableObj(obj:IEventDispatcher, evt:String=""):void {
			disable(prepObj(obj, evt));
		}
		/**
		 * Enable eventmappings from a specific EventDispatcher with optional specific event
		 * if no event is given all EventDispatcher's events will be enabled. 
		 *	
		 * @param evt String="" (optional).
		 *
		 * @example <listing version="4.0"> EventManager.enableObj(mySprite, MouseEvent.CLICK);</listing>
		 */
		public static function enableObj(obj:IEventDispatcher, evt:String=""):void {
			enable(prepObj(obj, evt));
		}
		/**
		 * Show eventmappings from a specific EventDispatcher with optional specific event
		 * if the optional event is given, it only shows that in the logger if present.
		 *
		 * @param evt (optional). 
		 *
		 * @example <listing version="4.0"> EventManager.showObj(mySprite);</listing>
		 */
		public static function showObj(obj:IEventDispatcher, evt:String=""):void {
			showLogTitle = "object: "+obj+ (evt == "") ? evt : " and event: "+evt;
			show(prepObj(obj, evt));
		}
		/** @private **/
		private	static function prepObj(obj:Object, evt:String=""):Object {
			var o:Object = {object: obj};
			if (evt	!= "") o.event = evt;
			return o;
		}
		//	______ MOD.ALL
		/**
		 * Enable all disabled eventMappings
		 *
		 * @example <listing version="4.0"> EventManager.enableAll();</listing>
		 */
		public static function enableAll():void {
			modifyListeners({job: JOB_ENABLE, criterias: -1});
		}
		/**
		 * Disable all enabled eventMappings
		 *
		 * @example <listing version="4.0"> EventManager.disableAll();</listing>
		 */
		public static function disableAll():void {
			modifyListeners({job: JOB_DISABLE, criterias: -1});
		}
		/**
		 * Remove all eventMappings
		 *
		 * @example <listing version="4.0"> EventManager.removeAll();</listing>
		 */
		public static function removeAll():void {
			modifyListeners({job: JOB_REMOVE, criterias: -1});
		}
		/**
		 * Show all EventDispatchers, events, groups and properties
		 *
		 * @example <listing version="4.0"> EventManager.showAll();</listing>
		 */
		public static function showAll():void {
			showLogTitle = "ALL";
			modifyListeners({job: JOB_SHOW, criterias: -1});
		}
		//	______ MISC
		/**
		 * This installs the logger class of your choice which handles EventManager's
		 * info, warn and error messages. 
		 * (show, listing, profiling messages = info)
		 * 
		 * By default EventManager uses the util.elm.loggers.TraceLogger
		 * There are some presets for Arthropod, ThunderboldAS3, DeMonsterDebugger, etc.
		 * You need to download the logger classes yourself, these are not included with EventManager.
		 * check: util.elm.loggers - open the .as template and read all informations are in there!
		 * 				 		  		
		 * @param log class instance which implements the IEventManagerLogger
		 *
		 * @example <listing version="4.0">
		 * import util.elm.EventManager;
		 * import util.elm.loggers.ThunderBoldAS3;
		 *
		 * package {
		 *     public class MyClass extends Sprite {
		 *
		 *         public function MyClass() {
		 * 		       EventManager.installLogger(new ThunderBoldAS3());
		 * 			   // EventManager.installLogger(new Arthropod());
		 *         }		 	
		 * }
		 * </listing>

		 */		
		public static function installLogger(l:IEventManagerLogger):void {
			init();
			logger = l;
			startLogger();
		}
		/**
		 * This (re)sets the EventManager logger to the default util.loggers.TraceLogger
		 * @see installLogger
		 *
		 * @example <listing version="4.0"> EventManager.initLogger();</listing>
		 */
		public static function initLogger():void {
			logger = new TraceLogger();
			startLogger();
		}
		/**
		 * This installs a custom profiling method which generates trace-outs about
		 * the current EventManager operation.
		 * This might come handy for application debugging and profiling.
		 * The users class needs to implement the util.profiler.IEventManagerprofilable Interface.
		 * The required method interceptFilter returns true or false.
		 * If it returns true the current action will generate a traced-out.
		 * See example below.
		 *
		 * @param c Class which implements the IEventManagerprofilable Interface
		 *
		 *
		 * @example <listing version="4.0">
		 * import util.elm.EventManager;
		 * import util.elm.profiler.IEventManagerProfilable;
		 * import flash.display.Sprite;
		 * import flash.events.IEventDispatcher;
		 * import flash.events.MouseEvent;
		 *
		 * package {
		 *     public class MyClass extends Sprite implements IEventManagerProfilable {
		 *
		 *         public function MyClass() {
		 *             EventManager.installProfiler(this);  //  installs the profiler
		 *             EventManager.add(this, MouseEvent.CLICK, mouseHandler, "myGroup");
		 *         }
		 *
		 *         function interceptFilter(obj:IEventDispatcher, group:String, job:String, mObj:Object):Boolean {
		 *                 //
		 *                 // obj:IEventDispatcher -- current EventDispatcher
		 *                 // group:String -- group name
		 *                 // job:String -- current job. Use constants for comparisons:
		 *                 //     EventManager.JOB_ADD, EventManager.JOB_REMOVE, EventManager.JOB_DISABLE, EventManager.JOB_ENABLE, EventManager.JOB_SHOW
		 *                 //
		 *                 // mOb.event:String --  current Event
		 *                 // mOb.listener:Function -- current EventHandler Function
		 *                 // mOb.auto_remove:Boolean -- true if it's auto_remove
		 *                 // mOb.enabled:Boolean -- true if Event is enabled
		 *
		 *                 //  profile all ADDs
		 *                 if (job == EventManager.JOB_ADD) return true;
		 *                 else return false;
		 *         }
		 *     }
		 * }
		 * </listing>
		 */
		public static function installProfiler(c:IEventManagerProfilable):void {
			profilerFunction = c.interceptFilter;
		}
		/**
		 * Remove/uninstall profiling
		 * @see installProfiler
		 *
		 * @example <listing version="4.0"> EventManager.uninstallProfiler();</listing>
		 */
		public static function uninstallProfiler():void {
			profilerFunction = null;
		}
		/**
		 * List all Groups in the logger
		 *
		 * @example <listing version="4.0"> EventManager.listGroups();</listing>
		 */
		public static function listGroups():void {
			prepListing(GROUP, "mapped groups");
		}
		/**
		 * List all EventDispatchers and their Events in the logger
		 *
		 */
		public static function listObjects():void {
			prepListing(OBJECT, "mapped Objects");
		}
		/**
		 * List all EventDispatchers and their Events with the auto_remove property in the logger
		 *
		 * @example <listing version="4.0"> EventManager.listAutoRemoves();</listing>
		 */
		public static function listAutoRemoves():void {
			prepListing(AUTOREMOVE, "auto removing events");
		}
		/**
		 * List all EventDispatchers and their Events with the protected property in the logger
		 *
		 * @example <listing version="4.0"> EventManager.listAutoRemoves();</listing>
		 */
		public static function listProtected():void {
			prepListing(PROTECTED, "protected events");
		}
		
		/** @private */
		private static function prepListing(prop:String, title:String):void {
			var arr:Array = [], str:String = "", n:int = 0, i:int = objList.length;
			while (--i > -1) {
				if (prop == AUTOREMOVE) {
					str += EventManagerObject(objList[i]).showEventMappings(true);
				} else arr.push(EventManagerObject(objList[i])[prop]);
			}
			if (prop == AUTOREMOVE && str == "") str = "- empty -";
			else if (str == "" && (i = arr.length) == 0) str = "- empty -";
			else if (str == "") {
				arr.sort(2);
				while (--i > -1) {
					if (i > 0 && arr[i] == arr[int(i-1)]) arr.splice(i,1);
					else {
						n++; str += (str == "") ? "'"+arr[i]+"'" : ", '"+arr[i]+"'";
					}
				}
			}
			str = (prop == AUTOREMOVE) ? title +" "+str+"\n" : title + "("+n+"): "+str;
			logIt(str, LOG_LISTING);
		}
		/**
		 * Returns how many EventDispatchers were modified by the last performed operation.
		 * This concerns only the last remove, disable or enable operation. 
		 * add, show, lists operations don't change or reset this value.
		 * Call EventManager.resetIterator(); to reset this value to zero.
		 *
		 * @return lenght of changed EventDispatchers
		 *
		 * @example <listing version="4.0"> var val:int = EventManager.lastChangesLength();</listing>
		 */
		public static function lastChangesLength():int {
			return lastModifiedObjects.length;
		}
		/**
		 * Returns how many EventDispatchers and Events are mapped
		 *
		 * @example <listing version="4.0"> EventManager.status();</listing>
		 */
		public static function status():void {
			var i:int = objList.length, e:int = 0;
			while (--i > -1) e += EventManagerObject(objList[i]).size();
			logIt("EventManager is managing "+objList.length+" object/s with "+e+" event/s", LOG_INFO);
		}
		/** @private
		 * Reset the Iterator
		 * @see getIterator()   
		 *
		 * @example <listing version="4.0"> EventManager.resetIterator();</listing>
		 */
		public static function resetIterator():void {
			lastModifiedObjects = [];
		}
		/**
		 * Returns an iterator of the last modified EventDispatchers
		 *
		 * @return EventManagerIterator
		 *
		 * @example <listing version="4.0">
		 *
		 * import util.elm.EventManager;
		 * import util.elm.iterator.EventManagerIterator;
		 *
		 * //  add two Sprites
		 * EventManager.add(mySprite0, MouseEvent.CLICK, mouseHandler, "myGroup", true);
		 * EventManager.add(mySprite1, MouseEvent.CLICK, mouseHandler, "myGroup", true);
		 *
		 * //  remove Events
		 * EventManager.removeGroup("myGroup");
		 *
		 * //  remove Children from Stage
		 * var it:EventManagerIterator = EventManager.getIterator();
		 * while (it.hasNext()) {
		 *     removeChild(it.next());
		 * }
		 * </listing>
		 */
		public static function getIterator():EventManagerIterator {
			return new EventManagerIterator(lastModifiedObjects);
		}
		/**
		 * Change the group of an already added EventDispatcher
		 * An EventDispatcher can only belong to one group.
		 * @param grp new group String
		 *
		 * @example <listing version="4.0">
		 *  EventManager.add(mySprite0, MouseEvent.CLICK, mouseHandler, "myGroup");  //  add to group "myGroup";
		 *  EventManager.add(mySprite0, MouseEvent.MOUSE_OVER, mouseHandler, "otherGroup");  //  mySprite0 still belongs to "myGroup"
		 *  EventManager.add(mySprite0, MouseEvent.MOUSE_OUT, mouseHandler);  //  mySprite0 belongs to "myGroup"
		 *  EventManager.changeGroup(mySprite0, "otherGroup");
		 *  EventManager.add(mySprite0, MouseEvent.MOUSE_WHEEL, mouseHandler, "myGroup");  //  mySprite0 belongs to "otherGroup"
		 * </listing>
		 */
		public static function changeGroup(obj:IEventDispatcher, grp:String):void {
			var i:int = findEventManagerObject(obj);
			if (i == -1) logIt("changeGroup failed for object: "+obj, LOG_WARNING);
			else EventManagerObject(objList[i]).group = grp;
		}
		/** @private */
		public static function logIt(msg:String, level:int):void {			
			if (level >= verboseLevel) {
				var f:Function;
				//var txt:String = "#com.aonj.actionscript3.common.util.manager.event.EventManagerM "+VERSION+" ";
				var txt:String = ""+VERSION+" ";
				switch (level) {
					case LOG_LISTING: txt += "<LISTING>"; f = logger.info; break;
					case LOG_SHOWING: txt += "<SHOWING>"; f = logger.info; break;
					case LOG_INFO:    txt += "<INFO>"; f = logger.info; break;
					case LOG_WARNING: txt += "<WARNING>"; f = logger.warn; break;
					case LOG_ERROR:   txt += "<ERROR>"; f = logger.error; break;
					case LOG_PROFILING: txt += "<PROFILING>"; f = logger.info; break;
				}
				if (showLogTitle != "") {
					txt += " "+showLogTitle;
					showLogTitle = "";
				}				
				f(txt + " " + msg);
				if (level == LOG_ERROR) throw new ArgumentError(txt);				
			}
		}
		//	________________________________________________________________________________CoreFunctions
		/** @private */
		private static function enable(options:Object):void {
			prepWithOptions(JOB_ENABLE, options);
		}
		/** @private */
		private static function disable(options:Object):void {
			prepWithOptions(JOB_DISABLE, options);
		}
		/** @private */
		private static function remove(options:Object):void {
			prepWithOptions(JOB_REMOVE, options);
		}
		/** @private */
		private static function show(options:Object):void {
			prepWithOptions(JOB_SHOW, options);
		}
		/**
		 * Initializes EventManager
		 * This method will be called automatically when using EventManager.add() or EventManager.installLogger().
		 * This only needs to be called once. However you may call this manually.
		 *
		 * @example <listing version="4.0"> EventManager.init();</listing>
		 */
		public static function init():void {
			if (instance == null) initInstance();
		}
		//	________________________________________________________________________________private METHODS
		/** @private */
		private	static function initInstance():void {
			instance = new EventManager(new SingletonBlocker());
			objList = []; lastModifiedObjects = [];
			initLogger();			
		}
		/** @private */
		private static function startLogger():void {
			logger.init();
			logger.info("com.aonj.actionscript3.common.util.manager.event.EventManager "+VERSION+" - http://code.google.com/p/as3listenermanager/\n");
		}
		/** @private */
		private	static function prepWithOptions(job:String, obj:Object):void {
			var opt:Object = parseOptions(obj);
			opt.job = job;
			if (opt.criterias > 0) modifyListeners(opt);
		}
		/** @private */
		private	static function parseOptions(obj:Object):Object {
			obj.criterias = 0;
			if ((obj[GROUP] is String && obj[GROUP] != "")) {
				obj.hasGroup =  true;
				obj.criterias++;
			}
			if ((obj[EVENT] is String && obj[EVENT] != "")) {
				obj.hasEvent = true;
				obj.criterias++;
			}
			if ((obj[LISTENER] != null && obj[LISTENER] is Function)) {
				obj.hasListener =  true;
				obj.criterias++;
			}
			if ((obj[OBJECT] != null && obj[OBJECT] is IEventDispatcher)) {
				obj.hasObject = true;
				obj.criterias++;
			}

			return obj;
		}
		/** @private */
		private	static function modifyListeners(args:Object):void {
			var i:int = objList.length, n:int, hitCounter:int, doChange:Boolean, showLog:String = "", key:String, evFlag:Boolean;
			var eObj:EventManagerObject;
			if (args.job != JOB_SHOW) resetIterator();
			while (--i > -1) {
				n = -1; doChange = true;
				eObj = EventManagerObject(objList[i]);
				if (args.criterias > 0) {
					hitCounter = 0;
					evFlag = false;
					for (key in args) {
						switch (key) {
							case "hasGroup":
								if (eObj.group == args[GROUP]) hitCounter++;
								break;
							case "hasObject":
								if (eObj.object == args[OBJECT]) hitCounter++;
								break;
							case "hasEvent":
							case "hasListener":
								if (!evFlag) {
									if ( (args.hasEvent && args.hasListener) && ( (n = eObj.findEventMapping(args[EVENT], args[LISTENER])) != -1) ) { hitCounter += 2; evFlag = true;}
									else if ( (args.hasEvent && !args.hasListener) && ( (n = eObj.findEventMapping(args[EVENT], null)) != -1) ) hitCounter++;
									else if ( (args.hasListener && !args.hasEvent) && ( (n = eObj.findEventMapping("", args[LISTENER])) != -1) ) hitCounter++;
								}
								break;
						}
						if (args.criterias == hitCounter) break;
					}
					doChange = (args.criterias == hitCounter) ? true : false;
				}
				
				if (doChange) {
					if (args.job != JOB_SHOW) lastModifiedObjects.push(eObj.object);
					switch (args.job) {
						case JOB_ENABLE:
							eObj.enableEventMapping(n);
							break;
						case JOB_DISABLE:
							eObj.disableEventMapping(n);
							break;
						case JOB_REMOVE:
							eObj.removeEventMapping(n);
							if (eObj.size() == 0) removeEventManagerObject(i);
							break;
						case JOB_SHOW:
							showLog += eObj.showEventMappings();
							break;
					}
				}
			}
			if (args.job == JOB_SHOW) {
				if (showLog == "") showLog = "- nothing found -";
				logIt(showLog, LOG_SHOWING);
			}
		}
		/** @private */
		public static function findEventManagerObject(obj:IEventDispatcher):int {
			var i:int = objList.length;
			while (--i > -1) if (EventManagerObject(objList[i]).object == obj) break;
			return i;
		}
		/** @private */
		public static function removeEventManagerObject(n:int):void {
			objList.splice(n, 1);
		}
	}
}
internal class SingletonBlocker {}