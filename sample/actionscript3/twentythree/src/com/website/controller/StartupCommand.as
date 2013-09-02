/**
 * User: jasonlam
 * Date: 28/01/2011
 * Time: 14:43
 * To change this template use File | Settings | File Templates.
 */

package com.website.controller {
    import com.twentythree.log.Logger;
    import com.website.model.proxy.ResourceProxy;
    import com.website.model.proxy.WorkProxy;
    import com.website.view.DisplayMediator;
    import com.website.view.StageMediator;
    import com.website.view.component.app.BaseDisplay;

    import flash.display.Stage;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    public class StartupCommand extends SimpleCommand implements ICommand {

        public function StartupCommand() {
        }

        override public function execute(notify:INotification):void {
            Logger.getInstance().debug("start", "StartupCommand", "execute");

            var stage:Stage = facade.retrieveMediator(StageMediator.NAME).getViewComponent() as Stage;
            var display:BaseDisplay = new BaseDisplay(stage);
            var displayMediator:DisplayMediator = new DisplayMediator(display);

            /* Register Secondary Proxy */
            facade.registerProxy(new WorkProxy());
            facade.registerMediator(displayMediator);
            ResourceProxy(facade.retrieveProxy(ResourceProxy.NAME)).startup();


        }
    }
}