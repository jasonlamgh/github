/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 28/05/2011
 * Time: 00:52
 * To change this template use File | Settings | File Templates.
 */
package com.website.model.collection {
    import com.website.model.vo.WorkVO;

    public class WorkCollection {

        private var _list:Array;

        public function WorkCollection() {
            _list = new Array();
        }

        public function addItem(obj:WorkVO):void {
            _list.push(obj);
        }

        public function get list():Array {
            return _list;
        }

        public function length():uint {
            return _list.length;
        }
    }
}
