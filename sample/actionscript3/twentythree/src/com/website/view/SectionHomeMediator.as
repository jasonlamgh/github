/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 27/05/2011
 * Time: 03:21
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class SectionHomeMediator extends Mediator implements IMediator {

        public static const NAME:String = "SectionHomeMediator";

        public function SectionHomeMediator(viewComponent:*) {
            super(NAME, viewComponent);
        }

        override public function listNotificationInterests():Array {
            return [];
        }

        override public function handleNotification(notify:INotification):void {
            switch(notify.getName()) {
                default :
            }
        }
    }
}
