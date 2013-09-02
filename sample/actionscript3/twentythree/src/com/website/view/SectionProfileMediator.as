/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 27/05/2011
 * Time: 03:19
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.view.section.ProfileSection;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class SectionProfileMediator extends Mediator implements IMediator {

        public static const NAME:String = "SectionProfileMediator";

        public function SectionProfileMediator(viewComponent:*) {
            super(NAME, viewComponent);
        }

        override public function listNotificationInterests():Array {
            return [ApplicationEvent.SECTION_REMOVED, ApplicationEvent.SECTION_OPENED ];
        }

        override public function handleNotification(notify:INotification):void {
            switch(notify.getName()) {
                case ApplicationEvent.SECTION_REMOVED :
                    viewComponent = null;
                    facade.removeMediator(NAME);
                    break;
                case ApplicationEvent.SECTION_OPENED :
                    ProfileSection(viewComponent).animateIn();
                    break;
                default :
            }
        }
    }
}
