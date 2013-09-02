/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 31/05/2011
 * Time: 12:19
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.log.Logger;

    import flash.display.Sprite;
    import flash.display.Stage;

    public class Page extends BaseSprite {

        private var background:Sprite;
        private var _stage:Stage;
        private var h:Number;

        public function Page(stage:Stage) {
            _stage = stage;

            background = new Sprite();
            addChild(background);

//            drawBackground();
        }

        private function drawBackground():void {
            Logger.getInstance().debug("start", "Page", "drawBackground");

            background.graphics.clear();
            background.graphics.beginFill(0xffffff, 1);
            background.graphics.drawRect(0, 0, 800, h);
            background.graphics.endFill();
        }

        public function refresh(height:Number):void {
            h = height;
            this.x = (this.stage.stageWidth/2) - 400;
            drawBackground();
        }
    }
}
