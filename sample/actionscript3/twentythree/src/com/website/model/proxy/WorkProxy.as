/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 28/05/2011
 * Time: 00:45
 * To change this template use File | Settings | File Templates.
 */
package com.website.model.proxy {
    import br.com.stimuli.loading.BulkLoader;

    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;

    import com.website.model.collection.WorkCollection;
    import com.website.model.vo.WorkVO;

    import flash.events.Event;

    import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;

    public class WorkProxy extends Proxy implements IProxy {

        public static const NAME:String = "WorkProxy";

        private var bulkloader:BulkLoader;
        private var status:Boolean = false;

        public function WorkProxy() {
            super(NAME, new WorkCollection());
            bulkloader = new BulkLoader(NAME, 12, BulkLoader.LOG_ERRORS);
        }

        public function init():void {
            Logger.getInstance().debug("start", "WorkProxy", "init");

            if(status) { sendNotification(ApplicationEvent.SECTION_LOADED); return;}

            bulkloader.add("xml/website-work.xml", {id:"website-work.xml"});
            bulkloader.addEventListener(Event.COMPLETE, complete);
            bulkloader.start();
        }

        private function complete(e:Event):void {
            Logger.getInstance().debug("start", "WorkProxy", "complete");

            status = true;
            bulkloader.removeEventListener(Event.COMPLETE, complete);

            var xml:XML = bulkloader.getXML("website-work.xml") as XML;

            Logger.getInstance().debug("xml="+xml, "WorkProxy", "complete");

            var collection:WorkCollection = new WorkCollection();

            for (var i:int = 0; i < xml.children().length(); i++) {
                var vo:WorkVO = new WorkVO();

                vo.id           = xml.item[i].id;
                vo.label        = xml.item[i].label;
                vo.title        = xml.item[i].title;
                vo.description  = xml.item[i].description;
                vo.image        = xml.item[i].image;
                vo.gallery      = new Array();

                var _xml:*      = xml.item[i].gallery;

                for (var j:int = 0; j < _xml.children().length(); j++) {
                    vo.gallery.push(_xml.item[j]);
                }
                collection.addItem(vo);
            }

            setData(collection);
            sendNotification(ApplicationEvent.SECTION_LOADED);
        }
    }
}
