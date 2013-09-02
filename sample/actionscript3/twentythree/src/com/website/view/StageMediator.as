/**
 * User: jasonlam
 * Date: 28/01/2011
 * Time: 14:43
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import com.asual.SWFAddress;
    import com.asual.SWFAddressEvent;
    import com.greensock.TimelineMax;
    import com.greensock.TweenMax;
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.view.component.app.BaseDisplay;
    import com.website.view.component.ui.Header;
    import com.website.view.component.ui.Nav;
    import com.website.view.section.HomeSection;
    import com.website.view.section.ProfileSection;
    import com.website.view.section.WorkSection;

    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class StageMediator extends Mediator implements IMediator {

        public static const NAME:String = "StageMediator";

        private var ignoreSWFAddressChange:Boolean = false;

        public function StageMediator(stage:Stage) {
            super(NAME, stage);

            Logger.getInstance().debug("start", "StageMediator", "StageMediator");

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = 25;
            stage.addEventListener(Event.RESIZE, resize);
        }

        override public function listNotificationInterests():Array {
            return [ApplicationEvent.ATTACH_DISPLAY];
        }

        override public function handleNotification(notify:INotification):void {
            Logger.getInstance().debug("start type=" + notify.getName(), "StageMediator", "handleNotification");

            switch (notify.getName()) {
                case ApplicationEvent.ATTACH_DISPLAY :
                    var app:BaseDisplay = BaseDisplay(facade.retrieveMediator(DisplayMediator.NAME).getViewComponent());
                    app.show();

                    var nav:Nav         = app.navigation.getChildAt(0) as Nav;
                    var header:Header   = app.header.getChildAt(0) as Header;
                    var tl:TimelineMax  = new TimelineMax({onComplete:function():void{
                        initSWFAddress();
                    }});

                    tl.append(TweenMax.to(header.getMask(), 1.25, {width:800,
                            onComplete:function():void{
                                TweenMax.to(nav.alphatfld, 1.25, {autoAlpha:1,
                                        onComplete:function():void{
                                            TweenMax.to(nav.tfld, 1.25, {autoAlpha:1});
                                            TweenMax.to(nav.alphatfld, 1.25, {autoAlpha:0});
                                        }});
                            }}));
                    tl.play();
                    break;
                default :
            }
        }

        private function initSWFAddress():void {
            Logger.getInstance().debug("start", "StageMediator", "initSWFAddress");
            SWFAddress.addEventListener(SWFAddressEvent.CHANGE, handleSWFAddressChange);
            return;
        }

        private function handleSWFAddressChange(e:SWFAddressEvent):void {
            Logger.getInstance().debug("start", "StageMediator", "handleSWFAddressChange");

            var swfaddress:String = e.value as String;
            Logger.getInstance().debug("swfaddress="+swfaddress, "StageMediator", "handleSWFAddressChange");

            switch(swfaddress) {
                case WorkSection.SECTION_NAME :
                    break;
                case ProfileSection.SECTION_NAME :
                    break;
                case HomeSection.SECTION_NAME :
                    break;
                default:
//                    sendNotification(ApplicationEvent.SECTION_REQUEST, swfaddress);
                    sendNotification(ApplicationEvent.SECTION_REQUEST, "home");
                    break;
            }
        }

        private function notifySWFAddress(e:INotification):void {
            //SWFAddress.setValue();
            //SWFAddress.setTitle();
        }

        private function resize(e:Event):void {
            Logger.getInstance().debug("start", "StageMediator", "resize");

            var display:DisplayMediator = facade.retrieveMediator(DisplayMediator.NAME) as DisplayMediator;
            BaseDisplay(display.getViewComponent()).resize();
        }

        override public function getViewComponent():Object {
            return viewComponent as Stage;
        }

    }
}
