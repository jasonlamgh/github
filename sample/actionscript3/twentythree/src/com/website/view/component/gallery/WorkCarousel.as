/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 30/05/2011
 * Time: 01:47
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.gallery {
    import com.greensock.TweenMax;
    import com.twentythree.display.BaseSprite;
    import com.twentythree.log.Logger;

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class WorkCarousel extends BaseSprite {

        private var _width:Number;
        private var _height:Number;

        private var list:Array;
        private var data:Array;

        private var _mask:Sprite;
        private var _hitArea:Sprite;

        private var target:int = 0;
        private var key:String;

        public function WorkCarousel(width:Number, height:Number, list:Array, key:String) {
            this._width   = width;
            this._height  = height;
            this.list     = list;
            this.key      = key;

            _mask            = new Sprite();
            _mask.graphics.beginFill(0, 0);
            _mask.graphics.drawRect(0, 0, _width, _height);
            _mask.graphics.endFill();

            _hitArea = new Sprite();
            _hitArea.graphics.beginFill(0x000000, 0);
            _hitArea.graphics.drawRect(0,0, _width, _height);
            _hitArea.graphics.endFill();

            this.mask = _mask;
            this.hitArea = _hitArea;
            addChild(_mask);

            _hitArea.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);

            this.alpha = 0;

            init();
        }

        private function init():void {
            Logger.getInstance().debug("start", "WorkCarousel", "init");

            var temp:WorkCarouselItem;

            data = new Array();

            for (var i:int = 0; i < list.length; i++) {
                var item:WorkCarouselItem = new WorkCarouselItem(list[i], "carousel-key-"+key+"-i-"+i.toString());

                data.push(item);
                addChild(item);

                item.x = item.width + 20;
            }

            data[0].x = 0;

            addChild(_hitArea);
        }

        private function mouseHandler(e:MouseEvent):void {
            switch(e.type) {
                case MouseEvent.MOUSE_UP :
                    next();
                    break;
            }
        }

        private function next():void {
            Logger.getInstance().debug("start", "WorkCarousel", "next");

            var out:WorkCarouselItem = data[target];

            disableClick();

            TweenMax.to(out, 0.75, {x:-780,
                    onComplete:function():void{
                        out.x = out.width+20;
                        enableClick();
                    }});

            target = (data.length-1) == target ? 0 : target+1;
//
            var _in:WorkCarouselItem = data[target];
            TweenMax.to(_in, 0.75, {x:0});
        }

        public function show():void {
            TweenMax.to(this, 0.75, {autoAlpha:1});
        }

        public function enableClick():void {
            _hitArea.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
        }

        public function disableClick():void {
            _hitArea.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
        }

        public function dispose():void {
            for (var i:int = 0; i < data.length; i++) {
                var item:WorkCarouselItem = data[i];
                item.dispose();
                this.alpha = 0;
            }
        }
    }
}
