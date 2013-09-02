/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 22:30
 * To change this template use File | Settings | File Templates.
 */

package com.website.view.section {
    import com.greensock.TweenMax;
    import com.twentythree.log.Logger;
    import com.website.event.SectionEvent;

    import flash.display.Sprite;

    public class AbstractSection extends Sprite implements ISection {

        public static const SECTION_NAME:String = "abstract section";

        public function AbstractSection() {
        }

        public function animateIn():void {
            var delay:Number = 0;

            CONFIG::DEBUG { delay=0 }

            TweenMax.to(this, 0.25, {autoAlpha:1, delay:delay});
        }

        public function getSectionName():String {
            return SECTION_NAME;
        }

        public function resize():void {

        }

        public function closeSection():void {
            Logger.getInstance().info("start", "AbstractSection", "closeSection");

            var event:* = new SectionEvent(SectionEvent.SECTION_CLOSING, getSectionName());
            dispatchEvent(event);
            closed();
        }

        public function closed():void {
            Logger.getInstance().debug("start", "AbstractSection", "closed");

            var event:* = new SectionEvent(SectionEvent.SECTION_CLOSED, getSectionName());
            dispatchEvent(event);
        }

    }
}
