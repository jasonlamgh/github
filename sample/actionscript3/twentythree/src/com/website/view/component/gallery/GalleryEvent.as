/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 30/05/2011
 * Time: 13:18
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.gallery {
    import flash.events.Event;

    public class GalleryEvent extends Event {

        public static const CAROUSEL_REQUEST:String = "carousel_request";

        public var requestData:Object;

        public function GalleryEvent(param1:String, param2:Object = null, param3:Boolean = false) {
            super(param1, param3);
            this.requestData = param2;
            return;
        }

        override public function toString():String {
            return formatToString("SectionEvent", "type", "bubbles", "cancelable", "eventPhase", "requestData");
        }

        override public function clone():Event {
            return new GalleryEvent(type, requestData, bubbles);
        }
    }
}
