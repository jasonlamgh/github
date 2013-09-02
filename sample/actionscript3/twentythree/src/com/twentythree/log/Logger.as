package com.twentythree.log {

    /**
     *  @author Jason Lam Bionic Communications 2010
     */

    public class Logger {

        public static var instance:ILogger;
        public static var lClass:Class;

        public function Logger() {
        }

        public static function init(lClass:Class):void {
            instance = new lClass;
        }

        public static function getInstance():ILogger {
           if(instance == null) instance = new lClass;
           return instance;
        }
    }
}
