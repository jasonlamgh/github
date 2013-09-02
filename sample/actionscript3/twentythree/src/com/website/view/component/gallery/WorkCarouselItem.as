/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 30/05/2011
 * Time: 02:27
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.gallery {
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;

    import com.greensock.TweenMax;

    import com.twentythree.display.BaseSprite;
    import com.twentythree.manager.LibraryManager;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;

    public class WorkCarouselItem extends BaseSprite {

        private var image:String;
        private var psq:Bitmap;
        private var psqh:Bitmap;
        private var overlay:Sprite;
        private var key:String;
        private var bulkloader:BulkLoader;
        private var bg:Sprite;
        private var preloader:Sprite;

        public function WorkCarouselItem(image:String, key:String) {
            this.image = image;
            this.key = key;



            psqh = LibraryManager.getInstance().getBitmap("pattern.square.horizontal.image");
            psq = LibraryManager.getInstance().getBitmap("pattern.square.image");

            bg = new Sprite();
            bg.graphics.beginFill(0xe5e5e5, 1);
            bg.graphics.drawRect(0,0, 760, 475);
            bg.graphics.endFill();

            preloader = new Sprite();
            preloader.graphics.clear();
            preloader.graphics.beginBitmapFill(psq.bitmapData);
            preloader.graphics.moveTo(0, 0);
            preloader.graphics.lineTo(760, 0);
            preloader.graphics.lineTo(760, 475);
            preloader.graphics.lineTo(0, 475);
            preloader.graphics.lineTo(0, 0);
            preloader.graphics.endFill();

            overlay = new Sprite();
            overlay.graphics.clear();
            overlay.graphics.beginBitmapFill(psqh.bitmapData);
            overlay.graphics.moveTo(0, 0);
            overlay.graphics.lineTo(760, 0);
            overlay.graphics.lineTo(760, 475);
            overlay.graphics.lineTo(0, 475);
            overlay.graphics.lineTo(0, 0);
            overlay.graphics.endFill();

            addChild(bg);
            addChild(overlay);
            addChild(preloader);

            preloader.width = 0;

            bulkloader = new BulkLoader(key);
            bulkloader.add(image, {id:key});
            bulkloader.start();
            bulkloader.addEventListener(Event.COMPLETE, complete);
            bulkloader.addEventListener(BulkProgressEvent.PROGRESS, progress);
        }

        private function progress(e:BulkProgressEvent):void {
            if(e._percentLoaded == 1) { bulkloader.removeEventListener(BulkProgressEvent.PROGRESS, progress) };
            preloader.width = e._percentLoaded * 475;
        }

        private function complete(e:Event):void {
            bulkloader.removeEventListener(Event.COMPLETE, complete);

            preloader.parent.removeChild(preloader);
            preloader.visible = false;

            var bitmap:Bitmap = bulkloader.getBitmap(key);
            var mask:Sprite = new Sprite();
            bitmap.smoothing = true;

            mask.graphics.beginFill(0, 1);
            mask.graphics.drawRect(0, 0, 760, 475);
            mask.graphics.endFill();

            bitmap.mask = mask;
            mask.width = 0;

            addChild(mask);
            addChild(bitmap);

            TweenMax.to(mask, 0.75, {width:760});
        }

        public function dispose():void {
            try {
                bulkloader.clear();
                bulkloader = null;
            } catch(e:Error) {
            }
        }
    }
}
