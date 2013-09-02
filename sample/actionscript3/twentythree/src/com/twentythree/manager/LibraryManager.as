/**
 * User: jasonlam
 * Date: 11/02/2011
 * Time: 12:13
 * To change this template use File | Settings | File Templates.
 */

package com.twentythree.manager {
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;

    import com.twentythree.log.Logger;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.media.Sound;
    import flash.text.StyleSheet;

    public class LibraryManager {

        private static var instance:LibraryManager;
        private static var library:Array
        private static var css:StyleSheet;

        public function LibraryManager() {
            library = new Array();
        }

        public function update(bulkloader:BulkLoader):void {
            Logger.getInstance().debug("start", "LibraryManager", "update");

            for (var i:int = 0; i < bulkloader.itemsTotal; i++) {
                var item:LoadingItem = bulkloader.items[i] as LoadingItem;

                if(!item._isLoaded) continue;
                Logger.getInstance().debug("type="+item.type+" id="+item.id, "LibraryManager", "update");

                switch(item.type) {
                    case BulkLoader.TYPE_IMAGE :
                        library[item.id] = item.content;
                        break;

                    case BulkLoader.TYPE_SOUND :
                        library[item.id] = item.content;
                        break;

                    case BulkLoader.TYPE_MOVIECLIP :
                        library[item.id] = item.content;
                        break;

                    case BulkLoader.TYPE_BINARY :
                        if(String(item.id).search(/css/ig)==-1) { library[item.id] = item.content; break;}

                        Logger.getInstance().debug("set style.css", "LibraryManager", "update");
                        css = new StyleSheet();
                        css.parseCSS(item.content);
                        break;

                    case BulkLoader.TYPE_XML :
                        library[item.id] = item.content;
                        break;

                    default:
                }
            }
        }

        public function getCSS():StyleSheet {
            return css;
        }

        public function getSWF(id:String):MovieClip {
            var result:MovieClip;

            result = library[id] as MovieClip;

            return result;
        }

        public function getMovieClip(id:String, className:String):MovieClip {
            Logger.getInstance().debug("start id="+id+" className="+className, "BaseProxy", "getMovieClip");

            var result:MovieClip;
            var _class:Class = MovieClip(library[id]).loaderInfo.applicationDomain.getDefinition(className) as Class;

            result = new _class() as MovieClip;

            return result;
        }

        public function getMovieClipClass(id:String, className:String):Class {
            var _class:Class = MovieClip(library[id]).loaderInfo.applicationDomain.getDefinition(className) as Class;
            return _class;
        }

        public function getBitmap(id:String):Bitmap {
            var result:Bitmap;
            result = new Bitmap((library[id].bitmapData.clone()));
            result.smoothing = true;
            return result;
        }

        public function getSound(id:String):Sound {
            var result:Sound;
            result = library[id] as Sound;
            Logger.getInstance().debug("id="+id+" result="+result, "LibraryManager", "getSound");
            return result;
        }

        public function getXML(id:String):XML {
            var result:XML;
            result = library[id] as XML;
            Logger.getInstance().debug("id="+id+" result="+result, "LibraryManager", "getXML");
            return result;
        }

        public function listAll():void { }

        public static function getInstance():LibraryManager {
            if(instance == null) instance = new LibraryManager();
            return instance;
        }

    }
}
