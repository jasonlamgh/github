/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 26/05/2011
 * Time: 23:17
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.component.ui {
    import com.twentythree.display.BaseSprite;
    import com.twentythree.display.BaseTextField;
    import com.twentythree.manager.LibraryManager;
    import com.website.view.component.ui.Line;

    public class Title extends BaseSprite {

        private var textfld:BaseTextField;

        public function Title(text:String) {
            textfld = new BaseTextField(text);
            textfld.setCSS(LibraryManager.getInstance().getCSS());
            textfld.render();


            addChild(textfld);
        }
    }
}
