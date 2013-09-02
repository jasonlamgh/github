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
    import com.website.view.SectionContactMediator;
    import com.website.view.SectionHomeMediator;
    import com.website.view.SectionMediator;
    import com.website.view.SectionProfileMediator;
    import com.website.view.SectionWorkMediator;
    import com.website.view.component.app.BaseDisplay;
    import com.website.view.section.ContactSection;
    import com.website.view.section.HomeSection;
    import com.website.view.section.ISection;
    import com.website.view.section.ProfileSection;
    import com.website.view.section.WorkSection;

    import flash.display.Sprite;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    public class SectionCreateCommand extends SimpleCommand implements ICommand {

        public function SectionCreateCommand() { }

        override public function execute(notify:INotification):void {
            Logger.getInstance().info("start", "SectionCreateCommand", "execute");

            if(facade.retrieveMediator(SectionMediator.NAME))
                throw new Error("You cannot create a section if one already exists! Use the RequestSectionCommand instead.");

            var section:ISection;
            var mediator:IMediator;
            var param:String = notify.getBody() as String;

            Logger.getInstance().info("section="+param, "SectionCreateCommand", "execute");

            switch(param) {
                case ProfileSection.SECTION_NAME :
                    section    = new ProfileSection();
                    mediator   = new SectionProfileMediator(section);
                    break;

                case WorkSection.SECTION_NAME :
                    section    = new WorkSection(facade);
                    mediator   = new SectionWorkMediator(section);
                    break;

                case HomeSection.SECTION_NAME :
                    section    = new HomeSection();
                    mediator   = new SectionHomeMediator(section);
                    break;

                case ContactSection.SECTION_NAME :
                    section    = new ContactSection();
                    mediator   = new SectionContactMediator(section);
                    break;

                default :
            }

            if(mediator == null) {
                Logger.getInstance().info("Mediator is null. Cannot register and addChild()", "SectionCreateCommand", "execute");
                return;
            }

            facade.registerMediator(mediator);
            facade.registerMediator(new SectionMediator(section));

            var display:BaseDisplay = facade.retrieveMediator(DisplayMediator.NAME).getViewComponent() as BaseDisplay;
            display.body.addChild(section as Sprite);
            display.resize();

            sendNotification(ApplicationEvent.SECTION_OPENED, param);
        }
    }
}