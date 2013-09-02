/**
 * User: jasonlam
 * Date: 28/01/2011
 * Time: 14:43
 * To change this template use File | Settings | File Templates.
 */

package com.website.controller {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.view.SectionMediator;
    import com.website.view.section.ISection;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    public class SectionRequestCommand extends SimpleCommand implements ICommand {

        public function SectionRequestCommand() { }

        override public function execute(notify:INotification):void {
            Logger.getInstance().debug("start", "SectionRequestCommand", "execute");

            var mediator:SectionMediator = facade.retrieveMediator(SectionMediator.NAME) as SectionMediator;
            var             param:String = notify.getBody() as String;

            Logger.getInstance().info("mediator="+mediator+" section="+param, "SectionRequestCommand", "execute");

            if(mediator) sendNotification(ApplicationEvent.SECTION_CHANGE, param);
            else sendNotification(ApplicationEvent.SECTION_CREATE, param);

        }
    }
}