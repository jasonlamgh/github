package com.twentythree.manager.event.profiler {
    import com.twentythree.manager.event.EventManager;

    import flash.events.IEventDispatcher;

    /**
     * User: jasonlam
     * Date: 02/03/2011
     * Time: 11:58
     * To change this template use File | Settings | File Templates.
     */

    public class Profiling implements IEventManagerProfilable{

        public function Profiling() {
            EventManager.installProfiler(this);
        }

        public function interceptFilter(obj:IEventDispatcher, group:String, job:String, mObj:Object):Boolean {

            // if you return true it will generate a PROFILING line
            // if you return false it won't

            var res:Boolean = true;
            if (group == "group1") res = false; //  don't profile group1
            //if (job == EventManager.JOB_ADD && obj.listener == someWorkingFunc) res = false;  // don't profile ADD mapped to someWorkingFunc(
            return res;
        }
    }
}
