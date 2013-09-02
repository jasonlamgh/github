/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 27/05/2011
 * Time: 02:09
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.event.SectionEvent;
    import com.website.view.section.ISection;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class SectionMediator extends Mediator implements IMediator {

        public static const NAME:String = "SectionMediator";

        private var nextSegment:String;

        public function SectionMediator(viewComponent:*) {
            super(NAME, viewComponent);

            Logger.getInstance().debug("viewComplete="+viewComponent, "SectionMediator", "SectionMediator");

            ISection(viewComponent).addEventListener(SectionEvent.SECTION_CLOSING, onSectionClosing, false, 0, true);
            ISection(viewComponent).addEventListener(SectionEvent.SECTION_CLOSED, onSectionClosed, false, 0, true);
        }

        override public function listNotificationInterests():Array {
            return [ApplicationEvent.SECTION_CHANGE];
        }

        override public function handleNotification(notify:INotification):void {
            Logger.getInstance().info("start notify="+notify.getName(), "SectionMediator", "handleNotification");

            switch(notify.getName()) {
                case ApplicationEvent.SECTION_CHANGE :
                    nextSegment = notify.getBody() as String;
                    Logger.getInstance().info("nextSegment="+nextSegment, "SectionMediator", "handleNotification");
                    ISection(viewComponent).closeSection();
                    break;
                default :
            }
        }

        private function onSectionClosing(e:SectionEvent):void {
            Logger.getInstance().info("start", "SectionMediator", "onSectionClosing");

            ISection(viewComponent).removeEventListener(SectionEvent.SECTION_CLOSING, onSectionClosing);
//            sendNotification(ApplicationEvent.SECTION_CLOSING, nextSegments);
        }

        private function onSectionClosed(e:SectionEvent):void {
            Logger.getInstance().info("start", "SectionMediator", "onSectionClosed");

            ISection(viewComponent).removeEventListener(SectionEvent.SECTION_CLOSED, onSectionClosed);
            sendNotification(ApplicationEvent.SECTION_REMOVE, nextSegment);
        }
    }
}