/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 27/05/2011
 * Time: 15:29
 * To change this template use File | Settings | File Templates.
 */
package com.website.event {

    import flash.events.*;

    public class SectionEvent extends Event {

        public static const  SECTION_CLOSING:String = "section_closing";
        public static const   SECTION_CLOSED:String = "section_closed";

        public var requestData:Object;

        public function SectionEvent(param1:String, param2:Object = null, param3:Boolean = false) {
            super(param1, param3);
            this.requestData = param2;
            return;
        }

        override public function toString():String {
            return formatToString("SectionEvent", "type", "bubbles", "cancelable", "eventPhase", "requestData");
        }

        override public function clone():Event {
            return new SectionEvent(type, requestData, bubbles);
        }
    }
}