/**
 * User: jasonlam
 * Date: 28/01/2011
 * Time: 14:43
 * To change this template use File | Settings | File Templates.
 */

package com.website.controller {
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.view.DisplayMediator;
    import com.website.view.SectionMediator;
    import com.website.view.component.app.BaseDisplay;

    import flash.display.Sprite;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    public class SectionRemoveCommand extends SimpleCommand implements ICommand {

        public function SectionRemoveCommand() { }

        override public function execute(notify:INotification):void {
            Logger.getInstance().info("start", "SectionRemoveCommand", "execute");

            var display:BaseDisplay  = facade.retrieveMediator(DisplayMediator.NAME).getViewComponent() as BaseDisplay;
            var section:SectionMediator     = facade.retrieveMediator(SectionMediator.NAME) as SectionMediator;

            Logger.getInstance().info("mediator="+facade.retrieveMediator(SectionMediator.NAME), "SectionRemoveCommand", "execute");
            if(facade.retrieveMediator(SectionMediator.NAME) == null) return;

            facade.removeMediator(SectionMediator.NAME);
            sendNotification(ApplicationEvent.SECTION_REMOVED);
            display.body.removeChild(section.getViewComponent() as Sprite);

            Logger.getInstance().debug("display.body.height="+display.body.height, "SectionRemoveCommand", "execute");

            var param:String = notify.getBody() as String;
            Logger.getInstance().info("param="+param, "SectionRemoveCommand", "execute");
            sendNotification(ApplicationEvent.SECTION_REQUEST, param);
        }
    }
}