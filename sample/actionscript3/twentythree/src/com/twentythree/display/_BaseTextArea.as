//package com.twentythree.display {
//
//    import flash.display.Sprite;
//    import flash.text.StyleSheet;
//    import flash.text.TextFieldAutoSize;
//    import flash.text.TextFormat;
//
//    /**
//     * User: jasonlam
//     * Date: 07/02/2011
//     * Time: 13:58
//     * To change this template use File | Settings | File Templates.
//     */
//
//    public class _BaseTextArea extends Sprite {
//
//        private var text:String;
//        private var vector:Vector.<BaseTextField>;
//
//        private var _width:Number;
//        private var _height:Number;
//
//        private var textformat:TextFormat;
//
//        private var id:String;
//
//        private var background:Boolean;
//        private var backgroundColor:uint;
//        private var backgroundAlpha:Number;
//
//        public function _BaseTextArea(text:String, width:Number=NaN, height:Number=NaN) {
//            this.text       = text;
//            this.vector     = new Vector.<BaseTextField>();
//            this.background = false;
//            this._width     = width;
//            this._height    = height;
//        }
//
//        public function init():void {
//
//            var reftf:BaseTextField = new BaseTextField(text);
////            reftf.setBackground(0x000000);
////            reftf.visible = false;
//
////            if(id && styleSheet) reftf.setStyle(id, styleSheet);
//            addChild(reftf);
//
//            var temp:BaseTextField;
//            for (var i:int = 0; i < reftf.textfield.numLines; i++) {
//                var ltf:BaseTextField = new BaseTextField(reftf.textfield.getLineText(i));
//
////                if(id && styleSheet) ltf.setStyle(id, styleSheet);
////                if(background) ltf.setBackground(backgroundColor, backgroundAlpha);
//
//                vector.push(ltf);
//                addChild(ltf);
//
//                ltf.y = temp == null ? 0 : temp.y + temp.height;
//                temp = ltf;
//            }
//
////            reftf.destroy(); removeChild(reftf);
//            temp    = null;
//            reftf   = null;
//        }
//
//        public function setCCS(css:StyleSheet):void {
//
//        }
//
//        public function setBackground(color:uint, alpha:Number=1):void {
//            this.background         = true;
//            this.backgroundColor    = color;
//            this.backgroundAlpha    = alpha;
//        }
//
//        public function destroy():void {
//            for each (var item:BaseTextField in vector) {
////                item.destroy();
//                item = null;
//            }
//
//            vector = null;
//        }
//    }
//}
