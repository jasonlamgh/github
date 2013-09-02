/**
 * User: jasonlam
 * Date: 31/01/2011
 * Time: 17:01
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.app {
    import com.greensock.TweenMax;
    import com.soma.ui.layouts.CanvasUI;
    import com.soma.utils.FPS;
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.util.DisplayUtil;
    import com.warmforestflash.ui.FullScreenScrollBar;
    import com.website.view.component.ui.*;

    import flash.display.MovieClip;

    import flash.display.Sprite;
    import flash.display.Stage;

    public class BaseDisplay extends Sprite {

        private var _stage:Stage;
        private var _canvas:CanvasUI;
        private var _page:Page;
        private var _header:BaseSprite;
        private var _footer:BaseSprite;
        private var _body:BaseSprite;
        private var _background:Background;
        private var _navigation:BaseSprite;
        private var _scrollBar:FullScreenScrollBar;
        private var _preloader:Sprite;

        private var _message:MovieClip;

        public function BaseDisplay(stage:Stage) {
            this._stage = stage;
            init();
        }

        private function init():void {
            Logger.getInstance().debug("start", "BaseDisplay", "init");

            _canvas = new CanvasUI(_stage, _stage.stageWidth, _stage.stageHeight);
            _canvas.backgroundColor = 0xcccccc;
            _canvas.backgroundAlpha = 1;

            _background = new Background(_stage);
            _canvas.addChild(_background);

            _page = new Page(_stage);

            _header     = new BaseSprite("header");
            _footer     = new BaseSprite("footer");
            _body       = new BaseSprite("body");
            _navigation = new BaseSprite("navigation");

            _page.addChild(_header);
            _page.addChild(_navigation);
            _page.addChild(_body);
            _page.addChild(_footer);

            _stage.addChild(_canvas);
            _stage.addChild(_page);

            _scrollBar = new FullScreenScrollBar(_page, 0xffffff, 0x8e8d8d, 0xd6d6d6, 0xffffff, 15, 15, 4, true);
            _canvas.addChild(_scrollBar);
            _page.visible = false;

            _message = LibraryManager.getInstance().getMovieClip("library", "Logo");

            _preloader = new Sprite();
            _preloader.graphics.beginFill(0xffffff, 1);
            _preloader.graphics.drawRect(0, 0, _canvas.width, _canvas.height);
            _preloader.graphics.endFill();

            _canvas.addChild(_preloader);
            _canvas.addChild(_message);

            var mbg:Sprite = new Sprite();
            mbg.graphics.beginFill(0xffffff, 1);
            mbg.graphics.drawRect(0, 0, _message.width+20, _message.height+20);
            mbg.graphics.endFill();
            mbg.x = 23;
            mbg.y = -10;

            _message.addChild(mbg);
            _message.swapChildrenAt(1,0);
            _message.x = (_stage.stageWidth/2) - (_message.width/2);
            _message.y = (_stage.stageHeight/2) - (_message.height/2);
            _message.alpha = 0;

            TweenMax.to(_message, 0.75, {autoAlpha:1});


//            CONFIG::DEBUG { _stage.addChild(new FPS()) }
        }

        public function show():void {
//            _message.visible = false;
//            _canvas.mask = null;
            _preloader.parent.removeChild(_preloader);
            _page.visible = true;
        }

        public function resize():void {
            Logger.getInstance().debug("start", "BaseDisplay", "resize");

            _canvas.width   = _preloader.width = _stage.stageWidth;
            _canvas.height  = _preloader.height = _stage.stageHeight;

            _message.x = (_stage.stageWidth/2) - (_message.width/2);
            _message.y = (_stage.stageHeight/2) - (_message.height/2);

            _header.y       = 23;
            _navigation.y   = _header.y + _header.height + 46;
            _body.y         = _navigation.y + _navigation.height;

            if(_body.height == 0) _footer.y = _navigation.y + _navigation.height + 50;
            else _footer.y = _body.y + _body.height + 50;

            var pageh:Number = _header.height + 23 + _navigation.height + 46 + _body.height + _footer.height + 25;

            _page.refresh(pageh);
            _canvas.refresh();
            _background.refresh();
            _scrollBar.adjustSize();

            DisplayUtil.PixelSnapAllChildrens(_page);
        }

        public function get canvas():CanvasUI {
            return _canvas;
        }

        public function set canvas(value:CanvasUI):void {
            _canvas = value;
        }

        public function get page():Page {
            return _page;
        }

        public function set page(value:Page):void {
            _page = value;
        }

        public function get header():BaseSprite {
            return _header;
        }

        public function set header(value:BaseSprite):void {
            _header = value;
        }

        public function get footer():BaseSprite {
            return _footer;
        }

        public function set footer(value:BaseSprite):void {
            _footer = value;
        }

        public function get body():BaseSprite {
            return _body;
        }

        public function set body(value:BaseSprite):void {
            _body = value;
        }

        public function get navigation():BaseSprite {
            return _navigation;
        }

        public function set navigation(value:BaseSprite):void {
            _navigation = value;
        }

        public function get preloader():Sprite {
            return _preloader;
        }

        public function get message():MovieClip {
            return _message;
        }
    }
}
