package com.website.model.proxy {
    import com.website.event.ApplicationEvent;
    import com.website.model.vo.ResourceVO;
    import com.twentythree.framework.proxy.BaseProxy;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.PropertiesManager;
    import com.twentythree.util.StringUtil;

    public class ResourceProxy extends BaseProxy {

        public static const NAME:String = "ResourceProxy";

        public function ResourceProxy() {
            super(NAME, new ResourceVO());
        }

        public function init():void {
            Logger.getInstance().info("start", "ResourceProxy", "init");

            var file:String = PropertiesManager.getInstance().getProperty("website.xml.init");
            var  key:String = PropertiesManager.getInstance().getProperty("website.xml.init.key");

            /* escape */
            if(StringUtil.isEmpty(file)) {
                Logger.getInstance().error("file "+ file +" does not exist or is not configured", "ResourceProxy", "init");

                return;
            }

            add(key, file, "", "", ApplicationEvent.STARTUP);
        }

        public function startup():void {
            Logger.getInstance().info("start", "ResourceProxy", "startup");

            var file:String = PropertiesManager.getInstance().getProperty("website.xml.build");
            var  key:String = PropertiesManager.getInstance().getProperty("website.xml.build.key");

            /* escape */
            if(StringUtil.isEmpty(file)) {
                Logger.getInstance().error("file "+ file +" does not exist or is not configured", "ResourceProxy", "startup");
                return;
            }

            add(key, file, ApplicationEvent.STARTUP_INIT, ApplicationEvent.STARTUP_PROGRESS, ApplicationEvent.STARTUP_COMPLETE);
        }

//        public function add(file:String, key:String):void {
//            Logger.getInstance().debug("start file="+file+" key="+key, "ResourceProxy", "add");
//
//            load(key, file, ApplicationEvent.PROXY_INIT, ApplicationEvent.PROXY_PROGRESS, ApplicationEvent.PROXY_COMPLETE);
//        }
    }
}
