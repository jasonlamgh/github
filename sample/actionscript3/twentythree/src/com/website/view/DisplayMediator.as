/**
 * User: jasonlam
 * Date: 31/01/2011
 * Time: 17:27
 * To change this template use File | Settings | File Templates.
 */
package com.website.view {
    import br.com.stimuli.loading.BulkProgressEvent;

    import com.greensock.TweenMax;

    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.view.component.app.BaseDisplay;

    import mx.core.Application;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;

    public class DisplayMediator extends Mediator implements IMediator {

        public static const NAME:String = "DisplayMediator";
        private var status:Boolean = false;

        public function DisplayMediator(viewComponent:*) {
            super(NAME, viewComponent);
        }

        override public function listNotificationInterests():Array {
            return [ApplicationEvent.STARTUP_COMPLETE, ApplicationEvent.RESIZE, ApplicationEvent.STARTUP_PROGRESS];
        }

        override public function handleNotification(notify:INotification):void {
            Logger.getInstance().debug("start type="+notify.getName(), "DisplayMediator", "handleNotification");
            var based:BaseDisplay = viewComponent as BaseDisplay;

            switch(notify.getName()) {
                case ApplicationEvent.STARTUP_COMPLETE :

                    TweenMax.to(based.message, 1.75, {autoAlpha:0, delay:2, onComplete:function():void{
                                sendNotification(ApplicationEvent.ATTACH_DISPLAY);
                            }});

                    break;

                case ApplicationEvent.RESIZE :
                    Logger.getInstance().debug("resize", "DisplayMediator", "handleNotification");
                    based.resize();
                    break;

                case ApplicationEvent.STARTUP_PROGRESS :
                    var param:BulkProgressEvent = notify.getBody() as BulkProgressEvent;
                    if(status) {return;}
                    if(param._percentLoaded == 1) { status = true };
                    Logger.getInstance().debug("progress="+param._percentLoaded+" width="+based.canvas.width, "DisplayMediator", "handleNotification");
                    based.preloader.x = param._percentLoaded * based.canvas.width;
                    break;
                default :
            }
        }
    }
}
