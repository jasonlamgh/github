package com.twentythree.component.button {
    import com.twentythree.display.BaseTextField;

    import com.twentythree.log.Logger;
    import com.twentythree.manager.FontManager;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.TextFormat;

    /**
     * User: jasonlam
     * Date: 01/02/2011
     * Time: 15:38
     * To change this template use File | Settings | File Templates.
     */

    public class BaseButton extends Sprite {

        public var image:Sprite;
        public var label:BaseTextField;

        public var hit:Sprite;

        public function BaseButton() {
            init();
        }

        public function init():void {
            image   = new Sprite();
            label   = new BaseTextField("BUTTON");
            hit     = new Sprite();

            var font:Font           = FontManager.GetFontbyName("supernatural_10_01");
            var tformat:TextFormat  = new TextFormat();
            tformat.font            = font.fontName;
            tformat.color           = 0xFFFFFF;
            tformat.size            = 10;
            label.textformat        = tformat;

            addChild(image);
            addChild(label);
            addChild(hit);

            hit.graphics.beginFill(0, 0.1);
            hit.graphics.drawRect(0, 0, this.width, this.height);
            hit.graphics.endFill();

            this.hit = hit;

            hit.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
            hit.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            hit.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);

            this.buttonMode = true;
        }

        private function mouseHandler(e:MouseEvent):void {
            Logger.getInstance().debug("e.type="+e.type, "BaseButton", "mouseHandler");
            switch (e.type) {
                case MouseEvent.MOUSE_UP :
                    break;
                case MouseEvent.MOUSE_OVER :
                    break;
                case MouseEvent.MOUSE_OUT :
                    break;
                default:
            }
        }

        public function destroy():void {}

    }
}
