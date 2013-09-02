package com.twentythree.log {

	public class Log4j implements ILogger {

        public static var status:Boolean = true;

		public static const MAX_LENGTH:Number = 35;
		public static const 	  INFO:String = "INFO";
		public static const      DEBUG:String = "DEBUG";
		public static const       WARN:String = "WARN";
		public static const      ERROR:String = "ERROR";

        public static var      LEVEL:String = "INFO,DEBUG";

		public function Log4j() { }

		public function init():void { }

        public function level(level:String):void {
           LEVEL = level == null ? LEVEL : level;
        }

		public function debug(msg:*, ...args):void {
			if(status) traceOutput(DEBUG, msg, args[1], args[0]);
		}

        public function info(msg:*, ...args):void {
			if(status) traceOutput(INFO, msg, args[1], args[0]);
		}

        public function error(msg:*, ...args):void {
			if(status) traceOutput(ERROR, msg, args[1], args[0]);
		}

		private function traceOutput(level:String, msg:*, funcName:String="", className:String=""):void {
			var className:String = " " + className + " ";
			var date:Date = new Date();

//            if(level.search(/[LEVEL]) == -1) return;
            if(LEVEL.search(level) == -1) return;

			while((className.length + level.length) < MAX_LENGTH) {
				className = className.concat('.');
			}

            trace(formatDateTime(date) + " [" + level + "]" + className + " " + funcName + "()" + "(" + String(msg) +")");

//			if(msg is String)
//				trace(formatDateTime(date) + level + className + " " + funcName + "()" + "(" + String(msg) +")");
//			else
//				trace(formatDateTime(date) + level + className + " " + funcName + "()" + "(" + String(msg) +")");
		}

		private function objTrace( obj : *, level : int = 0 ) : String {
			try {
			var msg:String = "";
                for ( var prop : String in obj ){
                    if(prop) {
                        msg.length > 0 ? msg += (', '+ prop + '=' + obj[ prop ]) : msg = (prop + '=' + obj[ prop ]);
                    }
                    objTrace( obj[ prop ], level + 1);
                }
			} catch (e:Error) {};
			return msg;
	    }

		private function formatDateTime(date:Date):String {
			var dateString:String = new String();

			dateString += date.getFullYear() + "-" + formatData(date.getMonth() + 1) + "-" + formatData(date.getDate());
			dateString += " " + formatData(date.getHours()) + ":" + formatData(date.getMinutes()) + ":" + formatData(date.getSeconds());

			return dateString;
		}

		private function formatData(data:Number):String {
			return (data < 10) ? "0" + data : "" + data;
		}
	}
}