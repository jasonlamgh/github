/**
 * User: jasonlam
 * Date: 28/01/2011
 * Time: 14:43
 * To change this template use File | Settings | File Templates.
 */
package com.website.controller {
    import com.soma.utils.FPS;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.event.ApplicationEvent;
    import com.website.view.DisplayMediator;
    import com.website.view.component.app.BaseDisplay;
    import com.website.view.component.ui.Footer;
    import com.website.view.component.ui.Header;
    import com.website.view.component.ui.Nav;
    import com.website.view.section.ProfileSection;

    import flash.display.Sprite;

    import flash.events.MouseEvent;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    public class AttachDisplayCommand extends SimpleCommand implements ICommand {

        public function AttachDisplayCommand() { }

        override public function execute(notify:INotification):void {
            Logger.getInstance().debug("start", "AttachDisplayCommand", "execute");

            LocaleCopyManager.getInstance().appendByXML(LibraryManager.getInstance().getXML("copy.xml"));

            var display:BaseDisplay = facade.retrieveMediator(DisplayMediator.NAME).getViewComponent() as BaseDisplay;

            var nav:Nav         = new Nav(facade);
            var footer:Footer   = new Footer();
            var header:Header   = new Header();

            display.header.addChild(header);
            display.navigation.addChild(nav);
            display.footer.addChild(footer);
            display.resize();
        }
    }
}