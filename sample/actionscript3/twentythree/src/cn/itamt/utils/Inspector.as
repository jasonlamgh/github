﻿package cn.itamt.utils {
	import cn.itamt.utils.inspector.data.InspectTarget;
	import cn.itamt.utils.inspector.interfaces.IInspectorView;
	import cn.itamt.utils.inspector.ui.InspectorRightMenu;
	import cn.itamt.utils.inspector.ui.InspectorTextField;
	import cn.itamt.utils.inspector.ui.InspectorViewOperationButton;
	import cn.itamt.utils.inspector.ui.LiveInspectView;
	import cn.itamt.utils.inspector.ui.PropertiesView;
	import cn.itamt.utils.inspector.ui.StructureView;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;	

	/**
	 * @author tamt
	 * @example
	 * 	<code>
	 * 		_inspector = Inspector.getInstance();
	 * 		_inspector.init(root, true);
	 * 	</code>
	 * @version 1.0 beta
	 */
	public class Inspector {
		public static const VERSION : String = '1.0 beta';

		private static var _instance : Inspector;
		private var _root : DisplayObjectContainer;

		public function get root() : DisplayObjectContainer {
			return _root;
		}

		private var _stage : Stage;

		public function get stage() : Stage {
			return _stage;
		}

		private var inspectView : LiveInspectView;
		private var structureView : StructureView;
		private var propertiesView : PropertiesView;
		private var ctmenu : InspectorRightMenu;

		private var curInspectEle : InspectTarget;

		public function getCurInspectTarget() : InspectTarget {
			return curInspectEle;
		}

		public function Inspector(sf : SingletonEnforcer) {
			super();
			
			liveInspectFilter = DisplayObject;
		}

		public static function getInstance() : Inspector {
			if(_instance == null) {
				_instance = new Inspector(new SingletonEnforcer());
			}

			return _instance;
		}

		/**
		 * @param withMenu		是否在右键菜单中显示操作选项
		 */
		public function init(root : DisplayObjectContainer, withMenu : Boolean = true) : void {
			
			this._root = root;
			this._stage = root.stage;
			
			this._stage.addEventListener(InspectorViewOperationButton.EVT_SHOW_TIP, onShowTip);
			this._stage.addEventListener(InspectorViewOperationButton.EVT_REMOVE_TIP, onRemoveTip);			//			this._stage.addEventListener(Event.ADDED, onSthAdd);			//			this._stage.addEventListener(Event.REMOVED, onSthRemove);

			if(stage == null) {
				throw new Error("Set inspector's stage before you call inspector.init(); ");
				return;
			}
			
			//右键菜单视图
			if(withMenu) {
				ctmenu = new InspectorRightMenu();
				registerView(ctmenu, InspectorRightMenu.ID);
			}
			
			//实时查看的视图
			inspectView = new LiveInspectView();
			registerView(inspectView, LiveInspectView.ID);
			
			//显示对象结构树视图
			structureView = new StructureView();
			//			registerView(structureView, StructureView.ID);
			
			//属性面板
			propertiesView = new PropertiesView();
//			registerView(this.propertiesView, PropertiesView.ID);
		}

		private var _views : Dictionary;

		/**
		 * 注册Inspector的视图.
		 */
		public function registerView(view : IInspectorView, id : String) : void {
			if(_views == null) {
				_views = new Dictionary();
			}
			
			if(view != _views[id]) {
				_views[id] = view;
				view.onRegister(this);
			}
			
			
			for each(var item:IInspectorView in _views) {
				item.onRegisterView(id);
			}
		}

		/**
		 * 注册Inspector的视图.
		 */
		public function registerViewById(id : String) : void {
			switch(id) {
				case InspectorRightMenu.ID:
					this.registerView(this.ctmenu, id);
					break;
				case LiveInspectView.ID:
					this.registerView(this.inspectView, id);
					break;
				case StructureView.ID:
					this.registerView(this.structureView, id);
					break;
				case PropertiesView.ID:
					this.registerView(this.propertiesView, id);
					break;
			}
		}

		/**
		 * 删除注册Inspector的视图.
		 */
		public function unregisterViewById(id : String) : void {
			if(_views[id]) {
				(_views[id] as IInspectorView).onUnRegister(this);
			}
			_views[id] = null;
			delete _views[id];
			
			for each(var view:IInspectorView in _views) {
				view.onUnregisterView(id);
			}
		}

		/**
		 * 打开某一个视图(主要是指面板, 例如"属性面板"/"显示结构面板")
		 */
		public function activeView(viewId : String = null) : void {
		}

		//过滤实时查看.
		private var liveInspectFilter : Class;

		/**
		 * 开启tInspector
		 */
		public function turnOn() : void {
			if(_isOn)return;
			_isOn = true;
			curInspectEle = null;
			
			for each(var view:IInspectorView in _views) {
				view.onTurnOn();
			}
			
			this.startLiveInspect();
		}

		/**
		 * 关闭tInspector
		 */
		public function turnOff() : void {
			this.stopLiveInspect();
			
			if(!_isOn)return;
			_isOn = false;
			curInspectEle = null;
			
			for each(var view:IInspectorView in _views) {
				view.onTurnOff();
			}
		}

		/**
		 * 设置Inspector的查看模式.
		 * @param clazz		Inspector将只查看clazz类型的显示对象.
		 */
		public function setInspectMode(clazz : Class) : void {
			this.liveInspectFilter = clazz;
			
			for each(var view:IInspectorView in _views) {
				view.onInspectMode(clazz);
			}
		}

		/**
		 * 开启查看
		 */
		private var _isOn : Boolean = false;

		public function get isOn() : Boolean {
			return _isOn;
		}

		private var _isLiveInspecting : Boolean = false;

		//是否处于LiveInspect状态.
		public function get isLiveInspecting() : Boolean {
			return _isLiveInspecting;
		}

		
		public function startLiveInspect() : void {
			if(!_isLiveInspecting) {
				curInspectEle = null;
			
				_isLiveInspecting = true;
				this.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				for each(var view:IInspectorView in _views) {
					view.onStartLiveInspect();
				}
			}
		}

		public function stopLiveInspect() : void {
			_isLiveInspecting = false;
			this.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			for each(var view:IInspectorView in _views) {
				view.onStopLiveInspect();
			}
		}

		private function enterFrameHandler(evt : Event = null) : void {
			var mousePos : Point = new Point(stage.mouseX, stage.mouseY);
			var objs : Array = stage.getObjectsUnderPoint(mousePos);
			var l : int = objs.length;
			
			if(l) {
				while(l--) {
					var target : DisplayObject = objs[l];
					if(isInspectView(target)) {
						continue;
					} 
					while(target) {
						if(target is liveInspectFilter) {
							liveInspect(target, false);
							return;
						} else {
							if(target.parent && target.parent != this.stage) {
								target = target.parent;
							} else {
								break;
							}
						}
					}
				}
			}
		}

		/**
		 * 要查看的对像是否是InspectView
		 */
		public function isInspectView(target : DisplayObject) : Boolean {
			for each(var view:IInspectorView in _views) {
				if(view.contains(target)) {
					return true;
				}
			}
			return false;
		}

		/**
		 * 实时查看某个显示对象
		 * @param ele					要查看的显示对象
		 * @param checkIsInspectorView	把InspectorView的显示对象排除掉
		 */
		public function liveInspect(ele : DisplayObject, checkIsInspectorView : Boolean = true) : void {
			if(curInspectEle && curInspectEle.displayObject == ele)return;
			if(checkIsInspectorView)if(isInspectView(ele))return;
			
			curInspectEle = getInspectTarget(ele);
			
			for each(var view:IInspectorView in _views) {
				view.onLiveInspect(curInspectEle);
			}
		}

		/**
		 * 查看某一个显示对象.
		 */
		public function inspect(ele : DisplayObject) : void {
			if(isInspectView(ele))return;
			
			stopLiveInspect();
			
			curInspectEle = getInspectTarget(ele);
			
			for each(var view:IInspectorView in _views) {
				view.onInspect(curInspectEle);
			}
		}

		private var _tMap : Dictionary;

		/**
		 * InspectTarget存储
		 */
		private function getInspectTarget(target : DisplayObject) : InspectTarget {
			if(_tMap == null) {
				_tMap = new Dictionary();
			}
			
			if(_tMap[target] == null) {
				_tMap[target] = new InspectTarget(target);
			}
			
			return _tMap[target];
		}

		
		//tip
		private var _tip : Sprite;

		/**
		 * 显示tip
		 */
		private function onShowTip(evt : Event) : void {
			if(evt.target is InspectorViewOperationButton) {
				var target : InspectorViewOperationButton = evt.target as InspectorViewOperationButton;
				if(_tip) {
					_tip.graphics.clear();
					DisplayObjectTool.removeAllChildAndChild(_tip);
					if(_tip.stage)this._tip.parent.removeChild(_tip);
					_tip = null;
				}
				_tip = new Sprite();
				_tip.filters = [new GlowFilter(0x0, 1, 16, 16, 1)];
				_tip.mouseEnabled = _tip.mouseChildren = false;
				
				var _tf : TextField = InspectorTextField.create(target.tip, 0xffffff, 15, 5, 0, 'left');
				_tf.y = 26 - _tf.height;
				_tip.addChild(_tf);
				_tip.graphics.beginFill(0x000000);
				_tip.graphics.drawRoundRect(0, 26 - _tf.height, _tf.width + 10, _tf.height, 10, 10);
				_tip.graphics.endFill();
				_tip.graphics.beginFill(0x000000);
				_tip.graphics.moveTo(9, 25);
				_tip.graphics.lineTo(15, 25);
				_tip.graphics.lineTo(12, 30);
				_tip.graphics.lineTo(9, 25);
				_tip.graphics.endFill();
				target.parent.addChild(_tip);
				
				//				var pt : Point = target.localToGlobal(new Point(0, 0));
				var rect : Rectangle = target.getBounds(target.parent);
				
				_tip.x = rect.x - 5;
				_tip.y = rect.y - 35;
				
				//
				DisplayObjectTool.swapToTop(_tip);
			}
			
			evt.stopImmediatePropagation();
		}

		/**
		 * 移除tip
		 */
		private function onRemoveTip(evt : Event) : void {
			if(_tip) {
				_tip.graphics.clear();
				DisplayObjectTool.removeAllChildAndChild(_tip);
				if(_tip.stage)this._tip.parent.removeChild(_tip);
				_tip = null;
			}
			evt.stopImmediatePropagation();
		}

		/**
		 * 有显示对象加入显示列表时
		 */
		private function onSthAdd(evt : Event) : void {
			if(isInspectView(evt.target as DisplayObject))return;
			if(this._isOn) {
				for each(var view:IInspectorView in _views) {
					view.onUpdate(curInspectEle);
				}
			}
		}

		/**
		 * 有显示对象移出显示列表时
		 */
		private function onSthRemove(evt : Event) : void {
			if(isInspectView(evt.target as DisplayObject))return;
			if(this._isOn) {
				for each(var view:IInspectorView in _views) {
					view.onUpdate(curInspectEle);
				}
			}
		}
	}
}

class SingletonEnforcer {
}


