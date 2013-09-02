/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 26/05/2011
 * Time: 19:38
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.manager.LibraryManager;

    import flash.display.Bitmap;

    import flash.display.BitmapData;

    import flash.display.Sprite;
    import flash.display.Stage;

    public class Background extends BaseSprite {

        private var background:Sprite;
        private var pattern:Bitmap;

        private var stageRef:Stage;

        public function Background(stageRef:Stage) {
            this.stageRef = stageRef;

            init();
        }

        private function init():void {
            background  = new Sprite();
            pattern     = LibraryManager.getInstance().getBitmap("pattern.square.horizontal.image");

            fillBackground();

            addChild(background);
        }


        private function fillBackground():void {
            background.graphics.clear();
            background.graphics.beginBitmapFill(pattern.bitmapData);
            background.graphics.moveTo(0,0);
            background.graphics.lineTo(stageRef.stageWidth, 0);
            background.graphics.lineTo(stageRef.stageWidth, stageRef.stageHeight);
            background.graphics.lineTo(0, stageRef.stageHeight);
            background.graphics.lineTo(0, 0);
            background.graphics.endFill();
        }

        public function refresh():void {
            fillBackground();
        }
    }
}
