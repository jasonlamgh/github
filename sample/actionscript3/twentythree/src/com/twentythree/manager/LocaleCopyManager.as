package com.twentythree.manager {
    import com.twentythree.log.Logger;
    import com.twentythree.util.StringUtil;

    /**
     * User: jasonlam
     * Date: 02/02/2011
     * Time: 14:40
     * To change this template use File | Settings | File Templates.
     */

    public class LocaleCopyManager {

        public static const DELIMITER:String = ":";

        private static var instance:LocaleCopyManager;
        private static var copy:Array;

        public function LocaleCopyManager() {
            copy = new Array();
        }

        public function retrieveCopy(id:String, locale:String="en_UK"):String {
            Logger.getInstance().debug("locale="+locale+" id="+id, "LocaleCopyManager", "retrieveCopy");

            var result:String;
            result = copy[locale+DELIMITER+id];

            Logger.getInstance().debug("result="+result, "LocaleCopyManager", "retrieveCopy");

            if(StringUtil.isEmpty(result)) result = "copy unavailable... please check xml or id";
            return result;
        }

        public function appendByXML(xml:XML):void {
            Logger.getInstance().debug("start xml="+xml, "LocaleCopyManager", "appendByXML");
            for (var i:int = 0; i < xml.children().length(); i++) {
                var     id:String = xml.item[i].id;
                var locale:String = xml.item[i].locale;
                var   type:String = xml.item[i].type;
                var  value:String = xml.item[i].value;

                if(type.search(/TEXT/ig) == -1) continue;

                copy[locale+DELIMITER+id] = value;
            }
        }

        public function append(locale:String, id:String, text:String=""):void {
            copy[locale+DELIMITER+id] = text;
        }

        public static function getInstance():LocaleCopyManager {
            if(instance == null) instance = new LocaleCopyManager();
            return instance;
        }

    }
}
