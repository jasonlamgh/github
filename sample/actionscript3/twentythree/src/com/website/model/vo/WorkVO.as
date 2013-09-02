/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 28/05/2011
 * Time: 00:45
 * To change this template use File | Settings | File Templates.
 */
package com.website.model.vo {
    public class WorkVO {

        private var _id:String;
        private var _label:String;
        private var _title:String;
        private var _description:String;
        private var _image:String;
        private var _gallery:Array;

        public function WorkVO() {
        }


        public function get id():String {
            return _id;
        }

        public function set id(value:String):void {
            _id = value;
        }

        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }

        public function get description():String {
            return _description;
        }

        public function set description(value:String):void {
            _description = value;
        }

        public function get image():String {
            return _image;
        }

        public function set image(value:String):void {
            _image = value;
        }

        public function get gallery():Array {
            return _gallery;
        }

        public function set gallery(value:Array):void {
            _gallery = value;
        }

        public function get label():String {
            return _label;
        }

        public function set label(value:String):void {
            _label = value;
        }
    }
}
