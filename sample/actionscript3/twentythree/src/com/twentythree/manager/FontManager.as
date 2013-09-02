package com.twentythree.manager {
    import com.twentythree.log.Logger;

    import flash.text.Font;

    /**
     * User: jasonlam
     * Date: 01/02/2011
     * Time: 10:57
     * To change this template use File | Settings | File Templates.
     */

    public class FontManager {

        public function FontManager() {
        }

        public static function ValidateFontByName(name:String):Boolean {
            var result:Boolean = false;
            var fontArr:Array = Font.enumerateFonts();

            for( var i:int=0; i<fontArr.length; i++ ) {
				if(fontArr[ i ].fontName == name) {
					return true;
				}
			}

            return result;
        }

        public static function GetFontbyName(name:String):Font {
            var result:Font;
            var fontArr:Array = Font.enumerateFonts();

			for( var i:int=0; i<fontArr.length; i++ ) {
				if(fontArr[ i ].fontName == name) {
					result = fontArr[ i ] as Font;
					break;
				}
			}

            return result;
        }

        public static function TraceAllFont():void {
            Logger.getInstance().debug("start", "FontManager", "TraceAllFont");

            var fontArr:Array = Font.enumerateFonts();

            for( var i:int=0; i<fontArr.length; i++ ) {
                Logger.getInstance().debug("font="+fontArr[i].fontName, "FontManager", "TraceAllFont");
            }

            Logger.getInstance().debug("end", "FontManager", "TraceAllFont");
        }
    }
}
