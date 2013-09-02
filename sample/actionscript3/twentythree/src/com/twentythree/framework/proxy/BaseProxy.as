package com.twentythree.framework.proxy {
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkProgressEvent;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;

    import com.twentythree.log.Logger;
    import com.twentythree.manager.LibraryManager;
    import com.twentythree.util.StringUtil;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.Video;
    import flash.utils.ByteArray;

    import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;

    /**
     * User: jasonlam
     * Date: 28/01/2011
     * Time: 12:31
     * To change this template use File | Settings | File Templates.
     */

    public class BaseProxy extends Proxy implements IProxy {

        public static var    NAME:String = "BaseProxy";

        public static const  TYPE_XML:String = "xml";
        public static const  TYPE_CSS:String = "css";
        public static const TYPE_FILE:String = "file";

        private static var bulkloader:BulkLoader;
        private var name:String;

        /* notification */
        private var notifyInit:String
        private var notifyProgress:String;
        private var notifyComplete:String;

        public function BaseProxy(name:String, data:Object) {
            Logger.getInstance().debug("start", "BaseProxy", "init");
            super(name, data);

            this.name = name;

//            if(Main.DEBUG) bulkloader = new BulkLoader(name, 12, BulkLoader.LOG_VERBOSE);
//            else bulkloader = new BulkLoader(name, 12, BulkLoader.LOG_ERRORS);
            bulkloader = new BulkLoader(name, 12, BulkLoader.LOG_ERRORS);

            Logger.getInstance().debug("end", "BaseProxy", "init");
        }

        public function add(key:String, file:String, notifyInit:String="", notifyProgress:String="",
                    notifyComplete:String=""):void {

            Logger.getInstance().info("start key="+key+" file="+file, "BaseProxy", "add");
            Logger.getInstance().debug("key="+key+" file="+file
                    +" notifyInit="+notifyInit+" notifyProgress="+notifyProgress
                    +" notifyComplete="+notifyComplete, "BaseProxy", "add");

            this.notifyInit     = notifyInit;
            this.notifyProgress = notifyProgress;
            this.notifyComplete = notifyComplete;

            bulkloader.addEventListener(Event.INIT, init);
            bulkloader.addEventListener(Event.COMPLETE, complete);
//            bulkloader.addEventListener(BulkProgressEvent.PROGRESS, progress);
            bulkloader.add(Main.FILEPATH+file, {id:key});

            bulkloader.resumeAll();
        }

        private function init(e:Event):void {
            Logger.getInstance().debug("start", "BaseProxy", "init");

            bulkloader.removeEventListener(Event.INIT, init);

            Logger.getInstance().debug("end", "BaseProxy", "init");
        }

        private function progress(e:BulkProgressEvent):void {
            sendNotification(notifyProgress, e);
            if(e._percentLoaded == 1) {bulkloader.addEventListener(BulkProgressEvent.PROGRESS, progress); }
        }

        private function complete(e:Event):void {
            Logger.getInstance().debug("start", "BaseProxy", "complete");

            bulkloader.removeEventListener(Event.COMPLETE, complete);
            bulkloader.pauseAll();

            if(appendXML()) return;
            if(append()) return;

            LibraryManager.getInstance().update(bulkloader);
            if(bulkloader._isFinished) sendNotification(notifyComplete);

            Logger.getInstance().debug("end", "BaseProxy", "complete");
        }

        private function appendXML():Boolean {
            Logger.getInstance().debug("start", "BaseProxy", "appendXML");

            var result:Boolean = false;

            Logger.getInstance().debug("items.length="+bulkloader.items.length, "BaseProxy", "appendXML");

            for each (var li:LoadingItem in bulkloader.items) {
                if(li.type == BulkLoader.TYPE_XML && li.isLoaded) {
                    var  xml:XML    = li.content;

                    for (var i:int = 0; i < xml.children().length(); i++) {
                        var  key:String = xml.item[i].id;
                        var file:String = Main.FILEPATH + xml.item[i].file;
                        var type:String = xml.item[i].type;

                        if(bulkloader.get(key)==null && type != null && StringUtil.isEqual(type, TYPE_XML)) {
                            Logger.getInstance().debug("adding file="+file, "BaseProxy", "appendXML");
                            bulkloader.add(file, {id:key});
                            result = true;
                        }
                    }
                }
            }

            if(result) { bulkloader.resumeAll(); bulkloader.addEventListener(Event.COMPLETE, complete);}

            Logger.getInstance().debug("result="+result, "BaseProxy", "appendXML");

            return result;
        }

        private function append():Boolean {
            Logger.getInstance().debug("start", "BaseProxy", "append");

            var result:Boolean = false;

            for each (var li:LoadingItem in bulkloader.items) {
                if(li.type == BulkLoader.TYPE_XML && li.isLoaded) {
                    var  xml:XML    = li.content;

                    for (var i:int = 0; i < xml.children().length(); i++) {
                        var  key:String = xml.item[i].id;
                        var file:String = xml.item[i].file;
                        var type:String = xml.item[i].type;
                        var locale:String = xml.item[i].locale;

                        if(StringUtil.isEqual(type, TYPE_XML)) continue;

                        if(bulkloader.get(key)==null && !StringUtil.isEmpty(file)) {
                            file = Boolean(locale) ? Main.FILEPATH+"locale/"+Main.LOCALE.toLowerCase()+"/"+file : Main.FILEPATH+file;

                            Logger.getInstance().debug("type="+type, "BaseProxy", "append");

                            if(StringUtil.isEqual(type, TYPE_FILE)) bulkloader.add(file, {id:key, type:BulkLoader.TYPE_BINARY});
                            else bulkloader.add(file, {id:key});

                            result = true;
                        }
                    }
                }
            }

            if(result) { bulkloader.resumeAll(); bulkloader.addEventListener(Event.COMPLETE, complete); bulkloader.addEventListener(BulkProgressEvent.PROGRESS, progress)}

            Logger.getInstance().debug("result="+result, "BaseProxy", "append");
            return result;

        }

        public function getBitmap(id:String):Bitmap {
            Logger.getInstance().debug("id="+id, "BaseProxy", "getBitmap");

            var result:Bitmap;
            result = new Bitmap(bulkloader.getBitmapData(id).clone());
            result.smoothing = true;

            Logger.getInstance().debug("result="+result, "BaseProxy", "getBitmap");

            return result;
        }

        public function getMovieClip(id:String, className:String):MovieClip {
            Logger.getInstance().debug("start id="+id+" className="+className, "BaseProxy", "getMovieClip");

            var result:MovieClip;
            var _class:Class = bulkloader.getMovieClip(id).loaderInfo.applicationDomain.getDefinition(className) as Class;

            result = new _class() as MovieClip;

            return result;
        }

        public function getFile(id:String):ByteArray {
            var result:ByteArray;
            result = bulkloader.getBinary(id);

            return result;
        }

        public function getSetting(id:String):String {
            var result:String;
            return result;
        }

        public function getSound(id:String):Sound {
            var result:Sound;
            Logger.getInstance().debug("id="+id, "BaseProxy", "getSound");
            bulkloader.getSound(id);
            Logger.getInstance().debug("result="+result, "BaseProxy", "getSound");
            return result;
        }

        public function getSWF(id:String):MovieClip {
            var result:MovieClip;

            result = bulkloader.getMovieClip(id);

            return result;
        }

        public function getVideo(id:String):Video {
            var result:Video;
            return result;
        }

        public function getXML(id:String):XML {
            Logger.getInstance().debug("start id="+id, "BaseProxy", "getXML");
            var result:XML;
            result = bulkloader.getXML(id);

            return result;
        }
    }
}
