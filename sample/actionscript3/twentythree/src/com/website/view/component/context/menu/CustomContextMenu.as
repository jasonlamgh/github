package com.website.view.component.context.menu {
    import com.twentythree.log.Logger;

    import com.twentythree.manager.PropertiesManager;

    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.ContextMenuEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;

    /**
     * User: jasonlam
     * Date: 07/02/2011
     * Time: 16:51
     * To change this template use File | Settings | File Templates.
     */
    public class CustomContextMenu {

        private static var instance:CustomContextMenu;

        public var cm:ContextMenu;

        private var company:ContextMenuItem;
        private var copyright:ContextMenuItem;
        private var email:ContextMenuItem;
        private var tel:ContextMenuItem;

        public function CustomContextMenu() { }

        public static function getInstance():CustomContextMenu {
            if(instance == null) instance = new CustomContextMenu();
            return instance;
        }

        public function customize():ContextMenu {
            cm          = new ContextMenu();


            company     = new ContextMenuItem(PropertiesManager.getInstance().getProperty("website.company"));
            copyright   = new ContextMenuItem(PropertiesManager.getInstance().getProperty("website.copyright"));
            email       = new ContextMenuItem(PropertiesManager.getInstance().getProperty("website.email"), true);
            tel         = new ContextMenuItem(PropertiesManager.getInstance().getProperty("website.tel"), true);

            cm.customItems.push(company, copyright, email);

            tel.separatorBefore = false;
            company.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, click);
            email.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, click);

            cm.hideBuiltInItems();
            return cm;
        }

        private function click(e:ContextMenuEvent):void {
            Logger.getInstance().info("start", "CustomContextMenu", "click");
            switch(e.currentTarget) {
                case company :
                    break;
                case email :
                    navigateToURL(new URLRequest("mailto:jason.lam@live.com"));
                    break;
                default:
            }
        }
    }
}
