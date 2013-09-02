/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:58
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.section {
    import com.greensock.TweenMax;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.LocaleCopyManager;
    import com.website.event.ApplicationEvent;
    import com.website.event.SectionEvent;
    import com.website.model.collection.WorkCollection;
    import com.website.view.component.gallery.WorkGallery;
    import com.website.view.component.ui.Line;
    import com.website.view.component.ui.Title;

    import flash.display.Sprite;

    import org.puremvc.as3.interfaces.IFacade;

    public class WorkSection extends AbstractSection implements ISection {

        public static const SECTION_NAME:String = "work";

        private var facade:IFacade;

        private var content:Sprite;
        private var title:Title;
        private var gallery:WorkGallery;
        private var data:WorkCollection;
        private var line:Line;

        public function WorkSection(facade:IFacade) {
            this.facade    = facade;

            title           = new Title(LocaleCopyManager.getInstance().retrieveCopy("work.copy"));
            title.y         = 10;

            this.alpha      = 0;

            content         = new Sprite();
            content.y       = title.y + title.height + 10;

            addChild(title);
            addChild(content);

            this.facade.sendNotification(ApplicationEvent.RESIZE);
        }

        public function init(data:WorkCollection):void {
            this.data = data;

            gallery     = new WorkGallery(data, facade);
            content.addChild(gallery);

            facade.sendNotification(ApplicationEvent.RESIZE);
            animateIn();
        }

        override public function closeSection():void {
            Logger.getInstance().info("start", "AbstractSection", "closeSection");

            var event:* = new SectionEvent(SectionEvent.SECTION_CLOSING, getSectionName());
            dispatchEvent(event);

            dispose();
            closed();
        }

        override public function getSectionName():String {
            return SECTION_NAME;
        }

        public function dispose():void {
            gallery.dispose();
        }
    }
}
