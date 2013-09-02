/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 28/05/2011
 * Time: 13:57
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.gallery {
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;

    import com.bigspaceship.utils.Lib;
    import com.greensock.TweenMax;
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.LibraryManager;
    import com.website.model.vo.WorkVO;
    import com.website.view.SectionProfileMediator;
    import com.website.view.component.ui.Line;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.describeType;

    import mx.controls.Text;

    import org.osmf.utils.URL;

    public class WorkGalleryItem extends BaseSprite {

        private var vo:WorkVO;
        private var label:BaseTextField;
        private var title:BaseTextField;
        private var description:BaseTextField;
        private var image:Sprite;
        private var tint:Sprite;
        private var patternsq:Bitmap;
        private var patternsqh:Bitmap;
        private var background:Sprite;
        private var ln:Line;
        private var msktinit:Sprite;
        private var bulkloader:BulkLoader;
        private var carousel:WorkCarousel;
        private var delay:Number;

        private var _hitArea:Sprite;
        private var _status:Boolean = false;


        public function WorkGalleryItem(obj:WorkVO, delay:Number = 0) {
            this.vo = obj;
            this.delay = 0

            CONFIG::DEBUG {
                this.delay = delay;
            }

            init();
        }

        private function init():void {

            label = new BaseTextField(vo.label);
            label.setCSS(LibraryManager.getInstance().getCSS());
            label.render();

            title = new BaseTextField(vo.title);
            title.setCSS(LibraryManager.getInstance().getCSS());
            title.render();

            description = new BaseTextField(vo.description);
            description.setCSS(LibraryManager.getInstance().getCSS());
            description.render();

            carousel = new WorkCarousel(760, 475, vo.gallery, vo.id);

            image = new Sprite();
            tint = new Sprite();
            background = new Sprite();
            _hitArea = new Sprite();
            ln = new Line();

            patternsqh = LibraryManager.getInstance().getBitmap("pattern.square.horizontal.image");
            patternsq = LibraryManager.getInstance().getBitmap("pattern.square.image");

            background.graphics.beginFill(0xececec);
            background.graphics.drawRect(0, 0, 760, 80);
            background.graphics.endFill();

            image.graphics.clear();
            image.graphics.beginBitmapFill(patternsqh.bitmapData);
            image.graphics.moveTo(0, 0);
            image.graphics.lineTo(760, 0);
            image.graphics.lineTo(760, 80);
            image.graphics.lineTo(0, 80);
            image.graphics.lineTo(0, 0);
            image.graphics.endFill();

            tint.graphics.clear();
            tint.graphics.beginBitmapFill(patternsq.bitmapData);
            tint.graphics.moveTo(0, 0);
            tint.graphics.lineTo(760, 0);
            tint.graphics.lineTo(760, 80);
            tint.graphics.lineTo(0, 80);
            tint.graphics.lineTo(0, 0);
            tint.graphics.endFill();
            tint.alpha = 0.5;

            msktinit = new Sprite();
            msktinit.graphics.beginFill(0, 0);
            msktinit.graphics.drawRect(0, 0, 760, 80);
            msktinit.graphics.endFill();
            tint.mask = msktinit;
            msktinit.width = 0;

            addChild(ln);
            addChild(label);
            addChild(title);
            addChild(description);
            addChild(background);
            addChild(image);
            addChild(tint);
            addChild(msktinit);
            addChild(_hitArea);

            this.hitArea = _hitArea;
            this.buttonMode = true;

            resize();
            drawHitArea();

            _hitArea.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            _hitArea.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
            _hitArea.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);

            TweenMax.to(this, 0.75, {autoAlpha:0.25});

            bulkloader = new BulkLoader("banner-id-" + vo.id);
            bulkloader.add(vo.image, {id:"image"});
            bulkloader.addEventListener(Event.COMPLETE, complete);
            bulkloader.addEventListener(BulkProgressEvent.PROGRESS, progress);
            bulkloader.start();
        }

        private function progress(e:BulkProgressEvent):void {
            Logger.getInstance().debug("e._percentLoaded="+e._percentLoaded, "WorkGalleryItem", "progress");
            msktinit.width = 780 * e._percentLoaded;

            if(e._percentLoaded == 1) { bulkloader.removeEventListener(BulkProgressEvent.PROGRESS, progress); }
        }

        private function complete(e:Event):void {
            bulkloader.removeEventListener(Event.COMPLETE, complete);

            var bitmap:Bitmap = bulkloader.getBitmap("image");
            var _width:Number = bitmap.width;
            var mask:Sprite = new Sprite();
            bitmap.smoothing = true;

            mask.graphics.beginFill(0, 1);
            mask.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
            mask.graphics.endFill();

            bitmap.mask = mask;
            mask.width = 0;

            image.addChild(mask);
            image.addChild(bitmap);

            TweenMax.to(mask, 0.75, {width:_width, delay:delay});

            description.addEventListener(TextEvent.LINK, lHandler);
        }

        private function mouseHandler(e:MouseEvent):void {
            switch (e.type) {
                case MouseEvent.MOUSE_OVER :
                    TweenMax.to(this, 0.75, {autoAlpha:1});
                    break;

                case MouseEvent.MOUSE_OUT :
                    TweenMax.to(this, 0.75, {autoAlpha:0.25});
                    break;

                case MouseEvent.MOUSE_UP :
                    image.visible = false;
                    background.visible = false;
                    tint.visible = false;
                    addChild(carousel);

                    _hitArea.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
                    _hitArea.removeEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
                    _hitArea.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);

                    dispatchEvent(new GalleryEvent(GalleryEvent.CAROUSEL_REQUEST, this));
                    break;
            }
        }

        private function lHandler(e:TextEvent):void {
            Logger.getInstance().debug("link="+e.text, "WorkGalleryItem", "linkHandler");
            navigateToURL(new URLRequest("http://"+e.text as String), "_blank");
        }

        public function drawHitArea():void {
            _hitArea.graphics.clear();
            _hitArea.graphics.beginFill(0, 0);
//            _hitArea.graphics.drawRect(0, 0, this.width, this.height);
            _hitArea.graphics.drawRect(0, 0, image.width, image.height);
            _hitArea.graphics.endFill();
        }

        public function resize():void {
            label.y = 10;
            title.y = label.height + label.y;
            description.y = title.height + title.y;
            image.y = tint.y = background.y = msktinit.y = _hitArea.y = description.height + description.y + 10;

            carousel.y = description.height + description.y + 10;
            carousel.x = 20;

            image.x = background.x = tint.x = msktinit.x = _hitArea.x = 20;
        }

        public function show():void {
            Logger.getInstance().debug("start", "WorkGalleryItem", "show");
            carousel.show();
        }

        public function hide():void {
            TweenMax.to(this, 0.75, {autoAlpha:0.5});

            removeChild(carousel);
            carousel.dispose();

            _hitArea.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            _hitArea.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
            _hitArea.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);

            image.visible = true;
            background.visible = true;
            tint.visible = true;
        }

        public function dispose():void {
            carousel.dispose();
            bulkloader.clear();
            bulkloader = null;
        }

        public function get status():Boolean {
            return _status;
        }

        public function set status(value:Boolean):void {
            _status = value;
        }
    }
}
