package com.twentythree.inspector {
    import com.twentythree.display.BaseTextField;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.FontManager;

    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.Font;
    import flash.text.TextFormat;

    /**
     * User: jasonlam
     * Date: 01/02/2011
     * Time: 14:00
     * To change this template use File | Settings | File Templates.
     */

    public class SpriteInspector {

        private static var si:Sprite;
        private static var stat:BaseTextField;

        public function SpriteInspector() {
        }

        public static function Init(sprite:Sprite):void {
            si = sprite;

            var font:Font           = FontManager.GetFontbyName("supernatural_10_01");
            var tformat:TextFormat  = new TextFormat();
            tformat.font            = font.fontName;
            tformat.color           = 0;
            tformat.size            = 10;

            stat = new BaseTextField(""+si+" "+si.name+""+"\nwidth="+si.width+" height="+si.height+" x="+si.x+" y="+si.y);
            stat.textformat = tformat;
            si.addChild(stat);

            si.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
            si.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
            si.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
        }

        private static function mouseHandler(e:MouseEvent):void {
            switch(e.type) {
                case MouseEvent.MOUSE_DOWN :
                    si.startDrag();
                    break;
                case MouseEvent.MOUSE_UP :
                    si.stopDrag();
                    break;
                case MouseEvent.MOUSE_MOVE :
                    update();
                    break;
                default:
            }
        }

        private static function update():void {
            stat.render(""+si+" "+si.name+""+"\nwidth="+si.width+" height="+si.height+" x="+si.x+" y="+si.y)
        }
    }
}
