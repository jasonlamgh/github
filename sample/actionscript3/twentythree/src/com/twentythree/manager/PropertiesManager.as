package com.twentythree.manager {
    import com.twentythree.properties.Properties;
    import com.twentythree.properties.PropertiesParser;

    /**
     * User: jasonlam
     * Date: 25/03/2011
     * Time: 09:37
     * To change this template use File | Settings | File Templates.
     */

    public class PropertiesManager {

        private static var instance:PropertiesManager;
        private static var props:Properties;

        public function PropertiesManager() {
        }

        public function parse(data:*):void {
            props = PropertiesParser.parse(data);
        }

        public function getProperty(key:String):String {
            var result:String;
            result = props.getProperty(key);
            return result;
        }

        public static function getInstance():PropertiesManager {
            if(instance == null) instance = new PropertiesManager();
            return instance;
        }
    }
}
