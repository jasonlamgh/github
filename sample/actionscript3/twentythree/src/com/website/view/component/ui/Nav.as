/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 22:46
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.event.ApplicationEvent;

    import flash.display.Sprite;
    import flash.events.TextEvent;

    import org.puremvc.as3.interfaces.IFacade;

    public class Nav extends BaseSprite {

        private var facade:IFacade;

        private var _tfld:BaseTextField;
        private var _alphatfld:BaseTextField;
        private var line:Line;

        private var _mask:Sprite;

        public function Nav(facade:IFacade) {

            this.facade = facade;

            var text:String         = LocaleCopyManager.getInstance().retrieveCopy("nav.copy");
            var alphatext:String    = LocaleCopyManager.getInstance().retrieveCopy("nav.alpha.copy");

            _tfld = new BaseTextField(text);
            _tfld.setCSS(LibraryManager.getInstance().getCSS());
            _tfld.render();

            _alphatfld = new BaseTextField(alphatext);
            _alphatfld.setCSS(LibraryManager.getInstance().getCSS());
            _alphatfld.render();

            _tfld.alpha         = 0;
            _alphatfld.alpha    = 0;

            line    = new Line();
            line.y  = _tfld.height + _tfld.y + 20;

            addChild(_alphatfld);
            addChild(_tfld);
            addChild(line);

            _mask    = new Sprite();
            _mask.graphics.beginFill(0, 0.5);
            _mask.graphics.drawRect(0, 0, this.width, this.height);
            _mask.graphics.endFill();

            _tfld.addEventListener(TextEvent.LINK, linkHandler);
        }

        private function linkHandler(e:TextEvent):void {
            facade.sendNotification(ApplicationEvent.SECTION_REQUEST, e.text);
        }

        public function get tfld():BaseTextField {
            return _tfld;
        }

        public function get alphatfld():BaseTextField {
            return _alphatfld;
        }
    }
}
