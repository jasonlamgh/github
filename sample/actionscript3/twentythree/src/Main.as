package {
    import com.twentythree.log.Log4j;
    import com.twentythree.log.Logger;
    import com.twentythree.manager.PropertiesManager;
    import com.website.ApplicationFacade;
    import com.website.view.component.context.menu.CustomContextMenu;

    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.Capabilities;
    import flash.system.Security;

    public class Main extends Sprite {

        public static const   NAME:String  = "website";

        public static var  FILEPATH:String = "";
        public static var   VERSION:String = "0.0";
        public static var     BUILD:String = "0";
        public static var    LOCALE:String = "en_UK";
        public static var    DEBUG:Boolean = false;

        public static var _stage:Stage;

        private var facade:ApplicationFacade;
        private var loader:URLLoader;


        public function Main() {
            Security.allowDomain("*");

            /* setup logger */
            Logger.init(Log4j);

            facade = new ApplicationFacade();
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            _stage = this.stage;

            /* flash vars */
            var parameters:Object = LoaderInfo( this.loaderInfo ).parameters;

            LOCALE      = parameters.locale ? parameters.locale : LOCALE;
            FILEPATH    = parameters.path ? parameters.path : FILEPATH;

            /* load properties file */
            var file:String = FILEPATH + NAME + ".properties";
            loader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, complete);
            loader.load(new URLRequest(file));
        }

        private function complete(e:Event):void {
            loader.removeEventListener(Event.COMPLETE, complete);

            /* setup properties manager */
            PropertiesManager.getInstance().parse(URLLoader(e.target).data);

            /* setup global vars */
            DEBUG   = Capabilities.playerType == "StandAlone" ? true : Boolean(PropertiesManager.getInstance().getProperty("website.debug"));
            VERSION = PropertiesManager.getInstance().getProperty("website.version");
            BUILD   = PropertiesManager.getInstance().getProperty("website.build");

            /* setup logger */
            Logger.getInstance().level(PropertiesManager.getInstance().getProperty("website.log.level"));

            trace("\n\n\n\n");
            trace("----------------------------------------------------------");
            trace(" Project: " + NAME + " Version: " + VERSION + " Build: " + BUILD);
            trace("----------------------------------------------------------");
            trace(" CONFIG:: -PATH="+FILEPATH+" -LOCALE="+LOCALE + "\n");
            /* setup context menu */

            contextMenu = CustomContextMenu.getInstance().customize();

            /* startup facade */
            facade.startup(this.stage);

//            CONFIG::DEBUG { Inspector.getInstance().init(this) };
            //_stage.addEventListener(Event.MOUSE_LEAVE, mouseHandler);
        }

        private function mouseHandler(e:Event):void {
            switch(e.type) {
                case Event.MOUSE_LEAVE :
                    _stage.removeEventListener(Event.MOUSE_LEAVE, mouseHandler);
                    break;
                case MouseEvent.MOUSE_MOVE :
                    break;
            }
        }

    }
}