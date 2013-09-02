/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:30
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;

    import flash.display.Sprite;

    public class Footer extends BaseSprite {
        private var footer:BaseTextField;
        private var line:Sprite;

        public function Footer() {
            var text:String = LocaleCopyManager.getInstance().retrieveCopy("footer.copy");
            footer          = new BaseTextField(text);

            footer.setCSS(LibraryManager.getInstance().getCSS());
            footer.render();

            footer.textfld.selectable = true;
            footer.y        = 10;

            line = new Sprite();

            line.graphics.beginFill(0xCCCCCC, 1.0);
            line.graphics.drawRect(0, 0, 760, 0.2);
            line.graphics.endFill();

            line.x = 20;

            var padding:Sprite = new Sprite();
            padding.graphics.beginFill(0x000000, 0);
            padding.graphics.drawRect(0,0, 10, 35);
            padding.graphics.endFill();

            addChild(footer);
            addChild(line);
            addChild(padding);
            padding.y = this.height;
        }
    }
}
