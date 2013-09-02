package com.twentythree.log {
	import nl.demonsters.debugger.MonsterDebugger;

	/**
	 *  @author Jason Lam Bionic Communications 2010
	 */

	public class DeMonster implements ILogger {

		private var log:MonsterDebugger;

		public function DeMonster() { }

		public function init():void { }
		
		public function debug(msg:*, ...args):void {
			if(args[0]) log = new MonsterDebugger(args[0]);
			else log = new MonsterDebugger(this);
			MonsterDebugger.trace(args[0], msg, MonsterDebugger.COLOR_NORMAL);
		};
	}
}
