/**
 * Created by ${PRODUCT_NAME}.
 * User: Jason Lam
 * Date: 1/23/11
 * Time: 12:12 AM
 * To change this template use File | Settings | File Templates.
 */
package com.twentythree.display {
    import com.twentythree.log.Logger;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    public class BaseTextField extends Sprite {

        private var _text:String;
        private var _textfld:TextField;
        private var _textfmt:TextFormat;
        private var _css:StyleSheet;

        public function BaseTextField(text:String) {
            _text                   = text;

            /* instantiate textfield and set default properties */

            _textfld              = new TextField();
            _textfld.autoSize     = TextFieldAutoSize.LEFT;
            _textfld.selectable   = false;

            addChild(_textfld);
        }

        public function render():void {
            _textfld.htmlText     = _text;

            if(_css == null) return;

            /* : TODO : embedFonts escape sequence if font is null */
            _textfld.embedFonts       = true;

            _textfld.styleSheet       = _css;
            _textfld.htmlText         = _text;

            _textfld.antiAliasType    = AntiAliasType.ADVANCED;
            _textfld.gridFitType      = GridFitType.SUBPIXEL;
            _textfld.selectable       = false;
        }

        public function setCSS(css:StyleSheet):void {
            this._css = css;
        }

        public function get text():String {
            return _text;
        }

        public function set text(value:String):void {
            _text = value;
        }

        public function get textfld():TextField {
            return _textfld;
        }

        public function set textfld(value:TextField):void {
            _textfld = value;
        }

        public function get textfmt():TextFormat {
            return _textfmt;
        }

        public function set textfmt(value:TextFormat):void {
            _textfmt = value;
        }
    }
}
