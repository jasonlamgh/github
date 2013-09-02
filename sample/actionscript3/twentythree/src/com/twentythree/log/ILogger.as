package com.twentythree.log {

	/**
	 *  @author Jason Lam Bionic Communications 2010
	 */

	public interface ILogger {



		function init():void;

		/**
		 *  debug
		 *
		 *  @param  msg - String or Object
		 *  @args  args - Log4j [0] Class Name [1] Function Name
         *                DeMonster [0] Object
		 */
		function debug(msg:*, ...args):void;
		function info(msg:*, ...args):void;
		function error(msg:*, ...args):void;
        function level(level:String):void;
	}
}
