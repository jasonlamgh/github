/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 25/05/2011
 * Time: 23:38
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;

    import flash.display.DisplayObject;

    import flash.display.Sprite;

    public class Line extends BaseSprite {

        private var line:Sprite;

        public function Line() {
            line = new Sprite();
            line.graphics.beginFill(0xCCCCCC, 1.0);
            line.graphics.drawRect(0, 0, 760, 0.2);
            line.graphics.endFill();

            line.x = 20;

            addChild(line);
        }
    }
}
