/**
 * Created by IntelliJ IDEA.
 * User: jasonlam
 * Date: 26/05/2011
 * Time: 22:56
 * To change this template use File | Settings | File Templates.
 */
package com.website.view.section {
    import flash.events.IEventDispatcher;

    public interface ISection extends IEventDispatcher {

        function getSectionName():String;
        function resize():void;
        function closeSection():void;

    }
}
