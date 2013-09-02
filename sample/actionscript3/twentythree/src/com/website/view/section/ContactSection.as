/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:58
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.section {
    import com.twentythree.display.BaseTextField;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.view.component.ui.Line;
    import com.website.view.component.ui.Title;

    import flash.display.MovieClip;

    public class ContactSection extends AbstractSection {

        public static const SECTION_NAME:String = "contact";

        private var title:Title;
        private var tfld:BaseTextField;
        private var line:Line;

        public function ContactSection() {
            init();
        }

        private function init():void {
            title           = new Title(LocaleCopyManager.getInstance().retrieveCopy("contact.copy"));
            title.y         = 10;

            line            = new Line();
            line.y          = title.y + title.height + 10;

            var text:String = LocaleCopyManager.getInstance().retrieveCopy("contact.detail.copy");
            tfld            = new BaseTextField(text);
            tfld.setCSS(LibraryManager.getInstance().getCSS());
            tfld.render();

            tfld.y          = line.y + 20;
            tfld.textfld.selectable = true;

            addChild(title);
            addChild(line);
            addChild(tfld);
        }

        override public function getSectionName() : String {
            return SECTION_NAME;
        }
    }
}
