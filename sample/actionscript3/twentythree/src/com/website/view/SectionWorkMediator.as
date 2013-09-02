/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 27/05/2011
 * Time: 03:20
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.model.collection.WorkCollection;
    import com.website.model.proxy.WorkProxy;
    import com.website.view.component.app.BaseDisplay;
    import com.website.view.section.WorkSection;

    import flash.system.System;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class SectionWorkMediator extends Mediator implements IMediator {

        public static const NAME:String = "SectionWorkMediator";

        public function SectionWorkMediator(viewComponent:*) {
            super(NAME, viewComponent);
        }

        override public function listNotificationInterests():Array {
            return [ApplicationEvent.SECTION_OPENED, ApplicationEvent.SECTION_LOADED, ApplicationEvent.SECTION_REMOVED];
        }

        override public function handleNotification(notify:INotification):void {
            Logger.getInstance().debug("start", "SectionWorkMediator", "handleNotification");

            switch(notify.getName()) {
                case ApplicationEvent.SECTION_OPENED :
                    WorkProxy(facade.retrieveProxy(WorkProxy.NAME)).init();
                    break;

                case ApplicationEvent.SECTION_LOADED :
                    var data:WorkCollection = facade.retrieveProxy(WorkProxy.NAME).getData() as WorkCollection;
                    WorkSection(viewComponent).init(data);
                    break;

                case ApplicationEvent.SECTION_REMOVED :
                    viewComponent = null;
                    facade.removeMediator(NAME);
                    System.gc();
                    break;

                default :
            }
        }
    }
}