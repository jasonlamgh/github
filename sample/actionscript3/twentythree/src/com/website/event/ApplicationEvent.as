package com.website.event {

    /**
     * User: jasonlam
     * Date: 28/01/2011
     * Time: 17:33
     * To change this template use File | Settings | File Templates.
     */

    public class ApplicationEvent {

        public static const          STARTUP:String = "startup";

        public static const   ATTACH_DISPLAY:String = "attach_display";

        public static const     STARTUP_INIT:String = "startup_init";
        public static const STARTUP_PROGRESS:String = "startup_progress";
        public static const STARTUP_COMPLETE:String = "startup_complete";


        public static const       PROXY_INIT:String = "proxy_init";
        public static const   PROXY_PROGRESS:String = "proxy_progress";
        public static const   PROXY_COMPLETE:String = "proxy_complete";

        public static const  SECTION_REQUEST:String = "section_request";
        public static const   SECTION_CREATE:String = "section_create";
        public static const   SECTION_REMOVE:String = "section_remove";
        public static const  SECTION_REMOVED:String = "section_removed";

        public static const   SECTION_CHANGE:String = "section_change";
        public static const   SECTION_OPENED:String = "section_opened";
        public static const   SECTION_LOADED:String = "section_loaded";

        public static const           RESIZE:String = "resize";
        public static const  RESIZE_COMPLETE:String = "resize_complete";

        public function ApplicationEvent() { }
    }
}
