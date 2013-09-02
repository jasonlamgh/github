package cn.itamt.utils.inspector.ui {
	import cn.itamt.utils.inspector.lang.InspectorLanguageManager;	
	import cn.itamt.utils.inspector.lang.Lang;	
	import cn.itamt.utils.Inspector;
	import cn.itamt.utils.inspector.consts.InspectMode;
	import cn.itamt.utils.inspector.interfaces.IInspectorView;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;	

	/**
	 * tInspector的右键菜单。
	 */
	public class InspectorRightMenu extends BaseInspectorView implements IInspectorView {
		public static const ID : String = '右键菜单';

		public static const ON : String = 'tInspector on';		public static const OFF : String = 'tInspector off';
		//开关菜单项
		private var _on : ContextMenuItem;		private var _off : ContextMenuItem;
		private var _dspMode : ContextMenuItem;
		private var _intMode : ContextMenuItem;
		//属性面板视图
		private var _pView : ContextMenuItem;
		//显示列表树视图
		private var _sView : ContextMenuItem;

		public function InspectorRightMenu(on : Boolean = true, mode : String = InspectMode.DISPLAY_OBJ) {
			_on = new ContextMenuItem(ON);
			_on.separatorBefore = true;
			_on.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			_off = new ContextMenuItem(OFF);
			_off.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			
			_dspMode = new ContextMenuItem(InspectMode.DISPLAY_OBJ);
			_dspMode.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			_intMode = new ContextMenuItem(InspectMode.INTERACTIVE_OBJ);
			_intMode.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			
			_pView = new ContextMenuItem(InspectorLanguageManager.getStr(PropertiesView.ID));
			_pView.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			_sView = new ContextMenuItem(InspectorLanguageManager.getStr(StructureView.ID));
			_sView.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			
			_on.enabled = on;
			_off.enabled = !on;
			
			_dspMode.caption = (mode == InspectMode.DISPLAY_OBJ) ? (InspectMode.DISPLAY_OBJ + '\t√') : (InspectMode.DISPLAY_OBJ);			_intMode.caption = (mode == InspectMode.INTERACTIVE_OBJ) ? (InspectMode.INTERACTIVE_OBJ + '\t√') : (InspectMode.INTERACTIVE_OBJ);
		}

		/**
		 * 注册到Inspector时.
		 */
		override public function onRegister(inspector : Inspector) : void {
			this._inspector = inspector;
			this.apply(inspector.root);
			
			this.onTurnOff();
		}

		private var _pOn : Boolean;		private var _sOn : Boolean;

		override public function onRegisterView(viewClassId : String) : void {
			switch(viewClassId) {
				case PropertiesView.ID:
					_pOn = true;
					_pView.caption = InspectorLanguageManager.getStr(PropertiesView.ID) + '\t√';
					break;
				case StructureView.ID:
					_sOn = true;
					_sView.caption = InspectorLanguageManager.getStr(StructureView.ID) + '\t√';
					break;
			}
		}

		/**
		 * 
		 */
		override public function onUnregisterView(viewClassId : String) : void {
			switch(viewClassId) {
				case PropertiesView.ID:
					_pOn = false;
					_pView.caption = InspectorLanguageManager.getStr(PropertiesView.ID);
					break;
				case StructureView.ID:
					_sOn = false;
					_sView.caption = InspectorLanguageManager.getStr(StructureView.ID);
					break;
			}
		}

		override public function onTurnOn() : void {
			_on.enabled = false;
			_off.enabled = true;
			
			_dspMode.enabled = _intMode.enabled = _pView.enabled = _sView.enabled = true;
		}

		override public function onTurnOff() : void {
			_on.enabled = true;
			_off.enabled = false;
			
			_dspMode.enabled = _intMode.enabled = _pView.enabled = _sView.enabled = false;
		}

		/**
		 * 当设置Inspect的查看模式时.
		 */
		override public function onInspectMode(clazz : Class) : void {
			if(clazz == DisplayObject) {
				_dspMode.caption = InspectMode.DISPLAY_OBJ + '\t√';
				_intMode.caption = InspectMode.INTERACTIVE_OBJ;
			}else if(clazz == InteractiveObject) {
				_dspMode.caption = InspectMode.DISPLAY_OBJ;
				_intMode.caption = InspectMode.INTERACTIVE_OBJ + '\t√';
			}
		}

		private var _objs : Array;

		/**
		 * 把InspectorRightmenu应用到某一个InteractiveObject的右键上.
		 */
		public function apply(obj : InteractiveObject) : void {
			if(_objs == null)_objs = [];
			if(_objs.indexOf(obj) < 0) {
				_objs.push(obj);
				
				var menu : ContextMenu = obj.contextMenu;
				if(menu == null) {
					menu = new ContextMenu();
				}
				menu.customItems.push(_on);
				menu.customItems.push(_off);
				menu.customItems.push(_dspMode);				menu.customItems.push(_intMode);
				menu.customItems.push(_pView);				menu.customItems.push(_sView);
				obj.contextMenu = menu;
			}
		}

		private function onMenuItemSelect(evt : ContextMenuEvent) : void {
			switch(evt.target) {
				case _on:
					_inspector.turnOn();
					break;
				case _off:
					_inspector.turnOff();
					break;
				case _dspMode:
					_inspector.setInspectMode(DisplayObject);
					break;
				case _intMode:
					_inspector.setInspectMode(InteractiveObject);
					break;
				case _pView:
					if(_pOn) {
						_inspector.unregisterViewById(PropertiesView.ID);
					} else {
						_inspector.registerViewById(PropertiesView.ID);
					}
					break;
				case _sView:
					if(_sOn) {
						_inspector.unregisterViewById(StructureView.ID);
					} else {
						_inspector.registerViewById(StructureView.ID);
					}
					break;
			}
		}
	}
}