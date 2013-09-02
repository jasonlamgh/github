/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 28/05/2011
 * Time: 13:57
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.gallery {
    import com.greensock.TweenMax;
    import com.twentythree.display.BaseSprite;
    import com.twentythree.log.Logger;
    import com.website.event.ApplicationEvent;
    import com.website.model.collection.WorkCollection;
    import com.website.model.vo.WorkVO;
    import com.website.view.component.gallery.GalleryEvent;

    import flash.display.Sprite;

    import org.puremvc.as3.interfaces.IFacade;

    public class WorkGallery extends BaseSprite {

        private var facade:IFacade;

        private var collection:WorkCollection;
        private var opened:WorkGalleryItem;
        private var data:Array;

        private var blank:Sprite;

        private var status:Boolean = false;

        public function WorkGallery(collection:WorkCollection, facade:IFacade) {
            this.facade = facade;
            this.collection = collection;

            init()
        }

        private function init():void {
            Logger.getInstance().debug("start", "WorkGallery", "init");

            var list:Array = collection.list;
            var temp:WorkGalleryItem;

            data = new Array();
            for (var i:int = 0; i < list.length; i++) {
                var vo:WorkVO = list[i];

                var item:WorkGalleryItem = new WorkGalleryItem(vo, i*0.1);

                item.addEventListener(GalleryEvent.CAROUSEL_REQUEST, galleryHandler);
                data.push(item);

                addChild(item);

                if(temp) {
                    item.y = temp.y + temp.height + 10;
                }

                temp = item;
            }

//            blank = new Sprite();
//            blank.graphics.beginFill(0x000000, 0);
//            blank.graphics.drawRect(0,0, 800, 23);
//            blank.graphics.endFill();
//            addChild(blank);
//
//            blank.y = temp.y + temp.height + 10;
        }

        private function galleryHandler(e:GalleryEvent):void {
            switch(e.type) {
                case GalleryEvent.CAROUSEL_REQUEST :
                    if(opened) {close(e.target as WorkGalleryItem)}
                    else {open(e.target as WorkGalleryItem)}
                    break;
                default :
            }
        }

        private function open(target:WorkGalleryItem):void {
            Logger.getInstance().debug("start target="+target, "WorkGallery", "open");

            var temp:WorkGalleryItem;

            var count:int       = 0;
            var total:Number    = 0;

            var _yarray:Array = new Array();
            for (var j:int = 0; j < data.length; j++) {
                var _item:WorkGalleryItem = data[j];

                total = 0;
                for (var m:int = 0; m < j; m++) {
                    var __item:WorkGalleryItem = data[m];
                    total += __item.height + 10;
                }
                Logger.getInstance().debug("total="+total, "WorkGallery", "open");
                _yarray.push(total);
            }

            this.opened = target;
            temp        = null;

            for (var i:int = 0; i < data.length; i++) {
                var item:WorkGalleryItem = data[i];

                TweenMax.to(item, 0.75, {y:_yarray[i],
                        onComplete:function():void{
                            count++;
                            if(count == data.length) {
                                if(!status) {facade.sendNotification(ApplicationEvent.RESIZE); status = true;}
                                target.show();
                            }
                        }});

                temp = item;
            }


        }

        private function close(target:WorkGalleryItem):void {
            opened.hide();
            open(target);
        }

        public function dispose():void {
            for (var i:int = 0; i < data.length; i++) {
                var item:WorkGalleryItem = data[i];
                item.dispose();
            }
        }
    }
}
