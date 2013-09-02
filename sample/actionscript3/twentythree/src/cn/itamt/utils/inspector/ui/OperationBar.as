package cn.itamt.utils.inspector.ui {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;		

	/**
	 * @author tamt
	 */
	public class OperationBar extends Sprite {
		public static const PRESS_MOVE : String = 'press_move';
		public static const PRESS_PARENT : String = 'press_parent';
		public static const PRESS_CHILD : String = 'press_child';
		public static const PRESS_BROTHER : String = 'press_brother';
		public static const PRESS_INFO : String = 'press_info';		public static const PRESS_STRUCTURE : String = 'press_structure';
		public static const PRESS_CLOSE : String = 'press_close';
		public static const DOWN_MOVE : String = 'down_move';
		public static const UP_MOVE : String = 'up_move';		public static const DB_CLICK_MOVE : String = 'double_click_move';
		//按钮
		private var _moveBtn : InspectorViewMoveButton;
		private var _pareBtn : InspectorViewParentButton;
		private var _childBtn : InspectorViewChildButton;
		private var _broBtn : InspectorViewBrotherButton;
		private var _infoBtn : InspectorViewInfoButton;
		private var _struBtn : InspectorViewStructureButton;
		private var _closeBtn : InspectorViewCloseButton;
		//布局
		private var _paddings : Array = [10, 5, 10];
		private var _btnGap : int = 5;
		private var _width : int = 200;
		private var _height : int = 33;

		public function get barHeight() : int {
			return _height;
		}

		public function OperationBar() : void {
		}

		public function init() : void {
		
			//按钮
			var btns : Array = [_moveBtn = new InspectorViewMoveButton, 
									_pareBtn = new InspectorViewParentButton, 
									_childBtn = new InspectorViewChildButton, 
									_broBtn = new InspectorViewBrotherButton,
									_infoBtn = new InspectorViewInfoButton,
									_struBtn = new InspectorViewStructureButton];
			var btn : InspectorViewOperationButton;
			for(var i : int = 0;i < btns.length; i++) {
				btn = btns[i] as InspectorViewOperationButton;
				addChild(btn);
				if(i == 0) {
					btn.x = _paddings[0] + i * _btnGap;
				} else {
					btn.x = _paddings[0] + i * (_btnGap + (btns[i - 1] as InspectorViewOperationButton).width);
				}
				btn.y = _paddings[1]; 
			}
			//关闭按钮
			_closeBtn = new InspectorViewCloseButton;
			addChild(_closeBtn);
			_closeBtn.x = btn.x + btn.width + 20/* - _paddings[2] - _closeBtn.width*/;
			_closeBtn.y = _paddings[1];
			
			//背景
			graphics.clear();
			graphics.beginFill(0x393939);
			graphics.drawRoundRectComplex(0, 0, _closeBtn.x + _closeBtn.width + 10, _height, 8, 8, 0, 8);
			graphics.endFill();
			
			
			_moveBtn.doubleClickEnabled = true;
			_moveBtn.addEventListener(MouseEvent.CLICK, onClickMoveBtn);			_moveBtn.addEventListener(MouseEvent.MOUSE_DOWN, onDownMoveBtn);			_moveBtn.addEventListener(MouseEvent.MOUSE_UP, onUpMoveBtn);			_moveBtn.addEventListener(MouseEvent.DOUBLE_CLICK, onDlickMoveBtn);
			_pareBtn.addEventListener(MouseEvent.CLICK, onClickParentBtn);
			_childBtn.addEventListener(MouseEvent.CLICK, onClickChildBtn);
			_broBtn.addEventListener(MouseEvent.CLICK, onClickBrotherBtn);
			_infoBtn.addEventListener(MouseEvent.CLICK, onClickInfoBtn);			_closeBtn.addEventListener(MouseEvent.CLICK, onClickCloseBtn);
			_struBtn.addEventListener(MouseEvent.CLICK, onClickStruBtn);
		}

		/**
		 * 双击"拖动"按钮
		 */
		private function onDlickMoveBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(DB_CLICK_MOVE));
		}

		private function onClickMoveBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_MOVE));
		}

		private function onDownMoveBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(DOWN_MOVE));
		}

		private function onUpMoveBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(UP_MOVE));
		}

		private function onClickParentBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_PARENT));
		}

		private function onClickChildBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_CHILD));
		}

		private function onClickBrotherBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_BROTHER));
		}

		private function onClickInfoBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_INFO, true, true));
		}

		private function onClickStruBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_STRUCTURE, true, true));
		}

		private function onClickCloseBtn(evt : MouseEvent) : void {
			dispatchEvent(new Event(PRESS_CLOSE));
		}

		/**
		 * 销毁对象
		 */
		public function dispose() : void {
		}

		/**
		 * 验证target, 是否禁用相关按钮
		 */
		public function validate(target : DisplayObject) : void {
			_moveBtn.enabled = _pareBtn.enabled = _childBtn.enabled = _broBtn.enabled = /*_infoBtn.enabled =*/ _closeBtn.enabled = true;
			
			if(target is Stage) {
				_moveBtn.enabled = false;
			}
			
			if(target.parent) {
				if(target.parent is Stage) {
					_pareBtn.enabled = false;
				}
				//TODO:注意：目标的下一个“兄弟”可能是InspectView。
				if(target.parent.numChildren == 1) {
					_broBtn.enabled = false;
				}
			} else {
				_pareBtn.enabled = false;
				_broBtn.enabled = false;
			}
			
			if(target is DisplayObjectContainer){
			} else {
				_childBtn.enabled = false;
			}
		}
	}
}
