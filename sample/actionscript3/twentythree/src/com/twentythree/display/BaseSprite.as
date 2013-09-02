package com.twentythree.display {
    import com.twentythree.inspector.SpriteInspector;
    import com.twentythree.log.Logger;

    import com.twentythree.manager.FontManager;

    import flash.display.Sprite;
    import flash.text.Font;
    import flash.text.TextFormat;

    /**
     * User: jasonlam
     * Date: 01/02/2011
     * Time: 10:33
     * To change this template use File | Settings | File Templates.
     */

    public class BaseSprite extends Sprite {

        public static var NAME:String = "BaseSprite";

        public function BaseSprite(name:String=null) {
            this.name = name == null ? NAME : name;
        }

        public function destroy():void {
            this.parent.removeChild(this);
            return;
        }


    }
}
