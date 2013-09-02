package com.website {
    import com.twentythree.log.Logger;
    import com.website.controller.AttachDisplayCommand;
    import com.website.controller.SectionCreateCommand;
    import com.website.controller.SectionRemoveCommand;
    import com.website.controller.SectionRequestCommand;
    import com.website.controller.StartupCommand;
    import com.website.event.ApplicationEvent;
    import com.website.model.proxy.ResourceProxy;
    import com.website.view.StageMediator;

    import flash.display.Stage;

    import org.puremvc.as3.interfaces.IFacade;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.facade.Facade;
    import org.puremvc.as3.patterns.observer.Notification;

    public class ApplicationFacade extends Facade implements IFacade {

        public static const NAME:String = "ApplicationFacade";

        public function ApplicationFacade() { }

        override protected function initializeController():void {
            Logger.getInstance().debug("start", "ApplicationFacade", "initializeController");
            super.initializeController();

            registerCommand(ApplicationEvent.STARTUP, StartupCommand);
            registerCommand(ApplicationEvent.ATTACH_DISPLAY, AttachDisplayCommand);
            registerCommand(ApplicationEvent.SECTION_REQUEST, SectionRequestCommand);
            registerCommand(ApplicationEvent.SECTION_CREATE, SectionCreateCommand);
            registerCommand(ApplicationEvent.SECTION_REMOVE, SectionRemoveCommand);
        }

        public function startup(stage:Stage):void {
            Logger.getInstance().debug("start", "ApplicationFacade", "startup");

            registerProxy(new ResourceProxy());
            registerMediator(new StageMediator(stage));

            ResourceProxy(retrieveProxy(ResourceProxy.NAME)).init();
        }
    }
}
