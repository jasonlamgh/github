/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 26/05/2011
 * Time: 00:01
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;

    import flash.display.MovieClip;
    import flash.display.Sprite;

    public class Header extends BaseSprite {

        private var logo:MovieClip;
        private var textfld:BaseTextField;

        private var _mask:Sprite;

        public function Header() {
            var text:String = LocaleCopyManager.getInstance().retrieveCopy("header.description.copy");

            logo            = LibraryManager.getInstance().getMovieClip("library", "Logo");
            textfld         = new BaseTextField(text);

            textfld.setCSS(LibraryManager.getInstance().getCSS());
            textfld.render();
//            textfld.y       = logo.y + logo.height - 35;
            textfld.y       = logo.y + logo.height;

            addChild(logo);
            addChild(textfld);

            _mask    = new Sprite();
            _mask.graphics.beginFill(0, 0.5);
            _mask.graphics.drawRect(0, 0, this.width, this.height);
            _mask.graphics.endFill();

            addChild(_mask);
            this.mask   = _mask;
            _mask.width = 0;
        }

        public function getMask():Sprite {
            return _mask;
        }
    }
}
