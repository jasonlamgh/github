/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:58
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.section {
    import com.twentythree.log.Logger;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.event.SectionEvent;
    import com.website.view.component.ui.Line;
    import com.website.view.component.ui.Title;

    import flash.display.MovieClip;

    public class ProfileSection extends AbstractSection implements ISection {

        public static const SECTION_NAME:String = "profile";

        private var content:MovieClip;
        private var title:Title;
        private var line:Line;

        public function ProfileSection() {
            init();
        }

        private function init():void {
            title           = new Title(LocaleCopyManager.getInstance().retrieveCopy("profile.copy"));
            title.y         = 10;

            line           = new Line();
            line.y         = title.y + title.height + 10;

            content         = LibraryManager.getInstance().getMovieClip("library", "Profile");
            content.y       = title.y + title.height + 50;
            content.x       = 30;

            this.alpha      = 0;

            addChild(title);
            addChild(content);
            addChild(line);
        }

        override public function closeSection():void {
            Logger.getInstance().info("start", "AbstractSection", "closeSection");

            removeChild(title);
            removeChild(content);
            removeChild(line);

            var event:* = new SectionEvent(SectionEvent.SECTION_CLOSING, getSectionName());
            dispatchEvent(event);
            closed();
        }

        override public function getSectionName() : String {
            return SECTION_NAME;
        }
    }
}
