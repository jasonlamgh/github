package com.twentythree.util {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;

    /**
     * User: jasonlam
     * Date: 11/02/2011
     * Time: 16:06
     * To change this template use File | Settings | File Templates.
     */

    public class DisplayUtil {

        public function DisplayUtil() {
        }

        public static function CenterDisplayObject(object:DisplayObjectContainer):Sprite {
            var result:Sprite = new Sprite();
            result.addChild(object);
            object.x = - object.width / 2;
            object.y = - object.height / 2;

            result.x = result.width / 2;
            result.y = result.height / 2;
            return result;
        }

        public static function PixelSnapAllChildrens(base:DisplayObjectContainer):void {
            for (var i:int = 0; i < base.numChildren - 1; i++) {
                var m:DisplayObject = base.getChildAt(i) as DisplayObject;
                var p:DisplayObjectContainer = base.getChildAt(i) as DisplayObjectContainer;

                if (m) {
                    m.x = Math.round(m.x);
                    m.y = Math.round(m.y);
                    if (p) {
                        if (p.numChildren > 0) PixelSnapAllChildrens(p);
                    }
                }
            }
        }
    }
}
