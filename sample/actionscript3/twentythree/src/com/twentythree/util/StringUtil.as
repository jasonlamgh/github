package com.twentythree.util {
    /**
     * User: jasonlam
     * Date: 02/02/2011
     * Time: 15:34
     * To change this template use File | Settings | File Templates.
     */

    public class StringUtil {
        public static const WHITESPACE:String = " \t\n\r"; /**< Whitespace characters (space, tab, new line and return). */

        public function StringUtil() { }

        public static function isEqual(string1:String, string2:String):Boolean {

            var result:Boolean = true;
			var pattern:RegExp = new RegExp('[' + StringUtil.WHITESPACE + ']', 'g');

            string1 = String(string1.replace(pattern, '')).toLowerCase();
            string2 = String(string2.replace(pattern, '')).toLowerCase();

            result = string1.search(string2) > -1 ? true : false;

			return result;
		}

        public static function isEmpty(string:String):Boolean {
            var result:Boolean = false;

            var pattern:RegExp = new RegExp('[' + StringUtil.WHITESPACE + ']', 'g');

            if(string == null) return true;
            string = String(string.replace(pattern, '')).toLowerCase();

            if(string == "") return true;

            return result;
        }


    }
}
