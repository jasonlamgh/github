package com.twentythree.manager {
    import flash.media.Sound;
    import flash.media.SoundChannel;

    /**
     * User: jasonlam
     * Date: 28/02/2011
     * Time: 11:09
     * To change this template use File | Settings | File Templates.
     */

    public class SoundManager {

        private static var instance:SoundManager;


        private static var _mute:Boolean = false;

        private static var ch1:SoundChannel;
        private static var ch2:SoundChannel;

        public function SoundManager() {
            ch1 = new SoundChannel();
            ch2 = new SoundChannel();
        }

        public static function getInstance():SoundManager {
            if(instance == null) instance = new SoundManager();
            return instance;
        }

        public function play(sound:Sound):void {
            if(sound==null || _mute) return;
            ch2 = sound.play();
        }

        public function stop():void {
            ch2.stop();
        }

        public function destroy():void {
            
        }


        public function get mute():Boolean {
            return _mute;
        }

        public function set mute(value:Boolean):void {
            _mute = value;
        }
    }
}
