/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:58
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.section {
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.view.component.ui.Line;
    import com.website.view.component.ui.Title;

    import flash.display.MovieClip;

    public class HomeSection extends AbstractSection {

        public static const SECTION_NAME:String = "home";

        private var title:Title;

        public function HomeSection() {
            init();
        }

        private function init():void {
            title           = new Title(LocaleCopyManager.getInstance().retrieveCopy("home.copy"));
            title.y         = 10;

//            addChild(title);
        }

        override public function getSectionName() : String {
            return SECTION_NAME;
        }
    }
}
